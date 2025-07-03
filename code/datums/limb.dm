/**
 * Limb datums for arms. Describes all activity performed by the limb.
 * Currently, this is basically attack_hand().
 *
 * Also serves as a future holder for any other special limb activity.
 */

/datum/limb
	var/obj/item/parts/holder = null
	/// used for ON_COOLDOWN stuff
	var/cooldowns
	/// this limb's click usage is limited by lastattacked. set to false for custom cooldowns.
	var/use_lastattacked_click_delay = TRUE
	var/special_next = 0
	/// Contains the datum which executes the items special, if it has one, when used beyond melee range.
	var/datum/item_special/disarm_special = null
	/// Contains the datum which executes the items special, if it has one, when used beyond melee range.
	var/datum/item_special/harm_special = null
	var/can_pickup_item = TRUE
	/// scale from 0 to 1 on how well this limb can attack/hit things with items
	var/attack_strength_modifier = 1
	/// if the limb can gun grab with a held gun
	var/can_gun_grab = TRUE
	/// if true, bypasses unarmed attack immunity for cyborgs (separate to weird special case handling for them)
	var/can_beat_up_robots = FALSE
	/// Bypass to allow special attacks to work on help/grab intent, kind of dumb but necessary
	var/use_specials_on_all_intents = FALSE
	/// Exemptions on what it can used/help by the limb
	var/list/interact_exemptions = list()
	var/exempt = FALSE // For specific items which are heavier yet carriable, has to be here cause of critter.dm checks

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

	proc/attack_self(mob/user)
		return

	proc/harm(mob/living/target, var/mob/living/user)
		if (special_next)
			if(!user || !target)
				return 0
			if (!target.melee_attack_test(user))
				return


			var/datum/attackResults/msgs = user.calculate_melee_attack(target, 2, 9, 0, 0.7, 0) // 0.7x stamina damage. No crits.
			if (msgs)
				msgs.damage_type = DAMAGE_BLUNT
				user.attack_effects(target, user.zone_sel?.selecting)
				msgs.flush(0)

			special_next = 0
		else
			user.melee_attack_normal(target, 0, 0, DAMAGE_BLUNT)
		ON_COOLDOWN(src, "limb_cooldown", COMBAT_CLICK_DELAY)

	proc/help(mob/living/target, var/mob/living/user)
		user.do_help(target)

	proc/disarm(mob/living/target, var/mob/living/user)
		if (special_next)
			src.shove(target,user)
			special_next = 0
		else
			user.disarm(target)
		ON_COOLDOWN(src, "limb_cooldown", COMBAT_CLICK_DELAY)

	proc/grab(mob/living/target, var/mob/living/user)
		if(target == user)
			user.grab_self()
			return
		if (issilicon(target))
			return
		user.grab_other(target)
		ON_COOLDOWN(src, "limb_cooldown", COMBAT_CLICK_DELAY)

	//calls attack specials if we got em
	//Ok look i know this isn't a true pixelaction() but it fits into the itemspecial call so i'm doin it
	proc/attack_range(atom/target, var/mob/user, params)
		if(user.a_intent == "disarm")
			if(disarm_special)
				SEND_SIGNAL(user, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)
				disarm_special.pixelaction(target,params,user)
				return TRUE
		else if (user.a_intent == "harm")
			if(harm_special)
				for (var/obj/item/cloaking_device/I in user)
					SEND_SIGNAL(user, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)
				harm_special.pixelaction(target,params,user)
				return TRUE
		else
			return FALSE

	proc/is_on_cooldown()
		return GET_COOLDOWN(src, "limb_cooldown")

	//alt version of disarm that shoves the target away from the user instead of trying to slap item out of hand
	proc/shove(mob/living/target, var/mob/living/user)
		user.disarm(target,0,0,DAMAGE_BLUNT,1)
		special_next = 0

/datum/limb/hitscan
	var/brute = 5
	var/burn = 0
	var/image/default_obscurer

	attack_range(atom/target, var/mob/user, params)
		user.visible_message("<b class='alert'>[user] fires at [target] with the [holder.name]!</b>")
		playsound(user.loc, 'sound/weapons/lasermed.ogg', 100, 1)
		if (ismob(target))
			var/mob/MT = target
			if (prob(30))
				user.visible_message(SPAN_ALERT("The shot misses!"))
			else
				MT.TakeDamageAccountArmor(user.zone_sel ? user.zone_sel.selecting : "All", brute, burn, 0, burn ? DAMAGE_BURN : DAMAGE_BLUNT)
		elecflash(target.loc,power = 2)
		ON_COOLDOWN(src, "limb_cooldown", 3 SECONDS)


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

		playsound(user, 'sound/effects/mag_warp.ogg', 50, TRUE)
		SPAWN(rand(1,3)) // so it might miss, sometimes, maybe
			var/obj/target_r = new/obj/railgun_trg_dummy(target)

			playsound(user, 'sound/weapons/railgun.ogg', 50, TRUE)
			user.set_dir(get_dir(user, target))

			var/list/affected = drawLineObj(user, target_r, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeRailG",1,1,"HalfStartRailG","HalfEndRailG",OBJ_LAYER,1)

			for(var/obj/O in affected)
				O.anchored = ANCHORED //Proc wont spawn the right object type so lets do that here.
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
	var/spread_angle = 8
	var/reloading_str = "reloading"
	var/image/default_obscurer
	var/muzzle_flash = null
	can_beat_up_robots = TRUE //so pointblanking works

	attack_range(atom/target, var/mob/user, params)
		src.shoot(target, user, FALSE, params)

	proc/point_blank(atom/target, var/mob/user)
		src.shoot(target, user, TRUE)

	proc/shoot(atom/target, var/mob/user, var/pointblank = FALSE, params)
		if (GET_COOLDOWN(src, "[src] reload") && !current_shots)
			boutput(user, SPAN_ALERT("The [holder.name] is [reloading_str]!"))
			return
		else if (current_shots <= 0)
			current_shots = shots
		if (current_shots > 0)
			if (ON_COOLDOWN(src, "[src] shoot", src.cooldown))
				return
			. = TRUE
			current_shots--
			if (pointblank && ismob(target))
				src.shoot_pointblank(target, user)
			else
				src.shoot_range(target, user, params)
		if (current_shots <= 0)
			ON_COOLDOWN(src, "[src] reload", src.reload_time)

	proc/shoot_range(atom/target, var/mob/user, params)
		shoot_projectile_ST_pixel_spread(user, proj, target, spread_angle = src.spread_angle, alter_proj = new/datum/callback(src, PROC_REF(alter_projectile)))
		if (src.muzzle_flash)
			if (isturf(user.loc))
				var/turf/origin = user.loc
				muzzle_flash_attack_particle(user, origin, target, src.muzzle_flash)
		user.visible_message("<b class='alert'>[user] fires at [target] with the [holder.name]!</b>")

	proc/shoot_pointblank(atom/target, var/mob/user)
		for (var/i = 0; i < proj.shot_number; i++)
			var/obj/projectile/P = initialize_projectile_pixel_spread(user, proj, target, 0, 0, alter_proj = new/datum/callback(src, PROC_REF(alter_projectile)))
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

	proc/alter_projectile(var/obj/projectile/P)
		return

	attack_hand(atom/target, mob/user, var/reach, params, location, control)
		switch(user.a_intent) //we're a gun, so we don't want to do normal attack_hand stuff
			if (INTENT_DISARM)
				src.disarm(target, user)
			if (INTENT_HARM)
				src.harm(target, user)

	help(mob/living/target, mob/living/user)
		return

	disarm(mob/living/target, mob/living/user)
		src.point_blank(target, user)

	grab(mob/living/target, mob/living/user)
		return

	harm(mob/living/target, mob/living/user)
		src.point_blank(target, user)

	/// despite the name, this means reloading
	is_on_cooldown()
		return (GET_COOLDOWN(src, "[src] reload") || GET_COOLDOWN(src, "[src] shoot"))

/datum/limb/gun/kinetic
	// if firing this limb pushes you back in space
	var/has_space_pushback = TRUE

	shoot(atom/target, var/mob/user, var/pointblank = FALSE, params)
		if((..() && istype(user.loc, /turf/space) || user.no_gravity) && src.has_space_pushback)
			user.inertia_dir = get_dir_accurate(target, user)
			step(user, user.inertia_dir)

	arm38
		proj = new/datum/projectile/bullet/revolver_38
		shots = 3
		current_shots = 3
		cooldown = 3 SECONDS
		reload_time = 20 SECONDS
		muzzle_flash = "muzzle_flash"

		fast
			cooldown = 2 SECONDS
			reload_time = 8 SECONDS

	abg
		proj = new/datum/projectile/bullet/abg
		shots = 6
		current_shots = 6
		cooldown = 3 SECONDS
		reload_time = 30 SECONDS
		muzzle_flash = "muzzle_flash"

		no_reload
			reload_time = 0 SECONDS


	cannon
		proj = new /datum/projectile/bullet/cannon
		shots = 1
		current_shots = 1
		cooldown = 3 SECONDS
		reload_time = 20 SECONDS
		muzzle_flash = "muzzle_flash_launch"

	clock
		proj = new /datum/projectile/bullet/nine_mm_NATO/auto
		shots = 16
		current_shots = 16
		reload_time = 60 SECONDS

	smg
		proj = new/datum/projectile/bullet/bullet_9mm/smg
		shots = 2
		current_shots = 2
		cooldown = 3 SECONDS
		reload_time = 10 SECONDS
		muzzle_flash = "muzzle_flash"
		spread_angle = 15

	artillery
		proj = new/datum/projectile/special/spreader/uniform_burst/circle/airburst
		shots = 1
		current_shots = 1
		cooldown = 5 SECONDS
		reload_time = 5 SECONDS

	minigun
		proj = new/datum/projectile/bullet/minigun
		shots = 10
		current_shots = 10
		cooldown = 0.1 SECONDS
		reload_time = 10 SECONDS
		muzzle_flash = "muzzle_flash"

		New()
			. = ..()
			var/datum/projectile/bullet/B = proj
			B.shot_number = 10


	mrl
		proj = new /datum/projectile/bullet/homing/rocket/mrl
		shots = 6
		current_shots = 6
		cooldown = 3 SECONDS
		reload_time = 120 SECONDS
		muzzle_flash = "muzzle_flash"

	glitch
		proj = new/datum/projectile/bullet/glitch
		shots = 1
		current_shots = 1
		cooldown = 4 SECONDS
		reload_time = 4 SECONDS

	fire_elemental
		proj = new/datum/projectile/bullet/flare
		shots = 1
		current_shots = 1
		cooldown = 4 SECONDS
		reload_time = 4 SECONDS

	space_phoenix
		proj = new/datum/projectile/bullet/space_phoenix_icicle
		shots = INFINITY
		current_shots = 1
		cooldown = 1 SECOND
		reload_time = 0
		spread_angle = 2
		has_space_pushback = FALSE

	syringe
		proj = new/datum/projectile/syringefilled
		shots = 1
		current_shots = 1
		cooldown = 4 SECONDS
		reload_time = 30 SECONDS

	spike
		proj = new/datum/projectile/special/spreader/uniform_burst/spikes
		shots = 1
		current_shots = 1
		cooldown = 1 SECOND
		reload_time = 1 SECOND
		spread_angle = 0

	striker
		proj = new /datum/projectile/special/spreader/uniform_burst/bird12
		shots = 7
		current_shots = 7
		cooldown = 2 SECONDS
		reload_time = 15 SECONDS

	rifle
		proj = new/datum/projectile/bullet/assault_rifle
		shots = 5
		current_shots = 5
		cooldown = 1 SECOND
		reload_time = 20 SECONDS

	draco
		proj = new/datum/projectile/bullet/draco
		shots = 5
		current_shots = 5
		cooldown = 1 SECOND
		reload_time = 20 SECONDS

/datum/limb/gun/energy
	phaser
		proj = new/datum/projectile/laser/light
		shots = 1
		current_shots = 1
		cooldown = 3 SECONDS
		reload_time = 3 SECONDS

	cutter
		proj = new/datum/projectile/laser/drill/cutter
		shots = 1
		current_shots = 1
		cooldown = 3 SECONDS
		reload_time = 3 SECONDS
		spread_angle = 0

	disruptor
		proj = new/datum/projectile/disruptor/high
		shots = 1
		current_shots = 1
		cooldown = 4 SECONDS
		reload_time = 4 SECONDS

	martian_ray
		proj = new/datum/projectile/energy_bolt/raybeam
		shots = 3
		current_shots = 9
		cooldown = 1 SECONDS
		reload_time = 3 SECONDS
		spread_angle = 3


/datum/limb/gun/spawner
	proj = new/datum/projectile/special/spawner
	shots = 1
	current_shots = 1
	cooldown = 2 SECOND
	reload_time = 2 SECOND
	var/typetospawn = null
	var/damage_type = D_KINETIC
	var/hit_type = DAMAGE_BLUNT
	var/dissipation_rate = 0
	var/max_range = 10
	var/proj_name = "dimensional pocket"
	var/proj_shot_sound = 'sound/weapons/rocket.ogg'
	var/proj_hit_sound = null
	var/proj_icon = 'icons/obj/projectiles.dmi'
	var/proj_icon_state = "bullet"

	New()
		. = ..()
		var/datum/projectile/special/spawner/P = proj
		P.typetospawn = src.typetospawn
		P.damage_type = src.damage_type
		P.hit_type = src.hit_type
		P.shot_sound = src.proj_shot_sound
		P.hit_sound = src.proj_hit_sound
		P.max_range = src.max_range
		P.dissipation_rate = src.dissipation_rate
		P.icon = src.proj_icon
		P.icon_state = src.proj_icon_state
		P.name = src.proj_name

	snack_dispenser
		typetospawn = /obj/random_item_spawner/snacks
		proj_name = "snack"
		proj_shot_sound = 'sound/machines/ding.ogg'

	ice_cream_dispenser
		typetospawn = /obj/item/reagent_containers/food/snacks/ice_cream/goodrandom
		proj_icon = 'icons/obj/foodNdrink/food_snacks.dmi'
		proj_icon_state = "icecream"
		proj_shot_sound = 'sound/effects/splort.ogg'
		proj_name = "ice cream"

	organ_dispenser
		typetospawn = /obj/random_item_spawner/organs/bloody/one_to_three
		cooldown = 5 SECOND
		reload_time = 5 SECOND
		proj_icon = 'icons/mob/monkey.dmi'
		proj_icon_state = "monkey"
		proj_shot_sound = 'sound/voice/screams/monkey_scream.ogg'
		proj_hit_sound = 'sound/impact_sounds/Slimy_Splat_1.ogg'
		proj_name = "monkey"

/datum/limb/gun/fluid
	proj = new/datum/projectile/special/shotchem

	var/chem_volume = 40
	var/initial_reagents = list()
	var/initial_gas_mixture = list()
	var/lit = TRUE
	var/base_temperature = 1000

	alter_projectile(var/obj/projectile/P)
		if(!P.proj_data)
			return

		var/list/P_special_data = P.special_data
		if(!P.reagents)
			P.create_reagents(chem_volume)

		if (islist(src.initial_reagents) && length(src.initial_reagents))
			for (var/current_id in src.initial_reagents)
				if (!istext(current_id))
					continue
				var/amt = src.initial_reagents[current_id]
				if (!isnum(amt))
					amt = (src.chem_volume / length(src.initial_reagents)) // should put an even amount of each?
				if (isnum(amt))
					P.reagents.add_reagent(current_id, amt)

		var/datum/gas_mixture/airgas = new /datum/gas_mixture
		for(var/gas in src.initial_gas_mixture)
			switch(gas)
				if("oxygen")
					airgas.oxygen = initial_gas_mixture[gas]
				if("toxins")
					airgas.toxins = initial_gas_mixture[gas]
				if("nitrogen")
					airgas.nitrogen = initial_gas_mixture[gas]

		P_special_data["proj_color"] = P.reagents.get_average_color()
		P_special_data["IS_LIT"] = src.lit
		P_special_data["burn_temp"] = src.base_temperature


		airgas.volume = 1
		if(src.lit)
			airgas.temperature = P_special_data["burn_temp"]

		P_special_data["airgas"] = airgas
		P_special_data["speed_mult"] = 0.6
		P_special_data["temp_pct_loss_atom"] = 0.02 // keep the heat, more or less

/datum/limb/gun/fluid/flamethrower
	shots = 4
	current_shots = 4
	cooldown = 2 SECONDS
	reload_time = 15 SECONDS

	var/mode = 0 //FLAMER_MODE_SINGLE
	initial_reagents = list("napalm_goo"=40)
	initial_gas_mixture = list("oxygen"=0.62)

	alter_projectile(var/obj/projectile/P)
		. = ..()

		var/list/P_special_data = P.special_data
		switch(mode)
			if(0)
				P_special_data["speed_mult"] = 0.6
				P_special_data["chem_pct_app_tile"] = 0.15
			if(1)
				P_special_data["speed_mult"] = 0.6
				P_special_data["chem_pct_app_tile"] = 0.20
			if(2)
				P_special_data["speed_mult"] = 1
				P_special_data["chem_pct_app_tile"] = 0.1
			else //default to backtank??
				P_special_data["speed_mult"] = 0.6
				P_special_data["chem_pct_app_tile"] = 0.15


/datum/limb/mouth
	var/sound_attack = 'sound/voice/animal/short_hiss.ogg'
	var/dam_low = 3
	var/dam_high = 9
	var/custom_msg = null
	var/miss_prob = 80
	var/stam_damage_mult = 1
	var/harm_intent_delay = COMBAT_CLICK_DELAY

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
			msgs.base_attack_message = src.custom_msg ? src.custom_msg : SPAN_COMBAT("<b>[user] bites [target]!</b>")
			msgs.played_sound = src.sound_attack
			msgs.flush(0)
			user.HealDamage("All", 2, 0)
		else
			user.visible_message(SPAN_COMBAT("<b>[user] attempts to bite [target] but misses!</b>"))
		user.lastattacked = get_weakref(target)
		ON_COOLDOWN(src, "limb_cooldown", harm_intent_delay)



/datum/limb/mouth/maneater
	sound_attack = 'sound/impact_sounds/Flesh_Tear_2.ogg'
	dam_low = 8
	dam_high = 12
	custom_msg = null
	miss_prob = 90
	stam_damage_mult = 0
	harm_intent_delay = COMBAT_CLICK_DELAY
	can_beat_up_robots = TRUE
	var/human_stam_damage = 50 //! how much stam damage this limb should deal to living mobs
	var/human_desorient_duration = 2 SECONDS //! how much desorient this limb should apply to living mobs
	var/human_stun_duration = 5 SECONDS //! how much stun this limb should apply to living mobs
	var/human_stun_cooldown = 6 SECONDS //! if this limb stunned: how long should this kind of limb not be able to stun the target; to prevent reapplication of stuns
	var/list/chems_to_inject = null //! list of chems this limb should inject on targets
	var/amount_to_inject = 3 //! amount of chems this limb should inject on targets
	var/borg_damage_bonus = 4 //! additional damage bonus or malus dealt to borgs
	var/borg_flinging_cooldown = 6 SECONDS //! cooldown on which to throw a borg across the room. No permastunning borgs

/datum/limb/mouth/maneater/New(var/obj/item/parts/holder)
	..()
	src.chems_to_inject = list()

/datum/limb/mouth/maneater/harm(mob/target, var/mob/user)
	if (!user || !target)
		return 0

	if (!target.melee_attack_test(user))
		return

	if (issilicon(target))
		src.fuck_up_silicons(target, user)
	else
		if (prob(src.miss_prob) || is_incapacitated(target)|| target.restrained())

			var/datum/attackResults/msgs = user.calculate_melee_attack(target, src.dam_low, src.dam_high, 0, src.stam_damage_mult, !isghostcritter(user), can_punch = 0, can_kick = 0)
			user.attack_effects(target, user.zone_sel?.selecting)
			if (isliving(target) && !issilicon(target))
				var/mob/living/victim = target
				//we want to stun the target long enough to get grabbed in find themselves about to get eaten, but not long enough to not be able to have the chance to struggle out of the grab
				if(!GET_COOLDOWN(victim, "maneater_paralysis") && victim.do_disorient(src.human_stam_damage, unconscious = src.human_stun_duration, disorient = src.human_desorient_duration, stack_stuns = FALSE))
					//If we dropped the Stamina below 0 and stunned the target, we put the stam damage on a cooldown
					ON_COOLDOWN(victim, "maneater_paralysis", src.human_stun_cooldown)
				//after the stun, as a little treat for skilled botanist, a maneater that got splices in it tries to inject its victims
				if (length(src.chems_to_inject) > 0)
					var/chem_protection = 0
					if (ishuman(victim))
						chem_protection = ((100 - victim.get_chem_protection())/100) //not gonna inject people with bio suits (1 is no chem prot, 0 is full prot for maths)
					var/injected_per_reagent = max(0.1 , chem_protection * src.amount_to_inject / length(src.chems_to_inject))
					if (injected_per_reagent > 0.1)
						for (var/plantReagent in src.chems_to_inject)
							victim.reagents?.add_reagent(plantReagent, injected_per_reagent)

			msgs.base_attack_message = src.custom_msg ? src.custom_msg : SPAN_COMBAT("<b>[user] bites [target]!</b>")
			msgs.played_sound = src.sound_attack
			msgs.flush(0)
		else
			user.visible_message(SPAN_COMBAT("<b>[user] attempts to bite [target] but misses!</b>"))
	user.lastattacked = get_weakref(target)
	if (user != target)
		attack_twitch(user, 1.2, 1.2)
	ON_COOLDOWN(src, "limb_cooldown", harm_intent_delay)

/datum/limb/mouth/maneater/proc/fuck_up_silicons(mob/target, var/mob/user)
	/// this proc makes the maneater fling borgs across the room or damages AI. The maneater is not interested in borgs, so it should just backhand them across the room.
	/// It should not directly go for wrenching off the head of borgs like special_attack_silicon
	var/damage = rand(src.dam_low, src.dam_high) + src.borg_damage_bonus

	if (check_target_immunity(target) == 1)
		playsound(user.loc, "punch", 50, 1, 1)
		user.visible_message(SPAN_COMBAT("<b>[user]'s attack bounces off [target] uselessly!</B>"))
		return

	playsound(user.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, 1)
	if (isrobot(target) && !target.anchored && !ON_COOLDOWN(src, "maneater_backhand", src.borg_flinging_cooldown))
		wrestler_backfist(user, target)
		user.visible_message(SPAN_COMBAT("<b>[user] flings [target] across the room!</b>"))
	else
		user.visible_message(SPAN_COMBAT("<b>[user] wails furiously on [target]!</b>"))

	if (damage > 0)
		random_brute_damage(target, damage)
		target.UpdateDamageIcon()

/// for cats/mice/etc
/datum/limb/mouth/small
	sound_attack = 'sound/impact_sounds/Flesh_Tear_1.ogg'
	dam_low = 1
	dam_high = 3
	stam_damage_mult = 0.3

	harm(mob/target, var/mob/user)
		if (isghostcritter(user) && ishuman(target) && target.health < target.max_health * 0.8)
			boutput(user, SPAN_ALERT("Your spectral conscience refuses to damage this human any further."))
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
	can_beat_up_robots = TRUE //it's a bear!
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
				if (FALSE)
					if (isitem(target))
						boutput(user, SPAN_ALERT("You try to pick [target] up but it wiggles out of your hand. Opposable thumbs would be nice."))
						return
					else if (istype(target, /obj/machinery))
						boutput(user, SPAN_ALERT("You're unlikely to be able to use [target]. You manage to scratch its surface though."))
						return

				if (TRUE)
					user.lastattacked = get_weakref(target)
					return

		. = ..()

	help(mob/target, var/mob/living/user)
		user.show_message(SPAN_ALERT("Nope. Not going to work. You're more likely to kill them."))
		user.lastattacked = get_weakref(target)

	disarm(mob/target, var/mob/living/user)
		logTheThing(LOG_COMBAT, user, "mauls [constructTarget(target,"combat")] with bear limbs (disarm intent) at [log_loc(user)].")
		user.visible_message(SPAN_ALERT("[user] mauls [target] while trying to disarm them!"))
		harm(target, user, 1)

	grab(mob/target, var/mob/living/user)
		logTheThing(LOG_COMBAT, user, "mauls [constructTarget(target,"combat")] with bear limbs (grab intent) at [log_loc(user)].")
		user.visible_message(SPAN_ALERT("[user] mauls [target] while trying to grab them!"))
		harm(target, user, 1)

	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if (no_logs != 1)
			logTheThing(LOG_COMBAT, user, "mauls [constructTarget(target,"combat")] with bear limbs at [log_loc(user)].")

		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 6, 10, 0, can_punch = 0, can_kick = 0)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("maim", "maul", "mangle", "rip", "claw", "lacerate", "mutilate")
		msgs.base_attack_message = SPAN_COMBAT("<b>[user] [action]s [target] with their [src.holder]!</b>")
		msgs.played_sound = 'sound/impact_sounds/Flesh_Tear_3.ogg'
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		if (prob(20))
			if (iscarbon(target))
				var/mob/living/carbon/C = target
				C.do_disorient(25, disorient=2 SECONDS)
		user.lastattacked = get_weakref(target)
		ON_COOLDOWN(src, "limb_cooldown", 2 SECONDS)

/datum/limb/zombie
	///Legally distinct from can_pickup_item, determines whether we use the thrall behaviour of pickup actionbars
	var/can_reach = FALSE
	can_beat_up_robots = TRUE
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
				if (!src.can_reach)
					boutput(user, SPAN_ALERT("Your zombie arm is too dumb to be able to handle this item!"))
					return
				boutput(user, SPAN_HINT("You reach out for the [target]."))
				var/datum/action/pickup = \
					new /datum/action/bar/private/icon/callback(user, target, 1.5 SECONDS, /atom/proc.Attackhand, list(user, params, location, control),
																null, null, null, (INTERRUPT_ACTION | INTERRUPT_ACT | INTERRUPT_STUNNED))
				pickup.resumable = FALSE // so we can click something else to cancel the action
				actions.start(pickup, user)
				return
			else if(istype(target, /obj/machinery/door))
				var/obj/machinery/door/O = target
				O.visible_message(SPAN_COMBAT("<b>[user]</b> violently smashes against the [O]!"))
				playsound(user.loc, O.hitsound, 50, 1, pitch = 1.6)
				O.take_damage(20, user) //Like 30ish hits to break a normal airlock?
				hit = TRUE
			else if(istype(target, /obj/mesh/grille))
				var/obj/mesh/grille/O = target
				if (!O.shock(user, 70))
					O.visible_message(SPAN_COMBAT("<b>[user]</b> violently slashes [O]!"))
					playsound(O.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 80, 1)
					O.damage_slashing(5)
				hit = TRUE

			else if(istype(target, /obj/window))
				var/obj/window/O = target
				O.visible_message(SPAN_ALERT("[user] smashes into the window."), SPAN_NOTICE("You mash yourself against the window."))
				O.damage_blunt(15)
				playsound(user.loc, O.hitsound, 50, 1, pitch = 1.6)
				hit = TRUE

			else if(istype(target, /obj/table))
				var/obj/table/O = target
				O.visible_message(SPAN_COMBAT("<b>[user]</b> violently rips apart the [O]!"))
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
				O.visible_message(SPAN_COMBAT("<b>[user]</b> violently rips [O] apart!"))
				hit = TRUE
			if(prob(40) && !ON_COOLDOWN(user, "zombie arm scream", 5 SECONDS))
				user.emote("scream")
			if (hit)
				user.lastattacked = get_weakref(target)
				attack_particle(user, target)
				return

		if (istype(target, /obj/machinery))
			boutput(user, SPAN_ALERT("You're unlikely to be able to use [target]. You manage to scratch its surface though."))
			return

		..()

	disarm(mob/target, var/mob/living/user)
		logTheThing(LOG_COMBAT, user, "mauls [constructTarget(target,"combat")] with zomb limbs (disarm intent) at [log_loc(user)].")
		user.visible_message(SPAN_ALERT("[user] mauls [target] while trying to disarm them!"))
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
			user.visible_message(SPAN_ALERT("[user] grabs hold of [target] aggressively!"))

	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if (no_logs != 1)
			logTheThing(LOG_COMBAT, user, "mauls [constructTarget(target,"combat")] with zombie limbs at [log_loc(user)].")

		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 6, 10, 1, can_punch = 0, can_kick = 0)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("maim", "maul", "mangle", "rip", "scratch", "mutilate")
		msgs.base_attack_message = SPAN_COMBAT("<b>[user] [action]s [target] with their [src.holder]!</b>")
		msgs.played_sound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
		msgs.damage_type = DAMAGE_BLUNT
		msgs.flush(SUPPRESS_LOGS)
		if (prob(40) && ishuman(user))
			if (iscarbon(target))
				var/mob/living/carbon/C = target
				C.do_disorient(25, disorient=3 SECONDS)
		if (ishuman(target) && ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.mutantrace, /datum/mutantrace/zombie/can_infect))
				target.changeStatus("z_pre_inf", rand(5,9) SECONDS)
		else if (issilicon(target))
			special_attack_silicon(target, user)

		user.lastattacked = get_weakref(target)
		ON_COOLDOWN(src, "limb_cooldown", 3 SECONDS)

/datum/limb/zombie/thrall
	can_reach = TRUE

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
		user.show_message(SPAN_ALERT("Not going to work. You're more likely to kill them."))
		user.lastattacked = get_weakref(target)

	disarm(mob/target, var/mob/living/user)
		logTheThing(LOG_COMBAT, user, "slashes [constructTarget(target,"combat")] with dual saw (disarm intent) at [log_loc(user)].")
		user.visible_message(SPAN_ALERT("[user] slashes [target] while trying to disarm them!"))
		harm(target, user, 1)

	grab(mob/target, var/mob/living/user)
		logTheThing(LOG_COMBAT, user, "slashes [constructTarget(target,"combat")] with dual saw (grab intent) at [log_loc(user)].")
		user.visible_message(SPAN_ALERT("[user] slashes [target] while trying to grab them!"))
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
		msgs.base_attack_message = SPAN_COMBAT("<b>[user] [action]s [target] with their [src.holder]!</b>")
		msgs.played_sound = 'sound/effects/sawhit.ogg'
		boutput(target, SPAN_ALERT("You can feel the saw slicing your body apart!"))
		target.emote("scream")
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		if (prob(60))
			target.changeStatus("knockdown", 2 SECONDS)
		user.lastattacked = get_weakref(target)

/datum/limb/brullbar
	var/log_name = "brullbar limbs"
	var/quality = 0.7
	var/king = FALSE
	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return
		if(check_target_immunity( target ))
			return

		if (!istype(user))
			target.Attackhand(user, params, location, control)
			return

		if (isobj(target))
			switch (user.smash_through(target, list("window", "grille", "door", "blob")))
				if (0)
					if (istype(target, /obj/item/reagent_containers))
						if (prob(50 * quality))
							user.visible_message(SPAN_ALERT("[user] accidentally crushes [target]!"), SPAN_ALERT("You accidentally crush the [target]!"))
							qdel(target)
							return
					else if (isitem(target))
						if (prob(45))
							user.show_message(SPAN_ALERT("[target] slips through your claws!"))
							return

				if (1)
					user.lastattacked = get_weakref(target)
					return

		..()
		return

	proc/accident(mob/target, mob/living/user)
		if(check_target_immunity( target ))
			return 0
		if (prob(25))
			logTheThing(LOG_COMBAT, user, "accidentally harms [constructTarget(target,"combat")] with [src] at [log_loc(user)].")
			user.visible_message(SPAN_COMBAT("<b>[user] accidentally claws [target] while trying to [user.a_intent] them!</b>"), SPAN_COMBAT("<b>You accidentally claw [target] while trying to [user.a_intent] them!</b>"))
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
			logTheThing(LOG_COMBAT, user, "mauls [constructTarget(target,"combat")] with [src] at [log_loc(user)].")

		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 6, 10, rand(5,9) * quality, can_punch = 0, can_kick = 0)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("maim", "maul", "mangle", "rip", "claw", "lacerate", "mutilate")
		msgs.base_attack_message = SPAN_COMBAT("<b>[user] [action]s [target] with their [src.holder]!</b>")
		msgs.played_sound = 'sound/impact_sounds/Flesh_Tear_3.ogg'
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		if (prob(20 * quality))
			if (iscarbon(target))
				var/mob/living/carbon/C = target
				C.do_disorient(15, disorient = 1 SECONDS)
		user.lastattacked = get_weakref(target)
		ON_COOLDOWN(src, "limb_cooldown", 20)

/datum/limb/brullbar/king
	log_name = "king brullbar limbs"
	quality = 1.4
	king = TRUE

/datum/limb/brullbar/severed_werewolf
	log_name = "severed werewolf limb"
	quality = 1

/// Currently used by the High Fever disease which is obtainable from the "Too Much" chem which only shows up in sickly pears, which are currently commented out. Go there to make use of this.
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
			user.visible_message(SPAN_ALERT("The [I] melts in [user]'s clutch"), SPAN_ALERT("The [I] melts in your clutch!"))
			qdel(target)
			I2.desc = "Looks like this was \an [I], melted by someone who was too much."
			for(var/mob/M in AIviewers(5, target))
				boutput(M, SPAN_ALERT("\The [I] melts."))
			qdel(I)
			return

		..()
		return

	proc/accident(mob/target, mob/living/user)
		if(check_target_immunity( target ))
			return 0
		if (prob(15))
			logTheThing(LOG_COMBAT, user, "accidentally harms [constructTarget(target,"combat")] with hot hands at [log_loc(user)].")
			user.visible_message(SPAN_COMBAT("<b>[user] accidentally melts [target] while trying to [user.a_intent] them!</b>"), SPAN_COMBAT("<b>You accidentally melt [target] while trying to [user.a_intent] them!</b>"))
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

		msgs.base_attack_message = SPAN_COMBAT("<b>[user] melts [target] with their clutch!</b>")
		msgs.played_sound = 'sound/impact_sounds/burn_sizzle.ogg'
		msgs.damage_type = DAMAGE_BURN
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = get_weakref(target)


// A replacement for the awful custom_attack() overrides in mutantraces.dm, which consisted of two
// entire copies of pre-stamina melee attack code (Convair880).
/datum/limb/abomination
	can_beat_up_robots = TRUE
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
			user.lastattacked = get_weakref(target)

			var/obj/critter/victim = target

			if (src.weak == 1)
				SPAWN(0)
					step_away(victim, user, 15)

				playsound(user.loc, pick('sound/voice/animal/werewolf_attack1.ogg', 'sound/voice/animal/werewolf_attack2.ogg', 'sound/voice/animal/werewolf_attack3.ogg'), 50, 1)
				SPAWN(0.1 SECONDS)
					if (user) playsound(user.loc, 'sound/impact_sounds/Flesh_Tear_3.ogg', 40, 1, -1)

				user.visible_message(SPAN_COMBAT("<b>[user] slashes viciously at [victim]!</B>"))
				victim.health -= rand(4,8) * victim.brutevuln

			if (src.weak == 2)
				var/turf/T = get_edge_target_turf(user, user.dir)

				if (prob(66) && T && isturf(T))
					user.visible_message(SPAN_COMBAT("<b>[user] mauls [victim] viciously, sending them flying!</B>"))
					victim.health -= 6 * victim.brutevuln
					victim.throw_at(T, 10, 2)
				else
					user.visible_message(SPAN_COMBAT("<b>[user] savagely slashes [victim]!"))
					victim.health -= 4 * victim.brutevuln

				playsound(user.loc, 'sound/misc/hastur/tentacle_hit.ogg', 25, 1, -1)

			else
				var/turf/T = get_edge_target_turf(user, user.dir)

				if (prob(66) && T && isturf(T))
					user.visible_message(SPAN_COMBAT("<b>[user] savagely punches [victim], sending them flying!</B>"))
					victim.health -= 6 * victim.brutevuln
					victim.throw_at(T, 10, 2)
				else
					user.visible_message(SPAN_COMBAT("<b>[user] punches [victim]!"))
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
					user.lastattacked = get_weakref(target)
					return

		if (ismob(target))
			user.lastattacked = get_weakref(target)
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
			user.visible_message(SPAN_ALERT("[user] grabs hold of [target] aggressively!"))

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

		user.lastattacked = get_weakref(target)

		if (src.weak == 1) // Werewolves get a guaranteed knockdown.
			if (!target.anchored && prob(50))
				send_flying = 1

			msgs.played_sound = 'sound/impact_sounds/Generic_Shove_1.ogg'
			user.werewolf_audio_effects(target, "disarm")
			msgs.base_attack_message = SPAN_COMBAT("<b>[user] [pick("clocks", "strikes", "smashes")] [target] with a [pick("fierce", "fearsome", "supernatural", "wild", "beastly")] punch, forcing them to the ground!</B>")

			if (prob(35))
				msgs.damage_type = DAMAGE_CUT // Nasty claws!

			msgs.damage = rand(1,9)
			target.changeStatus("knockdown", 2 SECONDS)
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
				msgs.base_attack_message = SPAN_COMBAT("<b>[user] whips [HH] with the sharp edge of a chitinous tendril, shearing off their [limb_name]!")
				msgs.damage_type = DAMAGE_CUT // We just lost a limb.

				msgs.damage = rand(1,5)
				HH.changeStatus("stunned", 2 SECONDS)

			else
				if (!target.anchored && prob(30))
					send_flying = 1
				else
					target.drop_item() // Shamblers get a guaranteed disarm.

				msgs.played_sound = 'sound/impact_sounds/Generic_Shove_1.ogg'
				msgs.base_attack_message = SPAN_COMBAT("<b>[user] shoves [target] with a [pick("powerful", "fearsome", "intimidating", "strong")] tendril[send_flying == 0 ? "" : ", forcing them to the ground"]!</B>")
				msgs.damage = rand(1,2)

		logTheThing(LOG_COMBAT, user, "diarms [constructTarget(target,"combat")] with [src.weak == 1 ? "werewolf" : "abomination"] arms at [log_loc(user)].")

		if (send_flying == 2)
			msgs.after_effects += /proc/wrestler_backfist
		else if (send_flying == 1)
			msgs.after_effects += /proc/wrestler_knockdown

		msgs.flush(SUPPRESS_LOGS)

		user.lastattacked = get_weakref(target)
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
				msgs.base_attack_message = SPAN_COMBAT("<b>[user] delivers a supernatural punch, sending [target] flying!</b>")
			else
				if (prob(25))
					msgs.base_attack_message = SPAN_COMBAT("<b>[user] mauls [target] viciously[send_flying == 0 ? "" : ", forcing them to the ground"]!</B>")
				else
					msgs.base_attack_message = SPAN_COMBAT("<b>[user] slashes viciously at [target][send_flying == 0 ? "" : ", forcing them to the ground"]!</B>")
					target.add_fingerprint(user)

			if (prob(33) && !isdead(target) && !issilicon(target))
				target.emote("scream")

			msgs.played_sound = 'sound/impact_sounds/Generic_Shove_1.ogg'
			user.werewolf_audio_effects(target, "swipe")
			msgs.damage = rand(8, 17)
			msgs.damage_type = DAMAGE_CUT // Nasty claws!

		else if (src.weak == 2)
			if (send_flying == 2)
				msgs.base_attack_message = SPAN_COMBAT("<b>[user] delivers a coil of tentacles at [target], sending them flying!</b>")
			else
				if (prob(25))
					msgs.base_attack_message = SPAN_COMBAT("<b>[user] mauls [target] viciously[send_flying == 0 ? "" : ", forcing them to the ground"]!</B>")
				else
					msgs.base_attack_message = SPAN_COMBAT("<b>[user] slashes viciously at [target][send_flying == 0 ? "" : ", forcing them to the ground"]!</B>")
					target.add_fingerprint(user)

			if (prob(33) && !isdead(target) && !issilicon(target))
				target.emote("scream")

			msgs.played_sound = 'sound/misc/hastur/tentacle_hit.ogg'
			msgs.damage = rand(8, 17)
			FLICK("hastur-attack", user)
			msgs.damage_type = DAMAGE_CUT // Nasty tentacles with sharp spikes!

		else
			if (send_flying == 2)
				msgs.base_attack_message = SPAN_COMBAT("<b>[user] delivers a savage blow, sending [target] flying!</b>")
			else
				msgs.base_attack_message = SPAN_COMBAT("<b>[user] punches [target] with a [pick("powerful", "fearsome", "intimidating", "strong")] tendril[send_flying == 0 ? "" : ", forcing them to the ground"]!</B>")

			msgs.played_sound = pick(sounds_punch)
			msgs.damage = rand(6, 13)
			msgs.damage_type = DAMAGE_BLUNT

		if (send_flying == 2)
			msgs.after_effects += /proc/wrestler_backfist
		else if (send_flying == 1)
			msgs.after_effects += /proc/wrestler_knockdown

		logTheThing(LOG_COMBAT, user, "punches [constructTarget(target,"combat")] with [src.weak == 1 ? "werewolf" : "abomination"] arms for [msgs.damage] damage at [log_loc(user)].")
		user.attack_effects(target, user.zone_sel?.selecting)
		msgs.flush(SUPPRESS_LOGS)

		user.lastattacked = get_weakref(target)
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
		user.lastattacked = get_weakref(target)
		..()
		return

/datum/limb/claw
	var/damage = 10
	can_beat_up_robots = TRUE
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
							user.show_message(SPAN_ALERT("[target] slips through your claws!"))
							return
						return ..() // was it intended that you were never supposed to actually pick things up with this limb type???? I feel like it was not. call your parents!!! - haine
					if (istype(target,/obj/machinery/power/apc))
						var/obj/machinery/power/apc/APC = target
						for (var/i=1,i<=4,i++)
							APC.cut(i)
						user.visible_message(SPAN_COMBAT("<b>[user]'s claw slithers inside [target] and slashes the wires!</b>"), SPAN_COMBAT("<b>Your claw slithers inside [target] and slashes the wires!</b>"))
						return
					if (istype(target,/obj/cable))
						var/obj/cable/C = target
						C.cut(user,user.loc)
						return
				if (1)
					user.lastattacked = get_weakref(target)
					return
		..()
		return

	proc/accident(mob/target, mob/living/user)
		if(check_target_immunity( target ))
			return 0
		if (prob(25))
			logTheThing(LOG_COMBAT, user, "accidentally harms [constructTarget(target,"combat")] with claw arms at [log_loc(user)].")
			user.visible_message(SPAN_COMBAT("<b>[user] accidentally claws [target] while trying to [user.a_intent] them!</b>"), SPAN_COMBAT("<b>You accidentally claw [target] while trying to [user.a_intent] them!</b>"))
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

		var/datum/attackResults/msgs = user.calculate_melee_attack(target, src.damage, src.damage, rand(1,3) * quality, can_punch = 0, can_kick = 0)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("maim", "stab", "rip", "claw", "slashe")
		msgs.base_attack_message = SPAN_COMBAT("<b>[user] [action]s [target] with their [src.holder]!</b>")
		msgs.played_sound = 'sound/impact_sounds/Flesh_Tear_3.ogg'
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = get_weakref(target)
		ON_COOLDOWN(src, "limb_cooldown", COMBAT_CLICK_DELAY)

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
		msgs.base_attack_message = SPAN_COMBAT("<b>[user] punches [target][pick("!", ", with a seemingly unknown effect!", ", doing who knows what!")]</b>")
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
					boutput(target, SPAN_ALERT("[pick("Your insides don't feel good!", "You don't feel right somehow.", "You feel strange inside.")]"))

		logTheThing(LOG_COMBAT, user, "punches [constructTarget(target, "combat")] with eldritch arms at [log_loc(user)].")

		user.lastattacked = get_weakref(target)

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
			user.lastattacked = get_weakref(target)
			user.smash_through(target, list("grille"))
			var/obj/O = target
			if (isitem(O) && !O.anchored)
				playsound(user,'sound/impact_sounds/Generic_Hit_1.ogg', 50, TRUE, pitch = 1.7)
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
		msgs.base_attack_message = SPAN_COMBAT("<b>[user] [action]s [target]!</b>")
		msgs.played_sound = 'sound/impact_sounds/Generic_Hit_1.ogg'
		msgs.damage_type = DAMAGE_BLUNT
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = get_weakref(target)


/// little critters with teeth, like mice! can pick up small items only. There are some checks in critter.dm, which might need to be updated with whatever you edit here.
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

				for (var/type in src.interact_exemptions)
					if (istype(O, type))
						exempt = TRUE
						..()
						return

				if (issmallanimal(user))
					var/mob/living/critter/small_animal/C = user
					if (C.ghost_spawned && HAS_FLAG(O.object_flags, NO_GHOSTCRITTER))
						can_pickup = 0
				if (O.w_class > max_wclass || !can_pickup && !exempt)
					user.visible_message(SPAN_COMBAT("<b>[user] struggles, failing to lift [target] off the ground!</b>"), SPAN_COMBAT("<b>You struggle with [target], but it's too big for you to lift!</b>"))
					return
			else
				for (var/type in src.interact_exemptions)
					if (istype(target, type))
						exempt = TRUE
						..()
						return
				if (issmallanimal(user))
					var/mob/living/critter/small_animal/C = user
					var/obj/O = target
					if (C.ghost_spawned && HAS_FLAG(O.object_flags, NO_GHOSTCRITTER))
						user.show_text(SPAN_COMBAT("<b>You try to use [target], but this is way too complicated for your spectral brain to comprehend!</b>"))
						return


		..()
		return

	help(mob/target, var/mob/living/user)
		if (issmallanimal(user) && iscarbon(target))
			user.lastattacked = get_weakref(target)
			var/mob/living/critter/small_animal/C = user
			if (C.ghost_spawned)
				if (max_wclass < 3)
					user.visible_message(SPAN_COMBAT("<b>[user] tries to help [target], but they're worse than useless!</b>"), SPAN_COMBAT("<b>You try to help [target], but your spectral will can only manage a poke!</b>"))
					playsound(user.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 25, 1, -1)
					return
		..()


	//yeah they're not ACTUALLY biting them but let's just assume that they are because i don't want a mouse or a dog to KO someone with a brutal right hook
	// changed to scratching, small mouths will take care of biting
	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if(check_target_immunity( target ))
			return 0
		if (isghostcritter(user) && ishuman(target) && target.health < 75)
			boutput(user, SPAN_ALERT("Your spectral conscience refuses to damage this human any further."))
			return 0
		var/quality = src.holder.quality
		if (no_logs != 1)
			logTheThing(LOG_COMBAT, user, "attacks [constructTarget(target,"combat")] with a critter arm at [log_loc(user)].")

		var/datum/attackResults/msgs = user.calculate_melee_attack(target, dam_low, dam_high, rand(dam_low, dam_high) * quality, stam_damage_mult, !isghostcritter(user))
		user.attack_effects(target, user.zone_sel?.selecting)
		msgs.base_attack_message = src.custom_msg ? src.custom_msg : SPAN_COMBAT("<b>[user] [pick(src.actions)] [target]!</b>")
		if (src.sound_attack)
			msgs.played_sound = src.sound_attack
		msgs.damage_type = src.dmg_type
		msgs.flush(SUPPRESS_LOGS)

		user.lastattacked = get_weakref(target)
		ON_COOLDOWN(src, "limb_cooldown", COMBAT_CLICK_DELAY)
		attack_particle(user,target)
		if (src != target)
			attack_twitch(src)

	grab(mob/target, var/mob/living/user)
		if (issmallanimal(user))
			user.lastattacked = get_weakref(target)
			var/mob/living/critter/small_animal/C = user
			if (C.ghost_spawned)
				if (max_wclass < 3)
					user.visible_message(SPAN_COMBAT("<b>[user] tries to grab [target], but they are too large!</b>"), SPAN_COMBAT("<b>You try to grab [target], but your spectral will is not strong enough!</b>"))
					return
		..()

	disarm(mob/target, var/mob/living/user)
		if (issmallanimal(user) && iscarbon(target))
			user.lastattacked = get_weakref(target)
			var/mob/living/critter/small_animal/C = user
			if (C.ghost_spawned)
				if (max_wclass < 3)
					user.visible_message(SPAN_COMBAT("<b>[user] tries to disarm [target], but can only manage a pathetic nudge!</b>"), SPAN_COMBAT("<b>You try to disarm [target], but your spectral will can only manage a pathetic nudge!</b>"))
					var/target_stamina = target.get_stamina()
					if (target_stamina && target_stamina > 5)
						target.remove_stamina(rand(1,4))
					playsound(user.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 25, 1, -1)
					return
		..()

/datum/limb/small_critter/mail
	interact_exemptions = list(/obj/item/random_mail)

	grab(mob/target, mob/living/user)
		user.visible_message("<b>[user] scrabbles pathetically at [target]!</b>")

/// same as the parent, but can pick up some heavier shit
/datum/limb/small_critter/med
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

/datum/limb/small_critter/space_phoenix
	dam_low = 5
	dam_high = 10
	dmg_type = DAMAGE_CUT
	actions = list("scratches", "slices", "claws")
	can_gun_grab = FALSE
	can_beat_up_robots = TRUE

/datum/limb/small_critter/med/dash
	dam_low = 3
	dam_high = 8
	actions = list("cuts", "rips", "claws", "slashes")
	sound_attack = 'sound/impact_sounds/Flesh_Tear_3.ogg'

	New(var/obj/item/parts/holder)
		..()
		src.setDisarmSpecial (/datum/item_special/katana_dash/limb)
		src.setHarmSpecial (/datum/item_special/katana_dash/limb)

	attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
		if (!holder)
			return
		if(check_target_immunity( target ))
			return

		if (!istype(user))
			target.Attackhand(user, params, location, control)
			return
		..()

	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if(check_target_immunity( target ))
			return 0
		if (istype(target,/mob/living/critter/small_animal/trilobite))
			return 0
		if (no_logs != 1)
			logTheThing(LOG_COMBAT, user, "slashes [constructTarget(target,"combat")] with dash arms at [log_loc(user)].")
		..()

/// test for crab attack thing
/datum/limb/swipe_quake
	New(var/obj/item/parts/holder)
		..()
		src.setDisarmSpecial (/datum/item_special/slam/no_item_attack)
		src.setHarmSpecial (/datum/item_special/swipe/limb)

/// I wanted a claw-like limb but without the random item pickup fail
/datum/limb/tentacle
	harm(mob/target, var/mob/living/user)
		if(check_target_immunity( target ))
			return FALSE
		logTheThing(LOG_COMBAT, user, "mauls [constructTarget(target,"combat")] with [src] at [log_loc(user)].")

		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 6, 8, rand(3, 5), can_punch = FALSE, can_kick = FALSE)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("maim", "maul", "mangle", "slap", "lacerate", "mutilate")
		msgs.base_attack_message = SPAN_COMBAT("<b>[user] [action]s [target] with [src.holder]!</b>")
		msgs.played_sound = 'sound/impact_sounds/Flesh_Tear_3.ogg'
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = get_weakref(target)


/datum/limb/jean

/datum/limb/golem
	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if (!user || !target)
			return 0

		if (!target.melee_attack_test(user))
			return

		if (no_logs != 1)
			logTheThing(LOG_COMBAT, user, "attacks [constructTarget(target,"combat")] with a golem arm at [log_loc(user)].")

		if(target.reagents)
			if(user.reagents && user.reagents.total_volume)
				user.reagents.reaction(target, TOUCH)
				user.reagents.trans_to(target, 5)

		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 6, 9, rand(4, 6), can_punch = FALSE, can_kick = FALSE)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("pummel", "pound", "mangle")
		msgs.base_attack_message = SPAN_COMBAT("<b>[user] [action]s [target]!</b>")
		msgs.played_sound =	'sound/impact_sounds/Generic_Hit_1.ogg'
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = get_weakref(target)
		ON_COOLDOWN(src, "limb_cooldown", 3 SECONDS)

/datum/limb/sword
	help(mob/target, var/mob/living/user)
		harm(target, user)

	disarm(mob/target, var/mob/living/user)
		harm(target, user)

	grab(mob/target, var/mob/living/user)
		harm(target, user)

	harm(mob/target, var/mob/living/user, var/no_logs = 0)
		if (!user || !target)
			return 0

		if (!target.melee_attack_test(user))
			return

		if (no_logs != 1)
			logTheThing(LOG_COMBAT, user, "attacks [constructTarget(target,"combat")] with a bladed arm at [log_loc(user)].")

		var/datum/attackResults/msgs = user.calculate_melee_attack(target, 6, 12, rand(0, 2), can_punch = FALSE, can_kick = FALSE)
		user.attack_effects(target, user.zone_sel?.selecting)
		var/action = pick("stab", "slashe", "cut")
		msgs.base_attack_message = SPAN_COMBAT("<b>[user] [action]s [target] with a blade!</b>")
		msgs.played_sound = 'sound/impact_sounds/Blade_Small_Bloody.ogg'
		msgs.damage_type = DAMAGE_CUT
		msgs.flush(SUPPRESS_LOGS)
		user.lastattacked = get_weakref(target)
		ON_COOLDOWN(src, "limb_cooldown", 3 SECONDS)
