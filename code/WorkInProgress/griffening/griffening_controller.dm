#define HOLDER_ROLE_UNUSED 0
#define HOLDER_ROLE_CREATURE 1
#define HOLDER_ROLE_EFFECT 2
#define HOLDER_ROLE_DISCARD 3
#define HOLDER_ROLE_GIBBED 4
#define HOLDER_ROLE_DECK 5
#define HOLDER_ROLE_AREA 6

#define PHASE_BEGIN 1
#define PHASE_DRAW 2
#define PHASE_MAIN 3
#define PHASE_BATTLE 4
#define PHASE_END 5

/datum/griffening_controller
	var/obj/griffening_central/field_center
	var/list/field_decoration = list()

	var/obj/griffening_area/area_indicator = null
	var/list/mobs_card_holder = list(list(null, null, null, null, null), list(null, null, null, null, null))
	var/list/effects_card_holder = list(list(null, null, null, null, null), list(null, null, null, null, null))
	var/list/deck_holder = list(null, null)
	var/list/discard_holder = list(null, null)
	var/list/gibbed_holder = list(null, null)
	var/list/area_holder = list(null, null)
	var/list/players = list(null, null)
	var/list/spectators = list()
	var/turn = 0
	var/current_player = 0
	var/static/next_game_id = 1
	var/game_id = 0

	var/bound_left
	var/bound_right
	var/bound_bottom
	var/bound_top

	var/phase = null
	var/phase_arguments = null

	New(var/obj/griffening_central/F)
		field_center = F

	proc/announce(message)
		var/formatted = "<b style='font-weight: bold; color: #008800'>\[GRIFENING\]: [message]</b>"
		for (var/mob/M in players)
			boutput(M, formatted)
		for (var/mob/M in spectators)
			boutput(M, formatted)

	proc/confirm(var/question, var/mob/M)
		if (!M)
			M = usr
		var/answer = alert(M, question,,"Yes","No")
		return answer == "Yes"

	proc/update_game_status(var/message)
		for (var/mob/M in players)
			boutput(M, "<span class='notice'>[message]</span>")

	proc/action(var/obj/griffening_card_holder/holder, var/mob/M)
		if (holder.controller != src)
			return
		var/active_player = holder.player
		if (players[active_player] != M)
			boutput(M, "<span class='alert'>You cannot play cards here.</span>")
		var/obj/item/playing_cards/card = M.equipped()
		var/datum/playing_card/griffening/C
		if (card)
			if (card.cards.len == 1)
				C = card.cards[1]

			for (var/datum/playing_card/Card in card.cards)
				if (!istype(Card, /datum/playing_card/griffening))
					boutput(usr, "<span class='alert'>[Card.card_name] is not a card for this game.</span>")
					return
				if (C.available_game_id != game_id)
					boutput(usr, "<span class='alert'>[Card.card_name] doesn't belong in this game.</span>")
					return
		if (current_player != active_player)
			boutput(M, "<span class='alert'>Not your turn.</span>")
			return
		switch (holder.role)
			if (HOLDER_ROLE_UNUSED)
				boutput(M, "<span class='alert'>You cannot play cards here.</span>")
				return
			if (HOLDER_ROLE_DECK)
				if (card)
					boutput(M, "<span class='alert'>You cannot play cards here.</span>")
					return
				if (phase == PHASE_DRAW)
					var/obj/item/playing_cards/stack = holder.card
					for (var/i = 1, i <= phase_arguments, i++)
						if (!stack || !stack.cards.len)
							boutput(M, "<span class='alert'>You lose.</span>")
							// @todo
							return
						card = stack.draw_card(card, null, 1)
						if (card.loc != M)
							if (!M.put_in_hand(card))
								card.set_loc(M.loc)
				else
					boutput(M, "<span class='alert'>You cannot draw cards right now.</span>")
			if (HOLDER_ROLE_GIBBED)
				boutput(M, "<span class='alert'>You cannot play cards here.</span>")
				return
			if (HOLDER_ROLE_DISCARD)
				if (phase == PHASE_MAIN)
					if (!card)
						boutput(M, "<span class='alert'>You must take the cards you wish to discard into your active hand.</span>")
						return
					if (confirm("Are you sure you want to discard [C ? C.card_name : "these [card.cards.len] cards"]?", M))
						merge_into(holder, card, M)
						update_game_status("Player [active_player] discards [C ? "1 card" : "[card.cards.len] cards"].")
				else
					boutput(M, "<span class='alert'>You cannot discard cards right now.</span>")
					return
			if (HOLDER_ROLE_CREATURE)
				if (phase == PHASE_MAIN)
					if (!card)
						if (!holder.card)
							boutput(M, "<span class='alert'>You must take the card you wish to play into your active hand.</span>")
							return
						return
					if (holder.card)
						boutput(M, "<span class='alert'>There is already a creature here.</span>")
						return
					if (!C)
						boutput(M, "<span class='alert'>You must take a single card into your active hand.</span>")
						return
					if (!istype(C, /datum/playing_card/griffening/creature))
						boutput(M, "<span class='alert'>You cannot play that here.</span>")
						return
					if (!phase_arguments)
						boutput(M, "<span class='alert'>You cannot play any more creatures this turn.</span>")
						return
					var/face_up = confirm("Would you like to play this creature face up?", M)
					var/datum/playing_card/griffening/creature/Cr = C
					if (!Cr.can_play(src, face_up, active_player))
						boutput(M, "<span class='alert'>You cannot play this creature.</span>")
						return
					if (!Cr.before_play(src, face_up, active_player, M))
						return
					phase_arguments--
					holder.card = card
					M.u_equip(card)
					card.set_loc(holder)
					update_game_status("Player [active_player] plays [face_up ? "creature [card.card_name]" : "a creature face down"].")
		show_informational()

	proc/merge_into(var/obj/griffening_card_holder/holder, var/obj/item/playing_cards/card, var/mob/M)
		if (M)
			M.u_equip(card)
		var/obj/item/playing_cards/merge_deck = holder.card
		if (!merge_deck)
			holder.card = card
			merge_deck = holder.card
			card.set_loc(holder)
		else
			merge_deck.add_cards(card)

	proc/register_player(var/playerid, var/mob/M, var/obj/item/playing_cards/deck)
		if (players[playerid])
			return
		players[playerid] = M
		M.eye = area_indicator
		var/obj/griffening_card_holder/deck_area = deck_holder[playerid]
		deck_area.card = deck
		deck.set_loc(deck_area)
		if (!game_id)
			game_id = next_game_id
			next_game_id++
		for (var/datum/playing_card/griffening/Card in deck.cards)
			Card.available_game_id = game_id
		deck_area.update_overlays()
		if (players[1] && players[2])
			announce("Let the games begin!")
			current_player = 1
			turn = 1

	proc/in_playing_area(var/mob/M)
		if (M.loc && M.loc.y == bound_bottom && M.loc.x >= bound_left && M.loc.x <= bound_right)
			return 1
		if (M.loc && M.loc.y == bound_top && M.loc.x >= bound_left && M.loc.x <= bound_right)
			return 2
		return 0

	proc/retrieve_card_type_from_player_deck(var/card_type, var/active_player, var/forced = 0)
		var/mob/M = players[active_player]
		var/obj/griffening_card_holder/holder = deck_holder[active_player]
		var/obj/item/playing_cards/deck = holder.card
		if (!deck)
			return null
		var/list/matches = list()
		for (var/datum/playing_card/griffening/C in deck.cards)
			if (istype(C, card_type))
				matches[C.card_name] = C
		if (matches.len == 0)
			var/datum/playing_card/griffening/expected = new card_type()
			var/cname = expected.card_name
			qdel(expected)
			boutput(M, "<span class='alert'>You don't have the appropriate card ([cname]) in your deck.</span>")
			return null
		var/datum/playing_card/griffening/chosen = null
		if (matches.len == 1)
			if (!forced)
				if (!confirm("Take [matches[1]] into your hand from your deck?", M))
					return null
			chosen = matches[matches[1]]
		else
			var/chosen_name
			if (forced)
				chosen_name = input("Which card would you like to draw?", "Pick a card", null) in matches
			else
				chosen_name = input("Which card would you like to draw?", "Pick a card", null) as null|anything in matches
			if (!chosen_name)
				return null
			chosen = matches[chosen_name]
		var/obj/item/playing_cards/E = M.equipped()
		if (!istype(E))
			M.drop_item()
			E = new()
			if (!M.put_in_hand(E))
				E.set_loc(M.loc)
		if (!istype(E.cards, /list))
			E.cards = list()
		E.cards += chosen
		deck.cards -= E
		E.update_cards()
		deck.update_cards()

	proc/get_face_up_area_card()
		var/obj/griffening_card_holder/holder = area_holder[1]
		if (holder.card && holder.card.face_up)
			return holder.card.cards[1]
		holder = area_holder[2]
		if (holder.card && holder.card.face_up)
			return holder.card.cards[2]

	proc/player_has_card(var/card_type, var/active_player)
		var/checked_player = active_player
		if (ispath(card_type, /datum/playing_card/griffening/effect))
			for (var/obj/griffening_card_holder/holder in effects_card_holder[checked_player])
				if (holder.card)
					var/datum/Card = holder.card.cards[1]
					if (Card.type == card_type)
						return 1
		else if (ispath(card_type, /datum/playing_card/griffening/area))
			var/obj/griffening_card_holder/holder = area_holder[checked_player]
			if (holder.card)
				var/datum/Card = holder.card.cards[1]
				return Card.type == card_type
		else
			for (var/obj/griffening_card_holder/holder in mobs_card_holder[checked_player])
				if (holder.card)
					var/datum/Card = holder.card.cards[1]
					if (Card.type == card_type)
						return 1
		return 0

	proc/player_has_card_face_up(var/card_type, var/active_player)
		var/checked_player = active_player
		if (ispath(card_type, /datum/playing_card/griffening/effect))
			for (var/obj/griffening_card_holder/holder in effects_card_holder[checked_player])
				if (holder.card && holder.card.face_up)
					var/datum/Card = holder.card.cards[1]
					if (Card.type == card_type)
						return 1
		else if (ispath(card_type, /datum/playing_card/griffening/area))
			var/obj/griffening_card_holder/holder = area_holder[checked_player]
			if (holder.card && holder.card.face_up)
				var/datum/Card = holder.card.cards[1]
				return Card.type == card_type
		else
			for (var/obj/griffening_card_holder/holder in mobs_card_holder[checked_player])
				if (holder.card && holder.card.face_up)
					var/datum/Card = holder.card.cards[1]
					if (Card.type == card_type)
						return 1
		return 0

	proc/opponent_has_card_face_up(var/card_type, var/active_player)
		return player_has_card_face_up(card_type, active_player == 1 ? 2 : 1)

	proc/player_creatures_with_attribute_face_up(var/card_attribute, var/active_player)
		var/list/ret = list()
		var/list/mobs_card_holder_player = mobs_card_holder[active_player]
		for (var/i = 1, i <= 5, i++)
			var/obj/griffening_card_holder/holder = mobs_card_holder_player[i]
			if (holder.card && holder.card.face_up)
				var/datum/playing_card/griffening/creature/Card = holder.card.cards[1]
				if (Card.attributes & card_attribute == card_attribute)
					ret += Card
					ret[Card] = "[active_player]C[i]"
		return ret

	proc/opponent_creatures_with_attribute_face_up(var/card_attribute, var/active_player)
		return player_creatures_with_attribute_face_up(card_attribute, active_player == 1 ? 2 : 1)

	proc/player_discarded_creatures_with_attribute(var/card_attribute, var/active_player)
		var/list/ret = list()
		var/obj/griffening_card_holder/holder = discard_holder[active_player]
		var/obj/item/playing_cards/PC = holder.card
		if (!PC)
			return ret
		for (var/i = 1, i <= PC.cards.len, i++)
			var/datum/playing_card/griffening/creature/Card = PC.cards[i]
			if (!istype(Card))
				continue
			if (Card.attributes & card_attribute == card_attribute)
				ret += Card
				ret[Card] = "[active_player]D[i]"
		return ret

	proc/opponent_discarded_creatures_with_attribute(var/card_attribute, var/active_player)
		return player_discarded_creatures_with_attribute(card_attribute, active_player == 1 ? 2 : 1)

	proc/player_effects_face_up(var/active_player)
		var/list/ret = list()
		var/list/effects_card_holder_player = effects_card_holder[active_player]
		for (var/i = 1, i <= 5, i++)
			var/obj/griffening_card_holder/holder = effects_card_holder_player[i]
			if (holder.card && holder.card.face_up)
				var/datum/playing_card/griffening/effect/Card = holder.card.cards[1]
				if (!(Card.card_type & GRIFFENING_TYPE_EQUIP))
					ret += Card
					ret[Card] = "[active_player]E[i]"
		return ret

	proc/opponent_effects_face_up(var/active_player)
		return player_effects_face_up(active_player == 1 ? 2 : 1)

	proc/player_equipment_face_up(var/active_player)
		var/list/ret = list()
		var/list/effects_card_holder_player = effects_card_holder[active_player]
		for (var/i = 1, i <= 5, i++)
			var/obj/griffening_card_holder/holder = effects_card_holder_player[i]
			if (holder.card && holder.card.face_up)
				var/datum/playing_card/griffening/effect/Card = holder.card.cards[1]
				if (Card.card_type & GRIFFENING_TYPE_EQUIP)
					ret += Card
					ret[Card] = "[active_player]E[i]"
		return ret

	proc/opponent_equipment_face_up(var/active_player)
		return player_equipment_face_up(active_player == 1 ? 2 : 1)

	proc/player_effects_and_equipment(var/active_player)
		var/list/ret = list()
		var/list/effects_card_holder_player = effects_card_holder[active_player]
		for (var/i = 1, i <= 5, i++)
			var/obj/griffening_card_holder/holder = effects_card_holder_player[i]
			if (holder.card)
				var/datum/playing_card/griffening/effect/Card = holder.card.cards[1]
				ret += Card
				ret[Card] = "[active_player]E[i]"
		return ret

	proc/opponent_effects_and_equipment(var/active_player)
		return player_effects_and_equipment(active_player == 1 ? 2 : 1)

	proc/player_has_attributed_creature_face_up(var/card_attribute, var/active_player)
		var/list/creatures = player_creatures_with_attribute_face_up(card_attribute, active_player)
		return creatures.len > 0

	proc/opponent_has_attributed_creature_face_up(var/card_attribute, var/active_player)
		return player_has_attributed_creature_face_up(card_attribute, active_player == 1 ? 2 : 1)

	proc/ask_player(var/list/choices, var/active_player, var/question = "Choose an option", var/timeout = 30)
		var/mob/asked = players[active_player]
		if (!istype(asked))
			return null
		if (!asked.client)
			return null
		var/answer = input(asked, question, question, null) as null|anything in choices
		return answer

	proc/locate_card(var/designation)
		var/playerid = text2num(chs(designation, 1))
		if (!playerid)
			return null
		var/array = chs(designation, 2)
		switch (array)
			if ("C")
				var/list/choice = mobs_card_holder[playerid]
				var/cardid = text2num(chs(designation, 3))
				var/obj/griffening_card_holder/holder = choice[cardid]
				if (!holder.card)
					return null
				var/obj/item/playing_cards/PC = holder.card
				return PC.cards[1]

			if ("E")
				var/list/choice = effects_card_holder[playerid]
				var/cardid = text2num(chs(designation, 3))
				var/obj/griffening_card_holder/holder = choice[cardid]
				if (!holder.card)
					return null
				var/obj/item/playing_cards/PC = holder.card
				return PC.cards[1]

			if ("A")
				var/obj/griffening_card_holder/holder = area_holder[playerid]
				if (!holder.card)
					return null
				var/obj/item/playing_cards/PC = holder.card
				return PC.cards[1]

			if ("D")
				var/obj/griffening_card_holder/holder = discard_holder[playerid]
				if (holder.card)
					return null
				var/cardid = text2num(copytext(designation, 3))
				var/obj/item/playing_cards/PC = holder.card
				if (PC.cards.len <= cardid)
					return PC.cards[cardid]
				return null

			if ("G")
				var/obj/griffening_card_holder/holder = gibbed_holder[playerid]
				if (holder.card)
					return null
				var/cardid = text2num(copytext(designation, 3))
				var/obj/item/playing_cards/PC = holder.card
				if (PC.cards.len <= cardid)
					return PC.cards[cardid]
				return null

			if ("K")
				var/obj/griffening_card_holder/holder = deck_holder[playerid]
				if (holder.card)
					return null
				var/cardid = text2num(copytext(designation, 3))
				var/obj/item/playing_cards/PC = holder.card
				if (PC.cards.len <= cardid)
					return PC.cards[cardid]
				return null
		return null

	proc/spawn_field()
		if (!field_center)
			return

		var/turf/T = get_turf(field_center)
		var/x = T.x
		var/y = T.y
		var/z = T.z
		bound_bottom = y - 6
		bound_top = y + 6
		bound_left = x - 3
		bound_right = x + 3

		// we need a range(7) area to be free
		if (x + 7 >= world.maxx || y + 7 >= world.maxy || y - 7 <= 1 || x - 7 <= 1)
			return

		for (var/turf/Q in block(locate(x - 3, y - 6, z), locate(x + 3, y + 6, z)))
			var/turf/R = new /turf/unsimulated/floor/griffening(Q)
			field_decoration += R
			if (R.x == x - 3 && !(abs(R.y - y) % 3))
				var/obj/LT = new /obj/machinery/light(R)
				LT.dir = 8
			if (R.x == x + 3 && !(abs(R.y - y) % 3))
				var/obj/LT = new /obj/machinery/light(R)
				LT.dir = 4
			if (R.y == y - 5 || R.y == y + 4 || R.y == y + 5 || R.y == y - 4)
				var/obj/griffening_card_holder/GCH = new /obj/griffening_card_holder(R, src)
				if (R.y > y)
					GCH.player = 2
				if (R.y == y - 5 || R.y == y + 4)
					if (R.x == x - 3)
						GCH.icon_state = "card_holder_bottom_left"
					else if (R.x == x + 3)
						GCH.icon_state = "card_holder_bottom_right"
					else
						GCH.icon_state = "card_holder_bottom"
					GCH.card_offset = 8
				else
					if (R.x == x - 3)
						GCH.icon_state = "card_holder_top_left"
					else if (R.x == x + 3)
						GCH.icon_state = "card_holder_top_right"
					else
						GCH.icon_state = "card_holder_top"
					GCH.card_offset = -8
				if (R.y == y - 5 && R.x == x - 3)
					GCH.name = "Deck"
					GCH.role = HOLDER_ROLE_DECK
					deck_holder[1] = GCH
				else if (R.y == y + 5 && R.x == x - 3)
					GCH.name = "Deck"
					GCH.role = HOLDER_ROLE_DECK
					deck_holder[2] = GCH
				else if (R.y == y - 4 && R.x == x - 3)
					GCH.name = "Discard"
					GCH.role = HOLDER_ROLE_DISCARD
					discard_holder[1] = GCH
				else if (R.y == y + 4 && R.x == x - 3)
					GCH.name = "Discard"
					GCH.role = HOLDER_ROLE_DISCARD
					discard_holder[2] = GCH
				else if (R.y == y - 4 && R.x == x + 3)
					GCH.name = "Gibbed"
					GCH.role = HOLDER_ROLE_GIBBED
					gibbed_holder[1] = GCH
				else if (R.y == y + 4 && R.x == x + 3)
					GCH.name = "Gibbed"
					GCH.role = HOLDER_ROLE_GIBBED
					gibbed_holder[2] = GCH
				else if (R.y == y - 5 && R.x == x + 3)
					GCH.name = "Area"
					GCH.role = HOLDER_ROLE_AREA
					area_holder[1] = GCH
				else if (R.y == y + 5 && R.x == x + 3)
					GCH.name = "Area"
					GCH.role = HOLDER_ROLE_AREA
					area_holder[2] = GCH
				else if (R.y == y - 5 || R.y == y - 4 || R.y == y + 4 || R.y == y + 5)
					var/id = R.x - (x - 3)
					if (R.y == y - 5)
						GCH.name = "Effect/Equip Slot #[id]"
						GCH.role = HOLDER_ROLE_EFFECT
						var/list/p1_effects_card_holder = effects_card_holder[1]
						p1_effects_card_holder[id] = GCH
						GCH.position_hologram(x, R.y - 3)
					else if (R.y == y + 5)
						GCH.name = "Effect/Equip Slot #[id]"
						GCH.role = HOLDER_ROLE_EFFECT
						var/list/p2_effects_card_holder = effects_card_holder[2]
						p2_effects_card_holder[id] = GCH
						GCH.position_hologram(x, R.y + 3)
					else if (R.y == y - 4)
						GCH.name = "Creature Slot #[id]"
						GCH.role = HOLDER_ROLE_CREATURE
						var/list/p1_mobs_card_holder = mobs_card_holder[1]
						p1_mobs_card_holder[id] = GCH
						GCH.position_hologram(x, R.y - 2)
					else if (R.y == y + 4)
						GCH.name = "Creature Slot #[id]"
						GCH.role = HOLDER_ROLE_CREATURE
						var/list/p2_mobs_card_holder = mobs_card_holder[2]
						p2_mobs_card_holder[id] = GCH
						GCH.position_hologram(x, R.y + 2)

		for (var/turf/Q in block(locate(x - 4, y - 6, z), locate(x - 4, y + 6, z)))
			var/turf/R = new /turf/unsimulated/wall/griffening(Q)
			field_decoration += R

		for (var/turf/Q in block(locate(x + 4, y - 6, z), locate(x + 4, y + 6, z)))
			var/turf/R = new /turf/unsimulated/wall/griffening(Q)
			field_decoration += R

		area_indicator = new /obj/griffening_area(T, src)
		field_decoration += area_indicator

	#define addinfo(x) p1 += x; p2 += x; sp += x
	#define addinfo1(x,y) p1 += x; p2 += y; sp += y
	#define addinfo2(x,y) p1 += y; p2 += x; sp += y
	proc/show_informational()
		var/p1 = ""
		var/p2 = ""
		var/sp = ""
		var/stylesheet = {"table {
	width: 100%;
}

td, th {
	width: 50%;
}

.attention: {
	border: 2px solid red;
}

.question {
	width: 100%;
	text-align: center;
	margin-top: 5px;
}

.answer-wrapper {
	width: 100%;
	margin-top: 20px;
	margin-bottom: 5px;
	text-align: center;
}

.answer {
	display: inline-block;
	margin-right: 5px;
	margin-left: 5px;
}"}
		addinfo("<html><head><title>Spacemen the Grifening</title><style>[stylesheet]</style></head><body>")
		addinfo("<h2>Spacemen the Grifening game</h2><b>Player 1: </b>[players[1]]<br/><b>Player 2: </b>[players[2]]<br/><br/>")
		/*if (current_player == 1)
			if (active_question)
				if (!question_output)
					generate_question_output()
				addinfo1("<div class='attention'>[question_output]</div>", "<b>Player 1</b> is currently playing.")
			else
				addinfo("<b>Player 1</b> is currently playing.")
		else if (current_player == 2)
			if (active_question)
				if (!question_output)
					generate_question_output()
				addinfo2("<div class='attention'>[question_output]</div>", "<b>Player 2</b> is currently playing.")
			else
				addinfo("<b>Player 2</b> is currently playing.")*/
		addinfo("<b>Player [current_player] is currently playing.</b><br><br>")
		addinfo("<h3>Field information</h3><b>Area in play: </b>")
		var/datum/playing_card/griffening/area/area = get_face_up_area_card()
		if (istype(area))
			addinfo("[area.card_name]<br/>[area.card_data]<br/><br/>")
		else
			addinfo("&lt;none&gt;<br/><br/>")
		addinfo("<table><thead><tr><th>Player 1</th><th>Player 2</th></tr></thead><tbody><tr><td><b>Creatures (left to right)</b><br>")
		var/list/card_holders = mobs_card_holder[1]
		for (var/i = 1, i <= 5, i++)
			addinfo("<b>Creature #[i]: </b>")
			var/obj/griffening_card_holder/holder = card_holders[i]
			if (holder.card)
				var/obj/item/playing_cards/PC = holder.card
				var/datum/playing_card/griffening/C = PC.cards[1]
				if (PC.face_up)
					addinfo("[C.card_name]<br/>[C.card_data]<br/>")
				else
					addinfo1("[C.card_name]<br/>[C.card_data]<br/> \[FACE DOWN\]<br>", "Face down card")
			else
				addinfo("&lt;none&gt;<br/>")
		addinfo("<br><b>Effects (left to right)</b><br/>")
		card_holders = effects_card_holder[1]
		for (var/i = 1, i <= 5, i++)
			addinfo("<b>Effect #[i]: </b>")
			var/obj/griffening_card_holder/holder = card_holders[i]
			if (holder.card)
				var/obj/item/playing_cards/PC = holder.card
				var/datum/playing_card/griffening/C = PC.cards[1]
				if (PC.face_up)
					addinfo("[C.card_name]<br/>[C.card_data]<br/>")
				else
					addinfo1("[C.card_name]<br/>[C.card_data]<br/> \[FACE DOWN\]<br>", "Face down card")
			else
				addinfo("&lt;none&gt;<br/>")
		var/obj/griffening_card_holder/D = discard_holder[1]
		var/obj/item/playing_cards/discard = D.card
		var/list/discards = list()
		if (discard)
			discards = discard.cards
		addinfo("<br><b>Discard pile:</b> [discards.len] cards<br/>")
		p1 += "<ul>"
		for (var/datum/playing_card/griffening/C in discards)
			p1 += "<li>[C.card_name]</li>"
		p1 += "</ul><br>"
		D = gibbed_holder[1]
		discard = D.card
		discards = list()
		if (discard)
			discards = discard.cards
		addinfo("<br><b>Gibbed pile:</b> [discards.len] cards<br/>")
		p1 += "<ul>"
		for (var/datum/playing_card/griffening/C in discards)
			p1 += "<li>[C.card_name]</li>"
		p1 += "</ul>"

		addinfo("</td><td><b>Creatures (left to right)</b><br>")

		card_holders = mobs_card_holder[2]
		for (var/i = 1, i <= 5, i++)
			addinfo("<b>Creature #[i]: </b>")
			var/obj/griffening_card_holder/holder = card_holders[i]
			if (holder.card)
				var/obj/item/playing_cards/PC = holder.card
				var/datum/playing_card/griffening/C = PC.cards[1]
				if (PC.face_up)
					addinfo("[C.card_name]<br/>[C.card_data]<br/>")
				else
					addinfo2("[C.card_name]<br/>[C.card_data]<br/> \[FACE DOWN\]<br>", "Face down card")
			else
				addinfo("&lt;none&gt;<br/>")
		addinfo("<br><b>Effects (left to right)</b><br/>")
		card_holders = effects_card_holder[2]
		for (var/i = 1, i <= 5, i++)
			addinfo("<b>Effect #[i]: </b>")
			var/obj/griffening_card_holder/holder = card_holders[i]
			if (holder.card)
				var/obj/item/playing_cards/PC = holder.card
				var/datum/playing_card/griffening/C = PC.cards[1]
				if (PC.face_up)
					addinfo("[C.card_name]<br/>[C.card_data]<br/>")
				else
					addinfo2("[C.card_name]<br/>[C.card_data]<br/> \[FACE DOWN\]<br>", "Face down card")
			else
				addinfo("&lt;none&gt;<br/>")
		D = discard_holder[2]
		discard = D.card
		discards = list()
		if (discard)
			discards = discard.cards
		addinfo("<br><b>Discard pile:</b> [discards.len] cards<br/>")
		p2 += "<ul>"
		for (var/datum/playing_card/griffening/C in discards)
			p2 += "<li>[C.card_name]</li>"
		p2 += "</ul><br>"
		D = gibbed_holder[2]
		discard = D.card
		discards = list()
		if (discard)
			discards = discard.cards
		addinfo("<br><b>Gibbed pile:</b> [discards.len] cards<br/>")
		p2 += "<ul>"
		for (var/datum/playing_card/griffening/C in discards)
			p2 += "<li>[C.card_name]</li>"
		p2 += "</ul>"

		addinfo("</td></tr></tbody></table>")

		addinfo1("<a href='?src=\ref[src];forfeit=1'>Forfeit</a>", "")
		addinfo2("<a href='?src=\ref[src];forfeit=2'>Forfeit</a>", "")

		var/mob/player1 = players[1]
		if (player1)
			player1.Browse(p1, "window=griffening;can_close=0;size=400x600")
		var/mob/player2 = players[2]
		if (player2)
			player2.Browse(p2, "window=griffening;can_close=0;size=400x600")
		for (var/mob/M in spectators)
			M.Browse(sp, "window=griffening;size=400x600")
	#undef addinfo2
	#undef addinfo1
	#undef addinfo

/turf/unsimulated/wall/griffening
	icon = 'icons/misc/griffening/area_wall.dmi'
	icon_state = null
	density = 1
	opacity = 0
	name = "wall"
	desc = "A holographic projector wall."

/turf/unsimulated/floor/griffening
	icon = 'icons/misc/griffening/area_floor.dmi'
	icon_state = null
	opacity = 0
	name = "floor"
	desc = "A holographic projector floor."

/obj/griffening_area
	name = "no area card in effect"
	desc = "No area card is currently in effect."
	icon = 'icons/misc/griffening/area_object.dmi'
	var/datum/griffening_controller/controller = null
	var/datum/playing_card/griffening/area/card = null
	var/area_owner = 0
	anchored = 1
	density = 1

	New(var/loc, var/ctrl)
		..()
		src.controller = ctrl

	examine()
		. = ..()
		if (!controller || !card)
			return
		else
			. += "Area card in effect: <i>[card.card_name]</i>"
			. += card.card_desc

/obj/griffening_hologram
	name = "hologram"
	desc = "hologram"
	icon = 'icons/mob/mob.dmi'
	icon_state = "blank"

/obj/griffening_card_holder
	name = "card slot"
	desc = "A slot where a card can be played."
	icon = 'icons/misc/griffening/griffening.dmi'

	var/datum/griffening_controller/controller = null
	var/obj/item/playing_cards/card = null
	var/obj/griffening_hologram/hologram = new
	var/card_offset = 0
	var/player = 1
	var/role = HOLDER_ROLE_UNUSED
	anchored = 1
	density = 1

	New(var/loc, var/ctrl)
		..()
		src.controller = ctrl

	proc/position_hologram(var/hx, var/hy)
		var/turf/T = locate(hx, hy, z)
		if (istype(T))
			hologram.set_loc(T)

	proc/update_overlays()
		overlays.len = 0
		if (!card)
			return
		display_card()

	proc/display_card()
		var/image/OL = image(card.icon, card.icon_state, pixel_y = card_offset)
		overlays += OL

	Click(location, control, params)
		var/mob/M = usr
		if (!M)
			return
		if (!ishuman(M))
			return
		if (controller.players[player])
			if (controller.players[player] != M)
				boutput(M, "<span class='alert'>You're not player [player], please stop clicking me.</span>")
				return
		var/areaid = controller.in_playing_area(M)
		if (areaid != player)
			boutput(M, "<span class='alert'>You must step up to the card holders to play.</span>")
			return
		if (!controller.players[player])
			var/obj/item/playing_cards/held = M.equipped()
			if (!istype(held))
				boutput(M, "<span class='alert'>You must be holding your deck to enter play.</span>")
				return
			if (held.cards.len < 40 || held.cards.len > 80)
				boutput(M, "<span class='alert'>You require 40-80 cards in your deck to play.</span>")
				return
			for (var/datum/playing_card/Card in held.cards)
				if (!istype(Card, /datum/playing_card/griffening))
					boutput(M, "<span class='alert'>Card [Card.card_name] is not a valid playing card. Remove it from your deck first.</span>")
					return
			M.remove_item(held)
			controller.register_player(player, M, held)
			boutput(M, "<span class='notice'>You enter the game as player [player]. The game begins when both players joined. Leaving the playing area (the row in front of your card holders) or becoming braindead for more than 15 seconds will automatically forfeit the game.</span>")
		else
			controller.action(src, M)

/obj/griffening_central
	name = "Spacemen the Grifening duel arena"
	invisibility = 101
	density = 0
	opacity = 0
	anchored = 1

	var/datum/griffening_controller/controller = null

	New()
		controller = new(src)
		controller.spawn_field()

#undef HOLDER_ROLE_CREATURE
#undef HOLDER_ROLE_EFFECT
#undef HOLDER_ROLE_DISCARD
#undef HOLDER_ROLE_GIBBED
#undef HOLDER_ROLE_DECK
#undef HOLDER_ROLE_AREA
#undef HOLDER_ROLE_UNUSED
