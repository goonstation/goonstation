ABSTRACT_TYPE(/obj/item/parts/robot_parts)
/obj/item/parts/robot_parts
	name = "robot parts"
	icon = 'icons/obj/robot_parts.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "buildpipe"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	streak_decal = /obj/decal/cleanable/oil
	streak_descriptor = "oily"
	var/appearanceString = "generic"
	var/icon_state_base = ""
	accepts_normal_human_overlays = FALSE
	skintoned = FALSE
	/// Robot limbs shouldn't get replaced through mutant race changes
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_ROBOT)
	fingertip_color = "#4e5263"

	decomp_affected = FALSE
	var/robot_movement_modifier

	var/max_health = 100
	var/dmg_blunt = 0
	var/dmg_burns = 0
	/// Currently vestigal variable previously used for speed, being left for potiental future application
	var/weight = 0
	/// does this part consume any extra power
	var/powerdrain = 0

	default_material = "steel"
	mat_changeappearance = FALSE

	force = 6
	stamina_damage = 40
	stamina_cost = 23
	stamina_crit_chance = 5
	breaks_cuffs = TRUE

	New()
		..()
		icon_state = "[src.icon_state_base]-[appearanceString]"

	examine()
		. = ..()
		switch(ropart_get_damage_percentage(1))
			if(15 to 29)
				. += SPAN_ALERT("It looks a bit dented and worse for wear.")
			if(29 to 59)
				. += SPAN_ALERT("It looks somewhat bashed up.")
			if(60 to INFINITY)
				. += SPAN_ALERT("It looks badly mangled.")

		switch(ropart_get_damage_percentage(2))
			if(15 to 29)
				. += SPAN_ALERT("It has some light scorch marks.")
			if(29 to 59)
				. += SPAN_ALERT("Parts of it are kind of melted.")
			if(60 to INFINITY)
				. += SPAN_ALERT("It looks terribly burnt up.")

	getMobIcon(var/decomp_stage = DECOMP_STAGE_NO_ROT, icon/mutantrace_override, force = FALSE)
		if (force)
			qdel(src.bodyImage)
			src.bodyImage = null
		if (src.bodyImage)
			return src.bodyImage

		src.bodyImage = image(mutantrace_override || src.partIcon, icon_state = "[src.icon_state_base]-[appearanceString]")
		return bodyImage

	attackby(obj/item/W, mob/user)
		if(isweldingtool(W))
			if(!W:try_weld(user, 1))
				return
			if (src.ropart_get_damage_percentage(1) > 0)
				src.ropart_mend_damage(20,0)
				src.add_fingerprint(user)
				user.visible_message("<b>[user.name]</b> repairs some of the damage to [src.name].")
			else
				boutput(user, SPAN_ALERT("It has no structural damage to weld out."))
				return
		else if(istype(W, /obj/item/cable_coil))
			var/obj/item/cable_coil/coil = W
			if (src.ropart_get_damage_percentage(1) > 0)
				src.ropart_mend_damage(0,20)
				coil.use(1)
				src.add_fingerprint(user)
				user.visible_message("<b>[user.name]</b> repairs some of the damage to [src.name]'s wiring.")
			else
				boutput(user, SPAN_ALERT("There's no burn damage on [src.name]'s wiring to mend."))
				return
		else ..()

	surgery(var/obj/item/tool)
		var/mob/orig_holder = holder

		var/wrong_tool = 0

		if(remove_stage > 0 && (istype(tool,/obj/item/staple_gun) || istype(tool,/obj/item/suture)) )
			remove_stage = 0

		else if(remove_stage == 0 || remove_stage == 2)
			if(iscuttingtool(tool))
				remove_stage++
			else
				wrong_tool = 1

		else if(remove_stage == 1)
			if(istype(tool, /obj/item/circular_saw) || istype(tool, /obj/item/saw))
				remove_stage++
			else
				wrong_tool = 1

		if (!wrong_tool && src) //ZeWaka: Fix for null.name
			switch(remove_stage)
				if(0)
					tool.the_mob.visible_message(SPAN_ALERT("[tool.the_mob] secures [holder.name]'s [src.name] to [his_or_her(holder)] stump with [tool]."), SPAN_ALERT("You secure [holder.name]'s [src.name] to [his_or_her(holder)] stump with [tool]."))
					logTheThing(LOG_COMBAT, tool.the_mob, "secures [constructTarget(holder,"combat")]'s [src.name] back on.")
				if(1)
					tool.the_mob.visible_message(SPAN_ALERT("[tool.the_mob] slices through the attachment mesh of [holder.name]'s [src.name] with [tool]."), SPAN_ALERT("You slice through the attachment mesh of [holder.name]'s [src.name] with [tool]."))
				if(2)
					tool.the_mob.visible_message(SPAN_ALERT("[tool.the_mob] saws through the base mount of [holder.name]'s [src.name] with [tool]."), SPAN_ALERT("You saw through the base mount of [holder.name]'s [src.name] with [tool]."))

					SPAWN(rand(150,200))
						if(remove_stage == 2)
							src.remove(0)
				if(3)
					tool.the_mob.visible_message(SPAN_ALERT("[tool.the_mob] cuts through the remaining strips of material holding [holder.name]'s [src.name] on with [tool]."), SPAN_ALERT("You cut through the remaining strips of material holding [holder.name]'s [src.name] on with [tool]."))
					logTheThing(LOG_COMBAT, tool.the_mob, "removes [constructTarget(holder,"combat")]'s [src.name].")
					src.remove(0)

			if(orig_holder)
				if(!isdead(orig_holder))
					if(prob(40))
						orig_holder.emote("scream")
				orig_holder.TakeDamage("chest",20,0)
				take_bleeding_damage(orig_holder, null, 15, DAMAGE_CUT)

	proc/ropart_take_damage(var/bluntdmg = 0,var/burnsdmg = 0)
		src.dmg_blunt += bluntdmg
		src.dmg_burns += burnsdmg
		if (src.dmg_blunt + src.dmg_burns >= src.max_health)
			if(src.holder) return 1 // need to do special stuff in this case, so we let the borg's melee hit take care of it
			else
				src.visible_message("<b>[src]</b> breaks!")
				playsound(src, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 40, TRUE)
				if (istype(src.loc,/turf/)) make_cleanable( /obj/decal/cleanable/robot_debris/limb,src.loc)
				del(src)
				return 0
		return 0

	/// For special explosion behaviour, explosive damage is handled in ropart_take_damage
	proc/ropart_ex_act(severity, lasttouched, power)
		return

	proc/ropart_mend_damage(var/bluntdmg = 0,var/burnsdmg = 0)
		src.dmg_blunt -= bluntdmg
		src.dmg_burns -= burnsdmg
		if (src.dmg_blunt < 0) src.dmg_blunt = 0
		if (src.dmg_burns < 0) src.dmg_burns = 0
		return 0

	proc/ropart_get_damage_percentage(var/which = 0)
		switch(which)
			if(1)
				if (src.dmg_blunt) return (src.dmg_blunt / src.max_health) * 100
				else return 0 // wouldn't want to divide by zero, even if my maths suck
			if(2)
				if (src.dmg_burns) return (src.dmg_burns / src.max_health) * 100
				else return 0
			else
				if (src.dmg_blunt || src.dmg_burns) return ((src.dmg_blunt + src.dmg_burns) / src.max_health) * 100
				else return 0

	proc/reinforce(var/obj/item/sheet/M, var/mob/user, var/obj/item/parts/robot_parts/result, var/need_reinforced)
		if (!src.can_reinforce(M, user, need_reinforced))
			return

		var/obj/item/parts/robot_parts/newitem = new result(get_turf(src))
		newitem.setMaterial(src.material)
		boutput(user, SPAN_NOTICE("You reinforce [src.name] with the metal."))
		M.change_stack_amount(-2)
		if (M.amount < 1)
			user.drop_item()
			qdel(M)
		SEND_SIGNAL(src, COMSIG_ITEM_CONVERTED, newitem, user)
		qdel(src)

	proc/can_reinforce(var/obj/item/sheet/M, var/mob/user, var/need_reinforced)
		if (need_reinforced && !M.reinforcement)
			boutput(user, SPAN_ALERT("You'll need reinforced sheets to reinforce this component."))
			return FALSE
		if (M.amount < 2)
			boutput(user, SPAN_ALERT("You need at least two metal sheets to reinforce this component."))
			return FALSE
		if (!src.material.isSameMaterial(M.material))
			boutput(user, SPAN_ALERT("You need the same material as the component to reinforce."))
			return FALSE
		return TRUE
