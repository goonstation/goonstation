/datum/targetable/wraithAbility/fake_sound
	name = "Fake Sound"
	icon_state = "fake_sound"
	desc = "Play a fake sound at a location of your choice."
	pointCost = 5
	targeted = TRUE
	target_anything = TRUE
	cooldown = 4 SECONDS
	var/list/sound_list = list("Death gasp",
	"Gasp",
	"Revolver",
	"AK477",
	"Csaber unsheathe",
	"Csaber attack",
	"Shotgun",
	"Energy sniper",
	"Cluwne",
	"Chainsaw",
	"Stab",
	"Bones breaking",
	"Vampire screech",
	"Brullbar",
	"Werewolf",
	"Gibs")

	cast(atom/target)
		if (..())
			return CAST_ATTEMPT_FAIL_CAST_FAILURE

		var/sound_choice = null
		if (length(src.sound_list) > 1)
			sound_choice = tgui_input_list(holder.owner, "What sound do you wish to play?", "Chosen sound", sound_list)
		switch(sound_choice)
			if("Death gasp")
				sound_choice = "sound/voice/death_[rand(1, 2)].ogg"
			if("Revolver")
				sound_choice = "sound/weapons/Gunshot.ogg"
			if("AK477")
				sound_choice = "sound/weapons/ak47shot.ogg"
				playsound(target, sound_choice, 70, FALSE)
				sleep(2 DECI SECONDS)
				playsound(target, sound_choice, 70, FALSE)
				sleep(2 DECI SECONDS)
				playsound(target, sound_choice, 70, FALSE)
				boutput(holder.owner, "You use your powers to create a sound.")
				return 0
			if("Csaber unsheathe")
				sound_choice = "sound/weapons/male_cswordturnon.ogg"
			if("Csaber attack")
				sound_choice = "sound/weapons/male_cswordattack[rand(1, 2)].ogg"
			if("Shotgun")
				sound_choice = "sound/weapons/shotgunshot.ogg"
			if("Energy sniper")
				sound_choice = "sound/weapons/snipershot.ogg"
			if("Cluwne")
				sound_choice = "sound/voice/cluwnelaugh[rand(1, 3)].ogg"
			if("Gasp")
				sound_choice = pick("sound/voice/gasps/male_gasp_[pick("1", "5")].ogg", "sound/voice/gasps/female_gasp_[pick("1", "5")].ogg")
			if("Chainsaw")
				sound_choice = "sound/machines/chainsaw_red.ogg"
			if("Stab")
				sound_choice = "sound/impact_sounds/Blade_Small_Bloody.ogg"
			if("Bones breaking")
				sound_choice = "sound/effects/bones_break.ogg"
			if("Vampire screech")
				sound_choice = "sound/effects/light_breaker.ogg"
			if("Brullbar")
				sound_choice = "sound/voice/animal/brullbar_scream.ogg"
			if("Werewolf")
				sound_choice = "sound/voice/animal/werewolf_howl.ogg"
			if("Gibs")
				sound_choice = "sound/impact_sounds/Flesh_Break_2.ogg"

		playsound(target, sound_choice, 70)
		boutput(holder.owner, SPAN_NOTICE("You use your powers to create a sound."))
		return CAST_ATTEMPT_SUCCESS
