
JSOG = require('JSOG')

inside = { name: 'thing' }

outside =
	inside1: inside
	inside2: inside

encoded = JSOG.encode(outside)

console.log JSON.stringify(encoded)
