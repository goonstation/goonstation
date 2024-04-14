/obj/item/device/event_beacon
	name = "Beacon deployer"
	desc = "A remote with a very inviting red button on it, what could it do?"
	icon_state = "event_beacon"
	///The ckey of the admin who spawned this
	var/spawner_key = null
	var/do_popup = TRUE

	New()
		..()
		if (!isadmin(usr)) //how did this happen? no idea, but it's bad
			qdel(src)
			CRASH("Beacon deployer spawned by non-admin user [usr], what")
		src.spawner_key = usr.key

	attack_self(mob/user)
		. = ..()
		boutput(user, SPAN_NOTICE("You press the button on the [src], it mysteriously vanishes in your hands."))
		playsound(src, 'sound/machines/button.ogg', 50)
		message_admins("[key_name(user)] activated \a [src] at [log_loc(src)]")
		var/turf/T = get_turf(src)
		var/client/client = find_player(src.spawner_key)?.client

		var/image/marker = image('icons/effects/64x64.dmi', T, "impact_marker", pixel_x = -16, pixel_y = -16)
		client << marker
		SPAWN(10 SECONDS)
			client.images -= marker
			qdel(marker)

		qdel(src)
		if (do_popup)
			if (client && alert(client, "[user] activated your [src] in [get_area(T)]", "Beacon activated", "Go there", "Close") == "Go there")
				client.mob.set_loc(T)
