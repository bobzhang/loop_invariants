// ============================================================================
// MIN-COST MAX-FLOW - Computation
// ============================================================================
//
// Main algorithm for computing minimum cost maximum flow.
//
// ALGORITHM:
// ```
//   total_flow = 0
//   total_cost = 0
//
//   While SPFA finds path from source to sink:
//     1. Find minimum residual capacity along path
//     2. Augment flow along path by this amount
//     3. Update total_flow and total_cost
//
//   Return (total_flow, total_cost)
// ```
//
// PATH AUGMENTATION:
// ```
//   Given path source -> v1 -> v2 -> ... -> sink:
//
//   1. Find bottleneck: min residual capacity on path
//   2. For each edge (u, v) on path:
//      - Forward edge: flow += bottleneck
//      - Reverse edge: flow -= bottleneck
//   3. Cost increase = bottleneck * dist[sink]
//      (dist[sink] = total cost to push 1 unit to sink)
// ```
//
// CORRECTNESS:
// ```
//   By always augmenting along minimum cost path:
//   - Each unit of flow uses cheapest available route
//   - Total cost is minimum for achieved flow value
// ```

///|
/// Compute min-cost max-flow from source to sink.
///
/// RETURNS: (max_flow, min_cost)
pub fn MinCostMaxFlow::compute(
  self : MinCostMaxFlow,
  source : Int,
  sink : Int,
) -> (Int64, Int64) {
  let mut total_flow = 0L
  let mut total_cost = 0L

  // Main loop: find and augment minimum cost paths
  while self.spfa(source, sink) {
    // Step 1: Find minimum residual capacity along path
    let mut path_flow = MCMF_INF
    let mut v = sink
    while v != source {
      let u = self.prev_v[v]
      let e_idx = self.prev_e[v]
      let residual = self.adj[u][e_idx].cap - self.adj[u][e_idx].flow
      if residual < path_flow {
        path_flow = residual
      }
      v = u
    }

    // Step 2: Augment flow along path
    v = sink
    while v != source {
      let u = self.prev_v[v]
      let e_idx = self.prev_e[v]

      // Update forward edge
      self.adj[u][e_idx].flow = self.adj[u][e_idx].flow + path_flow

      // Update reverse edge (for potential flow cancellation)
      let rev_idx = self.adj[u][e_idx].rev
      self.adj[v][rev_idx].flow = self.adj[v][rev_idx].flow - path_flow
      v = u
    }

    // Step 3: Update totals
    total_flow = total_flow + path_flow
    // dist[sink] is cost per unit of flow to reach sink
    total_cost = total_cost + path_flow * self.dist[sink]
  }
  (total_flow, total_cost)
}

///|
/// Compute min-cost max-flow with a flow limit.
///
/// Stops when either:
///   - Total flow reaches max_flow_limit, OR
///   - No more augmenting paths exist
///
/// RETURNS: (achieved_flow, total_cost)
pub fn MinCostMaxFlow::compute_with_limit(
  self : MinCostMaxFlow,
  source : Int,
  sink : Int,
  max_flow_limit : Int64,
) -> (Int64, Int64) {
  let mut total_flow = 0L
  let mut total_cost = 0L
  while total_flow < max_flow_limit && self.spfa(source, sink) {
    // Limit path flow to not exceed remaining limit
    let mut path_flow = MCMF_INF
    let remaining = max_flow_limit - total_flow
    if remaining < path_flow {
      path_flow = remaining
    }

    // Find bottleneck
    let mut v = sink
    while v != source {
      let u = self.prev_v[v]
      let e_idx = self.prev_e[v]
      let residual = self.adj[u][e_idx].cap - self.adj[u][e_idx].flow
      if residual < path_flow {
        path_flow = residual
      }
      v = u
    }

    // Augment flow
    v = sink
    while v != source {
      let u = self.prev_v[v]
      let e_idx = self.prev_e[v]
      self.adj[u][e_idx].flow = self.adj[u][e_idx].flow + path_flow
      let rev_idx = self.adj[u][e_idx].rev
      self.adj[v][rev_idx].flow = self.adj[v][rev_idx].flow - path_flow
      v = u
    }
    total_flow = total_flow + path_flow
    total_cost = total_cost + path_flow * self.dist[sink]
  }
  (total_flow, total_cost)
}
