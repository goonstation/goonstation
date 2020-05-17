/* MOB PROPERTIES */

/*

Contains a system to apply fast-to-check properties onto mobs, with different stacking behaviors.

To get the value of ANY property regardless of the behavior used, use:

	GET_MOB_PROPERTY(mob, property)

If you only want to know whether a property exists, use:

	HAS_MOB_PROPERTY(mob, property)

To set the values of properties, helper procs exist on the mob type:


Behavior-dependent macros:

In the context of these macros, "source" is where the property is being applied/removed from. The actual value of the source argument depends
on what makes sense in context, for example things where multiple objects of the same type may apply stacking properties it might make sense
to use the caller's src as the source; but for things where the property should be per-type unique, src.type may make more sense. A string
might make sense for when multiple types should overwrite eachothers applications of the property.

To modify already-applied values, just run the APPLY macro again.

SIMPLE PROPERTIES

There work like flags, carrying no value. Their existence itself "is" the value.

To set:

	APPLY_MOB_PROPERTY_SIMPLE(mob, property, source)

	for example:

	/obj/item/example_stick/attack_self(mob/user)
		APPLY_MOB_PROPERTY_SIMPLE(user, PROP_EXAMPLE, src.type)

To remove:

	REMOVE_MOB_PROPERTY_SIMPLE(mob, property, source)

	for example:

	/obj/item/unexample_stick/attack_self(mob/user)
		REMOVE_MOB_PROPERTY_SIMPLE(user, PROP_EXAMPLE, /obj/item/example_stick)



SUM PROPERTIES

The value of a sum property is the sum of applied values of the property from all sources.

To set:

	APPLY_MOB_PROPERTY_SUM(mob, property, source, value)

	for example:

	/obj/item/example_stick_1/attack_self(mob/user)
		APPLY_MOB_PROPERTY_SUM(user, PROP_EXAMPLE, src.type, 1)

	/obj/item/example_stick_2/attack_self(mob/user)
		APPLY_MOB_PROPERTY_SUM(user, PROP_EXAMPLE, src.type, 2)

	Using example_stick_1 gives the user a PROP_EXAMPLE value of 1 if no value existed prior. Using example_stick_2 right after makes the value 3.

To remove:

	REMOVE_MOB_PROPERTY_SUM(mob, property, source)

	for example:

	/obj/item/unexample_stick_1/attack_self(mob/user)
		REMOVE_MOB_PROPERTY_SUM(user, PROP_EXAMPLE, /obj/item/example_stick_1)



MAX PROPERTIES

The value of a max property is the largest of the applied values on the property.

To set:

	APPLY_MOB_PROPERTY_MAX(mob, property, source, value)

	for example:

	/obj/item/example_stick_1/attack_self(mob/user)
		APPLY_MOB_PROPERTY_MAX(user, PROP_EXAMPLE, src.type, 1)

	/obj/item/example_stick_2/attack_self(mob/user)
		APPLY_MOB_PROPERTY_MAX(user, PROP_EXAMPLE, src.type, 2)

	Using example_stick_1 gives the user a PROP_EXAMPLE value of 1 if no value existed prior,
	or the existing value was smaller than 1.
	Using example_stick_2 right after makes the value 2, as 2 is larger than 1[citation needed].

To remove:

	REMOVE_MOB_PROPERTY_MAX(mob, property, source)

	for example:

	/obj/item/unexample_stick_2/attack_self(mob/user)
		REMOVE_MOB_PROPERTY_MAX(user, PROP_EXAMPLE, /obj/item/example_stick_2)

	Using unexample_stick_2 returns the value to 1, assuming both sticks have been applied.



PRIORITY PROPERTIES

The value of a priority property is the value with the largest priority

To set:

	APPLY_MOB_PROPERTY_MAX(mob, property, source, value, priority)

	for example:

	/obj/item/example_stick_1/attack_self(mob/user)
		APPLY_MOB_PROPERTY_MAX(user, PROP_EXAMPLE, src.type, 1, 100)

	/obj/item/example_stick_2/attack_self(mob/user)
		APPLY_MOB_PROPERTY_MAX(user, PROP_EXAMPLE, src.type, -300, 200)

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

#define MOB_PROPERTY_ACTIVE_VALUE 1
#define MOB_PROPERTY_SOURCES_LIST 2
#define MOB_PROPERTY_PRIORITY_PRIO 1
#define MOB_PROPERTY_PRIORITY_VALUE 2


// Property defines
//
// Property strings must be prefixed with the following identifiers:
//
// Simple properties: i
// Max properties: m
// Sum properties: s
// Priority properties: p

#define PROP_CANTMOVE "i_cantmove"



#define GET_MOB_PROPERTY(target, property) (target.mob_properties[property] ? target.mob_properties[property][MOB_PROPERTY_ACTIVE_VALUE] : null)

// sliiiiiiiightly faster if you don't care about the value
#define HAS_MOB_PROPERTY(target, property) (target.mob_properties[property] ? TRUE : FALSE)


#define APPLY_MOB_PROPERTY_MAX(target, property, source, value) \
	do { \
		var/list/_L = target.mob_properties; \
		var/_V = value; \
		var/_S = source; \
		if (_L[property]) { \
			_L[property][MOB_PROPERTY_SOURCES_LIST][_S] = _V; \
			if (_L[property][MOB_PROPERTY_ACTIVE_VALUE] < _V) { \
				_L[property][MOB_PROPERTY_ACTIVE_VALUE] = _V; \
			} \
		} else { \
			_L[property] = list(_V, list(_S = _V)); \
		} \
	} while (0)

#define REMOVE_MOB_PROPERTY_MAX(target, property, source) \
	do { \
		var/list/_L = target.mob_properties; \
		if (_L[property]) { \
			_L[property][MOB_PROPERTY_SOURCES_LIST] -= source; \
			if (!length(_L[property][MOB_PROPERTY_SOURCES_LIST])) { \
				_L -= property; \
			} else { \
				_L[property][MOB_PROPERTY_ACTIVE_VALUE] = -INFINITY; \
				for(var/_S in _L[property][MOB_PROPERTY_SOURCES_LIST]) { \
					if (_L[property][MOB_PROPERTY_ACTIVE_VALUE] < _L[property][MOB_PROPERTY_SOURCES_LIST][_S]) { \
						_L[property][MOB_PROPERTY_ACTIVE_VALUE] = _L[property][MOB_PROPERTY_SOURCES_LIST][_S]; \
					} \
				} \
			} \
		} \
	} while (0)

#define APPLY_MOB_PROPERTY_SIMPLE(target, property, source) \
	do { \
		var/list/_L = target.mob_properties; \
		var/_S = source; \
		if (_L[property]) { \
			_L[property][MOB_PROPERTY_SOURCES_LIST] |= source; \
		} else { \
			_L[property] = list(1, list(_S)); \
		} \
	} while (0)

#define REMOVE_MOB_PROPERTY_SIMPLE(target, property, source) \
	do { \
		var/list/_L = target.mob_properties; \
		if (_L[property]) { \
			_L[property][MOB_PROPERTY_SOURCES_LIST] -= source; \
			if (!length(_L[property][MOB_PROPERTY_SOURCES_LIST])) { \
				_L -= property; \
			} \
		} \
	} while (0)

#define APPLY_MOB_PROPERTY_SUM(target, property, source, value) \
	do { \
		var/list/_L = target.mob_properties; \
		var/_V = value; \
		var/_S = source; \
		if (_L[property]) { \
			if (_L[property][MOB_PROPERTY_SOURCES_LIST][_S]) { \ /* if the value already exists from this source, adjust */ \
				_L[property][MOB_PROPERTY_ACTIVE_VALUE] -= _L[property][MOB_PROPERTY_SOURCES_LIST][_S]; \
				_L[property][MOB_PROPERTY_SOURCES_LIST][_S] = _V; \
				_L[property][MOB_PROPERTY_ACTIVE_VALUE] += _V; \
			} else { \
				_L[property][MOB_PROPERTY_SOURCES_LIST][_S] = _V; \
				_L[property][MOB_PROPERTY_ACTIVE_VALUE] += _V; \
			} \
		} else { \
			_L[property] = list(_V, list(_S = _V)); \
		} \
	} while (0)

#define REMOVE_MOB_PROPERTY_SUM(target, property, source) \
	do { \
		var/list/_L = target.mob_properties; \
		var/_S = source; \
		if (_L[property]) { \
			if (_L[property][MOB_PROPERTY_SOURCES_LIST][_S]) { \
				_L[property][MOB_PROPERTY_ACTIVE_VALUE] -= _L[property][MOB_PROPERTY_SOURCES_LIST][_S]; \
				_L[property][MOB_PROPERTY_SOURCES_LIST] -= _S; \
			} \
			if (!length(_L[property][MOB_PROPERTY_SOURCES_LIST])) { \
				_L -= property; \
			} \
		} \
	} while (0)

#define APPLY_MOB_PROPERTY_PRIORITY(target, property, source, value, priority) \
	do { \
		var/list/_L = target.mob_properties; \
		var/_V = value; \
		var/_P = priority; \
		var/_S = source; \
		if (_L[property]) { \
			_L[property][MOB_PROPERTY_SOURCES_LIST][_S] = list(_P, _V); \
			if (_L[property][MOB_PROPERTY_ACTIVE_VALUE] != _V) { \
				var/_TO_APPLY_PRIO = -INFINITY; \
				var/_TO_APPLY_VALUE; \
				for (var/list/_K in _L[property][MOB_PROPERTY_SOURCES_LIST]) { \
					var/list/_PRIOLIST = _L[property][MOB_PROPERTY_SOURCES_LIST][_K]; \
					if (_PRIOLIST[MOB_PROPERTY_PRIORITY_PRIO] > _TO_APPLY_PRIO) { \
						_TO_APPLY_PRIO = _PRIOLIST[MOB_PROPERTY_PRIORITY_PRIO]; \
						_TO_APPLY_VALUE = _PRIOLIST[MOB_PROPERTY_PRIORITY_VALUE]; \
					} \
				} \
				_L[property][MOB_PROPERTY_ACTIVE_VALUE] = _TO_APPLY_VALUE; \
			} \
		} else { \
			_L[property] = list(_V, list(_S = list(_P, _V))); \
		}; \
	} while (0)

#define REMOVE_MOB_PROPERTY_PRIORITY(target, property, source) \
	do { \
		var/list/_L = target.mob_properties; \
		var/_S = source; \
		if (_L[property]) { \
			var/_S_V = _L[property][MOB_PROPERTY_SOURCES_LIST][_S][MOB_PROPERTY_PRIORITY_VALUE];\
			_L[property][MOB_PROPERTY_SOURCES_LIST] -= source; \
			if (!length(_L[property][MOB_PROPERTY_SOURCES_LIST])) { \
				_L -= property; \
			} else if (_L[property][MOB_PROPERTY_ACTIVE_VALUE] == _S_V) { \ /* we removed the active value */ \
				var/_TO_APPLY_PRIO = -INFINITY; \
				var/_TO_APPLY_VALUE; \
				for (var/list/_K in _L[property][MOB_PROPERTY_SOURCES_LIST]) { \
					var/list/_PRIOLIST = _L[property][MOB_PROPERTY_SOURCES_LIST][_K]; \
					if (_PRIOLIST[MOB_PROPERTY_PRIORITY_PRIO] > _TO_APPLY_PRIO) { \
						_TO_APPLY_PRIO = _PRIOLIST[MOB_PROPERTY_PRIORITY_PRIO]; \
						_TO_APPLY_VALUE = _PRIOLIST[MOB_PROPERTY_PRIORITY_VALUE]; \
					} \
				} \
				_L[property][MOB_PROPERTY_ACTIVE_VALUE] = _TO_APPLY_VALUE; \
			} \
		} \
	} while (0)
