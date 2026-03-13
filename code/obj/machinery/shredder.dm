TYPEINFO(/obj/machinery/shredder)
	mats = 6
/obj/machinery/shredder
	name = "shredder"
	desc = "Don't stick your hand in there..."
	icon = 'icons/obj/machines/shredder.dmi'
	icon_state = "shredder"
	power_usage = 100
	density = 1
	anchored = ANCHORED
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WIRECUTTERS | DECON_WRENCH
	/// What can a shredder shred?
	var/accepted_types = list(/obj/item/card, /obj/item/paper, /obj/item/toy/diploma, /obj/item/currency/spacecash, /obj/item/currency/fishing, /obj/item/random_mail)
	/// Some things get rotated 90 degrees to fit better
	var/rotated_types = list(/obj/item/card, /obj/item/currency/spacecash, /obj/item/currency/fishing)
	/// Visual proxy for the thing being shredded
	var/atom/movable/proxy = null
	var/shredding = FALSE
	var/emagged = FALSE
	/// The little shredded paper window icon
	var/icon/shreddings_icon
	/// How many shreddings are in the window?
	var/shreddings_count = 0

/obj/machinery/shredder/New()
	. = ..()
	src.shreddings_icon = icon(src.icon, "blank") //todo: fix this
	src.underlays += icon(src.icon, src.icon_state)
	src.icon = src.shreddings_icon
	src.AddComponent(/datum/component/obj_projectile_damage)

/obj/machinery/shredder/emag_act(mob/user, obj/item/card/emag/E)
	if (src.emagged)
		return FALSE
	boutput(user, "You short out [src]'s finger-grabbing inhibitors!")
	src.emagged = TRUE
	return TRUE

/obj/machinery/shredder/attackby(obj/item/item, mob/user)
	if (!istypes(item, src.accepted_types))
		return ..()
	if (istype(item, /obj/item/card/emag)) //fine, I am merciful
		return ..()
	if (src.shredding)
		return
	if (src.emagged)
		src.limb_tax(user)
		return
	user.u_equip(item)
	src.shred(item)

/obj/machinery/shredder/attack_hand(mob/user)
	if (src.shredding)
		return
	if (src.emagged)
		src.limb_tax(user)
		return
	. = ..()

/obj/machinery/shredder/proc/limb_tax(mob/living/carbon/human/victim)
	if (!ishuman(victim))
		return //todo
	var/obj/item/arm = null
	if (victim.hand)
		arm = victim.limbs.l_arm.remove()
	else
		arm = victim.limbs.r_arm.remove()
	arm.set_loc(src)
	src.visible_message(SPAN_ALERT(SPAN_BOLD("[victim] slips and gets [his_or_her(victim)] fingers caught in [src]'s whirling blades! SHIT!")), "You hear a horrible tearing sound.")
	playsound(src, 'sound/impact_sounds/Flesh_Tear_1.ogg', 50, 1)
	victim.emote("scream")
	random_brute_damage(victim, rand(20, 30))
	take_bleeding_damage(victim, victim, 15)
	src.shred(arm)

/obj/machinery/shredder/onDestroy()
	if (src.powered())
		elecflash(src, power = 2)
	playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 50, 1)
	. = ..()

/obj/machinery/shredder/proc/shred(obj/item/item)
	set waitfor = FALSE

	src.shredding = TRUE
	src.AddOverlays(image(src.icon, "grind"), "grind")

	src.proxy = new
	src.proxy.mouse_opacity = FALSE
	src.proxy.appearance = item.appearance
	src.proxy.transform = null
	//tech shamelessly stolen from the kitchen gibber
	var/icon/mask_icon = icon('icons/obj/kitchen_grinder_mask.dmi', "shredder-mask")

	//some things go in sideways
	if (istypes(item, src.rotated_types) || (istype(item, /obj/item/random_mail) && (item.icon_state == "mail-1" || item.icon_state == "mail-1")))
		//rotate the icon ONLY so the alpha mask filter doesn't get messed up
		var/icon/icon = getFlatIcon(item)
		icon.Turn(90)
		src.proxy.icon = icon

	src.proxy.pixel_x = 0
	src.proxy.pixel_y = 22

	src.proxy.add_filter("grinder_mask", 1, alpha_mask_filter(x=0, y=-14, icon=mask_icon))

	animate(src.proxy, pixel_y = -10, time = 70)
	animate(src.proxy.get_filter("grinder_mask"), y = 30, time = 105, flags=ANIMATION_PARALLEL)
	src.vis_contents += src.proxy
	//particles come out a bit late so they don't show up before it hits the shredder (hopefully)
	sleep(2 SECOND)
	playsound(src, 'sound/machines/shredder.ogg', 50, 0)
	global.particleMaster.SpawnSystem(new /datum/particleSystem/shredded(src, target = item))
	sleep (5 SECONDS)
	src.ClearSpecificOverlays("grind")
	src.add_shreddings()
	QDEL_NULL(src.proxy)
	QDEL_NULL(item)
	src.shredding = FALSE

#define LOWER_BOUND 6
#define SLOT_HEIGHT 5
#define SLOT_WIDTH 4

/obj/machinery/shredder/proc/add_shreddings()
	if (src.shreddings_count >= ceil(SLOT_HEIGHT/2))
		//delete the bottom row (squashed or something)
		src.shreddings_icon.DrawBox(null, 16 - floor(SLOT_WIDTH/2), LOWER_BOUND, 16 + ceil(SLOT_WIDTH/2), LOWER_BOUND + 1)
		//shunt everything down one
		src.shreddings_icon.Shift(SOUTH, 2)
		src.shreddings_count -= 1

	//draw the new top layer
	var/icon/icon = icon(src.proxy.icon)
	for (var/y_offset = 0 to 1)
		var/y_pos = LOWER_BOUND + src.shreddings_count * 2 + y_offset
		for (var/i in 1 to SLOT_WIDTH)
			var/x_pos = 16 - floor(SLOT_WIDTH/2) + i
			src.shreddings_icon.DrawBox(icon.RandomPixelColor(), x_pos, y_pos)

	src.icon = src.shreddings_icon
	src.shreddings_count += 1

#undef LOWER_BOUND
#undef SLOT_HEIGHT
#undef SLOT_WIDTH
