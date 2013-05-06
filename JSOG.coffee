
# TODO: figure out how to export this properly


JSOG = {}

JSOG.decode = (encoded) ->
	# Holds every $id found so far - this is why id values must be strings
	found = {}

	doDecode = (encoded) ->
		console.log "decoding #{JSON.stringify(encoded)}"

		decodeObject = (encoded) ->
			if encoded['$ref']?
				return found[encoded['$ref']]

			result = {}
			found[encoded['$id']] = result

			for key, value of encoded
				if key != '$id'
					result[key] = doDecode(value)

			return result

		decodeArray = (encoded) ->
			result = []
			for value in encoded
				result.push(decode(value))

			return result

		if Array.isArray(encoded)
			return decodeArray(encoded)
		else if typeof encoded == 'object'
			return decodeObject(encoded)
		else
			return encoded

	doDecode(encoded)

nextId = 1
JSOG.encode = (original) ->
	#console.log "encoding #{JSON.stringify(original)}"

	encodeObject = (original) ->
		if original['$id']?
			return { '$ref': original['$id'] }

		result = {}
		original['$id'] = "#{nextId++}"
		for key, value of original
			result[key] = JSOG.encode(value)

		return result

	encodeArray = (original) ->
		return (encode val for val in original)

	if Array.isArray(original)
		return encodeArray(original)
	else if typeof original == 'object'
		return encodeObject(original)
	else
		return original


#
# Export to anywhere appropriate
#

if module && module.exports
	module.exports = JSOG

if window?
	window.JSOG = JSOG
