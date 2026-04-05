/obj/item/clothing/suit/chameleon
	name = "hoodie"
	desc = "Nice and comfy on those cold space evenings."
	icon_state = "hoodie"
	item_state = "hoodie"
	icon = 'icons/obj/clothing/overcoats/hoods/hoodies.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/hoods/worn_hoodies.dmi'
	var/list/clothing_choices = list()
	var/current_choice = new/datum/chameleon_suit_pattern/hoodie

	New()
		..()
		for(var/U in (concrete_typesof(/datum/chameleon_suit_pattern)))
			var/datum/chameleon_suit_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/clothing/suit/U, mob/user)
		if(istype(U, /obj/item/clothing/suit/chameleon))
			boutput(user, SPAN_ALERT("No!!! That's a terrible idea! You'll cause a horrible outer suit meltdown death loop!"))
			SPAWN(1 SECOND)
				boutput(user, SPAN_ALERT("Nah, just making fun. Doing that still doesn't work though!"))
			return

		if(istype(U, /obj/item/clothing/suit))
			for(var/datum/chameleon_suit_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, SPAN_ALERT("That appearance is already saved in the chameleon pattern banks!"))
					return

			var/datum/chameleon_suit_pattern/P = new /datum/chameleon_suit_pattern(src)
			P.name = U.name
			P.desc = U.desc
			P.icon_state = U.icon_state
			P.item_state = U.item_state
			P.sprite_item = U.icon
			P.sprite_worn = U.wear_image_icon
			P.sprite_hand = U.inhand_image_icon
			P.over_hair = U.c_flags & COVERSHAIR
			src.clothing_choices += P

			boutput(user, SPAN_NOTICE("[U.name]'s appearance has been copied!"))

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, SPAN_ALERT("<B>Your chameleon suit malfunctions!</B>"))
			src.name = "hoodie"
			src.desc = "A comfy jacket that's hard on the eyes."
			src.icon_state = "hoodie-psyche"
			src.item_state = "hoodie-psyche"
			src.hides_from_examine = null
			src.icon = 'icons/obj/clothing/overcoats/hoods/hoodies.dmi'
			src.wear_image_icon = 'icons/mob/clothing/overcoats/hoods/worn_hoodies.dmi'
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Suit."
		set category = "Local"
		set src in usr


		var/datum/chameleon_suit_pattern/which = tgui_input_list(usr, "Change the suit to which pattern?", "Chameleon Suit", clothing_choices)

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_suit_pattern/T)
		if (T)
			src.current_choice = T
			src.hides_from_examine = T.hides_from_examine
			src.name = T.name
			src.desc = T.desc
			src.icon_state = T.icon_state
			src.item_state = T.item_state
			src.icon = T.sprite_item
			src.wear_image_icon = T.sprite_worn
			src.inhand_image_icon = T.sprite_hand
			src.wear_image = image(wear_image_icon)
			src.inhand_image = image(inhand_image_icon)
			if (T.over_hair)
				c_flags |= COVERSHAIR
			else
				c_flags &= ~COVERSHAIR
			src.tooltip_rebuild = TRUE
			usr.set_clothing_icon_dirty()

ABSTRACT_TYPE(/datum/chameleon_suit_pattern)
/datum/chameleon_suit_pattern
	var/name = "You should not see this!"
	var/desc = "Report me to a coder."
	var/icon_state = "hoodie"
	var/item_state = "hoodie"
	var/sprite_item = 'icons/obj/clothing/overcoats/item_suit.dmi'
	var/sprite_worn = 'icons/mob/clothing/overcoats/worn_suit.dmi'
	var/sprite_hand = 'icons/mob/inhand/overcoat/hand_suit.dmi'
	var/over_hair = FALSE
	var/hides_from_examine = null

	hoodie
		name = "hoodie"
		desc = "Nice and comfy on those cold space evenings."
		icon_state = "hoodie"
		item_state = "hoodie"
		sprite_item = 'icons/obj/clothing/overcoats/hoods/hoodies.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/hoods/worn_hoodies.dmi'

	labcoat
		name = "labcoat"
		desc = "A suit that protects against minor chemical spills and biohazards."
		icon_state = "labcoat"
		item_state = "labcoat"

	labcoat_genetics
		name = "geneticist's labcoat"
		desc = "A protective laboratory coat with the green markings of a Geneticist."
		icon_state = "GNlabcoat"
		item_state = "GNlabcoat"

	labcoat_pharmacy
		name = "pharmacist's labcoat"
		desc = "A protective laboratory coat with the green markings of a Pharmacist."
		icon_state = "PHlabcoat"
		item_state = "PHlabcoat"

	labcoat_robotics
		name = "roboticist's labcoat"
		desc = "A protective laboratory coat with the black markings of a Roboticist."
		icon_state = "ROlabcoat"
		item_state = "ROlabcoat"

	labcoat_medical
		name = "doctor's labcoat"
		desc = "A protective laboratory coat with the red markings of a Medical Doctor."
		icon_state = "MDlabcoat"
		item_state = "MDlabcoat"

	labcoat_science
		name = "scientist's labcoat"
		desc = "A protective laboratory coat with the purple markings of a Scientist."
		icon_state = "SCIlabcoat"
		item_state = "SCIlabcoat"

	labcoat_MD
		name = "medical director's labcoat"
		desc = "The Medical Directors personal labcoat, its creation was commisioned and designed by the director themself."
		icon_state = "MDlonglabcoat"
		item_state = "MDlonglabcoat"

	labcoat_RD
		name = "research director's labcoat"
		desc = "A bunch of purple glitter and cheap plastic glued together in a sad attempt to make a stylish lab coat."
		icon_state = "RDlabcoat"
		item_state = "RDlabcoat"


	paramedic
		name = "paramedic suit"
		desc = "A protective padded suit for emergency response personnel. Offers limited thermal and biological protection."
		icon_state = "paramedic"
		item_state = "paramedic"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
		hides_from_examine = C_UNIFORM|C_SHOES|C_GLOVES

	fire_suit
		name = "firesuit"
		desc = "A suit that protects against fire and heat."
		icon_state = "fire"
		item_state = "fire_suit"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
		hides_from_examine = C_UNIFORM|C_SHOES

	armor_vest
		name = "armor vest"
		desc = "An armored vest that protects against some damage. Contains carbon fibres."
		icon_state = "armorvest"
		item_state = "armorvest"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_armor.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_armor.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_armor.dmi'

	captain_armor
		name = "captain's armor"
		desc = "A suit of protective formal armor made for the station's captain."
		icon_state = "caparmor"
		item_state = "caparmor"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_armor.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_armor.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_armor.dmi'
		hides_from_examine = C_UNIFORM|C_SHOES|C_GLOVES

	hos_cape
		name = "Head of Security's cape"
		desc = "A lightly-armored and stylish cape, made of heat-resistant materials. It probably won't keep you warm, but it would make a great security blanket!"
		icon_state = "hos-cape"
		item_state = "hos-cape"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_armor.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_armor.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_armor.dmi'

	hos_jacket
		name = "Head of Security's jacket"
		desc = "A slightly armored jacket favored by security personnel. It looks cozy and warm; you could probably sleep in this if you wanted to!"
		icon_state = "hoscoat"
		item_state = "hoscoat"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit.dmi'

	detective_jacket
		name = "detective's coat"
		desc = "Someone who wears this means business."
		icon_state = "detective"
		item_state = "det_suit"

	winter_coat_medical
		name = "medical winter coat"
		desc = "A padded coat to protect against the cold."
		icon_state = "wintercoat-medical"
		item_state = "wintercoat-medical"

	winter_coat_research
		name = "research winter coat"
		desc = "A padded coat to protect against the cold."
		icon_state = "wintercoat-research"
		item_state = "wintercoat-research"

	winter_coat_engineering
		name = "engineering winter coat"
		desc = "A padded coat to protect against the cold."
		icon_state = "wintercoat-engineering"
		item_state = "wintercoat-engineering"

	winter_coat_security
		name = "security winter coat"
		desc = "A padded coat to protect against the cold."
		icon_state = "wintercoat-security"
		item_state = "wintercoat-security"

	winter_coat_command
		name = "command winter coat"
		desc = "A padded coat to protect against the cold."
		icon_state = "wintercoat-command"
		item_state = "wintercoat-command"

	winter_coat_detective
		name = "detective's winter coat"
		desc = "A comfy coat to protect against the cold. Popular with private investigators."
		icon_state = "wintercoat-detective"
		item_state = "wintercoat-detective"

	badge
		name = "Security Badge"
		desc = "An official badge for a Nanotrasen Security Worker."
		icon_state = "security_badge"
		item_state = "security_badge"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'

	space_suit
		name = "space suit"
		desc = "A suit that protects against low pressure environments."
		icon_state = "space"
		item_state = "s_suit"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
		hides_from_examine = C_UNIFORM|C_SHOES|C_GLOVES

	space_suit_emergency
		name = "emergency suit"
		desc = "A suit that protects against low pressure environments for a short time. Amazingly, it's even more bulky and uncomfortable than the engineering suits."
		icon_state = "emerg"
		item_state = "emerg"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
		hides_from_examine = C_UNIFORM|C_SHOES|C_GLOVES

	space_suit_engineering
		name = "engineering space suit"
		desc = "An overly bulky space suit designed mainly for maintenance and mining."
		icon_state = "espace"
		item_state = "es_suit"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
		hides_from_examine = C_UNIFORM|C_SHOES|C_GLOVES

	industrial_armor
		name = "industrial space armor"
		icon_state = "indus"
		item_state = "indus"
		desc = "Very heavy armour for prolonged industrial activity. Protects from radiation and explosions."
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
		hides_from_examine = C_UNIFORM|C_SHOES|C_GLOVES

	industrial_diving_armor
		name = "industrial diving suit"
		desc = "Very heavy armour for prolonged industrial activity. Protects from radiation and explosions."
		icon_state = "diving_suit-industrial"
		item_state = "diving_suit-industrial"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
		hides_from_examine = C_UNIFORM|C_SHOES|C_GLOVES

	bio_suit
		name = "bio suit"
		desc = "A suit that protects against biological contamination."
		icon_state = "bio_suit"
		item_state = "bio_suit"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'
		hides_from_examine = C_UNIFORM|C_SHOES|C_GLOVES

	botanist_apron
		name = "blue apron"
		desc = "This will keep you safe from tomato stains. Unless they're the exploding ones"
		icon_state = "apron-botany"
		item_state = "apron-botany"

	adeptus //the only outer suit chaplains get weirdly
		name = "adeptus mechanicus robe"
		desc = "A robe of a member of the adeptus mechanicus."
		icon_state = "adeptus"
		item_state = "adeptus"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
		over_hair = TRUE
		hides_from_examine = C_UNIFORM|C_SHOES|C_GLOVES|C_GLASSES|C_EARS

	chef_coat
		name = "chef's coat"
		desc = "BuRK BuRK BuRK - Bork Bork Bork!"
		icon_state = "chef"
		item_state = "chef"
