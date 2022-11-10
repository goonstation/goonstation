/obj/item/device/radio/intercom
	name = "Station Intercom (Radio)"
#ifndef IN_MAP_EDITOR
	icon_state = "intercom"
#else
	icon_state = "intercom-map"
#endif
	anchored = 1
	plane = PLANE_NOSHADOW_ABOVE
	mats = 3
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WIRECUTTERS | DECON_MULTITOOL
	chat_class = RADIOCL_INTERCOM
	var/number = 0
	rand_pos = 0
	desc = "A wall-mounted radio intercom, used to communicate with the specified frequency. Usually turned off except during emergencies."
	hardened = 0

/obj/item/device/radio/intercom/proc/update_pixel_offset_dir(obj/item/AM, old_dir, new_dir)
	src.pixel_x = 0
	src.pixel_y = 0
	switch(new_dir)
		if(NORTH)
			src.pixel_y = -21
		if(SOUTH)
			src.pixel_y = 24
		if(EAST)
			src.pixel_x = -21
		if(WEST)
			src.pixel_x = 21

/obj/item/device/radio/intercom/New()
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGED, .proc/update_pixel_offset_dir)
	if(src.icon_state == "intercom") // if something overrides the icon we don't want this
		var/image/screen_image = image(src.icon, "intercom-screen")
		screen_image.color = src.device_color
		if(src.device_color == RADIOC_INTERCOM || isnull(src.device_color)) // unboringify the colour if default
			var/new_color = default_frequency_color(src.frequency)
			if(new_color)
				screen_image.color = new_color
		screen_image.alpha = 180
		src.UpdateOverlays(screen_image, "screen")
		if(src.pixel_x == 0 && src.pixel_y == 0)
			update_pixel_offset_dir(src,null,src.dir)

/obj/item/device/radio/intercom/ui_state(mob/user)
	return tgui_default_state

/obj/item/device/radio/intercom/attack_ai(mob/user as mob)
	src.add_fingerprint(user)
	SPAWN(0)
		attack_self(user)

/obj/item/device/radio/intercom/attack_hand(mob/user)
	src.add_fingerprint(user)
	SPAWN(0)
		attack_self(user)

/obj/item/device/radio/intercom/send_hear()
	if (src.listening)
		return hearers(7, src.loc)

/obj/item/device/radio/intercom/showMapText(var/mob/target, var/mob/sender, receive, msg, secure, real_name, lang_id, textLoc)
	if (!isAI(sender) || isdead(sender) || (frequency == R_FREQ_DEFAULT))
		..() // we also want the AI to be able to tune to any intercom and have maptext, but not the main radio (1459) because of spam
		return
	var/maptext = generateMapText(msg, textLoc, style = "color:#7F7FE2;", alpha = 255)
	target.show_message(type = 2, just_maptext = TRUE, assoc_maptext = maptext)

// -------------------- VR --------------------
/obj/item/device/radio/intercom/virtual
	desc = "Virtual radio for all your beeps and bops."
#ifndef IN_MAP_EDITOR
	icon = 'icons/effects/VR.dmi'
#endif
	protected_radio = 1
// --------------------------------------------

// ** preset intercoms to make mapping suck less augh **

/obj/item/device/radio/intercom/medical
	name = "Medical Intercom"
	frequency = R_FREQ_INTERCOM_MEDICAL
	broadcasting = 0
	device_color = "#0093FF"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/security
	name = "Security Intercom"
	frequency = R_FREQ_INTERCOM_SECURITY
	broadcasting = 0
	device_color = "#FF2000"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/brig
	name = "Brig Intercom"
	frequency = R_FREQ_INTERCOM_BRIG
	broadcasting = 0
	device_color = "#FF5000"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/science
	name = "Research Intercom"
	frequency = R_FREQ_INTERCOM_RESEARCH
	broadcasting = 0
	device_color = "#C652CE"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/engineering
	name = "Engineering Intercom"
	frequency = R_FREQ_INTERCOM_ENGINEERING
	broadcasting = 0
	device_color = "#BBBB00"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/cargo
	name = "Cargo Intercom"
	frequency = R_FREQ_INTERCOM_CARGO
	broadcasting = 0
	device_color = "#9A8B0D"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/catering
	name = "Catering Intercom"
	frequency = R_FREQ_INTERCOM_CATERING
	broadcasting = 0
	device_color = "#C16082"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/botany
	name = "Botany Intercom"
	frequency = R_FREQ_INTERCOM_BOTANY
	broadcasting = 0
	device_color = "#78ee48"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/AI
	name = "AI Intercom"
	frequency = R_FREQ_INTERCOM_AI
	broadcasting = 1
	device_color = "#7F7FE2"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/bridge
	name = "Bridge Intercom"
	frequency = R_FREQ_INTERCOM_BRIDGE
	broadcasting = 1
	device_color = "#339933"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/syndicate
	name = "Syndicate Intercom"
	frequency = R_FREQ_SYNDICATE
	broadcasting = TRUE
	device_color = "#820A16"
	hardened = TRUE

	initialize()
		if(istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/N = ticker.mode
			if(N.agent_radiofreq)
				set_frequency(N.agent_radiofreq)
		else
			set_frequency(frequency)

// -------------------- DetNet --------------------
/obj/item/device/radio/intercom/detnet
	name = "DetNet Intercom (General)"
	locked_frequency = TRUE
	device_color = RADIOC_STANDARD
	layer = 3.2

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/detnet/security
	name = "DetNet Intercom (Security)"
	frequency = R_FREQ_SECURITY
	secure_frequencies = list("g" = R_FREQ_SECURITY)
	secure_classes = list("g" = R_FREQ_SECURITY)
	device_color = RADIOC_SECURITY
	layer = 3.1

	initialize()
		set_frequency(frequency)
		set_secure_frequencies(src)

/obj/item/device/radio/intercom/detnet/detective
	name = "DetNet Intercom (???)"
	frequency = R_FREQ_DETECTIVE
	secure_frequencies = list("d" = R_FREQ_DETECTIVE)
	secure_classes = list("d" = R_FREQ_DETECTIVE)
	device_color = RADIOC_DETECTIVE
	layer = 3

	initialize()
		set_frequency(frequency)
		set_secure_frequencies(src)
// ------------------------------------------------

////// adventure area intercoms

/obj/item/device/radio/intercom/adventure/owlery
	name = "Owlery Intercom"
	frequency = R_FREQ_INTERCOM_OWLERY
	locked_frequency = TRUE
	broadcasting = 0
	device_color = "#3344AA"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/adventure/syndcommand
	name = "Suspicious Intercom"
	frequency = R_FREQ_INTERCOM_SYNDCOMMAND
	locked_frequency = TRUE
	broadcasting = 1
	device_color = "#BB3333"

	initialize()
		set_frequency(frequency)


/obj/item/device/radio/intercom/adventure/wizards
	name = "SWF Intercom"
	frequency = R_FREQ_INTERCOM_WIZARD
	broadcasting = 1
	device_color = "#3333AA"

	initialize()
		set_frequency(frequency)
