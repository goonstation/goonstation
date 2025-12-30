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
