
JSOG = require('./JSOG')

inside = { name: 'thing' }

outside =
	inside1: inside
	inside2: inside

encoded = JSOG.encode(outside)

console.log "Encoded is:"
console.log JSON.stringify(encoded, undefined, 4)

decoded = JSOG.decode(encoded)

console.log "Decoded is:"
console.log JSON.stringify(decoded, undefined, 4)
