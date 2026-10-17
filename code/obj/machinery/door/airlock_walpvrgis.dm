// ------------ walpvrgis airlocks ------------

/obj/machinery/door/airlock/walp
	name = "airlock"
	icon = 'icons/obj/doors/walpvrgis_doors.dmi'
	icon_state = "basic_closed"
	icon_base = "basic"
	welded_icon_state = "2_welded"
	flags = IS_PERSPECTIVE_FLUID | FLUID_DENSE
	req_access = null

	generic
		icon_state = "basic_closed"
		icon_base = "basic"

	staff
		name = "staff airlock"
		icon_state = "staff_closed"
		icon_base = "staff"

	clown
		name = "clownesque airlock"
		icon_state = "clown_closed"
		icon_base = "clown"

	maintenance
		name = "maintenance airlock"
		icon_state = "maint_closed"
		icon_base = "maint"

	command
		name = "command airlock"
		icon_state = "com_closed"
		icon_base = "com"

	security
		name = "security airlock"
		icon_state = "sec_closed"
		icon_base = "sec"

	engineering
		name = "engineering airlock"
		icon_state = "eng_closed"
		icon_base = "eng"

	mining
		name = "mining airlock"
		icon_state = "mining_closed"
		icon_base = "mining"

	medical
		name = "medical airlock"
		icon_state = "med_closed"
		icon_base = "med"

	morgue
		name = "morgue airlock"
		icon_state = "morgue_closed"
		icon_base = "morgue"

	science
		name = "research airlock"
		icon_state = "sci_closed"
		icon_base = "sci"

	botany
		name = "hydroponics airlock"
		icon_state = "hydro_closed"
		icon_base = "hydro"

	janitor
		name = "janitorial airlock"
		icon_state = "janitor_closed"
		icon_base = "janitor"

// ------------ glass variation airlocks ------------

/obj/machinery/door/airlock/walp/glass
	name = "glass airlock"
	icon = 'icons/obj/doors/walpvrgis_doors.dmi'
	icon_state = "gwhite_closed"
	icon_base = "gwhite"
	opacity = 0
	visible = 0

	generic
		icon_state = "gwhite_closed"
		icon_base = "gwhite"

	genericdark
		icon_state = "gcom_closed"
		icon_base = "gcom"

	command
		name = "glass command airlock"
		icon_state = "gcom_closed"
		icon_base = "gcom"

	security
		name = "glass security airlock"
		icon_state = "gsec_closed"
		icon_base = "gsec"

	engineering
		name = "glass engineering airlock"
		icon_state = "geng_closed"
		icon_base = "geng"

	medical
		name = "glass medical airlock"
		icon_state = "gmed_closed"
		icon_base = "gmed"

	science
		name = "glass research airlock"
		icon_state = "gsci_closed"
		icon_base = "gsci"

	botany
		name = "glass hydroponics airlock"
		icon_state = "ghydro_closed"
		icon_base = "ghydro"
