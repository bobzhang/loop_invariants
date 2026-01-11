# Challenge: Euler Tour

Iterative DFS to compute entry and exit times for each node.

## Example

```mbt check
///|
test "euler tour example" {
  let edges : Array[(Int, Int)] = [(0, 1), (0, 2), (1, 3), (1, 4)]
  let (tin, tout, _) = @challenge_euler_tour.euler_tour(5, edges[:], 0)
  inspect(tin[0] < tout[0], content="true")
}
```

## Another Example

```mbt check
///|
test "euler tour order length" {
  let edges : Array[(Int, Int)] = [(0, 1), (1, 2)]
  let (_, _, order) = @challenge_euler_tour.euler_tour(3, edges[:], 0)
  inspect(order.length(), content="3")
}
```
