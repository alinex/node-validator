// @flow
import chai from 'chai'
import Debug from 'debug'

import Reference from '../../src/Reference'
import SchemaData from '../../src/SchemaData'
import Schema from '../../src/Schema'
import ObjectSchema from '../../src/ObjectSchema'
import NumberSchema from '../../src/NumberSchema'

import * as helper from './helper'

const expect = chai.expect
const debug = Debug('test')

describe('reference', () => {

  it('should get direct value', (done) => {
    const ref = new Reference({ a: 1 })
    helper.reference(ref, undefined, (res) => {
      expect(res).deep.equal({ a: 1 })
    }, done)
  })

  describe('usage', () => {

    describe('in data', () => {

      it('should resolve', (done) => {
        const data = 'abc'
        const ref = new Reference(data)
        const schema = new Schema()
        // use schema
        helper.validateOk(schema, ref, (res) => {
          expect(res).deep.equal(data)
        }, done)
      })

    })

    describe('in schema', () => {

      it('should resolve', (done) => {
        const data = 'abc'
        const ref = new Reference(data)
        const schema = new Schema().default(ref)
        // use schema
        helper.validateOk(schema, undefined, (res) => {
          expect(res).deep.equal(data)
        }, done)
      })

      it('should describe', () => {
        const data = 'abc'
        const ref = new Reference(data)
        const schema = new Schema().default(ref)
        // use schema
        expect(helper.description(schema))
        .to.equal('It will default to reference at \'abc\' if not set.')
      })

    })

  })

  describe('source', () => {

    it('should support schema data', (done) => {
      const data = new SchemaData(1)
      const ref = new Reference()
      helper.reference(ref, data, (res) => {
        expect(res).deep.equal(1)
      }, done)
    })

    it('should support object structure', (done) => {
      const base = { a: 1 }
      const ref = new Reference(base)
      helper.reference(ref, undefined, (res) => {
        expect(res).deep.equal(base)
      }, done)
    })

    it('should support function', (done) => {
      function base() {
        return { a: 1 }
      }
      const ref = new Reference(base)
      helper.reference(ref, undefined, (res) => {
        expect(res).deep.equal({ a: 1 })
      }, done)
    })

    it('should support local command', (done) => {
      process.env.TESTENV = '777'
      const ref = new Reference('env://TESTENV')
      helper.reference(ref, undefined, (res) => {
        expect(res).to.be.a('string')
      }, done)
    })

    it('should support local command', (done) => {
      const ref = new Reference('exec://date')
      helper.reference(ref, undefined, (res) => {
        expect(res).to.be.a('string')
      }, done)
    })

    it('should support local command with options', (done) => {
      const ref = new Reference('exec:///bin/date +%Y')
      helper.reference(ref, undefined, (res) => {
        expect(res).to.be.a('string')
      }, done)
    })

//    it('should support remote command', (done) => {
//      const ref = new Reference('ssh://divibib@vs10191 date')
//      helper.reference(ref, undefined, (res) => {
//        expect(res).to.be.a('string')
//      }, done)
//    })

    it('should support local file', (done) => {
      const ref = new Reference('file:///proc/version')
      helper.reference(ref, undefined, (res) => {
        expect(res).to.be.a('string')
      }, done)
    })

    // web resource
    it('should support web servcie http', (done) => {
      const ref = new Reference('http://google.de')
      helper.reference(ref, undefined, (res) => {
        expect(res).to.be.a('string')
      }, done)
    })
    it('should support web servcie https', (done) => {
      const ref = new Reference('https://google.de')
      helper.reference(ref, undefined, (res) => {
        expect(res).to.be.a('string')
      }, done)
    })

    // ftp
    // sftp
//    it('should support web servcie ftp', (done) => {
//      const ref = new Reference('ftp://ftp.avm.de/fritz.box/')
//      helper.reference(ref, undefined, (res) => {
//        expect(res).to.be.a('string')
//      }, done)
//    })

  })

  describe.only('accessors', () => {

    describe('path', () => {

      const teams = {
        europe: {
          germany: {
            stuttgart: 'VFB Stuttgart',
            munich: 'FC Bayern',
            cologne: 'FC Köln',
          },
          spain: {
            madrid: 'Real Madrid',
          },
        },
        southamerica: {
          brazil: {
            saopaulo: 'FC Sao Paulo',
          },
        },
      }

      it('should get subelement of object', (done) => {
        const ref = new Reference({ a: 1 }).path('a')
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(1)
        }, done)
      })

      it('should get subelement of object', (done) => {
        const ref = new Reference({ a: { b: 1 } }).path('a/b')
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(1)
        }, done)
      })

      it('should get neighbor element', (done) => {
        const ref = new Reference().path('../b')
        const data = {
          a: ref,
          b: 2,
        }
        const schema = new ObjectSchema().key('a', new NumberSchema())
        // use schema
        helper.validateOk(schema, data, (res) => {
          expect(res).deep.equal({ a: 2, b: 2 })
        }, done)
      })

      it('should find group', (done) => {
        const ref = new Reference(teams).path('europe/germany')
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(teams.europe.germany)
        }, done)
      })

      it('should find element', (done) => {
        const ref = new Reference(teams).path('europe/germany/stuttgart')
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(teams.europe.germany.stuttgart)
        }, done)
      })

      it('should fail with', (done) => {
        const ref = new Reference(teams).path('berlin')
        helper.reference(ref, undefined, (res) => {
          expect(res).equal(undefined)
        }, done)
      })

      it('should allow backreferences in path', (done) => {
        const ref = new Reference(teams).path('europe/../southamerica')
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(teams.southamerica)
        }, done)
      })

      it('should allow name with asterisk', (done) => {
        const ref = new Reference(teams).path('europe/*/munich')
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(teams.europe.germany.munich)
        }, done)
      })

      it('should allow multilevel asterisk', (done) => {
        const ref = new Reference(teams).path('**/munich')
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(teams.europe.germany.munich)
        }, done)
      })

      it('should allow regexp pattern', (done) => {
        const ref = new Reference(teams).path('**/(munich|stuttgart)')
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal([teams.europe.germany.stuttgart, teams.europe.germany.munich])
        }, done)
      })

    })

    describe('keys', () => {

      it('should get list', (done) => {
        const data = { one: 1, two: 2 }
        const ref = new Reference(data).keys()
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(['one', 'two'])
        }, done)
      })

      it('should do nothing on undefined', (done) => {
        const ref = new Reference(undefined).keys()
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(undefined)
        }, done)
      })

    })

    describe('values', () => {

      it('should get list', (done) => {
        const data = { one: 1, two: 2 }
        const ref = new Reference(data).values()
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal([1, 2])
        }, done)
      })

      it('should do nothing on undefined', (done) => {
        const ref = new Reference(undefined).values()
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(undefined)
        }, done)
      })

    })

    describe('trim', () => {

      it('should work on string', (done) => {
        const data = 'Test\n'
        const ref = new Reference(data).trim()
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal('Test')
        }, done)
      })

      it('should work on array', (done) => {
        const data = ['one\n', '   two    ', '\t three']
        const ref = new Reference(data).trim()
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(['one', 'two', 'three'])
        }, done)
      })

      it('should work on object', (done) => {
        const data = { eins: 'one\n', zwei: '   two    ', drei: '\t three' }
        const ref = new Reference(data).trim()
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal({ eins: 'one', zwei: 'two', drei: 'three' })
        }, done)
      })

      it('should do nothing on undefined', (done) => {
        const ref = new Reference(undefined).trim()
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(undefined)
        }, done)
      })

    })

    describe('split', () => {

      it('should work on string', (done) => {
        const data = 'One;Eins\nTwo;Zwei\nThree;Drei'
        const ref = new Reference(data).split('\n', ';')
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal([['One', 'Eins'], ['Two', 'Zwei'], ['Three', 'Drei']])
        }, done)
      })

    })

    describe('join', () => {

      it('should work', (done) => {
        const data = [['One', 'Eins'], ['Two', 'Zwei'], ['Three', 'Drei']]
        const ref = new Reference(data).join('\n', ';')
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal('One;Eins\nTwo;Zwei\nThree;Drei')
        }, done)
      })

    })

    describe('match', () => {

      it('should work with global match', (done) => {
        const data = 'The house number one is just beside house number three.'
        const ref = new Reference(data).match(/number (\w+)/g)
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(['number one', 'number three'])
        }, done)
      })

      it('should work with single match', (done) => {
        const data = 'The house number one is just beside house number three.'
        const ref = new Reference(data).match(/number (\w+)/)
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(['number one', 'one'])
        }, done)
      })

    })

    describe('range', () => {

      it('should work with single element', (done) => {
        const data = [10, 11, 12, 13, 14, 15]
        const ref = new Reference(data).range([1], [3])
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal([11, 13])
        }, done)
      })

      it('should work with range', (done) => {
        const data = [10, 11, 12, 13, 14, 15]
        const ref = new Reference(data).range([1, 4])
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal([11, 12, 13])
        }, done)
      })

      it('should work with open end', (done) => {
        const data = [10, 11, 12, 13, 14, 15]
        const ref = new Reference(data).range([3, 0])
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal([13, 14, 15])
        }, done)
      })

      it('should work with negatives', (done) => {
        const data = [10, 11, 12, 13, 14, 15]
        const ref = new Reference(data).range([-3, -1])
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal([13, 14])
        }, done)
      })

    })

    describe('filter', () => {

      it('should work with list', (done) => {
        const data = ['number one', 'number two', 'number three', 'number four']
        const ref = new Reference(data).filter('number three', 'number four', 'number five')
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(['number three', 'number four'])
        }, done)
      })

      it('should work with regular expression', (done) => {
        const data = ['number one', 'number two', 'number three', 'number four']
        const ref = new Reference(data).filter(/ t/)
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(['number two', 'number three'])
        }, done)
      })

    })

    describe('exclude', () => {

      it('should work with list', (done) => {
        const data = ['number one', 'number two', 'number three', 'number four']
        const ref = new Reference(data).exclude('number three', 'number four', 'number five')
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(['number one', 'number two'])
        }, done)
      })

      it('should work with regular expression', (done) => {
        const data = ['number one', 'number two', 'number three', 'number four']
        const ref = new Reference(data).exclude(/ t/)
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(['number one', 'number four'])
        }, done)
      })

    })

    describe('parse', () => {

      it('should work with yaml', (done) => {
        const data = 'name: Albert\nage: 21'
        const ref = new Reference(data).parse() // autodetect
        helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal({ name: 'Albert', age: 21 })
        }, done)
      })

    })

  })

})
