/obj/decal/poster/wallsign/accident_sign
	name = "nuclear meltdown tracking sign"
	icon = 'icons/obj/decals/countdown_sign.dmi'
	icon_state = "base"
	desc = "It has been X shifts since the last nuclear meltdown"
	var/shift_count = 0

	New()
		..()
		src.shift_count = min(world.load_intra_round_value("nuclear_accident_count_[map_settings.name]") || 0, 99)
		world.save_intra_round_value("nuclear_accident_count_[map_settings.name]", src.shift_count+1)
		src.UpdateOverlays(image(src.icon, "[round(shift_count/10)]_"), "number10s")
		src.UpdateOverlays(image(src.icon, "_[round(shift_count%10)]"), "number1s")
		src.desc = "It has been [shift_count] shift\s since the last nuclear meltdown."
		switch(src.shift_count)
			if(0)
				src.desc += " Oh no."
			if(1 to 10)
				src.desc += " What a great cleanup job they did!"
			if(11 to 20)
				src.desc += " We're on a streak!"
			if(21 to 40)
				src.desc += " Competent engineers? On <i>my</i> space station?"
			if(41 to 80)
				src.desc += " That's so long!"
			if(81 to 98)
				src.desc += " Well done everybody!"
			if(99 to INFINITY)
				src.desc += " Maybe someone should do something about that..."

	attack_hand(mob/user)
		interact_particle(user, src)
		user.examine_verb(src)
