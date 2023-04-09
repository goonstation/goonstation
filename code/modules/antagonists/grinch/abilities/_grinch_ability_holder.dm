// Converted everything related to grinches from client procs to ability holders and used
// the opportunity to do some clean-up as well (Convair880).

//////////////////////////////////////////// Ability holder /////////////////////////////////////////

/atom/movable/screen/ability/topBar/grinch
	clicked(params)
		var/datum/targetable/grinch/spell = owner
		if (!istype(spell))
			return
		if (!spell.holder)
			return
		if (!isturf(owner.holder.owner.loc))
			boutput(owner.holder.owner, "<span class='alert'>You can't use this ability here.</span>")
			return
		if (spell.targeted && usr.targeting_ability == owner)
			usr.targeting_ability = null
			usr.update_cursor()
			return
		if (spell.targeted)
			if (spell.cooldowncheck())
				return
			owner.holder.owner.targeting_ability = owner
			owner.holder.owner.update_cursor()
		else
			SPAWN(0)
				spell.handleCast()
		return

/datum/abilityHolder/grinch
	usesPoints = 0
	regenRate = 0
	tabName = "Grinch"
	notEnoughPointsMessage = "<span class='alert'>You aren't strong enough to use this ability.</span>"

/////////////////////////////////////////////// Grinch spell parent ////////////////////////////

/datum/targetable/grinch
	icon = 'icons/mob/grinch_ui.dmi'
	icon_state = "grinchtemplate"
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/grinch
	can_cast_while_cuffed = TRUE

	New()
		var/atom/movable/screen/ability/topBar/grinch/B = new /atom/movable/screen/ability/topBar/grinch(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B

	updateObject()
		..()
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/grinch()
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
		if (!holder)
			return 0

		var/mob/living/M = holder.owner

		if (!M)
			return 0

		if (!(ishuman(M) || ismobcritter(M)))
			boutput(M, "<span class='alert'>You cannot use any powers in your current form.</span>")
			return 0

		if (M.transforming)
			boutput(M, "<span class='alert'>You can't use any powers right now.</span>")
			return 0

		if (incapacitation_check(src.incapacitation_restriction) != 1)
			boutput(M, "<span class='alert'>You can't use this ability while incapacitated!</span>")
			return 0

		if (src.can_cast_while_cuffed == FALSE && M.restrained())
			boutput(M, "<span class='alert'>You can't use this ability when restrained!</span>")
			return 0

		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
