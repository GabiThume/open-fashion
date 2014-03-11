# https://mombin-metate.codio.io/spring/paper.html
class Template
  constructor: (points) ->
    @path = new paper.Path(points)
    @path.strokeColor = '#e4141b'
    @path.strokeWidth= 2
    @path.selected = 'true'
  getPoint: (index) ->
    return @path[index]

class Solver
  constructor: (constraints) ->
    @constraints = constraints
  run: (template) ->
    for constraint in @constraints
      for pointIdx in [0...constraint.ref.length-1]
        if constraint.type is "distance"
          pA = template.path.segments[pointIdx].point
          pB = template.path.segments[pointIdx+1].point
          
          distVector = pA.subtract(pB)
          if (distVector < constraint.value)
            pA.x = (pA.x + Math.random())
            pA.y = (pA.y + Math.random())
          
         
          
class Constraint    
    constructor: (type, ref, value) ->
      @type = type
      @ref = ref
      @value = value # FIXME! Isto non equisiste!
        
class App
  constructor: () ->
    canvas = document.getElementById("canvas")
    paper.setup(canvas)

    # Creating the template shape
    #points = [[50,50], [100, 40], [300, 250], [300, 150]]
    
    points = [
      [552, 73],
      [560,107],
      [566,136],
      [573,154],
      [589,173],
      [605,187],
      [620,193],
      [606,272],
      [594,371],
      [585,477],
      [577,585],
      [489,583],
      [481,478],
      [472,372],
      [462,270],
      [449,170],
      [446,123],
      [445,107],
      [447,86]
    ]

    template = new Template(points)

    # Creating the template constraints
    constraints = [
      new Constraint('distance', [0...points.length], 40)
    ]
    
    # Creating and running solver
    solver = new Solver(constraints)
    
    paper.view.onFrame = (event) ->
      solver.run(template)
      
# =============================================================================
new App()
    
# =============================================================================

class Measurements
  outseam: 115
  inseam: 88
  waistC: 91
  buttC: 102
  thighC: 95
  kneeC: 54
  ankleC: 35
  backMid: 41
  frontMid: 31

measures = new Measurements

gui = new dat.GUI()
gui.add(measures, 'outseam', 0, 200)
gui.add(measures, 'inseam', 0, 200)
gui.add(measures, 'waistC', 0, 200)
gui.add(measures, 'buttC', 0, 200)
gui.add(measures, 'thighC', 0, 200)
gui.add(measures, 'kneeC', 0, 200)
gui.add(measures, 'ankleC', 0, 200)
gui.add(measures, 'backMid', 0, 200)
gui.add(measures, 'frontMid', 0, 200) 