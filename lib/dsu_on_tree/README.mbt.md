# DSU on Tree (Small-to-Large)

## Overview

**DSU on tree** is a technique for answering subtree queries on trees. It keeps
one global frequency structure and reuses the heavy child’s data to avoid
rebuilding counts from scratch for every node.

This package demonstrates the classic problem:

> For each node, compute the **sum of colors** that achieve the **maximum
> frequency** inside its subtree.

- **Time**: O(n log n) using a Map for counts
- **Space**: O(n)

## Key Idea

For a node `u`:

1. Solve all light children with `keep = false` (their data is discarded).
2. Solve the heavy child with `keep = true` (its data is kept).
3. Add all light subtrees and `u` into the current structure.
4. Record the answer for `u`.
5. If `keep = false`, clear the structure (it contains exactly subtree `u`).

## Example

```mbt check
///|
test "dsu on tree example" {
  let adj : Array[Array[Int]] = []
  for _ in 0..<5 {
    adj.push([])
  }
  adj[0].push(1)
  adj[1].push(0)
  adj[0].push(2)
  adj[2].push(0)
  adj[1].push(3)
  adj[3].push(1)
  adj[1].push(4)
  adj[4].push(1)
  let colors : Array[Int] = [1, 2, 1, 2, 3]
  let result = @dsu_on_tree.subtree_color_mode_sum(adj, colors)
  inspect(result, content="[3, 2, 1, 2, 3]")
}
```
