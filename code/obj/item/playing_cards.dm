//defines for the number of each card in the dmi of the following StG categories
#define NUMBER_F 4 //female
#define NUMBER_M 4 //male
#define NUMBER_N 2 //nonbinary
#define NUMBER_GENERAL 8
#define NUMBER_BORG 2
#define NUMBER_AI 2

//General Card Parents
//------------------//
/obj/item/playing_card
    icon = 'icons/obj/items/playing_card.dmi'
    dir = NORTH
    var/card_style //what style of card sprite are we using?
    var/facedown = FALSE
    var/foiled = FALSE

    var/list/stored_info
    contextLayout = new /datum/contextLayout/instrumental(16)
    var/list/datum/contextAction/cardActions

    attack_self(mob/user as mob)
        flip()
    
    attackby(obj/item/W as obj, mob/user as mob)
        if(istype(W,/obj/item/playing_card))
            if(loc != user)
                update_card_actions(TRUE)
            else
                update_card_actions()
            user.showContextActions(cardActions, src)

    proc/flip()
        if(!facedown)
            stored_info = list(name,desc,icon_state)
            name = "playing card"
            desc = "a face-down card."
            icon_state = "[card_style]-back"
            facedown = TRUE
        else
            name = stored_info[1]
            desc = stored_info[2]
            icon_state = stored_info[3]
            stored_info = null
            facedown = FALSE

    proc/update_card_actions(var/card_outside)
        cardActions = list()
        if(card_outside)
            cardActions += new /datum/contextAction/card/solitaire
        cardActions += new /datum/contextAction/card/fan
        cardActions += new /datum/contextAction/card/stack
        cardActions += new /datum/contextAction/card/close

    proc/solitaire()

    proc/stack()
    
    proc/fan()

    //procs that convert the card into the given StG card type
    proc/stg_mob(var/list/possible_card_types,var/list/humans,var/list/borgos,var/list/ai)
        var/path = pick(possible_card_types)
        var/datum/playing_card/griffening/creature/mob/chosen_card_type = new path
        var/mob/living/chosen_mob

        var/icon_state_num

        if(istype(chosen_card_type,/datum/playing_card/griffening/creature/mob/cyborg))
            if(borgos.len)
                chosen_mob = pick(borgos) //DEV - condense if possible
            if(chosen_mob)
                name = chosen_mob.name
            else
                name = "Cyborg [pick("Alpha", "Beta", "Gamma", "Delta", "Xi", "Pi", "Theta")]-[rand(10,99)]"
            icon_state_num = rand(1,NUMBER_BORG)
            icon_state = "stg-borg-[icon_state_num]"
        else if (istype(chosen_card_type,/datum/playing_card/griffening/creature/mob/ai))
            if(ai.len)
                chosen_mob = pick(ai)
            if(chosen_mob)
                name = chosen_mob.name
            else
                name = pick("SHODAN", "GLADOS", "HAL-9000")
            name += "the AI"
            icon_state_num = rand(1,NUMBER_AI)
            icon_state = "stg-ai-[icon_state_num]"
        else
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
                        icon_state = "stg-N-[icon_state_num]"
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
                        icon_state = "stg-N-[icon_state_num]"
        if(chosen_card_type.LVL)
            name = "LVL [chosen_card_type.LVL] [name]"
        desc = chosen_card_type.card_data
        desc += "ATK [chosen_card_type.ATK] | DEF [chosen_card_type.DEF]"

    proc/stg_friend(var/list/possible_card_types)
        var/path = pick(possible_card_types)
        var/datum/playing_card/griffening/creature/friend/chosen_card_type = new path
        if(chosen_card_type.LVL)
            name = "LVL [chosen_card_type.LVL] [chosen_card_type.card_name]"
        else
            name = chosen_card_type.card_name
        desc = chosen_card_type.card_data
        desc += "ATK [chosen_card_type.ATK] | DEF [chosen_card_type.DEF]"
        icon_state = "stg-general-[pick(1,NUMBER_GENERAL)]"

    proc/stg_effect(var/list/possible_card_types)
        var/path = pick(possible_card_types)
        var/datum/playing_card/griffening/effect/chosen_card_type = new path

        name = chosen_card_type.card_name
        desc = chosen_card_type.card_data
        icon_state = "stg-general-[pick(1,NUMBER_GENERAL)]"

    proc/stg_area(var/list/possible_card_types)
        var/path = pick(possible_card_types)
        var/datum/playing_card/griffening/area/chosen_card_type = new path

        name = chosen_card_type.card_name
        desc = chosen_card_type.card_data
        icon_state = "stg-general-[pick(1,NUMBER_GENERAL)]"

    proc/add_foil()
        UpdateOverlays(image(icon,"stg-foil"),"foil")
        foiled = TRUE

/obj/item/card_group
    name = "deck of playing cards"
    icon = 'icons/obj/items/playing_card.dmi'
    dir = NORTH
    var/card_style = "plain"
    var/total_cards
    var/is_hand = FALSE
    var/max_hand_size = 18
    contextLayout = new /datum/contextLayout/instrumental(16)
    var/list/datum/contextAction/cardActions
    var/list/stored_cards = list()

    attack_hand(mob/user as mob)
        if(!is_hand)
            update_card_actions("empty")
            user.showContextActions(cardActions, src)
        else
            ..()

    attack_self(mob/user as mob)
        if(is_hand)
            update_card_actions("handself")
            user.showContextActions(cardActions, src)
        //else shuffle

    attackby(obj/item/W as obj, mob/user as mob)
        if(istype(W, /obj/item/playing_card))
            if(is_hand)
                //add card
                world.log << ("PLACEHOLDER")
            else
                update_card_actions("card")
                user.showContextActions(cardActions, src)
        else if(istype(W,/obj/item/card_group))
            update_card_actions("group")
            user.showContextActions(cardActions, src)
        else
            ..()

    proc/handle_draw_last_card(var/mob/user)
        var/obj/item/playing_card/c = stored_cards[1]
        c.flip()
        if(loc == user)
            user.u_equip(src)
            user.put_in_hand_or_drop(stored_cards[1])
        else
            c.flip()
            c.set_loc(get_turf(src.loc))
        qdel(src)

    proc/add_to_group(var/obj/item/c)
        c.set_loc(src)
        stored_cards += c
        if(is_hand)
            if(length(stored_cards) > max_hand_size)
                is_hand = FALSE

    proc/update_group_sprite()
        var/cards = length(stored_cards)
        if(!is_hand)
            if(cards > ((total_cards/4 + total_cards/2)))
                icon_state = "[card_style]-deck-4"
            else if(cards > total_cards/2)
                icon_state = "[card_style]-deck-3"
            else if(cards > total_cards/4)
                icon_state = "[card_style]-deck-2"
            else if(cards < total_cards/4)
                icon_state = "[card_style]-deck-1"
        else
            if(cards > 5)
                icon_state = "[card_style]-hand-5"
            else
                icon_state = "[card_style]-hand-[cards]"

    proc/update_card_actions(var/hitby)
        cardActions = list()

        //card to deck
        if(hitby == "card")
            cardActions += new /datum/contextAction/card/topdeck
            cardActions += new /datum/contextAction/card/bottomdeck
            cardActions += new /datum/contextAction/card/close
        //empty to deck
        else if(hitby == "empty")
            cardActions += new /datum/contextAction/card/draw
            cardActions += new /datum/contextAction/card/draw_multiple
            cardActions += new /datum/contextAction/card/search
            if(length(stored_cards) <= max_hand_size)
                cardActions += new /datum/contextAction/card/fan
            cardActions += new /datum/contextAction/card/pickup
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

    proc/draw(var/mob/user)
        if(is_hand)
            return
        user.put_in_hand_or_drop(stored_cards[1])
        stored_cards -= stored_cards[1]
        if(length(stored_cards) == 1)
            handle_draw_last_card(user)
        else
            update_group_sprite()

    proc/draw_multiple(var/mob/user)
        if(is_hand)
            return
        var/card_number = input(user, "How many cards would you like to draw?", "[name]")  as null|num
        if(card_number > length(stored_cards))
            card_number = length(stored_cards)
        if(in_interact_range(src, user))
            var/obj/item/card_group/hand = new /obj/item/card_group
            hand.is_hand = TRUE
            hand.total_cards = total_cards
            for(var/i in 1 to card_number)
                hand.add_to_group(stored_cards[1])
                stored_cards -= stored_cards[1]
            hand.update_group_sprite()
            user.put_in_hand_or_drop(hand)
            if(length(stored_cards) == 1)
                handle_draw_last_card(user)
            else if(length(stored_cards) == 0)
                qdel(src)
            else
                update_group_sprite()
            
    proc/search(var/mob/user)
        var/card = input(user, "Which card would you like to draw?", "[name]")  as null|anything in stored_cards
        if(!card)
            return
        if(in_interact_range(src, user))
            user.put_in_hand_or_drop(card)
            stored_cards -= card
            if(length(stored_cards) == 1)
                handle_draw_last_card(user)
            else
                update_group_sprite()

    proc/reveal(var/mob/user)

    proc/fan(var/mob/user)
        if(is_hand)
            return
        if(length(stored_cards) < max_hand_size)
            is_hand = TRUE
            update_group_sprite()

    proc/stack(var/mob/user)
        if(!is_hand)
            return
        is_hand = FALSE
        update_group_sprite()

    proc/top_or_bottom(var/mob/user,var/W,var/position)
        if(istype(W,/obj/item/card_group))
            var/obj/item/card_group/G = W
            if(G.card_style == card_style)
                if(position == "top")
                    var/card_pos = length(G.stored_cards)
                    for(var/i in 1 to length(G.stored_cards))
                        var/obj/item/c = G.stored_cards[card_pos]
                        c.set_loc(src)
                        stored_cards.Insert(1,c)
                        card_pos--
                else
                    for(var/obj/item/c in G.stored_cards)
                        c.set_loc(src)
                        stored_cards += c
                user.u_equip(G)
                qdel(G)
                /*if(is_hand && (length(stored_cards) > max_hand_size))
                    is_hand = FALSE
                update_group_sprite()*/
        else if(istype(W,/obj/item/playing_card))
            var/obj/item/playing_card/c = W
            if(c.card_style == card_style)
                user.u_equip(c)
                c.set_loc(src)
                if(position == "top")
                    stored_cards.Insert(1,c)
                else
                    stored_cards += c
                update_group_sprite()

//Plain playing cards
//-----------------//
/obj/item/card_group/plain
    card_style = "plain"
    total_cards = 54

    New()
        ..()
        var/suit_num = 1
        var/card_num = 1
        var/plain_suit
        var/suit_name
        for(var/i in 1 to total_cards)
            var/obj/item/playing_card/card = new /obj/item/playing_card(src)
            card.card_style = card_style
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
                    card.name = "[capitalize(num2text(card_num))] of [suit_name]]"
                else
                    switch(card_num)
                        if(11)
                            card.name = "Jack of [suit_name]]"
                        if(12)
                            card.name = "Queen of [suit_name]]"
                        if(13)
                            card.name = "King of [suit_name]]"
            else
                if(card_num == 1)
                    card.name = "Red Joker"
                else
                    card.name = "Black Joker"
            
            card.icon_state = "[card_style]-[suit_num]-[card_num]"

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
    name = "deck of tarot cards"
    desc = "Whoever drew these probably felt like the nine of swords afterward..."
    card_style = "tarot"
    total_cards = 78

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
            card.card_style = card_style
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
                    card.name = "Ace of [suit_name]]"
                else if(card_num < 11)
                    card.name = "[capitalize(num2text(card_num))] of [suit_name]]"
                else
                    switch(card_num)
                        if(11)
                            card.name = "Page of [suit_name]]"
                        if(12)
                            card.name = "Knight of [suit_name]]"
                        if(13)
                            card.name = "Queen of [suit_name]]"
                        if(14)
                            card.name = "King of [suit_name]]"
            else
                card.name = major[card_num]

            card.icon_state = "[card_style]-[suit_num]-[card_num]"

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

    New()
        ..()
        var/target_month = 1 //card suit
        var/card_num = 1 //number within the card's suit
        for(var/i in 1 to total_cards)
            //Card.solitaire_offset = 5
            var/special_second
            var/special_third
            var/special_fourth

            var/obj/item/playing_card/card = new /obj/item/playing_card(src)
            card.card_style = card_style
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
    desc = "A deck of Spacemen the Griffening cards."
    card_style = "stg"
    total_cards = 40

    New()
        ..()

        var/list/possible_humans = list()
        for(var/mob/living/carbon/human/H in mobs)
            if(isnpcmonkey(H))
                continue
            if(iswizard(H))
                continue
            if(isnukeop(H))
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

        for(var/i in 1 to total_cards)
            var/obj/item/playing_card/card = new /obj/item/playing_card(src)
            card.card_style = card_style
            stored_cards += card
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

        update_group_sprite()

//Deck Boxes
//--------//

/obj/item/card_box //three state opening : box,open,empty
    name = "deckbox"
    desc = "a box for holding cards."
    icon = 'icons/obj/items/playing_card.dmi'
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

    attack_hand(mob/user as mob)
        if((loc == user) && (icon_state == "[box_style]-box-open"))
            user.put_in_hand_or_drop(stored_deck)
            icon_state = "[box_style]-box-empty"
            stored_deck = null
        else
            ..()

    attackby(obj/item/W as obj, mob/user as mob)
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

    New()
        ..()
        stored_deck = new /obj/item/card_group/tarot

/obj/item/card_box/hanafuda
    name = "hanafuda box"
    box_style = "hanafuda"

    New()
        ..()
        stored_deck = new /obj/item/card_group/hanafuda

/obj/item/stg_box
    name = "StG Preconstructed Deck Box"
    desc = "a pick up and play deck of StG cards!"
    icon = 'icons/obj/items/playing_card.dmi'
    icon_state = "stg-box"
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

    attack_self(mob/user as mob)
        switch(icon_state)
            if("stg-box")
                icon_state = "stg-box-open"
            if("stg-box-open")
                icon_state = "stg-box-torn"

    attack_hand(mob/user as mob)
        if((loc == user) && stored_deck && ((icon_state =="stg-box-torn") || (icon_state == "stg-blister")))
            if(icon_state == "stg-box-torn")
                icon_state = "stg-blister"
                ..()
                user.put_in_hand_or_drop(new /obj/item/stg_box_waste)
            else if(icon_state == "stg-blister")
                user.put_in_hand_or_drop(stored_deck)
                stored_deck = null
                name = "discarded blister packaging"
                ClearAllOverlays()
        else
            ..()

/obj/item/stg_box_waste
    name = "mutilated cardboard husk"
    icon = 'icons/obj/items/playing_card.dmi'
    icon_state = "stg-box-empty"
