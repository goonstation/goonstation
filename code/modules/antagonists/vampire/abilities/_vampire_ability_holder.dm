// Converted everything related to vampires from client procs to ability holders and used
// the opportunity to do some clean-up as well (Convair880).

////////////////////////////////////////////////// Helper procs ////////////////////////////////////////////////

// Just a little helper or two since vampire parameters aren't tracked by mob vars anymore.
/mob/proc/get_vampire_blood(var/total_blood = 0)
	var/datum/abilityHolder/vampire/AH = src.get_ability_holder(/datum/abilityHolder/vampire)
	if (AH && istype(AH))
		return AH.get_vampire_blood(total_blood)
	else
		return 0

/mob/proc/change_vampire_blood(var/change = 0, var/total_blood = 0, var/set_null = 0)
	if (!isvampire(src) && !isvampiricthrall(src))
		return

	var/datum/abilityHolder/vampire/AH = src.get_ability_holder(/datum/abilityHolder/vampire)
	if (AH && istype(AH))
		AH.change_vampire_blood(change, total_blood, set_null)
	else
		var/datum/abilityHolder/vampiric_thrall/AHZ = src.get_ability_holder(/datum/abilityHolder/vampiric_thrall)
		if(AHZ && istype(AHZ) && !total_blood)
			AHZ.change_vampire_blood(change, total_blood, set_null)

/mob/proc/check_vampire_power(var/which_power = VAMP_POWER_MAXIMUM)
	var/datum/abilityHolder/vampire/AH = src.get_ability_holder(/datum/abilityHolder/vampire)
	if (AH && istype(AH))
		switch (which_power)
			if (VAMP_POWER_THERMAL_VISION)
				if (AH.has_thermal)
					return TRUE
				else
					return FALSE

			if (VAMP_POWER_XRAY_VISION)
				if (AH.has_xray)
					return TRUE
				else
					return FALSE

			if (VAMP_POWER_MAXIMUM)
				if (AH.has_fullpower)
					return TRUE
				else
					return FALSE

			else
				return FALSE
	else
		return FALSE

////////////////////////////////////////////////// Ability holder /////////////////////////////////////////////
/datum/abilityHolder/vampire
	tabName = "Vampire"
	notEnoughPointsMessage = "<span class='alert'>You need more blood to use this ability.</span>"
	var/vamp_blood = 0
	var/vamp_blood_tracking = TRUE
	var/mob/vamp_isbiting = null
#ifdef BONUS_POINTS
	vamp_blood = 99999
	points = 99999
#endif

	// Note: please use mob.get_vampire_blood() & mob.change_vampire_blood() instead of changing the numbers directly.

	// At the time of writing, sight (thermal, x-ray) and chapel checks can be found in human.dm.
	var/has_thermal = FALSE
	var/has_xray = FALSE
	var/has_fullpower = FALSE

	// These are thresholds in relation to vamp_blood. Last_power exists only for unlock checks as stuff
	// might deduct something from vamp_blood, though it shouldn't happen on a regular basis.
	var/last_power = 0
	var/level1 = 5
	var/level2 = 300
	var/level3 = 600
	var/level4 = 900
	var/level5 = 1400
	var/level6 = 1800 // Full power.

	var/list/thralls = list()
	var/turf/coffin_turf = 0

	//contains the reference to the coffin if we're currently travelling to it, otherwise null
	var/obj/storage/closet/coffin/vampire/the_coffin = null

	onAbilityStat() // In the 'Vampire' tab.
		..()
		.= list()
		.["Blood:"] = round(src.points)
		.["Total:"] = round(src.vamp_blood)
		return

	onAttach(mob/to_whom)
		..()
		RegisterSignal(to_whom, COMSIG_MOB_FLIP, PROC_REF(launch_bat_orbiters))

	onRemove(mob/from_who)
		..()
		UnregisterSignal(from_who, COMSIG_MOB_FLIP)

	onLife(var/mult = 1)
		..()
		if (!(the_coffin?.disposed) && isturf(owner.loc) && istype(the_coffin,/obj/storage/closet/coffin))
			owner.set_loc(the_coffin)

		if (istype(owner.loc,/obj/storage/closet/coffin))
			the_coffin = null
			if (isdead(owner))
				owner.full_heal()
				if (ishuman(owner)) // oof
					var/mob/living/carbon/human/owner_human = owner
					owner_human.decomp_stage = DECOMP_STAGE_NO_ROT
					owner_human.update_face()
					owner_human.update_body()
			else
				changeling_super_heal_step(healed = owner, mult = mult*2, changer = 0)

	set_loc_callback(newloc)
		if (istype(newloc,/obj/storage/closet/coffin))
			the_coffin = null

	proc/change_vampire_blood(var/change = 0, var/total_blood = 0, var/set_null = FALSE)
		if (total_blood)
			if (src.vamp_blood < 0)
				src.vamp_blood = 0
				if (haine_blood_debug) logTheThing(LOG_DEBUG, owner, "<b>HAINE BLOOD DEBUG:</b> [owner]'s vamp_blood dropped below 0 and was reset to 0")

			if (set_null)
				src.vamp_blood = 0
			else
				src.vamp_blood = max(src.vamp_blood + change, 0)

		else
			if (src.points < 0)
				src.points = 0
				if (haine_blood_debug) logTheThing(LOG_DEBUG, owner, "<b>HAINE BLOOD DEBUG:</b> [owner]'s vamp_blood_remaining dropped below 0 and was reset to 0")

			if (set_null)
				src.points = 0
			else
				src.points = max(src.points + change, 0)

			if (change > 0 && ishuman(src.owner))
				var/mob/living/carbon/human/H = src.owner
				if (H.sims)
					H.sims.affectMotive("Thirst", change * 0.5)
					H.sims.affectMotive("Hunger", change * 0.5)

	proc/get_vampire_blood(var/total_blood = 0)
		if (total_blood)
			return src.vamp_blood
		else
			return src.points

	proc/blood_tracking_output(var/deduct = 0)
		if (!src.owner || !ismob(src.owner))
			return

		if (!istype(src, /datum/abilityHolder/vampire))
			return

		if (!src.vamp_blood_tracking)
			return

		if (deduct > 1)
			boutput(src.owner, "<span class='notice'>You used [deduct] units of blood, and have [src.points - deduct] remaining.</span>")

		else
			boutput(src.owner, "<span class='notice'>You have accumulated [src.vamp_blood] units of blood and [src.points] left to use.</span>")

	proc/check_for_unlocks()
		if (!src.owner || !ismob(src.owner))
			return

		if (!istype(src, /datum/abilityHolder/vampire))
			return

		if (!src.last_power && src.vamp_blood >= src.level1)
			src.last_power = 1

			src.addAbility(/datum/targetable/vampire/phaseshift_vampire)
			src.addAbility(/datum/targetable/vampire/enthrall)
			src.addAbility(/datum/targetable/vampire/speak_thrall)

		if (src.last_power == 1 && src.vamp_blood >= src.level2)
			src.last_power = 2

			src.has_thermal = 1
			APPLY_ATOM_PROPERTY(src.owner, PROP_MOB_THERMALVISION_MK2, src)
			boutput(src.owner, "<span class='notice'><h3>Your vampiric vision has improved (thermal)!</h3></span>")

			src.addAbility(/datum/targetable/vampire/mark_coffin)
			src.addAbility(/datum/targetable/vampire/coffin_escape)

		if (src.last_power == 2 && src.vamp_blood >= src.level3)
			src.last_power = 3

			src.addAbility(/datum/targetable/vampire/call_bats)
			src.addAbility(/datum/targetable/vampire/vampire_scream)

		if (src.last_power == 3 && src.vamp_blood >= src.level4)
			src.last_power = 4

			src.removeAbility(/datum/targetable/vampire/phaseshift_vampire)
			src.addAbility(/datum/targetable/vampire/phaseshift_vampire/mk2)
			src.addAbility(/datum/targetable/vampire/plague_touch)

		if (src.last_power == 4 && src.vamp_blood >= src.level5)
			src.last_power = 5

			src.removeAbility(/datum/targetable/vampire/vampire_scream)
			src.addAbility(/datum/targetable/vampire/vampire_scream/mk2)

		if (src.last_power == 5 && src.vamp_blood >= src.level6)
			src.last_power = 6

			src.has_xray = 1
			src.has_fullpower = 1
			//boutput(src.owner, "<span class='notice'><h3>Your vampiric vision has improved (x-ray)!</h3></span>")
			boutput(src.owner, "<span class='notice'><h3>You have attained full power and are now too powerful to be harmed or stopped by the chapel's aura.</h3></span>")

	remove_unlocks()
		src.removeAbility(/datum/targetable/vampire/phaseshift_vampire)
		src.removeAbility(/datum/targetable/vampire/phaseshift_vampire/mk2)
		src.removeAbility(/datum/targetable/vampire/mark_coffin)
		src.removeAbility(/datum/targetable/vampire/coffin_escape)
		src.removeAbility(/datum/targetable/vampire/enthrall)
		src.removeAbility(/datum/targetable/vampire/speak_thrall)
		src.removeAbility(/datum/targetable/vampire/call_bats)
		src.removeAbility(/datum/targetable/vampire/vampire_scream)
		src.removeAbility(/datum/targetable/vampire/vampire_scream/mk2)
		src.removeAbility(/datum/targetable/vampire/plague_touch)

		src.updateButtons()

	proc/transmit_thrall_msg(var/message,var/mob/sender)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

		if (!message)
			return

		if (dd_hasprefix(message, "*"))
			return

		logTheThing(LOG_DIARY, sender, "(GHOULSPEAK): [message]", "ghoulsay")
		logTheThing(LOG_SAY, sender, "(GHOULSPEAK): [message]")

		if (sender.client && sender.client.ismuted())
			boutput(sender, "You are currently muted and may not speak.")
			return

		sender.say_thrall(message, src)

	proc/make_thrall(var/mob/victim)
		if (ishuman(victim))

			var/mob/living/M = victim


			if (!M.mind && !M.client)
				if (M.ghost && M.ghost.client && !M.ghost.mind.get_player().dnr)
					var/mob/dead/ghost = M.ghost
					ghost.show_text("<span class='red'>You feel yourself torn away from the afterlife and back into your body!</span>")
					if(ghost.mind)
						ghost.mind.transfer_to(M)
					else if (ghost.client)
						M.client = ghost.client
					else if (ghost.key)
						M.key = ghost.key

				else if (M.last_client) //if all fails, lets try this
					for (var/client/C in clients)
						if (C == M.last_client && C.mob && isobserver(C.mob))
							if(C.mob && C.mob.mind)
								C.mob.mind.transfer_to(M)
							else
								M.client = C

							break

			if (!M.client)
				return

			M.full_heal()
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				H.decomp_stage = DECOMP_STAGE_NO_ROT

			if (M.bioHolder && M.traitHolder.hasTrait("training_chaplain"))
				if(ismob(owner))
					boutput(owner, "<span class='alert'>Wait, this is a chaplain!!! <B>AGDFHSKFGBLDFGLHSFDGHDFGH</B></span>")
					boutput(M, "<span class='notice'>Your divine protection saves you from enthrallment!</span>")
					owner.emote("scream")
					owner.changeStatus("weakened", 5 SECONDS)
					owner.TakeDamage("chest", 0, 30)
					return

			M.mind.add_subordinate_antagonist(ROLE_VAMPTHRALL, master = src)

			boutput(owner, "<span class='notice'>[M] has been revived as your thrall.</span>")
			logTheThing(LOG_COMBAT, owner, "enthralled [constructTarget(M,"combat")] at [log_loc(owner)].")



///////////////////////////////////////////// Vampire spell parent //////////////////////////////////////////////////

// If you change the blood cost, cooldown etc of an ability, don't forget to update vampireTips.html too!

// Notes:
// - If an ability isn't available from the beginning, add an unlock_message to notify the player of unlocks.
// - Vampire abilities are logged. Please keep it that way when you make additions.
// - Add this snippet at the bottom of cast() if the ability isn't free. Optional but basic feedback for the player.
//		var/datum/abilityHolder/vampire/AH = holder
//		AH.blood_tracking_output(src.pointCost)
//		- You should also call the proc if you make the player pay for an interrupted attempt to use the ability, for
//		  instance when employing do_mob() checks.

/datum/targetable/vampire
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "vampire-template"
	preferred_holder_type = /datum/abilityHolder/vampire
	can_cast_while_cuffed = TRUE
	var/not_when_in_an_object = TRUE
	var/unlock_message = null

	onAttach(var/datum/abilityHolder/H)
		. = ..()
		if (src.unlock_message && src.holder && src.holder.owner)
			boutput(src.holder.owner, "<span class='notice'><h3>[src.unlock_message]</h3></span>")

	castcheck(atom/target)
		if(isobj(holder.owner)) //Exception for VampTEG and Sentient Objects...
			return TRUE

		var/mob/M = holder.owner // this is a safe assumption until some chucklefuck gives the floor an abilityHolder

		if (src.not_when_in_an_object && !isturf(M.loc))
			boutput(M, "<span class='alert'>You can't use this ability while you're inside another object.</span>")
			return FALSE

		if (istype(get_area(M), /area/station/chapel) && !M.check_vampire_power(VAMP_POWER_MAXIMUM) && !(M.job == "Chaplain"))
			boutput(M, "<span class='alert'>Your powers do not work in this holy place! Maybe if you were more powerful...</span>")
			return FALSE

		return TRUE
