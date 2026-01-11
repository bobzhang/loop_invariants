# Min-Cost Max-Flow (Reference)

Compute a flow with minimum cost among all maximum flows, typically using
successive shortest augmenting paths.

## What it demonstrates

- Residual graph with costs
- SPFA/Dijkstra to find shortest augmenting paths
- Updating potentials and residual capacities

## Pseudocode sketch

```mbt nocheck
while shortest_path(source, sink):
  augment along path
  total_cost += path_cost * flow
```

## Notes

- Time complexity depends on shortest path method
- This package is a reference implementation with invariants
