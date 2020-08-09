/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-=-+CARDS+-=-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/* ----- TO DO -----
 - throwing a hand/stack/deck scatters the cards
 - throwing a card has a chance of being a good throw and doing a little damage
 - cheaty stuff
 - uno?
 - add cards to hats (fedoras?) (lol)
	 ----------------- */

/datum/playing_card
	var/card_name = "playing card"
	var/card_desc = "A card, for playing some kinda game with."
	var/card_face = "blank"
	var/card_back = "suit"
	var/card_foil = 0
	var/card_data = null
	var/card_reversible = 0 // can the card be drawn reversed? ie for tarot
	var/card_reversed = 0 // IS it reversed?
	var/card_tappable = 1 // tap 2 islands for mana
	var/card_tapped = 0 // summon Fog Bank, laugh
	var/card_spooky = 0
	var/solitaire_offset = 3

	New(cardname, carddesc, cardback, cardface, cardfoil, carddata, cardreversible, cardreversed, cardtappable, cardtapped, cardspooky, cardsolitaire)
		if (cardname) src.card_name = cardname
		if (carddesc) src.card_desc = carddesc
		if (cardback) src.card_back = cardback
		if (cardface) src.card_face = cardface
		if (cardfoil) src.card_foil = cardfoil
		if (carddata) src.card_data = carddata
		if (cardreversible) src.card_reversible = cardreversible
		if (cardreversed) src.card_reversed = cardreversed
		if (cardtappable) src.card_tappable = cardtappable
		if (cardtapped) src.card_tapped = cardtapped
		if (cardspooky) src.card_spooky = cardspooky
		if (cardsolitaire) src.solitaire_offset = cardsolitaire

	proc/examine_data()
		return card_data

/obj/item/playing_cards
	name = "deck of cards"
	desc = "Some cards, all in a neat stack, for playing some kinda game with."
	icon = 'icons/obj/items/playing_card.dmi'
	icon_state = "deck-suit"
	w_class = 1.0
	force = 0
	throwforce = 0
	burn_point = 750
	burn_output = 500
	burn_possible = 1
	health = 10
	tooltip_flags = REBUILD_DIST
	inventory_counter_enabled = 1
	var/list/cards = list()
	var/face_up = 0
	var/card_name = "blank card"
	var/card_desc = "A playing card."
	var/card_face = "blank"
	var/card_back = "suit"
	var/card_foil = 0
	var/card_data = null
	var/last_shown_off = null
	var/spooky = 0
	var/card_reversible = 0 // can it be drawn reversed?
	var/card_reversed = 0 // IS it reversed?
	var/card_tappable = 1 // tap dat shit
	var/card_tapped = 0
	var/solitaire_offset = 0 //any number : used for stacking cards with a specific negative y offset(like solitaire)

	New()
		..()
		src.pixel_x = rand(-12, 12)
		src.pixel_y = rand(-12, 12)

	proc/update_cards()
		if (!src.cards.len)
			qdel(src)
			return
		tooltip_rebuild = 1
		src.overlays = null
		switch (src.cards.len)
			if (-INFINITY to 0)
				qdel(src)
				return
			if (1)
				for (var/datum/playing_card/Card in src.cards)
					src.card_name = Card.card_name
					src.card_desc = Card.card_desc
					src.card_face = Card.card_face
					src.card_back = Card.card_back
					src.card_foil = Card.card_foil
					src.card_data = Card.examine_data()
					src.card_reversible = Card.card_reversible
					src.card_reversed = Card.card_reversed
					src.spooky = Card.card_spooky
					src.solitaire_offset = Card.solitaire_offset
				if (src.face_up)
					if (src.card_reversible && src.card_reversed)
						src.name = "reversed [src.card_name]"
						src.dir = NORTH
					else if (src.card_tappable && src.card_tapped)
						src.name = "tapped [src.card_name]"
						if (src.card_tapped == EAST)
							src.dir = EAST
						else if (src.card_tapped == WEST)
							src.dir = WEST
						else
							src.dir = pick(EAST, WEST)
							src.card_tapped = src.dir
					else
						src.name = src.card_name
						src.dir = SOUTH
					src.desc = "[src.card_desc] It's \an [src.name]."
					src.icon_state = "card-[src.card_face]"
					if (src.card_foil)
						src.overlays += "card-foil"
				else
					src.desc = src.card_desc
					src.icon_state = "back-[src.card_back]"
					if (src.card_tappable && src.card_tapped)
						src.name = "tapped playing card"
						if (src.card_tapped == EAST)
							src.dir = EAST
						else if (src.card_tapped == WEST)
							src.dir = WEST
						else
							src.dir = pick(EAST, WEST)
							src.card_tapped = src.dir
					else
						src.name = "playing card"
						src.dir = SOUTH
			if (2 to 4)
				src.name = "hand of cards"
				src.desc = "Some cards, for playing some kinda game with."
				src.icon_state = "hand-[src.card_back][src.cards.len]"
				if (src.face_up)
					src.face_up = 0
			if (5 to 10)
				src.name = "hand of cards"
				src.desc = "Some cards, for playing some kinda game with."
				src.icon_state = "hand-[src.card_back]5"
				if (src.face_up)
					src.face_up = 0
			if (11 to 19)
				src.name = "stack of cards"
				src.desc = "Some cards, all in a neat stack, for playing some kinda game with."
				src.icon_state = "stack-[src.card_back]"
				if (src.face_up)
					src.face_up = 0
			if (20 to INFINITY)
				src.name = "deck of cards"
				src.desc = "Some cards, all in a neat stack, for playing some kinda game with."
				src.icon_state = "deck-[src.card_back]"
				if (src.face_up)
					src.face_up = 0

		src.inventory_counter.update_number(src.cards.len)

	proc/draw_card(var/obj/item/playing_cards/CardStack, var/atom/target as turf|obj|mob, var/draw_face_up = 0, var/datum/playing_card/Card)
		if (!src.cards.len)
			qdel(src)
			return null

		if (!CardStack || !istype(CardStack, /obj/item/playing_cards))
			CardStack = new /obj/item/playing_cards(src.loc)
			CardStack.face_up = draw_face_up
			if (target)
				if (ismob(target))
					target:put_in_hand_or_drop(CardStack)
				else if (isturf(target))
					CardStack.set_loc(target)
				else
					CardStack.set_loc(target.loc)
		if (!Card || !istype(Card, /datum/playing_card))
			Card = src.cards[1]
		CardStack.cards += Card
		src.cards -= Card
		CardStack.update_cards()
		src.update_cards()
		return CardStack

	proc/add_cards(var/obj/item/playing_cards/CardStack)
		if (!CardStack)
			return
		if (!CardStack.cards.len)
			qdel(CardStack)
			return

		for (var/datum/playing_card/Card in CardStack.cards)
			Card = CardStack.cards[1]
			src.cards += Card
			CardStack.cards -= Card
			CardStack.update_cards()
			src.update_cards()

	get_desc(dist)
		src.update_cards()
		if (dist <= 0 && src.cards.len == 1 && !src.face_up)
			. += "It's \an [src.card_name]."
		if (src.cards.len == 1 && src.face_up)
			var/datum/playing_card/Card = src.cards[1]
			. += Card.examine_data()
		if (dist <= 0 && src.cards.len >= 2 && src.cards.len <= 10)
			var/seen_hand = ""
			for (var/datum/playing_card/Card in src.cards)
				seen_hand += "\an [Card.card_name] <br>"
			var/final_seen_hand = copytext(seen_hand, 1, -2)
			. += "<b>It has [src.cards.len] cards:</b><br> [final_seen_hand]"
		if (dist <= 0 && src.cards.len >= 11)
			. += "There's [src.cards.len] cards in the [src.cards.len <= 19 ? "stack" : "deck"]."

	MouseDrop(var/atom/target as obj|mob)
		if (!src.cards.len)
			qdel(src)
			return
		if (!target)
			return
		if (isdead(usr) && !src.spooky)
			boutput(usr, "<span class='alert'>Ghosts dealing cards? That's too spooky!</span>")
			return
		if (get_dist(usr, src) > 1)
			boutput(usr, "<span class='alert'>You're too far from [src] to draw a card!</span>")
			return
		if (get_dist(usr, target) > 1)
			if (istype(target, /obj/screen/hud))
				var/obj/screen/hud/hud = target
				if (istype(hud.master, /datum/hud/human))
					var/datum/hud/human/h_hud = hud.master // all this just to see if you're trying to deal to someone's hand, ffs
					if (h_hud.master && h_hud.master == usr) // or their face, I guess.  it'll apply to any attempts to deal to your hud
						target = usr
					else
						boutput(usr, "<span class='alert'>You're too far away from [target] to deal a card!</span>")
						return
				else
					boutput(usr, "<span class='alert'>You're too far away from [target] to deal a card!</span>")
					return
			else
				boutput(usr, "<span class='alert'>You're too far away from [target] to deal a card!</span>")
				return

		var/deal_face_up = 0
		var/datum/playing_card/Card = src.cards[1]
		if (usr.a_intent != INTENT_HELP)
			deal_face_up = 1
		if (usr.a_intent == INTENT_GRAB && src.cards.len > 1)
			usr.visible_message("<span class='notice'><b>[usr]</b> looks through [src].</span>",\
			"<span class='notice'>You look through [src].</span>")
			deal_face_up = 0
			var/list/availableCards = list()
			for (var/datum/playing_card/listCard in src.cards)
				availableCards += "[listCard.card_name]"
			boutput(usr, "<span class='notice'>What card would you like to deal from [src]?</span>")
			availableCards = sortList(availableCards)
			var/chosenCard = input("Select a card to deal.", "Choose Card") as null|anything in availableCards
			if (!chosenCard)
				return
			for (var/datum/playing_card/findCard in src.cards)
				if (findCard.card_name == chosenCard)
					Card = findCard
					break

		var/stupid_var = "[deal_face_up ? "\an [Card.card_name]" : "[src]"]"
		var/other_stupid_var = "[deal_face_up ? " \an [Card.card_name]." : "a card"]"

		if (src.cards.len == 1)
			if (target == src && src.card_tappable)
				if (src.card_tapped)
					usr.visible_message("<span class='notice'><b>[usr]</b> untaps [src].</span>",\
					"<span class='notice'>You untap [src].</span>")
					src.card_tapped = null
					src.update_cards()
				else
					usr.visible_message("<span class='notice'><b>[usr]</b> taps [src].</span>",\
					"<span class='notice'>You tap [src].</span>")
					src.card_tapped = pick(EAST, WEST)
					src.update_cards()
			else if (ismob(target))
				usr.tri_message("<span class='notice'><b>[usr]</b> takes [stupid_var][usr == target ? "." : " and deals it to [target]."]</span>",\
				usr, "<span class='notice'>You take [stupid_var][usr == target ? "." : " and deal it to [target]."]</span>", \
				target, "<span class='notice'>[target == usr ? "You take" : "<b>[usr]</b> takes"] [stupid_var][target == usr ? "." : " and deals it to you."]</span>")
				src.draw_card(null, target, deal_face_up, Card)
			else if (istype(target, /obj/table))
				usr.visible_message("<span class='notice'><b>[usr]</b> takes [stupid_var] and places it on [target].</span>",\
				"<span class='notice'>You take [stupid_var] and place it on [target].</span>")
				src.draw_card(null, target, deal_face_up, Card)
			else if (istype(target, /obj/item/playing_cards))
				usr.visible_message("<span class='notice'><b>[usr]</b> takes [stupid_var] and adds it to [target].</span>",\
				"<span class='notice'>You take [stupid_var] and add it to [target].</span>")
				src.draw_card(target, null, deal_face_up, Card)
			else
				boutput(usr, "<span class='alert'>What exactly are you trying to accomplish by giving [target] a card? [target] can't use it!</span>")
				return

		else
			if (ismob(target))
				usr.tri_message("<span class='notice'><b>[usr]</b> draws [other_stupid_var] from [src][usr == target ? "." : " and deals it to [target]."]</span>",\
				usr, "<span class='notice'>You draw [other_stupid_var] from [src][usr == target ? "." : " and deal it to [target]."]</span>", \
				target, "<span class='notice'>[target == usr ? "You draw" : "<b>[usr]</b> draws"] a card from [src][target == usr ? "." : " and deals it to you."]</span>")
				src.draw_card(null, target, deal_face_up, Card)
			else if (istype(target, /obj/table) || istype(target, /turf/simulated/floor) || istype(target,/turf/unsimulated/floor))
				usr.visible_message("<span class='notice'><b>[usr]</b> draws [other_stupid_var] from [src] and places it on [target].</span>",\
				"<span class='notice'>You draw [other_stupid_var] from [src] and place it on [target]. [other_stupid_var]</span>")
				src.draw_card(null, target, deal_face_up, Card)
			else if (istype(target, /obj/item/playing_cards))
				usr.visible_message("<span class='notice'><b>[usr]</b> draws [other_stupid_var] from [src] and adds it to [target].</span>",\
				"<span class='notice'>You draw [other_stupid_var] from [src] and add it to [target].</span>")
				src.draw_card(target, null, deal_face_up, Card)
			else
				boutput(usr, "<span class='alert'>What exactly are you trying to accomplish by dealing [target] a card? [target] can't use it!</span>")
				return

	attack_hand(mob/user as mob)
		if (get_dist(user, src) <= 0 && src.cards.len)
			if (user.l_hand == src || user.r_hand == src)
				var/draw_face_up = 0
				if (user.a_intent != INTENT_HELP)
					draw_face_up = 1
				if (user.a_intent == INTENT_GRAB && src.cards.len > 1)
					user.visible_message("<span class='notice'><b>[user]</b> looks through [src].</span>",\
					"<span class='notice'>You look through [src].</span>")
					var/list/availableCards = list()
					for (var/datum/playing_card/Card in src.cards)
						availableCards += "[Card.card_name]"
					boutput(user, "<span class='notice'>What card would you like to draw from [src]?</span>")
					var/chosenCard = input("Select a card to draw.", "Choose Card") as null|anything in availableCards
					if (!chosenCard)
						return
					var/datum/playing_card/cardToGive
					for (var/datum/playing_card/Card in src.cards) // this is so shitty and janky but idgaf right now -barf-
						if (Card.card_name == chosenCard)
							cardToGive = Card
							break
					if (!cardToGive)
						return
					user.visible_message("<span class='notice'><b>[usr]</b> draws a card from [src].</span>",\
					"<span class='notice'>You draw \an [chosenCard] from [src].</span>")
					src.draw_card(null, user, draw_face_up, cardToGive)
				else
					var/datum/playing_card/Card = src.cards[1]
					user.visible_message("<span class='notice'><b>[usr]</b> draws [draw_face_up ? "\an [Card.card_name]" : "a card"] from [src].</span>",\
					"<span class='notice'>You draw [draw_face_up ? "\an [Card.card_name]" : "a card"] from [src].</span>")
					src.draw_card(null, user, draw_face_up)
			else return ..(user)
		else return ..(user)

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/playing_cards))
			var/obj/item/playing_cards/C = W
			if(user.a_intent == "disarm")
				user.u_equip(C)
				C.set_loc(src.loc)
				C.pixel_x = src.pixel_x
				C.pixel_y = (src.pixel_y - C.solitaire_offset)
			else
				src.add_cards(C)
				user.visible_message("<span class='notice'><b>[user]</b> adds [C] to the bottom of [src].</span>",\
				"<span class='notice'>You add [C] to the bottom of [src].</span>")
		else return ..()

	attack_self(mob/user as mob)
		if (!src.cards.len)
			qdel(src)
			return
		if ((src.last_shown_off + 10) > world.time)
			return
		switch (src.cards.len)
			if (1)
				src.face_up = !(src.face_up)
				src.update_cards()
				user.visible_message("<span class='notice'><b>[user]</b> flips the card [src.face_up ? "face up. It's \an [src.name]." : "face down."]</span>",\
				"<span class='notice'>You flip the card [src.face_up ? "face up. It's \an [src.name]." : "face down."]</span>")
				src.last_shown_off = world.time
			if (2 to 10)
				var/shown_hand = ""
				for (var/datum/playing_card/Card in src.cards)
					shown_hand += "\an [Card.card_name], "
				var/final_shown_hand = copytext(shown_hand, 1, -2)
				user.visible_message("<span class='notice'><b>[user]</b> shows their hand: [final_shown_hand].</span>",\
				"<span class='notice'>You show your hand: [final_shown_hand].</span>")
				src.last_shown_off = world.time
			if (11 to INFINITY)
				riffle_shuffle(src.cards)
				for (var/datum/playing_card/Card in src.cards)
					if (Card.card_reversible)
						Card.card_reversed = rand(0, 1)
				user.visible_message("<span class='notice'><b>[user]</b> shuffles [src].</span>",\
				"<span class='notice'>You shuffle [src].</span>")
				src.last_shown_off = world.time

	afterattack(var/atom/A as turf, var/mob/user as mob, reach, params)
		if(istype(A,/turf/simulated/floor) || istype(A,/turf/unsimulated/floor))
			user.u_equip(src)
			src.set_loc(A)
			if (islist(params) && params["icon-y"] && params["icon-x"])
				src.pixel_x = text2num(params["icon-x"]) - 16
				src.pixel_y = text2num(params["icon-y"]) - 16
		else
			..()

/obj/item/playing_cards/suit
	desc = "Some playing cards, all in a neat stack. Each belongs to one of four suits and has a number. Collect all 52!"
	icon_state = "deck-suit"
	card_back = "suit"
	var/list/card_suits = list("hearts", "diamonds", "clubs", "spades")
	var/list/card_numbers = list("ace", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "jack", "queen", "king")

	New()
		..()
		var/datum/playing_card/Card
		for (var/suit in src.card_suits)
			for (var/num in src.card_numbers)
				Card = new()
				Card.card_name = "[num] of [suit]"
				Card.card_desc = "A classic playing card."
				Card.card_back = "suit"
				if (suit == "hearts" || suit == "diamonds")
					if (num == "jack" || num == "queen" || num == "king")
						Card.card_face = "R-face"
					else
						Card.card_face = "R-[num]"
				else
					if (num == "jack" || num == "queen" || num == "king")
						Card.card_face = "B-face"
					else
						Card.card_face = "B-[num]"
				src.cards += Card
		src.update_cards()

/obj/item/playing_cards/tarot
	desc = "Some tarot cards, all in a neat stack. What will the cards tell you?"
	icon_state = "deck-tarot"
	card_back = "tarot"
	var/list/card_major_arcana = list("The Fool - O", "The Magician - I", "The High Priestess - II", "The Empress - III", "The Emperor - IV", "The Hierophant - V",\
	"The Lovers - VI", "The Chariot - VII", "Justice - VIII", "The Hermit - IX", "Wheel of Fortune - X", "Strength - XI", "The Hanged Man - XII", "Death - XIII", "Temperance - XIV",\
	"The Devil - XV", "The Tower - XVI", "The Star - XVII", "The Moon - XVIII", "The Sun - XIX", "Judgement - XX", "The World - XXI")
	var/list/card_minor_arcana_suits = list("wands", "coins", "cups", "swords")
	var/list/card_minor_arcana_numbers = list("ace", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "page", "knight", "queen", "king")

	New()
		..()
		var/datum/playing_card/Card
		for (var/major in src.card_major_arcana)
			Card = new()
			Card.card_name = "[major]"
			Card.card_desc = "A tarot card."
			Card.card_back = "tarot"
			Card.card_face = "tarot[rand(1, 10)]"
			Card.card_reversible = 1
			if (src.spooky) Card.card_spooky = 1
			src.cards += Card

		for (var/minor in src.card_minor_arcana_suits)
			for (var/num in src.card_minor_arcana_numbers)
				Card = new()
				Card.card_name = "[num] of [minor]"
				Card.card_desc = "A tarot card."
				Card.card_back = "tarot"
				Card.card_reversible = 1
				if (src.spooky) Card.card_spooky = 1
				if (minor == "cups" || minor == "coins")
					if (num == "page" || num == "knight" || num == "queen" || num == "king")
						Card.card_face = "R-face"
					else
						Card.card_face = "R-[num]"
				else
					if (num == "page" || num == "knight" || num == "queen" || num == "king")
						Card.card_face = "B-face"
					else
						Card.card_face = "B-[num]"
				src.cards += Card

/obj/item/playing_cards/tarot/spooky
	spooky = 1

/obj/item/playing_cards/hanafuda
	desc = "Some hanafuda cards, all in a neat stack."
	icon_state = "deck-hanafuda"
	card_back = "hanafuda"

	var/datum/playing_card/Card
	New()
		..()
		var/card_num = 1
		var/target_month = 1
		for(var/i=1,i<=48,i++)
			Card = new()
			Card.card_back = "hanafuda"
			Card.card_desc = "a card for playing hanafuda!"
			Card.solitaire_offset = 5
			var/special_second
			var/special_third
			var/special_fourth

			switch(target_month)
				if(1)
					Card.card_name = "January : "
					special_third = "Poetry Slip"
					special_fourth = "Bright : Crane"
				if(2)
					Card.card_name = "February : "
					special_third = "Poetry Slip"
					special_fourth = "Animal : Bush Warbler"
				if(3)
					Card.card_name = "March : "
					special_third = "Poetry Slip"
					special_fourth = "Bright : Curtain"
				if(4)
					Card.card_name = "April : "
					special_third = "Red Ribbon"
					special_fourth = "Animal : Cuckoo"
				if(5)
					Card.card_name = "May : "
					special_third = "Blue Ribbon"
					special_fourth = "Animal : Butterfly"
				if(6)
					Card.card_name = "June : "
					special_third = "Red Ribbon"
					special_fourth = "Animal : Eight-Plank Bridge"
				if(7)
					Card.card_name = "July : "
					special_third = "Red Ribbon"
					special_fourth = "Animal : Boar"
				if(8)
					Card.card_name = "August : "
					special_third = "Animal : Geese"
					special_fourth = "Bright : Moon"
				if(9)
					Card.card_name = "September : "
					special_third = "Blue Ribbon"
					special_fourth = "Animal/Plain : Sake Cup"
				if(10)
					Card.card_name = "October : "
					special_third = "Blue Ribbon"
					special_fourth = "Animal : Deer"
				if(11)
					Card.card_name = "November : "
					special_second = "Red Ribbon"
					special_third = "Animal : Swallow"
					special_fourth = "Bright : Rain Man"
				if(12)
					Card.card_name = "December : "
					special_fourth = "Bright : Phoenix"

			switch(card_num)
				if(1)
					Card.card_name += "Plain"
				if(2)
					Card.card_name += (special_second ? special_second : "Plain")
				if(3)
					Card.card_name += (special_third ? special_third : "Plain")
				if(4)
					Card.card_name += (special_fourth ? special_fourth : "Plain")

			Card.card_face = "[target_month]-[card_num]"
			src.cards += Card

			if(card_num <= 3)
				card_num++
			else
				card_num = 1
				if(target_month <= 12)
					target_month++

// Traitor Trading Triumvirate?

/obj/item/playing_cards/trading
	name = "\improper Spacemen the Grifening deck"
	desc = "Some trading cards, all in a neat stack. Buy a booster brick today!"
	icon_state = "deck-trade"
	card_back = "trade"
	var/cards_to_generate = 40
	var/list/card_human = list()
	var/list/card_cyborg = list()
	var/list/card_ai = list()
	var/list/card_type_mob = list()
	var/list/card_type_friend = list()
	var/list/card_type_effect = list()
	var/list/card_type_area = list()
	/*var/list/card_nonhuman = list("Changeling", "Wraith")
	var/list/card_antag = list("Traitor", "Nuclear Operative", "Vampire", "Wizard", "Spy", "Revolutionary")
	var/list/card_friend = list("Hooty McJudgementowl", "Heisenbee", "THE OVERBEE", "Dr. Acula", "Jones", "boogiebot",	"George", "automaton",\
	"Murray", "Marty", "Remy", "Mr. Muggles", "Mrs. Muggles", "Mr. Rathen", "????", "Klaus", "Ol' Harner", "Officer Beepsky", "Tanhony",\
	"Krimpus", "Albert", "fat and sassy space bee", "Bombini")
	var/list/card_weapon = list("cyalume saber", "Russian revolver", "emergency toolbox", "mechanical toolbox", "electrical toolbox", "artistic toolbox",\
	"His Grace", "wrestling belt", "sleepy pen", "energy gun", "riot shotgun", "welding tool", "staple gun", "scalpel", "circular saw", "wrench",\
	"red chainsaw", "chainsaw", "stun baton", "phaser gun", "mini rad-poison-crossbow", "suppressed .22 pistol", "fire extinguisher", "crowbar",\
	"laser gun", "screwdriver", "riot launcher", "grenade", "rolling pin", "beaker full of hellchems", "canister bomb", "tank transfer valve bomb",\
	"broken bottle", "glass shard", "metal rods", "axe", "butcher's knife")
	var/list/card_armor = list("bio suit", "bio hood", "armored bio suit", "paramedic suit", "armored paramedic suit", "firesuit", "gas mask",\
	"emergency gas mask", "hard hat", "emergency suit", "emergency hood", "space suit", "labcoat", "armor vest", "Head of Security's beret",\
	"Head of Security's hat", "captain's armor", "captain's hat", "captain's space suit", "red space suit", "helmet", "bomb disposal suit",\
	"sunglasses", "prescription glasses", "ProDoc Healthgoggles", "Spectroscopic Scanner Goggles", "Optical Meson Scanner", "Optical Thermal Scanner",\
	"latex gloves", "insulated gloves", "bedsheet", "bedsheet cape")*/

	booster
		name = "\improper Spacemen the Grifening booster pack"
		desc = "10 trading cards, in a neat little pack. Collect them all today!"
		icon_state = "pack-trade"
		cards_to_generate = 10

	New()
		..()
		src.generate_lists() // generate lists to make cards out of
		for (var/i=0, i < src.cards_to_generate, i++) // try to make cards
			switch(rand(1,10))
				if (1 to 4)
					generate_mob_card()
				if (5 to 7)
					generate_effect_card()
				if (8 to 9)
					generate_friend_card()
				if (10)
					generate_area_card()
		src.update_cards() // update the appearance of the deck

	proc/generate_lists()
		src.card_human = list()
		src.card_cyborg = list()
		src.card_ai = list()
		for (var/mob/living/carbon/human/H in mobs)
			if (ismonkey(H))
				continue
			if (iswizard(H))
				continue
			if (isnukeop(H))
				continue
			src.card_human += H
		for (var/mob/living/silicon/robot/R in mobs)
			src.card_cyborg += R
		for (var/mob/living/silicon/ai/A in AIs)
			src.card_ai += A
		card_type_mob = childrentypesof(/datum/playing_card/griffening/creature/mob)
		card_type_friend = childrentypesof(/datum/playing_card/griffening/creature/friend)
		card_type_effect = childrentypesof(/datum/playing_card/griffening/effect)
		card_type_area = childrentypesof(/datum/playing_card/griffening/area)

	proc/generate_mob_card()
		if (!src.card_human.len || !src.card_ai.len || !src.card_cyborg.len)
			src.generate_lists()
			if (!src.card_human.len)
				return 0

		var/card_type = null
		if (prob(20))
			card_type = /datum/playing_card/griffening/creature/mob/assistant
		else
			card_type = pick(card_type_mob)
			card_type_mob -= card_type

		var/datum/playing_card/griffening/creature/mob/Card = new card_type()
		Card.card_back = "trade"
		if (prob(10))
			Card.card_foil = 1
		if (istype(Card, /datum/playing_card/griffening/creature/mob/ai))
			Card.card_face = "trade-ai[rand(1, 2)]"
			var/mob/living/silicon/ai/A
			if (card_ai.len)
				A = pick(card_ai)
			var/ai_name
			if (!A)
				ai_name = pick("SHODAN", "GLADOS", "HAL-9000")
			else
				card_ai -= A
				ai_name = A.name
			Card.card_name = "[Card.card_foil ? "foil " : null]AI [ai_name]"
		else if (istype(Card, /datum/playing_card/griffening/creature/mob/cyborg))
			Card.card_face = "trade-borg[rand(1,2)]"
			var/mob/living/silicon/robot/A
			if (card_cyborg.len)
				A = pick(card_cyborg)
			var/robot_name
			if (!A)
				robot_name = "Cyborg [pick("Alpha", "Beta", "Gamma", "Delta", "Xi", "Pi", "Theta")]-[rand(10,99)]"
			else
				card_cyborg -= A
				robot_name = A.name
			if (copytext(robot_name, 1, 8) == "Cyborg ")
				robot_name = copytext(robot_name, 8)
			Card.card_name = "[Card.card_foil ? "foil " : null]Cyborg [robot_name]"
		else
			Card.card_face = "trade-person[rand(1, 10)]"
			var/mob/living/carbon/human/A
			if (card_human.len)
				A = pick(card_human)
			var/human_name
			if (!A)
				human_name = "[pick("Pubbie", "Robust", "Shitty", "Father", "Mother", "Handsome")] [pick("Joe", "Jack", "Bill", "Robert", "Luis", "Damian", "Mike", "Jason", "Jane", "Janet", "Oprah", "Angelina", "Megan", "Jennifer", "Anna")]"
			else
				card_human -= A
				human_name = A.name
			Card.card_name = "[Card.card_foil ? "foil " : null][Card.card_name] [human_name]"

		if (Card.randomized_stats)
			// TODO: This will be unbalanced.
			Card.LVL = rand(0, 10)
			Card.ATK = rand(0, 10) * Card.LVL
			Card.DEF = rand(0, 10) * Card.LVL

		src.cards += Card

		// I'm temporarily disabling a lot of this until I get everything set up. - Marq
		/*

		var/datum/playing_card/griffening/mob/Card = new()
		Card.card_desc = "A trading card."
		Card.card_back = "trade"
		Card.card_face = "trade-person[rand(1, 10)]"
		var/LVL = rand(0, 10)
		var/ATK = rand(0, 10) * max(LVL, 1) // if the level's 0 we want the stats to not all be 0
		var/DEF = rand(0, 10) * max(LVL, 1)
		Card.LVL = LVL
		Card.ATK = ATK
		Card.DEF = DEF
		Card.attributes = ATTRIBUTE_DEFAULT
		Card.card_data += "ATK [ATK] | DEF [DEF]"
		if (prob(10))
			Card.card_foil = 1

		var/mob/living/carbon/human/H = pick(src.card_human)

		var/job_name
		var/is_human = 1

		if (prob(5))
			var/nonhuman_chance = 100 * (card_nonhuman.len / (card_nonhuman.len + card_antag.len))
			if (prob(nonhuman_chance))
				job_name = pick(src.card_nonhuman)
				is_human = 0
			else
				job_name = pick(src.card_antag)
		else
			var/datum/job/J
			if (prob(10))
				J = pick(job_controls.special_jobs)
			else
				J = pick(job_controls.staple_jobs)
			job_name = J.name

		if (is_human)
			Card.template = generate_human_image(H)
		else
			Card.template = generate_special_mob_image(H, job_name)
			Card.human = 0

		Card.card_name = "[Card.card_foil ? "foil " : ""]LVL [LVL] [job_name] [H.real_name]"

		src.cards += Card
		src.card_human -= H*/
		return 1

	proc/generate_human_image(var/mob/living/carbon/human/H)
		// Human images are obnoxious.
		var/image/ret = image('icons/mob/human.dmi', "blank", MOB_LIMB_LAYER)
		var/image/human_image = H.human_image
		var/skin_tone = H.bioHolder.mobAppearance.s_tone
		human_image.color = skin_tone
		var/gender_t = H.gender == FEMALE ? "f" : "m"
		human_image.icon_state = "chest_[gender_t]"
		ret.overlays += human_image
		human_image.icon_state = "groin_[gender_t]"
		ret.overlays += human_image
		human_image.icon_state = "head"
		ret.overlays += human_image
		human_image.icon_state = "l_arm"
		ret.overlays += human_image
		human_image.icon_state = "r_arm"
		ret.overlays += human_image
		human_image.icon_state = "l_leg"
		ret.overlays += human_image
		human_image.icon_state = "r_leg"
		ret.overlays += human_image
		human_image.icon_state = "hand_right"
		ret.overlays += human_image
		human_image.icon_state = "hand_left"
		ret.overlays += human_image
		human_image.icon_state = "foot_left"
		ret.overlays += human_image
		human_image.icon_state = "foot_right"
		ret.overlays += human_image
		var/image/he_image = image('icons/mob/human_hair.dmi', layer = MOB_FACE_LAYER)
		var/image/bd_image = image('icons/mob/human_hair.dmi', layer = MOB_FACE_LAYER)
		he_image.icon_state = "eyes"
		he_image.color = H.bioHolder.mobAppearance.e_color
		ret.overlays += he_image
		he_image.layer = MOB_HAIR_LAYER2
		he_image.icon_state = "[H.cust_one_state]"
		he_image.color = H.bioHolder.mobAppearance.customization_first_color
		ret.overlays += he_image
		bd_image.icon_state = "[H.cust_two_state]"
		bd_image.color = H.bioHolder.mobAppearance.customization_second_color
		ret.overlays += bd_image
		bd_image.layer = MOB_HAIR_LAYER2
		bd_image.icon_state = "[H.cust_three_state]"
		bd_image.color = H.bioHolder.mobAppearance.customization_third_color
		ret.overlays += bd_image
		return ret

	proc/generate_special_mob_image(var/mob/living/carbon/human/H, var/job_name)
		switch (job_name)
			if ("Wraith")
				return image('icons/mob/mob.dmi', "wraith")
			if ("Changeling")
				return generate_human_image(H)

	/*proc/generate_cyborg_card()
		if (!src.card_cyborg.len)
			return 0

		var/datum/playing_card/griffening/mob/Card = new()
		Card.card_desc = "A trading card."
		Card.card_back = "trade"
		Card.card_face = "trade-borg[rand(1, 2)]"
		var/LVL = rand(0, 10)
		var/ATK = rand(0, 10) * max(LVL, 1)
		var/DEF = rand(0, 10) * max(LVL, 1)
		Card.card_data += "ATK [ATK] | DEF [DEF]"
		if (prob(10))
			Card.card_foil = 1

		var/mob/living/silicon/robot/R = pick(src.card_cyborg)
		if (prob(5))
			Card.card_name = "[Card.card_foil ? "foil " : ""]LVL [LVL] Emagged Cyborg [R.name]"
		else
			Card.card_name = "[Card.card_foil ? "foil " : ""]LVL [LVL] Cyborg [R.name]"

		src.cards += Card
		src.card_cyborg -= R
		return 1

	proc/generate_ai_card()
		if (!src.card_ai.len)
			return 0

		var/datum/playing_card/Card = new()
		Card.card_desc = "A trading card."
		Card.card_back = "trade"
		Card.card_face = "trade-ai[rand(1, 2)]"
		var/LVL = rand(0, 10)
		var/ATK = rand(0, 10) * max(LVL, 1)
		var/DEF = rand(0, 10) * max(LVL, 1)
		Card.card_data += "ATK [ATK] | DEF [DEF]"
		if (prob(10))
			Card.card_foil = 1

		var/mob/living/silicon/ai/A = pick(src.card_ai)
		if (prob(5))
			Card.card_name = "[Card.card_foil ? "foil " : ""]LVL [LVL] Subverted AI [A.name]"
		else
			Card.card_name = "[Card.card_foil ? "foil " : ""]LVL [LVL] AI [A.name]"

		src.cards += Card
		src.card_ai -= A
		return 1*/

	proc/generate_friend_card()
		if (!src.card_type_friend.len)
			return 0

		var/card_type = pick(card_type_friend)
		var/datum/playing_card/griffening/creature/friend/Card = new card_type()
		Card.card_back = "trade"
		Card.card_face = "trade-general[rand(1, 8)]"
		Card.LVL = rand(0, 10)
		Card.ATK = rand(0, 10) * max(Card.LVL, 1)
		Card.DEF = rand(0, 10) * max(Card.LVL, 1)
		if (prob(10))
			Card.card_foil = 1

		Card.card_name = "[Card.card_foil ? "foil " : ""][Card.card_name]"

		src.cards += Card
		src.card_type_friend -= card_type
		return 1

	proc/generate_area_card()
		if (!src.card_type_area.len)
			return 0

		var/card_type = pick(card_type_area)
		var/datum/playing_card/griffening/area/Card = new card_type()
		Card.card_back = "trade"
		Card.card_face = "trade-general[rand(1, 8)]"
		if (prob(10))
			Card.card_foil = 1

		Card.card_name = "[Card.card_foil ? "foil " : ""][Card.card_name]"

		src.cards += Card
		return 1

	proc/generate_effect_card()
		if (!src.card_type_effect.len)
			return 0

		var/card_type = pick(card_type_effect)
		var/datum/playing_card/griffening/effect/Card = new card_type()
		Card.card_back = "trade"
		Card.card_face = "trade-general[rand(1, 8)]"
		if (prob(10))
			Card.card_foil = 1

		Card.card_name = "[Card.card_foil ? "foil " : ""][Card.card_name]"

		src.cards += Card
		return 1

/obj/item/playing_cards/clow
	desc = "A good set if you want to play 52 pickup."
	icon_state = "deck-clow"
	card_back = "clow"

	New()
		..()
		var/datum/playing_card/Card
		for (var/i = 1, i <= 52, i++)
			Card = new()
			Card.card_name = "\improper Clow card #[i]"
			Card.card_desc = "Are these supposed to be blank?"
			Card.card_back = "clow"
			Card.card_face = "clow1"
			src.cards += Card

/obj/item/card_box
	name = "deck box"
	desc = "A little cardboard box for keeping card decks in. Woah! We're truly in the future with technology like this."
	icon = 'icons/obj/items/playing_card.dmi'
	icon_state = "box"
	force = 1
	throwforce = 1
	w_class = 2
	var/obj/item/playing_cards/Cards
	var/open = 0
	var/icon_closed = "box"
	var/icon_open = "box-open"
	var/icon_empty = "box-empty"
	var/reusable = 1
	var/box_size = 120

	suit
		name = "box of playing cards"
		desc = "A little cardboard box with a standard 52-card deck in it."
		icon_state = "box-suit"
		icon_closed = "box-suit"
		icon_open = "box-suit-open"
		icon_empty = "box-suit-empty"
		box_size = 60

		New()
			..()
			src.Cards = new /obj/item/playing_cards/suit(src)

	tarot
		name = "box of tarot cards"
		desc = "A little cardboard box with a 78-card tarot deck in it."
		icon_state = "box-tarot"
		icon_closed = "box-tarot"
		icon_open = "box-tarot-open"
		icon_empty = "box-tarot-empty"
		box_size = 80

		New()
			..()
			src.Cards = new /obj/item/playing_cards/tarot(src)

	trading
		name = "\improper Spacemen the Grifening deck box"
		desc = "A little cardboard box with an StG deck in it! Wow!"
		icon_state = "box-trade"
		icon_closed = "box-trade"
		icon_open = "box-trade-open"
		icon_empty = "box-trade-empty"
		box_size = 75 // A 60 card deck plus a 15 card sideboard. Yep, it's a Magic joke.

		New()
			..()
			src.Cards = new /obj/item/playing_cards/trading(src)

	booster
		name = "\improper Spacemen the Grifening booster pack"
		desc = "A little pack that has more cards to perfect your StG decks with!"
		icon_state = "pack-trade"
		icon_closed = "pack-trade"
		icon_open = "pack-trade-open"
		icon_empty = "pack-trade-empty"
		reusable = 0
		New()
			..()
			src.Cards = new /obj/item/playing_cards/trading/booster(src)

	storage
		name = "trading card storage box"
		desc = "A plain white box for storing a lot of playing cards."
		icon_state = "box"
		icon_closed = "box"
		icon_open = "box-open"
		icon_empty = "box-empty"
		box_size = 400

	clow
		name = "\improper Clow Book"
		desc = "Contents guaranteed to not go flying off in all directions upon opening! Hopefully."
		icon_state = "box-clow"
		icon_closed = "box-clow"
		icon_open = "box-clow-open"
		icon_empty = "box-clow-empty"

		New()
			..()
			src.Cards = new /obj/item/playing_cards/clow(src)

	hanafuda
		name = "box of hanafuda cards"
		desc = "A little box of full-art hanafuda cards."
		icon_state = "box-hanafuda"
		icon_closed = "box-hanafuda"
		icon_open = "box-hanafuda-open"
		icon_empty = "box-hanafuda-empty"

		New()
			..()
			src.Cards = new /obj/item/playing_cards/hanafuda(src)


	attack_self(mob/user as mob)
		if (src.reusable)
			src.open = !src.open
		else if (!src.open)
			src.open = 1
		else
			boutput(user, "<span class='alert'>[src] is already open!</span>")
		src.update_icon()
		return

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (src.reusable)
			if (istype(W, /obj/item/playing_cards))
				var/obj/item/playing_cards/C = W
				if (!src.open)
					boutput(user, "<span class='alert'>[src] isn't open, you goof!</span>")
					return

				if (src.Cards)
					if (src.Cards.cards.len + C.cards.len > src.box_size)
						boutput(user, "<span class='alert'>You try your best to stuff more cards into [src], but there's just not enough room!</span>")
						return
					else
						boutput(user, "<span class='notice'>You add [C] to the cards in [src].</span>")
						src.Cards.add_cards(C)
						return

				if (C.cards.len > src.box_size)
					boutput(user, "<span class='alert'>You try your best to stuff the cards into [src], but there's just not enough room for all of them!</span>")
					return

				user.u_equip(W)
				W.layer = initial(W.layer)
				src.Cards = W
				W.set_loc(src)
				src.update_icon()
				boutput(user, "You stuff [W] into [src].")
		else
			return ..()

	attack_hand(mob/user as mob)
		if (src.loc == user && src.Cards && src.open)
			user.put_in_hand_or_drop(src.Cards)
			boutput(user, "You take [src.Cards] out of [src].")
			src.Cards = null
			src.add_fingerprint(user)
			src.update_icon()
			return
		return ..()

	proc/update_icon()
		if (src.open && !src.Cards)
			src.icon_state = src.icon_empty
		else if (src.open && src.Cards)
			src.icon_state = src.icon_open
		else
			src.icon_state = src.icon_closed

/obj/item/paper/card_manual
	name = "paper - 'Playing Card Tips & Tricks'"
	info = {"<ul>
	<li>Click on a card in-hand to flip it over.</li>
	<li>Click on a hand in-hand to show it.</li>
	<li>Click on a deck in-hand to shuffle the cards.</li>
	<li>Click-drag a card, hand or deck onto yourself or someone else to deal a card.</li>
	<li>Click-drag a card, hand or deck onto another set of cards to combine them.</li>
	<li>To draw or deal a card face-up, use any intent other than help.</li>
	<li>To draw or deal a specific card, use grab intent.</li>
	<li>To tap or untap a card, click-drag the card onto itself.</li>
	<li>To stack cards without forming a hand, click a card with another card while on disarm intent.</li>
	</ul>"}


/* Realistic Shuffling Ahoy! */

// The chance to pull another card from the same stack as opposed to switching,
// so the "stickyness" of the cards.
#define CARD_STICK_FACTOR 0.3

// Simulates a riffle shuffle using a markovian model.
// Why? Fuck it, I have no idea.
proc/riffle_shuffle(list/deck)
	// Determines a location near the center of the deck to split from.
	var/splitLoc = (deck.len / 2) + rand(-deck.len / 5, deck.len / 5)

	// Makes two lists, one for each half of the deck, then clears the original deck.
	var/list/D1 = deck.Copy(1, splitLoc)
	var/list/D2 = deck.Copy(splitLoc)
	deck.len = 0 // Will this work?

	// Markovian model of the shuffle
	var/currentStack = rand() > 0.5
	while(D1.len > 0 && D2.len > 0)
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
