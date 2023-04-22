/datum/targetable/wraithAbility/specialize
	name = "Evolve"
	icon_state = "evolve"
	desc = null  // set in onAttach
	pointCost = 150
	tooltip_flags = TOOLTIP_LEFT
	special_screen_loc = "NORTH-1,EAST"
	targeted = FALSE
	var/static/list/paths = list("Rot" = 1, "Summoner" = 2, "Trickster" = 3)
	var/list/paths_buttons = list()

	onAttach(datum/abilityHolder/holder)
		. = ..()
		var/datum/abilityHolder/wraith/wraith_holder = holder
		if (istype(ticker.mode, /datum/game_mode/disaster)) //For Disaster wraith
			src.desc = "Choose a form to evolve into using the power of the void."
		else
			src.desc = "Choose a form to evolve into once you have absorbed at least [wraith_holder.absorbs_to_evolve] souls."

		src.object.contextLayout = new /datum/contextLayout/screen_HUD_default(2, 16, 16)
		if (!src.object.contextActions)
			src.object.contextActions = list()

		// Kinda evil- we never directly cast this ability, we just add some context options to the button.Clicking a context option 'casts' the ability
		// (calling evolve())
		// this means we can't use castCheck or any of the usual stuff. Basically this ability doesn't do anything, the button does everything
		for(var/i in list(WRAITH_FORM_PLAGUEBRINGER, WRAITH_FORM_HARBINGER, WRAITH_FORM_TRICKSTER))
			var/datum/contextAction/wraith_evolve_button/newcontext = new /datum/contextAction/wraith_evolve_button(i)
			object.contextActions += newcontext

	// Called by this ability's button's context actions (yes)
	proc/evolve(var/effect)
		var/datum/abilityHolder/wraith/AH = holder
		if (AH.corpsecount < AH.absorbs_to_evolve && !istype(ticker.mode, /datum/game_mode/disaster))
			boutput(holder.owner, "<span class='notice'>You haven't absorbed enough souls. You need to absorb at least [AH.absorbs_to_evolve - AH.corpsecount] more!</span>")
			return TRUE
		if (holder.points < pointCost)
			boutput(holder.owner, "<span class='notice'>You do not have enough points to cast this. You need at least [pointCost] points.</span>")
			return TRUE
		else
			var/mob/living/intangible/wraith/W
			switch (effect)
				if (WRAITH_FORM_PLAGUEBRINGER)
					W = new/mob/living/intangible/wraith/wraith_decay(holder.owner)
					boutput(holder.owner, "<span class='notice'>You use some of your energy to evolve into a plaguebringer! Spread rot and disease all around!</span>")
					holder.owner.show_antag_popup("plaguebringer")
				if (WRAITH_FORM_HARBINGER)
					W = new/mob/living/intangible/wraith/wraith_harbinger(holder.owner)
					boutput(holder.owner, "<span class='notice'>You use some of your energy to evolve into a harbinger! Command your army of minions to bring ruin to the station!</span>")
					holder.owner.show_antag_popup("harbinger")
				if (WRAITH_FORM_TRICKSTER)
					W = new/mob/living/intangible/wraith/wraith_trickster(holder.owner)
					boutput(holder.owner, "<span class='notice'>You use some of your energy to evolve into a trickster! Decieve the crew and turn them against one another!</span>")
					holder.owner.show_antag_popup("trickster")

			W.real_name = holder.owner.real_name
			W.UpdateName()
			W.set_loc(get_turf(src.holder.owner))

			holder.owner.mind.transfer_to(W)
			var/datum/abilityHolder/wraith/new_holder = W.abilityHolder
			new_holder.regenRate = max(AH.regenRate - 2, 1)
			new_holder.corpsecount = max(AH.corpsecount - 1, 0)
			qdel(src.holder.owner)

			return W
