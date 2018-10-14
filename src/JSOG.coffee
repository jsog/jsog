
#
# Create JSOG.encode() and JSOG.decode()
#

JSOG = {}

nextId = 0

# Older browser compatibility
isArray = Array.isArray || (obj) -> Object.prototype.toString.call(obj) == '[object Array]'

# True if the object has a toJSON method
hasCustomJsonificaiton = (obj) -> obj.toJSON?

JSOG_OBJECT_ID = '__jsogObjectId'

#
# Take a JSON structure with cycles and turn it into a JSOG-encoded structure. Adds
# @id to every object and replaces duplicate references with @refs.
#
# Note that this modifies the original objects adding __jsogObjectId fields and leaves
# them there. There does not appear to be another way to define object identity in JS.
#
JSOG.encode = (original, idProperty = '@id', refProperty = '@ref') ->
	#console.log "encoding #{JSON.stringify(original)}"

	sofar = {}

	# Get (and if necessary, set) an object id. This ends up being left behind in the original object.
	idOf = (obj) ->
		if !obj[JSOG_OBJECT_ID]
			obj[JSOG_OBJECT_ID] = "#{nextId++}"

		return obj[JSOG_OBJECT_ID]

	doEncode = (original) ->
		encodeObject = (original) ->
			id = idOf(original)
			if sofar[id]
				return { "#{refProperty}": id}

			result = sofar[id] = { "#{idProperty}": id }
			for key, value of original
				if key != JSOG_OBJECT_ID
					result[key] = doEncode(value)

			return result

		encodeArray = (original) ->
			return (doEncode(val) for val in original)

		if !original?
			return original
		else if hasCustomJsonificaiton(original)
			return original
		else if isArray(original)
			return encodeArray(original)
		else if typeof original == 'object'
			return encodeObject(original)
		else
			return original

	return doEncode(original)

#
# Take a JSOG-encoded JSON structure and re-link all the references. The return value will
# not have any @id or @ref fields
#
JSOG.decode = (encoded, idProperty = '@id', refProperty = '@ref') ->
	# Holds every @id found so far.
	found = {}
	doLater = undefined

	doDecode = (encoded) ->
		#console.log "decoding #{JSON.stringify(encoded)}"

		decodeObject = (encoded) ->
			ref = encoded[refProperty]
			ref = ref.toString() if ref? # be defensive if someone uses numbers in violation of the spec
			result = {}
			populate = (key, value) ->
				result[key] = doDecode(value)
			if ref?
				return found[ref] || (found[ref]=result)


			id = encoded[idProperty]
			id = id.toString() if id? # be defensive if someone uses numbers in violation of the spec
			if id
				found[id] = result = found[id] || result

			for key, value of encoded
				if key != idProperty
					if doLater
						doLater.push(populate.bind(null, key, value))
					else
						doLater = []
						populate key, value
						while doLater.length
							doLater.shift()()
						doLater = undefined

			return result

		decodeArray = (encoded) ->
			return (doDecode(value) for value in encoded)

		if !encoded?
			return encoded
		else if isArray(encoded)
			return decodeArray(encoded)
		else if typeof encoded == 'object'
			return decodeObject(encoded)
		else
			return encoded

	return doDecode(encoded)

#
# Like JSON.stringify, but produces JSOG
#
JSOG.stringify = (obj) ->
	return JSON.stringify(JSOG.encode(obj))

#
# Like JSON.parse, but understands JSOG
#
JSOG.parse = (str) ->
	return JSOG.decode(JSON.parse(str))


#
# Export to anywhere appropriate
#

if module? && module.exports
	module.exports = JSOG

if window?
	window.JSOG = JSOG

if typeof define == 'function' && define.amd
	define 'JSOG', [], -> JSOG

return JSOG

