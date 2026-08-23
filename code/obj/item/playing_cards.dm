//defines for the number of each card in the dmi of the following StG categories
#define NUMBER_F 4 //female
#define NUMBER_M 4 //male
#define NUMBER_N 2 //nonbinary
#define NUMBER_GENERAL 8
#define NUMBER_BORG 2
#define NUMBER_AI 2

//General Card Stuffs
//-----------------//
/obj/item/playing_card
	icon = 'icons/obj/items/playing_card.dmi'
	icon_state = "plain-1-1"
	dir = NORTH
	w_class = W_CLASS_TINY
	burn_point = 220
	burn_output = 900
	burn_possible = TRUE
	///what style of card sprite are we using?
	var/card_style
	///number of cards in a full deck (used for reference when updating stack size)
	var/total_cards
	///the overall name of a given card type : used to communicate with card groups (i.e. playing, tarot, hanafuda)
	var/card_name
	var/facedown = FALSE
	var/foiled = FALSE
	var/tapped = FALSE
	var/reversed = FALSE
	///when solitaire stacking, how far down is the newest card pixel shifted?
	var/solitaire_offset = 5
	///vital card information that is referenced when a card flips over
	var/list/stored_info
	contextLayout = new /datum/contextLayout/instrumental(16)
	var/list/datum/contextAction/cardActions

	attack_hand(mob/user)
		..()
		set_dir(NORTH) //makes sure cards are always upright in the inventory (unless tapped or reversed - see later)


	attack_self(mob/user as mob)
		flip() //uno reverse O.O

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/playing_card)) //if a card is hit by a card, open the context menu for the player to decide what happens.
			if(loc != user)
				update_card_actions(TRUE)
			else
				update_card_actions()
			user.showContextActions(cardActions, src)
		else if(istype(W,/obj/item/card_group)) //when a card is hit by a card group, if it's a hand, vacuum up the card, otherwise it's a deck and the card gets sat on.
			var/obj/item/card_group/group = W
			if(group.card_style != card_style)
				user.show_text("These card types don't match, silly!", "red")
				return
			if(src.loc == user)
				user.u_equip(src)
				group.add_to_group(src)
				if(group.is_hand)
					user.visible_message("<b>[user.name]</b> adds a card to [his_or_her(user)] [group.name].")
				else
					user.visible_message("<b>[user.name]</b> plops the [group.name] on top of a card.")
			else
				if(group.is_hand)
					group.add_to_group(src)
					user.visible_message("<b>[user.name]</b> adds a card to [his_or_her(user)] [group.name].")
				else
					user.u_equip(group)
					group.set_loc(get_turf(src))
					group.add_to_group(src)
					user.visible_message("<b>[user.name]</b> plops the [group.name] on top of the [src.name].")
			group.update_group_sprite()
		else
			..()

	afterattack(var/atom/A as turf, var/mob/user as mob, reach, params) //handling the ability to place cards on the floor
		if(istype(A,/turf/simulated/floor) || istype(A,/turf/unsimulated/floor))
			user.u_equip(src)
			src.set_loc(A)
			if(islist(params) && params["icon-y"] && params["icon-x"])
				src.pixel_x = text2num(params["icon-x"]) - 16
				src.pixel_y = text2num(params["icon-y"]) - 16
			set_dir(user.dir)
		else
			..()

	mouse_drop(var/atom/target as obj|mob) //r o t a t e
		if(!istype(target,/obj/item/card_group))
			if (is_incapacitated(usr) || !usr.can_use_hands() || !can_reach(usr, src) || usr.sleeping || (target && target.event_handler_flags & NO_MOUSEDROP_QOL))
				return
			tap_or_reverse(usr)
		else
			..()


	set_dir(var/new_dir) //handing the modification of direction based on if a card is tapped or reversed
		..()
		if(tapped)
			if(loc == usr)
				dir = EAST
			else
				switch(dir)
					if(NORTH)
						dir = EAST
					if(SOUTH)
						dir = WEST
					if(EAST)
						dir = SOUTH
					if(WEST)
						dir = NORTH
		else if(reversed)
			if(loc == usr)
				dir = SOUTH
			else
				switch(dir)
					if(NORTH)
						dir = SOUTH
					if(SOUTH)
						dir = NORTH
					if(EAST)
						dir = WEST
					if(WEST)
						dir = EAST
		else if(loc == usr)
			dir = NORTH

	proc/update_stored_info() //builds the stored_info list
		stored_info = list(name,desc,icon_state)

	proc/flip()
		tooltip_rebuild = TRUE //makes sure the card tooltips get updated everytime
		if(!facedown)
			name = "playing card"
			desc = "A face-down card."
			icon_state = "[card_style]-back"
			facedown = TRUE
		else
			name = stored_info[1]
			desc = stored_info[2]
			icon_state = stored_info[3]
			facedown = FALSE
			if(tapped)
				tapped = FALSE
			if(reversed)
				reversed = FALSE
			dir = NORTH

	proc/tap_or_reverse(var/mob/user) //this is called to handle tapping and reversing of cards
		if(card_style == "tarot")
			if(!reversed)
				reversed = TRUE
				name += " Reversed"
			else
				reversed = FALSE
				name = stored_info[1]
		else
			if(!tapped)
				tapped = TRUE
				name = "tapped [name]"
			else
				tapped = FALSE
				name = stored_info[1]
		set_dir(user.dir)

	proc/update_card_actions(var/card_outside) //builds the context actions list when called
		cardActions = list()
		if(card_outside)
			cardActions += new /datum/contextAction/card/solitaire
			cardActions += new /datum/contextAction/card/fan
			cardActions += new /datum/contextAction/card/stack
			cardActions += new /datum/contextAction/card/close

	proc/deck_or_hand(var/mob/user,var/is_hand) //used by context actions to handle creating a hand or deck of cards
		if(!istype(user.equipped(),/obj/item/playing_card))
			return
		var/obj/item/playing_card/card = user.equipped()
		if(card.card_style != card_style)
			user.show_text("These card types don't match, silly!", "red")
			return
		var/obj/item/card_group/group = new /obj/item/card_group
		if(is_hand)
			group.update_group_information(group,src,TRUE)
		else
			group.update_group_information(group,src,FALSE)
		user.u_equip(card)
		group.add_to_group(card)
		if(is_hand)
			group.is_hand = TRUE
			user.visible_message("<b>[user.name]</b> creates a hand of cards.")
		else
			user.visible_message("<b>[user.name]</b> creates a deck of cards.")
		if(loc == user)
			user.u_equip(src)
			group.add_to_group(src,1)
			user.put_in_hand_or_drop(group)
		else
			group.set_loc(get_turf(src.loc))
			group.add_to_group(src,1)
		group.update_group_sprite()
		qdel(src)

	proc/solitaire(var/mob/user) //handles solitaire stacking
		if(!istype(user.equipped(),/obj/item/playing_card))
			return
		var/obj/item/playing_card/card = user.equipped()
		if(card.card_style != card_style)
			user.show_text("These card types don't match, silly!", "red")
			return
		user.u_equip(card)
		card.set_loc(src.loc)
		card.pixel_x = src.pixel_x
		card.pixel_y = (src.pixel_y - card.solitaire_offset)

	//procs that convert the card into the given StG card type
	proc/stg_mob(var/list/possible_card_types,var/list/humans,var/list/borgos,var/list/ai)
		var/path = pick(possible_card_types)
		var/datum/playing_card/griffening/creature/mob/chosen_card_type = new path
		var/mob/living/chosen_mob

		var/icon_state_num

		if(istype(chosen_card_type,/datum/playing_card/griffening/creature/mob/cyborg))
			if(length(borgos))
				chosen_mob = pick(borgos) //DEV - condense if possible
			if(chosen_mob)
				name = chosen_mob.name
			else
				name = "Cyborg [pick("Alpha", "Beta", "Gamma", "Delta", "Xi", "Pi", "Theta")]-[rand(10,99)]"
			icon_state_num = rand(1,NUMBER_BORG)
			icon_state = "stg-borg-[icon_state_num]"
		else if (istype(chosen_card_type,/datum/playing_card/griffening/creature/mob/ai))
			if(length(ai))
				chosen_mob = pick(ai)
			if(chosen_mob)
				name = chosen_mob.name
			else
				name = pick("SHODAN", "GLADOS", "HAL-9000")
			name += " the AI"
			icon_state_num = rand(1,NUMBER_AI)
			icon_state = "stg-ai-[icon_state_num]"
		else
			if(length(humans))
				chosen_mob = pick(humans)
			if(chosen_mob)
				name = "[chosen_card_type.card_name] [chosen_mob.real_name]"
				switch(his_or_her(chosen_mob))
					if("her")
						icon_state_num = rand(1,NUMBER_F)
						icon_state = "stg-f-[icon_state_num]"
					if("his")
						icon_state_num = rand(1,NUMBER_M)
						icon_state = "stg-m-[icon_state_num]"
					if("their")
						icon_state_num = rand(1,NUMBER_N)
						icon_state = "stg-n-[icon_state_num]"
			else
				name = chosen_card_type.card_name
				var/gender = rand(1,3)
				switch(gender)
					if(1)
						icon_state_num = rand(1,NUMBER_F)
						icon_state = "stg-f-[icon_state_num]"
					if(2)
						icon_state_num = rand(1,NUMBER_M)
						icon_state = "stg-m-[icon_state_num]"
					if(3)
						icon_state_num = rand(1,NUMBER_N)
						icon_state = "stg-n-[icon_state_num]"
		if(chosen_card_type.LVL)
			name = "LVL [chosen_card_type.LVL] [name]"
		var/atk
		var/def
		if(chosen_card_type.randomized_stats)
			atk = rand(0, 10)
			def = rand(0, 10)
			if(chosen_card_type.LVL)
				atk *= chosen_card_type.LVL
				def *= chosen_card_type.LVL
		else
			atk = chosen_card_type.ATK
			def = chosen_card_type.DEF

		name += " [atk]/[def]"
		desc = chosen_card_type.card_data
		desc += " ATK [atk] | DEF [def]"

	proc/stg_friend(var/list/possible_card_types)
		var/path = pick(possible_card_types)
		var/datum/playing_card/griffening/creature/friend/chosen_card_type = new path
		if(chosen_card_type.LVL)
			name = "LVL [chosen_card_type.LVL] [chosen_card_type.card_name]"
		else
			name = chosen_card_type.card_name
		var/atk
		var/def
		if(chosen_card_type.randomized_stats)
			atk = rand(0, 10)
			def = rand(0, 10)
			if(chosen_card_type.LVL)
				atk *= chosen_card_type.LVL
				def *= chosen_card_type.LVL
		else
			atk = chosen_card_type.ATK
			def = chosen_card_type.DEF
		name += " [atk]/[def]"
		desc = chosen_card_type.card_data
		desc += " ATK [atk] | DEF [def]"
		icon_state = "stg-general-[rand(1,NUMBER_GENERAL)]"

	proc/stg_effect(var/list/possible_card_types)
		var/path = pick(possible_card_types)
		var/datum/playing_card/griffening/effect/chosen_card_type = new path

		name = chosen_card_type.card_name
		desc = chosen_card_type.card_data
		icon_state = "stg-general-[rand(1,NUMBER_GENERAL)]"

	proc/stg_area(var/list/possible_card_types)
		var/path = pick(possible_card_types)
		var/datum/playing_card/griffening/area/chosen_card_type = new path

		name = chosen_card_type.card_name
		desc = chosen_card_type.card_data
		icon_state = "stg-general-[rand(1,NUMBER_GENERAL)]"

	proc/add_foil() //makes the card shiiiiiny
		UpdateOverlays(image(icon,"stg-foil"),"foil")
		foiled = TRUE
		name = "Foil [name]"
		src.update_stored_info()

/obj/item/playing_card/expensive //(¬‿¬)
	desc = "Tap this card and sacrifice one of yourselves to win the game."
	icon_state = "stg-general-0"
	var/list/prefix1 = list("Incredibly", "Strange", "Mysterious", "Suspicious", "Scary")
	var/list/prefix2 = list("Rare", "Black", "Dark", "Shadowy", "Expensive", "Fun", "Gamer")
	var/list/names = list("Flower", "Blossom", "Tulip", "Daisy")
	card_style = "stg"

	New()
		..()
		name = "[pick(prefix1)] [pick(prefix2)] [pick(names)]"
		update_stored_info()

	mouse_drop(var/atom/target as obj|mob)
		..()
		if(tapped)
			var/mob/user = usr
			user.deathConfetti()
			playsound(user.loc, 'sound/musical_instruments/Bikehorn_1.ogg', 50)
			user.visible_message(SPAN_COMBAT("<b>[uppertext(user.name)] WINS THE GAME!</b>"))
			if(!foiled)
				logTheThing(LOG_COMBAT, user, "was instantly braindeath killed by [src] at [log_loc(src)].")
				user.take_brain_damage(1000)
			else
				logTheThing(LOG_COMBAT, user, "was partygibbed by [src] at [log_loc(src)].")
				user.partygib(1)

ABSTRACT_TYPE(/obj/item/card_group)
/// since "playing_card"s are singular cards, card_groups handling groups of playing_cards in the form of either a deck or hand
/obj/item/card_group
	name = "deck of cards"
	icon = 'icons/obj/items/playing_card.dmi'
	icon_state = "plain_deck_4"
	dir = NORTH
	w_class = W_CLASS_TINY
	burn_point = 220
	burn_output = 900
	burn_possible = TRUE
	health = 10
	inventory_counter_enabled = 1
	/// same function as playing_card card name
	var/card_name
	///the type of card back used for this group (references icon_state names in the dmi)
	var/card_style = "plain"
	///how many cards are in a fully built deck of this type? (54 for plain decks, 78 for tarot, etc.) : used for reference on stack heights
	var/total_cards
	var/is_hand = FALSE
	///the number of cards you can have in a hand before it automatically becomes a deck
	var/max_hand_size = 18
	contextLayout = new /datum/contextLayout/instrumental(16)
	var/list/datum/contextAction/cardActions
	var/list/stored_cards = list()

	attack_hand(mob/user)
		if(!is_hand && (isturf(src.loc) || src.loc == user)) //handling the player interacting with a deck of cards with an empty hand
			update_card_actions(user, "empty")
			user.showContextActions(cardActions, src)
		else
			..()

	attack_self(mob/user as mob)
		if(is_hand) //attack_self with hand to pull up the menu
			update_card_actions(user, "handself")
			user.showContextActions(cardActions, src)
		else //attack_self with deck to shuffle
			if (length(stored_cards) < 11)
				shuffle_list(stored_cards)
			else
				riffle_shuffle(stored_cards)
			user.visible_message("<b>[user.name]</b> shuffles the [src.name].")

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/playing_card)) //adding a card to a hand will automatically place it in the hand, while adding a card to a deck will allow the player to decide where it goes
			if(is_hand)
				var/obj/item/playing_card/card = W
				if(card.card_style != card_style)
					user.show_text("These card types don't match, silly!", "red")
					return
				user.u_equip(card)
				add_to_group(card)
				user.visible_message("<b>[user.name]</b> adds a card to [his_or_her(user)] [src.name]")
			else
				update_card_actions(user, "card")
				user.showContextActions(cardActions, src)
			update_group_sprite()
		else if(istype(W,/obj/item/card_group)) //adding a hand to a deck is similar to adding a card to a deck, whereas adding a deck plops it on top
			var/obj/item/card_group/group = W
			if(group.is_hand && !is_hand)
				update_card_actions(user, "group")
				user.showContextActions(cardActions, src)
			else
				top_or_bottom(user,group,"top",1)
		else
			..()

	afterattack(var/atom/A as turf, var/mob/user as mob, reach, params)
		if(istype(A,/turf/simulated/floor) || istype(A,/turf/unsimulated/floor))
			user.u_equip(src)
			src.set_loc(A)
			if(islist(params) && params["icon-y"] && params["icon-x"])
				src.pixel_x = text2num(params["icon-x"]) - 16
				src.pixel_y = text2num(params["icon-y"]) - 16
		else
			..()

	special_desc(dist, mob/user) //handles the special chat output for examining hands and decks!
		if(is_hand && dist == 0)
			hand_examine(user,"self")
		else
			..()
			user.show_text ("<b>Contains [length(stored_cards)] cards.</b>" )

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob) //handles piling cards into a deck or hand
		if(istype(O,/obj/item/playing_card))
			user.visible_message("[user.name] starts scooping cards into the [src.name]...")
			SPAWN(0.2 SECONDS)
				for(var/obj/item/playing_card/card in range(1, user))
					if(card.card_style != card_style)
						continue
					if(card.loc == user)
						user.u_equip(card)
					add_to_group(card,1)
					update_group_sprite()
					sleep(0.2 SECONDS)

	proc/hand_examine(var/mob/user, var/target) //builds the examine text players see when a hand is revealed or examined
		var/message = ""
		for(var/obj/item/playing_card/card in stored_cards)
			message += "<b>[card.name]:</b><br>"
			if(card.desc)
				message += "[card.desc]<br>"
			else
				message += "<i>no description</i><br>"
			message += "-----<br>"
		if(target == "self")
			user.show_text(message)
		else if(target == "all")
			user.visible_message("<b>[user.name]</b> reveals their hand: <br><br>[message]")

	proc/draw_card(var/mob/user,var/obj/item/playing_card/card) //handles drawing single cards : used in search and draw
		user.put_in_hand_or_drop(card)
		if(card.card_style == "tarot")
			if(prob(50))
				card.tap_or_reverse(user)

	proc/handle_draw_last_card(var/mob/user) //when a player draws the second to last card of a group, the group is replaced by the last card in the group for consistency
		var/obj/item/playing_card/card = stored_cards[1]
		if(card.facedown == FALSE)
			card.flip()
		if(loc == user)
			user.u_equip(src)
			user.put_in_hand_or_drop(stored_cards[1])
		else
			card.set_loc(get_turf(src.loc))
		qdel(src)

	proc/add_to_group(var/obj/item/playing_card/card,var/insert) //handles adding cards to card_groups and where they are added
		card.set_loc(src)
		if(card.facedown)
			card.flip()
		if(card.tapped)
			card.tapped = FALSE
			card.name = card.stored_info[1]
		if(card.reversed)
			card.reversed = FALSE
			card.name = card.stored_info[1]
		card.dir = NORTH
		if(insert)
			stored_cards.Insert(insert,card)
		else
			stored_cards += card
		if(is_hand)
			if(length(stored_cards) > max_hand_size)
				is_hand = FALSE

	proc/update_group_sprite() //updates the deck/hand sprite to match how many cards are inside
		var/cards = length(stored_cards)
		if(!is_hand)
			if(cards >= ((total_cards/4 + total_cards/2)))
				icon_state = "[card_style]-deck-4"
			else if(cards >= total_cards/2)
				icon_state = "[card_style]-deck-3"
			else if(cards > total_cards/4)
				icon_state = "[card_style]-deck-2"
			else if(cards <= total_cards/4)
				icon_state = "[card_style]-deck-1"
			name = "deck of [card_name] cards"
		else
			if(cards > 5)
				icon_state = "[card_style]-hand-5"
			else
				icon_state = "[card_style]-hand-[cards]"
			name = "hand of [card_name] cards"
		inventory_counter.update_number(length(stored_cards))

	proc/update_card_information(var/obj/item/playing_card/card) //communicates information between card groups and playing_cards during deck creation to keep them in sync
		card.total_cards = total_cards
		card.card_style = card_style
		card.card_name = card_name

	proc/update_group_information(var/obj/item/card_group/group,var/obj/item/from,var/hand) //the inverse of update_card_information for creating card groups from cards
		if(hand == TRUE)
			group.is_hand = TRUE
		else
			group.is_hand = FALSE
		if(istype(from,/obj/item/playing_card))
			var/obj/item/playing_card/FA = from
			group.total_cards = FA.total_cards
			group.card_style = FA.card_style
			group.card_name = FA.card_name
		else if(istype(from,/obj/item/card_group))
			var/obj/item/card_group/FB = from
			group.total_cards = FB.total_cards
			group.card_style = FB.card_style
			group.card_name = FB.card_name

	proc/update_card_actions(mob/user, var/hitby) //generates card actions based on which interaction is causing the list to be updated
		cardActions = list()

		//card to deck
		if(hitby == "card")
			cardActions += new /datum/contextAction/card/topdeck
			cardActions += new /datum/contextAction/card/bottomdeck
			cardActions += new /datum/contextAction/card/close
		//empty to deck
		else if(hitby == "empty") //reordered this a bit to prevent overdrawing and have the correct actions avaliable
			cardActions += new /datum/contextAction/card/pickup
			if(!(user.find_in_hand(/obj/item/card_group)) || length(user.contents.Find(/obj/item/card_group)) < max_hand_size)
				cardActions += new /datum/contextAction/card/draw
				cardActions += new /datum/contextAction/card/draw_facedown
				cardActions += new /datum/contextAction/card/draw_multiple
				cardActions += new /datum/contextAction/card/search
			if(length(stored_cards) <= max_hand_size)
				cardActions += new /datum/contextAction/card/fan
			cardActions += new /datum/contextAction/card/close
		//hand to self
		else if(hitby == "handself")
			cardActions += new /datum/contextAction/card/search
			cardActions += new /datum/contextAction/card/reveal
			cardActions += new /datum/contextAction/card/stack
			cardActions += new /datum/contextAction/card/close
		//hand to deck
		else if(hitby == "group")
			cardActions += new /datum/contextAction/card/topdeck
			cardActions += new /datum/contextAction/card/bottomdeck
			cardActions += new /datum/contextAction/card/close

	proc/draw(var/mob/user,var/facedown) //the context action proc that handles players drawing a card
		var/obj/item/playing_card/card = stored_cards[1]
		if(facedown)
			card.flip()
		draw_card(user,card)
		stored_cards -= card
		if(length(stored_cards) == 1)
			handle_draw_last_card(user)
		else
			update_group_sprite()
		user.visible_message("<b>[user.name]</b> draws a card from the [src.name].")

	proc/draw_multiple(var/mob/user) //the context action proc that handles players drawing multiple cards
		if(is_hand)
			return
		var/card_number = round(input(user, "How many cards would you like to draw?", "[name]")  as null|num)
		if(!card_number || !isnum_safe(card_number))
			return
		if(card_number == 1)
			draw(user)
			return
		if(card_number > length(stored_cards))
			card_number = length(stored_cards)
		if(in_interact_range(src, user))
			var/obj/item/card_group/hand = new /obj/item/card_group
			update_group_information(hand,src,TRUE)
			for(var/i in 1 to card_number)
				hand.add_to_group(stored_cards[1])
				stored_cards -= stored_cards[1]
			hand.update_group_sprite()
			user.put_in_hand_or_drop(hand)
			user.visible_message("<b>[user.name]</b> draws [card_number] cards from the [src.name].")
			if(length(stored_cards) == 1)
				handle_draw_last_card(user)
			else if(!length(stored_cards))
				qdel(src)
			else
				update_group_sprite("user.name")

	proc/search(var/mob/user) //the context action proc that handles players search a group for a specific card
		user.visible_message("<b>[user.name]</b> begins to search through the [src.name]...")
		var/card = input(user, "Which card would you like to draw?", "[name]")  as null|anything in stored_cards
		if(!card)
			user.visible_message("<b>[user.name]</b> doesn't find what they're looking for.")
			return
		if(in_interact_range(src, user))
			draw_card(user,card)
			stored_cards -= card
			if(length(stored_cards) == 1)
				handle_draw_last_card(user)
			else
				update_group_sprite()
			user.visible_message("<b>[user.name]</b> slides a card out of the [src.name].")

	proc/reveal(var/mob/user) //the context action proc that handles revealing a hand
		hand_examine(user,"all")

	proc/fan(var/mob/user) //the context action proc that handles creating a hand from a deck
		if(is_hand)
			return
		if(length(stored_cards) < max_hand_size)
			is_hand = TRUE
			update_group_sprite()
			user.visible_message("<b>[user.name]</b> spreads [his_or_her(user)] cards into a neat fan.")

	proc/stack(var/mob/user) //the opposite of a fan
		if(!is_hand)
			return
		is_hand = FALSE
		update_group_sprite()
		user.visible_message("<b>[user.name]</b> gathers [his_or_her(user)] cards into a deck.")

	proc/top_or_bottom(var/mob/user,var/W,var/position,var/no_message) //the context action proc that handles adding cards to the top or bottom of a group
		var/successful
		if(istype(W,/obj/item/card_group))
			var/obj/item/card_group/group = W
			if(group.card_style == card_style)
				if(position == "top")
					var/card_pos = length(group.stored_cards)
					for(var/i in 1 to length(group.stored_cards))
						var/obj/item/card = group.stored_cards[card_pos]
						add_to_group(card,1)
						card_pos--
					successful = "top"
				else
					for(var/obj/item/card in group.stored_cards)
						add_to_group(card)
					successful = "the bottom"
				user.u_equip(group)
				qdel(group)
				if(is_hand && (length(stored_cards) > max_hand_size))
					is_hand = FALSE
				update_group_sprite()
				successful = TRUE
		else if(istype(W,/obj/item/playing_card))
			var/obj/item/playing_card/card = W
			if(card.card_style == card_style)
				user.u_equip(card)
				if(position == "top")
					add_to_group(card,1)
					successful = "top"
				else
					add_to_group(card)
					successful = "the bottom"
				update_group_sprite()
		if(successful)
			if(!no_message)
				user.visible_message("<b>[user.name]</b> places the [W] on [successful] of the [src.name].")
		else
			user.show_text("These card types don't match, silly!", "red")

	proc/build_stg(var/deck) //proc that handles generating either an stg preconstructed deck or stg booster pack
		var/list/possible_humans = list()
		for(var/mob/living/carbon/human/H in mobs)
			if(isnpcmonkey(H))
				continue
			if(iswizard(H))
				continue
			if(isnukeop(H))
				continue
			if(!H.mind)
				continue
			possible_humans += H
		var/list/possible_borgos = list()
		for(var/mob/living/silicon/robot/R in mobs)
			possible_borgos += R
		var/list/possible_ai = list()
		for(var/mob/living/silicon/ai/A in mobs)
			possible_ai += A

		var/list/possible_mobs = childrentypesof(/datum/playing_card/griffening/creature/mob)
		var/list/possible_friends = childrentypesof(/datum/playing_card/griffening/creature/friend)
		var/list/possible_effects = childrentypesof(/datum/playing_card/griffening/effect)
		var/list/possible_areas = childrentypesof(/datum/playing_card/griffening/area)


		var/modified_card_amount
		if(deck)
			modified_card_amount = prob(2)?39:40
		else
			modified_card_amount = prob(1)?9:10

		for(var/i in 1 to modified_card_amount)
			var/obj/item/playing_card/card = new /obj/item/playing_card(src)
			stored_cards += card
			if(deck)
				var/card_type = rand(1,4)
				switch(card_type)
					if(1)
						card.stg_mob(possible_mobs,possible_humans,possible_borgos,possible_ai)
					if(2)
						card.stg_friend(possible_friends)
					if(3)
						card.stg_effect(possible_effects)
					if(4)
						card.stg_area(possible_areas)
				if(prob(10))
					card.add_foil()
			else
				switch(i)
					if(1,2,3)
						card.stg_mob(possible_mobs,possible_humans,possible_borgos,possible_ai)
					if(4,5,6)
						card.stg_friend(possible_friends)
					if(7,8,9)
						card.stg_effect(possible_effects)
					if(10)
						card.stg_area(possible_areas)
			update_card_information(card)
			card.update_stored_info()

		if((modified_card_amount == 39) || (modified_card_amount == 9))
			var/obj/item/playing_card/expensive/e = new /obj/item/playing_card/expensive
			switch(modified_card_amount)
				if(39)
					add_to_group(e,rand(1,39))
					if(prob(10))
						e.add_foil()
				if(9)
					add_to_group(e)

		if(!deck)
			shuffle_list(stored_cards)
			var/obj/item/playing_card/card = pick(stored_cards)
			card.add_foil()

		update_group_sprite()

//Plain playing cards
//-----------------//
/obj/item/card_group/plain
	card_style = "plain"
	total_cards = 54
	card_name = "playing"

	New()
		..()
		var/suit_num = 1
		var/card_num = 1
		var/plain_suit
		var/suit_name
		for(var/i in 1 to total_cards)
			var/obj/item/playing_card/card = new /obj/item/playing_card(src)
			stored_cards += card
			switch(suit_num)
				if(1)
					plain_suit = TRUE
					suit_name = "Hearts"
				if(2)
					plain_suit = TRUE
					suit_name = "Diamonds"
				if(3)
					plain_suit = TRUE
					suit_name = "Spades"
				if(4)
					plain_suit = TRUE
					suit_name = "Clubs"
				if(5)
					plain_suit = FALSE
			if(plain_suit)
				if(card_num == 1)
					card.name = "Ace of [suit_name]"
				else if(card_num < 11)
					card.name = "[capitalize(num2text(card_num))] of [suit_name]"
				else
					switch(card_num)
						if(11)
							card.name = "Jack of [suit_name]"
						if(12)
							card.name = "Queen of [suit_name]"
						if(13)
							card.name = "King of [suit_name]"
			else
				if(card_num == 1)
					card.name = "Red Joker"
				else
					card.name = "Black Joker"

			card.icon_state = "[card_style]-[suit_num]-[card_num]"
			update_card_information(card)
			card.update_stored_info()

			if(plain_suit)
				if(card_num < 13)
					card_num++
				else
					card_num = 1
					suit_num++
			else if(card_num < 2)
				card_num++
		update_group_sprite()

//Tarot cards
//---------//
/obj/item/card_group/tarot
	desc = {"A type of card that originates back in the 15th century, but became popular for divination in the 18th century. There are 14 cards of each
	of the four suit types and 22 cards without suits that are called the Major Arcana."}
	card_style = "tarot"
	total_cards = 78
	card_name = "tarot"
	icon_state = "tarot_deck_4"

	New()
		..()
		var/suit_num = 1
		var/card_num = 1
		var/minor
		var/suit_name
		var/list/major = list("The Fool - O", "The Magician - I", "The High Priestess - II", "The Empress - III", "The Emperor - IV", "The Hierophant - V",\
		"The Lovers - VI", "The Chariot - VII", "Justice - VIII", "The Hermit - IX", "Wheel of Fortune - X", "Strength - XI", "The Hanged Man - XII", "Death - XIII", "Temperance - XIV",\
		"The Devil - XV", "The Tower - XVI", "The Star - XVII", "The Moon - XVIII", "The Sun - XIX", "Judgement - XX", "The World - XXI")
		for(var/i in 1 to total_cards)
			var/obj/item/playing_card/card = new /obj/item/playing_card(src)
			stored_cards += card
			switch(suit_num)
				if(1)
					minor = TRUE
					suit_name = "Cups"
				if(2)
					minor = TRUE
					suit_name = "Pentacles"
				if(3)
					minor = TRUE
					suit_name = "Swords"
				if(4)
					minor = TRUE
					suit_name = "Wands"
				if(5)
					minor = FALSE

			if(minor)
				if(card_num == 1)
					card.name = "Ace of [suit_name]"
				else if(card_num < 11)
					card.name = "[capitalize(num2text(card_num))] of [suit_name]"
				else
					switch(card_num)
						if(11)
							card.name = "Page of [suit_name]"
						if(12)
							card.name = "Knight of [suit_name]"
						if(13)
							card.name = "Queen of [suit_name]"
						if(14)
							card.name = "King of [suit_name]"
			else
				card.name = major[card_num]

			card.icon_state = "[card_style]-[suit_num]-[card_num]"
			update_card_information(card)
			card.update_stored_info()

			if(minor)
				if(card_num < 14)
					card_num++
				else
					card_num = 1
					suit_num++
			else if(card_num < 22)
				card_num++
		update_group_sprite()

//Hanafuda
//------//
/obj/item/card_group/hanafuda
	desc = "A deck of Japanese hanafuda."
	card_style = "hanafuda"
	total_cards = 48
	card_name = "hanafuda"
	icon_state = "hanafuda_deck_4"

	New()
		..()
		var/target_month = 1 //card suit
		var/card_num = 1 //number within the card's suit
		for(var/i in 1 to total_cards)
			var/special_second
			var/special_third
			var/special_fourth

			var/obj/item/playing_card/card = new /obj/item/playing_card(src)
			stored_cards += card
			switch(target_month)
				if(1)
					card.name = "January : "
					special_third = "Poetry Slip"
					special_fourth = "Bright : Crane"
				if(2)
					card.name = "February : "
					special_third = "Poetry Slip"
					special_fourth = "Animal : Bush Warbler"
				if(3)
					card.name = "March : "
					special_third = "Poetry Slip"
					special_fourth = "Bright : Curtain"
				if(4)
					card.name = "April : "
					special_third = "Red Ribbon"
					special_fourth = "Animal : Cuckoo"
				if(5)
					card.name = "May : "
					special_third = "Blue Ribbon"
					special_fourth = "Animal : Butterfly"
				if(6)
					card.name = "June : "
					special_third = "Red Ribbon"
					special_fourth = "Animal : Eight-Plank Bridge"
				if(7)
					card.name = "July : "
					special_third = "Red Ribbon"
					special_fourth = "Animal : Boar"
				if(8)
					card.name = "August : "
					special_third = "Animal : Geese"
					special_fourth = "Bright : Moon"
				if(9)
					card.name = "September : "
					special_third = "Blue Ribbon"
					special_fourth = "Animal/Plain : Sake Cup"
				if(10)
					card.name = "October : "
					special_third = "Blue Ribbon"
					special_fourth = "Animal : Deer"
				if(11)
					card.name = "November : "
					special_second = "Red Ribbon"
					special_third = "Animal : Swallow"
					special_fourth = "Bright : Rain Man"
				if(12)
					card.name = "December : "
					special_fourth = "Bright : Phoenix"

			switch(card_num)
				if(1)
					card.name += "Plain"
				if(2)
					card.name += (special_second ? special_second : "Plain")
				if(3)
					card.name += (special_third ? special_third : "Plain")
				if(4)
					card.name += (special_fourth ? special_fourth : "Plain")

			card.icon_state = "hanafuda-[target_month]-[card_num]"
			update_card_information(card)
			card.update_stored_info()

			if(card_num <= 3)
				card_num++
			else
				card_num = 1
				if(target_month <= 12)
					target_month++
		update_group_sprite()

//StG
//-//
/obj/item/card_group/stg
	desc = "A bunch of Spacemen the Griffening cards."
	card_style = "stg"
	total_cards = 40
	card_name = "Spacemen the Griffening"
	icon_state = "stg-deck-4"

	New()
		..()
		build_stg(1)

/obj/item/card_group/stg_booster
	desc = "A bunch of Spacemen the Griffening cards."
	card_style = "stg"
	total_cards = 10
	card_name = "Spacemen the Griffening"
	icon_state = "stg-deck-2"

	New()
		..()
		build_stg(0)

//Clow
//--//
/obj/item/card_group/clow
	desc = "A good set if you want to play 52 pickup."
	card_style = "clow"
	total_cards = 52
	card_name = "Clow"
	icon_state = "clow_deck_4"

	New()
		..()
		for(var/i in 1 to total_cards)
			var/obj/item/playing_card/card = new /obj/item/playing_card(src)
			stored_cards += card
			card.icon_state = "clow-1-1"
			card.name = "Clow Card #[i]"
			update_card_information(card)
			card.update_stored_info()
		update_group_sprite()

//Deck Boxes
//--------//

/obj/item/card_box //three state opening : box,open,empty
	name = "deckbox"
	desc = "a box for holding cards."
	icon = 'icons/obj/items/playing_card.dmi'
	icon_state = "white-box"
	w_class = W_CLASS_TINY
	burn_point = 220
	burn_output = 900
	burn_possible = TRUE
	health = 10
	var/obj/item/card_group/stored_deck
	var/box_style = "white"

	New()
		..()
		icon_state = "[box_style]-box"

	attack_self(mob/user as mob)
		if(icon_state == "[box_style]-box")
			if(stored_deck)
				icon_state = "[box_style]-box-open"
			else
				icon_state = "[box_style]-box-empty"
		else
			icon_state = "[box_style]-box"

	attack_hand(mob/user)
		if((loc == user) && (icon_state == "[box_style]-box-open"))
			user.put_in_hand_or_drop(stored_deck)
			icon_state = "[box_style]-box-empty"
			stored_deck = null
		else
			..()

	attackby(obj/item/W, mob/user)
		if(!stored_deck && istype(W,/obj/item/card_group))
			user.u_equip(W)
			W.set_loc(src)
			stored_deck = W
			icon_state = "[box_style]-box-open"
		else
			..()

/obj/item/card_box/red
	name = "red deckbox"
	box_style = "red"

/obj/item/card_box/plain
	box_style = "plain"
	name = "box of cards"

	New()
		..()
		stored_deck = new /obj/item/card_group/plain

/obj/item/card_box/tarot
	name = "ornate tarot box"
	box_style = "tarot"
	w_class = W_CLASS_SMALL

	New()
		..()
		stored_deck = new /obj/item/card_group/tarot

/obj/item/card_box/hanafuda
	name = "hanafuda box"
	box_style = "hanafuda"

	New()
		..()
		stored_deck = new /obj/item/card_group/hanafuda

/obj/item/card_box/clow
	name = "\improper Clow Book"
	desc = "Contents guaranteed to not go flying off in all directions upon opening! Hopefully."
	box_style = "clow"

	New()
		..()
		stored_deck = new /obj/item/card_group/clow

/obj/item/stg_box
	name = "StG Preconstructed Deck Box"
	desc = "a pick up and play deck of StG cards!"
	icon = 'icons/obj/items/playing_card.dmi'
	icon_state = "stg-box"
	w_class = W_CLASS_SMALL
	var/obj/item/card_group/stored_deck

	New()
		..()
		stored_deck = new /obj/item/card_group/stg(src)
		update_showcase()

	proc/update_showcase()
		if(stored_deck)
			var/obj/item/playing_card/chosen_card = pick(stored_deck.stored_cards)
			UpdateOverlays(image(icon,chosen_card.icon_state,-1,chosen_card.dir),"card")
			if(chosen_card.foiled)
				UpdateOverlays(image(icon,"stg-foil",-1,chosen_card.dir),"foil")

	attack_self(mob/user as mob) //must cut open packaging before getting cards out
		if(icon_state == "stg-box")
			user.show_text("You try to tear the packaging, but it's too strong! You'll need something to cut it...","red")

	attackby(obj/item/W, mob/user)
		if((icon_state == "stg-box") && (istool(W,TOOL_CUTTING) || istool(W,TOOL_SNIPPING)))
			if(loc != user)
				user.show_text("You need to hold the box if you want enough leverage to rip it to pieces!","red")
				return
			else //dropping cards here means the user doesnt have to go through the entire action to get them
				actions.start(new /datum/action/bar/private/stg_tear(user,src),user)
		else
			..()

/datum/action/bar/private/stg_tear
	duration = 10 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	var/mob/user
	var/obj/item/card_box/card_box
	var/list/messages = list("brutally hacks at the package's exterior with a sharp object!",
	"desperately slashes a sharp object against the exterior of the StG Preconstructed Deck Box!",
	"becomes a blinding blur of motion as they send bits of cardboard packaging into the air like grotesque confetti!",
	"impales the StG Preconstructed Deck Box, gripping their sharp implement with both hands, forcing the blade down the package as if disembowling it!")

	New(User, Box)
		user = User
		card_box = Box
		..()

	onStart()
		..()
		user.visible_message(SPAN_ALERT("<b>[user.name]</b> [pick(messages)]"))

	onUpdate()
		..()
		if(card_box.loc != user)
			user.show_text("You need to hold the box if you want enough leverage to rip it to pieces!","red")
			interrupt(INTERRUPT_ALWAYS)
		if(!istool(user.equipped(),TOOL_CUTTING) && !istool(user.equipped(),TOOL_SNIPPING))
			interrupt(INTERRUPT_ALWAYS)

	onEnd()
		..()
		if(card_box.icon_state == "stg-box")
			user.visible_message(SPAN_SUCCESS("<b>[user.name]</b> has thoroughly mutilated the StG Preconstructed Deck Box and retrieves the cards from inside."))
			card_box.icon_state = "stg-box-torn"
			user.put_in_hand_or_drop(card_box.stored_deck)
			var/obj/decal/cleanable/generic/decal = make_cleanable(/obj/decal/cleanable/generic,get_turf(user.loc))
			decal.color = pick("#000000","#6f0a0a","#a0621b")
			card_box.stored_deck = null
			card_box.ClearAllOverlays()

/obj/item/stg_booster
	name = "StG Booster Pack"
	icon = 'icons/obj/items/playing_card.dmi'
	icon_state = "stg-booster"
	var/obj/item/card_group/stored_deck

	New()
		..()
		stored_deck = new /obj/item/card_group/stg_booster(src)

	attack_self(mob/user as mob)
		if(icon_state == "stg-booster")
			icon_state = "stg-booster-open"

	attack_hand(mob/user)
		if(icon_state == "stg-booster-open")
			icon_state = "stg-booster-empty"
			user.put_in_hand_or_drop(stored_deck)
			stored_deck = null
		else
			..()

/* Realistic Shuffling Ahoy! */

// The chance to pull another card from the same stack as opposed to switching,
// so the "stickyness" of the cards.
#define CARD_STICK_FACTOR 0.5

// Simulates a riffle shuffle using a markovian model.
// Why? Fuck it, I have no idea.
proc/riffle_shuffle(list/deck)
	// Determines a location near the center of the deck to split from.

	var/splitLoc = (deck.len / 2) + rand(-(deck.len) / 5, deck.len / 5)

	// Makes two lists, one for each half of the deck, then clears the original deck.
	var/list/D1 = deck.Copy(1, splitLoc)
	var/list/D2 = deck.Copy(splitLoc)
	deck.len = 0

	// Markovian model of the shuffle
	var/currentStack = rand() > 0.5
	while(length(D1) > 0 && length(D2) > 0)
		var/item

		if(currentStack)
			item = D1[1]
			D1 -= item
		else
			item = D2[1]
			D2 -= item

		deck += item
		if(rand() > CARD_STICK_FACTOR)
			currentStack = !currentStack

	// One of these will always be empty but I'm too lazy to check which is which.
	deck += D1
	deck += D2
