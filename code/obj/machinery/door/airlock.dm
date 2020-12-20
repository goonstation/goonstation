#define AIRLOCK_WIRE_IDSCAN 1
#define AIRLOCK_WIRE_MAIN_POWER1 2
#define AIRLOCK_WIRE_MAIN_POWER2 3
#define AIRLOCK_WIRE_DOOR_BOLTS 4
#define AIRLOCK_WIRE_BACKUP_POWER1 5
#define AIRLOCK_WIRE_BACKUP_POWER2 6
#define AIRLOCK_WIRE_OPEN_DOOR 7
#define AIRLOCK_WIRE_AI_CONTROL 8
#define AIRLOCK_WIRE_ELECTRIFY 9
#define AIRLOCK_WIRE_SAFETY 10

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
	arePowerSystemsOn - 1 if the main or backup power are functioning, 0 if not. Does not check whether the power grid is charged or an APC has equipment on or anything like that. (Check (status & NOPOWER) for that)
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
	if(!src.arePowerSystemsOn() || (status & NOPOWER))
		boutput(user, "The door has no power - you can't electrify it.")
		return
	if (src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
		boutput(usr, text("<span class='alert'>The electrification wire has been cut.<br><br></span>"))
	else if (src.secondsElectrified==-1)
		boutput(usr, text("<span class='alert'>The door is already indefinitely electrified. You'd have to un-electrify it before you can re-electrify it with a non-forever duration.<br><br></span>"))
	else if (src.secondsElectrified!=0)
		boutput(usr, text("<span class='alert'>The door is already electrified. You can't re-electrify it while it's already electrified.<br><br></span>"))
	else
		src.secondsElectrified = 30
		logTheThing("combat", usr, null, "electrified airlock ([src]) at [log_loc(src)] for 30 seconds.")
		message_admins("[key_name(usr)] electrified airlock ([src]) at [log_loc(src)] for 30 seconds.")
		SPAWN_DBG(1 SECOND)
			while (src.secondsElectrified>0)
				src.secondsElectrified-=1
				if (src.secondsElectrified<0)
					src.secondsElectrified = 0
				sleep(1 SECOND)

/obj/machinery/door/airlock/proc/toggle_bolt(mob/user)
	if (src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
		boutput(usr, "<span class='alert'>You can't drop the door bolts - The door bolt dropping wire has been cut.</span>")
		return
	if(!src.arePowerSystemsOn() || (status & NOPOWER))
		boutput(user, "<span class='alert'>The door has no power - you can't raise/lower the door bolts.</span>")
		return
	if(src.locked)
		src.locked = 0
		update_icon()
	else
		logTheThing("station",user,null,"[user] has bolted a door at [log_loc(src)].")
		src.locked = 1
		update_icon()

/obj/machinery/door/airlock/proc/shock_perm(mob/user)
	if(!src.arePowerSystemsOn() || (status & NOPOWER))
		boutput(user, "<span class='alert'>The door has no power - you can't electrify it.</span>")
		return
	//electrify door indefinitely
	if (src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
		boutput(usr, text("<span class='alert'>The electrification wire has been cut.<br><br></span>"))
	else if (src.secondsElectrified==-1)
		boutput(usr, text("<span class='alert'>The door is already indefinitely electrified.<br><br></span>"))
	else if (src.secondsElectrified!=0)
		boutput(usr, text("<span class='alert'>The door is already electrified. You can't re-electrify it while it's already electrified.<br><br></span>"))
	else
		logTheThing("combat", usr, null, "electrified airlock ([src]) at [log_loc(src)] indefinitely.")
		message_admins("[key_name(usr)] electrified airlock ([src]) at [log_loc(src)] indefinitely.")
		src.secondsElectrified = -1

/obj/machinery/door/airlock/proc/shock_restore(mob/user)
	//un-electrify door
	if(!src.arePowerSystemsOn() || (status & NOPOWER))
		boutput(user, "The door has no power - you can't electrify it.")
		return
	if (src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
		boutput(usr, text("<span class='alert'>Can't un-electrify the airlock - The electrification wire is cut.<br><br></span>"))
	else if (src.secondsElectrified!=0)
		src.secondsElectrified = 0
		logTheThing("combat", usr, null, "de-electrified airlock ([src]) at [log_loc(src)].")
		message_admins("[key_name(usr)] de-electrified airlock ([src]) at [log_loc(src)].")


/obj/machinery/door/airlock/proc/idscantoggle(mob/user)
	if(!src.arePowerSystemsOn() || (status & NOPOWER))
		boutput(user, "<span class='alert'>The door has no power - you toggle the ID scanner.</span>")
		return
	//enable/disable ID scanner
	if (src.isWireCut(AIRLOCK_WIRE_IDSCAN))
		boutput(usr, "The IdScan wire has been cut - So, you can't disable it, but it is already disabled anyways.")
	else
		aiDisabledIdScanner = !aiDisabledIdScanner


/obj/machinery/door/airlock/proc/user_toggle_open(mob/user)
	if (src.operating == 1)
		return
	if((!src.arePowerSystemsOn()) || (status & NOPOWER) || src.isWireCut(AIRLOCK_WIRE_OPEN_DOOR))
		boutput(user, "<span class='alert'>The door has no power - you can't open/close it.</span>")
		return
	if(welded)
		boutput(usr, text("<span class='alert'>The airlock has been welded shut!</span>"))
	else if(locked)
		boutput(usr, text("<span class='alert'>The door bolts are down!</span>"))
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
	icon = 'icons/obj/doors/doorint.dmi'
	icon_state = "door_closed"

	deconstruct_flags = DECON_ACCESS | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_SCREWDRIVER | DECON_MULTITOOL
	object_flags = BOTS_DIRBLOCK | CAN_REPROGRAM_ACCESS

	var/image/panel_image = null
	var/panel_icon_state = "panel_open"

	var/image/welded_image = null
	var/welded_icon_state = "welded"

	explosion_resistance = 2
	health = 1200
	health_max = 1200

	var/ai_no_access = 0 //This is the dumbest var.
	var/aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/secondsMainPowerLost = 0 //The number of seconds until power is restored.
	var/secondsBackupPowerLost = 0 //The number of seconds until power is restored.
	var/spawnPowerRestoreRunning = 0
	var/welded = null
	var/wires = 1023 //goddd use bitflag defines please
	var/list/wire_colors = list("Orange" = 1, "Pink" = 2, "White" = 3, "Yellow" = 4, "Red" = 5, "Blue" = 6, "Green" = 7, "Grey" = 8, "Olive" = 9, "Teal" = 10)
	secondsElectrified = 0 //How many seconds remain until the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/aiDisabledIdScanner = 0
	var/aiHacking = 0
	var/obj/machinery/door/airlock/closeOther = null
	var/closeOtherId = null
	var/list/signalers[10]
	var/lockdownbyai = 0
	var/last_bump = 0
	var/net_id = null
	var/sound_airlock = 'sound/machines/airlock_swoosh_temp.ogg'
	var/sound_close_airlock = null
	sound_deny = 'sound/machines/airlock_deny.ogg'
	var/sound_deny_temp = 'sound/machines/airlock_deny_temp.ogg'
	var/id = null
	var/radiorange = AIRLOCK_CONTROL_RANGE
	var/safety = 1
	var/hackingProgression = 0
	var/HTML = null
	var/has_panel = 1
	var/hackMessage = ""
	var/net_access_code = null

	var/no_access = 0

	autoclose = 1
	power_usage = 50
	operation_time = 6
	brainloss_stumble = 1

	New()
		..()
		if(!isrestrictedz(src.z))
			var/area/station/A = get_area(src)
			src.name = A.name
		src.net_access_code = rand(1, NET_ACCESS_OPTIONS)
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING


/obj/machinery/door/airlock/check_access(obj/item/I)
	if (no_access) //nope :)
		return 0
	.= ..()

/obj/machinery/door/airlock/command
	icon = 'icons/obj/doors/Doorcom.dmi'
	req_access = list(access_heads)

/obj/machinery/door/airlock/security
	icon = 'icons/obj/doors/Doorsec.dmi'
	req_access = list(access_security)

/obj/machinery/door/airlock/engineering
	name = "Engineering"
	icon = 'icons/obj/doors/Dooreng.dmi'
	req_access = list(access_engineering)

/obj/machinery/door/airlock/medical
	icon = 'icons/obj/doors/doormed.dmi'
	req_access = list(access_medical)

/obj/machinery/door/airlock/maintenance
	name = "Maintenance Access"
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
	cant_emag = 1
	hardened = 1
	aiControlDisabled = 1
	object_flags = BOTS_DIRBLOCK

	meteorhit()
		return

	ex_act()
		return

/obj/machinery/door/airlock/centcom
	icon = 'icons/obj/doors/Doorcom.dmi'
	req_access_txt = "57"
	cant_emag = 1
	hardened = 1
	aiControlDisabled = 1
	object_flags = BOTS_DIRBLOCK

	meteorhit()
		return

	ex_act()
		return

/obj/machinery/door/airlock/glass
	name = "glass airlock"
	icon = 'icons/obj/doors/Doorglass.dmi'
	opacity = 0
	visible = 0

/obj/machinery/door/airlock/glass/command
		icon = 'icons/obj/doors/Doorcom-glass.dmi'
		req_access = list(access_heads)

/obj/machinery/door/airlock/glass/engineering
		icon = 'icons/obj/doors/Dooreng-glass.dmi'
		req_access = list(access_engineering)

/obj/machinery/door/airlock/glass/medical
		icon = 'icons/obj/doors/Doormed-glass.dmi'
		req_access = list(access_medical)

/obj/machinery/door/airlock/classic
	icon = 'icons/obj/doors/Doorclassic.dmi'
	sound_airlock = 'sound/machines/airlock.ogg'
	operation_time = 10

/obj/machinery/door/airlock/pyro
	name = "airlock"
	icon = 'icons/obj/doors/SL_doors.dmi'
	icon_state = "generic_closed"
	icon_base = "generic"
	panel_icon_state = "panel_open"
	welded_icon_state = "welded"
	flags = FPRINT | IS_PERSPECTIVE_FLUID | ALWAYS_SOLID_FLUID

/obj/machinery/door/airlock/pyro/alt
	icon_state = "generic2_closed"
	icon_base = "generic2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"

/obj/machinery/door/airlock/pyro/command
	name = "Command"
	icon_state = "com_closed"
	icon_base = "com"
	req_access = list(access_heads)
	health = 1600
	health_max = 1600

/obj/machinery/door/airlock/pyro/command/alt
	icon_state = "com2_closed"
	icon_base = "com2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	req_access = null

/obj/machinery/door/airlock/pyro/command/syndicate
	req_access = list(access_syndicate_commander)

/obj/machinery/door/airlock/pyro/weapons
	icon_state = "manta_closed"
	icon_base = "manta"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	req_access = null
	hardened = 1
	aiControlDisabled = 1

/obj/machinery/door/airlock/pyro/weapons/noemag
	req_access = null
	cant_emag = 1




/obj/machinery/door/airlock/pyro/security
	name = "Security"
	icon_state = "sec_closed"
	icon_base = "sec"
	req_access = list(access_security)

/obj/machinery/door/airlock/pyro/security/alt
	icon_state = "sec2_closed"
	icon_base = "sec2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	req_access = null

/obj/machinery/door/airlock/pyro/engineering
	name = "Engineering"
	icon_state = "eng_closed"
	icon_base = "eng"
	req_access = list(access_engineering)

/obj/machinery/door/airlock/pyro/engineering/alt
	icon_state = "eng2_closed"
	icon_base = "eng2"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	req_access = null

/obj/machinery/door/airlock/pyro/medical
	icon_state = "research_closed"
	icon_base = "research"
	req_access = list(access_medical)

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
	icon_state = "mining_closed"
	icon_base = "mining"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	req_access = null

/obj/machinery/door/airlock/pyro/maintenance
	name = "maintenance access"
	icon_state = "maint_closed"
	icon_base = "maint"
	req_access = list(access_maint_tunnels)

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

/obj/machinery/door/airlock/pyro/syndicate
	name = "reinforced external airlock"
	desc = "Looks pretty tough. I wouldn't take this door on in a fight."
	icon_state = "airlock_closed"
	icon_base = "airlock"
	panel_icon_state = "airlock_panel_open"
	welded_icon_state = "airlock_welded"
	sound_airlock = 'sound/machines/airlock.ogg'
	operation_time = 10
	req_access_txt = "52"
	cant_emag = 1
	hardened = 1
	aiControlDisabled = 1

	meteorhit()
		return
	ex_act()
		return

/obj/machinery/door/airlock/pyro/glass
	name = "glass airlock"
	icon_state = "glass_closed"
	icon_base = "glass"
	panel_icon_state = "glass_panel_open"
	welded_icon_state = "glass_welded"
	opacity = 0
	visible = 0

/obj/machinery/door/airlock/pyro/glass/brig
	req_access_txt = "2"

/obj/machinery/door/airlock/pyro/glass/command
	icon_state = "com_glass_closed"
	icon_base = "com_glass"
	req_access = list(access_heads)

/obj/machinery/door/airlock/pyro/glass/engineering
	icon_state = "eng_glass_closed"
	icon_base = "eng_glass"
	req_access = list(access_engineering)

/obj/machinery/door/airlock/pyro/glass/security //Shitty Azungar recolor, no need to thank me.
	icon_state = "sec_glass_closed"
	icon_base = "sec_glass"
	req_access = list(access_security)

/obj/machinery/door/airlock/pyro/glass/med
	icon_state = "med_glass_closed"
	icon_base = "med_glass"
	req_access = null

/obj/machinery/door/airlock/pyro/glass/sci
	icon_state = "sci_glass_closed"
	icon_base = "sci_glass"
	req_access = null

/obj/machinery/door/airlock/pyro/glass/toxins
	icon_state = "toxins_glass_closed"
	icon_base = "toxins_glass"
	req_access = null

/obj/machinery/door/airlock/pyro/glass/mining
	icon_state = "mining_glass_closed"
	icon_base = "mining_glass"
	req_access = null

/obj/machinery/door/airlock/pyro/glass/botany
	icon_state = "botany_glass_closed"
	icon_base = "botany_glass"
	req_access = null

/obj/machinery/door/airlock/pyro/classic
	icon_state = "old_closed"
	icon_base = "old"
	panel_icon_state = "old_panel_open"
	welded_icon_state = "old_welded"
	sound_airlock = 'sound/machines/airlock.ogg'
	operation_time = 10

/obj/machinery/door/airlock/pyro/glass/windoor
	icon_state = "windoor_closed"
	icon_base = "windoor"
	panel_icon_state = "windoor"
	welded_icon_state = "fdoor_weld"
	sound_airlock = 'sound/machines/windowdoor.ogg'
	has_panel = 0
	has_crush = 0
	layer = 3.5

	bumpopen(mob/user as mob)
		if (src.density)
			src.autoclose = 1
		..(user)

	attack_hand(mob/user as mob)
		if (src.density)
			src.autoclose = 0
		..(user)

/obj/machinery/door/airlock/pyro/glass/windoor/alt
	icon_state = "windoor2_closed"
	icon_base = "windoor2"
	panel_icon_state = "windoor2"
	welded_icon_state = "windoor2_weld"
	sound_airlock = 'sound/machines/windowdoor.ogg'
	has_panel = 0
	has_crush = 0
	layer = 3.5

/obj/machinery/door/airlock/pyro/sci_alt
	icon_state = "sci_closed"
	icon_base = "sci"
	panel_icon_state = "2_panel_open"
	welded_icon_state = "2_welded"
	req_access = null

/obj/machinery/door/airlock/pyro/toxins_alt
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
		icon_state = "com_closed"
		icon_base = "com"
		req_access = list(access_heads)

	command/alt
		icon_state = "fcom_closed"
		icon_base = "fcom"
		welded_icon_state = "fcom_welded"

	security
		icon_state = "sec_closed"
		icon_base = "sec"
		req_access = list(access_security)

	security/alt
		icon_state = "fsec_closed"
		icon_base = "fsec"
		welded_icon_state = "fsec_welded"

	engineering
		icon_state = "eng_closed"
		icon_base = "eng"
		req_access = list(access_engineering)

	engineering/alt
		icon_state = "feng_closed"
		icon_base = "feng"
		welded_icon_state = "feng_welded"

	medical
		icon_state = "med_closed"
		icon_base = "med"
		req_access = list(access_medical)

	medical/alt
		icon_state = "fmed_closed"
		icon_base = "fmed"
		welded_icon_state = "fmed_welded"

	morgue
		icon_state = "morg_closed"
		icon_base = "morg"
		req_access = list(access_morgue)

	morgue/alt
		icon_state = "fmorg_closed"
		icon_base = "fmorg"
		welded_icon_state = "fmorg_welded"

	chemistry
		icon_state = "chem_closed"
		icon_base = "chem"
		req_access = list(access_research)

	chemistry/alt
		icon_state = "fchem_closed"
		icon_base = "fchem"
		welded_icon_state = "fchem_welded"

	toxins
		icon_state = "tox_closed"
		icon_base = "tox"
		req_access = list(access_research)

	toxins/alt
		icon_state = "ftox_closed"
		icon_base = "ftox"
		welded_icon_state = "ftox_welded"

	maintenance
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
		icon_state = "tcom_closed"
		icon_base = "tcom"
		req_access = list(access_heads)

	command/alt
		icon_state = "tfcom_closed"
		icon_base = "tfcom"
		welded_icon_state = "fcom_welded"

	security
		icon_state = "tsec_closed"
		icon_base = "tsec"
		req_access = list(access_security)

	security/alt
		icon_state = "tfsec_closed"
		icon_base = "tfsec"
		welded_icon_state = "fsec_welded"

	engineering
		icon_state = "teng_closed"
		icon_base = "teng"
		req_access = list(access_engineering)

	engineering/alt
		icon_state = "tfeng_closed"
		icon_base = "tfeng"
		welded_icon_state = "feng_welded"

	medical
		icon_state = "tmed_closed"
		icon_base = "tmed"
		req_access = list(access_medical)

	medical/alt
		icon_state = "tfmed_closed"
		icon_base = "tfmed"
		welded_icon_state = "fmed_welded"

	morgue
		icon_state = "tmorg_closed"
		icon_base = "tmorg"
		req_access = list(access_morgue)

	morgue/alt
		icon_state = "tfmorg_closed"
		icon_base = "tfmorg"
		welded_icon_state = "fmorg_welded"

	chemistry
		icon_state = "tchem_closed"
		icon_base = "tchem"
		req_access = list(access_research)

	chemistry/alt
		icon_state = "tfchem_closed"
		icon_base = "tfchem"
		welded_icon_state = "fchem_welded"

	toxins
		icon_state = "ttox_closed"
		icon_base = "ttox"
		req_access = list(access_research)

	toxins/alt
		icon_state = "tftox_closed"
		icon_base = "tftox"
		welded_icon_state = "ftox_welded"

	maintenance
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
	playsound(get_turf(src), src.sound_deny_temp, 100, 0)

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
			if ((src.arePowerSystemsOn()) && (!(status & NOPOWER)))
				play_deny()
		if (AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
			//Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter).
			src.loseMainPower()
			SPAWN_DBG(1 DECI SECOND)
				src.shock(usr, 25)
		if (AIRLOCK_WIRE_DOOR_BOLTS)
			//one wire for door bolts. Sending a pulse through this drops door bolts if they're not down (whether power's on or not),
			//raises them if they are down (only if power's on)
			if (!src.locked)
				src.locked = 1
				logTheThing("station",usr,null,"[usr] has bolted a door at [log_loc(src)].")
				boutput(usr, "You hear a click from the bottom of the door.")
				tgui_process.update_uis(src)
			else
				if(src.arePowerSystemsOn()) //only can raise bolts if power's on
					src.locked = 0
				boutput(usr, "You hear a click from inside the door.")
			update_icon()
			SPAWN_DBG(1 DECI SECOND)
				src.shock(usr, 25)

		if (AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
			//two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter).
			src.loseBackupPower()
			SPAWN_DBG(1 DECI SECOND)
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
			SPAWN_DBG(1 SECOND)
				if (src.aiControlDisabled == 1)
					src.aiControlDisabled = 0
				else if (src.aiControlDisabled == 2)
					src.aiControlDisabled = -1
				src.updateDialog()
				tgui_process.update_uis(src)
			SPAWN_DBG(1 DECI SECOND)
				src.shock(usr, 25)
		if (AIRLOCK_WIRE_ELECTRIFY)
			//one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds.
			if (src.secondsElectrified==0)
				src.secondsElectrified = 30
				logTheThing("station", usr, null, "temporarily electrified an airlock at [log_loc(src)] with a pulse.")
				SPAWN_DBG(1 SECOND)
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
			logTheThing("station", usr, null, "caused an airlock to close and crush at [log_loc(src)] with a pulse.")
			src.safety = 0
			src.close(1)
			src.safety = 1
			SPAWN_DBG(1 DECI SECOND)
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
			SPAWN_DBG(1 DECI SECOND)
				src.shock(usr, 50)
		if (AIRLOCK_WIRE_DOOR_BOLTS)
			//Cutting this wire also drops the door bolts, and mending it does not raise them. (This is what happens now, except there are a lot more wires going to door bolts at present)
			if (src.locked!=1)
				src.locked = 1
				logTheThing("station",usr,null,"[usr] has bolted a door at [log_loc(src)].")
			update_icon()

		if (AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
			//Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
			src.loseBackupPower()
			SPAWN_DBG(1 DECI SECOND)
				src.shock(usr, 50)

		if (AIRLOCK_WIRE_AI_CONTROL)
			//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
			//aiControlDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
			if (src.aiControlDisabled == 0)
				src.aiControlDisabled = 1
			else if (src.aiControlDisabled == -1)
				src.aiControlDisabled = 2
			SPAWN_DBG(1 DECI SECOND)
				src.shock(usr, 25)

		if (AIRLOCK_WIRE_ELECTRIFY)
			//Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted.
			if (src.secondsElectrified != -1)
				logTheThing("station", usr, null, "permanently electrified an airlock at [log_loc(src)] by cutting the shock wire.")
				src.secondsElectrified = -1

		if(AIRLOCK_WIRE_SAFETY)
			logTheThing("station", usr, null, "permanently disabled the safety of an airlock at [log_loc(src)] by cutting the safety wire.")
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
				SPAWN_DBG(1 DECI SECOND)
					src.shock(usr, 50)

		if (AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
			if ((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
				src.regainBackupPower()
				SPAWN_DBG(1 DECI SECOND)
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
			logTheThing("station", usr, null, "re-enabled the safety of an airlock at [log_loc(src)] by mending the safety wire.")
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
	return !(src.isWireCut(AIRLOCK_WIRE_IDSCAN) || aiDisabledIdScanner)

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
		SPAWN_DBG(0)
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
	if(status & NOPOWER)
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

	var/net = get_connection()		// find the powernet of the connected cable

	if(!net)		// cable is unpowered
		return 0


	//if (src.airlockelectrocute(user, net))
		//return 1
	/// cogwerks: unifying this with cabl electrocution
	//var/atom/A = src
	if(src.electrocute(user, prb, net))
		return 1

	else
		return 0

/obj/machinery/door/airlock/proc/airlockelectrocute(mob/user, netnum) // cogwerks - this should be commented out or removed later but i am too tired right now
	//You're probably getting shocked deal w/ it

	if(!netnum)		// unconnected cable is unpowered
		return 0

	var/prot = 1

	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		if(H.gloves && H.gloves.hasProperty("conductivity"))
			var/obj/item/clothing/gloves/G = H.gloves
			prot = G.getProperty("conductivity")

	else if (issilicon(user))
		return 0

	if(prot <= 0.29)		// elec insulted gloves protect completely
		return 0

	//ok you're getting shocked now
	var/datum/powernet/PN			// find the powernet
	if(powernets && powernets.len >= netnum)
		PN = powernets[netnum]

	elecflash(user,power = 2)

	var/shock_damage = 0
	if(PN.avail > 750000)	//someone juiced up the grid enough, people going to die!
		shock_damage = min(rand(70,145),rand(70,145))*prot
	else if(PN.avail > 100000)
		shock_damage = min(rand(35,110),rand(35,110))*prot
	else if(PN.avail > 75000)
		shock_damage = min(rand(30,100),rand(30,100))*prot
	else if(PN.avail > 50000)
		shock_damage = min(rand(25,90),rand(25,90))*prot
	else if(PN.avail > 25000)
		shock_damage = min(rand(20,80),rand(20,80))*prot
	else if(PN.avail > 10000)
		shock_damage = min(rand(20,65),rand(20,65))*prot
	else
		shock_damage = min(rand(20,45),rand(20,45))*prot

//		message_admins("<span class='internal'><B>ADMIN: </B>DEBUG: shock_damage = [shock_damage] PN.avail = [PN.avail] user = [user] netnum = [netnum]</span>")

	if (user.bioHolder.HasEffect("resist_electric") == 2)
		var/healing = 0
		if (shock_damage)
			healing = shock_damage / 3
		user.HealDamage("All", healing, healing)
		user.take_toxin_damage(0 - healing)
		boutput(user, "<span class='notice'>You absorb the electrical shock, healing your body!</span>")
		return
	else if (user.bioHolder.HasEffect("resist_electric") == 1)
		boutput(user, "<span class='notice'>You feel electricity course through you harmlessly!</span>")
		return

	user.TakeDamage(user.hand == 1 ? "l_arm" : "r_arm", 0, shock_damage)
	boutput(user, "<span class='alert'><B>You feel a powerful shock course through your body!</B></span>")
	user.unlock_medal("HIGH VOLTAGE", 1)
	if (isliving(user))
		var/mob/living/L = user
		L.Virus_ShockCure(33)
		L.shock_cyberheart(33)
	sleep(0.1 SECONDS)
	if(user.getStatusDuration("stunned") < shock_damage * 10) user.changeStatus("stunned", shock_damage * 10)
	if(user.getStatusDuration("weakened") < shock_damage * 10) user.changeStatus("weakened", 10 * prot)
	for(var/mob/M in AIviewers(src))
		if(M == user)	continue
		M.show_message("<span class='alert'>[user.name] was shocked by the [src.name]!</span>", 3, "<span class='alert'>You hear a heavy electrical crack</span>", 2)
	return 1

/obj/machinery/door/airlock/update_icon(var/toggling = 0)
	if(toggling ? !density : density)
		if (locked)
			icon_state = "[icon_base]_locked"
		else
			icon_state = "[icon_base]_closed"
		if (p_open)
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
		icon_state = "[icon_base]_open"
	return

/obj/machinery/door/airlock/play_animation(animation)
	switch (animation)
		if ("opening")
			src.update_icon()
			if (p_open)
				flick("o_[icon_base]_opening", src) // there's an issue with the panel overlay not being gone by the time the animation is nearly done but I can't make that stop, despite my best efforts
			else
				flick("[icon_base]_opening", src)
		if ("closing")
			src.update_icon()
			if (p_open)
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
		SPAWN_DBG(2 SECONDS)
			//TODO: Make this take a minute
			boutput(user, "<span class='notice'>Airlock AI control has been blocked. Beginning fault-detection.</span>")
			hackMessage = "Fault Detection..."
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
			hackMessage = "Fault Confirmed..."
			hackingProgression = 2
			tgui_process.update_uis(src)
			sleep(2 SECONDS)
			boutput(user, "<span class='notice'>Attempting to hack into airlock. This may take some time.</span>")
			hackMessage = "Hacking into airlock..."
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
			hackMessage = "Uploading..."
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
			hackMessage = "Transfer complete"
			hackingProgression = 5
			tgui_process.update_uis(src)
			sleep(5 SECONDS)
			//disable blocked control
			src.aiControlDisabled = 2
			boutput(user, "<span class='notice'>Receiving control information from airlock.</span>")
			hackMessage = "Receiving Information"
			hackingProgression = 6
			tgui_process.update_uis(src)
			sleep(1 SECOND)
			hackingProgression = 0
			hackMessage = ""
			tgui_process.update_uis(src)
			//bring up airlock dialog
			src.aiHacking = 0

/obj/machinery/door/airlock/Bumped(atom/AM)
	if(ismob(AM))
		if(world.time - src.last_bump <= 30)
			return

		if (issilicon(AM) && (aiControlDisabled > 0 || cant_emag))
			return

		src.last_bump = world.time
		if (src.isElectrified())
			if(src.shock(AM, 100))
				return
	..()

/obj/machinery/door/airlock/ui_static_data(mob/user)
	var/list/static_data = list()

	static_data["wireColors"] = src.wire_colors
	static_data["netId"] = src.net_id
	static_data["name"] = src.name

	return static_data

/obj/machinery/door/airlock/ui_status(mob/user, datum/ui_state/state)
	return min(
		tgui_default_state.can_use_topic(src, user),
		tgui_not_incapacitated_state.can_use_topic(src, user)
	)


/obj/machinery/door/airlock/attack_hand(mob/user as mob)
	if (!issilicon(user))
		if (src.isElectrified())
			if (src.shock(user, 100))
				interact_particle(user,src)
				return
	else if (aiControlDisabled > 0 || cant_emag)
		return

	if (ishuman(user) && src.density && src.brainloss_stumble && src.do_brainstumble(user) == 1)
		return

	if (src.p_open)
		ui_interact(user)
		interact_particle(user,src)
	//clicking with no access, door closed, and help intent, and panel closed to knock
	else if (!src.allowed(user) && (user.a_intent == INTENT_HELP) && src.density && src.requiresID())
		knockOnDoor(user)
		return //Opening the door just because knocks are on cooldown is rude!
	else
		..(user)
	return

/obj/machinery/door/airlock/attackby(obj/item/C as obj, mob/user as mob)
	//boutput(world, text("airlock attackby src [] obj [] mob []", src, C, user))

	src.add_fingerprint(user)
	if (istype(C, /obj/item/device/t_scanner) || (istype(C, /obj/item/device/pda2) && istype(C:module, /obj/item/device/pda_module/tray)))
		if(src.isElectrified())
			boutput(usr, "<span class='alert'>[bicon(C)] <b>WARNING</b>: Abnormal electrical response received from access panel.</span>")
		else
			if(status & NOPOWER)
				boutput(usr, "<span class='alert'>[bicon(C)] No electrical response received from access panel.</span>")
			else
				boutput(usr, "<span class='notice'>[bicon(C)] Regular electrical response received from access panel.</span>")
		return

	if (!issilicon(usr))
		if (src.isElectrified())
			if(src.shock(user, 75))
				return

	if (!C)
		..()
		return

	if ((isweldingtool(C) && !( src.operating ) && src.density))
		if(!C:try_weld(user, 1, burn_eyes = 1))
			return
		if (!src.welded)
			src.welded = 1
			logTheThing("station", user, null, "welded [name] shut at [log_loc(user)].")
			user.unlock_medal("Lock Block", 1)
		else
			logTheThing("station", user, null, "un-welded [name] at [log_loc(user)].")
			src.welded = null

		if (src.health < src.health_max)
			src.heal_damage()
			boutput(usr, "<span class='notice'>Your repair the damage to [src].</span>")

		src.update_icon()
		return
	else if (isscrewingtool(C))
		if (src.hardened == 1)
			boutput(usr, "<span class='alert'>Your tool can't pierce this airlock! Huh.</span>")
			return
		if (!src.has_panel)
			boutput(usr, "<span class='alert'>[src] does not have a panel for you to unscrew!</span>")
			return
		src.p_open = !(src.p_open)
		tgui_process.update_uis(src)
		src.update_icon()
	else if (issnippingtool(C) && src.p_open)
		return src.attack_hand(user)
	else if (ispulsingtool(C))
		return src.attack_hand(user)
	else if (istype(C, /obj/item/device/radio/signaler))
		return src.attack_hand(user)
	else if (ispryingtool(C))
		src.unpowered_open_close()
	else
		..()
	return

/obj/machinery/door/airlock/proc/unpowered_open_close()
	if (!src || !istype(src))
		return

	if ((src.density) && (!( src.welded ) && !( src.operating ) && ((!src.arePowerSystemsOn()) || (status & NOPOWER)) && !( src.locked )))
		SPAWN_DBG( 0 )
			src.operating = 1
			play_animation("opening")
			update_icon(1)

			sleep(src.operation_time)

			src.set_density(0)

			if (!istype(src, /obj/machinery/door/airlock/glass))
				if (ignore_light_or_cam_opacity)
					src.opacity = 0
				else
					src.RL_SetOpacity(0)
			src.operating = 0

	else if ((!src.density) && (!( src.welded ) && !( src.operating ) && !( src.locked )))
		SPAWN_DBG( 0 )
			src.operating = 1
			play_animation("closing")
			update_icon(1)

			src.set_density(1)
			sleep(1.5 SECONDS)

			if (src.visible)
				if (ignore_light_or_cam_opacity)
					src.opacity = 1
				else
					src.RL_SetOpacity(1)
			src.operating = 0
	else if (src.welded)
		boutput(usr, "<span class='alert'>You try to pry [src]  open, but it won't budge! The sides of \the [src] seem to be welded.</span>")

	else if (src.locked)
		boutput(usr, "<span class='alert'>You try to pry [src]  open, but it won't budge! The bolts of \the [src] must be disabled first.</span>")

	else if (src.arePowerSystemsOn())
		boutput(usr, "<span class='alert'>You try to pry [src]  open, but it won't budge! The power of \the [src] must be disabled first.</span>")

	playsound(src, 'sound/machines/airlock_pry.ogg', 50, 1)

	return

/obj/machinery/door/airlock/open()
	if (src.welded || src.locked || src.operating == 1 || (!src.arePowerSystemsOn()) || (status & NOPOWER) || src.isWireCut(AIRLOCK_WIRE_OPEN_DOOR))
		return 0
	use_power(50)
	if (linked_forcefield)
		use_power(100)
	.= ..()

	if (narrator_mode)
		playsound(src.loc, 'sound/vox/door.ogg', 25, 1)
	else
		playsound(src.loc, src.sound_airlock, 25, 1)

	if (src.closeOther != null && istype(src.closeOther, /obj/machinery/door/airlock/) && !src.closeOther.density)
		src.closeOther.close(1)

/obj/machinery/door/airlock/close()
	if (linked_forcefield) //mbc : this sucks, but I need the forcefield to turn off even if the door is unpowered and can't close.
		linked_forcefield.setactive(0)

	if (src.welded || src.locked || src.operating || (!src.arePowerSystemsOn()) || (status & NOPOWER) || src.isWireCut(AIRLOCK_WIRE_OPEN_DOOR))
		return
	use_power(50)

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
		SPAWN_DBG(0.5 SECONDS)
			for_by_tcl(A, /obj/machinery/door/airlock)
				if (A.closeOtherId == src.closeOtherId && A != src)
					src.closeOther = A
					break

/obj/machinery/door/airlock/isblocked()
	if(src.density && ((status & NOPOWER) || src.welded || src.locked || (src.operating == -1) ))
		return 1
	return 0

/obj/machinery/door/airlock/autoclose()
	if(!welded)
		close(0, 1)
	else
		..()
	return

// This code allows for airlocks to be controlled externally by setting an id_tag and comm frequency (disables ID access)
obj/machinery/door/airlock
	var/id_tag
	var/frequency = 1411
	var/last_update_time = 0
	var/last_radio_login = 0
	mats = 18

	var/datum/radio_frequency/radio_connection

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
				pingsignal.transmission_method = TRANSMISSION_RADIO

				radio_connection.post_signal(src, pingsignal, radiorange)
				return

			else if (!id_tag || id_tag != signal.data["tag"])
				return

		if (signal.data["command"] && signal.data["command"] == "help")
			var/datum/signal/reply = get_free_signal()
			reply.source = src
			reply.transmission_method = TRANSMISSION_RADIO
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
			radio_connection.post_signal(src, reply, radiorange)
			return

		var/sent_code = text2num(signal.data["access_code"])
		if (aiControlDisabled > 0 || cant_emag || sent_code != src.net_access_code)
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
			rejectsignal.transmission_method = TRANSMISSION_RADIO

			radio_connection.post_signal(src, rejectsignal, radiorange)
			return

		if (!signal.data["command"])
			return

		var/senderid = signal.data["sender"]
		switch( lowertext(signal.data["command"]) )
			if("open")
				SPAWN_DBG(0)
					open(1)
					send_status(,senderid)

			if("close")
				SPAWN_DBG(0)
					close(1)
					send_status(,senderid)

			if("unlock")
				locked = 0
				update_icon()
				send_status(,senderid)

			if("lock")
				locked = 1
				update_icon()
				send_status()

			if("secure_open")
				SPAWN_DBG(0)
					locked = 0
					update_icon()

					sleep(0.5 SECONDS)
					open(1)

					locked = 1
					update_icon()
					sleep(src.operation_time)
					send_status(,senderid)

			if("secure_close")
				SPAWN_DBG(0)
					locked = 0
					close(1)

					locked = 1
					sleep(0.5 SECONDS)
					update_icon()
					sleep(src.operation_time)
					send_status(,senderid)

	proc/send_status(userid,target)
		if(radio_connection)
			var/datum/signal/signal = get_free_signal()
			signal.transmission_method = 1 //radio signal
			signal.source = src
			if (id_tag)
				signal.data["tag"] = id_tag
			signal.data["sender"] = net_id
			signal.data["timestamp"] = "[air_master.current_cycle]"

			if (userid)
				signal.data["user_id"] = "[userid]"
			if (target)
				signal.data["address_1"] = target
			signal.data["door_status"] = density?("closed"):("open")
			signal.data["lock_status"] = locked?("locked"):("unlocked")

			radio_connection.post_signal(src, signal, radiorange)

	proc/send_packet(userid,target,message) //For unique conditions like a rejection message instead of overall status
		if(radio_connection && message)
			var/datum/signal/signal = get_free_signal()
			signal.transmission_method = 1 //radio signal
			signal.source = src
			if (id_tag)
				signal.data["tag"] = id_tag
			signal.data["sender"] = net_id
			signal.data["timestamp"] = "[air_master.current_cycle]"

			if (userid)
				signal.data["user_id"] = "[userid]"
			if (target)
				signal.data["address_1"] = target

			signal.data["data"] = "[message]"

			radio_connection.post_signal(src, signal, radiorange)

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

			SPAWN_DBG(0)
				send_packet(user_name, ,"denied")
			src.last_update_time = ticker.round_elapsed_ticks

	proc/set_frequency(new_frequency)
		radio_controller.remove_object(src, "[frequency]")
		if(new_frequency)
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, "[frequency]")

	initialize()
		..()
		if(frequency)
			set_frequency(frequency)

		update_icon()

	New()
		..()

		if(radio_controller)
			set_frequency(frequency)

	disposing()
		if (radio_controller)
			set_frequency(null)
		..()

/obj/machinery/door/airlock/emp_act()
	..()
	if (prob(20) && (src.density && src.cant_emag != 1 && src.isblocked() != 1))
		src.open()
		src.operating = -1
	if(prob(40))
		if(src.secondsElectrified == 0)
			src.secondsElectrified = -1
			SPAWN_DBG(30 SECONDS)
				src.secondsElectrified = 0
	return

/obj/machinery/door/airlock/receive_silicon_hotkey(var/mob/user)
	..()

	if (!isAI(user) && !issilicon(user))
		return

	if (src.aiControlDisabled) return

	if (user.client.check_key(KEY_OPEN) && user.client.check_key(KEY_BOLT))
		. = 1
		// need to do it in the right order or nothing will happen
		if (locked)
			toggle_bolt(user)
			user_toggle_open(user)
		else
			user_toggle_open(user)
			toggle_bolt(user)
		return

	else if (user.client.check_key(KEY_OPEN))
		. = 1
		user_toggle_open(user)
		return

	else if (user.client.check_key(KEY_BOLT))
		. = 1
		toggle_bolt(user)
		return

	else if (user.client.check_key(KEY_SHOCK))
		. = 1
		//electrify door for 30 seconds
		if (src.secondsElectrified!=0)
			shock_restore(user)
		else
			if(!src.arePowerSystemsOn() || (status & NOPOWER))
				boutput(user, "The door has no power - you can't electrify it.")
				return
			if(alert("Are you sure? Electricity might harm a human!",,"No","Yes") == "Yes") // fix for holding spacebar clicking yes
				shock_temp(user)

/obj/machinery/door/airlock/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Airlock", name)
		ui.open()
	return TRUE

/obj/machinery/door/airlock/ui_data(mob/user)
	. = list(
		"userStates" = list(
			"distance" = get_dist(src, user),
			"isBorg" = ishivebot(user) || isrobot(user),
			"isAi" = isAI(user),
			"isCarbon" = iscarbon(user),
		),
		"panelOpen" = src.p_open,

		"mainTimeLeft" = secondsMainPowerLost,
		"backupTimeLeft" = secondsBackupPowerLost,
		"shockTimeLeft" = secondsElectrified,

		"idScanner" = !aiDisabledIdScanner,
		"boltsAreUp" = !src.locked,		// not bolted
		"welded" = welded,						// welded
		"opened" = !density,					// opened
		"safety" = src.safety,

		"canAiControl" = canAIControl(),
		"aiHacking" = src.aiHacking,
		"canAiHack" = canAIHack(),
		"hackingProgression" = src.hackingProgression,
		"hackMessage" = hackMessage,
		"aiControlVar" = aiControlDisabled,
		"aiControlDisabled" = src.aiControlDisabled,

		"noPower" = (status & NOPOWER),
		"powerIsOn" = src.arePowerSystemsOn() && !(status & NOPOWER),
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
	if (status & (NOPOWER | POWEROFF))
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
	if(src.arePowerSystemsOn() && canAIControl() && (ishivebot(usr) || isrobot(usr) || isAI(usr)))
		switch(action)
			if("disruptMain")
				if(!secondsMainPowerLost)
					loseMainPower()
					update_icon()
					. = TRUE
				else
					boutput(usr, "<span class='alert'>Main power is already offline.</span>")
				. = TRUE
			if("disruptBackup")
				if(!secondsBackupPowerLost)
					loseBackupPower()
					update_icon()
					. = TRUE
				else
					boutput(usr, "<span class='alert'>Backup power is already offline.</span>")
				. = TRUE
			if("shockRestore")
				shock_restore(usr)
				. = TRUE
			if("shockTemp")
				shock_temp(usr)
				. = TRUE
			if("shockPerm")
				shock_perm(usr)
				. = TRUE
			if("idScanToggle")
				idscantoggle(usr)
				. = TRUE
			if("boltToggle")
				toggle_bolt(usr)
				. = TRUE
			if("openClose")
				user_toggle_open(usr)
				. = TRUE
	if(src.p_open && get_dist(src, usr) <= 1 && !isAI(usr))
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
