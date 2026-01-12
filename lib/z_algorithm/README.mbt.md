# Z-Algorithm (Reference)

Compute the Z-array for a string, where `z[i]` is the length of the longest
prefix match starting at `i`. This supports linear-time pattern matching by
running on `pattern + separator + text`.

## What it demonstrates

- Z-box reuse to avoid re-computation
- Linear-time prefix matching
- Pattern matching by checking `z[i] == |pattern|`

## Pseudocode sketch

```mbt nocheck
///|
let z = compute_z(s)

///|
let hits = z_search(text, pattern)
```

## Example

```mbt check
///|
test "z algorithm example" {
  let z = @z_algorithm.compute_z("aabcaab")
  inspect(z, content="[7, 1, 0, 0, 3, 1, 0]")
  let hits = @z_algorithm.find_pattern("aabcaabxaab", "aab")
  inspect(hits, content="[0, 4, 8]")
}
```

## Notes

- This package is a reference implementation with detailed invariants.
- For a public API, see `lib/challenge_z_algorithm`.
- Time complexity: `O(n)`.
