/obj/item/card_group/mono
	card_style = "mono"
	total_cards = 108
	card_name = "mono"
	/list/numToSpecial = list("10"="Block", "11"="Reverse", "12"="Draw 2")

	New()
		..()
		//Add special cards
		for(var/i = 1, i<5, i++){
			var/obj/item/playing_card/wild = new /obj/item/playing_card(src)
			var/obj/item/playing_card/fuckYou = new /obj/item/playing_card(src)
			stored_cards += wild;
			stored_cards += fuckYou;
			setMonoCard(wild, 5, 0);
			setMonoCard(fuckYou, 5, 1);
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

	proc/setMonoCard(var/obj/item/playing_card/target , var/suit, var/num)
		var/plain_suit = TRUE;
		var/suit_name = "";
		switch(suit)
			if(1)
				suit_name = "Green"
			if(2)
				suit_name = "Blue"
			if(3)
				suit_name = "Yellow"
			if(4)
				suit_name = "Red"
			if(5)
				plain_suit = FALSE
		if(plain_suit){
			if(num < 10){
				target.name = "[suit_name] [capitalize(num2text(num))]"
			} else {
				target.name = "[suit_name] [numToSpecial["[num]"]]"
			}

		} else{
			if(num == 0){
				target.name = "Wild Card"
			} else{ //If I fuck up generation this will get people complaining
				target.name = "Wild Draw 4"
				num = 1;
			}
		}
		target.icon_state = "[card_style]-[suit]-[num]"
		update_card_information(target)
		target.update_stored_info()

