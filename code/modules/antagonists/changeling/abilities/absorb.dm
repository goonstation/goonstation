/datum/targetable/changeling/absorb
	name = "Absorb DNA"
	desc = "Suck the DNA out of a target."
	icon_state = "absorb"
	human_only = 1
	cooldown = 0
	targeted = 0
	target_anything = 0
	do_logs = FALSE
	restricted_area_check = ABILITY_AREA_CHECK_VR_ONLY

	cast(atom/target)
		if (..())
			return 1
		var/mob/living/C = holder.owner

		var/obj/item/grab/G = src.grab_check(null, 3, 1)
		if (!G || !istype(G))
			return 1
		var/mob/living/carbon/human/T = G.affecting

		if (!istype(T))
			boutput(C, SPAN_ALERT("This creature is not compatible with our biology."))
			return 1
		if (isnpcmonkey(T))
			boutput(C, SPAN_ALERT("Our hunger will not be satisfied by this lesser being."))
			return 1
		if (isnpc(T))
			boutput(C, SPAN_ALERT("The DNA of this target seems inferior somehow, you have no desire to feed on it."))
			addBHData(T)
			return 1
		if (T.bioHolder.HasEffect("husk"))
			boutput(usr, SPAN_ALERT("This creature has already been drained..."))
			return 1

		actions.start(new/datum/action/bar/private/icon/changelingAbsorb(T, src), C)
		return 0

	proc/addBHData(var/mob/living/victim)
		var/datum/abilityHolder/changeling/C = holder
		var/mob/ownerMob = holder.owner
		if (istype(C) && isnull(C.absorbed_dna[victim.real_name]))
			C.absorbed_dna[victim.real_name] = new /datum/absorbedIdentity(victim)
			ownerMob.show_message(SPAN_NOTICE("We can now transform into [victim.real_name]."), 1)

	//the actual absorb action we do at the end of the actionbar
	proc/absorb(mob/living/carbon/human/target)
		var/mob/living/ownerMob = src.holder.owner
		var/datum/abilityHolder/changeling/C = src.holder
		if (istype(C))
			C.addDna(target)
		boutput(ownerMob, SPAN_NOTICE("We have absorbed [target]!"))
		ownerMob.visible_message(SPAN_ALERT("<B>[ownerMob] sucks the fluids out of [target]!</B>"))
		logTheThing(LOG_COMBAT, ownerMob, "absorbs [constructTarget(target,"combat")] as a changeling [log_loc(ownerMob)].")

		target.dna_to_absorb = 0
		target.death(FALSE)
		target.disfigured = TRUE
		target.UpdateName()
		target.bioHolder.AddEffect("husk")
		target.bioHolder.mobAppearance.flavor_text = "A desiccated husk."

		if (ishuman(ownerMob))
			var/mob/living/carbon/human/H = ownerMob
			if (H.sims)
				H.sims.affectMotive("Thirst", 10)
				H.sims.affectMotive("Hunger", 10)


/datum/targetable/changeling/absorb/transfer
	name = "Transfer DNA"
	desc = "Suck the DNA out of a target and instantly become them, leaving your old body behind as a husk."
	icon_state = "absorb_transfer"

	absorb(mob/living/carbon/human/target)
		var/mob/living/ownerMob = src.holder.owner
		var/datum/abilityHolder/changeling/C = src.holder
		if (istype(C))
			C.addDna(target)
		boutput(ownerMob, SPAN_NOTICE("We have absorbed [target]!"))
		ownerMob.visible_message(SPAN_ALERT("<B>[ownerMob] sucks the fluids out of [target]!</B>"))
		logTheThing(LOG_COMBAT, ownerMob, "absorbs [constructTarget(target,"combat")] as a changeling [log_loc(ownerMob)].")
		target.full_heal()
		ownerMob.mind.transfer_to(target)
		C.composite_owner.removeHolder(C.type)
		if (istype(target.abilityHolder, /datum/abilityHolder/composite))
			var/datum/abilityHolder/composite/target_composite = target.abilityHolder
			target_composite.removeHolder(src.preferred_holder_type) //in case they're already a changeling
			target_composite.addHolderInstance(C)
		C.transferOwnership(target)
		ownerMob.dna_to_absorb = 0
		ownerMob.death(FALSE)
		ownerMob.disfigured = TRUE
		ownerMob.UpdateName()
		ownerMob.bioHolder.AddEffect("husk")
		ownerMob.bioHolder.mobAppearance.flavor_text = "A desiccated husk."
		ownerMob.ensure_speech_tree().RemoveSpeechOutput(SPEECH_OUTPUT_HIVECHAT_MEMBER)
		ownerMob.ensure_listen_tree().RemoveListenInput(LISTEN_INPUT_HIVECHAT)

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (H.sims)
				H.sims.affectMotive("Thirst", 10)
				H.sims.affectMotive("Hunger", 10)


/datum/action/bar/private/icon/changelingAbsorb
	duration = 250
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
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

		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || !devour || !devour.cooldowncheck())
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
			boutput(ownerMob, SPAN_NOTICE("We extend a proboscis."))
			ownerMob.visible_message(SPAN_ALERT("<B>[ownerMob] extends a proboscis!</B>"))

		if (complete > 0.6 && last_complete <= 0.6)
			boutput(ownerMob, SPAN_NOTICE("We stab [target] with the proboscis."))
			ownerMob.visible_message(SPAN_ALERT("<B>[ownerMob] stabs [target] with the proboscis!</B>"))
			boutput(target, SPAN_ALERT("<B>You feel a sharp stabbing pain!</B>"))
			random_brute_damage(target, 40)

		last_complete = complete

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || !devour || !devour.cooldowncheck())
			interrupt(INTERRUPT_ALWAYS)
			return

		if (isliving(target))
			target:was_harmed(owner, special = "ling")

		devour.addBHData(target)
		logTheThing(LOG_COMBAT, owner, "starts trying to absorb [constructTarget(target,"combat")] as a changeling [log_loc(owner)].")

	onEnd()
		..()
		if(owner && target && BOUNDS_DIST(owner, target) == 0 && devour)
			devour.absorb(target)


	onInterrupt()
		..()
		boutput(owner, SPAN_ALERT("Our absorption of [target] has been interrupted!"))
