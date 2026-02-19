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
		for(var/datum/teg_transformation/T as anything in possible_transformations)
			if(generator.active_form?.type == T.type) continue // Skip current form

			var/reagents_present = length(T.required_reagents)
			for(var/R as anything in T.required_reagents)
				if(generator.circ1.reagents.get_reagent_amount(R) + generator.circ2.reagents.get_reagent_amount(R) >= T.required_reagents[R])
					; // Do nothing
				else
					reagents_present = FALSE
					break

			if(reagents_present)
				transform_to_type(T.type)
				return

	proc/transform_to_type(type, mat_id)
		if(ispath(type, /datum/teg_transformation))
			logTheThing(LOG_STATION, generator, "began TEG transformation [type][mat_id ? " (material: [mat_id])" : ""].")
			SPAWN(0)
				if(generator.active_form)
					generator.active_form.on_revert()
				generator.active_form = new type
				if(mat_id)
					generator.active_form.mat_id = mat_id
				generator.active_form.on_transform(generator)

	/// Transform when a matsci semiconductor is inserted and the material differs the material
	/// from the TEG.  Transformation requires the semiconductor fully back in place and energy
	/// is present to activate NANITES!
	proc/check_material_transformation()
		if(!generator.active_form || istype(generator.active_form, /datum/teg_transformation/matsci))
			if(generator.semiconductor?.can_transform && generator.semiconductor?.material && ((src.generator.semiconductor.material.getID() != src.generator.material?.getID()) || !src.generator.material))
				if(src.generator.semiconductor_state == 0 && src.generator.powered())
					SPAWN(1.5 SECONDS)
						src.generator.use_power(500 WATTS)
						elecflash(src.generator)
						src.generator.visible_message(SPAN_ALERT("[src.generator] is suddenly engulfed in a swarm of nanites!"))
						var/nanite_overlay = image('icons/misc/critter.dmi', "nanites")
						generator.UpdateOverlays(nanite_overlay,"transform")
						generator.circ1.UpdateOverlays(nanite_overlay,"transform")
						generator.circ2.UpdateOverlays(nanite_overlay,"transform")
						sleep(randfloat(1.5 SECONDS, 2.5 SECONDS))
						transform_to_type(/datum/teg_transformation/matsci, generator.semiconductor.material.getID())
						sleep(randfloat(1.5 SECONDS, 2.5 SECONDS))
						src.generator.visible_message(SPAN_ALERT("The swarm of nanites disappears back into \the [src.generator]."))
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
	proc/on_grump(mult)
		return FALSE

	/// Base transformation to assign material
	proc/on_transform(obj/machinery/power/generatorTemp/teg)
		var/datum/material/M
		src.teg = teg
		if(initial(src.mat_id))
			M = getMaterial(src.mat_id)
		else
			M = src.teg.semiconductor.material.copyMaterial()

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

		on_transform()
			var/electrical_conductivity
			var/thermal_conductivity
			var/efficiency_shift

			. = ..()
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
				electrical_conductivity = src.teg.material.getProperty("electrical") * 10

			thermal_conductivity = 50
			if(src.teg.material.hasProperty("thermal"))
				thermal_conductivity =  src.teg.material.getProperty("thermal") * 10

			/*    2σ / κ = zT    - Offset 				Result 	*/
			/*  2*75 / 25 = 6    - 2 = 4  		 	 Great! 	*/
			/*	2*50 / 50 = 2    - 2 = 0  			 No Change*/
			/*  2*25 / 75 = 0.66 -2  = -1.34 		 TERRIBAD */
			/* Use above offset * 10 to put it in the -20 to 40 ballpark */
			efficiency_shift = (2 * electrical_conductivity / thermal_conductivity) - 2 //center on zero
			src.teg.semiconductor.efficiency_offset = clamp(efficiency_shift*10, -20, 40) //scale shift by 10 which gets it in the ballpark!
