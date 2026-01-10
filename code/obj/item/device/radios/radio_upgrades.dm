TYPEINFO(/obj/item/device/radio_upgrade)
	mats = 12

/obj/item/device/radio_upgrade //traitor radio upgrader
	name = "wiretap radio upgrade"
	desc = "An illegal device capable of picking up and sending all secure station radio signals, along with a secure Syndicate frequency. Can be installed in a radio headset. Does not actually work by wiretapping."
	icon = 'icons/obj/items/radio_upgrades.dmi'
	icon_state = "wiretap"
	w_class = W_CLASS_TINY
	is_syndicate = 1
	var/secure_frequencies = list(
		"h" = R_FREQ_COMMAND,
		"g" = R_FREQ_SECURITY,
		"e" = R_FREQ_ENGINEERING,
		"r" = R_FREQ_RESEARCH,
		"m" = R_FREQ_MEDICAL,
		"c" = R_FREQ_CIVILIAN,
		"z" = R_FREQ_SYNDICATE,
		)
	var/secure_classes = list()

	conspirator
		name = "private radio channel upgrade"
		desc = "A device capable of communicating over a private secure radio channel. Can be installed in a radio headset."
		secure_frequencies = null
		secure_classes = null

		New()
			..()
			var/datum/game_mode/conspiracy/C = new /datum/game_mode/conspiracy
			if (ticker?.mode && istype(ticker.mode, /datum/game_mode/conspiracy))
				C = ticker.mode
			src.secure_frequencies = list("z" = C.agent_radiofreq)
			src.secure_classes = list("z" = RADIOCL_SYNDICATE)

	gang
		name = "private radio channel upgrade"
		desc = "A device capable of communicating over a private secure radio channel. Can be installed in a radio headset."
		secure_frequencies = null
		secure_classes = null

		New(turf/newLoc, var/frequency)
			..()
			if (!frequency)
				return

			src.secure_frequencies = list("z" = frequency)
			src.secure_classes = list("z" = RADIOCL_SYNDICATE)

	// Crimers gotta crime
	syndicatechannel
		name = "syndicate radio channel upgrade"
		desc = "A device capable of upgrading a headset to allow access over the syndicate radio channel"
		icon_state = "syndicate"
		secure_frequencies = list("z" = R_FREQ_SYNDICATE)

	// For the super crimers (admin shenanigans)
	nanotrasen
		name = "nanotrasen radio channel upgrade"
		desc = "A device capable of upgrading a headset to allow access over the Nanotrasen radio channel"
		icon_state = "nanotrasen"
		secure_frequencies = list("n" = R_FREQ_NANOTRASEN)

ABSTRACT_TYPE(/obj/item/device/radio_upgrade/station)
/obj/item/device/radio_upgrade/station
	name = "youshouldntseeme radio upgrade"
	desc = "The abstract version of the station radio upgrade, you shouldn't be seeing this."
	icon_state = "civilian"
	is_syndicate = FALSE
	secure_frequencies = list()

/obj/item/device/radio_upgrade/station/command
	name = "command radio upgrade"
	desc = "A device capable of upgrading a headset to allow access over the Command radio channel. Can be installed in a radio headset."
	icon_state = "command"
	secure_frequencies = list("h" = R_FREQ_COMMAND)

/obj/item/device/radio_upgrade/station/security
	name = "security radio upgrade"
	desc = "A device capable of upgrading a headset to allow access over the Security radio channel. Can be installed in a radio headset."
	icon_state = "security"
	secure_frequencies = list("g" = R_FREQ_SECURITY)

/obj/item/device/radio_upgrade/station/engineering
	name = "engineering radio upgrade"
	desc = "A device capable of upgrading a headset to allow access over the Engineering radio channel. Can be installed in a radio headset."
	icon_state = "engineering"
	secure_frequencies = list("e" = R_FREQ_ENGINEERING)

/obj/item/device/radio_upgrade/station/research
	name = "research radio upgrade"
	desc = "A device capable of upgrading a headset to allow access over the Research radio channel. Can be installed in a radio headset."
	icon_state = "research"
	secure_frequencies = list("r" = R_FREQ_RESEARCH)

/obj/item/device/radio_upgrade/station/medical
	name = "medical radio upgrade"
	desc = "A device capable of upgrading a headset to allow access over the Medical radio channel. Can be installed in a radio headset."
	icon_state = "medical"
	secure_frequencies = list("m" = R_FREQ_MEDICAL)

/obj/item/device/radio_upgrade/station/civilian
	name = "civilian radio upgrade"
	desc = "A device capable of upgrading a headset to allow access over the Civilian radio channel. Can be installed in a radio headset."
	icon_state = "civilian"
	secure_frequencies = list("c" = R_FREQ_CIVILIAN)
