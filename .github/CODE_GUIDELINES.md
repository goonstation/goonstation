# Goonstation Code Guide

[ToC]

## General

## Operators
* Don't use `goto`. Bad.
* Don't use the `:` operator to override type safety checks. Instead, cast the variable to the proper type.

## Procs To Use

* Use `SPAWN_DBG()` instead of `spawn()`
* Use `TIME` instead of `world.timeofday`
* Bitflags (`&`) - Write as `bitfield & bitflag`

## Syntax

### Defines to use

#### Time Defines

The codebase contains some defines (e.g. `SECONDS`) which will automatically multiply a number by the correct amount to get a number in deciseconds. Using these is preferred over using a literal amount in deciseconds.

#### SI Units

The codebase also has defines for other SI units, such as `WATTS`. There are also SI unit prefixes for use, such as `MILLI`. These should be used whenever you're dealing with a quantity that's a SI unit. If you're using a derived unit, add its formula to the defines. These can be chained like so: `100 MILLI WATTS` or `1 KILO METER`.

### No magic numbers

Don't use numbers that have no explanation behind them. Instead, it's reccomended that you either put it into a const variable, a local file #define, or a global #define. For example,
```javascript
proc/do_stuff(thing)
	switch(thing)
		if(0)
			stuff
		if(1)
			other stuff
```

Do this instead:

```javascript
#define DO_THING_CORRECT 0
#define DO_THING_OTHER 1
proc/do_stuff(thing)
	switch(thing)
		if(DO_THING_CORRECT)
		    stuff
		if(DO_THING_OTHER)
			other stuff
```

### Use early returns

We don't want dozens of nesting levels, don't enclose a proc inside an if block if you can just return on a condition instead.

Bad: 
```javascript
obj/test/proc/coolstuff()
    if (foo)
        if (!bar)
            if (baz == 420)
                do_stuff
```
Good: 
```javascript
obj/test/proc/coolstuff()
    if (!foo || bar)
        return
    if (baz == "error_code")
        return
    do_stuff
```

### Spaces after control statements

See: `if(x)` vs `if (x)`

Nobody cares about this. This is heavily frowned upon for changing with little to no reason.

### Abstract types and typesof

Some types exist just as a parent and should never be created in-game (e.g. `/obj/item`). Mark those using the `ABSTRACT_TYPE(type)` macro. You can check if a type is abstract using the `IS_ABSTRACT(type)` macro.

To get a list of all concrete (non-abstract) subtypes of a type you should use `concrete_typesof(type)`, the result is cached so no need to store it yourself. (As a consequence please `.Copy` the list if you want to make changes to it locally.) Proper usage of `ABSTRACT_TYPE` + `concrete_typesof` is preferred to using `typesof` and `childrentypesof` *usually* though exceptions apply.

If you want to filter the results of `concrete_typesof` further (e.g. by the value of a var or by a blacklist) consider using `filtered_concrete_typesof(type, filter)`. `filter` is a proc that should return 1 if you want to include the item. Again, the result is cached (so the `filter` proc should not depend on outisde variables or randomness).

Example:
```javascript
ABSTRACT_TYPE(/obj/item/hat)
/obj/item/hat
	var/is_cool = 0

/obj/item/hat/uncool
	name = "Uncool Hat"

/obj/item/hat/cool
	name = "Cool hat"
	is_cool = 1

proc/is_hat_cool(hat_type)
	var/obj/item/hat/hat = hat_type
	return initial(hat.is_cool)

proc/random_cool_hat()
	return pick(filtered_concrete_typesof(/obj/item/hat, /proc/is_hat_cool))
```

See `_stdlib/_types.dm` for details.

## Whack BYOND shit

### Startup/Runtime trade-offs with lists and the "hidden" init() proc

First, read the comments in [this BYOND thread](http://www.byond.com/forum/post/2086980?page=2#comment19776775).

There are two key points there:

* Defining a list in the variable's definition calls a hidden proc: init(). If you have to define a list at startup, do so in New() and avoid the overhead of a second call (Init() and then New())
* It also consumes more memory to the point where the list is actually required, even if the object in question may never use it!

Remember: although this trade-off makes sense in many cases, it doesn't cover them all. Think carefully about your addition before deciding if you need to use it.

### typecheckless for-loops

When dealing with iterating over lists, you generally have two cases: where a list will only contain one type, and where a list will contain a multitude of types.

For the _first case_, we can do some special optimization, in what we call a "typecheckless for-loop."

The syntax looks like this:
```js
for (var/obj/foo/bar as() in my_list)
	bar.boogie()
```

This ends up giving us a 50% increase in speed, as with a normal typed for-loop it performs an `istype(thing, obj/foo)` on the object every iteration.

**Be warned:** If something in the list is not of the type provided, it will runtime!

*Additional note*: If you are using `by_type[]`, there exists a macro to do this automagically:
```js
for_by_tcl(iterator, type)
	loop stuff
```
As long as you don't want to filter out between specific children types of a by_type, you should be able to use this construction.

### for-in-to loops

`for (var/i = 1, i <= some_value, i++)` is the standard way to write a for-loop in most languages, but DM's `for(var/i in 1 to some_value)` syntax is actually faster in its implementation.

So, where possible, it's advised to use DM's syntax. (Note: the to keyword is inclusive, so it automatically defaults to replacing `<=`; if you want `<` then you should write it as `1 to some_value-1`).

**Be Warned:** if either `some_value` or `i` changes within the body of the for (underneath the `for(...)`) or if you are looping over a list and changing the length of the list then you cannot use this type of for-loop!

### Default Return (`.`)

Like other languages in the C family, DM has a `.` or "dot" operator, used for accessing variables/members/functions of an object instance. For example:

```javascript
var/mob/M = foo
M.gib()
```

However, DM also has a dot variable, accessed just as `.` on its own, defaulting to a value of null. Now, what's special about the dot operator is that it is automatically returned (as in the return statement) at the end of a proc, provided the proc does not already manually return (e.g. `return x`)

With `.` being present in every proc, we use it as a temporary variable. However, the `.` operator cannot replace a typecasted variable - it can hold data any other var in DM can, it just can't be accessed as one, although the `.` operator is compatible with a few operators that look weird but work perfectly fine, such as: `.++` for incrementing `.`'s value.

### global vs static variable keyword

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

The Debug-Overlays verb ingame is your friend. It offers many modes to debug many things, such as atmos air groups, writing, areas, and more.

### Profiler

The Open-Profiler verb ingame is also your friend. Be sure to literally type `.debug profile` in the second box.
Once you refresh once, you'll get detailed performance measurements on all running procs.

Guide to the categories:
* Self CPU: The cost of the code in the proc.
* Total CPU: Total cpu is the cost of self plus everything the proc calls.
* Real Time How much time the proc actually ran.
* Overtime: How much was spent past 100 tick_usage. This results in what we know as 'lag'.

If total cpu and real time are the same the proc never sleeps, otherwise real time will be higher as it counts the time while the proc is waiting.

### Target Dummy
* You can spawn in a target dummy (`/mob/living/carbon/human/tdummy`) to more easily test things that do damage - they have the ass day health percent and damage popups visible even if your build isn't set to ass day.

### Signals and Components
* ninjanomnom from TG has written up a [useful primer](https://tgstation13.org/phpBB/viewtopic.php?f=5&t=22674) on signals and components. Most of the stuff there applies, although elements do not exist in this codebase.

### Generic Action bar
* Hate coding action bars? Making a new definition for an action bar datum just so you have visual feedback for your construction feel gross? Well fear not! You can now use the SETUP_GENERIC_ACTIONBAR() macro! Check [_std/macros/actions.dm`](https://github.com/goonstation/goonstation/blob/master/_std/macros/actions.dm) for more information.  

### Turf Define Macro
* Making multiple turfs can be a real pain sometimes. If you use the `DEFINE_FLOORS()` macro as documented, it will create a simulated, simulated airless, unsimulated and unsimulated airless turf with the specified path and variables at compile time. There are many variations on the definition, so I recommend checking out [_std/macros/turf.dm](https://github.com/goonstation/goonstation/blob/master/_std/macros/turf.dm)

