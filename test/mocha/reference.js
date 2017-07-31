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

  describe('accessors', () => {

    describe('path', () => {

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

    })

  })

})
