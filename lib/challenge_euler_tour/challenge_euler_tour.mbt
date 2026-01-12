// ============================================================================
// Challenge: Euler Tour (Entry/Exit Times)
// ============================================================================

///|
fn build_adj(n : Int, edges : ArrayView[(Int, Int)]) -> Array[Array[Int]] {
  let adj = Array::makei(n, fn(_) { [] })
  for i = 0; i < edges.length(); i = i + 1 {
    let (u, v) = edges[i]
    adj[u].push(v)
    adj[v].push(u)
  } where {
    invariant: i >= 0 && i <= edges.length(),
    reasoning: (
      #|INVARIANT (adjacency build):
      #|All edges in edges[0..i) are added to adj.
      #|MAINTENANCE:
      #|Insert both directions for the next edge.
      #|TERMINATION:
      #|At i = edges.length(), the adjacency list is complete.
    ),
  }
  adj
}

///|
/// Compute Euler tour entry/exit times and visitation order.
#warnings("+missing_invariant+missing_reasoning")
pub fn euler_tour(
  n : Int,
  edges : ArrayView[(Int, Int)],
  root : Int,
) -> (Array[Int], Array[Int], Array[Int]) {
  let adj = build_adj(n, edges)
  let tin = Array::make(n, -1)
  let tout = Array::make(n, -1)
  let order : Array[Int] = []
  let stack : Array[(Int, Int, Int)] = [] // (node, parent, state)
  stack.push((root, -1, 0))
  let _ = for time = 0 {
    if stack.length() == 0 {
      break time
    }
    let (u, p, state) = stack.pop().unwrap()
    if state == 0 {
      tin[u] = time
      order.push(u)
      stack.push((u, p, 1))
      for v in adj[u] {
        if v != p {
          stack.push((v, u, 0))
        }
      }
      continue time + 1
    } else {
      tout[u] = time
      continue time
    }
  } where {
    invariant: time >= 0 && time <= n && order.length() == time,
    reasoning: (
      #|INVARIANT (Euler stack):
      #|time equals the number of entered nodes so far, and order lists them in
      #|entry order. The stack holds pending enter/exit actions.
      #|MAINTENANCE:
      #|On entry, record tin and push exit plus children. On exit, set tout.
      #|TERMINATION:
      #|When the stack is empty, all nodes have entry/exit times.
    ),
  }
  (tin, tout, order)
}

///|
test "euler_tour_basic" {
  let edges : Array[(Int, Int)] = [(0, 1), (0, 2), (1, 3), (1, 4)]
  let (tin, tout, order) = euler_tour(5, edges[:], 0)
  assert_eq(order.length(), 5)
  assert_eq(tin[0], 0)
  assert_eq(tout[0] > tin[0], true)
}
