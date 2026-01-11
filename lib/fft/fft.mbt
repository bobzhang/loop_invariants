// ============================================================================
// FFT/NTT - Fast Polynomial Multiplication
// ============================================================================
//
// Fast Fourier Transform (FFT) and Number Theoretic Transform (NTT) enable
// O(n log n) polynomial multiplication by converting to/from point-value form.
//
// KEY INSIGHT: Multiplying polynomials in coefficient form is O(n²), but
// in point-value form (evaluations) it's O(n). FFT converts in O(n log n).
//
// NTT BASICS:
// Uses primitive roots of unity in modular arithmetic instead of complex numbers.
// For prime p = k * 2^m + 1, primitive root g exists where g^((p-1)/2^m) is
// a 2^m-th root of unity modulo p.
//
// Common NTT-friendly primes:
// - 998244353 = 119 * 2^23 + 1, primitive root = 3
// - 167772161 = 5 * 2^25 + 1, primitive root = 3
//
// ALGORITHM (Cooley-Tukey):
// 1. Bit-reverse permutation of coefficients
// 2. Iteratively combine pairs using butterfly operations
// 3. For inverse, use conjugate roots and divide by n
//
// INVARIANTS:
// 1. After stage k, groups of 2^k elements are DFT of their original positions
// 2. Bit-reversal maps index i to bit-reverse(i), preserving correct DFT ordering
// 3. After inverse transform and division by n, original coefficients recovered
//
// TIME COMPLEXITY: O(n log n)
// SPACE COMPLEXITY: O(n)

///|
const NTT_MOD : Int64 = 998244353L

///|
const NTT_ROOT : Int64 = 3L

///|
/// Fast modular exponentiation
fn mod_pow(base : Int64, exp : Int64, m : Int64) -> Int64 {
  let mut result = 1L
  let mut b = base % m
  let mut e = exp
  while e > 0L {
    if e % 2L == 1L {
      result = result * b % m
    }
    b = b * b % m
    e = e / 2L
  }
  result
}

///|
/// Compute bit reversal of index
fn bit_reverse(x : Int, bits : Int) -> Int {
  let mut result = 0
  let mut v = x
  for i = 0; i < bits; i = i + 1 {
    result = (result << 1) | (v & 1)
    v = v >> 1
  } where {
    invariant: i >= 0 && i <= bits,
    reasoning: (
      #|result holds the reverse of the lowest i bits of x; v has been shifted
      #|right by i bits so the next bit to consume is at position 0.
    ),
  }
  result
}

///|
/// Number Theoretic Transform
priv struct NTT {
  n : Int // Must be power of 2
  log_n : Int
  root : Int64
  root_inv : Int64
  mod_val : Int64
}

///|
fn NTT::new(size : Int) -> NTT {
  // Find smallest power of 2 >= size
  let mut n = 1
  let mut log_n = 0
  while n < size {
    n = n * 2
    log_n = log_n + 1
  }
  let root = mod_pow(NTT_ROOT, (NTT_MOD - 1L) / n.to_int64(), NTT_MOD)
  let root_inv = mod_pow(root, NTT_MOD - 2L, NTT_MOD)
  { n, log_n, root, root_inv, mod_val: NTT_MOD }
}

///|
/// Perform NTT in-place
fn NTT::transform(self : NTT, a : Array[Int64], inverse : Bool) -> Unit {
  let n = self.n

  // Bit-reverse permutation
  for i = 0; i < n; i = i + 1 {
    let j = bit_reverse(i, self.log_n)
    if i < j {
      let tmp = a[i]
      a[i] = a[j]
      a[j] = tmp
    }
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: "I: Array unsorted. M: Swap a[i] with a[bit_reverse(i)] when i < j (to avoid double swap). T: Array in bit-reversed order for Cooley-Tukey algorithm.",
  }

  // Cooley-Tukey NTT
  let mut len = 2
  while len <= n {
    let w_base = if inverse { self.root_inv } else { self.root }
    let w = mod_pow(w_base, (n / len).to_int64(), self.mod_val)
    for i = 0; i < n; i = i + len {
      let mut wn = 1L
      for j = 0; j < len / 2; j = j + 1 {
        let u = a[i + j]
        let v = a[i + j + len / 2] * wn % self.mod_val
        a[i + j] = (u + v) % self.mod_val
        a[i + j + len / 2] = ((u - v) % self.mod_val + self.mod_val) %
          self.mod_val
        wn = wn * w % self.mod_val
      } where {
        invariant: j >= 0 && j <= len / 2,
        reasoning: (
          #|Within the current block, all butterflies for positions [0..j)
          #|are applied; wn equals w^j.
        ),
      }
    } where {
      invariant: i >= 0 && i <= n,
      reasoning: (
        #|All blocks starting at indices < i have been combined for this stage
        #|of length len.
      ),
    }
    len = len * 2
  }

  // For inverse, divide by n
  if inverse {
    let n_inv = mod_pow(n.to_int64(), self.mod_val - 2L, self.mod_val)
    for i = 0; i < n; i = i + 1 {
      a[i] = a[i] * n_inv % self.mod_val
    } where {
      invariant: i >= 0 && i <= n,
      reasoning: (
        #|a[0..i) has been scaled by n_inv to complete the inverse transform.
      ),
    }
  }
}

///|
/// Multiply two polynomials modulo NTT_MOD
fn NTT::multiply(
  self : NTT,
  a : Array[Int64],
  b : Array[Int64],
) -> Array[Int64] {
  let n = self.n

  // Pad arrays to size n
  let pa = Array::make(n, 0L)
  let pb = Array::make(n, 0L)
  for i = 0; i < a.length() && i < n; i = i + 1 {
    pa[i] = a[i] % self.mod_val
  } where {
    invariant: i >= 0 && i <= a.length() && i <= n,
    reasoning: (
      #|pa[0..i) holds the reduced coefficients from a[0..i).
    ),
  }
  for i = 0; i < b.length() && i < n; i = i + 1 {
    pb[i] = b[i] % self.mod_val
  } where {
    invariant: i >= 0 && i <= b.length() && i <= n,
    reasoning: (
      #|pb[0..i) holds the reduced coefficients from b[0..i).
    ),
  }

  // Transform both
  self.transform(pa, false)
  self.transform(pb, false)

  // Point-wise multiplication
  for i = 0; i < n; i = i + 1 {
    pa[i] = pa[i] * pb[i] % self.mod_val
  } where {
    invariant: i >= 0 && i <= n,
    reasoning: "I: pa, pb contain NTT of inputs. M: Multiply corresponding point values. Convolution theorem: NTT(a*b) = NTT(a) * NTT(b) pointwise. T: pa contains NTT of product.",
  }

  // Inverse transform
  self.transform(pa, true)
  pa
}

// ============================================================================
// SIMPLE POLYNOMIAL MULTIPLICATION (for comparison)
// ============================================================================

///|
/// O(n²) naive polynomial multiplication
fn poly_multiply_naive(a : Array[Int64], b : Array[Int64]) -> Array[Int64] {
  if a.length() == 0 || b.length() == 0 {
    return []
  }
  let result = Array::make(a.length() + b.length() - 1, 0L)
  for i = 0; i < a.length(); i = i + 1 {
    for j = 0; j < b.length(); j = j + 1 {
      result[i + j] = (result[i + j] + a[i] * b[j]) % NTT_MOD
    } where {
      invariant: j >= 0 && j <= b.length(),
      reasoning: (
        #|All pairs (i, 0..j) have contributed to result[i + *].
      ),
    }
  } where {
    invariant: i >= 0 && i <= a.length(),
    reasoning: (
      #|All pairs (0..i, *) have been accumulated into result.
    ),
  }
  result
}

// ============================================================================
// KARATSUBA MULTIPLICATION (O(n^1.58))
// ============================================================================

///|
/// Karatsuba polynomial multiplication
fn poly_multiply_karatsuba(a : Array[Int64], b : Array[Int64]) -> Array[Int64] {
  let n = a.length()
  let m = b.length()
  if n == 0 || m == 0 {
    return []
  }
  if n < 32 || m < 32 {
    return poly_multiply_naive(a, b)
  }
  let half = (if n > m { n } else { m }) / 2

  // Split: a = a_low + x^half * a_high
  let a_low : Array[Int64] = []
  let a_high : Array[Int64] = []
  for i = 0; i < a.length(); i = i + 1 {
    if i < half {
      a_low.push(a[i])
    } else {
      a_high.push(a[i])
    }
  } where {
    invariant: i >= 0 && i <= a.length(),
    reasoning: (
      #|a_low contains a[0..min(i,half)); a_high contains a[half..i) when i > half.
    ),
  }
  let b_low : Array[Int64] = []
  let b_high : Array[Int64] = []
  for i = 0; i < b.length(); i = i + 1 {
    if i < half {
      b_low.push(b[i])
    } else {
      b_high.push(b[i])
    }
  } where {
    invariant: i >= 0 && i <= b.length(),
    reasoning: (
      #|b_low contains b[0..min(i,half)); b_high contains b[half..i) when i > half.
    ),
  }

  // Recursive multiplications
  let z0 = poly_multiply_karatsuba(a_low, b_low)
  let z2 = poly_multiply_karatsuba(a_high, b_high)

  // z1 = (a_low + a_high)(b_low + b_high) - z0 - z2
  let a_sum : Array[Int64] = []
  let b_sum : Array[Int64] = []
  let max_low = if a_low.length() > a_high.length() {
    a_low.length()
  } else {
    a_high.length()
  }
  for i = 0; i < max_low; i = i + 1 {
    let av = if i < a_low.length() { a_low[i] } else { 0L }
    let ah = if i < a_high.length() { a_high[i] } else { 0L }
    a_sum.push((av + ah) % NTT_MOD)
  } where {
    invariant: i >= 0 && i <= max_low,
    reasoning: (
      #|a_sum[0..i) equals (a_low + a_high) coefficient-wise.
    ),
  }
  let max_low_b = if b_low.length() > b_high.length() {
    b_low.length()
  } else {
    b_high.length()
  }
  for i = 0; i < max_low_b; i = i + 1 {
    let bv = if i < b_low.length() { b_low[i] } else { 0L }
    let bh = if i < b_high.length() { b_high[i] } else { 0L }
    b_sum.push((bv + bh) % NTT_MOD)
  } where {
    invariant: i >= 0 && i <= max_low_b,
    reasoning: (
      #|b_sum[0..i) equals (b_low + b_high) coefficient-wise.
    ),
  }
  let z1_full = poly_multiply_karatsuba(a_sum, b_sum)

  // Combine: result = z0 + x^half * z1 + x^(2*half) * z2
  let result_len = n + m - 1
  let result = Array::make(result_len, 0L)
  for i = 0; i < z0.length(); i = i + 1 {
    result[i] = (result[i] + z0[i]) % NTT_MOD
  } where {
    invariant: i >= 0 && i <= z0.length(),
    reasoning: (
      #|result[0..i) contains the z0 contribution.
    ),
  }
  for i = 0; i < z1_full.length(); i = i + 1 {
    if i + half < result_len {
      let sub = if i < z0.length() { z0[i] } else { 0L }
      let sub2 = if i < z2.length() { z2[i] } else { 0L }
      result[i + half] = (
          (result[i + half] + z1_full[i] - sub - sub2) % NTT_MOD + NTT_MOD
        ) %
        NTT_MOD
    }
  } where {
    invariant: i >= 0 && i <= z1_full.length(),
    reasoning: (
      #|result[half..half+i) has been adjusted with z1_full and subtracted z0/z2.
    ),
  }
  for i = 0; i < z2.length(); i = i + 1 {
    if i + 2 * half < result_len {
      result[i + 2 * half] = (result[i + 2 * half] + z2[i]) % NTT_MOD
    }
  } where {
    invariant: i >= 0 && i <= z2.length(),
    reasoning: (
      #|result[2*half..2*half+i) includes the z2 contribution.
    ),
  }
  result
}

// ============================================================================
// TESTS
// ============================================================================

///|
test "ntt basic multiplication" {
  // (1 + 2x) * (3 + 4x) = 3 + 10x + 8x²
  let a : Array[Int64] = [1L, 2L]
  let b : Array[Int64] = [3L, 4L]
  let ntt = NTT::new(4)
  let result = ntt.multiply(a, b)
  inspect(result[0], content="3")
  inspect(result[1], content="10")
  inspect(result[2], content="8")
}

///|
test "ntt larger multiplication" {
  // (1 + x + x²) * (1 + x + x²) = 1 + 2x + 3x² + 2x³ + x⁴
  let a : Array[Int64] = [1L, 1L, 1L]
  let b : Array[Int64] = [1L, 1L, 1L]
  let ntt = NTT::new(8)
  let result = ntt.multiply(a, b)
  inspect(result[0], content="1")
  inspect(result[1], content="2")
  inspect(result[2], content="3")
  inspect(result[3], content="2")
  inspect(result[4], content="1")
}

///|
test "ntt vs naive" {
  let a : Array[Int64] = [1L, 2L, 3L, 4L]
  let b : Array[Int64] = [5L, 6L, 7L, 8L]
  let ntt = NTT::new(8)
  let ntt_result = ntt.multiply(a, b)
  let naive_result = poly_multiply_naive(a, b)
  for i = 0; i < naive_result.length(); i = i + 1 {
    inspect(ntt_result[i] == naive_result[i], content="true")
  } where {
    invariant: i >= 0 && i <= naive_result.length(),
    reasoning: (
      #|Results match for indices [0..i).
    ),
  }
}

///|
test "karatsuba vs naive" {
  let a : Array[Int64] = [1L, 2L, 3L, 4L, 5L]
  let b : Array[Int64] = [6L, 7L, 8L, 9L, 10L]
  let karatsuba_result = poly_multiply_karatsuba(a, b)
  let naive_result = poly_multiply_naive(a, b)
  inspect(karatsuba_result.length() == naive_result.length(), content="true")
  for i = 0; i < naive_result.length(); i = i + 1 {
    inspect(karatsuba_result[i] == naive_result[i], content="true")
  } where {
    invariant: i >= 0 && i <= naive_result.length(),
    reasoning: (
      #|Results match for indices [0..i).
    ),
  }
}

///|
test "mod_pow" {
  inspect(mod_pow(3L, 0L, 7L), content="1")
  inspect(mod_pow(3L, 1L, 7L), content="3")
  inspect(mod_pow(3L, 2L, 7L), content="2") // 9 % 7 = 2
  inspect(mod_pow(2L, 10L, 1000L), content="24") // 1024 % 1000 = 24
}

///|
test "bit_reverse" {
  inspect(bit_reverse(0, 3), content="0")
  inspect(bit_reverse(1, 3), content="4") // 001 -> 100
  inspect(bit_reverse(2, 3), content="2") // 010 -> 010
  inspect(bit_reverse(3, 3), content="6") // 011 -> 110
}
