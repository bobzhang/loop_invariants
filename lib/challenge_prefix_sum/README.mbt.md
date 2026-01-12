# Challenge: Prefix Sum Array

Build prefix sums so any range sum can be answered in O(1) after O(n)
preprocessing.

## What you learn

- Turning a running sum into a reusable prefix array
- Using `prefix[r+1] - prefix[l]` for inclusive ranges
- Simple loop invariants for accumulation

## Pseudocode sketch

```mbt nocheck
///|
let prefix = build_prefix_sum(arr)

///|
let sum_lr = prefix[r + 1] - prefix[l]
```

## Example

```mbt check
///|
test "prefix sum basic" {
  let arr : Array[Int] = [2, -1, 3, 0]
  let prefix = @challenge_prefix_sum.build_prefix_sum(arr[:])
  inspect(prefix, content="[0, 2, 1, 4, 4]")
  inspect(@challenge_prefix_sum.range_sum(prefix[:], 1, 2), content="2")
}
```

## Another Example

```mbt check
///|
test "prefix sum full range" {
  let arr : Array[Int] = [5, 5, 5]
  let prefix = @challenge_prefix_sum.build_prefix_sum(arr[:])
  inspect(@challenge_prefix_sum.range_sum(prefix[:], 0, 0), content="5")
  inspect(@challenge_prefix_sum.range_sum(prefix[:], 0, 2), content="15")
}
```

## Notes

- Preprocessing: O(n)
- Range query: O(1)
