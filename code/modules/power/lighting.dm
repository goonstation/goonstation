// The lighting system
//
// consists of light fixtures (/obj/machinery/light) and light tube/bulb items (/obj/item/light)


// light_status values shared between lighting fixtures and items
// defines moved to _setup.dm by ZeWaka
#define INSTALL_WALL 1
#define INSTALL_FLOOR 2
/// Amount of time it takes to attach a light fixture to a tile by hand
#define LIGHT_FIXTURE_ATTACH_TIME 4 SECONDS
/// Amount of time it takes to remove a light fixture from a tile by hand
#define LIGHT_FIXTURE_DETACH_TIME 2 SECONDS
/// Probabilty a worn/burned out light will break
#define WORN_LIGHT_BREAKPROB 5

TYPEINFO(/obj/item/light_parts)
	mats = 4

/obj/item/light_parts
	name = "fixture parts"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-fixture"
	material_amt = 0.2

	var/installed_icon_state = "tube-empty"
	var/installed_base_state = "tube"
	desc = "Parts of a lighting fixture"
	var/fixture_type = /obj/machinery/light
	var/light_type = /obj/item/light/tube
	var/fitting = "tube"
	var/install_type = INSTALL_WALL
	var/has_bulb = TRUE

	New()
		..()
		UpdateIcon()

	update_icon()
		..()
		if (src.has_bulb)
			var/image/light_image = SafeGetOverlayImage("light", src.icon, "[fitting]-light")
			src.AddOverlays(light_image, "light")
			return
		src.ClearSpecificOverlays("light")


// For metal sheets. Can't easily change an item's vars the way it's set up (Convair880).
/obj/item/light_parts/bulb
	name = "bulb fixture parts"
	icon_state = "bulb-fixture"
	fixture_type = /obj/machinery/light/small
	installed_icon_state = "bulb1"
	installed_base_state = "bulb"
	fitting = "bulb"
	light_type = /obj/item/light/bulb

/obj/item/light_parts/floor
	name = "floor fixture parts"
	icon_state = "floor-fixture"
	fixture_type = /obj/machinery/light/small/floor/netural
	installed_icon_state = "floor1"
	installed_base_state = "floor"
	fitting = "floor"
	light_type = /obj/item/light/bulb
	install_type = INSTALL_FLOOR

/obj/item/light_parts/proc/copy_light(obj/machinery/light/target)
	installed_icon_state = target.icon_state
	installed_base_state = target.base_state
	light_type = target.light_type
	if (!target.inserted_lamp)
		has_bulb = FALSE
	fixture_type = target.type
	fitting = target.fitting
	if (fitting == "tube")
		icon_state = "tube-fixture"
	else if (fitting == "floor")
		icon_state = "floor-fixture"
	else
		icon_state = "bulb-fixture"
	UpdateIcon()

/obj/item/light_parts/New()
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(attach_fixture))

/obj/item/light_parts/proc/can_attach(atom/target, mob/user)
	var/dir = NORTH
	var/turf/checkturf = get_turf(target)
	if (src.install_type == INSTALL_FLOOR)
		if (!istype(target, /turf/simulated/floor))
			return FALSE
	else if (src.install_type == INSTALL_WALL)
		if (!istype(target, /obj/window) && !istype(target, /turf/simulated/wall))
			return FALSE
		dir = get_dir(checkturf, user)
		checkturf = get_step(checkturf, dir)
		if (!is_cardinal(dir))
			boutput(user, "You can't seem to reach that part of \the [target]. Try standing right up against it.")
			return FALSE
	dir = turn(dir, 180)
	for (var/obj/machinery/light/L in checkturf)
		if (L.dir == dir && L.install_type == src.install_type)
			boutput(user, "There's already a lamp there!")
			return FALSE
	return TRUE

/obj/item/light_parts/proc/attach_fixture(atom/self, atom/target, mob/user, instantly)
	if (!user)
		return FALSE

	if (!src.can_attach(target, user))
		return FALSE

	var/dir = NORTH
	if (src.install_type == INSTALL_WALL)
		dir = get_dir(get_turf(target), user)

	if(!instantly)
		playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
		boutput(user, "You begin to attach the [src] to [target]...")
		SETUP_GENERIC_ACTIONBAR(user, src, LIGHT_FIXTURE_ATTACH_TIME, /obj/item/light_parts/proc/finish_attaching,\
			list(target, user, dir), src.icon, src.icon_state, null, null)
	else
		finish_attaching(target, user, dir)
	return TRUE

/obj/item/light_parts/proc/finish_attaching(atom/target, mob/user, var/light_dir)
	var/turf/turf_target = get_turf(target)
	// wall lights are actually on the turf next to the wall
	if (src.install_type == INSTALL_WALL)
		turf_target = get_step(turf_target, light_dir)
	var/obj/machinery/light/newlight = new src.fixture_type(turf_target)
	boutput(user, "You attach \the [src] to \the [target].")
	newlight.set_dir(turn(light_dir, 180))
	newlight.icon_state = src.installed_icon_state
	newlight.base_state = src.installed_base_state
	newlight.fitting = src.fitting
	if (!src.has_bulb)
		newlight.current_lamp.light_status = LIGHT_EMPTY
		newlight.inserted_lamp = null
		newlight.update()
	newlight.add_fingerprint(user)
	// this does the exact pixel positioning and stuff for the walls to line up with sprites
	if (src.install_type == INSTALL_WALL)
		newlight.nostick = 0
		newlight.autoposition(turn(light_dir, 180), TRUE)
	src.add_fingerprint(user)
	user.u_equip(src)
	qdel(src)

//MBC : moving lights to consume power inside as an area-wide process() instead of each individual light processing its own shit
/obj/machinery/light_area_manager
	#define LIGHTING_POWER_FACTOR 40
	name = "Area Lighting"
	event_handler_flags = IMMUNE_SINGULARITY | USE_FLUID_ENTER
	invisibility = INVIS_ALWAYS_ISH
	anchored = ANCHORED_ALWAYS
	var/area/my_area = null
	var/list/lights = list()
	var/brightness_placeholder = 1	//hey, maybe later use this in a way that is more optimized than iterating through each individual light

/obj/machinery/light_area_manager/ex_act(severity)
	return

/obj/machinery/light_area_manager/process()
	if(my_area?.power_light && my_area.lightswitch)
		..()
		var/thepower = src.brightness_placeholder * LIGHTING_POWER_FACTOR
		use_power(thepower * lights.len, LIGHT)


// the standard tube light fixture

ADMIN_INTERACT_PROCS(/obj/machinery/light, proc/broken, proc/admin_toggle, proc/admin_fix)

/var/global/stationLights = new/list()
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	var/base_state = "tube"		// base description and icon_state
	icon_state = "tube1"
	desc = "A lighting fixture."
	anchored = ANCHORED
	layer = EFFECTS_LAYER_UNDER_1
	plane = PLANE_NOSHADOW_ABOVE
	text = ""
	flags = FLUID_SUBMERGE | USEDELAY
	material_amt = 0.2

	var/on = 0 // 1 if on, 0 if off
	var/brightness = 1.6 // luminosity when on, also used in power calculation

	var/obj/item/light/light_type = /obj/item/light/tube // the type of the inserted light item
	var/allowed_type = /obj/item/light/tube // the type of allowed light items

	var/inserted_lamp = null // Reference for the actual lamp item inside
	var/obj/item/light/current_lamp = null // For easily accessing inserted_lamp's variables, which we do often enough. Don't desync these two!

	var/fitting = "tube"
	var/wallmounted = 1
	var/nostick = 1 //If set to true, overrides the autopositioning.
	var/candismantle = 1

	power_usage = 0
	power_channel = LIGHT
	var/removable_bulb = 1
	var/datum/light/point/light
	var/install_type = INSTALL_WALL

	var/obj/dummy/light_overlay // Light overlay object to place in `src.vis_contents`

	pass_unstable = TRUE

	New()
		..()
		inserted_lamp = new light_type()
		current_lamp = inserted_lamp
		if (src.loc.z == 1)
			stationLights += src

		var/area/A = get_area(src)
		if (A)
			UnsubscribeProcess()
			A.add_light(src)

	disposing()
		if (src in stationLights)
			stationLights -= src

		if (inserted_lamp)
			qdel(inserted_lamp)
			inserted_lamp = null

		var/area/A = get_area(src)
		if (A)
			A.remove_light(src)
		if (light)
			light.dispose()

		qdel(src.light_overlay)
		src.light_overlay = null
		..()

	proc/autoposition(setdir = null, instant = FALSE)
		//auto position these lights so i don't have to mess with dirs in the map editor that's annoying!!!
		if (nostick == 0) // unless nostick is set to true in which case... dont
			SPAWN (instant ? -1 : 1 DECI SECOND) // potentially wait for the wingrille spawners to complete when map is loading (ugly i am sorry)
				var/turf/T = null
				var/list/directions = null
				if (setdir)
					directions = list(setdir)
				else
					directions = cardinal
				for (var/dir in directions)
					T = get_step(src,dir)
					if(istype(T,/turf/simulated/false_wall))
						continue
					if (istype(T,/turf/simulated/wall) || istype(T,/turf/unsimulated/wall) || (locate(/obj/mapping_helper/wingrille_spawn) in T) || (locate(/obj/window) in T))
						var/is_jen_wall = 0 // jen walls' ceilings are narrower, so let's move the lights a bit further inward!
						if (istype(T, /turf/simulated/wall/auto/jen) || istype(T, /turf/simulated/wall/auto/reinforced/jen))
							is_jen_wall = 1
						src.set_dir(dir)
						if (dir == EAST)
							if (is_jen_wall)
								src.pixel_x = 12
							else
								src.pixel_x = 10
						else if (dir == WEST)
							if (is_jen_wall)
								src.pixel_x = -12
							else
								src.pixel_x = -10
						else if (dir == NORTH)
							if (is_jen_wall)
								src.pixel_y = 24
							else
								src.pixel_y = 21
						break
				T = null

	Cross(atom/movable/mover)
		. = ..()
		if(istype(mover, /obj/projectile))
			var/obj/projectile/P = mover
			if(P.called_target == src && P.proj_data?.damage > 5)
				. = FALSE

	bullet_act(obj/projectile/P)
		. = ..()
		src.broken(explode_rigged = TRUE)

//big standing lamps
/obj/machinery/light/flamp
	name = "floor lamp"
	icon = 'icons/obj/lighting.dmi'
	desc = "A tall and thin lamp that rests comfortably on the floor."
	anchored = ANCHORED
	light_type = /obj/item/light/bulb
	allowed_type = /obj/item/light/bulb
	fitting = "bulb"
	brightness = 1.4
	var/state
	base_state = "flamp"
	icon_state = "flamp1"
	wallmounted = 0
	install_type = INSTALL_FLOOR

//regular light bulbs
/obj/machinery/light/small
	icon_state = "bulb1"
	base_state = "bulb"
	fitting = "bulb"
	brightness = 1.2
	desc = "A small lighting fixture."
	light_type = /obj/item/light/bulb
	allowed_type = /obj/item/light/bulb

	netural
		name = "incandescent light bulb"
		light_type = /obj/item/light/bulb/neutral
	greenish
		name = "greenish incandescent light bulb"
		light_type = /obj/item/light/bulb/greenish
	blueish
		name = "blueish fluorescent light bulb"
		light_type = /obj/item/light/bulb/blueish
	purpleish
		name = "purpleish fluorescent light bulb"
		light_type = /obj/item/light/bulb/purpleish
	frostedred
		name = "frosted red fluorescent light bulb"
		light_type = /obj/item/light/bulb/emergency

	warm
		name = "fluorescent light bulb"
		light_type = /obj/item/light/bulb/warm
		very
			name = "warm fluorescent light bulb"
			light_type = /obj/item/light/bulb/warm/very

	cool
		name = "cool incandescent light bulb"
		light_type = /obj/item/light/bulb/cool
		very
			name = "very cool incandescent light bulb"
			light_type = /obj/item/light/bulb/cool/very

	harsh
		name = "harsh incandescent light bulb"
		light_type = /obj/item/light/bulb/harsh
		very
			name = "very harsh incandescent light bulb"
			light_type = /obj/item/light/bulb/harsh/very

	broken //Made at first to replace a decal in cog1's wreckage area
		name = "shattered light bulb"
		icon_state = "bulb-broken"

		New()
			..()
			current_lamp.light_status = LIGHT_BROKEN

	//The only difference between these small lights and others are that these automatically stick to walls! Wow!!
	sticky
		nostick = 0

		New()
			..()
			autoposition()

		netural
			name = "incandescent light bulb"
			light_type = /obj/item/light/bulb/neutral
		greenish
			name = "greenish incandescent light bulb"
			light_type = /obj/item/light/bulb/greenish
		blueish
			name = "blueish fluorescent light bulb"
			light_type = /obj/item/light/bulb/blueish
		purpleish
			name = "purpleish fluorescent light bulb"
			light_type = /obj/item/light/bulb/purpleish
		frostedred
			name = "frosted red fluorescent light bulb"
			light_type = /obj/item/light/bulb/emergency

		warm
			name = "fluorescent light bulb"
			light_type = /obj/item/light/bulb/warm
			very
				name = "warm fluorescent light bulb"
				light_type = /obj/item/light/bulb/warm/very

		cool
			name = "cool incandescent light bulb"
			light_type = /obj/item/light/bulb/cool
			very
				name = "very cool incandescent light bulb"
				light_type = /obj/item/light/bulb/cool/very

		harsh
			name = "harsh incandescent light bulb"
			light_type = /obj/item/light/bulb/harsh
			very
				name = "very harsh incandescent light bulb"
				light_type = /obj/item/light/bulb/harsh/very

		broken //Made at first to replace a decal in cog1's wreckage area
			name = "shattered light bulb"
			icon_state = "bulb-broken"

			New()
				..()
				current_lamp.light_status = LIGHT_BROKEN

/obj/machinery/light/small/uninstall_fixture()
	var/obj/item/light_parts/bulb/parts = new /obj/item/light_parts/bulb(get_turf(src))
	parts.copy_light(src)
	qdel(src)

//floor lights
/obj/machinery/light/small/floor
	icon_state = "floor1"
	base_state = "floor"
	desc = "A small lighting fixture, embedded in the floor."
	plane = PLANE_FLOOR
	allowed_type = /obj/item/light/bulb
	install_type = INSTALL_FLOOR

	New()
		..()

	netural
		name = "incandescent light fixture"
		light_type = /obj/item/light/bulb/neutral
	greenish
		name = "greenish incandescent light fixture"
		light_type = /obj/item/light/bulb/greenish
	blueish
		name = "blueish fluorescent light fixture"
		light_type = /obj/item/light/bulb/blueish
	purpleish
		name = "purpleish fluorescent light fixture"
		light_type = /obj/item/light/bulb/purpleish
	frostedred
		name = "frosted red fluorescent light fixture"
		light_type = /obj/item/light/bulb/emergency


	warm
		name = "fluorescent light fixture"
		light_type = /obj/item/light/bulb/warm
		very
			name = "warm fluorescent light fixture"
			light_type = /obj/item/light/bulb/warm/very

	cool
		name = "cool incandescent light fixture"
		light_type = /obj/item/light/bulb/cool
		very
			name = "very cool incandescent light fixture"
			light_type = /obj/item/light/bulb/cool/very

	harsh
		name = "harsh incandescent light fixture"
		light_type = /obj/item/light/bulb/harsh
		very
			name = "very harsh incandescent light fixture"
			light_type = /obj/item/light/bulb/harsh/very

	broken
		name = "shattered floor light"
		icon_state = "floor-broken"

		New()
			..()
			current_lamp.light_status = LIGHT_BROKEN

/obj/machinery/light/small/floor/uninstall_fixture()
	var/obj/item/light_parts/floor/parts = new /obj/item/light_parts/floor(get_turf(src))
	parts.copy_light(src)
	qdel(src)

/obj/machinery/light/emergency
	icon_state = "ebulb1"
	base_state = "ebulb"
	fitting = "bulb"
	brightness = 1
	desc = "A small light used to illuminate in emergencies."
	light_type = /obj/item/light/bulb/emergency
	allowed_type = /obj/item/light/bulb/emergency
	on = 0
	removable_bulb = 1

	New()
		..()
		var/turf/T = get_turf(src)
		if (T.z == Z_LEVEL_STATION && istype(T.loc, /area/station))
			START_TRACKING_CAT(TR_CAT_STATION_EMERGENCY_LIGHTS)

	disposing()
		..()
		STOP_TRACKING_CAT(TR_CAT_STATION_EMERGENCY_LIGHTS)

	exitsign
		name = "illuminated exit sign"
		desc = "This sign points the way to the escape shuttle."
		brightness = 1.3

/obj/machinery/light/emergencyflashing
	icon_state = "ebulb1"
	base_state = "ebulb"
	fitting = "bulb"
	name = "warning light"
	brightness = 1.3
	desc = "This foreboding light warns of danger."
	light_type = /obj/item/light/bulb/emergency
	allowed_type = /obj/item/light/bulb/emergency
	on = 1
	removable_bulb = 0
	install_type = INSTALL_WALL

/obj/machinery/light/runway_light
	name = "runway light"
	desc = "A small light used to guide pods into hangars."
	icon_state = "runway10"
	base_state = "runway1"
	fitting = "floor"
	brightness = 0.5
	light_type = /obj/item/light/bulb/runway
	allowed_type = /obj/item/light/bulb/runway
	plane = PLANE_NOSHADOW_BELOW
	on = 1
	wallmounted = 0
	removable_bulb = 0
	install_type = INSTALL_FLOOR
	delay2
		icon_state = "runway20"
		base_state = "runway2"
	delay3
		icon_state = "runway30"
		base_state = "runway3"
	delay4
		icon_state = "runway40"
		base_state = "runway4"
	delay5
		icon_state = "runway50"
		base_state = "runway5"

/obj/machinery/light/runway_light/update_icon_state()
	if (!inserted_lamp)
		icon_state = "floor-empty"
		on = 0
	else
		switch(current_lamp.light_status) // set icon_states
			if(LIGHT_OK)
				icon_state = "[base_state][on]"
			if(LIGHT_BURNED)
				icon_state = "floor-burned"
				on = 0
			if(LIGHT_BROKEN)
				icon_state = "floor-broken"
				on = 0

///This type hell is already baked into a lot of maps so this macro exists to make it less insane
#define DEFINE_DELAYS(_PATH)\
_PATH/delay2{icon_state = "runway20"; base_state = "runway2"}\
_PATH/delay3{icon_state = "runway30"; base_state = "runway3"}\
_PATH/delay4{icon_state = "runway40"; base_state = "runway4"}\
_PATH/delay5{icon_state = "runway50"; base_state = "runway5"}

/obj/machinery/light/traffic_light
	name = "warning light"
	desc = "A small, hardened light used to warn when shuttle traffic is expected."
	icon_state = "runway10"
	base_state = "runway1"
	fitting = "bulb"
	brightness = 0.5
	light_type = /obj/item/light/bulb/runway/traffic
	allowed_type = /obj/item/light/bulb/runway/traffic
	plane = PLANE_NOSHADOW_BELOW
	on = 0
	wallmounted = 0
	removable_bulb = 0
	var/static/warning_color = "#da9b49"
	var/connected_dock = null
	install_type = INSTALL_FLOOR

	New()
		..()
		if(src.connected_dock)
			RegisterSignal(GLOBAL_SIGNAL, src.connected_dock, PROC_REF(dock_signal_handler))

	ex_act(severity)
		if(severity == 1)
			..()

	proc/dock_signal_handler(datum/holder, var/signal)
		switch(signal)
			if(DOCK_EVENT_INCOMING)
				src.activate()
			if(DOCK_EVENT_ARRIVED)
				src.deactivate()
			if(DOCK_EVENT_OUTGOING)
				src.activate()
			if(DOCK_EVENT_DEPARTED)
				src.deactivate()

	proc/activate()
		src.color = warning_color
		src.on = TRUE
		src.update()

	proc/deactivate()
		src.color = null
		src.on = FALSE
		src.update()

	// matching mapping area conventions
/obj/machinery/light/traffic_light/trader_left
	connected_dock = COMSIG_DOCK_TRADER_WEST
DEFINE_DELAYS(/obj/machinery/light/traffic_light/trader_left)

/obj/machinery/light/traffic_light/trader_right
	connected_dock = COMSIG_DOCK_TRADER_EAST
DEFINE_DELAYS(/obj/machinery/light/traffic_light/trader_right)

/obj/machinery/light/traffic_light/trader_diner
	connected_dock = COMSIG_DOCK_TRADER_DINER
DEFINE_DELAYS(/obj/machinery/light/traffic_light/trader_diner)

/obj/machinery/light/traffic_light/mining_station
	connected_dock = COMSIG_DOCK_MINING_STATION
DEFINE_DELAYS(/obj/machinery/light/traffic_light/mining_station)

/obj/machinery/light/traffic_light/mining_diner
	connected_dock = COMSIG_DOCK_MINING_DINER
DEFINE_DELAYS(/obj/machinery/light/traffic_light/mining_diner)

/obj/machinery/light/traffic_light/mining_outpost
	connected_dock = COMSIG_DOCK_MINING_OUTPOST
DEFINE_DELAYS(/obj/machinery/light/traffic_light/mining_outpost)

/obj/machinery/light/traffic_light/john_owlery
	connected_dock = COMSIG_DOCK_JOHN_OWLERY
DEFINE_DELAYS(/obj/machinery/light/traffic_light/john_owlery)

/obj/machinery/light/traffic_light/john_diner
	connected_dock = COMSIG_DOCK_JOHN_DINER
DEFINE_DELAYS(/obj/machinery/light/traffic_light/john_diner)

/obj/machinery/light/traffic_light/john_outpost
	connected_dock = COMSIG_DOCK_JOHN_OUTPOST
DEFINE_DELAYS(/obj/machinery/light/traffic_light/john_outpost)

/obj/machinery/light/traffic_light/research_station
	connected_dock = COMSIG_DOCK_RESEARCH_STATION
DEFINE_DELAYS(/obj/machinery/light/traffic_light/research_station)

/obj/machinery/light/traffic_light/research_outpost
	connected_dock = COMSIG_DOCK_RESEARCH_OUTPOST
DEFINE_DELAYS(/obj/machinery/light/traffic_light/research_outpost)

/obj/machinery/light/traffic_light/medical_asylum
	connected_dock = COMSIG_DOCK_MEDICAL_ASYLUM
DEFINE_DELAYS(/obj/machinery/light/traffic_light/medical_asylum)

/obj/machinery/light/traffic_light/medical_medbay
	connected_dock = COMSIG_DOCK_MEDICAL_MEDBAY
DEFINE_DELAYS(/obj/machinery/light/traffic_light/medical_medbay)

/obj/machinery/light/traffic_light/medical_pathology
	connected_dock = COMSIG_DOCK_MEDICAL_PATHOLOGY
DEFINE_DELAYS(/obj/machinery/light/traffic_light/medical_pathology)

#undef DEFINE_DELAYS

// Traffic lights on/off is signal controlled; light switches should not affect us.
/obj/machinery/light/traffic_light/power_change()
	if(src.loc)
		var/area/A = get_area(src)
		var/state = src.on && A.power_light
		seton(state)

/obj/machinery/light/traffic_light/update_icon_state()
	if (!inserted_lamp)
		icon_state = "floor-empty"
		on = 0
	else
		switch(current_lamp.light_status) // set icon_states
			if(LIGHT_OK)
				icon_state = "[base_state][on]"
			if(LIGHT_BURNED)
				icon_state = "floor-burned"
				on = 0
			if(LIGHT_BROKEN)
				icon_state = "floor-broken"
				on = 0


/obj/machinery/light/beacon
	name = "tripod light"
	desc = "A large portable light tripod."
	density = 1
	anchored = ANCHORED
	icon_state = "tripod1"
	base_state = "tripod"
	fitting = "bulb"
	wallmounted = 0
	brightness = 1.5
	light_type = /obj/item/light/big_bulb
	allowed_type = /obj/item/light/big_bulb
	power_usage = 0
	install_type = INSTALL_FLOOR

	attackby(obj/item/W, mob/user)

		if (issilicon(user))
			return

		if (iswrenchingtool(W))

			add_fingerprint(user)
			src.anchored = !src.anchored

			if (!src.anchored)
				boutput(user, SPAN_ALERT("[src] can now be moved."))
				src.on = 0
			else
				boutput(user, SPAN_ALERT("[src] is now secured."))
				src.on = 1

			update()

		else
			return ..()

	has_power()
		return src.anchored

//Older lighting that doesn't power up so well anymore.
/obj/machinery/light/worn
	desc = "A rather old-looking lighting fixture."
	brightness = 1
	New()
		..()
		current_lamp.breakprob = WORN_LIGHT_BREAKPROB

// the desk lamp
/obj/machinery/light/lamp
	name = "desk lamp"
	brightness = 1
	wallmounted = FALSE
	fitting = "bulb"
	desc = "A desk lamp. For lighting desks."
	light_type = /obj/item/light/bulb
	allowed_type = /obj/item/light/bulb
	deconstruct_flags = DECON_SIMPLE
	layer = ABOVE_OBJ_LAYER
	plane = PLANE_DEFAULT
	var/switchon = FALSE		// independent switching for lamps - not controlled by area lightswitch
	install_type = INSTALL_FLOOR

// if attack with hand, only "grab" attacks are an attempt to remove bulb
// otherwise, switch the lamp on/off

/obj/machinery/light/lamp/attack_hand(mob/user)

	if(user.a_intent == INTENT_GRAB)
		..()	// do standard hand attack
	else
		switchon = !switchon
		boutput(user, "You switch [switchon ? "on" : "off"] the [name].")
		seton(switchon && powered(LIGHT))

// called when area power state changes
// override since lamp does not use area lightswitch

/obj/machinery/light/lamp/power_change()
	var/area/A = get_area(src)
	seton(switchon && A.power_light)

// returns whether this lamp has power
// true if area has power and lamp switch is on

/obj/machinery/light/lamp/has_power()
	var/area/A = get_area(src)
	return switchon && A.power_light

/obj/machinery/light/lamp/black
	icon_state = "lamp1"
	base_state = "lamp"

	New()
		..()
		src.AddOverlays(image('icons/obj/lighting.dmi', "lamp-base", layer = 2.99), "lamp base") // Just needs to be under the head of the lamp

	bright
		brightness = 1.8
		switchon = TRUE

// green-shaded desk lamp
/obj/machinery/light/lamp/green
	icon_state = "green1"
	base_state = "green"
	desc = "A green-shaded desk lamp."

	New()
		..()
		light.set_color(0.45, 0.85, 0.25)

//special lights w very specific colors. made for sealab!
/obj/machinery/light/incandescent
	light_type = /obj/item/light/tube
	allowed_type = /obj/item/light/tube
	nostick = 0

	New()
		..()
		autoposition()

	name = "incandescent light fixture"
	light_type = /obj/item/light/tube/neutral

	netural
		name = "incandescent light fixture"
		light_type = /obj/item/light/tube/neutral
	greenish
		name = "greenish incandescent light fixture"
		light_type = /obj/item/light/tube/greenish
	blueish
		name = "blueish fluorescent light fixture"
		light_type = /obj/item/light/tube/blueish
	purpleish
		name = "purpleish fluorescent light fixture"
		light_type = /obj/item/light/tube/purpleish

	warm
		name = "fluorescent light fixture"
		light_type = /obj/item/light/tube/warm
		very
			name = "warm fluorescent light fixture"
			light_type = /obj/item/light/tube/warm/very

	cool
		name = "cool incandescent light fixture"
		light_type = /obj/item/light/tube/cool
		very
			name = "very cool incandescent light fixture"
			light_type = /obj/item/light/tube/cool/very

	harsh
		name = "harsh incandescent light fixture"
		light_type = /obj/item/light/tube/harsh
		very
			name = "very harsh incandescent light fixture"
			light_type = /obj/item/light/tube/harsh/very

	broken
		name = "shattered light fixture"
		icon_state = "tube-broken"

		New()
			..()
			current_lamp.light_status = LIGHT_BROKEN

	small
		icon_state = "bulb1"
		base_state = "bulb"
		fitting = "bulb"
		brightness = 1.2
		desc = "A small lighting fixture."
		light_type = /obj/item/light/bulb


// create a new lighting fixture
/obj/machinery/light/New()
	..()
	light = new
	light.set_brightness(brightness)
	light.set_color(initial(src.light_type.color_r), initial(src.light_type.color_g), initial(src.light_type.color_b))
	light.set_height(2.4)
	light.attach(src)
	if (is_valid_icon_state("[src.base_state]-overlay", src.icon))
		light_overlay = new()
		light_overlay.mouse_opacity = 0
		light_overlay.icon = src.icon
		light_overlay.icon_state = "[src.base_state]-overlay"
		light_overlay.vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
	SPAWN(1 DECI SECOND)
		update()

// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light/proc/update()
	src.update_icon_state()

	if (on)
		light.enable()
	else
		light.disable()

	SPAWN(0)
		// now check to see if the bulb is burned out
		switch(current_lamp.light_status)
			if(LIGHT_OK)
				if(!on)
					return
				if(current_lamp.rigged)
					if (current_lamp.rigger)
						message_admins("[key_name(current_lamp.rigger)]'s rigged bulb exploded in [src.loc.loc], [log_loc(src)].")
						logTheThing(LOG_COMBAT, current_lamp.rigger, "'s rigged bulb exploded in [current_lamp.rigger.loc.loc] ([log_loc(src)])")
					explode()
				#ifndef STOP_BREAKING_THE_FUCKING_LIGHTS_I_WANT_TO_SEE_SHIT
				if(prob(current_lamp.breakprob))
					src.do_break()
				if(prob(current_lamp.burnprob))
					src.do_burn_out()
				#endif
			if (LIGHT_BURNED)
				if(prob(current_lamp.breakprob))
					src.do_break()

/obj/machinery/light/proc/update_icon_state()
	if (!inserted_lamp)
		icon_state = "[base_state]-empty"
		on = 0
	else
		switch(current_lamp.light_status) // set icon_states
			if(LIGHT_OK)
				icon_state = "[base_state][on]"
			if(LIGHT_BURNED)
				icon_state = "[base_state]-burned"
				on = 0
			if(LIGHT_BROKEN)
				icon_state = "[base_state]-broken"
				on = 0
	if (!on)
		vis_contents -= light_overlay
		return
	if (!(light_overlay in vis_contents))
		vis_contents += light_overlay

/obj/machinery/light/proc/do_break()
	current_lamp.light_status = LIGHT_BROKEN
	current_lamp.update()
	on = 0
	light.disable()
	src.update_icon_state()
	elecflash(src, radius = 1, power = 2, exclude_center = 0)
	logTheThing(LOG_STATION, null, "Light '[name]' broke itself (breakprob: [current_lamp.breakprob]) at ([log_loc(src)])")

/obj/machinery/light/clamp_act(mob/clamper, obj/item/clamp)
	if (current_lamp.light_status != LIGHT_BROKEN || current_lamp.light_status != LIGHT_EMPTY)
		src.do_break()
		return TRUE

/obj/machinery/light/proc/do_burn_out()
	var/original_brightness = src.light.brightness
	playsound(src, 'sound/effects/snaptape.ogg', 30, TRUE)
	src.light.set_brightness(original_brightness * 3)
	logTheThing(LOG_STATION, null, "Light '[name]' burned out (burnprob: [current_lamp.burnprob]) at ([log_loc(src)])")
	SPAWN(0.2 SECONDS)
		src.light.set_brightness(original_brightness)
		src.current_lamp.breakprob = WORN_LIGHT_BREAKPROB
		src.current_lamp.light_status = LIGHT_BURNED
		src.current_lamp.update()
		src.update_icon_state()
		playsound(src, 'sound/effects/sparks4.ogg', 40, TRUE)
		src.on = FALSE
		src.light.disable()

// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/proc/seton(var/s)
	var/old_on = on
	on = (s && current_lamp.light_status == LIGHT_OK)
	if(s != old_on) //don't update if trying to set to the same state
		update()

// examine verb
/obj/machinery/light/examine(mob/user)
	. = ..()

	if(!user || user.stat)
		return

	if (!inserted_lamp)
		. += "The [fitting] has been removed."
		return
	switch(current_lamp.light_status)
		if(LIGHT_OK)
			. += "It is turned [on? "on" : "off"]."
		if(LIGHT_BURNED)
			. += "The [fitting] is burnt out."
		if(LIGHT_BROKEN)
			. += "The [fitting] has been smashed."

/obj/machinery/light/proc/replace(mob/user, var/obj/item/light/newlamp = null) // if there's no newlamp this will just take out the old one.
	if (!user)
		return
	var/obj/item/light/oldlamp = inserted_lamp
	inserted_lamp = null

	if (newlamp)
		user.u_equip(newlamp)
		insert(user, newlamp)
	else
		update()
	user.put_in_hand_or_drop(oldlamp) // This just returns if there's no oldlamp, don't worry

/obj/machinery/light/proc/insert(mob/user, var/obj/item/light/newlamp) // Overriding the inserted lamp entirely
	if (!newlamp)
		return
	if (inserted_lamp)
		qdel(inserted_lamp)
	boutput(user, "You insert a [newlamp.name].")
	inserted_lamp = newlamp
	current_lamp = inserted_lamp
	current_lamp.set_loc(null)
	light.set_color(current_lamp.color_r, current_lamp.color_g, current_lamp.color_b)
	brightness = initial(brightness)
	on = has_power()
	update()

// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light/attackby(obj/item/W, mob/user)

	if (istype(W, /obj/item/lamp_manufacturer)) //deliberately placed above the borg check
		var/obj/item/lamp_manufacturer/M = W
		if (M.removing_toggled)
			return //This stuff gets handled in the manufacturer's after_attack
		if (removable_bulb == 0)
			boutput(user, "This fitting isn't user-serviceable.")
			return

		var/lamp_cost = null
		if (!inserted_lamp) //Taking charge/sheets
			if (!M.check_ammo(user, M.cost_empty))
				return
			lamp_cost = M.cost_empty
		else
			if (!M.check_ammo(user, M.cost_broken))
				return
			lamp_cost = M.cost_broken
		var/obj/item/light/L = null

		if (fitting == "tube")
			L = new M.dispensing_tube()
		else
			L = new M.dispensing_bulb()
		if(inserted_lamp)
			if (current_lamp.light_status == LIGHT_OK && current_lamp.name == L.name && brightness == initial(brightness) && current_lamp.color_r == L.color_r && current_lamp.color_g == L.color_g && current_lamp.color_b == L.color_b && on == has_power())
				boutput(user, "This fitting already has an identical lamp.")
				qdel(L)
				return // Stop borgs from making more sparks than necessary.

		insert(user, L)
		if (!isghostdrone(user)) // Same as ghostdrone RCDs, no sparks
			elecflash(user)
		M.take_ammo(user, lamp_cost)
		return


	if (issilicon(user) && !isghostdrone(user))
		return
		/*if (isghostdrone(user))
			return src.Attackhand(user)
		else
			return*/


	// see if there's a magtractor involved and if so save it for later as mag
	var/obj/item/magtractor/mag
	if (istype(W, /obj/item/magtractor))
		mag = W
		if (!mag.holding)
			return src.Attackhand(user)
		else
			W = mag.holding

	// attempt to insert light
	if(istype(W, /obj/item/light))
		if(istype(W, allowed_type))
			replace(user, W)
		else
			boutput(user, "This type of light requires a [fitting].")
			return


	// attempt to stick weapon into light socket
	else if(!inserted_lamp)
		if (isscrewingtool(W))
			if (has_power())
				boutput(user, "That's not safe with the power on!")
				return
			if (candismantle)
				boutput(user, "You begin to loosen the fixture's screws...")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				SETUP_GENERIC_ACTIONBAR(user, src, LIGHT_FIXTURE_DETACH_TIME, PROC_REF(uninstall_fixture),list(), src.icon, src.icon_state,\
				 "[user] finishes uninstalling \the [src].", INTERRUPT_MOVE|INTERRUPT_ACT|INTERRUPT_ATTACKED|INTERRUPT_STUNNED|INTERRUPT_ACTION)
				return
			else
				boutput(user, "You can't seem to dismantle it.")


		boutput(user, "You stick \the [W.name] into the light socket!")
		user.lastattacked = get_weakref(src)
		if(has_power() && (W.flags & CONDUCT))
			if(!user.bioHolder.HasEffect("resist_electric"))
				src.electrocute(user, 75, null, 20000)
				elecflash(src,radius = 1, power = 2, exclude_center = 1)

	// attempt to break the light
	else if(current_lamp.light_status != LIGHT_BROKEN)
		user.lastattacked = get_weakref(src)
		if(prob(1+W.force * 5))

			boutput(user, "You hit the light, and it smashes!")
			logTheThing(LOG_STATION, user, "smashes a light at [log_loc(src)]")

			var/datum/gang/gang = user.get_gang()
			gang?.do_vandalism(GANG_VANDALISM_LIGHT_BREAK_POINTS, src.loc)

			for(var/mob/M in AIviewers(src))
				if(M == user)
					continue
				M.show_message("[user.name] smashed the light!", 3, "You hear a tinkle of breaking glass", 2)
			if(on && (W.flags & CONDUCT))
				if(!user.bioHolder.HasEffect("resist_electric"))
					src.electrocute(user, 50, null, 20000)
			broken()


		else
			boutput(user, "You hit the light!")

/obj/machinery/light/proc/uninstall_fixture()
	var/obj/item/light_parts/parts = new /obj/item/light_parts(get_turf(src))
	parts.copy_light(src)
	qdel(src)

// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light/proc/has_power()
	var/pow_stat = powered(LIGHT)
	if (pow_stat && wire_powered)
		return 1
	var/area/A = get_area(src)
	return A ? A.lightswitch && A.power_light : 0

// ai attack - do nothing

/obj/machinery/light/attack_ai(mob/user)
	return


// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player

/obj/machinery/light/attack_hand(mob/user)

	add_fingerprint(user)

	if (isghostdrone(user))
		var/obj/item/magtractor/mag = user.equipped()
		if (!istype(mag) || mag.holding) // they aren't holding a magtractor or the magtractor already has something in it
			return // so there's no room for a bulb

	interact_particle(user,src)

	if(current_lamp.light_status == LIGHT_EMPTY)
		boutput(user, "There is no [fitting] in this light.")
		return

	// hey don't run around and steal all the emergency bolts you jerk
	if(!removable_bulb)
		boutput(user, "The bulb is firmly locked into place and cannot be removed.")
		return

	// make it burn hands if not wearing fire-insulated gloves
	if(on)
		var/prot = 0
		var/mob/living/carbon/human/H = user

		if(istype(H))

			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves

				prot = (G.getProperty("heatprot") >= 7)	// *** TODO: better handling of glove heat protection
		else
			prot = 1

		if (!in_interact_range(src, user))
			return
		if (prot > 0 || user.is_heat_resistant())
			boutput(user, "You remove the light [fitting].")
		else
			if(ON_COOLDOWN(src, "burn_hands", 1 SECOND))
				return
			boutput(user, "You try to remove the light [fitting], but you burn your hand on it!")
			H.UpdateDamageIcon()
			H.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 0, 5)
			return				// if burned, don't remove the light

	// create a light tube/bulb item and put it in the user's hand
	replace(user)

// break the light and make sparks if was on

/obj/machinery/light/proc/broken(var/nospark = 0, explode_rigged = FALSE)
	set name = "Break"

	if(current_lamp.light_status == LIGHT_EMPTY || current_lamp.light_status == LIGHT_BROKEN)
		return

	if(current_lamp.light_status == LIGHT_OK || current_lamp.light_status == LIGHT_BURNED)
		playsound(src.loc, 'sound/impact_sounds/Glass_Hit_1.ogg', 75, 1)

	if(!nospark)
		if(on)
			logTheThing(LOG_STATION, null, "Light '[name]' was on and has been broken, spewing sparks everywhere ([log_loc(src)])")
			elecflash(src,radius = 1, power = 2, exclude_center = 0)

	if(explode_rigged && current_lamp.rigged)
		if (current_lamp.rigger)
			message_admins("[key_name(current_lamp.rigger)]'s rigged bulb exploded in [src.loc.loc], [log_loc(src)].")
			logTheThing(LOG_COMBAT, current_lamp.rigger, "'s rigged bulb exploded in [current_lamp.rigger.loc.loc] ([log_loc(src)])")
		explode()
		return

	current_lamp.light_status = LIGHT_BROKEN
	current_lamp.update()
	SPAWN(0)
		update()

// explosion effect
// destroy the whole light fixture or just shatter it

/obj/machinery/light/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if (prob(75))
				broken()
		if(3)
			if (prob(50))
				broken()
	return

//blob effect

/obj/machinery/light/blob_act(var/power)
	if(prob(power * 2.5))
		broken()

/obj/machinery/light/proc/admin_toggle()
	set name = "Toggle"
	on = (!on && current_lamp.light_status == LIGHT_OK)
	update()

/obj/machinery/light/proc/admin_fix()
	set name = "Fix"
	if(isnull(current_lamp))
		current_lamp = new light_type
	current_lamp.light_status = LIGHT_OK
	current_lamp.update()
	on = TRUE
	update()

//mbc : i threw away this stuff in favor of a faster machine loop process
/*
/obj/machinery/light/process()
	if(on)
		..()
		var/thepower = src.brightness * LIGHTING_POWER_FACTOR
		use_power(thepower, LIGHT)
		if(rigged)
			if(prob(1))
				if (rigger)
					message_admins("[key_name(rigger)]'s rigged bulb exploded in [src.loc.loc], [log_loc(src)].")
					logTheThing(LOG_COMBAT, rigger, "'s rigged bulb exploded in [rigger.loc.loc] ([log_loc(src)])")
				explode()
				rigged = 0
				rigger = null
			else if(prob(2))
				if (rigger)
					message_admins("[key_name(rigger)]'s rigged bulb tried to explode but failed in [src.loc.loc], [log_loc(src)].")
					logTheThing(LOG_COMBAT, rigger, "'s rigged bulb tried to explode but failed in [rigger.loc.loc] ([log_loc(src)])")
				rigged = 0
				rigger = null
*/

// called when area power state changes

/obj/machinery/light/power_change()
	if(src.loc) //TODO fix the dispose proc for this so that when it is sent into the delete queue it doesn't try and exec this
		var/area/A = get_area(src)
		var/state = A.lightswitch && A.power_light
		//if (shipAlertState == SHIP_ALERT_BAD) state = 0
		seton(state)

// called when on fire

/obj/machinery/light/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume, cannot_be_cooled = FALSE)
	if(reagents) reagents.temperature_reagents(exposed_temperature, exposed_volume)
	if(prob(max(0, exposed_temperature - 1650)))   //0% at <400C, 100% at >500C   // previous value for subtraction was -673. tons of lights exploded Azungar edit: Nudged this up a bit just in case.
		broken()

// explode the light

/obj/machinery/light/proc/explode()
	var/turf/T = get_turf(src.loc)
	SPAWN(0)
		broken()	// break it first to give a warning
		sleep(0.2 SECONDS)
		explosion(src, T, 0, 1, 2, 2)
		sleep(0.1 SECONDS)
		qdel(src)


// special handling for emergency lights
// called when area power state changes
// override since emergency lights do not use area lightswitch

/obj/machinery/light/emergency/power_change()
	var/area/A = get_area(src)
	if (A)
		var/state = !A.power_light || shipAlertState == SHIP_ALERT_BAD
		seton(state)

/obj/machinery/light/emergency/insert()
	..()
	power_change()

// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light of the corresponding type

TYPEINFO(/obj/item/light)
	mats = 1

/obj/item/light
	icon = 'icons/obj/lighting.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	force = 2
	throwforce = 5
	w_class = W_CLASS_SMALL
	m_amt = 60
	var/light_status = LIGHT_OK		// LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/base_state
	var/breakprob = 0 //! Chance for the bulb to burst
	var/burnprob = 1 //! Chance for the bulb to burn out
	var/rigged = 0		// true if rigged to explode
	var/mob/rigger = null // mob responsible
	var/color_r = 1
	var/color_g = 1
	var/color_b = 1
	var/canberigged = 1

/obj/item/light/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "tube-white"
	base_state = "tube-white"
	item_state = "c_tube"
	g_amt = 200
	color_r = 0.95
	color_g = 0.95
	color_b = 1

	red
		name = "red light tube"
		desc = "Fancy."
		icon_state = "tube-red"
		base_state = "tube-red"
		color_r = 0.95
		color_g = 0.2
		color_b = 0.2
	reddish
		name = "reddish light tube"
		desc = "Fancy."
		icon_state = "tube-red"
		base_state = "tube-red"
		color_r = 0.98
		color_g = 0.75
		color_b = 0.5
	yellow
		name = "yellow light tube"
		desc = "Fancy."
		icon_state = "tube-yellow"
		base_state = "tube-yellow"
		color_r = 0.95
		color_g = 0.95
		color_b = 0.2
	yellowish
		name = "yellowish light tube"
		desc = "Fancy."
		icon_state = "tube-yellow"
		base_state = "tube-yellow"
		color_r = 0.98
		color_g = 0.98
		color_b = 0.75
	green
		name = "green light tube"
		desc = "Fancy."
		icon_state = "tube-green"
		base_state = "tube-green"
		color_r = 0.2
		color_g = 0.95
		color_b = 0.2
	cyan
		name = "cyan light tube"
		desc = "Fancy."
		icon_state = "tube-cyan"
		base_state = "tube-cyan"
		color_r = 0.2
		color_g = 0.95
		color_b = 0.95
	blue
		name = "blue light tube"
		desc = "Fancy."
		icon_state = "tube-blue"
		base_state = "tube-blue"
		color_r = 0.2
		color_g = 0.2
		color_b = 0.95
	purple
		name = "purple light tube"
		desc = "Fancy."
		icon_state = "tube-purple"
		base_state = "tube-purple"
		color_r = 0.95
		color_g = 0.2
		color_b = 0.95
	light_purpleish
		name = "light purpleish light tube"
		desc = "Fancy."
		icon_state = "tube-purple"
		base_state = "tube-purple"
		color_r = 0.98
		color_g = 0.76
		color_b = 0.98
	blacklight
		name = "black light tube"
		desc = "Fancy."
		icon_state = "tube-uv"
		base_state = "tube-uv"
		color_r = 0.3
		color_g = 0
		color_b = 0.9

	warm
		name = "fluorescent light tube"
		icon_state = "itube-orange"
		base_state = "itube-orange"
		color_r = 1
		color_g = 0.844
		color_b = 0.81

		very
			name = "warm fluorescent light tube"
			icon_state = "itube-red"
			base_state = "itube-red"
			color_r = 1
			color_g = 0.67
			color_b = 0.67

	neutral
		name = "incandescent light tube"
		icon_state = "itube-white"
		base_state = "itube-white"
		color_r = 0.95
		color_g = 0.98
		color_b = 0.97

	greenish
		name = "greenish incandescent light tube"
		icon_state = "itube-yellow"
		base_state = "itube-yellow"
		color_r = 0.87
		color_g = 0.98
		color_b = 0.89

	blueish
		name = "blueish fluorescent light tube"
		icon_state = "itube-blue"
		base_state = "itube-blue"
		color_r = 0.51
		color_g = 0.66
		color_b = 0.85

	purpleish
		name = "purpleish fluorescent light tube"
		icon_state = "itube-purple"
		base_state = "itube-purple"
		color_r = 0.42
		color_g = 0.2
		color_b = 0.58

	cool
		name = "cool incandescent light tube"
		icon_state = "itube-white"
		base_state = "itube-white"
		color_r = 0.88
		color_g = 0.904
		color_b = 1

		very
			name = "very cool incandescent light tube"
			icon_state = "itube-purple"
			base_state = "itube-purple"
			color_r = 0.74
			color_g = 0.74
			color_b = 1

	harsh
		name = "harsh incandescent light tube"
		icon_state = "itube-white"
		base_state = "itube-white"
		color_r = 0.99
		color_g = 0.899
		color_b = 0.99

		very
			name = "very harsh incandescent light tube"
			icon_state = "itube-pink"
			base_state = "itube-pink"
			color_r = 0.99
			color_g = 0.81
			color_b = 0.99

// the smaller bulb light fixture

/obj/item/light/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "bulb-yellow"
	base_state = "bulb-yellow"
	item_state = "contvapour"
	g_amt = 100
	color_r = 1
	color_g = 1
	color_b = 0.9

	red
		name = "red light bulb"
		desc = "Fancy."
		icon_state = "bulb-red"
		base_state = "bulb-red"
		color_r = 0.95
		color_g = 0.2
		color_b = 0.2
	reddish //apparently y'all didn't have reddish bulbs?
		name = "reddish light bulb"
		desc = "Fancy."
		icon_state = "bulb-red"
		base_state = "bulb-red"
		color_r = 0.98
		color_g = 0.75
		color_b = 0.5
	yellow
		name = "yellow light bulb"
		desc = "Fancy."
		icon_state = "bulb-yellow"
		base_state = "bulb-yellow"
		color_r = 0.95
		color_g = 0.95
		color_b = 0.2

		broken
			light_status = LIGHT_BROKEN
	yellowish
		name = "yellowish light bulb"
		desc = "Fancy."
		icon_state = "bulb-yellow"
		base_state = "bulb-yellow"
		color_r = 0.98
		color_g = 0.98
		color_b = 0.75
	green
		name = "green light bulb"
		desc = "Fancy."
		icon_state = "bulb-green"
		base_state = "bulb-green"
		color_r = 0.2
		color_g = 0.95
		color_b = 0.2
	cyan
		name = "cyan light bulb"
		desc = "Fancy."
		icon_state = "bulb-cyan"
		base_state = "bulb-cyan"
		color_r = 0.2
		color_g = 0.95
		color_b = 0.95
	blue
		name = "blue light bulb"
		desc = "Fancy."
		icon_state = "bulb-blue"
		base_state = "bulb-blue"
		color_r = 0.2
		color_g = 0.2
		color_b = 0.95
	purple
		name = "purple light bulb"
		desc = "Fancy."
		icon_state = "bulb-purple"
		base_state = "bulb-purple"
		color_r = 0.95
		color_g = 0.2
		color_b = 0.95
	blacklight
		name = "black light bulb"
		desc = "Fancy."
		icon_state = "bulb-uv"
		base_state = "bulb-uv"
		color_r = 0.3
		color_g = 0
		color_r = 0.9
	emergency
		name = "emergency light bulb"
		desc = "A frosted red bulb."
		icon_state = "bulb-emergency"
		base_state = "bulb-emergency"
		burnprob = 0
		color_r = 1
		color_g = 0.2
		color_b = 0.2

	warm
		name = "fluorescent light bulb"
		icon_state = "ibulb-yellow"
		base_state = "ibulb-yellow"
		color_r = 1
		color_g = 0.844
		color_b = 0.81

		very
			name = "warm fluorescent light bulb"
			icon_state = "ibulb-yellow"
			base_state = "ibulb-yellow"
			color_r = 1
			color_g = 0.67
			color_b = 0.67

	neutral
		name = "incandescent light bulb"
		icon_state = "ibulb-white"
		base_state = "ibulb-white"
		color_r = 0.95
		color_g = 0.98
		color_b = 0.97

	greenish
		name = "greenish incandescent light bulb"
		icon_state = "ibulb-green"
		base_state = "ibulb-green"
		color_r = 0.87
		color_g = 0.98
		color_b = 0.89

	blueish
		name = "blueish fluorescent light bulb"
		icon_state = "ibulb-blue"
		base_state = "ibulb-blue"
		color_r = 0.51
		color_g = 0.66
		color_b = 0.85

	purpleish
		name = "purpleish fluorescent light bulb"
		icon_state = "ibulb-purple"
		base_state = "ibulb-purple"
		color_r = 0.42
		color_g = 0.2
		color_b = 0.58

	cool
		name = "cool incandescent light bulb"
		icon_state = "ibulb-white"
		base_state = "ibulb-white"
		color_r = 0.88
		color_g = 0.904
		color_b = 1

		very
			name = "very cool incandescent light bulb"
			icon_state = "ibulb-blue"
			base_state = "ibulb-blue"
			color_r = 0.74
			color_g = 0.74
			color_b = 1

	harsh
		name = "harsh incandescent light bulb"
		icon_state = "ibulb-pink"
		base_state = "ibulb-pink"
		color_r = 0.99
		color_g = 0.899
		color_b = 0.99

		very
			name = "very harsh incandescent light bulb"
			icon_state = "ibulb-pink"
			base_state = "ibulb-pink"
			color_r = 0.99
			color_g = 0.81
			color_b = 0.99

	runway
		burnprob = 0

		traffic
			color_r = 1
			color_g = 0.67
			color_b = 0.67


/obj/item/light/big_bulb
	name = "beacon bulb"
	desc = "An immense replacement light bulb."
	icon_state = "tbulb"
	base_state = "tbulb"
	item_state = "contvapour"
	g_amt = 250
	color_r = 1
	color_g = 1
	color_b = 1

// update the icon state and description of the light
/obj/item/light
	proc/update()
		switch(light_status)
			if(LIGHT_OK)
				icon_state = base_state
				desc = "A replacement [name]."
			if(LIGHT_BURNED)
				icon_state = "[base_state]-burned"
				desc = "A burnt-out [name]."
			if(LIGHT_BROKEN)
				icon_state = "[base_state]-broken"
				desc = "A broken [name]."


/obj/item/light/New()
	..()
	update()


// attack bulb/tube with object
// if a syringe, can inject plasma to make it explode
/obj/item/light/attackby(var/obj/item/I, var/mob/user)
	if (!canberigged)
		return
	if(istype(I, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/S = I

		boutput(user, "You inject the solution into the [src].")

		if(S.reagents.has_reagent("plasma", 1))
			logTheThing(LOG_COMBAT, user, "rigged [src] to explode in [user.loc.loc] ([log_loc(user)])")
			rigged = 1
			rigger = user

		S.reagents.clear_reagents()
	else
		..()
	return

// called after an attack with a light item
// shatter light, unless it was an attempt to put it in a light socket
// now only shatter if the intent was harm

/obj/item/light/afterattack(atom/target, mob/user)
	if(istype(target, /obj/machinery/light))
		return
	if(user.a_intent != "harm")
		return

	if(light_status == LIGHT_OK || light_status == LIGHT_BURNED)
		boutput(user, "The [name] shatters!")
		light_status = LIGHT_BROKEN
		force = 5
		playsound(src.loc, 'sound/impact_sounds/Glass_Hit_1.ogg', 75, 1)
		update()

/obj/machinery/light/get_power_wire()
	if (wallmounted)
		var/obj/cable/C = null
		for (var/obj/cable/candidate in get_turf(src))
			if (candidate.d1 == dir || candidate.d2 == dir)
				C = candidate
				break
		return C
	else
		return ..()

#undef WORN_LIGHT_BREAKPROB
#undef LIGHT_FIXTURE_ATTACH_TIME
#undef LIGHT_FIXTURE_DETACH_TIME

#undef INSTALL_WALL
#undef INSTALL_FLOOR
