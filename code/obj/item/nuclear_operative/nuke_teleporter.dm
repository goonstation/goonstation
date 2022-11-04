/obj/item/remote/nuke_summon_remote
	name = "Nuclear Bomb Teleporter Remote"
	icon = 'icons/obj/items/device.dmi'
	desc = "A single-use teleporter remote that summons the nuclear bomb to the user's current location."
	icon_state = "bomb_remote"
	item_state = "electronic"
	w_class = W_CLASS_SMALL

	var/charges = 1
	var/use_sound = 'sound/machines/chime.ogg'
	var/atom/movable/the_bomb = null

/obj/item/remote/nuke_summon_remote/attack_self(mob/user as mob)
	if(charges >= 1)
		var/turf/T = get_turf(user)
		if(isnull(the_bomb))
			try_to_find_the_nuke()
		if(isnull(the_bomb))
			boutput(user, "<span class='alert'>No teleportation target found!</span>")
			return
		if(T.z != Z_LEVEL_STATION)
			boutput(user, "<span class='alert'>You cannot summon the bomb here!</span>")
			return
		if(the_bomb.anchored)
			boutput(user, "<span class='alert'>\The [the_bomb] is currently secured to the floor and cannot be teleported.</span>")
			return
		tele_the_bomb(user)
	else
		boutput(user, "<span class='alert'>The [src] is out of charge and can't be used again!</span>")

/obj/item/remote/nuke_summon_remote/proc/try_to_find_the_nuke()
	if(ticker.mode.type == /datum/game_mode/nuclear)
		var/datum/game_mode/nuclear/mode = ticker.mode
		the_bomb = mode.the_bomb
	if(isnull(the_bomb))
		for_by_tcl(nuke, /obj/machinery/nuclearbomb)
			the_bomb = nuke
			break

/obj/item/remote/nuke_summon_remote/proc/tele_the_bomb(mob/user as mob)
	showswirl(the_bomb)
	the_bomb.set_loc(get_turf(src))
	showswirl(src)
	src.visible_message("<span class='alert'>[user] has summoned the [the_bomb]!</span>")
	src.charges -= 1
	playsound(src.loc, use_sound, 70, 1)
