// Provide support for IIR filters to perform all your standard filtering needs!
// Previous inputs and outputs of the function will be summed together and output
//
// https://en.wikipedia.org/wiki/Infinite_impulse_response
/datum/digital_filter
	var/list/a_coefficients //feedback (scalars for sumation of previous results)
	var/list/b_coefficients //feedforward (scalars for sumation of previous inputs)
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

	// Sum equally weighted previous inputs of window_size
	window_average
		init(window_size)
			var/list/coeff_list = new()
			for(var/i in 1 to window_size)
				coeff_list += 1/window_size
			..(null, coeff_list)

	// Sum weighted current input and weighted previous output to achieve output
	// input weight will be ratio of weight assigned to input value while remaining goes to previous output
	//
	// Exponential Smoothing
	// Time constant will be the amount of time to achieve 63.2% of original sum
	// NOTE: This should be performed by a scheduled process as this ensures constant sample interval
	// https://en.wikipedia.org/wiki/Exponential_smoothing
	exponential_moving_average
		proc/init_basic(input_weight)
			var/input_weight_list[1]
			var/prev_output_weight_list[1]
			input_weight_list[1] = input_weight
			prev_output_weight_list[1] = -(1-input_weight)
			init(prev_output_weight_list,input_weight_list)

		proc/init_exponential_smoothing(sample_interval, time_const)
			init_basic(1.0 - ( eulers ** ( -sample_interval / time_const )))


/datum/teg_transformation_clock
	var/obj/machinery/power/generatorTemp/generator
	var/static/list/possible_transformations

	New(teg)
		. = ..()
		generator = teg
		if(!possible_transformations)
			possible_transformations = list()
			for(var/T in childrentypesof(/datum/teg_transformation))
				var/datum/teg_transformation/TT = new T
				possible_transformations += TT

	disposing()
		. = ..()
		generator = null

	proc/check_reagent_transformation()
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

	proc/check_material_transformation()
		// Transform when a matsci semiconductor is inserted and the material differs the material
		// from the TEG.  Transformation requires the semiconductor fully back in place and energy
		// is present to activate NANITES!
		if(!generator.active_form || generator.active_form.type == /datum/teg_transformation/matsci)
			if(generator.semiconductor?.material && ((src.generator.semiconductor.material.mat_id != src.generator.material?.mat_id) || !src.generator.material))
				if(src.generator.semiconductor_state == 0 && src.generator.powered())
					SPAWN_DBG(15.0)
						src.generator.use_power(500)
						elecflash(src.generator)
						src.generator.visible_message("<span class='alert'>[src.generator] is suddenly engulfed in a swarm of nanites!</span>")
						var/nanite_overlay = image('icons/misc/critter.dmi', "nanites")
						generator.UpdateOverlays(nanite_overlay,"transform")
						generator.circ1.UpdateOverlays(nanite_overlay,"transform")
						generator.circ2.UpdateOverlays(nanite_overlay,"transform")
						sleep(rand(15,25))
						if(generator.active_form)
							generator.active_form.on_revert()
						generator.active_form = new /datum/teg_transformation/matsci
						generator.active_form.material = generator.semiconductor.material.mat_id
						generator.active_form.on_transform(generator)
						sleep(rand(15,25))
						src.generator.visible_message("<span class='alert'>The swarm of nanites disappears back into \the [src.generator].</span>")
						generator.UpdateOverlays(null,"transform")
						generator.circ1.UpdateOverlays(null,"transform")
						generator.circ2.UpdateOverlays(null,"transform")


ABSTRACT_TYPE(/datum/teg_transformation)
datum
	teg_transformation
		var/name = null
		var/id = null
		var/audio_clip
		var/visible_msg
		var/audible_msg
		var/teg_overlay
		var/circulator_overlay
		var/material
		var/list/required_reagents
		var/obj/machinery/power/generatorTemp/teg

		proc/on_grump()
			return FALSE

		proc/on_transform(obj/machinery/power/generatorTemp/teg)
			src.teg = teg
			if(src.material)
				teg.setMaterial(getMaterial(src.material))
				teg.circ1.setMaterial(getMaterial(src.material))
				teg.circ2.setMaterial(getMaterial(src.material))
			return

		proc/on_revert()
			src.teg.setMaterial(getMaterial(initial(src.material)))
			src.teg.circ1.setMaterial(getMaterial(initial(src.material)))
			src.teg.circ2.setMaterial(getMaterial(initial(src.material)))
			qdel(src.teg.active_form)
			src.teg.active_form = null
			return

		default
			name = "Default"
			material = "steel"

		flock
			material = "gnesis"

		vampire
			material = "bone"

		birdbird
			name = "Squawk"

		matsci
			name = "Prototype"
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

/*
			 		if(W.material)
			var/datum/teg_transformation/matsci/semiconductor = new
			semiconductor.material = W.material.mat_id

			if(generator.active_form)
				generator.active_form.on_revert()
			generator.active_form = semiconductor
			generator.active_form.on_transform(generator)
		*/

/*
  0         1         	2         	3        	4
Present 	Unscrewed  Connected 	Unconnected		Missing
     (Screw)------------------(Snip)--------(Pry)             >>-->> REMOVAL
     (Screw)-----------------(Snip)-------(COIL)---(Item)		<<--<< REPLACEMNT
*/

/datum/action/bar/icon/teg_semiconductor_removal
	id = "teg_semiconductor_removal"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 200
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/machinery/power/generatorTemp/generator
	var/obj/item/the_tool

	New(var/obj/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			generator = O
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (generator == null || the_tool == null || owner == null || get_dist(owner, generator) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		// SCREW->SNIP->CROW (REMOVAL)
		if (generator.semiconductor_state == 0)
			owner.visible_message("<span class='notice'>[owner] begins to dismantle \the [generator] to get access to the semiconductor.</span>")
			playsound(get_turf(generator), "sound/items/Screwdriver.ogg", 50, 1)
		if (generator.semiconductor_state == 1)
			owner.visible_message("<span class='notice'>[owner] begins to snip wiring between the semiconductor and \the [generator].</span>")
			playsound(get_turf(generator), "sound/items/Scissor.ogg", 60, 1)
		if (generator.semiconductor_state == 3)
			owner.visible_message("<span class='notice'>[owner] begins prying out the semiconductor from \the [generator].</span>")
			playsound(get_turf(generator), "sound/items/Crowbar.ogg", 60, 1)

	onEnd()
		..()
		// SCREW->SNIP->CROW (REMOVAL)
		if (generator.semiconductor_state == 0)
			generator.semiconductor_state = 1
			playsound(get_turf(generator), "sound/items/Screwdriver.ogg", 50, 1)
			owner.visible_message("<span class='notice'>[owner] opens up access to the semiconductor.</span>", "<span class='notice'>You unscrew \the [generator] to gain access to the semiconductor.</span>")
			generator.semiconductor_repair = "The semiconductor is visible and needs to be disconnected from the TEG with some wirecutters or closed up with a screwdriver."
			return
		if (generator.semiconductor_state == 1)
			generator.semiconductor_state = 3
			boutput(owner, "<span class='notice'>You snip the last piece of the electrical system connected to the semiconductor.</span>")
			playsound(get_turf(generator), "sound/items/Scissor.ogg", 80, 1)
			generator.semiconductor_repair = "The semiconductor has been disconnected and can be pried out or reconnected with additional cable."
			generator.status = BROKEN // SEMICONDUCTOR DISCONNECTED IT BROKEN
			generator.updateicon()
			return

		if (generator.semiconductor_state == 3)
			generator.semiconductor_state = 4
			boutput(owner, "<span class='notice'>You finish prying the semiconductor out of \the [generator].</span>")
			playsound(get_turf(generator), "sound/items/Deconstruct.ogg", 80, 1)
			generator.semiconductor_repair = "The semiconductor is missing..."

			generator.semiconductor.set_loc(get_turf(generator))
			generator.semiconductor = null
			return

/datum/action/bar/icon/teg_semiconductor_replace
	id = "teg_semiconductor_removal"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 200
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/machinery/power/generatorTemp/generator
	var/obj/item/the_tool

	New(var/obj/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			generator = O
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (generator == null || the_tool == null || owner == null || get_dist(owner, generator) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		// (INSERT)->(COIL)->SNIP->SCREW
		if (generator.semiconductor_state == 4)
			owner.visible_message("<span class='notice'>[owner] begins to insert [the_tool] into \the [generator].</span>")
			playsound(get_turf(generator), "sound/items/Deconstruct.ogg", 60, 1)
		if (generator.semiconductor_state == 3)
			owner.visible_message("<span class='notice'>[owner] begins to wire up the semiconductor and \the [generator].</span>")
			playsound(get_turf(generator), "sound/items/Deconstruct.ogg", 60, 1)
		if (generator.semiconductor_state == 2)
			owner.visible_message("<span class='notice'>[owner] begins cutting the excess wire from the semiconductor.</span>")
			playsound(get_turf(generator), "sound/items/Scissor.ogg", 60, 1)
		if (generator.semiconductor_state == 1)
			owner.visible_message("<span class='notice'>[owner] begins to close up \the [generator] access to the semiconductor.</span>")
			playsound(get_turf(generator), "sound/items/Screwdriver.ogg", 50, 1)

	onEnd()
		..()
		// (INSERT)->(COIL)->SNIP->SCREW
		if (generator.semiconductor_state == 4)
			if (the_tool != null)
				src.generator.semiconductor = the_tool
				if(ismob(owner))
					var/mob/M = owner
					M.drop_item(the_tool)
				generator.semiconductor.set_loc(generator)

				generator.semiconductor_state = 3
				playsound(get_turf(generator), "sound/items/Deconstruct.ogg", 80, 1)
				owner.visible_message("<span class='notice'>[owner] places [the_tool] inside [generator].</span>", "<span class='notice'>You successfully place semiconductor inside \the [generator].</span>")
				generator.semiconductor_repair = "The semiconductor has been disconnected and can be pried out or reconnected with additional cable."

			return
		if (generator.semiconductor_state == 3)
			generator.semiconductor_state = 2
			boutput(owner, "<span class='notice'>You wire up the semicondoctor to \the [generator].</span>")
			playsound(get_turf(generator), "sound/items/Deconstruct.ogg", 80, 1)
			generator.semiconductor_repair = "The semiconductor has been wired in but has excess cable that must be removed."
			if (the_tool != null)
				the_tool.amount -= 4
				if(the_tool.amount <= 0)
					qdel(the_tool)
				else if(istype(the_tool, /obj/item/cable_coil))
					var/obj/item/cable_coil/C = the_tool
					C.updateicon()
			generator.status &= ~BROKEN // SEMICONDUCTOR RECONNECTED IT UNBROKEN
			generator.updateicon()
			return
		if (generator.semiconductor_state == 2)
			generator.semiconductor_state = 1
			boutput(owner, "<span class='notice'>You snip the excess wires from the semiconductor.</span>")
			playsound(get_turf(generator), "sound/items/Scissor.ogg", 80, 1)
			generator.semiconductor_repair = "The semiconductor is visible and needs to be disconnected from \the [generator] with some wirecutters or closed up with a screwdriver."
			return

		if (generator.semiconductor_state == 1)
			generator.semiconductor_state = 0
			owner.visible_message("<span class='notice'>[owner] closes up access to the semiconductor in \the [generator].</span>", "<span class='notice'>You successfully replaced the semiconductor.</span>")
			playsound(get_turf(generator), "sound/items/Deconstruct.ogg", 80, 1)
			generator.semiconductor_repair = null
			return


/obj/item/teg_semiconductor
	name = "Prototype Semiconductor"
	desc = "A large rectangulr plate stamped with 'Prototype Thermo-Electric Generator Semiconductor.  If found please return to NanoTrasen.'"
	icon = 'icons/obj/power.dmi'
	icon_state = "semi"


