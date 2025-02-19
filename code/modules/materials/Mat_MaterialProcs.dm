/*
triggerOnAttacked(var/obj/item/owner, var/mob/attacker, var/mob/attacked, var/atom/weapon)
triggerOnAttack(var/obj/item/owner, var/mob/attacker, var/mob/attacked)
triggerOnLife(var/mob/M, var/obj/item/I)
triggerOnAdd(var/owner)
triggerChem(var/location, var/chem, var/amount)
triggerPickup(var/mob/M, var/obj/item/I)
triggerDrop(var/mob/M, var/obj/item/I)
triggerTemp(var/owner, var/temp)
triggerExp(var/owner, var/severity)
triggerOnEntered(var/atom/owner, var/atom/entering)
*/

// THINGS LIKE GOLD SPARKLES ARE NOT REMOVED WHEN MATERIAL CHANGES!. MOVE THESE TO NEW APPEARANCE SYSTEM.

/datum/materialProc
	/// After how many material "generations" this trait disappears. `-1` = does not disappear.
	var/max_generations = 2
	/// Optional simple sentence that describes how the traits appears on the material. i.e. "It is shiny."
	var/desc = ""

	proc/execute()
		return
/*
/datum/materialProc/oneat_flesh
	max_generations = -1

	execute(var/mob/M, var/obj/item/I)
		M.reagents.add_reagent("prions", 15)
		return
*/

/datum/materialProc/onpickup_butt
	var/static/list/sound_fart = list('sound/voice/farts/poo2.ogg', \
								'sound/voice/farts/fart1.ogg', \
								'sound/voice/farts/fart2.ogg', \
								'sound/voice/farts/fart3.ogg', \
								'sound/voice/farts/fart4.ogg', \
								'sound/voice/farts/fart5.ogg')

	execute(var/mob/M, var/obj/item/I)
		if(prob(10) && !ON_COOLDOWN(I, "material_fart", 2 SECONDS))
			playsound(I, pick(src.sound_fart), 40, 0 , 0, (1.5 - rand()), channel=VOLUME_CHANNEL_EMOTE)
			M.visible_message(SPAN_EMOTE("\the [I] lets out a little toot as [M] squeezes it."))

/datum/materialProc/oneat_viscerite
	max_generations = -1

	execute(var/mob/M, var/obj/item/I)
		M.reagents.add_reagent("loose_screws", 15)
		return

/datum/materialProc/oneat_blob
	max_generations = -1

	execute(var/mob/M, var/obj/item/I)
		M.TakeDamage("chest", 10, 0)
		M.reagents.add_reagent("e.coli", 20)
		return

/datum/materialProc/ethereal_add
	desc = "It is almost impossible to grasp."
	max_generations = 1
	execute(var/atom/owner)
		APPLY_ATOM_PROPERTY(owner, PROP_ATOM_NEVER_DENSE, "ethereal")
		owner.set_density(0)
		return

/datum/materialProc/ffart_add
	desc = "It's very hard to move around."
	max_generations = 1

/datum/materialProc/ffart_pickup
	execute(var/mob/M, var/obj/item/I)
		if(!I.cant_drop)
			SPAWN(2 SECOND) //1 second is a little to harsh to since it slips right out of the nanofab/cruicble
				if(I in M.get_all_items_on_mob())
					M.remove_item(I)
					I.set_loc(get_turf(I))
		return

/datum/materialProc/brullbar_temp_onlife
	desc = "It feels furry."

	execute(var/mob/M, var/obj/item/I, mult)
		M?.bodytemperature = 310
		return

/datum/materialProc/generic_reagent_onattacked
	var/trigger_chance = 100
	var/limit = 0
	var/limit_count = 0
	var/lastTrigger = 0
	var/trigger_delay = 0
	var/reagent_id = ""
	var/reagent_amount = 0

	New(var/reagid = "carbon", var/amt = 2, var/chance = 100, var/limit_t = 0, var/tdelay = 50)
		trigger_chance = chance
		limit = limit_t
		trigger_delay = tdelay
		reagent_id = reagid
		reagent_amount = amt
		..()

	execute(var/atom/owner, var/mob/attacker, var/mob/attacked, var/atom/weapon)
		if(limit && limit_count >= limit) return
		if(world.time - lastTrigger < trigger_delay) return
		lastTrigger = world.time
		if(prob(trigger_chance))
			if(attacked.reagents)
				attacked.reagents.add_reagent(reagent_id, reagent_amount, null, T0C)
		return

/datum/materialProc/generic_explode_attack
	var/trigger_chance = 100
	var/explode_limit = 0
	var/explode_count = 0
	var/lastTrigger = 0

	desc = "It looks dangerously unstable."

	New(var/chance = 100, var/limit = 0)
		trigger_chance = chance
		explode_limit = limit
		..()

	execute(var/atom/owner)
		if(explode_limit && explode_count >= explode_limit) return
		if(world.time - lastTrigger < 50) return
		lastTrigger = world.time
		if(prob(trigger_chance))
			explode_count++
			var/turf/tloc = get_turf(owner)
			explosion(owner, tloc, 0, 1, 2, 3)
			tloc.visible_message(SPAN_ALERT("[owner] explodes!"))
			if(isitem(owner))
				var/obj/item/deleted_item = owner
				qdel(deleted_item)
			if(owner && istype(owner, /turf/simulated/wall))
				//if an erebite wall is exploded and still standing, let's rather dismantle it
				//noone would like repeatable exploding of reinforced erebite walls
				var/turf/simulated/wall/dismantled_wall = owner
				dismantled_wall.dismantle_wall(1)
		return

/datum/materialProc/generic_fireflash
	execute(var/atom/owner, var/temp)
		if(temp < T0C + 200)
			return
		if(ON_COOLDOWN(owner, "generic_mat_fireflash", 120 SECONDS))
			return
		fireflash(get_turf(owner), 1, chemfire = CHEM_FIRE_RED)
		return

/datum/materialProc/generic_itchy_onlife
	desc = "It makes your hands itch."

	execute(var/mob/M, var/obj/item/I, mult)
		if(issilicon(M)) return // silicons can't get itchy
		if(probmult(20)) M.emote(pick("twitch", "laugh", "sneeze", "cry"))
		if(probmult(10))
			boutput(M, SPAN_NOTICE("<b>Something tickles!</b>"))
			M.emote(pick("laugh", "giggle"))
		if(probmult(8))
			M.visible_message(SPAN_ALERT("<b>[M.name]</b> scratches at an itch."))
			random_brute_damage(M, 1)
			M.changeStatus("stunned", 1 SECOND)
			M.emote("grumble")
		if(probmult(8))
			boutput(M, SPAN_ALERT("<b>So itchy!</b>"))
			random_brute_damage(M, 2)
		if(probmult(1))
			boutput(M, SPAN_ALERT("<b><font size='[rand(2,5)]'>AHHHHHH!</font></b>"))
			random_brute_damage(M,5)
			M.changeStatus("knockdown", 5 SECONDS)
			M.make_jittery(6)
			M.visible_message(SPAN_ALERT("<b>[M.name]</b> falls to the floor, scratching themselves violently!"))
			M.emote("scream")
		return

/datum/materialProc/generic_reagent_onattack_depleting
	var/reag_id = "carbon"
	var/reag_amt = 1
	var/reag_chance = 10
	var/charges_left = 10

	New(var/reagent_id = "carbon", var/amount = 1, var/chance = 10, var/charges = 10)
		reag_id = reagent_id
		reag_amt = amount
		reag_chance = chance
		charges_left = charges
		..()

	execute(var/atom/owner, var/mob/attacker, var/atom/attacked)
		var/mob/attacked_mob = attacked
		if(attacked_mob && prob(reag_chance) && attacked_mob?.reagents)
			charges_left--
			attacked_mob.reagents.add_reagent(reag_id, reag_amt, null, T0C)
			if(!charges_left)
				if(owner.material)
					owner.material.removeTrigger(TRIGGERS_ON_ATTACK, src.type)
		return

/datum/materialProc/generic_reagent_onattack
	var/reag_id = "carbon"
	var/reag_amt = 1
	var/reag_chance = 10

	New(var/reagent_id = "carbon", var/amount = 1, var/chance = 10)
		reag_id = reagent_id
		reag_amt = amount
		reag_chance = chance
		..()

	execute(var/atom/owner, var/mob/attacker, var/atom/attacked)
		var/mob/attacked_mob = attacked
		if(attacked_mob && prob(reag_chance) && attacked_mob?.reagents)
			attacked_mob.reagents.add_reagent(reag_id, reag_amt, null, T0C)
		return

/datum/materialProc/generic_reagent_onlife
	var/reag_id = "carbon"
	var/reag_amt = 1

	New(var/reagent_id = "carbon", var/amount = 1)
		reag_id = reagent_id
		reag_amt = amount
		..()

	execute(var/mob/M, var/obj/item/I, mult)
		if(M?.reagents)
			M.reagents.add_reagent(reag_id, reag_amt * mult, null, T0C)
		return

/datum/materialProc/generic_reagent_onlife_depleting
	var/reag_id = "carbon"
	var/reag_amt = 1
	var/max_volume = 0
	var/added = 0

	New(var/reagent_id = "carbon", var/amount = 1, var/maxadd = 50)
		reag_id = reagent_id
		reag_amt = amount
		max_volume = maxadd
		..()

	execute(var/mob/M, var/obj/item/I, mult)
		if(M?.reagents)
			M.reagents.add_reagent(reag_id, reag_amt * mult, null, T0C)
			added += reag_amt * mult
			if(added >= max_volume)
				if(I.material)
					I.material.removeTrigger(TRIGGERS_ON_LIFE, src.type)
		return

/datum/materialProc/generic_explosive
	execute(var/atom/owner, var/temp)
		if(temp < T0C + 100)
			return
		if(ON_COOLDOWN(owner, "generic_mat_explosive", 10 SECONDS))
			return
		var/turf/tloc = get_turf(owner)
		explosion(owner, tloc, 1, 2, 3, 4)
		owner.visible_message(SPAN_ALERT("[owner] explodes!"))
		return

/datum/materialProc/flash_hit
	desc = "Every now and then it produces some bright sparks."

	execute(var/atom/owner, var/mob/attacker, var/atom/attacked, var/atom/weapon)
		if(ON_COOLDOWN(owner, "mat_flash_hit", 60 SECONDS))
			return
		attacked.visible_message(SPAN_ALERT("[owner] emits a flash of light!"))
		for (var/mob/living/carbon/M in all_viewers(5, attacked))
			M.apply_flash(8, 0, 0, 0, 3)

/datum/materialProc/smoke_hit
	desc = "Faint wisps of smoke rise from it."

	execute(var/atom/owner, var/mob/attacker, var/atom/attacked, var/atom/weapon)
		if(ON_COOLDOWN(owner, "mat_flash_hit", 20 SECONDS))
			return
		attacked.visible_message(SPAN_ALERT("[owner] emits a puff of smoke!"))
		for(var/turf/T in view(1, attacked))
			harmless_smoke_puff(get_turf(T))

/datum/materialProc/gold_add
	desc = "It's very shiny."
	execute(var/location)
		if(!particleMaster.CheckSystemExists(/datum/particleSystem/sparkles, location))
			particleMaster.SpawnSystem(new /datum/particleSystem/sparkles(location))
		return

/datum/materialProc/telecrystal_entered
	execute(var/atom/owner, var/atom/movable/entering)
		if (isobserver(entering) || isintangible(entering) || entering.anchored)
			return
		if(ON_COOLDOWN(entering, "telecrystal_warp", 1 SECOND))
			return
		var/turf/T = get_turf(entering)
		if(prob(50) && owner && isturf(owner) && !isrestrictedz(T.z))
			. = get_offset_target_turf(get_turf(entering), rand(-2, 2), rand(-2, 2))
			entering.visible_message(SPAN_ALERT("[entering] is warped away!"))
			playsound(T, "warp", 50)
			if(ismob(entering))
				boutput(entering, SPAN_ALERT("You suddenly teleport..."))
			entering.set_loc(.)
		return


/datum/materialProc/telecrystal_onattack
	execute(var/atom/owner, var/mob/attacker, var/atom/attacked)
		var/turf/T = get_turf(attacked)
		var/mob/attacked_mob = attacked
		if(!istype(attacked_mob) || attacked_mob.anchored || ON_COOLDOWN(attacked_mob, "telecrystal_warp", 1 SECOND))
			return
		if(prob(33) && !isrestrictedz(T.z)) // Haine fix for undefined proc or verb /turf/simulated/floor/set loc()
			. = get_offset_target_turf(get_turf(attacked_mob), rand(-8, 8), rand(-8, 8))
			var/fail_msg = ""
			if (prob(25) && attacker == attacked_mob && isitem(owner))
				var/obj/item/used_item = owner
				fail_msg = " but you lose [used_item]!"
				attacker.drop_item(used_item)
				playsound(attacker.loc, 'sound/effects/poof.ogg', 90)
			else
				playsound(attacker.loc, "warp", 50)
			attacked_mob.visible_message(SPAN_ALERT("[attacked_mob] is warped away!"))
			boutput(attacked_mob, SPAN_ALERT("You suddenly teleport... [fail_msg]"))
			attacked_mob.set_loc(.)

/datum/materialProc/telecrystal_life
	execute(var/mob/M, var/obj/item/I, mult)
		if(M.anchored || ON_COOLDOWN(M, "telecrystal_warp", 1 SECOND))
			return
		var/turf/T = get_turf(M)
		if(probmult(5) && M && !isrestrictedz(T.z))
			. = get_offset_target_turf(get_turf(M), rand(-8, 8), rand(-8, 8))
			M.visible_message(SPAN_ALERT("[M] is warped away!"))
			playsound(M.loc, "warp", 50)
			boutput(M, SPAN_ALERT("You suddenly teleport..."))
			M.set_loc(.)
		return

/datum/materialProc/plasmastone
	execute(var/atom/location) //exp and temp both have the location as first argument so i can use this for both.
		var/turf/T = get_turf(location)
		if(!T || T.density || !istype(location))
			return
		if(!location.material.isMutable()) //this is a little hacky, but basically ensure it's mutable and then do the trigger
			location.material = location.material.getMutable()
			return location.material.triggerTemp(location, 0)
		var/total_plasma = location.material.getProperty("plasma_offgas")
		if(total_plasma <= 0)
			if(prob(2) && location)
				location.visible_message("<span class='alert>[location] dissipates.</span>")
				qdel(location)
			return
		if(ON_COOLDOWN(location, "plasmastone_plasma_generate", 5 SECONDS)) return
		var/list/turf/simulated/floor/valid_turfs = list()
		for (var/turf/simulated/floor/target in range(1,location))
			if(target.gas_cross(target) && target.air)
				valid_turfs += target
		if(length(valid_turfs))
			var/turf/simulated/floor/target = pick(valid_turfs)
			if(target.parent?.group_processing)
				target.parent.suspend_group_processing()

			var/datum/gas_mixture/payload = new /datum/gas_mixture
			payload.toxins = 25 * location.material_amt
			total_plasma -= 1
			payload.temperature = T20C
			payload.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
			target.air.merge(payload)
			location.material.setProperty("plasma_offgas", total_plasma)

/datum/materialProc/plasmastone_on_hit
	execute(var/atom/owner)
		owner.material.triggerTemp(locate(owner))

/datum/materialProc/molitz_temp
	max_generations = 1

	proc/find_molitz(datum/material/material)
		if (istype(material, /datum/material/crystal/molitz))
			return material
		var/datum/material/interpolated/alloy = material
		if (istype(alloy))
			return locate(/datum/material/crystal/molitz) in alloy.getParentMaterials()

	execute(var/atom/owner, var/temp, var/agent_b=FALSE)
		if(temp < 500) return //less than reaction temp

		var/datum/material/crystal/molitz/molitz = src.find_molitz(owner.material)
		if (!istype(molitz))
			CRASH("Molitz_temp material proc applied to non-molitz thing") //somehow applied to non-molitz
		var/iterations = owner.material.getProperty("molitz_bubbles")
		if(iterations <= 0)
			owner.setMaterial(getMaterial("molitz_expended"))
			return

		var/datum/gas_mixture/air = owner.return_air() || owner.loc.return_air()
		if(!istype(air))
			var/turf/target = get_turf(owner)
			air = target?.return_air()

		if(!istype(air)) return //all air finding has failed, so stop

		if(ON_COOLDOWN(owner, "molitz_gas_generate", 30 SECONDS)) return

		//okay, now we've passed all the conditions for gas generation - do that
		if(!owner.material.isMutable()) //this is a little hacky, but basically ensure it's mutable and then do the trigger
			owner.material = owner.material.getMutable()
			return owner.material.triggerTemp(owner, temp)
		var/datum/gas_mixture/payload = new /datum/gas_mixture

		if(agent_b && air.toxins > MINIMUM_REACT_QUANTITY)
			payload.oxygen_agent_b += 0.18 * owner.material_amt
			payload.oxygen = 15 * owner.material_amt
			payload.temperature = T0C //reduced temp is supposeed to represent endothermic reaction
			air.merge(payload) //add it to the target air

			//sparkles
			animate_flash_color_fill_inherit(owner,"#ff0000",4, 2 SECONDS)
			playsound(owner, 'sound/effects/leakagentb.ogg', 50, TRUE, 8)
			if(!particleMaster.CheckSystemExists(/datum/particleSystem/sparklesagentb, owner))
				particleMaster.SpawnSystem(new /datum/particleSystem/sparklesagentb(owner))
		else //no plasma present, or this is just normal molitz - you get just plain oxygen
			payload.oxygen = 80 * owner.material_amt
			payload.temperature = temp
			air.merge(payload) //add it to the target air
			//blue sparkles
			animate_flash_color_fill_inherit(owner,"#0000FF",4, 2 SECONDS)
			playsound(owner, 'sound/effects/leakoxygen.ogg', 50, TRUE, 5)


		owner.material.setProperty("molitz_bubbles", iterations-1)


/datum/materialProc/molitz_temp/agent_b
	max_generations = 1
	execute(var/atom/location, var/temp)
		..(location, temp, TRUE)
		return

/datum/materialProc/molitz_exp
	max_generations = 1
	execute(var/atom/owner, var/sev)
		if(!istype(owner.material, /datum/material/crystal/molitz))
			return
		var/datum/material/crystal/molitz/molitz = owner.material
		var/iterations = molitz.getProperty("molitz_bubbles")
		if(iterations <= 0) return
		if(!owner.material.isMutable()) //this is a little hacky, but basically ensure it's mutable and then do the trigger
			owner.material = owner.material.getMutable()
			return owner.material.triggerExp(owner, sev)
		var/turf/target = get_turf(owner)
		if(sev > 0 && sev < 4) // Use pipebombs not canbombs!
			if(iterations >= 1)
				playsound(owner, 'sound/effects/leakoxygen.ogg', 50, TRUE, 5)
			if(iterations == 0)
				playsound(owner, 'sound/effects/molitzcrumble.ogg', 50, TRUE, 5)
			var/datum/gas_mixture/payload = new /datum/gas_mixture
			payload.oxygen = 50
			payload.temperature = T20C
			target.assume_air(payload)
			molitz.setProperty("molitz_bubbles", iterations-2)


/datum/materialProc/miracle_add
	execute(var/location)
		animate_rainbow_glow(location)
		return

/datum/materialProc/radioactive_add
	execute(var/atom/location)
		animate_flash_color_fill_inherit(location, "#1122EE", -1, 40)
		location.AddComponent(/datum/component/radioactive, location.material.getProperty("radioactive")*10, FALSE, FALSE, 1)
		return

/datum/materialProc/radioactive_remove
	execute(var/atom/location)
		animate_flash_color_fill_inherit(location, "#1122EE", -1, 40)
		var/datum/component/radioactive/R = location.GetComponent(/datum/component/radioactive)
		R?.RemoveComponent()
		return

/datum/materialProc/n_radioactive_add
	execute(var/atom/location)
		animate_flash_color_fill_inherit(location, "#1122EE", -1, 40)
		location.AddComponent(/datum/component/radioactive, location.material.getProperty("n_radioactive")*10, FALSE, TRUE, 1)
		return

/datum/materialProc/n_radioactive_remove
	execute(var/atom/location)
		animate_flash_color_fill_inherit(location, "#1122EE", -1, 40)
		var/datum/component/radioactive/R = location.GetComponent(/datum/component/radioactive)
		R?.RemoveComponent()
		return

/datum/materialProc/erebite_flash
	execute(var/location)
		animate_flash_color_fill_inherit(location,"#FF7711",-1,10)
		return

/datum/materialProc/erebite_temp
	execute(var/atom/owner, var/temp)
		if(temp < T0C + 900) return
		if(ON_COOLDOWN(owner, "erebite_temp", 10 SECONDS))
			return
		if((temp < T0C + 1200) && prob(80)) return //some leeway for triggering at lower temps
		var/turf/tloc = get_turf(owner)
		explosion(owner, tloc, 0, 1, 2, 3)
		owner.visible_message(SPAN_ALERT("[owner] explodes!"))
		return

/datum/materialProc/erebite_exp
	execute(var/atom/owner, var/sev)
		if(ON_COOLDOWN(owner, "erebite_exp", 10 SECONDS))
			return
		var/turf/tloc = get_turf(owner)
		if(sev > 0 && sev < 4)
			owner.visible_message(SPAN_ALERT("[owner] explodes!"))
			switch(sev)
				if(1)
					explosion(owner, tloc, 0, 1, 2, 3)
				if(2)
					explosion(owner, tloc, -1, 0, 1, 2)
				if(3)
					explosion(owner, tloc, -1, -1, 0, 1)
			qdel(owner)
		return

/datum/materialProc/slippery_attack
	execute(var/atom/owner, var/mob/attacker, var/atom/attacked)
		if (isitem(owner) && prob(20) && (owner in attacker.equipped_list()))
			var/obj/item/handled_item = owner
			boutput(attacker, SPAN_ALERT("[handled_item] slips right out of your hand!"))
			handled_item.set_loc(attacker.loc)
			handled_item.dropped(attacker)
		return

/datum/materialProc/slippery_entered
	execute(var/atom/owner, var/atom/movable/entering)
		if (isliving(entering) && isturf(owner) && prob(75) && !isintangible(entering))
			var/mob/living/L = entering
			if(L.slip(walking_matters = 1))
				boutput(L, "You slip on the icy floor!")
				playsound(owner, 'sound/misc/slip.ogg', 30, TRUE)
		return

/datum/materialProc/ice_life
	desc = "It is slowly melting."

	execute(var/mob/M, var/obj/item/I, mult)
		if (iscarbon(M))
			var/mob/living/carbon/C = M
			if (C.bodytemperature > 0)
				C.bodytemperature -= 2
			if (C.bodytemperature > T0C && probmult(4))
				boutput(C, "Your [I] melts from your body heat!")
				qdel(I)
		return

/datum/materialProc/ice_melt
	desc = "It would melt when exposed to heat."

	execute(var/atom/owner, var/temp)
		if(temp < T0C) return // less than reaction temp

		var/turf/T = get_turf(owner)

		// Make a water puddle and chunks
		if (istype(T))
			if (!istype(owner, /obj/item/raw_material))
				var/obj/item/raw_material/ice/cube = new /obj/item/raw_material/ice(T)
				cube.set_loc(T)
			make_cleanable(/obj/decal/cleanable/water, T)
			owner.visible_message(SPAN_NOTICE("[owner] melts, dissolving into water."))
			playsound(owner, 'sound/misc/drain_glug.ogg', 50, TRUE, 5)
			qdel(owner)

/datum/materialProc/soulsteel_entered
	execute(var/obj/item/owner, var/atom/movable/entering)
		if (!isobj(owner) || owner.anchored >= ANCHORED_ALWAYS) return
		if (istype(entering, /mob/dead/observer) && prob(33))
			var/mob/dead/observer/O = entering
			if(O.observe_round) return
			if(ON_COOLDOWN(owner, "soulsteel_revive", 3 MINUTES))
				boutput(entering, SPAN_ALERT("[owner] can not be possessed again so soon!"))
				return
			var/mob/mobenter = entering
			logTheThing(LOG_COMBAT, mobenter, "soulsteel-possesses [owner] at [log_loc(owner)].")
			if(mobenter.client)
				var/mob/living/object/OB = new/mob/living/object(owner.loc, owner, mobenter)
				OB.health = 8
				OB.max_health = 8
				OB.can_use_say = FALSE
				OB.show_antag_popup("soulsteel")

/datum/materialProc/reflective_onbullet
	execute(var/atom/owner, var/atom/attacked, var/obj/projectile/projectile)
		if(ismob(attacked) && (owner != attacked)) //i made this working on mobs, but let's not make reflective boots make you reflect laser shots, lol
			return
		if(projectile.proj_data.damage_type & D_BURNING || projectile.proj_data.damage_type & D_ENERGY)
			shoot_reflected_bounce(projectile, attacked, 4) //shoot_reflected_to_sender()
		return

/datum/materialProc/negative_add
	execute(var/atom/owner)
		if(isitem(owner))
			var/obj/item/I = owner
			I.no_gravity = 1
			I.AddComponent(/datum/component/loctargeting/no_gravity)
			animate_levitate(owner)
		return

/datum/materialProc/spacelag_add
	execute(atom/owner)
		if (!isturf(owner))
			animate_lag(owner)

/datum/materialProc/temp_miraclium
	execute(var/atom/location, var/temp)
		if(temp < T0C + 100)
			return

		SPAWN(1 SECOND)
			if(location?.material?.getID() == "miracle")
				location.visible_message(SPAN_NOTICE("[location] bends and twists, changing colors rapidly."))
				var/chosen = pick(prob(100); "mauxite",prob(100); "pharosium",prob(100); "cobryl",prob(100); "bohrum",prob(80); "cerenkite",prob(50); "syreline",prob(20); "slag",prob(3); "spacelag",prob(5); "soulsteel",prob(100); "molitz",prob(50); "claretine",prob(5); "erebite",prob(10); "quartz",prob(5); "uqill",prob(10); "telecrystal",prob(1); "starstone",prob(5); "blob",prob(8); "koshmarite",prob(20); "chitin",prob(4); "pizza",prob(15); "beewool",prob(6); "ectoplasm")
				location.setMaterial(getMaterial(chosen), appearance = 1, setname = 1)
		return

/datum/materialProc/enchanted_add
	execute(var/obj/item/owner)
		if(istype(owner))
			owner.enchant(1, setTo = 1)

/datum/materialProc/cardboard_blob_hit
	execute(var/atom/owner, var/blobPower)
		if (istype(owner, /obj))
			owner.visible_message(SPAN_ALERT("[owner] crumples!"), SPAN_ALERT("You hear a crumpling sound."))
			qdel(owner)
		else if (istype(owner, /turf))
			if (istype(owner, /turf/simulated/wall))
				var/turf/simulated/wall/wall_owner = owner
				owner.visible_message(SPAN_ALERT("Part of [owner] shears off under the blobby force! "))
				wall_owner.dismantle_wall(1)

/datum/materialProc/cardboard_on_hit // MARK: add to ignorant children
	execute(var/atom/owner, var/atom/attackatom, var/mob/attacker, var/meleeorthrow)
		if (meleeorthrow == 1) //if it was a melee attack
			if (issnippingtool(attackatom)||iscuttingtool(attackatom))
				if (isExploitableObject(owner))
					boutput(attacker, "Cutting [owner] into a sheet isn't possible.")
					return
				attacker.visible_message(SPAN_ALERT("[attacker] starts cutting [owner] apart."), SPAN_NOTICE("You start cutting [owner] apart."), "You hear the sound of cutting cardboard.")
				var/datum/action/bar/icon/hitthingwithitem/action_bar = new /datum/action/bar/icon/hitthingwithitem(attacker, attacker, attackatom, owner, src, 3 SECONDS, /datum/materialProc/cardboard_on_hit/proc/snip_end,\
				list(owner, attacker, attackatom), attackatom.icon, attackatom.icon_state)
				action_bar.interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED // uh, is this how I'm supposed to do this?
				actions.start(action_bar, attacker)
				return

		var/crumple = FALSE
		if (meleeorthrow == 1)
			if (isitem(attackatom))
				var/obj/item/meleeitem = attackatom
				if (prob(meleeitem.force*3))
					crumple = TRUE
			else
				if (ismob(attackatom) && prob(15)) //for bashing someone else or your laywer hands on cardboard, we calculate with ~ 5 damage
					crumple = TRUE
		else
			if(ismovable(attackatom))
				var/atom/movable/thrownatom = attackatom
				if (prob(thrownatom.throwforce*3))
					crumple = TRUE
		if(crumple)
			if (istype(owner, /obj))
				owner.visible_message(SPAN_ALERT("[owner] crumples!"), SPAN_ALERT("You hear a crumpling sound."))
				if(istype(owner, /obj/storage))
					var/obj/storage/S = owner
					S.dump_contents()
				qdel(owner)
			else if (istype(owner, /turf))
				if (istype(owner, /turf/simulated/wall))
					var/turf/simulated/wall/wall_owner = owner
					owner.visible_message(SPAN_ALERT("[owner] shears apart under the force of [attackatom]! "),SPAN_ALERT("You hear a crumpling sound."))
					logTheThing(LOG_STATION, attacker ? attacker : null, null, "bashed apart a cardboard wall ([owner.name]) using \a [attackatom] at [attacker ? get_area(attacker) : get_area(owner)] ([attacker ? showCoords(attacker.x, attacker.y, attacker.z) : showCoords(owner.x, owner.y, owner.z)])[attacker ? null : ", attacker is unknown, shown location is of the wall"][meleeorthrow == 1 ? ", this was a thrown item" : null]")
					wall_owner.dismantle_wall(1, 0)

				else if (istype(owner, /turf/simulated/floor))
					var/turf/simulated/floor/floor_owner = owner
					if (floor_owner.broken && floor_owner.intact)
						floor_owner.to_plating()
						owner.visible_message("The top layer of [owner] breaks away!", SPAN_ALERT("You hear a crumpling sound."))
					else if (floor_owner.broken && !floor_owner.intact)
						floor_owner.ReplaceWithSpace()
						owner.visible_message(SPAN_ALERT(" [owner] breaks apart, leaving a hole!"), SPAN_ALERT("You hear a crumpling sound.\nYou feel a rapid gust of air, flowing towards the floor!"))
					if (floor_owner.reinforced)
						floor_owner.ReplaceWithFloor()
						floor_owner.to_plating()
						owner.visible_message(SPAN_ALERT("[owner]'s reinforcement breaks apart!"), SPAN_ALERT("You hear a crumpling sound."))
					else if (floor_owner.intact)
						floor_owner.break_tile()
						owner.visible_message("The top layer of [owner] crumples!", "You hear a crumpling sound.")

/datum/materialProc/cardboard_on_hit/proc/snip_end(var/atom/owner, var/mob/attacker, var/atom/attackatom)
	if (istype(owner, /obj))
		attacker.visible_message(SPAN_ALERT("[attacker] cuts [owner] into a sheet."),SPAN_NOTICE("You finish cutting [owner] into a sheet."),"The sound of cutting cardboard stops.")
		var/obj/item/sheet/createdsheet = new /obj/item/sheet(get_turf(owner))
		createdsheet.setMaterial(owner.material)
		if (istype(owner, /obj/storage))
			var/obj/storage/S = owner
			S.dump_contents(attacker)
		qdel(owner)
	else if (istype(owner, /turf))
		if (istype(owner, /turf/simulated/wall))
			var/turf/simulated/wall/wall_owner = owner
			if (istype(owner, /turf/simulated/wall/r_wall) || istype(owner, /turf/simulated/wall/auto/reinforced))
				attacker.visible_message(SPAN_ALERT("[attacker] cuts the reinforcment off [owner]."),"You cut the reinforcement off [owner].","The sound of cutting cardboard stops.")
			else
				attacker.visible_message("[SPAN_ALERT("[attacker] cuts apart the outer cover of [owner]")].","[SPAN_NOTICE("You cut apart the outer cover of [owner]")].","The sound of cutting cardboard stops.")
				logTheThing(LOG_STATION, attacker, "cut apart a cardboard wall ([owner.name]) using \a [attackatom] at [get_area(attacker)] ([log_loc(attacker)])")
			wall_owner.dismantle_wall(0, 0)
		else if (istype(owner, /turf/simulated/floor))
			var/turf/simulated/floor/floor_owner = owner
			if (floor_owner.intact)
				if (!(floor_owner.broken || floor_owner.burnt))
					var/atom/A = new /obj/item/tile(floor_owner)
					A.setMaterial(owner.material)
				attacker.visible_message(SPAN_ALERT("[attacker] cuts off the top tile of [owner]."),SPAN_NOTICE("You cut off the top tile of [owner]."),"The sound of cutting cardboard stops.")
				floor_owner.to_plating()
				return
			if (floor_owner.reinforced)
				var/obj/R1 = new /obj/item/rods(src)
				var/obj/R2 = new /obj/item/rods(src)
				R1.setMaterial(owner.material)
				R2.setMaterial(owner.material)
				floor_owner.ReplaceWithFloor()
				floor_owner.to_plating()
				attacker.visible_message(SPAN_ALERT("[attacker] cuts the reinforcing rods off [owner]."),"You finish cutting the reinforcing rods off of [owner].", "The sound of cutting cardboard stops.")
				return
			if (!floor_owner.intact)
				var/atom/A = new /obj/item/tile(src)
				A.setMaterial(owner.material)
				logTheThing(LOG_STATION, attacker, "cut apart a cardboard floor ([owner.name]) using \a [attackatom] at [get_area(attacker)] ([log_loc(attacker)])")
				attacker.visible_message(SPAN_ALERT("Cuts apart [owner], revealing space!"),SPAN_ALERT("You finish cutting apart [owner], revealing space."),"The sound of cutting cardboard stops.")
				floor_owner.ReplaceWithSpace()
				return

/datum/materialProc/glowstick_add
	desc = "It has a chemical glow."
	max_generations = 1
	var/datum/component/loctargeting/sm_light/light_c

	execute(var/atom/owner)
		var/list/color = rgb2num(owner.material.getColor())
		light_c = owner.AddComponent(/datum/component/loctargeting/sm_light, color[1], color[2], color[3], 255 * 0.33)
		light_c.update(1)

/datum/materialProc/radioactive_temp
	max_generations = -1

	execute(var/atom/owner, var/temp)
		if(ON_COOLDOWN(owner, "radioactive_material_decay_fallout", 5 SECONDS)) return
		// Just sanity checks with ordering to not init what we don't need
		if (temp < 500 KELVIN || !isitem(owner)) return
		if (!issimulatedturf(owner.loc)) return
		var/turf/simulated/T = owner.loc
		if (!T.gas_cross(T)) return
		var/obj/item/I = owner
		if (I.amount < 1) return
		/// Init a property to 1 if it doesn't exist, its real value if it does, and if it does exist, delete it if the value is 0
		var/radioactive = I.material.getProperty("radioactive")
		var/n_radioactive = I.material.getProperty("n_radioactive")
		if (!radioactive && !n_radioactive)
			I.material.removeTrigger(TRIGGERS_ON_TEMP, /datum/materialProc/radioactive_temp)
			return
		var/datum/gas_mixture/air = T.return_air()
		if (!air || air.toxins < MINIMUM_REACT_QUANTITY) return
		if(T.parent?.group_processing)
			T.parent.suspend_group_processing()
		/// Mostly bullshit magic because I don't know how radiation works and plasma isn't real, but is how many moles to convert of existing plasma
		var/moles_to_convert = min(((I.amount * I.material_amt) * (1 + radioactive) * (1 + n_radioactive) * sqrt(temp) / 1000), air.toxins)
		air.radgas += moles_to_convert
		air.toxins -= moles_to_convert
		// Force mutability
		if (!I.material.isMutable())
			I.material = I.material.getMutable()
		if (radioactive)
			I.material.setProperty("radioactive", radioactive - min(radioactive, moles_to_convert/(10*I.amount)))
		else
			I.material.removeProperty("radioactive")
		if (n_radioactive)
			I.material.setProperty("n_radioactive", n_radioactive - min(n_radioactive, moles_to_convert/(50*I.amount)))
		else
			I.material.removeProperty("n_radioactive")
