/datum/antagonist/revolutionary
	id = ROLE_REVOLUTIONARY
	display_name = "revolutionary"
	display_at_round_end = FALSE

	New()
		. = ..()

		if (ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution))
			var/datum/game_mode/revolution/gamemode = ticker.mode
			if (!(src.owner in gamemode.revolutionaries))
				gamemode.revolutionaries += src.owner
			gamemode.update_rev_icons_added(src.owner)
		var/obj/itemspecialeffect/derev/E = new /obj/itemspecialeffect/derev
		E.color = "#FF5555"
		E.setup(src.owner.current.loc)

	disposing()
		if (ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution))
			var/datum/game_mode/revolution/gamemode = ticker.mode
			if (src.owner in gamemode.revolutionaries)
				gamemode.revolutionaries -= src.owner

		var/obj/itemspecialeffect/derev/E = new /obj/itemspecialeffect/derev
		E.color = "#5555FF"
		E.setup(src.owner.current.loc)

		. = ..()

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	announce_objectives()
		return

	announce()
		. = ..()
		src.owner.current.show_text("<h4><font color=red>Kill the Heads of Staff and don't harm your fellow freedom fighters. You can identify your comrades by the R icons (blue = head rev, red = regular member).</font></h4>")

	announce_removal()
		. = ..()
		src.owner.current.visible_message("<span class='notice'><b>[src.owner.current] looks like they just remembered their real allegiance!</b></span>", "<span class='notice'><b>You remember your real allegiance!</b></span>")
		src.owner.current.show_text("<h4><font color=blue>Protect the Heads of Staff and help them kill the leaders of the revolution.</font></h4>", "blue")
		src.owner.current.show_antag_popup("derevved")

	do_popup(override)
		if (!override)
			override = "revved"

		..(override)

	check_success()
		var/list/heads_of_staff = ticker?.mode?.get_living_heads()

		for(var/datum/mind/head_mind in heads_of_staff)
			if(head_mind?.current && !isdead(head_mind.current))
				if(istype(head_mind.current.loc, /obj/cryotron))
					continue

				var/turf/T = get_turf(head_mind.current)
				if(T.z != Z_LEVEL_STATION)
					continue

				return FALSE

		return TRUE
