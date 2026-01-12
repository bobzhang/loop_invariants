# Persistent Segment Tree (Range Assign)

Range assignment with lazy tags and range sum queries.

## Example

```mbt check
///|
test "persistent segment tree assign" {
  let arr = [1, 2, 3, 4][:]
  let root = @challenge_persistent_segment_tree_assign.build(
    arr,
    0,
    arr.length(),
  )
  let updated = @challenge_persistent_segment_tree_assign.apply_updates(
    root,
    arr.length(),
    [(1, 3, 5), (0, 2, 0)][:],
  )
  inspect(
    @challenge_persistent_segment_tree_assign.range_sum(
      root,
      0,
      arr.length(),
      0,
      4,
    ),
    content="10",
  )
  inspect(
    @challenge_persistent_segment_tree_assign.range_sum(
      updated,
      0,
      arr.length(),
      0,
      4,
    ),
    content="9",
  )
  inspect(@challenge_persistent_segment_tree_assign.total(updated), content="9")
}
```

## Another Example

```mbt check
///|
test "persistent segment tree assign simple" {
  let arr = [1, 2, 3][:]
  let root = @challenge_persistent_segment_tree_assign.build(
    arr,
    0,
    arr.length(),
  )
  let updated = @challenge_persistent_segment_tree_assign.apply_updates(
    root,
    arr.length(),
    [(0, 2, 5)][:],
  )
  inspect(
    @challenge_persistent_segment_tree_assign.range_sum(
      root,
      0,
      arr.length(),
      0,
      3,
    ),
    content="6",
  )
  inspect(
    @challenge_persistent_segment_tree_assign.range_sum(
      updated,
      0,
      arr.length(),
      0,
      3,
    ),
    content="13",
  )
}
```
