# Skip List

## Overview

A **Skip List** is a probabilistic data structure that provides expected O(log n)
search, insertion, and deletion. It uses multiple layers of linked lists with
express lanes for faster traversal.

- **Search/Insert/Delete**: O(log n) expected
- **Space**: O(n) expected
- **Simplicity**: Much simpler than balanced trees!

## The Key Insight

```
A linked list with "express lanes" at multiple levels.
Higher levels skip more elements, like a subway express line.

Regular linked list: O(n) search
  1 → 2 → 3 → 4 → 5 → 6 → 7 → 8

Skip list with levels:
Level 2: 1 ─────────────→ 5 ─────────────→ NIL
Level 1: 1 ──→ 3 ──→ 5 ──→ 7 ──→ NIL
Level 0: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → NIL

Search for 6:
  Level 2: 1 → 5 (stop, next is NIL or > 6)
  Level 1: 5 → 7 > 6 (stop)
  Level 0: 5 → 6 ✓ Found!

Only 4 comparisons instead of 6!
```

## How Levels Are Assigned

```
Each node gets a random level:
  Level 1: always (probability 1)
  Level 2: probability 1/2
  Level 3: probability 1/4
  Level k: probability (1/2)^(k-1)

This gives expected O(log n) levels.

Coin flip procedure:
  level = 1
  while random() < 0.5:
    level++
  return level
```

## Search Algorithm

```
def search(key):
    node = head
    for level in range(max_level - 1, -1, -1):
        while node.forward[level] != None:
            if node.forward[level].key < key:
                node = node.forward[level]
            elif node.forward[level].key == key:
                return node.forward[level]
            else:
                break  # drop down a level
    return None  # not found

Key insight: Move right while smaller, drop down when blocked.
```

## Algorithm Walkthrough

```
Skip list:
Level 2: HEAD ─────→ 3 ─────────→ 7 ─────→ NIL
Level 1: HEAD ─→ 2 ─→ 3 ─→ 5 ─→ 7 ─→ NIL
Level 0: HEAD → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → NIL

Search for 5:
  Level 2: HEAD → 3 (3 < 5) → 7 (7 > 5, drop down)
  Level 1: 3 → 5 ✓ Found!

Insert 4:
  1. Search to find position (stop at 3 on each level)
  2. Flip coins: level = 2 (got lucky)
  3. Update pointers:
     Level 2: 3 → 4 → 7
     Level 1: 3 → 4 → 5
     Level 0: 3 → 4 → 5

After insert:
Level 2: HEAD ─────→ 3 ─→ 4 ─────→ 7 ─────→ NIL
Level 1: HEAD ─→ 2 ─→ 3 ─→ 4 ─→ 5 ─→ 7 ─→ NIL
Level 0: HEAD → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → NIL
```

## Example Usage

```mbt nocheck
// Create skip list
let sl = SkipList::new()

// Insert elements
sl.insert(3)
sl.insert(1)
sl.insert(4)
sl.insert(1)  // duplicates handled by implementation
sl.insert(5)

// Search
sl.contains(3)  // true
sl.contains(2)  // false

// Delete
sl.delete(4)

// Range query (if supported)
sl.range(2, 5)  // [3, 4, 5] or similar
```

## Common Applications

### 1. Ordered Set/Map
```
Alternative to balanced BST with simpler implementation.
Insert, delete, search all O(log n) expected.
```

### 2. Range Queries
```
Find all elements in [lo, hi]:
1. Search for lo
2. Traverse at level 0 until > hi
Time: O(log n + k) where k = result size
```

### 3. Concurrent Data Structures
```
Skip lists are easier to make lock-free than trees.
Each level can be locked independently.
Used in Java's ConcurrentSkipListMap.
```

### 4. Database Indexing
```
Redis uses skip lists for sorted sets.
Good balance of simplicity and performance.
```

## Complexity Analysis

| Operation | Expected | Worst Case |
|-----------|----------|------------|
| Search | O(log n) | O(n) |
| Insert | O(log n) | O(n) |
| Delete | O(log n) | O(n) |
| Space | O(n) | O(n log n) |

Worst case is very unlikely (requires adversarial randomness).

## Skip List vs Balanced Trees

| Feature | Skip List | AVL/Red-Black |
|---------|-----------|---------------|
| Implementation | Simple | Complex |
| Worst case | O(n) rare | O(log n) always |
| Cache locality | Poor | Better |
| Concurrent | Easy | Hard |
| Range queries | Natural | With augmentation |

**Choose Skip List when**: You want simplicity or concurrency.

## Probability Analysis

```
Expected number of levels: O(log n)
  - P(level ≥ k) = (1/2)^(k-1)
  - Expected max level ≈ log₂(n)

Expected search time: O(log n)
  - At each level, expected 2 nodes traversed
  - O(log n) levels × O(1) per level

Expected space: O(n)
  - Each node has expected 2 pointers (1 + 1/2 + 1/4 + ...)
  - Total: 2n pointers expected
```

## Variations

```
Deterministic Skip List:
  Use deterministic level assignment (1-2-3 skip list)
  Guarantees O(log n) worst case

Indexable Skip List:
  Store subtree sizes in forward pointers
  Support O(log n) "select k-th element"

Skip List Map:
  Store key-value pairs
  Skip list on keys, values in nodes
```

## Implementation Notes

- Use sentinel nodes (HEAD with max level) for simpler code
- Store update[] array during search for insert/delete
- Maximum level: typically log₂(expected n) + a few extra
- Use probability p = 1/2 or 1/4 (1/4 uses less space)
- For concurrent versions, use lock-free CAS operations
- Consider memory pool for node allocation

