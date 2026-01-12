# Rabin-Karp Algorithm

## Overview

**Rabin-Karp** is a string matching algorithm using rolling hashes. It computes
a hash for the pattern and slides a window over the text, comparing hashes
for O(1) average-case matching per position.

- **Expected Time**: O(n + m)
- **Worst Case**: O(nm) (many hash collisions)
- **Space**: O(1)

## The Key Insight

```
Instead of comparing characters, compare hashes.
Use a "rolling hash" to update hash in O(1) as window slides.

Pattern: "aba"  →  hash("aba") = H_p

Text: "acababa"
       |||
Slide window:
  "aca" → hash = H₁ ≠ H_p
  "cab" → hash = H₂ ≠ H_p  (O(1) update from H₁!)
  "aba" → hash = H₃ = H_p  → verify characters
  ...

If hashes match, verify to avoid false positives.
```

## Rolling Hash

```
Polynomial hash:
  hash(s) = s[0] × b^(m-1) + s[1] × b^(m-2) + ... + s[m-1]
  where b = base (e.g., 31 or 256)

Rolling update when sliding from s[i..i+m] to s[i+1..i+m+1]:
  new_hash = (old_hash - s[i] × b^(m-1)) × b + s[i+m]

Example: base = 10, text = "12345"
  hash("123") = 1×100 + 2×10 + 3 = 123
  hash("234") = (123 - 1×100) × 10 + 4 = 234

This is O(1) instead of O(m)!
```

## Algorithm Walkthrough

```
Pattern: "ab" (m = 2)
Text: "aabab" (n = 5)
Base = 31

Precompute:
  h_pattern = 'a'×31 + 'b' = 97×31 + 98 = 3105

Sliding window:
  i=0: "aa" → hash = 97×31 + 97 = 3104 ≠ 3105
  i=1: "ab" → hash = (3104 - 97×31)×31 + 98 = 3105 = h_pattern
       Verify: "ab" == "ab" ✓ Match at position 1!
  i=2: "ba" → hash = (3105 - 97×31)×31 + 97 = 3106 ≠ 3105
  i=3: "ab" → hash = 3105 = h_pattern
       Verify: Match at position 3!

Matches found at: [1, 3]
```

## Example Usage

```mbt check
///|
test "rabin karp example" {
  let matches = @rabin_karp.rabin_karp_search("abababab", "aba")
  inspect(matches, content="[0, 2, 4]")
  inspect(@rabin_karp.rabin_karp_count("aaaa", "aa"), content="3")
}
```

## The Algorithm

```
def rabin_karp(text, pattern):
    n, m = len(text), len(pattern)
    if m > n: return []

    # Precompute
    h_pattern = hash(pattern)
    h_text = hash(text[0:m])
    b_power = base^(m-1) mod prime

    matches = []

    for i in 0..n-m:
        if h_text == h_pattern:
            if text[i:i+m] == pattern:  # Verify!
                matches.append(i)

        # Roll hash to next position
        if i < n - m:
            h_text = ((h_text - text[i] × b_power) × base + text[i+m]) mod prime

    return matches
```

## Common Applications

### 1. Single Pattern Search
```
Find all occurrences of pattern in text.
Average O(n + m), handles multiple patterns well.
```

### 2. Multiple Pattern Search
```
Search for many patterns simultaneously.
Compute hash for each pattern, check all at each position.
Time: O(n × k) for k patterns (hash comparisons are O(1))
```

### 3. Plagiarism Detection
```
Find common substrings between documents.
Hash all k-grams, find matching hashes.
```

### 4. Longest Repeated Substring
```
Binary search on length, use hashing to check.
O(n log n) with rolling hash.
```

## Hash Collision Handling

```
Problem: Different strings can have same hash (collision)

Solutions:
1. Always verify: Compare characters when hashes match
2. Double hashing: Use two independent hash functions
3. Large modulus: Use prime modulus to reduce collisions

Collision probability ≈ 1/prime for random strings
With 64-bit hash: ~1/10^18 probability
```

## Complexity Analysis

| Case | Time |
|------|------|
| Best/Average | O(n + m) |
| Worst (many collisions) | O(nm) |
| Multiple patterns (k) | O(n × k) average |

## Rabin-Karp vs Other String Matching

| Algorithm | Time | Preprocessing | Best For |
|-----------|------|---------------|----------|
| **Rabin-Karp** | O(n) avg | O(m) | Multiple patterns |
| KMP | O(n + m) | O(m) | Single pattern |
| Boyer-Moore | O(n/m) best | O(m + σ) | Long patterns |
| Aho-Corasick | O(n + z) | O(total pattern) | Many patterns |

**Choose Rabin-Karp when**: You need simple implementation or multiple pattern matching.

## Choosing Hash Parameters

```
Base (b):
  - Typically alphabet size or a prime (31, 37, 256)
  - Should be larger than alphabet size

Modulus (p):
  - Large prime to reduce collisions
  - Common: 10^9 + 7, 10^9 + 9, 2^61 - 1
  - Larger = fewer collisions but slower arithmetic

Multiple hashes:
  - Use 2-3 independent (base, modulus) pairs
  - Collision requires matching ALL hashes
  - Probability: 1/p₁ × 1/p₂ × ...
```

## Implementation Notes

- Precompute base^(m-1) for efficiency
- Use modular arithmetic to avoid overflow
- Handle negative remainders carefully (add modulus if needed)
- For case-insensitive matching, normalize before hashing
- Consider using 64-bit integers to avoid overflow issues
- Verification is essential to avoid false positives

