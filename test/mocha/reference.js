// @flow
import chai from 'chai'
import Debug from 'debug'

import Reference from '../../src/Reference'
import Data from '../../src/Data'
import Schema from '../../src/type/Schema'
import ObjectSchema from '../../src/type/Object'
import NumberSchema from '../../src/type/Number'

import * as helper from './helper'

const expect = chai.expect
const debug = Debug('test')

describe('reference', () => {

  it('should get direct value', () => {
    const ref = new Reference({ a: 1 })
    return helper.reference(ref, undefined, (res) => {
      expect(res).deep.equal({ a: 1 })
    })
  })

  describe('usage', () => {

    describe('in data', () => {

      it('should resolve', () => {
        const data = 'abc'
        const ref = new Reference(data)
        const schema = new Schema()
        // use schema
        return helper.validateOk(schema, ref, (res) => {
          expect(res).deep.equal(data)
        })
      })

    })

    describe('in schema', () => {

      it('should resolve', () => {
        const data = 'abc'
        const ref = new Reference(data)
        const schema = new Schema().default(ref)
        // use schema
        return helper.validateOk(schema, undefined, (res) => {
          expect(res).deep.equal(data)
        })
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

  describe('source', function sourcetest() {
    this.timeout(5000)

    it('should support schema data', () => {
      const data = new Data(1)
      const ref = new Reference()
      return helper.reference(ref, data, (res) => {
        expect(res).deep.equal(1)
      })
    })

    it('should support object structure', () => {
      const base = { a: 1 }
      const ref = new Reference(base)
      return helper.reference(ref, undefined, (res) => {
        expect(res).deep.equal(base)
      })
    })

    it('should support function', () => {
      function base() {
        return { a: 1 }
      }
      const ref = new Reference(base)
      return helper.reference(ref, undefined, (res) => {
        expect(res).deep.equal({ a: 1 })
      })
    })

    it('should support environment', () => {
      process.env.TESTENV = '777'
      const ref = new Reference('env://TESTENV')
      return helper.reference(ref, undefined, (res) => {
        expect(res).to.be.a('string')
      })
    })

    it('should support local command', () => {
      const ref = new Reference('exec://date')
      return helper.reference(ref, undefined, (res) => {
        expect(res).to.be.a('string')
      })
    })

    it('should support local command with options', () => {
      const ref = new Reference('exec:///bin/date +%Y')
      return helper.reference(ref, undefined, (res) => {
        expect(res).to.be.a('string')
      })
    })

    //    it('should support remote command', () => {
    //      const ref = new Reference('ssh://divibib@vs10191 date')
    //      return helper.reference(ref, undefined, (res) => {
    //        expect(res).to.be.a('string')
    //      })
    //    })

    it('should support local file', () => {
      const ref = new Reference('file:///proc/version')
      return helper.reference(ref, undefined, (res) => {
        expect(res).to.be.a('string')
      })
    })

    // web resource
    it('should support web servcie http', () => {
      const ref = new Reference('http://google.de')
      return helper.reference(ref, undefined, (res) => {
        expect(res).to.be.a('string')
      })
    })
    it('should support web servcie https', () => {
      const ref = new Reference('https://google.de')
      return helper.reference(ref, undefined, (res) => {
        expect(res).to.be.a('string')
      })
    })

    // ftp
    // sftp
    //    it('should support web servcie ftp', () => {
    //      const ref = new Reference('ftp://ftp.avm.de/fritz.box/')
    //      return helper.reference(ref, undefined, (res) => {
    //        expect(res).to.be.a('string')
    //      })
    //    })

  })

  describe('accessors', () => {

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

      it('should get subelement of object', () => {
        const ref = new Reference({ a: 1 }).path('a')
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(1)
        })
      })

      it('should get subelement of object', () => {
        const ref = new Reference({ a: { b: 1 } }).path('a/b')
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(1)
        })
      })

      it('should get neighbor element', () => {
        const ref = new Reference().path('../b')
        const data = {
          a: ref,
          b: 2,
        }
        const schema = new ObjectSchema().key('a', new NumberSchema())
        // use schema
        helper.validateOk(schema, data, (res) => {
          expect(res).deep.equal({ a: 2, b: 2 })
        })
      })

      it('should find group', () => {
        const ref = new Reference(teams).path('europe/germany')
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(teams.europe.germany)
        })
      })

      it('should find element', () => {
        const ref = new Reference(teams).path('europe/germany/stuttgart')
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(teams.europe.germany.stuttgart)
        })
      })

      it('should fail with', () => {
        const ref = new Reference(teams).path('berlin')
        return helper.reference(ref, undefined, (res) => {
          expect(res).equal(undefined)
        })
      })

      it('should allow backreferences in path', () => {
        const ref = new Reference(teams).path('europe/../southamerica')
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(teams.southamerica)
        })
      })

      it('should allow name with asterisk', () => {
        const ref = new Reference(teams).path('europe/*/munich')
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(teams.europe.germany.munich)
        })
      })

      it('should allow multilevel asterisk', () => {
        const ref = new Reference(teams).path('**/munich')
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(teams.europe.germany.munich)
        })
      })

      it('should allow regexp pattern', () => {
        const ref = new Reference(teams).path('**/(munich|stuttgart)')
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal([teams.europe.germany.stuttgart, teams.europe.germany.munich])
        })
      })

    })

    describe('keys', () => {

      it('should get list', () => {
        const data = { one: 1, two: 2 }
        const ref = new Reference(data).keys()
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(['one', 'two'])
        })
      })

      it('should do nothing on undefined', () => {
        const ref = new Reference(undefined).keys()
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(undefined)
        })
      })

    })

    describe('values', () => {

      it('should get list', () => {
        const data = { one: 1, two: 2 }
        const ref = new Reference(data).values()
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal([1, 2])
        })
      })

      it('should do nothing on undefined', () => {
        const ref = new Reference(undefined).values()
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(undefined)
        })
      })

    })

    describe('trim', () => {

      it('should work on string', () => {
        const data = 'Test\n'
        const ref = new Reference(data).trim()
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal('Test')
        })
      })

      it('should work on array', () => {
        const data = ['one\n', '   two    ', '\t three']
        const ref = new Reference(data).trim()
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(['one', 'two', 'three'])
        })
      })

      it('should work on object', () => {
        const data = { eins: 'one\n', zwei: '   two    ', drei: '\t three' }
        const ref = new Reference(data).trim()
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal({ eins: 'one', zwei: 'two', drei: 'three' })
        })
      })

      it('should do nothing on undefined', () => {
        const ref = new Reference(undefined).trim()
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(undefined)
        })
      })

    })

    describe('split', () => {

      it('should work on string', () => {
        const data = 'One;Eins\nTwo;Zwei\nThree;Drei'
        const ref = new Reference(data).split('\n', ';')
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal([['One', 'Eins'], ['Two', 'Zwei'], ['Three', 'Drei']])
        })
      })

    })

    describe('join', () => {

      it('should work', () => {
        const data = [['One', 'Eins'], ['Two', 'Zwei'], ['Three', 'Drei']]
        const ref = new Reference(data).join('\n', ';')
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal('One;Eins\nTwo;Zwei\nThree;Drei')
        })
      })

    })

    describe('match', () => {

      it('should work with global match', () => {
        const data = 'The house number one is just beside house number three.'
        const ref = new Reference(data).match(/number (\w+)/g)
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(['number one', 'number three'])
        })
      })

      it('should work with single match', () => {
        const data = 'The house number one is just beside house number three.'
        const ref = new Reference(data).match(/number (\w+)/)
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(['number one', 'one'])
        })
      })

    })

    describe('range', () => {

      it('should work with single element', () => {
        const data = [10, 11, 12, 13, 14, 15]
        const ref = new Reference(data).range([1], [3])
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal([11, 13])
        })
      })

      it('should work with range', () => {
        const data = [10, 11, 12, 13, 14, 15]
        const ref = new Reference(data).range([1, 4])
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal([11, 12, 13])
        })
      })

      it('should work with open end', () => {
        const data = [10, 11, 12, 13, 14, 15]
        const ref = new Reference(data).range([3, 0])
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal([13, 14, 15])
        })
      })

      it('should work with negatives', () => {
        const data = [10, 11, 12, 13, 14, 15]
        const ref = new Reference(data).range([-3, -1])
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal([13, 14])
        })
      })

    })

    describe('filter', () => {

      it('should work with list', () => {
        const data = ['number one', 'number two', 'number three', 'number four']
        const ref = new Reference(data).filter('number three', 'number four', 'number five')
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(['number three', 'number four'])
        })
      })

      it('should work with regular expression', () => {
        const data = ['number one', 'number two', 'number three', 'number four']
        const ref = new Reference(data).filter(/ t/)
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(['number two', 'number three'])
        })
      })

    })

    describe('exclude', () => {

      it('should work with list', () => {
        const data = ['number one', 'number two', 'number three', 'number four']
        const ref = new Reference(data).exclude('number three', 'number four', 'number five')
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(['number one', 'number two'])
        })
      })

      it('should work with regular expression', () => {
        const data = ['number one', 'number two', 'number three', 'number four']
        const ref = new Reference(data).exclude(/ t/)
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal(['number one', 'number four'])
        })
      })

    })

    describe('parse', () => {

      it('should work with yaml', () => {
        const data = 'name: Albert\nage: 21'
        const ref = new Reference(data).parse() // autodetect
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal({ name: 'Albert', age: 21 })
        })
      })

    })

    describe('fn', () => {

      it('should work', () => {
        const crop = (data) => {
          if (typeof data !== 'string') return data
          return data.substring(0, 8) // crop to 8 characters
        }
        const data = 'The large title to be reduced'
        const ref = new Reference(data).fn(crop)
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal('The larg')
        })
      })

    })

    describe('or', () => {

      it('should use sub reference', () => {
        const data = undefined
        const ref = new Reference(data).or(new Reference('default'))
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal('default')
        })
      })

      it('should forget sub reference', () => {
        const data = 'start'
        const ref = new Reference(data).or(new Reference('default'))
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal('start')
        })
      })

    })

    describe('concat', () => {

      it('should work with array', () => {
        const data = [1, 2, 3]
        const ref = new Reference(data).concat(new Reference([6, 7, 8]))
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal([1, 2, 3, 6, 7, 8])
        })
      })

      it('should work with object', () => {
        const data = { name: 'alfons', age: 32 }
        const ref = new Reference(data).concat(new Reference({ age: 35, country: 'germany' }))
        return helper.reference(ref, undefined, (res) => {
          expect(res).deep.equal({ name: 'alfons', age: 35, country: 'germany' })
        })
      })

    })

  })


})
