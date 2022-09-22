/datum/antagonist/hunter
	id = ROLE_HUNTER
	display_name = "hunter"

	/// The ability holder of this hunter, containing their respective abilities. We also use this for tracking power, at the moment.
	var/datum/abilityHolder/hunter/ability_holder

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			return FALSE

		var/mob/living/carbon/human/M = src.owner.current
		M.hunter_transform()

	alt_equipment()
		if (!ishuman(src.owner.current))
			return FALSE

		var/datum/abilityHolder/hunter/A = src.owner.current.get_ability_holder(/datum/abilityHolder/hunter)
		if (!A)
			src.ability_holder = src.owner.current.add_ability_holder(/datum/abilityHolder/hunter)
		else
			src.ability_holder = A
		src.ability_holder.addAbility(/datum/targetable/hunter/hunter_gearspawn)

	remove_equipment()
		src.ability_holder.removeAbility(/datum/targetable/hunter/hunter_gearspawn)
		src.ability_holder.removeAbility(/datum/targetable/hunter/hunter_taketrophy)
		src.ability_holder.removeAbility(/datum/targetable/hunter/hunter_trophycount)
		src.ability_holder.removeAbility(/datum/targetable/hunter/hunter_summongear)
		src.owner.current.remove_ability_holder(/datum/abilityHolder/hunter)

	relocate()
		var/mob/M = src.owner.current
		M.set_loc(pick_landmark(LANDMARK_LATEJOIN))

	assign_objectives()
		new /datum/objective_set/hunter(src.owner)


// Called for every human mob spawn and mutantrace change. The value of non-standard skulls is defined in organ.dm.
#define default_skull_desc "A trophy from a less interesting kill."
#define default_skull_value 1
/mob/proc/assign_gimmick_skull()
	if (!src || !ismob(src))
		return

	if (ishuman(src))
		var/mob/living/carbon/human/H = src

		if (!H.organHolder)
			sleep (2 SECONDS)
			if (!H.organHolder)
				return

		for (var/obj/item/W in H)
			if (istype(W, /obj/item/skull/) && W == H.organHolder.skull)
				var/obj/item/skull/S = H.organHolder.skull
				var/skull_type = null
				var/skull_value = default_skull_value
				var/skull_desc = default_skull_desc // The examine desc for hunters.

				// Cluwnes first.
				if (iscluwne(H))
					skull_type = /obj/item/skull/noface
					skull_desc = "A meaningless trophy from a weak opponent. You feel disgusted to even look at it."

				else
					// Antagonist check.
					if (checktraitor(H))
						switch (H.mind.special_role) // Ordered by skull value.
							if (ROLE_OMNITRAITOR)
								skull_type = /obj/item/skull/crystal
								skull_desc = "A trophy taken from a mystic, all-powerful creature. It is an immeasurable honor."
							if (ROLE_HUNTER)
								skull_type = /obj/item/skull/strange
								skull_desc = "A trophy taken from a hunter, the finest hunters of all."
							if (ROLE_CHANGELING)
								skull_type = /obj/item/skull/odd
								skull_desc = "A trophy taken from a shapeshifting alien! It is an immense honor."
							if (ROLE_WEREWOLF)
								skull_value = 4
								skull_desc = "A grand trophy from a lycanthrope, a very capable hunter. It is an immense honor."
							if (ROLE_WIZARD)
								skull_type = /obj/item/skull/peculiar
								skull_desc = "A grand trophy from a powerful magician. It brings you great honor."
							if (ROLE_VAMPIRE)
								skull_type = /obj/item/skull/menacing
								skull_value = 3
								skull_desc = "A trophy taken from an undead vampire! It brings you great honor."
							else
								skull_value = 2
								skull_desc = "A worthy trophy from a capable opponent."

					else
						// Mutantrace and ability holder check for non-antagonists.
						if (ischangeling(H) || isvampire(H))
							if (ischangeling(H))
								skull_type = /obj/item/skull/odd
								skull_desc = "A trophy taken from a shapeshifting alien! It is an immense honor."
							else if (isvampire(H))
								skull_value = 3
								skull_desc = "A trophy taken from an undead vampire! It brings you great honor."

						else
							if (!isnull(H.mutantrace))
								if (ishunter(H))
									skull_type = /obj/item/skull/strange
									skull_desc = "A trophy taken from a hunter, the finest hunters of all."
								if (iswerewolf(H))
									skull_value = 4
									skull_desc = "A grand trophy from a lycanthrope, a very capable hunter. It is an immense honor."
								if (isnpcmonkey(H))
									skull_value = 0
									skull_desc = "A meaningless trophy from a lab monkey. You feel disgusted to even look at it."

						// Everything's still default, so check for assigned_role. Could be a lizard captain or whatever.
						if (isnull(skull_type) && skull_value == default_skull_value && skull_desc == default_skull_desc)
							if (H.mind)
								if (H.mind.special_role == "macho man") // Not in ticker.Agimmicks.
									skull_type = /obj/item/skull/gold
									skull_desc = "A trophy taken from a legendary wrestler. It is an immeasurable honor."
								else
									switch (H.mind.assigned_role)
										if ("Head of Security")
											skull_value = 3
											skull_desc = "A grand trophy from a very worthy foe. It brings you great honor."
										if ("Captain")
											skull_value = 3
											skull_desc = "A grand trophy from a very worthy foe. It brings you great honor."
										if ("Security Officer")
											skull_value = 2
											skull_desc = "A worthy trophy from a capable opponent."
										if ("Detective")
											skull_value = 2
											skull_desc = "A worthy trophy from a capable opponent."
										if ("Vice Officer")
											skull_value = 2
											skull_desc = "A worthy trophy from a capable opponent."
										if ("Head of Personnel")
											skull_value = 2
											skull_desc = "A worthy trophy from a capable opponent."
										if ("Clown")
											skull_value = -1
											skull_desc = "A meaningless trophy from a weak opponent. You feel disgusted to even look at it."

				// Assign new skull or change value/desc.
				if (!isnull(skull_type))
					var/obj/item/skull/new_skull = new skull_type
					skull_value = new_skull.value // Defined in organ.dm. Copied because there isn't always a need to replace the skull.

					if (S.type != new_skull.type)
						//setup skull AFTER the qdel! otherwise skull gets set to null
						qdel(S)
						new_skull.donor = H
						new_skull.preddesc = skull_desc
						new_skull.set_loc(H)
						H.organHolder.skull = new_skull
						//DEBUG_MESSAGE("[H]'s skull: [new_skull.type] (V: [new_skull.value], D: [new_skull.preddesc])")
					else
						qdel(new_skull)
						S.value = skull_value
						S.preddesc = skull_desc
						//DEBUG_MESSAGE("[H]'s skull: [S.type] (V: [S.value], D: [S.preddesc])")
				else
					S.value = skull_value
					S.preddesc = skull_desc
					//DEBUG_MESSAGE("[H]'s skull: [S.type] (V: [S.value], D: [S.preddesc])")

	return
#undef default_skull_value
#undef default_skull_desc

// Returns the combined value of all trophies in the player's possession.
/mob/proc/get_skull_value()
	if (!src || !ismob(src))
		return 0

	var/value = 0

	var/list/L = src.get_all_items_on_mob()
	if (length(L))
		for (var/obj/item/skull/S in L)
			if (ishuman(src))
				var/mob/living/carbon/human/H = src
				if (H.organHolder.skull == S)
					continue // Your own skull doesn't count, dummy!
			value += S.value
	return value

//////////////////////////////////////////// Ability holder /////////////////////////////////////////

/atom/movable/screen/ability/topBar/hunter
	clicked(params)
		var/datum/targetable/hunter/spell = owner
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

/datum/abilityHolder/hunter
	usesPoints = 0
	regenRate = 0
	tabName = "Hunter"
	notEnoughPointsMessage = "<span class='alert'>You aren't strong enough to use this ability.</span>"

/////////////////////////////////////////////// Hunter spell parent ////////////////////////////

/datum/targetable/hunter
	icon = 'icons/mob/hunter_abilities.dmi'
	icon_state = "trophycount"
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/hunter
	var/when_stunned = 0 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = 0
	var/hunter_only = 0

	New()
		var/atom/movable/screen/ability/topBar/hunter/B = new /atom/movable/screen/ability/topBar/hunter(null)
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
			src.object = new /atom/movable/screen/ability/topBar/hunter()
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

		var/mob/living/carbon/human/M = holder.owner

		if (!M)
			return 0

		if (!ishuman(M)) // Only humans use mutantrace datums.
			boutput(M, "<span class='alert'>You cannot use any powers in your current form.</span>")
			return 0

		if (M.transforming)
			boutput(M, "<span class='alert'>You can't use any powers right now.</span>")
			return 0

		if (hunter_only == 1 && !ishunter(M))
			boutput(M, "<span class='alert'>You're not quite sure how to go about doing that in your current form.</span>")
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

// We have two paths to becoming a hunter so I think we are stuck with this

/mob/living/carbon/human/proc/hunter_transform()
	src.real_name = "hunter"

	src.jitteriness = 0
	src.delStatus("stunned")
	src.delStatus("weakened")
	src.delStatus("paralysis")
	src.delStatus("slowed")
	src.change_misstep_chance(-INFINITY)
	src.stuttering = 0
	src.delStatus("drowsy")

	if (src.hasStatus("handcuffed"))
		src.visible_message("<span class='alert'><B>[src] rips apart the [src.handcuffs] with pure brute strength!</b></span>")
		src.handcuffs.destroy_handcuffs(src)
	src.buckled = null

	if (src.mutantrace)
		qdel(src.mutantrace)
	src.set_mutantrace(/datum/mutantrace/hunter)

	var/datum/abilityHolder/hunter/A = src.get_ability_holder(/datum/abilityHolder/hunter)
	if (!A)
		A = src.add_ability_holder(/datum/abilityHolder/hunter)
	A.removeAbility(/datum/targetable/hunter/hunter_gearspawn)
	A.addAbility(/datum/targetable/hunter/hunter_taketrophy)
	A.addAbility(/datum/targetable/hunter/hunter_trophycount)
	A.addAbility(/datum/targetable/hunter/hunter_summongear)

	src.unequip_all()

	var/obj/item/implant/revenge/microbomb/hunter/B = new /obj/item/implant/revenge/microbomb/hunter(src)
	src.implant.Add(B)
	B.implanted = 1
	B.implanted(src)

	src.equip_if_possible(new /obj/item/clothing/under/gimmick/hunter(src), slot_w_uniform) // srcust be at the top of the list.
	src.equip_if_possible(new /obj/item/clothing/mask/hunter(src), slot_wear_mask)
	src.equip_if_possible(new /obj/item/storage/belt/hunter(src), slot_belt)
	src.equip_if_possible(new /obj/item/clothing/shoes/cowboy/hunter(src), slot_shoes)
	src.equip_if_possible(new /obj/item/device/radio/headset(src), slot_ears)
	src.equip_if_possible(new /obj/item/storage/backpack(src), slot_back)
	src.equip_if_possible(new /obj/item/tank/emergency_oxygen/extended(src), slot_l_store)
	src.equip_if_possible(new /obj/item/cloaking_device/hunter(src), slot_r_store)
	src.equip_if_possible(new /obj/item/knife/butcher/hunterspear(src), slot_in_backpack)
	src.equip_if_possible(new /obj/item/gun/energy/plasma_gun/hunter(src), slot_in_backpack)

	src.set_face_icon_dirty()
	src.set_body_icon_dirty()
	src.update_clothing()

	SPAWN(2.5 SECONDS) // Don't remove.
		if (src)
			src.assign_gimmick_skull()

	boutput(src, "<span class='notice'><h3>You have received your equipment. Let the hunt begin!</h3></span>")
	logTheThing(LOG_COMBAT, src, "transformed into a hunter at [log_loc(src)].")
