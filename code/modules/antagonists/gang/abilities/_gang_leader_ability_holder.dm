/atom/movable/screen/ability/topBar/gang
	clicked(params)
		var/datum/targetable/gang/spell = owner
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
				boutput(usr, SPAN_NOTICE("Please press a number to bind this ability to..."))
				return

		if (!isturf(owner.holder.owner.loc))
			boutput(owner.holder.owner, SPAN_ALERT("You can't use this spell here."))
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
			SPAWN(0)
				spell.handleCast()
		return


/* 	/		/		/		/		/		/		Ability Holder		/		/		/		/		/		/		/		/		*/

/datum/abilityHolder/gang
	usesPoints = 0
	regenRate = 0
	tabName = "gang"
	// notEnoughPointsMessage = SPAN_ALERT("You need more blood to use this ability.")
	points = 0
	pointName = "points"
	var/stealthed = 0
	var/const/MAX_POINTS = 100

	New()
		..()


	disposing()
		..()

	onLife(var/mult = 1)
		if(..()) return


/datum/targetable/gang
	icon = 'icons/mob/gang_abilities.dmi'
	icon_state = "gang-template"
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/gang
	var/when_stunned = 0 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = 0
	var/unlock_message = null
	var/can_cast_anytime = 0		//while alive

	New()
		var/atom/movable/screen/ability/topBar/gang/B = new /atom/movable/screen/ability/topBar/gang(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B
		return

	onAttach(var/datum/abilityHolder/H)
		..()
		if (src.unlock_message && src.holder && src.holder.owner)
			boutput(src.holder.owner, SPAN_NOTICE("<h3>[src.unlock_message]</h3>"))
		return

	updateObject()
		..()
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/gang()
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

	castcheck()
		if (!holder)
			return 0

		var/mob/living/M = holder.owner

		if (!M)
			return 0

		if (!(iscarbon(M) || ismobcritter(M)))
			boutput(M, SPAN_ALERT("You cannot use any powers in your current form."))
			return 0

		if (can_cast_anytime && !isdead(M))
			return 1
		if (!can_act(M, 0))
			boutput(M, SPAN_ALERT("You can't use this ability while incapacitated!"))
			return 0

		if (src.not_when_handcuffed && M.restrained())
			boutput(M, SPAN_ALERT("You can't use this ability when restrained!"))
			return 0

		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return


/datum/targetable/gang/locker_spot
	name = "Show locker location"
	desc = "Points you towards the location of your locker."
	icon_state = "find_locker"
	do_logs = FALSE
	interrupt_action_bars = FALSE

	cast()
		if (!holder)
			return TRUE

		var/mob/living/M = holder.owner

		if (!M)
			return TRUE

		if (!M.mind || !M.get_gang())
			boutput(M, SPAN_ALERT("Gang lockers? Huh?"))
			return TRUE
		var/datum/gang/userGang = M.get_gang()
		var/obj/ganglocker/locker = userGang.locker
		if (!locker)
			boutput(M, SPAN_ALERT("Your gang doesn't have a locker!"))
			return TRUE
		if (M.GetComponent(/datum/component/tracker_hud/gang))
			return TRUE
		. = ..()
		M.AddComponent(/datum/component/tracker_hud/gang, get_turf(locker))
		SPAWN(3 SECONDS)
			var/datum/component/tracker_hud/gang/component = M.GetComponent(/datum/component/tracker_hud/gang)
			component.RemoveComponent()
		return FALSE


/datum/targetable/gang/toggle_overlay
	name = "Toggle gang territory overlay"
	desc = "Toggles the colored gang overlay."
	icon_state = "toggle_overlays"
	do_logs = FALSE
	interrupt_action_bars = FALSE
	var/datum/mind/ownerMind

	proc/remove_self(mind)
		var/datum/client_image_group/imgroup = get_image_group(CLIENT_IMAGE_GROUP_GANGS)
		if (imgroup.subscribed_minds_with_subcount[mind] > 0)
			imgroup.remove_mind(mind)
	cast(mob/target)
		if (!holder)
			return TRUE

		var/mob/living/M = holder.owner

		if (!M)
			return TRUE

		if (!M.mind && !M.get_gang())
			boutput(M, SPAN_ALERT("Gang territory? What? You'd need to be in a gang to get it."))
			return TRUE
		. = ..()
		ownerMind = M.mind
		var/datum/client_image_group/imgroup = get_image_group(CLIENT_IMAGE_GROUP_GANGS)
		var/togglingOn = FALSE
		if (imgroup.subscribed_minds_with_subcount[M.mind] > 0)
			imgroup.remove_mind(ownerMind)
			UnregisterSignal(ownerMind, COMSIG_MIND_DETACH_FROM_MOB)
		else
			togglingOn = TRUE
			imgroup.add_mind(ownerMind)
			RegisterSignal(ownerMind, COMSIG_MIND_DETACH_FROM_MOB, PROC_REF(remove_self))

		boutput(M, "Gang territories turned [togglingOn ? "on" : "off"].")
		return FALSE
	disposing()
		var/datum/client_image_group/imgroup = get_image_group(CLIENT_IMAGE_GROUP_GANGS)
		if (imgroup.subscribed_minds_with_subcount[ownerMind] > 0)
			imgroup.remove_mind(ownerMind)
		UnregisterSignal(ownerMind, COMSIG_MIND_DETACH_FROM_MOB)
		..()

/datum/targetable/gang/set_gang_base
	name = "Set Gang Base"
	desc = "Permanently sets the area you're currently in as your gang's base and spawns your gang's locker."
	icon_state = "set-gang-base"
	targeted = 0
	can_cast_anytime = 1

	proc/check_valid(mob/M, area/targetArea)
		var/turf/T = get_turf(M)
		if(!istype(targetArea, /area/station) || get_z(T) != Z_LEVEL_STATION)
			boutput(M, SPAN_ALERT("You can only set your gang's base on the station."))
			return FALSE

		if(M.stat)
			boutput(M, SPAN_ALERT("Not when you're incapacitated."))
			return FALSE
		var/datum/antagonist/gang_leader/antag_role = M.mind.get_antagonist(ROLE_GANG_LEADER)
		//stop people setting up a locker they can't place
		if (T.controlling_gangs && !T.controlling_gangs[antag_role.gang])
			boutput(M, SPAN_ALERT("You can't place your base in another gang's turf!"))
			return FALSE
		for (var/obj/ganglocker/locker in range(2*GANG_TAG_INFLUENCE, T))
			if(locker.gang == antag_role.gang || !IN_EUCLIDEAN_RANGE(locker, T, 2*GANG_TAG_INFLUENCE)) continue
			boutput(M, SPAN_ALERT("You can't place your base so close to another gang's locker!"))
			return FALSE

		if((targetArea.teleport_blocked) || istype(targetArea, /area/supply) || istype(targetArea, /area/shuttle/))
			boutput(M, SPAN_ALERT("You can't place your base here!"))
			return FALSE
		return TRUE
	proc/confirm(mob/M)
		var/datum/antagonist/gang_leader/antag_role = M.mind.get_antagonist(ROLE_GANG_LEADER)
		antag_role.gang.select_gang_uniform()
		return TRUE

	proc/after_cast(mob/M, area/area, datum/antagonist/gang_leader/antag_role)
		for(var/datum/mind/member in antag_role.gang.members)
			boutput(member.current, SPAN_ALERT("Your gang's base has been set up in [area]!"))

		var/obj/ganglocker/locker = new /obj/ganglocker(get_turf(M))
		locker.set_gang(antag_role.gang)
		antag_role.gang.locker = locker
		locker.post_move_locker()

		M.abilityHolder.removeAbility(/datum/targetable/gang/set_gang_base)
		var/datum/targetable/gang/set_gang_base/migrate/newAbil = M.abilityHolder.addAbility(/datum/targetable/gang/set_gang_base/migrate)
		newAbil.doCooldown()

	cast()
		var/mob/M = holder.owner
		var/area/area = get_area(M)

		if (!check_valid(M, area))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		var/datum/antagonist/gang_leader/antag_role = M.mind.get_antagonist(ROLE_GANG_LEADER)
		if (!antag_role)
			return

		. = ..()
		if (!src.confirm(M))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (!check_valid(M, area))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		after_cast(M,area,antag_role)
		return



	migrate
		name = "Migrate Gang Base"
		desc = "Moves your locker to another area inside your gang's territory."
		icon_state = "reset-gang-base"
		targeted = 0
		can_cast_anytime = 1
		cooldown = 15 MINUTES

		check_valid(mob/M, area/targetArea)

			var/datum/gang/userGang = M.get_gang()
			//stop people setting up a locker they can't place
			var/turf/T = get_turf(M)
			if (!T.controlling_gangs || !T.controlling_gangs[userGang])
				boutput(M, SPAN_ALERT("You can only move your base to your turf!"))
				return FALSE
			. = ..()
			return .

		confirm(mob/M)
			var/result = tgui_alert(M, "Are you sure you want to move your locker here?", "Move Gang Base", list("Yes", "No"), 30 SECONDS)
			return (result == "Yes")


		after_cast(mob/M, area/area, datum/antagonist/gang_leader/antag_role)
			for(var/datum/mind/member in antag_role.gang.members)
				boutput(member.current, SPAN_ALERT("Your gang's base has been moved to \the [area]!"))

			var/obj/ganglocker/locker = antag_role.gang.locker
			if (!locker) //just in case some Wicked Loser has managed to find out a locker-deleting exploit or something
				locker = new /obj/ganglocker(get_turf(M))
				locker.set_gang(antag_role.gang)
				antag_role.gang.locker = locker
				locker.post_move_locker()
			else
				locker.pre_move_locker()
				locker.set_loc(get_turf(M))
				locker.post_move_locker()


			return CAST_ATTEMPT_SUCCESS
