/mob/living/carbon/human/glitchy
	var/list/glitchy_noises = list('sound/machines/romhack1.ogg', 'sound/machines/romhack3.ogg', 'sound/machines/fortune_greeting_broken.ogg',
	'sound/effects/glitchy1.ogg', 'sound/effects/glitchy2.ogg', 'sound/effects/glitchy3.ogg', 'sound/musical_instruments/WeirdHorn_12.ogg')

	New()
		..()
		src.rename_self()
		sound_burp = pick(glitchy_noises)
		sound_scream = pick(glitchy_noises)
		//sound_femalescream = pick(glitchy_noises)
		sound_fart = pick(glitchy_noises)
		sound_snap = pick(glitchy_noises)
		sound_fingersnap = pick(glitchy_noises)
		src.changeStatus("stimulants", 15 MINUTES)
		src.equip_new_if_possible(/obj/item/clothing/shoes/red, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/misc/chaplain, slot_w_uniform)
		bioHolder.mobAppearance.update_colorful_parts()

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (prob(5))
			rename_self()
			for(var/atom/A in range(3,src))
				src.glitch_up(A)

		src.glitch_up(src)

		if (prob(33))
			var/turf/T = get_turf(src)
			src.glitch_up(T)

	bump(atom/movable/AM)
		..()
		src.glitch_up(AM)

	get_age_pitch()
		..()
		return 1.0 + 0.5*(30 - rand(1,120))/80

	proc/rename_self()
		var/assembled_name = pick_string_autokey("names/first_male.txt") + " " + pick_string_autokey("names/last.txt")
		assembled_name = corruptText(assembled_name,75)
		src.real_name = assembled_name

	proc/glitch_up(var/atom/A)
		if (!A || !A.icon)
			return
		A.icon_state = pick(icon_states(A.icon))
		A.name = corruptText(A.name,10)
		A.alpha = rand(100,255)
		A.color = rgb(rand(0,255),rand(0,255),rand(0,255))
		playsound(src, pick(glitchy_noises), 80, 0, 0, src.get_age_pitch())

		switch(rand(1,5))
			if(1)
				animate_glitchy_fuckup1(A)
			if(2)
				animate_glitchy_fuckup2(A)
			if(3)
				animate_glitchy_fuckup3(A)
			if(4)
				animate_rainbow_glow(A)
			else
				animate_spin(A, dir = "R", T = 0.2, looping = -1)
				///proc/animate_spin(var/atom/A, var/dir = "L", var/T = 1, var/looping = -1)
