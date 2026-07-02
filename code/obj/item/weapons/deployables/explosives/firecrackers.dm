/obj/item/device/light/sparkler/firecracker
	name = "firecracker"
	desc = "Known to ward off evil."
	icon = 'icons/obj/items/firecracker.dmi'
	icon_state = "firecracker"
	icon_on = "firecracker-lit"
	icon_off = "firecracker"
	inhand_image_icon = 'icons/obj/items/firecracker.dmi'
	item_state = "firecracker"
	item_on = "firecracker-lit"
	item_off = "firecracker"

	gen_sparks()
		src.sparks--
		elecflash(src)
		if(!sparks)
			detonate()
		return

	throw_impact(atom/hit_atom, datum/thrown_thing/thr=null)
		if(!..() && src.on)
			src.detonate()

	proc/detonate()
		var/turf/T = get_turf(src)
		playsound(T, 'sound/effects/smoke.ogg', 20, TRUE, -2)
		explosion(src, T, -1, -1, -0.25, 1)
		new /obj/effects/flintlock_smoke(T)
		var/mob/M = src.loc
		SPAWN(0.1 SECONDS)
			qdel(src)
			if(istype(M))
				M.update_inhands()

/obj/item/device/light/sparkler/firecracker/lit
	hit_type = DAMAGE_BURN
	force = 3
	icon_state = "firecracker-lit"
	item_state = "firecracker-lit"

	New()
		..()
		src.light()
