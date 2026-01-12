# Challenge: Coordinate Compression

Map arbitrary values to a compact 0..k-1 range while preserving order.
Useful for replacing large IDs with dense indices.

## What you learn

- Sorting and deduplicating values
- Binary search to map each value to its rank
- Handling negative and large numbers uniformly

## Pseudocode sketch

```mbt nocheck
///|
let uniq = sort_and_unique(values)

///|
let idx = lower_bound(uniq, value)
```

## Example

```mbt check
///|
test "coordinate compress basic" {
  let values : Array[Int] = [100, 50, 100, -10]
  let (comp, uniq) = @challenge_coordinate_compress.coordinate_compress(
    values[:],
  )
  inspect(uniq, content="[-10, 50, 100]")
  inspect(comp, content="[2, 1, 2, 0]")
}
```

## Another Example

```mbt check
///|
test "coordinate compress duplicates" {
  let values : Array[Int] = [5, 5, 5]
  let (comp, uniq) = @challenge_coordinate_compress.coordinate_compress(
    values[:],
  )
  inspect(uniq, content="[5]")
  inspect(comp, content="[0, 0, 0]")
}
```

## Notes

- Preprocessing: O(n log n)
- Mapping each value: O(log n)
