// Contains:
//
// - Chainsaw
// - Plant analyzer
// - Portable seed fabricator
// - Watering can
// - Compost bag
// - Plant formulas
// - Garden Trowel

//////////////////////////////////////////////// Chainsaw ////////////////////////////////////

TYPEINFO(/obj/item/saw)
	mats = 12

/obj/item/saw
	name = "chainsaw"
	desc = "An electric chainsaw used to chop up harmful plants."
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "c_saw_off"
	item_state = "c_saw"
	var/base_state = "c_saw"
	var/active = 0
	hit_type = DAMAGE_CUT
	force = 3
	var/active_force = 12
	var/off_force = 3
	health = 10
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_BULKY
	flags = FPRINT | TABLEPASS | CONDUCT
	tool_flags = TOOL_SAWING
	var/sawnoise = 'sound/machines/chainsaw_green.ogg'
	arm_icon = "chainsaw-D"
	var/base_arm = "chainsaw"
	over_clothes = 1
	override_attack_hand = 1
	can_hold_items = 0
	stamina_damage = 30
	stamina_cost = 15
	stamina_crit_chance = 35

	cyborg

	active
		active = 1
		force = 12
		arm_icon = "chainsaw-A"

		New()
			..()
			hitsound = 'sound/machines/chainsaw_green.ogg'

	New()
		..()
		SPAWN(0.5 SECONDS)
			if (src)
				src.UpdateIcon()
		BLOCK_SETUP(BLOCK_ROD)
		return


	update_icon()
		set_icon_state("[src.base_state][src.active ? null : "_off"]")
		src.item_state = "[src.base_state][src.active ? "-A" : "-D"]"
		src.arm_icon = "[src.base_arm][src.active ? "-A" : "-D"]"
		if (src.temp_flags & IS_LIMB_ITEM)
			if (istype(src.loc,/obj/item/parts/human_parts/arm/left/item))
				var/obj/item/parts/human_parts/arm/left/item/I = src.loc
				I.handlistPart = "l_arm_[src.arm_icon]"
			else
				var/obj/item/parts/human_parts/arm/right/item/I = src.loc
				I.handlistPart = "r_arm_[src.arm_icon]"
		return

	// Fixed a couple of bugs and cleaned code up a little bit (Convair880).
	attack(mob/target, mob/user)
		if (!istype(target))
			return

		if (src.active)

			user.lastattacked = target
			target.lastattacker = user
			target.lastattackertime = world.time

			if (ishuman(target))
				if (ishuman(user) && saw_surgery(target,user))
					take_bleeding_damage(target, user, 2, DAMAGE_CUT)
					return
				else if (!isdead(target))
					take_bleeding_damage(target, user, 5, DAMAGE_CUT)
					if (prob(80))
						target.emote("scream")
		..()
		return

	attack_self(mob/user as mob)
		if (user.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span class='alert'><b>[user]</b> accidentally grabs the blade of [src].</span>")
			user.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 5, 5)
			JOB_XP(user, "Clown", 1)
		src.active = !( src.active )
		if (src.active)
			boutput(user, "<span class='notice'>[src] is now active.</span>")
			src.force = active_force
			src.hitsound = sawnoise
		else
			boutput(user, "<span class='notice'>[src] is now off.</span>")
			src.force = off_force
			src.hitsound = initial(src.hitsound)
		tooltip_rebuild = 1
		user.set_body_icon_dirty()
		src.UpdateIcon()
		user.update_inhands()
		src.add_fingerprint(user)
		return

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] shoves the chainsaw into [his_or_her(user)] chest!</b></span>")
		blood_slash(user, 25)
		playsound(user.loc, 'sound/machines/chainsaw_red.ogg', 50, 1)
		playsound(user.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
		user.u_equip(src)
		src.set_loc(user.loc)
		user.gib()
		return 1

/obj/item/saw/abilities = list(/obj/ability_button/saw_toggle)

TYPEINFO(/obj/item/saw/syndie)
	mats = list("MET-2"=25, "CON-1"=5, "POW-2"=5)

/obj/item/saw/syndie
	name = "red chainsaw"
	icon_state = "c_saw_s_off"
	item_state = "c_saw_s"
	base_state = "c_saw_s"
	tool_flags = TOOL_SAWING | TOOL_CHOPPING //fucks up doors. fuck doors
	active = 0
	force = 6
	active_force = 20
	off_force = 6
	health = 10
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_BULKY
	is_syndicate = 1
	desc = "A gas powered antique. This one is the real deal. Time for a space chainsaw massacre."
	contraband = 10 //scary
	sawnoise = 'sound/machines/chainsaw_red.ogg'
	arm_icon = "chainsaw_s-D"
	base_arm = "chainsaw_s"
	stamina_damage = 100
	stamina_cost = 30
	stamina_crit_chance = 40
	c_flags = EQUIPPED_WHILE_HELD | NOT_EQUIPPED_WHEN_WORN

	setupProperties()
		. = ..()
		setProperty("deflection", 75)

	attack_self(mob/user as mob)
		if(ON_COOLDOWN(src, "redsaw_toggle", 1 SECOND))
			return
		..()
		if (src.active)
			playsound(src, 'sound/machines/chainsaw_red_start.ogg', 90, 0)
		else
			playsound(src, 'sound/machines/chainsaw_red_stop.ogg', 90, 0)

	attack(mob/target, mob/user)
		if(!active)
			return ..()
		if (iscarbon(target))
			var/mob/living/carbon/C = target
			if (isdead(C))
				logTheThing(LOG_COMBAT, user, "butchers [C]'s corpse with the [src.name] at [log_loc(C)].")
				for (var/i=0, i<3, i++)
					new /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat(get_turf(C),C)
				if (C.mind)
					C.ghostize()
					qdel(C)
				else
					qdel(C)
				return

		if (!ishuman(target))
			target.changeStatus("weakened", 3 SECONDS)
			return ..()

		if (target.nodamage)
			return ..()

		if (target.spellshield)
			return ..()

		target.changeStatus("weakened", 3 SECONDS)
		var/mob/living/carbon/human/H = target
		if(prob(35))
			gibs(target.loc, blood_DNA=H.bioHolder.Uid, blood_type=H.bioHolder.bloodType, headbits=FALSE, source=H)

		if (H.organHolder && active)
			if (H.organHolder.appendix)
				H.organHolder.drop_organ("appendix")
				playsound(target.loc, 'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
				target.visible_message(
					"<span class='alert'><b>[target]'s appendix is ripped out [pick("violently", "brutally", "ferociously", "fiercely")]!</span>"
					)
				make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)
				return ..()

			if (H.organHolder.left_kidney)
				H.organHolder.drop_organ("left_kidney")
				playsound(target.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
				target.visible_message(
					"<span class='alert'><b>[target]'s kidney is torn out [pick("cruelly", "viciously", "atrociously", "fiercely")]!</span>"
					)
				make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)
				return ..()

			if (H.organHolder.left_lung)
				H.organHolder.drop_organ("left_lung")
				playsound(target.loc, 'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
				target.visible_message(
					"<span class='alert'><b>[target]'s lung is gashed out [pick("tempestuously", "impetuously", "sorta meanly", "unpleasantly")]!</span>"
					)
				make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)
				return ..()

			if (H.organHolder.right_kidney)
				H.organHolder.drop_organ("right_kidney")
				playsound(target.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
				target.visible_message(
					"<span class='alert'><b>[target]'s kidney is torn out [pick("cruelly", "viciously", "atrociously", "fiercely")]!</span>"
					)
				make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)
				return ..()

			if (H.organHolder.right_lung)
				H.organHolder.drop_organ("right_lung")
				playsound(target.loc, 'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
				target.visible_message(
					"<span class='alert'><b>[target]'s lung is gashed out [pick("tempestuously", "impetuously", "sorta meanly", "unpleasantly")]!</span>"
					)
				make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)
				return ..()

			if (H.organHolder.liver)
				H.organHolder.drop_organ("liver")
				playsound(target.loc, 'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
				target.visible_message(
					"<span class='alert'><b>[target]'s liver is gashed out [pick("unnecessarily", "stylishly", "viciously", "unethically")]!</span>"
					)
				make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)

				return ..()

			if (H.organHolder.heart) //move this up or down to make it kill faster or later
				H.organHolder.drop_organ("heart")
				playsound(target.loc, 'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
				target.visible_message(
					"<span class='alert'><b>[target]'s heart is ripped clean out! [pick("HOLY MOLY", "FUCK", "JESUS CHRIST", "THAT'S GONNA LEAVE A MARK", "OH GOD", "OUCH", "DANG", "WOW", "woah")]!!</span>"
					)
				make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)
				return ..()


			if (H.organHolder.spleen)
				H.organHolder.drop_organ("spleen")
				playsound(target.loc, 'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
				target.visible_message(
					"<span class='alert'><b>[target]'s spleen is removed with [pick("conviction", "malice", "disregard for safety regulations", "contempt")]!</span>"
					)
				make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)
				return ..()

			if (H.organHolder.pancreas)
				H.organHolder.drop_organ("pancreas")
				playsound(target.loc, 'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
				target.visible_message(
					"<span class='alert'><b>[target]'s pancreas is evicted with [pick("anger", "ill intent", "disdain")]!</span>"
					)
				make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)
				return ..()

			if (H.health < -500) //gib if it can't take any more organs and target is very damaged
				target.gib()
				return
			else
				return ..()

	proc/end_replace_arm(var/target, var/mob/living/carbon/human/H)
		if(!H)
			return
		if (!H.find_in_hand(src))
			boutput(H, "<span class='alert'>You need to be holding your saw!</span>")
			return
		var/obj/item/parts/human_parts/arm/new_arm = null
		if (target == "l_arm")
			if (H.limbs.l_arm)
				playsound(H.loc, 'sound/machines/chainsaw.ogg', 50, 1)
				playsound(H.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
				H.limbs.l_arm.sever()
				H.visible_message("[H] chainsaws their own arm off, holy shit!", "You grit your teeth and saw your own arm off!", "You hear a chainsaw on flesh!")
			new_arm = new /obj/item/parts/human_parts/arm/left/item(H)
			H.limbs.l_arm = new_arm
		else if (target == "r_arm")
			if (H.limbs.r_arm)
				playsound(H.loc, 'sound/machines/chainsaw.ogg', 50, 1)
				playsound(H.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
				H.limbs.r_arm.sever()
				H.visible_message("[H] chainsaws their own arm off, holy shit!", "You grit your teeth and saw your own arm off!", "You hear a chainsaw on flesh!")
			new_arm = new /obj/item/parts/human_parts/arm/right/item(H)
			H.limbs.r_arm = new_arm
		if (!new_arm) return //who knows

		new_arm.holder = H
		H.remove_item(src)

		new_arm:set_item(src)
		src.cant_drop = 1

		H.set_body_icon_dirty()
		H.hud.update_hands()
		for (var/obj/ability_button/B in src.ability_buttons)
			if (istype(B, /obj/ability_button/saw_replace_arm))
				H.item_abilities.Remove(B)
		H.need_update_item_abilities = 1
		H.update_item_abilities()
		H.visible_message("[H] attaches a chainsaw to the stump where their arm should be", "You attach your saw to where your arm should be")

/obj/item/saw/syndie/abilities = list(/obj/ability_button/saw_replace_arm)

/obj/item/saw/syndie/vr
	icon = 'icons/effects/VR.dmi'

TYPEINFO(/obj/item/saw/elimbinator)
	mats = 12

/obj/item/saw/elimbinator
	name = "The Elimbinator"
	desc = "Lops off limbs left and right!"
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "c_saw_s"
	item_state = "c_saw_s"
	base_state = "c_saw_s"
	hit_type = DAMAGE_CUT
	active = 1
	force = 5
	active_force = 10
	off_force = 5
	health = 10
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_BULKY
	sawnoise = 'sound/machines/chainsaw_red.ogg'
	hitsound = 'sound/machines/chainsaw_red.ogg'
	arm_icon = "chainsaw_s-A"
	base_arm = "chainsaw_s"
	stamina_damage = 40
	stamina_cost = 40
	stamina_crit_chance = 50

	attack(mob/target, mob/user)
		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			var/list/limbs = list("l_arm","r_arm","l_leg","r_leg")
			var/the_limb = null

			if (user.zone_sel.selecting in limbs)
				the_limb = user.zone_sel.selecting
			else
				the_limb = pick("l_arm","r_arm","l_leg","r_leg")

			if (!the_limb)
				return //who knows

			H.sever_limb(the_limb)
			H.changeStatus("stunned", 3 SECONDS)
			bleed(H, 3, 5)
		return ..()

////////////////////////////////////// Plant analyzer //////////////////////////////////////

TYPEINFO(/obj/item/plantanalyzer)
	mats = 4

/obj/item/plantanalyzer/
	name = "plant analyzer"
	desc = "A device which examines the genes of plant seeds."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "plantanalyzer"
	w_class = W_CLASS_TINY
	c_flags = ONBELT

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if (BOUNDS_DIST(A, user) > 0)
			return

		boutput(user, scan_plant(A, user, visible = 1)) // Replaced with global proc (Convair880).
		src.add_fingerprint(user)
		return

/////////////////////////////////////////// Seed fabricator ///////////////////////////////

/obj/item/seedplanter
	name = "portable seed fabricator"
	desc = "A tool for cyborgs used to create plant seeds."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "portable_seed_fab"
	var/datum/plant/selected = null


	attack_self(var/mob/user as mob)
		playsound(src.loc, 'sound/machines/click.ogg', 100, 1)
		var/holder = src.loc
		var/datum/plant/pick = tgui_input_list(user, "Which seed do you want?", "Portable Seed Fabricator", hydro_controls.vendable_plants)
		if (src.loc != holder)
			return
		src.selected = pick

	afterattack(atom/target as obj|mob|turf, mob/user as mob, flag)
		if (isturf(target) && selected)
			var/obj/item/seed/S
			// if (selected.unique_seed)
			// 	S = new selected.unique_seed(src.loc)
			// else
			// 	S = new /obj/item/seed(src.loc,0)
			// S.generic_seed_setup(selected)
			if (selected.unique_seed)
				S = new selected.unique_seed
				S.set_loc(src.loc)
			else
				S = new /obj/item/seed
				S.set_loc(src.loc)
				S.removecolor()
			S.generic_seed_setup(selected)



/obj/item/seedplanter/hidden
	desc = "This is supposed to be a cyborg part. You're not quite sure what it's doing here."


///////////////////////////////////// Garden Trowel ///////////////////////////////////////////////

/obj/item/gardentrowel
	name = "garden trowel"
	desc = "A tool to uproot plants and transfer them to decorative pots"
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/screwdriver.dmi'
	icon_state = "trowel"

	flags = FPRINT | TABLEPASS
	c_flags = ONBELT
	w_class = W_CLASS_TINY

	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	stamina_damage = 10
	stamina_cost = 10
	stamina_crit_chance = 30
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'

	rand_pos = 1
	var/image/plantyboi

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)

	afterattack(obj/target as obj, mob/user as mob)
		if(istype(target, /obj/machinery/plantpot))
			var/obj/machinery/plantpot/pot = target
			if(pot.current)
				var/datum/plant/p = pot.current
				if(p.growthmode == "weed")
					user.visible_message("<b>[user]</b> tries to uproot the [p.name], but it's roots hold firmly to the [pot]!","<span class='alert'>The [p.name] is too strong for you traveller...</span>")
					return
				if(pot.GetOverlayImage("plant"))
					plantyboi = pot.GetOverlayImage("plant")
					plantyboi.pixel_x = 2
					src.icon_state = "trowel_full"
				else
					return
				pot.HYPdestroyplant()

		//check if target is a plant pot to paste in the cosmetic plant overlay
///////////////////////////////////// Watering can ///////////////////////////////////////////////

/obj/item/reagent_containers/glass/wateringcan
	name = "watering can"
	desc = "Used to water things. Obviously."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "wateringcan"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "wateringcan"
	amount_per_transfer_from_this = 60
	w_class = W_CLASS_NORMAL
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	initial_volume = 120
	can_recycle = FALSE

	New()
		..()
		reagents.add_reagent("water", 120)

/obj/item/reagent_containers/glass/wateringcan/old
	name = "antique watering can"
	desc = "Used to water things. Obviously. But in a sort of rustic way..."
	icon_state = "watercan_old"
	item_state = ""				//it didn't have an in-hand icon ever...

/obj/item/reagent_containers/glass/wateringcan/gold
	name = "golden watering can"
	desc = "Used to water things. Obviously. But it's golden..."
	icon_state = "wateringcan_gold"
	item_state = "wateringcan_gold"

/obj/item/reagent_containers/glass/wateringcan/weed
	name = "weed watering can"
	desc = "Used to water things. Obviously."
	icon_state = "wateringcan_weed"
	item_state = "wateringcan_weed"

/obj/item/reagent_containers/glass/wateringcan/rainbow
	name = "rainbow watering can"
	desc = "Used to water things. Obviously. It's rainbow..."
	icon_state = "wateringcan_rainbow"
	item_state = "wateringcan_rainbow"

/////////////////////////////////////////// Compost bag ////////////////////////////////////////////////

/obj/item/reagent_containers/glass/compostbag/
	name = "compost bag"
	desc = "A big bag of shit."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "compost"
	amount_per_transfer_from_this = 10
	w_class = W_CLASS_NORMAL
	rc_flags = 0
	initial_volume = 60

	New()
		..()
		reagents.add_reagent("poo", 60)

/////////////////////////////////////////// Plant formulas /////////////////////////////////////

/obj/item/reagent_containers/glass/bottle/weedkiller
	name = "weedkiller"
	desc = "A small bottle filled with Atrazine, an effective weedkiller."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"
	amount_per_transfer_from_this = 10
	initial_volume = 40

	New()
		..()
		reagents.add_reagent("weedkiller", 40)

/obj/item/reagent_containers/glass/bottle/mutriant
	name = "Mutagenic Plant Formula"
	desc = "An unstable radioactive mixture that stimulates genetic diversity."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 10
	initial_volume = 40

	New()
		..()
		reagents.add_reagent("mutagen", 40)

/obj/item/reagent_containers/glass/bottle/groboost
	name = "Ammonia Plant Formula"
	desc = "A nutrient-rich plant formula that encourages quick plant growth."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 10
	initial_volume = 40

	New()
		..()
		reagents.add_reagent("ammonia", 40)

/obj/item/reagent_containers/glass/bottle/topcrop
	name = "Potash Plant Formula"
	desc = "A nutrient-rich plant formula that encourages large crop yields."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 10
	initial_volume = 40

	New()
		..()
		reagents.add_reagent("potash", 40)

/obj/item/reagent_containers/glass/bottle/powerplant
	name = "Saltpetre Plant Formula"
	desc = "A nutrient-rich plant formula that encourages more potent crops."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 10
	initial_volume = 40

	New()
		..()
		reagents.add_reagent("saltpetre", 40)

/obj/item/reagent_containers/glass/bottle/fruitful
	name = "Mutadone Plant Formula"
	desc = "A nutrient-rich formula that attempts to rectify genetic problems."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 10
	initial_volume = 40

	New()
		..()
		reagents.add_reagent("mutadone", 40)

/obj/item/reagent_containers/glass/happyplant
	name = "Happy Plant Mixture"
	desc = "250 units of things that make plants grow happy!"
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "happyplant"
	amount_per_transfer_from_this = 50
	w_class = W_CLASS_NORMAL
	incompatible_with_chem_dispensers = 1
	rc_flags = RC_SCALE
	initial_volume = 250
	initial_reagents = list("saltpetre"=50, "ammonia"=50, "potash"=50, "poo"=50, "space_fungus"=50)

/obj/item/reagent_containers/glass/water_pipe
	name = "water pipe"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bong"

	filled

/obj/item/reagent_containers/glass/jug
	name = "Jug"
	desc = "A sizable jug to hold liquids."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "Jug"
	amount_per_transfer_from_this = 25
	w_class = W_CLASS_NORMAL
	incompatible_with_chem_dispensers = TRUE
	rc_flags = RC_FULLNESS | RC_SPECTRO
	initial_volume = 200

/obj/item/reagent_containers/glass/jug/mutagenicbulk
	name = "Mutagenic Plant Nutrients"
	desc = "A wholesale jug of an unstable radioactive mixture that stimulates genetic diversity. Holds up to 200 units."
	icon_state = "MutagenicJug"
	initial_reagents = list("mutagen"=200)

/obj/item/reagent_containers/glass/jug/ammoniabulk
	name = "Quick-Growth Plant Nutrients"
	desc = "A wholesale jug a nutrient-rich plant formula that encourages quick plant growth. Holds up to 200 units."
	icon_state = "AmmoniaJug"
	initial_reagents = list("ammonia"=200)

/obj/item/reagent_containers/glass/jug/potashbulk
	name = "High-Yield Plant Nutrients"
	desc = "A wholesale jug of a nutrient-rich plant formula that encourages large crop yields. Holds up to 200 units."
	icon_state = "PotashJug"
	initial_reagents = list("potash"=200)

/obj/item/reagent_containers/glass/jug/saltpetrebulk
	name = "High-Strength Plant Nutrients"
	desc = "A wholesale jug of a nutrient-rich plant formula that encourages more potent crops. Holds up to 200 units."
	icon_state = "SaltpetreJug"
	initial_reagents = list("saltpetre"=200)

/obj/item/reagent_containers/glass/jug/mutadonebulk
	name = "Healthy Plant Nutrients"
	desc = "A wholesale jug of a nutrient-rich formula that attempts to rectify genetic problems. Holds up to 200 units."
	icon_state = "MutadoneJug"
	initial_reagents = list("mutadone"=200)
