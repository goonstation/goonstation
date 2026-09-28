/obj/item/remote/nuke_summon_remote
	name = "Nuclear Bomb Teleporter Remote"
	icon = 'icons/obj/items/device.dmi'
	desc = "A single-use teleporter remote that summons the nuclear bomb to the user's current location."
	icon_state = "bomb_remote"
	w_class = W_CLASS_SMALL

	var/charges = 1
	var/use_sound = 'sound/machines/chime.ogg'

/obj/item/remote/nuke_summon_remote/attack_self(mob/user)
	if (src.charges < 1)
		boutput(user, SPAN_ALERT("The [src] is out of charge and can't be used again!"))
		return

	if (!istrainedsyndie(user))
		boutput(user, SPAN_ALERT("The [src] beeps angrily!"))
		return

	var/turf/T = get_turf(user)
	if (T.z != Z_LEVEL_STATION)
		boutput(user, SPAN_ALERT("You cannot summon the bomb here!"))
		return

	var/obj/machinery/nuclearbomb/bomb = src.try_to_find_the_nuke()
	if (isnull(bomb))
		boutput(user, SPAN_ALERT("No teleportation target found!"))
		return

	if (bomb.anchored)
		boutput(user, SPAN_ALERT("\The [bomb] is currently secured to the floor and cannot be teleported."))
		return

	src.tele_the_bomb(user, bomb)

/obj/item/remote/nuke_summon_remote/proc/try_to_find_the_nuke()
	var/obj/machinery/nuclearbomb/the_bomb = astype(ticker.mode, /datum/game_mode/nuclear)?.the_bomb
	if (!isnull(the_bomb))
		return the_bomb

	for_by_tcl(bomb, /obj/machinery/nuclearbomb)
		return bomb

/obj/item/remote/nuke_summon_remote/proc/tele_the_bomb(mob/user, obj/machinery/nuclearbomb/bomb)
	global.showswirl(bomb)
	bomb.set_loc(get_turf(src))
	global.showswirl(src)

	src.visible_message(SPAN_ALERT("[user] has summoned the [bomb]!"))
	src.charges -= 1
	playsound(src.loc, use_sound, 70, 1)
