
/obj/item/storage/box/mousetraps
	name = "\improper Pest-B-Gon Mousetraps box"
	desc = "WARNING: Keep out of reach of children."
	icon_state = "mousetraps"
	spawn_contents = list(/obj/item/mousetrap = 7)

/obj/item/storage/box/nerd_kit
	name = "Tabletop Gaming Double Trouble Box Set"
	desc = "Two of your favorite tabletop roleplaying games, now in one box!"
	icon_state = "nerdkit"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box-red"
	spawn_contents = list(
		/obj/item/storage/box/nerd_kit/stations_and_syndicates,
		/obj/item/storage/box/nerd_kit/stationfinder
	)

/obj/item/storage/box/nerd_kit/stations_and_syndicates
	name = "Stations and Syndicates Starter Kit"
	desc = "It's the famous carmine box starter set for Stations and Syndicates, 9th edition."
	icon_state = "nerdkit"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box-red"
	spawn_contents = list(
		/obj/item/paper/book/from_file/DNDrulebook,
		/obj/item/paper/book/from_file/monster_manual_revised,
		/obj/item/storage/dicepouch,
		/obj/item/storage/dicepouch,
		/obj/item/storage/dicepouch,
		/obj/item/storage/dicepouch,
		/obj/item/storage/dicepouch
	)

/obj/item/storage/box/nerd_kit/stationfinder
	name = "Stationfinder Starter Kit"
	desc = "Contains everything you need to run a game of Stationfinder, First Edition"
	icon_state = "nerdkit"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box-red"
	spawn_contents = list(
		/obj/item/paper/book/from_file/DWrulebook,
		/obj/item/diceholder/dicebox,
		/obj/item/diceholder/dicebox,
		/obj/item/diceholder/dicebox,
		/obj/item/diceholder/dicebox,
		/obj/item/paper_bin,
		/obj/item/pen/pencil
	)

/obj/item/storage/box/balloonbox
	name = "balloon box"
	icon_state = "balloons"
	desc = "A box filled with an assortment of colored balloons."
	spawn_contents = list(/obj/item/reagent_containers/balloon = 7)

/obj/item/storage/box/pen
	name = "pen box"
	desc = "A box of pens."
	icon_state = "pen_box-temp"
	spawn_contents = list(/obj/item/pen = 4,
	/obj/item/pen/fancy,
	/obj/item/pen/red)

/obj/item/storage/box/crayon
	name = "crayon box"
	icon_state = "crayon_box-temp"
	desc = "Don't go outside the lines. You don't wanna know what happens to you if you do."
	spawn_contents = list(/obj/item/pen/crayon/random = 7)

/obj/item/storage/box/crayon/basic
	name = "basic crayon box"
	spawn_contents = list(/obj/item/pen/crayon/red,
	/obj/item/pen/crayon/orange,
	/obj/item/pen/crayon/yellow,
	/obj/item/pen/crayon/green,
	/obj/item/pen/crayon/aqua,
	/obj/item/pen/crayon/blue,
	/obj/item/pen/crayon/purple)

/obj/item/storage/box/marker
	name = "marker box"
	icon_state = "marker_box-temp"
	desc = "Don't go outside the lines. You don't wanna know what happens to you if you do."
	spawn_contents = list(/obj/item/pen/marker/random = 7)

/obj/item/storage/box/marker/basic
	name = "basic marker box"
	spawn_contents = list(/obj/item/pen/marker/red,
	/obj/item/pen/marker/orange,
	/obj/item/pen/marker/yellow,
	/obj/item/pen/marker/green,
	/obj/item/pen/marker/aqua,
	/obj/item/pen/marker/blue,
	/obj/item/pen/marker/purple)

/obj/item/storage/box/trash_bags
	name = "box of trash bags"
	desc = "Conveniently, once this box runs out of trash bags, you can throw it away in one of your new trash bags!!"
	icon_state = "trashybs" // a dumb name for a bad sprite, rip
	spawn_contents = list(/obj/item/clothing/under/trash_bag = 7)

/obj/item/storage/box/biohazard_bags
	name = "box of hazardous waste bags"
	desc = "Conveniently, once this box runs out of hazardous waste bags, you can throw it away in one of your new hazardous waste bags!! (Please be sure to bleed on it first, though, otherwise it's a bit of a waste of a bag.)"
	icon_state = "biohazard"
	spawn_contents = list(/obj/item/clothing/under/trash_bag/biohazard = 7)

/obj/item/storage/box/holywaterkit
	name = "do-it-yourself holy water kit"
	desc = "Just combine the ingredients with water! Free container with sample provided."
	icon_state = "holywaterkit"
	spawn_contents = list(/obj/item/reagent_containers/glass/bottle/mercury = 3,
	/obj/item/reagent_containers/food/drinks/bottle/wine = 3,
	/obj/item/reagent_containers/glass/bottle/holywater)

/obj/item/storage/box/misctools //used in CE locker
	name = "miscellaneous tools"
	desc = "A box full of tools, but distinctly seperate from a toolbox."
	icon_state = "box"
	spawn_contents = list(
		/obj/item/electronics/scanner,
		/obj/item/device/analyzer/atmospheric/upgraded,
		/obj/item/electronics/soldering,
		/obj/item/cargotele,
		/obj/item/lamp_manufacturer/organic,
		/obj/item/pinpointer/category/apcs/station,
		/obj/item/ore_scoop/prepared
	)
