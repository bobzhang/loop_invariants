# Challenge: Floyd-Warshall

All-pairs shortest paths by dynamic programming over intermediate vertices.

## Core Idea

- Allow intermediate vertices in increasing order `k = 0..n-1`.
- When `k` is fixed, paths may only use vertices `< k` internally.
- Each step improves `dist[i][j]` via `i -> k -> j`.

## What you learn

- Triple-nested DP with intermediate vertex k
- Relaxation: dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j])
- Detecting negative cycles via dist[i][i] < 0

## Pseudocode sketch

```mbt nocheck
for k in 0..n-1:
  for i in 0..n-1:
    for j in 0..n-1:
      dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j])
```

## Example

```mbt check
///|
test "floyd warshall basic" {
  let inf = 1_000_000_000
  let matrix : Array[Array[Int]] = [
    [0, 1, 10, inf],
    [inf, 0, 2, inf],
    [inf, inf, 0, 3],
    [inf, inf, inf, 0],
  ]
  let dist = @challenge_floyd_warshall.floyd_warshall(matrix, inf)
  inspect(dist[0][3], content="6")
}
```

## Another Example

```mbt check
///|
test "floyd warshall small" {
  let inf = 1_000_000_000
  let matrix : Array[Array[Int]] = [[0, 5, inf], [inf, 0, 1], [2, inf, 0]]
  let dist = @challenge_floyd_warshall.floyd_warshall(matrix, inf)
  inspect(dist[0][2], content="6")
  inspect(dist[2][1], content="7")
}
```

## Notes

- Time complexity: O(n^3)
- Space complexity: O(n^2)
