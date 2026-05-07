// Contents
// global scan atmos proc
// handheld atmos scanner & upgrade chip

// Made this a global proc instead of 10 or so instances of duplicate code spread across the codebase (Convair880).
/proc/scan_atmospheric(var/atom/A as turf|obj, var/pda_readout = 0, var/simple_output = 0, var/visible = 0, var/alert_output = 0)
	if (istype(A, /obj/ability_button))
		return
	if (!A)
		if (pda_readout == 1)
			return "Unable to obtain a reading."
		else if (simple_output == 1)
			return "(<b>Error:</b> <i>no source provided</i>)"
		else
			return SPAN_ALERT("Unable to obtain a reading.")

	if(visible)
		animate_scanning(A, "#00a0ff", alpha_hex = "32")

	var/datum/gas_mixture/check_me = A.return_air(direct = TRUE)
	var/pressure = null
	var/total_moles = null

	if (!check_me || !istype(check_me, /datum/gas_mixture/))
		if (pda_readout == 1)
			return "[A] does not contain any gas."
		else if (simple_output == 1)
			return "(<i>[A] has no gas holder</i>)"
		else
			return SPAN_ALERT("[A] does not contain any gas.")

	pressure = MIXTURE_PRESSURE(check_me)
	total_moles = TOTAL_MOLES(check_me)

	//DEBUG_MESSAGE("[A] contains: [pressure] kPa, [total_moles] moles.")

	var/data = ""

	if (total_moles > 0)
		if (pda_readout == 1) // Output goes into PDA interface, not the user's chatbox.
			data = "Air Pressure: [round(pressure, 0.1)] kPa<br>\
			Temperature: [round(check_me.temperature)] K<br>\
			[CONCENTRATION_REPORT(check_me, "<br>")]"

		else if (simple_output) // For the log_atmos() proc.
			data = "(<b>Pressure:</b> <i>[round(pressure, 0.1)] kPa</i>, <b>Temp:</b> <i>[round(check_me.temperature)] K</i>\
			, <b>Contents:</b> <i>[CONCENTRATION_REPORT(check_me, ", ")]</i>"

		else if (alert_output) // For the alert_atmos() proc.
			data = "(<b>Pressure:</b> <i>[round(pressure, 0.1)] kPa</i>, <b>Temp:</b> <i>[round(check_me.temperature)] K</i>\
			, <b>Contents:</b> <i>[SIMPLE_CONCENTRATION_REPORT(check_me, ", ")]</i>"

		else
			data = "--------------------------------<br>\
			[SPAN_NOTICE("Atmospheric analysis of <b>[A]</b>")]<br>\
			<br>\
			Pressure: [round(pressure, 0.1)] kPa<br>\
			Temperature: [round(check_me.temperature)] K<br>"
			//realistically bubbles should have a constantly changing volume based on their pressure but it doesn't really matter so let's just not report it
			if (!istype(A, /obj/bubble))
				data += "Volume: [check_me.volume] L<br>"
			data +=	"[SIMPLE_CONCENTRATION_REPORT(check_me, "<br>")]"

	else
		// Only used for "Atmospheric Scan" accessible through the PDA interface, which targets the turf
		// the PDA user is standing on. Everything else (i.e. clicking with the PDA on objects) goes in the chatbox.
		if (pda_readout == 1)
			data = "This area does not contain any gas."
		else if (simple_output == 1)
			data = "(<b>Contents:</b> <i>empty</i></b>)"
		else
			data = SPAN_ALERT("[A] does not contain any gas.")

	return data


TYPEINFO(/obj/item/device/analyzer/atmospheric)
	mats = 3

/obj/item/device/analyzer/atmospheric
	desc = "A hand-held environmental scanner which reports current gas levels and can track nearby hull breaches."
	name = "atmospheric analyzer"
	icon_state = "atmos-no_up"
	item_state = "analyzer"
	w_class = W_CLASS_SMALL
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	throwforce = 5
	w_class = W_CLASS_SMALL
	throw_speed = 4
	throw_range = 20
	var/analyzer_upgrade = 0
	///The breach we are currently tracking
	var/atom/target = null
	var/hudarrow_color = "#0df0f0"
	///We keep track of the airgroup so we can acquire a new breach after the old one is patched, even if the user is standing on space at the time
	var/datum/air_group/tracking_airgroup = null

	// Distance upgrade action code
	pixelaction(atom/target, params, mob/user, reach)
		var/turf/T = get_turf(target)
		if ((analyzer_upgrade == 1) && (BOUNDS_DIST(user, T) > 0))
			user.visible_message(SPAN_NOTICE("<b>[user]</b> takes a distant atmospheric reading of [T]."))
			boutput(user, scan_atmospheric(T, visible = 1))
			src.add_fingerprint(user)
			return

	attack_self(mob/user as mob)
		if (user.stat)
			return

		src.add_fingerprint(user)

		if (!src.target)
			src.find_breach()
			if (src.target)
				user.AddComponent(/datum/component/tracker_hud, src.target, src.hudarrow_color)
				src.AddOverlays(image('icons/obj/items/device.dmi', "atmos-tracker"), "breach_tracker")
		else
			src.tracker_off(user)

	proc/tracker_off(mob/user)
		src.ClearSpecificOverlays("breach_tracker")
		src.UnregisterSignal(src.target, COMSIG_TURF_REPLACED)
		var/datum/component/tracker_hud/arrow = user.GetComponent(/datum/component/tracker_hud)
		arrow?.RemoveComponent()
		src.target = null
		src.tracking_airgroup = null

	///Search the current airgroup for space borders and point to the closest one
	proc/find_breach()
		var/turf/simulated/T = get_turf(src)
		if (!src.tracking_airgroup)
			if (!istype(T) || !T.parent)
				boutput(src.loc, SPAN_ALERT("Unable to read atmospheric flow."))
				return
			src.tracking_airgroup = T.parent

		for (var/turf/breach in src.tracking_airgroup?.space_borders)
			for (var/dir in cardinal)
				var/turf/space/potential_space = get_step(breach, dir)
				if (istype(potential_space) && (!src.target || (GET_DIST(src.target, T) > GET_DIST(potential_space, T))))
					src.target = potential_space
					break
		if (!src.target)
			src.tracking_airgroup = null
			boutput(src.loc, SPAN_ALERT("No breaches found in current atmosphere."))
			return
		if (ismob(src.loc))
			var/datum/component/tracker_hud/arrow = src.loc.GetComponent(/datum/component/tracker_hud)
			arrow?.change_target(src.target)
		src.RegisterSignal(src.target, COMSIG_TURF_REPLACED, PROC_REF(update_breach))

	///When our target is replaced (most likely no longer a breach), pick a new one
	proc/update_breach(turf/replaced, turf/new_turf)
		src.UnregisterSignal(src.target, COMSIG_TURF_REPLACED)
		//the signal has to be sent before the turf is replaced, but we need to search after it has been replaced, hence the accursed SPAWN(1)
		SPAWN(1)
			if (!istype(new_turf, /turf/space))
				src.target = null
				src.find_breach()
				if (!src.target)
					src.tracker_off(src.loc)

	//we duplicate a little pinpointer code
	pickup(mob/user)
		. = ..()
		if (src.target)
			user.AddComponent(/datum/component/tracker_hud, src.target, src.hudarrow_color)

	dropped(mob/user)
		. = ..()
		var/datum/component/tracker_hud/arrow = user?.GetComponent(/datum/component/tracker_hud)
		arrow?.RemoveComponent()

	attackby(obj/item/W, mob/user)
		addUpgrade(W, user, src.analyzer_upgrade)

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if (BOUNDS_DIST(A, user) > 0 || istype(A, /obj/ability_button))
			return

		if (istype(A, /obj) || isturf(A))
			user.visible_message(SPAN_NOTICE("<b>[user]</b> takes an atmospheric reading of [A]."))
			boutput(user, scan_atmospheric(A, visible = 1))
		src.add_fingerprint(user)
		return

	detonator_act(event, var/obj/item/canbomb_detonator/det)
		switch (event)
			if ("attach")
				det.initial_wire_functions += src
			if ("pulse")
				det.attachedTo.visible_message("<span class='bold' style='color: #B7410E;'>\The [src]'s external display turns off for a moment before booting up again.</span>")
			if ("cut")
				det.attachedTo.visible_message("<span class='bold' style='color: #B7410E;'>\The [src]'s external display turns off.</span>")
				det.attachments.Remove(src)
			if ("leak")
				det.attachedTo.visible_message("<style class='combat bold'>\The [src] picks up the rapid atmospheric change of the canister, and signals the detonator.</style>")
				SPAWN(0)
					det.detonate()
		return

/obj/item/device/analyzer/atmospheric/upgraded //for borgs because JESUS FUCK
	analyzer_upgrade = 1
	icon_state = "atmos"

TYPEINFO(/obj/item/device/analyzer/atmosanalyzer_upgrade)
	mats = 2

/obj/item/device/analyzer/atmosanalyzer_upgrade
	name = "atmospherics analyzer upgrade"
	desc = "A small upgrade card that allows standard atmospherics analyzers to detect environmental information at a distance."
	icon_state = "atmos_upgr" // add this
	flags = TABLEPASS | CONDUCT
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10

///////////////// method to upgrade an analyzer if the correct upgrade cartridge is used on it /////////////////
/obj/item/device/analyzer/proc/addUpgrade(obj/item/device/W as obj, mob/user as mob, upgraded as num, active as num, iconState as text, itemState as text)
	if (istype(W, /obj/item/device/analyzer/healthanalyzer_upgrade) || istype(W, /obj/item/device/analyzer/healthanalyzer_organ_upgrade) || istype(W, /obj/item/device/analyzer/atmosanalyzer_upgrade))
		//Health Analyzers
		if (istype(src, /obj/item/device/analyzer/healthanalyzer))
			var/obj/item/device/analyzer/healthanalyzer/a = src
			if (istype(W, /obj/item/device/analyzer/healthanalyzer_upgrade))
				if (a.reagent_upgrade)
					boutput(user, SPAN_ALERT("This analyzer already has a reagent scan upgrade!"))
					return
				a.reagent_scan = 1
				a.reagent_upgrade = 1
				a.icon_state = a.organ_upgrade ? "health" : "health-r-up"
				a.scanner_status.icon_state = a.organ_scan ? "health_over-both" : "health_over-reagent"
				a.AddOverlays(a.scanner_status, "status")
				a.item_state = "healthanalyzer"

			else if (istype(W, /obj/item/device/analyzer/healthanalyzer_organ_upgrade))
				if (a.organ_upgrade)
					boutput(user, SPAN_ALERT("This analyzer already has an internal organ scan upgrade!"))
					return
				a.organ_upgrade = 1
				a.organ_scan = 1
				a.icon_state = a.reagent_upgrade ? "health" : "health-o-up"
				a.scanner_status.icon_state = a.reagent_scan ? "health_over-both" : "health_over-organ"
				a.AddOverlays(a.scanner_status, "status")
				a.item_state = "healthanalyzer"
		else if(istype(src, /obj/item/device/analyzer/atmospheric) && istype(W, /obj/item/device/analyzer/atmosanalyzer_upgrade))
			if (upgraded)
				boutput(user, SPAN_ALERT("This analyzer already has a distance scan upgrade!"))
				return
			var/obj/item/device/analyzer/atmospheric/a = src
			a.analyzer_upgrade = 1
			a.icon_state = "atmos"

		else
			boutput(user, SPAN_ALERT("That cartridge won't fit in there!"))
			return
		boutput(user, SPAN_NOTICE("Upgrade cartridge installed."))
		playsound(src.loc , 'sound/items/Deconstruct.ogg', 80, 0)
		user.u_equip(W)
		qdel(W)

