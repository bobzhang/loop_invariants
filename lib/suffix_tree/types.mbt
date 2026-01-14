// ============================================================================
// SUFFIX TREE - Type Definitions
// ============================================================================
//
// Core data structures for the suffix tree. The tree is stored as an array of
// nodes, where each node has outgoing edges. Edges store substring labels as
// (start, end) index pairs into the original text, enabling O(1) edge creation
// without copying characters.
//
// MEMORY LAYOUT:
//   - Node 0 is always the root
//   - Leaf nodes have no outgoing edges
//   - Each suffix ends at a unique leaf (guaranteed by sentinel)

///|
/// Sentinel character appended to ensure no suffix is prefix of another.
/// Using NUL character which won't appear in normal text.
pub const SENTINEL : Char = '\u0000'

///|
/// An edge in the suffix tree, representing a substring of the original text.
///
/// FIELDS:
///   - start: Starting index in text (inclusive)
///   - end: Ending index in text (exclusive)
///   - child: Index of the child node this edge leads to
///
/// The edge label is text[start..end), stored implicitly to save memory.
/// For a text of length n, this reduces edge storage from O(n) to O(1).
pub(all) struct Edge {
  start : Int
  end : Int
  child : Int
}

///|
/// A node in the suffix tree.
///
/// FIELDS:
///   - edges: Outgoing edges, each labeled with a substring
///   - leaf_count: Number of leaves in this subtree (for occurrence counting)
///
/// INVARIANTS:
///   - All edges from a node start with distinct characters
///   - leaf_count is valid only after compute_leaf_counts() is called
///   - Leaf nodes (edges.length() == 0) have leaf_count == 1
pub(all) struct Node {
  edges : Array[Edge]
  mut leaf_count : Int
}

///|
/// The suffix tree data structure.
///
/// FIELDS:
///   - text: Original string as char array, with SENTINEL appended
///   - nodes: All nodes stored in a flat array (node 0 = root)
///
/// PROPERTIES:
///   - Every suffix of the original string corresponds to a root-to-leaf path
///   - Every root-to-leaf path spells out a suffix
///   - Substring queries run in O(m) where m = query length
pub struct SuffixTree {
  text : Array[Char]
  nodes : Array[Node]
}

///|
/// Create an empty node with no edges.
pub fn Node::new() -> Node {
  { edges: [], leaf_count: 0 }
}
