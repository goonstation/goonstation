/obj/screen/ability/topBar/critter
	clicked(params)
		var/datum/targetable/critter/spell = owner
		if (!istype(spell))
			return
		if (!spell.holder)
			return
		if (!isturf(usr.loc))
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
			SPAWN_DBG(0)
				spell.handleCast()
		return

/datum/abilityHolder/critter
	usesPoints = 0
	regenRate = 0
	tabName = "Abilities"
	topBarRendered = 1
	rendered = 1


// ----------------------------------------
// Generic abilities that critters may have
// ----------------------------------------

/datum/targetable/critter
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "template"  // TODO.
	cooldown = 0
	last_cast = 0
	var/disabled = 0
	var/toggled = 0
	var/is_on = 0   // used if a toggle ability
	preferred_holder_type = /datum/abilityHolder/critter

	New()
		..()
		var/obj/screen/ability/topBar/critter/B = new /obj/screen/ability/topBar/critter(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B

	updateObject()
		..()
		if (!src.object)
			src.object = new /obj/screen/ability/topBar/critter()
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
		return M.restrained() || M.stat || M.hasStatus(list("paralysis", "stunned", "weakened"))

	castcheck()
		if (incapacitationCheck())
			boutput(holder.owner, __red("Not while incapacitated."))
			return 0
		if (disabled)
			boutput(holder.owner, __red("You cannot use that ability at this time."))
			return 0
		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
