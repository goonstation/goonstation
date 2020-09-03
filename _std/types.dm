#define childrentypesof(x) (typesof(x) - x)
// consider declaring the base type abstract instead and using concrete_typesof instead of childrentypesof

#define ABSTRACT_TYPE(type) /datum/_is_abstract ## type
#define IS_ABSTRACT(type) text2path("/datum/_is_abstract[type]")
/*
usage:

ABSTRACT_TYPE(/datum/test)
/datum/test
/datum/test/child

then you can do:
for(var/type in typesof(/datum/test))
	if(IS_ABSTRACT(type))
		continue
	do_stuff_with_type(type)

Useful for parent types you don't want to be instantiated in places that use istype like this
Note that the ABSTRACT_TYPE annotation *WILL* mark all predecesors of the type abstract too!
That is a feature, not a bug.

Turn on ABSTRACT_VIOLATION_CRASH or ABSTRACT_VIOLATION_WARN to get the server to yell at you
when you instantiate an abstract type. CRASH will runtime, WARN will log it. Don't turn it on
*permanently* on the live server (though turning it on once in a while is probably fine to see
if there are any violations).
*/
#ifdef ABSTRACT_VIOLATION_CRASH
/datum/New()
	..()
	if(IS_ABSTRACT(src.type))
		CRASH("Attempt to instantiate abstract type '[src.type]'.")
#elif defined(ABSTRACT_VIOLATION_WARN)
/datum/New()
	..()
	if(IS_ABSTRACT(src.type))
		logTheThing("debug", src, null, "Attempt to instantiate abstract type '[src.type]'.")
#endif


/*
typesof but only for concrete (not abstract) types
it caches the result so you don't need to worry about doing that manually
so subsequent calls on the same type will be very fast
just don't modify the result of the call directly
OKAY: var/list/hats = concrete_typesof(/obj/item/clothing/head) - /obj/item/clothing/head/hosberet
ALSO OKAY: var/list/hats = concrete_typesof(/obj/item/clothing/head).Copy()
           hats -= /obj/item/clothing/head/hosberet
NOT OKAY: var/list/hats = concrete_typesof(/obj/item/clothing/head)
          hats -= /obj/item/clothing/head/hosberet
*/
var/global/list/cached_concrete_types
proc/concrete_typesof(type)
	if(isnull(cached_concrete_types))
		cached_concrete_types = list()
	if(type in cached_concrete_types)
		return cached_concrete_types[type]
	. = list()
	for(var/subtype in typesof(type))
		if(!IS_ABSTRACT(subtype))
			. += subtype
	cached_concrete_types[type] = .

/*
The same thing but now you can filter the types using a proc. Also cached.
The filter proc takes a type and should return 1 if we want to include it and 0 otherwise.
That proc should also be pure (always return the same thing for the same arguments) because of the caching.
If you want to use non-pure proc do the filtering manually yourself and don't use this.
Note that the first call to filtered_concrete_typesof with a given type and filter will be (possibly a lot)
*slower* than doing it manually. The benefit of this proc only shows itself for future calls which are
very fast due to caching.

Example:
proc/filter_is_syndicate(type)
	var/obj/fake_instance = type
	return initial(fake_instance.is_syndicate)

var/syndie_thing_type = pick(filtered_concrete_typesof(/obj/item, /proc/filter_is_syndicate))
*/
var/global/list/cached_filtered_types
proc/filtered_concrete_typesof(type, filter)
	if(isnull(cached_filtered_types))
		cached_filtered_types = list()
	if((type in cached_filtered_types) && (filter in cached_filtered_types[type]))
		return cached_filtered_types[type][filter]
	. = list()
	for(var/subtype in typesof(type))
		if(!IS_ABSTRACT(subtype) && call(filter)(subtype))
			. += subtype
	if(!(type in cached_filtered_types))
		cached_filtered_types[type] = list()
	cached_filtered_types[type][filter] = .
