/datum/targetable/changeling/devour
	name = "Devour"
	desc = "Almost instantly devour a human for DNA."
	icon_state = "devour"
	abomination_only = 1
	cooldown = 5 SECONDS
	targeted = 0
	target_anything = 0
	do_logs = FALSE
	restricted_area_check = ABILITY_AREA_CHECK_VR_ONLY

	cast(atom/target)
		if (..())
			return 1
		var/mob/living/C = holder.owner

		var/obj/item/grab/G = src.grab_check(null, 1, 1)
		if (!G || !istype(G))
			return 1
		var/mob/living/carbon/human/T = G.affecting

		if (!istype(T))
			boutput(C, SPAN_ALERT("This creature is not compatible with our biology."))
			return 1
		if (isnpcmonkey(T))
			boutput(C, SPAN_ALERT("Our hunger will not be satisfied by this lesser being."))
			return 1
		if (T.bioHolder.HasEffect("husk"))
			boutput(usr, SPAN_ALERT("This creature has already been drained..."))
			return 1
		if (isnpc(T))
			boutput(C, SPAN_ALERT("The DNA of this target seems inferior somehow, you have no desire to feed on it."))
			return 1


		actions.start(new/datum/action/bar/icon/abominationDevour(T, src), C)
		return 0

/datum/action/bar/icon/abominationDevour
	duration = 50
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
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
				var/obj/item/parts/possible_limb = H.limbs.vars?[L]
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
		ownerMob.show_message(SPAN_NOTICE("We must hold still for a moment..."), 1)
		ON_COOLDOWN(target, "changeling_remove_limb", 1 SECOND) //don't eat a limb right away
		logTheThing(LOG_COMBAT, ownerMob, "starts trying to devour [constructTarget(target,"combat")] as a changeling in horror form [log_loc(owner)].")

	onEnd()
		..()

		var/mob/ownerMob = owner
		if(owner && ownerMob && target && BOUNDS_DIST(owner, target) == 0 && devour)
			var/datum/abilityHolder/changeling/C = devour.holder
			if (istype(C))
				C.addDna(target)
			boutput(ownerMob, SPAN_NOTICE("We devour [target]!"))
			ownerMob.visible_message(SPAN_ALERT("<B>[ownerMob] hungrily devours [target]!</B>"))
			playsound(ownerMob.loc, 'sound/voice/burp_alien.ogg', 50, 1)
			logTheThing(LOG_COMBAT, ownerMob, "devours [constructTarget(target,"combat")] as a changeling in horror form [log_loc(owner)].")

			target.ghostize()
			qdel(target)

	onInterrupt()
		..()
		boutput(owner, SPAN_ALERT("Our feasting on [target] has been interrupted!"))
		devour.doCooldown()
