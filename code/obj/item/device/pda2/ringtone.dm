/// Ringtone Programs
/datum/computer/file/pda_program/ringtone
	name = "Ringtone"
	size = 10
	/// The list of ringtone datii included in this program. Assoc'd list, "ringtone_ID" = new/datum/ringtone/urtone
	var/list/ring_list = list("ring1" = new/datum/ringtone)
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
	/// The text that asks the user whether to override the alert messages or not
	var/overrideAlertText = "Use default ringer message?"
	/// The text that indicates an affirmative for overriding the alert text
	var/overrideAlertYesText = "Yes"
	/// The text that indicates a negative for overriding the alert text
	var/overrideAlertNoText = "No"


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

		for(var/RiTo in src.ring_list)
			var/datum/ringtone/ring_tone_temp = src.ring_list[RiTo]
			var/applyLink = "<a href='?src=\ref[src];applyTone=[RiTo]'>[ring_tone_temp.applyText]</a>"
			var/previewLink = "<a href='?src=\ref[src];previewTone=[RiTo]'>[ring_tone_temp.previewText]</a>"
			dat += "[ring_tone_temp.nameText] [ring_tone_temp.name]<br>"
			dat += "[ring_tone_temp.descText] [ring_tone_temp.desc]<br>"
			dat += "[applyLink] | [previewLink]<br><br>"
			dat += "[src.dividerThing]<br><br>"

		dat += "<br><br>"

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

		else if (href_list["applyTone"])
			var/datum/ringtone/Rtone = src.ring_list[href_list["applyTone"]]
			src.master.set_ringtone(Rtone, 0, src.overrideAlertMessage)

		else if(href_list["previewTone"])
			var/datum/ringtone/Rtone = src.ring_list[href_list["previewTone"]]
			src.master.set_ringtone(Rtone, 1, src.overrideAlertMessage)
			var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
			var/datum/signal/signal = get_free_signal()
			signal.data["command"] = "text_message"
			signal.data["message"] = "[Rtone.previewMessage]"
			signal.data["tag"] = "preview_message"
			signal.data["sender_name"] = "[Rtone.previewSender]"
			signal.data["sender"] = "UNKNOWN"
			signal.data["address_1"] = src.master.net_id
			signal.transmission_method = TRANSMISSION_RADIO
			transmit_connection.post_signal(null, signal)

		src.master.add_fingerprint(usr)
		src.master.updateSelfDialog()
		return

/datum/computer/file/pda_program/ringtone/dogs
	name = "WOLF PACK"
	size = 10
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
	size = 10
	ring_list = list("ring1" = new/datum/ringtone/numbers)
	topText = "<h4>Leaptronics PDA Learning System</h4>"
	bottomText = "Dream it. Believe it. Achieve it. For ages 4-6."
	selectText = "Choose a Learnventure!"
	dividerThing = "<hr>"
	overrideAlertAllowed = 1
	overrideAlertText = "Enable encouragement."
	overrideAlertYesText = "Yes!"
	overrideAlertNoText = "No"

/datum/computer/file/pda_program/ringtone/clown
	name = "PDA Clowncentials"
	size = 10
	ring_list = list("ring1" = new/datum/ringtone/clown, "ring2" = new/datum/ringtone/clown/horn, "ring3" = new/datum/ringtone/clown/harmonica)
	topText = "<h4>Nooty Tooter's Merrymaker Medley</h4>"
	bottomText = "A collection of ringtones for aspiring ringmasters and ringmistresses."
	selectText = "Choose an act!"
	dividerThing = "<hr>"
	overrideAlertAllowed = 1
	overrideAlertText = "Line reminders?"
	overrideAlertYesText = "Yes"
	overrideAlertNoText = "No"

/datum/computer/file/pda_program/ringtone/syndie
	name = "SounDreamS PRO"
	size = 28
	ring_list = list("ring1" = new/datum/ringtone/syndie, "ring2" = new/datum/ringtone/syndie/guns, "ring3" = new/datum/ringtone/syndie/lasersword)
	topText = "<h4>SounDreamS Professional FX</h4>"
	bottomText = "1001 PROFESSIONAL HI-QUALITY sound effects for use in your projects!"
	selectText = "Pick a sound library:"
	dividerThing = "<hr>"
	overrideAlertAllowed = 1
	overrideAlertText = "Artist commentary?"
	overrideAlertYesText = "Yes"
	overrideAlertNoText = "No"
