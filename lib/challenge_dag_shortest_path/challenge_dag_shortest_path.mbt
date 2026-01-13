// ============================================================================
// Challenge: DAG Shortest Paths (Topological DP)
// ============================================================================

///|
const INF : Int = 0x3fffffff

///|
/// Return shortest paths in a DAG, or None if a cycle exists.
#warnings("+missing_invariant+missing_reasoning")
pub fn dag_shortest_paths(
  n : Int,
  edges : ArrayView[(Int, Int, Int)],
  src : Int,
) -> Array[Int]? {
  let adj : Array[Array[(Int, Int)]] = Array::makei(n, _ => [])
  let indeg : Array[Int] = Array::make(n, 0)
  let m = edges.length()
  for i = 0; i < m; i = i + 1 {
    let (u, v, w) = edges[i]
    if u >= 0 && u < n && v >= 0 && v < n {
      adj[u].push((v, w))
      indeg[v] = indeg[v] + 1
    }
  } where {
    invariant: i >= 0 && i <= m,
    reasoning: (
      #|INVARIANT (Build DAG):
      #|adj/indeg reflect all edges in edges[0..i).
      #|MAINTENANCE:
      #|Insert edge (u -> v) with weight w and increment indegree.
      #|TERMINATION:
      #|At i = m, the DAG representation is complete.
    ),
  }
  let queue : Array[Int] = []
  for i = 0; i < n; i = i + 1 {
    if indeg[i] == 0 {
      queue.push(i)
    }
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: (
      #|INVARIANT (Queue init):
      #|queue holds all zero-indegree nodes in [0..i).
      #|MAINTENANCE:
      #|Append i when it has indegree 0.
      #|TERMINATION:
      #|At i = n, queue is initialized.
    ),
  }
  let order : Array[Int] = []
  for head = 0; head < queue.length(); head = head + 1 {
    let u = queue[head]
    order.push(u)
    let neighbors = adj[u]
    for j = 0; j < neighbors.length(); j = j + 1 {
      let (v, _w) = neighbors[j]
      indeg[v] = indeg[v] - 1
      if indeg[v] == 0 {
        queue.push(v)
      }
    } where {
      invariant: j >= 0 && j <= neighbors.length(),
      reasoning: (
        #|INVARIANT (Topo relax):
        #|All neighbors[0..j) have been removed from the indegree counts.
        #|MAINTENANCE:
        #|Decrease indegree and enqueue when it becomes zero.
        #|TERMINATION:
        #|At j = deg(u), all outgoing edges of u are processed.
      ),
    }
  } where {
    invariant: head >= 0 && head <= queue.length(),
    reasoning: (
      #|INVARIANT (Topo order):
      #|order is a valid topological prefix of processed nodes.
      #|MAINTENANCE:
      #|Processing u reveals new zero-indegree nodes.
      #|TERMINATION:
      #|When head reaches queue length, all reachable nodes are processed.
    ),
  }
  if order.length() != n {
    return None
  }
  let dist = Array::make(n, INF)
  if src >= 0 && src < n {
    dist[src] = 0
  }
  for k = 0; k < n; k = k + 1 {
    let u = order[k]
    if dist[u] != INF {
      let neighbors = adj[u]
      for j = 0; j < neighbors.length(); j = j + 1 {
        let (v, w) = neighbors[j]
        let cand = dist[u] + w
        if cand < dist[v] {
          dist[v] = cand
        }
      } where {
        invariant: j >= 0 && j <= neighbors.length(),
        reasoning: (
          #|INVARIANT (DAG relax):
          #|All neighbors[0..j) have been relaxed from u.
          #|MAINTENANCE:
          #|Update dist[v] using edge (u -> v) when a shorter path is found.
          #|TERMINATION:
          #|At j = deg(u), all outgoing edges from u are processed.
        ),
      }
    }
  } where {
    invariant: k >= 0 && k <= n,
    reasoning: (
      #|INVARIANT (Topo DP):
      #|All nodes in order[0..k) have final shortest distances.
      #|MAINTENANCE:
      #|Relax edges in topological order, preserving correctness.
      #|TERMINATION:
      #|At k = n, all distances are finalized.
    ),
  }
  Some(dist)
}
