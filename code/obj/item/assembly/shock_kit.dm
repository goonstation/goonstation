/obj/item/assembly/shock_kit
	name = "Shock Kit"
	icon_state = "shock_kit"
	var/obj/item/clothing/head/helmet/part1 = null
	var/obj/item/device/radio/electropack/part2 = null
	status = 0
	w_class = W_CLASS_HUGE
	flags = TABLEPASS | CONDUCT

/obj/item/assembly/shock_kit/New(atom/newLoc, obj/item/clothing/head/helmet/helmet, obj/item/device/radio/electropack/electropack)
	..()
	helmet ||= new /obj/item/clothing/head/helmet(src)
	src.part1 = helmet
	helmet.master = src
	electropack ||= new /obj/item/device/radio/electropack(src)
	src.part2 = electropack
	electropack.master = src

/obj/item/assembly/shock_kit/disposing()
	if (src.part1)
		qdel(src.part1)
		src.part1 = null
	if (src.part2)
		qdel(src.part2)
		src.part2 = null
	..()

/obj/item/assembly/shock_kit/attackby(obj/item/W, mob/user)
	src.add_fingerprint(user)

	if (iswrenchingtool(W))
		var/turf/T = get_turf(src)
		if (src.part1)
			src.part1.set_loc(T)
			src.part1.master = null
			src.part1 = null
		if (src.part2)
			src.part2.set_loc(T)
			src.part2.master = null
			src.part2 = null
		qdel(src)
		return

	else return ..()

/obj/item/assembly/shock_kit/attack_self(mob/user as mob)
	src.part1.AttackSelf(user)
	src.part2.AttackSelf(user)
	src.add_fingerprint(user)
	return

/obj/item/assembly/shock_kit/receive_signal()
	if (src.master && istype(src.master, /obj/stool/chair/e_chair))
		var/obj/stool/chair/e_chair/C = src.master
		if (C.buckled_guy)
			logTheThing(LOG_SIGNALERS, usr, "signalled an electric chair (setting: [C.lethal ? "lethal" : "non-lethal"]), shocking [constructTarget(C.buckled_guy,"signalers")] at [log_loc(C)].") // Added (Convair880).
		C.shock()
	return
