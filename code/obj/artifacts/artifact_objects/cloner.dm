/obj/artifact/cloner
	name = "artifact cloner"
	associated_datum = /datum/artifact/cloner

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
		if (!user)
			return
		if (clone)
			return
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			// fluff
			if(swapSouls)
				boutput(user, "<span class='alert'>You feel your soul being sucked out of your body by [O]!</span>")
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

			if(clone.client) // gross hack for resetting tg layout bleh bluh copied from cloner code
				clone.client.set_layout(clone.client.tg_layout)

			if(swapSouls && H.mind)
				H.mind.transfer_to(clone)
			clone.changeStatus("paralysis", imprison_time) // so they don't ruin the surprise
			O.ArtifactFaultUsed(H)
			O.ArtifactFaultUsed(clone)

			if ((ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution)) && ((clone.mind in ticker.mode:revolutionaries) || (clone.mind in ticker.mode:head_revolutionaries)))
				ticker.mode:update_all_rev_icons() //So the icon actually appears

			ArtifactLogs(user, clone, O, "touched","creating an evil clone of ([user])",0)
			if(swapSouls)
				// make original body evil
				H.attack_alert = 0
				H.ai_init()
				SPAWN(rand(1 SECOND, 10 SECONDS))
					if(H) // completely convincing dialogue
						H.say(pick(
							"Well, that was weird!",
							"Huh",
							"Maybe it's a [pick("healer","teleporter","plant helper")] type artifact?",
							"What do you think it does?",
							"That activated it, didn't it?",
							"I don't feel any different.",
							""))
					sleep(evil_delay)
					if(H)
						H.ai_aggressive = 1
						H.ai_calm_down = 0
			else
				// make clone evil
				clone.attack_alert = 0
				clone.ai_init()
				clone.ai_aggressive = 1
				clone.ai_calm_down = 0

			SPAWN(imprison_time)
				if (!O.disposed)
					O.ArtifactDeactivated()

	effect_deactivate(obj/O)
		if (..())
			return
		if (clone?.loc == O)
			clone.set_loc(get_turf(O))
			O.visible_message("<span class='alert'><b>[O]</b> releases [clone.name] and shuts down!</span>")
		else
			O.visible_message("<span class='alert'><b>[O]</b> shuts down strangely!</span>")
		for(var/atom/movable/I in (O.contents-O.vis_contents))
			I.set_loc(get_turf(O))
		clone = null
