# Fast Walsh-Hadamard Transform (XOR)

## Overview

FWHT computes the XOR transform in O(n log n). The inverse transform divides
by `n` and recovers the original array (when values are integral).

- **Time**: O(n log n)
- **Space**: O(n)

## Example

```mbt check
///|
test "fwht xor convolution" {
  let a : Array[Int64] = [1L, 2L, 3L, 4L]
  let b : Array[Int64] = [5L, 6L, 7L, 8L]
  let c = @fwht.xor_convolution(a[:], b[:])
  inspect(c, content="[70, 68, 62, 60]")
}
```
