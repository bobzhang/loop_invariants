# 2-SAT (2-Satisfiability)

## Overview

**2-SAT** solves boolean satisfiability where each clause has exactly two literals.
Unlike general SAT (NP-complete), 2-SAT is solvable in **linear time** O(n + m)
using the implication graph and strongly connected components.

- **Time**: O(n + m)
- **Space**: O(n + m)

## The Problem

```
Variables: x₀, x₁, x₂, ...
Clauses: Each is (a ∨ b) where a, b are literals

Example:
  (x₀ ∨ x₁) ∧ (¬x₀ ∨ x₂) ∧ (¬x₁ ∨ ¬x₂)

Goal: Find assignment of true/false to variables
      such that all clauses are satisfied.
```

## The Key Insight: Implication Graph

```
(a ∨ b) is equivalent to two implications:
  ¬a → b   "if not a, then b"
  ¬b → a   "if not b, then a"

Build a graph with 2n nodes (x and ¬x for each variable):

Example: (x₀ ∨ x₁) ∧ (¬x₀ ∨ x₂) ∧ (¬x₁ ∨ ¬x₂)

Implications:
  ¬x₀ → x₁,  ¬x₁ → x₀    from (x₀ ∨ x₁)
  x₀ → x₂,   ¬x₂ → ¬x₀   from (¬x₀ ∨ x₂)
  x₁ → ¬x₂,  x₂ → ¬x₁    from (¬x₁ ∨ ¬x₂)

Graph:
  ¬x₀ ──→ x₁ ──→ ¬x₂ ──→ ¬x₁ ──→ x₀
    ↑                              │
    └──────────────────────────────┘
```

## Satisfiability Condition

```
THEOREM: 2-SAT is satisfiable if and only if
         no variable x and ¬x are in the same SCC.

Why?
- If x → ... → ¬x (path exists), setting x=true forces ¬x=true (contradiction)
- If ¬x → ... → x (path exists), setting x=false forces x=true (contradiction)
- If both paths exist, they form a cycle containing x and ¬x in same SCC

Example of unsatisfiable:
  (x₀) ∧ (¬x₀)

  Implications: ¬x₀ → x₀, x₀ → ¬x₀

  x₀ → ¬x₀ → x₀ (cycle!)

  x₀ and ¬x₀ in same SCC → unsatisfiable
```

## Algorithm Walkthrough

```
Formula: (x₀ ∨ x₁) ∧ (¬x₁ ∨ x₂)

Step 1: Build implication graph
  From (x₀ ∨ x₁): ¬x₀ → x₁, ¬x₁ → x₀
  From (¬x₁ ∨ x₂): x₁ → x₂, ¬x₂ → ¬x₁

  Nodes: x₀, ¬x₀, x₁, ¬x₁, x₂, ¬x₂

Step 2: Find SCCs (using Kosaraju/Tarjan)
  SCC 0: {¬x₀}
  SCC 1: {x₁, x₂}
  SCC 2: {¬x₂, ¬x₁, x₀}

Step 3: Check x and ¬x in different SCCs
  x₀ in SCC 2, ¬x₀ in SCC 0  ✓
  x₁ in SCC 1, ¬x₁ in SCC 2  ✓
  x₂ in SCC 1, ¬x₂ in SCC 2  ✓
  All different → satisfiable!

Step 4: Assign values (reverse topological order)
  Higher SCC number = earlier in reverse topo order

  x₀: SCC(x₀)=2 > SCC(¬x₀)=0 → x₀ = true
  x₁: SCC(x₁)=1 < SCC(¬x₁)=2 → x₁ = false
  x₂: SCC(x₂)=1 < SCC(¬x₂)=2 → x₂ = false

Verify: (x₀ ∨ x₁) = (T ∨ F) = T  ✓
        (¬x₁ ∨ x₂) = (T ∨ F) = T  ✓
```

## Visual: Implication Graph

```
Formula: (x₀ ∨ ¬x₁) ∧ (x₁ ∨ x₂) ∧ (¬x₂ ∨ ¬x₀)

Implication edges:
  ¬x₀ → ¬x₁,  x₁ → x₀     from (x₀ ∨ ¬x₁)
  ¬x₁ → x₂,   ¬x₂ → x₁    from (x₁ ∨ x₂)
  x₂ → ¬x₀,   x₀ → ¬x₂    from (¬x₂ ∨ ¬x₀)

Graph visualization:
         ┌──────────────────┐
         ↓                  │
  x₀ ──→ ¬x₂ ──→ x₁ ──→ x₀ │  (cycle within SCC)
         │
         ↓
  ¬x₁ ←── ... ←── ¬x₀

SCCs found: {x₀, ¬x₂, x₁}, {¬x₁, x₂, ¬x₀}

x₀ and ¬x₀ in different SCCs → satisfiable
```

## Example Usage

```mbt check
///|
test "2-sat concept" {
  // 2-SAT converts clauses to implication graph
  // (a ∨ b) → edges ¬a → b and ¬b → a

  // Example: (x₀ ∨ x₁) ∧ (¬x₀ ∨ x₁)
  // Implications: ¬x₀ → x₁, ¬x₁ → x₀
  //              x₀ → x₁, ¬x₁ → ¬x₀

  // Solution: x₁ = true (forced by both clauses)

  inspect(true, content="true")
}
```

## Common Applications

### 1. Scheduling with Conflicts
```
Problem: Schedule n events, each at time A or B.
         Some pairs conflict if scheduled together.

Variables: xᵢ = true means event i at time A
Clauses: If events i and j conflict at (A,A):
         add clause (¬xᵢ ∨ ¬xⱼ)
```

### 2. Graph 2-Coloring with Constraints
```
Problem: Color vertices with 2 colors, some pairs
         must be same color, others must differ.

Variables: xᵢ = true means color 1
Same color: (xᵢ ∨ ¬xⱼ) ∧ (¬xᵢ ∨ xⱼ)
Diff color: (xᵢ ∨ xⱼ) ∧ (¬xᵢ ∨ ¬xⱼ)
```

### 3. Implication Chains
```
Problem: If xᵢ then xⱼ must also hold.

Implication xᵢ → xⱼ:
  Equivalent to (¬xᵢ ∨ xⱼ)
```

### 4. At Most One True
```
Problem: At most one of x₁, x₂, ..., xₖ is true.

Clauses: (¬xᵢ ∨ ¬xⱼ) for all pairs i < j
Warning: O(k²) clauses, consider alternatives for large k
```

## Complexity Analysis

| Operation | Time |
|-----------|------|
| Build graph | O(m) |
| Find SCCs | O(n + m) |
| Assign values | O(n) |
| **Total** | **O(n + m)** |

## 2-SAT vs General SAT

| Property | 2-SAT | 3-SAT | General SAT |
|----------|-------|-------|-------------|
| Clause size | ≤ 2 | ≤ 3 | Any |
| Complexity | P (linear) | NP-complete | NP-complete |
| Algorithm | SCC | Backtracking/DPLL | SAT solvers |

**Choose 2-SAT when**: All clauses have at most 2 literals.

## The Assignment Rule

```
After finding SCCs, assign values based on topological order:

For each variable x:
  if SCC_order(x) > SCC_order(¬x):
    x = true
  else:
    x = false

Why this works:
- If a → b (implication), then SCC_order(a) ≤ SCC_order(b)
- We process in reverse topological order
- Assigning based on SCC order ensures:
  If x is true and x → y exists, then y is also true
```

## Implementation Notes

- Nodes: use 2i for xᵢ, 2i+1 for ¬xᵢ
- Negation: flip last bit (n ^ 1)
- For "force x = true", add clause (x ∨ x)
- For "force x = false", add clause (¬x ∨ ¬x)
- Verify solution by checking all implications

