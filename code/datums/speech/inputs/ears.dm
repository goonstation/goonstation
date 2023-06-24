TYPEINFO(/datum/listen_module/input/ears)
	id = "ears"
/datum/listen_module/input/ears
	id = "ears"
	channel = SAY_CHANNEL_OUTLOUD
	var/hearing_range = 5
	var/my_prefix = null

	process(datum/say_message/message)
		//if we have a prefix set and this message doesn't match it
		if(src.my_prefix != null && message.prefix != src.my_prefix && !(islist(src.my_prefix) && (message.prefix in src.my_prefix)))
			return null

		//range 0 means it's only audible if it's from inside you (ie radios, direct messages)
		if(message.heard_range == 0 && (src.parent_tree.parent == message.speaker.loc))
			.=..()
		//first check if it's possible that the turfs the speaker and listener are stood on could have heard eachother
		if(IN_RANGE(src.parent_tree.parent, message.speaker, src.hearing_range))
			//if listener and speaker are stood on a turf that is in range, do normal hearing
			if(isturf(src.parent_tree.parent.loc) && isturf(message.speaker.loc))
				if(src.parent_tree.parent in viewers(min(message.heard_range, src.hearing_range), message.speaker)) // view? viewers? hearers?
					.=..()
				else if((message.flags & SAYFLAG_WHISPER) && (src.parent_tree.parent in viewers(src.hearing_range, message.speaker))) //we didn't quite hear it because it was whispered
					message.content = stars(message.content)
					.=..()
			else
				//speaker is inside something or listener is, or both.
				//if it's a whisper, we can only hear it if we're in the same place
				if((message.flags & SAYFLAG_WHISPER) && (src.parent_tree.parent != message.speaker.loc))
					return null
				//get relative muffling between them
				var/atom/movable/speaker_loc = message.speaker.loc
				var/relative_thickness = 0
				var/matched_loc = FALSE
				var/atom/movable/outermost = null
				while(!isturf(speaker_loc))
					outermost = speaker_loc
					if(speaker_loc == src.parent_tree.parent.loc)
						matched_loc = TRUE
						break
					else
						relative_thickness += speaker_loc.soundproofing
						speaker_loc = speaker_loc.loc
				if(!matched_loc) //we're not in the same box
					var/atom/movable/hearer_loc = src.parent_tree.parent.loc
					while(!isturf(hearer_loc))
						relative_thickness += hearer_loc.soundproofing
						hearer_loc = hearer_loc.loc

				if(isnull(outermost) || relative_thickness < 0 || matched_loc & relative_thickness == 0)
					message.speaker_location_text = ""
				else if (relative_thickness == 0)
					message.speaker_location_text = "(on [bicon(outermost)] [outermost])"
				else if (relative_thickness < 10)
					message.speaker_location_text = "(inside [bicon(outermost)] [outermost])"
				else if (relative_thickness < 20)
					message.card_ident = null //muffled voicetype - hacky, use a flag instead
					message.speaker_location_text = "muffled (inside [bicon(outermost)] [outermost])"
				else
					return null //too thick to hear message
				.=..()



	format(datum/say_message/message)
		//because radio messages need to impart a little extra info, but they are heard like any spoken message, we do that formatting here conditionally
		if(message.flags & SAYFLAG_RADIO_SENT)
			//radio message

			// Alright, this code is heinous and definitely needs redoing, but I'm already reworking the entirety of speech so this can be a future job
			// for some poor sap (probably me)
			// I basically just copy pasted this from /obj/item/radio and hacked it in to working form. it's bad.
			var/rendered = ""
			var/obj/item/device/radio/radio_speaker = message.speaker
			if(!istype(radio_speaker))
				CRASH("A radio message seems to have been spoken by a thing that wasn't a radio. Fuck.")

			// Gets the various decorators for the message, like icons, colours, special formatting
			var/secure = null
			var/display_freq = radio_speaker.frequency
			var/prefix = copytext(message.prefix, 2, length(message.prefix)+1) //strip : from the prefix
			if(radio_speaker.secure_frequencies && length(message.prefix) > 1)
				secure = radio_speaker.secure_frequencies[prefix]
			var/textColor = secure ? null : radio_speaker.device_color
			var/classes = ""
			if(radio_speaker.chat_class)
				classes = " [radio_speaker.chat_class]"
			if (secure)
				display_freq = radio_speaker.secure_frequencies[prefix]
				if(prefix in radio_speaker.secure_classes)
					classes = " [radio_speaker.secure_classes[prefix]]"
				else
					classes = " [radio_speaker.secure_classes[1]]"
				textColor = radio_speaker.secure_colors[prefix]
				if (!textColor)
					if (radio_speaker.secure_colors.len)
						textColor = radio_speaker.secure_colors[1]
			var/css_style = ""
			if(textColor)
				css_style = " style='color: [textColor]'"
			var/part_a
			if (ismob(message.ident_speaker) && message.ident_speaker:mind)
				part_a = "<span class='radio[classes]'[css_style]>[radio_speaker.radio_icon(message.ident_speaker)]<span class='name' data-ctx='\ref[message.ident_speaker:mind]'>"
			else
				part_a = "<span class='radio[classes]'[css_style]>[radio_speaker.radio_icon(message.ident_speaker)]<span class='name'>"
			var/part_b = "</span><b> \[[format_frequency(display_freq)]\]</b> <span class='message'>"
			var/part_c = "</span></span>"

			// grab the job ID from the message's ident_speaker
			var/eqjobname = ""
			if (ishuman(message.ident_speaker))
				var/mob/living/carbon/human/H = message.ident_speaker
				if (H.wear_id)
					eqjobname = H.wear_id:assignment
				else
					eqjobname = "No ID"
			else if (isAI(message.ident_speaker))
				eqjobname = "AI"
			else if (isrobot(message.ident_speaker))
				eqjobname = "Cyborg"
			else if (istype(message.ident_speaker, /obj/machinery/computer)) // :v
				eqjobname = "Computer"
			else
				eqjobname = "Unknown"

			// Display the message
			if(message.voice_ident != message.card_ident)
				if(message.card_ident)
					rendered = "[part_a][message.card_ident][part_b][message.say_verb], \"[message.content]\"[part_c]"
				else
					rendered = "[part_a][message.voice_ident][part_b][message.say_verb], \"[message.content]\"[part_c]"

			var/mob/recieve_mob = src.parent_tree.parent
			if(istype(recieve_mob))
				if (recieve_mob.isAIControlled())
					rendered = "[part_a]<a href='?src=\ref[src];track3=[message.real_ident];track2=\ref[recieve_mob];track=\ref[message.ident_speaker]'>[message.real_ident] ([eqjobname]) </a>[part_b][message.say_verb], \"[message.content]\"[part_c]"

				if (recieve_mob.client && recieve_mob.client.holder && ismob(message.ident_speaker) && message.ident_speaker:mind)
					rendered = "<span class='adminHearing' data-ctx='[recieve_mob.client.chatOutput.getContextFlags()]'>[rendered]</span>"
			return rendered
		else
			//normal spoken message
			.=..() //just do default behaviour

TYPEINFO(/datum/listen_module/input/ears/intercom)
	id = "intercom_mic"
/datum/listen_module/input/ears/intercom
	id = "intercom_mic"
	my_prefix = ":in"
	hearing_range = 1

	process(datum/say_message/message)
		if(message.flags & SAYFLAG_RADIO_SENT)
			return null //don't retransmit messages you heard from radios
		..()
