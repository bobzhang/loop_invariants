// ============================================================================
// Challenge: Edit Distance (Levenshtein)
// ============================================================================

///|
fn min3(a : Int, b : Int, c : Int) -> Int {
  if a <= b && a <= c {
    a
  } else if b <= c {
    b
  } else {
    c
  }
}

///|
/// Compute edit distance using full DP table.
#warnings("+missing_invariant+missing_reasoning")
pub fn edit_distance(s1 : ArrayView[Char], s2 : ArrayView[Char]) -> Int {
  let m = s1.length()
  let n = s2.length()
  let dp : Array[Int] = Array::make((m + 1) * (n + 1), 0)
  for i in 0..=m {
    dp[i * (n + 1)] = i
  }
  for j in 0..=n {
    dp[j] = j
  }
  for i = 1; i <= m; i = i + 1 {
    for j = 1; j <= n; j = j + 1 {
      let idx = i * (n + 1) + j
      if s1[i - 1] == s2[j - 1] {
        dp[idx] = dp[(i - 1) * (n + 1) + (j - 1)]
      } else {
        dp[idx] = 1 +
          min3(
            dp[(i - 1) * (n + 1) + j],
            dp[i * (n + 1) + (j - 1)],
            dp[(i - 1) * (n + 1) + (j - 1)],
          )
      }
    } where {
      invariant: j >= 1 && j <= n + 1,
      reasoning: (
        #|INVARIANT (Row fill):
        #|dp[i,j] is computed for all columns < j in the current row.
        #|MAINTENANCE:
        #|Use the standard recurrence to fill dp[i,j], then advance j.
        #|TERMINATION:
        #|At j = n + 1, row i is complete.
      ),
    }
  } where {
    invariant: i >= 1 && i <= m + 1,
    reasoning: (
      #|INVARIANT (Rows complete):
      #|All rows < i are fully computed.
      #|MAINTENANCE:
      #|Fill row i from left to right, then move to i+1.
      #|TERMINATION:
      #|At i = m + 1, dp[m,n] is the edit distance.
    ),
  }
  dp[m * (n + 1) + n]
}

///|
test "edit_distance" {
  let s1 : Array[Char] = ['k', 'i', 't', 't', 'e', 'n']
  let s2 : Array[Char] = ['s', 'i', 't', 't', 'i', 'n', 'g']
  assert_eq(edit_distance(s1[:], s2[:]), 3)
  assert_eq(edit_distance(['a', 'b'][:], ['a', 'c'][:]), 1)
}
