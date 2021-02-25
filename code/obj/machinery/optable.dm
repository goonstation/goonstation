/obj/machinery/optable
	name = "Operating Table"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table2-idle"
	desc = "A table that allows qualified professionals to perform delicate surgeries."
	density = 1
	anchored = 1.0
	mats = 25
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS
	var/mob/living/carbon/human/victim = null
	var/strapped = 0.0

	var/obj/machinery/computer/operating/computer = null
	var/id = 0.0

/obj/machinery/optable/New()
	..()
	SPAWN_DBG(0.5 SECONDS)
		src.computer = locate(/obj/machinery/computer/operating, orange(2,src))

/obj/machinery/optable/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				src.set_density(0)
		else
	return

/obj/machinery/optable/blob_act(var/power)
	if(prob(power * 2.5))
		qdel(src)

/obj/machinery/optable/attack_hand(mob/user as mob)
	if (usr.is_hulk())
		user.visible_message("<span class='alert'>[user] destroys the table.</span>")
		src.set_density(0)
		qdel(src)
	return

/obj/machinery/optable/CanPass(atom/movable/O as mob|obj, target as turf, height=0, air_group=0)
	if (air_group || (height==0))
		return 1
	if (!O)
		return 0
	if ((O.flags & TABLEPASS || istype(O, /obj/newmeteor)))
		return 1
	else
		return 0

/obj/machinery/optable/proc/check_victim()
	if(locate(/mob/living/carbon/human, src.loc))
		var/mob/M = locate(/mob/living/carbon/human, src.loc)
		if(M.hasStatus("resting"))
			src.victim = M
			icon_state = "table2-active"
			return 1
	src.victim = null
	icon_state = "table2-idle"
	return 0

/obj/machinery/optable/process()
	check_victim()

/obj/machinery/optable/attackby(obj/item/W as obj, mob/user as mob)
	if (issilicon(user)) return
	if (istype(W, /obj/item/electronics/scanner)) return // hack
	if (istype(W, /obj/item/grab))
		if(ismob(W:affecting))
			var/mob/M = W:affecting
			M.setStatus("resting", INFINITE_STATUS)
			M.force_laydown_standup()
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				H.hud.update_resting()
			M.set_loc(src.loc)
			src.visible_message("<span class='alert'>[M] has been laid on the operating table by [user].</span>")
			for(var/obj/O in src)
				O.set_loc(src.loc)
			src.add_fingerprint(user)
			icon_state = "table2-active"
			src.victim = M
			qdel(W)
			return
	user.drop_item()
	if(W?.loc)
		W.set_loc(src.loc)
	return

/obj/machinery/optable/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if (!isliving(user))
		boutput(user, "<span class='alert'>You're dead! What the hell could surgery possibly do for you NOW, dumbass?!</span>")
		return
	if (!ismob(O))
		boutput(user, "<span class='alert'>You can't put that on the operating table!</span>")
		return
	if (ismobcritter(O))
		boutput(user, "<span class='alert'>You don't know how to operate on this. You never went to vet school!</span>")
		return
	if (!ishuman(O))
		boutput(user, "<span class='alert'>You can only put carbon lifeforms on the operating table.</span>")
		return
	if (get_dist(user,src) > 1)
		boutput(user, "<span class='alert'>You need to be closer to the operating table.</span>")
		return
	if (get_dist(user,O) > 1)
		boutput(user, "<span class='alert'>Your target needs to be near you to put them on the operating table.</span>")
		return

	var/mob/living/carbon/C = O
	if (user == C)
		src.visible_message("<span class='alert'><b>[user.name]</b> lies down on [src].</span>")
		user.setStatus("resting", INFINITE_STATUS)
		user.force_laydown_standup()
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			H.hud.update_resting()
		user.set_loc(src.loc)
		src.victim = user
	else
		src.visible_message("<span class='alert'><b>[user.name]</b> starts to move [C.name] onto the operating table.</span>")
		if (do_mob(user,C,30))
			C.setStatus("resting", INFINITE_STATUS)
			C.force_laydown_standup()
			if (ishuman(C))
				var/mob/living/carbon/human/H = C
				H.hud.update_resting()
			C.set_loc(src.loc)
			src.victim = C
		else
			boutput(user, "<span class='alert'>You were interrupted!</span>")
	return
