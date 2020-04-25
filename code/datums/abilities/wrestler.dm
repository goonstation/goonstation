// Converted everything related to wrestlers from client procs to ability holders and used
// the opportunity to do some clean-up as well (Convair880).

//////////////////////////////////////////// Setup //////////////////////////////////////////////////

/mob/proc/make_wrestler(var/make_inherent = 0, var/belt_check = 0, var/remove_powers = 0)
	if (ishuman(src) || iscritter(src))
		if (iscritter(src))
			var/mob/living/critter/C = src

			if (remove_powers == 1)
				var/datum/abilityHolder/wrestler/A = C.get_ability_holder(/datum/abilityHolder/wrestler)
				if (A && istype(A))
					C.remove_ability_holder(/datum/abilityHolder/wrestler)
				else
					C.abilityHolder.removeAbility(/datum/targetable/wrestler/kick)
					C.abilityHolder.removeAbility(/datum/targetable/wrestler/strike)
					C.abilityHolder.removeAbility(/datum/targetable/wrestler/drop)
					C.abilityHolder.removeAbility(/datum/targetable/wrestler/throw)
					C.abilityHolder.removeAbility(/datum/targetable/wrestler/slam)

				return

			else
				if (belt_check == 1) // They don't have belts.
					return

				if (isnull(C.abilityHolder)) // But they do have a critter AH by default...or should.
					var/datum/abilityHolder/wrestler/A2 = C.add_ability_holder(/datum/abilityHolder/wrestler)
					if (!A2 || !istype(A2, /datum/abilityHolder/))
						return

				C.abilityHolder.addAbility(/datum/targetable/wrestler/kick)
				C.abilityHolder.addAbility(/datum/targetable/wrestler/strike)
				C.abilityHolder.addAbility(/datum/targetable/wrestler/drop)
				C.abilityHolder.addAbility(/datum/targetable/wrestler/throw)
				C.abilityHolder.addAbility(/datum/targetable/wrestler/slam)

		if (ishuman(src))
			var/mob/living/carbon/human/H = src

			if (remove_powers == 1)
				var/datum/abilityHolder/wrestler/A3 = H.get_ability_holder(/datum/abilityHolder/wrestler)
				if (A3 && istype(A3))
					if (belt_check == 1 && A3.is_inherent == 1) // Wrestler/omnitraitor vs wrestling belt.
						return
					H.remove_ability_holder(/datum/abilityHolder/wrestler)
				else
					if (!isnull(H.abilityHolder))
						H.abilityHolder.removeAbility(/datum/targetable/wrestler/kick)
						H.abilityHolder.removeAbility(/datum/targetable/wrestler/strike)
						H.abilityHolder.removeAbility(/datum/targetable/wrestler/drop)
						H.abilityHolder.removeAbility(/datum/targetable/wrestler/throw)
						H.abilityHolder.removeAbility(/datum/targetable/wrestler/slam)

				return

			else
				if (belt_check == 1 && !(H.belt && istype(H.belt, /obj/item/storage/belt/wrestling)))
					return

				var/datum/abilityHolder/wrestler/A4 = H.get_ability_holder(/datum/abilityHolder/wrestler)
				if (A4 && istype(A4))
					return

				var/datum/abilityHolder/wrestler/A5 = H.add_ability_holder(/datum/abilityHolder/wrestler)
				A5.addAbility(/datum/targetable/wrestler/kick)
				A5.addAbility(/datum/targetable/wrestler/strike)
				A5.addAbility(/datum/targetable/wrestler/drop)
				A5.addAbility(/datum/targetable/wrestler/throw)
				A5.addAbility(/datum/targetable/wrestler/slam)

				if (make_inherent == 1)
					A5.is_inherent = 1

		if (belt_check != 1 && (src.mind && src.mind.special_role != "omnitraitor" && src.mind.special_role != "Faustian Wrestler"))
			SHOW_WRESTLER_TIPS(src)

	else return

//////////////////////////////////////////// Ability holder /////////////////////////////////////////

/obj/screen/ability/topBar/wrestler
	clicked(params)
		var/datum/targetable/wrestler/spell = owner
		if (!istype(spell))
			return
		if (!spell.holder)
			return
		if (owner.holder.owner) //how even
			if (!isturf(owner.holder.owner.loc))
				boutput(owner.holder.owner, "<span style=\"color:red\">You can't use this ability here.</span>")
				return
		if (spell.targeted && usr.targeting_ability == owner)
			usr.targeting_ability = null
			usr.update_cursor()
			return

		var/use_targeted = src.do_target_selection_check()
		if (use_targeted == 2)
			return
		if (spell.targeted || use_targeted == 1)
			if (world.time < spell.last_cast)
				return
			owner.holder.owner.targeting_ability = owner
			owner.holder.owner.update_cursor()
		else
			SPAWN_DBG(0)
				spell.handleCast()
		return

/datum/abilityHolder/wrestler
	usesPoints = 0
	regenRate = 0
	tabName = "Wrestler"
	notEnoughPointsMessage = "<span style=\"color:red\">You aren't strong enough to use this ability.</span>"
	var/is_inherent = 0 // Are we a wrestler as opposed to somebody with a wrestling belt?

/////////////////////////////////////////////// Wrestler spell parent ////////////////////////////

/datum/targetable/wrestler
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "wrestler-template"
	cooldown = 0
	start_on_cooldown = 1 // So you can't bypass the cooldown by taking off your belt and re-equipping it.
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/wrestler
	var/when_stunned = 0 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = 0

	New()
		var/obj/screen/ability/topBar/wrestler/B = new /obj/screen/ability/topBar/wrestler(null)
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
			src.object = new /obj/screen/ability/topBar/wrestler()
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
		var/datum/abilityHolder/wrestler/H = holder

		if (!M)
			return 0

		// The HUD autoequip code doesn't call unequipped() when it should, naturally.
		if (ishuman(M) && (istype(H) && H.is_inherent != 1))
			var/mob/living/carbon/human/HH = M
			if (!(HH.belt && istype(HH.belt, /obj/item/storage/belt/wrestling)))
				boutput(HH, __red("You have to wear the wrestling belt for this."))
				HH.make_wrestler(0, 1, 1)
				return 0

		if (!(ishuman(M) || iscritter(M))) // Not all critters have arms to grab people with, but whatever.
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

		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return 0

	proc/calculate_cooldown()
		if (!holder)
			return 0

		var/mob/living/M = holder.owner

		if (!M || !istype(M))
			return 0

		var/CD = src.cooldown
		var/ST_mod_max = M.get_stam_mod_max()
		var/ST_mod_regen = M.get_stam_mod_regen()

		// Balanced for 200/12 and 200/13 drugs (e.g. epinephrine or meth), so stamina regeneration
		// buffs are prioritized over total stamina modifiers.
		var/R = src.cooldown - (((ST_mod_max / 3 ) + (ST_mod_regen * 2)) * 10)
		if (R > (src.cooldown * 2.5))
			R = src.cooldown * 2.5 // Chems with severe stamina penalty exist, so this should be capped.
		CD = max((src.cooldown / 2.5), R) // About the same minimum as the old wrestling belt procs.

		//DEBUG_MESSAGE("Default CD: [src.cooldown]. Modifier: [R]. Actual CD: [CD].")
		return CD

	doCooldown()
		src.last_cast = world.time + calculate_cooldown()

		if (!src.holder.owner || !ismob(src.holder.owner))
			return

		// Why isn't this in afterCast()? Well, failed attempts to use an abililty call it too.
		SPAWN_DBG (rand(200, 900))
			if (src.holder && src.holder.owner && ismob(src.holder.owner))
				src.holder.owner.emote("flex")

		SPAWN_DBG(calculate_cooldown() + 5)
			holder.updateButtons()
