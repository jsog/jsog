# JSOG - JavaScript Object Graph

JSOG (JavaScript Object Graph) is a simple convention which allows arbitrary object graphs
to be represented in JSON. It allows a large, complicated, cyclic object graph to be seriazlied
and deserialized to and from JSON.

## The problem with JSON

JSON is widely used as a data interchange format, however, it
is limited:

* Only directed acyclic graphs can be represented.
* Graphs with repeating information are duplicated on the wire and in memory.

For example, picture this data structure which represents a department in a company:

	{
		'name': 'Engineering',
		'employees': [
			{
				name: 'Sally'
				projects: [{...Widgetomatic...}]
			}, {
				name: 'Bob',
				manager: {...Sally...},
				projects: [{...Widgetomatic...}]
			}
		],
		'projects': [
			{
				name: 'Widgetomatic',
				staff: [
					{...Sally...},
					{...Bob...}
				]
			}, {
				name: 'Underfunded',
				staff: []
			}
		]
	}

There are obvious cycles in this graph; employees manage other employees and projects have employees which
have projects. Your database and represents these relationships just fine and your ORM can pull the object
graph (with references) into memory, but you cannot directly serialize it to a JSON structure without stack
overflow errors. This is a problem when you want to return all of the employees, managers, and projects from a REST
GET to /departments/Engineering.

## The JSOG solution

JSOG is a standard way to represent object graphs.

* JSOG is 100% JSON. No special parser is necessary.
* JSOG is human readable; acyclic graphs are structured just like regular JSON.
* JSOG makes no assumptions about pre-existing fields. You do not need to create ids for your objects.
* JSOG is trivial to implement in any language or platform.

This is the JSOG representation of the previous department:

	{
		'$id': '1',
		'name': 'Engineering',
		'employees': [
			{
				'$id': '2',
				name: 'Sally'
				projects: [{
					'$id': '3',
					name: 'Widgetomatic',
					staff: [
						{ '$ref': '2' },
						{
							'$id': '4',
							name: 'Bob',
							manager: { '$ref': '2' },
							projects: [{ '$ref': '3' }]
						}
					]
				}]
			},
			{ '$ref': '4' }
		],
		'projects': [
			{ '$ref': '3' },
			{
				'$id': '5',
				name: 'Underfunded',
				staff: []
			}
		]
	}

### Serializing to JSOG

Each time a *new* object is encountered, give it a unique $id. Each time a *repeated* object is encountered,
serialize as a $ref to the existing $id.

### Deserializing from JSOG

Track the $id of every object deserialized. When a $ref is encountered, replace it with the object referenced.

## Implementation

Javascript can implement this as a pre- and post-processing step. For example:

	jsogEncoded = JSOG.encode(cyclicGraph);
	cyclicGraph = JSOG.decode(jsogEncoded);

