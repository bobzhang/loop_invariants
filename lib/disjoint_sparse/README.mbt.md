# Disjoint Sparse Table (Reference)

A variant of sparse table that supports O(1) queries for any associative
operation by precomputing disjoint block prefixes.

## What it demonstrates

- Building prefix minima for disjoint blocks
- Choosing a level by the highest differing bit
- O(1) range query via two precomputed values

## Pseudocode sketch

```mbt nocheck
k = highest_bit(l ^ (r-1))
answer = op(table[k][l], table[k][r-1])
```

## Example

```mbt check
///|
test "disjoint sparse sum example" {
  let arr : Array[Int64] = [1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L]
  let dst = @disjoint_sparse.DisjointSparseSum::new(arr)
  inspect(dst.query(0, 3), content="Some(10)")
  inspect(dst.query(2, 5), content="Some(18)")
}
```

## Notes

- Preprocess O(n log n), query O(1)
- For a challenge API, see `lib/challenge_disjoint_sparse_table`
