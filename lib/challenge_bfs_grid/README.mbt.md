# Challenge: BFS on a Grid

Shortest path on a grid with obstacles using breadth-first search.

## What you learn

- Level-order traversal to guarantee shortest paths
- Converting 2D coordinates to queue entries
- Boundary and obstacle checks

## Pseudocode sketch

```mbt nocheck
queue.push(start)
while queue not empty:
  pop front
  for each direction:
    if in bounds and not visited: enqueue
```

## Example

```mbt check
///|
test "bfs grid basic" {
  let grid : Array[Array[Int]] = [[0, 0, 0], [1, 1, 0], [0, 0, 0]]
  let dist = @challenge_bfs_grid.shortest_path_grid(grid, 0, 0, 2, 2)
  inspect(dist, content="Some(4)")
}
```

## Another Example

```mbt check
///|
test "bfs grid unreachable" {
  let grid : Array[Array[Int]] = [[0, 1], [1, 0]]
  let dist = @challenge_bfs_grid.shortest_path_grid(grid, 0, 0, 1, 1)
  inspect(dist, content="None")
}
```

## Notes

- Time complexity: O(R * C)
- Space complexity: O(R * C)
