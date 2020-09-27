# Garry's Mod Async
A basic async library for Garry's Mod. Written in MoonScript, must be compiled for use in the game.

# Usage
Usage is fairly simple. This library uses JavaScript-like Promises, but you won't need to instantiate them directly.

All functions are stored in the global `Async` by default. You can ensure thie global exists with `require 'async'`.

To use this module, you will need to compile lua/includes/modules/async.moon using moonc. You can find instructions on installing the Moonscript compiler [here](https://moonscript.org/#installation).

### Creating a Promise
This is easy! In either Lua or MoonScript, you can pass `Async.async` a function to create a promise easily. For example:

```
    import async from Async
    fn = async -> 
        print 'hey'
        return 'ho'
    
    fn()\andThen (data) ->
        print data
```

(or, in Lua, a bit less pretty)

```
    local async = Async.async
    
    local fn = async(function()
        print('hey')
    end)

    fn():andThen(function()
        print('ho')
    end)
```

These would both produce the following output:

```
hey
ho
```

Note that this is non-blocking, and will not run inline. This is by design, to finish in a thread before continuing with the promise.

The function passed will be run initially next tick, and if it returns data or errors, the promise will immediately resolve. Since the first function returns right away, the `andThen` will be called right away. Otherwise...

### fulfill!
Within any asynchronous function, you have access to the fulfill() function without needing to declare it. You can use it to fulfill Promises in the future, running their `andThen`s at an arbitrary later date. This is fairly standard if you've used promises before. I've included an example below:

```
    import async from Async
    fn = async -> 
        timer.Simple 1, fulfill
    
    fn()\andThen -> 
        print 'ho'
    
    print 'hey'
```

This will print `hey`, as expected, then, a second later when the function resolves, print `ho`. Any arguments passed to `fulfill` will be passed to the function registered under `andThen` if the initial Promise doesn't return. 

Notable is that a Promise cannot resolve more than once. This means if you return something, then call `fulfill` later, the `andThen` chain will not be run again.

### reject!
Similar to `fulfill`, except will run the `onError` chain. Not much more needs said, it functions identically to `fulfill`, except it only runs on initial error, or if called directly.

### andThen
Discussed in `fulfill`, any functions in the `andThen` chain are called when a Promise returns a value initially, or when `fulfill` is called. Accepts a single function argument.

### onError
Discussed in `reject`, called when this is called, or when the Promise initially errors out. Also accepts a single function argument.

### butAlways
This runs the first time the Promise initially returns a value or errors out, or is `fulfill`ed or `reject`ed. Functions in this chain are *not* passed any arguments from either of these function, but always run after the Promise resolves.

### Chaining
Not super necessary in MoonScript, since it has `with`, but included for Lua users. Any time you call `andThen`, `onError`, or `butAlways`, the functions will return their parent object, allowing chaining. For example, the following code works as expected in Lua:

```
    local async = Async.async
    local fn = async(function()
        return true
    end)
    fn:andThen(function() print(1) end)
      :andThen(function() print(2) end)
      :onError(function() print('Something went wrong') end)
      :butAlways(function() print('It's all over now') end)
```

And would output in the order registered, `andThen` or `onError` first, then `butAlways`. In this case:


```
1
2
It's all over now
```
