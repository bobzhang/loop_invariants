# Challenge: Coin Change (Min Coins)

Unbounded knapsack DP for minimum coin count.

## Example

```mbt check
///|
test "coin change example" {
  let coins : Array[Int] = [1, 3, 4]
  let ans = @challenge_coin_change_min.min_coins(coins[:], 6)
  inspect(ans, content="Some(2)")
}
```
