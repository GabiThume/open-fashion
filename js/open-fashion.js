window.onload = function() {
  var Vector = function (x, y) {
    this.x = x;
    this.y = y;
    this.coords = [x, y];
  };
  
  // Polygon sides
  var vectors = [new Vector(100, 10),
                 new Vector(100, 400),
                 new Vector(300, 400),
                 new Vector(250, 130),
                 new Vector(300, 10)];

  // Paperjs setup
  var canvas = document.getElementById('canvas');
  paper.setup(canvas);

  // Build a path to represent the pants template
  var path = new paper.Path();
  path.strokeColor = 'black';

  for (var i in vectors) {
    var coords = vectors[i].coords;
    path.add(new paper.Point(coords));
  }
  var coords = vectors[0].coords;
  path.add(coords);

  // Draws
  paper.view.draw();

  // Cassowary solver setup
  var solver = new c.SimplexSolver();

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