/*
CONTAINS:
GRENADE PARENT
NON-CHEM GRENADES
GIMMICK BOMBS
BREACHING CHARGES
FIREWORKS
PIPE BOMBS + CONSTRUCTION
*/

////////////////////////////// Grenade parent ///////////////////////////////////////

/obj/item/grenade
	desc = "You shouldn't be able to see this!"
	name = "some kind of grenade"
	w_class = 2.0
	icon = 'icons/obj/items/grenade.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "banana"
	item_state = "banana"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT | EXTRADELAY
	is_syndicate = 0
	mats = 6
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0
	/// If this goes off in a restricted / sanctuary area, it'll just kind of peter out
	var/fizzles_in_sanctuary = FALSE

	// Grenade timer / activated settings
	/// Is the grenade armed? Don't arm the grenade if its already armed, cant put the pin back in
	var/primed = 0
	/// Time till detonation
	var/det_time = 30
	/// Base time till detonation
	var/org_det_time = 30
	/// Screwdrivered time till detonation
	var/alt_det_time = 60

	// Grenade type settings, for making them do certain things on detonation
	/// Does graviton things when it goes off
	var/is_graviton = FALSE
	/// Disorients people through loud noises
	var/is_sonic_grenade = FALSE
	/// Teleports people to the void -- if they're lucky
	var/is_light_grenade = FALSE
	/// Just outright deletes anyone who touches this
	var/old_light_grenade = 0
	/// Place where it sends people
	var/destination
	/// Type of gas grenade. Valid entries: "smoke", "mustard"
	var/is_gas_grenade = FALSE
	/// Smoke, because the effects system doesn't have a common set of procs for some goddamned reason
	var/datum/effects/system/bad_smoke_spread/smoke
	/// Mustard gas, because the effects system doesn't have a common set of procs for some goddamned reason
	var/datum/effects/system/mustard_gas_spread/mustard
	/// Makes a singularity on detonation, of course
	var/make_singulo = FALSE
	/// for singulo grenades, replaces everything in this radius with engine floors
	var/radius = 3
	/// Make an explosion
	var/is_explosive_grenade = FALSE
	/// Power of the explosion (-1, -1, -0.25, 1 = 2.25 power, 3.375 brisance!)
	var/ex_power = 2.25
	/// Brisance of the explosion
	var/ex_brisance = 3.375
	/// Owlgibs people
	var/is_owlgib_grenade = FALSE
	/// Is a firework -- set to "slashed" for it to fizzle
	var/is_firework = FALSE
	/// Will mangle walls in range
	var/is_breaching_charge = FALSE
	/// Distance from the bomb to thrash walls and such
	var/breach_range = 1
	/// Will spew thermite everywhere
	var/is_thermite_charge = FALSE
	/// Is this a pipebomb?
	var/is_pipebomb = FALSE
	/// Is this an EMP grenade?
	var/is_emp_grenade = FALSE
	/// Does this grenade force clothes on people?
	var/is_clothing_grenade = FALSE
	/// Does this grenade change the surrounding materials?
	var/is_mat_change_grenade = FALSE

	// Payload-related stuff, for making them spew things on detonation
	/// Throw the payload in random directions? Otherwise, spawn and scoot them to random adjacent tiles
	var/throw_payload_random = 1
	/// Thing to throw. Won't throw anything if null. Must be a valid path!
	var/atom/movable/payload = null
	/// Number of payload-things to make
	var/count = 0
	/// Shoots projectiles in every direction on detonation
	var/is_frag_grenade = FALSE
	/// Override the default flak projectile with something else
	var/datum/projectile/custom_projectile_type = null
	/// Number of projectiles to shoot
	var/pellets_to_fire = 20

	/// The BEEP BEEP BEEP noise it makes when activated
	var/sound_armed = null
	/// The sound it makes when it explodes
	var/sound_explode = "sound/weapons/flashbang.ogg"
	/// The sound it makes when it beeps...?
	var/sound_beep = 'sound/machines/twobeep.ogg'
	/// What it looks like when armed
	var/icon_state_armed = null
	/// Flashes between this state and the armed state
	var/icon_state_exploding = null
	/// keep out of mousetraps
	var/not_in_mousetraps = 0
	/// Makes the grenade delete itself when exploding, otherwise reset itself
	var/del_self_on_explode = TRUE
	/// Makes an explosion effect on explosion. Harmless, but pretty
	var/explode_on_detonation = FALSE
	/// Uses a sound-spam charge-up noise
	var/beepy_chargeup = FALSE
	/// Wants to do something to or with a certain atom
	var/atom/target_atom

	New()
		..()
		if(src.is_emp_grenade || src.is_gas_grenade || is_explosive_grenade)
			src.del_self_on_explode = FALSE

		if (src.is_gas_grenade && usr?.loc) //Wire: Fix for Cannot read null.loc
			switch(src.is_gas_grenade)
				if("smoke")
					src.smoke = new src.smoke
					src.smoke.attach(src)
					src.smoke.set_up(10, 0, usr.loc)
				if("mustard")
					src.mustard = new src.mustard
					src.mustard.attach(src)
					src.mustard.set_up(10, 0, usr.loc)
				else // frick it you're getting both
					src.mustard = new src.mustard
					src.mustard.attach(src)
					src.mustard.set_up(10, 0, usr.loc)

					src.smoke = new src.smoke
					src.smoke.attach(src)
					src.smoke.set_up(10, 0, usr.loc)

	attack_self(mob/user as mob)
		if(is_breaching_charge)
			boutput(user, "<span class='alert'>[src] refuses to arm while not attached to something!</span>")
			return
		if(is_light_grenade)
			if (!isturf(user.loc))
				return
			if (src.primed == 0)
				message_admins("Grenade ([src]) primed in [get_area(src)] [log_loc(src)] by [key_name(user)].")
				logTheThing("combat", user, null, "primes a grenade ([src.type]) at [log_loc(user)].")
				boutput(user, "<span class='alert'>You pull the pin on [src]. You're not sure what that did. Maybe you should throw it?</span>")
				src.primed = 1
			return
		if(is_firework && src.primed)
			boutput(user, "<span class='alert'>It's already lit! Put it down while you still have fingers!</span>")
			return
		if (!src.primed)
			src.primed = 1		//This could help for now. Should leverege the click buffer from combat stuff too.
			if (!isturf(user.loc))
				src.primed = 0
				return
			message_admins("Grenade ([src]) primed at [log_loc(src)] by [key_name(user)].")
			logTheThing("combat", user, null, "primes a grenade ([src.type]) at [log_loc(user)].")
			if(beepy_chargeup)
				user.visible_message("<span class='alert'><B>[usr] has armed the [src.name]! Run!</B></span>", "<span class='alert'><B>You have armed the [src.name]!</span>")
				SPAWN_DBG(0)
					src.beep(10)
				return
			if (user?.bioHolder.HasEffect("clumsy"))
				boutput(user, "<span class='alert'>Huh? How does this thing work?!</span>")
				if(src.icon_state_exploding)
					src.icon_state = src.icon_state_exploding
					flick(src.icon_state_armed, src)
				else
					src.icon_state = src.icon_state_armed
				playsound(src.loc, src.sound_armed, 75, 1, -3)
				src.add_fingerprint(user)
				SPAWN_DBG(0.5 SECONDS)
					if (src) prime()
					return
			else
				boutput(user, "<span class='alert'>You prime [src]! [det_time/10] seconds!</span>")
				if(src.icon_state_armed)
					if(src.icon_state_exploding)
						src.icon_state = src.icon_state_exploding
						flick(src.icon_state_armed, src)
					else
						src.icon_state = src.icon_state_armed
				playsound(src.loc, src.sound_armed, 75, 1, -3)
				src.add_fingerprint(user)
				SPAWN_DBG(src.det_time)
					if (src) prime()
					return
		return
// warcrimes: Why the fuck is autothrow a feature why would this ever be a feature WHY. Now it wont do it unless it's primed i think.
	afterattack(atom/target as mob|obj|turf, mob/user as mob)
		if (src.primed)
			return
		if (get_dist(user, target) <= 1 || (!isturf(target) && !isturf(target.loc)) || !isturf(user.loc) || !src.primed )
			return
		if (user.equipped() == src)
			if(is_breaching_charge)
				if (istype(target, /obj/item/storage)) // no blowing yourself up if you have full backpack
					return
				if (user.bioHolder && user.bioHolder.HasEffect("clumsy"))
					boutput(user, "<span class='alert'>Huh? How does this thing work?!</span>")
					logTheThing("combat", user, null, "accidentally triggers [src] (clumsy bioeffect) at [log_loc(user)].")
					SPAWN_DBG (5)
						user.u_equip(src)
						src.prime()
						return
				else
					src.target_atom = target
					boutput(user, "<span class='alert'>You slap the charge on [src.target_atom], [det_time/10] seconds!</span>")
					user.visible_message("<span class='alert'>[user] has attached [src] to [src.target_atom].</span>")
					src.icon_state = "bcharge2"
					user.u_equip(src)
					src.set_loc(get_turf(src.target_atom))
					src.anchored = 1
					src.primed = 1

					// Yes, please (Convair880).
					logTheThing("combat", user, null, "attaches a [src] to [src.target_atom] at [log_loc(src.target_atom)].")

			else
				src.primed = 1
				src.icon_state = src.icon_state_armed
				message_admins("Grenade ([src]) primed at [log_loc(src)] by [key_name(user)].")
				logTheThing("combat", user, null, "primes a grenade ([src.type]) at [log_loc(user)].")
				boutput(user, "<span class='alert'>You prime [src]! [det_time/10] seconds!</span>")
				playsound(src.loc, src.sound_armed, 75, 1, -3)
				user.drop_item()
				src.throw_at(get_turf(target), 10, 3)

			src.add_fingerprint(user)
			SPAWN_DBG(src.det_time)
				if (src) prime()
				return
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (src.is_firework)
			if(iscuttingtool(W) && src.is_firework != "slashed" && !src.primed)
				src.is_firework = "slashed"
				src.name = "empty [src.name]" // its empty now!
				src.desc = "[src.desc] It has been cut open and emptied out."
				boutput(user, "You carefully cut [src] open and dump out the contents.")

				make_cleanable(/obj/decal/cleanable/magnesiumpile, get_turf(src.loc)) // create magnesium pile
				src.reagents.clear_reagents() // remove magnesium from firework
				return

			else if (iscuttingtool(W) && src.is_firework != "slashed" && src.primed) // cutting open a lit firework is a bad idea!
				boutput(user, "<span class='alert'>You cut open [src], but the lit primer ignites the contents!</span>")
				prime()
				return

			else if (iscuttingtool(W) && src.is_firework == "slashed")
				boutput(user, "[src] has already been cut open and emptied.")
				return
		else if (isscrewingtool(W))
			if (src.det_time == src.org_det_time)
				src.det_time = src.alt_det_time
				user.show_message("<span class='notice'>You set [src] for a [det_time/10] second detonation time.</span>")
				src.desc = "It is set to detonate in [det_time/10] seconds."
			else
				src.det_time = src.org_det_time
				user.show_message("<span class='notice'>You set [src] for a [det_time/10] second detonation time.</span>")
				src.desc = "It is set to detonate in [det_time/10] seconds."
			src.add_fingerprint(user)
		return

	attack_hand(mob/user as mob)
		if(is_breaching_charge && src.primed)
			boutput(user, "<span class='alert'>\The [src] is firmly anchored into place!</span>")
		if(is_light_grenade && src.primed >= 1)
			SPAWN_DBG (1)
				playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)
				if (old_light_grenade)
					for (var/obj/item/W in user)
						if (istype(W,/obj/item/clothing))
							user.u_equip(W)
							if (W)
								W.set_loc(user.loc)
								W.dropped(user)
								W.layer = initial(user.layer)
						else if (istype(W,/obj/item/grenade/old_grenade/light_gimmick))
							user.u_equip(W)
							if (W)
								W.set_loc(user.loc)
								W.dropped(user)
								W.layer = HUD_LAYER
						else
							qdel(W)
				else
					user.unequip_all()

				for (var/mob/N in viewers(user, null))
					if (get_dist(N, user) <= 6)
						N.flash(3 SECONDS)
				sleep(0.2 SECONDS)
				if (old_light_grenade)
					random_brute_damage(user, 200)
					sleep(1 DECI SECOND)
					if (isdead(user) || user.nodamage || isAI(user)) return
					logTheThing("combat", user, null, "was killed by touching a [src] at [log_loc(src)].")
					var/mob/dead/observer/newmob
					newmob = new/mob/dead/observer(user)
					user.client.mob = newmob
					user.mind.transfer_to(newmob)
					qdel(user)
				else
					if (destination)
						user.set_loc(destination)
					else
						user.set_loc(locate(40,19,2))
		else
			..()

	/// makes grenade explode
	proc/prime()
		if(src.is_pipebomb)
			src.do_explode() // Pipebome explosion code is best left where it is
			return
		var/turf/T = get_turf(src)
		var/area/A_T = get_area(T)
		if (isturf(T))
			if (src.fizzles_in_sanctuary && (isrestrictedz(T.z) || A_T?.sanctuary))
				src.visible_message("<span class='alert'>[src] buzzes for a moment, then self-destructs.</span>")
				elecflash(src,power = 4)
				qdel(src)
				return

			if(src.is_firework)
				if(src.is_firework != "slashed")
					var/turf/location = get_turf(src.loc)
					if(location)
						if(prob(10))
							explosion(src, location, 0, 0, 1, 1)
						else
							elecflash(src,power = 2)
					src.visible_message("<span class='alert'>\The [src] explodes!</span>")
				else
					boutput(usr, "<span class='alert'>The firework probably should have exploded by now. Fuck.</span>")
					return

			if(is_breaching_charge)
				if (istype(src.target_atom, /obj/machinery))
					src.target_atom.ex_act(1) // Reliably blasts through doors.
				// Breaching charges should be, you know, actually be decent at breaching walls and windows (Convair880).
				var/turf/location = get_turf(src)
				for (var/turf/simulated/wall/W in range(src.breach_range, location))
					if (W && istype(W) && !location.loc:sanctuary)
						W.ReplaceWithFloor()
				for (var/obj/structure/girder/G in range(src.breach_range, location))
					var/area/a = get_area(G)
					if (G && istype(G) && !a.sanctuary)
						qdel(G)
				for (var/obj/window/WD in range(src.breach_range, location))
					var/area/a = get_area(WD)
					if (WD && istype(WD) && prob(max(0, 100 - (WD.health / 3))) && !a.sanctuary)
						WD.smash()
				for (var/obj/grille/GR in range(src.breach_range, location))
					var/area/a = get_area(GR)
					if (GR && istype(GR) && GR.ruined != 1 && !a.sanctuary)
						GR.ex_act(2)

			if(is_thermite_charge)
				var/turf/location = get_turf(src)
				src.invisibility = 101
				for (var/turf/T_T in range(src.breach_range, location))
					if( T_T?.loc:sanctuary ) continue
					if (!istype(T_T, /turf/simulated/wall) && !istype(T_T, /turf/simulated/floor))
						continue

					T_T.hotspot_expose(2000, 125)

					var/obj/overlay/O = new/obj/overlay(T_T)
					O.name = "Thermite"
					O.desc = "A searing wall of flames."
					O.icon = 'icons/effects/fire.dmi'
					O.anchored = 1
					O.layer = TURF_EFFECTS_LAYER
					O.color = "#ff9a3a"
					var/datum/light/point/light = new
					light.set_brightness(1)
					light.set_color(0.5, 0.3, 0.0)
					light.attach(O)

					if (istype(T_T,/turf/simulated/wall))
						O.set_density(1)
					else
						O.set_density(0)

					var/distance = get_dist(T_T, location)
					if (distance < 2)
						var/turf/simulated/floor/F = null

						if (istype(T_T, /turf/simulated/wall))
							var/turf/simulated/wall/W = T_T
							F = W.ReplaceWithFloor()
						else if (istype(T_T, /turf/simulated/floor/))
							F = T_T

						if (F && istype(F))
							F.to_plating()
							F.burn_tile()
							O.icon_state = "2"
					else
						O.icon_state = "1"
						if (istype(T_T, /turf/simulated/floor))
							var/turf/simulated/floor/F = T_T
							F.burn_tile()

				for (var/obj/structure/girder/G in range(src.breach_range, location))
					var/area/a = get_area(G)
					if (G && istype(G) && !a.sanctuary)
						qdel(G)
				for (var/obj/window/W in range(src.breach_range, location))
					var/area/a = get_area(W)
					if (W && istype(W) && !a.sanctuary)
						W.damage_heat(500)
				for (var/obj/grille/GR in range(src.breach_range, location))
					var/area/a = get_area(GR)
					if (GR && istype(GR) && GR.ruined != 1 && !a.sanctuary)
						GR.damage_heat(500)

				for (var/mob/living/M in range(src.breach_range, location))
					if(check_target_immunity(M)) continue
					var/damage = 30 / (get_dist(M, src) + 1)
					M.TakeDamage("chest", 0, damage)
					M.update_burning(damage)

				SPAWN_DBG (100)
					if (src)
						for (var/obj/overlay/O in range(src.breach_range, location))
							if (O.name == "Thermite")
								qdel(O)
						qdel(src)

			playsound(src.loc, sound_explode, 100, 1)

			if(ispath(src.payload))
				new payload(T)
				var/list/dirs_available = alldirs
				if(src.count < 1)
					src.count = 1 // Clearly someone forgot to set this if they also set the payload
				for(var/i in 1 to src.count)
					var/atom/movable/thing = new payload(T)
					var/throw_success = 0
					if(src.throw_payload_random)
						var/turf/target = locate(T.x + rand(-4, 4), T.y + rand(-4, 4), T.z)
						if(target)
							thing.throw_at(target, rand(0, 10), rand(1, 4))
							throw_success = 1
					if(!throw_success)
						var/dir_at = pick(dirs_available)
						dirs_available -= dir_at
						step(thing, dir_at, 1)

			if(src.is_graviton)
				for (var/atom/X in orange(9, T))
					if (istype(X,/obj/machinery/containment_field))
						continue
					if (istype(X,/obj/machinery/field_generator))
						continue
					if (istype(X,/turf))
						continue
					if (istype(X, /obj))
						var/area/t = get_area(X)
						if(t?.sanctuary) continue
						if (prob(50) && X:anchored != 2)
							step_towards(X,src)

			if(make_singulo)
				src.build_a_singulo()

			if (src.is_gas_grenade)
				SPAWN_DBG (0)
					for(var/i in 1 to 4)
						if (src)
							switch(src.is_gas_grenade)
								if("smoke")
									src.smoke.start()
								if("mustard")
									src.mustard.start()
								else
									src.mustard.start()
									src.smoke.start()
							sleep(1 SECOND)
					qdel(src)

			if (src.is_explosive_grenade)
				explosion_new(src, T, src.ex_power, src.ex_brisance)
				var/obj/overlay/O = new/obj/overlay(get_turf(T))
				O.anchored = 1
				O.name = "Explosion"
				O.layer = NOLIGHT_EFFECTS_LAYER_BASE
				O.icon = 'icons/effects/64x64.dmi'
				O.icon_state = "explo_fiery"
				// smoke handled in smoking section
				var/datum/projectile/special/spreader/uniform_burst/circle/PJ = new /datum/projectile/special/spreader/uniform_burst/circle(T)
				if(src.custom_projectile_type)
					PJ.spread_projectile_type = src.custom_projectile_type
					PJ.pellet_shot_volume = 75 / PJ.pellets_to_fire //anti-ear destruction
				PJ.pellets_to_fire = src.pellets_to_fire
				var/targetx = src.y - rand(-5,5)
				var/targety = src.y - rand(-5,5)
				var/turf/newtarget = locate(targetx, targety, src.z)
				shoot_projectile_ST(src, PJ, newtarget)
				SPAWN_DBG(0.5 SECONDS)
					qdel(O)
					qdel(src)

			if (is_sonic_grenade)
				for (var/mob/living/M in hearers(8, T))
					if(check_target_immunity(M)) continue
					var/loud = 16 / (get_dist(M, T) + 1)
					if (src.loc == M.loc || src.loc == M)
						loud = 16
					var/weak = loud / 3
					var/stun = loud
					var/damage = loud * 2
					var/tempdeaf = loud * 3
					M.apply_sonic_stun(weak, stun, 0, 0, 0, damage, tempdeaf)
				sonic_attack_environmental_effect(T, 8, list("window", "r_window", "displaycase", "glassware"))

			if (is_emp_grenade)
				T.hotspot_expose(700,125)
				var/obj/overlay/pulse = new/obj/overlay(T)
				pulse.icon = 'icons/effects/effects.dmi'
				pulse.icon_state = "emppulse"
				pulse.name = "emp pulse"
				pulse.anchored = 1
				SPAWN_DBG (20)
					if (pulse) qdel(pulse)
				SPAWN_DBG(0)
					for (var/turf/tile in range(world.view-1, T))
						for (var/atom/O in tile.contents)
							var/area/t = get_area(O)
							if(t?.sanctuary) continue
							O.emp_act()
					qdel(src)

			if(is_clothing_grenade)
				src.clothe_victims()

			if(is_owlgib_grenade)
				for(var/mob/living/carbon/human/M in range(5, src))
					var/area/t = get_area(M)
					if(t?.sanctuary) continue
					SPAWN_DBG(0)
						M.owlgib()

			if(explode_on_detonation)
				var/obj/effects/explosion/E = new /obj/effects/explosion(src.loc)
				E.fingerprintslast = src.fingerprintslast

			if(src.del_self_on_explode)
				qdel(src)
		else
			qdel(src)

	/// builds a singulo!
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
			gen.anchored = 1
			icon_state = "Field_Gen +a"

	/// forces clothes onto victims. Requires a child proc to actually work
	proc/clothe_victims()
		return
	/// Changes the materials of everything around it
	proc/change_mats()
		return

	proc/beep(i)
		if(src.primed != 1)
			src.primed = 1
		var/k = i/2
		sleep(k*k)
		flick(icon_state+"_beep", src)
		playsound(get_turf(src), src.sound_beep, pitch = (32000 + ((10-i)*4000)))
		if(i>=0)
			src.beep(i-1)
		else
			src.prime()

	/// For pipebombs to perform their forbidden magic
	proc/do_explode()
		return
	// staging area


////////////////////////////// Old-style grenades ///////////////////////////////////////

/obj/item/grenade/old_grenade
	desc = "You shouldn't be able to see this!"
	name = "old grenade"
	w_class = 2.0
	icon = 'icons/obj/items/grenade.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "banana"
	item_state = "banana"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT | EXTRADELAY
	is_syndicate = 0
	mats = 6
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0

/obj/item/grenade/old_grenade/banana
	desc = "It is set to detonate in 3 seconds."
	name = "banana grenade"
	det_time = 30
	org_det_time = 30
	alt_det_time = 60
	icon_state = "banana"
	item_state = "banana"
	is_syndicate = 1
	sound_armed = "sound/weapons/armbomb.ogg"
	icon_state_armed = "banana1"
	payload = /obj/item/bananapeel

/obj/item/grenade/old_grenade/thing_thrower
	desc = "It is set to detonate in 3 seconds."
	name = "banana grenade"
	det_time = 30
	org_det_time = 30
	alt_det_time = 60
	icon_state = "banana"
	item_state = "banana"
	is_syndicate = 1
	sound_armed = "sound/weapons/armbomb.ogg"
	icon_state_armed = "banana1"
	payload = /obj/item/reagent_containers/food/snacks/plant/tomato
	throw_payload_random = TRUE
	count = 7
/obj/item/grenade/old_grenade/banana/cheese_sandwich
	name = "cheese sandwich grenade"
	icon_state = "banana-old"
	icon_state_armed = "banana1-old"
	payload = /obj/item/reagent_containers/food/snacks/sandwich/cheese

/obj/item/grenade/old_grenade/banana/banana_corndog
	name = "banana corndog grenade"
	icon_state = "banana-old"
	icon_state_armed = "banana1-old"
	payload = /obj/item/reagent_containers/food/snacks/corndog/banana

/obj/item/grenade/old_grenade/banana/wasp
	name = "suspicious looking grenade"
	icon_state = "wasp"
	icon_state_armed = "wasp1"
	payload = /obj/critter/spacebee

/obj/item/grenade/old_grenade/graviton //ITS SPELT GRAVITON
	desc = "It is set to detonate in 10 seconds."
	name = "graviton grenade"
	det_time = 100
	org_det_time = 100
	alt_det_time = 60
	icon_state = "graviton"
	item_state = "emp" //TODO: grenades REALLY need custom inhands, but I'm not submitting them in this PR
	is_syndicate = 1
	mats = 12
	sound_armed = "sound/weapons/armbomb.ogg"
	icon_state_armed = "graviton1"
	is_graviton = TRUE
	icon_state_exploding = "graviton2"

/obj/item/grenade/old_grenade/singularity
	desc = "It is set to detonate in 10 seconds."
	name = "singularity grenade"
	det_time = 100
	org_det_time = 100
	alt_det_time = 60
	icon_state = "graviton"
	item_state = "emp"
	is_syndicate = 1
	mats = 12
	sound_armed = "sound/weapons/armbomb.ogg"
	icon_state_armed = "graviton1"
	icon_state_exploding = "graviton2"
	radius = 3
	make_singulo = TRUE

/obj/item/grenade/old_grenade/smoke
	desc = "It is set to detonate in 2 seconds."
	name = "smoke grenade"
	icon_state = "smoke"
	det_time = 20.0
	org_det_time = 20
	alt_det_time = 60
	item_state = "flashbang"
	is_syndicate = 1
	sound_armed = "sound/weapons/armbomb.ogg"
	sound_explode = "sound/effects/smoke.ogg"
	icon_state_armed = "smoke1"
	is_gas_grenade = "smoke"

/obj/item/grenade/old_grenade/smoke/mustard
	name = "mustard gas grenade"
	icon_state = "mustard"
	icon_state_armed = "mustard1"
	is_gas_grenade = "mustard"

/obj/item/grenade/old_grenade/stinger
	name = "stinger grenade"
	desc = "It is set to detonate in 3 seconds."
	icon_state = "fragnade"
	det_time = 30.0
	org_det_time = 30
	alt_det_time = 60
	item_state = "fragnade"
	is_syndicate = 0
	sound_armed = "sound/weapons/pindrop.ogg"
	sound_explode = "sound/weapons/grenade.ogg"
	icon_state_armed = "fragnade1"
	is_explosive_grenade = TRUE
	del_self_on_explode = 0

/obj/item/grenade/old_grenade/stinger/frag
	name = "frag grenade"
	icon_state = "fragnade-alt"
	icon_state_armed = "fragnade-alt1"
	is_gas_grenade = "smoke" // it does the hokey-smokey too

/obj/item/grenade/old_grenade/high_explosive
	name = "HE grenade"
	desc = "A high-explosive grenade. It is set to detonate in 3 seconds."
	icon_state = "fragnade-alt"
	icon_state_armed = "fragnade-alt1"
	det_time = 30.0
	org_det_time = 30
	alt_det_time = 60
	item_state = "fragnade"
	is_syndicate = 0
	sound_armed = "sound/weapons/pindrop.ogg"
	sound_explode = "sound/weapons/grenade.ogg"
	is_explosive_grenade = TRUE
	ex_power = 5.0
	ex_brisance = 2
	del_self_on_explode = 0

/obj/item/grenade/old_grenade/sonic
	name = "sonic grenade"
	desc = "It is set to detonate in 3 seconds."
	icon_state = "sonic"
	det_time = 30.0
	org_det_time = 30
	alt_det_time = 60
	item_state = "flashbang"
	is_syndicate = 1
	sound_armed = "sound/effects/screech.ogg"
	icon_state_armed = "sonic1"
	is_sonic_grenade = TRUE
	fizzles_in_sanctuary = TRUE // Adventureglass is a protected species

/obj/item/grenade/old_grenade/emp
	desc = "It is set to detonate in 5 seconds."
	name = "emp grenade"
	det_time = 50.0
	org_det_time = 50
	alt_det_time = 30
	icon = 'icons/obj/items/device.dmi'
	icon_state = "emp"
	item_state = "emp"
	is_syndicate = 1
	sound_armed = "sound/weapons/armbomb.ogg"
	sound_explode = "sound/items/Welder2.ogg"
	icon_state_armed = "empar"
	is_emp_grenade = TRUE

/obj/item/grenade/old_grenade/moustache
	name = "moustache grenade"
	desc = "It is set to detonate in 3 seconds."
	det_time = 30.0
	org_det_time = 30
	alt_det_time = 60
	icon_state = "moustache"
	item_state = "flashbang"
	is_syndicate = 1
	sound_armed = "sound/weapons/armbomb.ogg"
	sound_explode = 'sound/effects/Explosion2.ogg'
	icon_state_armed = "moustache1"
	is_clothing_grenade = TRUE

	clothe_victims()
		for (var/mob/living/carbon/human/M in range(5, src))
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

/obj/item/grenade/old_grenade/light_gimmick
	name = "light grenade"
	icon_state = "lightgrenade"
	icon = 'icons/obj/items/weapons.dmi'
	desc = "It's a small cast-iron egg-shaped object, with the words \"Pick Me Up\" in gold in it."
	primed = 0
	not_in_mousetraps = 1
	is_light_grenade = TRUE

	New()
		..()
		destination = locate(40,19,2)

	primed
		primed = TRUE

	old
		old_light_grenade = TRUE

		primed
			primed = TRUE

////////////////////////// Gimmick bombs /////////////////////////////////

/obj/item/grenade/gimmickbomb/
	name = "Don't spawn this directly!"
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = ""
	beepy_chargeup = TRUE
	explode_on_detonation = TRUE
	sound_explode = 'sound/effects/Explosion2.ogg'

/obj/item/grenade/gimmickbomb/owlgib
	name = "Owl Bomb"
	desc = "Owls. Owls everywhere"
	icon_state = "owlbomb"
	sound_beep = 'sound/voice/animal/hoot.ogg'

/obj/item/grenade/gimmickbomb/owlclothes
	name = "Owl Bomb"
	desc = "Owls. Owls everywhere"
	icon_state = "owlbomb"
	sound_beep = 'sound/voice/animal/hoot.ogg'
	is_clothing_grenade

	clothe_victims()
		for(var/mob/living/carbon/human/M in range(5, src))
			var/area/t = get_area(M)
			if(t?.sanctuary) continue
			SPAWN_DBG(0)
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

/obj/item/grenade/gimmickbomb/hotdog
	name = "hotdog bomb"
	desc = "A hotdog bomb? What the heck does that even mean?!"
	icon_state = "hotdog"
	is_clothing_grenade = TRUE

	clothe_victims()
		for(var/mob/living/carbon/human/M in range(5, src))
			var/area/t = get_area(M)
			if(t?.sanctuary) continue
			SPAWN_DBG(0)
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

/obj/item/grenade/gimmickbomb/butt
	name = "Butt Bomb"
	desc = "What a crappy grenade."
	icon_state = "fartbomb"
	sound_beep = 'sound/voice/farts/poo2.ogg'
	sound_explode = 'sound/voice/farts/superfart.ogg'

/obj/item/grenade/gimmickbomb/gold
	name = "Gold Bomb"
	desc = "Why explode when you can gold!"
	icon_state = "banana"
	sound_beep = 'sound/machines/twobeep.ogg'
	is_mat_change_grenade = TRUE

	change_mats()
		for(var/turf/G in range(5, src))
			G.setMaterial(getMaterial("gold"))
		for(var/obj/item/I in range(5, src))
			I.setMaterial(getMaterial("gold"))
		for(var/obj/machinery/T in range(5, src))
			T.setMaterial(getMaterial("gold"))
		for(var/mob/living/carbon/human/M in range(3, src))
			var/area/t = get_area(M)
			if(t?.sanctuary) continue
			SPAWN_DBG(0)
				M.become_gold_statue()
		..()


/obj/item/grenade/gimmickbomb/butt/prearmed
	primed = 1
	anchored = 1

	New()
		SPAWN_DBG(0)
			src.beep(10)
		return ..()

/obj/item/grenade/gimmickbomb/owlgib/prearmed
	primed = 1
	anchored = 1

	New()
		SPAWN_DBG(0)
			src.beep(10)
		return ..()

/obj/item/grenade/gimmickbomb/owlclothes/prearmed
	primed = 1
	anchored = 1

	New()
		SPAWN_DBG(0)
			src.beep(10)
		return ..()

/////////////////////////////// Fireworks ///////////////////////////////////////

/obj/item/grenade/firework
	name = "firework"
	desc = "A consumer-grade pyrotechnic, often used in celebrations. This one says it was manufactured in Space-China."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "firework"
	opacity = 0
	density = 0
	anchored = 0.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	det_time = 20
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 5
	is_firework = TRUE
	sound_explode = "sound/effects/Explosion1.ogg"

	New()
		..()
		create_reagents(10)
		reagents.add_reagent("magnesium", 10)

//////////////////////// Breaching charges //////////////////////////////////

/obj/item/grenade/breaching_charge
	desc = "It is set to detonate in 5 seconds."
	name = "Breaching Charge"
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "bcharge"
	primed = null
	det_time = 50.0
	w_class = 2.0
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	desc = "A timed device that releases a relatively strong concussive force, strong enough to destroy rock and metal."
	stamina_damage = 1
	stamina_cost = 1
	stamina_crit_chance = 0
	is_explosive_grenade = TRUE
	is_breaching_charge = TRUE
	fizzles_in_sanctuary = TRUE
	ex_power = 0.75
	ex_brisance = 1.125

/obj/item/grenade/breaching_charge/NT
	name = "NanoTrasen Experimental EDF-7 Breaching Charge"

	stamina_damage = 1
	stamina_cost = 1
	stamina_crit_chance = 0
	ex_power = 1.25
	ex_brisance = 1.875
	breach_range = 2

/obj/item/grenade/breaching_charge/thermite
	name = "Thermite Breaching Charge"
	desc = "When applied to a wall, causes a thermite reaction which totally destroys it."
	flags = ONBELT
	w_class = 1
	breach_range = 2
	is_explosive_grenade = FALSE
	is_thermite_charge = TRUE
	del_self_on_explode = FALSE // Gotta clean up the mess it makes
	sound_explode = "sound/effects/bamf.ogg"

//////////////////////////////////////////
// PIPE BOMBS (INCLUDES CONSTRUCTION)
//////////////////////////////////////////

/obj/item/grenade/pipebomb
	icon = 'icons/obj/items/assemblies.dmi'
	item_state = "r_hands"

/obj/item/grenade/pipebomb/frame
	name = "pipe frame"
	desc = "Two small pipes joined together with grooves cut into the side."
	icon_state = "Pipe_Frame"
	burn_possible = 0
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
			if(alert(user, "Pour out the pipebomb reagents?",,"Yes","No") == "No")
				return
			boutput(user, "<span class='notice'>The reagents inside spill out!</span>")
			src.reagents = null
			state = 2
		return

	attackby(obj/item/W, mob/user)

		if(isweldingtool(W) && state == 1)
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

		if (allowed_items.len && item_mods.len < 3 && state == 2)
			var/ok = 0
			for (var/A in allowed_items)
				if (istype(W, text2path(A) )) ok = 1
			if (ok)
				boutput(user, "<span class='notice'>You stuff [W] into the [item_mods.len == 0 ? "first" : "second"] pipe.</span>")
				item_mods += W
				user.u_equip(W)
				W.set_loc(src)

		if(istype(W, /obj/item/reagent_containers/) && state == 2)
			var/ok = 0
			for (var/A in allowed_items)
				if (istype(W, text2path(A) )) ok = 1
			if (!ok)
				//There is less room for explosive material when you use item mods
				var/max_allowed = 20 - item_mods.len * 5
				boutput(user, "<span class='notice'>You fill the pipe with [max_allowed] units of the reagents.</span>")
				src.state = 3
				var/avg_volatility = 0
				src.reagents = new /datum/reagents(max_allowed)
				src.reagents.my_atom = src
				W.reagents.trans_to(src, max_allowed)
				for (var/id in src.reagents.reagent_list)
					var/datum/reagent/R = src.reagents.reagent_list[id]
					avg_volatility += R.volatility * R.volume / src.reagents.total_volume

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


		if(istype(W, /obj/item/cable_coil) && state == 3)
			boutput(user, "<span class='notice'>You link the cable, fuel and pipes.</span>")
			src.state = 4
			icon_state = "Pipe_Wired"

			if (material)
				name = "[src.material.name] pipe bomb frame"
			else
				name = "pipe bomb frame"

			desc = "Two small pipes joined together, filled with explosives and connected with a cable. It needs some kind of ignition switch."
			src.flags &= ~NOSPLASH

		if(istype(W, /obj/item/assembly/time_ignite) && state == 4)
			boutput(user, "<span class='notice'>You connect the cable to the timer/igniter assembly.</span>")
			var/turf/T = get_turf(src)
			var/obj/item/grenade/pipebomb/bomb/A = new /obj/item/grenade/pipebomb/bomb(T)
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

/obj/item/grenade/pipebomb/bomb
	name = "pipe bomb"
	desc = "An improvised explosive made primarily out of two pipes."
	icon_state = "Pipe_Timed"
	contraband = 4

	is_pipebomb = TRUE

	var/strength = 5
	var/armed = 0

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

	attack_self(mob/user as mob)
		if (armed)
			return
		boutput(user, "<span class='alert'>You activate the pipe bomb! 5 seconds!</span>")
		armed = 1
		message_admins("[key_name(user)] arms a pipe bomb (power [strength]) in [user.loc.loc], [showCoords(user.x, user.y, user.z)].")
		logTheThing("combat", user, null, "arms a pipe bomb (power [strength]) in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")

		if (sound_effect)
			SPAWN_DBG(4 SECONDS) //you can use a sound effect to hold a bomb in hand and throw it at the very last moment!
				playsound(get_turf(src), sound_effect, 50, 1)
		SPAWN_DBG(5 SECONDS)
			do_explode()

	ex_act(severity)
		do_explode()
		. = ..()

	do_explode()
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
					playsound(src.loc, "sound/voice/farts/superfart.ogg", 90, 1)
					for (var/mob/M in view(3+butt,src.loc))
						ass_explosion(M, 0, 5)
				else
					playsound(src.loc, "sound/voice/farts/poo2.ogg", 90, 1)
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
				playsound(get_turf(src), "sound/items/Deconstruct.ogg", 70, 1)
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
					if(!target.blocks_air && target.air)
						if(target.parent?.group_processing)
							target.parent.suspend_group_processing()

						var/datum/gas_mixture/payload = unpool(/datum/gas_mixture)
						payload.toxins = plasma * 100
						payload.temperature = T20C
						payload.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
						target.air.merge(payload)

			if (throw_objs.len && throw_objs.len > 0)
				var/turf/T = get_turf(src.loc)
				var/count = 6
				var/obj/spawn_item
				for (var/mob/living/L in oview(5, src.loc))
					spawn_item = pick(throw_objs)
					var/obj/O = new spawn_item(T)
					if (istype(O,/obj/item/reagent_containers/patch))
						var/obj/item/reagent_containers/patch/P = O
						P.good_throw = 1
					O.throw_at(L,5,3)
					count++
				if (count > 0)
					for (var/turf/target in oview(4,src.loc))
						if (prob(4))
							spawn_item = pick(throw_objs)
							var/obj/O = new spawn_item(T)
							if (istype(O,/obj/item/reagent_containers/patch))
								var/obj/item/reagent_containers/patch/P = O
								P.good_throw = 1
							O.throw_at(target,4,3)
							count++
						if (count <= 0)
							break;

			qdel(src)
		else
			visible_message("<span class='alert'>[src] sparks and emits a small cloud of smoke, crumbling into a pile of dust.</span>")
			qdel(src)

/obj/item/grenade/pipebomb/bomb/syndicate
	name = "pipe bomb"
	desc = "An improvised explosive made primarily out of two pipes." // cogwerks - changed the name
	icon_state = "Pipe_Timed"
	strength = 32

/obj/item/grenade/pipebomb/bomb/miniature_syndicate
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

/obj/item/grenade/pipebomb/bomb/engineering
	name = "controlled demolition pipe"
	desc = "A weak explosive designed to blast open holes in the sea floor."
	icon_state = "Pipe_Yellow"
	strength = 1

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

/obj/item/grenade/pipebomb/bomb/on_blowthefuckup(strength)
	..()

/obj/proc/throw_shrapnel(var/T, var/sqstrength, var/shrapnel_range)
	for (var/mob/living/carbon/human/M in view(T, shrapnel_range))
		if(check_target_immunity(M)) continue
		M.TakeDamage("chest", 15/M.get_ranged_protection(), 0)
		if (M.get_ranged_protection()>=1.5)
			boutput(M, "<span class='alert'><b>Your armor blocks the shrapnel!</b></span>")
		else
			var/obj/item/implant/projectile/shrapnel/implanted = new /obj/item/implant/projectile/shrapnel(M)
			implanted.owner = M
			M.implant += implanted
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
			var/obj/item/implant/projectile/shrapnel/implanted = new /obj/item/implant/projectile/shrapnel(M)
			implanted.owner = M
			M.implant += implanted
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
				var/obj/item/implant/projectile/shrapnel/implanted = new /obj/item/implant/projectile/shrapnel(M)
				implanted.owner = M
				M.implant += implanted
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
