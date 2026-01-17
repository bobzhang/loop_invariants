# Duval's Lyndon Factorization

## Overview

**Duval's algorithm** decomposes any string into a unique sequence of **Lyndon words**
in non-increasing lexicographic order. A Lyndon word is a string that is strictly
smaller than all of its non-trivial rotations.

- **Time**: O(n)
- **Space**: O(n)
- **Output**: Unique factorization into Lyndon words

## The Key Insight

```
Problem: Decompose a string into "primitive" building blocks

What makes Lyndon words special?
  - "a" is Lyndon: smallest rotation of itself
  - "ab" is Lyndon: "ab" < "ba"
  - "abc" is Lyndon: "abc" < "bca" < "cab"
  - "ba" is NOT Lyndon: "ab" < "ba"
  - "aa" is NOT Lyndon: "aa" = "aa" (not strictly smaller)

Theorem (Chen-Fox-Lyndon):
  Every string has a UNIQUE factorization into Lyndon words
  in non-increasing lexicographic order.
```

## Understanding Lyndon Words

```
Lyndon word: Strictly smallest among all its rotations

Examples:
  "a"     → rotations: "a"           → Lyndon ✓
  "ab"    → rotations: "ab", "ba"    → "ab" < "ba" ✓
  "abc"   → rotations: "abc","bca","cab" → "abc" smallest ✓
  "aab"   → rotations: "aab","aba","baa" → "aab" smallest ✓

Non-examples:
  "ba"    → rotations: "ba", "ab"    → "ab" < "ba" ✗
  "cba"   → rotations: "cba","bac","acb" → "acb" smallest ✗
  "aa"    → rotations: "aa", "aa"    → equal, not strictly smaller ✗

Key property: Lyndon words are primitive (not a repetition of a shorter string)
```

### Rotations as a Wheel

```
Take "abac" and rotate it by cutting at different positions:

  cut at 0: abac
  cut at 1: baca
  cut at 2: acab
  cut at 3: caba

The smallest rotation is "abac" itself, so "abac" is Lyndon.

Now take "abab":
  rotations: abab, baba, abab, baba
  "abab" repeats, so it is NOT strictly smaller than all rotations.
  Therefore "abab" is NOT Lyndon.
```

## The Unique Factorization

```
Every string can be written as w = L1 · L2 · ... · Lk where:
  - Each Li is a Lyndon word
  - L1 ≥ L2 ≥ ... ≥ Lk (lexicographically non-increasing)

Examples:
  "banana" = "b" · "an" · "an" · "a"
             (b ≥ an ≥ an ≥ a ✓)

  "ababab" = "ab" · "ab" · "ab"
             (ab = ab = ab ✓)

  "abracadabra" = "abracadabr" · "a"
             (Check: is "abracadabr" Lyndon? Yes!)
```

## Algorithm Walkthrough

```
Duval's algorithm uses three pointers: i, j, k

i = start of current potential Lyndon factor
j = scanning position
k = comparison position within the repeating pattern

Process "banana":

Initial: i=0, j=1, k=0
         b a n a n a
         i j
         k

Step 1: Compare s[j]=a vs s[k]=b
        'a' < 'b' → current block breaks
        Output: "b" (length j-k = 1)
        i = j = 1, k = 1

Step 2: i=1, j=2, k=1
        Compare s[2]='n' vs s[1]='a'
        'n' > 'a' → extend pattern
        j = 3, k = 1

Step 3: i=1, j=3, k=2
        Compare s[3]='a' vs s[2]='n'
        'a' < 'n' → break
        Output: "an" (from i=1, length 2)
        i = j = 3, k = 3

Step 4: Similar process...
        Output: "an"

Step 5: Output: "a"

Result: ["b", "an", "an", "a"]
```

### Pointer Trace Table (banana)

```
String: banana
Index : 0 1 2 3 4 5
Char  : b a n a n a

Step | i  j  k | compare s[k] vs s[j] | action
-----+---------+----------------------|-------------------------------
  1  | 0  1  0 | b > a                | stop scan, period = 1
     |         |                      | emit "b", i = 1
  2  | 1  2  1 | a < n                | j = 3, k = i
  3  | 1  3  1 | a = a                | j = 4, k = 2
  4  | 1  4  2 | n = n                | j = 5, k = 3
  5  | 1  5  3 | a = a                | j = 6, k = 4
  6  | 1  6  4 | end                  | period = 2
     |         |                      | emit "an", "an", i = 5
  7  | 5  6  5 | end                  | emit "a"
```

## Visual: Pattern Detection

```
Processing "ababab":

i=0, j=1: s[1]='b' > s[0]='a' → extend
i=0, j=2: s[2]='a' = s[0]='a' → continue matching
i=0, j=3: s[3]='b' = s[1]='b' → continue matching
i=0, j=4: s[4]='a' = s[0]='a' → continue matching
i=0, j=5: s[5]='b' = s[1]='b' → continue matching
End of string

We found "ab" repeated 3 times!
Output: ["ab", "ab", "ab"]

Key insight: When s[j] = s[k], we're detecting repetition.
The Lyndon word is s[i..i+period], repeated as many times as it fits.
```

## Why the Period Is `j - k`

```
At the moment we stop scanning, we know:
  - s[i..j) is the current candidate block
  - k points inside that block where the comparison last matched

So the distance (j - k) is the length of the repeating pattern.

Example: s = "abcabcab"
Indices:   0 1 2 3 4 5 6 7
Chars:     a b c a b c a b

At the end of the scan:
  i = 0, j = 8, k = 5
  period = j - k = 3

That means the Lyndon word is "abc" and we can emit it repeatedly:
  "abc" + "abc" + "ab"
```

## API

- `duval_factorization(s)` returns an array of factors (strings)

## Example Usage

```mbt check
///|
test "duval banana" {
  let factors = @duval_lyndon.duval_factorization("banana")
  inspect(factors, content="[\"b\", \"an\", \"an\", \"a\"]")
}
```

```mbt check
///|
test "duval ababab" {
  let factors = @duval_lyndon.duval_factorization("ababab")
  inspect(factors, content="[\"ab\", \"ab\", \"ab\"]")
}
```

## More Examples

```mbt check
///|
test "duval single char" {
  let factors = @duval_lyndon.duval_factorization("aaaa")
  inspect(factors, content="[\"a\", \"a\", \"a\", \"a\"]")
}
```

```mbt check
///|
test "duval already lyndon" {
  let factors = @duval_lyndon.duval_factorization("abcd")
  inspect(factors, content="[\"abcd\"]")
}
```

```mbt check
///|
test "duval repeating with tail" {
  let factors = @duval_lyndon.duval_factorization("abcabcab")
  inspect(factors, content="[\"abc\", \"abc\", \"ab\"]")
}
```

```mbt check
///|
test "duval decreasing" {
  let factors = @duval_lyndon.duval_factorization("dcba")
  inspect(factors, content="[\"d\", \"c\", \"b\", \"a\"]")
}
```

```mbt check
///|
test "duval mixed tail" {
  let factors = @duval_lyndon.duval_factorization("cabca")
  inspect(factors, content="[\"c\", \"abc\", \"a\"]")
}
```

```mbt check
///|
test "duval empty" {
  let factors = @duval_lyndon.duval_factorization("")
  inspect(factors, content="[]")
}
```

## Common Applications

### 1. Minimum Rotation
```
Duval's algorithm is a building block for minimum-rotation routines.
A common approach is to run Duval on s + s and pick the smallest
starting position within the first n characters, then take length n.

Example: s = "baca"
All rotations:
  baca, acab, caba, abac
Minimum rotation is "abac".
```

### 2. Lexicographically Smallest Suffix
```
Related to Lyndon factorization through the "standard decomposition"
Used in suffix array construction.
```

### 3. String Periodicity
```
If the factorization is L repeated k times,
the string has period |L|.
```

### 4. Combinatorics on Words
```
Lyndon words are the "prime" building blocks of strings.
Used in bijective BWT, necklace enumeration, etc.
```

## Edge Cases to Remember

```
Empty string:
  "" -> []

All equal characters:
  "aaaa" -> ["a", "a", "a", "a"]

Strictly decreasing:
  "dcba" -> ["d", "c", "b", "a"]

Already Lyndon:
  "abcd" -> ["abcd"]
```

## Properties of Lyndon Factorization

```
1. Uniqueness: Every string has exactly one Lyndon factorization
   with non-increasing factors.

2. Concatenation: If u < v are Lyndon words, then uv is Lyndon.

3. Counting: There are (1/n) Σ μ(d) * k^(n/d) Lyndon words
   of length n over alphabet of size k.

4. Relation to suffix array: The Lyndon factorization can be
   computed from the suffix array, and vice versa.
```

## Complexity Analysis

| Operation | Time |
|-----------|------|
| Factorization | O(n) |
| Space | O(n) for output |

## Duval's Algorithm vs Other Approaches

| Method | Time | Use Case |
|--------|------|----------|
| **Duval** | O(n) | Lyndon factorization |
| Booth | O(n) | Minimum rotation only |
| Suffix Array | O(n log n) | More general queries |

**Choose Duval when**: You need the full Lyndon factorization or related string properties.

## Implementation Notes

- The algorithm is online: processes characters left to right
- Three-pointer technique: i (block start), j (scan), k (compare)
- When s[j] > s[k]: extend the current run
- When s[j] = s[k]: continue comparing within the period
- When s[j] < s[k]: output complete Lyndon words, restart
- Handle empty string and single characters as edge cases
- This implementation slices with a StringBuilder to avoid repeated substring copies
- Comparisons are by String code units (usual lexicographic order for ASCII)
