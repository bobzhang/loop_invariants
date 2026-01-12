// ============================================================================
// BICONNECTED COMPONENTS - Undirected Graph Decomposition
// ============================================================================
//
// A biconnected component (block) is a maximal subgraph where any two vertices
// remain connected after removing any single vertex. Equivalently, there is no
// articulation point inside a block.
//
// Tarjan's DFS builds discovery times (disc) and low-link values (low):
// low[u] = minimum discovery time reachable from u using at most one back edge.
//
// BLOCK RULE:
// For a tree edge (u, v), if low[v] >= disc[u], then all edges on the DFS stack
// from (u, v) up to the top form one biconnected component.
//
// ARTICULATION RULE:
// - Root is articulation if it has >= 2 DFS children.
// - Non-root u is articulation if it has a child v with low[v] >= disc[u].
//
// INVARIANTS:
// 1. disc values increase strictly in DFS order.
// 2. low[u] is the minimum disc reachable from u's subtree.
// 3. The edge stack stores exactly the DFS edges not yet assigned to a block.
//
// TIME COMPLEXITY: O(V + E)
// SPACE COMPLEXITY: O(V + E)

///|
/// Result of biconnected decomposition.
pub(all) struct BiconnectedResult {
  components : Array[Array[(Int, Int)]]
  articulation_points : Array[Int]
}

///|
priv struct BiconnectedFinder {
  n : Int
  adj : Array[Array[(Int, Int)]] // (neighbor, edge_id)
  disc : Array[Int]
  low : Array[Int]
  parent_edge : Array[Int]
  edge_stack : Array[(Int, Int)]
  articulation : Array[Bool]
  components : Array[Array[(Int, Int)]]
  mut timer : Int
}

///|
fn BiconnectedFinder::new(n : Int) -> BiconnectedFinder {
  let adj = Array::make(n, [])
  for i = 0; i < n; i = i + 1 {
    adj[i] = []
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: (
      #|INVARIANT (adj init):
      #|adj[0..i) are distinct empty lists ready to receive edges.
      #|MAINTENANCE:
      #|Assign a fresh empty list at adj[i].
      #|TERMINATION:
      #|At i = n, every adjacency list is initialized.
    ),
  }
  {
    n,
    adj,
    disc: Array::make(n, -1),
    low: Array::make(n, -1),
    parent_edge: Array::make(n, -1),
    edge_stack: [],
    articulation: Array::make(n, false),
    components: [],
    timer: 0,
  }
}

///|
fn BiconnectedFinder::add_edge(
  self : BiconnectedFinder,
  u : Int,
  v : Int,
  id : Int,
) -> Unit {
  self.adj[u].push((v, id))
  self.adj[v].push((u, id))
}

///|
fn min(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn BiconnectedFinder::dfs(
  self : BiconnectedFinder,
  u : Int,
  p_edge : Int,
) -> Unit {
  self.disc[u] = self.timer
  self.low[u] = self.timer
  self.timer = self.timer + 1
  self.parent_edge[u] = p_edge
  let mut children = 0
  for i = 0; i < self.adj[u].length(); i = i + 1 {
    let (v, eid) = self.adj[u][i]
    if eid == p_edge {
      continue
    }
    if self.disc[v] == -1 {
      // Tree edge
      children = children + 1
      self.edge_stack.push((u, v))
      self.dfs(v, eid)
      self.low[u] = min(self.low[u], self.low[v])

      // Articulation test for non-root
      if p_edge != -1 && self.low[v] >= self.disc[u] {
        self.articulation[u] = true
      }

      // Extract a biconnected component
      if self.low[v] >= self.disc[u] {
        let comp : Array[(Int, Int)] = []
        for {
          if self.edge_stack.length() == 0 {
            break
          }
          let e = self.edge_stack.pop().unwrap()
          comp.push(e)
          if e == (u, v) || e == (v, u) {
            break
          }
        } where {
          invariant: comp.length() + self.edge_stack.length() >= 0,
          reasoning: (
            #|INVARIANT (component pop):
            #|comp contains a suffix of the DFS edge stack, popped from the top.
            #|Those edges are exactly the ones discovered after (u, v) and belong
            #|to the same biconnected block separated by (u, v).
            #|MAINTENANCE:
            #|Pop one edge per iteration, preserving the suffix property.
            #|TERMINATION:
            #|Stop once the boundary edge (u, v) is removed, yielding the block.
          ),
        }
        if comp.length() > 0 {
          self.components.push(comp)
        }
      }
    } else if self.disc[v] < self.disc[u] {
      // Back edge to an ancestor (unique direction for undirected graph)
      self.edge_stack.push((u, v))
      self.low[u] = min(self.low[u], self.disc[v])
    }
  } where {
    invariant: i >= 0 && i <= self.adj[u].length(),
    reasoning: (
      #|INVARIANT (DFS neighbors):
      #|Neighbors in adj[u][0..i) are processed; low[u] equals the minimum
      #|discovery time reachable through those neighbors or their subtrees.
      #|The edge stack holds all DFS edges not yet assigned to a component.
      #|MAINTENANCE:
      #|Tree edges recurse and update low; back edges update low directly and
      #|are pushed to the stack to belong to some future component.
      #|TERMINATION:
      #|At i = deg(u), low[u] reflects the full subtree of u.
    ),
  }

  // Root articulation check
  if p_edge == -1 && children > 1 {
    self.articulation[u] = true
  }
}

///|
fn BiconnectedFinder::run(self : BiconnectedFinder) -> Unit {
  for v = 0; v < self.n; v = v + 1 {
    if self.disc[v] == -1 {
      self.dfs(v, -1)
    }
  } where {
    invariant: v >= 0 && v <= self.n,
    reasoning: (
      #|INVARIANT (component scan):
      #|Vertices in [0..v) are fully processed and assigned to components.
      #|MAINTENANCE:
      #|If v is unvisited, start a DFS to cover its connected component.
      #|TERMINATION:
      #|At v = n, all components are processed.
    ),
  }
}

///|
fn BiconnectedFinder::collect_articulation_points(
  self : BiconnectedFinder,
) -> Array[Int] {
  let result : Array[Int] = []
  for i = 0; i < self.n; i = i + 1 {
    if self.articulation[i] {
      result.push(i)
    }
  } where {
    invariant: i >= 0 && i <= self.n,
    reasoning: (
      #|INVARIANT (collect APs):
      #|result contains articulation points among vertices in [0..i).
      #|MAINTENANCE:
      #|Append i when articulation[i] is true.
      #|TERMINATION:
      #|At i = n, all articulation points are collected.
    ),
  }
  result
}

///|
/// Compute biconnected components of an undirected graph.
/// Each component is returned as an array of edges (u, v).
pub fn biconnected_components(
  n : Int,
  edges : ArrayView[(Int, Int)],
) -> BiconnectedResult {
  if n <= 0 {
    return { components: [], articulation_points: [] }
  }
  let finder = BiconnectedFinder::new(n)
  for i = 0; i < edges.length(); i = i + 1 {
    let (u, v) = edges[i]
    if u >= 0 && u < n && v >= 0 && v < n {
      finder.add_edge(u, v, i)
    }
  } where {
    invariant: i >= 0 && i <= edges.length(),
    reasoning: (
      #|INVARIANT (edge add):
      #|All edges in edges[0..i) have been inserted into the adjacency lists.
      #|MAINTENANCE:
      #|Insert edge i if its endpoints are in range.
      #|TERMINATION:
      #|At i = edges.length(), the graph is fully built.
    ),
  }
  finder.run()
  let points = finder.collect_articulation_points()
  { components: finder.components, articulation_points: points }
}

// ============================================================================
// TESTS
// ============================================================================

///|
test "biconnected components basic" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (2, 0), (1, 3)]
  let result = biconnected_components(4, edges[:])
  let sizes = result.components.map(fn(c) { c.length() })
  sizes.sort_by(fn(a, b) { a - b })
  inspect(sizes, content="[1, 3]")
  result.articulation_points.sort_by(fn(a, b) { a - b })
  inspect(result.articulation_points, content="[1]")
}

///|
test "biconnected components tree" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (1, 3)]
  let result = biconnected_components(4, edges[:])
  let sizes = result.components.map(fn(c) { c.length() })
  sizes.sort_by(fn(a, b) { a - b })
  inspect(sizes, content="[1, 1, 1]")
  result.articulation_points.sort_by(fn(a, b) { a - b })
  inspect(result.articulation_points, content="[1]")
}
