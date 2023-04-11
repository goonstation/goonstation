// Converted everything related to vampires from client procs to ability holders and used
// the opportunity to do some clean-up as well (Convair880).

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
			if (src.owner.cooldowncheck())
				return
			usr.targeting_ability = owner
			usr.update_cursor()
		else
			SPAWN(0)
				spell.handleCast()
		return

/datum/abilityHolder/vampiric_thrall
	usesPoints = FALSE // fucking why
	regenRate = 0
	tabName = "Thrall"
	notEnoughPointsMessage = "<span class='alert'>You need more blood to use this ability.</span>"
	points = 0
	remove_on_clone = TRUE

	var/mob/vamp_isbiting = null
	var/datum/abilityHolder/vampire/master

	var/last_blood_points = 0

	onLife(var/mult = 1) //failsafe for UI not doing its update correctly elsewhere
		. = 0
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (istype(H.mutantrace, /datum/mutantrace/vampiric_thrall))
				var/datum/mutantrace/vampiric_thrall/V = H.mutantrace

				if (last_blood_points != V.blood_points)
					last_blood_points = V.blood_points
					src.updateText(0, src.x_occupied, src.y_occupied)

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
	preferred_holder_type = /datum/abilityHolder/vampiric_thrall
	incapacitation_restriction = ABILITY_CAN_USE_WHEN_STUNNED
	can_cast_while_cuffed = TRUE
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

	onAttach(var/datum/abilityHolder/H)
		. = ..()
		if (src.unlock_message && src.holder && src.holder.owner)
			boutput(src.holder.owner, "<span class='notice'><h3>[src.unlock_message]</h3></span>")

	updateObject()
		..()
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/vampiric_thrall()
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

	castcheck()
		. = ..()
		if (istype(get_area(holder.owner), /area/station/chapel))
			boutput(holder.owner, "<span class='alert'>Your powers do not work in this holy place!</span>")
			return FALSE
