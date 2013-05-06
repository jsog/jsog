
# TODO: figure out how to export this properly

JSOG = {}

JSOG.decode = (encoded) ->
	# Holds every $id found so far - this is why id values must be strings
	found = {}

	decodeObject = (encoded) ->
		if encoded['$ref']
			return found[encoded['$ref']]

		result = {}
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


