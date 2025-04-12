/obj/machinery/artifact/gas_radiator
	name = "artifact gas radiator"
	associated_datum = /datum/artifact/gas_radiator
	pressure_resistance = 1000 * ONE_ATMOSPHERE // please do not move

/datum/artifact/gas_radiator
	associated_object = /obj/machinery/artifact/gas_radiator
	type_name = "Gas radiator"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 450
	validtypes = list("ancient","martian","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/cold)
	activ_text = "begins to emit gas!"
	deact_text = "stops emitting gas."
	react_xray = list(10,85,80,5,"COMPLEX")
	var/gas_type = "oxygen"
	var/gas_temp = 310 KELVIN
	var/gas_amount = 100 MOLES
	var/gas_amount_current = 0 MOLES
	var/gas_amount_growth = 5 MOLES
	var/temp_text = "lukewarm"
	examine_hint = "It is covered in very conspicuous markings."
	combine_flags = ARTIFACT_COMBINES_INTO_ANY | ARTIFACT_ACCEPTS_ANY_COMBINE

	post_setup()
		. = ..()
		// gas type
		// oxygen is really the only thing here that's not dangerous, so I am having it be pretty common
		switch(artitype.name)
			if("eldritch") // bad things
				gas_type = pick(
					100;"nitrogen",
					100;"plasma",
					100;"carbon dioxide",
					75;"sleeping agent",
					10;"fallout")
			if("martian") // organic stuff
				gas_type = pick(
					200;"oxygen",
					100;"nitrogen",
					50;"carbon dioxide",
					50;"farts")
			if("ancient") // industrial type stuff
				gas_type = pick(
					200;"oxygen",
					100;"nitrogen",
					50;"carbon dioxide",
					50;"agent b")
			if("precursor") // all the god damn gases
				gas_type = pick(
					125;"oxygen",
					100;"nitrogen",
					75;"plasma",
					50;"carbon dioxide",
					30;"farts",
					30;"agent b",
					30;"sleeping agent",
					10;"fallout")

		// temperature
		gas_temp = rand(0 KELVIN, 620 KELVIN)
		if (artitype.name == "eldritch" && prob(66))
			if (gas_temp > 310 KELVIN)
				gas_temp *= 2
			if (gas_temp < 310 KELVIN)
				gas_temp /= 2

		// amount
		gas_amount = rand(50 MOLES, 200 MOLES)

		// text
		switch (gas_temp - T0C)
			// Give a bit more of a hint as to the temperature
			// values are fairly arbitrary
			if (-INFINITY to -40)
				temp_text = "very cold"
			if (-40 to 10)
				temp_text = "cold"
			if (10 to 30) // roughly "around room tempeature"
				temp_text = "mild"
			if (30 to 60)
				temp_text = "warm"
			if (60 to INFINITY)
				temp_text = "very hot"


		src.activ_text = "begins to emit [temp_text] gas!"
		src.deact_text = "stops emitting [temp_text] gas."

	effect_activate(obj/O)
		if(..())
			return
		ArtifactLogs(usr, null, O, "activated", "making it radiate [temp_text] ([gas_temp - T0C]&deg;C) [gas_type]", 1)

	effect_process(var/obj/O)
		if (..())
			return
		if(src.gas_amount_current < src.gas_amount)
			src.gas_amount_current = min(src.gas_amount_current + src.gas_amount_growth, src.gas_amount)
		var/turf/simulated/L = get_turf(O)
		if(istype(L))
			var/datum/gas_mixture/gas = new /datum/gas_mixture
			switch(src.gas_type)
				if("oxygen")
					gas.oxygen = src.gas_amount_current
				if("nitrogen")
					gas.nitrogen = src.gas_amount_current
				if("plasma")
					gas.toxins = src.gas_amount_current
				if("carbon dioxide")
					gas.carbon_dioxide = src.gas_amount_current
				if("farts")
					gas.farts = src.gas_amount_current
				if("agent b")
					gas.oxygen_agent_b = src.gas_amount_current
				if("sleeping agent")
					gas.nitrous_oxide = src.gas_amount_current
				if("fallout")
					gas.radgas = src.gas_amount_current
			gas.temperature = src.gas_temp
			if (L)
				L.assume_air(gas)

	effect_deactivate(obj/O)
		if(..())
			return
		src.gas_amount_current = 0 MOLES

