/*
/obj/secure_closet
	desc = "An immobile card-locked storage closet."
	name = "Security Locker"
	icon = 'icons/obj/closet.dmi'
	icon_state = "secure"
	density = 1
	throwforce = 30 // cogwerks cargo router thing, adjust as needed
	flags = NOSPLASH
	var/opened = 0
	var/locked = 1
	var/broken = 0
	var/large = 1
	var/jiggled = 0
	var/icon_closed = "secure"
	var/icon_opened = "secureopen"
	var/greenlight = "greenlight"
	var/redlight = "redlight"
	var/sparks = "sparks"
	var/datum/radio_frequency/radio_control = 1431
	var/net_id
	var/health = 6 // harder to break out of one of these

	New()
		..()
		update_overlays()
		SPAWN_DBG(1 SECOND)
			if (!opened)		// if closed, any item at src's loc is put in the contents
				for (var/obj/item/I in src.loc)
					if (I.density || I.anchored || I == src) continue
					I.set_loc(src)
			if (isnum(src.radio_control) && radio_controller)
				radio_control = max(1000, min(round(radio_control), 1500))
				src.net_id = generate_net_id(src)
				radio_controller.add_object(src, "[src.radio_control]")
				src.radio_control = radio_controller.return_frequency("[src.radio_control]")

	proc/update_overlays() // boop stolen from secure crates
		if (overlays)
			overlays = null
		overlays = list()

		if (opened)
			icon_state = icon_opened

		if (!opened)
			icon_state = icon_closed
			if (broken)
				overlays += sparks
			else if (locked)
				overlays += redlight
			else
				overlays += greenlight

	receive_signal(datum/signal/signal)
		if(!src.radio_control)
			return

		var/sender = signal.data["sender"]
		if(!signal || signal.encryption || !sender)
			return

		if (signal.data["address_1"] == src.net_id)
			switch (lowertext(signal.data["command"]))
				if ("status")
					var/datum/signal/reply = get_free_signal()
					reply.source = src
					reply.transmission_method = TRANSMISSION_RADIO
					reply.data = list("address_1" = sender, "command" = "lock=[locked]&open=[opened]", "sender" = src.net_id)
					SPAWN_DBG(0.5 SECONDS)
						src.radio_control.post_signal(src, reply, 2)

				if ("lock")
					. = 0
					if (signal.data["pass"] == netpass_heads)
						. = 1
						src.locked = !src.locked
						src.visible_message("[src] clicks[src.opened ? "" : " locked"].")
						src.update_overlays()

					var/datum/signal/reply = get_free_signal()
					reply.source = src
					reply.transmission_method = TRANSMISSION_RADIO
					if (.)
						reply.data = list("address_1" = sender, "command" = "ack", "sender" = src.net_id)
					else
						reply.data = list("address_1" = sender, "command" = "nack", "data" = "badpass", "sender" = src.net_id)
					SPAWN_DBG(0.5 SECONDS)
						src.radio_control.post_signal(src, reply, 2)

				if ("unlock")
					. = 0
					if (signal.data["pass"] == netpass_heads)
						. = 1
						src.locked = !src.locked
						src.visible_message("[src] clicks[src.opened ? "" : " unlocked"].")
						src.update_overlays()

					var/datum/signal/reply = get_free_signal()
					reply.source = src
					reply.transmission_method = TRANSMISSION_RADIO
					if (.)
						reply.data = list("address_1" = sender, "command" = "ack", "sender" = src.net_id)
					else
						reply.data = list("address_1" = sender, "command" = "nack", "data" = "badpass", "sender" = src.net_id)

					SPAWN_DBG(0.5 SECONDS)
						src.radio_control.post_signal(src, reply, 2)
			return //todo
		else if(signal.data["address_1"] == "ping")
			var/datum/signal/reply = get_free_signal()
			reply.source = src
			reply.transmission_method = TRANSMISSION_RADIO
			reply.data["address_1"] = sender
			reply.data["command"] = "ping_reply"
			reply.data["device"] = "WNET_SECLOCKER"
			reply.data["netid"] = src.net_id
			SPAWN_DBG(0.5 SECONDS)
				src.radio_control.post_signal(src, reply, 2)
			return

		return

/obj/secure_closet/courtroom
	name = "Courtroom Locker"
	req_access = list(access_heads)

/obj/secure_closet/courtroom/New()
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/paper/Court (src)
	new /obj/item/paper/Court (src)
	new /obj/item/paper/Court (src)
	new /obj/item/pen (src)
	new /obj/item/clothing/suit/judgerobe (src)
	new /obj/item/clothing/head/powdered_wig (src)
	new /obj/item/clothing/under/misc/lawyer/red(src)
	new /obj/item/clothing/under/misc/lawyer(src)
	new /obj/item/clothing/under/misc/lawyer/black(src)
	new /obj/item/storage/briefcase(src)
	return ..()

/obj/secure_closet/animal
	name = "Animal Control"
	req_access = list(access_medical)

/obj/secure_closet/animal/New()
	new /obj/item/device/radio/signaler(src)
	new /obj/item/device/radio/electropack(src)
	new /obj/item/device/radio/electropack(src)
	new /obj/item/device/radio/electropack(src)
	new /obj/item/device/radio/electropack(src)
	new /obj/item/device/radio/electropack(src)
	return ..()

/obj/secure_closet/brig
	name = "Confiscated Items Locker"
	req_access_txt = "2"
	//implant_lock = 2
	var/id = null

/*/obj/secure_closet/brig/New()
	new /obj/item/clothing/under/color/orange(src)
	new /obj/item/clothing/under/color/orange(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/shoes/orange(src)
	return ..()*/

/obj/secure_closet/highsec
	name = "Head of Personnel"
	req_access = list(access_heads)

/obj/secure_closet/highsec/New()
//	new /obj/item/gun/energy/egun(src)
	new /obj/item/device/flash(src)
	new /obj/item/storage/box/id_kit(src)
	new /obj/item/clothing/under/rank/head_of_personnel(src)
	new /obj/item/clothing/head/fancy/rank(src)
	new /obj/item/clothing/under/rank/head_of_personnel/fancy(src)
	new /obj/item/clothing/shoes/brown(src)
//	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/suit/armor/vest(src)
//	new /obj/item/clothing/head/helmet(src)
	return ..()

/obj/secure_closet/hos
	name = "Head Of Security"
	req_access = list(access_heads)
	icon_state = "sec"
	icon_closed = "sec"
	icon_opened = "secure_redopen"

/obj/secure_closet/hos/New()
	new /obj/item/storage/box/id_kit(src)
	new /obj/item/handcuffs(src)
	new /obj/item/device/flash(src)
	new /obj/item/clothing/under/color/red(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/head/helmet(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/device/detective_scanner(src)
	new /obj/item/baton(src)
	new /obj/item/gun/energy/egun(src)
	new /obj/item/device/radio/headset/security(src)
	new /obj/item/clothing/under/rank/head_of_securityold(src)
	new /obj/item/clothing/under/rank/head_of_securityold/fancy(src)
	new /obj/item/clothing/glasses/thermal(src)
	return ..()

/obj/secure_closet/armory
	name = "Special Equipment"
	req_access = list(access_heads)
	//implant_lock = 1
	icon_state = "sec"
	icon_closed = "sec"
	icon_opened = "secure_redopen"

/obj/secure_closet/armory/New()
	new /obj/item/device/flash(src)
	new /obj/item/storage/box/flashbang_kit(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/suit/armor/EOD(src)
	new /obj/item/clothing/head/helmet/EOD(src)
	new /obj/item/ammo/bullets/abg(src)
	new /obj/item/gun/kinetic/riotgun(src)
	return ..()

/obj/secure_closet/captains
	name = "Captain's Closet"
	req_access = list(access_captain)

/obj/secure_closet/captains/New()
	new /obj/item/gun/energy/egun(src)
	new /obj/item/storage/box/id_kit(src)
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/head/fancy/captain(src)
	new /obj/item/clothing/under/rank/captain/fancy(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/head/helmet/swat(src)
	return ..()

/obj/secure_closet/medical1
	name = "Medicine Closet"
	icon_state = "medical"
	icon_closed = "medical"
	icon_opened = "medicalopen"
	req_access = list(access_medical_lockers)

/obj/secure_closet/medical1/New()
	new /obj/item/storage/box/gl_kit(src)
	new /obj/item/reagent_containers/glass/bottle/antitoxin(src)
	new /obj/item/reagent_containers/glass/bottle/antitoxin(src)
	new /obj/item/reagent_containers/glass/bottle/antitoxin(src)
	new /obj/item/reagent_containers/glass/bottle/epinephrine(src)
	new /obj/item/reagent_containers/glass/bottle/epinephrine(src)
	new /obj/item/reagent_containers/glass/bottle/epinephrine(src)
	new /obj/item/reagent_containers/glass/bottle/morphine(src)
	new /obj/item/reagent_containers/glass/bottle/morphine(src)
	new /obj/item/reagent_containers/glass/bottle/toxin(src)
	new /obj/item/storage/box/syringes(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/clothing/glasses/visor(src)
	new /obj/item/clothing/glasses/eyepatch (src)
	return ..()

/obj/secure_closet/chemical
	name = "Chemical Closet"
	icon_state = "science"
	icon_closed = "science"
	icon_opened = "medicalopen"
	req_access = list(access_tox_storage)

/obj/secure_closet/chemical/New()
	// let's organize the SHIT outta this closet hot damn

	var/obj/item/reagent_containers/glass/bottle/B1 = new /obj/item/reagent_containers/glass/bottle/oil(src)
	B1.pixel_y = 6
	B1.pixel_x = -4

	var/obj/item/reagent_containers/glass/bottle/B2 = new /obj/item/reagent_containers/glass/bottle/phenol(src)
	B2.pixel_y = 6
	B2.pixel_x = 4

	var/obj/item/reagent_containers/glass/bottle/B3 = new /obj/item/reagent_containers/glass/bottle/acetone(src)
	B3.pixel_y = 0
	B3.pixel_x = -4

	var/obj/item/reagent_containers/glass/bottle/B4 = new /obj/item/reagent_containers/glass/bottle/ammonia(src)
	B4.pixel_y = 0
	B4.pixel_x = 4

	var/obj/item/reagent_containers/glass/bottle/B5 = new /obj/item/reagent_containers/glass/bottle/diethylamine(src)
	B5.pixel_y = -5
	B5.pixel_x = -4

	var/obj/item/reagent_containers/glass/bottle/B6 = new /obj/item/reagent_containers/glass/bottle/acid(src)
	B6.pixel_y = -5
	B6.pixel_x = 4
	return ..()

/obj/secure_closet/medical2
	name = "Anesthetic"
	icon_state = "medical"
	icon_closed = "medical"
	icon_opened = "medicalopen"
	req_access = list(access_medical_lockers)

/obj/secure_closet/medical2/New()
	new /obj/item/tank/anesthetic(src)
	new /obj/item/tank/anesthetic(src)
	new /obj/item/tank/anesthetic(src)
	new /obj/item/tank/anesthetic(src)
	new /obj/item/tank/anesthetic(src)
	new /obj/item/clothing/mask/medical(src)
	new /obj/item/clothing/mask/medical(src)
	new /obj/item/clothing/mask/medical(src)
	new /obj/item/clothing/mask/medical(src)
	return ..()

/obj/secure_closet/personal
	desc = "The first card swiped gains control."
	name = "Personal Closet"

/obj/secure_closet/personal/var/registered = null
/obj/secure_closet/personal/req_access = list(access_all_personal_lockers)

/obj/secure_closet/personal/New()
	new /obj/item/device/radio/signaler(src)
	new /obj/item/pen(src)
	new /obj/item/storage/backpack(src)
	new /obj/item/storage/backpack/satchel(src)
	new /obj/item/device/radio/headset(src)
	return ..()

/obj/secure_closet/personal/emag_act(var/mob/user, var/obj/item/card/emag/E) //FUCK YOU
	if(!src.broken)
		src.broken = 1
		src.locked = 0
		src.desc = "It appears to be broken."
		src.update_overlays()
		if (user)
			user.visible_message("<span class='notice'>The locker has been broken by [user] with an electromagnetic card!</span>")
		return 1
	return 0

/obj/secure_closet/personal/attackby(obj/item/W as obj, mob/user as mob)
	if (src.opened && !issilicon(user)) //Nope, borgs. You can't put your crap in these lockers either.
		if (istype(W, /obj/item/grab))
			src.MouseDrop_T(W:affecting, user)      //act like they were dragged onto the closet
		user.drop_item()
		if(W?.loc && !(W.cant_drop || W.cant_self_remove))	W.set_loc(src.loc)
	else if (istype(W, /obj/item/card/id))
		if(src.broken)
			boutput(user, "<span class='alert'>It appears to be broken.</span>")
			return
		var/obj/item/card/id/I = W
		if (src.allowed(user) || !src.registered || (istype(W, /obj/item/card/id) && src.registered == I.registered))
			//they can open all lockers, or nobody owns this, or they own this locker
			src.locked = !( src.locked )
			user.visible_message("<span class='notice'>The locker has been [src.locked ? null : "un"]locked by [user].</span>")
			src.update_overlays()
			if (!src.registered)
				src.registered = I.registered
				src.desc = "Owned by [I.registered]."
		else
			user.show_text("Access Denied", "red")
			user.unlock_medal("Rookie Thief", 1)
	else
		user.show_text("Access Denied", "red")
		user.unlock_medal("Rookie Thief", 1)
	return

/obj/secure_closet/personal/empty/New()
	return

/obj/secure_closet/hydroponics
	name = "Hydroponics Equipment"
	req_access = list(access_hydro)

/obj/secure_closet/hydroponics/New()
	new /obj/item/satchel/hydro(src)
	new /obj/item/saw(src)
	new /obj/item/plantanalyzer(src)
	new /obj/item/reagent_containers/glass/bottle/weedkiller(src)
	new /obj/item/reagent_containers/glass/bottle/weedkiller(src)
	new /obj/item/reagent_containers/glass/compostbag(src)
	new /obj/item/reagent_containers/glass/compostbag(src)
	new /obj/item/reagent_containers/glass/compostbag(src)
	new /obj/item/reagent_containers/glass/wateringcan(src)
	return ..()

/obj/secure_closet/security1
	name = "Security Equipment"
	req_access = list(access_securitylockers)
	icon_state = "sec"
	icon_closed = "sec"
	icon_opened = "secure_redopen"

/obj/secure_closet/security1/New()
	new /obj/item/handcuffs(src)
	new /obj/item/device/flash(src)
	new /obj/item/clothing/under/color/red(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/head/helmet(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/baton(src)
	new /obj/item/gun/energy/taser_gun(src)
	new /obj/item/device/radio/headset/security(src)
	return ..()


/obj/secure_closet/security2
	name = "Forensics Locker"
	req_access = list(access_forensics_lockers)
	icon_state = "sec"
	icon_closed = "sec"
	icon_opened = "secure_redopen"

/obj/secure_closet/security2/New()
	new /obj/item/clothing/under/rank/det(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/head/det_hat(src)
	new /obj/item/clothing/suit/det_suit(src)
//	new /obj/item/storage/box/fcard_kit(src) // Phased out with the forensic scanner overhaul. Was useless anyway (Convair880).
	new /obj/item/clothing/gloves/black(src)
	new /obj/item/clothing/glasses/thermal(src)
	new /obj/item/clothing/glasses/spectro(src)
	new /obj/item/storage/box/lglo_kit(src)
//	new /obj/item/fcardholder(src) // Ditto.
	new /obj/item/device/detective_scanner(src)
	new /obj/item/storage/box/detectivegun(src)
/*	new /obj/item/ammo/bullets/a38(src)  The detective's got more than enough ammo already (Convair880).
	new /obj/item/ammo/bullets/a38/stun(src)
	new /obj/item/gun/kinetic/detectiverevolver(src)  Moved to that box (Convair880).*/
	new /obj/item/device/flash(src)
	return ..()

/obj/secure_closet/turds
	name = "TURDS gear"
	req_access = list(access_armory)

/obj/secure_closet/turds/New()
	new /obj/item/clothing/gloves/black(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/head/helmet/turd(src)
	new /obj/item/clothing/shoes/swat(src)
	new /obj/item/clothing/suit/armor/turd(src)
	new /obj/item/clothing/under/misc/turds(src)

//	new /obj/item/gun/shotgun(src)
//	new /obj/item/ammo/abg(src)
//	new /obj/item/ammo/a12(src)
//	new /obj/item/ammo/a12(src)
//	new /obj/item/ammo/a12(src)
//	new /obj/item/ammo/a12(src)

//	new /obj/item/gun/fiveseven(src)
//	new /obj/item/ammo/a57(src)
//	new /obj/item/ammo/a57(src)
//	new /obj/item/ammo/a57(src)

	return ..()

/obj/secure_closet/security5
	name = "Commander Equipment"
	req_access = list(access_armory)

/obj/secure_closet/NTuni
	name = "NT Uniforms"
	req_access = list(access_armory)

/obj/secure_closet/NTuni/New()
	new /obj/item/clothing/under/misc/NT(src)
	new /obj/item/clothing/under/misc/NT(src)
	new /obj/item/clothing/under/misc/NT(src)
	new /obj/item/clothing/under/misc/NT(src)
	new /obj/item/clothing/gloves/black(src)
	new /obj/item/clothing/gloves/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)
	return ..()

/obj/secure_closet/NTE
	name = "NTE Gear"
	req_access = list(access_armory)

/obj/secure_closet/NTE/New()
//	new /obj/item/gun/energy/wave_gun(src)
//	new /obj/item/ammo/wave(src)
//	new /obj/item/ammo/wave(src)

	new /obj/item/gun/energy/disruptor(src)
	new /obj/item/ammo/power_cell/med_power(src)
	new /obj/item/ammo/power_cell/med_power(src)
	new /obj/item/handcuffs/tape_roll(src)
	new /obj/item/clothing/glasses/sunglasses(src)

	return ..()

/obj/secure_closet/NTarmor
	name = "NT Armor"
	req_access = list(access_armory)

/obj/secure_closet/NTarmor/New()
	new /obj/item/clothing/suit/armor/NT_alt(src)
	new /obj/item/clothing/suit/armor/NT_alt(src)
	new /obj/item/clothing/suit/armor/NT(src)
	new /obj/item/clothing/suit/armor/NT(src)
	new /obj/item/clothing/head/helmet/NT(src)
	new /obj/item/clothing/head/helmet/NT(src)
	return ..()

/obj/secure_closet/NTC
	name = "Commander Gear"
	req_access = list(access_armory)

/obj/secure_closet/NTC/New()
	new /obj/item/clothing/suit/armor/centcomm(src)
	new /obj/item/clothing/head/helmet(src)
	new /obj/item/clothing/under/suit/purple(src)
	new /obj/item/clothing/head/that/purple(src)
	new /obj/item/baton/cane(src)
	new /obj/item/gun/energy/disruptor(src)
	new /obj/item/ammo/power_cell(src)
	new /obj/item/ammo/power_cell(src)
	return ..()

/obj/secure_closet/scientist
	name = "Scientist Locker"
	icon_state = "science"
	icon_closed = "science"
	icon_opened = "medicalopen"
	req_access = list(access_tox_storage)

/obj/secure_closet/scientist/New()
	new /obj/item/tank/air(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/suit/bio_suit(src)
	new /obj/item/clothing/under/rank/scientist(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/latex(src)
	new /obj/item/clothing/head/bio_hood(src)
	new /obj/item/clothing/suit/labcoat(src)
	return ..()

/obj/secure_closet/research_director
	name = "Research Director's Locker"
	req_access = list(access_heads)

/obj/secure_closet/research_director/New()
	new /obj/item/plant/herb/cannabis/spawnable(src)
	new /obj/item/device/light/zippo(src)
	new /obj/item/clothing/under/rank/research_director(src)
	new /obj/item/clothing/head/fancy/rank(src)
	new /obj/item/clothing/under/rank/research_director/fancy(src)
	new /obj/item/clothing/suit/labcoat(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/circular_saw(src)
	new /obj/item/scalpel(src)
	new /obj/item/hand_tele(src)
	//new /obj/item/old_grenade/emp(src)
	new /obj/item/storage/box/zeta_boot_kit(src)
	new /obj/item/device/radio/electropack(src)
	new /obj/item/device/flash(src)
	if (prob(10))
		new /obj/item/photo/heisenbee (src)
	return ..()

/obj/secure_closet/medical_director
	name = "Medical Director's Locker"
	icon_state = "medical"
	icon_closed = "medical"
	icon_opened = "medicalopen"
	req_access = list(access_heads)

/obj/secure_closet/medical_director/New()
	new /obj/item/clothing/under/rank/medical_director(src)
	new /obj/item/clothing/head/fancy/rank(src)
	new /obj/item/clothing/under/rank/medical_director/fancy(src)
	new /obj/item/clothing/suit/labcoat(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/gun/kinetic/dart_rifle(src)
	new /obj/item/ammo/bullets/tranq_darts(src)
	new /obj/item/ammo/bullets/tranq_darts/anti_mutant(src)
	new /obj/item/storage/box/syringes(src)
	new /obj/item/robodefibrillator(src)
	new /obj/item/clothing/gloves/latex(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/circular_saw(src)
	new /obj/item/scalpel(src)
	new /obj/item/reagent_containers/glass/bottle/eyedrops(src)
	new /obj/item/reagent_containers/hypospray(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/device/flash(src)
	return ..()

/obj/secure_closet/medical_uniforms
	name = "Medical Uniforms"
	icon_state = "medical"
	icon_closed = "medical"
	icon_opened = "medicalopen"
	req_access = list(access_medical_lockers)

/obj/secure_closet/medical_uniforms/New()
	new /obj/item/storage/backpack/satchel/medic(src)
	new /obj/item/storage/backpack/satchel/medic(src)
	new /obj/item/storage/backpack/medic(src)
	new /obj/item/storage/backpack/medic(src)
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/shoes/red(src)
	new /obj/item/clothing/shoes/red(src)
	new /obj/item/clothing/suit/labcoat(src)
	new /obj/item/clothing/suit/labcoat(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/storage/box/stma_kit(src)
	new /obj/item/storage/box/lglo_kit(src)
	new /obj/item/clothing/glasses/healthgoggles(src)
	new /obj/item/clothing/glasses/healthgoggles(src)
	new /obj/item/device/radio/headset/medical(src)
	new /obj/item/device/radio/headset/medical(src)
	return ..()

/obj/secure_closet/chemtoxin
	name = "Chemistry Locker"
	req_access = list(access_medical)

/obj/secure_closet/bar
	name = "Booze"
	req_access = list(access_bar)

/obj/secure_closet/bar/New()
	new /obj/item/storage/box/beer(src)
	new /obj/item/storage/box/fruit_wedges(src)
	new /obj/item/storage/box/cocktail_doodads(src)
	new /obj/item/storage/box/cocktail_doodads(src)
	new /obj/item/storage/box/cocktail_umbrellas(src)
	new /obj/item/storage/box/cocktail_umbrellas(src)
	new /obj/item/reagent_containers/food/drinks/bottle/beer(src)
	new /obj/item/reagent_containers/food/drinks/bottle/beer(src)
	new /obj/item/reagent_containers/food/drinks/bottle/cider(src)
	new /obj/item/reagent_containers/food/drinks/bottle/cider(src)
	new /obj/item/reagent_containers/food/drinks/bottle/mead(src)
	new /obj/item/reagent_containers/food/drinks/bottle/mead(src)
	new /obj/item/reagent_containers/food/drinks/bottle/rum(src)
	new /obj/item/reagent_containers/food/drinks/bottle/rum(src)
	new /obj/item/reagent_containers/food/drinks/bottle/wine(src)
	new /obj/item/reagent_containers/food/drinks/bottle/wine(src)
	new /obj/item/reagent_containers/food/drinks/bottle/vodka(src)
	new /obj/item/reagent_containers/food/drinks/bottle/vodka(src)
	new /obj/item/reagent_containers/food/drinks/bottle/tequila(src)
	new /obj/item/reagent_containers/food/drinks/bottle/tequila(src)
	return ..()

/obj/secure_closet/kitchen
	name = "Kitchen Cabinet"
	req_access = list(access_kitchen)

/obj/secure_closet/kitchen/New()
	new /obj/item/clothing/head/chefhat(src)
	new /obj/item/clothing/head/chefhat(src)
	new /obj/item/clothing/under/rank/chef(src)
	new /obj/item/clothing/under/rank/chef(src)
	new /obj/item/kitchen/utensil/fork(src)
	new /obj/item/kitchen/utensil/knife(src)
	new /obj/item/kitchen/utensil/spoon(src)
	new /obj/item/kitchen/rollingpin(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/spaghetti(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/spaghetti(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/spaghetti(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/spaghetti(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/spaghetti(src)
	return ..()

/obj/secure_closet/meat
	name = "Meat Locker"

/obj/secure_closet/meat/New()
	new /obj/item/reagent_containers/food/snacks/ingredient/oatmeal(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/oatmeal(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/oatmeal(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/oatmeal(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/oatmeal(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/flour(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/flour(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/flour(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/flour(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/flour(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/flour(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/flour(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/flour(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/flour(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/flour(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/flour(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/sugar(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/sugar(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/sugar(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/sugar(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/sugar(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/sugar(src)

	if(prob(80))
		new /obj/item/reagent_containers/food/snacks/meatball(src)
		new /obj/item/reagent_containers/food/snacks/meatball(src)
		new /obj/item/reagent_containers/food/snacks/meatball(src)
		new /obj/item/reagent_containers/food/snacks/meatball(src)
	else
		new /obj/item/reagent_containers/food/snacks/burger/monkeyburger(src)
		new /obj/item/reagent_containers/food/snacks/burger/monkeyburger(src)
		new /obj/item/reagent_containers/food/snacks/burger/monkeyburger(src)
		new /obj/item/reagent_containers/food/snacks/burger/monkeyburger(src)
	return ..()

/obj/secure_closet/fridge
	name = "Refrigerator"
	icon_state = "fridge"
	icon_closed = "fridge"
	icon_opened = "fridgeopen"
	greenlight = "fridge-greenlight"
	redlight = "fridge-redlight"
	sparks = "fridge-sparks"

/obj/secure_closet/fridge/New()
	new /obj/item/reagent_containers/food/drinks/cola(src)
	new /obj/item/reagent_containers/food/drinks/cola(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/cheese(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/cheese(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/cheese(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/cheese(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/cheese(src)
	new /obj/item/reagent_containers/food/snacks/ingredient/cheese(src)
	new /obj/item/reagent_containers/food/drinks/milk(src)
	new /obj/item/reagent_containers/food/drinks/milk(src)
	new /obj/item/reagent_containers/food/drinks/milk(src)
	new /obj/item/reagent_containers/food/drinks/milk(src)
	new /obj/item/reagent_containers/food/drinks/milk(src)
	new /obj/item/kitchen/food_box/egg_box(src)
	new /obj/item/kitchen/food_box/egg_box(src)
	new /obj/item/storage/box/donkpocket_kit(src)
	new /obj/item/storage/box/bacon_kit(src)
	new /obj/item/storage/box/bacon_kit(src)
	if (prob(25))
		var/n = rand(2,10)
		while (n-- > 0)
			new /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget(src)
	return ..()

/obj/secure_closet/fridge_blood
	name = "blood supply refrigerator"
	icon_state = "fridge"
	icon_closed = "fridge"
	icon_opened = "fridgeopen"
	greenlight = "fridge-greenlight"
	redlight = "fridge-redlight"
	sparks = "fridge-sparks"

/obj/secure_closet/fridge_blood/New()
	new /obj/item/storage/box/iv_box(src)
	new /obj/item/reagent_containers/iv_drip/saline(src)
	new /obj/item/reagent_containers/iv_drip/blood(src)
	new /obj/item/reagent_containers/iv_drip/blood(src)
	new /obj/item/reagent_containers/iv_drip/blood(src)
	new /obj/item/reagent_containers/iv_drip/blood(src)
	var /obj/item/paper/P = new /obj/item/paper(src)
	P.name = "paper- 'angry note'"
	P.info = "This fridge is for BLOOD PACKS <u>ONLY</u>! If I ever catch the idiot who keeps leaving their lunch in here, you're taking a one-way trip to the goddamn solarium!<br><br><i>L. Alliman</i><br>"
	if (prob(11))
		new /obj/item/plate(src)
		if (prob(50))
			new /obj/item/reagent_containers/food/snacks/sandwich/meatball(src)
		else
			new /obj/item/reagent_containers/food/snacks/sandwich/pbh(src)
	return ..()

/obj/secure_closet/engineering_chief
	name = "Chief Engineer's Locker"
	req_access = list(access_heads)

/obj/secure_closet/engineering_chief/New()
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/clothing/under/rank/chief_engineer(src)
	new /obj/item/clothing/head/fancy/rank(src)
	new /obj/item/clothing/under/rank/chief_engineer/fancy(src)
	new /obj/item/clothing/gloves/yellow(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/magnetic(src)
	new /obj/item/clothing/ears/earmuffs(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/clothing/suit/fire(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/storage/belt/utility(src)
	new /obj/item/clothing/head/helmet/welding(src)
	new /obj/item/clothing/head/helmet/hardhat(src)
	new /obj/item/device/multitool(src)
	new /obj/item/device/flash(src)
	return ..()


/obj/secure_closet/engineering_electrical
	name = "Electrical Supplies"
	req_access = list(access_engineering_power)

/obj/secure_closet/engineering_electrical/New()
	new /obj/item/clothing/gloves/yellow(src)
	new /obj/item/clothing/gloves/yellow(src)
	new /obj/item/clothing/gloves/yellow(src)
	new /obj/item/storage/toolbox/electrical(src)
	new /obj/item/storage/toolbox/electrical(src)
	new /obj/item/storage/toolbox/electrical(src)
	new /obj/item/device/multitool(src)
	new /obj/item/device/multitool(src)
	new /obj/item/device/multitool(src)
	return ..()

/obj/secure_closet/engineering_welding
	name = "Welding Supplies"
	req_access = list(access_engineering)

/obj/secure_closet/engineering_welding/New()
	new /obj/item/clothing/head/helmet/welding(src)
	new /obj/item/clothing/head/helmet/welding(src)
	new /obj/item/clothing/head/helmet/welding(src)
	new /obj/item/weldingtool(src)
	new /obj/item/weldingtool(src)
	new /obj/item/weldingtool(src)
	return ..()

/obj/secure_closet/engineering_mech
	name = "Mechanic's Locker"
	req_access = list(access_engineering_power)

/obj/secure_closet/engineering_elect/New()
	new /obj/item/storage/toolbox/electrical(src)
	new /obj/item/clothing/under/rank/engineer(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/head/helmet/hardhat(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/pen/infared(src)
	new /obj/item/electronics/scanner(src)
	return ..()

/obj/secure_closet/engineering_env
	name = "Atmospheric Technician's Locker"
	req_access = list(access_engineering_atmos)

/obj/secure_closet/engineering_env/New()
	new /obj/item/clothing/under/misc/atmospheric_technician(src)
	new /obj/item/clothing/suit/fire(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/head/helmet/hardhat(src)
	new /obj/item/clothing/glasses/meson(src)
	return ..()

/obj/secure_closet/engineering_stru
	name = "Engineer's Locker"
	req_access = list(access_engineering_engine)

/obj/secure_closet/engineering_stru/New()
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/clothing/under/rank/engineer(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/head/helmet/hardhat(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/pen/infared(src)
	new /obj/item/clothing/head/helmet/welding(src)
	new /obj/item/storage/belt/utility(src)
	return ..()

/obj/secure_closet/barber
	name = "Barber Supplies"

/obj/secure_closet/mechanic
	name = "Hangar Supplies"
	req_access = list(access_hangar)

/obj/secure_closet/mechanic/New()
	new /obj/item/clothing/under/rank/mechanic(src)
	new /obj/item/clothing/under/rank/mechanic(src)
	new /obj/item/clothing/under/rank/mechanic(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/clothing/shoes/orange(src)
	return ..()

/obj/secure_closet/alter_health()
	return get_turf(src)

/obj/secure_closet/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	return src.opened

/obj/secure_closet/proc/can_close()
	for(var/obj/closet/closet in get_turf(src))
		return 0
	for(var/obj/secure_closet/closet in get_turf(src))
		if(closet != src)
			return 0
	return 1

/obj/secure_closet/proc/can_open()
	if (src.locked)
		return 0
	return 1

/obj/secure_closet/proc/dump_contents()
	var/newloc = get_turf(src)
	for (var/obj/item/I in src)
		I.set_loc(newloc)

	for (var/obj/overlay/o in src) //REMOVE THIS
		o.set_loc(newloc)

	for(var/mob/M in src)
		M.set_loc(newloc)

/obj/secure_closet/proc/bust_out()
	if(health)
		src.visible_message("<span class='alert'><b>[src]</b> [pick("cracks","bends","shakes","groans")].</span>")
		src.health--
	if(health <= 0)
		src.visible_message("<span class='alert'><b>[src]</b> breaks apart!</span>")
		src.dump_contents()
		sleep(0.1 SECONDS)
		var/newloc = src.loc
		new /obj/decal/cleanable/machine_debris(newloc)
		qdel(src)

/obj/secure_closet/proc/open()

	if (src.opened)
		return 0

	if (!src.can_open())
		return 0

	src.dump_contents()

	src.opened = 1
	src.update_overlays()
	playsound(src.loc, "sound/machines/click.ogg", 15, 1, -3)
	return 1

/obj/secure_closet/proc/close()
	if (!src.opened)
		return 0

	if (!src.can_close())
		return 0

	for (var/obj/item/I in src.loc)
		if (!I.anchored)
			I.set_loc(src)

	for (var/obj/overlay/o in src.loc) //REMOVE THIS
		if (!o.anchored)
			o.set_loc(src)

	for (var/mob/M in src.loc)
#ifdef HALLOWEEN
		if(halloween_mode && prob(5)) //remove the prob() if you want, it's just a little broken if dudes are constantly teleporting
			var/list/obj/closet/closets = list()
			for(var/obj/closet/O in world)
				LAGCHECK(LAG_LOW)
				if(O.z != src.z || O.opened || !O.can_open())
					continue
				closets.Add(O)

			var/obj/closet/warp_dest = pick(closets)
			M.set_loc(warp_dest)
			boutput(M, "<span class='alert'>You are suddenly thrown elsewhere!</span>")
			M.playsound_local(M.loc, "warp", 50, 1)

			continue
#endif
		if (isobserver(M) || iswraith(M) || isintangible(M))
			continue
		if (M.buckled)
			continue
		M.set_loc(src)

	src.opened = 0
	src.update_overlays()
	playsound(src.loc, "sound/machines/click.ogg", 15, 1, -3)
	return 1

/obj/secure_closet/verb/toggle_verb()
	set src in oview(1)
	set name = "Toggle"
	set desc = "Open or close the closet.  Whoa!"

	if (usr.stat || !usr.can_use_hands())
		return

	return toggle()

/obj/secure_closet/proc/toggle()
	if (src.opened)
		return src.close()
	return src.open()

/obj/secure_closet/ex_act(severity)
	switch(severity)
		if (1)
			for (var/atom/movable/A as mob|obj in src)
				A.set_loc(src.loc)
				A.ex_act(severity)
			qdel(src)
		if (2)
			if (prob(50))
				for (var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				qdel(src)
		if (3)
			if (prob(5))
				for (var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				qdel(src)

/obj/secure_closet/blob_act(var/power)
	if (prob(power * 2.5))
		dump_contents()
		qdel(src)

/obj/secure_closet/meteorhit(obj/O as obj)
	if (O.icon_state == "flaming")
		src.dump_contents()
		src.update_overlays()
		qdel(src)
		return
	return

/obj/secure_closet/bullet_act(flag)
/* Just in case someone gives closets health
	if (flag == PROJECTILE_BULLET)
		src.health -= 1
		src.healthcheck()
		return
	if (flag != PROJECTILE_LASER)
		src.health -= 3
		src.healthcheck()
		return
	else
		src.health -= 5
		src.healthcheck()
		return

	if(prob(1.5))
		for (var/atom/movable/A as mob|obj in src)
			A.set_loc(src.loc)
		qdel(src)
*/
	return
/obj/secure_closet/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if(!src.broken)
		src.broken = 1
		src.locked = 0
		src.update_overlays()
		if (user)
			user.visible_message("<span class='notice'>The locker has been broken by [user] with an electromagnetic card!</span>")
		return 1
	return 0

/obj/secure_closet/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/cargotele))
		W:cargoteleport(src, user)
		return

	if (src.opened && !issilicon(user))
		if (istype(W, /obj/item/grab))
			if (src.large)
				src.MouseDrop_T(W:affecting, user)	//act like they were dragged onto the closet
			else
				boutput(user, "The locker is too small to stuff [W] into!")
		user.drop_item()
		if(W?.loc && !(W.cant_drop || W.cant_self_remove))	W.set_loc(src.loc)
		return
	else if(src.broken)
		boutput(user, "<span class='alert'>It appears to be broken.</span>")
		return

	if(src.allowed(user))
		if(!src.opened)
			src.locked = !src.locked
			user.visible_message("<span class='notice'>The locker has been [src.locked ? null : "un"]locked by [user].</span>")
			src.update_overlays()
			return
		else
			src.close()
			return

	boutput(user, "<span class='alert'>Access Denied</span>")
	user.unlock_medal("Rookie Thief", 1)
	return

/obj/secure_closet/relaymove(mob/user as mob)
	if (user.stat)
		return
	if (!( src.locked ))
		for(var/obj/item/I in src)
			I.set_loc(src.loc)
		for(var/mob/M in src)
			M.set_loc(src.loc)
		src.opened = 1
		src.update_overlays()
	else
		if (!src.jiggled)
			src.jiggled = 1
			boutput(user, "<span class='notice'>It's welded shut!</span>")
			user.unlock_medal("IT'S A TRAP", 1)
			playsound(src.loc, "sound/effects/zhit.wav", 15, 1, -3)
			var/shakes = 5
			while (shakes > 0)
				shakes--
				src.pixel_x = rand(-5,5)
				src.pixel_y = rand(-5,5)
				sleep(0.1 SECONDS)
			src.pixel_x = 0
			src.pixel_y = 0
			SPAWN_DBG(0.5 SECONDS)
				src.jiggled = 0

	return

/obj/secure_closet/verb/move_inside()
	set src in oview(1)
	set category = "Local"

	if (usr.stat || !usr.can_use_hands() || usr.loc == src)
		return

	if (src.opened)
		step_towards(usr, src)
		sleep(1 SECOND)
		if (usr.loc == src.loc)
			src.close()
	else
		if (src.locked && src.allowed(usr))
			src.locked = !src.locked
			src.visible_message("<span class='notice'>The locker has been [src.locked ? null : "un"]locked by [usr].</span>")
			src.update_overlays()

		if (src.open())
			step_towards(usr, src)
			sleep(1 SECOND)
			if (usr.loc == src.loc)
				src.close()
	return

/obj/secure_closet/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if ((user.restrained() || user.stat))
		return
	if ((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)))
		return
	if(!src.opened)
		return
	if(istype(O, /obj/secure_closet) || istype(O, /obj/closet))
		return
	if(istype(O, /obj/screen))
		return
	step_towards(O, src.loc)
	if (user != O)
		user.visible_message("<span class='alert'>[user] stuffs [O] into [src]!</span>", "<span class='alert'>You stuff [O] into [src]!</span>")
	src.add_fingerprint(user)
	return
/*
/obj/secure_closet/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	if (!src.opened && !src.locked)
		if(!src.can_open())
			return
		//open it
		for(var/obj/item/I in src)
			I.set_loc(src.loc)
		for(var/mob/M in src)
			M.set_loc(src.loc)
		playsound(src.loc, "sound/machines/click.ogg", 15, 1, -3)
		src.opened = 1
		src.update_overlays()
	else if(src.opened)
		if(!src.can_close())
			return
		//close it
		for(var/obj/item/I in src.loc)
			if (!( I.anchored ))
				I.set_loc(src)
		for(var/mob/M in src.loc)
			if (M.buckled)
				continue
			M.set_loc(src)
		playsound(src.loc, "sound/machines/click.ogg", 15, 1, -3)
		src.opened = 0
		src.update_overlays()
	else
		return src.attackby(null, user)
	return*/

/obj/secure_closet/attack_hand(mob/user as mob)
	src.add_fingerprint(user)

	if (!src.toggle())
		return src.attackby(null, user)


/obj/secure_closet/attack_ai(mob/user)
	if (can_reach(user, src) && (isrobot(user) || isshell(user)))
		return src.attack_hand(user)
*/
