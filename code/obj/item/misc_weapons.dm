// Contains:
//
// - Esword
// - Dagger
// - Butcher's knife
// - Axe
// - Fireaxe
// - Baseball Bat
// - Ban me
// - Katana
// - Reverse Katana
// - Captain's Sword
// - Nukeop Commander's Sword
// - Bloodthirsty Blade
// - Fragile Sword


/// Cyalume saber/esword, famed traitor item
/obj/item/sword
	name = "cyalume saber"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "sword0"
	uses_multiple_icon_states = 1
	inhand_image_icon = 'icons/mob/inhand/hand_cswords.dmi'
	item_state = "sword0"
	var/active = 0
	var/open = 0
	var/use_glowstick = 1
	var/obj/item/device/light/glowstick/loaded_glowstick = null
	var/bladecolor = "invalid"
	var/robusted = 0
	var/list/valid_colors = list("R","O","Y","G","C","B","P","Pi","W")
	hit_type = DAMAGE_BLUNT
	force = 1
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	health = 7
	w_class = W_CLASS_SMALL
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY
	tool_flags = TOOL_CUTTING
	is_syndicate = 1
	mats = list("MET-1"=5, "CON-2"=5, "POW-3"=10)
	contraband = 5
	desc = "An illegal, recalled Super Protector Friend glow sword. When activated, uses energized cyalume to create an extremely dangerous saber. Can be concealed when deactivated."
	stamina_damage = 35 // This gets applied by obj/item/attack, regardless of if the saber is active.
	stamina_cost = 5
	stamina_crit_chance = 35
	var/active_force = 60
	var/active_stamina_dmg = 40
	var/active_stamina_cost = 40
	var/inactive_stamina_dmg = 35
	var/inactive_force = 1
	var/inactive_stamina_cost = 5
	var/state_name = "sword"
	var/off_w_class = W_CLASS_SMALL
	var/datum/component/loctargeting/simple_light/light_c
	var/do_stun = 0

	stunner
		do_stun = 1

	New()
		..()
		if(src.bladecolor == "invalid")
			src.bladecolor = pick(valid_colors)
		var/r = 0
		var/g = 0
		var/b = 0
		if (prob(1))
			src.bladecolor = null
		switch(src.bladecolor)
			if("R")
				r = 255
				src.loaded_glowstick = new /obj/item/device/light/glowstick/red(src)
			if("O")
				r = 255; g = 127
				src.loaded_glowstick = new /obj/item/device/light/glowstick/orange(src)
			if("Y")
				r = 255; g = 255
				src.loaded_glowstick = new /obj/item/device/light/glowstick/yellow(src)
			if("G")
				g = 255
				src.loaded_glowstick = new /obj/item/device/light/glowstick(src)
			if("C")
				b = 255; g = 200
				src.loaded_glowstick = new /obj/item/device/light/glowstick/cyan(src)
			if("B")
				b = 255
				src.loaded_glowstick = new /obj/item/device/light/glowstick/blue(src)
			if("P")
				r = 153; b = 255
				src.loaded_glowstick = new /obj/item/device/light/glowstick/purple(src)
			if("Pi")
				r = 255; g = 121; b = 255
				src.loaded_glowstick = new /obj/item/device/light/glowstick/pink(src)
			if("W")
				r = 255; g = 255; b = 255
				src.loaded_glowstick = new /obj/item/device/light/glowstick/white(src)
			else
				src.loaded_glowstick = new /obj/item/device/light/glowstick/white(src)
		src.loaded_glowstick.turnon()

		light_c = src.AddComponent(/datum/component/loctargeting/simple_light, r, g, b, 150)
		light_c.update(0)
		src.setItemSpecial(/datum/item_special/swipe/csaber)
		AddComponent(/datum/component/itemblock/saberblock, .proc/can_reflect, .proc/get_reflect_color)
		BLOCK_SETUP(BLOCK_SWORD)

/obj/item/sword/proc/can_reflect()
	return src.active

/obj/item/sword/proc/get_reflect_color()
	return get_hex_color_from_blade(src.bladecolor)

/obj/item/sword/attack(mob/target, mob/user, def_zone, is_special = 0)
	if(active)
		if (handle_parry(target, user))
			return 1
		if (do_stun)
			target.do_disorient(150, weakened = 50, stunned = 50, disorient = 40, remove_stamina_below_zero = 0)

		var/age_modifier = 0
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			age_modifier = 30 - H.bioHolder.age

		if(user.gender == MALE) playsound(user, pick('sound/weapons/male_cswordattack1.ogg','sound/weapons/male_cswordattack2.ogg'), 70, 5, 0, clamp(1.0 + age_modifier/60, 0.7, 1.2))
		else playsound(user, pick('sound/weapons/female_cswordattack1.ogg','sound/weapons/female_cswordattack2.ogg'), 70, 5, 0, clamp(1.0 + age_modifier/50, 0.7, 1.4))
		..()
	else
		if (user.a_intent == INTENT_HELP)
			user.visible_message("<span class='combat bold'>[user] [pick_string("descriptors.txt", pick("mopey", "borg_shake"))] baps [target] on the [pick("nose", "forehead", "wrist", "chest")] with \the [src]'s handle!</span>")
			if(prob(3))
				SPAWN(0.2 SECONDS)
					target.visible_message("<span class='bold'>[target.name]</span> flops over in shame!")
					target.changeStatus("stunned", 5 SECONDS)
					target.changeStatus("weakened", 5 SECONDS)
		else
			..()

/obj/item/sword/proc/get_hex_color_from_blade(var/C as text)
	switch(C)
		if("R")
			return "#FF0000"
		if("O")
			return "#FF9A00"
		if("Y")
			return "#FFFF00"
		if("G")
			return "#00FF78"
		if("C")
			return "#00FFFF"
		if("B")
			return "#0081DF"
		if("P")
			return "#CC00FF"
		if("Pi")
			return "#FFCCFF"
		if("W")
			return "#EBE6EB"
	return "RAND"

/obj/item/sword/proc/handle_parry(mob/target, mob/user)
	if (target != user && ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/sword/S = H.find_type_in_hand(/obj/item/sword, "right")
		if (!S)
			S = H.find_type_in_hand(/obj/item/sword, "left")
		if (S && S.active && !(H.lying || isdead(H) || H.hasStatus("stunned", "weakened", "paralysis")))
			var/obj/itemspecialeffect/clash/C = new /obj/itemspecialeffect/clash
			if(target.gender == MALE) playsound(target, pick('sound/weapons/male_cswordattack1.ogg','sound/weapons/male_cswordattack2.ogg'), 70, 0, 5, clamp(1.0 + (30 - H.bioHolder.age)/60, 0.7, 1.2))
			else playsound(target, pick('sound/weapons/female_cswordattack1.ogg','sound/weapons/female_cswordattack2.ogg'), 70, 0, 5, clamp(1.0 + (30 - H.bioHolder.age)/50, 0.7, 1.4))
			C.setup(H.loc)
			var/matrix/m = matrix()
			m.Turn(rand(0,360))
			C.transform = m
			var/matrix/m1 = C.transform
			m1.Scale(2,2)
			C.pixel_x = 32*(user.x - target.x)*0.5
			C.pixel_y = 32*(user.y - target.y)*0.5
			animate(C,transform=m1,time=8)
			H.remove_stamina(40)
			if (ishuman(user))
				var/mob/living/carbon/human/U = user
				U.remove_stamina(15)

			return 1
	return 0


/obj/item/sword/attack_self(mob/user as mob)
	if (use_glowstick)
		if (open)
			return

		if (!loaded_glowstick)
			boutput(user, "<span class='alert'>The sword emits a brief flash of light and turns off! The blade-focus glowstick seems to be missing.</span>")
			playsound(user, 'sound/items/zippo_close.ogg', 60, 1)
			return

		if (!loaded_glowstick.on)
			boutput(user, "<span class='alert'>The sword emits a brief flash of light and turns off! The blade-focus glowstick hasn't been cracked!</span>")
			playsound(user, 'sound/items/zippo_close.ogg', 60, 1)
			return

	if (user.bioHolder.HasEffect("clumsy") && prob(50))
		user.visible_message("<span class='alert'><b>[user]</b> fumbles [src] and cuts [himself_or_herself(user)].</span>")
		user.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 5, 5)
		take_bleeding_damage(user, user, 5)
		JOB_XP(user, "Clown", 1)
	src.active = !( src.active )
	tooltip_rebuild = 1
	if (src.active)
		src.UpdateIcon()
		SET_BLOCKS(BLOCK_ALL)
		boutput(user, "<span class='notice'>The sword is now active.</span>")
		hit_type = DAMAGE_CUT
		stamina_damage = active_stamina_dmg
		if(ishuman(user) && !ON_COOLDOWN(src, "playsound_on", 2 SECONDS))
			var/mob/living/carbon/human/U = user
			if(U.gender == MALE) playsound(U,'sound/weapons/male_cswordturnon.ogg', 70, 0, 5, clamp(1.0 + (30 - U.bioHolder.age)/60, 0.7, 1.2))
			else playsound(U,'sound/weapons/female_cswordturnon.ogg' , 100, 0, 5, clamp(1.0 + (30 - U.bioHolder.age)/50, 0.7, 1.4))
		src.force = active_force
		src.stamina_cost = active_stamina_cost
		src.w_class = W_CLASS_BULKY
		user.unlock_medal("The Force is strong with this one", 1)
	else
		src.UpdateIcon()
		SET_BLOCKS(BLOCK_SWORD)
		boutput(user, "<span class='notice'>The sword can now be concealed.</span>")
		hit_type = DAMAGE_BLUNT
		stamina_damage = inactive_stamina_dmg
		if(ishuman(user) && !ON_COOLDOWN(src, "playsound_off", 2 SECONDS))
			var/mob/living/carbon/human/U = user
			if(U.gender == MALE) playsound(U,'sound/weapons/male_cswordturnoff.ogg', 70, 0, 5, clamp(1.0 + (30 - U.bioHolder.age)/60, 0.7, 1.2))
			else playsound(U,'sound/weapons/female_cswordturnoff.ogg', 100, 0, 5, clamp(1.0 + (30 - U.bioHolder.age)/50, 0.7, 1.4))
		src.force = inactive_force
		src.stamina_cost = inactive_stamina_cost
		src.w_class = off_w_class
	user.update_inhands()
	src.add_fingerprint(user)
	..()

/obj/item/sword/custom_suicide = 1
/obj/item/sword/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	if (!src.active)
		return 0

	user.visible_message("<span class='alert'><b>[user] stabs [src] through [his_or_her(user)] chest.</b></span>")
	take_bleeding_damage(user, null, 250, DAMAGE_STAB)
	user.TakeDamage("chest", 200, 0)
	SPAWN(50 SECONDS)
		if (user && !isdead(user))
			user.suiciding = 0
	return 1

/obj/item/sword/attackby(obj/item/W, mob/user, params)
	if (!use_glowstick)
		return ..()

	if (isscrewingtool(W))
		if (src.active)
			boutput(user, "<span class='alert'>The sword has to be off before you open it!</span>")
			return

		if (!src.open)
			if (!src.bladecolor) //rainbow
				boutput(user, "<span class='alert'>This sword cannot be modified.</span>")
				return

			user.visible_message("<b>[user]</b> unscrews and opens [src].")
			playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
			src.open = 1
			if (loaded_glowstick)
				src.icon_state = "[state_name]-open-[bladecolor]"
			else
				src.icon_state = "[state_name]-open"
			return
		else if (src.open && src.bladecolor)
			user.visible_message("<b>[user]</b> closes and screws [src] shut.")
			playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
			src.open = 0
			src.icon_state = "[state_name]0"
		else
			boutput(user, "<span class='alert'>The screw spins freely in place without a blade to screw into.</span>")
			playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
			return

	if (istype(W, /obj/item/device/light/glowstick) && !loaded_glowstick && open)
		if (!W:on)
			boutput(user, "<span class='alert'>The glowstick needs to be on to act as a beam focus for the sword!</span>")
			return
		else
			user.visible_message("<b>[user]</b> loads a glowstick into [src].")
			loaded_glowstick = W
			W.set_loc(src)
			user.u_equip(W)
			var/datum/component/loctargeting/simple_light/light_c = src.GetComponent(/datum/component/loctargeting/simple_light)
			switch(src.loaded_glowstick.color_name)
				if("red")
					light_c.set_color(255, 0, 0)
					src.bladecolor = "R"
				if("orange")
					light_c.set_color(255, 127, 0)
					src.bladecolor = "O"
				if("yellow")
					light_c.set_color(255, 255, 0)
					src.bladecolor = "Y"
				if("green")
					light_c.set_color(0, 255, 0)
					src.bladecolor = "G"
				if("cyan")
					light_c.set_color(0, 200, 255)
					src.bladecolor = "C"
				if("blue")
					light_c.set_color(0, 0, 255)
					src.bladecolor = "B"
				if("purple")
					light_c.set_color(153, 0, 255)
					src.bladecolor = "P"
				if("pink")
					light_c.set_color(255, 121, 255)
					src.bladecolor = "Pi"
				if("white")
					light_c.set_color(255, 255, 255)
					src.bladecolor = "W"
			src.icon_state = "[state_name]-open-[bladecolor]"
			var/datum/item_special/swipe/csaber/S = src.special
			S.swipe_color = get_hex_color_from_blade(src.bladecolor)
			return
	else
		return ..()

/obj/item/sword/attack_hand(mob/user)
	if (src.open && src.loc == user)
		if (src.loaded_glowstick && src.use_glowstick)
			user.put_in_hand(loaded_glowstick)
			src.loaded_glowstick = null
			src.bladecolor = null
			src.icon_state = "[state_name]-open"
			return
	..()

/obj/item/sword/update_icon()
	. = ..()
	var/datum/component/loctargeting/simple_light/light_c = src.GetComponent(/datum/component/loctargeting/simple_light)
	if (src.active)
		if(robusted)
			src.icon_state = "iaxe1"
			src.item_state = "iaxe1"
		else
			src.icon_state = "[state_name]1-[src.bladecolor]"
			src.item_state = "[state_name]1-[src.bladecolor]"
			flick("sword_extend-[src.bladecolor]", src)
		light_c.update(TRUE)
	else
		if(robusted)
			src.icon_state = "iaxe0"
			src.item_state = "iaxe0"
		else

			src.icon_state = "[state_name]0"
			src.item_state = "[state_name]0"
			flick("sword_retract-[src.bladecolor]", src)
		light_c.update(FALSE)

/obj/item/sword/red
	bladecolor = "R"

	enakai
		active = 1;
		active_force = 5
		desc = "You were the chosen one! You were supposed to destroy the greytiders, not join them!";
		icon_state = "sword1-R";
		item_state = "sword1-R";
		name = "Enakai's red cyalume saber"

		pickup(mob/user)
			if(isadmin(user) || current_state == GAME_STATE_FINISHED)
				src.active_force = 60
				if(src.active)
					src.force = 60
			else
				boutput(user, "<span class='notice'>You feel that it was too soon for this...</span>")
			. = ..()

/obj/item/sword/orange
	bladecolor = "O"

/obj/item/sword/yellow
	bladecolor = "Y"

/obj/item/sword/green
	bladecolor = "G"

/obj/item/sword/cyan
	bladecolor = "C"

/obj/item/sword/blue
	bladecolor = "B"

/obj/item/sword/purple
	bladecolor = "P"

/obj/item/sword/pink
	bladecolor = "Pi"

/obj/item/sword/white
	bladecolor = "W"

/obj/item/sword/rainbow
	bladecolor = null

/obj/item/sword/vr
	icon = 'icons/effects/VR.dmi'
	inhand_image_icon = 'icons/effects/VR_csaber_inhand.dmi'
	valid_colors = list("R","Y","G","C","B","P","W","Bl")
	use_glowstick = 0

/obj/item/sword/old
	icon = 'icons/obj/items/oldsaber.dmi'
	use_glowstick = 0

/obj/item/sword/discount
	name = "d-saber"
	desc = "A discount cyalume saber. Commonly called a d-saber."
	state_name = "d_sword"
	icon_state = "d_sword0"
	item_state = "d_sword0"
	w_class = W_CLASS_NORMAL
	off_w_class = W_CLASS_NORMAL
	active_force = 18
	inactive_force = 8
	active_stamina_dmg = 65
	inactive_stamina_dmg = 30
	hit_type = DAMAGE_BLUNT

	can_reflect()
		return FALSE

	get_desc()
		..()
		. += "It is set to [src.active ? "on" : "off"]."

/obj/item/sword/discount/attack(mob/target, mob/user, def_zone, is_special = 0)
	//hhaaaaxxxxxxxx. overriding the disorient for my own effect
	if (active)
		hit_type = DAMAGE_BURN
	else
		hit_type = DAMAGE_BLUNT

	//returns TRUE if parried. So stop here
	if (..())
		return

	if (active)
		target.do_disorient(0, weakened = 0, stunned = 0, disorient = 30, remove_stamina_below_zero = 0)

///////////////////////////////////////////////// Dagger /////////////////////////////////////////////////

/obj/item/dagger
	name = "sacrificial dagger"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "dagger"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = "knife"
	force = 5
	throwforce = 15
	throw_range = 5
	hit_type = DAMAGE_STAB
	w_class = W_CLASS_SMALL
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY
	tool_flags = TOOL_CUTTING
	desc = "Gets the blood to run out juuuuuust right. Looks like this could be nasty when thrown."
	burn_type = 1
	stamina_damage = 15
	stamina_cost = 5
	stamina_crit_chance = 50
	pickup_sfx = 'sound/items/blade_pull.ogg'
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)

/obj/item/dagger/overwrite_impact_sfx(original_sound, hit_atom, thr)
	. = ..()
	if(ismob(hit_atom))
		. = 'sound/impact_sounds/Flesh_Stab_3.ogg'


/obj/item/dagger/throw_impact(atom/A, datum/thrown_thing/thr)
	if (..())
		return
	if(ismob(A))
		var/mob/M = A
		if (ismob(usr))
			M.lastattacker = usr
			M.lastattackertime = world.time
		M.changeStatus("weakened", 6 SECONDS)
		M.force_laydown_standup()
		take_bleeding_damage(M, null, 5, DAMAGE_CUT)

/obj/item/dagger/attack(target, mob/user)
	if(ismob(target))
		take_bleeding_damage(target, user, 5, DAMAGE_STAB)
	..()

/obj/item/dagger/smile
	name = "switchblade"
	force = 10
	throw_range = 10
	throwforce = 10

/obj/item/dagger/smile/attack(mob/living/target, mob/user)
	if(prob(10))
		var/say = pick("Why won't you smile?","Smile!","Why aren't you smiling?","Why is nobody smiling?","Smile like you mean it!","That is not a smile!","Smile, [target.name]!","I will make you smile, [target.name].","[target.name] didn't smile!")
		user.say(say)
	..()

/obj/item/dagger/syndicate
	name = "syndicate dagger"
	desc = "An ornamental dagger for syndicate higher-ups. It sounds fancy, but it's basically the munitions company equivalent of those glass cubes with the company logo frosted on."

/obj/item/dagger/syndicate/specialist //Infiltrator class knife
	name = "syndicate fighting utility knife"
	desc = "A light but robust combat knife that allows you to move faster in fights. Knocks down targets when thrown."
	icon_state = "combat_knife"
	force = 15
	throwforce = 20
	stamina_cost = 5
	c_flags = EQUIPPED_WHILE_HELD

	setupProperties()
		..()
		setProperty("movespeed", -0.5)

/obj/item/dagger/throwing_knife
	name = "cheap throwing knife"
	// icon = 'icons/obj/items/weapons.dmi'
	icon_state = "throwing_knife"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "ninjaknife"
	force = 8
	throwforce = 11
	throw_range = 10
	flags = FPRINT | TABLEPASS | USEDELAY //| NOSHIELD
	desc = "Like many knives, these can be thrown. Unlike many knives, these are made to be thrown."


	throw_impact(atom/A, datum/thrown_thing/thr)
		if(iscarbon(A))
			var/mob/living/carbon/C = A
			C.do_disorient(stamina_damage = 60, weakened = 0, stunned = 0, disorient = 40, remove_stamina_below_zero = 1)
			C.emote("twitch_v")
			A:lastattacker = usr
			A:lastattackertime = world.time
			random_brute_damage(C, throwforce, 1)

			take_bleeding_damage(A, null, 5, DAMAGE_CUT)
			playsound(src, 'sound/impact_sounds/Flesh_Stab_3.ogg', 40, 1)

/obj/item/dagger/throwing_knife/tele
	name = "portable knife"
	icon_state = "teleport_knife"

	throw_impact(atom/A, datum/thrown_thing/thr)
		..()
		if (isrestrictedz(src.z) || isrestrictedz(usr.z))
			return
		usr.set_loc(get_turf(src))
		usr.put_in_hand(src)

/obj/item/storage/box/shuriken_pouch
	name = "Shuriken Pouch"
	desc = "Contains four throwing stars!"
	icon_state = "ammopouch"
	spawn_contents = list(/obj/item/implant/projectile/shuriken = 4)

/obj/item/implant/projectile/shuriken
	name = "shuriken"
	desc = "A cheap replica of an ancient japanese throwing star."
	object_flags = NO_GHOSTCRITTER
	w_class = W_CLASS_TINY
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "shuriken"
	throw_spin = 1
	throw_speed = 4

	throw_impact(M)
		..()
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			H.implant.Add(src)
			src.visible_message("<span class='alert'>[src] gets embedded in [M]!</span>")
			playsound(src.loc, 'sound/impact_sounds/Flesh_Cut_1.ogg', 100, 1)
			H.changeStatus("weakened", 2 SECONDS)
			src.set_loc(M)
			src.implanted = 1
		random_brute_damage(M, 11)//embedding cares not for your armour
		take_bleeding_damage(M, null, 3, DAMAGE_CUT)

/obj/item/nunchucks
	name = "nunchucks"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "nunchucks"
	item_state = "nunchucks"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	force = 8
	throwforce = 6
	throw_range = 7
	hit_type = DAMAGE_BLUNT
	w_class = W_CLASS_SMALL
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY
	desc = "An ancient and questionably effective weapon."
	burn_type = 0
	stamina_damage = 45
	stamina_cost = 20
	stamina_crit_chance = 60
	// pickup_sfx = 'sound/items/blade_pull.ogg'

	New()
		..()
		src.setItemSpecial(/datum/item_special/nunchucks)
		BLOCK_SETUP(BLOCK_ROPE)

/obj/item/quarterstaff
	name = "quarterstaff"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "quarterstaff"
	item_state = "quarterstaff"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	uses_multiple_icon_states = 1
	force = 13
	throwforce = 6
	throw_range = 5
	hit_type = DAMAGE_BLUNT
	w_class = W_CLASS_NORMAL
	object_flags = NO_ARM_ATTACH
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY
	c_flags = EQUIPPED_WHILE_HELD
	desc = "An ancient and effective weapon. It's not just a stick alright!"
	stamina_damage = 65
	stamina_cost = 22
	stamina_crit_chance = 60
	// pickup_sfx = 'sound/items/blade_pull.ogg'
	// can_disarm = 1
	two_handed = 0
	var/use_two_handed = 1
	var/status = FALSE
	var/one_handed_force = 7
	var/two_handed_force = 13

	New()
		..()
		src.setItemSpecial(/datum/item_special/simple)
		BLOCK_SETUP(BLOCK_ROD)

	attack_self(mob/user as mob)
		src.add_fingerprint(user)

		if (!use_two_handed || setTwoHanded(!src.status))
			src.status = !src.status
			// playsound(src, "sparks", 75, 1, -1)
			if (src.status)
				setProperty("meleeprot", 3)
				setProperty("movespeed", 0.1)
				force = two_handed_force
				src.setItemSpecial(/datum/item_special/nunchucks)
			else
				setProperty("meleeprot", 0)
				setProperty("movespeed", 0)
				force = one_handed_force
				src.setItemSpecial(/datum/item_special/simple)

			user.update_equipped_modifiers() // Call the bruteforce movement modifier proc because we changed movespeed while equipped

			can_disarm = src.status
			item_state = status ? "quarterstaff2" : "quarterstaff1"
			user.update_inhands()
		else
			user.show_text("You need two free hands in order to activate the [src.name].", "red")

		..()

	dropped(mob/user)
		if (src.status)
			setTwoHanded(FALSE)
			src.status = FALSE
		..()

////////////////////////////////////////// Butcher's knife /////////////////////////////////////////

/obj/item/knife/butcher //Idea stolen from the welder!
	name = "Butcher's Knife"
	desc = "A huge knife."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife_b"
	item_state = "knife_b"
	force = 5
	throwforce = 15
	throw_speed = 4
	throw_range = 8
	w_class = W_CLASS_NORMAL
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY
	tool_flags = TOOL_CUTTING
	hit_type = DAMAGE_STAB
	var/makemeat = 1

/obj/item/knife/butcher/New()
	..()
	BLOCK_SETUP(BLOCK_KNIFE)

/obj/item/knife/butcher/throw_impact(atom/A, datum/thrown_thing/thr)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if (C.spellshield)
			return ..()
		if (ismob(usr))
			A:lastattacker = usr
			A:lastattackertime = world.time
		C.changeStatus("weakened", 6 SECONDS)
		C.force_laydown_standup()
		random_brute_damage(C, 20,1)
		take_bleeding_damage(C, null, 10, DAMAGE_CUT)

		playsound(src, 'sound/impact_sounds/Flesh_Stab_3.ogg', 40, 1)
	else
		..()

/obj/item/knife/butcher/attack(target, mob/user)
	if (!istype(src,/obj/item/knife/butcher/hunterspear) && ishuman(target) && ishuman(user))
		if (scalpel_surgery(target,user))
			return

	playsound(target, 'sound/impact_sounds/Flesh_Stab_1.ogg', 60, 1)

	if (iscarbon(target))
		var/mob/living/carbon/C = target
		if (!isdead(C))
			random_brute_damage(C, 20,1)//no more AP butcher's knife, jeez
			take_bleeding_damage(C, user, 10, DAMAGE_STAB)
		else
			if (src.makemeat)
				logTheThing(LOG_COMBAT, user, "butchers [C]'s corpse with the [src.name] at [log_loc(C)].")
				for (var/i in 0 to 2)
					new /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat(get_turf(C),C)
				if (C.mind)
					C.ghostize()
					qdel(C)
					return
				else
					qdel(C)
					return
	..()
	return

/obj/item/knife/butcher/custom_suicide = 1
/obj/item/knife/butcher/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	user.visible_message("<span class='alert'><b>[user] slashes [his_or_her(user)] own throat with [src]!</b></span>")
	blood_slash(user, 25)
	user.TakeDamage("head", 150, 0)
	return 1

/////////////////////////////////////////////////// Hunter Spear ////////////////////////////////////////////

/obj/item/knife/butcher/hunterspear
	name = "Hunting Spear"
	desc = "A very large, sharp spear."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "hunter_spear"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "hunter_spear"
	force = 8
	throwforce = 35
	throw_speed = 6
	throw_range = 10
	makemeat = 0
	var/hunter_key = "" // The owner of this spear.

	New()
		..()
		if(istype(src.loc, /mob/living))
			var/mob/M = src.loc
			src.AddComponent(/datum/component/self_destruct, M)
			src.AddComponent(/datum/component/send_to_target_mob, src)
			src.hunter_key = M.mind.key
			START_TRACKING_CAT(TR_CAT_HUNTER_GEAR)
			flick("[src.icon_state]-tele", src)

	disposing()
		. = ..()
		if (hunter_key)
			STOP_TRACKING_CAT(TR_CAT_HUNTER_GEAR)

/////////////////////////////////////////////////// Axe ////////////////////////////////////////////

/obj/item/axe
	name = "TN-DOLORIS Axe"
	desc = "An energised battle axe. The handle bears the insignia of the Terra Nivium company."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "axe0"
	uses_multiple_icon_states = 1
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	var/active = 0
	hit_type = DAMAGE_CUT
	force = 40
	throwforce = 25
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL
	contraband = 80
	flags = FPRINT | CONDUCT | NOSHIELD | TABLEPASS | USEDELAY
	tool_flags = TOOL_CUTTING
	stamina_damage = 50
	stamina_cost = 45
	stamina_crit_chance = 5


	New()
		..()
		BLOCK_SETUP(BLOCK_ROD)


// vvv what the heck why?? vvv
//obj/item/axe/attack(target, mob/user)
//	..()

/obj/item/axe/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		boutput(user, "<span class='notice'>The axe is now energised.</span>")
		src.hit_type = DAMAGE_BURN
		src.force = 150
		src.icon_state = "axe1"
		src.w_class = W_CLASS_HUGE
	else
		boutput(user, "<span class='notice'>The axe can now be concealed.</span>")
		src.hit_type = DAMAGE_CUT
		src.force = 40
		src.icon_state = "axe0"
		src.w_class = W_CLASS_HUGE
	src.add_fingerprint(user)
	user.update_inhands()
	return

/obj/item/axe/custom_suicide = 1
/obj/item/axe/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	user.visible_message("<span class='alert'><b>[user] slashes [his_or_her(user)] own throat with [src]!</b></span>")
	blood_slash(user, 25)
	user.TakeDamage("head", 150, 0)
	return 1

/obj/item/axe/vr
	icon = 'icons/effects/VR.dmi'

/////////////////////////////////////////////////// Fire Axe ////////////////////////////////////////////

/obj/item/fireaxe
	name = "fire axe"
	desc = "An axe with a pick-shaped end on the back, intended to be used to get through doors and windows in an emergency."
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "fireaxe"
	item_state = "fireaxe"
	hitsound = null
	flags = FPRINT | CONDUCT | TABLEPASS | USEDELAY | ONBELT
	object_flags = NO_ARM_ATTACH
	tool_flags = TOOL_CUTTING | TOOL_CHOPPING //TOOL_CHOPPING flagged items do 4 times as much damage to doors.
	hit_type = DAMAGE_CUT
	click_delay = 10
	two_handed = 0

	w_class = W_CLASS_NORMAL
	force = 20
	throwforce = 10
	throw_speed = 2
	throw_range = 4
	stamina_damage = 25
	stamina_cost = 15
	stamina_crit_chance = 5

	proc/set_values()
		if(two_handed)
			src.click_delay = COMBAT_CLICK_DELAY * 1.5
			force = 40
			throwforce = 25
			throw_speed = 4
			throw_range = 8
			stamina_damage = 45
			stamina_cost = 25
			stamina_crit_chance = 10
		else
			src.click_delay = COMBAT_CLICK_DELAY
			force = 20
			throwforce = 10
			throw_speed = 2
			throw_range = 4
			stamina_damage = 25
			stamina_cost = 15
			stamina_crit_chance = 5
		tooltip_rebuild = 1
		return

	attack_self(mob/user as mob)
		if(ishuman(user))
			if(two_handed)
				setTwoHanded(0) //Go 1-handed.
				set_values()
			else
				if(!setTwoHanded(1)) //Go 2-handed.
					boutput(user, "<span class='alert'>Can't switch to 2-handed while your other hand is full.</span>")
				else
					set_values()
		..()

	attack_hand(var/mob/user) // todo: maybe make the base/twohand delays into vars. maybe.
		src.two_handed = 0
		set_values()
		return ..()

	attack(mob/target, mob/user)
		..()
		// ugly but basically we make it louder and slightly downpitched if we're 2 handing
		playsound(target, 'sound/impact_sounds/Fireaxe.ogg', 30 * (1 + src.two_handed), pitch=(1 - 0.3 * src.two_handed))

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_ROD)

///////////////////////////////// Baseball Bat ////////////////////////////////////////////////////////////

/obj/item/bat
	name = "Baseball Bat"
	desc = "Play ball! Note: Batter is responsible for any injuries sustained due to ball-hitting."
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "baseballbat"
	item_state = "baseballbat"
	hit_type = DAMAGE_BLUNT
	force = 12
	throwforce = 7
	stamina_damage = 24
	stamina_cost = 30
	stamina_crit_chance = 15
	mats = list("wood" = 8)

	attack(mob/M, mob/user, def_zone, is_special)
		. = ..()
		attack_twitch(user, 3, 2)

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		src.AddComponent(/datum/component/holdertargeting/baseball_bat_reflect)
		BLOCK_SETUP(BLOCK_ROD)

/obj/item/ratstick
	name = "rat stick"
	desc = "Used for killing rats... Among other things."
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "ratstick"
	item_state = "ratstick"
	hit_type = DAMAGE_BLUNT
	force = 10
	throwforce = 7
	stamina_damage = 35
	stamina_cost = 25
	stamina_crit_chance = 35

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_ROD)

	attack(var/atom/A, var/mob/user)
		if (prob(50))
			hit_type = DAMAGE_BLUNT
			hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
		else
			hit_type = DAMAGE_CUT
			hitsound = 'sound/impact_sounds/Blade_Small_Bloody.ogg'
		return ..()
/////////////////////////////////////////////////// Ban me ////////////////////////////////////////////

/obj/item/banme
	name = "ban me"
	desc = "Sometimes known as a... what is this?"
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "banh_mi"
	force = 0
	throwforce = 0
	throw_speed = 3
	throw_range = 7

/obj/item/banme/attack(mob/M, mob/user)
	boutput(M, "<span class='alert'><b>You have been BANNED by [user]!</b></span>")
	boutput(user, "<span class='alert'><b>You have BANNED [M]!</b></span>")
	playsound(loc, 'sound/vox/banned.ogg', 60, 1)
	return

/////////////////////////////////////////////////// Swords ////////////////////////////////////////////
//You probably want to spawn the sheath in instead of this.
/obj/item/swords
	name = "youshouldntseeme sword"
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	hit_type = DAMAGE_CUT
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY
	tool_flags = TOOL_CUTTING
	w_class = W_CLASS_BULKY
	force = 10
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	contraband = 4
	attack_verbs = "slashes"
	hitsound = 'sound/impact_sounds/Blade_Small_Bloody.ogg'
	is_syndicate = TRUE
	var/delimb_prob = 1
	custom_suicide = 1

/obj/item/swords/proc/handle_parry(mob/target, mob/user)
	if (target != user && ishuman(target))
		var/mob/living/carbon/human/H = target
		if (H.find_type_in_hand(/obj/item/swords, "right") || H.find_type_in_hand(/obj/item/swords, "left"))
			var/obj/itemspecialeffect/clash/C = new /obj/itemspecialeffect/clash
			playsound(target, pick('sound/effects/sword_clash1.ogg','sound/effects/sword_clash2.ogg','sound/effects/sword_clash3.ogg'), 70, 0, 0)
			C.setup(H.loc)
			var/matrix/m = matrix()
			m.Turn(rand(0,360))
			C.transform = m
			var/matrix/m1 = C.transform
			m1.Scale(2,2)
			C.pixel_x = 32*(user.x - target.x)*0.5
			C.pixel_y = 32*(user.y - target.y)*0.5
			animate(C,transform=m1,time=8)
			H.remove_stamina(60)
			if (ishuman(user))
				var/mob/living/carbon/human/U = user
				U.remove_stamina(20)

			return 1
	return 0

/obj/item/swords/attack(mob/target, mob/user, def_zone, is_special = 0)
	if(!ishuman(target)) //only humans can currently be dismembered
		return ..()
	if (target.nodamage)
		return ..()
	if (target.spellshield)
		return ..()
	var/zoney = user.zone_sel.selecting
	var/mob/living/carbon/human/H = target
	if (handle_parry(H, user))
		return
	if (is_special)
		return ..()
	switch(zoney)
		if("head")
			if(!H.limbs.r_arm && !H.limbs.l_arm && !H.limbs.l_leg && !H.limbs.r_leg) //Does the target not have all of their limbs?
				H.organHolder.drop_and_throw_organ("head", dist = 5, speed = 1, showtext = 1) //sever_limb doesn't apply to heads :(
			return ..()
		if("chest")
			if (prob(delimb_prob))
				src.SeverButtStuff(H, user)
			return ..()
		if("r_arm")
			if (prob(delimb_prob))
				H.sever_limb(zoney)
			return ..()
		if("l_arm")
			if (prob(delimb_prob))
				H.sever_limb(zoney)
			return ..()
		if("r_leg")
			if (prob(delimb_prob))
				H.sever_limb(zoney)
			return ..()
		if("l_leg")
			if (prob(delimb_prob))
				H.sever_limb(zoney)
			return ..()
	..()

/obj/item/swords/suicide(var/mob/living/carbon/human/user as mob) //you stab out a random organ
	if (!istype(user) || !user.organHolder || !src.user_can_suicide(user))
		return 0
	else
		var/organtokill = pick("liver", "spleen", "heart", "appendix", "stomach", "intestines")
		user.visible_message("<span class='alert'><b>[user] stabs the [src] into their own chest, ripping out their [organtokill]! [pick("Oh the humanity", "What a bold display", "That's not safe at all")]!</b></span>")
		user.organHolder.drop_and_throw_organ(organtokill, dist = 5, speed = 1, showtext = 1)
		playsound(src.loc, 'sound/impact_sounds/Blade_Small_Bloody.ogg', 50, 1)
		user.TakeDamage("chest", 100, 0)
		SPAWN(10 SECONDS)
		if (user)
			user.suiciding = 0
		return 1

/// Checks if the target is facing in some way away from the user. Or they're lying down
/obj/item/swords/proc/SeverButtStuff(var/mob/living/carbon/human/target, var/mob/user)
	if(ismob(target) && (BOUNDS_DIST(target, user) == 0) && (target.dir == user.dir || target.lying))
		if(target.organHolder?.tail)
			target.organHolder.drop_and_throw_organ("tail", dist = 5, speed = 1, showtext = 1)
		else if(target.organHolder?.butt)
			target.organHolder.drop_and_throw_organ("butt", dist = 5, speed = 1, showtext = 1)

//PS the description can be shortened if you find it annoying and you are a jerk.
/obj/item/swords/katana
	name = "katana"
	desc = "That's it. I'm sick of all this 'Masterwork Cyalume Saber' bullshit that's going on in the SS13 system right now. Katanas deserve much better than that. Much, much better than that. I should know what I'm talking about. I myself commissioned a genuine katana in Space Japan for 2,400,000 Nuyen (that's about 20,000 credits) and have been practicing with it for almost 2 years now. I can even cut slabs of solid mauxite with my katana. Space Japanese smiths spend light-years working on a single katana and fold it up to a million times to produce the finest blades known to space mankind. Katanas are thrice as sharp as Syndicate sabers and thrice as hard for that matter too. Anything a c-saber can cut through, a katana can cut through better. I'm pretty sure a katana could easily bisect a drunk captain wearing full captain's armor with a simple tap. Ever wonder why the Syndicate never bothered conquering Space Japan? That's right, they were too scared to fight the disciplined Space Samurai and their space katanas of destruction. Even in World War 72, Nanotrasen soldiers targeted the men with the katanas first because their killing power was feared and respected."
	icon_state = "katana"
	force = 15 //Was at 5, but that felt far too weak. C-swords are at 60 in comparison. 15 is still quite a bit of damage, but just not insta-crit levels.
	mats = list("MET-3"=20, "FAB-1"=5)
	contraband = 7 //Fun fact: sheathing your katana makes you 100% less likely to be tazed by beepsky, probably


	// pickup_sfx = 'sound/items/blade_pull.ogg'
	var/obj/itemspecialeffect/katana_dash/start/start
	var/obj/itemspecialeffect/katana_dash/mid/mid1
	var/obj/itemspecialeffect/katana_dash/mid/mid2
	var/obj/itemspecialeffect/katana_dash/end/end
	delimb_prob = 100

	crafted
		name = "handcrafted katana"
		delimb_prob = 2

		force = 12
		contraband = 5

	New()
		..()
		start = new/obj/itemspecialeffect/katana_dash/start(src)
		mid1 = new/obj/itemspecialeffect/katana_dash/mid(src)
		mid2 = new/obj/itemspecialeffect/katana_dash/mid(src)
		end = new/obj/itemspecialeffect/katana_dash/end(src)
		src.setItemSpecial(/datum/item_special/katana_dash)
		BLOCK_SETUP(BLOCK_SWORD)

/obj/item/swords/katana/suicide(var/mob/user as mob)
	user.visible_message("<span class='alert'><b>[user] thrusts [src] through their stomach!</b></span>")
	var/say = pick("Kono shi wa watashinokazoku ni meiyo o ataeru","Haji no mae no shi", "Watashi wa kyo nagura reta.", "Teki ga katta", "Shinjiketo ga modotte kuru")
	user.say(say)
	blood_slash(user, 25)
	user.TakeDamage("chest", 150, 0)
	SPAWN(10 SECONDS)
		if (user)
			user.suiciding = 0
	return 1

/obj/item/swords/katana/self_destructing // for the dojo ronin to wield
	force = 30

	dropped(mob/user)
		..()
		if (isturf(src.loc))
			qdel(src)

/obj/item/swords/katana/reverse
	icon_state = "katana_reverse"
	name = "reverse blade katana"
	desc = "A sword whose blade is on the wrong side. Crafted by a master who grew to hate the death his weapons caused; which was weird since Oppenheimer has him beat by several orders of magnitude. Considered worthless by many, only a true virtuoso can unleash it's potential."
	hit_type = DAMAGE_BLUNT
	force = 18
	throw_range = 6
	contraband = 5 //Fun fact: sheathing your katana makes you 100% less likely to be tazed by beepsky, probably

	New()
		..()
		src.setItemSpecial(/datum/item_special/katana_dash/reverse)

/obj/item/swords/captain
	icon_state = "cap_sword"
	name = "Commander's Sabre"
	desc = ""
	mats = list("MET-2"=15)
	force = 16 //not awful but not amazing
	contraband = 4
	tooltip_flags = REBUILD_USER

	get_desc(var/dist, var/mob/user)
		if (user.mind && user.mind.assigned_role == "Captain")
			. = "An ornate and finely crafted blade commissioned from Iron Belle Bladeworks. Designed only for the most competent and highly respected of NT's chain of command. Like you!"
		else
			. = "Looks like some sort of historical recreation sword. The pommel is stamped with the name Iron Belle Bladeworks."

	New()
		..()
		src.setItemSpecial(/datum/item_special/rangestab) //more of a stab than a swing cuz its a sword you stab with

	blue
		icon_state = "blue_cap_sword"

	red
		icon_state = "red_cap_sword"

/obj/item/swords/nukeop
	icon_state = "syndie_sword"
	name = "Syndicate Commander's Sabre"
	desc = "A sharp sabre for the most trusted and competent syndicate operatives. Commissioned from Iron Belle Bladeworks."
	force = 20
	delimb_prob = 20
	contraband = 4

	New()
		..()
		src.setItemSpecial(/datum/item_special/rangestab)

/obj/item/swords/nukeop/suicide(var/mob/living/carbon/human/user as mob)
	if (!istype(user) || !user.organHolder || !src.user_can_suicide(user))
		return 0
	else
		user.visible_message("<span class='alert'><b>[user] cuts their own head clean off with the [src]! [pick("Holy shit", "Golly", "Wowie", "That's dedication", "What the heck")]!</b></span>")
		user.organHolder.drop_and_throw_organ("head", dist = 5, speed = 1, showtext = 1)
		playsound(src.loc, 'sound/impact_sounds/Flesh_Break_2.ogg', 50, 1)

/obj/item/swords/pirate
	icon_state = "pirate_sword"
	name = "Pirate's Sabre"
	desc = "A sharp sabre for the most feared of all space pirates. Commissioned from Iron Belle Bladeworks."
	force = 20
	delimb_prob = 10
	contraband = 4

	New()
		..()
		src.setItemSpecial(/datum/item_special/rangestab)

/obj/item/swords_sheaths //blegh, keeping naming consistent
	name = "youshouldntseemieum sheath"
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	wear_layer = MOB_SHEATH_LAYER
	uses_multiple_icon_states = 1
	hit_type = DAMAGE_BLUNT
	force = 5 // can do a little more damage, as a treat
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY | ONBELT
	var/obj/item/swords/sword_inside = 1
	var/sheathed_state = "katana_sheathed"
	var/sheath_state = "katana_sheath"
	var/ih_sheathed_state = "sheathedhand"
	var/ih_sheath_state = "sheathhand"
	var/sword_path = /obj/item/swords
	is_syndicate = TRUE

	New()
		..()
		var/obj/item/swords/K = new sword_path()
		sword_inside = K
		K.set_loc(src)
		BLOCK_SETUP(BLOCK_ROD)

	attack_hand(mob/living/carbon/human/user)
		if(src.sword_inside && (user.r_hand == src || user.l_hand == src || user.belt == src))
			draw_sword(user)
		else
			return ..()

	attack_self(mob/living/carbon/human/user as mob)
		if(user.r_hand == src || user.l_hand == src)
			draw_sword(user)
		else
			return ..()

	attackby(obj/item/W, mob/user)
		if (!istype(W, sword_path))
			boutput(user, "<span class='alert'>The [W] can't fit into [src].</span>")
			return
		if (istype(W, /obj/item/swords) && !src.sword_inside && !W.cant_drop == 1)
			icon_state = sheathed_state
			item_state = ih_sheathed_state
			user.u_equip(W)
			W.set_loc(src)
			user.update_clothing()
			src.sword_inside = W //katana SHOULD be in the sheath now.
			boutput(user, "<span class='notice'>You sheathe [W] in [src].</span>")
			playsound(user, 'sound/effects/sword_sheath.ogg', 50, 0, 0)
		else
			..()
			if(W.cant_drop == 1)
				boutput(user, "<span class='notice'>You can't sheathe the [W] while its attached to your arm.</span>")


/obj/item/swords_sheaths/proc/draw_sword(mob/living/carbon/human/user)
	if(src.sword_inside) //Checks if a sword is inside
		if (!user.r_hand || !user.l_hand)
			sword_inside.clean_forensic()
			boutput(user, "You draw [sword_inside] from your sheath.")
			playsound(user, pick('sound/effects/sword_unsheath1.ogg','sound/effects/sword_unsheath2.ogg'), 50, 0, 0)
			icon_state = sheath_state
			item_state = ih_sheath_state
			user.put_in_hand_or_drop(sword_inside)
			sword_inside = null //No more sword inside.
			user.update_clothing()
		else
			boutput(user, "You don't have a free hand to draw with!")

/obj/item/swords_sheaths/katana
	name = "katana sheath"
	desc = "It can clean a bloodied katana, and also allows for easier storage of a katana"
	icon_state = "katana_sheathed"
	item_state = "sheathedhand"
	sword_inside = 1
	sheathed_state = "katana_sheathed"
	sheath_state = "katana_sheath"

	ih_sheathed_state = "sheathedhand"
	ih_sheath_state = "sheathhand"
	sword_path = /obj/item/swords/katana

/obj/item/swords_sheaths/katana/reverse
	name = "reverse-blade katana sheath"
	desc = "It can clean a bloodied katana, and also allows for easier storage of a katana"
	icon_state = "sheath_reverse1"
	item_state = "sheath_reverse1"

	sheathed_state = "sheath_reverse1"
	sheath_state = "sheath_reverse0"
	ih_sheathed_state = "sheath_reverse1"
	ih_sheath_state = "sheath_reverse0"
	sword_path = /obj/item/swords/katana/reverse

/obj/item/swords_sheaths/captain
	name = "Commander's Scabbard"
	desc = null
	icon_state = "cap_sword_scabbard"
	item_state = "scabbard-cap1"

	sheathed_state = "cap_sword_scabbard"
	sheath_state = "cap_scabbard"
	ih_sheathed_state = "scabbard-cap1"
	ih_sheath_state = "scabbard-cap0"
	sword_path = /obj/item/swords/captain
	tooltip_flags = REBUILD_USER

	get_desc(var/dist, var/mob/user)
		if (user.mind && user.mind.assigned_role == "Captain")
			. = "A stylish container for your sabre. Made from the finest metals NT can afford, or so you've heard. The scabbard bears the insignia 'I.B.B'."
		else
			. = "A goofy container for a sword. What kind of nerd uses these nowadays? Sheesh!"

	blue //for NTSO medal reward
		icon_state = "blue_cap_sword_scabbard"
		item_state = "blue_scabbard-cap1"

		sheathed_state = "blue_cap_sword_scabbard"
		sheath_state = "blue_cap_scabbard"
		ih_sheathed_state = "blue_scabbard-cap1"
		ih_sheath_state = "blue_scabbard-cap0"
		sword_path = /obj/item/swords/captain/blue

	red //for brown pants medal reward
		icon_state = "red_cap_sword_scabbard"
		item_state = "red_scabbard-cap1"

		sheathed_state = "red_cap_sword_scabbard"
		sheath_state = "red_cap_scabbard"
		ih_sheathed_state = "red_scabbard-cap1"
		ih_sheath_state = "red_scabbard-cap0"
		sword_path = /obj/item/swords/captain/red

/obj/item/swords_sheaths/nukeop
	name = "Syndicate Commander's Scabbard"
	desc = "A nifty container for an evil sword. Given to the most trusted syndicate operatives. The scabbard bears the insignia 'I.B.B'."
	icon_state = "syndie_sword_scabbard"
	item_state = "scabbard-syndie1"

	sheathed_state = "syndie_sword_scabbard"
	sheath_state = "syndie_scabbard"
	ih_sheathed_state = "scabbard-syndie1"
	ih_sheath_state = "scabbard-syndie0"
	sword_path = /obj/item/swords/nukeop

/obj/item/swords_sheaths/pirate
	name = "Pirate's Scabbard"
	desc = "A nifty container for a ruthless sword. Given to the most feared space pirates, or stolen from the previous most feared space pirate. The scabbard bears the insignia 'I.B.B'."
	icon_state = "pirate_sword_scabbard"
	item_state = "scabbard-pirate1"

	sheathed_state = "pirate_sword_scabbard"
	sheath_state = "pirate_scabbard"
	ih_sheathed_state = "scabbard-pirate1"
	ih_sheath_state = "scabbard-pirate0"
	sword_path = /obj/item/swords/pirate


/*
 *							--- Non-electronic Swords ---
 * Below are two swords, the first grows stronger the more you use it, but resets when dropped.
 * The other grows weaker the more you use it, but can be restored with a whetstone.
 * Kinda just proof-of-concepts + me learning about numbers. ~ Gannets
*/

/obj/item/swords/bloodthirsty_blade
	name = "Bloodthirsty Blade"
	desc = "A mysterious blade that hungers for blood & revels in strife. Grows stronger when used for malicious means."
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi' //todo back sprites
	icon_state = "claymore"
	item_state = "longsword"
	flags = ONBACK
	hit_type = DAMAGE_CUT
	tool_flags = TOOL_CUTTING | TOOL_CHOPPING
	contraband = 5
	w_class = W_CLASS_BULKY
	force = 0
	throwforce = 5
	stamina_damage = 25
	stamina_cost = 25
	stamina_crit_chance = 15
	two_handed = 1
	pickup_sfx = 'sound/items/blade_pull.ogg'
	delimb_prob = 10

	New()
		..()
		name = "[pick("Mysterious","Foreboding","Menacing","Terrifying","Malevolent","Ghastly","Bloodthirsty","Vengeful","Loathsome")] [pick("Sword","Blade","Slicer","Knife","Dagger","Cutlass","Gladius","Cleaver","Chopper","Claymore","Zeitgeist")] of [pick("T'pire Weir Isles","Ballingry","Mossmorran","Auchtertool","Kirkcaldy","Auchmuirbridge","Methil","Muiredge","Swords")]"
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_SWORD)


/obj/item/swords/bloodthirsty_blade/attack(target, mob/user)
	playsound(target, 'sound/impact_sounds/Blade_Small_Bloody.ogg', 60, 1)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(!isdead(C))
			force += 5
			boutput(user, "<span class='alert'>The [src] delights in the bloodshed, you can feel it grow stronger!</span>")
			take_bleeding_damage(C, user, 5, DAMAGE_STAB)
	..()

/obj/item/swords/bloodthirsty_blade/dropped(mob/user)
	..()
	if (isturf(src.loc))
		user.visible_message("<span class='alert'>As the [src] falls from [user]'s hands, it seems to become duller!</span>")
		force = 5
		return

obj/item/swords/fragile_sword
	name = "fragile sword"
	desc = "This great blade has seen many battles, as such it dulls quickly when used."
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "fragile_sword"
	item_state = "fragile_sword"
	hit_type = DAMAGE_CUT
	contraband = 5
	w_class = W_CLASS_BULKY
	force = 60
	throwforce = 60
	stamina_damage = 25
	stamina_cost = 25
	stamina_crit_chance = 15
	pickup_sfx = 'sound/items/blade_pull.ogg'
	delimb_prob = 5

	var/minimum_force = 5
	var/maximum_force = 70

	New()
		..()
		BLOCK_SETUP(BLOCK_SWORD)

	attack(target, mob/user)
		playsound(target, 'sound/impact_sounds/Blade_Small_Bloody.ogg', 60, 1)
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			if(!isdead(C))
				if(force >= minimum_force)
					force -= 5
					throwforce = force
					boutput(user, "<span class='alert'>The [src]'s edge dulls slightly on impact!</span>")
					take_bleeding_damage(C, user, 5, DAMAGE_STAB)
		..()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/whetstone))
			if(force <= maximum_force)
				force += 5
				throwforce = force
				boutput(user, "<span class='notice'>You sharpen the blade of the [src] with the whetstone.</span>")
				playsound(loc, 'sound/items/blade_pull.ogg', 60, 1)
		..()

obj/item/whetstone
	name = "whetstone"
	desc = "A stone that can sharpen a blade and restore it to it's former glory."
	icon = 'icons/obj/dojo.dmi'
	icon_state = "whetstone"

/*
	Nuclear Operative Specialist Melee Weapon
	- A sword that builds force when attacking living humans
	- Caps at 100 force
	- Resets force when dropped
	- Use in-hand to switch special attacks
	- Knocks back on-hit
*/

#define SWIPE_MODE 1
#define STAB_MODE 2

/obj/item/heavy_power_sword
	name = "Hadar heavy power-sword"
	desc = "A heavy cyalume saber variant, builds generator charge when used in combat & supports multiple attack types."
	icon = 'icons/obj/large/64x32.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_cswords.dmi'
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	icon_state = "hadar_sword2"
	item_state = "hadar_sword2"
	flags = ONBACK | FPRINT | TABLEPASS
	hit_type = DAMAGE_CUT
	tool_flags = TOOL_CUTTING | TOOL_CHOPPING
	contraband = 5
	w_class = W_CLASS_BULKY
	force = 25
	throwforce = 25
	stamina_damage = 25
	stamina_cost = 20
	stamina_crit_chance = 15
	pickup_sfx = 'sound/weapons/hadar_pickup.ogg'
	hitsound = 'sound/weapons/hadar_impact.ogg'
	two_handed = 1
	uses_multiple_icon_states = 1

	var/mode = SWIPE_MODE
	var/maximum_force = 100
	var/swipe_color = "#0081DF"
	var/stab_color = "#FF0000"

	New()
		..()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		src.setItemSpecial(/datum/item_special/swipe)
		src.update_special_color()
		AddComponent(/datum/component/itemblock/saberblock, null, .proc/get_reflect_color)
		BLOCK_SETUP(BLOCK_SWORD)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

/obj/item/heavy_power_sword/proc/get_reflect_color()
	if (src.mode == SWIPE_MODE)
		return src.swipe_color
	if (src.mode == STAB_MODE)
		return src.stab_color
	return "#FFFFFF"

/obj/item/heavy_power_sword/proc/update_special_color()
	var/datum/item_special/swipe/swipe = src.special
	var/datum/item_special/rangestab/stab = src.special
	if (istype(swipe))
		swipe.swipe_color = src.swipe_color
	else if (istype(stab))
		stab.stab_color = src.stab_color

/obj/item/heavy_power_sword/attack(mob/M, mob/user, def_zone)

	var/turf/t = get_turf(user) // no farming in the safety of the Cairngorm
	if (t.loc:sanctuary)
		return

	if(src.mode == 1) // only knock back on the sweep attack
		var/turf/throw_target = get_edge_target_turf(M, get_dir(user,M))
		M.throw_at(throw_target, 2, 2)
	..()
	if(ishuman(M) && isalive(M) && src.force <= src.maximum_force) //build charge on living humans only, up to the cap
		src.force += 5
		boutput(user, "<span class='alert'>[src]'s generator builds charge!</span>")
		src.tooltip_rebuild = TRUE

/obj/item/heavy_power_sword/dropped(mob/user)
	..()
	if (isturf(src.loc))
		user.visible_message("<span class='alert'>[src] drops from [user]'s hands and powers down!</span>")
		force = initial(src.force)
		src.tooltip_rebuild = TRUE
		return

/obj/item/heavy_power_sword/attack_self(mob/user as mob)
	switch(src.mode) // switch in-case i want to add more modes later
		if(1)
			boutput(user, "<span class='alert'>[src] transforms enabling a ranged stab!</span>")
			icon_state = "hadar_sword1"
			item_state = "hadar_sword1"
			src.mode = STAB_MODE
			hit_type = DAMAGE_STAB
			src.setItemSpecial(/datum/item_special/rangestab)
		if(2)
			boutput(user, "<span class='alert'>[src] transforms in order to swing wide!</span>")
			icon_state = "hadar_sword2"
			item_state = "hadar_sword2"
			src.mode = SWIPE_MODE
			hit_type = DAMAGE_CUT
			src.setItemSpecial(/datum/item_special/swipe)
	user.update_inhands()
	tooltip_rebuild = TRUE
	src.update_special_color()
	..()

#undef SWIPE_MODE
#undef STAB_MODE

// Battering ram - a door breeching melee tool for the armory

/obj/item/breaching_hammer
	name = "airlock breaching sledgehammer"
	desc = "A heavy metal hammer designed to crumple space station airlocks."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "breaching_sledgehammer"
	item_state = "breaching_sledgehammer"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'

	tool_flags = TOOL_CHOPPING //to chop through doors
	hit_type = DAMAGE_BLUNT
	health = 10
	w_class = W_CLASS_NORMAL
	two_handed = 1
	click_delay = 30

	force = 30 //this number is multiplied by 4 when attacking doors.
	stamina_damage = 60
	stamina_cost = 30

	New()
		..()
		BLOCK_SETUP(BLOCK_ROD)

//Machete for The Slasher
/obj/item/slasher_machete
	name = "slasher's machete"
	desc = "An old machete, clearly showing signs of wear and tear due to its age."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "welder_machete"
	item_state = "welder_machete"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
	force = 15.0 //damage increases by 2.5 for every soul they take
	throwforce = 15 //damage goes up by 2.5 for every soul they take
	flags = FPRINT | CONDUCT | TABLEPASS | ONBELT
	item_function_flags = IMMUNE_TO_ACID
	hit_type = DAMAGE_CUT
	tool_flags = TOOL_CUTTING
	w_class = W_CLASS_NORMAL
	var/slasher_key = ""

	New()
		. = ..()
		START_TRACKING
		src.setItemSpecial(/datum/item_special/swipe)

	disposing()
		. = ..()
		STOP_TRACKING

	attack_hand(var/mob/user)
		if (user.mind)
			if (isslasher(user) || check_target_immunity(user))
				if (user.mind.key != src.slasher_key && !check_target_immunity(user))
					boutput(user, "<span class='alert'>The [src.name] is attuned to another Slasher! You may use it, but it may get recalled at any time!</span>")
				..()
				return
			else
				random_brute_damage(user, 2*src.force)
				boutput(user,"<span style=\"color:red\">You feel immense pain!</span>")
				user.changeStatus("weakened", 80)
				return
		else ..()

	pull(mob/user)
		if(check_target_immunity(user))
			return ..()

		if (!istype(user))
			return

		if (isslasher(user))
			return ..()
		else
			random_brute_damage(user, 2*src.force)
			boutput(user,"<span style=\"color:red\">You feel immense pain!</span>")
			user.changeStatus("weakened", 80)
			return

	throw_impact(atom/A, datum/thrown_thing/thr)
		if(iscarbon(A))
			var/mob/living/carbon/C = A
			if (ismob(usr))
				C.lastattacker = usr
				C.lastattackertime = world.time
			C.changeStatus("weakened", 3 SECONDS)
			C.force_laydown_standup()
			take_bleeding_damage(C, null, src.force / 2	, DAMAGE_CUT)
			random_brute_damage(C, round(throwforce * 0.75),1)
			playsound(src, 'sound/impact_sounds/Flesh_Stab_3.ogg', 40, 1)

	possessed
		cant_self_remove = 1
		cant_other_remove = 1
		cant_drop = 1
		throwforce = 20 //higher base damage, lower once the slasher starts scaling up their machete
		force = 20


// Halberd- Experimental weapon by NightmareChamillian
#define HALB_HEAVY_DAMAGE 35
#define HALB_MED_DAMAGE 24
#define HALB_LIGHT_DAMAGE 15

#define HALB_HEAVY_STAMDAM 40
#define HALB_LIGHT_STAMDAM 20

#define HALB_HEAVY_STAMCOST 35
#define HALB_MED_STAMCOST 20
#define HALB_LIGHT_STAMCOST 10

/obj/item/halberd
	name = "Halberd"
	desc = "An ancient axe-like weapon capable of cleaving and piercing flesh with ease. You have no idea what this is doing outside a museum."
	icon = 'icons/obj/large/64x32.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "halberdhoriz"
	icon_state = "halberdnormal"

	w_class = W_CLASS_BULKY
	two_handed = 1
	throw_range = 10
	throwforce = 30 //yeet like spear
	stamina_crit_chance = 5

	//these combat variables change depending on intent- starts with help intent vars
	force = HALB_MED_DAMAGE
	stamina_damage = HALB_LIGHT_STAMDAM
	stamina_cost = HALB_LIGHT_STAMCOST
	var/guard = null //! used to keep track of what melee properties we're using

	hit_type = DAMAGE_CUT
	flags = FPRINT | TABLEPASS | USEDELAY | ONBACK
	c_flags = EQUIPPED_WHILE_HELD
	item_function_flags = USE_INTENT_SWITCH_TRIGGER | USE_SPECIALS_ON_ALL_INTENTS

	New()
		..()
		BLOCK_SETUP(BLOCK_SWORD)

	setupProperties()
		. = ..()
		setProperty("deflection", 60)
		setProperty("block", 40)

	intent_switch_trigger(mob/user as mob)
		if(guard != user.a_intent)
			change_guard(user,user.a_intent)

	proc/change_guard(var/mob/user,var/intent) //heavily modified kendo code
		guard = intent
		switch(guard)
			if("help") //light swing with the axe
				force = HALB_MED_DAMAGE
				stamina_damage = HALB_LIGHT_STAMDAM
				stamina_cost = HALB_LIGHT_STAMCOST
				item_state = "halberdhoriz"
				icon_state = "halberdnormal"
				hit_type = DAMAGE_CUT
				src.click_delay = COMBAT_CLICK_DELAY * 0.75
				hitsound =  'sound/impact_sounds/Blade_Small_Bloody.ogg'
				src.setItemSpecial(/datum/item_special/simple)
				boutput(user, "<span class='notice'>You will now make light swings with the axe!</span>")
			if("disarm") //thrust with the pointy end
				force = HALB_LIGHT_DAMAGE
				stamina_damage = HALB_LIGHT_STAMDAM
				stamina_cost = HALB_LIGHT_STAMCOST
				item_state = "halberdverti"
				icon_state = "halberdnormal"
				hit_type = DAMAGE_STAB
				src.click_delay = COMBAT_CLICK_DELAY * 0.60
				hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
				src.setItemSpecial(/datum/item_special/rangestab)
				boutput(user, "<span class='notice'>You will thrust with the tip!</span>")

			if("grab") //attack with the spur on the back
				force = HALB_LIGHT_DAMAGE
				stamina_damage = HALB_HEAVY_STAMDAM
				stamina_cost = HALB_MED_STAMCOST
				item_state = "halberdhoriz"
				icon_state = "halberdupsidown"
				hit_type = DAMAGE_STAB
				src.click_delay = COMBAT_CLICK_DELAY
				hitsound ='sound/impact_sounds/coconut_break.ogg' //it's a good hitsound when you ignore the name
				src.setItemSpecial(/datum/item_special/simple)
				boutput(user, "<span class='notice'>You will now make dehabilitating swings with the spur!</span>")

			if("harm") //wide, tiring swings with the axe
				force = HALB_HEAVY_DAMAGE
				stamina_damage = HALB_HEAVY_STAMDAM
				stamina_cost = HALB_HEAVY_STAMCOST
				item_state = "halberdhoriz"
				icon_state = "halberdnormal"
				hit_type = DAMAGE_CUT
				src.click_delay = COMBAT_CLICK_DELAY * 1.25
				hitsound =  'sound/impact_sounds/Blade_Small_Bloody.ogg'
				src.setItemSpecial(/datum/item_special/swipe)
				boutput(user, "<span class='notice'>You will now make heavy swings with the axe!</span>")

		user.update_inhands()
		src.tooltip_rebuild = TRUE

	attack_hand(mob/user)
		if(src.loc != user)
			change_guard(user,user.a_intent)
		..()

	dropped(mob/user as mob)
		..()
		stat_reset()

	proc/stat_reset() //sets it to normal
		src.force = HALB_MED_DAMAGE
		src.stamina_damage = HALB_LIGHT_STAMDAM
		src.stamina_cost = HALB_LIGHT_STAMCOST
		src.item_state = "halberd1"
		src.hit_type = DAMAGE_CUT
		src.click_delay = COMBAT_CLICK_DELAY * 0.75
		src.hitsound =  'sound/impact_sounds/Blade_Small_Bloody.ogg'
		src.setItemSpecial(/datum/item_special/simple)
		src.tooltip_rebuild = TRUE

#undef HALB_HEAVY_DAMAGE
#undef HALB_MED_DAMAGE
#undef HALB_LIGHT_DAMAGE
#undef HALB_HEAVY_STAMDAM
#undef HALB_LIGHT_STAMDAM
#undef HALB_HEAVY_STAMCOST
#undef HALB_MED_STAMCOST
#undef HALB_LIGHT_STAMCOST

/obj/item/swords/sord
	name = "gross sord"
	desc = "oh no"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "longsword"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	color = "#4a996c"
	hit_type = DAMAGE_CUT
	flags = FPRINT | TABLEPASS | NOSHIELD | USEDELAY
	force = 10
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	is_syndicate = TRUE
	contraband = 10 // absolutely illegal
	w_class = W_CLASS_NORMAL
	hitsound = 'sound/voice/farts/fart7.ogg'
	tool_flags = TOOL_CUTTING
	attack_verbs = "slashes"

	New()
		..()
		src.setItemSpecial(/datum/item_special/rangestab)
