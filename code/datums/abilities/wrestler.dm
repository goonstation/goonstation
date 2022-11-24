// Converted everything related to wrestlers from client procs to ability holders and used
// the opportunity to do some clean-up as well (Convair880).

/* 	/		/		/		/		/		/		Setup		/		/		/		/		/		/		/		/		*/
//fake_wrestler - For the fake wrestling belt, make it so all abilities do no damage or stuns.
/mob/proc/make_wrestler(var/make_inherent = 0, var/belt_check = 0, var/remove_powers = 0, var/fake_wrestler = 0)
	if (ishuman(src) || ismobcritter(src))
		if (ismobcritter(src))
			var/mob/living/critter/C = src

			if (remove_powers == 1)
				if (istype(C.get_ability_holder(/datum/abilityHolder/wrestler), /datum/abilityHolder/wrestler))
					C.remove_ability_holder(/datum/abilityHolder/wrestler)
				else if (fake_wrestler && istype(C.get_ability_holder(/datum/abilityHolder/wrestler/fake), /datum/abilityHolder/wrestler/fake))
					C.remove_ability_holder(/datum/abilityHolder/wrestler)

				else
					C.abilityHolder.removeAbility("/datum/targetable/wrestler/kick[fake_wrestler ? "/fake" : ""]")
					C.abilityHolder.removeAbility("/datum/targetable/wrestler/strike[fake_wrestler ? "/fake" : ""]")
					C.abilityHolder.removeAbility("/datum/targetable/wrestler/drop[fake_wrestler ? "/fake" : ""]")
					C.abilityHolder.removeAbility("/datum/targetable/wrestler/throw[fake_wrestler ? "/fake" : ""]")
					C.abilityHolder.removeAbility("/datum/targetable/wrestler/slam[fake_wrestler ? "/fake" : ""]")

				return

			else
				if (belt_check == 1) // They don't have belts.
					return

				if (isnull(C.abilityHolder)) // But they do have a critter AH by default...or should.
					var/datum/abilityHolder/wrestler/A2
					if (fake_wrestler)
						A2 = C.add_ability_holder(/datum/abilityHolder/wrestler/fake)
					else
						A2 = C.add_ability_holder(/datum/abilityHolder/wrestler)
					if (!A2 || !istype(A2, /datum/abilityHolder/))
						return
				if(make_inherent)
					src.add_stam_mod_max("wrestler", 50)
					APPLY_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "wrestler", 5)
					src.max_health += 50
					health_update_queue |= src
				APPLY_ATOM_PROPERTY(src, PROP_MOB_PASSIVE_WRESTLE, "wrestledoodle")
				C.abilityHolder.addAbility("/datum/targetable/wrestler/kick[fake_wrestler ? "/fake" : ""]")
				C.abilityHolder.addAbility("/datum/targetable/wrestler/strike[fake_wrestler ? "/fake" : ""]")
				C.abilityHolder.addAbility("/datum/targetable/wrestler/drop[fake_wrestler ? "/fake" : ""]")
				C.abilityHolder.addAbility("/datum/targetable/wrestler/throw[fake_wrestler ? "/fake" : ""]")
				C.abilityHolder.addAbility("/datum/targetable/wrestler/slam[fake_wrestler ? "/fake" : ""]")

		if (ishuman(src))
			var/mob/living/carbon/human/H = src

			if (remove_powers == 1)
				var/datum/abilityHolder/wrestler/A3 = H.get_ability_holder(fake_wrestler ? /datum/abilityHolder/wrestler/fake : /datum/abilityHolder/wrestler)
				if (istype(A3))
					if (belt_check == 1 && A3.is_inherent == 1) // Wrestler/omnitraitor vs wrestling belt.
						return
					if (!isnull(H.abilityHolder))
						H.abilityHolder.removeAbility("/datum/targetable/wrestler/kick[fake_wrestler ? "/fake" : ""]")
						H.abilityHolder.removeAbility("/datum/targetable/wrestler/strike[fake_wrestler ? "/fake" : ""]")
						H.abilityHolder.removeAbility("/datum/targetable/wrestler/drop[fake_wrestler ? "/fake" : ""]")
						H.abilityHolder.removeAbility("/datum/targetable/wrestler/throw[fake_wrestler ? "/fake" : ""]")
						H.abilityHolder.removeAbility("/datum/targetable/wrestler/slam[fake_wrestler ? "/fake" : ""]")
					H.remove_ability_holder(fake_wrestler ? /datum/abilityHolder/wrestler/fake : /datum/abilityHolder/wrestler)

				return

			else
				if (belt_check == 1 && !(H.belt && istype(H.belt, /obj/item/storage/belt/wrestling)))
					return

				var/datum/abilityHolder/wrestler/A4 = H.get_ability_holder(/datum/abilityHolder/wrestler)
				if (istype(A4))
					return
				var/datum/abilityHolder/wrestler/fake/F = H.get_ability_holder(/datum/abilityHolder/wrestler/fake)
				if (fake_wrestler && istype(F))
					return

				var/datum/abilityHolder/wrestler/A5
				if (fake_wrestler)
					A5 = H.add_ability_holder(/datum/abilityHolder/wrestler/fake)
				else
					A5 = H.add_ability_holder(/datum/abilityHolder/wrestler)

				A5.addAbility("/datum/targetable/wrestler/kick[fake_wrestler ? "/fake" : ""]")
				A5.addAbility("/datum/targetable/wrestler/strike[fake_wrestler ? "/fake" : ""]")
				A5.addAbility("/datum/targetable/wrestler/drop[fake_wrestler ? "/fake" : ""]")
				A5.addAbility("/datum/targetable/wrestler/throw[fake_wrestler ? "/fake" : ""]")
				A5.addAbility("/datum/targetable/wrestler/slam[fake_wrestler ? "/fake" : ""]")

				if (make_inherent == 1)
					A5.is_inherent = 1
					src.add_stam_mod_max("wrestler", 50)
					APPLY_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "wrestler", 5)
					src.max_health += 50
					health_update_queue |= src


		if (belt_check != 1 && (src.mind && src.mind.special_role != ROLE_OMNITRAITOR && src.mind.special_role != "Faustian Wrestler"))
			src.show_antag_popup("wrestler")

	else return

/* 	/		/		/		/		/		/		Ability Holder		/		/		/		/		/		/		/		/		*/

/atom/movable/screen/ability/topBar/wrestler
	clicked(params)
		var/datum/targetable/wrestler/spell = owner
		if (!istype(spell))
			return
		if (!spell.holder)
			return
		if (owner.holder.owner) //how even
			if (!isturf(owner.holder.owner.loc))
				boutput(owner.holder.owner, "<span class='alert'>You can't use this ability here.</span>")
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
			SPAWN(0)
				spell.handleCast()
		return

/datum/abilityHolder/wrestler
	usesPoints = 0
	regenRate = 0
	tabName = "Wrestler"
	notEnoughPointsMessage = "<span class='alert'>You aren't strong enough to use this ability.</span>"
	var/is_inherent = 0 // Are we a wrestler as opposed to somebody with a wrestling belt?
	var/fake = 0

	deepCopy()
		. = ..()
		var/datum/abilityHolder/wrestler/copy = .
		if(istype(copy) && src.is_inherent == TRUE)
			copy.is_inherent = TRUE

/datum/abilityHolder/wrestler/fake
	fake = 1
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
	var/fake = 0

	New()
		var/atom/movable/screen/ability/topBar/wrestler/B = new /atom/movable/screen/ability/topBar/wrestler(null)
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
			src.object = new /atom/movable/screen/ability/topBar/wrestler()
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
				if (!isalive(M) || M.hasStatus(list("stunned", "paralysis", "weakened")))
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
			if (!(HH.belt && istype(HH.belt, /obj/item/storage/belt/wrestling)) && !HAS_ATOM_PROPERTY(M, PROP_MOB_PASSIVE_WRESTLE))
				boutput(HH, "<span class='alert'>You have to wear the wrestling belt for this.</span>")
				HH.make_wrestler(0, 1, 1)
				return 0

		if (fake && !(istype(get_turf(M), /turf/simulated/floor/specialroom/gym) || istype(get_turf(M), /turf/unsimulated/floor/specialroom/gym)))
			boutput(M, "<span class='alert'>You cannot use your \"powers\" outside of The Ring!</span>")
			return 0

		if (!(ishuman(M) || ismobcritter(M))) // Not all critters have arms to grab people with, but whatever.
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
		return 0

	doCooldown()
		src.last_cast = world.time + src.cooldown

		if (!src.holder.owner || !ismob(src.holder.owner))
			return

		// Why isn't this in afterCast()? Well, failed attempts to use an abililty call it too.
		SPAWN(rand(200, 900))
			if (src.holder && src.holder.owner && ismob(src.holder.owner))
				src.holder.owner.emote("flex")
