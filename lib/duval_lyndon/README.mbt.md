# Duval's Lyndon Factorization

## Overview

A **Lyndon word** is a non-empty string that is strictly smaller than all of its
non-trivial rotations. Duval's algorithm decomposes any string into a unique
sequence of Lyndon words in **non-increasing lexicographic order**.

- **Time**: O(n)
- **Space**: O(n)

## Algorithm Sketch

Maintain three indices `i`, `j`, `k`:

- `i` = start of the current block
- `j` = scanning position
- `k` = comparison position inside the block

Advance `j` while the block remains lexicographically minimal. When the scan
breaks, the block length is `j - k`, and that Lyndon word repeats as long as
`i <= k`.

## API

- `duval_factorization(s)` returns an array of factors (strings).

## Example Usage

```mbt check
///|
test "duval banana" {
  let factors = @duval_lyndon.duval_factorization("banana")
  inspect(factors, content="[\"b\", \"an\", \"an\", \"a\"]")
}
```

```mbt check
///|
test "duval ababab" {
  let factors = @duval_lyndon.duval_factorization("ababab")
  inspect(factors, content="[\"ab\", \"ab\", \"ab\"]")
}
```

## When To Use

- String algorithms that need **Lyndon decomposition** (e.g., minimum rotation).
- Building suffix arrays (as part of SA-IS or related techniques).
