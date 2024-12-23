/* ATOM PROPERTIES */

/*

Contains a system to apply fast-to-check properties onto mobs, with different stacking behaviors.

To get the value of ANY property regardless of the behavior used, use:

	GET_ATOM_PROPERTY(mob, property)

If you only want to know whether a property exists, use:

	HAS_ATOM_PROPERTY(mob, property)

To set the values of properties:

	APPLY_ATOM_PROPERTY(mob, property, source[, value[, priority]])

	value is REQUIRED for any property other than simple properties, omitting it will result in a compile error "incorrect number of macro arguments."
	priority is likewise REQUIRED for priority properties.

	REMOVE_ATOM_PROPERTY(mob, property, source)

Behavior-dependent macros:

In the context of these macros, "source" is where the property is being applied/removed from. The actual value of the source argument depends
on what makes sense in context, for example things where multiple objects of the same type may apply stacking properties it might make sense
to use the caller's src as the source; but for things where the property should be per-type unique, src.type may make more sense. A string
might make sense for when multiple types should overwrite eachothers applications of the property.

To modify already-applied values, just run the APPLY macro again.

SIMPLE PROPERTIES

There work like flags, carrying no value. Their existence itself "is" the value.

To set:

	APPLY_ATOM_PROPERTY(mob, property, source)

	for example:

	/obj/item/example_stick/attack_self(mob/user)
		APPLY_ATOM_PROPERTY(user, PROP_EXAMPLE, src.type)

To remove:

	REMOVE_ATOM_PROPERTY(mob, property, source)

	for example:

	/obj/item/unexample_stick/attack_self(mob/user)
		REMOVE_ATOM_PROPERTY(user, PROP_EXAMPLE, /obj/item/example_stick)



SUM PROPERTIES

The value of a sum property is the sum of applied values of the property from all sources.

To set:

	APPLY_ATOM_PROPERTY(mob, property, source, value)

	for example:

	/obj/item/example_stick_1/attack_self(mob/user)
		APPLY_ATOM_PROPERTY(user, PROP_EXAMPLE, src.type, 1)

	/obj/item/example_stick_2/attack_self(mob/user)
		APPLY_ATOM_PROPERTY(user, PROP_EXAMPLE, src.type, 2)

	Using example_stick_1 gives the user a PROP_EXAMPLE value of 1 if no value existed prior. Using example_stick_2 right after makes the value 3.

To remove:

	REMOVE_ATOM_PROPERTY(mob, property, source)

	for example:

	/obj/item/unexample_stick_1/attack_self(mob/user)
		REMOVE_ATOM_PROPERTY(user, PROP_EXAMPLE, /obj/item/example_stick_1)



MAX PROPERTIES

The value of a max property is the largest of the applied values on the property.

To set:

	APPLY_ATOM_PROPERTY(mob, property, source, value)

	for example:

	/obj/item/example_stick_1/attack_self(mob/user)
		APPLY_ATOM_PROPERTY(user, PROP_EXAMPLE, src.type, 1)

	/obj/item/example_stick_2/attack_self(mob/user)
		APPLY_ATOM_PROPERTY(user, PROP_EXAMPLE, src.type, 2)

	Using example_stick_1 gives the user a PROP_EXAMPLE value of 1 if no value existed prior,
	or the existing value was smaller than 1.
	Using example_stick_2 right after makes the value 2, as 2 is larger than 1[citation needed].

To remove:

	REMOVE_ATOM_PROPERTY(mob, property, source)

	for example:

	/obj/item/unexample_stick_2/attack_self(mob/user)
		REMOVE_ATOM_PROPERTY(user, PROP_EXAMPLE, /obj/item/example_stick_2)

	Using unexample_stick_2 returns the value to 1, assuming both sticks have been applied.



PRIORITY PROPERTIES

The value of a priority property is the value with the largest priority

To set:

	APPLY_ATOM_PROPERTY(mob, property, source, value, priority)

	for example:

	/obj/item/example_stick_1/attack_self(mob/user)
		APPLY_ATOM_PROPERTY(user, PROP_EXAMPLE, src.type, 1, 100)

	/obj/item/example_stick_2/attack_self(mob/user)
		APPLY_ATOM_PROPERTY(user, PROP_EXAMPLE, src.type, -300, 200)

	Using example_stick_1 gives the user a PROP_EXAMPLE value of 1 if no value existed prior,
	or the existing value came from a priority smaller than 100.
	Using example_stick_2 right after makes the value -300, as 200 is a higher priority than
	the applied 100.

To remove:

	REMOVE_ATOM_PROPERTY_PRIORITY(mob, property, source)

	for example:

	/obj/item/unexample_stick_2/attack_self(mob/user)
		REMOVE_ATOM_PROPERTY_PRIORITY(user, PROP_EXAMPLE, /obj/item/example_stick_2)

	Using unexample_stick_2 returns the value to 1, assuming both sticks have been applied.


*/

/// Defines of property update actions

/// Sends a debug action about the property changing whenever it changes
#define PROP_UPDATE_DEBUG(target, prop, old_val) DEBUG_MESSAGE("[target].[prop]: [old_val] -> [GET_ATOM_PROPERTY_RAW(target, prop)]")

#define PROP_UPDATE_INVISIBILITY(target, prop, old_val) do { \
	target.invisibility = GET_ATOM_PROPERTY_RAW(target, prop); \
	SEND_SIGNAL(target, COMSIG_ATOM_PROP_MOB_INVISIBILITY, old_val); \
	} while(0)

#define PROP_UPDATE_SIGHT(target, prop, old_val) do {\
	if(!isliving(target)) break; \
	var/mob/living/_living_mob = target; \
	var/datum/lifeprocess/sight/_sightprocess = _living_mob.lifeprocesses?[/datum/lifeprocess/sight]; \
	_sightprocess?.Process(); \
} while(0)

#define PROP_UPDATE_TELEBLOCK_CAT(target, prop, old_val) do { \
	var/is_teleblocking = GET_ATOM_PROPERTY_RAW(target, prop); \
	if (isnull(old_val) && !isnull(is_teleblocking)) { \
		OTHER_START_TRACKING_CAT(target, TR_CAT_TELEPORT_JAMMERS); \
	} else if (!isnull(old_val) && isnull(is_teleblocking)) { \
		OTHER_STOP_TRACKING_CAT(target, TR_CAT_TELEPORT_JAMMERS); \
	}; \
} while(0)

#define PROP_UPDATE_HIDE_ICONS(target, prop, old_val) do { \
	var/new_val = GET_ATOM_PROPERTY_RAW(target, prop); \
	if (old_val != new_val) { \
		var/icon_alpha = new_val ? 0 : 255; \
		if(isliving(target)) { \
			var/mob/living/L = target; \
			L.name_tag?.set_visibility(!new_val); \
		} if(ishuman(target)) { \
			var/mob/living/carbon/human/H = target; \
			H.arrestIcon?.alpha = icon_alpha; \
			if (H.prodoc_icons) { \
				var/image/I; \
				for (var/implant in H.prodoc_icons) { \
					I = H.prodoc_icons[implant]; \
					I.alpha = icon_alpha; \
				} \
			} \
			H.health_mon?.alpha = icon_alpha; \
		} \
	}; \
} while(0)

// Property defines
//
// These must be defined as macros in the format PROP_<yourproperty>(x) x("property key name", MACRO TO APPLY THE PROPERTY, MACRO TO REMOVE THE PROPERTY)

/*  Macros used for testing, left here as examples:
	#define PROP_TESTSIMPLE(x) x("test_simple", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
	#define PROP_TESTSUM(x) x("test_sum", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
	#define PROP_TESTMAX(x) x("test_max", APPLY_ATOM_PROPERTY_MAX, REMOVE_ATOM_PROPERTY_MAX)
	#define PROP_TESTPRIO(x) x("test_prio", APPLY_ATOM_PROPERTY_PRIORITY, REMOVE_ATOM_PROPERTY_PRIORITY)
*/

//-------------------- MOB PROPS -----------------------

// Vision properties
#define PROP_MOB_NIGHTVISION(x) x("nightvision", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT)
#define PROP_MOB_NIGHTVISION_WEAK(x) x("nightvision_weak", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT)
#define PROP_MOB_MESONVISION(x) x("mesonvision", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT)
#define PROP_MOB_GHOSTVISION(x) x("ghostvision", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT)
#define PROP_MOB_XRAYVISION(x) x("xrayvision", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT)
#define PROP_MOB_XRAYVISION_WEAK(x) x("xrayvision_weak", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT)
#define PROP_MOB_THERMALVISION(x) x("thermalvision", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT)
#define PROP_MOB_THERMALVISION_MK2(x) x("thermalvisionmk2", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT) // regular thermal sight + see mobs through walls
#define PROP_MOB_SPECTRO(x) x("spectrovision", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE, PROP_UPDATE_SIGHT)
#define PROP_MOB_EXAMINE_ALL_NAMES(x) x("examine_all", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_EXAMINE_HEALTH(x) x("healthvison", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_EXAMINE_HEALTH_SYNDICATE(x) x("healthvison_syndicate", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE) // doesn't work without PROP_MOB_EXAMINE_HEALTH; TODO rename this to further reduce confusion
//movement properties
#define PROP_MOB_CANTMOVE(x) x("cantmove", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_CANTTURN(x) x("cantturn", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_CANTSPRINT(x) x("cantsprint", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_NO_MOVEMENT_PUFFS(x) x("nomovementpuffs", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_STAMINA_REGEN_BONUS(x) x("stamina_regen", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_FAILED_SPRINT_FLOP(x) x("failed_sprint_flop", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE) // fall over when you sprint at 0 stamina

#define PROP_MOB_NO_SELF_HARM(x) x("noselfharm", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_NOCLIP(x) x("noclip", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_AI_UNTRACKABLE(x) x("aiuntrackable", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_BLOOD_TRACKING_ALWAYS(x) x("bloodtrackingalways", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_VAULT_SPEED(x) x("vaultspeed", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_MOVESPEED_ASSIST(x) x("movespeed_assist", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM) //what fraction (0-1) of movespeed penalty (from equipment only) to negate
//armour properties
#define PROP_MOB_MELEEPROT_HEAD(x) x("meleeprot_head", APPLY_ATOM_PROPERTY_MAX, REMOVE_ATOM_PROPERTY_MAX)
#define PROP_MOB_MELEEPROT_BODY(x) x("meleeprot_body", APPLY_ATOM_PROPERTY_MAX, REMOVE_ATOM_PROPERTY_MAX)
#define PROP_MOB_RANGEDPROT(x) x("rangedprot", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_RADPROT_EXT(x) x("radprotext", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_RADPROT_INT(x) x("radprotint", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_COLDPROT(x) x("coldprot", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_HEATPROT(x) x("heatprot", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_EXPLOPROT(x) x("exploprot", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_CHEMPROT(x) x("chemprot", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_DISARM_RESIST(x) x("disarm_resist", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_REFLECTPROT(x) x("reflection", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_TOYREFLECTPROT(x) x("toyreflection", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_METABOLIC_RATE(x) x("chem_metabolism", APPLY_ATOM_PROPERTY_PRODUCT, REMOVE_ATOM_PROPERTY_PRODUCT)
#define PROP_MOB_DIGESTION_EFFICIENCY(x) x("digestion_efficiency", APPLY_ATOM_PROPERTY_PRODUCT, REMOVE_ATOM_PROPERTY_PRODUCT)
#define PROP_MOB_CHEM_PURGE(x) x("chem_purging", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_REBREATHING(x) x("rebreathing", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_BREATHLESS(x) x("breathless", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_ENCHANT_ARMOR(x) x("enchant_armor", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_EQUIPMENT_MOVESPEED(x) x("equipment_movespeed", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_EQUIPMENT_MOVESPEED_SPACE(x) x("equipment_movespeed_space", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_EQUIPMENT_MOVESPEED_FLUID(x) x("equipment_movespeed_fluid", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_TALISMAN_SWIFTNESS(x) x("art_talisman_movement_mod", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_TALISMAN_BRUTE_REDUCTION(x) x("art_talisman_brute_reduction", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_TALISMAN_BURN_REDUCTION(x) x("art_talisman_burn_reduction", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_TALISMAN_TOX_REDUCTION(x) x("art_talisman_tox_reduction", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)

//disorient_resist props
#define PROP_MOB_DISORIENT_RESIST_BODY(x) x("disorient_resist_body", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_DISORIENT_RESIST_BODY_MAX(x) x("disorient_resist_body_max", APPLY_ATOM_PROPERTY_MAX, REMOVE_ATOM_PROPERTY_MAX)
#define PROP_MOB_DISORIENT_RESIST_EYE(x) x("disorient_resist_eye", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_DISORIENT_RESIST_EYE_MAX(x) x("disorient_resist_eye_max", APPLY_ATOM_PROPERTY_MAX, REMOVE_ATOM_PROPERTY_MAX)
#define PROP_MOB_DISORIENT_RESIST_EAR(x) x("disorient_resist_ear", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_DISORIENT_RESIST_EAR_MAX(x) x("disorient_resist_ear_max", APPLY_ATOM_PROPERTY_MAX, REMOVE_ATOM_PROPERTY_MAX)

//stunresist props
#define PROP_MOB_STUN_RESIST(x) x("stun_resist", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_STUN_RESIST_MAX(x) x("stun_resist_max", APPLY_ATOM_PROPERTY_MAX, REMOVE_ATOM_PROPERTY_MAX)

//misc properties
#define PROP_MOB_INVISIBILITY(x) x("invisibility", APPLY_ATOM_PROPERTY_MAX, REMOVE_ATOM_PROPERTY_MAX, PROP_UPDATE_INVISIBILITY)
#define PROP_MOB_PASSIVE_WRESTLE(x) x("wrassler", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_CANTTHROW(x) x("cantthrow", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_CANT_BE_PINNED(x) x("cantbepinned", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_CAN_CONSTRUCT_WITHOUT_HOLDING(x) x("can_build_without_holding", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE) //! Mob can bulid furniture without holding them (for borgs)
#define PROP_MOB_BLOODGIB_IMMUNE(x) x("bloodgib_immune", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE) //! Mob won't gib from having 1000+ effective blood
#define PROP_MOB_OVERDOSE_WEAKNESS(x) x("overdose_weakness", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_SUPPRESS_LAYDOWN_SOUND(x) x("suppress_laydown_sound", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_SUPPRESS_DEATH_SOUND(x) x("suppress_death_sound", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_NO_MIASMA(x) x("no_miasma", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_NO_DECOMPOSITION(x) x("no_decomposition", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_HEARD_PITCH(x) x("heard_pitch", APPLY_ATOM_PROPERTY_PRODUCT, REMOVE_ATOM_PROPERTY_PRODUCT)
#define PROP_MOB_BLOOD_ABSORPTION_RATE(x) x("blood_absorption_rate", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)
#define PROP_MOB_CANNOT_VOMIT(x) x("cannot_vomit", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_MOB_PRE_POSSESSION(x) x("pre_possession", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)

/// Hides med/sec HUDs and name tags from the mob
#define PROP_MOB_HIDE_ICONS(x) x("hide_icons", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE, PROP_UPDATE_HIDE_ICONS)

//-------------------- OBJ PROPS ------------------------
#define PROP_OBJ_GOLFABLE(x) x("golfable", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)

//-------------------- ITEM PROPS -----------------------
#define PROP_ITEM_IN_CHEM_DISPENSER(x) x("in_chem_dispenser", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)

//------------------- MOVABLE PROPS ---------------------
#define PROP_MOVABLE_VISIBLE_CONTRABAND(x) x("visible_contraband", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)  //! The visible contraband level of this movable
#define PROP_MOVABLE_VISIBLE_GUNS(x) x("visible_firearms", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM) //! The visible firearm contraband level of this movable
#define PROP_MOVABLE_CONTRABAND_OVERRIDE(x) x("contraband_pverride", APPLY_ATOM_PROPERTY_MAX, REMOVE_ATOM_PROPERTY_MAX) //! Thing is considered to have this contraband value, takes max if has multiple of these props
#define PROP_MOVABLE_KLEPTO_IGNORE(x) x("klepto_go_away", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
//-------------------- TURF PROPS -----------------------
//-------------------- ATOM PROPS -----------------------
#define PROP_ATOM_NEVER_DENSE(x) x("neverdense", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_ATOM_NO_ICON_UPDATES(x) x("no_icon_updates", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_ATOM_TELEPORT_JAMMER(x) x("teleport_jammer", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM, PROP_UPDATE_TELEBLOCK_CAT)
#define PROP_ATOM_FLOCK_THING(x) x("flock_thing", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_ATOM_FLOATING(x) x("floating", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
/// Thing will redirect clicks to a fluid on its tile when clicked by a relevant item (beaker mop etc)
#define PROP_ATOM_DO_LIQUID_CLICKS(x) x("do_liquid_clicks", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
///for tracking if a borg/cyborg frame was a roundstart one, for stats purposes
#define PROP_ATOM_ROUNDSTART_BORG(x) x("rounstart_borg", APPLY_ATOM_PROPERTY_SIMPLE, REMOVE_ATOM_PROPERTY_SIMPLE)
#define PROP_ATOM_ART_FISSURE_CORROSION_COUNT(x) x("art_fissure_corrosion_count", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)

#define PROP_ATOM_LUCK(x) x("luck", APPLY_ATOM_PROPERTY_SUM, REMOVE_ATOM_PROPERTY_SUM)

// In lieu of comments, these are the indexes used for list access in the macros below.
#define ATOM_PROPERTY_ACTIVE_VALUE 1
#define ATOM_PROPERTY_SOURCES_LIST 2
#define ATOM_PROPERTY_ACTIVE_PRIO 3
#define ATOM_PROPERTY_PRIORITY_PRIO 1
#define ATOM_PROPERTY_PRIORITY_VALUE 2

#define GET_PROP_NAME TUPLE_GET_1
#define GET_PROP_ADD TUPLE_GET_2
#define GET_PROP_REMOVE TUPLE_GET_3
#define GET_PROP_UPDATE TUPLE_GET_4_OR_DUMMY
#define HAS_PROP_UPDATE(prop) (UNLINT(TUPLE_LENGTH(prop) >= 4))


#define APPLY_ATOM_PROPERTY(target, property, etc...) GET_PROP_ADD(property)(target, GET_PROP_NAME(property), HAS_PROP_UPDATE(property), GET_PROP_UPDATE(property), ##etc)

#define REMOVE_ATOM_PROPERTY(target, property, source) GET_PROP_REMOVE(property)(target, GET_PROP_NAME(property), HAS_PROP_UPDATE(property), GET_PROP_UPDATE(property), source)

#define GET_ATOM_PROPERTY(target, property) (target.atom_properties?[GET_PROP_NAME(property)] ? target.atom_properties[GET_PROP_NAME(property)][ATOM_PROPERTY_ACTIVE_VALUE] : null)

#define GET_ATOM_PROPERTY_RAW(target, property_name) (target.atom_properties?[property_name] ? target.atom_properties[property_name][ATOM_PROPERTY_ACTIVE_VALUE] : null)

// sliiiiiiiightly faster if you don't care about the value
#define HAS_ATOM_PROPERTY(target, property) (target.atom_properties?[GET_PROP_NAME(property)] ? TRUE : FALSE)


#define APPLY_ATOM_PROPERTY_MAX(target, property, do_update, update_macro, source, value) \
	do { \
		LAZYLISTINIT(target.atom_properties); \
		var/list/_L = target.atom_properties; \
		var/_V = value; \
		var/_S = source; \
		if (_L) { \
			if (_L[property]) { \
				_L[property][ATOM_PROPERTY_SOURCES_LIST][_S] = _V; \
				if (_L[property][ATOM_PROPERTY_ACTIVE_VALUE] < _V) { \
					var/_OLD_VAL = _L[property][ATOM_PROPERTY_ACTIVE_VALUE]; \
					_L[property][ATOM_PROPERTY_ACTIVE_VALUE] = _V; \
					if(do_update) { update_macro(target, property, _OLD_VAL); } \
				} \
			} else { \
				_L[property] = list(_V, list()); \
				_L[property][ATOM_PROPERTY_SOURCES_LIST][_S] = _V; \
				if(do_update) { update_macro(target, property, null); } \
			} \
		}; \
	} while (0)

#define REMOVE_ATOM_PROPERTY_MAX(target, property, do_update, update_macro, source) \
	do { \
		var/list/_L = target.atom_properties; \
		if (_L?[property]) { \
			var/_V = _L[property][ATOM_PROPERTY_SOURCES_LIST][source]; \
			_L[property][ATOM_PROPERTY_SOURCES_LIST] -= source; \
			if (!length(_L[property][ATOM_PROPERTY_SOURCES_LIST])) { \
				var/_OLD_VAL = _L[property][ATOM_PROPERTY_ACTIVE_VALUE]; \
				_L -= property; \
				if(do_update && _OLD_VAL) { update_macro(target, property, _OLD_VAL); } \
			} else if(_L[property][ATOM_PROPERTY_ACTIVE_VALUE] == _V) { \
				var/_OLD_VAL = _L[property][ATOM_PROPERTY_ACTIVE_VALUE]; \
				_L[property][ATOM_PROPERTY_ACTIVE_VALUE] = -INFINITY; \
				for(var/_S in _L[property][ATOM_PROPERTY_SOURCES_LIST]) { \
					if (_L[property][ATOM_PROPERTY_ACTIVE_VALUE] < _L[property][ATOM_PROPERTY_SOURCES_LIST][_S]) { \
						_L[property][ATOM_PROPERTY_ACTIVE_VALUE] = _L[property][ATOM_PROPERTY_SOURCES_LIST][_S]; \
					} \
				} \
				if(do_update && _OLD_VAL != _L[property][ATOM_PROPERTY_ACTIVE_VALUE]) \
					{ update_macro(target, property, _OLD_VAL); } \
			} \
		} \
	} while (0)

#define APPLY_ATOM_PROPERTY_SIMPLE(target, property, do_update, update_macro, source) \
	do { \
		LAZYLISTINIT(target.atom_properties); \
		var/list/_L = target.atom_properties; \
		var/_S = source; \
		if (_L) { \
			if (_L[property]) { \
				_L[property][ATOM_PROPERTY_SOURCES_LIST] |= source; \
			} else { \
				_L[property] = list(1, list(_S)); \
				if(do_update) { update_macro(target, property, null); } \
			} \
		}; \
	} while (0)

#define REMOVE_ATOM_PROPERTY_SIMPLE(target, property, do_update, update_macro, source) \
	do { \
		var/list/_L = target.atom_properties; \
		if (_L?[property]) { \
			_L[property][ATOM_PROPERTY_SOURCES_LIST] -= source; \
			if (!length(_L[property][ATOM_PROPERTY_SOURCES_LIST])) { \
				_L -= property; \
				if(do_update) { update_macro(target, property, 1); } \
			} \
		} \
	} while (0)

#define APPLY_ATOM_PROPERTY_SUM(target, property, do_update, update_macro, source, value) \
	do { \
		LAZYLISTINIT(target.atom_properties); \
		var/list/_L = target.atom_properties; \
		var/_V = value; \
		var/_S = source; \
		if (_L) { \
			if (_L[property]) { \
				if (_L[property][ATOM_PROPERTY_SOURCES_LIST][_S]) { \
					var/_OLD_VAL = _L[property][ATOM_PROPERTY_ACTIVE_VALUE]; \
					_L[property][ATOM_PROPERTY_ACTIVE_VALUE] -= _L[property][ATOM_PROPERTY_SOURCES_LIST][_S]; \
					_L[property][ATOM_PROPERTY_SOURCES_LIST][_S] = _V; \
					_L[property][ATOM_PROPERTY_ACTIVE_VALUE] += _V; \
					if(do_update) { update_macro(target, property, _OLD_VAL); } \
				} else { \
					_L[property][ATOM_PROPERTY_SOURCES_LIST][_S] = _V; \
					_L[property][ATOM_PROPERTY_ACTIVE_VALUE] += _V; \
					if(do_update) { update_macro(target, property, _L[property][ATOM_PROPERTY_ACTIVE_VALUE] - _V); } \
				} \
			} else { \
				_L[property] = list(_V, list()); \
				_L[property][ATOM_PROPERTY_SOURCES_LIST][_S] = _V; \
				if(do_update) { update_macro(target, property, null); } \
			} \
		}; \
	} while (0)

#define REMOVE_ATOM_PROPERTY_SUM(target, property, do_update, update_macro, source) \
	do { \
		var/list/_L = target.atom_properties; \
		var/_S = source; \
		if (_L?[property]) { \
			var/_OLD_VAL = _L[property][ATOM_PROPERTY_ACTIVE_VALUE]; \
			if (_L[property][ATOM_PROPERTY_SOURCES_LIST][_S]) { \
				_L[property][ATOM_PROPERTY_ACTIVE_VALUE] -= _L[property][ATOM_PROPERTY_SOURCES_LIST][_S]; \
				_L[property][ATOM_PROPERTY_SOURCES_LIST] -= _S; \
				if(do_update) { update_macro(target, property, _OLD_VAL); } \
			} \
			if (!length(_L[property][ATOM_PROPERTY_SOURCES_LIST])) { \
				_L -= property; \
			} \
			if(do_update) { update_macro(target, property, _OLD_VAL); } \
		} \
	} while (0)

//WARNING: there is currently no good default handling (i.e.: yielding 1 instead of null) for when the property is not set at all. You need to do it manually.
#define APPLY_ATOM_PROPERTY_PRODUCT(target, property, do_update, update_macro, source, value) \
	do { \
		LAZYLISTINIT(target.atom_properties); \
		var/list/_L = target.atom_properties; \
		var/_V = value; \
		var/_S = source; \
		if (_L) { \
			if (_L[property]) { \
				if (_L[property][ATOM_PROPERTY_SOURCES_LIST][_S]) { \
					var/_OLD_VAL = _L[property][ATOM_PROPERTY_ACTIVE_VALUE]; \
					_L[property][ATOM_PROPERTY_ACTIVE_VALUE] /= _L[property][ATOM_PROPERTY_SOURCES_LIST][_S]; \
					_L[property][ATOM_PROPERTY_SOURCES_LIST][_S] = _V; \
					_L[property][ATOM_PROPERTY_ACTIVE_VALUE] *= _V; \
					if(do_update) { update_macro(target, property, _OLD_VAL); } \
				} else { \
					_L[property][ATOM_PROPERTY_SOURCES_LIST][_S] = _V; \
					_L[property][ATOM_PROPERTY_ACTIVE_VALUE] *= _V; \
					if(do_update) { update_macro(target, property, _L[property][ATOM_PROPERTY_ACTIVE_VALUE] / _V); } \
				} \
			} else { \
				_L[property] = list(_V, list()); \
				_L[property][ATOM_PROPERTY_SOURCES_LIST][_S] = _V; \
				if(do_update) { update_macro(target, property, null); } \
			} \
		}; \
	} while (0)

#define REMOVE_ATOM_PROPERTY_PRODUCT(target, property, do_update, update_macro, source) \
	do { \
		var/list/_L = target.atom_properties; \
		var/_S = source; \
		if (_L?[property]) { \
			var/_OLD_VAL = _L[property][ATOM_PROPERTY_ACTIVE_VALUE]; \
			if (_L[property][ATOM_PROPERTY_SOURCES_LIST][_S]) { \
				_L[property][ATOM_PROPERTY_ACTIVE_VALUE] /= _L[property][ATOM_PROPERTY_SOURCES_LIST][_S]; \
				_L[property][ATOM_PROPERTY_SOURCES_LIST] -= _S; \
			} \
			if (!length(_L[property][ATOM_PROPERTY_SOURCES_LIST])) { \
				_L -= property; \
			} \
			if(do_update) { update_macro(target, property, _OLD_VAL); } \
		} \
	} while (0)


#define APPLY_ATOM_PROPERTY_PRIORITY(target, property, do_update, update_macro, source, value, priority) \
	do { \
		LAZYLISTINIT(target.atom_properties); \
		var/list/_L = target.atom_properties; \
		var/_V = value; \
		var/_P = priority; \
		var/_S = source; \
		if (_L) { \
			if (_L[property]) { \
				_L[property][ATOM_PROPERTY_SOURCES_LIST][_S] = list(_P, _V); \
				if (_L[property][ATOM_PROPERTY_ACTIVE_PRIO] < _P) { \
					var/_OLD_VAL = _L[property][ATOM_PROPERTY_ACTIVE_VALUE]; \
					_L[property][ATOM_PROPERTY_ACTIVE_VALUE] = _V; \
					if(do_update) { update_macro(target, property, _OLD_VAL); } \
					_L[property][ATOM_PROPERTY_ACTIVE_PRIO] = _P; \
				} \
			} else { \
				_L[property] = list(_V, list()); \
				_L[property][ATOM_PROPERTY_SOURCES_LIST][_S] = list(_P, _V); \
				_L[property][ATOM_PROPERTY_ACTIVE_PRIO] = _P; \
				if(do_update) { update_macro(target, property, null); } \
			}; \
		}; \
	} while (0)

#define REMOVE_ATOM_PROPERTY_PRIORITY(target, property, do_update, update_macro, source) \
	do { \
		var/list/_L = target.atom_properties; \
		var/_S = source; \
		if (_L?[property]) { \
			var/_S_V = _L[property][ATOM_PROPERTY_SOURCES_LIST][_S][ATOM_PROPERTY_PRIORITY_VALUE];\
			_L[property][ATOM_PROPERTY_SOURCES_LIST] -= source; \
			if (!length(_L[property][ATOM_PROPERTY_SOURCES_LIST])) { \
				var/_OLD_VAL = _L[property][ATOM_PROPERTY_ACTIVE_VALUE]; \
				_L -= property; \
				if(do_update) { update_macro(target, property, _OLD_VAL); } \
			} else if (_L[property][ATOM_PROPERTY_ACTIVE_VALUE] == _S_V) { \
				var/_TO_APPLY_PRIO = -INFINITY; \
				var/_TO_APPLY_VALUE; \
				for (var/_SOURCE in _L[property][ATOM_PROPERTY_SOURCES_LIST]) { \
					var/list/_PRIOLIST = _L[property][ATOM_PROPERTY_SOURCES_LIST][_SOURCE]; \
					if (_PRIOLIST[ATOM_PROPERTY_PRIORITY_PRIO] >= _TO_APPLY_PRIO) { \
						_TO_APPLY_PRIO = _PRIOLIST[ATOM_PROPERTY_PRIORITY_PRIO]; \
						_TO_APPLY_VALUE = _PRIOLIST[ATOM_PROPERTY_PRIORITY_VALUE]; \
					} \
				} \
				var/_OLD_VAL = _L[property][ATOM_PROPERTY_ACTIVE_VALUE]; \
				_L[property][ATOM_PROPERTY_ACTIVE_VALUE] = _TO_APPLY_VALUE; \
				_L[property][ATOM_PROPERTY_ACTIVE_PRIO] = _TO_APPLY_PRIO; \
				if(do_update) { update_macro(target, property, _OLD_VAL); } \
			} \
		} \
	} while (0)


#define APPLY_ATOM_PROPERTY_ROOT_SUM_SQUARE(target, property, do_update, update_macro, source, value) \
	do { \
		LAZYLISTINIT(target.atom_properties); \
		var/list/_L = target.atom_properties; \
		var/_V = value; \
		var/_S = source; \
		if (_L) { \
			if (_L[property]) { \
				if (_L[property][ATOM_PROPERTY_SOURCES_LIST][_S]) { \
					var/_OLD_VAL = _L[property][ATOM_PROPERTY_ACTIVE_VALUE]; \
					_L[property][ATOM_PROPERTY_ACTIVE_VALUE] = sqrt(_L[property][ATOM_PROPERTY_ACTIVE_VALUE]**2 - _L[property][ATOM_PROPERTY_SOURCES_LIST][_S]**2); \
					_L[property][ATOM_PROPERTY_SOURCES_LIST][_S] = _V; \
					_L[property][ATOM_PROPERTY_ACTIVE_VALUE] = sqrt(_L[property][ATOM_PROPERTY_ACTIVE_VALUE]**2 + _V**2); \
					if(do_update) { update_macro(target, property, _OLD_VAL); } \
				} else { \
					_L[property][ATOM_PROPERTY_SOURCES_LIST][_S] = _V; \
					_L[property][ATOM_PROPERTY_ACTIVE_VALUE] = sqrt(_L[property][ATOM_PROPERTY_ACTIVE_VALUE]**2 + _V**2); \
					if(do_update) { update_macro(target, property, _L[property][ATOM_PROPERTY_ACTIVE_VALUE] - _V); } \
				} \
			} else { \
				_L[property] = list(_V, list()); \
				_L[property][ATOM_PROPERTY_SOURCES_LIST][_S] = _V; \
				if(do_update) { update_macro(target, property, null); } \
			} \
		}; \
	} while (0)

#define REMOVE_ATOM_PROPERTY_ROOT_SUM_SQUARE(target, property, do_update, update_macro, source) \
	do { \
		var/list/_L = target.atom_properties; \
		var/_S = source; \
		if (_L?[property]) { \
			var/_OLD_VAL = _L[property][ATOM_PROPERTY_ACTIVE_VALUE]; \
			if (_L[property][ATOM_PROPERTY_SOURCES_LIST][_S]) { \
				_L[property][ATOM_PROPERTY_ACTIVE_VALUE] = sqrt(_L[property][ATOM_PROPERTY_ACTIVE_VALUE]**2 - _L[property][ATOM_PROPERTY_SOURCES_LIST][_S]**2); \
				_L[property][ATOM_PROPERTY_SOURCES_LIST] -= _S; \
				if(do_update) { update_macro(target, property, _OLD_VAL); } \
			} \
			if (!length(_L[property][ATOM_PROPERTY_SOURCES_LIST])) { \
				_L -= property; \
			} \
			if(do_update) { update_macro(target, property, _OLD_VAL); } \
		} \
	} while (0)
