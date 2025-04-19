/obj/artifact/cloner
	name = "artifact cloner"
	associated_datum = /datum/artifact/cloner

	Entered(atom/movable/AM, atom/old_loc)
		. = ..()
		if(isliving(AM))
			APPLY_ATOM_PROPERTY(AM, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "cloner art")

	Exited(atom/movable/AM, atom/new_loc)
		. = ..()
		if(isliving(AM))
			REMOVE_ATOM_PROPERTY(AM, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "cloner art")

/datum/artifact/cloner
	associated_object = /obj/artifact/cloner
	type_name = "Cloner"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 90
	min_triggers = 2
	max_triggers = 2
	validtriggers = list(/datum/artifact_trigger/carbon_touch,/datum/artifact_trigger/silicon_touch)
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	react_xray = list(15,90,90,11,"HOLLOW")
	validtypes = list("wizard","eldritch")
	touch_descriptors = list("You seem to have a little difficulty taking your hand off its surface.")
	var/mob/living/carbon/human/clone = null
	var/imprison_time = 0
	var/evil_delay = 0
	var/swapSouls = FALSE
	var/deep_count = 0

	New()
		..()
		imprison_time = rand(5 SECONDS, 2 MINUTES)
		evil_delay = rand(0,imprison_time)
		swapSouls = prob(50)
		deep_count = prob(10) ? rand(1, 5) : 0

	effect_touch(var/obj/O,var/mob/living/user)
		if (..())
			return
		if (!ishuman(user))
			return
		if (clone)
			return
		var/mob/living/carbon/human/H = user
		// fluff
		if(swapSouls)
			boutput(user, SPAN_ALERT("You feel your soul being sucked out of your body by [O]!"))
		H.add_filter("cloner_art_outline", 0, outline_filter(size=0.5, color=rgb(255,0,0), flags=OUTLINE_SHARP))
		SPAWN(0.7 SECONDS)
			H.remove_filter("cloner_art_outline")

		if(deep_count > 0 && prob(5))
			deep_count--
			clone = semi_deep_copy(H, O, copy_flags=COPY_SKIP_EXPLOITABLE) // admins made me do it
			clone.remove_filter("cloner_art_outline")
		else
			// a bunch of stolen cloner code
			clone = new /mob/living/carbon/human/clone(O)
			clone.bioHolder.CopyOther(H.bioHolder, copyActiveEffects = TRUE)
			clone.set_mutantrace(H.bioHolder?.mobAppearance?.mutant_race?.type)
			clone.update_colorful_parts()
			if (H.abilityHolder)
				clone.abilityHolder = H.abilityHolder.deepCopy()
				clone.abilityHolder.transferOwnership(clone)
				clone.abilityHolder.remove_unlocks()
			if(!isnull(H.traitHolder))
				H.traitHolder.copy_to(clone.traitHolder)
			clone.real_name = user.real_name
			clone.UpdateName()
			spawn_rules_controller.apply_to(clone)

		if(swapSouls && H.mind)
			clone.is_npc = FALSE
			H.is_npc = TRUE
			H.mind.transfer_to(clone)
		APPLY_ATOM_PROPERTY(clone, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "cloner art")
		clone.changeStatus("unconscious", imprison_time) // so they don't ruin the surprise
		O.ArtifactFaultUsed(H)
		O.ArtifactFaultUsed(clone)

		ArtifactLogs(user, clone, O, "touched","creating an evil clone of ([user])",0)
		if(swapSouls)
			// make original body evil
			H.attack_alert = 0
			H.ai_init()
			SPAWN(randfloat(1 SECOND, 3 SECONDS))
				if(H && !H.client) // completely convincing dialogue
					if (prob(33))
						H.say(pick(
							"Well, that was weird!",
							"Huh",
							"Maybe it's a [pick("healer","teleporter","plant helper")] type artifact?",
							"What do you think it does?",
							"That activated it, didn't it?",
							"I don't feel any different.",
							""))
						sleep(randfloat(1 SECOND, 3 SECONDS))
						H.say(phrase_log.random_phrase("say"))
					else
						H.say(phrase_log.random_phrase("say"))
						sleep(randfloat(1 SECOND, 3 SECONDS))
						H.say(phrase_log.random_phrase("say"))
				src.make_evil(H)
		else
			src.make_evil(clone)

		SPAWN(imprison_time)
			if (!O.disposed)
				O.ArtifactDeactivated()

	proc/make_evil(mob/living/carbon/human/clone)
		set waitfor = FALSE
		if(clone)
			sleep(evil_delay)
			clone.attack_alert = 0
			clone.ai_init()
			clone.ai_aggressive = 1
			clone.ai_calm_down = 0
			sleep(randfloat(3 SECOND, 20 SECONDS))
			while (!isdead(clone) && isnull(clone.client) && !QDELETED(clone))
				clone.say(phrase_log.random_phrase("say"))
				sleep(randfloat(3 SECOND, 20 SECONDS))

	effect_deactivate(obj/O)
		if (..())
			return
		if (clone?.loc == O)
			clone.set_loc(get_turf(O))
			O.visible_message(SPAN_ALERT("<b>[O]</b> releases [clone.name] and shuts down!"))
		else
			O.visible_message(SPAN_ALERT("<b>[O]</b> shuts down strangely!"))
		for(var/atom/movable/I in (O.contents-O.vis_contents))
			I.set_loc(get_turf(O))
		clone = null
