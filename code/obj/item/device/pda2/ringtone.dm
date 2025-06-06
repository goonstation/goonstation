/// Ringtone Programs
/datum/computer/file/pda_program/ringtone
	name = "Ringtone"
	size = 4
	/// The list of ringtone datii included in this program. Assoc'd list, "ringtone_ID" = new/datum/ringtone/urtone
	var/list/ring_list = list(
		"ring1" = new/datum/ringtone,
		"ring2" = new/datum/ringtone/thinktronic,
		"ring3" = new/datum/ringtone/thinktronic/quad1,
		"ring4" = new/datum/ringtone/thinktronic/quad2)
	/// The text that goes at the top
	var/topText = "<h4>Thinktronic Systems PDA Sound System Backup</h4>"
	/// The text that goes just under the header
	var/bottomText = "In case you miss the classic."
	/// The text that goes above the list of things
	var/selectText = "Press \"Apply\" to restore the default PDA sound."
	/// The thing that separates each of the entries on the list
	var/dividerThing = "<hr>"
	/// Include an option to override the PDA's alert message?
	var/overrideAlertAllowed = 1
	/// Should this ringtone's own alert message overwrite the PDA's?
	var/overrideAlertMessage = 0
	/// Asks if the PDA should use the ringtone's built-in alert messages instead of the one set by the PDA.
	var/overrideAlertText = "Use this ringtone's ringer message in place of the PDA's?"
	/// Button that makes the PDA display the ringtone's alert messages whenever it gets messaged
	var/overrideAlertYesText = "Yes"
	/// Button that makes the PDA display the PDA's alert messages whenever it gets messaged
	var/overrideAlertNoText = "No"
	/// Which menu should we be in?
	var/subMenu = null
	/// Which ringtone index are we dealing with right now?
	var/selectedRT = null
	/// Which general slot should this ringtone be placed? "alert" or "mailgroup", please. Defaults to main
	var/ringToneGenSlot = null
	/// Where should this ringtone be placed?
	var/ringToneDestSlot = null
	/// Cooldowns
	var/list/cooldowns

	return_text()
		if(..())
			return

		var/dat = src.return_text_header()
		dat += "[src.topText]<br>"
		if(src.bottomText)
			dat += "[src.bottomText]<br><br>"
		if(src.selectText)
			dat += "[src.selectText]<br>"

		dat += "[src.dividerThing]<br><br>"

		switch(src.subMenu)
			if(null)
				src.ringToneGenSlot = null
				src.ringToneDestSlot = null
				src.selectedRT = null
				for(var/RiTo in src.ring_list)
					var/datum/ringtone/ring_tone_temp = src.ring_list[RiTo]
					var/applyLink = "<a href='byond://?src=\ref[src];setSelectedRT=[RiTo]'>[ring_tone_temp.applyText]</a>"
					var/previewLink = "<a href='byond://?src=\ref[src];previewTone=[RiTo]'>[ring_tone_temp.previewText]</a>"
					dat += "[ring_tone_temp.nameText] [ring_tone_temp.name]<br>"
					dat += "[ring_tone_temp.descText] [ring_tone_temp.desc]<br>"
					dat += "[applyLink] | [previewLink]<br><br>"
					dat += "[src.dividerThing]<br><br>"
				dat += "<br><br>"

			if("main_alert_or_mailgroup")
				if(!src.selectedRT)
					src.selectedRT = "ring1"
				var/datum/ringtone/ring_tone_temp = src.ring_list[src.selectedRT]
				var/applyLink = "<a href='byond://?src=\ref[src];applyTone=[src.selectedRT]'>Primary</a>"
				var/alertLink = "<a href='byond://?src=\ref[src];setToneGenSlot=["alert"]'>Alert</a>"
				var/mailLink = "<a href='byond://?src=\ref[src];setToneGenSlot=["mailgroup"]'>Mailgroup</a>"
				dat += "Set [ring_tone_temp] as which ringtone?<br>"
				dat += "[applyLink] | [alertLink] | [mailLink]<br><br>"
				dat += "<br><a href='byond://?src=\ref[src];resetMenu=1'>Cancel</a><br>"
				dat += "[src.dividerThing]<br><br>"

			if("alert")
				if(!src.selectedRT)
					src.selectedRT = "ring1"
				if(!length(src.master.alertgroups) || !length(src.master.alert_ringtones))
					src.subMenu = null
					dat += "Error retrieving alert types. Please refresh the page and contact customer support at 1-800-IMC-ODER."
				else
					var/datum/ringtone/ring_tone_temp = src.ring_list[src.selectedRT]
					dat += "Please select an alert type to use [ring_tone_temp].<br><br>"
					for(var/alert in src.master.alertgroups)
						dat += "<a href='byond://?src=\ref[src];applyTone=[alert]'>[alert]</a><br>"
					dat += "<br><a href='byond://?src=\ref[src];resetMenu=1'>Cancel</a><br>"
					dat += "[src.dividerThing]<br><br>"

			if("mailgroup")
				if(!src.selectedRT)
					src.selectedRT = "ring1"
				if(!length(src.master?.mailgroups))
					src.subMenu = null
					dat += "Error retrieving mailgroups. Please be a part of at least one mailgroup and try again. If this error persists, please contact customer support at 1-800-IMC-ODER."
				else
					var/datum/ringtone/ring_tone_temp = src.ring_list[src.selectedRT]
					dat += "Please select a mailgroup to use [ring_tone_temp].<br><br>"
					for(var/mailgroup in src.master.mailgroups)
						dat += "<a href='byond://?src=\ref[src];applyTone=[mailgroup]'>[mailgroup]</a><br>"
					dat += "<br><a href='byond://?src=\ref[src];resetMenu=1'>Cancel</a><br>"
					dat += "[src.dividerThing]<br><br>"

		if(src.overrideAlertAllowed)
			/// just a shorter var for selection purposes
			var/oam = src.overrideAlertMessage
			var/yes_button = "[src.overrideAlertYesText]"
			var/no_button = "[src.overrideAlertNoText]"
			dat += "[src.overrideAlertText]<br>"
			dat += "[oam ? "[yes_button]" : "<a href='byond://?src=\ref[src];overrideAlertSet=1'>[yes_button]</a>"] | [oam ? "<a href='byond://?src=\ref[src];overrideAlertSet=1'>[no_button]</a>" : "[no_button]"]"

		return dat

	Topic(href, href_list)
		if(..())
			return

		if (href_list["overrideAlertSet"])
			src.overrideAlertMessage = !src.overrideAlertMessage

		else if (href_list["resetMenu"])
			src.ResetTheMenu()

		else if (href_list["setSelectedRT"]) // goto first submenu
			src.selectedRT = href_list["setSelectedRT"]
			src.subMenu = "main_alert_or_mailgroup"

		else if (href_list["setToneGenSlot"]) // from first submenu
			switch(href_list["setToneGenSlot"])
				if("alert")
					src.ringToneGenSlot = "alert"
					src.subMenu = "alert"
				if("mailgroup")
					src.ringToneGenSlot = "mailgroup"
					src.subMenu = "mailgroup"
				else
					src.ResetTheMenu()

		else if (href_list["applyTone"])
			if(!src.selectedRT)
				src.selectedRT = "ring1"
			if(!src.ringToneGenSlot)
				src.ringToneGenSlot = "main"
			src.ringToneDestSlot = href_list["applyTone"]
			var/datum/ringtone/Rtone = src.ring_list[src.selectedRT]
			src.master.set_ringtone(Rtone, 0, src.overrideAlertMessage, src.ringToneGenSlot, src.ringToneDestSlot)
			src.ResetTheMenu()

		else if(href_list["previewTone"])
			if(ON_COOLDOWN(src, "preview_cooldown", 15 SECONDS))
				src.master.display_message("[bicon(master)] Preview sprocket cooling off, please wait [time_to_text(ON_COOLDOWN(src, "preview_cooldown", 0))].")
			else
				var/datum/ringtone/Rtone = src.ring_list[href_list["previewTone"]]
				src.master.set_ringtone(Rtone, 1, src.overrideAlertMessage)
				var/datum/signal/signal = get_free_signal()
				signal.data["command"] = "text_message"
				signal.data["message"] = "[Rtone.previewMessage]"
				signal.data["tag"] = "preview_message"
				signal.data["sender_name"] = "[Rtone.previewSender]"
				signal.data["sender"] = "UNKNOWN"
				signal.data["address_1"] = src.master.net_id
				radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)
			src.ResetTheMenu()

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

	proc/ResetTheMenu()
		src.ringToneGenSlot = null
		src.ringToneDestSlot = null
		src.selectedRT = null
		src.subMenu = null

/datum/computer/file/pda_program/ringtone/dogs
	name = "WOLF PACK"
	size = 4
	ring_list = list("ring1" = new/datum/ringtone/dogs, "ring2" = new/datum/ringtone/dogs/lessdogs)
	topText = "<h1>THE WOLF PACK HOWLTONE PACK</h1>"
	bottomText = "<h3>FOR THE CRANKEST TURBO ULTRA LORDS EVER.</h3>"
	selectText = "<h3>SMASH THAT HOWWWWL FOR FULL WOLF PACK.</h3>"
	dividerThing = "~=~=~=~=~RIDE OR DIE~=~=~=~=~"
	overrideAlertAllowed = 1
	overrideAlertText = "<h3>LET THE DOGS OUT</h3>"
	overrideAlertYesText = "<span class='alert' style='font-size: 1.25em'>AWOO</span>"
	overrideAlertNoText = "No"

/datum/computer/file/pda_program/ringtone/numbers
	name = "Leaptronics Pro"
	size = 4
	ring_list = list("ring1" = new/datum/ringtone/numbers)
	topText = "<h4>Leaptronics PDA Learning System</h4>"
	bottomText = "Dream it. Believe it. Achieve it. For ages 4-6."
	selectText = "Choose a Learnventure!"
	dividerThing = "<hr>"
	overrideAlertAllowed = 1
	overrideAlertText = "Enable encouragement via ringer message."
	overrideAlertYesText = "Yes!"
	overrideAlertNoText = "No"

/datum/computer/file/pda_program/ringtone/clown
	name = "PDA Clowncentials"
	size = 4
	ring_list = list("ring1" = new/datum/ringtone/clown, "ring2" = new/datum/ringtone/clown/horn, "ring3" = new/datum/ringtone/clown/harmonica)
	topText = "<h4>Nooty Tooter's Merrymaker Medley</h4>"
	bottomText = "A collection of ringtones for aspiring ringmasters and ringmistresses."
	selectText = "Choose an act!"
	dividerThing = "<hr>"
	overrideAlertAllowed = 1
	overrideAlertText = "Line reminders?"
	overrideAlertYesText = "Yes"
	overrideAlertNoText = "No"

/datum/computer/file/pda_program/ringtone/basic
	name = "Soultones"
	size = 4
	ring_list = list("ring1" = new/datum/ringtone/basic/ring1,\
									 "ring2" = new/datum/ringtone/basic/ring2,\
									 "ring3" = new/datum/ringtone/basic/ring3,\
									 "ring4" = new/datum/ringtone/basic/ring4,\
									 "ring5" = new/datum/ringtone/basic/ring5,\
									 "ring6" = new/datum/ringtone/basic/ring6,\
									 "ring7" = new/datum/ringtone/basic/ring7,\
									 "ring8" = new/datum/ringtone/basic/ring8,\
									 "ring8" = new/datum/ringtone/basic/ring9,\
									 "ring9" = new/datum/ringtone/basic/ring10)
	topText = "<h4>Celestial Soultones</h4>"
	bottomText = "A collection of bold PDA ringtones to set your spirit at ease..."
	selectText = "Discover your destiny..."
	dividerThing = "<center>~~become your dreams~~~</center>"
	overrideAlertAllowed = 1
	overrideAlertText = "Starkle your PDA ringer?"
	overrideAlertYesText = "Yes"
	overrideAlertNoText = "No"

/// Ringtones by Retkid
/datum/computer/file/pda_program/ringtone/chimes
	name = "Spacechimes"
	size = 4
	ring_list = list("ring1" = new/datum/ringtone/retkid/ring1,\
									 "ring2" = new/datum/ringtone/retkid/ring2,\
									 "ring3" = new/datum/ringtone/retkid/ring3,\
									 "ring4" = new/datum/ringtone/retkid/ring6,\
									 "ring5" = new/datum/ringtone/retkid/ring7)
	topText = "<h4>Spacechime Family</h4>"
	bottomText = "A diverse family of spacechimes. From the Retkid collection."
	selectText = "Choose a set of spacechimes"
	dividerThing = "<hr>"
	overrideAlertAllowed = 1
	overrideAlertText = "PDA Ringer Encouragement?"
	overrideAlertYesText = "Yes"
	overrideAlertNoText = "No"

/// Ringtones also by Retkid
/datum/computer/file/pda_program/ringtone/beepy
	name = "Blipous"
	size = 4
	ring_list = list("ring1" = new/datum/ringtone/retkid,\
									 "ring2" = new/datum/ringtone/retkid/ring4,\
									 "ring3" = new/datum/ringtone/retkid/ring5,\
									 "ring4" = new/datum/ringtone/retkid/ring8,\
									 "ring5" = new/datum/ringtone/retkid/ring9)
	topText = "<h4>Blipous Family Spaceblips</h4>"
	bottomText = "A collection of Blipous family heirloom Spaceblips. From the Retkid collection"
	selectText = "Choose a Spaceblip"
	dividerThing = "<hr>"
	overrideAlertAllowed = 1
	overrideAlertText = "PDA Ringer Spacequips?"
	overrideAlertYesText = "Yes"
	overrideAlertNoText = "No"

/datum/computer/file/pda_program/ringtone/syndie
	name = "SounDreamS PRO"
	size = 28
	ring_list = list("ring1" = new/datum/ringtone/syndie,\
									 "ring2" = new/datum/ringtone/syndie/guns,\
									 "ring3" = new/datum/ringtone/syndie/lasersword)
	topText = "<h4>SounDreamS Professional FX</h4>"
	bottomText = "1001 PROFESSIONAL HI-QUALITY sound effects for use in your projects!"
	selectText = "Pick a sound library:"
	dividerThing = "<hr>"
	overrideAlertAllowed = 1
	overrideAlertText = "Enable Artist Commentary Track?"
	overrideAlertYesText = "Yes"
	overrideAlertNoText = "No"
