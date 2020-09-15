/obj/item/gun/reagent
	name = "reagent gun"
	icon = 'icons/obj/items/gun.dmi'
	item_state = "gun"
	m_amt = 2000
	g_amt = 1000
	mats = 16
	add_residue = 0 // Does this gun add gunshot residue when fired? Energy guns shouldn't.
	var/capacity = 100 // reagent capacity of the gun
	var/list/ammo_reagents = null // list of reagents accepted as ammo, leave blank if you want any to be accepted
	var/projectile_reagents = 0 // whether the reagents should get transfered to the projectiles
	var/dump_reagents_on_turf = 0 //set this to 1 if you want the dumped reagents to be put onto the turf instead of just evaporated into nothingness
	var/custom_reject_message = "" //set this to a string if you want a custom message to be shown instead of the default when a reagent isnt accepted by the gun
	inventory_counter_enabled = 1

	New()
		src.create_reagents(capacity)
		..()

	move_trigger(var/mob/M, kindof)
		if (..() && reagents)
			reagents.move_trigger(M, kindof)

	is_open_container()
		return 1

	alter_projectile(source, var/obj/projectile/P)
		if(src.projectile_reagents && P && P.proj_data)
			if (!P.reagents)
				P.reagents = new /datum/reagents(P.proj_data.cost)
				P.reagents.my_atom = P
			src.reagents.trans_to(P, P.proj_data.cost)

	on_reagent_change(add)
		if(!add || !src.ammo_reagents)
			src.update_icon()
			return
		var/mob/M = ismob(src.loc) ? src.loc : null
		global.check_whitelist(src, src.ammo_reagents, M, src.custom_reject_message)
		src.update_icon()

	get_desc()
		. = "[src.projectiles ? "It is set to [src.current_projectile.sname]. " : ""]There are [src.reagents.total_volume]/[src.reagents.maximum_volume] units left!"
		if(src.current_projectile)
			. += " Each shot will currently use [src.current_projectile.cost] units!"
		else
			. += "<span class='alert'>*ERROR* No output selected!</span>"
		..()

	update_icon()
		if (src.current_projectile)
			var/amt = round(src.reagents.total_volume / src.current_projectile.cost)
			inventory_counter.update_number(amt)
		else
			inventory_counter.update_percent(src.reagents.total_volume, src.reagents.maximum_volume)

		return 0

	canshoot()
		if(src.reagents && src.current_projectile)
			if(src.reagents.total_volume >= src.current_projectile.cost)
				return 1
		return 0

	process_ammo(var/mob/user)
		if (!canshoot())
			boutput(user, "<span class='alert'>\The [src]'s internal reservoir does not contain enough reagents to fire it!</span>")
		if(!src.projectile_reagents)
			src.reagents.remove_any(src.current_projectile.cost)
			src.update_icon()
		return 1

	MouseDrop(over_object, src_location, over_location)
		..()
		if(!isliving(usr))
			return

		if(get_dist(src, usr) > 1)
			boutput(usr, "<span class='alert'>You need to be closer to empty \the [src] out!</span>")
			return

		if (!src.reagents)
			boutput(usr, "<span class='alert'>The little cap on the fluid container is stuck. Uh oh.</span>")
			return

		if(src.reagents.total_volume)
			if (src.dump_reagents_on_turf)
				logTheThing("combat", usr, null, "transfers chemicals from [src] [log_reagents(src)] to [get_turf(src)] at [log_loc(usr)].")
				src.reagents.trans_to(get_turf(src), src.reagents.total_volume)
			src.reagents.clear_reagents()
			src.update_icon()
			boutput(usr, "<span class='notice'>You dump out \the [src]'s stored reagents.</span>")
		else
			boutput(usr, "<span class='alert'>There's nothing loaded to drain!</span>")

	attackby(obj/item/I as obj, mob/user as mob)
		if (istype(I, /obj/item/reagent_containers/glass))
			return

		return ..()

/obj/item/gun/reagent/syringe
	name = "syringe gun"
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 4.0
	current_projectile = new/datum/projectile/syringe
	contraband = 3
	add_residue = 1 // Does this gun add gunshot residue when fired? These syringes are probably propelled by CO2 or something, but whatever (Convair880).
	mats = 12 // These are some of the few syndicate items that would be genuinely useful to non-antagonists when scanned.
	is_syndicate = 0 // Gonna let mechanics scan these, even without the syndicate scanner. THIS MAY BE A BAD IDEA.
	capacity = 90
	projectile_reagents = 1
	dump_reagents_on_turf = 1
	tooltip_flags = REBUILD_DIST

	get_desc(dist)
		if (dist > 2)
			return
		. = "<br>[round(src.reagents.total_volume/15)] / [round(src.reagents.maximum_volume/src.current_projectile.cost)] shots available.<br><span class='notice'>The internal reservoir contains:</span>"
		if (src.reagents.reagent_list.len)
			for (var/current_id in src.reagents.reagent_list)
				var/datum/reagent/current_reagent = src.reagents.reagent_list[current_id]
				. += "<br><span class='notice'>&emsp; [current_reagent.volume] units of [current_reagent.name]</span>"
		else
			. += "<br><span class='notice'>&emsp; Nothing</span>"

/obj/item/gun/reagent/syringe/NT
	name = "NT syringe gun"
	icon_state = "syringegun-NT"
	item_state = "syringegun-NT"
	contraband = 1
	ammo_reagents = list()
	var/safe = 1

	New()
		..()
		if (src.safe && islist(global.chem_whitelist) && global.chem_whitelist.len)
			src.ammo_reagents = global.chem_whitelist

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.safe)
			return 0
		if (user)
			boutput(user, "<span class='alert'>[src]'s safeties have been disabled.</span>")
		src.safe = 0
		src.ammo_reagents = null
		var/image/magged = image(src.icon, "syringemag", layer = FLOAT_LAYER)
		src.UpdateOverlays(magged, "emagged")
		return 1

/obj/item/gun/reagent/syringe/NT/emagged
	New()
		..()
		src.emag_act()


/obj/item/gun/reagent/ecto
	name = "ectoblaster"
	icon_state = "ecto0"
	ammo_reagents = list("ectoplasm")
	force = 7.0
	desc = "A weapon that launches concentrated ectoplasm. Harmless to humans, deadly to ghosts."

	New()
		current_projectile = new/datum/projectile/ectoblaster
		projectiles = list(current_projectile)
		..()

	update_icon()
		if(src.reagents)
			var/ratio = min(1, src.reagents.total_volume / src.reagents.maximum_volume)
			ratio = round(ratio, 0.25) * 100
			src.icon_state = "ecto[ratio]"
			return

	attackby(obj/item/I as obj, mob/user as mob)
		if (istype(I, /obj/item/reagent_containers/food/snacks/ectoplasm) && !src.reagents.is_full())
			I.reagents.trans_to(src, I.reagents.total_volume)
			user.visible_message("<span style=\"color:red\">[user] smooshes a glob of ectoplasm into [src].</span>")
			qdel(I)
			return

		return ..()
