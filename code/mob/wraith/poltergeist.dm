/mob/wraith/poltergeist
	name = "Poltergeist"
	real_name = "Poltergeist"
	desc = "Jesus Christ, how spooky."
	icon = 'icons/mob/mob.dmi'
	icon_state = "poltergeist"
	deaths = 1					//only 1 life
	var/mob/wraith/master = null
	var/obj/spookMarker/marker = null
	haunt_duration = 150
	death_icon_state = "derangedghost"
	var/max_dist_marker = 15
	var/max_dist_master = 12
	var/following_master = 0

	//this might be real shit, but there's not really a lot of poltergeists in a round so w/e
	var/dist_from_master = 0
	var/dist_from_marker = 0
	var/power_well_dist = 0		//the lesser of the two distances from master/marker

	make_name()
		var/len = rand(4, 6)
		var/vowel_prob = 0
		var/list/con = list("h","n", "k", "s", "l", "t", "r", "sh", "m", "d")
		var/list/vow = list("o", "a", "i", "u", "ou")
		var/theName = ""
		for (var/i = 1, i <= len, i++)
			if (prob(vowel_prob))
				vowel_prob = 0
				theName += pick(vow)
			else
				vowel_prob += rand(15, 40)
				theName += pick(con)
		var/fc = copytext(theName, 1, 2)
		theName = "[uppertext(fc)][copytext(theName, 2)]"
		if (prob(2))
			theName = pick("Peeves", "Peevs", "Peves", "Casper")
		theName = theName  + "[pick(" the Poltergeist", " the Mischievous", " the Playful", " the Trickster", " the Sneaky", " the Child", " the Kid", " the Ass", " the Inquisitive", " the Exiled")]"
		return theName

	New(var/turf/T, var/mob/wraith/master, var/obj/spookMarker/marker)
		..(T)
		src.master = master
		src.marker = marker

		//poltergeists can't make child poltergeists so lets just null this
		src.poltergeists = null

		//just in cases
		if (isnull(master.poltergeists))
			master.poltergeists = list()

		master.poltergeists += src

	Life()
		..()
		if (!marker && !master)
			death()
			boutput(src, "Your portal and master have been destroyed, you return to the nether.")

		if (dist_from_master > max_dist_marker && dist_from_marker > max_dist_master && health > 10)
			// if (marker)
			// 	src.set_loc(get_turf(marker))
			// 	boutput(src, "<span class='alert'>You are too far from your portal and master! You warp back to the portal!</span>")
			// else if (master)
			// 	src.set_loc(get_turf(marker))
			// 	boutput(src, "<span class='alert'>You are too far from your master and your portal is destroyed! You warp back to your master!</span>")
			boutput(src, "<span class='alert'>You are damaged from being too far from a well of power!</span>")
			TakeDamage("all", 5, 0)
		//else
			//You're close to a well of power, gain extra spell points

	death()
		if (master)
			boutput(master, "<span class='alert'>Your poltergeist, [src], has been destroyed!</span>")
		qdel(marker)
		..()

	disposing()
		qdel(marker)
		master?.poltergeists -= src
		master = null
		..()

	addAllAbilities()
		src.addAbility(/datum/targetable/wraithAbility/decay)
		src.addAbility(/datum/targetable/wraithAbility/command)
		src.addAbility(/datum/targetable/wraithAbility/animateObject)
		src.addAbility(/datum/targetable/wraithAbility/haunt)
		src.addAbility(/datum/targetable/wraithAbility/spook)
		src.addAbility(/datum/targetable/wraithAbility/whisper)
		src.addAbility(/datum/targetable/wraithAbility/blood_writing)

		src.addAbility(/datum/targetable/wraithAbility/teleport)
		src.addAbility(/datum/targetable/wraithAbility/follow_master)

	removeAllAbilities()
		src.removeAbility(/datum/targetable/wraithAbility/decay)
		src.removeAbility(/datum/targetable/wraithAbility/command)
		src.removeAbility(/datum/targetable/wraithAbility/animateObject)
		src.removeAbility(/datum/targetable/wraithAbility/haunt)
		src.removeAbility(/datum/targetable/wraithAbility/spook)
		src.removeAbility(/datum/targetable/wraithAbility/whisper)
		src.removeAbility(/datum/targetable/wraithAbility/blood_writing)

		src.removeAbility(/datum/targetable/wraithAbility/teleport)
		src.removeAbility(/datum/targetable/wraithAbility/follow_master)

	makeCorporeal()
		if (!src.density)
			src.set_density(1)
			src.invisibility = 0
			src.icon_state = "poltergeist-corp"
			src.see_invisible = 0
			src.visible_message(pick("<span class='alert'>A horrible apparition fades into view!</span>", "<span class='alert'>A pool of shadow forms!</span>"), pick("<span class='alert'>A shell of ectoplasm forms around you!</span>", "<span class='alert'>You manifest!</span>"))
		update_body()

	makeIncorporeal()
		if (src.density)
			src.visible_message(pick("<span class='alert'>[src] vanishes!</span>", "<span class='alert'>The poltergeist dissolves into shadow!</span>"), pick("<span class='notice'>The ectoplasm around you dissipates!</span>", "<span class='notice'>You fade into the aether!</span>"))
			src.set_density(0)
			src.invisibility = 10
			src.icon_state = "poltergeist"
			src.see_invisible = 16
		update_body()

	Move(var/turf/NewLoc, direct)
		..()
		update_well_dist(TRUE, TRUE)

	//values, TRUE, FALSE. which, if any of these two do we want to update the distances of
	proc/update_well_dist(var/update_master, var/update_marker)
		if (update_master)
			dist_from_master = master ? get_dist(src, master) : 0
		if (update_marker)
			dist_from_marker = marker ? get_dist(src, marker) : 0

		//lesser of dist from master and marker
		power_well_dist = min(dist_from_master, dist_from_marker)
		//Maybe display, but that could be too fast...


/////////////////abilities////////////////////////

//Only for poltergeist
/datum/targetable/wraithAbility/teleport
	name = "Teleport"
	icon_state = "teleport"
	desc = "Send an ethereal message to a living being."
	targeted = 1
	target_anything = 1
	pointCost = 100
	cooldown = 1 MINUTES
	power_well_dist = INFINITY

	cast(atom/target)
		if (..())
			return 1

		if (ispoltergeist(holder.owner))
			var/mob/wraith/poltergeist/P = holder.owner

			var/I = input(holder.owner, "Where to teleport", "Where to teleport", "Master") as anything in list("Master", "Anchor")
			switch (I)
				if ("Master")
					P.set_loc(P.master)
				if ("Anchor")
					P.set_loc(P.marker)

		else
			boutput(holder.owner, "Kiiiiinda need to be a poltergeist to use this ability. Something is fucked if you see this...")
//Only for poltergeist
/datum/targetable/wraithAbility/follow_master
	name = "Follow Master"
	icon_state = "follow_master"
	desc = "Send an ethereal message to a living being."
	targeted = 1
	target_anything = 1
	pointCost = 1
	cooldown = 2 SECONDS
	power_well_dist = 12

	cast(atom/target)
		if (..())
			return 1


		if (ispoltergeist(holder.owner))
			var/mob/wraith/poltergeist/P = holder.owner

			if (P.dist_from_master > P.max_dist_master)
				boutput(P, "<span class='alert'>You are too far from your master to follow them!</span>")
				return

			P.following_master = !P.following_master
			boutput(P, "You are now [P.following_master ? "following" : "not following"] your master.")

		else
			boutput(holder.owner, "Kiiiiinda need to be a poltergeist to use this ability. Something is fucked if you see this...")
