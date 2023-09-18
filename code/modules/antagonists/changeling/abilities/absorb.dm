/datum/action/bar/icon/abominationDevour
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "abom_devour"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	bar_icon_state = "bar-changeling"
	border_icon_state = "border-changeling"
	color_active = "#d73715"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/mob/living/target
	var/datum/targetable/changeling/devour/devour

	New(Target, Devour)
		target = Target
		devour = Devour
		..()

	onUpdate()
		..()

		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || !devour)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/ownerMob = owner
		var/obj/item/grab/G = ownerMob.equipped()

		if (!istype(G) || G.affecting != target || G.state == GRAB_PASSIVE)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!ON_COOLDOWN(target, "changeling_remove_limb", 1.5 SECONDS))
			var/list/valid_limbs = list("l_leg", "r_arm", "r_leg", "l_arm")
			var/mob/living/carbon/human/H = target
			H.TakeDamage("All", 15, 0, 0)
			take_bleeding_damage(H, null, 8, DAMAGE_STAB, TRUE)
			for (var/L in valid_limbs)
				var/obj/item/parts/possible_limb = H.limbs?[L]
				if (possible_limb)
					ownerMob.visible_message("<span class='combat bold'>[ownerMob] viciously devours [H]'s [possible_limb]!</span>")
					possible_limb.remove(FALSE)
					qdel(possible_limb)
					playsound(H, 'sound/voice/burp_alien.ogg', 35)
					H.emote("scream", FALSE)
					break

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || !devour)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/ownerMob = owner
		ownerMob.show_message("<span class='notice'>We must hold still for a moment...</span>", 1)
		ON_COOLDOWN(target, "changeling_remove_limb", 1 SECOND) //don't eat a limb right away

	onEnd()
		..()

		var/mob/ownerMob = owner
		if(owner && ownerMob && target && BOUNDS_DIST(owner, target) == 0 && devour)
			var/datum/abilityHolder/changeling/C = devour.holder
			if (istype(C))
				C.addDna(target)
			boutput(ownerMob, "<span class='notice'>We devour [target]!</span>")
			ownerMob.visible_message(text("<span class='alert'><B>[ownerMob] hungrily devours [target]!</B></span>"))
			playsound(ownerMob.loc, 'sound/voice/burp_alien.ogg', 50, 1)
			logTheThing(LOG_COMBAT, ownerMob, "devours [constructTarget(target,"combat")] as a changeling in horror form [log_loc(owner)].")

			target.ghostize()
			qdel(target)

	onInterrupt()
		..()
		boutput(owner, "<span class='alert'>Our feasting on [target] has been interrupted!</span>")
		devour.doCooldown()

/datum/targetable/changeling/devour
	name = "Devour"
	desc = "Almost instantly devour a human for DNA."
	icon_state = "devour"
	abomination_only = TRUE
	cooldown = 5 SECONDS
	restricted_area_check = ABILITY_AREA_CHECK_VR_ONLY

	cast(atom/target)
		. = ..()
		var/mob/living/C = holder.owner

		var/obj/item/grab/G = src.grab_check()
		if (!G)
			return TRUE
		var/mob/living/carbon/human/H = G.affecting

		actions.start(new/datum/action/bar/icon/abominationDevour(H, src), C)

	castcheck()
		. = ..()
		// need to do this here since currently I don't have a way of elegantly passing the target to cast() or vice versa.
		var/obj/item/grab/G = src.grab_check()
		if (!G)
			boutput(src.holder.owner, "<span class='alert'>You need to be grabbing someone to eat them!</span>")
			return FALSE
		var/mob/living/carbon/human/H = G.affecting
		if (!istype(H))
			boutput(src.holder.owner, "<span class='alert'>This creature is not compatible with our biology.</span>")
			return FALSE
		if (isnpc(H))
			boutput(src.holder.owner, "<span class='alert'>Our hunger will not be satisfied by this lesser being.</span>")
			return FALSE
		if (H.bioHolder.HasEffect("husk"))
			boutput(src.holder.owner, "<span class='alert'>This creature has already been drained...</span>")
			return FALSE

/datum/action/bar/private/icon/changelingAbsorb
	duration = 25 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "change_absorb"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	bar_icon_state = "bar-changeling"
	border_icon_state = "border-changeling"
	color_active = "#d73715"
	color_success = "#3fb54f"
	color_failure = "#8d1422"
	var/mob/living/target
	var/datum/targetable/changeling/absorb/devour
	var/last_complete = 0

	New(Target, Devour)
		target = Target
		devour = Devour
		..()

	onUpdate()
		..()

		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || !devour || devour.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/ownerMob = owner
		var/obj/item/grab/G = ownerMob.equipped()

		if (!istype(G) || G.affecting != target || G.state < GRAB_CHOKE)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/done = src.time_spent()
		var/complete = clamp((done / duration), 0, 1)
		if (complete >= 0.2 && last_complete < 0.2)
			boutput(ownerMob, "<span class='notice'>We extend a proboscis.</span>")
			ownerMob.visible_message(text("<span class='alert'><B>[ownerMob] extends a proboscis!</B></span>"))

		if (complete > 0.6 && last_complete <= 0.6)
			boutput(ownerMob, "<span class='notice'>We stab [target] with the proboscis.</span>")
			ownerMob.visible_message(text("<span class='alert'><B>[ownerMob] stabs [target] with the proboscis!</B></span>"))
			boutput(target, "<span class='alert'><B>You feel a sharp stabbing pain!</B></span>")
			random_brute_damage(target, 40)

		last_complete = complete

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || !devour || devour.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

		if (isliving(target))
			target:was_harmed(owner, special = "ling")

		devour.addBHData(target)

	onEnd()
		..()

		var/mob/ownerMob = owner
		if(owner && ownerMob && target && BOUNDS_DIST(owner, target) == 0 && devour)
			var/datum/abilityHolder/changeling/C = devour.holder
			if (istype(C))
				C.addDna(target)
			boutput(ownerMob, "<span class='notice'>We have absorbed [target]!</span>")
			ownerMob.visible_message(text("<span class='alert'><B>[ownerMob] sucks the fluids out of [target]!</B></span>"))
			logTheThing(LOG_COMBAT, ownerMob, "absorbs [constructTarget(target,"combat")] as a changeling [log_loc(owner)].")

			target.dna_to_absorb = 0
			target.death(FALSE)
			target.disfigured = TRUE
			target.UpdateName()
			target.bioHolder.AddEffect("husk")
			target.bioHolder.mobAppearance.flavor_text = "A desiccated husk."

	onInterrupt()
		..()
		boutput(owner, "<span class='alert'>Our absorption of [target] has been interrupted!</span>")

/datum/targetable/changeling/absorb
	name = "Absorb DNA"
	desc = "Suck the DNA out of a target."
	icon_state = "absorb"
	human_only = TRUE
	restricted_area_check = ABILITY_AREA_CHECK_VR_ONLY

	cast(atom/target)
		. = ..()
		var/mob/living/C = holder.owner

		var/obj/item/grab/G = src.grab_check(GRAB_CHOKE)
		if (!G)
			return TRUE
		var/mob/living/carbon/human/H = G.affecting

		actions.start(new/datum/action/bar/private/icon/changelingAbsorb(H, src), C)

	castcheck()
		. = ..()
		// have to do this here as well because I currently don't have an elegant way to pass an alternate target (something other than the target arg) here
		var/obj/item/grab/G = src.grab_check(GRAB_CHOKE)
		if (!G)
			return TRUE
		var/mob/living/carbon/human/H = G.affecting
		if (!istype(H))
			boutput(src.holder.owner, "<span class='alert'>This creature is not compatible with our biology.</span>")
			return FALSE
		if (isnpcmonkey(H))
			boutput(src.holder.owner, "<span class='alert'>Our hunger will not be satisfied by this lesser being.</span>")
			return FALSE
		if (isnpc(H))
			boutput(src.holder.owner, "<span class='alert'>The DNA of this target seems inferior somehow, you have no desire to feed on it.</span>")
			addBHData(H)
			return FALSE
		if (H.bioHolder.HasEffect("husk"))
			boutput(src.holder.owner, "<span class='alert'>This creature has already been drained...</span>")
			return FALSE

	proc/addBHData(var/mob/living/T)
		var/datum/abilityHolder/changeling/C = holder
		var/mob/ownerMob = holder.owner
		if (istype(C) && isnull(C.absorbed_dna[T.real_name]))
			var/datum/bioHolder/originalBHolder = new/datum/bioHolder(T)
			originalBHolder.CopyOther(T.bioHolder)
			C.absorbed_dna[T.real_name] = originalBHolder
			ownerMob.show_message("<span class='notice'>We can now transform into [T.real_name].</span>", 1)
