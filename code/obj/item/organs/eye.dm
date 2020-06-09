/*========================*/
/*----------Eyes----------*/
/*========================*/

/obj/item/organ/eye
	name = "eyeball"
	organ_name = "eye"
	desc = "Here's lookin' at you! Er, maybe not so much, anymore."
	icon_state = "eye"
	var/change_iris = 1
	var/color_r = 1 // same as glasses/helmets/masks/etc, used for vision color modifications, see human/handle_regular_hud_updates()
	var/color_g = 1
	var/color_b = 1
	var/show_on_examine = 0 // do we get mentioned when our donor is examined?

	New()
		..()
		SPAWN_DBG(0)
			src.update_icon()

	disposing()
		if (holder)
			if (holder.left_eye == src)
				holder.left_eye = null
			if (holder.right_eye == src)
				holder.right_eye = null
		..()

	proc/update_icon()
		if (!src.change_iris)
			return
		src.overlays = null
		var/image/iris_image = image(src.icon, src, "eye-iris")
		iris_image.color = "#0D84A8"
		if (src.donor && src.donor.bioHolder && src.donor.bioHolder.mobAppearance) // good lord
			var/datum/appearanceHolder/AH = src.donor.bioHolder.mobAppearance // I ain't gunna type that a billion times thanks
			if ((src.body_side == L_ORGAN && AH.customization_second == "Heterochromia Left") || (src.body_side == R_ORGAN && AH.customization_second == "Heterochromia Right")) // dfhsgfhdgdapeiffert
				iris_image.color = AH.customization_second_color
			else if ((src.body_side == L_ORGAN && AH.customization_third == "Heterochromia Left") || (src.body_side == R_ORGAN && AH.customization_third == "Heterochromia Right")) // gbhjdghgfdbldf
				iris_image.color = AH.customization_third_color
			else
				iris_image.color = AH.e_color
		src.overlays += iris_image

	attack(var/mob/living/carbon/M as mob, var/mob/user as mob)
		if (!ismob(M))
			return

		src.add_fingerprint(user)

		if (user.zone_sel.selecting != "head")
			return ..()
		if (!surgeryCheck(M, user))
			return ..()

		var/mob/living/carbon/human/H = M
		if (!H.organHolder)
			return ..()

		if (!headSurgeryCheck(H))
			user.show_text("You're going to need to remove that mask/helmet/glasses first.", "blue")
			return

		if (user.find_in_hand(src) == user.r_hand && !H.organHolder.right_eye)
			var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

			H.tri_message("<span style=\"color:red\"><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] right eye socket!</span>",\
			user, "<span style=\"color:red\">You [fluff] [src] into [user == H ? "your" : "[H]'s"] right eye socket!</span>",\
			H, "<span style=\"color:red\">[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your right eye socket!</span>")

			user.u_equip(src)
			H.organHolder.receive_organ(src, "right_eye", 2.0)
			H.update_body()

		else if (user.find_in_hand(src) == user.l_hand && !H.organHolder.left_eye)
			var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

			H.tri_message("<span style=\"color:red\"><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] left eye socket!</span>",\
			user, "<span style=\"color:red\">You [fluff] [src] into [user == H ? "your" : "[H]'s"] left eye socket!</span>",\
			H, "<span style=\"color:red\">[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your left eye socket!</span>")

			user.u_equip(src)
			H.organHolder.receive_organ(src, "left_eye", 2.0)
			H.update_body()

		else
			..()
		return

/obj/item/organ/eye/left
	name = "left eye"
	body_side = L_ORGAN

/obj/item/organ/eye/right
	name = "right eye"
	body_side = R_ORGAN

/obj/item/organ/eye/synth
	name = "syntheye"
	organ_name = "syntheye"
	desc = "An eye what done grew out of a plant."
	icon_state = "eye-synth"
	item_state = "plant"
	synthetic = 1
	made_from = "pharosium"

/obj/item/organ/eye/cyber
	name = "cybereye"
	organ_name = "cybereye"
	desc = "A fancy electronic eye to replace one that someone's lost. Kinda fragile, but better than nothing!"
	icon_state = "eye-cyber"
	item_state = "heart_robo1"
	robotic = 1
	edible = 0
	mats = 6
	made_from = "pharosium"
	show_on_examine = 1

	emp_act()
		..()
		if (!src.broken)
			src.take_damage(20, 20, 0)
			if (src.holder && src.holder.donor)
				src.holder.donor.show_text("<b>Your [src.organ_name] [pick("crackles and sparks", "makes a weird crunchy noise", "buzzes strangely")]!</b>", "red")

/obj/item/organ/eye/cyber/sunglass
	name = "polarized cybereye"
	organ_name = "polarized cybereye"
	desc = "A fancy electronic eye. It has a polarized filter on the lens for built-in protection from the sun and other harsh lightsources. Your night vision is fucked, though."
	icon_state = "eye-sunglass"
	mats = 7
	made_from = "pharosium"
	color_r = 0.95 // darken a little
	color_g = 0.95
	color_b = 0.975 // kinda blue
	change_iris = 0

	setupProperties()
		..()
		setProperty("disorient_resist_eye", 100)

/obj/item/organ/eye/cyber/sechud
	name = "\improper Security HUD cybereye"
	organ_name = "\improper Security HUD cybereye"
	desc = "A fancy electronic eye. It has a Security HUD system installed."
	icon_state = "eye-sec"
	mats = 7
	var/client/assigned = null
	made_from = "pharosium"
	color_r = 0.975 // darken a little, kinda red
	color_g = 0.95
	color_b = 0.95
	change_iris = 0

	process()
		if (assigned)
			assigned.images.Remove(arrestIconsAll)
			if (src.broken)
				processing_items.Remove(src)
				return
			addIcons()

			if (loc != assigned.mob)
				assigned.images.Remove(arrestIconsAll)
				assigned = null
		else
			processing_items.Remove(src)

	proc/addIcons()
		if (assigned)
			for (var/image/I in arrestIconsAll)
				if (!I || !I.loc || !src)
					continue
				if (I.loc.invisibility && I.loc != src.loc)
					continue
				else
					assigned.images.Add(I)

	on_transplant(var/mob/M as mob)
		..()
		if (src.broken)
			return
		if (M.client)
			src.assigned = M.client
			SPAWN_DBG(-1)
				if (!(src in processing_items))
					processing_items.Add(src)
		return

	on_removal()
		..()
		if (assigned)
			assigned.images.Remove(arrestIconsAll)
			assigned = null
			processing_items.Remove(src)
		return

/obj/item/organ/eye/cyber/thermal
	name = "thermal imager cybereye"
	organ_name = "thermal imager cybereye"
	desc = "A fancy electronic eye. It lets you see through cloaks and enhances your night vision. Use caution around bright lights."
	icon_state = "eye-thermal"
	mats = 7
	made_from = "pharosium"
	color_r = 1
	color_g = 0.9 // red tint
	color_b = 0.9
	change_iris = 0

/obj/item/organ/eye/cyber/meson
	name = "mesonic imager cybereye"
	organ_name = "mesonic imager cybereye"
	desc = "A fancy electronic eye. It lets you see the structure of the station through walls. Trippy!"
	icon_state = "eye-meson"
	mats = 7
	made_from = "pharosium"
	color_r = 0.925
	color_g = 1
	color_b = 0.9
	change_iris = 0
	organ_abilities = list(/datum/targetable/organAbility/meson)
	var/on = 1
	var/mob/living/carbon/human/assigned = null

	on_transplant(var/mob/M as mob)
		..()
		if (src.broken)
			return
		if (ishuman(M))
			src.assigned = M
			if (src.on)
				src.assigned.vision.set_scan(1)

	on_removal()
		..()
		if (istype(assigned.glasses, /obj/item/clothing/glasses/visor))
			return
		else
			src.assigned.vision.set_scan(0)

	proc/toggle()
		src.on = !src.on
		playsound(assigned, "sound/items/mesonactivate.ogg", 30, 1)
		if (src.on)
			assigned.vision.set_scan(1)
		else
			assigned.vision.set_scan(0)

/obj/item/organ/eye/cyber/spectro
	name = "spectroscopic imager cybereye"
	organ_name = "spectroscopic imager cybereye"
	desc = "A fancy electronic eye. It has an integrated minature Raman spectroscope for easy qualitative and quantitative analysis of chemical samples."
	icon_state = "eye-spectro"
	mats = 7
	made_from = "pharosium"
	color_r = 1 // pink tint?
	color_g = 0.9
	color_b = 0.95
	change_iris = 0

/obj/item/organ/eye/cyber/prodoc
	name = "\improper ProDoc Healthview cybereye"
	organ_name = "\improper ProDoc Healthview cybereye"
	desc = "A fancy electronic eye. It's fitted with an advanced miniature sensor array that allows you to quickly determine the physical condition of others."
	icon_state = "eye-prodoc"
	mats = 7
	var/client/assigned = null
	made_from = "pharosium"
	color_r = 0.925
	color_g = 1
	color_b = 0.925
	change_iris = 0

	// stolen from original prodocs
	process()
		if (assigned)
			assigned.images.Remove(health_mon_icons)
			if (src.broken)
				processing_items.Remove(src)
				return
			addIcons()

			if (loc != assigned.mob)
				assigned.images.Remove(health_mon_icons)
				assigned = null
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

	on_transplant(var/mob/M as mob)
		..()
		if (src.broken)
			return
		if (M.client)
			src.assigned = M.client
			SPAWN_DBG(-1)
				if (!(src in processing_items))
					processing_items.Add(src)
		return

	on_removal()
		..()
		if (assigned)
			assigned.images.Remove(health_mon_icons)
			assigned = null
			processing_items.Remove(src)
		return

/obj/item/organ/eye/cyber/ecto
	name = "ectosensor cybereye"
	organ_name = "ectosensor cybereye"
	desc = "A fancy electronic eye. It lets you see spooky stuff."
	icon_state = "eye-ecto"
	mats = 7
	made_from = "pharosium"
	color_r = 0.925
	color_g = 1
	color_b = 0.925
	change_iris = 0

/obj/item/organ/eye/cyber/camera
	name = "camera cybereye"
	organ_name = "camera cybereye"
	desc = "A fancy electronic eye. It has a camera in it connected to the station's security camera network."
	icon_state = "eye-camera"
	mats = 7
	var/obj/machinery/camera/camera = null
	var/camera_tag = "Eye Cam"
	var/camera_network = "Zeta"
	made_from = "pharosium"
	change_iris = 0

	New()
		..()
		SPAWN_DBG(0)
			src.camera = new /obj/machinery/camera(src)
			src.camera.c_tag = src.camera_tag
			src.camera.network = src.camera_network

	on_transplant(var/mob/M as mob)
		..()
		src.camera.c_tag = "[M]'s Eye"
		return ..()

/obj/item/organ/eye/cyber/nightvision
	name = "night vision cybereye"
	organ_name = "night vision cybereye"
	desc = "A fancy electronic eye. It has built-in image-intensifier tubes to allow vision in the dark. Keep away from bright lights."
	icon_state = "eye-night"
	mats = 7
	made_from = "pharosium"
	color_r = 0.7
	color_g = 1
	color_b = 0.7
	change_iris = 0

/obj/item/organ/eye/cyber/laser
	name = "laser cybereye"
	organ_name = "laser cybereye"
	desc = "A fancy electronic eye. It can fire a small laser."
	icon_state = "eye-laser"
	mats = 7
	made_from = "pharosium"
	color_r = 1
	color_g = 0.85
	color_b = 0.85
	change_iris = 0
	organ_abilities = list(/datum/targetable/organAbility/eyebeam)
	var/eye_proj_override = null

	add_ability(var/datum/abilityHolder/aholder, var/abil)
		if (!ispath(abil, /datum/targetable/organAbility/eyebeam) || !aholder)
			return ..()
		var/datum/targetable/organAbility/eyebeam/OA = aholder.getAbility(abil)//addAbility(abil)
		if (istype(OA)) // already has a laser eye, apparently!  let's DOUBLE IT
			OA.linked_organ = list(OA.linked_organ, src)
			OA.cooldown = 80
			OA.eye_proj = ispath(src.eye_proj_override) ? eye_proj_override : /datum/projectile/laser/eyebeams
		else
			OA = aholder.addAbility(abil)
			if (istype(OA))
				OA.linked_organ = src
				OA.cooldown = 40
				if (ispath(src.eye_proj_override))
					OA.eye_proj = src.eye_proj_override
					OA.cooldown = 80
				else if (src.body_side == L_ORGAN)
					OA.eye_proj = /datum/projectile/laser/eyebeams/left
				else
					OA.eye_proj = /datum/projectile/laser/eyebeams/right

	remove_ability(var/datum/abilityHolder/aholder, var/abil)
		if (!ispath(abil, /datum/targetable/organAbility/eyebeam) || !aholder)
			return ..()
		var/datum/targetable/organAbility/eyebeam/OA = aholder.getAbility(abil)
		if (!OA) // what??
			return
		if (islist(OA.linked_organ)) // two laser eyes, just remove our half of the projectile and whatnot
			var/list/lorgans = OA.linked_organ
			lorgans -= src // remove us from the list so only the other eye is left and thus will be lorgans[1]
			OA.linked_organ = lorgans[1]
			OA.cooldown = 40
			if (istype(OA.linked_organ, /obj/item/organ/eye/cyber/laser)) // I mean uhh it really really ought to be but we gotta be careful I guess
				var/obj/item/organ/eye/cyber/laser/other_eye = OA.linked_organ
				if (ispath(other_eye.eye_proj_override))
					OA.eye_proj = other_eye.eye_proj_override
					OA.cooldown = 80
					return
			if (src.body_side == L_ORGAN)
				OA.eye_proj = /datum/projectile/laser/eyebeams/right
			else
				OA.eye_proj = /datum/projectile/laser/eyebeams/left
		else // just us!
			aholder.removeAbility(abil)
