# Debugging

If you have any problems you may debug the code with the predefined flags. It uses the
[debug](https://www.npmjs.com/package/debug) module to let you define what to debug.

Call it with the `DEBUG` environment variable set to the types you want to debug. The most valuable
flags will be:

```bash
DEBUG=validator* validator...  # complete debugging
DEBUG=validator:number validator...  # only display the NumberSchema use
DEBUG=validator:number,validator:string validator...  # or use multiple
```

You can also combine them using comma like in the last example line or use only `DEBUG=*` to show all
debugging from all modules.

Such debugging may look like:

    validator search for data files at /home/alex/github/node-validator/test/mocha/../data/address-ok.yml +0ms
    validator found data file at /home/alex/github/node-validator/test/data/address-ok.yml +12ms
    validator:object { title: 'Dr.',
    validator:object   name: 'Alfons Ranze',
    validator:object   street: 'Im Heubach 3',
    validator:object   plz: 10565,
    validator:object   city: 'Berlin' } +0ms
    validator:object    ObjectSchema { keys:
    validator:object         Map {
    validator:object           'title' => StringSchema { allow: [Object] } ,
    validator:object           'name' => StringSchema { min: 3, required: true } ,
    validator:object           'street' => StringSchema { min: 3, required: true } ,
    validator:object           'plz' => NumberSchema { required: true,
    validator:object                negative: false,
    validator:object                positive: true,
    validator:object                max: 99999,
    validator:object                format: '00000' } ,
    validator:object           'city' => StringSchema { required: true, min: 3 }  } }  +1ms
    validator:string Data at /home/alex/github/node-validator/test/mocha/../data/address-ok.yml/title 'Dr.'  +0ms
    validator:string    StringSchema { allow: Set { 'Dr.', 'Prof.' } }  +1ms
    validator:string Data at /home/alex/github/node-validator/test/mocha/../data/address-ok.yml/name 'Alfons Ranze'  +0ms
    validator:string    StringSchema { min: 3, required: true }  +1ms
    validator:string Data at /home/alex/github/node-validator/test/mocha/../data/address-ok.yml/street 'Im Heubach 3'  +0ms
    validator:string    StringSchema { min: 3, required: true }  +0ms
    validator:number Data at /home/alex/github/node-validator/test/mocha/../data/address-ok.yml/plz 10565  +0ms
    validator:number    NumberSchema { required: true,
    validator:number        negative: false,
    validator:number        positive: true,
    validator:number        max: 99999,
    validator:number        format: '00000' }  +0ms
    validator:string Data at /home/alex/github/node-validator/test/mocha/../data/address-ok.yml/city 'Berlin'  +0ms
    validator:string    StringSchema { required: true, min: 3 }  +0ms
    validator:number => Data at /home/alex/github/node-validator/test/mocha/../data/address-ok.yml/plz '10565'  +3ms
    validator:string => Data at /home/alex/github/node-validator/test/mocha/../data/address-ok.yml/title 'Dr.'  +4ms
    validator:string => Data at /home/alex/github/node-validator/test/mocha/../data/address-ok.yml/name 'Alfons Ranze'  +3ms
    validator:string => Data at /home/alex/github/node-validator/test/mocha/../data/address-ok.yml/street 'Im Heubach 3'  +3ms
    validator:string => Data at /home/alex/github/node-validator/test/mocha/../data/address-ok.yml/city 'Berlin'  +3ms
    validator:object => Data at /home/alex/github/node-validator/test/mocha/../data/address-ok.yml { title: 'Dr.',
    validator:object   name: 'Alfons Ranze',
    validator:object   street: 'Im Heubach 3',
    validator:object   plz: '10565',
    validator:object   city: 'Berlin' }  +7ms
