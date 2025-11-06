//
//	Ship alert button
//	Teeny tiny hammer (to break the glass cover)
//

//Using this definition and global system in antipation of further extension onto this ship alert feature
var/global/shipAlertState = SHIP_ALERT_GOOD
var/global/soundGeneralQuarters = sound('sound/machines/siren_generalquarters_quiet.ogg')

TYPEINFO(/obj/machinery/shipalert)
	mats = 0

#define COMPLETE 0
#define HAMMER_TAKEN 1
#define SMASHED 2
/obj/machinery/shipalert
	name = "Ship Alert Button"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "shipalert0"
	desc = ""
	anchored = ANCHORED

	var/usageState = 0 // 0 = glass cover, hammer. 1 = glass cover, no hammer. 2 = cover smashed
	var/working = FALSE //processing loops
	var/cooldownPeriod = 5 MINUTES //5 minutes, change according to player abuse
	var/deactivateCooldown = 30 SECONDS // 30 seconds, no instantly taking it back
	var/max_msg_length = 200 //half of a command alert

	New()
		..()
		src.name = "[capitalize(station_or_ship())] Alert Button"
		UnsubscribeProcess()

		// Global signals that declare red alert automatically
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_NUKE_PLANTED, PROC_REF(activate))
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_ARMORY_AUTH, PROC_REF(activate))
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_ARMORY_UNAUTH, PROC_REF(deactivate))

/obj/machinery/shipalert/attack_hand(mob/user)
	if (user.stat || isghostdrone(user) || !isliving(user) || isintangible(user))
		return
	src.add_fingerprint(user)

	switch (usageState)
		if (COMPLETE)
			//take the hammer
			if (issilicon(user)) return
			var/obj/item/tinyhammer/hammer = new /obj/item/tinyhammer()
			user.put_in_hand_or_drop(hammer)
			src.usageState = HAMMER_TAKEN
			src.icon_state = "shipalert1"
			user.visible_message("[user] picks up \the [hammer]", "You pick up \the [hammer]")
		if (HAMMER_TAKEN)
			//no effect punch
			boutput(user, SPAN_ALERT("The glass casing is too strong for your puny hands!"))
		if (SMASHED)
			//activate
			if (src.working)
				return
			if (src.toggleActivate(user))
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)

/obj/machinery/shipalert/attackby(obj/item/W, mob/user)
	if (user.stat)
		return
	switch (src.usageState)
		if (HAMMER_TAKEN)
			if (istype(W, /obj/item/tinyhammer))
				//break glass
				var/area/T = get_turf(src)
				T.visible_message(SPAN_ALERT("[src]'s glass housing shatters!"))
				playsound(T, pick('sound/impact_sounds/Glass_Shatter_1.ogg','sound/impact_sounds/Glass_Shatter_2.ogg','sound/impact_sounds/Glass_Shatter_3.ogg'), 100, 1)
				var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
				G.set_loc(get_turf(user))
				src.usageState = SMASHED
				src.icon_state = "shipalert2"
			else
				//no effect
				boutput(user, SPAN_ALERT("\The [W] is far too weak to break the patented Nanotrasen<sup>TM</sup> Safety Glass housing."))
		if (SMASHED)
			if (istype(W, /obj/item/sheet) && (W.material.getMaterialFlags() & MATERIAL_CRYSTAL) && W.amount >= 2)
				SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, PROC_REF(repair_callback), list(user, W), W.icon, W.icon_state, "[user] repairs [src]'s safety glass.", INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)

/obj/machinery/shipalert/proc/repair_callback(mob/user, obj/item/sheet/glass)
	if (src.usageState != SMASHED)
		return
	src.usageState = HAMMER_TAKEN
	glass.change_stack_amount(-2)
	src.icon_state = "shipalert1"

/obj/machinery/shipalert/proc/toggleActivate(mob/user)
	if (!user)
		return FALSE

	if (src.working)
		boutput(user, SPAN_ALERT("The alert coils are currently discharging, please be patient."))
		return FALSE

	src.working = TRUE

	if (shipAlertState == SHIP_ALERT_BAD)
		if (GET_COOLDOWN(src, "deactivate_cooldown"))
			boutput(user, SPAN_ALERT("The alert coils are still in high-power mode, please wait to lift alert."))
			src.working = FALSE
			return FALSE
		. = src.deactivate(user, TRUE)
	else
		if (GET_COOLDOWN(src, "alert_cooldown"))
			boutput(user, SPAN_ALERT("The alert coils are still priming themselves."))
			src.working = FALSE
			return FALSE
		var/reason
		// no flockdrones, critters, etc
		if(!ishuman(user))
			reason = "Unknown"
		else
			reason = tgui_input_text(user, "Please describe the nature of the threat:", "Alert", max_length = src.max_msg_length)
		if (!length(reason))
			src.working = FALSE
			return FALSE
		reason = sanitize(adminscrub(reason, src.max_msg_length))
		. = src.activate(user, reason, TRUE)
	//alertWord stuff would go in a dedicated proc for extension
	var/alertWord = "green"
	if (shipAlertState == SHIP_ALERT_BAD)
		alertWord = "red"

	logTheThing(LOG_STATION, user, "toggled the ship alert to \"[alertWord]\"")
	message_admins("[user] toggled the ship alert to \"[alertWord]\"")
	src.working = FALSE

/obj/machinery/shipalert/proc/activate(mob/user, var/reason, var/announce = FALSE)
	if (shipAlertState == SHIP_ALERT_BAD)
		return FALSE
	//alert and siren
	if (announce)
		command_alert("All personnel, this is not a test. There is a confirmed, hostile threat on-board and/or near the station: <b>[end_sentence(reason)]</b><br>Report to your stations. Prepare for the worst.", "Alert - Condition Red", alert_origin = ALERT_STATION)
		playsound_global(world, soundGeneralQuarters, 100, pitch = 0.9) //lower pitch = more serious or something idk
	//toggle on
	shipAlertState = SHIP_ALERT_BAD

	// status display red alert
	var/datum/signal/status_signal = get_free_signal()
	status_signal.data["sender"] = "00000000"
	status_signal.data["command"] = STATUS_DISPLAY_PACKET_MODE_DISPLAY_ALERT
	status_signal.data["address_tag"] = "STATDISPLAY"
	status_signal.data["picture_state"] = STATUS_DISPLAY_PACKET_ALERT_REDALERT
	radio_controller.get_frequency(FREQ_STATUS_DISPLAY).post_packet_without_source(status_signal)

	ON_COOLDOWN(src, "deactivate_cooldown", src.deactivateCooldown)
	src.update_lights()
	src.do_lockdown(user)
	. = TRUE

/obj/machinery/shipalert/proc/deactivate(mob/user,var/announce = FALSE)
	if (shipAlertState == SHIP_ALERT_GOOD)
		return FALSE
	//centcom alert
	if (announce)
		command_alert("The emergency is over. Return to your regular duties.", "Alert - All Clear", alert_origin = ALERT_STATION)

	//toggle off
	shipAlertState = SHIP_ALERT_GOOD

	// set status displays to default
	var/datum/signal/status_signal = get_free_signal()
	status_signal.data["sender"] = "00000000"
	status_signal.data["command"] = STATUS_DISPLAY_PACKET_MODE_DISPLAY_DEFAULT
	status_signal.data["address_tag"] = "STATDISPLAY"
	radio_controller.get_frequency(FREQ_STATUS_DISPLAY).post_packet_without_source(status_signal)

	src.update_lights()

	ON_COOLDOWN(src, "alert_cooldown", src.cooldownPeriod)
	. = TRUE

/obj/machinery/shipalert/proc/update_lights()
	for(var/obj/machinery/light/emergency/light in by_cat[TR_CAT_STATION_EMERGENCY_LIGHTS])
		light.power_change()
		LAGCHECK(LAG_LOW)

/obj/machinery/shipalert/proc/do_lockdown(mob/user)
	for_by_tcl(shutter, /obj/machinery/door/poddoor)
		if (shutter.density)
			continue
		if (shutter.z != Z_LEVEL_STATION)
			continue
		if ((shutter.id != "lockdown") && (shutter.id != "ai_core") && (shutter.id != "armory"))
			continue
		shutter.close()

	for_by_tcl(turret_control, /obj/machinery/turretid)
		if (turret_control.lethal)
			turret_control.toggle_lethal(user)
		if (!turret_control.enabled)
			turret_control.toggle_active(user)


#undef COMPLETE
#undef HAMMER_TAKEN
#undef SMASHED

/obj/item/tinyhammer
	name = "teeny tiny hammer"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "tinyhammer"
	item_state = "tinyhammer"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	flags = TABLEPASS | CONDUCT
	object_flags = NO_GHOSTCRITTER
	force = 5
	throwforce = 5
	w_class = W_CLASS_TINY
	m_amt = 50
	desc = "Like a normal hammer, but teeny."
	stamina_damage = 33
	stamina_cost = 18
	stamina_crit_chance = 10
