# Challenge: Bitmask DP (TSP)

Solve the traveling salesman problem for small n by DP over subsets.

## What you learn

- Encoding visited sets as bitmasks
- Transitioning from (mask, u) to (mask | 1<<v, v)
- Closing the tour by returning to the start

## Pseudocode sketch

```mbt nocheck
for mask in 1..(1<<n)-1:
  for u in 0..n-1:
    for v in 0..n-1:
      if v not in mask:
        dp[mask|1<<v][v] = min(dp[mask|1<<v][v], dp[mask][u] + dist[u][v])
```

## Example

```mbt check
///|
test "bitmask dp tsp basic" {
  let inf = 1_000_000
  let dist : Array[Array[Int]] = [
    [0, 1, 3, 4],
    [1, 0, 2, 5],
    [3, 2, 0, 6],
    [4, 5, 6, 0],
  ]
  let best = @challenge_bitmask_dp.tsp_min_cycle(dist, inf)
  inspect(best, content="13")
}
```

## Another Example

```mbt check
///|
test "bitmask dp tsp triangle" {
  let inf = 1_000_000
  let dist : Array[Array[Int]] = [[0, 2, 4], [2, 0, 1], [4, 1, 0]]
  let best = @challenge_bitmask_dp.tsp_min_cycle(dist, inf)
  inspect(best, content="7")
}
```

## Notes

- Time complexity: O(n^2 * 2^n)
- Works for n <= ~20 in practice
