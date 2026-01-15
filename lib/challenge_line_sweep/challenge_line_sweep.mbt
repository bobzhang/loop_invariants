// ============================================================================
// Challenge: Line Sweep for Maximum Overlap
// ============================================================================

///|
priv struct Event {
  pos : Int
  delta : Int
}

///|
/// Compute the maximum number of overlapping intervals.
#warnings("+missing_invariant+missing_reasoning")
pub fn max_overlap(intervals : ArrayView[(Int, Int)]) -> Int {
  let events : Array[Event] = []
  for idx = 0; idx < intervals.length(); idx = idx + 1 {
    let (l, r) = intervals[idx]
    if l <= r {
      events.push({ pos: l, delta: 1 })
      events.push({ pos: r + 1, delta: -1 })
    }
  } where {
    invariant: idx >= 0 && idx <= intervals.length(),
    reasoning: (
      #|INVARIANT (event build):
      #|events contains endpoints for intervals[0..idx).
      #|MAINTENANCE:
      #|Add start/end events for intervals[idx] when valid.
      #|TERMINATION:
      #|At idx = intervals.length(), all events are built.
    ),
  }
  events.sort_by_key(e => e.pos)
  for i = 0, cur = 0, best = 0 {
    if i >= events.length() {
      break best
    } else {
      let new_cur = cur + events[i].delta
      let new_best = if new_cur > best { new_cur } else { best }
      continue i + 1, new_cur, new_best
    }
  } where {
    invariant: i >= 0 && i <= events.length(),
    reasoning: (
      #|INVARIANT (Sweep count):
      #|cur is the overlap count after processing events[0..i).
      #|best is the maximum overlap seen so far.
      #|MAINTENANCE:
      #|Apply the next delta and update best if needed.
      #|TERMINATION:
      #|At i = events.length(), best is the maximum overlap.
    ),
  }
}

///|
test "max_overlap" {
  let intervals : Array[(Int, Int)] = [(1, 3), (2, 5), (4, 6)]
  assert_eq(max_overlap(intervals[:]), 2)
  let intervals2 : Array[(Int, Int)] = [(1, 2), (3, 4)]
  assert_eq(max_overlap(intervals2[:]), 1)
}
