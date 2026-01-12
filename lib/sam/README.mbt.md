# Suffix Automaton (SAM)

## Overview

A **Suffix Automaton** is a minimal DFA that recognizes exactly all suffixes
(and hence all substrings) of a string. It's remarkably space-efficient,
using only O(n) states for a string of length n.

- **Build**: O(n)
- **Space**: O(n) states, O(n × σ) transitions
- **Substring check**: O(m) for pattern of length m

## The Key Insight

```
Group positions that have the same set of right contexts
(same "endpos" set) into a single state.

String: "aabab"
Endpos of "ab": {3, 5} (appears ending at positions 3 and 5)
Endpos of "b": {2, 3, 5}
Endpos of "aab": {3}

States with same endpos share a state in SAM!
```

## Structure Overview

```
String: "abab"

SAM states and transitions:
         ┌─a─→ [ab] ─b─→ [abab]
  [init] ─a─→ [a]              ↓
         │        ╲            b
         └─b─→ [b] ─a─→ [bab]←─┘

Suffix links (dotted):
  [abab] ··→ [bab] ··→ [ab] ··→ [b] ··→ [init]
  [a] ··→ [init]

Each state represents a set of substrings with same endpos.
```

## Suffix Links

```
Suffix link from state q points to state representing
the longest proper suffix of strings in q.

State [abab]: represents only "abab"
  Suffix link → [bab]: represents "bab"
    Suffix link → [ab]: represents "ab"
      Suffix link → [b]: represents "b"
        Suffix link → [init]: empty string

Following suffix links = iterating through suffixes!
```

## Algorithm: Building SAM

```
Process string character by character.
For each new character c:

1. Create new state for prefix seen so far
2. From previous state, add edge labeled c
3. Follow suffix links to add more edges
4. Handle cloning when endpos sets must split

Amortized O(1) per character → O(n) total
```

## Algorithm Walkthrough

```
Build SAM for "ab":

Initial: just [init]

Add 'a':
  Create [a], len=1
  Edge: init ─a─→ [a]
  Suffix link: [a] → init

  SAM: init ─a─→ [a]

Add 'b':
  Create [ab], len=2
  Edge: [a] ─b─→ [ab]
  Follow suffix links from [a]:
    init: no 'b' edge → add init ─b─→ [ab]
  Suffix link: [ab] → init (no, we need clone!)

  Actually, [ab]'s suffix "b" creates new state [b]:
  Edge: init ─b─→ [b]
  Suffix link: [ab] → [b] → init

  Final SAM:
  init ─a─→ [a] ─b─→ [ab]
      └─b─→ [b]

Substrings recognized: "", "a", "b", "ab"  ✓
```

## Example Usage

```mbt check
///|
test "sam example" {
  inspect(@sam.contains_substring("abab", "aba"), content="true")
  inspect(@sam.distinct_substrings_count("abab"), content="7")
}
```

## Common Applications

### 1. Substring Check
```
Query: Is P a substring of S?
Build SAM for S, try to walk P from init.
Time: O(|P|)
```

### 2. Count Distinct Substrings
```
Each state represents unique substrings.
Sum of (len[state] - len[suffix_link[state]]) over all states.

For "abab": 1 + 2 + 2 + 1 + 1 = 7 distinct substrings
("", "a", "b", "ab", "ba", "aba", "bab", "abab" - wait, that's 8)
Actually: "a", "b", "ab", "ba", "aba", "bab", "abab" = 7 (excluding empty)
```

### 3. Longest Common Substring
```
Build SAM for S, walk T through it.
Track maximum length reached.
Time: O(|S| + |T|)
```

### 4. Substring Occurrence Count
```
Count how many times P occurs in S.
Endpos size of the state reached by P.
Precompute via DFS on suffix link tree.
```

## Complexity Analysis

| Operation | Time |
|-----------|------|
| Build SAM | O(n) |
| Substring check | O(m) |
| Distinct substrings | O(n) |
| Occurrence count (after build) | O(m) |

## SAM vs Suffix Array vs Suffix Tree

| Structure | Space | Build | Substring | LCP |
|-----------|-------|-------|-----------|-----|
| **SAM** | O(n) | O(n) | O(m) | With link tree |
| Suffix Array | O(n) | O(n) | O(m log n) | O(1) with LCP |
| Suffix Tree | O(n) | O(n) | O(m) | O(1) |

**Choose SAM when**: You need efficient substring operations with minimal space.

## State Properties

```
Each state q has:
  - len[q]: length of longest string in the state
  - link[q]: suffix link to parent state
  - trans[q][c]: transition on character c

Key relationship:
  len[link[q]] < len[q]
  Strings in q have lengths in (len[link[q]], len[q]]
```

## Endpos Classes

```
Endpos(s) = set of ending positions of substring s

Properties:
1. Two substrings u, v have same endpos iff one is suffix of other
   and they appear together
2. Endpos classes are either disjoint or one contains the other
3. This forms a tree structure → suffix link tree!
```

## Implementation Notes

- States: at most 2n - 1 states for string of length n
- Transitions: at most 3n - 4 transitions
- Use arrays for small alphabet, maps for large
- Clone operation is the tricky part (handle carefully)
- Suffix links form a tree rooted at init
- For occurrence counting, compute sizes via DFS

