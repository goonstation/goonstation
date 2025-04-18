//Contains Fire / Explosion / Implosion related reagents.

ABSTRACT_TYPE(/datum/reagent/combustible)

datum
	reagent
		combustible/
			name = "fire stuff"

		combustible/phlogiston //This is used for the smoke/phlogiston reaction.
			name = "phlogiston"
			id = "phlogiston"
			description = "It appears to be liquid fire."
			reagent_state = LIQUID
			fluid_r = 250
			fluid_b = 0
			fluid_g = 175
			volatility = 2
			transparency = 175
			var/temp_fire = 4000
			var/temp_deviance = 1000
			var/size_divisor = 40
			var/mob_burning = 33
			hygiene_value = 1 // with purging fire
			viscosity = 0.7

			reaction_turf(var/turf/T, var/volume)
				if (!holder) //Wire: Fix for Cannot read null.total_temperature
					return
				if(holder.total_temperature <= T0C - 50) return //Too cold. Doesnt work.
				var/SD = size_divisor

				var/list/covered = holder.covered_turf()

				if (length(covered) > 9)
					volume = (volume/covered.len)

				var/radius = clamp(volume/SD, 0, 8)
				fireflash_melting(T, radius, rand(temp_fire - temp_deviance, temp_fire + temp_deviance), 500, chemfire = CHEM_FIRE_RED)
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				. = ..()
				if (!holder) //Wire: Fix for Cannot read null.total_temperature
					return
				if(holder.total_temperature <= T0C - 50) return
				var/MB = mob_burning
				var/mob/living/L = M
				if(istype(L))
					L.update_burning(MB)
				if (method == INGEST)
					M.TakeDamage("All", 0, clamp(volume_passed * 2, 10, 45), 0, DAMAGE_BURN)
					boutput(M, SPAN_ALERT("It burns!"))

			on_mob_life(var/mob/M, var/mult = 1)
				if (!holder) //Wire: Fix for Cannot read null.total_temperature
					return
				if(holder.total_temperature <= T0C - 50) return
				if(!M) M = holder.my_atom
				var/mob/living/L = M
				if(istype(L))
					L.update_burning(2 * mult)
				..()

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.fire_damage += 8
				growth_tick.growth_rate -= 12

		combustible/phlogiston/firedust
			name = "phlogiston dust"
			id = "firedust"
			description = "And this is solid fire. However that works."
			dispersal = 4
			temp_fire = 1500
			temp_deviance = 500
			transparency = 255
			size_divisor = 80
			mob_burning = 15

		combustible/napalm_goo  // adapated from weldfuel
			name = "napalm goo"
			id = "napalm_goo"
			description = "A highly flammable jellied fuel."
			reagent_state = LIQUID
			fluid_r = 200
			fluid_b = 50
			fluid_g = 100
			transparency = 150
			viscosity = 0.8
			minimum_reaction_temperature = T0C + 100
			var/temp_reacted = 0

			reaction_temperature(exposed_temperature, exposed_volume)
				if(!temp_reacted)
					temp_reacted = 1
					var/radius = clamp(volume*0.15, 0, 8)
					var/list/covered = holder.covered_turf()
					for(var/turf/t in covered)
						radius = clamp((volume/covered.len)*0.15, 0, 8)
						fireflash(t, radius, rand(3000, 6000), 500, chemfire = CHEM_FIRE_RED)
				holder?.del_reagent(id)
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume, var/paramslist = 0, var/raw_volume)
				. = ..()
				if(method == TOUCH)
					var/mob/living/L = M
					var/datum/statusEffect/simpledot/burning/burn = L.hasStatus("burning")
					if(istype(L) && burn)
						L.changeStatus("burning", 2 * raw_volume SECONDS)
						burn.counter += 10 * raw_volume
						L.TakeDamage("All", 0, (1 - L.get_heat_protection()/100) * clamp(3 * raw_volume * (burn.getStage()-1.25), 0, 35), 0, DAMAGE_BURN)
						if(!M.stat && !ON_COOLDOWN(M, "napalm_scream", 1 SECOND))
							M.emote("scream")
					return 0
				return 1

			on_mob_life(var/mob/M, var/mult = 1)
				var/mob/living/L = M
				var/datum/statusEffect/simpledot/burning/burn = L.hasStatus("burning")
				if(istype(L) && burn)
					L.changeStatus("burning", 2 * src.volume SECONDS)
					burn.counter += 10 * src.volume
					holder?.del_reagent(src.id)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.poison_damage += 1

			syndicate
				name = "syndicate napalm"
				id = "syndicate_napalm"
				description = "Extra sticky, extra burny"

				reaction_mob(var/mob/M, var/method=TOUCH, var/volume, var/paramslist = 0, var/raw_volume)
					. = ..()
					if(method == TOUCH)
						var/mob/living/L = M
						var/datum/statusEffect/simpledot/burning/burn = L.hasStatus("burning")
						L.changeStatus("slowed", 4 SECONDS, optional = 4)
						if(istype(L) && burn) //double up on the extra burny, not blockable by biosuits/etc either
							L.changeStatus("burning", raw_volume SECONDS)
							burn.counter += 5 * raw_volume

		combustible/kerosene
			name = "kerosene"
			id = "kerosene"
			description = "A substance widely applied as fuel for aviation vehicles and solvent for metal alloys (when heated)."
			reagent_state = LIQUID
			fluid_r = 250
			fluid_g = 250
			fluid_b = 250
			transparency = 255
			viscosity = 0.4
			volatility = 2
			minimum_reaction_temperature = T0C+600

			reaction_obj(var/obj/O, var/volume)
				if (!holder)
					return
				if (volume >= 5 && holder.total_temperature >= T0C + 400 && (istype(O, /obj/steel_beams) || (O.material && O.material.getID() == "steel")))
					O.visible_message(SPAN_ALERT("[O] melts!"))
					qdel(O)

			reaction_temperature(exposed_temperature, exposed_volume)
				var/radius = clamp(volume*0.15, 0, 8)
				var/list/covered = holder.covered_turf()
				var/list/affected = list()
				radius = clamp((volume/covered.len)*0.15, 0, 8)
				holder?.del_reagent(id)
				for(var/turf/t in covered)
					affected += fireflash_melting(t, radius, rand(3000, 6000), 500, chemfire = CHEM_FIRE_RED)

				for (var/turf/T in affected)
					for (var/obj/steel_beams/O in T)
						O.visible_message(SPAN_ALERT("[O] melts!"))
						qdel(O)

			reaction_turf(var/turf/simulated/T, var/volume)
				if (!holder)
					return
				if (!istype(T) || volume < 5 || holder.total_temperature < T0C + 400)
					return
				if (T.material && T.material.getID() == "steel")
					//T.visible_message(SPAN_ALERT("[T] melts!"))
					T.ex_act(2)

		combustible/thermite
			name = "thermite"
			id = "thermite"
			description = "Thermite burns at an incredibly high temperature. Can be used to melt walls."
			reagent_state = SOLID
			fluid_r = 85
			fluid_g = 0
			fluid_b = 0
			transparency = 255
			volatility = 1.5
			minimum_reaction_temperature = T0C+100
			fluid_flags = FLUID_BANNED

			reaction_temperature(exposed_temperature, exposed_volume)
				if (!istype(src.holder.my_atom, /obj/decal/cleanable)) //okay I wanted to let this react anywhere but then it tends to blow up when you synthesize it sooo
					return
				if(holder.get_reagent_amount(id) < 10) //no more thermiting walls with 1u tyvm
					return
				var/turf/T = get_turf(src.holder.my_atom)
				var/atom/my_atom = src.holder.my_atom
				holder.del_reagent(id)
				var/temp = rand(20000, 25000)
				fireflash_melting(T, 0, temp, 0, TRUE, CHEM_FIRE_DARKRED, FALSE, TRUE) // Bypasses the RNG roll to melt walls (Convair880).
				fireflash(T, 0, temp, 0, TRUE, CHEM_FIRE_DARKRED) //another fireflash because the first one gets deleted along with the turf
				qdel(my_atom)

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == TOUCH)
					var/mob/living/L = M
					if(istype(L) && L.getStatusDuration("burning"))
						L.changeStatus("burning", 10 SECONDS)

			reaction_turf(var/turf/T, var/volume)
				if(istype(T, /turf/simulated))
					var/list/covered = holder.covered_turf()
					if(length(covered) > 9)
						volume = volume/length(covered)
					if (volume < 3)
						return
					if (length(covered) == 1 && volume < 10)
						return
					var/obj/decal/cleanable/thermite/cleanable = locate() in T
					if (!cleanable)
						cleanable = make_cleanable(/obj/decal/cleanable/thermite, T)
						cleanable.create_reagents(10)
						cleanable.reagents.add_reagent("thermite", 10, null)

					if (length(T.active_hotspots))
						var/max_temp = T.active_hotspots[1].temperature
						var/max_vol = T.active_hotspots[1].volume
						if (length(T.active_hotspots) > 1)
							max_temp = max(max_temp, T.active_hotspots[2].temperature)
							max_vol = max(max_vol, T.active_hotspots[2].volume)
						T.reagents.temperature_reagents(max_temp, max_vol, 350, 300, 1)


		combustible/smokepowder
			name = "smoke powder"
			id = "smokepowder"
			description = "Produces smoke when heated."
			reagent_state = SOLID
			fluid_r = 200
			fluid_g = 200
			fluid_b = 200
			transparency = 230
			// Heat reaction moved to reactions to account for opening and closing containers

		combustible/propellant
			name = "aerosol propellant"
			id = "propellant"
			description = "Produces a aerosol spray when heated."
			reagent_state = SOLID
			fluid_r = 200
			fluid_g = 200
			fluid_b = 255
			transparency = 230

		combustible/sonicpowder
			name = "hootingium"
			id = "sonicpowder"
			description = "Produces a loud bang when heated."
			reagent_state = SOLID
			fluid_r = 200
			fluid_g = 200
			fluid_b = 200
			transparency = 230
			penetrates_skin = 1 // coat them with it?
			minimum_reaction_temperature = T0C+100
			var/no_fluff = 0

			reaction_temperature(exposed_temperature, exposed_volume)
				if(!reacting)
					reacting = 1
					var/list/covered = holder.covered_turf()
					var/location = covered.len ? covered[1] : 0
					var/hootmode = prob(5)

					sonicpowder_reaction(location, volume, hootmode, no_fluff)

				holder?.del_reagent(id)

			on_mob_life(var/mob/M, var/mult = 1) // fuck you jerk chemists (todo: a thing to self-harm borgs too, maybe ex_act(3) to the holder? I D K
				if(!M) M = holder.my_atom
				if(prob(70))
					M.take_brain_damage(1 * mult)
				..()
				return

		combustible/sonicpowder/nofluff
			name = "hootingium"
			id = "sonicpowder_nofluff"
			no_fluff = 1

		combustible/flashpowder
			name = "flash powder"
			id = "flashpowder"
			description = "Produces a bright flash of light when heated."
			reagent_state = SOLID
			fluid_r = 200
			fluid_g = 200
			fluid_b = 200
			transparency = 230
			penetrates_skin = 1 // coat them with it?
			viscosity = 0.5
			minimum_reaction_temperature = T0C+100

			reaction_temperature(exposed_temperature, exposed_volume)
				if(!reacting)
					reacting = 1
					var/list/covered = holder.covered_turf()
					var/location = covered.len ? covered[1] : 0
					flashpowder_reaction(location, holder.get_reagent_amount(id))
				holder?.del_reagent(id)

		combustible/infernite // COGWERKS CHEM REVISION PROJECT. this could be Chlorine Triflouride, a really mean thing
			name = "chlorine triflouride"
			id = "infernite"
			description = "An extremely volatile substance, handle with the utmost care."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 200
			fluid_b = 200
			volatility = 2
			transparency = 175
			depletion_rate = 4
			dispersal = 2
			hygiene_value = 2 // with purging fire
			viscosity = 0.5

			reaction_obj(var/obj/O, var/volume)
				var/datum/reagents/old_holder = src.holder //mbc pls, ZeWaka fix: null.holder
				var/id = src.id
				if (isnull(O)) return
				if(isitem(O))
					var/obj/item/I = O
					if(!I.health)
						I.health = 10
					if(!I.burn_output)
						I.burn_output = 1200
					if(!I.burning)
						if(!isnull(I)) // just in case
							I.combust()

					var/list/covered = old_holder.covered_turf()
					if (covered.len>4)
						old_holder.remove_reagent(id, I.health * 0.25)
				return

			reaction_turf(var/turf/T, var/volume)
				var/datum/reagents/old_holder = src.holder
				var/list/covered = old_holder.covered_turf()
				if(length(covered) > 9)
					volume = volume/length(covered)
				if (volume < 3)
					return

				var/fail = 0
				if (covered.len>4)
					fail = 1
					if (prob(volume+6))
						fail = 0

				if (!fail)
					var/radius = min((volume - 3) * 0.15, 3)
					fireflash_melting(T, radius, 4500 + volume * 500, 350, chemfire = CHEM_FIRE_RED)

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume, var/paramslist = 0, var/raw_volume)
				. = ..()
				if(method == TOUCH || method == INGEST)
					var/mob/living/L = M
					if(method == TOUCH)
						volume = raw_volume
					if(istype(L))
						if (volume <= 1)
							L.update_burning(10)
						else
							L.update_burning(50)
				if (method == INGEST)
					M.TakeDamage("All", 0, clamp(volume * 2.5, 15, 90), 0, DAMAGE_BURN)
					boutput(M, SPAN_ALERT("It burns!"))

			on_mob_life(var/mob/M, var/mult = 1)

				var/mob/living/L = M
				if(istype(L) && L.getStatusDuration("burning"))
					L.changeStatus("burning", 10 SECONDS * mult)
				..()

		combustible/foof // this doesn't work yet
			name = "FOOF"
			id = "foof"
			description = "Dioxygen Diflouride, a ludicrously powerful oxidizer. Run away."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 200
			fluid_b = 200
			transparency = 175
			depletion_rate = 1.2
			viscosity = 0.6
			volatility = 4

			reaction_turf(var/turf/T, var/volume)
				fireflash(T, clamp(volume/10, 0, 8), 7000, chemfire = CHEM_FIRE_RED)
				if(!istype(T, /turf/space))
					SPAWN(max(10, rand(20))) // let's burn right the fuck through the floor
						switch(volume)
							if(0 to 15)
								if(prob(15))
									//T.visible_message(SPAN_ALERT("[T] melts!"))
									T.ex_act(2)
							if(16 to INFINITY)
								//T.visible_message(SPAN_ALERT("[T] melts!"))
								T.ex_act(2)
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == TOUCH || method == INGEST)
					var/mob/living/L = M
					if(istype(L))
						L.update_burning(90)
				if (method == INGEST)
					M.TakeDamage("All", 0, clamp(volume * 6, 30, 90), 0, DAMAGE_BURN)
					boutput(M, SPAN_ALERT("It burns!"))
					M.emote("scream")
				return

			on_mob_life(var/mob/M, var/mult = 1)

				var/mob/living/L = M
				if(istype(L))
					L.update_burning(50 * mult)
				..()

		combustible/pyrosium // COGWERKS CHEM REVISION PROJECT. pretty much a magic chem, can leave alone
			name = "pyrosium"
			id = "pyrosium"
			description = "This strange compound seems to slowly heat up all by itself. Very sticky."
			reagent_state = LIQUID
			fluid_r = 100
			fluid_g = 200
			fluid_b = 150
			transparency = 150
			viscosity = 0.7
			minimum_reaction_temperature = 1000
			fluid_flags = FLUID_SMOKE_BANNED

			reaction_temperature(exposed_temperature, exposed_volume)
				holder.del_reagent(id)

		combustible/argine
			name = "argine"
			id = "argine"
			description = "This strange material seems to ignite & explode on low temperatures."
			reagent_state = LIQUID
			fluid_r = 50
			fluid_g = 200
			fluid_b = 200
			transparency = 200
			viscosity = 0.6
			volatility = 3
			minimum_reaction_temperature = -INFINITY


			reaction_temperature(exposed_temperature, exposed_volume)
				if(exposed_temperature < T0C)
					if(holder)
						var/list/covered = holder.covered_turf()
						var/density = clamp(src.volume / length(covered), 0, 10)
						for (var/turf/T in covered)//may need to further limit this
							explosion_new(holder.my_atom, T, 62 * (density/10)**1.5, 1)

						holder.del_reagent(id)

			reaction_obj(var/obj/O, var/volume)
				return
			reaction_turf(var/turf/T, var/volume)
				return

		combustible/sorium
			name = "sorium"
			id = "sorium"
			description = "Flammable material that causes a powerful shockwave on detonation."
			reagent_state = LIQUID
			fluid_r = 90
			fluid_g = 100
			fluid_b = 200
			transparency = 200
			viscosity = 0.6
			volatility = 1.25
			minimum_reaction_temperature = T0C + 200

			reaction_temperature(exposed_temperature, exposed_volume)
				if(!src.reacting)
					src.reacting = sorium_reaction(holder, volume, id)


			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				return

		combustible/liquiddarkmatter
			name = "liquid dark matter"
			id = "ldmatter"
			description = "What has science done ... It's concentrated dark matter in liquid form. And i thought you needed plutonic quarks for that."
			reagent_state = LIQUID
			fluid_r = 33
			fluid_g = 0
			fluid_b = 33
			value = 6 // 3 1 1 1
			viscosity = 0.9
			volatility = 1.5 // lol no
			minimum_reaction_temperature = T0C+200

			reaction_temperature(exposed_temperature, exposed_volume)
				if(!src.reacting)
					var/list/covered = holder.covered_turf()
					if (length(covered) > 1 && ((exposed_volume / length(covered)) > 0.5))
						return

					src.reacting = ldmatter_reaction(holder, volume, id)

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				return

		combustible/something
			name = "something"
			id = "something"
			description = "What is this thing?  None of the normal tests have been able to determine what exactly this is, just that it is benign."
			reagent_state = LIQUID
			fluid_r = 100
			fluid_g = 100
			fluid_b = 100
			transparency = 250
			viscosity = 0.2

		combustible/fuel // COGWERKS CHEM REVISION PROJECT. treat like acetylene or similar basic hydrocarbons for other reactions
			name = "welding fuel"
			id = "fuel"
			description = "A highly flammable blend of basic hydrocarbons, mostly Acetylene. Useful for both welding and organic chemistry, and can be fortified into a heavier oil."
			reagent_state = LIQUID
			volatility = 1
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			transparency = 230
			viscosity = 0.2
			minimum_reaction_temperature = T0C + 200
			depletion_rate = 0.6
			heat_capacity = 5

			var/max_radius = 7
			var/min_radius = 0
			var/volume_radius_modifier = -0.15
			var/volume_radius_multiplier = 0.09
			var/explosion_threshold = 100
			var/min_explosion_radius = 0
			var/max_explosion_radius = 4
			var/volume_explosion_radius_multiplier = 0.005
			var/volume_explosion_radius_modifier = 0


			var/caused_fireflash = 0
			var/min_req_fluid = 0.1 //at least 10% of the fluid needs to be oil for it to ignite

			reaction_temperature(exposed_temperature, exposed_volume)
				if(volume < 1)
					if (holder)
						holder.del_reagent(id)
					return

				if (caused_fireflash)
					return
				else
					var/list/covered = holder.covered_turf()
					if (length(covered) < 4 || (volume / holder.total_volume) > min_req_fluid)
						if(length(covered) > 0) //possible fix for bug where caused_fireflash was set to 1 without fireflash going off, allowing fuel to reach any temp without igniting
							caused_fireflash = 1
						for(var/turf/turf in covered)
							var/radius = clamp(((volume/covered.len) * volume_radius_multiplier + volume_radius_modifier), min_radius, max_radius)
							fireflash_melting(turf, radius, 2200 + radius * 250, radius * 50, chemfire = CHEM_FIRE_RED)
							if(holder && volume/length(covered) >= explosion_threshold)
								if(holder.my_atom)
									holder.my_atom.visible_message(SPAN_ALERT("<b>[holder.my_atom] explodes!</b>"))
									// Added log entries (Convair880).
									if(holder.my_atom.fingerprintslast || usr?.last_ckey)
										message_admins("Welding Fuel explosion (inside [holder.my_atom], reagent type: [id]) at [log_loc(holder.my_atom)]. Last touched by: [holder.my_atom.fingerprintslast ? "[key_name(holder.my_atom.fingerprintslast)]" : "*null*"] (usr: [ismob(usr) ? key_name(usr) : usr]).")
									logTheThing(LOG_BOMBING, holder.my_atom.fingerprintslast, "Welding Fuel explosion (inside [holder.my_atom], reagent type: [id]) at [log_loc(holder.my_atom)]. Last touched by: [holder.my_atom.fingerprintslast ? "[key_name(holder.my_atom.fingerprintslast)]" : "*null*"] (usr: [ismob(usr) ? key_name(usr) : usr]).")
								else
									turf.visible_message(SPAN_ALERT("<b>[holder.my_atom] explodes!</b>"))
									// Added log entries (Convair880).
									message_admins("Welding Fuel explosion ([turf], reagent type: [id]) at [log_loc(turf)].")
									logTheThing(LOG_BOMBING, null, "Welding Fuel explosion ([turf], reagent type: [id]) at [log_loc(turf)].")

								var/boomrange = clamp(round((volume/covered.len) * volume_explosion_radius_multiplier + volume_explosion_radius_modifier), min_explosion_radius, max_explosion_radius)
								explosion(holder.my_atom, turf, -1,-1,boomrange,1)
				if (caused_fireflash)
					holder?.del_reagent(id)

			reaction_obj(var/obj/O, var/volume)
				return 1

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == TOUCH)
					var/mob/living/L = M
					if(istype(L) && L.getStatusDuration("burning"))
						L.changeStatus("burning", 30 SECONDS)
				return 1

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if(istype(M, /mob/living/) && M.getStatusDuration("burning"))
					M.changeStatus("burning", 2 SECONDS * mult)
				if((M.health > 20) && (prob(33)))
					M.take_toxin_damage(1 * mult)
				if(probmult(20))
					M.nauseate(1)
				..()

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.poison_damage += 1

		// cogwerks - gunpowder test. IS THIS A TERRIBLE GODDAMN IDEA? PROBABLY

		combustible/blackpowder
			name = "black powder"
			id = "blackpowder"
			description = "A dangerous explosive material."
			reagent_state = SOLID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			volatility = 2.5
			transparency = 255
			depletion_rate = 0.05
			penetrates_skin = 1 // think of it as just being all over them i guess
			minimum_reaction_temperature = T0C+200
			fluid_flags = FLUID_BANNED | FLUID_STACKING_BANNED

			reaction_temperature(exposed_temperature, exposed_volume)
				if(src.reacting)
					return

				src.reacting = 1
				var/list/covered = holder.covered_turf()

				for(var/turf/location in covered)
					var/our_amt = holder.get_reagent_amount(src.id) / length(covered)

					if (our_amt < 10 && length(covered) > 5)
						if (prob(min(covered.len/3,85)))
							continue

					elecflash(location)
					SPAWN(rand(5,15))
						if(!holder || !holder.my_atom) return // runtime error fix
						switch(our_amt)
							if(0 to 20)
								holder.my_atom.visible_message("<b>The black powder ignites!</b>")
								if (length(covered) < 5 || prob(5))
									var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
									smoke.set_up(1, 0, location)
									smoke.start()
								explosion(holder.my_atom, location, -1, -1, pick(0,1), 1)
								if (length(covered) > 1)
									holder.remove_reagent(id, our_amt)
								else
									holder.del_reagent(id)
							if(21 to 80)
								holder.my_atom.visible_message("<b>[holder.my_atom] flares up!</b>")
								fireflash(location,0, chemfire = CHEM_FIRE_RED)
								explosion(holder.my_atom, location, -1, -1, 1, 2)
								if (length(covered) > 1)
									holder.remove_reagent(id, our_amt)
								else
									holder.del_reagent(id)
							if(81 to 160)
								holder.my_atom.visible_message(SPAN_ALERT("<b>[holder.my_atom] explodes!</b>"))
								explosion(holder.my_atom, location, -1, 1, 2, 3)
								if (length(covered) > 1)
									holder.remove_reagent(id, our_amt)
								else
									holder.del_reagent(id)
							if(161 to 300)
								holder.my_atom.visible_message(SPAN_ALERT("<b>[holder.my_atom] violently explodes!</b>"))
								explosion(holder.my_atom, location, 1, 3, 6, 8)
								if (length(covered) > 1)
									holder.remove_reagent(id, our_amt)
								else
									holder.del_reagent(id)
							if(301 to INFINITY)
								holder.my_atom.visible_message(SPAN_ALERT("<b>[holder.my_atom] detonates in a huge blast!</b>"))
								explosion(holder.my_atom, location, 3, 6, 12, 15)
								if (length(covered) > 1)
									holder.remove_reagent(id, our_amt)
								else
									holder.del_reagent(id)
						if(istype(holder?.my_atom, /obj))
							var/obj/container = holder.my_atom
							container.shatter_chemically(projectiles = TRUE)

			reaction_obj(var/obj/O, var/volume)
				return

			reaction_turf(var/turf/T, var/volume)
				if(!istype(T, /turf/space))
					//if(volume >= 5)
					if(!locate(/obj/decal/cleanable/dirt) in T)
						var/obj/decal/cleanable/dirt/D = make_cleanable(/obj/decal/cleanable/dirt,T)
						D.name = "black powder"
						D.desc = "Uh oh. Someone better clean this up!"
						if(!D.reagents) D.create_reagents(10)
						D.reagents.add_reagent("blackpowder", 5, null)

			reaction_mob(var/mob/living/carbon/human/M, var/method=TOUCH, var/volume, var/paramslist = 0, var/raw_volume)
				. = ..()
				if (ishuman(M) && raw_volume >= 10)
					M.gunshot_residue = TRUE


		combustible/nitrogentriiodide
			//This is the parent and should not be spawned
			name = "Nitrogen Triiodide"
			id = "nitrotri_parent"
			description = "A chemical that is stable when in liquid form, but becomes extremely volatile when dry."
			random_chem_blacklisted = 1
			reagent_state = LIQUID
			penetrates_skin = 1
			volatility = 2
			fluid_r = 48
			fluid_g = 22
			fluid_b = 64
			minimum_reaction_temperature = T0C+100
			var/is_dry = 0

			proc/bang()
				if(holder?.my_atom)
					holder.my_atom.visible_message("<b>The powder detonates!</b>")

					var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
					smoke.set_up(1, 0, holder.my_atom.loc)
					smoke.start()

					elecflash(holder.my_atom.loc)

					var/max_dev = min(round(1 * (volume/300)), 1)
					var/max_heavy = min(round(3 * (volume/300)), 3)
					var/max_light = min(round(6 * (volume/300)), 6)
					var/max_flash = min(round(9 * (volume/300)), 9)

					explosion(holder.my_atom, holder.my_atom.loc, max_dev, max_heavy, max_light, max_flash)

					var/datum/reagents/H = holder
					SPAWN(0)
						H.del_reagent("nitrotri_wet")
						H.del_reagent("nitrotri_dry")
						H.del_reagent("nitrotri_parent")

			proc/dry()
				if(is_dry) return
				is_dry = 1
				var/datum/reagents/H = holder
				var/vol = volume
				if(!H)
					return
				H.del_reagent(reagent="nitrotri_wet")
				H.add_reagent(reagent="nitrotri_dry", amount=vol, donotreact=1)


			reaction_turf(var/turf/T, var/volume)
				if(!istype(T, /turf/space) && volume >= 5 && !locate(/obj/decal/cleanable/nitrotriiodide) in T)
					return make_cleanable(/obj/decal/cleanable/nitrotriiodide,T)

			reaction_temperature(exposed_temperature, exposed_volume)
				dry()

		combustible/nitrogentriiodide/wet
			id = "nitrotri_wet"
			random_chem_blacklisted = 1
			volatility = 2
			viscosity = 0.3

			New()
				..()
				SPAWN(200 + rand(10, 600) * rand(1, 4)) //Random time until it becomes HIGHLY VOLATILE
					dry()

		combustible/nitrogentriiodide/dry
			id = "nitrotri_dry"
			random_chem_blacklisted = 1
			volatility = 2.5
			description = "A chemical that is stable when in liquid form, but becomes extremely volatile when dry. This is dry. Uh oh."
			is_dry = 1
			reagent_state = SOLID
			minimum_reaction_temperature = -INFINITY

			New()
				..()
				SPAWN(10 * rand(11,600)) //At least 11 seconds, at most 10 minutes
					bang()

			reaction_turf(var/turf/T, var/volume)
				var/obj/decal/cleanable/nitrotriiodide/NT = ..()
				if(NT)
					NT.Dry() 	//Welp
					NT.bang()	//What did you expect would happen when splashing THE HIGHLY VOLATILE POWDER on the floor

			reaction_temperature(exposed_temperature, exposed_volume)
				bang()

		combustible/photophosphide
			id = "photophosphide"
			name = "photophosphide"
			random_chem_blacklisted = TRUE //probably for the best ??
			description = "A photosensitive explosive reagent that detonates when exposed to relatively small amounts of light."
			reagent_state = SOLID
			fluid_r = 149
			fluid_g = 119
			fluid_b = 163
			transparency = 255
			taste = "sandy"
			fluid_flags = FLUID_BANNED | FLUID_STACKING_BANNED | FLUID_SMOKE_BANNED

			reaction_turf()
				return
