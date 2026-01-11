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
priv struct TreapNode {
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
/// Treap data structure
priv struct Treap {
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
fn Treap::new() -> Treap {
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
/// Insert a key into the treap
fn Treap::insert(self : Treap, key : Int64) -> Unit {
  let (next_state, priority) = next_random(self.rng_state)
  self.rng_state = next_state
  let new_node = TreapNode::new(key, priority)
  let (l, r) = split(self.root, key)
  self.root = merge(merge(l, Some(new_node)), r)
}

///|
/// Delete a key from the treap (only one occurrence if duplicates exist)
fn Treap::delete(self : Treap, key : Int64) -> Bool {
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

///|
/// Check if a key exists in the treap
fn Treap::contains(self : Treap, key : Int64) -> Bool {
  find_node(self.root, key) is Some(_)
}

///|
fn find_node(node : TreapNode?, key : Int64) -> TreapNode? {
  match node {
    None => None
    Some(n) =>
      if key < n.key {
        find_node(n.left, key)
      } else if key > n.key {
        find_node(n.right, key)
      } else {
        Some(n)
      }
  }
}

///|
/// Get the k-th smallest element (0-indexed)
fn Treap::kth_element(self : Treap, k : Int) -> Int64? {
  kth_helper(self.root, k)
}

///|
fn kth_helper(node : TreapNode?, k : Int) -> Int64? {
  match node {
    None => None
    Some(n) => {
      let left_size = get_size(n.left)
      if k < left_size {
        kth_helper(n.left, k)
      } else if k == left_size {
        Some(n.key)
      } else {
        kth_helper(n.right, k - left_size - 1)
      }
    }
  }
}

///|
/// Count elements less than key
fn Treap::count_less_than(self : Treap, key : Int64) -> Int {
  count_less_helper(self.root, key)
}

///|
fn count_less_helper(node : TreapNode?, key : Int64) -> Int {
  match node {
    None => 0
    Some(n) =>
      if n.key < key {
        1 + get_size(n.left) + count_less_helper(n.right, key)
      } else {
        count_less_helper(n.left, key)
      }
  }
}

///|
fn Treap::size(self : Treap) -> Int {
  get_size(self.root)
}

///|
/// Get minimum element
fn Treap::min(self : Treap) -> Int64? {
  min_helper(self.root)
}

///|
fn min_helper(node : TreapNode?) -> Int64? {
  match node {
    None => None
    Some(n) =>
      match n.left {
        None => Some(n.key)
        Some(_) => min_helper(n.left)
      }
  }
}

///|
/// Get maximum element
fn Treap::max(self : Treap) -> Int64? {
  max_helper(self.root)
}

///|
fn max_helper(node : TreapNode?) -> Int64? {
  match node {
    None => None
    Some(n) =>
      match n.right {
        None => Some(n.key)
        Some(_) => max_helper(n.right)
      }
  }
}

///|
/// Get elements in sorted order
fn Treap::to_array(self : Treap) -> Array[Int64] {
  let result : Array[Int64] = []
  inorder(self.root, result)
  result
}

///|
fn inorder(node : TreapNode?, result : Array[Int64]) -> Unit {
  match node {
    None => ()
    Some(n) => {
      inorder(n.left, result)
      result.push(n.key)
      inorder(n.right, result)
    }
  }
}

// ============================================================================
// TESTS
// ============================================================================

///|
test "treap basic insert" {
  let t = Treap::new()
  t.insert(5L)
  t.insert(3L)
  t.insert(7L)
  t.insert(1L)
  t.insert(9L)
  inspect(t.size(), content="5")
  inspect(t.contains(5L), content="true")
  inspect(t.contains(3L), content="true")
  inspect(t.contains(10L), content="false")
}

///|
test "treap delete" {
  let t = Treap::new()
  t.insert(5L)
  t.insert(3L)
  t.insert(7L)
  inspect(t.delete(3L), content="true")
  inspect(t.contains(3L), content="false")
  inspect(t.size(), content="2")
  inspect(t.delete(10L), content="false")
}

///|
test "treap kth element" {
  let t = Treap::new()
  t.insert(5L)
  t.insert(3L)
  t.insert(7L)
  t.insert(1L)
  t.insert(9L)

  // Sorted: 1, 3, 5, 7, 9
  inspect(t.kth_element(0), content="Some(1)")
  inspect(t.kth_element(2), content="Some(5)")
  inspect(t.kth_element(4), content="Some(9)")
  inspect(t.kth_element(5), content="None")
}

///|
test "treap count less than" {
  let t = Treap::new()
  t.insert(5L)
  t.insert(3L)
  t.insert(7L)
  t.insert(1L)
  t.insert(9L)
  inspect(t.count_less_than(5L), content="2") // 1, 3
  inspect(t.count_less_than(1L), content="0")
  inspect(t.count_less_than(10L), content="5")
}

///|
test "treap min max" {
  let t = Treap::new()
  t.insert(5L)
  t.insert(3L)
  t.insert(7L)
  inspect(t.min(), content="Some(3)")
  inspect(t.max(), content="Some(7)")
}

///|
test "treap to array" {
  let t = Treap::new()
  t.insert(5L)
  t.insert(3L)
  t.insert(7L)
  t.insert(1L)
  t.insert(9L)
  let arr = t.to_array()
  inspect(arr.length(), content="5")
  inspect(arr[0], content="1")
  inspect(arr[4], content="9")
}

///|
test "treap empty" {
  let t = Treap::new()
  inspect(t.size(), content="0")
  inspect(t.min(), content="None")
  inspect(t.max(), content="None")
  inspect(t.kth_element(0), content="None")
}

///|
test "treap single element" {
  let t = Treap::new()
  t.insert(42L)
  inspect(t.size(), content="1")
  inspect(t.contains(42L), content="true")
  inspect(t.min(), content="Some(42)")
  inspect(t.max(), content="Some(42)")
}

///|
test "treap duplicates" {
  let t = Treap::new()
  t.insert(5L)
  t.insert(5L)
  t.insert(5L)
  inspect(t.size(), content="3")
  inspect(t.delete(5L), content="true")
  inspect(t.size(), content="2")
}

///|
test "treap sorted insertion" {
  let t = Treap::new()
  for i in 0..<10 {
    t.insert(i.to_int64())
  }
  inspect(t.size(), content="10")
  inspect(t.kth_element(0), content="Some(0)")
  inspect(t.kth_element(9), content="Some(9)")
}

///|
test "treap reverse sorted insertion" {
  let t = Treap::new()
  for i = 9; i >= 0; i = i - 1 {
    t.insert(i.to_int64())
  } where {
    invariant: i >= -1 && i <= 9,
    reasoning: (
      #|INVARIANT (reverse insertion):
      #|Values in (i..9] have been inserted; remaining values are <= i.
      #|MAINTENANCE:
      #|Insert i, then decrement to continue the reverse sequence.
      #|TERMINATION:
      #|At i = -1, all values 0..9 are inserted.
    ),
  }
  inspect(t.size(), content="10")
  let arr = t.to_array()
  for i in 0..<10 {
    inspect(arr[i] == i.to_int64(), content="true")
  }
}
