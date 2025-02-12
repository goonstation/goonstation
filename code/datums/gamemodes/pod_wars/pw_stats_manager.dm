////////////////////////////player stats tracking datum//////////////////
/datum/pw_stats_manager
	var/list/player_stats = list()			//assoc list of ckey -> /datum/pw_player_stats

	var/list/item_rewards = list()		//assoc list of item name -> amount
	var/list/crate_list = list()			//assoc list of crate tier -> amount
	var/html_string

	proc/add_item_reward(var/string, var/team_num, var/amt = 1)
		switch(team_num)
			if (TEAM_NANOTRASEN)
				string = "NT,[string]"
			if (TEAM_SYNDICATE)
				string = "SY,[string]"

		item_rewards[string] += amt

	proc/add_crate(var/string, var/team_num)
		switch(team_num)
			if (TEAM_NANOTRASEN)
				string = "NT,[string]"
			if (TEAM_SYNDICATE)
				string = "SY,[string]"

		crate_list[string] ++

	proc/add_player(var/datum/mind/mind, var/initial_name, var/team_num, var/rank)
		//only add new stat tracker datum if one doesn't exist
		if (mind.ckey && player_stats[mind.ckey] == null)
			player_stats[mind.ckey] = new/datum/pw_player_stats(mind = mind, initial_name = initial_name, team_num = team_num, rank = rank )

	//team_num = team that just captured this point
	//computer = computer object for the point that has been captured. used for distance check currently.
	proc/inc_control_point_caps(var/team_num, var/obj/computer)
		for (var/ckey in player_stats)
			var/datum/pw_player_stats/stat = player_stats[ckey]
			if (stat.team_num != team_num)
				continue
			//if they are within 30 tiles of the capture point computer, it counts as helping!
			//I do the get_turf on the current mob in case they are in a pod. This is called Pod Wars after all...
			if (GET_DIST(get_turf(stat.mind?.current), computer) <= 30)
				stat.control_point_capture_count ++

	proc/inc_friendly_fire(var/mob/M)
		if (!ismob(M) || !M.ckey)
			return
		var/datum/pw_player_stats/stat = player_stats[M.ckey]
		if (istype(stat))
			stat.friendly_fire_count ++

	proc/inc_death(var/mob/M)
		if (!ismob(M) || !M.ckey)
			return
		var/datum/pw_player_stats/stat = player_stats[M.ckey]
		if (istype(stat))
			stat.death_count ++

		src.inc_longest_life(M.ckey)

	//uses shift time
	//only called from inc_death and the loop through the player_stats list of pw_player_stats datum
	proc/inc_longest_life(var/ckey)
		// if (!ismob(M))
		// 	return
		var/datum/pw_player_stats/stat = player_stats[ckey]
		if (istype(stat))
			var/shift_time = round(ticker.round_elapsed_ticks / (1 MINUTES), 0.01)		//this converts shift time to "minutes". uses this cause it starts counting when the round starts, not when the lobby starts.


			//I feel like I should explain this, but I'm not gonna cause it's not confusing enough to need it. Just the long names make it look weird.
			if (!stat.longest_life)
				stat.time_of_last_death = shift_time
				stat.longest_life = shift_time
			else
				if (stat.time_of_last_death < shift_time - stat.time_of_last_death)
					stat.time_of_last_death = shift_time
					stat.longest_life = shift_time - stat.time_of_last_death

	proc/inc_farts(var/mob/M)
		if (!ismob(M) || !M.ckey)
			return
		var/datum/pw_player_stats/stat = player_stats[M.ckey]
		if (istype(stat))
			stat.farts ++

	//has a variable increment amount cause not every tic of ethanol metabolize metabolizes the same amount of alcohol.
	proc/inc_alcohol_metabolized(var/mob/M, var/inc_amt = 1)
		if (!ismob(M) || !M.ckey)
			return
		var/datum/pw_player_stats/stat = player_stats[M.ckey]
		if (istype(stat))
			stat.alcohol_metabolized += inc_amt

	//called on round end to output the stats. returns the HTML as a string.
	proc/build_HTML()

		//calculate pet survival first.
		var/pet_dat = "<h4>Pet Stats:</h4>"
		for(var/pet in by_cat[TR_CAT_PW_PETS])
			if(istype(pet, /mob/living/critter/small_animal/turtle/sylvester/Commander))
				var/mob/living/critter/small_animal/turtle/sylvester/P = pet
				if(isalive(P))
					if (istype(get_area(P), /area/pod_wars/team1))
						pet_dat += "[SPAN_NOTICE("Sylvester is safe and sound on the Pytheas! Good job NanoTrasen!")]<br>"
					else if (istype(get_area(P), /area/pod_wars/team2))
						pet_dat += "[SPAN_ALERT("Sylvester was captured by the Syndicate! Oh no!")]<br>"
					else
						pet_dat += "[SPAN_NOTICE("Sylvester survived! Yay!")]<br>"

				else
					pet_dat += "[SPAN_ALERT("Sylvester was killed! Oh no!")]<br>"

			else if(istype(pet, /mob/living/carbon/human/npc/monkey/oppenheimer/pod_wars))
				var/mob/living/carbon/human/opp = pet
				if (isalive(opp))
					if (istype(get_area(opp), /area/pod_wars/team2))
						pet_dat += "[SPAN_NOTICE("Oppenheimer is safe and sound on the Lodbrok! Good job Syndicates!")]<br>"
					else if (istype(get_area(opp), /area/pod_wars/team1))
						pet_dat += "[SPAN_ALERT("Oppenheimer was captured by NanoTrasen! Oh no!")]<br>"
					else
						pet_dat += "[SPAN_NOTICE("Oppenheimer survived! Yay!")]<br>"

				else
					pet_dat += "[SPAN_ALERT("Oppenheimer was killed! Oh no!")]<br>"

		//write the player stats as a simple table
		var/p_stat_text = ""
		for (var/ckey in player_stats)
			var/datum/pw_player_stats/stat = player_stats[ckey]
			//first update longest life
			inc_longest_life(stat.ckey)
			// p_stat_text += stat.build_text()
			p_stat_text += {"
<tr>
 <td>[stat.team_num == 1? "NT" : stat.team_num == 2 ? "SY" : ""]</td>
 <td>[stat.initial_name] ([stat.ckey])</td>
 <td>[stat.death_count]</td>
 <td>[stat.friendly_fire_count]</td>
 <td>[stat.longest_life] (min)</td>
 <td>[round(stat.alcohol_metabolized, 0.01)](u)</td>
 <td>[stat.farts]</td>
 <td>[stat.control_point_capture_count]</th>  d
</tr>"}

		return {"
<h2>
Game Stats
</h2>
[pet_dat]
<h3>
Player Stats
</h3>
<table id=\"myTable\" cellspacing=\"0\"; cellpadding=\"5\">
  <tr>
    <th>Team</th>
    <th>Name</th>
    <th>Deaths</th>
    <th>Friendly Fire</th>
    <th>Longest Life</th>
    <th>Alcohol Metabolized</th>
    <th>Farts</th>
    <th>Ctrl Pts</th>
  </tr>
[p_stat_text]</table>
<hr>
<h2>Reward Stats</h2>
<h3>Crates</h3>
[build_rewards_text(src.crate_list)]
<h3>Items</h3>
[build_rewards_text(src.item_rewards)]

<style>
* {
  box-sizing: border-box;
}

.column {
  border: 1px solid #66A;
  float: left;
  width: 50%;
  padding: 10px;
}

 body {background-color: #448;}
 h2, h3, h4, span {color:white}
 td, th
 {
  border: 1px solid #66A;
  text-align: center;
  color:white;
 }

</style>"}

	//Assumes Lists are an assoc list in the format where the key starts with either "NT," or "SY," followed by the item/crate_tier name
	//and the value stored is just an int for the amount.
	//returns html text
	proc/build_rewards_text(var/list/L)
		if (!islist(L) || !length(L))
			logTheThing(LOG_DEBUG, null, "Something trying to write one of the lists for stats...")
			return

		var/cr_stats_NT = ""
		var/cr_stats_SY = ""
		for (var/stat in L)
			// message_admins("[stat]:[copytext(1,3)];[copytext(stat, 4)]")
			if (!istext(stat) || length(stat) <= 4) continue

			if (copytext(stat, 1,3) == "NT")
				cr_stats_NT += "<tr><b>[copytext(stat, 4)]</b> = [L[stat]]</tr><br>"
			else if (copytext(stat, 1,3) == "SY")
				cr_stats_SY += "<tr><b>[copytext(stat, 4)]</b> = [L[stat]]</tr><br>"

		return {"

<div class='column'>
  <h3>NanoTrasen</h3>
  [cr_stats_NT]
</div>
<div class='column'>
  <h3>Syndicate</h3>
  [cr_stats_SY]
</div>
"}

	proc/display_HTML_to_clients()
		html_string = build_HTML()
		for (var/client/C in clients)
			C.Browse(html_string, "window=scores;size=700x500;title=Scores" )
			boutput(C, "<strong style='color: #393;'>Use the command Display-Stats to view the stats screen if you missed it.</strong>")
			C.mob.verbs += /client/proc/display_stats

/client/proc/display_stats()
	set name = "Display Stats"
	var/datum/game_mode/pod_wars/mode = ticker.mode
	if (istype(mode))
		var/raw = alert(src,"Do you want to view the stats as raw html?", "Display Stats", "No", "Yes")
		if (raw == "Yes")
			src.Browse("<XMP>[mode.stats_manager?.html_string]</XMP>", "window=scores;size=700x500;title=Scores" )
		else
			src.Browse(mode.stats_manager?.html_string, "window=scores;size=700x500;title=Scores" )

//for displaying info about players on round end to everyone.
/datum/pw_player_stats
	var/datum/mind/mind
	var/initial_name
	var/ckey 			//this and initial_name are mostly for safety
	var/team_num 		//valid values, 1 = NT, 2 = SY
	var/rank			//current valid values include "Commander", "Pilot"
	var/time_of_last_death = 0

	//silly stats
	var/death_count = 0
	var/friendly_fire_count = 0
	var/control_point_capture_count = 0			//should be determined by being in the control point area when captured
	var/longest_life = 0						//this value is in "minutes" byond time.
	var/alcohol_metabolized = 0
	var/farts = 0

	New(var/datum/mind/mind, var/initial_name, var/team_num, var/rank)
		..()
		src.mind = mind
		src.initial_name = initial_name
		src.team_num = team_num
		src.rank = rank

		src.ckey = mind?.ckey

