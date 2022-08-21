// Converted everything related to grinches from client procs to ability holders and used
// the opportunity to do some clean-up as well (Convair880).

//////////////////////////////////////////// Setup //////////////////////////////////////////////////

/mob/proc/make_grinch()
	if (ishuman(src) || ismobcritter(src))
		if (ishuman(src))
			var/datum/abilityHolder/grinch/A = src.get_ability_holder(/datum/abilityHolder/grinch)
			if (A && istype(A))
				return

			var/datum/abilityHolder/grinch/G = src.add_ability_holder(/datum/abilityHolder/grinch)
			G.addAbility(/datum/targetable/grinch/vandalism)
			G.addAbility(/datum/targetable/grinch/poison)
			G.addAbility(/datum/targetable/grinch/instakill)
			G.addAbility(/datum/targetable/grinch/grinch_cloak)

			SPAWN(2.5 SECONDS) // Don't remove.
				if (src) src.assign_gimmick_skull()

		else if (ismobcritter(src))
			var/mob/living/critter/C = src

			if (isnull(C.abilityHolder)) // They do have a critter AH by default...or should.
				var/datum/abilityHolder/grinch/A2 = C.add_ability_holder(/datum/abilityHolder/grinch)
				if (!A2 || !istype(A2, /datum/abilityHolder/))
					return

			C.abilityHolder.addAbility(/datum/targetable/grinch/vandalism)
			C.abilityHolder.addAbility(/datum/targetable/grinch/poison)
			C.abilityHolder.addAbility(/datum/targetable/grinch/instakill)
			C.abilityHolder.addAbility(/datum/targetable/grinch/grinch_cloak)

		if (src.mind && src.mind.special_role != ROLE_OMNITRAITOR)
			src.show_antag_popup("grinch")

	else return

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
			if (world.time < spell.last_cast)
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
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/grinch
	var/when_stunned = 0 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = 0

	New()
		var/atom/movable/screen/ability/topBar/grinch/B = new /atom/movable/screen/ability/topBar/grinch(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B
		return

	updateObject()
		..()
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/grinch()
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

		if (!(ishuman(M) || ismobcritter(M)))
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

		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return
