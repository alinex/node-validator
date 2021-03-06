// @flow
import * as val from './builder'

const presets = {
  // text
  word: () => new val.String().notMatch(/\s/).min(1),
  character: () => new val.String().length(1),
  md5: () => new val.String().lowerCase().match(/^[a-f0-9]{32}$/),
  sha1: () => new val.String().lowerCase().match(/^[a-f0-9]{40}$/),
  sha256: () => new val.String().lowerCase().match(/^[a-f0-9]{64}$/),
  // network
  hostOrIP: () => new val.Logic()
    .allow(new val.Domain())
    .or(new val.IP()),
  // country specific
  plz: () => new val.Number().positive().max(99999).format('00000'),
}

export default presets
