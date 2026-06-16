//Datumised charm effects!
ABSTRACT_TYPE(/datum/charm_effect)
/datum/charm_effect
	/// List of reagent IDs that will cause this effect
	var/list/reagents = list()
	var/obj/item/clothing/suit/charm/charm

	/// Does this effect get added on a particular stain?
	proc/stain_condition(reagent_id, volume, datum/reagents/holder_reagents)
		return reagent_id in src.reagents

	/// When the charm is first stained with this effect
	proc/on_stain()
		return

	/// When the charm is "gained" by a mob, ie picked up or equipped
	proc/on_gain(mob/living/user)
		return

	/// When the charm is "lost" by a mob, ie dropped or stored in a container
	proc/on_lose(mob/living/user)
		return

/datum/charm_effect/cursed_blood
	/// How many curses will this block?
	var/charges = 3
	reagents = list("blood", "bloodc", "hemolymph")

	stain_condition(reagent_id, volume, datum/reagents/holder_reagents)
		var/datum/reagent/reagent = holder_reagents.get_reagent(reagent_id)
		var/datum/bioHolder/bioholder = reagent.data
		return ..() && istype(bioholder) && bioholder.cursed

	on_stain()
		var/datum/effects/system/bad_smoke_spread/smoke = new(get_turf(src.charm))
		smoke.set_up(2, 0, get_turf(charm), null, "#b1b1b1")
		smoke.start()

	on_lose(mob/living/user)
		src.UnregisterSignal(user, COMSIG_TRY_CURSE)

	on_gain(mob/living/user)
		src.RegisterSignal(user, COMSIG_TRY_CURSE, PROC_REF(on_try_curse))

	proc/on_try_curse(mob/living/victim, mob/living/intangible/wraith/wraith)
		if (src.charges <= 0)
			return FALSE
		var/obj/effects/harmless_smoke/smoke = new(get_turf(src.charm))
		SPAWN(1 SECOND)
			qdel(smoke)
		boutput(victim, SPAN_ALERT("Your [src.charm] singes as it protects you from a foul curse!"))
		victim.TakeDamage("chest", burn = 5) //ow!
		playsound(get_turf(victim), 'sound/impact_sounds/burn_sizzle.ogg', 50, 1)
		src.charges--
		if (src.charges <= 0)
			victim.drop_item(src.charm)
			qdel(src.charm)
			new /obj/decal/cleanable/ash(victim.loc)

		return TRUE
