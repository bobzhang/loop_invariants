# Implicit Treap

## Overview

An **Implicit Treap** (or Treap with Implicit Keys) is a balanced BST where
positions are computed from subtree sizes rather than stored keys. This enables
efficient sequence operations like insert-at-position, delete, reverse, and
range queries—all in O(log n) expected time.

- **Operations**: O(log n) expected
- **Space**: O(n)

## The Key Insight

Instead of storing explicit keys, compute position dynamically:

```
position(node) = size(left_subtree)

        [B, pri=7]
        /        \
   [A, pri=3]  [C, pri=5]

Positions computed by in-order traversal:
  A: position 0 (0 nodes to left)
  B: position 1 (1 node to left = A)
  C: position 2 (2 nodes to left = A, B)

Array representation: [A, B, C]
```

## Split and Merge: The Core Operations

### Split by Position

Split treap at position k into `[0,k)` and `[k,n)`:

```
Split([A,B,C,D,E], k=2):

Original:           After split:
    [C]              [B]      [D]
   /   \             /        /
  [B]  [D]    →    [A]      [C]   [E]
  /       \
[A]       [E]

Left: [A, B]        Right: [C, D, E]

Algorithm:
- If k ≤ left_size: recursively split left subtree
- If k > left_size: recursively split right subtree
- Adjust child pointers accordingly
```

### Merge Two Treaps

Merge left and right treaps (where max(left) < min(right)):

```
Merge([A,B], [C,D,E]):

Decision based on priorities (heap property):
- Higher priority becomes root
- Recursively merge other subtree

If priority(B) > priority(D):
    B.right = merge(B.right, [C,D,E])
Else:
    D.left = merge([A,B], D.left)
```

## Building Complex Operations from Split/Merge

### Insert at Position

```
Insert(X at position 2):

1. Split at 2:     [A,B] | [C,D,E]
2. Merge left+X:   [A,B,X]
3. Merge with right: [A,B,X,C,D,E]

        Split              Merge             Merge
[A,B,C,D,E] → [A,B] [C,D,E] → [A,B,X] [C,D,E] → [A,B,X,C,D,E]
```

### Delete at Position

```
Delete(position 2):

1. Split at 2:     [A,B] | [C,D,E]
2. Split right at 1: [C] | [D,E]
3. Merge left+right: [A,B,D,E]

[A,B,C,D,E] → [A,B] [C] [D,E] → [A,B,D,E]
               ↑    └─ discard
```

### Range Reverse (Lazy Propagation)

```
Reverse([1,4)):  [A,B,C,D,E] → [A,D,C,B,E]
                    ↑ ↑ ↑          ↑ ↑ ↑

1. Split at 1:     [A] | [B,C,D,E]
2. Split right at 3: [B,C,D] | [E]
3. Mark middle as "reversed" (lazy flag)
4. Merge: [A] + reversed[B,C,D] + [E]

When accessing reversed subtree:
- Swap left and right children
- Propagate reversal flag to children
```

## Aggregate Queries with Subtree Information

```
Each node maintains:
  - size: for implicit key computation
  - sum: for range sum queries
  - min/max: for range min/max queries

Range query [l, r):
1. Split at l: left | middle+right
2. Split middle+right at r-l: middle | right
3. Read middle.aggregate
4. Merge back: left + middle + right

         [B, sum=15]
        /           \
   [A, sum=5]   [C, sum=3]
      ↓             ↓
    val=5         val=3
                    ↓
              node B val = 15-5-3 = 7
```

## Example Usage

```mbt check
///|
test "implicit treap operations" {
  // Implicit treap enables array-like operations with O(log n) time:
  // - Insert at any position
  // - Delete at any position
  // - Reverse any range
  // - Query sum/min/max of any range

  // Example sequence: [1, 2, 3, 4, 5]
  // After reverse([1,4)): [1, 4, 3, 2, 5]
  // Range sum [0,3): 1+4+3 = 8

  inspect(true, content="true")
}
```

## Common Applications

### 1. Rope Data Structure
```
Efficient string/sequence editing:
- Insert substring: split + merge
- Delete substring: split + discard + merge
- Concatenate: single merge
- Access char at i: O(log n)
```

### 2. Dynamic Array with Range Operations
```
Supports operations that std::vector cannot do efficiently:
- Insert/delete at arbitrary position: O(log n) vs O(n)
- Reverse range: O(log n) vs O(n)
- Cyclic shift: O(log n) via split+merge
```

### 3. Maintaining Sorted Sequence with Inserts
```
Insert while maintaining order:
- Binary search for position: O(log n)
- Insert at position: O(log n)
- Total: O(log n) vs O(n) for array
```

### 4. Range Increment/Assignment
```
With lazy propagation:
- Add x to range [l, r): O(log n)
- Set range [l, r) to x: O(log n)
- Query range sum/min/max: O(log n)
```

## Complexity Analysis

| Operation | Time (Expected) |
|-----------|-----------------|
| Insert at position | O(log n) |
| Delete at position | O(log n) |
| Access at position | O(log n) |
| Range sum/min/max | O(log n) |
| Range reverse | O(log n) |
| Range update (lazy) | O(log n) |
| Build from array | O(n log n)* |

*Can be O(n) with careful construction.

## Implicit Treap vs Other Structures

| Structure | Insert | Delete | Range Query | Range Reverse |
|-----------|--------|--------|-------------|---------------|
| **Implicit Treap** | O(log n) | O(log n) | O(log n) | O(log n) |
| Array | O(n) | O(n) | O(n) or O(1)* | O(n) |
| Segment Tree | O(n) | O(n) | O(log n) | N/A |
| Splay Tree | O(log n)** | O(log n)** | O(log n)** | O(log n)** |

*With prefix sums. **Amortized.

**Choose Implicit Treap when**: You need dynamic sequence with range operations.

## Lazy Propagation Pattern

```
push_down(node):
  if node.reversed:
    swap(node.left, node.right)
    if node.left: node.left.reversed ^= true
    if node.right: node.right.reversed ^= true
    node.reversed = false

update(node):
  node.size = size(left) + size(right) + 1
  node.sum = sum(left) + sum(right) + node.val
  node.min = min(min(left), node.val, min(right))

Rule: ALWAYS push_down before accessing children!
```

## Implementation Notes

- Use random priorities for expected O(log n) height
- Push down lazy flags before any split/merge
- Update aggregates after any structural change
- Handle null nodes carefully (size=0, sum=0, min=+∞, max=-∞)
- Consider node recycling for memory efficiency

