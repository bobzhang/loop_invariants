# Longest Common Substring (DP)

## Overview

The **Longest Common Substring** problem finds the longest contiguous sequence
of characters that appears in both input strings. This implementation uses
dynamic programming with space optimization.

- **Time**: O(n × m)
- **Space**: O(m) with rolling array optimization
- **Output**: The actual substring and its length

## The Key Insight

```
Problem: Find the longest contiguous match between two strings

Longest Common Subsequence: Characters don't need to be adjacent
Longest Common Substring: Characters MUST be adjacent (contiguous)

Example:
  a = "abcdef"
  b = "zbcdf"

  LCS (subsequence): "bcdf" (length 4)
  LCS (substring):   "bcd"  (length 3)

The key: When characters match, extend the match.
         When they don't, reset to 0 (not skip like LCS).
```

## Understanding the DP Recurrence

```
Let dp[i][j] = length of longest common suffix ending at a[i-1] and b[j-1]

if a[i-1] == b[j-1]:
  dp[i][j] = dp[i-1][j-1] + 1   // extend the match
else:
  dp[i][j] = 0                   // no common suffix here

The answer is the maximum value in the entire DP table.
```

## Visual: DP Table Construction

```
a = "abab"
b = "baba"

DP table (dp[i][j] = common suffix length ending at a[i-1], b[j-1]):

        ""   b   a   b   a
    ""   0   0   0   0   0
     a   0   0   1   0   1
     b   0   1   0   2   0
     a   0   0   2   0   3  ← maximum!
     b   0   1   0   3   0

Maximum = 3, ending at a[3], b[4]
Substring = "aba" (positions 1-3 in a, positions 2-4 in b)
```

## Algorithm Walkthrough

```
a = "banana"
b = "ananas"

Building the DP table row by row:

Row for a[0] = 'b':
  b[0]='a': 'b'≠'a' → 0
  b[1]='n': 'b'≠'n' → 0
  ... all zeros

Row for a[1] = 'a':
  b[0]='a': 'a'='a' → dp[0][0]+1 = 1
  b[1]='n': 'a'≠'n' → 0
  b[2]='a': 'a'='a' → dp[0][1]+1 = 1
  ...

Row for a[2] = 'n':
  b[0]='a': 'n'≠'a' → 0
  b[1]='n': 'n'='n' → dp[1][0]+1 = 2  (extends "a" to "an")
  ...

Continue until max = 5 is found ("anana")
```

## Why O(m) Space?

```
Standard DP uses O(n × m) space for the full table.

Observation: dp[i][j] only depends on dp[i-1][j-1]

We only need the previous row!

Rolling array technique:
  prev_row = [0] * (m+1)
  curr_row = [0] * (m+1)

  for i in 1..n:
    for j in 1..m:
      if a[i-1] == b[j-1]:
        curr_row[j] = prev_row[j-1] + 1
      else:
        curr_row[j] = 0
    swap(prev_row, curr_row)

Space: O(m) instead of O(n × m)!
```

## Example Usage

```mbt check
///|
test "lcs banana ananas" {
  let result = @longest_common_substring.longest_common_substring(
    "banana", "ananas",
  )
  inspect(result.substring, content="anana")
  inspect(result.length, content="5")
}
```

## More Examples

```mbt check
///|
test "lcs no common substring" {
  let result = @longest_common_substring.longest_common_substring("abc", "xyz")
  inspect(result.substring, content="")
  inspect(result.length, content="0")
}
```

```mbt check
///|
test "lcs identical strings" {
  let result = @longest_common_substring.longest_common_substring(
    "hello", "hello",
  )
  inspect(result.substring, content="hello")
  inspect(result.length, content="5")
}
```

## Common Applications

### 1. Plagiarism Detection
```
Find the longest copied passage between two documents.
Long common substrings suggest copying.
```

### 2. DNA Sequence Analysis
```
Find common gene sequences between organisms.
Long matches indicate evolutionary relationships.
```

### 3. File Diff
```
Find unchanged sections between file versions.
Common substrings don't need to be shown as changes.
```

### 4. Autocomplete
```
Find the best partial match for user input.
Longest substring match often indicates intent.
```

## Complexity Analysis

| Operation | Time |
|-----------|------|
| Find LCS | O(n × m) |
| Space (optimized) | O(m) |
| Space (full table) | O(n × m) |

## LCS Substring vs Other String Algorithms

| Algorithm | Problem | Time |
|-----------|---------|------|
| **LCS Substring (DP)** | Longest contiguous match | O(nm) |
| LCS Subsequence | Longest (not contiguous) match | O(nm) |
| Suffix Array + LCP | Longest repeated substring | O(n log n) |
| Rolling Hash | Pattern matching | O(n + m) |

**Choose LCS Substring when**: You need the actual longest contiguous match,
not just its length.

## Implementation Notes

- Uses rolling row optimization for O(m) space
- Track position of maximum to reconstruct the substring
- Handle edge cases: empty strings, no match
- Can be parallelized row-by-row
- For very long strings, consider suffix array approach

## Recovering the Substring

```
While computing max, track:
  - max_len: maximum dp value seen
  - end_pos: position in string a where max_len ends

After DP completes:
  substring = a[end_pos - max_len : end_pos]

Example:
  a = "banana", max_len = 5, end_pos = 6
  substring = a[1:6] = "anana"
```

