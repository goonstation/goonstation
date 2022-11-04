/datum/targetable/brain_slug/devour_limb
	name = "Devour"
	desc = "Eat a human's limb for sustenance."
	icon_state = "infest_host"
	cooldown = 60 SECOND
	targeted = 1

	cast(atom/target)
		if (target == holder.owner)
			return TRUE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to infest.</span>")
			return TRUE
		if (!istype(target, /mob/living/carbon/human))
			boutput(holder.owner, "<span class='alert'>That doesn't seem to have a limb you can munch on.</span>")
			return TRUE
		var/mob/living/carbon/human/H = target
		actions.start(new/datum/action/bar/private/icon/devour_action(H, holder.owner), holder.owner)
		return FALSE

/datum/action/bar/private/icon/devour_action
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ATTACKED
	id = "brain_slug_devour"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/mob/living/carbon/human/current_target = null
	var/mob/living/critter/brain_slug/the_slug = null
	var/limb = null
	var/limb_acronym = null

	New(var/mob/living/carbon/human/M, var/mob/living/source)
		current_target = M
		src.the_slug = source
		var/mob/living/caster = the_slug
		switch(caster.zone_sel.selecting)
			if ("r_arm")
				if (src.current_target.limbs.r_arm)
					src.limb = src.current_target.limbs.r_arm
					src.limb_acronym = "r_arm"
			if ("l_arm")
				if (src.current_target.limbs.l_arm)
					src.limb = src.current_target.limbs.l_arm
					src.limb_acronym = "l_arm"
			if ("r_leg")
				if (src.current_target.limbs.r_leg)
					src.limb = src.current_target.limbs.r_leg
					src.limb_acronym = "r_leg"
			if ("l_leg")
				if (src.current_target.limbs.l_leg)
					src.limb = src.current_target.limbs.l_leg
					src.limb_acronym = "l_leg"
		..()

	onStart()
		var/mob/living/caster = the_slug
		if (caster == null || !isalive(caster) || !can_act(caster) || current_target == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (limb)
			boutput(caster, "<span class=notice>You begin to envelop [current_target]'s [limb]!</span>")
		else
			boutput(caster, "<span class=notice>You begin to envelop [current_target]!</span>")
		..()

	onUpdate()
		..()
		var/mob/living/caster = the_slug
		if (caster == null || !isalive(caster) || !can_act(caster) || current_target == null || BOUNDS_DIST(caster, current_target) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		var/mob/living/caster = the_slug
		random_brute_damage(current_target, 15)
		if (limb)
			current_target.lose_limb(src.limb_acronym)
			caster.visible_message("<span class='alert'>[caster] chomps down on [current_target]'s [limb] and tears it apart!</span>", "<span class='alert'>You devour [current_target]'s [limb]! Delicious!</span>")
			qdel(src.limb)
		else
			random_brute_damage(current_target, 5)
			caster.visible_message("<span class='alert'>[caster] tears off a chunk of flesh from [current_target]'s and swallows it!</span>", "<span class='alert'>You devour some of [current_target]! Scrumptious!</span>")
		if (prob(50))
			current_target.emote("scream")
		playsound(current_target.loc, 'sound/impact_sounds/Flesh_Break_2.ogg', 70)
		bleed(current_target, 10, 2)
		caster.HealDamage("All", 15, 0)
		..()

	onInterrupt()
		var/mob/living/caster = the_slug
		boutput(caster, "<span class='alert'>You were interrupted!</span>")
		..()
