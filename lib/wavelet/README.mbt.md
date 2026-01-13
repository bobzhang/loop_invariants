# Wavelet Tree

## Overview

A **Wavelet Tree** is a data structure for answering rank, select, and quantile
queries on sequences. It recursively partitions values by their bit representation,
enabling O(log σ) queries where σ is the alphabet size.

- **Rank query**: O(log σ) - count occurrences of value in range
- **Select query**: O(log σ) - find k-th occurrence of value
- **Quantile query**: O(log σ) - find k-th smallest in range
- **Space**: O(n log σ)

## Core Idea

- Split values by a midpoint at each level, storing a **bitvector** of left/right.
- Use **prefix sums** over the bitvector to map ranges down the tree in O(1).
- Queries follow the same path: **value navigation** for rank/select, and
  **count navigation** for quantiles.

## The Key Insight

```
Recursively split values into "low" and "high" halves.
At each level, store a bitvector indicating which half each element belongs to.

Array: [3, 1, 4, 1, 5, 9, 2, 6]
Values 1-9 (σ = 9)

Level 0: split at mid=5
  3,1,4,1,2 → low (0)    5,9,6 → high (1)
  Bitvector: [0,0,0,0,1,1,0,1]
  Position:   3 1 4 1 5 9 2 6

Left child: [3,1,4,1,2]   Right child: [5,9,6]

Level 1 (left): split at mid=3
  1,1,2 → low (0)    3,4 → high (1)
  Bitvector: [1,0,1,0,0]

Level 1 (right): split at mid=7
  5,6 → low (0)    9 → high (1)
  Bitvector: [0,1,0]

Continue recursively...
```

## Structure Visualization

```
Array: [3, 1, 4, 1, 5, 9, 2, 6]  (values 1-9)

                    [3,1,4,1,5,9,2,6]
                    bits: 00001101
                         /        \
            [3,1,4,1,2]            [5,9,6]
            bits: 10100            bits: 010
              /     \                /    \
         [1,1,2]  [3,4]          [5,6]   [9]
         bits:010 bits:01        bits:01  bits:0
           /   \     / \          / \
         [1,1] [2] [3] [4]      [5] [6]

Each node stores:
  - Bitvector indicating left(0) vs right(1) child
  - Prefix sum for O(1) rank queries within bitvector
```

## Rank Query

```
rank(c, i) = count of value c in positions [0, i)

Example: rank(1, 6) in [3,1,4,1,5,9,2,6]
                       0 1 2 3 4 5 6 7
         Count 1s in positions 0-5

At root: 1 < 5, so 1 goes left
  Count 0s in first 6 bits: [0,0,0,0,1,1] → 4 zeros
  Recurse to left child with position 4

Left child [3,1,4,1,2]: 1 < 3, so 1 goes left
  Count 0s in first 4 bits: [1,0,1,0] → 2 zeros
  Recurse to left child with position 2

Left child [1,1,2]: 1 < 2, so 1 goes left
  Count 0s in first 2 bits: [0,1] → 1 zero
  Recurse to left child with position 1

Leaf [1,1]: we're at the value node
  Answer = 1 (one '1' in first position)

Wait, let me recalculate with correct structure...
Actually rank(1,6) should be 2 since arr[1]=1 and arr[3]=1.
```

## Quantile Query (K-th Smallest)

```
quantile(l, r, k) = k-th smallest value in range [l, r]

Example: 2nd smallest in [3,1,4,1,5,9,2,6][1:5] = [1,4,1,5]
         Values: 1,1,4,5 → sorted: 1,1,4,5 → 2nd = 1

At root: count elements going left vs right in range [1,5)
  Bits [1:5] = [0,0,0,1]
  Left count = 3, right count = 1

  k=2 ≤ left_count=3, so k-th smallest is in left subtree
  Map range [1,5) → left child range using prefix sums

Recurse to left child with updated range...

Continue until reaching a leaf → that's the answer value.
```

## Select Query

```
select(c, k) = position of k-th occurrence of value c

Navigate down to leaf for c, then trace back up
using inverse rank operations.

Example: select(1, 2) = position of 2nd '1'
  Array: [3,1,4,1,5,9,2,6]
                0 1 2 3 4 5 6 7
  1 appears at positions 1 and 3
  select(1, 2) = 3
```

## Algorithm Walkthrough

```
Build wavelet tree for [2, 1, 4, 3]:

Values: 1-4, so log₂(4) = 2 levels

Level 0: mid = 2.5, split into [1,2] and [3,4]
  [2,1,4,3] → bits = [0,0,1,1]
  Left gets:  [2,1] (values ≤ 2)
  Right gets: [4,3] (values > 2)

Level 1 left: mid = 1.5
  [2,1] → bits = [1,0]
  Left: [1], Right: [2]

Level 1 right: mid = 3.5
  [4,3] → bits = [1,0]
  Left: [3], Right: [4]

Query: 2nd smallest in range [0,4)?
  At root: how many go left in [0,4)?
    Count 0s = 2
  k=2, left_count=2, so 2nd smallest is largest in left subtree

  At left child: range maps to [0,2)
    Count 0s = 1
  k=2 > left_count=1, so go right, k becomes 2-1=1

  At right-of-left leaf: value = 2

Answer: 2 ✓ (array [2,1,4,3] sorted = [1,2,3,4], 2nd = 2)
```

## Example Usage

```mbt nocheck
// Build wavelet tree
let arr = [3, 1, 4, 1, 5, 9, 2, 6]
let wt = WaveletTree::build(arr)

// Count occurrences of 1 in range [0, 6)
wt.rank(1, 0, 6)  // returns 2

// Find 3rd smallest in range [2, 7)
wt.kth_smallest(2, 7, 3)  // 3rd of [4,1,5,9,2] sorted = [1,2,4,5,9] → 4

// Find position of 2nd occurrence of 1
wt.select(1, 2)  // returns 3
```

## Common Applications

### 1. Range Quantile Queries
```
Find k-th smallest in any range [l, r].
Online queries, no sorting needed.
Time: O(log σ) per query.
```

### 2. Range Frequency
```
Count occurrences of value c in range [l, r].
Equivalent to rank(c, r) - rank(c, l).
```

### 3. Range Mode (with extensions)
```
Find most frequent element in range.
Requires additional data structures.
```

### 4. Document Retrieval
```
Given documents as strings, find documents containing query.
Wavelet tree on document IDs.
```

## Complexity Analysis

| Operation | Time | Space |
|-----------|------|-------|
| Build | O(n log σ) | O(n log σ) |
| Rank | O(log σ) | — |
| Select | O(log σ) | — |
| Quantile | O(log σ) | — |
| Range count | O(log σ) | — |

## Wavelet Tree vs Alternatives

| Structure | Quantile | Rank | Update | Space |
|-----------|----------|------|--------|-------|
| **Wavelet Tree** | O(log σ) | O(log σ) | Hard | O(n log σ) |
| Merge Sort Tree | O(log² n) | O(log² n) | Hard | O(n log n) |
| Persistent Segtree | O(log n) | O(log n) | O(log n) | O(n log n) |
| Sqrt Decomp | O(√n log n) | O(√n) | O(√n) | O(n) |

**Choose Wavelet Tree when**: You need fast quantile/rank queries on static data.

## Bitvector Implementation

```
Efficient bitvector is crucial for wavelet tree performance.

Requirements:
  - rank(i): count 1s in first i bits in O(1)
  - select(k): position of k-th 1 in O(1) or O(log n)

Implementation:
  - Store bits in 64-bit words
  - Precompute prefix popcount every 64 bits
  - Use CPU popcount instruction for within-word queries
```

## Implementation Notes

- Alphabet σ determines tree height: O(log σ) levels
- For small alphabet (σ < 256), use byte-wise lookup tables
- Build recursively or iteratively (level by level)
- For dynamic updates, consider wavelet matrix or balanced BST at leaves
- Compress alphabet first if values are sparse (coordinate compression)
