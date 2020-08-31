// base

/datum/artifact/bomb
	associated_object = null
	rarity_class = 0
	validtypes = list("ancient","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/cold,/datum/artifact_trigger/radiation)
	react_xray = list(12,75,30,11,"COMPLEX")
	var/explode_delay = 600
	var/dud = 0
	var/warning_initial = "begins catastrophically overloading!"
	var/warning_final = "reaches critical energy levels!"
	var/text_disarmed = "goes quiet."
	var/text_dud = "sputters and rattles a bit, then falls quiet."
	var/flascustomization_first_color = "#FF0000"
	var/sound/alarm_initial = 'sound/machines/lavamoon_plantalarm.ogg'
	var/sound/alarm_final = 'sound/machines/engine_alert1.ogg'
	examine_hint = "It is covered in very conspicuous markings."

	New()
		..()
		src.react_heat[2] = "VOLATILE REACTION DETECTED"

	post_setup()
		if (artitype.name != "eldritch" && prob(5))
			dud = 1

	effect_activate(var/obj/O)
		if (..())
			return
		if (explode_delay < 1)
			deploy_payload(O)
			return

		var/turf/T = get_turf(O)

		if (warning_initial)
			T.visible_message("<b><span class='alert'>[O] [warning_initial]</b></span>")
		if (alarm_initial)
			playsound(T, alarm_initial, 100, 1, -1)

		SPAWN_DBG(src.explode_delay)  //who the fuck coded this shit below without running get_turf again
			T = get_turf(O)
			if (warning_final)
				T.visible_message("<b><span class='alert'>[O] [warning_final]</b></span>")
			if (alarm_final)
				playsound(T, alarm_final, 100, 1, -1)
			animate_flash_color_fill(O,flascustomization_first_color,10,3)

			SPAWN_DBG(3 SECONDS)
				T = get_turf(O)
				if (src.activated)
					deploy_payload(O)
				else
					T.visible_message("<b><span class='notice'>[O] [text_disarmed]</b></span>")

	proc/deploy_payload(var/obj/O)
		if (!O)
			return 1
		if (dud)
			var/turf/T = get_turf(O)
			T.visible_message("<b>[O] [text_dud]")
			O.ArtifactDeactivated()
			return 1

		// Added (Convair880).
		ArtifactLogs(usr, null, O, "detonated", null, 1)

		return 0

// regular explosives

/obj/artifact/bomb
	name = "artifact bomb"
	associated_datum = /datum/artifact/bomb/explosive

/datum/artifact/bomb/explosive
	associated_object = /obj/artifact/bomb
	rarity_class = 3
	var/exp_deva = 1
	var/exp_hevy = 2
	var/exp_lite = 3

	New()
		..()
		src.exp_deva = rand(0,3)
		src.exp_hevy = rand(3,6)
		src.exp_lite = rand(6,9)

	deploy_payload(var/obj/O)
		if (..())
			return
		explosion(O, O.loc, src.exp_deva, src.exp_hevy, src.exp_lite, src.exp_lite * 2)

		O.ArtifactDestroyed()

/obj/artifact/bomb/devastating
	name = "artifact devastating bomb"
	associated_datum = /datum/artifact/bomb/explosive/devastating

/datum/artifact/bomb/explosive/devastating
	associated_object = /obj/artifact/bomb/devastating
	rarity_class = 4

	New()
		..()
		src.exp_deva *= rand(3,5)
		src.exp_hevy *= rand(4,6)
		src.exp_lite *= rand(5,7)
		src.explode_delay *= 1.5 //Was too long, nobody would know it was a bomb.ZeWaka

// black hole bomb

/obj/artifact/bomb/blackhole
	name = "artifact black hole bomb"
	associated_datum = /datum/artifact/bomb/blackhole

/datum/artifact/bomb/blackhole
	associated_object = /obj/artifact/bomb/blackhole
	rarity_class = 4
	react_xray = list(12,75,30,11,"ULTRADENSE")
	warning_initial = "begins intensifying its own gravity!"
	warning_final = "begins to collapse in on itself!"

	deploy_payload(var/obj/O)
		if (..())
			return
		var/turf/T = get_turf(O)
		playsound(T, "sound/machines/satcrash.ogg", 100, 0, 3, 0.8)
		new /obj/bhole(O.loc,rand(100,300))

		if (O)
			O.ArtifactDestroyed()

// chemical bombs

/obj/artifact/bomb/chemical
	name = "artifact chemical bomb"
	associated_datum = /datum/artifact/bomb/chemical

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src

/datum/artifact/bomb/chemical
	associated_object = /obj/artifact/bomb/chemical
	rarity_class = 2
	explode_delay = 0
	react_xray = list(5,65,20,11,"HOLLOW")
	validtypes = list("ancient","martian","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/heat,/datum/artifact_trigger/carbon_touch)
	var/payload_type = 0 // 0 for smoke, 1 for foam, 2 for propellant, 3 for just dumping fluids
	var/recharge_delay = 600
	var/list/payload_reagents = list()

	post_setup()
		payload_type = rand(0,3)
		var/list/potential_reagents = list()
		switch(artitype.name)
			if ("ancient")
				// industrial heavy machinery kinda stuff
				potential_reagents = list("nanites","liquid plasma","mercury","lithium","plasma","radium","uranium","phlogiston",
				"thermite","fuel","acid","silicate","lube","cryostylane","oil")
			if ("martian")
				// medicine, some poisons, some gross stuff
				potential_reagents = list("charcoal","styptic_powder","salbutamol","anti_rad","silver_sulfadiazine","synaptizine",
				"omnizine","synthflesh","cyanide","ketamine","toxin","neurotoxin","mutagen","fake_initropidril",
				"toxic_slurry","jenkem","space_fungus","blood","vomit","gvomit","urine","meat_slurry","grease")
			if ("eldritch")
				// all the worst stuff. all of it
				potential_reagents = list("chlorine","fluorine","lithium","mercury","plasma","radium","uranium","strange_reagent",
				"phlogiston","thermite","infernite","foof","fuel","blackpowder","acid","amanitin","coniine","cyanide","curare",
				"formaldehyde","lipolicide","initropidril","cholesterol","itching","pacid","pancuronium","polonium",
				"sodium_thiopental","ketamine","sulfonal","toxin","venom","neurotoxin","mutagen","wolfsbane",
				"toxic_slurry","histamine","sarin")
			else
				// absolutely everything
				potential_reagents = all_functional_reagent_ids

		if (potential_reagents.len > 0)
			var/looper = rand(2,8)
			while (looper > 0)
				var/reagent = pick(potential_reagents)
				if(payload_type == 3 && ban_from_fluid.Find(reagent)) // do not pick stuff that is banned from fluid dump
					continue
				looper--
				payload_reagents += reagent

		recharge_delay = rand(200,800)

	deploy_payload(var/obj/O)
		if (..())
			return

		var/list/reaction_reagents = list()

		for (var/X in payload_reagents)
			reaction_reagents += X

		var/amountper = 0
		if (reaction_reagents.len > 0)
			amountper = round(O.reagents.maximum_volume / reaction_reagents.len)
		else
			amountper = 20

		for (var/X in reaction_reagents)
			O.reagents.add_reagent(X,amountper)

		var/turf/location = get_turf(O)
		switch(payload_type)
			if(0)
				var/datum/effects/system/foam_spread/s = new()
				s.set_up(O.reagents.total_volume, location, O.reagents, 0)
				s.start()
			if(1)
				O.reagents.smoke_start(10)
			if(2)
				O.reagents.smoke_start(10,1)
			if(3)
				location.fluid_react(O.reagents, O.reagents.total_volume)

		O.reagents.clear_reagents()

		SPAWN_DBG(recharge_delay)
			if (O)
				O.ArtifactDeactivated()
