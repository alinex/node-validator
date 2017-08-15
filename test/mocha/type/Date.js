// @flow
import chai from 'chai'
import async from 'async'
import moment from 'moment'

import Reference from '../../../src/Reference'
import DateSchema from '../../../src/DateSchema'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = DateSchema

describe('date', () => {

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
        ['9:30', moment(new Date()).hour(9).minute(30).second(0)
          .millisecond(0)
          .toDate()],
        ['09:30', moment(new Date()).hour(9).minute(30).second(0)
          .millisecond(0)
          .toDate()],
        ['09:30:26', moment(new Date()).hour(9).minute(30).second(26)
          .millisecond(0)
          .toDate()],
        ['24:00:00', moment(new Date()).hour(24).minute(0).second(0)
          .millisecond(0)
          .toDate()],
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
        ['today', moment(new Date()).hour(12).minute(0).second(0)
          .millisecond(0)
          .toDate()],
        ['tomorrow', moment(new Date()).add(1, 'day').hour(12).minute(0)
          .second(0)
          .millisecond(0)
          .toDate()],
        ['yesterday', moment(new Date()).subtract(1, 'day').hour(12).minute(0)
          .second(0)
          .millisecond(0)
          .toDate()],
        ['last friday', moment(new Date()).subtract(7, 'days').day(5).hour(12)
          .minute(0)
          .second(0)
          .millisecond(0)
          .toDate()],
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
          .second(0)
          .millisecond(0)
          .toDate()],
        ['5 days ago', moment(new Date()).subtract(5, 'days').hour(12).minute(0)
          .second(0)
          .millisecond(0)
          .toDate()],
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

  describe('timezone', () => {

    it('should work', (done) => {
      const schema = new MySchema().timezone('EST')
      async.eachSeries([
        ['2013-02-08 09', new Date('2013-02-08 14:00 GMT')],
        ['2013-02-08T09', new Date('2013-02-08 14:00 GMT')],
        ['2013-02-08 09:30', new Date('2013-02-08 14:30 GMT')],
        ['2013-02-08T09:30', new Date('2013-02-08 14:30 GMT')],
        ['2013-02-08 09:30:26', new Date('2013-02-08 14:30:26 GMT')],
        ['2013-02-08T09:30:26', new Date('2013-02-08 14:30:26 GMT')],
        ['2013-02-08 09:30:26.123', new Date('2013-02-08 14:30:26.123 GMT')],
        ['2013-02-08 24:00:00.00', new Date('2013-02-09 05:00:00 GMT')],
      ], (check, cb) => {
        helper.validateOk(schema, check[0], (res) => {
          expect(res).deep.equal(check[1])
        }, cb)
      }, done)
    })

    it('should allow full name', (done) => {
      const schema = new MySchema().timezone('Eastern Standard Time')
      helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2013-02-08 14:30 GMT'))
      }, done)
    })

    it('should remove', (done) => {
      const schema = new MySchema().timezone('EST').timezone()
      helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2013-02-08 09:30'))
      }, done)
    })

    it('should allow reference', (done) => {
      const ref = new Reference('EST')
      const schema = new MySchema().timezone(ref)
      helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2013-02-08 14:30 GMT'))
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema().timezone('EST')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference('EST')
      const schema = new MySchema().timezone(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('range', () => {

    it('should work with min', (done) => {
      const schema = new MySchema().min('2013-01-01 00:00')
      helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2013-02-08 09:30'))
      }, done)
    })

    it('should fail with min', (done) => {
      const schema = new MySchema().min('2013-01-01 00:00')
      helper.validateFail(schema, '2012-02-08 09:30', undefined, done)
    })

    it('should remove min', (done) => {
      const schema = new MySchema().min('2013-01-01 00:00').min()
      helper.validateOk(schema, '2012-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2012-02-08 09:30'))
      }, done)
    })

    it('should fail with min as reference', (done) => {
      const ref = new Reference('2013-01-01 00:00')
      const schema = new MySchema().min(ref)
      helper.validateFail(schema, '2012-02-08 09:30', undefined, done)
    })

    it('should describe min', () => {
      const schema = new MySchema().min('2013-01-01 00:00')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe min with reference', () => {
      const ref = new Reference('2013-01-01 00:00')
      const schema = new MySchema().min(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with max', (done) => {
      const schema = new MySchema().max('2013-01-01 00:00')
      helper.validateOk(schema, '2012-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2012-02-08 09:30'))
      }, done)
    })

    it('should fail with max', (done) => {
      const schema = new MySchema().max('2013-01-01 00:00')
      helper.validateFail(schema, '2013-02-08 09:30', undefined, done)
    })

    it('should remove max', (done) => {
      const schema = new MySchema().max('2013-01-01 00:00').max()
      helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2013-02-08 09:30'))
      }, done)
    })

    it('should fail with max as reference', (done) => {
      const ref = new Reference('2012-01-01 00:00')
      const schema = new MySchema().max(ref)
      helper.validateFail(schema, '2013-02-08 09:30', undefined, done)
    })

    it('should describe max', () => {
      const schema = new MySchema().max('2013-01-01 00:00')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe max with reference', () => {
      const ref = new Reference('2013-01-01 00:00')
      const schema = new MySchema().max(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('format', () => {

    it('should work', (done) => {
      const schema = new MySchema().format('YYYY-MM-DD HH:mm:ss')
      helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal('2013-02-08 09:30:00')
      }, done)
    })

    it('should remove', (done) => {
      const schema = new MySchema().format('YYYY-MM-DD HH:mm:ss').format()
      helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2013-02-08 09:30'))
      }, done)
    })

    it('should allow reference', (done) => {
      const ref = new Reference('YYYY-MM-DD HH:mm:ss')
      const schema = new MySchema().format(ref)
      helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal('2013-02-08 09:30:00')
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema().format('YYYY-MM-DD HH:mm:ss')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference('YYYY-MM-DD HH:mm:ss')
      const schema = new MySchema().format(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('toLocale', () => {

    it('should work', (done) => {
      const schema = new MySchema().toLocale('de').format('LLL')
      helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal('8. Februar 2013 09:30')
      }, done)
    })

    it('should remove', (done) => {
      const schema = new MySchema().toLocale('de').format('LLL').toLocale()
      helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal('February 8, 2013 9:30 AM')
      }, done)
    })

    it('should allow reference', (done) => {
      const ref = new Reference('de')
      const schema = new MySchema().toLocale(ref).format('LLL')
      helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal('8. Februar 2013 09:30')
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema().toLocale('de').format('LLL')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference('de')
      const schema = new MySchema().toLocale(ref).format('LLL')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('toTimezone', () => {

    it('should work', (done) => {
      const schema = new MySchema().timezone('GMT').toTimezone('EST').format('LLL')
      helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal('February 8, 2013 4:30 AM')
      }, done)
    })

    it('should remove', (done) => {
      const schema = new MySchema().timezone('GMT').toTimezone('EST').toTimezone()
        .format('LLL')
      helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal('February 8, 2013 9:30 AM')
      }, done)
    })

    it('should work with reference', (done) => {
      const ref = new Reference('EST')
      const schema = new MySchema().timezone('GMT').toTimezone(ref).format('LLL')
      helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal('February 8, 2013 4:30 AM')
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema().toTimezone('EST').format('LLL')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference('EST')
      const schema = new MySchema().toTimezone(ref).format('LLL')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
