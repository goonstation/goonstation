/////////////////////////////////////// General Announcement Computer

/obj/machinery/computer/announcement
	name = "Announcement Computer"
	icon_state = "comm"
	machine_registry_idx = MACHINES_ANNOUNCEMENTS
	var/last_announcement = 0
	var/announcement_delay = 1200
	var/obj/item/card/id/ID = null
	var/unlocked = 0
	var/announce_status = "Insert Card"
	var/message = ""
	var/inhibit_updates = 0
	var/announces_arrivals = 0
	var/arrival_announcements_enabled = 1
	var/say_language = "english"
	var/arrivalalert = "$NAME has signed up as $JOB."
	var/obj/item/device/radio/intercom/announcement_radio = null
	var/voice_message = "broadcasts"
	var/voice_name = "Announcement Computer"
	var/sound_to_play = "sound/misc/announcement_1.ogg"
	req_access = list(access_heads)
	object_flags = CAN_REPROGRAM_ACCESS

	lr = 0.6
	lg = 1
	lb = 0.1

	New()
		..()
		if (src.announces_arrivals)
			src.announcement_radio = new(src)

	process()
		if (!inhibit_updates) src.updateUsrDialog()

	attack_hand(mob/user)
		if(..()) return
		src.add_dialog(user)
		var/dat = {"
			<body>
				<h1>Announcement Computer</h1>
				<hr>
				Status: [announce_status]<BR>
				Card: <a href='?src=\ref[src];card=1'>[src.ID ? src.ID.name : "--------"]</a><br>
				Broadcast delay: [nice_timer()]<br>
				<br>
				Message: "<a href='?src=\ref[src];edit_message=1'>[src.message ? src.message : "___________"]</a>" <a href='?src=\ref[src];clear_message=1'>(Clear)</a><br>
				<br>
				<b><a href='?src=\ref[src];send_message=1'>Transmit</a></b>
			"}
		if (src.announces_arrivals)
			dat += "<hr>[src.arrival_announcements_enabled ? "Arrival Announcement Message: \"[src.arrivalalert]\"<br><br><b><a href='?src=\ref[src];set_arrival_message=1'>Change</a></b><br><b><a href='?src=\ref[src];toggle_arrival_message=1'>Disable</a></b>" : "Arrival Announcements Disabled<br><br><b><a href='?src=\ref[src];toggle_arrival_message=1'>Enable</a></b>"]"
		dat += "</body>"
		user.Browse(dat, "window=announcementcomputer")
		onclose(user, "announcementcomputer")

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/card/id))
			if (src.ID)
				src.ID.set_loc(src.loc)
				boutput(user, "<span class='notice'>[src.ID] is ejected from the ID scanner.</span>")
			usr.drop_item()
			W.set_loc(src)
			src.ID = W
			src.unlocked = check_access(ID, 1)
			boutput(user, "<span class='notice'>You insert [W].</span>")
			return
		..()

	Topic(href, href_list[])
		if(..()) return

		if(href_list["card"])
			if(src.ID)
				src.ID.set_loc(src.loc)
				usr.put_in_hand_or_eject(src.ID) // try to eject it into the users hand, if we can
				src.ID = null
				src.unlocked = 0
			else
				var/obj/item/I = usr.equipped()
				if (istype(I, /obj/item/card/id))
					usr.drop_item()
					I.set_loc(src)
					src.ID = I
					src.unlocked = check_access(ID, 1)
				else if (istype(I, /obj/item/magtractor))
					var/obj/item/magtractor/mag = I
					if (istype(mag.holding, /obj/item/card/id))
						I = mag.holding
						mag.dropItem(0)
						I.set_loc(src)
						src.ID = I
						src.unlocked = check_access(ID, 1)

		else if(href_list["edit_message"])
			inhibit_updates = 1
			message = copytext( html_decode(trim(strip_html(html_decode(input("Select what you wish to announce.", "Announcement."))))), 1, 280 )
			if(url_regex && url_regex.Find(message)) message = ""
			inhibit_updates = 0
			playsound(src.loc, "keyboard", 50, 1, -15)

		else if (href_list["clear_message"])
			message = ""

		else if (href_list["send_message"])
			send_message(usr)

		else if (href_list["set_arrival_message"])
			inhibit_updates = 1
			src.set_arrival_alert(usr)
			inhibit_updates = 0

		else if (href_list["toggle_arrival_message"])
			src.arrival_announcements_enabled = !(src.arrival_announcements_enabled)
			boutput(usr, "Arrival announcements [src.arrival_announcements_enabled ? "en" : "dis"]abled.")

		update_status()
		src.updateUsrDialog()

	proc/update_status()
		if(!src.ID)
			announce_status = "Insert Card"
		else if(!src.unlocked)
			announce_status = "Insufficient Access"
		else if(!message)
			announce_status = "Input message."
		else if(get_time() > 0)
			announce_status = "Broadcast delay in effect."
		else
			announce_status = "Ready to transmit!"

	proc/send_message(var/mob/user)
		if(!message || !unlocked || get_time() > 0) return
		var/area/A = get_area(src)

		logTheThing("say", user, null, "created a command report: [message]")
		logTheThing("diary", user, null, "created a command report: [message]", "say")

		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			message = process_accents(H, message) //Slurred announcements? YES!

		command_announcement(message, "[A.name] Announcement by [ID.registered] ([ID.assignment])", sound_to_play)
		last_announcement = world.timeofday
		message = ""

	proc/nice_timer()
		if (world.timeofday < last_announcement)
			last_announcement = 0
		var/time = get_time()
		if(time < 0)
			return "--:--"
		else
			var/seconds = text2num(time) % 60 //ZeWaka: Should fix type mismatches.
			var/flick_seperator = (seconds % 2 == 0) // why was this being calculated after converting BACK into a string?!!! - cirr
			// VARIABLES SHOULDN'T CHANGE TYPE FROM STRING TO NUMBER TO STRING LIKE THIS IN LIKE SIX LINES AAGGHHHHH FUCK YOU DYNAMIC TYPING
			var/minutes = round(text2num((time - seconds) / 60))
			minutes = minutes < 10 ? "0[minutes]" : "[minutes]"
			seconds = seconds < 10 ? "0[seconds]" : "[seconds]"

			return "[minutes][flick_seperator ? ":" : " "][seconds]"

	proc/get_time()
		return max(((last_announcement + announcement_delay) - world.timeofday ) / 10, 0)

	proc/set_arrival_alert(var/mob/user)
		if (!user)
			return
		var/newalert = input(user,"Please enter a new arrival alert message. Valid tokens: $NAME, $JOB, $STATION", "Custom Arrival Alert", src.arrivalalert) as null|text
		if (!newalert)
			return
		if (!findtext(newalert, "$NAME"))
			user.show_text("The alert needs at least one $NAME token.", "red")
			return
		if (!findtext(newalert, "$JOB"))
			user.show_text("The alert needs at least one $JOB token.", "red")
			return
		src.arrivalalert = sanitize(adminscrub(newalert, 200))
		logTheThing("station", user, src, "sets the arrival announcement on [constructTarget(src,"station")] to \"[src.arrivalalert]\"")
		user.show_text("Arrival alert set to '[newalert]'", "blue")
		playsound(src.loc, "keyboard", 50, 1, -15)
		return

	proc/say_quote(var/text)
		return "[src.voice_message], \"[text]\""

	proc/process_language(var/message)
		var/datum/language/L = languages.language_cache[src.say_language]
		if (!L)
			L = languages.language_cache["english"]
		return L.get_messages(message)

	proc/announce_arrival(var/name, var/rank)
		if (!src.announces_arrivals)
			return 1
		if (!src.announcement_radio)
			src.announcement_radio = new(src)

		var/message = replacetext(replacetext(replacetext(src.arrivalalert, "$STATION", "[station_name()]"), "$JOB", rank), "$NAME", name)

		var/list/messages = process_language(message)
		src.announcement_radio.talk_into(src, messages, 0, src.name, src.say_language)
		logTheThing("station", src, null, "ANNOUNCES: [message]")
		return 1

/obj/machinery/computer/announcement/console_upper
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "announcement1"
/obj/machinery/computer/announcement/console_lower
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "announcement2"

/obj/machinery/computer/announcement/syndie
		icon_state = "syndiepc14"
		icon = 'icons/obj/decoration.dmi'
		req_access = null
		name = "Syndicate Announcement computer"
		voice_name = "Syndicate Announcement Computer"
