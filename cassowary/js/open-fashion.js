window.onload = function () {
  var Point = function (x, y) {
    this.x = x;
    this.y = y;
    this.coords = [x, y];
  };

  var Line = function (from, to) {
    this.from = from;
    this.to = to;
  };
  Line.prototype.length = function () {
    return Math.sqrt(Math.pow(this.to.x-this.from.x, 2) +
                     Math.pow(this.to.y-this.from.y, 2));
  };
  Line.prototype.angleWith = function (other, degree) {
    var dx_this = this.to.x-this.from.x;
    var dy_this = this.to.y-this.from.y;
    var dx_other = other.to.x-other.from.x;
    var dy_other = other.to.y-other.from.y;

    // Dot product of the two vectors formed by the two lines
    var dot = dx_this*dx_other + dy_this*dy_other;
    // Product of the squared lengths
    var squared = (dx_this*dx_this+dy_this*dy_this) *
      (dx_other*dx_other+dy_other*dy_other);

    var angle_rad = Math.acos(dot/Math.sqrt(squared));

    if (degree) {
      return angle_rad * 180 / Math.PI;
    }
    return angle_rad;
  };
  
  // Polygon points
  var points = [new Point(100, 10),
                new Point(100, 400),
                new Point(300, 400),
                new Point(250, 130),
                new Point(300, 10)];

  // Polygon sides
  var sides = [];
  for (var i=0; i<points.length-1; i++) {
    sides.push(new Line(points[i], points[i+1]))
  }
  sides.push(new Line(points[points.length-1], points[0]));
  
  console.log(sides[0].angleWith(sides[1], true));
  
  // Paperjs setup
  var canvas = document.getElementById('canvas');
  paper.setup(canvas);

  // Build a path to represent the pants template
  var path = new paper.Path();
  path.strokeColor = 'black';

  for (var i in points) {
    path.add(new paper.Point(points[i].coords));
  }
  path.add(points[0].coords);

  // Draws
  paper.view.draw();

  // Cassowary solver setup
  var solver = new c.SimplexSolver();

  var waist = sides[4].length();

  // Testing a simple linear system: 
  //    2x + 3y =  8      roots:  x = 1, y = 2 
  //     x -  y = -1
  var x = new c.Variable({ value: 0 });
  var y = new c.Variable({ value: 0 });
  
  // 2x + 3y = 8
  cle = new c.Expression(x);
  cle2 = new c.Expression(y);
  cle = (cle.times(2)).plus(cle2.times(3));
  cleq = new c.Equation(cle, 8);
  solver.addConstraint(cleq);

  // x - y = -1
  cle = new c.Expression(x);
  cle2 = new c.Expression(y);
  cle = cle.minus(cle2);
  cleq = new c.Equation(cle, -1);
  solver.addConstraint(cleq);
  
  /*
  solver.addEditVar(x)
  solver.beginEdit();
  solver.suggestValue(x, 4);
  solver.endEdit();
  */

  solver.resolve();
  console.log(solver.getInternalInfo());
  console.log('roots. x:', x.value, 'y:', y.value);

};
