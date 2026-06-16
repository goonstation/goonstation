//Datumised charm effects!
ABSTRACT_TYPE(/datum/charm_effect)
/datum/charm_effect
	/// List of reagent IDs that will cause this effect
	var/list/reagents = list()

	/// Does this effect get added on a particular stain?
	proc/stain_condition(reagent_id, volume, datum/reagents/holder_reagents)
		return reagent_id in src.reagents

	/// When the charm is first stained with this effect
	proc/on_stain(obj/item/paper/folded/charm/charm)
		return

	/// When the charm is "gained" by a mob, ie picked up or equipped
	proc/on_gain(obj/item/paper/folded/charm/charm, mob/living/user)
		return

	/// When the charm is "lost" by a mob, ie dropped or stored in a container
	proc/on_lose(obj/item/paper/folded/charm/charm, mob/living/user)
		return

/datum/charm_effect/cursed_blood
	reagents = list("blood", "bloodc", "hemolymph")

	stain_condition(reagent_id, volume, datum/reagents/holder_reagents)
		var/datum/reagent/reagent = holder_reagents.get_reagent(reagent_id)
		var/datum/bioHolder/bioholder = reagent.data
		return ..() && istype(bioholder) && bioholder.cursed

	on_stain(obj/item/paper/folded/charm/charm)
		var/datum/effects/system/bad_smoke_spread/smoke = new(get_turf(charm))
		smoke.set_up(2, 0, get_turf(charm), null, "#b1b1b1")
		smoke.start()
