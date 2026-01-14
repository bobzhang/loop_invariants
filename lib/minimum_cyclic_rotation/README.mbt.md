# Minimum Cyclic Rotation (Booth's Algorithm)

## Overview

The **minimum cyclic rotation** of a string is the lexicographically smallest
rotation. Booth's algorithm finds it in O(n) time by comparing candidate
rotations without generating all of them.

- **Time**: O(n)
- **Space**: O(n)
- **Output**: Index of the minimum rotation

## The Key Insight

```
A string of length n has n rotations:
  "baca" → "baca", "acab", "caba", "abac"

Naive: Generate all rotations, sort → O(n² log n)

Booth's insight: Compare two candidates simultaneously
  - Maintain two candidate start positions (i, j)
  - Compare characters at matching positions
  - Skip dominated candidates using failure information

Only O(n) comparisons needed!
```

## Understanding Cyclic Rotations

```
String: "baca" (length 4)

Rotation 0: baca  (start at index 0)
Rotation 1: acab  (start at index 1)
Rotation 2: caba  (start at index 2)
Rotation 3: abac  (start at index 3)

Sorted: "abac" < "acab" < "baca" < "caba"

Minimum rotation starts at index 3!
```

## Algorithm Walkthrough

```
String s = "baca" (work with s+s = "bacabaca" for wraparound)

Initialize: i = 0, j = 1, k = 0

Step 1: Compare s[(i+k)%n] vs s[(j+k)%n]
        s[0] = 'b' vs s[1] = 'a'
        'b' > 'a' → i is worse, skip it
        i = max(i + k + 1, j + 1) = max(1, 2) = 2
        Reset k = 0

Step 2: i=2, j=1, k=0
        Compare s[2] vs s[1]
        s[2] = 'c' vs s[1] = 'a'
        'c' > 'a' → i is worse
        i = max(2 + 0 + 1, 1 + 1) = 3
        Reset k = 0

Step 3: i=3, j=1, k=0
        Compare s[3] vs s[1]
        s[3] = 'a' vs s[1] = 'a'
        Equal → extend k
        k = 1

Step 4: i=3, j=1, k=1
        Compare s[(3+1)%4] vs s[(1+1)%4]
        s[0] = 'b' vs s[2] = 'c'
        'b' < 'c' → j is worse
        j = max(1 + 1 + 1, 3 + 1) = 4
        But j >= n, so we're done

Winner: i = 3
Minimum rotation: "abac" (starting at index 3)
```

## Visual: Comparing Rotations

```
Comparing rotation starting at i=0 vs j=3:

Position:  0   1   2   3
           ↓   ↓   ↓   ↓
Rot i=0:   b   a   c   a
Rot j=3:   a   b   a   c
           ^
           First difference: 'b' > 'a'

Rotation j=3 is lexicographically smaller!
```

## Example Usage

```mbt check
///|
test "min rotation basic" {
  inspect(@minimum_cyclic_rotation.min_cyclic_rotation("baca"), content="abac")
  inspect(
    @minimum_cyclic_rotation.min_cyclic_rotation_index("baca"),
    content="3",
  )
}
```

## More Examples

```mbt check
///|
test "min rotation examples" {
  // Single character
  inspect(@minimum_cyclic_rotation.min_cyclic_rotation("a"), content="a")

  // Already minimum
  inspect(@minimum_cyclic_rotation.min_cyclic_rotation("abc"), content="abc")

  // Need to rotate
  inspect(@minimum_cyclic_rotation.min_cyclic_rotation("cab"), content="abc")

  // Repeated pattern
  inspect(@minimum_cyclic_rotation.min_cyclic_rotation("abab"), content="abab")
}
```

## Common Applications

### 1. String Canonicalization
```
Problem: Are two strings cyclic rotations of each other?

Solution:
  canon(s1) = min_rotation(s1)
  canon(s2) = min_rotation(s2)
  s1 and s2 are rotations iff canon(s1) == canon(s2)

Example:
  "abc" and "bca" → both canonicalize to "abc" → YES
  "abc" and "acb" → "abc" vs "acb" → NO
```

### 2. Necklace Problems
```
A necklace is an equivalence class of strings under rotation.
Minimum rotation gives the canonical representative.

Necklace of {"abc", "bca", "cab"} → representative "abc"
```

### 3. Circular String Comparison
```
Compare circular DNA sequences.
Align by minimum rotation, then compare.
```

### 4. Pattern Matching in Circular Strings
```
Find pattern in circular text:
  1. Compute min_rotation_index
  2. Search in linearized form
```

## Algorithm Insight: Why O(n)?

```
Key observation: Each position is visited at most twice.

When we advance i or j by k+1, we skip positions that
are guaranteed to be suboptimal.

If s[(i+k)%n] > s[(j+k)%n]:
  - All rotations starting at i, i+1, ..., i+k are worse
    than the rotation starting at j
  - So we can skip directly to i+k+1

Total increments to i and j: at most 2n
Total comparisons: at most 2n
Overall: O(n)
```

## Complexity Analysis

| Operation | Time |
|-----------|------|
| Find min rotation index | O(n) |
| Get rotated string | O(n) |
| Compare two cyclic strings | O(n) |

## Related Algorithms

| Algorithm | Purpose | Time |
|-----------|---------|------|
| **Booth's** | Min rotation | O(n) |
| Duval | Lyndon factorization | O(n) |
| KMP on s+s | Find rotation | O(n) |

## Implementation Notes

- Work with s+s (doubled string) for easy wraparound
- Or use modular indexing: s[(i+k) % n]
- Handle empty string and single character cases
- The algorithm is similar to failure function computation
- Can be adapted for maximum rotation by reversing comparisons

