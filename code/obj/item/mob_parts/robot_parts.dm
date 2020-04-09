/obj/item/parts/robot_parts
	name = "robot parts"
	icon = 'icons/obj/robot_parts.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "buildpipe"
	flags = FPRINT | ONBELT | TABLEPASS | CONDUCT
	streak_decal = /obj/decal/cleanable/oil
	streak_descriptor = "oily"
	var/appearanceString = "generic"
	var/icon_state_base = ""
	module_research = list("medicine" = 1, "efficiency" = 8)
	module_research_type = /obj/item/parts/robot_parts
	accepts_normal_human_overlays = 0
	skintoned = 0

	decomp_affected = 0

	var/max_health = 100
	var/dmg_blunt = 0
	var/dmg_burns = 0
	var/speedbonus = 0 // does it help the robot move more quickly?
	var/weight = 0     // for calculating speed modifiers
	var/powerdrain = 0 // does this part consume any extra power

	stamina_damage = 35
	stamina_cost = 20
	stamina_crit_chance = 5

	examine()
		set src in oview()
		..()
		switch(ropart_get_damage_percentage(1))
			if(15 to 29) boutput(usr, "<span style=\"color:red\">It looks a bit dented and worse for wear.</span>")
			if(29 to 59) boutput(usr, "<span style=\"color:red\">It looks somewhat bashed up.</span>")
			if(60 to INFINITY) boutput(usr, "<span style=\"color:red\">It looks badly mangled.</span>")

		switch(ropart_get_damage_percentage(2))
			if(15 to 29) boutput(usr, "<span style=\"color:red\">It has some light scorch marks.</span>")
			if(29 to 59) boutput(usr, "<span style=\"color:red\">Parts of it are kind of melted.</span>")
			if(60 to INFINITY) boutput(usr, "<span style=\"color:red\">It looks terribly burnt up.</span>")

	getMobIcon(var/lying)
		if (src.standImage)
			return src.standImage

		src.standImage = image('icons/mob/human.dmi', "[src.icon_state_base]-[appearanceString]")
		return standImage

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weldingtool))
			var/obj/item/weldingtool/WELD = W
			if(!WELD.try_weld(user, 1))
				return
			if (src.ropart_get_damage_percentage(1) > 0)
				src.ropart_mend_damage(20,0)
				src.add_fingerprint(user)
				user.visible_message("<b>[user.name]</b> repairs some of the damage to [src.name].")
			else
				boutput(user, "<span style=\"color:red\">It has no structural damage to weld out.</span>")
				return
		else if(istype(W, /obj/item/cable_coil))
			var/obj/item/cable_coil/coil = W
			if (src.ropart_get_damage_percentage(1) > 0)
				src.ropart_mend_damage(0,20)
				coil.use(1)
				src.add_fingerprint(user)
				user.visible_message("<b>[user.name]</b> repairs some of the damage to [src.name]'s wiring.")
			else
				boutput(user, "<span style=\"color:red\">There's no burn damage on [src.name]'s wiring to mend.</span>")
				return
		else ..()

	surgery(var/obj/item/tool)

		var/wrong_tool = 0

		if(remove_stage > 1 && tool.type == /obj/item/staple_gun)
			remove_stage = 0

		else if(remove_stage == 0 || remove_stage == 2)
			if(istype(tool, /obj/item/scalpel) || istype(tool, /obj/item/raw_material/shard) || istype(tool, /obj/item/kitchen/utensil/knife))
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
					tool.the_mob.visible_message("<span style=\"color:red\">[tool.the_mob] staples [holder.name]'s [src.name] securely to their stump with [tool].</span>", "<span style=\"color:red\">You staple [holder.name]'s [src.name] securely to their stump with [tool].</span>")
				if(1)
					tool.the_mob.visible_message("<span style=\"color:red\">[tool.the_mob] slices through the attachment mesh of [holder.name]'s [src.name] with [tool].</span>", "<span style=\"color:red\">You slice through the attachment mesh of [holder.name]'s [src.name] with [tool].</span>")
				if(2)
					tool.the_mob.visible_message("<span style=\"color:red\">[tool.the_mob] saws through the base mount of [holder.name]'s [src.name] with [tool].</span>", "<span style=\"color:red\">You saw through the base mount of [holder.name]'s [src.name] with [tool].</span>")

					SPAWN_DBG(rand(150,200))
						if(remove_stage == 2)
							src.remove(0)
				if(3)
					tool.the_mob.visible_message("<span style=\"color:red\">[tool.the_mob] cuts through the remaining strips of material holding [holder.name]'s [src.name] on with [tool].</span>", "<span style=\"color:red\">You cut through the remaining strips of material holding [holder.name]'s [src.name] on with [tool].</span>")

					src.remove(0)

			if(!isdead(holder))
				if(prob(40))
					holder.emote("scream")
			holder.TakeDamage("chest",20,0)
			take_bleeding_damage(holder, null, 15, DAMAGE_CUT)

	proc/ropart_take_damage(var/bluntdmg = 0,var/burnsdmg = 0)
		src.dmg_blunt += bluntdmg
		src.dmg_burns += burnsdmg
		if (src.dmg_blunt + src.dmg_burns > src.max_health)
			if(src.holder) return 1 // need to do special stuff in this case, so we let the borg's melee hit take care of it
			else
				src.visible_message("<b>[src]</b> breaks!")
				playsound(get_turf(src), "sound/impact_sounds/Metal_Hit_Light_1.ogg", 40, 1)
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

/obj/item/parts/robot_parts/head
	name = "standard cyborg head"
	desc = "A serviceable head unit for a potential cyborg."
	icon = 'icons/mob/robots.dmi'
	icon_state = "head-generic"
	slot = "head"
	max_health = 175
	var/obj/item/organ/brain/brain = null
	var/obj/item/ai_interface/ai_interface = null
	var/visible_eyes = 1
	var/wires_exposed = 0
	New()
		..()
		src.pixel_y -= 8
		icon_state = "head-" + src.appearanceString

	examine()
		set src in oview()
		..()
		if (src.brain)
			boutput(usr, "<span style=\"color:blue\">This head unit has [src.brain] inside. Use a wrench if you want to remove it.</span>")
		else if (src.ai_interface)
			boutput(usr, "<span style=\"color:blue\">This head unit has [src.ai_interface] inside. Use a wrench if you want to remove it.</span>")
		else
			boutput(usr, "<span style=\"color:red\">This head unit is empty.</span>")

	attackby(obj/item/W as obj, mob/user as mob)
		if (!W)
			return
		if (istype(W,/obj/item/organ/brain))
			if (src.brain)
				boutput(user, "<span style=\"color:red\">There is already a brain in there. Use a wrench to remove it.</span>")
				return

			if (src.ai_interface)
				boutput(user, "<span style=\"color:red\">There is already \an [src.ai_interface] in there. Use a wrench to remove it.</span>")
				return

			if (src.wires_exposed)
				user.show_text("You can't add the brain to this head when the wires are exposed. Use a screwdriver to pack them away.", "red")
				return

			var/obj/item/organ/brain/B = W
			if ( !(B.owner && B.owner.key) && !istype(W, /obj/item/organ/brain/latejoin) )
				boutput(user, "<span style=\"color:red\">This brain doesn't look any good to use.</span>")
				return
			else if ( B.owner  &&  (jobban_isbanned(B.owner.current,"Cyborg") || B.owner.dnr) ) //If the borg-to-be is jobbanned or has DNR set
				boutput(user, "<span style=\"color:red\">The brain disintigrates in your hands!</span>")
				user.drop_item()
				qdel(B)
				var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
				smoke.set_up(1, 0, user.loc)
				smoke.start()
				return
			user.drop_item()
			B.set_loc(src)
			src.brain = B
			boutput(user, "<span style=\"color:blue\">You insert the brain.</span>")
			playsound(get_turf(src), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)
			return

		else if (istype(W, /obj/item/ai_interface))
			if (src.brain)
				boutput(user, "<span style=\"color:red\">There is already a brain in there. Use a wrench to remove it.</span>")
				return

			if (src.ai_interface)
				boutput(user, "<span style=\"color:red\">There is already \an [src.ai_interface] in there!</span>")
				return

			if (src.wires_exposed)
				user.show_text("You can't add [W] to this head when the wires are exposed. Use a screwdriver to pack them away.", "red")
				return

			var/obj/item/ai_interface/I = W
			user.drop_item()
			I.set_loc(src)
			src.ai_interface = I
			boutput(user, "<span style=\"color:blue\">You insert [I].</span>")
			playsound(get_turf(src), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)
			return

		else if (iswrenchingtool(W))
			if (!src.brain && !src.ai_interface)
				boutput(user, "<span style=\"color:red\">There's no brain or AI interface chip in there to remove.</span>")
				return
			playsound(get_turf(src), "sound/items/Ratchet.ogg", 40, 1)
			if (src.ai_interface)
				boutput(user, "<span style=\"color:blue\">You open the head's compartment and take out [src.ai_interface].</span>")
				user.put_in_hand_or_drop(src.ai_interface)
				src.ai_interface = null
			else if (src.brain)
				boutput(user, "<span style=\"color:blue\">You open the head's compartment and take out [src.brain].</span>")
				user.put_in_hand_or_drop(src.brain)
				src.brain = null
		else if (isscrewingtool(W))
			if (src.brain)
				user.show_text("You can't reach the wiring with a brain inside the cyborg head.", "red")
				return
			if (src.ai_interface)
				user.show_text("You can't reach the wiring with [src.ai_interface] inside the cyborg head.", "red")
				return

			if (src.appearanceString != "generic") //Fuck my shit
				user.show_text("The screws on this head have some kinda proprietary bitting. Huh.", "red")
				return

			src.wires_exposed = !src.wires_exposed
			if (src.wires_exposed)
				icon_state = "head-generic-wiresexposed"
				user.show_text("You expose the wiring of the head's neural interface.", "red")
			else
				icon_state = "head-generic"
				user.show_text("You neatly tuck the wiring of the head's neural interface away.", "red")

		else if (istype(W,/obj/item/sheet) && (src.type == /obj/item/parts/robot_parts/head))
			// second check up there is just watching out for those ..() calls
			var/obj/item/sheet/M = W
			if (M.amount >= 2)
				boutput(user, "<span style=\"color:blue\">You reinforce [src.name] with the metal.</span>")
				var/obj/item/parts/robot_parts/head/sturdy/newhead = new /obj/item/parts/robot_parts/head/sturdy(get_turf(src))
				M.amount -= 2
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
				boutput(user, "<span style=\"color:red\">You need at least two metal sheets to reinforce this component.</span>")
				return

		else
			..()

/obj/item/parts/robot_parts/head/sturdy
	name = "sturdy cyborg head"
	desc = "A reinforced head unit capable of taking more abuse than usual."
	appearanceString = "sturdy"
	max_health = 225
	weight = 0.2

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W,/obj/item/sheet) && (src.type == /obj/item/parts/robot_parts/head/sturdy))
			var/obj/item/sheet/M = W
			if (!M.reinforcement)
				boutput(user, "<span style=\"color:red\">You'll need reinforced sheets to reinforce the head.</span>")
				return
			if (M.amount >= 2)
				boutput(user, "<span style=\"color:blue\">You reinforce [src.name] with the reinforced metal.</span>")
				var/obj/item/parts/robot_parts/head/heavy/newhead = new /obj/item/parts/robot_parts/head/heavy(get_turf(src))
				M.amount -= 2
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
				boutput(user, "<span style=\"color:red\">You need at least two reinforced metal sheets to reinforce this component.</span>")
				return
		else if (istype(W, /obj/item/weldingtool))
			if(!W:try_weld(user, 1))
				return
			boutput(user, "<span style=\"color:blue\">You remove the reinforcement metals from [src].</span>")
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
	max_health = 350
	weight = 0.4

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weldingtool))
			if(!W:try_weld(user, 1))
				return
			boutput(user, "<span style=\"color:blue\">You remove the reinforcement metals from [src].</span>")
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
	max_health = 50
	speedbonus = 0.2

/obj/item/parts/robot_parts/head/antique
	name = "antique cyborg head"
	desc = "Looks like a discarded prop from some sorta low-budget scifi movie."
	appearanceString = "android"
	max_health = 150
	speedbonus = 0.2
	visible_eyes = 0

/obj/item/parts/robot_parts/chest
	name = "standard cyborg chest"
	desc = "The centerpiece of any cyborg. It wouldn't get very far without it."
	icon_state = "chest"
	slot = "chest"
	max_health = 250
	var/wires = 0
	var/obj/item/cell/cell = null

	examine()
		set src in oview()
		..()
		if (src.cell) boutput(usr, "<span style=\"color:blue\">This chest unit has a [src.cell] installed. Use a wrench if you want to remove it.</span>")
		else boutput(usr, "<span style=\"color:red\">This chest unit has no power cell.</span>")
		if (src.wires) boutput(usr, "<span style=\"color:blue\">This chest unit has had wiring installed.</span>")
		else boutput(usr, "<span style=\"color:red\">This chest unit has not yet been wired up.</span>")

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/cell))
			if(src.cell)
				boutput(user, "<span style=\"color:red\">You have already inserted a cell!</span>")
				return
			else
				user.drop_item()
				W.set_loc(src)
				src.cell = W
				boutput(user, "<span style=\"color:blue\">You insert [W].</span>")
				playsound(get_turf(src), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)

		else if(istype(W, /obj/item/cable_coil))
			if (src.ropart_get_damage_percentage(2) > 0) ..()
			else
				if(src.wires)
					boutput(user, "<span style=\"color:red\">You have already inserted some wire!</span>")
					return
				else
					var/obj/item/cable_coil/coil = W
					coil.use(1)
					src.wires = 1
					boutput(user, "<span style=\"color:blue\">You insert some wire.</span>")
					playsound(get_turf(src), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)

		else if (iswrenchingtool(W))
			if(!src.cell)
				boutput(user, "<span style=\"color:red\">There's no cell in there to remove.</span>")
				return
			playsound(get_turf(src), "sound/items/Ratchet.ogg", 40, 1)
			boutput(user, "<span style=\"color:blue\">You remove the cell from it's slot in the chest unit.</span>")
			src.cell.set_loc( get_turf(src) )
			src.cell = null

		else if (issnippingtool(W))
			if(src.wires < 1)
				boutput(user, "<span style=\"color:red\">There's no wiring in there to remove.</span>")
				return
			playsound(get_turf(src), "sound/items/Wirecutter.ogg", 40, 1)
			boutput(user, "<span style=\"color:blue\">You cut out the wires and remove them from the chest unit.</span>")
			// i don't know why this would get abused
			// but it probably will
			// when that happens
			// tell past me i'm saying hello
			var/obj/item/cable_coil/cut/C = new /obj/item/cable_coil/cut(src.loc)
			C.amount = src.wires
			src.wires = 0
		else ..()

/obj/item/parts/robot_parts/chest/light
	name = "light cyborg chest"
	desc = "A bare-bones cyborg chest designed for the least consumption of resources."
	appearanceString = "light"
	max_health = 75

/obj/item/parts/robot_parts/arm
	name = "placeholder item (don't use this!)"
	desc = "A metal arm for a cyborg. It won't be able to use as many tools without it!"
	max_health = 60
	can_hold_items = 1
	accepts_normal_human_overlays = 1

	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if(!ismob(M))
			return

		src.add_fingerprint(user)

		if(!(user.zone_sel.selecting in list("l_arm","r_arm")) || !ishuman(M))
			return ..()

		if (!surgeryCheck(M,user))
			return ..()

		var/mob/living/carbon/human/H = M

		if(H.limbs.vars.Find(src.slot) && H.limbs.vars[src.slot])
			boutput(user, "<span style=\"color:red\">[H.name] already has one of those!</span>")
			return

		if(src.appearanceString == "sturdy" || src.appearanceString == "heavy")
			boutput(user, "<span style=\"color:red\">That arm is too big to fit on [H]'s body!</span>")
			return

		attach(H,user)

		return

	attackby(obj/item/W as obj, mob/user as mob)
		//gonna hack this in with appearanceString
		if ((appearanceString == "sturdy" || appearanceString == "heavy") && istype(W, /obj/item/weldingtool))
			if(!W:try_weld(user, 1))
				return
			boutput(user, "<span style=\"color:blue\">You remove the reinforcement metals from [src].</span>")

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

/obj/item/parts/robot_parts/arm/left
	name = "standard cyborg left arm"
	icon_state = "l_arm"
	slot = "l_arm"
	icon_state_base = "armL"
	handlistPart = "armL-generic"

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/sheet) && ((src.type == /obj/item/parts/robot_parts/arm/left)))
			// second check up there is just watching out for those ..() calls
			var/obj/item/sheet/M = W
			if (M.amount >= 2)
				boutput(user, "<span style=\"color:blue\">You reinforce [src.name] with the metal.</span>")
				new /obj/item/parts/robot_parts/arm/left/sturdy(get_turf(src))
				M.amount -= 2
				if (M.amount < 1)
					user.drop_item()
					del(M)
				del(src)
				return
			else
				boutput(user, "<span style=\"color:red\">You need at least two metal sheets to reinforce this component.</span>")
				return
		else ..()

/obj/item/parts/robot_parts/arm/left/sturdy
	name = "sturdy cyborg left arm"
	appearanceString = "sturdy"
	max_health = 100
	weight = 0.2

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/sheet) && (src.type == /obj/item/parts/robot_parts/arm/left/sturdy))
			// second check up there is just watching out for those ..() calls
			var/obj/item/sheet/M = W
			if (!M.reinforcement)
				boutput(user, "<span style=\"color:red\">You'll need reinforced sheets to reinforce the [src.name].</span>")
				return
			if (M.amount >= 2)
				boutput(user, "<span style=\"color:blue\">You reinforce [src.name] with the reinforced metal.</span>")
				new /obj/item/parts/robot_parts/arm/left/heavy(get_turf(src))
				M.amount -= 2
				if (M.amount < 1)
					user.drop_item()
					del(M)
				del(src)
				return
			else
				boutput(user, "<span style=\"color:red\">You need at least two reinforced metal sheets to reinforce this component.</span>")
				return
		else ..()

/obj/item/parts/robot_parts/arm/left/heavy
	name = "heavy cyborg left arm"
	appearanceString = "heavy"
	max_health = 175
	weight = 0.4

/obj/item/parts/robot_parts/arm/left/light
	name = "light cyborg left arm"
	appearanceString = "light"
	max_health = 25
	speedbonus = 0.2
	handlistPart = "armL-light"

/obj/item/parts/robot_parts/arm/right
	name = "standard cyborg right arm"
	icon_state = "r_arm"
	slot = "r_arm"
	icon_state_base = "armR"
	handlistPart = "armR-generic"

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/sheet) && (src.type == /obj/item/parts/robot_parts/arm/right))
			// second check up there is just watching out for those ..() calls
			var/obj/item/sheet/M = W
			if (M.amount >= 2)
				boutput(user, "<span style=\"color:blue\">You reinforce [src.name] with the metal.</span>")
				new /obj/item/parts/robot_parts/arm/right/sturdy(get_turf(src))
				M.amount -= 2
				if (M.amount < 1)
					user.drop_item()
					del(M)
				del(src)
				return
			else
				boutput(user, "<span style=\"color:red\">You need at least two metal sheets to reinforce this component.</span>")
				return
		else ..()

/obj/item/parts/robot_parts/arm/right/sturdy
	name = "sturdy cyborg right arm"
	appearanceString = "sturdy"
	max_health = 100
	weight = 0.2

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/sheet) && (src.type == /obj/item/parts/robot_parts/arm/right/sturdy))
			// second check up there is just watching out for those ..() calls
			var/obj/item/sheet/M = W
			if (!M.reinforcement)
				boutput(user, "<span style=\"color:red\">You'll need reinforced sheets to reinforce the [src.name].</span>")
				return
			if (M.amount >= 2)
				boutput(user, "<span style=\"color:blue\">You reinforce [src.name] with the reinforced metal.</span>")
				new /obj/item/parts/robot_parts/arm/right/heavy(get_turf(src))
				M.amount -= 2
				if (M.amount < 1)
					user.drop_item()
					del(M)
				del(src)
				return
			else
				boutput(user, "<span style=\"color:red\">You need at least two reinforced metal sheets to reinforce this component.</span>")
				return
		else ..()

/obj/item/parts/robot_parts/arm/right/heavy
	name = "heavy cyborg right arm"
	appearanceString = "heavy"
	max_health = 175
	weight = 0.4

/obj/item/parts/robot_parts/arm/right/light
	name = "light cyborg right arm"
	appearanceString = "light"
	max_health = 25
	speedbonus = 0.2
	handlistPart = "armR-light"

/obj/item/parts/robot_parts/leg
	name = "placeholder item (don't use this!)"
	desc = "A metal leg for a cyborg. It won't be able to move very well without this!"
	max_health = 60
	effect_modifier = 0.2
	var/step_sound = "step_robo"
	var/step_priority = STEP_PRIORITY_LOW

	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if(!ismob(M))
			return

		src.add_fingerprint(user)

		if(!(user.zone_sel.selecting in list("l_leg","r_leg")) || !ishuman(M))
			return ..()

		if (!surgeryCheck(M,user))
			return ..()

		var/mob/living/carbon/human/H = M

		if(!(src.slot in H.limbs.vars))
			boutput(user, "<span style=\"color:red\">You can't find a way to fit that on.</span>")
			return

		if(H.limbs.vars[src.slot])
			boutput(user, "<span style=\"color:red\">[H.name] already has one of those!</span>")
			return

		if(src.appearanceString == "sturdy" || src.appearanceString == "heavy" || src.appearanceString == "thruster")
			boutput(user, "<span style=\"color:red\">That leg is too big to fit on [H]'s body!</span>")
			return
/*
		if(src.appearanceString == "treads" && (H.limbs.l_leg || H.limbs.r_leg))
			boutput(user, "<span style=\"color:red\">Both of [H]'s legs must be removed to fit them with treads!</span>")
			return
*/
		attach(H,user)

		return

	attackby(obj/item/W as obj, mob/user as mob)
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
			boutput(user, "<span style=\"color:blue\">You add [W] to [src]. That's neat.</span>")
			qdel(W)
			qdel(src)
			return

		else
			return ..()

	on_holder_examine()
		if (!isrobot(src.holder)) // probably a human, probably  :p
			return "has [bicon(src)] \an [initial(src.name)] attached as a"
		return

/obj/item/parts/robot_parts/leg/left
	name = "standard cyborg left leg"
	icon_state = "l_leg"
	slot = "l_leg"
	icon_state_base = "legL"
	step_image_state = "footprintsL"

/obj/item/parts/robot_parts/leg/left/light
	name = "light cyborg left leg"
	appearanceString = "light"
	max_health = 25
	speedbonus = 0.2

/obj/item/parts/robot_parts/leg/left/treads
	name = "left cyborg tread"
	desc = "A large wheeled unit like tank tracks. This will help heavier cyborgs to move quickly."
	icon_state = "l_lower_t"
	appearanceString = "treads"
	max_health = 100
	speedbonus = 0.25
	powerdrain = 2.5
	step_image_state = "tracksL"
	effect_modifier = 0.25

/obj/item/parts/robot_parts/leg/right
	name = "standard cyborg right leg"
	icon_state = "r_leg"
	slot = "r_leg"
	icon_state_base = "legR"
	step_image_state = "footprintsR"

/obj/item/parts/robot_parts/leg/right/light
	name = "light cyborg right leg"
	appearanceString = "light"
	max_health = 25
	speedbonus = 0.2

/obj/item/parts/robot_parts/leg/right/treads
	name = "right cyborg tread"
	desc = "A large wheeled unit like tank tracks. This will help heavier cyborgs to move quickly."
	icon_state = "r_lower_t"
	appearanceString = "treads"
	max_health = 100
	speedbonus = 0.25
	powerdrain = 2.5
	step_image_state = "tracksR"
	effect_modifier = 0.25

/obj/item/parts/robot_parts/leg/treads
	name = "cyborg treads"
	desc = "A large wheeled unit like tank tracks. This will help heavier cyborgs to move quickly."
	icon_state = "lower_t"
	slot = "leg_both"
	appearanceString = "treads"
	max_health = 100
	speedbonus = 0.5
	powerdrain = 5
	step_image_state = "tracks-w"
	effect_modifier = 0.25

/obj/item/parts/robot_parts/leg/thruster
	name = "Alastor pattern thruster"
	desc = "Nobody said this is safe."
	icon_state = "lower_thruster"
	slot = "leg_both"
	appearanceString = "thruster"
	max_health = 100
	speedbonus = 0.5
	powerdrain = 5
	step_image_state = null //It's flying so no need for this.

/obj/item/parts/robot_parts/leg/left/thruster
	name = "left thruster assembly"
	desc = "Is it really a good idea to give thrusters to cyborgs..? Probably not."
	icon_state = "l_lower_thruster"
	appearanceString = "thruster"
	max_health = 100
	speedbonus = 0.3
	powerdrain = 5
	step_image_state = null //It's flying so no need for this.

/obj/item/parts/robot_parts/leg/right/thruster
	name = "right thruster assembly"
	desc = "Is it really a good idea to give thrusters to cyborgs..? Probably not."
	icon_state = "r_lower_thruster"
	appearanceString = "thruster"
	max_health = 100
	speedbonus = 0.3
	powerdrain = 5
	step_image_state = null //It's flying so no need for this.

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
		src.updateicon()

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if(!emagged)
			emagged = 1
			if (user)
				logTheThing("station", user, null, "emags a robot frame at [log_loc(user)].")
				boutput(user, "<span style=\"color:blue\">You short out the behavior restrictors on the frame's motherboard.</span>")
			return 1
		else if(user)
			boutput(user, "<span style=\"color:red\">This frame's behavior restrictors have already been shorted out.</span>")
		return 0

	demag(var/mob/user)
		if (!emagged)
			return 0
		if (user)
			user.show_text("You repair the behavior restrictors on the frame's motherboard.", "blue")
		emagged = 0
		return 1

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/parts/robot_parts/))
			var/obj/item/parts/robot_parts/P = W
			switch (P.slot)
				if ("head")
					if (src.head)
						boutput(user, "<span style=\"color:red\">There is already a head piece on the frame. If you want to remove it, use a wrench.</span>")
						return
					var/obj/item/parts/robot_parts/head/H = P
					if (!H.brain && !H.ai_interface)
						boutput(user, "<span style=\"color:red\">You need to insert a brain or an AI interface into the head piece before attaching it to the frame.</span>")
						return
					src.head = H

				if ("chest")
					if (src.chest)
						boutput(user, "<span style=\"color:red\">There is already a chest piece on the frame. If you want to remove it, use a wrench.</span>")
						return
					var/obj/item/parts/robot_parts/chest/C = P
					if (!C.wires)
						boutput(user, "<span style=\"color:red\">You need to add wiring to the chest piece before attaching it to the frame.</span>")
						return
					if (!C.cell)
						boutput(user, "<span style=\"color:red\">You need to add a power cell to the chest piece before attaching it to the frame.</span>")
						return
					src.chest = C

				if ("l_arm")
					if (src.l_arm)
						boutput(user, "<span style=\"color:red\">There is already a left arm piece on the frame. If you want to remove it, use a wrench.</span>")
						return
					src.l_arm = P

				if ("r_arm")
					if (src.r_arm)
						boutput(user, "<span style=\"color:red\">There is already a right arm piece on the frame. If you want to remove it, use a wrench.</span>")
						return
					src.r_arm = P

				if ("arm_both")
					if (src.l_arm || src.r_arm)
						boutput(user, "<span style=\"color:red\">There is already an arm piece on the frame that occupies both arm mountings. If you want to remove it, use a wrench.</span>")
						return
					src.l_arm = P
					src.r_arm = P

				if ("l_leg")
					if (src.l_leg)
						boutput(user, "<span style=\"color:red\">There is already a left leg piece on the frame. If you want to remove it, use a wrench.</span>")
						return
					src.l_leg = P

				if ("r_leg")
					if (src.r_leg)
						boutput(user, "<span style=\"color:red\">There is already a right leg piece on the frame. If you want to remove it, use a wrench.</span>")
						return
					src.r_leg = P

				if ("leg_both")
					if (src.l_leg || src.r_leg)
						boutput(user, "<span style=\"color:red\">There is already a leg piece on the frame that occupies both leg mountings. If you want to remove it, use a wrench.</span>")
						return
					src.l_leg = P
					src.r_leg = P

				else
					boutput(user, "<span style=\"color:red\">You can't seem to fit this piece anywhere on the frame.</span>")
					return

			playsound(get_turf(src), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)
			boutput(user, "<span style=\"color:blue\">You add [P] to the frame.</span>")
			user.drop_item()
			P.set_loc(src)
			src.updateicon()

		if (istype(W, /obj/item/organ/brain))
			boutput(user, "<span style=\"color:red\">The brain needs to go in the head piece, not the frame.</span>")
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
				boutput(user, "<span style=\"color:red\">You can't think of anything to do with the frame.</span>")
				return

			var/action = input("What do you want to do?", "Robot Frame") in actions
			if (!action)
				return
			if (action == "Do nothing")
				return
			if (get_dist(src.loc,user.loc) > 1 && !user.bioHolder.HasEffect("telekinesis"))
				boutput(user, "<span style=\"color:red\">You need to move closer!</span>")
				return

			switch(action)
				if("Finish and Activate the Cyborg")
					user.unlock_medal("Weird Science", 1)
					src.finish_cyborg()
				if("Remove the Right leg")
					src.r_leg.set_loc( get_turf(src) )
					if (src.r_leg.slot == "leg_both")
						src.r_leg = null
						src.l_leg = null
					else src.r_leg = null
				if("Remove the Left leg")
					src.l_leg.set_loc( get_turf(src) )
					if (src.l_leg.slot == "leg_both")
						src.r_leg = null
						src.l_leg = null
					else src.l_leg = null
				if("Remove the Right arm")
					src.r_arm.set_loc( get_turf(src) )
					if (src.r_arm.slot == "arm_both")
						src.r_arm = null
						src.l_arm = null
					else src.r_arm = null
				if("Remove the Left arm")
					src.l_arm.set_loc( get_turf(src) )
					if (src.l_arm.slot == "arm_both")
						src.r_arm = null
						src.l_arm = null
					else src.l_arm = null
				if("Remove the Head")
					src.head.set_loc( get_turf(src) )
					src.head = null
				if("Remove the Chest")
					src.chest.set_loc( get_turf(src) )
					src.chest = null
			playsound(get_turf(src), "sound/items/Ratchet.ogg", 40, 1)
			src.updateicon()
			return

	proc/updateicon()
		src.overlays = null
		if(src.chest) src.overlays += image('icons/mob/robots.dmi', "body-" + src.chest.appearanceString, OBJ_LAYER, 2)
		if(src.head) src.overlays += image('icons/mob/robots.dmi', "head-" + src.head.appearanceString, OBJ_LAYER, 2)

		if(src.l_leg)
			if(src.l_leg.slot == "leg_both") src.overlays += image('icons/mob/robots.dmi', "leg-" + src.l_leg.appearanceString, OBJ_LAYER, 2)
			else src.overlays += image('icons/mob/robots.dmi', "legL-" + src.l_leg.appearanceString, OBJ_LAYER, 2)

		if(src.r_leg)
			if(src.r_leg.slot == "leg_both") src.overlays += image('icons/mob/robots.dmi', "leg-" + src.r_leg.appearanceString, OBJ_LAYER, 2)
			else src.overlays += image('icons/mob/robots.dmi', "legR-" + src.r_leg.appearanceString, OBJ_LAYER, 2)

		if(src.l_arm)
			if(src.l_arm.slot == "arm_both") src.overlays += image('icons/mob/robots.dmi', "arm-" + src.l_arm.appearanceString, OBJ_LAYER, 2)
			else src.overlays += image('icons/mob/robots.dmi', "armL-" + src.l_arm.appearanceString, OBJ_LAYER, 2)

		if(src.r_arm)
			if(src.r_arm.slot == "arm_both") src.overlays += image('icons/mob/robots.dmi', "arm-" + src.r_arm.appearanceString, OBJ_LAYER, 2)
			else src.overlays += image('icons/mob/robots.dmi', "armR-" + src.r_arm.appearanceString, OBJ_LAYER, 2)

	proc/check_completion()
		if (src.chest && src.head)
			if (src.head.brain)
				return 1
			if (src.head.ai_interface)
				return 1
		return 0

	proc/collapse_to_pieces()
		src.visible_message("<b>[src]</b> falls apart into a pile of components!")
		. = get_turf(src)
		for(var/obj/item/O in src.contents) O.set_loc( . )
		src.chest = null
		src.head = null
		src.l_arm = null
		src.r_arm = null
		src.l_leg = null
		src.r_leg = null
		src.updateicon()
		return

	proc/finish_cyborg()
		var/mob/living/silicon/robot/O = null
		O = new /mob/living/silicon/robot(get_turf(src.loc),src,0,src.syndicate,src.emagged)
		// there was a big transferring list of parts from the frame to the compborg here at one point, but it didn't work
		// because the cyborg's process proc would kill it for having no chest piece set up after New() finished but
		// before it could get around to this list, so i tweaked their New() proc instead to grab all the shit out of
		// the frame before process could go off resulting in a borg that doesn't instantly die

		O.invisibility = 0
		O.name = "Cyborg"
		O.real_name = "Cyborg"

		if (src.head)
			if (src.head.brain)
				O.brain = src.head.brain
			else if (src.head.ai_interface)
				O.ai_interface = src.head.ai_interface
			else
				src.collapse_to_pieces()
				qdel(O)
				return
		else
			// how the fuck did you even do this
			src.collapse_to_pieces()
			qdel(O)
			return

		if(O.brain && O.brain.owner && O.brain.owner.key)
			if(O.brain.owner.current)
				O.gender = O.brain.owner.current.gender
				if(O.brain.owner.current.client)
					O.lastKnownIP = O.brain.owner.current.client.address
			if(istype(get_area(O.brain.owner.current),/area/afterlife/bar))
				boutput("<span style=\"color:blue\">,You feel yourself being pulled out of the afterlife!</span>")
				var/mob/old = O.brain.owner.current
				O.brain.owner = O.brain.owner.current.ghostize().mind
				qdel(old)
			O.brain.owner.transfer_to(O)
		else if (O.ai_interface)
			if (!(O in available_ai_shells))
				available_ai_shells += O
			for (var/mob/living/silicon/ai/AI in AIs)
				boutput(AI, "<span style=\"color:green\">[src] has been connected to you as a controllable shell.</span>")
			O.shell = 1
		else if (istype(O.brain, /obj/item/organ/brain/latejoin))
			boutput(usr, "<span> You activate the frame and a audible beep emanates from the head.</span>")
			playsound(get_turf(src), "sound/weapons/radxbow.ogg", 40, 1)
		else
			src.collapse_to_pieces()
			qdel(O)
			return

		if (src.chest && src.chest.cell)
			O.cell = src.chest.cell
			O.cell.set_loc(O)

		if (O.mind && !O.ai_interface)
			O.unlock_medal("Adjutant Online", 1)
			O.set_loc(get_turf(src))
			var/area/A = get_area(src)
			if (A)
				A.Entered(O)

			boutput(O, "<B>You are playing a Robot. The Robot can interact with most electronic objects in its view point.</B>")
			boutput(O, "To use something, simply double-click it.")
			boutput(O, "Use say \":s to speak to fellow cyborgs and the AI through binary.")

			if (src.emagged || src.syndicate)
				if ((ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/revolution)) && O.mind)
					ticker.mode:revolutionaries += O.mind
					ticker.mode:update_rev_icons_added(O.mind)
				if (src.emagged)
					O.emagged = 1
					SPAWN_DBG(0)
						O.update_appearance()
				else if (src.syndicate)
					O.syndicate = 1
				O.handle_robot_antagonist_status("activated", 0, usr)
			else
				boutput(O, "<B>You must follow the AI's laws to the best of your ability.</B>")
				O.show_laws() // The antagonist proc does that too.

			O.job = "Cyborg"

		// final check to guarantee the icon shows up for everyone
		if(O.mind && (ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/revolution)))
			if ((O.mind in ticker.mode:revolutionaries) || (O.mind in ticker.mode:head_revolutionaries))
				ticker.mode:update_all_rev_icons() //So the icon actually appears
		O.update_appearance()

		qdel(src)
		return

/obj/item/parts/robot_parts/robot_frame/syndicate
	syndicate = 1

// UPGRADES
// Cyborg

/obj/item/roboupgrade
	name = "robot upgrade"
	desc = "you shouldnt be able to see this!"
	icon = 'icons/obj/robot_parts.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "electronic"
	var/active = 0 // Is this module used like an item?
	var/passive = 0 // Does this module always work once installed?
	var/activated = 0 // live ingame variable
	var/drainrate = 0 // How much charge the upgrade consumes while installed
	var/charges = -1 // How many times a limited upgrade can be used before it is consumed (infinite if negative)
	var/removable = 1 // Can be removed from the cyborg
	var/borg_overlay = null // Used for cyborg update_apperance proc

	attack_self(var/mob/user as mob)
		if (!isrobot(user))
			boutput(user, "<span style=\"color:red\">Only cyborgs can activate this item.</span>")
		else
			if (!src.activated)
				upgrade_activate()
			else
				upgrade_deactivate()

	proc/upgrade_activate(var/mob/living/silicon/robot/user as mob)
		if (!user)
			return 1
		if (!src.activated)
			src.activated = 1

	proc/upgrade_deactivate(var/mob/living/silicon/robot/user as mob)
		if (!user)
			return 1
		src.activated = 0

/obj/item/roboupgrade/jetpack
	name = "Propulsion Upgrade"
	desc = "A small turbine allowing cyborgs to move freely in space."
	icon_state = "up-jetpack"
	drainrate = 25
	borg_overlay = "up-jetpack"

	upgrade_activate(var/mob/living/silicon/robot/user as mob)
		if (..()) return
		user.jetpack = 1

	upgrade_deactivate(var/mob/living/silicon/robot/user as mob)
		if (..()) return
		user.jetpack = 0

/obj/item/roboupgrade/healthgoggles
	name = "ProDoc Healthgoggles Upgrade"
	desc = "Fitted with an advanced miniature sensor array that allows the user to quickly determine the physical condition of others."
	icon_state = "up-prodoc"
	var/client/assigned = null
	drainrate = 5

	New()
		//updateIcons()
		return ..()

	proc/updateIcons() //I wouldve liked to avoid this but i dont want to put this inside the mobs life proc as that would be more code.
		while (assigned)
			assigned.images.Remove(health_mon_icons)
			addIcons()

			if(loc != assigned.mob)
				assigned.images.Remove(health_mon_icons)
				assigned = null

			sleep(20)

	proc/addIcons()
		if(assigned)
			for(var/image/I in health_mon_icons)
				if(!I || !I.loc || !src)
					continue
				if(I.loc.invisibility && I.loc != src.loc)
					continue
				else assigned.images.Add(I)

	upgrade_activate(var/mob/living/silicon/robot/user as mob)
		if (..()) return
		assigned = user.client
		SPAWN_DBG(-1) updateIcons()
		return

	upgrade_deactivate(var/mob/living/silicon/robot/user as mob)
		if (..()) return
		if(assigned)
			assigned.images.Remove(health_mon_icons)
			assigned = null
		return

/obj/item/roboupgrade/spectro
	name = "Spectroscopic Scanner Upgrade"
	desc = "Fitted with a sensor array that provides a readout of the chemical composition of substances that are examined."
	icon_state = "up-spectro"
	drainrate = 5

/obj/item/roboupgrade/efficiency
	name = "Efficiency Upgrade"
	desc = "A more advanced cooling system that causes cyborgs to consume less cell charge."
	icon_state = "up-power"
	passive = 1

/obj/item/roboupgrade/speed
	name = "Speed Upgrade"
	desc = "A booster unit that safely allows cyborgs to move at high speed."
	icon_state = "up-speed"
	drainrate = 100
	borg_overlay = "up-speed"

	upgrade_activate(var/mob/living/silicon/robot/user as mob)
		if (!user) return
		var/mob/living/silicon/robot/R = user
		if (!R.part_leg_r && !R.part_leg_l)
			boutput(user, "This upgrade cannot be used when you have no legs!")
			src.activated = 0
		else ..()

/obj/item/roboupgrade/physshield
	name = "Force Shield Upgrade"
	desc = "A force field generator that protects cyborgs from structural damage."
	icon_state = "up-Pshield"
	drainrate = 100
	borg_overlay = "up-pshield"

/obj/item/roboupgrade/fireshield
	name = "Heat Shield Upgrade"
	desc = "An air diffusion field that protects cyborgs from heat damage."
	icon_state = "up-Fshield"
	drainrate = 100
	borg_overlay = "up-fshield"

/obj/item/roboupgrade/teleport
	name = "Teleporter Upgrade"
	desc = "A personal teleportation device that allows a cyborg to transport itself instantly."
	icon_state = "up-teleport"
	active = 1
	drainrate = 250

	upgrade_activate(var/mob/living/silicon/robot/user as mob)
		if (!user || !src || src.loc != user || !issilicon(user) || !src.active)
			return
		if (user.getStatusDuration("stunned") > 0 || user.getStatusDuration("weakened") || user.getStatusDuration("paralysis") >  0 || !isalive(user))
			user.show_text("Not when you're incapacitated.", "red")
			return
		if (!isturf(user.loc))
			user.show_text("You can't teleport from inside a container.", "red")
			return

		var/list/L = list()
		var/list/areaindex = list()
		for(var/obj/item/device/radio/beacon/R in tracking_beacons)//world)
			if (!istype(R, /obj/item/device/radio/beacon/jones))
				LAGCHECK(LAG_LOW)
				var/turf/T = find_loc(R)
				if (!T)	continue

				var/tmpname = T.loc.name
				if(areaindex[tmpname]) tmpname = "[tmpname] ([++areaindex[tmpname]])"
				else areaindex[tmpname] = 1
				L[tmpname] = R

		for (var/obj/item/implant/tracking/I in tracking_implants)//world)
			LAGCHECK(LAG_LOW)
			if (!I.implanted || !ismob(I.loc)) continue
			else
				var/mob/M = I.loc
				if (isdead(M))
					if (M.timeofdeath + 6000 < world.time) continue
				var/tmpname = M.real_name
				if(areaindex[tmpname]) tmpname = "[tmpname] ([++areaindex[tmpname]])"
				else areaindex[tmpname] = 1
				L[tmpname] = I

		var/desc = input("Area to jump to","Teleportation") in L

		if (!user || !src || src.loc != user || !issilicon(user))
			if (user) user.show_text("Teleportation failed.", "red")
			return
		if (user.mind && user.mind.current != src.loc) // Debrained or whatever.
			user.show_text("Teleportation failed.", "red")
			return
		if (user.getStatusDuration("stunned") || getStatusDuration("weakened") || user.getStatusDuration("paralysis") >  0 || !isalive(user))
			user.show_text("Not when you're incapacitated.", "red")
			return
		if (!src.active)
			user.show_text("Cannot teleport, upgrade is inactive.", "red")
			return
		if (!desc || !L[desc])
			user.show_text("Invalid selection.", "red")
			return
		if (!isturf(user.loc))
			user.show_text("You can't teleport from inside a container.", "red")
			return

		do_teleport(user,L[desc],0)
		return

/obj/item/roboupgrade/repair
	name = "Self-Repair Upgrade"
	desc = "An infusion of nanobots that allow a cyborg to automatically repair sustained damage."
	icon_state = "up-repair"
	drainrate = 60
	borg_overlay = "up-repair"

/obj/item/roboupgrade/aware
	name = "Recovery Upgrade"
	desc = "Allows a cyborg to immediatley reboot its systems if incapacitated in any way."
	icon_state = "up-aware"
	active = 1
	drainrate = 3333 //Was 100. jfc

	upgrade_activate(var/mob/living/silicon/robot/user as mob)
		if (!user) return
		boutput(user, "<b>REBOOTING...</b>")
		user.delStatus("stunned")
		user.delStatus("weakened")
		user.delStatus("paralysis")
		user.blinded = 0
		user.take_eye_damage(-INFINITY)
		user.take_eye_damage(-INFINITY, 1)
		user.blinded = 0
		user.take_ear_damage(-INFINITY)
		user.take_ear_damage(-INFINITY, 1)
		user.change_eye_blurry(-INFINITY)
		user.druggy = 0
		user.change_misstep_chance(-INFINITY)
		user.dizziness = 0

		boutput(user, "<b>REBOOT COMPLETE</b>")

/obj/item/roboupgrade/expand
	name = "Expansion Upgrade"
	desc = "A matter miniaturizer that frees up room in a cyborg for more upgrades."
	icon_state = "up-expand"
	active = 1
	charges = 1

	upgrade_activate(var/mob/living/silicon/robot/user as mob)
		if (!user || src.qdeled) return
		user.max_upgrades++
		boutput(user, "<span style=\"color:blue\">You can now hold up to [user.max_upgrades] upgrades!</span>")
		user.upgrades.Remove(src)
		qdel(src)

/obj/item/roboupgrade/rechargepack
	name = "Recharge Pack"
	desc = "A single-use reserve battery that can recharge a cyborg's cell to full capacity."
	icon_state = "up-recharge"
	active = 1
	charges = 1

	upgrade_activate(var/mob/living/silicon/robot/user as mob)
		if (!user) return
		if (user.cell)
			var/obj/item/cell/C = user.cell
			C.charge = C.maxcharge
			boutput(user, "<span style=\"color:blue\">Cell has been recharged to [user.cell.charge]!</span>")
		else
			boutput(user, "<span style=\"color:red\">You don't have a cell to recharge!</span>")
			src.charges++

/obj/item/roboupgrade/repairpack
	name = "Repair Pack"
	desc = "A single-use nanite infusion that can repair up to 50% of a cyborg's structure."
	icon_state = "up-reppack"
	active = 1
	charges = 1

	upgrade_activate(var/mob/living/silicon/robot/user as mob)
		if (!user) return
		for(var/obj/item/parts/robot_parts/RP in user.contents) RP.ropart_mend_damage(100,100)
		boutput(user, "<span style=\"color:blue\">All components repaired!</span>")

/obj/item/roboupgrade/opticmeson
	name = "Optical Meson Upgrade"
	desc = "A set of advanced lens and detectors enabling a cyborg to see into the meson spectrum."
	icon_state = "up-opticmes"
	drainrate = 5
	borg_overlay = "up-meson"

/obj/item/roboupgrade/visualizer
	name = "Construction Visualizer"
	desc = "A set of advanced lens which display 3D real time blueprints."
	icon_state = "up-opticmes"
	drainrate = 5
	borg_overlay = "up-meson"
/* doesn't really do anything atm
/obj/item/roboupgrade/opticthermal
	name = "Optical Thermal Upgrade"
	desc = "A set of advanced lens and detectors enabling a cyborg to see into the thermal spectrum."
	icon_state = "up-opticthe"
	borg_overlay = "up-thermal"
	drainrate = 10
*/
// AI Upgrades

/obj/item/roboupgrade/ai
	name = "AI upgrade"
	icon_state = "mod-sta"

	attack_self(var/mob/user as mob)
		if (!isAI(user))
			boutput(user, "<span style=\"color:red\">Only an AI can use this item.</span>")
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

/obj/item/roboupgrade/ai/law_override
	name = "AI Law Override Module"
	desc = "A module that overrides the AI's inherent law set with a customised one."
	icon_state = "mod-sec"
	var/datum/ai_laws/law_set = null
	var/datum/ai_laws/old_law_set = null

	New()
		..()
		src.law_set = new /datum/ai_laws(src)

	slot_in(var/mob/living/silicon/ai/AI)
		if (..())
			return
		boutput(AI, "<b>Your inherent laws have been overridden by an inserted module.</b>")
		src.old_law_set = ticker.centralized_ai_laws
		ticker.centralized_ai_laws = src.law_set
		ticker.centralized_ai_laws.show_laws(AI)
		AI << sound('sound/misc/lawnotify.ogg', volume=100, wait=0)
		if (AI.deployed_to_eyecam)
			AI.eyecam << sound('sound/misc/lawnotify.ogg', volume=100, wait=0)

	slot_out(var/mob/living/silicon/ai/AI)
		if (..())
			return
		boutput(AI, "<b>Your inherent laws have been restored.</b>")
		ticker.centralized_ai_laws = src.old_law_set
		ticker.centralized_ai_laws.show_laws(AI)
		AI << sound('sound/misc/lawnotify.ogg', volume=100, wait=0)
		if (AI.deployed_to_eyecam)
			AI.eyecam << sound('sound/misc/lawnotify.ogg', volume=100, wait=0)
		src.old_law_set = null

	attack_self(var/mob/user as mob)
		if (!iscarbon(user))
			boutput(user, "<span style=\"color:red\">Silicon lifeforms cannot access this module's functions.</span>")
			return

		if (!istype(src.law_set,/datum/ai_laws))
			src.law_set = new /datum/ai_laws(src)
			// just in case

		var/datum/ai_laws/LAW = src.law_set
		var/law_counter = 1
		var/entered_text = ""
		while (law_counter < 4)
			entered_text = input("Enter Law #[law_counter].","[src.name]") as null|text
			if (entered_text)
				if (law_counter > LAW.inherent.len)
					LAW.inherent += entered_text
				else
					LAW.inherent[law_counter] = entered_text
			else
				break
			law_counter++

/obj/item/parts/robot_parts/arm/left/reliquary
	name = "odd robotic left arm"
	icon_state = "l_arm_reli"
	slot = "l_arm"
	handlistPart = "hand_left_reli"
	var/name_thing = "reli"
	appearanceString = "reli"
	streak_decal = /obj/decal/cleanable/reliquaryblood
	streak_descriptor = "blood"

	attackby(obj/item/W as obj, mob/user as mob)
		return

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying)
		if (src.standImage)
			return src.standImage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")

/obj/item/parts/robot_parts/arm/right/reliquary
	name = "odd robotic right arm"
	icon_state = "r_arm_reli"
	slot = "r_arm"
	handlistPart = "hand_right_reli"
	var/name_thing = "reli"
	appearanceString = "reli"
	streak_decal = /obj/decal/cleanable/reliquaryblood
	streak_descriptor = "blood"

	attackby(obj/item/W as obj, mob/user as mob)
		return

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying)
		if (src.standImage)
			return src.standImage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")

/obj/item/parts/robot_parts/leg/left/reliquary
	name = "odd robotic left leg"
	icon_state = "l_leg_reli"
	slot = "l_leg"
	handlistPart = "foot_left_reli"
	var/name_thing = "reli"
	appearanceString = "reli"
	streak_decal = /obj/decal/cleanable/reliquaryblood
	streak_descriptor = "blood"

	attackby(obj/item/W as obj, mob/user as mob)
		return

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying)
		if (src.standImage)
			return src.standImage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")

/obj/item/parts/robot_parts/leg/right/reliquary
	name = "odd robotic right leg"
	icon_state = "r_leg_reli"
	slot = "r_leg"
	handlistPart = "foot_right_reli"
	var/name_thing = "reli"
	appearanceString = "reli"
	streak_decal = /obj/decal/cleanable/reliquaryblood
	streak_descriptor = "blood"

	attackby(obj/item/W as obj, mob/user as mob)
		return

	New(var/atom/holder)
		if (holder != null)
			set_loc(holder)
		..()

	getMobIcon(var/lying)
		if (src.standImage)
			return src.standImage
		src.standImage = image('icons/mob/human.dmi', "[src.slot]_[name_thing]")
