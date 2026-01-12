# Rolling Hash (Polynomial Hashing)

## Overview

**Rolling Hash** enables O(1) substring hash computation after O(n) preprocessing.
It's the foundation of Rabin-Karp string matching and many substring algorithms.

- **Preprocessing**: O(n)
- **Query**: O(1)
- **Space**: O(n)

## The Key Insight

```
Polynomial hash of string s:
  hash(s) = s[0]·base^(n-1) + s[1]·base^(n-2) + ... + s[n-1]·base^0

With prefix hashes, any substring hash is O(1):
  hash(s[l..r]) = prefix[r+1] - prefix[l] · base^(r-l+1)
```

## How It Works

```
String: "abcd"
Base: 31
Mod: 10^9 + 7

Character values: a=1, b=2, c=3, d=4

prefix[0] = 0           (empty string)
prefix[1] = 1           (just "a")
prefix[2] = 1·31 + 2 = 33    ("ab")
prefix[3] = 33·31 + 3 = 1026 ("abc")
prefix[4] = 1026·31 + 4 = 31810 ("abcd")

To get hash("bc"):
  l=1, r=2 (substring indices)
  hash = prefix[3] - prefix[1] · 31²
       = 1026 - 1 · 961
       = 65

Verify: hash("bc") = 2·31 + 3 = 65 ✓
```

## Visual: The Rolling Window

```
String: a b c d e f
        └─────┘
        window "bcd"

To slide window right (add 'e', remove 'b'):

  hash("bcde") = hash("bcd") · base + char('e') - char('b') · base^4

This is why it's called "rolling" - we can update
the hash in O(1) as the window slides!

Before: [a b c d] e f    hash = h1
After:   a [b c d e] f   hash = (h1 - a·base³) · base + e
```

## Rabin-Karp Pattern Matching

```
Text:    "aabcaabxaab"
Pattern: "aab"

1. Compute hash(pattern) = hash("aab")
2. Compute prefix hashes for text
3. For each position i:
   - Compute hash(text[i..i+2]) in O(1)
   - If hash matches pattern hash, verify (handle collisions)

Positions where hash("aab") matches:
  Position 0: "aab" ✓
  Position 4: "aab" ✓
  Position 8: "aab" ✓

Matches: [0, 4, 8]
```

## Example Usage

```mbt check
///|
test "rolling hash pattern search" {
  let hits = @rolling_hash.find_pattern_rabin_karp("aabcaabxaab", "aab")
  inspect(hits, content="[0, 4, 8]")
  inspect(
    @rolling_hash.count_pattern_rabin_karp("mississippi", "issi"),
    content="2",
  )
}
```

## Common Applications

### 1. Pattern Matching (Rabin-Karp)
```
Find all occurrences of pattern in text
Time: O(n + m) expected, O(n·m) worst case (due to collisions)
```

### 2. Longest Common Substring
```
Binary search on length + hash comparison
Time: O(n log n) with hashing vs O(n²) naive
```

### 3. Distinct Substrings Count
```
Hash all substrings, count unique hashes
Combine with suffix array for exact count
```

### 4. Palindrome Checking
```
hash(s[l..r]) == hash(reverse(s[l..r]))?
Precompute forward and reverse hashes
```

### 5. Lexicographic Comparison
```
Binary search for longest common prefix using hashes
Then compare the differing character
```

## Collision Handling

```
Problem: Different strings can have same hash!

hash("ab") might equal hash("xy") by chance

Probability: 1/MOD ≈ 10^-9 per comparison
For n² comparisons, collision likely if n > 30000

Solutions:
1. Use large prime MOD (10^9 + 7)
2. Double hashing: use two different bases
   Match only if both hashes match
3. Verify matches with direct string comparison
```

## Double Hashing

```
hash1 = polynomial hash with base1, mod1
hash2 = polynomial hash with base2, mod2

Strings match if hash1 AND hash2 both match.

Collision probability: 1/(mod1 · mod2) ≈ 10^-18
Safe for virtually any input size!
```

## Complexity Analysis

| Operation | Time |
|-----------|------|
| Build prefix hashes | O(n) |
| Query substring hash | O(1) |
| Pattern matching (expected) | O(n + m) |
| Pattern matching (worst) | O(n · m) |

## Rolling Hash vs Other Methods

| Method | Preprocessing | Query | Exact? |
|--------|---------------|-------|--------|
| **Rolling Hash** | O(n) | O(1) | No* |
| KMP | O(m) | O(n) | Yes |
| Z-Algorithm | O(n) | O(n) | Yes |
| Suffix Array | O(n log n) | O(m log n) | Yes |

*Hash collisions possible; verify matches for critical applications.

**Choose Rolling Hash when**: You need fast substring comparisons and can tolerate rare false positives.

## The Hash Formula

```
String s of length n:
hash(s) = Σ s[i] · base^(n-1-i)  (mod MOD)

Recurrence for prefix hash:
prefix[0] = 0
prefix[i+1] = prefix[i] · base + char_value(s[i])

Substring hash:
hash(s[l..r]) = prefix[r+1] - prefix[l] · base^(r-l+1)

The subtraction "removes" the contribution of s[0..l-1]
scaled by base^(r-l+1) to align the positions.
```

## Implementation Notes

- Choose prime MOD close to 2^30 to avoid overflow with int64
- Base should be larger than alphabet size (31 or 37 for lowercase letters)
- Precompute powers of base up to max string length
- For negative results after subtraction, add MOD
- Consider double hashing for safety-critical applications

