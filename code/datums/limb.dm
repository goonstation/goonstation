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


	New(var/obj/item/parts/holder)
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

		target.attack_hand(user, params, location, control)

	proc/harm(mob/living/target, var/mob/living/user)
		if (special_next)
			if(!user || !target)
				return 0
			if (!target.melee_attack_test(user))
				return

			var/obj/item/affecting = target.get_affecting(user)
			var/datum/attackResults/msgs = user.calculate_melee_attack(target, affecting, 2, 9, 0, 0.7, 0) // 0.7x stamina damage. No crits.
			msgs.damage_type = DAMAGE_BLUNT
			user.attack_effects(target, affecting)
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
		if (issilicon(target))
			return
		user.grab_other(target)
		user.lastattacked = target

	//calls attack specials if we got em
	//Ok look i know this isn't a true pixelaction() but it fits into the itemspecial call so i'm doin it
	proc/attack_range(atom/target, var/mob/user, params)
		if(user.a_intent == "disarm")
			if(disarm_special)
				for (var/obj/item/cloaking_device/I in user)
					if (I.active)
						I.deactivate(user)
						user.visible_message("<span class='notice'><b>[user]'s cloak is disrupted!</b></span>")
				disarm_special.pixelaction(target,params,user)
				.= 1
		else if (user.a_intent == "harm")
			if(harm_special)
				for (var/obj/item/cloaking_device/I in user)
					if (I.active)
						I.deactivate(user)
						user.visible_message("<span class='notice'><b>[user]'s cloak is disrupted!</b></span>")
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
		playsound(user.loc, "sound/weapons/lasermed.ogg", 100, 1)
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

		playsound(user, "sound/effects/mag_warp.ogg", 50, 1)
		SPAWN_DBG(rand(1,3)) // so it might miss, sometimes, maybe
			var/obj/target_r = new/obj/railgun_trg_dummy(target)

			playsound(user, "sound/weapons/railgun.ogg", 50, 1)
			user.dir = get_dir(user, target)

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
				for(var/obj/machinery/colosseum_putt/A in src_turf)
					if (A == O || A == user) continue
					A.meteorhit(O)

			sleep(0.3 SECONDS)
			for (var/obj/O in affected)
				pool(O)

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
		arcFlashTurf(user, get_turf(target), 15000)

/datum/limb/gun
	var/datum/projectile/proj = null
	var/cooldown = 30
	var/reload_time = 200
	var/shots = 4
	var/current_shots = 0
	var/reloading_str = "reloading"
	var/reloaded_at = 0
	var/next_shot_at = 0
	var/image/default_obscurer

	attack_range(atom/target, var/mob/user, params)
		if (reloaded_at > ticker.round_elapsed_ticks && !current_shots)
			boutput(user, "<span class='alert'>The [holder.name] is [reloading_str]!</span>")
			return
		else if (current_shots <= 0)
			current_shots = shots
		if (next_shot_at > ticker.round_elapsed_ticks)
			return
		if (current_shots > 0)
			current_shots--
			var/pox = text2num(params["icon-x"]) - 16
			var/poy = text2num(params["icon-y"]) - 16
			shoot_projectile_ST_pixel(user, proj, target, pox, poy)
			user.visible_message("<b class='alert'>[user] fires at [target] with the [holder.name]!</b>")
			next_shot_at = ticker.round_elapsed_ticks + cooldown
			if (!current_shots)
				reloaded_at = ticker.round_elapsed_ticks + reload_time
		else
			reloaded_at = ticker.round_elapsed_ticks + reload_time

	is_on_cooldown()
		if (ticker.round_elapsed_ticks < reloaded_at)
			return reloaded_at - ticker.round_elapsed_ticks
		return 0

	arm38
		proj = new/datum/projectile/bullet/revolver_38
		shots = 3
		current_shots = 3
		cooldown = 30
		reload_time = 200

	abg
		proj = new/datum/projectile/bullet/abg
		shots = 6
		current_shots = 6
		cooldown = 30
		reload_time = 300

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

	artillery
		proj = new/datum/projectile/bullet/autocannon
		shots = 1
		current_shots = 1
		cooldown = 50
		reload_time = 50

	disruptor
		proj = new/datum/projectile/disruptor/high
		shots = 1
		current_shots = 1
		cooldown = 40
		reload_time = 40

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

	minigun
		proj = new/datum/projectile/energybolt/reliquary_burst
		shots = 1
		current_shots = 1
		cooldown = 4
		reload_time = 4

		attack_range(atom/target, var/mob/user, params)
			if (reloaded_at > ticker.round_elapsed_ticks && !current_shots)
				boutput(user, "<span class='alert'>The [holder.name] is [reloading_str]!</span>")
				return
			else if (current_shots <= 0)
				current_shots = shots
			if (next_shot_at > ticker.round_elapsed_ticks)
				return
			if (current_shots > 0)
				current_shots--
				var/pox = text2num(params["icon-x"]) - 16
				var/poy = text2num(params["icon-y"]) - 16
				var/spread_angle = 15
				playsound(user.loc, "sound/misc/reliquary/Rel-vortex-firing.ogg", 70, 1)
				flick("guardian_gunlift", user)
				user.visible_message("<b class='alert'>[user] fires at [target] with the [holder.name]!</b>")
				next_shot_at = ticker.round_elapsed_ticks + cooldown
				SPAWN_DBG (3)
					shoot_projectile_ST_pixel_spread(user, proj, target, pox, poy, spread_angle)
				if (!current_shots)
					reloaded_at = ticker.round_elapsed_ticks + reload_time
			else
				reloaded_at = ticker.round_elapsed_ticks + reload_time

	spike
		proj = new/datum/projectile/special/spreader/uniform_burst/spikes
		shots = 1
		current_shots = 1
		cooldown = 1 SECOND
		reload_time = 1 SECOND

/datum/limb/mouth
	var/sound_attack = "sound/weapons/werewolf_attack1.ogg"
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
				potentially_food.Eat(user, user, 1)

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

		if (prob(src.miss_prob) || target.getStatusDuration("stunned") || target.getStatusDuration("weakened") || target.getStatusDuration("paralysis") || target.stat || target.restrained())
			var/obj/item/affecting = target.get_affecting(user)
			var/datum/attackResults/msgs = user.calculate_melee_attack(target, affecting, dam_low, dam_high, 0, stam_damage_mult, !isghostcritter(user))
			user.attack_effects(target, affecting)
			msgs.base_attack_message = src.custom_msg ? src.custom_msg : "<b><span class='combat'>[user] bites [target]!</span></b>"
			msgs.played_sound = src.sound_attack
			msgs.flush(0)
			user.HealDamage("All", 2, 0)
		else
			user.visible_message("<b><span class='combat'>[user] attempts to bite [target] but misses!</span></b>")
		user.lastattacked = target

/datum/limb/mouth/small // for cats/mice/etc
	sound_attack = "sound/impact_sounds/Flesh_Tear_1.ogg"
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
	attack_hand(atom/target, var/mob/user, var/reach, params, location, control)
		if (holder && holder.remove_object && istype(holder.remove_object))
			target.attackby(holder.remove_object, user, params, location, control)
			if (target)
				holder.remove_object.afterattack(target, src, reach)

/datum/limb/bear
	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return

		if (!istype(user))
			target.attack_hand(user, params, location, control)
			return

		if (ismob(target))
			..()
			return

		if (isobj(target))
			switch (user.smash_through(target, list("window", "grille")))
				if (0)
					if (isitem(target))
						boutput(user, "<span class='alert'>You try to pick [target] up but it wiggles out of your hand. Opposable thumbs would be nice.</span>")
						return
					else if (istype(target, /obj/machinery))
						boutput(user, "<span class='alert'>You're unlikely to be able to use [target]. You manage to scratch its surface though.</span>")
						return

				if (1)
					return

		..()
		return

	help(mob/target, var/mob/living/user)
		user.show_message("<span class='alert'>Nope. Not going to work. You're more likely to kill them.</span>")
		user.lastattacked = target

	disarm(mob/target, var/mob/living/user)
		logTheThing("combat", user, target, "mauls [constructTarget(target,"combat")] with bear limbs (disarm intent) at [log_loc(user)].")
		user.visible_message("<span class='alert'>[user] mauls [target] while trying to disarm them!</span>")
		harm(target, user, 1)

	grab(mob/target, var/mob/living/user)
		logTheThing("combat", user, target, "mauls [constructTarget(target,"combat")] with bear limbs (grab intent) at [log_loc(user)].")
		user.visible_message("<span class='alert'>[user] mauls [target] while trying to grab them!</span>")
		harm(target, user, 1)

	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if (no_logs != 1)
			logTheThing("combat", user, target, "mauls [constructTarget(target,"combat")] with bear limbs at [log_loc(user)].")
		var/obj/item/affecting = target.get_affecting(user)
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, affecting, 6, 10, 0)
		user.attack_effects(target, affecting)
		var/action = pick("maim", "maul", "mangle", "rip", "claw", "lacerate", "mutilate")
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target] with their [src.holder]!</span></b>"
		msgs.played_sound = "sound/impact_sounds/Flesh_Stab_1.ogg"
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		if (prob(60))
			target.changeStatus("weakened", 2 SECONDS)
		user.lastattacked = target

/datum/limb/dualsaw

	attack_hand(atom/target, var/mob/living/user, var/reach)
		if (!holder)
			return

		if (!istype(user))
			target.attack_hand(user)
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
		logTheThing("combat", user, target, "slashes [constructTarget(target,"combat")] with dual saw (disarm intent) at [log_loc(user)].")
		user.visible_message("<span class='alert'>[user] slashes [target] while trying to disarm them!</span>")
		harm(target, user, 1)

	grab(mob/target, var/mob/living/user)
		logTheThing("combat", user, target, "slashes [constructTarget(target,"combat")] with dual saw (grab intent) at [log_loc(user)].")
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
			logTheThing("combat", user, target, "slashes [constructTarget(target,"combat")] with dual saw at [log_loc(user)].")
		var/obj/item/affecting = target.get_affecting(user)
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, affecting, 6, 10, 0)
		user.attack_effects(target, affecting)
		var/action = pick("lacerate", "carve", "mangle", "sever", "hack", "slice", "mutilate")
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target] with their [src.holder]!</span></b>"
		msgs.played_sound = "sound/effects/sawhit.ogg"
		boutput(target, "<span class='alert'>You can feel the saw slicing your body apart!</span>")
		target.emote("scream")
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		if (prob(60))
			target.changeStatus("weakened",20)
		user.lastattacked = target

/datum/limb/wendigo
	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return
		if(check_target_immunity( target ))
			return
		var/quality = src.holder.quality

		if (!istype(user))
			target.attack_hand(user, params, location, control)
			return

		if (isobj(target))
			switch (user.smash_through(target, list("window", "grille", "door")))
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
					return

		..()
		return

	proc/accident(mob/target, mob/living/user)
		if(check_target_immunity( target ))
			return 0
		if (prob(25))
			logTheThing("combat", user, target, "accidentally harms [constructTarget(target,"combat")] with wendigo limbs at [log_loc(user)].")
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
			logTheThing("combat", user, target, "mauls [constructTarget(target,"combat")] with wendigo limbs at [log_loc(user)].")
		var/obj/item/affecting = target.get_affecting(user)
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, affecting, 6, 9, rand(5,9) * quality)
		user.attack_effects(target, affecting)
		var/action = pick("maim", "maul", "mangle", "rip", "claw", "lacerate", "mutilate")
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target] with their [src.holder]!</span></b>"
		msgs.played_sound = "sound/impact_sounds/Flesh_Stab_1.ogg"
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		if (prob(35 * quality))
			target.changeStatus("weakened", (4 * quality)*10)
		user.lastattacked = target

#if ASS_JAM
/datum/limb/hot //because
	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return
		if(check_target_immunity( target ))
			return


		if (!istype(user))
			target.attack_hand(user, params, location, control)
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
			logTheThing("combat", user, target, "accidentally harms [constructTarget(target,"combat")] with hot hands at [log_loc(user)].")
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
			logTheThing("combat", user, target, "melts [constructTarget(target,"combat")] with hot hands at [log_loc(user)].")
		var/obj/item/affecting = target.get_affecting(user)
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, affecting, 1, 3, 1, 0, 0)
		user.attack_effects(target, affecting)

		msgs.base_attack_message = "<b><span class='alert'>[user] melts [target] with their clutch!</span></b>"
		msgs.played_sound = "sound/impact_sounds/burn_sizzle.ogg"
		msgs.damage_type = DAMAGE_BURN
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = target


#endif
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
			target.attack_hand(user, params, location, control)
			return

		if (istype(target, /obj/critter))
			user.lastattacked = target

			var/obj/critter/victim = target

			if (src.weak == 1)
				SPAWN_DBG (0)
					step_away(victim, user, 15)

				playsound(user.loc, pick('sound/voice/animal/werewolf_attack1.ogg', 'sound/voice/animal/werewolf_attack2.ogg', 'sound/voice/animal/werewolf_attack3.ogg'), 50, 1)
				SPAWN_DBG (1)
					if (user) playsound(user.loc, "sound/impact_sounds/Flesh_Tear_3.ogg", 40, 1, -1)

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

			if (victim && victim.alive && victim.health <= 0)
				victim.CritterDeath()
			return

		if (isobj(target))
			switch (user.smash_through(target, list("window", "grille", "door")))
				if (0)
					target.attack_hand(user, params, location, control)
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
			target.attack_hand(user)
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
			GD.state = GRAB_AGGRESSIVE
			GD.update_icon()
			user.visible_message("<span class='alert'>[user] grabs hold of [target] aggressively!</span>")

		return

	disarm(mob/target, var/mob/living/user)
		if (!holder)
			return

		if (!istype(user) || !ismob(target))
			target.attack_hand(user)
			return

		if(check_target_immunity( target ))
			return 0

		if (target.melee_attack_test(user, null, null, 1) != 1) // Target.lying check is in there.
			return

		if (issilicon(target))
			special_attack_silicon(target, user)
			return

		var/send_flying = 0 // 1: a little bit | 2: across the room
		var/obj/item/affecting = target.get_affecting(user)
		var/datum/attackResults/disarm/msgs = user.calculate_disarm_attack(target, affecting)

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

		logTheThing("combat", user, target, "diarms [constructTarget(target,"combat")] with [src.weak == 1 ? "werewolf" : "abomination"] arms at [log_loc(user)].")

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
			target.attack_hand(user)
			return
		if(check_target_immunity( target ))
			return 0
		if (target.melee_attack_test(user) != 1)
			return

		if (issilicon(target))
			special_attack_silicon(target, user)
			return

		var/send_flying = 0 // 1: a little bit | 2: across the room
		var/obj/item/affecting = target.get_affecting(user)
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, affecting)

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

			msgs.played_sound = 'sound/impact_sounds/Generic_Punch_2.ogg'
			msgs.damage = rand(6, 13)
			msgs.damage_type = DAMAGE_BLUNT

		if (send_flying == 2)
			msgs.after_effects += /proc/wrestler_backfist
		else if (send_flying == 1)
			msgs.after_effects += /proc/wrestler_knockdown

		logTheThing("combat", user, target, "punches [constructTarget(target,"combat")] with [src.weak == 1 ? "werewolf" : "abomination"] arms at [log_loc(user)].")
		user.attack_effects(target, affecting)
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
			target.attack_hand(user, params, location, control)
			return

		if (isobj(target))
			switch (user.smash_through(target, list("door")))
				if (0)
					target.attack_hand(user, params, location, control)
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
			target.attack_hand(user)
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
			target.attack_hand(user, params, location, control)
			return

		if (isobj(target))
			switch (user.smash_through(target, list("grille")))
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
					return
		..()
		return

	proc/accident(mob/target, mob/living/user)
		if(check_target_immunity( target ))
			return 0
		if (prob(25))
			logTheThing("combat", user, target, "accidentally harms [constructTarget(target,"combat")] with claw arms at [log_loc(user)].")
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
			logTheThing("combat", user, target, "claws [constructTarget(target,"combat")] with claw arms at [log_loc(user)].")
		var/obj/item/affecting = target.get_affecting(user)
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, affecting, 2, 7, rand(1,3) * quality)
		user.attack_effects(target, affecting)
		var/action = pick("maim", "stab", "rip", "claw", "slashe")
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target] with their [src.holder]!</span></b>"
		msgs.played_sound = "sound/impact_sounds/Flesh_Tear_3.ogg"
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = target

/datum/limb/leg_hand
	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return
		if(check_target_immunity( target ))
			return

		if (!istype(user))
			target.attack_hand(user, params, location, control)
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
			logTheThing("combat", user, target, "kicks [constructTarget(target,"combat")] at [log_loc(user)].")
		var/obj/item/affecting = target.get_affecting(user)
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, affecting, 1, 4, rand(1,3) * quality)
		user.attack_effects(target, affecting)
		var/action = pick("kick", "stomp", "boot")
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target]!</span></b>"
		msgs.played_sound = 'sound/impact_sounds/Generic_Hit_1.ogg'
		msgs.damage_type = DAMAGE_BLUNT
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = target


//hey maybe later standardize this into flags per obj so we dont search this huge list every click ok??
var/list/ghostcritter_blocked = ghostcritter_blocked_objects()

/proc/ghostcritter_blocked_objects() // Generates an associate list of (type = 1) that can be checked much faster than looping istypes
	var/blocked_types = list(/obj/item/device/flash,\
	/obj/item/reagent_containers/glass/beaker,\
	/obj/item/reagent_containers/glass/bottle,\
	/obj/item/scalpel,\
	/obj/item/circular_saw,\
	/obj/item/staple_gun,\
	/obj/item/scissors,\
	/obj/item/razor_blade,\
	/obj/item/raw_material/shard,\
	/obj/item/kitchen/utensil/knife,\
	/obj/item/reagent_containers/food/snacks/prison_loaf,\
	/obj/item/reagent_containers/food/snacks/einstein_loaf,\
	/obj/reagent_dispensers,\
	/obj/machinery/chem_dispenser,\
	/obj/machinery/portable_atmospherics/canister,\
	/obj/machinery/networked/teleconsole,\
	/obj/storage/crate, /obj/storage/closet,\
	/obj/storage/secure/closet,\
	/obj/machinery/firealarm,\
	/obj/machinery/weapon_stand,\
	/obj/dummy/chameleon,\
	/obj/machinery/light,\
	/obj/machinery/vending,\
	/obj/machinery/nuclearbomb,\
	/obj/item/gun/kinetic/airzooka,\
	/obj/machinery/computer,\
	/obj/machinery/power/smes,
	/obj/item/tinyhammer) //Items that ghostcritters simply cannot interact, regardless of w_class
	. = list()
	for (var/blocked_type in blocked_types)
		for (var/subtype in typesof(blocked_type))
			.[subtype] = 1

//little critters with teeth, like mice! can pick up small items only.
/datum/limb/small_critter
	var/max_wclass = 1 // biggest thing we can carry
	var/dam_low = 1
	var/dam_high = 1
	var/actions = list("scratches", "baps", "slashes", "paws")
	var/sound_attack = "sound/impact_sounds/Flesh_Tear_3.ogg"
	var/dmg_type = DAMAGE_BLUNT
	var/custom_msg = null
	var/stam_damage_mult = 0.1

	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return
		if(check_target_immunity( target ))
			return
		if (!istype(user))
			target.attack_hand(user, params, location, control)
			return
		if (isobj(target))
			if (isitem(target))
				var/obj/item/O = target
				var/can_pickup = 1

				if (issmallanimal(usr))
					var/mob/living/critter/small_animal/C = usr
					if (C.ghost_spawned && ghostcritter_blocked[O.type])
						can_pickup = 0

				if (O.w_class > max_wclass || !can_pickup)
					user.visible_message("<span class='alert'><b>[user] struggles, failing to lift [target] off the ground!</b></span>", "<span class='alert'><b>You struggle with [target], but it's too big for you to lift!</b></span>")
					return
			else
				if (issmallanimal(user))
					var/mob/living/critter/small_animal/C = user
					if (C.ghost_spawned && ghostcritter_blocked[target.type])
						user.show_text("<span class='alert'><b>You try to use [target], but this is way too complicated for your spectral brain to comprehend!</b></span>")
						return


		..()
		return

	help(mob/target, var/mob/living/user)
		if (issmallanimal(usr) && iscarbon(target))
			user.lastattacked = target
			var/mob/living/critter/small_animal/C = usr
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
			logTheThing("combat", user, target, "attacks [constructTarget(target,"combat")] with a critter arm at [log_loc(user)].")
		var/obj/item/affecting = target.get_affecting(user)
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, affecting, dam_low, dam_high, rand(dam_low, dam_high) * quality, stam_damage_mult, !isghostcritter(user))
		user.attack_effects(target, affecting)
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
		if (issmallanimal(usr) && iscarbon(target))
			user.lastattacked = target
			var/mob/living/critter/small_animal/C = usr
			if (C.ghost_spawned)
				if (max_wclass < 3)
					user.visible_message("<span class='alert'><b>[user] tries to grab [target], but they are too large!</b></span>", "<span class='alert'><b>You try to grab [target], but your spectral will is not strong enough!</b></span>")
					return
		..()

	disarm(mob/target, var/mob/living/user)
		if (issmallanimal(usr) && iscarbon(target))
			user.lastattacked = target
			var/mob/living/critter/small_animal/C = usr
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
	max_wclass = 2
	stam_damage_mult = 0.5

/datum/limb/small_critter/strong
	max_wclass = 3
	stam_damage_mult = 1

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
			target.attack_hand(user, params, location, control)
			return
		..()

	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if(check_target_immunity( target ))
			return 0
		if (istype(target,/mob/living/critter/small_animal/trilobite/ai_controlled))
			return 0
		var/quality = src.holder.quality
		if (no_logs != 1)
			logTheThing("combat", user, target, "slashes [constructTarget(target,"combat")] with dash arms at [log_loc(user)].")
		//	var/mob/living/L = target
		//	L.do_disorient(24, 1 SECOND, 0, 0, 0.5 SECONDS)

		var/obj/item/affecting = target.get_affecting(user)
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, affecting, 1, 5, rand(0,2) * quality)
		user.attack_effects(target, affecting)
		var/action = pick("cut", "rip", "claw", "slashe")
		msgs.base_attack_message = "<b><span class='alert'>[user] [action]s [target]!</span></b>"
		msgs.played_sound = "sound/impact_sounds/Flesh_Tear_3.ogg"
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = target


//test for crab attack thing
/datum/limb/swipe_quake
	New(var/obj/item/parts/holder)
		..()
		src.setDisarmSpecial (/datum/item_special/slam/no_item_attack)
		src.setHarmSpecial (/datum/item_special/swipe/limb)

/datum/limb/reliquary_guardian_melee
	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return

		if(check_target_immunity( target ))
			return 0

		if (!istype(user))
			target.attack_hand(user, params, location, control)
			return

		if (istype(target, /obj/critter))
			user.lastattacked = target
			var/obj/critter/victim = target
			var/turf/T = get_edge_target_turf(user, user.dir)
			if (prob(66) && T && isturf(T))
				user.visible_message("<span class='alert'><B>[user] savagely punches [victim], sending them flying!</B></span>")
				victim.health -= 6 * victim.brutevuln
				victim.throw_at(T, 10, 2)
			else
				user.visible_message("<span class='alert'><B>[user] punches [victim]!</span>")
				victim.health -= 4 * victim.brutevuln

				playsound(user.loc, "punch", 25, 1, -1)

			if (victim && victim.alive && victim.health <= 0)
				victim.CritterDeath()
			return

		if (isobj(target))
			switch (user.smash_through(target, list("window", "grille", "door")))
				if (0)
					target.attack_hand(user, params, location, control)
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
			target.attack_hand(user)
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
			GD.state = GRAB_AGGRESSIVE
			GD.update_icon()
			user.visible_message("<span class='alert'>[user] grabs hold of [target] aggressively!</span>")

		return

	disarm(mob/target, var/mob/living/user)
		if (!holder)
			return

		if (!istype(user) || !ismob(target))
			target.attack_hand(user)
			return

		if(check_target_immunity( target ))
			return 0

		if (target.melee_attack_test(user, null, null, 1) != 1) // Target.lying check is in there.
			return

		if (issilicon(target))
			special_attack_silicon(target, user)
			return

		var/send_flying = 2 // 1: a little bit | 2: across the room
		var/obj/item/affecting = target.get_affecting(user)
		var/datum/attackResults/disarm/msgs = user.calculate_disarm_attack(target, affecting)

		if (!msgs || !istype(msgs))
			return

		user.lastattacked = target

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
				msgs.base_attack_message = "<span class='alert'><B>[user] slams [HH] with the edge of their enormous claw, shearing off their [limb_name]!</span>"
				msgs.damage_type = DAMAGE_CUT // We just lost a limb.

				msgs.damage = rand(1,5)
				HH.changeStatus("stunned", 2 SECONDS)

			else
				if (!target.anchored && prob(30))
					send_flying = 1
				else
					target.drop_item() // Shamblers get a guaranteed disarm.

				msgs.played_sound = 'sound/impact_sounds/Generic_Shove_1.ogg'
				msgs.base_attack_message = "<span class='alert'><B>[user] shoves [target] with a [pick("powerful", "fearsome", "intimidating", "strong")] attack[send_flying == 0 ? "" : ", forcing them to the ground"]!</B></span>"
				msgs.damage = rand(1,2)

		logTheThing("combat", user, target, "disarms [constructTarget(target,"combat")] with Reliquary Guardian Fist at [log_loc(user)].")

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
			target.attack_hand(user)
			return
		if(check_target_immunity( target ))
			return 0
		if (target.melee_attack_test(user) != 1)
			return

		if (issilicon(target))
			special_attack_silicon(target, user)
			return

		var/send_flying = 2 // 1: a little bit | 2: across the room
		var/obj/item/affecting = target.get_affecting(user)
		var/datum/attackResults/msgs = user.calculate_melee_attack(target, affecting)

		if (!msgs || !istype(msgs))
			return

		if (target.canmove && !target.anchored && !target.lying)
			if (prob(50))
				if (prob(60))
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

		if (send_flying == 2)
			msgs.base_attack_message = "<span class='alert'><B>[user] punches [target] with their[pick("enormous", "giant", "gargantuan", "strong")] steel fist[send_flying == 0 ? "" : ", forcing them to the ground"]!</B></span>"
		else
			msgs.base_attack_message = "<span class='alert'><B>[user] punches [target] with their[pick("enormous", "giant", "gargantuan", "strong")] steel fist[send_flying == 0 ? "" : ", forcing them to the ground"]!</B></span>"

			msgs.played_sound = 'sound/impact_sounds/Generic_Punch_2.ogg'
			msgs.damage = rand(6, 13)
			msgs.damage_type = DAMAGE_BLUNT

		if (send_flying == 2)
			msgs.after_effects += /proc/wrestler_backfist
		else if (send_flying == 1)
			msgs.after_effects += /proc/wrestler_knockdown

		logTheThing("combat", user, target, "punches [constructTarget(target,"combat")] with Reliquary Guardian Fist at [log_loc(user)].")
		user.attack_effects(target, affecting)
		msgs.flush(SUPPRESS_LOGS)

		user.lastattacked = target
		return
