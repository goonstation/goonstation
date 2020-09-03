// CHUMP HELMETS: COOKING THEM DESTROYS THE CHUMP HELMET SPAWN.

/obj/item/clothing/head/helmet
	name = "helmet"
	icon_state = "helmet"
	c_flags = COVERSEYES
	item_state = "helmet"
	desc = "Somewhat protects your head from being bashed in."
	protective_temperature = 500

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("heatprot", 10)
		setProperty("meleeprot_head", 4)

/obj/item/clothing/head/helmet/space
	name = "space helmet"
	icon_state = "space"
	c_flags = SPACEWEAR | COVERSEYES | COVERSMOUTH
	see_face = 0.0
	item_state = "s_helmet"
	desc = "Helps protect against vacuum."
	seal_hair = 1

	onMaterialChanged()
		if(src.material)
			if(material.hasProperty("thermal"))
				var/prot = round((100 - material.getProperty("thermal")) / 2)
				setProperty("coldprot", 10+prot)
				setProperty("heatprot", 1+round(prot/2))
			else
				setProperty("coldprot", 10)
				setProperty("heatprot", 2)

			if(material.hasProperty("permeable"))
				var/prot = 100 - material.getProperty("permeable")
				setProperty("viralprot", prot)
			else
				setProperty("viralprot", 40)

			if(material.hasProperty("density"))
				var/prot = round(material.getProperty("density") / 20)
				setProperty("meleeprot_head", prot)
			else
				setProperty("meleeprot_head", 2)

	setupProperties()
		..()
		setProperty("coldprot", 20)
		setProperty("heatprot", 5)
		setProperty("viralprot", 50)
		setProperty("disorient_resist_eye", 8)
		setProperty("disorient_resist_ear", 8)

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
	see_face = 0.0
	item_state = "s_helmet"
	var/on = 0

	var/datum/component/holdertargeting/medium_directional_light/light_dir

	New()
		..()
		light_dir = src.AddComponent(/datum/component/holdertargeting/medium_directional_light, 0.9 * 255, 0.9 * 255, 1 * 255, 210)
		light_dir.update(0)

	attack_self(mob/user)
		src.flashlight_toggle(user)
		return

	proc/flashlight_toggle(var/mob/user, var/force_on = 0)
		on = !on
		src.icon_state = "espace[on]"
		if (on)
			light_dir.update(1)
		else
			light_dir.update(0)
		user.update_clothing()
		return

/obj/item/clothing/head/helmet/space/engineer/april_fools
	icon_state = "espace0-alt"

	flashlight_toggle(var/mob/user, var/force_on = 0)
		on = !on
		src.icon_state = "espace[on]-alt"
		if (on)
			light_dir.update(1)
		else
			light_dir.update(0)
		user.update_clothing()
		return

/obj/item/clothing/head/helmet/space/engineer/abilities = list(/obj/ability_button/flashlight_engiehelm)

// Sealab helmets

/obj/item/clothing/head/helmet/space/engineer/diving //hijacking engiehelms for the flashlight
	name = "diving helmet"
	desc = "Comes equipped with a builtin flashlight."
	icon_state = "diving0"

	flashlight_toggle(var/mob/user, var/force_on = 0)
		on = !on
		src.icon_state = "diving[on]"
		if (on)
			light_dir.update(1)
		else
			light_dir.update(0)
		user.update_clothing()
		return

	security
		name = "security diving helmet"
		icon_state = "diving-sec0"

		flashlight_toggle(var/mob/user, var/force_on = 0)
			on = !on
			src.icon_state = "diving-sec[on]"
			if (on)
				light_dir.update(1)
			else
				light_dir.update(0)
			user.update_clothing()
			return

	civilian
		name = "civilian diving helmet"
		icon_state = "diving-civ0"

		flashlight_toggle(var/mob/user, var/force_on = 0)
			on = !on
			src.icon_state = "diving-civ[on]"
			if (on)
				light_dir.update(1)
			else
				light_dir.update(0)
			user.update_clothing()
			return

	command
		name = "command diving helmet"
		icon_state = "diving-com0"

		flashlight_toggle(var/mob/user, var/force_on = 0)
			on = !on
			src.icon_state = "diving-com[on]"
			if (on)
				light_dir.update(1)
			else
				light_dir.update(0)
			user.update_clothing()
			return

	engineering
		name = "engineering diving helmet"
		icon_state = "diving-eng0"

		flashlight_toggle(var/mob/user, var/force_on = 0)
			on = !on
			src.icon_state = "diving-eng[on]"
			if (on)
				light_dir.update(1)
			else
				light_dir.update(0)
			user.update_clothing()
			return

/obj/item/clothing/head/helmet/space/engineer/diving/abilities = list(/obj/ability_button/flashlight_engiehelm)

/obj/item/clothing/head/helmet/space/syndicate
	name = "red space helmet"
	icon_state = "syndicate"
	item_state = "space_helmet_syndicate"
	desc = "The standard space helmet of the dreaded Syndicate."

	old
		icon_state = "syndicate-OLD"
		desc = "A relic of the past."
		item_state = null

	commissar_cap
		name = "commander's cap"
		wear_image_icon = 'icons/mob/fruithat.dmi'
		icon_state = "commissar_cap"
		desc = "A terrifyingly tall, black & red cap, typically worn by a Syndicate Nuclear Operative Commander. Maybe they're trying to prove something to the Head of Security?"
		seal_hair = 0
		see_face = 1

	specialist
		name = "specialist combat helmet"
		desc = "A modified combat helmet for syndicate operative specialists."
		icon_state = "syndie_specialist"
		item_state = "syndie_specialist"

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
			see_face = 0.0
			protective_temperature = 1300
			abilities = list(/obj/ability_button/nukie_meson_toggle)
			var/on = 0

			attack_self(mob/user)
				src.toggle(user)

			proc/toggle(var/mob/toggler)
				src.on = !src.on
				playsound(get_turf(src), "sound/items/mesonactivate.ogg", 30, 1)
				if (ishuman(toggler))
					var/mob/living/carbon/human/H = toggler
					if (istype(H.head, /obj/item/clothing/head/helmet/space/syndicate/specialist/engineer)) //handling of the rest is done in life.dm
						if (src.on)
							H.vision.set_scan(1)
						else
							H.vision.set_scan(0)

			equipped(var/mob/living/user, var/slot)
				..()
				if(!isliving(user))
					return
				if (slot == SLOT_HEAD && on)
					user.vision.set_scan(1)

			unequipped(var/mob/living/user)
				..()
				if(!isliving(user))
					return
				user.vision.set_scan(0)

		medic
			name = "specialist health monitor"
			icon_state = "syndie_specialist"
			item_state = "syndie_specialist"
			var/client/assigned = null

			process()
				if (assigned)
					assigned.images.Remove(health_mon_icons)
					src.addIcons()

					if (loc != assigned.mob)
						assigned.images.Remove(health_mon_icons)
						assigned = null

					//sleep(2 SECONDS)
				else
					processing_items.Remove(src)

			proc/addIcons()
				if (assigned)
					for (var/image/I in health_mon_icons)
						if (!I || !I.loc || !src)
							continue
						if (I.loc.invisibility && I.loc != src.loc)
							continue
						else
							assigned.images.Add(I)

			equipped(var/mob/user, var/slot)
				..()
				if (slot == SLOT_HEAD)
					assigned = user.client
					SPAWN_DBG(-1)
						//updateIcons()
						if (!(src in processing_items))
							processing_items.Add(src)
				return

			unequipped(var/mob/user)
				..()
				if (assigned)
					assigned.images.Remove(health_mon_icons)
					assigned = null
					processing_items.Remove(src)
				return

		sniper
			name = "specialist combat cover"
			icon_state = "syndie_specialist-sniper"
			item_state = "syndie_specialist-sniper"

/obj/item/clothing/head/helmet/space/ntso //recoloured nuke class suits for ntso vs syndicate specialist
	name = "NT-SO combat helmet"
	desc = "A modified combat helmet for Nanotrasen special forces"
	icon_state = "ntso_specialist"
	item_state = "ntso_specialist"

	unremovable
		cant_self_remove = 1
		cant_other_remove = 1

/obj/item/clothing/head/helmet/space/nanotrasen
	name = "Nanotrasen Heavy Helmet"
	icon_state = "nthelm2"
	item_state = "nthelm2"
	desc = "Well protected helmet used by certain Nanotrasen bodyguards."

/obj/item/clothing/head/helmet/swat
	name = "swat helmet"
	icon_state = "swat"
	c_flags = COVERSEYES
	item_state = "swat_hel"
	setupProperties()
		..()
		setProperty("meleeprot_head", 7)

/obj/item/clothing/head/helmet/turd
	name = "T.U.R.D.S. helmet"
	icon_state = "turdhelm"
	c_flags = COVERSEYES
	item_state = "turdhelm"
	setupProperties()
		..()
		setProperty("meleeprot_head", 7)

/obj/item/clothing/head/helmet/thunderdome
	name = "Thunderdome helmet"
	icon_state = "thunderdome"
	c_flags = COVERSEYES
	item_state = "tdhelm"
	setupProperties()
		..()
		setProperty("meleeprot_head", 7)

/obj/item/clothing/head/helmet/hardhat
	name = "hard hat"
	icon_state = "hardhat0"
	uses_multiple_icon_states = 1
	c_flags = SPACEWEAR
	item_state = "hardhat0"
	desc = "Protects your head from falling objects, and comes with a flashlight. Safety first!"
	var/on = 0
	var/datum/component/holdertargeting/simple_light/light_dir

	setupProperties()
		..()
		setProperty("meleeprot_head", 5)

	New()
		..()
		light_dir = src.AddComponent(/datum/component/holdertargeting/medium_directional_light, 0.9 * 255, 0.9 * 255, 1 * 255, 210)
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

/obj/item/clothing/head/helmet/hardhat/security // Okay it's not actually a HARDHAT but why write extra code?
	name = "helmet"
	icon_state = "helmet-sec"
	uses_multiple_icon_states = 1
	c_flags = COVERSEYES
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
	c_flags = COVERSEYES | COVERSMOUTH
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
	c_flags = SPACEWEAR
	item_state = "camhat"
	var/obj/machinery/camera/camera = null
	var/camera_tag = "Helmet Cam"
	var/camera_network = "Zeta"

	New()
		..()
		src.camera = new /obj/machinery/camera (src)
		src.camera.c_tag = src.camera_tag
		src.camera.network = src.camera_network

/obj/item/clothing/head/helmet/camera/security
	name = "security camera helmet"
	desc = "A red helmet with a built in camera. It has a little note taped to it that says \"Security\"."
	icon_state = "redcamhat"
	c_flags = SPACEWEAR
	item_state = "redcamhat"
	camera_tag = "Security Helmet Cam"

/obj/item/clothing/head/helmet/jetson
	name = "Fifties America Reclamation Team Helmet"
	desc = "Combat helmet used by a minor terrorist group."
	icon_state = "jetson1"
	c_flags = SPACEWEAR
	icon_state = "jetson"
	item_state = "jetson"
	setupProperties()
		..()
		setProperty("meleeprot_head", 3)

/obj/item/clothing/head/helmet/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye. Can be flipped up for clearer vision."
	icon_state = "welding"
	c_flags = SPACEWEAR | COVERSEYES
	see_face = 0.0
	item_state = "welding"
	protective_temperature = 1300
	m_amt = 3000
	g_amt = 1000
	var/up = 0
	color_r = 0.5 // darken
	color_g = 0.5
	color_b = 0.5
	var/nodarken = 0

	setupProperties()
		..()
		setProperty("meleeprot_head", 2)
		setProperty("disorient_resist_eye", 100)

	proc/flip_down()
		setProperty("meleeprot_head", 2)
		setProperty("disorient_resist_eye", 100)

	proc/flip_up()
		setProperty("meleeprot_head", 4)
		setProperty("disorient_resist_eye", 0)


/obj/item/clothing/head/helmet/welding/abilities = list(/obj/ability_button/mask_toggle)

/obj/item/clothing/head/helmet/EOD
	name = "blast helmet"
	desc = "A thick head cover made of layers upon layers of space kevlar."
	icon_state = "EOD"
	item_state = "tdhelm"
	c_flags = COVERSEYES
	setupProperties()
		..()
		setProperty("meleeprot_head", 9)
		setProperty("disorient_resist_eye", 25)
		setProperty("exploprot", 2)

/obj/item/clothing/head/helmet/HoS
	name = "HoS Hat"
	icon_state = "hoscap"
	uses_multiple_icon_states = 1
	item_state = "hoscap"
	c_flags = SPACEWEAR | COVERSEYES
	var/is_a_communist = 0
	var/folds = 0
	desc = "Actually, you got this hat from a fast-food restaurant, that's why it folds like it was made of paper."
	setupProperties()
		..()
		setProperty("meleeprot_head", 7)

/obj/item/clothing/head/helmet/HoS/attack_self(mob/user as mob)
	if(user.r_hand == src || user.l_hand == src)
		if(!src.folds)
			src.folds = 1
			src.name = "HoS Beret"
			src.icon_state = "hosberet"
			src.item_state = "hosberet"
			boutput(usr, "<span class='notice'>You fold the hat into a beret.</span>")
		else
			src.folds = 0
			src.name = "HoS Hat"
			src.icon_state = "hoscap"
			src.item_state = "hoscap"
			boutput(usr, "<span class='notice'>You unfold the beret back into a hat.</span>")
		return

/obj/item/clothing/head/helmet/siren
	name = "siren helmet"
	desc = "A big flashing light that you put on your head. It also plays a siren for when you need to arrest someone!"
	icon_state = "siren0"
	uses_multiple_icon_states = 1
	item_state = "siren"
	c_flags = SPACEWEAR
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
		SPAWN_DBG (0)
			playsound(src.loc, "sound/machines/siren_police.ogg", 50, 1)
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
		SPAWN_DBG(0)
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
	setupProperties()
		..()
		setProperty("meleeprot_head", 10)
		setProperty("disorient_resist_eye", 50)
		setProperty("disorient_resist_ear", 30)

/obj/item/clothing/head/helmet/NT
	name = "\improper Nanotrasen helmet"
	desc = "Security has the constitutionality of a vending machine."
	icon_state = "nthelm"
	item_state = "nthelm"
	c_flags = SPACEWEAR | COVERSEYES | COVERSMOUTH
	see_face = 0.0
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

	setupProperties()
		..()
		setProperty("radprot", 50)
		setProperty("exploprot", 1)

	syndicate
		name = "Syndicate Command Helmet"
		desc = "Ooh, fancy."
		icon_state = "indusred"
		item_state = "indusred"
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

/obj/item/clothing/head/helmet/bucket
	name = "bucket helmet"
	desc = "Someone's cut out a bit of this bucket so you can put it on your head."
	icon_state = "buckethelm"
	item_state = "buckethelm"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'

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
		user.death(0)


/obj/item/clothing/head/helmet/bucket/hat
	name = "bucket hat"
	desc = "Looks like this bucket has been turned upside down so it can be used as a hat."
	icon_state = "buckethat"
	item_state = "buckethat"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	block_vision = 1
	seal_hair = 1
	var/bucket_type = /obj/item/reagent_containers/glass/bucket

	attack_self(mob/user as mob)
		boutput(usr, "<span class='notice'>You turn the bucket right side up.</span>")
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
		user.death(0)

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
		setProperty("meleeprot_head", 7)

/*/obj/item/clothing/head/helmet/escape
	name = "escape helmet"
	desc = "Eek!"
	icon_state = "escape"
	armor_value_melee = 4*/

/obj/item/clothing/head/helmet/firefighter
	name = "firefighter helm"
	desc = "For fighting fires."
	c_flags = COVERSEYES
	icon_state = "firefighter"
	item_state = "firefighter"
	seal_hair = 1
