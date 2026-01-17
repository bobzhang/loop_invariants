// ============================================================================
// DUVAL'S ALGORITHM - Lyndon Factorization
// ============================================================================
//
// Duval's algorithm factors a string into a sequence of Lyndon words such that
// the sequence is non-increasing in lexicographic order. The factorization is
// unique and can be found in linear time.
//
// KEY IDEA:
// - Scan with indices (i, j, k) to find the minimal rotation period.
// - Emit repeated factors of length (j - k) while i <= k.
//
// TIME COMPLEXITY: O(n)
// SPACE COMPLEXITY: O(n)

///|
fn slice_string(s : String, start : Int, end : Int) -> String {
  let sb = StringBuilder::new()
  for idx in start..<end {
    let ch = s[idx].to_int()
    sb.write_char(ch.unsafe_to_char())
  }
  sb.to_string()
}

///|
/// Compute Lyndon factorization using Duval's algorithm.
/// Returns factors as strings in non-increasing lexicographic order.
pub fn duval_factorization(s : String) -> Array[String] {
  let n = s.length()
  let factors : Array[String] = []
  let mut i = 0
  while i < n {
    let mut j = i + 1
    let mut k = i
    while j < n && s[k] <= s[j] {
      if s[k] < s[j] {
        k = i
      } else {
        k = k + 1
      }
      j = j + 1
    }
    let period = j - k
    while i <= k {
      factors.push(slice_string(s, i, i + period))
      i = i + period
    }
  }
  factors
}

// ============================================================================
// TESTS
// ============================================================================

///|
test "duval banana" {
  let factors = duval_factorization("banana")
  inspect(factors, content="[\"b\", \"an\", \"an\", \"a\"]")
}

///|
test "duval ababab" {
  let factors = duval_factorization("ababab")
  inspect(factors, content="[\"ab\", \"ab\", \"ab\"]")
}
