assert = require('assert')
JSOG = require('../lib/JSOG')

inside = { name: 'thing' }

outside =
	inside1: inside
	inside2: inside

describe 'no id should be set', ->
	it 'should not have added an id to outside', ->
		assert !(outside['$id']?)
	it 'should not have added an id to inside', ->
		assert !(inside['$id']?)

describe 'decoded should work', ->
	encoded = JSOG.encode(outside)
	decoded = JSOG.decode(encoded)

	console.log "Encoded is:"
	console.log JSON.stringify(encoded, undefined, 4)
	console.log "Outside after encoding is:"
	console.log JSON.stringify(outside, undefined, 4)
	console.log "Decoded is:"
	console.log JSON.stringify(decoded, undefined, 4)

	it 'inside1 and inside2 should be equal', ->
		assert decoded.inside1 == decoded.inside2
	it 'should have inside1.name', ->
		assert decoded.inside1.name == 'thing'
	it 'should not have an @id', ->
		assert !(decoded['@id']?)

roundtrip = JSOG.parse(JSOG.stringify(outside))
console.log "Roundtrip is:"
console.log JSON.stringify(roundtrip, undefined, 4)

describe 'cyclic references', ->
	circular = {}
	circular.me = circular

	encoded = JSOG.encode(circular)
	decoded = JSOG.decode(encoded)
	console.log "Encoded: " + JSON.stringify(encoded, undefined, 4)

	it 'should have an encoded id', ->
		assert encoded['@id']?
	it 'should have resolved references', ->
		assert encoded.me['@ref'] == encoded['@id']
	it 'me is decoded', ->
		assert decoded.me is decoded
	it 'is not circular', ->
		assert !(circular['@id']?)
