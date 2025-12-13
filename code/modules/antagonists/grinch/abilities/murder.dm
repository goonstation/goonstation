/datum/targetable/grinch/instakill
	name = "Entrapment"
	desc = "Crushes the victim alive into a gift box."
	icon_state = "grinchmurder"
	targeted = 1
	target_anything = 0
	target_nodamage_check = 1
	max_range = 1
	cooldown = 4800
	start_on_cooldown = 0
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 1
	var/active = FALSE

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		if (src.active)
			return 1
		if (!M || !target || !ismob(target))
			return 1
		if (M == target)
			boutput(M, SPAN_ALERT("Why would you want to kill yourself?"))
			return 1
		if (GET_DIST(M, target) > src.max_range)
			boutput(M, SPAN_ALERT("[target] is too far away."))
			return 1
		if (!iscarbon(target))
			boutput(M, SPAN_ALERT("[target] is immune to the disease."))
			return 1
		. = ..()
		src.active = TRUE
		var/mob/living/T = target

		if (isalive(holder.owner) && !holder.owner.transforming)
			if (ishuman(T))
				if (T.lying)
					T.lying = 0
					T.remove_stuns()
					T.set_clothing_icon_dirty()
				T.transforming = 1
				holder.owner.transforming = 1
				holder.owner.set_dir(get_dir(holder.owner, T))
				T.set_dir(get_dir(T, holder.owner))
				holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] menacingly grabs [T] by the chest!</B>"))
				var/dir_offset = get_dir(holder.owner, T)
				switch(dir_offset)
					if (NORTH)
						T.pixel_y = -24
						T.layer = holder.owner.layer - 1
					if (SOUTH)
						T.pixel_y = 24
						T.layer = holder.owner.layer + 1
					if (EAST)
						T.pixel_x = -24
						T.layer = holder.owner.layer - 1
					if (WEST)
						T.pixel_x = 24
						T.layer = holder.owner.layer - 1
				for (var/i = 0, i < 5, i++)
					T.pixel_y += 2
					sleep(0.3 SECONDS)

				sleep(0.5 SECONDS)
				var/mob/living/carbon/human/HU = T
				holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] begins snapping [HU]'s body!</B>"))
				var/number_of_snaps = 5
				var/i
				for(i = 0; i < number_of_snaps; i++)
					playsound(HU.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 75, 1)
					HU.emote("scream")
					take_bleeding_damage(HU, holder.owner, 2, DAMAGE_STAB)
					HU.Scale(1 + (rand(-30, 20) * 0.01), 1 + (rand(-20, 30) * 0.01))
					HU.Turn(rand(-60, 90))
					HU.bioHolder.age += 10
					sleep(1 SECOND)

				playsound(holder.owner.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 100, 1)
				var/obj/item/gift/victimbox = new /obj/item/gift(HU.loc)
				HU.visible_message(SPAN_ALERT("<B>[holder.owner]</B> rudely shoves [HU] inside a Spacemas present!"))
				var/obj/item/card/id/id = get_id_card(HU.wear_id)
				if (id)
					victimbox.name = "Wrapped [id.assignment]"
				else
					victimbox.name = "Wrapped Employee"
				victimbox.desc = "There's muffled yelling coming from inside..."
				var/list/organs = list("left_eye", "right_eye", "liver", "appendix", "left_kidney", "right_kidney", "butt", "stomach")
				var/obj/item/organ/O = pick(organs)
				var/obj/item/org = HU.organHolder.drop_organ(O, victimbox)
				victimbox.gift = org
				victimbox.contents += org
				HU.set_loc(victimbox)
				victimbox.trapped_player = HU
				victimbox.contents += HU
				HU.transform = null
				holder.owner.transforming = 0
		src.active = FALSE

