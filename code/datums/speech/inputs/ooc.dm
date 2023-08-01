TYPEINFO(/datum/listen_module/input/ooc)
	id = "ooc"
/datum/listen_module/input/ooc
	id = "ooc"
	channel = SAY_CHANNEL_OOC

	process(datum/say_message/message)
		var/mob/mob_speaker = null
		if(istype(message.speaker, /mob))
			mob_speaker = message.speaker
		if (mob_speaker?.client?.preferences && !mob_speaker.client.preferences.listen_ooc)
			return null
		. = ..()

	format(datum/say_message/message)
		var/display_name = message.speaker.name

		var/mob/mob_speaker = null
		if(istype(message.speaker, /mob))
			mob_speaker = message.speaker
			display_name = mob_speaker.key

		var/mob/mob_listener = null
		if(istype(src.parent_tree.parent, /mob))
			mob_listener = src.parent_tree.parent

		var/ooc_class = ""
		var/ooc_icon = null

		if (mob_speaker?.client?.stealth || mob_speaker?.client?.alt_key)
			if (mob_listener?.client?.holder)
				display_name = mob_speaker.client.fakekey
			else
				display_name += " (as [mob_speaker.client.fakekey])"

		if (mob_speaker?.client?.holder && (!mob_speaker.client.stealth || mob_listener?.client.holder))
			if (mob_speaker?.client?.holder.level == LEVEL_BABBY)
				ooc_class = "gfartooc"
			else
				ooc_class = "adminooc"
		else if (mob_speaker?.client?.is_mentor() && !mob_speaker?.client?.stealth)
			ooc_class = "mentorooc"
		else if (src.client.player.is_newbee)
				ooc_class = "newbeeooc"
				ooc_icon = "Newbee"

		var/rendered = "<span class=\"ooc [ooc_class]\"><span class=\"prefix\">OOC:</span> <span class=\"name\" data-ctx='\ref[src.mind]'>[display_name]:</span> <span class=\"message\">[msg]</span></span>"


		if( mob_speaker?.client?.cloud_available() && mob_speaker?.client?.cloud_get("donor") )
			message.content = replacetext(message.content, ":shelterfrog:", "<img src='http://stuff.goonhub.com/shelterfrog.png' width=32>")

		if (mob_speaker?.client?.has_contestwinner_medal)
			message.content = replacetext(message.content, ":shelterbee:", "<img src='http://stuff.goonhub.com/shelterbee.png' width=32>")

		var/rendered = "<span class=\"ooc [ooc_class]\"><span class=\"prefix\">OOC:</span> <span class=\"name\" data-ctx='\ref[mob_speaker?.mind]'>[display_name]:</span> <span class=\"message\">[message.content]</span></span>"
		if (ooc_icon)
			rendered = {"
			<div class='tooltip'>
				<img class=\"icon misc\" style=\"position: relative; bottom: -3px; \" src=\"[resource("images/radio_icons/[ooc_icon].png")]\">
				<span class="tooltiptext">[ooc_icon]</span>
			</div>
			"} + rendered

		if (mob_listener?.client?.holder)
			rendered = "<span class='adminHearing' data-ctx='[mob_listener?.client?.chatOutput.getContextFlags()]'>[rendered]</span>"
		return rendered


TYPEINFO(/datum/listen_module/input/looc)
	id = "looc"
/datum/listen_module/input/looc
	id = "looc"
	channel = SAY_CHANNEL_LOOC

	process(datum/say_message/message)
		var/mob/mob_speaker = null
		if(istype(message.speaker, /mob))
			mob_speaker = message.speaker
		if (mob_speaker?.client?.preferences && !mob_speaker.client.preferences.listen_looc)
			return null

		var/mob/mob_listener = null
		if(istype(src.parent_tree.parent, /mob))
			mob_listener = src.parent_tree.parent

			if (!IN_RANGE(mob_listener, message.speaker, LOOC_RANGE)) // is in range to hear looc
				if (!mob_listener.client?.holder || (!mob_listener.client?.only_local_looc || mob_listener.client?.player_mode)) // is admin with global looc enabled and not in player mode
					return null

		//LOOC maptext
		if (mob_speaker.client?.holder && !mob_speaker.client.stealth)
			if (mob_speaker.client.holder.level == LEVEL_BABBY)
				message.maptext_css_values["color"] = "#4cb7db"
			else
				message.maptext_css_values["color"] = "#cd6c4c"
		else if (mob_speaker.client?.is_mentor() && !mob_speaker.client.stealth)
			message.maptext_css_values["color"] = "#a24cff"

		. = ..()

	format(datum/say_message/message)
		var/display_name = message.speaker.name

		var/mob/mob_speaker = null
		if(istype(message.speaker, /mob))
			mob_speaker = message.speaker
			display_name = mob_speaker.key

		var/mob/mob_listener = null
		if(istype(src.parent_tree.parent, /mob))
			mob_listener = src.parent_tree.parent

		var/ooc_class = ""
		var/ooc_icon = null

		if (mob_speaker?.client?.stealth || mob_speaker?.client?.alt_key)
			if (mob_listener?.client?.holder)
				display_name = mob_speaker.client.fakekey
			else
				display_name += " (as [mob_speaker.client.fakekey])"

		if (mob_speaker?.client?.holder && (!mob_speaker.client.stealth || mob_listener?.client.holder))
			if (mob_speaker?.client?.holder.level == LEVEL_BABBY)
				ooc_class = "gfartooc"
			else
				ooc_class = "adminooc"
		else if (mob_speaker?.client?.is_mentor() && !mob_speaker?.client?.stealth)
			ooc_class = "mentorooc"
		else if (src.client.player.is_newbee)
				ooc_class = "newbeeooc"
				ooc_icon = "Newbee"


		var/rendered = "<span class=\"looc [ooc_class]\"><span class=\"prefix\">LOOC:</span> <span class=\"name\" data-ctx='\ref[mob_speaker?.mind]'>[display_name]:</span> <span class=\"message\">[message.content]</span></span>"
		if (ooc_icon)
			rendered = {"
			<div class='tooltip'>
				<img class=\"icon misc\" style=\"position: relative; bottom: -3px; \" src=\"[resource("images/radio_icons/[ooc_icon].png")]\">
				<span class="tooltiptext">[ooc_icon]</span>
			</div>
			"} + rendered

		if (mob_listener?.client?.holder)
			rendered = "<span class='adminHearing' data-ctx='[mob_listener?.client?.chatOutput.getContextFlags()]'>[rendered]</span>"
		return rendered
