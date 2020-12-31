// Converted everything related to vampires from client procs to ability holders and used
// the opportunity to do some clean-up as well (Convair880).

/* 	/		/		/		/		/		/		Setup		/		/		/		/		/		/		/		/		*/

/mob/proc/make_vampire(var/shitty = 0)
	if (ishuman(src) || ismobcritter(src))
		if (ishuman(src))
			var/datum/abilityHolder/vampire/A = src.get_ability_holder(/datum/abilityHolder/vampire)
			if (A && istype(A))
				return

			var/datum/abilityHolder/vampire/V = src.add_ability_holder(/datum/abilityHolder/vampire)

			if(shitty) // Infernal vampire.
				V.addAbility(/datum/targetable/vampire/blood_tracking)
			else
				V.addAbility(/datum/targetable/vampire/vampire_bite)
				V.addAbility(/datum/targetable/vampire/blood_steal)
				V.addAbility(/datum/targetable/vampire/blood_tracking)
				V.addAbility(/datum/targetable/vampire/cancel_stuns)
				V.addAbility(/datum/targetable/vampire/glare)
				V.addAbility(/datum/targetable/vampire/hypnotize)

			SPAWN_DBG(2.5 SECONDS) // Don't remove.
				if (src) src.assign_gimmick_skull()

		else if (ismobcritter(src)) // For testing. Just give them all abilities that are compatible.
			var/mob/living/critter/C = src

			if (isnull(C.abilityHolder)) // They do have a critter AH by default...or should.
				var/datum/abilityHolder/vampire/A2 = C.add_ability_holder(/datum/abilityHolder/vampire)
				if (!A2 || !istype(A2, /datum/abilityHolder/))
					return

			if(shitty) // Infernal vampire.
				C.abilityHolder.addAbility(/datum/targetable/vampire/blood_tracking)
			else
				C.abilityHolder.addAbility(/datum/targetable/vampire/cancel_stuns)
				C.abilityHolder.addAbility(/datum/targetable/vampire/glare)
				C.abilityHolder.addAbility(/datum/targetable/vampire/hypnotize)
				C.abilityHolder.addAbility(/datum/targetable/vampire/plague_touch)
				C.abilityHolder.addAbility(/datum/targetable/vampire/phaseshift_vampire)
				C.abilityHolder.addAbility(/datum/targetable/vampire/call_bats)
				C.abilityHolder.addAbility(/datum/targetable/vampire/vampire_scream)
				C.abilityHolder.addAbility(/datum/targetable/vampire/enthrall)

		if (src.mind && src.mind.special_role != "omnitraitor")
			if(shitty)
				boutput(src, "<span class='notice'>Oh shit, your fangs just broke off! Looks like you'll have to get blood the HARD way.</span>")

			SHOW_VAMPIRE_TIPS(src)

	else return

////////////////////////////////////////////////// Helper procs ////////////////////////////////////////////////

// Just a little helper or two since vampire parameters aren't tracked by mob vars anymore.
/mob/proc/get_vampire_blood(var/total_blood = 0)
	if (!isvampire(src))
		return 0

	var/datum/abilityHolder/vampire/AH = src.get_ability_holder(/datum/abilityHolder/vampire)
	if (AH && istype(AH))
		if (total_blood)
			return AH.vamp_blood
		else
			return AH.points
	else
		return 0

/mob/proc/change_vampire_blood(var/change = 0, var/total_blood = 0, var/set_null = 0)
	if (!isvampire(src) && !isvampiriczombie(src))
		return

	var/datum/abilityHolder/vampire/AH = src.get_ability_holder(/datum/abilityHolder/vampire)
	if (AH && istype(AH))
		if (total_blood)
			if (AH.vamp_blood < 0)
				AH.vamp_blood = 0
				if (haine_blood_debug) logTheThing("debug", src, null, "<b>HAINE BLOOD DEBUG:</b> [src]'s vamp_blood dropped below 0 and was reset to 0")

			if (set_null == 1)
				AH.vamp_blood = 0
			else
				AH.vamp_blood = max(AH.vamp_blood + change, 0)

		else
			if (AH.points < 0)
				AH.points = 0
				if (haine_blood_debug) logTheThing("debug", src, null, "<b>HAINE BLOOD DEBUG:</b> [src]'s vamp_blood_remaining dropped below 0 and was reset to 0")

			if (set_null == 1)
				AH.points = 0
			else
				AH.points = max(AH.points + change, 0)
	else
		var/datum/abilityHolder/vampiric_zombie/AHZ = src.get_ability_holder(/datum/abilityHolder/vampiric_zombie)
		if(AHZ && istype(AHZ) && !total_blood)
			var/mob/living/carbon/human/M = AHZ.owner
			if(istype(M) && istype(M.mutantrace, /datum/mutantrace/vamp_zombie))
				var/datum/mutantrace/vamp_zombie/V = M.mutantrace
				if (V.blood_points < 0)
					V.blood_points = 0
					if (haine_blood_debug) logTheThing("debug", src, null, "<b>HAINE BLOOD DEBUG:</b> [src]'s blood_points dropped below 0 and was reset to 0")

				if (set_null == 1)
					V.blood_points = 0
				else
					V.blood_points = max(V.blood_points + change, 0)

	return

/mob/proc/check_vampire_power(var/which_power = 3) // 1: thermal | 2: xray | 3: full power
	if (!isvampire(src))
		return 0

	if (!which_power)
		return 0

	var/datum/abilityHolder/vampire/AH = src.get_ability_holder(/datum/abilityHolder/vampire)
	if (AH && istype(AH))
		switch (which_power)
			if (1)
				if (AH.has_thermal == 1)
					return 1
				else
					return 0

			if (2)
				if (AH.has_xray == 1)
					return 1
				else
					return 0

			if (3)
				if (AH.has_fullpower == 1)
					return 1
				else
					return 0

			else
				return 0
	else
		return 0

////////////////////////////////////////////////// Ability holder /////////////////////////////////////////////

/obj/screen/ability/topBar/vampire
	clicked(params)
		var/datum/targetable/vampire/spell = owner
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
				src.updateIcon()
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
			owner.holder.owner.targeting_ability = owner
			owner.holder.owner.update_cursor()
		else
			SPAWN_DBG(0)
				spell.handleCast()
		return

/datum/abilityHolder/vampire
	usesPoints = 1
	regenRate = 0
	tabName = "Vampire"
	notEnoughPointsMessage = "<span class='alert'>You need more blood to use this ability.</span>"
	var/vamp_blood = 0
	points = 0 // Replaces the old vamp_blood_remaining var.
	var/vamp_blood_tracking = 1
	var/mob/vamp_isbiting = null

	// Note: please use mob.get_vampire_blood() & mob.change_vampire_blood() instead of changing the numbers directly.

	// At the time of writing, sight (thermal, x-ray) and chapel checks can be found in human.dm.
	var/has_thermal = 0
	var/has_xray = 0
	var/has_fullpower = 0

	// These are thresholds in relation to vamp_blood. Last_power exists only for unlock checks as stuff
	// might deduct something from vamp_blood, though it shouldn't happen on a regular basis.
	var/last_power = 0
	var/level1 = 5
	var/level2 = 300
	var/level3 = 600
	var/level4 = 900
	var/level5 = 1400
	var/level6 = 1800 // Full power.

	var/list/ghouls = list()
	var/turf/coffin_turf = 0

	var/traveling_to_coffin = 0 //shitty projectile hacky fix
	//theres a bug where projectiles get unpooled and moved elsewhere before theyre done with their currnent firing
	//badly affects 'travel' projectile. band aid.

	onAbilityStat() // In the 'Vampire' tab.
		..()
		.= list()
		.["Blood:"] = round(src.points)
		.["Total:"] = round(src.vamp_blood)
		return

	onLife(var/mult = 1)
		..()
		if (traveling_to_coffin && isturf(owner.loc) && istype(traveling_to_coffin,/obj/storage/closet/coffin))
			owner.set_loc(traveling_to_coffin)

		if (istype(owner.loc,/obj/storage/closet/coffin))
			traveling_to_coffin = 0
			if (isdead(owner))
				owner.full_heal()
			else
				changeling_super_heal_step(healed = owner, mult = mult*2, changer = 0)

	set_loc_callback(newloc)
		if (istype(newloc,/obj/storage/closet/coffin))
			//var/obj/storage/closet/coffin/C = newloc
			traveling_to_coffin = 0

	proc/blood_tracking_output(var/deduct = 0)
		if (!src.owner || !ismob(src.owner))
			return

		if (!istype(src, /datum/abilityHolder/vampire))
			return

		if (!src.vamp_blood_tracking)
			return

		if (deduct > 1)
			boutput(src.owner, __blue("You used [deduct] units of blood, and have [src.points - deduct] remaining."))

		else
			boutput(src.owner, __blue("You have accumulated [src.vamp_blood] units of blood and [src.points] left to use."))

		return

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
			boutput(src.owner, __blue("<h3>Your vampiric vision has improved (thermal)!</h3>"))

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

		if (src.last_power == 4 && src.vamp_blood >= src.level5)
			src.last_power = 5

			src.removeAbility(/datum/targetable/vampire/vampire_scream)
			src.addAbility(/datum/targetable/vampire/vampire_scream/mk2)
			src.addAbility(/datum/targetable/vampire/plague_touch)

		if (src.last_power == 5 && src.vamp_blood >= src.level6)
			src.last_power = 6

			src.has_xray = 1
			src.has_fullpower = 1
			//boutput(src.owner, __blue("<h3>Your vampiric vision has improved (x-ray)!</h3>"))
			boutput(src.owner, __blue("<h3>You have attained full power and are now too powerful to be harmed or stopped by the chapel's aura.</h3>"))

		return

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

	proc/transmit_ghoul_msg(var/message,var/mob/sender)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

		if (!message)
			return

		if (dd_hasprefix(message, "*"))
			return

		logTheThing("diary", sender, null, "(GHOULSPEAK): [message]", "ghoulsay")

		if (sender.client && sender.client.ismuted())
			boutput(sender, "You are currently muted and may not speak.")
			return

		sender.say_ghoul(message, src)


	proc/remove_thrall(var/mob/victim)
		remove_mindslave_status(victim)
		ghouls -= victim

	proc/make_thrall(var/mob/victim)
		if (ishuman(victim))

			var/mob/living/M = victim


			if (!M.mind && !M.client)
				if (M.ghost && M.ghost.client && !(M.ghost.mind && M.ghost.mind.dnr))
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

			if (M.bioHolder && M.traitHolder.hasTrait("training_chaplain"))
				boutput(owner, __red("Wait, this is a chaplain!!! <B>AGDFHSKFGBLDFGLHSFDGHDFGH</B>"))
				boutput(M, __blue("Your divine protection saves you from enthrallment!"))
				owner.emote("scream")
				owner.changeStatus("weakened", 5 SECONDS)
				owner.TakeDamage("chest", 0, 30)
				return


			M.real_name = "zombie [M.real_name]"
			if (M.mind)
				M.mind.special_role = "vampthrall"
				M.mind.master = owner.ckey
				if (!(M.mind in ticker.mode.Agimmicks))
					ticker.mode.Agimmicks += M.mind

			ghouls += M

			M.set_mutantrace(/datum/mutantrace/vamp_zombie)
			var/datum/abilityHolder/vampiric_zombie/VZ = M.get_ability_holder(/datum/abilityHolder/vampiric_zombie)
			if (VZ && istype(VZ))
				VZ.master = src

			boutput(M, __red("<b>You awaken filled with purpose - you must serve your master vampire, [owner.real_name]!</B>"))
			SHOW_MINDSLAVE_TIPS(M)

			boutput(owner, __blue("[M] has been revived as your thrall."))
			logTheThing("combat", owner, M, "enthralled [constructTarget(M,"combat")] at [log_loc(owner)].")



///////////////////////////////////////////// Vampire spell parent //////////////////////////////////////////////////

// If you change the blood cost, cooldown etc of an ability, don't forget to update vampireTips.html too!

// Notes:
// - If an ability isn't available from the beginning, add an unlock_message to notify the player of unlocks.
// - Vampire abilities are logged. Please keep it that way when you make additions.
// - Add this snippet at the bottom of cast() if the ability isn't free. Optional but basic feedback for the player.
//		var/datum/abilityHolder/vampire/H = holder
//		if (istype(H)) H.blood_tracking_output(src.pointCost)
//		- You should also call the proc if you make the player pay for an interrupted attempt to use the ability, for
//		  instance when employing do_mob() checks.

/datum/targetable/vampire
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "vampire-template"
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/vampire
	var/when_stunned = 0 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = 0
	var/unlock_message = null

	New()
		var/obj/screen/ability/topBar/vampire/B = new /obj/screen/ability/topBar/vampire(null)
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
			boutput(src.holder.owner, __blue("<h3>[src.unlock_message]</h3>"))
		return

	updateObject()
		..()
		if (!src.object)
			src.object = new /obj/screen/ability/topBar/vampire()
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
			boutput(M, __red("You cannot use any powers in your current form."))
			return 0

		if (M.transforming)
			boutput(M, __red("You can't use any powers right now."))
			return 0

		if (incapacitation_check(src.when_stunned) != 1)
			boutput(M, __red("You can't use this ability while incapacitated!"))
			return 0

		if (src.not_when_handcuffed == 1 && M.restrained())
			boutput(M, __red("You can't use this ability when restrained!"))
			return 0

		if (istype(get_area(M), /area/station/chapel) && M.check_vampire_power(3) != 1)
			boutput(M, __red("Your powers do not work in this holy place!"))
			return 0

		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return
