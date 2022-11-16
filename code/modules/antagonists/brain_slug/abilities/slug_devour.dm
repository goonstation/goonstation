/datum/targetable/brain_slug/slug_devour
	name = "Devour"
	desc = "Eat a human's limb or organs for sustenance."
	icon_state = "devour"
	cooldown = 50 SECOND
	targeted = 1

	cast(atom/target)
		if (!isturf(holder.owner.loc))
			boutput(holder.owner, "<span class='notice'>You cannot use that here!</span>")
			return TRUE
		if (target == holder.owner)
			return TRUE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to infest.</span>")
			return TRUE
		if (!istype(target, /mob/living/carbon/human))
			boutput(holder.owner, "<span class='alert'>That doesn't seem to have a limb or organs you can munch on.</span>")
			return TRUE
		var/mob/living/carbon/human/H = target
		actions.start(new/datum/action/bar/icon/devour_action(H, holder.owner), holder.owner)
		return TRUE

/datum/action/bar/icon/devour_action
	duration = 2 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ATTACKED
	id = "brain_slug_devour"
	icon = 'icons/mob/brainslug_ui.dmi'
	icon_state = "action_harvest"
	var/mob/living/carbon/human/current_target = null
	var/mob/living/caster = null
	var/target = null
	var/limb_acronym = null
	var/target_is_limb = TRUE

	New(var/mob/living/carbon/human/M, var/mob/living/source)
		current_target = M
		src.caster = source
		if (!src.current_target.organHolder) return
		else
			switch(src.caster.zone_sel.selecting)
				if ("r_arm")
					if (src.current_target.limbs.r_arm)
						src.target = src.current_target.limbs.r_arm
						src.limb_acronym = "r_arm"
				if ("l_arm")
					if (src.current_target.limbs.l_arm)
						src.target = src.current_target.limbs.l_arm
						src.limb_acronym = "l_arm"
				if ("r_leg")
					if (src.current_target.limbs.r_leg)
						src.target = src.current_target.limbs.r_leg
						src.limb_acronym = "r_leg"
				if ("l_leg")
					if (src.current_target.limbs.l_leg)
						src.target = src.current_target.limbs.l_leg
						src.limb_acronym = "l_leg"
				if ("chest" || "head")
					var/list/targets = list()
					src.target_is_limb = FALSE
					if (src.current_target.organHolder.left_eye)
						targets += src.current_target.organHolder.left_eye
					if (src.current_target.organHolder.right_eye)
						targets += src.current_target.organHolder.right_eye
					if (src.current_target.organHolder.liver)
						targets += src.current_target.organHolder.liver
					if (src.current_target.organHolder.left_kidney)
						targets += src.current_target.organHolder.left_kidney
					if (src.current_target.organHolder.left_lung)
						targets += src.current_target.organHolder.left_lung
					if (src.current_target.organHolder.right_kidney)
						targets += src.current_target.organHolder.right_kidney
					if (src.current_target.organHolder.right_lung)
						targets += src.current_target.organHolder.right_lung
					if (src.current_target.organHolder.spleen)
						targets += src.current_target.organHolder.spleen
					if (src.current_target.organHolder.pancreas)
						targets += src.current_target.organHolder.pancreas
					if (src.current_target.organHolder.intestines)
						targets += src.current_target.organHolder.intestines
					if (src.current_target.organHolder.stomach)
						targets += src.current_target.organHolder.stomach
					//No organs left? Go for the heart
					if (!length(targets))
						if (src.current_target.organHolder.heart)
							targets += src.current_target.organHolder.heart
						if (!length(targets))
							return
					src.target = pick(targets)
			..()

	onStart()
		if (!src.caster || !isalive(src.caster) || !can_act(src.caster) || !src.current_target)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (src.target)
			if (src.target_is_limb)
				boutput(src.caster, "<span class=notice>You begin to envelop [src.current_target]'s [src.target]!</span>")
			else
				boutput(src.caster, "<span class=notice>You begin to bite off [src.current_target]'s [src.target]!</span>")
		else
			boutput(src.caster, "<span class=notice>You begin to envelop [src.current_target]!</span>")
		hit_twitch(src.current_target)
		..()

	onUpdate()
		..()
		if (!src.caster || !isalive(src.caster) || !can_act(src.caster) || !src.current_target || BOUNDS_DIST(src.caster, src.current_target) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		random_brute_damage(src.current_target, 15)
		if (src.target)
			if (src.target_is_limb)
				src.current_target.lose_limb(src.limb_acronym)
			src.caster.visible_message("<span class='alert'>[src.caster] chomps down on [src.target] and tears it apart!</span>", "<span class='alert'>You devour [src.target]! [pick("Delicious!", "Delightful!", "Filling!")]</span>")
			qdel(src.target)
		else
			random_brute_damage(src.current_target, 5)
			src.caster.visible_message("<span class='alert'>[src.caster] tears off a chunk of flesh from [src.current_target]'s and swallows it!</span>", "<span class='alert'>You devour some of [src.current_target]! [pick("Scrumptious!", "Yum!")]</span>")
		if (prob(50))
			src.current_target.emote("scream")
		playsound(src.current_target.loc, 'sound/impact_sounds/Flesh_Break_2.ogg', 70)
		bleed(src.current_target, 10, 2)
		src.current_target.setStatus("stunned", 2 SECONDS)
		src.caster.HealDamage("All", 15, 0)
		var/datum/targetable/ability = caster.abilityHolder.getAbility(/datum/targetable/brain_slug/slug_devour)
		ability.doCooldown()
		..()

	onInterrupt()
		boutput(src.caster, "<span class='alert'>You were interrupted!</span>")
		..()
