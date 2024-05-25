/datum/targetable/changeling/stasis
	name = "Enter Regenerative Stasis"
	desc = "Enter a stasis, appearing to be completely dead for 45 seconds, while healing all injuries."
	icon_state = "stasis"
	human_only = 1
	cooldown = 450
	targeted = 0
	target_anything = 0
	can_use_in_container = 1

	incapacitationCheck()
		return 0

	cast(atom/target)
		if (..())
			return 1

		var/datum/abilityHolder/changeling/H = holder
		if (!istype(H))
			boutput(holder.owner, SPAN_ALERT("That ability is incompatible with our abilities. We should report this to a coder."))
			return 1

		var/mob/living/carbon/human/C = holder.owner
		if (tgui_alert(C,"Are we sure?","Enter Regenerative Stasis?",list("Yes","No")) != "Yes")
			boutput(holder.owner, SPAN_NOTICE("We change our mind."))
			return 1

		if(!H.in_fakedeath)
			boutput(holder.owner, SPAN_NOTICE("Repairing our wounds."))
			logTheThing(LOG_COMBAT, holder.owner, "enters regenerative stasis as a changeling [log_loc(holder.owner)].")
			var/list/implants = list()
			for (var/obj/item/implant/I in holder.owner) //Still preserving implants
				implants += I

			H.in_fakedeath = 1
			APPLY_ATOM_PROPERTY(C, PROP_MOB_CANTMOVE, "regen_stasis")

			C.lying = 1
			C.canmove = 0
			C.set_clothing_icon_dirty()

			C.emote("deathgasp")

			SPAWN(cooldown)
				if(H.in_fakedeath) //don't trigger this if we cancelled stasis via abomination form
					changeling_super_heal_step(C, 100, 100) //get those limbs back i didn't lay here for 45 seconds to be hopping around on one leg dang it
					if (C && !isdead(C))
						C.HealDamage("All", 1000, 1000)
						C.take_brain_damage(-INFINITY)
						C.take_toxin_damage(-INFINITY)
						C.change_misstep_chance(-INFINITY)
						C.take_oxygen_deprivation(-INFINITY)
						C.delStatus("drowsy")
						C.delStatus("passing_out")
						C.delStatus("n_radiation")
						C.remove_stuns()
						C.delStatus("slowed")
						C.delStatus("radiation")
						C.take_radiation_dose(-INFINITY)
						C.delStatus("disorient")
						C.health = 100
						C.reagents.clear_reagents()
						C.lying = 0
						C.canmove = 1
						boutput(C, SPAN_NOTICE("We have regenerated."))
						logTheThing(LOG_COMBAT, C, "[C] finishes regenerative statis as a changeling [log_loc(C)].")
						C.visible_message(SPAN_ALERT("<b>[C] appears to wake from the dead, having healed all wounds.</b>"))
						for(var/obj/item/implant/I in implants)
							if (istype(I, /obj/item/implant/projectile))
								boutput(C, SPAN_ALERT("\an [I] falls out of your abdomen."))
								I.on_remove(C)
								C.implant.Remove(I)
								I.set_loc(C.loc)
								continue
						if(C.bioHolder?.effects && length(C.bioHolder.effects))
							for(var/bioEffectId in C.bioHolder.effects)
								var/datum/bioEffect/gene = C.bioHolder.GetEffect(bioEffectId)
								if (gene.curable_by_mutadone && gene.effectType == EFFECT_TYPE_DISABILITY)
									C.bioHolder.RemoveEffect(gene.id)

					C.set_clothing_icon_dirty()
					H.in_fakedeath = 0
					REMOVE_ATOM_PROPERTY(C, PROP_MOB_CANTMOVE, "regen_stasis")
		return 0

/proc/changeling_super_heal_step(var/mob/living/carbon/human/healed, var/limb_regen_prob = 25, var/eye_regen_prob = 25, var/mult = 1, var/changer = 1)
	var/mob/living/carbon/human/C = healed
	var/list/implants = list()
	for (var/obj/item/implant/I in C) //Still preserving implants
		implants += I


	if (!C.getStatusDuration("burning") && !isdead(C) && (C.health < 100 || !C.limbs.l_arm || !C.limbs.r_arm || !C.limbs.l_leg || !C.limbs.r_leg || C.organHolder.get_missing_organs().len > 0))
		C.reagents.remove_any(10 * mult)
		if (C.health < C.max_health)
			C.HealDamage("All", 10 * mult, 1 * mult)
			C.take_toxin_damage(-10 * mult)
			C.take_oxygen_deprivation(-10 * mult)
			if (C.blood_volume < 500)
				C.blood_volume += 10 * mult
				//changelings can get this somehow and it stops speed regen ever turning off otherwise
			boutput(C, SPAN_NOTICE("You feel your flesh knitting back together."))
			for(var/obj/item/implant/I in implants)
				if (istype(I, /obj/item/implant/projectile))
					boutput(C, SPAN_ALERT("\an [I] falls out of your abdomen."))
					I.on_remove(C)
					C.implant.Remove(I)
					I.set_loc(C.loc)
					continue

		if (!C.limbs.l_arm || !C.limbs.r_arm || !C.limbs.l_leg || !C.limbs.r_leg)
			if(!C.limbs.l_arm && prob(limb_regen_prob))
				if (isabomination(C))
					C.limbs.l_arm = new /obj/item/parts/human_parts/arm/left/abomination(C)
				else
					C.limbs.l_arm = new /obj/item/parts/human_parts/arm/left(C)
				C.limbs.l_arm.holder = C
				C.limbs.l_arm:original_holder = C
				C.limbs.l_arm:set_skin_tone()
				C.visible_message(SPAN_ALERT("<B> [C]'s left arm grows back!"))
				C.set_body_icon_dirty()
				C.hud.update_hands()

			if (!C.limbs.r_arm && prob(limb_regen_prob))
				if (isabomination(C))
					C.limbs.r_arm = new /obj/item/parts/human_parts/arm/right/abomination(C)
				else
					C.limbs.r_arm = new /obj/item/parts/human_parts/arm/right(C)
				C.limbs.r_arm.holder = C
				C.limbs.r_arm:original_holder = C
				C.limbs.r_arm:set_skin_tone()
				C.visible_message(SPAN_ALERT("<B> [C]'s right arm grows back!"))
				C.set_body_icon_dirty()
				C.hud.update_hands()

			if (!C.limbs.l_leg && prob(limb_regen_prob))
				C.limbs.l_leg = new /obj/item/parts/human_parts/leg/left(C)
				C.limbs.l_leg.holder = C
				C.limbs.l_leg:original_holder = C
				C.limbs.l_leg:set_skin_tone()
				C.visible_message(SPAN_ALERT("<B> [C]'s left leg grows back!"))
				C.set_body_icon_dirty()

			if (!C.limbs.r_leg && prob(limb_regen_prob))
				C.limbs.r_leg = new /obj/item/parts/human_parts/leg/right(C)
				C.limbs.r_leg.holder = C
				C.limbs.r_leg:original_holder = C
				C.limbs.r_leg:set_skin_tone()
				C.visible_message(SPAN_ALERT("<B> [C]'s right leg grows back!"))
				C.set_body_icon_dirty()

		C.organHolder.create_organs()
		C.organHolder.heal_organs(10 * mult, 10 * mult, 10 * mult, list("brain", "left_eye", "right_eye", "heart", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail"))
		for (var/organ_slot in C.organHolder.organ_list)
			var/obj/item/organ/O = C.organHolder.organ_list[organ_slot]
			if(istype(O))
				O.unbreakme()

		if (!ON_COOLDOWN(C, "cling_visible_message", 3 SECONDS))
			if (changer)
				C.visible_message(SPAN_ALERT("<B>[C]'s flesh is moving and sliding around oddly!</B>"))
				playsound(C, 'sound/misc/cling_flesh.ogg', 30, TRUE)

/datum/targetable/changeling/regeneration
	name = "Speed Regeneration"
	desc = "Regenerate your health quickly and rather loudly."
	icon_state = "speedregen"
	human_only = 1
	cooldown = 900
	pointCost = 10
	targeted = 0
	target_anything = 0
	can_use_in_container = 1
	lock_holder = FALSE
	ignore_holder_lock = 1

	incapacitationCheck()
		return FALSE

	cast(atom/target)
		if (..())
			return 1

		var/datum/abilityHolder/changeling/aH = holder
		if (!istype(aH))
			boutput(holder.owner, SPAN_ALERT("That ability is incompatible with our abilities. We should report this to a coder."))
			return 1

		var/mob/living/carbon/human/H = holder.owner
		if (tgui_alert(H, "Are we sure?", "Speed regen?", list("Yes","No")) != "Yes")
			boutput(holder.owner, SPAN_NOTICE("We change our mind."))
			return 1

		H.changeStatus("changeling_speedregen", 30 SECONDS)
		return FALSE

/// changeling speedregen status effect
/datum/statusEffect/c_regeneration

	id = "changeling_speedregen"
	name = "Speed regeneration"
	desc = "You quickly heal the damage dealt to you."
	icon_state = "heart+"
	unique = TRUE
	maxDuration = 30 SECONDS

	onAdd(optional=null)
		. = ..()
		var/mob/living/carbon/human/H
		if (ishuman(owner))
			H = owner
			boutput(H, SPAN_NOTICE("We start regenerating."))
			H.visible_message(SPAN_ALERT("<B>[H]'s flesh starts moving and sliding around oddly, repairing their wounds!</B>"))
			return
		else
			owner.delStatus("changeling_speedregen")

	onUpdate(timePassed)
		var/mob/living/carbon/human/H
		if (!ishuman(owner)) return
		H = owner
		if (!H.getStatusDuration("burning"))
			if (!ON_COOLDOWN(H, "cling_regen", 2 SECONDS))
				changeling_super_heal_step(H, 25, 25)
		else // lings are vulnerable to fire so it stopping their regen makes sense
			if (!ON_COOLDOWN(H, "cling_fire_regen_cancellation", 3 SECONDS))
				boutput(H, SPAN_ALERT("The fire stops us from regenerating! Put it out!"))
				H.visible_message(SPAN_ALERT("<B>[H]'s flesh is moving weirdly in contact with the fire!</B>"))

	onRemove()
		. = ..()
		var/mob/living/carbon/human/H
		if (!ishuman(owner)) return
		H = owner
		boutput(H, SPAN_NOTICE("We stop regenerating."))
		H.visible_message(SPAN_ALERT("<B>[H]'s flesh stops moving and sliding around!</B>"))
		return
