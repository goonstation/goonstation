#define WEAPON_VENDOR_CATEGORY_SIDEARM "sidearm"
#define WEAPON_VENDOR_CATEGORY_LOADOUT "loadout"
#define WEAPON_VENDOR_CATEGORY_UTILITY "utility"
#define WEAPON_VENDOR_CATEGORY_ASSISTANT "assistant"

/obj/item/device/weapon_vendor
	name = "Weapon Vendor Uplink"
	icon = 'icons/obj/items/device.dmi'
	desc = "A modified uplink which allows you to buy a loadout on the go. Nifty!"
	icon_state = "uplink" //replace later
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	flags = TABLEPASS | FPRINT

	var/sound_token = 'sound/machines/capsulebuy.ogg'
	var/sound_buy = 'sound/machines/spend.ogg'
	var/list/credits = list(WEAPON_VENDOR_CATEGORY_SIDEARM = 0, WEAPON_VENDOR_CATEGORY_LOADOUT = 0, WEAPON_VENDOR_CATEGORY_UTILITY = 0, WEAPON_VENDOR_CATEGORY_ASSISTANT = 0)
	var/list/datum/materiel_stock = list()
	var/token_accepted = /obj/item/requisition_token
	var/log_purchase = FALSE

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "WeaponVendor", src.name)
			ui.open()

	ui_static_data(mob/user)
		. = list("stock" = list())

		for (var/datum/materiel/M as anything in materiel_stock)
			.["stock"] += list(list(
				"ref" = "\ref[M]",
				"name" = M.name,
				"description" = M.description,
				"cost" = M.cost,
				"category" = M.category,
			))

	ui_data(mob/user)
		. = list(
			"credits" = src.credits,
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return

		switch(action)
			if ("purchase")
				var/datum/materiel/M = locate(params["ref"]) in materiel_stock
				if (src.credits[M.category] >= M.cost)
					src.credits[M.category] -= M.cost
					var/atom/A = new M.path(src.loc)
					playsound(src.loc, sound_buy, 80, 1)
					src.vended(A)
					usr.put_in_hand_or_eject(A)
					return TRUE

	attackby(obj/item/I, mob/user)
		if(istype(I, token_accepted))
			user.drop_item(I)
			qdel(I)
			accepted_token(I, user)
		else
			..()

	attack_self(mob/user)
		return ui_interact(user)

	proc/accepted_token(token, mob/user)
		src.ui_interact(user)
		playsound(src.loc, sound_token, 80, 1)
		boutput(user, "<span class='notice'>You insert the requisition token into [src].</span>")
		if(log_purchase)
			logTheThing(LOG_DEBUG, user, "inserted [token] into [src] at [log_loc(get_turf(src))]")


	proc/vended(atom/A)
		if(log_purchase)
			logTheThing(LOG_DEBUG, usr, "bought [A] from [src] at [log_loc(get_turf(src))]")
		.= 0

/obj/item/device/weapon_vendor/syndicate
	name = "Syndicate Weapons Vendor"
	icon = 'icons/obj/items/device.dmi'
	desc = "A modified uplink which allows you to buy a loadout on the go. Nifty!"
	icon_state = "uplink" //replace later
	item_state = "electronic"
	token_accepted = /obj/item/requisition_token/syndicate
	log_purchase = TRUE

	New()
		..()
		// List of avaliable objects for purchase
		materiel_stock += new/datum/materiel/sidearm/smartgun
		materiel_stock += new/datum/materiel/sidearm/pistol
		materiel_stock += new/datum/materiel/sidearm/revolver

		materiel_stock += new/datum/materiel/loadout/assault
		materiel_stock += new/datum/materiel/loadout/heavy
		materiel_stock += new/datum/materiel/loadout/grenadier
		materiel_stock += new/datum/materiel/loadout/infiltrator
		materiel_stock += new/datum/materiel/loadout/scout
		materiel_stock += new/datum/materiel/loadout/medic
		materiel_stock += new/datum/materiel/loadout/firebrand
		materiel_stock += new/datum/materiel/loadout/engineer
		materiel_stock += new/datum/materiel/loadout/marksman
		materiel_stock += new/datum/materiel/loadout/knight
		materiel_stock += new/datum/materiel/loadout/custom

		materiel_stock += new/datum/materiel/utility/belt
		materiel_stock += new/datum/materiel/utility/knife
		materiel_stock += new/datum/materiel/utility/rpg_ammo
		materiel_stock += new/datum/materiel/utility/donk
		materiel_stock += new/datum/materiel/utility/sarin_grenade
		materiel_stock += new/datum/materiel/utility/noslip_boots
		materiel_stock += new/datum/materiel/utility/bomb_decoy
		materiel_stock += new/datum/materiel/utility/comtac

	accepted_token()
		src.credits[WEAPON_VENDOR_CATEGORY_SIDEARM]++
		src.credits[WEAPON_VENDOR_CATEGORY_LOADOUT]++
		src.credits[WEAPON_VENDOR_CATEGORY_UTILITY]++
		..()

/obj/item/device/weapon_vendor/syndicate/preloaded
	desc = "A pre-loaded uplink which allows you to buy a sidearm, loadout, and utility on the go. Nifty!"
	token_accepted = null
	credits = list(WEAPON_VENDOR_CATEGORY_SIDEARM = 1, WEAPON_VENDOR_CATEGORY_LOADOUT = 1, WEAPON_VENDOR_CATEGORY_UTILITY = 1, WEAPON_VENDOR_CATEGORY_ASSISTANT = 0)

#undef WEAPON_VENDOR_CATEGORY_SIDEARM
#undef WEAPON_VENDOR_CATEGORY_LOADOUT
#undef WEAPON_VENDOR_CATEGORY_UTILITY
#undef WEAPON_VENDOR_CATEGORY_ASSISTANT
