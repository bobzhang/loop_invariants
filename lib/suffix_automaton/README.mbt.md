# Suffix Automaton (Extended)

This package implements a **suffix automaton (SAM)** with extra utilities:

- substring checks,
- distinct substring count,
- longest common substring length.

It builds in **O(n)** time and space.

---

## 1. What is a suffix automaton?

A suffix automaton is a minimal DFA that recognizes **all substrings** of a
string.

That means:

```
P is a substring of S  <=>  SAM built from S accepts P
```

Unlike a trie of all substrings (which is huge), SAM is compact:

```
at most 2n - 1 states for a string of length n
```

---

## 2. Intuition: groups of substrings

Many substrings end in the **same positions** in the text.

SAM groups them into one state.

Example with `"abab"`:

```
"ab" ends at positions {1, 3}
"b"  ends at positions {1, 3}

Same end positions -> same SAM state
```

This is the key compression.

---

## 3. Visual overview (small SAM)

For `"abab"`:

```
init --a--> [a] --b--> [ab] --a--> [aba] --b--> [abab]
  \                             ^
   \--b--> [b] --a--> [ba] -----|
```

Each state represents multiple substrings that share the same end positions.

---

## 4. Suffix links (backbone)

Each state has a **suffix link** to the state representing its longest proper
suffix.

Example:

```
"abab" -> "bab" -> "ab" -> "b" -> ""
```

Following suffix links is like walking through suffixes.

---

## 5. Example usage (public API)

```mbt check
///|
test "suffix automaton example" {
  let sam = @suffix_automaton.SuffixAutomaton::new(10)
  sam.build("abab")
  inspect(sam.contains("aba"), content="true")
  inspect(sam.contains("ac"), content="false")
  inspect(sam.count_distinct_substrings(), content="7")
  inspect(
    @suffix_automaton.longest_common_substring("abcde", "cdefg"),
    content="3",
  )
}
```

---

## 6. Distinct substrings count

Each state `q` contributes:

```
len[q] - len[link[q]]
```

Summing over all states gives the number of **distinct substrings**.

Example `"abab"`:

```
a, b, ab, ba, aba, bab, abab  -> 7
```

---

## 7. Longest common substring (idea)

Build SAM for S, then walk through T:

```
if transition exists -> extend match
if not -> follow suffix links
track max length seen
```

Total time: O(|S| + |T|).

---

## 8. Complexity

```
Build SAM: O(n)
Substring check: O(m)
Distinct substrings: O(n)
Longest common substring: O(n + m)
```

---

## 9. Beginner checklist

1. SAM works for **substrings**, not just suffixes.
2. It uses suffix links to compress states.
3. Maximum states is 2n - 1.
4. For each query, just walk transitions.

---

## 10. Summary

Suffix automaton is one of the most powerful linear string structures:

- compact,
- fast substring checks,
- useful for many advanced string tasks.
