var __defProp = Object.defineProperty;
var __markAsModule = (target) => __defProp(target, "__esModule", { value: true });
var __export = (target, all) => {
  __markAsModule(target);
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};

// js/punkix/index.js
__export(exports, {
  PunkixHooks: () => hooks_default,
  decode: () => decode,
  encode: () => encode
});

// ../node_modules/@msgpack/msgpack/dist.es5+esm/utils/utf8.mjs
function utf8Count(str) {
  var strLength = str.length;
  var byteLength = 0;
  var pos = 0;
  while (pos < strLength) {
    var value = str.charCodeAt(pos++);
    if ((value & 4294967168) === 0) {
      byteLength++;
      continue;
    } else if ((value & 4294965248) === 0) {
      byteLength += 2;
    } else {
      if (value >= 55296 && value <= 56319) {
        if (pos < strLength) {
          var extra = str.charCodeAt(pos);
          if ((extra & 64512) === 56320) {
            ++pos;
            value = ((value & 1023) << 10) + (extra & 1023) + 65536;
          }
        }
      }
      if ((value & 4294901760) === 0) {
        byteLength += 3;
      } else {
        byteLength += 4;
      }
    }
  }
  return byteLength;
}
function utf8EncodeJs(str, output, outputOffset) {
  var strLength = str.length;
  var offset = outputOffset;
  var pos = 0;
  while (pos < strLength) {
    var value = str.charCodeAt(pos++);
    if ((value & 4294967168) === 0) {
      output[offset++] = value;
      continue;
    } else if ((value & 4294965248) === 0) {
      output[offset++] = value >> 6 & 31 | 192;
    } else {
      if (value >= 55296 && value <= 56319) {
        if (pos < strLength) {
          var extra = str.charCodeAt(pos);
          if ((extra & 64512) === 56320) {
            ++pos;
            value = ((value & 1023) << 10) + (extra & 1023) + 65536;
          }
        }
      }
      if ((value & 4294901760) === 0) {
        output[offset++] = value >> 12 & 15 | 224;
        output[offset++] = value >> 6 & 63 | 128;
      } else {
        output[offset++] = value >> 18 & 7 | 240;
        output[offset++] = value >> 12 & 63 | 128;
        output[offset++] = value >> 6 & 63 | 128;
      }
    }
    output[offset++] = value & 63 | 128;
  }
}
var sharedTextEncoder = new TextEncoder();
var TEXT_ENCODER_THRESHOLD = 50;
function utf8EncodeTE(str, output, outputOffset) {
  sharedTextEncoder.encodeInto(str, output.subarray(outputOffset));
}
function utf8Encode(str, output, outputOffset) {
  if (str.length > TEXT_ENCODER_THRESHOLD) {
    utf8EncodeTE(str, output, outputOffset);
  } else {
    utf8EncodeJs(str, output, outputOffset);
  }
}
var CHUNK_SIZE = 4096;
function utf8DecodeJs(bytes, inputOffset, byteLength) {
  var offset = inputOffset;
  var end = offset + byteLength;
  var units = [];
  var result = "";
  while (offset < end) {
    var byte1 = bytes[offset++];
    if ((byte1 & 128) === 0) {
      units.push(byte1);
    } else if ((byte1 & 224) === 192) {
      var byte2 = bytes[offset++] & 63;
      units.push((byte1 & 31) << 6 | byte2);
    } else if ((byte1 & 240) === 224) {
      var byte2 = bytes[offset++] & 63;
      var byte3 = bytes[offset++] & 63;
      units.push((byte1 & 31) << 12 | byte2 << 6 | byte3);
    } else if ((byte1 & 248) === 240) {
      var byte2 = bytes[offset++] & 63;
      var byte3 = bytes[offset++] & 63;
      var byte4 = bytes[offset++] & 63;
      var unit = (byte1 & 7) << 18 | byte2 << 12 | byte3 << 6 | byte4;
      if (unit > 65535) {
        unit -= 65536;
        units.push(unit >>> 10 & 1023 | 55296);
        unit = 56320 | unit & 1023;
      }
      units.push(unit);
    } else {
      units.push(byte1);
    }
    if (units.length >= CHUNK_SIZE) {
      result += String.fromCharCode.apply(String, units);
      units.length = 0;
    }
  }
  if (units.length > 0) {
    result += String.fromCharCode.apply(String, units);
  }
  return result;
}
var sharedTextDecoder = new TextDecoder();
var TEXT_DECODER_THRESHOLD = 200;
function utf8DecodeTD(bytes, inputOffset, byteLength) {
  var stringBytes = bytes.subarray(inputOffset, inputOffset + byteLength);
  return sharedTextDecoder.decode(stringBytes);
}
function utf8Decode(bytes, inputOffset, byteLength) {
  if (byteLength > TEXT_DECODER_THRESHOLD) {
    return utf8DecodeTD(bytes, inputOffset, byteLength);
  } else {
    return utf8DecodeJs(bytes, inputOffset, byteLength);
  }
}

// ../node_modules/@msgpack/msgpack/dist.es5+esm/ExtData.mjs
var ExtData = function() {
  function ExtData2(type, data) {
    this.type = type;
    this.data = data;
  }
  return ExtData2;
}();

// ../node_modules/@msgpack/msgpack/dist.es5+esm/DecodeError.mjs
var __extends = function() {
  var extendStatics = function(d, b) {
    extendStatics = Object.setPrototypeOf || { __proto__: [] } instanceof Array && function(d2, b2) {
      d2.__proto__ = b2;
    } || function(d2, b2) {
      for (var p in b2)
        if (Object.prototype.hasOwnProperty.call(b2, p))
          d2[p] = b2[p];
    };
    return extendStatics(d, b);
  };
  return function(d, b) {
    if (typeof b !== "function" && b !== null)
      throw new TypeError("Class extends value " + String(b) + " is not a constructor or null");
    extendStatics(d, b);
    function __() {
      this.constructor = d;
    }
    d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
  };
}();
var DecodeError = function(_super) {
  __extends(DecodeError2, _super);
  function DecodeError2(message) {
    var _this = _super.call(this, message) || this;
    var proto = Object.create(DecodeError2.prototype);
    Object.setPrototypeOf(_this, proto);
    Object.defineProperty(_this, "name", {
      configurable: true,
      enumerable: false,
      value: DecodeError2.name
    });
    return _this;
  }
  return DecodeError2;
}(Error);

// ../node_modules/@msgpack/msgpack/dist.es5+esm/utils/int.mjs
var UINT32_MAX = 4294967295;
function setUint64(view, offset, value) {
  var high = value / 4294967296;
  var low = value;
  view.setUint32(offset, high);
  view.setUint32(offset + 4, low);
}
function setInt64(view, offset, value) {
  var high = Math.floor(value / 4294967296);
  var low = value;
  view.setUint32(offset, high);
  view.setUint32(offset + 4, low);
}
function getInt64(view, offset) {
  var high = view.getInt32(offset);
  var low = view.getUint32(offset + 4);
  return high * 4294967296 + low;
}
function getUint64(view, offset) {
  var high = view.getUint32(offset);
  var low = view.getUint32(offset + 4);
  return high * 4294967296 + low;
}

// ../node_modules/@msgpack/msgpack/dist.es5+esm/timestamp.mjs
var EXT_TIMESTAMP = -1;
var TIMESTAMP32_MAX_SEC = 4294967296 - 1;
var TIMESTAMP64_MAX_SEC = 17179869184 - 1;
function encodeTimeSpecToTimestamp(_a) {
  var sec = _a.sec, nsec = _a.nsec;
  if (sec >= 0 && nsec >= 0 && sec <= TIMESTAMP64_MAX_SEC) {
    if (nsec === 0 && sec <= TIMESTAMP32_MAX_SEC) {
      var rv = new Uint8Array(4);
      var view = new DataView(rv.buffer);
      view.setUint32(0, sec);
      return rv;
    } else {
      var secHigh = sec / 4294967296;
      var secLow = sec & 4294967295;
      var rv = new Uint8Array(8);
      var view = new DataView(rv.buffer);
      view.setUint32(0, nsec << 2 | secHigh & 3);
      view.setUint32(4, secLow);
      return rv;
    }
  } else {
    var rv = new Uint8Array(12);
    var view = new DataView(rv.buffer);
    view.setUint32(0, nsec);
    setInt64(view, 4, sec);
    return rv;
  }
}
function encodeDateToTimeSpec(date) {
  var msec = date.getTime();
  var sec = Math.floor(msec / 1e3);
  var nsec = (msec - sec * 1e3) * 1e6;
  var nsecInSec = Math.floor(nsec / 1e9);
  return {
    sec: sec + nsecInSec,
    nsec: nsec - nsecInSec * 1e9
  };
}
function encodeTimestampExtension(object) {
  if (object instanceof Date) {
    var timeSpec = encodeDateToTimeSpec(object);
    return encodeTimeSpecToTimestamp(timeSpec);
  } else {
    return null;
  }
}
function decodeTimestampToTimeSpec(data) {
  var view = new DataView(data.buffer, data.byteOffset, data.byteLength);
  switch (data.byteLength) {
    case 4: {
      var sec = view.getUint32(0);
      var nsec = 0;
      return { sec, nsec };
    }
    case 8: {
      var nsec30AndSecHigh2 = view.getUint32(0);
      var secLow32 = view.getUint32(4);
      var sec = (nsec30AndSecHigh2 & 3) * 4294967296 + secLow32;
      var nsec = nsec30AndSecHigh2 >>> 2;
      return { sec, nsec };
    }
    case 12: {
      var sec = getInt64(view, 4);
      var nsec = view.getUint32(0);
      return { sec, nsec };
    }
    default:
      throw new DecodeError("Unrecognized data size for timestamp (expected 4, 8, or 12): ".concat(data.length));
  }
}
function decodeTimestampExtension(data) {
  var timeSpec = decodeTimestampToTimeSpec(data);
  return new Date(timeSpec.sec * 1e3 + timeSpec.nsec / 1e6);
}
var timestampExtension = {
  type: EXT_TIMESTAMP,
  encode: encodeTimestampExtension,
  decode: decodeTimestampExtension
};

// ../node_modules/@msgpack/msgpack/dist.es5+esm/ExtensionCodec.mjs
var ExtensionCodec = function() {
  function ExtensionCodec2() {
    this.builtInEncoders = [];
    this.builtInDecoders = [];
    this.encoders = [];
    this.decoders = [];
    this.register(timestampExtension);
  }
  ExtensionCodec2.prototype.register = function(_a) {
    var type = _a.type, encode2 = _a.encode, decode2 = _a.decode;
    if (type >= 0) {
      this.encoders[type] = encode2;
      this.decoders[type] = decode2;
    } else {
      var index2 = 1 + type;
      this.builtInEncoders[index2] = encode2;
      this.builtInDecoders[index2] = decode2;
    }
  };
  ExtensionCodec2.prototype.tryToEncode = function(object, context) {
    for (var i = 0; i < this.builtInEncoders.length; i++) {
      var encodeExt = this.builtInEncoders[i];
      if (encodeExt != null) {
        var data = encodeExt(object, context);
        if (data != null) {
          var type = -1 - i;
          return new ExtData(type, data);
        }
      }
    }
    for (var i = 0; i < this.encoders.length; i++) {
      var encodeExt = this.encoders[i];
      if (encodeExt != null) {
        var data = encodeExt(object, context);
        if (data != null) {
          var type = i;
          return new ExtData(type, data);
        }
      }
    }
    if (object instanceof ExtData) {
      return object;
    }
    return null;
  };
  ExtensionCodec2.prototype.decode = function(data, type, context) {
    var decodeExt = type < 0 ? this.builtInDecoders[-1 - type] : this.decoders[type];
    if (decodeExt) {
      return decodeExt(data, type, context);
    } else {
      return new ExtData(type, data);
    }
  };
  ExtensionCodec2.defaultCodec = new ExtensionCodec2();
  return ExtensionCodec2;
}();

// ../node_modules/@msgpack/msgpack/dist.es5+esm/utils/typedArrays.mjs
function ensureUint8Array(buffer) {
  if (buffer instanceof Uint8Array) {
    return buffer;
  } else if (ArrayBuffer.isView(buffer)) {
    return new Uint8Array(buffer.buffer, buffer.byteOffset, buffer.byteLength);
  } else if (buffer instanceof ArrayBuffer) {
    return new Uint8Array(buffer);
  } else {
    return Uint8Array.from(buffer);
  }
}
function createDataView(buffer) {
  if (buffer instanceof ArrayBuffer) {
    return new DataView(buffer);
  }
  var bufferView = ensureUint8Array(buffer);
  return new DataView(bufferView.buffer, bufferView.byteOffset, bufferView.byteLength);
}

// ../node_modules/@msgpack/msgpack/dist.es5+esm/Encoder.mjs
var DEFAULT_MAX_DEPTH = 100;
var DEFAULT_INITIAL_BUFFER_SIZE = 2048;
var Encoder = function() {
  function Encoder2(options) {
    var _a, _b, _c, _d, _e, _f, _g, _h;
    this.extensionCodec = (_a = options === null || options === void 0 ? void 0 : options.extensionCodec) !== null && _a !== void 0 ? _a : ExtensionCodec.defaultCodec;
    this.context = options === null || options === void 0 ? void 0 : options.context;
    this.useBigInt64 = (_b = options === null || options === void 0 ? void 0 : options.useBigInt64) !== null && _b !== void 0 ? _b : false;
    this.maxDepth = (_c = options === null || options === void 0 ? void 0 : options.maxDepth) !== null && _c !== void 0 ? _c : DEFAULT_MAX_DEPTH;
    this.initialBufferSize = (_d = options === null || options === void 0 ? void 0 : options.initialBufferSize) !== null && _d !== void 0 ? _d : DEFAULT_INITIAL_BUFFER_SIZE;
    this.sortKeys = (_e = options === null || options === void 0 ? void 0 : options.sortKeys) !== null && _e !== void 0 ? _e : false;
    this.forceFloat32 = (_f = options === null || options === void 0 ? void 0 : options.forceFloat32) !== null && _f !== void 0 ? _f : false;
    this.ignoreUndefined = (_g = options === null || options === void 0 ? void 0 : options.ignoreUndefined) !== null && _g !== void 0 ? _g : false;
    this.forceIntegerToFloat = (_h = options === null || options === void 0 ? void 0 : options.forceIntegerToFloat) !== null && _h !== void 0 ? _h : false;
    this.pos = 0;
    this.view = new DataView(new ArrayBuffer(this.initialBufferSize));
    this.bytes = new Uint8Array(this.view.buffer);
  }
  Encoder2.prototype.reinitializeState = function() {
    this.pos = 0;
  };
  Encoder2.prototype.encodeSharedRef = function(object) {
    this.reinitializeState();
    this.doEncode(object, 1);
    return this.bytes.subarray(0, this.pos);
  };
  Encoder2.prototype.encode = function(object) {
    this.reinitializeState();
    this.doEncode(object, 1);
    return this.bytes.slice(0, this.pos);
  };
  Encoder2.prototype.doEncode = function(object, depth) {
    if (depth > this.maxDepth) {
      throw new Error("Too deep objects in depth ".concat(depth));
    }
    if (object == null) {
      this.encodeNil();
    } else if (typeof object === "boolean") {
      this.encodeBoolean(object);
    } else if (typeof object === "number") {
      if (!this.forceIntegerToFloat) {
        this.encodeNumber(object);
      } else {
        this.encodeNumberAsFloat(object);
      }
    } else if (typeof object === "string") {
      this.encodeString(object);
    } else if (this.useBigInt64 && typeof object === "bigint") {
      this.encodeBigInt64(object);
    } else {
      this.encodeObject(object, depth);
    }
  };
  Encoder2.prototype.ensureBufferSizeToWrite = function(sizeToWrite) {
    var requiredSize = this.pos + sizeToWrite;
    if (this.view.byteLength < requiredSize) {
      this.resizeBuffer(requiredSize * 2);
    }
  };
  Encoder2.prototype.resizeBuffer = function(newSize) {
    var newBuffer = new ArrayBuffer(newSize);
    var newBytes = new Uint8Array(newBuffer);
    var newView = new DataView(newBuffer);
    newBytes.set(this.bytes);
    this.view = newView;
    this.bytes = newBytes;
  };
  Encoder2.prototype.encodeNil = function() {
    this.writeU8(192);
  };
  Encoder2.prototype.encodeBoolean = function(object) {
    if (object === false) {
      this.writeU8(194);
    } else {
      this.writeU8(195);
    }
  };
  Encoder2.prototype.encodeNumber = function(object) {
    if (!this.forceIntegerToFloat && Number.isSafeInteger(object)) {
      if (object >= 0) {
        if (object < 128) {
          this.writeU8(object);
        } else if (object < 256) {
          this.writeU8(204);
          this.writeU8(object);
        } else if (object < 65536) {
          this.writeU8(205);
          this.writeU16(object);
        } else if (object < 4294967296) {
          this.writeU8(206);
          this.writeU32(object);
        } else if (!this.useBigInt64) {
          this.writeU8(207);
          this.writeU64(object);
        } else {
          this.encodeNumberAsFloat(object);
        }
      } else {
        if (object >= -32) {
          this.writeU8(224 | object + 32);
        } else if (object >= -128) {
          this.writeU8(208);
          this.writeI8(object);
        } else if (object >= -32768) {
          this.writeU8(209);
          this.writeI16(object);
        } else if (object >= -2147483648) {
          this.writeU8(210);
          this.writeI32(object);
        } else if (!this.useBigInt64) {
          this.writeU8(211);
          this.writeI64(object);
        } else {
          this.encodeNumberAsFloat(object);
        }
      }
    } else {
      this.encodeNumberAsFloat(object);
    }
  };
  Encoder2.prototype.encodeNumberAsFloat = function(object) {
    if (this.forceFloat32) {
      this.writeU8(202);
      this.writeF32(object);
    } else {
      this.writeU8(203);
      this.writeF64(object);
    }
  };
  Encoder2.prototype.encodeBigInt64 = function(object) {
    if (object >= BigInt(0)) {
      this.writeU8(207);
      this.writeBigUint64(object);
    } else {
      this.writeU8(211);
      this.writeBigInt64(object);
    }
  };
  Encoder2.prototype.writeStringHeader = function(byteLength) {
    if (byteLength < 32) {
      this.writeU8(160 + byteLength);
    } else if (byteLength < 256) {
      this.writeU8(217);
      this.writeU8(byteLength);
    } else if (byteLength < 65536) {
      this.writeU8(218);
      this.writeU16(byteLength);
    } else if (byteLength < 4294967296) {
      this.writeU8(219);
      this.writeU32(byteLength);
    } else {
      throw new Error("Too long string: ".concat(byteLength, " bytes in UTF-8"));
    }
  };
  Encoder2.prototype.encodeString = function(object) {
    var maxHeaderSize = 1 + 4;
    var byteLength = utf8Count(object);
    this.ensureBufferSizeToWrite(maxHeaderSize + byteLength);
    this.writeStringHeader(byteLength);
    utf8Encode(object, this.bytes, this.pos);
    this.pos += byteLength;
  };
  Encoder2.prototype.encodeObject = function(object, depth) {
    var ext = this.extensionCodec.tryToEncode(object, this.context);
    if (ext != null) {
      this.encodeExtension(ext);
    } else if (Array.isArray(object)) {
      this.encodeArray(object, depth);
    } else if (ArrayBuffer.isView(object)) {
      this.encodeBinary(object);
    } else if (typeof object === "object") {
      this.encodeMap(object, depth);
    } else {
      throw new Error("Unrecognized object: ".concat(Object.prototype.toString.apply(object)));
    }
  };
  Encoder2.prototype.encodeBinary = function(object) {
    var size = object.byteLength;
    if (size < 256) {
      this.writeU8(196);
      this.writeU8(size);
    } else if (size < 65536) {
      this.writeU8(197);
      this.writeU16(size);
    } else if (size < 4294967296) {
      this.writeU8(198);
      this.writeU32(size);
    } else {
      throw new Error("Too large binary: ".concat(size));
    }
    var bytes = ensureUint8Array(object);
    this.writeU8a(bytes);
  };
  Encoder2.prototype.encodeArray = function(object, depth) {
    var size = object.length;
    if (size < 16) {
      this.writeU8(144 + size);
    } else if (size < 65536) {
      this.writeU8(220);
      this.writeU16(size);
    } else if (size < 4294967296) {
      this.writeU8(221);
      this.writeU32(size);
    } else {
      throw new Error("Too large array: ".concat(size));
    }
    for (var _i = 0, object_1 = object; _i < object_1.length; _i++) {
      var item = object_1[_i];
      this.doEncode(item, depth + 1);
    }
  };
  Encoder2.prototype.countWithoutUndefined = function(object, keys) {
    var count = 0;
    for (var _i = 0, keys_1 = keys; _i < keys_1.length; _i++) {
      var key = keys_1[_i];
      if (object[key] !== void 0) {
        count++;
      }
    }
    return count;
  };
  Encoder2.prototype.encodeMap = function(object, depth) {
    var keys = Object.keys(object);
    if (this.sortKeys) {
      keys.sort();
    }
    var size = this.ignoreUndefined ? this.countWithoutUndefined(object, keys) : keys.length;
    if (size < 16) {
      this.writeU8(128 + size);
    } else if (size < 65536) {
      this.writeU8(222);
      this.writeU16(size);
    } else if (size < 4294967296) {
      this.writeU8(223);
      this.writeU32(size);
    } else {
      throw new Error("Too large map object: ".concat(size));
    }
    for (var _i = 0, keys_2 = keys; _i < keys_2.length; _i++) {
      var key = keys_2[_i];
      var value = object[key];
      if (!(this.ignoreUndefined && value === void 0)) {
        this.encodeString(key);
        this.doEncode(value, depth + 1);
      }
    }
  };
  Encoder2.prototype.encodeExtension = function(ext) {
    var size = ext.data.length;
    if (size === 1) {
      this.writeU8(212);
    } else if (size === 2) {
      this.writeU8(213);
    } else if (size === 4) {
      this.writeU8(214);
    } else if (size === 8) {
      this.writeU8(215);
    } else if (size === 16) {
      this.writeU8(216);
    } else if (size < 256) {
      this.writeU8(199);
      this.writeU8(size);
    } else if (size < 65536) {
      this.writeU8(200);
      this.writeU16(size);
    } else if (size < 4294967296) {
      this.writeU8(201);
      this.writeU32(size);
    } else {
      throw new Error("Too large extension object: ".concat(size));
    }
    this.writeI8(ext.type);
    this.writeU8a(ext.data);
  };
  Encoder2.prototype.writeU8 = function(value) {
    this.ensureBufferSizeToWrite(1);
    this.view.setUint8(this.pos, value);
    this.pos++;
  };
  Encoder2.prototype.writeU8a = function(values) {
    var size = values.length;
    this.ensureBufferSizeToWrite(size);
    this.bytes.set(values, this.pos);
    this.pos += size;
  };
  Encoder2.prototype.writeI8 = function(value) {
    this.ensureBufferSizeToWrite(1);
    this.view.setInt8(this.pos, value);
    this.pos++;
  };
  Encoder2.prototype.writeU16 = function(value) {
    this.ensureBufferSizeToWrite(2);
    this.view.setUint16(this.pos, value);
    this.pos += 2;
  };
  Encoder2.prototype.writeI16 = function(value) {
    this.ensureBufferSizeToWrite(2);
    this.view.setInt16(this.pos, value);
    this.pos += 2;
  };
  Encoder2.prototype.writeU32 = function(value) {
    this.ensureBufferSizeToWrite(4);
    this.view.setUint32(this.pos, value);
    this.pos += 4;
  };
  Encoder2.prototype.writeI32 = function(value) {
    this.ensureBufferSizeToWrite(4);
    this.view.setInt32(this.pos, value);
    this.pos += 4;
  };
  Encoder2.prototype.writeF32 = function(value) {
    this.ensureBufferSizeToWrite(4);
    this.view.setFloat32(this.pos, value);
    this.pos += 4;
  };
  Encoder2.prototype.writeF64 = function(value) {
    this.ensureBufferSizeToWrite(8);
    this.view.setFloat64(this.pos, value);
    this.pos += 8;
  };
  Encoder2.prototype.writeU64 = function(value) {
    this.ensureBufferSizeToWrite(8);
    setUint64(this.view, this.pos, value);
    this.pos += 8;
  };
  Encoder2.prototype.writeI64 = function(value) {
    this.ensureBufferSizeToWrite(8);
    setInt64(this.view, this.pos, value);
    this.pos += 8;
  };
  Encoder2.prototype.writeBigUint64 = function(value) {
    this.ensureBufferSizeToWrite(8);
    this.view.setBigUint64(this.pos, value);
    this.pos += 8;
  };
  Encoder2.prototype.writeBigInt64 = function(value) {
    this.ensureBufferSizeToWrite(8);
    this.view.setBigInt64(this.pos, value);
    this.pos += 8;
  };
  return Encoder2;
}();

// ../node_modules/@msgpack/msgpack/dist.es5+esm/utils/prettyByte.mjs
function prettyByte(byte) {
  return "".concat(byte < 0 ? "-" : "", "0x").concat(Math.abs(byte).toString(16).padStart(2, "0"));
}

// ../node_modules/@msgpack/msgpack/dist.es5+esm/CachedKeyDecoder.mjs
var DEFAULT_MAX_KEY_LENGTH = 16;
var DEFAULT_MAX_LENGTH_PER_KEY = 16;
var CachedKeyDecoder = function() {
  function CachedKeyDecoder2(maxKeyLength, maxLengthPerKey) {
    if (maxKeyLength === void 0) {
      maxKeyLength = DEFAULT_MAX_KEY_LENGTH;
    }
    if (maxLengthPerKey === void 0) {
      maxLengthPerKey = DEFAULT_MAX_LENGTH_PER_KEY;
    }
    this.maxKeyLength = maxKeyLength;
    this.maxLengthPerKey = maxLengthPerKey;
    this.hit = 0;
    this.miss = 0;
    this.caches = [];
    for (var i = 0; i < this.maxKeyLength; i++) {
      this.caches.push([]);
    }
  }
  CachedKeyDecoder2.prototype.canBeCached = function(byteLength) {
    return byteLength > 0 && byteLength <= this.maxKeyLength;
  };
  CachedKeyDecoder2.prototype.find = function(bytes, inputOffset, byteLength) {
    var records = this.caches[byteLength - 1];
    FIND_CHUNK:
      for (var _i = 0, records_1 = records; _i < records_1.length; _i++) {
        var record = records_1[_i];
        var recordBytes = record.bytes;
        for (var j = 0; j < byteLength; j++) {
          if (recordBytes[j] !== bytes[inputOffset + j]) {
            continue FIND_CHUNK;
          }
        }
        return record.str;
      }
    return null;
  };
  CachedKeyDecoder2.prototype.store = function(bytes, value) {
    var records = this.caches[bytes.length - 1];
    var record = { bytes, str: value };
    if (records.length >= this.maxLengthPerKey) {
      records[Math.random() * records.length | 0] = record;
    } else {
      records.push(record);
    }
  };
  CachedKeyDecoder2.prototype.decode = function(bytes, inputOffset, byteLength) {
    var cachedValue = this.find(bytes, inputOffset, byteLength);
    if (cachedValue != null) {
      this.hit++;
      return cachedValue;
    }
    this.miss++;
    var str = utf8DecodeJs(bytes, inputOffset, byteLength);
    var slicedCopyOfBytes = Uint8Array.prototype.slice.call(bytes, inputOffset, inputOffset + byteLength);
    this.store(slicedCopyOfBytes, str);
    return str;
  };
  return CachedKeyDecoder2;
}();

// ../node_modules/@msgpack/msgpack/dist.es5+esm/Decoder.mjs
var __awaiter = function(thisArg, _arguments, P, generator) {
  function adopt(value) {
    return value instanceof P ? value : new P(function(resolve) {
      resolve(value);
    });
  }
  return new (P || (P = Promise))(function(resolve, reject) {
    function fulfilled(value) {
      try {
        step(generator.next(value));
      } catch (e) {
        reject(e);
      }
    }
    function rejected(value) {
      try {
        step(generator["throw"](value));
      } catch (e) {
        reject(e);
      }
    }
    function step(result) {
      result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected);
    }
    step((generator = generator.apply(thisArg, _arguments || [])).next());
  });
};
var __generator = function(thisArg, body) {
  var _ = { label: 0, sent: function() {
    if (t[0] & 1)
      throw t[1];
    return t[1];
  }, trys: [], ops: [] }, f, y, t, g;
  return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() {
    return this;
  }), g;
  function verb(n) {
    return function(v) {
      return step([n, v]);
    };
  }
  function step(op) {
    if (f)
      throw new TypeError("Generator is already executing.");
    while (g && (g = 0, op[0] && (_ = 0)), _)
      try {
        if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done)
          return t;
        if (y = 0, t)
          op = [op[0] & 2, t.value];
        switch (op[0]) {
          case 0:
          case 1:
            t = op;
            break;
          case 4:
            _.label++;
            return { value: op[1], done: false };
          case 5:
            _.label++;
            y = op[1];
            op = [0];
            continue;
          case 7:
            op = _.ops.pop();
            _.trys.pop();
            continue;
          default:
            if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) {
              _ = 0;
              continue;
            }
            if (op[0] === 3 && (!t || op[1] > t[0] && op[1] < t[3])) {
              _.label = op[1];
              break;
            }
            if (op[0] === 6 && _.label < t[1]) {
              _.label = t[1];
              t = op;
              break;
            }
            if (t && _.label < t[2]) {
              _.label = t[2];
              _.ops.push(op);
              break;
            }
            if (t[2])
              _.ops.pop();
            _.trys.pop();
            continue;
        }
        op = body.call(thisArg, _);
      } catch (e) {
        op = [6, e];
        y = 0;
      } finally {
        f = t = 0;
      }
    if (op[0] & 5)
      throw op[1];
    return { value: op[0] ? op[1] : void 0, done: true };
  }
};
var __asyncValues = function(o) {
  if (!Symbol.asyncIterator)
    throw new TypeError("Symbol.asyncIterator is not defined.");
  var m = o[Symbol.asyncIterator], i;
  return m ? m.call(o) : (o = typeof __values === "function" ? __values(o) : o[Symbol.iterator](), i = {}, verb("next"), verb("throw"), verb("return"), i[Symbol.asyncIterator] = function() {
    return this;
  }, i);
  function verb(n) {
    i[n] = o[n] && function(v) {
      return new Promise(function(resolve, reject) {
        v = o[n](v), settle(resolve, reject, v.done, v.value);
      });
    };
  }
  function settle(resolve, reject, d, v) {
    Promise.resolve(v).then(function(v2) {
      resolve({ value: v2, done: d });
    }, reject);
  }
};
var __await = function(v) {
  return this instanceof __await ? (this.v = v, this) : new __await(v);
};
var __asyncGenerator = function(thisArg, _arguments, generator) {
  if (!Symbol.asyncIterator)
    throw new TypeError("Symbol.asyncIterator is not defined.");
  var g = generator.apply(thisArg, _arguments || []), i, q = [];
  return i = {}, verb("next"), verb("throw"), verb("return"), i[Symbol.asyncIterator] = function() {
    return this;
  }, i;
  function verb(n) {
    if (g[n])
      i[n] = function(v) {
        return new Promise(function(a, b) {
          q.push([n, v, a, b]) > 1 || resume(n, v);
        });
      };
  }
  function resume(n, v) {
    try {
      step(g[n](v));
    } catch (e) {
      settle(q[0][3], e);
    }
  }
  function step(r) {
    r.value instanceof __await ? Promise.resolve(r.value.v).then(fulfill, reject) : settle(q[0][2], r);
  }
  function fulfill(value) {
    resume("next", value);
  }
  function reject(value) {
    resume("throw", value);
  }
  function settle(f, v) {
    if (f(v), q.shift(), q.length)
      resume(q[0][0], q[0][1]);
  }
};
var STATE_ARRAY = "array";
var STATE_MAP_KEY = "map_key";
var STATE_MAP_VALUE = "map_value";
var isValidMapKeyType = function(key) {
  return typeof key === "string" || typeof key === "number";
};
var HEAD_BYTE_REQUIRED = -1;
var EMPTY_VIEW = new DataView(new ArrayBuffer(0));
var EMPTY_BYTES = new Uint8Array(EMPTY_VIEW.buffer);
try {
  EMPTY_VIEW.getInt8(0);
} catch (e) {
  if (!(e instanceof RangeError)) {
    throw new Error("This module is not supported in the current JavaScript engine because DataView does not throw RangeError on out-of-bounds access");
  }
}
var DataViewIndexOutOfBoundsError = RangeError;
var MORE_DATA = new DataViewIndexOutOfBoundsError("Insufficient data");
var sharedCachedKeyDecoder = new CachedKeyDecoder();
var Decoder = function() {
  function Decoder2(options) {
    var _a, _b, _c, _d, _e, _f, _g;
    this.totalPos = 0;
    this.pos = 0;
    this.view = EMPTY_VIEW;
    this.bytes = EMPTY_BYTES;
    this.headByte = HEAD_BYTE_REQUIRED;
    this.stack = [];
    this.extensionCodec = (_a = options === null || options === void 0 ? void 0 : options.extensionCodec) !== null && _a !== void 0 ? _a : ExtensionCodec.defaultCodec;
    this.context = options === null || options === void 0 ? void 0 : options.context;
    this.useBigInt64 = (_b = options === null || options === void 0 ? void 0 : options.useBigInt64) !== null && _b !== void 0 ? _b : false;
    this.maxStrLength = (_c = options === null || options === void 0 ? void 0 : options.maxStrLength) !== null && _c !== void 0 ? _c : UINT32_MAX;
    this.maxBinLength = (_d = options === null || options === void 0 ? void 0 : options.maxBinLength) !== null && _d !== void 0 ? _d : UINT32_MAX;
    this.maxArrayLength = (_e = options === null || options === void 0 ? void 0 : options.maxArrayLength) !== null && _e !== void 0 ? _e : UINT32_MAX;
    this.maxMapLength = (_f = options === null || options === void 0 ? void 0 : options.maxMapLength) !== null && _f !== void 0 ? _f : UINT32_MAX;
    this.maxExtLength = (_g = options === null || options === void 0 ? void 0 : options.maxExtLength) !== null && _g !== void 0 ? _g : UINT32_MAX;
    this.keyDecoder = (options === null || options === void 0 ? void 0 : options.keyDecoder) !== void 0 ? options.keyDecoder : sharedCachedKeyDecoder;
  }
  Decoder2.prototype.reinitializeState = function() {
    this.totalPos = 0;
    this.headByte = HEAD_BYTE_REQUIRED;
    this.stack.length = 0;
  };
  Decoder2.prototype.setBuffer = function(buffer) {
    this.bytes = ensureUint8Array(buffer);
    this.view = createDataView(this.bytes);
    this.pos = 0;
  };
  Decoder2.prototype.appendBuffer = function(buffer) {
    if (this.headByte === HEAD_BYTE_REQUIRED && !this.hasRemaining(1)) {
      this.setBuffer(buffer);
    } else {
      var remainingData = this.bytes.subarray(this.pos);
      var newData = ensureUint8Array(buffer);
      var newBuffer = new Uint8Array(remainingData.length + newData.length);
      newBuffer.set(remainingData);
      newBuffer.set(newData, remainingData.length);
      this.setBuffer(newBuffer);
    }
  };
  Decoder2.prototype.hasRemaining = function(size) {
    return this.view.byteLength - this.pos >= size;
  };
  Decoder2.prototype.createExtraByteError = function(posToShow) {
    var _a = this, view = _a.view, pos = _a.pos;
    return new RangeError("Extra ".concat(view.byteLength - pos, " of ").concat(view.byteLength, " byte(s) found at buffer[").concat(posToShow, "]"));
  };
  Decoder2.prototype.decode = function(buffer) {
    this.reinitializeState();
    this.setBuffer(buffer);
    var object = this.doDecodeSync();
    if (this.hasRemaining(1)) {
      throw this.createExtraByteError(this.pos);
    }
    return object;
  };
  Decoder2.prototype.decodeMulti = function(buffer) {
    return __generator(this, function(_a) {
      switch (_a.label) {
        case 0:
          this.reinitializeState();
          this.setBuffer(buffer);
          _a.label = 1;
        case 1:
          if (!this.hasRemaining(1))
            return [3, 3];
          return [4, this.doDecodeSync()];
        case 2:
          _a.sent();
          return [3, 1];
        case 3:
          return [2];
      }
    });
  };
  Decoder2.prototype.decodeAsync = function(stream) {
    var _a, stream_1, stream_1_1;
    var _b, e_1, _c, _d;
    return __awaiter(this, void 0, void 0, function() {
      var decoded, object, buffer, e_1_1, _e, headByte, pos, totalPos;
      return __generator(this, function(_f) {
        switch (_f.label) {
          case 0:
            decoded = false;
            _f.label = 1;
          case 1:
            _f.trys.push([1, 6, 7, 12]);
            _a = true, stream_1 = __asyncValues(stream);
            _f.label = 2;
          case 2:
            return [4, stream_1.next()];
          case 3:
            if (!(stream_1_1 = _f.sent(), _b = stream_1_1.done, !_b))
              return [3, 5];
            _d = stream_1_1.value;
            _a = false;
            try {
              buffer = _d;
              if (decoded) {
                throw this.createExtraByteError(this.totalPos);
              }
              this.appendBuffer(buffer);
              try {
                object = this.doDecodeSync();
                decoded = true;
              } catch (e) {
                if (!(e instanceof DataViewIndexOutOfBoundsError)) {
                  throw e;
                }
              }
              this.totalPos += this.pos;
            } finally {
              _a = true;
            }
            _f.label = 4;
          case 4:
            return [3, 2];
          case 5:
            return [3, 12];
          case 6:
            e_1_1 = _f.sent();
            e_1 = { error: e_1_1 };
            return [3, 12];
          case 7:
            _f.trys.push([7, , 10, 11]);
            if (!(!_a && !_b && (_c = stream_1.return)))
              return [3, 9];
            return [4, _c.call(stream_1)];
          case 8:
            _f.sent();
            _f.label = 9;
          case 9:
            return [3, 11];
          case 10:
            if (e_1)
              throw e_1.error;
            return [7];
          case 11:
            return [7];
          case 12:
            if (decoded) {
              if (this.hasRemaining(1)) {
                throw this.createExtraByteError(this.totalPos);
              }
              return [2, object];
            }
            _e = this, headByte = _e.headByte, pos = _e.pos, totalPos = _e.totalPos;
            throw new RangeError("Insufficient data in parsing ".concat(prettyByte(headByte), " at ").concat(totalPos, " (").concat(pos, " in the current buffer)"));
        }
      });
    });
  };
  Decoder2.prototype.decodeArrayStream = function(stream) {
    return this.decodeMultiAsync(stream, true);
  };
  Decoder2.prototype.decodeStream = function(stream) {
    return this.decodeMultiAsync(stream, false);
  };
  Decoder2.prototype.decodeMultiAsync = function(stream, isArray) {
    return __asyncGenerator(this, arguments, function decodeMultiAsync_1() {
      var isArrayHeaderRequired, arrayItemsLeft, _a, stream_2, stream_2_1, buffer, e_2, e_3_1;
      var _b, e_3, _c, _d;
      return __generator(this, function(_e) {
        switch (_e.label) {
          case 0:
            isArrayHeaderRequired = isArray;
            arrayItemsLeft = -1;
            _e.label = 1;
          case 1:
            _e.trys.push([1, 15, 16, 21]);
            _a = true, stream_2 = __asyncValues(stream);
            _e.label = 2;
          case 2:
            return [4, __await(stream_2.next())];
          case 3:
            if (!(stream_2_1 = _e.sent(), _b = stream_2_1.done, !_b))
              return [3, 14];
            _d = stream_2_1.value;
            _a = false;
            _e.label = 4;
          case 4:
            _e.trys.push([4, , 12, 13]);
            buffer = _d;
            if (isArray && arrayItemsLeft === 0) {
              throw this.createExtraByteError(this.totalPos);
            }
            this.appendBuffer(buffer);
            if (isArrayHeaderRequired) {
              arrayItemsLeft = this.readArraySize();
              isArrayHeaderRequired = false;
              this.complete();
            }
            _e.label = 5;
          case 5:
            _e.trys.push([5, 10, , 11]);
            _e.label = 6;
          case 6:
            if (false)
              return [3, 9];
            return [4, __await(this.doDecodeSync())];
          case 7:
            return [4, _e.sent()];
          case 8:
            _e.sent();
            if (--arrayItemsLeft === 0) {
              return [3, 9];
            }
            return [3, 6];
          case 9:
            return [3, 11];
          case 10:
            e_2 = _e.sent();
            if (!(e_2 instanceof DataViewIndexOutOfBoundsError)) {
              throw e_2;
            }
            return [3, 11];
          case 11:
            this.totalPos += this.pos;
            return [3, 13];
          case 12:
            _a = true;
            return [7];
          case 13:
            return [3, 2];
          case 14:
            return [3, 21];
          case 15:
            e_3_1 = _e.sent();
            e_3 = { error: e_3_1 };
            return [3, 21];
          case 16:
            _e.trys.push([16, , 19, 20]);
            if (!(!_a && !_b && (_c = stream_2.return)))
              return [3, 18];
            return [4, __await(_c.call(stream_2))];
          case 17:
            _e.sent();
            _e.label = 18;
          case 18:
            return [3, 20];
          case 19:
            if (e_3)
              throw e_3.error;
            return [7];
          case 20:
            return [7];
          case 21:
            return [2];
        }
      });
    });
  };
  Decoder2.prototype.doDecodeSync = function() {
    DECODE:
      while (true) {
        var headByte = this.readHeadByte();
        var object = void 0;
        if (headByte >= 224) {
          object = headByte - 256;
        } else if (headByte < 192) {
          if (headByte < 128) {
            object = headByte;
          } else if (headByte < 144) {
            var size = headByte - 128;
            if (size !== 0) {
              this.pushMapState(size);
              this.complete();
              continue DECODE;
            } else {
              object = {};
            }
          } else if (headByte < 160) {
            var size = headByte - 144;
            if (size !== 0) {
              this.pushArrayState(size);
              this.complete();
              continue DECODE;
            } else {
              object = [];
            }
          } else {
            var byteLength = headByte - 160;
            object = this.decodeUtf8String(byteLength, 0);
          }
        } else if (headByte === 192) {
          object = null;
        } else if (headByte === 194) {
          object = false;
        } else if (headByte === 195) {
          object = true;
        } else if (headByte === 202) {
          object = this.readF32();
        } else if (headByte === 203) {
          object = this.readF64();
        } else if (headByte === 204) {
          object = this.readU8();
        } else if (headByte === 205) {
          object = this.readU16();
        } else if (headByte === 206) {
          object = this.readU32();
        } else if (headByte === 207) {
          if (this.useBigInt64) {
            object = this.readU64AsBigInt();
          } else {
            object = this.readU64();
          }
        } else if (headByte === 208) {
          object = this.readI8();
        } else if (headByte === 209) {
          object = this.readI16();
        } else if (headByte === 210) {
          object = this.readI32();
        } else if (headByte === 211) {
          if (this.useBigInt64) {
            object = this.readI64AsBigInt();
          } else {
            object = this.readI64();
          }
        } else if (headByte === 217) {
          var byteLength = this.lookU8();
          object = this.decodeUtf8String(byteLength, 1);
        } else if (headByte === 218) {
          var byteLength = this.lookU16();
          object = this.decodeUtf8String(byteLength, 2);
        } else if (headByte === 219) {
          var byteLength = this.lookU32();
          object = this.decodeUtf8String(byteLength, 4);
        } else if (headByte === 220) {
          var size = this.readU16();
          if (size !== 0) {
            this.pushArrayState(size);
            this.complete();
            continue DECODE;
          } else {
            object = [];
          }
        } else if (headByte === 221) {
          var size = this.readU32();
          if (size !== 0) {
            this.pushArrayState(size);
            this.complete();
            continue DECODE;
          } else {
            object = [];
          }
        } else if (headByte === 222) {
          var size = this.readU16();
          if (size !== 0) {
            this.pushMapState(size);
            this.complete();
            continue DECODE;
          } else {
            object = {};
          }
        } else if (headByte === 223) {
          var size = this.readU32();
          if (size !== 0) {
            this.pushMapState(size);
            this.complete();
            continue DECODE;
          } else {
            object = {};
          }
        } else if (headByte === 196) {
          var size = this.lookU8();
          object = this.decodeBinary(size, 1);
        } else if (headByte === 197) {
          var size = this.lookU16();
          object = this.decodeBinary(size, 2);
        } else if (headByte === 198) {
          var size = this.lookU32();
          object = this.decodeBinary(size, 4);
        } else if (headByte === 212) {
          object = this.decodeExtension(1, 0);
        } else if (headByte === 213) {
          object = this.decodeExtension(2, 0);
        } else if (headByte === 214) {
          object = this.decodeExtension(4, 0);
        } else if (headByte === 215) {
          object = this.decodeExtension(8, 0);
        } else if (headByte === 216) {
          object = this.decodeExtension(16, 0);
        } else if (headByte === 199) {
          var size = this.lookU8();
          object = this.decodeExtension(size, 1);
        } else if (headByte === 200) {
          var size = this.lookU16();
          object = this.decodeExtension(size, 2);
        } else if (headByte === 201) {
          var size = this.lookU32();
          object = this.decodeExtension(size, 4);
        } else {
          throw new DecodeError("Unrecognized type byte: ".concat(prettyByte(headByte)));
        }
        this.complete();
        var stack = this.stack;
        while (stack.length > 0) {
          var state = stack[stack.length - 1];
          if (state.type === STATE_ARRAY) {
            state.array[state.position] = object;
            state.position++;
            if (state.position === state.size) {
              stack.pop();
              object = state.array;
            } else {
              continue DECODE;
            }
          } else if (state.type === STATE_MAP_KEY) {
            if (!isValidMapKeyType(object)) {
              throw new DecodeError("The type of key must be string or number but " + typeof object);
            }
            if (object === "__proto__") {
              throw new DecodeError("The key __proto__ is not allowed");
            }
            state.key = object;
            state.type = STATE_MAP_VALUE;
            continue DECODE;
          } else {
            state.map[state.key] = object;
            state.readCount++;
            if (state.readCount === state.size) {
              stack.pop();
              object = state.map;
            } else {
              state.key = null;
              state.type = STATE_MAP_KEY;
              continue DECODE;
            }
          }
        }
        return object;
      }
  };
  Decoder2.prototype.readHeadByte = function() {
    if (this.headByte === HEAD_BYTE_REQUIRED) {
      this.headByte = this.readU8();
    }
    return this.headByte;
  };
  Decoder2.prototype.complete = function() {
    this.headByte = HEAD_BYTE_REQUIRED;
  };
  Decoder2.prototype.readArraySize = function() {
    var headByte = this.readHeadByte();
    switch (headByte) {
      case 220:
        return this.readU16();
      case 221:
        return this.readU32();
      default: {
        if (headByte < 160) {
          return headByte - 144;
        } else {
          throw new DecodeError("Unrecognized array type byte: ".concat(prettyByte(headByte)));
        }
      }
    }
  };
  Decoder2.prototype.pushMapState = function(size) {
    if (size > this.maxMapLength) {
      throw new DecodeError("Max length exceeded: map length (".concat(size, ") > maxMapLengthLength (").concat(this.maxMapLength, ")"));
    }
    this.stack.push({
      type: STATE_MAP_KEY,
      size,
      key: null,
      readCount: 0,
      map: {}
    });
  };
  Decoder2.prototype.pushArrayState = function(size) {
    if (size > this.maxArrayLength) {
      throw new DecodeError("Max length exceeded: array length (".concat(size, ") > maxArrayLength (").concat(this.maxArrayLength, ")"));
    }
    this.stack.push({
      type: STATE_ARRAY,
      size,
      array: new Array(size),
      position: 0
    });
  };
  Decoder2.prototype.decodeUtf8String = function(byteLength, headerOffset) {
    var _a;
    if (byteLength > this.maxStrLength) {
      throw new DecodeError("Max length exceeded: UTF-8 byte length (".concat(byteLength, ") > maxStrLength (").concat(this.maxStrLength, ")"));
    }
    if (this.bytes.byteLength < this.pos + headerOffset + byteLength) {
      throw MORE_DATA;
    }
    var offset = this.pos + headerOffset;
    var object;
    if (this.stateIsMapKey() && ((_a = this.keyDecoder) === null || _a === void 0 ? void 0 : _a.canBeCached(byteLength))) {
      object = this.keyDecoder.decode(this.bytes, offset, byteLength);
    } else {
      object = utf8Decode(this.bytes, offset, byteLength);
    }
    this.pos += headerOffset + byteLength;
    return object;
  };
  Decoder2.prototype.stateIsMapKey = function() {
    if (this.stack.length > 0) {
      var state = this.stack[this.stack.length - 1];
      return state.type === STATE_MAP_KEY;
    }
    return false;
  };
  Decoder2.prototype.decodeBinary = function(byteLength, headOffset) {
    if (byteLength > this.maxBinLength) {
      throw new DecodeError("Max length exceeded: bin length (".concat(byteLength, ") > maxBinLength (").concat(this.maxBinLength, ")"));
    }
    if (!this.hasRemaining(byteLength + headOffset)) {
      throw MORE_DATA;
    }
    var offset = this.pos + headOffset;
    var object = this.bytes.subarray(offset, offset + byteLength);
    this.pos += headOffset + byteLength;
    return object;
  };
  Decoder2.prototype.decodeExtension = function(size, headOffset) {
    if (size > this.maxExtLength) {
      throw new DecodeError("Max length exceeded: ext length (".concat(size, ") > maxExtLength (").concat(this.maxExtLength, ")"));
    }
    var extType = this.view.getInt8(this.pos + headOffset);
    var data = this.decodeBinary(size, headOffset + 1);
    return this.extensionCodec.decode(data, extType, this.context);
  };
  Decoder2.prototype.lookU8 = function() {
    return this.view.getUint8(this.pos);
  };
  Decoder2.prototype.lookU16 = function() {
    return this.view.getUint16(this.pos);
  };
  Decoder2.prototype.lookU32 = function() {
    return this.view.getUint32(this.pos);
  };
  Decoder2.prototype.readU8 = function() {
    var value = this.view.getUint8(this.pos);
    this.pos++;
    return value;
  };
  Decoder2.prototype.readI8 = function() {
    var value = this.view.getInt8(this.pos);
    this.pos++;
    return value;
  };
  Decoder2.prototype.readU16 = function() {
    var value = this.view.getUint16(this.pos);
    this.pos += 2;
    return value;
  };
  Decoder2.prototype.readI16 = function() {
    var value = this.view.getInt16(this.pos);
    this.pos += 2;
    return value;
  };
  Decoder2.prototype.readU32 = function() {
    var value = this.view.getUint32(this.pos);
    this.pos += 4;
    return value;
  };
  Decoder2.prototype.readI32 = function() {
    var value = this.view.getInt32(this.pos);
    this.pos += 4;
    return value;
  };
  Decoder2.prototype.readU64 = function() {
    var value = getUint64(this.view, this.pos);
    this.pos += 8;
    return value;
  };
  Decoder2.prototype.readI64 = function() {
    var value = getInt64(this.view, this.pos);
    this.pos += 8;
    return value;
  };
  Decoder2.prototype.readU64AsBigInt = function() {
    var value = this.view.getBigUint64(this.pos);
    this.pos += 8;
    return value;
  };
  Decoder2.prototype.readI64AsBigInt = function() {
    var value = this.view.getBigInt64(this.pos);
    this.pos += 8;
    return value;
  };
  Decoder2.prototype.readF32 = function() {
    var value = this.view.getFloat32(this.pos);
    this.pos += 4;
    return value;
  };
  Decoder2.prototype.readF64 = function() {
    var value = this.view.getFloat64(this.pos);
    this.pos += 8;
    return value;
  };
  return Decoder2;
}();

// js/_hooks/Punkix.Components.ListComponent.hooks.js
var Punkix_Components_ListComponent_hooks_exports = {};
__export(Punkix_Components_ListComponent_hooks_exports, {
  default: () => Punkix_Components_ListComponent_hooks_default
});

// ../node_modules/@shopify/draggable/build/esm/shared/AbstractEvent/AbstractEvent.mjs
var AbstractEvent = class {
  constructor(data) {
    this._canceled = false;
    this.data = data;
  }
  get type() {
    return this.constructor.type;
  }
  get cancelable() {
    return this.constructor.cancelable;
  }
  cancel() {
    this._canceled = true;
  }
  canceled() {
    return this._canceled;
  }
  clone(data) {
    return new this.constructor({
      ...this.data,
      ...data
    });
  }
};
AbstractEvent.type = "event";
AbstractEvent.cancelable = false;

// ../node_modules/@shopify/draggable/build/esm/shared/AbstractPlugin/AbstractPlugin.mjs
var AbstractPlugin = class {
  constructor(draggable) {
    this.draggable = draggable;
  }
  attach() {
    throw new Error("Not Implemented");
  }
  detach() {
    throw new Error("Not Implemented");
  }
};

// ../node_modules/@shopify/draggable/build/esm/Draggable/Sensors/Sensor/Sensor.mjs
var defaultDelay = {
  mouse: 0,
  drag: 0,
  touch: 100
};
var Sensor = class {
  constructor(containers = [], options = {}) {
    this.containers = [...containers];
    this.options = {
      ...options
    };
    this.dragging = false;
    this.currentContainer = null;
    this.originalSource = null;
    this.startEvent = null;
    this.delay = calcDelay(options.delay);
  }
  attach() {
    return this;
  }
  detach() {
    return this;
  }
  addContainer(...containers) {
    this.containers = [...this.containers, ...containers];
  }
  removeContainer(...containers) {
    this.containers = this.containers.filter((container) => !containers.includes(container));
  }
  trigger(element, sensorEvent) {
    const event = document.createEvent("Event");
    event.detail = sensorEvent;
    event.initEvent(sensorEvent.type, true, true);
    element.dispatchEvent(event);
    this.lastEvent = sensorEvent;
    return sensorEvent;
  }
};
function calcDelay(optionsDelay) {
  const delay = {};
  if (optionsDelay === void 0) {
    return {
      ...defaultDelay
    };
  }
  if (typeof optionsDelay === "number") {
    for (const key in defaultDelay) {
      if (Object.prototype.hasOwnProperty.call(defaultDelay, key)) {
        delay[key] = optionsDelay;
      }
    }
    return delay;
  }
  for (const key in defaultDelay) {
    if (Object.prototype.hasOwnProperty.call(defaultDelay, key)) {
      if (optionsDelay[key] === void 0) {
        delay[key] = defaultDelay[key];
      } else {
        delay[key] = optionsDelay[key];
      }
    }
  }
  return delay;
}

// ../node_modules/@shopify/draggable/build/esm/shared/utils/closest/closest.mjs
function closest(node, value) {
  if (node == null) {
    return null;
  }
  function conditionFn(currentNode) {
    if (currentNode == null || value == null) {
      return false;
    } else if (isSelector(value)) {
      return Element.prototype.matches.call(currentNode, value);
    } else if (isNodeList(value)) {
      return [...value].includes(currentNode);
    } else if (isElement(value)) {
      return value === currentNode;
    } else if (isFunction(value)) {
      return value(currentNode);
    } else {
      return false;
    }
  }
  let current = node;
  do {
    current = current.correspondingUseElement || current.correspondingElement || current;
    if (conditionFn(current)) {
      return current;
    }
    current = current?.parentNode || null;
  } while (current != null && current !== document.body && current !== document);
  return null;
}
function isSelector(value) {
  return Boolean(typeof value === "string");
}
function isNodeList(value) {
  return Boolean(value instanceof NodeList || value instanceof Array);
}
function isElement(value) {
  return Boolean(value instanceof Node);
}
function isFunction(value) {
  return Boolean(typeof value === "function");
}

// ../node_modules/@shopify/draggable/build/esm/shared/utils/distance/distance.mjs
function distance(x1, y1, x2, y2) {
  return Math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2);
}

// ../node_modules/@shopify/draggable/build/esm/Draggable/Sensors/SensorEvent/SensorEvent.mjs
var SensorEvent = class extends AbstractEvent {
  get originalEvent() {
    return this.data.originalEvent;
  }
  get clientX() {
    return this.data.clientX;
  }
  get clientY() {
    return this.data.clientY;
  }
  get target() {
    return this.data.target;
  }
  get container() {
    return this.data.container;
  }
  get originalSource() {
    return this.data.originalSource;
  }
  get pressure() {
    return this.data.pressure;
  }
};
var DragStartSensorEvent = class extends SensorEvent {
};
DragStartSensorEvent.type = "drag:start";
var DragMoveSensorEvent = class extends SensorEvent {
};
DragMoveSensorEvent.type = "drag:move";
var DragStopSensorEvent = class extends SensorEvent {
};
DragStopSensorEvent.type = "drag:stop";
var DragPressureSensorEvent = class extends SensorEvent {
};
DragPressureSensorEvent.type = "drag:pressure";

// ../node_modules/@shopify/draggable/build/esm/Draggable/Sensors/MouseSensor/MouseSensor.mjs
var onContextMenuWhileDragging = Symbol("onContextMenuWhileDragging");
var onMouseDown = Symbol("onMouseDown");
var onMouseMove = Symbol("onMouseMove");
var onMouseUp = Symbol("onMouseUp");
var startDrag = Symbol("startDrag");
var onDistanceChange = Symbol("onDistanceChange");
var MouseSensor = class extends Sensor {
  constructor(containers = [], options = {}) {
    super(containers, options);
    this.mouseDownTimeout = null;
    this.pageX = null;
    this.pageY = null;
    this[onContextMenuWhileDragging] = this[onContextMenuWhileDragging].bind(this);
    this[onMouseDown] = this[onMouseDown].bind(this);
    this[onMouseMove] = this[onMouseMove].bind(this);
    this[onMouseUp] = this[onMouseUp].bind(this);
    this[startDrag] = this[startDrag].bind(this);
    this[onDistanceChange] = this[onDistanceChange].bind(this);
  }
  attach() {
    document.addEventListener("mousedown", this[onMouseDown], true);
  }
  detach() {
    document.removeEventListener("mousedown", this[onMouseDown], true);
  }
  [onMouseDown](event) {
    if (event.button !== 0 || event.ctrlKey || event.metaKey) {
      return;
    }
    const container = closest(event.target, this.containers);
    if (!container) {
      return;
    }
    if (this.options.handle && event.target && !closest(event.target, this.options.handle)) {
      return;
    }
    const originalSource = closest(event.target, this.options.draggable);
    if (!originalSource) {
      return;
    }
    const {
      delay
    } = this;
    const {
      pageX,
      pageY
    } = event;
    Object.assign(this, {
      pageX,
      pageY
    });
    this.onMouseDownAt = Date.now();
    this.startEvent = event;
    this.currentContainer = container;
    this.originalSource = originalSource;
    document.addEventListener("mouseup", this[onMouseUp]);
    document.addEventListener("dragstart", preventNativeDragStart);
    document.addEventListener("mousemove", this[onDistanceChange]);
    this.mouseDownTimeout = window.setTimeout(() => {
      this[onDistanceChange]({
        pageX: this.pageX,
        pageY: this.pageY
      });
    }, delay.mouse);
  }
  [startDrag]() {
    const startEvent = this.startEvent;
    const container = this.currentContainer;
    const originalSource = this.originalSource;
    const dragStartEvent = new DragStartSensorEvent({
      clientX: startEvent.clientX,
      clientY: startEvent.clientY,
      target: startEvent.target,
      container,
      originalSource,
      originalEvent: startEvent
    });
    this.trigger(this.currentContainer, dragStartEvent);
    this.dragging = !dragStartEvent.canceled();
    if (this.dragging) {
      document.addEventListener("contextmenu", this[onContextMenuWhileDragging], true);
      document.addEventListener("mousemove", this[onMouseMove]);
    }
  }
  [onDistanceChange](event) {
    const {
      pageX,
      pageY
    } = event;
    const {
      distance: distance$1
    } = this.options;
    const {
      startEvent,
      delay
    } = this;
    Object.assign(this, {
      pageX,
      pageY
    });
    if (!this.currentContainer) {
      return;
    }
    const timeElapsed = Date.now() - this.onMouseDownAt;
    const distanceTravelled = distance(startEvent.pageX, startEvent.pageY, pageX, pageY) || 0;
    clearTimeout(this.mouseDownTimeout);
    if (timeElapsed < delay.mouse) {
      document.removeEventListener("mousemove", this[onDistanceChange]);
    } else if (distanceTravelled >= distance$1) {
      document.removeEventListener("mousemove", this[onDistanceChange]);
      this[startDrag]();
    }
  }
  [onMouseMove](event) {
    if (!this.dragging) {
      return;
    }
    const target = document.elementFromPoint(event.clientX, event.clientY);
    const dragMoveEvent = new DragMoveSensorEvent({
      clientX: event.clientX,
      clientY: event.clientY,
      target,
      container: this.currentContainer,
      originalEvent: event
    });
    this.trigger(this.currentContainer, dragMoveEvent);
  }
  [onMouseUp](event) {
    clearTimeout(this.mouseDownTimeout);
    if (event.button !== 0) {
      return;
    }
    document.removeEventListener("mouseup", this[onMouseUp]);
    document.removeEventListener("dragstart", preventNativeDragStart);
    document.removeEventListener("mousemove", this[onDistanceChange]);
    if (!this.dragging) {
      return;
    }
    const target = document.elementFromPoint(event.clientX, event.clientY);
    const dragStopEvent = new DragStopSensorEvent({
      clientX: event.clientX,
      clientY: event.clientY,
      target,
      container: this.currentContainer,
      originalEvent: event
    });
    this.trigger(this.currentContainer, dragStopEvent);
    document.removeEventListener("contextmenu", this[onContextMenuWhileDragging], true);
    document.removeEventListener("mousemove", this[onMouseMove]);
    this.currentContainer = null;
    this.dragging = false;
    this.startEvent = null;
  }
  [onContextMenuWhileDragging](event) {
    event.preventDefault();
  }
};
function preventNativeDragStart(event) {
  event.preventDefault();
}

// ../node_modules/@shopify/draggable/build/esm/shared/utils/touchCoords/touchCoords.mjs
function touchCoords(event) {
  const {
    touches,
    changedTouches
  } = event;
  return touches && touches[0] || changedTouches && changedTouches[0];
}

// ../node_modules/@shopify/draggable/build/esm/Draggable/Sensors/TouchSensor/TouchSensor.mjs
var onTouchStart = Symbol("onTouchStart");
var onTouchEnd = Symbol("onTouchEnd");
var onTouchMove = Symbol("onTouchMove");
var startDrag2 = Symbol("startDrag");
var onDistanceChange2 = Symbol("onDistanceChange");
var preventScrolling = false;
window.addEventListener("touchmove", (event) => {
  if (!preventScrolling) {
    return;
  }
  event.preventDefault();
}, {
  passive: false
});
var TouchSensor = class extends Sensor {
  constructor(containers = [], options = {}) {
    super(containers, options);
    this.currentScrollableParent = null;
    this.tapTimeout = null;
    this.touchMoved = false;
    this.pageX = null;
    this.pageY = null;
    this[onTouchStart] = this[onTouchStart].bind(this);
    this[onTouchEnd] = this[onTouchEnd].bind(this);
    this[onTouchMove] = this[onTouchMove].bind(this);
    this[startDrag2] = this[startDrag2].bind(this);
    this[onDistanceChange2] = this[onDistanceChange2].bind(this);
  }
  attach() {
    document.addEventListener("touchstart", this[onTouchStart]);
  }
  detach() {
    document.removeEventListener("touchstart", this[onTouchStart]);
  }
  [onTouchStart](event) {
    const container = closest(event.target, this.containers);
    if (!container) {
      return;
    }
    if (this.options.handle && event.target && !closest(event.target, this.options.handle)) {
      return;
    }
    const originalSource = closest(event.target, this.options.draggable);
    if (!originalSource) {
      return;
    }
    const {
      distance: distance2 = 0
    } = this.options;
    const {
      delay
    } = this;
    const {
      pageX,
      pageY
    } = touchCoords(event);
    Object.assign(this, {
      pageX,
      pageY
    });
    this.onTouchStartAt = Date.now();
    this.startEvent = event;
    this.currentContainer = container;
    this.originalSource = originalSource;
    document.addEventListener("touchend", this[onTouchEnd]);
    document.addEventListener("touchcancel", this[onTouchEnd]);
    document.addEventListener("touchmove", this[onDistanceChange2]);
    container.addEventListener("contextmenu", onContextMenu);
    if (distance2) {
      preventScrolling = true;
    }
    this.tapTimeout = window.setTimeout(() => {
      this[onDistanceChange2]({
        touches: [{
          pageX: this.pageX,
          pageY: this.pageY
        }]
      });
    }, delay.touch);
  }
  [startDrag2]() {
    const startEvent = this.startEvent;
    const container = this.currentContainer;
    const touch = touchCoords(startEvent);
    const originalSource = this.originalSource;
    const dragStartEvent = new DragStartSensorEvent({
      clientX: touch.pageX,
      clientY: touch.pageY,
      target: startEvent.target,
      container,
      originalSource,
      originalEvent: startEvent
    });
    this.trigger(this.currentContainer, dragStartEvent);
    this.dragging = !dragStartEvent.canceled();
    if (this.dragging) {
      document.addEventListener("touchmove", this[onTouchMove]);
    }
    preventScrolling = this.dragging;
  }
  [onDistanceChange2](event) {
    const {
      distance: distance$1
    } = this.options;
    const {
      startEvent,
      delay
    } = this;
    const start = touchCoords(startEvent);
    const current = touchCoords(event);
    const timeElapsed = Date.now() - this.onTouchStartAt;
    const distanceTravelled = distance(start.pageX, start.pageY, current.pageX, current.pageY);
    Object.assign(this, current);
    clearTimeout(this.tapTimeout);
    if (timeElapsed < delay.touch) {
      document.removeEventListener("touchmove", this[onDistanceChange2]);
    } else if (distanceTravelled >= distance$1) {
      document.removeEventListener("touchmove", this[onDistanceChange2]);
      this[startDrag2]();
    }
  }
  [onTouchMove](event) {
    if (!this.dragging) {
      return;
    }
    const {
      pageX,
      pageY
    } = touchCoords(event);
    const target = document.elementFromPoint(pageX - window.scrollX, pageY - window.scrollY);
    const dragMoveEvent = new DragMoveSensorEvent({
      clientX: pageX,
      clientY: pageY,
      target,
      container: this.currentContainer,
      originalEvent: event
    });
    this.trigger(this.currentContainer, dragMoveEvent);
  }
  [onTouchEnd](event) {
    clearTimeout(this.tapTimeout);
    preventScrolling = false;
    document.removeEventListener("touchend", this[onTouchEnd]);
    document.removeEventListener("touchcancel", this[onTouchEnd]);
    document.removeEventListener("touchmove", this[onDistanceChange2]);
    if (this.currentContainer) {
      this.currentContainer.removeEventListener("contextmenu", onContextMenu);
    }
    if (!this.dragging) {
      return;
    }
    document.removeEventListener("touchmove", this[onTouchMove]);
    const {
      pageX,
      pageY
    } = touchCoords(event);
    const target = document.elementFromPoint(pageX - window.scrollX, pageY - window.scrollY);
    event.preventDefault();
    const dragStopEvent = new DragStopSensorEvent({
      clientX: pageX,
      clientY: pageY,
      target,
      container: this.currentContainer,
      originalEvent: event
    });
    this.trigger(this.currentContainer, dragStopEvent);
    this.currentContainer = null;
    this.dragging = false;
    this.startEvent = null;
  }
};
function onContextMenu(event) {
  event.preventDefault();
  event.stopPropagation();
}

// ../node_modules/@shopify/draggable/build/esm/Draggable/Sensors/DragSensor/DragSensor.mjs
var onMouseDown2 = Symbol("onMouseDown");
var onMouseUp2 = Symbol("onMouseUp");
var onDragStart = Symbol("onDragStart");
var onDragOver = Symbol("onDragOver");
var onDragEnd = Symbol("onDragEnd");
var onDrop = Symbol("onDrop");
var reset = Symbol("reset");

// ../node_modules/@shopify/draggable/build/esm/Draggable/Sensors/ForceTouchSensor/ForceTouchSensor.mjs
var onMouseForceWillBegin = Symbol("onMouseForceWillBegin");
var onMouseForceDown = Symbol("onMouseForceDown");
var onMouseDown3 = Symbol("onMouseDown");
var onMouseForceChange = Symbol("onMouseForceChange");
var onMouseMove2 = Symbol("onMouseMove");
var onMouseUp3 = Symbol("onMouseUp");
var onMouseForceGlobalChange = Symbol("onMouseForceGlobalChange");

// ../node_modules/@shopify/draggable/build/esm/Plugins/Collidable/CollidableEvent/CollidableEvent.mjs
var CollidableEvent = class extends AbstractEvent {
  constructor(data) {
    super(data);
    this.data = data;
  }
  get dragEvent() {
    return this.data.dragEvent;
  }
};
CollidableEvent.type = "collidable";
var CollidableInEvent = class extends CollidableEvent {
  get collidingElement() {
    return this.data.collidingElement;
  }
};
CollidableInEvent.type = "collidable:in";
var CollidableOutEvent = class extends CollidableEvent {
  get collidingElement() {
    return this.data.collidingElement;
  }
};
CollidableOutEvent.type = "collidable:out";

// ../node_modules/@shopify/draggable/build/esm/Plugins/Collidable/Collidable.mjs
var onDragMove = Symbol("onDragMove");
var onDragStop = Symbol("onDragStop");
var onRequestAnimationFrame = Symbol("onRequestAnimationFrame");

// ../node_modules/@shopify/draggable/build/esm/_virtual/_rollupPluginBabelHelpers.mjs
function createAddInitializerMethod(e, t) {
  return function(r) {
    assertNotFinished(t, "addInitializer"), assertCallable(r, "An initializer"), e.push(r);
  };
}
function assertInstanceIfPrivate(e, t) {
  if (!e(t))
    throw new TypeError("Attempted to access private element on non-instance");
}
function memberDec(e, t, r, a, n, i, s, o, c, l, u) {
  var f;
  switch (i) {
    case 1:
      f = "accessor";
      break;
    case 2:
      f = "method";
      break;
    case 3:
      f = "getter";
      break;
    case 4:
      f = "setter";
      break;
    default:
      f = "field";
  }
  var d, p, h = {
    kind: f,
    name: o ? "#" + r : r,
    static: s,
    private: o,
    metadata: u
  }, v = {
    v: false
  };
  if (i !== 0 && (h.addInitializer = createAddInitializerMethod(n, v)), o || i !== 0 && i !== 2) {
    if (i === 2)
      d = function(e2) {
        return assertInstanceIfPrivate(l, e2), a.value;
      };
    else {
      var y = i === 0 || i === 1;
      (y || i === 3) && (d = o ? function(e2) {
        return assertInstanceIfPrivate(l, e2), a.get.call(e2);
      } : function(e2) {
        return a.get.call(e2);
      }), (y || i === 4) && (p = o ? function(e2, t2) {
        assertInstanceIfPrivate(l, e2), a.set.call(e2, t2);
      } : function(e2, t2) {
        a.set.call(e2, t2);
      });
    }
  } else
    d = function(e2) {
      return e2[r];
    }, i === 0 && (p = function(e2, t2) {
      e2[r] = t2;
    });
  var m = o ? l.bind() : function(e2) {
    return r in e2;
  };
  h.access = d && p ? {
    get: d,
    set: p,
    has: m
  } : d ? {
    get: d,
    has: m
  } : {
    set: p,
    has: m
  };
  try {
    return e.call(t, c, h);
  } finally {
    v.v = true;
  }
}
function assertNotFinished(e, t) {
  if (e.v)
    throw new Error("attempted to call " + t + " after decoration was finished");
}
function assertCallable(e, t) {
  if (typeof e != "function")
    throw new TypeError(t + " must be a function");
}
function assertValidReturnValue(e, t) {
  var r = typeof t;
  if (e === 1) {
    if (r !== "object" || t === null)
      throw new TypeError("accessor decorators must return an object with get, set, or init properties or void 0");
    t.get !== void 0 && assertCallable(t.get, "accessor.get"), t.set !== void 0 && assertCallable(t.set, "accessor.set"), t.init !== void 0 && assertCallable(t.init, "accessor.init");
  } else if (r !== "function") {
    var a;
    throw a = e === 0 ? "field" : e === 5 ? "class" : "method", new TypeError(a + " decorators must return a function or void 0");
  }
}
function curryThis1(e) {
  return function() {
    return e(this);
  };
}
function curryThis2(e) {
  return function(t) {
    e(this, t);
  };
}
function applyMemberDec(e, t, r, a, n, i, s, o, c, l, u) {
  var f, d, p, h, v, y, m = r[0];
  a || Array.isArray(m) || (m = [m]), o ? f = i === 0 || i === 1 ? {
    get: curryThis1(r[3]),
    set: curryThis2(r[4])
  } : i === 3 ? {
    get: r[3]
  } : i === 4 ? {
    set: r[3]
  } : {
    value: r[3]
  } : i !== 0 && (f = Object.getOwnPropertyDescriptor(t, n)), i === 1 ? p = {
    get: f.get,
    set: f.set
  } : i === 2 ? p = f.value : i === 3 ? p = f.get : i === 4 && (p = f.set);
  for (var g = a ? 2 : 1, b = m.length - 1; b >= 0; b -= g) {
    var I;
    if ((h = memberDec(m[b], a ? m[b - 1] : void 0, n, f, c, i, s, o, p, l, u)) !== void 0)
      assertValidReturnValue(i, h), i === 0 ? I = h : i === 1 ? (I = h.init, v = h.get || p.get, y = h.set || p.set, p = {
        get: v,
        set: y
      }) : p = h, I !== void 0 && (d === void 0 ? d = I : typeof d == "function" ? d = [d, I] : d.push(I));
  }
  if (i === 0 || i === 1) {
    if (d === void 0)
      d = function(e2, t2) {
        return t2;
      };
    else if (typeof d != "function") {
      var w = d;
      d = function(e2, t2) {
        for (var r2 = t2, a2 = w.length - 1; a2 >= 0; a2--)
          r2 = w[a2].call(e2, r2);
        return r2;
      };
    } else {
      var M = d;
      d = function(e2, t2) {
        return M.call(e2, t2);
      };
    }
    e.push(d);
  }
  i !== 0 && (i === 1 ? (f.get = p.get, f.set = p.set) : i === 2 ? f.value = p : i === 3 ? f.get = p : i === 4 && (f.set = p), o ? i === 1 ? (e.push(function(e2, t2) {
    return p.get.call(e2, t2);
  }), e.push(function(e2, t2) {
    return p.set.call(e2, t2);
  })) : i === 2 ? e.push(p) : e.push(function(e2, t2) {
    return p.call(e2, t2);
  }) : Object.defineProperty(t, n, f));
}
function applyMemberDecs(e, t, r, a) {
  for (var n, i, s, o = [], c = new Map(), l = new Map(), u = 0; u < t.length; u++) {
    var f = t[u];
    if (Array.isArray(f)) {
      var d, p, h = f[1], v = f[2], y = f.length > 3, m = 16 & h, g = !!(8 & h), b = r;
      if (h &= 7, g ? (d = e, h !== 0 && (p = i = i || []), y && !s && (s = function(t2) {
        return _checkInRHS(t2) === e;
      }), b = s) : (d = e.prototype, h !== 0 && (p = n = n || [])), h !== 0 && !y) {
        var I = g ? l : c, w = I.get(v) || 0;
        if (w === true || w === 3 && h !== 4 || w === 4 && h !== 3)
          throw new Error("Attempted to decorate a public method/accessor that has the same name as a previously decorated public method/accessor. This is not currently supported by the decorators plugin. Property name was: " + v);
        I.set(v, !(!w && h > 2) || h);
      }
      applyMemberDec(o, d, f, m, v, h, g, y, p, b, a);
    }
  }
  return pushInitializers(o, n), pushInitializers(o, i), o;
}
function pushInitializers(e, t) {
  t && e.push(function(e2) {
    for (var r = 0; r < t.length; r++)
      t[r].call(e2);
    return e2;
  });
}
function applyClassDecs(e, t, r, a) {
  if (t.length) {
    for (var n = [], i = e, s = e.name, o = r ? 2 : 1, c = t.length - 1; c >= 0; c -= o) {
      var l = {
        v: false
      };
      try {
        var u = t[c].call(r ? t[c - 1] : void 0, i, {
          kind: "class",
          name: s,
          addInitializer: createAddInitializerMethod(n, l),
          metadata: a
        });
      } finally {
        l.v = true;
      }
      u !== void 0 && (assertValidReturnValue(5, u), i = u);
    }
    return [defineMetadata(i, a), function() {
      for (var e2 = 0; e2 < n.length; e2++)
        n[e2].call(i);
    }];
  }
}
function defineMetadata(e, t) {
  return Object.defineProperty(e, Symbol.metadata || Symbol.for("Symbol.metadata"), {
    configurable: true,
    enumerable: true,
    value: t
  });
}
function _applyDecs2305(e, t, r, a, n, i) {
  if (arguments.length >= 6)
    var s = i[Symbol.metadata || Symbol.for("Symbol.metadata")];
  var o = Object.create(s === void 0 ? null : s), c = applyMemberDecs(e, t, n, o);
  return r.length || defineMetadata(e, o), {
    e: c,
    get c() {
      return applyClassDecs(e, r, a, o);
    }
  };
}
function _checkInRHS(e) {
  if (Object(e) !== e)
    throw TypeError("right-hand side of 'in' should be an object, got " + (e !== null ? typeof e : "null"));
  return e;
}

// ../node_modules/@shopify/draggable/build/esm/shared/utils/decorators/AutoBind.mjs
function AutoBind(originalMethod, {
  name,
  addInitializer
}) {
  addInitializer(function() {
    this[name] = originalMethod.bind(this);
  });
}

// ../node_modules/@shopify/draggable/build/esm/shared/utils/requestNextAnimationFrame/requestNextAnimationFrame.mjs
function requestNextAnimationFrame(callback) {
  return requestAnimationFrame(() => {
    requestAnimationFrame(callback);
  });
}

// ../node_modules/@shopify/draggable/build/esm/Draggable/DragEvent/DragEvent.mjs
var DragEvent = class extends AbstractEvent {
  constructor(data) {
    super(data);
    this.data = data;
  }
  get source() {
    return this.data.source;
  }
  get originalSource() {
    return this.data.originalSource;
  }
  get mirror() {
    return this.data.mirror;
  }
  get sourceContainer() {
    return this.data.sourceContainer;
  }
  get sensorEvent() {
    return this.data.sensorEvent;
  }
  get originalEvent() {
    if (this.sensorEvent) {
      return this.sensorEvent.originalEvent;
    }
    return null;
  }
};
DragEvent.type = "drag";
var DragStartEvent = class extends DragEvent {
};
DragStartEvent.type = "drag:start";
DragStartEvent.cancelable = true;
var DragMoveEvent = class extends DragEvent {
};
DragMoveEvent.type = "drag:move";
var DragOverEvent = class extends DragEvent {
  get overContainer() {
    return this.data.overContainer;
  }
  get over() {
    return this.data.over;
  }
};
DragOverEvent.type = "drag:over";
DragOverEvent.cancelable = true;
function isDragOverEvent(event) {
  return event.type === DragOverEvent.type;
}
var DragOutEvent = class extends DragEvent {
  get overContainer() {
    return this.data.overContainer;
  }
  get over() {
    return this.data.over;
  }
};
DragOutEvent.type = "drag:out";
var DragOverContainerEvent = class extends DragEvent {
  get overContainer() {
    return this.data.overContainer;
  }
};
DragOverContainerEvent.type = "drag:over:container";
var DragOutContainerEvent = class extends DragEvent {
  get overContainer() {
    return this.data.overContainer;
  }
};
DragOutContainerEvent.type = "drag:out:container";
var DragPressureEvent = class extends DragEvent {
  get pressure() {
    return this.data.pressure;
  }
};
DragPressureEvent.type = "drag:pressure";
var DragStopEvent = class extends DragEvent {
};
DragStopEvent.type = "drag:stop";
DragStopEvent.cancelable = true;
var DragStoppedEvent = class extends DragEvent {
};
DragStoppedEvent.type = "drag:stopped";

// ../node_modules/@shopify/draggable/build/esm/Plugins/ResizeMirror/ResizeMirror.mjs
var _initProto;
var _class;
var ResizeMirror = class extends AbstractPlugin {
  constructor(draggable) {
    _initProto(super(draggable));
    this.lastWidth = 0;
    this.lastHeight = 0;
    this.mirror = null;
  }
  attach() {
    this.draggable.on("mirror:created", this.onMirrorCreated).on("drag:over", this.onDragOver).on("drag:over:container", this.onDragOver);
  }
  detach() {
    this.draggable.off("mirror:created", this.onMirrorCreated).off("mirror:destroy", this.onMirrorDestroy).off("drag:over", this.onDragOver).off("drag:over:container", this.onDragOver);
  }
  getOptions() {
    return this.draggable.options.resizeMirror || {};
  }
  onMirrorCreated({
    mirror
  }) {
    this.mirror = mirror;
  }
  onMirrorDestroy() {
    this.mirror = null;
  }
  onDragOver(dragEvent) {
    this.resize(dragEvent);
  }
  resize(dragEvent) {
    requestAnimationFrame(() => {
      let over = null;
      const {
        overContainer
      } = dragEvent;
      if (this.mirror == null || this.mirror.parentNode == null) {
        return;
      }
      if (this.mirror.parentNode !== overContainer) {
        overContainer.appendChild(this.mirror);
      }
      if (isDragOverEvent(dragEvent)) {
        over = dragEvent.over;
      }
      const overElement = over || this.draggable.getDraggableElementsForContainer(overContainer)[0];
      if (!overElement) {
        return;
      }
      requestNextAnimationFrame(() => {
        const overRect = overElement.getBoundingClientRect();
        if (this.mirror == null || this.lastHeight === overRect.height && this.lastWidth === overRect.width) {
          return;
        }
        this.mirror.style.width = `${overRect.width}px`;
        this.mirror.style.height = `${overRect.height}px`;
        this.lastWidth = overRect.width;
        this.lastHeight = overRect.height;
      });
    });
  }
};
_class = ResizeMirror;
[_initProto] = _applyDecs2305(_class, [[AutoBind, 2, "onMirrorCreated"], [AutoBind, 2, "onMirrorDestroy"], [AutoBind, 2, "onDragOver"]], [], 0, void 0, AbstractPlugin).e;

// ../node_modules/@shopify/draggable/build/esm/Plugins/Snappable/SnappableEvent/SnappableEvent.mjs
var SnapEvent = class extends AbstractEvent {
  get dragEvent() {
    return this.data.dragEvent;
  }
  get snappable() {
    return this.data.snappable;
  }
};
SnapEvent.type = "snap";
var SnapInEvent = class extends SnapEvent {
};
SnapInEvent.type = "snap:in";
SnapInEvent.cancelable = true;
var SnapOutEvent = class extends SnapEvent {
};
SnapOutEvent.type = "snap:out";
SnapOutEvent.cancelable = true;

// ../node_modules/@shopify/draggable/build/esm/Plugins/Snappable/Snappable.mjs
var onDragStart2 = Symbol("onDragStart");
var onDragStop2 = Symbol("onDragStop");
var onDragOver2 = Symbol("onDragOver");
var onDragOut = Symbol("onDragOut");
var onMirrorCreated = Symbol("onMirrorCreated");
var onMirrorDestroy = Symbol("onMirrorDestroy");

// ../node_modules/@shopify/draggable/build/esm/Plugins/SwapAnimation/SwapAnimation.mjs
var _initProto2;
var _class2;
var defaultOptions = {
  duration: 150,
  easingFunction: "ease-in-out",
  horizontal: false
};
var SwapAnimation = class extends AbstractPlugin {
  constructor(draggable) {
    _initProto2(super(draggable));
    this.options = {
      ...defaultOptions,
      ...this.getOptions()
    };
    this.lastAnimationFrame = null;
  }
  attach() {
    this.draggable.on("sortable:sorted", this.onSortableSorted);
  }
  detach() {
    this.draggable.off("sortable:sorted", this.onSortableSorted);
  }
  getOptions() {
    return this.draggable.options.swapAnimation || {};
  }
  onSortableSorted({
    oldIndex,
    newIndex,
    dragEvent
  }) {
    const {
      source,
      over
    } = dragEvent;
    if (this.lastAnimationFrame) {
      cancelAnimationFrame(this.lastAnimationFrame);
    }
    this.lastAnimationFrame = requestAnimationFrame(() => {
      if (oldIndex >= newIndex) {
        animate(source, over, this.options);
      } else {
        animate(over, source, this.options);
      }
    });
  }
};
_class2 = SwapAnimation;
[_initProto2] = _applyDecs2305(_class2, [[AutoBind, 2, "onSortableSorted"]], [], 0, void 0, AbstractPlugin).e;
function animate(from, to, {
  duration,
  easingFunction,
  horizontal
}) {
  for (const element of [from, to]) {
    element.style.pointerEvents = "none";
  }
  if (horizontal) {
    const width = from.offsetWidth;
    from.style.transform = `translate3d(${width}px, 0, 0)`;
    to.style.transform = `translate3d(-${width}px, 0, 0)`;
  } else {
    const height = from.offsetHeight;
    from.style.transform = `translate3d(0, ${height}px, 0)`;
    to.style.transform = `translate3d(0, -${height}px, 0)`;
  }
  requestAnimationFrame(() => {
    for (const element of [from, to]) {
      element.addEventListener("transitionend", resetElementOnTransitionEnd);
      element.style.transition = `transform ${duration}ms ${easingFunction}`;
      element.style.transform = "";
    }
  });
}
function resetElementOnTransitionEnd(event) {
  if (event.target == null || !isHTMLElement(event.target)) {
    return;
  }
  event.target.style.transition = "";
  event.target.style.pointerEvents = "";
  event.target.removeEventListener("transitionend", resetElementOnTransitionEnd);
}
function isHTMLElement(eventTarget) {
  return Boolean("style" in eventTarget);
}

// ../node_modules/@shopify/draggable/build/esm/Plugins/SortAnimation/SortAnimation.mjs
var onSortableSorted = Symbol("onSortableSorted");
var onSortableSort = Symbol("onSortableSort");

// ../node_modules/@shopify/draggable/build/esm/Draggable/Plugins/Announcement/Announcement.mjs
var onInitialize = Symbol("onInitialize");
var onDestroy = Symbol("onDestroy");
var announceEvent = Symbol("announceEvent");
var announceMessage = Symbol("announceMessage");
var ARIA_RELEVANT = "aria-relevant";
var ARIA_ATOMIC = "aria-atomic";
var ARIA_LIVE = "aria-live";
var ROLE = "role";
var defaultOptions4 = {
  expire: 7e3
};
var Announcement = class extends AbstractPlugin {
  constructor(draggable) {
    super(draggable);
    this.options = {
      ...defaultOptions4,
      ...this.getOptions()
    };
    this.originalTriggerMethod = this.draggable.trigger;
    this[onInitialize] = this[onInitialize].bind(this);
    this[onDestroy] = this[onDestroy].bind(this);
  }
  attach() {
    this.draggable.on("draggable:initialize", this[onInitialize]);
  }
  detach() {
    this.draggable.off("draggable:destroy", this[onDestroy]);
  }
  getOptions() {
    return this.draggable.options.announcements || {};
  }
  [announceEvent](event) {
    const message = this.options[event.type];
    if (message && typeof message === "string") {
      this[announceMessage](message);
    }
    if (message && typeof message === "function") {
      this[announceMessage](message(event));
    }
  }
  [announceMessage](message) {
    announce(message, {
      expire: this.options.expire
    });
  }
  [onInitialize]() {
    this.draggable.trigger = (event) => {
      try {
        this[announceEvent](event);
      } finally {
        this.originalTriggerMethod.call(this.draggable, event);
      }
    };
  }
  [onDestroy]() {
    this.draggable.trigger = this.originalTriggerMethod;
  }
};
var liveRegion = createRegion();
function announce(message, {
  expire
}) {
  const element = document.createElement("div");
  element.textContent = message;
  liveRegion.appendChild(element);
  return setTimeout(() => {
    liveRegion.removeChild(element);
  }, expire);
}
function createRegion() {
  const element = document.createElement("div");
  element.setAttribute("id", "draggable-live-region");
  element.setAttribute(ARIA_RELEVANT, "additions");
  element.setAttribute(ARIA_ATOMIC, "true");
  element.setAttribute(ARIA_LIVE, "assertive");
  element.setAttribute(ROLE, "log");
  element.style.position = "fixed";
  element.style.width = "1px";
  element.style.height = "1px";
  element.style.top = "-1px";
  element.style.overflow = "hidden";
  return element;
}
document.addEventListener("DOMContentLoaded", () => {
  document.body.appendChild(liveRegion);
});

// ../node_modules/@shopify/draggable/build/esm/Draggable/Plugins/Focusable/Focusable.mjs
var onInitialize2 = Symbol("onInitialize");
var onDestroy2 = Symbol("onDestroy");
var defaultOptions5 = {};
var Focusable = class extends AbstractPlugin {
  constructor(draggable) {
    super(draggable);
    this.options = {
      ...defaultOptions5,
      ...this.getOptions()
    };
    this[onInitialize2] = this[onInitialize2].bind(this);
    this[onDestroy2] = this[onDestroy2].bind(this);
  }
  attach() {
    this.draggable.on("draggable:initialize", this[onInitialize2]).on("draggable:destroy", this[onDestroy2]);
  }
  detach() {
    this.draggable.off("draggable:initialize", this[onInitialize2]).off("draggable:destroy", this[onDestroy2]);
    this[onDestroy2]();
  }
  getOptions() {
    return this.draggable.options.focusable || {};
  }
  getElements() {
    return [...this.draggable.containers, ...this.draggable.getDraggableElements()];
  }
  [onInitialize2]() {
    requestAnimationFrame(() => {
      this.getElements().forEach((element) => decorateElement(element));
    });
  }
  [onDestroy2]() {
    requestAnimationFrame(() => {
      this.getElements().forEach((element) => stripElement(element));
    });
  }
};
var elementsWithMissingTabIndex = [];
function decorateElement(element) {
  const hasMissingTabIndex = Boolean(!element.getAttribute("tabindex") && element.tabIndex === -1);
  if (hasMissingTabIndex) {
    elementsWithMissingTabIndex.push(element);
    element.tabIndex = 0;
  }
}
function stripElement(element) {
  const tabIndexElementPosition = elementsWithMissingTabIndex.indexOf(element);
  if (tabIndexElementPosition !== -1) {
    element.tabIndex = -1;
    elementsWithMissingTabIndex.splice(tabIndexElementPosition, 1);
  }
}

// ../node_modules/@shopify/draggable/build/esm/Draggable/Plugins/Mirror/MirrorEvent/MirrorEvent.mjs
var MirrorEvent = class extends AbstractEvent {
  constructor(data) {
    super(data);
    this.data = data;
  }
  get source() {
    return this.data.source;
  }
  get originalSource() {
    return this.data.originalSource;
  }
  get sourceContainer() {
    return this.data.sourceContainer;
  }
  get sensorEvent() {
    return this.data.sensorEvent;
  }
  get dragEvent() {
    return this.data.dragEvent;
  }
  get originalEvent() {
    if (this.sensorEvent) {
      return this.sensorEvent.originalEvent;
    }
    return null;
  }
};
var MirrorCreateEvent = class extends MirrorEvent {
};
MirrorCreateEvent.type = "mirror:create";
var MirrorCreatedEvent = class extends MirrorEvent {
  get mirror() {
    return this.data.mirror;
  }
};
MirrorCreatedEvent.type = "mirror:created";
var MirrorAttachedEvent = class extends MirrorEvent {
  get mirror() {
    return this.data.mirror;
  }
};
MirrorAttachedEvent.type = "mirror:attached";
var MirrorMoveEvent = class extends MirrorEvent {
  get mirror() {
    return this.data.mirror;
  }
  get passedThreshX() {
    return this.data.passedThreshX;
  }
  get passedThreshY() {
    return this.data.passedThreshY;
  }
};
MirrorMoveEvent.type = "mirror:move";
MirrorMoveEvent.cancelable = true;
var MirrorMovedEvent = class extends MirrorEvent {
  get mirror() {
    return this.data.mirror;
  }
  get passedThreshX() {
    return this.data.passedThreshX;
  }
  get passedThreshY() {
    return this.data.passedThreshY;
  }
};
MirrorMovedEvent.type = "mirror:moved";
var MirrorDestroyEvent = class extends MirrorEvent {
  get mirror() {
    return this.data.mirror;
  }
};
MirrorDestroyEvent.type = "mirror:destroy";
MirrorDestroyEvent.cancelable = true;

// ../node_modules/@shopify/draggable/build/esm/Draggable/Plugins/Mirror/Mirror.mjs
var onDragStart3 = Symbol("onDragStart");
var onDragMove2 = Symbol("onDragMove");
var onDragStop3 = Symbol("onDragStop");
var onMirrorCreated2 = Symbol("onMirrorCreated");
var onMirrorMove = Symbol("onMirrorMove");
var onScroll = Symbol("onScroll");
var getAppendableContainer = Symbol("getAppendableContainer");
var defaultOptions6 = {
  constrainDimensions: false,
  xAxis: true,
  yAxis: true,
  cursorOffsetX: null,
  cursorOffsetY: null,
  thresholdX: null,
  thresholdY: null
};
var Mirror = class extends AbstractPlugin {
  constructor(draggable) {
    super(draggable);
    this.options = {
      ...defaultOptions6,
      ...this.getOptions()
    };
    this.scrollOffset = {
      x: 0,
      y: 0
    };
    this.initialScrollOffset = {
      x: window.scrollX,
      y: window.scrollY
    };
    this[onDragStart3] = this[onDragStart3].bind(this);
    this[onDragMove2] = this[onDragMove2].bind(this);
    this[onDragStop3] = this[onDragStop3].bind(this);
    this[onMirrorCreated2] = this[onMirrorCreated2].bind(this);
    this[onMirrorMove] = this[onMirrorMove].bind(this);
    this[onScroll] = this[onScroll].bind(this);
  }
  attach() {
    this.draggable.on("drag:start", this[onDragStart3]).on("drag:move", this[onDragMove2]).on("drag:stop", this[onDragStop3]).on("mirror:created", this[onMirrorCreated2]).on("mirror:move", this[onMirrorMove]);
  }
  detach() {
    this.draggable.off("drag:start", this[onDragStart3]).off("drag:move", this[onDragMove2]).off("drag:stop", this[onDragStop3]).off("mirror:created", this[onMirrorCreated2]).off("mirror:move", this[onMirrorMove]);
  }
  getOptions() {
    return this.draggable.options.mirror || {};
  }
  [onDragStart3](dragEvent) {
    if (dragEvent.canceled()) {
      return;
    }
    if ("ontouchstart" in window) {
      document.addEventListener("scroll", this[onScroll], true);
    }
    this.initialScrollOffset = {
      x: window.scrollX,
      y: window.scrollY
    };
    const {
      source,
      originalSource,
      sourceContainer,
      sensorEvent
    } = dragEvent;
    this.lastMirrorMovedClient = {
      x: sensorEvent.clientX,
      y: sensorEvent.clientY
    };
    const mirrorCreateEvent = new MirrorCreateEvent({
      source,
      originalSource,
      sourceContainer,
      sensorEvent,
      dragEvent
    });
    this.draggable.trigger(mirrorCreateEvent);
    if (isNativeDragEvent(sensorEvent) || mirrorCreateEvent.canceled()) {
      return;
    }
    const appendableContainer = this[getAppendableContainer](source) || sourceContainer;
    this.mirror = source.cloneNode(true);
    const mirrorCreatedEvent = new MirrorCreatedEvent({
      source,
      originalSource,
      sourceContainer,
      sensorEvent,
      dragEvent,
      mirror: this.mirror
    });
    const mirrorAttachedEvent = new MirrorAttachedEvent({
      source,
      originalSource,
      sourceContainer,
      sensorEvent,
      dragEvent,
      mirror: this.mirror
    });
    this.draggable.trigger(mirrorCreatedEvent);
    appendableContainer.appendChild(this.mirror);
    this.draggable.trigger(mirrorAttachedEvent);
  }
  [onDragMove2](dragEvent) {
    if (!this.mirror || dragEvent.canceled()) {
      return;
    }
    const {
      source,
      originalSource,
      sourceContainer,
      sensorEvent
    } = dragEvent;
    let passedThreshX = true;
    let passedThreshY = true;
    if (this.options.thresholdX || this.options.thresholdY) {
      const {
        x: lastX,
        y: lastY
      } = this.lastMirrorMovedClient;
      if (Math.abs(lastX - sensorEvent.clientX) < this.options.thresholdX) {
        passedThreshX = false;
      } else {
        this.lastMirrorMovedClient.x = sensorEvent.clientX;
      }
      if (Math.abs(lastY - sensorEvent.clientY) < this.options.thresholdY) {
        passedThreshY = false;
      } else {
        this.lastMirrorMovedClient.y = sensorEvent.clientY;
      }
      if (!passedThreshX && !passedThreshY) {
        return;
      }
    }
    const mirrorMoveEvent = new MirrorMoveEvent({
      source,
      originalSource,
      sourceContainer,
      sensorEvent,
      dragEvent,
      mirror: this.mirror,
      passedThreshX,
      passedThreshY
    });
    this.draggable.trigger(mirrorMoveEvent);
  }
  [onDragStop3](dragEvent) {
    if ("ontouchstart" in window) {
      document.removeEventListener("scroll", this[onScroll], true);
    }
    this.initialScrollOffset = {
      x: 0,
      y: 0
    };
    this.scrollOffset = {
      x: 0,
      y: 0
    };
    if (!this.mirror) {
      return;
    }
    const {
      source,
      sourceContainer,
      sensorEvent
    } = dragEvent;
    const mirrorDestroyEvent = new MirrorDestroyEvent({
      source,
      mirror: this.mirror,
      sourceContainer,
      sensorEvent,
      dragEvent
    });
    this.draggable.trigger(mirrorDestroyEvent);
    if (!mirrorDestroyEvent.canceled()) {
      this.mirror.remove();
    }
  }
  [onScroll]() {
    this.scrollOffset = {
      x: window.scrollX - this.initialScrollOffset.x,
      y: window.scrollY - this.initialScrollOffset.y
    };
  }
  [onMirrorCreated2]({
    mirror,
    source,
    sensorEvent
  }) {
    const mirrorClasses = this.draggable.getClassNamesFor("mirror");
    const setState = ({
      mirrorOffset,
      initialX,
      initialY,
      ...args
    }) => {
      this.mirrorOffset = mirrorOffset;
      this.initialX = initialX;
      this.initialY = initialY;
      this.lastMovedX = initialX;
      this.lastMovedY = initialY;
      return {
        mirrorOffset,
        initialX,
        initialY,
        ...args
      };
    };
    mirror.style.display = "none";
    const initialState = {
      mirror,
      source,
      sensorEvent,
      mirrorClasses,
      scrollOffset: this.scrollOffset,
      options: this.options,
      passedThreshX: true,
      passedThreshY: true
    };
    return Promise.resolve(initialState).then(computeMirrorDimensions).then(calculateMirrorOffset).then(resetMirror).then(addMirrorClasses).then(positionMirror({
      initial: true
    })).then(removeMirrorID).then(setState);
  }
  [onMirrorMove](mirrorEvent) {
    if (mirrorEvent.canceled()) {
      return null;
    }
    const setState = ({
      lastMovedX,
      lastMovedY,
      ...args
    }) => {
      this.lastMovedX = lastMovedX;
      this.lastMovedY = lastMovedY;
      return {
        lastMovedX,
        lastMovedY,
        ...args
      };
    };
    const triggerMoved = (args) => {
      const mirrorMovedEvent = new MirrorMovedEvent({
        source: mirrorEvent.source,
        originalSource: mirrorEvent.originalSource,
        sourceContainer: mirrorEvent.sourceContainer,
        sensorEvent: mirrorEvent.sensorEvent,
        dragEvent: mirrorEvent.dragEvent,
        mirror: this.mirror,
        passedThreshX: mirrorEvent.passedThreshX,
        passedThreshY: mirrorEvent.passedThreshY
      });
      this.draggable.trigger(mirrorMovedEvent);
      return args;
    };
    const initialState = {
      mirror: mirrorEvent.mirror,
      sensorEvent: mirrorEvent.sensorEvent,
      mirrorOffset: this.mirrorOffset,
      options: this.options,
      initialX: this.initialX,
      initialY: this.initialY,
      scrollOffset: this.scrollOffset,
      passedThreshX: mirrorEvent.passedThreshX,
      passedThreshY: mirrorEvent.passedThreshY,
      lastMovedX: this.lastMovedX,
      lastMovedY: this.lastMovedY
    };
    return Promise.resolve(initialState).then(positionMirror({
      raf: true
    })).then(setState).then(triggerMoved);
  }
  [getAppendableContainer](source) {
    const appendTo = this.options.appendTo;
    if (typeof appendTo === "string") {
      return document.querySelector(appendTo);
    } else if (appendTo instanceof HTMLElement) {
      return appendTo;
    } else if (typeof appendTo === "function") {
      return appendTo(source);
    } else {
      return source.parentNode;
    }
  }
};
function computeMirrorDimensions({
  source,
  ...args
}) {
  return withPromise((resolve) => {
    const sourceRect = source.getBoundingClientRect();
    resolve({
      source,
      sourceRect,
      ...args
    });
  });
}
function calculateMirrorOffset({
  sensorEvent,
  sourceRect,
  options,
  ...args
}) {
  return withPromise((resolve) => {
    const top = options.cursorOffsetY === null ? sensorEvent.clientY - sourceRect.top : options.cursorOffsetY;
    const left = options.cursorOffsetX === null ? sensorEvent.clientX - sourceRect.left : options.cursorOffsetX;
    const mirrorOffset = {
      top,
      left
    };
    resolve({
      sensorEvent,
      sourceRect,
      mirrorOffset,
      options,
      ...args
    });
  });
}
function resetMirror({
  mirror,
  source,
  options,
  ...args
}) {
  return withPromise((resolve) => {
    let offsetHeight;
    let offsetWidth;
    if (options.constrainDimensions) {
      const computedSourceStyles = getComputedStyle(source);
      offsetHeight = computedSourceStyles.getPropertyValue("height");
      offsetWidth = computedSourceStyles.getPropertyValue("width");
    }
    mirror.style.display = null;
    mirror.style.position = "fixed";
    mirror.style.pointerEvents = "none";
    mirror.style.top = 0;
    mirror.style.left = 0;
    mirror.style.margin = 0;
    if (options.constrainDimensions) {
      mirror.style.height = offsetHeight;
      mirror.style.width = offsetWidth;
    }
    resolve({
      mirror,
      source,
      options,
      ...args
    });
  });
}
function addMirrorClasses({
  mirror,
  mirrorClasses,
  ...args
}) {
  return withPromise((resolve) => {
    mirror.classList.add(...mirrorClasses);
    resolve({
      mirror,
      mirrorClasses,
      ...args
    });
  });
}
function removeMirrorID({
  mirror,
  ...args
}) {
  return withPromise((resolve) => {
    mirror.removeAttribute("id");
    delete mirror.id;
    resolve({
      mirror,
      ...args
    });
  });
}
function positionMirror({
  withFrame = false,
  initial = false
} = {}) {
  return ({
    mirror,
    sensorEvent,
    mirrorOffset,
    initialY,
    initialX,
    scrollOffset,
    options,
    passedThreshX,
    passedThreshY,
    lastMovedX,
    lastMovedY,
    ...args
  }) => {
    return withPromise((resolve) => {
      const result = {
        mirror,
        sensorEvent,
        mirrorOffset,
        options,
        ...args
      };
      if (mirrorOffset) {
        const x = passedThreshX ? Math.round((sensorEvent.clientX - mirrorOffset.left - scrollOffset.x) / (options.thresholdX || 1)) * (options.thresholdX || 1) : Math.round(lastMovedX);
        const y = passedThreshY ? Math.round((sensorEvent.clientY - mirrorOffset.top - scrollOffset.y) / (options.thresholdY || 1)) * (options.thresholdY || 1) : Math.round(lastMovedY);
        if (options.xAxis && options.yAxis || initial) {
          mirror.style.transform = `translate3d(${x}px, ${y}px, 0)`;
        } else if (options.xAxis && !options.yAxis) {
          mirror.style.transform = `translate3d(${x}px, ${initialY}px, 0)`;
        } else if (options.yAxis && !options.xAxis) {
          mirror.style.transform = `translate3d(${initialX}px, ${y}px, 0)`;
        }
        if (initial) {
          result.initialX = x;
          result.initialY = y;
        }
        result.lastMovedX = x;
        result.lastMovedY = y;
      }
      resolve(result);
    }, {
      frame: withFrame
    });
  };
}
function withPromise(callback, {
  raf = false
} = {}) {
  return new Promise((resolve, reject) => {
    if (raf) {
      requestAnimationFrame(() => {
        callback(resolve, reject);
      });
    } else {
      callback(resolve, reject);
    }
  });
}
function isNativeDragEvent(sensorEvent) {
  return /^drag/.test(sensorEvent.originalEvent.type);
}

// ../node_modules/@shopify/draggable/build/esm/Draggable/Plugins/Scrollable/Scrollable.mjs
var onDragStart4 = Symbol("onDragStart");
var onDragMove3 = Symbol("onDragMove");
var onDragStop4 = Symbol("onDragStop");
var scroll = Symbol("scroll");
var defaultOptions7 = {
  speed: 6,
  sensitivity: 50,
  scrollableElements: []
};
var Scrollable = class extends AbstractPlugin {
  constructor(draggable) {
    super(draggable);
    this.options = {
      ...defaultOptions7,
      ...this.getOptions()
    };
    this.currentMousePosition = null;
    this.scrollAnimationFrame = null;
    this.scrollableElement = null;
    this.findScrollableElementFrame = null;
    this[onDragStart4] = this[onDragStart4].bind(this);
    this[onDragMove3] = this[onDragMove3].bind(this);
    this[onDragStop4] = this[onDragStop4].bind(this);
    this[scroll] = this[scroll].bind(this);
  }
  attach() {
    this.draggable.on("drag:start", this[onDragStart4]).on("drag:move", this[onDragMove3]).on("drag:stop", this[onDragStop4]);
  }
  detach() {
    this.draggable.off("drag:start", this[onDragStart4]).off("drag:move", this[onDragMove3]).off("drag:stop", this[onDragStop4]);
  }
  getOptions() {
    return this.draggable.options.scrollable || {};
  }
  getScrollableElement(target) {
    if (this.hasDefinedScrollableElements()) {
      return closest(target, this.options.scrollableElements) || document.documentElement;
    } else {
      return closestScrollableElement(target);
    }
  }
  hasDefinedScrollableElements() {
    return Boolean(this.options.scrollableElements.length !== 0);
  }
  [onDragStart4](dragEvent) {
    this.findScrollableElementFrame = requestAnimationFrame(() => {
      this.scrollableElement = this.getScrollableElement(dragEvent.source);
    });
  }
  [onDragMove3](dragEvent) {
    this.findScrollableElementFrame = requestAnimationFrame(() => {
      this.scrollableElement = this.getScrollableElement(dragEvent.sensorEvent.target);
    });
    if (!this.scrollableElement) {
      return;
    }
    const sensorEvent = dragEvent.sensorEvent;
    const scrollOffset = {
      x: 0,
      y: 0
    };
    if ("ontouchstart" in window) {
      scrollOffset.y = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0;
      scrollOffset.x = window.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft || 0;
    }
    this.currentMousePosition = {
      clientX: sensorEvent.clientX - scrollOffset.x,
      clientY: sensorEvent.clientY - scrollOffset.y
    };
    this.scrollAnimationFrame = requestAnimationFrame(this[scroll]);
  }
  [onDragStop4]() {
    cancelAnimationFrame(this.scrollAnimationFrame);
    cancelAnimationFrame(this.findScrollableElementFrame);
    this.scrollableElement = null;
    this.scrollAnimationFrame = null;
    this.findScrollableElementFrame = null;
    this.currentMousePosition = null;
  }
  [scroll]() {
    if (!this.scrollableElement || !this.currentMousePosition) {
      return;
    }
    cancelAnimationFrame(this.scrollAnimationFrame);
    const {
      speed,
      sensitivity
    } = this.options;
    const rect = this.scrollableElement.getBoundingClientRect();
    const bottomCutOff = rect.bottom > window.innerHeight;
    const topCutOff = rect.top < 0;
    const cutOff = topCutOff || bottomCutOff;
    const documentScrollingElement = getDocumentScrollingElement();
    const scrollableElement = this.scrollableElement;
    const clientX = this.currentMousePosition.clientX;
    const clientY = this.currentMousePosition.clientY;
    if (scrollableElement !== document.body && scrollableElement !== document.documentElement && !cutOff) {
      const {
        offsetHeight,
        offsetWidth
      } = scrollableElement;
      if (rect.top + offsetHeight - clientY < sensitivity) {
        scrollableElement.scrollTop += speed;
      } else if (clientY - rect.top < sensitivity) {
        scrollableElement.scrollTop -= speed;
      }
      if (rect.left + offsetWidth - clientX < sensitivity) {
        scrollableElement.scrollLeft += speed;
      } else if (clientX - rect.left < sensitivity) {
        scrollableElement.scrollLeft -= speed;
      }
    } else {
      const {
        innerHeight,
        innerWidth
      } = window;
      if (clientY < sensitivity) {
        documentScrollingElement.scrollTop -= speed;
      } else if (innerHeight - clientY < sensitivity) {
        documentScrollingElement.scrollTop += speed;
      }
      if (clientX < sensitivity) {
        documentScrollingElement.scrollLeft -= speed;
      } else if (innerWidth - clientX < sensitivity) {
        documentScrollingElement.scrollLeft += speed;
      }
    }
    this.scrollAnimationFrame = requestAnimationFrame(this[scroll]);
  }
};
function hasOverflow(element) {
  const overflowRegex = /(auto|scroll)/;
  const computedStyles = getComputedStyle(element, null);
  const overflow = computedStyles.getPropertyValue("overflow") + computedStyles.getPropertyValue("overflow-y") + computedStyles.getPropertyValue("overflow-x");
  return overflowRegex.test(overflow);
}
function isStaticallyPositioned(element) {
  const position = getComputedStyle(element).getPropertyValue("position");
  return position === "static";
}
function closestScrollableElement(element) {
  if (!element) {
    return getDocumentScrollingElement();
  }
  const position = getComputedStyle(element).getPropertyValue("position");
  const excludeStaticParents = position === "absolute";
  const scrollableElement = closest(element, (parent) => {
    if (excludeStaticParents && isStaticallyPositioned(parent)) {
      return false;
    }
    return hasOverflow(parent);
  });
  if (position === "fixed" || !scrollableElement) {
    return getDocumentScrollingElement();
  } else {
    return scrollableElement;
  }
}
function getDocumentScrollingElement() {
  return document.scrollingElement || document.documentElement;
}

// ../node_modules/@shopify/draggable/build/esm/Draggable/Emitter/Emitter.mjs
var Emitter = class {
  constructor() {
    this.callbacks = {};
  }
  on(type, ...callbacks) {
    if (!this.callbacks[type]) {
      this.callbacks[type] = [];
    }
    this.callbacks[type].push(...callbacks);
    return this;
  }
  off(type, callback) {
    if (!this.callbacks[type]) {
      return null;
    }
    const copy = this.callbacks[type].slice(0);
    for (let i = 0; i < copy.length; i++) {
      if (callback === copy[i]) {
        this.callbacks[type].splice(i, 1);
      }
    }
    return this;
  }
  trigger(event) {
    if (!this.callbacks[event.type]) {
      return null;
    }
    const callbacks = [...this.callbacks[event.type]];
    const caughtErrors = [];
    for (let i = callbacks.length - 1; i >= 0; i--) {
      const callback = callbacks[i];
      try {
        callback(event);
      } catch (error) {
        caughtErrors.push(error);
      }
    }
    if (caughtErrors.length) {
      console.error(`Draggable caught errors while triggering '${event.type}'`, caughtErrors);
    }
    return this;
  }
};

// ../node_modules/@shopify/draggable/build/esm/Draggable/DraggableEvent/DraggableEvent.mjs
var DraggableEvent = class extends AbstractEvent {
  get draggable() {
    return this.data.draggable;
  }
};
DraggableEvent.type = "draggable";
var DraggableInitializedEvent = class extends DraggableEvent {
};
DraggableInitializedEvent.type = "draggable:initialize";
var DraggableDestroyEvent = class extends DraggableEvent {
};
DraggableDestroyEvent.type = "draggable:destroy";

// ../node_modules/@shopify/draggable/build/esm/Draggable/Draggable.mjs
var onDragStart5 = Symbol("onDragStart");
var onDragMove4 = Symbol("onDragMove");
var onDragStop5 = Symbol("onDragStop");
var onDragPressure = Symbol("onDragPressure");
var dragStop = Symbol("dragStop");
var defaultAnnouncements = {
  "drag:start": (event) => `Picked up ${event.source.textContent.trim() || event.source.id || "draggable element"}`,
  "drag:stop": (event) => `Released ${event.source.textContent.trim() || event.source.id || "draggable element"}`
};
var defaultClasses = {
  "container:dragging": "draggable-container--is-dragging",
  "source:dragging": "draggable-source--is-dragging",
  "source:placed": "draggable-source--placed",
  "container:placed": "draggable-container--placed",
  "body:dragging": "draggable--is-dragging",
  "draggable:over": "draggable--over",
  "container:over": "draggable-container--over",
  "source:original": "draggable--original",
  mirror: "draggable-mirror"
};
var defaultOptions8 = {
  draggable: ".draggable-source",
  handle: null,
  delay: {},
  distance: 0,
  placedTimeout: 800,
  plugins: [],
  sensors: [],
  exclude: {
    plugins: [],
    sensors: []
  }
};
var Draggable = class {
  constructor(containers = [document.body], options = {}) {
    if (containers instanceof NodeList || containers instanceof Array) {
      this.containers = [...containers];
    } else if (containers instanceof HTMLElement) {
      this.containers = [containers];
    } else {
      throw new Error("Draggable containers are expected to be of type `NodeList`, `HTMLElement[]` or `HTMLElement`");
    }
    this.options = {
      ...defaultOptions8,
      ...options,
      classes: {
        ...defaultClasses,
        ...options.classes || {}
      },
      announcements: {
        ...defaultAnnouncements,
        ...options.announcements || {}
      },
      exclude: {
        plugins: options.exclude && options.exclude.plugins || [],
        sensors: options.exclude && options.exclude.sensors || []
      }
    };
    this.emitter = new Emitter();
    this.dragging = false;
    this.plugins = [];
    this.sensors = [];
    this[onDragStart5] = this[onDragStart5].bind(this);
    this[onDragMove4] = this[onDragMove4].bind(this);
    this[onDragStop5] = this[onDragStop5].bind(this);
    this[onDragPressure] = this[onDragPressure].bind(this);
    this[dragStop] = this[dragStop].bind(this);
    document.addEventListener("drag:start", this[onDragStart5], true);
    document.addEventListener("drag:move", this[onDragMove4], true);
    document.addEventListener("drag:stop", this[onDragStop5], true);
    document.addEventListener("drag:pressure", this[onDragPressure], true);
    const defaultPlugins = Object.values(Draggable.Plugins).filter((Plugin) => !this.options.exclude.plugins.includes(Plugin));
    const defaultSensors = Object.values(Draggable.Sensors).filter((sensor) => !this.options.exclude.sensors.includes(sensor));
    this.addPlugin(...[...defaultPlugins, ...this.options.plugins]);
    this.addSensor(...[...defaultSensors, ...this.options.sensors]);
    const draggableInitializedEvent = new DraggableInitializedEvent({
      draggable: this
    });
    this.on("mirror:created", ({
      mirror
    }) => this.mirror = mirror);
    this.on("mirror:destroy", () => this.mirror = null);
    this.trigger(draggableInitializedEvent);
  }
  destroy() {
    document.removeEventListener("drag:start", this[onDragStart5], true);
    document.removeEventListener("drag:move", this[onDragMove4], true);
    document.removeEventListener("drag:stop", this[onDragStop5], true);
    document.removeEventListener("drag:pressure", this[onDragPressure], true);
    const draggableDestroyEvent = new DraggableDestroyEvent({
      draggable: this
    });
    this.trigger(draggableDestroyEvent);
    this.removePlugin(...this.plugins.map((plugin) => plugin.constructor));
    this.removeSensor(...this.sensors.map((sensor) => sensor.constructor));
  }
  addPlugin(...plugins) {
    const activePlugins = plugins.map((Plugin) => new Plugin(this));
    activePlugins.forEach((plugin) => plugin.attach());
    this.plugins = [...this.plugins, ...activePlugins];
    return this;
  }
  removePlugin(...plugins) {
    const removedPlugins = this.plugins.filter((plugin) => plugins.includes(plugin.constructor));
    removedPlugins.forEach((plugin) => plugin.detach());
    this.plugins = this.plugins.filter((plugin) => !plugins.includes(plugin.constructor));
    return this;
  }
  addSensor(...sensors) {
    const activeSensors = sensors.map((Sensor2) => new Sensor2(this.containers, this.options));
    activeSensors.forEach((sensor) => sensor.attach());
    this.sensors = [...this.sensors, ...activeSensors];
    return this;
  }
  removeSensor(...sensors) {
    const removedSensors = this.sensors.filter((sensor) => sensors.includes(sensor.constructor));
    removedSensors.forEach((sensor) => sensor.detach());
    this.sensors = this.sensors.filter((sensor) => !sensors.includes(sensor.constructor));
    return this;
  }
  addContainer(...containers) {
    this.containers = [...this.containers, ...containers];
    this.sensors.forEach((sensor) => sensor.addContainer(...containers));
    return this;
  }
  removeContainer(...containers) {
    this.containers = this.containers.filter((container) => !containers.includes(container));
    this.sensors.forEach((sensor) => sensor.removeContainer(...containers));
    return this;
  }
  on(type, ...callbacks) {
    this.emitter.on(type, ...callbacks);
    return this;
  }
  off(type, callback) {
    this.emitter.off(type, callback);
    return this;
  }
  trigger(event) {
    this.emitter.trigger(event);
    return this;
  }
  getClassNameFor(name) {
    return this.getClassNamesFor(name)[0];
  }
  getClassNamesFor(name) {
    const classNames = this.options.classes[name];
    if (classNames instanceof Array) {
      return classNames;
    } else if (typeof classNames === "string" || classNames instanceof String) {
      return [classNames];
    } else {
      return [];
    }
  }
  isDragging() {
    return Boolean(this.dragging);
  }
  getDraggableElements() {
    return this.containers.reduce((current, container) => {
      return [...current, ...this.getDraggableElementsForContainer(container)];
    }, []);
  }
  getDraggableElementsForContainer(container) {
    const allDraggableElements = container.querySelectorAll(this.options.draggable);
    return [...allDraggableElements].filter((childElement) => {
      return childElement !== this.originalSource && childElement !== this.mirror;
    });
  }
  cancel() {
    this[dragStop]();
  }
  [onDragStart5](event) {
    const sensorEvent = getSensorEvent(event);
    const {
      target,
      container,
      originalSource
    } = sensorEvent;
    if (!this.containers.includes(container)) {
      return;
    }
    if (this.options.handle && target && !closest(target, this.options.handle)) {
      sensorEvent.cancel();
      return;
    }
    this.originalSource = originalSource;
    this.sourceContainer = container;
    if (this.lastPlacedSource && this.lastPlacedContainer) {
      clearTimeout(this.placedTimeoutID);
      this.lastPlacedSource.classList.remove(...this.getClassNamesFor("source:placed"));
      this.lastPlacedContainer.classList.remove(...this.getClassNamesFor("container:placed"));
    }
    this.source = this.originalSource.cloneNode(true);
    this.originalSource.parentNode.insertBefore(this.source, this.originalSource);
    this.originalSource.style.display = "none";
    const dragStartEvent = new DragStartEvent({
      source: this.source,
      originalSource: this.originalSource,
      sourceContainer: container,
      sensorEvent
    });
    this.trigger(dragStartEvent);
    this.dragging = !dragStartEvent.canceled();
    if (dragStartEvent.canceled()) {
      this.source.remove();
      this.originalSource.style.display = null;
      return;
    }
    this.originalSource.classList.add(...this.getClassNamesFor("source:original"));
    this.source.classList.add(...this.getClassNamesFor("source:dragging"));
    this.sourceContainer.classList.add(...this.getClassNamesFor("container:dragging"));
    document.body.classList.add(...this.getClassNamesFor("body:dragging"));
    applyUserSelect(document.body, "none");
    requestAnimationFrame(() => {
      const oldSensorEvent = getSensorEvent(event);
      const newSensorEvent = oldSensorEvent.clone({
        target: this.source
      });
      this[onDragMove4]({
        ...event,
        detail: newSensorEvent
      });
    });
  }
  [onDragMove4](event) {
    if (!this.dragging) {
      return;
    }
    const sensorEvent = getSensorEvent(event);
    const {
      container
    } = sensorEvent;
    let target = sensorEvent.target;
    const dragMoveEvent = new DragMoveEvent({
      source: this.source,
      originalSource: this.originalSource,
      sourceContainer: container,
      sensorEvent
    });
    this.trigger(dragMoveEvent);
    if (dragMoveEvent.canceled()) {
      sensorEvent.cancel();
    }
    target = closest(target, this.options.draggable);
    const withinCorrectContainer = closest(sensorEvent.target, this.containers);
    const overContainer = sensorEvent.overContainer || withinCorrectContainer;
    const isLeavingContainer = this.currentOverContainer && overContainer !== this.currentOverContainer;
    const isLeavingDraggable = this.currentOver && target !== this.currentOver;
    const isOverContainer = overContainer && this.currentOverContainer !== overContainer;
    const isOverDraggable = withinCorrectContainer && target && this.currentOver !== target;
    if (isLeavingDraggable) {
      const dragOutEvent = new DragOutEvent({
        source: this.source,
        originalSource: this.originalSource,
        sourceContainer: container,
        sensorEvent,
        over: this.currentOver,
        overContainer: this.currentOverContainer
      });
      this.currentOver.classList.remove(...this.getClassNamesFor("draggable:over"));
      this.currentOver = null;
      this.trigger(dragOutEvent);
    }
    if (isLeavingContainer) {
      const dragOutContainerEvent = new DragOutContainerEvent({
        source: this.source,
        originalSource: this.originalSource,
        sourceContainer: container,
        sensorEvent,
        overContainer: this.currentOverContainer
      });
      this.currentOverContainer.classList.remove(...this.getClassNamesFor("container:over"));
      this.currentOverContainer = null;
      this.trigger(dragOutContainerEvent);
    }
    if (isOverContainer) {
      overContainer.classList.add(...this.getClassNamesFor("container:over"));
      const dragOverContainerEvent = new DragOverContainerEvent({
        source: this.source,
        originalSource: this.originalSource,
        sourceContainer: container,
        sensorEvent,
        overContainer
      });
      this.currentOverContainer = overContainer;
      this.trigger(dragOverContainerEvent);
    }
    if (isOverDraggable) {
      target.classList.add(...this.getClassNamesFor("draggable:over"));
      const dragOverEvent = new DragOverEvent({
        source: this.source,
        originalSource: this.originalSource,
        sourceContainer: container,
        sensorEvent,
        overContainer,
        over: target
      });
      this.currentOver = target;
      this.trigger(dragOverEvent);
    }
  }
  [dragStop](event) {
    if (!this.dragging) {
      return;
    }
    this.dragging = false;
    const dragStopEvent = new DragStopEvent({
      source: this.source,
      originalSource: this.originalSource,
      sensorEvent: event ? event.sensorEvent : null,
      sourceContainer: this.sourceContainer
    });
    this.trigger(dragStopEvent);
    if (!dragStopEvent.canceled())
      this.source.parentNode.insertBefore(this.originalSource, this.source);
    this.source.remove();
    this.originalSource.style.display = "";
    this.source.classList.remove(...this.getClassNamesFor("source:dragging"));
    this.originalSource.classList.remove(...this.getClassNamesFor("source:original"));
    this.originalSource.classList.add(...this.getClassNamesFor("source:placed"));
    this.sourceContainer.classList.add(...this.getClassNamesFor("container:placed"));
    this.sourceContainer.classList.remove(...this.getClassNamesFor("container:dragging"));
    document.body.classList.remove(...this.getClassNamesFor("body:dragging"));
    applyUserSelect(document.body, "");
    if (this.currentOver) {
      this.currentOver.classList.remove(...this.getClassNamesFor("draggable:over"));
    }
    if (this.currentOverContainer) {
      this.currentOverContainer.classList.remove(...this.getClassNamesFor("container:over"));
    }
    this.lastPlacedSource = this.originalSource;
    this.lastPlacedContainer = this.sourceContainer;
    this.placedTimeoutID = setTimeout(() => {
      if (this.lastPlacedSource) {
        this.lastPlacedSource.classList.remove(...this.getClassNamesFor("source:placed"));
      }
      if (this.lastPlacedContainer) {
        this.lastPlacedContainer.classList.remove(...this.getClassNamesFor("container:placed"));
      }
      this.lastPlacedSource = null;
      this.lastPlacedContainer = null;
    }, this.options.placedTimeout);
    const dragStoppedEvent = new DragStoppedEvent({
      source: this.source,
      originalSource: this.originalSource,
      sensorEvent: event ? event.sensorEvent : null,
      sourceContainer: this.sourceContainer
    });
    this.trigger(dragStoppedEvent);
    this.source = null;
    this.originalSource = null;
    this.currentOverContainer = null;
    this.currentOver = null;
    this.sourceContainer = null;
  }
  [onDragStop5](event) {
    this[dragStop](event);
  }
  [onDragPressure](event) {
    if (!this.dragging) {
      return;
    }
    const sensorEvent = getSensorEvent(event);
    const source = this.source || closest(sensorEvent.originalEvent.target, this.options.draggable);
    const dragPressureEvent = new DragPressureEvent({
      sensorEvent,
      source,
      pressure: sensorEvent.pressure
    });
    this.trigger(dragPressureEvent);
  }
};
Draggable.Plugins = {
  Announcement,
  Focusable,
  Mirror,
  Scrollable
};
Draggable.Sensors = {
  MouseSensor,
  TouchSensor
};
function getSensorEvent(event) {
  return event.detail;
}
function applyUserSelect(element, value) {
  element.style.webkitUserSelect = value;
  element.style.mozUserSelect = value;
  element.style.msUserSelect = value;
  element.style.oUserSelect = value;
  element.style.userSelect = value;
}

// ../node_modules/@shopify/draggable/build/esm/Droppable/DroppableEvent/DroppableEvent.mjs
var DroppableEvent = class extends AbstractEvent {
  constructor(data) {
    super(data);
    this.data = data;
  }
  get dragEvent() {
    return this.data.dragEvent;
  }
};
DroppableEvent.type = "droppable";
var DroppableStartEvent = class extends DroppableEvent {
  get dropzone() {
    return this.data.dropzone;
  }
};
DroppableStartEvent.type = "droppable:start";
DroppableStartEvent.cancelable = true;
var DroppableDroppedEvent = class extends DroppableEvent {
  get dropzone() {
    return this.data.dropzone;
  }
};
DroppableDroppedEvent.type = "droppable:dropped";
DroppableDroppedEvent.cancelable = true;
var DroppableReturnedEvent = class extends DroppableEvent {
  get dropzone() {
    return this.data.dropzone;
  }
};
DroppableReturnedEvent.type = "droppable:returned";
DroppableReturnedEvent.cancelable = true;
var DroppableStopEvent = class extends DroppableEvent {
  get dropzone() {
    return this.data.dropzone;
  }
};
DroppableStopEvent.type = "droppable:stop";
DroppableStopEvent.cancelable = true;

// ../node_modules/@shopify/draggable/build/esm/Droppable/Droppable.mjs
var onDragStart6 = Symbol("onDragStart");
var onDragMove5 = Symbol("onDragMove");
var onDragStop6 = Symbol("onDragStop");
var dropInDropzone = Symbol("dropInDropZone");
var returnToOriginalDropzone = Symbol("returnToOriginalDropzone");
var closestDropzone = Symbol("closestDropzone");
var getDropzones = Symbol("getDropzones");

// ../node_modules/@shopify/draggable/build/esm/Swappable/SwappableEvent/SwappableEvent.mjs
var SwappableEvent = class extends AbstractEvent {
  constructor(data) {
    super(data);
    this.data = data;
  }
  get dragEvent() {
    return this.data.dragEvent;
  }
};
SwappableEvent.type = "swappable";
var SwappableStartEvent = class extends SwappableEvent {
};
SwappableStartEvent.type = "swappable:start";
SwappableStartEvent.cancelable = true;
var SwappableSwapEvent = class extends SwappableEvent {
  get over() {
    return this.data.over;
  }
  get overContainer() {
    return this.data.overContainer;
  }
};
SwappableSwapEvent.type = "swappable:swap";
SwappableSwapEvent.cancelable = true;
var SwappableSwappedEvent = class extends SwappableEvent {
  get swappedElement() {
    return this.data.swappedElement;
  }
};
SwappableSwappedEvent.type = "swappable:swapped";
var SwappableStopEvent = class extends SwappableEvent {
};
SwappableStopEvent.type = "swappable:stop";

// ../node_modules/@shopify/draggable/build/esm/Swappable/Swappable.mjs
var onDragStart7 = Symbol("onDragStart");
var onDragOver3 = Symbol("onDragOver");
var onDragStop7 = Symbol("onDragStop");

// ../node_modules/@shopify/draggable/build/esm/Sortable/SortableEvent/SortableEvent.mjs
var SortableEvent = class extends AbstractEvent {
  constructor(data) {
    super(data);
    this.data = data;
  }
  get dragEvent() {
    return this.data.dragEvent;
  }
};
SortableEvent.type = "sortable";
var SortableStartEvent = class extends SortableEvent {
  get startIndex() {
    return this.data.startIndex;
  }
  get startContainer() {
    return this.data.startContainer;
  }
};
SortableStartEvent.type = "sortable:start";
SortableStartEvent.cancelable = true;
var SortableSortEvent = class extends SortableEvent {
  get currentIndex() {
    return this.data.currentIndex;
  }
  get over() {
    return this.data.over;
  }
  get overContainer() {
    return this.data.dragEvent.overContainer;
  }
};
SortableSortEvent.type = "sortable:sort";
SortableSortEvent.cancelable = true;
var SortableSortedEvent = class extends SortableEvent {
  get oldIndex() {
    return this.data.oldIndex;
  }
  get newIndex() {
    return this.data.newIndex;
  }
  get oldContainer() {
    return this.data.oldContainer;
  }
  get newContainer() {
    return this.data.newContainer;
  }
};
SortableSortedEvent.type = "sortable:sorted";
var SortableStopEvent = class extends SortableEvent {
  get oldIndex() {
    return this.data.oldIndex;
  }
  get newIndex() {
    return this.data.newIndex;
  }
  get oldContainer() {
    return this.data.oldContainer;
  }
  get newContainer() {
    return this.data.newContainer;
  }
};
SortableStopEvent.type = "sortable:stop";

// ../node_modules/@shopify/draggable/build/esm/Sortable/Sortable.mjs
var onDragStart8 = Symbol("onDragStart");
var onDragOverContainer = Symbol("onDragOverContainer");
var onDragOver4 = Symbol("onDragOver");
var onDragStop8 = Symbol("onDragStop");
function onSortableSortedDefaultAnnouncement({
  dragEvent
}) {
  const sourceText = dragEvent.source.textContent.trim() || dragEvent.source.id || "sortable element";
  if (dragEvent.over) {
    const overText = dragEvent.over.textContent.trim() || dragEvent.over.id || "sortable element";
    const isFollowing = dragEvent.source.compareDocumentPosition(dragEvent.over) & Node.DOCUMENT_POSITION_FOLLOWING;
    if (isFollowing) {
      return `Placed ${sourceText} after ${overText}`;
    } else {
      return `Placed ${sourceText} before ${overText}`;
    }
  } else {
    return `Placed ${sourceText} into a different container`;
  }
}
var defaultAnnouncements2 = {
  "sortable:sorted": onSortableSortedDefaultAnnouncement
};
var Sortable = class extends Draggable {
  constructor(containers = [], options = {}) {
    super(containers, {
      ...options,
      announcements: {
        ...defaultAnnouncements2,
        ...options.announcements || {}
      }
    });
    this.startIndex = null;
    this.startContainer = null;
    this[onDragStart8] = this[onDragStart8].bind(this);
    this[onDragOverContainer] = this[onDragOverContainer].bind(this);
    this[onDragOver4] = this[onDragOver4].bind(this);
    this[onDragStop8] = this[onDragStop8].bind(this);
    this.on("drag:start", this[onDragStart8]).on("drag:over:container", this[onDragOverContainer]).on("drag:over", this[onDragOver4]).on("drag:stop", this[onDragStop8]);
  }
  destroy() {
    super.destroy();
    this.off("drag:start", this[onDragStart8]).off("drag:over:container", this[onDragOverContainer]).off("drag:over", this[onDragOver4]).off("drag:stop", this[onDragStop8]);
  }
  index(element) {
    return this.getSortableElementsForContainer(element.parentNode).indexOf(element);
  }
  getSortableElementsForContainer(container) {
    const allSortableElements = container.querySelectorAll(this.options.draggable);
    return [...allSortableElements].filter((childElement) => {
      return childElement !== this.originalSource && childElement !== this.mirror && childElement.parentNode === container;
    });
  }
  [onDragStart8](event) {
    this.startContainer = event.source.parentNode;
    this.startIndex = this.index(event.source);
    const sortableStartEvent = new SortableStartEvent({
      dragEvent: event,
      startIndex: this.startIndex,
      startContainer: this.startContainer
    });
    this.trigger(sortableStartEvent);
    if (sortableStartEvent.canceled()) {
      event.cancel();
    }
  }
  [onDragOverContainer](event) {
    if (event.canceled()) {
      return;
    }
    const {
      source,
      over,
      overContainer
    } = event;
    const oldIndex = this.index(source);
    const sortableSortEvent = new SortableSortEvent({
      dragEvent: event,
      currentIndex: oldIndex,
      source,
      over
    });
    this.trigger(sortableSortEvent);
    if (sortableSortEvent.canceled()) {
      return;
    }
    const children = this.getSortableElementsForContainer(overContainer);
    const moves = move({
      source,
      over,
      overContainer,
      children
    });
    if (!moves) {
      return;
    }
    const {
      oldContainer,
      newContainer
    } = moves;
    const newIndex = this.index(event.source);
    const sortableSortedEvent = new SortableSortedEvent({
      dragEvent: event,
      oldIndex,
      newIndex,
      oldContainer,
      newContainer
    });
    this.trigger(sortableSortedEvent);
  }
  [onDragOver4](event) {
    if (event.over === event.originalSource || event.over === event.source) {
      return;
    }
    const {
      source,
      over,
      overContainer
    } = event;
    const oldIndex = this.index(source);
    const sortableSortEvent = new SortableSortEvent({
      dragEvent: event,
      currentIndex: oldIndex,
      source,
      over
    });
    this.trigger(sortableSortEvent);
    if (sortableSortEvent.canceled()) {
      return;
    }
    const children = this.getDraggableElementsForContainer(overContainer);
    const moves = move({
      source,
      over,
      overContainer,
      children
    });
    if (!moves) {
      return;
    }
    const {
      oldContainer,
      newContainer
    } = moves;
    const newIndex = this.index(source);
    const sortableSortedEvent = new SortableSortedEvent({
      dragEvent: event,
      oldIndex,
      newIndex,
      oldContainer,
      newContainer
    });
    this.trigger(sortableSortedEvent);
  }
  [onDragStop8](event) {
    const sortableStopEvent = new SortableStopEvent({
      dragEvent: event,
      oldIndex: this.startIndex,
      newIndex: this.index(event.source),
      oldContainer: this.startContainer,
      newContainer: event.source.parentNode
    });
    this.trigger(sortableStopEvent);
    this.startIndex = null;
    this.startContainer = null;
  }
};
function index(element) {
  return Array.prototype.indexOf.call(element.parentNode.children, element);
}
function move({
  source,
  over,
  overContainer,
  children
}) {
  const emptyOverContainer = !children.length;
  const differentContainer = source.parentNode !== overContainer;
  const sameContainer = over && source.parentNode === over.parentNode;
  if (emptyOverContainer) {
    return moveInsideEmptyContainer(source, overContainer);
  } else if (sameContainer) {
    return moveWithinContainer(source, over);
  } else if (differentContainer) {
    return moveOutsideContainer(source, over, overContainer);
  } else {
    return null;
  }
}
function moveInsideEmptyContainer(source, overContainer) {
  const oldContainer = source.parentNode;
  overContainer.appendChild(source);
  return {
    oldContainer,
    newContainer: overContainer
  };
}
function moveWithinContainer(source, over) {
  const oldIndex = index(source);
  const newIndex = index(over);
  if (oldIndex < newIndex) {
    source.parentNode.insertBefore(source, over.nextElementSibling);
  } else {
    source.parentNode.insertBefore(source, over);
  }
  return {
    oldContainer: source.parentNode,
    newContainer: source.parentNode
  };
}
function moveOutsideContainer(source, over, overContainer) {
  const oldContainer = source.parentNode;
  if (over) {
    over.parentNode.insertBefore(source, over);
  } else {
    overContainer.appendChild(source);
  }
  return {
    oldContainer,
    newContainer: source.parentNode
  };
}

// js/_hooks/Punkix.Components.ListComponent.hooks.js
var Punkix_Components_ListComponent_hooks_default = {
  mounted() {
    this.initDraggables();
  },
  initDraggables() {
    const target = this.el.dataset.target;
    const assign = this.el.dataset.assign;
    new Sortable(this.el, {
      draggable: ".sortable",
      handle: ".sortable-handle",
      animation: 150,
      classes: { "draggable:over": "has-background-info-light" }
    }).on("sortable:stop", (event) => {
      const newIndex = parseInt(event.data.newIndex);
      const oldIndex = parseInt(event.data.oldIndex);
      const payload = {
        from: oldIndex,
        to: newIndex
      };
      if (oldIndex !== newIndex) {
        const event2 = `sort-${assign}`;
        if (target) {
          this.pushEventTo(target, event2, payload);
        } else {
          this.pushEvent(event2, payload);
        }
      }
    });
  }
};

// js/_hooks/index.js
function ns(hooks2, nameSpace) {
  const updatedHooks = {};
  Object.keys(hooks2).map(function(key) {
    updatedHooks[`${nameSpace}#${key}`] = hooks2[key];
  });
  return updatedHooks;
}
var hooks = Object.assign(ns(Punkix_Components_ListComponent_hooks_exports, "Punkix.Components.ListComponent"));
var hooks_default = hooks;

// js/punkix/index.js
var encoder = new Encoder({ ignoreUndefined: true });
var decoder = new Decoder();
var encode = (payload, callback) => {
  if (payload.payload instanceof ArrayBuffer) {
    payload.payload = new Uint8Array(payload.payload);
  }
  callback(encoder.encode(payload));
};
var decode = (payload, callback) => callback(decoder.decode(payload));
//# sourceMappingURL=punkix.cjs.js.map
