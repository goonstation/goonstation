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
	/// The material that owns this trigger
	var/datum/material/owner = null

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
		APPLY_ATOM_PROPERTY(owner, PROP_ATOM_NEVER_DENSE, "ethereal")
		owner.set_density(0)
		return

/datum/materialProc/ffart_add
	desc = "It's very hard to move around."
	max_generations = 1

/datum/materialProc/ffart_pickup
	execute(var/mob/M, var/obj/item/I)
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

	execute(var/obj/item/owner)
		if(explode_limit && explode_count >= explode_limit) return
		if(world.time - lastTrigger < 50) return
		lastTrigger = world.time
		if(prob(trigger_chance))
			explode_count++
			var/turf/tloc = get_turf(owner)
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

	execute(var/mob/M, var/obj/item/I, mult)
		if(issilicon(M)) return // silicons can't get itchy
		if(probmult(20)) M.emote(pick("twitch", "laugh", "sneeze", "cry"))
		if(probmult(10))
			boutput(M, "<span class='notice'><b>Something tickles!</b></span>")
			M.emote(pick("laugh", "giggle"))
		if(probmult(8))
			M.visible_message("<span class='alert'><b>[M.name]</b> scratches at an itch.</span>")
			random_brute_damage(M, 1)
			M.changeStatus("stunned", 1 SECOND)
			M.emote("grumble")
		if(probmult(8))
			boutput(M, "<span class='alert'><b>So itchy!</b></span>")
			random_brute_damage(M, 2)
		if(probmult(1))
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
		if(prob(reag_chance) && attacked?.reagents)
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
		if(prob(reag_chance) && attacked?.reagents)
			attacked.reagents.add_reagent(reag_id, reag_amt, null, T0C)
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
		if (isobserver(entering) || isintangible(entering))
			return
		if(ON_COOLDOWN(entering, "telecrystal_warp", 1 SECOND))
			return
		var/turf/T = get_turf(entering)
		if(prob(50) && owner && isturf(owner) && !isrestrictedz(T.z))
			. = get_offset_target_turf(get_turf(entering), rand(-2, 2), rand(-2, 2))
			entering.visible_message("<span class='alert'>[entering] is warped away!</span>")
			playsound(owner.loc, "warp", 50)
			boutput(entering, "<span class='alert'>You suddenly teleport...</span>")
			entering.set_loc(.)
		return


/datum/materialProc/telecrystal_onattack
	execute(var/obj/item/owner, var/mob/attacker, var/mob/attacked)
		var/turf/T = get_turf(attacked)
		if(ON_COOLDOWN(attacked, "telecrystal_warp", 1 SECOND))
			return
		if(prob(33))
			if(istype(attacked) && !isrestrictedz(T.z)) // Haine fix for undefined proc or verb /turf/simulated/floor/set loc()
				. = get_offset_target_turf(get_turf(attacked), rand(-8, 8), rand(-8, 8))
				var/fail_msg = ""
				if (prob(25) && attacker == attacked)
					fail_msg = " but you lose [owner]!"
					attacker.drop_item(owner)
					playsound(attacker.loc, 'sound/effects/poof.ogg', 90)
				else
					playsound(attacker.loc, "warp", 50)
				attacked.visible_message("<span class='alert'>[attacked] is warped away!</span>")
				boutput(attacked, "<span class='alert'>You suddenly teleport... [fail_msg]</span>")
				attacked.set_loc(.)
		return

/datum/materialProc/telecrystal_life
	execute(var/mob/M, var/obj/item/I, mult)
		if(ON_COOLDOWN(M, "telecrystal_warp", 1 SECOND))
			return
		var/turf/T = get_turf(M)
		if(probmult(5) && M && !isrestrictedz(T.z))
			. = get_offset_target_turf(get_turf(M), rand(-8, 8), rand(-8, 8))
			M.visible_message("<span class='alert'>[M] is warped away!</span>")
			playsound(M.loc, "warp", 50)
			boutput(M, "<span class='alert'>You suddenly teleport...</span>")
			M.set_loc(.)
		return

/datum/materialProc/plasmastone
	var/total_plasma = 500

	execute(var/location) //exp and temp both have the location as first argument so i can use this for both.
		var/turf/T = get_turf(location)
		if(!T || T.density)
			return
		if(total_plasma <= 0)
			if(prob(2) && src.owner.owner)
				src.owner.owner.visible_message("<span class='alert>[src.owner.owner] dissipates.</span>")
				qdel(src.owner.owner)
			return
		for (var/turf/simulated/floor/target in range(1,location))
			if(ON_COOLDOWN(target, "plasmastone_plasma_generate", 10 SECONDS)) continue
			if(!target.gas_impermeable && target.air)
				if(target.parent?.group_processing)
					target.parent.suspend_group_processing()

				var/datum/gas_mixture/payload = new /datum/gas_mixture
				payload.toxins = 25
				total_plasma -= payload.toxins
				payload.temperature = T20C
				payload.volume = R_IDEAL_GAS_EQUATION * T20C / 1000
				target.air.merge(payload)
		return

/datum/materialProc/plasmastone_on_hit
	execute(var/atom/owner)
		owner.material.triggerTemp(locate(owner))

/datum/materialProc/molitz_temp
	var/unresonant = 1
	var/iterations = 4 // big issue I had was that with the strat that Im designing this for (teleporting crystals in and out of engine) one crystal could last you for like, 50 minutes, I didnt want to keep on reducing total amount as itd nerf agent b collection hard. So instead I drastically reduced amount and drastically upped output. This would speed up farming agent b to 3 minutes per crystal, which Im fine with
	execute(var/atom/location, var/temp, var/agent_b=FALSE)
		var/turf/target = get_turf(location)
		if(owner.hasProperty("resonance"))
			if(unresonant == 1)
				iterations = max(iterations, 2)
				unresonant -= 1
		if(iterations <= 0) return
		if(ON_COOLDOWN(location, "molitz_gas_generate", 30 SECONDS)) return

		var/datum/gas_mixture/air = target.return_air()
		if(!air) return

		var/datum/gas_mixture/payload = new /datum/gas_mixture
		payload.temperature = T20C
		payload.volume = R_IDEAL_GAS_EQUATION * T20C / 1000

		if(agent_b && air.temperature > 500 && air.toxins > MINIMUM_REACT_QUANTITY )
			var/datum/gas/oxygen_agent_b/trace_gas = payload.get_or_add_trace_gas_by_type(/datum/gas/oxygen_agent_b)
			payload.temperature = T0C // Greatly reduce temperature to simulate an endothermic reaction
			// Itr: .18 Agent B, 20 oxy, 1.3 minutes per iteration, realisticly around 7-8 minutes per crystal.

			animate_flash_color_fill_inherit(location,"#ff0000",4, 2 SECONDS)
			playsound(location, 'sound/effects/leakagentb.ogg', 50, 1, 8)
			if(!particleMaster.CheckSystemExists(/datum/particleSystem/sparklesagentb, location))
				particleMaster.SpawnSystem(new /datum/particleSystem/sparklesagentb(location))
			trace_gas.moles += 0.18
			iterations -= 1
			payload.oxygen = 20

			target.assume_air(payload)
		else
			animate_flash_color_fill_inherit(location,"#0000FF",4, 2 SECONDS)
			playsound(location, 'sound/effects/leakoxygen.ogg', 50, 1, 5)
			payload.oxygen = 80
			iterations -= 1

			target.assume_air(payload)

/datum/materialProc/molitz_temp/agent_b
	execute(var/atom/location, var/temp)
		..(location, temp, TRUE)
		return

/datum/materialProc/molitz_exp
	var/maxexplode = 1
	execute(var/atom/location, var/sev)
		if(maxexplode <= 0) return
		var/turf/target = get_turf(location)
		if(sev > 0 && sev < 4) // Use pipebombs not canbombs!
			var/datum/gas_mixture/payload = new /datum/gas_mixture
			payload.oxygen = 50
			payload.temperature = T20C
			target.assume_air(payload)
			maxexplode -= 1
			if(owner)
				owner.setProperty("resonance", 1)

/datum/materialProc/molitz_on_hit
	execute(var/atom/owner, var/obj/attackobj)
		owner.material.triggerTemp(owner, 1500)

/datum/materialProc/miracle_add
	execute(var/location)
		animate_rainbow_glow(location)
		return

/datum/materialProc/radioactive_add
	execute(var/atom/location)
		animate_flash_color_fill_inherit(location, "#1122EE", -1, 40)
		location.AddComponent(/datum/component/radioactive, location.material.getProperty("radioactive")*10, FALSE, FALSE, isitem(owner) ? 0 : 1)
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
		location.AddComponent(/datum/component/radioactive, location.material.getProperty("n_radioactive")*10, FALSE, TRUE, isitem(owner) ? 0 : 1)
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
			owner.set_loc(attacker.loc)
			owner.dropped(attacker)
		return

/datum/materialProc/slippery_entered
	execute(var/atom/owner, var/atom/movable/entering)
		if (isliving(entering) && isturf(owner) && prob(75) && !isintangible(entering))
			var/mob/living/L = entering
			if(L.slip(walking_matters = 1))
				boutput(L, "You slip on the icy floor!")
				playsound(owner, 'sound/misc/slip.ogg', 30, 1)
		return

/datum/materialProc/ice_life
	desc = "It is slowly melting."

	execute(var/mob/M, var/obj/item/I, mult)
		if (iscarbon(M))
			var/mob/living/carbon/C = M
			if (C.bodytemperature > 0)
				C.bodytemperature -= 2
			if (C.bodytemperature > 100 && probmult(4))
				boutput(C, "Your [I] melts from your body heat!")
				qdel(I)
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
				var/mob/living/object/OB = new/mob/living/object(owner.loc, owner, mobenter)
				OB.health = 8
				OB.max_health = 8
				OB.canspeak = 0
				OB.show_antag_popup("soulsteel")
		return

/datum/materialProc/reflective_onbullet
	execute(var/obj/item/owner, var/atom/attacked, var/obj/projectile/projectile)
		if(projectile.proj_data.damage_type & D_BURNING || projectile.proj_data.damage_type & D_ENERGY)
			shoot_reflected_bounce(projectile, owner) //shoot_reflected_to_sender()
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

		SPAWN(1 SECOND)
			if(location?.material?.mat_id == "miracle")
				location.visible_message("<span class='notice'>[location] bends and twists, changing colors rapidly.</span>")
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
			owner.visible_message("<span class='alert'>[owner] crumples!</span>", "<span class='alert'>You hear a crumpling sound.</span>")
			qdel(owner)
		else if (istype(owner, /turf))
			if (istype(owner, /turf/simulated/wall))
				var/turf/simulated/wall/wall_owner = owner
				owner.visible_message("<span class='alert'>Part of [owner] shears off under the blobby force! </span>")
				wall_owner.dismantle_wall(1)

/datum/materialProc/cardboard_on_hit // MARK: add to ignorant children
	execute(var/atom/owner, var/obj/attackobj, var/mob/attacker, var/meleeorthrow)
		if (meleeorthrow == 1) //if it was a melee attack
			if (issnippingtool(attackobj)||iscuttingtool(attackobj))
				if (isExploitableObject(owner))
					boutput(attacker, "Cutting [owner] into a sheet isn't possible.")
					return
				attacker.visible_message("<span class='alert'>[attacker] starts cutting [owner] apart.</span>", "<span class='notice'>You start cutting [owner] apart.</span>", "You hear the sound of cutting cardboard.")
				var/datum/action/bar/icon/hitthingwithitem/action_bar = new /datum/action/bar/icon/hitthingwithitem(attacker, attacker, attackobj, owner, src, 3 SECONDS, /datum/materialProc/cardboard_on_hit/proc/snip_end,\
				list(owner, attacker, attackobj), attackobj.icon, attackobj.icon_state)
				action_bar.interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED // uh, is this how I'm supposed to do this?
				actions.start(action_bar, attacker)
				return

		var/crumple = FALSE
		if (meleeorthrow == 1)
			if (!isitem(attackobj))
				CRASH("meleeorthrow should only be set to 1 when attackobj is an item")
			var/obj/item/meleeitem = attackobj
			if (prob(meleeitem.force*3))
				crumple = TRUE
		else
			if (prob(attackobj.throwforce*3))
				crumple = TRUE
		if(crumple)
			if (istype(owner, /obj))
				owner.visible_message("<span class='alert'>[owner] crumples!</span>", "<span class='alert'>You hear a crumpling sound.</span>")
				if(istype(owner, /obj/storage))
					var/obj/storage/S = owner
					S.dump_contents()
				qdel(owner)
			else if (istype(owner, /turf))
				if (istype(owner, /turf/simulated/wall))
					var/turf/simulated/wall/wall_owner = owner
					owner.visible_message("<span class='alert'>[owner] shears apart under the force of [attackobj]! </span>","<span class='alert'>You hear a crumpling sound.</span>")
					logTheThing(LOG_STATION, attacker ? attacker : null, null, "bashed apart a cardboard wall ([owner.name]) using \a [attackobj] at [attacker ? get_area(attacker) : get_area(owner)] ([attacker ? showCoords(attacker.x, attacker.y, attacker.z) : showCoords(owner.x, owner.y, owner.z)])[attacker ? null : ", attacker is unknown, shown location is of the wall"][meleeorthrow == 1 ? ", this was a thrown item" : null]")
					wall_owner.dismantle_wall(1, 0)

				else if (istype(owner, /turf/simulated/floor))
					var/turf/simulated/floor/floor_owner = owner
					if (floor_owner.broken && floor_owner.intact)
						floor_owner.to_plating()
						owner.visible_message("The top layer of [owner] breaks away!","<span class='alert'>You hear a crumpling sound.</span>")
					else if (floor_owner.broken && !floor_owner.intact)
						floor_owner.ReplaceWithSpace()
						owner.visible_message("<span class='alert'> [owner] breaks apart, leaving a hole!</span>", "<span class='alert'>You hear a crumpling sound.\nYou feel a rapid gust of air, flowing towards the floor!")
					if (floor_owner.reinforced)
						floor_owner.ReplaceWithFloor()
						floor_owner.to_plating()
						owner.visible_message("<span class='alert'>[owner]'s reinforcement breaks apart!</span>", "<span class='alert'>You hear a crumpling sound.</span>")
					else if (floor_owner.intact)
						floor_owner.break_tile()
						owner.visible_message("The top layer of [owner] crumples!", "You hear a crumpling sound.")

/datum/materialProc/cardboard_on_hit/proc/snip_end(var/atom/owner, var/mob/attacker, var/obj/attackobj)
	if (istype(owner, /obj))
		attacker.visible_message("<span class='alert'>[attacker] cuts [owner] into a sheet.</span>","<span class='notice'>You finish cutting [owner] into a sheet.</span>","The sound of cutting cardboard stops.")
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
				attacker.visible_message("<span class='alert'>[attacker] cuts the reinforcment off [owner].</span>","You cut the reinforcement off [owner].","The sound of cutting cardboard stops.")
			else
				attacker.visible_message("<span class='alert'>[attacker] cuts apart the outer cover of [owner]</span>.","<span class='notice'>You cut apart the outer cover of [owner]</span>.","The sound of cutting cardboard stops.")
				logTheThing(LOG_STATION, attacker, "cut apart a cardboard wall ([owner.name]) using \a [attackobj] at [get_area(attacker)] ([log_loc(attacker)])")
			wall_owner.dismantle_wall(0, 0)
		else if (istype(owner, /turf/simulated/floor))
			var/turf/simulated/floor/floor_owner = owner
			if (floor_owner.intact)
				if (!(floor_owner.broken || floor_owner.burnt))
					var/atom/A = new /obj/item/tile(floor_owner)
					A.setMaterial(owner.material)
				attacker.visible_message("<span class='alert'>[attacker] cuts off the top tile of [owner].</span>","<span class='notice'>You cut off the top tile of [owner].</span>","The sound of cutting cardboard stops.")
				floor_owner.to_plating()
				return
			if (floor_owner.reinforced)
				var/obj/R1 = new /obj/item/rods(src)
				var/obj/R2 = new /obj/item/rods(src)
				R1.setMaterial(owner.material)
				R2.setMaterial(owner.material)
				floor_owner.ReplaceWithFloor()
				floor_owner.to_plating()
				attacker.visible_message("<span class='alert'>[attacker] cuts the reinforcing rods off [owner].</span>","You finish cutting the reinforcing rods off of [owner].", "The sound of cutting cardboard stops.")
				return
			if (!floor_owner.intact)
				var/atom/A = new /obj/item/tile(src)
				A.setMaterial(owner.material)
				logTheThing(LOG_STATION, attacker, "cut apart a cardboard floor ([owner.name]) using \a [attackobj] at [get_area(attacker)] ([log_loc(attacker)])")
				attacker.visible_message("<span class='alert'>Cuts apart [owner], revealing space!</span>","<span class='alert'>You finish cutting apart [owner], revealing space.</span>","The sound of cutting cardboard stops.")
				floor_owner.ReplaceWithSpace()
				return
