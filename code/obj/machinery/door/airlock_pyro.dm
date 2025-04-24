// ------------ pyro airlocks ------------

/obj/machinery/door/airlock/pyro
	name = "airlock"
	icon = 'icons/obj/doors/SL_doors.dmi'
	flags = IS_PERSPECTIVE_FLUID | FLUID_DENSE
	req_access = null

/obj/machinery/door/airlock/pyro/safe
	can_shock = FALSE

/obj/machinery/door/airlock/pyro/alt
	icon_state = "generic2_closed"
	icon_base = "generic2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"

/obj/machinery/door/airlock/pyro/classic
	name = "old airlock"
	icon_state = "old_closed"
	icon_base = "old"
	panel_icon_state = "old_panel_open"
	welded_icon_state = "old_welded"
	sound_airlock = 'sound/machines/airlock.ogg'
	operation_time = 10

// -------- command

/obj/machinery/door/airlock/pyro/command
	name = "command airlock"
	icon_state = "com_closed"
	icon_base = "com"
	health = 800
	health_max = 800

TYPEINFO(/obj/machinery/door/airlock/pyro/command/centcom)
	mats = 0

/obj/machinery/door/airlock/pyro/command/centcom
	req_access = list(access_centcom)
	cant_emag = TRUE
	cyborgBumpAccess = FALSE
	hardened = TRUE
	aiControlDisabled = TRUE
	object_flags = BOTS_DIRBLOCK

/obj/machinery/door/airlock/pyro/command/alt
	icon_state = "com2_closed"
	icon_base = "com2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"

TYPEINFO(/obj/machinery/door/airlock/pyro/command/syndicate)
	mats = 0

/obj/machinery/door/airlock/pyro/command/syndicate
	req_access = list(access_syndicate_commander)

// -------- security

/obj/machinery/door/airlock/pyro/weapons
	icon_state = "manta_closed"
	icon_base = "manta"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	hardened = TRUE
	aiControlDisabled = TRUE
	cyborgBumpAccess = FALSE

/obj/machinery/door/airlock/pyro/weapons/noemag
	cant_emag = TRUE
	cyborgBumpAccess = FALSE

/obj/machinery/door/airlock/pyro/weapons/secure
	name = "secure weapons airlock"
	icon_state = "secure_closed"
	icon_base = "secure"
	hardened = FALSE
	cant_hack = TRUE
	aiControlDisabled = FALSE
	health = 800
	health_max = 800

/obj/machinery/door/airlock/pyro/security
	name = "security airlock"
	icon_state = "sec_closed"
	icon_base = "sec"

/obj/machinery/door/airlock/pyro/security/alt
	icon_state = "sec2_closed"
	icon_base = "sec2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"

// -------- engineering

/obj/machinery/door/airlock/pyro/engineering
	name = "engineering airlock"
	icon_state = "eng_closed"
	icon_base = "eng"

/obj/machinery/door/airlock/pyro/engineering/alt
	icon_state = "eng2_closed"
	icon_base = "eng2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"

/obj/machinery/door/airlock/pyro/mining
	name = "mining airlock"
	icon_state = "mining_closed"
	icon_base = "mining"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"

// -------- medsci

/obj/machinery/door/airlock/pyro/medical
	name = "medical airlock"
	icon_state = "research_closed"
	icon_base = "research"

/obj/machinery/door/airlock/pyro/medical/alt
	icon_state = "research2_closed"
	icon_base = "research2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"

/obj/machinery/door/airlock/pyro/medical/alt2
	icon_state = "med_closed"
	icon_base = "med"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"

/obj/machinery/door/airlock/pyro/medical/morgue
	icon_state = "morgue_closed"
	icon_base = "morgue"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"

/obj/machinery/door/airlock/pyro/sci_alt
	name = "research airlock"
	icon_state = "sci_closed"
	icon_base = "sci"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"

/obj/machinery/door/airlock/pyro/toxins_alt
	name = "toxins airlock"
	icon_state = "toxins2_closed"
	icon_base = "toxins2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"

// -------- maintenance

/obj/machinery/door/airlock/pyro/maintenance
	name = "maintenance airlock"
	icon_state = "maint_closed"
	icon_base = "maint"

/obj/machinery/door/airlock/pyro/maintenance/alt
	icon_state = "maint2_closed"
	icon_base = "maint2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"

// -------- external

/obj/machinery/door/airlock/pyro/external
	name = "external airlock"
	icon_state = "airlock_closed"
	icon_base = "airlock"
	panel_icon_state = "airlock_panel_open"
	welded_icon_state = "airlock_welded"
	sound_airlock = 'sound/machines/airlock.ogg'
	opacity = 0
	visible = 0
	operation_time = 10

TYPEINFO(/obj/machinery/door/airlock/pyro/reinforced)
	mats = 0

/obj/machinery/door/airlock/pyro/reinforced
	name = "reinforced external airlock"
	desc = "Looks pretty tough. I wouldn't take this door on in a fight."
	icon_state = "airlock_closed"
	icon_base = "airlock"
	panel_icon_state = "airlock_panel_open"
	welded_icon_state = "airlock_welded"
	sound_airlock = 'sound/machines/airlock.ogg'
	operation_time = 10
	cant_emag = TRUE
	hardened = TRUE
	aiControlDisabled = TRUE

/obj/machinery/door/airlock/pyro/reinforced/meteorhit()
	return
/obj/machinery/door/airlock/pyro/reinforced/ex_act()
	return
/obj/machinery/door/airlock/pyro/reinforced/blob_act(power)
	return

/obj/machinery/door/airlock/pyro/reinforced/syndicate
	req_access = list(access_syndicate_shuttle)
	explosion_resistance = 999999
	anchored = ANCHORED_ALWAYS //haha fuk u

	listeningpost
		req_access = list(access_impossible)

/obj/machinery/door/airlock/pyro/reinforced/arrivals
	icon_state = "arrivals_closed"
	icon_base = "arrivals"
	opacity = 0
	visible = 0

// -------- glass

/obj/machinery/door/airlock/pyro/glass
	name = "glass airlock"
	icon_state = "glass_closed"
	icon_base = "glass"
	panel_icon_state = "glass_panel_open"
	welded_icon_state = "glass_welded"
	opacity = 0
	visible = 0

TYPEINFO(/obj/machinery/door/airlock/pyro/glass/reinforced)
	mats = 0

/obj/machinery/door/airlock/pyro/glass/reinforced
	name = "reinforced glass airlock"
	desc = "Looks pretty tough. I wouldn't take this door on in a fight."
	operation_time = 10
	cant_emag = TRUE
	hardened = TRUE
	aiControlDisabled = TRUE

/obj/machinery/door/airlock/pyro/glass/reinforced/meteorhit()
	return
/obj/machinery/door/airlock/pyro/glass/reinforced/ex_act()
	return
/obj/machinery/door/airlock/pyro/glass/reinforced/blob_act(power)
	return

/obj/machinery/door/airlock/pyro/glass/command
	name = "command airlock"
	icon_state = "com_glass_closed"
	icon_base = "com_glass"

/obj/machinery/door/airlock/pyro/glass/engineering
	name = "engineering airlock"
	icon_state = "eng_glass_closed"
	icon_base = "eng_glass"

/obj/machinery/door/airlock/pyro/glass/security //Shitty Azungar recolor, no need to thank me.
	name = "security airlock"
	icon_state = "sec_glass_closed"
	icon_base = "sec_glass"

/obj/machinery/door/airlock/pyro/glass/security/alt
	name = "security airlock"
	icon_state = "sec_glassalt_closed"
	icon_base = "sec_glassalt"

/obj/machinery/door/airlock/pyro/glass/med
	name = "medical airlock"
	icon_state = "med_glass_closed"
	icon_base = "med_glass"

/obj/machinery/door/airlock/pyro/glass/sci
	name = "research airlock"
	icon_state = "sci_glass_closed"
	icon_base = "sci_glass"

/obj/machinery/door/airlock/pyro/glass/toxins
	name = "toxins airlock"
	icon_state = "toxins_glass_closed"
	icon_base = "toxins_glass"

/obj/machinery/door/airlock/pyro/glass/mining
	name = "mining airlock"
	icon_state = "mining_glass_closed"
	icon_base = "mining_glass"

/obj/machinery/door/airlock/pyro/glass/botany
	name = "botany airlock"
	icon_state = "botany_glass_closed"
	icon_base = "botany_glass"

// -------- windoors

/obj/machinery/door/airlock/pyro/glass/windoor
	name = "thin glass airlock"
	icon_state = "windoor_closed"
	icon_base = "windoor"
	panel_icon_state = "windoor_panel_open"
	welded_icon_state = "glassdoor_welded"
	sound_airlock = 'sound/machines/windowdoor.ogg'
	has_crush = FALSE
	health = 500
	health_max = 500
	layer = EFFECTS_LAYER_UNDER_4 // under lights and blinds, above pretty much everything else
	object_flags = BOTS_DIRBLOCK | CAN_REPROGRAM_ACCESS | HAS_DIRECTIONAL_BLOCKING
	flags = IS_PERSPECTIVE_FLUID | FLUID_DENSE | ON_BORDER
	event_handler_flags = USE_FLUID_ENTER

/obj/machinery/door/airlock/pyro/glass/windoor/opened()
	layer = COG2_WINDOW_LAYER //this is named weirdly, but seems right
	. = ..()

/obj/machinery/door/airlock/pyro/glass/windoor/close()
	layer = EFFECTS_LAYER_UNDER_4
	. = ..()

/obj/machinery/door/airlock/pyro/glass/windoor/bumpopen(atom/movable/AM)
	if (src.density)
		src.autoclose = TRUE
	..()

/obj/machinery/door/airlock/pyro/glass/windoor/attack_hand(mob/user)
	if (src.density)
		src.autoclose = FALSE
	..(user)

/obj/machinery/door/airlock/pyro/glass/windoor/Cross(atom/movable/mover)
	if (istype(mover, /obj/projectile))
		var/obj/projectile/P = mover
		if (P.proj_data.window_pass)
			return 1

	if (get_dir(loc, mover) & dir) // Check for appropriate border.
		if(density && mover && mover.flags & DOORPASS && !src.cant_emag)
			if (ismob(mover) && mover:pulling && src.bumpopen(mover))
				// If they're pulling something and the door would open anyway,
				// just let the door open instead.
				return 0
			animate_door_squeeze(mover)
			return 1 // they can pass through a closed door
		return !density
	else
		return 1

/obj/machinery/door/airlock/pyro/glass/windoor/gas_cross(turf/target)
	if(get_dir(loc, target) & dir)
		return !density
	else
		return TRUE

/obj/machinery/door/airlock/pyro/glass/windoor/Uncross(atom/movable/mover, do_bump = TRUE)
	if (istype(mover, /obj/projectile))
		var/obj/projectile/P = mover
		if (P.proj_data.window_pass)
			return TRUE
	if (get_dir(loc, mover.movement_newloc) & dir)
		if(density && mover && mover.flags & DOORPASS && !src.cant_emag)
			if (ismob(mover) && mover:pulling && src.bumpopen(mover))
				// If they're pulling something and the door would open anyway,
				// just let the door open instead.
				. = FALSE
				UNCROSS_BUMP_CHECK(mover)
				return
			animate_door_squeeze(mover)
			return TRUE // they can pass through a closed door
		. = !density
	else
		. = TRUE
	UNCROSS_BUMP_CHECK(mover)
/obj/machinery/door/airlock/pyro/glass/windoor/update_nearby_tiles(need_rebuild)
	if (!air_master) return 0

	var/turf/simulated/source = loc
	var/turf/simulated/target = get_step(source,dir)

	if (need_rebuild)
		if (istype(source)) // Rebuild resp. update nearby group geometry.
			if (source.parent)
				air_master.groups_to_rebuild[source.parent] = null
			else
				air_master.tiles_to_update[source] = null

		if (istype(target))
			if (target.parent)
				air_master.groups_to_rebuild[target.parent] = null
			else
				air_master.tiles_to_update[target] = null
	else
		if (istype(source)) air_master.tiles_to_update[source] = null
		if (istype(target)) air_master.tiles_to_update[target] = null

	if (istype(source))
		source.selftilenotify() //for fluids

/obj/machinery/door/airlock/pyro/glass/windoor/xmasify()
	return

/obj/machinery/door/airlock/pyro/glass/windoor/alt
	icon_state = "windoor2_closed"
	icon_base = "windoor2"
	panel_icon_state = null
	welded_icon_state = "windoor2_weld"
	sound_airlock = 'sound/machines/windowdoor.ogg'
	has_crush = FALSE
