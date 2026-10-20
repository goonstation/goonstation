/obj/machinery/computer/operating
	name = "operating computer"
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/computer.dmi'
	icon_state = "operating"
	desc = "Shows information on a patient laying on an operating table."
	can_reconnect = TRUE
	circuit_type = /obj/item/circuitboard/operating

	var/mob/living/carbon/human/victim = null

	var/obj/machinery/optable/table = null
	id = 0
	var/list/victim_data[][] = list()
	var/const/history_max = 25

	attackby(obj/item/W, mob/user)
		. = ..()
		if (iswrenchingtool(W) && src.circuit_type)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/computer/operating/proc/change_shape,\
			list(W, user), W.icon, W.icon_state, "[user] changes the shape of the [src].", null)
		else
			src.Attackhand(user)

	get_help_message(dist, mob/user)
		. = "You can use a <b>screwdriver</b> to unscrew the screen"
		if (src.can_reconnect)
			. += ",\nor a <b>multitool</b> to re-scan for equipment. <br> You may also use a <b>wrench</b> to reconfigure the [src] visually."
		else
			. += "."

/obj/machinery/computer/operating/New()
	..()
	SPAWN(0.5 SECONDS)
		connection_scan()

/obj/machinery/computer/operating/connection_scan()
	src.table = locate(/obj/machinery/optable, orange(2,src))

/obj/machinery/computer/operating/attack_hand(mob/user)
	add_fingerprint(user)
	if(status & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/operating/ui_interact(mob/user, datum/tgui/ui)
	if (src.victim)
		SEND_SIGNAL(src.victim.reagents, COMSIG_REAGENTS_ANALYZED, user)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OperatingComputer")
		ui.open()

/obj/machinery/computer/operating/process()
	..()
	if (status & (BROKEN | NOPOWER))
		return
	if(src.table && (src.table.check_victim()))
		src.victim = src.table.victim
	else
		src.victim = null
		src.victim_data = null
	if (src.victim)
		src.victim_data += list(sample_victim())
		if (length(src.victim_data) > src.history_max)
			src.victim_data.Cut(1, 2) //drop the oldest entry
		use_power(500)


/obj/machinery/computer/operating/proc/sample_victim()
	. = list()
	.["brute"] = src.victim?.get_brute_damage()
	.["burn"] = src.victim?.get_burn_damage()
	.["toxin"] = src.victim?.get_toxin_damage()
	.["oxy"] = src.victim?.get_oxygen_deprivation()

/obj/machinery/computer/operating/ui_data(mob/user)
	. = list()
	.["occupied"] = istype(src.victim)
	if(!src.victim)
		return
	. += src.victim.ui_health_data(TRUE, TRUE, TRUE, TRUE)
	.["patient_data"] = src.victim_data

/obj/machinery/computer/operating/small
	density = 0
	icon_state = "operating-small"

/obj/machinery/computer/operating/proc/change_shape()
	if (src.density)
		src.base_icon_state = "operating-small"
	else
		src.base_icon_state = "operating"
	src.power_change() // redraw nopower/broken/screen glow
	src.density = !src.density
