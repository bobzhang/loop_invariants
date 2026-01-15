# Aho-Corasick Algorithm

## Overview

The **Aho-Corasick Algorithm** finds all occurrences of multiple patterns in a
text simultaneously. It's like running many KMP searches at once.

- **Build**: O(Σ pattern lengths × alphabet size)
- **Search**: O(text length + number of matches)
- **Space**: O(Σ pattern lengths × alphabet size)

## The Problem

```
Patterns: ["he", "she", "his", "hers"]
Text:     "ushers"

Find ALL pattern occurrences:
  Position 1: "she" matches
  Position 2: "he" matches
  Position 2: "hers" matches

Naive: Run each pattern separately → O(n × m) per pattern
Aho-Corasick: One pass → O(n + total matches)
```

## The Key Insight

```
Combine patterns into a trie, then add "failure links"
that enable efficient transitions on mismatches.

Patterns: ["he", "she", "his", "hers"]

Trie:
         root
        /    \
       h      s
      / \      \
     e   i      h
     |   |      |
     r   s      e
     |
     s

When scanning "ushers":
- At 'u': no match, stay at root
- At 's': follow s transition
- At 'h': follow h from s
- At 'e': found "she"! Also follow failure link to "he"
- etc.
```

## Algorithm Components

### 1. Trie (Goto Function)

```
Build trie from all patterns:

Patterns: ["he", "she"]

        root
       /    \
      h      s
      |      |
      e*     h
             |
             e*

* marks accepting states (pattern ends here)
```

### 2. Failure Links

```
Failure link points to longest proper suffix that is
also a prefix of some pattern.

For "she":
  State after "sh": failure → "h" (from pattern "he")
  State after "she": failure → "he"

        root
       /    \
      h      s
      |      |
      e*←────h
       ↑     |
       └─────e*

Failure link from "she" to "he" because
"he" is longest suffix of "she" that's a pattern prefix.
```

### 3. Output Function

```
At each state, list all patterns that end there.

State "e" (from "she"):
  - "she" ends here directly
  - "he" ends here (via failure link)

So when we reach this state, we output both matches!
```

## Algorithm Walkthrough

```
Patterns: ["he", "she", "his"]
Text: "ushers"

Step-by-step:
  u: root → root (no 'u' edge, stay)
  s: root → s
  h: s → sh
  e: sh → she (Match "she"!)
       → follow failure to "he" (Match "he"!)
  r: she → sher
       → follow failure to "her"
  s: sher → shers
       → follow failure to "hers" (Match "hers"!)

Matches found: [("she", 1), ("he", 2), ("hers", 2)]
```

## Visual: Failure Link Traversal

```
When pattern doesn't continue, follow failure links:

At state "sh" trying to match 'x':
1. No 'x' edge from "sh"
2. Follow failure link to "h"
3. No 'x' edge from "h"
4. Follow failure link to root
5. No 'x' edge from root → stay at root

      sh ─fail→ h ─fail→ root
       ↓        ↓         ↓
      no x     no x      no x
```

## Example Usage

```mbt check
///|
test "aho corasick example" {
  let patterns : Array[String] = ["he", "she", "his", "hers"]
  let matches = @aho_corasick.find_all_matches(patterns[:], "ushers")
  inspect(matches.length(), content="3")
  let found_she = matches.filter(m => m.2 == "she").length() > 0
  let found_he = matches.filter(m => m.2 == "he").length() > 0
  let found_hers = matches.filter(m => m.2 == "hers").length() > 0
  inspect(found_she && found_he && found_hers, content="true")
  inspect(@aho_corasick.count_all_matches(patterns[:], "ushers"), content="3")
}
```

## Building Failure Links (BFS)

```
Process states in BFS order (by depth):

Why BFS? Failure link of depth-d state points to
state with depth < d. So all targets are processed
before their sources.

Queue: [h, s]  (depth 1)

Process h:
  failure[h] = root

Process s:
  failure[s] = root

Queue: [e, i, h]  (depth 2)

Process e (from h):
  Follow failure[h]=root, check if root has 'e' edge
  No → failure[e] = root

Process h (from s):
  Follow failure[s]=root, check if root has 'h' edge
  Yes → failure[sh] = h

...and so on
```

## Common Applications

### 1. Multi-Pattern Search
```
Find all occurrences of dictionary words in text
Use case: Spam detection, sensitive word filtering
```

### 2. DNA Sequence Matching
```
Find all known gene sequences in a genome
Patterns: known genes, text: genome
```

### 3. Network Intrusion Detection
```
Match packet payloads against signature database
Real-time matching with streaming input
```

### 4. Text Indexing
```
Preprocess patterns, then search multiple texts
Amortize O(m) build cost across many searches
```

## Complexity Analysis

| Operation | Time |
|-----------|------|
| Add pattern | O(pattern length) |
| Build automaton | O(total pattern length × alphabet) |
| Search | O(text length + matches) |

## Aho-Corasick vs Alternatives

| Method | Patterns | Build | Search |
|--------|----------|-------|--------|
| **Aho-Corasick** | Multiple | O(m × σ) | O(n + z) |
| KMP (per pattern) | Single | O(m) | O(n) |
| Rabin-Karp | Multiple | O(m) | O(n × k) expected |
| Suffix Array | Multiple | O(n log n) | O(m log n) per pattern |

n = text length, m = total pattern length, k = pattern count, z = matches, σ = alphabet

**Choose Aho-Corasick when**: You have multiple patterns and need all matches.

## The Automaton View

```
Aho-Corasick builds a finite automaton:

States: All prefixes of all patterns
Transitions:
  - Goto: Follow trie edge if exists
  - Failure: Follow failure link otherwise

Input: Text characters one by one
Output: All patterns ending at current position

The automaton never backtracks in the text!
Each character advances the state exactly once.
```

## Implementation Notes

- Use array of size 256 for ASCII transitions (or map for Unicode)
- BFS order is crucial for building failure links
- Output links chain multiple matches at same position
- For streaming: maintain state between text chunks
- Memory optimization: compress sparse transition tables
