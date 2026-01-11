// ============================================================================
// Challenge: Unbounded Knapsack (Complete Knapsack)
// ============================================================================

///|
/// Maximum value with unlimited copies of each item.
#warnings("+missing_invariant+missing_reasoning")
fn knapsack_unbounded(
  weights : ArrayView[Int],
  values : ArrayView[Int],
  capacity : Int,
) -> Int {
  let n = if weights.length() < values.length() {
    weights.length()
  } else {
    values.length()
  }
  let dp : Array[Int] = Array::make(capacity + 1, 0)
  for i = 0; i < n; i = i + 1 {
    let w_i = weights[i]
    let v_i = values[i]
    for w = w_i; w <= capacity; w = w + 1 {
      let cand = dp[w - w_i] + v_i
      if cand > dp[w] {
        dp[w] = cand
      }
    } where {
      invariant: w >= w_i && w <= capacity + 1,
      reasoning: (
        #|INVARIANT (Ascending weight update):
        #|dp[w] reflects the best value using items up to i with unlimited copies.
        #|MAINTENANCE:
        #|Ascending w allows dp[w - w_i] to already include item i, enabling
        #|reuse of the same item multiple times.
        #|TERMINATION:
        #|At w = capacity + 1, all weights for item i are updated.
      ),
    }
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: (
      #|INVARIANT (Items processed):
      #|After items [0..i), dp stores optimal values with unlimited use.
      #|MAINTENANCE:
      #|Each item extends dp by considering repeated uses via ascending weights.
      #|TERMINATION:
      #|At i = n, dp[capacity] is optimal for all items.
    ),
  }
  dp[capacity]
}

///|
test "knapsack_unbounded" {
  let weights : Array[Int] = [2, 3]
  let values : Array[Int] = [4, 5]
  assert_eq(knapsack_unbounded(weights[:], values[:], 7), 13)
  assert_eq(knapsack_unbounded(weights[:], values[:], 1), 0)
}
