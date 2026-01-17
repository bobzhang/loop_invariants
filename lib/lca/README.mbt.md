# Lowest Common Ancestor (LCA) with Binary Lifting

## What LCA Answers

The **Lowest Common Ancestor** of two nodes `u` and `v` is the deepest node
that is an ancestor of both. It is the core primitive behind distance queries,
subtree checks, and many tree path algorithms.

This package uses **binary lifting**:

- **Preprocess**: O(n log n)
- **Query**: O(log n)
- **Space**: O(n log n)

## Visual Intuition

```
Tree:
          0
        / | \
       1  2  3
      / \
     4   5

LCA(4, 5) = 1
LCA(4, 2) = 0
LCA(4, 3) = 0
LCA(1, 5) = 1
```

The LCA is the last shared node on the two root‑to‑node paths.

## Binary Lifting in One Picture

For each node, precompute ancestors at powers of two:

```
up[v][0] = parent
up[v][1] = 2^1 ancestor
up[v][2] = 2^2 ancestor
...
```

Any jump by `k` levels is done by decomposing `k` into bits.

Example: jump 13 = 8 + 4 + 1

```
13 = (1101)_2
jump 2^3 -> jump 2^2 -> jump 2^0
```

## Step‑By‑Step Query

### 1) Equalize Depths

Bring the deeper node up to the same depth.

Example: `LCA(5, 2)`

```
Depth[5] = 3, Depth[2] = 1
Diff = 2 (binary 10)

Lift node 5 by 2:
  jump 2^1 -> 5 -> 1
Now both at depth 1: nodes 1 and 2
```

### 2) Jump Together

From the highest power down, if `up[u][k] != up[v][k]`, jump both up.

After this, the parent of either node is the LCA.

## Example Table

Tree:

```
    0
   / \
  1   2
 / \
3   4
/
5
```

Depth and ancestor table:

```
node:   0  1  2  3  4  5
up[][0]: -1 0  0  1  1  3
up[][1]: -1 -1 -1 0  0  1
up[][2]: -1 -1 -1 -1 -1 0
```

Now `LCA(5,4)`:

```
Depths: 5=3, 4=2 => lift 5 by 1 -> 3
Now nodes 3 and 4
Check from high k:
  k=1: up[3][1]=0, up[4][1]=0 (equal)
  k=0: up[3][0]=1, up[4][0]=1 (equal)
Result = up[3][0] = 1
```

## Common Operations Using LCA

### Distance Between Nodes

```
dist(u, v) = depth[u] + depth[v] - 2 * depth[LCA(u, v)]
```

### Ancestor Check

```
Is u ancestor of v?  LCA(u, v) == u
```

### k‑th Ancestor

Decompose `k` into powers of two and jump using `up[v][bit]`.

### Path Queries

Split by LCA and combine:

```
query(u, v) = combine(query(u, lca), query(lca, v))
```

## Weighted Trees (Distance Queries)

Store `dist_to_root[v]` during DFS:

```
dist(u, v) = dist_to_root[u] + dist_to_root[v]
          - 2 * dist_to_root[LCA(u, v)]
```

## Example Usage

```mbt check
///|
test "lca basic" {
  let edges : Array[(Int, Int)] = [(0, 1), (0, 2), (0, 3), (1, 4), (1, 5)]
  let lca = @lca.LCA::new(6, edges)
  inspect(lca.query(4, 5), content="1")
  inspect(lca.query(4, 2), content="0")
}
```

```mbt check
///|
test "lca distance via depths" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2), (1, 3)]
  let lca = @lca.LCA::new(4, edges)
  let l = lca.query(2, 3)
  let dist = lca.depth[2] + lca.depth[3] - 2 * lca.depth[l]
  inspect(dist, content="2")
}
```

## Common Pitfalls

- **Rooted tree**: LCA depends on a root (here root = 0).
- **Invalid nodes**: queries outside `[0..n-1]` return `-1`.
- **Disconnected graph**: this expects a tree, not a forest.
- **Log size**: use `ceil(log2(n)) + 1` for ancestor table height.

## Complexity

| Operation | Time | Space |
|----------|------|-------|
| Build | O(n log n) | O(n log n) |
| LCA query | O(log n) | O(1) extra |
| Distance query | O(log n) | O(1) extra |
| k‑th ancestor | O(log n) | O(1) extra |

## Binary Lifting vs Other Methods

| Method | Preprocess | Query | Notes |
|--------|------------|-------|------|
| Binary Lifting | O(n log n) | O(log n) | simple, fast |
| Euler Tour + RMQ | O(n) | O(1) | more complex |
| HLD | O(n) | O(log n) | if you already need HLD |

Binary lifting is usually the best balance of simplicity and speed.
