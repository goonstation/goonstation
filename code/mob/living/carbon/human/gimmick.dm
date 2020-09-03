// cluwne

/mob/living/carbon/human/cluwne
	New()
		..()
		SPAWN_DBG(0)
			src.gender = "male"
			src.real_name = "cluwne"
			src.contract_disease(/datum/ailment/disease/cluwneing_around,null,null,1)
			src.contract_disease(/datum/ailment/disability/clumsy,null,null,1)

			src.equip_new_if_possible(/obj/item/clothing/under/gimmick/cursedclown, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/shoes/cursedclown_shoes, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/mask/cursedclown_hat, slot_wear_mask)
			src.equip_new_if_possible(/obj/item/clothing/gloves/cursedclown_gloves, slot_gloves)
			src.make_jittery(1000)
			src.bioHolder.AddEffect("clumsy")
			src.take_brain_damage(80)

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		if (isdead(src))
			return
		jitteriness = INFINITY
		stuttering = INFINITY
		HealDamage("All", INFINITY, INFINITY)
		take_oxygen_deprivation(-INFINITY)
		take_toxin_damage(-INFINITY)
		if(prob(5))
			SPAWN_DBG(0)
				src.say("HANK!")
				playsound(src.loc, "sound/musical_instruments/Boathorn_1.ogg", 22, 1)

/mob/living/carbon/human/cluwne/floor
	nodamage = 1
	anchored = 1
	layer = 0
	plane = PLANE_UNDERFLOOR

	var/name_override = "floor cluwne"
	New()
		..()
		SPAWN_DBG(0)
			ailments.Cut()
			real_name = name_override
			name = name_override

	cluwnegib()
		return

	ex_act()
		return

/mob/living/carbon/human/cluwne/floor/gimmick
	layer = 4
	plane = PLANE_DEFAULT
	nodamage = 0

	New()
		..()
		SPAWN_DBG(0)
			src.add_ability_holder(/datum/abilityHolder/gimmick)
			abilityHolder.addAbility(/datum/targetable/gimmick/reveal)
			abilityHolder.addAbility(/datum/targetable/gimmick/movefloor)
			abilityHolder.addAbility(/datum/targetable/gimmick/floorgrab)
			SPAWN_DBG(1 SECOND)
				abilityHolder.updateButtons()

// Come to collect a poor unfortunate soul
/mob/living/carbon/human/satan
	nodamage = 1
	anchored = 1
	layer = 0
	plane = PLANE_UNDERFLOOR
	New()
		..()
		SPAWN_DBG(0)
			src.gender = "male"
			src.real_name = "Satan"
			src.name = "Satan"
			src.equip_new_if_possible(/obj/item/clothing/under/misc/lawyer/red/demonic, src.slot_w_uniform)
			src.bioHolder.AddEffect("horns", 0, 0, 1)
			src.bioHolder.AddEffect("aura_fire", 0, 0, 1)

/mob/living/carbon/human/satan/gimmick
	anchored = 1
	layer = 4
	plane = PLANE_DEFAULT

	New()
		..()
		SPAWN_DBG(0)
			src.add_ability_holder(/datum/abilityHolder/gimmick)
			src.real_name = "Satan"
			src.nodamage = 1
			bioHolder.age = 400
			bioHolder.mobAppearance.customization_first = "Pompadour"
			bioHolder.mobAppearance.customization_first_color = "#000000"
			bioHolder.mobAppearance.gender = "male"
			bioHolder.mobAppearance.underwear = "boxers"
			src.bioHolder.AddEffect("horns", 0, 0, 1)
			src.bioHolder.AddEffect("hell_fire", 0, 0, 1)
			abilityHolder.addAbility(/datum/targetable/gimmick/go2hell)
			abilityHolder.addAbility(/datum/targetable/gimmick/highway2hell)
			abilityHolder.addAbility(/datum/targetable/gimmick/reveal)
			abilityHolder.addAbility(/datum/targetable/gimmick/movefloor)
			SPAWN_DBG(1 SECOND)
				bioHolder.mobAppearance.UpdateMob()
				abilityHolder.updateButtons()

				src.equip_new_if_possible(/obj/item/clothing/under/misc/lawyer/red/demonic, src.slot_w_uniform)
				src.equip_new_if_possible(/obj/item/clothing/suit/labcoat/hitman/satansuit, slot_wear_suit)
				src.equip_new_if_possible(/obj/item/clothing/shoes/red, slot_shoes)
				src.equip_new_if_possible(/obj/item/storage/backpack, slot_back)
				src.equip_new_if_possible(/obj/item/device/radio/headset, slot_ears)
				src.put_in_hand_or_drop(new /obj/item/storage/briefcase/satan)

/mob/living/carbon/human/jester

	New()
		..()
		SPAWN_DBG(0)
			src.real_name = "Jester"
			src.add_ability_holder(/datum/abilityHolder/gimmick)
			src.nodamage = 1
			src.bioHolder.AddEffect("accent_void", 0, 0, 1)
			abilityHolder.addAbility(/datum/targetable/gimmick/spooky)
			abilityHolder.addAbility(/datum/targetable/gimmick/Jestershift)

		SPAWN_DBG(1 SECOND)
			bioHolder.mobAppearance.UpdateMob()
			abilityHolder.updateButtons()

			src.equip_new_if_possible(/obj/item/clothing/under/gimmick/jester, src.slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/shoes/jester, slot_shoes)
			src.equip_new_if_possible(/obj/item/storage/backpack, slot_back)
			src.equip_new_if_possible(/obj/item/clothing/mask/jester, slot_wear_mask)
			src.equip_new_if_possible(/obj/item/device/radio/headset, slot_ears)
			src.equip_new_if_possible(/obj/item/clothing/head/jester, slot_head)

/mob/living/carbon/human/cluwne/floor/anticheat
	name_override = "anti-cheat cluwne"

mob/living/carbon/human/cluwne/satan
	New()
		..()
		SPAWN_DBG(0)
			src.bioHolder.AddEffect("horns", 0, 0, 1)
			src.bioHolder.AddEffect("aura_fire", 0, 0, 1)
			src.bioHolder.AddEffect("superfartgriff")
			src.bioHolder.AddEffect("bigpuke", 0, 0, 1)
			src.bioHolder.AddEffect("melt", 0, 0, 1)

mob/living/carbon/human/cluwne/satan/megasatan //someone can totally use this for an admin gimmick.
	New()
		..()
		SPAWN_DBG(0)
			src.unkillable = 1 //for the megasatan in you

// how you gonna have father ted and father jack and not father dougal? smh

/mob/living/carbon/human/fatherted
	New()
		..()
		SPAWN_DBG(0)
			bioHolder.mobAppearance.gender = "male"
			src.real_name = "Father Ted"

			src.equip_new_if_possible(/obj/item/clothing/shoes/red, slot_shoes)

			src.equip_new_if_possible(/obj/item/clothing/under/rank/chaplain, slot_w_uniform)

			SPAWN_DBG(1 SECOND)
				bioHolder.mobAppearance.UpdateMob()

/mob/living/carbon/human/fatherjack
	New()
		..()
		SPAWN_DBG(0)
			bioHolder.mobAppearance.gender = "male"
			src.real_name = "Father Jack"
			bioHolder.bloodType = "B+"

			src.equip_new_if_possible(/obj/item/clothing/shoes/red, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/misc/chaplain, slot_w_uniform)
			src.traitHolder.addTrait("training_chaplain")

			SPAWN_DBG(1 SECOND)
				bioHolder.mobAppearance.UpdateMob()

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if(prob(1) && !src.stat)
			SPAWN_DBG(0) src.say(pick( "DRINK!", "FECK!", "ARSE!", "GIRLS!","That would be an ecumenical matter."))

	attackby(obj/item/W, mob/M)
		if (istype(W, /obj/item/paper/postcard/owlery))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, "<span class='notice'><b>You show [W] to [src]</b> </span>")
			SPAWN_DBG(1 SECOND)
				say("Aye! Bill won't stop talking about it!")
			return
		..()

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0)
		if (special) //vamp or ling
			src.target = M
			src.ai_state = 2
			src.ai_threatened = world.timeofday
			src.ai_target = M

		//Bartender isnt' used right now.
		//Whoever does eventually put him back in the game : Use a global list of bartenders or something. Dont check all_viewers
		//	for (var/mob/living/carbon/human/npc/diner_bartender/BT in all_viewers(7, src))
			//	BT.protect_from(M, src)

//biker // cogwerks - bringing back the bikers for the diner, now less offensive

/// BILL SPEECH STUFF

#define BILL_PICK(WHAT) pick_string("shittybill.txt", WHAT)

proc/empty_mouse_params()//TODO MOVE THIS!!!
	.= list()
	.["icon-x"] = 0
	.["icon-y"] = 0
	.["screen-loc"] = 0
	.["left"] = 1
	.["middle"] = 0
	.["right"] = 0
	.["ctrl"] = 0
	.["shift"] = 0
	.["alt"] = 0
	.["drag-cell"] = 0
	.["drop-cell"] = 0
	.["drag"] = 0


/mob/living/carbon/human/proc/auto_interact(var/msg)
	.= 0
	var/list/hudlist = list()

	if (src.client)
		for (var/atom/I in src.hud.inventory_bg)
			if (istype(I,/obj/screen/hud))
				hudlist += I

	for (var/obj/item/I in src.contents)
		if (istype(I,/obj/item/organ) || istype(I,/obj/item/skull) || istype(I,/obj/item/parts)) continue //FUCK
		hudlist += I
		if (istype(I,/obj/item/storage))
			hudlist += I.contents
	hudlist += src.item_abilities

	var/list/close_match = list()
	for (var/atom/I in view(1,src) + hudlist)
		if (!I.mouse_opacity) continue
		if (TWITCH_BOT_INTERACT_BLOCK(I)) continue
		if (istype(I,/obj/item/organ) || istype(I,/obj/item/skull) || istype(I,/obj/item/parts)) continue  //fuck x3
		if ((msg == "airlock" || msg == "door") && istype(I,/obj/machinery/door))
			close_match += I
			continue
		if ((msg == "internals" || msg == "internal" || msg == "o2" || msg == "oxygen" || msg == "air") && istype(I,/obj/ability_button/tank_valve_toggle))
			close_match += I
			continue
		if ((msg == "jetpack" || msg == "jet" || msg == "fly") && istype(I,/obj/ability_button/jetpack_toggle))
			close_match += I
			continue

		if (I.name == msg)
			close_match.len = 0
			close_match += I
			break
		else if (findtext(I.name,msg))
			close_match += I

	if (close_match.len)
		var/atom/picked = pick(close_match)

		var/obj/item/W = src.equipped()
		if (!src.restrained())
			if (istype(picked,/obj/screen/hud))
				var/obj/screen/hud/HUD = picked
				var/list/params = empty_mouse_params()
				HUD.clicked(HUD.id, src, params)
			else if (istype(picked,/obj/ability_button))
				var/obj/ability_button/A = picked
				A.execute_ability()
			else if (istype(picked,/obj/machinery/vehicle))
				var/obj/machinery/vehicle/V = picked
				V.board_pod(src)
			else if (istype(picked,/obj/vehicle))
				var/obj/vehicle/V = picked
				V.MouseDrop_T(src,src)
			else if(W)
				W.attack(picked, src, ran_zone("chest"))
			else
				picked.attack_hand(src)

		.= picked


/mob/living/carbon/human/biker
	real_name = "Shitty Bill"
	gender = MALE
	var/talk_prob = 5
	var/greeted_murray = 0

#ifdef TWITCH_BOT_ALLOWED
	max_health = 250

	/*
	proc/n()
		keys_changed(KEY_FORWARD, KEY_FORWARD)
		SPAWN_DBG(1 DECI SECOND)
			keys_changed(0,0xFFFF)
	proc/s()
		src.process_move(SOUTH)
	proc/e()
		src.process_move(KEY_FORWARD)
	proc/w()
		src.process_move(WEST)
	proc/nw()
		src.process_move(NORTHWEST)
	proc/sw()
		src.process_move(SOUTHWEST)
	proc/ne()
		keys_changed(KEY_FORWARD|KEY_RIGHT, KEY_FORWARD|KEY_RIGHT)
		SPAWN_DBG(1 DECI SECOND)
			keys_changed(0,KEY_FORWARD|KEY_BACKWARD|KEY_RIGHT|KEY_LEFT)
	proc/se()
		src.process_move(SOUTHEAST)
	*/
#endif


	New()
		..()
		shittybills += src
		SPAWN_DBG(0)
			bioHolder.mobAppearance.customization_second = "Tramp"
			bioHolder.age = 62
			bioHolder.bloodType = "A-"
			bioHolder.mobAppearance.gender = "male"
			bioHolder.mobAppearance.underwear = "briefs"
			SPAWN_DBG(1 SECOND)
				bioHolder.mobAppearance.UpdateMob()

			src.equip_new_if_possible(/obj/item/clothing/shoes/brown, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/misc/head_of_security, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/paper/postcard/owlery, slot_l_hand)
			//src.equip_new_if_possible(/obj/item/device/radio/headset/civilian, slot_ears)
			//src.equip_new_if_possible(/obj/item/clothing/suit, slot_wear_suit)
			//src.equip_new_if_possible(/obj/item/clothing/head/biker_cap, slot_head)

			var/obj/item/implant/access/infinite/shittybill/implant = new /obj/item/implant/access/infinite/shittybill(src)
			implant.implanted(src, src)

			var/obj/item/power_stones/G = new /obj/item/power_stones/Gall
			G.set_loc(src)
			src.chest_item = G
			src.chest_item_sewn = 1

	disposing()
		shittybills -= src
		..()

	// Shitty Bill always goes to the afterlife bar unless he has a client
	death(gibbed)
		..(gibbed)

		shittybills -= src

		if (!src.client && src.z != 2)
			var/turf/target_turf = pick(get_area_turfs(/area/afterlife/bar/barspawn))

			var/mob/living/carbon/human/biker/newbody = new()
			newbody.set_loc(target_turf)
			newbody.overlays += image('icons/misc/32x64.dmi',"halo")
			if(inafterlifebar(src))
				qdel(src)
			return
		else
			boutput(src, "<span class='bold notice'>Shitty Bill will try to respawn in roughly 3 minutes.</span>")
			src.become_ghost()
#ifdef TWITCH_BOT_ALLOWED
			src = null


			//FUCK I AM GOOG GOOD GOOD CODER
			SPAWN_DBG(50 SECONDS)
				if (!twitch_mob || !twitch_mob.client)
					for (var/client/C in clients)
						if (C.ckey == TWITCH_BOT_CKEY)
							twitch_mob = C.mob

				if (twitch_mob)
					boutput(twitch_mob, "<span class='bold notice'>Roughly 2 minutes left for respawn.</span>")



			SPAWN_DBG(100 SECONDS)
				if (!twitch_mob || !twitch_mob.client)
					for (var/client/C in clients)
						if (C.ckey == TWITCH_BOT_CKEY)
							twitch_mob = C.mob

				if (twitch_mob)
					boutput(twitch_mob, "<span class='bold notice'>Roughly 1 minute left for respawn.</span>")


			SPAWN_DBG(1500)
				if (!twitch_mob || !twitch_mob.client)
					for (var/client/C in clients)
						if (C.ckey == TWITCH_BOT_CKEY)
							twitch_mob = C.mob

				if (twitch_mob && isdead(twitch_mob))
					var/mob/living/carbon/human/biker/newbody =  = new(pick_landmark(LANDMARK_TWITCHY_BILL_RESPAWN, get_turf(twitch_mob)))

					if (newbody)
						twitch_mob.mind.transfer_to(newbody)
						if (locate(/obj/item/storage/toilet) in newbody.loc)
							newbody.visible_message("<b>[newbody]</b> crawls out of the toilet!")
						else if (locate(/obj/submachine/chef_oven) in newbody.loc)
							newbody.visible_message("<b>[newbody]</b> pops out of the oven!")
#endif

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

#ifdef TWITCH_BOT_ALLOWED
		if (IS_TWITCH_CONTROLLED(src))
			var/list/wins = list()
			wins = splittext(winget(src.client, null, "windows"), ";")
			for(var/x in wins)
				if (!TWITCH_BOT_AUTOCLOSE_BLOCK(x))
					src.Browse(null,"window=[x]")
					//src.Browse(null, "window=[x]")
#endif

		if(!src.stat && !src.client)
			if(target)
				if(isdead(target))
					target = null
				if(get_dist(src, target) > 1)
					step_to(src, target, 1)
				if(get_dist(src, target) <= 1 && !LinkBlocked(src.loc, target.loc))
					var/obj/item/W = src.equipped()
					if (!src.restrained())
						if(W)
							W.attack(target, src, ran_zone("chest"))
						else
							target.attack_hand(src)
			else if(ai_aggressive)
				a_intent = INTENT_HARM
				for(var/mob/M in oview(5, src))
					if(M == src)
						continue
					if(M.type == src.type)
						continue
					if(M.stat)
						continue
					// stop on first human mob
					if(ishuman(M))
						target = M
						break
					target = M
			if(src.canmove && prob(20) && isturf(src.loc))
				step(src, pick(NORTH, SOUTH, EAST, WEST))
			if(prob(2))
				SPAWN_DBG(0) emote(BILL_PICK("emotes"))

			if(prob(talk_prob))
				src.speak()

	proc/speak()
		SPAWN_DBG(0)

			var/obj/machinery/bot/guardbot/old/tourguide/murray = pick(by_type[/obj/machinery/bot/guardbot/old/tourguide])
			if (murray && get_dist(src,murray) > 7)
				murray = null
			if (istype(murray))
				if (!findtext(murray.name, "murray"))
					murray = null

			var/area/A = get_area(src)
			var/list/alive_mobs = list()
			var/list/dead_mobs = list()
			if (A.population && A.population.len)
				for(var/mob/living/M in oview(5,src))
					if(!isdead(M))
						alive_mobs += M
					else
						dead_mobs += M

			if(dead_mobs && dead_mobs.len > 0 && prob(60)) //SpyGuy for undefined var/len (what the heck)
				var/mob/M = pick(dead_mobs)
				say("[BILL_PICK("deadguy")] [M.name]...")
			else if (alive_mobs.len > 0)
				if (murray && !greeted_murray)
					greeted_murray = 1
					say("[BILL_PICK("greetings")] Murray! How's it [BILL_PICK("verbs")]?")
					SPAWN_DBG(rand(20,40))
						if (murray && murray.on && !murray.idle)
							murray.speak("Hi, Bill! It's [BILL_PICK("murraycompliment")] to see you again!")

				else
					var/mob/M = pick(alive_mobs)
					var/speech_type = rand(1,11)

					switch(speech_type)
						if(1)
							say("[BILL_PICK("greetings")] [M.name].")

						if(2)
							say("[BILL_PICK("question")] you lookin' at, [BILL_PICK("insults")]?")

						if(3)
							say("You a [BILL_PICK("people")]?")

						if(4)
							say("[BILL_PICK("rude")], gimme yer [BILL_PICK("item")].")

						if(5)
							say("Got a light, [BILL_PICK("insults")]?")

						if(6)
							say("Nice [BILL_PICK("deadguy")], [BILL_PICK("insults")].")

						if(7)
							say("Got any [BILL_PICK("drugs")]?")

						if(8)
							say("I ever tell you 'bout [BILL_PICK("stories")]?")

						if(9)
							say("You [BILL_PICK("verbs")]?")

						if(10)
							if (prob(50))
								say("Man, I sure miss [BILL_PICK("domiss")].")
							else
								say("Man, I sure don't miss [BILL_PICK("dontmiss")].")

						if(11)
							say("I think my [BILL_PICK("friends")] [BILL_PICK("friendsactions")].")
/* commenting out the bartender stuff because he aint around much. replacing with john bill retorts.
					if (prob(10))
						SPAWN_DBG(4 SECONDS)
							for (var/mob/living/carbon/human/npc/diner_bartender/BT in all_hearers(7, src))
								switch (speech_type)
									if (4)
										BT.say("Look in the machine, you bum.")
									if (7)
										BT.say("You ask that weirdo in the bathroom?")
									if (8)
										if (prob(2))
											BT.say("One of these days, you better. You always talkin' like you're gunna tell some grand story about that, and then you never do[pick("", ", you ass")].")
										else if (prob(6))
											BT.say("Nah, [src].")
										else
											BT.say("Yeah, [src], I remember that one.")
									if (9)
										if (prob(50))
											BT.say("Yeah, sometimes.")
										else
											BT.say("Nah.")
*/

					if (johnbills.len > 0 && prob(25))
						SPAWN_DBG(4 SECONDS)
							var/mob/living/carbon/human/john/MJ = pick(johnbills)
							switch (speech_type)
								if (4)
									MJ.say("You're a big boy now brud, find one yourself.")
								if (7)
									MJ.say("You still on that?")
								if (8)
									if (prob(2))
										MJ.say("Nuh uh, no way no how. You were still in diapers when that happenned- and I'd remember that! [pick("... I think?",".",", Probably...")]")
									else if (prob(6))
										MJ.say("Don't think ya did, [src].")
									else if (prob(50))
										MJ.say("Oh yeah, sure [src], I remember. I do.")
									else
										MJ.say("Sounds a lot like [pick_string("johnbill.txt", "stories")], doesn't it?")
								if (9)
									if (prob(30))
										MJ.say("Only once, in college, and I didn't inhale.")
									else
										MJ.say("Nah, I'd rather [pick_string("johnbill.txt", "verbs")].")
								else
									MJ.speak()


	attackby(obj/item/W, mob/M)
		if (istype(W, /obj/item/paper/tug/invoice))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, "<span class='notice'><b>You show [W] to [src]</b> </span>")
			SPAWN_DBG(1 SECOND)
				say("Hard to believe, but I think my [BILL_PICK("friends")] would be proud to see it.")
			return
		if (istype(W, /obj/item/paper/postcard/owlery))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, "<span class='notice'><b>You show [W] to [src]</b> </span>")
			SPAWN_DBG(1 SECOND)
				say("Yep, can't wait to go on that trip! That [pick_string("johnbill.txt", "insults")] oughta be here soon!")
			return
		if (istype(W, /obj/item/ursium/U))
			say("These things are everywhere. Got anything more exotic?")
			return
		if (istype(W, /obj/item/ursium/antiU))
			var/obj/item/ursium/antiU/aU = W
			boutput(M, "<span class='notice'><b>You show [W] to [src]</b> </span>")
			say("Whoa nelly! Mind if i have a taste?")
			SPAWN_DBG(1 SECOND)
				M.visible_message("<span class='alert'>[src] touches the [W]! Something isnt right! </span>")
				aU:annihilation(2 * aU.ursium)
			return
		..()



	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0)
		if (special) //vamp or ling
			src.target = M
			src.ai_state = 2
			src.ai_threatened = world.timeofday
			src.ai_target = M
			src.a_intent = INTENT_HARM
			src.ai_set_active(1)

		for (var/mob/JB in johnbills)
			var/mob/living/carbon/human/john/J = JB
			if (get_dist(J,src) <= 7)
				if((!J.ai_active) || prob(25))
					J.say("That's my brother, you [pick_string("johnbill.txt", "insults")]!")
				J.target = M
				J.ai_set_active(1)
				J.a_intent = INTENT_HARM


// merchant

/mob/living/carbon/human/merchant
	New()
		..()
		SPAWN_DBG(0)
			src.gender = "male"
			src.real_name = pick("Slick", "Fast", "Frugal", "Thrifty", "Clever", "Shifty") + " " + pick_string_autokey("names/first_male.txt")
			src.equip_new_if_possible(/obj/item/clothing/shoes/black, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/gimmick/merchant, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/suit/merchant, slot_wear_suit)
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, slot_glasses)
			src.equip_new_if_possible(/obj/item/clothing/head/merchant_hat, slot_head)

// myke

/mob/living/carbon/human/myke
	New()
		..()
		SPAWN_DBG(0)
			src.gender = "male"
			src.real_name = "Myke"

			SPAWN_DBG(1 SECOND)
				bioHolder.mobAppearance.UpdateMob()

			src.equip_new_if_possible(/obj/item/clothing/shoes/red, slot_shoes)

			src.equip_new_if_possible(/obj/item/clothing/under/color/lightred, slot_w_uniform)

			src.equip_new_if_possible(/obj/item/clothing/mask/breath, slot_wear_mask)
			src.internal = src.back
	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		src.changeStatus("weakened", 5 SECONDS)
		if(prob(15))
			SPAWN_DBG(0) emote(pick("giggle", "laugh"))
		if(prob(1))
			SPAWN_DBG(0) src.say(pick("You guys wanna hear me play bass?", stutter("HUFFFF"), "I missed my AA meeting to play Left 4 Dead...", "I got my license suspended AGAIN", "I got fired from [pick("McDonald's", "Boston Market", "Wendy's", "Burger King", "Starbucks", "Menard's")]..."))

// waldo

// Where's WAL[DO/LY]???

/mob/living/carbon/human/waldo
	New()
		..()
		SPAWN_DBG(0)
			src.gender = "male"
			src.real_name = "Waldo"

			src.equip_new_if_possible(/obj/item/clothing/shoes/brown, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/gimmick/waldo, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/head/waldohat, slot_head)
			src.equip_new_if_possible(/obj/item/device/radio/headset, slot_ears)
			src.equip_new_if_possible(/obj/item/storage/backpack, slot_back)

/mob/living/carbon/human/fake_waldo
	nodamage = 1
	New()
		..()
		SPAWN_DBG(0)
			src.gender = "male"
			src.bioHolder.mobAppearance.s_tone = pick("#FAD7D0", "#BD8A57", "#935D37")
			src.real_name = "[pick(prob(150); "W", "V")][pick(prob(150); "a", "au", "o", "e")][pick(prob(150); "l", "ll")][pick(prob(150); "d", "t")][pick(prob(150); "o", "oh", "a", "e")]"

			SPAWN_DBG(1 SECOND)
				bioHolder.mobAppearance.UpdateMob()

			var/shoes = text2path("/obj/item/clothing/shoes/" + pick("black","brown","red"))
			src.equip_new_if_possible(shoes, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/gimmick/fake_waldo, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/device/radio/headset, slot_ears)
			src.equip_new_if_possible(/obj/item/storage/backpack, slot_back)
			if(prob(75))
				src.equip_new_if_possible(/obj/item/clothing/head/fake_waldohat, slot_head)
			else if(prob(20))
				src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, slot_glasses)
			walk(src, pick(cardinal), 1)
			sleep(rand(150, 600))
			illusion_expire()
	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		if(prob(33) && canmove && isturf(loc))
			step(src, pick(cardinal))
	proc/illusion_expire(mob/user)
		if(user)
			boutput(user, "<span class='alert'><B>You reach out to attack the Waldo illusion but it explodes into dust, knocking you off your feet!</B></span>")
			user.changeStatus("weakened", 4 SECONDS)
		for(var/mob/M in viewers(src, null))
			if(M.client && M != user)
				M.show_message("<span class='alert'><b>The Waldo illusion explodes into smoke!</b></span>")
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(1, 0, src.loc)
		smoke.start()
		SPAWN_DBG(0)
			qdel(src)
		return
	attack_hand(mob/user)
		return illusion_expire(user)
	attackby(obj/item/W, mob/user)
		return illusion_expire(user)
	MouseDrop(mob/M)
		if(iscarbon(M) && !M.hasStatus("handcuffed"))
			return illusion_expire(M)

/mob/living/carbon/human/don_glab
	real_name = "Donald \"Don\" Glabs"
	gender = MALE

	New()
		..()
		SPAWN_DBG(0)
			bioHolder.age = 44
			bioHolder.bloodType = "Worchestershire"
			bioHolder.mobAppearance.customization_first = "Pompadour"
			bioHolder.mobAppearance.customization_first_color = "#F6D646"
			bioHolder.mobAppearance.gender = "male"
			bioHolder.mobAppearance.underwear = "boxers"
			SPAWN_DBG(1 SECOND)
				bioHolder.mobAppearance.UpdateMob()

			src.equip_new_if_possible(/obj/item/clothing/shoes/orange, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/suit/red, slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses, slot_glasses)
			src.equip_new_if_possible(/obj/item/clothing/head/cowboy, slot_head)

	attackby(obj/item/W, mob/M)
		if (istype(W, /obj/item/paper/postcard/owlery))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, "<span class='notice'><b>You show [W] to [src]</b> </span>")
			SPAWN_DBG(1 SECOND)
				say("Oh yeah sure, I seen it. That ol- how would he say it, [BILL_PICK("insults")]? He won't stop going on and on and on...")
		..()

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0)
		if (special) //vamp or ling
			src.target = M
			src.ai_state = 2
			src.ai_threatened = world.timeofday
			src.ai_target = M

		//Bartender isnt' used right now.
		//Whoever does eventually put him back in the game : Use a global list of bartenders or something. Dont check all_viewers
		//	for (var/mob/living/carbon/human/npc/diner_bartender/BT in all_viewers(7, src))
			//	BT.protect_from(M, src)

/mob/living/carbon/human/tommy
	sound_list_laugh = list('sound/voice/tommy_hahahah.ogg', 'sound/voice/tommy_hahahaha.ogg')
	sound_list_scream = list('sound/voice/tommy_you-are-tearing-me-apart-lisauh.ogg', 'sound/voice/tommy_did-not-hit-hehr.ogg')
	sound_list_flap = list('sound/voice/tommy_weird-chicken-noise.ogg')

	New()
		..()
		SPAWN_DBG(0)
			src.real_name = Create_Tommyname()

			src.gender = "male"
			bioHolder.mobAppearance.customization_first = "Dreadlocks"
			bioHolder.mobAppearance.gender = "male"
			bioHolder.mobAppearance.s_tone = "#FAD7D0"
			bioHolder.AddEffect("accent_tommy")
			SPAWN_DBG(1 SECOND)
				bioHolder.mobAppearance.UpdateMob()

			src.equip_new_if_possible(/obj/item/clothing/shoes/black {cant_drop = 1; cant_other_remove = 1; cant_self_remove = 1} , slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/suit {cant_drop = 1; cant_other_remove = 1; cant_self_remove = 1} , slot_w_uniform)

			src.equip_new_if_possible(/obj/item/device/radio/headset, slot_ears)
			src.equip_new_if_possible(/obj/item/storage/backpack, slot_back)
			src.equip_new_if_possible(/obj/item/football, slot_in_backpack)

/mob/living/carbon/human/waiter
	real_name = "Cade Plids"

	New()
		..()
		SPAWN_DBG(0)
		JobEquipSpawned("Waiter")

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if(prob(1) && !src.stat)
			SPAWN_DBG(0) src.say(pick( "Oh my god!", "No, no, they can't be gone!", "This can't be happening!", "How did I get here?!","Where is everyone else?!"))
		if(prob(1) && !src.stat)
			SPAWN_DBG(0) src.emote(pick("shiver","shudder","blink","sob","faint","pale","twitch","scream"))

/mob/living/carbon/human/secret
	unobservable = 1

/datum/aiHolder/human/yank
	New()
		..()
		var/datum/aiTask/timed/targeted/human/suplex/A = get_instance(/datum/aiTask/timed/targeted/human/suplex, list(src))
		var/datum/aiTask/timed/targeted/human/boxing/B = get_instance(/datum/aiTask/timed/targeted/human/boxing, list(src))
		var/datum/aiTask/timed/targeted/human/get_weapon/C = get_instance(/datum/aiTask/timed/targeted/human/get_weapon, list(src))
		var/datum/aiTask/timed/targeted/human/boxing/D = get_instance(/datum/aiTask/timed/targeted/human/boxing, list(src))
		var/datum/aiTask/timed/targeted/human/flee/F = get_instance(/datum/aiTask/timed/targeted/human/flee, list(src))
		F.transition_task = B
		B.transition_task = C
		C.transition_task = D
		D.transition_task = A
		A.transition_task = F
		default_task = B

// This is Big Yank, one of John Bill's old buds. Yank owes John a favor. He's a Juicer.
/mob/living/carbon/human/big_yank
	gender = MALE
	is_npc = 1
	uses_mobai = 1

	New()
		..()
		SPAWN_DBG(0)
			bioHolder.age = 49
			bioHolder.mobAppearance.customization_first = "Full Beard"
			bioHolder.mobAppearance.customization_first_color = "#555555"
			bioHolder.mobAppearance.gender = "male"
			bioHolder.mobAppearance.underwear = "boxers"
			real_name = "[pick("Chut","Brendt","Franko","Steephe","Geames","Whitney","Thom","Cheddar")] \"Big Yank\" Whitney"
			SPAWN_DBG(1 SECOND)
				bioHolder.mobAppearance.UpdateMob()

			src.equip_new_if_possible(/obj/item/clothing/shoes/orange, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/rank/chief_engineer, slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses, slot_glasses)

			src.ai = new /datum/aiHolder/human/yank(src)
			remove_lifeprocess(/datum/lifeprocess/blindness)
			remove_lifeprocess(/datum/lifeprocess/viruses)
			src.ai.enabled = 0


	attack_hand(mob/M)
		..()
#if ASS_JAM
		src.gib()
#endif
		if(isdead(src))
			return
		if (prob(30))
			say(pick("Hey you better back off [pick_string("johnbill.txt", "insults")]- I'm busy.","You feelin lucky, [pick_string("johnbill.txt", "insults")]?"))
			src.ai.target = null
			src.ai.enabled = 0

	attackby(obj/item/W, mob/M)
		if (istype(W, /obj/item/paper/tug/invoice))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, "<span class='notice'><b>You show [W] to [src]</b> </span>")
			SPAWN_DBG(1 SECOND)
				say(pick("Brudder, I did that job months ago. Fuck outta here with that.","Oh come on, quit wastin my time [pick_string("johnbill.txt", "insults")]."))
			return
		..()

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0)
		if(isdead(src))
			return
		if(prob(20))
			say(pick("Oh no you don't - not today, not ever!","Nice try asshole, but I ain't goin' down so easy!","Gonna take more than that to take out THIS Juicer!","You wanna fuck around bucko? You wanna try your luck?"))
			src.ai.interrupt()
		src.ai.target = M
		src.ai.enabled = 1



#if ASS_JAM //explodey yank
		say("Feel My Wrath.")
		explosion_new(src, src.loc, 20)
		src.gib()
#endif

#undef BILL_PICK
