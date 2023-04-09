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

// TODO remove this var and the checks in parent, replace with  castcheck() override
/datum/abilityHolder/wrestler/fake
	fake = TRUE
/////////////////////////////////////////////// Wrestler spell parent ////////////////////////////

/datum/targetable/wrestler
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "wrestler-template"
	start_on_cooldown = TRUE // So you can't bypass the cooldown by taking off your belt and re-equipping it.
	preferred_holder_type = /datum/abilityHolder/wrestler
	interrupt_action_bars = TRUE
	/// For fake wrestlers, who can only wrestle in the ring (abilities don't work outside)
	var/fake = FALSE

	New()
		var/atom/movable/screen/ability/topBar/B = new /atom/movable/screen/ability/topBar(null)
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
			return FALSE

		if (fake && !(istype(get_turf(M), /turf/simulated/floor/specialroom/gym) || istype(get_turf(M), /turf/unsimulated/floor/specialroom/gym)))
			boutput(M, "<span class='alert'>You cannot use your \"powers\" outside of The Ring!</span>")
			return FALSE

		if (!incapacitation_check(src.incapacitation_restriction))
			boutput(M, "<span class='alert'>You can't use this ability while incapacitated!</span>")
			return FALSE

		return TRUE
