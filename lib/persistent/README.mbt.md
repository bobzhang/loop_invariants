# Persistent Data Structures

## Overview

**Persistent data structures** preserve previous versions after modifications.
Instead of mutating in place, they create new versions while sharing unchanged
portions. This enables "time travel" through data history.

- **Update**: O(log n) typically
- **Query any version**: O(log n)
- **Space per update**: O(log n)

## The Key Insight

```
Don't modify nodes—create new ones.
Share unchanged subtrees between versions!

Mutable update:          Persistent update:
Before:    [A]           Before:    [A]
          /   \                    /   \
        [B]   [C]                [B]   [C]
        /                        /
      [D]                      [D]

Modify D:  [A]           After:   [A']   ← new
          /   \                  /    \
        [B]   [C]   →        [B']   [C]  ← B' new, C shared
        /                    /
      [D']                 [D']   ← new
                           /
                         [D] ← old D still exists in old version

Old tree: [A]-[B]-[D]
New tree: [A']-[B']-[D']
Shared: [C]
```

## Path Copying

```
Only copy nodes on the path from root to modified node.

Binary tree with n nodes:
  - Path length: O(log n)
  - Nodes copied per update: O(log n)
  - Total space for k updates: O(k log n)

Original:         After update at *:
     1                  1'   ← copy
    / \                /  \
   2   3              2'   3  ← copy 2, share 3
  / \                /  \
 4   5             4    5' ← share 4, copy 5
     |                   |
     *                   *' ← new value
```

## Example Usage

```mbt nocheck
// Version 0: initial tree
let v0 = PersistentTree::new()

// Version 1: insert 5
let v1 = v0.insert(5)

// Version 2: insert 3
let v2 = v1.insert(3)

// Query any version!
v0.contains(5)  // false
v1.contains(5)  // true
v2.contains(3)  // true

// Version 3: update from v1 (branching history)
let v3 = v1.insert(7)
// v2 and v3 are independent branches
```

## Common Persistent Structures

### Persistent Array (Versioned Array)
```
Update element at index i.
Access element at index i in any version.

Implementation: Use balanced tree indexed by position
Time: O(log n) per operation
```

### Persistent Stack
```
Push and pop create new versions.
Previous versions remain accessible.

Implementation: Linked list (naturally persistent!)
Time: O(1) per operation
```

### Persistent Segment Tree
```
Range queries on any version.
Point updates create new version.

Implementation: Path-copied segment tree
Time: O(log n) per operation
```

### Persistent Union-Find
```
Find and union with version control.
Query connectivity in any version.

Time: O(log n) with partial persistence
```

## Common Applications

### 1. Undo/Redo
```
Each edit creates new version.
Undo: revert to previous version.
Redo: move to next version.

No need to track inverse operations!
```

### 2. Version Control (Git-like)
```
Each commit is a new version.
Branches are multiple versions from same parent.
Merge combines two versions.
```

### 3. Functional Programming
```
Immutable data structures are naturally persistent.
Share structure between values.
Safe concurrent access (no mutations).
```

### 4. Range Queries Over Time
```
Given array with updates, answer:
"What was sum of [l, r] after k-th update?"

Use persistent segment tree.
```

## Types of Persistence

```
Partial Persistence:
  - Query any version
  - Only modify latest version

Full Persistence:
  - Query any version
  - Modify any version (creates branch)

Confluent Persistence:
  - Merge two versions into one
  - Hardest to implement efficiently
```

## Complexity Analysis

| Structure | Update | Query | Space/Update |
|-----------|--------|-------|--------------|
| Persistent Array | O(log n) | O(log n) | O(log n) |
| Persistent Stack | O(1) | O(1) | O(1) |
| Persistent Segtree | O(log n) | O(log n) | O(log n) |
| Persistent Treap | O(log n) | O(log n) | O(log n) |

## Persistent vs Immutable vs Mutable

| Type | Modify | Old Versions | Sharing |
|------|--------|--------------|---------|
| Mutable | In-place | Lost | N/A |
| Immutable | Full copy | All | None |
| **Persistent** | Path copy | All | Maximum |

**Choose Persistent when**: You need version history with efficient space/time.

## Fat Node vs Path Copying

```
Fat Node:
  Each node stores all its historical values.
  Space: O(1) per update
  Query: O(log versions) per node access

Path Copying:
  Copy nodes on update path.
  Space: O(log n) per update
  Query: O(log n) total

Path copying is simpler and often preferred.
```

## Implementation Notes

- Use immutable references/pointers
- Never mutate—always create new nodes
- Store root pointers for each version
- Consider garbage collection for old versions
- For segment tree, keep array of version roots
- Reference counting can help manage memory

