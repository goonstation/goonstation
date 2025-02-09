// ITS WARC TIME BAYBEE
// f
// Moved these from BBSSS.dm to here because they're global and don't really give that much away (should they be global?)
var/johnbill_shuttle_fartnasium_active = 0
var/fartcount = 0

TYPEINFO(/area/diner/tug)
	valid_bounty_area = FALSE
/area/diner/tug
	icon_state = "green"
	name = "Big Yank's Cheap Tug"
TYPEINFO(/area/diner/juicer_trader)
	valid_bounty_area = FALSE
/area/diner/jucer_trader
	icon_state = "green"
	name = "Placeholder Paul's $STORE_NAME.shuttle"

/obj/item/clothing/head/paper_hat/john
	name = "John Bill's paper bus captain hat"
	desc = "This is made from someone's tax returns"

/obj/item/clothing/mask/cigarette/john
	name = "John Bill's cigarette"
	on = 1
	put_out(var/mob/user as mob, var/message as text)
		// how about we do literally nothing instead?
		// please stop doing the thing you keep doing.

/obj/item/clothing/shoes/thong
	name = "garbage flip-flops"
	icon_state = "thong"
	protective_temperature = 0
	var/possible_names = list("sandals", "flip-flops", "thongs", "rubber slippers", "jandals", "slops", "chanclas")
	var/stapled = FALSE

	examine()
		. = ..()
		if(stapled)
			. += "Two thongs stapled together, to make a MEGA VELOCITY boomerang."
		else
			. += "These cheap [pick(possible_names)] don't even look legal."

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/staple_gun) && !stapled)
			stapled = TRUE
			boutput(user, "You staple the [src] together to create a mighty thongarang.")
			name = "thongarang"
			icon_state = "thongarang"
			throwforce = 0
			throw_range = 10
			throw_return = 1
		else
			..()

	setupProperties()
		..()
		setProperty("coldprot", 0)
		setProperty("heatprot", 0)
		setProperty("conductivity", 1)
		delProperty("chemprot")



ABSTRACT_TYPE(/obj/machinery/vending/meat)
/obj/machinery/vending/meat //MEAT VENDING MACHINE ((parent because we need more than 1 kind))
	name = "ABSTRACT MEAT VENDOR"
	desc = "YOU SHOULD NOT BE SEEING THIS OH NO"
	icon_state = "steak"
	icon_panel = "standard-panel"
	icon_off = "monkey-off"
	icon_broken = "monkey-broken"
	icon_fallen = "monkey-fallen"
	icon_fallen_broken = "monkey-fallen-broken"
	pay = 1
	acceptcard = 1
	slogan_list = list("It's meat you can buy!",
	"Trade your money for meat!",
	"Buy the meat! It's meat!",
	"Why not buy the meat?",
	"Please, please buy meat.")

	light_r = 0.9
	light_g = 0.1
	light_b = 0.1

	create_products(restocked)
		..()

/obj/machinery/vending/meat/prefab_grill
	name = "Meat4cash"
	desc = "An exotic meat vendor."

	create_products(restocked)
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat, 10, cost=PAY_UNTRAINED/4) // 30
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat, 10, cost=PAY_UNTRAINED/5) // 24
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat, 20, cost=PAY_UNTRAINED/6) // 20

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat, 2, cost=PAY_UNTRAINED, hidden=1) // 120

/// This is currently unused as it was intended for use in PR 6684, but it was removed upon request. This might be a temporary removal, so it's staying here.
/obj/machinery/vending/meat/station
	// too much meat trivializes the fine art of monkey butchering, gotta have one with less meat
	name = "FreshFlesh"
	desc = "All of its branding and identification tags have been scratched or peeled off. What the fuck is this?"

	create_products(restocked)
		..()
		// prices here are triple of the prefab_grill version where applicable
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat, 3, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget, 5, cost=PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/fish, 3, cost=PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat, 6, cost=PAY_UNTRAINED/3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat, 3, cost=PAY_UNTRAINED/2)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat, 5, cost=PAY_DOCTORATE, hidden=1)

// all of john's area specific lines here
/area/var/john_talk = null
/area/owlery/owleryhall/john_talk = list("Oh dang, That's me! Wait... Oh dang guys, I think I'm banned from here.","Hope these guys don't mind I stole their bus.","Oh i've seen a scanner like that before. Lotta radiation.","Hey that thing there? Looks important.")
/area/owlery/owleryhall/gangzone/john_talk = list("I don't likesa the looksa these Italians, brud","That's some tough lookin boids- We cool?","Oughta grill a couple of these types. Grill em well done.")
/area/diner/dining/john_talk = list("This place smells a lot like my bro.","This was a good spot to park the bus.","Y'all got a grill in here?","Could do a lot of crimes back there. Probably will.")
/area/diner/bathroom/john_talk = list("I haven't been here in a foggy second!", "I wonder what the fungus on the walls here tastes like... wanna juice it?", "I always wondered what happened to this toilet.")
/area/diner/motel/john_talk = list("Ain't much to look at, but we got the hull for this section pretty cheap!","Uh, don't bother with room 3- it's a little uh... rough.","Mmmm Mmm still smells like salvage.")
/area/diner/motel/observatory/john_talk = list("What a goddamn view.","Never thought I'd have a place like this.")
/area/diner/motel/pool/john_talk = list("Hey brungo, got any water? Like ten to twenty tonnes, eh?","It's a shame I can't swim, on account of the pirate's code.","I've seen this place in a video.")
/area/diner/motel/chemstorage/john_talk = list("Good a time as any to learn chemistry, I guess.","Think I can sell any of this juice?")
/area/lower_arctic/lower/john_talk = list("I ain't a fan of wendibros, they steal my meat.","Chilly eh?")
/area/moon/museum/west/john_talk = list("Got lost here once. More than once. Every time.","You got a map, beardo?","Can we go home yet?")
/area/jones/bar/john_talk = list("When the heck am I gonna get some service here, I'm parched!","What do I gotta start purrin' to get a drink here?","What's the holdup, catscratch? Let's get this party started!")
/area/solarium/john_talk = list("You kids will try anything, wontcha?","Nice sun, dorkus.","So it's a star? Big deal.","I betcha my bus coulda got us here faster, dork.","All righty, now let's grill a steak on that thing!","You bring any snacks?")
/area/marsoutpost/john_talk= list("Things weren't this dry last time I was here.","Really let the place go to the rats didn't they.","Great place for a cookout, if you ask me.")
/area/marsoutpost/duststorm/john_talk= list("Aw fuck, I've seen storms like this before. Where the hell was that planet...","Gehenna awaits.")
/area/sim/racing_entry/john_talk = list("Haha I'm a Nintendo","Beep Boop","Lookit Ma'! I'm in the computer!","Ey cheggit out! Pixels!")
/area/crypt/sigma/mainhall/john_talk = list("Looks a heck a spooky in here","Wonder if there's any meat in that swamp?")
/area/iomoon/base/john_talk = list("Yknow, I think it's almost too hot to grill out there.","This place is a lot shittier than Mars, y'know that?","I didn't really wanna come along you know. I did this for you.")
/area/dojo/john_talk = list("Eyyy, just like my cartoons!","What a sight! Gotta admire the Italians, eh?")
/area/dojo/sakura/john_talk = list("Shoshun mazu, Sake ni ume uru, Nioi kana","Haru moya ya, Keshiki totonou, Tsuki to ume","Hana no kumo, Kane ha Ueno ka, Asakusa ka")
/area/meat_derelict/entry/john_talk = list("Oooh baby now we're talkin! Now we're talkin!","Oh heck yeah now that's my kind of adventure, eh?","Oh boy do I have a good feelin' about this one!")
/area/meat_derelict/main/john_talk = list("Aw yeah dog, this place just gets better and better!","Mmm Mmm! That smells fresh and ready for a grillin'!")
/area/meat_derelict/guts/john_talk = list("And just when I thought it couldnt get better.","Pinch me, I'm dreaming!","Smells good in here, like vinegar!")
/area/meat_derelict/boss/john_talk = list("I'm gonna need a bigger grill.","Fuck that's a big steak!","Oooh mama we are cooked now!")
/area/meat_derelict/soviet/john_talk = list("Betcha these rooskies don't even own a grill","Wonder what these reds are doin in my steak palace?","Ah, gotta debone that before ya cook it.")
/area/bee_trader/john_talk = list("That little Bee, always gettin' inta trouble.","Hey remember that weird puzzle with the showerheads?","What a nasty museum that was, eh? Nasty.")
/area/flock_trader/john_talk = list("Woah, what's with these teal chickens? Must be good grillin'.","I feel like this was revealed to me in a fever dream once.","Dang, that's a mighty fine chair.")
/area/timewarp/ship/john_talk = list("I wonder if my ol' compadre Murray is around.","Did ya see those clocks outside? Time just flies by.","I swear I saw a ship just like this years ago, but somewhere else.","Didn't they use to haul some strange stuff on these gals?")
/area/derelict_ai_sat/core/john_talk = list("Hello, Daddy.","You should probably start writing down the shit I say, I certainly can't remember any of it.")
/area/adventure/urs_dungeon/john_talk = list("This place smells like my bro.","Huh, Always wondered what those goggles did.","Huh, Always wondered what those goggles did.","Your hubris will be punished. Will you kill your fellow man to save yourself? Who harvests the harvestmen? What did it feel like when you lost your mind?")
/area/grillnasium/grill_chamber/john_talk = list("You better know what you've started.","This is where it happens.")



// bus driver
/mob/living/carbon/human/john
	real_name = "John Bill"
#ifdef IN_MAP_EDITOR
	icon = 'icons/mob/map_mob.dmi'
	icon_state = "john_bill"
#endif
	interesting = "Found in a coffee can at age fifteen. Went to jail for fraud. Recently returned to the can."
	gender = MALE
	is_npc = TRUE
	var/talk_prob = 7
	var/greeted_murray = 0
	var/list/snacks = null
	var/gotsmokes = 0
	var/nude = 0

	nude
		nude = 1

	New()
		..()
		START_TRACKING_CAT(TR_CAT_JOHNBILLS)
		if(nude)
			return
		src.equip_new_if_possible(/obj/item/clothing/shoes/thong, SLOT_SHOES)
		src.equip_new_if_possible(/obj/item/clothing/under/color/orange, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/mask/cigarette/john, SLOT_WEAR_MASK)
		src.equip_new_if_possible(/obj/item/clothing/suit/labcoat, SLOT_WEAR_SUIT)
		src.equip_new_if_possible(/obj/item/clothing/head/paper_hat/john, SLOT_HEAD)

		new /obj/item/implant/access/infinite/shittybill(src)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_JOHNBILLS)
		..()

	initializeBioholder()
		bioHolder.mobAppearance.customizations["hair_bottom"].style =  new /datum/customization_style/hair/gimmick/shitty_beard
		bioHolder.mobAppearance.customizations["hair_bottom"].color = "#281400"
		bioHolder.mobAppearance.customizations["hair_middle"].style =  new /datum/customization_style/hair/short/pomp
		bioHolder.mobAppearance.customizations["hair_middle"].color = "#241200"
		bioHolder.mobAppearance.customizations["hair_top"].style =  new /datum/customization_style/hair/gimmick/shitty_beard_stains
		bioHolder.mobAppearance.customizations["hair_top"].color = "#663300"
		bioHolder.age = 63
		bioHolder.bloodType = "A+"
		bioHolder.mobAppearance.gender = "male"
		bioHolder.mobAppearance.underwear = "briefs"
		bioHolder.mobAppearance.u_color = "#996633"
		. = ..()

	// John Bill always goes to the afterlife bar.
	death(gibbed)
		..(gibbed)

		STOP_TRACKING_CAT(TR_CAT_JOHNBILLS)

		if (!src.client)
			var/turf/target_turf = pick(get_area_turfs(/area/afterlife/bar/barspawn))

			var/mob/living/carbon/human/john/newbody = new()
			newbody.set_loc(target_turf)
			newbody.setStatus("in_afterlife", INFINITE_STATUS, newbody)
			if(inafterlifebar(src))
				qdel(src)
			return
		else
			boutput(src, "<span class='bold notice'>Haha you died loser.</span>")
			src.become_ghost()

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		if(!src.stat && !src.client)
			if(target)
				if(isdead(target))
					target = null
				if(BOUNDS_DIST(src, target) > 0)
					step_to(src, target, 1)
				if(BOUNDS_DIST(src, target) == 0 && !LinkBlocked(src.loc, target.loc))
					var/obj/item/W = src.equipped()
					if (!src.restrained())
						if(W)
							W.attack(target, src, ran_zone("chest"))
						else
							target.Attackhand(src)
			else if(ai_aggressive)
				set_a_intent(INTENT_HARM)
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
			if(prob(20) && src.canmove && isturf(src.loc))
				step(src, pick(NORTH, SOUTH, EAST, WEST))
			if(prob(2))
				SPAWN(0) emote(JOHN_PICK("emotes"))
			if(prob(15))
				snacktime()
			var/area/A = get_area(src)
			if(prob(talk_prob) || A?.john_talk)
				src.speak()

	proc/snacktime()
		snacks = list()
		for(var/obj/item/reagent_containers/food/snacks/S in src)
			snacks += S
		if(length(snacks) > 0)
			var/obj/item/reagent_containers/food/snacks/snacc = pick(snacks)
			if(istype(snacc, /obj/item/reagent_containers/food/snacks/bite))
				if(prob(75))
					return
				else
					src.visible_message(SPAN_ALERT("[src] horks up a lump from his stomach... "))
			snacc.Eat(src,src,1)

	proc/pacify()
		src.set_a_intent(INTENT_HELP)
		src.target = null
		src.ai_set_state(AI_PASSIVE)
		src.ai_target = null

	proc/speak()
		if(nude)
			return // nude john is for looking at, not listening to.
		SPAWN(0)
			var/list/grills = list()

			var/obj/machinery/bot/guardbot/old/tourguide/murray = pick(by_type[/obj/machinery/bot/guardbot/old/tourguide])
			if (murray && GET_DIST(src,murray) > 7)
				murray = null
			if (istype(murray))
				if (!findtext(murray.name, "murraycompliment"))
					murray = null

			var/area/A = get_area(src)
			var/list/alive_mobs = list()
			var/list/dead_mobs = list()
			if (A && A.population && length(A.population))
				for(var/mob/living/M in oview(5,src))
					if(!isdead(M))
						alive_mobs += M
					else
						dead_mobs += M

			if (prob(20))
				for(var/obj/machinery/shitty_grill/G in orange(5, src))
					grills.Add(G)

			if (A.john_talk && prob(90))
				SPAWN(5 SECONDS)
					var/area/john_area = get_area(src)
					say(pick(john_area.john_talk))
					john_area.john_talk = null

			else if (length(grills) > 0)
				var/obj/machinery/shitty_grill/G = pick(grills)
				if (G.grillitem)
					switch(G.cooktime)
						if (0 to 15)
							say("Yep, \the [G.grillitem] needs a little more time.")
						if (16 to 49)
							say("[JOHN_PICK("rude")], [JOHN_PICK("grilladvice")] [G.grillitem].")
						if (50 to 59)
							say("Whoa! \The [G.grillitem] is cooked to perfection! Lemme get that for ya!")
							G.eject_food()
						else
							say("Good fuckin' job [JOHN_PICK("insults")], you burnt it.")
				else
					if (G.grilltemp >= 200 + T0C)
						if(prob(70))
							say("That there ol' [G] looks about ready for a [JOHN_PICK("drugs")]-seasoned steak!")
						else
							say("That [G] is hot! Who's grillin' ?")
					else
						say("Anyone gonna fire up \the [G]?")

			else if(prob(40) && length(dead_mobs))
				var/mob/M = pick(dead_mobs)
				say("[JOHN_PICK("deadguy")] [M.name]...")
			else if (length(alive_mobs) > 0)
				if (murray && !greeted_murray)
					greeted_murray = 1
					say("[JOHN_PICK("greetings")] Murray! How's it [JOHN_PICK("verbs")]?")
					SPAWN(rand(20,40))
						if (murray?.on && !murray.idle)
							murray.say("Hi, John! It's [JOHN_PICK("murraycompliment")] to see you here, of all places.")

				else
					var/mob/M = pick(alive_mobs)
					var/speech_type = rand(1,11)

					switch(speech_type)
						if(1)
							say("[JOHN_PICK("greetings")] [M.name].")
							M.add_karma(2)

						if(2)
							say("[JOHN_PICK("question")] you lookin' at, [JOHN_PICK("insults")]?")

						if(3)
							say("You a [JOHN_PICK("people")]?")

						if(4)
							say("[JOHN_PICK("rude")], gimme yer [JOHN_PICK("item")].")

						if(5)
							say("Got a light, [JOHN_PICK("insults")]?")

						if(6)
							say("Nice [JOHN_PICK("nouns")], [JOHN_PICK("insults")].")

						if(7)
							say("Got any [JOHN_PICK("drugs")]?")

						if(8)
							say("I ever tell you 'bout [JOHN_PICK("stories")]?")

						if(9)
							say("You [JOHN_PICK("verbs")]?")

						if(10)
							if (prob(50))
								say("Man, I sure miss [JOHN_PICK("domiss")].")
							else
								say("Man, I sure don't miss [JOHN_PICK("dontmiss")].")

						if(11)
							say("I think my [JOHN_PICK("friends")] [JOHN_PICK("friendsactions")].")

					if (prob(25) && length(by_cat[TR_CAT_SHITTYBILLS]))
						SPAWN(3.5 SECONDS)
							var/mob/living/carbon/human/biker/MB = pick(by_cat[TR_CAT_SHITTYBILLS])
							switch (speech_type)
								if (4)
									MB.say("You borrowed mine fifty years ago, and I never got it back.")
								if (7)
									MB.say("If I had any, I wouldn't share it with ya [pick_string("shittybill.txt", "insults")].")
								if (8)
									if (prob(2))
										MB.say("One of these days, you oughta. I don't believe it for a second but let's hear it, [pick_string("shittybill.txt", "people")].")
									else if (prob(6))
										MB.say("No way, [src].")
									else
										MB.say("Yeah, [src], you told me that one before.")
								if (9)
									if (prob(50))
										MB.say("Yeah, sometimes.")
									else
										MB.say("No way.")
								else
									MB.speak()



	attackby(obj/item/W, mob/M)
		if (istype(W, /obj/item/paper/tug/invoice))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, SPAN_NOTICE("<b>You show [W] to [src]</b> "))
			SPAWN(1 SECOND)
				say("One of them [JOHN_PICK("people")] folks from the station helped us raise the cash. Lil bro been dreamin bout it fer years.")
			return
		#ifdef SECRETS_ENABLED
		if (istype(W, /obj/item/paper/grillnasium/fartnasium_recruitment))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, SPAN_NOTICE("<b>You show [W] to [src]</b> "))
			SPAWN(1 SECOND)
				say("Well hot dog! [JOHN_PICK("insults")], you wouldn't believe it but I use to work there!")
				johnbill_shuttle_fartnasium_active = 1
				sleep(2 SECONDS)
				say("Yer dag right we can go Juicin around in there! Pack yer shit we're doin a B&E ! ! ! ")
				emote("dance")
			return
		#endif
		if (istype(W, /obj/item/reagent_containers/food/snacks) || (istype(W, /obj/item/clothing/mask/cigarette/cigarillo) && !gotsmokes))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, SPAN_NOTICE("<b>You offer [W] to [src]</b> "))
			M.u_equip(W)
			W.set_loc(src)
			W.dropped(M)
			src.drop_item()
			src.put_in_hand_or_drop(W)

			SPAWN(1 DECI SECOND)
				say("Oh? [W] eh?")
				say(pick("No kiddin' fer me?","I guess I could go fer a quick one yeah!","Oh dang dang dang! Haven't had one of these babies in a while!","Well I never get tired of those!","You're offering this to me? Don't mind if i do, [JOHN_PICK("people")]"))
				pacify()

				if (istype(W, /obj/item/clothing/mask/cigarette/cigarillo/juicer))
					gotsmokes = 1
					sleep(3 SECONDS)
					say(pick("Listen bud, I don't know who sold you these, but they ain't your pal.","Y'know these ain't legal in any NT facilities, right?","Maybe you ain't so dumb as ya look, brud."))
					var/obj/item/clothing/mask/cigarette/cigarillo/juicer/J = W
					src.u_equip(wear_mask)
					src.equip_if_possible(J, SLOT_WEAR_MASK)
					J.cant_other_remove = 0
					sleep(3 SECONDS)
					J.light(src, SPAN_ALERT("<b>[src]</b> casually lights [J] and takes a long draw."))
					sleep(5 SECONDS)
#if BUILD_TIME_DAY >= 28 // this block controls whether or not it is the right time to smoke a fat doink with Big J
					say("You know a little more than you let on, don't you?")
					sleep(7 SECONDS)
					say("See but I been away long enough that I don't know much about you.")
					emote("cough")
					sleep(15 SECONDS)
					particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(src.loc, src.dir))
					say("Other than you 'trasies really did me and my bro a solid, back when there was that whole business with the bee n' all that. A real solid. But by now you're wonderin' why we were involved with her anyhow.")
					sleep(7 SECONDS)
					say("All in due time.")
					emote("cough")
					sleep(9 SECONDS)
					J.put_out(src, "<b>[src]</b> distractedly drops and treads on the lit [J.name], putting it out instantly.")
					src.u_equip(J)
					J.set_loc(src.loc)
					sleep(2 SECONDS)
					say("These just don't taste the same without him...")
#else // it is not time
					say(pick("This ain't the time, but we should have a talk. A long talk.","Under better circumstances, I'd like to smoke a few of these and reminesce with ya.","We'll have to do this again some time. When the time is right."))
#endif
					gotsmokes = 0

				else if(istype(W, /obj/item/clothing/mask/cigarette))
					say(pick("Well this ain't my usual brand, but...", "Oh actually, got any... uh nah you've probably never even seen one of those.","Wait a second, this ain't a real 'Rillo."))
					var/obj/item/clothing/mask/cigarette/cig = W
					src.u_equip(wear_mask)
					src.equip_if_possible(cig, SLOT_WEAR_MASK)
					sleep(3 SECONDS)
					cig.light(src, SPAN_ALERT("<b>[src]</b> cautiously lights [cig] and takes a short draw."))
					sleep(5 SECONDS)
					say(pick("Yeah that's ol' Dan's stuff...","But hey, thanks for the smokes, bruddo.","Smooth. Too smooth."))
			return
		..()

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		. = ..()
		if (special) //vamp or ling
			src.target = M
			src.ai_set_state(AI_ATTACKING)
			src.ai_threatened = world.timeofday
			src.ai_target = M
			src.set_a_intent(INTENT_HARM)
			src.ai_set_active(1)

		for (var/mob/SB in by_cat[TR_CAT_SHITTYBILLS])
			var/mob/living/carbon/human/biker/S = SB
			if (GET_DIST(S,src) <= 7)
				if(!(S.ai_active) || (prob(25)))
					S.say("That's my brother, you [JOHN_PICK("insults")]!")
					M.add_karma(-1)
				S.target = M
				S.ai_set_active(1)
				S.set_a_intent(INTENT_HARM)





/obj/fakeobject/thrust
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	name = "ionized exhaust"
	desc = "Thankfully harmless, to registered employees anyway."

/obj/fakeobject/thrust/flames
	icon_state = "engineshit"
/obj/fakeobject/thrust/flames2
	icon_state = "engineshit2"

/obj/item/paper/tug/invoice
	name = "Big Yank's Space Tugs, Limited."
	desc = "Looks like a bill of sale."
	info = {"<b>Client:</b> Bill, John
			<br><b>Date:</b> TBD
			<br><b>Articles:</b> Structure, Static. Pressurized. Single.
			<br><b>Destination:</b> \"where there's rocks at\"\[sic\]
			<br>
			<br><b>Total Charge:</b> 17,440 paid in full with value-added meat.
			<br>Big Yank's Cheap Tug"}

/obj/item/paper/tug/warehouse
	name = "Big Yank's Space Tugs, Limited."
	desc = "Looks like a bill of sale. It is blank"
	info = {"<b>Client:</b>
			<br><b>Date:</b>
			<br><b>Articles:</b>
			<br><b>Duration:</b>
			<br>
			<br><b>Total Charge:</b>
			<br>Big Yank's Stash N Dash"}

/obj/item/paper/horizon/HTSL
	name = "crumpled note"
	interesting = "The carbon dating of the cellulose within the paper is not consistent."
	info = {"NSS Horizon Technical Service Log
			<br>Commission date 22 June 2047
			<br>Printing Shakedown Notes:
			<br>
			<br>With regards to the Horizon-class Hypercarrier, the following concerns were identified and addressed:
			<br>
			<br>Concern: Due to budgetary concerns, \[REDACTED] and mitigation efforts resulting unusual thermal flux, drastically increasing the odds of a runaway thermal \[REDACTED]
			<br>
			<br>Remedy: The NSS Horizon will not house critical Nanotrasen staff.
			<br>
			<br>Concern: Thermal cladding is both grossly insufficient and visibly in very poor repair, further exacerbating \[REDACTED] into a runaway thermal event, of possible \[REDACTED] and further collateral damage.
			<br>
			<br>Remedy: Cladding repainted; damaged cladding is no longer visible and will not affect employee morale
			<br>
			<br>Concern: Artificial Intelligence Core grossly insufficient for intra-\[REDACTED] navigation, sublight control necessary for all course changes.
			<br>
			<br>Remedy: A.I.C. relegated to door control and entertainment services.
			<br
			><br>Concern: Hull integrity tests inconclusive, all data lost when hull-mounted sensors were lost in testing breach. See personnel logs for subsequent staff rotation.
			<br>
			<br>No remedy suggested.
			<br>
			<br><span style='font-family: Dancing Script, cursive;'>You'd think they would have made this file easier to access, at least to the assholes refitting it. Stranded for six years, moored by failing engines, we've made do, but there's not much more we can do here. I've converted most of the Horizon Project bolt-ons to more civil amenities, got the port engine running well enough to keep life support on, but nearly everyone left here is either a grifter or a prisonner.
			<br>Never would have signed up for that mission if I knew what they were actually trying to do. Assholes.
			<br>
			<br>Got a call this morning that NT wants to recomission this heap of shit, as a research outpost. I spend six fucking years sending distress calls, and by 1800 hours, there's going to be a shuttle full of bright-faced convicts ready to make the Kuiper Belt teem with greed again. I'm sorry, but its a step too far. I won't be here to greet them.
			<br>
			<br>February 3rd, 2053</span>"}

/obj/item/paper/horizon/eggs
	name = "eggs"
	desc = "eggs"
	info = "legs"

/turf/simulated/wall/r_wall/afterbar
	name = "wall"
	desc = null
	attackby(obj/item/W, mob/user, params)
		return


/*
Urs' Hauntdog critter
*/
/obj/critter/hauntdog
	name = "hauntdog"
	desc = "A very, <i>very</i> haunted hotdog. Hopping around. Hopdog."
	icon = 'icons/misc/hauntdog.dmi'
	icon_state = "hauntdog"
	death_text = null
	health = 30
	density = 0

	patrol_step()
		if (!mobile)
			return
		var/turf/moveto = locate(src.x + rand(-1,1),src.y + rand(-1, 1),src.z)

		if(isturf(moveto) && !moveto.density)
			flick("hauntdog-hop",src)
			step_towards(src, moveto)
		if(src.aggressive) seek_target()
		steps += 1
		if (steps == rand(5,20)) src.task = "thinking"

	ai_think()
		if(prob(5))
			flip()
		..()

	proc/flip()
		src.visible_message("<b>[src]</b> does a flip!")
		flick("hauntdog-flip",src)
		sleep(1.3 SECONDS)

	CritterDeath()
		if (!src.alive) return
		..()
		src.visible_message("<b>[src]</b> stops moving.")
		var/obj/item/reagent_containers/food/snacks/hotdog/H = new /obj/item/reagent_containers/food/snacks/hotdog(get_turf(src))

		H.bun = 5
		H.desc = "A very haunted hotdog. A hauntdog, perhaps."
		H.heal_amt += 1
		H.name = "ordinary hauntdog"
		H.food_effects = list("food_all","food_brute")
		if (H.reagents)
			H.reagents.add_reagent("ectoplasm", 10)
		H.UpdateIcon()

		qdel(src)

/mob/living/critter/small_animal/pig/hogg
	name = "hogg vorbis"
	real_name = "hogg vorbis"
	desc = "the hogg vorbis."
	icon_state = "hogg"
	icon_state_dead = "hogg-dead"
	speech_verb_say = "screams!"
	speech_verb_exclaim = "screams!"

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		if(act == "scream" && src.emote_check(voluntary, 50))
			var/turf/T = get_turf(src)
			var/hogg = pick('sound/voice/hagg_vorbis.ogg','sound/voice/hogg_vorbis.ogg','sound/voice/hogg_vorbis_the.ogg','sound/voice/hogg_vorbis_screams.ogg','sound/voice/hogg_with_scream.ogg','sound/voice/hoooagh2.ogg','sound/voice/hoooagh.ogg',)
			playsound(T, hogg, 60, TRUE, channel=VOLUME_CHANNEL_EMOTE)
			return SPAN_EMOTE("<b>[src]</b> screeeams!")
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	on_pet(mob/user)
		if (..())
			return 1
		if (prob(25))
			var/turf/T = get_turf(src)
			src.visible_message("[src] screams![prob(5) ? " ...uh?" : null]",\
			"You screams!")
			var/hogg = pick('sound/voice/hagg_vorbis.ogg','sound/voice/hogg_vorbis.ogg','sound/voice/hogg_vorbis_the.ogg','sound/voice/hogg_vorbis_screams.ogg','sound/voice/hogg_with_scream.ogg','sound/voice/hoooagh2.ogg','sound/voice/hoooagh.ogg',)
			playsound(T, hogg, 60, TRUE)
			user.add_karma(1.5)

// ########################
// # Horizon  audio  logs #
// ########################

/obj/item/device/audio_log/horizon_minorcollision
	continuous = 0
	audiolog_messages = list("Course stady, bearing One One Zero Mark Two,",
							"Firing thrusters.",
							"Steady hot stuff. Keep your eyes on the grav- wait a second.",
							"Uh, Captain- I- I don't-",
							"Shuttlecraft One to NSS Horizon abort maneuver! ABORT MANEUVER WE ARE NOT CLEA-",
							"*Thunderous scraping, metallic sound*",
							"Negative, Captain. Engines offline, there's some kind of well between *click*",
							"What. the fuck is that. *Creaking, static*")
	audiolog_speakers = list("Female voice",
							"Juvenile voice",
							"Female voice",
							"Juvenile voice",
							"Female voice",
							"???",
							"NSS Horizon",
							"???")


/mob/living/carbon/human/geneticist
	is_npc = 1
	uses_mobai = 1
	real_name = "Juicer Gene"
	max_health = 50

	New()
		..()
		src.ai = new /datum/aiHolder/human/geneticist(src)
		src.equip_new_if_possible(/obj/item/clothing/shoes/dress_shoes, SLOT_SHOES)
		src.equip_new_if_possible(/obj/item/clothing/under/rank/geneticist, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/suit/labcoat/pathology, SLOT_WEAR_SUIT)
		if(prob(50))
			src.equip_new_if_possible(/obj/item/clothing/glasses/regular, SLOT_GLASSES)
