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
pub struct TreapNode {
  key : Int64
  priority : Int // Random priority
  mut left : TreapNode?
  mut right : TreapNode?
  mut size : Int // Subtree size for order statistics
}

///|
fn TreapNode::new(key : Int64, priority : Int) -> TreapNode {
  { key, priority, left: None, right: None, size: 1 }
}

///|
fn get_size(node : TreapNode?) -> Int {
  match node {
    None => 0
    Some(n) => n.size
  }
}

///|
fn update_size(node : TreapNode) -> Unit {
  node.size = 1 + get_size(node.left) + get_size(node.right)
}

///|
/// Randomized BST that supports order statistics.
pub struct Treap {
  mut root : TreapNode?
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
pub fn Treap::new() -> Treap {
  { root: None, rng_state: 42 }
}

///|
/// Split tree into (keys < key, keys >= key)
fn split(node : TreapNode?, key : Int64) -> (TreapNode?, TreapNode?) {
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
fn merge(l : TreapNode?, r : TreapNode?) -> TreapNode? {
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
pub fn Treap::insert(self : Treap, key : Int64) -> Unit {
  let (next_state, priority) = next_random(self.rng_state)
  self.rng_state = next_state
  let new_node = TreapNode::new(key, priority)
  let (l, r) = split(self.root, key)
  self.root = merge(merge(l, Some(new_node)), r)
}

///|
/// Delete a key from the treap (only one occurrence if duplicates exist).
pub fn Treap::delete(self : Treap, key : Int64) -> Bool {
  let (l, r) = split(self.root, key)
  let (mid, r2) = split(r, key + 1L)
  match mid {
    None => {
      self.root = merge(l, r2)
      false
    }
    Some(mid_node) => {
      // Delete only one occurrence: keep either left or right subtree of mid
      // mid_node contains all elements with this key
      // We keep all children (which are also key-duplicates) but remove the root
      let remaining = merge(mid_node.left, mid_node.right)
      self.root = merge(merge(l, remaining), r2)
      true
    }
  }
}
