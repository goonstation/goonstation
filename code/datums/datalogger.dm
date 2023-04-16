var/global/datum/datalogger/game_stats
//
/datum/datalogger
	var/list/stats = list()
	New()
		..()
		stats["date"] = time2text(world.realtime, "MM/DD/YY hh:mm:ss")
		stats["adminhelps"] = 0
		stats["mentorhelps"] = 0
		stats["prayers"] = 0
		stats["deaths"] = 0
		stats["playerdeaths"] = 0
		stats["firstdeath"] = null	// players only
		stats["lastdeath"] = null		// players only
		stats["alldeaths"] = list()		// all player deaths
		stats["monkeydeaths"] = 0
		stats["clones"] = 0
		stats["sleeper"] = 0
		stats["traitorloss"] = 0
		stats["traitorwin"] = 0
		stats["farts"] = 0
		stats["violence"] = 0
		stats["catches"] = 0
//		stats["animes"] = 0
		stats["fornoreason"] = 0
//		stats["literally"] = 0
//		stats["gayirl"] = 0
		stats["verily"] = 0
		stats["grief"] = 0
		stats["grife"] = 0
		stats["grif"] = 0
		stats["griff"] = 0
		stats["greif"] = 0
		stats["grief_other"] = 0
		stats["rouge"] = 0
		stats["players"] = 0
		stats["admins"] = 0
		stats["gunfire"] = 0
		stats["grass_touched"] = 0
		stats["slips"] = 0
		stats["hydro_harvests"] = 0
		stats["hydro_produce"] = 0
	proc
		Increment(var/p)
			if(!(p in stats))
				return null
			stats[p]++
			//DEBUG_MESSAGE("[p] = [stats[p]]")
			return 1
		IncrementBy(var/p, var/amt)
			if(!(p in stats))
				return null
			stats[p] += amt
			return 1
		Decrement(var/p)
			if(!(p in stats))
				return null
			stats[p]--
			return 1
		DecrementBy(var/p, var/amt)
			if(!(p in stats))
				return null
			stats[p] -= amt
			return 1
		SetValue(var/p, var/val)
			if(!(p in stats))
				return null
			stats[p] = val
			return 1
		ScanText(var/msg)
			var/list/text_tokens = splittext(msg, " ")
			var/fornoreason = 0
//			var/gayirl = 0
			var/verily = 0
			for(var/token in text_tokens)
				token = lowertext(token)
				token = replacetext(token, "!", "")
				token = replacetext(token, "?", "")
				// this should cover all misspellings of "grief"
				if(dd_hasprefix(token, "gr"))
					if(dd_hassuffix(token, "ed"))
						token = copytext(token, 1, length(token) - 1)
					if(dd_hassuffix(token, "ing"))
						token = copytext(token, 1, length(token) - 2)
					if(dd_hassuffix(token, "in"))
						token = copytext(token, 1, length(token) - 1)
					if(dd_hassuffix(token, "d"))
						token = copytext(token, 1, length(token))
					if(dd_hassuffix(token, "f") || dd_hassuffix(token, "fe"))
						if(!game_stats.Increment(token))
							game_stats.Increment("grief_other")
//				else if(token in list("o.o", "o_o", "^_^", "^^", "<.<", ">.>", "<<", ">>", "-.-", "-_-"))
//					game_stats.Increment("animes")
				else if(token == "literally")
					game_stats.Increment("literally")
				else if(token == "for" && fornoreason == 0)
					fornoreason = 1
				else if(token == "no" && fornoreason == 1)
					fornoreason = 2
				else if(token == "reason" && fornoreason == 2)
					fornoreason = 3
					game_stats.Increment("fornoreason")
				else if(token == "rouge")
					game_stats.Increment("rouge")
//				else if(token == "gay" && gayirl == 0)
//					gayirl = 1
//				else if(token == "irl" && gayirl == 1)
//					gayirl = 2
//					game_stats.Increment("gayirl")
				else if(token == "verily" && !verily)
					verily = 1
					game_stats.Increment("verily")
		GetStat(var/index)
			if(!(index in stats))
				return null
			return stats[index]

		AddDeath(var/mobName, var/mobCkey, var/where, var/health)
			// Stores player deaths.

			var/turf/whereT = get_turf(where)
			var/list/death = list(
				"name" = mobName,
				"ckey" = mobCkey,
				"health" = health,
				"where" = whereT,
				"whereText" = "[whereT.loc] ([whereT.x], [whereT.y], [whereT.z])",
				)

			if (!stats["firstdeath"])
				stats["firstdeath"] = death
			stats["lastdeath"] = death
			stats["alldeaths"] += list(death)
			stats["playerdeaths"]++

			return 1


//	Disabled for the sake of what I wanted to do with this, left write to file code commented.
//		WriteToFile(var/filetxt)
//			var/stats_file = null
//			if(!fexists(filetxt))
//				stats_file = file(filetxt)
//				var/header = ""
//				for(var/p in stats)
//					header += "[p]&emsp;"
//				boutput(stats_file, header)
//			else
//				stats_file = file(filetxt)
//			var/data_str = ""
//			for(var/p in stats)
//				data_str += "[stats[p]]&emsp;"
//			stats_file << data_str
