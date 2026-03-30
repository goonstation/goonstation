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

	rank/pharmacist
		name = "pharmacist's jumpsuit"
		desc = "Proves you know how to make chemicals explode and/or heal people."
		icon_state = "pharmacist"
		item_state = "pharmacist"

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
