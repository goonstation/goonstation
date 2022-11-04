
/////////////////////////////////////////////
//////// Attach a steam trail to an object (eg. a reacting beaker) that will follow it
// even if it's carried of thrown.
/////////////////////////////////////////////

/datum/effects/system/steam_trail_follow
	var/atom/holder
	var/turf/oldposition
	var/processing = 1
	var/on = 1
	var/number

/datum/effects/system/steam_trail_follow/proc/set_up(atom/atom)
	holder = atom
	oldposition = get_turf(atom)

/datum/effects/system/steam_trail_follow/proc/start()
	if(!src.on)
		src.on = 1
		src.processing = 1
	if(src.processing)
		src.processing = 0
		SPAWN(0)
			if(src.number < 3)
				var/obj/effects/steam/I = new /obj/effects/steam
				I.set_loc(src.oldposition)
				src.number++
				src.oldposition = get_turf(holder)
				I.set_dir(src.holder.dir)
				SPAWN(1 SECOND)
					if (I && !I.disposed) qdel(I)
					src.number--
				SPAWN(0.2 SECONDS)
					if(src.on)
						src.processing = 1
						src.start()
			else
				SPAWN(0.2 SECONDS)
					if(src.on)
						src.processing = 1
						src.start()

/datum/effects/system/steam_trail_follow/proc/stop()
	src.processing = 0
	src.on = 0
