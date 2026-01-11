# Challenge: TSP (Bitmask DP)

Bitmask DP for minimum Hamiltonian cycle starting at node 0.

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
