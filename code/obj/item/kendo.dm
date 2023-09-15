//=====
//Armor
//=====

/obj/item/clothing/head/helmet/men
	name = "men"
	desc = "\improper 面 : A light padded helmet with a grilled faceplate to protect the user in a kendo match."
	icon_state = "men"
	item_state = "men"
	seal_hair = 1

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("heatprot", 5)
		setProperty("meleeprot_head", 2)

/obj/item/clothing/suit/armor/douandtare
	name = "dou and tare"
	desc = "\improper 胴と垂れ : A breastplate and padded skirt used primarily in kendo."
	icon_state = "dou-tare"
	item_state = "dou-tare"
	body_parts_covered = TORSO | LEGS
	bloodoverlayimage = SUITBLOOD_ARMOR

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("meleeprot", 4)
		setProperty("rangedprot", 0.4)
		setProperty("pierceprot", 1)
		setProperty("disorient_resist", 10)
		setProperty("movespeed", 1)

/obj/item/clothing/gloves/kote
	name = "kote"
	desc = "小手 : Big poofy gloves to cover the hands in kendo sparring."
	icon_state = "kote"
	item_state = "kote"
	material_prints = "navy blue, synthetic leather fibers"
	crit_override = 1
	bonus_crit_chance = 0
	stamina_dmg_mult = 0.35

	setupProperties()
		..()
		setProperty("coldprot", 7)
		setProperty("conductivity", 0.4)

//======
//Shinai
//======

/obj/item/shinai
	name = "shinai"
	desc = "\improper 竹刀 : A sword-like weapon made of slats of bamboo. Shinai are made to reflect the weight of a katana, but disperse impact on hit to minimize damage."
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "shinai"
	item_state = "shinai"
	wear_state = "shinai"

	w_class = W_CLASS_BULKY
	two_handed = 0
	throwforce = 4
	throw_range = 4
	stamina_crit_chance = 2

	//these combat variables will change depending on the guard
	var/default_force = 5
	var/default_stamina_damage = 10
	var/default_stamina_cost = 5

	custom_suicide = 1
	hitsound = 'sound/impact_sounds/bat_wood.ogg'

	hit_type = DAMAGE_BLUNT
	tool_flags = 0
	flags = FPRINT | TABLEPASS | USEDELAY
	c_flags = EQUIPPED_WHILE_HELD | ONBELT
	item_function_flags = USE_INTENT_SWITCH_TRIGGER | USE_SPECIALS_ON_ALL_INTENTS

	var/guard

	New()
		..()
		src.stat_reset()
		BLOCK_SETUP(BLOCK_SWORD)

	attack_self(mob/user as mob)
		if (src.two_handed == 1)
			if(user.updateTwoHanded(src, FALSE)) // should never fail, but respect error codes
				src.stat_reset()
		else
			if(user.updateTwoHanded(src, TRUE))
				src.two_handed = 1
		update_icon()
		user.update_inhands()

	proc/change_guard(var/mob/user,var/intent)
		user.do_disorient(10,0,0,0,0,0,null) // so that people can't cheese by swapping guards in one hand
		if(!src.two_handed)
			return
		guard = intent
		switch(guard)
			if("help")
				src.force = 5
				src.stamina_damage = 10
				src.stamina_cost = 5
				src.item_state = "shinai-light"
				src.setItemSpecial(/datum/item_special/simple/kendo_light)
			if("disarm")
				src.force = 6
				src.stamina_damage = 10
				src.stamina_cost = 8
				src.item_state = "shinai-sweep"
				src.setItemSpecial(/datum/item_special/swipe/kendo_sweep)
			if("grab")
				src.force = 6
				src.stamina_damage = 15
				src.stamina_cost = 10
				src.item_state = "shinai-thrust"
				src.setItemSpecial(/datum/item_special/rangestab/kendo_thrust)
			if("harm")
				src.force = 8
				src.stamina_damage = 30
				src.stamina_cost = 35
				src.item_state = "shinai-heavy"
				src.setItemSpecial(/datum/item_special/simple/kendo_heavy)
		user.update_inhands()
		src.buildTooltipContent()

	proc/parry_block_check(var/mob/living/carbon/human/attacker,var/mob/living/carbon/human/defender)
		if(attacker == defender)
			return

		if((attacker.a_intent == defender.a_intent) && !defender.hasStatus("disorient"))
			playsound(defender, "sound/impact_sounds/kendo_parry_[pick(1,2,3)].ogg", 50, 1)
			attacker.do_disorient(0,0,0,0,10,1)
			return 1

		else if(defender.hasStatus("blocking"))
			playsound(defender, "sound/impact_sounds/kendo_block_[pick(1,2)].ogg", 50, 1)
			if(attacker.equipped())
				defender.do_disorient((attacker.equipped().stamina_cost*1.5),0,0,0,0,1,null)
			return 2
		return 0

	proc/stat_reset()
		src.force = default_force
		src.stamina_damage = default_stamina_damage
		src.stamina_cost = default_stamina_cost
		src.w_class = W_CLASS_BULKY
		src.item_state = "shinai"
		src.two_handed = 0
		src.setItemSpecial()
		src.buildTooltipContent()

	intent_switch_trigger(mob/user as mob)
		if(guard != user.a_intent)
			change_guard(user,user.a_intent)

	attack(mob/living/carbon/human/defender, mob/living/carbon/human/attacker)
		if(!src.two_handed)
			..()
		if(!ishuman(defender))
			..()
		if(!defender.equipped())
			..()

		if (istype(defender.equipped(), /obj/item/shinai))
			var/obj/item/shinai/S = defender.equipped()
			var/parry_block = S.parry_block_check(attacker, defender)
			if((parry_block == 1) || (parry_block == 2))
				attacker.do_disorient((attacker.equipped().stamina_damage),0,0,0,0,1,null)
				return //stops damage if parried or blocked, if not, itll check for a disarm

		if((attacker.a_intent=="disarm") && prob(20))
			var/obj/item/I = defender.equipped()
			if (I.cant_drop)
				return
			defender.u_equip(I)
			I.set_loc(defender.loc)
			var/target_turf = get_offset_target_turf(I.loc,rand(5)-rand(5),rand(5)-rand(5))
			I.throw_at(target_turf,3,1)
			defender.show_text("<b>[attacker] knocks the [I] right out of your hands!</b>","red")
			attacker.show_text("<b>You knock the [I] right out of [defender]'s hands!</b>","green")
		..()

	attack_hand(mob/user)
		if(src.loc != user)
			change_guard(user,user.a_intent)
		..()

	dropped(mob/user as mob)
		..()
		stat_reset()

	suicide(var/mob/user as mob)
		user.visible_message("<span class='alert'><b>[user] bows and gently places the [src] on the ground.</b></span>")
		user.drop_item()
		var/say = pick("Take wa yowaku magaru ga ki wa tsuyoshi gouku tatsu.", "Kyoufu wa kokoro ga yurusu kagiri fukai monode shika nai.",
		"Mizu ni nagasu.", "Anshin shite shineru.", "Shiranu ga hotoke.", "Makeru ga kachi.", "Ashita wa ashita no kaze ga fuku.")
		user.say(say)
		var/sakura = image(icon = 'icons/obj/dojo.dmi', icon_state = "sakura_overlay", layer = EFFECTS_LAYER_BASE)
		user.UpdateOverlays(sakura, "sakura")
		user.do_disorient(300,0,0,0,0,1)
		user.changeStatus("stunned", 3 SECONDS)
		SPAWN(3 SECONDS)
			user.death(FALSE)
			user.UpdateOverlays(null, "sakura")
		return 1

//==========
//Shinai Bag
//==========

/obj/item/shinai_bag
	name = "shinai bag"
	desc = "\improper 竹刀袋 : A tube-like back for holding two shinai."
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	icon_state = "shinaibag-closed"
	item_state = "shinaibag-closed"
	flags = FPRINT | TABLEPASS
	c_flags = ONBACK
	w_class = W_CLASS_BULKY
	var/open = 0
	var/shinai = 2

	proc/update_sprite(var/mob/user)
		if(!open)
			src.icon_state = "shinaibag-closed"
			src.item_state = "shinaibag-closed"
		else
			src.icon_state = "shinaibag-[shinai+src.contents.len]"
			src.item_state = "shinaibag-[shinai+src.contents.len]"

		if(src.loc == user)
			user.update_clothing()
			user.update_inhands()

	proc/draw_shinai(var/mob/user)
		if(!src.contents.len && !shinai)
			user.show_text("The [src] is empty!","red")
			return

		var/obj/item/shinai/S
		if(src.contents.len)
			S = src.contents[1]
		else if(shinai)
			S = new /obj/item/shinai
			shinai--

		update_sprite(user)
		user.put_in_hand_or_drop(S)
		S.change_guard(user,user.a_intent)
		update_sprite(user)

	attack_self(mob/user as mob)
		open = !open
		update_sprite(user)

	attack_hand(mob/user)
		if(src.loc == user)
			if(open)
				draw_shinai(user)
			else
				open = !open
				update_sprite(user)
		else if((user.a_intent == "grab") && open)
			draw_shinai(user)
		else
			..()

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/shinai) && open && shinai + length(src.contents) < 2)
			user.u_equip(W)
			W.set_loc(src)
			update_sprite(user)
		else
			..()

	mouse_drop(atom/over_object, src_location, over_location)
		..()
		var/atom/movable/screen/hud/S = over_object
		if (istype(S))
			playsound(src.loc, "rustle", 50, 1, -5)
			if (can_act(usr) && src.loc == usr)
				if (S.id == "rhand")
					if (!usr.r_hand)
						usr.u_equip(src)
						usr.put_in_hand_or_drop(src, 0)
				else
					if (S.id == "lhand")
						if (!usr.l_hand)
							usr.u_equip(src)
							usr.put_in_hand_or_drop(src, 1)

/obj/item/storage/box/kendo_box
	name = "kendo box"
	desc = "A box full of kendo gear!"
	icon_state = "sushibox"
	spawn_contents = list(/obj/item/clothing/head/helmet/men=2,/obj/item/clothing/suit/armor/douandtare=2,/obj/item/clothing/gloves/kote=2,/obj/item/shinai_bag=1)

/obj/item/storage/box/kendo_box/hakama
	name = "uwagi and hakama box"
	desc = "A box full of sets of uwagi and hakama!"
	icon_state = "box"
	spawn_contents = list(/obj/item/clothing/under/gimmick/hakama/random=7)
