# Union-Find (Disjoint Set Union) (Reference)

Maintain connectivity under union operations and answer connectivity queries
in near-constant time.

## What it demonstrates

- Union by size/rank
- Path compression
- Connectivity checks

## Pseudocode sketch

```mbt nocheck
if find(a) == find(b): connected
else: union(a, b)
```

## Example

```mbt check
///|
test "union find example" {
  let uf = @union_find.UnionFind::new(4)
  let _ = uf.union(0, 1)
  let _ = uf.union(2, 3)
  inspect(uf.connected(0, 1), content="true")
  inspect(uf.connected(0, 2), content="false")
  inspect(uf.count_sets(), content="2")
}
```

## Notes

- Amortized time: O(alpha(n)) per operation
- This package is a reference implementation with invariants
- For a challenge-style API, see `lib/challenge_union_find_rollback`
