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
			M = copyMaterial(src.teg.semiconductor.material)
			teg.setMaterial(M)
			teg.circ1.setMaterial(M)
			teg.circ2.setMaterial(M)

	/// Revert material back to initial values
	proc/on_revert()
		src.teg.setMaterial(getMaterial(initial(src.mat_id)))
		src.teg.circ1.setMaterial(getMaterial(initial(src.mat_id)))
		src.teg.circ2.setMaterial(getMaterial(initial(src.mat_id)))
		qdel(src.teg.active_form)

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
