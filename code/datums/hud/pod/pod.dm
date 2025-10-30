/datum/hud/pod
	exceeds_boundaries = TRUE
	var/obj/machinery/vehicle/master = null
	var/atom/movable/screen/hud/pod/leave_pod/leave_pod = null
	var/atom/movable/screen/hud/pod/read_only/sensor_lock/sensor_lock = null
	var/atom/movable/screen/hud/pod/read_only/tracking/tracking = null

/datum/hud/pod/New(loc)
	. = ..()

	src.master = loc
	src.leave_pod = new(null, src)
	src.sensor_lock = new(null, src)
	src.tracking = new(null, src)

	var/datum/hud_zone/main_panel = src.create_hud_zone(
		list(x_low = 1, x_high = 14, y_low = TILE_HEIGHT + 1, y_high = TILE_HEIGHT + 1),
		"main_panel",
		vertical_edge = NORTH,
	)
	main_panel.register_element(new /datum/hud_element(new /atom/movable/screen/hud/pod/engine(null, src)), "engine")
	main_panel.register_element(new /datum/hud_element(new /atom/movable/screen/hud/pod/wormhole(null, src)), "wormhole")
	main_panel.register_element(new /datum/hud_element(new /atom/movable/screen/hud/pod/life_support(null, src)), "life_support")
	main_panel.register_element(new /datum/hud_element(new /atom/movable/screen/hud/pod/comms(null, src)), "comms")
	main_panel.register_element(new /datum/hud_element(new /atom/movable/screen/hud/pod/comms_use(null, src)), "comms_use")
	main_panel.register_element(new /datum/hud_element(new /atom/movable/screen/hud/pod/sensors(null, src)), "sensors")
	main_panel.register_element(new /datum/hud_element(new /atom/movable/screen/hud/pod/sensors_use(null, src)), "sensors_use")
	main_panel.register_element(new /datum/hud_element(new /atom/movable/screen/hud/pod/weapon(null, src)), "weapon")
	main_panel.register_element(new /datum/hud_element(new /atom/movable/screen/hud/pod/lights(null, src)), "lights")
	main_panel.register_element(new /datum/hud_element(new /atom/movable/screen/hud/pod/secondary_system(null, src)), "secondary_system")
	main_panel.register_element(new /datum/hud_element(new /atom/movable/screen/hud/pod/lock(null, src)), "lock")
	main_panel.register_element(new /datum/hud_element(new /atom/movable/screen/hud/pod/set_lock_code(null, src)), "set_lock_code")
	main_panel.register_element(new /datum/hud_element(new /atom/movable/screen/hud/pod/return_to_station(null, src)), "return_to_station")
	main_panel.register_element(new /datum/hud_element(new /atom/movable/screen/hud/pod/rcs(null, src)), "rcs")

	var/datum/hud_zone/healthbar_panel = src.create_hud_zone(
		list(x_low = WIDE_TILE_WIDTH - 2, x_high = WIDE_TILE_WIDTH, y_low = TILE_HEIGHT + 1, y_high = TILE_HEIGHT + 1),
		"healthbar_panel",
		vertical_edge = NORTH,
		horizontal_edge = EAST,
	)
	healthbar_panel.register_element(new /datum/hud_element(new /atom/movable/screen/hud/pod/read_only/healthbars(null, src), width = 3), "healthbars")

	var/datum/hud_zone/exit_panel = src.create_hud_zone(
		list(x_low = WIDE_TILE_WIDTH, x_high = WIDE_TILE_WIDTH, y_low = 1, y_high = 2),
		"exit_panel",
		horizontal_edge = EAST,
	)
	exit_panel.register_element(new /datum/hud_element(src.leave_pod), "leave_pod")
	exit_panel.register_element(new /datum/hud_element(src.sensor_lock), "sensor_lock")

	var/datum/hud_zone/tracking_panel = src.create_hud_zone(
		list(x_low = 11, x_high = 11, y_low = 8, y_high = 8),
		"tracking_panel",
	)
	tracking_panel.register_element(new /datum/hud_element(src.tracking), "tracking")

	if (src.master)
		src.update_health()
		src.update_systems()
		src.update_states()
		src.update_fuel()

/datum/hud/pod/disposing()
	src.master = null
	src.leave_pod = null
	src.sensor_lock = null
	src.tracking = null
	src.delete_hud_zone("main_panel")
	src.delete_hud_zone("healthbar_panel")
	src.delete_hud_zone("exit_panel")
	src.delete_hud_zone("tracking_panel")

	. = ..()

/datum/hud/pod/proc/check_clients()
	for (var/client/C as anything in src.clients)
		if (C.mob.loc != src.master)
			src.remove_client(C)

/datum/hud/pod/proc/check_hud_layout(mob/user)
	if (user.client.tg_layout)
		leave_pod.screen_loc = "SOUTH,EAST-6"
	else
		leave_pod.screen_loc = "SOUTH,EAST"

/datum/hud/pod/proc/update_health()
	src.check_clients()

	var/atom/movable/screen/hud/pod/read_only/healthbars/healthbar_panel = src.get_hudzone("healthbar_panel").get_element("healthbars").screen_obj
	healthbar_panel.health_bar.update_health_overlays(src.master.health, src.master.maxhealth, 0, 0)

/datum/hud/pod/proc/update_fuel()
	src.check_clients()

	var/atom/movable/screen/hud/pod/read_only/healthbars/healthbar_panel = src.get_hudzone("healthbar_panel").get_element("healthbars").screen_obj
	if (istype(src.master.fueltank))
		healthbar_panel.fuel_bar.update_health_overlays(MIXTURE_PRESSURE(master.fueltank.air_contents), PORTABLE_ATMOS_MAX_RELEASE_PRESSURE, 0, 0)
	else
		healthbar_panel.fuel_bar.update_health_overlays(0, 100, 0, 0)

/datum/hud/pod/proc/update_states()
	src.check_clients()

	for (var/atom/movable/screen/hud/pod/pod_screen_obj in src.objects)
		pod_screen_obj.update_state()

/datum/hud/pod/proc/update_systems()
	src.check_clients()

	for (var/atom/movable/screen/hud/pod/pod_screen_obj in src.objects)
		pod_screen_obj.update_system()

/datum/hud/pod/proc/switch_sound()
	for (var/mob/M in src.master)
		M.playsound_local(src.master, 'sound/machines/pod_switch.ogg', 60, TRUE, ignore_flag = SOUND_IGNORE_SPACE)
