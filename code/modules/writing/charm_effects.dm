//Datumised charm effects!

//ideas:
// something to protect against "gamer" wizard spells like arse nath
// chance to dodge?
// Luminol: protects from trickster wraith darkness effect?
// PROTECT FROM METEOR - smear it with char or something?

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
		src.charm.add_filter("cursed_blood", 1, outline_filter(size=0, color="#CC1E27"))
		animate(src.charm.filters[length(src.charm.filters)], size = 1, time = 1 SECOND)
		animate(time = 0.5 SECONDS, size = 0)
		SPAWN(1.5 SECONDS)
			src.charm.remove_filter("cursed_blood")
		src.charm.visible_message(SPAN_NOTICE("[src.charm] glows faintly as the cursed blood seeps into it."))

	on_lose(mob/living/user)
		src.UnregisterSignal(user, COMSIG_TRY_CURSE)

	on_gain(mob/living/user)
		src.RegisterSignal(user, COMSIG_TRY_CURSE, PROC_REF(on_try_curse))

#define MAX_SERMON_LENGTH 120
	proc/on_try_curse(mob/living/victim, mob/living/intangible/wraith/wraith)
		if (src.charges <= 0)
			return FALSE
		var/obj/effects/harmless_smoke/smoke = new(get_turf(src.charm))
		SPAWN(1 SECOND)
			qdel(smoke)
		boutput(victim, SPAN_ALERT("Your [src.charm.name] singes as it protects you from a foul curse!"))
		victim.TakeDamage("chest", burn = 5) //ow!
		playsound(get_turf(victim), 'sound/impact_sounds/burn_sizzle.ogg', 50, 1)
		src.charges--
		if (wraith && src.charm.paper)
			var/charm_text = strip_html_tags(src.charm.paper.info)
			//if it won't fit in a message just throw a snippet of it at them instead of always the end
			if (length(charm_text) > MAX_SERMON_LENGTH)
				var/start = rand(1, length(charm_text) - MAX_SERMON_LENGTH)
				charm_text = copytext(charm_text, start, start + MAX_SERMON_LENGTH)
				charm_text = "...[charm_text]..."
			DISPLAY_MAPTEXT(victim, list(wraith), MAPTEXT_MOB_RECIPIENTS_WITH_OBSERVERS, /image/maptext/curse_denied, charm_text, src.charm)
		if (src.charges <= 0)
			victim.drop_item(src.charm)
			qdel(src.charm)
			new /obj/decal/cleanable/ash(victim.loc)

		return TRUE
#undef MAX_SERMON_LENGTH

/datum/charm_effect/wolfsbane
	reagents = list("wolfsbane")

	on_gain(mob/living/user)
		APPLY_ATOM_PROPERTY(user, PROP_MOB_LYCANTHROPY_RESIST, src)
		user.add_ailment_resistance(/datum/ailment/disease/lycanthropy, src)

	on_lose(mob/living/user)
		REMOVE_ATOM_PROPERTY(user, PROP_MOB_LYCANTHROPY_RESIST, src)
		user.remove_ailment_resistance(/datum/ailment/disease/lycanthropy, src)

/datum/charm_effect/lavender
	reagents = list("lavender_essence")

	on_gain(mob/living/user)
		src.RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
		src.RegisterSignal(user, COMSIG_LIVING_LIFE_TICK, PROC_REF(on_life))
		user.add_ailment_resistance(/datum/ailment/disease/cold, src)
		user.add_ailment_resistance(/datum/ailment/disease/flu, src)

	on_lose(mob/living/user)
		src.UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		src.UnregisterSignal(user, COMSIG_LIVING_LIFE_TICK)
		user.remove_ailment_resistance(/datum/ailment/disease/cold, src)
		user.remove_ailment_resistance(/datum/ailment/disease/flu, src)

	proc/on_move(mob/living/user, atom/previous_loc, dir)
		if (prob(30) && !ON_COOLDOWN(src.charm, "miasma_clear", 1 SECOND))
			src.try_clear_miasma()

	proc/on_life()
		if (prob(10))
			src.try_clear_miasma()

	proc/try_clear_miasma()
		var/obj/fluid/airborne/cloud = locate() in get_turf(src.charm)
		if (cloud?.group.reagents.get_reagent_amount("miasma"))
			cloud.group.update_amt_per_tile()
			cloud.group.reagents.remove_any(cloud.group.amt_per_tile)
			cloud.group.reagents.remove_reagent("miasma", 5) //a constant term so we don't end up in epsilon hell
			qdel(cloud)

/datum/charm_effect/booze
	stain_condition(reagent_id, volume, datum/reagents/holder_reagents)
		var/datum/reagent/fooddrink/alcoholic/reagent = holder_reagents.get_reagent(reagent_id)
		return istype(reagent)

	on_gain(mob/living/user)
		APPLY_ATOM_PROPERTY(user, PROP_MOB_ALCOHOL_RESIST, src, 40)

	on_lose(mob/living/user)
		REMOVE_ATOM_PROPERTY(user, PROP_MOB_ALCOHOL_RESIST, src)
