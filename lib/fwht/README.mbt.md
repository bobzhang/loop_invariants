# Fast Walsh-Hadamard Transform (XOR)

## Overview

FWHT computes the XOR transform in O(n log n). The inverse transform divides
by `n` and recovers the original array (when values are integral).

- **Time**: O(n log n)
- **Space**: O(n)

## Requirements

- The array length must be a power of two.
- XOR convolution uses the XOR transform and its inverse.

## Core Idea

FWHT applies a butterfly operation at each scale:

```
(a, b) -> (a + b, a - b)
```

Repeated over log n levels, this diagonalizes XOR convolution. The inverse
transform applies the same butterflies and divides by n.

## Roundtrip Example

```mbt check
///|
test "fwht xor roundtrip" {
  let a : Array[Int64] = [1L, 2L, 3L, 4L]
  let t = @fwht.fwht_xor(a[:], false)
  let inv = @fwht.fwht_xor(t[:], true)
  inspect(inv, content="[1, 2, 3, 4]")
}
```

## XOR Convolution Example

```mbt check
///|
test "fwht xor convolution" {
  let a : Array[Int64] = [1L, 2L, 3L, 4L]
  let b : Array[Int64] = [5L, 6L, 7L, 8L]
  let c = @fwht.xor_convolution(a[:], b[:])
  inspect(c, content="[70, 68, 62, 60]")
}
```
