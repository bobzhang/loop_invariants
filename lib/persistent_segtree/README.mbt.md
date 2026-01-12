# Persistent Segment Tree

## Overview

A **Persistent Segment Tree** preserves all previous versions after updates.
Each update creates a new version by copying only the modified path, enabling
queries on any historical state of the data.

- **Update**: O(log n), creates new version
- **Query**: O(log n), on any version
- **Space**: O(log n) per update

## The Key Insight

```
Only copy nodes along the path to the update position.
Share all other nodes between versions!

Update at index 3 (version 1 → version 2):

Version 1:         Version 2:
    [0-7]              [0-7]' ← new root
    /    \            /    \
 [0-3]  [4-7]     [0-3]' [4-7] ← share [4-7]
 /   \            /   \
[0-1][2-3]     [0-1][2-3]' ← share [0-1]
     /   \          /   \
   [2]   [3]      [2]   [3]' ← new value

Nodes copied: 4 (path to leaf)
Nodes shared: rest of tree
```

## Algorithm Walkthrough

```
Initial array: [1, 2, 3, 4, 5, 6, 7, 8] (version 0)

Version 0:
        [36]          ← sum of all
       /    \
    [10]    [26]
    /  \    /  \
  [3]  [7][11][15]
  / \  / \ / \ / \
 1  2 3  4 5 6 7  8

Update index 2 to value 10 (version 1):
  Path: root → left → right → leaf[2]
  New sum at leaf: 10
  Update ancestors: [14], [17], [43]

Version 1:
        [43]'         ← new root
       /    \
    [17]'   [26]     ← share [26]
    /   \
  [3]   [14]'        ← share [3]
  / \   /  \
 1  2 10   4         ← new leaf

Both versions accessible:
  query(version=0, 0, 7) = 36
  query(version=1, 0, 7) = 43
```

## Visual: Version Tree

```
Multiple updates create a tree of versions:

    v0 ──update(2, 10)──→ v1 ──update(5, 0)──→ v2
     │
     └──update(0, 5)──→ v3 ──update(7, 1)──→ v4

v0: [1,2,3,4,5,6,7,8]
v1: [1,2,10,4,5,6,7,8]
v2: [1,2,10,4,5,0,7,8]
v3: [5,2,3,4,5,6,7,8]  (branched from v0)
v4: [5,2,3,4,5,6,7,1]

Each version is independently queryable!
```

## Example Usage

```mbt nocheck
// Build initial segment tree (version 0)
let arr = [1, 2, 3, 4, 5, 6, 7, 8]
let versions = [PersistentSegTree::build(arr)]

// Update creates new version
versions.push(versions[0].update(2, 10))  // version 1
versions.push(versions[1].update(5, 0))   // version 2

// Query any version
versions[0].query(0, 3)  // sum [1,2,3,4] = 10
versions[1].query(0, 3)  // sum [1,2,10,4] = 17
versions[2].query(0, 7)  // sum of v2 = 37
```

## Common Applications

### 1. Kth Element in Range (Online)
```
Classic problem: Kth smallest in array[l..r]

Solution:
1. Sort array, get ranks
2. Build persistent segtree on ranks
3. Version i = prefix tree after inserting first i elements
4. Query(l, r, k) = difference between versions r and l-1

Time: O(log n) per query
```

### 2. Time-Travel Queries
```
Array changes over time, query past states.
Version t = state after t-th update.
Query(version=t, l, r) gives historical range sum.
```

### 3. 2D Range Queries
```
Count points in rectangle [x1, x2] × [y1, y2].
Version x = points with x-coordinate ≤ x.
Query difference between version x2 and x1-1.
```

### 4. Tree Path Queries
```
Query path from u to v in tree.
Root-to-u versions enable path extraction via LCA.
```

## Complexity Analysis

| Operation | Time | Space |
|-----------|------|-------|
| Build | O(n) | O(n) |
| Update (create version) | O(log n) | O(log n) |
| Query (any version) | O(log n) | O(1) |
| Total for k updates | O(k log n) | O(n + k log n) |

## Persistent Segtree vs Regular Segtree

| Feature | Regular | Persistent |
|---------|---------|------------|
| Query | O(log n) | O(log n) |
| Update | O(log n) | O(log n) |
| Space | O(n) | O(n + k log n) |
| History | Lost | Preserved |
| Branching | No | Yes |

**Choose Persistent Segment Tree when**: You need to query historical states.

## Space Optimization

```
Without garbage collection:
  All O(n + k log n) nodes stay in memory

With garbage collection:
  Only reachable versions kept
  Reference counting or tracing GC

For offline problems:
  Process queries in order
  Delete unneeded versions
```

## Combining with Other Techniques

```
Persistent + Lazy:
  Store lazy tags in nodes
  Copy lazy tag during update
  More complex, rarely needed

Persistent + Merge Sort Tree:
  Each node stores sorted list of subtree values
  Very powerful for range rank queries
```

## Implementation Notes

- Store version roots in array/vector
- Each node: left_child, right_child, value (pointers/indices)
- Use implicit tree (no explicit indices) or explicit
- For sum tree: update ancestors after creating new leaf
- Be careful with memory: persistent trees can use lots of RAM
- Consider using object pool for node allocation

