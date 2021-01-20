/datum/targetable/spell/pandemonium
	name = "Pandemonium"
	desc = "Calls upon spirits of chaos to summon unpredictable effects."
	icon_state = "pandemonium"
	targeted = 0
	cooldown = 400
	requires_robes = 1
	offensive = 1
	voice_grim = "sound/voice/wizard/PandemoniumGrim.ogg"
	voice_fem = "sound/voice/wizard/PandemoniumFem.ogg"
	voice_other = "sound/voice/wizard/PandemoniumLoud.ogg"

	cast()
		if(!holder)
			return
		holder.owner.say("WATT LEHFUQUE")
		..()

		var/list/available_effects = list("babel", "boost", "roar", "signaljam", "grilles", "meteors")

		var/protectuser = 1
		if (!holder.owner.wizard_spellpower(src))
			boutput(holder.owner, "<span class='alert'>Without your staff to focus your spell, it may backfire!</span>")
			protectuser = 0

		var/people_in_range = 0
		for (var/mob/living/carbon/M in range(7, holder.owner))
			if (M == holder.owner) continue
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

		switch(pick(available_effects))
			if("fireburst") W.PAND_Fireburst(protectuser)
			if("babel") W.PAND_Babel(protectuser)
			if("tripballs") W.PAND_Tripballs(protectuser)
			if("flashbang") W.PAND_Flashbang(protectuser)
			if("meteors") W.PAND_Meteors(protectuser)
			if("screech") W.PAND_Screech(protectuser)
			if("boost") W.PAND_Boost(protectuser)
			if("roar") W.PAND_Roar(protectuser)
			if("signaljam") W.PAND_Signaljam(protectuser)
			if("grilles") W.PAND_Grilles(protectuser)

// holy shit someone clean this up and just move it into the main spell proc, this is ridiclous
/mob/living/proc/PAND_Fireburst(var/protectuser = 1)
	for(var/mob/O in AIviewers(src, null)) O.show_message(text("<span class='alert'><B>[]</B> radiates a wave of burning heat!</span>", src), 1)
	playsound(src, "sound/effects/bamf.ogg", 80, 1)
	for (var/mob/living/carbon/human/M in range(6, src))
		if (M == src && protectuser) continue
		if (iswizard(M)) continue
		if(check_target_immunity( M )) continue
		boutput(M, "<span class='alert'>You suddenly burst into flames!</span>")
		M.update_burning(30)

/mob/living/proc/PAND_Babel(var/protectuser = 1)
	for(var/mob/O in AIviewers(src, null)) O.show_message(text("<span class='alert'><B>[]</B> emits a faint smell of cheese!</span>", src), 1)
	playsound(src, "sound/voice/farts/superfart.ogg", 80, 1)
	for (var/mob/living/carbon/human/M in mobs)
		if (M == src && protectuser) continue
		if (ishuman(M))
			if (M.traitHolder.hasTrait("training_chaplain")) continue
		if (iswizard(M)) continue
		if(check_target_immunity( M )) continue
		M.bioHolder.AddEffect("accent_swedish", timeleft = 15)
		M.bioHolder.AddEffect("accent_comic", timeleft = 15)
		M.bioHolder.AddEffect("accent_elvis", timeleft = 15)
		M.bioHolder.AddEffect("accent_chav", timeleft = 15)

/mob/living/proc/PAND_Tripballs(var/protectuser = 1)
	for(var/mob/O in AIviewers(src, null)) O.show_message(text("<span class='alert'><B>[]</B> radiates a confusing aura!</span>", src), 1)
	playsound(src, "sound/effects/bionic_sound.ogg", 80, 1)
	for (var/mob/living/carbon/human/M in range(25, src))
		if (M == src && protectuser) continue
		if (ishuman(M))
			if (M.traitHolder.hasTrait("training_chaplain")) continue
		if (iswizard(M)) continue
		if(check_target_immunity( M )) continue
		boutput(M, "<span class='alert'>You feel extremely strange!</span>")
		M.reagents.add_reagent("LSD", 20)
		M.reagents.add_reagent("THC", 20)
		M.reagents.add_reagent("psilocybin", 20)

/mob/living/proc/PAND_Flashbang(var/protectuser = 1)
	for(var/mob/O in AIviewers(src, null)) O.show_message(text("<span class='alert'><B>[]</B> explodes into a brilliant flash of light!</span>", src), 1)
	playsound(src.loc, "sound/weapons/flashbang.ogg", 50, 1)
	for(var/mob/N in AIviewers(src, null))
		if(get_dist(N, src) <= 6)
			if(N != src)
				if (ishuman(N))
					if (N.traitHolder && N.traitHolder.hasTrait("training_chaplain"))
						continue
				if (iswizard(N))
					continue
				if(check_target_immunity( N )) continue
				N.apply_flash(30, 5)
		if(N.client) shake_camera(N, 6, 16)

/mob/living/proc/PAND_Meteors(var/protectuser = 1)
	for(var/mob/O in AIviewers(src, null)) O.show_message(text("<span class='alert'><B>[]</B> summons meteors!</span>", src), 1)
	for(var/turf/T in orange(1, src))
		if(!T.density)
			var/target_dir = get_dir(src.loc, T)
			var/turf/U = get_edge_target_turf(src, target_dir)
			new /obj/newmeteor/small(my_spawn = T, trg = U)

/mob/living/proc/PAND_Screech(var/protectuser = 1)
	for(var/mob/O in AIviewers(src, null)) O.show_message(text("<span class='alert'><B>[]</B> emits a horrible shriek!</span>", src), 1)
	playsound(src.loc, "sound/effects/screech.ogg", 25, 1, -1)

	for (var/mob/living/H in hearers(src, null))
		if (H == src && protectuser)
			continue
		if (ishuman(H) && H.traitHolder && (H.traitHolder.hasTrait("training_chaplain")))
			H.show_text("You are immune to [src]'s screech!", "blue")
			JOB_XP(H, "Chaplain", 2)
			continue
		if (iswizard(H))
			continue
		if (isvampire(H) && H.check_vampire_power(3) == 1)
			H.show_text("You are immune to [src]'s screech!", "blue")
			continue
		if(check_target_immunity( H )) continue
		H.apply_sonic_stun(0, 3, 0, 0, 0, 8)

	sonic_attack_environmental_effect(src, 7, list("light", "window", "r_window"))
	return

/mob/living/proc/PAND_Boost(var/protectuser = 1)
	for(var/mob/O in AIviewers(src, null)) O.show_message(text("<span class='alert'><B>[]</B> glows with magical power!</span>", src), 1)
	playsound(src.loc, "sound/mksounds/boost.ogg", 25, 1, -1)
	src.bioHolder.AddEffect("arcane_power", timeleft = 60)

/mob/living/proc/PAND_Roar(var/protectuser = 1)
	for(var/mob/O in AIviewers(src, null)) O.show_message(text("<span class='alert'><B>[]</B> emits a horrific reverberating roar!</span>", src), 1)
	world << sound('sound/effects/mag_pandroar.ogg')
	for (var/mob/living/carbon/human/M in mobs)
		if (M == src && protectuser) continue
		if (ishuman(M))
			if (M.traitHolder.hasTrait("training_chaplain")) continue
		if (iswizard(M)) continue
		if(check_target_immunity( M )) continue
		boutput(M, "<span class='alert'>A horrifying noise stuns you in sheer terror!</span>")
		M.changeStatus("stunned", 3 SECONDS)
		M.stuttering += 10

/mob/living/proc/PAND_Signaljam(var/protectuser = 1)//wtf.
	for(var/mob/O in AIviewers(src, null)) O.show_message(text("<span class='alert'><B>[]</B> emits a wave of electrical interference!</span>", src), 1)
	playsound(src.loc, "sound/effects/mag_warp.ogg", 25, 1, -1)
	for (var/client/C)
		if (!ishuman(C.mob))
			continue
		var/mob/living/carbon/human/M = C.mob
		if (M.ears) boutput(M, "<span class='alert'>Your headset speaker suddenly bursts into weird static!</span>")
	signal_loss += 100
	sleep(10 SECONDS)
	signal_loss -= 100

/mob/living/proc/PAND_Grilles(var/protectuser = 1)
	for(var/mob/O in AIviewers(src, null)) O.show_message(text("<span class='alert'><B>[]</B> reshapes the metal around \him!</span>", src), 1)
	playsound(src.loc, "sound/impact_sounds/Metal_Hit_Light_1.ogg", 25, 1, -1)
	for(var/turf/simulated/floor/T in view(src,7))
		if (prob(33)) new /obj/grille/steel(T)
