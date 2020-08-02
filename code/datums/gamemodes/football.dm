/*
	super bowl 2053
*/


var/global/list/football_spawns = list("join" = list(), "blue" = list(), "red" = list(), "bluefield" = list(), "redfield" = list(), "football" = list())
var/global/list/list/datum/mind/football_players = list("blue" = list(), "red" = list())

#define FOOTBALL_PREGAME 1
#define FOOTBALL_INGAME 2
#define FOOTBALL_POSTSCORE 3
#define FOOTBALL_POSTGAME 4


/datum/game_mode/football
	name = "Football"
	config_tag = "football"
	var/score_red = 0
	var/score_blue = 0
	var/game_state = FOOTBALL_PREGAME
	var/time_left = 15 MINUTES
	var/time_next_state = 15 SECONDS
	var/obj/item/football/the_big_one/the_football = null
	var/last_tick = 0
	var/list/obj/decal/big_number/clock_num
	var/list/obj/decal/big_number/red_num
	var/list/obj/decal/big_number/blue_num
	do_antag_random_spawns = 0

	announce()
		boutput(world, "<B>Welcome to the Space American Football League's Space Bowl LXXXVII!</B>")
		boutput(world, "<B>Get ready to play some football!</B>")

	pre_setup()
		// EVERYONE IS A football player.
		for(var/client/C)
			var/mob/new_player/player = C.mob
			if (!istype(player)) continue
			if (player.ready)
				if (player.mind)
					src.init_player(player, 0, 1)

		time_left = 15 MINUTES
		time_next_state = 15 SECONDS

		clock_num = list(locate("football_clock1000"), locate("football_clock100"), locate("football_clock10"), locate("football_clock1"))
		red_num = list(locate("football_red100"), locate("football_red10"), locate("football_red1"))
		blue_num = list(locate("football_blue100"), locate("football_blue10"), locate("football_blue1"))

		return 1


		// Things we are skipping:
		// Antag selection. Everyone is an antag!
		// Antag weighting. We dont record this - otherwise playing this round would fuck your weighting chances


	post_setup()
		SPAWN_DBG(0)
			// yeah this is shit. i do not care
			var/delta = 0
			last_tick = ticker.round_elapsed_ticks
			src.update_game_clock()
			boutput(world, "Game starts in 15 seconds.")
			while (true)
				delta = ticker.round_elapsed_ticks - last_tick
				last_tick = ticker.round_elapsed_ticks
				time_next_state -= delta

				switch (src.game_state)
					if (FOOTBALL_PREGAME)
						if (time_next_state < 0)
							// GET OUT THERE AND FIGHT
							boutput(world, "<b>The next possession begins now!</b>")
							src.put_me_in_coach()
							src.game_state = FOOTBALL_INGAME
							src.time_next_state = 2 MINUTES
							if (!the_football)
								the_football = new /obj/item/football/the_big_one()
							the_football.set_loc(pick(football_spawns["football"]))

					if (FOOTBALL_INGAME)
						time_left -= delta
						src.update_game_clock()
						if (src.time_next_state < 0)
							boutput(world, "Respawning dead players. Next wave in thirty seconds...")
							// people in the lockers go into the game, dead people go to the lockers
							src.put_me_in_coach()
							src.reset_players()
							src.time_next_state = 30 SECONDS
						if (!the_football || the_football.qdeled)
							boutput(world, "how the hell did you clowns lose the goddamn football?????? what the fuck. respawning it at midfield!")
							the_football = new /obj/item/football/the_big_one()
							the_football.set_loc(pick(football_spawns["football"]))

						// update timer
						// idk occasionally respawn people

					if (FOOTBALL_POSTSCORE)
						if (time_next_state < 0)
							src.reset_players(0)
							src.time_next_state = 10 SECONDS
							src.game_state = FOOTBALL_PREGAME
							boutput(world, "Next possession in 10 seconds...")
					if (FOOTBALL_POSTGAME)
						// we just dont do anything
						return

				sleep(0.8 SECONDS)


	check_finished()
		if (time_left <= 0)
			src.game_state = FOOTBALL_POSTGAME
			return 1
		return 0


	proc/score_a_goal(var/team, var/points = 6)
		if (game_state != FOOTBALL_INGAME)
			// you cant. you cant DO that outside of the game you clown
			return
		switch(team)
			if ("red")
				src.score_red += points
			if ("blue")
				src.score_blue += points

		src.time_next_state = 5 SECONDS
		src.game_state = FOOTBALL_POSTSCORE
		boutput(world, "<h1>[points == 6 ? "Touchdown!" : "Toss in."]</h1><h2>Team [uppertext(team)] scores! [points] point\s.</h2> Next possession in 30 seconds...")
		update_scoreboard()
		sleep(0.5 SECONDS)
		the_football.visible_message("\The [src] registers the endzone and detonates!")
		sleep(0.5 SECONDS)
		if (the_football)
			the_football.blowthefuckup(100)
			qdel(the_football)
			the_football = null

	proc/update_scoreboard()
		src.update_score_numbers(red_num, score_red)
		src.update_score_numbers(blue_num, score_blue)


	proc/update_score_numbers(var/list/obj/decal/big_number/numbers, var/score)
		if (score >= 100)
			numbers[1].color = null
			numbers[1].icon_state = "num[clamp(round(score / 100), 0, 9)]"
		if (score >= 10)
			numbers[2].color = null
			numbers[2].icon_state = "num[clamp(round(score / 10) % 10, 0, 9)]"

		numbers[3].icon_state = "num[clamp(score % 10, 0, 9)]"


	proc/update_game_clock()

		var/m = round(time_left / 600)
		var/s = round(time_left / 10) % 60

		clock_num[1].icon_state = "num[clamp(round(m / 10), 0, 9)]"
		clock_num[2].icon_state = "num[clamp(m % 10, 0, 9)]"
		clock_num[3].icon_state = "num[clamp(round(s / 10), 0, 9)]"
		clock_num[4].icon_state = "num[clamp(s % 10, 0, 9)]"


	declare_completion()
		boutput(world,"<h1>FINISH!</h1><h2>Red team: [score_red] point\s</h2><h2>Blue team: [score_blue] point\s</h2>Thanks for playing this gimmick I guess, see you next time")
		update_game_clock()
		update_scoreboard()
		the_football.blowthefuckup(200)

	process()
		..()


	proc/put_me_in_coach()
		for (var/team in football_players)
			for (var/datum/mind/player in football_players[team])
				if (player.current && ishuman(player.current))
					if (istype(get_area(player.current), /area/football/staging))
						player.current.set_loc(pick(football_spawns["[team]field"]))


	proc/init_player(mob/M, var/team = 0, var/is_new = 0)
		var/mob/living/carbon/human/footballer = M
		if (istype(M, /mob/new_player))
			var/mob/new_player/N = M
			N.mind.assigned_role = "MODE"
			footballer = N.create_character(new /datum/job/football)

		if (!ishuman(footballer))
			boutput(M, "something went wrong. dunno what. sorry. football machine broke")
			return

		if (is_new)
			if (football_players["blue"].len == football_players["red"].len)
				team = pick("red", "blue")
			else if (football_players["blue"].len < football_players["red"].len)
				team = "blue"
			else
				team = "red"

			footballer.mind.special_role = team
			football_players[team] += footballer.mind

		footballer.equip_if_possible(new /obj/item/device/radio/headset(footballer), footballer.slot_ears)

		var/obj/item/card/id/captains_spare/I = new /obj/item/card/id/captains_spare(footballer) // for whatever reason, this is neccessary
		I.registered = "[footballer.name]"
		I.icon = 'icons/obj/items/card.dmi'
		I.icon_state = "fingerprint0"
		I.desc = "A tag for indicating what team you're on. Doesn't really matter."
		if (team == "blue")
			footballer.equip_if_possible(new /obj/item/clothing/suit/armor/football(footballer), footballer.slot_wear_suit)
			footballer.equip_if_possible(new /obj/item/clothing/head/helmet/football(footballer), footballer.slot_head)
			footballer.equip_if_possible(new /obj/item/clothing/under/football(footballer), footballer.slot_w_uniform)
			I.name = "Blue Team"
			I.assignment = "Blue Team"
			I.color = "#0000ff"
		else
			footballer.equip_if_possible(new /obj/item/clothing/suit/armor/football/red(footballer), footballer.slot_wear_suit)
			footballer.equip_if_possible(new /obj/item/clothing/head/helmet/football/red(footballer), footballer.slot_head)
			footballer.equip_if_possible(new /obj/item/clothing/under/football/red(footballer), footballer.slot_w_uniform)
			I.name = "Red Team"
			I.assignment = "Red Team"
			I.color = "#ff0000"

		footballer.equip_if_possible(new /obj/item/clothing/shoes/cleats(footballer), footballer.slot_shoes)

		footballer.equip_if_possible(I, footballer.slot_wear_id)
		//footballer.Equip_Bank_Purchase(footballer.mind.purchased_bank_item)
		footballer.set_clothing_icon_dirty()
		footballer.set_loc(pick(football_spawns[team]))
		boutput(footballer, "You're on the [team] team! The football is to your [team == "red" ? "LEFT" : "RIGHT"]. Carry it all the way to the [team == "red" ? "LEFT" : "RIGHT"] endzone to score!")



	proc/reset_players(var/dead_only = 1)

		for (var/team in football_players)
			for (var/datum/mind/player in football_players[team])
				try
					if (!player.current || isdead(player.current))
						if (!player.current.client)
							continue //ZeWaka: fix for null.preferences
						var/mob/living/carbon/human/newbody = new()
						player.current.client.preferences.copy_to(newbody, player.current, 1)

						if (player) //Mind transfer also handles key transfer.
							player.transfer_to(newbody)
						else //Oh welp, still need to move that key!
							newbody.key = player.key
						src.init_player(newbody, team)
					else if (!dead_only && ishuman(player.current))
						player.current.full_heal()
						player.current.set_loc(pick(football_spawns[team]))
				catch
					// do fucking nothing just keep going thanks

		/*
		if(!isdead(src) || !src.mind || !ticker || !ticker.mode)
		return

		var/mob/living/carbon/human/newbody = new()
		if (!src.client) return //ZeWaka: fix for null.preferences
		src.client.preferences.copy_to(newbody,src,1)
		newbody.real_name = src.real_name


		if (src.mind) //Mind transfer also handles key transfer.
			src.mind.transfer_to(newbody)
		else //Oh welp, still need to move that key!
			newbody.key = src.key
		equip_battler(newbody)
		newbody.set_clothing_icon_dirty()
		newbody.set_loc(pick(ass_arena_spawn).loc)
		return
		*/
