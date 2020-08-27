
var/global/list/persistent_bank_purchaseables =	list(\
	new /datum/bank_purchaseable/human_item/crayon,\
	new /datum/bank_purchaseable/human_item/paint_rainbow,\
	new /datum/bank_purchaseable/human_item/paint_plaid,\
	new /datum/bank_purchaseable/human_item/stickers,\
	new /datum/bank_purchaseable/human_item/bee_egg,\
	new /datum/bank_purchaseable/human_item/harmonica,\
	new /datum/bank_purchaseable/human_item/airhorn,\
	new /datum/bank_purchaseable/human_item/dramatichorn,\
	new /datum/bank_purchaseable/human_item/saxophone,\
	new /datum/bank_purchaseable/human_item/trumpet,\
	new /datum/bank_purchaseable/human_item/fiddle,\
	new /datum/bank_purchaseable/human_item/gold_zippo,\
	new /datum/bank_purchaseable/human_item/toy_sword,\
	new /datum/bank_purchaseable/human_item/sound_synth,\
	new /datum/bank_purchaseable/human_item/food_synth,\
	new /datum/bank_purchaseable/human_item/record,\
	new /datum/bank_purchaseable/human_item/sparkler_box,\
	new /datum/bank_purchaseable/human_item/dabbing_license,\
	new /datum/bank_purchaseable/human_item/chem_hint,\

	new /datum/bank_purchaseable/altjumpsuit,\
	new /datum/bank_purchaseable/altclown,\
	new /datum/bank_purchaseable/bp_fjallraven,\
	new /datum/bank_purchaseable/bp_randoseru,\
	new /datum/bank_purchaseable/bp_anello,\
	new /datum/bank_purchaseable/nt_backpack,\
	new /datum/bank_purchaseable/lizard,\
	new /datum/bank_purchaseable/cow,\
	new /datum/bank_purchaseable/skeleton,\
	new /datum/bank_purchaseable/roach,\
	new /datum/bank_purchaseable/limbless,\
	new /datum/bank_purchaseable/corpse,\
	new /datum/bank_purchaseable/space_diner,\
	new /datum/bank_purchaseable/mail_order,\
	new /datum/bank_purchaseable/lunchbox,\

	new /datum/bank_purchaseable/critter_respawn,\
	new /datum/bank_purchaseable/golden_ghost,\

	new /datum/bank_purchaseable/fruithat,\
	new /datum/bank_purchaseable/hoodie,\
	new /datum/bank_purchaseable/pride_o_matic,\
	new /datum/bank_purchaseable/fake_waldo,\
	new /datum/bank_purchaseable/moustache,\
	new /datum/bank_purchaseable/gold_that,\
	new /datum/bank_purchaseable/dancin_shoes,\

	new /datum/bank_purchaseable/alohamaton,\
	new /datum/bank_purchaseable/ai_hat)


/datum/bank_purchaseable
	var/name = "a thing u can buy"
	var/cost = 0
	var/atom/path = null //Object to spawn. If null, spawn nothing
	var/carries_over = 1

	var/list/required_levels = list() //Associated List of JOB:REQUIRED LEVEL ("Clown"=999) etc. Optional jobxp requirements for this.

	//Return 1 for successful purchase.
	//	All children that need to spawn an item should have a call to this base
	proc/Create(var/mob/living/M)
		var/equip_success = 0
		if (!path)
			return equip_success
		if (ishuman(M)) // yeah, just do the same exact thing as with trinkets. Maybe this 'put item in any open slot' thing should be its own proc?
			var/mob/living/carbon/human/H = M
			equip_success = 1
			var/obj/I = new path(H.loc)
			I.name = "[H.real_name][pick_string("trinkets.txt", "modifiers")] [I.name]"
			I.quality = rand(5,80)
			var/equipped = 0
			if (istype(H.back, /obj/item/storage) && H.equip_if_possible(I, H.slot_in_backpack))
				equipped = 1
			else if (istype(H.belt, /obj/item/storage) && H.equip_if_possible(I, H.slot_in_belt))
				equipped = 1
			if (!equipped)
				if (!H.l_store && H.equip_if_possible(I, H.slot_l_store))
					equipped = 1
				else if (!H.r_store && H.equip_if_possible(I, H.slot_r_store))
					equipped = 1
				else if (!H.l_hand && H.equip_if_possible(I, H.slot_l_hand))
					equipped = 1
				else if (!H.r_hand && H.equip_if_possible(I, H.slot_r_hand))
					equipped = 1

				if (!equipped)
					I.set_loc(get_turf(src))

		if (isrobot(M)) //Assuming the cyborg spawns naked. otherwise we would do all these funky checks for equipped clothing and replacing them etc... who cares!!!
			var/mob/living/silicon/robot/R = M
			if (ispath(path, /obj/item/clothing))
				if(ispath(path,/obj/item/clothing/under))
					var/obj/O = new path(R.loc)
					R.clothes["under"] = O
					O.set_loc(R)
					equip_success = 1
				else if(ispath(path,/obj/item/clothing/suit))
					var/obj/O = new path(R.loc)
					R.clothes["suit"] = O
					O.set_loc(R)
					equip_success = 1
				else if(ispath(path,/obj/item/clothing/mask))
					var/obj/O = new path(R.loc)
					R.clothes["mask"] = O
					O.set_loc(R)
					equip_success = 1
				else if(ispath(path,/obj/item/clothing/head))
					var/obj/O = new path(R.loc)
					R.clothes["head"] = O
					O.set_loc(R)
					equip_success = 1
				if(equip_success)
					R.update_appearance()

		if(isAI(M))
			var/mob/living/silicon/ai/AI = M
			if (ispath(path, /obj/item/clothing))
				if(ispath(path,/obj/item/clothing/head))
					AI.set_hat(new path(AI))
					equip_success = 1



		//The AI can't really wear items...
		//Maybe use this space later to give the AI critter pets or spawn objects inside the AI core?

		return equip_success

	proc/hasJobXP(var/key)
		var/pass = 1
		for(var/X in required_levels)
			var/level = get_level(key, X)
			if(level < required_levels[X])
				pass = 0
		return pass

	nothing
		name = "Nothing"
		cost = 0

		Create(var/mob/living/M)
			return 1

	///////////////////////
	//HUMAN PURCHASEABLES//
	///////////////////////

	human_item

		Create(var/mob/living/M)
			if (!ishuman(M))
				return 0
			return ..()

		crayon
			name = "Crayon"
			cost = 50
			path = /obj/item/pen/crayon/random

		paint_rainbow
			name = "Rainbow Paint Can"
			cost = 1500
			path = /obj/item/paint_can/rainbow

		paint_plaid
			name = "Plaid Paint Can"
			cost = 3000
			path = /obj/item/paint_can/rainbow/plaid

		stickers
			name = "Sticker Box"
			cost = 300
			path = /obj/item/item_box/assorted/stickers/stickers_limited

		bee_egg
			name = "Bee Egg"
			cost = 550
			path = /obj/item/reagent_containers/food/snacks/ingredient/egg/bee

		harmonica
			name = "Harmonica"
			cost = 150
			path = /obj/item/instrument/harmonica

		airhorn
			name = "Air Horn"
			cost = 800
			path = /obj/item/instrument/bikehorn/airhorn

		dramatichorn
			name = "Dramatic Horn"
			cost = 400
			path = /obj/item/instrument/bikehorn/dramatic

		saxophone
			name = "Saxophone"
			cost = 600
			path = /obj/item/instrument/saxophone

		trumpet
			name = "Trumpet"
			cost = 700
			path = /obj/item/instrument/trumpet

		fiddle
			name = "Fiddle"
			cost = 700
			path = /obj/item/instrument/fiddle

		gold_zippo
			name = "Gold Zippo"
			cost = 500
			path = /obj/item/device/light/zippo/gold

		toy_sword
			name = "Toy Sword"
			cost = 900
			path = /obj/item/toy/sword

		sound_synth
			name = "Sound Synthesizer"
			cost = 14000
			path = /obj/item/noisemaker

		food_synth
			name = "Food Synthesizer"
			cost = 8000
			path = /obj/item/robot_foodsynthesizer

		record
			name = "Record"
			cost = 2000
			path = /obj/item/record/spacebux

		sparkler_box
			name = "Sparkler Box"
			cost = 1000
			path = /obj/item/storage/sparkler_box

		dabbing_license
			name = "Dabbing License"
			cost = 4200
			path = /obj/item/card/id/dabbing_license

		battlepass
			name = "Battle Pass"
			cost = 1000
			path = /obj/item/battlepass

			Create(var/mob/living/M)
				..(M)
				if(M && M.mind)
					battle_pass_holders.Add(M.mind)
				return 1

		chem_hint
			name = "Secret chem hint"
			cost = 3500
			path = /obj/item/chem_hint
			carries_over = 0



	altjumpsuit
		name = "Alternate Jumpsuit"
		cost = 1500

		Create(var/mob/living/M)
			var/succ = 0
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				/*if (H.head && istype(H.head, /obj/item/clothing/head))
					var/path = text2path("[H.head.type]/april_fools")
					if (ispath(path))
						M.u_equip(H.head)
						qdel(H.head)
						var/obj/item/clothing/head/hatt = new path
						H.force_equip(hatt)
						succ = 1*/


				if (H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under/rank))
					if (ispath(text2path("[H.w_uniform.type]/april_fools")))
						H.w_uniform.icon_state = "[H.w_uniform.icon_state]-alt"
						H.w_uniform.item_state = "[H.w_uniform.item_state]-alt"
						succ = 1

				if (H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit))
					if (ispath(text2path("[H.wear_suit.type]/april_fools")))
						H.wear_suit.icon_state = "[H.wear_suit.icon_state]-alt"
						H.wear_suit.item_state = "[H.wear_suit.item_state]-alt"
						if (istype(H.wear_suit, /obj/item/clothing/suit/labcoat))
							H.wear_suit:coat_style = "[H.wear_suit:coat_style]-alt"
						succ = 1

			return succ

	altclown
		name = "Alternate Clown Outfit"
		cost = 200

		Create(var/mob/living/M)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.mind)
					if (H.mind.assigned_role == "Clown")
						var/type = pick("purple","pink","yellow")
						H.w_uniform.icon = 'icons/obj/clothing/uniforms/item_js_gimmick.dmi'
						H.w_uniform.wear_image_icon = 'icons/mob/jumpsuits/worn_js_gimmick.dmi'
						H.w_uniform.icon_state = "[type]clown"
						H.w_uniform.item_state = "[type]clown"
						H.w_uniform.name = "[type] clown suit"
						H.wear_mask.icon_state = "[type]clown"
						H.wear_mask.item_state = "[type]clown"
						H.wear_mask.name = "[type] clown mask"
						H.shoes.icon_state = "[type]clown"
						H.shoes.item_state = "[type]clown"
						H.shoes.name = "[type] clown shoes"
						H.shoes.desc = "Normal clown shoes, just [type] instead of red."
						if (type == "purple")
							H.w_uniform.desc = "What kind of clown are you for wearing this color? It's a good question, honk."
							H.wear_mask.desc = "Purple is a very flattering color on almost everyone."
						if (type == "pink")
							H.w_uniform.desc = "The color pink is the embodiment of love and hugs and nice people. Honk."
							H.wear_mask.desc = "This reminds you of cotton candy."
						if (type == "yellow")
							H.w_uniform.desc = "Have a happy honk!"
							H.wear_mask.desc = "A ray of sunshine."
						return 1
				return 0

			return 0

	lizard
		name = "Reptillian"
		cost = 3000

		Create(var/mob/living/M)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.bioHolder)
					H.bioHolder.AddEffect("lizard")
					return 1
			return 0

	cow
		name = "Cow"
		cost = 4000

		Create(var/mob/living/M)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.bioHolder)
					H.bioHolder.AddEffect("cow")
					return 1
			return 0

	skeleton
		name = "Skeleton"
		cost = 5000

		Create(var/mob/living/M)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.bioHolder)
					H.bioHolder.AddEffect("skeleton")
					return 1
			return 0

	roach
		name = "Roach"
		cost = 5000

		Create(var/mob/living/M)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.bioHolder)
					H.bioHolder.AddEffect("roach")
					return 1
			return 0

	limbless
		name = "No Limbs"
		cost = 10000

		Create(var/mob/living/M)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				SPAWN_DBG(6 SECONDS)
					if (H.limbs)
						if (H.limbs.l_arm)
							H.limbs.l_arm.delete()
						if (H.limbs.r_arm)
							H.limbs.r_arm.delete()
						if (H.limbs.l_leg)
							H.limbs.l_leg.delete()
						if (H.limbs.r_leg)
							H.limbs.r_leg.delete()
						boutput( H, "<span class='notice'><b>Your limbs magically disappear! Oh, no!</b></span>" )
				return 1
			return 0

	corpse
		name = "Corpse"
		cost = 15000
		carries_over = 0

		Create(var/mob/living/M)
			setdead(M)
			boutput(M, "<span class='notice'><b>You magically keel over and die! Oh, no!</b></span>")
			return 1

	space_diner
		name = "Space Diner Patron"
		cost = 5000

		Create(var/mob/living/M)
			var/list/start
			for(var/turf/T in get_area_turfs(/area/diner/dining, 1))
				start = T
				break
			if (!start)
				return 0
			if (istype(M.loc, /obj/storage)) // for stowaways
				var/obj/storage/S = M.loc
				S.set_loc(start)
			else
				M.set_loc(start)
			return 1

	mail_order
		name = "Mail Order"
		cost = 5000

		Create(var/mob/living/M)
			var/obj/storage/S
			if (istype(M.loc, /obj/storage)) // also for stowaways; we really should have a system for integrating this stuff
				S = M.loc
			else
				S = new /obj/storage/crate/packing(get_turf(M))
				M.set_loc(S)
				shippingmarket.receive_crate(S)
				return 1

	critter_respawn
		name = "Alt Ghost Critter"
		cost = 1000
		var/list/respawn_critter_types = list(/mob/living/critter/small_animal/boogiebot/weak, /mob/living/critter/small_animal/figure/weak)

		Create(var/mob/M)
			return 1

	golden_ghost
		name = "Golden Ghost"
		cost = 1500

		Create(var/mob/M)
			return 1

	bp_fjallraven
		name = "Rucksack"
		cost = 1400

		Create(var/mob/living/M)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.back)
					var/color = pick("red","yellow")
					H.back.name = "rucksack"
					H.back.icon_state = H.back.item_state = "bp_fjallraven_[color]"
					return 1
			return 0

	bp_randoseru
		name = "Randoseru"
		cost = 1500

		Create(var/mob/living/M)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.back)
					H.back.name = "randoseru"
					H.back.icon_state = H.back.item_state = "bp_randoseru"
					return 1
			return 0

	bp_anello
		name = "Travel Backpack"
		cost = 1600

		Create(var/mob/living/M)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.back)
					H.back.name = "travel pack"
					H.back.icon_state = H.back.item_state = "bp_anello"
				return 1
			return 0

	nt_backpack
		name = "NT Backpack"
		cost = 600

		Create(var/mob/living/M)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.back)
					H.back.name = "\improper NT backpack"
					H.back.icon_state = "NTbackpack"
					return 1
				return 0

	lunchbox
		name = "Lunchbox"
		cost = 600

		Create(var/mob/living/M)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				var/obj/item/storage/lunchbox/L = pick(childrentypesof(/obj/item/storage/lunchbox))
				if ((!H.l_hand && H.equip_if_possible(new L(H), H.slot_l_hand)) || (!H.r_hand && H.equip_if_possible(new L(H), H.slot_r_hand)) || (istype(H.back, /obj/item/storage) && H.equip_if_possible(new L(H), H.slot_in_backpack)))
					return 1
			return 0


	/////////////////////////////////////
	//CLOTHING (FITS HUMAN AND CYBORGS)//
	/////////////////////////////////////

	fruithat
		name = "Fruit Hat"
		cost = 150
		path = /obj/item/clothing/head/fruithat

	hoodie
		name = "Hoodie"
		cost = 1500
		path = /obj/item/clothing/suit/hoodie/random

	pride_o_matic
		name = "Pride-O-Matic Jumpsuit"
		cost = 1200
		path = /obj/item/clothing/under/pride/special

	fake_waldo
		name = "Stripe Outfit"
		cost = 1400
		path = /obj/item/clothing/under/gimmick/fake_waldo

	moustache
		name = "Discount Fake Moustache"
		cost = 500
		path = /obj/item/clothing/mask/moustache/safe

	gold_that
		name = "Golden Top Hat"
		cost = 900
		path = /obj/item/clothing/head/that/gold

	dancin_shoes
		name = "Dancin Shoes"
		cost = 2000
		path = /obj/item/clothing/shoes/heels/dancin

	////////////////////////
	//CYBORG PURCHASEABLES//
	////////////////////////

	alohamaton
		name = "Alohamaton Skin"
		cost = 4000

		Create(var/mob/living/M)
			if (isrobot(M))
				var/mob/living/silicon/robot/R = M
				R.alohamaton_skin = 1
				R.update_appearance()
				return 1
			return 0

	////////////////////
	//AI PURCHASEABLES//
	////////////////////

	malfAI
		name = "Malf AI Skin (placeholder)"
		cost = 2000

		Create(var/mob/living/M)
			if (isAI(M))
				var/mob/living/silicon/ai/A = M
				A.custom_emotions = ai_emotions | list("ROGUE(reward)" = "ai-red")
				A.faceEmotion = "ai-red"
				A.set_color("#EE0000")
				return 1
			return 0

	ai_hat
		name = "AI hat"
		cost = 1000

		Create(var/mob/living/M)
			if (isAI(M))
				var/mob/living/silicon/ai/A = M
				var/picked = pick(childrentypesof(/obj/item/clothing/head))
				A.set_hat(new picked())
				return 1
			return 0


