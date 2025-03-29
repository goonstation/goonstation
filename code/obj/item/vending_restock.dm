/obj/item/vending/restock_cartridge
	name = "Empty restock cartridge"
	icon = 'icons/obj/items/vendcart.dmi'
	icon_state = "vendcart_base"
	desc = "An empty vanding machine restocking cartridge."
	throwforce = 1
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10
	var/vendingType = "empty" //vending machine path name ending for cartridge compatability check. I wanted to use reflection, but this was easier


/obj/item/vending/restock_cartridge/coffee
	name = "coffee restock cartridge"
	icon_state = "coffee"
	desc = "A cartridge that restocks coffee vending machines."
	vendingType = "coffee"

/obj/item/vending/restock_cartridge/snack
	name = "snack restock cartridge"
	icon_state = "snack"
	desc = "A cartridge that restocks snack vending machines."
	vendingType = "snack"

/obj/item/vending/restock_cartridge/cigarette
	name = "cigarette restock cartridge"
	icon_state = "cigarette"
	desc = "A cartridge that restocks cigarette vending machines."
	vendingType = "cigarette"

/obj/item/vending/restock_cartridge/medical
	name = "medical restock cartridge"
	icon_state = "medical"
	desc = "A cartridge that restocks medical vending machines."
	vendingType = "medical"

/obj/item/vending/restock_cartridge/chemistry
	name = "chemical restock cartridge"
	icon_state = "chemistry"
	desc = "A cartridge that restocks chemical vending machines."
	vendingType = "chemistry"

/obj/item/vending/restock_cartridge/medical_public
	name = "public medical restock cartridge"
	icon_state = "medical_public"
	desc = "A cartridge that restocks public medical vending machines."
	vendingType = "medical_public"

/obj/item/vending/restock_cartridge/security
	name = "security restock cartridge"
	icon_state = "security"
	desc = "A cartridge that restocks security vending machines."
	vendingType = "security"

/obj/item/vending/restock_cartridge/security_ammo
	name = "security ammo restock cartridge"
	icon_state = "security_ammo"
	desc = "A cartridge that restocks security ammo vending machines."
	vendingType = "security_ammo"

/obj/item/vending/restock_cartridge/cola
	name = "cola restock cartridge"
	icon_state = "cola"
	desc = "A cartridge that restocks cola vending machines."
	vendingType = "cola"

/obj/item/vending/restock_cartridge/mechanics
	name = "mechanics restock cartridge"
	icon_state = "mechanics"
	desc = "A cartridge that restocks mechanics vending machines."
	vendingType = "mechanics"

/obj/item/vending/restock_cartridge/computer3
	name = "computer3 restock cartridge"
	icon_state = "computer3"
	desc = "A cartridge that restocks computer3 vending machines."
	vendingType = "computer3"

/obj/item/vending/restock_cartridge/floppy
	name = "floppy restock cartridge"
	icon_state = "floppy"
	desc = "A cartridge that restocks floppy vending machines."
	vendingType = "floppy"

/obj/item/vending/restock_cartridge/pda
	name = "pda restock cartridge"
	icon_state = "pda"
	desc = "A cartridge that restocks pda vending machines."
	vendingType = "pda"

/obj/item/vending/restock_cartridge/book
	name = "book restock cartridge"
	icon_state = "book"
	desc = "A cartridge that restocks book vending machines."
	vendingType = "book"

/obj/item/vending/restock_cartridge/kitchen
	name = "kitchen restock cartridge"
	icon_state = "kitchen"
	desc = "A cartridge that restocks kitchen vending machines."
	vendingType = "kitchen"

/obj/item/vending/restock_cartridge/monkey
	name = "monkey restock cartridge"
	icon_state = "monkey"
	desc = "A cartridge that restocks monkey vending machines."
	vendingType = "monkey"

/obj/item/vending/restock_cartridge/magivend
	name = "magivend restock cartridge"
	icon_state = "vendcart_base" //no sprite yet
	desc = "A cartridge that restocks magivend vending machines."
	vendingType = "magivend"

/obj/item/vending/restock_cartridge/standard
	name = "standard restock cartridge"
	icon_state = "standard"
	desc = "A cartridge that restocks standard vending machines."
	vendingType = "standard"

/obj/item/vending/restock_cartridge/hydroponics
	name = "hydroponics restock cartridge"
	icon_state = "hydroponics"
	desc = "A cartridge that restocks hydroponics vending machines."
	vendingType = "hydroponics"

/obj/item/vending/restock_cartridge/alcohol
	name = "alcohol restock cartridge"
	icon_state = "alcohol"
	desc = "A cartridge that restocks alcohol vending machines."
	vendingType = "alcohol"

/obj/item/vending/restock_cartridge/chem
	name = "chem restock cartridge"
	icon_state = "vendcart_base" //no sprite yet
	desc = "A cartridge that restocks chem vending machines."
	vendingType = "chem"

/obj/item/vending/restock_cartridge/cards
	name = "card restock cartridge"
	icon_state = "cards"
	desc = "A cartridge that restocks cards vending machines."
	vendingType = "cards"

/obj/item/vending/restock_cartridge/capsule
	name = "capsule restock cartridge"
	icon_state = "capsule"
	desc = "A cartridge that restocks capsule vending machines."
	vendingType = "capsule"

/obj/item/vending/restock_cartridge/portamed
	name = "advanced medical restock cartridge"
	icon_state = "medical"
	desc = "A cartridge that restocks the portable nanomed vending machine."
	vendingType = "port_a_nanomed"

//---------------Job Clothing Vendors--------------//

/obj/item/vending/restock_cartridge/jobclothing
	name = "generic clothing restock cartridge"
	icon_state = "clothing"
	vendingType =  "jobclothing"

/obj/item/vending/restock_cartridge/jobclothing/security
	name = "security clothing restock cartridge"
	desc = "A cartridge that restocks security clothing vending machines."
	vendingType = "jobclothing/security"

/obj/item/vending/restock_cartridge/jobclothing/medical
	name = "medical clothing restock cartridge"
	desc = "A cartridge that restocks medical clothing vending machines."
	vendingType = "jobclothing/medical"

/obj/item/vending/restock_cartridge/jobclothing/engineering
	name = "engineering clothing restock cartridge"
	desc = "A cartridge that restocks engineering clothing vending machines."
	vendingType = "jobclothing/engineering"

/obj/item/vending/restock_cartridge/jobclothing/catering
	name = "catering clothing restock cartridge"
	desc = "A cartridge that restocks catering clothing vending machines."
	vendingType = "jobclothing/catering"

/obj/item/vending/restock_cartridge/jobclothing/research
	name = "research clothing restock cartridge"
	desc = "A cartridge that restocks research clothing vending machines."
	vendingType = "jobclothing/research"

/obj/item/vending/restock_cartridge/jobclothing/syndicate
	name = "syndicate clothing restock cartridge"
	desc = "A cartridge that restocks syndicate clothing vending machines."
	vendingType = "jobclothing/syndicate"
