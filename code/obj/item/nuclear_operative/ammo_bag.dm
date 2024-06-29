/obj/item/ammo/ammobox
	sname = "Generic Ammobox"
	name = "Generic Ammobox"
	desc = "A generic ammobox for getting some ammunition."
	icon_state = "lmg_ammo-0-old"
	/*
	ammo_type = null
	caliber = null
	var/list/valid_calibers = list() //supports lists and single, set to "All" for any gun

	attackby(obj/item/gun/kinetic/W, mob/user)
		if(istype(W, /obj/item/gun/kinetic))
			if((islist(valid_calibers) && (initial(W.caliber) in valid_calibers) || (!islist(valid_calibers) && valid_calibers == initial(W.caliber)) || valid_calibers == "All"))
				new W.default_magazine(get_turf(src))
				var/obj/O = W.default_magazine
				boutput(user, SPAN_ALERT("You get a [O.name] out of [src]."))
				qdel(src)
			if(valid_calibers == "All")
				new W.default_magazine(get_turf(src))
				var/obj/O = W.default_magazine
				boutput(user, SPAN_ALERT("You get a [O.name] out of [src]."))
				qdel(src)
		else
			..()
	*///We'll deal with you later

/obj/item/ammo/ammobox/nukeop
	name = "Syndicate Ammo Bag"
	desc = "A bag that can fabricate magazines for standard syndicate weapons. Technology!"
	icon_state = "ammobag"
	item_state = "ammobag"
	var/charge = 10
	var/spec_ammo = FALSE
	var/deployed = FALSE

	New()
		..()
		if(!deployed)
			src.desc = "A folded up bag that, once deployed, can fabricate magazines for standard syndicate weapons. It has [src.charge] charge left."
		else
			src.desc = "A bag that can fabricate magazines for standard syndicate weapons. Technology! It has [src.charge] charge left."

	attack_self(mob/user)
		if(!deployed)
			user.visible_message("[user] begins unfolding a [src].", "You begin unfolding \the [src].")
			SETUP_GENERIC_ACTIONBAR(user, src, 5 SECONDS, /obj/item/ammo/ammobox/nukeop/proc/deploy_ammobag, user, src.icon, src.icon_state,"[user] finishes deploying a [src].", null)

	mouse_drop(atom/over_object, src_location, over_location, over_control, params)
		if(!(over_object == usr))
			return
		if(usr.equipped()) //empty hand required
			return

		if(deployed)
			usr.visible_message("[usr] begins folding up [src].", "You begin folding up \the [src].")
			SETUP_GENERIC_ACTIONBAR(usr, src, 5 SECONDS, /obj/item/ammo/ammobox/nukeop/proc/fold_ammobag, usr, src.icon, src.icon_state,"[usr] finishes folding up [src].", null)


	proc/deploy_ammobag(var/mob/user)
		force_drop(user)
		anchored = ANCHORED
		deployed = TRUE
		icon_state = "[initial(icon_state)]-d[charge <= 0 ? "-empty" : ""]"

	proc/fold_ammobag(var/mob/user)
		anchored = UNANCHORED
		deployed = FALSE
		icon_state = "[initial(icon_state)]"
		sleep(1 DECI SECOND)
		Attackhand(user)

	attackby(obj/item/gun/kinetic/W, mob/user)
		if(!deployed)
			boutput(user, SPAN_ALERT("The [src] isn't unfolded!"))
			return

		if(!istype(W))
			return

		if(!length(W.ammobag_magazines))
			return

		if(W.ammobag_spec_required && !spec_ammo)
			return

		if(ON_COOLDOWN(user, "nukeop_ammobag", 10 SECONDS))
			return

		var/ammo
		var/ammo_cost
		if(spec_ammo)
			if(length(W.ammobag_magazines) >= 2)
				var/list/ammo_list = W.ammobag_magazines.Copy(2, 0)
				ammo = pick(ammo_list)
				ammo_cost = W.ammobag_restock_cost
			else if(length(W.ammobag_magazines) == 1)
				ammo = W.ammobag_magazines[1]
				if(!W.ammobag_spec_required)
					ammo_cost = clamp(W.ammobag_restock_cost - 1, 0, 99)
				else
					ammo_cost = W.ammobag_restock_cost

		else
			ammo = W.ammobag_magazines[1]
			ammo_cost = W.ammobag_restock_cost

		if(charge >= ammo_cost)
			var/obj/item/created = new ammo(get_turf(src))
			boutput(user, SPAN_ALERT("You get an [initial(created.name)] out of [src]."))
			charge -= ammo_cost
		else
			boutput(user, SPAN_ALERT("The [src] doesn't have enough charge left to fabricate the ammo for [W]!"))
			return

		desc = "A bag that can fabricate magazines for standard syndicate weapons. Technology! It has [charge] charge left."
		if(charge <= 0)
			icon_state = "[initial(icon_state)]-d-empty"


/obj/item/ammo/ammobox/nukeop/spec_ammo
	name = "Syndicate Specialist Ammo Bag"
	desc = "A bag that can fabricate specialist magazines for standard syndicate weapons. Technology!"
	icon_state = "ammobag-sp"
	spec_ammo = TRUE

	New()
		..()
		desc = "A bag that can fabricate specialist magazines for standard syndicate weapons. Technology! It has [charge] charge left."

//Universal
/obj/item/ammo/ammobox/shootingrange
	name = "Shooting Range Ammo Bag"
	desc = "A universal ammo bag for kinetic ammunition."
	icon_state = "ammobag-sp-d"
	anchored = ANCHORED_ALWAYS

	New()
		..()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/gun/kinetic))
			var/obj/item/gun/kinetic/K = I
			if(!K.ammo.refillable)
				boutput(user, SPAN_ALERT("The ammobag grumps unhappily. What?"))
				return
			if(K.ammo.amount_left>=K.max_ammo_capacity)
				user.show_text("[K] is full!", "red")
				return
			K.ammo.amount_left = K.max_ammo_capacity
			K.UpdateIcon()
			user.visible_message(SPAN_ALERT("[user] refills [K] from [src]."), SPAN_ALERT("You fully refill [K] with ammo from [src]."))
			var/obj/item/ammo/bullets/magazine = K.default_magazine
			var/reload_sound = initial(magazine.sound_load)
			if(isnull(reload_sound))
				playsound(K, 'sound/weapons/gunload_light.ogg', 50, TRUE)
			else
				playsound(K, reload_sound, 50, TRUE)

	ex_act(severity)
		return
