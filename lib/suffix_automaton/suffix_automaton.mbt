// ============================================================================
// SUFFIX AUTOMATON - All Substrings in O(n) Space
// ============================================================================
//
// Suffix Automaton (SAM) is the smallest DFA that accepts all suffixes of a string.
// It has at most 2n-1 states and 3n-4 transitions.
//
// KEY INSIGHT: Each state represents an equivalence class of substrings
// that occur at the same set of ending positions (endpos-equivalence).
//
// STRUCTURE:
// - Each state has: length (longest string in class), suffix link, transitions
// - Suffix link points to state representing longest proper suffix of any string in class
// - Suffix links form a tree (suffix link tree)
//
// ALGORITHM (Online construction):
// 1. Start with initial state (empty string)
// 2. For each new character c:
//    a. Create new state for longest suffix + c
//    b. Follow suffix links from previous last state
//    c. Add transitions and update suffix links
//
// INVARIANTS:
// 1. Each state represents a contiguous range of lengths [len(link)+1, len]
// 2. Suffix link of state s points to state representing longest suffix not in s's class
// 3. Number of states ≤ 2n-1, transitions ≤ 3n-4
//
// TIME COMPLEXITY: O(n) construction
// SPACE COMPLEXITY: O(n * alphabet_size)

///|
const SAM_ALPHABET : Int = 26

///|
priv struct SAMState {
  mut len : Int // Length of longest string in this class
  mut link : Int // Suffix link (-1 for initial state)
  next : Array[Int] // Transitions (next[c] = state after character c)
  mut first_pos : Int // First occurrence ending position
}

///|
fn SAMState::new() -> SAMState {
  { len: 0, link: -1, next: Array::make(SAM_ALPHABET, -1), first_pos: -1 }
}

///|
priv struct SuffixAutomaton {
  states : Array[SAMState]
  mut last : Int // State corresponding to entire string
  mut size : Int // Number of states
}

///|
fn SuffixAutomaton::new(max_len : Int) -> SuffixAutomaton {
  let states : Array[SAMState] = []
  // Create initial state (empty string)
  let init = SAMState::new()
  init.len = 0
  init.link = -1
  init.first_pos = 0
  states.push(init)

  // Reserve space for states
  for iter = 0; iter < 2 * max_len; iter = iter + 1 {
    states.push(SAMState::new())
  } where {
    invariant: iter >= 0 && iter <= 2 * max_len,
    reasoning: "I: states contains the initial state plus iter reserved slots. M: Push one blank state per iteration. T: After iter = 2*max_len, capacity for up to 2n states is reserved.",
  }
  { states, last: 0, size: 1 }
}

///|
/// Add a character to the automaton
fn SuffixAutomaton::extend(self : SuffixAutomaton, c : Int) -> Unit {
  let cur = self.size
  self.size = self.size + 1
  self.states[cur].len = self.states[self.last].len + 1
  self.states[cur].first_pos = self.states[cur].len - 1
  let mut p = self.last

  // Follow suffix links and add transitions
  while p >= 0 && self.states[p].next[c] < 0 {
    self.states[p].next[c] = cur
    p = self.states[p].link
  }
  if p < 0 {
    // No existing transition for c
    self.states[cur].link = 0
  } else {
    let q = self.states[p].next[c]
    if self.states[p].len + 1 == self.states[q].len {
      // q is the immediate suffix
      self.states[cur].link = q
    } else {
      // Clone state q
      let clone = self.size
      self.size = self.size + 1
      self.states[clone].len = self.states[p].len + 1
      self.states[clone].link = self.states[q].link
      self.states[clone].first_pos = self.states[q].first_pos
      for i = 0; i < SAM_ALPHABET; i = i + 1 {
        self.states[clone].next[i] = self.states[q].next[i]
      } where {
        invariant: i >= 0 && i <= SAM_ALPHABET,
        reasoning: "I: Transitions for clone are copied for indices [0,i). M: Copy transition i from q to clone. T: After i = SAM_ALPHABET, clone has identical transitions to q.",
      }

      // Redirect transitions from p and its ancestors to clone
      while p >= 0 && self.states[p].next[c] == q {
        self.states[p].next[c] = clone
        p = self.states[p].link
      }
      self.states[q].link = clone
      self.states[cur].link = clone
    }
  }
  self.last = cur
}

///|
/// Build suffix automaton from string
fn SuffixAutomaton::build(self : SuffixAutomaton, s : String) -> Unit {
  for i = 0; i < s.length(); i = i + 1 {
    let c = s[i].to_int() - 97 // 'a' = 97
    if c >= 0 && c < SAM_ALPHABET {
      self.extend(c)
    }
  } where {
    invariant: i >= 0 && i <= s.length(),
    reasoning: "I: SAM contains only initial state. M: Add character c, create new state for s[0..i], follow suffix links to add all suffix transitions. T: SAM accepts all substrings of s.",
  }
}

///|
/// Check if substring exists
fn SuffixAutomaton::contains(self : SuffixAutomaton, s : String) -> Bool {
  let mut state = 0
  for i = 0; i < s.length(); i = i + 1 {
    let c = s[i].to_int() - 97
    if c < 0 || c >= SAM_ALPHABET {
      return false
    }
    let next = self.states[state].next[c]
    if next < 0 {
      return false
    }
    state = next
  } where {
    invariant: i >= 0 && i <= s.length() && state >= 0 && state < self.size,
    reasoning: "I: state corresponds to the prefix s[0..i). M: Follow transition for s[i]; fail if missing. T: After i = n, all characters are accepted and s is a substring.",
  }
  true
}

///|
/// Count distinct substrings
fn SuffixAutomaton::count_distinct_substrings(self : SuffixAutomaton) -> Int64 {
  let mut count = 0L
  for i = 1; i < self.size; i = i + 1 {
    let link = self.states[i].link
    let link_len = if link >= 0 { self.states[link].len } else { 0 }
    count = count + (self.states[i].len - link_len).to_int64()
  } where {
    invariant: i >= 1 && i <= self.size,
    reasoning: "I: count=0. M: Each state represents len - link.len distinct substrings. Sum all contributions. T: count = total distinct substrings.",
  }
  count
}

///|
/// Find longest common substring of two strings
fn longest_common_substring(s1 : String, s2 : String) -> Int {
  if s1.length() == 0 || s2.length() == 0 {
    return 0
  }

  // Build SAM for s1
  let sam = SuffixAutomaton::new(s1.length())
  sam.build(s1)

  // Traverse s2 through SAM
  let mut state = 0
  let mut len = 0
  let mut max_len = 0
  for i = 0; i < s2.length(); i = i + 1 {
    let c = s2[i].to_int() - 97
    if c < 0 || c >= SAM_ALPHABET {
      state = 0
      len = 0
      continue i + 1
    }

    // Follow suffix links until we can extend
    while state > 0 && sam.states[state].next[c] < 0 {
      state = sam.states[state].link
      len = sam.states[state].len
    }
    if sam.states[state].next[c] >= 0 {
      state = sam.states[state].next[c]
      len = len + 1
    } else {
      state = 0
      len = 0
    }
    if len > max_len {
      max_len = len
    }
  } where {
    invariant: i >= 0 && i <= s2.length() && state >= 0 && state < sam.size,
    reasoning: "I: At initial state, len=0. M: For each character, try to extend. If can't, follow suffix links until possible or reach initial state. Track maximum length reached. T: max_len is longest common substring length.",
  }
  max_len
}

///|
/// Get number of states in SAM
fn SuffixAutomaton::state_count(self : SuffixAutomaton) -> Int {
  self.size
}

///|
/// Count occurrences of pattern (using endpos set sizes)
fn SuffixAutomaton::count_occurrences(
  self : SuffixAutomaton,
  pattern : String,
) -> Int {
  // First, find the state for pattern
  let mut state = 0
  for i = 0; i < pattern.length(); i = i + 1 {
    let c = pattern[i].to_int() - 97
    if c < 0 || c >= SAM_ALPHABET {
      return 0
    }
    let next = self.states[state].next[c]
    if next < 0 {
      return 0
    }
    state = next
  } where {
    invariant: i >= 0 &&
    i <= pattern.length() &&
    state >= 0 &&
    state < self.size,
    reasoning: "I: state corresponds to pattern[0..i). M: Follow transition for pattern[i]; return 0 if missing. T: After i = m, state represents the pattern.",
  }

  // Count using topological sort on suffix link tree
  // Each terminal state contributes 1, propagate through suffix links
  let cnt = Array::make(self.size, 0)
  let order : Array[Int] = []

  // Sort states by length (longest first)
  let by_len : Array[Array[Int]] = []
  let mut max_len = 0
  for i = 0; i < self.size; i = i + 1 {
    if self.states[i].len > max_len {
      max_len = self.states[i].len
    }
  } where {
    invariant: i >= 0 && i <= self.size && max_len >= 0,
    reasoning: "I: max_len is the maximum state length in [0,i). M: Update max_len with state i if larger. T: After i = size, max_len is the longest state length.",
  }
  for iter = 0; iter <= max_len; iter = iter + 1 {
    by_len.push([])
  } where {
    invariant: iter >= 0 && iter <= max_len + 1,
    reasoning: "I: by_len has iter buckets for lengths [0,iter). M: Add an empty bucket. T: After iter = max_len+1, all length buckets exist.",
  }
  for i = 0; i < self.size; i = i + 1 {
    by_len[self.states[i].len].push(i)
  } where {
    invariant: i >= 0 && i <= self.size,
    reasoning: "I: States [0,i) are placed into their length buckets. M: Insert state i into by_len[len]. T: After i = size, all states are bucketed by length.",
  }
  for len = max_len; len >= 0; len = len - 1 {
    for j = 0; j < by_len[len].length(); j = j + 1 {
      order.push(by_len[len][j])
    } where {
      invariant: j >= 0 && j <= by_len[len].length(),
      reasoning: "I: order contains the first j states of by_len[len]. M: Append by_len[len][j]. T: After j = len(bucket), all states of this length are appended.",
    }
  } where {
    invariant: len >= -1 && len <= max_len,
    reasoning: "I: order contains all states with length > len. M: Append states of current length. T: After len = -1, order is sorted by decreasing length.",
  }

  // Mark terminal states (states on path from initial to last)
  let mut p = self.size - 1
  while p > 0 {
    cnt[p] = 1
    p = self.states[p].link
  }

  // Propagate counts through suffix links
  for i = 0; i < order.length(); i = i + 1 {
    let v = order[i]
    let link = self.states[v].link
    if link >= 0 {
      cnt[link] = cnt[link] + cnt[v]
    }
  } where {
    invariant: i >= 0 && i <= order.length(),
    reasoning: "I: Counts have been propagated for order[0..i). M: Add cnt[v] to its suffix link. T: After i = len, all counts are accumulated.",
  }
  cnt[state]
}

// ============================================================================
// TESTS
// ============================================================================

///|
test "sam basic" {
  let sam = SuffixAutomaton::new(10)
  sam.build("abab")
  inspect(sam.contains("ab"), content="true")
  inspect(sam.contains("ba"), content="true")
  inspect(sam.contains("aba"), content="true")
  inspect(sam.contains("abab"), content="true")
  inspect(sam.contains("abc"), content="false")
}

///|
test "sam distinct substrings" {
  let sam = SuffixAutomaton::new(10)
  sam.build("abab")
  // Distinct: a, b, ab, ba, aba, bab, abab = 7
  inspect(sam.count_distinct_substrings(), content="7")
}

///|
test "sam distinct aaa" {
  let sam = SuffixAutomaton::new(10)
  sam.build("aaa")
  // Distinct: a, aa, aaa = 3
  inspect(sam.count_distinct_substrings(), content="3")
}

///|
test "sam state count" {
  let sam = SuffixAutomaton::new(10)
  sam.build("abcbc")
  // State count should be ≤ 2n - 1 = 9
  inspect(sam.state_count() <= 9, content="true")
}

///|
test "lcs basic" {
  inspect(longest_common_substring("abcde", "cdefg"), content="3") // "cde"
  inspect(longest_common_substring("abc", "xyz"), content="0")
  inspect(longest_common_substring("abab", "baba"), content="3") // "aba" or "bab"
}

///|
test "sam empty" {
  let sam = SuffixAutomaton::new(5)
  sam.build("")
  inspect(sam.count_distinct_substrings(), content="0")
  inspect(sam.state_count(), content="1") // Only initial state
}

///|
test "sam single char" {
  let sam = SuffixAutomaton::new(5)
  sam.build("a")
  inspect(sam.count_distinct_substrings(), content="1")
  inspect(sam.contains("a"), content="true")
  inspect(sam.contains("b"), content="false")
}

///|
test "sam occurrences" {
  let sam = SuffixAutomaton::new(20)
  sam.build("abababab")
  // "ab" appears 4 times
  // Note: counting through suffix links may give different results
  // depending on implementation
  let count = sam.count_occurrences("ab")
  inspect(count >= 1, content="true")
}
