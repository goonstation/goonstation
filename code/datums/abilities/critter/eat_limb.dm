/datum/targetable/critter/eat_limb
	name = "Bite Limb"
	desc = "Swallow a limb on the ground, or attempt to gnaw a random one off of someone!"
	icon_state = "mimic_eat_limb"
	cooldown = 45 SECONDS
	targeted = TRUE
	target_anything = TRUE
	cooldown_after_action = TRUE
	var/datum/human_limbs/torn_limb

	New()
		..()
		// stomach retreat can get away with being by itself, but eat limb should always come bundled with it (probably will seperate later)
		if (!holder.owner.getAbility(/datum/targetable/critter/stomach_retreat))
			holder.owner.addAbility(/datum/targetable/critter/stomach_retreat)
		if (!holder.owner.GetComponent(/datum/component/death_barf))
			holder.owner.AddComponent(/datum/component/death_barf)

	cast(atom/target)
		. = ..()
		var/datum/targetable/critter/stomach_retreat/stomach_abil = src.holder.getAbility(/datum/targetable/critter/stomach_retreat)
		if (stomach_abil?.inside)
			return TRUE
		if (ishuman(target) && target != src.holder.owner)
			var/mob/living/carbon/human/targetHuman = target
			var/list/randLimbBase = list("r_arm", "r_leg", "l_arm", "l_leg")
			var/list/randLimb
			for (var/potential_limb in randLimbBase) // build a list of limbs the target actually has
				if (targetHuman.limbs.get_limb(potential_limb))
					LAZYLISTADD(randLimb, potential_limb)
			src.torn_limb = targetHuman.limbs.get_limb(pick(randLimb))
		if (ishuman(target) || istype(target, /obj/item/parts/human_parts))
			src.holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] leaps, latching onto and gnawing at [src.torn_limb]!</b>"))
		else
			return
		actions.start(new/datum/action/bar/icon/eat_limb(target, holder.owner, src.torn_limb), holder.owner)

/datum/action/bar/icon/eat_limb
	duration = 1 SECONDS
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	interrupt_flags = null
	var/atom/target
	var/mob/user
	var/obj/item/parts/tornlimb

	New(Target, User, Tornlimb)
		target = Target
		user = User
		tornlimb = Tornlimb
		..()

	onStart()
		..()
		if (ishuman(src.target))
			src.duration = 5 SECONDS
			APPLY_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE, "chomping")
			RegisterSignal(src.user, COMSIG_MOB_GRABBED, PROC_REF(hold_slip))
			var/mob/living/carbon/human/human = src.target
			LAZYLISTADD(human.attached_objs, src.user)
			src.user.set_loc(src.target.loc)
			src.user.transform = matrix(src.user.transform, 90, MATRIX_ROTATE | MATRIX_MODIFY)
			ADD_FLAG(src.user.flags, CLICK_DELAY_IN_CONTENTS)
			switch (src.tornlimb.slot)
				if ("l_leg")
					src.user.pixel_y = -13
					src.user.pixel_x = 6
				if ("r_leg")
					src.user.pixel_y = -13
					src.user.pixel_x = -6
				if ("l_arm")
					src.user.pixel_x = 10
				if ("r_arm")
					src.user.pixel_x = -10
		else
			src.interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ACTION
			src.duration = 1 SECONDS
		if (istype(src.user, /mob/living/critter/mimic))
			var/mob/living/critter/mimic/mimic = src.user
			mimic.stop_hiding()
			mimic.last_disturbed = INFINITY
			mimic.use_stunned_icon = FALSE

	onUpdate()
		..()
		if (!ON_COOLDOWN(global, "chomp_gib", 2 SECONDS))
			var/gib = make_cleanable(/obj/decal/cleanable/blood/gibs, get_turf(target))
			playsound(src.user, 'sound/impact_sounds/Flesh_Crush_1.ogg', 60, 1)
			eat_twitch(src.user)
			random_brute_damage(src.target, 6)
			ThrowRandom(gib, rand(2,6))

	onEnd()
		..()
		if (istype(src.user, /mob/living/critter/mimic))
			var/mob/living/critter/mimic/antag_spawn/mimic = src.user
			mimic.last_disturbed = 1 SECONDS
			mimic.use_stunned_icon = TRUE
		if (ishuman(src.target))
			var/mob/living/carbon/human/human = src.target
			src.user.transform = null
			UnregisterSignal(src.user, COMSIG_MOB_GRABBED)
			LAZYLISTREMOVE(human.attached_objs, src.user)
			src.user.set_loc(src.target.loc)
			src.user.pixel_y = 0
			src.user.pixel_x = 0
			take_bleeding_damage(src.target, src.user, 15, DAMAGE_CUT, 1)
			REMOVE_ATOM_PROPERTY(src.user, PROP_MOB_CANTMOVE, "chomping")
			REMOVE_FLAG(src.user.flags, CLICK_DELAY_IN_CONTENTS)
		src.gobble(src.target, src.user)

	proc/gobble(atom/target, mob/user)
		var/datum/component/death_barf/barfcomp = user.GetComponent(/datum/component/death_barf)
		if (ishuman(target))
			var/limb_obj = src.tornlimb.sever()
			target.emote("scream")
			user.contents.Add(limb_obj)
			if (barfcomp)
				barfcomp.record_limb(limb_obj)
			var/datum/targetable/critter/eat_limb/abil = user.getAbility(/datum/targetable/critter/eat_limb)
			abil.afterAction()
		else
			user.contents.Add(target)
			barfcomp.record_limb(target)

	proc/hold_slip(source, obj/item/grab/grab)
		SPAWN(0.5 SECONDS)
			if (!grab.affecting || !grab.assailant)
				return
			boutput(src.target, SPAN_ALERT("You try to grab the [src.user] but it's writhing around too hard!"))
			qdel(grab)
