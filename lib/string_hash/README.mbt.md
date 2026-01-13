# String Hashing (Reference)

Compute prefix hashes and compare substrings in O(1) time after preprocessing.

## Core Idea

Use a polynomial rolling hash:

```
hash(l, r) = pref[r] - pref[l] * pow_base[r-l]
```

With precomputed prefix hashes and powers, each substring hash is O(1).

## What it demonstrates

- Polynomial rolling hash
- Power table construction
- Collision mitigation patterns

## Pseudocode sketch

```mbt nocheck
hash(l, r) = pref[r] - pref[l] * pow_base[r-l]
```

## Example

```mbt check
///|
test "string hash example" {
  let hits = @string_hash.hash_pattern_match("abababab", "aba")
  inspect(hits, content="[0, 2, 4]")
}
```

## Notes

- `hash_pattern_match` scans all positions and compares hashes.
- Hash collisions are possible; use double hashing or verify by substring compare.
- This package is a reference implementation with invariants.
- Pattern matching is O(n + m) time after preprocessing.
