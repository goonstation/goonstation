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

/obj/item/saw
	name = "chainsaw"
	desc = "A chainsaw used to chop up harmful plants."
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "c_saw_off"
	item_state = "c_saw"
	var/base_state = "c_saw"
	var/active = 0.0
	hit_type = DAMAGE_CUT
	force = 3.0
	var/active_force = 12.0
	var/off_force = 3.0
	var/how_dangerous_is_this_thing = 1
	var/takes_damage = 1
	health = 10.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 4.0
	flags = FPRINT | TABLEPASS | CONDUCT
	tool_flags = TOOL_SAWING
	mats = 12
	var/sawnoise = 'sound/machines/chainsaw_green.ogg'
	arm_icon = "chainsaw0"
	over_clothes = 1
	override_attack_hand = 1
	can_hold_items = 0
	stamina_damage = 30
	stamina_cost = 15
	stamina_crit_chance = 35

	cyborg
		takes_damage = 0

	New()
		..()
		SPAWN_DBG (5)
			if (src)
				src.update_icon()
		BLOCK_ROD
		return

	proc/check_health()
		if (src.health <= 0 && src.takes_damage)
			SPAWN_DBG (2)
				if (src)
					usr.u_equip(src)
					usr.update_inhands()
					boutput(usr, "<span class='alert'>[src] falls apart!</span>")
					qdel(src)
		return

	proc/damage_health(var/amt)
		src.health -= amt
		src.check_health()
		return

	proc/update_icon()
		set_icon_state("[src.base_state][src.active ? null : "_off"]")
		return

	// Fixed a couple of bugs and cleaned code up a little bit (Convair880).
	attack(mob/target as mob, mob/user as mob)
		if (!istype(target))
			return

		if (src.active)

			user.lastattacked = target
			target.lastattacker = user
			target.lastattackertime = world.time

			if (ishuman(target))
				if (ishuman(user) && saw_surgery(target,user))
					src.damage_health(2)
					take_bleeding_damage(target, user, 2, DAMAGE_CUT)
					return
				else if (!isdead(target))
					take_bleeding_damage(target, user, 5, DAMAGE_CUT)
					if (prob(80))
						target.emote("scream")

			playsound(target, sawnoise, 60, 1)//need a better sound

			if (src.takes_damage)
				if (issilicon(target))
					src.damage_health(4)
				else
					src.damage_health(1)

			switch (src.how_dangerous_is_this_thing)
				if (2) // Red chainsaw.
					if (iscarbon(target))
						var/mob/living/carbon/C = target
						if (!isdead(C))
							C.changeStatus("stunned", 3 SECONDS)
							C.changeStatus("weakened", 3 SECONDS)
						else
							logTheThing("combat", user, C, "butchers [C]'s corpse with the [src.name] at [log_loc(C)].")
							var/sourcename = C.real_name
							var/sourcejob = "Stowaway"
							if (C.mind && C.mind.assigned_role)
								sourcejob = C.mind.assigned_role
							else if (C.ghost && C.ghost.mind && C.ghost.mind.assigned_role)
								sourcejob = C.ghost.mind.assigned_role
							for (var/i=0, i<3, i++)
								var/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/meat = new /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat(get_turf(C))
								meat.name = sourcename + meat.name
								meat.subjectname = sourcename
								meat.subjectjob = sourcejob
							if (C.mind)
								C.ghostize()
								qdel(C)
								return
							else
								qdel(C)
								return

				if (3) // Elimbinator.
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
		..()
		return

	attack_self(mob/user as mob)
		if (user.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span class='alert'><b>[user]</b> accidentally grabs the blade of [src].</span>")
			user.TakeDamage(user.hand == 1 ? "l_arm" : "r_arm", 5, 5)
			JOB_XP(user, "Clown", 1)
		src.active = !( src.active )
		if (src.active)
			boutput(user, "<span class='notice'>[src] is now active.</span>")
			src.force = active_force
		else
			boutput(user, "<span class='notice'>[src] is now off.</span>")
			src.force = off_force
		tooltip_rebuild = 1
		src.update_icon()
		user.update_inhands()
		src.add_fingerprint(user)
		return

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] shoves the chainsaw into [his_or_her(user)] chest!</b></span>")
		user.u_equip(src)
		src.set_loc(user.loc)
		user.gib()
		return 1

/obj/item/saw/abilities = list(/obj/ability_button/saw_toggle)

/obj/item/saw/syndie
	name = "red chainsaw"
	icon_state = "c_saw_s_off"
	item_state = "c_saw_s"
	base_state = "c_saw_s"
	tool_flags = TOOL_SAWING | TOOL_CHOPPING //fucks up doors. fuck doors
	active = 0.0
	force = 6.0
	active_force = 20.0
	off_force = 6.0
	health = 10
	takes_damage = 0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 4.0
	is_syndicate = 1
	how_dangerous_is_this_thing = 1 //it gibs differently
	mats = 14
	desc = "This one is the real deal. Time for a space chainsaw massacre."
	contraband = 10 //scary
	sawnoise = 'sound/machines/chainsaw_red.ogg'
	arm_icon = "chainsaw1"
	stamina_damage = 100
	stamina_cost = 30
	stamina_crit_chance = 40

/obj/item/saw/syndie/attack(mob/living/carbon/human/target as mob, mob/user as mob)
	var/mob/living/carbon/human/H = target

	if (H.organHolder && active == 1)
		if (H.organHolder.appendix)
			H.organHolder.drop_organ("appendix")
			playsound(target.loc,'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s appendix is ripped out [pick("violently", "brutally", "ferociously", "fiercely")]!</span>"
				)
			make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)
			return ..()

		if (H.organHolder.left_kidney)
			H.organHolder.drop_organ("left_kidney")
			playsound(target.loc,'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s kidney is torn out [pick("cruelly", "viciously", "atrociously", "fiercely")]!</span>"
				)
			make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)
			return ..()

		if (H.organHolder.left_lung)
			H.organHolder.drop_organ("left_lung")
			playsound(target.loc,'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s lung is gashed out [pick("tempestuously", "impetuously", "sorta meanly", "unpleasantly")]!</span>"
				)
			make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)
			return ..()

		if (H.organHolder.right_kidney)
			H.organHolder.drop_organ("right_kidney")
			playsound(target.loc,'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s kidney is torn out [pick("cruelly", "viciously", "atrociously", "fiercely")]!</span>"
				)
			make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)
			return ..()

		if (H.organHolder.right_lung)
			H.organHolder.drop_organ("right_lung")
			playsound(target.loc,'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s lung is gashed out [pick("tempestuously", "impetuously", "sorta meanly", "unpleasantly")]!</span>"
				)
			make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)
			return ..()

		if (H.organHolder.liver)
			H.organHolder.drop_organ("liver")
			playsound(target.loc,'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s liver is gashed out [pick("unnecessarily", "stylishly", "viciously", "unethically")]!</span>"
				)
			make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)

			return ..()

		if (H.organHolder.heart) //move this up or down to make it kill faster or later
			H.organHolder.drop_organ("heart")
			playsound(target.loc,'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s heart is ripped clean out! [pick("HOLY MOLY", "FUCK", "JESUS CHRIST", "THAT'S GONNA LEAVE A MARK", "OH GOD", "OUCH", "DANG", "WOW", "woah")]!!</span>"
				)
			make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)
			return ..()


		if (H.organHolder.spleen)
			H.organHolder.drop_organ("spleen")
			playsound(target.loc,'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
			target.visible_message(
				"<span class='alert'><b>[target]'s spleen is removed with [pick("conviction", "malice", "disregard for safety regulations", "contempt")]!</span>"
				)
			make_cleanable(/obj/decal/cleanable/blood/gibs,target.loc)
			return ..()

		if (H.organHolder.pancreas)
			H.organHolder.drop_organ("pancreas")
			playsound(target.loc,'sound/impact_sounds/Slimy_Splat_2_Short.ogg', 50, 1)
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

/obj/item/saw/syndie/vr
	icon = 'icons/effects/VR.dmi'

/obj/item/saw/elimbinator
	name = "The Elimbinator"
	desc = "Lops off limbs left and right!"
	icon = 'icons/obj/items/weapons.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "c_saw_s"
	item_state = "c_saw_s"
	base_state = "c_saw_s"
	hit_type = DAMAGE_CUT
	active = 1.0
	force = 5
	active_force = 10.0
	off_force = 5.0
	health = 10
	how_dangerous_is_this_thing = 3
	takes_damage = 0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 4.0
	mats = 12
	sawnoise = 'sound/machines/chainsaw_red.ogg'
	arm_icon = "chainsaw1"
	stamina_damage = 40
	stamina_cost = 40
	stamina_crit_chance = 50

////////////////////////////////////// Plant analyzer //////////////////////////////////////

/obj/item/plantanalyzer/
	name = "plant analyzer"
	desc = "A device which examines the genes of plant seeds."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "plantanalyzer"
	w_class = 1.0
	flags = ONBELT
	mats = 4
	module_research = list("analysis" = 4, "devices" = 4, "hydroponics" = 2)

	afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
		if (get_dist(A, user) > 1)
			return

		boutput(user, scan_plant(A, user, visible = 1)) // Replaced with global proc (Convair880).
		src.add_fingerprint(user)
		return

/////////////////////////////////////////// Seed fabricator ///////////////////////////////

/obj/item/seedplanter
	name = "Portable Seed Fabricator"
	desc = "A tool for cyborgs used to create plant seeds."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "forensic0"
	var/datum/plant/selected = null


	attack_self(var/mob/user as mob)
		playsound(src.loc, "sound/machines/click.ogg", 100, 1)
		var/list/usable = list()
		for(var/datum/plant/A in hydro_controls.plant_species)
			if (!A.vending)
				continue
			usable += A

		var/datum/plant/pick = input(usr, "Which seed do you want?", "Portable Seed Fabricator", null) in usable
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
				S = unpool(selected.unique_seed)
				S.set_loc(src.loc)
			else
				S = unpool(/obj/item/seed)
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

	flags = FPRINT | TABLEPASS | ONBELT
	w_class = 1.0

	force = 5.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	stamina_damage = 10
	stamina_cost = 10
	stamina_crit_chance = 30
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'

	module_research = list("tools" = 4, "metals" = 1)
	rand_pos = 1
	var/image/plantyboi

	New()
		..()
		BLOCK_KNIFE

	afterattack(obj/target as obj, mob/user as mob)
		if(istype(target, /obj/machinery/plantpot))
			var/obj/machinery/plantpot/pot = target
			if(pot.current)
				var/datum/plant/p = pot.current
				if(pot.GetOverlayImage("plant"))
					plantyboi = pot.GetOverlayImage("plant")
					plantyboi.pixel_x = 2
					src.icon_state = "trowel_full"
				else
					return
				if(p.growthmode == "weed")
					user.visible_message("<b>[user]</b> tries to uproot the [p.name], but it's roots hold firmly to the [pot]!","<span class='alert'>The [p.name] is too strong for you traveller...</span>")
					return
				pot.HYPdestroyplant()

		//check if target is a plant pot to paste in the cosmetic plant overlay
///////////////////////////////////// Watering can ///////////////////////////////////////////////

/obj/item/reagent_containers/glass/wateringcan/
	name = "watering can"
	desc = "Used to water things. Obviously."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "watercan"
	amount_per_transfer_from_this = 60
	w_class = 3.0
	rc_flags = RC_FULLNESS | RC_VISIBLE | RC_SPECTRO
	module_research = list("tools" = 2, "hydroponics" = 4)

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(120)
		reagents = R
		R.my_atom = src
		R.add_reagent("water", 120)

/////////////////////////////////////////// Compost bag ////////////////////////////////////////////////

/obj/item/reagent_containers/glass/compostbag/
	name = "compost bag"
	desc = "A big bag of shit."
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "compost"
	amount_per_transfer_from_this = 10
	w_class = 3.0
	rc_flags = 0
	module_research = list("tools" = 1, "hydroponics" = 1)

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(60)
		reagents = R
		R.my_atom = src
		R.add_reagent("poo", 60)

/////////////////////////////////////////// Plant formulas /////////////////////////////////////

/obj/item/reagent_containers/glass/bottle/weedkiller
	name = "weedkiller"
	desc = "A small bottle filled with Atrazine, an effective weedkiller."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle1"
	amount_per_transfer_from_this = 10
	module_research = list("tools" = 1, "hydroponics" = 1, "science" = 1)
	module_research_type = /obj/item/reagent_containers/glass/bottle/weedkiller

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(40)
		reagents = R
		R.my_atom = src
		R.add_reagent("weedkiller", 40)

/obj/item/reagent_containers/glass/bottle/mutriant
	name = "Mutagenic Plant Formula"
	desc = "An unstable radioactive mixture that stimulates genetic diversity."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 10

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(40)
		reagents = R
		R.my_atom = src
		R.add_reagent("mutagen", 40)

/obj/item/reagent_containers/glass/bottle/groboost
	name = "Ammonia Plant Formula"
	desc = "A nutrient-rich plant formula that encourages quick plant growth."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 10

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(40)
		reagents = R
		R.my_atom = src
		R.add_reagent("ammonia", 40)

/obj/item/reagent_containers/glass/bottle/topcrop
	name = "Potash Plant Formula"
	desc = "A nutrient-rich plant formula that encourages large crop yields."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 10

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(40)
		reagents = R
		R.my_atom = src
		R.add_reagent("potash", 40)

/obj/item/reagent_containers/glass/bottle/powerplant
	name = "Saltpetre Plant Formula"
	desc = "A nutrient-rich plant formula that encourages more potent crops."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 10

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(40)
		reagents = R
		R.my_atom = src
		R.add_reagent("saltpetre", 40)

/obj/item/reagent_containers/glass/bottle/fruitful
	name = "Mutadone Plant Formula"
	desc = "A nutrient-rich formula that attempts to rectify genetic problems."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle3"
	amount_per_transfer_from_this = 10

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(40)
		reagents = R
		R.my_atom = src
		R.add_reagent("mutadone", 40)

/obj/item/reagent_containers/glass/happyplant
	name = "Happy Plant Mixture"
	desc = "250 units of things that make plants grow happy!"
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	icon_state = "happyplant"
	amount_per_transfer_from_this = 50
	w_class = 3.0
	incompatible_with_chem_dispensers = 1
	rc_flags = RC_SCALE
	initial_volume = 250
	initial_reagents = list("saltpetre"=50, "ammonia"=50, "potash"=50, "poo"=50, "space_fungus"=50)
