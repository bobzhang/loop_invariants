# Bipartite Matching

## Problem

You have two groups (left and right). Edges mean "can match". Find the **largest set of pairs** where no vertex is used twice.

Example:

- Left: workers
- Right: jobs
- Edge: worker can do job

## Simple Idea (Augmenting Paths)

Start with an empty matching. Repeatedly find a path that **alternates** between:

- unmatched edges
- matched edges

If the path ends at an unmatched right vertex, **flip** the edges on the path. This increases the matching size by 1.

## Algorithm Used Here (Kuhn / DFS)

This package uses the simple DFS-based augmenting path algorithm:

1. For each left vertex `u`:
2. Run DFS to find an augmenting path
3. If found, increase the matching

It is easy to implement and good for medium-sized graphs.

## Complexity

- Time: **O(V × E)**
- Space: **O(V + E)**

## Example

```mbt check
///|
test "bipartite matching example" {
  let edges : Array[(Int, Int)] = [(0, 0), (0, 1), (1, 1)]
  let matching = @bipartite_matching.max_matching(2, 2, edges[:])
  inspect(matching, content="[(0, 0), (1, 1)]")
  inspect(matching.length(), content="2")
}
```

## When to Use

Use bipartite matching when you need:

- Assignments (workers → jobs)
- Pairing requests (students → courses)
- Maximum non-conflicting pairs

If the graph is very large, Hopcroft–Karp is faster, but the idea is the same.
