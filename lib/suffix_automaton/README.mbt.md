# Suffix Automaton (Extended)

## Overview

A **Suffix Automaton (SAM)** is a minimal DFA that accepts exactly all suffixes
of a string. This extended implementation provides additional utilities for
substring queries and occurrence counting.

- **Build**: O(n)
- **Space**: O(n) states, O(n × σ) transitions
- **Queries**: O(m) for substring of length m

## Core Idea

Maintain states representing endpos equivalence classes and suffix links that
connect each state to the longest proper suffix. Each new character extends
the automaton by updating transitions and possibly cloning states.

## The Key Insight

```
Group positions by their "right context" (endpos set).
Positions where the same substring ends share a state.

String: "aabab"
         12345

Endpos of "ab": {3, 5}  (appears ending at positions 3 and 5)
Endpos of "b":  {2, 3, 5}
Endpos of "aab": {3}
Endpos of "a":  {1, 2, 4}

Key property: If two strings have same endpos,
              one must be a suffix of the other!

This allows massive compression:
  All substrings with same endpos → one state
```

## SAM Structure

```
String: "abab"

SAM states and transitions:
         ┌─a─→ [a] ──b──→ [ab] ─a─→ [aba] ─b─→ [abab]
  [init] ─┤
         └─b─→ [b] ──a──→ [ba] ──b──→ [bab]
                           ↑
                      (clone of aba minus ab prefix)

Suffix links (form a tree):
  [abab] → [bab] → [ab] → [b] → [init]
  [aba] → [ba] → [a] → [init]

Each state represents multiple substrings with same endpos!
```

## State Properties

```
Each state q has:
  - len[q]: length of longest string in this state
  - link[q]: suffix link to state with shorter strings
  - trans[q][c]: transition on character c

Substrings represented by state q:
  All strings of length (len[link[q]] + 1) to len[q]

Example state for "abab":
  len = 4, link points to state with len = 3 ("bab")
  This state represents only "abab"

Example state for ["ab", "b"]:
  len = 2, link points to init (len = 0)
  This state represents "ab" and "b" (both have endpos {2,4})
```

## Clone Operation

```
When extending SAM with new character, sometimes we need to clone:

Before adding 'b' to "aba":
  State [a] has transition on 'a' to [a] (for "aa")

Problem: New suffix "ab" has different endpos than "aab"
         But they currently share a state!

Solution: Clone the state
  1. Create new state with same transitions
  2. Split the endpos set between original and clone
  3. Update suffix links appropriately
```

## Algorithm Walkthrough

```
Build SAM for "ab":

Initial: [init] (len=0, link=null)

Add 'a':
  Create [a] (len=1)
  Transition: init ─a→ [a]
  Suffix link: [a] → init

  SAM: init ─a→ [a]

Add 'b':
  Create [ab] (len=2)
  Transition: [a] ─b→ [ab]

  Follow suffix links from [a]:
    init has no 'b' transition → add init ─b→ [ab]?
    No! "b" has different endpos than "ab"

  Need separate state [b] for just "b":
  Transition: init ─b→ [b]
  Suffix link: [ab] → [b] → init

  Final SAM:
  init ─a→ [a] ─b→ [ab]
      └─b→ [b]
  Suffix links: [ab]→[b]→init, [a]→init
```

## Example Usage

```mbt check
///|
test "suffix automaton example" {
  let sam = @suffix_automaton.SuffixAutomaton::new(10)
  sam.build("abab")
  inspect(sam.contains("aba"), content="true")
  inspect(sam.count_distinct_substrings(), content="7")
  inspect(
    @suffix_automaton.longest_common_substring("abcde", "cdefg"),
    content="3",
  )
}
```

## Common Applications

### 1. Substring Check
```
Is P a substring of S?
Build SAM for S, walk P from init.
If all transitions exist → P is substring.
Time: O(|P|) after O(|S|) preprocessing.
```

### 2. Count Distinct Substrings
```
Sum of (len[q] - len[link[q]]) for all states.
Each state contributes its unique substrings.
Answer for "abab": 7 (a, b, ab, ba, aba, bab, abab)
```

### 3. Count Occurrences
```
How many times does P appear in S?
Navigate to state for P, return endpos size.
Precompute sizes via DFS on suffix link tree.
```

### 4. Longest Common Substring
```
Build SAM for S, walk T through it.
Track maximum matched length.
When stuck, follow suffix links.
Time: O(|S| + |T|)
```

## Complexity Analysis

| Operation | Time |
|-----------|------|
| Build SAM | O(n) |
| Substring check | O(m) |
| Distinct substrings | O(n) |
| Occurrence count (with prep) | O(m) |
| Longest common substring | O(n + m) |

## SAM vs Other String Structures

| Structure | Space | Build | Substring | LCS |
|-----------|-------|-------|-----------|-----|
| **SAM** | O(n) | O(n) | O(m) | O(n + m) |
| Suffix Array | O(n) | O(n) | O(m log n) | O(n log n) |
| Suffix Tree | O(n) | O(n) | O(m) | O(n + m) |
| Trie (all substr) | O(n²) | O(n²) | O(m) | — |

**Choose SAM when**: You need efficient substring operations with minimal space.

## Endpos Classes Theory

```
Endpos(s) = set of ending positions of substring s

Properties:
1. If u is suffix of v and both appear:
   Endpos(v) ⊆ Endpos(u)

2. For any two substrings u, v:
   Endpos(u) and Endpos(v) are either
   disjoint or one contains the other

3. This forms a tree structure!
   → The suffix link tree

Number of distinct endpos classes = O(n)
This is why SAM has O(n) states!
```

## Implementation Notes

- States: at most 2n - 1 states for string of length n
- Transitions: at most 3n - 4 transitions
- Use arrays for small alphabet (a-z), maps for large (Unicode)
- Clone operation is the tricky part—handle suffix links carefully
- For occurrence counting: compute endpos sizes via topological sort
- Suffix link tree root is init state
