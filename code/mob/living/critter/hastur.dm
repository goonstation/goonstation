var/HasturPresent = 0

TYPEINFO(/mob/living/critter/hastur)
	start_speech_modifiers = list(SPEECH_MODIFIER_ACCENT_VOID)

/mob/living/critter/hastur
	name = "????"
	real_name = "????"
	desc = "He who must not be named..."
	density = 1
	anchored = ANCHORED
	icon = 'icons/misc/hastur.dmi'
	icon_state = "hastur"
	hand_count = 4
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	can_help = 1
	see_invisible = INVIS_ADVENTURE
	stat = STAT_DEAD
	stepsound = 'sound/misc/hastur/tentacle_walk.ogg'
	speech_verb_say = "states"
	speech_verb_exclaim = "declares"
	speech_verb_ask = "inquires"
	bound_height = 32
	bound_width = 32
	layer = 40
	var/icon/northsouth = null
	var/icon/eastwest = null
	var/lastdir = null

	New()
		..()
		src.see_in_dark = SEE_DARK_FULL
		northsouth = icon('icons/misc/hastur.dmi')
		eastwest = icon('icons/misc/hastur.dmi')
		changeIcon()
		src.nodamage = 1
		HasturPresent = 1
		bioHolder.AddEffect("radio_brain", 2)
		abilityHolder.addAbility(/datum/targetable/hastur/devour)
		abilityHolder.addAbility(/datum/targetable/hastur/insanityaura)
		abilityHolder.addAbility(/datum/targetable/hastur/masswhisper)
		abilityHolder.addAbility(/datum/targetable/hastur/ancientinvisibility)

	bump(atom/O)
		. = ..()
		changeIcon(0)
		return .

	proc/changeIcon(var/rebuildOverlays = 0)
		if(dir == NORTH || dir == SOUTH)
			icon = northsouth
			pixel_x = -16
		if(dir == EAST || dir == WEST)
			icon = eastwest
			pixel_y = -4
		return

	Move()
		if(dir != lastdir)
			if(dir == NORTHEAST || dir == SOUTHWEST || dir == SOUTHEAST || dir == NORTHWEST)
				set_dir(lastdir)
				changeIcon()
			else
				lastdir = dir
				changeIcon()
		. = ..()

	set_loc(var/newloc as turf|mob|obj in world)
		..(newloc)
		changeIcon()

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.name = "right tentacles"					// designation of the hand - purely for show
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "tentacler"				// the icon state of the hand UI background
		HH.limb_name = "right tentacles"					// name for the dummy holder
		HH.limb = new /datum/limb/abomination/hastur	// if not null, the special limb to use when attack_handing
		HH.can_hold_items = 1
		HH.can_attack = 1

		HH = hands[2]
		HH.name = "left tentacles"					// designation of the hand - purely for show
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "tentaclel"				// the icon state of the hand UI background
		HH.limb_name = "left tentacles"					// name for the dummy holder
		HH.limb = new /datum/limb/abomination/hastur	// if not null, the special limb to use when attack_handing
		HH.can_hold_items = 1
		HH.can_attack = 1

		HH = hands[3]
		HH.name = "long range tentacles"					// designation of the hand - purely for show
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "tentaclek"				// the icon state of the hand UI background
		HH.limb_name = "long range tentacles"					// name for the dummy holder
		HH.limb = new /datum/limb/longtentacle	// if not null, the special limb to use when attack_handing
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1

		HH = hands[4]
		HH.name = "long range stun tentacles"					// designation of the hand - purely for show
		HH.icon = 'icons/mob/critter_ui.dmi'	// the icon of the hand UI background
		HH.icon_state = "tentacles"				// the icon state of the hand UI background
		HH.limb_name = "long range stun tentacles"					// name for the dummy holder
		HH.limb = new /datum/limb/longtentaclestun	// if not null, the special limb to use when attack_handing
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1

	setup_healths()
		add_hh_flesh(6500, 0.5)
		add_hh_flesh_burn(6500, 0.5)
		add_health_holder(/datum/healthHolder/toxin)

	death(var/gibbed)
		. = ..()
		HasturPresent = 0

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/misc/hastur/growl.ogg' , 60, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>Something growls menacingly under [src]'s robe!</b>"
		return null

	on_pet(mob/user)
		random_brute_damage(user, rand(5,10))
		boutput(user,SPAN_ALERT("<b>Sharp tentacle slaps [user] away as [he_or_she(user)] attempt to pet [src]!</b>"))


//DEVOUR ABILITY// - Pretty much just a changeling re-do
/datum/targetable/hastur
	interrupt_action_bars = FALSE

/datum/targetable/hastur/devour
	name = "Devour"
	desc = "Instantly devour a human.. (USE SPARINGLY)"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "hasturdevour"
	targeted = 1
	target_nodamage_check = 1
	max_range = 1
	cooldown = 0

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M || !target || !ismob(target))
			return 1

		if (M == target)
			boutput(M, SPAN_ALERT("You can't devour yourself."))
			return 1

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, SPAN_ALERT("[target] is too far away."))
			return 1
		. = ..()
		M.visible_message(pick(SPAN_ALERT("<B>[M] reveals their true form for a moment and -COMPLETELY- devours [target]!</B>"),SPAN_ALERT("<B>Huge mouth emerges underneath [M]'s robes and DEVOURS [target]!</B>"),SPAN_ALERT("<B>[M] growls angrily as they reveal their true form, completely devouring [target]!</B>")))
		playsound(M.loc, pick('sound/misc/hastur/devour1.ogg','sound/misc/hastur/devour2.ogg','sound/misc/hastur/devour3.ogg','sound/misc/hastur/devour4.ogg'), 90,1)
		flick("hastur-devour", M)
		SPAWN(7 DECI SECONDS)
			target.gib()
			target.icon_state = "lost"
			target.name = "Soulless [target.real_name]"
			target.real_name =  "Soulless [target.real_name]"

//INSANITY AURA ABILITY// - Pretty much just a changeling re-do

/datum/targetable/hastur/insanityaura
	name = "Insanity Aura"
	desc = "Causes everyone to go a bit mad around you.."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "hasturaura"
	targeted = 0
	cooldown = 500

	cast()
		. = ..()
		for(var/mob/living/M in orange(300))
			M.addOverlayComposition(/datum/overlayComposition/insanity)
			M.updateOverlaysClient(M.client)
			boutput(M, pick("<font color=purple><b>The reality around you fades out..</b></font>","<font color=purple><b>Suddenly your mind feels extremely frail and vulnerable..</b></font>","<font color=purple><b>Your sanity starts to fail you...</b></font>"))
			playsound(M, 'sound/ambience/spooky/Void_Song.ogg', 50, TRUE)
			SPAWN(62 SECONDS)
				M.removeOverlayComposition(/datum/overlayComposition/insanity)
				M.updateOverlaysClient(M.client)


//INSANITY AURA ABILITY// - Pretty much just a changeling re-do

/datum/targetable/hastur/masswhisper
	name = "Mass Whisper"
	icon_state = "hasturwhisper"
	icon = 'icons/mob/critter_ui.dmi'
	desc = "Send a creepy void flavoured text to all living beings.."
	targeted = 0
	target_anything = 0
	cooldown = 2

	cast()
		. = ..()
		var/msg = input("Message:", text("What would you like to whisper to everyone?")) as null|text
		msg = voidSpeak(trimtext(copytext(sanitize(msg), 1, 255)))
		if (!msg)
			return

		if (usr.client && usr.client.holder)
			boutput(world, "<font color=purple><b>An otherwordly voice whispers into your ears... [msg]</b></font>")
			//msg = voidSpeak(trimtext(copytext(sanitize(msg), 1, 255)))
			//boutput(usr, "<b>You whisper to everyone:</b> [message]")


//ANCIENT INVISIBILIT ABILITY// - Pretty much just a changeling re-do
/datum/targetable/hastur/ancientinvisibility
	name = "Veil of the void"
	icon_state = "hasturinvisibility"
	icon = 'icons/mob/critter_ui.dmi'
	desc = "Vanish/Manifest back from the void to hunt your prey.."
	targeted = 0
	target_anything = 0
	cooldown = 5
	var/stage = 0

	cast()
		var/mob/living/critter/hastur/H = src.holder.owner
		. = ..()
		if (stage == 1)
			H.set_density(1)
			REMOVE_ATOM_PROPERTY(H, PROP_MOB_INVISIBILITY, src)
			H.alpha = 255
			H.stepsound = 'sound/misc/hastur/tentacle_walk.ogg'
			H.visible_message(pick(SPAN_ALERT("A horrible apparition fades into view!"), SPAN_ALERT("A pool of shadow forms and manifests into shape!")), pick(SPAN_ALERT("Void manifests around you, giving you your physical form back."), SPAN_ALERT("Energies of the void allow you to manifest back in a physical form.")))
			stage = 0
		else
			H.visible_message(pick(SPAN_ALERT("[H] vanishes from sight!"), SPAN_ALERT("[H] dissolves into the void!")), pick(SPAN_NOTICE("You are enveloped by the void, hiding your physical manifestation."), SPAN_NOTICE("You fade into the void!")))
			H.set_density(0)
			APPLY_ATOM_PROPERTY(H, PROP_MOB_INVISIBILITY, src, INVIS_SPOOKY)
			H.alpha = 160
			H.stepsound = null
			H.see_invisible = INVIS_SPOOKY
			stage = 1

//TENTACLE LONG RANGE WHIP//

/obj/line_obj/tentacle
	name = "sharp tentacle"
	desc = ""
	anchored = ANCHORED
	density = 0
	opacity = 0

/obj/tentacle_trg_dummy
	name = ""
	desc = ""
	anchored = ANCHORED
	density = 0
	opacity = 0
	invisibility = INVIS_ALWAYS_ISH


/datum/limb/longtentacle
	var/cooldown = 50
	var/next_shot_at = 0
	var/image/default_obscurer

	is_on_cooldown()
		if (ticker.round_elapsed_ticks < next_shot_at)
			return next_shot_at - ticker.round_elapsed_ticks
		return 0

	attack_range(atom/target, var/mob/user, params)
		var/turf/start = user.loc
		if (!isturf(start))
			return
		target = get_turf(target)
		if (!target)
			return
		if (target == start)
			return
		if (next_shot_at > ticker.round_elapsed_ticks)
			return
		next_shot_at = ticker.round_elapsed_ticks + cooldown

		playsound(user, 'sound/misc/hastur/tentacle_hit.ogg', 50, TRUE)
		SPAWN(rand(1,3)) // so it might miss, sometimes, maybe
			var/obj/target_r = new/obj/tentacle_trg_dummy(target)

			playsound(user, 'sound/misc/hastur/tentacle_hit.ogg', 50, TRUE)
			user.visible_message(SPAN_ALERT("<B>[user] sends a sharp tentacle flying!</B>"))
			user.set_dir(get_dir(user, target))

			var/list/affected = drawLineObj(user, target_r, /obj/line_obj/tentacle ,'icons/obj/projectiles.dmi',"WholeTentacle",1,1,"HalfStartTentacle","HalfEndTentacle",OBJ_LAYER,1)

			for(var/obj/O in affected)
				O.anchored = ANCHORED //Proc wont spawn the right object type so lets do that here.
				O.name = "sharp tentacle"
				var/turf/src_turf = O.loc
				for(var/obj/machinery/vehicle/A in src_turf)
					if(A == O || A == user) continue
					A.meteorhit(O)
				for(var/obj/mesh/grille/A in src_turf)
					if(A == O || A == user) continue
					A.damage_blunt(10)
				for(var/obj/window/A in src_turf)
					if(A == O || A == user) continue
					A.smash()
				for(var/mob/living/M in src_turf)
					if(M == O || M == user) continue
					if (ishuman(M))
						playsound(M, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, TRUE)
						take_bleeding_damage(M, M, 15)
						M.visible_message(SPAN_ALERT("[M] gets stabbed by a sharp, spiked tentacle!"))
						random_brute_damage(M, rand(10,20),1)
					else
						M.meteorhit(O)
				for(var/turf/T in src_turf)
					if(T == O) continue
					T.meteorhit(O)

			sleep(0.7 SECONDS)
			for (var/obj/O in affected)
				qdel(O)

			if(istype(target_r, /obj/tentacle_trg_dummy)) qdel(target_r)

//TENTACLE LONG RANGE WHIP WITH STUN

/datum/limb/longtentaclestun
	var/cooldown = 50
	var/next_shot_at = 0
	var/image/default_obscurer

	is_on_cooldown()
		if (ticker.round_elapsed_ticks < next_shot_at)
			return next_shot_at - ticker.round_elapsed_ticks
		return 0

	attack_range(atom/target, var/mob/user, params)
		var/turf/start = user.loc
		if (!isturf(start))
			return
		target = get_turf(target)
		if (!target)
			return
		if (target == start)
			return
		if (next_shot_at > ticker.round_elapsed_ticks)
			return
		next_shot_at = ticker.round_elapsed_ticks + cooldown

		playsound(user, 'sound/misc/hastur/tentacle_hit.ogg', 50, TRUE)
		SPAWN(rand(1,3)) // so it might miss, sometimes, maybe
			var/obj/target_r = new/obj/tentacle_trg_dummy(target)

			playsound(user, 'sound/misc/hastur/tentacle_hit.ogg', 50, TRUE)
			user.visible_message(SPAN_ALERT("<B>[user] sends a grabbing tentacle flying!</B>"))
			user.set_dir(get_dir(user, target))

			var/list/affected = drawLineObj(user, target_r, /obj/line_obj/tentacle ,'icons/obj/projectiles.dmi',"WholeTentacle",1,1,"HalfStartTentacle","HalfEndTentacle",OBJ_LAYER,1)

			for(var/obj/O in affected)
				O.anchored = ANCHORED //Proc wont spawn the right object type so lets do that here.
				O.name = "coiled tentacle"
				var/turf/src_turf = O.loc
				for(var/obj/machinery/vehicle/A in src_turf)
					if(A == O || A == user) continue
					A.meteorhit(O)
				for(var/obj/mesh/grille/A in src_turf)
					if(A == O || A == user) continue
					A.damage_blunt(10)
				for(var/obj/window/A in src_turf)
					if(A == O || A == user) continue
					A.smash()
				for(var/mob/living/M in src_turf)
					if(M == O || M == user) continue
					var/turf/destination = get_turf(user)
					if (destination)
						do_teleport(M, destination, 1, sparks=0) ///You will appear adjacent to Hastur.
						playsound(M, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, TRUE)
						M.changeStatus("unconscious", 2 SECONDS)
						M.visible_message(SPAN_ALERT("[M] gets grabbed by a tentacle and dragged!"))


					else
						M.meteorhit(O)
				for(var/turf/T in src_turf)
					if(T == O) continue
					T.meteorhit(O)

			sleep(0.7 SECONDS)
			for (var/obj/O in affected)
				qdel(O)

			if(istype(target_r, /obj/tentacle_trg_dummy)) qdel(target_r)
