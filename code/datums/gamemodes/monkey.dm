/datum/game_mode/monkey
	name = "monkey"
	config_tag = "monkey"

/datum/game_mode/monkey/announce()
	boutput(world, "<B>The current game mode is - Monkey!</B>")
	boutput(world, "<B>Some of your crew members have been infected by a mutageous virus!</B>")
	boutput(world, "<B>Escape on the shuttle but the humans have precedence!</B>")

/datum/game_mode/monkey/post_setup()
	SPAWN(5 SECONDS)
		var/list/players = list()
		for (var/mob/living/carbon/human/player in mobs)
			if (player.client)
				players += player

		if (players.len >= 3)
			var/amount = round((players.len - 1) / 3) + 1
			amount = min(4, amount)

			while (amount > 0)
				var/mob/living/carbon/human/player = pick(players)
				player.monkeyize()

				players -= player
				amount--

		for (var/mob/living/carbon/human/rabid_monkey in mobs)
			if (ismonkey(rabid_monkey))
				rabid_monkey.contract_disease(/datum/ailment/disease/monkey_madness,null,null,1)

/datum/game_mode/monkey/check_finished()
	if(emergency_shuttle.location == SHUTTLE_LOC_RETURNED)
		return 1

	return 0

/datum/game_mode/monkey/declare_completion()
	var/monkeywin = 0
	for(var/mob/living/carbon/human/monkey_player in mobs)
		if (!ismonkey(monkey_player))
			continue

		if (!isdead(monkey_player))
			if (in_centcom(monkey_player))
				monkeywin = 1
				break

	if(monkeywin)
		for(var/mob/living/carbon/human/human_player in mobs)
			if (ismonkey(human_player))
				continue

			if (!isdead(human_player))
				var/turf/location = get_turf(human_player.loc)
				if (istype(human_player.loc, /turf))
					if (in_centcom(human_player))
						monkeywin = 0
						break

	if (monkeywin)
		boutput(world, "<FONT size = 3><B>The monkies have won!</B></FONT>")
		for(var/mob/living/carbon/human/monkey_player in mobs)
			if (ismonkey(monkey_player) && monkey_player.client)
				boutput(world, "<B>[monkey_player.key] was a monkey.</B>")

	else
		boutput(world, "<FONT size = 3><B>The Research Staff has stopped the monkey invasion!</B></FONT>")
		for(var/mob/living/carbon/human/human_player in mobs)
			if (!ismonkey(human_player) && human_player.client)
				boutput(world, "<B>[human_player.key] was [human_player.real_name].</B>")

	return 1
