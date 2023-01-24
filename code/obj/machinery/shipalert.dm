//
//	Ship alert button
//	Teeny tiny hammer (to break the glass cover)
//

//Using this definition and global system in antipation of further extension onto this ship alert feature
var/global/shipAlertState = SHIP_ALERT_GOOD
var/global/soundGeneralQuarters = sound('sound/machines/siren_generalquarters_quiet.ogg')

TYPEINFO(/obj/machinery/shipalert)
	mats = 0

/obj/machinery/shipalert
	name = "Ship Alert Button"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "shipalert0"
	desc = ""
	anchored = 1

	var/usageState = 0 // 0 = glass cover, hammer. 1 = glass cover, no hammer. 2 = cover smashed
	var/working = 0 //processing loops
	var/lastActivated = 0
	var/cooldownPeriod = 2000 //2 minutes, change according to player abuse

	New()
		..()
		UnsubscribeProcess()

/obj/machinery/shipalert/attack_hand(mob/user)
	if (user.stat || isghostdrone(user) || !isliving(user) || isintangible(user))
		return

	src.add_fingerprint(user)

	switch (usageState)
		if (0)
			//take the hammer
			if (issilicon(user)) return
			var/obj/item/tinyhammer/hammer = new /obj/item/tinyhammer()
			user.put_in_hand_or_drop(hammer)
			src.usageState = 1
			src.icon_state = "shipalert1"
			user.visible_message("[user] picks up \the [hammer]", "You pick up \the [hammer]")
		if (1)
			//no effect punch
			out(user, "<span class='alert'>The glass casing is too strong for your puny hands!</span>")
		if (2)
			//activate
			if (src.working) return
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			src.toggleActivate(user)

/obj/machinery/shipalert/attackby(obj/item/W, mob/user)
	if (user.stat)
		return

	if (src.usageState == 1)
		if (istype(W, /obj/item/tinyhammer))
			//break glass
			var/area/T = get_turf(src)
			T.visible_message("<span class='alert'>[src]'s glass housing shatters!</span>")
			playsound(T, pick('sound/impact_sounds/Glass_Shatter_1.ogg','sound/impact_sounds/Glass_Shatter_2.ogg','sound/impact_sounds/Glass_Shatter_3.ogg'), 100, 1)
			var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
			G.set_loc(get_turf(user))
			src.usageState = 2
			src.icon_state = "shipalert2"
		else
			//no effect
			out(user, "<span class='alert'>\The [W] is far too weak to break the patented Nanotrasen<sup>TM</sup> Safety Glass housing.</span>")

/obj/machinery/shipalert/proc/toggleActivate(mob/user)
	if (!user)
		return

	if (src.working)
		out(user, "The alert coils are currently discharging, please be patient.")
		return

	src.working = 1

	if (shipAlertState == SHIP_ALERT_BAD)
		//centcom alert
		command_alert("The emergency is over. Return to your regular duties.", "Alert - All Clear")

		//toggle off
		shipAlertState = SHIP_ALERT_GOOD

		//update all lights
		for (var/obj/machinery/light/L in stationLights)
			L.power_change()
			sleep(0.25)

		lastActivated = world.time

	else
		if (src.lastActivated + src.cooldownPeriod > world.time)
			out(user, "The alert coils are still priming themselves.")
			src.working = 0
			return

		//alert and siren
#ifdef MAP_OVERRIDE_MANTA
		command_alert("This is not a drill. This is not a drill. General Quarters, General Quarters. All hands man your battle stations. Crew without military training shelter in place. Set material condition '[rand(1, 100)]-[pick_string("station_name.txt", "militaryLetters")]' throughout the ship. The route of travel is forward and up to starboard, down and aft to port. Prepare for hostile contact.", "NSS Manta - General Quarters")
#else
		command_alert("All personnel, this is not a test. There is a confirmed, hostile threat on-board and/or near the station. Report to your stations. Prepare for the worst.", "Alert - Condition Red", alert_origin = ALERT_STATION)
#endif
		world << soundGeneralQuarters
		//toggle on
		shipAlertState = SHIP_ALERT_BAD

		//update all lights
		for (var/obj/machinery/light/L in stationLights)
			L.power_change()
			sleep(0.25)

		lastActivated = world.time

	//alertWord stuff would go in a dedicated proc for extension
	var/alertWord = "green"
	if (shipAlertState == SHIP_ALERT_BAD) alertWord = "red"

	logTheThing(LOG_STATION, user, "toggled the ship alert to \"[alertWord]\"")
	logTheThing(LOG_DIARY, user, "toggled the ship alert to \"[alertWord]\"", "station")
	src.working = 0

/obj/item/tinyhammer
	name = "teeny tiny hammer"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "tinyhammer"
	item_state = "tinyhammer"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	flags = FPRINT | TABLEPASS | CONDUCT
	object_flags = NO_GHOSTCRITTER
	force = 5
	throwforce = 5
	w_class = W_CLASS_TINY
	m_amt = 50
	desc = "Like a normal hammer, but teeny."
	stamina_damage = 33
	stamina_cost = 18
	stamina_crit_chance = 10
