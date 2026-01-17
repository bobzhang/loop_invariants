# Floor Sum

## Overview

Compute the sum of floor values:

```
S = Σ_{i=0}^{n-1} floor((a·i + b) / m)
```

This uses an elegant Euclidean-style reduction that runs in O(log m) time.

- **Time**: O(log m + log a)
- **Space**: O(1)
- **Key Feature**: Counts lattice points under a line

## The Key Insight

```
Problem: Sum floor((a·i + b) / m) for i = 0, 1, ..., n-1

Naive: O(n) - compute each term

Euclidean insight:
  The sum counts lattice points (i, j) where:
    0 ≤ i < n
    0 ≤ j ≤ floor((a·i + b) / m)

  This is the area under a line! We can use coordinate transforms
  similar to the Euclidean algorithm to reduce (a, m) → smaller values.

Key reductions:
  1. If a ≥ m: Extract floor(a/m)·i contribution, reduce a to a % m
  2. If b ≥ m: Extract floor(b/m) from each term, reduce b to b % m
  3. Swap coordinates: Transform problem with smaller parameters

Result: O(log m) iterations like GCD computation!
```

## Visual: Counting Lattice Points

```
Example: n=5, m=3, a=2, b=1
S = Σ floor((2·i + 1) / 3), i = 0..4

Line: y = (2x + 1) / 3

    y
    3 |       ●───────
    2 |     ●─────●
    1 |   ●───●
    0 ● ●───●
      └─●─●─●─●─●─► x
        0 1 2 3 4

Table:
  i=0: floor(1/3) = 0
  i=1: floor(3/3) = 1
  i=2: floor(5/3) = 1
  i=3: floor(7/3) = 2
  i=4: floor(9/3) = 3

Sum = 0 + 1 + 1 + 2 + 3 = 7
```

## Algorithm

```
floor_sum(n, m, a, b):
  if n == 0: return 0
  result = 0

  // Reduction 1: Handle a ≥ m
  if a >= m:
    // floor((a·i + b)/m) = floor(a/m)·i + floor((a%m·i + b)/m)
    result += (a / m) * n * (n - 1) / 2
    a = a % m

  // Reduction 2: Handle b ≥ m
  if b >= m:
    // Each term gets floor(b/m) added
    result += (b / m) * n
    b = b % m

  // Base case: if a*n + b < m, all remaining floors are 0
  y_max = a * n + b
  if y_max < m: return result

  // Coordinate swap (Euclidean step)
  new_n = y_max / m
  new_b = y_max % m
  swap(a, m)
  n = new_n
  b = new_b

  return result
```

## Example Usage

```mbt check
///|
test "floor sum quick start" {
  inspect(@floor_sum.floor_sum(4L, 5L, 3L, 2L), content="4")
  inspect(@floor_sum.floor_sum(5L, 4L, 2L, 1L), content="4")
  inspect(@floor_sum.floor_sum(5L, 3L, 2L, 1L), content="7")
}
```

```mbt check
///|
test "floor sum with reductions" {
  inspect(@floor_sum.floor_sum(5L, 4L, 6L, 7L), content="21")
}
```

## Algorithm Walkthrough

```
Example: floor_sum(n=5, m=3, a=2, b=1)

Step 1: a=2 < m=3, b=1 < m=3
  y_max = a*n + b = 2*5 + 1 = 11
  y_max >= m, so reduce:
    new_n = 11 / 3 = 3
    new_b = 11 % 3 = 2
    swap(a, m) => a=3, m=2
    n=3, b=2

Step 2: a=3 ≥ m=2
  result += (a/m) * n*(n-1)/2 = 1 * 3*2/2 = 3
  a = 3 % 2 = 1

Step 3: b=2 ≥ m=2
  result += (b/m) * n = 1 * 3 = 3
  b = 0
  result = 6

Now y_max = a*n + b = 1*3 + 0 = 3
  y_max >= m, reduce again:
    new_n = 3 / 2 = 1
    new_b = 3 % 2 = 1
    swap(a, m) => a=2, m=1
    n=1, b=1

Step 4: a=2 ≥ m=1
  result += (a/m) * n*(n-1)/2 = 2 * 0 = 0
  a = 0

Step 5: b=1 ≥ m=1
  result += (b/m) * n = 1 * 1 = 1
  b = 0
  result = 7

Now y_max = a*n + b = 0*1 + 0 = 0
  y_max < m, loop ends.

Final answer: 7
```

## Why the Euclidean Reduction Works

```
The floor sum counts lattice points in a triangle-like region.

Original region:         After coordinate swap:
  0 ≤ i < n                The same lattice points,
  0 ≤ j < (a·i + b)/m      but counted from a different axis!

When a < m, the line y = (ax + b)/m has slope < 1.
We can swap x and y roles, getting a new problem with:
  - New "a" becomes m (or related)
  - New "m" becomes a
  - Since a < m was the input, new problem has smaller m

This is exactly like Euclidean GCD reduction!
Each step: (a, m) → (m mod a, a) or similar
Terminates in O(log min(a, m)) steps.
```

## Common Applications

### 1. Counting Lattice Points
```
Count integer points under a line segment.
Useful in computational geometry.
```

### 2. Number Theory
```
Compute sums involving floor functions.
Related to Dedekind sums and continued fractions.
```

### 3. Competitive Programming
```
AtCoder Library includes this function.
Used in problems involving counting with divisibility.
```

### 4. Algorithm Analysis
```
Analyze algorithms with floor-based recurrences.
Summation of harmonic-like series.
```

## Complexity Analysis

| Operation | Time |
|-----------|------|
| Floor Sum | O(log min(a, m)) |
| Space | O(1) |

The time complexity follows from the Euclidean algorithm's analysis.

## Floor Sum vs Direct Computation

```
Direct: O(n) - compute each floor
Floor Sum: O(log m) - Euclidean reduction

For n = 10^9, m = 10^9:
  Direct: 10^9 operations (too slow)
  Floor Sum: ~60 operations (log scale)

Speedup: 10^7 times faster!
```

## Common Pitfalls

- **Parameter order**: API is `floor_sum(n, m, a, b)`.
- **Negative inputs**: this implementation assumes non-negative values.
- **Overflow**: use 64-bit integers for large n, a, b, m.

## Implementation Notes

- Handle n = 0 as base case (sum = 0)
- Handle m ≤ 0 appropriately (undefined or error)
- Use 64-bit integers to avoid overflow for large n
- The recursive formula involves a coordinate transformation
- Similar in spirit to extended Euclidean algorithm

## Related Functions

```
1. floor_sum: Σ floor((a·i + b) / m)
2. Dedekind sum: Related to floor sums with reciprocal terms
3. Lattice point counting: Pick's theorem for polygons
4. Farey sequence: Fractions with floor properties
```
