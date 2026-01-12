# Dinic Max Flow (Reference)

Compute the maximum flow in a directed graph using level graphs and blocking
flows.

## What it demonstrates

- BFS to build level graph
- DFS to send blocking flow
- Repeating until no augmenting path exists

## Pseudocode sketch

```mbt nocheck
while bfs_levels():
  while pushed = dfs_blocking():
    flow += pushed
```

## Example

```mbt check
///|
test "dinic max flow example" {
  let edges : Array[(Int, Int, Int64)] = [
    (0, 1, 3),
    (0, 2, 2),
    (1, 2, 1),
    (1, 3, 2),
    (2, 3, 4),
  ]
  let flow = @dinic.max_flow(4, edges[:], 0, 3)
  inspect(flow, content="5")
}
```

## Notes

- Time complexity: O(E * V^2) worst case, faster in practice
- This package is a reference implementation with invariants
