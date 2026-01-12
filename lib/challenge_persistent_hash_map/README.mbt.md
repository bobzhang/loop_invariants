# Persistent Hash Map

Immutable hash map with bucketed lists and path-copying updates.

## Example

```mbt check
///|
test "persistent hash map" {
  let map0 = @challenge_persistent_hash_map.make(4)
  let map1 = @challenge_persistent_hash_map.put(map0, 1, 10)
  let map2 = @challenge_persistent_hash_map.put(map1, 5, 50)
  let map3 = @challenge_persistent_hash_map.put(map2, 1, 11)
  inspect(@challenge_persistent_hash_map.get(map3, 1), content="Some(11)")
  inspect(@challenge_persistent_hash_map.get(map3, 5), content="Some(50)")
  inspect(@challenge_persistent_hash_map.get(map1, 5), content="None")
  inspect(@challenge_persistent_hash_map.size(map3), content="2")
}
```

## Another Example

```mbt check
///|
test "persistent hash map sizes" {
  let map0 = @challenge_persistent_hash_map.make(2)
  let map1 = @challenge_persistent_hash_map.put(map0, 2, 20)
  let map2 = @challenge_persistent_hash_map.put(map1, 4, 40)
  inspect(@challenge_persistent_hash_map.get(map2, 4), content="Some(40)")
  inspect(@challenge_persistent_hash_map.size(map2), content="2")
}
```
