/obj/item/remote/nuke_summon_remote
	name = "Nuclear Bomb Teleporter Remote"
	icon = 'icons/obj/items/device.dmi'
	desc = "A single-use teleporter remote that summons the nuclear bomb to the user's current location."
	icon_state = "bomb_remote"
	item_state = "electronic"
	density = 0
	anchored = 0.0
	w_class = 2.0

	var/charges = 1
	var/use_sound = "sound/machines/chime.ogg"

	attack_self(mob/user as mob)
		if(charges >= 1)
			var/datum/game_mode/nuclear/mode = ticker.mode
			showswirl(mode.the_bomb)
			mode.the_bomb?.set_loc(get_turf(src))
			showswirl(src)
			src.visible_message("<span class='alert'>[user] has summoned the Nuclear Bomb!</span>")
			src.charges -= 1
			playsound(src.loc, use_sound, 70, 1)
		else
			boutput(user, "<span class='alert'>The [src] is out of charge and can't be used again!</span>")
			return

