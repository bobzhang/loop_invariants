# Challenge: MST (Prim)

Prim's algorithm (O(n^2)) over an adjacency list.

## Core Idea

Maintain a set of visited nodes and repeatedly add the cheapest edge that
connects a visited node to an unvisited node. This variant uses O(n^2)
selection instead of a heap.

## Example

```mbt check
///|
test "mst prim example" {
  let edges : Array[(Int, Int, Int)] = [
    (0, 1, 1),
    (1, 2, 2),
    (2, 3, 3),
    (0, 3, 10),
  ]
  let adj = @challenge_mst_prim.build_adj(4, edges[:])
  let total = @challenge_mst_prim.mst_weight(adj)
  inspect(total, content="Some(6)")
}
```

## Another Example

```mbt check
///|
test "mst prim disconnected" {
  let edges : Array[(Int, Int, Int)] = [(0, 1, 1)]
  let adj = @challenge_mst_prim.build_adj(3, edges[:])
  let total = @challenge_mst_prim.mst_weight(adj)
  inspect(total, content="None")
}
```

## Notes

- Time complexity is O(n^2) with dense graphs.
- Returns None when the graph is disconnected.
