// base

ABSTRACT_TYPE(/datum/artifact/bomb)
/datum/artifact/bomb
	type_size = ARTIFACT_SIZE_LARGE
	associated_object = null
	rarity_weight = 0
	validtypes = list("ancient","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,
	/datum/artifact_trigger/cold,/datum/artifact_trigger/radiation, /datum/artifact_trigger/language)
	fault_blacklist = list(ITEM_ONLY_FAULTS, TOUCH_ONLY_FAULTS) // can't sting you at range
	react_xray = list(12,75,30,11,"COMPLEX")
	var/explode_delay = 600
	var/dud = 0
	var/warning_initial = "begins catastrophically overloading!"
	var/warning_final = "reaches critical energy levels!"
	var/text_disarmed = "goes quiet."
	var/text_cooldown = "makes a subdued noise."
	var/text_dud = "sputters and rattles a bit, then falls quiet."
	var/flascustomization_first_color = "#FF0000"
	var/sound/alarm_initial = 'sound/machines/lavamoon_plantalarm.ogg'
	var/sound/alarm_during = 'sound/machines/alarm_a.ogg'
	var/sound/alarm_final = 'sound/machines/engine_alert1.ogg'
	var/sound/sound_cooldown = 'sound/machines/weaponoverload.ogg'
	var/doAlert = 0
	var/blewUp = 0
	var/animationScale = 3
	var/detonation_time = INFINITY
	var/lightColor = list(255,255,255,255)
	var/recharge_delay = 0
	examine_hint = "It is covered in very conspicuous markings."
	shard_reward = ARTIFACT_SHARD_POWER

	New()
		..()
		src.react_heat[2] = "VOLATILE REACTION DETECTED"

	post_setup()
		. = ..()
		if (artitype.name != "eldritch" && prob(3))
			dud = 1

	effect_activate(var/obj/O)
		if (..())
			return
		var/turf/T = get_turf(O)
		src.detonation_time = TIME + src.explode_delay
		if(recharge_delay && ON_COOLDOWN(O, "bomb_cooldown", recharge_delay))
			T.visible_message(SPAN_ALERT("<b>[O] [text_cooldown]</b>"))
			playsound(T, sound_cooldown, 100, TRUE)
			SPAWN(3 SECONDS)
				O.ArtifactDeactivated() // lol get rekt spammer
			return

		// this is all just fluff
		if (warning_initial)
			T.visible_message("<b>[SPAN_ALERT("[O] [warning_initial]</b>")]")
		if (alarm_initial)
			playsound(T, alarm_initial, 100, TRUE, doAlert?200:-1)
		if (doAlert)
			var/area/A = get_area(O)
			command_alert("An extremely unstable object of [artitype.type_name] origin has been detected in [A]. The crew is advised to dispose of it immediately.", "Station Threat Detected", alert_origin = ALERT_ANOMALY)
		message_ghosts("<b>An artifact bomb</b> has just been triggered in [log_loc(T, ghostjump=TRUE)].")
		O.add_simple_light("artbomb", lightColor)
		animate(O, pixel_y = rand(-3,3), pixel_y = rand(-3,3),time = 1,loop = src.explode_delay + 10 SECONDS, easing = ELASTIC_EASING, flags=ANIMATION_PARALLEL)
		animate(O.simple_light, flags=ANIMATION_PARALLEL, time = src.explode_delay + 10 SECONDS, transform = matrix() * animationScale)


	effect_process(var/obj/O)
		if(..())
			return
		if(!src.activated)
			return
		var/turf/T = get_turf(O)
		if(alarm_during)
			playsound(T, alarm_during, 30, TRUE) // repeating noise, so people who come near later know it's a bomb

		if(TIME > src.detonation_time)
			src.detonation_time = INFINITY
			if (!O || !T) // please stop
				return

			// more fluff
			if (warning_final)
				T.visible_message("<b>[SPAN_ALERT("[O] [warning_final]</b>")]")
			if (alarm_final)
				playsound(T, alarm_final, 100, TRUE, -1)
			animate(O, pixel_y = rand(-3,3), pixel_y = rand(-3,3),time = 1,loop = 10 SECONDS, easing = ELASTIC_EASING, flags=ANIMATION_PARALLEL)
			if(O.simple_light)
				animate(O.simple_light, flags=ANIMATION_PARALLEL, time = 10 SECONDS, transform = matrix() * animationScale)

			// actual boom
			SPAWN(10 SECONDS)
				if (!O.disposed && src.activated)
					blewUp = 1
					deploy_payload(O)

	effect_deactivate(obj/O)
		if(..())
			return
		// and remove all the animation stuff when it is deactivated (:
		animate(O, pixel_y = 0, pixel_y = 0, time = 3,loop = 1, easing = LINEAR_EASING)
		if(O.simple_light)
			animate(O.simple_light, flags=ANIMATION_PARALLEL, time= 3 SECONDS, transform = null)
		SPAWN(3 SECONDS)
			O.remove_simple_light("artbomb")
		var/turf/T = get_turf(O)
		T.visible_message("<b>[SPAN_NOTICE("[O] [text_disarmed]</b>")]")
		if(src.doAlert && !src.blewUp && !ON_COOLDOWN(O, "alertDisarm", 10 MINUTES)) // lol, don't give the message if it was destroyed by exploding itself
			command_alert("The object of [src.artitype.type_name] origin has been neutralized. All personnel should return to their duties.", "Station Threat Neutralized", alert_origin = ALERT_ANOMALY)

	proc/deploy_payload(var/obj/O)
		if (!O)
			return 1
		if (dud)
			var/turf/T = get_turf(O)
			T.visible_message("<b>[O] [text_dud]")
			if(src.doAlert && !ON_COOLDOWN(O, "alertDud", 10 MINUTES))
				command_alert("The object of [src.artitype.type_name] origin appears to be nonfunctional. All personnel should return to their duties.", "Station Threat Neutralized", alert_origin = ALERT_ANOMALY)
			O.ArtifactDeactivated()
			return 1

		// Added (Convair880).
		ArtifactLogs(usr, null, O, "detonated", log_addendum, 1)

		return 0

// regular explosives

/obj/machinery/artifact/bomb
	name = "artifact bomb"
	associated_datum = /datum/artifact/bomb/explosive

	ArtifactDestroyed()
		. = ..()
		if(src.artifact && istype(src.artifact, /datum/artifact/bomb))
			var/datum/artifact/bomb/B = src.artifact
			if(B.doAlert && B.activated && !B.blewUp) // lol, don't give the message if it was destroyed by exploding itself
				command_alert("The object of [B.artitype.type_name] origin has been neutralized. All personnel should return to their duties.", "Station Threat Neutralized", alert_origin = ALERT_ANOMALY)



/datum/artifact/bomb/explosive
	associated_object = /obj/machinery/artifact/bomb
	type_name = "Bomb (explosive)"
	rarity_weight = 200
	var/exp_deva = 1
	var/exp_hevy = 2
	var/exp_lite = 3

	New()
		..()
		src.exp_deva = rand(0,3)
		src.exp_hevy = rand(3,6)
		src.exp_lite = rand(6,9)

	post_setup()
		. = ..()
		src.react_xray[1] = src.exp_hevy*5

	deploy_payload(var/obj/O)
		if (..())
			return
		explosion(O, get_turf(O), src.exp_deva, src.exp_hevy, src.exp_lite, src.exp_lite * 2)

		O.ArtifactDestroyed()

/obj/machinery/artifact/bomb/devastating
	name = "artifact devastating bomb"
	associated_datum = /datum/artifact/bomb/explosive/devastating

/datum/artifact/bomb/explosive/devastating
	associated_object = /obj/machinery/artifact/bomb/devastating
	type_name = "Bomb (explosive, devastating)"
	rarity_weight = 90
	doAlert = 1
	recharge_delay = 10 MINUTES
	animationScale = 6

	New()
		..()
		src.exp_deva *= rand(2,4)
		src.exp_hevy *= rand(3,5)
		src.exp_lite *= rand(5,7)
		src.explode_delay *= 2 // I added some more stuff so hopefully people will know it's a bomb now!

// black hole bomb

/obj/machinery/artifact/bomb/blackhole
	name = "artifact black hole bomb"
	associated_datum = /datum/artifact/bomb/blackhole

/datum/artifact/bomb/blackhole
	associated_object = /obj/machinery/artifact/bomb/blackhole
	type_name = "Bomb (black hole)"
	rarity_weight = 90
	react_xray = list(12,75,30,11,"ULTRADENSE")
	warning_initial = "begins intensifying its own gravity!"
	warning_final = "begins to collapse in on itself!"

	deploy_payload(var/obj/O)
		if (..())
			return
		var/turf/T = get_turf(O)
		playsound(T, 'sound/machines/singulo_start.ogg', 90, FALSE, 3)
		new /obj/bhole(T,rand(100,300))

		if (O)
			O.ArtifactDestroyed()

// chemical bombs
// different types of bombs for "payload_type"
#define CHEMBOMB_FOAMY 0
#define CHEMBOMB_SMOKEY 1
#define CHEMBOMB_CLASSICAL_GAS 2
#define CHEMBOMB_FLUIDY 3


/obj/machinery/artifact/bomb/chemical
	name = "artifact chemical bomb"
	associated_datum = /datum/artifact/bomb/chemical

	New()
		..()
		src.create_reagents(rand(100,1000))

/datum/artifact/bomb/chemical
	associated_object = /obj/machinery/artifact/bomb/chemical
	type_name = "Bomb (chemical)"
	rarity_weight = 350
	explode_delay = 0
	alarm_initial = null
	alarm_during = null
	alarm_final = null
	react_xray = list(5,65,20,11,"HOLLOW")
	validtypes = list("ancient","martian","eldritch","precursor")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/heat,/datum/artifact_trigger/carbon_touch)
	var/payload_type = 0 // 0 for smoke, 1 for foam, 2 for propellant, 3 for just dumping fluids
	recharge_delay = 10 MINUTES
	var/list/payload_reagents = list()

	post_setup()
		. = ..()
		payload_type = rand(0,3)
		var/payload_type_name = "unknown"
		switch (payload_type)
			if (CHEMBOMB_FOAMY)
				payload_type_name = "foam"
			if (CHEMBOMB_SMOKEY)
				payload_type_name = "smoke"
			if (CHEMBOMB_CLASSICAL_GAS)
				payload_type_name = "propellant"
			if (CHEMBOMB_FLUIDY)
				payload_type_name = "fluid"

		var/list/potential_reagents = list()
		switch(artitype.name)
			if ("ancient")
				// industrial heavy machinery kinda stuff
				potential_reagents = list("nanites","liquid plasma","mercury","lithium","plasma","radium","uranium","phlogiston",
				"silicon","gypsum","sodium_sulfate","diethylamine","pyrosium","thermite","fuel","acid","silicate","lube","cryostylane",
				"ash","clacid","oil","acetone","ammonia")
			if ("martian")
				// medicine, some poisons, some gross stuff
				potential_reagents = list("charcoal","styptic_powder","salbutamol","anti_rad","silver_sulfadiazine","synaptizine",
				"omnizine","synthflesh","saline","salicylic_acid","menthol","calomel","penteticacid","antihistamine","atropine","solipsizine",
				"perfluorodecalin","ipecac","mutadone","insulin","epinephrine","cyanide","ketamine","toxin","neurotoxin","neurodepressant","mutagen",
				"fake_initropidril","toxic_slurry","space_fungus","blood","vomit","gvomit","meat_slurry","grease","butter","spaceglue", "ants")
			if ("eldritch")
				// all the worst stuff. all of it
				potential_reagents = list("chlorine","fluorine","lithium","mercury","plasma","radium","uranium","strange_reagent",
				"phlogiston","thermite","infernite","foof","fuel","blackpowder","acid","amanitin","coniine","cyanide","curare",
				"formaldehyde","lipolicide","initropidril","cholesterol","itching","pacid","pancuronium","polonium",
				"sodium_thiopental","ketamine","sulfonal","toxin","cytotoxin","neurotoxin","mutagen","wolfsbane",
				"toxic_slurry","histamine","saxitoxin","hemotoxin","ricin","tetrodotoxin")
			else
				// absolutely everything
				potential_reagents = all_functional_reagent_ids

		if (length(potential_reagents) > 0)
			var/looper = rand(2,5)
			while (looper > 0)
				var/reagent = pick(potential_reagents)
				if(payload_type == 3) // do not pick stuff that is banned from fluid dump
					var/datum/reagent/cached = reagents_cache[reagent]
					if (cached.fluid_flags & FLUID_BANNED)
						continue
				looper--
				payload_reagents += reagent
			log_addendum = "Payload: [payload_type_name], [jointext(payload_reagents, ", ")]"

		recharge_delay = rand(300,800)

	deploy_payload(var/obj/O)
		if (..())
			return

		var/list/reaction_reagents = list()

		for (var/X in payload_reagents)
			reaction_reagents += X

		var/amountper = 0
		if (length(reaction_reagents) > 0)
			amountper = round(O.reagents.maximum_volume / reaction_reagents.len)
		else
			amountper = 20

		for (var/X in reaction_reagents)
			O.reagents.add_reagent(X,amountper)

		var/turf/location = get_turf(O)
		switch(payload_type)
			if(CHEMBOMB_FOAMY)
				var/datum/effects/system/foam_spread/s = new()
				s.set_up(O.reagents.total_volume, location, O.reagents, 0)
				s.start()
			if(CHEMBOMB_SMOKEY)
				// normal smoke
				O.reagents.smoke_start(50)
			if(CHEMBOMB_CLASSICAL_GAS)
				// "classic" smoke
				O.reagents.smoke_start(50,1)
			if(CHEMBOMB_FLUIDY)
				location.fluid_react(O.reagents, O.reagents.total_volume)
				var/datum/fluid_group/FG = location.active_liquid?.group
				if(FG)
					FG.base_evaporation_time = 30 SECONDS
					FG.bonus_evaporation_time = 0 SECONDS

		if(QDELETED(O))
			return
		O.reagents.clear_reagents()

		SPAWN(recharge_delay)
			if (O)
				O.ArtifactDeactivated()

// undef chembomb payload_type types
#undef CHEMBOMB_FOAMY
#undef CHEMBOMB_SMOKEY
#undef CHEMBOMB_CLASSICAL_GAS
#undef CHEMBOMB_FLUIDY

// matter transmutation bomb

#define NO_EFFECT 0
#define MAKE_HUMAN_MATERIAL 1
#define MAKE_HUMAN_STATUE 2

/obj/machinery/artifact/bomb/transmute
	name = "artifact matter transmutation bomb"
	associated_datum = /datum/artifact/bomb/transmute

	ArtifactHitWith(obj/item/O, mob/user)
		if(..())
			return
		var/datum/artifact/bomb/transmute/A = src.artifact
		O.setMaterial(A.mat)
		boutput(user, "\The [O] turn\s into [A.mat.getName()]!")

/datum/artifact/bomb/transmute
	associated_object = /obj/machinery/artifact/bomb/transmute
	type_name = "Bomb (material transmutation)"
	validtypes = list("wizard","eldritch","martian","ancient","precursor")
	fault_blacklist = list(ITEM_ONLY_FAULTS, TOUCH_ONLY_FAULTS)
	rarity_weight = 90
	react_xray = list(17,95,95,3,"ANOMALOUS")
	warning_initial = ""
	warning_final = ""
	alarm_initial = null
	alarm_during = null
	alarm_final = 'sound/effects/glitchy1.ogg'
	var/material = "gold"
	var/datum/material/mat = null
	var/affects_organic = 0 // 1 means material human, 2 means material statue
	var/range = 7
	var/smoothEdge = 0 // with this, the area will be perfectly circular

	post_setup()
		..()
		affects_organic = pick(
			prob(5); NO_EFFECT,
			prob(2); MAKE_HUMAN_MATERIAL,
			prob(2); MAKE_HUMAN_STATUE)
		smoothEdge = prob(50)

		explode_delay = rand(30 SECONDS, 2 MINUTES)
		switch(artitype.name)
			if("wizard") // magical stuff
				material = pick(
					100;"gold",
					100;"syreline",
					100;"silver",
					100;"cobryl",
					50;"miracle",
					50;"hauntium",
					50;"ectoplasm",
					10;"ectofibre",
					10;"wiz_quartz",
					10;"wiz_topaz",
					10;"wiz_ruby",
					10;"wiz_amethyst",
					10;"wiz_emerald",
					10;"wiz_sapphire",
					5;"jean",
					10;"starstone")
			if("eldritch") // fuck you
				material = pick(
					100;"koshmarite",
					100;"plasmastone",
					100;"telecrystal",
					50;"erebite")
			if("martian") // organic stuff
				material = pick(
					100;"flesh",
					100;"viscerite",
					100;"leather",
					100;"cotton",
					100;"coral",
					50;"spidersilk",
					50;"beewool",
					50;"beeswax",
					50;"chitin",
					50;"bamboo",
					50;"wood",
					50;"bone",
					20;"blob",
					20;"pizza",
					5;"jean",
					20;"butt")
			if("ancient") // industrial type stuff
				material = pick(
					100;"electrum",
					100;"steel",
					100;"mauxite",
					100;"copper",
					100;"pharosium",
					100;"glass",
					100;"char",
					100;"molitz",
					50;"molitz_b",
					50;"bohrum",
					50;"cerenkite",
					50;"plasmasteel",
					50;"claretine",
					50;"plasmaglass",
					50;"uqill",
					50;"latex",
					50;"synthrubber",
					50;"synthblubber",
					50;"synthleather",
					50;"fibrilith",
					30;"carbonfibre",
					30;"diamond",
					30;"dyneema",
					20;"iridiumalloy",
					20;"neutronium")
			if("precursor") // uh, the rest
				material = pick(
					100;"rock",
					100;"slag",
					100;"ice",  // no possible way this ends poorly
					15;"spacelag",
					15;"cardboard",
					15;"frozenfart",
					15;"negativematter")

		mat = getMaterial(material)

		warning_initial = "appears to be turning into [mat.getName()]."
		warning_final = "begins transmuting nearby matter into [mat.getName()]!"
		log_addendum = "Material: [mat.getName()]"

		var/matR = GetRedPart(mat.getColor())
		var/matG = GetGreenPart(mat.getColor())
		var/matB = GetBluePart(mat.getColor())
		lightColor = list(matR, matG, matB, 255)

		range = rand(3,7)

	onVarChanged(variable, oldval, newval)
		. = ..()
		if(variable == "material")
			mat = getMaterial(material)
		if(variable == "mat" || variable == "material")
			warning_initial = "appears to be turning into [mat.getName()]."
			warning_final = "begins transmuting nearby matter into [mat.getName()]!"
			log_addendum = "Material: [mat.getName()]"

			var/matR = GetRedPart(mat.getColor())
			var/matG = GetGreenPart(mat.getColor())
			var/matB = GetBluePart(mat.getColor())
			lightColor = list(matR, matG, matB, 255)

	effect_activate(obj/O)
		if(..())
			return
		O.setMaterial(mat)

	deploy_payload(var/obj/O)
		if (..())
			return
		var/base_offset = rand(1000)
		O.add_filter("rays", 1, rays_filter(size=0, density=20, factor=1, offset=base_offset, threshold=0, color=mat.getColor()))
		animate(O.get_filter("rays"), size=16*range, time=0.5 SECONDS, offset=base_offset+50)
		animate(size=32*range, time=0.5 SECONDS, offset=base_offset+50, alpha=0)
		playsound(O.loc, 'sound/weapons/conc_grenade.ogg', 90, 1)

		SPAWN(1 SECOND)
			var/range_squared = range**2
			var/turf/T = get_turf(O)
			for(var/atom/G in range(range, T))
				if(istype(G, /obj/overlay) || istype(G, /obj/effects) || istype(G, /turf/space) || istype(G, /obj/fluid) || istype(G, /obj/particle))
					continue
				var/dist = GET_SQUARED_EUCLIDEAN_DIST(O, G)
				var/distPercent = (dist/range_squared)*100
				if(dist > range_squared)
					continue
				if(!smoothEdge && prob(distPercent))
					continue
				if(istype(G, /mob))
					if(!isliving(G) || isintangible(G)) // not stuff like ghosts, please
						continue
					var/mob/M = G
					switch(affects_organic)
						if(MAKE_HUMAN_MATERIAL)
							M.setMaterial(mat)
							for(var/atom/I in M.get_all_items_on_mob())
								I.setMaterial(mat)
							O.ArtifactFaultUsed(M)
						if(MAKE_HUMAN_STATUE)
							if(distPercent < 40) // only inner 40% of range
								O.ArtifactFaultUsed(M)
								if(M)
									M.become_statue(mat.getID())
				else
					G.setMaterial(mat)

			if(O)
				O.ArtifactDestroyed()


#undef NO_EFFECT
#undef MAKE_HUMAN_MATERIAL
#undef MAKE_HUMAN_STATUE
