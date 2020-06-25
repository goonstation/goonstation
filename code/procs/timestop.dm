#if ASS_JAM
/obj/effect/timefield
	name = "timefield"
	desc = "/shrug"
	density = 0
	anchored = 1
	opacity = 0
	alpha = 255
	var/list/immune = list()
	var/duration
	var/size
	var/freezeloop = FALSE
	layer = LATTICE_LAYER
	var/list/frozen_things = list()
	var/list/frozen_turfs = list()
	var/list/old_colors = list()
	var/list/old_anchored = list()
	var/list/smoltimefields = list()
	var/list/decofrozen = list()
	New(loc, immune, duration, size, freezeloop)
		..(loc)
		src.immune += immune // see below
		src.duration = duration // see below
		src.size = size //byond be like
		src.freezeloop = freezeloop
		for (var/turf/simulated/S in range(size, src))
			freeze_turf(S)
		for (var/atom/X in range(size, src))
			freeze_atom(X)
		for (var/turf/simulated/S in range(size, src))
			var/obj/effect/timefieldsmall/newsmalltimefield = new(S, src)
			smoltimefields += newsmalltimefield
		sleep(duration)
		unfreeze_all()
		src.immune -= immune
		for(var/t in smoltimefields)
			qdel(t)
			smoltimefields -= t


/obj/effect/timefieldsmall
	name = "smol timefield"
	desc = "you shouldnt be able to read this"
	density = 0
	anchored = 1
	opacity = 0
	alpha = 255
	var/obj/effect/timefield/masterfield

	New(var/loc, var/obj/effect/timefield/masterfield)
		..(loc)
		src.masterfield = masterfield

	Crossed(var/atom/crosser as mob|obj)
		..(crosser)
		masterfield.freeze_atom(crosser)

//inorder to time stop simply insert the timestop proc anywhere look at code/datums/abilities/wizard/timestop.dm for an example of how this could be used
proc/timestop(setimmune, setduration, setsize, var/loopfreeze = FALSE) // loopfreeze controls whether or not loops are unsubbed to when pausing of a thing. it defaults to no(0/FALSE)
	var/obj/effect/timefield/newtimefield = new(get_turf(usr), setimmune, setduration, setsize, loopfreeze)
	sleep(setduration)
	qdel(newtimefield)


/obj/effect/timefield/proc/freeze_atom(atom/movable/A)
	if(A in immune)
		return
	var/frozen = TRUE
	if(istype(A, /mob/living))
		freeze_mob(A)
	else if(istype(A, /obj/projectile))
		freeze_projectile(A)
	else if(istype(A, /obj/critter))
		freeze_critter(A)
	else if(istype(A, /obj/machinery))
		freeze_machinery(A)
	else if(istype(A, /obj) && A.throwing == 1)
		freeze_throwing(A)
		frozen = TRUE
	else if(istype(A, /obj) && !istype(A, /obj/overlay))
		old_colors["\ref[A]"] = A.color
		freeze_deco(A)
		decofrozen += A
		return
	else
		frozen = FALSE
	if(!frozen)
		return
	old_anchored["\ref[A]"] = A.anchored
	A.anchored = 1
	if(!(A in decofrozen))
		old_colors["\ref[A]"] = A.color
		reversecolourin(A)
	frozen_things += A
	return


/obj/effect/timefield/proc/unfreeze_all()
	for(var/i in frozen_things)
		unfreeze_atom(i)
	for(var/T in frozen_turfs)
		unfreeze_turf(T)
	for(var/d in decofrozen)
		unfreeze_deco(d)
		decofrozen -= d

/obj/effect/timefield/proc/unfreeze_atom(atom/movable/A)
	if(istype(A, /obj) && A.throwing == 1)
		unfreeze_throwing(A)
	if(isliving(A))
		unfreeze_mob(A)
	else if(istype(A, /obj/projectile))
		unfreeze_projectile(A)
	else if(istype(A, /obj/critter))
		unfreeze_critter(A)
	else if(istype(A, /obj/machinery))
		unfreeze_machinery(A)
	reversecolourout(A)
	A.anchored = old_anchored["\ref[A]"]
	frozen_things -= A
	return
/*
				FREEZING OF THINGS
*/
/obj/effect/timefield/proc/freeze_throwing(atom/movable/AM)
	AM.throwing_paused = TRUE
	var/matrix/transform_original = AM.transform
	animate(AM, transform = matrix(transform_original, 120, MATRIX_ROTATE | MATRIX_MODIFY), time = 8/3, loop = 1)
	animate(transform = matrix(transform_original, 120, MATRIX_ROTATE | MATRIX_MODIFY), time = 8/3, loop = 1)
	animate(transform = matrix(transform_original, 120, MATRIX_ROTATE | MATRIX_MODIFY), time = 8/3, loop = 1)

/obj/effect/timefield/proc/unfreeze_throwing(atom/movable/AM)
	AM.throwing_paused = FALSE
	var/matrix/transform_original = AM.transform
	animate(AM, transform = matrix(transform_original, 120, MATRIX_ROTATE | MATRIX_MODIFY), time = 8/3, loop = -1)
	animate(transform = matrix(transform_original, 120, MATRIX_ROTATE | MATRIX_MODIFY), time = 8/3, loop = -1)
	animate(transform = matrix(transform_original, 120, MATRIX_ROTATE | MATRIX_MODIFY), time = 8/3, loop = -1)

/obj/effect/timefield/proc/freeze_turf(turf/T)
	reversecolourin(T)
	frozen_turfs += T

/obj/effect/timefield/proc/unfreeze_turf(turf/T)
	reversecolourout(T)


/obj/effect/timefield/proc/freeze_projectile(obj/projectile/P)
	P.projectile_paused = TRUE

/obj/effect/timefield/proc/unfreeze_projectile(obj/projectile/P)
	P.projectile_paused = FALSE

/obj/effect/timefield/proc/freeze_mob(mob/living/L)
	L.ai_prefrozen = L.ai_active
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.ai_set_active(0)
	L.paused = 1
	if(freezeloop)
		mobs.Remove(L)

/obj/effect/timefield/proc/unfreeze_mob(mob/living/L)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.ai_set_active(L.ai_prefrozen)  // makes sure the ai is the same as before
	L.paused = 0
	L.TakeDamage("chest", L.pausedbrute, 0, 0, DAMAGE_BLUNT) // see below
	L.TakeDamage("chest", 0, L.pausedburn, 0, DAMAGE_BURN) // see below
	L.take_toxin_damage(L.pausedtox) // see below
	L.take_brain_damage(L.pausedbrain) // see below
	L.take_oxygen_deprivation(L.pausedoxy) // see below
	L.pausedbrute = 0 // see below
	L.pausedburn = 0 // see below
	L.pausedtox = 0 // see below
	L.pausedoxy = 0 // see below
	L.pausedbrain = 0 // needed for damage freezing
	if(freezeloop)
		mobs.Add(L)

/obj/effect/timefield/proc/freeze_critter(obj/critter/C)
	C.paused = 1

/obj/effect/timefield/proc/unfreeze_critter(obj/critter/C)
	C.paused = 0

/obj/effect/timefield/proc/freeze_machinery(obj/machinery/M)
//	if(freezeloop) //couldnt make it work(am lazy) - moon
//		machines.Remove(M)

/obj/effect/timefield/proc/unfreeze_machinery(obj/machinery/M)
//	if(freezeloop) //seeabove
//		machines.Add(M)

/obj/effect/timefield/proc/freeze_deco(obj/O)
	reversecolourin(O)

/obj/effect/timefield/proc/unfreeze_deco(obj/O)
	reversecolourout(O)

/obj/effect/timefield/proc/reversecolourin(atom/A) // reverses colours
	A.color = list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 0,0,0,1, 1,1,1,0)

/obj/effect/timefield/proc/reversecolourout(atom/A)
	A.color = old_colors["\ref[A]"] //un reverses colours
#endif
