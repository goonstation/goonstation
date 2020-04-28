# Goonstation Code Guide

[ToC]

## General

### Operators
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

#### Spaces after control statements

See: `if(x)` vs `if (x)`

Nobody cares about this. This is heavily frowned upon for changing with little to no reason.

### Whack BYOND shit

#### Startup/Runtime trade-offs with lists and the "hidden" init() proc

First, read the comments in [this BYOND thread](http://www.byond.com/forum/post/2086980?page=2#comment19776775).

There are two key points there:

* Defining a list in the variable's definition calls a hidden proc: init(). If you have to define a list at startup, do so in New() and avoid the overhead of a second call (Init() and then New())
* It also consumes more memory to the point where the list is actually required, even if the object in question may never use it!

Remember: although this trade-off makes sense in many cases, it doesn't cover them all. Think carefully about your addition before deciding if you need to use it.


#### for-in-to loops

`for (var/i = 1, i <= some_value, i++)` is the standard way to write a for loop in most languages, but DM's `for(var/i in 1 to some_value)` syntax is actually faster in its implementation.

So, where possible, it's advised to use DM's syntax. (Note: the to keyword is inclusive, so it automatically defaults to replacing `<=`; if you want `<` then you should write it as `1 to some_value-1`).

**Be Warned:** if either `some_value` or `i` changes within the body of the for (underneath the `for(...)`) or if you are looping over a list and changing the length of the list then you cannot use this type of for-loop!

#### Default Return (`.`)

Like other languages in the C family, DM has a `.` or "dot" operator, used for accessing variables/members/functions of an object instance. For example:

```javascript
var/mob/M = foo
M.gib()
```

However, DM also has a dot variable, accessed just as `.` on its own, defaulting to a value of null. Now, what's special about the dot operator is that it is automatically returned (as in the return statement) at the end of a proc, provided the proc does not already manually return (e.g. `return x`)

With `.` being present in every proc, we use it as a temporary variable. However, the `.` operator cannot replace a typecasted variable - it can hold data any other var in DM can, it just can't be accessed as one, although the `.` operator is compatible with a few operators that look weird but work perfectly fine, such as: `.++` for incrementing `.`'s value.

#### global vs static variable keyword

DM has a variable keyword, called `global`. This var keyword is for vars inside of types. For instance:
```javascript
/mob/var/global/foo = TRUE
```
This does **not** mean that you can access it everywhere like a global var. Instead, it means that that var will only exist once for all instances of its type, in this case that var will only exist once for all mobs - it's shared across everything in its type. (Much more like the keyword `static` in other languages like PHP/C++/C#/Java)

Isn't that confusing?

There is also an undocumented keyword called `static` that has the same behavior as global but more correctly describes DM's behavior. Therefore, always use `static` instead of `global` in variables, as it reduces surprise when reading code.

## Useful Things

### VSCode Debugger

### Debugging Overlays

### Profiler

### Target Dummy
* You can spawn in a target dummy (`/mob/living/carbon/human/tdummy`) to more easily test things that do damage - they have the ass day health percent and damage popups visible even if your build isn't set to ass day.