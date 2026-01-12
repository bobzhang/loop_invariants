# Challenge: Difference Array

Apply many range increments efficiently by storing the differences between
adjacent elements.

## What you learn

- Representing range updates with two point updates
- Reconstructing the final array via prefix sum
- Loop invariants for reconstruction

## Pseudocode sketch

```mbt nocheck
// add delta to [l, r]
diff[l] += delta
diff[r + 1] -= delta

// recover array
for i in 0..n-1:
  arr[i] = arr[i-1] + diff[i]
```

## Example

```mbt check
///|
test "difference array basic" {
  let base : Array[Int] = [1, 2, 3, 4, 5]
  let updates : Array[(Int, Int, Int)] = [(1, 3, 2), (0, 0, -1), (2, 4, 1)]
  let updated = @challenge_difference_array.apply_range_add(base[:], updates[:])
  inspect(updated, content="[0, 4, 6, 7, 6]")
}
```

## Another Example

```mbt check
///|
test "difference array disjoint ranges" {
  let base : Array[Int] = [0, 0, 0, 0]
  let updates : Array[(Int, Int, Int)] = [(0, 1, 3), (2, 3, 1)]
  let updated = @challenge_difference_array.apply_range_add(base[:], updates[:])
  inspect(updated, content="[3, 3, 1, 1]")
}
```

## Notes

- Range update: O(1)
- Reconstruction: O(n)
