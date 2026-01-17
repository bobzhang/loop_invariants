# Berlekamp–Massey (Find a Linear Recurrence)

## Problem

Given a sequence like:

```
0, 1, 1, 2, 3, 5, 8, ...
```

find the **shortest linear recurrence** that generates it.
That is, find coefficients `c` so that:

```
s[i] = c[0]*s[i-1] + c[1]*s[i-2] + ... + c[L-1]*s[i-L]
```

## Simple Idea

Process the sequence left to right.
Whenever the current recurrence fails to predict a value, update it using a past failure.
The algorithm keeps the **shortest** valid recurrence seen so far.

## What You Get

A coefficient array `[c0, c1, ..., c{L-1}]` that works for all later terms.
Once you have it, you can compute very large indices quickly.

## Requirements

- Modulus must be **prime** (we need modular inverses)
- The sequence should follow a linear recurrence

## Complexity

- Find recurrence: **O(n²)**
- Use recurrence to compute `s[n]`: **O(L² log n)**

## Example

```mbt check
///|
test "berlekamp massey quick start" {
  let m = 1000000007L
  let seq : Array[Int64] = [0L, 1L, 1L, 2L, 3L, 5L, 8L]
  let coeffs = @berlekamp_massey.berlekamp_massey(seq, m)
  inspect(coeffs, content="[1, 1]")
}
```

```mbt check
///|
test "berlekamp massey geometric" {
  let m = 1000000007L
  let seq : Array[Int64] = [1L, 2L, 4L, 8L, 16L]
  let coeffs = @berlekamp_massey.berlekamp_massey(seq, m)
  inspect(coeffs, content="[2]")
}
```

## When to Use

Use Berlekamp–Massey when:

- You suspect a sequence has a recurrence
- You want a **compact formula** to jump to large indices
- You are working modulo a prime
