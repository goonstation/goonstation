/* Contains;
- Solar tracker
- Solar panel
- Solar control computer
*/

/////////////////////////////////// Solar tracker //////////////////////////////////////////////////////

//Machine that tracks the sun and reports it's direction to the solar controllers
//As long as this is working, solar panels on same powernet will track automatically

TYPEINFO(/obj/machinery/power/tracker)
	mats = list("CRY-1"=15, "CON-1"=20)

/obj/machinery/power/tracker
	name = "Houyi stellar tracker"
	desc = "The XIANG|GIESEL model '后羿' star tracker, used to set the alignment of accompanying photo-electric generator panels."
	icon = 'icons/obj/power.dmi'
	icon_state = "tracker"
	anchored = 1
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


/////////////////////////////////////////////// Solar panel /////////////////////////////////////////////////////

TYPEINFO(/obj/machinery/power/solar)
	mats = list("MET-2"=15, "CON-1"=15)

/obj/machinery/power/solar
	name = "Kuafu photoelectric panel"
	desc = "The XIANG|GIESEL model '夸父' photo electrical generator. commonly known as a solar panel."
	icon = 'icons/obj/power.dmi'
	icon_state = "solar_panel"
	anchored = 1
	density = 1
	directwired = 1
	processing_tier = PROCESSING_32TH // Uncomment this and line 175 for an experimental optimization
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
		animate(src, time=rand(0.1 SECONDS, 9 SECONDS))
		animate(transform=matrix(adir, MATRIX_ROTATE), time=rand(1 SECOND, 4 SECONDS))

/obj/machinery/power/solar/proc/update_solar_exposure()
	if(obscured)
		sunfrac = 0
		return
	if(isnull(sun))	return
	var/p_angle = (360 + adir - sun.angle) % 360
	sunfrac = max(cos(p_angle), 0) ** 2

// Previous SOLARGENRATE was 1500 WATTS processed every 3.3 SECONDS.  This provides 454.54 WATTS every second
// Adjust accordingly based on machine proc rate
#define SOLARGENRATE (454.54 * MACHINE_PROCS_PER_SEC)

/obj/machinery/power/solar/process()
	..()
	if(status & BROKEN)
		return

	if(!obscured)
		var/sgen = SOLARGENRATE * sunfrac
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
	var/track = 2			// 0= off  1=timed  2=auto (tracker)
	var/trackrate = 600		// 300-900 seconds
	var/trackdir = 1		// 0 =CCW, 1=CW
	var/nexttime = 0
	var/obj/machinery/power/tracker/tracker

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

/obj/machinery/computer/solar_control/New()
	..()
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
	..()

/obj/machinery/computer/solar_control/process()
	..()

	lastgen = gen
	gen = 0

	if(status & (NOPOWER | BROKEN))
		return

	if(track==1 && nexttime < world.timeofday && trackrate)
		nexttime = world.timeofday + 3600/abs(trackrate)
		cdir = (cdir+trackrate/abs(trackrate)+360)%360

		set_panels(cdir)

	src.updateDialog()


// called by solar tracker when sun position changes
/obj/machinery/computer/solar_control/proc/tracker_update(var/angle)
	if(track != 2 || status & (NOPOWER | BROKEN))
		return
	cdir = angle
	set_panels(cdir)

	src.updateDialog()

/obj/machinery/computer/solar_control/attack_hand(mob/user)
	if(..())
		return

	if ( (BOUNDS_DIST(src, user) > 0 ))
		if (!isAI(user))
			src.remove_dialog(user)
			user.Browse(null, "window=solcon")
			return

	add_fingerprint(user)
	src.add_dialog(user)

	var/t = "<TT><B>XIANG|GIESEL Photo-Electric Generator Control</B><HR><PRE>"
	t += "Generated power : [round(lastgen)] W<BR><BR>"
	t += "<B>Orientation</B>: [rate_control(src,"cdir","[cdir]&deg",1,15)] ([angle2text(cdir)])<BR><BR><BR>"

	t += "<BR><HR><BR><BR>"

	t += "Tracking: "
	switch(track)
		if(0)
			t += "<B>Off</B> <A href='?src=\ref[src];track=1'>Timed</A> <A href='?src=\ref[src];track=2'>Auto</A><BR>"
		if(1)
			t += "<A href='?src=\ref[src];track=0'>Off</A> <B>Timed</B> <A href='?src=\ref[src];track=2'>Auto</A><BR>"
		if(2)
			t += "<A href='?src=\ref[src];track=0'>Off</A> <A href='?src=\ref[src];track=1'>Timed</A> <B>Auto</B><BR>"


	t += "Tracking Rate: [rate_control(src,"tdir","[trackrate] deg/h ([trackrate<0 ? "CCW" : "CW"])",5,30,180)]<BR><BR>"
	t += "<A href='?src=\ref[src];close=1'>Close</A></TT>"
	user.Browse(t, "window=solcon")
	onclose(user, "solcon")
	return

/obj/machinery/computer/solar_control/Topic(href, href_list)
	if(..())
		usr.Browse(null, "window=solcon")
		src.remove_dialog(usr)
		return
	if(href_list["close"] )
		usr.Browse(null, "window=solcon")
		src.remove_dialog(usr)
		return

	if(href_list["dir"])
		cdir = text2num_safe(href_list["dir"])
		SPAWN(1 DECI SECOND)
			set_panels(cdir)

	if(href_list["rate control"])
		if(href_list["cdir"])
			src.cdir = clamp((360+src.cdir+text2num_safe(href_list["cdir"]))%360, 0, 359)
			SPAWN(1 DECI SECOND)
				set_panels(cdir)
		if(href_list["tdir"])
			src.trackrate = clamp(src.trackrate+text2num_safe(href_list["tdir"]), -7200,7200)
			if(src.trackrate) nexttime = world.timeofday + 3600/abs(trackrate)

	if(href_list["track"])
		if(src.trackrate) nexttime = world.timeofday + 3600/abs(trackrate)
		track = text2num_safe(href_list["track"])
		if(track == 2)
			if(tracker) // we keep track of the tracker now
				cdir = tracker.sun_angle

	src.updateUsrDialog()
	return

/obj/machinery/computer/solar_control/proc/set_panels(var/cdir=null)
	var/datum/powernet/powernet = src.get_direct_powernet()
	if (!powernet) return
	for(var/obj/machinery/power/solar/Solar in powernet.nodes)
		if(Solar.control != src && Solar.control) continue
		if(current_state != GAME_STATE_PLAYING && Solar.id != src.solar_id)
			continue // some solars are weird
		Solar.control = src
		Solar.ndir = src.cdir

	if (!src.tracker)
		for(var/obj/machinery/power/tracker/Tracker in powernet.nodes)
			if(Tracker.control != src && Tracker.control) continue
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

		var/sgen = SOLARGENRATE * sunfrac
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
