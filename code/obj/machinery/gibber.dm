/obj/machinery/gibber
	name = "Gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = 1
	anchored = 1
	var/operating = 0 //Is it on?
	var/dirty = 0 // Does it need cleaning?
	var/gibtime = 40 // Time from starting until meat appears
	var/mob/occupant // Mob who has been put inside
	var/output_direction = "W" // Spray gibs and meat in that direction.
	mats = 15
	deconstruct_flags =  DECON_WRENCH | DECON_WELDER

	output_north
		output_direction = "N"
	output_east
		output_direction = "E"
	output_west
		output_direction = "W"
	output_south
		output_direction = "S"

/obj/machinery/gibber/New()
	..()
	src.overlays += image('icons/obj/kitchen.dmi', "grindnotinuse")
	UnsubscribeProcess()

/obj/machinery/gibber/custom_suicide = 1
/obj/machinery/gibber/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	if (user.client)
		user.visible_message("<span class='alert'><b>[user] climbs into the gibber and switches it on.</b></span>")
		user.set_loc(src)
		src.occupant = user
		src.startgibbing(user)
		return 1

/obj/machinery/gibber/relaymove(mob/user as mob)
	src.go_out()
	return

/obj/machinery/gibber/attack_hand(mob/user as mob)
	if(operating)
		boutput(user, "<span class='alert'>It's locked and running</span>")
		return
	else
		src.startgibbing(user)

/obj/machinery/gibber/attackby(obj/item/grab/G as obj, mob/user as mob)
	if(src.occupant)
		boutput(user, "<span class='alert'>The gibber is full, empty it first!</span>")
		return
	if (!( istype(G, /obj/item/grab)) || !(ishuman(G.affecting)))
		boutput(user, "<span class='alert'>This item is not suitable for the gibber!</span>")
		return

	user.visible_message("<span class='alert'>[user] starts to put [G.affecting] into the gibber!</span>")
	src.add_fingerprint(user)
	sleep(3 SECONDS)
	if(G?.affecting)
		user.visible_message("<span class='alert'>[user] stuffs [G.affecting] into the gibber!</span>")
		logTheThing("combat", user, G.affecting, "forced [constructTarget(G.affecting,"combat")] into a gibber at [log_loc(src)].")
		message_admins("[key_name(user)] forced [key_name(G.affecting, 1)] ([isdead(G.affecting) ? "dead" : "alive"]) into a gibber at [log_loc(src)].")
		var/mob/M = G.affecting
		M.set_loc(src)
		src.occupant = M
		qdel(G)

/obj/machinery/gibber/verb/eject()
	set src in oview(1)
	set category = "Local"

	if (!isalive(usr)) return
	if (src.operating) return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/gibber/proc/go_out()
	if (!src.occupant)
		return
	for(var/obj/O in src)
		O.set_loc(src.loc)
	src.occupant.set_loc(src.loc)
	src.occupant = null
	return


/obj/machinery/gibber/proc/startgibbing(mob/user as mob)
	if(src.operating)
		return
	if(!src.occupant)
		for(var/mob/M in hearers(src, null))
			M.show_message("<span class='alert'>You hear a loud metallic grinding sound.</span>", 1)
		return
	else
		var/bdna = null // For forensics (Convair880).
		var/btype = null

		for(var/mob/M in hearers(src, null))
			M.show_message("<span class='alert'>You hear a loud squelchy grinding sound.</span>", 1)
		src.operating = 1
		flick("grinder-on", src)

		var/sourcename = src.occupant.real_name
		var/sourcejob
		if (src.occupant.mind && src.occupant.mind.assigned_role)
			sourcejob = src.occupant.mind.assigned_role
		else if (src.occupant.ghost && src.occupant.ghost.mind && src.occupant.ghost.mind.assigned_role)
			sourcejob = src.occupant.ghost.mind.assigned_role
		else
			sourcejob = "Stowaway"

		var/decomp = 0
		if(ishuman(src.occupant))
			decomp = src.occupant:decomp_stage

			bdna = src.occupant.bioHolder.Uid // Ditto (Convair880).
			btype = src.occupant.bioHolder.bloodType

		if(user != src.occupant) //for suiciding with gibber
			logTheThing("combat", user, src.occupant, "grinds [constructTarget(src.occupant,"combat")] in a gibber at [log_loc(src)].")
			message_admins("[key_name(src.occupant, 1)] is ground up in a gibber by [key_name(user)] at [log_loc(src)].")
		src.occupant.death(1)

		if (src.occupant.mind)
			src.occupant.ghostize()
			qdel(src.occupant)
		else
			qdel(src.occupant)
		src.occupant = null

		var/turf/T1
		var/turf/T2
		var/turf/T3

		switch (src.output_direction)
			if ("N")
				T1 = locate(src.x, src.y + 1, src.z)
				T2 = locate(src.x, src.y + 2, src.z)
				T3 = locate(src.x, src.y + 3, src.z)
			if ("E")
				T1 = locate(src.x + 1, src.y, src.z)
				T2 = locate(src.x + 2, src.y, src.z)
				T3 = locate(src.x + 3, src.y, src.z)
			if ("S")
				T1 = locate(src.x, src.y - 1, src.z)
				T2 = locate(src.x, src.y - 2, src.z)
				T3 = locate(src.x, src.y - 3, src.z)
			if ("W")
				T1 = locate(src.x - 1, src.y, src.z)
				T2 = locate(src.x - 2, src.y, src.z)
				T3 = locate(src.x - 3, src.y, src.z)

		var/blocked = 0
		if (T1)
			if (T1.density)
				T1 = null
				blocked = 1
			else
				for (var/obj/O in T1.contents)
					if (!ismob(O) && O.density && !(O.flags & ON_BORDER))
						T1 = null
						blocked = 1
						break
		if (T2)
			if (T2.density || blocked != 0)
				T2 = null
				blocked = 1
			else
				for (var/obj/O2 in T2.contents)
					if (!ismob(O2) && O2.density && !(O2.flags & ON_BORDER))
						T2 = null
						blocked = 1
						break
		if (T3)
			if (T3.density || blocked != 0)
				T3 = null
			else
				for (var/obj/O3 in T3.contents)
					if (!ismob(O3) && O3.density && !(O3.flags & ON_BORDER))
						T3 = null
						break

		src.dirty += 1
		if(decomp)
			SPAWN_DBG(src.gibtime)
				playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
				operating = 0
				var/obj/decal/cleanable/blood/B1 = null // For forensics (Convair880).
				var/obj/decal/cleanable/blood/gibs/G1 = null
				if (decomp > 2)
					if (T1 && isturf(T1))
						make_cleanable( /obj/decal/cleanable/molten_item,T1)
						B1 = make_cleanable( /obj/decal/cleanable/blood,T1)
						if (bdna && btype)
							B1.blood_DNA = bdna
							B1.blood_type = btype
				else
					if (T1 && isturf(T1))
						G1 = make_cleanable( /obj/decal/cleanable/blood/gibs,T1)
						if (bdna && btype)
							G1.blood_DNA = bdna
							G1.blood_type = btype
					if (T2 && isturf(T2))
						B1 = make_cleanable( /obj/decal/cleanable/blood,T2)
						if (bdna && btype)
							B1.blood_DNA = bdna
							B1.blood_type = btype
			return
		var/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/newmeat1 = new /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/
		var/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/newmeat2 = new /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/
		var/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/newmeat3 = new /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/
		newmeat1.name = sourcename + newmeat1.name
		newmeat1.subjectname = sourcename
		newmeat1.subjectjob = sourcejob
		newmeat2.name = sourcename + newmeat2.name
		newmeat2.subjectname = sourcename
		newmeat2.subjectjob = sourcejob
		newmeat3.name = sourcename + newmeat3.name
		newmeat3.subjectname = sourcename
		newmeat3.subjectjob = sourcejob
		SPAWN_DBG(src.gibtime)
			playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			operating = 0
			var/obj/decal/cleanable/blood/gibs/G2 = null // For forensics (Convair880).

			if (T1 && isturf(T1))
				G2 = make_cleanable( /obj/decal/cleanable/blood/gibs,T1)
				if (bdna && btype)
					G2.blood_DNA = bdna
					G2.blood_type = btype
				newmeat1.set_loc(T1)
			if (T2 && isturf(T2))
				G2 = make_cleanable( /obj/decal/cleanable/blood/gibs,T2)
				if (bdna && btype)
					G2.blood_DNA = bdna
					G2.blood_type = btype
				newmeat2.set_loc(T2)
			else
				newmeat2.set_loc(T1)
			if (T3 && isturf(T3))
				G2 = make_cleanable( /obj/decal/cleanable/blood/gibs,T3)
				if (bdna && btype)
					G2.blood_DNA = bdna
					G2.blood_type = btype
				newmeat3.set_loc(T3)
			else
				newmeat3.set_loc(T1)
			if (src.dirty == 1)
				src.overlays += image('icons/obj/kitchen.dmi', "grindbloody")

		src.operating = 0
