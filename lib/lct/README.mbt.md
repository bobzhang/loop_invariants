# Link‑Cut Tree (Dynamic Trees)

## What It Solves

A **Link‑Cut Tree (LCT)** maintains a **forest of dynamic trees** where edges
can be added or removed, and path queries can be answered efficiently.

Operations (amortized O(log n)):

- `link(u, v)` — connect two trees
- `cut(u, v)` — remove an edge
- `connected(u, v)` — check if in same tree
- `path_sum(u, v)` or other path queries (if aggregates are stored)

Static trees can use HLD/LCA; LCT shines when the tree **changes** over time.

## Core Idea

LCT decomposes each tree into **preferred paths**, and each preferred path is
stored as a **splay tree** (an auxiliary tree). The preferred paths change
based on access patterns.

```
Original tree:              Preferred paths:
      1                        [1]
     /|\                       |
    2 3 4                      [3]
   /    |                      |
  5     6                 [2-5]   [4-6]

Access(6) makes the path 1‑3‑4‑6 preferred.
```

## How Access Works (The Key Operation)

`access(v)` rewires preferred paths so that the **entire path from v to root**
becomes one splay tree, with `v` at the root of that splay tree.

```
Before access(6):         After access(6):
  preferred paths           preferred path
   [1-2-5]                   [1-3-4-6]
   [3]                       [2-5]
   [4-6]
```

This is the core building block for link, cut, LCA, and path queries.

## Operations (High‑Level)

### Link(u, v)

```
make_root(u)
access(v)
attach u under v
```

The two trees merge into one.

### Cut(u, v)

```
make_root(u)
access(v)
if v.left == u: cut it
```

The tree splits into two.

### Connected(u, v)

```
access(u)
access(v)
If u now has any upward pointer, they were connected.
```

## Visual: Splay Tree vs Actual Tree

Splay rotations **do not** change the real tree topology. They only rearrange
auxiliary trees (preferred paths).

```
Actual tree:      Splay tree (preferred path order by depth)
     1                       1
    / \                     / \
   2   3                   2   3

Rotations change the splay tree shape, but not the actual tree edges.
```

## Example Usage

```mbt check
///|
test "dynamic forest" {
  let forest = @lct.DynamicForest::new(4)

  // 0-1-2   and 3 alone
  inspect(forest.link(0, 1), content="true")
  inspect(forest.link(1, 2), content="true")
  inspect(forest.connected(0, 2), content="true")
  inspect(forest.connected(0, 3), content="false")

  // Cut edge (1,2)
  inspect(forest.cut(1, 2), content="true")
  inspect(forest.connected(0, 2), content="false")
}
```

## Common Applications

### 1) Dynamic Connectivity

```
Edge insertions and deletions with fast connectivity queries.
```

### 2) Dynamic MST / Maximum Spanning Forest

```
When adding edges, detect cycles and remove a heavy edge.
LCT supports max‑edge queries on paths.
```

### 3) Dynamic LCA

```
access(u), access(v) -> the split point of paths gives LCA.
```

### 4) Path Aggregates

```
Store sum/min/max in each splay node and query on root‑to‑node path.
```

## Complexity

| Operation | Time (amortized) |
|-----------|-------------------|
| access | O(log n) |
| link | O(log n) |
| cut | O(log n) |
| connected | O(log n) |
| path queries | O(log n) |

## Common Pitfalls

- **Not a static tree**: LCT is for **dynamic** forests.
- **Amortized bounds**: worst‑case per op can be higher, but total is O(m log n).
- **Edge direction**: many LCT implementations treat edges as parent/child
  only after rerooting.
- **Lazy reversal**: required for `make_root` to reverse paths safely.

## LCT vs Other Structures

| Structure | Link/Cut | Path Query | Use Case |
|-----------|----------|------------|----------|
| Link‑Cut Tree | O(log n) | O(log n) | dynamic trees |
| HLD | N/A | O(log^2 n) | static trees |
| Euler Tour Tree | O(log n) | subtree queries | dynamic forests |

## Implementation Notes (This Package)

- `LinkCutTree` implements the full LCT with splay‑tree auxiliary nodes.
- `DynamicForest` wraps safe `link`, `cut`, `connected` for connectivity only.
- Path aggregates stored as `subtree_sum` on splay nodes.
- `make_root` uses a lazy reversal flag to flip preferred paths.
