/obj/item/device/locker_deployer
	name = "Locker deployer"
	desc = "A targeting beacon that once activated causes a high-speed missile containing a storage device to be launched to it's location."
	icon_state = "nt_locator"
	w_class = W_CLASS_TINY
	var/obj/storage/storage_to_spawn = /obj/storage/secure/closet/nanotrasen
	var/activated = FALSE

	attack_self(mob/user)
		if(src.activated)
			boutput(user, SPAN_NOTICE("The beacon is already active!"))
			return
		if(get_z(src) != Z_LEVEL_STATION)
			boutput(user, SPAN_NOTICE("You must be on station to use this!"))
		src.activated = TRUE
		boutput(user, SPAN_NOTICE("You activate the targeting beacon!"))
		playsound(src.loc, 'sound/weapons/armbomb.ogg', 100, 1)
		src.icon_state = "[initial(src.icon_state)]_active"
		SPAWN(3 SECONDS)
			src.spawn_storage(user, get_turf(src))
			qdel(src)

	proc/spawn_storage(mob/user, turf/T)
		var/image/marker = image('icons/effects/64x64.dmi', T, "impact_marker")
		marker.pixel_x = -16
		marker.pixel_y = -16
		marker.plane = PLANE_OVERLAY_EFFECTS
		marker.layer = NOLIGHT_EFFECTS_LAYER_BASE
		marker.appearance_flags = RESET_ALPHA | RESET_COLOR | NO_CLIENT_COLOR | KEEP_APART | RESET_TRANSFORM | PIXEL_SCALE
		marker.alpha = 100
		user.client.images += marker
		SPAWN(0)
			launch_with_missile(new storage_to_spawn, T)
			qdel(marker)
			user.client.images -= marker

/obj/item/device/locker_deployer/ntsc
	storage_to_spawn = /obj/storage/secure/closet/nanotrasen/ntsc
