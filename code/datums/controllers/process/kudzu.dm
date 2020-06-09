datum/controller/process/kudzu
	var/list/kudzu = list()

	var/tmp/list/detailed_count
	var/count = 0

	setup()
		name = "Kudzu"
		schedule_interval = 5 SECONDS

		detailed_count = new

	doWork()
		if (count == 7)
			count = 0
			//make kudzu men converting cocoons for all dead humans
			for (var/mob/M in mobs)
				//dnr I dunno !((M && M.mind) || !(M && M.mind && M.mind.dnr))
				if (M.stat == 2 && isturf(M.loc) && M.loc.temp_flags & HAS_KUDZU && ishuman(M))
					var/mob/living/carbon/human/H = M
					if (istype(H.mutantrace, /datum/mutantrace/kudzu))
						continue
					//make cocoon
					var/obj/icecube/kudzu/cube = new /obj/icecube/kudzu(get_turf(M), M)
					M.set_loc(cube)
					cube.visible_message("<span style=\"color:red\"><B>[M] is covered by the vines!</span>")
			// return

		for (var/obj/spacevine/K in kudzu)
			if (K.run_life)
				K.Life()
				scheck()
		count++

	tickDetail()
		if (detailed_count && detailed_count.len)
			var/stats = "<b>Kudzu Stats:</b><br>"
			var/count
			for (var/thing in detailed_count)
				count = detailed_count[thing]
				stats += "[thing] processed [count] times. Total kudzu: [kudzu.len]<br>"
			boutput(usr, "<br>[stats]")
