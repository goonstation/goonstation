// Converted everything related to wrestlers from client procs to ability holders and used
// the opportunity to do some clean-up as well (Convair880).

/* 	/		/		/		/		/		/		Ability Holder		/		/		/		/		/		/		/		/		*/

/atom/movable/screen/ability/topBar/wrestler
/datum/abilityHolder/wrestler
	usesPoints = FALSE
	regenRate = 0
	tabName = "Wrestler"
	notEnoughPointsMessage = "<span class='alert'>You aren't strong enough to use this ability.</span>"
	var/fake = FALSE

/datum/abilityHolder/wrestler/fake
	fake = TRUE
/////////////////////////////////////////////// Wrestler spell parent ////////////////////////////

/datum/targetable/wrestler
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "wrestler-template"
	start_on_cooldown = TRUE // So you can't bypass the cooldown by taking off your belt and re-equipping it.
	preferred_holder_type = /datum/abilityHolder/wrestler
	interrupt_action_bars = TRUE
	/// TODO MOVE BEHAVIOR TO PARENT
	var/incapacitation_restriction = 0 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	/// \TODO
	var/not_when_handcuffed = 0
	var/fake = FALSE

	New()
		var/atom/movable/screen/ability/topBar/wrestler/B = new /atom/movable/screen/ability/topBar/wrestler(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B

	updateObject()
		..()
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/wrestler()
			object.icon = src.icon
			object.owner = src

		var/on_cooldown = src.cooldowncheck()
		if (on_cooldown)
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt] ([round(on_cooldown)])"
			object.icon_state = src.icon_state + "_cd"
		else
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt]"
			object.icon_state = src.icon_state

	proc/incapacitation_check(strictness)
		var/mob/living/M = src.holder.owner
		if (!isalive(M))
			return FALSE
		if (strictness != ABILITY_CAN_USE_ALWAYS)
			if (M.hasStatus(list("stunned", "weakened")) && strictness == ABILITY_NO_INCAPACITATED_USE)
				return FALSE
			if (M.hasStatus("paralysis") && strictness == ABILITY_CAN_USE_WHEN_STUNNED) // second check is unnecessary, keeping in case more levels are added later
				return FALSE
		return TRUE

	tryCast(atom/target, params)
		. = ..()
		if (. == CAST_ATTEMPT_SUCCESS)
			SPAWN(rand(20 SECONDS, 90 SECONDS))
				if (ismob(src.holder?.owner))
					src.holder.owner.emote("flex")

	castcheck()
		if (!holder)
			return 0

		var/mob/living/M = holder.owner

		if (!M)
			return 0

		if (fake && !(istype(get_turf(M), /turf/simulated/floor/specialroom/gym) || istype(get_turf(M), /turf/unsimulated/floor/specialroom/gym)))
			boutput(M, "<span class='alert'>You cannot use your \"powers\" outside of The Ring!</span>")
			return 0

		if (!incapacitation_check(src.incapacitation_restriction))
			boutput(M, "<span class='alert'>You can't use this ability while incapacitated!</span>")
			return FALSE

		if (src.not_when_handcuffed == 1 && M.restrained())
			boutput(M, "<span class='alert'>You can't use this ability when restrained!</span>")
			return 0

		return TRUE
