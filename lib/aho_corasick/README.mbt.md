# Aho-Corasick (Reference)

Multi-pattern string matching by combining patterns into a trie and adding
failure links. This allows scanning the text once while reporting matches.

## What it demonstrates

- Trie construction from patterns
- Failure links via BFS
- Streaming matching with output links

## Pseudocode sketch

```mbt nocheck
build_trie(patterns)
build_failure_links()
for c in text:
  state = next_state(state, c)
  report matches at state
```

## Notes

- Time complexity: O(text length + total pattern length)
- This package is a reference implementation with invariants
