// ============================================================================
// 0-1 BFS - Shortest Paths with Edge Weights 0 or 1
// ============================================================================
//
// 0-1 BFS computes single-source shortest paths on graphs whose edge weights
// are only 0 or 1. It replaces Dijkstra's priority queue with a deque:
// - weight 0 edges push the neighbor to the front
// - weight 1 edges push the neighbor to the back
//
// This maintains a nondecreasing distance order in the deque, giving an
// O(V + E) time bound.
//
// TIME COMPLEXITY: O(V + E)
// SPACE COMPLEXITY: O(V + E)

///|
const ZERO_ONE_INF : Int = 1000000000

///|
/// Directed edge with weight 0 or 1.
pub struct Edge {
  to : Int
  weight : Int
} derive(Show)

///|
/// Graph as an adjacency list.
pub struct Graph {
  n : Int
  adj : Array[Array[Edge]]
}

///|
/// Create a graph with n vertices.
pub fn Graph::new(n : Int) -> Graph {
  let adj = Array::make(n, [])
  for i in 0..<n {
    adj[i] = []
  }
  { n, adj }
}

///|
/// Add a directed edge u -> v with weight 0 or 1.
pub fn Graph::add_edge(self : Graph, u : Int, v : Int, weight : Int) -> Unit {
  self.adj[u].push({ to: v, weight })
}

///|
/// Add an undirected edge (u, v) with weight 0 or 1.
pub fn Graph::add_undirected_edge(
  self : Graph,
  u : Int,
  v : Int,
  weight : Int,
) -> Unit {
  self.add_edge(u, v, weight)
  self.add_edge(v, u, weight)
}

///|
/// Compute shortest distances from source using 0-1 BFS.
/// Unreachable vertices keep distance ZERO_ONE_INF.
pub fn zero_one_bfs(graph : Graph, source : Int) -> Array[Int] {
  let n = graph.n
  let dist = Array::make(n, ZERO_ONE_INF)
  if n == 0 {
    return dist
  }
  dist[source] = 0
  let deque : @deque.Deque[Int] = @deque.Deque::new()
  deque.push_front(source)
  for steps = 0; deque.length() > 0; steps = steps + 1 {
    let u = deque.pop_front().unwrap()
    let du = dist[u]
    for e in graph.adj[u] {
      let nd = du + e.weight
      if nd < dist[e.to] {
        dist[e.to] = nd
        if e.weight == 0 {
          deque.push_front(e.to)
        } else {
          deque.push_back(e.to)
        }
      }
    }
  } where {
    invariant: steps >= 0 && dist.length() == n && dist[source] == 0,
    reasoning: (
      #|INVARIANT (0-1 BFS frontier):
      #|The deque stores the current frontier of vertices whose outgoing edges
      #|may still improve distances. Every vertex already popped from the front
      #|has its final shortest distance. Distances of queued vertices are
      #|nondecreasing from front to back.
      #|MAINTENANCE:
      #|Relaxing an edge never increases distances. A weight-0 relaxation keeps
      #|the same distance and pushes to the front; a weight-1 relaxation adds 1
      #|and pushes to the back. Since the front always has the smallest distance,
      #|this preserves the distance order of the deque.
      #|TERMINATION:
      #|When the deque is empty, no edge can relax any distance further, so dist
      #|contains the shortest 0/1 path lengths from source.
    ),
  }
  dist
}
