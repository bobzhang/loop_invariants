# Matrix Exponentiation

## Overview

**Matrix Exponentiation** computes M^n efficiently using binary exponentiation
(square-and-multiply). It's the key technique for computing linear recurrences
in O(k³ log n) time, where k is the matrix dimension.

- **Time**: O(k³ log n) for k×k matrix to power n
- **Space**: O(k²)

## The Key Insight

```
Just like computing a^n in O(log n) multiplications,
we can compute M^n in O(log n) matrix multiplications!

Binary exponentiation:
  a^13 = a^8 × a^4 × a^1    (13 = 1101 in binary)

Matrix version:
  M^13 = M^8 × M^4 × M^1

Precompute: M^1, M^2, M^4, M^8, ...
Each is square of previous: M^(2k) = M^k × M^k
```

## Fibonacci Example

```
Fibonacci: F(n) = F(n-1) + F(n-2)

As matrix equation:
┌ F(n)   ┐   ┌ 1 1 ┐   ┌ F(n-1) ┐
│        │ = │     │ × │        │
└ F(n-1) ┘   └ 1 0 ┘   └ F(n-2) ┘

Apply n-1 times:
┌ F(n)   ┐   ┌ 1 1 ┐^(n-1)   ┌ F(1) ┐   ┌ 1 1 ┐^(n-1)   ┌ 1 ┐
│        │ = │     │       × │      │ = │     │       × │   │
└ F(n-1) ┘   └ 1 0 ┘         └ F(0) ┘   └ 1 0 ┘         └ 0 ┘

F(10) via matrix:
┌ 1 1 ┐^9   ┌ 55 34 ┐
│     │   = │       │
└ 1 0 ┘     └ 34 21 ┘

F(10) = 55 ✓
```

## Algorithm

```
def matrix_power(M, n):
    result = identity_matrix
    base = M

    while n > 0:
        if n is odd:
            result = result × base
        base = base × base
        n = n // 2

    return result

# For Fibonacci(n):
M = [[1, 1], [1, 0]]
answer = matrix_power(M, n-1)[0][0]
```

## Walkthrough: M^5

```
M = ┌ 2 1 ┐
    └ 1 1 ┘

n = 5 = 101 in binary

Iteration 1: n=5 (odd)
  result = I × M = M
  base = M² = ┌ 5 3 ┐
              └ 3 2 ┘
  n = 2

Iteration 2: n=2 (even)
  result = M (unchanged)
  base = M⁴ = ┌ 34 21 ┐
              └ 21 13 ┘
  n = 1

Iteration 3: n=1 (odd)
  result = M × M⁴ = M⁵ = ┌ 89 55 ┐
                         └ 55 34 ┘
  base = M⁸
  n = 0

Done! M⁵ computed in 3 iterations.
```

## Common Applications

### 1. Linear Recurrences
```
Any recurrence f(n) = a₁f(n-1) + a₂f(n-2) + ... + aₖf(n-k)

Matrix form:
┌ f(n)   ┐   ┌ a₁ a₂ ... aₖ ┐   ┌ f(n-1) ┐
│ f(n-1) │   │ 1  0  ... 0  │   │ f(n-2) │
│  ...   │ = │ 0  1  ... 0  │ × │  ...   │
└ f(n-k+1)┘   └ 0  0  ... 0  ┘   └ f(n-k) ┘
```

### 2. Path Counting
```
Count paths of exactly n edges in graph:
  (A^n)[i][j] = number of paths from i to j

A = adjacency matrix
```

### 3. Markov Chains
```
State after n transitions:
  π(n) = π(0) × P^n

P = transition probability matrix
```

### 4. Dynamic Programming Optimization
```
Some DP with fixed transition structure:
  dp[n] = M × dp[n-1]

Compute dp[n] in O(k³ log n) instead of O(kn).
```

## Example: Tribonacci

```
T(n) = T(n-1) + T(n-2) + T(n-3)
T(0)=0, T(1)=0, T(2)=1

Transition matrix:
┌ T(n)   ┐   ┌ 1 1 1 ┐   ┌ T(n-1) ┐
│ T(n-1) │ = │ 1 0 0 │ × │ T(n-2) │
└ T(n-2) ┘   └ 0 1 0 ┘   └ T(n-3) ┘

T(10) = 149 (sequence: 0,0,1,1,2,4,7,13,24,44,81,149,...)
```

## Modular Matrix Exponentiation

```
For large exponents, compute M^n mod p:

def mat_mult_mod(A, B, p):
    C = new matrix of zeros
    for i, j, k:
        C[i][j] = (C[i][j] + A[i][k] * B[k][j]) % p
    return C

def mat_pow_mod(M, n, p):
    // Same as before, but use mat_mult_mod
```

## Complexity Analysis

| Operation | Time |
|-----------|------|
| Matrix multiply (k×k) | O(k³) |
| Matrix power M^n | O(k³ log n) |
| Nth Fibonacci | O(log n) |
| Nth term of k-order recurrence | O(k³ log n) |

## Matrix Exponentiation vs Naive

| Method | Time | When to Use |
|--------|------|-------------|
| **Matrix exp** | O(k³ log n) | n is huge |
| Naive DP | O(kn) | k is huge or n is small |
| Generating functions | Analytical | When closed form exists |

**Choose Matrix Exponentiation when**: n is large and k is small.

## Building the Matrix

```
General k-th order recurrence:
  f(n) = c₁f(n-1) + c₂f(n-2) + ... + cₖf(n-k) + d

With constant term d:
┌ f(n)   ┐   ┌ c₁ c₂ ... cₖ d ┐   ┌ f(n-1) ┐
│ f(n-1) │   │ 1  0  ... 0  0 │   │ f(n-2) │
│  ...   │ = │ 0  1  ... 0  0 │ × │  ...   │
│ f(n-k+1)│   │ 0  0  ... 0  0 │   │ f(n-k) │
└   1    ┘   └ 0  0  ... 0  1 ┘   └   1    ┘

The extra row/column handles the constant term.
```

## Implementation Notes

- Use modular arithmetic to avoid overflow
- Precompute base cases correctly
- Matrix should be square; pad if needed
- For sparse matrices, use sparse multiplication
- Identity matrix is the "1" for matrix multiplication
- Consider Strassen's algorithm for very large matrices (rarely needed)

