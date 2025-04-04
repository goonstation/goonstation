TYPEINFO(/obj/item/device/radio/intercom)
	mats = 3
	start_speech_modifiers = list(SPEECH_MODIFIER_INTERCOM)

/obj/item/device/radio/intercom
	name = "Station Intercom (Radio)"
#ifndef IN_MAP_EDITOR
	icon_state = "intercom"
#else
	icon_state = "intercom-map"
#endif
	anchored = ANCHORED
	plane = PLANE_NOSHADOW_ABOVE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WIRECUTTERS | DECON_MULTITOOL
	chat_class = RADIOCL_INTERCOM
	var/number = 0
	rand_pos = 0
	desc = "A wall-mounted radio intercom, used to communicate with the specified frequency. Usually turned off except during emergencies."
	hardened = 0
	use_speech_bubble = TRUE

	HELP_MESSAGE_OVERRIDE("Stand next to an intercom and use the prefix <B> :in </B> to speak directly into it.")

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
	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGED, PROC_REF(update_pixel_offset_dir))
	if(src.icon_state == "intercom") // if something overrides the icon we don't want this
		var/image/screen_image = image(src.icon, "intercom-screen")
		screen_image.color = src.device_color
		if(src.device_color == RADIOC_INTERCOM || isnull(src.device_color)) // unboringify the colour if default
			var/new_color = default_frequency_color(src.frequency)
			if(new_color)
				screen_image.color = new_color
		screen_image.alpha = 180
		src.AddOverlays(screen_image, "screen")
		if(src.pixel_x == 0 && src.pixel_y == 0)
			update_pixel_offset_dir(src,null,src.dir)

/obj/item/device/radio/intercom/ui_state(mob/user)
	return tgui_default_state

/obj/item/device/radio/intercom/attack_ai(mob/user as mob)
	src.add_fingerprint(user)
	SPAWN(0)
		src.AttackSelf(user)

/obj/item/device/radio/intercom/attack_hand(mob/user)
	src.add_fingerprint(user)
	SPAWN(0)
		src.AttackSelf(user)

/obj/item/device/radio/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/reagent_containers/food/fish))
		if(src.dir == SOUTH)
			user.visible_message("<b><span class='hint'>[user] shoves the fish over the intercom, and then mounts the whole thing on a board \
				which they conveniently had.</span></b>", "<b><span class='hint'>You shove the fish over the intercom, and then mount the whole thing on a board \
				which you conveniently had.</span></b>")

			new /obj/item/device/radio/intercom/fish(src.loc, src)
			playsound(src.loc, pick('sound/impact_sounds/Slimy_Hit_1.ogg', 'sound/impact_sounds/Slimy_Hit_2.ogg'), 50, 1, -1)
			user.drop_item(W)
			qdel(W)
			qdel(src)
		else
			boutput(user, SPAN_ALERT("Looks like the fish won't fit over an intercom facing that way."))
		return
	. = ..()

/obj/item/device/radio/intercom/receive_silicon_hotkey(var/mob/user)
	..()

	if (!isAI(user))
		return

	if (!isAIeye(user))
		boutput(user, "Deploy to an AI Eye first to override intercoms.")
		return

	if(user.client.check_key(KEY_BOLT))
		if (src.locked_frequency)
			boutput(user, SPAN_ALERT("You can't override an intercom with a locked frequency!"))
			return

		var/original_src_frequency = src.frequency
		var/original_microphone_enabled = src.microphone_enabled
		var/original_speaker_enabled = src.speaker_enabled

		src.locked_frequency = TRUE // lockdown; saves us from clickspam
		var/mob/living/intangible/aieye/eye = user
		src.set_frequency(eye.mainframe.radio2.frequency)
		src.toggle_microphone(TRUE)
		src.toggle_speaker(TRUE)

		var/message_params = list(
			"say_sound" = 'sound/misc/talk/bottalk_3.ogg',
			"maptext_css_values" = list("color" = "#CC3FCC"),
			"relay_flags" = SAY_RELAY_RADIO,
		)
		src.say("AI override engaged!", flags = 0, message_params = message_params)
		src.show_speech_bubble(image('icons/mob/mob.dmi', "ai"))

		SPAWN(1 MINUTE)
			src.locked_frequency = FALSE // safe as long as we can't control locked frequencies in the first place
			src.set_frequency(original_src_frequency)
			src.toggle_microphone(original_microphone_enabled)
			src.toggle_speaker(original_speaker_enabled)

// -------------------- VR --------------------
/obj/item/device/radio/intercom/virtual
	desc = "Virtual radio for all your beeps and bops."
#ifndef IN_MAP_EDITOR
	icon = 'icons/effects/VR.dmi'
#endif
	protected_radio = TRUE
// --------------------------------------------

// ** preset intercoms to make mapping suck less augh **

/obj/item/device/radio/intercom/medical
	name = "Medical Intercom"
	frequency = R_FREQ_INTERCOM_MEDICAL
	initial_microphone_enabled = FALSE
	device_color = "#0093FF"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/security
	name = "Security Intercom"
	frequency = R_FREQ_INTERCOM_SECURITY
	initial_microphone_enabled = FALSE
	device_color = "#FF2000"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/brig
	name = "Brig Intercom"
	frequency = R_FREQ_INTERCOM_BRIG
	initial_microphone_enabled = FALSE
	device_color = "#FF5000"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/science
	name = "Research Intercom"
	frequency = R_FREQ_INTERCOM_RESEARCH
	initial_microphone_enabled = FALSE
	device_color = "#C652CE"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/engineering
	name = "Engineering Intercom"
	frequency = R_FREQ_INTERCOM_ENGINEERING
	initial_microphone_enabled = FALSE
	device_color = "#BBBB00"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/cargo
	name = "Cargo Intercom"
	frequency = R_FREQ_INTERCOM_CARGO
	initial_microphone_enabled = FALSE
	device_color = "#9A8B0D"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/mining
	name = "Mining Intercom"
	frequency = R_FREQ_INTERCOM_MINING
	broadcasting = FALSE
	device_color = "#6b4e0b"

	initialize(player_caused_init)
		. = ..()
		src.set_frequency(frequency)

/obj/item/device/radio/intercom/catering
	name = "Catering Intercom"
	frequency = R_FREQ_INTERCOM_CATERING
	initial_microphone_enabled = FALSE
	device_color = "#C16082"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/botany
	name = "Botany Intercom"
	frequency = R_FREQ_INTERCOM_BOTANY
	initial_microphone_enabled = FALSE
	device_color = "#78ee48"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/AI
	name = "AI Intercom"
	frequency = R_FREQ_INTERCOM_AI
	initial_microphone_enabled = TRUE
	device_color = "#7F7FE2"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/bridge
	name = "Bridge Intercom"
	frequency = R_FREQ_INTERCOM_BRIDGE
	initial_microphone_enabled = TRUE
	device_color = "#339933"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/syndicate
	name = "Syndicate Intercom"
	frequency = R_FREQ_SYNDICATE
	initial_microphone_enabled = TRUE
	device_color = "#820A16"
	hardened = TRUE
	locked_frequency = TRUE

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
	secure_frequencies = list("t" = R_FREQ_DETECTIVE)
	secure_classes = list("t" = R_FREQ_DETECTIVE)
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
	initial_microphone_enabled = FALSE
	device_color = "#3344AA"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/adventure/syndcommand
	name = "Suspicious Intercom"
	frequency = R_FREQ_INTERCOM_SYNDCOMMAND
	locked_frequency = TRUE
	initial_microphone_enabled = TRUE
	device_color = "#BB3333"

	initialize()
		set_frequency(frequency)


/obj/item/device/radio/intercom/adventure/wizards
	name = "SWF Intercom"
	frequency = R_FREQ_INTERCOM_WIZARD
	initial_microphone_enabled = TRUE
	device_color = "#3333AA"

	initialize()
		set_frequency(frequency)


/obj/item/device/radio/intercom/fish
	name = "Fishercom"
	desc = "Didn't some burger place invent these?"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "wallfish"
	forced_maptext = TRUE // carte blanche
	pixel_y = 28 // fish only approved for dir = SOUTH
	device_color = "#3983C6" // for chat color

	// burning stuff
	burn_remains = BURN_REMAINS_MELT // burn down to a glob
	burn_possible = TRUE
	burn_point = 300
	health = 50 // same as a plank

/obj/item/device/radio/intercom/fish/New(loc, obj/item/device/radio/intercom/intercom_to_copy)
	. = ..()
	if (intercom_to_copy && istype(intercom_to_copy))
		src.device_color = intercom_to_copy.device_color
		src.toggle_microphone(intercom_to_copy.microphone_enabled)
		src.name = replacetext(intercom_to_copy.name, "Intercom", "Fishercom")
		src.frequency = intercom_to_copy.frequency

/obj/item/device/radio/intercom/fish/receive_signal()
	. = ..()

	if (.)
		return

	flick("wallfish_move", src)

/obj/item/device/radio/intercom/fish/combust()
	if (!src.burning)
		src.ensure_speech_tree().AddSpeechModifier(SPEECH_MODIFIER_ACCENT_STUTTER)

	. = ..()

/obj/item/device/radio/intercom/fish/combust_ended()
	if (!src.burning)
		src.ensure_speech_tree().RemoveSpeechModifier(SPEECH_MODIFIER_ACCENT_STUTTER)
	. = ..()

/obj/item/device/radio/intercom/fish/update_pixel_offset_dir()
	return


/obj/item/device/radio/intercom/AI/handheld
	name = "Portable Intercom"
	desc = "A portable intercom that's useful to do all the things intercoms normally do, which is mostly listening in on people."
	initial_microphone_enabled = FALSE
	initial_speaker_enabled = FALSE
	anchored = UNANCHORED
	icon_state = "intercom_pot"
