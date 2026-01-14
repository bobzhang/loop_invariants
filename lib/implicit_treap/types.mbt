// ============================================================================
// IMPLICIT TREAP - Type Definitions
// ============================================================================
//
// A Treap with Implicit Keys is a balanced BST that maintains a sequence where
// positions are determined implicitly by subtree sizes rather than stored keys.
//
// KEY INSIGHT:
// ```
//   Instead of storing keys, each node's "key" is its position in the
//   in-order traversal. This position is computed dynamically as:
//
//     position(node) = size(left_subtree) + positions from ancestors going right
//
//   This means:
//   - No keys need to be stored or updated
//   - Insert/delete at any position is O(log n)
//   - Split/merge preserve positions automatically
// ```
//
// STRUCTURE:
// ```
//   BST Property: Left subtree contains elements with smaller positions
//   Heap Property: Parent priority > children priorities
//
//   Example: Sequence [A, B, C, D, E]
//
//            C(0.8)         BST order by implicit position
//           / \             Heap order by priority
//         B(0.5) D(0.6)
//         /       \
//       A(0.2)   E(0.3)
//
//   Position of C = size(left) = 2 → C is at index 2
//   Position of A = 0 (leftmost)
//   Position of E = 2 + 1 + 1 = 4 (rightmost)
// ```
//
// WHY TREAP?
// ```
//   Random priorities ensure expected O(log n) height.
//   Unlike AVL/Red-Black trees:
//   - No complex rebalancing rules
//   - Split/merge naturally preserve balance
//   - Simpler implementation
// ```
//
// OPERATIONS (all O(log n) expected):
// ```
//   split(k):     Split into [0..k) and [k..n)
//   merge(t1,t2): Merge sequences (all t1 positions < t2 positions)
//   insert(pos):  Insert at position via split + merge
//   delete(pos):  Delete at position via split + merge
//   reverse(l,r): Reverse range [l,r) with lazy propagation
// ```
//
// APPLICATIONS:
//   - Rope data structure (text editors)
//   - Ordered list with fast insert/delete
//   - Range queries with modifications

///|
/// Node in implicit treap.
///
/// FIELDS:
/// ```
///   val:      Value stored at this position
///   priority: Random priority for heap property (higher = closer to root)
///   size:     Size of subtree (for implicit key computation)
///   sum:      Sum of values in subtree (for range sum queries)
///   min_val:  Minimum value in subtree
///   max_val:  Maximum value in subtree
///   rev:      Lazy reversal flag (children should be swapped)
///   left:     Index of left child (-1 if none)
///   right:    Index of right child (-1 if none)
/// ```
///
/// IMPLICIT KEY COMPUTATION:
/// ```
///   The key (position) of a node is:
///     size(left_subtree) + sum of (size(left_subtree) + 1)
///     for each ancestor where we went right
///
///   This is computed dynamically during traversal.
/// ```
pub(all) struct ImplicitNode {
  mut val : Int64 // Value stored at this position
  priority : Int // Random priority for heap property
  mut size : Int // Size of subtree (for implicit key computation)
  mut sum : Int64 // Sum of values in subtree (for range queries)
  mut min_val : Int64 // Minimum value in subtree
  mut max_val : Int64 // Maximum value in subtree
  mut rev : Bool // Lazy reversal flag
  mut left : Int // Index of left child (-1 if none)
  mut right : Int // Index of right child (-1 if none)
}

///|
/// Implicit Treap data structure.
///
/// COMPONENTS:
/// ```
///   nodes:      Array-based node storage (indices instead of pointers)
///   root:       Index of root node (-1 if empty)
///   rand_state: State for random priority generation
///   free_list:  Recycled node indices for reuse
/// ```
///
/// MEMORY MANAGEMENT:
/// ```
///   Nodes are stored in a flat array with index-based references.
///   When a node is deleted, its index goes to free_list.
///   Allocation prefers free_list, then appends to array.
/// ```
pub(all) struct ImplicitTreap {
  nodes : Array[ImplicitNode]
  mut root : Int
  mut rand_state : Int
  free_list : Array[Int]
}

///|
/// Create a new empty implicit treap.
pub fn ImplicitTreap::new() -> ImplicitTreap {
  { nodes: [], root: -1, rand_state: 12345, free_list: [] }
}

///|
/// Get the number of elements in the treap.
pub fn ImplicitTreap::size(self : ImplicitTreap) -> Int {
  self.get_size(self.root)
}
