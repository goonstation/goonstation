/obj/item/device/crucifykit
	name = "Hammer and Nails"
	desc = "If anyone asks, this is for hanging a painting"
	icon = 'icons/obj/items/items.dmi' //change icon
	icon_state = "tinyhammer" //change icon
	var/nails_left = 4 //figure this system out
	is_syndicate = 1


	New()
		..()

	attack(mob/M, mob/user)



		//TODO
		//allow for creation of cross - just go botch some code in the construction file together
		//make it so you can crucify people
		//they need to have nothing in hands
		//crucifying puts a nail in each hand - they can't interact but someone can pull them out
		//if someone dies on the cross, they can't be pulled down
		//can also be used as a melee weapon when the nails run out
		//add objective to crucify someone on the crew
