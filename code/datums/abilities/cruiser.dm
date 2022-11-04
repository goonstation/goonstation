/atom/movable/screen/ability/topBar/cruiser
	clicked(params)
		var/datum/targetable/cruiser/spell = owner
		var/datum/abilityHolder/holder = owner.holder


		if(params["left"] && params["ctrl"])
			if(owner.waiting_for_hotkey)
				holder.cancel_action_binding()
			else
				owner.waiting_for_hotkey = 1
				boutput(usr, "<span class='notice'>Please press a number to bind this ability to...</span>")
		else if(params["left"])
			if (!istype(spell))
				return
			if (!spell.holder)
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

		owner.holder.updateButtons()

/datum/abilityHolder/cruiser
	topBarRendered = 1
	usesPoints = 0
	regenRate = 0
	tabName = "Cruiser Controls"

// ----------------------------------------
// Controls for the cruiser ships.
// ----------------------------------------

/datum/targetable/cruiser
	icon = 'icons/mob/cruiser_ui.dmi'
	icon_state = ""
	cooldown = 0
	last_cast = 0
	check_range = 0
	var/disabled = 0
	var/toggled = 0
	var/is_on = 0   // used if a toggle ability
	preferred_holder_type = /datum/abilityHolder/cruiser
	ignore_sticky_cooldown = 1

	New()
		var/atom/movable/screen/ability/topBar/cruiser/B = new /atom/movable/screen/ability/topBar/cruiser(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B

	updateObject()
		..()
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/cruiser()
			object.icon = src.icon
			object.owner = src
		if (disabled)
			object.name = "[src.name] (unavailable)"
			object.icon_state = src.icon_state + "_cd"
		else if (src.last_cast > world.time)
			object.name = "[src.name] ([round((src.last_cast-world.time)/10)])"
			object.icon_state = src.icon_state + "_cd"
		else if (toggled)
			if (is_on)
				object.name = "[src.name] (on)"
				object.icon_state = src.icon_state
			else
				object.name = "[src.name] (off)"
				object.icon_state = src.icon_state + "_cd"
		else
			object.name = src.name
			object.icon_state = src.icon_state

	proc/incapacitationCheck()
		var/mob/living/M = holder.owner
		return M.restrained() || is_incapacitated(M)

	castcheck()
		if (incapacitationCheck())
			boutput(holder.owner, "<span class='alert'>Not while incapacitated.</span>")
			return 0
		if (disabled)
			boutput(holder.owner, "<span class='alert'>You cannot use that ability at this time.</span>")
			return 0
		return 1

	doCooldown()
		if (!holder)
			return
		last_cast = world.time + cooldown
		holder.updateButtons()
		SPAWN(cooldown + 5)
			holder.updateButtons()

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
