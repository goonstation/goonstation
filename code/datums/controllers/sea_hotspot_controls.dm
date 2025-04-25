// Distance from the edge of the map that hotspots will avoid moving into
#define HOTSPOT_AVOID_EDGE_DISTANCE 15

/turf/proc/probe_test()
	return hotspot_controller.probe_turf(src)

/datum/hotspot_controller
	var/list/hotspot_groups = list()

	var/groups_to_create = 43

	var/icon/map = 0
	var/icon/map_html = 0

	var/sound_env_test = 0

	New()
		..()
		#ifdef HOTSPOTS_ENABLED
		setup_hotspots()
		#endif

	proc/setup_hotspots()
		#ifdef UPSCALED_MAP
		src.groups_to_create *= 4
		#endif
		var/datum/sea_hotspot/new_hotspot = 0
		for (var/i = 1, i <= src.groups_to_create, i++)
			new_hotspot = new
			hotspot_groups += new_hotspot
			var/turf/T = 0

			var/maxsearch = 6
			while ( maxsearch > 0 && (!T || (T.loc && istype(T.loc,/area/station))) ) //block from spawning under station
				T = locate(rand(1 + HOTSPOT_AVOID_EDGE_DISTANCE, world.maxx - HOTSPOT_AVOID_EDGE_DISTANCE), rand(1 + HOTSPOT_AVOID_EDGE_DISTANCE, world.maxy - HOTSPOT_AVOID_EDGE_DISTANCE), 1)
				maxsearch--

			new_hotspot.move_center_to(T)

	#ifdef UNDERWATER_MAP
	var/list/map_colors = list(
		empty = rgb(0, 0, 255),
		solid = rgb(0, 0, 50),
		station = rgb(255, 153, 58),
		other = rgb(120, 200, 120))
	#else
	var/list/map_colors = list(
		empty = rgb(30, 30, 45),
		solid = rgb(180,180,180),
		station = rgb(27, 163, 186),
		other = rgb(186, 0, 60))
	#endif

	proc/generate_map()
		if (!map)
			Z_LOG_DEBUG("Mining Map", "Generating map ...")
			map = icon('icons/misc/trenchMapEmpty.dmi', "template")
			var/turf_color = null
			var/size_mult = 2
			for (var/x in 1 to world.maxx)
				for (var/y in 1 to world.maxy)
					var/turf/T = locate(x,y,MINING_Z)
					if (istype(T, /turf/simulated/wall/auto/asteroid) || istype(T, /turf/simulated/floor/plating/airless/asteroid))
						turf_color = "solid"
					else if (istype(T, /turf/space))
						continue
					else
						if (T.loc && istype(T.loc, /area/shuttle/sea_elevator) || istype(T.loc, /area/mining) || istype(T.loc, /area/prefab/sea_mining) || istype(T.loc, /area/station/solar/small_backup3))
							turf_color = "station"
						else
							turf_color = "other"

					var/mx = x * size_mult - 1
					var/my = y * size_mult - 1
					map.DrawBox(map_colors[turf_color], mx, my, mx + 1, my + 1)

			for (var/beacon in by_type[/obj/warp_beacon])
				if (istype(beacon, /obj/warp_beacon/miningasteroidbelt))
					var/turf/T = get_turf(beacon)
					map.DrawBox(map_colors["station"], T.x * size_mult - 3, T.y * size_mult - 3, T.x * size_mult + 2, T.y * size_mult + 2)

			Z_LOG_DEBUG("Mining Map", "Map generation complete")
			generate_map_html()

	proc/generate_map_html()

		if (!src.map)
			// what the fuck???
			return

		var/list/hotspots = list()
		for (var/datum/sea_hotspot/S in hotspot_groups)
			hotspots += {"<div class='hotspot' style='bottom: [S.center.y * 2]px; left: [S.center.x * 2]px; width: [S.radius * 4 + 2]px; height: [S.radius * 4 + 2]px; margin-left: -[S.radius * 2]px; margin-bottom: -[S.radius * 2]px;'></div>"}

		src.map_html = {"
<!doctype html>
<html>
<head>
	[map_currently_underwater?"<title>Trench Map</title>":"<title>Mining Map</title>"]
	<meta http-equiv="X-UA-Compatible" content="IE=edge;">
	<style type="text/css">
		body {
			background: black;
			color: white;
			font-family: 'Consolas', 'Ubuntu Mono', monospace;
		}
		* {
			border-sizing: border-box;
			image-rendering: -moz-crisp-edges;
			image-rendering: -o-crisp-edges;
			image-rendering: -webkit-optimize-contrast;
			image-rendering: crisp-edges;
			image-rendering: pixelated;
			-ms-interpolation-mode:nearest-neighbor;
			}
		#map {
			position: relative;
			height: 600px;
			width: 600px;
			overflow: hidden;
			margin: 0 auto;
			background-color: [map_colors["empty"]]
		}
		#map img {
			position: absolute;
			bottom: 0
			left: 0;
		}
		.hotspot {
			position: absolute;
			background: rgba(255, 120, 120, 0.6);
		}
		.key {
			text-align: center;
			margin-top: 0.5em;
		}
		.key > span {
			white-space: nowrap;
			display: inline-block;
			margin: 0 0.5em;
		}
		.key > span > span {
			display: inline-block;
			height: 1em;
			width: 1em;
			border: 1px solid white;
		}
		.empty { background-color: [map_colors["empty"]]; }
		.solid { background-color: [map_colors["solid"]]; }
		.station { background-color: [map_colors["station"]]; }
		.other { background-color: [map_colors["other"]]; }
		.vent { background-color: rgb(255, 120, 120); }
	</style>
</head>
<body>
		<div id='map'>
			<img src="trenchmap.png" height="600">
			[hotspots.Join("")]
		</div>
		<div class='key'>
			<span><span class='solid'></span> Solid Rock</span>
			<span><span class='station'></span> NT Asset</span>
			<span><span class='other'></span> Unknown</span>
			[map_currently_underwater?"<span><span class='vent'></span> Hotspot</span>":""]
			</div>
</body>
</html>
"}

	proc/show_map(var/client/C)
		if (!C)
			return
		if (!src.map_html || !src.map)
			boutput(C, "<b class='alert'>oh no, map doesnt exist!</b>")
			return
		C << browse_rsc(src.map, "trenchmap.png")
		C << browse(src.map_html, "window=trench_map;size=650x700;title=Trench Map")

	proc/clear()
		hotspot_groups.len = 0

	proc/process() //do movety uptdate
		for (var/datum/sea_hotspot/S in hotspot_groups)
			S.drift_count++
			if (S.drift_count >= S.drift_speed)
				S.drift_count = 0
				S.move_center_to(get_step(S.center.turf(), S.drift_dir))
			LAGCHECK(LAG_HIGH)

		// this updates the trench map's hotspot overlay when they move
		// this happens about once a minute and shouldn't cause any issues
		generate_map_html()


	proc/get_hotspot(var/turf/T)
		.= 0
		for (var/datum/sea_hotspot/S in hotspot_groups)
			if(S.get_tile_heat(T))
				.= S
				break

	proc/get_hotspots_list(var/turf/T)
		.= list()
		for (var/datum/sea_hotspot/S in hotspot_groups)
			if(S.get_tile_heat(T))
				.+= S

	proc/get_hotspots_amount(var/turf/T)
		.= 0
		for (var/datum/sea_hotspot/S in hotspot_groups)
			if(S.get_tile_heat(T))
				.+= 1

	proc/probe_turf(var/turf/T)
		.= 0
		for (var/datum/sea_hotspot/S in hotspot_groups)
			if (S.vent_capture_amt > 1)
				.+= (S.get_tile_heat(T) / S.vent_capture_amt) * (2 - (1 / (S.vent_capture_amt - 1))) //lessen individual output of multiple capture units on the same hotspot, but with a small boost to overall output
			else
				.+= S.get_tile_heat(T)

		var/amt = hotspot_controller.get_hotspots_amount(T)
		var/mult = ( (amt > 1) ? (1 + (amt / 2.3)) : (1) ) //stack bonus (2.3 is the magic number that contorls the bonus scaling)
		. *= mult

	proc/disturb_turf(var/turf/T) //triggered from asteroid mining currently
		if (T.z != 5) return

		var/tally = 0
		var/heat
		for (var/datum/sea_hotspot/S in hotspot_groups)
			heat = S.get_tile_heat(locate(T.x,T.y,1))
			if (heat)
				S.bonus_heat += S.per_activity
			tally += heat
		if (tally)
			elecflash(T)

	proc/stomp_turf(var/turf/T) //Move hotspot 1 tile and set its dir to the difference between stomp loc and hotspot center
		.= 0
		for (var/datum/sea_hotspot/S in hotspot_groups)
			if (S.get_tile_heat(T))

				//ahhhh shit
				var/turf/center = S.center.turf()
				if (BOUNDS_DIST(T, center) > 0) //smash center to lock me in place
					S.can_drift = 1
					.= 1
				else
					S.can_drift = 0

				S.drift_dir = vector_to_dir(center.x - T.x, center.y - T.y)

				S.move_center_to(get_step(S.center.turf(), S.drift_dir))

	proc/colorping_at_turf(var/turf/T)
		for (var/datum/sea_hotspot/S in hotspot_groups)
			if(S.get_tile_heat(T))
				S.color_ping()

//phenomena flags
#define PH_QUAKE_WEAK 1
#define PH_QUAKE 2
#define PH_FIRE_WEAK 4
#define PH_FIRE 8
#define PH_EX_WEAK 16
#define PH_EX 32

/datum/sea_hotspot
	var/static/heat_dropoff_per_dist_unit = 0.1 // possible todo : a quad curve
	var/static/base_heat = 1000
	//var/static/max_activity_heat_bonus = 2000 //when mining underneath this hotspot on the trench zlevel, increase bonus heat (NOT USED)
	//var/static/heat_polled_past_max_factor = 0.1 //When polled at cap, return heat with this multiplier applied.

	var/static/per_activity = 95

	var/bonus_heat = 0

	//var/list/covered_points = list() //lol this did nothing
	var/datum/hotspot_point/center = new
	var/radius = 8
	var/static/cool_cushion = 2

	var/drift_dir = 0
	var/can_drift = 1
	var/drift_speed = 1 //amount of hotspot controller ticks (currently minutes) it takes to move
	var/drift_count = 0

	var/vent_capture_amt = 0

	var/d = 0

	var/last_colorping = 0


	New()
		..()
		drift_dir = pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,SOUTHWEST,NORTHEAST,SOUTHEAST)
		//if (prob(25))
		//	drift_speed = 2
		if (prob(5))
			can_drift = 0

	proc/move_center_to(var/turf/new_center)
		if (!istype(new_center)) return
		// allow hotspots to move before the game starts
		// (fixes them being set as !can_drift in New() and then
		// getting stuck at 0,0,0 forever)
		if (current_state >= GAME_STATE_PLAYING && !can_drift) return

		// if we would be moved too close to the edges of the world, turn around
		if (new_center.x >= (world.maxx - HOTSPOT_AVOID_EDGE_DISTANCE) || new_center.x <= (1 + HOTSPOT_AVOID_EDGE_DISTANCE) || new_center.y >= (world.maxy - HOTSPOT_AVOID_EDGE_DISTANCE) || new_center.y <= (1 + HOTSPOT_AVOID_EDGE_DISTANCE))
			drift_dir = turn(drift_dir,180)
			return

		center.change(new_center.x,new_center.y,new_center.z)


		if (current_state == GAME_STATE_PLAYING)
			vent_capture_amt = 0
			//covered_points.len = 0 //we don't need to clear + create new points here, ideally use old ones
			var/list/dowsers = list()
			for (var/turf/T in range(radius,new_center))
				//covered_points += new/datum/hotspot_point(T.x,T.y,T.z)
				//T.color = "#FFCCCC"
				var/turf/space/fluid/S = T
				if (istype(S) && S.captured)
					vent_capture_amt += 1

				var/obj/item/heat_dowsing/H = locate() in T
				if (H && H.closest_hotspot == src)
					dowsers += H

			for (var/thing in dowsers)
				var/obj/item/heat_dowsing/H = thing
				if (H.deployed)
					step(H, drift_dir)
			//new_center.color = "#ff0000"
			//get_step(new_center,drift_dir).color = "#ff9900"

			src.do_phenomena()

	proc/do_phenomena(var/recursion = 0, var/recursion_heat = 0)
		var/turf/C = src.center.turf()
		if (!C) return
		var/turf/phenomena_point = locate(C.x + rand(-radius,radius) * 0.5,C.y + rand(-radius,radius) * 0.5, 1)
		var/heat = recursion_heat ? recursion_heat : hotspot_controller.probe_turf(phenomena_point)
		var/phenomena_flags = 0

		//lazy ugly mbc code incoming
		if (heat > 200)
			phenomena_flags |= PH_QUAKE_WEAK
			if (heat > 900)
				phenomena_flags |= PH_QUAKE
				phenomena_flags &= ~PH_QUAKE_WEAK

		if (heat > 1800)
			phenomena_flags |= PH_FIRE_WEAK
			if (heat > 3000)
				phenomena_flags |= PH_FIRE
				phenomena_flags &= ~PH_FIRE_WEAK

		if (heat > 4500)
			phenomena_flags |= PH_EX
			phenomena_flags &= ~PH_FIRE_WEAK
			phenomena_flags &= ~PH_FIRE
			if (heat > 5600)
				phenomena_flags |= PH_EX
				phenomena_flags |= PH_FIRE

		var/found = 0
		for (var/mob/living/M in range(6, C))
			found = 1
			if (phenomena_flags & PH_QUAKE_WEAK)
				shake_camera(M, 4, 4)
				M.show_text(SPAN_ALERT("<b>The ground rumbles softly.</b>"))

			if (phenomena_flags & PH_QUAKE)
				shake_camera(M, 5, 16)
				random_brute_damage(M, 3)
				M.changeStatus("knockdown", 1 SECOND)
				M.show_text(SPAN_ALERT("<b>The ground quakes and rumbles violently!</b>"))

		if (phenomena_flags & PH_FIRE_WEAK)
			fireflash(phenomena_point,0)

		if (phenomena_flags & PH_FIRE)
			fireflash(phenomena_point,1)

		if (phenomena_flags & PH_EX)
			explosion(src, phenomena_point, -1, -1, 2, 3)

		if ((phenomena_flags & PH_EX) || (phenomena_flags & PH_FIRE_WEAK) || (phenomena_flags & PH_FIRE))
			playsound(phenomena_point, 'sound/misc/ground_rumble_big.ogg', 65, TRUE, 0.1, 0.7)
		else if (found)
			playsound(phenomena_point, 'sound/misc/ground_rumble.ogg', 70, TRUE, 0.1, 1)

		//hey recurse at this arbitrary heat value, thanks
		if (heat > 8000 + (8000 * recursion))
			var/areaname = get_area_name(phenomena_point)
			if (recursion <= 0 && areaname && areaname != "Ocean")
				var/logmsg = "BIG hotspot phenomena (Heat : [heat])  at [log_loc(phenomena_point)]."
				message_admins(logmsg)
				logTheThing(LOG_BOMBING, null, logmsg)
				logTheThing(LOG_DIARY, null, logmsg, "game")

			SPAWN(5 SECONDS)
				LAGCHECK(LAG_HIGH)
				src.do_phenomena( recursion++, heat - (9000 + (9000 * recursion)) )
		else
			var/areaname = get_area_name(phenomena_point)
			if (phenomena_flags > PH_QUAKE && recursion <= 0 && areaname && areaname != "Ocean")
				var/logmsg = "Hotspot phenomena (Heat : [heat])  at [log_loc(phenomena_point)]."
				message_admins(logmsg)
				logTheThing(LOG_BOMBING, null, logmsg)
				logTheThing(LOG_DIARY, null, logmsg, "game")


	proc/poll_capture_amt(var/turf/center)
		vent_capture_amt = 0
		for (var/turf/space/fluid/T in range(radius,center))
			if (T.captured)
				vent_capture_amt += 1
			LAGCHECK(LAG_HIGH)

	proc/get_tile_heat(var/turf/T)

		d = GET_DIST(T, center.turf())
		if (d > radius)
			.= 0
			if (d <= radius + cool_cushion)
				.= (base_heat + bonus_heat) * ( (heat_dropoff_per_dist_unit * 0.8) / (d - radius) )
		else
			.= max( (base_heat + bonus_heat) - ((base_heat + bonus_heat) * (heat_dropoff_per_dist_unit * d)) , 0 )

	proc/color_ping(var/setcolor = "#FF0011")
		if (world.time + 10 SECONDS > last_colorping)

			for (var/turf/space/fluid/T in range(radius,center))
				var/lastcolor = T.color
				T.color = setcolor
				animate(T, color = lastcolor, time = 3 SECONDS, easing = SINE_EASING)
				LAGCHECK(LAG_REALTIME)

			last_colorping = world.time

//why does this exist, you ask
//the hotspot datum needs to live on the basis of coordinates, not turfs. Turfs might be created, destroyed, moved(?) or changed in other ways that could booboo with their hotspot readouts.
//this is safer and less prone to conflicts with other wonky code
/datum/hotspot_point
	var/x = 0
	var/y = 0
	var/z = 0

	New(x=0,y=0,z=0)
		..()
		src.x = x
		src.y = y
		src.z = z

	proc/change(x=0,y=0,z=0)
		src.x = x
		src.y = y
		src.z = z

	proc/turf()
		.= locate(x,y,z)



/obj/item/heat_dowsing
	name = "dowsing rod"
	icon = 'icons/obj/sealab_power.dmi'
	icon_state = "dowsing_hands"
	item_state = "dowsing"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	desc = "Stick this rod into the sea floor to poll for underground heat. Distance readings may fluctuate based on the frequency of vibrational waves.<br>If the mass of heat moves via drift, this rod will follow its movements." //doppler effect lol i'm science
	plane = PLANE_ABOVE_LIGHTING
	throwforce = 6
	w_class = W_CLASS_SMALL
	force = 6
	throw_speed = 4
	throw_range = 5
	stamina_damage = 30
	stamina_cost = 15
	stamina_crit_chance = 1
	//two_handed = 1
	var/static/image/speech_bubble = image('icons/mob/mob.dmi', "speech")
	var/static/dowse_dist_fuzz = 3
	var/static/speak_interval = 8 // speak every [x] process ticks (machine loop targets about 1 tick per 2 seconds)
	var/speak_count = 8

	var/last_deploy_process = 0
	var/static/deploy_process_interval_min = 10
	var/deployed = 0
	var/datum/sea_hotspot/closest_hotspot = 0

	var/placed = 0
	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)

	ex_act(severity)
		return //nah

	disposing()
		deployed = 0
		closest_hotspot = 0
		processing_items -= src
		..()

	process()
		var/heat = hotspot_controller.probe_turf(src.loc)
		//hardcoding these levels because i dont wanna linear ramp and this is easier than doing the quad curve or whatever
		var/heat_level = 0//todo : balance
		if (heat >= 1) heat_level++
		if (heat >= 300) heat_level++
		if (heat >= 500) heat_level++
		if (heat >= 650) heat_level++
		if (heat >= 800) heat_level++
		if (heat >= 900) heat_level++
		if (heat >= 1000) heat_level++
		if (heat >= 1400) heat_level++
		if (heat >= 1900) heat_level++
		if (heat >= 2400) heat_level++
		if (heat >= 3000) heat_level++
		if (heat >= 3900) heat_level++
		if (heat >= 4500) heat_level++
		if (heat >= 5600) heat_level++

		if (src.z == 5) heat_level = 0 //nope! you can't cheat this bad.

		icon_state = "dowsing_deployed_[heat_level]"



		var/dist_last = 9999

		if (heat_level > 0)
			speak_count++
			if (speak_count >= speak_interval)
				speak_count = 0
				var/val = 0 //my friend valerie
				var/true_center = 0
				for (var/datum/sea_hotspot/H in hotspot_controller.get_hotspots_list(src.loc))
					var/turf/center = H.center.turf()
					if (src.loc == center)
						true_center += 1

					var/d = GET_DIST(src.loc,center)
					if (d < dist_last)
						closest_hotspot = H
						dist_last = GET_DIST(src.loc,center)

					val += GET_DIST(src.loc,center)
					if (H.can_drift)
						var/turf/dir_step = get_step(center, H.drift_dir)

						var/angle = arctan(src.loc.y - center.y, src.loc.x - center.x)
						var/angle2 = arctan(dir_step.y - center.y, dir_step.x - center.x) //todo : atan2 not necessary here. Make some dir2angle function for speed.

						var/diff = abs(angledifference(angle,angle2))
						diff -= 90
						diff = (diff / 90) * (dowse_dist_fuzz / H.drift_speed)

						val += round(diff, 1)

				val = clamp(val, 0, 20)

				if (placed)
					placed = 0

					for (var/mob/O in hearers(src, null))
						O.show_message(SPAN_SUBTLE(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"Estimated distance to center : [val]\"")), 2)


					if (true_center) //stomper does this anywya, lets let them dowse for the true center instead of accidntally stomping and being annoying
						playsound(src, 'sound/machines/twobeep.ogg', 50, TRUE,0.1,0.7)
						if (true_center > 1)
							for (var/mob/O in hearers(src, null))
								O.show_message(SPAN_SUBTLE(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"[true_center] centers have been located!\"")), 2)

						else
							for (var/mob/O in hearers(src, null))
								O.show_message(SPAN_SUBTLE(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"True center has been located!\"")), 2)


				speech_bubble.icon_state = "[val]"
				AddOverlays(speech_bubble, "speech_bubble")
				SPAWN(1.5 SECONDS)
					ClearSpecificOverlays("speech_bubble")

	attackby(var/obj/item/I, var/mob/M)
		if (ispryingtool(I))
			if (deployed)
				src.undeploy()
			else
				if (src in M.contents)
					src.force_drop()
				src.deploy()
		..()

	attack_hand(var/mob/living/carbon/human/user)
		src.undeploy()
		..()

	afterattack(var/turf/T, var/mob/user)
		if (istype(T) && !T.density)
			processing_items |= src

			user.drop_item()
			src.set_loc(T)
			src.deploy()

			return
		..()

	proc/undeploy()
		src.icon_state = "dowsing_hands"
		deployed = 0
		closest_hotspot = 0
		processing_items -= src

	proc/deploy()
		processing_items |= src
		src.icon_state = "dowsing_deployed_[0]"
		speak_count = speak_interval
		pixel_x = 0
		pixel_y = 0
		deployed = 1
		placed = 1
		process()
		usr.next_click = world.time + 1
		playsound(src.loc, 'sound/effects/shovel2.ogg', 50, 1, 0.3)

		//maybe later
		//hotspot_controller.colorping_at_turf(src.loc)


/turf/space/fluid/attack_hand(var/mob/user)
	var/obj/item/heat_dowsing/H = locate() in src
	if (H)
		H.Attackhand(user)

/turf/space/fluid/attackby(var/obj/item/W, var/mob/user)
	if (istype_exact(src, /turf/space/fluid))
		if (istype(W,/obj/item/shovel) || istype(W,/obj/item/slag_shovel))
			actions.start(new/datum/action/bar/icon/dig_sea_hole(src), user)
			return
		else if (istype(W,/obj/item/mining_tool/powered/shovel))
			var/obj/item/mining_tool/powered/shovel/PS = W
			if (PS.is_on)
				actions.start(new/datum/action/bar/icon/dig_sea_hole/fast(src), user)
			else
				actions.start(new/datum/action/bar/icon/dig_sea_hole(src), user)
			return
	..()

/obj/venthole
	name = "hole"
	desc = "A hole dug in the seafloor."
	icon = 'icons/obj/sealab_power.dmi'
	icon_state = "venthole_1"
	anchored = ANCHORED_ALWAYS
	density = 0

	ex_act(severity)
		return //nah

	get_desc(dist)
		if (dist <= 4)
			//todo : move to proc or define or some shit because i just copyptasstesds
			var/heat = hotspot_controller.probe_turf()
			var/heat_level = 0
			if (heat >= 1) heat_level++
			if (heat >= 900) heat_level++
			if (heat >= 1200) heat_level++

			//fuckk
			if (heat_level == 1)
				. += "Looks warm!"
			if (heat_level == 2)
				. += "Looks hot!"
			if (heat_level == 3)
				. += "Looks searing hot!"

	attackby(var/obj/item/W, var/mob/user)
		if (istype(W,/obj/item/vent_capture_unbuilt))
			var/obj/item/vent_capture_unbuilt/V = W
			V.build(user,src.loc)
			return
		if (istype(W,/obj/item/shovel) || istype(W,/obj/item/slag_shovel))
			actions.start(new/datum/action/bar/icon/dig_sea_hole(src.loc), user)
		else if (istype(W,/obj/item/mining_tool/powered/shovel))
			var/obj/item/mining_tool/powered/shovel/PS = W
			if (PS.is_on)
				actions.start(new/datum/action/bar/icon/dig_sea_hole/fast(src.loc), user)
			else
				actions.start(new/datum/action/bar/icon/dig_sea_hole(src.loc), user)
		..()

#define VENT_GENFACTOR 300

TYPEINFO(/obj/item/vent_capture_unbuilt)
	mats = 8

/obj/item/vent_capture_unbuilt
	name = "unbuilt vent capture unit"
	desc = "An unbuilt piece of machinery that converts vent output into electricity."
	icon = 'icons/obj/sealab_power.dmi'
	icon_state = "hydrovent_unbuilt"
	item_state = "vent"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS

	attackby(var/obj/item/W, var/mob/user)
		if (istype(W,/obj/item/electronics/soldering) || isscrewingtool(W) || ispryingtool(W) || iswrenchingtool(W))
			build(user,src.loc)
			return
		..()

	attack_self(var/mob/user)
		build(user,user.loc)

	proc/build(var/mob/user, var/turf/build_turf)
		if ((locate(/obj/venthole) in build_turf))
			var/obj/item/vent_capture_unbuilt/V = user.equipped()
			if(istype(V))
				user.drop_item()
				V.set_loc(build_turf)

			actions.start(new/datum/action/bar/icon/build_vent_capture(src,build_turf), user)
		else
			user.show_text("You need to dig a hole first!", "blue")

	proc/finish_build(var/turf/T)
		if(!isturf(src.loc) || T != src.loc)
			return
		var/obj/machinery/power/vent_capture/V = new /obj/machinery/power/vent_capture(src.loc)
		V.built = 1
		//V.built = 0
		//V.UpdateIcon()
		qdel(src)

/obj/machinery/power/vent_capture
	name = "vent capture unit"
	desc = "A piece of machinery that converts vent output into electricity."
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "hydrovent_1"
	density = 1
	anchored = ANCHORED

	var/last_gen = 0
	var/total_gen = 0

	var/built = 1

	New()
		..()
		START_TRACKING
		AddComponent(/datum/component/mechanics_holder)
		if (istype(src.loc,/turf/space/fluid))
			var/turf/space/fluid/T = src.loc
			T.captured = 1
			update_capture()

	ex_act(severity)
		return //nah

	update_icon()
		icon_state = icon_state = "hydrovent_[built]"

	disposing()
		..()
		STOP_TRACKING
		if (istype(src.loc,/turf/space/fluid))
			var/turf/space/fluid/T = src.loc
			T.captured = 0
			update_capture()

	attackby(var/obj/item/W, var/mob/user)
		if (istype(W,/obj/item/electronics/soldering) || isscrewingtool(W) || ispryingtool(W) || iswrenchingtool(W))
			actions.start(new/datum/action/bar/icon/unbuild_vent_capture(src), user)
			return
		..()

	proc/unbuild(var/mob/user)
		new /obj/item/vent_capture_unbuilt(src.loc)
		qdel(src)

	Move(NewLoc,Dir=0,step_x=0,step_y=0)
		if (istype(src.loc,/turf/space/fluid))
			var/turf/space/fluid/T = src.loc
			T.captured = 0
			update_capture()

		. = ..(NewLoc,Dir,step_x,step_y)

		if (istype(src.loc,/turf/space/fluid))
			var/turf/space/fluid/T = src.loc
			T.captured = 1
			update_capture()

	proc/update_capture()
		if (!isturf(src.loc)) return
		var/datum/sea_hotspot/H = hotspot_controller.get_hotspot(src.loc)
		if (H)
			H.poll_capture_amt(src.loc)


	attackby(var/obj/item/W, var/mob/user)
		if (!built)
			if (ispryingtool(W)) //blah i don care
				built = 1
				UpdateIcon()
				return
		else
			if (istype(W,/obj/item/cable_coil))
				src.loc.Attackby(W,user)
				return
		..()


	process()
		if(status & BROKEN)
			return
		if (!built) return

		var/sgen = VENT_GENFACTOR * hotspot_controller.probe_turf(src.loc)

		if (sgen > 0)
			add_avail(sgen)
			total_gen += sgen
		last_gen = sgen
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "power=[num2text(round(last_gen), 50)]&powerfmt=[engineering_notation(last_gen)]W&total=[total_gen]&totalfmt=[engineering_notation(total_gen)]J")

	get_desc(dist)
		if (!built)
			. += "Complete hypothetical building step to complete construction."
		//if (dist <= 4) //TODO : UNITS
		//
		. += "<br>Current Output: [engineering_notation(last_gen)]W"
		. += "<br>Lifetime Output: [engineering_notation(total_gen)]J"

	/*proc/healthcheck()
		if (src.health <= 0)
			if(!(status & BROKEN))
				broken()
			else
				new /obj/item/raw_material/shard/glass(src.loc)
				new /obj/item/raw_material/shard/glass(src.loc)
				qdel(src)
				return
		return*/

TYPEINFO(/obj/machinery/power/stomper)
	mats = 8

/obj/machinery/power/stomper
	name = "stomper unit"
	desc = "This machine is used to disturb the flow of underground magma and redirect it."
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "stomper0"
	density = 1
	anchored = UNANCHORED
	status = REQ_PHYSICAL_ACCESS

	var/power_up_realtime = 30
	var/const/power_cell_usage = 4

	var/on = 0
	var/open = 0
	var/activated_timeofday = 0
	var/obj/item/cell/cell

	var/powerupsfx = 'sound/machines/shieldgen_startup.ogg'
	var/powerdownsfx = 'sound/machines/engine_alert3.ogg'

	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_DESTRUCT
	flags = 0 // override FLUID_SUBMERGE and TGUI_INTERACTIVE

	var/mode_toggle = 0
	var/set_anchor = 1

	var/emagged = FALSE

	New()
		..()
		cell = new(src)
		cell.charge = 1000
		cell.maxcharge = 1000

	ex_act(severity)
		return //nah

	emag_act(mob/user, obj/item/card/emag/E)
		if (src.emagged)
			user?.show_message(SPAN_ALERT("[src] has already had its safety restrictions disabled."))
			return
		src.emagged = TRUE
		power_up_realtime = 10
		set_anchor = 0
		for (var/mob/O in hearers(src, null))
			O.show_message(SPAN_SUBTLE(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"Safety restrictions disabled.\"")), 2)
		return TRUE

	update_icon()
		icon_state = "stomper[on]"

	attack_hand(var/mob/living/carbon/human/user)
		src.add_fingerprint(user)

		if(open)
			if(cell && !user.equipped() && in_interact_range(src, user))
				cell.UpdateIcon()
				user.put_in_hand_or_drop(cell)

				user.visible_message(SPAN_NOTICE("[user] removes the power cell from \the [src]."), SPAN_NOTICE("You remove the power cell from \the [src]."))
		else
			activate()

			playsound(src.loc, 'sound/machines/engine_alert3.ogg', 50, 1, 0.1, on ? 1 : 0.6)
			UpdateIcon()
			user.visible_message(SPAN_NOTICE("[user] switches [on ? "on" : "off"] the [src]."),SPAN_NOTICE("You switch [on ? "on" : "off"] the [src]."))

	proc/activate()
		on = !on
		if (set_anchor)
			anchored = on

		if (!cell || cell.charge <= 0 && on)
			src.visible_message("[src] shuts down. The power cell must be replaced.", "blue")
			on = 0

		if (on)
			activated_timeofday = world.timeofday
			SubscribeToProcess()

	verb/toggle()
		set name = "Single/Auto Toggle"
		set src in oview(1)
		set category = "Local"

		if(!isliving(usr) || !isalive(usr))
			return

		mode_toggle = !mode_toggle

		for (var/mob/O in hearers(src, null))
			O.show_message(SPAN_SUBTLE(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"Stomp mode : [mode_toggle ? "automatic" : "single"].\"")), 2)

	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/cell))
			if(open)
				if(cell)
					boutput(user, SPAN_ALERT("There is already a power cell inside."))
					return
				else
					// insert cell
					var/obj/item/cell/C = user.equipped()
					if(istype(C))
						user.drop_item()
						cell = C
						C.set_loc(src)
						C.add_fingerprint(user)

						user.visible_message(SPAN_NOTICE("[user] inserts a power cell into [src]."), SPAN_NOTICE("You insert the power cell into [src]."))
			else
				boutput(user, SPAN_ALERT("The hatch must be open to insert a power cell."))
				return
		else if (ispryingtool(I))
			open = !open
			user.visible_message(SPAN_NOTICE("[user] [open ? "opens" : "closes"] the hatch on the [src]."), SPAN_NOTICE("You [open ? "open" : "close"] the hatch on the [src]."))
			UpdateIcon()
		else
			..()

	process()
		if(status & BROKEN) return
		if (!on) return

		if (!cell || cell.charge <= 0)
			on = 0
			UnsubscribeProcess()

		//nahh this seems a bit tedious
		//cell.use(power_cell_usage)

		if (world.timeofday < activated_timeofday + power_up_realtime)
			return

		on = 0
		UpdateIcon()
		FLICK("stomper2",src)

		if (hotspot_controller.stomp_turf(get_turf(src))) //we didn't stomped center, do an additional SFX
			SPAWN(0.4 SECONDS)
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 99, 1, 0.1, 0.7)

		for (var/datum/sea_hotspot/H in hotspot_controller.get_hotspots_list(get_turf(src)))
			if (BOUNDS_DIST(src, H.center.turf()) == 0)
				playsound(src, 'sound/machines/twobeep.ogg', 50, TRUE,0.1,0.7)
				for (var/mob/O in hearers(src, null))
					O.show_message(SPAN_SUBTLE(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"Hotspot pinned.\"")), 2)

		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 99, 1, 0.1, 0.7)

		for (var/mob/M in src.loc)
			if (isliving(M) && !isintangible(M))
				random_brute_damage(M, 55, 1)
				M.changeStatus("knockdown", 1 SECOND)
				INVOKE_ASYNC(M, TYPE_PROC_REF(/mob, emote), "scream")
				playsound(M.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 70, 1)

		for (var/mob/C in viewers(src))
			shake_camera(C, 5, 8)

		//squash person

		if (set_anchor)
			anchored = on

		UnsubscribeProcess()

		if (mode_toggle) //reactivate in togglemode
			activate()

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.cell)
			src.cell = null

TYPEINFO(/obj/item/clothing/shoes/stomp_boots)
	mats = 20

/obj/item/clothing/shoes/stomp_boots
	name = "stomper boots"
	desc = "A pair of specialized boots for stomping the ground really hard." // TODO add techy explanation I guess
	icon_state = "stompboots"
	kick_bonus = 3
	step_sound = "step_plating"
	step_priority = STEP_PRIORITY_LOW
	laces = LACES_NONE
	burn_possible = FALSE
	abilities = list(/obj/ability_button/stomper_boot_stomp)

	setupProperties()
		. = ..()
		src.setProperty("movespeed", 0.8)
		src.setProperty("disorient_resist", 15)

/obj/ability_button/stomper_boot_stomp
	name = "Stomp"
	icon_state = "magbootson"
	desc = "Stomp the ground, pinning hotspots under you and moving any others nearby."
	var/jump_height = 1.5 //! Jump height, in tiles.
	var/jump_time = 1 SECONDS//! Time the jump takes, in seconds.
	var/stomp_cooldown = 10 SECONDS
	var/stomp_damage = 20
	requires_equip = TRUE
	var/prevLayer = null
	var/prevPlane = null

	proc/start_jump()
		the_mob.visible_message(SPAN_ALERT("<b>[the_mob]</b> activates the boost on their stomper boots!"))
		playsound(src.loc, 'sound/items/miningtool_on.ogg', 50, 1)
		src.prevLayer = the_mob.layer
		src.prevPlane = the_mob.plane
		the_mob.layer = EFFECTS_LAYER_4 // need to be above posters and shit
		the_mob.plane = PLANE_NOSHADOW_ABOVE
		APPLY_ATOM_PROPERTY(the_mob, PROP_ATOM_NEVER_DENSE, src)
		the_mob.flags |= TABLEPASS

		if (prob(10))
			the_mob.emote("flip")

		animate(the_mob,
			pixel_y = jump_height * 32,
			time = jump_time / 2,
			easing = EASE_OUT | CIRCULAR_EASING,
			flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
		animate(
			pixel_y = -jump_height * 32,
			time = jump_time / 2,
			easing = EASE_IN | CIRCULAR_EASING,
			flags = ANIMATION_RELATIVE)

	proc/end_jump(mob/jumper)
		jumper.layer = prevLayer
		jumper.plane = prevPlane
		REMOVE_ATOM_PROPERTY(jumper, PROP_ATOM_NEVER_DENSE, src)
		jumper.flags &= ~TABLEPASS
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 50, 1, 0.1, 0.7)

		if (locate(/obj/item/clothing/shoes) in jumper.get_equipped_items())
			if (hotspot_controller.stomp_turf(get_turf(src))) //we didn't stomped center, do an additional SFX
				SPAWN(0.4 SECONDS)
					playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, 1, 0.1, 0.7)

			for (var/datum/sea_hotspot/H in hotspot_controller.get_hotspots_list(get_turf(src)))
				if (BOUNDS_DIST(src, H.center.turf()) == 0)
					playsound(src, 'sound/machines/twobeep.ogg', 50, TRUE, 0.1, 0.7)
					for (var/mob/O in hearers(jumper, null))
						O.show_message(SPAN_SUBTLE(SPAN_SAY("[SPAN_NAME("[src]")] beeps, \"Hotspot pinned.\"")), 2)

			for (var/mob/M in get_turf(src))
				if (isliving(M) && !isintangible(M) && M != jumper)
					random_brute_damage(M, src.stomp_damage, TRUE)
					M.changeStatus("knockdown", 1 SECOND)
					playsound(M.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 70, 1)
		else
			// took them off mid air
			random_brute_damage(jumper, 25, FALSE)
			jumper.changeStatus("knockdown", 3 SECONDS)
			playsound(jumper.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 90, 1)

	execute_ability()
		if(!(the_item in the_mob.get_equipped_items()))
			boutput(the_mob, SPAN_ALERT("Try wearing [src] first."))
			return
		if (!ON_COOLDOWN(src, "stomp", src.stomp_cooldown))
			// Mostly stolen from jumpy
			if (istype(the_mob.loc, /turf/))
				src.start_jump()
				SPAWN(0)
					var/mob/jumper = the_mob // do this so we still have a reference if the button gets deleted
					sleep(jump_time)
					src.end_jump(jumper)

			else if (istype(the_mob.loc, /obj/))
				var/obj/container = the_mob.loc
				boutput(the_mob, SPAN_ALERT("You leap and slam your head against the inside of [container]! Ouch!"))
				the_mob.changeStatus("unconscious", 5 SECONDS)
				the_mob.changeStatus("knockdown", 5 SECONDS)
				container.visible_message(SPAN_ALERT("<b>[the_mob.loc]</b> emits a loud thump and rattles a bit."))
				playsound(container, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, TRUE)
				animate_storage_thump(container)
		else
			var/cooldown_in_seconds = GET_COOLDOWN(src, "stomp") / 10
			boutput(the_mob, SPAN_ALERT("The stomper boots are recharging. The integrated timer shows <b>\"00:[(cooldown_in_seconds < 10 ? "0" : "")][cooldown_in_seconds]\"</b>."))

/obj/item/clothing/shoes/stomp_boots/extreme
	name = "\improper STOMP BOOTS HYPERMURDER EDITION"
	desc = "PAPA'S GOT A BRAND NEW SHOE"
	abilities = list(/obj/ability_button/stomper_boot_stomp/extreme)

/obj/ability_button/stomper_boot_stomp/extreme
	name = "EARTH SHATTERING MEGA STOMP"
	desc = "EXTREMELY HAZARDOUS TO ALL LIFE"
	stomp_cooldown = 0 SECONDS
	stomp_damage = 200

/obj/item/clothing/shoes/stomp_boots/very_high
	name = "very high stomper boots"
	desc = "How high IS the ceiling in here?"
	abilities = list(/obj/ability_button/stomper_boot_stomp/very_high)

/obj/ability_button/stomper_boot_stomp/very_high
	start_jump()
		..()
		APPLY_ATOM_PROPERTY(src.the_mob, PROP_MOB_NOCLIP, src)

	end_jump(mob/jumper)
		REMOVE_ATOM_PROPERTY(jumper, PROP_MOB_NOCLIP, src)
		..()

////////////////////////////////////////////////////////////
//actions
////////////////////////////////////////////////////////////


/datum/action/bar/icon/build_vent_capture
	duration = 50
	interrupt_flags = INTERRUPT_STUNNED
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"
	var/turf/T
	var/obj/item/vent_capture_unbuilt/V

	New(Vent, Loc)
		V = Vent
		T = Loc
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, T) > 0 || V == null || owner == null || T == null || V.loc != T)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, T) > 0 || V == null || owner == null || T == null || V.loc != T)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(BOUNDS_DIST(owner, T) > 0 || V == null || owner == null || T == null || V.loc != T)
			interrupt(INTERRUPT_ALWAYS)
			return
		if(locate(/obj/machinery/power/vent_capture) in T)
			V.visible_message(SPAN_NOTICE("[V] beeps grumpily and aborts construction."), SPAN_NOTICE("You hear a grumpy beeping."))
			interrupt(INTERRUPT_ALWAYS)
			return

		if(owner && V && T)
			V.finish_build(T)

/datum/action/bar/icon/unbuild_vent_capture
	duration = 50
	interrupt_flags = INTERRUPT_STUNNED
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"
	var/obj/machinery/power/vent_capture/V

	New(Vent)
		V = Vent
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, V) > 0 || V == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, V) > 0 || V == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(BOUNDS_DIST(owner, V) > 0 || V == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if(owner && V)
			V.unbuild()

/datum/action/bar/icon/dig_sea_hole
	duration = 30
	interrupt_flags = INTERRUPT_STUNNED
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"
	var/turf/T

	New(Turf)
		T = Turf
		..()
		playsound(T, 'sound/effects/shovel1.ogg', 50, TRUE, 0.3)

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, T) > 0 || T == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, T) > 0 || T == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(BOUNDS_DIST(owner, T) > 0 || T == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/found = 0
		for(var/obj/venthole/venthole in T)
			found = 1
			qdel(venthole)

		if (!found)
			new /obj/venthole(T)

		playsound(T, 'sound/effects/shovel3.ogg', 50, TRUE, 0.3)


	fast
		duration = 5


/obj/item/trench_map
	name = "sea trench map"
	desc = null
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "wall_poster_trench"
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 3
	throw_range = 15
	layer = OBJ_LAYER+1

	burn_point = 220
	burn_output = 900
	burn_possible = TRUE
	health = 4
	var/can_put_up = 1

	examine(mob/user)
		if (user.client && hotspot_controller)
			hotspot_controller.show_map(user.client)
			return list()
		else
			return ..()

	attack_self(mob/user)
		. = ..()
		src.examine(user)

	attack_hand(mob/user)
		if (!src.anchored)
			return ..()
		if (user.a_intent != INTENT_HARM)
			if (user.client && hotspot_controller)
				hotspot_controller.show_map(user.client)
			return
		var/turf/T = src.loc
		user.visible_message(SPAN_ALERT("<b>[user]</b> rips down [src] from [T]!"),\
		SPAN_ALERT("You rip down [src] from [T]!"))
		var/obj/decal/cleanable/ripped_poster/decal = make_cleanable(/obj/decal/cleanable/ripped_poster, T)
		decal.icon_state = "[src.icon_state]-rip2"
		decal.pixel_x = src.pixel_x
		decal.pixel_y = src.pixel_y
		src.anchored = UNANCHORED
		src.icon_state = "[src.icon_state]-rip1"
		src.can_put_up = 0
		user.put_in_hand_or_drop(src)

	afterattack(var/atom/A as mob|obj|turf, var/mob/user as mob)
		if (src.can_put_up && (istype(A, /turf/simulated/wall) || istype(A, /turf/simulated/shuttle/wall) || istype(A, /turf/unsimulated/wall) || istype(A, /obj/window)))
			user.visible_message("<b>[user]</b> attaches [src] to [A].",\
			"You attach [src] to [A].")
			user.u_equip(src)
			src.set_loc(A)
			src.anchored = ANCHORED
		else
			return ..()
