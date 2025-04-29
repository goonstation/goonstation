TYPEINFO(/obj/item/gun/reagent)
	mats = 16

/obj/item/gun/reagent
	name = "reagent gun"
	item_state = "gun"
	m_amt = 2000
	g_amt = 1000
	add_residue = 0 // Does this gun add gunshot residue when fired? Energy guns shouldn't.
	var/capacity = 100 // reagent capacity of the gun
	var/list/ammo_reagents = null // list of reagents accepted as ammo, leave blank if you want any to be accepted
	var/projectile_reagents = 0 // whether the reagents should get transfered to the projectiles
	var/dump_reagents_on_turf = 0 //set this to 1 if you want the dumped reagents to be put onto the turf instead of just evaporated into nothingness
	var/custom_reject_message = "" //set this to a string if you want a custom message to be shown instead of the default when a reagent isnt accepted by the gun
	///will fill a projectile only partway
	var/fractional = FALSE
	inventory_counter_enabled = 1
	move_triggered = 1
	recoil_strength = 1

	New()
		src.create_reagents(capacity)
		..()

	move_trigger(var/mob/M, kindof)
		if (..() && reagents)
			reagents.move_trigger(M, kindof)

	is_open_container()
		return 1

	alter_projectile(var/obj/projectile/P)
		if(src.projectile_reagents && P?.proj_data)
			if (!P.reagents)
				P.reagents = new /datum/reagents(P.proj_data.cost)
				P.reagents.my_atom = P
			src.reagents.trans_to(P, P.proj_data.cost)

	on_reagent_change(add)
		..()
		if(!add || !src.ammo_reagents)
			src.UpdateIcon()
			return
		var/mob/M = ismob(src.loc) ? src.loc : null
		global.check_whitelist(src, src.ammo_reagents, M, src.custom_reject_message)
		src.UpdateIcon()

	get_desc()
		. = "[(length(src.firemodes) > 1) ? "It is set to [src.current_projectile.sname]. " : ""]There are [src.reagents.total_volume]/[src.reagents.maximum_volume] units left!"
		if(src.current_projectile)
			. += " Each shot will currently use [src.current_projectile.cost] units!"
		else
			. += SPAN_ALERT("*ERROR* No output selected!")
		..()

	update_icon()

		if (src.current_projectile)
			var/amt = round(src.reagents.total_volume) / round(src.current_projectile.cost)
			if(fractional)
				amt = ceil(round(amt, 0.1))
			else
				amt = round(amt)
			inventory_counter.update_number(amt)
		else
			inventory_counter.update_percent(src.reagents.total_volume, src.reagents.maximum_volume)

		return 0

	canshoot(mob/user)
		if(src.reagents && src.current_projectile)
			if(src.fractional && src.reagents.total_volume > 0)
				return 1
			else if(src.reagents.total_volume >= src.current_projectile.cost)
				return 1
		return 0

	process_ammo(var/mob/user)
		if (!canshoot(user))
			boutput(user, SPAN_ALERT("\The [src]'s internal reservoir does not contain enough reagents to fire it!"))
		if(!src.projectile_reagents)
			src.reagents.remove_any(src.current_projectile.cost)
			src.UpdateIcon()
		return 1

	mouse_drop(over_object, src_location, over_location)
		..()
		if(!isliving(usr))
			return

		if(BOUNDS_DIST(src, usr) > 0)
			boutput(usr, SPAN_ALERT("You need to be closer to empty \the [src] out!"))
			return

		if (!src.reagents)
			boutput(usr, SPAN_ALERT("The little cap on the fluid container is stuck. Uh oh."))
			return

		if(src.reagents.total_volume)
			if (src.dump_reagents_on_turf)
				logTheThing(LOG_CHEMISTRY, usr, "transfers chemicals from [src] [log_reagents(src)] to [get_turf(src)] at [log_loc(usr)].")
				src.reagents.reaction(get_turf(src), TOUCH, src.reagents.total_volume)
			src.reagents.clear_reagents()
			src.UpdateIcon()
			boutput(usr, SPAN_NOTICE("You dump out \the [src]'s stored reagents."))
		else
			boutput(usr, SPAN_ALERT("There's nothing loaded to drain!"))

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/reagent_containers/glass))
			return

		return ..()

TYPEINFO(/obj/item/gun/reagent/syringe)
	mats = 12 // These are some of the few syndicate items that would be genuinely useful to non-antagonists when scanned.

/obj/item/gun/reagent/syringe
	name = "syringe gun"
	icon = 'icons/obj/items/guns/syringe.dmi'
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = W_CLASS_NORMAL
	throw_speed = 2
	throw_range = 10
	force = 4
	contraband = 3
	add_residue = 1 // Does this gun add gunshot residue when fired? These syringes are probably propelled by CO2 or something, but whatever (Convair880).
	is_syndicate = 0 // Gonna let mechanics scan these, even without the syndicate scanner. THIS MAY BE A BAD IDEA.
	capacity = 90
	projectile_reagents = 1
	dump_reagents_on_turf = 1
	tooltip_flags = REBUILD_DIST

	New()
		set_current_projectile(new/datum/projectile/syringe/syringe_barbed)
		. = ..()

	get_desc(dist)
		if (dist > 2)
			return
		. = "<br>[round(src.reagents.total_volume/15)] / [round(src.reagents.maximum_volume/src.current_projectile.cost)] shots available.<br>[SPAN_NOTICE("The internal reservoir contains:")]"
		if (src.reagents.reagent_list.len)
			for (var/current_id in src.reagents.reagent_list)
				var/datum/reagent/current_reagent = src.reagents.reagent_list[current_id]
				. += "<br>[SPAN_NOTICE("&emsp; [current_reagent.volume] units of [current_reagent.name]")]"
		else
			. += "<br>[SPAN_NOTICE("&emsp; Nothing")]"

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		var/obj/projectile/P = ..()
		if (istype(P)) //we actually shot something
			P.create_reagents()


/obj/item/gun/reagent/syringe/NT
	name = "NT syringe gun"
	icon_state = "syringegun-NT"
	item_state = "syringegun-NT"
	contraband = 1
	ammo_reagents = list()
	var/safe = 1

	New()
		..()
		set_current_projectile(new/datum/projectile/syringe)
		if (src.safe && islist(global.chem_whitelist) && length(global.chem_whitelist))
			src.ammo_reagents = global.chem_whitelist

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.safe)
			return 0
		if (user)
			boutput(user, SPAN_ALERT("[src]'s volumetric limiter safeties have been disabled."))
		src.safe = 0
		src.fractional = TRUE
		src.current_projectile.cost = 90
		src.UpdateIcon()
		var/image/magged = image(src.icon, "syringemag", layer = FLOAT_LAYER)
		src.UpdateOverlays(magged, "emagged")
		return 1

/obj/item/gun/reagent/syringe/NT/emagged
	New()
		..()
		src.emag_act()


/obj/item/gun/reagent/syringe/love
	name = "Love Gun"
	icon_state = "syringegun-love"
	item_state = "syringegun-love"
	contraband = 1
	capacity = 250
	ammo_reagents = list("love", "hugs")
	custom_reject_message = "This Gun was built for Love, not War!"

	New()
		..()
		set_current_projectile(new/datum/projectile/syringe)
		src.reagents.add_reagent("love", src.reagents.maximum_volume)


/obj/item/gun/reagent/syringe/love/plus // Sometimes you just need more love in your life.
	name = "Love Gun Plus"
	capacity = 1000

/obj/item/gun/reagent/ecto
	name = "ectoblaster"
	desc = "A weapon that launches concentrated ectoplasm. Harmless to humans, deadly to ghosts."
	icon = 'icons/obj/items/guns/energy.dmi'
	icon_state = "ghost"
	ammo_reagents = list("ectoplasm")
	force = 7

	New()
		set_current_projectile(new/datum/projectile/ectoblaster)
		add_firemode(null, current_projectile)
		..()

	update_icon()

		if(src.reagents)
			var/ratio = min(1, src.reagents.total_volume / src.reagents.maximum_volume)
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "ecto[ratio]"
			return

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/reagent_containers/food/snacks/ectoplasm) && !src.reagents.is_full())
			I.reagents.trans_to(src, I.reagents.total_volume)
			user.visible_message(SPAN_ALERT("[user] smooshes a glob of ectoplasm into [src]."))
			qdel(I)
			return

		return ..()
