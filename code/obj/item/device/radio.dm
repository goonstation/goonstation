/obj/item/device/radio
	name = "station bounced radio"
	desc = "A portable, non-wearable radio for communicating over a specified frequency. Has a microphone and a speaker which can be independently toggled."
	suffix = "\[3\]"
	icon_state = "walkietalkie"
	item_state = "radio"
	var/device_color = null
	var/chat_class = RADIOCL_STANDARD // respects dark mode, gets overriden by device_color
	var/last_transmission
	var/frequency = R_FREQ_DEFAULT
	var/locked_frequency = 0 // can't change the frequency from default: enables radios to be outside the default range as well
	var/list/secure_frequencies = null
	var/list/secure_colors = list()
	var/list/secure_classes = list(RADIOCL_STANDARD) // respects dark mode, gets overriden by secure_colors
	var/protected_radio = 0 // Cannot be picked up by radio_brain bioeffect.
	var/traitor_frequency = 0.0
	var/obj/item/device/radio/patch_link = null
	var/obj/item/uplink/integrated/radio/traitorradio = null
	var/wires = WIRE_SIGNAL | WIRE_RECEIVE | WIRE_TRANSMIT
	var/b_stat = 0.0
	var/broadcasting = null
	var/listening = 1.0
	var/list/secure_connections = null
	var/datum/radio_frequency/radio_connection
	var/speaker_range = 2
	var/static/image/speech_bubble = image('icons/mob/mob.dmi', "speech")
	flags = FPRINT | TABLEPASS | ONBELT | CONDUCT
	throw_speed = 2
	throw_range = 9
	w_class = 2.0
	mats = 3

	var/icon_override = 0

	var/const
		WIRE_SIGNAL = 1 //sends a signal, like to set off a bomb or electrocute someone
		WIRE_RECEIVE = 2
		WIRE_TRANSMIT = 4
		TRANSMISSION_DELAY = 5 // only 2/second/radio
		WINDOW_OPTIONS = "window=radio;size=280x350"


	// Moved initializaiton to world/New
var/list/headset_channel_lookup

/obj/item/device/radio/New()
	..()
	if(radio_controller)
		initialize()

/obj/item/device/radio/initialize()
	if ((src.frequency < R_FREQ_MINIMUM || src.frequency > R_FREQ_MAXIMUM) && !src.locked_frequency)
		// if the frequency is somehow set outside of the normal range, put it back in range
		world.log << "[src] ([src.type]) has a frequency of [src.frequency], sanitizing."
		src.frequency = sanitize_frequency(src.frequency)

	set_frequency(frequency)
	if(src.secure_frequencies)
		set_secure_frequencies()

/obj/item/device/radio/disposing()
	radio_controller.remove_object(src, "[frequency]")

	if(istype(src.secure_frequencies))
		for (var/sayToken in src.secure_frequencies)
			var/frequency_id = src.secure_frequencies["[sayToken]"]
			if (frequency_id)
				radio_controller.remove_object(src, "[frequency_id]")

	src.secure_connections = null
	src.secure_frequencies = null

	..()

/obj/item/device/radio/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, "[frequency]")
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, "[frequency]")

/obj/item/device/radio/proc/set_secure_frequencies()
	if(istype(src.secure_frequencies))
		for (var/sayToken in src.secure_frequencies)
			var/frequency_id = src.secure_frequencies["[sayToken]"]
			if (frequency_id)
				if (!istype(src.secure_connections))
					src.secure_connections = list()
				src.secure_connections["[sayToken]"] = radio_controller.add_object(src, "[frequency_id]")
			else
				src.secure_frequencies -= "[sayToken]"

/obj/item/device/radio/proc/set_secure_frequency(frequencyToken, newFrequency)
	if (!frequencyToken || !newFrequency)
		return

	if(!istype(src.secure_frequencies))
		secure_frequencies = list()

	if(!istype(src.secure_connections))
		secure_connections = list()

	var/oldFrequency = src.secure_frequencies["[frequencyToken]"]
	if (oldFrequency)
		radio_controller.remove_object(src, "[oldFrequency]")

	src.secure_connections["[frequencyToken]"] = radio_controller.add_object(src, "[newFrequency]")
	src.secure_frequencies["[frequencyToken]"] = newFrequency
	return

/obj/item/device/radio/attack_self(mob/user as mob)
	src.add_dialog(user)

	var/dat = {"
Microphone: [src.broadcasting ? "<a href='?src=\ref[src];talk=0'>Engaged</a>" : "<a href='?src=\ref[src];talk=1'>Disengaged</a>"]
<br>Speaker: [src.listening ? "<a href='?src=\ref[src];listen=0'>Engaged</a>" : "<a href='?src=\ref[src];listen=1'>Disengaged</a>"]
<br>Frequency:
[!src.locked_frequency ? "<a href='?src=\ref[src];freq=-10'>-</a> <a href='?src=\ref[src];freq=-2'>-</a> <a href='?src=\ref[src];freq=set'><strong>[format_frequency(src.frequency)]</strong></a> <a href='?src=\ref[src];freq=2'>+</a> <a href='?src=\ref[src];freq=10'>+</a>" : "</strong>[format_frequency(src.frequency)]</strong>"]
"}

	if (istype(src.secure_frequencies) && src.secure_frequencies.len)
		dat += "<hr>Supplementary Channels:<table style='border-collapse: collapse;' cellpadding='2'><tr><th>Channel</th><th>Freq</th><th>Prefix</th></tr>"
		for (var/sayToken in src.secure_frequencies)
			dat += {"<tr><td>[ headset_channel_lookup["[src.secure_frequencies["[sayToken]"]]"] ? headset_channel_lookup["[src.secure_frequencies["[sayToken]"]]"] : "???" ]</td><td> <strong>[format_frequency(src.secure_frequencies["[sayToken]"])]</strong></td><td><code>[sayToken]</code></td></tr>
"}

		dat += "</table>"

	if (src.b_stat)
		dat += {"
<hr>
Green Wire: <a href='?src=\ref[src];wires=[WIRE_TRANSMIT]'>[src.wires & WIRE_TRANSMIT ? "Cut" : "Mend"] Wire</a>
<br>Red Wire: <a href='?src=\ref[src];wires=[WIRE_RECEIVE]'>[src.wires & WIRE_RECEIVE ? "Cut" : "Mend"] Wire</a>
<br>Blue Wire: <a href='?src=\ref[src];wires=[WIRE_SIGNAL]'>[src.wires & WIRE_SIGNAL ? "Cut" : "Mend"] Wire</a>
"}

	user.Browse(dat, WINDOW_OPTIONS)
	onclose(user, "radio")
	return

/obj/item/device/radio/Topic(href, href_list)
	//..()
	if (usr.stat)
		return

	// Band-aid fix for intercoms, RE 'bounds_dist' check in the 'in_range' proc. Feel free to improve the implementation (Convair880).
	var/special_cases =((istype(src, /obj/item/device/radio/intercom) && (get_dist(src, usr) <= 1) && (istype(src.loc, /turf))) || (istype(src, /obj/item/device/radio/spy) && (get_dist(src, usr) <= 1)))
	if ((issilicon(usr) || isAI(usr)) || (src in usr) || (special_cases) || (usr.loc == src.loc))
		src.add_dialog(usr)

		if (href_list["track"])
			// wait is tracking here? really? what? ???? ????????????
			//var/mob/target = locate(href_list["track"])
			var/mob/living/silicon/A = locate(href_list["track2"])
			var/heard_name = href_list["track3"]
			A.ai_name_track(heard_name)
			return

		if (href_list["freq"])
			var/new_frequency = null

			if (href_list["freq"] == "set")
				new_frequency = input(usr, "New frequency ([R_FREQ_MINIMUM] - [R_FREQ_MAXIMUM]):", "Enter new frequency", frequency) as null|num
				if (!new_frequency)
					return
			else
				new_frequency = frequency + text2num(href_list["freq"])

			set_frequency(sanitize_frequency(new_frequency))

			if (!isnull(src.traitorradio) && src.traitor_frequency && src.frequency == src.traitor_frequency)
				src.remove_dialog(usr)
				usr.Browse(null, WINDOW_OPTIONS)
				onclose(usr, "radio")
				// now transform the regular radio, into a (disguised)syndicate uplink!
				var/obj/item/uplink/integrated/radio/T = src.traitorradio
				var/obj/item/device/radio/R = src
				R.set_loc(T)
				usr.u_equip(R)
				usr.put_in_hand_or_drop(T)
				R.set_loc(T)
				T.attack_self(usr)
				return

		else if (href_list["talk"])
			src.broadcasting = text2num(href_list["talk"])

		else if (href_list["listen"])
			src.listening = text2num(href_list["listen"])

		else if (href_list["wires"])
			if (!(usr.find_tool_in_hand(TOOL_SNIPPING)))
				return

			var/wireflip = text2num(href_list["wires"]) & (WIRE_SIGNAL | WIRE_RECEIVE | WIRE_TRANSMIT)
			if (wireflip)
				src.wires ^= wireflip

		if (istype(src, /obj/item/device/radio/spy))
			src.updateSelfDialogFromTurf() //radio is inside of another object, use turf

		if (!( src.master ))
			if (ismob(src.loc))
				attack_self(src.loc)
				if (istype(src.loc, /mob/living/silicon/ai)) // eyecam handling
					src.updateSelfDialog()
			else if (istype(src.loc, /obj))
				for(var/mob/M in src.loc)
					attack_self(M)
			else
				src.updateDialog()
		else
			if (ismob(src.master.loc))
				src.attack_self(src.master.loc)
			else
				src.updateDialog()

		src.add_fingerprint(usr)
	else
		usr.Browse(null, WINDOW_OPTIONS)

//pass to talk_into instead of a mob if you don't have a mob handy
//please don't read this i'm so ashamed
/datum/generic_radio_source
	var/name = "Unknown"
	var/real_name = "Unknown"
	var/voice_name = "Unknown"
	var/voice_message = "broadcasts"
	var/say_language = "english"

	proc/say_quote(var/text)
		return "[src.voice_message], \"[text]\""

	proc/set_name(var/new_name)
		name = new_name
		real_name = new_name
		voice_name = new_name

/obj/item/device/radio/proc/radio_icon(var/mob/user)
	if (isAI(user))
		.= "ai"
	else if (isrobot(user))
		.= "robo"
	else if (icon_override)
		.= icon_override

	if(.)
		. = {"<img style=\"position: relative; left: -1px; bottom: -3px;\" class=\"icon misc\" src="[resource("images/radio_icons/[.].png")]">"}
	else
		return bicon(src)

/obj/item/device/radio/talk_into(mob/M as mob, messages, secure, real_name, lang_id)
	// According to a pair of DEBUG calls set up for testing, no radio jammer check for the src radio was performed.
	// As improbable as this sounds, there are bug reports too to back up the findings. So uhm...
	if (src.radio_connection.check_for_jammer(src) != 0)
		return
	if (!(src.wires & WIRE_TRANSMIT))
		return
//	if (last_transmission && world.time < (last_transmission + TRANSMISSION_DELAY))
//		return

	var/ai_sender = 0
	var/eqjobname

	if (iscarbon(M))
		if (hasvar(M, "wear_id"))
			if (M:wear_id)
				eqjobname = M:wear_id:assignment
			else
				eqjobname = "No ID"
	else if (isAI(M))
		eqjobname = "AI"
		ai_sender = 1
	else if (isrobot(M))
		eqjobname = "Cyborg"
	else if (istype(M, /obj/machinery/computer)) // :v
		eqjobname = "Computer"
	else
		eqjobname = "Unknown"

	var/list/receive = list()

	var/display_freq = src.frequency //Frequency to display on radio broadcast messages

	var/datum/radio_frequency/connection = null
	if (secure && src.secure_connections && istype(src.secure_connections["[secure]"], /datum/radio_frequency))
		connection = src.secure_connections["[secure]"]
		display_freq = src.secure_frequencies["[secure]"]
	else
		connection = src.radio_connection
		secure = 0

	for (var/obj/item/I in connection.devices)
		if (istype(I, /obj/item/device/radio))
			var/obj/item/device/radio/R = I
			//MBC : Do checks here and call check_for_jammer_bare instead. reduces proc calls.
			if (can_check_jammer)
				if (connection.check_for_jammer_bare(R))
					continue

			if (R.accept_rad(src, messages, connection))
				R.speech_bubble()
				if (secure)
					for (var/i in R.send_hear())
						if (!(i in receive))
							receive += i

							//mbc : i dont like doing this here but its the easiest place to fit it in since this is a point where we have access to both the receiving mob and the radio they are receiving through
							var/mob/rmob = i

							if (ai_sender)
								rmob.playsound_local(R, 'sound/misc/talk/radio_ai.ogg', 30, 1, 0, pitch = 1, ignore_flag = SOUND_SPEECH)
							else
								rmob.playsound_local(R, 'sound/misc/talk/radio2.ogg', 30, 1, 0, pitch = 1, ignore_flag = SOUND_SPEECH)

				else
					for (var/i in R.send_hear())
						if (!(i in receive))
							receive += i

							if (ai_sender)
								var/mob/rmob = i
								rmob.playsound_local(R, 'sound/misc/talk/radio_ai.ogg', 30, 1, 0, pitch = 1, ignore_flag = SOUND_SPEECH)

		else if (istype(I, /obj/item/mechanics/radioscanner)) //MechComp radio scanner
			var/obj/item/mechanics/radioscanner/R = I
			R.hear_radio(M, messages, lang_id)

	var/list/heard_flock = list() // heard by flockdrones/flockmind

	// Don't let them monitor Syndie headsets. You can get the radio_brain bioeffect at the start of the round, basically.
	if (src.protected_radio != 1 && isnull(src.traitorradio))
		for (var/mob/living/L in radio_brains)
			receive += L

		for(var/mob/zoldorf/z in the_zoldorf)
			if(z.client)
				receive += z


		// hi it's me cirr here to shoehorn in another thing
		// flockdrones and flockmind should hear all channels, but with terrible corruption
		if(flocks && flocks.len)
			for(var/F in flocks)
				var/datum/flock/flock = flocks[F]
				if(flock)
					if(flock.flockmind)
						heard_flock |= flock.flockmind
					if(flock.units && flock.units.len > 0)
						for(var/mob/living/D in flock.units)
							if(D)
								heard_flock |= D

	for (var/client/C)
		if (!C.mob) continue
		var/mob/dead/D = C.mob

		if ((istype(D, /mob/dead/observer) || (iswraith(D) && !D.density)) || ((!isturf(src.loc) && src.loc == D.loc) && !istype(D, /mob/dead/target_observer)))
			if (!(D in receive))
				receive += D

	var/list/heard_masked = list() // masked name or no real name
	var/list/heard_normal = list() // normal message
	var/list/heard_voice = list() // voice message
	var/list/heard_garbled = list() // garbled message


	// Receiving mobs
	for (var/mob/R in receive)
		if (R.say_understands(M, lang_id))
			if (!isghostdrone(R) && (!ishuman(M) || (ishuman(M) && M.wear_mask && M.wear_mask.vchange))) //istype(M.wear_mask, /obj/item/clothing/mask/gas/voice))
				heard_masked += R
			else if (isghostdrone(R))
				heard_voice += R
			else if(!isflock(R)) // a special exemption for flockdrones/flockminds who never get to hear normal radio
				heard_normal += R
		else
			if (M.voice_message)
				heard_voice += R
			else
				heard_garbled += R

		//DEBUG_MESSAGE("Message transmitted. Frequency: [display_freq]. Source: [src] at [log_loc(src)]. Receiver: [R] at [log_loc(R)].")

	var/rendered

	if (length(heard_masked) || length(heard_normal) || length(heard_voice) || length(heard_garbled) || length(heard_flock))
		var/textColor = secure ? null : src.device_color
		var/classes = ""
		if(src.chat_class)
			classes = " [src.chat_class]"
		if (secure)
			if(secure in secure_classes)
				classes = " [secure_classes["[secure]"]]"
			else
				classes = " [secure_classes[1]]"
			textColor = secure_colors["[secure]"]
			if (!textColor)
				if (secure_colors.len)
					textColor = secure_colors[1]
		var/css_style = ""
		if(textColor)
			css_style = " style='color: [textColor]'"
		var/part_a
		if (ismob(M) && M.mind)
			part_a = "[radio_icon(M)]<span class='radio[classes]'[css_style]><span class='name' data-ctx='\ref[M.mind]'>"
		else
			part_a = "[radio_icon(M)]<span class='radio[classes]'[css_style]><span class='name'>"
		var/part_b = "</span><b> \[[format_frequency(display_freq)]\]</b> <span class='message'>"
		var/part_c = "</span></span>"


		if (length(heard_masked))
			if (ishuman(M))
				if (M:wear_id)
					rendered = "[part_a][M:wear_id:registered][part_b][M.say_quote(messages[1])][part_c]"
				else
					rendered = "[part_a]Unknown[part_b][M.say_quote(messages[1])][part_c]"
			else
				rendered = "[part_a][M.name][part_b][M.say_quote(messages[1])][part_c]"

			for (var/mob/R in heard_masked)
				var/thisR = rendered
				if (R.isAIControlled())
					thisR = "[part_a]<a href='?src=\ref[src];track3=[M.name];track2=\ref[R];track=\ref[M]'>[M.name] ([eqjobname]) </a>[part_b][M.say_quote(messages[1])][part_c]"

				if (R.client && R.client.holder && ismob(M) && M.mind)
					thisR = "<span class='adminHearing' data-ctx='[R.client.chatOutput.getContextFlags()]'>[thisR]</span>"
				R.show_message(thisR, 2)

		if (length(heard_normal))
			rendered = "[part_a][real_name ? real_name : M.real_name][part_b][M.say_quote(messages[1])][part_c]"
			for (var/mob/R in heard_normal)
				var/thisR = rendered
				if (R.isAIControlled())
					thisR = "[part_a]<a href='?src=\ref[src];track3=[real_name ? real_name : M.real_name];track2=\ref[R];track=\ref[M]'>[real_name ? real_name : M.real_name] ([eqjobname]) </a>[part_b][M.say_quote(messages[1])][part_c]"

				if (R.client && R.client.holder && ismob(M) && M.mind)
					thisR = "<span class='adminHearing' data-ctx='[R.client.chatOutput.getContextFlags()]'>[thisR]</span>"
				R.show_message(thisR, 2)

		if (length(heard_voice))
			rendered = "[part_a][M.voice_name][part_b][M.voice_message][part_c]"
			for (var/mob/R in heard_voice)
				var/thisR = rendered
				if (R.isAIControlled())
					thisR = "[part_a]<a href='?src=\ref[src];track3=[M.voice_name];track2=\ref[R];track=\ref[M]'>[M.voice_name] ([eqjobname]) </a>[part_b][M.voice_message][part_c]"
				else if (isghostdrone(R))
					thisR = "[part_a][M.voice_name][part_b][M.say_quote(messages[1])][part_c]"

				if (R.client && R.client.holder && ismob(M) && M.mind)
					thisR = "<span class='adminHearing' data-ctx='[R.client.chatOutput.getContextFlags()]'>[thisR]</span>"
				R.show_message(thisR, 2)

		if (length(heard_garbled))
			rendered = "[part_a][M.voice_name][part_b][M.say_quote(messages[2])][part_c]"
			for (var/mob/R in heard_garbled)
				var/thisR = rendered
				if (R.isAIControlled())
					thisR = "[part_a]<a href='?src=\ref[src];track3=[M.voice_name];track2=\ref[R];track=\ref[M]'>[M.voice_name]</a>[part_b][M.say_quote(messages[2])][part_c]"

				if (R.client && R.client.holder && ismob(M) &&  M.mind)
					thisR = "<span class='adminHearing' data-ctx='[R.client.chatOutput.getContextFlags()]'>[thisR]</span>"
				R.show_message(thisR, 2)

		// sure why NOT copy paste - cirr
		// TODO: datumise this to cut down on all the damn copy paste - cirr
		if (length(heard_flock))
			rendered = "[part_a][radioGarbleText(real_name ? real_name : M.real_name, 10)][part_b][M.say_quote(radioGarbleText(messages[1], 40))][part_c]"
			for (var/mob/R in heard_flock)
				var/thisR = rendered
				// there will NEVER be an AI controlled member of this, SO HELP ME IF THERE IS
				if (R.client && R.client.holder && ismob(M) && M.mind)
					thisR = "<span class='adminHearing' data-ctx='[R.client.chatOutput.getContextFlags()]'>[thisR]</span>"
				R.show_message(thisR, 2)


/obj/item/device/radio/hear_talk(mob/M as mob, msgs, real_name, lang_id)
	if (src.broadcasting)
		talk_into(M, msgs, null, real_name, lang_id)

// Hope I didn't butcher this, but I couldn't help but notice some odd stuff going on when I tried to debug radio jammers (Convair880).
/obj/item/device/radio/proc/accept_rad(obj/item/device/radio/R as obj, message, var/datum/radio_frequency/freq)
	if (message)
		// Simple frequency match. The only check that used to be here.
		if (src.frequency == R.frequency)
			//DEBUG_MESSAGE("Match found for transmission from [R] at [log_loc(R)] (simple frequency match)")
			return 1

		// Secure channel lookup when R.frequency != src.frequency. According to DEBUG calls set up for testing,
		// this meant the receiving radio would decline the message even though both share a secure channel.
		else if (src.secure_connections && istype(src.secure_connections) && src.secure_connections.len && freq && istype(freq))
			var/list/datum/radio_frequency/RF = list()

			for (var/key in src.secure_connections)
				if (!RF.Find(src.secure_connections["[key]"]) && istype(src.secure_connections["[key]"], /datum/radio_frequency))
					RF.Add(src.secure_connections["[key]"])

			// Secure channel match. Easy.
			if (RF.Find(freq) && freq.devices.Find(src))
				//DEBUG_MESSAGE("Match found for transmission from [R] at [log_loc(R)] (list/devices match)")
				return 1

			// Sender didn't use a secure channel prefix, giving us the 145.9 radio frequency datum.
			// The devices list is useless here, but we can still receive the message if one of our
			// secure channels happens to have the same frequency as the sender's radio.
			if (src.secure_frequencies && istype(src.secure_frequencies) && src.secure_frequencies.len)
				for (var/freq2 in src.secure_frequencies)
					if (isnum(src.secure_frequencies["[freq2]"]) && src.secure_frequencies["[freq2]"] == R.frequency)
						//DEBUG_MESSAGE("Match found for transmission from [R] at [log_loc(R)] (frequency compare)")
						return 1

	return 0

/obj/item/device/radio/proc/send_hear()

	last_transmission = world.time
	if ((src.listening && src.wires & WIRE_RECEIVE))
		var/list/hear = hearers(src.speaker_range, src.loc) // changed so station bounce radios will be loud and headsets will only be heard on their tile

		// modified so that a mob holding the radio is always a hearer of it
		// this fixes radio problems when inside something (e.g. mulebot)

		if(ismob(loc))
			if(! hear.Find(loc) )
				hear += loc
		//modified so people in the same object as it can hear it
		if(istype(loc, /obj))
			for(var/mob/M in loc)
				if(! hear.Find(M) )
					hear += M
		return hear
	return

/obj/item/device/radio/proc/speech_bubble()
	if ((src.listening && src.wires & WIRE_RECEIVE))
		if (istype(src, /obj/item/device/radio/intercom))
			UpdateOverlays(speech_bubble, "speech_bubble")
			SPAWN_DBG(1.5 SECONDS)
				UpdateOverlays(null, "speech_bubble")

/obj/item/device/radio/examine(mob/user)
	. = ..()
	if ((in_range(src, user) || src.loc == user))
		if (src.b_stat)
			. += "<span class='notice'>\the [src] can be attached and modified!</span>"
		else
			. += "<span class='notice'>\the [src] can not be modified or attached!</span>"
	if (istype(src.secure_frequencies) && src.secure_frequencies.len)
		. += "Supplementary Channels:"
		for (var/sayToken in src.secure_frequencies) //Most convoluted string of the year award 2013
			. += "[ headset_channel_lookup["[src.secure_frequencies["[sayToken]"]]"] ? headset_channel_lookup["[src.secure_frequencies["[sayToken]"]]"] : "???" ]: \[[format_frequency(src.secure_frequencies["[sayToken]"])]] (Activator: <b>[sayToken]</b>)"

/obj/item/device/radio/attackby(obj/item/W as obj, mob/user as mob)
	src.add_dialog(user)
	if (!isscrewingtool(W))
		return
	src.b_stat = !( src.b_stat )
	if (src.b_stat)
		user.show_message("<span class='notice'>The radio can now be attached and modified!</span>")
	else
		user.show_message("<span class='notice'>The radio can no longer be modified or attached!</span>")
	if (isliving(src.loc))
		var/mob/living/M = src.loc
		src.attack_self(M)
		//Foreach goto(83)
	src.add_fingerprint(user)
	return

/obj/item/device/radio/emp_act()
	broadcasting = 0
	listening = 0
	return

/obj/item/radiojammer
	name = "signal jammer"
	desc = "An illegal device used to jam radio signals, preventing broadcast or transmission."
	icon = 'icons/obj/objects.dmi'
	icon_state = "shieldoff"
	w_class = 1
	var/active = 0
	is_syndicate = 1
	mats = 10

	attack_self(var/mob/user as mob)
		if (!(radio_controller && istype(radio_controller)))
			return

		src.active = !src.active
		if (src.active)
			boutput(user, "You activate [src].")
			src.icon_state = "shieldon"
			if (!radio_controller.active_jammers.Find(src))
				radio_controller.active_jammers.Add(src)
		else
			boutput(user, "You shut off [src].")
			icon_state = "shieldoff"
			if (radio_controller.active_jammers.Find(src))
				radio_controller.active_jammers.Remove(src)

	disposing()
		if (radio_controller && istype(radio_controller) && radio_controller.active_jammers.Find(src))
			radio_controller.active_jammers.Remove(src)
		..()
/obj/item/device/radio/beacon
	name = "tracking beacon"
	icon_state = "beacon"
	item_state = "signaler"
	desc = "A small beacon that is tracked by the Teleporter Computer, allowing things to be sent to its general location."
	burn_possible = 0

/obj/item/device/radio/beacon/New()
	..()
	START_TRACKING

/obj/item/device/radio/beacon/disposing()
	STOP_TRACKING
	..()

/obj/item/device/radio/beacon/hear_talk()
	return

/obj/item/device/radio/beacon/send_hear()
	return null

/obj/item/device/radio/electropack
	name = "\improper Electropack"
	icon_state = "electropack0"
	var/code = 2.0
	var/on = 0.0
//	var/e_pads = 0.0
	frequency = 1451
	throw_speed = 1
	throw_range = 3
	w_class = 5.0
	flags = FPRINT | TABLEPASS | ONBACK | CONDUCT
	item_state = "electropack"
	desc = "A device that, when signaled on the correct frequency, causes a disabling electric shock to be sent to the animal (or human) wearing it."
	cant_self_remove = 1

/*
/obj/item/device/radio/electropack/examine()
	set src in view()
	set category = "Local"

	..()
	if ((in_range(src, usr) || src.loc == usr))
		if (src.e_pads)
			boutput(usr, "<span class='notice'>The electric pads are exposed!</span>")
	return*/

/obj/item/device/radio/electropack/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/clothing/head/helmet))
		var/obj/item/assembly/shock_kit/A = new /obj/item/assembly/shock_kit( user )
		W.set_loc(A)
		A.part1 = W
		W.layer = initial(W.layer)
		user.u_equip(W)
		user.put_in_hand_or_drop(A)
		W.master = A
		src.master = A
		src.layer = initial(src.layer)
		user.u_equip(src)
		src.set_loc(A)
		A.part2 = src
		src.add_fingerprint(user)
	return

/obj/item/device/radio/electropack/Topic(href, href_list)
	//..()
	if (usr.stat || usr.restrained())
		return
	if (src in usr || (src.master && (src.master in usr)) || (in_range(src, usr) && istype(src.loc, /turf)))
		src.add_dialog(usr)
		if (href_list["freq"])
			var/new_frequency = sanitize_frequency(frequency + text2num(href_list["freq"]))
			set_frequency(new_frequency)
		else
			if (href_list["code"])
				src.code += text2num(href_list["code"])
				src.code = round(src.code)
				src.code = min(100, src.code)
				src.code = max(1, src.code)
			else
				if (href_list["power"])
					src.on = !( src.on )
					src.icon_state = text("electropack[]", src.on)
		if (!( src.master ))
			if (ismob(src.loc))
				attack_self(src.loc)
			else
				for(var/mob/M in viewers(1, src))
					if (M.client)
						src.attack_self(M)
		else
			if (ismob(src.master.loc))
				src.attack_self(src.master.loc)
			else
				for(var/mob/M in viewers(1, src.master))
					if (M.client)
						src.attack_self(M)
	else
		usr.Browse(null, WINDOW_OPTIONS)
		return
	return
/*
/obj/item/device/radio/electropack/accept_rad(obj/item/device/radio/signaler/R as obj, message)

	if ((istype(R, /obj/item/device/radio/signaler) && R.frequency == src.frequency && R.code == src.code))
		return 1
	else
		return null
	return
*/
/obj/item/device/radio/electropack/receive_signal(datum/signal/signal)
	if (!signal || !signal.data || ("[signal.data["code"]]" != "[code]"))//(signal.encryption != code))
		return

	if (ismob(src.loc) && src.on)
		var/mob/M = src.loc
		if (src == M.back)
			M.show_message("<span class='alert'><B>You feel a sharp shock!</B></span>")
			logTheThing("signalers", usr, M, "signalled an electropack worn by [constructTarget(M,"signalers")] at [log_loc(M)].") // Added (Convair880).
			if(ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/revolution))
				if((M.mind in ticker.mode:revolutionaries) && !(M.mind in ticker.mode:head_revolutionaries) && prob(20))
					ticker.mode:remove_revolutionary(M.mind)

#ifdef USE_STAMINA_DISORIENT
			M.do_disorient(200, weakened = 100, disorient = 60, remove_stamina_below_zero = 0)
#else
			M.changeStatus("weakened", 10 SECONDS)
#endif
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				for (var/uid in H.pathogens)
					var/datum/pathogen/P = H.pathogens[uid]
					P.onshocked(35, 500)

	if ((src.master && src.wires & WIRE_SIGNAL))
		src.master.receive_signal()

	return

/obj/item/device/radio/electropack/attack_self(mob/user as mob, flag1)

	if (!( ishuman(user) ))
		return
	src.add_dialog(user)
	var/dat = {"<TT>
<a href='?src=\ref[src];power=1'>Turn [src.on ? "Off" : "On"]</a><br>
<B>Frequency/Code</B> for electropack:<br>
Frequency:
<a href='?src=\ref[src];freq=-10'>-</a>
<a href='?src=\ref[src];freq=-2'>-</a> [format_frequency(src.frequency)]
<a href='?src=\ref[src];freq=2'>+</a>
<a href='?src=\ref[src];freq=10'>+</a><br>

Code:
<a href='?src=\ref[src];code=-5'>-</a>
<a href='?src=\ref[src];code=-1'>-</a> [src.code]
<a href='?src=\ref[src];code=1'>+</a>
<a href='?src=\ref[src];code=5'>+</a><br>
</TT>"}
	user.Browse(dat, WINDOW_OPTIONS)
	onclose(user, "radio")
	return



// ****************************************************




/obj/item/device/radio/signaler
	name = "\improper Remote Signaling Device"
	icon_state = "signaller"
	item_state = "signaler"
	var/code = 30.0
	w_class = 1.0
	frequency = 1457
	var/delay = 0
	var/airlock_wire = null
	desc = "A device used to send a coded signal over a specified frequency, with the effect depending on the device that recieves the signal."

/*
/obj/item/device/radio/signaler/examine()
	set src in view()
	set category = "Local"
	..()
	if ((in_range(src, usr) || src.loc == usr))
		if (src.b_stat)
			usr.show_message("<span class='notice'>The signaler can be attached and modified!</span>")
		else
			usr.show_message("<span class='notice'>The signaler can not be modified or attached!</span>")
	return
*/

/obj/item/device/radio/signaler/attack_self(mob/user as mob, flag1)
	src.add_dialog(user)
	var/t1
	if ((src.b_stat && !( flag1 )))
		t1 = text("-------<br><br>Green Wire: []<br><br>Red Wire:   []<br><br>Blue Wire:  []<br><br>", (src.wires & WIRE_TRANSMIT ? text("<a href='?src=\ref[];wires=[WIRE_TRANSMIT]'>Cut Wire</a>", src) : text("<a href='?src=\ref[];wires=[WIRE_TRANSMIT]'>Mend Wire</a>", src)), (src.wires & WIRE_RECEIVE ? text("<a href='?src=\ref[];wires=[WIRE_RECEIVE]'>Cut Wire</a>", src) : text("<a href='?src=\ref[];wires=[WIRE_RECEIVE]'>Mend Wire</a>", src)), (src.wires & WIRE_SIGNAL ? text("<a href='?src=\ref[];wires=[WIRE_SIGNAL]'>Cut Wire</a>", src) : text("<a href='?src=\ref[];wires=[WIRE_SIGNAL]'>Mend Wire</a>", src)))
	else
		t1 = "-------"
	var/dat = {"
<TT>
Speaker: [src.listening ? "<a href='?src=\ref[src];listen=0'>Engaged</a>" : "<a href='?src=\ref[src];listen=1'>Disengaged</a>"]<br>
<a href='?src=\ref[src];send=1'>Send Signal</a><br>
<B>Frequency/Code</B> for signaler:<br>
Frequency:
<a href='?src=\ref[src];freq=-10'>-</a>
<a href='?src=\ref[src];freq=-2'>-</a>
[format_frequency(src.frequency)]
<a href='?src=\ref[src];freq=2'>+</a>
<a href='?src=\ref[src];freq=10'>+</a><br>

Code:
<a href='?src=\ref[src];code=-5'>-</a>
<a href='?src=\ref[src];code=-1'>-</a>
[src.code]
<a href='?src=\ref[src];code=1'>+</a>
<a href='?src=\ref[src];code=5'>+</a><br>
[t1]
</TT>"}
	user.Browse(dat, WINDOW_OPTIONS)
	onclose(user, "radio")
	return

obj/item/device/radio/signaler/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/instrument/bikehorn))
		var/obj/item/assembly/radio_horn/A = new /obj/item/assembly/radio_horn( user )
		W.set_loc(A)
		A.part2 = W
		W.layer = initial(W.layer)
		user.u_equip(W)
		user.put_in_hand_or_drop(A)
		W.master = A
		src.master = A
		src.layer = initial(src.layer)
		user.u_equip(src)
		src.set_loc(A)
		A.part1 = src
		src.add_fingerprint(user)
		boutput(user, "You open the signaler and cram the [W.name] in there!")
	else
		..()
	return

/obj/item/device/radio/signaler/hear_talk()
	return

/obj/item/device/radio/signaler/send_hear()
	return


/obj/item/device/radio/signaler/receive_signal(datum/signal/signal)
	if(!signal || !signal.data || "[signal.data["code"]]" != "[code]")//(signal.encryption != code))
		return

	if (!( src.wires & WIRE_RECEIVE ))
		return
	if(istype(src.loc, /obj/machinery/door/airlock) && src.airlock_wire && src.wires & WIRE_SIGNAL)
//		boutput(world, "/obj/.../signaler/r_signal([signal]) has master = [src.master] and type [(src.master?src.master.type : "none")]")
//		boutput(world, "[src.airlock_wire] - [src] - [usr] - [signal]")
		var/obj/machinery/door/airlock/A = src.loc
		A.pulse(src.airlock_wire)
//		src.master:r_signal(signal)
	if(src.master && (src.wires & WIRE_SIGNAL))
		var/turf/T = get_turf(src.master)
		if (src.master && istype(src.master, /obj/item/device/transfer_valve))
			logTheThing("bombing", usr, null, "signalled a radio on a transfer valve at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"].")
			message_admins("[key_name(usr)] signalled a radio on a transfer valve at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"].")

		else if (src.master && istype(src.master, /obj/item/assembly/rad_ignite)) //Radio-detonated beaker assemblies
			var/obj/item/assembly/rad_ignite/RI = src.master
			logTheThing("bombing", usr, null, "signalled a radio on a radio-igniter assembly at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"]. Contents: [log_reagents(RI.part3)]")

		else if(src.master && istype(src.master, /obj/item/assembly/radio_bomb))	//Radio-detonated single-tank bombs
			logTheThing("bombing", usr, null, "signalled a radio on a single-tank bomb at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"].")
			message_admins("[key_name(usr)] signalled a radio on a single-tank bomb at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"].")
		SPAWN_DBG(0)
			src.master.receive_signal(signal)
	for(var/mob/O in hearers(1, src.loc))
		O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)

	return

/obj/item/device/radio/signaler/proc/send_signal(message="ACTIVATE")

	if(last_transmission && world.time <= (last_transmission + TRANSMISSION_DELAY * 2))
		return
	last_transmission = world.time

	if (!( src.wires & WIRE_TRANSMIT ))
		return

	logTheThing("signalers", !usr && src.master ? src.master.fingerprintslast : usr, null, "used remote signaller[src.master ? " (connected to [src.master.name])" : ""] at [src.master ? "[log_loc(src.master)]" : "[log_loc(src)]"]. Frequency: [format_frequency(frequency)]/[code].")

	var/datum/signal/signal = get_free_signal()
	signal.source = src
	//signal.encryption = code
	signal.data["code"] = code
	signal.data["message"] = message

	radio_connection.post_signal(src, signal)

	return

/obj/item/device/radio/signaler/Topic(href, href_list)
	//..()
	if (usr.stat)
		return
	var/is_detonator_trigger = 0
	if (src.master)
		if (istype(src.master, /obj/item/assembly/detonator/) && src.master.master)
			if (istype(src.master.master, /obj/machinery/portable_atmospherics/canister/) && in_range(src.master.master, usr))
				is_detonator_trigger = 1
	if (is_detonator_trigger || (src in usr) || (src.master && (src.master in usr)) || (in_range(src, usr) && istype(src.loc, /turf)))
		src.add_dialog(usr)
		if (href_list["freq"])
			var/new_frequency = sanitize_frequency(frequency + text2num(href_list["freq"]))
			set_frequency(new_frequency)
		else if (href_list["code"])
			src.code += text2num(href_list["code"])
			src.code = round(src.code)
			src.code = min(100, src.code)
			src.code = max(1, src.code)
		else if (href_list["send"])
			src.send_signal("ACTIVATE")
			return
		else if (href_list["listen"])
			src.listening = text2num(href_list["listen"])
		else if (href_list["wires"])
			//var/t1 = text2num(href_list["wires"])
			if (!(usr.find_tool_in_hand(TOOL_SNIPPING)))
				return
			if ((!( src.b_stat ) && !( src.master )))
				return

			..()
			// bet this breaks everything oops oh well
			/*
			if (t1 & 1)
				if (src.wires & 1)
					src.wires &= 65534
				else
					src.wires |= 1
			else
				if (t1 & 2)
					if (src.wires & 2)
						src.wires &= 65533
					else
						src.wires |= 2
				else
					if (t1 & 4)
						if (src.wires & 4)
							src.wires &= 65531
						else
							src.wires |= 4
			*/
		src.add_fingerprint(usr)
		if (!src.master)
			if (ismob(src.loc))
				attack_self(src.loc)
			else
				for(var/mob/M in viewers(1, src))
					if (M.client)
						src.attack_self(M)
		else
			if (is_detonator_trigger)
				src.attack_self(usr)
			if (ismob(src.master.loc))
				src.attack_self(src.master.loc)
			else
				for(var/mob/M in viewers(1, src.master))
					if (M.client)
						src.attack_self(M)
	else
		usr.Browse(null, WINDOW_OPTIONS)
		return
	return

//////////////////////////////////////////////////
/obj/item/device/radio/intercom/loudspeaker
	name = "Loudspeaker Transmitter"
	icon = 'icons/obj/loudspeakers.dmi'
	icon_state = "transmitter"
	anchored = 1.0
	speaker_range = 0
	mats = 0
	chat_class = RADIOCL_INTERCOM
	//Best I can figure, you need broadcasting and listening to both be TRUE for it to make a signal and send the words spoken next to it. Why? Fuck whoever named these, that's why.
	broadcasting = 0
	listening = 0		//maybe this doesn't need to be on. It shouldn't be relaying signals.
	density = 1
	rand_pos = 0
	desc = "A HAM radio transmitter...Basically...It only transmits to loudspeakers on a secure frequency."
	frequency = R_FREQ_LOUDSPEAKERS
	var/image/active_light = null

	New()
		// active_light = new ()

//Must be standing next to it to talk into it
/obj/item/device/radio/intercom/loudspeaker/hear_talk(mob/M as mob, msgs, real_name, lang_id)
	if (src.broadcasting)
		if (get_dist(src, M) <= 1)
			talk_into(M, msgs, null, real_name, lang_id)

/obj/item/device/radio/intercom/loudspeaker/examine()
	. = ..()
	. += "[src] is[src.broadcasting ? " " : " not "]active!\nIt is tuned to [format_frequency(src.frequency)]Hz."

/obj/item/device/radio/intercom/loudspeaker/attack_self(mob/user as mob)
	if (!broadcasting)
		broadcasting = 1
		src.icon_state = "transmitter-on"
		boutput(user, "Now transmitting.")
	else
		broadcasting = 0
		src.icon_state = "transmitter"
		boutput(user, "No longer transmitting.")

/obj/item/device/radio/intercom/loudspeaker/initialize()

	set_frequency(frequency)
	if(src.secure_frequencies)
		set_secure_frequencies()

//This is the main parent, also is the actual speakers that will be attached to the walls.
/obj/item/device/radio/intercom/loudspeaker/speaker
	name = "Loudspeaker"
	icon_state = "loudspeaker"
	anchored = 1.0
	speaker_range = 7
	mats = 0
	broadcasting = 1
	listening = 1
	chat_class = RADIOCL_INTERCOM
	frequency = R_FREQ_LOUDSPEAKERS
	rand_pos = 0
	density = 0
	desc = "A Loudspeaker."

	New()
		//..()
		if(src.pixel_x == 0 && src.pixel_y == 0)
			switch(src.dir)
				if(NORTH)
					pixel_y = -14
				if(SOUTH)
					pixel_y = 32
				if(EAST)
					pixel_x = -21
				if(WEST)
					pixel_x = 21

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST

//You can't talk into it to send a message
/obj/item/device/radio/intercom/loudspeaker/speaker/hear_talk()
	return

	//listening seems to refer to the device listening to the signals, not listening to voice

/obj/item/device/radio/intercom/loudspeaker/speaker/send_hear()
	var/list/hear = ..()

	for (var/mob/M in hear)

		flick("loudspeaker-transmitting",src)
		playsound(src.loc, 'sound/misc/talk/speak_1.ogg', 50, 1)
	return hear


/obj/item/device/radio/intercom/loudspeaker/speaker/attack_hand(mob/user as mob)
	return
