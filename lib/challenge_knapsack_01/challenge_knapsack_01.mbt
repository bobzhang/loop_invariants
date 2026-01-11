// ============================================================================
// Challenge: 0/1 Knapsack (One-Dimensional DP)
// ============================================================================

///|
/// Maximum value with weight limit using each item at most once.
#warnings("+missing_invariant+missing_reasoning")
fn knapsack_01(
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
    for w = capacity; w >= w_i; w = w - 1 {
      let cand = dp[w - w_i] + v_i
      if cand > dp[w] {
        dp[w] = cand
      }
    } where {
      invariant: w >= -1 && w <= capacity,
      reasoning: (
        #|INVARIANT (Descending weight update):
        #|For all weights > w, dp already includes item i at most once.
        #|MAINTENANCE:
        #|Using descending w ensures dp[w - w_i] still refers to the previous
        #|item set (0/1), so adding v_i doesn't reuse item i.
        #|TERMINATION:
        #|When w < w_i, all feasible weights for item i are processed.
      ),
    }
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: (
      #|INVARIANT (Items processed):
      #|After processing items [0..i), dp[w] is the best value with weight ≤ w.
      #|MAINTENANCE:
      #|The inner loop incorporates item i exactly once into dp.
      #|TERMINATION:
      #|At i = n, dp[capacity] is the optimal value.
    ),
  }
  dp[capacity]
}

///|
test "knapsack_01" {
  let weights : Array[Int] = [2, 3, 4]
  let values : Array[Int] = [4, 5, 6]
  assert_eq(knapsack_01(weights[:], values[:], 5), 9)
  assert_eq(knapsack_01(weights[:], values[:], 3), 5)
}
