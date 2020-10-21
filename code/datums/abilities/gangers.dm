//stole this from vampire. prevents runtimes. IDK why this isn't in the parent.
/obj/screen/ability/topBar/gang
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


/* 	/		/		/		/		/		/		Ability Holder		/		/		/		/		/		/		/		/		*/

/datum/abilityHolder/gang
	usesPoints = 0
	regenRate = 0
	tabName = "gang"
	// notEnoughPointsMessage = "<span class='alert'>You need more blood to use this ability.</span>"
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
		var/obj/screen/ability/topBar/gang/B = new /obj/screen/ability/topBar/gang(null)
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
			boutput(src.holder.owner, __blue("<h3>[src.unlock_message]</h3>"))
		return

	updateObject()
		..()
		if (!src.object)
			src.object = new /obj/screen/ability/topBar/gang()
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
			boutput(M, __red("You cannot use any powers in your current form."))
			return 0

		if (can_cast_anytime && !isdead(M))
			return 1
		if (!can_act(M, 0))
			boutput(M, __red("You can't use this ability while incapacitated!"))
			return 0

		if (src.not_when_handcuffed && M.restrained())
			boutput(M, __red("You can't use this ability when restrained!"))
			return 0

		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return

/datum/targetable/gang/set_gang_base
	name = "Set Gang Base"
	desc = "Permanently sets the area you're currently in as your gang's base and spawns your gang's locker."
	icon_state = "set-gang-base"
	targeted = 0
	can_cast_anytime = 1

	cast()
		var/mob/M = holder.owner
		var/area/area = get_area(M)

		if(area.gang_base)
			boutput(M, "<span class='alert'>Another gang's base is in this area!</span>")
			return

		if(M.stat)
			boutput(M, "<span class='alert'>Not when you're incapacitated.</span>")
			return

		if (istype(ticker.mode, /datum/game_mode/gang))
			var/datum/game_mode/gang/mode = ticker.mode
			mode.uniform_prompt(M.mind)
		else
			boutput(M, "<span class='alert'>The round's mode isn't Gang, you can't place a locker here!.</span>")
			return

		M.mind.gang.base = area
		area.gang_base = 1

		for(var/obj/decal/cleanable/gangtag/G in area)
			if(G.owners == M.mind.gang) continue
			var/obj/decal/cleanable/gangtag/T = make_cleanable(/obj/decal/cleanable/gangtag,G.loc)
			T.icon_state = "gangtag[M.mind.gang.gang_tag]"
			T.name = "[M.mind.gang.gang_name] tag"
			T.owners = M.mind.gang
			T.delete_same_tags()
			break

		var/obj/ganglocker/locker = new /obj/ganglocker(usr.loc)
		locker.name = "[M.mind.gang.gang_name] Locker"
		locker.desc = "A locker with a small screen attached to the door, and the words 'Property of [usr.mind.gang.gang_name] - DO NOT TOUCH!' scratched into both sides."
		locker.gang = M.mind.gang
		ticker.mode:gang_lockers += locker
		M.mind.gang.locker = locker
		locker.update_icon()

		M.abilityHolder.removeAbility(/datum/targetable/gang/set_gang_base)

		return
