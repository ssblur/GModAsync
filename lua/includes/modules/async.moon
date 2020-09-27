--- A promise library in Moonscript.
--  Incredibly basic, implementation is *not* thread-safe.
--  Built initially for Garry's Mod.
--  @author Patrick Emery
promises = {}

class Promise
    STATE:
        PENDING: 1
        FULFILLED: 2
        REJECTED: 3

    new: (f, ...) =>
        if type(f) == @@
            return f
        @state = @@STATE.PENDING
        @f_error = {}
        @f_then = {}
        @f_always = {}
        @data = {}
        @run = false
        @args = {...}
        @f = f

        promises[@] = true
    
    andThen: (f) =>
        @f_then[#@f_then + 1] = f
        @

    onError: (f) =>
        @f_error[#@f_error + 1] = f
        @

    butAlways: (f) =>
        @f_always[#@f_always + 1] = f
        @

    fulfill: (...) =>
        @data = {...}
        @state = @@STATE.FULFILLED

    reject: (...) =>
        @data = {...}
        @state = @@STATE.REJECTED
    
    __tick: =>
        unless @run
            @success, @data = pcall @f, unpack @args
            if @success
                if @data
                    @state = @@STATE.FULFILLED
            else
                @state = @@STATE.REJECTED
            @run = true
        unless @state == @@STATE.PENDING
            promises[@] = nil
            @data = @data or {}
            for _, f in pairs if @state == @@STATE.FULFILLED then @f_then else @f_error
                f unpack @data
            for _, f in *@f_always
                f if state == @@STATE.FULFILLED then unpack @data
    tick: ->
        for p in pairs promises
            p\__tick!
    
PromiseFactory = (f) ->
    -> 
        p = Promise(f)
        env = {
            fulfill: p\fulfill
            reject: p\reject
        }
        setmetatable env, {__index: _G}
        setfenv f, env
        p

--------------------- Garry's Mod Tick Variant. To port this to another context, reimplement the part below. ---------------------
AddCSLuaFile!
timer.Create 'blur_async_promise_tick', 0, 0, ->
    Promise.tick!
export Async = {
    promise: Promise
    async: PromiseFactory
}
--------------------- This bit's over now, the rest is standard.                                             ---------------------

Promise