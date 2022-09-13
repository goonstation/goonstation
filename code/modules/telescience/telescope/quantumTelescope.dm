/*
TODO: Enforce ping rate limit here as well in case someone futzes with the javascript.
*/

/obj/machinery/computer/telescope
	name = "quantum telescope"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer_generic"
	circuit_type = /obj/item/circuitboard/telescope

	var/mob/using = null

	var/tracking_id = "" //id of the event we're tracking/targeting.

	New()
		processing_items.Add(src)
		..()

	process()
		..()
		if(using != null)
			rebuildEventList(using)

	proc/boot_if_away()
		if(using && (!using.client || using.client.inactivity >= 600 || !in_interact_range(src, using)))
			using.Browse(null, "window=qtelescope;override_setting=1")
			using = null
		return

	attack_hand(mob/user)
		if(status & (BROKEN|NOPOWER))
			return

		boot_if_away()

		if(using && using != user)
			boutput(user, "<span class='alert'>Somebody is already using that machine.</span>")
			return

		using = user
		src.add_dialog(user)
		add_fingerprint(user)

		user.Browse(grabResource("html/telescope.html"), "window=qtelescope;size=974x560;title=Quantum Telescope;can_resize=0", 1)

		onclose(user, "telescope", src)

		SPAWN(1 SECOND)
			callJsFunc(user, "setRef", list("\ref[src]")) //This is shit but without it, it calls the JS before the window is open and doesn't work. (Is this still true?!?!)
			rebuildEventList(user)
			callJsFunc(using, "showFooterMsg", list("Left-Click: Ping , Right-Click: Clear map"))
		return

	proc/rebuildEventList(var/user)
		callJsFunc(user, "setRef", list("\ref[src]"))
		callJsFunc(user, "clearEvents", "")
		sendEventList(user)
		callJsFunc(user, "rebuildEventList", "")
		return

	//function addEvent(name, type, discovered, tracking, ref)
	proc/sendEventList(var/user)
		if(tele_man)
			for(var/A in tele_man.events_active)
				var/datum/telescope_event/E = tele_man.events_active[A]
				if(E.disabled) continue
				callJsFunc(user, "addEvent", list(E.name_undiscovered, E.tags, 0, (E.id == tracking_id ? 1:0), E.id))

			for(var/A in tele_man.events_found)
				var/datum/telescope_event/E = tele_man.events_found[A]
				if(E.disabled) continue
				callJsFunc(user, "addEvent", list(E.name, E.tags, 1, 0, E.id))
		return

	Topic(href, href_list)

		boot_if_away()

		if(href_list["close"])
			using = null

		else if(href_list["jscall"] && using)
			switch(href_list["jscall"])
				if("track")
					var/id = href_list["id"]
					for(var/A in tele_man.events_active)
						var/datum/telescope_event/E = tele_man.events_active[A]
						if(E.id == id)
							if(E.disabled)
								return
							tracking_id = id
							callJsFunc(using, "showFooterMsg", list("Now tracking: " + E.name_undiscovered))
							rebuildEventList(using)
							break

				if("activate")
					var/id = href_list["id"]
					for(var/A in tele_man.events_found)
						var/datum/telescope_event/E = tele_man.events_found[A]
						if(E.id == id)
							if(E.telescopeDialogue)
								E.onContact(src)
								E.telescopeDialogue.showDialogue(using)
							else
								E.onContact(src)
							break

				if("ping")
					var/vX = text2num_safe(href_list["x"])
					var/vY = text2num_safe(href_list["y"])
					for(var/A in tele_man.events_active)
						var/datum/telescope_event/E = tele_man.events_active[A]
						if(E.id == tracking_id)
							if(E.disabled)
								tracking_id = ""
								return
							var/distx = abs(vX - E.loc_x)
							var/disty = abs(vY - E.loc_y)
							var/dist = (distx * distx + disty * disty) ** 0.5
							if (dist <= E.size)
								using.playsound_local(src.loc, 'sound/machines/found.ogg', 50, 1)
								E.onDiscover(src)
								tele_man.events_active.Remove(tracking_id)
								tele_man.events_found.Add(tracking_id)
								tele_man.events_found[tracking_id] = E
								tracking_id = ""
								rebuildEventList(using)
								callJsFunc(using, "byondFound", list(E.loc_x, E.loc_y, E.size, E.id))
							else
								using.playsound_local(src.loc, 'sound/machines/sweep.ogg', 50, 1)
								//callJsFunc(using, "showFooterMsg", list("dist [(distx + disty)]"))
								rebuildEventList(using)

								// Actual size of circle to show; 100% to 120% of actual radius
								var/ping_radius = (dist + E.size) * rand(100, 120) / 100
								callJsFunc(using, "byondAddMark", list(vX, vY, ping_radius))
							break
		return


	proc/callJsFunc(var/client, var/funcName, var/list/params)
		var/paramsJS = list2params(params)
		client << output(paramsJS,"qtelescope.browser:[funcName]")
		return
