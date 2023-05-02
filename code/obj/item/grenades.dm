/*
CONTAINS:
NON-CHEM GRENADES
GIMMICK BOMBS
BREACHING CHARGES
FIREWORKS
PIPE BOMBS + CONSTRUCTION
*/

////////////////////////////// Old-style grenades ///////////////////////////////////////

TYPEINFO(/obj/item/old_grenade)
	mats = 6

ADMIN_INTERACT_PROCS(/obj/item/old_grenade, proc/detonate)

/obj/item/old_grenade
	desc = "You shouldn't be able to see this!"
	name = "old grenade"
	var/armed = FALSE
	var/det_time = 3 SECONDS
	var/org_det_time = 3 SECONDS
	var/alt_det_time = 6 SECONDS
	w_class = W_CLASS_SMALL
	icon = 'icons/obj/items/grenade.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "banana"
	item_state = "banana"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT | EXTRADELAY
	c_flags = ONBELT
	is_syndicate = FALSE
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0
	duration_put = 0.25 SECONDS //crime
	var/is_dangerous = TRUE
	var/sound_armed = null
	var/icon_state_armed = null
	var/not_in_mousetraps = 0
	var/issawfly = FALSE //for sawfly remote

	attack_self(mob/user as mob)
		if (!src.armed)
			src.armed = TRUE		//This could help for now. Should leverage the click buffer from combat stuff too.
			if (!isturf(user.loc))
				src.armed = FALSE
				return
			logGrenade(user)
			if (user?.bioHolder.HasEffect("clumsy"))
				boutput(user, "<span class='alert'>Huh? How does this thing work?!</span>")
				src.UpdateIcon()
				playsound(src.loc, src.sound_armed, 75, 1, -3)
				src.add_fingerprint(user)
				SPAWN(0.5 SECONDS)
					if (src) detonate(user)
					return
			else
				boutput(user, "<span class='alert'>You prime [src]! [det_time/10] seconds!</span>")
				src.UpdateIcon()
				playsound(src.loc, src.sound_armed, 75, 1, -3)
				src.add_fingerprint(user)
				SPAWN(src.det_time)
					if (src) detonate(user)
					return

// warcrimes: Why the fuck is autothrow a feature why would this ever be a feature WHY. Now it wont do it unless it's primed i think.
	afterattack(atom/target as mob|obj|turf, mob/user as mob)
		if (src.armed)
			return
		if (BOUNDS_DIST(user, target) == 0 || (!isturf(target) && !isturf(target.loc)) || !isturf(user.loc) || !src.armed )
			return
		if (user.equipped() == src)
			if (!src.armed)
				src.armed = TRUE
				src.UpdateIcon()
				logGrenade(user)
				boutput(user, "<span class='alert'>You prime [src]! [det_time/10] seconds!</span>")
				playsound(src.loc, src.sound_armed, 75, 1, -3)
				SPAWN(src.det_time)
					if (src) detonate(user)
					return
			user.drop_item()
			src.throw_at(get_turf(target), 10, 3)
			src.add_fingerprint(user)

	attackby(obj/item/W, mob/user)
		if (isscrewingtool(W))
			if (src.det_time == src.org_det_time)
				src.det_time = src.alt_det_time
				user.show_message("<span class='notice'>You set [src] for a [det_time/10] second detonation time.</span>")
				src.desc = "It is set to detonate in [det_time/10] seconds."
			else
				src.det_time = src.org_det_time
				user.show_message("<span class='notice'>You set [src] for a [det_time/10] second detonation time.</span>")
				src.desc = "It is set to detonate in [det_time/10] seconds."
			src.add_fingerprint(user)

	update_icon()
		..()
		if (src.armed)
			src.icon_state = src.icon_state_armed
		else
			src.icon_state = initial(src.icon_state)

	proc/detonate(mob/user) // Most grenades require a turf reference.
		var/turf/T = get_turf(src)
		if (!T || !isturf(T))
			return null
		else
			return T

	proc/logGrenade(mob/user)
		var/area/A = get_area(src)
		if(!A.dont_log_combat && user)
			if(is_dangerous)
				message_admins("Grenade ([src]) primed at [log_loc(src)] by [key_name(user)].")
			logTheThing(LOG_COMBAT, user, "primes a grenade ([src.type]) at [log_loc(user)].")

ABSTRACT_TYPE(/obj/item/old_grenade/spawner)
/obj/item/old_grenade/spawner
	desc = "It is set to detonate in 3 seconds."
	det_time = 3 SECONDS
	org_det_time = 3 SECONDS
	alt_det_time = 6 SECONDS
	is_syndicate = TRUE
	sound_armed = 'sound/weapons/armbomb.ogg'
	is_dangerous = FALSE
	var/payload = null
	var/amount_to_spawn = 5

	detonate()
		var/turf/T = ..()
		if (T)
			playsound(T, 'sound/weapons/flashbang.ogg', 25, 1)
			new payload(T)
			for (var/i in 1 to src.amount_to_spawn - 1)
				var/turf/adjacent = get_step(T, cardinal[(i % length(cardinal)) + 1])
				if (!adjacent.density)
					new payload(adjacent)
				else
					new payload(T)
		qdel(src)

/obj/item/old_grenade/spawner/banana
	name = "banana grenade"
	icon_state = "banana"
	icon_state_armed = "banana1"
	payload = /obj/item/bananapeel

/obj/item/old_grenade/spawner/cheese_sandwich
	name = "cheese sandwich grenade"
	icon_state = "banana-old"
	icon_state_armed = "banana1-old"
	payload = /obj/item/reagent_containers/food/snacks/sandwich/cheese

/obj/item/old_grenade/spawner/banana_corndog
	name = "banana corndog grenade"
	icon_state = "banana-old"
	icon_state_armed = "banana1-old"
	payload = /obj/item/reagent_containers/food/snacks/corndog/banana

/obj/item/old_grenade/spawner/wasp
	name = "suspicious looking grenade"
	icon_state = "wasp"
	icon_state_armed = "wasp1"
	payload = /obj/critter/wasp
	is_dangerous = TRUE

/obj/item/old_grenade/thing_thrower
	desc = "It is set to detonate in 3 seconds."
	name = "banana grenade"
	det_time = 3 SECONDS
	org_det_time = 3 SECONDS
	alt_det_time = 6 SECONDS
	icon_state = "banana"
	item_state = "banana"
	is_syndicate = TRUE
	sound_armed = 'sound/weapons/armbomb.ogg'
	icon_state_armed = "banana1"
	is_dangerous = FALSE
	var/payload = /obj/item/reagent_containers/food/snacks/plant/tomato
	var/count = 7

	detonate()
		var/turf/T = ..()
		if (T)
			playsound(T, 'sound/weapons/flashbang.ogg', 25, 1)
			for(var/i = 1; i <= src.count; i++)
				var/atom/movable/thing = new payload(T)
				var/turf/target = locate(T.x + rand(-4, 4), T.y + rand(-4, 4), T.z)
				if(target)
					thing.throw_at(target, rand(0, 10), rand(1, 4))
		qdel(src)

TYPEINFO(/obj/item/old_grenade/graviton)
	mats = 12

/obj/item/old_grenade/graviton //ITS SPELT GRAVITON
	desc = "It is set to detonate in 10 seconds."
	name = "graviton grenade"
	det_time = 10 SECONDS
	org_det_time = 10 SECONDS
	alt_det_time = 6 SECONDS
	icon_state = "graviton"
	item_state = "emp" //TODO: grenades REALLY need custom inhands, but I'm not submitting them in this PR
	is_syndicate = TRUE
	sound_armed = 'sound/weapons/armbomb.ogg'
	icon_state_armed = "graviton1"
	var/icon_state_exploding = "graviton2"

	attack_self(mob/user as mob)
		if (!src.armed)
			src.armed = TRUE		//This could help for now. Should leverege the click buffer from combat stuff too.
			if (!isturf(user.loc))
				src.armed = FALSE
				return
			logGrenade(user)
			if (user?.bioHolder.HasEffect("clumsy"))
				boutput(user, "<span style=\"color:red\">Huh? How does this thing work?!</span>")
				src.icon_state = src.icon_state_exploding
				flick(src.icon_state_armed, src)
				playsound(src.loc, src.sound_armed, 75, 1, -3)
				src.add_fingerprint(user)
				SPAWN(0.5 SECONDS)
					if (src) detonate()
					return
			else
				boutput(user, "<span style=\"color:red\">You prime [src]! [det_time/10] seconds!</span>")
				src.icon_state = src.icon_state_exploding
				flick(src.icon_state_armed, src)
				playsound(src.loc, src.sound_armed, 75, 1, -3)
				src.add_fingerprint(user)
				SPAWN(src.det_time)
					if (src) detonate()
					return
		return

	detonate()
		var/turf/T = ..()
		if (T)
			if (T && isrestrictedz(T.z) || T.loc:sanctuary)
				src.visible_message("<span class='alert'>[src] buzzes for a moment, then self-destructs.</span>")
				elecflash(src,power = 4)
				qdel(src)
				return
			for (var/atom/movable/X in orange(9, T))
				if (istypes(X, list(/obj/machinery/containment_field, /obj/machinery/field_generator, /obj/fluid, /obj/effect, /obj/overlay)))
					continue
				var/area/t = get_area(X)
				if(t?.sanctuary) continue
				if (prob(50) && X.anchored != 2)
					step_towards(X,src)
		qdel(src)
		return

TYPEINFO(/obj/item/old_grenade/singularity)
	mats = 12

/obj/item/old_grenade/singularity
	desc = "It is set to detonate in 10 seconds."
	name = "singularity grenade"
	det_time = 10 SECONDS
	org_det_time = 10 SECONDS
	alt_det_time = 6 SECONDS
	icon_state = "graviton"
	item_state = "emp"
	is_syndicate = TRUE
	sound_armed = 'sound/weapons/armbomb.ogg'
	icon_state_armed = "graviton1"
	var/icon_state_exploding = "graviton2"
	var/radius = 3

	attack_self(mob/user as mob)
		if (!src.armed)
			src.armed = TRUE		//This could help for now. Should leverege the click buffer from combat stuff too.
			if (!isturf(user.loc))
				src.armed = FALSE
				return
			logGrenade(user)
			if (user?.bioHolder.HasEffect("clumsy"))
				boutput(user, "<span style=\"color:red\">Huh? How does this thing work?!</span>")
				src.icon_state = src.icon_state_exploding
				flick(src.icon_state_armed, src)
				playsound(src.loc, src.sound_armed, 75, 1, -3)
				src.add_fingerprint(user)
				SPAWN(0.5 SECONDS)
					if (src) detonate()
					return
			else
				boutput(user, "<span style=\"color:red\">You prime [src]! [det_time/10] seconds!</span>")
				src.icon_state = src.icon_state_exploding
				flick(src.icon_state_armed, src)
				playsound(src.loc, src.sound_armed, 75, 1, -3)
				src.add_fingerprint(user)
				SPAWN(src.det_time)
					if (src) detonate()
					return
		return

	detonate()
		var/turf/T = ..()
		if (T)
			if (T && isrestrictedz(T.z) || T.loc:sanctuary)
				src.visible_message("<span class='alert'>[src] buzzes for a moment, then self-destructs.</span>")
				elecflash(src,power = 4)
				qdel(src)
				return
			src.build_a_singulo()

	proc/build_a_singulo()
		var/turf/C = get_turf(src)
		for(var/turf/T in block(locate(C.x - radius, C.y - radius, C.z), locate(C.x + radius, C.y + radius, C.z)))
			T.ReplaceWith(/turf/simulated/floor/engine, 0, 1, 0, 0)
		new /obj/machinery/the_singularitygen(C)
		for(var/dir in ordinal)
			var/turf/T = get_steps(C, dir, radius)
			var/obj/machinery/field_generator/gen = new(T)
			gen.set_active(1)
			gen.state = 3
			gen.power = 250
			gen.anchored = ANCHORED
			icon_state = "Field_Gen +a"
		qdel(src)

/obj/item/old_grenade/smoke
	desc = "It is set to detonate in 2 seconds."
	name = "smoke grenade"
	icon_state = "smoke"
	det_time = 2 SECONDS
	org_det_time = 2 SECONDS
	alt_det_time = 6 SECONDS
	item_state = "flashbang"
	is_syndicate = TRUE
	sound_armed = 'sound/weapons/armbomb.ogg'
	icon_state_armed = "smoke1"
	var/datum/effects/system/bad_smoke_spread/smoke

	New()
		..()
		src.smoke = new /datum/effects/system/bad_smoke_spread/
		src.smoke.attach(src)
		src.smoke.set_up(10, 0, src.loc)

	detonate()
		var/turf/T = ..()
		if (T)
			var/obj/item/old_grenade/smoke/mustard/M = null
			if (istype(src, /obj/item/old_grenade/smoke/mustard))
				M = src
			playsound(T, 'sound/effects/smoke.ogg', 50, 1, -3)

			SPAWN(0)
				if (src)
					if (M && istype(M, /obj/item/old_grenade/smoke/mustard))
						M.mustard_gas.start()
					else
						src.smoke.start()

					sleep(1 SECOND)
					if (M && istype(M, /obj/item/old_grenade/smoke/mustard))
						M.mustard_gas.start()
					else
						src.smoke.start()

					sleep(1 SECOND)
					if (M && istype(M, /obj/item/old_grenade/smoke/mustard))
						M.mustard_gas.start()
					else
						src.smoke.start()

					sleep(1 SECOND)
					if (M && istype(M, /obj/item/old_grenade/smoke/mustard))
						M.mustard_gas.start()
					else
						src.smoke.start()

					if (M && istype(M, /obj/item/old_grenade/smoke/mustard))
						qdel(M)
					else
						qdel(src)
		else
			qdel(src)
		return

/obj/item/old_grenade/smoke/mustard
	name = "mustard gas grenade"
	var/datum/effects/system/mustard_gas_spread/mustard_gas
	icon_state = "mustard"
	icon_state_armed = "mustard1"

	New()
		..()
		if (usr?.loc) //Wire: Fix for Cannot read null.loc
			src.mustard_gas = new /datum/effects/system/mustard_gas_spread/
			src.mustard_gas.attach(src)
			src.mustard_gas.set_up(5, 0, usr.loc)

/obj/item/old_grenade/stinger
	name = "stinger grenade"
	desc = "It is set to detonate in 3 seconds."
	icon_state = "fragnade"
	det_time = 3 SECONDS
	org_det_time = 3 SECONDS
	alt_det_time = 6 SECONDS
	item_state = "fragnade"
	is_syndicate = FALSE
	sound_armed = 'sound/weapons/pindrop.ogg'
	icon_state_armed = "fragnade1"
	var/custom_projectile_type = /datum/projectile/bullet/stinger_ball
	var/pellets_to_fire = 20

	detonate()
		var/turf/T = ..()
		if (T)
			playsound(T, 'sound/weapons/grenade.ogg', 25, 1)
			explosion(src, T, -1, -1, -0.25, 1)
			var/obj/overlay/O = new/obj/overlay(get_turf(T))
			O.anchored = ANCHORED
			O.name = "Explosion"
			O.layer = NOLIGHT_EFFECTS_LAYER_BASE
			O.icon = 'icons/effects/64x64.dmi'
			O.icon_state = "explo_fiery"
			var/obj/item/old_grenade/stinger/frag/F = null
			if (istype(src, /obj/item/old_grenade/stinger/frag))
				F = src
			if (F)
				playsound(T, 'sound/effects/smoke.ogg', 20, 1, -2)
				SPAWN(0)
					if (F?.smoke) //Wire note: Fix for Cannot execute null.start()
						for(var/i = 1 to 6)
							F.smoke.start()
							sleep(1 SECOND)
			var/datum/projectile/special/spreader/uniform_burst/circle/PJ = new /datum/projectile/special/spreader/uniform_burst/circle(T)
			if(src.custom_projectile_type)
				PJ.spread_projectile_type = src.custom_projectile_type
				PJ.pellet_shot_volume = 75 / PJ.pellets_to_fire //anti-ear destruction
			PJ.pellets_to_fire = src.pellets_to_fire
			var/targetx = src.y - rand(-5,5)
			var/targety = src.y - rand(-5,5)
			var/turf/newtarget = locate(targetx, targety, src.z)
			shoot_projectile_ST(src, PJ, newtarget)
			SPAWN(0.5 SECONDS)
				qdel(O)
				qdel(src)
		else
			qdel(src)
		return

/obj/item/old_grenade/stinger/frag
	name = "frag grenade"
	icon_state = "fragnade-alt"
	icon_state_armed = "fragnade-alt1"
	var/datum/effects/system/bad_smoke_spread/smoke
	custom_projectile_type = /datum/projectile/bullet/grenade_fragment

	New()
		..()
		src.smoke = new /datum/effects/system/bad_smoke_spread/
		src.smoke.attach(src)
		src.smoke.set_up(7, 1, src.loc)

/obj/item/old_grenade/high_explosive
	name = "HE grenade"
	desc = "A high-explosive grenade. It is set to detonate in 3 seconds."
	icon_state = "fragnade-alt"
	icon_state_armed = "fragnade-alt1"
	det_time = 3 SECONDS
	org_det_time = 3 SECONDS
	alt_det_time = 6 SECONDS
	item_state = "fragnade"
	is_syndicate = FALSE
	sound_armed = 'sound/weapons/pindrop.ogg'

	detonate()
		var/turf/T = ..()
		if (T)
			explosion_new(src, T, 5.0, 2)
			playsound(T, 'sound/weapons/grenade.ogg', 25, 1)
			var/obj/overlay/O = new/obj/overlay(get_turf(T))
			O.anchored = ANCHORED
			O.name = "Explosion"
			O.layer = NOLIGHT_EFFECTS_LAYER_BASE
			O.icon = 'icons/effects/64x64.dmi'
			O.icon_state = "explo_fiery"
			SPAWN(0.5 SECONDS)
				qdel(O)
				qdel(src)
		else
			qdel(src)
		return

/obj/item/old_grenade/sonic
	name = "sonic grenade"
	desc = "It is set to detonate in 3 seconds."
	icon_state = "sonic"
	det_time = 3 SECONDS
	org_det_time = 3 SECONDS
	alt_det_time = 6 SECONDS
	item_state = "flashbang"
	is_syndicate = TRUE
	sound_armed = 'sound/effects/screech.ogg'
	icon_state_armed = "sonic1"

	detonate()
		var/turf/T = ..()
		if (T)
			if (isrestrictedz(T.z) && !restricted_z_allowed(usr, T))
				src.visible_message("<span class='alert'>[src] buzzes for a moment, then self-destructs.</span>")
				elecflash(T)
				qdel(src)
				return

			playsound(T, 'sound/weapons/flashbang.ogg', 25, 1)

			for (var/mob/living/M in hearers(8, T))
				if(check_target_immunity(M)) continue
				var/loud = 16 / (GET_DIST(M, T) + 1)
				if (src.loc == M.loc || src.loc == M)
					loud = 16

				var/weak = loud / 3
				var/stun = loud
				var/damage = loud * 2
				var/tempdeaf = loud * 3

				M.apply_sonic_stun(weak, stun, 0, 0, 0, damage, tempdeaf)

			sonic_attack_environmental_effect(T, 8, list("window", "r_window", "displaycase", "glassware"))

		qdel(src)
		return

/obj/item/old_grenade/foam_dart
	name = "foam dart grenade"
	desc = "You can make great fights with these and foam dart guns."
	icon_state = "foam-dart"
	det_time = 3 SECONDS
	org_det_time = 3 SECONDS
	alt_det_time = 6 SECONDS
	item_state = "fragnade"
	sound_armed = 'sound/weapons/pindrop.ogg'
	icon_state_armed = "foam-dart1"
	var/custom_projectile_type = /datum/projectile/bullet/foamdart/biodegradable
	var/pellets_to_fire = 18

	detonate()
		var/turf/T = ..()
		if (!T)
			qdel(src)
			return
		var/datum/projectile/special/spreader/uniform_burst/circle/burst_circle = new /datum/projectile/special/spreader/uniform_burst/circle(T)
		if(src.custom_projectile_type)
			burst_circle.spread_projectile_type = src.custom_projectile_type
			burst_circle.pellet_shot_volume = 75 / burst_circle.pellets_to_fire
		burst_circle.pellets_to_fire = src.pellets_to_fire
		var/targetx = src.y - rand(-5,5)
		var/targety = src.y - rand(-5,5)
		var/turf/newtarget = locate(targetx, targety, src.z)
		shoot_projectile_ST(src, burst_circle, newtarget)
		SPAWN(0.5 SECONDS)
			qdel(src)

/obj/item/old_grenade/emp
	desc = "It is set to detonate in 5 seconds."
	name = "emp grenade"
	det_time = 5 SECONDS
	org_det_time = 5 SECONDS
	alt_det_time = 3 SECONDS
	icon_state = "emp"
	item_state = "emp"
	is_syndicate = TRUE
	sound_armed = 'sound/weapons/armbomb.ogg'
	icon_state_armed = "emp1"

	detonate()
		var/turf/T = ..()
		if (T)
			playsound(T, 'sound/items/Welder2.ogg', 25, 1)
			T.hotspot_expose(700,125)

			var/grenade = src // detaching the proc - in theory
			src = null

			var/obj/overlay/pulse = new/obj/overlay(T)
			pulse.icon = 'icons/effects/effects.dmi'
			pulse.icon_state = "emppulse"
			pulse.name = "emp pulse"
			pulse.anchored = ANCHORED
			SPAWN(2 SECONDS)
				if (pulse) qdel(pulse)

			for (var/turf/tile in range(world.view-1, T))
				for (var/atom/O in tile.contents)
					var/area/t = get_area(O)
					if(t?.sanctuary) continue
					O.emp_act()

			qdel(grenade)
		else
			qdel(src)
		return

TYPEINFO(/obj/item/old_grenade/oxygen)
	mats = list("MET-2"=2, "CON-1"=2, "molitz"=10, "char"=1 )

/obj/item/old_grenade/oxygen
	name = "red oxygen grenade"
	desc = "It is set to detonate in 3 seconds."
	det_time = 3 SECONDS
	org_det_time = 3 SECONDS
	alt_det_time = 6 SECONDS
	icon_state = "oxy"
	item_state = "flashbang"
	sound_armed = 'sound/weapons/armbomb.ogg'
	icon_state_armed = "oxy1"
	is_dangerous = FALSE

	detonate()
		var/turf/simulated/T = ..()
		var/datum/gas_mixture/GM = new /datum/gas_mixture
		GM.temperature = T20C + 15
		GM.oxygen = 1830
		GM.carbon_dioxide = 20

		var/obj/effects/explosion/E = new /obj/effects/explosion(T)
		// Uses existing animated icon adjust coloration of explosion to lighter cyan to match oxygen items
		// scaling it to cover a turf, adjusting plane to avoid casting shadows, and wave animation to
		// help differentiate it from a standard explosion (also makes it wispy)
		E.color = list(0,0,0.6,0.2,0, 0.3,0,-0.8,0,0, 0,0.33,0,0,0, 0.9,0.8,0.8,0.7,0)
		E.plane = PLANE_NOSHADOW_ABOVE
		E.transform = matrix(0.75, MATRIX_SCALE)
		animate_wave(E,4)

		if (T && istype(T))
			if (T.air)
				if (T.parent?.group_processing)
					T.parent.air.merge(GM)
				else
					var/count = length(T.parent?.members)
					if (count)
						var/o2_per = GM.oxygen / count
						var/co2_per = GM.carbon_dioxide / count
						for (var/turf/simulated/MT as() in T.parent.members)
							if (GM.disposed)
								GM = new /datum/gas_mixture
							GM.temperature = T20C + 15
							GM.oxygen = o2_per
							GM.carbon_dioxide = co2_per
							MT.assume_air(GM)
					else
						T.assume_air(GM)

			for (var/mob/living/HH in hearers(8, T))
				var/checkdist = GET_DIST(HH.loc, T)
				var/misstep = clamp(1 + 10 * (5 - checkdist), 0, 40)
				var/ear_damage = max(0, 5 * 0.2 * (3 - checkdist))
				var/ear_tempdeaf = max(0, 5 * 0.2 * (5 - checkdist))
				var/stamina = clamp(5 * (5 + 1 * (7 - checkdist)), 0, 120)
				HH.apply_sonic_stun(0, 0, misstep, 0, 2, ear_damage, ear_tempdeaf, stamina)

			animate(E, alpha=0, time=2.5 SECONDS)
			playsound(T, 'sound/weapons/flashbang.ogg', 30, 1)
			var/datum/effects/system/steam_spread/steam = new /datum/effects/system/steam_spread
			steam.set_up(10, 0, get_turf(src), color="#0ff", plane=PLANE_NOSHADOW_ABOVE)
			steam.attach(src.loc)
			steam.start()

		else
			animate(E, alpha=0, time=2 SECONDS)
			playsound(T, 'sound/weapons/flashbang.ogg', 15, 1)

		E.fingerprintslast = src.fingerprintslast
		qdel(src)
		return

/obj/item/old_grenade/moustache
	name = "moustache grenade"
	desc = "It is set to detonate in 3 seconds."
	det_time = 3 SECONDS
	org_det_time = 3 SECONDS
	alt_det_time = 6 SECONDS
	icon_state = "moustache"
	item_state = "flashbang"
	is_syndicate = TRUE
	sound_armed = 'sound/weapons/armbomb.ogg'
	icon_state_armed = "moustache1"

	detonate()
		var/turf/T = ..()
		if (T)
			for (var/mob/living/carbon/human/M in range(5, T))
				if (!(M.wear_mask && istype(M.wear_mask, /obj/item/clothing/mask/moustache)))
					for (var/obj/item/clothing/O in M)
						if (istype(O,/obj/item/clothing/mask))
							M.u_equip(O)
							if (O)
								O.set_loc(M.loc)
								O.dropped(M)
								O.layer = initial(O.layer)

					var/obj/item/clothing/mask/moustache/moustache = new /obj/item/clothing/mask/moustache(M)
					moustache.cant_self_remove = 1
					moustache.cant_other_remove = 1

					M.equip_if_possible(moustache, M.slot_wear_mask)
					M.set_clothing_icon_dirty()

			playsound(T, 'sound/effects/Explosion2.ogg', 100, 1)
			var/obj/effects/explosion/E = new /obj/effects/explosion(T)
			E.fingerprintslast = src.fingerprintslast

		qdel(src)
		return

/obj/item/old_grenade/light_gimmick
	name = "light grenade"
	icon_state = "lightgrenade"
	icon = 'icons/obj/items/weapons.dmi'
	desc = "It's a small cast-iron egg-shaped object, with the words \"Pick Me Up\" in gold in it."
	armed = FALSE
	not_in_mousetraps = TRUE
	var/old_light_grenade = 0
	var/destination

	New()
		..()
		#ifdef UPSCALED_MAP
		destination = locate(40 * 2,19 * 2,2)
		#else
		destination = locate(40,19,2)
		#endif

	primed
		armed = TRUE

	old
		old_light_grenade = 1

		primed
			armed = TRUE

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (BOUNDS_DIST(user, target) == 0 || (!isturf(target) && !isturf(target.loc)) || !isturf(user.loc))
			return
		if (istype(target, /obj/item/storage)) return ..()
		if (!src.armed && user)
			message_admins("Grenade ([src]) primed at [log_loc(src)] by [key_name(user)].")
			logTheThing(LOG_COMBAT, user, "primes a grenade ([src.type]) at [log_loc(user)].")
			boutput(user, "<span class='alert'>You pull the pin on [src]. You're not sure what that did, but you throw it anyway.</span>")
			src.armed = TRUE
			src.add_fingerprint(user)
			user.drop_item()
			src.throw_at(get_turf(target), 10, 3)
		return

	attack_self(mob/user as mob)
		if (!isturf(user.loc))
			return
		if (!src.armed && user)
			message_admins("Grenade ([src]) primed at [log_loc(src)] by [key_name(user)].")
			logTheThing(LOG_COMBAT, user, "primes a grenade ([src.type]) at [log_loc(user)].")
			boutput(user, "<span class='alert'>You pull the pin on [src]. You're not sure what that did. Maybe you should throw it?</span>")
			src.armed = TRUE
		return

	attack_hand(mob/user)
		if (!src.armed)
			..()
		else
			SPAWN(0.1 SECONDS)
				playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)
				if (old_light_grenade)
					for (var/obj/item/W in user)
						if (istype(W,/obj/item/clothing))
							user.u_equip(W)
							if (W)
								W.set_loc(user.loc)
								W.dropped(user)
								W.layer = initial(user.layer)
						else if (istype(W,/obj/item/old_grenade/light_gimmick))
							user.u_equip(W)
							if (W)
								W.set_loc(user.loc)
								W.dropped(user)
								W.layer = HUD_LAYER
						else
							qdel(W)
				else if (!issilicon(user)) //borgs could drop all their tools/internal items trying to pull one
					user.unequip_all()

				for (var/mob/N in viewers(user, null))
					if (GET_DIST(N, user) <= 6)
						N.flash(3 SECONDS)
				sleep(0.2 SECONDS)
				if (old_light_grenade)
					random_brute_damage(user, 200)
					sleep(1 DECI SECOND)
					if (isdead(user) || user.nodamage || isAI(user)) return
					logTheThing(LOG_COMBAT, user, "was killed by touching a [src] at [log_loc(src)].")
					if(user.client)
						var/mob/dead/observer/newmob
						newmob = new/mob/dead/observer(user)
						user.client.mob = newmob
						user.mind.transfer_to(newmob)
					qdel(user)
				else
					logTheThing(LOG_COMBAT, user, "was teleported by touching [src] ([src.type]) at [log_loc(src)].")
					if (destination)
						user.set_loc(destination)
					else
						user.set_loc(locate(40,19,2))
		return

	attackby(obj/item/W, mob/user)
		return

////////////////////////// Gimmick bombs /////////////////////////////////

/obj/item/gimmickbomb/
	name = "Don't spawn this directly!"
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = ""
	var/armed = FALSE
	var/sound_explode = 'sound/effects/Explosion2.ogg'
	var/sound_beep = 'sound/machines/twobeep.ogg'
	var/is_dangerous = TRUE

	proc/detonate()
		playsound(src.loc, sound_explode, 45, 1)

		var/obj/effects/explosion/E = new /obj/effects/explosion(src.loc)
		E.fingerprintslast = src.fingerprintslast

		invisibility = INVIS_ALWAYS_ISH
		SPAWN(15 SECONDS)
			qdel (src)

	proc/beep(i)
		var/k = i/2
		sleep(k*k)
		flick(icon_state+"_beep", src)
		src.playbeep(src.loc, i, src.sound_beep)
		if(i>=0)
			src.beep(i-1)
		else
			src.detonate()

	proc/logGrenade(mob/user)
		var/area/A = get_area(src)
		if(!A.dont_log_combat && user)
			if(is_dangerous)
				message_admins("Grenade ([src]) primed at [log_loc(src)] by [key_name(user)].")
			logTheThing(LOG_COMBAT, user, "primes a grenade ([src.type]) at [log_loc(user)].")

	proc/arm(mob/usr as mob)
		usr.show_message("<span class='alert'><B>You have armed the [src.name]!</span>")
		for(var/mob/O in viewers(usr))
			if (O.client)
				O.show_message("<span class='alert'><B>[usr] has armed the [src.name]! Run!</B></span>", 1)

		SPAWN(0)
			src.beep(10)

	proc/playbeep(var/atom/source, i as num, sound)
		var/soundin = sound
		var/vol = 40

		var/sound/S = sound(soundin)
		S.frequency = 32000 + ((10-i)*4000)
		S.wait = 0 //No queue
		S.channel = 0 //Any channel
		S.volume = vol
		S.priority = 0

		for (var/mob/M in range(world.view, source))
			if (M.client)
				if(isturf(source))
					var/dx = source.x - M.x
					S.pan = clamp(dx/8.0 * 100, -100, 100)
				M << S

	attack_self(mob/user as mob)
		if (user.equipped() == src && !src.armed)
			src.arm(user)
			logGrenade(user)
			armed = TRUE

/obj/item/gimmickbomb/owlgib
	name = "Owl Bomb"
	desc = "Owls. Owls everywhere"
	icon_state = "owlbomb"
	sound_beep = 'sound/voice/animal/hoot.ogg'

	detonate()
		for(var/mob/living/carbon/human/M in range(5, src))
			var/area/t = get_area(M)
			if(t?.sanctuary) continue
			SPAWN(0)
				M.owlgib()
		..()

/obj/item/gimmickbomb/owlclothes
	name = "Owl Bomb"
	desc = "Owls. Owls everywhere"
	icon_state = "owlbomb"
	sound_beep = 'sound/voice/animal/hoot.ogg'

	detonate()
		for(var/mob/living/carbon/human/M in range(5, src))
			var/area/t = get_area(M)
			if(t?.sanctuary) continue
			SPAWN(0)
				if (!(M.wear_mask && istype(M.wear_mask, /obj/item/clothing/mask/owl_mask)))
					for(var/obj/item/clothing/O in M)
						M.u_equip(O)
						if (O)
							O.set_loc(M.loc)
							O.dropped(M)
							O.layer = initial(O.layer)

					var/obj/item/clothing/under/gimmick/owl/owlsuit = new /obj/item/clothing/under/gimmick/owl(M)
					owlsuit.cant_self_remove = 1
					var/obj/item/clothing/mask/owl_mask/owlmask = new /obj/item/clothing/mask/owl_mask(M)
					owlmask.cant_self_remove = 1


					M.equip_if_possible(owlsuit, M.slot_w_uniform)
					M.equip_if_possible(owlmask, M.slot_wear_mask)
					M.set_clothing_icon_dirty()
		..()

/obj/item/gimmickbomb/hotdog
	name = "hotdog bomb"
	desc = "A hotdog bomb? What the heck does that even mean?!"
	icon_state = "hotdog"

	detonate()
		for(var/mob/living/carbon/human/M in range(5, src))
			var/area/t = get_area(M)
			if(t?.sanctuary) continue
			SPAWN(0)
				if (!(M.wear_suit && istype(M.wear_suit, /obj/item/clothing/suit/gimmick/hotdog)))
					for(var/obj/item/clothing/O in M)
						M.u_equip(O)
						if (O)
							O.set_loc(M.loc)
							O.dropped(M)
							O.layer = initial(O.layer)

					var/obj/item/clothing/suit/gimmick/hotdog/H = new /obj/item/clothing/suit/gimmick/hotdog(M)
					H.cant_self_remove = 1

					M.equip_if_possible(H, M.slot_wear_suit)
					M.set_clothing_icon_dirty()
		..()

/obj/item/gimmickbomb/butt
	name = "Butt Bomb"
	desc = "What a crappy grenade."
	icon_state = "fartbomb"
	sound_beep = 'sound/voice/farts/poo2.ogg'
	sound_explode = 'sound/voice/farts/superfart.ogg'
	is_dangerous = FALSE

/obj/item/gimmickbomb/gold
	name = "Gold Bomb"
	desc = "Why explode when you can gold!"
	icon_state = "banana"
	sound_beep = 'sound/machines/twobeep.ogg'

	detonate()
		for(var/turf/G in range(5, src))
			G.setMaterial(getMaterial("gold"))
		for(var/obj/item/I in range(5, src))
			I.setMaterial(getMaterial("gold"))
		for(var/obj/machinery/T in range(5, src))
			T.setMaterial(getMaterial("gold"))
		for(var/mob/living/carbon/human/M in range(3, src))
			var/area/t = get_area(M)
			if(t?.sanctuary) continue
			SPAWN(0)
				M.become_statue(getMaterial("gold"))
		..()


/obj/item/gimmickbomb/butt/prearmed
	armed = TRUE
	anchored = ANCHORED

	New()
		SPAWN(0)
			src.beep(10)
		return ..()

/obj/item/gimmickbomb/owlgib/prearmed
	armed = TRUE
	anchored = ANCHORED

	New()
		SPAWN(0)
			src.beep(10)
		return ..()

/obj/item/gimmickbomb/owlclothes/prearmed
	armed = TRUE
	anchored = ANCHORED

	New()
		SPAWN(0)
			src.beep(10)
		return ..()

//dummy type for compile
/obj/item/gimmickbomb/grenyanda/inert

/////////////////////////////// Fireworks ///////////////////////////////////////

/obj/item/firework
	name = "firework"
	desc = "A consumer-grade pyrotechnic, often used in celebrations."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "firework"
	opacity = 0
	density = 0
	anchored = UNANCHORED
	force = 1
	throwforce = 1
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	var/det_time = 20
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 5
	var/slashed = FALSE // has it been emptied out? if so, better dud!
	var/primer_burnt = FALSE // avoid priming a firework multiple times, that doesn't make sense!
	var/primed = FALSE // cutting open lit fireworks is a BAD idea
	var/bootleg_level = 0 // 0 = normal, 1 = unstable, 2 = unstable and you arm fall off

	New()
		..()
		create_reagents(10)
		reagents.add_reagent("magnesium", 10)

	afterattack(atom/target as mob|obj|turf, mob/user as mob)
		if (user.equipped() == src)
			if (src.primer_burnt)
				boutput(user, "<span class='alert'>You accidentally strike the primer, but it's already burnt!</span>")
				return

			else if (src.slashed)
				boutput(user, "<span class='alert'>You accidentally prime the firework! [det_time/10] seconds!</span>")
				SPAWN( src.det_time )
					boutput(user, "<span class='alert'>The firework probably should have exploded by now.</span>")
					src.primer_burnt = TRUE
					return

			else if (user.bioHolder.HasEffect("clumsy"))
				boutput(user, "<span class='alert'>Huh? How does this thing work?!</span>")
				src.primed = TRUE
				SPAWN( 5 )
					boom(user)
					return

			else
				boutput(user, "<span class='alert'>You accidentally prime the firework! [det_time/10] seconds!</span>")
				src.primed = TRUE
				SPAWN( src.det_time )
					boom(user)
					return

	proc/boom(mob/user as mob)
		var/turf/location = get_turf(src.loc)

		if(location)
			if((prob(10)) || (src.bootleg_level == 2))
				explosion(src, location, 0, 0, 1, 1)

				if ((src.bootleg_level == 2) && (ishuman(user)))
					var/mob/living/carbon/human/H = user
					H.sever_limb(H.hand == LEFT_HAND ? "l_arm" : "r_arm") // copied from weapon_racks.dm

			else
				elecflash(src,power = 2)

				if (src.bootleg_level == 0)
					playsound(src.loc, 'sound/effects/Explosion1.ogg', 75, 1)
				else
					playsound(src.loc, 'sound/effects/Explosion2.ogg', 75, 1)

		src.visible_message("<span class='alert'>\The [src] explodes!</span>")

		qdel(src)

	attack_self(mob/user as mob)
		if (user.equipped() == src)
			if (src.primer_burnt)
				boutput(user, "<span class='alert'>You can't light a firework more than once!</span>")
				return

			else if (src.slashed)
				boutput(user, "<span class='alert'>You prime the firework! [det_time/10] seconds!</span>")
				SPAWN( src.det_time )
					boutput(user, "<span class='alert'>The firework probably should have exploded by now. Fuck.</span>")
					src.primer_burnt = TRUE
					return

			else if (user.bioHolder.HasEffect("clumsy"))
				boutput(user, "<span class='alert'>Huh? How does this thing work?!</span>")
				src.primed = TRUE
				SPAWN( 5 )
					boom(user)
					return

			else
				boutput(user, "<span class='alert'>You prime the firework! [det_time/10] seconds!</span>")
				src.primed = TRUE
				SPAWN( src.det_time )
					boom(user)
					return

	attackby(obj/A, mob/user) // adapted from iv_drips.dm
		if (iscuttingtool(A) && !(src.slashed) && !(src.primed))
			boutput(user, "You carefully cut [src] open and dump out the contents.")
			src.slashed = TRUE
			src.name = "empty [src.name]" // its empty now!
			src.desc = "[src.desc] It has been cut open and emptied out."

			make_cleanable(/obj/decal/cleanable/magnesiumpile, get_turf(src.loc)) // create magnesium pile
			src.reagents.clear_reagents() // remove magnesium from firework
			return

		else if (iscuttingtool(A) && !(src.slashed) && (src.primed)) // cutting open a lit firework is a bad idea!
			boutput(user, "<span class='alert'>You cut open [src], but the lit primer ignites the contents!</span>")
			boom(user)
			return

		else if (iscuttingtool(A) && (src.slashed))
			boutput(user, "[src] has already been cut open and emptied.")
			return

/obj/item/firework/bootleg
	name = "bootleg firework"
	desc = "A consumer-grade pyrotechnic, often used in celebrations. This one seems to be missing a label, weird."

	New()
		..()
		create_reagents(10)

		if (prob(30))
			reagents.add_reagent("flashpowder", 5) // must've been a mix-up!

			if (prob(15))
				reagents.add_reagent("blackpowder", 5) // thats one hell of a mix-up
				src.bootleg_level = 2
			else
				reagents.add_reagent("flashpowder", 5) // this way every firework has 10u reagents
				src.bootleg_level = 1

		else
			reagents.add_reagent("magnesium", 10)

	afterattack(atom/target as mob|obj|turf, mob/user as mob)
		if (src.bootleg_level > 0)
			boutput(user, "<span class='alert'>You accidentally prime the firework, and the contents ignite immediately!</span>")
			boom(user)
			return

		..()

	attack_self(mob/user as mob)
		if (src.bootleg_level > 0)
			boutput(user, "<span class='alert'>You try to prime the firework, but the contents ignite immediately!</span>")
			boom(user)
			return

		..()

	attackby(obj/A, mob/user) // adapted from iv_drips.dm
		if (iscuttingtool(A) && !(src.slashed) && (src.bootleg_level > 0))
			boutput(user, "You try to cut [src] open, but the contents spontaneously ignite!")
			boom(user)
			return

		..()

//////////////////////// Breaching charges //////////////////////////////////

/obj/item/breaching_charge
	name = "Breaching Charge"
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "bcharge"
	var/armed = FALSE
	var/det_time = 50
	w_class = W_CLASS_SMALL
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT
	var/expl_devas = 0
	var/expl_heavy = 0
	var/expl_light = 1
	var/expl_flash = 2
	var/expl_range = 1
	desc = "A timed device that releases a relatively strong concussive force, strong enough to destroy rock and metal."
	stamina_damage = 1
	stamina_cost = 1
	stamina_crit_chance = 0

	attack_hand(var/mob/user)
		if (src.armed)
			boutput(user, "<span class='alert'>\The [src] is firmly anchored into place!</span>")
			return
		return ..()

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (user.equipped() == src)
			if (!src.armed)
				if (!src.check_placeable_target(target))
					return
				if (user.bioHolder && user.bioHolder.HasEffect("clumsy"))
					boutput(user, "<span class='alert'>Huh? How does this thing work?!</span>")
					var/area/A = get_area(src)
					if(!A.dont_log_combat)
						logTheThing(LOG_COMBAT, user, "accidentally triggers [src] (clumsy bioeffect) at [log_loc(user)].")
					SPAWN(0.5 SECONDS)
						user.u_equip(src)
						src.boom()
						return
				else
					boutput(user, "<span class='alert'>You slap the charge on [target], [det_time/10] seconds!</span>")
					user.visible_message("<span class='alert'>[user] has attached [src] to [target].</span>")
					src.icon_state = "bcharge2"
					user.u_equip(src)
					src.set_loc(get_turf(target))
					src.anchored = ANCHORED
					src.armed = TRUE

					// Yes, please (Convair880).
					var/area/A = get_area(src)
					if(!A.dont_log_combat)
						logTheThing(LOG_COMBAT, user, "attaches a [src] to [target] at [log_loc(target)].")

					SPAWN(src.det_time)
						if (src)
							src.boom()
							if (target)
								if (istype(target, /obj/machinery))
									target.ex_act(1) // Reliably blasts through doors.
						return
		return

	proc/boom()
		if (!src || !istype(src))
			return

		var/turf/location = get_turf(src)
		if (location && istype(location) && !location.loc:sanctuary)
			if (isrestrictedz(location.z))
				src.visible_message("<span class='alert'>[src] buzzes for a moment, then self-destructs.</span>")
				elecflash(location)
				qdel(src)
				return

			location.hotspot_expose(700, 125)

			//Explosive effect for breaching charges only
			if (!(istype(src, /obj/item/breaching_charge/mining)))
				// NT charge shake
				if (expl_heavy)
					for(var/client/C in clients)
						if(C.mob && (C.mob.z == src.z))
							shake_camera(C.mob, 8, 24) // remove if this is too laggy
							playsound(C.mob, explosions.distant_sound, 70, 0)
							new /obj/effects/explosion (src.loc)
				else
					playsound(src.loc, pick(sounds_explosion), 75, 1)
					new/obj/effect/supplyexplosion(src.loc)
			else
				playsound(src.loc, 'sound/weapons/flashbang.ogg', 50, 1)

			explosion(src, location, src.expl_devas, src.expl_heavy, src.expl_light, src.expl_flash)
			// Breaching charges should be, you know, actually be decent at breaching walls and windows (Convair880).
			for (var/turf/simulated/wall/W in range(src.expl_range, location))
				if (W && istype(W) && !location.loc:sanctuary)
					W.ReplaceWithFloor()
			for (var/obj/structure/girder/G in range(src.expl_range, location))
				var/area/a = get_area(G)
				if (G && istype(G) && !a.sanctuary)
					qdel(G)
			for (var/obj/window/WD in range(src.expl_range, location))
				var/area/a = get_area(WD)
				if (WD && istype(WD) && prob(max(0, 100 - (WD.health / 3))) && !a.sanctuary)
					WD.smash()
			for (var/obj/grille/GR in range(src.expl_range, location))
				var/area/a = get_area(GR)
				if (GR && istype(GR) && GR.ruined != 1 && !a.sanctuary)
					GR.ex_act(2)

		qdel(src)
		return

	proc/check_placeable_target(atom/A)
		if (!istype(A, /obj/item))
			return TRUE
		if (istype(A, /obj/item/storage)) // no blowing yourself up if you have full backpack
			return FALSE
		return A.density

/obj/item/breaching_charge/NT
	name = "NanoTrasen Experimental EDF-7 Breaching Charge"
	expl_devas = 0
	expl_heavy = 1
	expl_light = 4
	expl_flash = 10
	expl_range = 2
	stamina_damage = 1
	stamina_cost = 1
	stamina_crit_chance = 0

/obj/item/breaching_charge/thermite
	name = "Thermite Breaching Charge"
	desc = "When applied to a wall, causes a thermite reaction which totally destroys it."
	c_flags = ONBELT
	object_flags = NO_GHOSTCRITTER
	w_class = W_CLASS_TINY
	expl_range = 2

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (user.equipped() == src)
			if (!src.armed)
				if (!src.check_placeable_target(target))
					return
				if (user.bioHolder && user.bioHolder.HasEffect("clumsy"))
					boutput(user, "<span class='alert'>Huh? How does this thing work?!</span>")
					var/area/A = get_area(src)
					if(!A.dont_log_combat)
						logTheThing(LOG_COMBAT, user, "accidentally triggers [src] (clumsy bioeffect) at [log_loc(user)].")
					SPAWN(0.5 SECONDS)
						user.u_equip(src)
						src.boom()
						return
				else
					boutput(user, "<span class='alert'>You slap the charge on [target], [det_time/10] seconds!</span>")
					user.visible_message("<span class='alert'>[user] has attached [src] to [target].</span>")
					src.icon_state = "bcharge2"
					user.u_equip(src)
					src.set_loc(get_turf(target))
					src.anchored = ANCHORED
					src.armed = TRUE

					// Yes, please (Convair880).
					var/area/A = get_area(src)
					if(!A.dont_log_combat)
						logTheThing(LOG_COMBAT, user, "attaches a [src] to [target] at [log_loc(target)].")

					SPAWN(src.det_time)
						if (src)
							src.boom()
		return

	boom()
		if (!src || !istype(src))
			return

		var/turf/location = get_turf(src.loc)
		if (location && istype(location))
			if (isrestrictedz(location.z))
				src.visible_message("<span class='alert'>[src] buzzes for a moment, then self-destructs.</span>")
				elecflash(location)
				qdel(src)
				return

			playsound(location, 'sound/effects/bamf.ogg', 100, 0.5)
			src.invisibility = INVIS_ALWAYS

			for (var/turf/T in range(src.expl_range, location))
				if( T?.loc:sanctuary ) continue
				if (!istype(T, /turf/simulated/wall) && !istype(T, /turf/simulated/floor))
					continue

				T.hotspot_expose(2000, 125)

				var/obj/overlay/O = new/obj/overlay(T)
				O.name = "Thermite"
				O.desc = "A searing wall of flames."
				O.icon = 'icons/effects/fire.dmi'
				O.anchored = ANCHORED
				O.layer = TURF_EFFECTS_LAYER
				O.color = "#ff9a3a"
				var/datum/light/point/light = new
				light.set_brightness(1)
				light.set_color(0.5, 0.3, 0.0)
				light.attach(O)

				if (istype(T,/turf/simulated/wall))
					O.set_density(1)
				else
					O.set_density(0)

				var/distance = GET_DIST(T, location)
				if (distance < 2)
					var/turf/simulated/floor/F = null

					if (istype(T, /turf/simulated/wall/auto/feather))
						var/turf/simulated/wall/auto/feather/flockwall = T
						flockwall.takeDamage("fire", 1)
						O.icon_state = "2"
						if (flockwall.health <= 0)
							flockwall.destroy()
					else if (istype(T, /turf/simulated/wall))
						var/turf/simulated/wall/W = T
						F = W.ReplaceWithFloor()
					else if (istype(T, /turf/simulated/floor/))
						F = T

					if (F && istype(F))
						F.to_plating()
						F.burn_tile()
						O.icon_state = "2"
				else
					O.icon_state = "1"
					if (istype(T, /turf/simulated/floor))
						var/turf/simulated/floor/F = T
						F.burn_tile()

			for (var/obj/machinery/door/DR in src.loc)
				var/area/a = get_area(DR)
				if (!DR.cant_emag && !a.sanctuary)
					DR.take_damage(DR.health)
			for (var/obj/structure/girder/G in range(src.expl_range, location))
				var/area/a = get_area(G)
				if (G && istype(G) && !a.sanctuary)
					qdel(G)
			for (var/obj/window/W in range(src.expl_range, location))
				var/area/a = get_area(W)
				if (W && istype(W) && !a.sanctuary)
					W.damage_heat(500)
			for (var/obj/grille/GR in range(src.expl_range, location))
				var/area/a = get_area(GR)
				if (GR && istype(GR) && GR.ruined != 1 && !a.sanctuary)
					GR.damage_heat(500)

			for (var/mob/living/M in range(src.expl_range, location))
				if(check_target_immunity(M)) continue
				var/damage = 30 / (GET_DIST(M, src) + 1)
				M.TakeDamage("chest", 0, damage)
				M.update_burning(damage)

			SPAWN(10 SECONDS)
				if (src)
					for (var/obj/overlay/O in range(src.expl_range, location))
						if (O.name == "Thermite")
							qdel(O)
					qdel(src)
		else
			qdel(src)

		return

//////////////////////////////////////////
// PIPE BOMBS (INCLUDES CONSTRUCTION)
//////////////////////////////////////////

/obj/item/pipebomb
	icon = 'icons/obj/items/assemblies.dmi'
	item_state = "r_hands"
	duration_put = 0.5 SECONDS //crime

/obj/item/pipebomb/frame
	name = "pipe frame"
	desc = "Two small pipes joined together with grooves cut into the side."
	icon_state = "Pipe_Frame"
	burn_possible = 0
	material_amt = 0.3
	var/state = 1
	var/strength = 5
	var/list/item_mods = new/list() //stuff something into one or both of the pipes to change the finished product
	var/list/allowed_items = list("/obj/item/device/light/glowstick","/obj/item/clothing/head/butt", "/obj/item/paper", "/obj/item/reagent_containers/food/snacks/ingredient/meat",\
	 							"/obj/item/reagent_containers/food/snacks/ectoplasm", "/obj/item/scrap", "/obj/item/raw_material/scrap_metal", "/obj/item/cell","/obj/item/cable_coil",\
	 							"/obj/item/item_box/medical_patches", "/obj/item/item_box/gold_star", "/obj/item/item_box/assorted/stickers", "/obj/item/material_piece/cloth",\
	 							"/obj/item/raw_material/shard", "/obj/item/raw_material/telecrystal", "/obj/item/instrument", "/obj/item/reagent_containers/food/snacks/ingredient/butter",\
	 							"/obj/item/rcd_ammo")

	attack_self(mob/user as mob)
		if (state == 3)
			if(tgui_alert(user, "Pour out the pipebomb reagents?", "Empty reagents", list("Yes", "No")) != "Yes")
				return
			boutput(user, "<span class='notice'>The reagents inside spill out!</span>")
			src.reagents = null
			state = 2
		return

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/pipebomb/frame))
			var/obj/item/pipebomb/frame/other_frame = W
			if((src.state + other_frame.state == 3)) // one of pipes is welded, other one is not
				user.u_equip(src)
				user.u_equip(W)
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				var/obj/item/gun/kinetic/slamgun/S = new/obj/item/gun/kinetic/slamgun
				user.put_in_hand_or_drop(S)
				qdel(W)
				qdel(src)

		if(isweldingtool(W) && src.state == 1)
			if(!W:try_weld(user, 1))
				return
			boutput(user, "<span class='notice'>You hollow out the pipe.</span>")
			src.state = 2
			icon_state = "Pipe_Hollow"
			desc = "Two small pipes joined together. The pipes are empty."

			if (material)
				name = "hollow [src.material.name] pipe frame"
			else
				name = "hollow pipe frame"
			src.flags |= NOSPLASH

		if(issnippingtool(W) && src.state == 2) //pipeshot crafting
			name = "hollow pipe hulls"
			boutput(user, "<span class='notice'>You cut the pipe into four neat hulls.</span>")
			src.state = 5
			icon_state = "Pipeshot"
			desc = "Four open pipe shells. They're currently empty."

		if (allowed_items.len && item_mods.len < 3 && src.state == 2)
			var/ok = 0
			for (var/A in allowed_items)
				if (istype(W, text2path(A) )) ok = 1
			if (ok)
				boutput(user, "<span class='notice'>You stuff [W] into the [item_mods.len == 0 ? "first" : "second"] pipe.</span>")
				item_mods += W
				user.u_equip(W)
				W.set_loc(src)

		if(istype(W, /obj/item/reagent_containers/) && src.state == 2)
			var/ok = 0
			for (var/A in allowed_items)
				if (istype(W, text2path(A) )) ok = 1
			if (!ok)
				//There is less room for explosive material when you use item mods
				var/max_allowed = 20 - item_mods.len * 5
				src.state = 3
				var/avg_volatility = 0
				src.reagents = new /datum/reagents(max_allowed)
				src.reagents.my_atom = src
				W.reagents.trans_to(src, max_allowed)
				boutput(user, "<span class='notice'>You fill the pipe with [src.reagents.total_volume] units of the reagents.</span>")
				for (var/id in src.reagents.reagent_list)
					var/datum/reagent/R = src.reagents.reagent_list[id]
					avg_volatility += R.volatility * R.volume / src.reagents.maximum_volume

				qdel(src.reagents)
				src.reagents = null
				if (avg_volatility < 1) // B A D.
					src.strength = 0
				else
					src.strength *= avg_volatility
					src.strength -= item_mods.len * 0.5 //weakened by having mods

				icon_state = "Pipe_Filled"
				src.state = 3
				desc = "Two small pipes joined together. The pipes are filled."

				if (material)
					name = "filled [src.material.name] pipe frame"
				else
					name = "filled pipe frame"

		if(istype(W, /obj/item/reagent_containers/) && src.state == 5) //pipeshot crafting cont'd
			var/amount = 20
			var/avg_volatility = 0

			for (var/id in W.reagents.reagent_list)
				var/datum/reagent/R = W.reagents.reagent_list[id]
				avg_volatility += R.volatility
			avg_volatility /= W.reagents.reagent_list.len

			if (avg_volatility < 1) // invalid ingredients/concentration
				boutput(user, "<span class='notice'>You realize that the contents of [W] aren't actually all too explosive and decide not to pour it into the [src].</span>")
			else
				//consume the reagents
				src.reagents = new /datum/reagents(amount)
				src.reagents.my_atom = src
				W.reagents.trans_to(src, amount)
				qdel(src.reagents)
				//make the hulls
				boutput(user, "<span class='notice'>You add some propellant to the hulls.</span>")
				new /obj/item/assembly/pipehulls(get_turf(src))
				qdel(src)

		if(istype(W, /obj/item/cable_coil) && src.state == 3)
			boutput(user, "<span class='notice'>You link the cable, fuel and pipes.</span>")
			src.state = 4
			icon_state = "Pipe_Wired"

			if (material)
				name = "[src.material.name] pipe bomb frame"
			else
				name = "pipe bomb frame"

			desc = "Two small pipes joined together, filled with explosives and connected with a cable. It needs some kind of ignition switch."
			src.flags &= ~NOSPLASH

		if(istype(W, /obj/item/assembly/time_ignite) && src.state == 4)
			boutput(user, "<span class='notice'>You connect the cable to the timer/igniter assembly.</span>")
			var/turf/T = get_turf(src)
			var/obj/item/pipebomb/bomb/A = new /obj/item/pipebomb/bomb(T)
			A.strength = src.strength
			if (material)
				A.setMaterial(src.material)
				src.material = null

			//add properties from item mods to the finished pipe bomb
			for (var/M in item_mods)
				for (var/I in allowed_items)
					if (istype(M, text2path(I) ))
						A.name = "modified pipe bomb"
						if (istype(M, /obj/item/device/light/glowstick))
							A.glowsticks += 1
						if (istype(M, /obj/item/clothing/head/butt))
							A.butt += 1
						if (istype(M, /obj/item/paper))
							A.confetti += 1
						if (istype(M, /obj/item/reagent_containers/food/snacks/ingredient/meat))
							A.meat += 1
						if (istype(M, /obj/item/reagent_containers/food/snacks/ectoplasm))
							A.ghost += 1
						if (istype(M, /obj/item/scrap) || istype(M,/obj/item/raw_material/scrap_metal))
							A.extra_shrapnel += 1
						if (istype(M,/obj/item/cable_coil))
							A.cable += 1
						if (istype(M, /obj/item/cell))
							var/obj/item/cell/C = M
							A.charge += C.charge
							if (C.rigged || istype(M, /obj/item/cell/erebite))
								A.strength += 3
						if (istype(M, /obj/item/material_piece/cloth))
							A.strength = src.strength / 5
						if (istype(M, /obj/item/raw_material/shard))
							var/obj/item/raw_material/shard/S = M // fix for duplication glitch because someone may have forgot to assign M to S, whoops!
							A.bleed += 1
							if (S && (S.material.hasProperty("hard") || istype(S, /obj/item/raw_material/shard/plasmacrystal)))
								A.bleed += 1
						if (istype(M, /obj/item/raw_material/telecrystal))
							A.tele += 1
						if (istype(M, /obj/item/instrument))
							var/obj/item/instrument/R = M
							A.sound_effect = islist(R.sounds_instrument) ? pick(R.sounds_instrument) : R.sounds_instrument
						if (istype(M, /obj/item/reagent_containers/food/snacks/ingredient/butter))
							if (!A.reagents)
								var/datum/reagents/R = new/datum/reagents(20)
								A.reagents = R
							A.reagents.add_reagent("water", 5)
						if (istype(M, /obj/item/rcd_ammo))
							A.rcd += 1
							if (istype(M, /obj/item/rcd_ammo/big))
								A.rcd += 1
						if (istype(M, /obj/item/item_box/medical_patches) || istype(M,/obj/item/item_box/gold_star))
							var/obj/item/item_box/B = M
							A.throw_objs += B.contained_item
						if (istype(M, /obj/item/item_box/assorted/stickers))
							var/obj/item/item_box/assorted/B = M
							A.throw_objs += B.contained_items
						if (istype(M, /obj/item/material_piece/plasmastone) || istype(M, /obj/item/raw_material/plasmastone))
							A.plasma += 1
			user.u_equip(W)
			qdel(W)
			qdel(src)
		else
			..()
			return

ADMIN_INTERACT_PROCS(/obj/item/pipebomb/bomb, proc/arm)
/obj/item/pipebomb/bomb
	name = "pipe bomb"
	desc = "An improvised explosive made primarily out of two pipes."
	icon_state = "Pipe_Timed"
	contraband = 4

	var/strength = 5
	var/armed = FALSE
	var/is_dangerous = TRUE

	var/glowsticks = 0
	var/butt = 0
	var/confetti = 0
	var/meat = 0
	var/ghost = 0
	var/extra_shrapnel = 0
	var/charge = 0
	var/cable = 0
	var/bleed = 0
	var/tele = 0
	var/sound_effect = 0
	var/rcd = 0
	var/plasma = 0
	var/rcd_mat = "steel"
	//if it contains reagents, those will be splashed on the floor

	var/list/throw_objs = new /list()

	attack_self(mob/user)
		if (src.armed)
			return
		src.arm(user)

	proc/arm(mob/user)
		boutput(user, "<span class='alert'>You activate the pipe bomb! 5 seconds!</span>")
		armed = TRUE
		var/area/A = get_area(src)
		if(!A.dont_log_combat && user)
			if(is_dangerous)
				message_admins("[key_name(user || usr)] arms a [src.name] (power [strength]) at [log_loc(src)] by [key_name(user)].")
			logTheThing(LOG_COMBAT, user, "arms a [src.name] (power [strength]) at [log_loc(src)])")

		if (sound_effect)
			SPAWN(4 SECONDS) //you can use a sound effect to hold a bomb in hand and throw it at the very last moment!
				playsound(src, sound_effect, 50, 1)
		SPAWN(5 SECONDS)
			do_explode()

	ex_act(severity)
		do_explode()
		. = ..()

	proc/do_explode()
		if (src.strength)
			if (src.material)
				var/strength_mult = 1
				if (findtext(material.mat_id, "erebite"))
					strength_mult = 2
				else if (findtext(material.mat_id, "plasmastone"))
					strength_mult = 1.25
				src.strength *= strength_mult

			//do mod effects : pre-explosion
			if (glowsticks)
				var/turf/T = get_turf(src.loc)
				make_cleanable( /obj/decal/cleanable/generic,T)
				for (var/turf/splat in view(1,src.loc))
					make_cleanable( /obj/decal/cleanable/greenglow,splat)
				var/radium_amt = 6 * glowsticks
				for (var/mob/M in view(3,src.loc))
					if(iscarbon(M))
						if (M.reagents)
							M.reagents.add_reagent("radium", radium_amt, null, T0C + 300)
					boutput(M, "<span class='alert'>You are splashed with hot green liquid!</span>")
			if (butt)
				if (butt > 1)
					playsound(src.loc, 'sound/voice/farts/superfart.ogg', 90, 1, channel=VOLUME_CHANNEL_EMOTE)
					for (var/mob/M in view(3+butt,src.loc))
						ass_explosion(M, 0, 5)
				else
					playsound(src.loc, 'sound/voice/farts/poo2.ogg', 90, 1, channel=VOLUME_CHANNEL_EMOTE)
					for (var/mob/M in view(3,src.loc))
						ass_explosion(M, 0, 5)
			if (confetti)
				if (confetti > 1)
					particleMaster.SpawnSystem(new /datum/particleSystem/confetti_more(src.loc))
				else
					particleMaster.SpawnSystem(new /datum/particleSystem/confetti(src.loc))
			if (meat)
				if (meat > 1)
					gibs(src.loc)
				for (var/turf/splat in view(meat,src.loc))
					make_cleanable( /obj/decal/cleanable/blood,splat)
			if (ghost) //throw objects towards bomb center
				var/turf/T = get_turf(src.loc)
				if (ghost > 1)
					for (var/mob/M in view(2+ghost,src.loc))
						if(iscarbon(M))
							boutput(M, "<span class='alert'>You are yanked by an unseen force!</span>")
							var/yank_distance = 1
							if (prob(50))
								yank_distance = 2
							M.throw_at(T, yank_distance, 2)
				for (var/obj/O in view(1,src.loc))
					O.throw_at(T, 2, 2)
			if (extra_shrapnel)
				throw_shrapnel(get_turf(src.loc), 4, extra_shrapnel * 3)
			if (cable && charge) //arc flash
				var/target_count = 0
				for (var/mob/living/L in view(5, src.loc))
					target_count++
				if (target_count)
					for (var/mob/living/L in oview(5, src.loc))
						arcFlash(src, L, max((charge*7) / target_count, 1))
				else
					for (var/turf/T in oview(3,src.loc))
						if (prob(2))
							arcFlashTurf(src, T, max((charge*6) * rand(),1))
			if (bleed)
				for (var/mob/M in view(3,src.loc))
					take_bleeding_damage(M, null, bleed * 3, DAMAGE_CUT)
			if (src.reagents)
				for (var/turf/T in oview(1+ round(src.reagents.total_volume * 0.12),src.loc) )
					src.reagents.reaction(T,1,5)

			src.blowthefuckup(src.strength, 0)

			//do mod effects : post-explosion
			if (tele)
				for (var/mob/M in view(2+tele,src.loc))
					if(isturf(M.loc) && !isrestrictedz(M.loc.z))
						var/turf/warp_to = get_turf(pick(orange(3 + tele, M.loc)))
						if (isturf(warp_to))
							playsound(M.loc, "warp", 50, 1)
							M.visible_message("<span class='alert'>[M] is warped away!</span>")
							boutput(M, "<span class='alert'>You suddenly teleport ...</span>")
							M.set_loc(warp_to)
			if (rcd)
				playsound(src, 'sound/items/Deconstruct.ogg', 70, 1)
				for (var/turf/T in view(rcd,src.loc))
					if (istype(T, /turf/space))
						var/turf/simulated/floor/F = T:ReplaceWithFloor()
						F.setMaterial(getMaterial(rcd_mat))
				if (rcd > 1)
					for (var/turf/T in view(3,src.loc))
						if (prob(rcd * 10))
							new /obj/grille/steel(T)

			if (plasma)
				for (var/turf/simulated/floor/target in range(1,src.loc))
					if(!target.gas_impermeable && target.air)
						if(target.parent?.group_processing)
							target.parent.suspend_group_processing()

						var/datum/gas_mixture/payload = new /datum/gas_mixture
						payload.toxins = plasma * 100
						payload.temperature = T20C
						payload.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
						target.air.merge(payload)

			if (throw_objs.len && throw_objs.len > 0)
				var/turf/T = get_turf(src.loc)
				var/count = 20
				var/obj/spawn_item
				for (var/mob/living/L in oview(5, src.loc))
					spawn_item = pick(throw_objs)
					var/obj/O = new spawn_item(T)
					if (istype(O,/obj/item/reagent_containers/patch))
						var/obj/item/reagent_containers/patch/P = O
						P.good_throw = 1
					O.throw_at(L,5,3)
					count--
				if (count > 0)
					for (var/turf/target in oview(4,src.loc))
						if (prob(4))
							spawn_item = pick(throw_objs)
							var/obj/O = new spawn_item(T)
							if (istype(O,/obj/item/reagent_containers/patch))
								var/obj/item/reagent_containers/patch/P = O
								P.good_throw = 1
							O.throw_at(target,4,3)
							count--
						if (count <= 0)
							break;

			qdel(src)
		else
			visible_message("<span class='alert'>[src] sparks and emits a small cloud of smoke, crumbling into a pile of dust.</span>")
			qdel(src)

/obj/item/pipebomb/bomb/syndicate
	name = "pipe bomb"
	desc = "An improvised explosive made primarily out of two pipes." // cogwerks - changed the name
	icon_state = "Pipe_Timed"
	strength = 32

/obj/item/pipebomb/bomb/miniature_syndicate
	name = "pipe bomb"
	desc = "This pipe bomb seems funny. You can hear muffled tiny screams inside."
	icon_state = "Pipe_Timed"
	strength = 1
	var/how_many_miniatures = 4

	do_explode()
		for (var/i = 1, i <= how_many_miniatures, i++)
			var/obj/critter/gunbot/drone/miniature_syndie/O = new /obj/critter/gunbot/drone/miniature_syndie(get_turf(src))
			var/atom/target = get_edge_target_turf(src, pick(alldirs))
			O.throw_at(target,4,3)

		..()

/obj/item/pipebomb/bomb/engineering
	name = "controlled demolition pipe"
	desc = "A weak explosive designed to blast open holes in the sea floor."
	icon_state = "Pipe_Yellow"
	strength = 1
	is_dangerous = FALSE

	on_blowthefuckup(strength) //always blow hole!
		..(strength)
		if (istype(src.loc,/turf/space/fluid))
			var/turf/space/fluid/T = src.loc
			T.blow_hole()

/obj/effects/explosion/tiny_baby
	New()
		..()
		src.transform = matrix(0.5, MATRIX_SCALE)

/obj/proc/on_blowthefuckup(strength)
	new /obj/effects/explosion/tiny_baby (src.loc)
	if (src.material)
		src.material.triggerTemp(src, T0C + strength * 100)
		src.material.triggerExp(src, 1)

/obj/item/pipebomb/bomb/on_blowthefuckup(strength)
	..()

/obj/proc/throw_shrapnel(var/T, var/sqstrength, var/shrapnel_range)
	for (var/mob/living/carbon/human/M in view(T, shrapnel_range))
		if(check_target_immunity(M)) continue
		M.TakeDamage("chest", 15/M.get_ranged_protection(), 0)
		if (M.get_ranged_protection()>=1.5)
			boutput(M, "<span class='alert'><b>Your armor blocks the shrapnel!</b></span>")
		else
			var/obj/item/implant/projectile/shrapnel/implanted = new /obj/item/implant/projectile/shrapnel
			implanted.implanted(M, null, 25 * sqstrength)
			boutput(M, "<span class='alert'><b>You are struck by shrapnel!</b></span>")
			if (!M.stat)
				M.emote("scream")


/turf/proc/throw_shrapnel(var/T, var/sqstrength, var/shrapnel_range)
	for (var/mob/living/carbon/human/M in view(T, shrapnel_range))
		if(check_target_immunity(M)) continue
		M.TakeDamage("chest", 15/M.get_ranged_protection(), 0)
		if (M.get_ranged_protection()>=1.5)
			boutput(M, "<span class='alert'><b>Your armor blocks the shrapnel!</b></span>")
		else
			var/obj/item/implant/projectile/shrapnel/implanted = new /obj/item/implant/projectile/shrapnel
			implanted.implanted(M, null, 25 * sqstrength)
			boutput(M, "<span class='alert'><b>You are struck by shrapnel!</b></span>")
			if (!M.stat)
				M.emote("scream")






/obj/proc/blowthefuckup(var/strength = 1, var/delete = 1) // dropping this to object-level so that I can use it for other things
	var/T = get_turf(src)
	src.visible_message("<span class='alert'>[src] explodes!</span>")
	var/sqstrength = sqrt(strength)
	var/shrapnel_range = 3 + sqstrength
	if (strength >= 1)
		src.throw_shrapnel(T, sqstrength, shrapnel_range)
	on_blowthefuckup(strength)

	explosion_new(src, T, strength, 1)
	if (delete)
		qdel(src)

/mob/proc/blowthefuckup(var/strength = 1,var/visible_message = 1) // similar proc for mobs
	var/T = get_turf(src)
	if(visible_message) src.visible_message("<span class='alert'>[src] explodes!</span>")
	var/sqstrength = sqrt(strength)
	var/shrapnel_range = 3 + sqstrength
	for (var/mob/living/carbon/human/M in view(T, shrapnel_range))
		if(check_target_immunity(M)) continue
		if (M != src)
			M.TakeDamage("chest", 15/M.get_ranged_protection(), 0)
			if (M.get_ranged_protection()>=1.5)
				boutput(M, "<span class='alert'><b>Your armor blocks the chunks of [src.name]!</b></span>")
			else
				var/obj/item/implant/projectile/shrapnel/implanted = new /obj/item/implant/projectile/shrapnel
				implanted.implanted(M, null, 25 * sqstrength)
				boutput(M, "<span class='alert'><b>You are struck by chunks of [src.name]!</b></span>")
				if (!M.stat)
					M.emote("scream")

	explosion_new(src, T, strength, 1)
	src.gib()

/turf/proc/blowthefuckup(var/strength = 1, var/delete = 1) // simulate spalling damage. could use a new sprite though
	var/T = get_turf(src)
	src.visible_message("<span class='alert'>[src] explodes!</span>")
	var/sqstrength = sqrt(strength)
	var/shrapnel_range = 3 + sqstrength
	if (strength >= 1)
		src.throw_shrapnel(T, sqstrength, shrapnel_range)
	new /obj/effects/explosion/tiny_baby (src.loc)
	explosion_new(src, T, strength, 1)
	if (delete)
		qdel(src)
