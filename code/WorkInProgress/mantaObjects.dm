//////////////////TABLE OF CONTENTS//////////////////

///MANTA RELATED LISTS AND GLOBAL VARIABLES///
///MANTA RELATED OBJECTS///
///MANTA RELATED TURFS///
///MANTA RELATED DATUMS (Mainly related to fixing propellers.)///
///MANTA RELATED AREAS///
///MANTA SECRET STUFF///

//******************************************** MANTA COMPATIBLE LISTS HERE ********************************************

var/list/mantaTiles = list()
var/list/mantaBubbles = list()
var/list/mantaPlants = list()
var/list/mantaPropellers = list()
var/list/mantaHeaters = list()
var/list/mantaJunctionbox = list ()
var/list/mantaPushList = list()
var/mantaMoving = 1
var/MagneticTether = 1
var/obj/manta_speed_lever/mantaLever = null

//******************************************** MANTA COMPATIBLE OBJECTS HERE ********************************************

/obj/decal/mantaBubbles
	density = 0
	anchored = 1
	layer =  EFFECTS_LAYER_4
	name = ""
	mouse_opacity = 0

	New()
		mantaBubbles.Add(src)
		return ..()

	disposing()
		mantaBubbles.Remove(src)
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
	anchored = 2
	var/on = 1
	var/lastuse = 0
	var/locked = 1 //Starts off locked.
	req_access = list(access_heads)

	New()
		mantaLever = src
		updateIcon()
		..()
//This crap is here so nothing can destroy it.
	hitby()
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

	attack_hand(mob/user as mob)
		var/diff = world.timeofday - lastuse
		if(diff < 0) diff += 864000 //Wrapping protection.

		if (locked == 1)
			user.show_text("<span class='alert'><b>You must first unlock the lever console with an ID to be able to use it.</b></span>")
			return

		if(mantaIsBroken() && !on)
			user.show_text("<span class='alert'><b>Too many propellers are damaged; you can not move NSS Manta.</b></span>")
			return

		if(diff > 3000)
			lastuse = world.timeofday
			if(on)
				user.show_text("<span class='notice'><b>You turn off the propellers.</b></span>")
				on = 0
				updateIcon()
				command_alert("Attention, NSS Manta is slowing down to a halt. Shutting down propellers.", "NSS Manta Movement Computer")
				mantaSetMove(on)
			else
				user.show_text("<span class='notice'><b>You turn on the propellers.</b></span>")
				on = 1
				world << 'sound/effects/mantamoving.ogg'
				sleep(7 SECONDS)
				updateIcon()
				command_alert("Attention, firing up propellers.  NSS Manta will be on the move shortly.", "NSS Manta Movement Computer")
				mantaSetMove(on)
			return
		else
			user.show_text("<span class='alert'><b>The engine is still busy.</b></span>")


	attack_ai(mob/user as mob)
		return attack_hand(user)

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/device/pda2) && W:ID_card)
			W = W:ID_card
		if(istype(W, /obj/item/card/id))
			if (src.allowed(user))
				user.visible_message("[user] [src.locked ? "unlocks" : "locks"] the access panel.","You [src.locked ? "unlock" : "lock"] the access panel.")
				src.locked = !src.locked
				updateIcon()
			else
				boutput(user, "<span class='alert'>Access denied.</span>")
		else
			..()

		return

	proc/updateIcon()
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
	for(var/obj/machinery/mantapropulsion/A in mantaPropellers)
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
			if(M && M.z == 1) shake_camera(M, 5, 15, 0.2)

	for(var/A in mantaTiles)
		var/turf/space/fluid/manta/T = A
		if (!istype(T))
			mantaTiles.Remove(T)
			continue
		T.setScroll(moving)
	for(var/A in mantaBubbles)
		var/obj/O = A
		O.alpha = (moving ? 255:0)
	for(var/A in mantaPlants)
		var/obj/O = A
		O.alpha = (moving ? 0:255)
	for(var/A in mantaPropellers)
		var/obj/machinery/mantapropulsion/O = A
		O.setOn(moving)

	mantaMoving = moving
	return

/obj/machinery/mantapropulsion
	name = "propeller"
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "sea_propulsion"
	var/stateOn = ""
	var/stateOff = ""
	var/stateDamaged = ""
	var/on = 1
	anchored = 2
	density = 1
	var/health = 100
	var/maxhealth = 100
	var/important = 0
	var/repairstate = 0
	var/broken = 0

	New()
		stateOff = "sea_propulsion_off"
		stateOn = "sea_propulsion"
		icon_state = stateOn
		on = 1
		return .

	disposing()
		mantaPropellers.Remove(src)
		return ..()

	Bumped(atom/AM) //This is stolen straight from the crusher, just making sure that the propellers are actually on.
		var/tm_amt = 0
		var/tg_amt = 0
		var/tw_amt = 0
		var/bblood = 0
		if (mantaMoving == 1)
			if (repairstate == 0)

				if(istype(AM,/obj/item/scrap))
					return

				if(world.timeofday - AM.last_bumped <= 60)
					return

				if(ismob(AM))
					var/mob/M = AM
					for(var/obj/O in M.contents)
						if(isobj(O))
							tm_amt += O.m_amt
							tg_amt += O.g_amt
							tw_amt += O.w_amt
							if(iscarbon(M))
								tw_amt += 5000
								bblood = 2
							else if(issilicon(M))
								tm_amt += 5000
								tg_amt += 1000
						qdel(O)
					logTheThing("combat", M, null, "is ground up in one of Manta's propellers at[log_loc(src)].")
					message_admins("[key_name(M)] is ground up in one of Manta's propellers at [log_loc(src)].")
					M.gib()
				else if(isobj(AM))
					var/obj/B = AM
					tm_amt += B.m_amt
					tg_amt += B.g_amt
					tw_amt += B.w_amt
					for(var/obj/O in AM.contents)
						if(isobj(O))
							tm_amt += O.m_amt
							tg_amt += O.g_amt
							tw_amt += O.w_amt
						qdel(O)
				else
					return
				for(var/mob/M in oviewers())
					if(M.client)
						boutput(M, "<span class='alert'>You hear a grinding sound!</span>")
				var/obj/item/scrap/S = new(get_turf(src))
				S.blood = bblood
				S.set_components(tm_amt,tg_amt,tw_amt)
				qdel(AM)
			//		step(S,2)
				return


//REPAIRING:  wrench > screwdriver > crowbar > wires > welder > wrench > screwdriver > sheet > welder

	attackby(var/obj/item/I as obj, var/mob/user as mob)
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
				if (isweldingtool(I) && I:try_weld(user,0,-1,0,0))
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
				if (isweldingtool(I) && I:try_weld(user,0,-1,0,0))
					actions.start(new /datum/action/bar/icon/propeller_fix(src, I, 50), user)






	ex_act(severity)
		switch(severity)
			if(1.0)
				change_health(-maxhealth)
				return
			if(2.0)
				change_health(-50)
				return
			if(3 to INFINITY)
				change_health(-35)
				return

	proc/change_health(var/change = 0)
		health = max(min(maxhealth, health+change), 0)
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
	icon = 'icons/obj/64x64.dmi'
	icon_state = "bigsea_propulsion"
	important = 1
	bound_height = 64
	bound_width = 64
	appearance_flags = TILE_BOUND

	New()
		mantaPropellers.Add(src)
		. = ..()
		stateOff = "bigsea_propulsion_off"
		stateOn = "bigsea_propulsion"
		stateDamaged = "bigsea_propulsion_broken"
		icon_state = stateOn
		on = 1
		return .

/obj/machinery/power/seaheater
	name = "heater"
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "heater"
	anchored = 2
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
	icon = 'icons/obj/64x64.dmi'
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
	anchored = 2
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
		mantaJunctionbox.Add(src)
		. = ..()
		update_icon()

	disposing()
		mantaJunctionbox.Remove(src)
		return ..()

	attack_hand(mob/user as mob)
		if (isAI(usr))
			boutput(user, "<span class='alert'>You'd touch the door, if only you had hands.</span>")
			return
		if (broken == 1)
			user.shock(src, rand(5000, 15000), "chest", 1)
		if (!src.open)
			src.open = 1
			update_icon()
			user.show_text("<span class='notice'><b>You open junction box's outer door.</b></span>")
		else
			src.open = 0
			update_icon()
			user.show_text("<span class='notice'><b>You close junction box's outer door.</b></span>")

	attackby(var/obj/item/I as obj, var/mob/user as mob)
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
		mantaJunctionbox.Remove(src)
		src.desc = "You should start by removing the outer screws from the casing. Be sure to wear some insulated gloves!"

	proc/Repair()
		src.broken = 0
		src.repairstate = 0

	proc/update_icon()
		if (src.open == 1)
			src.icon_state = src.iconopen

		else
			src.open = 0
			src.icon_state = src.iconclosed

	process()
		if(broken == 1)
			var/obj/sparks = unpool(/obj/effects/sparks/end)
			sparks.set_loc(src.loc)
			playsound(src.loc, "sparks", 100, 1)
			var/area/TT = get_area(src)
			if(isarea(TT))
				attached = locate() in TT
			if(attached)
				var/datum/powernet/PN = attached.get_powernet()
				if(PN)
					var/drained = min ( drain_rate, PN.avail )
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
					playsound(src, "sound/effects/screech.ogg", 100, 1, 1)
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
	icon = 'icons/obj/32x64.dmi'
	name = "Communications Tower"
	icon_state = "commstower"
	density = 0
	anchored = 2
	var/health = 100
	var/maxhealth = 100
	var/broken = 0
	bound_width = 32
	bound_height = 32

	ex_act(severity)
		switch(severity)
			if(1.0)
				change_health(-maxhealth)
				return
			if(2.0)
				change_health(-50)
				return
			if(3 to INFINITY)
				change_health(-35)
				return

	attackby(var/obj/item/I as obj, var/mob/user as mob)
		user.lastattacked = src
		..()
		if (broken == 0)
			change_health(-I.force)
			return
		else
			return

	proc/change_health(var/change = 0)
		health = max(min(maxhealth, health+change), 0)
		if (broken == 1)
			return
		if(health == 0)
			icon_state = "commstower_broken"
			broken = 1
			random_events.force_event("Communications Malfunction")

/obj/machinery/magneticbeacon
	icon = 'icons/obj/32x64.dmi'
	name = "Magnetic Tether"
	icon_state = "magbeacon"
	desc = "A rather delicate magnetic tether array. It allows people to safely explore the ocean around NSS Manta while carrying a magnetic attachment point."
	density = 0
	anchored = 2
	var/health = 100
	var/maxhealth = 100
	var/broken = 0
	var/repairstate = 0
	bound_width = 32
	bound_height = 32
	appearance_flags = TILE_BOUND

	ex_act(severity)
		switch(severity)
			if(1.0)
				change_health(-maxhealth)
				return
			if(2.0)
				change_health(-50)
				return
			if(3 to INFINITY)
				change_health(-35)
				return

	attackby(var/obj/item/I as obj, var/mob/user as mob)
		user.lastattacked = src
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
		health = max(min(maxhealth, health+change), 0)
		if (broken == 1)
			return
		if(health == 0)
			icon_state = "magbeacon_broken"
			broken = 1
			repairstate = 1
			MagneticTether = 0
			src.desc = "You should start by removing the outer screws from the casing. Be sure to wear some insulated gloves!"
			world << 'sound/effects/manta_alarm.ogg'
			command_alert("The Magnetic tether has suffered critical damage aboard NSS Manta. Jetpacks equipped with magnetic attachments are now offline, please do not venture out into the ocean until the tether has been repaired.", "Magnetic Tether Damaged")

/obj/landmark
	name = "bigboom"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1.0

/obj/miningteleporter
	name = "Experimental long-range mining teleporter"
	desc = "Well this looks somewhat unsafe."
	icon = 'icons/misc/32x64.dmi'
	icon_state = "englrt0"
	density = 0
	anchored = 1
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

	attack_hand(mob/user as mob)
		if(busy) return
		if(get_dist(usr, src) > 1 || usr.z != src.z) return
		src.add_dialog(user)
		add_fingerprint(user)
		busy = 1
		flick("englrt1", src)
		playsound(src, 'sound/machines/lrteleport.ogg', 60, 1)
		animate_teleport(user)
		SPAWN_DBG(1 SECOND)
		teleport(user)
		busy = 0

	proc/teleport(mob/user)
		for(var/X in by_type[/obj/miningteleporter])
			var/obj/miningteleporter/S = X
			if(S.id == src.id && S != src)
				if(recharging == 1)
					return 1
				else
					S.recharging = 1
					src.recharging = 1
					user.set_loc(S.loc)
					showswirl(user.loc)
					SPAWN_DBG(recharge)
						S.recharging = 0
						src.recharging = 0
				return

/obj/item/hosmedal
	name = "war medal"
	icon = 'icons/obj/items/items.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	icon_state = "hosmedal"
	item_state = "hosmedal"

	New()
		..()
		BLOCK_BOOK

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
		BLOCK_ROD

/obj/item/constructioncone
	desc = "Caution!"
	name = "construction cone"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "cone"
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | TABLEPASS
	stamina_damage = 15
	stamina_cost = 8
	stamina_crit_chance = 10

/obj/effect/boommarker
	name = ""
	icon = 'icons/effects/64x64.dmi'
	icon_state = "impact_marker"
	density = 0
	anchored = 1
	mouse_opacity = 0
	desc = "Uh oh.."
	pixel_x = -16
	pixel_y = -16

//Manta specific plants, straight copy, does not use the slow-down mechanic due to the alpha.

/obj/sea_plant_manta
	name = "sea plant"
	icon = 'icons/obj/sealab_objects.dmi'
	desc = "It's thriving."
	anchored = 1
	density = 0
	layer = EFFECTS_LAYER_UNDER_1
	var/database_id = null
	var/random_color = 1
	var/drop_type = 0
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER | USE_CANPASS

	New()
		..()
		if (src.random_color)
			src.color = random_saturated_hex_color()
		if (!src.pixel_x)
			src.pixel_x = rand(-8,8)
		if (!src.pixel_y)
			src.pixel_y = rand(-8,8)
		mantaPlants.Add(src)

	attackby(obj/item/W, mob/user)
		if (drop_type && issnippingtool(W))
			var/obj/item/drop = new drop_type
			drop.set_loc(src.loc)
			src.visible_message("<span class='alert'>[user] cuts down [src].</span>")
			qdel(src)
		..()

	disposing()
		mantaPlants.Remove(src)
		return ..()


/obj/sea_plant_manta/HasExited(atom/movable/A as mob|obj)
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


//******************************************** MANTA COMPATIBLE TURFS HERE ********************************************

/turf/space/fluid/manta
	var/stateOn = ""
	var/stateOff = ""
	var/on = 1
	var/list/L = list()

	New()
		mantaTiles.Add(src)
		. = ..()
		stateOff = "manta_sand"
		stateOn = "[stateOff]_scroll"
		icon_state = stateOn
		on = 1
		return .

	Del()
		mantaTiles.Remove(src)
		return ..()

	ex_act(severity)
		return

	proc/setScroll(var/newOn=0)
		if(newOn)
			icon_state = stateOn
			on = newOn
		else
			icon_state = stateOff
			on = newOn
		return

	Entered(atom/movable/Obj,atom/OldLoc)
		if(y <= 3 || y >= world.maxy - 3 || x <= 3 || x >= world.maxx - 3)
			if (!L || L.len == 0)
				for(var/turf/T in get_area_turfs(/area/trench_landing))
					L+=T

			if (istype(Obj,/obj/torpedo_targeter) ||istype(Obj,/mob/dead) || istype(Obj,/mob/wraith) || istype(Obj,/mob/living/intangible) || istype(Obj, /obj/lattice) || istype(Obj, /obj/cable/reinforced))
				return

			return_if_overlay_or_effect(Obj)

			if (L && L.len && !istype(Obj,/obj/overlay) && !istype(Obj,/obj/torpedo_targeter))
				Obj.set_loc(pick(L))
		..(Obj,OldLoc)

//Manta
/turf/space/fluid/manta/nospawn
	spawningFlags = null

//******************************************** MANTA COMPATIBLE DATUMS HERE ********************************************
//REPAIRING:  wrench > screwdriver > crowbar > wires > welder > wrench > screwdriver > sheet > welder

/datum/action/bar/icon/propeller_fix
	id = "propeller_fix1"
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
			if (H.mind.assigned_role == "Mechanic")
				duration = round(duration / 2)

	onUpdate()
		..()
		if (propeller == null || the_tool == null || owner == null || get_dist(owner, propeller) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		if (propeller.repairstate == 1)
			playsound(get_turf(propeller), "sound/items/Ratchet.ogg", 50, 1)
			owner.visible_message("<span class='notice'>[owner] begins to loosen the outer bolts.</span>")
		if (propeller.repairstate == 2)
			playsound(get_turf(propeller), "sound/items/Screwdriver.ogg", 50, 1)
			owner.visible_message("<span class='notice'>[owner] begins to unscrew the casings screws..</span>")
		if (propeller.repairstate == 3)
			owner.visible_message("<span class='notice'>[owner] begins prying the outer casing.</span>")
			playsound(get_turf(propeller), "sound/items/Crowbar.ogg", 60, 1)
		if (propeller.repairstate == 4)
			playsound(get_turf(propeller), "sound/impact_sounds/Generic_Stab_1.ogg", 60, 1)
			owner.visible_message("<span class='notice'>[owner] begins reconnecting and replacing the damaged cables.</span>")
		if (propeller.repairstate == 5)
			playsound(get_turf(propeller), "sound/items/Welder.ogg", 50, 1)
			owner.visible_message("<span class='notice'>[owner] begins to weld the connection points and soldering the control board.</span>")
		if (propeller.repairstate == 6)
			playsound(get_turf(propeller), "sound/items/Ratchet.ogg", 60, 1)
			owner.visible_message("<span class='notice'>[owner] begins securing the bolts to the casing.</span>")
		if (propeller.repairstate == 7)
			playsound(get_turf(propeller), "sound/items/Screwdriver.ogg", 50, 1)
			owner.visible_message("<span class='notice'>[owner] places the casing back on and begins securing the casing and its screws back on.</span>")
		if (propeller.repairstate == 8)
			playsound(get_turf(propeller), "sound/items/Deconstruct.ogg", 50, 1)
			owner.visible_message("<span class='notice'>[owner] begins constructing replacements for the propellers..</span>")
		if (propeller.repairstate == 9)
			playsound(get_turf(propeller), "sound/items/Welder.ogg", 60, 1)
			owner.visible_message("<span class='notice'>[owner] begins to weld the replacement propellers on.</span>")
	onEnd()
		..()
		if (propeller.repairstate == 1)
			propeller.repairstate = 2
			boutput(owner, "<span class='notice'>You remove the bolts.</span>")
			playsound(get_turf(propeller), "sound/items/Deconstruct.ogg", 80, 1)
			propeller.desc = "It's totaled, the securing bolts are off, just have to unscrew the casing screws now."
			return
		if (propeller.repairstate == 2)
			propeller.repairstate = 3
			boutput(owner, "<span class='notice'>You remove the screws.</span>")
			playsound(get_turf(propeller), "sound/items/Deconstruct.ogg", 80, 1)
			propeller.desc = "It's totaled. The casing looks like it can be pried off now."
			return
		if (propeller.repairstate == 3)
			propeller.repairstate = 4
			boutput(owner, "<span class='notice'>You pry the outer casing off.</span>")
			playsound(get_turf(propeller), "sound/items/Deconstruct.ogg", 80, 1)
			propeller.desc = "It's totaled. The casing's off and the motor wiring is exposed, might need replacing."
			return
		if (propeller.repairstate == 4)
			propeller.repairstate = 5
			boutput(owner, "<span class='notice'>You reconnect the damaged cables and re-wire the propellers internal motor.</span>")
			playsound(get_turf(propeller), "sound/items/Deconstruct.ogg", 80, 1)
			propeller.desc = "It's totaled. The wiring connectors needs to be welded onto the motor now."
			return
		if (propeller.repairstate == 5)
			propeller.repairstate = 6
			boutput(owner, "<span class='notice'>You finish welding the points and the board.</span>")
			playsound(get_turf(propeller), "sound/items/Deconstruct.ogg", 80, 1)
			propeller.desc = "It's partially fixed. the wiring looks good, better secure it with bolts before moving on."
			return
		if (propeller.repairstate == 6)
			propeller.repairstate = 7
			boutput(owner, "<span class='notice'>You secure the bolts back to the casing.</span>")
			playsound(get_turf(propeller), "sound/items/Deconstruct.ogg", 80, 1)
			propeller.desc = "It's partially fixed. the wiring looks good, better secure it with screws before moving on.."
			return
		if (propeller.repairstate == 7)
			propeller.repairstate = 8
			boutput(owner, "<span class='notice'>You finish placing the casing back on and successfully attach it with screws.</span>")
			playsound(get_turf(propeller), "sound/items/Deconstruct.ogg", 80, 1)
			propeller.desc = "It's partially fixed.The casing's closed, but the propellers are mangled, will probably need 5 sheets of metal to weld on a replacement."
			return
		if (propeller.repairstate == 8)
			propeller.repairstate = 9
			boutput(owner, "<span class='notice'>You finish building the replacement propellers.</span>")
			playsound(get_turf(propeller), "sound/items/Deconstruct.ogg", 80, 1)
			propeller.desc = "It's nearly fixed. The replacement propellers are ready, just have to weld them on now."
			if (the_tool != null)
				the_tool.amount -= 5
				if(the_tool.amount <= 0)
					qdel(the_tool)
			return

		if (propeller.repairstate == 9)
			propeller.repairstate = 0
			propeller.broken = 0
			boutput(owner, "<span class='notice'>You finish welding  the replacement propellers,the propeller is again in working condition.</span>")
			playsound(get_turf(propeller), "sound/items/Deconstruct.ogg", 80, 1)
			propeller.health = 100
			mantaPropellers.Add(src)
		if (mantaMoving == 1)
			propeller.on = 1
			propeller.icon_state = "bigsea_propulsion"
		else
			propeller.on = 0
			propeller.icon_state = "bigsea_propulsion_off"


//REPAIRING:  screwdriver > wirecutters > cable coil > wirecutters > multitool > screwdriver

/datum/action/bar/icon/junctionbox_fix
	id = "junctionbox_fix"
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
			if (H.mind.assigned_role == "Mechanic")
				duration = round(duration / 2)

	onUpdate()
		..()
		if (box == null || the_tool == null || owner == null || get_dist(owner, box) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		if (box.repairstate == 1)
			playsound(get_turf(box), "sound/items/Screwdriver.ogg", 100, 1)
			owner.visible_message("<span class='notice'>[owner] begins to unscrew the casings screws.</span>")
		if (box.repairstate == 2)
			playsound(get_turf(box), "sound/items/Wirecutter.ogg", 100, 1)
			owner.visible_message("<span class='notice'>[owner] begins cutting out the damaged cables.</span>")
		if (box.repairstate == 3)
			playsound(get_turf(box), "sound/impact_sounds/Generic_Stab_1.ogg", 60, 1)
			owner.visible_message("<span class='notice'>[owner] begins reconnecting and replacing the damaged cables.</span>")
		if (box.repairstate == 4)
			playsound(get_turf(box), "sound/items/Wirecutter.ogg", 100, 1)
			owner.visible_message("<span class='notice'>[owner] begins cutting out the excess bits of cable.</span>")
		if (box.repairstate == 5)
			playsound(get_turf(box), "sound/items/Screwdriver.ogg", 100, 1)
			owner.visible_message("<span class='notice'>[owner] begins to screw the casings screws back on.</span>")
	onEnd()
		..()
		if (box.repairstate == 1)
			box.repairstate = 2
			boutput(owner, "<span class='notice'>You successfully remove the screws.</span>")
			playsound(get_turf(box), "sound/items/Deconstruct.ogg", 80, 1)
			box.desc = "Perhaps you should cut out the damaged wires?"
			return
		if (box.repairstate == 2)
			boutput(owner, "<span class='notice'>You cut out the damaged cables. </span>")
			playsound(get_turf(box), "sound/items/Deconstruct.ogg", 80, 1)
			box.repairstate = 3
			box.desc = "You should reconnect the damaged wires by adding some new wire."
			return
		if (box.repairstate == 3)
			box.repairstate = 4
			boutput(owner, "<span class='notice'>You reconnect the damaged cables and re-wire the junction box.</span>")
			playsound(get_turf(box), "sound/items/Deconstruct.ogg", 80, 1)
			box.desc = "You should maybe cut off the excess bits of cable out."
			return
		if (box.repairstate == 4)
			boutput(owner, "<span class='notice'>You cut out excess bits of cable.</span>")
			playsound(get_turf(box), "sound/items/Deconstruct.ogg", 80, 1)
			box.repairstate = 5
			box.desc = "Alright, that should do it. Just have to screw the casing back on now."
			return
		if (box.repairstate == 5)
			box.repairstate = 0
			box.broken = 0
			boutput(owner, "<span class='notice'>You successfully screw the casing back on.</span>")
			playsound(get_turf(box), "sound/items/Deconstruct.ogg", 80, 1)
			mantaJunctionbox.Add(src)
			box.desc = "An electrical junction box is an enclosure housing electrical connections, to protect the connections and provide a safety barrier."
			return

//REPAIRING:  screwdriver > wirecutters > cable coil > wirecutters > multitool > screwdriver

/datum/action/bar/icon/magnettether_fix
	id = "junctionbox_fix"
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
			if (H.mind.assigned_role == "Mechanic")
				duration = round(duration / 2)

	onUpdate()
		..()
		if (magnet == null || the_tool == null || owner == null || get_dist(owner, magnet) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		if (magnet.repairstate == 1)
			playsound(get_turf(magnet), "sound/items/Screwdriver.ogg", 100, 1)
			owner.visible_message("<span class='notice'>[owner] begins to unscrew the casings screws.</span>")
		if (magnet.repairstate == 2)
			playsound(get_turf(magnet), "sound/items/Wirecutter.ogg", 100, 1)
			owner.visible_message("<span class='notice'>[owner] begins cutting out the damaged cables.</span>")
		if (magnet.repairstate == 3)
			playsound(get_turf(magnet), "sound/impact_sounds/Generic_Stab_1.ogg", 60, 1)
			owner.visible_message("<span class='notice'>[owner] begins reconnecting and replacing the damaged cables.</span>")
		if (magnet.repairstate == 4)
			playsound(get_turf(magnet), "sound/items/Wirecutter.ogg", 100, 1)
			owner.visible_message("<span class='notice'>[owner] begins cutting out the excess bits of cable.</span>")
		if (magnet.repairstate == 5)
			playsound(get_turf(magnet), "sound/items/Screwdriver.ogg", 100, 1)
			owner.visible_message("<span class='notice'>[owner] begins to screw the casings screws back on.</span>")
	onEnd()
		..()
		if (magnet.repairstate == 1)
			magnet.repairstate = 2
			boutput(owner, "<span class='notice'>You successfully remove the screws.</span>")
			playsound(get_turf(magnet), "sound/items/Deconstruct.ogg", 80, 1)
			magnet.desc = "Perhaps you should cut out the damaged wires?"
			return
		if (magnet.repairstate == 2)
			boutput(owner, "<span class='notice'>You cut out the damaged cables. </span>")
			playsound(get_turf(magnet), "sound/items/Deconstruct.ogg", 80, 1)
			magnet.repairstate = 3
			magnet.desc = "You should reconnect the damaged wires by adding some new wire."
			return
		if (magnet.repairstate == 3)
			magnet.repairstate = 4
			boutput(owner, "<span class='notice'>You reconnect the damaged cables and re-wire the junction box.</span>")
			playsound(get_turf(magnet), "sound/items/Deconstruct.ogg", 80, 1)
			magnet.desc = "You should maybe cut off the excess bits of cable out."
			return
		if (magnet.repairstate == 4)
			boutput(owner, "<span class='notice'>You cut out excess bits of cable.</span>")
			playsound(get_turf(magnet), "sound/items/Deconstruct.ogg", 80, 1)
			magnet.repairstate = 5
			magnet.desc = "Alright, that should do it. Just have to screw the casing back on now."
			return
		if (magnet.repairstate == 5)
			magnet.repairstate = 0
			magnet.broken = 0
			magnet.icon_state = "magbeacon"
			boutput(owner, "<span class='notice'>You successfully screw the casing back on.</span>")
			playsound(get_turf(magnet), "sound/items/Deconstruct.ogg", 80, 1)
			MagneticTether = 1
			magnet.health = 100
			magnet.desc = "A rather delicate magnetic tether array. It allows people to safely explore the ocean around NSS Manta while carrying a magnetic attachment point."
			command_alert("The Magnetic tether has been successfully repaired. Magnetic attachment points are online once again.", "Magnetic Tether Repaired")
			return

#ifdef MOVING_SUB_MAP //Defined in the map-specific .dm configuration file.
/datum/random_event/special/mantacommsdown
	name = "Communications Malfunction"

	event_effect(var/source)
		..()
		if (random_events.announce_events)
			command_alert("Communication tower has been severely damaged aboard NSS Manta. Ships automated communication system will now attempt to re-establish signal through backup channel. We estimate this will take eight to ten minutes.", "Communications Malfunction")
			world << 'sound/effects/commsdown.ogg'
			sleep(rand(80,100))
			signal_loss += 100
			sleep(rand(4800,6000))
			signal_loss -= 100

			if (random_events.announce_events)
				command_alert("Communication link has been established with Oshan Laboratory through backkup channel. Communications should be restored to normal aboard NSS Manta.", "Communications Restored")
			else
				message_admins("<span class='internal'>Manta Comms event ceasing.</span>")


/datum/random_event/major/electricmalfunction
	name = "Electrical Malfunction"

	event_effect()
		..()
		var/obj/machinery/junctionbox/J = mantaJunctionbox[rand(3,mantaJunctionbox.len)]
		if (J.broken == 1)
			return
		J.Breakdown()
		command_alert("Certain junction boxes are malfunctioning around NSS Manta. Please seek out and repair the malfunctioning junction boxes before they lead to power outages.", "Electrical Malfunction")

/datum/random_event/special/namepending
	name = "Name Pending"

	event_effect()
		..()
		var/list/EV = list()
		//var/delay = rand(2000,3000) hissssss
		//var/obj/effect/boommarker/B = /obj/effect/boommarker
		for(var/obj/landmark/S in landmarks)//world)
			if (S.name == "bigboom")
				EV.Add(S.loc)
		var/bigboommark = pick(EV)

		var/list/eligible = mantaPropellers.Copy()
		for(var/i=0, i<3, i++)
			var/obj/machinery/mantapropulsion/big/P = eligible[rand(1,eligible.len)]
			P.Breakdown()
			eligible.Remove(P)
			sleep(1 SECOND)

		new /obj/effect/boommarker(bigboommark)
#endif


//******************************************** MANTA COMPATIBLE AREAS HERE ********************************************
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
			if(!(Obj.temp_flags & MANTA_PUSHING))
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
	name = "Wreck of NSS Polaris"
	icon_state = "green"
	sound_group = "polaris"
	teleport_blocked = 1
	sound_loop = 'sound/ambience/loop/Polarisloop.ogg'

/area/wrecknsspolaris/vault
	requires_power = 0

/area/wrecknsspolaris/outside
	icon_state = "blue"
	ambient_light = OCEAN_LIGHT
/area/wrecknsspolaris/outside/teleport
/area/wrecknsspolaris/outside/back

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
			user.visible_message("<span class='notice'>The [src] accepts the biometrics of the hand and beeps, granting you access.</span>")
			playsound(src.loc, "sound/effects/handscan.ogg", 50, 1)
			for (var/obj/machinery/door/airlock/M in doors)
				if (M.id == src.id)
					if (M.density)
						M.open()
						M.operating = -1
						used = 1



/obj/machinery/handscanner/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	playsound(src.loc, "sound/effects/handscan.ogg", 50, 1)
	if (used == 0)
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.limbs && (istype(H.limbs.r_arm, /obj/item/parts/human_parts/arm/right/polaris)))
				user.visible_message("<span class='notice'>The [src] accepts the biometrics of the hand and beeps, granting you access.</span>")

				for (var/obj/machinery/door/poddoor/M in doors)
					if (M.id == src.id)
						if (M.density)
							M.open()

				for (var/obj/machinery/door/airlock/M in doors)
					if (M.id == src.id)
						if (M.density)
							M.open()
							M.operating = -1
							used = 1
			else
				boutput(user, "<span class='alert'>Invalid biometric profile. Access denied.</span>")
	else
		boutput(user, "<span class='alert'>The door has already been opened. It looks like the mechanism has jammed for good.</span>")

/obj/machinery/reliquaryscout
	name = "????"
	desc = "What the fuck is that!?"
	icon = null
	icon_state = "scoutbot"
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.set_brightness(1)
		light.set_color(0.2, 0.7, 0.2)
		light.attach(src)
		light.enable()

	process()
		for(var/mob/living/carbon/human/H in oview(11,src))
			src.visible_message("<span class='alert'>[src] spots [H], and rapidly speeds off into the trench.</span>")
			playsound(src.loc, "sound/misc/ancientbot_beep1.ogg", 80, 1)
			SPAWN_DBG(2 SECONDS)
				flick("scoutbot_teleport", src)
				qdel(src)


/obj/item/storage/secure/ssafe/polaris
	name = "captain's lockbox"
	configure_mode = 0
	random_code = 1
	spawn_contents = list(/obj/item/card/id/polaris,
	/obj/item/paper/manta_polarisnote,/obj/item/reagent_containers/emergency_injector/random,/obj/item/spacecash/thousand,
	/obj/item/spacecash/thousand,/obj/item/spacecash/thousand)

/obj/item/card/id/polaris
	name = "Sergeant's spare ID"
	icon_state = "polaris"
	registered = "Sgt. Wilkins"
	assignment = "Sergeant"
	access = list(access_polariscargo,access_heads)

/obj/item/card/id/blank_polaris
	name = "blank Nanotrasen ID"
	icon_state = "polaris"

/obj/item/broken_egun
	name = "broken energy gun"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon = 'icons/obj/items/items.dmi'
	icon_state = "broken_egun"
	desc = "Its a gun that has two modes, stun and kill, although this one is nowhere near working condition."
	item_state = "energy"
	force = 5.0

/obj/item/blackbox
	name = "flight recorder of NSS Polaris"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	icon = 'icons/obj/items/items.dmi'
	icon_state = "blackbox"
	desc = "A flight recorder is an electronic recording device placed in an spacecraft for the purpose of facilitating the investigation of accidents and incidents. Someone from Nanotrasen would surely want to see this."
	item_state = "electropack"
	force = 5.0

/turf/unsimulated/floor/polarispit
	name = "deep abyss"
	desc = "You can't see the bottom."
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "pit"
	fullbright = 0
	pathable = 0
	// this is the code for falling from abyss into ice caves
	// could maybe use an animation, or better text. perhaps a slide whistle ogg?
	Entered(atom/A as mob|obj)
		if (isobserver(A) || isintangible(A))
			return ..()

		if (polarisfall.len)
			var/turf/T = pick(polarisfall)
			fall_to(T, A)
			return
		else ..()

	polarispitwall
		icon_state = "pit_wall"

//******************************************** NSS MANTA SECRET VAULT********************************************

/obj/vaultdoor
	name = "vault door"
	icon = 'icons/obj/96x32.dmi'
	icon_state = "vaultdoor_closed"
	density = 1
	anchored = 2
	opacity = 1
	bound_width = 96
	appearance_flags = TILE_BOUND

/turf/unsimulated/floor/special/fogofcheating
	name = "fog of cheating prevention"
	desc = "Yeah, nice try."
	icon_state = "void_gray"

/area/mantavault
	name = "NSS Manta Secret Vault"
	icon_state = "red"
	teleport_blocked = 1
	sound_loop = "sound/ambience/loop/manta_vault.ogg"
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
						triggerer.visible_message("<span class='alert'>A hidden compartment opens up, revealing a hatch and a ladder.</span>")
						playsound(src.loc, "sound/effects/polaris_crateopening.ogg", 90, 1,1)
						new /obj/ladder/vaultladder(get_turf(src))
						triggered = 1
						return

/obj/ladder/vaultladder
	id = "vault"

//RANDOM PROCS//
