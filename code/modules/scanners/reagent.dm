// Contents
// global scan reagents proc
// handheld reagent scanner

/proc/scan_reagents(atom/A, show_temp = TRUE, visible = FALSE, medical = FALSE, admin = FALSE)
	if (!A)
		return SPAN_ALERT("ERROR: NO SUBJECT DETECTED")

	if(visible)
		animate_scanning(A, "#a92fda")

	var/data = null
	var/reagent_data = null
	var/datum/reagents/reagents = A.reagents

	if(istype(A, /obj/fluid))
		var/obj/fluid/F = A
		reagents = F.group.reagents
	else if (istype(A, /obj/item/assembly))
		var/obj/item/assembly/checked_assembly = A
		reagents = checked_assembly.get_first_component_reagents()
	else if (istype(A, /obj/machinery/clonepod))
		var/obj/machinery/clonepod/P = A
		if(P.occupant)
			reagents = P.occupant.reagents
	else if (istype(A, /obj/fluid_pipe))
		var/obj/fluid_pipe/P = A
		reagents = P.network.reagents

	if (reagents)
		if (length(reagents.reagent_list))
			if("cloak_juice" in reagents.reagent_list)
				var/datum/reagent/cloaker = reagents.reagent_list["cloak_juice"]
				if(cloaker.volume >= 5)
					data = SPAN_ALERT("ERR: SPECTROSCOPIC ANALYSIS OF THIS SUBSTANCE IS NOT POSSIBLE.")
					return data
			if (!admin)
				SEND_SIGNAL(reagents, COMSIG_REAGENTS_ANALYZED, usr)

			var/reagents_length = length(reagents.reagent_list)
			data = "<b class='notice'>[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found in [A].</b>"

			for (var/current_id in reagents.reagent_list)
				var/datum/reagent/current_reagent = reagents.reagent_list[current_id]
				var/show_OD = (medical && current_reagent.overdose != 0 && current_reagent.volume >= current_reagent.overdose)
				reagent_data += "<span [show_OD ? "class='alert'" : "class='notice'"]><br>&emsp;[current_reagent.name] - [current_reagent.volume][show_OD? " - OD!":""]</span>"
			data += "[reagent_data]"

			if (show_temp)
				data += "<br>[SPAN_NOTICE("Overall temperature: [reagents.total_temperature] K")]"
		else
			data = "<b class='notice'>No active chemical agents found in [A].</b>"
	else
		data = "<b class='notice'>No significant chemical agents found in [A].</b>"

	if (CHECK_LIQUID_CLICK(A))
		var/turf/T = get_turf(A)
		var/obj/fluid/liquid = T.active_liquid
		var/obj/fluid/airborne/gas = T.active_airborne_liquid
		if (liquid)
			data += "<br>[scan_reagents(liquid, show_temp, visible, medical, admin)]"
		if (gas)
			data += "<br>[scan_reagents(gas, show_temp, visible, medical, admin)]"

	return data

/proc/get_ethanol_equivalent(mob/user, datum/reagents/R)
	var/eth_eq = 0
	var/should_we_output = FALSE //looks bad if we output this when it's just ethanol in there
	if(!istype(R))
		return
	for (var/current_id in R.reagent_list)
		var/datum/reagent/current_reagent = R.reagent_list[current_id]
		if (istype(current_reagent, /datum/reagent/fooddrink/alcoholic))
			var/datum/reagent/fooddrink/alcoholic/alch_reagent = current_reagent
			eth_eq += alch_reagent.alch_strength * alch_reagent.volume
			should_we_output = TRUE
		if (current_reagent.id == "ethanol")
			eth_eq += current_reagent.volume
	if (should_we_output == FALSE)
		eth_eq = 0
	return eth_eq



TYPEINFO(/obj/item/device/reagentscanner)
	mats = 5

/obj/item/device/reagentscanner
	name = "reagent scanner"
	icon_state = "reagentscan"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	item_state = "reagentscan"
	desc = "A hand-held device that scans and lists the chemicals inside the scanned subject."
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10
	m_amt = 200
	var/scan_results = null
	var/last_scan_timestamp = null
	hide_attack = ATTACK_PARTIALLY_HIDDEN
	tooltip_flags = REBUILD_DIST

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		return

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if(istype(A, /obj/machinery/photocopier))
			return // Upload scan results to the photocopier without scanning the photocopier itself

		user.visible_message(SPAN_NOTICE("<b>[user]</b> scans [A] with [src]!"),\
		SPAN_NOTICE("You scan [A] with [src]!"))

		src.scan_results = scan_reagents(A, visible = TRUE)
		src.last_scan_timestamp = time2text(world.timeofday, "DD MMM [CURRENT_SPACE_YEAR], hh:mm:ss")
		tooltip_rebuild = TRUE

		if (!isnull(A.reagents))
			if (length(A.reagents.reagent_list) > 0)
				set_icon_state("reagentscan-results")
			else
				set_icon_state("reagentscan-no")
		else
			set_icon_state("reagentscan-no")

		if (isnull(src.scan_results))
			boutput(user, SPAN_ALERT("\The [src] encounters an error and crashes!"))
		else
			var/scan_output = "[src.scan_results]"
			if (user.traitHolder.hasTrait("training_bartender"))
				var/eth_eq = get_ethanol_equivalent(user, A.reagents)
				if (eth_eq)
					scan_output += "<br> [SPAN_REGULAR("You estimate there's the equivalent of <b>[eth_eq] units of ethanol</b> here.")]"
			boutput(user, scan_output)

	attack_self(mob/user as mob) // no eth_eq here cuz then we'd have to save how the reagent container used to be
		if (isnull(src.scan_results))
			boutput(user, SPAN_NOTICE("No previous scan results located."))
			return
		src.print_report(user)

	get_desc(dist)
		if (dist < 3)
			if (!isnull(src.scan_results))
				. += "<br>[SPAN_NOTICE("Previous scan's results:<br>[src.scan_results]")]"

	proc/print_report(mob/user)
		if (!src.scan_results)
			boutput(user, SPAN_ALERT("\The [src] has nothing to print — scan something first!"))
			return
		if (!ON_COOLDOWN(src, "print_receipt", 4 SECONDS))
			var/obj/item/paper/P = new /obj/item/paper/thermal(user.loc)
			P.name = "reagent scan report"
			P.info = src.scan_results + "<br>--------------------------------<br>Taken At: [src.last_scan_timestamp]"
			user.put_in_hand_or_eject(P)
			playsound(src, 'sound/machines/printer_thermal.ogg', 25, TRUE)
