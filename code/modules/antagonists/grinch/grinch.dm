/datum/antagonist/grinch
	id = ROLE_GRINCH
	display_name = "grinch"
	antagonist_icon = "grinch"
	success_medal = "You're a mean one..."
	wiki_link = "https://wiki.ss13.co/Grinch"

	/// The ability holder of this grinch, containing their respective abilities.
	var/datum/abilityHolder/grinch/ability_holder

	is_compatible_with(datum/mind/mind)
		return isliving(mind.current)

	give_equipment()
		var/mob/living/carbon/human/H
		if (!ishuman(src.owner.current))
			return FALSE
		else
			H = src.owner.current

		var/mob/living/carbon/human/grinch = H
		global.grinches += 1
		grinch.grinchnumber = global.grinches

		var/obj/item/heart = H.organHolder.get_organ("heart")
		heart.transform = matrix(heart.transform, 3, MATRIX_SCALE)
		var/datum/abilityHolder/grinch/A = H.get_ability_holder(/datum/abilityHolder/grinch)
		if (!A)
			src.ability_holder = H.add_ability_holder(/datum/abilityHolder/grinch)
		else
			src.ability_holder = A

		H.equip_if_possible(new /obj/item/clothing/under/shirt_pants_b(H), SLOT_W_UNIFORM)

		src.ability_holder.addAbility(/datum/targetable/grinch/vandalism)
		src.ability_holder.addAbility(/datum/targetable/grinch/poison)
		src.ability_holder.addAbility(/datum/targetable/grinch/instakill)
		src.ability_holder.addAbility(/datum/targetable/grinch/grinch_cloak)
		src.ability_holder.addAbility(/datum/targetable/grinch/slap)
		src.ability_holder.addAbility(/datum/targetable/grinch/evil_grin)
		src.ability_holder.addAbility(/datum/targetable/grinch/grinch_transform)

	remove_equipment()
		src.ability_holder.removeAbility(/datum/targetable/grinch/vandalism)
		src.ability_holder.removeAbility(/datum/targetable/grinch/poison)
		src.ability_holder.removeAbility(/datum/targetable/grinch/instakill)
		src.ability_holder.removeAbility(/datum/targetable/grinch/grinch_cloak)
		src.ability_holder.removeAbility(/datum/targetable/grinch/slap)
		src.ability_holder.removeAbility(/datum/targetable/grinch/evil_grin)
		src.ability_holder.removeAbility(/datum/targetable/grinch/grinch_transform)
		src.owner.current.remove_ability_holder(/datum/abilityHolder/grinch)

	add_to_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_GRINCH)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())
		image_group.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_GRINCH)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)

	assign_objectives()
		new /datum/objective_set/grinch(src.owner, src)

	on_death()
		. = ..()
		var/obj/respawn = locate(/obj/grinch_respawn_point) in world
		var/mob/player = src.owner.current

		player.add_filter("death fx", 1, displacement_map_filter(icon=icon('icons/effects/distort.dmi', "canister_pop"), size=0, y=8))
		animate(player.get_filter("death fx"), size=50, time=2 SECONDS, easing=SINE_EASING)
		SPAWN(2 SECONDS)
			player.gib()
		SPAWN(4 SECONDS)
			var/mob/living/critter/small_animal/grinch_larvae/larvae = new /mob/living/critter/small_animal/grinch_larvae (get_turf(respawn))
			src.owner.current.mind.transfer_to(larvae)

/obj/fakeobject/grinchrock
	name = "rock"
	anchored = ANCHORED
	density = 1
	icon = 'icons/misc/lunar.dmi'
	icon_state = "moonrock"
	var/in_cave = FALSE

	New()
		. = ..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

	attack_hand(mob/user)
		if (isgrinchmind(user) && src.in_cave)
			var/list/rocks = list()
			for_by_tcl(G_rock, /obj/fakeobject/grinchrock)
				if (!G_rock.in_cave)
					rocks += G_rock
			if (rocks)
				src.send_grinch(user, pick(rocks))

	proc/send_grinch(var/mob/grinch, var/obj/rock)
		var/timer1 = rand(2, 5)
		APPLY_ATOM_PROPERTY(grinch, PROP_MOB_CANTMOVE, "stall")
		boutput(grinch, "You dig under the rock to the tunnels below!")
		animate(grinch, timer1 SECONDS, alpha = 0)
		SPAWN(timer1 SECONDS)
			grinch.set_loc(get_turf(rock))
			var/timer2 = rand(2, 5)
			animate(grinch, timer2 SECONDS, alpha = 255)
			rock.visible_message(SPAN_ALERT("<b>[grinch]</b> appears from under the earth!"))
			SPAWN(timer2 SECONDS)
				REMOVE_ATOM_PROPERTY(grinch, PROP_MOB_CANTMOVE, "stall")

/obj/item/mining_tools/pick/santa
	name = "Santa's Own Pickaxe"
	desc = "It's beautiful. By god, it even has festive lights."
	icon_state = "santa"
	item_state = "santa"

/turf/unsimulated/wall/auto/adventure/grinchwall
	name = "furred wall"
	desc = "This wall is covered in strange fur... It looks breakable, but not with any tools you know of."
	icon = 'icons/turf/walls/overgrown.dmi'
	icon_state = "root-0"
	mod = "root-"
	can_replace_with_stuff = TRUE
	var/hits = 0
	var/entrance = TRUE

	attack_hand(mob/user)
		if (isgrinchmind(user))
			APPLY_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE, "stall")
			user.visible_message("<b>[user]</b> vanishes through the dense Grinchian wall felt!")
			animate(user, 2 SECONDS, alpha = 0)
			SPAWN(2 SECONDS)
				if (entrance)
					user.set_loc(get_turf(locate(268, 93, 1)))
				else
					user.set_loc(get_turf(locate(265, 93, 1)))
				animate(user, 2 SECONDS, alpha = 255)
				user.visible_message("<b>[user]</b> appears from under the earth!")
				SPAWN(2 SECONDS)
					REMOVE_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE, "stall")

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/mining_tools/pick/santa))
			playsound(user, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
			shake_camera(user, 4, 8, 0.5)
			src.hits += 1
			if (src.hits >= 3)
				src.ReplaceWith(global.map_settings.space_turf_replacement)

/obj/grinch_respawn_point
	name = "grinch respawn"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "strange-g"

/mob/living/critter/small_animal/grinch_larvae
	name = "grinch larvae"
	icon = 'icons/misc/critter.dmi'
	icon_state = "grinch_larvae"
	nodamage = TRUE

	New()
		..()
		src.setStatus("grinch_respawn", 30 SECONDS)

/mob/living/critter/brullbar/max
	name = "Max"
	real_name = "Max"
	desc = "He has served Grinchkind since the original's death. So loyal. So powerful."
	icon = 'icons/misc/critter.dmi'
	icon_state = "illegal"
	icon_state_dead = "illegal-lying"
	add_abilities = list(/datum/targetable/critter/tackle, /datum/targetable/critter/frenzy)

/datum/objective_set/grinch


