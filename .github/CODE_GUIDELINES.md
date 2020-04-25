# Goonstation Code Guide

[ToC]

## General

### Bad Operators
* Don't use `goto`. Bad.
* Don't use the `:` operator to override type safety checks. Instead, cast the variable to the proper type.

### Procs To Use

* Use `SPAWN_DBG()` instead of `spawn()`
* Use `TIME` instead of `world.timeofday`

### Syntax

#### Use early returns

We don't want dozens of nesting levels, don't enclose a proc inside an if block if you can just return on a condition instead.

Bad: 
```
obj/test/proc/coolstuff()
    if (foo)
        if (!bar)
            if (baz == 420)
                do_stuff
```
Good: 
```
obj/test/proc/coolstuff()
    if (!foo || bar)
        return
    if (baz == "error_code")
        return
    do_stuff
```

### Whack BYOND shit

#### Startup/Runtime trade-offs with lists and the "hidden" init() proc

First, read the comments in [this BYOND thread](http://www.byond.com/forum/post/2086980?page=2#comment19776775).

There are two key points there:

* Defining a list in the variable's definition calls a hidden proc: init(). If you have to define a list at startup, do so in New() and avoid the overhead of a second call (Init() and then New())
* It also consumes more memory to the point where the list is actually required, even if the object in question may never use it!

Remember: although this trade-off makes sense in many cases, it doesn't cover them all. Think carefully about your addition before deciding if you need to use it.

## Useful Things

### VSCode Debugger

### Debugging Overlays

### Profiler

### Target Dummy
* You can spawn in a target dummy (`/mob/living/carbon/human/tdummy`) to more easily test things that do damage - they have the assday health percent and damage popups visible even if your build isn't set to assday.