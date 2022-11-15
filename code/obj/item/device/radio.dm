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
	var/traitor_frequency = 0
	var/obj/item/device/radio/patch_link = null
	var/obj/item/uplink/integrated/radio/traitorradio = null
	var/wires = WIRE_SIGNAL | WIRE_RECEIVE | WIRE_TRANSMIT
	var/b_stat = 0
	var/broadcasting = FALSE
	var/listening = TRUE
	var/has_microphone = TRUE
	var/list/datum/component/packet_connected/radio/secure_connections = null
	var/speaker_range = 2
	var/static/mutable_appearance/speech_bubble = living_speech_bubble //typing_indicator.dm
	///This is for being able to run through signal jammers (just solar flares for now). acceptable values = 0 and 1.
	var/hardened = 1
	///Set to make it not work, used by flock victory screech
	var/bricked = FALSE
	///Message shown when you attempt to use the radio while bricked
	var/bricked_msg = "The radio is utterly dead and silent."
	/// Set to TRUE for your radio obj to have unconditional flying text. Override showMapText() to conditionalize it.
	var/doesMapText = FALSE
	// probably not too resource intensive but I'd be careful using this just in case

	flags = FPRINT | TABLEPASS | ONBELT | CONDUCT
	throw_speed = 2
	throw_range = 9
	w_class = W_CLASS_SMALL
	mats = 3

	var/icon_override = 0
	var/icon_tooltip = null // null = use name, "" = no tooltip

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
	if ((src.frequency < R_FREQ_MINIMUM || src.frequency > R_FREQ_MAXIMUM) && !src.locked_frequency)
		// if the frequency is somehow set outside of the normal range, put it back in range
		world.log << "[src] ([src.type]) has a frequency of [src.frequency], sanitizing."
		src.frequency = sanitize_frequency(src.frequency)

	MAKE_DEFAULT_RADIO_PACKET_COMPONENT("main", frequency)

	if(src.secure_frequencies)
		set_secure_frequencies()

	src.chat_text = new
	src.vis_contents += src.chat_text

/obj/item/device/radio/disposing()
	src.patch_link = null
	src.traitorradio  = null
	src.secure_connections = null
	src.secure_frequencies = null
	src.speech_bubble = null
	..()

/obj/item/device/radio/proc/set_frequency(new_frequency)
	frequency = new_frequency
	get_radio_connection_by_id(src, "main").update_frequency(frequency)

/obj/item/device/radio/proc/set_secure_frequencies()
	if(istype(src.secure_frequencies))
		if (!istype(src.secure_connections))
			src.secure_connections = list()
		for (var/sayToken in src.secure_frequencies)
			var/frequency_id = src.secure_frequencies["[sayToken]"]
			if (frequency_id)
				if (!src.secure_connections["[sayToken]"])
					src.secure_connections["[sayToken]"] = MAKE_DEFAULT_RADIO_PACKET_COMPONENT("f[frequency_id]", frequency_id)
			else
				src.secure_frequencies -= "[sayToken]"

/obj/item/device/radio/proc/set_secure_frequency(frequencyToken, newFrequency)
	if (!frequencyToken || !newFrequency)
		return

	if(!istype(src.secure_frequencies))
		secure_frequencies = list()

	if(!istype(src.secure_connections))
		secure_connections = list()

	var/oldConnection = src.secure_connections["[frequencyToken]"]
	if (oldConnection)
		qdel(oldConnection)

	src.secure_connections["[frequencyToken]"] = MAKE_DEFAULT_RADIO_PACKET_COMPONENT("f[newFrequency]", newFrequency)
	src.secure_frequencies["[frequencyToken]"] = newFrequency
	return

/obj/item/device/radio/ui_interact(mob/user, datum/tgui/ui)
	if (src.bricked)
		user.show_text(src.bricked_msg, "red")
		return
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Radio")
		ui.open()

/obj/item/device/radio/ui_state(mob/user)
	return tgui_physical_state

/obj/item/device/radio/ui_status(mob/user, datum/ui_state/state)
	if (isAI(user))
		. = UI_INTERACTIVE
	else
		. = min(
			state.can_use_topic(src, user),
			tgui_not_incapacitated_state.can_use_topic(src, user)
		)

/obj/item/device/radio/ui_data(mob/user)

	var/list/frequencies = new/list(length(src.secure_frequencies))
	if (istype(src.secure_frequencies) && length(src.secure_frequencies))
		for(var/i in 1 to length(src.secure_frequencies))
			var/sayToken = src.secure_frequencies[i]
			frequencies[i] = list(
				"channel" = headset_channel_lookup["[src.secure_frequencies[sayToken]]"] ? headset_channel_lookup["[src.secure_frequencies[sayToken]]"] : "???",
				"frequency" = format_frequency(src.secure_frequencies[sayToken]),
				"sayToken" = sayToken,
			)

	. = list(
		"name" = src.name,
		"broadcasting" = src.broadcasting,
		"listening" = src.listening,
		"frequency" = src.frequency,
		"lockedFrequency" = src.locked_frequency,
		"secureFrequencies" = frequencies,
		"wires" = src.wires,
		"modifiable" = src.b_stat,
		"hasMicrophone" = src.has_microphone,
	)

/obj/item/device/radio/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	if (src.bricked)
		return
	switch(action)
		if ("set-frequency")
			if (src.locked_frequency)
				return FALSE
			set_frequency(sanitize_frequency(params["value"]))

			// We check "finish" here which is true whenever the user inputs a number
			// with the input field or stops dragging so its harder to bruteforce the
			// uplink.
			if (params["finish"] && !isnull(src.traitorradio) && src.traitor_frequency && src.frequency == src.traitor_frequency)
				ui.close()
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

			return TRUE

		if ("toggle-broadcasting")
			src.broadcasting = !src.broadcasting
			return TRUE

		if ("toggle-listening")
			src.listening = !src.listening
			return TRUE

		if ("toggle-wire")
			if (!(usr.find_tool_in_hand(TOOL_SNIPPING)))
				return FALSE

			var/wireflip = params["wire"] & (WIRE_SIGNAL | WIRE_RECEIVE | WIRE_TRANSMIT)
			if (wireflip)
				src.wires ^= wireflip

				return TRUE

/obj/item/device/radio/Topic(href, href_list)
	if (usr.stat)
		return

	if ((issilicon(usr) || isAI(usr)) || (src in usr) || (usr.loc == src.loc))
		if (href_list["track"])
			// wait is tracking here? really? what? ???? ????????????
			var/mob/living/silicon/A = locate(href_list["track2"])
			var/heard_name = href_list["track3"]
			A.ai_name_track(heard_name)
			return

/obj/item/device/radio/attack_self(mob/user as mob)
	src.ui_interact(user)

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
		. = bicon(src)
	var/tooltip = src.icon_tooltip
	if(isnull(tooltip))
		tooltip = src.name
	if(tooltip)
		. = {"<div class='tooltip'>[.]<span class="tooltiptext">[tooltip]</span></div>"}


/** Max number of radios that will show maptext for a single message.
 *  5 should be sufficient for any normal gameplay; any more is people constructing extras
 */
#define RADIO_MAPTEXT_MAX_RADIOS_DISPLAYING 5
/obj/item/device/radio/talk_into(mob/M as mob, messages, secure, real_name, lang_id)
	if (length(by_cat[TR_CAT_RADIO_JAMMERS]) && check_for_radio_jammers(src))
		return
	if (!(src.wires & WIRE_TRANSMIT))
		return
//	if (last_transmission && world.time < (last_transmission + TRANSMISSION_DELAY))
//		return
	if (src.bricked)
		M.show_text(src.bricked_msg, "red")
		return

	var/ai_sender = 0
	var/eqjobname

	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (H.wear_id)
			eqjobname = H.wear_id:assignment
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

	///will be associative. key = mob, value = list()
	///each person will be associated with the radios they're hearing through, e.g shitty bill = radio1, radio2, radio3; john bill = radio1, radio3, radio4
	var/list/receive = new()


	var/display_freq = src.frequency //Frequency to display on radio broadcast messages

	var/datum/component/packet_connected/radio/connection = null
	if (secure && src.secure_connections && istype(src.secure_connections["[secure]"], /datum/component/packet_connected))
		connection = src.secure_connections["[secure]"]
		display_freq = src.secure_frequencies["[secure]"]
	else
		connection = get_radio_connection_by_id(src, "main")
		secure = 0

	var/freq = connection.get_frequency()

	for (var/obj/item/I as anything in connection.network?.analog_devices)
		if (istype(I, /obj/item/device/radio))
			var/obj/item/device/radio/R = I
			if (R.bricked)
				continue
			if (length(by_cat[TR_CAT_RADIO_JAMMERS]) && check_for_radio_jammers(R))
				continue
			//if we have signal_loss (solar flare), and the radio isn't hardened don't send message, then block general frequencies.
			if (signal_loss && !src.hardened && !secure)
				if (text2num_safe(freq) >= R_FREQ_MINIMUM && text2num_safe(freq) <= R_FREQ_MAXIMUM)
					continue

			if (R.accept_rad(src, messages, connection.network))
				if (ai_sender)
					R.speech_bubble(image('icons/mob/mob.dmi', "ai"))
				else
					R.speech_bubble()
				if (secure)

					var/mob/temp_mob = null
					if (istype(R.loc, /obj/item/organ/head))
						var/obj/item/organ/head/O = R.loc
						if (O.linked_human != null)
							temp_mob = O.linked_human

					for (var/i in R.send_hear() + temp_mob)
						if (i)
							var/mob/rmob = i
							if (!(i in receive))
								receive.Add(rmob)
								if (ai_sender)
									rmob.playsound_local(R, 'sound/misc/talk/radio_ai.ogg', 30, 1, 0, pitch = 1, ignore_flag = SOUND_SPEECH)
								else
									rmob.playsound_local(R, 'sound/misc/talk/radio2.ogg', 30, 1, 0, pitch = 1, ignore_flag = SOUND_SPEECH)
								//mbc : i dont like doing this here but its the easiest place to fit it in since this is a point where we have access to both the receiving mob and the radio they are receiving through
								//nex : now we have a list of all the radios someone is hearing through so now we can do this elsewhere, poggers. anyways still gonna leave this here :^)

							associateRadioToMob(rmob, R, receive, messages, secure, real_name, lang_id)


				else
					var/mob/temp_mob = null
					if (istype(R.loc, /obj/item/organ/head))
						var/obj/item/organ/head/O = R.loc
						if (O.linked_human != null)
							temp_mob = O.linked_human

					for (var/i in R.send_hear() + temp_mob)
						if (i)
							if (signal_loss && !R.hardened && R.frequency >= R_FREQ_MINIMUM && R.frequency <= R_FREQ_MAXIMUM)
								continue

							var/mob/rmob = i
							if (!(i in receive))
								receive.Add(i)
								if (ai_sender)
									rmob.playsound_local(R, 'sound/misc/talk/radio_ai.ogg', 30, 1, 0, pitch = 1, ignore_flag = SOUND_SPEECH)

							associateRadioToMob(rmob, R, receive, messages, secure, real_name, lang_id)

		else if (istype(I, /obj/item/mechanics/radioscanner)) //MechComp radio scanner
			var/obj/item/mechanics/radioscanner/R = I
			R.hear_radio(M, messages, lang_id)

	var/list/heard_flock = list() // heard by flockdrones/flockmind
	var/datum/game_mode/conspiracy/N = ticker.mode
	var/protected_frequency = null
	if(istype(N))
		protected_frequency = N.agent_radiofreq //groups conspirator frequency as a traitor one and protects it along with nukies
	// Don't let them monitor Syndie headsets. You can get the radio_brain bioeffect at the start of the round, basically.
	if (src.protected_radio != 1 && isnull(src.traitorradio) && protected_frequency != display_freq )
		for (var/mob/living/L in radio_brains)
			if(radio_brains[L] == 1 && display_freq != R_FREQ_DEFAULT)
				continue
			receive += L

		for(var/mob/zoldorf/z in the_zoldorf)
			if(z.client)
				receive += z

	// flockdrones and flockmind should hear all channels, but with terrible corruption
		for(var/F in flocks)
			var/datum/flock/flock = flocks[F]
			if(flock)
				if(flock.flockmind)
					heard_flock |= flock.flockmind
				for(var/mob/living/D in flock.units)
					if(D)
						heard_flock |= D

	for (var/client/C)
		if (!C.mob) continue
		var/mob/dead/D = C.mob

		if ((istype(D, /mob/dead/observer) || (iswraith(D) && !D.density)) || ((!isturf(src.loc) && src.loc == D.loc) && !istype(D, /mob/dead/target_observer)))

			if (!C.mute_ghost_radio && !(D in receive))
				receive += D

	var/list/heard_masked = list() // masked name or no real name
	var/list/heard_normal = list() // normal message
	var/list/heard_voice = list() // voice message
	var/list/heard_garbled = list() // garbled message


	// Receiving mobs
	for (var/mob/R in receive)
		if(isnewplayer(R))
			continue
		if (R.say_understands(M, lang_id))
			if (!isghostdrone(R) && (!ishuman(M) || (ishuman(M) && M.wear_mask && M.wear_mask.vchange))) //istype(M.wear_mask, /obj/item/clothing/mask/gas/voice))
				heard_masked += R
			else if (isghostdrone(R))
				heard_voice += R
			else if(!isflockmob(R)) // a special exemption for flockdrones/flockminds who never get to hear normal radio
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
			part_a = "<span class='radio[classes]'[css_style]>[radio_icon(M)]<span class='name' data-ctx='\ref[M.mind]'>"
		else
			part_a = "<span class='radio[classes]'[css_style]>[radio_icon(M)]<span class='name'>"
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

				// We don't wanna boutput more than once but we gotta make sure all our maptext sends
				// We also do our client pref checks here and not when forming receive[], so that other things unrelated
				// to maptext can use the big list of people associated with the radios they're hearing through
				if (!R.client?.preferences.flying_chat_hidden)
					var/count = 0
					for (var/obj/item/device/radio/rad in receive[R])
						if (++count > RADIO_MAPTEXT_MAX_RADIOS_DISPLAYING)
							break
						rad.showMapText(R, M, receive, messages[1], secure, real_name, lang_id)

				R.show_message(thisR, 2)

		if (length(heard_normal))
			var/prep_name = "[real_name ? real_name : M.real_name]"
			if(M.vdisfigured)
				prep_name = "Unknown"
			rendered = "[part_a][prep_name][part_b][M.say_quote(messages[1])][part_c]"
			for (var/mob/R in heard_normal)
				var/thisR = rendered
				if (R.isAIControlled())
					thisR = "[part_a]<a href='?src=\ref[src];track3=[real_name ? real_name : M.real_name];track2=\ref[R];track=\ref[M]'>[real_name ? real_name : M.real_name] ([eqjobname]) </a>[part_b][M.say_quote(messages[1])][part_c]"

				if (R.client && R.client.holder && ismob(M) && M.mind)
					thisR = "<span class='adminHearing' data-ctx='[R.client.chatOutput.getContextFlags()]'>[thisR]</span>"

				if (!R.client?.preferences.flying_chat_hidden)
					var/count = 0
					for (var/obj/item/device/radio/rad in receive[R])
						if (++count > RADIO_MAPTEXT_MAX_RADIOS_DISPLAYING)
							break
						rad.showMapText(R, M, receive, messages[1], secure, real_name, lang_id)

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

				if (!R.client?.preferences.flying_chat_hidden)
					var/count = 0
					for (var/obj/item/device/radio/rad in receive[R])
						if (++count > RADIO_MAPTEXT_MAX_RADIOS_DISPLAYING)
							break
						rad.showMapText(R, M, receive, messages[1], secure, real_name, lang_id)

				R.show_message(thisR, 2)

		if (length(heard_garbled))
			rendered = "[part_a][M.voice_name][part_b][M.say_quote(messages[2])][part_c]"
			for (var/mob/R in heard_garbled)
				var/thisR = rendered
				if (R.isAIControlled())
					thisR = "[part_a]<a href='?src=\ref[src];track3=[M.voice_name];track2=\ref[R];track=\ref[M]'>[M.voice_name]</a>[part_b][M.say_quote(messages[2])][part_c]"

				if (R.client && R.client.holder && ismob(M) &&  M.mind)
					thisR = "<span class='adminHearing' data-ctx='[R.client.chatOutput.getContextFlags()]'>[thisR]</span>"

				if (!R.client?.preferences.flying_chat_hidden)
					var/count = 0
					for (var/obj/item/device/radio/rad in receive[R])
						if (++count > RADIO_MAPTEXT_MAX_RADIOS_DISPLAYING)
							break
						rad.showMapText(R, M, receive, messages[2], secure, real_name, lang_id)

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
#undef RADIO_MAPTEXT_MAX_RADIOS_DISPLAYING


/obj/item/device/radio/hear_talk(mob/M as mob, msgs, real_name, lang_id)
	if (src.broadcasting)
		talk_into(M, msgs, null, real_name, lang_id)

/// Handles adding radio objs to the list of radios someone is hearing a message through.
/obj/item/device/radio/proc/associateRadioToMob(var/mob/rmob, var/obj/item/device/radio/R, receive, messages, secure, real_name, lang_id)
// By default, associateRadioToMob() won't use all these vars, but we're calling them anyways in case someone overrides it and is expecting it to be called with these args
	if (rmob.client)
		if (!islist(receive[rmob]))
			receive[rmob] = list()
		receive[rmob] += R

/// Renders maptext to the receiving radio by default. Set textLoc to the loc you want to render the text on otherwise.
/obj/item/device/radio/proc/generateMapText(var/text, textLoc, var/mob/R, style, var/alpha = 140, force, time) // lets hope to god copy/pasting works just fine
	var/image/chat_maptext/maptext = null
	if (isnull(textLoc))
		textLoc = src
	if (speechpopups && text)
		maptext = make_chat_maptext(textLoc, text, style, alpha, force, time)
	return maptext

/// Handles the displaying of maptext to a player; called on the actual object that the maptext is generating on. Override in child to change maptext behavior!
/obj/item/device/radio/proc/showMapText(var/mob/R, var/mob/sender, receive, msg, secure, real_name, lang_id, textLoc)
	if(!src.doesMapText && !force_radio_maptext)
		return
	var/maptext = generateMapText(msg, R = R, textLoc = textLoc) // if you want to simply ..() but want to override the maptext loc
	R.show_message(type = 2, just_maptext = TRUE, assoc_maptext = maptext)

// Hope I didn't butcher this, but I couldn't help but notice some odd stuff going on when I tried to debug radio jammers (Convair880).
/obj/item/device/radio/proc/accept_rad(obj/item/device/radio/R as obj, message, var/datum/packet_network/radio/freq)
	if (message)
		// Simple frequency match. The only check that used to be here.
		if (src.frequency == R.frequency)
			//DEBUG_MESSAGE("Match found for transmission from [R] at [log_loc(R)] (simple frequency match)")
			return 1

		// Secure channel lookup when R.frequency != src.frequency. According to DEBUG calls set up for testing,
		// this meant the receiving radio would decline the message even though both share a secure channel.
		else if (src.secure_connections && istype(src.secure_connections) && src.secure_connections.len && freq && istype(freq))
			if(get_radio_connection_by_id(src, "f[freq.frequency]"))
				return TRUE

			// Sender didn't use a secure channel prefix, giving us the 145.9 radio frequency datum.
			// The devices list is useless here, but we can still receive the message if one of our
			// secure channels happens to have the same frequency as the sender's radio.
			if (src.secure_frequencies && istype(src.secure_frequencies) && length(src.secure_frequencies))
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
			hear |= loc
		//modified so people in the same object as it can hear it
		if(istype(loc, /obj))
			for(var/mob/M in loc)
				hear |= M
		return hear

/obj/item/device/radio/proc/speech_bubble(var/bubbleOverride)
	if (!bubbleOverride)
		bubbleOverride = src.speech_bubble
	if ((src.listening && src.wires & WIRE_RECEIVE))
		if (istype(src, /obj/item/device/radio/intercom))
			UpdateOverlays(bubbleOverride, "speech_bubble")
			SPAWN(1.5 SECONDS)
				UpdateOverlays(null, "speech_bubble")

/obj/item/device/radio/examine(mob/user)
	. = ..()
	if ((in_interact_range(src, user) || src.loc == user))
		if (src.b_stat)
			. += "<br><span class='notice'>[src] can be attached and modified!</span>"
		else
			. += "<br><span class='notice'>[src] can not be modified or attached!</span>"
	if (istype(src.secure_frequencies) && length(src.secure_frequencies))
		. += "<br><b>Supplementary channels:</b>"
		for (var/sayToken in src.secure_frequencies) //Most convoluted string of the year award 2013
			. += "<br>[ headset_channel_lookup["[src.secure_frequencies["[sayToken]"]]"] ? headset_channel_lookup["[src.secure_frequencies["[sayToken]"]]"] : "???" ]: \[[format_frequency(src.secure_frequencies["[sayToken]"])]] (Activator: <b>[sayToken]</b>)"

/obj/item/device/radio/attackby(obj/item/W, mob/user)
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
	w_class = W_CLASS_TINY
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
			START_TRACKING_CAT(TR_CAT_RADIO_JAMMERS)
		else
			boutput(user, "You shut off [src].")
			icon_state = "shieldoff"
			STOP_TRACKING_CAT(TR_CAT_RADIO_JAMMERS)

	disposing()
		if(src in by_cat[TR_CAT_RADIO_JAMMERS])
			STOP_TRACKING_CAT(TR_CAT_RADIO_JAMMERS)
		..()
/obj/item/device/radio/beacon
	name = "tracking beacon"
	icon_state = "beacon"
	item_state = "signaler"
	desc = "A small beacon that is tracked by the Teleporter Computer, allowing things to be sent to its general location."
	burn_possible = 0
	anchored = 1

	attack_hand(mob/user)
		if (src.anchored)
			boutput(user, "You need to unscrew the [src.name] from the floor first!")
			return
		..()

	attackby(obj/item/I, mob/user)
		if (isscrewingtool(I))
			if (src.anchored)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user.visible_message("[user] unscrews [src] from the floor.", "You unscrew [src] from the floor.", "You hear a screwdriver.")
				src.anchored = 0
				return
			else
				if (isturf(src.loc))
					var/turf/T = get_turf(src)
					if (istype(T, /turf/space))
						user.show_text("What exactly are you gonna secure [src] to?", "red")
						return
					else
						playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
						user.visible_message("[user] screws [src] to the floor, anchoring it in place.", "You screw [src] to the floor, anchoring it in place.", "You hear a screwdriver.")
						src.anchored = 1
						return
		..()

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
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	icon_state = "electropack0"
	var/code = 2
	var/on = 0
//	var/e_pads = 0
	frequency = FREQ_TRACKING_IMPLANT
	throw_speed = 1
	throw_range = 3
	w_class = W_CLASS_HUGE
	flags = FPRINT | TABLEPASS | ONBACK | CONDUCT
	item_state = "electropack"
	desc = "A device that, when signaled on the correct frequency, causes a disabling electric shock to be sent to the animal (or human) wearing it."
	cant_self_remove = 1

/*
/obj/item/device/radio/electropack/examine()
	set src in view()
	set category = "Local"

	..()
	if ((in_interact_range(src, usr) || src.loc == usr))
		if (src.e_pads)
			boutput(usr, "<span class='notice'>The electric pads are exposed!</span>")
	return*/

/obj/item/device/radio/electropack/attackby(obj/item/W, mob/user)
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
	if (src in usr || (src.master && (src.master in usr)) || (in_interact_range(src, usr) && istype(src.loc, /turf)))
		src.add_dialog(usr)
		if (href_list["freq"])
			var/new_frequency = sanitize_frequency(frequency + text2num_safe(href_list["freq"]))
			set_frequency(new_frequency)
		else
			if (href_list["code"])
				src.code += text2num_safe(href_list["code"])
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
			logTheThing(LOG_SIGNALERS, usr, "signalled an electropack worn by [constructTarget(M,"signalers")] at [log_loc(M)].") // Added (Convair880).
			if(ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution))
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
	var/code = 30
	w_class = W_CLASS_TINY
	frequency = FREQ_SIGNALER
	has_microphone = FALSE
	var/delay = 0
	var/airlock_wire = null
	desc = "A device used to send a coded signal over a specified frequency, with the effect depending on the device that receives the signal."

/obj/item/device/radio/signaler/ui_data(mob/user)
	. = ..()
	. += list(
		"code" = src.code,
		"sendButton" = TRUE,
		)

obj/item/device/radio/signaler/attackby(obj/item/W, mob/user)
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
		boutput(user, "You open the signaller and cram the [W.name] in there!")
	//Commenting this out so the SWORD PR gets merged without being summonable by normal players, so it can be tested first. Both the MSF and SWORD can still be spawned in with admin powers, obviously.
	//else if (istype(W, /obj/item/cable_coil))
	//	W.amount -= 1
	//	if (W.amount <= 0)
	//		qdel(W)
	//	else
	//		W.inventory_counter.update_number(W.amount)
	//	var/obj/item/makeshift_signaller_frame/A = new /obj/item/makeshift_signaller_frame
	//	user.put_in_hand_or_drop(A)
	//	A.add_fingerprint(user)
	//	boutput(user, "You open the signaller and attach some additional wires to it!")
	//	qdel(src)
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
			logTheThing(LOG_BOMBING, usr, "signalled a radio on a transfer valve at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"].")
			message_admins("[key_name(usr)] signalled a radio on a transfer valve at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"].")
			SEND_SIGNAL(src.master, COMSIG_ITEM_BOMB_SIGNAL_START)

		else if (src.master && istype(src.master, /obj/item/assembly/rad_ignite)) //Radio-detonated beaker assemblies
			var/obj/item/assembly/rad_ignite/RI = src.master
			logTheThing(LOG_BOMBING, usr, "signalled a radio on a radio-igniter assembly at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"]. Contents: [log_reagents(RI.part3)]")
			SEND_SIGNAL(src.master, COMSIG_ITEM_BOMB_SIGNAL_START)

		else if(src.master && istype(src.master, /obj/item/assembly/radio_bomb))	//Radio-detonated single-tank bombs
			logTheThing(LOG_BOMBING, usr, "signalled a radio on a single-tank bomb at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"].")
			message_admins("[key_name(usr)] signalled a radio on a single-tank bomb at [T ? "[log_loc(T)]" : "horrible no-loc nowhere void"].")
			SEND_SIGNAL(src.master, COMSIG_ITEM_BOMB_SIGNAL_START)
		SPAWN(0)
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

	logTheThing(LOG_SIGNALERS, !usr && src.master ? src.master.fingerprintslast : usr, null, "used remote signaller[src.master ? " (connected to [src.master.name])" : ""] at [src.master ? "[log_loc(src.master)]" : "[log_loc(src)]"]. Frequency: [format_frequency(frequency)]/[code].")

	var/datum/signal/signal = get_free_signal()
	signal.source = src
	//signal.encryption = code
	signal.data["code"] = code
	signal.data["message"] = message

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, src.frequency)

	return

/obj/item/device/radio/signaler/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch (action)
		if ("set-code")
			var/newcode = text2num_safe(params["value"])
			newcode = round(newcode)
			newcode = min(100, newcode)
			src.code = max(1, newcode)
			. = TRUE
		if ("send")
			src.send_signal("ACTIVATE")

//////////////////////////////////////////////////
/obj/item/device/radio/intercom/loudspeaker
	name = "Loudspeaker Transmitter"
	icon = 'icons/obj/loudspeakers.dmi'
	icon_state = "transmitter"
	anchored = 1
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

//Must be standing next to it to talk into it
/obj/item/device/radio/intercom/loudspeaker/hear_talk(mob/M as mob, msgs, real_name, lang_id)
	if (src.broadcasting)
		if (BOUNDS_DIST(src, M) == 0)
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
	anchored = 1
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
		..()
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

/obj/item/device/radio/intercom/loudspeaker/attack_self(mob/user as mob)
	return

/obj/item/device/radio/intercom/loudspeaker/speaker/attack_hand(mob/user)
	return

// Lol better dont use these while conspiracy is active. Has an extra frequency for commentators to cooperate over.
/obj/item/device/radio/commentator
	name = "commentator radio"
	icon_state = "radio"
	chat_class = RADIOCL_COMMAND
	locked_frequency = TRUE
	icon_tooltip = "Commentator Radio"

/obj/item/device/radio/headset/commentator
	name = "commentator headset"
	icon_state = "command headset"
	icon_override = "commentator"
	chat_class = RADIOCL_COMMAND
	locked_frequency = TRUE
	icon_tooltip = "Commentator"
	secure_frequencies = list("z" = 555)
	secure_classes = list("z" = RADIOCL_SYNDICATE)
