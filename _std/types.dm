#define childrentypesof(x) (typesof(x) - x)
// consider declaring the base type abstract instead and using concrete_typesof instead of childrentypesof

/// nulls a var if its value doesn't match the var's type
#define ENSURE_TYPE(VAR) if(!istype(VAR)) VAR = null;

#define ABSTRACT_TYPE(type) /_is_abstract ## type
#define IS_ABSTRACT(type) text2path("/_is_abstract[type]")
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
		logTheThing(LOG_DEBUG, src, "Attempt to instantiate abstract type '[src.type]'.")
#endif

var/global/list/cached_concrete_types

/**
 * [/proc/typesof()] but only for concrete (not abstract) types,
 * it caches the result so you don't need to worry about doing that manually
 * so subsequent calls on the same type will be very fast.
 *
 * just don't modify the result of the call directly
 *
 * OKAY: `var/list/hats = concrete_typesof(/obj/item/clothing/head) - /obj/item/clothing/head/hosberet`
 *
 * ALSO OKAY:
 * ```dm
 * var/list/hats = concrete_typesof(/obj/item/clothing/head).Copy()
 * hats -= /obj/item/clothing/head/hosberet
 * ```
 *
 * NOT OKAY:
 * ```dm
 * var/list/hats = concrete_typesof(/obj/item/clothing/head)
 * hats -= /obj/item/clothing/head/hosberet
 * ```
 */
proc/concrete_typesof(type, cache=TRUE)
	if(isnull(cached_concrete_types))
		cached_concrete_types = list()
	if(type in cached_concrete_types)
		return cached_concrete_types[type]
	. = list()
	for(var/subtype in typesof(type))
		if(!IS_ABSTRACT(subtype))
			. += subtype
	if(cache)
		cached_concrete_types[type] = .

var/global/list/cached_filtered_types

/**
	* The same thing but now you can filter the types using a proc. Also cached.
	* The filter proc takes a type and should return 1 if we want to include it and 0 otherwise.
	* That proc should also be pure (always return the same thing for the same arguments) because of the caching.
	* If you want to use non-pure proc do the filtering manually yourself and don't use this.
	* Note that the first call to filtered_concrete_typesof with a given type and filter will be (possibly a lot)
	* *slower* than doing it manually. The benefit of this proc only shows itself for future calls which are
	* very fast due to caching.
	*
	* Example:
	* ```
	* proc/filter_is_syndicate(type)
	* 	var/obj/fake_instance = type
	* 	return initial(fake_instance.is_syndicate)
	*
	* var/syndie_thing_type = pick(filtered_concrete_typesof(/obj/item, /proc/filter_is_syndicate))
	* ```
	*/
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

/// Gets the instance of a singleton type (or a non-singleton type if you decide to use it on one).
proc/get_singleton(type)
	RETURN_TYPE(type)
	. = singletons[type]
	if(isnull(.))
		. = singletons[type] = new type

var/global/list/singletons = list()


/// Find predecessor of a type
proc/predecessor_path_in_list(type, list/types)
	while(type)
		if(type in types)
			return type
		type = type2parent(type)
	return null

/**
	* Returns the maximal subtype (i.e. the most subby) in a list of given types
	*/
proc/maximal_subtype(var/list/L)
	if (!(length(L)))
		.= null
	else
		.= L[1]
		for (var/t in L)
			if (ispath(t, .))
				.= t
			else if (!(ispath(., t)))
				return null // paths in L aren't linearly ordered


// by_type and by_cat stuff

// sometimes we want to have all objects of a certain type stored (bibles, staffs of cthulhu, ...)
// to do that add START_TRACKING to New and STOP_TRACKING to disposing, then use by_type[/obj/item/bible] to access the list of things

#define START_TRACKING if(!by_type[__TYPE__]) { by_type[__TYPE__] = list() }; by_type[__TYPE__][src] = 1
#define STOP_TRACKING by_type[__TYPE__].Remove(src)

/// contains lists of objects indexed by their type based on [START_TRACKING] / [STOP_TRACKING]
var/list/list/by_type = list()

/// Loops over all instances of a type that's tracked via the [START_TRACKING] and [STOP_TRACKING] macros.
/// Example: for_by_tcl(gnome, /obj/item/gnomechompski) qdel(gnome)
#define for_by_tcl(_iterator, _type) for(var ##_type/##_iterator as anything in by_type[##_type])

// sometimes we want to have a list of objects of multiple types, without having to traverse multiple lists
// to do that add START_TRACKING_CAT("category") to New or whatever proc you want to start tracking the objects in (eg: tracking dead humans, put start tracking in death())
// and add STOP_TRACKING_CAT("category") to disposing, or whatever proc you want to stop tracking the objects in (eg: tracking live humans, put stop tracking in death())
// and to traverse the list, use by_cat["category"] to get the list of objects in that category
// also ideally youd use defines for by_cat categories!
#define START_TRACKING_CAT(x) OTHER_START_TRACKING_CAT(src, x)
#define STOP_TRACKING_CAT(x) OTHER_STOP_TRACKING_CAT(src, x)
#define OTHER_START_TRACKING_CAT(what, x) if(!by_cat[x]) { by_cat[x] = list() }; by_cat[x][what] = 1
#define OTHER_STOP_TRACKING_CAT(what, x) by_cat[x]?.Remove(what)

/// contains lists of objects indexed by a category string based on START_TRACKING_CAT / STOP_TRACKING_CAT
var/list/list/by_cat = list()

// tracked categories

#define TR_CAT_ATMOS_MACHINES "atmos_machines"
#define TR_CAT_LIGHT_GENERATING_TURFS "light_generating_turfs"
#define TR_CAT_CRITTERS "critters"
#define TR_CAT_PETS "pets"
#define TR_CAT_PW_PETS "pod_wars_pets"
#define TR_CAT_PODS_AND_CRUISERS "pods_and_cruisers"
#define TR_CAT_NERVOUS_MOBS "nervous_mobs"
#define TR_CAT_SHITTYBILLS "shittybills"
#define TR_CAT_JOHNBILLS "johnbills"
#define TR_CAT_OTHERBILLS "otherbills"
#define TR_CAT_TELEPORT_JAMMERS "teleport_jammers"
#define TR_CAT_RADIO_JAMMERS "radio_jammers"
#define TR_CAT_BURNING_MOBS "dudes_on_fire"
#define TR_CAT_BURNING_ITEMS "items_on_fire"
#define TR_CAT_OMNIPRESENT_MOBS "omnipresent_mobs"
#define TR_CAT_CHAPLAINS "chaplains"
#define TR_CAT_SOUL_TRACKING_ITEMS "soul_tracking_items"
#define TR_CAT_CLOWN_DISBELIEF_MOBS "clown_disbelief_mobs"
#define TR_CAT_CANNABIS_OBJ_ITEMS "cannabis_objective"
#define TR_CAT_HEAD_SURGEON "head_surgeon"
#define TR_CAT_SPY_STICKERS_REGULAR "spysticker_regular"
#define TR_CAT_SPY_STICKERS_DET "spysticker_det"
#define TR_CAT_ARTIFACTS "artifacts"
#define TR_CAT_NUKE_OP_STYLE "nukie_style_items" //Items that follow the nuke op color scheme and are generally associated with ops. For recoloring!
#define TR_CAT_HUNTER_GEAR "hunter_gear"
#define TR_CAT_FLOCK_STRUCTURE "flock_structure"
#define TR_CAT_AREA_PROCESS "process_area"
#define TR_CAT_RANCID_STUFF "rancid_stuff"
#define TR_CAT_GHOST_OBSERVABLES "ghost_observables"
#define TR_CAT_STATION_EMERGENCY_LIGHTS "emergency_lights"
#define TR_CAT_STAMINA_MOBS "stamina_mobs"
#define TR_CAT_BUGS "bugs"
#define TR_CAT_POSSIBLE_DEAD_DROP "dead_drops"
#define TR_CAT_SINGULO_MAGNETS "singulo_magnets"
#define TR_CAT_PORTABLE_MACHINERY "portable_machinery"
#define TR_CAT_MANUFACTURER_LINK "manufacturer_link"
#define TR_CAT_TIMING_TIMERS "timing_timers" //item timers that are actively timing right now
// powernets? processing_items?
// mobs? ai-mobs?

#ifndef LIVE_SERVER
#define TR_CAT_DELETE_ME "delete_me" // Things we delete after setup if we're on a local and the relevant compile options are uncommented
#endif


/// type-level information type
/typeinfo
	parent_type = /datum

/typeinfo/datum

/typeinfo/atom
	parent_type = /typeinfo/datum
	/// Used to provide a list of subtypes that will be returned by get_random_subtype
	var/random_subtypes = null

/typeinfo/turf
	parent_type = /typeinfo/atom

/typeinfo/area
	parent_type = /typeinfo/atom

/typeinfo/atom/movable

/typeinfo/obj
	parent_type = /typeinfo/atom/movable

/typeinfo/mob
	parent_type = /typeinfo/atom/movable

/typeinfo/var/SpacemanDMM_return_type = /typeinfo

/**
 * Declares typeinfo for some type.
 *
 * Example:
 * ```
 * TYPEINFO(/atom)
 * 	var/monkeys_hate = FALSE
 *
 * TYPEINFO(/obj/item/clothing/glasses/blindfold)
 * 	monkeys_hate = TRUE
 * ```
 *
 * Treat this as if you were defining a type. You can add vars and procs, override vars and procs etc.
 * There might be minor issues if you define TYPEINFO of one type multiple times. Consider using `/typeinfo/THE_TYPE` for subsequent additions
 * to the object's typeinfo **if you know it has already been declared once using TYPEINFO**.
*/
#define TYPEINFO(TYPE) \
	TYPE/typeinfo_type = /typeinfo ## TYPE; \
	TYPE/get_typeinfo() { /* maybe unnecessary, possibly replace the proc with a macro */ \
		RETURN_TYPE(/typeinfo ## TYPE); \
		return get_singleton(src.typeinfo_type); \
	} \
	/typeinfo ## TYPE

#define TYPEINFO_NEW(TYPE) /typeinfo ## TYPE/New()

/// var storing the subtype of /typeinfo relevant for this object
/datum/var/typeinfo_type = /typeinfo/datum

/**
 * Retrieves the typeinfo datum for this datum's type.
 *
 * Example:
 * ```
 * var/obj/item/item_in_hand = src.equipped()
 * var/typeinfo/atom/typeinfo = item_in_hand.get_typeinfo()
 * if(typeinfo.monkeys_hate)
 * 	src.throw(src.equipped(), somewhere)
 * ```
*/
/datum/proc/get_typeinfo()
	RETURN_TYPE(/typeinfo/datum)
	return get_singleton(src.typeinfo_type)

/**
 * Retrieves the typeinfo datum for a given type.
 *
 * Example:
 * ```
 * for(var/type in types)
 * 	var/typeinfo/atom/typeinfo = get_type_typeinfo(type)
 * 	if(!typeinfo.admin_spawnable)
 * 		continue
 * 	valid_types += type
 * ```
*/
proc/get_type_typeinfo(type)
	RETURN_TYPE(/typeinfo/datum) // change to /typeinfo if we ever implement /typeinfo for non-datums for some reason
	var/datum/type_dummy = type
	return get_singleton(initial(type_dummy.typeinfo_type))

/**
 * Returns the parent type of a given type.
 * Assumes that parent_type was not overriden.
 */
/proc/type2parent(child)
	var/string_type = "[child]"
	var/last_slash = findlasttext(string_type, "/")
	if(last_slash == 1)
		switch(child)
			if(/datum)
				return null
			if(/obj, /mob)
				return /atom/movable
			if(/area, /turf)
				return /atom
			else
				return /datum
	return text2path(copytext(string_type, 1, last_slash))


/// Finds some instance of a type in the world. Returns null if none found.
proc/find_first_by_type(type)
	RETURN_TYPE(type)
	var/ancestor = type
	while(ancestor != null)
		if(ancestor in global.by_type)
			if(length(global.by_type[ancestor]))
				for(var/instance in global.by_type[ancestor])
					if(istype(instance, type))
						return instance
				return null
			else
				return null
		ancestor = type2parent(ancestor)
	. = locate(type)

/**
 *	Finds all instance of a type in the world.
 *	Returns a list of the instances if no procedure is given.
 *	Otherwise, calls the procedure for each instance and returns an assoc list of the form list(instance = procedure(instance, arguments...), ...)
 *	`procedure_src` is the src for the proc call. If it is null, a global proc is called.
 *	If it is the string "instance" the output list will be instead list(instance = instance.procedure(arguments...), ...)
 */
proc/find_all_by_type(type, procedure=null, procedure_src=null, arguments=null, lagcheck=TRUE)
	RETURN_TYPE(type)
	var/ancestor = type
	while(ancestor != null)
		if(ancestor in global.by_type)
			if(length(global.by_type[ancestor]))
				if(ancestor == type)
					. = global.by_type[ancestor].Copy()
				else
					. = list()
					for(var/D in global.by_type[ancestor])
						if(istype(D, type))
							. += D
			else
				return list()
		ancestor = type2parent(ancestor)

	if(.)
		if(!isnull(procedure))
			if(procedure_src == "instance")
				for(var/instance in .)
					.[instance] = call(instance, procedure)(arglist(arguments))
			else if(procedure_src && length(arguments))
				for(var/instance in .)
					var/mod_args = list(instance) + arguments
					.[instance] = call(procedure_src, procedure)(arglist(mod_args))
			else if(procedure_src)
				for(var/instance in .)
					.[instance] = call(procedure_src, procedure)(instance)
			else if(length(arguments))
				for(var/instance in .)
					var/mod_args = list(instance) + arguments
					.[instance] = call(procedure)(arglist(mod_args))
			else
				for(var/instance in .)
					.[instance] = call(procedure)(instance)
		return

	var/atom_base = /datum
	ancestor = type
	while(ancestor != null)
		if(ancestor in list(/obj, /mob, /area, /turf, /atom/movable, /atom, /datum))
			atom_base = ancestor
			break
		ancestor = type2parent(ancestor)

	. = list()
	#define IT_TYPE(T) if(T) {\
			if(!isnull(procedure) && procedure_src == "instance") {\
				for(var ## T/instance) {\
					if(lagcheck) LAGCHECK(LAG_LOW); \
					if(istype(instance, type)) {\
						.[instance] = call(instance, procedure)(arglist(arguments)); \
					} \
				} \
			} else if(!isnull(procedure) && procedure_src && length(arguments)) {\
				for(var ## T/instance) {\
					if(lagcheck) LAGCHECK(LAG_LOW); \
					if(istype(instance, type)) {\
						var/mod_args = list(instance) + arguments; \
						.[instance] = call(procedure_src, procedure)(arglist(mod_args)); \
					} \
				} \
			} else if(!isnull(procedure) && procedure_src) {\
				for(var ## T/instance) {\
					if(lagcheck) LAGCHECK(LAG_LOW); \
					if(istype(instance, type)) {\
						.[instance] = call(procedure_src, procedure)(instance); \
					} \
				} \
			} else if(!isnull(procedure) && length(arguments)) { \
				for(var ## T/instance) {\
					if(lagcheck) LAGCHECK(LAG_LOW); \
					if(istype(instance, type)) {\
						var/mod_args = list(instance) + arguments; \
						.[instance] = call(procedure)(arglist(mod_args)); \
					} \
				} \
			} else if(!isnull(procedure)) { \
				for(var ## T/instance) {\
					if(lagcheck) LAGCHECK(LAG_LOW); \
					if(istype(instance, type)) {\
						.[instance] = call(procedure)(instance); \
					} \
				} \
			} else { \
				for(var ## T/instance) {\
					if(lagcheck) LAGCHECK(LAG_LOW); \
					if(istype(instance, type)) {\
						. += instance; \
					} \
				} \
			} \
		}
	// the escaped newlines are currently necessary because of https://github.com/SpaceManiac/SpacemanDMM/issues/306
	switch(atom_base)
		IT_TYPE(/obj) \
		IT_TYPE(/mob) \
		IT_TYPE(/area) \
		IT_TYPE(/turf) \
		IT_TYPE(/atom/movable) \
		IT_TYPE(/atom) \
		IT_TYPE(/datum) \
		IT_TYPE(/client) \
		else
			CRASH("find_all_by_type: invalid type: [type]")
	#undef IT_TYPE

/// istype but for checking a list of types
proc/istypes(datum/dat, list/types)
	// based on the size of the types list this could be optimizable later by pre-generating and caching a concatenation of typesof() of them
	for(var/type in types)
		if(istype(dat, type))
			return TRUE
	return FALSE

/// Returns a random subtype when an atom has TYPEINFO with a random_subtypes list
/proc/get_random_subtype(atom_type, return_instance = FALSE, return_instance_newargs = null)
	var/typeinfo/atom/info = get_type_typeinfo(atom_type)
	var/atom/chosen_type = pick(info.random_subtypes)
	if (!return_instance)
		return chosen_type
	return new chosen_type(return_instance_newargs)

/// thing.type but it also returns "num" for numbers etc.
/proc/string_type_of_anything(thing)
	. = "unknown"
	if(isnum(thing))
		return "num"
	else if(istext(thing))
		return "text"
	else if(islist(thing))
		return "list"
	else if(ispath(thing))
		return "path"
	else if(isnull(thing))
		return "null"
	else if(isproc(thing))
		return "proc"
	else if(isresource(thing))
		return "resource"
	else if(thing == world)
		return "world"
	else
		return "[thing:type]"
