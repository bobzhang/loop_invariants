# Persistent Data Structures (Reference)

Core ideas and utilities for building persistent versions of data structures.

## What it demonstrates

- Path copying for updates
- Structural sharing across versions
- Versioned access patterns

## Pseudocode sketch

```mbt nocheck
new_root = update(old_root, ...)
query(new_root, ...)
query(old_root, ...)
```

## Notes

- Typically O(log n) update/query with sharing
- This package is a reference implementation with invariants
