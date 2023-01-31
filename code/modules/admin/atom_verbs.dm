
var/global/atom_emergency_stop = 0

/client/proc/cmd_atom_emergency_stop()
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set popup_menu = 0
	set name = "Stop Atom Verbs"
	set desc = "For when someone's used an atom verb and you've found yourself yelling \"Oh god the server is dying STOP SPINNING THINGS AAAAA STOP PLEASE I BEG YOU\""
	ADMIN_ONLY

	if (!atom_emergency_stop)
		atom_emergency_stop = 1
		logTheThing(LOG_ADMIN, usr, "used the emergency stop command for atom verbs.")
		logTheThing(LOG_DIARY, usr, "used the emergency stop command for atom verbs.", "admin")
		message_admins("[key_name(usr)] used the emergency stop command for atom verbs.")
		SPAWN(10 SECONDS) // after 10 seconds, turn it off
			atom_emergency_stop = 0
			message_admins("The emergency stop for atom verbs has turned off again.")
	else
		boutput(usr, "<span class='alert'>The emergency stop for atom verbs is already on!</span>")
		return

/* ----------------- Transmute ------------------ */

/client/proc/cmd_transmute_type()
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set popup_menu = 0
	set name = "Transmute Type"
	set desc = "Transmute all things under the path you specify."
	ADMIN_ONLY

	if (alert(src, "Are you sure you want to transmute everything of a type?", "Confirmation", "Yes", "No") == "Yes")

		var/transmute_thing = input("enter path of the things you want to transmute", "Enter Path", pick("/obj", "/mob", "/turf")) as null|text
		if (!transmute_thing)
			return
		var/transmute_path = get_one_match(transmute_thing, /atom, use_concrete_types = FALSE, only_admin_spawnable = FALSE)
		if (!transmute_path)
			return

		var/amount_to_transmute = input(usr, "amount of things to transmute between each pause", "Amount to Transmute", 500) as null|num
		if (!amount_to_transmute)
			return
		var/sleep_time = input(usr, "amount of time to wait between each batch of stuff (in 10ths of seconds)", "Sleep Time", 2) as null|num
		if (!sleep_time)
			return

		if (!material_cache.len)
			boutput(usr, "<span class='alert'>Error detected in material cache, attempting rebuild. Please try again.</span>")
			buildMaterialCache()
			return
		var/mat = input(usr,"Select Material:","Material",null) in material_cache
		if(!mat)
			return

		logTheThing(LOG_ADMIN, usr, "transmuted all of [transmute_path] into [mat] (details: [amount_to_transmute] things/batch, [sleep_time] sleep time)")
		logTheThing(LOG_DIARY, usr, "transmuted all of [transmute_path] into [mat] (details: [amount_to_transmute] things/batch, [sleep_time] sleep time)", "admin")
		message_admins("[key_name(usr)] began transmuting all of [transmute_path] into [mat]")

		var/transmute = 0
		var/transmute_total = 0

		for (var/atom/A as anything in find_all_by_type(transmute_path))
			if(istype(A, /obj/overlay/tile_effect) || istype(A, /atom/movable/screen))
				continue
			LAGCHECK(LAG_LOW)
			if (atom_emergency_stop)
				logTheThing(LOG_ADMIN, usr, "type transmute command terminated due to an emergency stop.")
				logTheThing(LOG_DIARY, usr, "type transmute command terminated due to an emergency stop.", "admin")
				message_admins("[key_name(usr)]'s type transmute command terminated due to an emergency stop!")
				break
			else
				A.setMaterial(getMaterial(mat), copy = FALSE)
				transmute ++
				transmute_total ++
				if (transmute >= amount_to_transmute)
					transmute = 0
					sleep(sleep_time)

		logTheThing(LOG_ADMIN, usr, "transmuted [transmute_total] of [transmute_path] into [mat].")
		logTheThing(LOG_DIARY, usr, "transmuted [transmute_total] of [transmute_path] into [mat].", "admin")
		message_admins("[key_name(usr)] transmuted [transmute_total] of [transmute_path] into [mat].")
		return

/* -------------------- Emag -------------------- */

/client/proc/cmd_emag_all()
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set popup_menu = 0
	set name = "Emag All"
	set desc = "Emags every atom. Every single one."
	ADMIN_ONLY

	if (alert(src, "Are you sure you want to emag every fucking atom?", "Confirmation", "Yes", "No") == "Yes")

		var/amount_to_emag = input(usr, "amount of things to emag between each pause", "Amount to Emag", 500) as null|num
		if (!amount_to_emag)
			return
		var/sleep_time = input(usr, "amount of time to wait between each batch of stuff (in 10ths of seconds)", "Sleep Time", 2) as null|num
		if (!sleep_time)
			return

		logTheThing(LOG_ADMIN, usr, "emagged every goddamn atom (details: [amount_to_emag] things/batch, [sleep_time] sleep time)")
		logTheThing(LOG_DIARY, usr, "emagged every goddamn atom (details: [amount_to_emag] things/batch, [sleep_time] sleep time)", "admin")
		message_admins("[key_name(usr)] began emagging every goddamn atom")

		var/emagged = 0
		var/emagged_total = 0

		for (var/atom/A in world)
			LAGCHECK(LAG_LOW)
			if (atom_emergency_stop)
				logTheThing(LOG_ADMIN, usr, "emagging command terminated due to an emergency stop.")
				logTheThing(LOG_DIARY, usr, "emagging command terminated due to an emergency stop.", "admin")
				message_admins("[key_name(usr)]'s emagging command terminated due to an emergency stop!")
				break
			else
				if (A.emag_act())
					A.emag_act(null,null)
					emagged ++
					emagged_total ++
					if (emagged >= amount_to_emag)
						emagged = 0
						sleep(sleep_time)

		logTheThing(LOG_ADMIN, usr, "emagged [emagged_total] atoms.")
		logTheThing(LOG_DIARY, usr, "emagged [emagged_total] atoms.", "admin")
		message_admins("[key_name(usr)] emagged [emagged_total] atoms.")
		return

/client/proc/cmd_emag_type()
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set popup_menu = 0
	set name = "Emag Type"
	set desc = "Emag all things under the path you specify."
	ADMIN_ONLY

	if (alert(src, "Are you sure you want to emag everything of a type?", "Confirmation", "Yes", "No") == "Yes")

		var/emag_thing = input("enter path of the things you want to emag", "Enter Path", pick("/obj", "/mob", "/turf")) as null|text
		if (!emag_thing)
			return
		var/emag_path = get_one_match(emag_thing, /atom, use_concrete_types = FALSE, only_admin_spawnable = FALSE)
		if (!emag_path)
			return

		var/amount_to_emag = input(usr, "amount of things to emag between each pause", "Amount to Emag", 500) as null|num
		if (!amount_to_emag)
			return
		var/sleep_time = input(usr, "amount of time to wait between each batch of stuff (in 10ths of seconds)", "Sleep Time", 2) as null|num
		if (!sleep_time)
			return

		logTheThing(LOG_ADMIN, usr, "emagged all of [emag_path] (details: [amount_to_emag] things/batch, [sleep_time] sleep time)")
		logTheThing(LOG_DIARY, usr, "emagged all of [emag_path] (details: [amount_to_emag] things/batch, [sleep_time] sleep time)", "admin")
		message_admins("[key_name(usr)] began emagging all of [emag_path]")

		var/emagged = 0
		var/emagged_total = 0

		for (var/atom/A as anything in find_all_by_type(emag_path))
			LAGCHECK(LAG_LOW)
			if (atom_emergency_stop)
				logTheThing(LOG_ADMIN, usr, "type emagging command terminated due to an emergency stop.")
				logTheThing(LOG_DIARY, usr, "type emagging command terminated due to an emergency stop.", "admin")
				message_admins("[key_name(usr)]'s type emagging command terminated due to an emergency stop!")
				break
			else
				if (A.emag_act())
					A.emag_act(null,null)
					emagged ++
					emagged_total ++
					if (emagged >= amount_to_emag)
						emagged = 0
						sleep(sleep_time)

		logTheThing(LOG_ADMIN, usr, "emagged [emagged_total] of [emag_path].")
		logTheThing(LOG_DIARY, usr, "emagged [emagged_total] of [emag_path].", "admin")
		message_admins("[key_name(usr)] emagged [emagged_total] of [emag_path].")
		return

/client/proc/cmd_emag_target(var/atom/target as mob|obj|turf in world)
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set popup_menu = 0
	set name = "Emag Target"
	set desc = "Emag this thing. Not the other thing like this thing. THIS thing."
	ADMIN_ONLY

	if (!target)
		target = input(usr, "Target", "Target") as null|mob|obj|turf in world
	if (!target)
		return

	if (target?.emag_act())
		target.emag_act(null,null)

		logTheThing(LOG_ADMIN, usr, "emagged [target] via Emag Target ([log_loc(target)] in [target.loc])")
		logTheThing(LOG_DIARY, usr, "emagged [target] via Emag Target ([log_loc(target)] in [target.loc])", "admin")
		message_admins("[key_name(usr)] emagged [target] via Emag Target ([log_loc(target)] in [target.loc])")
	else
		boutput(usr, "<span class='alert'>Could not emag [target]!</span>")
	return

/* -------------------- Scale -------------------- */

/client/proc/cmd_scale_all()
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set popup_menu = 0
	set name = "Scale All"
	set desc = "Scales every atom. Every single one."
	ADMIN_ONLY

	if (alert(src, "Are you sure you want to scale every fucking atom?", "Confirmation", "Yes", "No") == "Yes")

		var/scalex = input(usr, "1 normal, 2 double etc", "X Scale", "1") as null|num
		if (!scalex)
			return
		var/scaley = input(usr, "1 normal, 2 double etc", "Y Scale", "1") as null|num
		if (!scaley)
			return

		var/amount_to_scale = input(usr, "amount of things to scale between each pause", "Amount to Scale", 500) as null|num
		if (!amount_to_scale)
			return
		var/sleep_time = input(usr, "amount of time to wait between each batch of stuff (in 10ths of seconds)", "Sleep Time", 2) as null|num
		if (!sleep_time)
			return

		logTheThing(LOG_ADMIN, usr, "scaled every goddamn atom (details: X:[scalex], Y:[scaley], [amount_to_scale] things/batch, [sleep_time] sleep time)")
		logTheThing(LOG_DIARY, usr, "scaled every goddamn atom (details: X:[scalex], Y:[scaley], [amount_to_scale] things/batch, [sleep_time] sleep time)", "admin")
		message_admins("[key_name(usr)] began scaling every goddamn atom (details: X:[scalex], Y:[scaley], [amount_to_scale] things/batch, [sleep_time] sleep time)")

		var/scaled = 0
		var/scaled_total = 0

		for (var/atom/A in world)
			LAGCHECK(LAG_LOW)
			if (atom_emergency_stop)
				logTheThing(LOG_ADMIN, usr, "scaling command terminated due to an emergency stop.")
				logTheThing(LOG_DIARY, usr, "scaling command terminated due to an emergency stop.", "admin")
				message_admins("[key_name(usr)]'s scaling command terminated due to an emergency stop!")
				break
			else
				A.Scale(scalex, scaley)
				scaled ++
				scaled_total ++
				if (scaled >= amount_to_scale)
					scaled = 0
					sleep(sleep_time)

		logTheThing(LOG_ADMIN, usr, "scaled [scaled_total] atoms.")
		logTheThing(LOG_DIARY, usr, "scaled [scaled_total] atoms.", "admin")
		message_admins("[key_name(usr)] scaled [scaled_total] atoms.")
		return

/client/proc/cmd_scale_type()
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set popup_menu = 0
	set name = "Scale Type"
	set desc = "Scales all things under the path you specify."
	ADMIN_ONLY

	if (alert(src, "Are you sure you want to scale everything of a type?", "Confirmation", "Yes", "No") == "Yes")

		var/scale_thing = input("enter path of the things you want to scale", "Enter Path", pick("/obj", "/mob", "/turf")) as null|text
		if (!scale_thing)
			return
		var/scale_path = get_one_match(scale_thing, /atom, use_concrete_types = FALSE, only_admin_spawnable = FALSE)
		if (!scale_path)
			return

		var/scalex = input(usr, "1 normal, 2 double etc", "X Scale", "1") as null|num
		if (!scalex)
			return
		var/scaley = input(usr, "1 normal, 2 double etc", "Y Scale", "1") as null|num
		if (!scaley)
			return

		var/amount_to_scale = input(usr, "amount of things to scale between each pause", "Amount to Scale", 500) as null|num
		if (!amount_to_scale)
			return
		var/sleep_time = input(usr, "amount of time to wait between each batch of stuff (in 10ths of seconds)", "Sleep Time", 2) as null|num
		if (!sleep_time)
			return

		logTheThing(LOG_ADMIN, usr, "scaled all of [scale_path] (details: X:[scalex], Y:[scaley], [amount_to_scale] things/batch, [sleep_time] sleep time)")
		logTheThing(LOG_DIARY, usr, "scaled all of [scale_path] (details: X:[scalex], Y:[scaley], [amount_to_scale] things/batch, [sleep_time] sleep time)", "admin")
		message_admins("[key_name(usr)] began scaling all of [scale_path] (details: X:[scalex], Y:[scaley], [amount_to_scale] things/batch, [sleep_time] sleep time)")

		var/scaled = 0
		var/scaled_total = 0

		for (var/atom/A as anything in find_all_by_type(scale_path))
			LAGCHECK(LAG_LOW)
			if (atom_emergency_stop)
				logTheThing(LOG_ADMIN, usr, "type scaling command terminated due to an emergency stop.")
				logTheThing(LOG_DIARY, usr, "type scaling command terminated due to an emergency stop.", "admin")
				message_admins("[key_name(usr)]'s type scaling command terminated due to an emergency stop!")
				break
			else
				A.Scale(scalex, scaley)
				scaled ++
				scaled_total ++
				if (scaled >= amount_to_scale)
					scaled = 0
					sleep(sleep_time)

		logTheThing(LOG_ADMIN, usr, "scaled [scaled_total] of [scale_path].")
		logTheThing(LOG_DIARY, usr, "scaled [scaled_total] of [scale_path].", "admin")
		message_admins("[key_name(usr)] scaled [scaled_total] of [scale_path].")
		return

/client/proc/cmd_scale_target(var/atom/target as mob|obj|turf in world)
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set popup_menu = 0
	set name = "Scale Target"
	set desc = "Scales a target."
	ADMIN_ONLY

	if (!target)
		target = input(usr, "Target", "Target") as null|mob|obj|turf in world
	if (!target)
		return

	var/scalex = input(usr,"X Scale","1 normal, 2 double etc","1") as null|num
	if (!scalex)
		return
	var/scaley = input(usr,"Y Scale","1 normal, 2 double etc","1") as null|num
	if (!scaley)
		return

	logTheThing(LOG_ADMIN, usr, "scaled [target] by X:[scalex] Y:[scaley] ([log_loc(target)] in [target.loc])")
	logTheThing(LOG_DIARY, usr, "scaled [target] by X:[scalex] Y:[scaley] ([log_loc(target)] in [target.loc])", "admin")
	message_admins("[key_name(usr)] scaled [target] by X:[scalex] Y:[scaley] ([log_loc(target)] in [target.loc])")

	target.Scale(scalex, scaley)
	return

/* -------------------- Rotate -------------------- */

/client/proc/cmd_rotate_all()
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set popup_menu = 0
	set name = "Rotate All Atoms"
	set desc = "Rotates every atom. Every single one."
	ADMIN_ONLY

	if (alert(src, "Are you sure you want to rotate every fucking atom?", "Confirmation", "Yes", "No") == "Yes")

		var/rot = input(usr, "how many degrees to rotate", "Rotation", "0") as null|num
		if (!rot)
			return

		var/amount_to_rotate = input(usr, "amount of things to rotate between each pause", "Amount to Rotate", 500) as null|num
		if (!amount_to_rotate)
			return
		var/sleep_time = input(usr, "amount of time to wait between each batch of stuff (in 10ths of seconds)", "Sleep Time", 2) as null|num
		if (!sleep_time)
			return

		logTheThing(LOG_ADMIN, usr, "rotated every goddamn atom (details: [rot] rotation, [amount_to_rotate] things/batch, [sleep_time] sleep time)")
		logTheThing(LOG_DIARY, usr, "rotated every goddamn atom (details: [rot] rotation, [amount_to_rotate] things/batch, [sleep_time] sleep time)", "admin")
		message_admins("[key_name(usr)] began rotating every goddamn atom (details: [rot] rotation, [amount_to_rotate] things/batch, [sleep_time] sleep time)")

		var/rotated = 0
		var/rotated_total = 0

		for (var/atom/A in world)
			LAGCHECK(LAG_LOW)
			if (atom_emergency_stop)
				logTheThing(LOG_ADMIN, usr, "rotating command terminated due to an emergency stop.")
				logTheThing(LOG_DIARY, usr, "rotating command terminated due to an emergency stop.", "admin")
				message_admins("[key_name(usr)]'s rotating command terminated due to an emergency stop!")
				break
			else
				A.Turn(rot)
				rotated ++
				rotated_total ++
				if (rotated >= amount_to_rotate)
					rotated = 0
					sleep(sleep_time)

		logTheThing(LOG_ADMIN, usr, "rotated [rotated_total] atoms.")
		logTheThing(LOG_DIARY, usr, "rotated [rotated_total] atoms.", "admin")
		message_admins("[key_name(usr)] rotated [rotated_total] atoms.")
		return

/client/proc/cmd_rotate_type()
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set popup_menu = 0
	set name = "Rotate Type"
	set desc = "Rotates all things under the path you specify."
	ADMIN_ONLY

	if (alert(src, "Are you sure you want to rotate everything of a type?", "Confirmation", "Yes", "No") == "Yes")

		var/rotate_thing = input("enter path of the things you want to rotate", "Enter Path", pick("/obj", "/mob", "/turf")) as null|text
		if (!rotate_thing)
			return
		var/rotate_path = get_one_match(rotate_thing, /atom, use_concrete_types = FALSE, only_admin_spawnable = FALSE)
		if (!rotate_path)
			return

		var/rot = input(usr, "how many degrees to rotate", "Rotation", "0") as null|num
		if (!rot)
			return

		var/amount_to_rotate = input(usr, "amount of things to rotate between each pause", "Amount to Rotate", 500) as null|num
		if (!amount_to_rotate)
			return
		var/sleep_time = input(usr, "amount of time to wait between each batch of stuff (in 10ths of seconds)", "Sleep Time", 2) as null|num
		if (!sleep_time)
			return

		logTheThing(LOG_ADMIN, usr, "rotated all of [rotate_path] (details: [rot] rotation, [amount_to_rotate] things/batch, [sleep_time] sleep time)")
		logTheThing(LOG_DIARY, usr, "rotated all of [rotate_path] (details: [rot] rotation, [amount_to_rotate] things/batch, [sleep_time] sleep time)", "admin")
		message_admins("[key_name(usr)] began rotating all of [rotate_path] (details: [rot] rotation, [amount_to_rotate] things/batch, [sleep_time] sleep time)")

		var/rotated = 0
		var/rotated_total = 0

		for (var/atom/A as anything in find_all_by_type(rotate_path))
			LAGCHECK(LAG_LOW)
			if (atom_emergency_stop)
				logTheThing(LOG_ADMIN, usr, "type rotating command terminated due to an emergency stop.")
				logTheThing(LOG_DIARY, usr, "type rotating command terminated due to an emergency stop.", "admin")
				message_admins("[key_name(usr)]'s type rotating command terminated due to an emergency stop!")
				break
			else
				A.Turn(rot)
				rotated ++
				rotated_total ++
				if (rotated >= amount_to_rotate)
					rotated = 0
					sleep(sleep_time)

		logTheThing(LOG_ADMIN, usr, "rotated [rotated_total] of [rotate_path].")
		logTheThing(LOG_DIARY, usr, "rotated [rotated_total] of [rotate_path].", "admin")
		message_admins("[key_name(usr)] rotated [rotated_total] of [rotate_path].")
		return

/client/proc/cmd_rotate_target(var/atom/target as mob|obj|turf in world)
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set popup_menu = 0
	set name = "Rotate Target"
	set desc = "Rotates a target."
	ADMIN_ONLY

	if (!target)
		target = input(usr, "Target", "Target") as null|mob|obj|turf in world
	if (!target)
		return

	var/rot = input(usr, "how many degrees to rotate", "Rotation", "0") as null|num
	if (!rot)
		return

	logTheThing(LOG_ADMIN, usr, "rotated [target] by [rot] degrees ([log_loc(target)] in [target.loc])")
	logTheThing(LOG_DIARY, usr, "rotated [target] by [rot] degrees ([log_loc(target)] in [target.loc])", "admin")
	message_admins("[key_name(usr)] rotated [target] by [rot] degrees ([log_loc(target)] in [target.loc])")

	target.Turn(rot)
	return

/* -------------------- Spin -------------------- */

/client/proc/cmd_spin_all()
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set popup_menu = 0
	set name = "Spin All"
	set desc = "Spins every atom. Every single one."
	ADMIN_ONLY

	if (alert(src, "Are you sure you want to spin every fucking atom?", "Confirmation", "Yes", "No") == "Yes")

		var/looping = 0

		var/direction = input(usr, "R is clockwise", "Direction", "R") as null|anything in list("R", "L")
		if (!direction)
			return
		var/time = input(usr, "lower numbers are faster", "Animate Time", "1") as null|num
		if (!time)
			return
		var/endless_spins = alert(usr, "endless spins y/n", "Looping?", "No", "Yes")
		if (endless_spins == "Cancel")
			return
		else if (endless_spins == "Yes")
			looping = -1
		else
			looping = 0
		var/amount_to_spin = input(usr, "amount of atoms to spin between each pause", "Amount to Spin", 500) as null|num
		if (!amount_to_spin)
			return
		var/sleep_time = input(usr, "amount of time to wait between each batch of atoms (in 10ths of seconds)", "Sleep Time", 2) as null|num
		if (!sleep_time)
			return

		logTheThing(LOG_ADMIN, usr, "spun every goddamn atom (details: [direction] direction, [time] animate time, [looping] looping, [amount_to_spin] atoms/batch, [sleep_time] sleep time)")
		logTheThing(LOG_DIARY, usr, "spun every goddamn atom (details: [direction] direction, [time] animate time, [looping] looping, [amount_to_spin] atoms/batch, [sleep_time] sleep time)", "admin")
		message_admins("[key_name(usr)] began spinning every goddamn atom (details: [direction] direction, [time] animate time, [looping] looping, [amount_to_spin] atoms/batch, [sleep_time] sleep time)")

		var/spun = 0
		var/spun_total = 0

		for (var/atom/A in world)
			LAGCHECK(LAG_LOW)
			if (atom_emergency_stop)
				logTheThing(LOG_ADMIN, usr, "spinning command terminated due to an emergency stop.")
				logTheThing(LOG_DIARY, usr, "spinning command terminated due to an emergency stop.", "admin")
				message_admins("[key_name(usr)]'s spinning command terminated due to an emergency stop!")
				break
			else
				animate_spin(A, direction, time, looping, FALSE)
				spun ++
				spun_total ++
				if (spun >= amount_to_spin)
					spun = 0
					sleep(sleep_time)

		logTheThing(LOG_ADMIN, usr, "spun [spun_total] atoms.")
		logTheThing(LOG_DIARY, usr, "spun [spun_total] atoms.", "admin")
		message_admins("[key_name(usr)] spun [spun_total] atoms.")
		return

/client/proc/cmd_spin_type()
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set popup_menu = 0
	set name = "Spin Type"
	set desc = "Spins all things under the path you specify."
	ADMIN_ONLY

	if (alert(src, "Are you sure you want to spin everything of a type?", "Confirmation", "Yes", "No") == "Yes")

		var/looping = 0
		// I stole this from Spy's emag_all_of_type() tia Spy ilu <3
		var/spin_thing = input("enter path of the things you want to spin", "Enter Path", pick("/obj", "/mob", "/turf")) as null|text
		if (!spin_thing)
			return
		var/spin_path = get_one_match(spin_thing, /atom, use_concrete_types = FALSE, only_admin_spawnable = FALSE)
		if (!spin_path)
			return

		var/direction = input(usr, "R is clockwise", "Direction", "R") as null|anything in list("R", "L")
		if (!direction)
			return
		var/time = input(usr, "lower numbers are faster", "Animate Time", "1") as null|num
		if (!time)
			return
		var/endless_spins = alert(usr, "endless spins y/n", "Looping?", "No", "Yes")
		if (endless_spins == "Cancel")
			return
		else if (endless_spins == "Yes")
			looping = -1
		else
			looping = 0

		var/amount_to_spin = input(usr, "amount of things to spin between each pause", "Amount to Spin", 500) as null|num
		if (!amount_to_spin)
			return
		var/sleep_time = input(usr, "amount of time to wait between each batch of stuff (in 10ths of seconds)", "Sleep Time", 2) as null|num
		if (!sleep_time)
			return

		logTheThing(LOG_ADMIN, usr, "spun all of [spin_path] (details: [direction] direction, [time] animate time, [looping] looping, [amount_to_spin] things/batch, [sleep_time] sleep time)")
		logTheThing(LOG_DIARY, usr, "spun all of [spin_path] (details: [direction] direction, [time] animate time, [looping] looping, [amount_to_spin] things/batch, [sleep_time] sleep time)", "admin")
		message_admins("[key_name(usr)] began spinning all of [spin_path] (details: [direction] direction, [time] animate time, [looping] looping, [amount_to_spin] things/batch, [sleep_time] sleep time)")

		var/spun = 0
		var/spun_total = 0

		for (var/atom/A as anything in find_all_by_type(spin_path))
			LAGCHECK(LAG_LOW)
			if (atom_emergency_stop)
				logTheThing(LOG_ADMIN, usr, "type spinning command terminated due to an emergency stop.")
				logTheThing(LOG_DIARY, usr, "type spinning command terminated due to an emergency stop.", "admin")
				message_admins("[key_name(usr)]'s type spinning command terminated due to an emergency stop!")
				break
			else
				animate_spin(A, direction, time, looping, FALSE)
				spun ++
				spun_total ++
				if (spun >= amount_to_spin)
					spun = 0
					sleep(sleep_time)

		logTheThing(LOG_ADMIN, usr, "spun [spun_total] of [spin_path].")
		logTheThing(LOG_DIARY, usr, "spun [spun_total] of [spin_path].", "admin")
		message_admins("[key_name(usr)] spun [spun_total] of [spin_path].")
		return

/client/proc/cmd_spin_target(var/atom/target as mob|obj|turf in world)
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set popup_menu = 0
	set name = "Spin Target"
	set desc = "Spins a target."
	ADMIN_ONLY

	if (!target)
		target = input(usr, "Target", "Target") as null|mob|obj|turf in world
	if (!target)
		return
	var/looping = 0
	var/direction = input(usr, "R is clockwise", "Direction", "R") as null|anything in list("R", "L")
	if (!direction)
		return
	var/time = input(usr, "lower numbers are faster", "Animate Time", "1") as null|num
	if (!time)
		return
	var/endless_spins = alert(usr, "endless spins y/n", "Looping?", "No", "Yes", "Cancel")
	if (endless_spins == "Cancel")
		return
	else if (endless_spins == "Yes")
		looping = -1
	else
		looping = 0

	logTheThing(LOG_ADMIN, usr, "spun [target] (details: [direction] direction, [time] animate time, [looping] looping, [log_loc(target)] in [target.loc])")
	logTheThing(LOG_DIARY, usr, "spun [target] (details: [direction] direction, [time] animate time, [looping] looping, [log_loc(target)] in [target.loc]))", "admin")
	message_admins("[key_name(usr)] spun [target] (details: [direction] direction, [time] animate time, [looping] looping, [log_loc(target)] in [target.loc]))")

	animate_spin(target, direction, time, looping, FALSE)
	return

/* -------------------- Get -------------------- */

/client/proc/cmd_get_all()
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set popup_menu = 0
	set name = "Get All"
	set desc = "Gets every object and mob. Every single one. Oh god no."
	ADMIN_ONLY

	if (alert(src, "Are you sure you want to get fucking object and mob and bring it to your tile?", "YOU WILL REGRET THIS", "Yes", "No") == "Yes")

		var/turf/user_location = get_turf(usr)

		var/amount_to_get = input(usr, "amount of things to get between each pause", "Amount to Get", 500) as null|num
		if (!amount_to_get)
			return
		var/sleep_time = input(usr, "amount of time to wait between each batch of stuff (in 10ths of seconds)", "Sleep Time", 2) as null|num
		if (!sleep_time)
			return

		logTheThing(LOG_ADMIN, usr, "teleported every goddamn obj/mob to them (details: [amount_to_get] things/batch, [sleep_time] sleep time)")
		logTheThing(LOG_DIARY, usr, "teleported every goddamn obj/mob to them (details: [amount_to_get] things/batch, [sleep_time] sleep time)", "admin")
		message_admins("[key_name(usr)] began teleporting every goddamn obj/mob to themselves (details: [amount_to_get] things/batch, [sleep_time] sleep time)")

		var/gotten = 0
		var/gotten_total = 0

		for (var/atom/A in world)
			LAGCHECK(LAG_LOW)
			if (atom_emergency_stop)
				logTheThing(LOG_ADMIN, usr, "teleport command terminated due to an emergency stop.")
				logTheThing(LOG_DIARY, usr, "teleport command terminated due to an emergency stop.", "admin")
				message_admins("[key_name(usr)]'s teleport command terminated due to an emergency stop!")
				break
			else
				if (!istype(A, /obj) && !ismob(A))
					continue
				if (istype(A, /atom/movable/screen) || istype(A, /obj/overlay/tile_effect))
					continue
				A:set_loc(user_location)
				gotten ++
				gotten_total ++
				if (gotten >= amount_to_get)
					gotten = 0
					sleep(sleep_time)

		logTheThing(LOG_ADMIN, usr, "teleported [gotten_total] objs/mobs.")
		logTheThing(LOG_DIARY, usr, "teleported [gotten_total] objs/mobs.", "admin")
		message_admins("[key_name(usr)] teleported [gotten_total] objs/mobs.")
		return

/client/proc/cmd_get_type()
	SET_ADMIN_CAT(ADMIN_CAT_ATOM)
	set popup_menu = 0
	set name = "Get Type"
	set desc = "Get all things under the path you specify. Don't give this /turf or /area stuff, it's not going to work."
	ADMIN_ONLY

	if (alert(src, "Are you sure you want to teleport everything of a type to your tile?", "Confirmation", "Yes", "No") == "Yes")

		var/get_thing = input("enter path of the things you want to get", "Enter Path", pick("/obj", "/mob")) as null|text
		if (!get_thing)
			return
		var/get_path = get_one_match(get_thing, /atom/movable, use_concrete_types = FALSE, only_admin_spawnable = FALSE)
		if (!get_path)
			return

		var/turf/user_location = get_turf(usr)

		var/amount_to_get = input(usr, "amount of things to get between each pause", "Amount to Get", 500) as null|num
		if (!amount_to_get)
			return
		var/sleep_time = input(usr, "amount of time to wait between each batch of stuff (in 10ths of seconds)", "Sleep Time", 2) as null|num
		if (!sleep_time)
			return

		logTheThing(LOG_ADMIN, usr, "teleported all of [get_path] to themselves (details: [amount_to_get] things/batch, [sleep_time] sleep time)")
		logTheThing(LOG_DIARY, usr, "teleported all of [get_path] to themselves (details: [amount_to_get] things/batch, [sleep_time] sleep time)", "admin")
		message_admins("[key_name(usr)] began teleporting all of [get_path] to themselves (details: [amount_to_get] things/batch, [sleep_time] sleep time)")

		var/gotten = 0
		var/gotten_total = 0

		for (var/atom/movable/A as anything in find_all_by_type(get_path))
			LAGCHECK(LAG_LOW)
			if (atom_emergency_stop)
				logTheThing(LOG_ADMIN, usr, "teleport command terminated due to an emergency stop.")
				logTheThing(LOG_DIARY, usr, "teleport command terminated due to an emergency stop.", "admin")
				message_admins("[key_name(usr)]'s teleport command terminated due to an emergency stop!")
				break
			else
				if (A == user_location)
					continue
				A.set_loc(user_location)
				gotten ++
				gotten_total ++
				if (gotten >= amount_to_get)
					gotten = 0
					sleep(sleep_time)

		logTheThing(LOG_ADMIN, usr, "teleported [gotten_total] of [get_path].")
		logTheThing(LOG_DIARY, usr, "teleported [gotten_total] of [get_path].", "admin")
		message_admins("[key_name(usr)] teleported [gotten_total] of [get_path].")
		return

// cmd_get_target() isn't needed since we already have get_mobject()
