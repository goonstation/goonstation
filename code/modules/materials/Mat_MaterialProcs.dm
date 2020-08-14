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

//!!!!!!!!!!!!!!!!!!!! THINGS LIKE GOLD SPARKLES ARE NOT REMOVED WHEN MATERIAL CHANGES!. MOVE THESE TO NEW APPEARANCE SYSTEM.

/datum/materialProc
	var/max_generations = 2 //After how many material "generations" this trait disappears. -1 = does not disappear.
	var/desc = "" //Optional simple sentence that describes how the traits appears on the material. i.e. "It is shiny."

	proc/execute()
		return
/*
/datum/materialProc/oneat_flesh
	max_generations = -1

	execute(var/mob/M, var/obj/item/I)
		M.reagents.add_reagent("prions", 15)
		return
*/
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
		owner.set_density(0)
		return

/datum/materialProc/ffart_add
	desc = "It's very hard to move around."
	max_generations = 1

	execute(var/atom/owner)
		if(istype(owner, /atom/movable))
			var/atom/movable/A = owner
			A.anchored = 1
		return

/datum/materialProc/ffart_pickup
	execute(var/mob/M, var/obj/item/I)
		SPAWN_DBG(1 SECOND)
			M.remove_item(I)
			I.set_loc(get_turf(I))
		return

/datum/materialProc/wendigo_temp_onlife
	desc = "It feels furry."

	execute(var/mob/M, var/obj/item/I)
		if(M)
			M.bodytemperature = 310
		return

/datum/materialProc/fail_explosive
	var/lastTrigger = 0
	var/trigger_chance = 100

	New(var/chance = 100)
		trigger_chance = chance
		..()

	execute(var/atom/location)
		if(world.time - lastTrigger < 100) return
		lastTrigger = world.time
		var/turf/tloc = get_turf(location)
		explosion(location, location, tloc, 1, 2, 3, 4, 1)
		location.visible_message("<span class='alert'>[location] explodes!</span>")
		return

/datum/materialProc/radioactive_on_enter
	desc = "It glows faintly."

	execute(var/atom/owner, var/atom/entering)
		if(ismob(entering))
			var/mob/M = entering
			if(owner.material)
				M.changeStatus("radiation", max(round(owner.material.getProperty("radioactive") / 15),1)*10, 3)
		return

/datum/materialProc/n_radioactive_on_enter
	desc = "It glows blue faintly."

	execute(var/atom/owner, var/atom/entering)
		if(ismob(entering))
			var/mob/M = entering
			if(owner.material)
				M.changeStatus("n_radiation", max(round(owner.material.getProperty("n_radioactive") / 15),1)*10, 3)
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

	execute(var/obj/item/owner, var/mob/attacker, var/mob/attacked, var/atom/weapon)
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

	execute(var/obj/item/owner, var/mob/attacker, var/mob/attacked)
		if(explode_limit && explode_count >= explode_limit) return
		if(world.time - lastTrigger < 50) return
		lastTrigger = world.time
		if(prob(trigger_chance))
			explode_count++
			var/turf/tloc = get_turf(attacked)
			explosion(owner, tloc, 0, 1, 2, 3, 1)
			tloc.visible_message("<span class='alert'>[owner] explodes!</span>")
			qdel(owner)
		return

/datum/materialProc/generic_fireflash
	var/lastTrigger = 0

	execute(var/atom/location, var/temp)
		if(temp < T0C + 200)
			return
		if(world.time - lastTrigger < 1200) return
		lastTrigger = world.time
		fireflash(get_turf(location), 1)
		return

/datum/materialProc/generic_itchy_onlife
	desc = "It makes your hands itch."

	execute(var/mob/M, var/obj/item/I)
		if(prob(20)) M.emote(pick("twitch", "laugh", "sneeze", "cry"))
		if(prob(10))
			boutput(M, "<span class='notice'><b>Something tickles!</b></span>")
			M.emote(pick("laugh", "giggle"))
		if(prob(8))
			M.visible_message("<span class='alert'><b>[M.name]</b> scratches at an itch.</span>")
			random_brute_damage(M, 1)
			M.changeStatus("stunned", 1 SECOND)
			M.emote("grumble")
		if(prob(8))
			boutput(M, "<span class='alert'><b>So itchy!</b></span>")
			random_brute_damage(M, 2)
		if(prob(1))
			boutput(M, "<span class='alert'><b><font size='[rand(2,5)]'>AHHHHHH!</font></b></span>")
			random_brute_damage(M,5)
			M.changeStatus("weakened", 5 SECONDS)
			M.make_jittery(6)
			M.visible_message("<span class='alert'><b>[M.name]</b> falls to the floor, scratching themselves violently!</span>")
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

	execute(var/obj/item/owner, var/mob/attacker, var/mob/attacked)
		if(prob(reag_chance) && attacked && attacked.reagents)
			charges_left--
			attacked.reagents.add_reagent(reag_id, reag_amt, null, T0C)
			if(!charges_left)
				if(owner.material)
					owner.material.triggersOnAttack.Remove(src)
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

	execute(var/obj/item/owner, var/mob/attacker, var/mob/attacked)
		if(prob(reag_chance) && attacked && attacked.reagents)
			attacked.reagents.add_reagent(reag_id, reag_amt, null, T0C)
		return

/datum/materialProc/generic_reagent_onlife
	var/reag_id = "carbon"
	var/reag_amt = 1

	New(var/reagent_id = "carbon", var/amount = 1)
		reag_id = reagent_id
		reag_amt = amount
		..()

	execute(var/mob/M, var/obj/item/I)
		if(M && M.reagents)
			M.reagents.add_reagent(reag_id, reag_amt, null, T0C)
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

	execute(var/mob/M, var/obj/item/I)
		if(M && M.reagents)
			M.reagents.add_reagent(reag_id, reag_amt, null, T0C)
			added += reag_amt
			if(added >= max_volume)
				if(I.material)
					I.material.triggersOnLife.Remove(src)
		return

/datum/materialProc/generic_explosive
	var/lastTrigger = 0

	execute(var/atom/location, var/temp)
		if(temp < T0C + 100)
			return
		if(world.time - lastTrigger < 100) return
		lastTrigger = world.time
		var/turf/tloc = get_turf(location)
		explosion(location, tloc, 1, 2, 3, 4, 1)
		location.visible_message("<span class='alert'>[location] explodes!</span>")
		return

/datum/materialProc/flash_hit
	var/last_trigger = 0
	desc = "Every now and then it produces some bright sparks."

	execute(var/obj/item/owner, var/mob/attacker, var/mob/attacked, var/atom/weapon)
		if((world.time - last_trigger) >= 600)
			last_trigger = world.time
			attacked.visible_message("<span class='alert'>[owner] emits a flash of light!</span>")
			for (var/mob/living/carbon/M in all_viewers(5, attacked))
				M.apply_flash(8, 0, 0, 0, 3)
		return

/datum/materialProc/smoke_hit
	desc = "Faint wisps of smoke rise from it."
	var/last_trigger = 0

	execute(var/obj/item/owner, var/mob/attacker, var/mob/attacked, var/atom/weapon)
		if((world.time - last_trigger) >= 200)
			last_trigger = world.time
			attacked.visible_message("<span class='alert'>[owner] emits a puff of smoke!</span>")
			for(var/turf/T in view(1, attacked))
				harmless_smoke_puff(get_turf(T))
		return

/datum/materialProc/gold_add
	desc = "It's very shiny."
	execute(var/location)
		if(!particleMaster.CheckSystemExists(/datum/particleSystem/sparkles, location))
			particleMaster.SpawnSystem(new /datum/particleSystem/sparkles(location))
		return

/datum/materialProc/telecrystal_entered
	execute(var/atom/owner, var/atom/movable/entering)
		if(prob(50) && owner && isturf(owner) && !isrestrictedz(owner.z))
			. = get_offset_target_turf(get_turf(entering), rand(-2, 2), rand(-2, 2))
			entering.visible_message("<span class='alert'>[entering] is warped away!</span>")
			boutput(entering, "<span class='alert'>You suddenly teleport ...</span>")
			entering.set_loc(.)
		return


/datum/materialProc/telecrystal_onattack
	execute(var/obj/item/owner, var/mob/attacker, var/mob/attacked)
		if(prob(50))
			if(istype(attacked) && !isrestrictedz(attacked.z)) // Haine fix for undefined proc or verb /turf/simulated/floor/set loc()
				. = get_offset_target_turf(get_turf(attacked), rand(-8, 8), rand(-8, 8))
				attacked.visible_message("<span class='alert'>[attacked] is warped away!</span>")
				boutput(attacked, "<span class='alert'>You suddenly teleport ...</span>")
				attacked.set_loc(.)
		return

/datum/materialProc/telecrystal_life
	execute(var/mob/M, var/obj/item/I)
		if(prob(5) && M && !isrestrictedz(M.z))
			. = get_offset_target_turf(get_turf(M), rand(-8, 8), rand(-8, 8))
			M.visible_message("<span class='alert'>[M] is warped away!</span>")
			boutput(M, "<span class='alert'>You suddenly teleport ...</span>")
			M.set_loc(.)
		return

/datum/materialProc/plasmastone
	execute(var/location) //exp and temp both have the location as first argument so i can use this for both.
		for (var/turf/simulated/floor/target in range(1,location))
			if(!target.blocks_air && target.air)
				if(target.parent)
					target.parent.suspend_group_processing()

				var/datum/gas_mixture/payload = unpool(/datum/gas_mixture)
				payload.toxins = 100
				target.air.merge(payload)
		return

/datum/materialProc/miracle_add
	execute(var/location)
		animate_rainbow_glow(location)
		return

/datum/materialProc/radioactive_add
	execute(var/location)
		animate_flash_color_fill_inherit(location,"#1122EE",-1,40)
		return

/datum/materialProc/radioactive_life
	execute(var/mob/M, var/obj/item/I)
		if(I.material)
			M.changeStatus("radiation", (max(round(I.material.getProperty("radioactive") / 20),1))*10, 2)
		return

/datum/materialProc/radioactive_pickup
	execute(var/mob/M, var/obj/item/I)
		if(I.material)
			M.changeStatus("radiation", (max(round(I.material.getProperty("radioactive") / 5),1))*10, 4)
		return

/datum/materialProc/n_radioactive_add
	execute(var/location)
		animate_flash_color_fill_inherit(location,"#4279D1",-1,40)
		return

/datum/materialProc/n_radioactive_life
	execute(var/mob/M, var/obj/item/I)
		if(I.material)
			M.changeStatus("n_radiation", (max(round(I.material.getProperty("n_radioactive") / 20),1))*10, 2)
		return

/datum/materialProc/n_radioactive_pickup
	execute(var/mob/M, var/obj/item/I)
		if(I.material)
			M.changeStatus("neutron_radiation", (max(round(I.material.getProperty("n_radioactive") / 5),1))*10, 4)
		return

/datum/materialProc/erebite_flash
	execute(var/location)
		animate_flash_color_fill_inherit(location,"#FF7711",-1,10)
		return

/datum/materialProc/erebite_temp
	var/lastTrigger = 0

	execute(var/atom/location, var/temp)
		if(temp < T0C + 10) return
		if(world.time - lastTrigger < 100) return
		lastTrigger = world.time
		var/turf/tloc = get_turf(location)
		explosion(location, tloc, 0, 1, 2, 3, 1)
		location.visible_message("<span class='alert'>[location] explodes!</span>")
		return

/datum/materialProc/erebite_exp
	var/lastTrigger = 0

	execute(var/atom/location, var/sev)
		if(world.time - lastTrigger < 100) return
		lastTrigger = world.time
		var/turf/tloc = get_turf(location)
		if(sev > 0 && sev < 4)
			location.visible_message("<span class='alert'>[location] explodes!</span>")
			switch(sev)
				if(1)
					explosion(location, tloc, 0, 1, 2, 3, 1)
				if(2)
					explosion(location, tloc, -1, 0, 1, 2, 1)
				if(3)
					explosion(location, tloc, -1, -1, 0, 1, 1)
			qdel(location)
		return

/datum/materialProc/slippery_attack
	execute(var/obj/item/owner, var/mob/attacker, var/mob/attacked)
		if (prob(20))
			boutput(attacker, "<span class='alert'>[owner] slips right out of your hand!</span>")
			owner.loc = attacker.loc
			owner.dropped()
		return

/datum/materialProc/slippery_entered
	execute(var/atom/owner, var/atom/movable/entering)
		if (iscarbon(entering) && isturf(owner) && prob(75))
			var/mob/living/carbon/C = entering
			boutput(C, "You slip on the icy floor!")
			playsound(get_turf(owner), "sound/misc/slip.ogg", 30, 1)
			C.changeStatus("weakened", 2 SECONDS)
			C.force_laydown_standup()
		return

/datum/materialProc/ice_life
	desc = "It is slowly melting."

	execute(var/mob/M, var/obj/item/I)
		if (iscarbon(M))
			var/mob/living/carbon/C = M
			if (C.bodytemperature > 0)
				C.bodytemperature -= 2
			if (C.bodytemperature > 100 && prob(4))
				boutput(C, "Your [I] melts from your body heat!")
				qdel(I)
		return

/datum/materialProc/soulsteel_add
	execute(var/atom/owner)
		owner.event_handler_flags |= USE_HASENTERED
		return

/datum/materialProc/soulsteel_entered
	var/lastTrigger = 0
	execute(var/obj/item/owner, var/atom/movable/entering)
		if (!isobj(owner)) return
		if (istype(entering, /mob/dead/observer) && prob(33))
			var/mob/dead/observer/O = entering
			if(O.observe_round) return
			if(world.time - lastTrigger < 1800)
				boutput(entering, "<span class='alert'>[owner] can not be possessed again so soon!</span>")
				return
			lastTrigger = world.time
			var/mob/mobenter = entering
			if(mobenter.client)
				var/mob/living/object/OB = new/mob/living/object(owner, mobenter)
				OB.health = 8
				OB.max_health = 8
				OB.canspeak = 0
				SHOW_SOULSTEEL_TIPS(OB)
		return

/datum/materialProc/reflective_onbullet
	execute(var/obj/item/owner, var/atom/attacked, var/obj/projectile/projectile)
		if(projectile.proj_data.damage_type & D_BURNING || projectile.proj_data.damage_type & D_ENERGY)
			shoot_reflected_true(projectile, projectile) //shoot_reflected_to_sender()
		return

/datum/materialProc/negative_add
	execute(var/atom/owner)
		if(isitem(owner))
			var/obj/item/I = owner
			I.no_gravity = 1
			I.AddComponent(/datum/component/holdertargeting/no_gravity)
			animate_levitate(owner)
		return

/datum/materialProc/temp_miraclium
	execute(var/atom/location, var/temp)
		if(temp < T0C + 100)
			return

		SPAWN_DBG(1 SECOND)
			if(location && location.material && location.material.mat_id == "miracle")
				location.visible_message("<span class='notice'>[location] bends and twists, changing colors rapidly.</span>")
				var/chosen = pick(prob(100); "mauxite",prob(100); "pharosium",prob(100); "cobryl",prob(100); "bohrum",prob(80); "cerenkite",prob(50); "syreline",prob(20); "slag",prob(3); "spacelag",prob(5); "soulsteel",prob(100); "molitz",prob(50); "claretine",prob(5); "erebite",prob(10); "quartz",prob(5); "uqill",prob(10); "telecrystal",prob(1); "starstone",prob(5); "blob",prob(8); "koshmarite",prob(20); "chitin",prob(4); "pizza",prob(15); "beewool",prob(6); "ectoplasm")
				location.setMaterial(getMaterial(chosen), appearance = 1, setname = 1)
		return
