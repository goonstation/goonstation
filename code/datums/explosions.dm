/**
 * This probably seems weird to split into two datums right now, but I swear it makes sense.
 * Basically, you should be allowed to have various connections between modifiers <-> effects,
 * rather than being limited to a single combination having a single predefined set of effects.
 */

var/global/list/datum/explosion_modifier/explosion_modifiers

/// Modifier which, given its requirements are satisfied, changes the explosion in some way.
ABSTRACT_TYPE(/datum/explosion_modifier)
/datum/explosion_modifier
	var/id = "abstract_subtype"
	var/list/effect_paths = list() //! The effects which will be used
	var/effect_strength = 0 //! How intense the effect will be when this modifier calls it

	proc/getID()
		return src.id

	/// DO NOT CALL THIS DIRECTLY! Override this and get_effects() instead and pass in vars there.
	/// This proc checks if some input variables satisfy the requirement(s) for this modifier, and returns true/false.
	proc/check_satisfies_requirements()
		SHOULD_CALL_PARENT(FALSE)
		return FALSE

	// Pass in requirement vars through here
	/// Get all the effects for this modifier. Returns instances with the current effect_strength if requirements are satisifed, an empty list otherwlse.
	proc/get_effects(atom/exploding_thing, obj/item/item_modifier, list/datum/explosion_effect/effects_applied_already)
		SHOULD_CALL_PARENT(TRUE)
		/* Add something such as this in subtypes, then call parent
		. = list()
		if (!src.check_satisfies_requirements())
			return
		*/
		. = list()
		for (var/effect_path in src.effect_paths)
			// If it's already in the list, just add its strength to the existing ones strength
			var/applied_already = FALSE
			for (var/datum/explosion_effect/effect as anything in effects_applied_already)
				if (istype_exact(effect, effect_path))
					effect.effect_strength += src.effect_strength
					applied_already = TRUE
					break
			if (applied_already)
				continue
			. += new effect_path(exploding_thing, src.effect_strength, item_modifier)

/// Adds handling for checking items so as not to force repetition on subtypes.
ABSTRACT_TYPE(/datum/explosion_modifier/item)
/datum/explosion_modifier/item
	id = "abstract_item_subtype"
	var/required_type //! Type to require for the type check in check_satisfies_requirements

	check_satisfies_requirements(obj/item/I)
		if (!istype(I, src.required_type))
			return FALSE
		return TRUE

	get_effects(atom/exploding_thing, obj/item/item_modifier)
		. = list()
		if (!src.check_satisfies_requirements(item_modifier))
			return
		. = ..()

/// Makes the explosion turf-safe by instantaneously sealing the breach it creates using RCD cartridges.
/datum/explosion_modifier/item/turf_safe
	id = "turf_safe"
	effect_paths = list(/datum/explosion_effect/turf_safe, /datum/explosion_effect/rcd)
	required_type = /obj/item/rcd_ammo

	get_effects(atom/exploding_thing, obj/item/item_modifier)
		. = list()
		if (!src.check_satisfies_requirements(item_modifier))
			return
		// We verify it's rcd ammo in check_satisfies_requirements
		var/obj/item/rcd_ammo/R = item_modifier
		src.effect_strength = R.matter
		. = ..()

/// Datum which determines some effect which should happen to the explosion.
ABSTRACT_TYPE(/datum/explosion_effect)
/datum/explosion_effect
	var/atom/parent //! the thing that is exploding
	var/effect_strength //! passed in from explosion modifiers
	var/obj/item/used_item //! item used for this modifier

	New(atom/exploding_thing, effect_strength = 0, obj/item/used_item = null)
		..()
		src.parent = exploding_thing
		src.effect_strength = effect_strength
		src.used_item = used_item

	proc/apply_to(datum/explosion/E)
		return

/// Makes the explosion turf-safe, preventing destruction of floors and walls like normal.
/datum/explosion_effect/turf_safe

	apply_to(datum/explosion/E)
		E.turf_safe = TRUE

/datum/explosion_effect/rcd

	apply_to(datum/explosion/E)
		var/max_range = ceil(src.effect_strength / 50) // up to 100 -> / 50 = 1-2
		var/material_used
		if (isnull(used_item.material))
			material_used = getMaterial("steel")
		else
			material_used = used_item.material
		for (var/turf/T in view(max_range, src.parent.loc))
			if (istype(T, /turf/space))
				var/turf/simulated/floor/F = T:ReplaceWithFloor()
				F.setMaterial(material_used)

			var/dist_from_origin = get_dist(T.loc, src.parent.loc)
			if (prob(src.effect_strength/dist_from_origin))
				var/obj/grille/G = new /obj/grille(T)
				G.setMaterial(material_used)

/// Makes an explosion release an instantaneous burst of ionizing radiation, scaling with explosion range and power.
/datum/explosion_effect/radioactive

