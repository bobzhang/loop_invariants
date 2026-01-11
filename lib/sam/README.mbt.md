# Suffix Automaton (SAM) (Reference)

Compact automaton that recognizes all substrings of a string in linear time.

## What it demonstrates

- State cloning during extension
- Suffix links and endpos classes
- Counting occurrences via link tree

## Pseudocode sketch

```mbt nocheck
for c in s:
  extend(c)
```

## Notes

- Time complexity: O(n) build
- This package is a reference implementation with invariants
