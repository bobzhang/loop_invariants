# Berlekamp-Massey (Find a Linear Recurrence)

Berlekamp-Massey finds the **shortest linear recurrence** that generates a
sequence, working modulo a prime number. It is a classic tool in algorithms
and number theory: once you discover the recurrence, you can predict far
future terms quickly.

This package exports a single function:

- `@berlekamp_massey.berlekamp_massey(seq, m)` -> `Array[Int64]`

The result is a list of coefficients `[c0, c1, ..., c{L-1}]` so that:

```
s[i] = c0*s[i-1] + c1*s[i-2] + ... + c{L-1}*s[i-L] (mod m)
```

## Problem statement

You are given the first `n` terms of a sequence (modulo a prime `m`). You want
the *shortest* recurrence that reproduces those terms. The recurrence length
`L` should be as small as possible.

## Why this is useful

Once you know the recurrence, you can:

- Predict future terms efficiently.
- Build fast exponentiation / linear recurrence evaluation.
- Compress sequence descriptions into a small set of coefficients.

## What the algorithm guarantees

Berlekamp-Massey processes the sequence left to right and maintains the
shortest recurrence that matches the prefix so far. If the sequence truly
follows a linear recurrence, the algorithm returns the minimal one.

The modulus **must be prime**, because the algorithm uses modular inverses.

## How to read the output

If the output is `coeffs = [c0, c1, c2]`, the recurrence is:

```
s[i] = c0*s[i-1] + c1*s[i-2] + c2*s[i-3] (mod m)
```

The length `L` is `coeffs.length()`. If the output is empty, the sequence is
empty (input length 0).

## Examples

### Example 1: Fibonacci

Fibonacci satisfies `s[i] = s[i-1] + s[i-2]`.

```mbt check
///|
test "fibonacci recurrence" {
  let m = 1000000007L
  let seq : Array[Int64] = [0L, 1L, 1L, 2L, 3L, 5L, 8L]
  let coeffs = @berlekamp_massey.berlekamp_massey(seq, m)
  inspect(coeffs, content="[1, 1]")
}
```

### Example 2: geometric progression

If `s[i] = 2 * s[i-1]`, the recurrence length is 1.

```mbt check
///|
test "geometric progression" {
  let m = 1000000007L
  let seq : Array[Int64] = [1L, 2L, 4L, 8L, 16L]
  let coeffs = @berlekamp_massey.berlekamp_massey(seq, m)
  inspect(coeffs, content="[2]")
}
```

### Example 3: constant sequence

A constant sequence has recurrence `s[i] = s[i-1]`.

```mbt check
///|
test "constant sequence" {
  let m = 1000000007L
  let seq : Array[Int64] = [7L, 7L, 7L, 7L]
  let coeffs = @berlekamp_massey.berlekamp_massey(seq, m)
  inspect(coeffs, content="[1]")
}
```

### Example 4: custom length-2 recurrence

Let the rule be `s[i] = 2*s[i-1] + 3*s[i-2]`.

```mbt check
///|
test "custom recurrence length 2" {
  let m = 1000000007L
  let seq : Array[Int64] = [1L, 2L, 7L, 20L, 61L, 182L]
  let coeffs = @berlekamp_massey.berlekamp_massey(seq, m)
  inspect(coeffs, content="[2, 3]")
}
```

### Example 5: verify the recurrence on the next term

Here we recompute the next term from the coefficients and confirm that it
matches the sequence.

```mbt check
///|
test "verify next term" {
  let m = 1000000007L
  let seq : Array[Int64] = [1L, 2L, 7L, 20L, 61L]
  let coeffs = @berlekamp_massey.berlekamp_massey(seq, m)
  inspect(coeffs, content="[2, 3]")
  // Predict the next term using the recurrence.
  let next = (coeffs[0] * seq[4] + coeffs[1] * seq[3]) % m
  inspect(next, content="182")
}
```

## Step-by-step intuition (short version)

The algorithm keeps a current recurrence `C` and a previous recurrence `B`.
When the current recurrence fails to predict a term (this is called a
"discrepancy"), we adjust `C` using `B` to fix the error at the current index.
If the current recurrence is too short to explain the new data, we increase
its length.

Think of it as "patching" the recurrence only when it is proven wrong, which
ensures minimal length.

## Practical notes and pitfalls

- **Modulus must be prime** so that modular inverses exist.
- **More data is better**: if you only give a few terms, the algorithm can only
  fit that prefix. To reliably recover a recurrence of length L, provide at
  least 2*L terms.
- **Output is modulo m**: negative coefficients are represented as `m - x`.
- **Sequence is assumed to follow a recurrence**: if it does not, the output
  only guarantees correctness for the prefix provided.

## Complexity

- Finding the recurrence: O(n^2)
- Using the recurrence to jump far: typically O(L^2 log n) with fast exponentiation

## When to use Berlekamp-Massey

Use it when:

- You suspect a sequence is linear-recurring modulo a prime.
- You want a compact representation of the sequence.
- You plan to compute large-index terms efficiently.
