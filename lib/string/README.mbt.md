# String Algorithms (Palindrome + LCS)

This package exposes two classic string routines:

1. **Longest palindromic substring range**
2. **Longest common subsequence length**

Both operate on `Array[Char]` inputs.

---

## 1. Longest palindromic substring range

**What it returns**

`longest_palindrome_range(s)` returns `(start, len)` where:

- `start` is the starting index of the longest palindrome
- `len` is its length

Example string:

```
s = "abcbd"
index: 0 1 2 3 4
chars: a b c b d

Longest palindrome is "bcb" (indices 1..3)
```

So the result is `(1, 3)`.

The implementation uses **Manacher's algorithm**, which finds the longest
palindrome in **O(n)** time.

### Visual intuition (expand around centers)

Manacher treats palindromes as expanding around a center:

```
odd-length center at index 2:
  a b c b d
      ^
  expand: c
  expand: b c b
  stop (a != d)

even-length center between 1 and 2:
  a b | c b d
      ^
  expand: (no match)
```

Manacher does this efficiently by reusing previous expansions.

---

### Example usage

```mbt check
///|
test "longest palindrome range" {
  let s1 : Array[Char] = ['a', 'b', 'a', 'c', 'a', 'b', 'a']
  inspect(@string.longest_palindrome_range(s1[:]), content="(0, 7)")
  let s2 : Array[Char] = ['a', 'b', 'b', 'a']
  inspect(@string.longest_palindrome_range(s2[:]), content="(0, 4)")
  let s3 : Array[Char] = ['a', 'b', 'c', 'b', 'd']
  inspect(@string.longest_palindrome_range(s3[:]), content="(1, 3)")
}
```

---

## 2. Longest common subsequence (LCS) length

The **LCS** is the longest sequence that appears in both strings **in order**,
but not necessarily contiguously.

Example:

```
s1 = "ABCDEF"
s2 = "ACBCF"

One LCS is "ABCF" (length 4)
```

The algorithm uses DP with a recurrence:

```
if s1[i-1] == s2[j-1]:
  dp[i][j] = dp[i-1][j-1] + 1
else:
  dp[i][j] = max(dp[i-1][j], dp[i][j-1])
```

---

### Example usage

```mbt check
///|
test "lcs length" {
  let s1 : Array[Char] = ['A', 'B', 'C', 'D', 'E', 'F']
  let s2 : Array[Char] = ['A', 'C', 'B', 'C', 'F']
  inspect(@string.lcs_length(s1[:], s2[:]), content="4")
  let s3 : Array[Char] = ['A', 'B', 'C']
  let s4 : Array[Char] = ['D', 'E', 'F']
  inspect(@string.lcs_length(s3[:], s4[:]), content="0")
}
```

---

## 3. Visual intuition (LCS table)

For `s1 = "ABC"` and `s2 = "AC"`:

```
      ""  A  C
  ""   0  0  0
  A    0  1  1
  B    0  1  1
  C    0  1  2
```

The final cell is the LCS length.

### Traceback idea (how to recover the sequence)

If you also want the **actual subsequence**, you can trace back:

```
if chars match: move diagonally (take char)
else move to the larger neighbor (up or left)
```

This package only returns the length, but the DP table shows how to recover
the sequence if needed.

---

## 4. Complexity

```
Longest palindrome (Manacher): O(n)
LCS length (DP):              O(n*m)
```

---

## 5. Typical applications

1. **Palindrome detection** (DNA motifs, text cleaning)
2. **Diff tools** (LCS for file comparison)
3. **Bioinformatics** (sequence alignment)

---

## 6. Summary

This package gives you two foundational string tools:

- fast longest‑palindrome range,
- classic LCS length DP.

They are great building blocks for text and sequence problems.
