/obj/item/plank
	name = "wooden plank"
	desc = "My best friend plank!"
	icon = 'icons/obj/materials.dmi'
	icon_state = "plank"
	force = 4.0
	//cogwerks - burn vars
	burn_point = 400
	burn_output = 1500
	burn_possible = 1
	health = 50

	stamina_damage = 50
	stamina_cost = 25
	stamina_crit_chance = 10

	New()
		..()
		BLOCK_SETUP(BLOCK_ALL)

	attack_self(mob/user as mob)
		var/turf/T = get_turf(user)
		if (locate(/obj/structure/woodwall) in T)
			boutput(usr, "<span class='alert'>There's already a barricade here!</span>")
			return
		actions.start(new /datum/action/bar/icon/plank_build(src, 30), user)
		return

	proc/construct(mob/user as mob, turf/T as turf)
		if (!T)
			T = user ? get_turf(user) : get_turf(src)
			if (!T) // buh??
				return
		if (locate(/obj/structure/woodwall) in T)
			return

		var/obj/structure/woodwall/newWall = new (T)
		if (newWall)
			if (src.material)
				newWall.setMaterial(src.material)
			if (user)
				newWall.add_fingerprint(user)
				newWall.builtby = user.real_name
				logTheThing("station", user, null, "builds \a [newWall] (<b>Material:</b> [newWall.material && newWall.material.mat_id ? "[newWall.material.mat_id]" : "*UNKNOWN*"]) at [log_loc(T)].")
				user.u_equip(src)
		qdel(src)
		return

	proc/construct_door(var/obj/item/plank/C, mob/user as mob)
		var/turf/T = get_turf(user)
		if(user.loc == T)
			if(!locate(/obj/machinery/door/unpowered/wood) in T)
				new /obj/machinery/door/unpowered/wood(T)
				qdel(src)
				qdel(C)
			boutput(usr, "<span class='alert'>There's already a door here!</span>")
			return
		else
			return

	attackby(obj/item/C as obj, mob/user as mob)
		if (istype(C, /obj/item/plank))
			actions.start(new /datum/action/bar/icon/plank_build_door(C, src, 30), user)

//bad copy paste, bad code. - kyle me made, bad
/obj/item/plank/anti_zombie
	construct(mob/user as mob, turf/T as turf)
		if (!T)
			T = user ? get_turf(user) : get_turf(src)
			if (!T) // buh??
				return
		if (locate(/obj/structure/woodwall) in T)
			return

		var/obj/structure/woodwall/anti_zombie/newWall = new (T)
		if (newWall)
			if (src.material)
				newWall.setMaterial(src.material)
			if (user)
				newWall.add_fingerprint(user)
				newWall.builtby = user.real_name
				logTheThing("station", user, null, "builds \a [newWall] (<b>Material:</b> [newWall.material && newWall.material.mat_id ? "[newWall.material.mat_id]" : "*UNKNOWN*"]) at [log_loc(T)].")
				user.u_equip(src)
		qdel(src)
		return

/* -------------------- Actions -------------------- */
/datum/action/bar/icon/plank_build
	id = "plank_build"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	#ifdef HALLOWEEN
	duration = 20
	#else
	duration = 30
	#endif
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/item/plank/plank

	New(var/obj/item/plank/P, var/duration_i)
		..()
		plank = P
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (plank == null || owner == null || get_dist(owner, plank) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && plank != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		owner.visible_message("<span class='notice'>[owner] begins constructing a wooden barricade!</span>")

	onEnd()
		..()
		owner.visible_message("<span class='notice'>[owner] constructs a wooden barricade!</span>")
		plank.construct(owner)


/datum/action/bar/icon/plank_build_door
	id = "plank_build_door"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 30
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/item/plank/plank
	var/obj/item/plank/otherplank

	New(var/obj/item/plank/P, var/obj/item/plank/PP, var/duration_i)
		..()
		plank = P
		otherplank = PP
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (plank == null || owner == null || otherplank == null || get_dist(owner, plank) > 1 || get_dist(owner, otherplank) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && plank != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		owner.visible_message("<span class='notice'>[owner] begins constructing a wooden door!</span>")

	onEnd()
		..()
		owner.visible_message("<span class='notice'>[owner] constructs a wooden door!</span>")
		plank.construct_door(otherplank, owner)
