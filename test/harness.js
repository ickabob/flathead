// Define a basic console for implementations that do not provide one.

if (typeof console !== 'object') {
  console = {

    log: function() {
      var args = Array.prototype.slice.call(arguments);
      for (var i = 0; i < args.length; i++)
        print(args[i]);
    },

    error: function() {
      var args = Array.prototype.slice.call(arguments);
      for (var i = 0; i < args.length; i++)
        print(args[i]);
    },

    assert: function(assertion) {
      if (!assertion)
        throw new Error("assertion failed");
    }

  };
}
