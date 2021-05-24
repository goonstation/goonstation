/*
    Lythine's space casino prefab
	Contents:
	 Item slot machine
	 Genetics gambling machine
	 Barbuddy
*/

// Item slot machine

/obj/submachine/slot_machine/item
	name = "Item Slot Machine"
	desc = "A slot machine that produces items rather than money. Somehow."
	icon_state = "slotsitem-off"
	mats = 40

	var/list/junktier = list( // junk tier, 60% chance
		"/obj/item/a_gift/easter",
		"/obj/item/raw_material/rock",
		"/obj/item/balloon_animal",
		"/obj/item/cigpacket",
		"/obj/item/clothing/shoes/moon",
		"/obj/item/fish/carp",
		"/obj/item/instrument/bagpipe",
		"/obj/item/clothing/under/gimmick/yay"
	)

	var/list/usefultier = list( // half decent tier, 30% chance
		"/obj/item/clothing/gloves/yellow",
		"/obj/item/bat",
		"/obj/item/reagent_containers/food/snacks/donkpocket/warm",
		"/obj/item/device/flash",
		"/obj/item/clothing/glasses/sunglasses",
		"/obj/vehicle/skateboard",
		"/obj/item/storage/firstaid/regular",
		"/obj/item/clothing/shoes/sandal"
	)

	var/list/raretier = list( // rare tier, 7% chance
		"/obj/item/hand_tele",
		"/obj/item/baton",
		"/obj/item/clothing/suit/armor/vest",
		"/obj/item/device/voltron",
		"/obj/item/gun/energy/phaser_gun"
	)

	var/list/veryraretier = list( // very rare tier, 0.2% chance
		"/obj/item/pipebomb/bomb/syndicate",
		"/obj/item/card/id/captains_spare",
		"/obj/item/sword_core",
		"/obj/item/sword",
		"/obj/item/storage/belt/wrestling"
	)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		switch(action)
			if ("insert_card")
				if (src.scan)
					return TRUE
				var/obj/O = usr.equipped()
				if (istype(O, /obj/item/card/id))
					boutput(usr, "<span class='notice'>You insert your ID card.</span>")
					usr.drop_item()
					O.set_loc(src)
					src.scan = O
					. = TRUE
			if ("play")
				if (src.working || !src.scan)
					return TRUE
				if (src.scan.money < 20)
					src.visible_message("<span class='subtle'><b>[src]</b> says, 'Insufficient money to play!'</span>")
					return TRUE
				src.scan.money -= 20
				src.plays++
				src.working = 1
				src.icon_state = "slotsitem-on"

				playsound(get_turf(src), "sound/machines/ding.ogg", 50, 1)
				. = TRUE
				ui_interact(usr, ui)
				SPAWN_DBG(2.5 SECONDS) // why was this at ten seconds, christ
					money_roll()
					src.working = 0
					src.icon_state = "slotsitem-off"

			if("eject")
				if(!src.scan)
					return TRUE // jerks doing that "hide in a chute to glitch auto-update windows out" exploit caused a wall of runtime errors
				usr.put_in_hand_or_eject(src.scan)
				src.scan = null
				src.working = FALSE
				src.icon_state = "slotsitem-off" // just in case, some fucker broke it earlier
				src.visible_message("<span class='subtle'><b>[src]</b> says, 'Thank you for playing!'</span>")
				. = TRUE

		src.add_fingerprint(usr)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "machineUsed")

	money_roll()
		var/roll = rand(1,500)
		var/exclamation = ""
		var/win_sound = "sound/machines/ping.ogg"
		var/obj/item/P = null

		if (roll <= 1) // very rare tier, 0.2% chance
			P = text2path(pick(veryraretier))
			win_sound = "sound/misc/airraid_loop_short.ogg"
			exclamation = "JACKPOT! "
		else if (roll > 1 && roll <= 15) // self destruction, 2.8% chance -- intentionally made higher than very rare tier so that this isnt just awesome free csaber every time all the time
			src.emag_act(null, null)
			return
		else if (roll > 15 && roll <= 50) // rare tier, 7% chance
			P = text2path(pick(raretier))
			win_sound =  "sound/musical_instruments/Bell_Huge_1.ogg"
			exclamation = "Big Winner! "
		else if (roll > 50 && roll <= 200) // half decent tier, 30% chance
			P = text2path(pick(usefultier))
			exclamation = "Winner! "
		else // junk tier, 60% chance
			P = text2path(pick(junktier))
			exclamation = "Winner! "

		if (P == null)
			return
		var/obj/item/prize = new P
		prize.loc = src.loc
		prize.layer += 0.1
		src.visible_message("<span class='subtle'><b>[src]</b> says, '[exclamation][src.scan.registered] has won [prize.name]!'</span>")
		playsound(get_turf(src), "[win_sound]", 55, 1)
		src.working = 0
		src.icon_state = "slotsitem-off"

	emag_act(var/mob/user, var/obj/item/card/emag/E) // Freak out and die
		src.icon_state = "slotsitem-malf"
		playsound(get_turf(src), "sound/misc/klaxon.ogg", 55, 1)
		src.visible_message("<span class='subtle'><b>[src]</b> says, 'WINNER! WINNER! JACKPOT! WINNER! JACKPOT! BIG WINNER! BIG WINNER!'</span>")
		playsound(src.loc, "sound/impact_sounds/Metal_Clang_1.ogg", 60, 1, pitch = 1.2)
		animate_shake(src,7,5,2)
		sleep(3.5 SECONDS)

		src.visible_message("<span class='subtle'><b>[src]</b> says, 'BIG WINNER! BIG WINNER!'</span>")
		playsound(src.loc, "sound/impact_sounds/Metal_Clang_2.ogg", 60, 1, pitch = 0.8)
		animate_shake(src,5,7,2)
		sleep(1.5 SECONDS)

		new/obj/decal/implo(src.loc)
		playsound(src, 'sound/effects/suck.ogg', 60, 1)
		if (src.scan)
			src.scan.set_loc(src.loc)
		qdel(src)
