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

  it('should work without specification', () => {
    const data = new Date()
    const schema = new MySchema()
    expect(schema).to.be.an('object')
    // use schema
    return helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(data)
    })
  })

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.be.a('string')
  })

  describe('parsing', () => {

    it('should allow ISO 8601 date', () => {
      const schema = new MySchema()
      let p = Promise.resolve()
      for (const e of [
        ['2013-02-08', new Date('2013-02-08 00:00')],
        ['2013-W06-5', new Date('2013-02-08 00:00')],
        ['2013-039', new Date('2013-02-08 00:00')],
      ]) {
        p = p.then(() => helper.validateOk(schema, e[0], res => expect(res).deep.equal(e[1])))
      }
      return p
    })

    it('should allow date with time', () => {
      const schema = new MySchema()
      let p = Promise.resolve()
      for (const e of [
        ['2013-02-08 09', new Date('2013-02-08 09:00')],
        ['2013-02-08T09', new Date('2013-02-08 09:00')],
        ['2013-02-08 09:30', new Date('2013-02-08 09:30')],
        ['2013-02-08T09:30', new Date('2013-02-08 09:30')],
        ['2013-02-08 09:30:26', new Date('2013-02-08 09:30:26')],
        ['2013-02-08T09:30:26', new Date('2013-02-08 09:30:26')],
        ['2013-02-08 09:30:26.123', new Date('2013-02-08 09:30:26.123')],
        ['2013-02-08 24:00:00.00', new Date('2013-02-09 00:00:0')],
      ]) {
        p = p.then(() => helper.validateOk(schema, e[0], res => expect(res).deep.equal(e[1])))
      }
      return p
    })

    it('should allow only time', () => {
      const schema = new MySchema()
      let p = Promise.resolve()
      for (const e of [
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
      ]) {
        p = p.then(() => helper.validateOk(schema, e[0], res => expect(res).deep.equal(e[1])))
      }
      return p
    })

    it('should allow date parts with time', () => {
      const schema = new MySchema()
      let p = Promise.resolve()
      for (const e of [
        ['2013-02-08 09', new Date('2013-02-08 09:00')],
        ['2013-W06-5 09', new Date('2013-02-08 09:00')],
        ['2013-039 09', new Date('2013-02-08 09:00')],
      ]) {
        p = p.then(() => helper.validateOk(schema, e[0], res => expect(res).deep.equal(e[1])))
      }
      return p
    })

    it('should allow date with time and timezone', () => {
      const schema = new MySchema()
      let p = Promise.resolve()
      for (const e of [
        ['2013-02-08 09+07:00', new Date('2013-02-08 02:00Z')],
        ['2013-02-08 09-0100', new Date('2013-02-08 10:00Z')],
        ['2013-02-08 09Z', new Date('2013-02-08 09:00Z')],
        ['2013-02-08 09:30:26.123+07:00', new Date('2013-02-08 02:30:26.123Z')],
      ]) {
        p = p.then(() => helper.validateOk(schema, e[0], res => expect(res).deep.equal(e[1])))
      }
      return p
    })

  })

  describe('natural language', () => {

    it('should allow reference names', () => {
      const schema = new MySchema()
      let p = Promise.resolve()
      for (const e of [
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
      ]) {
        p = p.then(() => helper.validateOk(schema, e[0], res => expect(res).deep.equal(e[1])))
      }
      return p
    })

    it('should allow named dates', () => {
      const schema = new MySchema()
      let p = Promise.resolve()
      for (const e of [
        ['17 August 2013', new Date('2013-08-17 12:00')],
        ['19 Aug 2013', new Date('2013-08-19 12:00')],
        ['20 Aug. 2013', new Date('2013-08-20 12:00')],
      ]) {
        p = p.then(() => helper.validateOk(schema, e[0], res => expect(res).deep.equal(e[1])))
      }
      return p
    })

    it('should allow named dates with time', () => {
      const schema = new MySchema()
      let p = Promise.resolve()
      for (const e of [
        ['Sat Aug 17 2013 18:40:39 GMT+0900 (JST)', new Date('2013-08-17 09:40:39Z')],
      ]) {
        p = p.then(() => helper.validateOk(schema, e[0], res => expect(res).deep.equal(e[1])))
      }
      return p
    })

    it('should allow relative date', () => {
      const schema = new MySchema()
      let p = Promise.resolve()
      for (const e of [
        ['This Friday at 13:00', moment(new Date()).day(5).hour(13).minute(0)
          .second(0)
          .millisecond(0)
          .toDate()],
        ['5 days ago', moment(new Date()).subtract(5, 'days').hour(12).minute(0)
          .second(0)
          .millisecond(0)
          .toDate()],
      ]) {
        p = p.then(() => helper.validateOk(schema, e[0], res => expect(res).deep.equal(e[1])))
      }
      return p
    })

    it('should allow now', () => {
      const schema = new MySchema()
      return helper.validateOk(schema, 'now', (res) => {
        const now = new Date().getTime()
        expect(res.getTime()).to.be.within(now - 1000, now)
      })
    })

  })

  describe('timezone', () => {

    it('should work', () => {
      const schema = new MySchema().timezone('EST')
      let p = Promise.resolve()
      for (const e of [
        ['2013-02-08 09', new Date('2013-02-08 14:00 GMT')],
        ['2013-02-08T09', new Date('2013-02-08 14:00 GMT')],
        ['2013-02-08 09:30', new Date('2013-02-08 14:30 GMT')],
        ['2013-02-08T09:30', new Date('2013-02-08 14:30 GMT')],
        ['2013-02-08 09:30:26', new Date('2013-02-08 14:30:26 GMT')],
        ['2013-02-08T09:30:26', new Date('2013-02-08 14:30:26 GMT')],
        ['2013-02-08 09:30:26.123', new Date('2013-02-08 14:30:26.123 GMT')],
        ['2013-02-08 24:00:00.00', new Date('2013-02-09 05:00:00 GMT')],
      ]) {
        p = p.then(() => helper.validateOk(schema, e[0], res => expect(res).deep.equal(e[1])))
      }
      return p
    })

    it('should allow full name', () => {
      const schema = new MySchema().timezone('Eastern Standard Time')
      return helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2013-02-08 14:30 GMT'))
      })
    })

    it('should remove', () => {
      const schema = new MySchema().timezone('EST').timezone()
      return helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2013-02-08 09:30'))
      })
    })

    it('should allow reference', () => {
      const ref = new Reference('EST')
      const schema = new MySchema().timezone(ref)
      return helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2013-02-08 14:30 GMT'))
      })
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

    it('should work with min', () => {
      const schema = new MySchema().min('2013-01-01 00:00')
      return helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2013-02-08 09:30'))
      })
    })

    it('should fail with min', () => {
      const schema = new MySchema().min('2013-01-01 00:00')
      return helper.validateFail(schema, '2012-02-08 09:30', undefined)
    })

    it('should remove min', () => {
      const schema = new MySchema().min('2013-01-01 00:00').min()
      return helper.validateOk(schema, '2012-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2012-02-08 09:30'))
      })
    })

    it('should fail with min as reference', () => {
      const ref = new Reference('2013-01-01 00:00')
      const schema = new MySchema().min(ref)
      return helper.validateFail(schema, '2012-02-08 09:30', undefined)
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

    it('should work with max', () => {
      const schema = new MySchema().max('2013-01-01 00:00')
      return helper.validateOk(schema, '2012-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2012-02-08 09:30'))
      })
    })

    it('should fail with max', () => {
      const schema = new MySchema().max('2013-01-01 00:00')
      return helper.validateFail(schema, '2013-02-08 09:30', undefined)
    })

    it('should remove max', () => {
      const schema = new MySchema().max('2013-01-01 00:00').max()
      return helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2013-02-08 09:30'))
      })
    })

    it('should fail with max as reference', () => {
      const ref = new Reference('2012-01-01 00:00')
      const schema = new MySchema().max(ref)
      return helper.validateFail(schema, '2013-02-08 09:30', undefined)
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

    it('should work with greater', () => {
      const schema = new MySchema().greater('2013-01-01 00:00')
      return helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2013-02-08 09:30'))
      })
    })

    it('should fail with greater', () => {
      const schema = new MySchema().greater('2013-01-01 00:00')
      return helper.validateFail(schema, '2012-02-08 09:30', undefined)
    })

    it('should remove greater', () => {
      const schema = new MySchema().greater('2013-01-01 00:00').greater()
      return helper.validateOk(schema, '2012-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2012-02-08 09:30'))
      })
    })

    it('should fail with greater as reference', () => {
      const ref = new Reference('2013-01-01 00:00')
      const schema = new MySchema().greater(ref)
      return helper.validateFail(schema, '2012-02-08 09:30', undefined)
    })

    it('should describe greater', () => {
      const schema = new MySchema().greater('2013-01-01 00:00')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe greater with reference', () => {
      const ref = new Reference('2013-01-01 00:00')
      const schema = new MySchema().greater(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with less', () => {
      const schema = new MySchema().less('2013-01-01 00:00')
      return helper.validateOk(schema, '2012-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2012-02-08 09:30'))
      })
    })

    it('should fail with less', () => {
      const schema = new MySchema().less('2013-01-01 00:00')
      return helper.validateFail(schema, '2013-02-08 09:30', undefined)
    })

    it('should remove less', () => {
      const schema = new MySchema().less('2013-01-01 00:00').less()
      return helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2013-02-08 09:30'))
      })
    })

    it('should fail with less as reference', () => {
      const ref = new Reference('2012-01-01 00:00')
      const schema = new MySchema().less(ref)
      return helper.validateFail(schema, '2013-02-08 09:30', undefined)
    })

    it('should describe less', () => {
      const schema = new MySchema().less('2013-01-01 00:00')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe less with reference', () => {
      const ref = new Reference('2013-01-01 00:00')
      const schema = new MySchema().less(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('format', () => {

    it('should work', () => {
      const schema = new MySchema().format('YYYY-MM-DD HH:mm:ss')
      return helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal('2013-02-08 09:30:00')
      })
    })

    it('should remove', () => {
      const schema = new MySchema().format('YYYY-MM-DD HH:mm:ss').format()
      return helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal(new Date('2013-02-08 09:30'))
      })
    })

    it('should allow reference', () => {
      const ref = new Reference('YYYY-MM-DD HH:mm:ss')
      const schema = new MySchema().format(ref)
      return helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal('2013-02-08 09:30:00')
      })
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

    it('should work', () => {
      const schema = new MySchema().toLocale('de').format('LLL')
      return helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal('8. Februar 2013 09:30')
      })
    })

    it('should remove', () => {
      const schema = new MySchema().toLocale('de').format('LLL').toLocale()
      return helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal('February 8, 2013 9:30 AM')
      })
    })

    it('should allow reference', () => {
      const ref = new Reference('de')
      const schema = new MySchema().toLocale(ref).format('LLL')
      return helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal('8. Februar 2013 09:30')
      })
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

    it('should work', () => {
      const schema = new MySchema().timezone('GMT').toTimezone('EST').format('LLL')
      return helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal('February 8, 2013 4:30 AM')
      })
    })

    it('should remove', () => {
      const schema = new MySchema().timezone('GMT').toTimezone('EST').toTimezone()
        .format('LLL')
      return helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal('February 8, 2013 9:30 AM')
      })
    })

    it('should work with reference', () => {
      const ref = new Reference('EST')
      const schema = new MySchema().timezone('GMT').toTimezone(ref).format('LLL')
      return helper.validateOk(schema, '2013-02-08 09:30', (res) => {
        const now = new Date().getTime()
        expect(res).to.deep.equal('February 8, 2013 4:30 AM')
      })
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
