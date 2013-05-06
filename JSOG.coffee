
# TODO: figure out how to export this properly

exports = window.JSOG = JSOG = {}

JSOG.decode = (encoded) ->
	# Holds every $id found so far - this is why id values must be strings
	found = {}

	decodeObject = (encoded) ->
		if encoded['$ref']?
			return found[encoded['$ref']]

		result = {}
		found[encoded['$id']] = result

		for key, value of encoded
			if key != '$id'
				result[key] = decode(value)

		return result

	decodeArray = (encoded) ->
		result = []
		for value in encoded
			result.push(decode(value))

		return result

	if Array.isArray(encoded)
		return decodeArray(encoded)
	else if typeof encoded == object
		return decodeObject(encoded)
	else
		return encoded

nextId = 1
encodeInPlace = (original) ->
	encodeObject = (original) ->
		if original['$id']?
			return { '$ref': original['$id'] }

		original['$id'] = "#{nextId++}"
		for key, value of original
			if key != '$id'
				original[key] = encodeInPlace(value)

		return original

	encodeArray = (original) ->
		for i in [0...original.length]
			original[i] = encodeInPlace(original[i])

		return original

	if Array.isArray(original)
		return encodeArray(original)
	else if typeof original == object
		return encodeObject(original)
	else
		return encoded

JSOG.encode = (original) ->
	cloned = JSON.parse(JSON.stringify(original))
	return encodeInPlace(cloned)
