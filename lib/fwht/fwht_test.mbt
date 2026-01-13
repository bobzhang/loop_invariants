///|
test "fwht xor roundtrip" {
  let a : Array[Int64] = [1L, 2L, 3L, 4L]
  let t = @fwht.fwht_xor(a[:], false)
  let inv = @fwht.fwht_xor(t[:], true)
  inspect(inv, content="[1, 2, 3, 4]")
}

///|
test "fwht xor convolution" {
  let a : Array[Int64] = [1L, 2L, 3L, 4L]
  let b : Array[Int64] = [5L, 6L, 7L, 8L]
  let c = @fwht.xor_convolution(a[:], b[:])
  inspect(c, content="[70, 68, 62, 60]")
}
