/* 	/		/		/		/		/		/		Ability Holder		/		/		/		/		/		/		/		/		*/

/datum/abilityHolder/pod_pilot
	usesPoints = 0
	regenRate = 0
	tabName = "pod_pilot"
	// notEnoughPointsMessage = "<span class='alert'>You need more blood to use this ability.</span>"
	points = 0
	pointName = "points"

	New()
		..()
		add_all_abilities()


	disposing()
		..()

	onLife(var/mult = 1)
		if(..()) return

	proc/add_all_abilities()
		src.addAbility(/datum/targetable/pod_pilot/scoreboard)

//can't remember why I did this as an ability. Probably better to add directly like I did in kudzumen, but later... -kyle
//Wait, maybe I never used this. I can't remember, it's too late now to think and I'll just keep it in case I secretly had a good reason to do this.
/datum/targetable/pod_pilot
	icon = 'icons/mob/pod_pilot_abilities.dmi'
	icon_state = "template"
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/pod_pilot
	var/when_stunned = 0 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = 0
	var/unlock_message = null
	var/can_cast_anytime = 0		//while alive

	New()
		var/atom/movable/screen/ability/topBar/pod_pilot/B = new /atom/movable/screen/ability/topBar/pod_pilot(null)
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
			boutput(src.holder.owner, "<span class='notice'><h3>[src.unlock_message]</h3></span>")
		return

	updateObject()
		..()
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/pod_pilot()
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
			boutput(M, "<span class='alert'>You cannot use any powers in your current form.</span>")
			return 0
		if (can_cast_anytime && !isdead(M))
			return 1
		if (!can_act(M, 0))
			boutput(M, "<span class='alert'>You can't use this ability while incapacitated!</span>")
			return 0

		if (src.not_when_handcuffed && M.restrained())
			boutput(M, "<span class='alert'>You can't use this ability when restrained!</span>")
			return 0

		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return

/datum/targetable/pod_pilot/scoreboard
	name = "scoreboard"
	desc = "How many scores do we have?"
	icon = 'icons/mob/pod_pilot_abilities.dmi'
	icon_state = "empty"
	targeted = 0
	cooldown = 0
	special_screen_loc = "NORTH,CENTER-2"

	onAttach(var/datum/abilityHolder/H)
		object.mouse_opacity = 0
		// object.maptext_y = -32
		if (istype(ticker.mode, /datum/game_mode/pod_wars))
			var/datum/game_mode/pod_wars/mode = ticker.mode
			object.vis_contents += mode.board
		return


