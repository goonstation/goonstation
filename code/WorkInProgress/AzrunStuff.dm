/// Provide support for IIR filters to perform all your standard filtering needs!
/// Previous inputs and outputs of the function will be summed together and output
///
/// https://en.wikipedia.org/wiki/Infinite_impulse_response
/datum/digital_filter
	/// feedback (scalars for sumation of previous results)
	var/list/a_coefficients
	/// feedforward (scalars for sumation of previous inputs)
	var/list/b_coefficients
	var/z_a[1]
	var/z_b[1]

	proc/init(list/feedback, list/feedforward)
		a_coefficients = feedback
		b_coefficients = feedforward
		z_a.len = length(a_coefficients)
		z_b.len = length(b_coefficients)

	proc/process(input)
		var/feedback_sum
		var/input_sum
		z_b[1] = input

		// Sum previous outputs
		for(var/i in 1 to length(src.a_coefficients))
			feedback_sum -= src.a_coefficients[i]*src.z_a[i]
			if(i>1) src.z_a[i] = src.z_a[i-1]

		// Sum inputs
		for(var/i in 1 to length(src.b_coefficients))
			input_sum += src.b_coefficients[i]*src.z_b[i]
			if(i>1) src.z_b[i] = src.z_b[i-1]
		. = feedback_sum + input_sum
		if(length(src.z_a)) src.z_a[1] = .

	/// Sum equally weighted previous inputs of window_size
	window_average
		init(window_size)
			var/list/coeff_list = new()
			for(var/i in 1 to window_size)
				coeff_list += 1/window_size
			..(null, coeff_list)

	/// Sum weighted current input and weighted previous output to achieve output
	/// input weight will be ratio of weight assigned to input value while remaining goes to previous output
	///
	/// Exponential Smoothing
	/// Time constant will be the amount of time to achieve 63.2% of original sum
	/// NOTE: This should be performed by a scheduled process as this ensures constant sample interval
	/// https://en.wikipedia.org/wiki/Exponential_smoothing
	exponential_moving_average
		proc/init_basic(input_weight)
			var/input_weight_list[1]
			var/prev_output_weight_list[1]
			input_weight_list[1] = input_weight
			prev_output_weight_list[1] = -(1-input_weight)
			init(prev_output_weight_list,input_weight_list)

		proc/init_exponential_smoothing(sample_interval, time_const)
			init_basic(1.0 - ( eulers ** ( -sample_interval / time_const )))

/// Transformation Manager for Thermo-Electric Generator
/datum/teg_transformation_mngr
	var/obj/machinery/power/generatorTemp/generator
	var/static/list/datum/teg_transformation/possible_transformations

	New(teg)
		. = ..()
		generator = teg
		if(!possible_transformations)
			possible_transformations = list()
			for(var/T in childrentypesof(/datum/teg_transformation))
				var/datum/teg_transformation/TT = new T
				possible_transformations += TT

	disposing()
		generator = null
		. = ..()

	/// Periodic function to check if transformation by reagent is possible
	proc/check_reagent_transformation()
		if(generator?.active_form?.skip_transformation_checks) return
		for(var/datum/teg_transformation/T as() in possible_transformations)
			if(generator.active_form?.type == T.type) continue // Skip current form

			var/reagents_present = length(T.required_reagents)
			for(var/R as() in T.required_reagents)
				if(generator.circ1.reagents.get_reagent_amount(R) + generator.circ2.reagents.get_reagent_amount(R) >= T.required_reagents[R])
				else
					reagents_present = FALSE
					break

			if(reagents_present)
				SPAWN_DBG(0)
					if(generator.active_form)
						generator.active_form.on_revert()
					generator.active_form = new T.type
					generator.active_form.on_transform(generator)
				return

	/// Transform when a matsci semiconductor is inserted and the material differs the material
	/// from the TEG.  Transformation requires the semiconductor fully back in place and energy
	/// is present to activate NANITES!
	proc/check_material_transformation()
		if(!generator.active_form || istype(generator.active_form, /datum/teg_transformation/matsci))
			if(generator.semiconductor?.material && ((src.generator.semiconductor.material.mat_id != src.generator.material?.mat_id) || !src.generator.material))
				if(src.generator.semiconductor_state == 0 && src.generator.powered())
					SPAWN_DBG(1.5 SECONDS)
						src.generator.use_power(500 WATTS)
						elecflash(src.generator)
						src.generator.visible_message("<span class='alert'>[src.generator] is suddenly engulfed in a swarm of nanites!</span>")
						var/nanite_overlay = image('icons/misc/critter.dmi', "nanites")
						generator.UpdateOverlays(nanite_overlay,"transform")
						generator.circ1.UpdateOverlays(nanite_overlay,"transform")
						generator.circ2.UpdateOverlays(nanite_overlay,"transform")
						sleep(rand(1.5 SECONDS, 2.5 SECONDS))
						if(generator.active_form)
							generator.active_form.on_revert()
						generator.active_form = new /datum/teg_transformation/matsci
						generator.active_form.mat_id = generator.semiconductor.material.mat_id
						generator.active_form.on_transform(generator)
						sleep(rand(1.5 SECONDS, 2.5 SECONDS))
						src.generator.visible_message("<span class='alert'>The swarm of nanites disappears back into \the [src.generator].</span>")
						generator.UpdateOverlays(null,"transform")
						generator.circ1.UpdateOverlays(null,"transform")
						generator.circ2.UpdateOverlays(null,"transform")


ABSTRACT_TYPE(/datum/teg_transformation)
/** Thermo-Electric Generator Transformations
	These are various forms the Thermo-Electric Generator can take. They can
	be achieved by:
		* a reagent mixture similar to chems
		* triggered directly via another condition
  */
datum/teg_transformation
	var/name = null
	/// material id to apply
	var/mat_id
	/// associated list of reagent ids and amounts to cause transformation
	var/list/required_reagents
	/// ref to TEG
	var/obj/machinery/power/generatorTemp/teg
	/// Automatic transformation checks until a seperate criteria is achieved
	var/skip_transformation_checks = FALSE

	disposing()
		teg = null
		. = ..()

	/// Return False by default to cause classic grump behavior
	proc/on_grump()
		return FALSE

	/// Base transformation to assign material
	proc/on_transform(obj/machinery/power/generatorTemp/teg)
		var/datum/material/M
		src.teg = teg
		if(src.mat_id)
			M = getMaterial(src.mat_id)
		else
			M = copyMaterial(src.teg.semiconductor.material)

		teg.setMaterial(M)
		teg.circ1.setMaterial(M)
		teg.circ2.setMaterial(M)

	/// Revert material back to initial values
	proc/on_revert()
		src.teg.removeMaterial()
		src.teg.circ1.removeMaterial()
		src.teg.circ2.removeMaterial()
		src.teg.active_form = null
		qdel(src)

  //                    //
  // TEG TRANFORMATIONS //
  //                    //

	/// Default TEG Transformation we know and ""love""
	default
		mat_id = "steel"

	/**
	  * Material Science Transformation
	  * Triggered by /obj/item/teg_semiconductor having a material applied likely by [/obj/machinery/arc_electroplater]
	  */
	matsci
		mat_id = null
		var/prev_efficiency

		on_transform()
			var/electrical_conductivity
			var/thermal_conductivity
			var/efficiency_shift

			. = ..()
			prev_efficiency = src.teg.efficiency_controller
			/*
			FOM zT for Themoelectric Devices
				zT = S2σT/κ
			Prefer high electrical conductivity (σ)
			Prefer low thermal conductivity (κ)
			IGNORED: The measure of the magnitude of electrons flow in response to a temperature difference across that material is given by the Seebeck coefficient (S).
			INGORED: Temperature

			Oversimplification: zT = 2σ/κ
			*/
			electrical_conductivity = 50
			if(src.teg.material.hasProperty("electrical"))
				electrical_conductivity = src.teg.material.getProperty("electrical")

			thermal_conductivity = 50
			if(src.teg.material.hasProperty("thermal"))
				thermal_conductivity = src.teg.material.getProperty("thermal")

			/*    2σ / κ = zT    - Offset 				Result 	*/
			/*  2*75 / 25 = 6    - 2 = 4  		 	 Great! 	*/
			/*	2*50 / 50 = 2    - 2 = 0  			 No Change*/
			/*  2*25 / 75 = 0.66 -2  = -1.34 		 TERRIBAD */
			/* Use above offset * 10 to put it in the -20 to 40 ballpark */
			efficiency_shift = (2 * electrical_conductivity / thermal_conductivity) - 2 //center on zero
			efficiency_shift = clamp(efficiency_shift*10, -20, 40) //scale shift by 10 which gets it in the ballpark!
			src.teg.efficiency_controller = clamp(src.teg.efficiency_controller + efficiency_shift, 25, 75) //ensure nothing goes bonkers

		on_revert()
			src.teg.efficiency_controller = prev_efficiency
			. = ..()

	birdbird
		name = "Squawk"
		mat_id = "gold"
		required_reagents = list("feather_fluid"=10)
		var/list/mob/shitlist = list()

		on_transform(obj/machinery/power/generatorTemp/teg)
			var/image/chicken = image('icons/obj/clothing/item_masks.dmi', "chicken")
			teg.UpdateOverlays(chicken, "mask")
			. = ..()

		on_revert()
			var/list/ejectables = list()
			teg.UpdateOverlays(null, "mask")

			for(var/i in 1 to rand(3,10))
				var/obj/item/feather/F = new(src)
				F.color = src.teg.color
				ejectables += F
			handle_ejectables(teg.loc, ejectables)

			. = ..()

		on_grump()
			var/list/squawks = list("sound/voice/animal/squawk1.ogg","sound/voice/animal/squawk2.ogg", "sound/voice/animal/squawk3.ogg")
			if(prob(8))
				playsound(teg, pick(squawks), rand(10,40), 1)

			if(prob(10))
				for(var/mob/living/critter/small_animal/bird/B in orange(5, teg))
					RegisterSignal(B, COMSIG_MOB_ATTACKED_PRE, .proc/bird_attacked, override=TRUE)
			else
				for(var/turf/simulated/T in orange(2,teg))
					var/datum/gas_mixture/turf_gas = T.return_air()
					var/datum/gas_mixture/removed = turf_gas.remove_ratio(0.25)
					removed.temperature = 37.5 + T0C
					T.assume_air(removed)

			if(length(shitlist) && prob(25))
				var/shitter_found = FALSE
				var/atom/last = src.teg
				for(var/mob/M in src.shitlist)
					if(get_dist(src.teg, M) < 5)
						if(!shitter_found)
							playsound(teg, pick(squawks), 80, 1)
							shitter_found = TRUE

						elecflash(M, power = 2, exclude_center = 0)
						var/list/affected = DrawLine(last, M, /obj/line_obj/elec ,'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",OBJ_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')
						for(var/obj/O in affected)
							SPAWN_DBG(0.6 SECONDS) pool(O)
						last = M

			return TRUE

		proc/bird_attacked(mob/attacked, mob/attacker, weapon)
			if(istype(attacker))
				src.shitlist |= attacker
				src.teg.grump += 10

	vampire
		mat_id = "bone"
		required_reagents = list("vampire_serum"=5)
		var/datum/abilityHolder/vampire/abilityHolder
		var/list/datum/targetable/vampire/abilities = list()

		proc/attach_hud()
			. = FALSE

		on_transform(obj/machinery/power/generatorTemp/teg)
			. = ..()
			abilityHolder = new /datum/abilityHolder/vampire(src)
			abilityHolder.owner = teg
			abilityHolder.addAbility(/datum/targetable/vampire/blood_steal)
			for(var/datum/targetable/vampire/A in abilityHolder.abilities)
				abilities[A.name] = A
			RegisterSignal(src.teg, COMSIG_ATOM_HITBY_PROJ, .proc/projectile_collide)
			var/image/mask = image('icons/obj/clothing/item_masks.dmi', "death")
			teg.UpdateOverlays(mask, "mask")
			var/volume = src.teg.circ1.reagents.total_volume
			src.teg.circ1.reagents.remove_any(volume)
			src.teg.circ1.reagents.add_reagent("blood", volume)
			volume = src.teg.circ2.reagents.total_volume
			src.teg.circ2.reagents.remove_any(volume)
			src.teg.circ2.reagents.add_reagent("blood", volume)
			make_cleanable(/obj/decal/cleanable/blood,get_turf(src.teg.loc))
			make_cleanable(/obj/decal/cleanable/blood,get_turf(src.teg.circ1))
			make_cleanable(/obj/decal/cleanable/blood,get_turf(src.teg.circ2))


		on_revert()
			var/datum/reagents/leaked
			teg.UpdateOverlays(null, "mask")
			UnregisterSignal(src.teg, COMSIG_ATOM_HITBY_PROJ)
			var/volume = src.teg.circ1.reagents.total_volume
			leaked = src.teg.circ1.reagents.remove_any_to(volume)
			leaked.reaction(get_step(src.teg.circ1, SOUTH))
			volume = src.teg.circ2.reagents.total_volume
			leaked = src.teg.circ2.reagents.remove_any_to(volume)
			leaked.reaction(get_step(src.teg.circ2, SOUTH))
			. = ..()

		on_grump()
			var/mob/living/carbon/human/H
			var/list/mob/living/carbon/targets = list()

			if(prob(50)) // Azrun LOWER THIS ZOMG
				for(var/mob/living/carbon/M in orange(5, teg))
					if(M.blood_volume >= 0 && !M.traitHolder.hasTrait("training_chaplain"))
						targets += M

			if(length(targets))
				var/mob/living/carbon/target = pick(targets)

				if(target in abilityHolder.ghouls)
					H = target
					if(	abilityHolder.points > 100 && target.blood_volume < 50 && !ON_COOLDOWN(src.teg,"heal", 120 SECONDS) )
						enthrall(H)
				else
					if(isalive(target))
						if( !ON_COOLDOWN(target,"teg_glare", 30 SECONDS) )
							glare(target)

						if(!abilities["Blood Steal"].actions.hasAction(src.teg, "vamp_blood_suck_ranged") && !ON_COOLDOWN(src.teg,"vamp_blood_suck_ranged", 10 SECONDS))
							actions.start(new/datum/action/bar/private/icon/vamp_ranged_blood_suc(src.teg,abilityHolder, target, abilities["Blood Steal"]), src.teg)

				if(ishuman(target))
					H = target
					if(isdead(H) && abilityHolder.points > 100 && !ON_COOLDOWN(src.teg,"enthrall",30 SECONDS))
						enthrall(H)

			if(prob(10))
				var/list/responses = list("I hunger! Bring us food so we may eat!", "Blood... I needs it.", "I HUNGER!", "Summon them here so we may feast!")
				say_ghoul(pick(responses))

			if(prob(20) && abilityHolder.points > 100)
				var/datum/reagents/reagents = pick(src.teg.circ1.reagents, src.teg.circ2.reagents)
				var/transfer_volume = clamp(reagents.maximum_volume - reagents.total_volume, 0, abilityHolder.points - 100)

				if(transfer_volume)
					transfer_volume = rand(0, transfer_volume)
					reagents.add_reagent("blood",transfer_volume)
					abilityHolder.deductPoints(transfer_volume)
					src.teg.grump -= 10
				else
					reagents.remove_any_to(100)
					make_cleanable(/obj/decal/cleanable/blood,get_step(src.teg, SOUTH))
					src.teg.efficiency_controller += 5
					SPAWN_DBG(45 SECONDS)
						src.teg?.efficiency_controller -= 5



			return TRUE

		proc/projectile_collide(owner, obj/projectile/P)
			if (("vamp" in P.special_data))
				var/bitesize = 10
				var/mob/living/carbon/victim = P.special_data["victim"]
				var/datum/abilityHolder/vampire/vampire = P.special_data["vamp"]
				if (vampire == abilityHolder && P.max_range == PROJ_INFINITE_RANGE)
					P.travelled = 0
					P.max_range = 4
					P.special_data.len = 0 // clear special data so normal on_end() wont trigger
					vampire.vamp_blood += bitesize
					vampire.addPoints(bitesize)
					vampire.tally_bite(victim,bitesize)
					if (victim.blood_volume < bitesize)
						victim.blood_volume = 0
					else
						victim.blood_volume -= bitesize

		proc/say_ghoul(var/message)
			var/name = src.teg.name
			var/alt_name = " (VAMPIRE)"

			if (!message || !length(src.abilityHolder.ghouls) )
				return

			var/rendered = "<span class='game ghoulsay'><span class='prefix'>GHOULSPEAK:</span> <span class='name'>[name]<span class='text-normal'>[alt_name]</span></span> <span class='message'>[message]</span></span>"
			for (var/mob/M in src.abilityHolder.ghouls)
				boutput(M, rendered)

		proc/glare(mob/living/carbon/target)
			var/obj/O = src.teg
			if (!target || !ismob(target))
				return 1

			if (get_dist(src.teg, target) > 3)
				return 1

			if (isdead(target))
				return 1

			O.visible_message("<span class='alert'><B>[O] emits a blinding flash at [target]!</B></span>")
			var/obj/itemspecialeffect/glare/E = unpool(/obj/itemspecialeffect/glare)
			E.color = "#FFFFFF"
			E.setup(O.loc)
			playsound(O.loc,"sound/effects/glare.ogg", 50, 1, pitch = 1, extrarange = -4)

			SPAWN_DBG(1 DECI SECOND)
				var/obj/itemspecialeffect/glare/EE = unpool(/obj/itemspecialeffect/glare)
				EE.color = "#FFFFFF"
				EE.setup(target.loc)
				playsound(target.loc,"sound/effects/glare.ogg", 50, 1, pitch = 0.8, extrarange = -4)

			target.apply_flash(30, 15, stamina_damage = 350)

		proc/enthrall(mob/living/carbon/human/target)
			var/datum/abilityHolder/vampire/H = src.abilityHolder
			if(istype(target))
				if (!istype(target.mutantrace, /datum/mutantrace/vamp_zombie))
					if (!target.mind && !target.client)
						if (target.ghost && target.ghost.client && !(target.ghost.mind && target.ghost.mind.dnr))
							var/mob/dead/ghost = target.ghost
							ghost.show_text("<span class='red'>You feel yourself torn away from the afterlife and back into your body!</span>")
							if(ghost.mind)
								ghost.mind.transfer_to(target)
							else if (ghost.client)
								target.client = ghost.client
							else if (ghost.key)
								target.key = ghost.key

						else if (target.last_client) //if all fails, lets try this
							for (var/client/C in clients)
								if (C == target.last_client && C.mob && isobserver(C.mob))
									if(C.mob && C.mob.mind)
										C.mob.mind.transfer_to(target)
									else
										target.client = C
									break

					if (!target.client)
						return

					target.full_heal()

					target.real_name = "zombie [target.real_name]"
					if (target.mind)
						target.mind.special_role = "vampthrall"
						target.mind.master = src.teg
						if (!(target.mind in ticker.mode.Agimmicks))
							ticker.mode.Agimmicks += target.mind

					src.abilityHolder.ghouls += target

					target.set_mutantrace(/datum/mutantrace/vamp_zombie)
					var/datum/abilityHolder/vampiric_zombie/VZ = target.get_ability_holder(/datum/abilityHolder/vampiric_zombie)
					if (VZ && istype(VZ))
						VZ.master = H

					boutput(target, __red("<b>You awaken filled with purpose - you must serve your master \"vampire\", [src.teg]!</B>"))
					boutput(target, __red("<b>You are bound to the [src.teg]. It hungers for blood! You must be protect it and feed it!</B>"))
					SHOW_MINDSLAVE_TIPS(target)
				else
					target.full_heal()

				if (target in H.ghouls)
					//and add blood!
					var/datum/mutantrace/vamp_zombie/V = target.mutantrace
					if (V)
						V.blood_points += 200

					H.blood_tracking_output(100)

					H.deductPoints(100)



