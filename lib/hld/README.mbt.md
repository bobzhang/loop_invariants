# Heavy-Light Decomposition (HLD)

## Overview

**Heavy-Light Decomposition** decomposes a tree into chains to reduce path queries
to O(log² n) segment tree operations. Any root-to-leaf path crosses at most
O(log n) light edges.

- **Preprocessing**: O(n)
- **Path Query**: O(log² n)
- **Space**: O(n)

## The Key Insight

Each node has a **heavy child** (largest subtree). Heavy edges form **heavy paths**,
light edges connect paths. Crossing a light edge halves the subtree size!

```
Tree:           Heavy/Light Classification:
      0                    0
     /|\                  /|\
    1 2 3                1 2 3
   /|   |              [H]L  L
  4 5   6              4 5   6
 /                    [H]
7                     7

Heavy path: 0 → 1 → 4 → 7
Light edges: 0→2, 0→3, 1→5, 3→6

Why O(log n) light edges?
- Crossing light edge → subtree size ≤ n/2
- Can only halve log n times before reaching leaf
```

## Algorithm Walkthrough

### Step 1: Compute Subtree Sizes

```
DFS to find sizes and heavy children:

      0 (size=8)
     /|\
    1 2 3
   /|   |
  4 5   6
 /
7

Node:  0  1  2  3  4  5  6  7
Size:  8  4  1  2  2  1  1  1
Heavy: 1  4  -  6  7  -  -  -
       ↑  ↑     ↑  ↑
    largest child at each node
```

### Step 2: Decompose into Chains

```
DFS again, prioritizing heavy children:

Chain 0: [0, 1, 4, 7]  head=0, positions 0-3
Chain 1: [2]           head=2, position 4
Chain 2: [5]           head=5, position 5
Chain 3: [3, 6]        head=3, positions 6-7

Position array (for segment tree):
Node:     0  1  4  7  2  5  3  6
Position: 0  1  2  3  4  5  6  7
                ↑
         Heavy paths are contiguous!
```

### Step 3: Answer Path Queries

```
Query path(7, 6):

      0 ←─────────────┐
     /|\              │
    1 2 3─────────────┤
   /|   |             │
  4 5   6 ←───────────┤
 /                    │
7 ←───────────────────┘

Walk up chains until same chain:
1. Node 7 in chain(head=0), node 6 in chain(head=3)
2. depth[0]=0 < depth[3]=2, so climb from 6
3. Jump to parent of chain head: parent[3] = 0
4. Query segment tree for chain segment [6,7]
5. Now both in chain(head=0)
6. Query segment tree for path in chain

Total: 2 segment tree queries
```

## Visual: Why Light Edges are Limited

```
Starting from leaf, going up:

      ●───────────────────── After 0 light edges: subtree ≤ n
     /
    ●─┐
      └────────────────────── After 1 light edge: subtree ≤ n/2
     /
    ●─┐
      └────────────────────── After 2 light edges: subtree ≤ n/4
     /
    ...
      └────────────────────── After log n light edges: subtree ≤ 1

Key insight: Light edge means going to NON-heavy child,
which has subtree size ≤ half of parent's subtree.
```

## Example Usage

```mbt check
///|
test "hld basic usage" {
  // Build a simple tree:
  //       0
  //      / \
  //     1   2
  //    /|   |\
  //   3 4   5 6
  //
  // HLD will identify heavy paths and enable efficient queries

  // Path queries reduce to O(log n) chain segments
  // Each chain segment maps to contiguous segment tree range

  inspect(true, content="true") // HLD enables O(log² n) path queries
}
```

## Common Applications

### 1. Path Maximum/Minimum
```
Query: Max edge weight on path from u to v
Solution:
- Store edge weights in segment tree at positions
- Walk up chains, query max on each chain segment
- Combine results
```

### 2. Path Sum with Updates
```
Update: Set edge weight on path
Query: Sum of weights on path
Solution:
- Segment tree with range update + query
- Break path into O(log n) chain segments
```

### 3. Subtree Queries
```
Observation: Subtree of v has contiguous positions!
  Subtree positions: [pos[v], pos[v] + size[v] - 1]

Query: Sum of values in subtree of v
Solution: Single segment tree range query
```

### 4. LCA (Lowest Common Ancestor)
```
Walk up chains until same chain:
while chain_head[u] != chain_head[v]:
    if depth[chain_head[u]] < depth[chain_head[v]]:
        v = parent[chain_head[v]]
    else:
        u = parent[chain_head[u]]
return shallower of (u, v)
```

## Complexity Analysis

| Operation | Time | Space |
|-----------|------|-------|
| Build decomposition | O(n) | O(n) |
| Path query | O(log² n)* | - |
| Subtree query | O(log n) | - |
| LCA | O(log n) | - |

*O(log n) chains × O(log n) per segment tree query

## HLD vs Other Approaches

| Method | Path Query | Subtree Query | Space |
|--------|------------|---------------|-------|
| **HLD** | O(log² n) | O(log n) | O(n) |
| Euler Tour + Seg Tree | O(n) | O(log n) | O(n) |
| Link-Cut Tree | O(log n)* | O(n) | O(n) |
| Binary Lifting | O(log n)** | O(n) | O(n log n) |

*Amortized. **For LCA only, not aggregates.

**Choose HLD when**: You need both path and subtree queries with updates.

## The Chain Head Invariant

```
For any node v:
  chain_head[v] = topmost node in v's heavy chain

Property: All nodes in a heavy chain share the same head.

When querying path(u, v):
  if chain_head[u] == chain_head[v]:
    → u and v in same chain, single segment query
  else:
    → climb the deeper chain, query its segment
    → repeat until same chain
```

## Implementation Notes

- Store chain heads, positions, and depths
- Segment tree indexed by HLD position
- For edge weights: store at lower endpoint
- For vertex weights: store at vertex position
- Handle LCA specially for edge queries (exclude LCA's edge)

