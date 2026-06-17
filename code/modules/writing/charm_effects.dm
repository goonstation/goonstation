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

#define MAX_SERMON_LENGTH 120
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
	var/had_disease_resist = FALSE

	on_gain(mob/living/user)
		APPLY_ATOM_PROPERTY(user, PROP_MOB_LYCANTHROPY_RESIST, src)
		if (/datum/ailment/disease/lycanthropy in user.resistances)
			src.had_disease_resist = TRUE
		else
			src.had_disease_resist = FALSE
			user.resistances += /datum/ailment/disease/lycanthropy

	on_lose(mob/living/user)
		REMOVE_ATOM_PROPERTY(user, PROP_MOB_LYCANTHROPY_RESIST, src)
		if (src.had_disease_resist)
			return
		user.resistances -= /datum/ailment/disease/lycanthropy
