/obj/rack
	name = "rack"
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	density = 1
	flags = FPRINT | NOSPLASH
	anchored = 1.0
	desc = "A metal frame used to hold objects. Can be wrenched and made portable."
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS

/obj/rack/New()
	..()
	var/bonus = 0
	for (var/obj/O in loc)
		if (isitem(O))
			bonus += 4
		if (istype(O, /obj/table))
			return
		if (istype(O, /obj/rack) && O != src)
			return
	var/area/Ar = get_area(src)
	if (Ar)
		Ar.sims_score = min(Ar.sims_score + bonus, 100)

/obj/rack/ex_act(severity)
	switch(severity)
		if(1.0)
			//src.deconstruct()
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				src.deconstruct()
				return
		if(3.0)
			if (prob(25))
				src.icon_state = "rackbroken"
				src.set_density(0)
		else
	return

/obj/rack/blob_act(var/power)
	if(prob(power * 2.5))
		src.deconstruct()
		return
	else if(prob(power * 2.5))
		src.icon_state = "rackbroken"
		src.set_density(0)
		return

/obj/rack/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if (mover.flags & TABLEPASS)
		return 1
	else
		return 0

/obj/rack/MouseDrop_T(obj/O as obj, mob/user as mob)
	if (!isitem(O) || !in_range(user, src) || !in_range(user, O) || user.restrained() || user.getStatusDuration("paralysis") || user.sleeping || user.stat || user.lying)
		return
	var/obj/item/I = O
	if (istype(I,/obj/item/satchel))
		var/obj/item/satchel/S = I
		if (S.contents.len < 1)
			boutput(usr, "<span class='alert'>There's nothing in [S]!</span>")
		else
			user.visible_message("<span class='notice'>[user] dumps out [S]'s contents onto [src]!</span>")
			for (var/obj/item/thing in S.contents)
				thing.set_loc(src.loc)
			S.desc = "A leather bag. It holds 0/[S.maxitems] [S.itemstring]."
			S.satchel_updateicon()
			return
	if (isrobot(user) || user.equipped() != I || (I.cant_drop || I.cant_self_remove))
		return
	user.drop_item()
	if (I.loc != src.loc)
		step(I, get_dir(I, src))
	return

/obj/rack/disposing()
	var/turf/OL = get_turf(src)
	if (!OL)
		return
	if (!(locate(/obj/table) in OL) && !(locate(/obj/rack) in OL))
		var/area/Ar = OL.loc
		for (var/obj/item/I in OL)
			Ar.sims_score -= 4
		Ar.sims_score = max(Ar.sims_score, 0)
	..()

/obj/rack/attackby(obj/item/W as obj, mob/user as mob)
	if (iswrenchingtool(W))
		actions.start(new /datum/action/bar/icon/rack_tool_interact(src, W), user)
	else
		src.place_on(W, user)
	return

/obj/rack/proc/deconstruct()
	var/obj/item/furniture_parts/P = new /obj/item/furniture_parts/rack(src.loc)
	if (P && src.material)
		P.setMaterial(src.material)
	qdel(src)

/obj/rack/meteorhit(obj/O as obj)
	if(prob(75))
		qdel(src)
		return
	else
		src.icon_state = "rackbroken"
		src.set_density(0)
	return

/datum/action/bar/icon/rack_tool_interact
	id = "rack_tool_interact"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 50
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/rack/the_rack
	var/obj/item/the_tool

	New(var/obj/rack/rak, var/obj/item/tool, var/duration_i)
		..()
		if (rak)
			the_rack = rak
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (the_rack == null || the_tool == null || owner == null || get_dist(owner, the_rack) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		playsound(get_turf(the_rack), "sound/items/Ratchet.ogg", 50, 1)
		owner.visible_message("<span class='notice'>[owner] begins disassembling [the_rack].</span>")

	onEnd()
		..()
		playsound(get_turf(the_rack), "sound/items/Deconstruct.ogg", 50, 1)
		owner.visible_message("<span class='notice'>[owner] disassembles [the_rack].</span>")
		the_rack.deconstruct()
