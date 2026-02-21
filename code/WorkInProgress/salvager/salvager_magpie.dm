
var/datum/magpie_manager/magpie_man = new
/datum/magpie_manager
	var/obj/npc/trader/salvager/magpie
#if !defined(LIVE_SERVER) && !defined(UNIT_TESTS)
	var/datum/mapPrefab/allocated/salvager_local/local_prefab
#endif

	proc/setup()
		src.magpie = locate("M4GP13")

		#if !defined(LIVE_SERVER) && !defined(UNIT_TESTS) // don't load the map prefab on live, it's only used for testing
		if( !magpie_man.magpie )
			src.local_prefab = get_singleton(/datum/mapPrefab/allocated/salvager_local).load()
			src.magpie = locate("M4GP13")
		#endif


/obj/salvager_cryotron
	name = "industrial cryogenic sleep unit"
	desc = "The terminus of an aging underfloor cryogenic storage complex."
	anchored = ANCHORED
	density = 1
	icon = 'icons/obj/large/32x64.dmi'

	icon_state = "cryo_close"
	event_handler_flags = IMMUNE_SINGULARITY
	var/list/folks_to_spawn = list()
	var/busy = FALSE
	var/obj/npc/trader/salvager/magpie
#ifdef RP_MODE
	var/starting_currency = 1800
#else
	var/starting_currency = 2500
#endif

	New()
		..()
		START_TRACKING
		processing_items += src
		UpdateParticles(new /particles/cryo_mist, "mist")

	proc/process()
		if(!busy)
			spawn_next_person()
		if(TIME - busy > 20 SECONDS)
			busy = FALSE

	//Return 1 if there is another person to spawn afterward
	proc/spawn_next_person()
		busy = TIME
		SPAWN(0)
			var/welcomed = FALSE
			var/particles/E = src.GetParticles("mist")
			if(length(contents))
				icon_state = "cryo_open"
				E.spawning = 0.2
				// Dispense in wall?  Throw... down?
				var/atom/movable/AM = pick(contents)

				if(ismob(AM) || iscritter(AM))
					//Sweet Smoke Effects
					sleep(1.5 SECONDS)
					AM.set_loc(get_turf(src))
					E.spawning = 0.3
					sleep(0.5 SECONDS)
					step(AM,SOUTH)

					// Welcome Them!
					if(!magpie)
						magpie = locate() in orange(5,src)
					var/fun_word = pick("scrap", "material", "shineys", "baubles", "items of value", "electronics", "trinkets")
					var/speak_name = AM.name
					if(ismob(AM))
						var/mob/M = AM
						speak_name = M.real_name
						var/currency_mod = 0
						if(world.time > 5 MINUTES)
							currency_mod = (world.time / (1 MINUTE)) * 95

						magpie.barter_customers[magpie.barter_lookup(M)] = starting_currency + currency_mod + rand(5,50)
					magpie.say("Welcome [speak_name], please bring me back some [fun_word]!")

					welcomed = TRUE
				else
					// Throw them their gear!
					sleep(0.5 SECONDS)
					AM.set_loc(get_turf(src))
					AM.throw_at(get_offset_target_turf(src.loc, 0, -5), rand(2,5), 1)

				//Close Door...
				sleep(0.5 SECONDS)
				E.spawning = 0
				icon_state = "cryo_close"
			if(welcomed)
				sleep(5 SECONDS)
				busy = FALSE
			else
				busy = FALSE

/particles/cryo_mist
	width = 100    // 500 x 500 image to cover a moderately sized map
	height = 100
	count = 5   // 2500 particles
	spawning = 0
	bound1 = list(-32, -64, 0)
	bound2 = list(32, 64, 10)
	lifespan = 10  // live for 60s max
	fade = 5
	fadein = 8
	icon = 'icons/effects/particles.dmi'
	icon_state = "mistcloud1"
	position = generator("box", list(-5,-5,0), list(5,-10,0))
	velocity = generator("box", list(-1,0,0), list(1,-1,0))


/obj/machinery/macrofab/salvager
#ifdef UNDERWATER_MAP
	name = "Sub Fabricator"
	createdObject = /obj/machinery/vehicle/tank/minisub/salvsub
#else
	name = "Pod Fabricator"
	createdObject = /obj/machinery/vehicle/miniputt/armed/salvager
#endif
	desc = "A sophisticated machine that fabricates vehicles from a nearby reserve of supplies."


	itemName = "salvager pod"
	sound_volume = 15

	attack_hand(var/mob/user)
		if(user.mind?.get_antagonist(ROLE_SALVAGER))
			..()
		else
			boutput(user, SPAN_ALERT("This machine's design makes no sense to you, you can't figure out how to use it!"))



/obj/machinery/r_door_control/salvager
	id = "hangar_salvager"
	access_type = POD_ACCESS_SALVAGER

/obj/landmark/salvager_spawn
	name = LANDMARK_SALVAGER

/obj/landmark/salvager_tele
	name = LANDMARK_SALVAGER_TELEPORTER


/obj/landmark/salvager_beacon
	name = LANDMARK_SALVAGER_BEACON

// MAGPIE Equipment
/obj/machinery/vehicle/miniputt/armed/salvager
	desc = "A repeatedly rebuilt and refitted pod.  Looks like it has seen some things."
	color = list(-0.269231,0.75,3.73077,0.269231,-0.249999,-2.73077,1,0.5,0)
	init_comms_type = /obj/item/shipcomponent/communications/salvager

	health = 250
	maxhealth = 250
	armor_score_multiplier = 0.7
	speedmod = 1.18

	New()
		..()
		src.install_part(null, new /obj/item/shipcomponent/secondary_system/lock/bioscan(src), POD_PART_LOCK)
		myhud.update_systems()
		myhud.update_states()

/datum/manufacture/pod/armor_light/salvager
	name = "Salvager Pod Armor"
	item_requirements = list("metal_dense" = 30,
							 "conductive" = 20)
	item_outputs = list(/obj/item/podarmor/salvager)
	create = 1
	time = 20 SECONDS
	category = "Component"

/obj/item/podarmor/salvager
	name = "Salvager Pod Armor"
	desc = "Exterior plating for vehicle pods."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "dbox"
	vehicle_types = list("/obj/structure/vehicleframe/puttframe" = /obj/machinery/vehicle/miniputt/armed/salvager,
						 "/obj/structure/vehicleframe/subframe" = /obj/machinery/vehicle/tank/minisub/salvsub )

/datum/manufacture/communications/salvager
	name = "Salvager Communication Array"
	item_requirements = list("metal_dense" = 10, "conductive" = 20)
	item_outputs = list(/obj/item/shipcomponent/communications/salvager)
	time = 12 SECONDS
	create = 1
	category = "Resource"

/obj/item/shipcomponent/communications/salvager
	name = "Salvager Communication Array"
	desc = "A rats nest of cables and extra parts fashioned into a shipboard communicator."
	color = "#91681c"
	access_type = list(POD_ACCESS_SALVAGER)

	go_home()
		var/escape_planet
#ifdef UNDERWATER_MAP
		escape_planet = !isrestrictedz(ship.z)
#else
		escape_planet = !isnull(station_repair.station_generator) && (ship.z == Z_LEVEL_STATION)
#endif

		if(!escape_planet)
			return

		var/turf/target = get_home_turf()
		if(!src.active)
			boutput(usr, "[ship.ship_message("Sensors inactive! Unable to calculate trajectory!")]")
			return TRUE
		if(!target)
			boutput(usr, "[ship.ship_message("Sensor error! Unable to calculate trajectory!")]")
			return TRUE

		var/obj/item/shipcomponent/engine/engine_part = ship.get_part(POD_PART_ENGINE)
		if(!engine_part)
			boutput(usr, "[ship.ship_message("Engines missing! Unable to calculate trajectory!")]")
		if(engine_part.active)
			if(engine_part.ready)
				//brake the pod, we must stop to calculate warp trajectory.
				if (istype(ship.movement_controller, /datum/movement_controller/pod))
					var/datum/movement_controller/pod/MCP = ship.movement_controller
					if (MCP.velocity_x != 0 || MCP.velocity_y != 0)
						boutput(usr, "[ship.ship_message("Ship must have ZERO relative velocity to calculate trajectory to destination!")]")
						playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
						return TRUE
				else if (istype(ship.movement_controller, /datum/movement_controller/tank))
					var/datum/movement_controller/tank/MCT = ship.movement_controller
					if (MCT.input_x != 0 || MCT.input_y != 0)
						boutput(usr, "[ship.ship_message("Ship must have ZERO relative velocity (be stopped) to calculate trajectory destination!")]")
						playsound(src, 'sound/machines/buzz-sigh.ogg', 50)
						return TRUE


				engine_part.warp_autopilot = 1
				boutput(usr, "[ship.ship_message("Charging engines for escape velocity! Overriding manual control!")]")

				var/health_perc = ship.health_percentage
				ship.going_home = FALSE
				sleep(5 SECONDS)

				if(ship.health_percentage < (health_perc - 30))
					boutput(usr, "[ship.ship_message("Trajectory calculation failure! Ship characteristics changed from calculations!")]")
				else if(src.active)
					var/old_color = ship.color
					animate_teleport(ship)
					sleep(0.8 SECONDS)
					ship.set_loc(target)
					ship.color = old_color // revert color from teleport color-shift
				else
					boutput(usr, "[ship.ship_message("Trajectory calculation failure! Loss of systems!")]")

				engine_part.ready = 0
				engine_part.warp_autopilot = 0
				engine_part.ready()
			else
				boutput(usr, "[ship.ship_message("Engine recharging! Unable to minimize trajectory error!")]")
		else
			boutput(usr, "[ship.ship_message("Engines inactive! Unable to calculate trajectory!")]")

		return TRUE

	get_home_turf()
		if((POD_ACCESS_SALVAGER in src.access_type) && length(landmarks[LANDMARK_SALVAGER_BEACON]))
			. = pick(landmarks[LANDMARK_SALVAGER_BEACON])

/obj/item/robot_foodsynthesizer/salvager
	desc = "An old food synthesizer. It seems to rusted onto the table?"
	anchored = ANCHORED

	New()
		. = ..()
		src.vend_this = "Burger"

	attack_hand(mob/user)
		src.attack_self(user)
		for(var/obj/item/reagent_containers/food/snacks/burger/synthburger/B in src.loc)
			B.setStatus("acid", 10 SECONDS)

/obj/marker/salvager_teleport
	icon_state = "X"
	icon = 'icons/misc/mark.dmi'
	name = "Salvager Teleport Marker"
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	opacity = 0

	Crossed(atom/movable/AM)
		. = ..()

		if(ismob(AM))
			var/mob/M = AM

			if(M.mind?.get_antagonist(ROLE_SALVAGER))
				if(length(landmarks[LANDMARK_SALVAGER_TELEPORTER]))
					SPAWN(0.5 SECONDS)
						if(src.loc == M.loc)
							actions.start(new /datum/action/bar/private/salvager_tele(M, null), M)
				else
					boutput(M, SPAN_ALERT("Something is wrong..."))


/obj/machinery/door/poddoor/pyro/podbay_autoclose/salvager
	name = "external blast door"
	id = "hangar_salvager"
	dir = EAST

/obj/warp_beacon/salvager
	name = "Magpie"
	icon_state = "beacon_synd"
	encrypted = POD_ACCESS_SALVAGER


/obj/machinery/manufacturer/uniform/salvager
	name = "uniform manufacturer"
	supplemental_desc = "This one can create a wide variety of one-size-fits-all jumpsuits, as well as backpacks and radio headsets."
	accept_blueprints = TRUE
	available = list(/datum/manufacture/shoes,
		/datum/manufacture/shoes_brown,
		/datum/manufacture/shoes_white,
		/datum/manufacture/civilian_headset,
		/datum/manufacture/jumpsuit_assistant,
		/datum/manufacture/jumpsuit_pink,
		/datum/manufacture/jumpsuit_red,
		/datum/manufacture/jumpsuit_orange,
		/datum/manufacture/jumpsuit_yellow,
		/datum/manufacture/jumpsuit_green,
		/datum/manufacture/jumpsuit_blue,
		/datum/manufacture/jumpsuit_purple,
		/datum/manufacture/jumpsuit_black,
		/datum/manufacture/jumpsuit,
		/datum/manufacture/jumpsuit_white,
		/datum/manufacture/jumpsuit_brown,
		/datum/manufacture/hat_black,
		/datum/manufacture/hat_white,
		/datum/manufacture/hat_pink,
		/datum/manufacture/hat_red,
		/datum/manufacture/hat_yellow,
		/datum/manufacture/hat_orange,
		/datum/manufacture/hat_green,
		/datum/manufacture/hat_blue,
		/datum/manufacture/hat_purple,
		/datum/manufacture/backpack,
		/datum/manufacture/backpack_red,
		/datum/manufacture/backpack_green,
		/datum/manufacture/backpack_blue,
		/datum/manufacture/satchel,
		/datum/manufacture/satchel_red,
		/datum/manufacture/satchel_green,
		/datum/manufacture/satchel_blue)

	hidden = list(/datum/manufacture/breathmask,
		/datum/manufacture/patch,
		/datum/manufacture/towel,
		/datum/manufacture/handkerchief)

/obj/salvager_putt_spawner
	name = "syndiputt spawner"
	icon = 'icons/obj/ship.dmi'
	icon_state = "syndi_mini_spawn"
	New()
		..()
#ifdef UNDERWATER_MAP
		new/obj/machinery/vehicle/tank/minisub/salvsub(src.loc)
#else
		new/obj/machinery/vehicle/miniputt/armed/salvager(src.loc)
#endif
		qdel(src)

/obj/machinery/vehicle/tank/minisub/salvsub
	body_type = "minisub"
	icon_state = "whitesub_body"
	health = 150
	maxhealth = 150
	acid_damage_multiplier = 0.5
	init_comms_type = /obj/item/shipcomponent/communications/salvager
	color = list(-0.269231,0.75,3.73077,0.269231,-0.249999,-2.73077,1,0.5,0)

	New()
		..()
		name = "salvager minisub"
		src.install_part(null, new /obj/item/shipcomponent/mainweapon/taser(src), POD_PART_MAIN_WEAPON)
		src.install_part(null, new /obj/item/shipcomponent/secondary_system/cargo(src), POD_PART_SECONDARY)
		src.install_part(null, new /obj/item/shipcomponent/secondary_system/lock/bioscan(src), POD_PART_LOCK)



/obj/machinery/manufacturer/hangar/magpie
	name = "ship component fabricator"
	supplemental_desc = "This one produces modules for space pods or minisubs."
	free_resources = list(
		/obj/item/material_piece/mauxite = 10,
		/obj/item/material_piece/pharosium = 10,
		/obj/item/material_piece/molitz = 10,
	)
	available = list(
#ifdef UNDERWATER_MAP
		/datum/manufacture/sub/preassembeled_parts,
#else
		/datum/manufacture/putt/preassembeled_parts,
		/datum/manufacture/pod/weapon/ltlaser,
#endif
		/datum/manufacture/engine,
		/datum/manufacture/pod/preassembeled_parts,
		/datum/manufacture/pod/armor_light,
		/datum/manufacture/pod/armor_industrial,
		/datum/manufacture/pod/armor_light/salvager,
		/datum/manufacture/cargohold,
		/datum/manufacture/communications/salvager,
		/datum/manufacture/pod/weapon/mining,
		/datum/manufacture/pod/weapon/mining/drill,
		/datum/manufacture/engine2,
		/datum/manufacture/pod/lock,
		/datum/manufacture/beaconkit
	)


/obj/minimap/salvager
	name = "Station Map"
	map_path = /datum/minimap/area_map
	map_type = MAP_SYNDICATE

	///A semi-transparent minimap marker used to communicate where the marker will be placed on the minimap.
	var/datum/minimap_marker/marker_silhouette

	Click(location, control, params)
		var/list/param_list = params2list(params)
		var/datum/minimap/area_map/minimap = map
		if ("left" in param_list)
			// Convert from screen (x, y) to map (x, y) coordinates.
			var/x = round((text2num(param_list["icon-x"]) - minimap.minimap_render.pixel_x) / (minimap.zoom_coefficient * minimap.map_scale))
			var/y = round((text2num(param_list["icon-y"]) - minimap.minimap_render.pixel_y) / (minimap.zoom_coefficient * minimap.map_scale))
			var/turf/clicked = locate(x, y, map.z_level)

			if(src.marker_silhouette)
				minimap.remove_minimap_marker(src.marker_silhouette.target)
				marker_silhouette = null
			if (!src.marker_silhouette)
				minimap.create_minimap_marker(clicked, 'icons/obj/minimap/minimap_markers.dmi', "crosshair")
				src.marker_silhouette = minimap.minimap_markers[clicked]
				src.marker_silhouette.marker.alpha = 175

			src.marker_silhouette.target = clicked
			minimap.set_marker_position(src.marker_silhouette, src.marker_silhouette.target.x, src.marker_silhouette.target.y, map.z_level)

			var/list/turf/safe_turfs = list()

			var/obj/machinery/salvager_pod_launcher/L = src.loc
			for(var/turf/T in range(L.turf_spread, clicked))
				if(L?.safe_turf(T))
					safe_turfs += T
			if(length(safe_turfs) < L.minimum_safe_turfs)
				playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 30, 0)
				boutput(usr, "You must select a location near the perimeter of the station. The missile pods will not pierce the station.")
				SPAWN(0.2 SECONDS)
					minimap.remove_minimap_marker(src.marker_silhouette.target)
			else
				playsound(src.loc, 'sound/machines/ping.ogg', 30, 0)

/obj/machinery/salvager_pod_launcher
	name = "Pod Launcher Control Console"
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "dwaine2"
	var/turf_spread = 3
	var/minimum_safe_turfs = 5
	var/launch_delay = 10 SECONDS
	var/reload_time = 5 MINUTES
	density = 1
	anchored = TRUE

	var/initial_notify_complete = FALSE
	var/landing_area
	var/obj/minimap/salvager/station_map //shouldn't be AI for testing
	var/atom/movable/minimap_ui_handler/minimap_ui

	New()
		. = ..()
		station_map = new(src)
		station_map.map_type = MAP_SYNDICATE // NEED OTHER THINGY
		minimum_safe_turfs = min(minimum_safe_turfs, round(turf_spread*turf_spread*0.6))

	attack_hand(mob/user)
		if(..())
			return

		landing_area = station_map.marker_silhouette?.target

		if(!src.landing_area)
			minimap_ui = new(src, "ai_map", src.station_map, "Station Map", "ntos")
			minimap_ui.ui_interact(user)
		else
			var/choice = input(user, "Would you like to reset your area, or Launch to the pod?") in list("Reset", "Launch", "Cancel")
			switch(choice)
				if("Reset")
					station_map.map?.remove_minimap_marker(landing_area)
					qdel(station_map.marker_silhouette)
					station_map.marker_silhouette = null
					minimap_ui = new(src, "ai_map", src.station_map, "Station Map", "ntos")
					minimap_ui.ui_interact(user)
					return
				if("Launch")
					var/list/chosen_mobs = list()
					var/area/A = get_area(src)
					for(var/mob/living/carbon/found_mob in A.contents)
						chosen_mobs += found_mob
					var/confirmation = input(user, "Are you sure you would like to deploy? [length(chosen_mobs) <= 1 ? "You're currently alone!" : "You have [length(chosen_mobs)]" ]") in list("Yes", "No")
					if(doors_ready())
						if(confirmation == "Yes")
							var/confirmation2 = input(user, "Are you EXTREMELY sure? There's no coming back!") in list("Yes", "No")
							if(confirmation2 == "Yes")
								send_to_pod(user)
							else
								return
						else
							return
					else
						playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 30, 0)
						src.visible_message("[src] flashes: \"Door Ajar!\"")
						return
				if("Cancel")
					return

	proc/doors_ready()
		var/area/A = get_area(src)
		. = TRUE
		for(var/obj/machinery/door/airlock/door in A.machines)
			. &&= (!door.operating && door.density && !door.locked)

	proc/lock_doors(lock)
		var/ready = TRUE
		var/obj/machinery/door/airlock/door
		var/list/obj/machinery/door/airlock/doors = list()
		var/area/A = get_area(src)
		for(door in A.machines)
			if(lock)
				ready &&= (!door.operating && door.density)
			doors += door
		if(ready)
			for(door in doors)
				door.locked = lock
		var/obj/machinery/light/e_light = locate("salvager_pods_avail")
		if(e_light)
			if(lock)
				e_light.light.disable()
			else
				e_light.light.enable()

	proc/send_to_pod(mob/user)
		if( !in_interact_range(user, src) || !doors_ready() )
			return
		var/list/mob/living/launched_mobs = list()
		var/area/A = get_area(src)
		lock_doors(TRUE)
		var/rand_time = src.launch_delay + rand(0 SECONDS, 5 SECONDS)
		for(var/mob/living/carbon/found_mob in A.contents)
			launched_mobs += found_mob

		for(var/mob/living/L in launched_mobs)
			shake_camera(L, rand_time*2, 8, 0.4)
			var/atom/target = get_edge_target_turf(L, pick(alldirs))
			if(target && !L.buckled)
				L.throw_at(target, 3, 1)
				L.changeStatus("stunned", 2 SECONDS)
				L.changeStatus("knockdown", 2 SECONDS)

		sleep(rand_time / 2)
		if((istype(ticker.mode, /datum/game_mode/salvager) && !initial_notify_complete) || prob(80))
			command_alert("Our sensors have detected an incoming pod is headed towards the [station_or_ship()], a response would be advised.", "Central Command Alert", 'sound/misc/announcement_1.ogg')
			initial_notify_complete = TRUE
		sleep(rand_time / 2)
		send_pods(launched_mobs)
		sleep(src.reload_time)
		lock_doors(FALSE)

	proc/safe_turf(var/turf/T)
		var/spacemove
		if(istype(T, /turf/space))
			spacemove = TRUE
			for (var/atom/A in oview(1,T))
				if (A.stops_space_move && !isfloor(A))
					spacemove = FALSE
					break
		else
			var/area/A = get_area(T)
			spacemove = !istype(A, /area/space)
		return !spacemove

	proc/send_pods(var/list/mob/living/launched_mobs)
		var/list/turf/possible_turfs = list()
		if(src.landing_area)
			for(var/turf/T in range(turf_spread, src.landing_area))
				if(safe_turf(T))
					possible_turfs += T
		for(var/mob/living/carbon/C in launched_mobs)
			var/turf/picked_turf = pick(possible_turfs)
			var/obj/arrival_missile/missile = launch_with_missile(C, picked_turf, null, "arrival_missile_synd", TRUE)
			logTheThing(LOG_DEBUG, null, "Salvager Pod: [C] fired at [log_loc(picked_turf)]. [log_loc(src.landing_area)] was target.")
			missile.color = list(0.961409,0.696086,-0.162516,0.0174579,0.685104,0.0735192,0.471909,0.123506,1.39666)

			possible_turfs -= picked_turf
			if(!length(possible_turfs))
				for(var/turf/T in range(turf_spread, src.landing_area))
					if(safe_turf(T))
						possible_turfs += T
		command_alert("A [length(launched_mobs) > 1 ? "group of [length(launched_mobs)] personnel missiles have" : "single personnel missile has"] been spotted heading towards the station, be prepared for contact.","Central Command Alert", 'sound/misc/announcement_1.ogg')



TYPEINFO(/obj/npc/trader/salvager)
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN)

/obj/npc/trader/salvager
	name = "M4GP13 Salvage and Barter System"
	icon = 'icons/obj/trader.dmi'
	icon_state = "crate_dispenser"
	picture = "generic.png"
	angrynope = "Unable to process request."
	whotext = "I am the salvage reclamation and supply commissary.  In short I will provide goods in exchange for reclaimed materials and equipment."
	barter = TRUE
	currency = "Salvage Points"
	speech_verb_say = "beeps"
	use_speech_bubble = TRUE
	voice_sound_override = 'sound/misc/talk/bottalk_1.ogg'

	var/distribute_earnings = FALSE

	New()
		..()

		for(var/sell_type in concrete_typesof(/datum/commodity/magpie/sell))
			src.goods_sell += new sell_type(src)

		for(var/buy_type in (concrete_typesof(/datum/commodity/magpie/buy) - concrete_typesof(/datum/commodity/magpie/buy/random_buy)))
			src.goods_buy += new buy_type(src)

		greeting= {"[src.name]'s light flash, and he states, \"Greetings, welcome to my shop. Please select from my available equipment.\""}

		sell_dialogue = "[src.name] states, \"There are several individuals in my database that are looking to procure goods."

		buy_dialogue = "[src.name] states,\"Please select what you would like to buy\"."

		successful_sale_dialogue = list("[src.name] states, \"Thank you for the business organic.\"",
			"[src.name], \"I am adding you to the Good Customer Database.\"")

		failed_sale_dialogue = list("[src.name] states, \"<ERROR> Item not in purchase database.\"",
			"[src.name] states, \"I'm sorry I currently have no interest in that item, perhaps you should try another trader.\"",
			"[src.name] starts making a loud and irritating noise. [src.name] states, \"Fatal Exception Error: Cannot locate item\"",
			"[src.name] states, \"Invalid Input\"")

		successful_purchase_dialogue = list("[src.name] states, \"Thank you for your business\".",
			"[src.name] states, \"Looking forward to future transactions\".")

		failed_purchase_dialogue = list("[src.name] states, \"I am sorry, but you currenty do not have enough funds to purchase this.\"",
			"[src.name] states, \"Funds not found.\"")

		pickupdialogue = "[src.name] states, \"Thank you for your business. Please come again\"."

		pickupdialoguefailure = "[src.name] states, \"I'm sorry, but you don't have anything to pick up\"."

	sold_item(datum/commodity/C, obj/S, amount, mob/user as mob)
		. = ..()
		if(istype(C, /datum/commodity/magpie/buy))
			var/datum/commodity/magpie/buy/salvager_commodity = C
			. = round(salvager_commodity.price_check(S) * amount)

		if(istype(C, /datum/commodity/magpie/buy/random_buy))
			var/datum/commodity/magpie/buy/random_buy/RB = C
			RB.reroll_commodity()

		var/datum/antagonist/salvager/SA = user?.mind?.get_antagonist(ROLE_SALVAGER)
		if(SA)
			SA.salvager_points += .

		if(src.distribute_earnings && round(. * src.distribute_earnings / length(src.barter_customers)))
			var/portion = round(. * src.distribute_earnings / length(src.barter_customers))
			for(var/customer in barter_customers)
				src.barter_customers[customer] += portion
			. -= length(src.barter_customers) * portion

	attackby(obj/item/I, mob/user)
		var/scan_time = 1.8 SECONDS
		if(ON_COOLDOWN(src, "scanning", scan_time * 1.5))
			return

		. = appraise_text(I)

		animate_scanning(user, . ? "#FFFF00" : "#ff4400", scan_time)
		sleep(scan_time)
		src.say(.)

	proc/appraise(obj/item/I)
		if(I.deconstruct_flags || isitem(I))
			var/datum/commodity/magpie/buy/salvager_commodity = most_applicable_trade(src.goods_buy, I)
			var/datum/commodity/magpie/sell/selling_commodity = most_applicable_trade(src.goods_sell, I)
			if(salvager_commodity)
				. = salvager_commodity.price_check(I)
				if(istype(I))
					. *= I.amount

				// Ensure that all items sell for less than what they can be purchased for
				// except for power sink because we want to buy AND sell it
				if(selling_commodity && !istype(salvager_commodity, /datum/commodity/magpie/buy/power_sink))
					var/buy_cost = selling_commodity.price
					if(istype(I))
						buy_cost *= I.amount
					if(. > buy_cost)
						. = min(., buy_cost * 0.8)


	proc/appraise_text(obj/item/I)
		. = appraise(I)
		if(.)
			if(prob(90))
				. = "Current market value is [.]."
			else
				if(prob(20))
					. = "[.] is the best I can do."
				else
					. = "[.]."
			if(src.distribute_earnings)
				if(prob(50))
					. += " [src.distribute_earnings*100]% of that will be distributed amongst the crew."
				else
					. += " [src.distribute_earnings*100]% will be shared."
		else
			if(prob(95))
				. = "Current market value is 0."
			else
				. = "No record of a buyer for [I]."

	barter_lookup(mob/M)
		. = M?.bioHolder?.Uid
		if(!.)
			. = ..()


/////////////////
// M4GP13 Trader
/////////////////

ABSTRACT_TYPE(/datum/commodity/magpie/buy)
/datum/commodity/magpie/buy

	proc/price_check(obj/item)
		. = src.price

		if(GET_COOLDOWN(item, "SALVAGER PART"))
			. = 5

	materials
		comname = "Processed Material Bar"
		comtype = /obj/item/material_piece
		desc_buy = "This forms the backbone of the salvage economy. We need it today and others will need it tomorrow."
		price = 10

		price_check(obj/O)
			. = ..()
			if(O?.material)
				if(O.material.getID() in list("slag", "glass"))
					. *= 0.4
				else if(O.material.getID() in list("char"))
					. *= 0.2

				if(O.material.getProperty("reflective") >= 7)
					. *= 1.3
				if(O.material.getProperty("radioactive") >= 5)
					. *= 1.3

				if(O.material.getProperty("density") >= 5)
					. *= 1.2
				if(O.material.getProperty("hard") >= 5)
					. *= 1.2
				if(O.material.getProperty("electrical") >= 5)
					. *= 1.2

	sheet
		comname = "Material Sheets"
		comtype = /obj/item/sheet
		desc_buy = "Metal to glass these are common building blocks of many salvaged goods."
		price = 1

	machine_frame
		comname = "Disassembled Frame"
		comtype = /obj/item/electronics/frame
		desc_buy = "Machinery and electronics are highly valued and will fetch a decent price.  Price subject to source and quality of product."
		price = 100

		price_check(obj/O)
			. = ..()
#ifdef SECRETS_ENABLED
			var/obj/item/electronics/frame/F = O

			var/path
			if(istype(F))
				if(F.deconstructed_thing)
					path = F.deconstructed_thing.type
				else
					path = F.store_type
			else
				path = O.type

			for(var/type in value_list)
				if(ispath(path, type))
					. += value_list[type]
					break
#endif

			. = source_adjustment(O, .)

		proc/source_adjustment(obj/O, value)
			. = value

			if(length(O.req_access))
				. += 75

			if( O.icon_state != "dbox_big")
				. /= 10
			else
				if(!GET_COOLDOWN(O,"OEM PART"))
					. *= 0.5
				if(!GET_COOLDOWN(O,"STATION"))
					. *= 0.8

	machine_frame/machine
		hidden = TRUE
		comtype = /obj/machinery

		source_adjustment(obj/O, value)
			. = value

			if(length(O.req_access))
				. += 75

			if(!GET_COOLDOWN(O,"OEM PART"))
				. *= 0.5
			if(!istype(get_area(O),/area/station))
				. *= 0.8

	machine_frame/machine/submachine
		hidden = TRUE
		comtype = /obj/submachine

	power_sink
		hidden = TRUE
		comtype = /obj/item/device/powersink/salvager

		price_check(obj/O)
			. = 0
			var/obj/item/device/powersink/salvager/sink = O
			if(istype(O))
				. =	round(( sink.power_drained / sink.max_power ) * 15000)

	robotics
		comname = "Robot Parts"
		comtype = /obj/item/parts/robot_parts
		desc_buy = "There are always a number of groups in need of some robot parts."
		price = 25

	telecrystal
		comname = "Telecrystal"
		comtype = /obj/item/raw_material/telecrystal
		desc = "Rare space-warping are highly valued and needed for continued salvaging operations."
		price = 200

	gemstone
		comname = "Gemstone"
		comtype = /obj/item/raw_material/gemstone
		desc = "A cornerstone of both jewelry and often specalty electronics.  There are always a buyer."
		price = 150


ABSTRACT_TYPE(/datum/commodity/magpie/buy/random_buy)
/datum/commodity/magpie/buy/random_buy
	var/list/targets = list()

	proc/reroll_commodity()
		if(length(src.targets))
			src.comtype = pick(src.targets)
			var/value = src.targets[src.comtype]
			src.targets -= src.comtype
			var/obj/object_type = src.comtype
			src.comname = initial(object_type.name)
			price = value
			baseprice = value
			upperfluc = value * 0.10
			lowerfluc = value * -0.05
		else
			comtype = null
			hidden = TRUE

	New()
		..()
		reroll_commodity()

ABSTRACT_TYPE(/datum/commodity/magpie/sell)
/datum/commodity/magpie/sell

	teleporter
		comname = "Handheld teleporter to Magpie"
		desc = "Recovered and repurposed teleportation technology.  It works most of the time."
		comtype = /obj/item/salvager_hand_tele
		price = 400

	helmet
		comname = "Combat Helm"
		desc = "Heavily modified combination of industrial and military combat headgear."
		comtype = /obj/item/clothing/head/helmet/space/industrial/salvager
		price = 250

	armor
		comname = "Combat armor"
		desc = "Heavily modified combination of industrial and military combat gear."
		comtype = /obj/item/clothing/suit/space/industrial/salvager
		price = 500

	arcwelder
		comname = "Arc Welder"
		desc = "A self-recharging handheld arc welder.  Weld some metal or arc some people."
		comtype = /obj/item/weldingtool/arcwelder
		price = 500

	caxe
		comname = "Crash axe"
		desc = "A light utility axe that can be serviced as a vicious weapon."
		comtype = /obj/item/crashaxe
		price = 400

	sledgehammer
		comname = "Sledgehammer"
		desc = "A classic means of manual demolition."
		comtype = /obj/item/breaching_hammer/salvager
		price = 500
		amount = 4

#ifdef SECRETS_ENABLED
	improved_zipgun
		comname = "Customized Zip gun"
		desc = "An improvised firearm made from other firearms.  Modified for field repair."
		comtype = /obj/item/gun/kinetic/zipgun/salvager
		price = 350
#endif

	shotgun
		comname = "Pump action shotgun"
		desc = "A salvaged and rebuilt pump action shotgun."
		comtype = /obj/item/gun/kinetic/pumpweapon/riotgun/salvager
		price = 1200
		amount = 6

	quadbarrel
		comname = "Four Letter Word"
		desc = "Built around a shotgun that couldn't be reclaimed, this weapon trades stability for versatility."
		comtype = /obj/item/gun/kinetic/sawnoff/quadbarrel
		price = 1200
		amount = 4

	flare_ammo
		comname = "12ga Flare Shells"
		comtype = /obj/item/ammo/bullets/flare
		desc = "Military-grade 12 gauge flare shells."
		price = 250

	makeshift_laser
		comname = "Makeshift Laser Rifle"
		desc = "A makeshift laser rifle outfitted with a tube and cell."
		comtype = /obj/item/gun/energy/makeshift/basic_salvager
		price = 650
		amount = 4

	rifle
		comname = "Survival Rifle"
		desc = "Semi-automatic rifle with easily convertible caliber. Starts in .22 caliber."
		comtype = /obj/item/gun/kinetic/survival_rifle
		price = 1000

	bullets_22
		comname = ".22 magazine"
		desc = "A small .22 magazine for kinetic firearms."
		comtype = /obj/item/ammo/bullets/bullet_22
		price = 200
		amount = 4

	bullets_22_hp
		comname = ".22 Hollow Point magazine"
		desc = "A small .22 HP magazine for kinetic firearms. Less penetration and more pain."
		comtype = /obj/item/ammo/bullets/bullet_22HP
		price = 500
		amount = 10

	rifle_9mm
		comname = "Rifle 9mm conversion"
		desc = "Survival rifle conversion kit to 9mm."
		comtype = /obj/item/survival_rifle_barrel/barrel_9mm
		price = 500
		amount = 10

	bullets_9mm
		comname = "9mm magazine"
		desc = "A handgun magazine with 9x19mm rounds."
		comtype = /obj/item/ammo/bullets/bullet_9mm
		price = 399
		amount = 10

#ifndef RP_MODE
	rifle_556
		comname = "Rifle 5.56x45 conversion"
		desc = "Survival rifle conversion kit to 5.56x45mm NATO."
		comtype = /obj/item/survival_rifle_barrel/barrel_556
		price = 969
#endif

	assault_mag
		comname = "Rifle magazine"
		desc = "A magazine of 5.56 rounds, an intermediate rifle cartridge."
		comtype =  /obj/item/ammo/bullets/assault_rifle
		price = 699
		amount = 10

	assault_mag_ap
		comname = "Armor Piercing Rifle magazine"
		desc = "A magazine of 5.56 AP rounds, an intermediate rifle cartridge."
		comtype =  /obj/item/ammo/bullets/assault_rifle/armor_piercing
		price = 850
		amount = 8

	pepper_nades
		comname = "Crowd Dispersal Grenades"
		desc = "A box of crowd dispersal grenades"
		comtype = /obj/item/storage/box/crowdgrenades
		price = 400
		amount = 4

	flash_n_smoke
		comname = "Grenade Pouch"
		desc = "Flashbang and smoke grenades."
		comtype = /obj/item/storage/grenade_pouch/salvager_distract
		price = 350
		amount = 6

#ifndef UNDERWATER_MAP
	pod_kinetic
		comname = "SPE-12 Ballistic System"
		comtype = /obj/item/shipcomponent/mainweapon/gun
		desc = "A pod-mounted kinetic weapon system."
		price = 5000
		amount = 3

	pod_kinetic_9mm
		comname = "PEP-9L Ballistic System"
		comtype = /obj/item/shipcomponent/mainweapon/gun_9mm/uses_ammo
		desc = "A pod-mounted kinetic weapon system. Has limited ammunition."
		price = 3000
		amount = 3

	pod_kinetic_22
		comname = "PEP-22L Ballistic System"
		comtype = /obj/item/shipcomponent/mainweapon/gun_22/uses_ammo
		desc = "A pod-mounted kinetic weapon system. Has limited ammunition."
		price = 2200
		amount = 3

	pod_40mm
		comname = "40mm Assault Platform"
		comtype = /obj/item/shipcomponent/mainweapon/artillery/lower_ammo
		desc = "A pair of pod-mounted ballistic launchers, fires explosive 40mm shells. Holds 6 shells."
		price = 8000
		amount = 3

	artillery_ammo
		comname = "40mm HE Ammunition"
		comtype = /obj/item/ammo/bullets/autocannon
		desc = "High explosive grenades, for the resupplement of artillery assault platforms."
		price = 1500
		amount = 2
#endif

	barbed_wire
		comname = "Barbed Wire"
		comtype = /obj/item/deployer/barricade/barbed/wire
		desc = "A coiled up length of barbed wire that can be used to make some kind of barricade."
		price = 350
		amount = 10

#ifdef SECRETS_ENABLED
	shield
		comname = "Makeshift Riot Shield"
		desc = "A giant sheet of steel with a strap.  Not quite the acme of defense but it should do."
		comtype = /obj/item/salvager_shield
		price = 700
		amount = 4

	shield_belt
		comname = "Shield Belt"
		comtype = /obj/item/storage/belt/powered/salvager
		desc = "Belt generates an energy field around the user.  Provides some environmental protection as well."
		price = 1200
		amount = 4
#endif

	radiojammer
		comname = "Radio Jammer"
		comtype = /obj/item/radiojammer
		desc = "A device that can block radio transmissions around it.  Recovered from a syndicate vessel."
		price = 2000

#ifdef SECRETS_ENABLED
	door_hacker
		comname = "Door Hacker Assistant"
		comtype = /obj/item/door_hacker
		desc = "A device that when connected to a door panel will determine the function of each wire."
		price = 100
#endif

	power_sink
		comname = "Power Sink and Storage"
		comtype = /obj/item/device/powersink/salvager
		desc = "A device that can be used to drain power and sell it back to the M4GP13."
		price = 1000
		amount = 4

	crank
		comname = "Crank (5x pills)"
		comtype = /obj/item/storage/pill_bottle/crank
		desc = "A cheap and dirty stimulant drug."
		price = 50

	meth
		comname = "Meth (5x pills)"
		comtype = /obj/item/storage/pill_bottle/methamphetamine
		desc = "A highly effective and dangerous stimulant drug."
		price = 350

	salvager
		comname = "Salvage Reclaimer"
		desc = "Replacement salvage reclaimer.  Sometimes you lose things and sometimes people take things..."
		comtype = /obj/item/salvager
		price = 100

	decon
		comname = "Dualconstructor"
		desc = "Replacement dualconstructor.  Sometimes you lose things and sometimes people yeet them into space..."
		comtype = /obj/item/tool/omnitool/dualconstruction_device
		price = 10

	omnitool
		comname = "Omnitool"
		desc = "Replacement omnitool.  No one wants to carry around each tool individually."
		comtype = /obj/item/tool/omnitool
		price = 100
		amount = 6

	comm_upgrade
		comname = "Radio channel upgrade"
		desc = "Key to retrofit an existing headset to support Salvager frequencies."
		comtype = /obj/item/device/radio_upgrade/salvager
		price = 10

	salvager_goggles
		comname = "Salvager Goggles"
		desc = "Salvager Appraisal Visualizer. Provides a rough estimate of the value of things nearby."
		comtype = /obj/item/clothing/glasses/salvager
		price = 50

	telecrystal
		comname = "Telecrystal"
		comtype = /obj/item/raw_material/telecrystal
		desc = "Rare space-warping are highly valued and needed for continued salvaging operations."
		price = 225

ABSTRACT_TYPE(/datum/commodity/magpie/special/sell/arms)
/datum/commodity/magpie/special/sell/arms
	pistol
		comname = "9mm pistol"
		desc = "A rare semi-automatic 9mm pistol that was collected from an military vessel."
		comtype = /obj/item/gun/kinetic/pistol
		price = 1650
		amount = 4

	pulse_rifle
		comname = "Pulse Rifle"
		desc = "A sleek energy rifle. Often kept under lock and key at nanotrasen facilities."
		comtype = /obj/item/gun/energy/pulse_rifle
		price = 1800
		amount = 6

	breaching_charge
		comname = "Thermite Breaching Charge"
		desc = "A self-contained thermite breaching charge, useful for destroying walls."
		comtype = /obj/item/breaching_charge/thermite
		price = 500
		amount = 4

#ifdef RP_MODE
	rifle_556
		comname = "Rifle 5.56x45 conversion"
		desc = "Survival rifle conversion kit to 5.56x45mm NATO."
		comtype = /obj/item/survival_rifle_barrel/barrel_556
		price = 969
#endif

ABSTRACT_TYPE(/datum/commodity/magpie/special/sell/pirate)
/datum/commodity/magpie/special/sell/pirate
	rifle
		comname = "Replica Flintlock Rifle"
		desc = "Flintlock rifle and 15 rounds of ammunition provided in a specialised satchel."
		comtype = /obj/item/storage/backpack/satchel/flintlock_rifle_satchel
		price = 550
		amount = 5

	pistol
		comname = "Replica flintlock pistols"
		desc = "A set of two flintlock pistols and 15 rounds of ammunition."
		comtype = /obj/item/storage/backpack/satchel/flintlock_pistol_satchel
		price = 750
		amount = 4

	sabre
		comname = "Replica Pirate's Sabre"
		desc = "A sharp sabre for the most feared of all space pirates. Being you of course."
		comtype = /obj/item/swords_sheaths/pirate
		price = 650
		amount = 3


ABSTRACT_TYPE(/datum/commodity/magpie/special/buy/pirate)
/datum/commodity/magpie/special/buy/pirate

	proc/price_check(obj/item)
		. = src.price
	bullion
		comname = "Stamped Gold Bullion"
		comtype = /obj/item/stamped_bullion
		price = 1000

