# Goonstation Code Guidelines

[ToC]

## General

* Don't use `goto`. Bad.
* Don't use the `:` operator to override type safety checks. Instead, cast the variable to the proper type.
* Use `SPAWN_DBG()` instead of `spawn()`