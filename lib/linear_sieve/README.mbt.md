# Linear Sieve

## Overview

The linear sieve computes primes and multiplicative functions such as
smallest prime factor (spf), Euler's totient (phi), and Möbius (mu)
in **O(n)** time.

- **Time**: O(n)
- **Space**: O(n)

## Quick Start

```mbt check
///|
test "linear sieve quick start" {
  let sieve = @linear_sieve.LinearSieve::new(10)
  inspect(sieve.primes, content="[2, 3, 5, 7]")
  inspect(sieve.spf[10], content="2")
  inspect(sieve.phi[10], content="4")
  inspect(sieve.mu[10], content="1")
  inspect(sieve.mu[4], content="0")
  inspect(sieve.is_prime(7), content="true")
  inspect(sieve.is_prime(9), content="false")
}
```

## What You Get

- `primes`: list of all primes ≤ n
- `spf`: smallest prime factor for every integer
- `phi`: Euler's totient function
- `mu`: Möbius function

These arrays enable fast factorization and multiplicative function queries.

## Factorization Example

```mbt check
///|
test "linear sieve factorization" {
  let sieve = @linear_sieve.LinearSieve::new(100)
  inspect(sieve.factorize(84), content="[(2, 2), (3, 1), (7, 1)]")
  inspect(sieve.is_prime(97), content="true")
}
```
