// ============================================================================
// Challenge: Sliding Window Minimum
// ============================================================================

///|
/// Return minimum for each window of size k.
#warnings("+missing_invariant+missing_reasoning")
pub fn sliding_window_min(arr : ArrayView[Int], k : Int) -> Array[Int] {
  let n = arr.length()
  guard n >= k && k > 0 else { return [] }
  let result : Array[Int] = []
  let deque : Array[Int] = []
  for i = 0 {
    if i >= n {
      break result
    } else {
      while deque.length() > 0 && deque[0] <= i - k {
        let _ = deque.remove(0)

      }
      while deque.length() > 0 && arr[deque[deque.length() - 1]] >= arr[i] {
        let _ = deque.pop()

      }
      deque.push(i)
      if i >= k - 1 {
        result.push(arr[deque[0]])
      }
      continue i + 1
    }
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: (
      #|INVARIANT (Monotone deque):
      #|Deque indices are increasing and values are increasing, so the front
      #|holds the minimum of the current window.
      #|MAINTENANCE:
      #|Remove expired indices, drop larger values from the back, then push i.
      #|TERMINATION:
      #|At i = n, all window minimums are collected.
    ),
  }
}

///|
test "sliding_window_min" {
  let arr : Array[Int] = [4, 2, 12, 3, 5, 1]
  assert_eq(sliding_window_min(arr[:], 3), [2, 2, 3, 1])
}
