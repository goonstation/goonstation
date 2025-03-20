/datum/antagonist/pirate
	id = ROLE_PIRATE
	display_name = "\improper Pirate"
	antagonist_icon = "pirate"
	antagonist_panel_tab_type = /datum/antagonist_panel_tab/bundled/pirate
	has_info_popup = FALSE


	is_compatible_with(datum/mind/mind)
		return isliving(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			boutput(src.owner.current, SPAN_ALERT("Due to your lack of opposable thumbs, the pirates were unable to provide you with your equipment. That's biology for you."))
			return FALSE
		var/mob/living/carbon/human/H = src.owner.current
		var/obj/trinket
		if (H.trinket)
			trinket = H.trinket.deref()
			trinket.set_loc(null)
		H.unequip_all(TRUE)

		if (id == ROLE_PIRATE_CAPTAIN)
			H.equip_if_possible(new /obj/item/clothing/under/shirt_pants_b(H), SLOT_W_UNIFORM)
			H.equip_if_possible(new /obj/item/clothing/suit/armor/pirate_captain_coat(H), SLOT_WEAR_SUIT)
			H.equip_if_possible(new /obj/item/clothing/head/pirate_captain(H), SLOT_HEAD)
			H.equip_if_possible(new /obj/item/clothing/shoes/swat/heavy(H), SLOT_SHOES)
			H.equip_if_possible(new /obj/item/device/radio/headset/pirate/captain(H), SLOT_EARS)
			H.equip_if_possible(new /obj/item/card/id/pirate/captain, SLOT_WEAR_ID)

		else if (id == ROLE_PIRATE_FIRST_MATE)
			H.equip_if_possible(new /obj/item/clothing/under/gimmick/guybrush(H), SLOT_W_UNIFORM)
			H.equip_if_possible(new /obj/item/clothing/suit/armor/pirate_first_mate_coat(H), SLOT_WEAR_SUIT)
			H.equip_if_possible(new /obj/item/clothing/head/pirate_first_mate(H), SLOT_HEAD)
			H.equip_if_possible(new /obj/item/device/radio/headset/pirate/first_mate(H), SLOT_EARS)
			H.equip_if_possible(new /obj/item/card/id/pirate/first_mate, SLOT_WEAR_ID)

		else if (id == ROLE_PIRATE)
			// Random clothing:
			var/obj/item/clothing/jumpsuit = pick(/obj/item/clothing/under/gimmick/waldo,
							/obj/item/clothing/under/misc/serpico,
							/obj/item/clothing/under/gimmick/guybrush,
							/obj/item/clothing/under/misc/dirty_vest)
			var/obj/item/clothing/hat = pick(/obj/item/clothing/head/red,
							/obj/item/clothing/head/bandana/red,
							/obj/item/clothing/head/pirate_brn,
							/obj/item/clothing/head/pirate_blk)

			H.equip_if_possible(new jumpsuit, SLOT_W_UNIFORM)
			H.equip_if_possible(new hat, SLOT_HEAD)
			H.equip_if_possible(new /obj/item/device/radio/headset/pirate(H), SLOT_EARS)
			H.equip_if_possible(new /obj/item/card/id/pirate, SLOT_WEAR_ID)

		H.equip_if_possible(new /obj/item/storage/backpack(H), SLOT_BACK)
		H.equip_if_possible(new /obj/item/clothing/shoes/swat(H), SLOT_SHOES)
		H.equip_if_possible(new /obj/item/reagent_containers/food/drinks/flask/pirate(H), SLOT_IN_BACKPACK)
		H.equip_if_possible(new /obj/item/pinpointer/gold_bee(H), SLOT_IN_BACKPACK)
		H.equip_if_possible(new /obj/item/clothing/glasses/eyepatch/pirate(H), SLOT_GLASSES)
		H.equip_if_possible(new /obj/item/requisition_token/pirate(H), SLOT_R_STORE)
		H.equip_if_possible(new /obj/item/tank/emergency_oxygen/extended(H), SLOT_L_STORE)
		H.equip_if_possible(new /obj/item/swords_sheaths/pirate(H), SLOT_BELT)
		H.equip_if_possible(new /obj/item/pirate_hand_tele(H), SLOT_R_HAND)

		H.equip_sensory_items()

		H.traitHolder.addTrait("training_drinker")
		H.addBioEffect("accent_pirate")

	add_to_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_PIRATE)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())
		image_group.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_PIRATE)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)

	relocate()
		var/mob/M = src.owner.current
		if (id == ROLE_PIRATE_CAPTAIN)
			M.set_loc(pick_landmark(LANDMARK_PIRATE_CAPTAIN, LANDMARK_LATEJOIN)) // Needed because if not spawned pirate get nulled
		else if (id == ROLE_PIRATE_FIRST_MATE)
			M.set_loc(pick_landmark(LANDMARK_PIRATE_FIRST_MATE, LANDMARK_LATEJOIN))
		else
			M.set_loc(pick_landmark(LANDMARK_PIRATE, LANDMARK_LATEJOIN))

	first_mate
		id = ROLE_PIRATE_FIRST_MATE
		display_name = "\improper Pirate First Mate"
		antagonist_icon = "pirate_first_mate"

	captain
		id = ROLE_PIRATE_CAPTAIN
		display_name = "\improper Pirate Captain"
		antagonist_icon = "pirate_captain"

TYPEINFO(/obj/gold_bee)
	mat_appearances_to_ignore = list("gold")
/obj/gold_bee
	name = "\improper Gold Bee Statue"
	desc = "The artist has painstakingly sculpted every individual strand of bee wool to achieve this breath-taking result. You could almost swear this bee is about to spontaneously take flight."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "gold_bee"
	flags = FLUID_SUBMERGE | TGUI_INTERACTIVE
	object_flags = NO_GHOSTCRITTER
	density = 1
	anchored = UNANCHORED
	default_material = "gold"
	mat_changename = FALSE
	var/list/gibs = list()

	New()
		..()
		for(var/i in 1 to 7)
			gibs.Add(new /obj/item/stamped_bullion)
			gibs.Add(new /obj/item/raw_material/gold)

	attack_hand(mob/user)
		src.add_fingerprint(user)

		if (user.a_intent != INTENT_HARM)
			src.visible_message(SPAN_NOTICE("<b>[user]</b> pets [src]!"))

	attackby(obj/item/W, mob/user)
		src.add_fingerprint(user)
		user.lastattacked = get_weakref(src)

		src.visible_message(SPAN_COMBAT("<b>[user]</b> hits [src] with [W]!"))
		src.take_damage(W.force / 3)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 100, 1)
		attack_particle(user, src)

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round(((P.power/6)*P.proj_data.ks_ratio), 1.0)

		src.visible_message(SPAN_COMBAT("<b>[src]</b> is hit by [P]!"))
		if (damage <= 0)
			return
		if(P.proj_data.damage_type == D_KINETIC || (P.proj_data.damage_type == D_ENERGY && damage))
			src.take_damage(damage / 3)
		else if (P.proj_data.damage_type == D_PIERCING)
			src.take_damage(damage)

	proc/take_damage(var/amount)
		if (!isnum(amount) || amount < 1)
			return
		src._health = max(0,src._health - amount)

		if (src._health < 1)
			src.visible_message(SPAN_ALERT("<b>[src]</b> breaks and shatters into many peices!"))
			playsound(src.loc, 'sound/impact_sounds/plate_break.ogg', 50, 0.1, 0, 0.5)
			if (length(gibs))
				for (var/atom/movable/I in gibs)
					I.set_loc(get_turf(src))
					ThrowRandom(I, 3, 1)
			qdel(src)

/obj/landmark/pirate_tele
	name = LANDMARK_PIRATES_TELE

/obj/machinery/r_door_control/podbay/pirate
	id = "peregrine_podbay"
	access_type = POD_ACCESS_PIRATE

	new_walls
		north
			pixel_y = 24
		east
			pixel_x = 22
		south
			pixel_y = -19
		west
			pixel_x = -22

/obj/machinery/door/poddoor/blast/pyro/podbay_autoclose/pirate_podbay
	name = "Blast Shield"
	id = "peregrine_podbay"

/obj/machinery/door/poddoor/blast/pyro/podbay_autoclose/pirate_armory
	name = "Podbay Door"
	id = "peregrine_armory"

/obj/warp_beacon/pirate
	name = "Peregrine hangar beacon"
	icon_state = "beacon_synd"
	encrypted = POD_ACCESS_PIRATE

/obj/item/shipcomponent/communications/pirate
	name = "Pirate Communication Array"
	desc = "A patchwork of mismatched components, boasts an unexpected proficiency in homing in on elusive warp beacons."
	color = "#91681c"
	access_type = list(POD_ACCESS_PIRATE)

TYPEINFO(/obj/item/salvager_hand_tele)
	mats = list("metal" = 5,
				"energy" = 5,
				"conductive_high" = 5,
				"telecrystal" = 30)
/obj/item/pirate_hand_tele
	name = "makeshift teleporter"
	icon = 'icons/obj/items/device.dmi'
	desc = "A questionable portable teleportation device that is coupled to a specific location."
	icon_state = "hand_tele"
	item_state = "electronic"
	throwforce = 5
	health = 5
	w_class = W_CLASS_SMALL
	c_flags = ONBELT
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	var/image/indicator
	var/image/indicator_light

	New()
		..()
		indicator = image(src.icon, "hand_tele_o")
		indicator_light = image(src.icon, "hand_tele_o", layer=LIGHTING_LAYER_BASE)
		indicator_light.blend_mode = BLEND_ADD
		indicator_light.plane = PLANE_LIGHTING
		indicator_light.color = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5)

	get_help_message(dist, mob/user)
		. = "Use it in hand to return to the Peregrine. Use it on someone else to send your target to the Peregrine instead."

	attack_self(mob/user)
		. = ..()
		if(!ispirate(user)) src.malfunction(user)
		if (!isturf(user.loc))
			boutput(user, SPAN_ALERT("It wouldn't be safe to use \the [src] from inside of \the [user.loc]!"))
			return
		if(length(landmarks[LANDMARK_PIRATES_TELE]))
			if (!ON_COOLDOWN(src, "recharging", 15 SECONDS))
				actions.start(new /datum/action/bar/pirate_tele(user, src), user)
			else
				user.show_message(SPAN_ALERT("It's still recharging!"))
		else
			user.show_message(SPAN_ALERT("Something is wrong..."))

	// teleport a friend
	attack(mob/target, mob/user, def_zone, is_special, params)
		if (!ispirate(user))
			src.malfunction(user)
			return
		if (target.anchored)
			boutput(user, SPAN_ALERT("Teleportation failed due to interference."))
			return

		if(length(landmarks[LANDMARK_PIRATES_TELE]))
			if (!ON_COOLDOWN(src, "recharging", 15 SECONDS))
				actions.start(new /datum/action/bar/pirate_tele(target, src), user)
			else
				user.show_message(SPAN_ALERT("It's still recharging!"))
			return
		else
			user.show_message(SPAN_ALERT("Something is wrong..."))

	proc/malfunction(mob/user)
		switch(rand(1,10))
			if(1 to 5)
				boutput(user, SPAN_ALERT("You can't make any sense of this device.  Maybe it isn't for you."))
			if(6 to 8)
				boutput(user, SPAN_ALERT("\the [src] screen flashes momentarily before discharing a shock."))
				user.shock(src, 2500, "chest", 1, 1)
				user.changeStatus("stunned", 3 SECONDS)
			if(9 to 10)
				boutput(user, SPAN_ALERT("[src] gets really hot... and explodes?!?"))
				elecflash(src)
				user.u_equip(src)
				qdel(src)

/datum/action/bar/pirate_tele
	duration = 6 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	var/atom/movable/target
	var/obj/item/pirate_hand_tele/device

	New(Target, Device)
		target = Target
		device = Device
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if(prob(25))
			elecflash(device)

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		playsound(owner.loc, 'sound/machines/click.ogg', 60, 1)

	onEnd()
		..()
		var/turf/destination = pick(landmarks[LANDMARK_PIRATES_TELE])
		animate_teleport(target)
		SPAWN(6 DECI SECONDS)
			showswirl(target)
			target.set_loc(destination)
			showswirl(target)
			elecflash(src)
