// big bad file of bad things i may or may not use

//panic button
/obj/item/device/panicbutton
	name = "panic button"
	desc = "A big red button that alerts the station Security team that there's a crisis at your location. On the bottom someone has scribbled 'oh shit button', cute."
	icon_state = "panic_button"
	w_class = W_CLASS_TINY
	var/net_id = null
	var/alert_group = list(MGD_SECURITY, MGA_CRISIS)

	New()
		. = ..()
		src.net_id = generate_net_id(src)
		MAKE_SENDER_RADIO_PACKET_COMPONENT(src.net_id, "pda", FREQ_PDA)

	attack_self(mob/user)
		..()
		if(!ON_COOLDOWN(src, "panic button", 15 SECONDS))
			if(isliving(user))
				playsound(src, 'sound/items/security_alert.ogg', 30)
				usr.visible_message(SPAN_ALERT("[usr] presses the red button on [src]."),
				SPAN_NOTICE("You press the button on [src]."),
				SPAN_ALERT("You see [usr] press a button on [src]."))
				logTheThing(LOG_COMBAT, user, "triggers [src] at [log_loc(user)]")
				triggerpanicbutton()
		else
			boutput(user, SPAN_NOTICE("The [src] buzzes faintly. It must be cooling down."))

	proc/triggerpanicbutton(user)
		var/datum/signal/signal = get_free_signal()
		var/area/an_area = get_area(src)
		signal.source = src
		signal.data["command"] = "text_message"
		signal.data["sender_name"] = "PANIC-BUTTON"
		signal.data["group"] = src.alert_group
		signal.data["sender"] = "00000000"
		signal.data["address_1"] = "00000000"
		signal.data["message"] = "***CRISIS ALERT*** Location: [an_area ? an_area.name : "nowhere"]!"
		signal.data["is_alert"] = TRUE

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, null, FREQ_PDA)

/obj/item/device/panicbutton/medicalalert //really just adding this for the hop version but hey maybe medical wants to hand out medical life alert buttons for the funny
	name = "medical alert button"
	desc = "A big red button that alerts the station Medical team that there's a crisis at your location."
	alert_group = list(MGD_MEDBAY, MGA_CRISIS)

/obj/item/device/panicbutton/medicalalert/hop
	name = "life alert button"
	desc = "For when you've got a REAL BIG problem and want EVERYONE to know about it."
	alert_group = list(MGD_PARTY, MGD_MEDBAY, MGD_SECURITY, MGD_COMMAND, MGA_CRISIS) // lol. lmao, even

/obj/item/storage/box/panic_buttons
	name = "box of panic buttons"
	desc = "A box filled with panic buttons. For when you have a real big problem and need a whole lot of people to freak out about it. Note: DEFINITELY keep out of reach of the clown and/or assistants."
	spawn_contents = list(/obj/item/device/panicbutton = 7)

/obj/item/storage/box/panic_buttons/medicalalert
	name = "box of medical alert buttons"
	desc = "A box filled with medical alert buttons."
	spawn_contents = list(/obj/item/device/panicbutton/medicalalert = 7)

//dazzler. moved to own file. probably wont do anything with this
/obj/item/gun/energy/dazzler
	name = "dazzler"
	icon_state = "taser" // wtb 1 sprite
	item_state = "taser"
	force = 1
	cell_type = /obj/item/ammo/power_cell/med_power
	desc = "The Five Points Armory Dazzler Prototype, an experimental weapon that produces a cohesive electrical charge designed to disorient and slowdown a target. It can even shoot through windows!"
	muzzle_flash = "muzzle_flash_bluezap"
	uses_charge_overlay = TRUE
	charge_icon_state = "taser"

	New()
		set_current_projectile(new/datum/projectile/energy_bolt/dazzler)
		projectiles = list(current_projectile)
		..()


/datum/projectile/energy_bolt/dazzler
	name = "energy bolt"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "signifer2_brute"
	stun = 4
	cost = 20
	max_range = 12
	window_pass = 1 // maybe keep
	dissipation_rate = 0 // weak enough as is
	sname = "dazzle"
	shot_sound = 'sound/weapons/Taser.ogg'
	shot_sound_extrarange = 5
	shot_number = 1
	damage_type = D_ENERGY
	color_red = 0
	color_green = 0
	color_blue = 1
	disruption = 8

/obj/item/gun/energy/stasis
	name = "stasis rifle"
	icon = 'icons/obj/items/guns/energy48x32.dmi'
	icon_state = "stasis"
	item_state = "rifle"
	charge_icon_state = "stasis"
	force = 1
	cell_type = /obj/item/ammo/power_cell/med_power
	desc = "An experimental weapon that produces a cohesive electrical charge designed to hold a target in place for a limited time."
	muzzle_flash = "muzzle_flash_bluezap"
	uses_charge_overlay = TRUE
	can_dual_wield = FALSE
	two_handed = 1
	w_class = W_CLASS_NORMAL
	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY

	New()
		set_current_projectile(new/datum/projectile/energy_bolt/stasis)
		projectiles = list(current_projectile)
		AddComponent(/datum/component/holdertargeting/windup, 3 SECONDS)
		..()

/datum/projectile/energy_bolt/stasis
	name = "stasis bolt"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "cyan_bolt"
	damage = 0
	cost = 100
	dissipation_rate = 2
	dissipation_delay = 8
	shot_sound = 'sound/weapons/laser_e.ogg'
	shot_number = 1
	damage_type = D_ENERGY
	hit_ground_chance = 0
	brightness = 0.8
	ie_type = "E"
	has_impact_particles = TRUE

	on_hit(atom/hit)
		if (isliving(hit))
			var/mob/living/L = hit
			L.changeStatus("stasis", 6 SECONDS)
		impact_image_effect(ie_type, hit)
		return

/obj/item/swords/sord
	name = "gross sord"
	desc = "oh no"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "longsword"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	color = "#4a996c"
	hit_type = DAMAGE_CUT
	flags = TABLEPASS | NOSHIELD | USEDELAY
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

//mercenary stuff lives here for now
/obj/item/clothing/under/misc/merc01
	name = "khaki shirt and gray pants"
	desc = "A slick pair of gray camouflage pattern pants and a khaki pocketed shirt."
	icon_state = "merc01"
	item_state = "merc01"

/obj/item/storage/belt/security/shoulder_holster/small
	name = "lightweight shoulder holster"
	desc = "A cheap shoulder holster without much storage space for anything else."
	slots = 3

/mob/living/carbon/human/normal/merc
	faction = list(FACTION_MERCENARY)
	New()
		..()
		src.equip_new_if_possible(/obj/item/clothing/under/misc/merc01, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/storage/belt/security/shoulder_holster/small, SLOT_BELT)
		src.equip_new_if_possible(/obj/item/clothing/shoes/detective, SLOT_SHOES)
		src.equip_new_if_possible(/obj/item/card/id, SLOT_WEAR_ID)
		src.equip_new_if_possible(/obj/item/device/radio/headset, SLOT_EARS)
		src.equip_new_if_possible(/obj/item/storage/backpack/brown, SLOT_BACK)
		src.equip_new_if_possible(/obj/item/clothing/suit/armor/vest/light, SLOT_WEAR_SUIT)

		var/obj/item/card/id/C = src.wear_id
		if(C)
			C.registered = src.real_name
			C.assignment = "Greyhold Mercenary Operative"
			C.name = "[C.registered]'s ID Card ([C.assignment])"

		update_clothing()

/obj/mapping_helper/mob_spawn/corpse/human/merc
	spawn_type = /mob/living/carbon/human/normal/merc

ABSTRACT_TYPE(/mob/living/critter/human/mercenary)
/mob/living/critter/human/mercenary
	name = "\improper Mercenary"
	real_name = "\improper Mercenary"
	desc = "A very angry merc."
	health_brute = 25
	health_burn = 25
	corpse_spawner = /obj/mapping_helper/mob_spawn/corpse/human/merc
	human_to_copy = /mob/living/carbon/human/normal/merc

	faction = list(FACTION_MERCENARY)

/mob/living/critter/human/mercenary/knife
	ai_type = /datum/aiHolder/aggressive
	hand_count = 2

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb/sword
		HH.name = "left hand"
		HH.suffix = "-L"
		HH.icon_state = "blade"
		HH.limb_name = "combat knife"
		HH.can_hold_items = FALSE
		HH.object_for_inhand = /obj/item/dagger

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "right arm"

/mob/living/critter/human/mercenary/rifle
	ai_type = /datum/aiHolder/ranged
	hand_count = 1

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.limb = new /datum/limb/gun/kinetic/draco
		HH.name = "rifle"
		HH.suffix = "-LR"
		HH.icon_state = "handrifle"
		HH.limb_name = "\improper Draco Pistol"
		HH.can_hold_items = FALSE
		HH.can_attack = TRUE
		HH.can_range_attack = TRUE
		HH.object_for_inhand = /obj/item/gun/kinetic/draco

/obj/item/paper/mercmanifest1
	name = "Shipping Manifest"
	info = {"<center><b>Manifest</b><br>
	Target Destination: Frontier, local distrubution<br><br>
	<li>Standard Uniform</li> - 5x<br><br>
	Approved for processing.<br>
	Shipping to Frontier Outpost 8.<br>
	Received at Frontier Outpost 8.<br>
	Awaiting local transportation.</center>"}


/obj/item/paper/mercmanifest2
	name = "Shipping Manifest"
	info = {"<center><b>Manifest</b><br>
	Target Destination: Frontier Outpost 8<br><br>
	<li>Rations</li> - Burrito 5x<br>
	<li>Rations</li> - TV Dinner 5x<br><br>
	Approved for processing.<br>
	Shipping to Frontier Outpost 8.<br>
	Received at Frontier Outpost 8. </center>"}

/obj/item/paper/mercmanifest3
	name = "Shipping Manifest"
	info = {"<center><b>Manifest</b><br>
	Target Destination: Frontier, local distrubution<br><br>
	<li>Medical Kit</li> - Standard 1x<br>
	<li>Medical Kit</li> - Oxygen 1x<br><br>
	Approved for processing.<br>
	Shipping to Frontier Outpost 8.<br>
	Received at Frontier Outpost 8.<br>
	Awaiting local transportation.</center>"}

// Spiderweb shit and abilities. woe, anyone foolish enough to gaze upon this code
/obj/spiderweb
	name = "spider web"
	desc = "Not your average cobweb, it looks much thicker."
	icon = 'icons/obj/decals/cleanables.dmi'
	icon_state = "cobweb_small"
	anchored = ANCHORED_ALWAYS
	var/weblevel = 1
	density = 0

	New()
		..()
		src.update_self()

	Cross(atom/A)
		switch(weblevel)
			if(1 to 2)
				if(isliving(A) && !A.hasStatus("webwalk"))
					A.changeStatus("slowed", 1 SECONDS)
					if(!ON_COOLDOWN(A, "webrustle", 1 SECOND))
						playsound(A.loc, 'sound/impact_sounds/Bush_Hit.ogg', 45, 1)
					return 1
				else
					return 1
			if(3)
				if(isliving(A) && !A.hasStatus("webwalk"))
					return 0
				else
					return 1

	attackby(obj/item/W, mob/user)
		if (!W) return
		if (!user) return
		var/dmg = FALSE
		if (W.hit_type == DAMAGE_CUT || W.hit_type == DAMAGE_BURN || W.hit_type == DAMAGE_STAB)
			playsound(src.loc, 'sound/impact_sounds/burn_sizzle.ogg', 45, 1)
			dmg = TRUE
		else if (W.hit_type == DAMAGE_BLUNT)
			playsound(src.loc, 'sound/impact_sounds/Bush_Hit.ogg', 45, 1)
			boutput(user, SPAN_NOTICE("Your [W.name] isn't effective against the [src]!"))
			return

		if(dmg == TRUE)
			src.take_damage(1, "brute", user)

		user.lastattacked  = src
		..()

/obj/spiderweb/proc/update_self()
	playsound(src, 'sound/misc/splash_1.ogg', 45, 1)
	switch(src.weblevel)
		if (-INFINITY to 1)
			src.name = initial(src.name)
			src.set_opacity(0)
			src.set_density(0)
			src.icon_state = "cobweb_small"
		if (2)
			src.name = "thick [initial(src.name)]"
			src.set_opacity(1)
			src.set_density(0)
			src.icon_state = "cobweb_floor-c"
		if (3 to INFINITY)
			src.name = "dense [initial(src.name)]"
			src.set_opacity(1)
			src.set_density(1)
			src.icon_state = "cobweb_floor"

/obj/spiderweb/proc/take_damage(var/amount, var/damtype = "brute",var/mob/user)
	if (!isnum(amount) || amount <= 0)
		return

	src.weblevel -= 1
	if (src.weblevel < 1)
		qdel (src)
	else
		src.update_self()


/datum/statusEffect/webwalk
	id = "webwalk"
	name = "Web Walking"
	desc = "You can walk through spider webs without any adverse effects."
	icon_state = "foot"
	effect_quality = STATUS_QUALITY_POSITIVE
	duration = INFINITE_STATUS
	maxDuration = null
	unique = TRUE

/datum/targetable/lay_spider_web
	name = "Lay a Web"
	desc = "Lay a spider web on the ground. If there is already a web there, upgrade it to the next level."
	icon = 'icons/misc/abilities.dmi'
	icon_state = "poo"
	targeted = 1
	target_anything = 1
	cooldown = 3 SECONDS
	max_range = 1

	cast(atom/target)
		. = ..()
		var/turf/T = get_turf(target)
		if (isturf(T))
			if (T.density)
				boutput(holder.owner, SPAN_ALERT("You can't lay a web there!"))
				return 1

			for (var/obj/O in T.contents)
				if (istype(O, /obj/window) || istype(O, /obj/forcefield) || istype(O, /obj/blob))
					boutput(holder.owner, SPAN_ALERT("You can't lay a web there!"))
					return 1


			var/obj/spiderweb/web_tile = locate(/obj/spiderweb) in T.contents

			if (istype(web_tile))
				if(web_tile.weblevel < 3)
					web_tile.weblevel += 1
					web_tile.update_self()
					boutput(holder.owner, SPAN_NOTICE("You reinforce the web on [T]."))
				else
					boutput(holder.owner, SPAN_NOTICE("You can't reinforce this web any more."))
					return
			else
				new/obj/spiderweb(T)
				boutput(holder.owner, SPAN_NOTICE("You lay a web on [T]."))

/mob/living/critter/spider/baby/weblaying
	adultpath = /mob/living/critter/spider/med/weblaying
	add_abilities = list(/datum/targetable/lay_spider_web,
						/datum/targetable/critter/spider_bite,
						/datum/targetable/critter/spider_flail,
						/datum/targetable/critter/spider_drain)
	New()
		..()
		src.changeStatus("webwalk", INFINITE_STATUS)

/mob/living/critter/spider/med/weblaying
	adultpath = /mob/living/critter/spider/weblaying
	add_abilities = list(/datum/targetable/lay_spider_web,
						/datum/targetable/critter/spider_bite,
						/datum/targetable/critter/spider_flail,
						/datum/targetable/critter/spider_drain)
	New()
		..()
		src.changeStatus("webwalk", INFINITE_STATUS)

/mob/living/critter/spider/weblaying
	add_abilities = list(/datum/targetable/lay_spider_web,
						/datum/targetable/critter/spider_bite,
						/datum/targetable/critter/spider_flail,
						/datum/targetable/critter/spider_drain)
	New()
		..()
		src.changeStatus("webwalk", INFINITE_STATUS)
