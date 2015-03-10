assert = require('assert')
JSOG = require('../lib/JSOG')
moment = require('moment')

describe 'leaving original object alone', ->
	foo = {}
	JSOG.encode(foo)

	it 'should not have added an id', ->
		assert !(foo['$id']?)

describe 'duplicate references', ->
	inside = { name: 'thing' }

	outside =
		inside1: inside
		inside2: inside

	encoded = JSOG.encode(outside)
	decoded = JSOG.decode(encoded)

	console.log "Encoded is:"
	console.log JSON.stringify(encoded, undefined, 4)
	console.log "Outside after encoding is:"
	console.log JSON.stringify(outside, undefined, 4)
	console.log "Decoded is:"
	console.log JSON.stringify(decoded, undefined, 4)

	roundtrip = JSOG.parse(JSOG.stringify(outside))
	console.log "Roundtrip is:"
	console.log JSON.stringify(roundtrip, undefined, 4)

	it 'inside1 and inside2 should be equal', ->
		assert decoded.inside1 == decoded.inside2
	it 'should have inside1.name', ->
		assert decoded.inside1.name == 'thing'
	it 'should not have an @id', ->
		assert !(decoded['@id']?)

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

describe 'nulls', ->
	it 'should leave null by itself alone', ->
		assert JSOG.encode(null) == null

	it 'should leave null in an object alone', ->
		foo = { foo: null }
		encoded = JSOG.encode(foo)

		assert encoded['@id']?
		assert encoded.foo == null

describe 'arrays', ->
	it 'should encode arrays properly', ->
		foo = { bar: true }
		array = [foo, foo]

		encoded = JSOG.encode(array)

		assert encoded[0]['@id']?
		assert encoded[0]['@id'] == encoded[1]['@ref']

describe 'custom json serialization', ->
	it 'should leave objects with toJSON methods alone', ->
		foo = { foo: moment() }
		encoded = JSOG.encode(foo)
		assert encoded.foo == foo.foo