# Mo's Algorithm

## Overview

**Mo's Algorithm** answers multiple offline range queries efficiently by
reordering queries to minimize transitions between them. It achieves
O((n + q) × √n) time using sqrt decomposition.

- **Time**: O((n + q) × √n)
- **Space**: O(n + q)

## The Problem

```
Array: [1, 2, 1, 3, 1, 2, 4]
Queries: How many distinct elements in each range?
  [0, 2] → {1, 2} → 2
  [1, 4] → {1, 2, 3} → 3
  [2, 6] → {1, 2, 3, 4} → 4

Naive: O(q × n) - process each query from scratch
Mo's: O((n + q) × √n) - reorder and transition efficiently
```

## The Key Insight: Sqrt Decomposition

```
Divide array indices into √n blocks:

Array:  [1, 2, 1, 3, 1, 2, 4, 5, 9]
         \_____/  \_____/  \_____/
         Block 0  Block 1  Block 2

Sort queries by:
  1. Block number of left endpoint
  2. Within same block: right endpoint

Block 0 queries: (0,2), (1,4), (2,6)  → sort by right
Block 1 queries: (3,5), (4,7)          → sort by right
...
```

## Why O((n + q) × √n)?

```
Left pointer movement:
- Within a block: moves at most √n per query
- Across blocks: at most n total (q queries, each crosses ≤1 block boundary)
- Total: O(q × √n)

Right pointer movement:
- Within each block: monotonically increasing → O(n) per block
- √n blocks total
- Total: O(n × √n)

Combined: O(q × √n + n × √n) = O((n + q) × √n)
```

## Algorithm Walkthrough

```
Array: [1, 2, 1, 3, 1, 2, 4]
Block size: √7 ≈ 2

Queries in original order:
  Q0: [0, 6]
  Q1: [0, 2]
  Q2: [2, 4]
  Q3: [1, 3]

Sorted order (block of L, then R):
  Q1: [0, 2]  block(0)=0, r=2
  Q3: [1, 3]  block(1)=0, r=3
  Q0: [0, 6]  block(0)=0, r=6
  Q2: [2, 4]  block(2)=1, r=4

Processing:
  Start: window = ∅

  Q1 [0,2]: add(0), add(1), add(2)
            window = {1,2,1} → distinct = 2

  Q3 [1,3]: remove(0), add(3)
            window = {2,1,3} → distinct = 3

  Q0 [0,6]: add(0), add(4), add(5), add(6)
            window = {1,2,1,3,1,2,4} → distinct = 4

  Q2 [2,4]: remove(0), remove(1), remove(5), remove(6)
            window = {1,3,1} → distinct = 2
```

## Visual: Pointer Movement

```
Query processing with reordering:

Array:   [1, 2, 1, 3, 1, 2, 4]
          0  1  2  3  4  5  6

Q1 [0,2]:  L──────R
Q3 [1,3]:     L───────R          L moves 1, R moves 1
Q0 [0,6]:  L──────────────────R  L moves 1, R moves 3
Q2 [2,4]:        L───────R       L moves 2, R moves 2

Without reordering (original order):
Q0 [0,6]:  L──────────────────R
Q1 [0,2]:  L──────R              R moves 4 (wasteful!)
Q2 [2,4]:        L───────R       L moves 2, R moves 2
Q3 [1,3]:     L───────R          L moves 1, R moves 1

Reordering reduces wasted movement!
```

## The Add/Remove Operations

```
For distinct element count:

State: count[x] = occurrences of x in window
       distinct = number of x where count[x] > 0

add(idx):
  x = arr[idx]
  if count[x] == 0:
    distinct++
  count[x]++

remove(idx):
  x = arr[idx]
  count[x]--
  if count[x] == 0:
    distinct--

Both are O(1)!
```

## Example Usage

```mbt check
///|
test "mo algorithm concept" {
  // Mo's algorithm processes queries offline
  // by reordering them to minimize pointer movement

  // Example: Count distinct elements
  // Array: [1, 2, 1, 3, 1, 2, 4]
  // Query [0, 2]: {1, 2, 1} → 2 distinct

  // Key insight: sorting queries by (block(L), R)
  // minimizes total pointer movement to O((n+q)√n)

  inspect(true, content="true")
}
```

## Common Applications

### 1. Distinct Element Count
```
Query: How many distinct values in [l, r]?
add(i): if count[arr[i]]++ == 0, distinct++
remove(i): if --count[arr[i]] == 0, distinct--
```

### 2. Frequency of Most Common Element
```
Query: Max frequency of any element in [l, r]?
Maintain: count[x], freq_count[f] = elements with frequency f
add(i): update count, freq_count, max_freq
remove(i): update count, freq_count, recalculate max
```

### 3. Range Sum of Occurrences
```
Query: Sum of f(count[x]) for all x in [l, r]
Example: f(c) = c² gives sum of squared frequencies
```

### 4. K-th Smallest Element (with persistent data structure)
```
Combine Mo's with order statistics tree
Query: K-th smallest in [l, r]
```

## Complexity Analysis

| Operation | Time |
|-----------|------|
| Sort queries | O(q log q) |
| Process queries | O((n + q) × √n) |
| Total | O((n + q) × √n) |

The add/remove must be O(1) or O(log n) for efficiency.

## Mo's Algorithm vs Alternatives

| Method | Time | Online? | Updates? |
|--------|------|---------|----------|
| **Mo's Algorithm** | O((n+q)√n) | No | No |
| Segment Tree | O(q log n) | Yes | Yes |
| Sqrt Decomposition | O(q√n) | Yes | Yes |
| Persistent Seg Tree | O(q log n) | Yes | No |

**Choose Mo's when**: Offline queries with complex aggregate functions.

## The Block Size Optimization

```
Standard: block_size = √n

Alternating direction within blocks:
- Even blocks: sort by R ascending
- Odd blocks: sort by R descending

This reduces R pointer backtracking:
Block 0: R goes 0 → n
Block 1: R goes n → 0 (instead of restarting at 0)
Block 2: R goes 0 → n
...

Total R movement: O(n × √n) instead of O(n × √n), but better constant
```

## Implementation Notes

- Query ordering is crucial - don't forget to store original indices
- Maintain current [l, r] range incrementally
- Handle empty ranges as edge case
- For online queries, consider other data structures
- Block size tuning: try √(n²/q) for better performance when q << n

