// ============================================================================
// BLOCK-CUT TREE - Articulation Points and Biconnected Components
// ============================================================================
//
// The block-cut tree is a bipartite graph between original vertices and
// biconnected components. Component nodes connect to every vertex that belongs
// to that component. Articulation points appear in multiple components.
//
// Node indexing:
// - Original vertices: 0 .. n-1
// - Component nodes: n .. n + c - 1
//
// TIME COMPLEXITY: O(V + E)
// SPACE COMPLEXITY: O(V + E)

///|
/// Block-cut tree representation.
pub struct BlockCutTree {
  original_vertices : Int
  component_count : Int
  adj : Array[Array[Int]]
}

///|
/// Build the block-cut tree of an undirected graph.
pub fn build_block_cut_tree(
  n : Int,
  edges : ArrayView[(Int, Int)],
) -> BlockCutTree {
  if n <= 0 {
    return { original_vertices: 0, component_count: 0, adj: [] }
  }
  let result = @biconnected_components.biconnected_components(n, edges)
  let comps = result.components
  let c = comps.length()
  let total = n + c
  let adj = Array::makei(total, _ => [])
  for ci = 0; ci < c; ci = ci + 1 {
    let comp_edges = comps[ci]
    let in_comp = Array::make(n, false)
    let vertices : Array[Int] = []
    for ei = 0; ei < comp_edges.length(); ei = ei + 1 {
      let (u, v) = comp_edges[ei]
      if not(in_comp[u]) {
        in_comp[u] = true
        vertices.push(u)
      }
      if not(in_comp[v]) {
        in_comp[v] = true
        vertices.push(v)
      }
    } where {
      invariant: ei >= 0 && ei <= comp_edges.length(),
      reasoning: (
        #|INVARIANT (collect component vertices):
        #|vertices contains the unique endpoints seen in comp_edges[0..ei).
        #|MAINTENANCE:
        #|Add u and v when they appear for the first time.
        #|TERMINATION:
        #|At ei = len, all vertices in the component are collected.
      ),
    }
    let comp_node = n + ci
    for vi = 0; vi < vertices.length(); vi = vi + 1 {
      let v = vertices[vi]
      adj[comp_node].push(v)
      adj[v].push(comp_node)
    } where {
      invariant: vi >= 0 && vi <= vertices.length(),
      reasoning: (
        #|INVARIANT (connect component):
        #|Component node comp_node is connected to vertices[0..vi).
        #|MAINTENANCE:
        #|Add the next vertex as a neighbor of the component node.
        #|TERMINATION:
        #|At vi = len, the component node connects to all its vertices.
      ),
    }
  } where {
    invariant: ci >= 0 && ci <= c,
    reasoning: (
      #|INVARIANT (block-cut construction):
      #|Block-cut edges for components [0..ci) have been added.
      #|MAINTENANCE:
      #|Collect vertices for component ci and connect them to its node.
      #|TERMINATION:
      #|At ci = c, all components are connected in the block-cut tree.
    ),
  }
  { original_vertices: n, component_count: c, adj }
}
