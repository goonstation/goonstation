//Yikes let's put all these stone powers in one place
//This is Readster's very messy attempt at ability code (<-- Eff You)

//Space Stone
/obj/ability_button/stone_teleport
	name = "Telecrystal Stone"
	icon_state = "spiritrockbutton"
	icon = 'icons/obj/ouroborousrocks.dmi'
	cooldown = 600

	execute_ability()
		logTheThing(LOG_COMBAT, usr, "used the Brass Gauntlet and triggered the [src.name]'s effect at [log_loc(usr)]")
		SPAWN(0)
			the_mob.teleportscroll(1, 0, null)

		return 1


//Soul Stone
/obj/ability_button/stone_animate
	name = "SoulSteel Stone"
	icon_state = "spiritrockbutton"
	icon = 'icons/obj/ouroborousrocks.dmi'
	cooldown = 3000

	execute_ability()
		SPAWN(0)
			usr.visible_message("<span class='alert'><B>[usr] channels souls into all nearby objects!</B></span>")
			logTheThing(LOG_COMBAT, usr, "used the Brass Gauntlet and triggered the [src.name]'s effect at [log_loc(usr)]")
			for(var/obj/item/I in oview(5, usr)) //No longer brings your organs to life, killing you as they desperately try to attack you from the inside!
				if (I.anchored || I.invisibility) continue
				new/mob/living/object/ai_controlled(src.loc, src)
		..()
		return 1

//Power Stone
/obj/ability_button/stone_power
	name = "Erebite Stone"
	icon_state = "teleport" //change later
	cooldown = 200

	execute_ability()
		//Presumably explode a dude
		logTheThing(LOG_COMBAT, usr, "used the Brass Gauntlet and triggered the [src.name]'s effect at [log_loc(usr)]")
		boutput(the_mob, "<span class='alert'>You totally would've exploded a dude. If it was implemented. This power stone is kinda chumpy, huh?</span>")
		..()
		return 1

//Time Stone
/obj/ability_button/stone_time
	name = "Space Lag Stone"
	icon_state = "teleport" //change later
	cooldown = 1400
	var/casting = 0

	execute_ability()
		logTheThing(LOG_COMBAT, usr, "used the Brass Gauntlet and triggered the [src.name]'s effect at [log_loc(usr)]")
		usr.visible_message("<span class='alert'><B>[usr] flicks his hand and begins to warp time!</B></span>")
		SPAWN(0)
			usr.full_heal()
			timeywimey(100)
		..()
		return 1

//Reality Stone
/obj/ability_button/stone_reality
	name = "Miracle-Matter Stone"
	icon_state = "teleport"
	cooldown = 600

	execute_ability()
		logTheThing(LOG_COMBAT, usr, "used the Brass Gauntlet and triggered the [src.name]'s effect at [log_loc(usr)]")
		SPAWN(0)
			var/distance = 1
			var/list/affected = list()

			for(distance=1,distance<=10, distance++) //For each row of the cone
				var/turf/centerOfRow = get_steps(usr, usr.dir, distance) //Get the center tile at the current distance.
				affected.Add(centerOfRow) //and add it to the list
				for(var/steps=1,steps<=(distance-1), steps++) //For each tile of width of the cone in the current row.
					affected.Add(get_steps(centerOfRow, turn(usr.dir,-90), steps)) //Get the left and right of the current row at the current width
					affected.Add(get_steps(centerOfRow, turn(usr.dir,90), steps))  //And add them to our list

			for(var/turf/T in affected)
				var/list/material = list("gold","silver","spacelag","iridiumalloy","soulsteel","erebite","ruby","onyx","diamond","topaz","emerald","telecrystal","miracle","ice","flesh","pizza")
				T.setMaterial(getMaterial(pick(material)))
				var/dir_temp = pick("L", "R")
				animate_spin(T, dir_temp, 3)
				sleep(0.1)
			for(var/mob/M in affected)
				var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
				smoke.set_up(5, 0, M.loc)
				smoke.attach(M)
				smoke.start()
				M.unequip_all()
				var/mob/living/critter/C = M.make_critter(pick(animal_spell_critter_paths))
				if (istype(C, /mob/living/critter/small_animal/bee))
					var/mob/living/critter/small_animal/bee/B = C
					B.non_admin_bee_allowed = 1
				C.changeStatus("stunned", 10 SECONDS)

			for(var/turf/T in affected)
				animate(T)
		..()
		return 1

///////////////////////////////////////
///////////Gimmick Stones/////////////

//Owl Stone
/obj/ability_button/stone_owl
	name = "Owl Stone"
	icon_state = "owlstonebutton"
	icon = 'icons/obj/ouroborousrocks.dmi'
	cooldown = 600

	execute_ability()
		logTheThing(LOG_COMBAT, usr, "used the Brass Gauntlet and triggered the [src.name]'s effect at [log_loc(usr)]")
		SPAWN(0)
			boutput(usr,"<span class='alert'><B>You spead the energies of the owl around you.</B></span>")
			playsound(usr.loc, 'sound/voice/animal/hoot.ogg', 100, 1)
			for(var/mob/living/carbon/human/M in range(5, usr))
				if(M == usr)
					continue
				M.flash(60)
				M.changeStatus("weakened", 5 SECONDS)
				M.playsound_local(M.loc, 'sound/voice/animal/hoot.ogg', 100, 1)

				if(prob(1))
					if(prob(50))
						M.make_critter(/mob/living/critter/small_animal/bird/owl/large/hooter, M.loc)
					else
						playsound(M.loc, 'sound/voice/animal/hoot.ogg', 100, 1)
						M.gib()
						new /mob/living/critter/small_animal/bird/owl/large/hooter(M.loc)
					continue

				if(prob(10))
					if(prob(50))
						M.make_critter(/mob/living/critter/small_animal/bird/owl, M.loc)
					else
						M.owlgib()
					continue

				if(!(M.wear_mask && istype(M.wear_mask, /obj/item/clothing/mask/owl_mask)))
					if(prob(50))
						for(var/obj/item/clothing/O in M)
							M.u_equip(O)
							if (O)
								O.set_loc(M.loc)
								O.dropped(M)
								O.layer = initial(O.layer)

						var/obj/item/clothing/under/gimmick/owl/owlsuit = new /obj/item/clothing/under/gimmick/owl(M)
						owlsuit.cant_self_remove = 1
						var/obj/item/clothing/mask/owl_mask/owlmask = new /obj/item/clothing/mask/owl_mask(M)
						owlmask.cant_self_remove = 1


						M.equip_if_possible(owlsuit, M.slot_w_uniform)
						M.equip_if_possible(owlmask, M.slot_wear_mask)
						M.set_clothing_icon_dirty()
					continue

				else
					boutput(M,"<span class='alert'><B>You hear an intense and painful hooting inside your head.</B></span>")
					var/hooting = 0
					while(hooting <= rand(8, 12))
						M.playsound_local(M.loc, 'sound/voice/animal/hoot.ogg', 100, 1)
						if(prob(50))
							random_brute_damage(M, rand(1,5))
							M.flash(10)
						M.changeStatus("weakened", 0.5 SECONDS)
						sleep(rand(1,5))
						hooting++

			if (ishuman(usr))
				var/mob/living/carbon/human/H = usr
				if (!(istype(H.w_uniform, /obj/item/clothing/under/gimmick/owl)) || !(istype(H.wear_mask, /obj/item/clothing/mask/owl_mask)))
					if(prob(30))
						boutput(usr,"<span class='alert'><B>The stone rejects you and backfires.</B></span>")
						usr.owlgib()
		..()
		return 1


//Gall Stone
/obj/ability_button/stone_gall
	name = "Gall Stone"
	icon_state = "gallstonebutton"
	icon = 'icons/obj/ouroborousrocks.dmi'
	cooldown = 3000

	execute_ability()
		logTheThing(LOG_COMBAT, usr, "used the Brass Gauntlet and triggered the [src.name]'s effect at [log_loc(usr)]")
		SPAWN(0)
			boutput(usr, "<span class='alert'><B>You spread a feeling of sickness.</B></span>") //Gross
			for(var/mob/living/carbon/human/M in range(5, usr))
				boutput(M,"<span class='alert'><B>Your insides feel like they're fighting to escape your body.</B></span>")
				SPAWN(rand(30,50)) //Let's stagger out the vomitting a bit
					M.visible_message("<span class='alert'><B>[M] is violently sick everywhere!</B></span>")
					random_brute_damage(M, rand(5,30))
					M.changeStatus("weakened", 0.5 SECONDS)
					var/turf/T = get_turf(M)
					playsound(T, pick('sound/impact_sounds/Slimy_Splat_1.ogg','sound/misc/meat_plop.ogg'), 100, 1)
					if(prob(1)) //Oh no you rolled poorly. Welcome to the *instant death raffle!!*
						var/list/organ_list = list("left_eye", "right_eye", "chest", "heart", "left_lung", "right_lung", "butt") //1/7 chance you might die! Spooky!
						var/obj/item/organ/O = pick(organ_list)
						M.organHolder.drop_organ(O, T)

						//Warcrimes you better clean this code up or so help me!
						if(O == "left_eye" || "right_eye")
							O = "eye"
						else if(O == "left_lung" || "right_lung")
							O = "lung"

						M.visible_message("<span class='alert'><B>[M] vomits out their [O]. [pick("Holy shit!", "Holy fuck!", "What the hell!", "What the fuck!", "Jesus Christ!", "Yikes!", "Oof...")]</B></span>")
					else if(prob(10)) //Lucky guy! Now you're only going to lose a less vital organ (and your heart maybe :X)
						var/list/organ_list = list("left_eye", "right_eye", "heart", "left_lung", "right_lung", "butt", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix")
						var/obj/item/organ/O = pick(organ_list)
						M.organHolder.drop_organ(O, T)

						//Warcrimes you better clean this code up or so help me!
						if(O == "left_eye" || "right_eye")
							O = "eye"
						if(O == "left_lung" || "right_lung")
							O = "lung"

						M.visible_message("<span class='alert'><B>[M] vomits out their [O]. [pick("Holy shit!", "Holy fuck!", "What the hell!", "What the fuck!", "Jesus Christ!", "Yikes!", "Oof...")]</B></span>")
					else if(prob(20))
						make_cleanable( /obj/decal/cleanable/blood/gibs,T)
					else
						M.vomit() //Oh geez the janitor will not be happy
		..()
		return 1


//////////////////////////////////////////
//////////////////////////////////////////


//Spookify
proc/badstone(var/mob/user, var/obj/item/W, var/obj/item/clothing/B)
	user.visible_message("<span class='alert'><B>[user] forces the [W] into the [B]!</B></span>")
	user.drop_item()
	W.set_loc(null) //<-- this sets the location to null
	sleep(5 SECONDS)

	playsound(user, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, 1)
	boutput(user,"<span class='alert'><B>The [B] cracks slightly around the stone.</B></span>")
	sleep(20 SECONDS)
	boutput(user,"<span class='alert'><B>The [B] feels really tight on your arm all of a sudden.</B></span>")
	sleep(10 SECONDS)
	playsound(user, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
	boutput(user,"<span class='alert'><B>Like really tight!</B></span>")
	sleep(10 SECONDS)
	playsound(user, 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
	user.emote("scream")
	sleep(5 SECONDS)
	playsound(user, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
	sleep(10 SECONDS)
	playsound(user, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
	user.visible_message("<span class='alert'><B>The [B] begins to glow!</B></span>")
	sleep(2 SECONDS)
	boutput(user, "<span class='alert'><B>The [B] tightens hard around your hand and begins to move on its own!</B></span>")
	playsound(user, 'sound/impact_sounds/Flesh_Crush_1.ogg', 50, 1)
	sleep(5 SECONDS)

	//Everything turns to gold
proc/goldsnap(var/mob/user)
	user.emote("snap")
	sleep(1 SECOND)
	boutput(user, "<span class='alert'><B>Everything around you turns to gold!</B></span>")
	message_admins("Gold snap effect from the Brass Gauntlet triggered at [log_loc(user)] by [key_name(user)].")
	logTheThing(LOG_COMBAT, user, "used the Brass Gauntlet and triggered the goldsnap at [log_loc(user)]")
	var/turf/T = get_turf(user)
	user.set_dir(SOUTH)
	user.become_statue(getMaterial("gold"))
	for(var/turf/G in range(10, T))
		G.setMaterial(getMaterial("gold"))
	sleep(2 SECONDS)
	explosion(T, T, 10, 6, 10, 10)
	sleep(2 SECONDS)
	for(var/obj/I in range(10, T))
		I.setMaterial(getMaterial("gold"))

proc/badmaterial(var/mob/user, var/obj/item/W, var/obj/item/clothing/B)
	user.visible_message("<span class='alert'><B>You push the [W] into the [B]!</B></span>")
	user.drop_item()
	W.set_loc(null) //<-- this sets the location to null
	sleep(5 SECONDS)
	user.visible_message("<span class='alert'><B>The [B] begins to make an ungodly noise. Maybe that wasn't so safe after all...</B></span>")
	sleep(10 SECONDS)
	user.visible_message("<span class='alert'><B>Your body is suddenly and violently ripped apart.</B></span>")
	logTheThing(LOG_COMBAT, user, "used the Brass Gauntlet and gibbed themselves due to a bad material at [log_loc(user)]")
	user.gib()

proc/timeywimey(var/time)
	var/list/positions = list()
	for(var/client/C in clients)
		if(istype(C.mob, /mob/living))
			if(C.mob == usr)
				continue
			var/mob/living/L = C.mob
			positions.Add(L)
			positions[L] = L.loc

//	var/current_time = world.timeofday
//	while (current_time + 100 > world.timeofday && current_time <= world.timeofday)
	sleep(time)

	for(var/mob/living/L in positions)
		if (!L) continue
		L.flash(3 SECONDS)
		boutput(L, "<span class='alert'><B>You suddenly feel yourself pulled violently back in time!</B></span>")
		L.set_loc(positions[L])
		L.changeStatus("stunned", 6 SECONDS)
		elecflash(L,power = 2)
		playsound(L.loc, 'sound/effects/mag_warp.ogg', 25, 1, -1)
	return 1
