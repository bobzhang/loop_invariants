# Challenge: Mo's Algorithm (Range Sum)

Offline range sums by sorting queries into blocks.

## Example

```mbt check
///|
test "mo example" {
  let arr : Array[Int] = [1, 2, 3, 4, 5]
  let qs : Array[(Int, Int)] = [(0, 3), (1, 4), (2, 5), (0, 5)]
  let ans = @challenge_mo_algorithm_sum.mo_range_sum(arr[:], qs[:])
  inspect(ans, content="[6, 9, 12, 15]")
}
```

## Another Example

```mbt check
///|
test "mo example small" {
  let arr : Array[Int] = [2, 4, 6, 8]
  let qs : Array[(Int, Int)] = [(0, 2), (1, 3), (0, 4)]
  let ans = @challenge_mo_algorithm_sum.mo_range_sum(arr[:], qs[:])
  inspect(ans, content="[6, 10, 20]")
}
```
