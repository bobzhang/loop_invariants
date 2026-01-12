# Persistent Fenwick Tree

Persistent BIT with point updates and prefix/range sums.

## Example

```mbt check
///|
test "persistent fenwick" {
  let fw0 = @challenge_persistent_fenwick.make(5)
  let fw1 = @challenge_persistent_fenwick.add(fw0, 0, 3)
  let fw2 = @challenge_persistent_fenwick.add(fw1, 2, 4)
  let fw3 = @challenge_persistent_fenwick.add(fw2, 4, 1)
  inspect(@challenge_persistent_fenwick.prefix_sum(fw3, 2), content="7")
  inspect(@challenge_persistent_fenwick.range_sum(fw3, 1, 4), content="5")
  inspect(@challenge_persistent_fenwick.prefix_sum(fw0, 4), content="0")
  inspect(@challenge_persistent_fenwick.length(fw3), content="5")
}
```

## Another Example

```mbt check
///|
test "persistent fenwick another" {
  let fw0 = @challenge_persistent_fenwick.make(4)
  let fw1 = @challenge_persistent_fenwick.add(fw0, 1, 5)
  let fw2 = @challenge_persistent_fenwick.add(fw1, 3, 2)
  inspect(@challenge_persistent_fenwick.prefix_sum(fw2, 1), content="5")
  inspect(@challenge_persistent_fenwick.range_sum(fw2, 1, 3), content="7")
}
```
