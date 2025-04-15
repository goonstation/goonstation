var/maniac_active = 0
var/maniac_previous_victim = "Unknown"
//maniac
//A psycho chef that sometimes appears when you go through doors on the evilreaver derelict, similar to that *ANIMEE* game Ao Oni


/obj/chaser
	density = 1
	anchored = ANCHORED
	var/mob/target = null

	New()
		SPAWN(1 DECI SECOND) process()
		..()


	proc/proximity_act()

	proc/process()
		if(target)
			if (BOUNDS_DIST(src, src.target) == 0)
				proximity_act()

			var/dist = GET_DIST(src, src.target)
			if(dist > world.view * 2)
				walk_towards(src, src.target, 3)
			else
				walk_to(src, src.target, 0, 3)

			sleep(1 SECOND)
			SPAWN(0.5 SECONDS)
				process()

/obj/chaser/maniac
	name = "?"
	icon = 'icons/misc/evilreaverstation.dmi'
	icon_state = "chaser"
	desc = "We all go a little mad sometimes, haven't you?"

	var/sound/aaah = sound('sound/misc/chefsong.ogg',channel=7)
	var/targeting = 0


	New()
		name = maniac_previous_victim
		..()

	proximity_act()
		if(prob(40))
			src.visible_message(SPAN_ALERT("<B>[src] slices through [target.name] with the axe!</B>"))
			playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
			target.change_eye_blurry(10)
			boutput(target, "Help... help...")
			SPAWN(0.5 SECONDS)
				var/victimkey = target.ckey
				var/victimname = target.name
				boutput(target, "Connection axed.")
				target.ckey = "" // disconnect the player so they rejoin wondering what the hell happened
				sleep(0)
				var/mob/dead/observer/ghost = new/mob/dead/observer
				for(var/turf/T in landmarks[LANDMARK_EVIL_CHEF_CORPSE])
					ghost.set_loc(T)
					new /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat(T,target)

				ghost.ckey = victimkey
				ghost.name = victimname // should've added this sooner
				ghost.real_name = victimname
				maniac_previous_victim = victimname
				maniac_active &= ~1
				qdel(target)
				qdel(src)
				src.target = null
				src.targeting = FALSE
		else
			src.visible_message(SPAN_ALERT("<B>[src] swings at [target.name] with the axe!</B>"))
			playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 50, 1)

	process()
		if(!targeting)
			targeting = 1
			target<< 'sound/misc/chefsong_start.ogg'
			SPAWN(8 SECONDS)
				aaah.repeat = 1
				target << aaah
				sleep(rand(100,400))
				if(target)	target << sound('sound/misc/chefsong_end.ogg',channel=7)
				qdel(src)
		..()



/obj/chaser/trigger
	name = "evil maniac trigger"
	icon = 'icons/misc/evilreaverstation.dmi'
	icon_state = "chaser"
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	density = 0

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(!(maniac_active & 1))
			if(isliving(AM))
				if(AM:client)
					if(prob(75))
						maniac_active |= 1
						SPAWN(1 MINUTE) maniac_active &= ~1
						SPAWN(rand(10,30))
							var/obj/chaser/maniac/C = new /obj/chaser/maniac(src.loc)
							C.target = AM

/obj/chaser/rptrigger
	name = "evil maniac trigger"
	icon = 'icons/misc/evilreaverstation.dmi'
	icon_state = "chaser"
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED
	density = 0

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(!(maniac_active & 1))
			if(isliving(AM))
				if(AM:client)
					if(prob(75))
						maniac_active |= 1
						SPAWN(1 MINUTE) maniac_active &= ~1
						SPAWN(rand(10,30))
							var/obj/chaser/maniac/C = new /obj/chaser/rpmaniac(src.loc)
							C.target = AM


////////////////////////////////////////

//The PR1 Guardbuddy//



/obj/machinery/checkpointbot
	name = "PR-1 Automated Checkpoint"
	desc = "The great-great-great-great-great grandfather of the PR-6 Guardbuddy, and it's almost in mint condition!"
	icon = 'icons/obj/bots/robuddy/pr-1.dmi'
	icon_state = "body"
	anchored = ANCHORED
	density = 1
	var/alert = 0
	var/id = "evilreaverbridge"

	New()
		..()
		src.AddComponent(/datum/component/proximity)

	EnteredProximity(atom/movable/AM)
		if(!alert)
			if(iscarbon(AM))
				alert = 1
				playsound(src.loc, 'sound/machines/whistlealert.ogg', 50, 1)

				src.UpdateOverlays(image(src.icon, "face-sad"), "emotion")
				src.UpdateOverlays(image(src.icon, "lights-on"), "lights")

				for(var/obj/machinery/door/poddoor/P in by_type[/obj/machinery/door])
					if (P.id == src.id)
						if (!P.density)
							SPAWN( 0 )
								P.close()
				SPAWN(5 SECONDS)
					if(id == "evilreaverbridge")
						playsound(src.loc, 'sound/machines/driveclick.ogg', 50, 1)
						var/obj/item/paper/PA = new /obj/item/paper
						PA.set_loc(src.loc)

						PA.info = "<center>YOU DO NOT BELONG HERE<BR><font size=30>LEAVE NOW</font></center>" //rude!
						PA.name = "Paper - PR1-OUT"

					src.UpdateOverlays(null, "emotion")

					sleep(30 SECONDS)
					alert = 0
					src.UpdateOverlays(null, "lights")



////////////
/area/evilreaver
	name = "Forgotten Station"
	icon_state = "derelict"
	teleport_blocked = 1
	sound_loop = 'sound/ambience/spooky/Evilreaver_Ambience.ogg'
	occlude_foreground_parallax_layers = TRUE
#ifdef MAP_OVERRIDE_OSHAN
	requires_power = FALSE
#elif defined(MAP_OVERRIDE_NEON)
	requires_power = FALSE
#endif

/area/evilreaver/medical
	icon_state = "medbay"
	name = "Forgotten Medical Bay"

/area/evilreaver/genetics
	icon_state = "medbay"
	name = "Forgotten Medical Research"

/area/evilreaver/storage
	icon_state = "storage"

/area/evilreaver/storage/engineering
	name = "Forgotten Engineering Storage"

/area/evilreaver/storage/tools
	name = "Forgotten Tools Storage"


/area/evilreaver/storage/emergency
	name = "Forgotten Emergency Storage A"

/area/evilreaver/storage/fire
	name = "Forgotten Emergency Storage B"

/area/evilreaver/atmospherics
	icon_state = "atmos"
	name = "Forgotten Atmospherics"

/area/evilreaver/security
	icon_state = "brigcell"
	name = "Forgotten Security"

/area/evilreaver/toxins
	icon_state = "toxlab"
	name = "Forgotten Toxins"

/area/evilreaver/chapel
	icon_state = "chapel"
	name = "Forgotten Chapel"
/area/evilreaver/bar
	icon_state = "bar"
	name = "Forgotten Bar"

/area/evilreaver/crew
	icon_state = "crewquarters"
	name = "Forgotten Crew Quarters"

/area/evilreaver/bridge
	icon_state = "bridge"
	name = "Forgotten Bridge"


///////////////////////////

/obj/item/clothing/suit/space/old
	name = "obsolete space suit"
	desc = "You probably wouldn't be able to fit into this."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "space_old"
	item_state = "space_old"
	cant_self_remove = 1

	equipped(var/mob/user, var/slot)
		boutput(user, SPAN_ALERT("Uh oh.."))
		..()

/obj/item/clothing/head/helmet/space/old
	name = "obsolete space helmet"
	desc = "This looks VERY uncomfortable!"
	icon_state = "space_old"


/obj/chaser/rpmaniac
	name = "?"
	icon = 'icons/misc/evilreaverstation.dmi'
	icon_state = "chaser"
	desc = "We all go a little mad sometimes, haven't you?"

	var/sound/aaah = sound('sound/misc/chefsong.ogg',channel=7)
	var/targeting = 0

	proximity_act()
		if(prob(40))
			src.visible_message(SPAN_ALERT("<B>[src] slashes [target.name] with the axe!</B>"))
			playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
			target.change_eye_blurry(10)
			boutput(target, "Help... help...")
			SPAWN(0.5 SECONDS)
				boutput(target, "You better run..")

				var/the_limb = null
				var/mob/living/carbon/human/H = target
				the_limb = pick("l_arm","r_arm","l_leg","r_leg")
				H.sever_limb(the_limb)
				random_brute_damage(target, rand(40,70),1)
				qdel(src)
				maniac_active &= ~1
		else
			src.visible_message(SPAN_ALERT("<B>[src] swings at [target.name] with the axe!</B>"))
			playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 50, 1)

	process()
		if(!targeting)
			targeting = 1
			target<< 'sound/misc/chefsong_start.ogg'
			SPAWN(8 SECONDS)
				aaah.repeat = 1
				target << aaah
				sleep(rand(100,400))
				if(target)	target << sound('sound/misc/chefsong_end.ogg',channel=7)
				qdel(src)
		..()

