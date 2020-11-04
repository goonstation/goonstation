//Handles blobs without being pissy about it
datum/controller/process/blob
	var/list/blobs = list()

	var/tmp/list/detailed_count

	setup()
		name = "Blob"
		schedule_interval = 31 // 3.1 SECOND

		detailed_count = new

	doWork()

		for (var/obj/blob/B in blobs)
			if (B.runOnLife || B.poison)
				B.Life()
				scheck()

		/*var/currentTick = ticks

		for(var/obj/blob/B in blobs)
			if (prob (B.life_prob))
				B.Life()

			detailed_count["[B.type]"]++

			scheck(currentTick)*/

	tickDetail()
		if (length(detailed_count))
			var/stats = "<b>Blob Stats:</b><br>"
			var/count
			for (var/thing in detailed_count)
				count = detailed_count[thing]
				stats += "[thing] processed [count] times. Total blobs: [blobs.len]<br>"
			boutput(usr, "<br>[stats]")
