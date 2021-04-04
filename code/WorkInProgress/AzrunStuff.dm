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
		for(var/datum/teg_transformation/T as anything in possible_transformations)
			if(generator.active_form?.type == T.type) continue // Skip current form

			var/reagents_present = length(T.required_reagents)
			for(var/R as anything in T.required_reagents)
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

// CE's pet rock! A true hellburn companion
obj/item/rocko
	name = "Rocko"
	icon = 'icons/obj/materials.dmi'
	icon_state = "rock1"
	w_class = 1
	var/static/list/rocko_is
	var/smile = TRUE
	var/painted
	var/bright = FALSE
	var/awakened = TRUE // SHOULD BE FALSE
	var/power_level = 0
	var/area/prev_area
	var/list/area/visited
	var/list/obj/item/device/key/keys_touched
	var/mob/living/holder
	var/obj/item/clothing/head/hat
	var/dna_collected

	New()
		. = ..()
		visited = list()
		keys_touched = list()
		var/matrix/xf = matrix()
		if(prob(20))
			bright = TRUE

		src.chat_text = new
		src.vis_contents += src.chat_text

		src.icon_state = "rock[pick(1,3)]"
		src.transform = xf*1.2
		src.rocko_is = list("a great listener", "a good friend", "trustworthy", "wise", "sweet", "great at parties")
		update_icon()
		START_TRACKING_CAT(TR_CAT_PETS)
		processing_items |= src

	set_loc(var/newloc as turf|mob|obj in world)
		var/atom/oldloc = src.loc
		src.holder = null
		. = ..()
		if(src && !src.disposed && src.loc && (!istype(src.loc, /turf) || !istype(oldloc, /turf)))
			if(src.chat_text.vis_locs.len)
				var/atom/movable/AM = src.chat_text.vis_locs[1]
				AM.vis_contents -= src.chat_text
			if(istype(src.loc, /turf))
				src.vis_contents += src.chat_text
			if(ismob(src.loc))
				src.holder = src.loc

	disposing()
		processing_items -= src
		qdel(chat_text)
		chat_text = null
		STOP_TRACKING_CAT(TR_CAT_PETS)
		..()

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (istype(W, /obj/item/device/key))
			var/obj/item/device/key/K = W

			if(!keys_touched.Find(K))
				keys_touched += K
				if(!particleMaster.CheckSystemExists(/datum/particleSystem/sparkles, src))
					particleMaster.SpawnSystem(new /datum/particleSystem/sparkles(src))
					SPAWN_DBG(20 SECONDS)
						particleMaster.RemoveSystem(/datum/particleSystem/sparkles, src)
				if(ismob(src.loc))
					var/mob/M = src.loc
					boutput(M,"<B>[src]</B> glows brightly momentarily and begins to sparkle.")
				else
					src.visible_message("<B>[src]</B> glows brightly momentarily and begins to sparkle.")

	proc/can_mob_observe(/var/mob/M)
		if(src.awakened)
			. = TRUE
			return

		var/view_chance = 0

		if(M.job == "Chief Engineer")
			view_chance += 2
			if(src.holder == M)
				view_chance += 5

		// whoa dude!
		if(M.reagents?.total_volume && (M.reagents.has_reagent("LSD") || M.reagents.has_reagent("lsd_bee") || M.reagents.has_reagent("psilocybin") || M.reagents?.has_reagent("bathsalts") || M.reagents?.has_reagent("THC")) )
			view_chance += 20
		if(M.hasStatus("drunk"))
			view_chance += 10

		//when above powered theshold
		if(M.job in list("Engineer", "Chief Engineer", "Mechanic"))
			view_chance += 10
		else
			view_chance += 5

		return prob(view_chance)

	process()
		var/area/current_area = get_area(src)
		if(src.prev_area != current_area)
			src.visited |= current_area
			src.prev_area = get_area(src)

		if(prob(95))
			return

		switch(pick( 200;1, 10;2, 10;3, 10;4, 200;5))
			if(1)
				emote("<B>[src]</B> winks.", "<I>winks</I>")
			if(2)
				if(holder) boutput(holder,"<B>[src]</B> feels warm.")
			if(3)
				emote("<B>[src]</B> whispers something about a hellburn.", "<I>whispers something about a hellburn</I>")
			if(4)
				emote("<B>[src]</B> rants about job site safety.", "<I>Goes on about job safety</I>")
			if(5)
				speak("We really need to do something about the [pick("captain", "head of personnel", "clown", "research director", "head of security", "medical director", "AI")].")

	proc/speak(message)
		var/list/targets
		var/image/chat_maptext/chat_text = null

		if(!holder)
			targets = hearers(src, null)
			chat_text = make_chat_maptext(src, message, "color: ["#bfd6d8"];", alpha = 200)
		else
			targets = list(holder)

		for(var/mob/O in targets)
			if(src.can_mob_observe(O))
				O.show_message("<span class='game say bold'><span class='name'>[src.name]</span> says, <span class='message'>\"[message]\"</span></span>", 2, assoc_maptext = chat_text)

	proc/emote(message, maptext_out)
		var/list/targets
		var/image/chat_maptext/chat_text = null

		if(!holder)
			targets = viewers(src, null)
			chat_text = make_chat_maptext(src, maptext_out, "color: #C2BEBE;", alpha = 120)
		else
			targets = list(holder)

		for (var/mob/O in targets)
			if(src.can_mob_observe(O))
				O.show_message("<span class='emote'>[message]</span>", assoc_maptext = chat_text)

	proc/update_icon()
		var/icon/smiley_icon = icon('icons/misc/stickers.dmi', src.smile ? "smile2" : "frown2")
		smiley_icon.Shift(SOUTH,3)
		var/image/smiley = image(smiley_icon)
		smiley.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

		if(bright)
			smiley.blend_mode = BLEND_ADD
			painted = pick(list("#FF0","#0FF","#FFF"))
		else
			smiley.blend_mode = BLEND_SUBTRACT
			painted = pick(list("#3F3", "#FFF","#5F0","#0F5","#F50"))

		smiley.color = color_mapping_matrix(
			list("#663300", "#FFAA00", "#FFE924"),
			list(painted, "#000", "#000")
			)
		src.UpdateOverlays(smiley, "face")
		update_hat()

	proc/update_hat()
		if(istype(src.hat))
			var/icon/working_icon = icon(src.hat.wear_image_icon, src.hat.icon_state, SOUTH )
			working_icon.Shift(SOUTH, 10)
			src.UpdateOverlays(image(working_icon), "hat")
		else
			src.UpdateOverlays(null, "hat")

	get_desc(dist, mob/user)
		if(ismob(user) &&	user.job == "Chief Engineer")
			. = "A rock but also [pick(rocko_is)]."
		else if(ismob(user) && (user.job in list("Engineer", "Mechanic", "Quarter Master", "Quartermaster", "Captain")))
			. = "The Chief Engineer loves this rock.  Maybe it's to make up for their lack of a pet."
		else
			. = "A rock with a [src.smile ? "smiley" : "frowny"] face painted on it."

	attackby(obj/item/W, mob/living/user)
		if(istype(W,/obj/item/clothing/head))
			if(src.hat)
				src.set_loc(get_turf(src))
				src.hat = null

			src.hat = W
			user.drop_item(W)
			W.set_loc(src)
			user.visible_message("[user] manages to fit [W] snugly on top of [src].")
			update_hat()
		. = ..()

	attack_self(mob/user as mob)
		. = "[user] shakes [src]"
		if(hat && prob(40))
			. += "and knocks [src.hat] off"
			src.hat.set_loc(get_turf(src))
			src.hat = null
			update_hat()
		user.visible_message("[.].")

	proc/calculate_power_level()
		power_level = length(src.visited) * 1
		power_level += length(src.keys_touched) * 10
