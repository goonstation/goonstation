/obj/machinery/shredder
	name = "shredder"
	desc = "Don't stick your hand in there..."
	icon = 'icons/obj/machines/shredder.dmi'
	icon_state = "feed_grinder"
	power_usage = 100
	density = 1
	anchored = ANCHORED
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WIRECUTTERS | DECON_WRENCH
	/// What can a shredder shred?
	var/accepted_types = list(/obj/item/card, /obj/item/paper, /obj/item/toy/diploma, /obj/item/currency/spacecash)
	///Visual proxy for the thing being shredded
	var/atom/movable/proxy = null

/obj/machinery/shredder/New()
	. = ..()
	src.AddComponent(/datum/component/obj_projectile_damage)

/obj/machinery/shredder/attackby(obj/item/item, mob/user)
	if (!istypes(item, src.accepted_types))
		return ..()
	if (src.shredding)
		return
	user.u_equip(item)
	src.shred(item)

/obj/machinery/shredder/power_change()
	. = ..()


/obj/machinery/shredder/onDestroy()
	if (src.powered())
		elecflash(src, power = 2)
	playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 50, 1)
	. = ..()

/obj/machinery/shredder/proc/shred(obj/item/item)
	set waitfor = FALSE

	src.proxy = new
	src.proxy.mouse_opacity = FALSE
	src.proxy.appearance = item.appearance
	src.proxy.transform = null
	//tech shamelessly stolen from the kitchen gibber
	var/icon/mask_icon = icon('icons/obj/kitchen_grinder_mask.dmi', "shredder-mask")

	//some things go in sideways
	if (istypes(item, list(/obj/item/card, /obj/item/currency/spacecash)))
		//rotate the icon ONLY so the alpha mask filter doesn't get messed up
		var/icon/icon = getFlatIcon(item)
		icon.Turn(90)
		src.proxy.icon = icon

	src.proxy.pixel_x = 0
	src.proxy.pixel_y = 24

	src.proxy.add_filter("grinder_mask", 1, alpha_mask_filter(x=0, y=-16, icon=mask_icon))

	animate(src.proxy, pixel_y = -8, time = 70)
	animate(src.proxy.get_filter("grinder_mask"), y = 32, time = 105, flags=ANIMATION_PARALLEL)
	src.vis_contents += src.proxy
	//particles come out a bit late so they don't show up before it hits the shredder (hopefully)
	sleep(2 SECOND)
	// https://pixabay.com/sound-effects/technology-paper-shredder-02-421981/
	playsound(src, 'sound/machines/shredder.ogg', 50, 0)
	global.particleMaster.SpawnSystem(new /datum/particleSystem/shredded(src, target = item))
	sleep (5 SECONDS)
	QDEL_NULL(src.proxy)
	QDEL_NULL(item)
