# Matrix Exponentiation (linear recurrences in log n)

## 1. What problem does this solve?

Matrix exponentiation computes **M^n** fast using binary exponentiation. This is
useful because many problems (Fibonacci, linear recurrences, path counting) can
be written as repeated matrix multiplication.

- Time: O(k^3 log n) for k x k matrices
- Space: O(k^2)

This package is a **teaching example** with rich loop invariants. It does not
export a public API, so code examples are marked `mbt nocheck` and mirror the
package tests.

## 2. Key idea: binary exponentiation for matrices

Scalar version:

```
a^13 = a^8 * a^4 * a^1  (13 = 1101b)
```

Matrix version is identical:

```
M^13 = M^8 * M^4 * M^1
```

We build powers by squaring:

```
M^1, M^2, M^4, M^8, ...
```

Each step halves the exponent, so the loop runs in O(log n) steps.

## 3. The invariant that makes it correct

Inside the loop we maintain:

```
result * base^e = M^n
```

- If `e` is odd, multiply `result` by `base`.
- Then square `base` and halve `e`.

Because matrix multiplication is associative, the same reasoning as scalar
exponentiation applies.

## 4. Matrix multiplication (why O(k^3))

For two matrices A (k x k) and B (k x k):

```
C[i,j] = sum_{t=0..k-1} A[i,t] * B[t,j]
```

This is the classic triple loop and costs O(k^3).

Diagram (dot product for one cell):

```
Row i of A:   a0  a1  a2 ...
Column j of B: b0  b1  b2 ...
C[i,j] = a0*b0 + a1*b1 + a2*b2 + ...
```

## 5. Walkthrough: M^5 by hand

Take:

```
M = [ 2 1 ]
    [ 1 1 ]

n = 5 (101b)
```

Process bits from least significant:

```
result = I
base = M

n=5 odd: result = I*M = M
base = M^2
n=2 even: result unchanged
base = M^4
n=1 odd: result = M * M^4 = M^5
n=0 stop
```

Only 3 squarings and 2 multiplies.

## 6. Fibonacci as a matrix

The Fibonacci recurrence:

```
F(n) = F(n-1) + F(n-2)
```

Matrix form:

```
[ F(n+1) ]   [ 1 1 ]^n [ 1 ]
[ F(n)   ] = [ 1 0 ]   [ 0 ]
```

So `F(n)` is the (0,1) entry of `M^n` where:

```
M = [ 1 1 ]
    [ 1 0 ]
```

Example result:

```
M^9 = [ 55 34 ]
      [ 34 21 ]
F(10) = 55
```

```mbt nocheck
///|
test "fibonacci example" {
  inspect(fibonacci(10L), content="55")
  inspect(fibonacci(20L), content="6765")
}
```

## 7. Generic linear recurrence

Any k-term recurrence:

```
f(n) = c0*f(n-1) + c1*f(n-2) + ... + c(k-1)*f(n-k)
```

can be written with a k x k companion matrix:

```
[ f(n)   ]   [ c0 c1 c2 ... c(k-1) ] [ f(n-1) ]
[ f(n-1) ] = [ 1  0  0  ... 0      ] [ f(n-2) ]
[ ...    ]   [ 0  1  0  ... 0      ] [ ...    ]
[ f(n-k+1)]  [ 0  0  0  ... 1      ] [ f(n-k) ]
```

Raise this matrix to power `n-k+1` and multiply by the initial vector.

```mbt nocheck
///|
test "solve_recurrence examples" {
  let coeffs : Array[Int64] = [1L, 1L]
  let initial : Array[Int64] = [0L, 1L]
  inspect(solve_recurrence(coeffs, initial, 10L), content="55")
}
```

## 8. Path counting in graphs

If `A` is an adjacency matrix of a graph, then:

```
(A^k)[i,j] = number of paths of length k from i to j
```

Example graph:

```
0 -> 1 -> 2 -> 0
```

Adjacency matrix:

```
[0 1 0]
[0 0 1]
[1 0 0]
```

```mbt nocheck
///|
test "count_paths example" {
  let adj : Array[Array[Int64]] = [[0L, 1L, 0L], [0L, 0L, 1L], [1L, 0L, 0L]]
  let paths2 = count_paths(adj, 2L)
  inspect(paths2.get(0, 2), content="1")
}
```

## 9. Modulo arithmetic

This implementation uses a fixed modulus:

```
MATRIX_MOD = 1_000_000_007
```

This prevents overflow and keeps values in range for large exponents. There is
also a `multiply_no_mod` path for pure integer math when you know values are
small.

## 10. Identity matrix

The identity matrix acts like 1 for multiplication:

```
I = [1 0]
    [0 1]

I * A = A * I = A
```

It is used to initialize `result` in exponentiation.

```mbt nocheck
///|
test "identity example" {
  let a = Matrix::from_array([[1L, 2L], [3L, 4L]])
  let i = Matrix::identity(2)
  inspect(a.multiply_no_mod(i).equals(a), content="true")
}
```

## 11. Complexity summary

```
Matrix multiply:   O(k^3)
Matrix exponent:   O(k^3 log n)
Fibonacci:         O(log n)
Recurrence (k):    O(k^3 log n)
```

## 12. Common pitfalls

- Exponentiating a non-square matrix (invalid)
- Forgetting the identity matrix as the neutral element
- Mixing modulo and non-modulo arithmetic
- Overflow when using `multiply_no_mod` on large values

## 13. When to use matrix exponentiation

Use it when:

- `n` is huge (10^12, 10^18, ...)
- The recurrence has small fixed dimension `k`
- You need many queries for large indices

For small `n`, a simple DP loop is often faster and simpler.

## 14. API overview (internal)

The main building blocks inside the package:

- `Matrix::multiply` / `Matrix::multiply_no_mod`
- `Matrix::power`
- `fibonacci(n)`
- `solve_recurrence(coeffs, initial, n)`
- `count_paths(adj, k)`

See the test cases in `lib/matrix_exp/matrix_exp.mbt` for exact usage.
