/* MOB PROPERTIES */

/*

Contains a system to apply fast-to-check properties onto mobs, with different stacking behaviors.

To get the value of ANY property regardless of the behavior used, use:

	GET_MOB_PROPERTY(mob, property)

If you only want to know whether a property exists, use:

	HAS_MOB_PROPERTY(mob, property)

To set the values of properties:

	APPLY_MOB_PROPERTY(mob, property, source[, value[, priority]])

	value is REQUIRED for any property other than simple properties, omitting it will result in a compile error "incorrect number of macro arguments."
	priority is likewise REQUIRED for priority properties.

	REMOVE_MOB_PROPERTY(mob, property, source)

Behavior-dependent macros:

In the context of these macros, "source" is where the property is being applied/removed from. The actual value of the source argument depends
on what makes sense in context, for example things where multiple objects of the same type may apply stacking properties it might make sense
to use the caller's src as the source; but for things where the property should be per-type unique, src.type may make more sense. A string
might make sense for when multiple types should overwrite eachothers applications of the property.

To modify already-applied values, just run the APPLY macro again.

SIMPLE PROPERTIES

There work like flags, carrying no value. Their existence itself "is" the value.

To set:

	APPLY_MOB_PROPERTY(mob, property, source)

	for example:

	/obj/item/example_stick/attack_self(mob/user)
		APPLY_MOB_PROPERTY(user, PROP_EXAMPLE, src.type)

To remove:

	REMOVE_MOB_PROPERTY(mob, property, source)

	for example:

	/obj/item/unexample_stick/attack_self(mob/user)
		REMOVE_MOB_PROPERTY(user, PROP_EXAMPLE, /obj/item/example_stick)



SUM PROPERTIES

The value of a sum property is the sum of applied values of the property from all sources.

To set:

	APPLY_MOB_PROPERTY(mob, property, source, value)

	for example:

	/obj/item/example_stick_1/attack_self(mob/user)
		APPLY_MOB_PROPERTY(user, PROP_EXAMPLE, src.type, 1)

	/obj/item/example_stick_2/attack_self(mob/user)
		APPLY_MOB_PROPERTY(user, PROP_EXAMPLE, src.type, 2)

	Using example_stick_1 gives the user a PROP_EXAMPLE value of 1 if no value existed prior. Using example_stick_2 right after makes the value 3.

To remove:

	REMOVE_MOB_PROPERTY(mob, property, source)

	for example:

	/obj/item/unexample_stick_1/attack_self(mob/user)
		REMOVE_MOB_PROPERTY(user, PROP_EXAMPLE, /obj/item/example_stick_1)



MAX PROPERTIES

The value of a max property is the largest of the applied values on the property.

To set:

	APPLY_MOB_PROPERTY(mob, property, source, value)

	for example:

	/obj/item/example_stick_1/attack_self(mob/user)
		APPLY_MOB_PROPERTY(user, PROP_EXAMPLE, src.type, 1)

	/obj/item/example_stick_2/attack_self(mob/user)
		APPLY_MOB_PROPERTY(user, PROP_EXAMPLE, src.type, 2)

	Using example_stick_1 gives the user a PROP_EXAMPLE value of 1 if no value existed prior,
	or the existing value was smaller than 1.
	Using example_stick_2 right after makes the value 2, as 2 is larger than 1[citation needed].

To remove:

	REMOVE_MOB_PROPERTY(mob, property, source)

	for example:

	/obj/item/unexample_stick_2/attack_self(mob/user)
		REMOVE_MOB_PROPERTY(user, PROP_EXAMPLE, /obj/item/example_stick_2)

	Using unexample_stick_2 returns the value to 1, assuming both sticks have been applied.



PRIORITY PROPERTIES

The value of a priority property is the value with the largest priority

To set:

	APPLY_MOB_PROPERTY(mob, property, source, value, priority)

	for example:

	/obj/item/example_stick_1/attack_self(mob/user)
		APPLY_MOB_PROPERTY(user, PROP_EXAMPLE, src.type, 1, 100)

	/obj/item/example_stick_2/attack_self(mob/user)
		APPLY_MOB_PROPERTY(user, PROP_EXAMPLE, src.type, -300, 200)

	Using example_stick_1 gives the user a PROP_EXAMPLE value of 1 if no value existed prior,
	or the existing value came from a priority smaller than 100.
	Using example_stick_2 right after makes the value -300, as 200 is a higher priority than
	the applied 100.

To remove:

	REMOVE_MOB_PROPERTY_PRIORITY(mob, property, source)

	for example:

	/obj/item/unexample_stick_2/attack_self(mob/user)
		REMOVE_MOB_PROPERTY_PRIORITY(user, PROP_EXAMPLE, /obj/item/example_stick_2)

	Using unexample_stick_2 returns the value to 1, assuming both sticks have been applied.


*/

/// Defines of property update actions

/// Sends a debug action about the property changing whenever it changes
#define PROP_UPDATE_DEBUG(target, prop, old_val) DEBUG_MESSAGE("[target].[prop]: [old_val] -> [GET_MOB_PROPERTY_RAW(target, prop)]")

#define PROP_UPDATE_INVISIBILITY(target, prop, old_val) do { \
	target.invisibility = GET_MOB_PROPERTY_RAW(target, prop); \
	SEND_SIGNAL(target, COMSIG_MOB_PROP_INVISIBILITY, old_val); \
	} while(0)

#define PROP_UPDATE_SIGHT(target, prop, old_val) do {\
	if(!isliving(target)) return; \
	var/mob/living/_living_mob = target; \
	var/datum/lifeprocess/sight/_sightprocess = _living_mob.lifeprocesses?[/datum/lifeprocess/sight]; \
	_sightprocess?.process(); \
} while(0)

// Property defines
//
// These must be defined as macros in the format PROP_<yourproperty>(x) x("property key name", MACRO TO APPLY THE PROPERTY, MACRO TO REMOVE THE PROPERTY)

/*  Macros used for testing, left here as examples:
	#define PROP_TESTSIMPLE(x) x("test_simple", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE)
	#define PROP_TESTSUM(x) x("test_sum", APPLY_MOB_PROPERTY_SUM, REMOVE_MOB_PROPERTY_SUM)
	#define PROP_TESTMAX(x) x("test_max", APPLY_MOB_PROPERTY_MAX, REMOVE_MOB_PROPERTY_MAX)
	#define PROP_TESTPRIO(x) x("test_prio", APPLY_MOB_PROPERTY_PRIORITY, REMOVE_MOB_PROPERTY_PRIORITY)
*/

// Vision properties
#define PROP_NIGHTVISION(x) x("nightvision", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT)
#define PROP_NIGHTVISION_WEAK(x) x("nightvision_weak", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT)
#define PROP_MESONVISION(x) x("mesonvision", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT)
#define PROP_GHOSTVISION(x) x("ghostvision", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT)
#define PROP_XRAYVISION(x) x("xrayvision", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT)
#define PROP_XRAYVISION_WEAK(x) x("xrayvision_weak", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT)
#define PROP_THERMALVISION(x) x("thermalvision", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT)
#define PROP_THERMALVISION_MK2(x) x("thermalvisionmk2", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT) // regular thermal sight + see mobs through walls
#define PROP_SPECTRO(x) x("spectrovision", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT)
#define PROP_EXAMINE_ALL_NAMES(x) x("examine_all", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE)

#define PROP_CANTMOVE(x) x("cantmove", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE)
#define PROP_CANTSPRINT(x) x("cantsprint", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE)
#define PROP_CANTTHROW(x) x("cantthrow", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE)
#define PROP_NO_MOVEMENT_PUFFS(x) x("nomovementpuffs", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE)
#define PROP_NEVER_DENSE(x) x("neverdense", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE)
#define PROP_INVISIBILITY(x) x("invisibility", APPLY_MOB_PROPERTY_MAX, REMOVE_MOB_PROPERTY_MAX, PROP_UPDATE_INVISIBILITY)
#define PROP_PASSIVE_WRESTLE(x) x("wrassler", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE)
#define PROP_NO_SELF_HARM(x) x("noselfharm", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE)
#define PROP_NOCLIP(x) x("noclip", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE)
#define PROP_AI_UNTRACKABLE(x) x("aiuntrackable", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE)
//armour properties
#define PROP_MELEEPROT_HEAD(x) x("meleeprot_head", APPLY_MOB_PROPERTY_MAX, REMOVE_MOB_PROPERTY_MAX)
#define PROP_MELEEPROT_BODY(x) x("meleeprot_body", APPLY_MOB_PROPERTY_MAX, REMOVE_MOB_PROPERTY_MAX)
#define PROP_RANGEDPROT(x) x("rangedprot", APPLY_MOB_PROPERTY_SUM, REMOVE_MOB_PROPERTY_SUM)
#define PROP_RADPROT(x) x("radprot", APPLY_MOB_PROPERTY_SUM, REMOVE_MOB_PROPERTY_SUM)
#define PROP_COLDPROT(x) x("coldprot", APPLY_MOB_PROPERTY_SUM, REMOVE_MOB_PROPERTY_SUM)
#define PROP_HEATPROT(x) x("heatprot", APPLY_MOB_PROPERTY_SUM, REMOVE_MOB_PROPERTY_SUM)
#define PROP_EXPLOPROT(x) x("exploprot", APPLY_MOB_PROPERTY_SUM, REMOVE_MOB_PROPERTY_SUM)
#define PROP_DISARM_RESIST(x) x("disarm_resist", APPLY_MOB_PROPERTY_SUM, REMOVE_MOB_PROPERTY_SUM)
#define PROP_REFLECTPROT(x) x("reflection", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE)
#define PROP_METABOLIC_RATE(x) x("chem_metabolism", APPLY_MOB_PROPERTY_PRODUCT, REMOVE_MOB_PROPERTY_PRODUCT)
#define PROP_DIGESTION_EFFICIENCY(x) x("digestion_efficiency", APPLY_MOB_PROPERTY_PRODUCT, REMOVE_MOB_PROPERTY_PRODUCT)
#define PROP_CHEM_PURGE(x) x("chem_purging", APPLY_MOB_PROPERTY_SUM, REMOVE_MOB_PROPERTY_SUM)
#define PROP_REBREATHING(x) x("rebreathing", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE)
#define PROP_BREATHLESS(x) x("breathless", APPLY_MOB_PROPERTY_SIMPLE, REMOVE_MOB_PROPERTY_SIMPLE)
#define PROP_ENCHANT_ARMOR(x) x("enchant_armor", APPLY_MOB_PROPERTY_SUM, REMOVE_MOB_PROPERTY_SUM)
#define PROP_STAMINA_REGEN_BONUS(x) x("stamina_regen", APPLY_MOB_PROPERTY_SUM, REMOVE_MOB_PROPERTY_SUM)
//disorient_resist props
#define PROP_DISORIENT_RESIST_BODY(x) x("disorient_resist_body", APPLY_MOB_PROPERTY_SUM, REMOVE_MOB_PROPERTY_SUM)
#define PROP_DISORIENT_RESIST_BODY_MAX(x) x("disorient_resist_body_max", APPLY_MOB_PROPERTY_MAX, REMOVE_MOB_PROPERTY_MAX)
#define PROP_DISORIENT_RESIST_EYE(x) x("disorient_resist_eye", APPLY_MOB_PROPERTY_SUM, REMOVE_MOB_PROPERTY_SUM)
#define PROP_DISORIENT_RESIST_EYE_MAX(x) x("disorient_resist_eye_max", APPLY_MOB_PROPERTY_MAX, REMOVE_MOB_PROPERTY_MAX)
#define PROP_DISORIENT_RESIST_EAR(x) x("disorient_resist_ear", APPLY_MOB_PROPERTY_SUM, REMOVE_MOB_PROPERTY_SUM)
#define PROP_DISORIENT_RESIST_EAR_MAX(x) x("disorient_resist_ear_max", APPLY_MOB_PROPERTY_MAX, REMOVE_MOB_PROPERTY_MAX)

// In lieu of comments, these are the indexes used for list access in the macros below.
#define MOB_PROPERTY_ACTIVE_VALUE 1
#define MOB_PROPERTY_SOURCES_LIST 2
#define MOB_PROPERTY_ACTIVE_PRIO 3
#define MOB_PROPERTY_PRIORITY_PRIO 1
#define MOB_PROPERTY_PRIORITY_VALUE 2

#define GET_PROP_NAME TUPLE_GET_1
#define GET_PROP_ADD TUPLE_GET_2
#define GET_PROP_REMOVE TUPLE_GET_3
#define GET_PROP_UPDATE TUPLE_GET_4_OR_DUMMY
#define HAS_PROP_UPDATE(prop) (UNLINT(TUPLE_LENGTH(prop) >= 4))

#define APPLY_MOB_PROPERTY(target, property, etc...) GET_PROP_ADD(property)(target, GET_PROP_NAME(property), HAS_PROP_UPDATE(property), GET_PROP_UPDATE(property), ##etc)

#define REMOVE_MOB_PROPERTY(target, property, source) GET_PROP_REMOVE(property)(target, GET_PROP_NAME(property), HAS_PROP_UPDATE(property), GET_PROP_UPDATE(property), source)

#define GET_MOB_PROPERTY(target, property) (target.mob_properties?[GET_PROP_NAME(property)] ? target.mob_properties[GET_PROP_NAME(property)][MOB_PROPERTY_ACTIVE_VALUE] : null)

#define GET_MOB_PROPERTY_RAW(target, property_name) (target.mob_properties?[property_name] ? target.mob_properties[property_name][MOB_PROPERTY_ACTIVE_VALUE] : null)

// sliiiiiiiightly faster if you don't care about the value
#define HAS_MOB_PROPERTY(target, property) (target.mob_properties?[GET_PROP_NAME(property)] ? TRUE : FALSE)


#define APPLY_MOB_PROPERTY_MAX(target, property, do_update, update_macro, source, value) \
	do { \
		var/list/_L = target.mob_properties; \
		var/_V = value; \
		var/_S = source; \
		if (_L) { \
			if (_L[property]) { \
				_L[property][MOB_PROPERTY_SOURCES_LIST][_S] = _V; \
				if (_L[property][MOB_PROPERTY_ACTIVE_VALUE] < _V) { \
					var/_OLD_VAL = _L[property][MOB_PROPERTY_ACTIVE_VALUE]; \
					_L[property][MOB_PROPERTY_ACTIVE_VALUE] = _V; \
					if(do_update) { update_macro(target, property, _OLD_VAL); } \
				} \
			} else { \
				_L[property] = list(_V, list()); \
				_L[property][MOB_PROPERTY_SOURCES_LIST][_S] = _V; \
				if(do_update) { update_macro(target, property, null); } \
			} \
		}; \
	} while (0)

#define REMOVE_MOB_PROPERTY_MAX(target, property, do_update, update_macro, source) \
	do { \
		var/list/_L = target.mob_properties; \
		if (_L?[property]) { \
			var/_V = _L[property][MOB_PROPERTY_SOURCES_LIST][source]; \
			_L[property][MOB_PROPERTY_SOURCES_LIST] -= source; \
			if (!length(_L[property][MOB_PROPERTY_SOURCES_LIST])) { \
				var/_OLD_VAL = _L[property][MOB_PROPERTY_ACTIVE_VALUE]; \
				_L -= property; \
				if(do_update && _OLD_VAL) { update_macro(target, property, _OLD_VAL); } \
			} else if(_L[property][MOB_PROPERTY_ACTIVE_VALUE] == _V) { \
				var/_OLD_VAL = _L[property][MOB_PROPERTY_ACTIVE_VALUE]; \
				_L[property][MOB_PROPERTY_ACTIVE_VALUE] = -INFINITY; \
				for(var/_S in _L[property][MOB_PROPERTY_SOURCES_LIST]) { \
					if (_L[property][MOB_PROPERTY_ACTIVE_VALUE] < _L[property][MOB_PROPERTY_SOURCES_LIST][_S]) { \
						_L[property][MOB_PROPERTY_ACTIVE_VALUE] = _L[property][MOB_PROPERTY_SOURCES_LIST][_S]; \
					} \
				} \
				if(do_update && _OLD_VAL != _L[property][MOB_PROPERTY_ACTIVE_VALUE]) \
					{ update_macro(target, property, _OLD_VAL); } \
			} \
		} \
	} while (0)

#define APPLY_MOB_PROPERTY_SIMPLE(target, property, do_update, update_macro, source) \
	do { \
		var/list/_L = target.mob_properties; \
		var/_S = source; \
		if (_L) { \
			if (_L[property]) { \
				_L[property][MOB_PROPERTY_SOURCES_LIST] |= source; \
			} else { \
				_L[property] = list(1, list(_S)); \
				if(do_update) { update_macro(target, property, null); } \
			} \
		}; \
	} while (0)

#define REMOVE_MOB_PROPERTY_SIMPLE(target, property, do_update, update_macro, source) \
	do { \
		var/list/_L = target.mob_properties; \
		if (_L?[property]) { \
			_L[property][MOB_PROPERTY_SOURCES_LIST] -= source; \
			if (!length(_L[property][MOB_PROPERTY_SOURCES_LIST])) { \
				_L -= property; \
				if(do_update) { update_macro(target, property, 1); } \
			} \
		} \
	} while (0)

#define APPLY_MOB_PROPERTY_SUM(target, property, do_update, update_macro, source, value) \
	do { \
		var/list/_L = target.mob_properties; \
		var/_V = value; \
		var/_S = source; \
		if (_L) { \
			if (_L[property]) { \
				if (_L[property][MOB_PROPERTY_SOURCES_LIST][_S]) { \
					var/_OLD_VAL = _L[property][MOB_PROPERTY_ACTIVE_VALUE]; \
					_L[property][MOB_PROPERTY_ACTIVE_VALUE] -= _L[property][MOB_PROPERTY_SOURCES_LIST][_S]; \
					_L[property][MOB_PROPERTY_SOURCES_LIST][_S] = _V; \
					_L[property][MOB_PROPERTY_ACTIVE_VALUE] += _V; \
					if(do_update) { update_macro(target, property, _OLD_VAL); } \
				} else { \
					_L[property][MOB_PROPERTY_SOURCES_LIST][_S] = _V; \
					_L[property][MOB_PROPERTY_ACTIVE_VALUE] += _V; \
					if(do_update) { update_macro(target, property, _L[property][MOB_PROPERTY_ACTIVE_VALUE] - _V); } \
				} \
			} else { \
				_L[property] = list(_V, list()); \
				_L[property][MOB_PROPERTY_SOURCES_LIST][_S] = _V; \
				if(do_update) { update_macro(target, property, null); } \
			} \
		}; \
	} while (0)

#define REMOVE_MOB_PROPERTY_SUM(target, property, do_update, update_macro, source) \
	do { \
		var/list/_L = target.mob_properties; \
		var/_S = source; \
		if (_L?[property]) { \
			var/_OLD_VAL = _L[property][MOB_PROPERTY_ACTIVE_VALUE]; \
			if (_L[property][MOB_PROPERTY_SOURCES_LIST][_S]) { \
				_L[property][MOB_PROPERTY_ACTIVE_VALUE] -= _L[property][MOB_PROPERTY_SOURCES_LIST][_S]; \
				_L[property][MOB_PROPERTY_SOURCES_LIST] -= _S; \
				if(do_update) { update_macro(target, property, _OLD_VAL); } \
			} \
			if (!length(_L[property][MOB_PROPERTY_SOURCES_LIST])) { \
				_L -= property; \
			} \
			if(do_update) { update_macro(target, property, _OLD_VAL); } \
		} \
	} while (0)

#define APPLY_MOB_PROPERTY_PRODUCT(target, property, do_update, update_macro, source, value) \
	do { \
		var/list/_L = target.mob_properties; \
		var/_V = value; \
		var/_S = source; \
		if (_L) { \
			if (_L[property]) { \
				if (_L[property][MOB_PROPERTY_SOURCES_LIST][_S]) { \
					var/_OLD_VAL = _L[property][MOB_PROPERTY_ACTIVE_VALUE]; \
					_L[property][MOB_PROPERTY_ACTIVE_VALUE] /= _L[property][MOB_PROPERTY_SOURCES_LIST][_S]; \
					_L[property][MOB_PROPERTY_SOURCES_LIST][_S] = _V; \
					_L[property][MOB_PROPERTY_ACTIVE_VALUE] *= _V; \
					if(do_update) { update_macro(target, property, _OLD_VAL); } \
				} else { \
					_L[property][MOB_PROPERTY_SOURCES_LIST][_S] = _V; \
					_L[property][MOB_PROPERTY_ACTIVE_VALUE] *= _V; \
					if(do_update) { update_macro(target, property, _L[property][MOB_PROPERTY_ACTIVE_VALUE] / _V); } \
				} \
			} else { \
				_L[property] = list(_V, list()); \
				_L[property][MOB_PROPERTY_SOURCES_LIST][_S] = _V; \
				if(do_update) { update_macro(target, property, null); } \
			} \
		}; \
	} while (0)

#define REMOVE_MOB_PROPERTY_PRODUCT(target, property, do_update, update_macro, source) \
	do { \
		var/list/_L = target.mob_properties; \
		var/_S = source; \
		if (_L?[property]) { \
			var/_OLD_VAL = _L[property][MOB_PROPERTY_ACTIVE_VALUE]; \
			if (_L[property][MOB_PROPERTY_SOURCES_LIST][_S]) { \
				_L[property][MOB_PROPERTY_ACTIVE_VALUE] /= _L[property][MOB_PROPERTY_SOURCES_LIST][_S]; \
				_L[property][MOB_PROPERTY_SOURCES_LIST] -= _S; \
			} \
			if (!length(_L[property][MOB_PROPERTY_SOURCES_LIST])) { \
				_L -= property; \
			} \
			if(do_update) { update_macro(target, property, _OLD_VAL); } \
		} \
	} while (0)


#define APPLY_MOB_PROPERTY_PRIORITY(target, property, source, do_update, update_macro, value, priority) \
	do { \
		var/list/_L = target.mob_properties; \
		var/_V = value; \
		var/_P = priority; \
		var/_S = source; \
		if (_L) { \
			if (_L[property]) { \
				_L[property][MOB_PROPERTY_SOURCES_LIST][_S] = list(_P, _V); \
				if (_L[property][MOB_PROPERTY_ACTIVE_PRIO] < _P) { \
					var/_OLD_VAL = _L[property][MOB_PROPERTY_ACTIVE_VALUE]; \
					_L[property][MOB_PROPERTY_ACTIVE_VALUE] = _V; \
					if(do_update) { update_macro(target, property, _OLD_VAL); } \
					_L[property][MOB_PROPERTY_ACTIVE_PRIO] = _P; \
				} \
			} else { \
				_L[property] = list(_V, list()); \
				_L[property][MOB_PROPERTY_SOURCES_LIST][_S] = list(_P, _V); \
				_L[property][MOB_PROPERTY_ACTIVE_PRIO] = _P; \
				if(do_update) { update_macro(target, property, null); } \
			}; \
		}; \
	} while (0)

#define REMOVE_MOB_PROPERTY_PRIORITY(target, property, do_update, update_macro, source) \
	do { \
		var/list/_L = target.mob_properties; \
		var/_S = source; \
		if (_L?[property]) { \
			var/_S_V = _L[property][MOB_PROPERTY_SOURCES_LIST][_S][MOB_PROPERTY_PRIORITY_VALUE];\
			_L[property][MOB_PROPERTY_SOURCES_LIST] -= source; \
			if (!length(_L[property][MOB_PROPERTY_SOURCES_LIST])) { \
				var/_OLD_VAL = _L[property][MOB_PROPERTY_ACTIVE_VALUE]; \
				_L -= property; \
				if(do_update) { update_macro(target, property, _OLD_VAL); } \
			} else if (_L[property][MOB_PROPERTY_ACTIVE_VALUE] == _S_V) { \
				var/_TO_APPLY_PRIO = -INFINITY; \
				var/_TO_APPLY_VALUE; \
				for (var/_SOURCE in _L[property][MOB_PROPERTY_SOURCES_LIST]) { \
					var/list/_PRIOLIST = _L[property][MOB_PROPERTY_SOURCES_LIST][_SOURCE]; \
					if (_PRIOLIST[MOB_PROPERTY_PRIORITY_PRIO] >= _TO_APPLY_PRIO) { \
						_TO_APPLY_PRIO = _PRIOLIST[MOB_PROPERTY_PRIORITY_PRIO]; \
						_TO_APPLY_VALUE = _PRIOLIST[MOB_PROPERTY_PRIORITY_VALUE]; \
					} \
				} \
				var/_OLD_VAL = _L[property][MOB_PROPERTY_ACTIVE_VALUE]; \
				_L[property][MOB_PROPERTY_ACTIVE_VALUE] = _TO_APPLY_VALUE; \
				_L[property][MOB_PROPERTY_ACTIVE_PRIO] = _TO_APPLY_PRIO; \
				if(do_update) { update_macro(target, property, _OLD_VAL); } \
			} \
		} \
	} while (0)
