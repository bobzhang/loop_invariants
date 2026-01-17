# Union-Find (Disjoint Set Union) - Beginner-Friendly Guide

Union-Find (also called DSU) manages **disjoint sets** and supports two fast
operations:

- **Find**: which set is this element in?
- **Union**: merge two sets.

With path compression and union-by-rank, both operations are **almost O(1)**.

---

## 1) The problem it solves

You have items that slowly become connected:

```
union(0, 1)
union(1, 2)
union(3, 4)
```

Now you want to answer:

```
connected(0, 2)?  -> yes
connected(0, 4)?  -> no (until we connect them)
```

Union-Find answers these in nearly constant time.

---

## 2) The data structure (forest of trees)

Each set is stored as a tree.  
The root represents the set ID.

Initial state (each node is its own root):

```
0   1   2   3   4
|   |   |   |   |
0   1   2   3   4
```

`parent[i] = i` means "i is a root".

---

## 3) Union: merge two sets

Suppose we union(0, 1) and union(2, 3):

```
Before:             After:
0   1   2   3       0       2
|   |   |   |       |       |
0   1   2   3       1       3
```

Now union(0, 2):

```
   0             0
   |             |
   1             1

   2       ->    2
   |             |
   3             3

After union:
     0
   /   \
  1     2
         \
          3
```

---

## 4) Path compression (why find is fast)

Every `find(x)` shortens the path to the root:

```
Before find(3):        After find(3):
0                       0
|                     / | \
1                    1  2  3
|
2
|
3
```

After compression, future finds are almost instant.

---

## 5) Union by rank (or size)

When merging two trees, attach the **smaller** one under the larger one.

This keeps trees shallow and speeds up future queries.

---

## 6) Example: connectivity queries

```mbt check
///|
test "union find connectivity" {
  let uf = @union_find.UnionFind::new(5)
  inspect(uf.connected(0, 4), content="false")
  let _ = uf.union(0, 1)
  let _ = uf.union(1, 2)
  let _ = uf.union(3, 4)
  inspect(uf.connected(0, 2), content="true")
  inspect(uf.connected(0, 4), content="false")
  let _ = uf.union(2, 3)
  inspect(uf.connected(0, 4), content="true")
}
```

---

## 7) Example: counting components

```mbt check
///|
test "union find count sets" {
  let uf = @union_find.UnionFind::new(6)
  inspect(uf.count_sets(), content="6")
  let _ = uf.union(0, 1)
  let _ = uf.union(2, 3)
  inspect(uf.count_sets(), content="4")
  let _ = uf.union(0, 2)
  inspect(uf.count_sets(), content="3")
}
```

---

## 8) Example: sizes of components

```mbt check
///|
test "union find set size" {
  let uf = @union_find.UnionFind::new(5)
  let _ = uf.union(0, 1)
  let _ = uf.union(1, 2)
  inspect(uf.set_size(0), content="3")
  inspect(uf.set_size(3), content="1")
  let _ = uf.union(2, 3)
  inspect(uf.set_size(3), content="4")
}
```

---

## 9) Typical use cases

```
Connectivity in graphs
Kruskal's minimum spanning tree
Connected components in images
Grouping friends in social networks
Equivalence classes (A = B, B = C)
```

---

## 10) Kruskal's MST (how DSU fits)

Kruskal's algorithm:

```
1. Sort edges by weight
2. For each edge (u, v):
   if not connected(u, v):
     union(u, v)
     add edge to MST
```

Union-Find makes step 2 extremely fast.

---

## 11) Complexity

```
Operation      Cost (amortized)
find           O(α(n))
union          O(α(n))
connected      O(α(n))
```

`α(n)` is the inverse Ackermann function (so small it is < 5 for any real input).

---

## 12) Common pitfalls

- Forgetting to call `find` before comparing roots.
- Assuming `set_size(x)` works on non-roots (this implementation handles it).
- Mixing up 0-indexed and 1-indexed element IDs.
