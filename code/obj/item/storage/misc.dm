
/obj/item/storage/box/mousetraps
	name = "\improper Pest-B-Gon Mousetraps box"
	desc = "WARNING: Keep out of reach of children."
	icon_state = "mousetraps"
	spawn_contents = list(/obj/item/mousetrap = 7)

/obj/item/storage/box/nerd_kit
	name = "tabletop gaming kit"
	desc = "It's the famous carmine box starter set for Syndicates & Stations, Fifth Edition."
	icon_state = "nerdkit"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box-red"
	spawn_contents = list(
		/obj/item/paper/book/DNDrulebook,
		/obj/item/dice,
		/obj/item/dice/d4,
		/obj/item/dice/d8,
		/obj/item/dice/d12,
		/obj/item/dice/d20,
		/obj/item/dice/d100
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

//equipment kits for the staff assignment kiosk

/obj/item/storage/box/staffkit/civ
	name = "catering assistant kit"
	desc = "A slightly stale-smelling set of equipment."
	spawn_contents = list(/obj/item/clothing/under/rank/staffciv,
		/obj/item/device/radio/headset/civilian,
		/obj/item/clothing/head/souschefhat,
		/obj/item/clothing/gloves/latex,
		/obj/item/satchel/hydro,
		/obj/item/spraybottle/cleaner)

/obj/item/storage/box/staffkit/eng
	name = "engineering assistant kit"
	desc = "A slightly stale-smelling set of equipment."
	spawn_contents = list(/obj/item/clothing/under/rank/staffeng,
		/obj/item/device/radio/headset/engineer,
		/obj/item/crowbar,
		/obj/item/clothing/head/emerg,
		/obj/item/clothing/suit/space/emerg,
		/obj/item/mining_tool/power_pick,
		/obj/item/satchel/mining)

/obj/item/storage/box/staffkit/med
	name = "medical assistant kit"
	desc = "A slightly stale-smelling set of equipment."
	spawn_contents = list(/obj/item/clothing/under/rank/staffmed,
		/obj/item/device/radio/headset/medical,
		/obj/item/reagent_containers/emergency_injector/epinephrine,
		/obj/item/device/analyzer/healthanalyzer,
		/obj/item/reagent_containers/mender/brute,
		/obj/item/reagent_containers/mender/burn,
		/obj/item/reagent_containers/pill/salbutamol)

/obj/item/storage/box/staffkit/res
	name = "research assistant kit"
	desc = "A slightly stale-smelling set of equipment."
	spawn_contents = list(/obj/item/clothing/under/rank/staffres,
		/obj/item/device/radio/headset/research,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/gloves/latex,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/device/reagentscanner)

