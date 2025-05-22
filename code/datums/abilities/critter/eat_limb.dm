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
				var/list/randLimbBase = list("r_arm", "r_leg", "l_arm", "l_leg")
				var/list/randLimb = null
				for (var/L in randLimbBase)
					if (targetHuman.limbs.get_limb(L))
						LAZYLISTADD(randLimb, L)
				var/obj/item/parts/human_parts/targetLimb = targetHuman.limbs.get_limb(pick(randLimb))

				boutput(world, SPAN_ALERT("<b>[holder.owner] starts to gnaw at [targetLimb]!</b>"))
				actions.start(new/datum/action/bar/icon/eat_limb(holder, targetLimb, holder.owner, TRUE), holder.owner)

/datum/action/bar/icon/eat_limb
	duration = 1 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ACTION
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/last_crunch = 0
	var/datum/targetable/critter/eat_limb/eat
	var/atom/target
	var/mob/living/critter/mimic/antag_spawn/user
	var/moblimb

	New(Eat, Target, User, Moblimb)
		eat = Eat
		target = Target
		user = User
		moblimb = Moblimb
		..()
		if (moblimb)
			duration = 5 SECONDS

	onStart()
		..()
		user.stop_hiding()
		user.last_disturbed = INFINITY

	onUpdate()
		..()
		last_crunch++
		if (last_crunch >= 2)
			var/datum/human_limbs/T = target
			var/gib = make_cleanable(/obj/decal/cleanable/blood/gibs, get_turf(target))
			playsound(user, 'sound/impact_sounds/Flesh_Crush_1.ogg', 60, 1)
			eat_twitch(user)
			random_brute_damage(T.holder, 2)
			ThrowRandom(gib, rand(2,6))
			last_crunch = 0

	onEnd()
		..()
		user.last_disturbed = 1 SECONDS
		if (moblimb)
			src.gobble(target, user, TRUE)
		else
			src.gobble(target, user)

	proc/gobble(atom/target, mob/user, var/gnaw = FALSE)
		var/datum/human_limbs/limbTarget = target
		var/mob/living/critter/mimic/antag_spawn/mimic = user
		var/obj/limb = null
		if (gnaw)
			limb = limbTarget.sever()
			target.emote("scream")
			var/datum/targetable/critter/eat_limb/abil = mimic.getAbility(/datum/targetable/critter/eat_limb)
			abil.afterAction()
		else
			limb = limbTarget

		if (mimic.stomachHolder)
			playsound(mimic, 'sound/voice/burp_alien.ogg', 60, 1)
			limb.set_loc(mimic.stomachHolder.limb_target_turf)
			LAZYLISTADD(mimic.stomachHolder.limbs_eaten, limb)
			limb.pixel_x = rand(-12,12)
			limb.pixel_y = rand(-12,12)
			mimic.stomachHolder.limb_target_turf = get_turf(pick(mimic.stomachHolder.non_walls))
		else
			boutput(mimic, "You can't eat this...")
