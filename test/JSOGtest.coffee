assert = require('assert')
JSOG = require('../JSOG')

inside = { name: 'thing' }

outside =
	inside1: inside
	inside2: inside

encoded = JSOG.encode(outside)

#console.log "Encoded is:"
#console.log JSON.stringify(encoded, undefined, 4)
#console.log "Outside after encoding is:"
#console.log JSON.stringify(outside, undefined, 4)

describe 'no id should be set', ->
	it 'should not have added an id to outside', ->
		assert !(outside['$id']?)
	it 'should not have added an id to inside', ->
		assert !(inside['$id']?)

decoded = JSOG.decode(encoded)

console.log "Decoded is:"
console.log JSON.stringify(decoded, undefined, 4)

#assert decoded.inside1 == decoded.inside2
#assert decoded.inside1.name == 'thing'
#assert !(decoded['$id']?)
