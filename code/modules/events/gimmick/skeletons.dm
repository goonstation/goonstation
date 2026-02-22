#ifdef HALLOWEEN
/datum/random_event/minor/skeletons
	weight = 50

#else
/datum/random_event/special/skeletons
#endif

	name = "Closet Skeletons"
	customization_available = 1

	admin_call(var/source)
		if (..())
			return

		var/select = input(usr, "How many skeletons to spawn (1-50)?", "Number of skeletons") as null|num

		select = max(1,select)
		select = min(50,select)

		src.event_effect(source, select)
		return

	event_effect(var/source, var/spawn_amount_selected = 0)
		..()

		var/spawn_amount = rand(7,13)
		if(spawn_amount_selected)
			spawn_amount = spawn_amount_selected

		var/list/closets = list()

		for_by_tcl(S, /obj/storage/closet)
			if(S.loc.z == 1)
				closets += S


		var/sensortext = pick("sensors", "technicians", "probes", "satellites", "monitors")
		var/pickuptext = pick("picked up", "detected", "found", "sighted", "reported")
		var/anomlytext = pick("spooky infestation", "loud clacking noise","rattling of bones")
		var/ohshittext = pick("en route for collision with", "rapidly approaching", "heading towards")
		command_alert("Our [sensortext] have [pickuptext] \a [anomlytext] [ohshittext] the station. Be wary of closets.", "Anomaly Alert", alert_origin = ALERT_ANOMALY)

		SPAWN(1 DECI SECOND)
			for(var/i = 0, i<spawn_amount, i++)
				if(length(closets) > 0)
					var/obj/storage/temp = pick(closets)
					if(temp.open)
						temp.close()
					if(temp.open)
						closets -= temp
						continue
					temp.visible_message(SPAN_ALERT("<b>[temp]</b> emits a loud thump and rattles a bit."))
					playsound(temp, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, TRUE)
					var/wiggle = 6
					while(wiggle > 0)
						wiggle--
						temp.pixel_x = rand(-3,3)
						temp.pixel_y = rand(-3,3)
						sleep(0.1 SECONDS)
					temp.pixel_x = 0
					temp.pixel_y = 0
					new/mob/living/critter/skeleton(temp)
					closets -= temp
				else
					break

