// Treap: Randomized Balanced Binary Search Tree
// Combines BST property (keys) with Heap property (priorities)
// With rigorous loop invariants and mathematical reasoning

// ============================================================================
// TREAP FUNDAMENTALS
// ============================================================================
//
// A Treap is a binary tree where each node has:
//   - key: satisfies BST property (left < node < right)
//   - priority: satisfies max-heap property (parent >= children)
//
// KEY THEOREM: If priorities are random and unique, the expected height
// of a Treap with n nodes is O(log n).
//
// PROOF INTUITION: With random priorities, each node has equal probability
// of being the root (the one with highest priority). This leads to a
// structure equivalent to a random BST built by inserting in a random order.

///|
struct TreapNode {
  key : Int
  priority : Int // random priority for balancing
  mut left : TreapNode?
  mut right : TreapNode?
  mut size : Int // subtree size for order statistics
}

///|
fn TreapNode::new(key : Int, priority : Int) -> TreapNode {
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
struct Treap {
  mut root : TreapNode?
  mut rand_state : Int // simple LCG random state
}

///|
fn Treap::new() -> Treap {
  { root: None, rand_state: 12345 }
}

///|
/// Simple LCG random number generator
fn Treap::next_random(self : Treap) -> Int {
  // LCG: state = (a * state + c) mod m
  // Using smaller parameters to avoid overflow
  self.rand_state = (self.rand_state * 1103 + 12345) % 65536
  if self.rand_state < 0 {
    -self.rand_state
  } else {
    self.rand_state
  }
}

// ============================================================================
// ROTATIONS (Maintain heap property while preserving BST property)
// ============================================================================

///|
/// Right rotation: lifts left child to become new root
///  Preserves BST property while allowing priority reordering
fn rotate_right(node : TreapNode) -> TreapNode {
  // Before:       node          After:       left
  //              /    \                     /    \
  //           left     C        =>         A     node
  //          /    \                              /   \
  //         A      B                            B     C
  match node.left {
    None => node
    Some(left) => {
      node.left = left.right
      left.right = Some(node)
      update_size(node)
      update_size(left)
      left
    }
  }
}

///|
/// Left rotation: lifts right child to become new root
fn rotate_left(node : TreapNode) -> TreapNode {
  match node.right {
    None => node
    Some(right) => {
      node.right = right.left
      right.left = Some(node)
      update_size(node)
      update_size(right)
      right
    }
  }
}

// ============================================================================
// INSERTION
// ============================================================================

///|
/// Insert a key into the treap
fn Treap::insert(self : Treap, key : Int) -> Unit {
  let priority = self.next_random()
  self.root = self.insert_helper(self.root, key, priority)
}

///|
/// Recursive insertion helper
fn Treap::insert_helper(
  self : Treap,
  node : TreapNode?,
  key : Int,
  priority : Int,
) -> TreapNode? {
  match node {
    None => Some(TreapNode::new(key, priority))
    Some(n) =>
      if key < n.key {
        n.left = self.insert_helper(n.left, key, priority)
        update_size(n)
        // Rotate right if heap property violated
        match n.left {
          Some(left) if left.priority > n.priority => Some(rotate_right(n))
          _ => Some(n)
        }
      } else if key > n.key {
        n.right = self.insert_helper(n.right, key, priority)
        update_size(n)
        // Rotate left if heap property violated
        match n.right {
          Some(right) if right.priority > n.priority => Some(rotate_left(n))
          _ => Some(n)
        }
      } else {
        // Key already exists
        Some(n)
      }
  }
}

// ============================================================================
// DELETION
// ============================================================================

///|
/// Delete a key from the treap
fn Treap::delete(self : Treap, key : Int) -> Unit {
  self.root = self.delete_helper(self.root, key)
}

///|
/// Recursive deletion helper
fn Treap::delete_helper(
  self : Treap,
  node : TreapNode?,
  key : Int,
) -> TreapNode? {
  match node {
    None => None
    Some(n) =>
      if key < n.key {
        n.left = self.delete_helper(n.left, key)
        update_size(n)
        Some(n)
      } else if key > n.key {
        n.right = self.delete_helper(n.right, key)
        update_size(n)
        Some(n)
      } else {
        // Found the node to delete
        // Rotate the node down until it becomes a leaf
        match (n.left, n.right) {
          (None, None) => None
          (Some(_), None) => n.left
          (None, Some(_)) => n.right
          (Some(left), Some(right)) =>
            // Rotate the higher priority child up
            if left.priority > right.priority {
              let rotated = rotate_right(n)
              rotated.right = self.delete_helper(rotated.right, key)
              update_size(rotated)
              Some(rotated)
            } else {
              let rotated = rotate_left(n)
              rotated.left = self.delete_helper(rotated.left, key)
              update_size(rotated)
              Some(rotated)
            }
        }
      }
  }
}

// ============================================================================
// SEARCH AND ORDER STATISTICS
// ============================================================================

///|
/// Search for a key in the treap
fn Treap::contains(self : Treap, key : Int) -> Bool {
  for node = self.root {
    match node {
      None => break false
      Some(n) =>
        if key < n.key {
          continue n.left
        } else if key > n.key {
          continue n.right
        } else {
          break true
        }
    }
  } where {
    invariant: true,
    reasoning: (
      #|BST SEARCH INVARIANT:
      #|  If key exists in the treap, it is in the subtree rooted at node.
      #|
      #|BASE CASE:
      #|  node = root, key could be anywhere in the tree
      #|
      #|INDUCTIVE STEP:
      #|  - If key < node.key, by BST property, key is in left subtree
      #|  - If key > node.key, by BST property, key is in right subtree
      #|  - If key == node.key, we found it
      #|
      #|TERMINATION:
      #|  Tree is finite; we descend one level each iteration.
      #|  Expected depth is O(log n) due to random priorities.
    ),
  }
}

///|
/// Find the k-th smallest element (1-indexed)
fn Treap::kth_element(self : Treap, k : Int) -> Int? {
  for node = self.root, remaining = k {
    match node {
      None => break None
      Some(n) => {
        let left_size = get_size(n.left)
        if remaining <= left_size {
          continue n.left, remaining
        } else if remaining == left_size + 1 {
          break Some(n.key)
        } else {
          continue n.right, remaining - left_size - 1
        }
      }
    }
  } where {
    invariant: remaining > 0,
    reasoning: (
      #|ORDER STATISTICS INVARIANT:
      #|  We're looking for the remaining-th smallest element in current subtree.
      #|
      #|CASES:
      #|  1. remaining <= left_size: Answer is in left subtree
      #|  2. remaining == left_size + 1: Current node is the answer
      #|  3. remaining > left_size + 1: Answer is in right subtree,
      #|     and we need the (remaining - left_size - 1)-th element there
      #|
      #|CORRECTNESS:
      #|  By BST property, left subtree has exactly left_size elements
      #|  smaller than current node. The (left_size + 1)-th smallest
      #|  is the current node itself.
    ),
  }
}

///|
/// Count elements less than key
fn Treap::count_less_than(self : Treap, key : Int) -> Int {
  for node = self.root, count = 0 {
    match node {
      None => break count
      Some(n) =>
        if key <= n.key {
          continue n.left, count
        } else {
          // key > n.key, so n and its left subtree are all less than key
          continue n.right, count + get_size(n.left) + 1
        }
    }
  } where {
    invariant: count >= 0,
    reasoning: (
      #|COUNT LESS THAN INVARIANT:
      #|  count = number of elements in already-processed subtrees that are < key
      #|  node = root of subtree where remaining elements to check reside
      #|
      #|INDUCTIVE STEP:
      #|  - If key <= n.key: All elements in right subtree are >= n.key >= key,
      #|    so only left subtree may have elements < key
      #|  - If key > n.key: The node n and its entire left subtree are < key,
      #|    so add (left_size + 1) to count and search right subtree
      #|
      #|TERMINATION:
      #|  count = total number of elements in treap that are < key
    ),
  }
}

// ============================================================================
// SPLIT AND MERGE (Key operations for implicit treaps)
// ============================================================================

///|
/// Split treap into two treaps: one with keys < key, one with keys >= key
fn Treap::split(node : TreapNode?, key : Int) -> (TreapNode?, TreapNode?) {
  match node {
    None => (None, None)
    Some(n) =>
      if n.key < key {
        let (left_part, right_part) = Treap::split(n.right, key)
        n.right = left_part
        update_size(n)
        (Some(n), right_part)
      } else {
        let (left_part, right_part) = Treap::split(n.left, key)
        n.left = right_part
        update_size(n)
        (left_part, Some(n))
      }
  }
}

///|
/// Merge two treaps where all keys in left < all keys in right
fn Treap::merge(left : TreapNode?, right : TreapNode?) -> TreapNode? {
  match (left, right) {
    (None, r) => r
    (l, None) => l
    (Some(l), Some(r)) =>
      if l.priority > r.priority {
        l.right = Treap::merge(l.right, Some(r))
        update_size(l)
        Some(l)
      } else {
        r.left = Treap::merge(Some(l), r.left)
        update_size(r)
        Some(r)
      }
  }
}

// ============================================================================
// IMPLICIT TREAP (Treap as array with efficient operations)
// ============================================================================

///|
struct ImplicitTreapNode {
  value : Int
  priority : Int
  mut left : ImplicitTreapNode?
  mut right : ImplicitTreapNode?
  mut size : Int
  mut lazy_rev : Bool // lazy propagation for reversal
}

///|
fn ImplicitTreapNode::new(value : Int, priority : Int) -> ImplicitTreapNode {
  { value, priority, left: None, right: None, size: 1, lazy_rev: false }
}

///|
fn implicit_get_size(node : ImplicitTreapNode?) -> Int {
  match node {
    None => 0
    Some(n) => n.size
  }
}

///|
fn implicit_update_size(node : ImplicitTreapNode) -> Unit {
  node.size = 1 + implicit_get_size(node.left) + implicit_get_size(node.right)
}

///|
/// Push down lazy reversal flag
fn push_down(node : ImplicitTreapNode) -> Unit {
  if node.lazy_rev {
    // Swap children
    let temp = node.left
    node.left = node.right
    node.right = temp
    // Propagate to children
    match node.left {
      Some(l) => l.lazy_rev = not(l.lazy_rev)
      None => ()
    }
    match node.right {
      Some(r) => r.lazy_rev = not(r.lazy_rev)
      None => ()
    }
    node.lazy_rev = false
  }
}

///|
struct ImplicitTreap {
  mut root : ImplicitTreapNode?
  mut rand_state : Int
}

///|
fn ImplicitTreap::new() -> ImplicitTreap {
  { root: None, rand_state: 54321 }
}

///|
fn ImplicitTreap::next_random(self : ImplicitTreap) -> Int {
  self.rand_state = (self.rand_state * 1103 + 12345) % 65536
  if self.rand_state < 0 {
    -self.rand_state
  } else {
    self.rand_state
  }
}

///|
/// Split by position (0-indexed)
fn ImplicitTreap::split_by_pos(
  node : ImplicitTreapNode?,
  pos : Int,
) -> (ImplicitTreapNode?, ImplicitTreapNode?) {
  match node {
    None => (None, None)
    Some(n) => {
      push_down(n)
      let left_size = implicit_get_size(n.left)
      if pos <= left_size {
        let (left_part, right_part) = ImplicitTreap::split_by_pos(n.left, pos)
        n.left = right_part
        implicit_update_size(n)
        (left_part, Some(n))
      } else {
        let (left_part, right_part) = ImplicitTreap::split_by_pos(
          n.right,
          pos - left_size - 1,
        )
        n.right = left_part
        implicit_update_size(n)
        (Some(n), right_part)
      }
    }
  }
}

///|
/// Merge implicit treaps
fn ImplicitTreap::merge(
  left : ImplicitTreapNode?,
  right : ImplicitTreapNode?,
) -> ImplicitTreapNode? {
  match (left, right) {
    (None, r) => r
    (l, None) => l
    (Some(l), Some(r)) => {
      push_down(l)
      push_down(r)
      if l.priority > r.priority {
        l.right = ImplicitTreap::merge(l.right, Some(r))
        implicit_update_size(l)
        Some(l)
      } else {
        r.left = ImplicitTreap::merge(Some(l), r.left)
        implicit_update_size(r)
        Some(r)
      }
    }
  }
}

///|
/// Insert value at position
fn ImplicitTreap::insert_at(
  self : ImplicitTreap,
  pos : Int,
  value : Int,
) -> Unit {
  let priority = self.next_random()
  let new_node = ImplicitTreapNode::new(value, priority)
  let (left, right) = ImplicitTreap::split_by_pos(self.root, pos)
  self.root = ImplicitTreap::merge(
    ImplicitTreap::merge(left, Some(new_node)),
    right,
  )
}

///|
/// Delete element at position
fn ImplicitTreap::delete_at(self : ImplicitTreap, pos : Int) -> Unit {
  let (left, rest) = ImplicitTreap::split_by_pos(self.root, pos)
  let (_, right) = ImplicitTreap::split_by_pos(rest, 1)
  self.root = ImplicitTreap::merge(left, right)
}

///|
/// Reverse range [l, r] (0-indexed, inclusive)
fn ImplicitTreap::reverse_range(self : ImplicitTreap, l : Int, r : Int) -> Unit {
  let (left, rest) = ImplicitTreap::split_by_pos(self.root, l)
  let (mid, right) = ImplicitTreap::split_by_pos(rest, r - l + 1)
  match mid {
    Some(m) => m.lazy_rev = not(m.lazy_rev)
    None => ()
  }
  self.root = ImplicitTreap::merge(ImplicitTreap::merge(left, mid), right)
}

///|
/// Get value at position
fn ImplicitTreap::get(self : ImplicitTreap, pos : Int) -> Int? {
  for node = self.root, remaining = pos {
    match node {
      None => break None
      Some(n) => {
        push_down(n)
        let left_size = implicit_get_size(n.left)
        if remaining < left_size {
          continue n.left, remaining
        } else if remaining == left_size {
          break Some(n.value)
        } else {
          continue n.right, remaining - left_size - 1
        }
      }
    }
  } where {
    invariant: remaining >= 0,
    reasoning: (
      #|IMPLICIT TREAP ACCESS INVARIANT:
      #|  remaining = target index within current subtree
      #|
      #|The implicit treap represents an array where:
      #|  - In-order traversal gives array elements in order
      #|  - Position is determined by subtree sizes, not stored keys
      #|
      #|CASES:
      #|  1. remaining < left_size: Element is in left subtree
      #|  2. remaining == left_size: Current node is at target position
      #|  3. remaining > left_size: Element is in right subtree at adjusted position
      #|
      #|LAZY PROPAGATION:
      #|  push_down ensures reversal flags are applied before we descend.
    ),
  }
}

///|
/// Convert to array
fn ImplicitTreap::to_array(self : ImplicitTreap) -> Array[Int] {
  let result : Array[Int] = []
  self.inorder_collect(self.root, result)
  result
}

///|
/// In-order traversal to collect elements
fn ImplicitTreap::inorder_collect(
  self : ImplicitTreap,
  node : ImplicitTreapNode?,
  result : Array[Int],
) -> Unit {
  match node {
    None => ()
    Some(n) => {
      push_down(n)
      self.inorder_collect(n.left, result)
      result.push(n.value)
      self.inorder_collect(n.right, result)
    }
  }
}

// ============================================================================
// TESTS
// ============================================================================

///|
test "treap_basic_insert_search" {
  let treap = Treap::new()
  treap.insert(5)
  treap.insert(3)
  treap.insert(7)
  treap.insert(1)
  treap.insert(9)
  inspect(treap.contains(5), content="true")
  inspect(treap.contains(3), content="true")
  inspect(treap.contains(7), content="true")
  inspect(treap.contains(1), content="true")
  inspect(treap.contains(9), content="true")
  inspect(treap.contains(4), content="false")
  inspect(treap.contains(0), content="false")
}

///|
test "treap_delete" {
  let treap = Treap::new()
  treap.insert(5)
  treap.insert(3)
  treap.insert(7)
  inspect(treap.contains(5), content="true")
  treap.delete(5)
  inspect(treap.contains(5), content="false")
  inspect(treap.contains(3), content="true")
  inspect(treap.contains(7), content="true")
}

///|
test "treap_kth_element" {
  let treap = Treap::new()
  // Insert: 5, 3, 7, 1, 9, 4, 6
  treap.insert(5)
  treap.insert(3)
  treap.insert(7)
  treap.insert(1)
  treap.insert(9)
  treap.insert(4)
  treap.insert(6)
  // Sorted: 1, 3, 4, 5, 6, 7, 9
  inspect(treap.kth_element(1), content="Some(1)")
  inspect(treap.kth_element(2), content="Some(3)")
  inspect(treap.kth_element(3), content="Some(4)")
  inspect(treap.kth_element(4), content="Some(5)")
  inspect(treap.kth_element(7), content="Some(9)")
  inspect(treap.kth_element(8), content="None")
}

///|
test "treap_count_less_than" {
  let treap = Treap::new()
  treap.insert(5)
  treap.insert(3)
  treap.insert(7)
  treap.insert(1)
  treap.insert(9)
  // Elements: 1, 3, 5, 7, 9
  inspect(treap.count_less_than(0), content="0")
  inspect(treap.count_less_than(1), content="0")
  inspect(treap.count_less_than(2), content="1")
  inspect(treap.count_less_than(5), content="2")
  inspect(treap.count_less_than(6), content="3")
  inspect(treap.count_less_than(10), content="5")
}

///|
test "treap_split_merge" {
  let treap = Treap::new()
  treap.insert(5)
  treap.insert(3)
  treap.insert(7)
  treap.insert(1)
  treap.insert(9)
  // Split at key 6: left has {1,3,5}, right has {7,9}
  let (left, right) = Treap::split(treap.root, 6)
  inspect(get_size(left), content="3")
  inspect(get_size(right), content="2")
  // Merge back
  let merged = Treap::merge(left, right)
  inspect(get_size(merged), content="5")
}

///|
test "implicit_treap_basic" {
  let treap = ImplicitTreap::new()
  // Build array [1, 2, 3, 4, 5]
  treap.insert_at(0, 1)
  treap.insert_at(1, 2)
  treap.insert_at(2, 3)
  treap.insert_at(3, 4)
  treap.insert_at(4, 5)
  inspect(treap.get(0), content="Some(1)")
  inspect(treap.get(2), content="Some(3)")
  inspect(treap.get(4), content="Some(5)")
}

///|
test "implicit_treap_insert_delete" {
  let treap = ImplicitTreap::new()
  treap.insert_at(0, 1)
  treap.insert_at(1, 3)
  treap.insert_at(1, 2) // Insert 2 at position 1
  // Array: [1, 2, 3]
  inspect(treap.get(0), content="Some(1)")
  inspect(treap.get(1), content="Some(2)")
  inspect(treap.get(2), content="Some(3)")
  treap.delete_at(1) // Delete at position 1
  // Array: [1, 3]
  inspect(treap.get(0), content="Some(1)")
  inspect(treap.get(1), content="Some(3)")
}

///|
test "implicit_treap_reverse" {
  let treap = ImplicitTreap::new()
  for i = 1; i <= 5; i = i + 1 {
    treap.insert_at(i - 1, i)
  }
  // Array: [1, 2, 3, 4, 5]
  treap.reverse_range(1, 3)
  // Array: [1, 4, 3, 2, 5]
  let arr = treap.to_array()
  inspect(arr[0], content="1")
  inspect(arr[1], content="4")
  inspect(arr[2], content="3")
  inspect(arr[3], content="2")
  inspect(arr[4], content="5")
}

///|
test "implicit_treap_full_reverse" {
  let treap = ImplicitTreap::new()
  for i = 1; i <= 4; i = i + 1 {
    treap.insert_at(i - 1, i)
  }
  // Array: [1, 2, 3, 4]
  treap.reverse_range(0, 3)
  // Array: [4, 3, 2, 1]
  let arr = treap.to_array()
  inspect(arr[0], content="4")
  inspect(arr[1], content="3")
  inspect(arr[2], content="2")
  inspect(arr[3], content="1")
}

///|
test "treap_empty" {
  let treap = Treap::new()
  inspect(treap.contains(1), content="false")
  inspect(treap.kth_element(1), content="None")
  inspect(treap.count_less_than(0), content="0")
}

///|
test "treap_duplicate_insert" {
  let treap = Treap::new()
  treap.insert(5)
  treap.insert(5)
  treap.insert(5)
  inspect(treap.contains(5), content="true")
  // Size should still be 1 (no duplicates)
  inspect(get_size(treap.root), content="1")
}
