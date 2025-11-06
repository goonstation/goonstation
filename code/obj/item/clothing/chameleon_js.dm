/obj/item/clothing/under/chameleon
	name = "black jumpsuit"
	desc = "A generic jumpsuit with no rank markings."
	icon = 'icons/obj/clothing/jumpsuits/item_js.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuits/hand_js.dmi'
	icon_state = "black"
	item_state = "black"
	var/list/clothing_choices = list()
	var/current_choice = new/datum/chameleon_jumpsuit_pattern

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_jumpsuit_pattern)))
			var/datum/chameleon_jumpsuit_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/clothing/under/U, mob/user)
		if(istype(U, /obj/item/clothing/under/chameleon))
			boutput(user, SPAN_ALERT("No!!! That's a terrible idea! You'll cause a horrible jumpsuit chain reaction!"))
			SPAWN(1 SECOND)
				boutput(user, SPAN_ALERT("Nah, just kidding. Doing that still doesn't work though!"))
			return

		if(istype(U, /obj/item/clothing/under))
			for(var/datum/chameleon_jumpsuit_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, SPAN_ALERT("That appearance is already saved in the chameleon pattern banks!"))
					return

			var/datum/chameleon_jumpsuit_pattern/P = new /datum/chameleon_jumpsuit_pattern(src)
			P.name = U.name
			P.desc = U.desc
			P.icon_state = U.icon_state
			P.item_state = U.item_state
			P.sprite_item = U.icon
			P.sprite_worn = U.wear_image_icon
			P.sprite_hand = U.inhand_image_icon
			P.hide_underwear = U.hide_underwear
			src.clothing_choices += P

			boutput(user, SPAN_NOTICE("[U.name]'s appearance has been copied!"))

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, SPAN_ALERT("<B>Your chameleon jumpsuit malfunctions!</B>"))
			src.name = "psychedelic jumpsuit"
			src.desc = "Groovy!"
			src.icon_state = "psyche"
			src.item_state = "psyche"
			icon = 'icons/obj/clothing/jumpsuits/item_js_gimmick.dmi'
			wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'
			inhand_image_icon = 'icons/mob/inhand/jumpsuits/hand_js_gimmick.dmi'
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Jumpsuit."
		set category = "Local"
		set src in usr

		var/datum/chameleon_jumpsuit_pattern/which = tgui_input_list(usr, "Change the jumpsuit to which pattern?", "Chameleon Jumpsuit", clothing_choices)

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_jumpsuit_pattern/T)
		if (T)
			src.current_choice = T
			src.name = T.name
			src.desc = T.desc
			src.icon_state = T.icon_state
			src.item_state = T.item_state
			src.icon = T.sprite_item
			src.wear_image_icon = T.sprite_worn
			src.inhand_image_icon = T.sprite_hand
			src.wear_image = image(wear_image_icon)
			src.inhand_image = image(inhand_image_icon)
			src.hide_underwear = T.hide_underwear
			src.tooltip_rebuild = TRUE
			usr.set_clothing_icon_dirty()
			usr.update_body()

/datum/chameleon_jumpsuit_pattern
	var/name = "black jumpsuit"
	var/desc = "A generic jumpsuit with no rank markings."
	var/icon_state = "black"
	var/item_state = "black"
	var/sprite_item = 'icons/obj/clothing/jumpsuits/item_js.dmi'
	var/sprite_worn = 'icons/mob/clothing/jumpsuits/worn_js.dmi'
	var/sprite_hand = 'icons/mob/inhand/jumpsuits/hand_js.dmi'
	var/hide_underwear = FALSE

	white
		name = "white jumpsuit"
		icon_state = "white"
		item_state = "white"

	grey
		name = "grey jumpsuit"
		icon_state = "grey"
		item_state = "grey"

	green
		name = "green jumpsuit"
		icon_state = "green"
		item_state = "green"

	aqua
		name = "cyan jumpsuit"
		icon_state = "aqua"
		item_state  = "aqua"

	lightblue
		name = "sky blue jumpsuit"
		icon_state = "lightblue"
		item_state  = "lightblue"
	blue
		name = "blue jumpsuit"
		icon_state = "blue"
		item_state = "blue"

	darkblue
		name = "indigo jumpsuit"
		icon_state = "darkblue"
		item_state  = "darkblue"

	purple
		name = "purple jumpsuit"
		icon_state = "purple"
		item_state  = "purple"

	lightpurple
		name = "violet jumpsuit"
		icon_state = "lightpurple"
		item_state  = "lightpurple"

	magenta
		name = "magenta jumpsuit"
		icon_state = "magenta"
		item_state = "magenta"

	pink
		name = "pink jumpsuit"
		icon_state = "pink"
		item_state = "pink"

	red
		name = "red jumpsuit"
		icon_state = "red"
		item_state = "red"

	rank
		name = "staff assistant's jumpsuit"
		desc = "It's a generic grey jumpsuit. That's about what assistants are worth, anyway."
		icon_state = "assistant"
		item_state = "assistant"
		sprite_item = 'icons/obj/clothing/jumpsuits/item_js_rank.dmi'
		sprite_worn = 'icons/mob/clothing/jumpsuits/worn_js_rank.dmi'
		sprite_hand = 'icons/mob/inhand/jumpsuits/hand_js_rank.dmi'

	rank/engineer
		name = "engineer's jumpsuit"
		desc = "If this suit was non-conductive, maybe engineers would actually do their damn job."
		icon_state = "engine"
		item_state = "engine"

	rank/medical
		name = "medical doctor's jumpsuit"
		desc = "It's got a red plus on it, that's a good thing right?"
		icon_state = "medical"
		item_state = "medical"

	rank/roboticist
		name = "roboticist's jumpsuit"
		desc = "Black and white, like ethics."
		icon_state = "robotics"
		item_state = "robotics"

	rank/scientist
		name = "scientist's jumpsuit"
		desc = "A research jumpsuit, supposedly more resistant to biohazards. It had better be!"
		icon_state = "scientist"
		item_state = "scientist"

	rank/geneticist
		name = "geneticist's jumpsuit"
		desc = "Genetics is very green these days, isn't it?"
		icon_state = "genetics"
		item_state = "genetics"

	rank/hydroponics
		name = "botanist's jumpsuit"
		desc = "Has a strong earthy smell to it. Hopefully it's merely dirty as opposed to soiled."
		icon_state = "hydro"
		item_state = "hydro"

	rank/janitor
		name = "janitor's jumpsuit"
		desc = "You don't really want to think about what those stains are from."
		icon_state = "janitor"
		item_state = "janitor"

	rank/bartender
		name = "bartender's suit"
		desc = "A nice and tidy outfit. Shame about the bar though."
		icon_state = "barman"
		item_state = "barman"

	rank/chef
		name = "chef's uniform"
		desc = "Issued only to the most hardcore chefs in space."
		icon_state = "chef"
		item_state = "chef"

	rank/chaplain
		name = "chaplain jumpsuit"
		desc = "A protestant vicar's outfit. Used to be a nun's, but it was a rather bad habit."
		icon_state = "chaplain"
		item_state = "chaplain"

	rank/cargo
		name = "quartermaster's jumpsuit"
		desc = "What can brown do for you?"
		icon_state = "qm"
		item_state = "qm"

	rank/overalls
		name = "miner's overalls"
		desc = "Durable overalls for the hard worker who likes to smash rocks into little bits."
		icon_state = "miner"
		item_state = "miner"

	rank/security
		name = "security uniform"
		desc = "Is anyone who wears a jacket like that EVER good?"
		icon_state = "security"
		item_state = "security"

	rank/det
		name = "hard worn suit"
		desc = "Someone who wears this means business. Either that or they're a total dork."
		icon_state = "detective"
		item_state = "detective"

	rank/captain
		name = "captain's uniform"
		desc = "Would you believe terrorists actually want to steal this jumpsuit? It's true!"
		icon_state = "captain"
		item_state = "captain"

	rank/head_of_personnel
		name = "head of personnel's uniform"
		desc = "Rather bland and inoffensive. Perfect for vanishing off the face of the universe."
		icon_state = "hop"
		item_state = "hop"

	rank/head_of_securityold
		name = "head of security's uniform"
		desc = "It's bright red and rather crisp, much like security's victims tend to be."
		icon_state = "hos"
		item_state = "hos"

	rank/chief_engineer
		name = "chief engineer's uniform"
		desc = "It's an old, battered boiler suit with faded oil stains."
		icon_state = "chief"
		item_state = "chief"

	rank/research_director
		name = "research director's uniform"
		desc = "This suit is ludicrously cheap. They must be embezzling the research budget again."
		icon_state = "director"
		item_state = "director"

	rank/medical_director
		name = "medical director's uniform"
		desc = "There's some odd stains on this thing. Hm."
		icon_state = "med_director"
		item_state = "med_director"

	rank/security_assistant
		name = "security assistant uniform"
		desc = "Wait, is that velcro?"
		icon_state = "security-assistant"
		item_state = "security-assistant"

	rank/rancher
		name = "rancher's overalls"
		desc = "Smells like a barn; hopefully its wearer wasn't raised in one."
		icon_state = "rancher"
		item_state = "rancher"

	courier
		name = "postmaster's jumpsuit"
		desc = "The crisp threads of a postmaster."
		icon_state = "mail"
		item_state = "mail"
		sprite_item = 'icons/obj/clothing/jumpsuits/item_js_misc.dmi'
		sprite_worn = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
		sprite_hand = 'icons/mob/inhand/jumpsuits/hand_js_misc.dmi'

/obj/item/clothing/head/chameleon
	name = "hat"
	desc = "A knit cap in red."
	icon_state = "red"
	item_state = "rgloves"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	icon = 'icons/obj/clothing/item_hats.dmi'
	var/list/clothing_choices = list()
	var/current_choice = new/datum/chameleon_hat_pattern
	blocked_from_petasusaphilic = TRUE
	item_function_flags = IMMUNE_TO_ACID

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_hat_pattern)))
			var/datum/chameleon_hat_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/clothing/head/U, mob/user)
		if(istype(U, /obj/item/clothing/head/chameleon))
			boutput(user, SPAN_ALERT("No!!! That's a terrible idea! You'll cause a cataclysmic hat infinite loop!"))
			SPAWN(1 SECOND)
				boutput(user, SPAN_ALERT("Nah, just yankin' your chain. Doing that still doesn't work though!"))
			return

		if(istype(U, /obj/item/clothing/head/))
			for(var/datum/chameleon_hat_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, SPAN_ALERT("That appearance is already saved in the chameleon pattern banks!"))
					return

			var/datum/chameleon_hat_pattern/P = new /datum/chameleon_hat_pattern(src)
			P.name = U.name
			P.desc = U.desc
			P.icon_state = U.icon_state
			P.item_state = U.item_state
			P.sprite_item = U.icon
			P.sprite_worn = U.wear_image_icon
			P.sprite_hand = U.inhand_image_icon
			P.seal_hair = U.c_flags & COVERSHAIR
			src.clothing_choices += P

			boutput(user, SPAN_NOTICE("[U.name]'s appearance has been copied!"))

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, SPAN_ALERT("<B>Your chameleon hat malfunctions!</B>"))
			src.name = "hat"
			src.desc = "A knit cap in...what the hell?"
			src.icon_state = "psyche"
			src.item_state = "bgloves"
			src.hides_from_examine = null
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			src.c_flags &= ~COVERSHAIR
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Hat."
		set category = "Local"
		set src in usr

		var/datum/chameleon_hat_pattern/which = tgui_input_list(usr, "Change the hat to which pattern?", "Chameleon Hat", clothing_choices)

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_hat_pattern/T)
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
			if (T.seal_hair)
				c_flags |= COVERSHAIR
			else
				c_flags &= ~COVERSHAIR
			src.tooltip_rebuild = TRUE
			usr.set_clothing_icon_dirty()

/datum/chameleon_hat_pattern
	var/name = "hat"
	var/desc = "A knit cap in red."
	var/icon_state = "red"
	var/item_state = "rgloves"
	var/sprite_item = 'icons/obj/clothing/item_hats.dmi'
	var/sprite_worn = 'icons/mob/clothing/head.dmi'
	var/sprite_hand = 'icons/mob/inhand/hand_headgear.dmi'
	var/seal_hair = FALSE
	var/hides_from_examine = null

	NTberet
		name = "Nanotrasen beret"
		desc = "For the inner space dictator in you."
		icon_state = "ntberet"
		item_state = "ntberet"
		seal_hair = FALSE

	HoS_beret
		name = "HoS Beret"
		icon_state = "hosberet"
		item_state = "hosberet"
		desc = "Actually, this hat is from a fast-food restaurant, that's why it folds like it was made of paper."
		seal_hair = FALSE

	HoS_hat
		name = "HoS Hat"
		icon_state = "hoscap"
		item_state = "hoscap"
		desc = "Actually, this hat is from a fast-food restaurant, that's why it folds like it was made of paper."
		seal_hair = FALSE

	caphat
		name = "Captain's hat"
		icon_state = "captain"
		item_state = "caphat"
		desc = "A symbol of the captain's rank, and the source of all their power."
		seal_hair = FALSE

	janiberet
		name = "Head of Sanitation beret"
		desc = "The Chief of Cleaning, the Superintendent of Scrubbing, whatever you call yourself, you know how to make those tiles shine. Good job."
		icon_state = "janitorberet"
		item_state = "janitorberet"
		seal_hair = FALSE

	janihat
		name = "Head of Sanitation hat"
		desc = "The Chief of Cleaning, the Superintendent of Scrubbing, whatever you call yourself, you know how to make those tiles shine. Good job."
		icon_state = "janitorhat"
		item_state = "janitorhat"
		seal_hair = FALSE

	hardhat
		name = "hard hat"
		icon_state = "hardhat0"
		item_state = "hardhat0"
		desc = "Protects your head from falling objects, and comes with a flashlight. Safety first!"
		seal_hair = FALSE

	hardhat_CE
		name = "chief engineer's hard hat"
		icon_state = "hardhat_chief_engineer0"
		item_state = "hardhat_chief_engineer0"
		desc = "A dented old helmet with a bright green stripe. An engraving on the inside reads 'CE'."
		seal_hair = FALSE

	security
		name = "helmet"
		icon_state = "helmet-sec"
		item_state = "helmet"
		desc = "Somewhat protects your head from being bashed in."
		seal_hair = FALSE
		hides_from_examine = C_EARS

	fancy
		name = "fancy hat"
		icon_state = "rank-fancy"
		item_state = "that"
		desc = "What do you mean this hat isn't fancy?"
		seal_hair = FALSE

	detective
		name = "Detective's hat"
		desc = "Someone who wears this will look very smart."
		icon_state = "detective"
		item_state = "det_hat"
		seal_hair = FALSE

	space_helmet
		name = "space helmet"
		icon_state = "space"
		item_state = "s_helmet"
		desc = "Helps protect against vacuum."
		seal_hair = TRUE
		hides_from_examine = C_EARS|C_MASK|C_GLASSES

	space_helmet_emergency
		name = "emergency hood"
		icon_state = "emerg"
		item_state = "emerg"
		desc = "Helps protect from vacuum for a short period of time."
		seal_hair = TRUE
		hides_from_examine = C_EARS|C_MASK|C_GLASSES

	space_helmet_engineer
		name = "engineering space helmet"
		desc = "Comes equipped with a builtin flashlight."
		icon_state = "espace0"
		item_state = "s_helmet"
		seal_hair = TRUE
		hides_from_examine = C_EARS|C_MASK|C_GLASSES

	industrial_helmet
		icon_state = "indus"
		item_state = "indus"
		name = "industrial space helmet"
		desc = "Goes with Industrial Space Armor. Now with zesty citrus-scented visor!"
		seal_hair = TRUE
		hides_from_examine = C_EARS|C_MASK|C_GLASSES

	industrial_diving_helmet
		icon_state = "diving_suit-industrial"
		item_state = "diving_suit-industrial"
		name = "industrial diving helmet"
		desc = "Goes with Industrial Diving Suit. Now with a fresh mint-scented visor!"
		seal_hair = TRUE
		hides_from_examine = C_EARS|C_MASK|C_GLASSES

	cowboy_hat
		name = "cowboy hat"
		desc = "Yeehaw!"
		icon_state = "cowboy"
		item_state = "cowboy"
		seal_hair = FALSE

	turban
		name = "turban"
		desc = "A very comfortable cotton turban."
		icon_state = "turban"
		item_state = "that"
		seal_hair = FALSE

	top_hat
		name = "top hat"
		desc = "An stylish looking hat"
		icon_state = "tophat"
		item_state = "that"
		seal_hair = FALSE

	chef_hat
		name = "Chef's hat"
		desc = "Your toque blanche, coloured as such so that your poor sanitation is obvious, and the blood shows up nice and crazy."
		icon_state = "chef"
		item_state = "chefhat"
		seal_hair = FALSE

	bio_hood
		name = "bio hood"
		icon_state = "bio"
		item_state = "bio_hood"
		desc = "This hood protects you from harmful biological contaminants."
		seal_hair = TRUE
		hides_from_examine = C_EARS

	postal_cap
		name = "postmaster's hat"
		desc = "The hat of a postmaster."
		icon_state = "mailcap"
		item_state = "mailcap"
		seal_hair = FALSE

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

/obj/item/clothing/glasses/chameleon
	name = "prescription glasses"
	desc = "Corrective lenses, perfect for the near-sighted."
	icon_state = "glasses"
	item_state = "glasses"
	icon = 'icons/obj/clothing/item_glasses.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	wear_image_icon = 'icons/mob/clothing/eyes.dmi'
	var/list/clothing_choices = list()
	var/current_choice = new/datum/chameleon_glasses_pattern

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_glasses_pattern)))
			var/datum/chameleon_glasses_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/clothing/glasses/U, mob/user)
		if(istype(U, /obj/item/clothing/glasses/chameleon))
			boutput(user, SPAN_ALERT("No!!! That's a horrible idea! You'll cause a horrible eyewear cascade!"))
			SPAWN(1 SECOND)
				boutput(user, SPAN_ALERT("Nah, just pulling your leg. Doing that still doesn't work though!"))
			return

		if(istype(U, /obj/item/clothing/glasses/))
			for(var/datum/chameleon_glasses_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, SPAN_ALERT("That appearance is already saved in the chameleon pattern banks!"))
					return

			var/datum/chameleon_glasses_pattern/P = new /datum/chameleon_glasses_pattern(src)
			P.name = U.name
			P.desc = U.desc
			P.icon_state = U.icon_state
			P.item_state = U.item_state
			P.sprite_item = U.icon
			P.sprite_worn = U.wear_image_icon
			P.sprite_hand = U.inhand_image_icon
			src.clothing_choices += P

			boutput(user, SPAN_NOTICE("[U.name]'s appearance has been copied!"))

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, SPAN_ALERT("<B>Your chameleon glasses malfunction!</B>"))
			src.name = "glasses"
			src.desc = "A pair of glasses. They seem to be broken, though."
			src.icon_state = "psyche"
			src.item_state = "psyche"
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Glasses."
		set category = "Local"
		set src in usr

		var/datum/chameleon_glasses_pattern/which = tgui_input_list(usr, "Change the glasses to which pattern?", "Chameleon Glasses", clothing_choices)

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_glasses_pattern/T)
		if (T)
			src.current_choice = T
			src.name = T.name
			src.desc = T.desc
			src.icon_state = T.icon_state
			src.item_state = T.item_state
			src.icon = T.sprite_item
			src.wear_image_icon = T.sprite_worn
			src.inhand_image_icon = T.sprite_hand
			src.wear_image = image(wear_image_icon)
			src.inhand_image = image(inhand_image_icon)
			src.tooltip_rebuild = TRUE
			usr.set_clothing_icon_dirty()

/datum/chameleon_glasses_pattern
	var/name = "prescription glasses"
	var/desc = "Corrective lenses, perfect for the near-sighted."
	var/icon_state = "glasses"
	var/item_state = "glasses"
	var/sprite_item = 'icons/obj/clothing/item_glasses.dmi'
	var/sprite_worn = 'icons/mob/clothing/eyes.dmi'
	var/sprite_hand = 'icons/mob/inhand/hand_headgear.dmi'

	meson
		name = "Meson Goggles"
		desc = "Goggles that allow you to see the structure of the station through walls."
		icon_state = "meson"
		item_state = "glasses"

	sunglasses
		name = "sunglasses"
		desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
		icon_state = "sun"
		item_state = "sunglasses"

	sechud
		name = "\improper Security HUD"
		desc = "Sunglasses with a high tech sheen."
		icon_state = "sec"

	thermal
		name = "optical thermal scanner"
		icon_state = "thermal"
		item_state = "glasses"

	visor
		name = "\improper VISOR goggles"
		icon_state = "visor"
		item_state = "glasses"

	prodoc
		name = "\improper ProDoc Healthgoggles"
		desc = "Fitted with an advanced miniature sensor array that allows the user to quickly determine the physical condition of others."
		icon_state = "prodocs-upgraded"

	spectro
		name = "spectroscopic scanner goggles"
		icon_state = "spectro"
		item_state = "glasses"

/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	desc = "These shoes somewhat protect you from fire."
	icon_state = "black"
	icon = 'icons/obj/clothing/item_shoes.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_feethand.dmi'
	wear_image_icon = 'icons/mob/clothing/feet.dmi'
	var/list/clothing_choices = list()
	var/current_choice = new/datum/chameleon_shoes_pattern
	step_sound = "step_default"

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_shoes_pattern)))
			var/datum/chameleon_shoes_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/clothing/shoes/U, mob/user)
		if(istype(U, /obj/item/clothing/shoes/chameleon))
			boutput(user, SPAN_ALERT("No!!! That's a terrible idea! You'll cause a bad shoe feedback cycle!"))
			SPAWN(1 SECOND)
				boutput(user, SPAN_ALERT("Nah, just joking. Doing that still doesn't work though!"))
			return

		if(istype(U, /obj/item/clothing/shoes/cowboy/boom)) //if they're gonna copy sounds they're not gonna work on boom boots
			boutput(user, SPAN_ALERT("It doesn't seem like your chameleon shoes can copy that. Hmm."))
			return

		if(istype(U, /obj/item/clothing/shoes))
			for(var/datum/chameleon_shoes_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, SPAN_ALERT("That appearance is already saved in the chameleon pattern banks!"))
					return

			var/datum/chameleon_shoes_pattern/P = new /datum/chameleon_shoes_pattern(src)
			P.name = U.name
			P.desc = U.desc
			P.icon_state = U.icon_state
			P.item_state = U.item_state
			P.sprite_item = U.icon
			P.sprite_worn = U.wear_image_icon
			P.sprite_hand = U.inhand_image_icon
			P.step_sound = U.step_sound
			src.clothing_choices += P

			boutput(user, SPAN_NOTICE("[U.name]'s appearance has been copied!"))

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, SPAN_ALERT("<B>Your chameleon shoes malfunction!</B>"))
			src.name = "shoes"
			src.desc = "A pair of shoes. Maybe they're those light up kind you had as a kid?"
			src.icon_state = "psyche"
			src.item_state = "psyche"
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Shoes."
		set category = "Local"
		set src in usr

		var/datum/chameleon_shoes_pattern/which = tgui_input_list(usr, "Change the shoes to which pattern?", "Chameleon Shoes", clothing_choices)

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_shoes_pattern/T)
		if (T)
			src.current_choice = T
			src.name = T.name
			src.desc = T.desc
			src.icon_state = T.icon_state
			src.item_state = T.item_state
			src.icon = T.sprite_item
			src.wear_image_icon = T.sprite_worn
			src.inhand_image_icon = T.sprite_hand
			src.wear_image = image(wear_image_icon)
			src.inhand_image = image(inhand_image_icon)
			src.step_sound = T.step_sound
			src.tooltip_rebuild = TRUE
			usr.set_clothing_icon_dirty()

/datum/chameleon_shoes_pattern
	var/name = "black shoes"
	var/desc = "These shoes somewhat protect you from fire."
	var/icon_state = "black"
	var/item_state = "black"
	var/sprite_item = 'icons/obj/clothing/item_shoes.dmi'
	var/sprite_worn = 'icons/mob/clothing/feet.dmi'
	var/sprite_hand = 'icons/mob/inhand/hand_feethand.dmi'
	var/step_sound = "step_default"

	brown
		name = "brown shoes"
		icon_state = "brown"
		item_state = "brown"
		desc = "Brown shoes, camouflage on this kind of station."
		step_sound = "step_default"

	red
		name = "red shoes"
		icon_state = "red"
		item_state = "red"
		step_sound = "step_default"

	orange
		name = "orange shoes"
		icon_state = "orange"
		item_state = "orange"
		desc = "Shoes, now in prisoner orange! Can be made into shackles."
		step_sound = "step_default"

	white
		name = "white shoes"
		icon_state = "white"
		item_state = "white"
		desc = "Protects you against biohazards that would enter your feet."
		step_sound = "step_default"

	magnetic
		name = "magnetic shoes"
		desc = "Keeps the wearer firmly anchored to the ground. Provided the ground is metal, of course."
		icon_state = "magboots"
		item_state = "magboots"
		step_sound = "step_plating"

	swat
		name = "military boots"
		desc = "Polished and very shiny military boots."
		icon_state = "swat"
		item_state = "swat"
		step_sound = "step_military"

	caps_boots
		name = "captain's boots"
		desc = "A set of formal shoes with a protective layer underneath."
		icon_state = "capboots"
		item_state = "capboots"
		step_sound = "step_military"

	galoshes
		name = "galoshes"
		desc = "Rubber boots that prevent slipping on wet surfaces."
		icon_state = "galoshes"
		item_state = "galoshes"
		step_sound = "step_rubberboot"

	detective
		name = "worn boots"
		desc = "This pair of leather boots has seen better days."
		icon_state = "detective"
		item_state = "detective"
		step_sound = "step_default"

	magic_sandals
		name = "magic sandals"
		desc = "They magically stop you from slipping on magical hazards. It's not the mesh on the underside that does that. It's MAGIC. Read a fucking book."
		icon_state = "wizard"
		item_state = "wizard"
		step_sound = "step_flipflop"

	chef
		name = "chef's clogs"
		desc = "Sturdy shoes that minimize injury from falling objects or knives."
		icon_state = "chef"
		step_sound = "step_wood"

	mechanised_diving_boots
		name = "mechanised diving boots"
		icon_state = "divindboots"
		item_state = "divindboots"
		desc = "Industrial-grade boots fitted with mechanised balancers and stabilisers to increase running speed under a heavy workload."
		step_sound = "step_default"

	mechanised_boots
		icon_state = "indboots"
		item_state = "indboots"
		name = "mechanised boots"
		desc = "Industrial-grade boots fitted with mechanised balancers and stabilisers to increase running speed under a heavy workload."
		step_sound = "step_default"

/obj/item/clothing/gloves/chameleon
	name = "black gloves"
	desc = "These thick leather gloves are fire-resistant."
	icon_state = "black"
	item_state = "bgloves"
	icon = 'icons/obj/clothing/item_gloves.dmi'
	wear_image_icon = 'icons/mob/clothing/hands.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_feethand.dmi'
	var/list/clothing_choices = list()
	var/current_choice = new/datum/chameleon_gloves_pattern
	material_prints = "black leather fibers"
	hide_prints = TRUE
	scramble_prints = FALSE
	fingertip_color = "#535353"

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_gloves_pattern)))
			var/datum/chameleon_gloves_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/clothing/gloves/U, mob/user)
		if(istype(U, /obj/item/clothing/gloves/chameleon))
			boutput(user, SPAN_ALERT("No!!! That's a terrible idea! You'll cause an awful glove fractal!"))
			SPAWN(1 SECOND)
				boutput(user, SPAN_ALERT("Nah, just having a laugh. Doing that still doesn't work though!"))
			return

		if(istype(U, /obj/item/clothing/gloves))
			for(var/datum/chameleon_gloves_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, SPAN_ALERT("That appearance is already saved in the chameleon pattern banks!"))
					return

			var/datum/chameleon_gloves_pattern/P = new /datum/chameleon_gloves_pattern(src)
			P.name = U.name
			P.desc = U.desc
			P.icon_state = U.icon_state
			P.item_state = U.item_state
			P.sprite_item = U.icon
			P.sprite_worn = U.wear_image_icon
			P.sprite_hand = U.inhand_image_icon
			src.clothing_choices += P
			P.print_type = U.material_prints

			boutput(user, SPAN_NOTICE("[U.name]'s appearance has been copied!"))

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, SPAN_ALERT("<B>Your chameleon gloves malfunction!</B>"))
			src.name = "gloves"
			src.desc = "A pair of gloves. Something seems off about them..."
			src.icon_state = "psyche"
			src.item_state = "psyche"
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			src.material_prints = "high-tech rainbow flashing nanofibers"
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Gloves."
		set category = "Local"
		set src in usr

		var/datum/chameleon_shoes_pattern/which = tgui_input_list(usr, "Change the shoes to which pattern?", "Chameleon Gloves", clothing_choices)

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_gloves_pattern/T)
		if (T)
			src.current_choice = T
			src.name = T.name
			src.desc = T.desc
			src.icon_state = T.icon_state
			src.item_state = T.item_state
			src.icon = T.sprite_item
			src.wear_image_icon = T.sprite_worn
			src.inhand_image_icon = T.sprite_hand
			src.wear_image = image(wear_image_icon)
			src.inhand_image = image(inhand_image_icon)
			src.material_prints = T.print_type
			src.fingertip_color = T.fingertip_color
			src.tooltip_rebuild = TRUE
			usr.set_clothing_icon_dirty()

/datum/chameleon_gloves_pattern
	var/name = "black gloves"
	var/desc = "These thick leather gloves are fire-resistant."
	var/icon_state = "black"
	var/item_state = "bgloves"
	var/sprite_item = 'icons/obj/clothing/item_gloves.dmi'
	var/sprite_worn = 'icons/mob/clothing/hands.dmi'
	var/sprite_hand = 'icons/mob/inhand/hand_feethand.dmi'
	var/print_type = "black leather fibers"
	var/hide_prints = TRUE
	var/scramble_prints = FALSE
	var/fingertip_color = null

	insulated
		desc = "Tough rubber work gloves styled in a high-visibility yellow color. They are electrically insulated, and provide full protection against most shocks."
		name = "insulated gloves"
		icon_state = "yellow"
		item_state = "ygloves"
		print_type = "insulative fibers"
		hide_prints = TRUE
		scramble_prints = FALSE
		fingertip_color = "#ffff33"

	fingerless
		desc = "These gloves lack fingers. Good for a space biker look, but not so good for concealing your fingerprints."
		name = "fingerless gloves"
		icon_state = "fgloves"
		item_state = "finger-"
		hide_prints = FALSE
		scramble_prints = FALSE
		fingertip_color = null

	latex
		name = "latex gloves"
		icon_state = "latex"
		item_state = "lgloves"
		desc = "Thin, disposal medical gloves used to help prevent the spread of germs."
		scramble_prints = TRUE
		fingertip_color = "#f3f3f3"

	boxing
		name = "boxing gloves"
		desc = "Big soft gloves used in competitive boxing. Gives your punches a bit more weight, at the cost of precision."
		icon_state = "boxinggloves"
		item_state = "bogloves"
		print_type = "red leather fibers"
		hide_prints = TRUE
		scramble_prints = FALSE
		fingertip_color = "#f80000"

	long
		desc = "These long gloves protect your sleeves and skin from whatever dirty job you may be doing."
		name = "cleaning gloves"
		icon_state = "long_gloves"
		item_state = "long_gloves"
		print_type = "synthetic silicone rubber fibers"
		hide_prints = TRUE
		scramble_prints = FALSE
		fingertip_color = "#ffff33"

	gauntlets
		name = "concussion gauntlets"
		desc = "These gloves enable miners to punch through solid rock with their hands instead of using tools."
		icon_state = "cgaunts"
		item_state = "bgloves"
		print_type = "industrial-grade mineral fibers"
		hide_prints = TRUE
		scramble_prints = FALSE
		fingertip_color = "#535353"

	caps_gloves
		name = "captain's gloves"
		desc = "A pair of formal gloves that are electrically insulated and quite heat-resistant. The high-quality materials help you in blocking attacks."
		icon_state = "capgloves"
		item_state = "capgloves"
		print_type = "high-quality synthetic fibers"
		hide_prints = TRUE
		scramble_prints = FALSE
		fingertip_color = "#3fb54f"

/obj/item/storage/belt/chameleon
	name = "utility belt"
	desc = "Can hold various small objects."
	icon_state = "utilitybelt"
	item_state = "utility"
	icon = 'icons/obj/items/belts.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	wear_image_icon = 'icons/mob/clothing/belt.dmi'
	var/list/clothing_choices = list()
	var/current_choice = new/datum/chameleon_belt_pattern

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_belt_pattern)))
			var/datum/chameleon_belt_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/storage/belt/U, mob/user)
		..()
		if(istype(U, /obj/item/storage/belt/chameleon))
			boutput(user, SPAN_ALERT("No!!! That's a terrible idea! You'll cause a putrid belt spiral!"))
			SPAWN(1 SECOND)
				boutput(user, SPAN_ALERT("Nah, just jesting. Doing that still doesn't work though!"))
			return

		if(istype(U, /obj/item/storage/belt))
			for(var/datum/chameleon_belt_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, SPAN_ALERT("That appearance is already saved in the chameleon pattern banks!"))
					return

			var/datum/chameleon_belt_pattern/P = new /datum/chameleon_belt_pattern(src)
			P.name = U.name
			P.desc = U.desc
			P.icon_state = U.icon_state
			P.item_state = U.item_state
			P.sprite_item = U.icon
			P.sprite_worn = U.wear_image_icon
			P.sprite_hand = U.inhand_image_icon
			src.clothing_choices += P

			boutput(user, SPAN_NOTICE("[U.name]'s appearance has been copied!"))

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, SPAN_ALERT("<B>Your chameleon belt malfunctions!</B>"))
			src.name = "belt"
			src.desc = "A flashing belt. Looks like you can still put things in it, though."
			src.icon_state = "psyche"
			src.item_state = "psyche"
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Belt."
		set category = "Local"
		set src in usr

		var/datum/chameleon_belt_pattern/which = tgui_input_list(usr, "Change the belt to which pattern?", "Chameleon Belt", clothing_choices)

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_belt_pattern/T)
		if (T)
			src.current_choice = T
			src.name = T.name
			src.desc = T.desc
			src.icon_state = T.icon_state
			src.item_state = T.item_state
			src.icon = T.sprite_item
			src.wear_image_icon = T.sprite_worn
			src.inhand_image_icon = T.sprite_hand
			src.wear_image = image(wear_image_icon)
			src.inhand_image = image(inhand_image_icon)
			src.tooltip_rebuild = TRUE
			usr.set_clothing_icon_dirty()

/datum/chameleon_belt_pattern
	var/name = "utility belt"
	var/desc = "Can hold various small objects."
	var/icon_state = "utilitybelt"
	var/item_state = "utility"
	var/sprite_item = 'icons/obj/items/belts.dmi'
	var/sprite_worn = 'icons/mob/clothing/belt.dmi'
	var/sprite_hand = 'icons/mob/inhand/hand_storage.dmi'

	ceshielded
		name = "aurora MKII utility belt"
		desc = "An utility belt for usage in high-risk salvage operations. Contains a personal shield generator. Can be activated to overcharge the shields temporarily."
		icon_state = "cebelt"
		item_state = "cebelt"

	security
		name = "security toolbelt"
		desc = "For the trend-setting officer on the go. Has a place on it to clip a baton and a holster for a small gun."
		icon_state = "secbelt"
		item_state = "secbelt"

	medical
		name = "medical belt"
		desc = "A specialized belt for treating patients outside medbay in the field. A unique attachment point lets you carry defibrillators."
		icon_state = "injectorbelt"
		item_state = "medical"

	shoulder_holster
		name = "shoulder holster"
		icon_state = "shoulder_holster"
		item_state = "shoulder_holster"

	miner
		name = "miner's belt"
		desc = "Can hold various mining tools."
		icon_state = "minerbelt"
		item_state = "mining"

	robotics
		name = "Roboticist's belt"
		desc = "A utility belt, in the departmental colors of someone who loves robots and surgery."
		icon_state = "utilrobotics"
		item_state = "robotics"

	rancher
		name = "rancher's belt"
		desc = "A sturdy belt with hooks for chicken carriers."
		icon_state = "rancherbelt"
		item_state = "rancher"

/obj/item/storage/backpack/chameleon
	name = "backpack"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's back."
	icon_state = "backpack"
	item_state = "backpack"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	var/list/clothing_choices = list()
	var/current_choice = new/datum/chameleon_backpack_pattern
	spawn_contents = list()
	check_wclass = TRUE
	can_hold = list(/obj/item/storage/belt/chameleon)
	satchel_variant = null //Set and then unset in convert_to_satchel, but should remain null as we don't know what we're disguised as.

	New()
		..()
		var/obj/item/remote/chameleon/remote = new /obj/item/remote/chameleon(src.loc)
		remote.connected_backpack = src

		var/obj/item/clothing/under/chameleon/jumpsuit = new /obj/item/clothing/under/chameleon(src)
		src.storage.add_contents(jumpsuit)
		remote.connected_jumpsuit = jumpsuit

		var/obj/item/clothing/head/chameleon/hat = new /obj/item/clothing/head/chameleon(src)
		src.storage.add_contents(hat)
		remote.connected_hat = hat

		var/obj/item/clothing/suit/chameleon/suit = new /obj/item/clothing/suit/chameleon(src)
		src.storage.add_contents(suit)
		remote.connected_suit = suit

		var/obj/item/clothing/glasses/chameleon/glasses = new /obj/item/clothing/glasses/chameleon(src)
		src.storage.add_contents(glasses)
		remote.connected_glasses = glasses

		var/obj/item/clothing/shoes/chameleon/shoes = new /obj/item/clothing/shoes/chameleon(src)
		src.storage.add_contents(shoes)
		remote.connected_shoes = shoes

		var/obj/item/storage/belt/chameleon/belt = new /obj/item/storage/belt/chameleon(src)
		src.storage.add_contents(belt)
		remote.connected_belt = belt

		var/obj/item/clothing/gloves/chameleon/gloves = new /obj/item/clothing/gloves/chameleon(src)
		src.storage.add_contents(gloves)
		remote.connected_gloves = gloves

		for(var/U in (typesof(/datum/chameleon_backpack_pattern)))
			var/datum/chameleon_backpack_pattern/P = new U
			src.clothing_choices += P

	attackby(obj/item/storage/backpack/U, mob/user)
		..()
		if(istype(U, /obj/item/storage/backpack/chameleon))
			boutput(user, SPAN_ALERT("No!!! That's a terrible idea! You'll cause a stinky backpack self-cloning freak accident!"))
			SPAWN(1 SECOND)
				boutput(user, SPAN_ALERT("Nah, just kidding. Doing that still doesn't work though!"))
			return

		if(istype(U, /obj/item/storage/backpack))
			for(var/datum/chameleon_backpack_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, SPAN_ALERT("That appearance is already saved in the chameleon pattern banks!"))
					return

			var/datum/chameleon_backpack_pattern/P = new /datum/chameleon_backpack_pattern(src)
			P.name = U.name
			P.desc = U.desc
			P.icon_state = U.icon_state
			P.item_state = U.item_state
			P.sprite_item = U.icon
			P.sprite_worn = U.wear_image_icon
			P.sprite_hand = U.inhand_image_icon
			src.clothing_choices += P

			boutput(user, SPAN_NOTICE("[U.name]'s appearance has been copied!"))

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, SPAN_ALERT("<B>Your chameleon backpack malfunctions!</B>"))
			src.name = "backpack"
			src.desc = "A flashing backpack. Looks like you can still put things in it, though."
			src.icon_state = "psyche_backpack"
			src.item_state = "psyche_backpack"
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			M.set_clothing_icon_dirty()

	//Needs special casing to first figure out which bag we're disguised as, then call parent when we've figured out which satchel we need to be
	convert_to_satchel(name_base_item)
		var/list/bag_types = concrete_typesof(/obj/item/storage/backpack)
		for (var/obj/item/storage/backpack/bag as anything in bag_types)
			if((bag::icon_state == src.icon_state) && (bag::icon == src.icon))
				src.satchel_variant = bag::satchel_variant
		. = ..(name_base_item)
		//Make sure to add the new satchel disguise to our list if it isn't already there
		for(var/datum/chameleon_backpack_pattern/check_pattern in src.clothing_choices)
			if(check_pattern.name == src.name)
				return .
		var/datum/chameleon_backpack_pattern/P = new /datum/chameleon_backpack_pattern(src)
		P.name = src.name
		P.desc = src.desc
		P.icon_state = src.icon_state
		P.item_state = src.item_state
		P.sprite_item = src.icon
		P.sprite_worn = src.wear_image_icon
		P.sprite_hand = src.inhand_image_icon
		src.clothing_choices += P

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Backpack."
		set category = "Local"
		set src in usr

		var/datum/chameleon_backpack_pattern/which = tgui_input_list(usr, "Change the backpack to which pattern?", "Chameleon Backpack", clothing_choices)

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_backpack_pattern/T)
		if (T)
			src.current_choice = T
			src.name = T.name
			src.desc = T.desc
			src.icon_state = T.icon_state
			src.item_state = T.item_state
			src.icon = T.sprite_item
			src.wear_image_icon = T.sprite_worn
			src.inhand_image_icon = T.sprite_hand
			src.wear_image = image(wear_image_icon)
			src.inhand_image = image(inhand_image_icon)
			src.tooltip_rebuild = TRUE
			usr.set_clothing_icon_dirty()

/datum/chameleon_backpack_pattern
	var/name = "backpack"
	var/desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's back."
	var/icon_state = "backpack"
	var/item_state = "backpack"
	var/sprite_item = 'icons/obj/items/storage.dmi'
	var/sprite_worn =  'icons/mob/clothing/back.dmi'
	var/sprite_hand = 'icons/mob/inhand/hand_storage.dmi'

	satchel
		name = "satchel"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's shoulder."
		icon_state = "satchel"
		item_state = "satchel"

	engineer
		name = "engineering backpack"
		desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects effectively on the back of engineering personnel."
		icon_state = "bp_engineering"
		item_state = "bp_engineering"

	engineer_satchel
		name = "engineering satchel"
		desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects effectively on the shoulder of engineering personnel."
		icon_state = "satchel_engineering"
		item_state = "satchel_engineering"

	research
		name = "research backpack"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects efficiently on the back of research personnel."
		icon_state = "bp_research"
		item_state = "bp_research"

	research_satchel
		name = "research satchel"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects efficiently on the shoulder of research personnel."
		icon_state = "satchel_research"
		item_state = "satchel_research"

	security
		name = "security backpack"
		desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects adequately on the back of security personnel."
		icon_state = "bp_security"
		item_state = "bp_security"

	security_satchel
		name = "security satchel"
		desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects stylishly on the shoulder of security personnel."
		icon_state = "satchel_security"
		item_state = "satchel_security"

	robotics
		name = "robotics backpack"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects monochromaticly on the back of roboticists."
		icon_state = "bp_robotics"
		item_state = "bp_robotics"

	robotics_satchel
		name = "robotics satchel"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects monochromaticly on the shoulder of roboticists."
		icon_state = "satchel_robotics"
		item_state = "satchel_robotics"

	genetics
		name = "genetics backpack"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects safely on the back of geneticists."
		icon_state = "bp_genetics"
		item_state = "bp_genetics"

	genetics_satchel
		name = "genetics satchel"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects safely on the shoulder of geneticists."
		icon_state = "satchel_genetics"
		item_state = "satchel_genetics"

	medic
		name = "medic's backpack"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a Medical Doctor's back."
		icon_state = "bp_medic"
		item_state = "bp-medic"

	medic_satchel
		name = "medic's satchel"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a Medical Doctor's shoulder."
		icon_state = "satchel_medic"
		item_state = "satchel_medic"

	captain
		name = "Captain's Backpack"
		desc = "A fancy designer bag made out of space snake leather and encrusted with plastic expertly made to look like gold."
		icon_state = "capbackpack"
		item_state = "capbackpack"

	captain_satchel
		name = "Captain's Satchel"
		desc = "A fancy designer bag made out of space snake leather and encrusted with plastic expertly made to look like gold."
		icon_state = "capsatchel"
		item_state = "capsatchel"

/obj/item/remote/chameleon
	name = "chameleon outfit remote"
	desc = "A remote control that allows you to change an entire set of chameleon clothes, all at once."
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote"
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	HELP_MESSAGE_OVERRIDE({"Use the remote in hand to change the appearance of all chameleon clothing.
							Right click on a piece of chameleon clothing and use <b>"Change appearance"</b> to change the appearance of that specific piece.
							Use a piece of clothing on the corresponding chameleon clothing piece to add that appearance to the list of possible appearances.
							Use the remote in hand and select the <b>"New Outfit Set"</b> option to create a new set of clothing."})

	var/obj/item/storage/backpack/chameleon/connected_backpack = null
	var/obj/item/clothing/under/chameleon/connected_jumpsuit = null
	var/obj/item/clothing/head/chameleon/connected_hat = null
	var/obj/item/clothing/suit/chameleon/connected_suit = null
	var/obj/item/clothing/glasses/chameleon/connected_glasses = null
	var/obj/item/clothing/shoes/chameleon/connected_shoes = null
	var/obj/item/storage/belt/chameleon/connected_belt = null
	var/obj/item/clothing/gloves/chameleon/connected_gloves = null
	var/list/outfit_choices = list()

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_outfit_choices)))
			var/datum/chameleon_outfit_choices/P = new U
			src.outfit_choices += P
		return

	attack_self(mob/user)
		if (isliving(user))
			var/datum/chameleon_outfit_choices/which = tgui_input_list(user, "Change the chameleon outfit to which set?", "Chameleon Outfit Remote", outfit_choices)

			if(!which)
				return

			if (which.function == "delete_outfit")
				var/datum/chameleon_outfit_choices/outfit_to_delete = tgui_input_list(user, "Delete which chameleon outfit set?", "Chameleon Outfit Remote", outfit_choices)

				if(!outfit_to_delete)
					return
				if(outfit_to_delete.function)
					boutput(user, SPAN_ALERT("The chameleon outfit prevents you from deleting this function!"))
					return

				src.outfit_choices -= outfit_to_delete

				boutput(user, SPAN_NOTICE("Outfit set deleted!"))
				return

			if(which.function == "new_outfit")
				var/name = tgui_input_text(user, "Name of new outfit set:", "Chameleon Outfit Remote")
				if(!name)
					return
				for(var/datum/chameleon_outfit_choices/P in src.outfit_choices)
					if(P.name == name)
						boutput(user, SPAN_ALERT("That outfit set name is already saved in the chameleon outfit banks!"))
						return

				var/datum/chameleon_outfit_choices/P = new /datum/chameleon_outfit_choices(src)
				P.name = name
				if(connected_jumpsuit)
					P.jumpsuit_type = connected_jumpsuit.current_choice
				if(connected_hat)
					P.hat_type = connected_hat.current_choice
				if(connected_suit)
					P.suit_type = connected_suit.current_choice
				if(connected_glasses)
					P.glasses_type = connected_glasses.current_choice
				if(connected_shoes)
					P.shoes_type = connected_shoes.current_choice
				if(connected_gloves)
					P.gloves_type = connected_gloves.current_choice
				if(connected_belt)
					P.belt_type = connected_belt.current_choice
				if(connected_backpack)
					P.backpack_type = connected_backpack.current_choice
				src.outfit_choices += P

				boutput(user, SPAN_NOTICE("New outfit set created!"))
				return

			if(connected_jumpsuit || which.jumpsuit_type)
				connected_jumpsuit.change_outfit(which.jumpsuit_type)

			if(connected_hat || which.hat_type)
				connected_hat.change_outfit(which.hat_type)

			if(connected_suit || which.suit_type)
				connected_suit.change_outfit(which.suit_type)

			if(connected_glasses || which.glasses_type)
				connected_glasses.change_outfit(which.glasses_type)

			if(connected_shoes || which.shoes_type)
				connected_shoes.change_outfit(which.shoes_type)

			if(connected_gloves || which.gloves_type)
				connected_gloves.change_outfit(which.gloves_type)

			if(connected_belt || which.belt_type)
				connected_belt.change_outfit(which.belt_type)

			if(connected_backpack || which.backpack_type)
				connected_backpack.change_outfit(which.backpack_type)

/datum/chameleon_outfit_choices
	var/function = null
	var/name = "Staff Assistant"
	var/jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank
	var/hat_type = new/datum/chameleon_hat_pattern/
	var/suit_type = new/datum/chameleon_suit_pattern/hoodie
	var/glasses_type = new/datum/chameleon_glasses_pattern
	var/shoes_type = new/datum/chameleon_shoes_pattern
	var/gloves_type = null
	var/belt_type = new/datum/chameleon_belt_pattern
	var/backpack_type = new/datum/chameleon_backpack_pattern

	captain
		name = "Captain"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/captain
		hat_type = new/datum/chameleon_hat_pattern/caphat
		suit_type = new/datum/chameleon_suit_pattern/captain_armor
		glasses_type = new/datum/chameleon_glasses_pattern/sunglasses
		shoes_type = new/datum/chameleon_shoes_pattern/caps_boots
		gloves_type = new/datum/chameleon_gloves_pattern/caps_gloves
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern/captain

	head_of_security
		name = "Head Of Security"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/head_of_securityold
		hat_type = new/datum/chameleon_hat_pattern/HoS_beret
		suit_type = new/datum/chameleon_suit_pattern/hos_jacket
		glasses_type = new/datum/chameleon_glasses_pattern/sechud
		shoes_type = new/datum/chameleon_shoes_pattern/swat
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern/security
		backpack_type = new/datum/chameleon_backpack_pattern/security

	head_of_personnel
		name = "Head of Personnel"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/head_of_personnel
		hat_type = new/datum/chameleon_hat_pattern/fancy
		suit_type = new/datum/chameleon_suit_pattern/winter_coat_command
		glasses_type = new/datum/chameleon_glasses_pattern
		shoes_type = new/datum/chameleon_shoes_pattern/brown
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	chief_engineer
		name = "Chief Engineer"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/chief_engineer
		hat_type = new/datum/chameleon_hat_pattern/hardhat_CE
		suit_type = new/datum/chameleon_suit_pattern/winter_coat_command
		glasses_type = new/datum/chameleon_glasses_pattern/meson
		shoes_type = new/datum/chameleon_shoes_pattern/brown
		gloves_type = new/datum/chameleon_gloves_pattern/insulated
		belt_type = new/datum/chameleon_belt_pattern/ceshielded
		backpack_type = new/datum/chameleon_backpack_pattern/engineer

	medical_director
		name = "Medical Director"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/medical_director
		hat_type = new/datum/chameleon_hat_pattern/fancy
		suit_type = new/datum/chameleon_suit_pattern/labcoat_MD
		glasses_type = new/datum/chameleon_glasses_pattern/prodoc
		shoes_type = new/datum/chameleon_shoes_pattern
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern/medical
		backpack_type = new/datum/chameleon_backpack_pattern

	research_director
		name = "Research Director"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/research_director
		hat_type = new/datum/chameleon_hat_pattern/fancy
		suit_type = new/datum/chameleon_suit_pattern/labcoat_RD
		glasses_type = new/datum/chameleon_glasses_pattern/spectro
		shoes_type = new/datum/chameleon_shoes_pattern/brown
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	security_officer
		name = "Security Officer"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/security
		hat_type = new/datum/chameleon_hat_pattern/security
		suit_type = new/datum/chameleon_suit_pattern/armor_vest
		glasses_type = new/datum/chameleon_glasses_pattern/sechud
		shoes_type = new/datum/chameleon_shoes_pattern/swat
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern/security
		backpack_type = new/datum/chameleon_backpack_pattern/security

	detective
		name = "Detective"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/det
		hat_type = new/datum/chameleon_hat_pattern/detective
		suit_type = new/datum/chameleon_suit_pattern/detective_jacket
		glasses_type = new/datum/chameleon_glasses_pattern/thermal
		shoes_type = new/datum/chameleon_shoes_pattern/detective
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern/shoulder_holster
		backpack_type = new/datum/chameleon_backpack_pattern

	security_assistant
		name = "Security Assistant"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/security_assistant
		hat_type = new/datum/chameleon_hat_pattern
		suit_type = new/datum/chameleon_suit_pattern/badge
		glasses_type = new/datum/chameleon_glasses_pattern/sechud
		shoes_type = new/datum/chameleon_shoes_pattern/brown
		gloves_type = new/datum/chameleon_gloves_pattern/fingerless
		belt_type = new/datum/chameleon_belt_pattern/security
		backpack_type = new/datum/chameleon_backpack_pattern/security

	scientist
		name = "Scientist"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/scientist
		hat_type = new/datum/chameleon_hat_pattern
		suit_type = new/datum/chameleon_suit_pattern/labcoat_science
		glasses_type = new/datum/chameleon_glasses_pattern/spectro
		shoes_type = new/datum/chameleon_shoes_pattern/white
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern/research

	medical_doctor
		name = "Medical Doctor"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/medical
		hat_type = new/datum/chameleon_hat_pattern
		suit_type = new/datum/chameleon_suit_pattern/labcoat_medical
		glasses_type = new/datum/chameleon_glasses_pattern/prodoc
		shoes_type = new/datum/chameleon_shoes_pattern/red
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern/medical
		backpack_type = new/datum/chameleon_backpack_pattern/medic

	roboticist
		name = "Roboticist"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/roboticist
		hat_type = new/datum/chameleon_hat_pattern
		suit_type = new/datum/chameleon_suit_pattern/labcoat_robotics
		glasses_type = new/datum/chameleon_glasses_pattern/prodoc
		shoes_type = new/datum/chameleon_shoes_pattern
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern/robotics
		backpack_type = new/datum/chameleon_backpack_pattern/robotics

	geneticist
		name = "Geneticist"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/geneticist
		hat_type = new/datum/chameleon_hat_pattern
		suit_type = new/datum/chameleon_suit_pattern/labcoat_genetics
		glasses_type = new/datum/chameleon_glasses_pattern/prodoc
		shoes_type = new/datum/chameleon_shoes_pattern/white
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern/medical
		backpack_type = new/datum/chameleon_backpack_pattern/genetics

	quartermaster
		name = "Quartermaster"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/cargo
		hat_type = new/datum/chameleon_hat_pattern
		suit_type = new/datum/chameleon_suit_pattern/winter_coat_engineering
		glasses_type = new/datum/chameleon_glasses_pattern
		shoes_type = new/datum/chameleon_shoes_pattern
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	engineer
		name = "Engineer"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/engineer
		hat_type = new/datum/chameleon_hat_pattern/hardhat
		suit_type = new/datum/chameleon_suit_pattern/winter_coat_engineering
		glasses_type = new/datum/chameleon_glasses_pattern/meson
		shoes_type = new/datum/chameleon_shoes_pattern/orange
		gloves_type = new/datum/chameleon_gloves_pattern/insulated
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern/engineer

	miner
		name = "Miner"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/overalls
		hat_type = new/datum/chameleon_hat_pattern/space_helmet_engineer
		suit_type = new/datum/chameleon_suit_pattern/space_suit_engineering
		glasses_type = new/datum/chameleon_glasses_pattern/meson
		shoes_type = new/datum/chameleon_shoes_pattern/orange
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern/miner
		backpack_type = new/datum/chameleon_backpack_pattern/engineer

	rancher
		name = "Rancher"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/rancher
		hat_type = new/datum/chameleon_hat_pattern/cowboy_hat
		suit_type = new/datum/chameleon_suit_pattern/botanist_apron
		glasses_type = new/datum/chameleon_glasses_pattern
		shoes_type = new/datum/chameleon_shoes_pattern/brown
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern/rancher
		backpack_type = new/datum/chameleon_backpack_pattern

	botanist
		name = "Botanist"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/hydroponics
		hat_type = new/datum/chameleon_hat_pattern/cowboy_hat
		suit_type = new/datum/chameleon_suit_pattern/botanist_apron
		glasses_type = new/datum/chameleon_glasses_pattern/sunglasses
		shoes_type = new/datum/chameleon_shoes_pattern/brown
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	janitor
		name = "Janitor"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/janitor
		hat_type = new/datum/chameleon_hat_pattern/janiberet
		suit_type = new/datum/chameleon_suit_pattern/bio_suit
		glasses_type = new/datum/chameleon_glasses_pattern
		shoes_type = new/datum/chameleon_shoes_pattern/galoshes
		gloves_type = new/datum/chameleon_gloves_pattern/long
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	chaplain
		name = "Chaplain"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/chaplain
		hat_type = new/datum/chameleon_hat_pattern/turban
		suit_type = new/datum/chameleon_suit_pattern/adeptus
		glasses_type = new/datum/chameleon_glasses_pattern
		shoes_type = new/datum/chameleon_shoes_pattern/magic_sandals
		gloves_type = new/datum/chameleon_gloves_pattern
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	bartender
		name = "Bartender"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/bartender
		hat_type = new/datum/chameleon_hat_pattern/top_hat
		suit_type = new/datum/chameleon_suit_pattern/armor_vest
		glasses_type = new/datum/chameleon_glasses_pattern/spectro
		shoes_type = new/datum/chameleon_shoes_pattern
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	chef
		name = "Chef"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/chef
		hat_type = new/datum/chameleon_hat_pattern/chef_hat
		suit_type = new/datum/chameleon_suit_pattern/chef_coat
		glasses_type = new/datum/chameleon_glasses_pattern
		shoes_type = new/datum/chameleon_shoes_pattern/chef
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	mail_courier //did you know you can go to jail for up to 3 years for impersonating a US mail carrier
		name = "Mail Courier"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/courier
		hat_type = new/datum/chameleon_hat_pattern/postal_cap
		suit_type = new/datum/chameleon_suit_pattern/hoodie
		glasses_type = new/datum/chameleon_glasses_pattern
		shoes_type = new/datum/chameleon_shoes_pattern/brown
		gloves_type = new/datum/chameleon_gloves_pattern/latex
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern/satchel

	new_outfit
		function = "new_outfit"
		name = "New Outfit Set"

	delete_outfit
		function = "delete_outfit"
		name = "Delete Outfit Set"
