/datum/targetable/wraithAbility/specialize
	name = "Evolve"
	icon_state = "evolve"
	desc = "Choose a form to evolve into once you have absorbed at least 3 souls"
	targeted = 0
	pointCost = 150
	tooltip_options = list("align" = TOOLTIP_LEFT | TOOLTIP_CENTER)
	special_screen_loc = "NORTH-1,EAST"
	var/static/list/paths = list("Rot" = 1, "Summoner" = 2, "Trickster" = 3)
	var/list/paths_buttons = list()


	New()
		if (istype(ticker.mode, /datum/game_mode/disaster)) //For Disaster wraith
			desc = "Choose a form to evolve into using the power of the void"

		..()

		object.contextLayout = new /datum/contextLayout/screen_HUD_default(2, 16, 16)
		if (!object.contextActions)
			object.contextActions = list()

		for(var/i in 1 to 3)
			var/datum/contextAction/wraith_evolve_button/newcontext = new /datum/contextAction/wraith_evolve_button(i)
			object.contextActions += newcontext

	cast()
		if (..())
			return 1

	proc/evolve(var/effect as text)
		var/datum/abilityHolder/wraith/AH = holder
		if (AH.corpsecount < AH.absorbs_to_evolve && !istype(ticker.mode, /datum/game_mode/disaster))
			boutput(holder.owner, SPAN_NOTICE("You didn't absorb enough souls. You need to absorb at least [AH.absorbs_to_evolve - AH.corpsecount] more!"))
			return 1
		if (holder.points < pointCost)
			boutput(holder.owner, SPAN_NOTICE("You do not have enough points to cast this. You need at least [pointCost] points."))
			return 1
		else
			var/mob/living/intangible/wraith/W
			switch (effect)
				if (1)
					W = new/mob/living/intangible/wraith/wraith_decay(holder.owner)
					boutput(holder.owner, SPAN_NOTICE("You use some of your energy to evolve into a plaguebringer! Spread rot and disease all around!"))
					holder.owner.show_antag_popup("plaguebringer")
				if (2)
					W = new/mob/living/intangible/wraith/wraith_harbinger(holder.owner)
					boutput(holder.owner, SPAN_NOTICE("You use some of your energy to evolve into a harbinger! Command your army of minions to bring ruin to the station!"))
					holder.owner.show_antag_popup("harbinger")
				if (3)
					W = new/mob/living/intangible/wraith/wraith_trickster(holder.owner)
					boutput(holder.owner, SPAN_NOTICE("You use some of your energy to evolve into a trickster! Deceive the crew and turn them against one another!"))
					holder.owner.show_antag_popup("trickster")

			W.real_name = holder.owner.real_name
			W.UpdateName()
			var/turf/T = get_turf(holder.owner)
			W.set_loc(T)

			holder.owner.mind.transfer_to(W)
			var/datum/abilityHolder/wraith/new_holder = W.abilityHolder
			new_holder.regenRate = max(AH.regenRate - 2, 1)
			new_holder.corpsecount = max(AH.corpsecount - 1, 0)
			qdel(holder.owner)

			return W
