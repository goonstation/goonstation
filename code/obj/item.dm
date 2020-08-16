/obj/item
	name = "item"
	icon = 'icons/obj/items/items.dmi'
	text = ""
	var/icon_old = null
	var/uses_multiple_icon_states = 0
	var/force = null
	var/item_state = null
	var/hit_type = DAMAGE_BLUNT // for bleeding system things, options: DAMAGE_BLUNT, DAMAGE_CUT, DAMAGE_STAB in order of how much it affects the chances to increase bleeding
	throwforce = 1//4
	var/r_speed = 1.0
	var/health = 4 // burn faster
	var/burn_point = 15000  // this already exists but nothing uses it???
	var/burn_possible = 1 //cogwerks fire project - can object catch on fire - let's have all sorts of shit burn at hellish temps
	//MBC : im shit. change burn_possible to '2' if you want it to pool itself instead of qdeling when burned

	var/burn_output = 1500 //how hot should it burn
	var/burn_type = 0 // 0 = ash, 1 = melt
	var/burning = null
	var/burning_last_process = 0
	var/hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
	var/w_class = 3.0 // how big they are, determines if they can fit in backpacks and pockets and the like
	p_class = 1.5 // how hard they are to pull around, determines how much something slows you down while pulling it
	var/cant_self_remove = 0 //Can't remove from non-hand slots
	var/cant_other_remove = 0 //Can't be removed from non-hand slots by others
	var/cant_drop = 0 //Cant' be removed in general. I guess.

	flags = FPRINT | TABLEPASS
	var/tool_flags = 0
	var/c_flags = null
	var/tooltip_flags = null
	var/item_function_flags = null

	pressure_resistance = 50
	var/obj/item/master = null
	var/amount = 1
	var/max_stack = 1
	var/stack_type = null // if null, only current type. otherwise uses this
	var/contraband = 0 //If nonzero, bots consider this a thing people shouldn't be carrying without authorization
	var/hide_attack = 0 //If 1, hide the attack animation + particles. Used for hiding attacks with silenced .22 and sleepy pen
						//If 2, play the attack animation but hide the attack particles.

	var/needOnMouseMove = 0 //If 1, we check all the stuff required for onMouseMove for this. Leave this off unless required. Might cause extra lag.

	var/image/wear_image = null
	var/wear_image_icon = 'icons/mob/belt.dmi'
	var/image/inhand_image = null
	var/inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'

	var/equipped_in_slot = null // null if not equipped, otherwise contains the slot in which it is

	var/arm_icon = "" //set to an icon state in human.dmi minus _s/_l and l_arm_/r_arm_ to allow use as an arm
	var/over_clothes = 0 //draw over clothes when used as a limb
	var/override_attack_hand = 1 //when used as an arm, attack with item rather than using attack_hand
	var/can_hold_items = 0 //when used as an arm, can it hold things?

	var/stamina_damage = STAMINA_ITEM_DMG //amount of stamina removed from target per hit.
	var/stamina_cost = STAMINA_ITEM_COST  //amount of stamina removed from USER per hit. This cant bring you below 10 points and you will not be able to attack if it would.
	var/stamina_crit_chance = STAMINA_CRIT_CHANCE //Crit chance when attacking with this.

	var/list/module_research = null//list()
	var/module_research_type = null
	var/module_research_no_diminish = 0

	var/edible = 0 // can you eat the thing?

	var/duration_put    = -1 //If set to something other than -1 these will control
	var/duration_remove = -1 //how long it takes to remove or put the item onto a person. 1/10ths of a second.

	var/rand_pos = 0
	var/useInnerItem = 0 //Should this item use a contained item (in contents) to attack with instead?
	var/obj/item/holding = null

	var/two_handed = 0 //Requires both hands. Do not change while equipped. Use proc for that (TBI)
	var/click_delay = DEFAULT_CLICK_DELAY //Delay before next click after using this.
	var/combat_click_delay = COMBAT_CLICK_DELAY

	var/showTooltip = 1
	var/showTooltipDesc = 1
	var/tmp/lastTooltipTitle = null
	var/tmp/lastTooltipContent = null
	var/tmp/lastTooltipName = null
	var/tmp/lastTooltipDist = null
	var/tmp/lastTooltipUser = null
	var/tmp/lastTooltipSpectro = null
	var/tmp/tooltip_rebuild = 1
	var/rarity = ITEM_RARITY_COMMON //Just a little thing to indicate item rarity. RPG fluff.

	var/datum/item_special/special = null //Contains the datum which executes the items special, if it has one, when used beyond melee range.

	var/pickup_sfx = 0 //if null, we auto-pick from a list based on w_class

	var/can_disarm = 0

	var/block_hearing_when_worn = HEARING_NORMAL
	 //fuck me mbc why you do this | | ok i did it to reduce type checking in a proc that gets called A LOT and idk what else to do ok help


	var/obj/item/grab/chokehold = null
	var/obj/item/grab/special_grab = null

	var/block_vision = 0 //cannot see when worn

	// Inventory count display. Call create_inventory_counter in New()
	var/inventory_counter_enabled = 0
	var/obj/overlay/inventory_counter/inventory_counter = null

	proc/setTwoHanded(var/twohanded = 1) //This is the safe way of changing 2-handed-ness at runtime. Use this please.
		if(ismob(src.loc))
			var/mob/L = src.loc
			return L.updateTwoHanded(src, twohanded)
		else
			two_handed = twohanded
		return 1

	proc/buildTooltipContent()
		. = list()
		if(showTooltipDesc)
			. += capitalize(src.desc)
			var/extra = src.get_desc(get_dist(src, usr), usr)
			if(extra)
				. += "<br>" + extra

		. += "<hr>"
		if(rarity >= 4)
			. += "<div><img src='[resource("images/tooltips/rare.gif")]' alt='' class='icon' /><span>Rare item</span></div>"
		. += "<div><img src='[resource("images/tooltips/attack.png")]' alt='' class='icon' /><span>Damage: [src.force ? src.force : "0"] dmg[src.force ? "("+DAMAGE_TYPE_TO_STRING(src.hit_type)+")" : ""], [round((1 / (max(src.click_delay,src.combat_click_delay) / 10)), 0.1)] atk/s, [src.throwforce ? src.throwforce : "0"] thrown dmg</span></div>"
		if (src.stamina_cost || src.stamina_damage)
			. += "<div><img src='[resource("images/tooltips/stamina.png")]' alt='' class='icon' /><span>Stamina: [src.stamina_damage ? src.stamina_damage : "0"] dmg, [stamina_cost] consumed per swing</span></div>"

		if(src.properties && src.properties.len)
			for(var/datum/objectProperty/P in src.properties)
				if(!istype(P, /datum/objectProperty/inline))
					. += "<br><img style=\"display:inline;margin:0\" src=\"[resource("images/tooltips/[P.tooltipImg]")]\" width=\"12\" height=\"12\" /> [P.name]: [P.getTooltipDesc(src, src.properties[P])]"

		//itemblock tooltip additions
		if(src.c_flags & HAS_GRAB_EQUIP)
			. += "<br><img style=\"display:inline;margin:0\" src=\"[resource("images/tooltips/prot.png")]\" width=\"12\" height=\"12\" /> Block+: "
			for(var/obj/item/grab/block/B in src)
				if(B.properties && B.properties.len)
					for(var/datum/objectProperty/inline/P in B.properties)
						. += "<img style=\"display:inline;margin:0\" src=\"[resource("images/tooltips/[P.tooltipImg]")]\" width=\"12\" height=\"12\" /> "
					for(var/datum/objectProperty/P in B.properties)
						if(!istype(P, /datum/objectProperty/inline))
							. += "<br><img style=\"display:inline;margin:0\" width=\"12\" height=\"12\" /><img style=\"display:inline;margin:0\" src=\"[resource("images/tooltips/[P.tooltipImg]")]\" width=\"12\" height=\"12\" /> [P.name]: [P.getTooltipDesc(B, B.properties[P])]"
			for (var/datum/component/C in src.GetComponents(/datum/component/itemblock))
				. += jointext(C.getTooltipDesc(), "")
		else if(src.c_flags & BLOCK_TOOLTIP)
			. += "<br><img style=\"display:inline;margin:0\" src=\"[resource("images/tooltips/prot.png")]\" width=\"12\" height=\"12\" /> Block+: RESIST with this item for more info"

		if(istype(src, /obj/item/clothing/gloves))
			var/obj/item/clothing/gloves/G = src
			if(G.specialoverride && G.overridespecial)
				var/content = resource("images/tooltips/[G.specialoverride.image].png")
				. += "<br>Unarmed special attack override:<br><img style=\"float:left;margin:0;margin-right:3px\" src=\"[content]\" width=\"32\" height=\"32\" /><div style=\"overflow:hidden\">[G.specialoverride.name]: [G.specialoverride.getDesc()]</div>"
			. = jointext(., "")
		if(special && !istype(special, /datum/item_special/simple))
			var/content = resource("images/tooltips/[special.image].png")
			. += "<br><br><img style=\"float:left;margin:0;margin-right:3px\" src=\"[content]\" width=\"32\" height=\"32\" /><div style=\"overflow:hidden\">[special.name]: [special.getDesc()]<br>To execute a special, use HARM or DISARM intent and click a far-away tile.</div>"
		. = jointext(., "")

		lastTooltipContent = .

	MouseEntered(location, control, params)
		if (showTooltip && usr.client.tooltipHolder)
			var/show = 1

			if (!lastTooltipContent || !lastTooltipTitle || tooltip_flags & REBUILD_ALWAYS\
			 || (HAS_MOB_PROPERTY(usr, PROP_SPECTRO) && tooltip_flags & REBUILD_SPECTRO)\
			 || (usr != lastTooltipUser && tooltip_flags & REBUILD_USER)\
			 || (get_dist(src, usr) != lastTooltipDist && tooltip_flags & REBUILD_DIST))
				tooltip_rebuild = 1

			//If user has tooltips to always show, and the item is in world, and alt key is NOT pressed, deny
			//z == 0 seems to be a good way to check if something is inworld or not... removed some ismob checks.
			if (usr.client.preferences.tooltip_option == TOOLTIP_ALWAYS && z != 0 && !usr.client.check_key(KEY_EXAMINE))
				show = 0

			var/title
			if (tooltip_rebuild || lastTooltipName != src.name)
				if(rarity >= 7)
					title = "<span class=\"rainbow\">[capitalize(src.name)]</span>"
				else
					title = "<span style=\"color:[RARITY_COLOR[rarity] || "#fff"]\">[capitalize(src.name)]</span>"
				lastTooltipTitle = title
				lastTooltipName = src.name
			else
				title = lastTooltipTitle

			if(show)
				var/list/tooltipParams = list(
					"params" = params,
					"title" = title,
					"content" = tooltip_rebuild ? buildTooltipContent() : lastTooltipContent,
					"theme" = usr.client.preferences.hud_style == "New" ? "newhud" : "item"
				)

				if (src.z == 0 && src.loc == usr)
					tooltipParams["flags"] = TOOLTIP_TOP2 //space up one tile, not TOP. need other spacing flag thingy

				//If we're over an item that's stored in a container the user has equipped
				if (src.z == 0 && istype(src.loc, /obj/item/storage) && src.loc.loc == usr)
					tooltipParams["flags"] = TOOLTIP_RIGHT

				usr.client.tooltipHolder.showHover(src, tooltipParams)

			tooltip_rebuild = 0

		usr.moused_over(src)

	MouseExited()
		if(showTooltip && usr.client.tooltipHolder)
			usr.client.tooltipHolder.hideHover()
		usr.moused_exit(src)

	onMaterialChanged()
		..()
		if (istype(src.material))
			force = material.hasProperty("hard") ? force + round(material.getProperty("hard") / 20) : force
			burn_possible = src.material.getProperty("flammable") > 50 ? 1 : 0
			if (src.material.material_flags & MATERIAL_METAL || src.material.material_flags & MATERIAL_CRYSTAL || src.material.material_flags & MATERIAL_RUBBER)
				burn_type = 1
			else
				burn_type = 0

		if (src.material.triggersOnLife.len)
			src.AddComponent(/datum/component/holdertargeting/mat_triggersonlife)
		else
			var/datum/component/C = src.GetComponent(/datum/component/holdertargeting/mat_triggersonlife)
			if (C)
				C.RemoveComponent(/datum/component/holdertargeting/mat_triggersonlife)

	removeMaterial()
		if (src.material && src.material.triggersOnLife.len)
			var/datum/component/C = src.GetComponent(/datum/component/holdertargeting/mat_triggersonlife)
			if (C)
				C.RemoveComponent(/datum/component/holdertargeting/mat_triggersonlife)
		..()

/obj/item/New()
	// this is dumb but it won't let me initialize vars to image() for some reason
	wear_image = image(wear_image_icon)
	wear_image.icon_state = icon_state //Why was this null until someone actually wore it? Made manipulation impossible.
	inhand_image = image(inhand_image_icon)
	if (src.rand_pos)
		if (!src.pixel_x) // just in case
			src.pixel_x = rand(-8,8)
		if (!src.pixel_y) // same as above
			src.pixel_y = rand(-8,8)
	src.setItemSpecial(/datum/item_special/simple)

	if (inventory_counter_enabled)
		src.create_inventory_counter()
		if (src.amount != 1)
			// this is a gross hack to make things not just show "1" by default
			src.inventory_counter.update_number(src.amount)
	..()

/obj/item/unpooled()
	..()
	src.amount = 1

	if (src.burning)
		if (src.burn_output >= 1000)
			src.overlays -= image('icons/effects/fire.dmi', "2old")
		else
			src.overlays -= image('icons/effects/fire.dmi', "1old")
	src.burning = 0

	if (inventory_counter_enabled)
		src.inventory_counter = unpool(/obj/overlay/inventory_counter)
		src.inventory_counter.update_number(src.amount)

/obj/item/pooled()
	src.amount = 0
	src.health = initial(src.health)

	if (src.burning)
		if (src.burn_output >= 1000)
			src.overlays -= image('icons/effects/fire.dmi', "2old")
		else
			src.overlays -= image('icons/effects/fire.dmi', "1old")
	src.burning = 0

	if (ismob(src.loc))
		var/mob/M = src.loc
		M.u_equip(src)

	if (src.inventory_counter)
		pool(src.inventory_counter)
		src.inventory_counter = null

	..()

/obj/item/set_loc(var/newloc as turf|mob|obj in world)
	if (src.temp_flags & IS_LIMB_ITEM)
		if (istype(newloc,/obj/item/parts/human_parts/arm/left/item) || istype(newloc,/obj/item/parts/human_parts/arm/right/item))
			..()
		else
			return
	else
		..()

//set up object properties on the block when blocking with the item. if overriding this proc, add the BLOCK_SETUP macro to new() to register for the signal and to get tooltips working right
/obj/item/proc/block_prop_setup(var/source, var/obj/item/grab/block/B)
	SHOULD_CALL_PARENT(1)
	if(!src.c_flags)
		return
	if(src.c_flags & BLOCK_CUT)
		B.setProperty("I_block_cut", max(DEFAULT_BLOCK_PROTECTION_BONUS, B.getProperty("I_block_cut")))
	if(src.c_flags & BLOCK_STAB)
		B.setProperty("I_block_stab", max(DEFAULT_BLOCK_PROTECTION_BONUS, B.getProperty("I_block_stab")))
	if(src.c_flags & BLOCK_BURN)
		B.setProperty("I_block_burn", max(DEFAULT_BLOCK_PROTECTION_BONUS, B.getProperty("I_block_burn")))
	if(src.c_flags & BLOCK_BLUNT)
		B.setProperty("I_block_blunt", max(DEFAULT_BLOCK_PROTECTION_BONUS, B.getProperty("I_block_blunt")))

/obj/item/proc/onMouseDrag(src_object,over_object,src_location,over_location,src_control,over_control,params)
	if(special && !special.manualTriggerOnly)
		if(istype(usr, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = usr
			if(H.in_throw_mode) return
		special.onMouseDrag(src_object,over_object,src_location,over_location,src_control,over_control,params)
	return

/obj/item/proc/onMouseDown(atom/target,location,control,params)
	if(special && !special.manualTriggerOnly)
		if(istype(usr, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = usr
			if(H.in_throw_mode) return
		special.onMouseDown(target,location,control,params)
	return

/obj/item/proc/onMouseUp(atom/target,location,control,params)
	if(special && !special.manualTriggerOnly)
		if(istype(usr, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = usr
			if(H.in_throw_mode) return
		special.onMouseUp(target,location,control,params)
	return

/obj/item/pixelaction(atom/target, params, mob/user, reach)
	if(special && !special.manualTriggerOnly && !reach)
		special.pixelaction(target,params,user,reach)
		return 1
	..()


//disgusting proc. merge with foods later. PLEASE
/obj/item/proc/Eat(var/mob/M as mob, var/mob/user)
	if (!src.edible && !(src.material && src.material.edible))
		return 0
	if (!iscarbon(M) && !ismobcritter(M))
		return 0

	if (M == user)
		M.visible_message("<span class='notice'>[M] takes a bite of [src]!</span>",\
		"<span class='notice'>You take a bite of [src]!</span>")

		if (src.material && src.material.edible)
			src.material.triggerEat(M, src)

		if (src.reagents && src.reagents.total_volume)
			src.reagents.reaction(M, INGEST)
			SPAWN_DBG (5) // Necessary.
				src.reagents.trans_to(M, src.reagents.total_volume/src.amount)

		playsound(M.loc,"sound/items/eatfood.ogg", rand(10, 50), 1)
		SPAWN_DBG (10)
			if (!src || !M || !user)
				return 0
			// Why not, I guess. Adds a bit of flavour (Convair880).
			if (iswerewolf(M) && istype(src, /obj/item/organ/))
				M.show_text("Mmmmm, tasty organs. How refreshing.", "blue")
				M.HealDamage("All", 5, 5)

			M.visible_message("<span class='alert'>[M] finishes eating [src].</span>",\
			"<span class='alert'>You finish eating [src].</span>")
			user.u_equip(src)
			qdel(src)
		return 1

	else
		if(M.mob_flags & IS_RELIQUARY)
			boutput(user, "<span class='alert'>They don't come equipped with a digestive system, so there is no point in trying to feed them.</span>")
			return 0
		user.tri_message("<span class='alert'><b>[user]</b> tries to feed [M] [src]!</span>",\
		user, "<span class='alert'>You try to feed [M] [src]!</span>",\
		M, "<span class='alert'><b>[user]</b> tries to feed you [src]!</span>")
		logTheThing("combat", user, M, "attempts to feed [constructTarget(M,"combat")] [src] [log_reagents(src)]")

		if (!do_mob(user, M))
			return 0
		if (get_dist(user,M) > 1)
			return 0

		user.tri_message("<span class='alert'><b>[user]</b> feeds [M] [src]!</span>",\
		user, "<span class='alert'>You feed [M] [src]!</span>",\
		M, "<span class='alert'><b>[user]</b> feeds you [src]!</span>")
		logTheThing("combat", user, M, "feeds [constructTarget(M,"combat")] [src] [log_reagents(src)]")

		if (src.material && src.material.edible)
			src.material.triggerEat(M, src)

		if (src.reagents && src.reagents.total_volume)
			src.reagents.reaction(M, INGEST)
			SPAWN_DBG (5) // Necessary.
				src.reagents.trans_to(M, src.reagents.total_volume)

		playsound(M.loc, "sound/items/eatfood.ogg", rand(10, 50), 1)
		SPAWN_DBG (10)
			if (!src || !M || !user)
				return 0
			// Ditto (Convair880).
			if (iswerewolf(M) && istype(src, /obj/item/organ/))
				M.show_text("Mmmmm, tasty organs. How refreshing.", "blue")
				M.HealDamage("All", 5, 5)

			M.visible_message("<span class='alert'>[M] finishes eating [src].</span>",\
			"<span class='alert'>You finish eating [src].</span>")
			user.u_equip(src)
			qdel(src)
		return 1

/obj/item/proc/take_damage(brute, burn, tox, disallow_limb_loss)
	// this is a helper for organs and limbs
	return 0

/obj/item/proc/heal_damage(brute, burn, tox)
	// this is a helper for organs and limbs
	return 0

/obj/item/proc/get_damage()
	// this is a helper for organs and limbs
	return 0

/obj/item/proc/equipment_click(atom/source, atom/target, params, location, control, origParams, slot) //Called through hand_range_attack on items the mob is wearing that have HAS_EQUIP_CLICK in flags.
	return 0


/*
		var/icon/overlay = icon('icons/effects/96x96.dmi',"smoke")
		if (color)
			overlay.Blend(color,ICON_MULTIPLY)
		var/image/I = image(overlay)
		I.pixel_x = -32
		I.pixel_y = -32

		var/the_dir = NORTH
	for(var/i=0, i<8, i++)
		var/obj/chem_smoke/C = new/obj/chem_smoke(location, holder, max_vol)
		C.overlays += I
		if (rname) C.name = "[rname] smoke"
		SPAWN_DBG(0)
			var/my_dir = the_dir
			var/my_time = rand(80,110)
			var/my_range = 3
			SPAWN_DBG(my_time) qdel(C)
			for(var/b=0, b<my_range, b++)
				sleep(1.5 SECONDS)
				if (!C) break
				step(C,my_dir)
				C.expose()
		the_dir = turn(the_dir,45)
*/

/obj/item/proc/combust_ended()
	processing_items.Remove(src)

/obj/item/proc/combust() // cogwerks- flammable items project
	if (!src.burning)
		src.visible_message("<span class='alert'>[src] catches on fire!</span>")
		src.burning = 1
		if (src.burn_output >= 1000)
			src.overlays += image('icons/effects/fire.dmi', "2old")
		else
			src.overlays += image('icons/effects/fire.dmi', "1old")
		processing_items.Add(src)
		/*if (src.reagents && src.reagents.reagent_list && src.reagents.reagent_list.len)

			//boutput(world, "<span class='alert'><b>[src] is releasing chemsmoke!</b></span>")
			//cogwerks note for drsingh: this was causing infinite server-killing problems
			//someone brought a couple pieces of cheese into chemistry
			//chlorine trifluoride foam set the cheese on fire causing it to releasee cheese smoke
			//creating a dozen more cheeses on the floor
			//which would catch on fire, releasing more cheese smoke
			//i'm sure you can see where that is going
			//this will happen with any reagents that create more reagent-containing items on turf reactions
			var/location = get_turf(src)
			var/max_vol = reagents.maximum_volume
			var/rname = reagents.get_master_reagent_name()
			var/color = reagents.get_master_color(1)
			var/icon/overlay = icon('icons/effects/96x96.dmi',"smoke")
			if (color)
				overlay.Blend(color,ICON_MULTIPLY)
			var/image/I = image(overlay)
			I.pixel_x = -32
			I.pixel_y = -32

			var/the_dir = NORTH
			for(var/i=0, i<8, i++)
				var/obj/chem_smoke/C = new/obj/chem_smoke(location, reagents, max_vol)
				C.overlays += I
				if (rname) C.name = "[rname] smoke"
				SPAWN_DBG(0)
					var/my_dir = the_dir
					var/my_time = rand(80,110)
					var/my_range = 3
					SPAWN_DBG(my_time) qdel(C)
					for(var/b=0, b<my_range, b++)
						sleep(1.5 SECONDS)
						if (!C) break
						step(C,my_dir)
						C.expose()
				the_dir = turn(the_dir,45) */

/obj/item/temperature_expose(datum/gas_mixture/air, temperature, volume)
	if (src.burn_possible && !src.burning)
		if ((temperature > T0C + src.burn_point) && prob(5))
			src.combust()
	if (src.material)
		src.material.triggerTemp(src, temperature)
	..() // call your fucking parents

/obj/item/proc/update_stack_appearance()
	return

/obj/item/proc/change_stack_amount(var/diff)
	amount += diff
	if (!inventory_counter)
		create_inventory_counter()
	inventory_counter.update_number(amount)
	if (amount > 0)
		update_stack_appearance()
	else if (!issilicon(usr))
		// Zamu change - added if (!issilicon(usr))
		// I have no idea if this matters - issilicon() is used in other places to prevent
		// dropping or deleting items in some places.
		// good thing I have no clue what I'm doing
		// Potential issue for later: may end up not deleting external-to-player stacks
		// maybe check for src.loc = usr? ???
		SPAWN_DBG(0)
			usr.u_equip(src)
			pool(src)

/obj/item/proc/stack_item(obj/item/other)
	var/added = 0

	if (other != src && check_valid_stack(other))
		if (src.amount + other.amount > max_stack)
			added = max_stack - src.amount
		else
			added = other.amount

		src.change_stack_amount(added)
		other.change_stack_amount(-added)

	return added

/obj/item/proc/before_stack(atom/movable/O as obj, mob/user as mob)
	user.visible_message("<span class='notice'>[user] begins quickly stacking [src]!</span>")

/obj/item/proc/after_stack(atom/movable/O as obj, mob/user as mob, var/added)
	boutput(user, "<span class='notice'>You finish stacking [src].</span>")

/obj/item/proc/failed_stack(atom/movable/O as obj, mob/user as mob, var/added)
	boutput(user, "<span class='notice'>You can't hold any more [name] than that!</span>")

/obj/item/proc/check_valid_stack(atom/movable/O as obj)

	if (stack_type)
		if(!istype(O, stack_type))
			return 0
	else
		if(src.type != O.type)
			return 0

	if(O.material && src.material)
		if(!isSameMaterial(O.material, src.material))
			return 0
	else if ((O.material && !src.material) || (!O.material && src.material))
		return 0

	return 1

/obj/item/proc/split_stack(var/toRemove)
	if(toRemove >= amount) return 0
	var/obj/item/P = new src.type(src.loc)

	if(src.material)
		P.setMaterial(copyMaterial(src.material))

	src.change_stack_amount(-toRemove)
	P.change_stack_amount(toRemove - P.amount)
	return P

/obj/item/MouseDrop_T(atom/movable/O as obj, mob/user as mob)
	..()
	if (max_stack > 1 && src.loc == user && get_dist(O, user) <= 1 && check_valid_stack(O))
		if ( src.amount >= max_stack)
			failed_stack(O, user)
			return

		var/added = 0
		var/staystill = user.loc
		var/stack_result = 0

		before_stack(O, user)

		for(var/obj/item/other in view(1,user))
			stack_result = stack_item(other)
			if (!stack_result)
				continue
			else
				sleep(0.3 SECONDS)
				added += stack_result
				if (user.loc != staystill) break
				if (src.amount >= max_stack)
					failed_stack(O, user)
					return

		after_stack(O, user, added)

#define src_exists_inside_user_or_user_storage (src.loc == user || (istype(src.loc, /obj/item/storage) && src.loc.loc == user))


/obj/item/MouseDrop(atom/over_object, src_location, over_location, over_control, params)
	..()

	if (usr.stat || usr.restrained() || !can_reach(usr, src) || usr.getStatusDuration("paralysis") || usr.sleeping || usr.lying || isAIeye(usr) || isAI(usr) || isrobot(usr) || isghostcritter(usr) || (over_object && over_object.event_handler_flags & NO_MOUSEDROP_QOL))
		return

	var/on_turf = isturf(src.loc)

	var/mob/user = usr

	params = params2list(params)

	if (isliving(over_object) && isliving(usr) && !istype(src,/obj/item/storage)) //pickup action
		if (user == over_object)
			actions.start(new /datum/action/bar/private/icon/pickup(src), user)
		//else // use laterr, after we improve the 'give' dialog to work with multicontext
		//	if (get_dist(user,over_object) <= 1 && src_exists_inside_usr_or_usr_storage)
		//		user.give_to(over_object)
	else

		if (isturf(over_object))
			if (on_turf && in_range(over_object,src) && !src.anchored) //drag from floor to floor == slide
				if (istype(over_object,/turf/simulated/floor) || istype(over_object,/turf/unsimulated/floor))
					step_to(src,over_object)
					//this would be cool ha ha h
					//if (islist(params) && params["icon-y"] && params["icon-x"])
						//src.pixel_x = text2num(params["icon-x"]) - 16
						//src.pixel_y = text2num(params["icon-y"]) - 16
						//animate(src, pixel_x = text2num(params["icon-x"]) - 16, pixel_y = text2num(params["icon-y"]) - 16, time = 30, flags = ANIMATION_END_NOW)
					return
			else if (src_exists_inside_user_or_user_storage && !istype(src,/obj/item/storage)) //sorry for the storage check, i dont wanna override their mousedrop and to do it Correcly would be a whole big rewrite
				usr.drop_from_slot(src) //drag from inventory to floor == drop
				step_to(src,over_object)
				return

		var/is_storage = istype(over_object,/obj/item/storage)
		if (is_storage || istype(over_object, /obj/screen/hud))
			if (on_turf && isturf(over_object.loc) && is_storage)
				try_equip_to_inventory_object(usr, over_object, params)
			else if (on_turf)
				actions.start(new /datum/action/bar/private/icon/pickup/then_hud_click(src, over_object, params), usr)
			else
				try_equip_to_inventory_object(usr, over_object, params)

		else if (isobj(over_object) && !src.check_valid_stack(over_object))
			if (src.loc == usr || istype(src.loc,/obj/item/storage))
				if (try_put_hand_mousedrop(usr))
					if (can_reach(usr, over_object))
						usr.click(over_object, params, src_location, over_control)
			else
				actions.start(new /datum/action/bar/private/icon/pickup/then_obj_click(src, over_object, params), usr)

//equip an item, given an inventory hud object or storage item UI thing
/obj/item/proc/try_equip_to_inventory_object(var/mob/user, var/atom/over_object, var/params)
	var/obj/screen/hud/S = over_object
	if (istype(S))
		if (S.master && istype(S.master,/datum/hud/storage))
			var/datum/hud/storage/hud = S.master
			over_object = hud.master //If dragged into backpack HUD, change over_object to the backpack

	if (istype(over_object,/obj/item/storage) && over_object != src)
		var/obj/item/storage/storage = over_object
		if (istype(storage.loc, /turf))
			if (!(in_range(src,user) && in_range(storage,user)))
				return

		var/succ = src.try_put_hand_mousedrop(user, storage)
		if (succ)
			SPAWN_DBG(1 DECI SECOND)
				if (user.is_in_hands(src))
					storage.attackby(src, user)
			return

	if (istype(S))
		if (src.cant_self_remove)
			return
		if ( !user.restrained() && !user.stat )
			var/succ = src.try_put_hand_mousedrop(user)
			if (succ)
				SPAWN_DBG(1 DECI SECOND)
					if (user.is_in_hands(src))
						S.sendclick(params, user)

#undef src_exists_inside_user_or_user_storage


/obj/item/proc/try_put_hand_mousedrop(mob/user)
	var/oldloc = src.loc

	if (!src.anchored)
		if (!user.r_hand || !user.l_hand || (user.r_hand == src) || (user.l_hand == src))
			if (!user.hand) //big messy ugly bad if() chunk here because we want to prefer active hand
				if (user.r_hand == src)
					. = 1
				else if (user.l_hand == src)
					user.swap_hand(1)
					. = 1
				else if (!user.r_hand)
					user.u_equip(src)
					. = user.put_in_hand(src, 0)
				else if (!user.l_hand)
					user.swap_hand(1)
					user.u_equip(src)
					. = user.put_in_hand(src, 1)
			else
				if (user.l_hand == src)
					.= 1
				else if (user.r_hand == src)
					user.swap_hand(0)
					. = 1
				else if (!user.l_hand)
					user.u_equip(src)
					. = user.put_in_hand(src, 1)
				else if (!user.r_hand)
					user.swap_hand(0)
					user.u_equip(src)
					. = user.put_in_hand(src, 0)

		else
			user.show_text("You need a free hand to do that!", "blue")
			.= 0
	else
		user.show_text("This item is anchored to the floor!", "blue")
		.= 0

	if (. == 1)
		if (istype(oldloc,/obj/item/storage))
			var/obj/item/storage/S = oldloc
			//S.hud.remove_item(src)
			S.hud.objects -= src // prevents invisible object from failed transfer (item doesn't fit in pockets from backpack for example)

/obj/item/attackby(obj/item/W as obj, mob/user as mob, params)
	if (src.material)
		src.material.triggerTemp(src ,1500)
	if (src.burn_possible && src.burn_point <= 1500)
		if ((isweldingtool(W) && W:try_weld(user,0,-1,0,0)) || (istype(W, /obj/item/clothing/head/cakehat) && W:on) || (istype(W, /obj/item/device/igniter)) || (istype(W, /obj/item/device/light/zippo) && W:on) || (istype(W, /obj/item/match) && (W:on > 0)) || W.burning)
			src.combust()
		else
			..(W, user)
	else
		..(W, user)

/obj/item/proc/process()
	if (src.burning)
		if (src.material)
			src.material.triggerTemp(src, src.burn_output + rand(1,200))
		var/turf/T = get_turf(src.loc)
		if (T) // runtime error fix
			T.hotspot_expose((src.burn_output + rand(1,200)),5)

		if (prob(7))
			elecflash(src)
		if (prob(7))
			var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
			smoke.set_up(1, 0, src.loc)
			smoke.attach(src)
			smoke.start()
		if (prob(7))
			fireflash(src, 0)

		if (prob(40))
			if (src.health > 4)
				src.health /= 4
			else
				src.health -= 2

		if (src.health <= 0)
			if (burn_type == 1)
				make_cleanable( /obj/decal/cleanable/molten_item,get_turf(src))
			else
				make_cleanable( /obj/decal/cleanable/ash,get_turf(src))

			if (istype(src,/obj/item/parts/human_parts))
				src:holder = null

			src.combust_ended()

			if (src.burn_possible == 2)
				pool(src)
			else
				src.overlays.len = 0
				qdel(src)
			return
	else
		if (burning_last_process != src.burning)
			if (src.burn_output >= 1000)
				src.overlays -= image('icons/effects/fire.dmi', "2old")
			else
				src.overlays -= image('icons/effects/fire.dmi', "1old")
			return

		processing_items.Remove(src)

	burning_last_process = src.burning
	return null

/obj/item/proc/attack_self(mob/user)
	if (src.temp_flags & IS_LIMB_ITEM)
		if (istype(src.loc,/obj/item/parts/human_parts/arm/left/item))
			var/obj/item/parts/human_parts/arm/left/item/I = src.loc
			I.remove_from_mob()
			I.set_item(src)
		else if (istype(src.loc,/obj/item/parts/human_parts/arm/right/item))
			var/obj/item/parts/human_parts/arm/right/item/I = src.loc
			I.remove_from_mob()
			I.set_item(src)

	if(chokehold)
		chokehold.attack_self(user)

	return

/obj/item/proc/talk_into(mob/M as mob, text, secure, real_name, lang_id)
	return

/obj/item/proc/moved(mob/user as mob, old_loc as turf)
	return

/obj/item/proc/equipped(var/mob/user, var/slot)
	SHOULD_CALL_PARENT(1)
	if(src.c_flags & NOT_EQUIPPED_WHEN_WORN && slot != SLOT_L_HAND && slot != SLOT_R_HAND)
		return
	#ifdef COMSIG_ITEM_EQUIPPED
	SEND_SIGNAL(src, COMSIG_ITEM_EQUIPPED, user, slot)
	#endif
	src.equipped_in_slot = slot
	for(var/datum/objectProperty/equipment/prop in src.properties)
		prop.onEquipped(src, user, src.properties[prop])
	var/datum/movement_modifier/equipment/equipment_proxy = locate() in user.movement_modifiers
	if (!equipment_proxy)
		equipment_proxy = new
		APPLY_MOVEMENT_MODIFIER(user, equipment_proxy, /obj/item)
	equipment_proxy.additive_slowdown += src.getProperty("movespeed")
	var/fluidmove = src.getProperty("negate_fluid_speed_penalty")
	if (fluidmove)
		equipment_proxy.additive_slowdown += fluidmove // compatibility hack for old code treating space & fluid movement capability as a slowdown
		equipment_proxy.aquatic_movement += fluidmove
	var/spacemove = src.getProperty("space_movespeed")
	if (spacemove)
		equipment_proxy.additive_slowdown += spacemove // compatibility hack for old code treating space & fluid movement capability as a slowdown
		equipment_proxy.space_movement += spacemove

/obj/item/proc/unequipped(var/mob/user)
	SHOULD_CALL_PARENT(1)
	if(src.c_flags & NOT_EQUIPPED_WHEN_WORN && src.equipped_in_slot != SLOT_L_HAND && src.equipped_in_slot != SLOT_R_HAND)
		return
	#ifdef COMSIG_ITEM_UNEQUIPPED
	SEND_SIGNAL(src, COMSIG_ITEM_UNEQUIPPED, user)
	#endif
	for(var/datum/objectProperty/equipment/prop in src.properties)
		prop.onUnequipped(src, user, src.properties[prop])
	src.equipped_in_slot = null
	var/datum/movement_modifier/equipment/equipment_proxy = locate() in user.movement_modifiers
	if (!equipment_proxy)
		equipment_proxy = new
		APPLY_MOVEMENT_MODIFIER(user, equipment_proxy, /obj/item)
	equipment_proxy.additive_slowdown -= src.getProperty("movespeed")
	var/fluidmove = src.getProperty("negate_fluid_speed_penalty")
	if (fluidmove)
		equipment_proxy.additive_slowdown -= fluidmove
		equipment_proxy.aquatic_movement -= fluidmove
	var/spacemove = src.getProperty("space_movespeed")
	if (spacemove)
		equipment_proxy.additive_slowdown -= spacemove
		equipment_proxy.space_movement -= spacemove

/obj/item/proc/afterattack(atom/target, mob/user, reach, params)
	return

/obj/item/dummy/ex_act()
	return

/obj/item/dummy/blob_act(var/power)
	return

/obj/item/ex_act(severity)
	switch(severity)
		if (1.0)
			if (istype(src,/obj/item/parts/human_parts))
				src:holder = null
			qdel(src)
			return
		if (2.0)
			if (prob(50))

				if (istype(src,/obj/item/parts/human_parts))
					src:holder = null

				qdel(src)
				return
			if (src.material)
				src.material.triggerTemp(src ,7500)
			if (src.burn_possible && !src.burning && src.burn_point <= 7500)
				src.combust()
			if (src.artifact)
				if (!src.ArtifactSanityCheck()) return
				src.ArtifactStimulus("force", 75)
				src.ArtifactStimulus("heat", 450)
		if (3.0)
			if (prob(5))

				if (istype(src,/obj/item/parts/human_parts))
					src:holder = null

				qdel(src)
				return
			if (src.material)
				src.material.triggerTemp(src, 3500)
			if (src.burn_possible && !src.burning && src.burn_point <= 3500)
				src.combust()
			if (src.artifact)
				if (!src.ArtifactSanityCheck()) return
				src.ArtifactStimulus("force", 25)
				src.ArtifactStimulus("heat", 380)
		else
	return

/obj/item/blob_act(var/power)
	if (src.artifact)
		if (!src.ArtifactSanityCheck()) return
		src.ArtifactStimulus("force", power)
		src.ArtifactStimulus("carbtouch", 1)
	return

//nah
/*
/obj/item/verb/move_to_top()
	set name = "Move to Top"
	set src in oview(1)
	set category = "Local"

	if (!istype(src.loc, /turf) || usr.stat || usr.restrained() )
		return

	var/turf/T = src.loc

	src.set_loc(null)

	src.set_loc(T)
*/

/obj/item/interact(mob/user)
	if (user.equipped() == src)
		src.attack_self(user)
	else
		src.pick_up_by(user)

/obj/item/proc/pick_up_by(var/mob/M)
	if (world.time < M.next_click)
		return //fuck youuuuu

	if (isdead(M) || (!iscarbon(M) && !ismobcritter(M)))
		return

	if (!istype(src.loc, /turf) || !isalive(M) || M.getStatusDuration("paralysis") || M.getStatusDuration("stunned") || M.getStatusDuration("weakened") || M.restrained())
		return

	if (!can_reach(M, src))
		return

	.= 1
	for (var/obj/item/cloaking_device/I in M)
		if (I.active)
			I.deactivate(M)
			M.visible_message("<span class='notice'><b>[M]'s cloak is disrupted!</b></span>")
	if (issmallanimal(M))
		var/mob/living/critter/small_animal = M

		for (var/datum/handHolder/HH  in small_animal.hands)
			if (istype(HH.limb,/datum/limb/small_critter))
				if (M.equipped())
					M.drop_item()
					SPAWN_DBG(1 DECI SECOND)
						HH.limb.attack_hand(src,M,1)
				else
					HH.limb.attack_hand(src,M,1)
				M.next_click = world.time + src.click_delay
				return

	//the verb is PICK-UP, not 'smack this object with that object'
	if (M.equipped())
		M.drop_item()
		SPAWN_DBG(1 DECI SECOND)
			src.attack_hand(M)
	else
		src.attack_hand(M)
	M.next_click = world.time + src.click_delay

/obj/item/get_desc()
	var/t
	switch(src.w_class)
		if (-INFINITY to 1.0) t = "tiny"
		if (2.0) t = "small"
		if (3.0) t = "normal-sized"
		if (4.0) t = "bulky"
		if (5.0 to INFINITY) t = "huge"
		else
	if (usr && usr.bioHolder && usr.bioHolder.HasEffect("clumsy") && prob(50)) t = "funny-looking"
	return "It is \an [t] item."

/obj/item/attack_hand(mob/user as mob)
	var/checkloc = src.loc
	while(checkloc && !istype(checkloc,/turf))
		if (isliving(checkloc) && checkloc != user)
			return 0
		checkloc = checkloc:loc
	src.throwing = 0

	if (isobj(src.loc))
		var/obj/container = src.loc
		container.vis_contents -= src

	if (src.loc == user)
		var/in_pocket = 0
		if(issilicon(user)) //if it's a borg's shit, stop here
			return 0
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.l_store == src || H.r_store == src)
				in_pocket = 1
		if (!cant_self_remove || (!cant_drop && (user.l_hand == src || user.r_hand == src)) || in_pocket == 1)
			user.u_equip(src)
		else
			boutput(user, "<span class='alert'>You can't remove this item.</span>")
			return 0
	else
		//src.pickup(user) //This is called by the later put_in_hand() call
		if (user.pulling == src)
			user.pulling = null
		if (isturf(src.loc))
			pickup_particle(user,src)
	if (!user)
		return 0

	var/area/MA = get_area(user)
	var/area/OA = get_area(src)
	if( OA && MA && OA != MA && OA.blocked )
		boutput( user, "<span class='alert'>You cannot pick up items from outside a restricted area.</span>" )
		return 0

	var/atom/oldloc = src.loc
	var/atom/oldloc_sfx = src.loc
	src.set_loc(user) // this is to fix some bugs with storage items
	if (istype(oldloc, /obj/item/storage))
		var/obj/item/storage/S = oldloc
		S.hud.remove_item(src) // ugh
		oldloc_sfx = oldloc.loc
	if (src in bible_contents)
		bible_contents.Remove(src) // UNF
		for (var/obj/item/storage/bible/bible in by_type[/obj/item/storage/bible])
			bible.hud.remove_item(src)
	user.put_in_hand_or_drop(src)

	if (src.artifact)
		if (src.ArtifactSanityCheck())
			src.ArtifactTouched(user)

	if (hide_attack != 1)
		if (pickup_sfx)
			playsound(oldloc_sfx, pickup_sfx, 56, vary=0.2)
		else
			playsound(oldloc_sfx, "sound/items/pickup_[max(min(src.w_class,3),1)].ogg", 56, vary=0.2)

	return 1


//MBC : I had to move some ItemSpecial number changes here to avoid race conditions. is_special flag passed as an arg; If true we take a look at src.special
/obj/item/proc/attack(mob/M as mob, mob/user as mob, def_zone, is_special = 0)
	if (!M || !user) // not sure if this is the right thing...
		return
	if ((src.edible && (ishuman(M) || ismobcritter(M)) || (src.material && src.material.edible)) && src.Eat(M, user))
		return

	if (surgeryCheck(M, user))		// Check for surgery-specific actions
		if(insertChestItem(M, user))	// Puting item in patient's chest
			return

	if (src.flags & SUPPRESSATTACK)
		logTheThing("combat", user, M, "uses [src] ([type], object name: [initial(name)]) on [constructTarget(M,"combat")]")
		return

	if (user.mind && user.mind.special_role == "vampthrall" && isvampire(M) && user.is_mentally_dominated_by(M))
		boutput(user, "<span class='alert'>You cannot harm your master!</span>") //This message was previously sent to the attacking item. YEP.
		return

	if(user.traitHolder && !user.traitHolder.hasTrait("glasscannon"))
		if (!user.process_stamina(src.stamina_cost))
			logTheThing("combat", user, M, "tries to attack [constructTarget(M,"combat")] with [src] ([type], object name: [initial(name)]) but is out of stamina")
			return

	if (chokehold)
		chokehold.attack(M, user, def_zone, is_special)
		return
	else if (special_grab)
		if (user.a_intent == INTENT_GRAB)
			src.try_grab(M, user)
			return

	var/obj/item/affecting = M.get_affecting(user, def_zone)
	var/hit_area
	var/d_zone
	if (istype(affecting, /obj/item/organ))
		var/obj/item/organ/O = affecting
		hit_area = parse_zone(O.organ_name)
		d_zone = O.organ_name
	else if (istype(affecting, /obj/item/parts))
		var/obj/item/parts/P = affecting
		hit_area = parse_zone(P.slot)
		d_zone = P.slot
	else
		hit_area = parse_zone(affecting)
		d_zone = affecting

	if (!M.melee_attack_test(user, src, d_zone))
		logTheThing("combat", user, M, "attacks [constructTarget(M,"combat")] with [src] ([type], object name: [initial(name)]) but the attack is blocked!")
		return

	if(hasProperty("frenzy"))
		SPAWN_DBG(0)
			var/frenzy = getProperty("frenzy")
			click_delay -= frenzy
			sleep(3 SECONDS)
			click_delay += frenzy
/*
	if(hasProperty("Momentum"))
		SPAWN_DBG(0)
			var/momentum = getProperty("momemtum")
			force += 5
*/
	if (src.material)
		src.material.triggerOnAttack(src, user, M)
	for (var/atom/A in M)
		if (A.material)
			A.material.triggerOnAttacked(A, user, M, src)

	user.violate_hippocratic_oath()

	for (var/mob/V in nervous_mobs)
		if (get_dist(user,V) > 6)
			continue
		if (prob(8) && user)
			if (M != V)
				V.emote("scream")
				V.changeStatus("stunned", 3 SECONDS)

	var/datum/attackResults/msgs = new(user)
	msgs.clear(M)
	msgs.affecting = affecting
	msgs.logs = list()
	msgs.logc("attacks [constructTarget(M,"combat")] with [src] ([type], object name: [initial(name)])")

	SEND_SIGNAL(M, COMSIG_MOB_ATTACKED_PRE, user, src)
	var/stam_crit_pow = src.stamina_crit_chance
	if (prob(stam_crit_pow))
		msgs.stamina_crit = 1
		msgs.played_sound = "sound/impact_sounds/Generic_Punch_1.ogg"
		//moved to item_attack_message
		//msgs.visible_message_target("<span class='alert'><B><I>... and lands a devastating hit!</B></I></span>")

	if (can_disarm)
		msgs = user.calculate_disarm_attack(M, M.get_affecting(user), 0, 0, 0, is_shove = 1, disarming_item = src)
	else
		msgs.msg_group = "[usr]_attacks_[M]_with_[src]"
		msgs.visible_message_target(user.item_attack_message(M, src, hit_area, msgs.stamina_crit))

	msgs.played_sound = src.hitsound

	var/power = src.force + src.getProperty("searing")

	if(hasProperty("unstable"))
		power = rand(power, round(power * getProperty("unstable")))

	var/attack_resistance = M.check_attack_resistance(src)
	if (attack_resistance)
		power = 0
		if (istext(attack_resistance))
			msgs.show_message_target(attack_resistance)

	if (hasProperty("searing"))
		msgs.damage_type = DAMAGE_BURN
	else
		msgs.damage_type = hit_type

	if(hasProperty("vorpal"))
		msgs.bleed_always = 1
		msgs.bleed_bonus = getProperty("vorpal")

	var/armor_mod = 0
	armor_mod = M.get_melee_protection(d_zone, src.hit_type)

	var/pierce_prot = 0
	if (d_zone == "head")
		pierce_prot = M.get_head_pierce_prot()
	else
		pierce_prot = M.get_chest_pierce_prot()

	var/adjusted = max(0, getProperty("piercing") - pierce_prot)
	if(adjusted)
		var/prc = ((100 - getProperty("piercing")) / 100)
		armor_mod = round(armor_mod * prc)

	if (is_special && src.special)
		if (src.special.damageMult > 0 && src.special.damageMult != 1)
			power *= src.special.damageMult

	if(user.traitHolder && user.traitHolder.hasTrait("glasscannon"))
		power *= 2

	if(user.is_hulk())
		power *= 1.5

	power -= armor_mod

	if (w_class > STAMINA_MIN_WEIGHT_CLASS)
		var/stam_power = stamina_damage

		if (is_special && src.special)
			if(src.special.overrideStaminaDamage >= 0)
				stam_power = src.special.overrideStaminaDamage

		//reduce stamina by the same proportion that base damage was reduced
		//min cap is stam_power/2 so we still cant ignore it entirely
		if ((power + armor_mod) == 0) //mbc lazy runtime fix
			stam_power = stam_power / 2 //do the least
		else
			stam_power = max(  stam_power / 2, stam_power * ( power / (power + armor_mod) )  )

		//stam_power -= armor_mod
		msgs.force_stamina_target = 1
		msgs.stamina_target -= max(stam_power, 0)

	if (is_special && src.special)
		if(src.special.overrideCrit >= 0)
			stam_crit_pow = src.special.overrideCrit

	if(M.traitHolder && M.traitHolder.hasTrait("deathwish"))
		power *= 2

	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if (H.blood_pressure["total"] > 585)
			msgs.visible_message_self("<span class='alert'><I>[user] gasps and wheezes from the exertion!</I></span>")
			user.losebreath += rand(1,2)
			msgs.stamina_self -= 10

	if(hasProperty("impact"))
		var/turf/T = get_edge_target_turf(M, get_dir(user, M))
		M.throw_at(T, 2, getProperty("impact"))


	msgs.damage = power
	msgs.flush()
	src.add_fingerprint(user)
	#ifdef COMSIG_ITEM_ATTACK_POST
	SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_POST, M, user, power)
	#endif
	return

/obj/item/onVarChanged(variable, oldval, newval)
	. = 0
	switch(variable)
		if ("color")
			if (src.wear_image) src.wear_image.color = newval
			if (src.inhand_image) src.inhand_image.color = newval
			. = 1
		if ("alpha")
			if (src.wear_image) src.wear_image.alpha = newval
			if (src.inhand_image) src.inhand_image.alpha = newval
			. = 1
		if ("blend_mode")
			if (src.wear_image) src.wear_image.blend_mode = newval
			if (src.inhand_image) src.inhand_image.blend_mode = newval
			. = 1
		if ("icon_state")
			. = 1
		if ("item_state")
			. = 1
		if ("wear_image")
			. = 1
		if ("inhand_image")
			. = 1
	if (. && src.loc && ismob(src.loc))
		var/mob/M = src.loc
		M.update_inhands()

/obj/item/proc/attach(var/mob/living/carbon/human/attachee,var/mob/attacher)
	//if (!src.arm_icon) return //ANYTHING GOES!~!

	if (src.object_flags & NO_ARM_ATTACH || src.cant_drop)
		boutput(attacher, "<span class='alert'>You try to attach [src] to [attachee]'s stump, but it politely declines!</span>")
		return

	var/obj/item/parts/human_parts/arm/new_arm = null
	if (attacher.zone_sel.selecting == "l_arm")
		new_arm = new /obj/item/parts/human_parts/arm/left/item(attachee)
		attachee.limbs.l_arm = new_arm
	else
		new_arm = new /obj/item/parts/human_parts/arm/right/item(attachee)
		attachee.limbs.r_arm = new_arm
	if (!new_arm) return //who knows

	new_arm.holder = attachee
	attacher.remove_item(src)
	new_arm.remove_stage = 2

	new_arm:set_item(src)
	src.cant_drop = 1

	for(var/mob/O in AIviewers(attachee, null))
		if (O == (attacher || attachee))
			continue
		if (attacher == attachee)
			O.show_message("<span class='alert'>[attacher] attaches [src] to \his own stump!</span>", 1)
		else
			O.show_message("<span class='alert'>[attachee] has [src] attached to \his stump by [attacher].</span>", 1)

	if (attachee != attacher)
		boutput(attachee, "<span class='alert'>[attacher] attaches [src] to your stump. It doesn't look very secure!</span>")
		boutput(attacher, "<span class='alert'>You attach [src] to [attachee]'s stump. It doesn't look very secure!</span>")
	else
		boutput(attacher, "<span class='alert'>You attach [src] to your own stump. It doesn't look very secure!</span>")

	attachee.set_body_icon_dirty()

	//qdel(src)

	SPAWN_DBG(rand(150,200))
		if (new_arm.remove_stage == 2) new_arm.remove()

	return

/obj/item/proc/handle_other_remove(var/mob/source, var/mob/living/carbon/human/target)
	//Refactor of the item removal code. Fuck having that shit defined in human.dm >>>>>>:C
	//Return something true (lol byond) to allow removal
	//Return something false to disallow
	return (!cant_other_remove && !cant_drop)

/obj/item/disposing()
	// Clean up circular references
	disposing_abilities()
	setItemSpecial(null)
	if (src.inventory_counter)
		pool(src.inventory_counter)
		src.inventory_counter = null

	if(istype(src.loc, /obj/item/storage))
		var/obj/item/storage/storage = src.loc
		src.set_loc(get_turf(src)) // so the storage doesn't add it back >:(
		storage.hud?.remove_item(src)

	var/turf/T = loc
	if (!istype(T))
		if(src.temp_flags & IS_LIMB_ITEM)
			if(istype(src.loc, /obj/item/parts/human_parts/arm/right/item)||istype(src.loc, /obj/item/parts/human_parts/arm/left/item))
				src.loc:remove(0)
		if (ismob(src.loc))
			var/mob/M = src.loc
			M.u_equip(src)

			//mbc GC tooltips (this wont 100% kill tooltip deletions but itll help?
			if	(M.client && M.client.tooltipHolder)
				for (var/datum/tooltip/tip in M.client.tooltipHolder.tooltips)
					if (tip.A == src)
						tip.A = null
				if (M.client.tooltipHolder.transient)
					if (M.client.tooltipHolder.transient.A == src)
						M.client.tooltipHolder.transient.A = null

		return ..()
	var/area/Ar = T.loc
	if (!(locate(/obj/table) in T) && !(locate(/obj/rack) in T))
		Ar.sims_score = min(Ar.sims_score + 4, 100)

	if (event_handler_flags & IS_TRINKET) //slow but fast as i can get for now, rewrite trinket holding later
		for(var/mob/living/carbon/human/M in mobs)
			if (M.trinket == src)
				M.trinket = null

	if (special_grab || chokehold)
		drop_grab()

	..()

/obj/item/proc/on_spin_emote(var/mob/living/carbon/human/user as mob)
	if ((user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50)) || (user.reagents && prob(user.reagents.get_reagent_amount("ethanol") / 2)) || prob(5))
		. = "<B>[user]</B> [pick("spins", "twirls")] [src] around in [his_or_her(user)] hand, and drops it right on the ground.[prob(10) ? " What an oaf." : null]"
		user.u_equip(src)
		src.set_loc(user.loc)
		JOB_XP(user, "Clown", 1)
	else
		. = "<B>[user]</B> [pick("spins", "twirls")] [src] around in [his_or_her(user)] hand."

/obj/item/proc/HY_set_species()
	return

/obj/item/proc/HY_set_mutation()
	return

/obj/item/proc/HY_set_strain()
	return

/obj/item/proc/registered_owner()
	.= 0


/obj/item/proc/force_drop(var/mob/possible_mob_holder = 0)
	if (!possible_mob_holder)
		if (ismob(src.loc))
			possible_mob_holder = src.loc

	if(possible_mob_holder)
		if (src in possible_mob_holder.equipped_list())
			if (possible_mob_holder.equipped() == src)
				possible_mob_holder.drop_item()
			else
				possible_mob_holder.hand = !possible_mob_holder.hand
				possible_mob_holder.drop_item()
				possible_mob_holder.hand = !possible_mob_holder.hand

/obj/item/proc/create_inventory_counter()
	src.inventory_counter = unpool(/obj/overlay/inventory_counter)
	src.vis_contents += src.inventory_counter

/obj/item/proc/dropped(mob/user)
	if (user)
		src.dir = user.dir
		#ifdef COMSIG_MOB_DROPPED
		SEND_SIGNAL(user, COMSIG_MOB_DROPPED, src)
		#endif
	if (src.c_flags & EQUIPPED_WHILE_HELD)
		src.unequipped(user)
	#ifdef COMSIG_ITEM_DROPPED
	SEND_SIGNAL(src, COMSIG_ITEM_DROPPED, user)
	#endif

	if(src.material) src.material.triggerDrop(user, src)
	if (islist(src.ability_buttons))
		for(var/obj/ability_button/B in ability_buttons)
			B.OnDrop()
	hide_buttons()
	clear_mob()
	if (src.inventory_counter)
		src.inventory_counter.hide_count()
	if (special_grab || chokehold)
		drop_grab()
	return

/obj/item/proc/pickup(mob/user)
	#ifdef COMSIG_ITEM_PICKUP
	SEND_SIGNAL(src, COMSIG_ITEM_PICKUP, user)
	#endif
	#ifdef COMSIG_MOB_PICKUP
	SEND_SIGNAL(user, COMSIG_MOB_PICKUP, src)
	#endif
	if(src.material)
		src.material.triggerPickup(user, src)
	set_mob(user)
	show_buttons()
	if (src.inventory_counter)
		src.inventory_counter.show_count()
	if (src.c_flags & EQUIPPED_WHILE_HELD)
		src.equipped(user, user.get_slot_from_item(src))

/obj/item/proc/intent_switch_trigger(mob/user)
	return
