# KMP (Knuth–Morris–Pratt) String Matching

## What KMP Solves

KMP finds **all occurrences** of a pattern in a text in **O(n + m)** time:

- `n` = text length
- `m` = pattern length

It avoids re-checking characters by using a **failure function** (also called
LPS or prefix function).

## Problem Example

Text: `ABABDABACDABABCABAB`
Pattern: `ABAB`

```
Text:    ABABDABACDABABCABAB
         ^^^^      ^^^^  ^^^^
Matches: 0         10    15
```

## Why Naive Search Is Slow

Naive matching restarts at the next character every time a mismatch happens.
This can repeat many comparisons.

Example:

```
Text:    AAAAAAB
Pattern: AAAB

Naive comparisons:
  pos 0: AAA? fail
  pos 1: AAA? fail
  pos 2: AAA? fail
  pos 3: AAAB match

Lots of repeated work.
```

KMP avoids re-checking by jumping to the next possible valid prefix.

## The Failure Function (LPS / Prefix Function)

For each position `i`, the failure value tells us:

```
fail[i] = length of the longest proper prefix of pattern[0..i]
         that is also a suffix of pattern[0..i]
```

### Example: Pattern "ABAB"

```
Index:   0 1 2 3
Pattern: A B A B
Fail:    0 0 1 2
```

Why `fail[3] = 2`?

```
Pattern: A B A B
         ===       prefix "AB"
             ===   suffix "AB"
```

### Another Example: Pattern "ABACABA"

```
Index:   0 1 2 3 4 5 6
Pattern: A B A C A B A
Fail:    0 0 1 0 1 2 3
```

At index 6 (`ABACABA`), the longest border is `ABA` (length 3).

## How Matching Uses the Failure Function

Let `i` be index in text, `j` in pattern.

- If `text[i] == pattern[j]`, advance both.
- If mismatch and `j > 0`, set `j = fail[j - 1]`.
- If mismatch and `j == 0`, advance `i` only.

This means `i` never goes backward, so the search is linear.

## Walkthrough Example

Text: `ABABDABACDABABCABAB`
Pattern: `ABAB`

```
Start: i=0, j=0
A==A -> i=1, j=1
B==B -> i=2, j=2
A==A -> i=3, j=3
B==B -> i=4, j=4 (match!)
Record match at i-m = 0
j = fail[3] = 2 (reuse "AB")

Next:
D vs A mismatch
j = fail[1] = 0
Continue from i=4
```

KMP keeps the valid prefix and skips redundant comparisons.

## Overlapping Matches (KMP Handles Them)

Text: `AAAA`
Pattern: `AA`

Matches at indices `[0, 1, 2]`:

```
AAAA
^^
 ^^
  ^^
```

KMP naturally finds overlaps because after a match it falls back using `fail`.

## API Examples

```mbt check
///|
test "kmp complete example" {
  let text = "ababcababa"
  let pattern = "aba"

  // All occurrences
  inspect(@kmp.kmp_search(text, pattern), content="[0, 5, 7]")

  // First occurrence
  inspect(@kmp.kmp_find_first(text, "cab"), content="4")
  inspect(@kmp.kmp_find_first(text, "xyz"), content="-1")

  // Count occurrences
  inspect(@kmp.kmp_count(text, pattern), content="3")

  // Failure function
  let fail = @kmp.compute_failure("ABAB")
  inspect(fail, content="[0, 0, 1, 2]")

  // Prefix function alias
  let pi = @kmp.prefix_function("ababa")
  inspect(pi, content="[0, 0, 1, 2, 3]")
}
```

## Z-Function (Alternative Tool)

The Z-function measures how far the prefix matches at each position.

Example:

```
String:  A A B X A A B
Z:       7 1 0 0 3 1 0
          ^       ^
          |       "AAB" matches prefix
          entire string matches itself
```

You can use Z for pattern matching by building:

```
pattern + "$" + text
```

Then every position with `z[i] == pattern.length()` is a match.

```mbt check
///|
test "z-function example" {
  let z = @kmp.compute_z_function("AABXAAB")
  inspect(z[0], content="7")
  inspect(z[1], content="1")
  inspect(z[4], content="3")
  let matches = @kmp.z_search("ABABDABACDABABCABAB", "ABAB")
  inspect(matches.length(), content="3")
}
```

## Diagram: Why Failure Saves Work

```
Pattern:  A B A B
Fail:     0 0 1 2

Text:     A B A B D ...
           ^^^^

Mismatch at D:
  Instead of restarting from pattern[0],
  we set j = fail[3] = 2 and continue with "AB" already matched.
```

## Complexity

| Step | Time | Space |
|------|------|-------|
| Build fail | O(m) | O(m) |
| Search | O(n) | O(1) + fail |
| Total | O(n + m) | O(m) |

## Common Pitfalls

- **Empty pattern**: this implementation returns an empty match list.
- **Unicode details**: indexing in MoonBit strings is by UTF‑16 code units.
  For grapheme‑level matching, preprocess into code points.
- **Case sensitivity**: comparisons are exact; normalize if needed.

## When to Use KMP

- You need all occurrences of one pattern
- The text is large and repeated scanning is expensive
- You want linear time guarantees

## KMP vs Alternatives

| Algorithm | Preprocess | Search | Notes |
|----------|------------|--------|------|
| Naive | O(1) | O(nm) | tiny patterns only |
| **KMP** | O(m) | O(n) | single pattern |
| Z-function | O(n+m) | O(n+m) | alternative to KMP |
| Rabin–Karp | O(m) | O(n) average | multiple patterns |

KMP is the classic choice for a single pattern with linear guarantees.
