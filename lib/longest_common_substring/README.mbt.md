# Longest Common Substring (DP)

## Overview

The **longest common substring** problem asks for the longest contiguous string
that appears in both input strings. This implementation uses dynamic
programming with rolling rows to achieve O(n * m) time and O(m) space.

- **Time**: O(n * m)
- **Space**: O(m)

## DP Recurrence

Let `dp[i][j]` be the length of the longest common suffix ending at `a[i-1]`
and `b[j-1]`:

```
if a[i-1] == b[j-1]: dp[i][j] = dp[i-1][j-1] + 1
else:               dp[i][j] = 0
```

The maximum value over all `dp[i][j]` is the answer.

## API

- `longest_common_substring(a, b)` returns `{ substring, length }`.

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

## When To Use

- Comparing two strings for shared patterns.
- Educational settings (clear correctness reasoning).
