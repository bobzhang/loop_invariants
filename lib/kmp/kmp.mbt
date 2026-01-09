// ============================================================================
// KMP ALGORITHM - Knuth-Morris-Pratt Pattern Matching
// ============================================================================
//
// KMP is a linear-time string matching algorithm that never re-examines
// characters in the text, using a "failure function" to skip ahead.
//
// KEY INSIGHT: If we're matching pattern[0..j-1] against text and mismatch at
// pattern[j], we can use previously matched characters to determine the next
// position to try without backtracking in the text.
//
// FAILURE FUNCTION (pi):
// pi[i] = length of longest proper prefix of pattern[0..i] that is also a suffix
//
// EXAMPLE for pattern = "aabaa":
// i:     0  1  2  3  4
// char:  a  a  b  a  a
// pi:    0  1  0  1  2
//
// pi[4] = 2 because "aa" is both prefix and suffix of "aabaa"
//
// WHY IT WORKS:
// If pattern[0..j-1] matches text[i-j..i-1] but pattern[j] != text[i]:
// - We know pattern[0..j-1] = text[i-j..i-1]
// - pi[j-1] tells us the longest prefix of pattern that could still match
// - So we can continue matching from pattern[pi[j-1]] against text[i]
//
// EXAMPLE MATCHING:
// text:    "aabaabaaa"
// pattern: "aabaa"
//
// When we match "aabaa" starting at position 0, then mismatch at 'b' vs 'a':
// - We've matched "aabaa" but next char doesn't match
// - pi[4] = 2, so "aa" is a suffix that's also a prefix
// - We can shift to compare pattern[2] against current text position
//
// ALGORITHM:
// 1. Build failure function in O(m) time
// 2. Match pattern against text in O(n) time
// Total: O(n + m)
//
// INVARIANTS:
// 1. pi[i] < i (proper prefix, so strictly shorter)
// 2. If pi[i] = k > 0, then pattern[0..k-1] = pattern[i-k+1..i]
// 3. pi is the optimal "fallback" - no longer fallback possible
//
// TIME COMPLEXITY: O(n + m)
// SPACE COMPLEXITY: O(m)

///|
/// Compute failure function (prefix function) for a pattern
/// pi[i] = length of longest proper prefix of pattern[0..i] that is also suffix
fn compute_failure(pattern : String) -> Array[Int] {
  let m = pattern.length()
  if m == 0 {
    return []
  }

  let pi = Array::make(m, 0)
  // pi[0] = 0 by definition (no proper prefix)

  // INVARIANT: k = length of current matching prefix
  // pattern[0..k-1] = pattern[i-k..i-1]
  for i = 1, k = 0; i < m; {
    // Try to extend the matching prefix
    // Fall back using failure function until match or k = 0
    let mut curr_k = k
    while curr_k > 0 && pattern[curr_k] != pattern[i] {
      // Mismatch: fall back using failure function
      curr_k = pi[curr_k - 1]
    }

    let next_k = if pattern[curr_k] == pattern[i] {
      curr_k + 1
    } else {
      curr_k
    }

    pi[i] = next_k
    continue i + 1, next_k
  }

  pi
}

///|
/// Find all occurrences of pattern in text using KMP
/// Returns array of starting positions where pattern occurs
fn kmp_search(text : String, pattern : String) -> Array[Int] {
  let result : Array[Int] = []
  let n = text.length()
  let m = pattern.length()

  if m == 0 || m > n {
    return result
  }

  let pi = compute_failure(pattern)

  // INVARIANT: k = number of characters of pattern currently matched
  // text[i-k..i-1] = pattern[0..k-1]
  for i = 0, k = 0; i < n; {
    // Try to extend the match
    let mut curr_k = k
    while curr_k > 0 && pattern[curr_k] != text[i] {
      // Mismatch: use failure function to find next position
      curr_k = pi[curr_k - 1]
    }

    let mut next_k = if pattern[curr_k] == text[i] {
      curr_k + 1
    } else {
      curr_k
    }

    // Check for full match
    if next_k == m {
      result.push(i - m + 1)
      // Continue searching (allow overlapping matches)
      next_k = pi[next_k - 1]
    }

    continue i + 1, next_k
  }

  result
}

///|
/// Count occurrences of pattern in text
fn kmp_count(text : String, pattern : String) -> Int {
  kmp_search(text, pattern).length()
}

///|
/// Check if pattern exists in text
fn kmp_contains(text : String, pattern : String) -> Bool {
  let n = text.length()
  let m = pattern.length()

  if m == 0 {
    return true
  }
  if m > n {
    return false
  }

  let pi = compute_failure(pattern)

  for i = 0, k = 0; i < n; {
    let mut curr_k = k
    while curr_k > 0 && pattern[curr_k] != text[i] {
      curr_k = pi[curr_k - 1]
    }

    let next_k = if pattern[curr_k] == text[i] {
      curr_k + 1
    } else {
      curr_k
    }

    if next_k == m {
      return true
    }

    continue i + 1, next_k
  } else {
    false
  }
}

// ============================================================================
// APPLICATIONS OF FAILURE FUNCTION
// ============================================================================

///|
/// Find all borders (prefix-suffix matches) of a string
/// A border of length k means s[0..k-1] = s[n-k..n-1]
fn find_borders(s : String) -> Array[Int] {
  let n = s.length()
  if n == 0 {
    return []
  }

  let pi = compute_failure(s)
  let borders : Array[Int] = []

  // Follow the chain of failure function from pi[n-1]
  // INVARIANT: Each step gives a valid border
  for k = pi[n - 1]; k > 0; k = pi[k - 1] {
    borders.push(k)
  }

  // Reverse to get borders in increasing order
  let result : Array[Int] = []
  for i = borders.length() - 1; i >= 0; i = i - 1 {
    result.push(borders[i])
  }

  result
}

///|
/// Find the period of a string (length of smallest repeating unit)
fn string_period_kmp(s : String) -> Int {
  let n = s.length()
  if n == 0 {
    return 0
  }

  let pi = compute_failure(s)

  // If n % (n - pi[n-1]) == 0, then n - pi[n-1] is the period
  // REASONING: pi[n-1] is the longest border, so pattern repeats every n - pi[n-1] chars
  let candidate_period = n - pi[n - 1]
  if n % candidate_period == 0 {
    candidate_period
  } else {
    n // No repetition, period is entire string
  }
}

///|
/// Check if string is a repetition of a smaller pattern
fn is_repetition_kmp(s : String) -> Bool {
  let n = s.length()
  if n <= 1 {
    return false
  }
  string_period_kmp(s) < n
}

///|
/// Find longest prefix of s that is also a suffix (excluding s itself)
fn longest_prefix_suffix_kmp(s : String) -> Int {
  let n = s.length()
  if n <= 1 {
    return 0
  }

  let pi = compute_failure(s)
  pi[n - 1]
}

///|
/// Get the minimum string that, when repeated, produces s (or prefix of s)
fn minimum_rotation_factor(s : String) -> String {
  let n = s.length()
  if n == 0 {
    return ""
  }

  let period = string_period_kmp(s)
  (try? s[0:period]).or("").to_string()
}

// ============================================================================
// KMP FOR MULTIPLE PATTERNS (Simple version)
// ============================================================================

///|
/// Find occurrences of any of the patterns in text
/// Returns array of (position, pattern_index) pairs
fn multi_pattern_search(
  text : String,
  patterns : Array[String]
) -> Array[(Int, Int)] {
  let result : Array[(Int, Int)] = []

  // Simple approach: run KMP for each pattern
  // For better performance with many patterns, use Aho-Corasick
  for i = 0; i < patterns.length(); i = i + 1 {
    let matches = kmp_search(text, patterns[i])
    for j = 0; j < matches.length(); j = j + 1 {
      result.push((matches[j], i))
    }
  }

  // Sort by position
  result.sort_by(fn(a, b) {
    let (pos_a, _) = a
    let (pos_b, _) = b
    pos_a - pos_b
  })

  result
}

// ============================================================================
// TESTS
// ============================================================================

///|
test "kmp failure function" {
  let pi = compute_failure("aabaa")

  // a a b a a
  // 0 1 0 1 2
  inspect(pi.length(), content="5")
  inspect(pi[0], content="0")
  inspect(pi[1], content="1")
  inspect(pi[2], content="0")
  inspect(pi[3], content="1")
  inspect(pi[4], content="2")
}

///|
test "kmp failure function abcabc" {
  let pi = compute_failure("abcabc")

  // a b c a b c
  // 0 0 0 1 2 3
  inspect(pi[0], content="0")
  inspect(pi[1], content="0")
  inspect(pi[2], content="0")
  inspect(pi[3], content="1")
  inspect(pi[4], content="2")
  inspect(pi[5], content="3")
}

///|
test "kmp search basic" {
  let matches = kmp_search("aabcaabxaab", "aab")

  inspect(matches.length(), content="3")
  inspect(matches[0], content="0")
  inspect(matches[1], content="4")
  inspect(matches[2], content="8")
}

///|
test "kmp search no match" {
  let matches = kmp_search("abcdef", "xyz")
  inspect(matches.length(), content="0")
}

///|
test "kmp search full match" {
  let matches = kmp_search("abc", "abc")

  inspect(matches.length(), content="1")
  inspect(matches[0], content="0")
}

///|
test "kmp search overlapping" {
  let matches = kmp_search("aaaa", "aa")

  inspect(matches.length(), content="3")
  inspect(matches[0], content="0")
  inspect(matches[1], content="1")
  inspect(matches[2], content="2")
}

///|
test "kmp count" {
  inspect(kmp_count("mississippi", "issi"), content="2")
  inspect(kmp_count("abcabc", "abc"), content="2")
  inspect(kmp_count("hello", "xyz"), content="0")
}

///|
test "kmp contains" {
  inspect(kmp_contains("hello world", "wor"), content="true")
  inspect(kmp_contains("hello world", "xyz"), content="false")
  inspect(kmp_contains("abc", "abc"), content="true")
  inspect(kmp_contains("abc", ""), content="true")
}

///|
test "find borders" {
  // "abcab" has border "ab" of length 2
  let borders = find_borders("abcab")
  inspect(borders.length(), content="1")
  inspect(borders[0], content="2")

  // "aaaa" has borders "a", "aa", "aaa"
  let borders2 = find_borders("aaaa")
  inspect(borders2.length(), content="3")
  inspect(borders2[0], content="1")
  inspect(borders2[1], content="2")
  inspect(borders2[2], content="3")
}

///|
test "string period kmp" {
  inspect(string_period_kmp("abab"), content="2") // "ab" repeats
  inspect(string_period_kmp("abcabc"), content="3") // "abc" repeats
  inspect(string_period_kmp("abcd"), content="4") // no repetition
  inspect(string_period_kmp("aaaa"), content="1") // "a" repeats
}

///|
test "is repetition kmp" {
  inspect(is_repetition_kmp("abab"), content="true")
  inspect(is_repetition_kmp("abcabc"), content="true")
  inspect(is_repetition_kmp("aaaa"), content="true")
  inspect(is_repetition_kmp("abcd"), content="false")
  inspect(is_repetition_kmp("abc"), content="false")
}

///|
test "longest prefix suffix kmp" {
  inspect(longest_prefix_suffix_kmp("abcab"), content="2") // "ab"
  inspect(longest_prefix_suffix_kmp("aaaa"), content="3") // "aaa"
  inspect(longest_prefix_suffix_kmp("abcd"), content="0") // none
}

///|
test "minimum rotation factor" {
  inspect(minimum_rotation_factor("abab"), content="ab")
  inspect(minimum_rotation_factor("aaaa"), content="a")
  inspect(minimum_rotation_factor("abcd"), content="abcd")
}

///|
test "multi pattern search" {
  let text = "aababcabc"
  let patterns : Array[String] = ["ab", "abc"]
  let matches = multi_pattern_search(text, patterns)

  // "ab" at 1, 4, 6; "abc" at 4, 6
  // Sorted by position: (1,0), (4,0), (4,1), (6,0), (6,1)
  inspect(matches.length() >= 5, content="true")
}

///|
test "kmp empty pattern" {
  let matches = kmp_search("abc", "")
  inspect(matches.length(), content="0")
}

///|
test "kmp pattern longer than text" {
  let matches = kmp_search("ab", "abcd")
  inspect(matches.length(), content="0")
}

///|
test "kmp single char" {
  let matches = kmp_search("aaaa", "a")

  inspect(matches.length(), content="4")
  inspect(matches[0], content="0")
  inspect(matches[3], content="3")
}

///|
test "failure function single char" {
  let pi = compute_failure("a")
  inspect(pi.length(), content="1")
  inspect(pi[0], content="0")
}

///|
test "failure function empty" {
  let pi = compute_failure("")
  inspect(pi.length(), content="0")
}

///|
test "find borders empty" {
  let borders = find_borders("")
  inspect(borders.length(), content="0")
}

///|
test "find borders no border" {
  let borders = find_borders("abc")
  inspect(borders.length(), content="0")
}
