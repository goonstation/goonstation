/datum/targetable/critter/eat_limb
	name = "Bite Limb"
	desc = "Swallow a limb on the ground, or attempt to gnaw a random one off of someone!"
	icon_state = "mimic_eat_limb"
	cooldown = 45 SECONDS
	targeted = TRUE
	target_anything = TRUE
	cooldown_after_action = TRUE

	New()
		..()
		// stomach retreat can get away with being by itself, but eat limb should always come bundled with it
		if (!holder.owner.getAbility(/datum/targetable/critter/stomach_retreat))
			holder.owner.addAbility(/datum/targetable/critter/stomach_retreat)
		if (!holder.owner.GetComponent(/datum/component/death_barf))
			holder.owner.AddComponent(/datum/component/death_barf)

	cast(atom/target)
		. = ..()
		var/turf/T = get_turf(holder.owner)
		if (!T.z || isrestrictedz(T.z))
			boutput(holder.owner, SPAN_ALERT("You can't do that here!"))
			return
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
	var/atom/target
	var/mob/user

	New(Target, User)
		target = Target
		user = User
		..()

	onStart()
		..()
		if (ishuman(target))
			src.duration = 5 SECONDS
		else
			src.duration = 1 SECONDS
		if (istype(user, /mob/living/critter/mimic))
			var/mob/living/critter/mimic/mimic = user
			mimic.stop_hiding()
			mimic.last_disturbed = INFINITY

	onUpdate()
		..()
		if (!ON_COOLDOWN(global, "chomp_gib", 2 SECONDS))
			var/gib = make_cleanable(/obj/decal/cleanable/blood/gibs, get_turf(target))
			playsound(user, 'sound/impact_sounds/Flesh_Crush_1.ogg', 60, 1)
			eat_twitch(user)
			random_brute_damage(target, 2)
			ThrowRandom(gib, rand(2,6))

	onEnd()
		..()
		if (istype(user, /mob/living/critter/mimic))
			var/mob/living/critter/mimic/mimic = user
			mimic.last_disturbed = 1 SECONDS
		src.gobble(target, user)

	proc/gobble(atom/target, mob/user)
		var/datum/component/death_barf/barfcomp = user.GetComponent(/datum/component/death_barf)
		if (ishuman(target))
			var/mob/living/carbon/human/targetHuman = target
			var/list/randLimbBase = list("r_arm", "r_leg", "l_arm", "l_leg")
			var/list/randLimb
			for (var/potential_limb in randLimbBase) // build a list of limbs the target actually has
				if (targetHuman.limbs.get_limb(potential_limb))
					LAZYLISTADD(randLimb, potential_limb)
			var/datum/human_limbs/torn_limb = targetHuman.limbs.get_limb(pick(randLimb))
			var/limb_obj = torn_limb.sever()
			target.emote("scream")
			user.contents.Add(limb_obj)
			barfcomp.record_limb(limb_obj)
			var/datum/targetable/critter/eat_limb/abil = user.getAbility(/datum/targetable/critter/eat_limb)
			abil.afterAction()
		else
			user.contents.Add(target)
			barfcomp.record_limb(target)
