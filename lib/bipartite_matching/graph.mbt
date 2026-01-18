// ============================================================================
// BIPARTITE GRAPH - Graph Builder for Bipartite Matching
// ============================================================================
//
// A bipartite graph has two disjoint vertex sets: left and right.
// Edges only connect vertices from different sets.
//
// Left vertices are numbered 0..n_left-1
// Right vertices are numbered 0..n_right-1

///|
/// Bipartite graph representation.
/// Left vertices are numbered 0..n_left-1, right vertices 0..n_right-1.
struct BipartiteGraph {
  n_left : Int
  n_right : Int
  adj : Array[Array[Int]]
}

///|
/// Create a new bipartite graph.
/// 
/// Example:
/// ```
/// let graph = BipartiteGraph::new(3, 3)
/// graph.add_edge(0, 0)
/// graph.add_edge(1, 1)
/// let size = graph.hungarian().max_matching()
/// ```
pub fn BipartiteGraph::new(n_left : Int, n_right : Int) -> BipartiteGraph {
  let adj : Array[Array[Int]] = Array::makei(n_left, _ => [])
  { n_left, n_right, adj }
}

///|
/// Add an edge from left vertex u to right vertex v.
pub fn BipartiteGraph::add_edge(
  self : BipartiteGraph,
  u : Int,
  v : Int,
) -> Unit {
  // u is in left set (0..n_left-1), v is in right set (0..n_right-1)
  self.adj[u].push(v)
}

///|
/// Create a Hungarian algorithm matcher for this graph.
/// Time complexity: O(V * E)
pub fn BipartiteGraph::hungarian(self : BipartiteGraph) -> Hungarian {
  Hungarian::new(self)
}

///|
/// Create a Hopcroft-Karp algorithm matcher for this graph.
/// Time complexity: O(E * sqrt(V)) - faster for large graphs.
pub fn BipartiteGraph::hopcroft_karp(self : BipartiteGraph) -> HopcroftKarp {
  HopcroftKarp::new(self)
}
