/obj/machinery/door/poddoor
	name = "podlock"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "pdoor1"
	icon_base = "pdoor"
	cant_emag = 1
	layer = 2.8
	object_flags = 0

	health = 1800
	health_max = 1800

	var/id = 1.0

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

/obj/machinery/door/poddoor/blast/single
	doordir = "single"
	icon_state = "bdoorsingle1"

/obj/machinery/door/poddoor/buff/staging
	name = "Staging Area"
	desc = "This door neatly separates the setup area from the spectator booths."
	icon = 'icons/effects/VR.dmi'

	New()
		..()
		SPAWN_DBG(5 SECONDS)
			open()

	bump()
		return

	attack_hand()
		return

	attackby()
		return

/obj/machinery/door/poddoor/buff/gauntlet
	name = "The Gauntlet"
	desc = "This door guards the passage out of the gauntlet. It will not open while there are live players inside."
	icon = 'icons/effects/VR.dmi'

	bump()
		return

	attack_hand()
		return

	attackby()
		return

/obj/machinery/door/poddoor/pyro
	icon = 'icons/obj/doors/SL_doors.dmi'
	icon_state = "pdoor1"
	icon_base = "pdoor"
	flags = FPRINT | IS_PERSPECTIVE_FLUID | ALWAYS_SOLID_FLUID

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/machinery/door_control (door_control.dm)
	// /obj/machinery/r_door_control (door_control.dm)
	// /obj/machinery/door/poddoor/blast/pyro (poddoor.dm)
	// /obj/warp_beacon (warp_travel.dm)
	podbay_autoclose
		autoclose = 1

		wizard_horizontal
			name = "external blast door"
			id = "hangar_wizard"
			dir = NORTH

			vertical
				dir = EAST

		syndicate_horizontal
			name = "external blast door"
			id = "hangar_syndicate"
			dir = NORTH

			vertical
				dir = EAST

		catering_horizontal
			name = "pod bay (catering)"
			id = "hangar_catering"
			dir = NORTH

			vertical
				dir = EAST

		arrivals_horizontal
			name = "pod bay (arrivals)"
			id = "hangar_arrivals"
			dir = NORTH

			vertical
				dir = EAST

		escape_horizontal
			name = "pod bay (escape hallway)"
			id = "hangar_escape"
			dir = NORTH

			vertical
				dir = EAST

		mainpod1_horizontal
			name = "pod bay (main hangar #1)"
			id = "hangar_podbay1"
			dir = NORTH

			vertical
				dir = EAST

		mainpod2_horizontal
			name = "pod bay (main hangar #2)"
			id = "hangar_podbay2"
			dir = NORTH

			vertical
				dir = EAST

		engineering_horizontal
			name = "pod bay (engineering)"
			id = "hangar_engineering"
			dir = NORTH

			vertical
				dir = EAST

		security_horizontal
			name = "pod bay (security)"
			id = "hangar_security"
			dir = NORTH

			vertical
				dir = EAST

		medsci_horizontal
			name = "pod bay (medsci)"
			id = "hangar_medsci"
			dir = NORTH

			vertical
				dir = EAST

		research_horizontal
			name = "pod bay (research)"
			id = "hangar_research"
			dir = NORTH

			vertical
				dir = EAST

		medbay_horizontal
			name = "pod bay (medbay)"
			id = "hangar_medbay"
			dir = NORTH

			vertical
				dir = EAST

		qm_horizontal
			name = "pod bay (cargo bay)"
			id = "hangar_qm"
			dir = NORTH

			vertical
				dir = EAST

		mining_horizontal
			name = "pod bay (mining)"
			id = "hangar_mining"
			dir = NORTH

			vertical
				dir = EAST

		miningoutpost_horizontal
			name = "pod bay (mining outpost)"
			id = "hangar_miningoutpost"
			dir = NORTH

			vertical
				dir = EAST

		diner1_horizontal
			name = "pod bay (space diner #1)"
			id = "hangar_spacediner1"
			dir = NORTH

			vertical
				dir = EAST

		diner2_horizontal
			name = "pod bay (space diner #2)"
			id = "hangar_spacediner2"
			dir = NORTH

			vertical
				dir = EAST

		soviet_horizontal
			name = "pod bay (salyut)"
			id = "hangar_soviet"
			dir = NORTH

			vertical
				dir = EAST
		t1d1_horizontal
			name = "pod bay (team1door1)"
			id = "hangar_t1d1"
			dir = NORTH

			vertical
				dir = EAST

		t1d2_horizontal
			name = "pod bay (team1door2)"
			id = "hangar_t1d2"
			dir = NORTH

			vertical
				dir = EAST

		t1d3_horizontal
			name = "pod bay (team1door3)"
			id = "hangar_t1d3"
			dir = NORTH

			vertical
				dir = EAST

		t1d4_horizontal
			name = "pod bay (team1door4)"
			id = "hangar_t1d4"
			dir = NORTH

			vertical
				dir = EAST

		t2d1_horizontal
			name = "pod bay (team2door1)"
			id = "hangar_t2d1"
			dir = NORTH

			vertical
				dir = EAST

		t2d2_horizontal
			name = "pod bay (team2door2)"
			id = "hangar_t2d2"
			dir = NORTH

			vertical
				dir = EAST

		t2d3_horizontal
			name = "pod bay (team2door3)"
			id = "hangar_t2d3"
			dir = NORTH

			vertical
				dir = EAST

		t2d4_horizontal
			name = "pod bay (team2door4)"
			id = "hangar_t2d4"
			dir = NORTH

			vertical
				dir = EAST
		t1d1_horizontal
			name = "pod bay (team1door1)"
			id = "hangar_t1d1"
			dir = NORTH

			vertical
				dir = EAST

		t1d2_horizontal
			name = "pod bay (team1door2)"
			id = "hangar_t1d2"
			dir = NORTH

			vertical
				dir = EAST

		t1d3_horizontal
			name = "pod bay (team1door3)"
			id = "hangar_t1d3"
			dir = NORTH

			vertical
				dir = EAST

		t1d4_horizontal
			name = "pod bay (team1door4)"
			id = "hangar_t1d4"
			dir = NORTH

			vertical
				dir = EAST

		t1condoor_horizontal
			name = "pod bay (team1 construction door)"
			id = "hangar_t1condoor"
			dir = NORTH

			vertical
				dir = EAST

		t2d1_horizontal
			name = "pod bay (team2door1)"
			id = "hangar_t2d1"
			dir = NORTH

			vertical
				dir = EAST

		t2d2_horizontal
			name = "pod bay (team2door2)"
			id = "hangar_t2d2"
			dir = NORTH

			vertical
				dir = EAST

		t2d3_horizontal
			name = "pod bay (team2door3)"
			id = "hangar_t2d3"
			dir = NORTH

			vertical
				dir = EAST

		t2d4_horizontal
			name = "pod bay (team2door4)"
			id = "hangar_t2d4"
			dir = NORTH

			vertical
				dir = EAST

		t2condoor_horizontal
			name = "pod bay (team2 construction door)"
			id = "hangar_t2condoor"
			dir = NORTH

			vertical
				dir = EAST

/obj/machinery/door/poddoor/blast/pyro
	icon = 'icons/obj/doors/SL_doors.dmi'
	icon_state = "bdoorsingle1"
	doordir = "single"

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/machinery/door_control (door_control.dm)
	// /obj/machinery/r_door_control (door_control.dm)
	// /obj/machinery/door/poddoor/pyro (poddoor.dm)
	// /obj/warp_beacon (warp_travel.dm)
	podbay_autoclose
		autoclose = 1
		icon_state = "bdoormid1"
		doordir = "mid"

		wizard_horizontal
			name = "external blast door"
			id = "hangar_wizard"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		syndicate_horizontal
			name = "external blast door"
			id = "hangar_syndicate"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		catering_horizontal
			name = "pod bay (catering)"
			id = "hangar_catering"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		arrivals_horizontal
			name = "pod bay (arrivals)"
			id = "hangar_arrivals"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		escape_horizontal
			name = "pod bay (escape hallway)"
			id = "hangar_escape"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		mainpod1_horizontal
			name = "pod bay (main hangar #1)"
			id = "hangar_podbay1"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		mainpod2_horizontal
			name = "pod bay (main hangar #2)"
			id = "hangar_podbay2"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		engineering_horizontal
			name = "pod bay (engineering)"
			id = "hangar_engineering"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		security_horizontal
			name = "pod bay (security)"
			id = "hangar_security"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		medsci_horizontal
			name = "pod bay (medsci)"
			id = "hangar_medsci"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		research_horizontal
			name = "pod bay (research)"
			id = "hangar_research"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		medbay_horizontal
			name = "pod bay (medbay)"
			id = "hangar_medbay"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		qm_horizontal
			name = "pod bay (cargo bay)"
			id = "hangar_qm"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		mining_horizontal
			name = "pod bay (mining)"
			id = "hangar_mining"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		miningoutpost_horizontal
			name = "pod bay (mining outpost)"
			id = "hangar_miningoutpost"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		diner1_horizontal
			name = "pod bay (space diner #1)"
			id = "hangar_spacediner1"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		diner2_horizontal
			name = "pod bay (space diner #2)"
			id = "hangar_spacediner2"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		soviet_horizontal
			name = "pod bay (salyut)"
			id = "hangar_soviet"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"
		t1d1_horizontal
			name = "pod bay (team1door1)"
			id = "hangar_t1d1"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t1d2_horizontal
			name = "pod bay (team1door2)"
			id = "hangar_t1d2"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t1d3_horizontal
			name = "pod bay (team1door3)"
			id = "hangar_t1d3"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t1d4_horizontal
			name = "pod bay (team1door4)"
			id = "hangar_t1d4"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t2d1_horizontal
			name = "pod bay (team2door1)"
			id = "hangar_t2d1"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t2d2_horizontal
			name = "pod bay (team2door2)"
			id = "hangar_t2d2"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t2d3_horizontal
			name = "pod bay (team2door3)"
			id = "hangar_t2d3"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t2d4_horizontal
			name = "pod bay (team2door4)"
			id = "hangar_t2d4"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t1d1_horizontal
			name = "pod bay (team1door1)"
			id = "hangar_t1d1"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t1d2_horizontal
			name = "pod bay (team1door2)"
			id = "hangar_t1d2"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t1d3_horizontal
			name = "pod bay (team1door3)"
			id = "hangar_t1d3"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t1d4_horizontal
			name = "pod bay (team1door4)"
			id = "hangar_t1d4"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t1condoor_horizontal
			name = "pod bay (team1 construction door)"
			id = "hangar_t1condoor"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t2d1_horizontal
			name = "pod bay (team2door1)"
			id = "hangar_t2d1"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t2d2_horizontal
			name = "pod bay (team2door2)"
			id = "hangar_t2d2"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t2d3_horizontal
			name = "pod bay (team2door3)"
			id = "hangar_t2d3"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t2d4_horizontal
			name = "pod bay (team2door4)"
			id = "hangar_t2d4"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

		t2condoor_horizontal
			name = "pod bay (team2 construction door)"
			id = "hangar_t2condoor"
			dir = NORTH

			vertical
				dir = EAST
			single_horizontal
				dir = NORTH
				icon_state = "bdoorsingle1"
				doordir = "single"
			single_vertical
				dir = EAST
				icon_state = "bdoorsingle1"
				doordir = "single"

/obj/machinery/door/poddoor/attackby(obj/item/C as obj, mob/user as mob)
	src.add_fingerprint(user)
	if (C && !ispryingtool(C))
		if (src.density && !src.operating)
			user.lastattacked = src
			attack_particle(user,src)
			playsound(src.loc, src.hitsound , 50, 1, pitch = 1.6)
			src.take_damage(C.force)
	if ((src.density && (status & NOPOWER) && !( src.operating )))
		SPAWN_DBG( 0 )
			src.operating = 1
			flick("[icon_base]c0", src)
			src.icon_state = "[icon_base]0"
			sleep(1.5 SECONDS)
			src.set_density(0)
			if (ignore_light_or_cam_opacity)
				src.opacity = 0
			else
				src.RL_SetOpacity(0)
			src.operating = 0
			update_nearby_tiles()
			return
	return

/obj/machinery/door/poddoor/bumpopen(mob/user as mob)
	return 0

/obj/machinery/door/poddoor/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!density)
		return 0
	if (linked_forcefield) //mbc : oh gosh why is this not calling door parent
		linked_forcefield.setactive(1)

	if(!src.operating) //in case of emag
		src.operating = 1

	SPAWN_DBG(-1)
		flick("[icon_base]c0", src)
		src.icon_state = "[icon_base]0"
		sleep(1 SECOND)
		src.set_density(0)
		if (ignore_light_or_cam_opacity)
			src.opacity = 0
		else
			src.RL_SetOpacity(0)
		update_nearby_tiles()

		if(operating == 1) //emag again
			src.operating = 0
		if(autoclose)
			SPAWN_DBG(15 SECONDS)
				autoclose()
	return 1

/obj/machinery/door/poddoor/close()
	if (src.operating)
		return
	if (src.density)
		return
	if (linked_forcefield) //mbc : oh gosh why is this not calling door parent
		linked_forcefield.setactive(0)

	SPAWN_DBG(0)
		src.operating = 1
		flick("[icon_base]1", src)
		src.icon_state = "[icon_base]1"
		src.set_density(1)
		if (src.visible)
			if (ignore_light_or_cam_opacity)
				src.opacity = 1
			else
				src.RL_SetOpacity(1)
		update_nearby_tiles()

		sleep(1 SECOND)
		src.operating = 0

	return

/obj/machinery/door/poddoor/buff
	name = "buff blast door"
	desc = "This sure is a really strong looking door.  You would think there would be a point where the door is stronger than the walls around it."

	ex_act()
		return

	blob_act(var/power)
		return

	bullet_act()
		return

/obj/machinery/door/poddoor/blast
	name = "blast door"
	icon = 'icons/obj/doors/blastdoor.dmi'
	icon_state = "bdoormid1"
	desc = "Looks pretty tough. I wouldn't take this door on in a fight."
	icon_base = "bdoor"
	var/doordir = "mid"

/obj/machinery/door/poddoor/blast/New()
	..()
	if(icon_state == "[icon_base]mid1")
		doordir = "mid"
	if(icon_state == "[icon_base]left1")
		doordir = "left"
	if(icon_state == "[icon_base]right1")
		doordir = "right"
	if(icon_state == "[icon_base]single1")
		doordir = "single"

/obj/machinery/door/poddoor/blast/attackby(obj/item/C as obj, mob/user as mob)
	src.add_fingerprint(user)
	if (!ispryingtool(C))
		return
	if ((src.density && (status & NOPOWER) && !( src.operating )))
		SPAWN_DBG( 0 )
			src.operating = 1
			flick("[icon_base][doordir]c0", src)
			src.icon_state = "[icon_base][doordir]0"
			sleep(1.5 SECONDS)
			src.set_density(0)
			if (ignore_light_or_cam_opacity)
				src.opacity = 0
			else
				src.RL_SetOpacity(0)
			src.operating = 0
			update_nearby_tiles()
			return
	return

/obj/machinery/door/poddoor/blast/bumpopen(mob/user as mob)
	return 0

/obj/machinery/door/poddoor/blast/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!density)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	if (linked_forcefield) //mbc : SAVE ME FROM THIS HELL WHERE PARENTS ARENT CALLED
		linked_forcefield.setactive(1)

	SPAWN_DBG(-1)
		flick("[icon_base][doordir]c0", src)
		src.icon_state = "[icon_base][doordir]0"
		sleep(1 SECOND)
		src.set_density(0)
		if (ignore_light_or_cam_opacity)
			src.opacity = 0
		else
			src.RL_SetOpacity(0)
		update_nearby_tiles()

		if(operating == 1) //emag again
			src.operating = 0
		if(autoclose)
			SPAWN_DBG(15 SECONDS)
				autoclose()
	return 1

/obj/machinery/door/poddoor/blast/close()
	if (src.operating || src.density)
		return
	if (linked_forcefield) //mbc : SAVE ME FROM THIS HELL WHERE PARENTS ARENT CALLED
		linked_forcefield.setactive(0)
	src.operating = 1

	SPAWN_DBG(0)
		flick("[icon_base][doordir]c1", src)
		src.icon_state = "[icon_base][doordir]1"
		src.set_density(1)
		if (src.visible)
			if (ignore_light_or_cam_opacity)
				src.opacity = 1
			else
				src.RL_SetOpacity(1)
		update_nearby_tiles()

		sleep(1 SECOND)
		src.operating = 0
	return

/obj/machinery/door/poddoor/isblocked()
	if (src.density)
		return 1
	return 0
