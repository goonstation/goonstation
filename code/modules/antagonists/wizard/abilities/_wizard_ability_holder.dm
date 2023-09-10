////////////////////////////////////////////// Helper procs ////////////////////////////////////////////////////

/mob/proc/emp_touchy(source, obj/item/I)
	I.emp_act()

/mob/proc/emp_hands(source)
	for(var/obj/item/I in src.equipped_list())
		I.emp_act()

/mob/proc/wizard_spellpower(var/datum/targetable/spell/spell = null)
	return 0

/mob/living/carbon/human/wizard_spellpower(var/datum/targetable/spell/spell = null)
	var/magcount = 0
	if (!src) return 0 // ??
	if (src.bioHolder.HasEffect("arcane_power") == 2)
		magcount += 10
	if (src.bioHolder.HasEffect("robed"))
		return 1
	for (var/obj/item/clothing/C in src.contents)
		if (C.magical) magcount += 1
	if(istype(spell) && istype(src.gloves, /obj/item/clothing/gloves/ring/wizard))
		var/obj/item/clothing/gloves/ring/wizard/WR = src.gloves
		if (WR.ability_path == spell.type)
			magcount += 10
	if (istype(src.r_hand, /obj/item/staff))
		magcount += 2
	if (istype(src.l_hand, /obj/item/staff))
		magcount += 2
	if (magcount >= 4) return 1
	else return 0

/mob/living/critter/wizard_spellpower(var/datum/targetable/spell/spell = null)
	var/magcount = 0
	if (src.bioHolder.HasEffect("arcane_power") == 2)
		magcount += 10
	if (src.bioHolder.HasEffect("robed"))
		return 1
	for (var/obj/item/clothing/C in src.contents)
		if (C.magical)
			magcount += 1
			if (istype(spell) && istype(C, /obj/item/clothing/gloves/ring/wizard))
				var/obj/item/clothing/gloves/ring/wizard/WR = C
				if (WR.ability_path == spell.type)
					magcount += 10
	if (src.find_type_in_hand(/obj/item/staff))
		magcount += 2
	if (magcount >= 4) return 1
	else return 0

/mob/proc/wizard_castcheck(var/datum/targetable/spell/spell = null)
	return 0

/mob/living/carbon/human/wizard_castcheck(var/datum/targetable/spell/spell = null)
	if(src.stat)
		boutput(src, "You can't cast spells while incapacitated.")
		return 0
	if(src.bioHolder.HasEffect("arcane_power") == 2)
		return 1
	if(spell && istype(src.gloves, /obj/item/clothing/gloves/ring/wizard))
		var/obj/item/clothing/gloves/ring/wizard/WR = src.gloves
		if (WR.ability_path == spell.type)
			return 1
	if (!src.bioHolder.HasEffect("robed")) //bypass robes check
		if(!istype(src.wear_suit, /obj/item/clothing/suit/wizrobe))
			boutput(src, "You don't feel strong enough without a magical robe.")
			return 0
		if(!istype(src.head, /obj/item/clothing/head/wizard))
			boutput(src, "You don't feel strong enough without a magical hat.")
			return 0
	var/area/A = get_area(src)
	if(istype(A, /area/station/chapel))
		boutput(src, "You cannot cast spells on hallowed ground!")// Maybe if the station were more corrupted...")
		return 0
	if(spell)
		if(spell.offensive && A.sanctuary)
			boutput( src, "You cannot cast offensive spells in a sanctuary." )
			return 0
		if (spell.offensive && src.bioHolder.HasEffect("arcane_shame"))
			boutput(src, "You are too consumed with shame to cast that spell!")
			return 0
	else
		if(A.sanctuary)
			boutput( src, "You cannot cast offensive spells in a sanctuary." )
			return 0
		if(src.bioHolder.HasEffect("arcane_shame"))
			boutput(src, "You are too consumed with shame to cast that spell!")
			return 0
	return 1

/mob/living/critter/wizard_castcheck(var/datum/targetable/spell/spell = null)
	if(src.stat)
		boutput(src, "You can't cast spells while incapacitated.")
		return 0
	if(src.bioHolder.HasEffect("arcane_power") == 2)
		return 1
	if (istype(spell))
		for (var/obj/item/clothing/gloves/ring/wizard/WR in src.contents)
			if (WR.ability_path == spell.type)
				return 1
	if (!src.bioHolder.HasEffect("robed")) //bypass robes check
		if(!find_in_equipment(/obj/item/clothing/head/wizard))
			boutput(src, "You don't feel strong enough without a magical hat.")
			return 0
	var/area/getarea = get_area(src)
	if(spell?.offensive && getarea.sanctuary)
		boutput( src, "You cannot cast spells in a sanctuary." )
		return 0
	if(getarea.name == "Chapel" || getarea.name == "Chapel Office")
		boutput(src, "You cannot cast spells on hallowed ground!")// Maybe if the station were more corrupted...")
		return 0
	return 1

//////////////////////////////////////////// Ability holder /////////////////////////////////////////

/atom/movable/screen/ability/topBar/spell
	clicked(params)
		var/datum/targetable/spell/spell = owner
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
				boutput(usr, "<span class='notice'>Please press a number to bind this ability to...</span>")
				return

		if (!isturf(usr.loc))
			return
		if (world.time < spell.last_cast)
			return
		if (spell.targeted && usr.targeting_ability == owner)
			usr.targeting_ability = null
			usr.update_cursor()
			return
		var/mob/user = spell.holder.owner
		if (!istype(spell, /datum/targetable/spell/prismatic_spray/admin) && !user.wizard_castcheck(spell))
			return
		if (spell.targeted)
			usr.targeting_ability = owner
			usr.update_cursor()
		else
			SPAWN(0)
				spell.handleCast()

/datum/abilityHolder/wizard
	usesPoints = 0
	topBarRendered = 1
	tabName = "Wizard"

/////////////////////////////////////////////// Wizard spell parent ////////////////////////////

/datum/targetable/spell
	preferred_holder_type = /datum/abilityHolder/wizard
	var/requires_being_on_turf = FALSE
	var/requires_robes = 0
	var/offensive = 0
	var/cooldown_staff = 0
	var/prepared_count = 0
	var/casting_time = 0
	var/voice_grim = null
	var/voice_fem = null
	var/voice_other = null
	var/maptext_style = "color: white !important; text-shadow: 1px 1px 3px white; -dm-text-outline: 1px black;"
	var/maptext_colors = null

	proc/calculate_cooldown()
		var/cool = src.cooldown
		var/mob/user = src.holder.owner
		if (user?.bioHolder)
			switch (user.bioHolder.HasEffect("arcane_power"))
				if (1)
					cool /= 2
				if (2)
					cool = 1
		if (src.cooldown_staff && !user.wizard_spellpower(src))
			cool *= 1.5
		return cool

	disposing()
		if (object)
			qdel(object)
		..()

	doCooldown()
		src.last_cast = world.time + calculate_cooldown()
		SPAWN(calculate_cooldown() + 5)
			holder.updateButtons()

	//mbc : i don't see why the wizard needs a specialized tryCast() proc. someone fix it later for me!
	tryCast(atom/target)
		if (!holder || !holder.owner)
			return CAST_ATTEMPT_FAIL_CAST_FAILURE
		var/datum/abilityHolder/wizard/H = holder
		if (H.locked && !src.ignore_holder_lock)
			boutput(holder.owner, "<span class='alert'>You're already casting an ability.</span>")
			return CAST_ATTEMPT_FAIL_CAST_FAILURE // ASSHOLES
		if (src.last_cast > world.time)
			return
		if (isunconscious(holder.owner))
			boutput(holder.owner, "<span class='alert'>You cannot cast this ability while you are unconscious.</span>")
			src.holder.locked = FALSE
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (!holder.cast_while_dead && isdead(holder.owner))
			boutput(holder.owner, "<span class='alert'>You cannot cast this ability while you are dead.</span>")
			src.holder.locked = FALSE
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (!istype(src, /datum/targetable/spell/prismatic_spray/admin) && !H.owner.wizard_castcheck(src)) // oh god this is ugly but it's technically not duplicating code so it fixes to problem with the move to ability buttons
			src.holder.locked = FALSE
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (src.requires_being_on_turf && !isturf(holder.owner.loc))
			boutput(holder.owner, "<span class='alert'>That ability doesn't seem to work here.</span>")
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		var/turf/T = get_turf(holder.owner)
		if(offensive && T.loc:sanctuary )
			boutput(holder.owner, "<span class='alert'>You cannot cast offensive spells on someone in a sanctuary.</span>")
		if (src.restricted_area_check)
			if (!isturf(T))
				boutput(holder.owner, "<span class='alert'>That ability doesn't seem to work here.</span>")
				return CAST_ATTEMPT_FAIL_CAST_FAILURE

			switch (src.restricted_area_check)
				if (ABILITY_AREA_CHECK_ALL_RESTRICTED_Z)
					if (isrestrictedz(T.z))
						var/area/Arr = get_area(T)
						if (!istype(Arr, /area/wizard_station))
							boutput(holder.owner, "<span class='alert'>That ability doesn't seem to work here.</span>")
							return CAST_ATTEMPT_FAIL_CAST_FAILURE
				if (ABILITY_AREA_CHECK_VR_ONLY)
					var/area/A = get_area(T)
					if (istype(A, /area/sim))
						boutput(holder.owner, "<span class='alert'>You can't use this ability in virtual reality.</span>")
						return CAST_ATTEMPT_FAIL_CAST_FAILURE
		if (src.lock_holder)
			H.locked = TRUE
		if (src.cooldown_staff && !holder.owner.wizard_spellpower(src))
			boutput(holder.owner, "<span class='alert'>Your spell takes longer to recharge without a staff to focus it!</span>")
		. = cast(target)
		H.locked = FALSE

	proc/targetSpellImmunity(mob/living/carbon/human/H, var/messages, var/chaplain_xp)
		if (H.traitHolder.hasTrait("training_chaplain"))
			if (messages)
				boutput(holder.owner, "<span class='alert'>[H] has divine protection from magic.</span>")
				H.visible_message("<span class='alert'>The spell has no effect on [H]!</span>")
			if (chaplain_xp)
				JOB_XP(H, "Chaplain", chaplain_xp)
			return 1

		if (iswizard(H))
			if (messages)
				H.visible_message("<span class='alert'>The spell has no effect on [H]!</span>")
			return 1

		if (check_target_immunity(H))
			if (messages)
				H.visible_message("<span class='alert'>[H] seems to be warded from the effects!</span>")
			return 1

		return 0

	updateObject()
		if (!holder || !holder.owner)
			qdel(src)
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/spell()
		object.icon = src.icon
		if (src.last_cast > world.time)
			object.name = "[src.name] ([round((src.last_cast-world.time)/10)])"
			object.icon_state = src.icon_state + "_cd"
		else
			object.name = src.name
			object.icon_state = src.icon_state
		object.owner = src

	castcheck()
		return holder.owner.wizard_castcheck(src)

	cast(atom/target)
		if(ishuman(holder.owner))
			var/mob/living/carbon/human/O = holder.owner
			if(src.voice_grim && O && istype(O.wear_suit, /obj/item/clothing/suit/wizrobe/necro) && istype(O.head, /obj/item/clothing/head/wizard/necro))
				playsound(O.loc, src.voice_grim, 50, 0, -1)
			else if(src.voice_fem && O.gender == "female")
				playsound(O.loc, src.voice_fem, 50, 0, -1)
			else if (src.voice_other)
				playsound(O.loc, src.voice_other, 50, 0, -1)

		var/log_target = constructTarget(target,"combat")
		logTheThing(LOG_COMBAT, holder.owner, "casts [src.name] from [log_loc(holder.owner)][targeted ? ", at [log_target]" : ""].")
