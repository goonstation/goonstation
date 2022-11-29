/mob/living/critter/wraith/skeleton_commander
	name = "skeleton commander"
	desc = "A bulky skeleton here to encourage his friends."
	density = 1
	hand_count = 2
	can_help = 1
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	custom_gib_handler = /proc/bonegibs
	icon = 'icons/mob/skeleton_commander.dmi'
	icon_state = "skeleton_commander"
	health_brute = 90
	health_brute_vuln = 0.7
	health_burn = 90
	health_burn_vuln = 0.3
	var/mob/living/intangible/wraith/master = null
	var/deathsound = "sound/impact_sounds/plate_break.ogg"

	New(var/turf/T, var/mob/living/intangible/wraith/M = null)
		..(T)
		if(M != null)
			src.master = M

			if (isnull(M.summons))
				M.summons = list()
			M.summons += src

		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION_WEAK, src)
		src.add_stam_mod_max("commander", 50)
		abilityHolder.addAbility(/datum/targetable/critter/skeleton_commander/rally)
		abilityHolder.addAbility(/datum/targetable/critter/skeleton_commander/summon_lesser_skeleton)

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_burn_vuln)

	death(var/gibbed)
		if (src.master)
			src.master.summons -= src
			src.master = null
		if (!gibbed)
			src.unequip_all()
			playsound(src, src.deathsound, 50, 0)
			visible_message("[src] shatters in bits of bones!")
			src.gib()
		return ..()


	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.suffix = "-L"
		HH.icon_state = "handl"
		HH.limb_name = "left arm"

		HH = hands[2]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb/halberd
		HH.name = "halberd"
		HH.suffix = "-R"
		HH.icon_state = "halberd"
		HH.limb_name = "halberd"
		HH.can_hold_items = 0
		HH.can_attack = 1
		HH.can_range_attack = 1

/datum/limb/halberd
	attack_range(atom/target, var/mob/user, params)
		switch (user.a_intent)
			if (INTENT_HELP)
				return 0
			if (INTENT_DISARM)
				if(!isturf(target.loc) && !isturf(target)) return

				var/direction = get_dir_pixel(user, target, params)
				if(direction == NORTHEAST || direction == NORTHWEST || direction == SOUTHEAST || direction == SOUTHWEST)
					direction = (prob(50) ? turn(direction, 45) : turn(direction, -45))

				var/list/attacked = list()

				var/turf/one = get_step(user, direction)
				var/turf/effect = get_step(one, direction)
				var/turf/two = get_step(one, turn(direction, 90))
				var/turf/three = get_step(one, turn(direction, -90))

				var/obj/itemspecialeffect/swipe/swipe = new /obj/itemspecialeffect/swipe
				swipe.color = "#EBE6EB"
				swipe.setup(effect)
				swipe.set_dir(direction)

				var/hit = FALSE
				for(var/turf/T in list(one, two, three))
					for(var/atom/movable/A in T)
						if(A in attacked) continue
						if(ismob(A) && !isobserver(A))
							var/mob/M = A
							M.TakeDamageAccountArmor("All", rand(7,9), 0, 0, DAMAGE_CUT)
							attacked += A
							hit = TRUE

				if (!hit)
					playsound(user, 'sound/effects/swoosh.ogg', 50, 0)
				else
					playsound(user, 'sound/impact_sounds/Flesh_Cut_1.ogg', 50, 0)
				return 0
			if (INTENT_GRAB)
				if(!isturf(target.loc) && !isturf(target)) return
				var/direction = get_dir_pixel(user, target, params)
				var/list/attacked = list()

				var/turf/one = get_step(user, direction)
				var/turf/two = get_step(one, direction)

				var/obj/itemspecialeffect/stab = new /obj/itemspecialeffect
				stab.alpha = 255
				stab.color = "#EBE6EB"
				stab.icon_state = "spear"
				stab.setup(get_turf(user))
				stab.set_dir(direction)
				var/hit = FALSE
				for(var/turf/T in list(one, two))
					for(var/atom/A in T)
						if(A in attacked) continue
						if(ismob(A) && !isobserver(A))
							var/mob/M = A
							M.TakeDamageAccountArmor("All", rand(8,9), 0, 0, DAMAGE_STAB)
							attacked += A
							hit = TRUE

				if (!hit)
					playsound(user, 'sound/effects/swoosh.ogg', 50, 0)
				else
					playsound(user, 'sound/impact_sounds/Flesh_Stab_3.ogg', 80)

			if (INTENT_HARM)
				if (!isturf(target.loc) && !isturf(target)) return
				var/direction = get_dir_pixel(user, target, params)
				var/turf/turf = get_step(user, direction)
				var/hit = FALSE

				var/obj/itemspecialeffect/simple/S = new /obj/itemspecialeffect/simple
				S.setup(turf)

				for(var/atom/A in turf)
					if(ismob(A) && !isobserver(A))
						var/mob/M = A
						M.TakeDamageAccountArmor("All", rand(7,9), 0, 0, DAMAGE_CUT)
						hit = TRUE
						break

				if (!hit)
					playsound(user, 'sound/effects/swoosh.ogg', 50, 0)
				else
					playsound(user, 'sound/impact_sounds/Flesh_Stab_3.ogg', 80)

	harm(mob/target, var/mob/living/user)
		if(check_target_immunity( target ))
			return 0
		logTheThing(LOG_COMBAT, user, "stabs [constructTarget(target,"combat")] with [src] at [log_loc(user)].")
		var/obj/item/affecting = target.get_affecting(user)
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, affecting, 6, 9, rand(5,7), can_punch = 0, can_kick = 0)
		user.attack_effects(target, affecting)
		var/action = pick("slashes", "stabs", "pierces")
		msgs.base_attack_message = "<b><span class='alert'>[user] [action] [target] with their [src.holder]!</span></b>"
		msgs.played_sound = "sound/impact_sounds/Flesh_Stab_3.ogg"
		msgs.damage_type = DAMAGE_STAB
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = target
