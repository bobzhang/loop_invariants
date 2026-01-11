# Trie (Prefix Tree) (Reference)

Store a set of strings for fast prefix queries and lexicographic traversal.

## What it demonstrates

- Node-based prefix tree construction
- Insert, search, and prefix checks
- DFS traversal for listing words

## Pseudocode sketch

```mbt nocheck
insert(word):
  for c in word: go to child or create
```

## Notes

- Time complexity: O(length of word) per operation
- This package is a reference implementation with invariants
