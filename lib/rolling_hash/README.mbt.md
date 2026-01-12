# Rolling Hash (Reference)

Compute substring hashes in O(1) after O(n) preprocessing. Useful for
string matching, palindromes, and substring equality.

## What it demonstrates

- Prefix hash construction
- Power table for base^k
- Constant-time substring hash extraction

## Pseudocode sketch

```mbt nocheck
hash(l, r) = pref[r] - pref[l] * base^(r-l)
```

## Example

```mbt check
///|
test "rolling hash pattern search" {
  let hits = @rolling_hash.find_pattern_rabin_karp("aabcaabxaab", "aab")
  inspect(hits, content="[0, 4, 8]")
  inspect(
    @rolling_hash.count_pattern_rabin_karp("mississippi", "issi"),
    content="2",
  )
}
```

## Notes

- Time complexity: O(1) per query after O(n) setup
- This package is a reference implementation with invariants
