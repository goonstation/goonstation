/obj/item/device/light/sparkler
	name = "sparkler"
	desc = "Be careful not to start a fire!"
	icon = 'icons/obj/items/sparklers.dmi'
	icon_state = "sparkler-off"
	icon_on = "sparkler-on"
	icon_off = "sparkler-off"
	inhand_image_icon = 'icons/obj/items/sparklers.dmi'
	item_state = "sparkler-off"
	var/item_on = "sparkler-on"
	var/item_off = "sparkler-off"
	w_class = W_CLASS_TINY
	density = 0
	anchored = UNANCHORED
	opacity = 0
	col_r = 0.7
	col_g = 0.3
	col_b = 0.3
	var/sparks = 7
	var/burnt = 0


	New()
		..()

	attack_self(mob/user as mob)
		if (src.on)
			var/fluff = pick("snuff", "blow")
			user.visible_message("<b>[user]</b> [fluff]s out [src].",\
			"You [fluff] out [src].")
			src.put_out(user)

	attackby(obj/item/W, mob/user)
		if (!src.on && sparks)
			if (isweldingtool(W) && W:try_weld(user,0,-1,0,0))
				src.light(user, SPAN_ALERT("<b>[user]</b> casually lights [src] with [W], what a badass."))

			else if (istype(W, /obj/item/clothing/head/cakehat) && W:on)
				src.light(user, SPAN_ALERT("Did [user] just light [his_or_her(user)] [src] with [W]? Holy Shit."))

			else if (istype(W, /obj/item/device/igniter))
				src.light(user, SPAN_ALERT("<b>[user]</b> fumbles around with [W]; sparks erupt from [src]."))

			else if (istype(W, /obj/item/device/light/zippo) && W:on)
				src.light(user, SPAN_ALERT("With a single flick of their wrist, [user] smoothly lights [src] with [W]. Damn they're cool."))

			else if ((istype(W, /obj/item/match) || istype(W, /obj/item/device/light/candle)) && W:on)
				src.light(user, SPAN_ALERT("<b>[user] lights [src] with [W]."))

			else if (W.burning)
				src.light(user, SPAN_ALERT("<b>[user]</b> lights [src] with [W]. Goddamn."))
		else
			return ..()

	temperature_expose(datum/gas_mixture/air, temperature, volume)
		if((temperature > T0C+400))
			src.light()
		..()

	process()
		if (src.on)
			var/turf/location = src.loc
			if (ismob(location))
				var/mob/M = location
				if (M.find_in_hand(src))
					location = M.loc
			var/turf/T = get_turf(src.loc)
			if (T)
				T.hotspot_expose(700,5)

			if(prob(66))
				src.gen_sparks()

	proc/gen_sparks()
		src.sparks--
		elecflash(src)
		if(!sparks)
			src.put_out()
			src.burnt = 1
			src.name = "burnt-out sparkler"
			src.icon_state = "sparkler-burnt"
			src.item_state = "sparkler-burnt"
			var/mob/M = src.loc
			if(istype(M))
				M.update_inhands()
		return

	proc/light(var/mob/user as mob, var/message as text)
		if (!src) return
		if (burnt) return
		if (!src.on)
			logTheThing(LOG_STATION, user, "lights the [src] at [log_loc(src)].")
			src.on = 1
			src.hit_type = DAMAGE_BURN
			src.force = 3
			src.icon_state = src.icon_on
			src.item_state = src.item_on
			light.enable()
			processing_items |= src
			if(user)
				user.update_inhands()
		return

	proc/put_out(var/mob/user as mob)
		if (!src) return
		if (src.on)
			src.on = 0
			src.hit_type = DAMAGE_BLUNT
			src.force = 0
			src.icon_state = src.icon_off
			src.item_state = src.item_off
			light.disable()
			processing_items -= src
			if(user)
				user.update_inhands()
		return

/obj/item/storage/sparkler_box
	name = "sparkler box"
	desc = "Have fun!"
	icon = 'icons/obj/items/sparklers.dmi'
	icon_state = "sparkler_box-close"
	max_wclass = W_CLASS_TINY
	slots = 5
	spawn_contents = list(/obj/item/device/light/sparkler,/obj/item/device/light/sparkler,/obj/item/device/light/sparkler,/obj/item/device/light/sparkler,/obj/item/device/light/sparkler)
	var/open = 0

	attack_hand(mob/user)
		if (src.loc == user && (opens_if_worn || src == user.l_hand || src == user.r_hand))
			if(src.open)
				..()
			else
				src.open = 1
				src.icon_state = "sparkler_box-open"
				playsound(src.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 20, 1, -2)
				boutput(user, SPAN_NOTICE("You snap open the child-protective safety tape on [src]."))
		else
			..()

	attack_self(mob/user as mob)
		if(src.open)
			..()
		else
			src.open = 1
			src.icon_state = "sparkler_box-open"
			playsound(src.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 20, 1, -2)
			boutput(user, SPAN_NOTICE("You snap open the child-protective safety tape on [src]."))

	mouse_drop(atom/over_object, src_location, over_location)
		if(!src.open)
			if (over_object == usr && in_interact_range(src, usr) && isliving(usr) && !usr.stat)
				return
			if (usr.is_in_hands(src))
				return
		..()

#define ROMAN_CANDLE_UNLIT 0
#define ROMAN_CANDLE_LIT 1
#define ROMAN_CANDLE_BURNT 2

/obj/item/roman_candle
	name = "roman candle"
	desc = "Contains 10 exploding stars. Only use outdoors. Only point towards sky. All liability is waived."
	icon = 'icons/obj/items/sparklers.dmi'
	icon_state = "sparkler-off"
	inhand_image_icon = 'icons/obj/items/sparklers.dmi'
	item_state = "sparkler-off"
	w_class = W_CLASS_SMALL
	var/state = ROMAN_CANDLE_UNLIT
	var/charges = 10

	New()
		. = ..()
		src.charges = rand(8,10) // cheap ass fireworks

	attack_self(mob/user)
		. = ..()
		if (src.state == ROMAN_CANDLE_UNLIT)
			src.state = ROMAN_CANDLE_LIT
			processing_items |= src
			icon_state = "sparkler-on"
			item_state = "sparkler-on"
			var/mob/M = src.loc
			if(istype(M))
				M.update_inhands()

	process()
		if (src.state == ROMAN_CANDLE_LIT)
			var/turf/location = src.loc
			var/direction = pick(alldirs)
			if (ismob(location))
				var/mob/M = location
				if (M.find_in_hand(src))
					location = M.loc
					direction = M.dir

			var/turf/T = get_turf(src.loc)

			if (T)
				T.hotspot_expose(700,5)

			if (prob(66))
				src.shoot_firework(T, direction)

	proc/shoot_firework(turf/T, direction)
		var/datum/projectile/special/firework/firework = new
		shoot_projectile_ST_pixel_spread(src.loc, firework, get_step(src.loc, direction))
		playsound(src.loc, 'sound/effects/firework.ogg', 50, 1) // TODO: Cut sound into pheeeoooo and pop
		src.charges--
		if (src.charges <= 0)
			src.state = ROMAN_CANDLE_BURNT
			processing_items -= src
			icon_state = "sparkler-burnt"
			item_state = "sparkler-burnt"
			var/mob/M = src.loc
			if(istype(M))
				M.update_inhands()

#undef ROMAN_CANDLE_UNLIT
#undef ROMAN_CANDLE_LIT
#undef ROMAN_CANDLE_BURNT
