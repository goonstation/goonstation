// how many possible network verification codes are there (i.e. how hard is it to bruteforce)
#define NET_ACCESS_OPTIONS 32

/*
	New methods:
	pulse - sends a pulse into a wire for hacking purposes
	cut - cuts a wire and makes any necessary state changes
	mend - mends a wire and makes any necessary state changes
	isWireColorCut - returns 1 if that color wire is cut, or 0 if not
	isWireCut - returns 1 if that wire (e.g. AIRLOCK_WIRE_DOOR_BOLTS) is cut, or 0 if not
	canAIControl - 1 if the AI can control the airlock, 0 if not (then check canAIHack to see if it can hack in)
	canAIHack - 1 if the AI can hack into the airlock to recover control, 0 if not. Also returns 0 if the AI does not *need* to hack it.
	arePowerSystemsOn - 1 if the main or backup power are functioning, 0 if not. Does not check whether the power grid is charged or an APC has equipment on or anything like that. (Check (src.status & NOPOWER) for that)
	requiresIDs - 1 if the airlock is requiring IDs, 0 if not
	isAllPowerCut - 1 if the main and backup power both have cut wires.
	regainMainPower - handles the effects of main power coming back on.
	loseMainPower - handles the effects of main power going offline. Usually (if one isn't already running) spawn a thread to count down how long it will be offline - counting down won't happen if main power was completely cut along with backup power, though, the thread will just sleep.
	loseBackupPower - handles the effects of backup power going offline.
	regainBackupPower - handles the effects of main power coming back on.
	shock - has a chance of electrocuting its target.
*/


/obj/machinery/door/airlock/proc/shock_temp(mob/user)
	//electrify door for 30 seconds
	if(!src.arePowerSystemsOn() || (src.status & NOPOWER))
		boutput(user, "The door has no power - you can't electrify it.")
		return
	if(!src.can_shock)
		boutput(user, "This door is unable to be electrified, you cannot shock it.")
		return
	if (src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
		boutput(user, text("<span class='alert'>The electrification wire has been cut.<br><br></span>"))
	else if (src.secondsElectrified==-1)
		boutput(user, text("<span class='alert'>The door is already indefinitely electrified. You'd have to un-electrify it before you can re-electrify it with a non-forever duration.<br><br></span>"))
	else if (src.secondsElectrified!=0)
		boutput(user, text("<span class='alert'>The door is already electrified. You can't re-electrify it while it's already electrified.<br><br></span>"))
	else
		src.secondsElectrified = 30
		logTheThing(LOG_COMBAT, user, "electrified airlock ([src]) at [log_loc(src)] for 30 seconds.")
		message_admins("[key_name(user)] electrified airlock ([src]) at [log_loc(src)] for 30 seconds.")
		SPAWN(1 SECOND)
			while (src.secondsElectrified>0)
				src.secondsElectrified-=1
				if (src.secondsElectrified<0)
					src.secondsElectrified = 0
				sleep(1 SECOND)

/obj/machinery/door/airlock/proc/toggle_bolt(mob/user)
	if (src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
		boutput(user, "<span class='alert'>You can't drop the door bolts - The door bolt dropping wire has been cut.</span>")
		return
	if(!src.arePowerSystemsOn() || (src.status & NOPOWER))
		boutput(user, "<span class='alert'>The door has no power - you can't raise/lower the door bolts.</span>")
		return
	if(src.locked)
		src.locked = 0
		src.UpdateIcon()
		playsound(src, 'sound/machines/airlock_unbolt.ogg', 40, 1, -2)
	else
		logTheThing(LOG_STATION, user, "[user] has bolted a door at [log_loc(src)].")
		src.locked = 1
		src.UpdateIcon()
		playsound(src, 'sound/machines/airlock_bolt.ogg', 40, 1, -2)

/obj/machinery/door/airlock/proc/shock_perm(mob/user)
	if(!src.arePowerSystemsOn() || (src.status & NOPOWER))
		boutput(user, "<span class='alert'>The door has no power - you can't electrify it.</span>")
		return
	//electrify door indefinitely
	if(!src.can_shock)
		boutput(user, text("<span class='alert'>This door is unable to be electrified.<br><br></span>"))
	if (src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
		boutput(user, text("<span class='alert'>The electrification wire has been cut.<br><br></span>"))
	else if (src.secondsElectrified==-1)
		boutput(user, text("<span class='alert'>The door is already indefinitely electrified.<br><br></span>"))
	else if (src.secondsElectrified!=0)
		boutput(user, text("<span class='alert'>The door is already electrified. You can't re-electrify it while it's already electrified.<br><br></span>"))
	else
		logTheThing(LOG_COMBAT, user, "electrified airlock ([src]) at [log_loc(src)] indefinitely.")
		message_admins("[key_name(user)] electrified airlock ([src]) at [log_loc(src)] indefinitely.")
		src.secondsElectrified = -1

/obj/machinery/door/airlock/proc/shock_restore(mob/user)
	//un-electrify door
	if(!src.arePowerSystemsOn() || (src.status & NOPOWER))
		boutput(user, "The door has no power - you can't electrify it.")
		return
	if (src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
		boutput(user, text("<span class='alert'>Can't un-electrify the airlock - The electrification wire is cut.<br><br></span>"))
	else if (src.secondsElectrified!=0)
		src.secondsElectrified = 0
		logTheThing(LOG_COMBAT, user, "de-electrified airlock ([src]) at [log_loc(src)].")
		message_admins("[key_name(user)] de-electrified airlock ([src]) at [log_loc(src)].")


/obj/machinery/door/airlock/proc/idscantoggle(mob/user)
	if(!src.arePowerSystemsOn() || (src.status & NOPOWER))
		boutput(user, "<span class='alert'>The door has no power - you toggle the ID scanner.</span>")
		return
	//enable/disable ID scanner
	if (src.isWireCut(AIRLOCK_WIRE_IDSCAN))
		boutput(user, "The IdScan wire has been cut - So, you can't disable it, but it is already disabled anyways.")
	else
		src.aiDisabledIdScanner = !src.aiDisabledIdScanner


/obj/machinery/door/airlock/proc/user_toggle_open(mob/user)
	if (src.operating == 1)
		return
	if((!src.arePowerSystemsOn()) || (src.status & NOPOWER) || src.isWireCut(AIRLOCK_WIRE_OPEN_DOOR))
		boutput(user, "<span class='alert'>The door has no power - you can't open/close it.</span>")
		return
	if(src.welded)
		boutput(user, text("<span class='alert'>The airlock has been welded shut!</span>"))
	else if(locked)
		boutput(user, text("<span class='alert'>The door bolts are down!</span>"))
	else if(!density)
		close()
	else
		open()


//This generates the randomized airlock wire assignments for the game.
/proc/RandomAirlockWires()
	//to make this not randomize the wires, just set index to 1 and increment it in the flag for loop (after doing everything else).
	var/list/wires = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	airlockIndexToFlag = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	airlockIndexToWireColor = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	airlockWireColorToIndex = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	var/flagIndex = 1
	for (var/flag=1, flag<1024, flag+=flag)
		var/valid = 0
		while (!valid)
			var/colorIndex = rand(1, 10)
			if (wires[colorIndex]==0)
				valid = 1
				wires[colorIndex] = flag
				airlockIndexToFlag[flagIndex] = flag
				airlockIndexToWireColor[flagIndex] = colorIndex
				airlockWireColorToIndex[colorIndex] = flagIndex
		flagIndex+=1
	return wires

/* Example:
Airlock wires color -> flag are { 64, 128, 256, 2, 16, 4, 8, 32, 1 }.
Airlock wires color -> index are { 7, 8, 9, 2, 5, 3, 4, 6, 1 }.
Airlock index -> flag are { 1, 2, 4, 8, 16, 32, 64, 128, 256 }.
Airlock index -> wire color are { 9, 4, 6, 7, 5, 8, 1, 2, 3 }.
*/

/obj/machinery/door/airlock
	name = "airlock"
	icon = 'icons/obj/doors/SL_doors.dmi'
	icon_state = "door_closed"
	deconstruct_flags = DECON_NULL_ACCESS | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_SCREWDRIVER | DECON_MULTITOOL
	object_flags = BOTS_DIRBLOCK | CAN_REPROGRAM_ACCESS

	var/image/panel_image = null
	var/panel_icon_state = "panel_open"

	var/image/welded_image = null
	var/welded_icon_state = "welded"

	explosion_resistance = 2
	health = 600
	health_max = 600

	var/ai_no_access = 0 //This is the dumbest var.
	var/aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/secondsMainPowerLost = 0 //The number of seconds until power is restored.
	var/secondsBackupPowerLost = 0 //The number of seconds until power is restored.
	var/cyborgBumpAccess = TRUE
	var/spawnPowerRestoreRunning = 0
	var/welded = null
	var/wires = 1023 //goddd use bitflag defines please
	var/list/wire_colors = list("Orange" = 1, "Pink" = 2, "White" = 3, "Yellow" = 4, "Red" = 5, "Blue" = 6, "Green" = 7, "Grey" = 8, "Olive" = 9, "Teal" = 10)
	secondsElectrified = 0 //How many seconds remain until the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/aiDisabledIdScanner = FALSE
	var/aiHacking = 0
	var/obj/machinery/door/airlock/closeOther = null
	var/closeOtherId = null
	var/list/signalers[10]
	var/lockdownbyai = 0
	var/net_id = null
	var/sound_airlock = 'sound/machines/airlock_swoosh_temp.ogg'
	var/sound_close_airlock = null
	sound_deny = 'sound/machines/airlock_deny.ogg'
	var/sound_deny_temp = 'sound/machines/airlock_deny_temp.ogg'
	var/id = null
	var/radiorange = AIRLOCK_CONTROL_RANGE
	var/safety = 1
	var/can_shock = TRUE
	var/hackingProgression = 0
	var/has_panel = TRUE
	var/hackMessage = ""
	var/net_access_code = null

	var/no_access = 0

	autoclose = TRUE
	power_usage = 50
	operation_time = 6
	brainloss_stumble = TRUE

	get_desc()
		var/healthpercent = src.health/src.health_max * 100
		switch(healthpercent)
			if(90 to 99) //dont want to clog up the description unless it's actually damaged
				. += "It seems to be in mostly good condition"
			if(75 to 89)
				. += "It seems slightly [pick("dinged up", "dented", "damaged", "scratched")]"
			if(50 to 74)
				. += "It looks [pick("busted", "damaged", "messed up", "dented")]."
			if(25 to 49)
				. += "It looks [pick("quite", "pretty", "rather", "notably")] [pick("mangled", "busted", "messed up", "wrecked", "destroyed", "haggard")]."
			if(0 to 24)
				. += "It is barely intact!"

/obj/machinery/door/airlock/New()
	..()
	if(!isrestrictedz(src.z) && src.name == initial(src.name)) //The second half prevents varedited names being overwritten
		var/area/station/A = get_area(src)
		src.name = A.name
	src.net_access_code = rand(1, NET_ACCESS_OPTIONS)
	START_TRACKING


/obj/machinery/door/airlock/was_built_from_frame(mob/user, newly_built)
	. = ..()
	req_access = list()

/obj/machinery/door/airlock/disposing()
	. = ..()
	STOP_TRACKING


/obj/machinery/door/airlock/check_access(obj/item/I)
	if (src.no_access) //nope :)
		return 0
	.= ..()

/obj/machinery/door/airlock/command
	name = "command airlock"
	icon = 'icons/obj/doors/Doorcom.dmi'
	req_access = list(access_heads)

/obj/machinery/door/airlock/security
	name = "security airlock"
	icon = 'icons/obj/doors/Doorsec.dmi'
	req_access = list(access_security)

/obj/machinery/door/airlock/engineering
	name = "engineering airlock"
	icon = 'icons/obj/doors/Dooreng.dmi'
	req_access = list(access_engineering)

/obj/machinery/door/airlock/medical
	name = "medical airlock"
	icon = 'icons/obj/doors/doormed.dmi'
	req_access = list(access_medical)

/obj/machinery/door/airlock/maintenance
	name = "maintenance airlock"
	icon = 'icons/obj/doors/Doormaint.dmi'
	req_access = list(access_maint_tunnels)

/obj/machinery/door/airlock/external
	name = "external airlock"
	icon = 'icons/obj/doors/Doorext.dmi'
	sound_airlock = 'sound/machines/airlock.ogg'
	opacity = 0
	visible = 0
	operation_time = 10

/obj/machinery/door/airlock/syndicate // fuck our players for making us (or at least me) need this
	name = "reinforced external airlock"
	desc = "Looks pretty tough. I wouldn't take this door on in a fight."
	icon = 'icons/obj/doors/Doorext.dmi'
	req_access_txt = "52"
	cant_emag = TRUE
	cyborgBumpAccess = FALSE
	hardened = TRUE
	aiControlDisabled = TRUE
	object_flags = BOTS_DIRBLOCK
	mats = 0

/obj/machinery/door/airlock/syndicate/meteorhit()
	return

/obj/machinery/door/airlock/syndicate/ex_act()
	return

/obj/machinery/door/airlock/centcom
	icon = 'icons/obj/doors/Doorcom.dmi'
	req_access_txt = "57"
	cant_emag = TRUE
	cyborgBumpAccess = FALSE
	hardened = TRUE
	aiControlDisabled = TRUE
	object_flags = BOTS_DIRBLOCK
	mats = 0

/obj/machinery/door/airlock/centcom/meteorhit()
	return

/obj/machinery/door/airlock/centcom/ex_act()
	return

/obj/machinery/door/airlock/glass
	name = "glass airlock"
	icon = 'icons/obj/doors/Doorglass.dmi'
	opacity = 0
	visible = 0

/obj/machinery/door/airlock/glass/command
		name = "command airlock"
		icon = 'icons/obj/doors/Doorcom-glass.dmi'
		req_access = list(access_heads)

/obj/machinery/door/airlock/glass/engineering
		name = "engineering airlock"
		icon = 'icons/obj/doors/Dooreng-glass.dmi'
		req_access = list(access_engineering)

/obj/machinery/door/airlock/glass/medical
		name = "medical airlock"
		icon = 'icons/obj/doors/Doormed-glass.dmi'
		req_access = list(access_medical)

/obj/machinery/door/airlock/classic
	name = "large airlock"
	icon = 'icons/obj/doors/Doorclassic.dmi'
	sound_airlock = 'sound/machines/airlock.ogg'
	operation_time = 10

/obj/machinery/door/airlock/pyro
	name = "airlock"
	icon = 'icons/obj/doors/SL_doors.dmi'
	flags = FPRINT | IS_PERSPECTIVE_FLUID | ALWAYS_SOLID_FLUID

/obj/machinery/door/airlock/pyro/safe
	can_shock = FALSE

/obj/machinery/door/airlock/pyro/alt
	icon_state = "generic2_closed"
	icon_base = "generic2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"

/obj/machinery/door/airlock/pyro/command
	name = "command airlock"
	icon_state = "com_closed"
	icon_base = "com"
	req_access = null
	health = 800
	health_max = 800

/obj/machinery/door/airlock/pyro/command/centcom
	req_access_txt = "57"
	cant_emag = TRUE
	cyborgBumpAccess = FALSE
	hardened = TRUE
	aiControlDisabled = TRUE
	object_flags = BOTS_DIRBLOCK
	mats = 0

/obj/machinery/door/airlock/pyro/command/alt
	icon_state = "com2_closed"
	icon_base = "com2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	req_access = null

/obj/machinery/door/airlock/pyro/command/syndicate
	req_access = list(access_syndicate_commander)
	mats = 0

/obj/machinery/door/airlock/pyro/weapons
	icon_state = "manta_closed"
	icon_base = "manta"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	req_access = null
	hardened = TRUE
	aiControlDisabled = TRUE
	cyborgBumpAccess = FALSE

/obj/machinery/door/airlock/pyro/weapons/noemag
	req_access = null
	cant_emag = TRUE
	cyborgBumpAccess = FALSE




/obj/machinery/door/airlock/pyro/security
	name = "security airlock"
	icon_state = "sec_closed"
	icon_base = "sec"
	req_access = null

/obj/machinery/door/airlock/pyro/security/alt
	icon_state = "sec2_closed"
	icon_base = "sec2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	req_access = null

/obj/machinery/door/airlock/pyro/engineering
	name = "engineering airlock"
	icon_state = "eng_closed"
	icon_base = "eng"
	req_access = null

/obj/machinery/door/airlock/pyro/engineering/alt
	icon_state = "eng2_closed"
	icon_base = "eng2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	req_access = null

/obj/machinery/door/airlock/pyro/medical
	name = "medical airlock"
	icon_state = "research_closed"
	icon_base = "research"
	req_access = null

/obj/machinery/door/airlock/pyro/medical/alt
	icon_state = "research2_closed"
	icon_base = "research2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	req_access = null

/obj/machinery/door/airlock/pyro/medical/alt2
	icon_state = "med_closed"
	icon_base = "med"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	req_access = null

/obj/machinery/door/airlock/pyro/medical/morgue
	icon_state = "morgue_closed"
	icon_base = "morgue"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	req_access = null

/obj/machinery/door/airlock/pyro/mining
	name = "mining airlock"
	icon_state = "mining_closed"
	icon_base = "mining"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	req_access = null

/obj/machinery/door/airlock/pyro/maintenance
	name = "maintenance airlock"
	icon_state = "maint_closed"
	icon_base = "maint"
	req_access = null

/obj/machinery/door/airlock/pyro/maintenance/alt
	icon_state = "maint2_closed"
	icon_base = "maint2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"


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
	mats = 0

/obj/machinery/door/airlock/pyro/reinforced/meteorhit()
	return
/obj/machinery/door/airlock/pyro/reinforced/ex_act()
	return
/obj/machinery/door/airlock/pyro/reinforced/blob_act(power)
	return

/obj/machinery/door/airlock/pyro/reinforced/syndicate
	req_access_txt = "52"
	cyborgBumpAccess = FALSE

/obj/machinery/door/airlock/pyro/glass
	name = "glass airlock"
	icon_state = "glass_closed"
	icon_base = "glass"
	panel_icon_state = "glass_panel_open"
	welded_icon_state = "glass_welded"
	opacity = 0
	visible = 0

/obj/machinery/door/airlock/pyro/glass/reinforced
	name = "reinforced glass airlock"
	desc = "Looks pretty tough. I wouldn't take this door on in a fight."
	operation_time = 10
	cant_emag = TRUE
	hardened = TRUE
	aiControlDisabled = TRUE
	mats = 0

/obj/machinery/door/airlock/pyro/glass/reinforced/meteorhit()
	return
/obj/machinery/door/airlock/pyro/glass/reinforced/ex_act()
	return
/obj/machinery/door/airlock/pyro/glass/reinforced/blob_act(power)
	return

/obj/machinery/door/airlock/pyro/glass/brig
	req_access_txt = "2"

/obj/machinery/door/airlock/pyro/glass/command
	name = "command airlock"
	icon_state = "com_glass_closed"
	icon_base = "com_glass"
	req_access = null

/obj/machinery/door/airlock/pyro/glass/engineering
	name = "engineering airlock"
	icon_state = "eng_glass_closed"
	icon_base = "eng_glass"
	req_access = null

/obj/machinery/door/airlock/pyro/glass/security //Shitty Azungar recolor, no need to thank me.
	name = "security airlock"
	icon_state = "sec_glass_closed"
	icon_base = "sec_glass"
	req_access = null

/obj/machinery/door/airlock/pyro/glass/security/alt
	name = "security airlock"
	icon_state = "sec_glassalt_closed"
	icon_base = "sec_glassalt"
	req_access = null

/obj/machinery/door/airlock/pyro/glass/med
	name = "medical airlock"
	icon_state = "med_glass_closed"
	icon_base = "med_glass"
	req_access = null

/obj/machinery/door/airlock/pyro/glass/sci
	name = "research airlock"
	icon_state = "sci_glass_closed"
	icon_base = "sci_glass"
	req_access = null

/obj/machinery/door/airlock/pyro/glass/toxins
	name = "toxins airlock"
	icon_state = "toxins_glass_closed"
	icon_base = "toxins_glass"
	req_access = null

/obj/machinery/door/airlock/pyro/glass/mining
	name = "mining airlock"
	icon_state = "mining_glass_closed"
	icon_base = "mining_glass"
	req_access = null

/obj/machinery/door/airlock/pyro/glass/botany
	name = "botany airlock"
	icon_state = "botany_glass_closed"
	icon_base = "botany_glass"
	req_access = null

/obj/machinery/door/airlock/pyro/classic
	name = "old airlock"
	icon_state = "old_closed"
	icon_base = "old"
	panel_icon_state = "old_panel_open"
	welded_icon_state = "old_welded"
	sound_airlock = 'sound/machines/airlock.ogg'
	operation_time = 10

/obj/machinery/door/airlock/pyro/glass/windoor
	name = "thin glass airlock"
	icon_state = "windoor_closed"
	icon_base = "windoor"
	panel_icon_state = "windoor_panel_open"
	welded_icon_state = "fdoor_weld"
	sound_airlock = 'sound/machines/windowdoor.ogg'
	has_crush = FALSE
	health = 500
	health_max = 500
	layer = EFFECTS_LAYER_UNDER_1
	object_flags = BOTS_DIRBLOCK | CAN_REPROGRAM_ACCESS | HAS_DIRECTIONAL_BLOCKING
	flags = FPRINT | IS_PERSPECTIVE_FLUID | ALWAYS_SOLID_FLUID | ON_BORDER
	event_handler_flags = USE_FLUID_ENTER

/obj/machinery/door/airlock/pyro/glass/windoor/opened()
	layer = COG2_WINDOW_LAYER //this is named weirdly, but seems right
	. = ..()

/obj/machinery/door/airlock/pyro/glass/windoor/close()
	layer = EFFECTS_LAYER_UNDER_1
	. = ..()

/obj/machinery/door/airlock/pyro/glass/windoor/bumpopen(mob/user)
	if (src.density)
		src.autoclose = TRUE
	..(user)

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
				air_master.groups_to_rebuild |= source.parent
			else
				air_master.tiles_to_update |= source

		if (istype(target))
			if (target.parent)
				air_master.groups_to_rebuild |= target.parent
			else
				air_master.tiles_to_update |= target
	else
		if (istype(source)) air_master.tiles_to_update |= source
		if (istype(target)) air_master.tiles_to_update |= target

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

/obj/machinery/door/airlock/pyro/sci_alt
	name = "research airlock"
	icon_state = "sci_closed"
	icon_base = "sci"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	req_access = null

/obj/machinery/door/airlock/pyro/toxins_alt
	name = "toxins airlock"
	icon_state = "toxins2_closed"
	icon_base = "toxins2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	req_access = null

/obj/machinery/door/airlock/gannets
	name = "airlock"
	icon = 'icons/obj/doors/destiny.dmi'
	icon_state = "gen_closed"
	icon_base = "gen"

	alt
		icon_state = "fgen_closed"
		icon_base = "fgen"
		welded_icon_state = "fgen_welded"

	command
		name = "command airlock"
		icon_state = "com_closed"
		icon_base = "com"
		req_access = list(access_heads)

	command/alt
		icon_state = "fcom_closed"
		icon_base = "fcom"
		welded_icon_state = "fcom_welded"

	security
		name = "security airlock"
		icon_state = "sec_closed"
		icon_base = "sec"
		req_access = list(access_security)

	security/alt
		icon_state = "fsec_closed"
		icon_base = "fsec"
		welded_icon_state = "fsec_welded"

	engineering
		name = "engineering airlock"
		icon_state = "eng_closed"
		icon_base = "eng"
		req_access = list(access_engineering)

	engineering/alt
		icon_state = "feng_closed"
		icon_base = "feng"
		welded_icon_state = "feng_welded"

	medical
		name = "medical airlock"
		icon_state = "med_closed"
		icon_base = "med"
		req_access = list(access_medical)

	medical/alt
		icon_state = "fmed_closed"
		icon_base = "fmed"
		welded_icon_state = "fmed_welded"

	morgue
		name = "morgue airlock"
		icon_state = "morg_closed"
		icon_base = "morg"
		req_access = list(access_morgue)

	morgue/alt
		icon_state = "fmorg_closed"
		icon_base = "fmorg"
		welded_icon_state = "fmorg_welded"

	chemistry
		name = "chemistry airlock"
		icon_state = "chem_closed"
		icon_base = "chem"
		req_access = list(access_research)

	chemistry/alt
		icon_state = "fchem_closed"
		icon_base = "fchem"
		welded_icon_state = "fchem_welded"

	toxins
		name = "toxins airlock"
		icon_state = "tox_closed"
		icon_base = "tox"
		req_access = list(access_research)

	toxins/alt
		icon_state = "ftox_closed"
		icon_base = "ftox"
		welded_icon_state = "ftox_welded"

	maintenance
		name = "maintenance airlock"
		icon_state = "maint_closed"
		icon_base = "maint"
		welded_icon_state = "maint_welded"
		req_access = list(access_maint_tunnels)

/obj/machinery/door/airlock/gannets/glass
	name = "glass airlock"
	icon = 'icons/obj/doors/destiny.dmi'
	icon_state = "tgen_closed"
	icon_base = "tgen"
	opacity = 0
	visible = 0

	alt
		icon_state = "tfgen_closed"
		icon_base = "tfgen"
		welded_icon_state = "fgen_welded"

	command
		name = "glass command airlock"
		icon_state = "tcom_closed"
		icon_base = "tcom"
		req_access = list(access_heads)

	command/alt
		icon_state = "tfcom_closed"
		icon_base = "tfcom"
		welded_icon_state = "fcom_welded"

	security
		name = "glass security airlock"
		icon_state = "tsec_closed"
		icon_base = "tsec"
		req_access = list(access_security)

	security/alt
		icon_state = "tfsec_closed"
		icon_base = "tfsec"
		welded_icon_state = "fsec_welded"

	engineering
		name = "glass engineering airlock"
		icon_state = "teng_closed"
		icon_base = "teng"
		req_access = list(access_engineering)

	engineering/alt
		icon_state = "tfeng_closed"
		icon_base = "tfeng"
		welded_icon_state = "feng_welded"

	medical
		name = "glass medical airlock"
		icon_state = "tmed_closed"
		icon_base = "tmed"
		req_access = list(access_medical)

	medical/alt
		icon_state = "tfmed_closed"
		icon_base = "tfmed"
		welded_icon_state = "fmed_welded"

	morgue
		name = "glass morgue airlock"
		icon_state = "tmorg_closed"
		icon_base = "tmorg"
		req_access = list(access_morgue)

	morgue/alt
		icon_state = "tfmorg_closed"
		icon_base = "tfmorg"
		welded_icon_state = "fmorg_welded"

	chemistry
		name = "glass chemistry airlock"
		icon_state = "tchem_closed"
		icon_base = "tchem"
		req_access = list(access_research)

	chemistry/alt
		icon_state = "tfchem_closed"
		icon_base = "tfchem"
		welded_icon_state = "fchem_welded"

	toxins
		name = "glass toxins airlock"
		icon_state = "ttox_closed"
		icon_base = "ttox"
		req_access = list(access_research)

	toxins/alt
		icon_state = "tftox_closed"
		icon_base = "tftox"
		welded_icon_state = "ftox_welded"

	maintenance
		name = "glass maintenance airlock"
		icon_state = "tmaint_closed"
		icon_base = "tmaint"
		welded_icon_state = "tmaint_welded"
		req_access = list(access_maint_tunnels)

/*
About the new airlock wires panel:
*	An airlock wire dialog can be accessed by the normal way or by using wirecutters or a multitool on the door while the wire-panel is open. This would show the following wires, which you can either wirecut/mend or send a multitool pulse through. There are 9 wires.
*		one wire from the ID scanner. Sending a pulse through this flashes the red light on the door (if the door has power). If you cut this wire, the door will stop recognizing valid IDs. (If the door has 0000 access, it still opens and closes, though)
*		two wires for power. Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter). Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be red open, but bolts-raising will not work. Cutting these wires may electrocute the user.
*		one wire for door bolts. Sending a pulse through this drops door bolts (whether the door is powered or not) or raises them (if it is). Cutting this wire also drops the door bolts, and mending it does not raise them. If the wire is cut, trying to raise the door bolts will not work.
*		two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter). Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
*		one wire for opening the door. Sending a pulse through this while the door has power makes it open the door if no access is required.
*		one wire for AI control. Sending a pulse through this blocks AI control for a second or so (which is enough to see the AI control light on the panel dialog go off and back on again). Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
*		one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds. Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted. (Currently it is also STAYING electrified until someone mends the wire)
*/
/obj/machinery/door/airlock/proc/play_deny()
	play_animation("deny")
	playsound(src, src.sound_deny_temp, 35, 0, 0.8) //if this doesn't carry far enough, tweak the extrarange number, not the volume

/obj/machinery/door/airlock/proc/try_pulse(var/wire_color, mob/user)
	if (!user.find_tool_in_hand(TOOL_PULSING))
		boutput(user, "You need a multitool or similar!")
		return FALSE
	if (src.isWireColorCut(wire_color))
		boutput(user, "You can't pulse a cut wire.")
		return FALSE
	src.pulse(wire_color)
	return TRUE

/obj/machinery/door/airlock/proc/pulse(var/wireColor)
	//var/wireFlag = airlockWireColorToFlag[wireColor] //not used in this function
	var/wireIndex = airlockWireColorToIndex[wireColor]
	switch(wireIndex)
		if(AIRLOCK_WIRE_IDSCAN)
			//Sending a pulse through this flashes the red light on the door (if the door has power).
			if ((src.arePowerSystemsOn()) && (!(src.status & NOPOWER)))
				play_deny()
		if (AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
			//Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter).
			src.loseMainPower()
			SPAWN(1 DECI SECOND)
				src.shock(usr, 25)
		if (AIRLOCK_WIRE_DOOR_BOLTS)
			//one wire for door bolts. Sending a pulse through this drops door bolts if they're not down (whether power's on or not),
			//raises them if they are down (only if power's on)
			if (!src.locked)
				src.locked = 1
				logTheThing(LOG_STATION, usr, "[usr] has bolted a door at [log_loc(src)].")
				boutput(usr, "You hear a clunk from the bottom of the door.")
				playsound(src, 'sound/machines/airlock_bolt.ogg', 40, 1, -2)
				tgui_process.update_uis(src)
			else
				if(src.arePowerSystemsOn()) //only can raise bolts if power's on
					src.locked = 0
					boutput(usr, "You hear a clunk from inside the door.")
					playsound(src, 'sound/machines/airlock_unbolt.ogg', 40, 1, -2)
			src.UpdateIcon()
			SPAWN(1 DECI SECOND)
				src.shock(usr, 25)

		if (AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
			//two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter).
			src.loseBackupPower()
			SPAWN(1 DECI SECOND)
				src.shock(usr, 25)
		if (AIRLOCK_WIRE_AI_CONTROL)
			if(prob(10))
				src.net_access_code = rand(1, NET_ACCESS_OPTIONS)
			if (src.aiControlDisabled == 0)
				src.aiControlDisabled = 1
			else if (src.aiControlDisabled == -1)
				src.aiControlDisabled = 2
			src.updateDialog()
			tgui_process.update_uis(src)
			SPAWN(1 SECOND)
				if (src.aiControlDisabled == 1)
					src.aiControlDisabled = 0
				else if (src.aiControlDisabled == 2)
					src.aiControlDisabled = -1
				src.updateDialog()
				tgui_process.update_uis(src)
			SPAWN(1 DECI SECOND)
				src.shock(usr, 25)
		if (AIRLOCK_WIRE_ELECTRIFY)
			//one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds.
			if (src.can_shock == 0)
				return
			if (src.secondsElectrified==0)
				src.secondsElectrified = 30
				logTheThing(LOG_STATION, usr, "temporarily electrified an airlock at [log_loc(src)] with a pulse.")
				SPAWN(1 SECOND)
					//TODO: Move this into process() and make pulsing reset secondsElectrified to 30
					while (src.secondsElectrified>0)
						src.secondsElectrified-=1
						if (src.secondsElectrified<0)
							src.secondsElectrified = 0
						//
						sleep(1 SECOND)
		if(AIRLOCK_WIRE_OPEN_DOOR)
			//tries to open the door without ID
			//will succeed only if the ID wire is cut or the door requires no access
			if (!src.requiresID() || src.check_access(null))
				if (src.density)
					open()
				else
					close()

		if(AIRLOCK_WIRE_SAFETY)
			logTheThing(LOG_STATION, usr, "caused an airlock to close and crush at [log_loc(src)] with a pulse.")
			src.safety = 0
			src.close(1)
			src.safety = 1
			SPAWN(1 DECI SECOND)
				src.shock(usr, 25)

/obj/machinery/door/airlock/proc/attach_signaler(var/wire_color, mob/user)
	if(!istype(user.equipped(), /obj/item/device/radio/signaler))
		boutput(user, "You need a signaler!")
		return FALSE

	if(src.isWireColorCut(wire_color))
		boutput(user, "You can't attach a signaler to a cut wire.")
		return FALSE

	var/obj/item/device/radio/signaler/R = user.equipped()
	if(!R.b_stat)
		boutput(user, "This radio can't be attached!")
		return FALSE

	user.drop_item()
	R.set_loc(src)
	R.airlock_wire = wire_color
	src.signalers[wire_color] = R
	tgui_process.update_uis(src)
	logTheThing(LOG_STATION, user, "attaches a remote signaller on frequency [R.frequency] to [src] at [log_loc(src)].")
	return TRUE

/obj/machinery/door/airlock/proc/detach_signaler(var/wire_color, mob/user)
	if(!(src.signalers[wire_color]))
		boutput(user, "There's no signaler attached to that wire!")
		return FALSE

	var/obj/item/device/radio/signaler/R = src.signalers[wire_color]
	user.put_in_hand_or_drop(R)
	R.airlock_wire = null
	src.signalers[wire_color] = null
	tgui_process.update_uis(src)
	return TRUE

/obj/machinery/door/airlock/proc/try_cut(var/wire_color, mob/user)
	if(!user.find_tool_in_hand(TOOL_SNIPPING))
		boutput(user, "You need a snipping tool!")
		return FALSE

	src.cut(wire_color)
	return TRUE

/obj/machinery/door/airlock/proc/cut(var/wireColor)
	var/wireFlag = airlockWireColorToFlag[wireColor]
	var/wireIndex = airlockWireColorToIndex[wireColor]
	wires &= ~wireFlag
	switch(wireIndex)
		if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
			//Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be crowbarred open, but bolts-raising will not work. Cutting these wires may electocute the user.
			src.loseMainPower()
			SPAWN(1 DECI SECOND)
				src.shock(usr, 50)
		if (AIRLOCK_WIRE_DOOR_BOLTS)
			//Cutting this wire also drops the door bolts, and mending it does not raise them. (This is what happens now, except there are a lot more wires going to door bolts at present)
			if (src.locked!=1)
				src.locked = 1
				playsound(src, 'sound/machines/airlock_bolt.ogg', 40, 1, -2)
				logTheThing(LOG_STATION, usr, "[usr] has bolted a door at [log_loc(src)].")
			src.UpdateIcon()

		if (AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
			//Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
			src.loseBackupPower()
			SPAWN(1 DECI SECOND)
				src.shock(usr, 50)

		if (AIRLOCK_WIRE_AI_CONTROL)
			//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
			//aiControlDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
			if (src.aiControlDisabled == 0)
				src.aiControlDisabled = 1
			else if (src.aiControlDisabled == -1)
				src.aiControlDisabled = 2
			SPAWN(1 DECI SECOND)
				src.shock(usr, 25)

		if (AIRLOCK_WIRE_ELECTRIFY)
			//Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted.
			if (src.secondsElectrified != -1 && can_shock)
				logTheThing(LOG_STATION, usr, "permanently electrified an airlock at [log_loc(src)] by cutting the shock wire.")
				src.secondsElectrified = -1

		if(AIRLOCK_WIRE_SAFETY)
			logTheThing(LOG_STATION, usr, "permanently disabled the safety of an airlock at [log_loc(src)] by cutting the safety wire.")
			src.safety = 0

	tgui_process.update_uis(src)

/obj/machinery/door/airlock/proc/try_mend(var/wire_color, mob/user)
	if(!user.find_tool_in_hand(TOOL_SNIPPING))
		boutput(user, "You need a snipping tool to mend the wire!")
		return FALSE
	src.mend(wire_color)
	return TRUE

/obj/machinery/door/airlock/proc/mend(var/wireColor)
	var/wireFlag = airlockWireColorToFlag[wireColor]
	var/wireIndex = airlockWireColorToIndex[wireColor] //not used in this function
	wires |= wireFlag
	switch(wireIndex)
		if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
			if ((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
				src.regainMainPower()
				SPAWN(1 DECI SECOND)
					src.shock(usr, 50)

		if (AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
			if ((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
				src.regainBackupPower()
				SPAWN(1 DECI SECOND)
					src.shock(usr, 50)

		if (AIRLOCK_WIRE_AI_CONTROL)
			//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
			//aiControlDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
			if (src.aiControlDisabled == 1)
				src.aiControlDisabled = 0
			else if (src.aiControlDisabled == 2)
				src.aiControlDisabled = -1

		if (AIRLOCK_WIRE_ELECTRIFY)
			if (src.secondsElectrified == -1)
				src.secondsElectrified = 0

		if(AIRLOCK_WIRE_SAFETY)
			logTheThing(LOG_STATION, usr, "re-enabled the safety of an airlock at [log_loc(src)] by mending the safety wire.")
			src.safety = 1

	tgui_process.update_uis(src)

/obj/machinery/door/airlock/proc/isElectrified()
	return (src.secondsElectrified != 0)

/obj/machinery/door/airlock/proc/isWireColorCut(var/wireColor)
	var/wireFlag = airlockWireColorToFlag[wireColor]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/door/airlock/proc/isWireCut(var/wireIndex)
	var/wireFlag = airlockIndexToFlag[wireIndex]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/door/airlock/proc/canAIControl()
	return ((src.aiControlDisabled!=1) && (!src.isAllPowerCut()) && (src.hardened == 0));

/obj/machinery/door/airlock/proc/canAIHack()
	return ((src.aiControlDisabled==1) && (!src.isAllPowerCut()) && (src.hardened == 0));

/obj/machinery/door/airlock/proc/arePowerSystemsOn()
	return (src.secondsMainPowerLost==0 || src.secondsBackupPowerLost==0)

/obj/machinery/door/airlock/requiresID()
	return !(src.isWireCut(AIRLOCK_WIRE_IDSCAN) || src.aiDisabledIdScanner)

/obj/machinery/door/airlock/proc/isAllPowerCut()
	var/retval=0
	if (src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1) || src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2))
		if (src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1) || src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2))
			retval=1
	return retval

/obj/machinery/door/airlock/proc/regainMainPower()
	if (src.secondsMainPowerLost > 0)
		src.secondsMainPowerLost = 0

/obj/machinery/door/airlock/proc/loseMainPower()
	if (src.secondsMainPowerLost <= 0)
		src.secondsMainPowerLost = 60
		if (src.secondsBackupPowerLost < 10)
			src.secondsBackupPowerLost = 10
	if (!src.spawnPowerRestoreRunning)
		src.spawnPowerRestoreRunning = 1
		SPAWN(0)
			var/cont = 1
			while (cont)
				sleep(1 SECOND)
				cont = 0
				if (src.secondsMainPowerLost>0)
					if ((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
						src.secondsMainPowerLost -= 1
						src.updateDialog()
						tgui_process.update_uis(src)
					cont = 1

				if (src.secondsBackupPowerLost>0)
					if ((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
						src.secondsBackupPowerLost -= 1
						src.updateDialog()
						tgui_process.update_uis(src)
					cont = 1
			src.spawnPowerRestoreRunning = 0
			src.updateDialog()
			tgui_process.update_uis(src)

/obj/machinery/door/airlock/proc/loseBackupPower()
	if (src.secondsBackupPowerLost < 60)
		src.secondsBackupPowerLost = 60

/obj/machinery/door/airlock/proc/regainBackupPower()
	if (src.secondsBackupPowerLost > 0)
		src.secondsBackupPowerLost = 0

//borrowed from the grille's get_connection
/obj/machinery/door/airlock/proc/get_connection()
	if(src.status & NOPOWER)
		return 0

	var/obj/machinery/power/apc/localAPC = get_local_apc(src)
	if (localAPC?.terminal?.powernet)
		return localAPC.terminal.powernet.number

	return 0

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
// The preceding comment was borrowed from the grille's shock script
/obj/machinery/door/airlock/proc/shock(mob/user, prb)

	if(!prob(prb))
		return 0 //you lucked out, no shock for you

	var/net = get_connection() //find the powernet of the connected cable

	if(!net) // cable is unpowered
		return 0

	if(src.electrocute(user, 100, net)) //this is on purpose so the rng wont roll twice
		return 1

	else
		return 0


/obj/machinery/door/airlock/update_icon(var/toggling = 0, override_parent = TRUE)
	if(toggling ? !density : density)
		if (locked)
			icon_state = "[icon_base]_locked"
		else
			icon_state = "[icon_base]_closed"
		if (src.panel_open)
			if (!src.panel_image)
				src.panel_image = image(src.icon, src.panel_icon_state)
			src.UpdateOverlays(src.panel_image, "panel")
		else
			src.UpdateOverlays(null, "panel")
		if (welded)
			if (!src.welded_image)
				src.welded_image = image(src.icon, src.welded_icon_state)
			src.UpdateOverlays(src.welded_image, "weld")
		else
			src.UpdateOverlays(null, "weld")
	else
		src.UpdateOverlays(null, "panel")
		src.UpdateOverlays(null, "weld")
		src.icon_state = "[icon_base]_open"
	return

/obj/machinery/door/airlock/play_animation(animation)
	switch (animation)
		if ("opening")
			src.UpdateIcon()
			if (src.panel_open)
				flick("o_[icon_base]_opening", src) // there's an issue with the panel overlay not being gone by the time the animation is nearly done but I can't make that stop, despite my best efforts
			else
				flick("[icon_base]_opening", src)
		if ("closing")
			src.UpdateIcon()
			if (src.panel_open)
				flick("o_[icon_base]_closing", src)
			else
				flick("[icon_base]_closing", src)
		if ("spark")
			flick("[icon_base]_spark", src)
		if ("deny")
			flick("[icon_base]_deny", src)
	return

/obj/machinery/door/airlock/attack_ai(mob/user as mob)
	ui_interact(user)

/obj/machinery/door/airlock/proc/hack(mob/user as mob)
	if (src.aiHacking==0)
		src.aiHacking=1
		SPAWN(2 SECONDS)
			//TODO: Make this take a minute
			boutput(user, "<span class='notice'>Airlock AI control has been blocked. Beginning fault-detection.</span>")
			src.hackMessage = "Fault Detection..."
			hackingProgression = 1
			tgui_process.update_uis(src)
			sleep(5 SECONDS)
			if (src.canAIControl())
				boutput(user, "<span class='notice'>Alert cancelled. Airlock control has been restored without our assistance.</span>")
				src.aiHacking=0
				return
			else if (!src.canAIHack())
				boutput(user, "<span class='notice'>We've lost our connection! Unable to hack airlock.</span>")
				src.aiHacking=0
				return
			boutput(user, "<span class='notice'>Fault confirmed: airlock control wire disabled or cut.</span>")
			src.hackMessage = "Fault Confirmed..."
			hackingProgression = 2
			tgui_process.update_uis(src)
			sleep(2 SECONDS)
			boutput(user, "<span class='notice'>Attempting to hack into airlock. This may take some time.</span>")
			src.hackMessage = "Hacking into airlock..."
			hackingProgression = 3
			tgui_process.update_uis(src)
			sleep(20 SECONDS)
			if (src.canAIControl())
				boutput(user, "<span class='notice'>Alert cancelled. Airlock control has been restored without our assistance.</span>")
				src.aiHacking=0
				return
			else if (!src.canAIHack())
				boutput(user, "<span class='alert'>We've lost our connection! Unable to hack airlock.</span>")
				src.aiHacking=0
				return
			boutput(user, "<span class='notice'>Upload access confirmed. Loading control program into airlock software.</span>")
			src.hackMessage = "Uploading..."
			hackingProgression = 4
			tgui_process.update_uis(src)
			sleep(17 SECONDS)
			if (src.canAIControl())
				boutput(user, "<span class='notice'>Alert cancelled. Airlock control has been restored without our assistance.</span>")
				src.aiHacking=0
				return
			else if (!src.canAIHack())
				boutput(user, "<span class='alert'>We've lost our connection! Unable to hack airlock.</span>")
				src.aiHacking=0
				return
			boutput(user, "<span class='notice'>Transfer complete. Forcing airlock to execute program.</span>")
			src.hackMessage = "Transfer complete"
			hackingProgression = 5
			tgui_process.update_uis(src)
			sleep(5 SECONDS)
			//disable blocked control
			src.aiControlDisabled = 2
			boutput(user, "<span class='notice'>Receiving control information from airlock.</span>")
			src.hackMessage = "Receiving Information"
			hackingProgression = 6
			tgui_process.update_uis(src)
			sleep(1 SECOND)
			hackingProgression = 0
			src.hackMessage = ""
			tgui_process.update_uis(src)
			//bring up airlock dialog
			src.aiHacking = 0

/obj/machinery/door/airlock/Bumped(atom/movable/AM)
	if(ON_COOLDOWN(src, "airlock_bump_try_open", 3 SECONDS))
		return
	if(ismob(AM))
		if (src.isElectrified())
			if(src.shock(AM, 100))
				return
	..()
/obj/machinery/door/airlock/bumpopen(atom/movable/AM)
	if (issilicon(AM))
		if (!src.cyborgBumpAccess)
			return
		var/mob/silicon = AM
		if (!silicon.mind)
			return
	. = ..()
/obj/machinery/door/airlock/ui_static_data(mob/user)
	. = list(
		"wireColors" = src.wire_colors,
		"netId" = src.net_id,
		"name" = src.name
	)

/obj/machinery/door/airlock/ui_status(mob/user, datum/ui_state/state)
	return min(
		tgui_default_state.can_use_topic(src, user),
		tgui_not_incapacitated_state.can_use_topic(src, user)
	)

/obj/machinery/door/airlock/proc/get_welding_positions(mob/user)
	var/start
	var/stop
	var/rel_dir = get_dir(user, src)
	if(istype(src, /obj/machinery/door/airlock/gannets)) //Gannets why your airlocks have so many welded icon states!!
		if(rel_dir == NORTH || rel_dir == NORTHWEST || rel_dir == NORTHEAST)
			start = list(0,-15)
			stop = list(0,15)
		else
			start = list(0,15)
			stop = list(0,-15)
	else
		switch(src.welded_icon_state)
			if("welded")
				if(dir == NORTH || dir == SOUTH)
					if(rel_dir == NORTH || rel_dir == NORTHWEST || rel_dir == NORTHEAST)
						start = list(0,-15)
						stop = list(0,15)
					else
						start = list(0,15)
						stop = list(0,-15)
				else
					if(rel_dir == EAST || rel_dir == SOUTHEAST || rel_dir == NORTHEAST)
						start = list(-15,0)
						stop = list(15,0)
					else
						start = list(15,0)
						stop = list(-15,0)
			if("2_welded")
				if(dir == NORTH || dir == SOUTH)
					if(rel_dir == NORTH || rel_dir == NORTHWEST || rel_dir == NORTHEAST)
						start = list(0,-15)
						stop = list(0,15)
					else
						start = list(0,15)
						stop = list(0,-15)
				else
					if(rel_dir == EAST || rel_dir == SOUTHEAST || rel_dir == NORTHEAST)
						start = list(-15,0)
						stop = list(15,0)
					else
						start = list(15,0)
						stop = list(-15,0)
			if("old_welded")
				if(dir == NORTH || dir == SOUTH)
					start = list(0,-15)
					stop = list(0,5)
				else
					if(rel_dir == EAST || rel_dir == SOUTHEAST || rel_dir == NORTHEAST)
						start = list(-15,0)
						stop = list(15,0)
					else
						start = list(15,0)
						stop = list(-15,0)
			if("fdoor_weld")
				if(dir == EAST)
					start = list(15,-15)
					stop = list(15,15)
				else if(dir == WEST)
					start = list(-15,-15)
					stop = list(-15,15)
				else
					start = list(-15,-15)
					stop = list(15,-15)
			else
				if(dir == NORTH || dir == SOUTH)
					start = list(-15,-15)
					stop = list(15,-15)
				else
					if(rel_dir == EAST || rel_dir == SOUTHEAST || rel_dir == NORTHEAST)
						start = list(-15,-15)
						stop = list(-15,15)
					else
						start = list(15,-15)
						stop = list(15,15)

	if(src.welded)
		. = list(stop,start)
	else
		. = list(start,stop)

/obj/machinery/door/airlock/attack_hand(mob/user)
	var/valid_tool_found = FALSE
	if(length(user.equipped_list()))
		for(var/obj/item/I in user.equipped_list())
			if(issnippingtool(I) || ispulsingtool(I) || istype(I, /obj/item/device/radio/signaler))
				valid_tool_found = TRUE

	if (!issilicon(user))
		if (src.isElectrified())
			if (src.shock(user, 100))
				interact_particle(user,src)
				return
	else if (src.aiControlDisabled == 1 || src.cant_emag)
		return

	if (ishuman(user) && src.density && src.brainloss_stumble && src.do_brainstumble(user) == 1)
		return

	if (src.panel_open && valid_tool_found)
		ui_interact(user)
		interact_particle(user,src)

	//clicking with no access, door closed, and help intent to knock
	else if (!src.allowed(user) && (user.a_intent == INTENT_HELP) && src.density && src.requiresID())
		knockOnDoor(user)
		return //Opening the door just because knocks are on cooldown is rude!
	else
		..(user)
	return

/obj/machinery/door/airlock/attackby(obj/item/C, mob/user)
	//boutput(world, text("airlock attackby src [] obj [] mob []", src, C, user))

	src.add_fingerprint(user)
	if (istype(C, /obj/item/device/t_scanner) || (istype(C, /obj/item/device/pda2) && istype(C:module, /obj/item/device/pda_module/tray)))
		if(src.isElectrified())
			boutput(user, "<span class='alert'>[bicon(C)] <b>WARNING</b>: Abnormal electrical response received from access panel.</span>")
		else
			if(src.status & NOPOWER)
				boutput(user, "<span class='alert'>[bicon(C)] No electrical response received from access panel.</span>")
			else
				boutput(user, "<span class='notice'>[bicon(C)] Regular electrical response received from access panel.</span>")
		return

	if (!issilicon(user) && (BOUNDS_DIST(src, user) == 0))
		if (src.isElectrified())
			if(src.shock(user, 75))
				return

	if (!C)
		..()
		return

	if ((isweldingtool(C) && !( src.operating ) && src.density))
		if (src.hardened)
			boutput(user, "<span class='alert'>Your tool is unable to weld this airlock! Huh.</span>")
			return
		if(!C:try_weld(user, 1, burn_eyes = 1))
			return

		var/positions = src.get_welding_positions(user)

		actions.start(new /datum/action/bar/private/welding(user, src, 2 SECONDS, /obj/machinery/door/airlock/proc/weld_action, \
			list(user), null, positions[1], positions[2]),user)

		if (src.health < src.health_max)
			src.heal_damage()
			boutput(user, "<span class='notice'>Your repair the damage to [src].</span>")

		return
	else if (isscrewingtool(C))
		if (src.hardened)
			boutput(user, "<span class='alert'>Your tool can't pierce this airlock! Huh.</span>")
			return
		if (!src.has_panel)
			boutput(user, "<span class='alert'>[src] does not have a panel for you to unscrew!</span>")
			return
		src.panel_open = !(src.panel_open)
		tgui_process.update_uis(src)
		src.UpdateIcon()
	else if (issnippingtool(C) && src.panel_open)
		return src.Attackhand(user)
	else if (ispulsingtool(C))
		return src.Attackhand(user)
	else if (istype(C, /obj/item/device/radio/signaler))
		return src.Attackhand(user)
	else if (ispryingtool(C))
		src.unpowered_open_close()
	else
		..()
	return

/obj/machinery/door/airlock/proc/weld_action(mob/user)
	if(!src.density)
		return
	if (!src.welded)
		src.welded = 1
		logTheThing(LOG_STATION, user, "welded [name] shut at [log_loc(user)].")
		user.unlock_medal("Lock Block", 1)
	else
		logTheThing(LOG_STATION, user, "un-welded [name] at [log_loc(user)].")
		src.welded = null
	src.UpdateIcon()

/obj/machinery/door/airlock/proc/unpowered_open_close()
	if (!src || !istype(src))
		return

	if ((src.density) && (!( src.welded ) && !( src.operating ) && ((!src.arePowerSystemsOn()) || (src.status & NOPOWER)) && !( src.locked )))
		SPAWN( 0 )
			src.operating = 1
			play_animation("opening")
			src.UpdateIcon(1)

			sleep(src.operation_time)

			src.set_density(0)

			if (!istype(src, /obj/machinery/door/airlock/glass))
				if (ignore_light_or_cam_opacity)
					src.set_opacity(0)
				else
					src.RL_SetOpacity(0)
			src.operating = 0
			src.UpdateIcon()

	else if ((!src.density) && (!( src.welded ) && !( src.operating ) && !( src.locked )))
		SPAWN( 0 )
			src.operating = 1
			play_animation("closing")
			src.UpdateIcon(1)

			src.set_density(1)
			sleep(1.5 SECONDS)

			if (src.visible)
				if (ignore_light_or_cam_opacity)
					src.set_opacity(1)
				else
					src.RL_SetOpacity(1)
			src.operating = 0
			src.UpdateIcon()

	else if (src.operating == -1) //broken
		boutput(usr, "<span class='alert'>You try to pry [src]  [src.density ? "open" : "closed"], but it won't budge! It seems completely broken!</span>")

	else if (src.welded)
		boutput(usr, "<span class='alert'>You try to pry [src]  open, but it won't budge! The sides of \the [src] seem to be welded.</span>")

	else if (src.locked)
		boutput(usr, "<span class='alert'>You try to pry [src]  open, but it won't budge! The bolts of \the [src] must be disabled first.</span>")

	else if (src.arePowerSystemsOn())
		boutput(usr, "<span class='alert'>You try to pry [src]  open, but it won't budge! The power of \the [src] must be disabled first.</span>")

	if(!ON_COOLDOWN(src, "prying_sound", 1.5 SECONDS))
		playsound(src, 'sound/machines/airlock_pry.ogg', 35, 1)

	return

/obj/machinery/door/airlock/open()
	if (src.welded || src.locked || src.operating == 1 || (!src.arePowerSystemsOn()) || (src.status & NOPOWER) || src.isWireCut(AIRLOCK_WIRE_OPEN_DOOR))
		return 0
	src.use_power(50)
	if (src.linked_forcefield)
		src.use_power(100)
	.= ..()

	if (narrator_mode)
		playsound(src.loc, 'sound/vox/door.ogg', 25, 1)
	else
		playsound(src.loc, src.sound_airlock, 25, 1)

	if (src.closeOther != null && istype(src.closeOther, /obj/machinery/door/airlock/) && !src.closeOther.density)
		src.closeOther.close(1)

/obj/machinery/door/airlock/close()
	//split into two sets of checks so failures to close due to lacking power will cause linked shields to deactivate
	if ((!src.arePowerSystemsOn()) || (src.status & NOPOWER) || src.isWireCut(AIRLOCK_WIRE_OPEN_DOOR))
		if (src.linked_forcefield)
			src.linked_forcefield.setactive(0)
		return
	if (src.welded || src.locked || src.operating)
		return
	src.use_power(50)

	if(!..(!src.safety))
		if (narrator_mode)
			playsound(src.loc, 'sound/vox/door.ogg', 25, 1)
		else
			if (src.sound_close_airlock)
				playsound(src.loc, src.sound_close_airlock, 25, 1)
			else
				playsound(src.loc, src.sound_airlock, 25, 1)

	return

/obj/machinery/door/airlock/New()
	..()
	src.net_id = generate_net_id(src)
	if (src.id_tag)
		src.id_tag = ckeyEx(src.id_tag)

	if (src.closeOtherId != null)
		src.closeOtherId = ckeyEx(src.closeOtherId)
		SPAWN(0.5 SECONDS)
			for_by_tcl(A, /obj/machinery/door/airlock)
				if (A.closeOtherId == src.closeOtherId && A != src)
					src.closeOther = A
					break

/obj/machinery/door/airlock/isblocked()
	if(src.density && ((src.status & NOPOWER) || src.welded || src.locked || (src.operating == -1) ))
		return 1
	return 0

/obj/machinery/door/airlock/autoclose()
	if(!src.welded)
		close(0, 1)
	else
		..()
	return

// This code allows for airlocks to be controlled externally by setting an id_tag and comm frequency (disables ID access)
obj/machinery/door/airlock
	var/id_tag
	var/frequency = FREQ_AIRLOCK
	var/last_update_time = 0
	var/last_radio_login = 0
	mats = 18


	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption)
			return

		if(lowertext(signal.data["sender"]) == src.net_id)
			return

		if (lowertext(signal.data["address_1"]) != src.net_id)
			if (lowertext(signal.data["address_1"]) == "ping")
				var/datum/signal/pingsignal = get_free_signal()
				pingsignal.source = src
				pingsignal.data["device"] = "DOR_AIRLOCK"
				pingsignal.data["netid"] = src.net_id
				pingsignal.data["sender"] = src.net_id
				pingsignal.data["address_1"] = signal.data["sender"]
				pingsignal.data["command"] = "ping_reply"

				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pingsignal, radiorange)
				return

			else if (!id_tag || id_tag != signal.data["tag"])
				return

		if (signal.data["command"] && signal.data["command"] == "help")
			var/datum/signal/reply = get_free_signal()
			reply.source = src
			reply.data["sender"] = src.net_id
			reply.data["address_1"] = signal.data["sender"]
			if (!signal.data["topic"])
				reply.data["description"] = "Airlock - requires an access code that can be found on the maintenance panel"
				reply.data["topics"] = "open,close,lock,unlock,secure_close,secure_open"
			else
				reply.data["topic"] = signal.data["topic"]
				switch (lowertext(signal.data["topic"]))
					if ("open")
						reply.data["description"] = "Opens the airlock. Requires access code"
						reply.data["args"] = "access_code"
					if ("close")
						reply.data["description"] = "Closes the airlock. Requires access code"
						reply.data["args"] = "access_code"
					if ("lock")
						reply.data["description"] = "Drops the airlocks bolts, securing it in place. Requires access code"
						reply.data["args"] = "access_code"
					if ("unlock")
						reply.data["description"] = "Lifts the airlocks bolts, unsecuring it. Requires access code"
						reply.data["args"] = "access_code"
					if ("secure_close")
						reply.data["description"] = "Closes the airlock and drops the bolts, securing it closed. Requires access code"
						reply.data["args"] = "access_code"
					if ("secure_open")
						reply.data["description"] = "Opens the airlock and drops the bolts, securing it open. Requires access code"
						reply.data["args"] = "access_code"
					else
						reply.data["description"] = "ERROR: UNKNOWN TOPIC"
			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, reply, radiorange)
			return

		var/sent_code = text2num_safe(signal.data["access_code"])
		if (src.aiControlDisabled > 0 || src.cant_emag || sent_code != src.net_access_code)
			if(prob(20))
				src.play_deny()
			if(signal.data["command"] && signal.data["command"] == "nack")
				return
			var/datum/signal/rejectsignal = get_free_signal()
			rejectsignal.source = src
			rejectsignal.data["address_1"] = signal.data["sender"]
			rejectsignal.data["command"] = "nack"
			rejectsignal.data["data"] = "badpass"
			rejectsignal.data["sender"] = src.net_id

			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, rejectsignal, radiorange)
			return

		if (!signal.data["command"])
			return

		var/senderid = signal.data["sender"]
		switch( lowertext(signal.data["command"]) )
			if("open")
				SPAWN(0)
					open(1)
					send_status(,senderid)

			if("close")
				SPAWN(0)
					close(1)
					send_status(,senderid)

			if("unlock")
				locked = 0
				src.UpdateIcon()
				send_status(,senderid)

			if("lock")
				locked = 1
				src.UpdateIcon()
				send_status()

			if("secure_open")
				SPAWN(0)
					locked = 0
					src.UpdateIcon()

					sleep(0.5 SECONDS)
					open(1)

					locked = 1
					src.UpdateIcon()
					sleep(src.operation_time)
					send_status(,senderid)

			if("secure_close")
				SPAWN(0)
					locked = 0
					close(1)

					locked = 1
					sleep(0.5 SECONDS)
					src.UpdateIcon()
					sleep(src.operation_time)
					send_status(,senderid)

	proc/send_status(userid,target)
		var/datum/signal/signal = get_free_signal()
		signal.source = src
		if (id_tag)
			signal.data["tag"] = id_tag
		signal.data["sender"] = net_id
		signal.data["timestamp"] = "[air_master.current_cycle]"
		signal.data["address_tag"] = "airlock_listener" // prevents other doors from receiving this packet unnecessarily

		if (userid)
			signal.data["user_id"] = "[userid]"
		if (target)
			signal.data["address_1"] = target
		signal.data["door_status"] = density?("closed"):("open")
		signal.data["lock_status"] = locked?("locked"):("unlocked")

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, radiorange)

	proc/send_packet(userid,target,message) //For unique conditions like a rejection message instead of overall src.status
		if(message)
			var/datum/signal/signal = get_free_signal()
			signal.source = src
			if (id_tag)
				signal.data["tag"] = id_tag
			signal.data["sender"] = net_id
			signal.data["timestamp"] = "[air_master.current_cycle]"

			if (userid)
				signal.data["user_id"] = "[userid]"
			if (target)
				signal.data["address_1"] = target
			signal.data["address_tag"] = "door" // prevents other doors from receiving this packet unnecessarily

			signal.data["data"] = "[message]"

			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, radiorange)

	open(surpress_send)
		. = ..()
		if(!surpress_send && (src.last_update_time + 100 < ticker.round_elapsed_ticks))
			var/user_name = "???"
			if (issilicon(usr))
				user_name = "AI"
			else if (ishuman(usr))
				var/mob/living/carbon/human/C = usr
				var/obj/item/card/id/card = C.equipped()
				if (istype(card) && card.registered)
					user_name = card.registered

				else if (C.wear_id && C.wear_id:registered)
					user_name = C.wear_id:registered

			send_status(user_name)
			src.last_update_time = ticker.round_elapsed_ticks

	close(surpress_send, is_auto = 0)
		. = ..()
		if(!surpress_send && (src.last_update_time + 100 < ticker.round_elapsed_ticks))
			var/user_name = "???"
			if (issilicon(usr))
				user_name = "AI"
			else if (ishuman(usr))
				var/mob/living/carbon/human/C = usr
				var/obj/item/card/id/card = C.equipped()
				if (istype(card) && card.registered)
					user_name = card.registered

				else if (C.wear_id && C.wear_id:registered)
					user_name = C.wear_id:registered

			send_status(user_name)
			src.last_update_time = ticker.round_elapsed_ticks

	allowed(mob/living/carbon/human/user)
		. = ..()
		if (!. && user && (src.last_update_time + 100 < ticker.round_elapsed_ticks))
			var/user_name = "???"
			if (issilicon(user))
				user_name = "AI"
			else if (istype(user))
				var/obj/item/card/id/card = user.equipped()
				if (istype(card) && card.registered)
					user_name = card.registered

				else if (user.wear_id && user.wear_id:registered)
					user_name = user.wear_id:registered

			SPAWN(0)
				send_packet(user_name, ,"denied")
			src.last_update_time = ticker.round_elapsed_ticks

	initialize()
		..()
		src.UpdateIcon()

	New()
		..()
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, frequency)

/obj/machinery/door/airlock/emp_act()
	..()
	if (prob(20) && (src.density && src.cant_emag != 1 && src.isblocked() != 1))
		src.open()
		src.operating = -1
	if(prob(40))
		if(src.secondsElectrified == 0)
			src.secondsElectrified = -1
			SPAWN(30 SECONDS)
				src.secondsElectrified = 0
	return

/obj/machinery/door/airlock/emag_act(mob/user, obj/item/card/emag/E)
	. = ..()
	if(src.welded && !src.locked)
		audible_message("<span class='alert'>[src] lets out a loud whirring and grinding noise!</span>")
		animate_shake(src, 5, 2, 2, src.pixel_x, src.pixel_y)
		playsound(src, 'sound/items/mining_drill.ogg', 25, 1, 0, 0.8)
		src.take_damage(src.health * 0.8)

/obj/machinery/door/airlock/receive_silicon_hotkey(var/mob/user)
	..()

	if (!isAI(user) && !issilicon(user))
		return

	if (src.aiControlDisabled == 1) return

	if (user.client.check_key(KEY_OPEN) && user.client.check_key(KEY_BOLT))
		. = 1
		// need to do it in the right order or nothing will happen
		if (locked)
			src.toggle_bolt(user)
			src.user_toggle_open(user)
		else
			src.user_toggle_open(user)
			src.toggle_bolt(user)
		return

	else if (user.client.check_key(KEY_OPEN))
		. = 1
		src.user_toggle_open(user)
		return

	else if (user.client.check_key(KEY_BOLT))
		. = 1
		src.toggle_bolt(user)
		return

	else if (user.client.check_key(KEY_SHOCK))
		. = 1
		//electrify door for 30 seconds
		if (src.secondsElectrified!=0)
			src.shock_restore(user)
		else
			if(!src.arePowerSystemsOn() || (src.status & NOPOWER))
				boutput(user, "The door has no power - you can't electrify it.")
				return

			while (user.client.check_key(KEY_SHOCK))
				sleep(0.2 SECONDS) // num seems to work fine

			if (tgui_alert(user, "Are you sure? Electricity might harm a human!", "Electrification Confirmation", list("Yes", "No")) == "Yes")
				src.shock_temp(user)

/obj/machinery/door/airlock/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Airlock", name)
		ui.open()
	return TRUE

/obj/machinery/door/airlock/ui_data(mob/user)
	. = list(
		"userStates" = list(
			"distance" = GET_DIST(src, user),
			"isBorg" = ishivebot(user) || isrobot(user),
			"isAi" = isAI(user),
			"isCarbon" = iscarbon(user),
		),
		"panelOpen" = src.panel_open,

		"mainTimeLeft" = secondsMainPowerLost,
		"backupTimeLeft" = src.secondsBackupPowerLost,
		"shockTimeLeft" = src.secondsElectrified,

		"idScanner" = !src.aiDisabledIdScanner,
		"boltsAreUp" = !src.locked,		// not bolted
		"welded" = src.welded,						// welded
		"opened" = !density,					// opened
		"safety" = src.safety,

		"canAiControl" = src.canAIControl(),
		"aiHacking" = src.aiHacking,
		"canAiHack" = src.canAIHack(),
		"hackingProgression" = src.hackingProgression,
		"hackMessage" = src.hackMessage,
		"aiControlVar" = src.aiControlDisabled,
		"aiControlDisabled" = src.aiControlDisabled,

		"noPower" = (src.status & NOPOWER),
		"powerIsOn" = src.arePowerSystemsOn() && !(src.status & NOPOWER),
		"accessCode" = src.net_access_code,
		"wires" = list(
			"main_1" = !src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1),
			"main_2" = !src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2),
			"backup_1" = !src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1),
			"backup_2" = !src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2),
			"shock" = !src.isWireCut(AIRLOCK_WIRE_ELECTRIFY),
			"idScanner" = !src.isWireCut(AIRLOCK_WIRE_IDSCAN),
			"bolts" = !src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS),
			"safe" = !src.isWireCut(AIRLOCK_WIRE_SAFETY),
		),
	)

	if(src.signalers)
		. += list("signalers" = src.signalers)

	var/list/wire_states = list()
	for(var/I in src.wire_colors)
		wire_states += src.isWireCut(airlockWireColorToIndex[src.wire_colors[I]])
	. += list("wireStates" = wire_states)

/obj/machinery/door/airlock/proc/aidoor_access_check(mob/user)
	if (src.status & (NOPOWER | POWEROFF))
		return UI_UPDATE

/obj/machinery/door/airlock/ui_act(action, params)
	. = ..()
	if (.)
		return
	if(src.arePowerSystemsOn() && (ishivebot(usr) || isrobot(usr) || isAI(usr)))
		switch(action)
			if("hackAirlock")
				if (src.canAIHack() && !src.aiHacking)
					src.hack(usr)
					. = TRUE
	if(src.arePowerSystemsOn() && src.canAIControl() && (ishivebot(usr) || isrobot(usr) || isAI(usr)))
		switch(action)
			if("disruptMain")
				if(!secondsMainPowerLost)
					loseMainPower()
					src.UpdateIcon()
					. = TRUE
				else
					boutput(usr, "<span class='alert'>Main power is already offline.</span>")
				. = TRUE
			if("disruptBackup")
				if(!src.secondsBackupPowerLost)
					src.loseBackupPower()
					src.UpdateIcon()
					. = TRUE
				else
					boutput(usr, "<span class='alert'>Backup power is already offline.</span>")
				. = TRUE
			if("shockRestore")
				src.shock_restore(usr)
				. = TRUE
			if("shockTemp")
				src.shock_temp(usr)
				. = TRUE
			if("shockPerm")
				src.shock_perm(usr)
				. = TRUE
			if("idScanToggle")
				src.idscantoggle(usr)
				. = TRUE
			if("boltToggle")
				src.toggle_bolt(usr)
				. = TRUE
			if("openClose")
				src.user_toggle_open(usr)
				. = TRUE
	if(src.panel_open && BOUNDS_DIST(src, usr) == 0 && !isAI(usr))
		switch(action)
			if("cut")
				var/which_wire = params["wireColorIndex"]
				if(isnum(which_wire))
					src.try_cut(which_wire+1, usr)
					. = TRUE
			if("mend")
				var/which_wire = params["wireColorIndex"]
				if(isnum(which_wire))
					src.try_mend(which_wire+1, usr)
					. = TRUE
			if("pulse")
				var/which_wire = params["wireColorIndex"]
				if(isnum(which_wire))
					src.try_pulse(which_wire+1, usr)
					. = TRUE
			if("signaler")
				var/which_wire = params["wireColorIndex"]
				if(isnum(which_wire))
					if(src.signalers[which_wire+1])
						src.detach_signaler(which_wire+1, usr)
						. = TRUE
					else
						src.attach_signaler(which_wire+1, usr)
						. = TRUE

#undef NET_ACCESS_OPTIONS
