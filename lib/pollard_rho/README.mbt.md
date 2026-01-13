# Pollard Rho Factorization

## Overview

This package combines a deterministic Miller–Rabin test for 64-bit integers
with Pollard's Rho algorithm to factor composite numbers efficiently.

- **Time**: sub-exponential in practice (heuristic)
- **Space**: O(1) extra (plus recursion)

## Quick Start

```mbt check
///|
test "pollard rho quick start" {
  let factors = @pollard_rho.factorize_with_counts(8051L)
  inspect(factors, content="[(83, 1), (97, 1)]")
}
```

## Primality Test

`is_prime` is deterministic for 64-bit integers using a fixed base set.

```mbt check
///|
test "pollard rho is_prime" {
  inspect(@pollard_rho.is_prime(2L), content="true")
  inspect(@pollard_rho.is_prime(97L), content="true")
  inspect(@pollard_rho.is_prime(221L), content="false")
}
```

## Factorization Tips

- The factor list is sorted and includes repeats (e.g. `12 -> [2, 2, 3]`).
- For `(prime, exponent)` pairs, use `factorize_with_counts`.
- Input `n <= 1` returns an empty list.
