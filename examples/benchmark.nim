import ../src/nimtest/api

echo "Benchmarking Example"
echo "==================="

# Performance benchmarking
discard benchmark("string concatenation", 1000):
  proc() =
    var s = ""
    for i in 0..100:
      s &= "test"

discard benchmark("array operations", 1000):
  proc() =
    var arr = newSeq[int](100)
    for i in 0..99:
      arr[i] = i * 2

echo "Benchmarking completed!"