# String Hashing

## Overview

**String Hashing** uses polynomial rolling hashes to compare substrings in O(1)
time after O(n) preprocessing. It's widely used for pattern matching, substring
comparison, and detecting repeated patterns.

- **Preprocessing**: O(n)
- **Substring Hash**: O(1)
- **Pattern Matching**: O(n + m)

## The Key Insight

```
Treat string as a number in base B:
  hash("abc") = 'a'×B² + 'b'×B + 'c'

With precomputed prefix hashes, any substring hash is O(1):
  hash(s[l..r]) = prefix[r+1] - prefix[l] × B^(r-l+1)

Example: s = "abcde", B = 31
  prefix[0] = 0
  prefix[1] = 'a' = 97
  prefix[2] = 'a'×31 + 'b' = 97×31 + 98 = 3105
  prefix[3] = 'a'×31² + 'b'×31 + 'c' = ...

  hash("bcd") = prefix[4] - prefix[1] × 31³
```

## Polynomial Rolling Hash

```
For string s of length n with base B and modulus M:

prefix[0] = 0
prefix[i] = (prefix[i-1] × B + s[i-1]) mod M

powers[0] = 1
powers[i] = (powers[i-1] × B) mod M

Substring hash [l, r]:
  hash = (prefix[r+1] - prefix[l] × powers[r-l+1]) mod M
  if hash < 0: hash += M  // Handle negative mod
```

## Visual: Hash Computation

```
String: "abcde"
Base: 31, Mod: 10^9+7

Building prefix hashes:
  Index:   0    1    2    3    4    5
  Char:    -    a    b    c    d    e
  ASCII:   -   97   98   99  100  101

  prefix[0] = 0
  prefix[1] = 0×31 + 97 = 97
  prefix[2] = 97×31 + 98 = 3105
  prefix[3] = 3105×31 + 99 = 96354
  prefix[4] = 96354×31 + 100 = 2987074
  prefix[5] = 2987074×31 + 101 = 92599395

Query hash("bcd") = s[1..3]:
  = prefix[4] - prefix[1] × powers[3]
  = 2987074 - 97 × 31³
  = 2987074 - 97 × 29791
  = 2987074 - 2889727
  = 97347
```

## Why It Works

```
prefix[r+1] = s[0]×B^r + s[1]×B^(r-1) + ... + s[r]×B^0

prefix[l] × B^(r-l+1) = s[0]×B^r + ... + s[l-1]×B^(r-l+1)

Subtraction cancels the prefix, leaving:
  s[l]×B^(r-l) + s[l+1]×B^(r-l-1) + ... + s[r]×B^0

Which is exactly hash(s[l..r])!
```

## Example Usage

```mbt check
///|
test "string hash example" {
  let hits = @string_hash.hash_pattern_match("abababab", "aba")
  inspect(hits, content="[0, 2, 4]")
}
```

## Common Applications

### 1. Pattern Matching
```
Find all occurrences of pattern P in text T:
  1. Compute hash of P
  2. Slide window of length |P| over T
  3. Compare hashes (O(1) each)

Time: O(n + m) average (assuming no collisions)
```

### 2. Longest Common Substring
```
Binary search on length k:
  - Hash all substrings of length k from both strings
  - Check for hash collision → potential match
  - Verify actual match to handle collisions

Time: O(n log n) with hashing
```

### 3. Detecting Repeated Substrings
```
Hash all substrings, find duplicates.
Use hash set for O(1) lookup.
```

### 4. String Comparison in Suffix Array
```
Compare suffixes using LCP + hashing.
Binary search for longest common prefix.
```

## Handling Collisions

```
Problem: Different strings can have same hash (collision)

Solutions:
1. Double hashing: Use two independent (base, mod) pairs
   Match only if BOTH hashes match
   Collision probability: ~1/M₁ × 1/M₂

2. Verify on match: When hashes match, compare actual strings
   Adds O(m) per match, but correct

3. Large prime modulus: Use 10^18 range
   Single hash collision: ~1/10^18

Recommended: Double hashing for competitive programming
```

## Hash Parameters

```
Good choices:
  Base (B): 31, 37, or 256 (larger than alphabet)
  Modulus (M): Large prime like 10^9+7, 10^9+9, or 2^61-1

Multiple hashes (recommended):
  Hash 1: B=31, M=10^9+7
  Hash 2: B=37, M=10^9+9

Avoid:
  - Base smaller than alphabet (collisions guaranteed)
  - Power-of-2 modulus (birthday attack vulnerabilities)
  - Same base and mod as opponent might guess (in contests)
```

## Complexity Analysis

| Operation | Time |
|-----------|------|
| Build prefix hashes | O(n) |
| Build power table | O(n) |
| Substring hash | O(1) |
| Pattern match | O(n + m) |
| String compare | O(1) hash, O(n) verify |

## String Hashing vs Other Approaches

| Approach | Preprocessing | Query | Guarantees |
|----------|--------------|-------|------------|
| **String Hashing** | O(n) | O(1) | Probabilistic |
| KMP | O(m) | O(n) | Deterministic |
| Suffix Array | O(n log n) | O(m log n) | Deterministic |
| Z-algorithm | O(n+m) | O(n+m) | Deterministic |

**Choose String Hashing when**: You need O(1) substring comparisons or multiple pattern matching.

## Implementation Notes

- Handle modular arithmetic carefully (negative remainders)
- Precompute power table up to max string length
- For multiple queries, cache common hashes
- Consider using unsigned 64-bit integers for speed
- Watch for overflow: use 128-bit multiplication or careful modular mult

