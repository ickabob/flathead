// test_regexp_global.js
// ---------------------
// Tests for the RegExp global object. Some adapted from V8's mjsunit/regexp.js

var assert = console.assert;

var assertTrue = function(a) { assert(a); };

var assertFalse = function(a) { assert(!a); };

var assertEquals = function(a, b) {
  if (a !== b)
    console.log(a + ' !== ' + b);
  assert(a === b);
};

var assertRegExpEquals = function(a, b) {
  assertEquals(a.source, b.source);
  assertEquals(a.global, b.global);
  assertEquals(a.multiline, b.multiline);
  assertEquals(a.ignoreCase, b.ignoreCase);
};

var assertEmptyRegExp = function(r, cmp) {
  // The value of the 'source' prop seems to be implementation-specific
  // when the 'pattern' constructor argument is undefined.
  //
  // Either '(?:)' or '' is acceptable.
  if (!(r.source === '(?:)' || r.source === ''))
    assert(false);
  assertEquals(r.global, cmp.global);
  assertEquals(r.multiline, cmp.multiline);
  assertEquals(r.ignoreCase, cmp.ignoreCase);
};

var test = function(name, f) {
  f();
};


// ----------------------------------------------------------------------------
// RegExp Global
// ----------------------------------------------------------------------------

assert(RegExp);
assertEquals('function', typeof RegExp);

test('Constructor', function() {
  assertEquals('object', typeof new RegExp);
  assertEquals('object', typeof new RegExp());
  assertEquals('object', typeof RegExp());
  assertEmptyRegExp(new RegExp, /(?:)/);
  assertEmptyRegExp(new RegExp(), /(?:)/);
  assertEmptyRegExp(new RegExp(undefined, 'igm'), /(?:)/igm);
  assertRegExpEquals(/null/gim, new RegExp(null, 'igm'));
  assertRegExpEquals(/abc/i, new RegExp('abc', 'i'));
  assertRegExpEquals(/abc/i, RegExp('abc', 'i'));
  assertRegExpEquals(/abc/gim, new RegExp('abc', 'igm'));
  assertRegExpEquals(/abc/ig, new RegExp('abc', 'gi'));
  assertRegExpEquals(/abc/g, new RegExp('abc', 'g'));
});


// ----------------------------------------------------------------------------
// RegExp Prototype
// ----------------------------------------------------------------------------

assert(RegExp.prototype);
assertEquals('object', typeof RegExp.prototype);

test('RegExp#exec(str)', function() {
  // TODO
});

test('RegExp#test(str)', function() {
  assertFalse(/()foo$\1/.test("football"));
  assertFalse(/foo$(?=ball)/.test("football"));
  assertFalse(/foo$(?!bar)/.test("football"));
  assertTrue(/()foo$\1/.test("foo"));
  assertTrue(/foo$(?=(ball)?)/.test("foo"));
  assertTrue(/()foo$(?!bar)/.test("foo"));
  assertFalse(/(x?)foo$\1/.test("football"));
  assertFalse(/foo$(?=ball)/.test("football"));
  assertFalse(/foo$(?!bar)/.test("football"));
  assertTrue(/(x?)foo$\1/.test("foo"));
  assertTrue(/foo$(?=(ball)?)/.test("foo"));
  assertTrue(/foo$(?!bar)/.test("foo"));

  var re = /(?:a$|bc$)/;
  assertTrue(re.test("a"));
  assertTrue(re.test("bc"));
  assertTrue(re.test("abc"));
  assertTrue(re.test("zimzamzumba"));
  assertTrue(re.test("zimzamzumbc"));
  assertFalse(re.test("c"));
  assertFalse(re.test(""));
});

test('RegExp#toString(str)', function() {
  assertEquals('/abc/gim', (new RegExp('abc', 'img')).toString());
  assertEquals('/abc/gi', (new RegExp('abc', 'ig')).toString());
  assertEquals('/abc/m', (new RegExp('abc', 'm')).toString());
  assertEquals('/abc/gim', /abc/img.toString());
});
