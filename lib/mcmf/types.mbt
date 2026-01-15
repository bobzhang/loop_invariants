// ============================================================================
// MIN-COST MAX-FLOW - Type Definitions
// ============================================================================
//
// Find maximum flow with minimum total cost. Each edge has both capacity
// and cost per unit of flow.
//
// PROBLEM FORMULATION:
// ```
//   Given: Directed graph G = (V, E)
//          Edge capacities c(u, v)
//          Edge costs w(u, v)
//          Source s and sink t
//
//   Find: Flow f that maximizes total flow from s to t
//         while minimizing total cost Σ f(u,v) * w(u,v)
// ```
//
// ALGORITHM (SPFA-based):
// ```
//   1. Find shortest path (by cost) from source to sink using SPFA
//   2. Augment flow along this path
//   3. Repeat until no augmenting path exists
//
//   By always choosing the minimum cost path, we ensure that for any
//   given flow value, we achieve minimum cost.
// ```
//
// RESIDUAL GRAPH WITH COSTS:
// ```
//   For edge (u, v) with capacity c, flow f, cost w:
//
//   Forward edge:  residual = c - f, cost = +w
//   Backward edge: residual = f,     cost = -w
//
//   The negative cost on backward edges is crucial!
//   It allows us to "cancel" flow and get cost refund.
//
//   Example: If we pushed 1 unit through (u,v) at cost 5,
//   we can later push 1 unit backward at cost -5 to cancel.
// ```
//
// WHY MINIMUM COST PATH:
// ```
//   Claim: If we always augment along minimum cost path,
//          we get minimum cost for any flow value.
//
//   Proof sketch:
//   - Each augmentation increases flow by some amount
//   - If there were a cheaper way to achieve current flow,
//     we could have found it via negative cost cycles
//   - SPFA with negative edges finds true shortest paths
//     (no negative cycles in residual graph if no initial ones)
// ```
//
// APPLICATIONS:
//   - Assignment problem (bipartite matching with costs)
//   - Transportation problem
//   - Job scheduling with costs
//   - Network design optimization

///|
/// Infinity constant for MCMF algorithm.
pub const MCMF_INF : Int64 = 4611686018427387903L

///|
/// Edge in the min-cost max-flow network.
///
/// STRUCTURE:
/// ```
///   to:   Destination vertex
///   cap:  Edge capacity
///   cost: Cost per unit of flow
///   flow: Current flow on edge
///   rev:  Index of reverse edge in adj[to]
///
///   Residual capacity = cap - flow
///   Cost for pushing flow = cost * flow_amount
/// ```
pub(all) struct MCMFEdge {
  to : Int
  cap : Int64
  cost : Int64
  mut flow : Int64
  rev : Int // Index of reverse edge in adj[to]
}

///|
/// Min-Cost Max-Flow data structure.
///
/// COMPONENTS:
/// ```
///   n:        Number of vertices
///   adj:      Adjacency list of edges
///   dist:     Shortest path distance (by cost) from source
///   prev_v:   Previous vertex on shortest path
///   prev_e:   Edge index used to reach each vertex
///   in_queue: Whether vertex is currently in SPFA queue
/// ```
pub(all) struct MinCostMaxFlow {
  n : Int
  adj : Array[Array[MCMFEdge]]
  dist : Array[Int64]
  prev_v : Array[Int]
  prev_e : Array[Int]
  in_queue : Array[Bool]
}

///|
/// Create a new MinCostMaxFlow instance with n vertices.
pub fn MinCostMaxFlow::new(n : Int) -> MinCostMaxFlow {
  let adj : Array[Array[MCMFEdge]] = Array::makei(n, _ => [])
  {
    n,
    adj,
    dist: Array::make(n, 0L),
    prev_v: Array::make(n, -1),
    prev_e: Array::make(n, -1),
    in_queue: Array::make(n, false),
  }
}

///|
/// Add edge from u to v with capacity cap and cost per unit flow.
///
/// IMPLEMENTATION:
/// ```
///   1. Add forward edge: (v, cap, cost, 0, rev_index)
///   2. Add backward edge: (u, 0, -cost, 0, forward_index)
///
///   The backward edge has:
///   - Capacity 0 (no flow can be pushed initially)
///   - Negative cost (refund when canceling flow)
/// ```
pub fn MinCostMaxFlow::add_edge(
  self : MinCostMaxFlow,
  u : Int,
  v : Int,
  cap : Int64,
  cost : Int64,
) -> Unit {
  let rev_u = self.adj[v].length()
  let rev_v = self.adj[u].length()
  self.adj[u].push({ to: v, cap, cost, flow: 0L, rev: rev_u })
  self.adj[v].push({ to: u, cap: 0L, cost: -cost, flow: 0L, rev: rev_v })
}
