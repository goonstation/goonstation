//******************************************** NSS POLARIS STUFF ********************************************

/area/crashsite
	name = "Crash site"
	icon_state = "green"

/area/wrecknsspolaris
	name = "Wreck of the NSS Polaris"
	icon_state = "green"
	sound_group = "polaris"
	teleport_blocked = AREA_TELEPORT_BLOCKED
	sound_loop = 'sound/ambience/loop/Polarisloop.ogg'

/area/wrecknsspolaris/vault
	name = "NSS Polaris Vault"
	requires_power = 0

/area/wrecknsspolaris/outside
	name = "Ouside the Wreck"
	icon_state = "blue"
	ambient_light_source = AMBIENT_LIGHT_SRC_OCEAN

/area/wrecknsspolaris/outside/teleport
	name = "Outer Wreck (with teleport)"

/area/wrecknsspolaris/outside/back
	name = "Back of the Wreck"

/obj/item/parts/human_parts/arm/right/polaris
	name = "misplaced right arm"
	desc = "Someone might need a hand with this."

/obj/machinery/handscanner
	name = "Hand Scanner"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "handscanner"
	var/id = "polarisdoor"
	var/used = 0

/obj/machinery/hanscanner/New()
	..()
	UnsubscribeProcess()


/obj/machinery/handscanner/attackby(obj/item/W, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	if (used == 0)
		if(istype(W, /obj/item/parts/human_parts/arm/right/polaris))
			user.visible_message(SPAN_NOTICE("The [src] accepts the biometrics of the hand and beeps, granting you access."))
			playsound(src.loc, 'sound/effects/handscan.ogg', 50, 1)
			for_by_tcl(M, /obj/machinery/door/airlock)
				if (M.id == src.id)
					if (M.density)
						M.open()
						M.operating = -1
						used = 1



/obj/machinery/handscanner/attack_hand(mob/user)
	src.add_fingerprint(user)
	playsound(src.loc, 'sound/effects/handscan.ogg', 50, 1)
	if (used == 0)
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.limbs && (istype(H.limbs.r_arm, /obj/item/parts/human_parts/arm/right/polaris)))
				user.visible_message(SPAN_NOTICE("The [src] accepts the biometrics of the hand and beeps, granting you access."))

				for (var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
					if (M.id == src.id)
						if (M.density)
							M.open()

				for_by_tcl(M, /obj/machinery/door/airlock)
					if (M.id == src.id)
						if (M.density)
							M.open()
							M.operating = -1
							used = 1
			else
				boutput(user, SPAN_ALERT("Invalid biometric profile. Access denied."))
	else
		boutput(user, SPAN_ALERT("The door has already been opened. It looks like the mechanism has jammed for good."))


/obj/item/storage/secure/ssafe/polaris
	name = "captain's lockbox"
	configure_mode = 0
	random_code = 1
	spawn_contents = list(/obj/item/card/id/polaris,
	/obj/item/paper/manta_polarisnote,/obj/item/reagent_containers/emergency_injector/random,/obj/item/currency/spacecash/thousand,
	/obj/item/currency/spacecash/thousand,/obj/item/currency/spacecash/thousand)

/obj/item/card/id/polaris
	name = "Sergeant's spare ID"
	icon_state = "id_nanotrasen"
	registered = "Sgt. Wilkins"
	assignment = "Sergeant"
	access = list(access_polariscargo,access_heads)
	keep_icon = TRUE

/obj/item/broken_egun
	name = "broken energy gun"
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon = 'icons/obj/items/items.dmi'
	icon_state = "broken_egun"
	desc = "Its a gun that has two modes, stun and kill, although this one is nowhere near working condition."
	item_state = "energy"
	force = 5

/obj/item/blackbox
	name = "flight recorder of NSS Polaris"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	icon = 'icons/obj/items/items.dmi'
	icon_state = "blackbox"
	desc = "A flight recorder is an electronic recording device placed in a spacecraft for the purpose of facilitating the investigation of accidents and incidents. Someone from Nanotrasen would surely want to see this."
	item_state = "electropack"
	force = 5

/turf/unsimulated/floor/polarispit
	name = "deep abyss"
	desc = "You can't see the bottom."
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "pit"
	fullbright = 0
	pathable = 0
	var/falltarget = LANDMARK_FALL_POLARIS
	// this is the code for falling from abyss into ice caves
	// could maybe use an animation, or better text. perhaps a slide whistle ogg?
	New()
		src.AddComponent(/datum/component/pitfall/target_landmark,\
			BruteDamageMax = 50,\
			FallTime = 0 SECONDS,\
			TargetLandmark = src.falltarget)
		..()

	polarispitwall
		icon_state = "pit_wall"

	marj
		name = "dank abyss"
		desc = "The smell rising from it somehow permeates the surrounding water."
		falltarget = LANDMARK_FALL_MARJ

		pitwall
			icon_state = "pit_wall"

	cult
		name = "ominious abyss"
		desc = "The water below vibrates with a tension, as though it was raging."
		falltarget = LANDMARK_FALL_CULTIST

		pitwall
			icon_state = "pit_wall"
