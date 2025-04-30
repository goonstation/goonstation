//----------------TABLE OF CONTENTS--------------------//

//MANTA RELATED LISTS AND GLOBAL VARIABLES//
//MANTA RELATED OBJECTS//
//MANTA RELATED TURFS//
//MANTA RELATED DATUMS (Mainly related to fixing propellers.)//
//MANTA RELATED AREAS//
//MANTA SECRET STUFF//

//-------------------------------------------- MANTA COMPATIBLE LISTS HERE --------------------------------------------

var/list/mantaPushList = list()
var/mantaMoving = 1
var/MagneticTether = 1
var/obj/manta_speed_lever/mantaLever = null

//-------------------------------------------- MANTA COMPATIBLE OBJECTS HERE --------------------------------------------

/obj/decal/mantaBubbles
	density = 0
	anchored = ANCHORED_ALWAYS
	layer =  EFFECTS_LAYER_4
	event_handler_flags = IMMUNE_MANTA_PUSH | USE_FLUID_ENTER
	name = ""
	mouse_opacity = 0

	New()
		START_TRACKING
		..()

	disposing()
		STOP_TRACKING
		return ..()

	small
		icon = 'icons/effects/bubbles32x64.dmi'
		icon_state = "bubbles"
		pixel_y = 8

	large
		icon = 'icons/effects/bubbles64x64.dmi'
		icon_state = "bubbles2"
		pixel_y = 16

	verylarge
		icon = 'icons/effects/bubbles64x256.dmi'
		icon_state = "bubbles"
		pixel_y = 16

	smallfast
		icon = 'icons/effects/bubbles_1.dmi'
		icon_state = "bubbles"
		dir = NORTH
		//pixel_y = 32

/obj/manta_speed_lever
	name = "lever console"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "lever1"
	density = 1
	anchored = ANCHORED_ALWAYS
	var/on = 1
	var/lastuse = 0
	var/locked = 1 //Starts off locked.
	req_access = list(access_heads)

	New()
		mantaLever = src
		UpdateIcon()
		..()
//This crap is here so nothing can destroy it.
	hitby(atom/movable/AM, datum/thrown_thing/thr)
		SHOULD_CALL_PARENT(FALSE)
	reagent_act()
	bullet_act()
	ex_act()
	blob_act()
	meteorhit()
	damage_heat()
	damage_corrosive()
	damage_piercing()
	damage_slashing()
	damage_blunt()

	attack_hand(mob/user)
		var/diff = world.timeofday - lastuse
		if(diff < 0) diff += 864000 //Wrapping protection.

		if (locked == 1)
			user.show_text(SPAN_ALERT("<b>You must first unlock the lever console with an ID to be able to use it.</b>"))
			return

		if(mantaIsBroken() && !on)
			user.show_text(SPAN_ALERT("<b>Too many propellers are damaged; you can not move NSS Manta.</b>"))
			return

		if(diff > 3000)
			lastuse = world.timeofday
			if(on)
				user.show_text(SPAN_NOTICE("<b>You turn off the propellers.</b>"))
				on = 0
				UpdateIcon()
				command_alert("Attention, NSS Manta is slowing down to a halt. Shutting down propellers.", "NSS Manta Movement Computer", alert_origin = ALERT_STATION)
				mantaSetMove(on)
			else
				user.show_text(SPAN_NOTICE("<b>You turn on the propellers.</b>"))
				on = 1
				playsound_global(world, 'sound/effects/mantamoving.ogg', 90)
				sleep(7 SECONDS)
				UpdateIcon()
				command_alert("Attention, firing up propellers.  NSS Manta will be on the move shortly.", "NSS Manta Movement Computer", alert_origin = ALERT_STATION)
				mantaSetMove(on)
			return
		else
			user.show_text(SPAN_ALERT("<b>The engine is still busy.</b>"))


	attack_ai(mob/user as mob)
		return attack_hand(user)

	attackby(obj/item/W, mob/user)
		if(istype(get_id_card(W), /obj/item/card/id))
			if (src.allowed(user))
				user.visible_message("[user] [src.locked ? "unlocks" : "locks"] the access panel.","You [src.locked ? "unlock" : "lock"] the access panel.")
				src.locked = !src.locked
				UpdateIcon()
			else
				boutput(user, SPAN_ALERT("Access denied."))
		else
			..()

		return

	update_icon()
		if (locked == 1 && on == 1)
			icon_state = "lever1-locked"
		if (locked == 1 && on == 0)
			icon_state = "lever0-locked"
		if (locked == 0 && on == 1)
			icon_state = "lever1"
		if (locked == 0 && on == 0)
			icon_state = "lever0"

/proc/mantaIsBroken()
	var/broken = 0
	for_by_tcl(A, /obj/machinery/mantapropulsion)
		if(!A.important) continue
		if(A.health == 0) broken++
		if(A.health > 0) broken--
	if(broken >= 4)
		return 1
	return 0

/proc/mantaSetMove(var/moving=1, var/doShake=1)

	if(mantaIsBroken() && moving == 1) //If too many are broken and we want to move, nope out. This is just an extra safety.
		mantaMoving = 0
		return

	if(doShake)
		for(var/client/C in clients)
			var/mob/M = C.mob
			if(M?.z == 1) shake_camera(M, 5, 32, 0.2)

	for_by_tcl(T, /turf/space/fluid/manta)
		T.setScroll(moving)

	for_by_tcl(O, /obj/decal/mantaBubbles)
		O.alpha = (moving ? 255:0)

	for_by_tcl(O, /obj/sea_plant_manta)
		O.alpha = (moving ? 0:255)

	for_by_tcl(O, /obj/machinery/mantapropulsion)
		O.setOn(moving)

	mantaMoving = moving
	return

/obj/machinery/mantapropulsion
	name = "propeller"
	icon = 'icons/obj/shuttle.dmi'
	icon_state = "sea_propulsion"
	var/stateOn = ""
	var/stateOff = ""
	var/stateDamaged = ""
	var/on = 1
	anchored = ANCHORED_ALWAYS
	density = 1
	var/health = 100
	var/maxhealth = 100
	var/important = 0
	var/repairstate = 0
	var/broken = 0

	New()
		..()
		stateOff = "sea_propulsion_off"
		stateOn = "sea_propulsion"
		icon_state = stateOn
		on = 1
		START_TRACKING

	disposing()
		STOP_TRACKING
		return ..()

	Bumped(atom/AM) //This is stolen straight from the crusher, just making sure that the propellers are actually on.
		if (mantaMoving == 1)
			if (repairstate == 0)
				actions.start(new /datum/action/bar/crusher(AM), src)


//REPAIRING:  wrench > screwdriver > crowbar > wires > welder > wrench > screwdriver > sheet > welder

	attackby(var/obj/item/I, var/mob/user)
		switch(repairstate)
			if (0)
				if (important == 1)
					..()
					change_health(-I.force)
					return
			if(1)
				if (istool(I, TOOL_WRENCHING))
					actions.start(new /datum/action/bar/icon/propeller_fix(src, I, 50), user)
			if(2)
				if (istool(I, TOOL_SCREWING))
					actions.start(new /datum/action/bar/icon/propeller_fix(src, I, 50), user)
			if(3)
				if (ispryingtool(I))
					actions.start(new /datum/action/bar/icon/propeller_fix(src, I, 60), user)
			if(4)
				if (istype(I, /obj/item/cable_coil))
					actions.start(new /datum/action/bar/icon/propeller_fix(src, I, 60), user)
			if(5)
				if (isweldingtool(I) && I:try_weld(user,0,-1))
					actions.start(new /datum/action/bar/icon/propeller_fix(src, I, 50), user)
			if(6)
				if (istool(I, TOOL_WRENCHING))
					actions.start(new /datum/action/bar/icon/propeller_fix(src, I, 50), user)
			if(7)
				if (istool(I, TOOL_SCREWING))
					actions.start(new /datum/action/bar/icon/propeller_fix(src, I, 50), user)
			if(8)
				if (istype(I, /obj/item/sheet))
					var/obj/item/sheet/S = I
					if (S.amount >= 5)
						actions.start(new /datum/action/bar/icon/propeller_fix(src, I, 50), user)
			if(9)
				if (isweldingtool(I) && I:try_weld(user,0,-1))
					actions.start(new /datum/action/bar/icon/propeller_fix(src, I, 50), user)






	ex_act(severity)
		switch(severity)
			if(1)
				change_health(-maxhealth)
				return
			if(2)
				change_health(-50)
				return
			if(3 to INFINITY)
				change_health(-35)
				return

	proc/change_health(var/change = 0)
		health = clamp(health+change, 0, maxhealth)
		if(health == 0)
			setOn(0)
			repairstate = 1
			broken = 1
			desc = "It's definitely totaled, looks like the securing bolts are in place. Maybe grab a wrench?"
			if(mantaIsBroken() && mantaMoving)
				mantaSetMove(0)
				if(mantaLever)
					mantaLever.on = 0
					mantaLever.icon_state = "lever0"
		return

	proc/setOn(var/newOn=0)
		if(health)
			if(newOn)
				icon_state = stateOn
				on = newOn
			else
				icon_state = stateOff
				on = newOn
		else
			icon_state = stateDamaged //ADD YOUR BROKEN ICON STATE HERE THANK YOU
			on = 0
		return

	proc/Breakdown()
		health = 0
		on = 0
		icon_state = "bigsea_propulsion_broken"
		change_health()




/obj/machinery/mantapropulsion/big
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "bigsea_propulsion"
	important = 1
	bound_height = 64
	bound_width = 64
	appearance_flags = TILE_BOUND | PIXEL_SCALE

	New()
		. = ..()
		stateOff = "bigsea_propulsion_off"
		stateOn = "bigsea_propulsion"
		stateDamaged = "bigsea_propulsion_broken"
		icon_state = stateOn
		on = 1
		return .

/obj/machinery/power/seaheater
	name = "heater"
	icon = 'icons/obj/shuttle.dmi'
	icon_state = "heater"
	anchored = ANCHORED_ALWAYS
	density = 1

	New()
		..()

	seaheater_right
		icon_state = "seaheater_R"

	seaheater_left
		icon_state = "seaheater_L"

	seaheater_middle
		icon_state = "seaheater_M"

	seaheater
		icon_state = "seaheater"

/obj/machinery/power/seaheater/big
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "bigheater"
	var/lastpower = 0

	/*process()
		if(mantaMoving)
			var/power = 0
			var/a = 1000
			var/b = 100
			var/c = 100
			power = a*b*c
			src.lastpower = power
			powernet = get_direct_powernet()
			add_avail(power)
			..()


	proc/GetFunctioningPropellers()
		var/propelcount = 0
		for(var/obj/machinery/mantapropulsion/A in mantaPropellers)
			if(A.health <= 1) propelcount++
			return propelcount*/


/obj/machinery/junctionbox
	name = "junction box"
	desc = "An electrical junction box is an enclosure housing electrical connections, to protect the connections and provide a safety barrier."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "junctionbox"
	anchored = ANCHORED_ALWAYS
	var/open = 0
	var/iconopen = "junctionbox_open"
	var/iconclosed = "junctionbox"
	var/broken = 0
	var/repairstate = 0
	var/obj/cable/attached
	var/drain_rate = 50000		// amount of power to drain per tick
	var/power_drained = 0 		// has drained this much power
	var/max_power = 2e8		// maximum power that can be drained before exploding

	New()
		START_TRACKING
		. = ..()
		UpdateIcon()

	disposing()
		STOP_TRACKING
		return ..()

	attack_hand(mob/user)
		if (isAI(user))
			boutput(user, SPAN_ALERT("You'd touch the door, if only you had hands."))
			return
		if (broken == 1)
			user.shock(src, rand(5000, 15000), "chest", 1)
		if (!src.open)
			src.open = 1
			UpdateIcon()
			user.show_text(SPAN_NOTICE("<b>You open junction box's outer door.</b>"))
		else
			src.open = 0
			UpdateIcon()
			user.show_text(SPAN_NOTICE("<b>You close junction box's outer door.</b>"))

	attackby(var/obj/item/I, var/mob/user)
		if (broken == 1 && open == 1)
			user.shock(src, rand(5000, 15000), "chest", 1)
		switch(repairstate)
			if(1)
				if (broken == 1 && open == 1)
					user.shock(src, rand(5000, 15000), "chest", 1)
					if (istool(I, TOOL_SCREWING))
						actions.start(new /datum/action/bar/icon/junctionbox_fix(src, I, 30), user)
			if(2)
				if (broken == 1 && open == 1)
					user.shock(src, rand(5000, 15000), "chest", 1)
					if (istool(I, TOOL_SNIPPING))
						actions.start(new /datum/action/bar/icon/junctionbox_fix(src, I, 20), user)
			if(3)
				if (broken == 1 && open == 1)
					user.shock(src, rand(5000, 15000), "chest", 1)
					if (istype(I, /obj/item/cable_coil))
						actions.start(new /datum/action/bar/icon/junctionbox_fix(src, I, 30), user)
			if(4)
				if (broken == 1 && open == 1)
					user.shock(src, rand(5000, 15000), "chest", 1)
					if (istool(I, TOOL_SNIPPING))
						actions.start(new /datum/action/bar/icon/junctionbox_fix(src, I, 20), user)
			if(5)
				if (broken == 1 && open == 1)
					user.shock(src, rand(5000, 15000), "chest", 1)
					if (istool(I, TOOL_SCREWING))
						actions.start(new /datum/action/bar/icon/junctionbox_fix(src, I, 30), user)

	proc/Breakdown()
		src.broken = 1
		src.repairstate = 1
		src.desc = "You should start by removing the outer screws from the casing. Be sure to wear some insulated gloves!"

	proc/Repair()
		src.broken = 0
		src.repairstate = 0

	update_icon()
		if (src.open == 1)
			src.icon_state = src.iconopen

		else
			src.open = 0
			src.icon_state = src.iconclosed

	process()
		if(broken == 1)
			var/obj/sparks = new /obj/effects/sparks/end
			sparks.set_loc(src.loc)
			playsound(src.loc, "sparks", 100, 1)
			var/area/TT = get_area(src)
			if(isarea(TT))
				attached = locate() in TT
			if(attached)
				var/datum/powernet/PN = attached.get_powernet()
				if(PN)
					var/drained = min ( drain_rate, (PN.avail - PN.newload) )
					PN.newload += drained
					power_drained += drained

					if(drained < drain_rate)
						for(var/obj/machinery/power/terminal/T in PN.nodes)
							if(istype(T.master, /obj/machinery/power/apc))
								var/obj/machinery/power/apc/A = T.master
								if(A.operating && A.cell)
									A.cell.charge = max(0, A.cell.charge - 50)
									power_drained += 50

				if(power_drained > max_power * 0.95)
					playsound(src, 'sound/effects/screech.ogg', 50, TRUE, 1)
				if(power_drained >= max_power)
					processing_items.Remove(src)
					explosion(src, src.loc, 3,6,9,12)
					qdel(src)

/obj/machinery/junctionbox/varianta
	icon_state = "junctionbox3"
	iconopen = "junctionbox3_open"
	iconclosed = "junctionbox3"

/obj/machinery/junctionbox/variantb
	icon_state = "junctionbox2"
	iconopen = "junctionbox2_open"
	iconclosed = "junctionbox2"

/obj/machinery/communicationstower
	icon = 'icons/obj/large/32x64.dmi'
	name = "Communications Tower"
	icon_state = "commstower"
	density = 0
	anchored = ANCHORED_ALWAYS
	var/health = 100
	var/maxhealth = 100
	var/broken = 0
	bound_width = 32
	bound_height = 32

	ex_act(severity)
		switch(severity)
			if(1)
				change_health(-maxhealth)
				return
			if(2)
				change_health(-50)
				return
			if(3 to INFINITY)
				change_health(-35)
				return

	attackby(var/obj/item/I, var/mob/user)
		user.lastattacked = get_weakref(src)
		..()
		if (broken == 0)
			change_health(-I.force)
			return
		else
			return

	proc/change_health(var/change = 0)
		health = clamp(health+change, 0, maxhealth)
		if (broken == 1)
			return
		if(health == 0)
			icon_state = "commstower_broken"
			broken = 1
			random_events.force_event("Communications Malfunction")

/obj/machinery/magneticbeacon
	icon = 'icons/obj/large/32x64.dmi'
	name = "Magnetic Tether"
	icon_state = "magbeacon"
	desc = "A rather delicate magnetic tether array. It allows people to safely explore the ocean around NSS Manta while carrying a magnetic attachment point."
	density = 0
	anchored = ANCHORED_ALWAYS
	var/health = 100
	var/maxhealth = 100
	var/broken = 0
	var/repairstate = 0
	bound_width = 32
	bound_height = 32
	appearance_flags = TILE_BOUND | PIXEL_SCALE

	ex_act(severity)
		switch(severity)
			if(1)
				change_health(-maxhealth)
				return
			if(2)
				change_health(-50)
				return
			if(3 to INFINITY)
				change_health(-35)
				return

	attackby(var/obj/item/I, var/mob/user)
		user.lastattacked = get_weakref(src)
		..()
		if (broken == 0)
			change_health(-I.force)
			return
		else
			switch(repairstate)
				if(1)
					if (broken == 1)
						user.shock(src, rand(5000, 15000), "chest", 1)
						if (istool(I, TOOL_SCREWING))
							actions.start(new /datum/action/bar/icon/magnettether_fix(src, I, 30), user)
				if(2)
					if (broken == 1)
						user.shock(src, rand(5000, 15000), "chest", 1)
						if (istool(I, TOOL_SNIPPING))
							actions.start(new /datum/action/bar/icon/magnettether_fix(src, I, 20), user)
				if(3)
					if (broken == 1)
						user.shock(src, rand(5000, 15000), "chest", 1)
						if (istype(I, /obj/item/cable_coil))
							actions.start(new /datum/action/bar/icon/magnettether_fix(src, I, 30), user)
				if(4)
					if (broken == 1)
						user.shock(src, rand(5000, 15000), "chest", 1)
						if (istool(I, TOOL_SNIPPING))
							actions.start(new /datum/action/bar/icon/magnettether_fix(src, I, 20), user)
				if(5)
					if (broken == 1)
						user.shock(src, rand(5000, 15000), "chest", 1)
						if (istool(I, TOOL_SCREWING))
							actions.start(new /datum/action/bar/icon/magnettether_fix(src, I, 30), user)

	proc/change_health(var/change = 0)
		health = clamp(health+change, 0, maxhealth)
		if (broken == 1)
			return
		if(health == 0)
			icon_state = "magbeacon_broken"
			broken = 1
			repairstate = 1
			MagneticTether = 0
			src.desc = "You should start by removing the outer screws from the casing. Be sure to wear some insulated gloves!"
			playsound_global(world, 'sound/effects/manta_alarm.ogg', 90)
			command_alert("The Magnetic tether has suffered critical damage aboard NSS Manta. Jetpacks equipped with magnetic attachments are now offline, please do not venture out into the ocean until the tether has been repaired.", "Magnetic Tether Damaged", alert_origin = ALERT_STATION)

/obj/miningteleporter
	name = "Experimental long-range mining teleporter"
	desc = "Well this looks somewhat unsafe."
	icon = 'icons/misc/32x64.dmi'
	icon_state = "englrt"
	density = 0
	anchored = ANCHORED
	var/recharging =0
	var/id = "shuttle" //The main location of the teleporter
	var/recharge = 20 //A short recharge time between teleports
	var/busy = 0
	layer = 2
	bound_height = 32
	bound_width = 32

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING


	attack_ai(mob/user as mob)
		return attack_hand(user)

	attack_hand(mob/user)
		if(busy) return
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		src.add_dialog(user)
		add_fingerprint(user)
		busy = 1
		FLICK("englrt-act", src)
		playsound(src, 'sound/machines/lrteleport.ogg', 60, TRUE)
		animate_teleport(user)
		SPAWN(1 SECOND)
		teleport(user)
		busy = 0

	proc/teleport(mob/user)
		for_by_tcl(S, /obj/miningteleporter)
			if(S.id == src.id && S != src)
				if(recharging == 1)
					return 1
				else
					S.recharging = 1
					src.recharging = 1
					user.set_loc(S.loc)
					showswirl(user.loc)
					SPAWN(recharge)
						S.recharging = 0
						src.recharging = 0
				return
/obj/item/rddiploma
	name = "RD's diploma"
	icon = 'icons/obj/items/items.dmi'
	desc = ".. Upon closer inspection this degree seems to be fake! Who could have guessed!"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	icon_state = "rddiploma"
	item_state = "rddiploma"

/obj/item/mdlicense
	name = "MD's medical license"
	icon = 'icons/obj/items/items.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	icon_state = "mdlicense"
	item_state = "mdlicense"

/obj/item/firstbill
	name = "HoP's first bill"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "hopbill"

//CONSTRUCTION WORKER STUFF//

/obj/item/sledgehammer
	name = "sledgehammer"
	desc = "A heavy hammer that takes great deal of strenght to wield."
	icon_state = "sledgehammer"
	item_state = "sledgehammer"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	two_handed = 1
	click_delay = 30
	force = 50

	New()
		..()
		BLOCK_SETUP(BLOCK_ROD)

/obj/item/clothing/head/constructioncone
	desc = "Caution!"
	name = "construction cone"
	icon = 'icons/obj/construction.dmi'
	icon_state = "cone_1"
	force = 1
	throwforce = 3
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	flags = TABLEPASS
	stamina_damage = 15
	stamina_cost = 8
	stamina_crit_chance = 10
	max_stack = 5
	item_state = "cone_1"
	wear_state = "cone_hat_1"
	hat_offset_y = 8

	setupProperties()
		..()
		setProperty("coldprot", 0) // it has a hole on top, after all
		setProperty("heatprot", 0)
		setProperty("meleeprot_head", 2)

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message(SPAN_NOTICE("[user] begins gathering up [src]\s!"))

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		UpdateStackAppearance()
		boutput(user, SPAN_NOTICE("You finish gathering up [src]\s."))

	attack_hand(mob/user)
		if((user.r_hand == src || user.l_hand == src) && src.amount > 1)

			if (!in_interact_range(src, user)) //no walking away
				return

			var/obj/item/clothing/head/constructioncone/new_stack = split_stack(1)
			if (!istype(new_stack))
				boutput(user, SPAN_ALERT("Invalid entry, try again."))
				return
			user.put_in_hand_or_drop(new_stack)
			new_stack.add_fingerprint(user)
			boutput(user, SPAN_NOTICE("You take 1 cone from the stack, leaving [src.amount] cones behind."))
		else
			..(user)


	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/clothing/head/constructioncone))
			if (src.loc == user)
				if (ishuman(user))
					var/mob/living/carbon/human/H = user
					if (H.head == src)
						boutput(user, SPAN_ALERT("You can't stack cones when they are on your head!"))
						return
			var/success = stack_item(I)
			if (!success)
				boutput(user, SPAN_ALERT("You can't put any more cones in this stack!"))
			else
				if(!user.is_in_hands(src))
					user.put_in_hand(src)
				if(isrobot(user))
					boutput(user, SPAN_NOTICE("You add [success] cones to the stack. It now has [I.amount] cones."))
				else
					boutput(user, SPAN_NOTICE("You add [src.amount - success] cones to the stack. It now has [src.amount] cones."))

	_update_stack_appearance()
		src.amount = clamp(src.amount, 1, src.max_stack)
		icon_state = "cone_[src.amount]"
		item_state = "cone_[src.amount]"
		wear_state = "cone_hat_[src.amount]"

	afterattack(var/turf/T, var/mob/user, reach, params)
		if (!isturf(user.loc))
			return

		if (BOUNDS_DIST(T, user) > 0)
			boutput(user, SPAN_NOTICE("You can't setup [src] that far away."))
			return

		if (!istype(T, /turf/simulated/floor))
			return

		var/obj/item/clothing/head/constructioncone/cone = new /obj/item/clothing/head/constructioncone
		src.change_stack_amount(-1)

		var/pox = cone.pixel_x
		var/poy = cone.pixel_y

		if (params)
			if (islist(params) && params["icon-y"] && params["icon-x"])
				pox = text2num(params["icon-x"]) - 16
				poy = text2num(params["icon-y"]) - 16

		cone.pixel_x = pox
		cone.pixel_y = poy
		cone.set_loc(T)
		playsound(cone, 'sound/impact_sounds/tube_bonk.ogg', 20, TRUE, pitch=0.5)
		..()

	examine()
		. = ..()
		. += "There are [src.amount] cones on this stack."

/obj/effect/boommarker
	name = ""
	icon = 'icons/effects/64x64.dmi'
	icon_state = "impact_marker"
	density = 0
	anchored = ANCHORED
	mouse_opacity = 0
	desc = "Uh oh.."
	pixel_x = -16
	pixel_y = -16

//Manta specific plants, straight copy, does not use the slow-down mechanic due to the alpha.

/obj/sea_plant_manta
	name = "sea plant"
	icon = 'icons/obj/sealab_objects.dmi'
	desc = "It's thriving."
	anchored = ANCHORED
	density = 0
	layer = EFFECTS_LAYER_UNDER_1
	var/database_id = null
	var/random_color = 1
	var/drop_type = 0
	event_handler_flags = USE_FLUID_ENTER

	New()
		..()
		if (src.random_color)
			src.color = random_saturated_hex_color()
		if (!src.pixel_x)
			src.pixel_x = rand(-8,8)
		if (!src.pixel_y)
			src.pixel_y = rand(-8,8)
		START_TRACKING

	attackby(obj/item/W, mob/user)
		if (drop_type && issnippingtool(W))
			var/obj/item/drop = new drop_type
			drop.set_loc(src.loc)
			src.visible_message(SPAN_ALERT("[user] cuts down [src]."))
			qdel(src)
		..()

	disposing()
		STOP_TRACKING
		return ..()


/obj/sea_plant_manta/Uncrossed(atom/movable/A as mob|obj)
	..()
	if (ismob(A))
		if (A.dir & SOUTH) //If mob exiting south, dont break perspective
			src.layer = 3.9
		else
			src.layer = EFFECTS_LAYER_UNDER_1

//TODO : make all plants drop things!
/obj/sea_plant_manta/bulbous
	name = "bulbous coral"
	icon_state = "bulbous"
	database_id = "sea_plant_bluecoral"
	drop_type = /obj/item/material_piece/coral

/obj/sea_plant_manta/branching
	name = "branching coral"
	icon_state = "branching"
	database_id = "sea_plant_branchcoral"
	drop_type = /obj/item/material_piece/coral

/obj/sea_plant_manta/coralfingers
	name = "stylophora coral"
	icon_state = "coralfingers"
	database_id = "sea_plant_fingercoral"
	drop_type = /obj/item/material_piece/coral

/obj/sea_plant_manta/anemone
	name = "sea anemone"
	icon_state = "anemone"
	database_id = "sea_plant_anemone"

/obj/sea_plant_manta/anemone/lit
	name = "glowing sea anemone"
	icon_state = "anemone_lit"
	database_id = "sea_plant_lit_anemone"
	var/datum/light/point/light = 0
	var/init = 0

	disposing()
		light = 0
		..()

	initialize()
		..()
		if (!init)
			init = 1
			var/datum/color/C = new
			C.from_hex(src.color)
			if (!light)
				light = new
				light.attach(src)
			light.set_brightness(1)
			light.set_color(C.r/255, C.g * 0.25/255, C.b * 0.25/255)
			light.set_height(3)
			light.enable()

/obj/sea_plant_manta/kelp
	name = "kelp"
	icon_state = "kelp"
	database_id = "sea_plant_kelp"
	random_color = 0

/obj/sea_plant_manta/seaweed
	name = "seaweed"
	icon_state = "seaweed"
	database_id = "sea_plant_seaweed"
	random_color = 0
	drop_type = /obj/item/reagent_containers/food/snacks/ingredient/seaweed

/obj/sea_plant_manta/tubesponge
	name = "tube sponge"
	icon_state = "tubesponge"
	database_id = "sea_plant_tubesponge"
	drop_type = /obj/item/sponge

/obj/sea_plant_manta/tubesponge/small
	icon_state = "tubesponge_small"
	database_id = "sea_plant_tubesponge-small"


//-------------------------------------------- MANTA COMPATIBLE TURFS HERE --------------------------------------------

/turf/space/fluid/manta
	var/stateOn = ""
	var/stateOff = ""
	var/on = TRUE
	var/list/L = list()

	New()
		START_TRACKING
		. = ..()
		stateOff = "manta_sand"
		stateOn = "[stateOff]_scroll"
		icon_state = stateOn
		on = TRUE

	Del()
		STOP_TRACKING
		. = ..()

	ex_act(severity)
		return

	proc/setScroll(var/newOn=0)
		if(newOn)
			icon_state = stateOn
			on = newOn
		else
			icon_state = stateOff
			on = newOn

	Entered(atom/movable/Obj,atom/OldLoc)
		if(isnull(OldLoc)) // hack, remove later pls thx
			return ..(Obj, OldLoc)
		if(y <= 3 || y >= world.maxy - 3 || x <= 3 || x >= world.maxx - 3)
			if (!L || length(L) == 0)
				for(var/turf/T in get_area_turfs(/area/trench_landing))
					L+=T

			if (istype(Obj,/obj/torpedo_targeter) ||istype(Obj,/mob/dead) || istype(Obj,/mob/living/intangible) || istype(Obj, /obj/lattice) || istype(Obj, /obj/cable/reinforced) || istype(Obj, /obj/arrival_missile))
				return

			return_if_overlay_or_effect(Obj)

			if (length(L) && !istype(Obj,/obj/overlay) && !istype(Obj,/obj/torpedo_targeter))
				Obj.set_loc(pick(L))
		..(Obj,OldLoc)

//Manta
/turf/space/fluid/manta/nospawn
	spawningFlags = null

//-------------------------------------------- MANTA COMPATIBLE DATUMS HERE --------------------------------------------
//REPAIRING:  wrench > screwdriver > crowbar > wires > welder > wrench > screwdriver > sheet > welder

/datum/action/bar/icon/propeller_fix
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 200
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/machinery/mantapropulsion/propeller
	var/obj/item/the_tool

	New(var/obj/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			propeller = O
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.mind.assigned_role == "Chief Engineer")
				duration = round(duration / 2)
			if (H.mind.assigned_role == "Engineer")
				duration = round(duration / 2)

	onUpdate()
		..()
		if (propeller == null || the_tool == null || owner == null || BOUNDS_DIST(owner, propeller) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		if (propeller.repairstate == 1)
			playsound(propeller, 'sound/items/Ratchet.ogg', 50, TRUE)
			owner.visible_message(SPAN_NOTICE("[owner] begins to loosen the outer bolts."))
		if (propeller.repairstate == 2)
			playsound(propeller, 'sound/items/Screwdriver.ogg', 50, TRUE)
			owner.visible_message(SPAN_NOTICE("[owner] begins to unscrew the casings screws.."))
		if (propeller.repairstate == 3)
			owner.visible_message(SPAN_NOTICE("[owner] begins prying the outer casing."))
			playsound(propeller, 'sound/items/Crowbar.ogg', 60, TRUE)
		if (propeller.repairstate == 4)
			playsound(propeller, 'sound/impact_sounds/Generic_Stab_1.ogg', 60, TRUE)
			owner.visible_message(SPAN_NOTICE("[owner] begins reconnecting and replacing the damaged cables."))
		if (propeller.repairstate == 5)
			the_tool:try_weld(owner,0,-1,0,0)
			owner.visible_message(SPAN_NOTICE("[owner] begins to weld the connection points and soldering the control board."))
		if (propeller.repairstate == 6)
			playsound(propeller, 'sound/items/Ratchet.ogg', 60, TRUE)
			owner.visible_message(SPAN_NOTICE("[owner] begins securing the bolts to the casing."))
		if (propeller.repairstate == 7)
			playsound(propeller, 'sound/items/Screwdriver.ogg', 50, TRUE)
			owner.visible_message(SPAN_NOTICE("[owner] places the casing back on and begins securing the casing and its screws back on."))
		if (propeller.repairstate == 8)
			playsound(propeller, 'sound/items/Deconstruct.ogg', 50, TRUE)
			owner.visible_message(SPAN_NOTICE("[owner] begins constructing replacements for the propellers.."))
		if (propeller.repairstate == 9)
			the_tool:try_weld(owner,0,-1,0,0)
			owner.visible_message(SPAN_NOTICE("[owner] begins to weld the replacement propellers on."))
	onEnd()
		..()
		if (propeller.repairstate == 1)
			propeller.repairstate = 2
			boutput(owner, SPAN_NOTICE("You remove the bolts."))
			playsound(propeller, 'sound/items/Deconstruct.ogg', 80, TRUE)
			propeller.desc = "It's totaled, the securing bolts are off, just have to unscrew the casing screws now."
			return
		if (propeller.repairstate == 2)
			propeller.repairstate = 3
			boutput(owner, SPAN_NOTICE("You remove the screws."))
			playsound(propeller, 'sound/items/Deconstruct.ogg', 80, TRUE)
			propeller.desc = "It's totaled. The casing looks like it can be pried off now."
			return
		if (propeller.repairstate == 3)
			propeller.repairstate = 4
			boutput(owner, SPAN_NOTICE("You pry the outer casing off."))
			playsound(propeller, 'sound/items/Deconstruct.ogg', 80, TRUE)
			propeller.desc = "It's totaled. The casing's off and the motor wiring is exposed, might need replacing."
			return
		if (propeller.repairstate == 4)
			propeller.repairstate = 5
			boutput(owner, SPAN_NOTICE("You reconnect the damaged cables and re-wire the propellers internal motor."))
			playsound(propeller, 'sound/items/Deconstruct.ogg', 80, TRUE)
			propeller.desc = "It's totaled. The wiring connectors needs to be welded onto the motor now."
			return
		if (propeller.repairstate == 5)
			propeller.repairstate = 6
			boutput(owner, SPAN_NOTICE("You finish welding the points and the board."))
			playsound(propeller, 'sound/items/Deconstruct.ogg', 80, TRUE)
			propeller.desc = "It's partially fixed. the wiring looks good, better secure it with bolts before moving on."
			return
		if (propeller.repairstate == 6)
			propeller.repairstate = 7
			boutput(owner, SPAN_NOTICE("You secure the bolts back to the casing."))
			playsound(propeller, 'sound/items/Deconstruct.ogg', 80, TRUE)
			propeller.desc = "It's partially fixed. the wiring looks good, better secure it with screws before moving on.."
			return
		if (propeller.repairstate == 7)
			propeller.repairstate = 8
			boutput(owner, SPAN_NOTICE("You finish placing the casing back on and successfully attach it with screws."))
			playsound(propeller, 'sound/items/Deconstruct.ogg', 80, TRUE)
			propeller.desc = "It's partially fixed.The casing's closed, but the propellers are mangled, will probably need 5 sheets of metal to weld on a replacement."
			return
		if (propeller.repairstate == 8)
			propeller.repairstate = 9
			boutput(owner, SPAN_NOTICE("You finish building the replacement propellers."))
			playsound(propeller, 'sound/items/Deconstruct.ogg', 80, TRUE)
			propeller.desc = "It's nearly fixed. The replacement propellers are ready, just have to weld them on now."
			if (the_tool != null)
				the_tool.amount -= 5
				if(the_tool.amount <= 0)
					qdel(the_tool)
			return

		if (propeller.repairstate == 9)
			propeller.repairstate = 0
			propeller.broken = 0
			boutput(owner, SPAN_NOTICE("You finish welding  the replacement propellers,the propeller is again in working condition."))
			playsound(propeller, 'sound/items/Deconstruct.ogg', 80, TRUE)
			propeller.health = 100
		if (mantaMoving == 1)
			propeller.on = 1
			propeller.icon_state = "bigsea_propulsion"
		else
			propeller.on = 0
			propeller.icon_state = "bigsea_propulsion_off"


//REPAIRING:  screwdriver > wirecutters > cable coil > wirecutters > multitool > screwdriver

/datum/action/bar/icon/junctionbox_fix
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 200
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/machinery/junctionbox/box
	var/obj/item/the_tool

	New(var/obj/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			box = O
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.mind.assigned_role == "Chief Engineer")
				duration = round(duration / 2)
			if (H.mind.assigned_role == "Engineer")
				duration = round(duration / 2)

	onUpdate()
		..()
		if (box == null || the_tool == null || owner == null || BOUNDS_DIST(owner, box) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		if (box.repairstate == 1)
			playsound(box, 'sound/items/Screwdriver.ogg', 100, TRUE)
			owner.visible_message(SPAN_NOTICE("[owner] begins to unscrew the casings screws."))
		if (box.repairstate == 2)
			playsound(box, 'sound/items/Wirecutter.ogg', 100, TRUE)
			owner.visible_message(SPAN_NOTICE("[owner] begins cutting out the damaged cables."))
		if (box.repairstate == 3)
			playsound(box, 'sound/impact_sounds/Generic_Stab_1.ogg', 60, TRUE)
			owner.visible_message(SPAN_NOTICE("[owner] begins reconnecting and replacing the damaged cables."))
		if (box.repairstate == 4)
			playsound(box, 'sound/items/Wirecutter.ogg', 100, TRUE)
			owner.visible_message(SPAN_NOTICE("[owner] begins cutting out the excess bits of cable."))
		if (box.repairstate == 5)
			playsound(box, 'sound/items/Screwdriver.ogg', 100, TRUE)
			owner.visible_message(SPAN_NOTICE("[owner] begins to screw the casings screws back on."))
	onEnd()
		..()
		if (box.repairstate == 1)
			box.repairstate = 2
			boutput(owner, SPAN_NOTICE("You successfully remove the screws."))
			playsound(box, 'sound/items/Deconstruct.ogg', 80, TRUE)
			box.desc = "Perhaps you should cut out the damaged wires?"
			return
		if (box.repairstate == 2)
			boutput(owner, SPAN_NOTICE("You cut out the damaged cables. "))
			playsound(box, 'sound/items/Deconstruct.ogg', 80, TRUE)
			box.repairstate = 3
			box.desc = "You should reconnect the damaged wires by adding some new wire."
			return
		if (box.repairstate == 3)
			box.repairstate = 4
			boutput(owner, SPAN_NOTICE("You reconnect the damaged cables and re-wire the junction box."))
			playsound(box, 'sound/items/Deconstruct.ogg', 80, TRUE)
			box.desc = "You should maybe cut off the excess bits of cable out."
			return
		if (box.repairstate == 4)
			boutput(owner, SPAN_NOTICE("You cut out excess bits of cable."))
			playsound(box, 'sound/items/Deconstruct.ogg', 80, TRUE)
			box.repairstate = 5
			box.desc = "Alright, that should do it. Just have to screw the casing back on now."
			return
		if (box.repairstate == 5)
			box.repairstate = 0
			box.broken = 0
			boutput(owner, SPAN_NOTICE("You successfully screw the casing back on."))
			playsound(box, 'sound/items/Deconstruct.ogg', 80, TRUE)
			box.desc = "An electrical junction box is an enclosure housing electrical connections, to protect the connections and provide a safety barrier."
			return

//REPAIRING:  screwdriver > wirecutters > cable coil > wirecutters > multitool > screwdriver

/datum/action/bar/icon/magnettether_fix
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 200
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/machinery/magneticbeacon/magnet
	var/obj/item/the_tool

	New(var/obj/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			magnet = O
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.mind.assigned_role == "Chief Engineer")
				duration = round(duration / 2)
			if (H.mind.assigned_role == "Engineer")
				duration = round(duration / 2)

	onUpdate()
		..()
		if (magnet == null || the_tool == null || owner == null || BOUNDS_DIST(owner, magnet) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		if (magnet.repairstate == 1)
			playsound(magnet, 'sound/items/Screwdriver.ogg', 100, TRUE)
			owner.visible_message(SPAN_NOTICE("[owner] begins to unscrew the casings screws."))
		if (magnet.repairstate == 2)
			playsound(magnet, 'sound/items/Wirecutter.ogg', 100, TRUE)
			owner.visible_message(SPAN_NOTICE("[owner] begins cutting out the damaged cables."))
		if (magnet.repairstate == 3)
			playsound(magnet, 'sound/impact_sounds/Generic_Stab_1.ogg', 60, TRUE)
			owner.visible_message(SPAN_NOTICE("[owner] begins reconnecting and replacing the damaged cables."))
		if (magnet.repairstate == 4)
			playsound(magnet, 'sound/items/Wirecutter.ogg', 100, TRUE)
			owner.visible_message(SPAN_NOTICE("[owner] begins cutting out the excess bits of cable."))
		if (magnet.repairstate == 5)
			playsound(magnet, 'sound/items/Screwdriver.ogg', 100, TRUE)
			owner.visible_message(SPAN_NOTICE("[owner] begins to screw the casings screws back on."))
	onEnd()
		..()
		if (magnet.repairstate == 1)
			magnet.repairstate = 2
			boutput(owner, SPAN_NOTICE("You successfully remove the screws."))
			playsound(magnet, 'sound/items/Deconstruct.ogg', 80, TRUE)
			magnet.desc = "Perhaps you should cut out the damaged wires?"
			return
		if (magnet.repairstate == 2)
			boutput(owner, SPAN_NOTICE("You cut out the damaged cables. "))
			playsound(magnet, 'sound/items/Deconstruct.ogg', 80, TRUE)
			magnet.repairstate = 3
			magnet.desc = "You should reconnect the damaged wires by adding some new wire."
			return
		if (magnet.repairstate == 3)
			magnet.repairstate = 4
			boutput(owner, SPAN_NOTICE("You reconnect the damaged cables and re-wire the junction box."))
			playsound(magnet, 'sound/items/Deconstruct.ogg', 80, TRUE)
			magnet.desc = "You should maybe cut off the excess bits of cable out."
			return
		if (magnet.repairstate == 4)
			boutput(owner, SPAN_NOTICE("You cut out excess bits of cable."))
			playsound(magnet, 'sound/items/Deconstruct.ogg', 80, TRUE)
			magnet.repairstate = 5
			magnet.desc = "Alright, that should do it. Just have to screw the casing back on now."
			return
		if (magnet.repairstate == 5)
			magnet.repairstate = 0
			magnet.broken = 0
			magnet.icon_state = "magbeacon"
			boutput(owner, SPAN_NOTICE("You successfully screw the casing back on."))
			playsound(magnet, 'sound/items/Deconstruct.ogg', 80, TRUE)
			MagneticTether = 1
			magnet.health = 100
			magnet.desc = "A rather delicate magnetic tether array. It allows people to safely explore the ocean around NSS Manta while carrying a magnetic attachment point."
			command_alert("The Magnetic tether has been successfully repaired. Magnetic attachment points are online once again.", "Magnetic Tether Repaired", alert_origin = ALERT_STATION)
			return

#ifdef MOVING_SUB_MAP //Defined in the map-specific .dm configuration file.
/datum/random_event/special/mantacommsdown
	name = "Communications Malfunction"

	event_effect(var/source)
		..()
		if (random_events.announce_events)
			command_alert("Communication tower has been severely damaged aboard NSS Manta. Ships automated communication system will now attempt to re-establish signal through backup channel. We estimate this will take eight to ten minutes.", "Communications Malfunction", alert_origin = ALERT_STATION)
			playsound_global(world, 'sound/effects/commsdown.ogg', 100)
			sleep(rand(80,100))
			signal_loss += 100
			sleep(rand(4800,6000))
			signal_loss -= 100

			if (random_events.announce_events)
				command_alert("Communication link has been established with Oshan Laboratory through backkup channel. Communications should be restored to normal aboard NSS Manta.", "Communications Restored", alert_origin = ALERT_STATION)
			else
				message_admins(SPAN_INTERNAL("Manta Comms event ceasing."))


/datum/random_event/major/electricmalfunction
	name = "Electrical Malfunction"

	event_effect()
		..()
		var/obj/machinery/junctionbox/J = pick(by_type[/obj/machinery/junctionbox])
		if (J.broken)
			return
		J.Breakdown()
		command_alert("Certain junction boxes are malfunctioning around NSS Manta. Please seek out and repair the malfunctioning junction boxes before they lead to power outages.", "Electrical Malfunction", alert_origin = ALERT_STATION)

/datum/random_event/special/namepending
	name = "Name Pending"

	event_effect()
		..()
		var/list/eligible = by_type[/obj/machinery/mantapropulsion].Copy()
		for(var/i=0, i<3, i++)
			var/obj/machinery/mantapropulsion/big/P = pick(eligible)
			P.Breakdown()
			eligible.Remove(P)
			sleep(1 SECOND)

		new /obj/effect/boommarker(pick_landmark(LANDMARK_BIGBOOM))
#endif


//-------------------------------------------- MANTA COMPATIBLE AREAS HERE --------------------------------------------
//Also ugh, duplicate code.

/area/mantaSpace
	icon_state = "blue"

	// **************
	Entered(atom/movable/Obj,atom/OldLoc)
		addManta(Obj)
		return ..(Obj, OldLoc)

	Exited(atom/movable/Obj, atom/newLoc)
		removeManta(Obj)
		return ..(Obj, newLoc)
	// **************

/area
	proc/removeManta(atom/movable/Obj)
		mantaPushList.Remove(Obj)
		Obj.temp_flags &= ~MANTA_PUSHING
		return
	proc/addManta(atom/movable/Obj)
		if(!istype(Obj, /obj/overlay) && !istype(Obj, /obj/machinery/light_area_manager) && istype(Obj, /atom/movable))
			if(!(Obj.temp_flags & MANTA_PUSHING) && !(Obj.event_handler_flags & IMMUNE_MANTA_PUSH) && !Obj.anchored)
				mantaPushList.Add(Obj)
				Obj.temp_flags |= MANTA_PUSHING
		return

/area/propellerpower
	icon_state = "propeller"
	name = "Propellers"
	color = OCEAN_COLOR

	Entered(atom/movable/Obj,atom/OldLoc)
		addManta(Obj)
		return ..(Obj, OldLoc)

	Exited(atom/movable/Obj, atom/newLoc)
		removeManta(Obj)
		return ..(Obj, newLoc)


/area/supply/sell_point/manta
	ambient_light = OCEAN_LIGHT

	Entered(atom/movable/Obj,atom/OldLoc)
		addManta(Obj)
		return ..(Obj, OldLoc)

	Exited(atom/movable/Obj, atom/newLoc)
		removeManta(Obj)
		return ..(Obj, newLoc)

/area/supply/spawn_point/manta
	color = OCEAN_COLOR
	requires_power = 0
	force_fullbright = 0
	luminosity = 0

	Entered(atom/movable/Obj,atom/OldLoc)
		addManta(Obj)
		return ..(Obj, OldLoc)

	Exited(atom/movable/Obj, atom/newLoc)
		removeManta(Obj)
		return ..(Obj, newLoc)

/area/station/shield_zone/manta
	Entered(atom/movable/Obj,atom/OldLoc)
		addManta(Obj)
		return ..(Obj, OldLoc)

	Exited(atom/movable/Obj, atom/newLoc)
		removeManta(Obj)
		return ..(Obj, newLoc)

/area/shuttle/merchant_shuttle/left_station/cogmap/manta
	filler_turf = "/turf/space/fluid/manta"

	Entered(atom/movable/Obj,atom/OldLoc)
		addManta(Obj)
		return ..(Obj, OldLoc)

	Exited(atom/movable/Obj, atom/newLoc)
		removeManta(Obj)
		return ..(Obj, newLoc)

/area/shuttle/merchant_shuttle/right_station/cogmap/manta
	filler_turf = "/turf/space/fluid/manta"

	Entered(atom/movable/Obj,atom/OldLoc)
		addManta(Obj)
		return ..(Obj, OldLoc)

	Exited(atom/movable/Obj, atom/newLoc)
		removeManta(Obj)
		return ..(Obj, newLoc)

/area/station/com_dish/manta
	Entered(atom/movable/Obj,atom/OldLoc)
		addManta(Obj)
		return ..(Obj, OldLoc)

	Exited(atom/movable/Obj, atom/newLoc)
		removeManta(Obj)
		return ..(Obj, newLoc)

/area/shuttle/john/diner/manta
	filler_turf = "/turf/space/fluid/manta"

	Entered(atom/movable/Obj,atom/OldLoc)
		addManta(Obj)
		return ..(Obj, OldLoc)

	Exited(atom/movable/Obj, atom/newLoc)
		removeManta(Obj)
		return ..(Obj, newLoc)

/area/station/abandonedship
	name = "Abandoned ship"
	icon_state = "yellow"

//******************************************** MANTA SECRET STUFF HERE ********************************************



//******************************************** NSS POLARIS STUFF ********************************************

/area/crashsite
	name = "Crash site"
	icon_state = "green"

/area/wrecknsspolaris
	name = "Wreck of the NSS Polaris"
	icon_state = "green"
	sound_group = "polaris"
	teleport_blocked = 1
	sound_loop = 'sound/ambience/loop/Polarisloop.ogg'

/area/wrecknsspolaris/vault
	name = "NSS Polaris Vault"
	requires_power = 0

/area/wrecknsspolaris/outside
	name = "Ouside the Wreck"
	icon_state = "blue"
	ambient_light = OCEAN_LIGHT

/area/wrecknsspolaris/outside/teleport
	name = "Outer Wreck (with teleport)"

/area/wrecknsspolaris/outside/back
	name = "Back of the Wreck"

/obj/item/parts/human_parts/arm/right/polaris
	name = "misplaced right arm"
	desc = "Someone might need a hand with this."

/obj/machinery/handscanner
	name = "Hand Scanner"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "handscanner"
	var/id = "polarisdoor"
	var/used = 0

/obj/machinery/hanscanner/New()
	..()
	UnsubscribeProcess()


/obj/machinery/handscanner/attackby(obj/item/W, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	if (used == 0)
		if(istype(W, /obj/item/parts/human_parts/arm/right/polaris))
			user.visible_message(SPAN_NOTICE("The [src] accepts the biometrics of the hand and beeps, granting you access."))
			playsound(src.loc, 'sound/effects/handscan.ogg', 50, 1)
			for_by_tcl(M, /obj/machinery/door/airlock)
				if (M.id == src.id)
					if (M.density)
						M.open()
						M.operating = -1
						used = 1



/obj/machinery/handscanner/attack_hand(mob/user)
	src.add_fingerprint(user)
	playsound(src.loc, 'sound/effects/handscan.ogg', 50, 1)
	if (used == 0)
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.limbs && (istype(H.limbs.r_arm, /obj/item/parts/human_parts/arm/right/polaris)))
				user.visible_message(SPAN_NOTICE("The [src] accepts the biometrics of the hand and beeps, granting you access."))

				for (var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
					if (M.id == src.id)
						if (M.density)
							M.open()

				for_by_tcl(M, /obj/machinery/door/airlock)
					if (M.id == src.id)
						if (M.density)
							M.open()
							M.operating = -1
							used = 1
			else
				boutput(user, SPAN_ALERT("Invalid biometric profile. Access denied."))
	else
		boutput(user, SPAN_ALERT("The door has already been opened. It looks like the mechanism has jammed for good."))


/obj/item/storage/secure/ssafe/polaris
	name = "captain's lockbox"
	configure_mode = 0
	random_code = 1
	spawn_contents = list(/obj/item/card/id/polaris,
	/obj/item/paper/manta_polarisnote,/obj/item/reagent_containers/emergency_injector/random,/obj/item/currency/spacecash/thousand,
	/obj/item/currency/spacecash/thousand,/obj/item/currency/spacecash/thousand)

/obj/item/card/id/polaris
	name = "Sergeant's spare ID"
	icon_state = "id_nanotrasen"
	registered = "Sgt. Wilkins"
	assignment = "Sergeant"
	access = list(access_polariscargo,access_heads)
	keep_icon = TRUE

/obj/item/card/id/blank_polaris
	name = "blank Nanotrasen ID"
	icon_state = "id_nanotrasen"
	keep_icon = TRUE

/obj/item/broken_egun
	name = "broken energy gun"
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon = 'icons/obj/items/items.dmi'
	icon_state = "broken_egun"
	desc = "Its a gun that has two modes, stun and kill, although this one is nowhere near working condition."
	item_state = "energy"
	force = 5

/obj/item/blackbox
	name = "flight recorder of NSS Polaris"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	icon = 'icons/obj/items/items.dmi'
	icon_state = "blackbox"
	desc = "A flight recorder is an electronic recording device placed in an spacecraft for the purpose of facilitating the investigation of accidents and incidents. Someone from Nanotrasen would surely want to see this."
	item_state = "electropack"
	force = 5

/turf/unsimulated/floor/polarispit
	name = "deep abyss"
	desc = "You can't see the bottom."
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "pit"
	fullbright = 0
	pathable = 0
	var/falltarget = LANDMARK_FALL_POLARIS
	// this is the code for falling from abyss into ice caves
	// could maybe use an animation, or better text. perhaps a slide whistle ogg?
	New()
		src.AddComponent(/datum/component/pitfall/target_landmark,\
			BruteDamageMax = 50,\
			FallTime = 0 SECONDS,\
			TargetLandmark = src.falltarget)
		..()

	polarispitwall
		icon_state = "pit_wall"

	marj
		name = "dank abyss"
		desc = "The smell rising from it somehow permeates the surrounding water."
		falltarget = LANDMARK_FALL_MARJ

		pitwall
			icon_state = "pit_wall"

//-------------------------------------------- NSS MANTA SECRET VAULT --------------------------------------------

/obj/vaultdoor
	name = "vault door"
	icon = 'icons/obj/large/96x32.dmi'
	icon_state = "vaultdoor_closed"
	density = 1
	anchored = ANCHORED_ALWAYS
	opacity = 1
	bound_width = 96
	appearance_flags = TILE_BOUND | PIXEL_SCALE

/turf/unsimulated/floor/special/fogofcheating
	name = "fog of cheating prevention"
	desc = "Yeah, nice try."
	icon_state = "void_gray"

/area/mantavault
	name = "NSS Manta Secret Vault"
	icon_state = "red"
	teleport_blocked = 1
	sound_loop = 'sound/ambience/loop/manta_vault.ogg'
	sound_group = "vault"

/obj/trigger/mantasecrettrigger
	name = "Confession of a jester."

	var/running = 0
	var/triggered = 0

	on_trigger(var/atom/movable/triggerer)
		//Sanity check
		if(isobserver(triggerer) || running) return
		if (triggered == 0)
			var/mob/M = triggerer
			if(!istype(M))
				return
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if (H.wear_mask && H.head && H.shoes && H.w_uniform)
					if (istype(H.head, /obj/item/clothing/head/jester) && istype(H.wear_mask, /obj/item/clothing/mask/jester) && istype(H.shoes, /obj/item/clothing/shoes/jester) && istype(H.w_uniform, /obj/item/clothing/under/gimmick/jester))
						triggerer.visible_message(SPAN_ALERT("A hidden compartment opens up, revealing a hatch and a ladder."))
						playsound(src.loc, 'sound/effects/polaris_crateopening.ogg', 90, 1,1)
						new /obj/ladder/vaultladder(get_turf(src))
						triggered = 1
						return

/obj/ladder/vaultladder
	id = "vault"
