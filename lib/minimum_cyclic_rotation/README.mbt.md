# Minimum Cyclic Rotation (Booth's Algorithm)

## Overview

The **minimum cyclic rotation** of a string is the lexicographically smallest
string among all its rotations. Booth's algorithm finds this rotation in **O(n)**
by comparing two candidate rotations and skipping dominated ones.

- **Time**: O(n)
- **Space**: O(n)

## Key Idea

Maintain two candidates `i` and `j` and a common prefix length `k`:

- If the prefixes match, extend `k`.
- On mismatch, skip the worse candidate by `k + 1`.
- The smaller of `i` and `j` at the end is the answer.

## API

- `min_cyclic_rotation_index(s)` returns the start index.
- `min_cyclic_rotation(s)` returns the rotated string.

## Example Usage

```mbt check
///|
test "min rotation basic" {
  inspect(@minimum_cyclic_rotation.min_cyclic_rotation("baca"), content="abac")
  inspect(
    @minimum_cyclic_rotation.min_cyclic_rotation_index("baca"),
    content="3",
  )
}
```

## When To Use

- String canonicalization (e.g., cyclic string equivalence).
- Necklace / bracelet problems in combinatorics.
- Minimal representation of rotations for hashing or indexing.
