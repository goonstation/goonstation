/obj/item/card_group/solo
	card_style = "solo"
	total_cards = 108
	card_name = "SOLO"

	New()
		..()
		//Add special cards
		for(var/i in 1 to 4)
			stored_cards += new /obj/item/playing_card/solo(src, 5, 0)
			stored_cards += new /obj/item/playing_card/solo(src, 5, 1)

		//Add one set of zeroes
		for(var/i in 1 to 4)
			stored_cards += new /obj/item/playing_card/solo(src,i,0)

		//Do rest of the numbers
		for(var/i in 1 to 4)
			for(var/j in 1 to 12)
				stored_cards += new /obj/item/playing_card/solo(src, i, j)
				stored_cards += new /obj/item/playing_card/solo(src, i, j)



		update_group_sprite()



/obj/item/card_box/solo
	box_style = "red"
	name = "box of SOLO cards"

	New()
		..()
		stored_deck = new /obj/item/card_group/solo(src)

/obj/item/playing_card/solo
	var/static/numToSpecial = list("10"="Block", "11"="Reverse", "12"="Draw 2")

	New(atom/loc, var/suit, var/num)
		..()
		var/plain_suit = TRUE
		var/suit_name = ""
		switch(suit)
			if(1)
				suit_name = "Eldritch"
			if(2)
				suit_name = "Martian"
			if(3)
				suit_name = "Precursor"
			if(4)
				suit_name = "Wizard"
			if(5)
				plain_suit = FALSE
		if(plain_suit)
			if(num < 10)
				name = "[suit_name] [capitalize(num2text(num))]"
			else
				name = "[suit_name] [numToSpecial["[num]"]]"


		else
			if(num == 0)
				name = "Wild Card"
			else  //If I fuck up generation this will get people complaining
				name = "Wild Draw 4"
				num = 1
		icon_state = "solo-[suit]-[num]"
		update_stored_info()
		//Only meant to be used as with the solo card-game generation
		//Same as calling update_card_information on card holder
		card_name = "SOLO"
		card_style = "solo"
		total_cards = 108
