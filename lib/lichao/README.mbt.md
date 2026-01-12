# Li Chao Tree

## Overview

A **Li Chao Tree** maintains a dynamic set of lines and supports queries for
the minimum (or maximum) y-value at any x-coordinate. It's a specialized
segment tree for the "line container" problem.

- **Insert**: O(log C) where C is the coordinate range
- **Query**: O(log C)
- **Space**: O(n) or O(log C × lines)

## The Problem

```
Maintain a set of lines y = mx + b.
Query: What is the minimum y at x = k?

Lines: y = 2x + 1, y = -x + 5, y = 0.5x + 2

At x = 1: min(3, 4, 2.5) = 2.5  (from line y = 0.5x + 2)
At x = 4: min(9, 1, 4) = 1      (from line y = -x + 5)

Naive: O(n) per query (check all lines)
Li Chao: O(log C) per query!
```

## The Key Insight

```
Build segment tree over x-coordinates.
Each node stores ONE "dominating" line for its interval.

When inserting line L into node [l, r]:
1. Compare L with current line at midpoint m = (l+r)/2
2. Keep the better line at m as "winner"
3. The "loser" might still win on one side — recurse there!

Key observation: The loser can only win on at most ONE side.
```

## Algorithm Walkthrough

```
Coordinate range: [0, 4]
Insert lines: A: y = -x + 4, B: y = x

Tree structure (before inserts):
      [0,4]
     /     \
  [0,2]   [2,4]
  /   \   /   \
[0,1][1,2][2,3][3,4]

Insert A: y = -x + 4 (winner at all levels initially)

Insert B: y = x into [0,4]:
  Midpoint = 2
  A at 2: -2 + 4 = 2
  B at 2: 2
  Tie! Keep A (or B), recurse other

  At [0,2]: A still wins at mid=1 (A=3, B=1), B wins at left
  At [0,1]: B now wins (at mid=0.5: A=3.5, B=0.5)

Query x=1:
  [0,4]: A gives 3
  [0,2]: A gives 3
  [0,1]: B gives 1
  Answer: min(3, 3, 1) = 1 ✓
```

## Visual: Line Dominance

```
Lines: A (dashed), B (solid)

y
4 |  A
3 |   \     /B
2 |    \   /
1 |     \/      ← intersection
0 |─────X────────→ x
      0 1 2 3 4

A dominates [0, 1], B dominates [1, ∞]

In Li Chao tree:
  Root stores one line (say A)
  But we recurse to track B where it wins
```

## Example Usage

```mbt nocheck
// Create Li Chao tree for x in [0, 1000000]
let lc = LiChaoTree::new(0, 1000000)

// Insert lines: y = mx + b
lc.insert(2, 1)   // y = 2x + 1
lc.insert(-1, 5)  // y = -x + 5

// Query minimum y at x = 3
let min_y = lc.query(3)  // Returns min(7, 2) = 2
```

## The Insert Algorithm

```
insert(line, node [l, r]):
    mid = (l + r) / 2

    if node has no line:
        node.line = line
        return

    # Compare at midpoint
    new_better_at_mid = line(mid) < node.line(mid)

    if new_better_at_mid:
        swap(line, node.line)  # new line stays here

    # The "loser" might win on one side
    if l == r:
        return

    left_wins = line(l) < node.line(l)
    if left_wins:
        insert(line, left_child)
    else:
        insert(line, right_child)
```

## Common Applications

### 1. Convex Hull Trick (Offline)
```
DP optimization where transitions are lines.
dp[i] = min(dp[j] + cost(j, i))

If cost(j, i) = a[j] * b[i] + c[j]:
  This is a line y = a[j] * x + c[j] queried at x = b[i]

Li Chao handles dynamic (online) insertions!
```

### 2. Shortest Path with Linear Costs
```
Edge cost = mx + b where x is current "state"
Use Li Chao to find cheapest edge at any state.
```

### 3. Dynamic Programming Optimization
```
Many DP problems with form:
  dp[i] = min over j of (f(j) * g(i) + h(j))

Insert line (f(j), h(j)), query at g(i).
```

### 4. Computational Geometry
```
Lower envelope of lines.
Useful for various geometric optimization problems.
```

## Complexity Analysis

| Operation | Time | Space |
|-----------|------|-------|
| Insert line | O(log C) | O(1) amortized |
| Query min at x | O(log C) | O(1) |
| Total with n lines | O(n log C) | O(n + log C) or O(4C) |

## Li Chao vs Convex Hull Trick

| Feature | Li Chao | Convex Hull Trick |
|---------|---------|-------------------|
| Insert order | Any | Sorted by slope |
| Query order | Any | Often sorted |
| Complexity | O(log C) | O(log n) or O(1) amortized |
| Implementation | Simpler | More complex |

**Choose Li Chao when**: You need arbitrary insert/query order or simpler code.

## Line Segments

```
Li Chao can also handle line segments [l, r]:
Insert segment only into nodes fully contained in [l, r].

insert_segment(line, node [nl, nr], seg [l, r]):
    if nr < l or r < nl:
        return  # no overlap
    if l <= nl and nr <= r:
        insert(line, node)  # fully contained
        return
    insert_segment(line, left_child, seg)
    insert_segment(line, right_child, seg)

Time: O(log² C) per segment
```

## Dynamic Variant

```
For unknown coordinate range, use dynamic segment tree:
- Start with a small tree
- Create nodes on demand when inserting

Or use coordinate compression if all queries are known.
```

## Implementation Notes

- Use 1e18 or similar for "no line" sentinel
- For maximum instead of minimum, flip comparison
- Be careful with floating-point precision
- Can use persistent Li Chao for versioned queries
- Space-efficient: only O(n log C) nodes ever created
- For small C, use array-based segment tree

