// Converted everything related to wrestlers from client procs to ability holders and used
// the opportunity to do some clean-up as well (Convair880).

/* 	/		/		/		/		/		/		Ability Holder		/		/		/		/		/		/		/		/		*/

/atom/movable/screen/ability/topBar/wrestler
	clicked(params)
		var/datum/targetable/wrestler/spell = owner
		if (!istype(spell))
			return
		if (!spell.holder)
			return
		if (owner.holder.owner) //how even
			if (!isturf(owner.holder.owner.loc))
				boutput(owner.holder.owner, "<span class='alert'>You can't use this ability here.</span>")
				return
		if (spell.targeted && usr.targeting_ability == owner)
			usr.targeting_ability = null
			usr.update_cursor()
			return

		if (spell.target_selection_check)
			var/use_targeted = src.do_target_selection_check()
			if (use_targeted == 2)
				return
			if (spell.targeted || use_targeted == 1)
				if (spell.cooldowncheck())
					return
				owner.holder.owner.targeting_ability = owner
				owner.holder.owner.update_cursor()

		spell.handleCast()

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
	var/when_stunned = 0 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
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

	proc/incapacitation_check(var/stunned_only_is_okay = 0)
		if (!holder)
			return 0

		var/mob/living/M = holder.owner
		if (!M || !ismob(M))
			return 0

		switch (stunned_only_is_okay)
			if (0)
				if (!isalive(M) || M.hasStatus(list("stunned", "paralysis", "weakened")))
					return 0
				else
					return 1
			if (1)
				if (!isalive(M) || M.getStatusDuration("paralysis") > 0)
					return 0
				else
					return 1
			else
				return 1

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

		if (!(ishuman(M) || ismobcritter(M))) // Not all critters have arms to grab people with, but whatever.
			boutput(M, "<span class='alert'>You cannot use any powers in your current form.</span>")
			return 0

		if (M.transforming)
			boutput(M, "<span class='alert'>You can't use any powers right now.</span>")
			return 0

		if (incapacitation_check(src.when_stunned) != 1)
			boutput(M, "<span class='alert'>You can't use this ability while incapacitated!</span>")
			return 0

		if (src.not_when_handcuffed == 1 && M.restrained())
			boutput(M, "<span class='alert'>You can't use this ability when restrained!</span>")
			return 0

		return TRUE
