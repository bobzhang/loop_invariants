# Math Utilities

## Overview

A collection of number-theoretic algorithms and mathematical utilities with
detailed invariants. These are fundamental building blocks for competitive
programming and cryptography.

## GCD and Extended GCD

```
GCD (Greatest Common Divisor):
  gcd(a, b) = largest d that divides both a and b

Euclidean Algorithm:
  gcd(a, b) = gcd(b, a mod b)
  gcd(a, 0) = a

Example:
  gcd(48, 18) = gcd(18, 12) = gcd(12, 6) = gcd(6, 0) = 6

Time: O(log min(a, b))
```

### Extended GCD

```
Find x, y such that: ax + by = gcd(a, b)

Extended Euclidean Algorithm:
  gcd(a, b) = gcd(b, a mod b)
  If bx' + (a mod b)y' = gcd(b, a mod b)
  Then ax + by = gcd(a, b) where:
    x = y'
    y = x' - (a/b) * y'

Example:
  48x + 18y = gcd(48, 18) = 6
  Solution: x = -1, y = 3  (check: -48 + 54 = 6 ✓)
```

## Modular Arithmetic

### Modular Inverse

```
a⁻¹ mod m = x such that ax ≡ 1 (mod m)

Exists iff gcd(a, m) = 1

Methods:
1. Extended GCD: ax + my = 1, so x is the inverse
2. Fermat's Little Theorem: a⁻¹ ≡ a^(p-2) (mod p) for prime p
3. Euler's Theorem: a⁻¹ ≡ a^(φ(m)-1) (mod m)

Example:
  3⁻¹ mod 7 = 5  (check: 3 × 5 = 15 ≡ 1 mod 7 ✓)
```

### Modular Exponentiation

```
Compute a^n mod m efficiently using binary exponentiation.

Algorithm:
  result = 1
  while n > 0:
    if n is odd: result = result * a mod m
    a = a * a mod m
    n = n / 2

Time: O(log n) multiplications

Example:
  3^10 mod 7:
  3^1 = 3, 3^2 = 2, 3^4 = 4, 3^8 = 2
  3^10 = 3^8 × 3^2 = 2 × 2 = 4 mod 7
```

## Chinese Remainder Theorem

```
Given:
  x ≡ a₁ (mod m₁)
  x ≡ a₂ (mod m₂)
  ...
  x ≡ aₖ (mod mₖ)

If m₁, m₂, ..., mₖ are pairwise coprime:
  Unique solution exists modulo M = m₁ × m₂ × ... × mₖ

Algorithm:
  For each i:
    Mᵢ = M / mᵢ
    yᵢ = Mᵢ⁻¹ mod mᵢ
  x = Σ aᵢ × Mᵢ × yᵢ (mod M)

Example:
  x ≡ 2 (mod 3)
  x ≡ 3 (mod 5)
  M = 15, solution: x = 8 (check: 8 mod 3 = 2, 8 mod 5 = 3 ✓)
```

## Combinatorics

### Factorials and Inverse Factorials

```
Precompute for O(1) binomial coefficients:

fact[0] = 1
for i in 1..n: fact[i] = fact[i-1] * i mod p

inv_fact[n] = mod_pow(fact[n], p-2, p)  // Fermat
for i in n-1..0: inv_fact[i] = inv_fact[i+1] * (i+1) mod p

C(n, k) = fact[n] * inv_fact[k] * inv_fact[n-k] mod p
```

### Pascal's Triangle

```
C(n, k) = C(n-1, k-1) + C(n-1, k)

     1
    1 1
   1 2 1
  1 3 3 1
 1 4 6 4 1

Properties:
  C(n, 0) = C(n, n) = 1
  C(n, k) = C(n, n-k)
  Σ C(n, k) = 2^n
```

## Prime Numbers

### Primality Testing

```
Trial division: O(√n)
  Check divisibility by 2, then odd numbers up to √n

Miller-Rabin: O(k log³ n)
  Probabilistic, but deterministic for n < 2^64 with fixed witnesses
```

### Sieve of Eratosthenes

```
Find all primes up to n in O(n log log n):

is_prime = [true] * (n+1)
is_prime[0] = is_prime[1] = false

for i in 2..√n:
    if is_prime[i]:
        for j in i*i..n step i:
            is_prime[j] = false

Primes up to 30: 2, 3, 5, 7, 11, 13, 17, 19, 23, 29
```

### Prime Factorization

```
Factorize n into primes:

factors = []
d = 2
while d * d <= n:
    while n mod d == 0:
        factors.append(d)
        n = n / d
    d = d + 1
if n > 1:
    factors.append(n)

Example: 60 = 2² × 3 × 5
```

## Euler's Totient Function

```
φ(n) = count of integers in [1, n] coprime to n

Formula: φ(n) = n × Π (1 - 1/p) for each prime p dividing n

Examples:
  φ(1) = 1
  φ(p) = p - 1 for prime p
  φ(12) = 12 × (1-1/2) × (1-1/3) = 4
        (coprimes: 1, 5, 7, 11)
```

## Common Applications

### 1. Modular Division
```
a / b mod p = a × b⁻¹ mod p
Requires: gcd(b, p) = 1
```

### 2. Large Exponents
```
Compute a^(b^c) mod m using Euler's theorem:
  a^k mod m = a^(k mod φ(m)) mod m  (if gcd(a,m) = 1)
```

### 3. Counting Problems
```
Use binomial coefficients with modular arithmetic.
Precompute factorials for efficiency.
```

### 4. Cryptography
```
RSA uses: modular exponentiation, Euler's totient, CRT
```

## Complexity Summary

| Operation | Time |
|-----------|------|
| GCD | O(log min(a,b)) |
| Extended GCD | O(log min(a,b)) |
| Mod exponentiation | O(log n) |
| Mod inverse | O(log m) |
| Sieve (primes to n) | O(n log log n) |
| Factorization | O(√n) |
| Precompute factorials | O(n) |
| Binomial (after precompute) | O(1) |

## Implementation Notes

- Use 64-bit integers to avoid overflow in modular multiplication
- For very large numbers, use __int128 or careful modular reduction
- Precompute factorials up to expected n for many binomial queries
- CRT can overflow; use careful intermediate modular reduction
- For multiple modular inverses, batch using factorial trick

