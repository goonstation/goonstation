// GLASSES

/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/item_glasses.dmi'
	wear_image_icon = 'icons/mob/clothing/eyes.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	item_state = "glasses"
	w_class = W_CLASS_SMALL
	c_flags = COVERSEYES
	var/allow_blind_sight = 0
	wear_layer = MOB_GLASSES_LAYER
	block_vision = 0
	duration_remove = 1.5 SECONDS
	duration_put = 1.5 SECONDS
	var/block_eye = null // R or L
	var/correct_bad_vision = 0
	compatible_species = list("human", "cow", "werewolf", "flubber")

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/cloth))
			user.visible_message("<span class='notice'>[user] [pick("polishes", "shines", "cleans", "wipes")] [src] with [W].</span>")
			return
		return ..()

/obj/item/clothing/glasses/crafted
	name = "glasses"
	icon_state = "crafted"
	item_state = "crafted"
	desc = "A simple pair of glasses."

	onMaterialChanged()
		..()
		if(istype(src.material))
			if(src.material.alpha >= 190)
				desc = "You can't see through these. G.R.E.A.T."
				block_vision = 1
			alpha = 255

		setProperty("disorient_resist_eye", src.getProperty("density") * 0.6)

/obj/item/clothing/glasses/blindfold
	name = "blindfold"
	icon_state = "blindfold"
	item_state = "blindfold"
	desc = "A strip of cloth painstakingly designed to wear around your eyes so you cannot see."
	block_vision = 1

	attack(mob/M, mob/user, def_zone) //this is for equipping blindfolds on head attack.
		if (user.zone_sel.selecting == "head" && ishuman(M)) //ishuman() works on monkeys too apparently.
			if(user == M) //Accidentally blindfolding yourself might be annoying so I'm leaving that out.
				boutput(user, "<span class='alert'>Put it on your eyes, dingus!</span>")
				return
			var/mob/living/carbon/human/target = M //can't equip to mobs unless they are human
			if(target.glasses)
				boutput(user, "<span class='alert'>[target] is already wearing something on their eyes!</span>")
				return
			actions.start(new/datum/action/bar/icon/otherItem(user, target, user.equipped(), target.slot_glasses, 1.3 SECONDS) , user) //Uses extended timer to make up for previously having to manually equip to someone's eyes.
			return
		..() //if not selecting the head of a human or monkey, just do normal attack.

TYPEINFO(/obj/item/clothing/glasses/meson)
	mats = 6

/obj/item/clothing/glasses/meson
	name = "meson goggles"
	icon_state = "meson"
	var/base_state = "meson"
	item_state = "glasses"
	desc = "Goggles that allow you to see the structure of the station through walls."
	color_r = 0.92
	color_g = 1
	color_b = 0.92
	var/on = 1

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 15)


	attack_self(mob/user)
		src.toggle(user)

	proc/toggle(var/mob/toggler)
		src.on = !src.on
		src.item_state = "[src.base_state][src.on ? null : "-off"]"
		set_icon_state("[src.base_state][src.on ? null : "-off"]")
		toggler.update_clothing()
		playsound(src, 'sound/items/mesonactivate.ogg', 30, 1)
		if (ishuman(toggler))
			var/mob/living/carbon/human/H = toggler
			if (istype(H.glasses, /obj/item/clothing/glasses/meson)) //hamdling of the rest is done in life.dm
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
		if (slot == SLOT_GLASSES && on)
			user.vision.set_scan(1)
			APPLY_ATOM_PROPERTY(user, PROP_MOB_MESONVISION, src)

	unequipped(var/mob/living/user)
		..()
		if(!isliving(user))
			return
		user.vision.set_scan(0)

	unequipped(mob/user)
		. = ..()
		REMOVE_ATOM_PROPERTY(user, PROP_MOB_MESONVISION, src)

/obj/item/clothing/glasses/meson/abilities = list(/obj/ability_button/meson_toggle)

/obj/item/clothing/glasses/regular
	name = "prescription glasses"
	icon_state = "glasses"
	item_state = "glasses"
	desc = "Corrective lenses, perfect for the near-sighted."
	correct_bad_vision = 1

/obj/item/clothing/glasses/regular/ecto
	name = "peculiar spectacles"
	desc = "Admittedly, they are rather strange."
	icon_state = "ectoglasses"
	color_r = 0.89
	color_g = 1
	color_b = 0.85

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 15)

	equipped(mob/user, slot)
		. = ..()
		APPLY_ATOM_PROPERTY(user, PROP_MOB_GHOSTVISION, src)

	unequipped(mob/user)
		. = ..()
		REMOVE_ATOM_PROPERTY(user, PROP_MOB_GHOSTVISION, src)

/obj/item/clothing/glasses/regular/ecto/goggles
	name = "ectoplasmoleic imager"
	desc = "A pair of goggles with a dumb name."
	icon_state = "ectogoggles"

/obj/item/clothing/glasses/sunglasses
	name = "sunglasses"
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	icon_state = "sun"
	item_state = "sunglasses"
	protective_temperature = 1300
	var/already_worn = 0
	color_r = 0.9 // darken a little
	color_g = 0.9
	color_b = 0.95 // kinda blue

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 100)

/obj/item/clothing/glasses/sunglasses/equipped(var/mob/user, var/slot)
	var/mob/living/carbon/human/H = user
	if(istype(H) && slot == SLOT_GLASSES)
		if(H.mind)
			if(H.mind.assigned_role == "Detective" && !src.already_worn)
				src.already_worn = 1
				playsound(user, 'sound/voice/yeaaahhh.ogg', 100, 0)
				user.visible_message("<span class='alert'><B><font size=3>YEAAAAAAAAAAAAAAAH!</font></B></span>")
	..()
	return

TYPEINFO(/obj/item/clothing/glasses/sunglasses/tanning)
	mats = 4

/obj/item/clothing/glasses/sunglasses/tanning
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. This pair has a label that says: \"For tanning use only.\""
	color_b = 0.95

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 40)

/obj/item/clothing/glasses/sunglasses/sechud
	name = "\improper Security HUD"
	desc = "Sunglasses with a high tech sheen."
	icon_state = "sec"
	color_r = 0.95 // darken a little, kinda red
	color_g = 0.9
	color_b = 0.9

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/H = src.loc
			if (istype(H.glasses, /obj/item/clothing/glasses/sunglasses/sechud))
				boutput(H, "<span class='alert'><B>Your HUD malfunctions!</B></span>")
				H.take_eye_damage(3, 1)
				H.change_eye_blurry(5)
				H.bioHolder.AddEffect("bad_eyesight")
				SPAWN(10 SECONDS)
					H.bioHolder.RemoveEffect("bad_eyesight")

	equipped(var/mob/user, var/slot)
		..()
		if (slot == SLOT_GLASSES)
			get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).add_mob(user)

	unequipped(var/mob/user)
		if(src.equipped_in_slot == SLOT_GLASSES)
			get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).remove_mob(user)
		..()

/obj/item/clothing/glasses/sunglasses/sechud/superhero
	name = "superhero mask"
	desc = "Perfect for hiding your identity while fighting crime."
	icon_state = "superhero"
	item_state = "superhero"
	color_r = 1
	color_g = 1
	color_b = 1
	contraband = 4 // illegal (stolen) crimefighting vigilante gear

TYPEINFO(/obj/item/clothing/glasses/thermal)
	mats = 8

/obj/item/clothing/glasses/thermal
	name = "optical thermal scanner"
	icon_state = "thermal"
	item_state = "glasses"
	desc = "High-tech glasses that can see through cloaking technology. Also helps you see further in the dark."
	color_r = 1
	color_g = 0.8 // red tint
	color_b = 0.8
	/// For seeing through walls
	var/upgraded = FALSE

	equipped(mob/user, slot)
		. = ..()
		if(upgraded)
			APPLY_ATOM_PROPERTY(user, PROP_MOB_THERMALVISION_MK2, src)
		else
			APPLY_ATOM_PROPERTY(user, PROP_MOB_THERMALVISION, src)

	unequipped(mob/user)
		. = ..()
		if(upgraded)
			REMOVE_ATOM_PROPERTY(user, PROP_MOB_THERMALVISION_MK2, src)
		else
			REMOVE_ATOM_PROPERTY(user, PROP_MOB_THERMALVISION, src)

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/H = src.loc
			if (istype(H.glasses, /obj/item/clothing/glasses/thermal))
				boutput(H, "<span class='alert'><B>Your thermals malfunction!</B></span>")
				H.take_eye_damage(3, 1)
				H.change_eye_blurry(5)
				H.bioHolder.AddEffect("bad_eyesight")
				if(upgraded)
					REMOVE_ATOM_PROPERTY(H, PROP_MOB_THERMALVISION_MK2, src)
				else
					REMOVE_ATOM_PROPERTY(H, PROP_MOB_THERMALVISION, src)

				SPAWN(10 SECONDS)
					H.bioHolder.RemoveEffect("bad_eyesight")
					if(H.glasses == src)
						if(upgraded)
							APPLY_ATOM_PROPERTY(H, PROP_MOB_THERMALVISION_MK2, src)
						else
							APPLY_ATOM_PROPERTY(H, PROP_MOB_THERMALVISION, src)
		return

/obj/item/clothing/glasses/thermal/traitor //sees people through walls
	desc = "High-tech glasses that can see through cloaking technology. Also helps you see further in the dark. They sort of hurt your eyes to look through."
	color_r = 1
	color_g = 0.75 // slightly more red?
	color_b = 0.75
	upgraded = TRUE

/obj/item/clothing/glasses/thermal/orange
	name = "orange-tinted glasses"
	desc = "A pair of glasses with an orange tint to them."
	icon_state = "oglasses"
	color_r = 1
	color_g = 0.9 // orange tint?
	color_b = 0.8

TYPEINFO(/obj/item/clothing/glasses/visor)
	mats = 4

/obj/item/clothing/glasses/visor
	name = "\improper VISOR goggles"
	icon_state = "visor"
	item_state = "glasses"
	desc = "VIS-tech Optical Rejuvinator goggles allow the blind to see while worn."
	allow_blind_sight = 1
	color_r = 0.92
	color_g = 0.92
	color_b = 1

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 15)

	equipped(var/mob/living/user, var/slot)
		..()
		if(!isliving(user))
			return
		if (slot == SLOT_GLASSES)
			user.vision.set_scan(1)
		return

	unequipped(var/mob/living/user)
		..()
		if(!isliving(user))
			return
		user.vision.set_scan(0)
		return

/obj/item/clothing/glasses/eyepatch
	name = "medical eyepatch"
	desc = "Only the coolest eye-wear around."
	icon_state = "eyepatch-R"
	uses_multiple_icon_states = 1
	item_state = "headset"
	block_eye = "R"
	var/pinhole = 0
	var/mob/living/carbon/human/equipper
	wear_layer = MOB_GLASSES_LAYER2

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 7)

	equipped(var/mob/user, var/slot)
		var/mob/living/carbon/human/H = user
		if(istype(H) && slot == SLOT_GLASSES)
			equipper = user//todo: this is prooobably redundant
		return ..()

	attackby(obj/item/W, mob/user)
		if ((isscrewingtool(W) || istype(W, /obj/item/pen)) && !pinhole)
			if( equipper && equipper.glasses == src )
				var/obj/item/organ/eye/theEye = equipper.drop_organ((src.icon_state == "eyepatch-L") ? "left_eye" : "right_eye")
				pinhole = 1
				block_eye = null
				appearance_flags |= RESET_COLOR
				if(!theEye)
					user.show_message("<span class='alert'>Um. Wow. Thats kinda grode.<span>")
					return ..()
				theEye.appearance_flags |= RESET_COLOR
				user.show_message("<span class='alert'>You stab a hole in [src].  Unfortunately, you also stab a hole in your eye and when you pull [W] away your eye comes with it!!</span>")
				return
			else
				pinhole = 1
				block_eye = null
				appearance_flags |= RESET_COLOR
				user.show_message("<span class='notice'>You poke a tiny pinhole into [src]!</span>")
				if (!pinhole)
					desc = "[desc] Unfortunately, its not so cool anymore since there's a tiny pinhole in it."
				return
		return ..()
	attack_self(mob/user)

		if (src.icon_state == "eyepatch-R")
			src.block_eye = "L"
		else
			src.block_eye = "R"
		src.icon_state = "eyepatch-[src.block_eye]"
		boutput(user, "You flip [src] around.")
		if (pinhole)
			block_eye = null

	pirate
		name = "pirate's eyepatch"
		pinhole = TRUE
		block_eye = null

		New()
			..()
			var/eye_covered
			if (prob(50))
				eye_covered = "L"
			else
				eye_covered = "R"
			src.icon_state = "eyepatch-[eye_covered]"

/obj/item/clothing/glasses/vr
	name = "\improper VR goggles"
	desc = "A pair of VR goggles running a personal simulation."
	icon_state = "vr"
	item_state = "sunglasses"
	var/network = LANDMARK_VR_DET_NET

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 28)

	New()
		SPAWN(2 SECONDS)
			if (src)
				src.name += " - '[src.network]'" // They otherwise all look the same (Convair880).
		..()

	equipped(var/mob/user, var/slot)
		..()
		var/mob/living/carbon/human/H = user
		if(istype(H) && slot == SLOT_GLASSES && !H.network_device && !inafterlife(H))
			user.network_device = src
			//user.verbs += /mob/proc/jack_in
			Station_VNet.Enter_Vspace(H, src,src.network)
		return

	unequipped(var/mob/user)
		..()
		if(ishuman(user) && user:network_device == src)
			//user.verbs -= /mob/proc/jack_in
			user:network_device = null
		return

//Goggles used to assume control of a linked scuttlebot
/obj/item/clothing/glasses/scuttlebot_vr
	name = "Scuttlebot remote controller"
	desc = "A pair of VR goggles connected to a remote scuttlebot. Use them on the scuttlebot to turn it back into a hat."
	icon_state = "vr"
	item_state = "sunglasses"
	var/mob/living/critter/robotic/scuttlebot/connected_scuttlebot = null

	equipped(var/mob/user, var/slot) //On equip, if there's a scuttlebot, control it
		..()
		var/mob/living/carbon/human/H = user
		if(connected_scuttlebot != null)
			if(connected_scuttlebot.mind)
				boutput(user, "<span class='alert'>The scuttlebot is already active somehow!</span>")
			else if(!connected_scuttlebot.loc)
				boutput(user, "<span class='alert'>You put on the glasses but they show no signal. The scuttlebot couldnt be found.</span>")
			else
				connected_scuttlebot.controller = H
				user.mind.transfer_to(connected_scuttlebot)
		else
			boutput(user, "<span class='alert'>You put on the glasses but they show no signal. The scuttlebot is likely destroyed.</span>")

	attack(mob/W, mob/M)
		if (istype(W, /mob/living/critter/robotic/scuttlebot))
			var/mob/living/critter/robotic/scuttlebot/S = W
			if (connected_scuttlebot != S)
				boutput(M, "You try to put the goggles back into the hat but it grumps at you, not recognizing the glasses.")
				return 1

			if (istype(W, /mob/living/critter/robotic/scuttlebot/weak))
				var/mob/living/critter/robotic/scuttlebot/weak/O = S
				if (O.linked_hat != null)
					O.linked_hat.set_loc(get_turf(O))
				else
					var/obj/item/clothing/head/det_hat/gadget/gadgethat = new /obj/item/clothing/head/det_hat/gadget(get_turf(O))
					if (O.is_inspector)
						gadgethat.make_inspector()
				boutput(M, "You stuff the goggles back into the detgadget hat. It powers down with a low whirr.")
				qdel(O)
				qdel(src)
			else
				new /obj/item/clothing/head/det_hat/folded_scuttlebot(get_turf(S))
				boutput(M, "You stuff the goggles back into the hat. It powers down with a low whirr.")
				S.drop_item()
				qdel(S)
				qdel(src)
		else
			..()

	unequipped(var/mob/user) //Someone might have removed them from us. If we're inside the scuttlebot, we're forced out
		..()
		if(connected_scuttlebot != null)
			connected_scuttlebot.return_to_owner()

/obj/item/clothing/glasses/vr_fake //Only exist IN THE MATRIX.  Used to log out.
	name = "\improper VR goggles"
	desc = "A pair of VR goggles running a personal simulation.  You should know this, being IN the simulation and all."
	icon_state = "vr"
	item_state = "sunglasses"

	unequipped(var/mob/user)
		..()
		if(istype(user, /mob/living/carbon/human/virtual) && user:body)
			//Station_VNet.Leave_Vspace(user)
			user.death()
		return

/obj/item/clothing/glasses/vr/arcade
	network = LANDMARK_VR_ARCADE

/obj/item/clothing/glasses/vr/bomb
	network = LANDMARK_VR_BOMBTEST

TYPEINFO(/obj/item/clothing/glasses/healthgoggles)
	mats = 8

/obj/item/clothing/glasses/healthgoggles
	name = "\improper ProDoc Healthgoggles"
	desc = "Fitted with an advanced miniature sensor array that allows the user to quickly determine the physical condition of others."
	icon_state = "prodocs"
	uses_multiple_icon_states = 1
	var/scan_upgrade = 0
	var/health_scan = 0
	color_r = 0.85
	color_g = 1
	color_b = 0.87

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 15)

	equipped(var/mob/user, var/slot)
		..()
		if (slot == SLOT_GLASSES)
			get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).add_mob(user)
			if (src.health_scan)
				APPLY_ATOM_PROPERTY(user,PROP_MOB_EXAMINE_HEALTH,src)

	unequipped(var/mob/user)
		if(src.equipped_in_slot == SLOT_GLASSES)
			REMOVE_ATOM_PROPERTY(user,PROP_MOB_EXAMINE_HEALTH,src)
			get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(user)
		..()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/device/analyzer/healthanalyzer_upgrade))
			if (src.scan_upgrade)
				boutput(user, "<span class='alert'>[src] already has a health scan upgrade!</span>")
				return
			else
				src.scan_upgrade = 1
				src.health_scan = 1
				var/mob/living/carbon/human/human_user = user
				if (istype(human_user) && human_user.glasses == src)
					APPLY_ATOM_PROPERTY(user,PROP_MOB_EXAMINE_HEALTH,src)
				src.icon_state = "prodocs-upgraded"
				boutput(user, "<span class='notice'>Health scan upgrade installed.</span>")
				playsound(src.loc , 'sound/items/Deconstruct.ogg', 80, 0)
				user.u_equip(W)
				qdel(W)
				return
		else
			return ..()

	attack_self(mob/user as mob)
		if (!src.scan_upgrade)
			boutput(user, "<span class='alert'>No health scan upgrade detected!</span>")
			return
		else
			src.health_scan = !(src.health_scan)
			boutput(user, "<span class='notice'>Health scanner [src.health_scan ? "enabled" : "disabled"].</span>")
			return

/obj/item/clothing/glasses/healthgoggles/upgraded
	icon_state = "prodocs-upgraded"
	scan_upgrade = 1
	health_scan = 1

// Glasses that allow the wearer to get a full reagent report for containers
TYPEINFO(/obj/item/clothing/glasses/spectro)
	mats = 6

/obj/item/clothing/glasses/spectro
	name = "spectroscopic scanner goggles"
	icon_state = "spectro"
	item_state = "glasses"
	desc = "Goggles with an integrated minature Raman spectroscope for easy qualitative and quantitative analysis of chemical samples."
	color_r = 1 // pink tint?
	color_g = 0.8
	color_b = 0.9

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 5)

	equipped(mob/user, slot)
		. = ..()
		APPLY_ATOM_PROPERTY(user, PROP_MOB_SPECTRO, src)

	unequipped(mob/user)
		. = ..()
		REMOVE_ATOM_PROPERTY(user, PROP_MOB_SPECTRO, src)

/obj/item/clothing/glasses/spectro/monocle //used for bartender job reward
	name = "spectroscopic monocle"
	icon_state = "spectro_monocle"
	item_state = "spectro_monocle"
	desc = "Such a dapper eyepiece! And a practical one at that."

// testing thing for static overlays
/obj/item/clothing/glasses/staticgoggles
	name = "goggles"
	desc = "wha"
	icon_state = "machoglasses"
	color = "#FF00FF"
	var/active = FALSE

	equipped(var/mob/user, var/slot)
		..()
		if (slot == SLOT_GLASSES)
			get_image_group(CLIENT_IMAGE_GROUP_GHOSTDRONE).add_mob(user)
			active = TRUE

	unequipped(var/mob/user)
		..()
		if (active)
			get_image_group(CLIENT_IMAGE_GROUP_GHOSTDRONE).remove_mob(user)
			active = FALSE

TYPEINFO(/obj/item/clothing/glasses/noir)
	mats = 4

/obj/item/clothing/glasses/noir
	name = "Noir-Tech Glasses"
	desc = "A pair of glasses that simulate what the world looked like before the invention of color."
	icon_state = "noir"
	equipped(var/mob/user, var/slot)
		..()
		var/mob/living/carbon/human/H = user
		if(istype(H) && slot == SLOT_GLASSES)
			if(H.client)
				animate_fade_grayscale(H.client, 5)
	unequipped(var/mob/user, var/slot)
		..()
		var/mob/living/carbon/human/H = user
		if(istype(H))
			if (H.client)
				animate_fade_from_grayscale(H.client, 5)

TYPEINFO(/obj/item/clothing/glasses/nightvision)
	mats = 8

TYPEINFO(/obj/item/clothing/glasses/nightvision/sechud)
	mats = 12

TYPEINFO(/obj/item/clothing/glasses/nightvision/sechud/flashblocking)
	mats = 25 //expensive if someone scans them because I can do what I want

/obj/item/clothing/glasses/nightvision
	name = "night vision goggles"
	icon_state = "nightvision"
	item_state = "glasses"
	desc = "Goggles with separate built-in image-intensifier tubes to allow vision in the dark. Keep away from bright lights."
	color_r = 0.5
	color_g = 1
	color_b = 0.5
	wear_layer = MOB_GLASSES_LAYER2

	equipped(mob/user, slot)
		. = ..()
		APPLY_ATOM_PROPERTY(user, PROP_MOB_NIGHTVISION, src)

	unequipped(mob/user)
		. = ..()
		REMOVE_ATOM_PROPERTY(user, PROP_MOB_NIGHTVISION, src)

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/H = src.loc
			if (istype(H.glasses, /obj/item/clothing/glasses/nightvision))
				boutput(H, "<span class='alert'><B>Your nightvision goggles malfunction!</B></span>")
				H.take_eye_damage(3, 1)
				H.change_eye_blurry(5)
				H.bioHolder.AddEffect("bad_eyesight")
				SPAWN(10 SECONDS)
					H.bioHolder.RemoveEffect("bad_eyesight")

	sechud
		name = "night vision sechud goggles"
		icon_state = "nightvisionsechud"
		desc = "Goggles with separate built-in image-intensifier tubes to allow vision in the dark. Keep away from bright lights. This version also has built in SecHUD functionality."
		color_r = 1
		color_g = 0.5
		color_b = 0.5

		equipped(var/mob/user, var/slot)
			..()
			if (slot == SLOT_GLASSES)
				get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).add_mob(user)

		unequipped(var/mob/user)
			if(src.equipped_in_slot == SLOT_GLASSES)
				get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).remove_mob(user)
			..()

		flashblocking //Admin or gimmick spawn option
			name = "SUPER night vision sechud goggles"
			desc = "Goggles with separate built-in image-intensifier tubes to allow vision in the dark AND SecHUDs AND with darkened lenses? Wowee!"

			setupProperties()
				..()
				setProperty("disorient_resist_eye", 100)


/obj/item/clothing/glasses/packetvision
	name = "\improper Packetvision HUD"
	desc = "These let you see wireless packets like some sort of a hackerman."
	item_state = "glasses"
	icon_state = "glasses"
	color = "#a0ffa0"
	color_r = 0.9
	color_g = 1
	color_b = 0.9

	equipped(var/mob/user, var/slot)
		..()
		if (slot == SLOT_GLASSES)
			get_image_group(CLIENT_IMAGE_GROUP_PACKETVISION).add_mob(user)

	unequipped(var/mob/user)
		if(src.equipped_in_slot == SLOT_GLASSES)
			get_image_group(CLIENT_IMAGE_GROUP_PACKETVISION).remove_mob(user)
		..()
