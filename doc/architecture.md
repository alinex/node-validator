# Architecture

Heavily based on joi API...


http://2ality.com/i/index2.html private properties

## Schema definition

- create schema class
- elements are instance of type classes
- import() load from literal schema

```js
import validator from 'alinex-validator'

class Person extends validator.Object {
    name: new validator.Integer().min(10).max(100),
}
export default Person

// load from literal
class Individual extends validator.Object {}
await Individual.loadSchemaFromFile('individual.json')
export default Individual
```

## Validation

- describe()
- new () load values
- validate() bool
- get() direct access
- object() export object
- toJS() export javascript

```js
import Person from './person'

const person = new Person(data)
await person.validate()
console.log person.object().name
if (person.has('home/street')) console.log person.get('home/street')
// reload
person.clean().load(base).load(data) // load with base and extension
// ...
```

## CLI

- convert yaml


## Usage

- loading object structure
- import javascript data




## Schema

data
result


## Ideas

- defaults in schema
- default as extra data structure
