/datum/targetable/critter/eat_limb
	name = "Bite Limb"
	desc = "Swallow a limb on the ground, or attempt to gnaw a random one off of someone!"
	icon_state = "mimic_eat_limb"
	cooldown = 45 SECONDS
	targeted = TRUE
	target_anything = TRUE
	cooldown_after_action = TRUE

	cast(atom/target)
		. = ..()
		if (istype(target, /obj/item/parts/human_parts))
			var/obj/item/parts/human_parts/limb = target
			if (limb.mimic_edible)
				actions.start(new/datum/action/bar/icon/eat_limb(holder, limb, holder.owner), holder.owner)
		else if (ishuman(target))
			var/mob/living/carbon/human/targetHuman = target
			if (!targetHuman.limbs)
				boutput(holder.owner, "Your target doesn't have any limbs! Did you do that?")
				return
			else
				var/randLimb = list("random_limb_string" = pick("l_arm", "r_arm", "l_leg", "r_leg"))
				var/obj/item/parts/human_parts/targetLimb = targetHuman.limbs.get_limb(randLimb["random_limb_string"])
				if (targetLimb)
					boutput(world, SPAN_ALERT("<b>[holder.owner] starts to gnaw at [targetLimb]!</b>"))
					actions.start(new/datum/action/bar/icon/eat_limb(holder, targetLimb, holder.owner, TRUE), holder.owner)
				else
					src.cast(target)

/datum/action/bar/icon/eat_limb
	duration = 1 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ACTION
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/datum/targetable/critter/eat_limb/eat
	var/atom/target
	var/mob/living/critter/mimic/antag_spawn/user
	var/floorlimb

	New(Eat, Target, User, Floorlimb)
		eat = Eat
		src.target = Target
		user = User
		floorlimb = Floorlimb
		..()
		if (floorlimb)
			duration = 5 SECONDS

	onStart()
		..()
		user.stop_hiding()
		user.last_disturbed = INFINITY

	onEnd()
		..()
		user.last_disturbed = 1 SECONDS
		if (floorlimb)
			src.gobble(target, user, TRUE)
		else
			src.gobble(target, user)

	proc/gobble(atom/target, mob/user, var/gnaw = FALSE)
		var/datum/human_limbs/limbTarget = target
		var/mob/living/critter/mimic/antag_spawn/mimic = user
		var/obj/limb = null
		if (gnaw)
			limb = limbTarget.sever()
			var/datum/targetable/critter/eat_limb/abil = mimic.getAbility(/datum/targetable/critter/eat_limb)
			abil.afterAction()
		else
			limb = limbTarget

		playsound(mimic, 'sound/voice/burp_alien.ogg', 60, 1)
		if (mimic.stomachHolder)
			limb.set_loc(mimic.stomachHolder.region.get_random_turf())
			LAZYLISTADD(mimic.stomachHolder.limbs_eaten, limb)
			limb.pixel_x = rand(-12,12)
			limb.pixel_y = rand(-12,12)
		else
			boutput(mimic, "You can't eat this...")
