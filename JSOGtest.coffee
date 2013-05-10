
assert = require('assert')
JSOG = require('./JSOG')

inside = { name: 'thing' }

outside =
	inside1: inside
	inside2: inside

encoded = JSOG.encode(outside)

console.log "Encoded is:"
console.log JSON.stringify(encoded, undefined, 4)
console.log "Outside after encoding is:"
console.log JSON.stringify(outside, undefined, 4)

assert !(outside['@id']?)
assert !(inside['@id']?)

decoded = JSOG.decode(encoded)

console.log "Decoded is:"
console.log JSON.stringify(decoded, undefined, 4)

assert decoded.inside1 == decoded.inside2
assert decoded.inside1.name == 'thing'
assert !(decoded['@id']?)

roundtrip = JSOG.parse(JSOG.stringify(outside))

console.log "Roundtrip is:"
console.log JSON.stringify(roundtrip, undefined, 4)
