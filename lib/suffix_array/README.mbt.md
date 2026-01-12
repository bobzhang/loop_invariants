# Suffix Array (Reference)

Build a suffix array and LCP array for a string. This enables fast substring
searches and many string analytics tasks.

## What it demonstrates

- Prefix-doubling suffix array construction
- Kasai LCP computation
- Binary search over suffix array for pattern lookup

## Pseudocode sketch

```mbt nocheck
///|
let sa = build_suffix_array(s)

///|
let lcp = build_lcp(s, sa)
```

## Example

```mbt check
///|
test "suffix array example" {
  let sa = @suffix_array.SuffixArray::new("banana")
  let hits = sa.find_all("ana")
  inspect(hits, content="[1, 3]")
  inspect(sa.count("na"), content="2")
}
```

## Notes

- This package is a reference implementation with invariants.
- For a public API, see `lib/challenge_suffix_array`.
- Time complexity: `O(n log^2 n)` for SA, `O(n)` for LCP.
