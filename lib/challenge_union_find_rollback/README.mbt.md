# Challenge: Union-Find with Rollback

A disjoint-set union (DSU) that can undo merges, useful for offline queries
and divide-and-conquer on time.

## What you learn

- Logging parent/size changes
- Rolling back to a previous snapshot
- Keeping union by size without path compression

## Pseudocode sketch

```mbt nocheck
snap = dsu.snapshot()
if dsu.union(a, b):
  ...
dsu.rollback(snap)
```

## Example

```mbt check
///|
test "rollback dsu basic" {
  let dsu = @challenge_union_find_rollback.RollbackDSU::new(4)
  let _ = dsu.union(0, 1)
  let _ = dsu.union(2, 3)
  let snap = dsu.snapshot()
  let _ = dsu.union(1, 2)
  inspect(dsu.same(0, 3), content="true")
  dsu.rollback(snap)
  inspect(dsu.same(0, 3), content="false")
}
```

## Another Example

```mbt check
///|
test "rollback dsu nested snapshot" {
  let dsu = @challenge_union_find_rollback.RollbackDSU::new(3)
  let snap0 = dsu.snapshot()
  let _ = dsu.union(0, 1)
  let snap1 = dsu.snapshot()
  let _ = dsu.union(1, 2)
  inspect(dsu.same(0, 2), content="true")
  dsu.rollback(snap1)
  inspect(dsu.same(0, 2), content="false")
  dsu.rollback(snap0)
  inspect(dsu.same(0, 1), content="false")
}
```

## Notes

- Typical use: dynamic connectivity offline
- Path compression is avoided to allow rollback
