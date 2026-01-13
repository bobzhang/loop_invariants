# Challenge: TSP (Bitmask DP)

Bitmask DP for minimum Hamiltonian cycle starting at node 0.

## Core Idea

Let `dp[mask][v]` be the minimum cost to start at 0, visit exactly the nodes in
`mask`, and end at `v`. Transitions add one new node at a time:

```
dp[mask | (1<<u)][u] = min(dp[mask][v] + dist[v][u])
```

## Example

```mbt check
///|
test "tsp example" {
  let dist : Array[Array[Int]] = [
    [0, 10, 15, 20],
    [10, 0, 35, 25],
    [15, 35, 0, 30],
    [20, 25, 30, 0],
  ]
  let ans = @challenge_bitmask_tsp.tsp_min_cycle(dist)
  inspect(ans, content="80")
}
```

## Another Example

```mbt check
///|
test "tsp triangle" {
  let dist : Array[Array[Int]] = [[0, 2, 4], [2, 0, 1], [4, 1, 0]]
  let ans = @challenge_bitmask_tsp.tsp_min_cycle(dist)
  inspect(ans, content="7")
}
```

## Notes

- Time complexity is O(n^2 * 2^n).
- This assumes a complete distance matrix.
