/obj/machinery/artifact/heater
	name = "artifact heater"
	associated_datum = /datum/artifact/heater

/datum/artifact/heater
	associated_object = /obj/machinery/artifact/heater
	rarity_class = 1 // modified from 2 as part of art tweak
	validtypes = list("ancient","martian","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/radiation,/datum/artifact_trigger/cold)
	activ_text = "begins to radiate air!"
	deact_text = "stops pumping out air."
	react_xray = list(10,85,80,5,"COMPLEX")
	var/heat_target = 310
	var/heat_amount = 40000
	examine_hint = "It is covered in very conspicuous markings."

	post_setup()
		heat_target = rand(0,620)
		if (artitype.name == "eldritch" && prob(66))
			if (heat_target > 310)
				heat_target *= 2
			if (heat_target < 310 && heat_target != 0)
				heat_target /= 2
		heat_amount = rand(20000,60000)
		if (heat_target > 310)
			activ_text = "begins to radiate hot air!"
			deact_text = "stops pumping out hot air."
		if (heat_target < 310)
			activ_text = "begins to radiate cold air!"
			deact_text = "stops pumping out cold air."

	effect_process(var/obj/O)
		if (..())
			return
		var/turf/simulated/L = get_turf(O)
		if(istype(L))
			var/datum/gas_mixture/env = L.return_air()
			if(env.temperature < (heat_target+T0C))
				var/transfer_moles = 0.25 * TOTAL_MOLES(env)
				var/datum/gas_mixture/removed = env.remove(transfer_moles)
				if(removed)
					var/heat_capacity = HEAT_CAPACITY(removed)
					if(heat_capacity)
						removed.temperature = (removed.temperature*heat_capacity + heat_amount)/heat_capacity
				env.merge(removed)
