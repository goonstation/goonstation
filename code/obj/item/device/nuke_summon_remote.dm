/obj/item/remote/nuke_summon_remote
	name = "Nuclear Bomb Teleporter Remote"
	icon = 'icons/obj/items/device.dmi'
	desc = "A one use teleporter remote that summons the nuclear bomb to the user's current location."
	icon_state = "locator"
	item_state = "electronic"
	density = 0
	anchored = 0.0
	w_class = 2.0

	var/uses = 1
	var/sound_firing = 'sound/weapons/energy/howitzer_firing.ogg' //temp

	attack_self(mob/user as mob)
		if(uses >= 1)
			var/datum/game_mode/nuclear/mode = ticker.mode
			showswirl(mode.the_bomb)
			mode.the_bomb?.set_loc(get_turf(src))
			showswirl(src)
			src.visible_message("<span class='alert'>[user] has summoned the Nuclear Bomb!</span>")
			src.uses -= 1
			playsound(src.loc, sound_firing, 70, 1)
		else
			return

