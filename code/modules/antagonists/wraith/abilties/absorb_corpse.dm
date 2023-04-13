/datum/targetable/wraithAbility/absorbCorpse
	name = "Absorb Corpse"
	icon_state = "absorbcorpse"
	desc = "Steal life essence from a corpse. You cannot use this on a skeleton!"
	targeted = 1
	target_anything = 1
	pointCost = 20
	cooldown = 45 SECONDS //Starts at 45 seconds and scales upward exponentially

	cast(atom/target)
		if (..())
			return 1
		if (!target)
			target = get_turf(holder.owner)

		//Find a suitable corpse
		var/mob/living/carbon/human/H
		if (ishuman(target))
			H = target
		if (isturf(target))
			for (var/mob/living/carbon/human/mob_target in target.contents)
				if (!isdead(mob_target))
					continue
				if (mob_target.decomp_stage >= DECOMP_STAGE_SKELETONIZED)
					continue
				H = mob_target
				break
		if (ishuman(H))
			if (!isdead(H))
				boutput(holder.owner, "<span class='alert'>The living consciousness controlling this body shields it from being absorbed.</span>")
				return 1
			if (H.decomp_stage >= DECOMP_STAGE_SKELETONIZED)
				boutput(holder.owner, "<span class='alert'>That corpse is already too decomposed.</span>")
				return 1
			//check for formaldehyde. if there's more than the wraith's tol amt, we can't absorb right away.
			var/mob/living/intangible/wraith/W = src.holder.owner
			if (istype(W))
				var/amt = H.reagents.get_reagent_amount("formaldehyde")
				if (amt >= W.formaldehyde_tolerance)
					H.reagents.remove_reagent("formaldehyde", amt)
					boutput(holder.owner, "<span class='alert'>This vessel is tainted with an... unpleasant substance... It is now removed...But you are wounded</span>")
					particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#FFFFFF", 2, locate(H.x, H.y, H.z)))
					holder.owner.TakeDamage(null, 50, 0)
					return 0
		else
			boutput(holder.owner, "<span class='alert'>Absorbing [target] does not satisfy your ethereal taste.</span>")
			return 1
		if (!H)
			return 1 // no valid targets were identified, cast fails

		logTheThing(LOG_COMBAT, holder.owner, "absorbs the corpse of [key_name(H)] as a wraith.")
		var/turf/T = get_turf(H)
		// decay wraith receives bonuses for toxin damaged and decayed bodies, but can't absorb fresh kils without toxin damage
		if ((istype(holder.owner, /mob/living/intangible/wraith/wraith_decay)))
			if ((H.get_toxin_damage() >= 60) || (H.decomp_stage == DECOMP_STAGE_HIGHLY_DECAYED))
				boutput(holder.owner, "<span class='alert'>[H] is extremely rotten and bloated. It satisfies us greatly</span>")
				holder.points += 150
				T.fluid_react_single("miasma", 60, airborne = 1)
				H.visible_message("<span class='alert'><strong>[pick("A mysterious force rips [H]'s body apart!", "[H]'s corpse suddenly explodes in a cloud of miasma and guts!")]</strong></span>")
				H.gib()
			else if (!(H.get_toxin_damage() >= 30) && !(H.decomp_stage >= DECOMP_STAGE_BLOATED))
				boutput(holder.owner, "<span class='alert'>This body is too fresh. It needs to be poisoned or rotten before we consume it.</span>")
				return 1
		if (H.loc)//gibbed check
			//Make the corpse all grody and skeleton-y
			H.decomp_stage = DECOMP_STAGE_SKELETONIZED
			if (H.organHolder && H.organHolder.brain)
				qdel(H.organHolder.brain)
			H.set_face_icon_dirty()
			H.set_body_icon_dirty()
			particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#000000", 5, locate(H.x, H.y, H.z)))
			boutput(holder.owner, "<span class='alert'><b>[pick("You draw the essence of death out of [H]'s corpse!", "You drain the last scraps of life out of [H]'s corpse!")]</b></span>")
			H.visible_message("<span class='alert'>[pick("Black smoke rises from [H]'s corpse! Freaky!", "[H]'s corpse suddenly rots to nothing but bone in moments!")]</span>", null, "<span class='alert'>A horrid stench fills the air.</span>")
		playsound(T, "sound/voice/wraith/wraithsoulsucc[rand(1, 2)].ogg", 30, 0)
		holder.regenRate += 2
		var/datum/abilityHolder/wraith/AH = holder
		if (istype(AH))
			var/mob/living/intangible/wraith/W = AH.owner
			if (istype(W))
				W.onAbsorb(H)
			AH.corpsecount++

		return 0


	doCooldown()         //This makes it so wraith early game is much faster but hits a wall of high absorb cooldowns after ~5 corpses
		if (!holder)	 //so wraiths don't hit scientific notation rates of regen without playing perfectly for a million years
			return
		var/datum/abilityHolder/wraith/W = holder
		if (istype(W))
			if (W.corpsecount == 0)
				cooldown = 45 SECONDS
			else
				cooldown += W.corpsecount * 150
		last_cast = world.time + cooldown
		holder.updateButtons()
		SPAWN(cooldown + 5)
			holder?.updateButtons()
