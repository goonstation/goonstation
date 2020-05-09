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

	Life()
		..()
		if (!marker && !master)
			death()
			boutput(src, "Your portal and master have been destroyed, you return to the nether.")

		if ((marker && get_dist(src, marker) > 15) && (master && get_dist(src,master) > 12 ))
			if (marker)
				src.set_loc(get_turf(marker))
				boutput(src, "<span class='alert'>You are too far from your portal and master! You warp back to the portal!</span>")
			else if (master)
				src.set_loc(get_turf(marker))
				boutput(src, "<span class='alert'>You are too far from your master and your portal is destroyed! You warp back to your master!</span>")
			boutput(src, "<span class='alert'>You are damaged from snapping back to your current location!</span>")
			TakeDamage("all", 10, 10)
	death()
		if (master)
			boutput(master, "<span class='alert'>Your poltergeist, [src], has been destroyed!</span>")
		qdel(marker)
		..()

	disposing()
		qdel(marker)
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

	removeAllAbilities()
		src.removeAbility(/datum/targetable/wraithAbility/decay)
		src.removeAbility(/datum/targetable/wraithAbility/command)
		src.removeAbility(/datum/targetable/wraithAbility/animateObject)
		src.removeAbility(/datum/targetable/wraithAbility/haunt)
		src.removeAbility(/datum/targetable/wraithAbility/spook)
		src.removeAbility(/datum/targetable/wraithAbility/whisper)
		src.removeAbility(/datum/targetable/wraithAbility/blood_writing)

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
