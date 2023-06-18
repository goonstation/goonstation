////////////////////////////////////////////// Helper procs ////////////////////////////////////////////////////

/mob/proc/emp_touchy(source, obj/item/I)
	I.emp_act()

/mob/proc/emp_hands(source)
	for(var/obj/item/I in src.equipped_list())
		I.emp_act()

/// Returns TRUE if we have enough magic power to cast a spell, FALSE if we don't.
/mob/proc/wizard_spellpower(var/datum/targetable/spell/spell = null)
	return FALSE

/mob/living/critter/wizard_spellpower(var/datum/targetable/spell/spell = null)
	var/magcount = 0
	if (src.bioHolder.HasEffect("arcane_power") == 2)
		magcount += 10
	if (src.bioHolder.HasEffect("robed"))
		return TRUE
	for (var/obj/item/clothing/C in src.contents)
		if (C.magical)
			magcount += 1
			if (istype(spell) && istype(C, /obj/item/clothing/gloves/ring/wizard))
				var/obj/item/clothing/gloves/ring/wizard/WR = C
				if (WR.ability_path == spell.type)
					magcount += 10
	if (src.find_type_in_hand(/obj/item/staff))
		magcount += 2

	return (magcount >= 4)

// --------------------------------- Ability holder ---------------------------------------------------
#define MINIMUM_SPELLPOWER 4
/datum/abilityHolder/wizard
	usesPoints = FALSE
	topBarRendered = TRUE
	tabName = "Wizard"

	/// Check if we have our robes and staff for casting (or some substitute)
	/// Arg can be null for generic check
	proc/wizard_spellpower(datum/targetable/spell/abil)
		var/mob/living/caster = src.owner
		if (caster.bioHolder.HasEffect("robed")) // special magic bullshit effect
			return TRUE

		for (var/obj/item/clothing/gloves/ring/wizard/ring in caster.get_equipped_items())
			if (ring.ability_path == abil?.type)
				return TRUE

		var/magcount = 0
		if (caster.bioHolder.HasEffect("arcane_power") == 2) // secondary magic bullshit effect
			magcount += 10
		for (var/obj/item/clothing/C in caster.get_equipped_items())
			if (C.magical)
				magcount += 1
		if (caster.find_type_in_hand(/obj/item/staff))
			magcount += 2

		return (magcount >= MINIMUM_SPELLPOWER)

	// Checks the immunity for a single target of a spell (could be an indirect target, or called by a projectile or something)
	proc/targetSpellImmunity(atom/target, messages, chaplain_xp)
		if (!istype(target, /mob))
			return FALSE
		var/mob/M = target
		if (M.traitHolder.hasTrait("training_chaplain"))
			if (messages)
				boutput(src.owner, "<span class='alert'>[M] has divine protection from magic.</span>")
				M.visible_message("<span class='alert'>The spell has no effect on [M]!</span>")
			JOB_XP(M, "Chaplain", chaplain_xp)
			return TRUE

		if (iswizard(M))
			if (messages)
				M.visible_message("<span class='alert'>The spell has no effect on [M]!</span>")
			return TRUE

		if (check_target_immunity(M))
			if (messages)
				M.visible_message("<span class='alert'>[M] seems to be warded from the effects!</span>")
			return TRUE
		return FALSE

#undef MINIMUM_SPELLPOWER
//------------------------- Wizard spell parent -----------------------------

/// Minimum spell power required to cast something without an additional cooldown
/datum/targetable/spell
	preferred_holder_type = /datum/abilityHolder/wizard
	var/requires_robes = FALSE					//! Does this spell require robes to cast?
	var/offensive = FALSE						//! Is this spell offensive, i.e. for attacking/damaging people/the station?
	var/cooldown_staff = FALSE					//! Should this spell have an increased (1.5x) cooldown if we cast without a staff?
	var/voice_grim = null						//! Evil necromancer spell cast sound
	var/voice_fem = null						//! Femme spell cast sound
	var/voice_other = null						//! Masc/NB (i guess???) spell cast sound

	/// Special text styling/swag for this spell
	var/maptext_style = "color: white !important; text-shadow: 1px 1px 3px white; -dm-text-outline: 1px black;"
	/// Coloration for the spell mapte
	var/maptext_colors = null

	var/granted_chaplain_xp = 0 				//! How much XP should we give chaplains who are directly targeted by this spell?

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

	doCooldown(customCooldown)
		var/on_cooldown = src.calculate_cooldown()
		. = ..(on_cooldown)

	cast(atom/target)
		var/datum/abilityHolder/wizard/wiz_holder = src.holder
		if (src.cooldown_staff && !wiz_holder.wizard_spellpower())
			boutput(holder.owner, "<span class='alert'>Your spell takes longer to recharge without a staff to focus it!</span>")

		if(ishuman(holder.owner))
			var/mob/living/carbon/human/O = holder.owner
			if(src.voice_grim && O && istype(O.wear_suit, /obj/item/clothing/suit/wizrobe/necro) && istype(O.head, /obj/item/clothing/head/wizard/necro))
				playsound(O.loc, src.voice_grim, 50, 0, -1)
			else if(src.voice_fem && O.gender == "female")
				playsound(O.loc, src.voice_fem, 50, 0, -1)
			else if (src.voice_other)
				playsound(O.loc, src.voice_other, 50, 0, -1)
		. = ..()

	// This should really be on the abilityHolder, do that when hoisting castcheck there
	castcheck(atom/target)
		. = ..()
		var/mob/caster = src.holder.owner

		var/ring_bypass = FALSE
		for (var/obj/item/clothing/gloves/ring/wizard/WR in caster.equipped_list())
			if (WR.ability_path == src.type)
				ring_bypass = TRUE
				break

		if (src.targeted)
			var/datum/abilityHolder/wizard/wiz_holder = src.holder
			if (wiz_holder.targetSpellImmunity(target, TRUE, src.granted_chaplain_xp))
				return FALSE

		var/bypass_extra_checks = (caster.bioHolder.HasEffect("arcane_power") == 2) || ring_bypass
		if (!bypass_extra_checks)
			if (!caster.bioHolder.HasEffect("robed") && ishuman(caster))
				var/mob/living/carbon/human/H = caster // the type caster summons runtime errors
				if(!istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
					boutput(H, "<span class='alert'>You don't feel strong enough without a magical robe.</span>")
					return FALSE
				if(!istype(H.head, /obj/item/clothing/head/wizard))
					boutput(H, "<span class='alert'>You don't feel strong enough without a magical hat.</span>")
					return FALSE

			var/area/A = get_area(caster)
			if(src?.offensive && A.sanctuary)
				boutput(caster, "<span class='alert'>You cannot cast offensive spells in a sanctuary.</span>")
				return FALSE
			if(istype(A, /area/station/chapel)) // this should really be a 'sanctified' var or something
				boutput(caster, "<span class='alert'>You cannot cast spells on hallowed ground!</span>")
				return FALSE

			if(caster.bioHolder.HasEffect("arcane_shame"))
				boutput(caster, "<span class='alert'>You are too consumed with shame to cast that spell!</span>")
				return FALSE
