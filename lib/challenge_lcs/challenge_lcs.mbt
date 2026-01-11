// ============================================================================
// Challenge: Longest Common Subsequence Length
// ============================================================================

///|
fn max(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Compute LCS length using two-row DP.
#warnings("+missing_invariant+missing_reasoning")
fn lcs_length(a : ArrayView[Char], b : ArrayView[Char]) -> Int {
  let m = a.length()
  let n = b.length()
  if m == 0 || n == 0 {
    return 0
  }
  let mut prev : Array[Int] = Array::make(n + 1, 0)
  let mut curr : Array[Int] = Array::make(n + 1, 0)
  for i = 1 {
    if i > m {
      break prev[n]
    } else {
      for j = 1 {
        if j > n {
          break
        } else if a[i - 1] == b[j - 1] {
          curr[j] = prev[j - 1] + 1
          continue j + 1
        } else {
          curr[j] = max(prev[j], curr[j - 1])
          continue j + 1
        }
      } where {
        invariant: j >= 1 && j <= n + 1,
        reasoning: (
          #|INVARIANT (Row DP):
          #|curr[t] equals LCS length of a[0..i) and b[0..t) for t < j.
          #|MAINTENANCE:
          #|Update curr[j] from neighbors and advance j.
          #|TERMINATION:
          #|At j = n + 1, row i is complete.
        ),
      }
      let tmp = prev
      prev = curr
      curr = tmp
      continue i + 1
    }
  } where {
    invariant: i >= 1 && i <= m + 1,
    reasoning: (
      #|INVARIANT (Rows):
      #|prev stores LCS lengths for a[0..i) against all prefixes of b.
      #|MAINTENANCE:
      #|After filling curr, swap so prev becomes the finished row.
      #|TERMINATION:
      #|At i = m + 1, prev[n] is the full LCS length.
    ),
  }
}

///|
test "lcs_length" {
  let a : Array[Char] = ['A', 'B', 'C', 'B', 'D', 'A', 'B']
  let b : Array[Char] = ['B', 'D', 'C', 'A', 'B', 'A']
  assert_eq(lcs_length(a[:], b[:]), 4)
  assert_eq(lcs_length(['A', 'B', 'C'][:], ['A', 'B', 'C'][:]), 3)
}
