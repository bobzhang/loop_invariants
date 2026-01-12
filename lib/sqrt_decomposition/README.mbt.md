# Sqrt Decomposition

## Overview

**Sqrt Decomposition** divides an array into blocks of size √n, trading off
between update and query time. Each block stores precomputed aggregate values,
enabling O(√n) for both operations.

- **Query**: O(√n)
- **Update**: O(1) to O(√n)
- **Space**: O(n)

## The Key Insight

```
Split array into √n blocks of size √n each.
Each block maintains its aggregate (sum, min, max, etc.).

Array: [1, 2, 3, 4, 5, 6, 7, 8, 9]  (n = 9, block size = 3)

Block 0: [1, 2, 3]  sum = 6
Block 1: [4, 5, 6]  sum = 15
Block 2: [7, 8, 9]  sum = 24

Query [1, 7]:
  - Partial block 0: just elements 2, 3 (indices 1-2)
  - Full block 1: use precomputed sum = 15
  - Partial block 2: just elements 7 (index 6)
  Result: (2 + 3) + 15 + 7 = 27
```

## Query Algorithm

```
Query range [l, r]:

  ┌─────┬─────┬─────┬─────┬─────┐
  │  0  │  1  │  2  │  3  │  4  │  blocks
  └─────┴─────┴─────┴─────┴─────┘
       l           r
       ↓           ↓
  [   |×××|█████|█████|××   ]

  × = partial block (iterate element by element)
  █ = full block (use precomputed aggregate)

for i in l to end_of_first_block:
    result += arr[i]           // O(√n) at most

for block in first_full_block to last_full_block:
    result += block_sum[block] // O(√n) blocks

for i in start_of_last_block to r:
    result += arr[i]           // O(√n) at most
```

## Update Algorithm

```
Point update at index i:

1. Update the element: arr[i] = new_value
2. Recompute block aggregate:
   block_sum[i / block_size] = sum of elements in block

Time: O(√n) to recompute block sum
      (or O(1) if we track delta: new_sum = old_sum - old_val + new_val)
```

## Algorithm Walkthrough

```
Array: [1, 2, 3, 4, 5, 6, 7, 8, 9]
Block size: 3
Block sums: [6, 15, 24]

Query(1, 7):
  Block of index 1: 0 (partial)
  Block of index 7: 2 (partial)

  Left partial (block 0, indices 1-2): 2 + 3 = 5
  Full blocks (block 1): 15
  Right partial (block 2, index 6-7): 7 + 8 = 15

  Answer: 5 + 15 + 15 = 35

Update(4, 10):  // Change arr[4] from 5 to 10
  Block of index 4: 1
  Old block sum: 15
  Delta: 10 - 5 = 5
  New block sum: 15 + 5 = 20

  Block sums: [6, 20, 24]
```

## Example Usage

```mbt check
///|
test "sqrt decomposition example" {
  let arr : Array[Int64] = [1L, 2L, 3L, 4L, 5L]
  let sd = @sqrt_decomposition.SqrtSum::new(arr)
  inspect(sd.query(1, 3), content="9")
  sd.update(2, 10)
  inspect(sd.query(1, 3), content="16")
}
```

## Common Applications

### 1. Range Sum Queries
```
Query sum of [l, r] with point updates.
Simpler alternative to Fenwick/Segment tree.
```

### 2. Mo's Algorithm
```
Process offline queries by ordering them.
Move query endpoints √n times on average.
Total: O((n + q)√n) for q queries.
```

### 3. Heavy-Light in Blocks
```
Split path into √n pieces.
Each piece handled separately.
```

### 4. Block-Based String Matching
```
Divide text into blocks.
Check each block for pattern matches.
```

## Complexity Comparison

| Structure | Query | Point Update | Range Update |
|-----------|-------|--------------|--------------|
| **Sqrt Decomp** | O(√n) | O(1)-O(√n) | O(√n) |
| Fenwick Tree | O(log n) | O(log n) | O(log n)* |
| Segment Tree | O(log n) | O(log n) | O(log n) |

*Fenwick needs two trees for range update + range query

## Sqrt Decomposition vs Segment Tree

| Aspect | Sqrt Decomposition | Segment Tree |
|--------|-------------------|--------------|
| Time complexity | O(√n) | O(log n) |
| Implementation | Very simple | More complex |
| Constant factor | Very low | Higher |
| Lazy propagation | Simple | Tricky |
| Memory usage | O(n) | O(n) |

**Choose Sqrt Decomposition when**:
- Simple implementation is priority
- Constant factor matters (small n)
- Complex operations that are hard to segment-tree-ify

## Variations

```
Block-based deque:
  Maintain √n elements per block.
  Push/pop in O(√n) amortized.

2D sqrt decomposition:
  Split matrix into √n × √n blocks.
  Query/update in O(√n) per dimension.

Time-based sqrt:
  Process queries in batches of √q.
  Rebuild structure between batches.
```

## Implementation Notes

- Block size = ceil(√n) is common choice
- Tune block size empirically: try n^0.4 to n^0.6
- For min/max: block stores the minimum/maximum
- Lazy updates: store pending update per block
- Handle edge cases: last block may be smaller

