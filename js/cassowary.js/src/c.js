// Copyright (C) 1998-2000 Greg J. Badros
// Use of this source code is governed by
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Parts Copyright (C) 2011-2012, Alex Russell (slightlyoff@chromium.org)

(function(scope){
"use strict";

// For Safari 5.x. Go-go-gadget ridiculously long release cycle!
try {
  (function(){}).bind(scope);
} catch (e) {
  Object.defineProperty(Function.prototype, "bind", {
    value: function(scope) {
      var f = this;
      return function() { return f.apply(scope, arguments); }
    },
    enumerable: false,
    configurable: true,
    writable: true,
  });
}

var inBrowser = (typeof scope["HTMLElement"] != "undefined");

var getTagName = function(proto) {
  var tn = null;
  while (proto && proto != Object.prototype) {
      if (proto.tagName) {
        tn = proto.tagName;
        break;
      }
    proto = proto.prototype;
  }
  return tn || "div";
};
var epsilon = 1e-8;

var  _t_map = {};
var walkForMethod = function(ctor, name) {
  if (!ctor || !name) return;

  // Check the class-side first, the look at the prototype, then walk up
  if (typeof ctor[name] == "function") {
    return ctor[name];
  }
  var p = ctor.prototype;
  if (p && typeof p[name] == "function") {
    return p[name];
  }
  if (p === Object.prototype ||
      p === Function.prototype) {
    return;
  }

  if (typeof ctor.__super__ == "function") {
    return walkForMethod(ctor.__super__, name);
  }
};

// Global
var c = scope.c = function() {
  if(c._api) {
    return c._api.apply(this, arguments);
  }
};

//
// Configuration
//
c.debug = false;
c.trace = false;
c.verbose = false;
c.traceAdded = false;
c.GC = false;

//
// Constants
//
c.GEQ = 1;
c.LEQ = 2;


//
// Utility methods
//
c.inherit = function(props) {
  var ctor = null;
  var parent = null;

  if (props["extends"]) {
    parent = props["extends"];
    delete props["extends"];
  }

  if (props["initialize"]) {
    ctor = props["initialize"];
    delete props["initialize"];
  }

  var realCtor = ctor || function() { };

  Object.defineProperty(realCtor, "__super__", {
    value: (parent) ? parent : Object,
    enumerable: false,
    configurable: true,
    writable: false,
  });

  if (props["_t"]) {
    _t_map[props["_t"]] = realCtor;
  }

  // FIXME(slightlyoff): would like to have class-side inheritance!
  // It's easy enough to do when we have __proto__, but we don't in IE 9/10.
  //   = (

  /*
  // NOTE: would happily do this except it's 2x slower. Boo!
  props.__proto__ = parent ? parent.prototype : Object.prototype;
  realCtor.prototype = props;
  */

  var rp = realCtor.prototype = Object.create(
    ((parent) ? parent.prototype : Object.prototype)
  );

  c.extend(rp, props);

  // If we're in a browser, we want to support "subclassing" HTML elements.
  // This needs some magic and we rely on a wrapped constructor hack to make
  // it happen.
  if (inBrowser) {
    if (parent && parent.prototype instanceof scope.HTMLElement) {
      var intermediateCtor = realCtor;
      var tn = getTagName(rp);
      var upgrade = function(el) {
        el.__proto__ = rp;
        intermediateCtor.apply(el, arguments);
        if (rp["created"]) { el.created(); }
        if (rp["decorate"]) { el.decorate(); }
        return el;
      };
      this.extend(rp, { upgrade: upgrade, });

      realCtor = function() {
        // We hack the constructor to always return an element with it's
        // prototype wired to ours. Boo.
        return upgrade(
          scope.document.createElement(tn)
        );
      }
      realCtor.prototype = rp;
      this.extend(realCtor, { ctor: intermediateCtor, }); // HACK!!!
    }
  }

  return realCtor;
};

c.own = function(obj, cb, context) {
  Object.getOwnPropertyNames(obj).forEach(cb, context||scope);
  return obj;
};

c.extend = function(obj, props) {
  c.own(props, function(x) {
    var pd = Object.getOwnPropertyDescriptor(props, x);
    try {
      if ( (typeof pd["get"] == "function") ||
           (typeof pd["set"] == "function") ) {
        Object.defineProperty(obj, x, pd);
      } else if (typeof pd["value"] == "function" ||x.charAt(0) === "_") {
        pd.writable = true;
        pd.configurable = true;
        pd.enumerable = false;
        Object.defineProperty(obj, x, pd);
      } else {
          obj[x] = props[x];
      }
    } catch(e) {
      // console.warn("c.extend assignment failed on property", x);
    }
  });
  return obj;
};

// FIXME: legacy API to be removed
c.traceprint = function(s /*String*/) { if (c.verbose) { console.log(s); } };
c.fnenterprint = function(s /*String*/) { console.log("* " + s); };
c.fnexitprint = function(s /*String*/) { console.log("- " + s); };

c.assert = function(f /*boolean*/, description /*String*/) {
  if (!f) {
    throw new c.InternalError("Assertion failed: " + description);
  }
};

c.plus = function(e1, e2) {
  if (!(e1 instanceof c.Expression)) {
    e1 = new c.Expression(e1);
  }
  if (!(e2 instanceof c.Expression)) {
    e2 = new c.Expression(e2);
  }
  return e1.plus(e2);
};

c.minus = function(e1, e2) {
  if (!(e1 instanceof c.Expression)) {
    e1 = new c.Expression(e1);
  }
  if (!(e2 instanceof c.Expression)) {
    e2 = new c.Expression(e2);
  }

  return e1.minus(e2);
};

c.times = function(e1, e2) {
  if (typeof e1 == "number" || e1 instanceof c.Variable) {
    e1 = new c.Expression(e1);
  }
  if (typeof e2 == "number" || e2 instanceof c.Variable) {
    e2 = new c.Expression(e2);
  }

  return e1.times(e2);
};

c.divide = function(e1 /*c.Expression*/, e2 /*c.Expression*/) {
  if (typeof e1 == "number" || e1 instanceof c.Variable) {
    e1 = new c.Expression(e1);
  }
  if (typeof e2 == "number" || e2 instanceof c.Variable) {
    e2 = new c.Expression(e2);
  }

  return e1.divide(e2);
};

c.approx = function(a /*double*/, b /*double*/) {
  if (a === b) { return true; }
  var av, bv;
  av = (a instanceof c.Variable) ? a.value : a;
  bv = (b instanceof c.Variable) ? b.value : b;
  if (av == 0) {
    return (Math.abs(bv) < epsilon);
  }
  if (bv == 0) {
    return (Math.abs(av) < epsilon);
  }
  return (Math.abs(av - bv) < Math.abs(av) * epsilon);
};

var count = 0;
c._inc = function() { return count++; };

c.parseJSON = function(str) {
  return JSON.parse(str, function(k, v) {
    if (typeof v != "object" || typeof v["_t"] != "string") {
      return v;
    }
    var type = v["_t"];
    var ctor = _t_map[type];
    if (type && ctor) {
      var fromJSON = walkForMethod(ctor, "fromJSON");
      if (fromJSON) {
        return fromJSON(v, ctor);
      }
    }
    return v;
  });
};

// For Node...not that I'm bitter. No no, not at all. Not me. Never...
if (typeof require == "function" &&
    typeof module != "undefined" &&
    typeof load == "undefined") {
  scope.exports = c;
}
// ...well, hardly ever.

})(this);
