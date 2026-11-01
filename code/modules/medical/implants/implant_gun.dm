/* =============================================================== */
/* ------------------------- Implant Gun ------------------------- */
/* =============================================================== */

TYPEINFO(/obj/item/gun/implanter)
	analyser_flags = parent_type::analyser_flags | ANALYSER_ELECTRONIC
	mats = 8

/obj/item/gun/implanter
	name = "implant gun"
	desc = "A gun that accepts an implant, that you can then shoot into other people! Or a wall, which certainly wouldn't be too big of a waste, since you'd only be using this to shoot people with things like health monitor or rotbusttec implants. Right?"
	icon = 'icons/obj/items/guns/kinetic.dmi'
	icon_state = "implant"
	contraband = 1
	var/obj/item/implant/my_implant = null
	recoil_strength = 1

	New()
		set_current_projectile(new/datum/projectile/implanter)
		..()

	get_desc()
		. += "There is [my_implant ? "\a [my_implant]" : "currently no implant"] loaded into it."

	attackby(var/obj/item/W, var/mob/user)
		var/obj/item/implant/I = null
		if (istype(W, /obj/item/implant))
			I = W
		else if (istype(W, /obj/item/implanter))
			var/obj/item/implanter/implanter = W
			if (implanter.imp)
				I = implanter.imp
		else if (istype(W, /obj/item/implantcase))
			var/obj/item/implantcase/case = W
			if (case.imp)
				I = case.imp
		else
			return ..()
		if (I)
			if (my_implant)
				user.show_text("[src] already has an implant in it!", "red")
				return

			my_implant = I
			tooltip_rebuild = TRUE

			if (istype(W, /obj/item/implant))
				user.u_equip(W)
			else if (istype(W, /obj/item/implanter))
				var/obj/item/implanter/implanter = W
				implanter.imp = null
				implanter.update()
			else if (istype(W, /obj/item/implantcase))
				var/obj/item/implantcase/case = W
				case.imp = null
				case.update()

			I.set_loc(src)
			user.show_text("You load [I] into [src].", "blue")

			if (!current_projectile)
				set_current_projectile(new/datum/projectile/implanter)
			var/datum/projectile/implanter/my_datum = current_projectile
			my_datum.my_implant = my_implant
			my_datum.implant_master = user

		else
			return ..()

	canshoot(mob/user)
		if (!my_implant)
			return 0
		return 1

	process_ammo(var/mob/user)
		if (!my_implant)
			return 0
		if (!current_projectile)
			set_current_projectile(new/datum/projectile/implanter)
		var/datum/projectile/implanter/my_datum = current_projectile
		if (ismob(user) && my_datum.implant_master != user)
			my_datum.implant_master = user
		return 1

	alter_projectile(var/obj/projectile/P)
		if (!P || !my_implant)
			return ..()
		my_implant.set_loc(P)
		my_implant = null
		tooltip_rebuild = TRUE

ADMIN_INTERACT_PROCS(/obj/item/gun/implanter/infinite, proc/set_implant_type)
TYPEINFO(/obj/item/gun/implanter/infinite)
	mats=null
/obj/item/gun/implanter/infinite
	name = "implant gun deluxe"
	desc = "This auto-regenerating implant gun is illegal in several Earth countries. Not that it matters here in space."

	var/implant_typepath = /obj/item/implant/bloodmonitor

	New()
		. = ..()
		src.my_implant = new src.implant_typepath(src)
		if (!current_projectile)
			set_current_projectile(new/datum/projectile/implanter)
		var/datum/projectile/implanter/my_datum = current_projectile
		my_datum.my_implant = my_implant
		if (ismob(src.loc))
			my_datum.implant_master = src.loc

	attackby(obj/item/I, mob/user)
		if (istypes(I, list(/obj/item/implant, /obj/item/implanter, /obj/item/implantcase)))
			boutput(user, SPAN_ALERT("The implant installed in [src] cannot be removed or replaced!"))
			return
		return ..()

	alter_projectile(obj/projectile/P)
		if (!P || !my_implant)
			return ..()
		src.my_implant.set_loc(P)

		src.my_implant = new src.implant_typepath(src)
		if (!current_projectile)
			set_current_projectile(new/datum/projectile/implanter)
		var/datum/projectile/implanter/my_datum = current_projectile
		my_datum.my_implant = my_implant
		if (ismob(src.loc))
			my_datum.implant_master = src.loc
		src.tooltip_rebuild = TRUE

	proc/set_implant_type()
		var/new_typepath = tgui_input_list(usr, "Select implant type", "Change Implant", concrete_typesof(/obj/item/implant), src.my_implant ? src.my_implant.type : /obj/item/implant/bloodmonitor)
		if (!ispath(new_typepath, /obj/item/implant))
			return

		if (src.my_implant)
			qdel(src.my_implant)
			src.my_implant = null
		src.implant_typepath = new_typepath
		src.my_implant = new src.implant_typepath(src)
		if (!current_projectile)
			set_current_projectile(new/datum/projectile/implanter)
		var/datum/projectile/implanter/my_datum = current_projectile
		my_datum.my_implant = my_implant
		if (ismob(src.loc))
			my_datum.implant_master = src.loc

/obj/item/gun/implanter/infinite/minigun
	name = "implant gun deluxe championship edition turbo"
	desc = "You feel a vague sense of terror just looking at this thing."
	icon = 'icons/obj/items/guns/kinetic64x32.dmi'
	icon_state = "minigun"
	item_state = "heavy"
	force = MELEE_DMG_LARGE
	two_handed = TRUE
	recoil_strength = 12
	spread_angle = 15
	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	c_flags = EQUIPPED_WHILE_HELD
	fire_animation = TRUE
	w_class = W_CLASS_BULKY

	New()
		AddComponent(/datum/component/holdertargeting/fullauto/ramping, 2.5, 0.4, 0.9) //you only get full auto, why would you burst fire with a minigun?
		. = ..()

	setupProperties()
		..()
		setProperty("carried_movespeed", 1.5) //the addative slow down does not play nice with the full auto so you get this instead

/obj/item/gun/implanter/infinite/minigun/confetti_cannon
	name = "confetti cannon!!!"
	desc = "You feel a vague sense of terror just looking at this thing. Honk."
	implant_typepath = /obj/item/implant/confetti

/obj/item/gun/implanter/infinite/minigun/microbomb_cannon
	name = "microbomb mass implanter"
	desc = "You feel the yearning maw of the void grip you tightly. It comes."
	implant_typepath = /obj/item/implant/revenge/microbomb

/datum/projectile/implanter
	name = "implant bullet"
	damage = 5
	shot_sound = 'sound/machines/click.ogg'
	damage_type = D_KINETIC
	hit_type = DAMAGE_STAB
	casing = /obj/item/casing/small
	impact_image_state = "bullethole-small"
	shot_number = 1
	fullauto_valid = TRUE
	//no_hit_message = 1
	var/obj/item/implant/my_implant = null
	var/mob/implant_master = null

	on_hit(atom/hit, angle, var/obj/projectile/O)
		if (!my_implant)
			return
		if (ishuman(hit))
			var/mob/living/carbon/human/H = hit
			if (my_implant.can_implant(H, implant_master))
				my_implant.implanted(H, implant_master)
			else
				my_implant.set_loc(get_turf(H))
		else if (ismobcritter(hit))
			var/mob/living/critter/C = hit
			if (C.can_implant && my_implant.can_implant(C, implant_master))
				my_implant.implanted(C, implant_master)
			else
				my_implant.set_loc(get_turf(C))
		else
			my_implant.set_loc(get_turf(O))

	on_max_range_die(var/obj/projectile/O)
		my_implant.set_loc(get_turf(O))
		..()
