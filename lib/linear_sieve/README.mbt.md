# Linear Sieve

## Overview

The linear sieve computes primes and multiplicative functions such as
smallest prime factor (spf), Euler's totient (phi), and Möbius (mu)
in **O(n)** time.

- **Time**: O(n)
- **Space**: O(n)

## Example

```mbt check
///|
test "linear sieve example" {
  let sieve = @linear_sieve.LinearSieve::new(10)
  inspect(sieve.primes, content="[2, 3, 5, 7]")
  inspect(sieve.phi[10], content="4")
  inspect(sieve.mu[10], content="1")
}
```
