datum/controller/process/kudzu
	var/list/kudzu = list()

	var/tmp/list/detailed_count
	var/count = 0

	setup()
		name = "Kudzu"
		schedule_interval = 3 SECONDS

		detailed_count = new

	doWork()
		for (var/obj/spacevine/K in kudzu)
			if (K.run_life)
				K.Life()
				scheck()

	tickDetail()
		if (length(detailed_count))
			var/stats = "<b>Kudzu Stats:</b><br>"
			var/count
			for (var/thing in detailed_count)
				count = detailed_count[thing]
				stats += "[thing] processed [count] times. Total kudzu: [kudzu.len]<br>"
			boutput(usr, "<br>[stats]")


/mob/living/carbon/human/proc/infect_kudzu()
	var/obj/icecube/kudzu/cube = new /obj/icecube/kudzu(get_turf(src), src)
	src.set_loc(cube)
	cube.visible_message("<span class='alert'><B>[src] is covered by the vines!</span>")
