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
	compatible_species = list("human", "cow", "werewolf", "flubber")
	var/block_eye = null // R or L
	var/correct_bad_vision = 0
	var/nudge_compatible = TRUE // below vars for the "nudge" emote
	var/flash_compatible = FALSE
	var/og_icon_state = "glasses"
	var/flash_toggle = TRUE
	var/flash_state = "flash"

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/cloth))
			user.visible_message(SPAN_NOTICE("[user] [pick("polishes", "shines", "cleans", "wipes")] [src] with [W]."))
			return
		return ..()

	proc/nudge_emote()
		var/mob/living/carbon/human/H = src.loc
		if (src.flash_toggle)
			src.flash_toggle = FALSE
			var/image/oglasses = image('icons/mob/clothing/eyes.dmi', loc=src.icon_state, icon_state=flash_state, layer=MOB_GLASSES_LAYER+1)
			H.AddOverlays(oglasses, "glasses")
		else
			H.ClearSpecificOverlays("glasses")
			src.flash_toggle = TRUE

/obj/item/clothing/glasses/crafted
	name = "glasses"
	icon_state = "crafted"
	item_state = "crafted"
	desc = "A simple pair of glasses."
	flash_compatible = TRUE

	onMaterialChanged()
		..()
		if(istype(src.material))
			if(src.material.getAlpha() >= 190)
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
	nudge_compatible = FALSE

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 100)

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (ishuman(target) && user.a_intent != INTENT_HARM) //ishuman() works on monkeys too apparently.
			var/mob/living/carbon/human/Htarget = target //can't equip to mobs unless they are human
			if(user == Htarget) //Accidentally blindfolding yourself might be annoying so I'm leaving that out.
				boutput(user, SPAN_ALERT("Put it on your eyes, dingus!"))
				return
			if(Htarget.glasses)
				boutput(user, SPAN_ALERT("[Htarget] is already wearing something on [his_or_her(Htarget)] eyes!"))
				return
			actions.start(new/datum/action/bar/icon/otherItem(user, Htarget, user.equipped(), SLOT_GLASSES, 1.3 SECONDS) , user) //Uses extended timer to make up for previously having to manually equip to someone's eyes.
			return
		..() //if not selecting the head of a human or monkey, just do normal attack.

ABSTRACT_TYPE(/obj/item/clothing/glasses/toggleable)
/obj/item/clothing/glasses/toggleable
	var/on = TRUE

	attack_self(mob/user)
		src.toggle(user)

	proc/toggle(var/mob/toggler)
		src.on = !src.on
		src.item_state = "[initial(src.icon_state)][src.on ? null : "-off"]"
		src.set_icon_state("[initial(src.icon_state)][src.on ? null : "-off"]")
		toggler.update_clothing()

TYPEINFO(/obj/item/clothing/glasses/toggleable/meson)
	mats = 6
/obj/item/clothing/glasses/toggleable/meson
	name = "meson goggles"
	icon_state = "meson"
	item_state = "glasses"
	desc = "Goggles that allow you to see the structure of the station through walls."
	flash_compatible = TRUE
	color_r = 0.92
	color_g = 1
	color_b = 0.92
	abilities = list(/obj/ability_button/meson_toggle)

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 15)

	toggle(var/mob/toggler)
		..()
		playsound(src, 'sound/items/mesonactivate.ogg', 30, TRUE)
		if (ishuman(toggler))
			var/mob/living/carbon/human/H = toggler
			if (istype(H.glasses, /obj/item/clothing/glasses/toggleable/meson)) //hamdling of the rest is done in life.dm
				if (src.on)
					H.meson(src)
				else
					H.unmeson(src)

	equipped(var/mob/living/user, var/slot)
		..()
		if(!isliving(user))
			return
		if (slot == SLOT_GLASSES && on)
			user.meson(src)

	unequipped(var/mob/living/user)
		..()
		if(!isliving(user))
			return
		user.unmeson(src)

/obj/item/clothing/glasses/regular
	name = "prescription glasses"
	icon_state = "glasses"
	item_state = "glasses"
	desc = "Corrective lenses, perfect for the near-sighted."
	correct_bad_vision = 1
	flash_compatible = TRUE

	attack_self(mob/user)
		user.show_text("You swap the style of your glasses.")
		if (src.icon_state == "glasses")
			src.icon_state = "glasses_round"
		else
			src.icon_state = "glasses"

/obj/item/clothing/glasses/regular/round
	name = "round glasses"
	icon_state = "glasses_round"
	item_state = "glasses_round"
	desc = "Big round corrective lenses, perfect for the near-sighted nerd."
	flash_compatible = FALSE

/obj/item/clothing/glasses/regular/ecto
	name = "peculiar spectacles"
	desc = "Admittedly, they are rather strange."
	icon_state = "ectoglasses"
	flash_compatible = TRUE
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
	flash_state = "goggle_flash"

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
				playsound(user, 'sound/voice/yeaaahhh.ogg', 100, FALSE)
				user.visible_message(SPAN_ALERT("<B><font size=3>YEAAAAAAAAAAAAAAAH!</font></B>"))
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
	var/image_group = CLIENT_IMAGE_GROUP_ARREST_ICONS

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/H = src.loc
			if (H.glasses == src)
				boutput(H, SPAN_ALERT("<B>Your HUD malfunctions!</B>"))
				H.take_eye_damage(3, 1)
				H.change_eye_blurry(5)
				H.bioHolder.AddEffect("bad_eyesight")
				SPAWN(10 SECONDS)
					H.bioHolder.RemoveEffect("bad_eyesight")

	emag_act(mob/user)
		if (src.image_group != CLIENT_IMAGE_GROUP_ARREST_ICONS)
			boutput(user, SPAN_ALERT("[src]'s facial recognition is already fried!"))
			return
		src.image_group = "fake_arrest_icons_\ref[src]"
		for (var/i in 1 to rand(3,7))
			var/datum/db_record/record = pick(data_core.security.records)
			for_by_tcl(H, /mob/living/carbon/human)
				if (H.real_name == record["name"] || H.name == record["name"])
					var/icon_state = pick(100; "*Arrest*", 20; "Contraband", 5; "Clown")
					var/image/fake_arrest_icon = image('icons/effects/sechud.dmi',H,icon_state,EFFECTS_LAYER_UNDER_4)
					fake_arrest_icon.appearance_flags = PIXEL_SCALE | RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART
					get_image_group(src.image_group).add_image(fake_arrest_icon)
					break

		if(src.equipped_in_slot == SLOT_GLASSES)
			get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).remove_mob(src.loc)
			get_image_group(src.image_group).add_mob(src.loc)

		boutput(user, SPAN_ALERT("You short out [src]'s facial recognition circuit!"))
		return TRUE

	equipped(var/mob/user, var/slot)
		..()
		if (slot == SLOT_GLASSES)
			get_image_group(src.image_group).add_mob(user)

	unequipped(var/mob/user)
		if(src.equipped_in_slot == SLOT_GLASSES)
			get_image_group(src.image_group).remove_mob(user)
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

/obj/item/clothing/glasses/nt_operative
	name = "\improper NanoTrasen Operative HUD"
	desc = "Patented NT technology compacting many different HUDs into one compact set of glasses.  Enhanced shielding blocks many flashes."
	icon_state = "nt"
	item_state = "sunglasses"
	color_r = 0.85
	color_g = 0.85
	color_b = 1

	equipped(var/mob/user, var/slot)
		..()
		if (slot == SLOT_GLASSES)
			//Security
			get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).add_mob(user)
			//Medical
			get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).add_mob(user)
			APPLY_ATOM_PROPERTY(user,PROP_MOB_EXAMINE_HEALTH,src)

	unequipped(var/mob/user)
		if(src.equipped_in_slot == SLOT_GLASSES)
			//Security
			get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).remove_mob(user)
			//Medical
			REMOVE_ATOM_PROPERTY(user,PROP_MOB_EXAMINE_HEALTH,src)
			get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(user)
		..()

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 100)

TYPEINFO(/obj/item/clothing/glasses/thermal)
	mats = 8

/obj/item/clothing/glasses/thermal
	name = "optical thermal scanner"
	icon_state = "thermal"
	item_state = "glasses"
	flash_state = "goggle_flash"
	flash_compatible = TRUE
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
				boutput(H, SPAN_ALERT("<B>Your thermals malfunction!</B>"))
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
	is_syndicate = TRUE

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
	flash_state = "goggle_flash"
	flash_compatible = TRUE
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
	item_state = "headset"
	block_eye = "R"
	nudge_compatible = FALSE
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
					user.show_message(SPAN_ALERT(">Um. Wow. Thats kinda grode."))
					return ..()
				theEye.appearance_flags |= RESET_COLOR
				user.show_message(SPAN_ALERT("You stab a hole in [src].  Unfortunately, you also stab a hole in your eye and when you pull [W] away your eye comes with it!!"))
				logTheThing(LOG_COMBAT, user, "removes their [log_object(theEye)] using an eyepatch and [log_object(W)] at [log_loc(user)].")
				return
			else
				pinhole = 1
				block_eye = null
				appearance_flags |= RESET_COLOR
				user.show_message(SPAN_NOTICE("You poke a tiny pinhole into [src]!"))
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
	icon_state = "vr_detective"
	item_state = "vr_detective"
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
	icon_state = "vr_scuttlebot"
	item_state = "vr_scuttlebot"
	var/mob/living/critter/robotic/scuttlebot/connected_scuttlebot = null

	equipped(var/mob/user, var/slot) //On equip, if there's a scuttlebot, control it
		..()
		var/mob/living/carbon/human/H = user
		if(connected_scuttlebot != null)
			if(connected_scuttlebot.mind)
				boutput(user, SPAN_ALERT("The scuttlebot is already active somehow!"))
			else if(!connected_scuttlebot.loc)
				boutput(user, SPAN_ALERT("You put on the goggles but they show no signal. The scuttlebot couldn't be found."))
			else
				H.network_device = src.connected_scuttlebot
				connected_scuttlebot.controller = H
				user.mind.transfer_to(connected_scuttlebot)
		else
			boutput(user, SPAN_ALERT("You put on the goggles but they show no signal. The scuttlebot is likely destroyed."))

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (istype(target, /mob/living/critter/robotic/scuttlebot))
			var/mob/living/critter/robotic/scuttlebot/S = target
			if (connected_scuttlebot != S)
				boutput(user, "You try to put the goggles back into the hat but it grumps at you, not recognizing the goggles.")
				return 1
			if (S.linked_hat != null)
				S.linked_hat.set_loc(get_turf(S))
			else
				if (istype(S, /mob/living/critter/robotic/scuttlebot/weak))
					var/obj/item/clothing/head/det_hat/gadget/newgadget = new /obj/item/clothing/head/det_hat/gadget(get_turf(S))
					if (S.is_inspector)
						newgadget.make_inspector()
				else
					var/obj/item/clothing/head/det_hat/folded_scuttlebot/newscuttle = new /obj/item/clothing/head/det_hat/folded_scuttlebot(get_turf(S))
					if (S.is_inspector)
						newscuttle.make_inspector()
			boutput(user, "You stuff the goggles back into the detgadget hat. It powers down with a low whirr.")
			for(var/obj/item/photo/P in S.contents)
				P.set_loc(get_turf(src))

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
	item_state = "vr"

	unequipped(var/mob/user)
		..()
		if(istype(user, /mob/living/carbon/human/virtual) && user:body)
			//Station_VNet.Leave_Vspace(user)
			user.death()
		return

/obj/item/clothing/glasses/vr/arcade
	icon_state = "vr"
	item_state = "vr"
	network = LANDMARK_VR_ARCADE

/obj/item/clothing/glasses/vr/bomb
	icon_state = "vr_science"
	item_state = "vr_science"
	network = LANDMARK_VR_BOMBTEST

TYPEINFO(/obj/item/clothing/glasses/healthgoggles)
	mats = 8

/obj/item/clothing/glasses/healthgoggles
	name = "\improper ProDoc Healthgoggles"
	desc = "Fitted with an advanced miniature sensor array that allows the user to quickly determine the physical condition of others."
	icon_state = "prodocs"
	flash_compatible = TRUE
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
				boutput(user, SPAN_ALERT("[src] already has a health scan upgrade!"))
				return
			else
				src.scan_upgrade = 1
				src.health_scan = 1
				var/mob/living/carbon/human/human_user = user
				if (istype(human_user) && human_user.glasses == src)
					APPLY_ATOM_PROPERTY(user,PROP_MOB_EXAMINE_HEALTH,src)
				src.icon_state = "prodocs-upgraded"
				boutput(user, SPAN_NOTICE("Health scan upgrade installed."))
				playsound(src.loc , 'sound/items/Deconstruct.ogg', 80, 0)
				user.u_equip(W)
				qdel(W)
				return
		else
			return ..()

	attack_self(mob/user as mob)
		if (!src.scan_upgrade)
			boutput(user, SPAN_ALERT("No health scan upgrade detected!"))
			return
		else
			src.health_scan = !(src.health_scan)
			boutput(user, SPAN_NOTICE("Health scanner [src.health_scan ? "enabled" : "disabled"]."))
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
	flash_state = "goggle_flash"
	flash_compatible = TRUE
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
				boutput(H, SPAN_ALERT("<B>Your nightvision goggles malfunction!</B>"))
				H.take_eye_damage(3, 1)
				H.change_eye_blurry(5)
				H.bioHolder.AddEffect("bad_eyesight")
				SPAWN(10 SECONDS)
					H.bioHolder.RemoveEffect("bad_eyesight")

	flashblocking //Admin or gimmick spawn option
		name = "advanced night vision sechud goggles"
		desc = "Goggles with separate built-in image-intensifier tubes to allow vision in the dark AND with darkened lenses? Wowee!"
		color_r = 0.8
		color_g = 0.8
		color_b = 0.8

		setupProperties()
			..()
			setProperty("disorient_resist_eye", 100)

	sechud
		name = "night vision sechud goggles"
		icon_state = "nightvisionsechud"
		desc = "Goggles with separate built-in image-intensifier tubes to allow vision in the dark. Keep away from bright lights. This version also has built in SecHUD functionality."
		color_r = 0.8
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
	var/freq = FREQ_AIRLOCK

	get_desc()
		return "A little dial on the side is set to [format_frequency(src.freq)]."

	attack_self(mob/user)
		. = ..()
		src.ui_interact(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "PacketVision")
			ui.open()

	ui_data(mob/user)
		. = ..()
		.["frequency"] = src.freq

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (action == "set-frequency" && params["finish"])
			var/old_freq = src.freq
			src.freq = sanitize_frequency_diagnostic(params["value"])
			if (src.freq != old_freq && src.equipped_in_slot == SLOT_GLASSES && ismob(src.loc))
				get_image_group("[CLIENT_IMAGE_GROUP_PACKETVISION][old_freq]").remove_mob(src.loc)
				get_image_group("[CLIENT_IMAGE_GROUP_PACKETVISION][src.freq]").add_mob(src.loc)
			return TRUE

	equipped(var/mob/user, var/slot)
		..()
		if (slot == SLOT_GLASSES)
			get_image_group("[CLIENT_IMAGE_GROUP_PACKETVISION][src.freq]").add_mob(user)

	unequipped(var/mob/user)
		if(src.equipped_in_slot == SLOT_GLASSES)
			get_image_group("[CLIENT_IMAGE_GROUP_PACKETVISION][src.freq]").remove_mob(user)
		..()

TYPEINFO(/obj/item/clothing/glasses/toggleable/atmos)
	mats = 6
/obj/item/clothing/glasses/toggleable/atmos
	name = "pressure visualization goggles"
	desc = "Goggles with an integrated local atmospheric pressure scanner, capable of providing a visualization of surrounding air pressure."
	icon_state = "atmos"
	item_state = "glasses"
	flash_state = "goggle_flash"
	flash_compatible = TRUE
	abilities = list(/obj/ability_button/atmos_goggle_toggle)
	var/list/image/atmos_overlays = list()
	//this is literally just a 32x32 white square, someone please tell me if there's a less dumb way to do this
	var/icon/overlay_icon = 'icons/effects/effects.dmi'
	var/overlay_state = "atmos_overlay"

	toggle(var/mob/toggler)
		..()
		toggler.playsound_local(src, 'sound/machines/tone_beep.ogg', 40, TRUE)
		if (src.equipped_in_slot == SLOT_GLASSES && src.on)
			processing_items |= src
		else
			processing_items -= src

	equipped(mob/user, slot)
		..()
		if (slot == SLOT_GLASSES && src.on)
			processing_items |= src

	unequipped(mob/user)
		if(src.equipped_in_slot == SLOT_GLASSES)
			processing_items -= src
		..()

	proc/clear_overlays(mob/M)
		if (!M.client)
			return
		for (var/image/image as anything in src.atmos_overlays)
			M.client.images -= image
		src.atmos_overlays = list()

	proc/generate_overlays(mob/M)
		if (!M.client)
			return
		for (var/turf/simulated/T in view(M, M.client.view))
			if (!T.air)
				continue
			var/image/new_overlay = image(src.overlay_icon, T, src.overlay_state)
			var/relative_pressure = MIXTURE_PRESSURE(T.air)/ONE_ATMOSPHERE
			//make more orange if over one atmosphere
			new_overlay.color = rgb(91 * (max(1,relative_pressure)), 103, 231 / (max(1,relative_pressure)))
			new_overlay.alpha = 0
			animate(new_overlay, alpha=min(200, 200 * relative_pressure), time=2 DECI SECONDS)
			animate(alpha=0, time=2 SECONDS)
			src.atmos_overlays += new_overlay
			M.client.images += new_overlay

	process()
		var/mob/M = src.loc
		if (!istype(M) || !M.client)
			return
		src.clear_overlays(M)
		src.generate_overlays(M)

/obj/item/clothing/glasses/eyestrain
	name = "blue-light filtering glasses"
	desc = "A pair of glasses that reduce eye-strain from staring a computer screen all shift."
	icon_state = "oglasses"
	flash_compatible = TRUE
	// would be nice if these tinted TGUI

	color_r = 1
	color_g = 0.9
	color_b = 0.8

