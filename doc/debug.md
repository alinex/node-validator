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
