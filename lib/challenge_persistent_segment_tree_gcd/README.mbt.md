# Persistent Segment Tree (GCD)

Point updates with range GCD queries.

## Example

```mbt check
///|
test "persistent segment tree gcd" {
  let arr = [6, 10, 15, 25][:]
  let root = @challenge_persistent_segment_tree_gcd.build(arr, 0, arr.length())
  let updated = @challenge_persistent_segment_tree_gcd.apply_updates(
    root,
    arr.length(),
    [(2, 5), (0, 9)][:],
  )
  inspect(
    @challenge_persistent_segment_tree_gcd.range_gcd(
      root,
      0,
      arr.length(),
      0,
      4,
    ),
    content="1",
  )
  inspect(
    @challenge_persistent_segment_tree_gcd.range_gcd(
      updated,
      0,
      arr.length(),
      0,
      4,
    ),
    content="1",
  )
  inspect(
    @challenge_persistent_segment_tree_gcd.gcd_value(updated),
    content="1",
  )
}
```
