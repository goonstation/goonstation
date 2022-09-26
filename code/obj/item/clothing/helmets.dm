// CHUMP HELMETS: COOKING THEM DESTROYS THE CHUMP HELMET SPAWN.

/obj/item/clothing/head/helmet
	name = "helmet"
	icon_state = "helmet"
	c_flags = COVERSEYES
	item_state = "helmet"
	desc = "Somewhat protects your head from being bashed in."
	protective_temperature = 500
	duration_remove = 5 SECONDS

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("heatprot", 10)
		setProperty("meleeprot_head", 4)

/obj/item/clothing/head/helmet/space
	name = "space helmet"
	icon_state = "space"
	c_flags = SPACEWEAR | COVERSEYES | COVERSMOUTH | BLOCKCHOKE
	see_face = 0
	item_state = "s_helmet"
	desc = "Helps protect against vacuum."
	hides_from_examine = C_EARS|C_MASK|C_GLASSES
	seal_hair = 1
	path_prot = 0

	setupProperties()
		..()
		setProperty("coldprot", 20)
		setProperty("heatprot", 5)
		setProperty("viralprot", 50)
		setProperty("chemprot", 20)
		setProperty("disorient_resist_eye", 8)
		setProperty("disorient_resist_ear", 8)
		setProperty("space_movespeed", 0.2)
		setProperty("radprot", 5)

	oldish
		icon_state = "space-OLD"
		desc = "A relic of the past."
		item_state = null

/obj/item/clothing/head/helmet/space/engineer
	name = "engineering space helmet"
	desc = "Comes equipped with a builtin flashlight."
	icon_state = "espace0"
	uses_multiple_icon_states = 1
	c_flags = SPACEWEAR | COVERSEYES | COVERSMOUTH
	see_face = 0
	item_state = "s_helmet"
	var/on = 0

	var/datum/component/loctargeting/medium_directional_light/light_dir

	New()
		..()
		light_dir = src.AddComponent(/datum/component/loctargeting/medium_directional_light, 0.9 * 255, 0.9 * 255, 1 * 255, 210)
		if(ismob(src.loc))
			light_dir.light_target = src.loc
		light_dir.update(0)

	attack_self(mob/user)
		src.flashlight_toggle(user, activated_inhand = TRUE)
		return

	proc/flashlight_toggle(var/mob/user, var/force_on = 0, activated_inhand = FALSE)
		on = !on
		src.icon_state = "espace[on]"
		if (on)
			light_dir.update(1)
		else
			light_dir.update(0)
		user.update_clothing()
		if (activated_inhand)
			var/obj/ability_button/flashlight_engiehelm/flashlight_button = locate(/obj/ability_button/flashlight_engiehelm) in src.ability_buttons
			flashlight_button.icon_state = src.on ? "lighton" : "lightoff"
		return

/obj/item/clothing/head/helmet/space/engineer/april_fools
	icon_state = "espace0-alt"

	flashlight_toggle(var/mob/user, var/force_on = 0, activated_inhand = FALSE)
		on = !on
		src.icon_state = "espace[on]-alt"
		if (on)
			light_dir.update(1)
		else
			light_dir.update(0)
		user.update_clothing()
		if (activated_inhand)
			var/obj/ability_button/flashlight_engiehelm/flashlight_button = locate(/obj/ability_button/flashlight_engiehelm) in src.ability_buttons
			flashlight_button.icon_state = src.on ? "lighton" : "lightoff"
		return

/obj/item/clothing/head/helmet/space/engineer/abilities = list(/obj/ability_button/flashlight_engiehelm)

/obj/item/clothing/head/helmet/space/captain
	name = "captain's space helmet"
	icon_state = "space-captain"
	item_state = "space-captain"
	desc = "Helps protect against vacuum. Comes in an interesting green befitting the captain."

	setupProperties()
		..()
		setProperty("space_movespeed", 0.1)

	blue
		name = "commander's space helmet"
		icon_state = "space-captain-blue"
		item_state = "space-captain-blue"
		desc = "Helps protect against vacuum. Comes in a fasionable blue befitting a commander."

	red
		name = "commander's space helmet"
		icon_state = "space-captain-red"
		item_state = "space-captain-red"
		desc = "Helps protect against vacuum. Comes in a fasionable red befitting a commander."

/obj/item/clothing/head/helmet/space/neon
	name = "neon space helmet"
	icon_state = "space-cute"
	item_state = "space-cute"
	desc = "Helps protect against vacuum. Comes in a unique, flashy style."

/obj/item/clothing/head/helmet/space/custom
	name = "bespoke space helmet"
	desc = "A custom built helmet with a fancy visor!"
	icon_state = "spacemat"

	var/image/fabrItemImg = null
	var/image/fabrWornImg = null
	var/image/visrItemImg = null
	var/image/visrWornImg = null

	New()
		..()
		// Prep the item overlays
		fabrItemImg = SafeGetOverlayImage("item-helmet", src.icon, "spacemat")
		visrItemImg = SafeGetOverlayImage("item-visor", src.icon, "spacemat-vis")
		// Prep the worn overlays
		fabrWornImg = SafeGetOverlayImage("worn-helmet", src.wear_image_icon, "spacemat")
		visrWornImg = SafeGetOverlayImage("worn-visor", src.wear_image_icon, "spacemat-vis")

	proc/set_custom_mats(datum/material/helmMat, datum/material/visrMat)
		src.setMaterial(
			helmMat,
			FALSE, // We want to purely rely on the overlay colours
		)
		name = "[visrMat]-visored [helmMat] helmet"

		// Setup the clothing stats based on material properties
		var/prot = max(0, (5 - visrMat.getProperty("thermal")) * 5)
		setProperty("coldprot", 10+prot)
		setProperty("heatprot", 2+round(prot/2))
		// All crystals (assuming default chem value) will give 20 chemprot, same as normal helm
		prot =  clamp(((visrMat.getProperty("chemical") - 4) * 10), 0, 35)
		setProperty("chemprot", prot)
		 // Even if soft visor, still gives some value
		prot = max(0, visrMat.getProperty("density") - 3) / 2
		setProperty("meleeprot_head", 3 + prot)

		// Setup item overlays
		fabrItemImg.color = helmMat.color
		visrItemImg.color = visrMat.color
		UpdateOverlays(visrItemImg, "item-visor")
		UpdateOverlays(fabrItemImg, "item-helmet")
		// Setup worn overlays
		fabrWornImg.color = helmMat.color
		visrWornImg.color = visrMat.color
		src.wear_image.overlays += fabrWornImg
		src.wear_image.overlays += visrWornImg
		// Add back the helmet texture since we overide the material apparance
		if (helmMat.texture)
			src.setTexture(helmMat.texture, helmMat.texture_blend, "material")

// Sealab helmets

/obj/item/clothing/head/helmet/space/engineer/diving //hijacking engiehelms for the flashlight
	name = "diving helmet"
	desc = "Comes equipped with a builtin flashlight."
	icon_state = "diving0"
	acid_survival_time = 8 MINUTES

	flashlight_toggle(var/mob/user, var/force_on = 0, activated_inhand = FALSE)
		on = !on
		src.icon_state = "diving[on]"
		if (on)
			light_dir.update(1)
		else
			light_dir.update(0)
		user.update_clothing()
		if (activated_inhand)
			var/obj/ability_button/flashlight_engiehelm/flashlight_button = locate(/obj/ability_button/flashlight_engiehelm) in src.ability_buttons
			flashlight_button.icon_state = src.on ? "lighton" : "lightoff"
		return

	security
		name = "security diving helmet"
		icon_state = "diving-sec0"

		flashlight_toggle(var/mob/user, var/force_on = 0, activated_inhand = FALSE)
			on = !on
			src.icon_state = "diving-sec[on]"
			if (on)
				light_dir.update(1)
			else
				light_dir.update(0)
			user.update_clothing()
			if (activated_inhand)
				var/obj/ability_button/flashlight_engiehelm/flashlight_button = locate(/obj/ability_button/flashlight_engiehelm) in src.ability_buttons
				flashlight_button.icon_state = src.on ? "lighton" : "lightoff"
			return

	civilian
		name = "civilian diving helmet"
		icon_state = "diving-civ0"

		flashlight_toggle(var/mob/user, var/force_on = 0, activated_inhand = FALSE)
			on = !on
			src.icon_state = "diving-civ[on]"
			if (on)
				light_dir.update(1)
			else
				light_dir.update(0)
			user.update_clothing()
			if (activated_inhand)
				var/obj/ability_button/flashlight_engiehelm/flashlight_button = locate(/obj/ability_button/flashlight_engiehelm) in src.ability_buttons
				flashlight_button.icon_state = src.on ? "lighton" : "lightoff"
			return

	command
		name = "command diving helmet"
		icon_state = "diving-com0"

		flashlight_toggle(var/mob/user, var/force_on = 0, activated_inhand = FALSE)
			on = !on
			src.icon_state = "diving-com[on]"
			if (on)
				light_dir.update(1)
			else
				light_dir.update(0)
			user.update_clothing()
			if (activated_inhand)
				var/obj/ability_button/flashlight_engiehelm/flashlight_button = locate(/obj/ability_button/flashlight_engiehelm) in src.ability_buttons
				flashlight_button.icon_state = src.on ? "lighton" : "lightoff"
			return

	engineering
		name = "engineering diving helmet"
		icon_state = "diving-eng0"

		flashlight_toggle(var/mob/user, var/force_on = 0, activated_inhand = FALSE)
			on = !on
			src.icon_state = "diving-eng[on]"
			if (on)
				light_dir.update(1)
			else
				light_dir.update(0)
			user.update_clothing()
			if (activated_inhand)
				var/obj/ability_button/flashlight_engiehelm/flashlight_button = locate(/obj/ability_button/flashlight_engiehelm) in src.ability_buttons
				flashlight_button.icon_state = src.on ? "lighton" : "lightoff"
			return

/obj/item/clothing/head/helmet/space/engineer/diving/abilities = list(/obj/ability_button/flashlight_engiehelm)

/obj/item/clothing/head/helmet/space/syndicate
	name = "red space helmet"
	icon_state = "syndicate"
	item_state = "space_helmet_syndicate"
	desc = "The standard space helmet of the dreaded Syndicate."
	item_function_flags = IMMUNE_TO_ACID
	team_num = TEAM_SYNDICATE
	blocked_from_petasusaphilic = TRUE

	New()
		..()
		setProperty("chemprot",30)
		setProperty("heatprot", 15)
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)

	#ifdef MAP_OVERRIDE_POD_WARS
	attack_hand(mob/user)
		if (get_pod_wars_team_num(user) == team_num)
			..()
		else
			boutput(user, "<span class='alert'>The space helmet <b>explodes</b> as you reach out to grab it!</span>")
			make_fake_explosion(src)
			user.u_equip(src)
			src.dropped(user)
			qdel(src)
	#endif

	setupProperties()
		..()
		setProperty("space_movespeed", 0)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	old
		icon_state = "syndicate-OLD"
		desc = "A relic of the past."
		item_state = null

	commissar_cap
		name = "commander's cap"
		icon_state = "syndie_commander"
		desc = "A terrifyingly tall, black & red cap, typically worn by a Syndicate Nuclear Operative Commander. Maybe they're trying to prove something to the Head of Security?"
		seal_hair = 0
		see_face = 1
		team_num = TEAM_SYNDICATE

		setupProperties()
			..()
			setProperty("exploprot", 10)

		#ifdef MAP_OVERRIDE_POD_WARS
		attack_hand(mob/user)
			if (get_pod_wars_team_num(user) == team_num)
				..()
			else
				boutput(user, "<span class='alert'>The cap <b>explodes</b> as you reach out to grab it!</span>")
				make_fake_explosion(src)
				user.u_equip(src)
				src.dropped(user)
				qdel(src)
		#endif

	specialist
		name = "specialist combat helmet"
		desc = "A modified combat helmet for syndicate operative specialists."
		icon_state = "syndie_specialist"
		item_state = "syndie_specialist"

		setupProperties()
			..()
			setProperty("exploprot", 10)

		infiltrator
			name = "specialist combat helmet"
			desc = "A modified combat helmet for syndicate operative specialists."
			icon_state = "syndie_specialist-infiltrator"
			item_state = "syndie_specialist-infiltrator"

		firebrand
			name = "specialist combat helmet"
			icon_state = "syndie_specialist-firebrand"
			item_state = "syndie_specialist-firebrand"

		unremovable
			cant_self_remove = 1
			cant_other_remove = 1

		engineer
			name = "specialist welding helmet"
			icon_state = "syndie_specialist"
			item_state = "syndie_specialist"
			c_flags = SPACEWEAR | COVERSEYES
			see_face = 0
			protective_temperature = 1300
			abilities = list(/obj/ability_button/nukie_meson_toggle)
			var/on = 0

			attack_self(mob/user)
				src.toggle(user)

			proc/toggle(var/mob/toggler)
				src.on = !src.on
				playsound(src, 'sound/items/mesonactivate.ogg', 30, 1)
				if (ishuman(toggler))
					var/mob/living/carbon/human/H = toggler
					if (istype(H.head, /obj/item/clothing/head/helmet/space/syndicate/specialist/engineer)) //handling of the rest is done in life.dm
						if (src.on)
							H.vision.set_scan(1)
							APPLY_ATOM_PROPERTY(toggler, PROP_MOB_MESONVISION, src)
						else
							H.vision.set_scan(0)
							REMOVE_ATOM_PROPERTY(toggler, PROP_MOB_MESONVISION, src)

			equipped(var/mob/living/user, var/slot)
				..()
				if(!isliving(user))
					return
				if (slot == SLOT_HEAD && on)
					user.vision.set_scan(1)
					APPLY_ATOM_PROPERTY(user, PROP_MOB_MESONVISION, src)

			unequipped(var/mob/living/user)
				..()
				if(!isliving(user))
					return
				user.vision.set_scan(0)
				REMOVE_ATOM_PROPERTY(user, PROP_MOB_MESONVISION, src)

		medic
			name = "specialist health monitor"
			icon_state = "syndie_specialist"
			item_state = "syndie_specialist"
			c_flags = SPACEWEAR | COVERSEYES | COVERSMOUTH | BLOCKCHOKE

			setupProperties()
				..()
				setProperty("viralprot", 50)

			equipped(var/mob/user, var/slot)
				..()
				if (slot == SLOT_HEAD)
					APPLY_ATOM_PROPERTY(user,PROP_MOB_EXAMINE_HEALTH_SYNDICATE,src)
					get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).add_mob(user)

			unequipped(var/mob/user)
				if(src.equipped_in_slot == SLOT_HEAD)
					REMOVE_ATOM_PROPERTY(user,PROP_MOB_EXAMINE_HEALTH_SYNDICATE,src)
					get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(user)
				..()

		sniper
			name = "specialist combat cover"
			icon_state = "syndie_specialist-sniper"
			item_state = "syndie_specialist-sniper"

		knight
			name = "heavy specialist great helm"
			desc = "A menacing full-face helmet for syndicate super-heavies."
			icon_state = "syndie_specialist-knight"
			item_state = "syndie_specialist-knight"

			setupProperties()
				..()
				setProperty("meleeprot_head", 6)
				setProperty("rangedprot", 1)
				setProperty("disorient_resist_eye", 50)
				setProperty("disorient_resist_ear", 50)
				setProperty("space_movespeed", 0.3)

		bard
			name = "anarchist performance helmet"
			desc = "The tall decorative mohawk inspires both fear and envy."
			icon_state = "syndie_specialist-bard"
			item_state = "syndie_specialist-bard"


/obj/item/clothing/head/helmet/space/ntso //recoloured nuke class suits for ntso vs syndicate specialist
	name = "NT combat helmet"
	desc = "A modified combat helmet for Nanotrasen security forces."
	icon_state = "ntso_specialist"
	item_state = "ntso_specialist"
	acid_survival_time = 6 MINUTES

	setupProperties()
		..()
		setProperty("space_movespeed", 0)


	unremovable
		cant_self_remove = 1
		cant_other_remove = 1

/obj/item/clothing/head/helmet/space/nanotrasen
	name = "Nanotrasen Heavy Helmet"
	icon_state = "nthelm2"
	item_state = "nthelm2"
	desc = "Well protected helmet used by certain Nanotrasen bodyguards."

/obj/item/clothing/head/helmet/space/nanotrasen/pilot
	name = "Nanotrasen Pilot Helmet"
	icon_state = "nanotrasen_pilot"
	item_state = "nanotrasen_pilot"
	desc = "A space helmet used by certain Nanotrasen pilots."
	team_num = TEAM_NANOTRASEN
	#ifdef MAP_OVERRIDE_POD_WARS
	attack_hand(mob/user)
		if (get_pod_wars_team_num(user) == team_num)
			..()
		else
			boutput(user, "<span class='alert'>The space helmet <b>explodes</b> as you reach out to grab it!</span>")
			make_fake_explosion(src)
			user.u_equip(src)
			src.dropped(user)
			qdel(src)
	#endif

	setupProperties()
		..()
		setProperty("chemprot",30)
		setProperty("space_movespeed", 0)

/obj/item/clothing/head/helmet/swat
	name = "swat helmet"
	icon_state = "swat"
	c_flags = COVERSEYES | BLOCKCHOKE
	item_state = "swat_hel"
	setupProperties()
		..()
		setProperty("meleeprot_head", 7)

/obj/item/clothing/head/helmet/turd
	name = "T.U.R.D.S. helmet"
	icon_state = "turdhelm"
	c_flags = COVERSEYES | BLOCKCHOKE
	hides_from_examine = C_EARS
	item_state = "turdhelm"
	setupProperties()
		..()
		setProperty("meleeprot_head", 7)

/obj/item/clothing/head/helmet/thunderdome
	name = "Thunderdome helmet"
	icon_state = "thunderdome"
	c_flags = COVERSEYES | BLOCKCHOKE
	item_state = "tdhelm"
	setupProperties()
		..()
		setProperty("meleeprot_head", 7)

/obj/item/clothing/head/helmet/hardhat
	name = "hard hat"
	icon_state = "hardhat0"
	uses_multiple_icon_states = 1
	item_state = "hardhat0"
	desc = "Protects your head from falling objects, and comes with a flashlight. Safety first!"
	var/on = 0
	var/datum/component/loctargeting/simple_light/light_dir

	setupProperties()
		..()
		setProperty("meleeprot_head", 5)

	New()
		..()
		light_dir = src.AddComponent(/datum/component/loctargeting/medium_directional_light, 0.9 * 255, 0.9 * 255, 1 * 255, 210)
		if(ismob(src.loc))
			light_dir.light_target = src.loc
		light_dir.update(0)

	attack_self(mob/user)
		src.flashlight_toggle(user)
		return

	proc/flashlight_toggle(var/mob/user, var/force_on = 0)
		on = !on
		src.icon_state = "hardhat[on]"
		src.item_state = "hardhat[on]"
		user.update_clothing()
		if (on)
			light_dir.update(1)
		else
			light_dir.update(0)
		return

	attackby(var/obj/item/T, mob/user as mob)
		if(istype(T, /obj/item/device/prox_sensor) && src.type == /obj/item/clothing/head/helmet/hardhat) //No derivatives
			boutput(user,  "You attach the proximity sensor to the hard hat. Now you need to add a robot arm.")
			new /obj/item/digbotassembly(get_turf(src))
			qdel(T)
			qdel(src)
			return
		else
			..()

/obj/item/clothing/head/helmet/hardhat/security // Okay it's not actually a HARDHAT but why write extra code?
	name = "helmet"
	icon_state = "helmet-sec"
	uses_multiple_icon_states = 1
	c_flags = COVERSEYES | BLOCKCHOKE
	item_state = "helmet"
	desc = "Somewhat protects your head from being bashed in."
	protective_temperature = 500

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("heatprot", 10)
		setProperty("meleeprot_head", 5)

	flashlight_toggle(var/mob/user, var/force_on = 0)
		on = !on
		user.update_clothing()
		if (on)
			light_dir.update(1)
		else
			light_dir.update(0)
		return

	attack_self(mob/user as mob) //Azungar was here and added some of his own styles to this thing.
		user.show_text("You change the helmet's style.")
		if (src.icon_state == "helmet-sec")
			src.icon_state = "helmet"
			src.item_state = "helmet"
		else if (src.icon_state == "helmet")
			src.icon_state = "helmet-sec-alt"
			src.item_state = "helmet-sec-alt"
		else if (src.icon_state == "helmet-sec-alt")
			src.icon_state = "helmet-sec-alt2"
			src.item_state = "helmet-sec-alt2"
		else
			src.icon_state = "helmet-sec"
			src.item_state = "helmet-sec"

/obj/item/clothing/head/helmet/hardhat/security/improved // Azungar's more out of style helmet that can only be bought through QM.
	name = "elite helmet"
	icon_state = "helmet-sec-elite"
	desc = "Better protection from getting your head bashed in."
	c_flags = COVERSEYES | COVERSMOUTH | BLOCKCHOKE
	seal_hair = 1
	item_state = "helmet-sec-elite"

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("heatprot", 10)
		setProperty("meleeprot_head", 8)

	attack_self(mob/user as mob)
		return


/obj/item/clothing/head/helmet/hardhat/abilities = list(/obj/ability_button/flashlight_hardhat)

/obj/item/clothing/head/helmet/camera
	name = "camera helmet"
	desc = "A helmet with a built in camera."
	icon_state = "camhat"
	mats = list("MET-1"=4, "CRY-1"=2, "CON-1"=2)
	item_state = "camhat"
	var/obj/machinery/camera/camera = null
	var/camera_tag = "Helmet Cam"
	var/camera_network = "Zeta"
	var/static/camera_counter = 0

	New()
		..()
		if(src.camera_tag == initial(src.camera_tag))
			src.camera_tag = "Built [src.camera_tag] [src.camera_counter]"
			camera_counter++
		src.camera = new /obj/machinery/camera (src)
		src.camera.c_tag = src.camera_tag
		src.camera.network = src.camera_network

/obj/item/clothing/head/helmet/camera/security
	name = "security camera helmet"
	desc = "A red helmet with a built in camera. It has a little note taped to it that says \"Security\"."
	icon_state = "redcamhat"
	item_state = "redcamhat"
	camera_tag = "Security Helmet Cam"

/obj/item/clothing/head/helmet/jetson
	name = "Fifties America Reclamation Team Helmet"
	desc = "Combat helmet used by a minor terrorist group."
	icon_state = "jetson1"
	icon_state = "jetson"
	item_state = "jetson"
	setupProperties()
		..()
		setProperty("meleeprot_head", 3)

/obj/item/clothing/head/helmet/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye. Can be flipped up for clearer vision."
	icon_state = "welding"
	c_flags = COVERSEYES | BLOCKCHOKE
	hides_from_examine = C_EARS|C_MASK|C_GLASSES
	see_face = FALSE
	item_state = "welding"
	protective_temperature = 1300
	m_amt = 3000
	g_amt = 1000
	var/up = FALSE // The helmet's current position

	setupProperties()
		..()
		setProperty("meleeprot_head", 1)
		setProperty("disorient_resist_eye", 100)

	proc/obscure(mob/user)
		user.addOverlayComposition(/datum/overlayComposition/weldingmask)
		user.updateOverlaysClient(user.client)

	proc/reveal(mob/user)
		user.removeOverlayComposition(/datum/overlayComposition/weldingmask)
		user.updateOverlaysClient(user.client)

	proc/flip_down(var/mob/living/carbon/human/user)
		up = FALSE
		see_face = FALSE
		icon_state = "welding"
		boutput(user, "You flip the mask down. The mask is now protecting you from eye damage.")
		if (user.head == src)
			src.obscure(user)
			user.update_clothing()

		src.c_flags |= (COVERSEYES | BLOCKCHOKE)
		setProperty("meleeprot_head", 1)
		setProperty("disorient_resist_eye", 100)

	proc/flip_up(var/mob/living/carbon/human/user)
		up = TRUE
		see_face = TRUE
		icon_state = "welding-up"
		boutput(user, "You flip the mask up. The mask is now providing greater armor to your head.")
		if (user.head == src)
			src.reveal(user)
			user.update_clothing()

		src.c_flags &= ~(COVERSEYES | BLOCKCHOKE)
		setProperty("meleeprot_head", 4)
		setProperty("disorient_resist_eye", 0)

	equipped(mob/user, slot)
		. = ..()
		if (!src.up)
			src.obscure(user)

	unequipped(mob/user)
		. = ..()
		src.reveal(user)

	disposing()
		. = ..()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/owner = src.loc
			if (owner.head == src) //human is actually wearing it
				src.reveal(owner)

	attack_self(mob/user) //let people toggle these inhand too
		for(var/obj/ability_button/mask_toggle/toggle in ability_buttons)
			toggle.execute_ability() //This is a weird way of doing it but we'd have to get the ability button to update the icon anyhow
		..()


/obj/item/clothing/head/helmet/welding/abilities = list(/obj/ability_button/mask_toggle)

/obj/item/clothing/head/helmet/EOD
	name = "blast helmet"
	desc = "A thick head cover made of layers upon layers of space kevlar."
	icon_state = "EOD"
	item_state = "tdhelm"
	c_flags = COVERSEYES | BLOCKCHOKE
	hides_from_examine = C_EARS
	setupProperties()
		..()
		setProperty("meleeprot_head", 9)
		setProperty("disorient_resist_eye", 25)
		setProperty("exploprot", 20)
		setProperty("movespeed", 0.15)

/obj/item/clothing/head/helmet/siren
	name = "siren helmet"
	desc = "A big flashing light that you put on your head. It also plays a siren for when you need to arrest someone!"
	icon_state = "siren0"
	uses_multiple_icon_states = 1
	item_state = "siren"
	mats = 8
	abilities = list(/obj/ability_button/weeoo) // is near segway code in vehicle.dm
	var/weeoo_in_progress = 0
	var/datum/light/light

	setupProperties()
		..()
		setProperty("meleeprot_head", 5)

	New()
		..()
		var/obj/ability_button/weeoo/NB = new
		//NB.screen_loc = "NORTH-2,1"
		abilities += NB
		light = new /datum/light/point
		light.set_brightness(0.7)
		light.set_height(1.8)
		light.attach(src)

	proc/weeoo()
		if (weeoo_in_progress)
			return
		weeoo_in_progress = 10
		SPAWN(0)
			playsound(src.loc, 'sound/machines/siren_police.ogg', 50, 1)
			light.enable()
			src.icon_state = "siren1"
			for (weeoo_in_progress, weeoo_in_progress > 0, weeoo_in_progress--)
				light.set_color(0.9, 0.1, 0.1)
				if (!weeoo_in_progress)
					break
				sleep(0.3 SECONDS)
				if (!weeoo_in_progress)
					break
				light.set_color(0.1, 0.1, 0.9)
				sleep(0.3 SECONDS)
			light.disable()
			src.icon_state = "siren0"
			weeoo_in_progress = 0

	unequipped(var/mob/user)
		..()
		if (src.weeoo_in_progress)
			src.weeoo_in_progress = 0

	pickup(mob/user)
		..()
		light.attach(user)

	dropped(mob/user)
		..()
		SPAWN(0)
			if (src.loc != user)
				light.attach(src)

/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	desc = "Good Lord, this thing is heavy. How the hell is anyone supposed to see out of this?"
	icon_state = "riot"//Awww yeah, sprites
	item_state = "riot"//go buttes, go
	color_r = 0.7
	color_g = 0.7
	color_b = 0.8
	c_flags = BLOCKCHOKE
	setupProperties()
		..()
		setProperty("meleeprot_head", 10)
		setProperty("disorient_resist_eye", 50)
		setProperty("disorient_resist_ear", 30)
		setProperty("movespeed", 0.5)

/obj/item/clothing/head/helmet/NT
	name = "\improper Nanotrasen helmet"
	desc = "Security has the constitutionality of a vending machine."
	icon_state = "nthelm"
	item_state = "nthelm"
	c_flags = SPACEWEAR | COVERSEYES | COVERSMOUTH | BLOCKCHOKE
	hides_from_examine = C_EARS|C_MASK|C_GLASSES
	see_face = 0
	setupProperties()
		..()
		setProperty("meleeprot_head", 8)
		setProperty("disorient_resist_eye", 15)

/obj/item/clothing/head/helmet/space/industrial
	mats = 7
#ifdef UNDERWATER_MAP
	icon_state = "diving_suit-industrial"
	item_state = "diving_suit-industrial"
	name = "industrial diving helmet"
	desc = "Goes with Industrial Diving Suit. Now with a fresh mint-scented visor!"

#else
	icon_state = "indus"
	item_state = "indus"
	name = "industrial space helmet"
	desc = "Goes with Industrial Space Armor. Now with zesty citrus-scented visor!"
#endif
	acid_survival_time = 8 MINUTES

	setupProperties()
		..()
		setProperty("radprot", 50)
		setProperty("exploprot", 10)
		setProperty("space_movespeed", 0)

	syndicate
		name = "Syndicate Command Helmet"
		desc = "Ooh, fancy."
		icon_state = "indusred"
		item_state = "indusred"
		is_syndicate = 1

		setupProperties()
			..()
			setProperty("meleeprot_head", 7)

/obj/item/clothing/head/helmet/space/mining_combat
	name = "mining combat helmet"
	desc = "Goes with Mining Combat Armor. Now with sweet strawberry-scented visor!"
	icon_state = "mining_combat"
	item_state = "mining_combat"
	mats = 10

	setupProperties()
		..()
		setProperty("radprot", 25)
		setProperty("meleeprot_head", 2)
		setProperty("disorient_resist_eye", 25)
		setProperty("disorient_resist_ear", 10)
		setProperty("space_movespeed", 0)

/obj/item/clothing/head/helmet/bucket
	name = "bucket helmet"
	desc = "Someone's cut out a bit of this bucket so you can put it on your head."
	icon_state = "buckethelm"
	item_state = "buckethelm"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	c_flags = COVERSEYES | BLOCKCHOKE
	hides_from_examine = C_EARS

	setupProperties()
		..()
		setProperty("meleeprot_head", 2)

	red
		name = "red bucket helmet"
		desc = "Someone's cut out a bit of this bucket so you can put it on your head. It's red, and it kinda remind you of something."
		icon_state = "buckethelm-r"
		item_state = "buckethelm-r"

	custom_suicide = 1
	suicide(var/mob/user as mob)
		user.u_equip(src)
		src.set_loc(get_turf(user))
		step_rand(src)
		user.visible_message("<span class='alert'><b>[user] kicks the bucket!</b></span>")
		user.death(FALSE)


/obj/item/clothing/head/helmet/bucket/hat
	name = "bucket hat"
	desc = "Looks like this bucket has been turned upside down so it can be used as a hat."
	icon_state = "buckethat"
	item_state = "buckethat"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	block_vision = 1
	seal_hair = 1
	var/bucket_type = /obj/item/reagent_containers/glass/bucket
	hides_from_examine = C_EARS|C_MASK|C_GLASSES

	attack_self(mob/user as mob)
		boutput(user, "<span class='notice'>You turn the bucket right side up.</span>")
		var/obj/item/reagent_containers/glass/bucket/B = new bucket_type(src.loc)
		user.u_equip(src)
		user.put_in_hand_or_drop(B)
		qdel(src)
		return

	custom_suicide = 1
	suicide(var/mob/user as mob)
		user.u_equip(src)
		src.set_loc(get_turf(user))
		user.visible_message("<span class='alert'><b>[user] kicks the bucket!</b></span>")
		user.death(FALSE)

	red
		name = "red bucket hat"
		desc = "Looks like this bucket has been turned upside down so it can be used as a hat. It's red."
		icon_state = "buckethat-r"
		item_state = "buckethat-r"
		bucket_type = /obj/item/reagent_containers/glass/bucket/red

/obj/item/clothing/head/helmet/greek
	name = "vaguely greek helmet"
	desc = "Is this what the gladiators wore?"
	c_flags = COVERSEYES
	icon_state = "gr_helmet"
	setupProperties()
		..()
		setProperty("meleeprot_head", 2)

/*/obj/item/clothing/head/helmet/escape
	name = "escape helmet"
	desc = "Eek!"
	icon_state = "escape"
	armor_value_melee = 4*/

/obj/item/clothing/head/helmet/firefighter
	name = "firefighter helm"
	desc = "For fighting fires."
	c_flags = COVERSEYES | BLOCKCHOKE
	icon_state = "firefighter"
	item_state = "firefighter"
	seal_hair = 1

	setupProperties()
		..()
		setProperty("meleeprot_head", 3)
		setProperty("coldprot", 5)
		setProperty("heatprot", 15)
		setProperty("disorient_resist_eye", 8)
		setProperty("disorient_resist_ear", 8)

/obj/item/clothing/head/helmet/captain
	name = "captain's helmet"
	desc = "Somewhat protects an important person's head from being bashed in. Comes in a intriqueing shade of green befitting of a captain"
	c_flags = COVERSEYES | BLOCKCHOKE
	icon_state = "helmet-captain"
	item_state = "helmet-captain"

	setupProperties()
		..()
		setProperty("meleeprot_head", 7)

	blue
		name = "commander's helmet"
		desc = "Somewhat protects an important person's head from being bashed in. Comes in a stylish shade of blue befitting of a commander"
		icon_state = "helmet-captain-blue"
		item_state = "helmet-captain-blue"

	red
		name = "\improper CentCom helmet"
		desc = "Somewhat protects an important person's head from being bashed in. Comes in a stylish shade of red befitting of an executive"
		icon_state = "helmet-captain-red"
		item_state = "helmet-captain-red"
