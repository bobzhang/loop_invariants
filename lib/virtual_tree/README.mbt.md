# Virtual Tree

## Overview

A **virtual tree** is the minimal tree that connects a subset of nodes in a
rooted tree. It is built by inserting the necessary LCAs (lowest common
ancestors) and connecting nodes by ancestor relationships in Euler order.

- **Time**: O(k log n), where k is the number of important nodes
- **Space**: O(n + k)

## Key Idea

1. Sort important nodes by DFS order (tin).
2. Add LCAs of consecutive nodes.
3. Sort again and remove duplicates.
4. Use a stack to connect nodes into a tree.

## Example

```mbt check
///|
test "virtual tree example" {
  let adj : Array[Array[Int]] = []
  for _ in 0..<6 {
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
  adj[2].push(5)
  adj[5].push(2)
  let vt = @virtual_tree.build_virtual_tree(adj, [3, 4, 5])
  inspect(vt.nodes, content="[0, 1, 3, 4, 5]")
}
```
