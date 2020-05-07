/obj/item/device/radio/intercom
	name = "Station Intercom (Radio)"
	icon_state = "intercom"
	anchored = 1.0
	plane = PLANE_NOSHADOW_BELOW
	mats = 0
	device_color = RADIOC_INTERCOM
	var/number = 0
	rand_pos = 0
	desc = "A wall-mounted radio intercom, used to communicate with the specified frequency. Usually turned off except during emergencies."

/obj/item/device/radio/intercom/attack_ai(mob/user as mob)
	src.add_fingerprint(user)
	SPAWN_DBG (0)
		attack_self(user)

/obj/item/device/radio/intercom/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	SPAWN_DBG (0)
		attack_self(user)

/obj/item/device/radio/intercom/send_hear()
	if (src.listening)
		return hearers(7, src.loc)

/obj/item/device/radio/intercom/putt
	name = "Colosseum Intercommunicator"
	frequency = R_FREQ_INTERCOM_COLOSSEUM
	broadcasting = 1
	device_color = "#aa5c00"
	protected_radio = 1

	initialize()
		set_frequency(frequency)

// -------------------- VR --------------------
/obj/item/device/radio/intercom/virtual
	desc = "Virtual radio for all your beeps and bops."
	icon = 'icons/effects/VR.dmi'
	protected_radio = 1
// --------------------------------------------

// ** preset intercoms to make mapping suck less augh **

/obj/item/device/radio/intercom/medical
	name = "Medical Intercom"
	frequency = R_FREQ_INTERCOM_MEDICAL
	broadcasting = 0
	device_color = "#0050FF"
	pixel_y = 24

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/security
	name = "Security Intercom"
	frequency = R_FREQ_INTERCOM_SECURITY
	broadcasting = 0
	device_color = "#FF2000"
	pixel_y = 24

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/brig
	name = "Brig Intercom"
	frequency = R_FREQ_INTERCOM_BRIG
	broadcasting = 0
	device_color = "#FF5000"
	pixel_y = 24

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/science
	name = "Research Intercom"
	frequency = R_FREQ_INTERCOM_RESEARCH
	broadcasting = 0
	device_color = "#FF2000"
	pixel_y = 24

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/engineering
	name = "Engineering Intercom"
	frequency = R_FREQ_INTERCOM_ENGINEERING
	broadcasting = 0
	device_color = "#BBBB00"
	pixel_y = 24

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/cargo
	name = "Cargo Intercom"
	frequency = R_FREQ_INTERCOM_CARGO
	broadcasting = 0
	device_color = "#9A8B0D"
	pixel_y = 24

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/catering
	name = "Catering Intercom"
	frequency = R_FREQ_INTERCOM_CATERING
	broadcasting = 0
	device_color = "#FF2000"
	pixel_y = 24

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/AI
	name = "AI Intercom"
	frequency = R_FREQ_INTERCOM_AI
	broadcasting = 1
	device_color = "#333399"
	pixel_y = 24

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/bridge
	name = "Bridge Intercom"
	frequency = R_FREQ_INTERCOM_BRIDGE
	broadcasting = 1
	device_color = "#339933"
	pixel_y = 24

	initialize()
		set_frequency(frequency)


////// adventure area intercoms

/obj/item/device/radio/intercom/adventure/owlery
	name = "Owlery Intercom"
	frequency = R_FREQ_INTERCOM_OWLERY
	broadcasting = 0
	device_color = "#3344AA"
	pixel_y = 24

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/adventure/syndcommand
	name = "Suspicious Intercom"
	frequency = R_FREQ_INTERCOM_SYNDCOMMAND
	broadcasting = 1
	device_color = "#BB3333"
	pixel_y = 24

	initialize()
		set_frequency(frequency)


/obj/item/device/radio/intercom/adventure/wizards
	name = "SWF Intercom"
	frequency = R_FREQ_INTERCOM_WIZARD
	broadcasting = 1
	device_color = "#3333AA"
	pixel_y = 24

	initialize()
		set_frequency(frequency)
