outseam = 103
inseam = 88
waistC = 91
buttC = 102
thighC = 61
kneeC = 44
ankleC = 30
backMid = 41
frontMid = 31

startY = 50
startX = 25

refPointsFrontR = {
  A: [startX, startY],
  B: [startX-3, 58],
  C: [startX-2, 72],
  D: [startX+1, 85],
  E: [startX+5, 110],
  F: [startX+10, outseam+startY],
  G: [startX+30, 52],
  H: [startX+31, 60],
  I: [startX+32, 70],
  J: [startX+35, 78],
  K: [startX+34, 110],
  L: [startX+30, outseam+startY]
}

startX = 150

refPointsBackR = {
  A: [startX, refPointsFrontR['A'][1]],
  B: [startX-3, 58],
  C: [startX-2, 72],
  D: [startX+1, 85],
  E: [startX+5, 110],
  F: [startX+10, outseam+startY],
  G: [startX+30, 52],
  H: [startX+31, 60],
  I: [startX+35, 70],
  J: [startX+39, refPointsFrontR['J'][1]],
  K: [startX+34, 110],
  L: [startX+30, outseam+startY]
}

lineRef = 50

letters = ['F', 'E', 'D', 'C', 'B', 'A', 'G', 'H', 'I', 'J', 'K', 'L']

# =============================================================================

setupModelFrontR = ->

  coords = (refPointsFrontR[letter] for letter in letters)

  # Add points
  for coord in coords
    p = new Point(coord[0]*4, coord[1]*4)
    model.points.push(p)

  # Add distance constraints
  # for i in [0...model.points.length-1]
  #   p1 = model.points[i]
  #   p2 = model.points[i+1]

  #   distance = math.distance(p1, p2)
  #   constraint = new DistanceConstraint(p1, p2, distance)
  #   model.constraints.push(constraint)
  # p1 = model.points[model.points.length-1]
  # p2 = model.points[0]
  
  # distance = math.distance(p1, p2)
  # constraint = new DistanceConstraint(p1, p2, distance)
  # model.constraints.push(constraint)

  # Add angle constraints
  #for i in [0...model.points.length-1]
  #  p1 = model.points[i]
  #  p2 = model.points[i+1]

  #  angle = math.angle(p1, p2)
  #  constraint = new AngleConstraint(p1, p2, angle)
  #  model.constraints.push(constraint)

  #p1 = model.points[model.points.length-1]
  #p2 = model.points[0]

  #angle = math.angle(p1, p2)
  #constraint = new AngleConstraint(p1, p2, angle)
  #model.constraints.push(constraint)

  render()

# =============================================================================

setupModelFrontL = ->

  coords = (refPointsFrontR[letter] for letter in letters)

  for coord in coords
    p = new Point((2*lineRef-coord[0])*4+200, coord[1]*4)
    model.points.push(p)

  render()

# =============================================================================

setupModelBackR = ->

  coords = (refPointsBackR[letter] for letter in letters)

  # Add points
  for coord in coords
    p = new Point(coord[0]*4, coord[1]*4)
    model.points.push(p)

  render()

# =============================================================================

setupModelBackL = ->

  coords = (refPointsBackR[letter] for letter in letters)

  lineRef = 200
  # Add points
  for coord in coords
    p = new Point((2*lineRef-coord[0])*4, coord[1]*4)
    model.points.push(p)

  render()

# =============================================================================
# Set up canvas
# =============================================================================

canvasEl = document.querySelector("#c")
ctx = canvasEl.getContext("2d")

resize = ->
  rect = canvasEl.getBoundingClientRect()
  canvasEl.width = rect.width
  canvasEl.height = rect.height
  render()

init = ->
  window.addEventListener("resize", resize)
  canvasEl.addEventListener("pointerdown", pointerDown)
  canvasEl.addEventListener("pointermove", pointerMove)
  canvasEl.addEventListener("pointerup", pointerUp)
  setupModelFrontL()
  setupModelFrontR()
  setupModelBackR()
  setupModelBackL()
  resize()
  idleLoop()

idleLoop = ->
  idle()
  requestAnimationFrame(idleLoop)


# =============================================================================
# Model
# =============================================================================

class Point
  constructor: (@x, @y) ->

class DistanceConstraint
  constructor: (@p1, @p2, @distance) ->
  pointNames: -> ["p1", "p2"]

  solveFor: (pointName) ->
    dx = @p2.x - @p1.x
    dy = @p2.y - @p1.y
    direction = math.normalize(new Point(dx, dy))

    if pointName == "p1"
      x = @p2.x - direction.x * @distance
      y = @p2.y - direction.y * @distance
    else if pointName == "p2"
      x = @p1.x + direction.x * @distance
      y = @p1.y + direction.y * @distance

    return new Point(x, y)

  error: ->
    d = math.distance(@p1, @p2)
    e = d - @distance
    return e*e

class AngleConstraint
  constructor: (@p1, @p2, @angle) ->
  pointNames: -> ["p1", "p2"]

  solveFor: (pointName) ->
    dx = @p2.x - @p1.x
    dy = @p2.y - @p1.y

    cos = Math.cos(@angle)
    sin = Math.sin(@angle)

    parallelComponent = cos*dx + sin*dy

    if pointName == "p1"
      x = @p2.x - parallelComponent * cos
      y = @p2.y - parallelComponent * sin
    else if pointName == "p2"
      x = @p1.x + parallelComponent * cos
      y = @p1.y + parallelComponent * sin

    return new Point(x, y)


  # error: ->
  #   dx = @p2.x - @p1.x
  #   dy = @p2.y - @p1.y
  #   cos = Math.cos(-@angle)
  #   sin = Math.sin(-@angle)
  #   rdy = sin*dx + cos*dy
  #   return rdy*rdy
  error: ->
    angle = math.angle(@p1, @p2)
    da = angle - @angle
    e = math.distance(@p1, @p2) * Math.sin(da)
    return e * e

window.model = model = {
  points: []
  constraints: []
}


# =============================================================================
# UI State
# =============================================================================

uistate = {
  movingPoint: null
  lastTouchedPoints: []
  pointerX: 0
  pointerY: 0
}


# =============================================================================
# Render
# =============================================================================

clear = ->
  ctx.save()
  ctx.setTransform(1, 0, 0, 1, 0, 0)
  width = ctx.canvas.width
  height = ctx.canvas.height
  ctx.clearRect(0, 0, width, height)
  ctx.restore()

drawPoint = (point, color = "#000") ->
  ctx.beginPath()
  ctx.arc(point.x, point.y, 2.5, 0, Math.PI*2)
  ctx.fillStyle = color
  ctx.fill()

  ctx.font = '11px Sans'
  ctx.fillStyle = '#0000ff'
  x = point.x
  y = point.y
  ctx.fillText x.toFixed(0)/4 + ',' + y.toFixed(0)/4, x+5, y+5

drawCircle = (center, radius, color = "#000") ->
  ctx.beginPath()
  ctx.arc(center.x, center.y, radius, 0, Math.PI*2)
  ctx.lineWidth = 1
  ctx.strokeStyle = color
  ctx.stroke()

drawLine = (p1, p2, color = "#000") ->
  ctx.beginPath()
  ctx.moveTo(p1.x, p1.y)
  ctx.lineTo(p2.x, p2.y)
  ctx.lineWidth = 1
  ctx.strokeStyle = color
  ctx.stroke()

render = ->
  clear()

  for point in model.points
    color = "#000"
    color = "#f00" if point == uistate.lastTouchedPoints[0]
    color = "#a00" if point == uistate.lastTouchedPoints[1]
    drawPoint(point, color)
    if point.fixed
      drawCircle(point, 5, color)

  for constraint in model.constraints
    if constraint instanceof DistanceConstraint
      drawLine(constraint.p1, constraint.p2, "blue")
    if constraint instanceof AngleConstraint
      drawLine(constraint.p1, constraint.p2, "red")


# =============================================================================
# Manipulation
# =============================================================================

findPointNear = (p) ->
  for point in model.points
    if math.distance(p, point) < 10
      return point
  return undefined

pointerDown = (e) ->
  p = new Point(e.clientX, e.clientY)

  unless foundPoint = findPointNear(p)
    model.points.push(p)
    Foundpoint = p

  uistate.movingPoint = foundPoint
  if uistate.lastTouchedPoints[0] != foundPoint
    uistate.lastTouchedPoints.unshift(foundPoint)

pointerMove = (e) ->
  uistate.pointerX = e.clientX
  uistate.pointerY = e.clientY

pointerUp = (e) ->
  if uistate.movingPoint
    uistate.movingPoint = null

idle = ->
  if point = uistate.movingPoint
    point.x = uistate.pointerX
    point.y = uistate.pointerY

    originalFixed = point.fixed
    point.fixed = true
    enforceConstraints()
    point.fixed = false
    enforceConstraints()
    point.fixed = originalFixed

  else
    enforceConstraints()

  render()

key "D", ->
  p1 = uistate.lastTouchedPoints[0]
  p2 = uistate.lastTouchedPoints[1]

  distance = math.distance(p1, p2)
  constraint = new DistanceConstraint(p1, p2, distance)
  model.constraints.push(constraint)

  render()

key "A", ->
  p1 = uistate.lastTouchedPoints[0]
  p2 = uistate.lastTouchedPoints[1]

  angle = math.angle(p1, p2)
  constraint = new AngleConstraint(p1, p2, angle)
  model.constraints.push(constraint)

  render()

key "F", ->
  p = uistate.lastTouchedPoints[0]
  p.fixed = !p.fixed


# =============================================================================
# Math
# =============================================================================

math = {}

math.distance = (p1, p2) ->
  dx = p2.x - p1.x
  dy = p2.y - p1.y
  return Math.sqrt(dx*dx + dy*dy)

math.angle = (p1, p2) ->
  dx = p2.x - p1.x
  dy = p2.y - p1.y
  return Math.atan2(dy, dx)

math.normalize = (p) ->
  d = Math.sqrt(p.x*p.x + p.y*p.y)
  return new Point(p.x / d, p.y / d)


# =============================================================================
# Constraints
# =============================================================================

window.config = config = {
  epsilon: 1e-2
  stepSize: 0.1
  maxIterations: 400
}

enforceConstraints = ->

  for iteration in [0...config.maxIterations]

    moves = []

    for constraint in model.constraints
      e = constraint.error()
      if e > config.epsilon

        pointNames = constraint.pointNames()
        pointNames = _.reject pointNames, (pointName) ->
          constraint[pointName].fixed

        for pointName in pointNames
          point = constraint[pointName]
          solvedPoint = constraint.solveFor(pointName)
          dx = solvedPoint.x - point.x
          dy = solvedPoint.y - point.y
          delta = new Point(dx, dy)
          moves.push({point, delta})

    if moves.length == 0
      # All constraints solved.
      break

    for {point, delta} in moves
      point.x += delta.x * config.stepSize
      point.y += delta.y * config.stepSize


# =============================================================================
# Let's go!
# =============================================================================

init()
