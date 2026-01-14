// ============================================================================
// TREAP - Randomized Binary Search Tree
// ============================================================================
//
// A Treap is a randomized BST that combines properties of:
// 1. Binary Search Tree: keys satisfy BST property
// 2. Heap: priorities satisfy heap property (max-heap)
//
// KEY INSIGHT: Random priorities ensure expected O(log n) height,
// giving O(log n) expected time for all operations.
//
// STRUCTURE:
// Each node has:
// - key: satisfies BST property (left < key < right)
// - priority: random value, satisfies max-heap property (parent >= children)
//
// OPERATIONS via SPLIT and MERGE:
// - split(t, key): split tree t into (< key, >= key)
// - merge(l, r): merge two trees where all keys in l < all keys in r
//
// SPLIT(t, key):
// If t is empty: return (null, null)
// If t.key < key: (l, r) = split(t.right, key); return (t with right=l, r)
// Else: (l, r) = split(t.left, key); return (l, t with left=r)
//
// MERGE(l, r):
// If l or r is empty: return the other
// If l.priority > r.priority: return l with right = merge(l.right, r)
// Else: return r with left = merge(l, r.left)
//
// INVARIANTS:
// 1. BST property: for each node, all keys in left subtree < node.key < all keys in right
// 2. Heap property: for each node, node.priority >= children's priorities
// 3. Random priorities give expected O(log n) height
//
// EXPECTED TIME COMPLEXITY: O(log n) for insert, delete, find
// SPACE COMPLEXITY: O(n)

///|
/// Node in the treap (BST key + heap priority).
pub struct TreapNode[T] {
  key : T
  priority : Int // Random priority
  mut left : TreapNode[T]?
  mut right : TreapNode[T]?
  mut size : Int // Subtree size for order statistics
}

///|
fn[T] TreapNode::new(key : T, priority : Int) -> TreapNode[T] {
  { key, priority, left: None, right: None, size: 1 }
}

///|
fn[T] get_size(node : TreapNode[T]?) -> Int {
  match node {
    None => 0
    Some(n) => n.size
  }
}

///|
fn[T] update_size(node : TreapNode[T]) -> Unit {
  node.size = 1 + get_size(node.left) + get_size(node.right)
}

///|
/// Randomized BST that supports order statistics (keys must be comparable).
pub struct Treap[T] {
  mut root : TreapNode[T]?
  mut rng_state : Int // Simple LCG random number generator
}

///|
/// Simple LCG random number generator
fn next_random(state : Int) -> (Int, Int) {
  // LCG: next = (a * state + c) mod m
  // Using common constants
  let a = 1103515245
  let c = 12345
  let next = a * state + c
  (next, if next < 0 { -next } else { next })
}

///|
/// Create an empty treap with a deterministic RNG seed.
pub fn[T] Treap::new() -> Treap[T] {
  { root: None, rng_state: 42 }
}

///|
/// Split tree into (keys < key, keys >= key)
fn[T : Compare] split(
  node : TreapNode[T]?,
  key : T,
) -> (TreapNode[T]?, TreapNode[T]?) {
  match node {
    None => (None, None)
    Some(n) =>
      if n.key < key {
        let (l, r) = split(n.right, key)
        n.right = l
        update_size(n)
        (Some(n), r)
      } else {
        let (l, r) = split(n.left, key)
        n.left = r
        update_size(n)
        (l, Some(n))
      }
  }
}

///|
/// Merge two treaps where all keys in l < all keys in r
fn[T] merge(l : TreapNode[T]?, r : TreapNode[T]?) -> TreapNode[T]? {
  match (l, r) {
    (None, r) => r
    (l, None) => l
    (Some(ln), Some(rn)) =>
      if ln.priority > rn.priority {
        ln.right = merge(ln.right, Some(rn))
        update_size(ln)
        Some(ln)
      } else {
        rn.left = merge(Some(ln), rn.left)
        update_size(rn)
        Some(rn)
      }
  }
}

///|
/// Insert a key into the treap.
pub fn[T : Compare] Treap::insert(self : Treap[T], key : T) -> Unit {
  let (next_state, priority) = next_random(self.rng_state)
  self.rng_state = next_state
  let new_node = TreapNode::new(key, priority)
  let (l, r) = split(self.root, key)
  self.root = merge(merge(l, Some(new_node)), r)
}

///|
/// Delete a key from the treap (only one occurrence if duplicates exist).
pub fn[T : Compare] Treap::delete(self : Treap[T], key : T) -> Bool {
  let (next_root, deleted) = delete_node(self.root, key)
  self.root = next_root
  deleted
}

///|
/// Remove a single node with matching key and return (new_root, deleted).
fn[T : Compare] delete_node(
  node : TreapNode[T]?,
  key : T,
) -> (TreapNode[T]?, Bool) {
  match node {
    None => (None, false)
    Some(n) =>
      if key < n.key {
        let (new_left, deleted) = delete_node(n.left, key)
        n.left = new_left
        if deleted {
          update_size(n)
        }
        (Some(n), deleted)
      } else if key > n.key {
        let (new_right, deleted) = delete_node(n.right, key)
        n.right = new_right
        if deleted {
          update_size(n)
        }
        (Some(n), deleted)
      } else {
        (merge(n.left, n.right), true)
      }
  }
}
