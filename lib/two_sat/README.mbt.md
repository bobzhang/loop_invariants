# 2-SAT (Reference)

Solve boolean formulas in 2-CNF by building the implication graph and finding
strongly connected components.

## What it demonstrates

- Implication graph construction
- SCC-based satisfiability check
- Extracting a satisfying assignment by component order

## Pseudocode sketch

```mbt nocheck
for clause (a or b):
  add edges (!a -> b) and (!b -> a)
run SCC
if x and !x in same SCC: unsatisfiable
```

## Notes

- Time complexity: O(V + E)
- This package is a reference implementation with invariants
