
# Storage datums

## What is a storage datum?
A storage datum is something that can be added to any atom to give it storage functionality, being able to hold things of type `/obj/item` in a HUD. 

Atom level procs, for things like attacking a storage with an item, close to the level of signal usage, are used to make this work.

## Looking to add storage to an atom?
For the simplest case, just call `src.create_storage(/datum/storage)` as below:
```js
/obj/item/basket
	name = "basket"
	desc = "A simple basket for holding items."
	
	New()
		..()
		src.create_storage(/datum/storage)
```

This creates a very simple storage, with default parameters. More initialized variables to change the storage can found in the storage datum code file.

As for how storage interacts with an atom's item interaction procs, such as it's `attackby()` proc, those procs will run before any storage happens. Returning without calling the parent will prevent storage functionality, so make sure to return if you don't want something to be stored. Otherwise, you'll need to watch your code for any overridden procs to make sure nothing strange happens when storage of the item is expected.

## When should a new storage datum type be created?
A new storage datum type should be created when a type is needed that rewrites how adding and removing contents to a linked item works, or a significant change is needed that warrants a new type. Ex. See `/datum/storage/bible`.

## Lower level things and practices to note
* Items in an atom's storage are kept track of in the atom's `.contents` list _and_ in the storage datum, but when iterating through storagecontents, storage datum procs should be used for getting the contents.
* For atoms of type `/obj/item`, `src.loc` and `src.stored.linked_item` will be the same, but the second should be used for consistency and clarity.

## Examples
One cool case of storage datums is giving storage to clothing items. An example is below:
```js
/obj/item/clothing/fishingvest
	name = "fishing vest"
	desc = "A nice fishing vest, with some pockets on the front."

	New()
		..()
		src.create_storage(/datum/storage, max_wclass = W_CLASS_SMALL, slots = 3, opens_if_worn = TRUE)
```
This would create give the vest item three storage slot that can hold small items and that when clicked when worn would allow one to use the storage without taking the item off.
