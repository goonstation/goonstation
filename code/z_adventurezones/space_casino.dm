/*
    Lythine's space casino prefab
	Contents:
	 Item slot machine
	 Misc props
*/

// Item slot machine

TYPEINFO(/obj/submachine/slot_machine/item)
	mats = null

/obj/submachine/slot_machine/item
	name = "Item Slot Machine"
	desc = "A slot machine that produces items rather than money. Somehow."
	icon_state = "slotsitem-off"
	var/uses = 0
	max_roll = 1000
	icon_base = "slotsitem"

	var/list/junktier = list( // junk tier, 60%
		/obj/item/a_gift/easter,
		/obj/item/raw_material/rock,
		/obj/item/balloon_animal,
		/obj/item/cigpacket,
		/obj/item/clothing/shoes/moon,
		/obj/item/reagent_containers/food/fish/carp,
		/obj/item/instrument/bagpipe,
		/obj/item/clothing/under/gimmick/yay,
		/obj/item/scrap,
		/obj/item/paper_bin,
		/obj/item/item_box/gold_star,
		/obj/item/storage/box/costume/hotdog,
		/mob/living/critter/small_animal/cockroach,
		/obj/item/device/light/flashlight,
		/obj/item/kitchen/utensil/knife,
		/obj/item/staple_gun,
		/obj/item/old_grenade/spawner/cheese_sandwich,
		/obj/item/old_grenade/spawner/banana_corndog,
		/obj/item/rubberduck,
		/obj/item/clothing/gloves/yellow/unsulated
	)

	var/list/usefultier = list( // half decent tier, 15% chance
		/obj/item/bat,
		/obj/item/reagent_containers/food/snacks/donkpocket/warm,
		/obj/item/device/flash,
		/obj/vehicle/skateboard,
		/obj/item/storage/firstaid/regular,
		/obj/item/cigpacket/random,
		/obj/item/clothing/mask/gas,
		/obj/critter/domestic_bee,
		/obj/item/card/id/dabbing_license,
		/obj/item/clothing/glasses/sunglasses/tanning
	)

	var/list/raretier = list( // rare tier, 2% chance
		/obj/item/clothing/gloves/yellow,
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/clothing/shoes/sandal/magic,
		/obj/item/hand_tele,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/gimmickbomb/hotdog,
		/obj/item/card/id/captains_spare,
		/obj/item/storage/banana_grenade_pouch,
		/mob/living/critter/brullbar, // have fun!
		/obj/item/artifact/teleport_wand,
		/obj/item/storage/firstaid/crit
	)

	money_roll(waver)
		var/roll = rand(1,max_roll)
		var/exclamation = ""
		var/win_sound = 'sound/machines/ping.ogg'
		var/prize_type = null

		if(roll > (max_roll - uses * 20)) // failure chances increase by 2% every roll
			src.emag_act(null, null) // bye bye!
			prize_type = /obj/item/assembly/time_ignite_butt/prearmed
			exclamation = "Big Loser! Goodbye! "
			win_sound = 'sound/musical_instruments/Trombone_Failiure.ogg'
			return
		else if (roll <= 20 && wager > 250) // rare tier, 2% chance, only on high wagers
			prize_type = pick(raretier)
			win_sound = 'sound/misc/airraid_loop_short.ogg'
			exclamation = "JACKPOT! "
			src.uses += 20
		else if (roll > 20 && roll <= 170) // half decent tier, 15% chance
			prize_type = pick(usefultier)
			exclamation = "Big Winner! "
			src.uses += 5
		else if(roll > 170 && roll <= 770) // junk tier
			prize_type = pick(junktier)
			exclamation = "Winner! "
			src.uses++
		else//rock, 23%, doesn't increment uses
			exclamation = "Loser! "

		if (!prize_type)
			prize_type = /obj/item/raw_material/rock
		var/obj/item/prize = new prize_type
		prize.set_loc(src.loc)
		prize.layer += 0.1
		src.visible_message(SPAN_SUBTLE("<b>[src]</b> says, '[exclamation][src.scan.registered] has won \an [prize.name]!'"))
		playsound(get_turf(src), "[win_sound]", 55, 1)

	emag_act(var/mob/user, var/obj/item/card/emag/E) // Freak out and die
		src.icon_state = "slotsitem-malf"
		playsound(get_turf(src), 'sound/misc/klaxon.ogg', 55, 1)
		src.visible_message(SPAN_SUBTLE("<b>[src]</b> says, 'WINNER! WINNER! JACKPOT! WINNER! JACKPOT! BIG WINNER! BIG WINNER!'"))
		playsound(src.loc, 'sound/impact_sounds/Metal_Clang_1.ogg', 60, 1, pitch = 1.2)
		animate_shake(src,7,5,2)
		sleep(3.5 SECONDS)

		src.visible_message(SPAN_SUBTLE("<b>[src]</b> says, 'BIG WINNER! BIG WINNER!'"))
		playsound(src.loc, 'sound/impact_sounds/Metal_Clang_2.ogg', 60, 1, pitch = 0.8)
		animate_shake(src,5,7,2)
		sleep(1.5 SECONDS)

		new/obj/decal/implo(src.loc)
		playsound(src, 'sound/effects/suck.ogg', 60, TRUE)
		if (src.scan)
			src.scan.set_loc(src.loc)
		qdel(src)
		return TRUE

// Misc props

/obj/fakeobject/genetics_scrambler
	name = "modified GeneTek Scanner"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "scanner_0"
	anchored = ANCHORED
	density = 1

/obj/fakeobject/chefbot
	name = "inactive chefbot"
	desc = "It seems to still be sparking..."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "chefbot0"
	anchored = ANCHORED

/obj/fakeobject/brokengamblebot
	name = "inactive gambling robot"
	icon = 'icons/obj/bots/robuddy/pr-6.dmi'
	icon_state = "body"

/obj/item/paper/space_casino_note
	name = "note"
	info = {"I don't care if it's "not safe" or "we don't know how it works", we're about to go out of business!<br>
			I tested it and all I got were some clothes and food, it's safe enough to be making us money.<br>
			I'm putting the machine out for all to play. That's final. I don't see your genetics THING making us anything other than a lawsuit anyway.<br><br>

			P.S. Tell me if you see any suspicious pods outside, I'm starting to get paranoid.
			"}
