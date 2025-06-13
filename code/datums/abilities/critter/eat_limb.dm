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
		if (ishuman(target) || istype(target, /obj/item/parts/human_parts))
			boutput(world, SPAN_ALERT("<b>[holder.owner] starts to gnaw at [target]!</b>"))
		else
			return
		actions.start(new/datum/action/bar/icon/eat_limb(target, holder.owner), holder.owner)

/datum/action/bar/icon/eat_limb
	duration = 1 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ACTION
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/last_crunch = 0
	var/atom/target
	var/mob/living/critter/mimic/antag_spawn/user

	New(Target, User)
		target = Target
		user = User
		..()

	onStart()
		..()
		if (ishuman(target))
			duration = 5 SECONDS
		else
			duration = 1 SECONDS
		user.stop_hiding()
		user.last_disturbed = INFINITY

	onUpdate()
		..()
		last_crunch++
		if (last_crunch >= 2)
			var/gib = make_cleanable(/obj/decal/cleanable/blood/gibs, get_turf(target))
			playsound(user, 'sound/impact_sounds/Flesh_Crush_1.ogg', 60, 1)
			eat_twitch(user)
			random_brute_damage(target, 2)
			ThrowRandom(gib, rand(2,6))
			last_crunch = 0

	onEnd()
		..()
		user.last_disturbed = 1 SECONDS
		src.gobble(target, user)

	proc/gobble(atom/target, mob/user)
		if (ishuman(target))
			var/mob/living/carbon/human/targetHuman = target
			var/list/randLimbBase = list("r_arm", "r_leg", "l_arm", "l_leg")
			var/list/randLimb
			for (var/potential_limb in randLimbBase) // build a list of limbs the target actually has
				if (targetHuman.limbs.get_limb(potential_limb))
					LAZYLISTADD(randLimb, potential_limb)
			var/datum/human_limbs/torn_limb = targetHuman.limbs.get_limb(pick(randLimb))
			var/limb_obj = torn_limb.sever()
			user.contents.Add(limb_obj)
			target.emote("scream")
			var/datum/targetable/critter/eat_limb/abil = user.getAbility(/datum/targetable/critter/eat_limb)
			abil.afterAction()
		else
			user.contents.Add(target)
