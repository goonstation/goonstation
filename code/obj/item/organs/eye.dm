/*========================*/
/*----------Eyes----------*/
/*========================*/

/obj/item/organ/eye
	name = "eyeball"
	organ_name = "eye"
	desc = "Here's lookin' at you! Er, maybe not so much, anymore."
	organ_holder_location = "head"
	icon = 'icons/obj/items/organs/eye.dmi'
	icon_state = "eye"
	var/change_iris = 1
	var/iris_color = "#0D84A8"
	var/iris_state_override = null
	var/color_r = 1 // same as glasses/helmets/masks/etc, used for vision color modifications, see human/handle_regular_hud_updates()
	var/color_g = 1
	var/color_b = 1
	///do we get mentioned when our donor is examined?
	var/show_on_examine = FALSE
	///provides sight for blindness checks
	var/provides_sight = TRUE

	New()
		..()
		SPAWN(0)
			src.UpdateIcon()

	disposing()
		if (holder)
			if (holder.left_eye == src)
				holder.left_eye = null
			if (holder.right_eye == src)
				holder.right_eye = null
		..()

	on_transplant(mob/M)
		. = ..()
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.update_face()

	on_removal()
		if(ishuman(donor))
			var/mob/living/carbon/human/H = donor
			SPAWN(0) //need to delay until after the eye is actually removed from the organholder
				H.update_face()
		. = ..()

	proc/update_color(datum/appearanceHolder/AH, side)
		if(src.change_iris)
			if (AH.customizations["hair_bottom"].style.id == "hetcro[side]")
				src.iris_color = AH.customizations["hair_bottom"].color
			else if (AH.customizations["hair_middle"].style.id == "hetcro[side]")
				src.iris_color = AH.customizations["hair_middle"].color
			else if (AH.customizations["hair_top"].style.id == "hetcro[side]")
				src.iris_color = AH.customizations["hair_top"].color
			else
				src.iris_color = AH.e_color
			var/image/iris_image = image(src.icon, src, "[iris_state_override || icon_state]-iris")
			iris_image.color = iris_color
			src.UpdateOverlays(iris_image, "iris")


	attach_organ(var/mob/living/carbon/M, var/mob/user)
		/* Overrides parent function to handle special case for attaching eyes.
		Note that eyes don't appear to track op_stage on the head container, like chest organs do. */
		var/mob/living/carbon/human/H = M
		if (!src.can_attach_organ(H, user))
			return 0

		if (!headSurgeryCheck(H))
			user.show_text("You're going to need to remove that mask/helmet/glasses first.", "blue")
			return null

		var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")
		var/target_organ_location = null

		if (user.find_in_hand(src, "right"))
			target_organ_location = "right"
		else if (user.find_in_hand(src, "left"))
			target_organ_location = "left"
		else if (!user.find_in_hand(src))
			// Organ is not in the attackers hand. This was likely a drag and drop. If you're just tossing an organ at a body, where it lands will be imprecise
			target_organ_location = pick("right", "left")

		if (target_organ_location == "right" && !H.organHolder.right_eye)
			user.tri_message(H, SPAN_ALERT("<b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] right eye socket!"),\
				SPAN_ALERT("You [fluff] [src] into [user == H ? "your" : "[H]'s"] right eye socket!"),\
				SPAN_ALERT("[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your right eye socket!"))

			if (user.find_in_hand(src))
				user.u_equip(src)
			H.organHolder.receive_organ(src, "right_eye", 2)
			H.update_body()
		else if (target_organ_location == "left" && !H.organHolder.left_eye)
			user.tri_message(H, SPAN_ALERT("<b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] left eye socket!"),\
				SPAN_ALERT("You [fluff] [src] into [user == H ? "your" : "[H]'s"] left eye socket!"),\
				SPAN_ALERT("[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your left eye socket!"))

			if (user.find_in_hand(src))
				user.u_equip(src)
			H.organHolder.receive_organ(src, "left_eye", 2)
			H.update_body()
		else
			user.tri_message(H, SPAN_ALERT("<b>[user]</b> tries to [fluff] the [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] right eye socket!<br>But there's something already there!"),\
				SPAN_ALERT("You try to [fluff] the [src] into [user == H ? "your" : "[H]'s"] right eye socket!<br>But there's something already there!"),\
				SPAN_ALERT("[H == user ? "You" : "<b>[user]</b>"] [H == user ? "try" : "tries"] to [fluff] the [src] into your right eye socket!<br>But there's something already there!"))
			return 0

		return 1

	// dead eyes stop working
	breakme()
		. = ..()
		src.provides_sight = FALSE

	unbreakme()
		. = ..()
		src.provides_sight = TRUE

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
	iris_state_override = "eye"
	iris_color = "#2dca2d"

TYPEINFO(/obj/item/organ/eye/cyber)
	mats = 6

/obj/item/organ/eye/cyber
	name = "cybereye"
	organ_name = "cybereye"
	desc = "A fancy electronic eye to replace one that someone's lost. Kinda fragile, but better than nothing!"
	icon_state = "eye-cyber"
	item_state = "heart_robo1"
	robotic = 1
	created_decal = /obj/decal/cleanable/oil
	edible = 0
	default_material = "pharosium"
	show_on_examine = TRUE
	change_iris = FALSE

	emp_act()
		..()
		if (!src.broken)
			src.donor.take_eye_damage(0.01, 0) //nonzero amount of eye damage in order to trigger actually updating the blindness/etc
			if (src.holder && src.holder.donor)
				src.holder.donor.show_text("<b>Your [src.organ_name] [pick("crackles and sparks", "makes a weird crunchy noise", "buzzes strangely")]!</b>", "red")

/obj/item/organ/eye/cyber/configurable
	iris_state_override = "eye"
	change_iris = TRUE

	attackby(obj/item/W, mob/user)
		if(ispulsingtool(W)) //TODO kyle's robotics configuration console/machine/thing
			var/new_color = tgui_color_picker(usr, "Choose a color", "Cybereye", "#0D84A8")
			if (!isnull(new_color))
				iris_color = new_color
			var/image/iris_image = image(src.icon, src, "eye-iris")
			iris_image.color = iris_color
			src.UpdateOverlays(iris_image, "iris")
		else
			. = ..()

TYPEINFO(/obj/item/organ/eye/cyber/sunglass)
	mats = 7

/obj/item/organ/eye/cyber/sunglass
	name = "polarized cybereye"
	organ_name = "polarized cybereye"
	desc = "A fancy electronic eye. It has a polarized filter on the lens for built-in protection from the sun and other harsh lightsources. Your night vision is fucked, though."
	icon_state = "eye-sunglass"
	default_material = "pharosium"
	color_r = 0.95 // darken a little
	color_g = 0.95
	color_b = 0.975 // kinda blue
	iris_color = "#202020"

	on_transplant(mob/M)
		. = ..()
		APPLY_ATOM_PROPERTY(M, PROP_MOB_DISORIENT_RESIST_EYE, src, 100)
		APPLY_ATOM_PROPERTY(M, PROP_MOB_DISORIENT_RESIST_EYE_MAX, src, 100)

	on_removal()
		REMOVE_ATOM_PROPERTY(donor, PROP_MOB_DISORIENT_RESIST_EYE, src)
		REMOVE_ATOM_PROPERTY(donor, PROP_MOB_DISORIENT_RESIST_EYE_MAX, src)
		. = ..()

TYPEINFO(/obj/item/organ/eye/cyber/sechud)
	mats = 7

/obj/item/organ/eye/cyber/sechud
	name = "\improper Security HUD cybereye"
	organ_name = "\improper Security HUD cybereye"
	desc = "A fancy electronic eye. It has a Security HUD system installed."
	icon_state = "eye-sec"
	default_material = "pharosium"
	color_r = 0.975 // darken a little, kinda red
	color_g = 0.95
	color_b = 0.95
	iris_color = "#3a0404"

	process()
		if (src.broken)
			processing_items.Remove(src)
			get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).remove_mob(donor)

	on_transplant(var/mob/M)
		..()
		if (src.broken)
			return
		processing_items |= src
		get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).add_mob(donor)

	on_removal()
		processing_items.Remove(src)
		get_image_group(CLIENT_IMAGE_GROUP_ARREST_ICONS).remove_mob(donor)
		..()

TYPEINFO(/obj/item/organ/eye/cyber/thermal)
	mats = 7

/obj/item/organ/eye/cyber/thermal
	name = "thermal imager cybereye"
	organ_name = "thermal imager cybereye"
	desc = "A fancy electronic eye. It lets you see through cloaks and enhances your night vision. Use caution around bright lights."
	icon_state = "eye-thermal"
	default_material = "pharosium"
	color_r = 1
	color_g = 0.9 // red tint
	color_b = 0.9
	iris_color = "#a01f1f"

	on_transplant(mob/M)
		. = ..()
		APPLY_ATOM_PROPERTY(M, PROP_MOB_THERMALVISION, src)

	on_removal()
		REMOVE_ATOM_PROPERTY(donor, PROP_MOB_THERMALVISION, src)
		. = ..()

TYPEINFO(/obj/item/organ/eye/cyber/meson)
	mats = 7

/obj/item/organ/eye/cyber/meson
	name = "mesonic imager cybereye"
	organ_name = "mesonic imager cybereye"
	desc = "A fancy electronic eye. It lets you see the structure of the station through walls. Trippy!"
	icon_state = "eye-meson"
	default_material = "pharosium"
	color_r = 0.925
	color_g = 1
	color_b = 0.9
	organ_abilities = list(/datum/targetable/organAbility/meson)
	var/on = 1
	var/mob/living/carbon/human/assigned = null
	iris_color = "#45bb00"

	on_transplant(var/mob/M)
		..()
		if (src.broken)
			return
		if (ishuman(M))
			src.assigned = M
			if (src.on)
				src.assigned.meson(src)

	on_removal()
		src.assigned.unmeson(src)
		..()

	proc/toggle()
		src.on = !src.on
		playsound(assigned, 'sound/items/mesonactivate.ogg', 30, TRUE)
		if (src.on)
			src.assigned.meson(src)
		else
			src.assigned.unmeson(src)

TYPEINFO(/obj/item/organ/eye/cyber/spectro)
	mats = 7

/obj/item/organ/eye/cyber/spectro
	name = "spectroscopic imager cybereye"
	organ_name = "spectroscopic imager cybereye"
	desc = "A fancy electronic eye. It has an integrated minature Raman spectroscope for easy qualitative and quantitative analysis of chemical samples."
	icon_state = "eye-spectro"
	default_material = "pharosium"
	color_r = 1 // pink tint?
	color_g = 0.9
	color_b = 0.95
	iris_color = "#d12ab5"

	on_transplant(mob/M)
		. = ..()
		APPLY_ATOM_PROPERTY(M, PROP_MOB_SPECTRO, src)

	on_removal()
		REMOVE_ATOM_PROPERTY(donor, PROP_MOB_SPECTRO, src)
		. = ..()

TYPEINFO(/obj/item/organ/eye/cyber/prodoc)
	mats = 7

/obj/item/organ/eye/cyber/prodoc
	name = "\improper ProDoc Healthview cybereye"
	organ_name = "\improper ProDoc Healthview cybereye"
	desc = "A fancy electronic eye. It's fitted with an advanced miniature sensor array that allows you to quickly determine the physical condition of others."
	icon_state = "eye-prodoc"
	default_material = "pharosium"
	color_r = 0.925
	color_g = 1
	color_b = 0.925
	iris_color = "#1dd144"

	// stolen from original prodocs
	process()
		if (src.broken)
			processing_items.Remove(src)
			get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(donor)

	on_transplant(var/mob/M)
		..()
		if (src.broken)
			return
		processing_items |= src
		APPLY_ATOM_PROPERTY(M,PROP_MOB_EXAMINE_HEALTH,src)
		get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).add_mob(M)
		return

	on_removal()
		processing_items.Remove(src)
		REMOVE_ATOM_PROPERTY(donor,PROP_MOB_EXAMINE_HEALTH,src)
		get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(donor)
		..()
		return

TYPEINFO(/obj/item/organ/eye/cyber/ecto)
	mats = 7

/obj/item/organ/eye/cyber/ecto
	name = "ectosensor cybereye"
	organ_name = "ectosensor cybereye"
	desc = "A fancy electronic eye. It lets you see spooky stuff."
	icon_state = "eye-ecto"
	default_material = "pharosium"
	color_r = 0.925
	color_g = 1
	color_b = 0.925
	iris_color = "#65e681"

	on_transplant(mob/M)
		. = ..()
		APPLY_ATOM_PROPERTY(M, PROP_MOB_GHOSTVISION, src)

	on_removal()
		REMOVE_ATOM_PROPERTY(donor, PROP_MOB_GHOSTVISION, src)
		. = ..()

TYPEINFO(/obj/item/organ/eye/cyber/camera)
	mats = 7

/obj/item/organ/eye/cyber/camera
	name = "camera cybereye"
	organ_name = "camera cybereye"
	desc = "A fancy electronic eye. It has a camera in it connected to the station's security camera network."
	icon_state = "eye-camera"
	var/obj/machinery/camera/camera = null
	var/camera_tag = "Eye Cam"
	var/camera_network = CAMERA_NETWORK_PUBLIC
	default_material = "pharosium"
	iris_color = "#0d0558"

	New()
		..()
		src.camera = new /obj/machinery/camera(src)
		src.camera.c_tag = src.camera_tag
		src.camera.network = src.camera_network

	on_transplant(var/mob/M)
		..()
		src.camera.c_tag = "[M]'s Eye"
		return ..()

TYPEINFO(/obj/item/organ/eye/cyber/nightvision)
	mats = 7

/obj/item/organ/eye/cyber/nightvision
	name = "night vision cybereye"
	organ_name = "night vision cybereye"
	desc = "A fancy electronic eye. It has built-in image-intensifier tubes to allow vision in the dark. Keep away from bright lights."
	icon_state = "eye-night"
	default_material = "pharosium"
	color_r = 0.7
	color_g = 1
	color_b = 0.7
	iris_color = "#027e17"

	on_transplant(mob/M)
		. = ..()
		APPLY_ATOM_PROPERTY(M, PROP_MOB_NIGHTVISION, src)

	on_removal()
		REMOVE_ATOM_PROPERTY(donor, PROP_MOB_NIGHTVISION, src)
		. = ..()

TYPEINFO(/obj/item/organ/eye/cyber/laser)
	mats = 7

/obj/item/organ/eye/cyber/laser
	name = "laser cybereye"
	organ_name = "laser cybereye"
	desc = "A fancy electronic eye. It can fire a small laser."
	icon_state = "eye-laser"
	default_material = "pharosium"
	color_r = 1
	color_g = 0.85
	color_b = 0.85
	organ_abilities = list(/datum/targetable/organAbility/eyebeam)
	iris_color = "#ff0000"
	var/eye_proj_override = null

	add_ability(var/datum/abilityHolder/aholder, var/abil)
		if (!ispath(abil, /datum/targetable/organAbility/eyebeam) || !aholder)
			return ..()
		var/datum/targetable/organAbility/eyebeam/OA = aholder.getAbility(abil)//addAbility(abil)
		if (istype(OA)) // already has a laser eye, apparently!  let's DOUBLE IT
			OA.linked_organ = list(OA.linked_organ, src)
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

TYPEINFO(/obj/item/organ/eye/cyber/monitor)
	mats = 7

/obj/item/organ/eye/cyber/monitor
	name = "monitor cybereye"
	organ_name = "monitor cybereye"
	desc = "A tiny screen to replace an eye. It can view camera networks from the installed monitor."
	organ_abilities = list(/datum/targetable/organAbility/view_camera)
	default_material = "pharosium"
	iris_color = "#0d0508"
	icon_state = "eye-monitor"
	var/obj/item/device/camera_viewer/viewer = null

	HELP_MESSAGE_OVERRIDE("You can replace the installed camera monitor by clicking the eye with a monitor in-hand.")

	New()
		. = ..()
		src.viewer = new /obj/item/device/camera_viewer/public(src)

	emag_act(mob/user, obj/item/card/emag/E)
		if(!src.emagged)
			if(user)
				boutput(user, SPAN_ALERT("The internal monitor's network limiter shorts, fusing to \the [src] and making the lens opaque!"))
			src.visible_message(SPAN_ALERT("<B>[src] sparks and shudders oddly!</B>"))
			src.viewer.camera_networks = list(
				CAMERA_NETWORK_STATION,
				CAMERA_NETWORK_PUBLIC,
				CAMERA_NETWORK_RANCH,
				CAMERA_NETWORK_MINING,
				CAMERA_NETWORK_SCIENCE,
				CAMERA_NETWORK_TELESCI,
				CAMERA_NETWORK_CARGO,
			)
			src.emagged = TRUE
			src.provides_sight = FALSE

	disposing()
		. = ..()
		qdel(src.viewer)
		src.viewer = null

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/device/camera_viewer))
			if(src.emagged)
				boutput(user, "The internal monitor on [src] is fused in place and can't be removed!")
				return
			user.u_equip(W)
			W.set_loc(src)
			boutput(user, "You install [W] into [src].")
			user.put_in_hand_or_drop(src.viewer)
			src.viewer = W
			return
		..()

	remove_ability(datum/abilityHolder/aholder, abil)
		if (!ispath(abil, /datum/targetable/organAbility/view_camera) || !aholder)
			return ..()
		if (aholder.owner)
			src.viewer.disconnect_user(aholder.owner)
			aholder.removeAbility(abil)


/obj/item/organ/eye/lizard
	name = "slit eye"
	desc = "I guess its owner is just a lzard now. Ugh that pun was terrible. Not worth losing an eye over."
	icon_state = "eye-lizard"

/obj/item/organ/eye/skeleton
	name = "boney eye"
	desc = "Yes it also has eye sockets. How this works is unknown."
	icon_state = "eye-bone"
	default_material = "bone" //duh
	blood_reagent = "calcium"
	change_iris = 0

/obj/item/organ/eye/cow
	name = "cow eye"
	desc = "This takes 'hitting the bullseye' to another level."
	icon_state = "eye-cow"
	blood_reagent = "milk"

/obj/item/organ/eye/pug
	name = "pug eye"
	desc = "Poor guy."

/obj/item/organ/eye/glass
	name = "glass eye"
	organ_name = "glass eye"
	desc = "Straight out of the sixteenth century. Surprisingly lifelike!"
	show_on_examine = TRUE
	provides_sight = FALSE
	created_decal = null
	default_material = "glass"
	blood_reagent = null
