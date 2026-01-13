///|
test "linear sieve basics" {
  let sieve = @linear_sieve.LinearSieve::new(10)
  inspect(sieve.primes, content="[2, 3, 5, 7]")
  inspect(sieve.spf[10], content="2")
  inspect(sieve.phi[10], content="4")
  inspect(sieve.mu[10], content="1")
  inspect(sieve.mu[4], content="0")
  assert_true(sieve.is_prime(7))
  assert_true(not(sieve.is_prime(9)))
}

///|
test "linear sieve factorize" {
  let sieve = @linear_sieve.LinearSieve::new(100)
  let factors = sieve.factorize(84)
  inspect(factors, content="[(2, 2), (3, 1), (7, 1)]")
}
