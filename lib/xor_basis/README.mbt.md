# XOR Basis (Beginner-Friendly Guide)

An XOR basis stores a set of numbers so you can quickly answer:

- Can I make `x` by XORing some subset?
- What is the maximum `x ^ y` I can get?
- How many independent values do I have?

It is like **Gaussian elimination**, but over bits with XOR.

This package provides:

```
@xor_basis.XorBasis::new()
XorBasis::insert(x)
XorBasis::can_represent(x)
XorBasis::max_xor(x)
XorBasis::rank()
```

All values are `Int64`.

---

## 1) XOR as linear algebra (tiny example)

Consider numbers with 3 bits:

```
5 = 101
3 = 011
6 = 110
```

All XOR combinations of `{5, 3}`:

```
0   (empty set)
5   (101)
3   (011)
5 ⊕ 3 = 110 = 6
```

So `{5, 3}` already spans `{0, 3, 5, 6}`.

That means inserting `6` should **not** increase the basis size.

---

## 2) Building the basis (visual)

Insert `5 (101)`, `3 (011)`, `6 (110)`:

```
Start: basis empty

Insert 5 = 101
  highest bit = 2
  basis[2] empty -> store 101

Insert 3 = 011
  highest bit = 1
  basis[1] empty -> store 011

Insert 6 = 110
  highest bit = 2
  110 ⊕ 101 = 011
  highest bit = 1
  011 ⊕ 011 = 000
  reduced to 0 -> already representable
```

Final basis has 2 vectors: rank = 2.

---

## 3) Insert algorithm (intuition)

We try to eliminate the highest set bit using existing basis vectors.

If we end up with 0, the number is already in the span.
If we end with a new highest bit, we store it.

---

## 4) Max XOR query (greedy works)

To maximize `x ^ y`, we try to turn on the highest bits first:

```
If XORing with a basis vector flips a high bit from 0 to 1,
do it.
```

This is optimal because higher bits dominate smaller ones.

Example:

```
basis = {101, 011}
x = 010

Try bit2 vector 101:
010 ⊕ 101 = 111  (better, bit2 becomes 1)

Try bit1 vector 011:
111 ⊕ 011 = 100  (worse, bit1 becomes 0)

Result = 111 = 7
```

---

## 5) Example: insert + membership

```mbt check
///|
test "xor basis membership" {
  let b = @xor_basis.XorBasis::new()
  let _ = b.insert(5L) // 101
  let _ = b.insert(3L) // 011

  // Span is {0, 3, 5, 6}
  inspect(b.can_represent(0L), content="true")
  inspect(b.can_represent(3L), content="true")
  inspect(b.can_represent(5L), content="true")
  inspect(b.can_represent(6L), content="true")
  inspect(b.can_represent(1L), content="false")
}
```

---

## 6) Example: rank (independence)

```mbt check
///|
test "xor basis rank" {
  let b = @xor_basis.XorBasis::new()
  inspect(b.rank(), content="0")
  inspect(b.insert(5L), content="true")
  inspect(b.rank(), content="1")
  inspect(b.insert(3L), content="true")
  inspect(b.rank(), content="2")
  // 6 = 5 XOR 3, so it does not increase rank
  inspect(b.insert(6L), content="false")
  inspect(b.rank(), content="2")
}
```

---

## 7) Example: maximum XOR

```mbt check
///|
test "xor basis max xor" {
  let b = @xor_basis.XorBasis::new()
  let _ = b.insert(8L)
  let _ = b.insert(5L)
  let _ = b.insert(10L)
  inspect(b.max_xor(0L), content="15")
}
```

---

## 8) Why rank matters

If rank = `r`, the basis spans exactly `2^r` values.

Example:

```
rank = 2 -> 4 values
rank = 3 -> 8 values
```

This is useful when counting distinct XOR results.

---

## 9) Common applications

```
Maximum XOR subarray
Maximum XOR pair queries
Check linear independence over GF(2)
Count number of distinct XOR values
XOR cycle basis in graphs
```

---

## 10) Complexity

Let B be number of bits (<= 63 for Int64):

```
insert         O(B)
can_represent  O(B)
max_xor        O(B)
rank           O(1)
```

Since B is tiny, operations are effectively constant time.

---

## 11) Common pitfalls

- Forgetting to use `Int64` values.
- Assuming insert order matters (it does not affect the span).
- Mixing up "rank" (independent vectors) with "size" of input list.
