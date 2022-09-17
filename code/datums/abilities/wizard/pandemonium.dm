/datum/targetable/spell/pandemonium
	name = "Pandemonium"
	desc = "Calls upon spirits of chaos to summon unpredictable effects."
	icon_state = "pandemonium"
	targeted = 0
	cooldown = 400
	requires_robes = 1
	offensive = 1
	voice_grim = 'sound/voice/wizard/PandemoniumGrim.ogg'
	voice_fem = 'sound/voice/wizard/PandemoniumFem.ogg'
	voice_other = 'sound/voice/wizard/PandemoniumLoud.ogg'
	maptext_colors = list("#FF0000", "#00FF00", "#FFFF00", "#0000FF", "#00FFFF", "#FF00FF")

	cast()
		if(!holder)
			return
		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("WARR LEHFUQUE", FALSE, maptext_style, maptext_colors)
		..()

		var/list/available_effects = list("babel", "boost", "roar", "signaljam", "grilles", "meteors")

		var/protectuser = 1
		if (!holder.owner.wizard_spellpower(src))
			boutput(holder.owner, "<span class='alert'>Without your staff to focus your spell, it may backfire!</span>")
			protectuser = 0

		var/people_in_range = 0
		for (var/mob/living/carbon/M in range(7, holder.owner))
			if (M == holder.owner)
				continue
			people_in_range++

		if (people_in_range)
			available_effects += "fireburst"
			available_effects += "tripballs"
			available_effects += "flashbang"
			available_effects += "screech"

		var/string_of_effects = " "
		for (var/X in available_effects)
			string_of_effects += "[X] "

		var/mob/living/carbon/human/W = holder.owner
		var/spell_result = ""

		switch(pick(available_effects))
			if("fireburst")
				spell_result = "fireburst"
				W.visible_message("<span class='alert'><B>[W]</B> radiates a wave of burning heat!</span>")
				playsound(W, 'sound/effects/bamf.ogg', 80, 1)
				for (var/mob/living/carbon/human/H in range(6, W))
					if ((H == W) && protectuser)
						continue
					if (targetSpellImmunity(H, FALSE, 0))
						continue
					boutput(H, "<span class='alert'>You suddenly burst into flames!</span>")
					H.update_burning(30)
			if("babel")
				spell_result = "babel accents"
				W.visible_message("<span class='alert'><B>[W]</B> emits a faint smell of cheese!</span>")
				playsound(W, 'sound/voice/farts/superfart.ogg', 80, 1)
				for (var/mob/living/carbon/human/H in mobs)
					if ((H == W) && protectuser)
						continue
					if (targetSpellImmunity(H, FALSE, 0))
						continue
					H.bioHolder.AddEffect("accent_swedish", timeleft = 15)
					H.bioHolder.AddEffect("accent_comic", timeleft = 15)
					H.bioHolder.AddEffect("accent_elvis", timeleft = 15)
					H.bioHolder.AddEffect("accent_chav", timeleft = 15)
			if("tripballs")
				spell_result = "hallucinogenic aura"
				W.visible_message("<span class='alert'><B>[W]</B> radiates a confusing aura!</span>")
				playsound(W, 'sound/effects/bionic_sound.ogg', 80, 1)
				for (var/mob/living/carbon/human/H in range(25, W))
					if ((H == W) && protectuser)
						continue
					if (targetSpellImmunity(H, FALSE, 0))
						continue
					boutput(H, "<span class='alert'>You feel extremely strange!</span>")
					H.reagents.add_reagent("LSD", 20)
					H.reagents.add_reagent("THC", 20)
					H.reagents.add_reagent("psilocybin", 20)
			if("flashbang")
				spell_result = "flashbang"
				W.visible_message("<span class='alert'><B>[W]</B> explodes into a brilliant flash of light!</span>")
				playsound(W.loc, 'sound/weapons/flashbang.ogg', 50, 1)
				for(var/mob/M in AIviewers(W, null))
					if(GET_DIST(M, W) <= 6)
						if(M != W)
							if (targetSpellImmunity(M, FALSE, 0))
								continue
							M.apply_flash(30, 5)
							if(M.client)
								shake_camera(M, 6, 16)
			if("meteors")
				spell_result = "meteors"
				W.visible_message("<span class='alert'><B>[W]</B> summons meteors!</span>")
				for(var/turf/T in orange(1, W))
					if(!T.density)
						var/target_dir = get_dir(W.loc, T)
						var/turf/U = get_edge_target_turf(W, target_dir)
						new /obj/newmeteor/small(my_spawn = T, trg = U)
			if("screech")
				spell_result = "screech"
				W.audible_message("<span class='alert'><B>[W]</B> emits a horrible shriek!</span>")
				playsound(W.loc, 'sound/effects/screech.ogg', 50, 1, -1)
				for (var/mob/living/M in hearers(W, null))
					if ((M == W) && protectuser)
						continue
					if (targetSpellImmunity(M, FALSE, 2))
						continue
					if (isvampire(M) && M.check_vampire_power(3) == 1)
						M.show_text("You are immune to [W]'s screech!", "blue")
						continue
					M.apply_sonic_stun(0, 3, 0, 0, 0, 8)
				sonic_attack_environmental_effect(W, 7, list("light", "window", "r_window"))
			if("boost")
				spell_result = "arcane boost"
				W.audible_message("<span class='alert'><B>[W]</B> glows with magical power!</span>")
				playsound(W.loc, 'sound/mksounds/boost.ogg', 25, 1, -1)
				W.bioHolder.AddEffect("arcane_power", timeleft = 60)
			if("roar")
				spell_result = "roar"
				W.audible_message("<span class='alert'><B>[W]</B> emits a horrific reverberating roar!</span>")
				playsound_global(world, 'sound/effects/mag_pandroar.ogg', 50)
				for (var/mob/living/carbon/human/H in mobs)
					if ((H == W) && protectuser)
						continue
					if (targetSpellImmunity(H, FALSE, 0))
						continue
					boutput(H, "<span class='alert'>A horrifying noise stuns you in sheer terror!</span>")
					H.changeStatus("stunned", 3 SECONDS)
					H.stuttering += 10
			if("signaljam")
				spell_result = "signal loss"
				W.visible_message("<span class='alert'><B>[W]</B> emits a wave of electrical interference!</span>")
				playsound(W.loc, 'sound/effects/mag_warp.ogg', 25, 1, -1)
				for (var/client/C)
					if (!ishuman(C.mob))
						continue
					var/mob/living/carbon/human/H = C.mob
					if (H.ears) boutput(H, "<span class='alert'>Your headset speaker suddenly bursts into weird static!</span>")
				signal_loss += 100
				SPAWN(10 SECONDS)
					signal_loss -= 100
			if("grilles")
				spell_result = "metal grilles"
				W.visible_message("<span class='alert'><B>[W]</B> reshapes the metal around [him_or_her(W)]!</span>")
				playsound(W.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 25, 1, -1)
				for(var/turf/simulated/floor/T in view(W,7))
					if (prob(33))
						new /obj/grille/steel(T)
		logTheThing(LOG_COMBAT, W, "'s Pandemonium caused a [spell_result] effect at [log_loc(W)].")
