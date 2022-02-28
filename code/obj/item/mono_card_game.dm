/obj/item/card_group/mono
	card_style = "mono"
	total_cards = 118
	card_name = "mono"
	var/list/numToSpecial = new list(10 = "Block", 11 = "Reverse", 12 = "Draw 2")

	New()
		..()
		var/suit_num = 1;
		var/card_num = 1;
		//Add special cards
		for(var/i = 1, i<5, i++){
			var/obj/item/playing_card/wild = new /obj/item/playing_card(src)
			var/obj/item/playing_card/fuckYou = new /obj/item/playing_card(src)
			stored_cards += wild;
			stored_cards += fuckYou;
			setMonoCard(wild, 5, 1);
			setMonoCard(fuckYou, 5, 2);
		}
		//Add one set of zeroes
		for(var/i = 1, i < 5, i++){
			var/obj/item/playing_card/card = new /obj/item/playing_card(src)
			stored_cards += card
			setMonoCard(card, i, 0)
		}
		//Do rest of the numbers
		for(var/i=1, i<5, i++){
			for(var/j = 1, j<13, j++){

				var/obj/item/playing_card/card = new /obj/item/playing_card(src)
				stored_cards += card
				setMonoCard(card, i, j)

				var/obj/item/playing_card/card2 = new /obj/item/playing_card(src)
				stored_cards += card2
				setMonoCard(card2, i, j)
			}
		}
		update_group_sprite()

	proc/setMonoCard(/obj/item/playing_card/target, /var/suit, /var/num)
		var/plain_suit = TRUE;
		var/suit_name;
		switch(suit){
			if(1)
				suit_name = "Red"
			if(2)
				suit_name = "Yellow"
			if(3)
				suit_name = "Blue"
			if(4)
				suit_name = "Green"
			if(5)
				plain_suit = FALSE
		}
		if(plain_suit){
			if(num < 10){
				card.name = "[suit_name] [capitalize(num2text(num))]"
			} else {
				card.name = "[suit_name] [numToSpecial[num]]"
			}

		} else{
			if(num == 1){
				card.name = "Wild Card"
			} else{ //If I fuck up generation this will get people complaining
				card.name = "Wild Draw 4"
				num = 2;
			}
		}
		card.icon_state = "[card_style]-[suit_num]-[card_num]"
		update_card_information(card)
		card.update_stored_info()

