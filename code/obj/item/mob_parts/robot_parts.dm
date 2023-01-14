ABSTRACT_TYPE(/obj/item/parts/robot_parts)
/obj/item/parts/robot_parts
	name = "robot parts"
	icon = 'icons/obj/robot_parts.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "buildpipe"
	flags = FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT
	streak_decal = /obj/decal/cleanable/oil
	streak_descriptor = "oily"
	var/appearanceString = "generic"
	var/icon_state_base = ""
	accepts_normal_human_overlays = 0
	skintoned = 0
	/// Robot limbs shouldn't get replaced through mutant race changes
	limb_is_unnatural = TRUE
	kind_of_limb = (LIMB_ROBOT)

	decomp_affected = 0
	var/robot_movement_modifier

	var/max_health = 100
	var/dmg_blunt = 0
	var/dmg_burns = 0
	var/weight = 0     // for calculating speed modifiers
	var/powerdrain = 0 // does this part consume any extra power

	force = 6
	stamina_damage = 40
	stamina_cost = 23
	stamina_crit_chance = 5

	New()
		..()
		icon_state = "[src.icon_state_base]-[appearanceString]"


	examine()
		. = ..()
		switch(ropart_get_damage_percentage(1))
			if(15 to 29)
				. += "<span class='alert'>It looks a bit dented and worse for wear.</span>"
			if(29 to 59)
				. += "<span class='alert'>It looks somewhat bashed up.</span>"
			if(60 to INFINITY)
				. += "<span class='alert'>It looks badly mangled.</span>"

		switch(ropart_get_damage_percentage(2))
			if(15 to 29)
				. += "<span class='alert'>It has some light scorch marks.</span>"
			if(29 to 59)
				. += "<span class='alert'>Parts of it are kind of melted.</span>"
			if(60 to INFINITY)
				. += "<span class='alert'>It looks terribly burnt up.</span>"

	getMobIcon(var/lying)
		if (src.standImage)
			return src.standImage

		src.standImage = image('icons/mob/human.dmi', "[src.icon_state_base]-[appearanceString]")
		return standImage

	attackby(obj/item/W, mob/user)
		if(isweldingtool(W))
			if(!W:try_weld(user, 1))
				return
			if (src.ropart_get_damage_percentage(1) > 0)
				src.ropart_mend_damage(20,0)
				src.add_fingerprint(user)
				user.visible_message("<b>[user.name]</b> repairs some of the damage to [src.name].")
			else
				boutput(user, "<span class='alert'>It has no structural damage to weld out.</span>")
				return
		else if(istype(W, /obj/item/cable_coil))
			var/obj/item/cable_coil/coil = W
			if (src.ropart_get_damage_percentage(1) > 0)
				src.ropart_mend_damage(0,20)
				coil.use(1)
				src.add_fingerprint(user)
				user.visible_message("<b>[user.name]</b> repairs some of the damage to [src.name]'s wiring.")
			else
				boutput(user, "<span class='alert'>There's no burn damage on [src.name]'s wiring to mend.</span>")
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
					tool.the_mob.visible_message("<span class='alert'>[tool.the_mob] staples [holder.name]'s [src.name] securely to their stump with [tool].</span>", "<span class='alert'>You staple [holder.name]'s [src.name] securely to their stump with [tool].</span>")
					logTheThing(LOG_COMBAT, tool.the_mob, "staples [constructTarget(holder,"combat")]'s [src.name] back on.")
				if(1)
					tool.the_mob.visible_message("<span class='alert'>[tool.the_mob] slices through the attachment mesh of [holder.name]'s [src.name] with [tool].</span>", "<span class='alert'>You slice through the attachment mesh of [holder.name]'s [src.name] with [tool].</span>")
				if(2)
					tool.the_mob.visible_message("<span class='alert'>[tool.the_mob] saws through the base mount of [holder.name]'s [src.name] with [tool].</span>", "<span class='alert'>You saw through the base mount of [holder.name]'s [src.name] with [tool].</span>")

					SPAWN(rand(150,200))
						if(remove_stage == 2)
							src.remove(0)
				if(3)
					tool.the_mob.visible_message("<span class='alert'>[tool.the_mob] cuts through the remaining strips of material holding [holder.name]'s [src.name] on with [tool].</span>", "<span class='alert'>You cut through the remaining strips of material holding [holder.name]'s [src.name] on with [tool].</span>")
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
		if (src.dmg_blunt + src.dmg_burns > src.max_health)
			if(src.holder) return 1 // need to do special stuff in this case, so we let the borg's melee hit take care of it
			else
				src.visible_message("<b>[src]</b> breaks!")
				playsound(src, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 40, 1)
				if (istype(src.loc,/turf/)) make_cleanable( /obj/decal/cleanable/robot_debris/limb,src.loc)
				del(src)
				return 0
		return 0

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

ABSTRACT_TYPE(/obj/item/parts/robot_parts/head)
/obj/item/parts/robot_parts/head
	name = "cyborg head"
	desc = "A serviceable head unit for a potential cyborg."
	icon_state_base = "head"
	icon_state = "head-generic"
	slot = "head"

	var/obj/item/organ/brain/brain = null
	var/obj/item/ai_interface/ai_interface = null
	var/visible_eyes = 1

		// Screen head specific
	var/mode = "lod" // lod (light-on-dark) or dol (dark-on-light)
	var/face = "happy"

	examine()
		. = ..()
		if (src.brain)
			. += "<span class='notice'>This head unit has [src.brain] inside. Use a wrench if you want to remove it.</span>"
		else if (src.ai_interface)
			. += "<span class='notice'>This head unit has [src.ai_interface] inside. Use a wrench if you want to remove it.</span>"
		else
			. += "<span class='alert'>This head unit is empty.</span>"

	attackby(obj/item/W, mob/user)
		if (!W)
			return
		if (istype(W,/obj/item/organ/brain))
			if (src.brain)
				boutput(user, "<span class='alert'>There is already a brain in there. Use a wrench to remove it.</span>")
				return

			if (src.ai_interface)
				boutput(user, "<span class='alert'>There is already \an [src.ai_interface] in there. Use a wrench to remove it.</span>")
				return

			var/obj/item/organ/brain/B = W
			if ( !(B.owner && B.owner.key) && !istype(W, /obj/item/organ/brain/latejoin) )
				boutput(user, "<span class='alert'>This brain doesn't look any good to use.</span>")
				return
			else if ( B.owner  &&  (jobban_isbanned(B.owner.current,"Cyborg") || B.owner.dnr) ) //If the borg-to-be is jobbanned or has DNR set
				boutput(user, "<span class='alert'>The brain disintigrates in your hands!</span>")
				user.drop_item()
				qdel(B)
				var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
				smoke.set_up(1, 0, user.loc)
				smoke.start()
				return
			user.drop_item()
			B.set_loc(src)
			src.brain = B
			boutput(user, "<span class='notice'>You insert the brain.</span>")
			playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)
			return

		else if (istype(W, /obj/item/ai_interface))
			if (src.brain)
				boutput(user, "<span class='alert'>There is already a brain in there. Use a wrench to remove it.</span>")
				return

			if (src.ai_interface)
				boutput(user, "<span class='alert'>There is already \an [src.ai_interface] in there!</span>")
				return

			var/obj/item/ai_interface/I = W
			user.drop_item()
			I.set_loc(src)
			src.ai_interface = I
			boutput(user, "<span class='notice'>You insert [I].</span>")
			playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)
			return

		else if (iswrenchingtool(W))
			if (!src.brain && !src.ai_interface)
				boutput(user, "<span class='alert'>There's no brain or AI interface chip in there to remove.</span>")
				return
			playsound(src, 'sound/items/Ratchet.ogg', 40, 1)
			if (src.ai_interface)
				boutput(user, "<span class='notice'>You open the head's compartment and take out [src.ai_interface].</span>")
				user.put_in_hand_or_drop(src.ai_interface)
				src.ai_interface = null
			else if (src.brain)
				boutput(user, "<span class='notice'>You open the head's compartment and take out [src.brain].</span>")
				user.put_in_hand_or_drop(src.brain)
				src.brain = null
		else
			..()

/obj/item/parts/robot_parts/head/standard
	name = "standard cyborg head"
	max_health = 175
	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/sheet))
			var/obj/item/sheet/M = W
			if (M.amount >= 2)
				boutput(user, "<span class='notice'>You reinforce [src.name] with the metal.</span>")
				var/obj/item/parts/robot_parts/head/sturdy/newhead = new /obj/item/parts/robot_parts/head/sturdy(get_turf(src))
				M.change_stack_amount(-2)
				if (M.amount < 1)
					user.drop_item()
					qdel(M)
				if (src.brain)
					newhead.brain = src.brain
					src.brain.set_loc(newhead)
				else if (src.ai_interface)
					newhead.ai_interface = src.ai_interface
					src.ai_interface.set_loc(newhead)
				qdel(src)
				return
			else
				boutput(user, "<span class='alert'>You need at least two metal sheets to reinforce this component.</span>")
				return
		else
			..()

/obj/item/parts/robot_parts/head/sturdy
	name = "sturdy cyborg head"
	desc = "A reinforced head unit capable of taking more abuse than usual."
	appearanceString = "sturdy"
	icon_state = "head-sturdy"
	max_health = 225
	weight = 0.2
	kind_of_limb = (LIMB_ROBOT | LIMB_HEAVY) // shush

	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/sheet))
			var/obj/item/sheet/M = W
			if (!M.reinforcement)
				boutput(user, "<span class='alert'>You'll need reinforced sheets to reinforce the head.</span>")
				return
			if (M.amount >= 2)
				boutput(user, "<span class='notice'>You reinforce [src.name] with the reinforced metal.</span>")
				var/obj/item/parts/robot_parts/head/heavy/newhead = new /obj/item/parts/robot_parts/head/heavy(get_turf(src))
				M.change_stack_amount(-2)
				if (M.amount < 1)
					user.drop_item()
					qdel(M)
				if (src.brain)
					newhead.brain = src.brain
					src.brain.set_loc(newhead)
				else if (src.ai_interface)
					newhead.ai_interface = src.ai_interface
					src.ai_interface.set_loc(newhead)
				qdel(src)
				return
			else
				boutput(user, "<span class='alert'>You need at least two reinforced metal sheets to reinforce this component.</span>")
				return
		else if (isweldingtool(W))
			if(!W:try_weld(user, 1))
				return
			boutput(user, "<span class='notice'>You remove the reinforcement metals from [src].</span>")
			var/obj/item/parts/robot_parts/head/newhead = new /obj/item/parts/robot_parts/head/(get_turf(src))
			if (src.brain)
				newhead.brain = src.brain
				src.brain.set_loc(newhead)
			else if (src.ai_interface)
				newhead.ai_interface = src.ai_interface
				src.ai_interface.set_loc(newhead)

			//costs 2 sheets to make vov
			new/obj/item/sheet/steel(get_turf(src))
			new/obj/item/sheet/steel(get_turf(src))

			qdel(src)
			return

		else
			..()

/obj/item/parts/robot_parts/head/heavy
	name = "heavy cyborg head"
	desc = "A heavily reinforced head unit intended for use on cyborgs that perform tough and dangerous work."
	appearanceString = "heavy"
	icon_state = "head-heavy"
	max_health = 350
	weight = 0.4
	kind_of_limb = (LIMB_ROBOT | LIMB_HEAVIER)

	attackby(obj/item/W, mob/user)
		if (isweldingtool(W))
			if(!W:try_weld(user, 1))
				return
			boutput(user, "<span class='notice'>You remove the reinforcement metals from [src].</span>")
			var/obj/item/parts/robot_parts/head/sturdy/newhead = new /obj/item/parts/robot_parts/head/sturdy/(get_turf(src))
			if (src.brain)
				newhead.brain = src.brain
				src.brain.set_loc(newhead)
			else if (src.ai_interface)
				newhead.ai_interface = src.ai_interface
				src.ai_interface.set_loc(newhead)
			//costs 2 sheets to make vov
			new/obj/item/sheet/steel/reinforced(get_turf(src))
			new/obj/item/sheet/steel/reinforced(get_turf(src))

			qdel(src)
			return
		else
			..()

/obj/item/parts/robot_parts/head/light
	name = "light cyborg head"
	desc = "A cyborg head with little reinforcement, to be built in times of scarce resources."
	appearanceString = "light"
	icon_state = "head-light"
	max_health = 50
	robot_movement_modifier = /datum/movement_modifier/robot_part/head
	kind_of_limb = (LIMB_ROBOT | LIMB_LIGHT)

/obj/item/parts/robot_parts/head/antique
	name = "antique cyborg head"
	desc = "Looks like a discarded prop from some sorta low-budget scifi movie."
	appearanceString = "android"
	icon_state = "head-android"
	max_health = 150
	visible_eyes = 0
	robot_movement_modifier = /datum/movement_modifier/robot_part/head

/obj/item/parts/robot_parts/head/screen
	name = "cyborg screen head"
	desc = "A somewhat fragile head unit with a screen addressable by the cyborg."
	appearanceString = "screen"
	icon_state = "head-screen"
	max_health = 90
	var/list/expressions = list("happy", "veryhappy", "neutral", "sad", "angry", "curious", "surprised", "unsure", "content", "tired", "cheeky","skull","eye")

ABSTRACT_TYPE(/obj/item/parts/robot_parts/chest)
/obj/item/parts/robot_parts/chest
	name = "cyborg chest"
	desc = "Oh no I'm an abstract parent object, how did you get me?"
	icon_state_base = "body"
	icon_state = "body-generic"
	slot = "chest"
	//These vars track the wiring/cell that the chest needs before you can stuff it on a frame
	var/wires = 0
	var/obj/item/cell/cell = null

	examine()
		. = ..()

		if (src.cell)
			. += "<span class='notice'>This chest unit has a [src.cell] installed. Use a wrench if you want to remove it.</span>"
		else
			. += "<span class='alert'>This chest unit has no power cell.</span>"

		if (src.wires)
			. += "<span class='notice'>This chest unit has had wiring installed.</span>"
		else
			. += "<span class='alert'>This chest unit has not yet been wired up.</span>"

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/cell))
			if(src.cell)
				boutput(user, "<span class='alert'>You have already inserted a cell!</span>")
				return
			else
				user.drop_item()
				W.set_loc(src)
				src.cell = W
				boutput(user, "<span class='notice'>You insert [W].</span>")
				playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)

		else if(istype(W, /obj/item/cable_coil))
			if (src.ropart_get_damage_percentage(2) > 0) ..()
			else
				if(src.wires)
					boutput(user, "<span class='alert'>You have already inserted some wire!</span>")
					return
				else
					var/obj/item/cable_coil/coil = W
					coil.use(1)
					src.wires = 1
					boutput(user, "<span class='notice'>You insert some wire.</span>")
					playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)

		else if (iswrenchingtool(W))
			if(!src.cell)
				boutput(user, "<span class='alert'>There's no cell in there to remove.</span>")
				return
			playsound(src, 'sound/items/Ratchet.ogg', 40, 1)
			boutput(user, "<span class='notice'>You remove the cell from it's slot in the chest unit.</span>")
			src.cell.set_loc( get_turf(src) )
			src.cell = null

		else if (issnippingtool(W))
			if(src.wires < 1)
				boutput(user, "<span class='alert'>There's no wiring in there to remove.</span>")
				return
			playsound(src, 'sound/items/Wirecutter.ogg', 40, 1)
			boutput(user, "<span class='notice'>You cut out the wires and remove them from the chest unit.</span>")
			// i don't know why this would get abused
			// but it probably will
			// when that happens
			// tell past me i'm saying hello
			var/obj/item/cable_coil/cut/C = new /obj/item/cable_coil/cut(src.loc)
			C.amount = src.wires
			src.wires = 0

		else ..()

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.cell)
			src.cell = null

/obj/item/parts/robot_parts/chest/standard
	name = "standard cyborg chest"
	desc = "The centerpiece of any cyborg. It wouldn't get very far without it."
	max_health = 250

	attackby(obj/item/W, mob/user)
		if (isweldingtool(W))
			var/obj/item/weldingtool/welder = W
			if (welder.try_weld(user, 3, 3))
				var/obj/item/clothing/suit/armor/makeshift/R = new /obj/item/clothing/suit/armor/makeshift(get_turf(user))
				boutput(user, "<span class='notice'>You remove the internal support structures of the [src]. It's structural integrity is ruined, but you could squeeze into it now.</span>")
				user.u_equip(src)
				user.put_in_hand_or_drop(R)
				qdel(src)
		else
			..()


/obj/item/parts/robot_parts/chest/light
	name = "light cyborg chest"
	desc = "A bare-bones cyborg chest designed for the least consumption of resources."
	appearanceString = "light"
	icon_state = "body-light"
	max_health = 75
	kind_of_limb = (LIMB_ROBOT | LIMB_LIGHT) // hush

ABSTRACT_TYPE(/obj/item/parts/robot_parts/arm)
/obj/item/parts/robot_parts/arm
	name = "placeholder item (don't use this!)"
	desc = "A metal arm for a cyborg. It won't be able to use as many tools without it!"
	max_health = 60
	can_hold_items = 1
	accepts_normal_human_overlays = 1

	attack(mob/living/carbon/M, mob/living/carbon/user)
		if(!ismob(M))
			return

		src.add_fingerprint(user)

		if(!(user.zone_sel.selecting in list("l_arm","r_arm")) || !ishuman(M))
			return ..()

		if (!surgeryCheck(M,user))
			return ..()

		var/mob/living/carbon/human/H = M

		if(H.limbs.get_limb(user.zone_sel.selecting))
			boutput(user, "<span class='alert'>[H.name] already has one of those!</span>")
			return

		if(src.appearanceString == "sturdy" || src.appearanceString == "heavy")
			boutput(user, "<span class='alert'>That arm is too big to fit on [H]'s body!</span>")
			return

		attach(H,user)

		return

	attackby(obj/item/W, mob/user)
		//gonna hack this in with appearanceString
		if ((appearanceString == "sturdy" || appearanceString == "heavy") && isweldingtool(W))
			if(!W:try_weld(user, 1))
				return
			boutput(user, "<span class='notice'>You remove the reinforcement metals from [src].</span>")

			if (appearanceString == "sturdy")
				if (slot == "l_arm")
					new /obj/item/parts/robot_parts/arm/left(get_turf(src))
				else if (slot == "r_arm")
					new /obj/item/parts/robot_parts/arm/right(get_turf(src))

				new/obj/item/sheet/steel(get_turf(src))
				new/obj/item/sheet/steel(get_turf(src))

			else if (appearanceString == "heavy")
				if (slot == "l_arm")
					new /obj/item/parts/robot_parts/arm/left/sturdy(get_turf(src))
				else if (slot == "r_arm")
					new /obj/item/parts/robot_parts/arm/right/sturdy(get_turf(src))

				new/obj/item/sheet/steel/reinforced(get_turf(src))
				new/obj/item/sheet/steel/reinforced(get_turf(src))

			qdel(src)
			return
		else
			..()
	on_holder_examine()
		if (!isrobot(src.holder)) // probably a human, probably  :p
			return "has [bicon(src)] \an [initial(src.name)] attached as a"
		return

ABSTRACT_TYPE(/obj/item/parts/robot_parts/arm/left)
/obj/item/parts/robot_parts/arm/left
	name = "cyborg left arm"
	slot = "l_arm"
	icon_state_base = "l_arm"
	icon_state = "l_arm-generic"
	handlistPart = "armL-generic"

/obj/item/parts/robot_parts/arm/left/standard
	name = "standard cyborg left arm"
	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/sheet))
			var/obj/item/sheet/M = W
			if (M.amount >= 2)
				boutput(user, "<span class='notice'>You reinforce [src.name] with the metal.</span>")
				new /obj/item/parts/robot_parts/arm/left/sturdy(get_turf(src))
				M.change_stack_amount(-2)
				if (M.amount < 1)
					user.drop_item()
					del(M)
				del(src)
				return
			else
				boutput(user, "<span class='alert'>You need at least two metal sheets to reinforce this component.</span>")
				return
		else ..()

/obj/item/parts/robot_parts/arm/left/sturdy
	name = "sturdy cyborg left arm"
	appearanceString = "sturdy"
	icon_state = "l_arm-sturdy"
	max_health = 100
	weight = 0.2
	kind_of_limb = (LIMB_ROBOT | LIMB_HEAVY)

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/sheet))
			var/obj/item/sheet/M = W
			if (!M.reinforcement)
				boutput(user, "<span class='alert'>You'll need reinforced sheets to reinforce the [src.name].</span>")
				return
			if (M.amount >= 2)
				boutput(user, "<span class='notice'>You reinforce [src.name] with the reinforced metal.</span>")
				new /obj/item/parts/robot_parts/arm/left/heavy(get_turf(src))
				M.change_stack_amount(-2)
				if (M.amount < 1)
					user.drop_item()
					del(M)
				del(src)
				return
			else
				boutput(user, "<span class='alert'>You need at least two reinforced metal sheets to reinforce this component.</span>")
				return
		else ..()

/obj/item/parts/robot_parts/arm/left/heavy
	name = "heavy cyborg left arm"
	appearanceString = "heavy"
	icon_state = "l_arm-heavy"
	max_health = 175
	weight = 0.4
	kind_of_limb = (LIMB_ROBOT | LIMB_HEAVIER)

/obj/item/parts/robot_parts/arm/left/light
	name = "light cyborg left arm"
	appearanceString = "light"
	icon_state = "l_arm-light"
	max_health = 25
	handlistPart = "armL-light"
	robot_movement_modifier = /datum/movement_modifier/robot_part/arm_left
	kind_of_limb = (LIMB_ROBOT | LIMB_LIGHT)

ABSTRACT_TYPE(/obj/item/parts/robot_parts/arm/right)
/obj/item/parts/robot_parts/arm/right
	name = "cyborg right arm"
	icon_state = "r_arm"
	slot = "r_arm"
	icon_state_base = "r_arm"
	icon_state = "r_arm-generic"
	handlistPart = "armR-generic"


/obj/item/parts/robot_parts/arm/right/standard
	name = "standard cyborg right arm"
	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/sheet))
			var/obj/item/sheet/M = W
			if (M.amount >= 2)
				boutput(user, "<span class='notice'>You reinforce [src.name] with the metal.</span>")
				new /obj/item/parts/robot_parts/arm/right/sturdy(get_turf(src))
				M.change_stack_amount(-2)
				if (M.amount < 1)
					user.drop_item()
					del(M)
				del(src)
				return
			else
				boutput(user, "<span class='alert'>You need at least two metal sheets to reinforce this component.</span>")
				return
		else ..()

/obj/item/parts/robot_parts/arm/right/sturdy
	name = "sturdy cyborg right arm"
	appearanceString = "sturdy"
	icon_state = "r_arm-sturdy"
	max_health = 100
	weight = 0.2
	kind_of_limb = (LIMB_ROBOT | LIMB_HEAVY)

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/sheet))
			var/obj/item/sheet/M = W
			if (!M.reinforcement)
				boutput(user, "<span class='alert'>You'll need reinforced sheets to reinforce the [src.name].</span>")
				return
			if (M.amount >= 2)
				boutput(user, "<span class='notice'>You reinforce [src.name] with the reinforced metal.</span>")
				new /obj/item/parts/robot_parts/arm/right/heavy(get_turf(src))
				M.change_stack_amount(-2)
				if (M.amount < 1)
					user.drop_item()
					del(M)
				del(src)
				return
			else
				boutput(user, "<span class='alert'>You need at least two reinforced metal sheets to reinforce this component.</span>")
				return
		else ..()

/obj/item/parts/robot_parts/arm/right/heavy
	name = "heavy cyborg right arm"
	appearanceString = "heavy"
	icon_state = "r_arm-heavy"
	max_health = 175
	weight = 0.4
	kind_of_limb = (LIMB_ROBOT | LIMB_HEAVIER)

/obj/item/parts/robot_parts/arm/right/light
	name = "light cyborg right arm"
	appearanceString = "light"
	icon_state = "r_arm-light"
	max_health = 25
	handlistPart = "armR-light"
	robot_movement_modifier = /datum/movement_modifier/robot_part/arm_right
	kind_of_limb = (LIMB_ROBOT | LIMB_LIGHT)

ABSTRACT_TYPE(/obj/item/parts/robot_parts/leg)
/obj/item/parts/robot_parts/leg
	name = "placeholder item (don't use this!)"
	desc = "A metal leg for a cyborg. It won't be able to move very well without this!"
	icon_state_base = "legs" // effectively the prefix for items that go on both legs at once.
	max_health = 60
	var/step_sound = "step_robo"
	var/step_priority = STEP_PRIORITY_LOW

	attack(mob/living/carbon/M, mob/living/carbon/user)
		if(!ismob(M))
			return

		src.add_fingerprint(user)

		if(!(user.zone_sel.selecting in list("l_leg","r_leg")) || !ishuman(M))
			return ..()

		if (!surgeryCheck(M,user))
			return ..()

		var/mob/living/carbon/human/H = M

		if(H.limbs.get_limb(user.zone_sel.selecting))
			boutput(user, "<span class='alert'>[H.name] already has one of those!</span>")
			return

		if(src.appearanceString == "sturdy" || src.appearanceString == "heavy" || src.appearanceString == "thruster")
			boutput(user, "<span class='alert'>That leg is too big to fit on [H]'s body!</span>")
			return

		attach(H,user)

		return

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/skull))
			var/obj/item/skull/Skull = W
			var/obj/machinery/bot/skullbot/B

			if (Skull.icon_state == "skull_crystal" || istype(Skull, /obj/item/skull/crystal))
				B = new /obj/machinery/bot/skullbot/crystal(get_turf(user))

			else if (Skull.icon_state == "skullP" || istype(Skull, /obj/item/skull/strange))
				B = new /obj/machinery/bot/skullbot/strange(get_turf(user))

			else if (Skull.icon_state == "skull_strange" || istype(Skull, /obj/item/skull/peculiar))
				B = new /obj/machinery/bot/skullbot/peculiar(get_turf(user))

			else if (Skull.icon_state == "skullA" || istype(Skull, /obj/item/skull/odd))
				B = new /obj/machinery/bot/skullbot/odd(get_turf(user))

			else if (Skull.icon_state == "skull_noface" || istype(Skull, /obj/item/skull/noface))
				B = new /obj/machinery/bot/skullbot/faceless(get_turf(user))

			else if (Skull.icon_state == "skull_gold" || istype(Skull, /obj/item/skull/gold))
				B = new /obj/machinery/bot/skullbot/gold(get_turf(user))

			else
				B = new /obj/machinery/bot/skullbot(get_turf(user))

			if (Skull.donor)
				B.name = "[Skull.donor.real_name] skullbot"

			user.show_text("You add [W] to [src]. That's neat.", "blue")
			qdel(W)
			qdel(src)
			return

		else if (istype(W, /obj/item/soulskull))
			new /obj/machinery/bot/skullbot/ominous(get_turf(user))
			boutput(user, "<span class='notice'>You add [W] to [src]. That's neat.</span>")
			qdel(W)
			qdel(src)
			return

		else
			return ..()

	on_holder_examine()
		if (!isrobot(src.holder)) // probably a human, probably  :p
			return "has [bicon(src)] \an [initial(src.name)] attached as a"
		return

ABSTRACT_TYPE(/obj/item/parts/robot_parts/leg/left)
/obj/item/parts/robot_parts/leg/left
	name = "cyborg left leg"
	slot = "l_leg"
	step_image_state = "footprintsL"
	icon_state_base = "l_leg"
	icon_state = "l_leg-generic"
	partlistPart = "legL-generic"
	movement_modifier = /datum/movement_modifier/robotleg_left

/obj/item/parts/robot_parts/leg/left/standard
	name = "standard cyborg left leg"

/obj/item/parts/robot_parts/leg/left/light
	name = "light cyborg left leg"
	appearanceString = "light"
	icon_state = "l_leg-light"
	partlistPart = "legL-light"
	max_health = 25
	robot_movement_modifier = /datum/movement_modifier/robotleg_left
	kind_of_limb = (LIMB_ROBOT | LIMB_LIGHT)

/obj/item/parts/robot_parts/leg/left/treads
	name = "left cyborg tread"
	desc = "A large wheeled unit like tank tracks. This will help heavier cyborgs to move quickly."
	appearanceString = "treads"
	icon_state = "l_leg-treads"
	handlistPart = "legL-treads" // THIS ONE gets to layer with the hands because it looks ugly if jumpsuits are over it. Will fix codewise later
	max_health = 100
	powerdrain = 2.5
	step_image_state = "tracksL"
	movement_modifier = /datum/movement_modifier/robottread_left
	robot_movement_modifier = /datum/movement_modifier/robot_part/tread_left
	kind_of_limb = (LIMB_ROBOT | LIMB_TREADS)

ABSTRACT_TYPE(/obj/item/parts/robot_parts/leg/right)
/obj/item/parts/robot_parts/leg/right
	name = "cyborg right leg"
	slot = "r_leg"
	step_image_state = "footprintsR"
	icon_state_base = "r_leg"
	icon_state = "r_leg-generic"
	partlistPart = "legR-generic"
	movement_modifier = /datum/movement_modifier/robotleg_right

/obj/item/parts/robot_parts/leg/right/standard
	name = "standard cyborg right leg"

/obj/item/parts/robot_parts/leg/right/light
	name = "light cyborg right leg"
	appearanceString = "light"
	icon_state = "r_leg-light"
	partlistPart = "legR-light"
	max_health = 25
	robot_movement_modifier = /datum/movement_modifier/robotleg_right
	kind_of_limb = (LIMB_ROBOT | LIMB_LIGHT)

/obj/item/parts/robot_parts/leg/right/treads
	name = "right cyborg tread"
	desc = "A large wheeled unit like tank tracks. This will help heavier cyborgs to move quickly."
	appearanceString = "treads"
	icon_state = "r_leg-treads"
	handlistPart = "legR-treads"  // THIS ONE gets to layer with the hands because it looks ugly if jumpsuits are over it. Will fix codewise later
	max_health = 100
	powerdrain = 2.5
	step_image_state = "tracksR"
	movement_modifier = /datum/movement_modifier/robottread_right
	robot_movement_modifier = /datum/movement_modifier/robot_part/tread_right
	kind_of_limb = (LIMB_ROBOT | LIMB_TREADS)

/obj/item/parts/robot_parts/leg/left/thruster
	name = "left thruster assembly"
	desc = "Is it really a good idea to give thrusters to cyborgs..? Probably not."
	appearanceString = "thruster"
	icon_state = "l_leg-thruster"
	max_health = 100
	powerdrain = 5
	step_image_state = null //It's flying so no need for this.
	robot_movement_modifier = /datum/movement_modifier/robot_part/thruster_left
	kind_of_limb = (LIMB_ROBOT | LIMB_TREADS | LIMB_LIGHT)

/obj/item/parts/robot_parts/leg/right/thruster
	name = "right thruster assembly"
	desc = "Is it really a good idea to give thrusters to cyborgs..? Probably not."
	appearanceString = "thruster"
	icon_state = "r_leg-thruster"
	max_health = 100
	powerdrain = 5
	step_image_state = null //It's flying so no need for this.
	robot_movement_modifier = /datum/movement_modifier/robot_part/thruster_right
	kind_of_limb = (LIMB_ROBOT | LIMB_TREADS | LIMB_LIGHT)

/obj/item/parts/robot_parts/robot_frame
	name = "robot frame"
	icon_state = "robo_suit"
	max_health = 5000
	var/syndicate = 0 ///This will make the borg a syndie one
	var/emagged = 0
	var/obj/item/parts/robot_parts/head/head = null
	var/obj/item/parts/robot_parts/chest/chest = null
	var/obj/item/parts/robot_parts/l_arm = null
	var/obj/item/parts/robot_parts/r_arm = null
	var/obj/item/parts/robot_parts/l_leg = null
	var/obj/item/parts/robot_parts/r_leg = null
	var/obj/item/organ/brain/brain = null

	New()
		..()
		src.icon_state = "robo_suit"; //The frame is the only exception for the composite item name thing.
		src.UpdateIcon()

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if(!emagged)
			emagged = 1
			if (user)
				logTheThing(LOG_STATION, user, "emags a robot frame at [log_loc(user)].")
				boutput(user, "<span class='notice'>You short out the behavior restrictors on the frame's motherboard.</span>")
			return 1
		else if(user)
			boutput(user, "<span class='alert'>This frame's behavior restrictors have already been shorted out.</span>")
		return 0

	demag(var/mob/user)
		if (!emagged)
			return 0
		if (user)
			user.show_text("You repair the behavior restrictors on the frame's motherboard.", "blue")
		emagged = 0
		return 1

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/parts/robot_parts/))
			var/obj/item/parts/robot_parts/P = W
			switch (P.slot)
				if ("head")
					if (src.head)
						boutput(user, "<span class='alert'>There is already a head piece on the frame. If you want to remove it, use a wrench.</span>")
						return
					var/obj/item/parts/robot_parts/head/H = P
					if (!H.brain && !H.ai_interface)
						boutput(user, "<span class='alert'>You need to insert a brain or an AI interface into the head piece before attaching it to the frame.</span>")
						return
					src.head = H

				if ("chest")
					if (src.chest)
						boutput(user, "<span class='alert'>There is already a chest piece on the frame. If you want to remove it, use a wrench.</span>")
						return
					var/obj/item/parts/robot_parts/chest/C = P
					if (!C.wires)
						boutput(user, "<span class='alert'>You need to add wiring to the chest piece before attaching it to the frame.</span>")
						return
					if (!C.cell)
						boutput(user, "<span class='alert'>You need to add a power cell to the chest piece before attaching it to the frame.</span>")
						return
					src.chest = C

				if ("l_arm")
					if (src.l_arm)
						boutput(user, "<span class='alert'>There is already a left arm piece on the frame. If you want to remove it, use a wrench.</span>")
						return
					src.l_arm = P

				if ("r_arm")
					if (src.r_arm)
						boutput(user, "<span class='alert'>There is already a right arm piece on the frame. If you want to remove it, use a wrench.</span>")
						return
					src.r_arm = P

				if ("arm_both")
					if (src.l_arm || src.r_arm)
						boutput(user, "<span class='alert'>There is already an arm piece on the frame that occupies both arm mountings. If you want to remove it, use a wrench.</span>")
						return
					src.l_arm = P
					src.r_arm = P

				if ("l_leg")
					if (src.l_leg)
						boutput(user, "<span class='alert'>There is already a left leg piece on the frame. If you want to remove it, use a wrench.</span>")
						return
					src.l_leg = P

				if ("r_leg")
					if (src.r_leg)
						boutput(user, "<span class='alert'>There is already a right leg piece on the frame. If you want to remove it, use a wrench.</span>")
						return
					src.r_leg = P

				if ("leg_both")
					if (src.l_leg || src.r_leg)
						boutput(user, "<span class='alert'>There is already a leg piece on the frame that occupies both leg mountings. If you want to remove it, use a wrench.</span>")
						return
					src.l_leg = P
					src.r_leg = P

				else
					boutput(user, "<span class='alert'>You can't seem to fit this piece anywhere on the frame.</span>")
					return

			playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)
			boutput(user, "<span class='notice'>You add [P] to the frame.</span>")
			user.drop_item()
			P.set_loc(src)
			src.UpdateIcon()

		if (istype(W, /obj/item/organ/brain))
			boutput(user, "<span class='alert'>The brain needs to go in the head piece, not the frame.</span>")
			return

		if (iswrenchingtool(W))
			var/list/actions = list("Do nothing")
			if(src.check_completion())
				actions.Add("Finish and Activate the Cyborg")
			if(src.r_leg)
				actions.Add("Remove the Right leg")
			if(src.l_leg)
				actions.Add("Remove the Left leg")
			if(src.r_arm)
				actions.Add("Remove the Right arm")
			if(src.l_arm)
				actions.Add("Remove the Left arm")
			if(src.head)
				actions.Add("Remove the Head")
			if(src.chest)
				actions.Add("Remove the Chest")
			if(!actions.len)
				boutput(user, "<span class='alert'>You can't think of anything to do with the frame.</span>")
				return

			var/action = tgui_input_list(user, "What do you want to do?", "Robot Frame", actions)
			if (!action)
				return
			if (action == "Do nothing")
				return
			if (BOUNDS_DIST(src.loc, user.loc) > 0 && !user.bioHolder.HasEffect("telekinesis"))
				boutput(user, "<span class='alert'>You need to move closer!</span>")
				return

			switch(action)
				if("Finish and Activate the Cyborg")
					user.unlock_medal("Weird Science", 1)
					src.finish_cyborg()
				if("Remove the Right leg")
					src.r_leg?.set_loc( get_turf(src) )
					if (src.r_leg.slot == "leg_both")
						src.r_leg = null
						src.l_leg = null
					else src.r_leg = null
				if("Remove the Left leg")
					src.l_leg?.set_loc( get_turf(src) )
					if (src.l_leg.slot == "leg_both")
						src.r_leg = null
						src.l_leg = null
					else src.l_leg = null
				if("Remove the Right arm")
					src.r_arm?.set_loc( get_turf(src) )
					if (src.r_arm.slot == "arm_both")
						src.r_arm = null
						src.l_arm = null
					else src.r_arm = null
				if("Remove the Left arm")
					src.l_arm?.set_loc( get_turf(src) )
					if (src.l_arm.slot == "arm_both")
						src.r_arm = null
						src.l_arm = null
					else src.l_arm = null
				if("Remove the Head")
					src.head?.set_loc( get_turf(src) )
					src.head = null
				if("Remove the Chest")
					src.chest?.set_loc( get_turf(src) )
					src.chest = null
			playsound(src, 'sound/items/Ratchet.ogg', 40, 1)
			src.UpdateIcon()
			return

	update_icon()
		src.overlays = null
		if(src.chest) src.overlays += image('icons/mob/robots.dmi', "body-" + src.chest.appearanceString, OBJ_LAYER, 2)
		if(src.head) src.overlays += image('icons/mob/robots.dmi', "head-" + src.head.appearanceString, OBJ_LAYER, 2)

		if(src.l_leg)
			if(src.l_leg.slot == "leg_both") src.overlays += image('icons/mob/robots.dmi', "leg-" + src.l_leg.appearanceString, OBJ_LAYER, 2)
			else src.overlays += image('icons/mob/robots.dmi', "l_leg-" + src.l_leg.appearanceString, OBJ_LAYER, 2)

		if(src.r_leg)
			if(src.r_leg.slot == "leg_both") src.overlays += image('icons/mob/robots.dmi', "leg-" + src.r_leg.appearanceString, OBJ_LAYER, 2)
			else src.overlays += image('icons/mob/robots.dmi', "r_leg-" + src.r_leg.appearanceString, OBJ_LAYER, 2)

		if(src.l_arm)
			if(src.l_arm.slot == "arm_both") src.overlays += image('icons/mob/robots.dmi', "arm-" + src.l_arm.appearanceString, OBJ_LAYER, 2)
			else src.overlays += image('icons/mob/robots.dmi', "l_arm-" + src.l_arm.appearanceString, OBJ_LAYER, 2)

		if(src.r_arm)
			if(src.r_arm.slot == "arm_both") src.overlays += image('icons/mob/robots.dmi', "arm-" + src.r_arm.appearanceString, OBJ_LAYER, 2)
			else src.overlays += image('icons/mob/robots.dmi', "r_arm-" + src.r_arm.appearanceString, OBJ_LAYER, 2)

	proc/check_completion()
		if (src.chest && src.head)
			if (src.head.brain)
				return 1
			if (src.head.ai_interface)
				return 1
		return 0

	proc/finish_cyborg()
		var/mob/living/silicon/robot/borg = null
		borg = new /mob/living/silicon/robot(get_turf(src.loc),src,0,src.syndicate,src.emagged)
		// there was a big transferring list of parts from the frame to the compborg here at one point, but it didn't work
		// because the cyborg's process proc would kill it for having no chest piece set up after New() finished but
		// before it could get around to this list, so i tweaked their New() proc instead to grab all the shit out of
		// the frame before process could go off resulting in a borg that doesn't instantly die

		borg.name = "Cyborg"
		borg.real_name = "Cyborg"

		if (!src.head)
			// how the fuck did you even do this
			stack_trace("Attempted to finish a cyborg from borg frame [identify_object(src)] without a head. That's bad.")
			borg.death()
			qdel(src)
			return

		if(borg.part_head.brain?.owner?.key)
			if(borg.part_head.brain.owner.current)
				borg.gender = borg.part_head.brain.owner.current.gender
				if(borg.part_head.brain.owner.current.client)
					borg.lastKnownIP = borg.part_head.brain.owner.current.client.address
			var/mob/M = find_ghost_by_key(borg.part_head.brain.owner.key)
			if (!M) // if we couldn't find them (i.e. they're still alive), don't pull them into this borg
				src.visible_message("<span class='alert'><b>[src]</b> remains inactive, as the conciousness associated with that brain could not be reached.</span>")
				borg.death()
				qdel(src)
				return
			if (!isdead(M)) // so if they're in VR, the afterlife bar, or a ghostcritter
				boutput(M, "<span class='notice'>You feel yourself being pulled out of your current plane of existence!</span>")
				borg.part_head.brain.owner = M.ghostize()?.mind
				qdel(M)
			else
				boutput(M, "<span class='alert'>You feel yourself being dragged out of the afterlife!</span>")
			borg.part_head.brain.owner.transfer_to(borg)
			if (isdead(M) && !isliving(M))
				qdel(M)

		else if (src.head.ai_interface)
			if (!(borg in available_ai_shells))
				available_ai_shells += borg
			for_by_tcl(AI, /mob/living/silicon/ai)
				boutput(AI, "<span class='success'>[src] has been connected to you as a controllable shell.</span>")
			borg.shell = 1
		else if (istype(borg.part_head.brain, /obj/item/organ/brain/latejoin))
			boutput(usr, "<span class='notice'>You activate the frame and a audible beep emanates from the head.</span>")
			playsound(src, 'sound/weapons/radxbow.ogg', 40, 1)
		else
			stack_trace("We finished cyborg [identify_object(borg)] from frame [identify_object(src)] with a brain, but somehow lost the brain??? Where did it go")
			borg.death()
			qdel(src)
			return

		if (src.chest && src.chest.cell)
			borg.cell = src.chest.cell
			borg.cell.set_loc(borg)

		if (borg.mind && !borg.part_head.ai_interface)
			borg.unlock_medal("Adjutant Online", 1)
			borg.set_loc(get_turf(src))

			boutput(borg, "<B>You are playing a Robot. The Robot can interact with most electronic objects in its view point.</B>")
			boutput(borg, "To use something, simply click it.")
			boutput(borg, "Use the prefix <B>:s</B> to speak to fellow cyborgs and the AI through binary.")

			if (src.emagged || src.syndicate)
				if ((ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution)) && borg.mind)
					ticker.mode:revolutionaries += borg.mind
					ticker.mode:update_rev_icons_added(borg.mind)
				if (src.emagged)
					borg.emagged = 1
					SPAWN(0)
						borg.update_appearance()
				else if (src.syndicate)
					borg.syndicate = 1
				borg.make_syndicate("activated by [usr]")
			else
				boutput(borg, "<B>You must follow the AI's laws to the best of your ability.</B>")
				borg.show_laws() // The antagonist proc does that too.

			borg.job = "Cyborg"

		// final check to guarantee the icon shows up for everyone
		if(borg.mind && (ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution)))
			if ((borg.mind in ticker.mode:revolutionaries) || (borg.mind in ticker.mode:head_revolutionaries))
				ticker.mode:update_all_rev_icons() //So the icon actually appears
		borg.update_appearance()

		qdel(src)
		return

/obj/item/parts/robot_parts/robot_frame/syndicate
	syndicate = 1

// UPGRADES
// Cyborg

// AI Upgrades

/obj/item/roboupgrade/ai
	name = "AI upgrade"
	icon_state = "mod-sta"

	attack_self(var/mob/user as mob)
		if (!isAI(user))
			boutput(user, "<span class='alert'>Only an AI can use this item.</span>")
			return

	proc/slot_in(var/mob/living/silicon/ai/AI)
		if (!AI)
			return 1
		AI.installed_modules += src
		return 0

	proc/slot_out(var/mob/living/silicon/ai/AI)
		if (!AI)
			return 1
		AI.installed_modules -= src
		return 0

/*	Cogs, just uncomment this stuff when the VOX thing is ready - ISN
/obj/item/roboupgrade/ai/vox
	name = "AI VOX Module"
	desc = "A speech synthesizer module that allows the AI to make vocal announcements over the station radio system."
	icon_state = "mod-atmos"

	slot_in(var/mob/living/silicon/ai/AI)
		if (..())
			return
		AI.verbs += whatever the vox verb is i guess

	slot_out(var/mob/living/silicon/ai/AI)
		if (..())
			return
		AI.verbs -= whatever the vox verb is i guess
*/

