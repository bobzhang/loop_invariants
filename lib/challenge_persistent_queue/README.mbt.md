# Persistent Queue

Immutable queue implemented with two stacks and lazy reversal.

## Example

```mbt check
///|
test "persistent queue" {
  let q0 : @challenge_persistent_queue.Queue[Int] = @challenge_persistent_queue.empty()
  let q1 = @challenge_persistent_queue.enqueue(q0, 1)
  let q2 = @challenge_persistent_queue.enqueue(q1, 2)
  let q3 = @challenge_persistent_queue.enqueue(q2, 3)
  inspect(@challenge_persistent_queue.peek(q3), content="Some(1)")
  guard @challenge_persistent_queue.dequeue(q3) is Some((1, q4)) else {
    fail("expected dequeue")
  }
  inspect(@challenge_persistent_queue.peek(q4), content="Some(2)")
  inspect(@challenge_persistent_queue.size(q4), content="2")
}
```
