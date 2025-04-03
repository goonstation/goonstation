/* Contains;
- Solar tracker
- Solar panel
- Solar control computer
*/

/////////////////////////////////// Solar tracker //////////////////////////////////////////////////////

//Machine that tracks the sun and reports it's direction to the solar controllers
//As long as this is working, solar panels on same powernet will track automatically

TYPEINFO(/obj/machinery/power/tracker)
	mats = list("crystal" = 15,
				"conductive" = 20)
/obj/machinery/power/tracker
	name = "Houyi stellar tracker"
	desc = "The XIANG|GIESEL model '后羿' star tracker, used to set the alignment of accompanying photo-electric generator panels."
	icon = 'icons/obj/power.dmi'
	icon_state = "tracker"
	anchored = ANCHORED
	density = 1
	directwired = 1
	var/id = 1 // nolonger used, kept for map compatibility
	var/sun_angle = 0		// sun angle as set by sun datum
	var/obj/machinery/computer/solar_control/control

	north
		id = "north"
	south
		id = "south"
	alt
		id = "alt"
	east
		id = "east"
	west
		id = "west"
	small_backup1
		id = "small_backup1"
	small_backup2
		id = "small_backup2"
	small_backup3
		id = "small_backup3"
	small_backup4
		id = "small_backup4"
	diner
		id = "diner"
	silverglass
		id = "silverglass"
	zeta
		id = "zeta"
	aisat
		id = "aisat"
	New()
		..()
		SPAWN(1 SECOND)
			powernet = src.get_direct_powernet()
			if (powernet)
				for(var/obj/machinery/power/data_terminal/test_link in powernet.data_nodes) // plug and play
					if(!istype(test_link?.master,/obj/machinery/computer/solar_control)) continue
					var/obj/machinery/computer/solar_control/controller = test_link?.master
					if(controller?.tracker) break // if there's already a tracker, dont connect
					control = controller
					control.tracker = src // otherwise, we are now the tracker
					break
	// called by datum/sun/calc_position() as sun's angle changes
	proc/set_angle(var/angle)
		sun_angle = angle

		//set icon dir to show sun illumination
		set_dir(turn(NORTH, -angle - 22.5))	// 22.5 deg bias ensures, e.g. 67.5-112.5 is EAST

		var/datum/powernet/powernet = src.get_direct_powernet()
		if (!istype(powernet) || !control)
			return
		if(control.get_direct_powernet() == powernet)
			control.tracker_update(angle)

	// override power change to do nothing since we don't care about area power
	// (and it would be pointless anyway given that solar panels and the associated tracker are usually on a separate powernet)
	power_change()
		return

	disposing() // it would probably be best if we unlink all our panels
		if(control)
			control.tracker = null
			control = null
		..()


/////////////////////////////////////////////// Solar panel /////////////////////////////////////////////////////

TYPEINFO(/obj/machinery/power/solar)
	mats = list("metal_dense" = 15,
				"conductive" = 15)
/obj/machinery/power/solar
	name = "Kuafu photoelectric panel"
	desc = "The XIANG|GIESEL model '夸父' photo electrical generator. commonly known as a solar panel."
	icon = 'icons/obj/power.dmi'
	icon_state = "solar_panel"
	anchored = ANCHORED
	density = 1
	directwired = 1
	processing_tier = PROCESSING_EIGHTH
	var/health = 10
	var/id = 1 // nolonger used, kept for map compatibility
	var/obscured = 0
	var/sunfrac = 0
	var/adir = SOUTH
	var/ndir = SOUTH
	var/turn_angle = 0
	var/obj/machinery/computer/solar_control/control


	north
		id = "north"
	south
		id = "south"
	alt
		id = "alt"
	east
		id = "east"
	west
		id = "west"
	small_backup1
		id = "small_backup1"
	small_backup2
		id = "small_backup2"
	small_backup3
		id = "small_backup3"
	small_backup4
		id = "small_backup4"
	diner
		id = "diner"
	silverglass
		id = "silverglass"
	zeta
		id = "zeta"
	aisat
		id = "aisat"


/obj/machinery/power/solar/New()
	..()
	SPAWN(1 SECOND)
		if (current_state == GAME_STATE_PLAYING)
			powernet = src.get_direct_powernet()
			if(powernet)
				for(var/obj/machinery/power/data_terminal/test_link in powernet.data_nodes) // plug and play
					if(!istype(test_link?.master,/obj/machinery/computer/solar_control)) continue
					control = test_link?.master // we need to be able to find a control console
					break
				if(control?.cdir)
					ndir = control.cdir
		UpdateIcon()
		update_solar_exposure()


/obj/machinery/power/solar/attackby(obj/item/W, mob/user)
	..()
	src.add_fingerprint(user)
	src.health -= W.force
	src.healthcheck()
	return

/obj/machinery/power/solar/proc/healthcheck()
	if (src.health <= 0)
		if(!(status & BROKEN))
			broken()
		else
			var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
			G.set_loc(src.loc)
			G = new /obj/item/raw_material/shard/glass
			G.set_loc(src.loc)

			qdel(src)
			return
	return

/obj/machinery/power/solar/update_icon()
	if(status & BROKEN)
		icon_state = "solar_panel-b"
	else
		src.icon_state = "solar_panel"
		src.set_dir(NORTH)
		animate(src, time=randfloat(0.1 SECONDS, 9 SECONDS))
		animate(transform=matrix(adir, MATRIX_ROTATE), time=rand(1 SECOND, 4 SECONDS))

/obj/machinery/power/solar/proc/update_solar_exposure()
	if(obscured)
		sunfrac = 0
		return
	if(isnull(sun))	return
	var/p_angle = (360 + adir - sun.angle) % 360
	sunfrac = max(cos(p_angle), 0) ** 2


/obj/machinery/power/solar/process()
	..()
	if(status & BROKEN)
		return

	if(!obscured)
		var/sgen = global.solar_gen_rate * sunfrac
		sgen *= PROCESSING_TIER_MULTI(src)
		add_avail(sgen)
		if(powernet && control && powernet == control.get_direct_powernet())
			control.gen += sgen

	if(adir != ndir)
		var/old_adir = adir
		var/max_move = rand(8, 12)
		adir = (360 + adir + clamp((180 - (540 - ndir + adir) % 360), -max_move, max_move)) % 360
		if(adir != old_adir)
			use_power(10) // uses power to rotate
			UpdateIcon()

		update_solar_exposure()

/obj/machinery/power/solar/proc/broken()
	status |= BROKEN
	UpdateIcon()
	UnsubscribeProcess() // Broken solar panels need not process, supposedly there's no way to repair them?
	return

/obj/machinery/power/solar/meteorhit()
	if(status & !BROKEN)
		broken()
	else
		qdel(src)

/obj/machinery/power/solar/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			if(prob(15))
				var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
				G.set_loc(src.loc)
			return
		if(2)
			if (prob(50))
				broken()
		if(3)
			if (prob(25))
				broken()
	return

/obj/machinery/power/solar/blob_act(var/power)
	if(prob(power * 2.5))
		broken()
		src.set_density(0)

/////////////////////////////////////////////////// Solar control computer /////////////////////////////////////////

/obj/machinery/computer/solar_control
	name = "Xihe photo-electric generator controller"
	desc = "The XIANG|GIESEL model '羲和' controller for articulated photo-electric panel arrays."
	icon_state = "solar"
	circuit_type = /obj/item/circuitboard/solar_control
	can_reconnect = TRUE
	power_usage = 0
	//var/obj/overlay/solcon
	var/solar_id = 1
	var/cdir = 0
	var/gen = 0
	var/lastgen = 0
	var/active = TRUE
	var/obj/machinery/power/tracker/tracker
	var/emagged = FALSE

	north
		solar_id = "north"
	south
		solar_id = "south"
	alt
		solar_id = "alt"
	east
		solar_id = "east"
	west
		solar_id = "west"
	small_backup1
		solar_id = "small_backup1"
	small_backup2
		solar_id = "small_backup2"
	small_backup3
		solar_id = "small_backup3"
	small_backup4
		solar_id = "small_backup4"
	diner
		solar_id = "diner"
	silverglass
		solar_id = "silverglass"
	zeta
		solar_id = "zeta"
	aisat
		solar_id = "aisat"
	drone_factory
		solar_id = "dronefactory"

/obj/machinery/computer/solar_control/New()
	..()
	AddComponent(/datum/component/mechanics_holder)
	SPAWN(1.5 SECONDS)
		var/turf/T = get_turf(src)
		var/obj/machinery/power/data_terminal/test_link = locate() in T
		if (!test_link) test_link = new /obj/machinery/power/data_terminal(T)
		if(!DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
			test_link.master = src
		set_panels(cdir) // this finds all the solars

/obj/machinery/computer/solar_control/disposing() // it would probably be best if we unlink all our panels
	var/datum/powernet/powernet = src.get_direct_powernet()
	if (powernet)
		for(var/obj/machinery/power/solar/Solar in powernet.nodes)
			if(Solar.control == src)
				Solar.control = null
		if (tracker) // we track the solar tracker now
			tracker.control = null
			tracker = null
	..()

/obj/machinery/computer/solar_control/process()
	..()

	lastgen = gen
	gen = 0
	SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "power=[num2text(round(lastgen), 50)]&powerfmt=[engineering_notation(lastgen)]W&angle=[cdir]")


// called by solar tracker when sun position changes
/obj/machinery/computer/solar_control/proc/tracker_update(var/angle)
	if(!active || status & (NOPOWER | BROKEN))
		return
	cdir = emagged ? (angle + 180) % 360 : angle
	set_panels(cdir)

/obj/machinery/computer/solar_control/attack_hand(mob/user)
	if(..())
		return

	if ( (BOUNDS_DIST(src, user) > 0 ))
		if (!isAI(user))
			return

	if (istype(user.equipped(), /obj/item/card/emag))
		return

	active = !active
	user.show_text("You [active ? "activate" : "deactivate"] [src]'s solar tracking.", "blue")
	if (src.is_active_and_powered())
		src.tracker_update(!QDELETED(tracker) ? tracker.sun_angle : cdir)

	src.UpdateIcon()

/obj/machinery/computer/solar_control/get_desc()
	. = "<br />It is currently <em>[src.is_active_and_powered() ? "tracking the sun" : "disabled"]</em>"
	. += "<br />Generated power: [round(lastgen)] W"
	. += "<br />Current Orientation: [cdir]&deg; ([angle2text(cdir)])"
	. += "<br />Sun Orientation: [!QDELETED(src.tracker) ? "[tracker.sun_angle]&deg; ([angle2text(tracker.sun_angle)])" : "Unknown"]"

/obj/machinery/computer/solar_control/proc/is_active_and_powered()
	. = active && !(status & (NOPOWER | BROKEN))

/obj/machinery/computer/solar_control/update_icon()
	. = ..()
	if (src.is_active_and_powered())
		src.icon_state = initial(src.icon_state)
	else
		src.icon_state = "solar0"

/obj/machinery/computer/solar_control/power_change()
	..()
	if (!(src.status & (NOPOWER | BROKEN)))
		src.UpdateIcon()

/obj/machinery/computer/solar_control/emag_act(var/mob/user)
	. = ..()
	if (src.emagged)
		return

	src.emagged = TRUE
	user.show_text("You short out the control circuit on [src]!", "blue")
	if (active && !QDELETED(tracker))
		src.tracker_update(tracker.sun_angle)

/obj/machinery/computer/solar_control/proc/set_panels(var/cdir=null)
	var/datum/powernet/powernet = src.get_direct_powernet()
	if (!powernet) return
	for(var/obj/machinery/power/solar/Solar in powernet.nodes)
		if(Solar.control != src && Solar.control) continue
		if(current_state != GAME_STATE_PLAYING && Solar.id != src.solar_id)
			continue // some solars are weird
		Solar.control = src
		Solar.ndir = src.cdir

	if (QDELETED(src.tracker))
		for(var/obj/machinery/power/tracker/Tracker in powernet.nodes)
			if(Tracker.control != src && Tracker.control) continue
			if(QDELETED(Tracker)) continue
			if(current_state != GAME_STATE_PLAYING && Tracker.id != src.solar_id)
				continue // some solars are weird
			Tracker.control = src
			src.tracker = Tracker
			break

// hotfix until someone edits all maps to add proper wires underneath the computers
/obj/machinery/computer/solar_control/get_power_wire()
	return locate(/obj/cable) in get_turf(src)

/obj/machinery/computer/solar_control/connection_scan()
	// Find the closest solar panel ID and use that for the current one
	var/datum/powernet/powernet = src.get_direct_powernet()
	if(!powernet) return

	var/closest_solar_id = 1
	var/closest_solar_distance = null
	for(var/obj/machinery/power/solar/Solar in powernet.nodes)
		if (closest_solar_distance != null && GET_DIST(src, Solar) >= closest_solar_distance)
			continue

		closest_solar_id = Solar.id
		closest_solar_distance = GET_DIST(src, Solar)

	src.solar_id = closest_solar_id
	set_panels(cdir)

// solar panels which ignore occlusion

TYPEINFO(/obj/machinery/power/solar/owl_cheat)
	mats = 0

/obj/machinery/power/solar/owl_cheat
	id = "owl"

	update_solar_exposure()
		if(isnull(sun))	return
		var/p_angle = abs((360+adir)%360 - (360+sun.angle)%360)
		if(p_angle > 90)			// if facing more than 90deg from sun, zero output
			sunfrac = 0
			return
		sunfrac = cos(p_angle) ** 2

	process()
		if(status & BROKEN)
			return

		var/sgen = DEFAULT_SOLARGENRATE * sunfrac
		sgen *= PROCESSING_TIER_MULTI(src)
		add_avail(sgen)
		if(powernet && control)
			if(control.get_direct_powernet() == powernet) // this line right here...
				control.gen += sgen

		if(adir != ndir)
			var/old_adir = adir
			var/max_move = rand(8, 12)
			adir = (360 + adir + clamp((180 - (540 - ndir + adir) % 360), -max_move, max_move)) % 360
			if(adir != old_adir)
				UpdateIcon()

			update_solar_exposure()
