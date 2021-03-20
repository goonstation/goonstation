ABSTRACT_TYPE(/obj/critter/limbed_critter)
/obj/critter/limbed_critter
	var/datum/critter_limbs/limbs

	New()
		..()
		src.limbs = new /datum/critter_limbs(src)

	proc/update_dead_icon()
		if (src.alive)
			return
		. = initial(icon_state)
		if (!src.limbs.l_arm)
			. += "-l"
		if (!src.limbs.r_arm)
			. += "-r"
		. += "-dead"
		icon_state = .

	proc/critter_limb_removal(obj/item/W as obj, mob/living/user as mob)
		if (!src.alive)
			if (user.zone_sel.selecting in list("l_arm","r_arm"))
				var/obj/item/parts/surgery_limb = src.limbs.vars[user.zone_sel.selecting]
				if (isnull(surgery_limb))
					boutput(user, "<span class='alert'>[src] has no limb there!.</span>")
					return 1
				if (iscuttingtool(W))
					if (surgery_limb.remove_stage == 0)
						user.visible_message("<span class='alert'>[user] slices through the skin and flesh of [src]'s [surgery_limb.name] with [W].</span>", "<span class='alert'>You slice through the skin and flesh of [src]'s [surgery_limb.name] with [W].</span>")
						surgery_limb.remove_stage++
					else if (surgery_limb.remove_stage == 2)
						user.visible_message("<span class='alert'>[user] cuts through the remaining strips of skin holding [src]'s [surgery_limb.name] on with [W].</span>", "<span class='alert'>You cut through the remaining strips of skin holding [src]'s [surgery_limb.name] on with [W].</span>")
						surgery_limb.remove_stage++
						var/turf/location = get_turf(src)
						if (location)
							surgery_limb.set_loc(location)
							src.limbs.vars[user.zone_sel.selecting] = null // clearing the surgery_limb definition is not what we want
						src.update_dead_icon()
						return surgery_limb
					return 1

				else if (istool(W, TOOL_SAWING))
					if (surgery_limb.remove_stage == 1)
						user.visible_message("<span class='alert'>[user] saws through the bone of [src]'s [surgery_limb.name] with [W].</span>", "<span class='alert'>You saw through the bone of [src]'s [surgery_limb.name] with [W].</span>")
						surgery_limb.remove_stage++
					return 1

				else
					return 0
			else
				return 0
		else
			return 2 // used to handle custom take damage, replace if custom take damage proc made

	attackby(obj/item/W as obj, mob/living/user as mob)
		user.lastattacked = src
		var/limb_status = critter_limb_removal(W, user)
		if (!limb_status || limb_status == 2)
			..()
			return


/datum/critter_limbs
	var/obj/critter/limbed_critter/holder = null //incompatible with parts holder

	var/obj/item/parts/l_arm = null
	var/obj/item/parts/r_arm = null
	var/obj/item/parts/l_leg = null
	var/obj/item/parts/r_leg = null

