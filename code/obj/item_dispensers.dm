//////////
//PARENT//
//////////

/obj/item_dispenser
	name = "item dispenser"
	desc = "A storage container that easily dispenses items."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dispenser_handcuffs"
	pixel_y = 28
	anchored = 1
	var/filled_icon_state = "" //i tried to do this in a smart way but it was a PITA so here have this stinky code instead
	var/empty_icon_state = "" //autoset by the s y s t e m, dont set this yourself
	var/amount = 3 //how many items does it have?
	var/deposit_type = null //this is a type that this item will accept to "reload" itself
	var/withdraw_type = null //this is a type that this item will dispense
	var/cant_deposit = 0 //set this to 1 if you want people to not be able to put items into it
	var/cant_withdraw = 0 //set this to 1 if you want people to not be able to take items out of it (why would you ever use this? why????)
	var/display_amount = 1 //displays amount of item in dispenser

	New()
		..()
		src.empty_icon_state = "[src.filled_icon_state]0"
		src.update_icon()

	get_desc()
		if(display_amount)
			. += "There's [src.amount] left."

	attackby(obj/item/W as obj, mob/user as mob)
		if (src.cant_deposit)
			..()
			return
		if (istype(W, src.deposit_type))
			user.u_equip(W)
			src.amount++
			src.update_icon()
			boutput(user, "<span class='notice'>You put \the [W] into \the [src]. [display_amount ? "There's [src.amount] left.": null ]</span>")
			qdel(W)

	attack_hand(mob/user as mob)
		add_fingerprint(user)
		if (src.cant_withdraw)
			..()
			return
		if (src.amount >= 1)
			src.amount--
			src.update_icon()
			var/obj/item/I = new src.withdraw_type
			boutput(user, "<span class='notice'>You put \the [I] into \the [src]. [display_amount ? "There's [src.amount] left.": null ]</span>")
			user.put_in_hand_or_drop(I)
		else
			boutput(user, "<span class='alert'>There's nothing in \the [src] to take!</span>")

	proc/update_icon()
		if (src.amount <= 0)
			src.icon_state = src.empty_icon_state
		else
			src.icon_state = src.filled_icon_state

///////////////////
//ITEM DISPENSERS//
///////////////////

/obj/item_dispenser/handcuffs
	name = "handcuffs dispenser"
	desc = "A storage container that easily dispenses handcuffs."
	icon_state = "dispenser_handcuffs"
	filled_icon_state = "dispenser_handcuffs"
	deposit_type = /obj/item/handcuffs
	withdraw_type = /obj/item/handcuffs

/obj/item_dispenser/latex_gloves
	name = "latex gloves dispenser"
	desc = "A storage container that easily dispenses latex gloves."
	icon_state = "dispenser_gloves"
	filled_icon_state = "dispenser_gloves"
	deposit_type = /obj/item/clothing/gloves/latex
	withdraw_type = /obj/item/clothing/gloves/latex

/obj/item_dispenser/medical_mask
	name = "medical mask dispenser"
	desc = "A storage container that easily dispenses medical masks."
	icon_state = "dispenser_mask"
	filled_icon_state = "dispenser_mask"
	deposit_type = /obj/item/clothing/mask/medical
	withdraw_type = /obj/item/clothing/mask/medical

/obj/item_dispenser/perscription_glasses
	name = "perscription glasses dispenser"
	desc = "A storage container that easily dispenses perscription glasses."
	icon_state = "dispenser_glasses"
	filled_icon_state = "dispenser_glasses"
	deposit_type = /obj/item/clothing/glasses/regular
	withdraw_type = /obj/item/clothing/glasses/regular

/obj/item_dispenser/idcarddispenser
	name = "ID card dispenser"
	desc = "A storage container that easily dispenses fresh ID cards. It can be refilled with paper."
	icon_state = "dispenser_id"
	filled_icon_state = "dispenser_id"
	deposit_type = /obj/item/paper
	withdraw_type = /obj/item/card/id
	amount = 7

	attack_hand(mob/user as mob)
		if (!src.cant_withdraw && src.amount >= 1)
			playsound(src.loc, "sound/machines/printer_dotmatrix.ogg", 25, 1)
		..()

/obj/item_dispenser/icedispenser
	name = "ice dispenser"
	desc = "It's a small freezer unit that produces ice. Looks like it's hooked into the station water mains."
	icon_state = "dispenser_ice"
	filled_icon_state = "dispenser_ice"
	withdraw_type = /obj/item/raw_material/ice
	deposit_type = null
	amount = 10000
	display_amount = 0
	pixel_y = 0
	flags = FPRINT | NOSPLASH

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/glass) || istype(W, /obj/item/reagent_containers/food/drinks))
			if (W.reagents.total_volume <= (W.reagents.maximum_volume - 10))
				W.reagents.add_reagent("ice", 10, null, (T0C - 50))
				user.visible_message("[user] adds some ice to the [W].",\
			"<span class='notice'>You add some ice to the [W].</span>")
			else
				boutput(user, "<span class='alert'>[W] is too full!</span>")
