# Rabin-Karp (Reference)

Rolling-hash based pattern matching. Efficient for multiple pattern checks and
average-case linear search, with verification on hash matches.

## What it demonstrates

- Polynomial rolling hash construction
- O(1) hash updates for sliding windows
- Collision-safe verification

## Pseudocode sketch

```mbt nocheck
///|
let hits = rabin_karp_search(text, pattern)
```

## Example

```mbt check
///|
test "rabin karp example" {
  let matches = @rabin_karp.rabin_karp_search("abababab", "aba")
  inspect(matches, content="[0, 2, 4]")
  inspect(@rabin_karp.rabin_karp_count("aaaa", "aa"), content="3")
}
```

## Notes

- This package is a reference implementation with invariants.
- For a public API, see `lib/challenge_rabin_karp`.
- Expected time complexity: `O(n + m)`.
