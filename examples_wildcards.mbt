// ============================================================================
// Example E: Parentheses with Wildcards ("*" can be "(", ")", or empty)
// ============================================================================

///|
fn clamp_nonneg(x : Int) -> Int {
  if x < 0 {
    0
  } else {
    x
  }
}

///|
/// Unclamped min/max balance for chars[0..end).
/// "(" adds 1, ")" subtracts 1, "*" can do both.
fn range_prefix(chars : ArrayView[Char], end : Int) -> (Int, Int) {
  if end <= 0 {
    (0, 0)
  } else {
    let (lo, hi) = range_prefix(chars, end - 1)
    let c = chars[end - 1]
    if c == '(' {
      (lo + 1, hi + 1)
    } else if c == ')' {
      (lo - 1, hi - 1)
    } else if c == '*' {
      (lo - 1, hi + 1)
    } else {
      (lo, hi)
    }
  }
}

///|
/// Check if there exists an assignment of '*' that makes the string balanced.
#warnings("+missing_invariant+missing_reasoning")
fn is_balanced_parens_star(chars : ArrayView[Char]) -> Bool {
  for i = 0, low = 0, high = 0 {
    if i >= chars.length() {
      break low == 0
    } else {
      let c = chars[i]
      let next_low = if c == '(' {
        low + 1
      } else if c == ')' {
        low - 1
      } else if c == '*' {
        low - 1
      } else {
        low
      }
      let next_high = if c == '(' {
        high + 1
      } else if c == ')' {
        high - 1
      } else if c == '*' {
        high + 1
      } else {
        high
      }
      if next_high < 0 {
        break false
      } else {
        let clamped_low = clamp_nonneg(next_low)
        continue i + 1, clamped_low, next_high
      }
    }
  } where {
    invariant: 0 <= i && i <= chars.length(),
    reasoning: (
      #|i is the length of the processed prefix.
    ),
    invariant: high == range_prefix(chars, i).1,
    reasoning: (
      #|high tracks the maximum possible balance after i chars.
      #|Each character shifts the whole range by +1, -1, or expands by 1.
    ),
    invariant: low == clamp_nonneg(range_prefix(chars, i).0),
    reasoning: (
      #|low tracks the minimum *valid* balance after i chars.
      #|We clamp negatives to 0 because any negative balance is invalid
      #|and cannot be extended to a valid full string.
    ),
    invariant: low <= high,
    reasoning: (
      #|Possible balances for a prefix always form a contiguous interval.
      #|If high < 0 then the interval is entirely negative → impossible.
    ),
  }
}

///|
test "is_balanced_parens_star" {
  let empty : Array[Char] = []
  assert_true(is_balanced_parens_star(empty[:]))
  assert_true(is_balanced_parens_star(['(', ')'][:]))
  assert_true(is_balanced_parens_star(['(', '*', ')'][:]))
  assert_true(is_balanced_parens_star(['(', '*', ')', ')'][:])) // * = '('
  assert_true(is_balanced_parens_star(['(', '*', '(', ')'][:])) // * = ')'
  assert_true(is_balanced_parens_star(['*'][:])) // * = empty
  assert_true(not(is_balanced_parens_star([')', '*', '('][:])))
  assert_true(not(is_balanced_parens_star(['(', ')', ')', '*'][:])))
  assert_true(not(is_balanced_parens_star(['(', '(', '*'][:])))
}
