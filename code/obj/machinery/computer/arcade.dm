/*
 *	Arcade -- An arcade cabinet.
 */

TYPEINFO(/obj/machinery/computer/arcade)
	mats = 10

/obj/machinery/computer/arcade
	name = "arcade machine"
	icon = 'icons/obj/computer.dmi'
	icon_state = "arcade"
	deconstruct_flags = DECON_MULTITOOL
	circuit_type = /obj/item/circuitboard/arcade
	var/enemy_name = "Space Villian"
	var/temp = "Winners Don't Use Spacedrugs" //Temporary message, for attack messages, etc
	var/player_hp = 30 //Player health/attack points
	var/player_mp = 10
	var/enemy_hp = 45 //Enemy health/attack points
	var/enemy_mp = 20
	var/gameover = 0
	var/blocked = 0 //Player cannot attack/heal while set
	desc = "An arcade machine, you can win wonderful prizes!"

	light_r =0.7
	light_g = 0.96
	light_b = 0.96

/obj/machinery/computer/arcade/New()
	..()
	var/name_action
	var/name_part1
	var/name_part2

	name_action = pick("Defeat ", "Annihilate ", "Save ", "Strike ", "Stop ", "Destroy ", "Robust ", "Romance ")

	name_part1 = pick("the Automatic ", "Farmer ", "Lord ", "Professor ", "the Evil ", "the Dread King ", "the Space ", "Lord ")
	name_part2 = pick("Melonoid", "Murdertron", "Sorcerer", "Ruin", "Jeff", "Ectoplasm", "Crushulon")

	src.enemy_name = replacetext((name_part1 + name_part2), "the ", "")
	src.name = (name_action + name_part1 + name_part2)

/obj/machinery/computer/arcade/attack_hand(mob/user)
	if(..())
		return
	show_ui(user)
	return

/obj/machinery/computer/arcade/proc/show_ui(var/mob/user)
	src.add_dialog(user)
	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a>"
	dat += "<center><h4>[src.enemy_name]</h4></center>"

	dat += "<br><center><h3>[src.temp]</h3></center>"
	dat += "<br><center>Health: [src.player_hp] | Magic: [src.player_mp] | Enemy Health: [src.enemy_hp]</center>"

	if (src.gameover)
		dat += "<center><b><a href='byond://?src=\ref[src];newgame=1'>New Game</a>"
	else
		dat += "<center><b><a href='byond://?src=\ref[src];attack=1'>Attack</a> | "
		dat += "<a href='byond://?src=\ref[src];heal=1'>Heal</a> | "
		dat += "<a href='byond://?src=\ref[src];charge=1'>Recharge Power</a>"

	dat += "</b></center>"

	user.Browse(dat, "window=arcade")
	onclose(user, "arcade")

/obj/machinery/computer/arcade/Topic(href, href_list)
	//Just check if we're in range for handhelds
	if(..() && (!istype(src, /obj/machinery/computer/arcade/handheld)))
		return
	else if (!in_interact_range(src, usr))
		return

	if (!src.blocked)
		if (href_list["attack"])
			if(cheat_check()) return
			src.blocked = 1
			var/attackamt = rand(2,6)
			src.temp = "You attack for [attackamt] damage!"
			src.updateUsrDialog()

			sleep(1 SECOND)
			src.enemy_hp -= attackamt
			src.arcade_action()

		else if (href_list["heal"])
			if(cheat_check()) return
			src.blocked = 1
			var/pointamt = rand(1,3)
			var/healamt = rand(6,8)
			src.temp = "You use [pointamt] magic to heal for [healamt] damage!"
			src.updateUsrDialog()

			sleep(1 SECOND)
			src.player_mp -= pointamt
			src.player_hp += healamt
			src.blocked = 1
			src.updateUsrDialog()
			src.arcade_action()

		else if (href_list["charge"])
			if(cheat_check()) return
			src.blocked = 1
			var/chargeamt = rand(4,7)
			src.temp = "You regain [chargeamt] points"
			src.player_mp += chargeamt

			src.updateUsrDialog()
			sleep(1 SECOND)
			src.arcade_action()

	if (href_list["close"])
		src.remove_dialog(usr)
		usr.Browse(null, "window=arcade")

	else if (href_list["newgame"]) //Reset everything
		temp = "New Round"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = 0

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/arcade/proc/arcade_action()
	//No more vending prizes due to href exploits
	if(src.gameover)
		return

	var/mob/living/carbon/human/H = usr
	if (istype(H))
		if (H.sims)
			H.sims.affectMotive("fun", 4)
	if ((src.enemy_mp <= 0) || (src.enemy_hp <= 0))
		src.gameover = 1
		src.temp = "[src.enemy_name] has fallen! Rejoice!"
		var/obj/item/prize
		var/prizeselect = rand(1,8)
		switch(prizeselect)
			if(1)
				var/obj/item/spacecash/P = new /obj/item/spacecash
				P.setup(src.loc)
				prize = P
				prize.name = "space ticket"
				prize.desc = "It's almost like actual currency!"
			if(2)
				if (isrestrictedz(z))
					var/obj/item/spacecash/P = new /obj/item/spacecash
					P.setup(src.loc)
					prize = P
					prize.name = "space ticket"
					prize.desc = "It's almost like actual currency!"
				else
					prize = new /obj/item/device/radio/beacon(src.loc)
					prize.name = "electronic blink toy game"
					prize.anchored = UNANCHORED
					prize.desc = "Blink.  Blink.  Blink."
			if(3)
				prize = new /obj/item/device/light/zippo(src.loc)
				prize.name = "Burno Lighter"
				prize.desc = "Almost like a decent lighter!"
			if(4)
				prize = new /obj/item/toy/sword(src.loc)
			if(5)
				prize = new /obj/item/instrument/harmonica(src.loc)
				prize.name = "reverse harmonica"
				prize.desc = "To the untrained eye it is like any other harmonica, but the professional will notice that it is BACKWARDS."
			if(6)
				prize = new /obj/item/wrench/gold(src.loc)
			if(7)
				prize = new /obj/item/firework(src.loc)
				prize.icon = 'icons/obj/items/device.dmi'
				prize.icon_state = "shield0"
				prize.name = "decloaking device"
				prize.desc = "A device for removing cloaks. Made in Space-Taiwan."
				prize:det_time = 5
			if(8)
				prize = new /obj/item/toy/plush(src.loc)


	else if ((src.enemy_mp <= 5) && (prob(70)))
		var/stealamt = rand(2,3)
		src.temp = "[src.enemy_name] steals [stealamt] of your power!"
		src.player_mp -= stealamt
		src.updateUsrDialog()

		if (src.player_mp <= 0)
			src.gameover = 1
			sleep(1 SECOND)
			src.temp = "You have been drained! GAME OVER"

	else if ((src.enemy_hp <= 10) && (src.enemy_mp > 4))
		src.temp = "[src.enemy_name] heals for 4 health!"
		src.enemy_hp += 4
		src.enemy_mp -= 4

	else
		var/attackamt = rand(3,6)
		src.temp = "[src.enemy_name] attacks for [attackamt] damage!"
		src.player_hp -= attackamt

	if ((src.player_mp <= 0) || (src.player_hp <= 0))
		src.gameover = 1
		src.temp = "You have been crushed! GAME OVER"

	src.blocked = 0
	return

/obj/machinery/computer/arcade/proc/cheat_check()
	//Call this proc in attack / heal / recharge code before doing work. If called when the game is over someone is a cheating scrubbaroni
	if(src.gameover)
		show_ui(usr)
		return 1
	else
		return 0

/obj/machinery/computer/arcade/power_change()

	if(status & BROKEN)
		icon_state = "arcadeb"
	else
		if( powered() )
			icon_state = initial(icon_state)
			status &= ~NOPOWER
		else
			SPAWN(rand(0, 15))
				src.icon_state = "arcade0"
				status |= NOPOWER
