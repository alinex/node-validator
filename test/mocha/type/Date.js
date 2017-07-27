// @flow
import chai from 'chai'
import async from 'async'
import moment from 'moment'

import { DateSchema, Reference } from '../../../src/index'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = DateSchema

describe.only('string', () => {

  it('should work without specification', (done) => {
    const data = new Date()
    const schema = new MySchema()
    expect(schema).to.be.an('object')
    // use schema
    helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(data)
    }, done)
  })

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.be.a('string')
  })

  describe('parsing', () => {

    it('should allow ISO 8601 date', (done) => {
      const schema = new MySchema()
      async.eachSeries([
        ['2013-02-08', new Date('2013-02-08 00:00')],
        ['2013-W06-5', new Date('2013-02-08 00:00')],
        ['2013-039', new Date('2013-02-08 00:00')],
      ], (check, cb) => {
        helper.validateOk(schema, check[0], (res) => {
          expect(res).deep.equal(check[1])
        }, cb)
      }, done)
    })

    it('should allow date with time', (done) => {
      const schema = new MySchema()
      async.eachSeries([
        ['2013-02-08 09', new Date('2013-02-08 09:00')],
        ['2013-02-08T09', new Date('2013-02-08 09:00')],
        ['2013-02-08 09:30', new Date('2013-02-08 09:30')],
        ['2013-02-08T09:30', new Date('2013-02-08 09:30')],
        ['2013-02-08 09:30:26', new Date('2013-02-08 09:30:26')],
        ['2013-02-08T09:30:26', new Date('2013-02-08 09:30:26')],
        ['2013-02-08 09:30:26.123', new Date('2013-02-08 09:30:26.123')],
        ['2013-02-08 24:00:00.00', new Date('2013-02-09 00:00:0')],
      ], (check, cb) => {
        helper.validateOk(schema, check[0], (res) => {
          expect(res).deep.equal(check[1])
        }, cb)
      }, done)
    })

    it('should allow only time', (done) => {
      const schema = new MySchema()
      async.eachSeries([
         ['9:30', moment(new Date()).hour(9).minute(30).second(0).millisecond(0).toDate()],
         ['09:30', moment(new Date()).hour(9).minute(30).second(0).millisecond(0).toDate()],
         ['09:30:26', moment(new Date()).hour(9).minute(30).second(26).millisecond(0).toDate()],
         ['24:00:00', moment(new Date()).hour(24).minute(0).second(0).millisecond(0).toDate()],
      ], (check, cb) => {
        helper.validateOk(schema, check[0], (res) => {
          expect(res).deep.equal(check[1])
        }, cb)
      }, done)
    })

    it('should allow date parts with time', (done) => {
      const schema = new MySchema()
      async.eachSeries([
        ['2013-02-08 09', new Date('2013-02-08 09:00')],
        ['2013-W06-5 09', new Date('2013-02-08 09:00')],
        ['2013-039 09', new Date('2013-02-08 09:00')],
      ], (check, cb) => {
        helper.validateOk(schema, check[0], (res) => {
          expect(res).deep.equal(check[1])
        }, cb)
      }, done)
    })

    it('should allow date with time and timezone', (done) => {
      const schema = new MySchema()
      async.eachSeries([
        ['2013-02-08 09+07:00', new Date('2013-02-08 02:00Z')],
        ['2013-02-08 09-0100', new Date('2013-02-08 10:00Z')],
        ['2013-02-08 09Z', new Date('2013-02-08 09:00Z')],
        ['2013-02-08 09:30:26.123+07:00', new Date('2013-02-08 02:30:26.123Z')],
      ], (check, cb) => {
        helper.validateOk(schema, check[0], (res) => {
          expect(res).deep.equal(check[1])
        }, cb)
      }, done)
    })

  })

  describe('natural language', () => {

    it('should allow reference names', (done) => {
      const schema = new MySchema()
      async.eachSeries([
        ['today', moment(new Date()).hour(12).minute(0).second(0).millisecond(0).toDate()],
        ['tomorrow', moment(new Date()).add(1, 'day').hour(12).minute(0).second(0)
        .millisecond(0).toDate()],
        ['yesterday', moment(new Date()).subtract(1, 'day').hour(12).minute(0).second(0)
        .millisecond(0).toDate()],
        ['last friday', moment(new Date()).subtract(7, 'days').day(5).hour(12).minute(0)
        .second(0).millisecond(0).toDate()],
      ], (check, cb) => {
        helper.validateOk(schema, check[0], (res) => {
          expect(res).deep.equal(check[1])
        }, cb)
      }, done)
    })

    it('should allow named dates', (done) => {
      const schema = new MySchema()
      async.eachSeries([
        ['17 August 2013', new Date('2013-08-17 12:00')],
        ['19 Aug 2013', new Date('2013-08-19 12:00')],
        ['20 Aug. 2013', new Date('2013-08-20 12:00')],
      ], (check, cb) => {
        helper.validateOk(schema, check[0], (res) => {
          expect(res).deep.equal(check[1])
        }, cb)
      }, done)
    })

    it('should allow named dates with time', (done) => {
      const schema = new MySchema()
      async.eachSeries([
        ['Sat Aug 17 2013 18:40:39 GMT+0900 (JST)', new Date('2013-08-17 09:40:39Z')],
      ], (check, cb) => {
        helper.validateOk(schema, check[0], (res) => {
          expect(res).deep.equal(check[1])
        }, cb)
      }, done)
    })

    it('should allow relative date', (done) => {
      const schema = new MySchema()
      async.eachSeries([
        ['This Friday at 13:00', moment(new Date()).day(5).hour(13).minute(0)
        .second(0).millisecond(0).toDate()],
        ['5 days ago', moment(new Date()).subtract(5, 'days').hour(12).minute(0)
        .second(0).millisecond(0).toDate()],
      ], (check, cb) => {
        helper.validateOk(schema, check[0], (res) => {
          expect(res).deep.equal(check[1])
        }, cb)
      }, done)
    })

    it('should allow now', (done) => {
      const schema = new MySchema()
      helper.validateOk(schema, 'now', (res) => {
        const now = new Date().getTime()
        expect(res.getTime()).to.be.within(now - 1000, now)
      }, done)
    })

  })

})
