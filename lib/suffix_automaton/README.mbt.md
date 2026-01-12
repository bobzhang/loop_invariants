# Suffix Automaton (Reference, Extended)

An extended suffix automaton implementation with additional utilities and
queries over substring occurrences.

## What it demonstrates

- SAM construction with state cloning
- Transitions over a fixed alphabet
- Queries built on top of the automaton

## Pseudocode sketch

```mbt nocheck
extend(c)
follow transitions for queries
```

## Example

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

## Notes

- Time complexity: O(n) build
- This package is a reference implementation with invariants
