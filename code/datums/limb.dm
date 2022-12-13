/**
 * Limb datums for arms. Describes all activity performed by the limb.
 * Currently, this is basically attack_hand().
 *
 * Also serves as a future holder for any other special limb activity.
 */

/datum/limb
	var/obj/item/parts/holder = null

	var/special_next = 0
	var/datum/item_special/disarm_special = null //Contains the datum which executes the items special, if it has one, when used beyond melee range.
	var/datum/item_special/harm_special = null //Contains the datum which executes the items special, if it has one, when used beyond melee range.
	var/can_pickup_item = TRUE

	New(var/obj/item/parts/holder)
		..()
		src.holder = holder

		src.setDisarmSpecial (/datum/item_special/disarm)
		src.setHarmSpecial (/datum/item_special/harm)

	disposing()
		if(holder?.limb_data == src)
			holder.limb_data = null
		holder = null
		if(disarm_special)
			disarm_special.dispose()
			disarm_special = null
		if(harm_special)
			harm_special.dispose()
			harm_special = null
		..()

	// !!CAUTION!! it is allowed to delete the target here
	// Mob is also passed as a convenience/redundancy.
	proc/attack_hand(atom/target, var/mob/user, var/reach, params, location, control)
		if(!target) // fix runtime Cannot execute null.attack hand().
			return
		target.Attackhand(user, params, location, control)

	proc/harm(mob/living/target, var/mob/living/user)
		if (special_next)
			if(!user || !target)
				return 0
			if (!target.melee_attack_test(user))
				return

			
			var/datum/attackResults/msgs = user.calculate_melee_attack(target, 2, 9, 0, 0.7, 0) // 0.7x stamina damage. No crits.
			msgs.damage_type = DAMAGE_BLUNT
			user.attack_effects(target, user.zone_sel?.selecting)
			msgs.flush(0)

			special_next = 0
		else
			user.melee_attack_normal(target, 0, 0, DAMAGE_BLUNT)
		user.lastattacked = target

	proc/help(mob/living/target, var/mob/living/user)
		user.do_help(target)
		user.lastattacked = target

	proc/disarm(mob/living/target, var/mob/living/user)
		if (special_next)
			src.shove(target,user)
			special_next = 0
		else
			user.disarm(target)
		user.lastattacked = target

	proc/grab(mob/living/target, var/mob/living/user)
		if(target == user)
			user.grab_self()
			return
		if (issilicon(target))
			return
		user.grab_other(target)
		user.lastattacked = target

	//calls attack specials if we got em
	//Ok look i know this isn't a true pixelaction() but it fits into the itemspecial call so i'm doin it
	proc/attack_range(atom/target, var/mob/user, params)
		if(user.a_intent == "disarm")
			if(disarm_special)
				SEND_SIGNAL(user, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)
				disarm_special.pixelaction(target,params,user)
				.= 1
		else if (user.a_intent == "harm")
			if(harm_special)
				for (var/obj/item/cloaking_device/I in user)
					SEND_SIGNAL(user, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)
				harm_special.pixelaction(target,params,user)
				.= 1
		else
			.= 0

	proc/is_on_cooldown()
		return 0

	//alt version of disarm that shoves the target away from the user instead of trying to slap item out of hand
	proc/shove(mob/living/target, var/mob/living/user)
		user.disarm(target,0,0,DAMAGE_BLUNT,1)
		special_next = 0

/datum/limb/hitscan
	var/brute = 5
	var/burn = 0
	var/cooldown = 30
	var/next_shot_at = 0
	var/image/default_obscurer

	attack_range(atom/target, var/mob/user, params)
		if (next_shot_at > ticker.round_elapsed_ticks)
			return
		user.visible_message("<b class='alert'>[user] fires at [target] with the [holder.name]!</b>")
		playsound(user.loc, 'sound/weapons/lasermed.ogg', 100, 1)
		next_shot_at = ticker.round_elapsed_ticks + cooldown
		if (ismob(target))
			var/mob/MT = target
			if (prob(30))
				user.visible_message("<span class='alert'>The shot misses!</span>")
			else
				MT.TakeDamageAccountArmor(user.zone_sel ? user.zone_sel.selecting : "All", brute, burn, 0, burn ? DAMAGE_BURN : DAMAGE_BLUNT)
		elecflash(target.loc,power = 2)

	is_on_cooldown()
		if (ticker.round_elapsed_ticks < next_shot_at)
			return next_shot_at - ticker.round_elapsed_ticks
		return 0

/datum/limb/railgun
	var/cooldown = 50
	var/next_shot_at = 0
	var/image/default_obscurer
	is_on_cooldown()
		if (ticker.round_elapsed_ticks < next_shot_at)
			return next_shot_at - ticker.round_elapsed_ticks
		return 0

	attack_range(atom/target, var/mob/user, params)
		var/turf/start = user.loc
		if (!isturf(start))
			return
		target = get_turf(target)
		if (!target)
			return
		if (target == start)
			return
		if (next_shot_at > ticker.round_elapsed_ticks)
			return
		next_shot_at = ticker.round_elapsed_ticks + cooldown

		playsound(user, 'sound/effects/mag_warp.ogg', 50, 1)
		SPAWN(rand(1,3)) // so it might miss, sometimes, maybe
			var/obj/target_r = new/obj/railgun_trg_dummy(target)

			playsound(user, 'sound/weapons/railgun.ogg', 50, 1)
			user.set_dir(get_dir(user, target))

			var/list/affected = DrawLine(user, target_r, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeRailG",1,1,"HalfStartRailG","HalfEndRailG",OBJ_LAYER,1)

			for(var/obj/O in affected)
				O.anchored = 1 //Proc wont spawn the right object type so lets do that here.
				O.name = "Energy"
				var/turf/src_turf = O.loc
				for(var/obj/machinery/vehicle/A in src_turf)
					if(A == O || A == user) continue
					A.meteorhit(O)
				for(var/mob/living/M in src_turf)
					if(M == O || M == user) continue
					M.meteorhit(O)
				for(var/turf/T in src_turf)
					if(T == O) continue
					T.meteorhit(O)

			sleep(0.3 SECONDS)
			for (var/obj/O in affected)
				qdel(O)

			if(istype(target_r, /obj/railgun_trg_dummy)) qdel(target_r)

/datum/limb/arcflash
	var/wattage = 15000
	var/cooldown = 60
	var/next_shot_at = 0
	var/image/default_obscurer
	is_on_cooldown()
		if (ticker.round_elapsed_ticks < next_shot_at)
			return next_shot_at - ticker.round_elapsed_ticks
		return 0

	attack_range(atom/target, var/mob/user, params)
		if (next_shot_at > ticker.round_elapsed_ticks)
			return
		next_shot_at = ticker.round_elapsed_ticks + cooldown
		arcFlashTurf(user, get_turf(target), wattage)

/datum/limb/gun
	var/datum/projectile/proj = null
	var/cooldown = 3 SECONDS
	var/reload_time = 20 SECONDS
	var/shots = 4
	var/current_shots = 0
	var/reloading_str = "reloading"
	var/image/default_obscurer
	var/muzzle_flash = null

	attack_range(atom/target, var/mob/user, params)
		src.shoot(target, user, FALSE, params)

	proc/point_blank(atom/target, var/mob/user)
		src.shoot(target, user, TRUE)

	proc/shoot(atom/target, var/mob/user, var/pointblank = FALSE, params)
		//slightly cursed ref usage because we can't use ON_COOLDOWN with datums
		if (GET_COOLDOWN(user, "\ref[src] reload") && !current_shots)
			boutput(user, "<span class='alert'>The [holder.name] is [reloading_str]!</span>")
			return
		else if (current_shots <= 0)
			current_shots = shots
		if (current_shots > 0)
			if (ON_COOLDOWN(user, "\ref[src] shoot", src.cooldown))
				return
			. = TRUE
			current_shots--
			if (pointblank)
				src.shoot_pointblank(target, user)
			else
				src.shoot_range(target, user, params)
		if (current_shots <= 0)
			ON_COOLDOWN(user, "\ref[src] reload", src.reload_time)

	proc/shoot_range(atom/target, var/mob/user, params)
		var/pox = text2num(params["icon-x"]) - 16
		var/poy = text2num(params["icon-y"]) - 16
		shoot_projectile_ST_pixel(user, proj, target, pox, poy)
		if (src.muzzle_flash)
			if (isturf(user.loc))
				var/turf/origin = user.loc
				muzzle_flash_attack_particle(user, origin, target, src.muzzle_flash)
		user.visible_message("<b class='alert'>[user] fires at [target] with the [holder.name]!</b>")

	proc/shoot_pointblank(atom/target, var/mob/user)
		for (var/i = 0; i < proj.shot_number; i++)
			var/obj/projectile/P = initialize_projectile_pixel(user, proj, target, 0, 0)
			if (!P)
				return FALSE
			if(BOUNDS_DIST(user, target) == 0)
				P.was_pointblank = 1
				P.shooter = null
				P.mob_shooter = user
				hit_with_existing_projectile(P, target) // Includes log entry.
			else
				P.launch()
		user.visible_message("<b class='alert'>[user] shoots [target] point-blank with the [holder.name]!</b>")

	attack_hand(atom/target, mob/user, var/reach, params, location, control)
		return

	help(mob/living/target, mob/living/user)
		return

	disarm(mob/living/target, mob/living/user)
		src.point_blank(target, user)

	grab(mob/living/target, mob/living/user)
		return

	harm(mob/living/target, mob/living/user)
		src.point_blank(target, user)

	//despite the name, this means reloading
	is_on_cooldown(var/mob/user)
		return GET_COOLDOWN(user, "\ref[src] reload")

/datum/limb/gun/kinetic
	shoot(atom/target, var/mob/user, var/pointblank = FALSE, params)
		if(..() && istype(user.loc, /turf/space) || user.no_gravity)
			user.inertia_dir = get_dir(target, user)
			step(user, user.inertia_dir)
	arm38
		proj = new/datum/projectile/bullet/revolver_38
		shots = 3
		current_shots = 3
		cooldown = 30
		reload_time = 200
		muzzle_flash = "muzzle_flash"

	abg
		proj = new/datum/projectile/bullet/abg
		shots = 6
		current_shots = 6
		cooldown = 30
		reload_time = 300
		muzzle_flash = "muzzle_flash"

	artillery
		proj = new/datum/projectile/bullet/autocannon
		shots = 1
		current_shots = 1
		cooldown = 50
		reload_time = 50

	glitch
		proj = new/datum/projectile/bullet/glitch
		shots = 1
		current_shots = 1
		cooldown = 40
		reload_time = 40

	fire_elemental
		proj = new/datum/projectile/bullet/flare
		shots = 1
		current_shots = 1
		cooldown = 40
		reload_time = 40

	syringe
		proj = new/datum/projectile/syringefilled
		shots = 1
		current_shots = 1
		cooldown = 40
		reload_time = 300

	spike
		proj = new/datum/projectile/special/spreader/uniform_burst/spikes
		shots = 1
		current_shots = 1
		cooldown = 1 SECOND
		reload_time = 1 SECOND

	rifle
		proj = new/datum/projectile/bullet/assault_rifle
		shots = 5
		current_shots = 5
		cooldown = 1 SECOND
		reload_time = 20 SECONDS

/datum/limb/gun/energy
	phaser
		proj = new/datum/projectile/laser/light
		shots = 1
		current_shots = 1
		cooldown = 30
		reload_time = 30

	cutter
		proj = new/datum/projectile/laser/drill/cutter
		shots = 1
		current_shots = 1
		cooldown = 30
		reload_time = 30

	disruptor
		proj = new/datum/projectile/disruptor/high
		shots = 1
		current_shots = 1
		cooldown = 40
		reload_time = 40

/datum/limb/mouth
	var/sound_attack = 'sound/voice/animal/werewolf_attack1.ogg'
	var/dam_low = 3
	var/dam_high = 9
	var/custom_msg = null
	var/miss_prob = 80
	var/stam_damage_mult = 1

	attack_hand(atom/target, var/mob/user, var/reach)
		if (ismob(target))
			..()

		if (isitem(target))
			var/obj/item/potentially_food = target
			if (potentially_food.edible)
				potentially_food.attack(user, user)

	help(mob/target, var/mob/user)
		return

	disarm(mob/target, var/mob/user)
		return

	grab(mob/target, var/mob/user)
		return

	harm(mob/target, var/mob/user)
		if (!user || !target)
			return 0

		if (!target.melee_attack_test(user))
			return

		if (prob(src.miss_prob) || is_incapacitated(target)|| target.restrained())
			
			var/datum/attackResults/msgs = user.calculate_melee_attack(target, dam_low, dam_high, 0, stam_damage_mult, !isghostcritter(user), can_punch = 0, can_kick = 0)
			user.attack_effects(target, user.zone_sel?.selecting)
			msgs.base_attack_message = src.custom_msg ? src.custom_msg : "<b><span class='combat'>[user] bites [target]!</span></b>"
			msgs.played_sound = src.sound_attack
			msgs.flush(0)
			user.HealDamage("All", 2, 0)
		else
			user.visible_message("<b><span class='combat'>[user] attempts to bite [target] but misses!</span></b>")
		user.lastattacked = target

/datum/limb/mouth/small // for cats/mice/etc
	sound_attack = 'sound/impact_sounds/Flesh_Tear_1.ogg'
	dam_low = 1
	dam_high = 3
	stam_damage_mult = 0.3

	harm(mob/target, var/mob/user)
		if (isghostcritter(user) && ishuman(target) && target.health < target.max_health * 0.8)
			boutput(user, "Your spectral conscience refuses to damage this human any further.")
			return 0
		..()


/datum/limb/mouth/small/possum
	dam_low = 0
	dam_high = 0

/datum/limb/item
	can_pickup_item = FALSE
	attack_hand(atom/target, var/mob/user, var/reach, params, location, control)
		if (holder?.remove_object && istype(holder.remove_object))
			target.Attackby(holder.remove_object, user, params, location, control)
			if (target)
				holder.remove_object.AfterAttack(target, user, reach)

/datum/limb/bear
	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return

		if (!istype(user))
			target.Attackhand(user, params, location, control)
			return

		if (ismob(target))
			..()
			return

		if (isobj(target))
			switch (user.smash_through(target, list("window", "grille", "blob")))
				if (0)
					if (isitem(target))
						boutput(user, "<span class='alert'>You try to pick [target] up but it wiggles out of your hand. Opposable thumbs would be nice.</span>")
						return
					else if (istype(target, /obj/machinery))
						boutput(user, "<span class='alert'>You're unlikely to be able to use [target]. You manage to scratch its surface though.</span>")
						return

				if (1)
					user.lastattacked = target
					return

		..()
		return

	help(mob/target, var/mob/living/user)
		user.show_message("<span class='alert'>Nope. Not going to work. You're more likely to kill them.</span>")
		user.lastattacked = target

	disarm(mob/target, var/mob/living/user)
		logTheThing(LOG_COMBAT, user, "mauls [constructTarget(target,"combat")] with bear limbs (disarm intent) at [log_loc(user)].")
		user.visible_message("<span class='alert'>[user] mauls [target] while trying to disarm them!</span>")
		harm(target, user, 1)

	grab(mob/target, var/mob/living/user)
		logTheThing(LOG_COMBAT, user, "mauls [constructTarget(target,"combat")] with bear limbs (grab intent) at [log_loc(user)].")
		user.visible_message("<span class='alert'>[user] mauls [target] while trying to grab them!</span>")
		harm(target, user, 1)

	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if (no_logs != 1)
			logTheThing(LOG_COMBAT, user, "mauls [constructTarget(target,"combat")] with bear limbs at [log_loc(user)].")
		
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 6, 10, 0, can_punch = 0, can_kick = 0)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("maim", "maul", "mangle", "rip", "claw", "lacerate", "mutilate")
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target] with their [src.holder]!</span></b>"
		msgs.played_sound = 'sound/impact_sounds/Flesh_Tear_3.ogg'
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		if (prob(20))
			if (iscarbon(target))
				var/mob/living/carbon/C = target
				C.do_disorient(25, disorient=2 SECONDS)
		user.lastattacked = target

/datum/limb/bear/zombie

	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control) //TODO: Make this actually do damage to things instead of just smashing the thing.
		if (!holder)
			return

		if (!istype(user))
			target.Attackhand(user, params, location, control)
			return
		if (issilicon(target))
			special_attack_silicon(target, user)
			return

		if (isobj(target)) //I am just going to do this like this, this is not good but I do not care.
			var/hit = FALSE
			if (isitem(target))
				boutput(user, "<span class='alert'>Your zombie arm is too dumb to be able to handle this item!</span>")
				return
			else if(istype(target, /obj/machinery/door))
				var/obj/machinery/door/O = target
				O.visible_message("<span class='alert'><b>[user]</b> violently smashes against the [O]!</span>")
				playsound(user.loc, O.hitsound, 50, 1, pitch = 1.6)
				O.take_damage(20, user) //Like 30ish hits to break a normal airlock?
				hit = TRUE
			else if(istype(target, /obj/grille))
				var/obj/grille/O = target
				if (!O.shock(user, 70))
					O.visible_message("<span class='alert'><b>[user]</b> violently slashes [O]!</span>")
					playsound(O.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 80, 1)
					O.damage_slashing(5)
				hit = TRUE

			else if(istype(target, /obj/window))
				var/obj/window/O = target
				O.visible_message("<span class='alert'>[user] smashes into the window.</span>", "<span class='notice'>You mash yourself against the window.</span>")
				O.damage_blunt(15)
				playsound(user.loc, O.hitsound, 50, 1, pitch = 1.6)
				hit = TRUE

			else if(istype(target, /obj/table))
				var/obj/table/O = target
				O.visible_message("<span class='alert'><b>[user]</b> violently rips apart the [O]!</span>")
				playsound(O.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
				O.deconstruct()
				hit = TRUE

			else if(istype(target, /obj/structure/woodwall))
				var/obj/window/O = target
				O.Attackhand(user)
				hit = TRUE
			else if(istype(target, /obj/machinery/bot))
				var/obj/machinery/bot/O = target
				O.explode()
				O.visible_message("<span class='alert'><b>[user]</b> violently rips [O] apart!</span>")
				hit = TRUE
			if (hit)
				user.lastattacked = target
				attack_particle(user, target)
			if(prob(40) && !ON_COOLDOWN(user, "zombie arm scream", 1 SECOND))
				user.emote("scream")
			return

		if (istype(target, /obj/machinery))
			boutput(user, "<span class='alert'>You're unlikely to be able to use [target]. You manage to scratch its surface though.</span>")
			return

		..()
		return

	disarm(mob/target, var/mob/living/user)
		logTheThing(LOG_COMBAT, user, "mauls [constructTarget(target,"combat")] with zomb limbs (disarm intent) at [log_loc(user)].")
		user.visible_message("<span class='alert'>[user] mauls [target] while trying to disarm them!</span>")
		harm(target, user, 1)

	grab(mob/target, var/mob/living/user)
		if (!holder)
			return

		if (!istype(user) || !ismob(target))
			target.Attackhand(user)
			return

		if(check_target_immunity( target ))
			return 0

		user.grab_other(target, 1) // Use standard grab proc.

		// Werewolves and shamblers grab aggressively by default.
		var/obj/item/grab/GD = user.equipped()
		if (GD && istype(GD) && (GD.affecting && GD.affecting == target))
			GD.state = GRAB_STRONG
			APPLY_ATOM_PROPERTY(target, PROP_MOB_CANTMOVE, GD)
			target.update_canmove()
			GD.UpdateIcon()
			user.visible_message("<span class='alert'>[user] grabs hold of [target] aggressively!</span>")

		return

	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if (no_logs != 1)
			logTheThing(LOG_COMBAT, user, "mauls [constructTarget(target,"combat")] with bear limbs at [log_loc(user)].")
		
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 6, 10, 1, can_punch = 0, can_kick = 0)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("maim", "maul", "mangle", "rip", "scratch", "mutilate")
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target] with their [src.holder]!</span></b>"
		msgs.played_sound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
		msgs.damage_type = DAMAGE_BLUNT
		msgs.flush(SUPPRESS_LOGS)
		if (prob(40))
			if (iscarbon(target))
				var/mob/living/carbon/C = target
				C.do_disorient(25, disorient=3 SECONDS)
		if (ishuman(target) && ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.mutantrace, /datum/mutantrace/zombie))
				target.changeStatus("z_pre_inf", rand(5,9) SECONDS)
		else if (issilicon(target))
			special_attack_silicon(target, user)

		user.lastattacked = target


/datum/limb/dualsaw

	attack_hand(atom/target, var/mob/living/user, var/reach)
		if (!holder)
			return

		if (!istype(user))
			target.Attackhand(user)
			return

		if (ismob(target))
			..()
			return

		..()
		return

	help(mob/target, var/mob/living/user)
		user.show_message("<span class='alert'>Not going to work. You're more likely to kill them.</span>")
		user.lastattacked = target

	disarm(mob/target, var/mob/living/user)
		logTheThing(LOG_COMBAT, user, "slashes [constructTarget(target,"combat")] with dual saw (disarm intent) at [log_loc(user)].")
		user.visible_message("<span class='alert'>[user] slashes [target] while trying to disarm them!</span>")
		harm(target, user, 1)

	grab(mob/target, var/mob/living/user)
		logTheThing(LOG_COMBAT, user, "slashes [constructTarget(target,"combat")] with dual saw (grab intent) at [log_loc(user)].")
		user.visible_message("<span class='alert'>[user] slashes [target] while trying to grab them!</span>")
		harm(target, user, 1)

	harm(mob/target, var/mob/living/user, var/no_logs = 0)

		var/mob/living/carbon/human/H = target
		var/list/limbs = list("l_arm","r_arm","l_leg","r_leg")
		var/the_limb = null
		if (user.zone_sel.selecting in limbs)
			the_limb = user.zone_sel.selecting
		else
			the_limb = pick("l_arm","r_arm","l_leg","r_leg")

		if (!the_limb)
			return //who knows

		if (prob(8))
			H.sever_limb(the_limb)

		if (no_logs != 1)
			logTheThing(LOG_COMBAT, user, "slashes [constructTarget(target,"combat")] with dual saw at [log_loc(user)].")
		
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 6, 10, 0, can_punch = 0, can_kick = 0)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("lacerate", "carve", "mangle", "sever", "hack", "slice", "mutilate")
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target] with their [src.holder]!</span></b>"
		msgs.played_sound = 'sound/effects/sawhit.ogg'
		boutput(target, "<span class='alert'>You can feel the saw slicing your body apart!</span>")
		target.emote("scream")
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		if (prob(60))
			target.changeStatus("weakened", 2 SECONDS)
		user.lastattacked = target

/datum/limb/brullbar
	var/log_name = "brullbar limbs"
	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return
		if(check_target_immunity( target ))
			return
		var/quality = src.holder.quality

		if (!istype(user))
			target.Attackhand(user, params, location, control)
			return

		if (isobj(target))
			switch (user.smash_through(target, list("window", "grille", "door", "blob")))
				if (0)
					if (istype(target, /obj/item/reagent_containers))
						if (prob(50 * quality))
							user.visible_message("<span class='alert'>[user] accidentally crushes [target]!</span>", "<span class='alert'>You accidentally crush the [target]!</span>")
							qdel(target)
							return
					else if (isitem(target))
						if (prob(45))
							user.show_message("<span class='alert'>[target] slips through your claws!</span>")
							return

				if (1)
					user.lastattacked = target
					return

		..()
		return

	proc/accident(mob/target, mob/living/user)
		if(check_target_immunity( target ))
			return 0
		if (prob(25))
			logTheThing(LOG_COMBAT, user, "accidentally harms [constructTarget(target,"combat")] with [src] at [log_loc(user)].")
			user.visible_message("<span class='alert'><b>[user] accidentally claws [target] while trying to [user.a_intent] them!</b></span>", "<span class='alert'><b>You accidentally claw [target] while trying to [user.a_intent] them!</b></span>")
			harm(target, user, 1)
			return 1
		return 0

	help(mob/target, var/mob/living/user)
		if (accident(target, user))
			return
		else
			..()

	disarm(mob/target, var/mob/living/user)
		if (accident(target, user))
			return
		else
			..()

	grab(mob/target, var/mob/living/user)
		if (accident(target, user))
			return
		else
			..()

	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if(check_target_immunity( target ))
			return 0
		var/quality = src.holder.quality
		if (no_logs != 1)
			logTheThing(LOG_COMBAT, user, "mauls [constructTarget(target,"combat")] with [src] at [log_loc(user)].")
		
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 6, 10, rand(5,9) * quality, can_punch = 0, can_kick = 0)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("maim", "maul", "mangle", "rip", "claw", "lacerate", "mutilate")
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target] with their [src.holder]!</span></b>"
		msgs.played_sound = 'sound/impact_sounds/Flesh_Tear_3.ogg'
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		if (prob(20 * quality))
			if (iscarbon(target))
				var/mob/living/carbon/C = target
				C.do_disorient(25, disorient=2 SECONDS)
		user.lastattacked = target

/datum/limb/brullbar/severed_werewolf
	log_name = "severed werewolf limb"

// Currently used by the High Fever disease which is obtainable from the "Too Much" chem which only shows up in sickly pears, which are currently commented out. Go there to make use of this.
/datum/limb/hot //because
	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return
		if(check_target_immunity( target ))
			return


		if (!istype(user))
			target.Attackhand(user, params, location, control)
			return

		if (isitem(target))
			var/obj/item/I = target
			if(I.anchored)
				return 0
			var/obj/decal/cleanable/molten_item/I2 = make_cleanable(/obj/decal/cleanable/molten_item,I.loc)
			user.visible_message("<span class='alert'>The [I] melts in [user]'s clutch</span>", "<span class='alert'>The [I] melts in your clutch!</span>")
			qdel(target)
			I2.desc = "Looks like this was \an [I], melted by someone who was too much."
			for(var/mob/M in AIviewers(5, target))
				boutput(M, "<span class='alert'>\the [I] melts.</span>")
			qdel(I)
			return

		..()
		return

	proc/accident(mob/target, mob/living/user)
		if(check_target_immunity( target ))
			return 0
		if (prob(15))
			logTheThing(LOG_COMBAT, user, "accidentally harms [constructTarget(target,"combat")] with hot hands at [log_loc(user)].")
			user.visible_message("<span class='alert'><b>[user] accidentally melts [target] while trying to [user.a_intent] them!</b></span>", "<span class='alert'><b>You accidentally melt [target] while trying to [user.a_intent] them!</b></span>")
			harm(target, user, 1)
			return 1
		return 0

	help(mob/target, var/mob/living/user)
		if (accident(target, user))
			return
		else
			..()

	disarm(mob/target, var/mob/living/user)
		if (accident(target, user))
			return
		else
			..()

	grab(mob/target, var/mob/living/user)
		if (accident(target, user))
			return
		else
			..()

	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if(check_target_immunity( target ))
			return 0
		if (no_logs != 1)
			logTheThing(LOG_COMBAT, user, "melts [constructTarget(target,"combat")] with hot hands at [log_loc(user)].")
		
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 1, 3, 1, 0, 0, can_punch = 0, can_kick = 0)
		user.attack_effects(target, user.zone_sel?.selecting)

		msgs.base_attack_message = "<b><span class='alert'>[user] melts [target] with their clutch!</span></b>"
		msgs.played_sound = 'sound/impact_sounds/burn_sizzle.ogg'
		msgs.damage_type = DAMAGE_BURN
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = target


// A replacement for the awful custom_attack() overrides in mutantraces.dm, which consisted of two
// entire copies of pre-stamina melee attack code (Convair880).
/datum/limb/abomination
	var/weak = 0

	werewolf
		weak = 1 // Werewolf melee attacks are similar enough. Less repeated code.
	hastur
		weak = 2 //Same reason as above, its too similar to warrant a new limb.

	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return

		if(check_target_immunity( target ))
			return 0

		if (!istype(user))
			target.Attackhand(user, params, location, control)
			return

		if (istype(target, /obj/critter))
			user.lastattacked = target

			var/obj/critter/victim = target

			if (src.weak == 1)
				SPAWN(0)
					step_away(victim, user, 15)

				playsound(user.loc, pick('sound/voice/animal/werewolf_attack1.ogg', 'sound/voice/animal/werewolf_attack2.ogg', 'sound/voice/animal/werewolf_attack3.ogg'), 50, 1)
				SPAWN(0.1 SECONDS)
					if (user) playsound(user.loc, 'sound/impact_sounds/Flesh_Tear_3.ogg', 40, 1, -1)

				user.visible_message("<span class='alert'><B>[user] slashes viciously at [victim]!</B></span>")
				victim.health -= rand(4,8) * victim.brutevuln

			if (src.weak == 2)
				var/turf/T = get_edge_target_turf(user, user.dir)

				if (prob(66) && T && isturf(T))
					user.visible_message("<span class='alert'><B>[user] mauls [victim] viciously, sending them flying!</B></span>")
					victim.health -= 6 * victim.brutevuln
					victim.throw_at(T, 10, 2)
				else
					user.visible_message("<span class='alert'><B>[user] savagely slashes [victim]!</span>")
					victim.health -= 4 * victim.brutevuln

				playsound(user.loc, 'sound/misc/hastur/tentacle_hit.ogg', 25, 1, -1)

			else
				var/turf/T = get_edge_target_turf(user, user.dir)

				if (prob(66) && T && isturf(T))
					user.visible_message("<span class='alert'><B>[user] savagely punches [victim], sending them flying!</B></span>")
					victim.health -= 6 * victim.brutevuln
					victim.throw_at(T, 10, 2)
				else
					user.visible_message("<span class='alert'><B>[user] punches [victim]!</span>")
					victim.health -= 4 * victim.brutevuln

				playsound(user.loc, "punch", 25, 1, -1)

			if (victim?.alive && victim.health <= 0)
				victim.CritterDeath()
			return

		if (isobj(target))
			switch (user.smash_through(target, list("window", "grille", "door", "blob")))
				if (0)
					target.Attackhand(user, params, location, control)
					return
				if (1)
					user.lastattacked = target
					return

		if (ismob(target))
			user.lastattacked = target
			if (issilicon(target))
				special_attack_silicon(target, user)
				return
			else
				..()
				return

		..()
		return

	grab(mob/target, var/mob/living/user)
		if (!holder)
			return

		if (!istype(user) || !ismob(target))
			target.Attackhand(user)
			return

		if(check_target_immunity( target ))
			return 0

		if (issilicon(target))
			special_attack_silicon(target, user)
			return

		user.grab_other(target, 1) // Use standard grab proc.

		// Werewolves and shamblers grab aggressively by default.
		var/obj/item/grab/GD = user.equipped()
		if (GD && istype(GD) && (GD.affecting && GD.affecting == target))
			target.changeStatus("stunned", 2 SECONDS)
			GD.state = GRAB_STRONG
			APPLY_ATOM_PROPERTY(target, PROP_MOB_CANTMOVE, GD)
			target.update_canmove()
			GD.UpdateIcon()
			user.visible_message("<span class='alert'>[user] grabs hold of [target] aggressively!</span>")

		return

	disarm(mob/target, var/mob/living/user)
		if (!holder)
			return

		if (!istype(user) || !ismob(target))
			target.Attackhand(user)
			return

		if(check_target_immunity( target ))
			return 0

		if (target.melee_attack_test(user, null, null, 1) != 1) // Target.lying check is in there.
			return

		if (issilicon(target))
			special_attack_silicon(target, user)
			return

		var/send_flying = 0 // 1: a little bit | 2: across the room

		var/datum/attackResults/disarm/msgs = user.calculate_disarm_attack(target)

		if (!msgs || !istype(msgs))
			return

		user.lastattacked = target

		if (src.weak == 1) // Werewolves get a guaranteed knockdown.
			if (!target.anchored && prob(50))
				send_flying = 1

			msgs.played_sound = 'sound/impact_sounds/Generic_Shove_1.ogg'
			user.werewolf_audio_effects(target, "disarm")
			msgs.base_attack_message = "<span class='alert'><B>[user] [pick("clocks", "strikes", "smashes")] [target] with a [pick("fierce", "fearsome", "supernatural", "wild", "beastly")] punch, forcing them to the ground!</B></span>"

			if (prob(35))
				msgs.damage_type = DAMAGE_CUT // Nasty claws!

			msgs.damage = rand(1,9)
			target.changeStatus("weakened", 2 SECONDS)
			target.stuttering += 1


		else
			if (prob(25) && ishuman(target))
				var/mob/living/carbon/human/HH = target
				var/limb_name = "unknown limb"

				if (!HH || !ishuman(HH))
					..() // Something went very wrong, fall back to default disarm proc.
					return

				if (HH.l_hand)
					HH.sever_limb("l_arm")
					limb_name = "left arm"
				else if (HH.r_hand)
					HH.sever_limb("r_arm")
					limb_name = "right arm"
				else
					var/list/limbs = list("l_arm","r_arm","l_leg","r_leg")
					var/the_limb = pick(limbs)
					if (!HH.has_limb(the_limb))
						return 0
					HH.sever_limb(the_limb)
					switch (the_limb)
						if ("l_arm")
							limb_name = "left arm"
						if ("r_arm")
							limb_name = "right arm"
						if ("l_leg")
							limb_name = "left leg"
						if ("r_leg")
							limb_name = "right leg"

				if (prob(50) && !isdead(HH))
					HH.emote("scream")

				msgs.played_sound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
				msgs.base_attack_message = "<span class='alert'><B>[user] whips [HH] with the sharp edge of a chitinous tendril, shearing off their [limb_name]!</span>"
				msgs.damage_type = DAMAGE_CUT // We just lost a limb.

				msgs.damage = rand(1,5)
				HH.changeStatus("stunned", 2 SECONDS)

			else
				if (!target.anchored && prob(30))
					send_flying = 1
				else
					target.drop_item() // Shamblers get a guaranteed disarm.

				msgs.played_sound = 'sound/impact_sounds/Generic_Shove_1.ogg'
				msgs.base_attack_message = "<span class='alert'><B>[user] shoves [target] with a [pick("powerful", "fearsome", "intimidating", "strong")] tendril[send_flying == 0 ? "" : ", forcing them to the ground"]!</B></span>"
				msgs.damage = rand(1,2)

		logTheThing(LOG_COMBAT, user, "diarms [constructTarget(target,"combat")] with [src.weak == 1 ? "werewolf" : "abomination"] arms at [log_loc(user)].")

		if (send_flying == 2)
			msgs.after_effects += /proc/wrestler_backfist
		else if (send_flying == 1)
			msgs.after_effects += /proc/wrestler_knockdown

		msgs.flush(SUPPRESS_LOGS)

		user.lastattacked = target
		return

	harm(mob/target, var/mob/living/user)
		if (!holder)
			return

		if (!istype(user) || !ismob(target))
			target.Attackhand(user)
			return
		if(check_target_immunity( target ))
			return 0
		if (target.melee_attack_test(user) != 1)
			return

		if (issilicon(target))
			special_attack_silicon(target, user)
			return

		var/send_flying = 0 // 1: a little bit | 2: across the room
		
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, can_punch = 0, can_kick = 0)

		if (!msgs || !istype(msgs))
			return

		if (target.canmove && !target.anchored && !target.lying)
			if (prob(50))
				if (src.weak == 1 && prob(40))	//make werewolf punches a bit weaker to compensate for new abilities.
					send_flying = 1
				else if (prob(60))
					target.stuttering += 2
					send_flying = 1
				else
					target.stuttering += 3
					send_flying = 2
			else
				target.stuttering += 1
				target.changeStatus("stunned", 2 SECONDS)
		else
			target.changeStatus("stunned", 2 SECONDS)
			target.stuttering += 1

		if (src.weak == 1)
			//needed so tainted saliva can transfer on regular attacks
			user.werewolf_tainted_saliva_transfer(target)

			if (send_flying == 2)
				msgs.base_attack_message = "<span class='alert'><B>[user] delivers a supernatural punch, sending [target] flying!</b></span>"
			else
				if (prob(25))
					msgs.base_attack_message = "<span class='alert'><B>[user] mauls [target] viciously[send_flying == 0 ? "" : ", forcing them to the ground"]!</B></span>"
				else
					msgs.base_attack_message = "<span class='alert'><B>[user] slashes viciously at [target][send_flying == 0 ? "" : ", forcing them to the ground"]!</B></span>"
					target.add_fingerprint(user)

			if (prob(33) && !isdead(target) && !issilicon(target))
				target.emote("scream")

			msgs.played_sound = 'sound/impact_sounds/Generic_Shove_1.ogg'
			user.werewolf_audio_effects(target, "swipe")
			msgs.damage = rand(8, 17)
			msgs.damage_type = DAMAGE_CUT // Nasty claws!

		else if (src.weak == 2)
			if (send_flying == 2)
				msgs.base_attack_message = "<span class='alert'><B>[user] delivers a coil of tentacles at [target], sending them flying!</b></span>"
			else
				if (prob(25))
					msgs.base_attack_message = "<span class='alert'><B>[user] mauls [target] viciously[send_flying == 0 ? "" : ", forcing them to the ground"]!</B></span>"
				else
					msgs.base_attack_message = "<span class='alert'><B>[user] slashes viciously at [target][send_flying == 0 ? "" : ", forcing them to the ground"]!</B></span>"
					target.add_fingerprint(user)

			if (prob(33) && !isdead(target) && !issilicon(target))
				target.emote("scream")

			msgs.played_sound = 'sound/misc/hastur/tentacle_hit.ogg'
			msgs.damage = rand(8, 17)
			flick("hastur-attack", user)
			msgs.damage_type = DAMAGE_CUT // Nasty tentacles with sharp spikes!

		else
			if (send_flying == 2)
				msgs.base_attack_message = "<span class='alert'><B>[user] delivers a savage blow, sending [target] flying!</b></span>"
			else
				msgs.base_attack_message = "<span class='alert'><B>[user] punches [target] with a [pick("powerful", "fearsome", "intimidating", "strong")] tendril[send_flying == 0 ? "" : ", forcing them to the ground"]!</B></span>"

			msgs.played_sound = pick(sounds_punch)
			msgs.damage = rand(6, 13)
			msgs.damage_type = DAMAGE_BLUNT

		if (send_flying == 2)
			msgs.after_effects += /proc/wrestler_backfist
		else if (send_flying == 1)
			msgs.after_effects += /proc/wrestler_knockdown

		logTheThing(LOG_COMBAT, user, "punches [constructTarget(target,"combat")] with [src.weak == 1 ? "werewolf" : "abomination"] arms at [log_loc(user)].")
		user.attack_effects(target, user.zone_sel?.selecting)
		msgs.flush(SUPPRESS_LOGS)

		user.lastattacked = target
		return

// And why not (Convair880).
/datum/limb/hunter
	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return
		if(check_target_immunity( target ))
			return 0
		if (!istype(user))
			target.Attackhand(user, params, location, control)
			return

		if (isobj(target))
			switch (user.smash_through(target, list("door")))
				if (0)
					target.Attackhand(user, params, location, control)
					return
				if (1)
					return

		..()
		return

	harm(mob/target, var/mob/living/user)
		if (!holder)
			return
		if(check_target_immunity( target ))
			return 0
		if (!istype(user) || !ismob(target))
			target.Attackhand(user)
			return

		if (ismob(target))
			user.melee_attack_normal(target, 5) // Slightly more powerful punches. This is bonus damage, not a multiplier.
			return
		user.lastattacked = target
		..()
		return

/datum/limb/claw
	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return
		if(check_target_immunity( target ))
			return
		//var/quality = src.holder.quality

		if (!istype(user))
			target.Attackhand(user, params, location, control)
			return

		if (isobj(target))
			switch (user.smash_through(target, list("grille","blob")))
				if (0)
					if (isitem(target))
						if (prob(60))
							user.show_message("<span class='alert'>[target] slips through your claws!</span>")
							return
						return ..() // was it intended that you were never supposed to actually pick things up with this limb type???? I feel like it was not. call your parents!!! - haine
					if (istype(target,/obj/machinery/power/apc))
						var/obj/machinery/power/apc/APC = target
						for (var/i=1,i<=4,i++)
							APC.cut(i)
						user.visible_message("<span class='alert'><b>[user]'s claw slithers inside [target] and slashes the wires!</b></span>", "<span class='alert'><b>Your claw slithers inside [target] and slashes the wires!</b></span>")
						return
					if (istype(target,/obj/cable))
						var/obj/cable/C = target
						C.cut(user,user.loc)
						return
				if (1)
					user.lastattacked = target
					return
		..()
		return

	proc/accident(mob/target, mob/living/user)
		if(check_target_immunity( target ))
			return 0
		if (prob(25))
			logTheThing(LOG_COMBAT, user, "accidentally harms [constructTarget(target,"combat")] with claw arms at [log_loc(user)].")
			user.visible_message("<span class='alert'><b>[user] accidentally claws [target] while trying to [user.a_intent] them!</b></span>", "<span class='alert'><b>You accidentally claw [target] while trying to [user.a_intent] them!</b></span>")
			harm(target, user, 1)
			return 1
		return 0

	help(mob/target, var/mob/living/user)
		if (accident(target, user))
			return
		else
			..()

	disarm(mob/target, var/mob/living/user)
		if (accident(target, user))
			return
		else
			..()

	grab(mob/target, var/mob/living/user)
		if (accident(target, user))
			return
		else
			..()

	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if(check_target_immunity( target ))
			return 0
		var/quality = src.holder.quality
		if (no_logs != 1)
			logTheThing(LOG_COMBAT, user, "claws [constructTarget(target,"combat")] with claw arms at [log_loc(user)].")
		
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 10, 10, rand(1,3) * quality, can_punch = 0, can_kick = 0)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("maim", "stab", "rip", "claw", "slashe")
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target] with their [src.holder]!</span></b>"
		msgs.played_sound = 'sound/impact_sounds/Flesh_Tear_3.ogg'
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = target

/datum/limb/eldritch
	var/static/list/organs = list("heart", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix")

	harm(mob/living/target, var/mob/living/user)
		if(!user || !target)
			return FALSE
		if (!target.melee_attack_test(user))
			return

		
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, can_punch = 0)

		if (!msgs)
			return

		msgs.damage = 0
		msgs.damage_type = DAMAGE_BLUNT
		msgs.base_attack_message = "<span class='alert'><b>[user] punches [target][pick("!", ", with a seemingly unknown effect!", ", doing who knows what!")]</b></span>"
		user.attack_effects(target, user.zone_sel?.selecting)
		msgs.flush(SUPPRESS_LOGS)

		if (target.organHolder)
			var/list/possible_organs = list()
			for (var/organ in organs)
				if (target.organHolder.get_organ(organ))
					possible_organs += organ

			if (length(possible_organs))
				target.organHolder.damage_organ(5, 0, 0, pick(possible_organs))

				if (prob(25))
					boutput(target, "<span class='alert'>[pick("Your insides don't feel good!", "You don't feel right somehow.", "You feel strange inside.")]</span>")

		logTheThing(LOG_COMBAT, user, "punches [constructTarget(target, "combat")] with eldritch arms at [log_loc(user)].")

		user.lastattacked = target

/datum/limb/leg_hand
	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return
		if(check_target_immunity( target ))
			return

		if (!istype(user))
			target.Attackhand(user, params, location, control)
			return

		if (isobj(target))
			user.lastattacked = target
			user.smash_through(target, list("grille"))
			var/obj/O = target
			if (isitem(O) && !O.anchored)
				playsound(user,'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1, pitch = 1.7)
				var/turf/throw_to = get_edge_target_turf(user, get_dir(user,target))
				O.throw_at(throw_to, 8, 2)

		..()
		return

	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if(check_target_immunity( target ))
			return 0
		var/quality = src.holder.quality
		if (no_logs != 1)
			logTheThing(LOG_COMBAT, user, "kicks [constructTarget(target,"combat")] at [log_loc(user)].")
		
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 1, 4, rand(1,3) * quality, can_kick = 0)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("kick", "stomp", "boot")
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target]!</span></b>"
		msgs.played_sound = 'sound/impact_sounds/Generic_Hit_1.ogg'
		msgs.damage_type = DAMAGE_BLUNT
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = target


//little critters with teeth, like mice! can pick up small items only.
/datum/limb/small_critter
	var/max_wclass = W_CLASS_TINY // biggest thing we can carry
	var/dam_low = 1
	var/dam_high = 1
	var/actions = list("scratches", "baps", "slashes", "paws")
	var/sound_attack = 'sound/impact_sounds/Flesh_Tear_3.ogg'
	var/dmg_type = DAMAGE_BLUNT
	var/custom_msg = null
	var/stam_damage_mult = 0.1

	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return
		if(check_target_immunity( target ))
			return
		if (!istype(user))
			target.Attackhand(user, params, location, control)
			return
		if (isobj(target))
			if (isitem(target))
				var/obj/item/O = target
				var/can_pickup = 1

				if (issmallanimal(user))
					var/mob/living/critter/small_animal/C = user
					if (C.ghost_spawned && HAS_FLAG(O.object_flags, NO_GHOSTCRITTER))
						can_pickup = 0

				if (O.w_class > max_wclass || !can_pickup)
					user.visible_message("<span class='alert'><b>[user] struggles, failing to lift [target] off the ground!</b></span>", "<span class='alert'><b>You struggle with [target], but it's too big for you to lift!</b></span>")
					return
			else
				if (issmallanimal(user))
					var/mob/living/critter/small_animal/C = user
					var/obj/O = target
					if (C.ghost_spawned && HAS_FLAG(O.object_flags, NO_GHOSTCRITTER))
						user.show_text("<span class='alert'><b>You try to use [target], but this is way too complicated for your spectral brain to comprehend!</b></span>")
						return


		..()
		return

	help(mob/target, var/mob/living/user)
		if (issmallanimal(user) && iscarbon(target))
			user.lastattacked = target
			var/mob/living/critter/small_animal/C = user
			if (C.ghost_spawned)
				if (max_wclass < 3)
					user.visible_message("<span class='alert'><b>[user] tries to help [target], but they're worse than useless!</b></span>", "<span class='alert'><b>You try to help [target], but your spectral will can only manage a poke!</b></span>")
					playsound(user.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 25, 1, -1)
					return
		..()

	//yeah they're not ACTUALLY biting them but let's just assume that they are because i don't want a mouse or a dog to KO someone with a brutal right hook
	// changed to scratching, small mouths will take care of biting
	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if(check_target_immunity( target ))
			return 0
		if (isghostcritter(user) && ishuman(target) && target.health < 75)
			boutput(user, "Your spectral conscience refuses to damage this human any further.")
			return 0
		var/quality = src.holder.quality
		if (no_logs != 1)
			logTheThing(LOG_COMBAT, user, "attacks [constructTarget(target,"combat")] with a critter arm at [log_loc(user)].")
		
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, dam_low, dam_high, rand(dam_low, dam_high) * quality, stam_damage_mult, !isghostcritter(user))
		user.attack_effects(target, user.zone_sel?.selecting)
		msgs.base_attack_message = src.custom_msg ? src.custom_msg : "<b><span class='alert'>[user] [pick(src.actions)] [target]!</span></b>"
		if (src.sound_attack)
			msgs.played_sound = src.sound_attack
		msgs.damage_type = src.dmg_type
		msgs.flush(SUPPRESS_LOGS)

		user.lastattacked = target
		attack_particle(user,target)
		if (src != target)
			attack_twitch(src)

	grab(mob/target, var/mob/living/user)
		if (issmallanimal(user))
			user.lastattacked = target
			var/mob/living/critter/small_animal/C = user
			if (C.ghost_spawned)
				if (max_wclass < 3)
					user.visible_message("<span class='alert'><b>[user] tries to grab [target], but they are too large!</b></span>", "<span class='alert'><b>You try to grab [target], but your spectral will is not strong enough!</b></span>")
					return
		..()

	disarm(mob/target, var/mob/living/user)
		if (issmallanimal(user) && iscarbon(target))
			user.lastattacked = target
			var/mob/living/critter/small_animal/C = user
			if (C.ghost_spawned)
				if (max_wclass < 3)
					user.visible_message("<span class='alert'><b>[user] tries to disarm [target], but can only manage a pathetic nudge!</b></span>", "<span class='alert'><b>You try to disarm [target], but your spectral will can only manage a pathetic nudge!</b></span>")
					var/target_stamina = target.get_stamina()
					if (target_stamina && target_stamina > 5)
						target.remove_stamina(rand(1,4))
					playsound(user.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 25, 1, -1)
					return
		..()

/datum/limb/small_critter/med //same as the previous, but can pick up some heavier shit
	max_wclass = W_CLASS_SMALL
	stam_damage_mult = 0.5

/datum/limb/small_critter/strong
	max_wclass = W_CLASS_NORMAL
	stam_damage_mult = 1

/datum/limb/small_critter/pincers
	dmg_type = DAMAGE_STAB
	max_wclass = W_CLASS_SMALL
	stam_damage_mult = 0.5
	dam_low = 2
	dam_high = 4
	sound_attack = 'sound/items/Wirecutter.ogg'
	actions = list("snips", "pinches", "slashes")

/datum/limb/small_critter/possum
	dam_low = 0
	dam_high = 0

/datum/limb/small_critter/med/dash
	New(var/obj/item/parts/holder)
		..()
		src.setDisarmSpecial (/datum/item_special/katana_dash/limb)
		src.setHarmSpecial (/datum/item_special/katana_dash/limb)


	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return
		if(check_target_immunity( target ))
			return
		//var/quality = src.holder.quality

		if (!istype(user))
			target.Attackhand(user, params, location, control)
			return
		..()

	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if(check_target_immunity( target ))
			return 0
		if (istype(target,/mob/living/critter/small_animal/trilobite/ai_controlled))
			return 0
		var/quality = src.holder.quality
		if (no_logs != 1)
			logTheThing(LOG_COMBAT, user, "slashes [constructTarget(target,"combat")] with dash arms at [log_loc(user)].")
		//	var/mob/living/L = target
		//	L.do_disorient(24, 1 SECOND, 0, 0, 0.5 SECONDS)

		
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 1, 5, rand(0,2) * quality, can_punch = 0, can_kick = 0)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("cut", "rip", "claw", "slashe")
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target]!</span></b>"
		msgs.played_sound = 'sound/impact_sounds/Flesh_Tear_3.ogg'
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = target


//test for crab attack thing
/datum/limb/swipe_quake
	New(var/obj/item/parts/holder)
		..()
		src.setDisarmSpecial (/datum/item_special/slam/no_item_attack)
		src.setHarmSpecial (/datum/item_special/swipe/limb)

//I wanted a claw-like limb but without the random item pickup fail
/datum/limb/tentacle
	harm(mob/target, var/mob/living/user)
		if(check_target_immunity( target ))
			return FALSE
		logTheThing(LOG_COMBAT, user, "mauls [constructTarget(target,"combat")] with [src] at [log_loc(user)].")
		
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 6, 8, rand(3, 5), can_punch = FALSE, can_kick = FALSE)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("maim", "maul", "mangle", "slap", "lacerate", "mutilate")
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target] with [src.holder]!</span></b>"
		msgs.played_sound = 'sound/impact_sounds/Flesh_Tear_3.ogg'
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = target
