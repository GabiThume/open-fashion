ratio = 1/10
threshold = 1/100000

numConstraints = 2

constraints = []
for i in [0...numConstraints]
  constraints[i] = 1

constraints[0] = 0

for iteration in [0...40000]
  # console.log constraints
  d = [0]
  for i in [1...numConstraints]
    diff = constraints[i] - constraints[i-1]
    d.push(constraints[i] - diff * ratio)

  allPassed = true
  for i in [1...numConstraints]
    constraints[i] = d[i]
    if d[i] > threshold
      allPassed = false
  if allPassed
    break

console.log iteration