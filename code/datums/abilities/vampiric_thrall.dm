// Converted everything related to vampires from client procs to ability holders and used
// the opportunity to do some clean-up as well (Convair880).

/* 	/		/		/		/		/		/		Setup		/		/		/		/		/		/		/		/		*/
/mob/proc/make_vampiric_thrall()
	if (ishuman(src))
		var/datum/abilityHolder/vampiric_thrall/A = src.get_ability_holder(/datum/abilityHolder/vampiric_thrall)
		if (A && istype(A))
			return

		var/datum/abilityHolder/vampiric_thrall/V = src.add_ability_holder(/datum/abilityHolder/vampiric_thrall)

		V.addAbility(/datum/targetable/vampiric_thrall/speak)
		V.addAbility(/datum/targetable/vampire/vampire_bite/thrall)


		V.transferOwnership(src)

		if (src.mind && src.mind.special_role != ROLE_OMNITRAITOR)
			src.show_antag_popup("vampthrall")


/* 	/		/		/		/		/		/		Ability Holder	/		/		/		/		/		/		/		/		*/

/atom/movable/screen/ability/topBar/vampiric_thrall
	clicked(params)
		var/datum/targetable/vampiric_thrall/spell = owner
		var/datum/abilityHolder/holder = owner.holder

		if (!istype(spell))
			return
		if (!spell.holder)
			return

		if(params["shift"] && params["ctrl"])
			if(owner.waiting_for_hotkey)
				holder.cancel_action_binding()
				return
			else
				owner.waiting_for_hotkey = 1
				src.UpdateIcon()
				boutput(usr, "<span class='notice'>Please press a number to bind this ability to...</span>")
				return

		if (!isturf(owner.holder.owner.loc))
			boutput(owner.holder.owner, "<span class='alert'>You can't use this spell here.</span>")
			return
		if (spell.targeted && usr.targeting_ability == owner)
			usr.targeting_ability = null
			usr.update_cursor()
			return
		if (spell.targeted)
			if (world.time < spell.last_cast)
				return
			usr.targeting_ability = owner
			usr.update_cursor()
		else
			SPAWN(0)
				spell.handleCast()
		return

/datum/abilityHolder/vampiric_thrall
	usesPoints = 0
	regenRate = 0
	tabName = "Thrall"
	notEnoughPointsMessage = "<span class='alert'>You need more blood to use this ability.</span>"
	points = 0

	var/mob/vamp_isbiting = null
	var/datum/abilityHolder/vampire/master = 0

	var/last_blood_points = 0

	onLife(var/mult = 1) //failsafe for UI not doing its update correctly elsewhere
		.= 0
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (istype(H.mutantrace, /datum/mutantrace/vampiric_thrall))
				var/datum/mutantrace/vampiric_thrall/V = H.mutantrace

				if (last_blood_points != V.blood_points)
					last_blood_points = V.blood_points
					src.updateText(0, src.x_occupied, src.y_occupied)


	onAbilityStat() // In the 'Vampire' tab.
		..()
		.= list()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (istype(H.mutantrace, /datum/mutantrace/vampiric_thrall))
				var/datum/mutantrace/vampiric_thrall/V = H.mutantrace
				.["Blood:"] = round(V.blood_points)
				.["Max HP:"] = round(H.max_health)

	proc/msg_to_master(var/msg)
		if (master)
			master.transmit_thrall_msg(msg,owner)

	proc/change_vampire_blood(var/change = 0, var/total_blood = 0, var/set_null = 0)
		if(!total_blood)
			var/mob/living/carbon/human/M = owner
			if(istype(M) && istype(M.mutantrace, /datum/mutantrace/vampiric_thrall))
				var/datum/mutantrace/vampiric_thrall/V = M.mutantrace
				if (V.blood_points < 0)
					V.blood_points = 0
					if (haine_blood_debug) logTheThing(LOG_DEBUG, M, "<b>HAINE BLOOD DEBUG:</b> [M]'s blood_points dropped below 0 and was reset to 0")

				if (set_null)
					V.blood_points = 0
				else
					V.blood_points = max(V.blood_points + change, 0)


/datum/targetable/vampiric_thrall
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "vampire-template"
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/vampiric_thrall
	var/when_stunned = 1 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = 0
	var/not_when_in_an_object = TRUE
	var/unlock_message = null

	New()
		var/atom/movable/screen/ability/topBar/vampiric_thrall/B = new /atom/movable/screen/ability/topBar/vampiric_thrall(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B
		return

	onAttach(var/datum/abilityHolder/H)
		..() // Start_on_cooldown check.
		if (src.unlock_message && src.holder && src.holder.owner)
			boutput(src.holder.owner, "<span class='notice'><h3>[src.unlock_message]</h3></span>")
		return

	updateObject()
		..()
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/vampiric_thrall()
			object.icon = src.icon
			object.owner = src
		if (src.last_cast > world.time)
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt] ([round((src.last_cast-world.time)/10)])"
			object.icon_state = src.icon_state + "_cd"
		else
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt]"
			object.icon_state = src.icon_state
		return

	proc/incapacitation_check(var/stunned_only_is_okay = 0)
		if (!holder)
			return 0

		var/mob/living/M = holder.owner
		if (!M || !ismob(M))
			return 0

		switch (stunned_only_is_okay)
			if (0)
				if (!isalive(M) || M.getStatusDuration("stunned") > 0 || M.getStatusDuration("paralysis") > 0 || M.getStatusDuration("weakened"))
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

	castcheck()
		if (!holder)
			return 0

		var/mob/living/M = holder.owner

		if (!M)
			return 0

		if (!(iscarbon(M) || ismobcritter(M)))
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

		if (istype(get_area(M), /area/station/chapel))
			boutput(M, "<span class='alert'>Your powers do not work in this holy place!</span>")
			return 0

		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return
