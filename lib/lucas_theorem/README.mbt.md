# Lucas Theorem

## Overview

Lucas theorem computes `C(n, k) mod p` for **large n** when `p` is prime:

```
C(n, k) ≡ Π C(n_i, k_i) (mod p)
```

where `n_i` and `k_i` are digits of `n` and `k` in base `p`.

- **Time**: O(p + log_p n)
- **Space**: O(p)

## Quick Start

```mbt check
///|
test "lucas theorem quick start" {
  inspect(@lucas_theorem.nck_mod_prime_lucas(10L, 3L, 7L), content="1")
}
```

## Core Idea

Write n and k in base p. The binomial coefficient factors as the product of
digit-level coefficients:

```
C(n, k) mod p = Π C(ni, ki) mod p
```

If any digit ki > ni, the result is 0.

## Why It Works (Intuition)

Write `n` and `k` in base `p`:

```
n = n0 + n1 p + n2 p^2 + ...
k = k0 + k1 p + k2 p^2 + ...
```

Then:

```
C(n, k) mod p = Π C(ni, ki) mod p
```

If any digit `ki > ni`, that term is zero.

## More Examples

```mbt check
///|
test "lucas theorem small cases" {
  inspect(@lucas_theorem.nck_mod_prime_lucas(5L, 2L, 5L), content="0")
  inspect(@lucas_theorem.nck_mod_prime_lucas(1000L, 500L, 2L), content="0")
}
```
