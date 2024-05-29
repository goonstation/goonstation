/obj/item/shipcomponent/sensor
	name = "Standard Sensor System"
	desc = "Advanced scanning system for ships."
	power_used = 20
	system = "Sensors"
	var/ships = 0
	var/list/obj/shiplist = list()
	var/beacons = 0
	var/list/beaconlist = list()
	var/lifeforms = 0
	var/list/lifelist = list()
	var/list/obj/whos_tracking_me = list()
	//HAHA SUE ME NERDS, I'LL REMOVE THIS WHEN SENSORS DON'T SUCK --Kyle
#if defined(MAP_OVERRIDE_POD_WARS)
	var/seekrange = 90
#else
	var/seekrange = 30
#endif
	var/sight = SEE_SELF
	var/see_in_dark = SEE_DARK_HUMAN + 3
	var/antisight = 0
	var/centerlight = null
	var/centerlight_color = "#ffffff"
	var/see_invisible = INVIS_CLOAK
	var/scanning = 0
	var/atom/tracking_target = null
	var/const/SENSOR_REFRESH_RATE = 10
	var/tracking_gps_coord = 0		//TRUE if we are tracking an x, y coordinate. FALSE if we're tracking another ship.
	icon_state = "sensor-w"

	//these 3 used in processing loop. Put up here cause I'm easy style converting from 2016 that doesn't have it.
	var/cur_dist = 0
	var/same_z_level = 0
	var/trackable_range = 0


	disposing()
		stop_tracking_me()
		..()

	mob_deactivate(mob/M as mob)
		M.sight &= ~SEE_TURFS
		M.sight &= ~SEE_MOBS
		M.sight &= ~SEE_OBJS
		M.see_in_dark = initial(M.see_in_dark)
		M.see_invisible = INVIS_NONE
		end_tracking()
		scanning = 0

	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		src.add_dialog(user)

		var/dat = "<B>[src] Console</B><BR><HR><BR>"
		if(src.active)
			dat += build_html_gps_form(src, FALSE, src.tracking_target)
			dat += {"<HR><BR><A href='byond://?src=\ref[src];scan=1'>Scan Area</A>"}
			dat += {"<HR><B>[beacons] Beacons Nearby:</B><BR>"}
			if(beaconlist.len)
				for(var/obj/B in beaconlist)
					dat += {"<HR><a href=\"byond://?src=\ref[src];dest_cords=1;x=[B.x];y=[B.y];z=[B.z]\">[B.name]</a>~[round(GET_DIST(src.ship, B), 25)]M [dir_name(get_dir(src.ship, B))]"}
			dat += {"<HR><B>[ships] Ships Detected:</B><BR>"}
			if(shiplist.len)
				for(var/obj/V in shiplist)
					dat += {"<HR> | <a href=\"byond://?src=\ref[src];tracking_ship=\ref[V]\">[V.name]</a> [dir_name(get_dir(src.ship, V))]"}
			dat += {"<HR>[lifeforms] Lifeforms Detected:</B><BR>"}
			if(lifelist.len)
				for(var/lifename in lifelist)
					dat += {"[lifename] | "}
		else
			dat += {"<B><span style=\"color:red\">SYSTEM OFFLINE</span></B>"}
		user.Browse(dat, "window=ship_sensor")
		onclose(user, "ship_sensor")
		return

	Topic(href, href_list)
		if(usr.stat || usr.restrained())
			return

		if (usr.loc == ship)
			src.add_dialog(usr)

			if (href_list["scan"] && !scanning)
				scan(usr)
			if(href_list["getcords"])
				boutput(usr, SPAN_NOTICE("Located at: <b>X</b>: [src.ship.x], <b>Y</b>: [src.ship.y]"))
				return
			if (href_list["tracking_ship"] && !scanning)
				end_tracking()
				obtain_tracking_target(locate(href_list["tracking_ship"]))
			if (href_list["stop_tracking"])
				end_tracking()
			if(href_list["dest_cords"] && !scanning)
				end_tracking()
				obtain_target_from_coords(href_list)

			src.add_fingerprint(usr)
			for(var/mob/M in ship)
				if (M.using_dialog_of(src))
					src.opencomputer(M)
		else
			usr.Browse(null, "window=ship_sensor")
			return
		return

	//If our target is a turf from the GPS coordinate picker. Our range will be much higher
	proc/begin_tracking(var/gps_coord=0)
		if (src.tracking_target)
			var/obj/machinery/vehicle/target_pod = src.tracking_target
			if (istype(target_pod))
				var/obj/item/shipcomponent/sensor/target_sensor = target_pod.sensors
				if (istype(target_sensor))
					target_sensor.whos_tracking_me |= src.ship
					target_pod.myhud.sensor_lock.icon_state = "master-caution"
					target_pod.myhud.sensor_lock.mouse_opacity = 1

		src.ship.myhud.tracking.icon_state = "dots-s"
		processing_items.Add(src)
		track_target(gps_coord)

	//nulls the tracking target, sets the hud object to turn off end center on the ship, removes src from the target pod's tracking list, and updates the dilaogue
	proc/end_tracking()
		processing_items.Remove(src)
		if (src.tracking_target)
			var/obj/machinery/vehicle/target_pod = src.tracking_target
			if (istype(target_pod))
				var/obj/item/shipcomponent/sensor/target_sensor = target_pod.sensors
				if (istype(target_sensor))
					target_sensor.whos_tracking_me -= src.ship
					if (islist(target_sensor.whos_tracking_me) && length(target_sensor.whos_tracking_me) == 0)
						target_pod.myhud.sensor_lock.icon_state = "off"
						target_pod.myhud.sensor_lock.mouse_opacity = 0

		src.tracking_target = null
		src.ship.myhud.tracking.set_dir(NORTH)
		animate(src.ship.myhud.tracking, transform = null, time = 10, loop = 0)

		src.ship.myhud.tracking.icon_state = "off"

	//Tracking loop
	proc/track_target(var/gps_coord)
		tracking_gps_coord = gps_coord		//Dumb stuff cause I made this on 2016 which didn't have an items processing loop.
		cur_dist = 0
		same_z_level = 0
		trackable_range = 0
		process()

	process()
		if (src.tracking_target && src.ship && src.ship.myhud && src.ship.myhud.tracking)
			same_z_level = (src.ship.z == src.tracking_target.z)
			cur_dist = GET_DIST(src.ship,src.tracking_target)
			trackable_range = adjust_seekrange(src.tracking_target)
			//change position and icon dir based on direction to target. And make sure it's using the dots.
			//must be within range and be on the same z-level
			if (same_z_level && (cur_dist <= trackable_range || tracking_gps_coord))
				// src.set_dir(get_dir(ship, src.tracking_target))
				src.ship.myhud.tracking.icon_state = "dots-s"
				animate_tracking_hud(src.ship.myhud.tracking, src.tracking_target)

			//If the target is out of seek range, move to top and change to lost state
			else
				src.ship.myhud.tracking.icon_state = "lost"
				//if we're off the z-level or tracking a ship and twice as far out: lose the signal
				//If it's a static gps target from the coordinate picker, we can track from anywhere. Maybe unneeded
				if (!same_z_level || ( !tracking_gps_coord && cur_dist > trackable_range*2 ))
					end_tracking()
					for(var/mob/M in ship)
						boutput(M, SPAN_ALERT("Tracking signal lost."))
					playsound(src.loc, 'sound/machines/whistlebeep.ogg', 50, 1)

			// sleep(SENSOR_REFRESH_RATE)


	//If the engine is off or we're using 10% of power capacity, make it harder for people to track us.
	//currently only using this for tracking. It doesn't effect the active sensor scan button.
	proc/adjust_seekrange(var/obj/machinery/vehicle/pod)
		if (istype(pod))
			if (pod.sec_system && pod.sec_system.f_active && istype(pod.sec_system, /obj/item/shipcomponent/secondary_system/cloak))
				return src.seekrange/3
			if (pod.powercapacity == 0 || (pod.powercurrent/pod.powercapacity) <= 0.1)
				return src.seekrange/2
		return src.seekrange

	//Arguments: A should be the tracking HuD dots, target is the sensor's tracking_target
	//Turns the sprite around
	proc/animate_tracking_hud(var/atom/A, var/atom/target)
		if (!istype(A) || !istype(target))
			return
		var/ang = get_angle(src.ship, target)
		//Was maybe thinking about having it get further out or something the further the target is, but no.
		//var/dist = GET_DIST(src.ship, target)
		//var/number = round(ang/(45-(50-dist)))*(45-(50-dist))
		var/matrix/M = matrix()
		M = M.Turn(ang)
		M = M.Translate(32 * sin(ang),32 * cos(ang))

		animate(A, transform = M, time = 10, loop = 0)

	//arguments: O is the target to track. If O is within sensor range after .1 SECOND, it is tracked by the sensor
	proc/obtain_tracking_target(var/obj/O)
		if (!O)
			return
		scanning = 1
		src.tracking_target = O
		boutput(usr, SPAN_NOTICE("Attempting to pinpoint energy source..."))
		playsound(ship.loc, 'sound/machines/signal.ogg', 50, 0)
		sleep(1 SECOND)
		if (src.tracking_target && GET_DIST(src,src.tracking_target) <= seekrange)
			scanning = 0		//remove this if we want to force the user to manually stop tracking before trying to track something else
			boutput(usr, SPAN_NOTICE("Tracking target: [src.tracking_target.name]"))
			SPAWN(0)		//Doing this to redraw the scanner window after the topic call that uses this fires.
				begin_tracking(0)
		else
			boutput(usr, SPAN_NOTICE("Unable to locate target."))
			src.tracking_target = null
		scanning = 0

	//For use by clicking a pod to target them, instantly add them as your tracking target
	proc/quick_obtain_target(var/obj/machinery/vehicle/O)
		if (!O)
			return
		src.tracking_target = O
		boutput(usr, SPAN_NOTICE("Tracking target: [src.tracking_target.name]"))
		SPAWN(0)
			begin_tracking(0)
		for(var/mob/M in ship)
			if (M.using_dialog_of(src))
				src.opencomputer(M)

//Doing nothing with the Z-level value right now.
	proc/obtain_target_from_coords(href_list)
	//The default Z coordinate given. Just use current Z-Level where the object is. Pods won't
		#define DEFAULT_Z_VALUE -1
		scanning = 1
		if (href_list["dest_cords"])
			tracking_target = null
			var/x = text2num_safe(href_list["x"])
			var/y = text2num_safe(href_list["y"])
			var/z = text2num_safe(href_list["z"])
			if (!x || !y/* || !z*/)
				boutput(usr, SPAN_ALERT("'0' is an invalid gps coordinate. Try again."))
				return
			//Using -1 as the default value
			if (z == DEFAULT_Z_VALUE)
				if (src.loc)
					z = src.loc.z

			boutput(usr, SPAN_NOTICE("Attempting to pinpoint: <b>X</b>: [x], <b>Y</b>: [y], Z</b>: [z]"))
			playsound(ship.loc, 'sound/machines/signal.ogg', 50, 0)
			sleep(1 SECOND)
			var/turf/T = locate(x,y,z)

			//Set located turf to be the tracking_target
			if (isturf(T))
				src.tracking_target = T
				boutput(usr, SPAN_NOTICE("Now tracking: <b>X</b>: [T.x], <b>Y</b>: [T.y]"))
				scanning = 0		//remove this if we want to force the user to manually stop tracking before trying to track something else
				SPAWN(0)		//Doing this to redraw the scanner window after the topic call that uses this fires.
					begin_tracking(1)
		sleep(1 SECOND)
		scanning = 0
		#undef DEFAULT_Z_VALUE

	//stop the tracking for everyone who is currently tracking you.
	proc/stop_tracking_me()
		for (var/obj/O in whos_tracking_me)
			var/obj/machinery/vehicle/pod = O
			if (istype(pod))
				var/obj/item/shipcomponent/sensor/S = pod.sensors
				if (istype(S))
					S.end_tracking()


	proc/dir_name(var/direction)
		switch (direction)
			if (1)
				return "north"
			if (2)
				return "south"
			if (4)
				return "east"
			if (8)
				return "west"
			if (5)
				return "northeast"
			if (6)
				return "southeast"
			if (9)
				return "northwest"
			if (10)
				return "southwest"

	proc/scan(mob/user as mob)
		scanning = 1
		lifeforms = 0
		ships = 0
		beacons = 0
		lifelist = list()
		shiplist = list()
		beaconlist = list()
		for(var/mob/living/carbon/human/M in ship)
			M.playsound_local_not_inworld('sound/machines/signal.ogg', vol=100)
		ship.visible_message("<b>[ship] begins a sensor sweep of the area.</b>")
		boutput(user, SPAN_NOTICE("Scanning..."))
		sleep(3 SECONDS)
		boutput(user, SPAN_NOTICE("Scan complete."))
		for (var/mob/living/M in mobs)
			if (!isturf(M.loc))	// || ship.Find(M)
				continue
			if ((ship.z == M.z) && GET_DIST(ship.loc, M) <= src.seekrange)
				if(!isdead(M) && !isintangible(M))
#ifdef UNDERWATER_MAP
					if (istype(M,/mob/living/critter/aquatic/fish)) continue
#endif
					lifeforms++
					//Add direction to mob if close. Who cares about doing it for non-drone critters and npc's...
					if (GET_DIST(ship.loc, M) <= src.seekrange/2)
						lifelist += "[M.name] - [dir_name(get_dir(ship, M))]"
						continue
					lifelist += M.name

		for (var/obj/npc/C in range(src.seekrange,ship.loc))
			if(C.alive)
				lifeforms++
				lifelist += C.name

		for (var/obj/B in by_type[/obj/warp_beacon]) //ignoring cruisers, they barely exist, sue me.
			if(B != ship)
				if (ship.z == B.z)
					beacons++
					beaconlist[B] = "[dir_name(get_dir(ship, B))]"

		for (var/obj/machinery/vehicle/V in by_cat[TR_CAT_PODS_AND_CRUISERS]) //ignoring cruisers, they barely exist, sue me.
			if(V != ship)
				if ((ship.z == V.z) && GET_DIST(ship.loc, V) <= src.seekrange)
					ships++
					shiplist[V] = "[dir_name(get_dir(ship, V))]"

		for (var/obj/critter/C in range(src.seekrange,ship.loc))
			if ((ship.z == C.z) && GET_DIST(ship.loc, C) <= src.seekrange)
				if(C.alive)
					if (istype(C,/obj/critter/gunbot))
						ships++
						shiplist[C] ="[dir_name(get_dir(ship, C))]"
					else
						lifeforms++
						lifelist += C.name
		for_by_tcl(O, /obj/storage)
			if ((ship.z == O.z) && GET_DIST(ship.loc, O) <= src.seekrange/2)
				for (var/mob/living/M in O.contents)
					lifeforms++
					lifelist += "Obscure Life Sign"
					break

		sleep(1 SECOND)
		scanning = 0
		return

//Sends topic call with "dest_cords" and "X", "Y", "Z" as params
proc/build_html_gps_form(var/atom/A, var/show_Z=0, var/atom/target)
//I wanted to use a button for this, but that breaks chui. all window.locations sets do. I'll settle for it with the dest coords
//<button id='getCords' style='width:100%;' onClick=\"window.location.href = 'byond://?src=\ref[A];getcords=1';\">Get Local Coordinates</button><BR>
	var/dat = ""
	if (target)
		var/display_text = target.name
		if (isturf(target))
			display_text += " at X:[target.x], Y:[target.y]"
		dat += {"<BR>Currently Tracking: [display_text]
		<a href=\"byond://?src=\ref[A];stop_tracking=1\">Stop Tracking</a>"}

	return {"
		<script>
			function showInput() {
			  var x = document.getElementById('destInput');
			  if (x.style.display === 'none') {
			    x.style.display = 'block';
			  } else {
			    x.style.display = 'none';
			  }
			}
			function send() {
				var x = document.getElementById('idX').value;
				var y = document.getElementById('idY').value;
				var z = document.getElementById('idZ').value;
				if (!isNaN(x) && !isNaN(y) && !isNaN(z)){
					window.location='byond://?src=\ref[A];dest_cords=1;x='+x+';y='+y+';z='+z;
				}
			}
		</script>
		<style>
			.btn {
				color: blue;
				background: #4E565E;
				border: solid #3B424A 2px;
			}
			[istype(A, /obj/item/device/gps) ? ".inputs { background: #4E565E; }" : ""]
		</style>

		<div id=topDiv>
			<center><A href='byond://?src=\ref[A];getcords=1' style='width:calc(100% - 5px);'>Get Local Coordinates</A><BR></center>
			<button class='button' id='dest' style='width:calc(100% - 5px);' onClick='(showInput())' >Select Destination</button><BR>
			<div style='display:none' id = 'destInput'>
					X Coordinate: <input class='inputs' id='idX' type='number' min='0' max='500' name='X' value='1' pattern='[0-9]+' title='Numbers 0-9'><br>
					Y Coordinate: <input class='inputs' id='idY' type='number' min='0' max='500' name='Y' value='1' pattern='[0-9]+' title='Numbers 0-9'><br>
					<div[show_Z ? "" : " style='display: none;'"]>
						Z Coordinate: <input class='inputs' id='idZ' type='number' name='Z' value='[show_Z ? "0" : "-1"]' pattern='[0-9]+' title='Numbers 0-9'><br>
					</div>
					<button class='button' onclick='send()'>Enter</button>
			</div>
		</div>
		[dat]
		"}

/obj/item/shipcomponent/sensor/ecto
	name = "Ecto-Sensor 900"
	desc = "The number one choice for reasearchers of the supernatural."
	see_invisible = INVIS_GHOST
	power_used = 40
	icon_state = "sensor-g"

/obj/item/shipcomponent/sensor/mining
	name = "Conclave A-1984 Sensor System"
	desc = "Advanced geological meson scanners for ships."
	sight = SEE_TURFS
	antisight = SEE_BLACKNESS
	centerlight = "thermal"
	centerlight_color = "#9bdb9b"
	power_used = 35
	icon_state = "sensor-y"

	scan(mob/user as mob)
		..()
		mining_scan(get_turf(user), user, 6)

/obj/item/shipcomponent/sensor/combat
	name = "Long-Range Sensor 2143"
	desc = "The number one choice for reasearchers of the supernatural."
	power_used = 40
	seekrange = 60
	icon_state = "sensor-r"
