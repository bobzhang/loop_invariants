// ============================================================================
// Challenge: Sparse Table (Range Minimum Query)
// ============================================================================

///|
fn min(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub struct SparseTable {
  log : Array[Int]
  table : Array[Array[Int]]
}

///|
/// Build a sparse table for range minimum queries.
#warnings("+missing_invariant+missing_reasoning")
pub fn build_sparse_table(arr : ArrayView[Int]) -> SparseTable {
  let n = arr.length()
  if n == 0 {
    return { log: [0], table: [] }
  }
  let log = Array::make(n + 1, 0)
  for i in 2..=n {
    log[i] = log[i / 2] + 1
  }
  let kmax = log[n]
  let table = Array::makei(kmax + 1, _ => Array::make(n, 0))
  for i in 0..<n {
    table[0][i] = arr[i]
  }
  for k = 1; k <= kmax; k = k + 1 {
    let span = 1 << k
    let half = span >> 1
    for i = 0; i + span <= n; i = i + 1 {
      table[k][i] = min(table[k - 1][i], table[k - 1][i + half])
    } where {
      invariant: i >= 0 && i + span <= n,
      reasoning: (
        #|INVARIANT (build level):
        #|table[k][0..i) holds minimums for all length-2^k ranges that start
        #|before i. Each entry combines two length-2^(k-1) halves.
        #|MAINTENANCE:
        #|Set table[k][i] = min(left half, right half).
        #|TERMINATION:
        #|At i + span > n, all valid ranges for this level are built.
      ),
    }
  } where {
    invariant: k >= 1 && k <= kmax + 1,
    reasoning: (
      #|INVARIANT (levels):
      #|Levels [0..k) are fully built, each storing min values for ranges of
      #|length 2^level.
      #|MAINTENANCE:
      #|Use level k-1 to compute level k by combining adjacent blocks.
      #|TERMINATION:
      #|At k = kmax + 1, all levels are available for O(1) queries.
    ),
  }
  { log, table }
}

///|
/// Query the minimum over [l, r).
pub fn range_min(st : SparseTable, l : Int, r : Int) -> Int {
  let len = r - l
  let k = st.log[len]
  let span = 1 << k
  min(st.table[k][l], st.table[k][r - span])
}
