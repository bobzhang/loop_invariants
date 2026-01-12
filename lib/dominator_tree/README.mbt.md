# Dominator Tree (Lengauer-Tarjan)

## Overview

In a directed graph with a start node `s`, a vertex **u dominates v** if every
path from `s` to `v` goes through `u`.

The **immediate dominator** `idom[v]` is the closest strict dominator of `v`.
Connecting `idom[v] -> v` forms the **dominator tree**.

This package implements the classic **Lengauer-Tarjan** algorithm.

- **Time**: O((V + E) * alpha(V))
- **Space**: O(V + E)

## Key Concepts

### 1. DFS Indexing
We number vertices by DFS order and work in that index space. This makes the
algorithm efficient and allows union-find with path compression.

### 2. Semi-Dominator (sdom)
For each vertex `v`, `sdom[v]` is the minimum DFS index reachable from `v`
by following any number of DFS-tree edges and at most one back edge.

### 3. Buckets
Vertices are grouped by their semi-dominator, then resolved in reverse DFS
order to compute `idom` candidates.

## Example

```
Graph:
0 -> 1 -> 2 -> 3 -> 4 -> 5
     \         \       /
      \-> 3     \-> 5

Dominators (root=0):
  idom[1] = 0
  idom[2] = 1
  idom[3] = 1
  idom[4] = 3
  idom[5] = 1
```

## Example Usage

```mbt check
///|
test "dominator tree example" {
  let edges : Array[(Int, Int)] = [
    (0, 1),
    (1, 2),
    (2, 3),
    (1, 3),
    (3, 4),
    (4, 5),
    (2, 5),
  ]
  let dom = @dominator_tree.build_dominator_tree(6, edges[:], 0).unwrap()
  inspect(dom.idom[3], content="1")
  inspect(dom.dominates(1, 5), content="true")
}
```

## Why It Works

The algorithm builds the dominator relation in two stages:

1. Compute `sdom` using union-find and a DFS tree.
2. Resolve `idom` by grouping nodes with the same `sdom` and correcting with
   a final pass.

The union-find structure maintains the best candidate ancestor for each node,
which makes the total work nearly linear.

## Applications

- Compiler optimization (control-flow graphs)
- Program analysis (dominance frontiers)
- SSA construction
- Network reachability reasoning
