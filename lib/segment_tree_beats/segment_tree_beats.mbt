// ============================================================================
// SEGMENT TREE BEATS - Range chmin with max/sum queries
// ============================================================================
//
// Segment tree beats maintains, for each node covering interval [l, r):
// - max: maximum value in the interval
// - second_max: second largest value (< max), or -inf if all equal
// - count_max: number of elements equal to max
// - sum: sum of all values in the interval
//
// KEY INSIGHT:
// For a range chmin update with value x, if x is strictly greater than
// second_max, only the elements equal to max will change. We can update
// the node without descending further, and the amortized complexity stays
// logarithmic (the "beats" effect).
//
// TIME COMPLEXITY:
// - range_chmin: O(log n) amortized
// - range_max/range_sum: O(log n)
//
// SPACE COMPLEXITY: O(n)

///|
const NEG_INF : Int64 = -9223372036854775807L

///|
fn max_i64(a : Int64, b : Int64) -> Int64 {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub struct SegmentTreeBeats {
  n : Int
  max : Array[Int64]
  second_max : Array[Int64]
  count_max : Array[Int]
  sum : Array[Int64]
}

///|
/// Build a segment tree beats structure from an array of Int64 values.
pub fn SegmentTreeBeats::new(values : ArrayView[Int64]) -> SegmentTreeBeats {
  let n = values.length()
  let size = if n == 0 { 0 } else { 4 * n }
  let max = Array::make(size, NEG_INF)
  let second_max = Array::make(size, NEG_INF)
  let count_max = Array::make(size, 0)
  let sum = Array::make(size, 0L)
  let st : SegmentTreeBeats = { n, max, second_max, count_max, sum }
  if n > 0 {
    st.build(1, 0, n, values)
  }
  st
}

///|
fn SegmentTreeBeats::build(
  self : SegmentTreeBeats,
  node : Int,
  l : Int,
  r : Int,
  values : ArrayView[Int64],
) -> Unit {
  if r - l == 1 {
    let v = values[l]
    self.max[node] = v
    self.second_max[node] = NEG_INF
    self.count_max[node] = 1
    self.sum[node] = v
  } else {
    let mid = (l + r) / 2
    self.build(node * 2, l, mid, values)
    self.build(node * 2 + 1, mid, r, values)
    self.pull(node)
  }
}

///|
/// Recompute node information from its children.
fn SegmentTreeBeats::pull(self : SegmentTreeBeats, node : Int) -> Unit {
  let left = node * 2
  let right = left + 1
  let left_max = self.max[left]
  let right_max = self.max[right]
  self.sum[node] = self.sum[left] + self.sum[right]
  if left_max > right_max {
    self.max[node] = left_max
    self.count_max[node] = self.count_max[left]
    self.second_max[node] = max_i64(self.second_max[left], right_max)
  } else if left_max < right_max {
    self.max[node] = right_max
    self.count_max[node] = self.count_max[right]
    self.second_max[node] = max_i64(self.second_max[right], left_max)
  } else {
    self.max[node] = left_max
    self.count_max[node] = self.count_max[left] + self.count_max[right]
    self.second_max[node] = max_i64(
      self.second_max[left],
      self.second_max[right],
    )
  }
}

///|
/// Apply chmin to a node assuming x > second_max and x < max.
fn SegmentTreeBeats::apply_chmin(
  self : SegmentTreeBeats,
  node : Int,
  x : Int64,
) -> Unit {
  let max_val = self.max[node]
  if x >= max_val {
    return
  }
  let diff = max_val - x
  self.sum[node] = self.sum[node] - diff * self.count_max[node].to_int64()
  self.max[node] = x
}

///|
/// Push max constraints from parent to children.
fn SegmentTreeBeats::push(self : SegmentTreeBeats, node : Int) -> Unit {
  let max_val = self.max[node]
  let left = node * 2
  let right = left + 1
  if self.max[left] > max_val {
    self.apply_chmin(left, max_val)
  }
  if self.max[right] > max_val {
    self.apply_chmin(right, max_val)
  }
}

///|
/// Apply range chmin: for i in [l, r), a[i] = min(a[i], x).
pub fn SegmentTreeBeats::range_chmin(
  self : SegmentTreeBeats,
  l : Int,
  r : Int,
  x : Int64,
) -> Unit {
  if self.n == 0 || l >= r {
    return
  }
  self.chmin_impl(1, 0, self.n, l, r, x)
}

///|
/// Recursively apply chmin while maintaining max/second_max invariants.
fn SegmentTreeBeats::chmin_impl(
  self : SegmentTreeBeats,
  node : Int,
  l : Int,
  r : Int,
  ql : Int,
  qr : Int,
  x : Int64,
) -> Unit {
  if qr <= l || r <= ql || x >= self.max[node] {
    return
  }
  if ql <= l && r <= qr && x > self.second_max[node] {
    self.apply_chmin(node, x)
    return
  }
  let mid = (l + r) / 2
  self.push(node)
  self.chmin_impl(node * 2, l, mid, ql, qr, x)
  self.chmin_impl(node * 2 + 1, mid, r, ql, qr, x)
  self.pull(node)
}

///|
/// Query maximum on [l, r).
pub fn SegmentTreeBeats::range_max(
  self : SegmentTreeBeats,
  l : Int,
  r : Int,
) -> Int64 {
  if self.n == 0 || l >= r {
    return NEG_INF
  }
  self.max_impl(1, 0, self.n, l, r)
}

///|
fn SegmentTreeBeats::max_impl(
  self : SegmentTreeBeats,
  node : Int,
  l : Int,
  r : Int,
  ql : Int,
  qr : Int,
) -> Int64 {
  if qr <= l || r <= ql {
    return NEG_INF
  }
  if ql <= l && r <= qr {
    return self.max[node]
  }
  let mid = (l + r) / 2
  self.push(node)
  let left = self.max_impl(node * 2, l, mid, ql, qr)
  let right = self.max_impl(node * 2 + 1, mid, r, ql, qr)
  max_i64(left, right)
}

///|
/// Query sum on [l, r).
pub fn SegmentTreeBeats::range_sum(
  self : SegmentTreeBeats,
  l : Int,
  r : Int,
) -> Int64 {
  if self.n == 0 || l >= r {
    return 0L
  }
  self.sum_impl(1, 0, self.n, l, r)
}

///|
fn SegmentTreeBeats::sum_impl(
  self : SegmentTreeBeats,
  node : Int,
  l : Int,
  r : Int,
  ql : Int,
  qr : Int,
) -> Int64 {
  if qr <= l || r <= ql {
    return 0L
  }
  if ql <= l && r <= qr {
    return self.sum[node]
  }
  let mid = (l + r) / 2
  self.push(node)
  let left = self.sum_impl(node * 2, l, mid, ql, qr)
  let right = self.sum_impl(node * 2 + 1, mid, r, ql, qr)
  left + right
}

// ============================================================================
// TESTS
// ============================================================================

///|
test "segment tree beats range chmin" {
  let values : Array[Int64] = [5L, 1L, 7L, 3L, 9L]
  let st = SegmentTreeBeats::new(values)
  inspect(st.range_sum(0, 5), content="25")
  inspect(st.range_max(0, 5), content="9")
  st.range_chmin(1, 4, 4L)
  inspect(st.range_sum(0, 5), content="22")
  inspect(st.range_max(0, 5), content="9")
  st.range_chmin(0, 5, 4L)
  inspect(st.range_sum(0, 5), content="16")
  inspect(st.range_max(0, 5), content="4")
  st.range_chmin(2, 5, 2L)
  inspect(st.range_sum(0, 5), content="11")
  inspect(st.range_max(0, 5), content="4")
}

///|
test "segment tree beats single element" {
  let st = SegmentTreeBeats::new([10L])
  inspect(st.range_sum(0, 1), content="10")
  inspect(st.range_max(0, 1), content="10")
  st.range_chmin(0, 1, 6L)
  inspect(st.range_sum(0, 1), content="6")
  inspect(st.range_max(0, 1), content="6")
}
