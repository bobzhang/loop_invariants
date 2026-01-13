# Challenge: MST (Kruskal)

Minimum spanning tree via edge sorting and DSU.

## Core Idea

Sort edges by weight, then iterate and add an edge if it connects two different
components (using DSU/Union-Find). The sum of accepted edges is the MST weight.

## Example

```mbt check
///|
test "mst kruskal example" {
  let edges : Array[(Int, Int, Int)] = [
    (0, 1, 1),
    (1, 2, 2),
    (2, 3, 3),
    (0, 3, 10),
  ]
  let total = @challenge_mst_kruskal.mst_weight(4, edges[:])
  inspect(total, content="Some(6)")
}
```

## Another Example

```mbt check
///|
test "mst kruskal disconnected" {
  let edges : Array[(Int, Int, Int)] = [(0, 1, 1)]
  let total = @challenge_mst_kruskal.mst_weight(3, edges[:])
  inspect(total, content="None")
}
```

## Notes

- If the graph is disconnected, no MST exists.
- Time complexity is O(E log E).

## Tips

- Sort edges once; DSU handles connectivity checks.
