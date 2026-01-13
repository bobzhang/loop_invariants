# Floor Sum

## Overview

Compute the sum:

```
S = sum_{i=0}^{n-1} floor((a*i + b) / m)
```

This uses the classic Euclidean reduction from AtCoder Library.

- **Time**: O(log m + log a)
- **Space**: O(1)

## Quick Start

```mbt check
///|
test "floor sum quick start" {
  inspect(@floor_sum.floor_sum(4L, 5L, 3L, 2L), content="4")
  inspect(@floor_sum.floor_sum(5L, 4L, 2L, 1L), content="4")
}
```

## How the Reduction Works (Intuition)

Two observations let us reduce the parameters:

1. If `a >= m`, then `floor((a*i + b)/m)` contributes `floor(a/m) * i` plus a
   smaller term with `a % m`.
2. If `b >= m`, then every term contributes `floor(b/m)` plus a smaller term
   with `b % m`.

After extracting those contributions, we swap roles of `(a, m)` using the
Euclidean step to shrink the modulus.

## More Example

```mbt check
///|
test "floor sum with reductions" {
  inspect(@floor_sum.floor_sum(5L, 4L, 6L, 7L), content="21")
}
```

## Notes

- All parameters are treated as non-negative in this implementation.
- For `n <= 0` or `m <= 0`, the sum is `0`.
