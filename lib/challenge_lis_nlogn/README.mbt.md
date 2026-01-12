# Challenge: LIS Length

Patience sorting approach with binary search for longest increasing subsequence length.

## Example

```mbt check
///|
test "lis example" {
  let nums : Array[Int] = [3, 1, 2, 1, 8, 5, 6]
  let len = @challenge_lis_nlogn.lis_length(nums[:])
  inspect(len, content="4")
}
```

## Another Example

```mbt check
///|
test "lis classic" {
  let nums : Array[Int] = [10, 9, 2, 5, 3, 7, 101, 18]
  let len = @challenge_lis_nlogn.lis_length(nums[:])
  inspect(len, content="4")
}
```
