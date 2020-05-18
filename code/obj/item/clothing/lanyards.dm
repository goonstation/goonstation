/obj/item/clothing/lanyard
	name = "lanyard"
	desc = "Only dorks wear these."
	icon = 'icons/obj/clothing/item_lanyards.dmi'
	wear_image_icon = 'icons/mob/lanyards.dmi'
	icon_state = "blue"
	var/obj/item/card/id/ID_card = null
	var/registered = null

	New()
		..()
		AddComponent(/datum/component/storage)

	attackby(obj/item/W, mob/user, params)
		..()
		if (istype(W, /obj/item/card/id))
			var/obj/item/card/id/ID = W
			src.registered = ID.registered

	attack_self(mob/user)
		attack_hand(user)
		..()

/datum/component/storage
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/obj/owner
	var/datum/hud/storage/hud
	var/list/can_hold
	var/in_list_or_max = 0
	var/max_wclass = 2
	var/slots = 7
	var/sneaky = 0
	var/does_not_open_in_pocket = 1

/datum/component/storage/Initialize(var/list/spawn_contents)
	if (!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_OBJ_ATTACK_BY), .proc/attack_by)
	RegisterSignal(parent, list(COMSIG_OBJ_ATTACK_HAND), .proc/attack_hand)
	RegisterSignal(parent, list(COMSIG_OBJ_MOVE_TRIGGER), .proc/move_trigger)
	src.hud = new(src)
	SPAWN_DBG(1 DECI SECOND)
		if (spawn_contents)
			src.make_my_stuff(spawn_contents)

/datum/component/storage/move_trigger(var/mob/M, kindof)
	for (var/obj/O in contents)
		if (O.move_triggered)
			O.move_trigger(M, kindof)

/datum/component/storage/disposing()
	if (hud)
		for (var/mob/M in hud.mobs)
			if (M.s_active == src)
				M.s_active = null
		qdel(hud)
		hud = null
	..()

/datum/component/storage/RegisterWithParent()
	src.owner = src.parent

/datum/component/storage/proc/attack_by(obj/source, obj/item/W, mob/user)
	if (W.cant_drop)
		return
	if (islist(src.can_hold) && src.can_hold.len)
		var/ok = 0
		if (src.in_list_or_max && W.w_class <= src.max_wclass)
			ok = 1
		else
			for (var/A in src.can_hold)
				if (ispath(A) && istype(W, A))
					ok = 1
		if (!ok)
			boutput(user, "<span class='alert'>[src.owner] cannot hold [W].</span>")
			return

	else if (W.w_class > src.max_wclass)
		boutput(user, "<span class='alert'>[W] won't fit into [src.owner]!</span>")
		return

	var/list/my_contents = src.get_contents()
	if (my_contents.len >= slots)
		boutput(usr, "<span class='alert'>[src.owner] is full!</span>")
		return 0

	var/atom/checkloc = src.owner.loc
	while (checkloc && !isturf(src.owner.loc))
		if (checkloc == W)
			return
		checkloc = checkloc.loc

	user.u_equip(W)
	W.dropped(user)
	src.add_contents(W)
	hud.add_item(W)

	src.owner.add_fingerprint(user)
	animate_storage_rustle(src.owner)
	if (!src.sneaky && !istype(W, /obj/item/gun/energy/crossbow))
		user.visible_message("<span class='notice'>[user] has added [W] to [src.owner]!</span>", "<span class='notice'>You have added [W] to [src.owner].</span>")
	playsound(src.owner.loc, "rustle", 50, 1, -5)

/datum/component/storage/proc/attack_hand(obj/source, mob/user)
	if (!src.sneaky)
		playsound(src.owner.loc, "rustle", 50, 1, -2)
	if (src.owner.loc == user && (!does_not_open_in_pocket || src.owner == user.l_hand || src.owner == user.r_hand))
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.limbs)
				if ((src.owner == H.l_hand && istype(H.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item)) || (src.owner == H.r_hand && istype(H.limbs.r_arm, /obj/item/parts/human_parts/arm/right/item)))
					return
		if (user.s_active)
			user.detach_hud(user.s_active)
			user.s_active = null
		if (src.mousetrap_check(user))
			return
		user.s_active = src.hud
		hud.update()
		user.attach_hud(src.hud)
		src.owner.add_fingerprint(user)
		animate_storage_rustle(src.owner)
	else
		for (var/mob/M in src.hud.mobs)
			if (M != user)
				M.detach_hud(src.hud)
		src.hud.update()

/datum/component/storage/proc/add_contents(obj/item/I)
	I.set_loc(src.owner)

/datum/component/storage/proc/get_contents()
	RETURN_TYPE(/list)
	var/list/cont = src.owner.contents.Copy()
	for(var/atom/A in cont)
		if(!istype(A, /obj/item) || istype(A, /obj/item/grab))
			cont.Remove(A)
	return cont

/datum/component/storage/proc/get_all_contents()
	var/list/L = list()
	L += get_contents()
	for (var/obj/item/storage/S in get_contents())
		L += S.get_all_contents()
	return L

/datum/component/storage/proc/mousetrap_check(mob/user)
	if (!ishuman(user) || user.stat)
		return
	for (var/obj/item/mousetrap/MT in src.owner.contents)
		if (MT.armed)
			user.visible_message("<span class='alert'><B>[user] reaches into [src.owner] and sets off a mousetrap!</B></span>",\
			"<span class='alert'><B>You reach into [src.owner], but there was a live mousetrap in there!</B></span>")
			MT.triggered(user, user.hand ? "l_hand" : "r_hand")
			. = 1
	for (var/obj/item/mine/M in src.owner.contents)
		if (M.armed && M.used_up != 1)
			user.visible_message("<span class='alert'><B>[user] reaches into [src.owner] and sets off a [M]!</B></span>",\
			"<span class='alert'><B>You reach into [src.owner], but there was a live [M] in there!</B></span>")
			M.triggered(user)
			. = 1

/datum/component/storage/proc/make_my_stuff(list/spawn_contents) // use this rather than overriding the container's New()
	for (var/thing in spawn_contents)
		if (!ispath(thing))
			continue
		if (isnum(spawn_contents[thing])) //Instead of duplicate entries in the list, let's make them associative
			var/amt = abs(spawn_contents[thing])
		for (amt, amt>0, amt--)
			new thing(src.owner)
	return 1
