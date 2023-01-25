/obj/item/Tumbling_Creeper
	name = "Tumbling Creeper"
	desc = "A tumbler made of creeper. A highly invasive plant known for destroying many ecological systems. If planted onto the ground, it serves as a prickly trap. Can absorb chemicals poured onto it."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "Tumbling_Creeper-Unplanted"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "tumbling_creeper"
	flags = TABLEPASS | FPRINT | NOSPLASH
	w_class = W_CLASS_NORMAL
	force = 3
	throwforce = 3
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 5
	var/datum/plant/planttype = /datum/plant/weed/creeper
	var/datum/plantgenes/plantgenes = null
	var/generation = 0 // For genetics tracking.
	var/armed = FALSE //! This determinates if the trap is armed or not
	var/endurance_for_max = 100 //! how much endurance is needed to reach max damage with the trap
	var/potency_for_max = 200 //! how much potency is needed to generate the max injection-multiplier
	var/armed_force = 8 //! how much damage the trap does when stepped upon. Will be set when harvested
	var/armed_force_min = 8 //! how much damage the trap does when stepped upon with 0 endurance
	var/armed_force_max = 14 //! how much damage the trap does when stepped upon with the maximum endurance
	var/armed_weakened = 2 SECONDS //! how long you are weakened after stepping into the trap
	var/crashed_force = 20 //! how much damage the trap does when crashed into. Will be set when harvested
	var/crashed_force_min = 20 //! how much damage the trap does when stepped upon with 0 endurance
	var/crashed_force_max = 30 //! how much damage the trap does when stepped upon with the maximum endurance
	var/crashed_weakened = 3 SECONDS //! how long you are stunned if you crash into the trap
	var/reagent_storage = 8 //! How much the max amount of chems is the trap should be able to hold
	var/reagent_storage_min = 8 //! How much the max amount of chems is the trap should be able to hold	at 0 potency
	var/reagent_storage_max = 50 //! How much the max amount of chems is the trap should be able to hold	at max potency
	var/reagent_generation_multiplier = 0.5 //! How much percentage of the volume should be filled with assoc_reagents when harvested
	var/stepon_transfer_multiplier = 0.5 //! Multiplier to damage to calculate the amount of chems tranferred when stepped into.
	var/crash_transfer_multiplier = 0.4 //! Multiplier to damage to calculate the amount of chems tranferred when crashed into.
	var/target_zone = "chest" //! which zone the trap tries to target and calculate the damage resist from
	var/disarming_time = 3 SECONDS //! how long disarming with a wirecutter should take
	var/arming_time = 2 SECONDS //! how long arming should take
	var/tumbling_cooldown = 15 SECONDS //!how long the item should take at minimum before it begins tumbling again
	var/tumbling_distance_max = 6 //! how many tiles the item tries to move at most when tumbling
	var/tumbling_distance_min = 3 //! how many tiles the item tries to move at least when tumbling
	var/tumbling_speed = 0.3 //!how fast the throw while tumbling should be
	var/tumbling_flip_duration = 1.25 SECONDS //!how long a flip of the tumbler should take
	var/tumbling_chance = 20 //! the chance in % the item tries to thumble on each process tick
	var/on_Ground = TRUE //! changed whenever the item is picked up or dropped
	var/plantpot_damage_chance = 20 //! the chance for an armed tumbler to damage a plant in percent
	var/plantpot_damage_amount = 6 //! the amount of damage the armed tumbler should deal to the plant
	var/self_assemly_chance = 50 //! the chance in percent for the trap to auto-arm when it gets flung against a plantpot

	New()
		..()
		processing_items |= src

		if(ispath(src.planttype))
			var/datum/plant/species = HY_get_species_from_path(src.planttype, src)
			if (species)
				src.planttype = species

		src.plantgenes = new /datum/plantgenes(src)

		src.create_reagents(src.reagent_storage)


	proc/Setup_DNA()
		var/datum/plantgenes/DNA = src.plantgenes

		// raise the reagent storage limit linear from 0 potency to max potency
		src.reagent_storage = clamp(
			round(src.reagent_storage_min + (DNA.potency/src.potency_for_max) * (src.reagent_storage_max - src.reagent_storage_min)),
			src.reagent_storage_min,
			src.reagent_storage_max)

		src.reagents.maximum_volume = src.reagent_storage

		//add chemicals until reagent_generation_multiplier percentage of the storage is filled
		if (src.planttype)
			//we build a list out of all chems in assoc_reagents and commuts
			var/list/putreagents = list()
			putreagents = src.planttype.assoc_reagents
			//theoretically the tumbling creeper got no assoc_reagents, but for the case that will change at some point
			if(DNA.mutation)
				putreagents = putreagents | DNA.mutation.assoc_reagents
			if(DNA.commuts)
				for (var/datum/plant_gene_strain/reagent_adder/R in DNA.commuts)
					putreagents |= R.reagents_to_add
			// Now we add each reagent into the tumbling creeper
			if (length(putreagents) > 0)
				var/volume_to_fill = src.reagent_storage * src.reagent_generation_multiplier
				var/to_add = volume_to_fill / length(putreagents)
				for (var/plantReagent in putreagents)
					src.reagents.add_reagent(plantReagent, to_add)

		// raise the damage of the plant linear from 0 endurance to max endurance
		src.crashed_force = clamp(
			round(src.crashed_force_min + (DNA.endurance/src.endurance_for_max) * (src.crashed_force_max - src.crashed_force_min)),
			src.crashed_force_min,
			src.crashed_force_max)

		src.armed_force = clamp(
			round(src.armed_force_min + (DNA.endurance/src.endurance_for_max) * (src.armed_force_max - src.armed_force_min)),
			src.armed_force_min,
			src.armed_force_max)

	disposing()
		processing_items -= src
		src.plantgenes = null
		..()

	examine()
		. = ..()
		if (src.armed)
			. += "<span class='alert'>It looks like it's planted into the ground.</span>"

	process()
		. = ..()
		// This handles the creepers invasive behaviour.
		// When unarmed, it can randomly move. When armed, it starts attacking and planting creeper seeds into the trays
		if (!src.armed)
			//Let's see if our fellow creeper moves on their own
			//this checks if the item is on the ground and on simulated ground
			if (prob(src.tumbling_chance) && istype(src.loc, /turf) && issimulatedturf(get_turf(src)))
				if (!ON_COOLDOWN(src, "tumbling_fun", src.tumbling_cooldown))
					//the thumbler tries to randomly pick a cardinal direction and throws itself towards it
					//yes, it will damage people in its way. Yes, it could damage glass walls as well and it's hillarious
					//It takes a random direction on purpose. Tumbling weeds likes to get stuck
					var/target_direction = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
					var/target_distance = rand(src.tumbling_distance_min, src.tumbling_distance_max)
					var/turf/target_turf = get_ranged_target_turf(get_turf(src), target_direction, target_distance * 32)
					animate_spin(src, pick( "R" , "L"), src.tumbling_flip_duration, 2)
					src.throw_at(target_turf, target_distance, src.tumbling_speed)
		else
			if (prob(src.plantpot_damage_chance))
			//we look at plantpots around is if the creep is able to spread
				for (var/obj/machinery/plantpot/C in range(1,src))
					var/datum/plant/growing = C.current
					if (!C.dead && C.current && !istype(growing,/datum/plant/crystal) && !istype(growing,/datum/plant/weed/creeper))
						C.HYPdamageplant("physical",plantpot_damage_amount,1)
					else if (C.dead)
						C.HYPdestroyplant()
					else if (!C.current && src.plantgenes && !HYPCheckCommut(src.plantgenes, /datum/plant_gene_strain/seedless))
						//we create a new seed now
						var/obj/item/seed/WS = new /obj/item/seed
						var/datum/plant/New_Planttype = src.planttype
						var/datum/plantgenes/DNA = src.plantgenes
						var/datum/plantgenes/New_DNA = WS.plantgenes
						if (!New_Planttype.hybrid)
							WS.generic_seed_setup(New_Planttype)
						HYPpassplantgenes(DNA,New_DNA)
						// for spliced plants, we have to go some additional steps
						if (New_Planttype.hybrid)
							var/plantType = New_Planttype.type
							var/datum/plant/hybrid = new plantType(WS)
							for (var/V in New_Planttype.vars)
								if (issaved(New_Planttype.vars[V]) && V != "holder")
									hybrid.vars[V] = New_Planttype.vars[V]
							WS.planttype = hybrid
						//we now devolve the seed to not make tumbler spread like wildfire
						New_DNA.mutation = null
						// now we are able to plant the seed
						C.HYPnewplant(WS)
						spawn(0.5 SECONDS)
							qdel(WS)

	HY_set_species(var/datum/plant/species)
		if (species)
			src.planttype = species
		else
			if (ispath(src.planttype))
				src.planttype = new src.planttype(src)
			else
				qdel(src)
				return


	attackby(obj/item/W, mob/user)
		if(issnippingtool(W))
			if (src.armed)
				if (ON_COOLDOWN(user, "disarming_tumbling_creeper", user.combat_click_delay))
					return
				playsound(src.loc, 'sound/items/Scissor.ogg', 60)
				user.visible_message("[user] starts to cut the roots of [src]...")
				var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(
					user,
					src,
					src.disarming_time,
					/obj/item/Tumbling_Creeper/proc/disarm,\list(user),
					W.icon,
					W.icon_state,
					"[user] finishes cutting out [src]")
				actions.start(action_bar, user)
				return
		if(istype(W, /obj/item/reagent_containers/glass/))
			if(!W.reagents.total_volume)
				boutput(user, "<span class='alert'>There is nothing in [W] to pour onto [src]!</span>")
				return
			else
				var/transferable_amount = min(W:amount_per_transfer_from_this, W.reagents.total_volume, src.reagents.maximum_volume - src.reagents.total_volume)
				if (transferable_amount <= 0)
					boutput(user, "<span class='alert'>[src] cannot hold any more chemicals!</span>")
					return
				user.visible_message("<span class='notice'> [transferable_amount] units of [W]'s content are applied onto [src] by [user].</span>")
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
				W.reagents.trans_to(src, transferable_amount)
				return
		..()

	ex_act(severity)
		//no reuseable explosive chem traps, sorry
		qdel(src)

	proc/arm(mob/user)
		if (!src)
			return
		for(var/obj/item/B in get_turf(src))
			if (istype(B, /obj/item/Tumbling_Creeper))
				var/obj/item/Tumbling_Creeper/BM = B
				if (BM.armed)
					boutput(user, "<span class='alert'>A creeper is already planted here!</span>")
					return
		if (!src.armed)
			logTheThing(LOG_COMBAT, user, "planted [src] at [src.loc]")
			set_icon_state("Tumbling_Creeper-Planted")
			user?.drop_item(src)
			src.armed = TRUE
			src.anchored = TRUE

	proc/disarm(mob/user)
		if (!src)
			return
		if (src.armed)
			set_icon_state("Tumbling_Creeper-Unplanted")
			logTheThing(LOG_COMBAT, user, "uprooted [src] at [src.loc]")
			src.armed = FALSE
			src.anchored = FALSE

	proc/break_down(mob/user)
		//Cut down the creeper into nothing
		if (!src)
			return
		qdel(src)

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		//now the tumbler reaches its destination
		if (istype(hit_atom, /obj/machinery/plantpot))
			var/obj/machinery/plantpot/C = hit_atom
			var/datum/plant/growing = C.current
			if (!C.current || !istype(growing,/datum/plant/crystal) && !istype(growing,/datum/plant/weed/creeper))
				if (prob(src.self_assemly_chance))
					src.arm()


	hitby(atom/movable/AM, datum/thrown_thing/thr)
		..()
		if (src.armed && ishuman(AM) && AM.throwing)
			var/mob/living/carbon/human/victim = AM
			//crashes into the creeper when being thrown/slipped at it
			victim.visible_message("<span class='alert'><B>[victim] crashes into the planted [src]!</B></span>",\
			"<span class='alert'><B>You crash into the planted [src]!</B></span>")
			crash_into(victim)
			qdel(src) //if crashed into, destroys the creeper

	attack_self(mob/user as mob)
		if (!src.armed)
			for(var/obj/item/B in get_turf(src))
				if (istype(B, /obj/item/Tumbling_Creeper))
					var/obj/item/Tumbling_Creeper/BM = B
					if (BM.armed)
						boutput(user, "<span class='alert'>A creeper is already planted here!</span>")
						return
			user.show_text("You start to plant the creeper onto the ground...", "blue")
			var/datum/action/bar/icon/callback/action_bar = new /datum/action/bar/icon/callback(
				user,
				src,
				src.arming_time,
				/obj/item/Tumbling_Creeper/proc/arm,
				\list(user),
				src.icon,
				src.icon_state,
				"[user] finishes planting [src]")
			actions.start(action_bar, user)
			return
		..()


	Crossed(atom/movable/AM as mob|obj)
		..()
		if (src.armed && ishuman(AM))
			var/mob/living/carbon/human/victim = AM
			//crawling or just walking between the sticks is a viable counter
			//getting thrown at the trap has a different effect we want to check seperately
			if(victim.lying || victim.throwing || !victim.running_check(walking_matters = 1, ignore_actual_delay = 1))
				return
			//If any checks failed, well, you step into the trap
			victim.visible_message("<span class='alert'><B>[victim] steps into the planted [src]!</B></span>",\
			"<span class='alert'><B>You step into the planted [src]!</B></span>")
			step_on(victim)

	proc/crash_into(mob/living/carbon/human/victim as mob)
		if (!src || !victim || !src.armed)
			return
		logTheThing(LOG_COMBAT, victim, "crashed into [src] at [log_loc(src)].")
		victim.changeStatus("weakened", src.crashed_weakened)
		victim.force_laydown_standup()
		src.trap_damage(victim, src.crashed_force, src.crash_transfer_multiplier)
		playsound(victim.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 80, 1)
		victim.UpdateDamageIcon()


	proc/step_on(mob/living/carbon/human/victim as mob)
		if (!src || !victim || !src.armed)
			return
		logTheThing(LOG_COMBAT, victim, "stepped into [src] at [log_loc(src)].")
		victim.changeStatus("weakened", src.armed_weakened)
		victim.force_laydown_standup()
		src.trap_damage(victim, src.armed_force, src.stepon_transfer_multiplier)
		playsound(victim.loc, 'sound/impact_sounds/Flesh_stab_1.ogg', 80, 1)
		if (src.material)
			src.material.triggerOnAttack(src, null, victim)
		victim.UpdateDamageIcon()

	proc/trap_damage(mob/living/carbon/human/victim as mob, damage, transfer_multiplier)
		if (!src || !victim)
			return
		var/target = "All"
		if (victim.organHolder[src.target_zone])
			target = src.target_zone
		// we need this to calculate how much chems get transfered
		// This means damage against the zone, reduced by melee protection, multiplied by transfer multiplier and then rounded
		var/injected_amount = max(0, round((damage - victim.get_melee_protection(target, DAMAGE_STAB))*transfer_multiplier))
		victim.TakeDamageAccountArmor(target, damage, 0, 0, DAMAGE_STAB)
		// If injected_amount is greater than 0 and there are reagents in the trap, inject the victim
		if (src.reagents && src.reagents.total_volume && injected_amount > 0)
			logTheThing(LOG_COMBAT, src, "injected [victim] at [log_loc(src)] with [min(injected_amount, src.reagents.total_volume)]u of reagents.")
			src.reagents.trans_to(victim, injected_amount)
