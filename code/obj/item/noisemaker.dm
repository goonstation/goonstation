/obj/item/noisemaker
	name = "sound synthesizer"
	desc = "Either the most awesome or most annoying thing in the universe, depending on which side of it you're on."
	icon = 'icons/obj/instruments.dmi'
	icon_state = "bike_horn"
	var/mode = "honk"
	var/custom_file = null

	attack_self(var/mob/user as mob)
		if (ON_COOLDOWN(src, "attack_self", 1 SECOND))
			return
		if(custom_file)
			playsound(src.loc, custom_file, 100, 1)
			return
		switch(src.mode)
			if ("honk") playsound(src.loc, 'sound/musical_instruments/Bikehorn_1.ogg', 50, 1)
			if ("fart")
				if (farting_allowed)
					playsound(src.loc, 'sound/voice/farts/poo2_robot.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
			if ("burp") playsound(src.loc, 'sound/voice/burp_alien.ogg', 50, 1)
			if ("squeak") playsound(src.loc, 'sound/misc/clownstep1.ogg', 50, 1)
			if ("cat") playsound(src.loc, 'sound/voice/animal/cat.ogg', 50, 1)
			if ("harmonica")
				var/which = rand(1,3)
				switch(which)
					if(1) playsound(src.loc, 'sound/musical_instruments/Harmonica_1.ogg', 50, 1)
					if(2) playsound(src.loc, 'sound/musical_instruments/Harmonica_2.ogg', 50, 1)
					if(3) playsound(src.loc, 'sound/musical_instruments/Harmonica_3.ogg', 50, 1)
			if ("vuvuzela") playsound(src.loc, 'sound/musical_instruments/Vuvuzela_1.ogg', 45, 1)
			if ("bang") playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 40, 1)
			if ("buzz") playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, 1)
			if ("gunshot") playsound(src.loc, 'sound/weapons/Gunshot.ogg', 50, 1)
			if ("siren") playsound(src.loc, 'sound/machines/siren_police.ogg', 50, 1)
			if ("coo") playsound(src.loc, 'sound/voice/babynoise.ogg', 50, 1)
			if ("rimshot") playsound(src.loc, 'sound/misc/rimshot.ogg', 50, 1)
			if ("trombone") playsound(src.loc, 'sound/musical_instruments/Trombone_Failiure.ogg', 50, 1)
			if ("un1") playsound(src.loc, 'sound/voice/yayyy.ogg', 50, 1)
			if ("un2") playsound(src.loc, 'sound/effects/screech.ogg', 50, 1)
			if ("un3") playsound(src.loc, 'sound/voice/yeaaahhh.ogg', 50, 1)
			else playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 1)

	attack(mob/M, mob/user, def_zone)
		var/newmode = input("Select sound to play", "Make some noise", src.mode) in list("honk", "fart", "burp", "squeak", "cat", "harmonica", "vuvuzela", "bang", "buzz", "gunshot", "siren", "coo", "rimshot", "trombone")

		if (newmode && rand(1,150) == 1)
			boutput(user, "<span class='alert'>BZZZ SOUND SYNTHESISER ERROR</span>")
			boutput(user, "<span class='notice'>Mode is now: ???</span>")
			src.mode = pick("un1","un2","un3")
		else if (newmode)
			boutput(user, "<span class='notice'>Mode is now: [newmode]</span>")
			src.mode = newmode
