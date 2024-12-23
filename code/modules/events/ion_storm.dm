/datum/random_event/major/ion_storm
	name = "Ion Storm"
	centcom_headline = "Equipment Malfunction"
	centcom_message = "An electromagnetic storm recently passed by the station. Sensitive electrical equipment may require maintenance."
	centcom_origin = ALERT_WEATHER
	message_delay = 5 MINUTES
	/// The fraction of message_delay taken up by each stage of the ion storm
	var/stage_delay
	var/list/datum/ion_category/categories

	New()
		..()
		build_categories()
		stage_delay = 1 / length(categories)

	event_effect(var/source)
		..()

		//Robots get all hallucinatey
		for (var/mob/living/L in global.mobs)
			if (issilicon(L) || isAIeye(L))
				if (prob(33))
					var/timeout_seconds = rand(60,120) //1 to 2 minutes
					switch (rand(1,5))
						if(1) //lsd-like
							var/datum/reagent/drug/LSD/drug_type = /datum/reagent/drug/LSD //it's a path so we can grab the static vars, and not do init
							logTheThing(LOG_DIARY, null, "[L] gets [drug_type] like effect applied by ion storm")
							L.AddComponent(/datum/component/hallucination/trippy_colors, timeout=timeout_seconds)
							if(prob(60)) //monkey mode
								L.AddComponent(/datum/component/hallucination/fake_attack, timeout=timeout_seconds, image_list=drug_type.monkey_images, name_list=drug_type.monkey_names, attacker_prob=20, max_attackers=3)
							else
								L.AddComponent(/datum/component/hallucination/fake_attack, timeout=timeout_seconds, image_list=null, name_list=null, attacker_prob=20, max_attackers=3)
							L.AddComponent(/datum/component/hallucination/random_sound, timeout=timeout_seconds, sound_list=drug_type.halluc_sounds, sound_prob=5)
							L.AddComponent(/datum/component/hallucination/random_image_override, timeout=timeout_seconds, image_list=drug_type.critter_image_list, target_list=list(/mob/living/carbon/human), range=6, image_prob=10, image_time=20, override=TRUE)
						if(2) //lsbee
							var/datum/reagent/drug/lsd_bee/drug_type = /datum/reagent/drug/lsd_bee //it's a path so we can grab the static vars, and not do init
							logTheThing(LOG_DIARY, null, "[L] gets [drug_type] like effect applied by ion storm")
							var/bee_halluc = drug_type.bee_halluc
							var/image/imagekey = pick(bee_halluc)
							L.AddComponent(/datum/component/hallucination/fake_attack, timeout=timeout_seconds, image_list=list(imagekey), name_list=bee_halluc[imagekey], attacker_prob=10)
						if(3)
							var/datum/reagent/drug/catdrugs/drug_type = /datum/reagent/drug/catdrugs //it's a path so we can grab the static vars, and not do init
							logTheThing(LOG_DIARY, null, "[L] gets [drug_type] like effect applied by ion storm")
							var/cat_halluc = drug_type.cat_halluc
							var/image/imagekey = pick(cat_halluc)
							L.AddComponent(/datum/component/hallucination/fake_attack, timeout=timeout_seconds, image_list=list(imagekey), name_list=cat_halluc[imagekey], attacker_prob=7, max_attackers=3)
							L.AddComponent(/datum/component/hallucination/random_sound, timeout=timeout_seconds, sound_list=drug_type.cat_sounds, sound_prob=20)
						if(4) //hellshroom
							logTheThing(LOG_DIARY, null, "[L] gets hellshroom like effect applied by ion storm")
							var/bats = rand(2,3)
							L.AddComponent(/datum/component/hallucination/fake_attack, timeout=timeout_seconds, image_list=list(new /image('icons/misc/AzungarAdventure.dmi', "hellbat")), name_list=list("hellbat"), attacker_prob=100, max_attackers=bats)
							boutput(L, SPAN_ALERT("<b>A hellbat begins to chase you</b>!"))
							L.emote("scream")
						if(5) //mimicotoxin
							logTheThing(LOG_DIARY, null, "[L] gets mimicotoxin like effect applied by ion storm")
							L.AddComponent(/datum/component/hallucination/random_image_override, timeout=timeout_seconds, image_list=list(image('icons/misc/critter.dmi',"mimicface")), target_list=list(/obj/item, /mob/living), range=5, image_prob=2, image_time=10, override=FALSE)



		SPAWN(message_delay * stage_delay)

			// Fuck up some categories
			for (var/datum/ion_category/category as anything in categories)
				if(prob(category.prob_of_happening))
					category.fuck_up()
				sleep(message_delay * stage_delay)

	proc/build_categories()
		categories = list()
		for (var/category in childrentypesof(/datum/ion_category))
			categories += new category


ABSTRACT_TYPE(/datum/ion_category)
/datum/ion_category
	/// Minimum number of Things this affects
	var/amount_min
	/// Maximum number of Things this effects
	var/amount_max
	var/prob_of_happening = 80
	var/interdict_cost = 100 //how much energy an interdictor needs to invest to keep this from malfunctioning
	var/list/atom/targets = list()

	proc/valid_instance(var/atom/found)
		var/turf/T = get_turf(found)
		if (!T)
			return FALSE
		if (T.z != Z_LEVEL_STATION)
			return FALSE
		if (!istype(T.loc,/area/station/))
			return FALSE
		return TRUE

	proc/build_targets()

	proc/action(var/atom/object)

	proc/fuck_up()
		if (!length(targets))
			build_targets()
		if (!length(targets))
			return
		var/amount = rand(amount_min, amount_max)
		for (var/i in 1 to amount)
			var/atom/object = pick(targets)

			//spatial interdictor: shield general hardware from ionic interference. law racks explicitly omitted due to sensitivity (and gameplay fun)
			//consumes cell charge per hardware item protected, based on the category's interdict cost
			var/interdicted = FALSE
			for_by_tcl(IX, /obj/machinery/interdictor)
				if (IX.expend_interdict(interdict_cost,object))
					interdicted = TRUE
					SPAWN(rand(1,8))
						playsound(object.loc, "sparks", 60, 1) //absorption noise, as a little bit of "force feedback"
					break
			if(interdicted)
				continue

			//we don't try again if it is null, because it's possible there just are none
			if (!isnull(object))
				action(object)

/datum/ion_category/APCs
	amount_min = 10
	amount_max = 25
	interdict_cost = 500

	build_targets()
		for (var/obj/machinery/power/apc/apc in machine_registry[MACHINES_POWER])
			if (valid_instance(apc))
				targets += apc

	action(var/obj/machinery/power/apc/apc)
		var/apc_diceroll = rand(1,4)
		switch(apc_diceroll)
			if (1)
				apc.lighting = 0
			if (2)
				apc.equipment = 0
			if (3)
				apc.environ = 0
			if (4)
				apc.environ = 0
				apc.equipment = 0
				apc.lighting = 0
		logTheThing(LOG_STATION, null, "Ion storm interfered with [apc.name] at [log_loc(apc)]")
		apc.aidisabled = TRUE
		apc.update()
		apc.UpdateIcon()

/datum/ion_category/doors
	amount_min = 20
	amount_max = 50

	valid_instance(var/obj/machinery/door/airlock/door)
		return ..() && !door.cant_emag

	build_targets()
		for_by_tcl(door, /obj/machinery/door/airlock)
			if (valid_instance(door))
				targets += door

	action(var/obj/machinery/door/airlock/door)
		var/door_diceroll = !door.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS) ? rand(1,6) : rand(1, 3)
		var/safe = door.safety
		switch(door_diceroll)
			if(1)
				door.secondsElectrified = -1
				logTheThing(LOG_STATION, null, "Ion storm permanantly electrified an airlock ([door.name]) at [log_loc(door)]")
				door.aiControlDisabled = TRUE

			if(2)
				var/shock_dur = rand(20, 120)
				var/disabled_old = door.aiControlDisabled
				door.secondsElectrified = shock_dur
				logTheThing(LOG_STATION, null, "Ion storm electrified an airlock ([door.name]) at [log_loc(door)] for [shock_dur] seconds")
				door.aiControlDisabled = TRUE
				SPAWN(shock_dur SECONDS)
					door.aiControlDisabled = disabled_old

			if(3)
				door.aiDisabledIdScanner = TRUE

			if(4)
				if (door.density)
					door.open()
					logTheThing(LOG_STATION, null, "Ion storm opened an airlock ([door.name]) at [log_loc(door)]")
				else
					door.safety = 0
					door.close()
					door.safety = safe
					logTheThing(LOG_STATION, null, "Ion storm closed an airlock ([door.name]) at [log_loc(door)]")

			if(5)
				if (!door.locked)
					door.set_locked()
					logTheThing(LOG_STATION, null, "Ion storm locked an airlock ([door.name]) at [log_loc(door)]")
					door.aiControlDisabled = TRUE
				else
					door.set_unlocked()
					logTheThing(LOG_STATION, null, "Ion storm unlocked an airlock ([door.name]) at [log_loc(door)]")

			if(6)
				if(door.locked)
					door.set_unlocked()

				if (door.density)
					door.open()
					logTheThing(LOG_STATION, null, "Ion storm bolted an airlock open ([door.name]) at [log_loc(door)]")
				else
					door.safety = 0
					door.close()
					door.safety = safe
					logTheThing(LOG_STATION, null, "Ion storm bolted an airlock closed ([door.name]) at [log_loc(door)]")

				if (!door.locked)
					door.set_locked()
					door.aiControlDisabled = TRUE

/datum/ion_category/lights
	amount_min = 30
	amount_max = 70

	valid_instance(var/obj/machinery/light/light)
		return ..() && light.removable_bulb

	build_targets()
		for (var/light as anything in stationLights)
			if (valid_instance(light))
				targets += light

	action(var/obj/machinery/light/light)
		var/light_diceroll = rand(1,3)
		switch(light_diceroll)
			if(1)
				light.broken()
				logTheThing(LOG_STATION, null, "Ion storm overloaded lighting at [log_loc(light)]")
			if(2)
				light.light.set_color(rand(1,100) / 100, rand(1,100) / 100, rand(1,100) / 100)
				light.brightness = rand(4,32) / 10
			if(3)
				light.on = 0
				logTheThing(LOG_STATION, null, "Ion storm turned off the lighting at [log_loc(light)]")

		light.update()

/datum/ion_category/manufacturers
	amount_min = 4
	amount_max = 8
	interdict_cost = 200

	build_targets()
		for_by_tcl(man, /obj/machinery/manufacturer)
			if (valid_instance(man))
				targets += man

	action(var/obj/machinery/manufacturer/manufacturer)
		manufacturer.pulse(pick(list(1,2,3,4)))
		logTheThing(LOG_STATION, null, "Ion storm interfered with [manufacturer.name] at [log_loc(manufacturer)]")

/datum/ion_category/venders
	amount_min = 4
	amount_max = 8
	interdict_cost = 250

	build_targets()
		for_by_tcl(vender, /obj/machinery/vending)
			if (valid_instance(vender))
				targets += vender

	action(var/obj/machinery/vending/vender)
		vender.pulse(pick(list(1,2,3,4)))
		logTheThing(LOG_STATION, null, "Ion storm interfered with [vender.name] at [log_loc(vender)]")

/datum/ion_category/fire_alarms
	amount_min = 3
	amount_max = 6

	build_targets()
		for(var/obj/machinery/firealarm/alarm as anything in machine_registry[MACHINES_FIREALARMS])
			if (valid_instance(alarm))
				targets += alarm

	action(var/obj/machinery/firealarm/alarm)
		alarm.alarm()

/datum/ion_category/pda_alerts
	amount_min = 1
	amount_max = 2

	valid_instance(var/obj/item/device/pda2/pda)
		return ..() && pda.owner

	build_targets()
		for_by_tcl(pda, /obj/item/device/pda2)
			if (valid_instance(pda))
				targets += pda

	action(var/obj/item/device/pda2/pda)
		for (var/datum/computer/file/pda_program/prog in pda.hd.root.contents)
			if (istype(prog, /datum/computer/file/pda_program/emergency_alert))
				pda.run_program(prog)
				var/datum/computer/file/pda_program/emergency_alert/alert_prog = prog
				alert_prog.send_alert(rand(1,4), TRUE)

/datum/ion_category/station_bots
	amount_min = 1
	amount_max = 4
	prob_of_happening = 20

	valid_instance(obj/machinery/bot/bot)
		. = ..() && !bot.emagged && (!istype(bot, /obj/machinery/bot/guardbot) && !istype(bot, /obj/machinery/bot/secbot) || prob(50))

	build_targets()
		for_by_tcl(bot, /obj/machinery/bot)
			if(valid_instance(bot))
				targets += bot

	action(obj/machinery/bot/bot)
		bot.emp_act()

/datum/ion_category/cameras
	amount_min = 2
	amount_max = 5

	valid_instance(obj/machinery/camera/camera)
		. = ..() && camera.type == /obj/machinery/camera && camera.network == "SS13" && get_z(camera) == Z_LEVEL_STATION

	build_targets()
		for_by_tcl(camera, /obj/machinery/camera)
			if (valid_instance(camera))
				targets += camera

	action(obj/machinery/camera/camera)
		camera.break_camera()

/datum/ion_category/flock_speak //hehehe
	amount_max = 7
	amount_min = 3

	fuck_up()
		SPAWN(0)
			for (var/i in 1 to rand(src.amount_min, src.amount_max))
				var/siliconrendered = "<span class='flocksay sentient'>[SPAN_BOLD("\[?????\] ")]<span class='name'>[radioGarbleText(get_default_flock().name, FLOCK_RADIO_GARBLE_CHANCE)]</span> [SPAN_MESSAGE("[radioGarbleText(phrase_log.random_phrase("radio"), FLOCK_RADIO_GARBLE_CHANCE)]")]</span>"
				for (var/client/client in global.clients)
					if(client.mob.robot_talk_understand || istype(client.mob, /mob/living/intangible/aieye))
						boutput(client, siliconrendered)
				sleep(rand(2 SECONDS, 30 SECONDS))
