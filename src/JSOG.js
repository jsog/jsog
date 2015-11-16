(function (root, factory) {
  // UMD module pattern

  if (typeof define === "function" && define.amd) {
    // AMD. Register as an anonymous module.
    define([], factory);
  } else if (typeof exports === "object") {
    // Node. Does not work with strict CommonJS, but
    // only CommonJS-like environments that support module.exports,
    // like Node.
    module.exports = factory();
  } else {
    // Browser globals (root is window)
    root.JSOG = factory();
  }

}(this, function () {
  "use strict";

  var JSOG, JSOG_OBJECT_ID, JSOG_OBJECT_DECODED, hasCustomJsonification, isArray, nullOrUndefined;

  JSOG = {};

  isArray = Array.isArray || function (obj) {
      return Object.prototype.toString.call(obj) === "[object Array]";
    };

  hasCustomJsonification = function (obj) {
    return typeof obj.toJSON === "function";
  };

  nullOrUndefined = function (val) {
    return typeof val === "undefined" || val === null;
  };

  JSOG_OBJECT_ID = "__jsogObjectId";
  JSOG_OBJECT_DECODED = "__jsogObjectDecoded";

  JSOG.encode = function (original) {
    var doEncode, idOf, sofar, nextId;
    nextId = 0;
    sofar = {};
    idOf = function (obj) {
      if (!obj[ JSOG_OBJECT_ID ]) {
        obj[ JSOG_OBJECT_ID ] = "" + (nextId++);
      }
      return obj[ JSOG_OBJECT_ID ];
    };
    doEncode = function (original) {
      var encodeArray, encodeObject;
      encodeObject = function (original) {
        var id, key, result, value;
        id = idOf(original);
        if (sofar[ id ]) {
          return {
            "@ref": id
          };
        }
        result = sofar[ id ] = {
          "@id": id
        };
        for (key in original) {
          if (original.hasOwnProperty(key) && key !== JSOG_OBJECT_DECODED) {
            value = original[ key ];
            if (key !== JSOG_OBJECT_ID) {
              result[ key ] = doEncode(value);
            }
          }
        }
        return result;
      };
      encodeArray = function (original) {
        var val;
        return (function () {
          var i, len, results;
          results = [];
          for (i = 0, len = original.length; i < len; i++) {
            val = original[ i ];
            results.push(doEncode(val));
          }
          return results;
        })();
      };
      if (nullOrUndefined(original)) {
        return original;
      } else if (hasCustomJsonification(original)) {
        return original;
      } else if (isArray(original)) {
        return encodeArray(original);
      } else if (typeof original === "object") {
        return encodeObject(original);
      } else {
        return original;
      }
    };
    return doEncode(original);
  };


  JSOG.decode = function (encoded) {
    var doDecode, found;
    found = {};
    doDecode = function (encoded) {
      var decodeArray, decodeObject;
      decodeObject = function (encoded) {
        var id, key, ref, result, value;
        if (encoded[ JSOG_OBJECT_DECODED ] === true) {
          return encoded;
        }
        ref = encoded[ "@ref" ];
        if (ref != null) {
          ref = ref.toString();
        }
        if (ref != null) {
          return found[ ref ];
        }
        result = {};
        id = encoded[ "@id" ];
        if (id != null) {
          id = id.toString();
        }
        if (id) {
          found[ id ] = result;
        }
        for (key in encoded) {
          if (encoded.hasOwnProperty(key)) {
            value = encoded[ key ];
            if (key !== "@id") {
              result[ key ] = doDecode(value);
            }
          }
        }
        result[ JSOG_OBJECT_DECODED ] = true;
        return result;
      };
      decodeArray = function (encoded) {
        var value;
        return (function () {
          var i, len, results;
          results = [];
          for (i = 0, len = encoded.length; i < len; i++) {
            value = encoded[ i ];
            results.push(doDecode(value));
          }
          return results;
        })();
      };
      if (nullOrUndefined(encoded)) {
        return encoded;
      } else if (isArray(encoded)) {
        return decodeArray(encoded);
      } else if (typeof encoded === "object") {
        return decodeObject(encoded);
      } else {
        return encoded;
      }
    };
    return doDecode(encoded);
  };

  JSOG.stringify = function (obj) {
    return JSON.stringify(JSOG.encode(obj));
  };

  JSOG.parse = function (str) {
    return JSOG.decode(JSON.parse(str));
  };

  return JSOG;
}));