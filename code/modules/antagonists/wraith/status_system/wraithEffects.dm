/datum/statusEffect/creeping_dread	//Aka fear of the dark
	id = "creeping_dread"
	name = "Creeping dread"
	desc = "The dark is trying to get you! Stay in the light!"
	icon_state = "dread1"
	unique = 1
	duration = 20 SECONDS
	maxDuration = 3 MINUTES
	var/mob/living/carbon/human/H

	onUpdate(var/timePassed)

		var/mult = timePassed / (2 SECONDS)

		if (!ishuman(owner))
			return

		H = owner
		var/turf/local_turf = get_turf(H)
		if (local_turf.RL_GetBrightness() < 0.3)
			duration += timePassed * 2
		if ((duration <= 30 SECONDS))
			if(icon_state != "dread1")
				icon_state = "dread1"
			if(probmult(6))
				switch (rand(1,5))
					if (1)
						H.emote("pale")
					if (2)
						H.emote("shiver")
						boutput(H, pick("The shadows grow colder", "You feel a chill run down your spine"))
					if (3)
						H.emote("scream")
						boutput(H, pick("<span class='alert'>You feel something brush against your arm!<span>", "<span class='alert'>Oh god! Did you see that?!</span>"))
					if (4)
						H.emote("twitch")
						boutput(H, "You hear some clicking noises, akin to an insect.")
					if (5)
						H.emote("twitch_v")
						boutput(H, pick("<span class='alert'>You feel something crawling on your back<span class='alert'>", "<span class='alert'>Something just crawled up your leg!</span>"))
		if ((duration > 30 SECONDS) && (duration < 60 SECONDS))
			if(icon_state != "dread2")
				icon_state = "dread2"
			if(probmult(9))
				switch (rand(1,3))
					if (1)
						H.emote("scream")
						boutput(H, pick("<span class='alert'>The shadows are getting thicker! YOU HAVE TO <b>RUN</b>!<span class='alert'>", "<span class='alert'>You hate it here! Find some light, NOW!"))
					if (2)
						H.emote("flipout")
						boutput(H, "<span class='alert'>You can't stay in the dark! RUN!</span>")
					if (3)
						H.setStatus("stunned", 2 SECONDS)
						H.visible_message("<span class='alert'>[H] flails around wildly, trying to get some invisible things off [himself_or_herself(H)].</span>", "<span class='alert'>You flail around wildly trying to defend yourself from the shadows!</span>")
		if ((duration >= 60 SECONDS) && (duration < 90 SECONDS))
			SPAWN(1 SECOND)
				H.playsound_local(H, "sound/effects/heartbeat.ogg", 50)
			H.make_jittery(30)
			H.setStatus("terror", 30 SECONDS)
			if(icon_state != "dread3")
				icon_state = "dread3"
			if(probmult(12))
				switch (rand(1, 4))
					if (1)
						H.take_brain_damage(10)
						boutput(H, pick("<span class='alert'>YOU CANT THINK IN THE DARK LIKE THIS! FIND SOME LIGHT!</span>", "<span class='alert'>You hate it! ALL OF IT!</span>, <span class='alert'>Your temples pound, you cant think like this!</span>"))
					if (2)
						H.losebreath += 2
						boutput(H, pick("<span class='notice'>You cant control your breathing!</span>", "<span class='notice'>You hyperventilate</span>"))
						H.playsound_local(H, "sound/effects/hyperventstethoscope.ogg", 50)
					if (3)
						H.emote("panic")
						boutput(H, pick("<span class='alert'>THE DARK! STAY OUT OF THE DARK!</span>", "<span class='alert'>What the <b>FUCK</b> was THAT?"))
					if (4)
						random_brute_damage(H, 3)
						H.playsound_local(H, "sound/impact_sounds/Flesh_Tear_[pick("1", "2", "3")].ogg", 70)
						boutput(H, pick("<span class='alert'>SOMETHING BIT YOU, HOLY SHIT!!!</span>"))
		if ((duration >= 90 SECONDS) && (duration < 130 SECONDS))
			SPAWN(5 DECI SECONDS)
				H.playsound_local(H, "sound/effects/heartbeat.ogg", 70)
			H.make_jittery(30)
			H.setStatus("terror", 30 SECONDS)
			if(icon_state != "dread4")
				icon_state = "dread4"
			if(probmult(15))
				switch (rand(1, 4))
					if (1)
						H.take_brain_damage(10)
						boutput(H, pick("<span class='alert'>YOU CANT TAKE IT ANYMORE!!!</span>", "<span class='alert'>This cant be real!</span>", "<span class='alert'>It's ALL LIES! ALL OF IT!</span>"))
					if (2)
						H.emote("scream")
						boutput(H, "<span class='alert'>NO, NO, NO!</span>")
					if (3)
						H.emote("panic")
						boutput(H, pick("<span class='alert'>IT'S RIGHT HERE, YOU JUST CAN'T SEE IT!</span>", "<span class='alert'>IT'S WATCHING YOU, LAUGHING! YOU KNOW IT!</span>"))
					if (4)
						H.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)	//Bad luck
						H.visible_message("<span class='alert'>[H] suddenly clutches their chest with a terrified expression</span>", "<span class='alert'>Your heart is beating out of your chest! You feel like death!</span>")
		if ((duration >= 130 SECONDS))
			H.contract_disease(/datum/ailment/malady/heartfailure,null,null,1)
			H.contract_disease(/datum/ailment/malady/flatline,null,null,1)
			H.visible_message("<span class='alert'>[H]'s face goes blank as they start to collapse to the ground</span>", "<span class='alert'>Your nerves can't take it any longer! Your heart is giving up on you!</span>")
			duration = 60 SECONDS

		for (var/obj/item/device/pda2/P in range(3, H)) //Turn off all nearby pda lights
			if((P.module != null) && istype(P.module, /obj/item/device/pda_module/flashlight))
				var/obj/item/device/pda_module/flashlight/F = P.module
				if (F.on)
					F.toggle_light()

/datum/statusEffect/terror
	id = "terror"
	name = "Terror"
	desc = "terrorized"
	unique = 1
	duration = 40 SECONDS
	maxDuration = 3 MINUTES
	visible = FALSE
	var/mob/living/carbon/human/H
	var/sound_effect = null
	var/illusion_icon = null
	var/illusion_icon_state = null
	var/volume = null
	var/has_faked_armory = FALSE
	var/has_faked_nuke = FALSE
	var/has_faked_shuttle = FALSE
	var/range = 6

	onAdd(optional=null)
		. = ..()
		if (ishuman(owner))
			H = owner
			get_image_group(CLIENT_IMAGE_GROUP_ILLUSSION).add_mob(H)
		else
			owner.delStatus("terror")

	onRemove()
		. = ..()
		H = owner
		get_image_group(CLIENT_IMAGE_GROUP_ILLUSSION).remove_mob(H)

	onUpdate()
		var/mult = 1
		if (probmult(5))
			switch (rand(1,3))
				if (1) // Image based illusion
					var/turf/owner_turf = get_turf(owner)
					if (!owner_turf) return
					var/list/turfs = block(locate(max(owner_turf.x - range, 0), max(owner_turf.y - range, 0), owner_turf.z), locate(min(owner_turf.x + range, world.maxx), min(owner_turf.y + range, world.maxy), owner_turf.z))
					var/list/wall_turfs = list()
					for (var/turf/simulated/wall/wall in turfs)
						wall_turfs += wall
					if (length(wall_turfs))
						var/turf/W = pick(wall_turfs)
						switch(rand(1,3))
							if (1)
								sound_effect = 'sound/effects/Explosion2.ogg'
								illusion_icon = 'icons/effects/64x64.dmi'
								illusion_icon_state = "explo_fiery"
								volume = 45
							if (2)
								sound_effect = 'sound/effects/Explosion2.ogg'
								illusion_icon = 'icons/effects/96x96.dmi'
								illusion_icon_state = "explo_smoky"
								volume = 45
							if (3)
								sound_effect = "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg"
								illusion_icon = 'icons/mob/mob.dmi'
								illusion_icon_state = "wraith"
								volume = 65
						var/image/illusionIcon = image(illusion_icon, W, null, EFFECTS_LAYER_UNDER_4)
						illusionIcon.icon_state = illusion_icon_state
						get_image_group(CLIENT_IMAGE_GROUP_ILLUSSION).add_image(illusionIcon)	//Put the image in a group so the illusion is shared
						if (sound_effect != null)
							H.playsound_local(H.loc,sound_effect, volume, 1)
						sleep(5 SECONDS)
						qdel(illusionIcon)
				if (2) //sound based
					if(prob(90))
						switch(rand(1,8))
							if (1)
								sound_effect = "sound/machines/phones/ring_incoming.ogg"
								volume = 60
							if (2)
								sound_effect = 'sound/effects/explosionfar.ogg'
								volume = 70
								shake_camera(H, 2, 8)
							if (3)
								sound_effect = 'sound/effects/ghostlaugh.ogg'
								volume = 50
							if (3)
								sound_effect = 'sound/effects/light_breaker.ogg'
								volume = 70
							if (4)
								sound_effect = 'sound/weapons/rev_flash_startup.ogg'
								volume = 70
							if (5)
								sound_effect = 'sound/weapons/shotgunshot.ogg'
								volume = 70
							if (6)
								sound_effect = 'sound/weapons/tranq_pistol.ogg'
								volume = 70
							if (7)
								sound_effect = 'sound/voice/animal/brullbar_scream.ogg'
								volume = 70
							if (8)
								sound_effect = 'sound/voice/animal/werewolf_howl.ogg'
								volume = 70
							if (8)
								sound_effect = 'sound/voice/wizard/MagicMissileLoud.ogg'
								volume = 70
					else	//Fake announcements, much rarer
						switch(rand(1,2))
							if (1)
								if(!has_faked_nuke)
									sound_effect = 'sound/machines/bomb_planted.ogg'
									volume = 90
									boutput(H, "<h1 class='alert'>Frontier Authority Update</h1>")
									boutput(H, "<h2 class='alert'>Nuclear Weapon Detected</h2>")
									boutput(H, "<span class='alert'>A nuclear bomb has been armed in [pick("the Bridge", "the Bar", "the security lobby", "the medical lobby")]. It will explode in 5 minutes. All personnel must report to the plant area to disarm the bomb immediatly.</span>")
									has_faked_nuke = true
							if (2)
								if(!has_faked_shuttle)
									sound_effect = 'sound/misc/shuttle_enroute.ogg'
									volume = 80
									boutput(H, "<h1 class='alert'>The Emergency Shuttle Has Been Called</h1>")
									boutput(H, "<span>No reason given.</span>")
									boutput(H, "<span class='alert'>It will arrive in 6 minutes.</span>")
									has_faked_shuttle = true
					H.playsound_local(H.loc,sound_effect, volume, 1)
				if (3) //Wall based, blood pouring out of the walls and other spooky stuff
					var/turf/owner_turf = get_turf(owner)
					if (!owner_turf) return
					var/list/turfs = block(locate(max(owner_turf.x - range, 0), max(owner_turf.y - range, 0), owner_turf.z), locate(min(owner_turf.x + range, world.maxx), min(owner_turf.y + range, world.maxy), owner_turf.z))
					var/list/wall_turfs = list()
					for (var/turf/simulated/wall/wall in turfs)
						wall_turfs += wall
					if (length(wall_turfs))
						var/turf/simulated/wall/W = pick(wall_turfs)
						switch(rand(1,3))
							if (1)
								illusion_icon = 'icons/effects/wraitheffects.dmi'
								illusion_icon_state = "bloodpour"
							if (2)
								illusion_icon = 'icons/effects/wraitheffects.dmi'
								illusion_icon_state = "bloodpour2"
							if (3)
								illusion_icon = 'icons/effects/wraitheffects.dmi'
								illusion_icon_state = "blooddrops"
								var/image/dripIcon = image(illusion_icon, W, null, EFFECTS_LAYER_UNDER_4)
								dripIcon.icon_state = illusion_icon_state
								get_image_group(CLIENT_IMAGE_GROUP_ILLUSSION).add_image(dripIcon)
								SPAWN(10 SECONDS)
									while(dripIcon.alpha > 0)
										sleep(5 DECI SECOND)
										dripIcon.alpha -= 10
									qdel(dripIcon)
								illusion_icon = 'icons/effects/wraitheffects.dmi'
								illusion_icon_state = "bloodrip"
						var/image/illusionIcon = image(illusion_icon, W, null, EFFECTS_LAYER_UNDER_4)
						illusionIcon.icon_state = illusion_icon_state
						get_image_group(CLIENT_IMAGE_GROUP_ILLUSSION).add_image(illusionIcon)
						SPAWN(10 SECONDS)
							while(illusionIcon.alpha > 0)
								sleep(5 DECI SECOND)
								illusionIcon.alpha -= 10
							qdel(illusionIcon)

/datum/statusEffect/corporeal
	id = "corporeal"
	icon_state = "eye"
	desc = "You've manifested into the phyiscal realm!"
	unique = TRUE
	maxDuration = 1 MINUTE

	onAdd(optional) // optional = forced to manifest
		. = ..()
		var/mob/M = owner
		if (istype(M, /mob/wraith))
			var/mob/wraith/W = M
			if(optional)
				W.forced_manifest = TRUE
			else
				W.haunting = TRUE
				W.flags &= !UNCRUSHABLE
			if (!istype_exact(M, /mob/wraith/poltergeist))
				M.alpha = 255
		if (istype_exact(M, /mob/wraith/poltergeist))
			M.icon_state = "poltergeist-corp"
			M.update_body()
		M.set_density(TRUE)
		REMOVE_ATOM_PROPERTY(M, PROP_MOB_INVISIBILITY, M)
		M.see_invisible = INVIS_NONE
		M.visible_message(pick("<span class='alert'>A horrible apparition fades into view!</span>", "<span class='alert'>A pool of shadow forms!</span>"), pick("<span class='alert'>A shell of ectoplasm forms around you!</span>", "<span class='alert'>You manifest!</span>"))

	onRemove()
		var/mob/M = owner
		if (istype(M, /mob/wraith))
			var/mob/wraith/W = M
			W.forced_manifest = FALSE
			W.haunting = FALSE
			W.flags |= UNCRUSHABLE
			if (!istype_exact(M, /mob/wraith/poltergeist))
				M.alpha = 160
		if (istype_exact(M, /mob/wraith/poltergeist))
			M.icon_state = "poltergeist"
			M.update_body()
		M.visible_message(pick("<span class='alert'>[M] vanishes!</span>", "<span class='alert'>The [M] dissolves into shadow!</span>"), pick("<span class='notice'>The ectoplasm around you dissipates!</span>", "<span class='notice'>You fade into the aether!</span>"))
		M.set_density(FALSE)
		APPLY_ATOM_PROPERTY(M, PROP_MOB_INVISIBILITY, M, INVIS_SPOOKY)
		M.see_invisible = INVIS_SPOOKY
		. = ..()
