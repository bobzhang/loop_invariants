# Challenge: Matrix Chain Multiplication

Dynamic programming for optimal multiplication order.

## Example

```mbt check
///|
test "matrix chain example" {
  let dims : Array[Int] = [10, 30, 5, 60]
  let cost = @challenge_matrix_chain.matrix_chain_min_cost(dims[:])
  inspect(cost, content="4500")
}
```
