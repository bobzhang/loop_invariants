# Stoer–Wagner Global Minimum Cut (Undirected)

This package finds the **global minimum cut** of an undirected weighted graph.
Unlike s‑t min cut, it does **not** require a source or sink.

---

## 1. Problem statement (beginner friendly)

We want to remove edges so the graph splits into **two non‑empty parts**, with
minimum total weight removed.

That minimum weight is the **global min cut**.

---

## 2. Big idea

Stoer–Wagner runs multiple phases.

Each phase:

1. Builds a growing set **A** by always adding the vertex most connected to A.
2. The last vertex added is **t**.
3. The cut that isolates **t** is a valid min‑cut candidate.
4. Contract the last two vertices and repeat.

The best cut over all phases is the answer.

---

## 3. Visual: maximum adjacency search

```
Graph (weights shown):

  A --2-- B --1-- C
  |               |
  2               1
  |               |
  D --------------+

Start A = {A}
Weights to A: B=2, D=2, C=0
Pick B or D (say B) -> A={A,B}
Update weights: C = 1, D = 2
Pick D -> A={A,B,D}
Update: C = 1 + 1 = 2
Pick C last

Last vertex C gives a cut candidate.
```

---

## 4. Small worked example (4‑cycle)

Cycle with weight 1 on each edge:

```
0 --1-- 1
|       |
1       1
|       |
3 --1-- 2
```

Minimum cut is 2 (remove any two adjacent edges).

### Phase 1

Start A = {0}

```
weights: w[1]=1, w[3]=1, w[2]=0
pick 1, then pick 2, then pick 3 last
```

Cut isolating 3 has weight 2.

### Contract and repeat

All phases give weight 2, so answer is 2.

---

## 5. Why it works (intuition)

At the end of a phase, the last vertex `t` has the strongest total connection
to the set built so far.

The cut `{t}` vs rest equals the **minimum s‑t cut** for the phase.
By contracting and repeating, every possible cut is considered implicitly.

---

## 6. API overview

From `pkg.generated.mbti`:

```
stoer_wagner_min_cut(n, edges) -> MinCutResult?

MinCutResult:
  weight : Int64
  cut    : Array[Int]   // one side of the cut
```

---

## 7. Example usage

```mbt check
///|
test "stoer wagner cycle" {
  let edges : Array[(Int, Int, Int64)] = [
    (0, 1, 1L),
    (1, 2, 1L),
    (2, 3, 1L),
    (3, 0, 1L),
  ]
  let result = @stoer_wagner_min_cut.stoer_wagner_min_cut(4, edges[:]).unwrap()
  inspect(result.weight, content="2")
}
```

```mbt check
///|
test "stoer wagner weighted" {
  let edges : Array[(Int, Int, Int64)] = [(0, 1, 5L), (1, 2, 3L), (0, 2, 2L)]
  let result = @stoer_wagner_min_cut.stoer_wagner_min_cut(3, edges[:]).unwrap()
  inspect(result.weight, content="5")
}
```

---

## 8. Disconnected graphs

If the graph is disconnected, the global min cut is 0.

```mbt check
///|
test "stoer wagner disconnected" {
  let edges : Array[(Int, Int, Int64)] = []
  let result = @stoer_wagner_min_cut.stoer_wagner_min_cut(3, edges[:]).unwrap()
  inspect(result.weight, content="0")
}
```

---

## 9. Complexity

```
Dense version:   O(V^3)
Heap version:    O(VE + V^2 log V)
Space:           O(V^2)
```

This is best for medium‑sized graphs.

---

## 10. Beginner checklist

1. Graph is **undirected**.
2. Edge weights are non‑negative.
3. Input vertices are 0‑indexed.
4. Result returns **one side** of the min cut.

---

## 11. Summary

Stoer–Wagner gives a deterministic global min cut:

- repeated maximum‑adjacency phases,
- contract last two vertices each phase,
- smallest cut found is the answer.
