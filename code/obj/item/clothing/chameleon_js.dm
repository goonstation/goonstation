/obj/item/clothing/under/chameleon
	name = "black jumpsuit"
	desc = "A generic jumpsuit with no rank markings."
	icon = 'icons/obj/clothing/uniforms/item_js.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js.dmi'
	inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js.dmi'
	icon_state = "black"
	uses_multiple_icon_states = 1
	item_state = "black"
	permeability_coefficient = 0.50
	var/list/clothing_choices = list()

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_jumpsuit_pattern)))
			var/datum/chameleon_jumpsuit_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/clothing/under/U as obj, mob/user as mob)
		if(istype(U, /obj/item/clothing/under/chameleon))
			boutput(user, "<span class='alert'>No!!! That's a terrible idea! You'll cause a horrible jumpsuit chain reaction!</span>")
			SPAWN_DBG(1 SECOND)
				boutput(user, "<span class='alert'>Nah, just kidding. Doing that still doesn't work though!</span>")
			return

		if(istype(U, /obj/item/clothing/under))
			for(var/datum/chameleon_jumpsuit_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, "<span class='alert'>That appearance is already saved in the chameleon pattern banks!</span>")
					return

			var/datum/chameleon_jumpsuit_pattern/P = new /datum/chameleon_jumpsuit_pattern(src)
			P.name = U.name
			P.desc = U.desc
			P.icon_state = U.icon_state
			P.item_state = U.item_state
			P.sprite_item = U.icon
			P.sprite_worn = U.wear_image_icon
			P.sprite_hand = U.inhand_image_icon
			src.clothing_choices += P

			boutput(user, "<span class='notice'>[U.name]'s appearance has been copied!</span>")

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, "<span class='alert'><B>Your chameleon jumpsuit malfunctions!</B></span>")
			src.name = "psychedelic jumpsuit"
			src.desc = "Groovy!"
			icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
			wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_gimmick.dmi'
			inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_gimmick.dmi'
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			src.icon_state = "psyche"
			src.item_state = "psyche"
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Jumpsuit."
		set category = "Local"
		set src in usr

		var/datum/chameleon_jumpsuit_pattern/which = input("Change the jumpsuit to which pattern?", "Chameleon Jumpsuit") as null|anything in clothing_choices

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_jumpsuit_pattern/T)
		src.name = T.name
		src.desc = T.desc
		src.icon_state = T.icon_state
		src.item_state = T.item_state
		src.icon = T.sprite_item
		src.wear_image_icon = T.sprite_worn
		src.inhand_image_icon = T.sprite_hand
		src.wear_image = image(wear_image_icon)
		src.inhand_image = image(inhand_image_icon)
		usr.set_clothing_icon_dirty()

/datum/chameleon_jumpsuit_pattern
	var/name = "black jumpsuit"
	var/desc = "A generic jumpsuit with no rank markings."
	var/icon_state = "black"
	var/item_state = "black"
	var/sprite_item = 'icons/obj/clothing/uniforms/item_js.dmi'
	var/sprite_worn = 'icons/mob/clothing/jumpsuits/worn_js.dmi'
	var/sprite_hand = 'icons/mob/inhand/jumpsuit/hand_js.dmi'

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
		sprite_item = 'icons/obj/clothing/uniforms/item_js_rank.dmi'
		sprite_worn = 'icons/mob/clothing/jumpsuits/worn_js_rank.dmi'
		sprite_hand = 'icons/mob/inhand/jumpsuit/hand_js_rank.dmi'

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

	rank/mechanic
		name = "mechanic's uniform"
		desc = "Formerly an electrician's uniform, renamed because mechanics are not electricians."
		icon_state = "mechanic"
		item_state = "mechanic"

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


/obj/item/clothing/head/chameleon
	name = "hat"
	desc = "A knit cap in black."
	icon_state = "black"
	item_state = "swat_gl"
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	icon = 'icons/obj/clothing/item_hats.dmi'
	uses_multiple_icon_states = 1
	var/list/clothing_choices = list()
	blocked_from_petasusaphilic = TRUE

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_hat_pattern)))
			var/datum/chameleon_hat_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/clothing/head/U as obj, mob/user as mob)
		if(istype(U, /obj/item/clothing/head/chameleon))
			boutput(user, "<span class='alert'>No!!! That's a terrible idea! You'll cause a cataclysmic hat infinite loop!</span>")
			SPAWN_DBG(1 SECOND)
				boutput(user, "<span class='alert'>Nah, just yankin' your chain. Doing that still doesn't work though!</span>")
			return

		if(istype(U, /obj/item/clothing/head/))
			for(var/datum/chameleon_hat_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, "<span class='alert'>That appearance is already saved in the chameleon pattern banks!</span>")
					return

			var/datum/chameleon_hat_pattern/P = new /datum/chameleon_hat_pattern(src)
			P.name = U.name
			P.desc = U.desc
			P.icon_state = U.icon_state
			P.item_state = U.item_state
			P.sprite_item = U.icon
			P.sprite_worn = U.wear_image_icon
			P.sprite_hand = U.inhand_image_icon
			src.clothing_choices += P

			boutput(user, "<span class='notice'>[U.name]'s appearance has been copied!</span>")

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, "<span class='alert'><B>Your chameleon hat malfunctions!</B></span>")
			src.name = "hat"
			src.desc = "A knit cap in...what the hell?"
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			src.icon_state = "psyche"
			src.item_state = "bgloves"
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Hat."
		set category = "Local"
		set src in usr

		var/datum/chameleon_hat_pattern/which = input("Change the hat to which pattern?", "Chameleon Hat") as null|anything in clothing_choices

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_hat_pattern/T)
		src.name = T.name
		src.desc = T.desc
		src.icon_state = T.icon_state
		src.item_state = T.item_state
		src.icon = T.sprite_item
		src.wear_image_icon = T.sprite_worn
		src.inhand_image_icon = T.sprite_hand
		src.wear_image = image(wear_image_icon)
		src.inhand_image = image(inhand_image_icon)
		usr.set_clothing_icon_dirty()

/datum/chameleon_hat_pattern
	var/name = "hat"
	var/desc = "A knit cap in black."
	var/icon_state = "black"
	var/item_state = "black"
	var/sprite_item = 'icons/obj/clothing/item_hats.dmi'
	var/sprite_worn = 'icons/mob/clothing/head.dmi'
	var/sprite_hand = 'icons/mob/inhand/hand_headgear.dmi'

	NTberet
		name = "Nanotrasen beret"
		desc = "For the inner space dictator in you."
		icon_state = "ntberet"
		item_state = "ntberet"

	HoS_beret
		name = "HoS Beret"
		icon_state = "hosberet"
		item_state = "hoberet"
		desc = "Actually, this hat is from a fast-food restaurant, that's why it folds like it was made of paper."

	HoS_hat
		name = "HoS Hat"
		icon_state = "hoscap"
		item_state = "hoscap"
		desc = "Actually, this hat is from a fast-food restaurant, that's why it folds like it was made of paper."

	caphat
		name = "Captain's hat"
		icon_state = "captain"
		item_state = "caphat"
		desc = "A symbol of the captain's rank, and the source of all their power."

	janiberet
		name = "Head of Sanitation beret"
		desc = "The Chief of Cleaning, the Superintendent of Scrubbing, whatever you call yourself, you know how to make those tiles shine. Good job."
		icon_state = "janitorberet"
		item_state = "janitorberet"

	janihat
		name = "Head of Sanitation hat"
		desc = "The Chief of Cleaning, the Superintendent of Scrubbing, whatever you call yourself, you know how to make those tiles shine. Good job."
		icon_state = "janitorhat"
		item_state = "janitorhat"

	hardhat
		name = "hard hat"
		icon_state = "hardhat0"
		item_state = "hardhat0"
		desc = "Protects your head from falling objects, and comes with a flashlight. Safety first!"

	security
		name = "helmet"
		icon_state = "helmet-sec"
		item_state = "helmet"
		desc = "Somewhat protects your head from being bashed in."

	fancy
		name = "fancy hat"
		icon_state = "rank-fancy"
		item_state = "that"
		desc = "What do you mean this is hat isn't fancy?"

	detective
		name = "Detective's hat"
		desc = "Someone who wears this will look very smart."
		icon_state = "detective"
		item_state = "det_hat"

/obj/item/clothing/suit/chameleon
	name = "hoodie"
	desc = "Nice and comfy on those cold space evenings."
	icon_state = "hoodie"
	item_state = "hoodie"
	icon = 'icons/obj/clothing/overcoats/item_suit.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit.dmi'
	uses_multiple_icon_states = 1
	var/list/clothing_choices = list()

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_suit_pattern)))
			var/datum/chameleon_suit_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/clothing/suit/U as obj, mob/user as mob)
		if(istype(U, /obj/item/clothing/suit/chameleon))
			boutput(user, "<span class='alert'>No!!! That's a terrible idea! You'll cause a horrible outer suit meltdown death loop!</span>")
			SPAWN_DBG(1 SECOND)
				boutput(user, "<span class='alert'>Nah, just making fun. Doing that still doesn't work though!</span>")
			return

		if(istype(U, /obj/item/clothing/suit))
			for(var/datum/chameleon_suit_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, "<span class='alert'>That appearance is already saved in the chameleon pattern banks!</span>")
					return

			var/datum/chameleon_suit_pattern/P = new /datum/chameleon_suit_pattern(src)
			P.name = U.name
			P.desc = U.desc
			P.icon_state = U.icon_state
			P.item_state = U.item_state
			P.sprite_item = U.icon
			P.sprite_worn = U.wear_image_icon
			P.sprite_hand = U.inhand_image_icon
			src.clothing_choices += P

			boutput(user, "<span class='notice'>[U.name]'s appearance has been copied!</span>")

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, "<span class='alert'><B>Your chameleon suit malfunctions!</B></span>")
			src.name = "hoodie"
			src.desc = "A comfy jacket that's hard on the eyes."
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			src.icon_state = "hoodie-psyche"
			src.item_state = "hoodie-psyche"
			src.icon = 'icons/obj/clothing/overcoats/item_suit.dmi'
			src.wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit.dmi'
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Suit."
		set category = "Local"
		set src in usr

		var/datum/chameleon_suit_pattern/which = input("Change the suit to which pattern?", "Chameleon Suit") as null|anything in clothing_choices

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_suit_pattern/T)
		src.name = T.name
		src.desc = T.desc
		src.icon_state = T.icon_state
		src.item_state = T.item_state
		src.icon = T.sprite_item
		src.wear_image_icon = T.sprite_worn
		src.inhand_image_icon = T.sprite_hand
		src.wear_image = image(wear_image_icon)
		src.inhand_image = image(inhand_image_icon)
		usr.set_clothing_icon_dirty()

/datum/chameleon_suit_pattern
	var/name = "hoodie"
	var/desc = "Nice and comfy on those cold space evenings."
	var/icon_state = "hoodie"
	var/item_state = "hoodie"
	var/sprite_item = 'icons/obj/clothing/overcoats/item_suit.dmi'
	var/sprite_worn = 'icons/mob/clothing/overcoats/worn_suit.dmi'
	var/sprite_hand = 'icons/mob/inhand/overcoat/hand_suit.dmi'

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

	labcoat_sciene
		name = "scientist's labcoat"
		desc = "A protective laboratory coat with the purple markings of a Scientist."
		icon_state = "SCIlabcoat"
		item_state = "SCIlabcoat"

	bio_suit
		name = "bio suit"
		desc = "A suit that protects against biological contamination."
		icon_state = "bio_suit"
		item_state = "bio_suit"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'

	paramedic
		name = "paramedic suit"
		desc = "A protective padded suit for emergency response personnel. Offers limited thermal and biological protection."
		icon_state = "paramedic"
		item_state = "paramedic"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'

	fire_suit
		name = "firesuit"
		desc = "A suit that protects against fire and heat."
		icon_state = "fire"
		item_state = "fire_suit"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_hazard.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_hazard.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_hazard.dmi'

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

	hos_cape
		name = "Head of Security's cape"
		desc = "A lightly-armored and stylish cape, made of heat-resistant materials. It probably won't keep you warm, but it would make a great security blanket!"
		icon_state = "hos-cape"
		item_state = "hos-cape"
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_armor.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_armor.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_armor.dmi'

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
		sprite_item = 'icons/obj/clothing/overcoats/item_suit_armor.dmi'
		sprite_worn = 'icons/mob/clothing/overcoats/worn_suit_armor.dmi'
		sprite_hand = 'icons/mob/inhand/overcoat/hand_suit_armor.dmi'

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

/obj/item/clothing/glasses/chameleon
	name = "prescription glasses"
	desc = "Corrective lenses, perfect for the near-sighted."
	icon_state = "glasses"
	item_state = "glasses"
	icon = 'icons/obj/clothing/item_glasses.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	wear_image_icon = 'icons/mob/clothing/eyes.dmi'
	uses_multiple_icon_states = 1
	var/list/clothing_choices = list()

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_glasses_pattern)))
			var/datum/chameleon_glasses_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/clothing/glasses/U as obj, mob/user as mob)
		if(istype(U, /obj/item/clothing/glasses/chameleon))
			boutput(user, "<span class='alert'>No!!! That's a horrible idea! You'll cause a horrible eyewear cascade!</span>")
			SPAWN_DBG(1 SECOND)
				boutput(user, "<span class='alert'>Nah, just pulling your leg. Doing that still doesn't work though!</span>")
			return

		if(istype(U, /obj/item/clothing/glasses/))
			for(var/datum/chameleon_glasses_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, "<span class='alert'>That appearance is already saved in the chameleon pattern banks!</span>")
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

			boutput(user, "<span class='notice'>[U.name]'s appearance has been copied!</span>")

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, "<span class='alert'><B>Your chameleon glasses malfunction!</B></span>")
			src.name = "glasses"
			src.desc = "A pair of glasses. They seem to be broken, though."
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			src.icon_state = "psyche"
			src.item_state = "psyche"
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Glasses."
		set category = "Local"
		set src in usr

		var/datum/chameleon_glasses_pattern/which = input("Change the glasses to which pattern?", "Chameleon Glasses") as null|anything in clothing_choices

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_glasses_pattern/T)
		src.name = T.name
		src.desc = T.desc
		src.icon_state = T.icon_state
		src.item_state = T.item_state
		src.icon = T.sprite_item
		src.wear_image_icon = T.sprite_worn
		src.inhand_image_icon = T.sprite_hand
		src.wear_image = image(wear_image_icon)
		src.inhand_image = image(inhand_image_icon)
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
	uses_multiple_icon_states = 1
	var/list/clothing_choices = list()

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_shoes_pattern)))
			var/datum/chameleon_shoes_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/clothing/shoes/U as obj, mob/user as mob)
		if(istype(U, /obj/item/clothing/shoes/chameleon))
			boutput(user, "<span class='alert'>No!!! That's a terrible idea! You'll cause a bad shoe feedback cycle!</span>")
			SPAWN_DBG(1 SECOND)
				boutput(user, "<span class='alert'>Nah, just joking. Doing that still doesn't work though!</span>")
			return

		if(istype(U, /obj/item/clothing/shoes))
			for(var/datum/chameleon_shoes_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, "<span class='alert'>That appearance is already saved in the chameleon pattern banks!</span>")
					return

			var/datum/chameleon_shoes_pattern/P = new /datum/chameleon_shoes_pattern(src)
			P.name = U.name
			P.desc = U.desc
			P.icon_state = U.icon_state
			P.item_state = U.item_state
			P.sprite_item = U.icon
			P.sprite_worn = U.wear_image_icon
			P.sprite_hand = U.inhand_image_icon
			src.clothing_choices += P

			boutput(user, "<span class='notice'>[U.name]'s appearance has been copied!</span>")

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, "<span class='alert'><B>Your chameleon shoes malfunction!</B></span>")
			src.name = "shoes"
			src.desc = "A pair of shoes. Maybe they're those light up kind you had as a kid?"
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			src.icon_state = "psyche"
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Shoes."
		set category = "Local"
		set src in usr

		var/datum/chameleon_shoes_pattern/which = input("Change the shoes to which pattern?", "Chameleon Shoes") as null|anything in clothing_choices

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_shoes_pattern/T)
		src.name = T.name
		src.desc = T.desc
		src.icon_state = T.icon_state
		src.item_state = T.item_state
		src.icon = T.sprite_item
		src.wear_image_icon = T.sprite_worn
		src.inhand_image_icon = T.sprite_hand
		src.wear_image = image(wear_image_icon)
		src.inhand_image = image(inhand_image_icon)
		usr.set_clothing_icon_dirty()

/datum/chameleon_shoes_pattern
	var/name = "black shoes"
	var/desc = "These shoes somewhat protect you from fire."
	var/icon_state = "black"
	var/item_state = "black"
	var/sprite_item = 'icons/obj/clothing/item_shoes.dmi'
	var/sprite_worn = 'icons/mob/clothing/feet.dmi'
	var/sprite_hand = 'icons/mob/inhand/hand_feethand.dmi'

	brown
		name = "brown shoes"
		icon_state = "brown"
		item_state = "brown"
		desc = "Brown shoes, camouflage on this kind of station."

	red
		name = "red shoes"
		icon_state = "red"
		item_state = "red"

	orange
		name = "orange shoes"
		icon_state = "orange"
		item_state = "orange"
		desc = "Shoes, now in prisoner orange! Can be made into shackles."

	magnetic
		name = "magnetic shoes"
		desc = "Keeps the wearer firmly anchored to the ground. Provided the ground is metal, of course."
		icon_state = "magboots"
		item_state = "magboots"

	swat
		name = "military boots"
		desc = "Polished and very shiny military boots."
		icon_state = "swat"
		item_state = "swat"

	galoshes
		name = "galoshes"
		desc = "Rubber boots that prevent slipping on wet surfaces."
		icon_state = "galoshes"
		item_state = "galoshes"

	detective
		name = "worn boots"
		desc = "This pair of leather boots has seen better days."
		icon_state = "detective"
		item_state = "detective"

/obj/item/clothing/gloves/chameleon
	name = "Black Gloves"
	desc = "These gloves are fire-resistant."
	icon_state = "black"
	item_state = "bgloves"
	icon = 'icons/obj/clothing/item_gloves.dmi'
	wear_image_icon = 'icons/mob/clothing/hands.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_feethand.dmi'
	uses_multiple_icon_states = 1
	var/list/clothing_choices = list()
	material_prints = "high-tech nanofibers"

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_gloves_pattern)))
			var/datum/chameleon_gloves_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/clothing/gloves/U as obj, mob/user as mob)
		if(istype(U, /obj/item/clothing/gloves/chameleon))
			boutput(user, "<span class='alert'>No!!! That's a terrible idea! You'll cause an awful glove fractal!</span>")
			SPAWN_DBG(1 SECOND)
				boutput(user, "<span class='alert'>Nah, just having a laugh. Doing that still doesn't work though!</span>")
			return

		if(istype(U, /obj/item/clothing/gloves))
			for(var/datum/chameleon_gloves_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, "<span class='alert'>That appearance is already saved in the chameleon pattern banks!</span>")
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

			boutput(user, "<span class='notice'>[U.name]'s appearance has been copied!</span>")

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, "<span class='alert'><B>Your chameleon gloves malfunction!</B></span>")
			src.name = "gloves"
			src.desc = "A pair of gloves. Something seems off about them..."
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			src.icon_state = "psyche"
			src.item_state = "psyche"
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Gloves."
		set category = "Local"
		set src in usr

		var/datum/chameleon_shoes_pattern/which = input("Change the gloves to which pattern?", "Chameleon Gloves") as null|anything in clothing_choices

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_gloves_pattern/T)
		src.name = T.name
		src.desc = T.desc
		src.icon_state = T.icon_state
		src.item_state = T.item_state
		src.icon = T.sprite_item
		src.wear_image_icon = T.sprite_worn
		src.inhand_image_icon = T.sprite_hand
		src.wear_image = image(wear_image_icon)
		src.inhand_image = image(inhand_image_icon)
		usr.set_clothing_icon_dirty()

/datum/chameleon_gloves_pattern
	var/name = "Black Gloves"
	var/desc = "These gloves are fire-resistant."
	var/icon_state = "black"
	var/item_state = "bgloves"
	var/sprite_item = 'icons/obj/clothing/item_gloves.dmi'
	var/sprite_worn = 'icons/mob/clothing/hands.dmi'
	var/sprite_hand = 'icons/mob/inhand/hand_feethand.dmi'

	insulated
		desc = "These gloves are electrically insulated."
		name = "insulated gloves"
		icon_state = "yellow"
		item_state = "ygloves"

	fingerless
		desc = "These gloves lack fingers."
		name = "Fingerless Gloves"
		icon_state = "fgloves"
		item_state = "finger-"

	latex
		name = "Latex Gloves"
		icon_state = "latex"
		item_state = "lgloves"
		desc = "Thin gloves that offer minimal protection."

	boxing
		name = "Boxing Gloves"
		desc = "These gloves are for competitive boxing."
		icon_state = "boxinggloves"
		item_state = "bogloves"

/obj/item/storage/belt/chameleon
	name = "utility belt"
	desc = "Can hold various small objects."
	icon_state = "utilitybelt"
	item_state = "utility"
	icon = 'icons/obj/items/belts.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	wear_image_icon = 'icons/mob/clothing/belt.dmi'
	uses_multiple_icon_states = 1
	var/list/clothing_choices = list()

	New()
		..()
		for(var/U in (typesof(/datum/chameleon_belt_pattern)))
			var/datum/chameleon_belt_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/storage/belt/U as obj, mob/user as mob)
		..()
		if(istype(U, /obj/item/storage/belt/chameleon))
			boutput(user, "<span class='alert'>No!!! That's a terrible idea! You'll cause a putrid belt spiral!</span>")
			SPAWN_DBG(1 SECOND)
				boutput(user, "<span class='alert'>Nah, just jesting. Doing that still doesn't work though!</span>")
			return

		if(istype(U, /obj/item/storage/belt))
			for(var/datum/chameleon_belt_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, "<span class='alert'>That appearance is already saved in the chameleon pattern banks!</span>")
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

			boutput(user, "<span class='notice'>[U.name]'s appearance has been copied!</span>")

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, "<span class='alert'><B>Your chameleon belt malfunctions!</B></span>")
			src.name = "belt"
			src.desc = "A flashing belt. Looks like you can still put things in it, though."
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			src.icon_state = "psyche"
			src.item_state = "psyche"
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Belt."
		set category = "Local"
		set src in usr

		var/datum/chameleon_belt_pattern/which = input("Change the belt to which pattern?", "Chameleon Belt") as null|anything in clothing_choices

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_belt_pattern/T)
		src.name = T.name
		src.desc = T.desc
		src.icon_state = T.icon_state
		src.item_state = T.item_state
		src.icon = T.sprite_item
		src.wear_image_icon = T.sprite_worn
		src.inhand_image_icon = T.sprite_hand
		src.wear_image = image(wear_image_icon)
		src.inhand_image = image(inhand_image_icon)
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

/obj/item/storage/backpack/chameleon
	name = "backpack"
	desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's back."
	icon_state = "backpack"
	item_state = "backpack"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	uses_multiple_icon_states = 1
	var/list/clothing_choices = list()
	spawn_contents = list()

	New()
		..()
		var/obj/item/remote/chameleon/remote = new /obj/item/remote/chameleon(src.loc)
		SPAWN_DBG(0)
			remote.connected_backpack = src

		var/obj/item/clothing/under/chameleon/jumpsuit = new /obj/item/clothing/under/chameleon(src)
			remote.connected_jumpsuit = jumpsuit

		var/obj/item/clothing/head/chameleon/hat = new /obj/item/clothing/head/chameleon(src)
			remote.connected_hat = hat

		var/obj/item/clothing/suit/chameleon/suit = new /obj/item/clothing/suit/chameleon(src)
			remote.connected_suit = suit

		var/obj/item/clothing/glasses/chameleon/glasses = new /obj/item/clothing/glasses/chameleon(src)
			remote.connected_glasses = glasses

		var/obj/item/clothing/shoes/chameleon/shoes = new /obj/item/clothing/shoes/chameleon(src)
			remote.connected_shoes = shoes

		var/obj/item/storage/belt/chameleon/belt = new /obj/item/storage/belt/chameleon(src)
			remote.connected_belt = belt

		var/obj/item/clothing/gloves/chameleon/gloves = new /obj/item/clothing/gloves/chameleon(src)
			remote.connected_gloves = gloves

		for(var/U in (typesof(/datum/chameleon_backpack_pattern)))
			var/datum/chameleon_backpack_pattern/P = new U
			src.clothing_choices += P
		return

	attackby(obj/item/storage/backpack/U as obj, mob/user as mob)
		..()
		if(istype(U, /obj/item/storage/backpack/chameleon))
			boutput(user, "<span class='alert'>No!!! That's a terrible idea! You'll cause a stinky backpack self-cloning freak accident!</span>")
			SPAWN_DBG(1 SECOND)
				boutput(user, "<span class='alert'>Nah, just kidding. Doing that still doesn't work though!</span>")
			return

		if(istype(U, /obj/item/storage/backpack))
			for(var/datum/chameleon_backpack_pattern/P in src.clothing_choices)
				if(P.name == U.name)
					boutput(user, "<span class='alert'>That appearance is already saved in the chameleon pattern banks!</span>")
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

			boutput(user, "<span class='notice'>[U.name]'s appearance has been copied!</span>")

	emp_act()
		if (ishuman(src.loc))
			var/mob/living/carbon/human/M = src.loc
			boutput(M, "<span class='alert'><B>Your chameleon backpack malfunctions!</B></span>")
			src.name = "backpack"
			src.desc = "A flashing backpack. Looks like you can still put things in it, though."
			wear_image = image(wear_image_icon)
			inhand_image = image(inhand_image_icon)
			src.icon_state = "psyche_backpack"
			src.item_state = "psyche_backpack"
			M.set_clothing_icon_dirty()

	verb/change()
		set name = "Change Appearance"
		set desc = "Alter the appearance of your Chameleon Backpack."
		set category = "Local"
		set src in usr

		var/datum/chameleon_backpack_pattern/which = input("Change the backpack to which pattern?", "Chameleon Backpack") as null|anything in clothing_choices

		if(!which)
			return

		src.change_outfit(which)

	proc/change_outfit(var/datum/chameleon_backpack_pattern/T)
		src.name = T.name
		src.desc = T.desc
		src.icon_state = T.icon_state
		src.item_state = T.item_state
		src.icon = T.sprite_item
		src.wear_image_icon = T.sprite_worn
		src.inhand_image_icon = T.sprite_hand
		src.wear_image = image(wear_image_icon)
		src.inhand_image = image(inhand_image_icon)
		usr.set_clothing_icon_dirty()

/datum/chameleon_backpack_pattern
	var/name = "backpack"
	var/desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's back."
	var/icon_state = "backpack"
	var/item_state = "backpack"
	var/sprite_item = 'icons/obj/items/storage.dmi'
	var/sprite_worn =  'icons/mob/clothing/back.dmi'
	var/sprite_hand = 'icons/mob/inhand/hand_storage.dmi'

	engineer
		name = "engineering backpack"
		desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects effectively on the back of engineering personnel."
		icon_state = "bp_engineering"
		item_state = "bp_engineering"

	research
		name = "research backpack"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects efficiently on the back of research personnel."
		icon_state = "bp_research"
		item_state = "bp_research"

	security
		name = "security backpack"
		desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects adequately on the back of security personnel."
		icon_state = "bp_security"
		item_state = "bp_security"

	robotics
		name = "robotics backpack"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects monochromaticly on the back of roboticists."
		icon_state = "bp_robotics"
		item_state = "bp_robotics"

	genetics
		name = "genetics backpack"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects safely on the back of geneticists."
		icon_state = "bp_genetics"
		item_state = "bp_genetics"

	medic
		name = "medic's backpack"
		desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a Medical Doctor's back."
		icon_state = "bp_medic"
		item_state = "bp-medic"

	captain
		name = "Captain's Backpack"
		desc = "A fancy designer bag made out of space snake leather and encrusted with plastic expertly made to look like gold."
		icon_state = "capbackpack"
		item_state = "capbackpack"

/obj/item/remote/chameleon
	name = "chameleon outfit remote"
	desc = "A remote control that allows you to change an entire set of chameleon clothes, all at once."
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote"
	item_state = "electronic"
	w_class = W_CLASS_SMALL

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

	attack_self()
		if (isliving(usr))
			set src in usr
			var/datum/chameleon_outfit_choices/which = input(usr, "Change the chameleon outfit to which set?", "Chameleon Outfit Remote") as null|anything in outfit_choices

			if(!which)
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
	var/name = "Staff Assistant"
	var/jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank
	var/hat_type = new/datum/chameleon_hat_pattern/
	var/suit_type = new/datum/chameleon_suit_pattern
	var/glasses_type = new/datum/chameleon_glasses_pattern
	var/shoes_type = new/datum/chameleon_shoes_pattern
	var/gloves_type = null
	var/belt_type = new/datum/chameleon_belt_pattern
	var/backpack_type = new/datum/chameleon_backpack_pattern

	captain
		name = "Captain"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank
		hat_type = new/datum/chameleon_hat_pattern/caphat
		suit_type = new/datum/chameleon_suit_pattern/captain_armor
		glasses_type = new/datum/chameleon_glasses_pattern/sunglasses
		shoes_type = new/datum/chameleon_shoes_pattern/swat
		belt_type = null
		backpack_type = new/datum/chameleon_backpack_pattern/captain

	head_of_security
		name = "Head Of Security"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/head_of_securityold
		hat_type = new/datum/chameleon_hat_pattern/HoS_beret
		suit_type = new/datum/chameleon_suit_pattern/hos_jacket
		glasses_type = new/datum/chameleon_glasses_pattern/sechud
		shoes_type = new/datum/chameleon_shoes_pattern/swat
		gloves_type = null
		belt_type = new/datum/chameleon_belt_pattern/security
		backpack_type = new/datum/chameleon_backpack_pattern/security

	head_of_personnel
		name = "Head of Personnel"
		jumpsuit_type = new/datum/chameleon_jumpsuit_pattern/rank/head_of_personnel
		hat_type = new/datum/chameleon_hat_pattern/fancy
		suit_type = new/datum/chameleon_suit_pattern/winter_coat_command
		glasses_type = new/datum/chameleon_glasses_pattern
		shoes_type = new/datum/chameleon_shoes_pattern/brown
		gloves_type = null
		belt_type = new/datum/chameleon_belt_pattern
		backpack_type = new/datum/chameleon_backpack_pattern

	security
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