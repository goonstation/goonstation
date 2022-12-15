/obj/item/clothing/suit/armor/football
	name = "space-american football pads"
	desc = "A protective suit designed for players of the ancient sport of space-american football. This armor bears colors of the Spacecow Wobbegongs, who won the 2048 series!"
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "fb_blue"
	//same values as captain armor
	var/in_rush = 0
	item_function_flags = IMMUNE_TO_ACID
	setupProperties()
		..()
		setProperty("meleeprot", 8)
		setProperty("rangedprot", 1.5)

	red
		desc = "A protective suit designed for players of the ancient sport of space-american football. This armor bears colors of the Spacissippi Timberdoodles, who were defeated by the Wobbegongs in the 2048 finals. Many consider this victory to be a fluke."
		icon_state = "fb_red"

/obj/item/clothing/head/helmet/football
	name = "space-american football helmet"
	desc = "Gotta protect your head! This helmet will certainly do the job. It has a Spacecow Wobbegongs logo printed on it!"
	icon_state = "fb_blue"
	c_flags = COVERSEYES | COVERSMOUTH
	item_function_flags = IMMUNE_TO_ACID
	setupProperties()
		..()
		setProperty("meleeprot_head", 6)

	red
		desc = "Gotta protect your head! This helmet will certainly do the job. It has a Spacissippi Timberdoodles logo printed on it!"
		icon_state = "fb_red"

/obj/item/clothing/under/football
	name = "athletic pants"
	desc = "These are athletic pants bearing the colors of the Spacecow Wobbegongs. The fabric feels like victory."
	icon = 'icons/obj/clothing/uniforms/item_js_athletic.dmi'
	wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_athletic.dmi'
	icon_state = "fb_blue"
	item_function_flags = IMMUNE_TO_ACID

	red
		desc = "These are athletic pants bearing the colors of the Spacissippi Timberdoodles. The fabric smells like rivalry."
		icon_state = "fb_red"

/obj/item/clothing/shoes/cleats
	name = "cleats"
	desc = "Sharp cleats made for playing football at a professional level. The cleats provide excellent grip. They must be expensive!"
	icon_state = "cleats"
	item_state = "bl_shoes"
	c_flags = NOSLIP
	kick_bonus = 6
	step_sound = "step_plating"
	compatible_species = list("cow", "human")
	step_priority = STEP_PRIORITY_LOW
	item_function_flags = IMMUNE_TO_ACID

/obj/item/clothing/suit/armor/football/equipped(var/mob/user, var/slot)
	..()
	in_rush = 0

/obj/item/clothing/suit/armor/football/abilities = list(/obj/ability_button/football_charge)

/mob/living/carbon/human/proc/wearing_football_gear()
	return ( (src.wear_suit && istype(src.wear_suit,/obj/item/clothing/suit/armor/football)) \
			&& (src.shoes && istype(src.shoes,/obj/item/clothing/shoes/cleats) || istype(mutantrace, /datum/mutantrace/cow)) \
			&& (src.w_uniform && istype(src.w_uniform,/obj/item/clothing/under/football)) )


/mob/living/carbon/human/proc/rush()
	if (!wearing_football_gear())
		boutput(src, "<span class='alert'>You need to wear more football gear first! It just wouldn't be safe.</span>")
		return

	var/obj/item/clothing/suit/armor/football/S = src.wear_suit
	if (S.in_rush) return
	S.in_rush = 1
	playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 0.4, 0 , 2)

	var/charge_dir = src.dir
	var/turf/T = get_turf(src)
	for(var/i=1, i<20, i++)
		if (!S.in_rush)
			break
		S.in_rush = i
		T = get_step(T, charge_dir)
		src.Move(T)
		sleep(0.1 SECONDS)

	S.in_rush = 0

//this is balanced in favor of brute damage and stamina damage. Stun is very small.
//Crossing a large distance before hitting the target will increase the damage a lot.
/mob/living/carbon/human/proc/tackle(var/atom/target)
	var/obj/item/clothing/suit/armor/football/S = src.wear_suit
	if (!istype(S) || !S.in_rush)	return
	var/power = 20 + (S.in_rush * 2.5) //Power can range from 20 - 70
	S.in_rush = 0

	if(check_target_immunity(target))
		boutput(src, "<span class='alert'>[target] braces themselves to stop your tackle effortlessly!</span>")
		return

	if (src.hasStatus("handcuffed"))
		boutput(src, "<span class='alert'>With your hands tied behind your back, you slam into [target] face first!</span>")
		src.changeStatus("weakened", 3 SECONDS)
		src.force_laydown_standup()

	src.remove_stamina(40)

	if (!src.head || !istype(src.head,/obj/item/clothing/head/helmet/football))
		boutput(src, "<span class='alert'>Ouch! Feels like a properly designed helmet would come in handy.</span>")
		src.take_brain_damage(1 + power * 0.1)

	for (var/mob/C in viewers(src))
		shake_camera(C, 6, 16)
	if (ismob(target))
		var/mob/M = target
		var/msg = pick("tackles", "rushes into", "sacks", "steamrolls", "plows into", "bashes", "leaps into", "runs into", "bowls over")
		M.visible_message("<span class='alert'><B>[src] [msg] [target]!</B></span>")

		M.changeStatus("stunned", 2 SECONDS)
		M.changeStatus("weakened", 2 SECONDS)
		M.force_laydown_standup()
		power = max(9, power)
		M.TakeDamageAccountArmor("chest", power, 0, 0, DAMAGE_BLUNT)
		M.remove_stamina(80 + power) //lotsa stamina damage whoa!!

		var/turf/throw_at = get_edge_target_turf(src, src.dir)
		M.throw_at(throw_at, 10, 2)
		playsound(src.loc, "swing_hit", 40, 1)
		logTheThing(LOG_STATION, src, "tackles [target] using football gear [log_loc(src)].")
	else if(isturf(target))
		if(istype(target, /turf/simulated/wall/r_wall || istype(target, /turf/simulated/wall/auto/reinforced)) && prob(power / 2))
			return
		if(istype(target, /turf/simulated/wall) && prob(power))
			var/turf/simulated/wall/T = target
			T.dismantle_wall(1)
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
		logTheThing(LOG_COMBAT, src, "tackles [target] using football gear [log_loc(src)].")
	else if (isobj(target))
		var/obj/O = target
		var/adjective = pick("hard", "strong", "powerful", "rough", "driven", "beefy", "big", "tough")
		src.visible_message("<span class='alert'><B>[src] smashes into [target] with a [adjective] shoulder!</B></span>")
		logTheThing(LOG_COMBAT, src, "tackles [target] using football gear [log_loc(src)].")
		switch (src.smash_through(O, list("window", "grille", "table"), 0))
			if (0)
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
				if (istype(O, /obj/machinery/door) && O.density)
					var/obj/machinery/door/D = O
					SPAWN(0)
						D.try_force_open(src)
					return
				if (istype(O, /obj/structure/girder) || istype(O, /obj/foamedmetal))
					qdel(O)
					return
				if (istype(O,/obj/machinery/vending))
					var/obj/machinery/vending/V = O
					V.fall(src)
					return
				if (istype(O,/obj/machinery/portable_atmospherics/canister))
					var/obj/machinery/portable_atmospherics/canister/C = O
					C.health -= power
					C.healthcheck()
			if (1)
				return
	return

// MADDEN NFL FOOTBALL 2051

/obj/item/football
	name = "football"
	desc = "A pigskin. An oblate leather spheroid. For tossing around."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "football"
	uses_multiple_icon_states = 1
	item_state = "football"
	w_class = W_CLASS_NORMAL
	force = 0
	throw_range = 10
	throwforce = 0
	throw_spin = 0


/obj/item/football/the_big_one
	name = "\improper SAFL football"
	desc = "The official football of the Space American Football League. There's some insignia on it for Space Bowl LXXXVII."
	custom_suicide = 0
	c_flags = EQUIPPED_WHILE_HELD
	throw_range = 15
	throwforce = 10
	w_class = W_CLASS_HUGE
	// look it is VERY IMPORTANT
	plane = PLANE_HUD - 1
	var/obj/maptext_junk/indicator
	var/mob/carrier = 0
	var/mob/tosser = 0
	New()
		..()
		indicator = new(src)
		indicator.maptext_y = 38
		indicator.maptext_height = 64
		setProperty("movespeed", 1)
		add_filter("outline", 1, outline_filter(size=0.5, color=rgb(255,255,255)))

	pickup(mob/M)
		..()
		if (indicator && src.carrier)
			src.carrier.vis_contents -= indicator
		if (indicator && M.mind && M.mind.special_role)
			var/col1 = ""
			var/col2 = ""
			var/col3 = ""
			if (M.mind.special_role == "red")
				col1 = "color: #800; -dm-text-outline: 2px #f88;"
				col2 = "color: #f88; -dm-text-outline: 2px #800;"
				col3 = "1"
			if (M.mind.special_role == "blue")
				col1 = "color: #008; -dm-text-outline: 2px #88f;"
				col2 = "color: #88f; -dm-text-outline: 2px #008;"
				col3 = "2"

			var/blink1 = "<span class='c vb ps2p' style='[col1]'><span class='vga' style='font-size: 24px'>[col3]</span>\n↓</span>"
			var/blink2 = "<span class='c vb ps2p' style='[col2]'><span class='vga' style='font-size: 24px'>[col3]</span>\n↓</span>"
			indicator.maptext = blink1
			animate(indicator, maptext = blink1, time = 3, loop = -1)
			animate(maptext = blink2, time = 3, loop = -1)
			M.vis_contents += indicator
			src.carrier = M

	dropped(mob/M)
		..()
		if (indicator)
			indicator.maptext = ""
			animate(indicator, maptext = "")
			if (src.carrier)
				src.carrier.vis_contents -= indicator

	disposing()
		SHOULD_CALL_PARENT(FALSE)
		return // CRASH("YOU CAN'T DELETE THE FOOTBALL! YOU WILL REGRET THIS!")

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		if (hit_atom)
			if(ismob(hit_atom) && ishuman(hit_atom))
				var/mob/living/carbon/human/H = hit_atom
				var/mob/living/carbon/human/user = usr
				if (H.mind && user.mind && H.mind.special_role == user.mind.special_role)
					playsound(src.loc, 'sound/items/bball_bounce.ogg', 65, 1)
					src.Attackhand(H)
					H.visible_message("<span class='combat'>[user] passes \the [src] to [H]!</span>", "<span class='combat'>You pass \the [src] to [H]!</span>")
					return

		..()

	ex_act(severity)
		return

/obj/item/football/throw_at(atom/target, range, speed, list/params, turf/thrown_from, mob/thrown_by, throw_type = 1,
			allow_anchored = 0, bonus_throwforce = 0, end_throw_callback = null)
	src.icon_state = "football_air"
	. = ..()

/obj/item/football/throw_impact(atom/hit_atom, datum/thrown_thing/thr)
	. = ..(hit_atom)
	src.icon_state = "football"
	if(hit_atom)
		playsound(src.loc, 'sound/items/bball_bounce.ogg', 65, 1)
		if (ismob(hit_atom))
			var/mob/hitMob = hit_atom
			if (ishuman(hitMob))
				var/mob/living/carbon/human/user = usr
				SPAWN( 0 )
					if (istype(user))
						if (check_target_immunity(hitMob))
							hitMob.visible_message("<span class='alert'>The [src] bounces off of [hit_atom]!</span>")
						else if (user.wearing_football_gear())
							//boutput(hitMob, "<span class='alert'>Oof! The [src.name] knocks the wind right out of you!</span>")
							hitMob.visible_message("<span class='alert'><b>[src] hits [hit_atom] in the gut and knocks the wind right out of them!</b></span>")
							hitMob.changeStatus("stunned", 2 SECONDS)
							hitMob.changeStatus("weakened", 2 SECONDS)
							hitMob.remove_stamina(30)
							hitMob.force_laydown_standup()

	return

/obj/item/football/custom_suicide = 1
/obj/item/football/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	if (ishuman(user))
		if (user:wearing_football_gear())
			user.visible_message("<span class='alert'><b>[user] spikes [src] into the ground! TOUCHDOWN!!!</b></span>")
			user.TakeDamage("head", 150, 0)
			playsound(src.loc, 'sound/items/bball_bounce.ogg', 50, 1)
			var/turf/T = get_turf(src.loc)
			if(T)
				explosion_new(src, T, 32)
			return 1

	user.visible_message("<span class='alert'><b>[user] spikes [src]. It bounces back up and hits [him_or_her(user)] square in the forehead!</b></span>")
	user.TakeDamage("head", 150, 0)
	playsound(src.loc, 'sound/items/bball_bounce.ogg', 50, 1)
	return 1
