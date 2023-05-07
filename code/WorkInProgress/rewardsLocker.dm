/datum/achievementReward
	var/title = ""
	var/desc = ""
	var/required_medal = null
	var/once_per_round = 1   //Can only be claimed once per round.
	var/mobonly = 1 //If the reward can only be redeemed if the player has a /mob/living.


	///Called when the reward is claimed from the locker. Spawn item here / give verbs here / do whatever for reward. Return 1 on success or bugs will happen.
	proc/rewardActivate(var/mob/activator)
		boutput(activator, "This reward is undefined. Please inform a coder.")
		//You could even make one-time reward by stripping their medal here.
		return


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// Rewards below
/datum/achievementReward/satchel
	title = "(Skin) Satchel"
	desc = "Converts whatever backpack you're wearing into a satchel. Requires that you're wearing a backpack."
	required_medal = "Fish"
	once_per_round = 0

	rewardActivate(var/mob/activator)
		if (!istype(activator))
			return

		if (!activator.back)
			boutput(activator, "<span class='alert'>You can't reskin a backpack if you're not wearing one!</span>")
			return

		var/obj/item/storage/backpack/M = activator.back
		var/prev_desc

		if(!istype(M))
			boutput(activator, "<span class='alert'>Whatever it is you've got on your back, it isn't a backpack!</span>")
			return

		//SPACEBUX REWARD BACKPACKS
		if (istype(M, /obj/item/storage/backpack/NT) || activator.back.icon_state == "NTbackpack")
			M.icon_state = "NTsatchel"
			M.item_state = "NTsatchel"
			M.name = "\improper NT Satchel"
			M.real_name = "NT satchel"
			M.desc = "A stylish blue, thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's shoulder. (Base Item: NT backpack)"

		else if (istype(M, /obj/item/storage/backpack/randoseru) || activator.back.icon_state == "bp_randoseru")
			M.icon_state = "sat_randoseru"
			M.item_state = "sat_randoseru"
			M.name = "randoseru satchel"
			M.real_name = "randoseru satchel"
			M.desc = "Inconspicuous, nostalgic and quintessentially Space Japanese. (Base Item: randoseru)"

		else if (istype(M, /obj/item/storage/backpack/fjallravenyel) || activator.back.icon_state == "bp_fjallraven_yellow")
			M.icon_state = "sat_fjallraven_yellow"
			M.item_state = "sat_fjallraven_yellow"
			M.name = "rucksack satchel"
			M.real_name = "rucksack satchel"
			M.desc = "A thick, wearable container made of synthetic fibers, perfectly suited for outdoorsy, adventure-loving staff. (Base Item: rucksack)"

		else if (istype(M, /obj/item/storage/backpack/fjallravenred) || activator.back.icon_state == "bp_fjallraven_red")
			M.icon_state = "sat_fjallraven_red"
			M.item_state = "sat_fjallraven_red"
			M.name = "rucksack satchel"
			M.real_name = "rucksack satchel"
			M.desc = "A thick, wearable container made of synthetic fibers, perfectly suited for outdoorsy, adventure-loving staff. (Base Item: rucksack)"

		else if (istype(M, /obj/item/storage/backpack/anello) || activator.back.icon_state == "bp_anello")
			M.icon_state = "sat_anello"
			M.item_state = "sat_anello"
			M.name = "travel satchel"
			M.real_name = "travel satchel"
			M.desc = "A thick, wearable container made of synthetic fibers, often seen carried by tourists and travelers. (Base Item: travel pack)"

		else if (istype(M, /obj/item/storage/backpack/studdedblack) || activator.back.icon_state == "bp_studded")
			M.icon_state = "sat_studded"
			M.item_state = "sat_studded"
			M.name = "studded satchel"
			M.real_name = "studded satchel"
			M.desc = "Made of sturdy synthleather and covered in metal studs. Much edgier than the standard issue bag. (Base Item: studded backpack)"

		else if (istype(M, /obj/item/storage/backpack/itabag/blue) || activator.back.icon_state == "bp_itabag_blue")
			prev_desc = M.desc
			M.icon_state = "sat_itabag_blue"
			M.item_state = "sat_itabag_blue"
			M.name = "blue itabag satchel"
			M.real_name = "blue itabag satchel"
			M.desc = "[prev_desc] (Base Item: blue itabag)"

		else if (istype(M, /obj/item/storage/backpack/itabag/purple) || activator.back.icon_state == "bp_itabag_purple")
			prev_desc = M.desc
			M.icon_state = "sat_itabag_purple"
			M.item_state = "sat_itabag_purple"
			M.name = "purple itabag satchel"
			M.real_name = "purple itabag satchel"
			M.desc = "[prev_desc] (Base Item: purple itabag)"

		else if (istype(M, /obj/item/storage/backpack/itabag/mint) || activator.back.icon_state == "bp_itabag_mint")
			prev_desc = M.desc
			M.icon_state = "sat_itabag_mint"
			M.item_state = "sat_itabag_mint"
			M.name = "mint itabag satchel"
			M.real_name = "mint itabag satchel"
			M.desc = "[prev_desc] (Base Item: mint itabag)"

		else if (istype(M, /obj/item/storage/backpack/itabag/black) || activator.back.icon_state == "bp_itabag_black")
			prev_desc = M.desc
			M.icon_state = "sat_itabag_black"
			M.item_state = "sat_itabag_black"
			M.name = "black itabag satchel"
			M.real_name = "black itabag satchel"
			M.desc = "[prev_desc] (Base Item: black itabag)"

		else if (istype(M, /obj/item/storage/backpack/itabag) || activator.back.icon_state == "bp_itabag_pink")
			prev_desc = M.desc
			M.icon_state = "sat_itabag_pink"
			M.item_state = "sat_itabag_pink"
			M.name = "pink itabag satchel"
			M.real_name = "pink itabag satchel"
			M.desc = "[prev_desc] (Base Item: pink itabag)"

		else if (istype(M, /obj/item/storage/backpack/brown) || activator.back.icon_state == "backpackbr")
			M.icon_state = "satchelbr"
			M.item_state = "satchelbr"
			M.name = "satchel"
			M.real_name = "satchel"
			M.desc = "A thick, wearable container made of synthetic fibers. This brown variation is both rustic and adventurous! (Base Item: backpack)"

		//OTHER NON-JOB BAGS
		else if (istype(M, /obj/item/storage/backpack/NT) || activator.back.icon_state == "Syndiebackpack")
			M.icon_state = "Syndiesatchel"
			M.item_state = "Syndiesatchel"
			M.name = "\improper Syndicate Satchel"
			M.real_name = "Syndicate Satchel"
			M.desc = "A stylish red, evil, thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on an operative's shoulder. (Base Item: Syndicate backpack)"

		else if (istype(M, /obj/item/storage/backpack/studdedwhite) || activator.back.icon_state == "bp_studdedw")
			M.icon_state = "sat_studdedw"
			M.item_state = "sat_studdedw"
			M.name = "white studded satchel"
			M.real_name = "white studded satchel"
			M.desc = "Made of sturdy white synthleather and covered in metal studs. Much edgier than the standard issue bag. (Base Item: white studded backpack)"

		else if (istype(M, /obj/item/storage/backpack/bearpack) || activator.back.icon_state == "bp_bear")
			M.icon_state = "sat_bear"
			M.item_state = "sat_bear"
			M.name = "bear-satchel"
			M.real_name = "bear-satchel"
			M.desc = "An adorable friend that is perfect for hugs AND carries your gear for you, how helpful! (Base Item: bearpack)"

		else if (istype(M, /obj/item/storage/backpack/breadpack) || activator.back.icon_state == "bp_breadpack")
			M.icon_state = "sat_breadpack"
			M.item_state = "sat_breadpack"
			M.name = "bag-uette satchel"
			M.real_name = "bag-uette satchel"
			M.desc = "It kind of smells like bread too! Definitely not edible, sadly. (Base Item: bag-uette)"

		else if (istype(M, /obj/item/storage/backpack/turtlegreen) || activator.back.icon_state == "bp_turtle_green")
			M.icon_state = "sat_turtle_green"
			M.name = "green turtle shell satchel"
			M.real_name = "green turtle shell backpack"
			M.desc = "A satchel that looks like a green turtleshell. Cowabunga! (Base Item: green turtle shell backpack)"

		else if (istype(M, /obj/item/storage/backpack/turtlebrown) || activator.back.icon_state == "bp_turtle_brown")
			M.icon_state = "sat_turtle_brown"
			M.name = "brown turtle shell satchel"
			M.real_name = "brown turtle shell backpack"
			M.desc = "A satchel that looks like a brown turtleshell. How childish! (Base Item: brown turtle shell backpack)"

		else if (istype(M, /obj/item/storage/backpack/blue) || activator.back.icon_state == "backpackb")
			M.icon_state = "satchelb"
			M.item_state = "satchelb"
			M.name = "satchel"
			M.real_name = "satchel"
			M.desc = "A thick, wearable container made of synthetic fibers. The blue variation is similar in shade to Abzu's ocean. (Base Item: backpack)"

		else if (istype(M, /obj/item/storage/backpack/red) || activator.back.icon_state == "backpackr")
			M.icon_state = "satchelr"
			M.item_state = "satchelr"
			M.name = "satchel"
			M.real_name = "satchel"
			M.desc = "A thick, wearable container made of synthetic fibers. The red variation is striking and slightly suspicious. (Base Item: backpack)"

		else if (istype(M, /obj/item/storage/backpack/green) || activator.back.icon_state == "backpackg")
			M.icon_state = "satchelg"
			M.item_state = "satchelg"
			M.name = "satchel"
			M.real_name = "satchel"
			M.desc = "A thick, wearable container made of synthetic fibers. The green variation reminds you of a botanist's garden... (Base Item: backpack)"

		//JOB BAGS
		else if (istype(M, /obj/item/storage/backpack/medic) || activator.back.icon_state == "bp_medic")
			M.icon_state = "satchel_medic"
			M.item_state = "satchel_medic"
			M.name = "medic's satchel"
			M.real_name = "medic's satchel"
			M.desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a medical doctor's shoulder. (Base Item: medic's backpack)"

		else if (istype(M, /obj/item/storage/backpack/security) || activator.back.icon_state == "bp_security")
			M.icon_state = "satchel_security"
			M.item_state = "satchel_security"
			M.name = "security satchel"
			M.real_name = "security satchel"
			M.desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects stylishly on the shoulder of security personnel.(Base Item: security backpack)"

		else if (istype(M, /obj/item/storage/backpack/robotics) || activator.back.icon_state == "bp_robotics")
			M.icon_state = "satchel_robotics"
			M.item_state = "satchel_robotics"
			M.name = "robotics satchel"
			M.real_name = "robotics satchel"
			M.desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects monochromaticly on the shoulder of roboticists.(Base Item: robotics backpack)"

		else if (istype(M, /obj/item/storage/backpack/genetics) || activator.back.icon_state == "bp_genetics")
			M.icon_state = "satchel_genetics"
			M.item_state = "satchel_genetics"
			M.name = "genetics satchel"
			M.real_name = "genetics satchel"
			M.desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects safely on the shoulder of geneticists.(Base Item: genetics backpack)"

		else if (istype(M, /obj/item/storage/backpack/engineering) || activator.back.icon_state == "bp_engineering")
			M.icon_state = "satchel_engineering"
			M.item_state = "satchel_engineering"
			M.name = "engineering satchel"
			M.real_name = "engineering satchel"
			M.desc = "A sturdy, wearable container made of synthetic fibers, able to carry a number of objects effectively on the shoulder of engineers.(Base Item: engineering backpack)"

		else if (istype(M, /obj/item/storage/backpack/research) || activator.back.icon_state == "bp_research")
			M.icon_state = "satchel_research"
			M.item_state = "satchel_research"
			M.name = "research satchel"
			M.real_name = "research satchel"
			M.desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects efficiently on the shoulder of scientists.(Base Item: research backpack)"

		else if (istype(M, /obj/item/storage/backpack/captain/blue) || activator.back.icon_state == "capbackpack_blue")
			M.icon_state = "capsatchel_blue"
			M.item_state = "capsatchel_blue"
			M.name = "Captain's Satchel"
			M.real_name = "Captain's Satchel"
			M.desc = "A fancy designer bag made out of rare blue space snake leather and encrusted with plastic expertly made to look like gold. (Base Item: Captain's Backpack)"

		else if (istype(M, /obj/item/storage/backpack/captain/red) || activator.back.icon_state == "capbackpack_red")
			M.icon_state = "capsatchel_red"
			M.item_state = "capsatchel_red"
			M.name = "Captain's Satchel"
			M.real_name = "Captain's Satchel"
			M.desc = "A fancy designer bag made out of rare red space snake leather and encrusted with plastic expertly made to look like gold. (Base Item: Captain's Backpack)"

		else if (istype(M, /obj/item/storage/backpack/captain) || activator.back.icon_state == "capbackpack")
			M.icon_state = "capsatchel"
			M.item_state = "capbackpack"
			M.name = "Captain's Satchel"
			M.real_name = "Captain's Satchel"
			M.desc = "A fancy designer bag made out of space snake leather and encrusted with plastic expertly made to look like gold. (Base Item: Captain's Backpack)"

		//GENERIC BACKPACK
		else if (M.satchel_compatible && (istype(M, /obj/item/storage/backpack) || activator.back.icon_state == "backpack"))
			M.icon_state = "satchel"
			M.item_state = "satchel"
			M.name = "satchel"
			M.real_name = "satchel"
			M.desc = "A thick, wearable container made of synthetic fibers, able to carry a number of objects comfortably on a crewmember's shoulder. (Base Item: backpack)"
		else
			boutput(activator, "<span class='alert'>Whatever it is you've got on your back, it can't be reskinned!</span>")
			return

		//Updates to ensure satchel is displayed correctly
		M.icon = 'icons/obj/items/storage.dmi'
		M.inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
		if (M.inhand_image) M.inhand_image.icon = 'icons/mob/inhand/hand_storage.dmi'
		M.wear_image_icon = 'icons/mob/clothing/back.dmi'
		if (M.wear_image) M.wear_image.icon = 'icons/mob/clothing/back.dmi'
		activator.set_clothing_icon_dirty()
		M.wear_layer = MOB_BACK_LAYER_SATCHEL

		return 1

/datum/achievementReward/hightechpodskin
	title = "(Skin) HighTech Pod"
	desc = "Gives you a Kit that allows you to change the appearance of a Pod."
	required_medal = "Newton's Crew"

	rewardActivate(var/mob/activator)
		boutput(usr, "<span class='notice'>The Kit has been dropped at your current location.</span>")
		new /obj/item/pod/paintjob/tronthing(get_turf(activator))
		return 1

/datum/achievementReward/respirator
	title = "(Skin) Gas Respirator"
	desc = "Turns a gas mask you're wearing into a high-tech particle-filtered version."
	required_medal = "Old Enemy"
	once_per_round = FALSE

	rewardActivate(var/mob/activator)
		if (!istype(activator))
			return

		if (activator.wear_mask && istype(activator.wear_mask, /obj/item/clothing/mask/gas))
			var/obj/item/clothing/mask/gas/emergency/mask = activator.wear_mask
			mask.icon_state = "respirator-gas"
			mask.item_state = "respirator-gas"
			mask.name = "gas respirator"
			mask.real_name = "gas respirator"
			mask.desc = "A close-fitting gas mask with a custom particle filter."
			mask.color_r = 0.85
			mask.color_g = 0.85
			mask.color_b = 0.95
			activator.set_clothing_icon_dirty()
			return 1

		boutput(activator, "<span class='alert'>Unable to redeem... are you wearing a gas mask?</span>")
		return

/datum/achievementReward/swatgasmask
	title = "(Skin) SWAT Gas Mask"
	desc = "Turns your Gas Mask into a SWAT Gas Mask. If you're wearing one."
	required_medal = "Leave no man behind!"

	rewardActivate(var/mob/activator)
		if (!istype(activator))
			return

		if (activator.wear_mask && istype(activator.wear_mask, /obj/item/clothing/mask/gas))
			var/obj/item/clothing/mask/gas/emergency/M = activator.wear_mask
			M.icon_state = "swatNT"
			//M.item_state = "swat"
			M.name = "SWAT Gas Mask"
			M.real_name = "SWAT Gas Mask"
			M.desc = "A snazzy-looking black Gas Mask."
			M.color_r = 0.8
			M.color_g = 0.8
			M.color_b = 1
			activator.set_clothing_icon_dirty()
			return 1
		boutput(activator, "<span class='alert'>Unable to redeem... are you wearing a gas mask?</span>")
		return

/datum/achievementReward/colorfulberet
	title = "(Skin) Colorful Beret"
	desc = "Turns your hat into a colorful beret. If you're wearing one."
	required_medal = "Monkey Duty"

	rewardActivate(var/mob/activator)
		if (ishuman(activator))
			var/mob/living/carbon/human/H = activator
			if (!istype(H.head, /obj/item/clothing/head/helmet) && istype(H.head, /obj/item/clothing/head)) // ha...
				var/obj/item/clothing/head/M = H.head
				M.icon_state = "beret_base"
				M.wear_image_icon = 'icons/mob/clothing/head.dmi'
				M.color = random_saturated_hex_color(1)
				M.name = "beret"
				M.real_name = "beret"
				M.desc = "A colorful beret."
				activator.set_clothing_icon_dirty()
				return 1
			boutput(activator, "<span class='alert'>Unable to redeem... are you wearing a hat?</span>")
		else
			boutput(activator, "<span class='alert'>Unable to redeem... only humans can redeem this.</span>")

		return 0

/datum/achievementReward/round_flask
	title = "(Skin) Round-bottom Flask"
	desc = "Requires you to be holding a large beaker."
	required_medal = "We didn't start the fire"
	once_per_round = 0

	rewardActivate(var/mob/activator)
		if (!istype(activator))
			return

		var/obj/item/reagent_containers/glass/beaker/large/skin_target = activator.find_type_in_hand(/obj/item/reagent_containers/glass/beaker/large)
		if (skin_target)
			var/prev = skin_target.name
			skin_target.name = "round-bottom flask"
			skin_target.desc = "A large round-bottom flask, for all your chemistry needs. (Base Item: [prev])"
			skin_target.icon_style = "flask"
			skin_target.item_state = "flask"
			skin_target.fluid_image = image(skin_target.icon, "fluid-flask")
			skin_target.UpdateIcon()
			activator.set_clothing_icon_dirty()
			return 1
		else
			boutput(activator, "<span class='alert'>Unable to redeem... you need to have a large beaker in your hands.</span>")
			return

/datum/achievementReward/red_bucket
	title = "(Skin) Red Bucket"
	desc = "Requires you to be holding a bucket."
	required_medal = "Spotless"
	once_per_round = 1

	rewardActivate(var/mob/activator)
		if (!istype(activator))
			return

		var/obj/item/reagent_containers/glass/bucket/skin_target = activator.find_type_in_hand(/obj/item/reagent_containers/glass/bucket)

		if (skin_target)
			var/obj/item/reagent_containers/glass/bucket/red/new_bucket = new /obj/item/reagent_containers/glass/bucket/red(get_turf(activator))
			new_bucket.reagents = skin_target.reagents
			new_bucket.fingerprints = skin_target.fingerprints
			new_bucket.fingerprints_full = skin_target.fingerprints_full
			new_bucket.fingerprintslast = skin_target.fingerprintslast
			skin_target.reagents = null
			skin_target.fingerprints = null
			skin_target.fingerprints_full = null
			skin_target.fingerprintslast = null
			qdel(skin_target)
			activator.put_in_hand(new_bucket)
			return 1
		else
			boutput(activator, "<span class='alert'>Unable to redeem... you need to have a bucket in your hands.</span>")
			return


/datum/achievementReward/pilotuniform
	title = "(Skin) Pilot Suit"
	desc = "Requires that you wear something in your jumpsuit slot."
	required_medal = "It's not 'Door to Heaven'"

	rewardActivate(var/mob/activator)
		if (ishuman(activator))
			var/mob/living/carbon/human/H = activator
			if (H.w_uniform)
				var/obj/item/clothing/M = H.w_uniform
				var/prev = M.name
				M.icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
				M.inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_misc.dmi'
				if (M.inhand_image) M.inhand_image.icon = 'icons/mob/inhand/jumpsuit/hand_js_misc.dmi'
				M.wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
				if (M.wear_image) M.wear_image.icon = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
				M.icon_state = "mechanic-reward"
				M.item_state = "mechanic-reward"
				M.name = "pilot suit"
				M.real_name = "pilot suit"
				M.desc = "A sleek but comfortable pilot's jumpsuit. (Base Item: [prev])"
				H.set_clothing_icon_dirty()
				return 1
			boutput(activator, "<span class='alert'>Unable to redeem... you need to be wearing a jumpsuit.</span>")
			return

		boutput(activator, "<span class='alert'>Unable to redeem... Only humans can redeem this.</span>")
		return

/datum/achievementReward/flower_scrubs
	title = "(Skin) Flower Scrubs"
	desc = "Requires that you wear medical scrubs in your jumpsuit slot."
	required_medal = "Primum non nocere"
	once_per_round = 0

	rewardActivate(var/mob/activator)
		if (ishuman(activator))
			var/mob/living/carbon/human/H = activator
			if (H.w_uniform)
				var/obj/item/clothing/under/scrub/M = H.w_uniform
				if (!istype(M))
					boutput(activator, "<span class='alert'>You're not wearing medical scrubs!</span>")
					return
				var/prev = M.name
				M.icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
				M.inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js.dmi'
				if (M.inhand_image) M.inhand_image.icon = 'icons/mob/inhand/jumpsuit/hand_js.dmi'
				M.wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
				if (M.wear_image) M.wear_image.icon = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
				M.icon_state = "scrub-f"
				M.item_state = "lightblue"
				M.name = "flower scrubs"
				M.real_name = "flower scrubs"
				M.desc = "Man, these scrubs look pretty nice. (Base Item: [prev])"
				H.set_clothing_icon_dirty()
				return 1

		boutput(activator, "<span class='alert'>Unable to redeem... Only humans can redeem this.</span>")
		return

/datum/achievementReward/stylish
	title = "(Skin) Relic Security Jumpsuit"
	desc = "Requires that you wear a security officer or Head of Security uniform in your jumpsuit slot."
	required_medal = "Dead or alive, you're coming with me"

	rewardActivate(var/mob/activator)
		if (ishuman(activator))
			var/mob/living/carbon/human/H = activator
			if (H.w_uniform)
				var/obj/item/clothing/under/rank/M = H.w_uniform
				if (istype(M, /obj/item/clothing/under/rank/head_of_security))
					M.icon_state = "hos-old"
					H.set_clothing_icon_dirty()
					return 1
				else if (istype(M, /obj/item/clothing/under/rank/security))
					M.icon_state = "security-old"
					M.item_state = "security-relic"
					H.set_clothing_icon_dirty()
					return 1

			boutput(activator, "<span class='alert'>Unable to redeem... you need to be wearing a HoS or Security jumpsuit.</span>")
			return
		boutput(activator, "<span class='alert'>Unable to redeem... Only humans can redeem this.</span>")
		return

/datum/achievementReward/med_labcoat
	title = "(Skin) Cool Medical Labcoat"
	desc = "Requires that you wear a medical labcoat in your suit slot."
	required_medal = "Patchwork"
	once_per_round = 0

	rewardActivate(var/mob/activator)
		if (ishuman(activator))
			var/mob/living/carbon/human/H = activator
			if (H.wear_suit)
				var/obj/item/clothing/suit/labcoat/medical/M = H.wear_suit
				if (istype(M))
					//change the icon if you've bought the alt jumpsuit thing (so the coat matches the alt medical jumpsuit)
					if (activator.mind && istype(activator.mind.purchased_bank_item, /datum/bank_purchaseable/altjumpsuit))
						M.icon_state = findtext(M.icon_state, "_o") ? "MDlabcoat-coolalt_o" : "MDlabcoat-coolalt"
						M.coat_style = "MDlabcoat-coolalt"
					else
						M.icon_state = findtext(M.icon_state, "_o") ? "MDlabcoat-cool_o" : "MDlabcoat-cool"
						M.coat_style = "MDlabcoat-cool"

					H.set_clothing_icon_dirty()
					return 1

			boutput(activator, "<span class='alert'>Unable to redeem... you need to be wearing a medical labcoat.</span>")
			return

		boutput(activator, "<span class='alert'>Unable to redeem... Only humans can redeem this.</span>")
		return

/datum/achievementReward/sci_labcoat
	title = "(Skin) Science Labcoat"
	desc = "Requires that you wear a labcoat in your suit slot."
	required_medal = "Meth is a hell of a drug"
	once_per_round = 0

	rewardActivate(var/mob/activator)
		if (ishuman(activator))
			var/mob/living/carbon/human/H = activator
			if (H.wear_suit)
				var/obj/item/clothing/suit/labcoat/M = H.wear_suit
				if (istype(M))
					var/prev = M.name
					M.icon = 'icons/obj/clothing/overcoats/item_suit.dmi'
					M.inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit.dmi'
					if (M.inhand_image) M.inhand_image.icon = 'icons/mob/inhand/overcoat/hand_suit.dmi'
					M.wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit.dmi'
					if (M.wear_image) M.wear_image.icon = 'icons/mob/clothing/overcoats/worn_suit.dmi'

					//change the icon if you've bought the alt jumpsuit thing (so the coat matches the alt science jumpsuit)
					if (activator.mind && istype(activator.mind.purchased_bank_item, /datum/bank_purchaseable/altjumpsuit))
						M.icon_state = findtext(M.icon_state, "_o") ? "SCIlabcoat-alt_o" : "SCIlabcoat-alt"
						M.item_state = "SCIlabcoat-alt"
						M.coat_style = "SCIlabcoat-alt"
						M.desc = "A protective laboratory coat with the green markings of a fancy Scientist. (Base Item: [prev])"
					else
						M.icon_state = findtext(M.icon_state, "_o") ? "SCIlabcoat_o" : "SCIlabcoat"
						M.item_state = "SCIlabcoat"
						M.coat_style = "SCIlabcoat"
						M.desc = "A protective laboratory coat with the purple markings of a Scientist. (Base Item: [prev])"

					M.name = "scientist's labcoat"
					M.real_name = "scientist's labcoat"
					H.set_clothing_icon_dirty()
					return 1

			boutput(activator, "<span class='alert'>Unable to redeem... you need to be wearing a labcoat.</span>")
			return

		boutput(activator, "<span class='alert'>Unable to redeem... Only humans can redeem this.</span>")
		return

/datum/achievementReward/alchemistrobes
	title = "(Skin) Grand Alchemist's Robes"
	desc = "Requires that you wear a labcoat in your suit slot."
	required_medal = "Illuminated"
	once_per_round = 0

	rewardActivate(var/mob/activator)
		if (ishuman(activator))
			var/mob/living/carbon/human/H = activator
			if (H.wear_suit)
				var/obj/item/clothing/suit/labcoat/M = H.wear_suit
				if (istype(M))
					var/prev = M.name
					M.icon = 'icons/obj/clothing/overcoats/item_suit.dmi'
					M.inhand_image_icon = 'icons/mob/inhand/hand_cl_suit.dmi'
					if (M.inhand_image) M.inhand_image.icon = 'icons/mob/inhand/hand_cl_suit.dmi'
					M.wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit.dmi'
					if (M.wear_image) M.wear_image.icon = 'icons/mob/clothing/overcoats/worn_suit.dmi'
					M.icon_state = findtext(M.icon_state, "_o") ? "alchrobe_o" : "alchrobe"
					M.item_state = "alchrobe"
					M.coat_style = "alchrobe"
					M.name = "grand alchemist's robes"
					M.real_name = "grand alchemist's robes"
					M.desc = "Well you sure LOOK the part with these on. (Base Item: [prev])"
					H.set_clothing_icon_dirty()
					return 1
			boutput(activator, "<span class='alert'>Unable to redeem... you need to be wearing a labcoat.</span>")
			return

		boutput(activator, "<span class='alert'>Unable to redeem... Only humans can redeem this.</span>")
		return

/datum/achievementReward/dioclothes
	title = "(Skin) Strange Vampire Outfit"
	desc = "Requires that you wear a vampire cape."
	required_medal = "Dracula Jr."

	rewardActivate(var/mob/activator)
		if (ishuman(activator))
			var/mob/living/carbon/human/H = activator
			if (H.wear_suit)
				var/obj/item/clothing/M = H.wear_suit
				if (istype(M, /obj/item/clothing/suit/gimmick/vampire))
					var/prev = M.name
					M.icon = 'icons/obj/clothing/overcoats/item_suit.dmi'
					M.inhand_image_icon = 'icons/mob/inhand/hand_cl_suit.dmi'
					M.wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit.dmi'
					M.icon_state = "vclothes"
					M.item_state = "vclothes"
					M.name = "strange vampire outfit"
					M.real_name = "strange vampire outfit"
					M.desc = "How many breads <i>have</i> you eaten in your life? It's a good question. (Base Item: [prev])"
					H.set_clothing_icon_dirty()
					return 1

		boutput(activator, "<span class='alert'>Unable to redeem... you must be wearing a vampire cape. Guess it's the thought that <i>counts<i>. </span>")
		return

/datum/achievementReward/clown_college
	title = "Clown College Regalia"
	desc = "Spawns you your clown college graduation cap and diploma."
	required_medal = "Unlike the director, I went to college"

	rewardActivate(var/mob/activator)
		if (ishuman(activator))
			var/mob/living/carbon/human/H = activator
			if (H.mind.assigned_role == "Clown")
				H.equip_if_possible(new /obj/item/clothing/head/graduation_cap(H), H.slot_head)
				var/obj/item/toy/diploma/D = new /obj/item/toy/diploma(get_turf(H))
				D.redeemer = H.ckey
				H.put_in_hand_or_drop(D)
				return 1
			boutput(H, "You're not a honking clown, you imposter!")

		boutput(activator, "<span class='alert'>Unable to redeem... Only humans can redeem this.</span>")
		return

/datum/achievementReward/Aerostaticjacket
	title = "(Skin) Aerostatic Pilot Jacket"
	desc = "Turns your detectives coat into a orange pilot jacket"
	required_medal = "Deep Freeze"

	rewardActivate(var/mob/activator)
		var/mob/living/carbon/human/H = activator
		if (H.wear_suit)
			var/obj/item/clothing/suit/det_suit/M = H.wear_suit
			if (istype(M))
				var/prev = M.name
				M.icon_state = findtext(M.icon_state, "_o") ? "detective_kim_o" : "detective_kim"
				M.coat_style = "detective_kim"
				M.name = "Aerostatic Pilot Jacket"
				M.real_name = "Aerostatic pilot jacket"
				M.desc = "You feel centered while wearing this... Maybe you could put something in the pockets? (Base Item: [prev])"
				H.set_clothing_icon_dirty()
				return 1

			if(H.mind.assigned_role == "Detective")
				boutput(activator, "<span class='alert'>Unable to redeem... you need to be wearing your jacket, detective.</span>")
				return

			boutput(activator, "<span class='alert'>Unable to redeem... you need to be wearing a detective's jacket.</span>")
		return

/datum/achievementReward/inspectorscloths
	title = "(Skin set) Inspector's Clothes"
	desc = "Will change the skin of a detective's coat, hats, gloves, shoes, jumpsuit, and holster."
	required_medal = "Neither fashionable noir stylish"
	once_per_round = FALSE

	rewardActivate(var/mob/activator)
		if (ishuman(activator))
			var/mob/living/carbon/human/H = activator
			var/succ = FALSE
			if (H.wear_suit)
				var/obj/item/clothing/suit/det_suit/M = H.wear_suit
				if (istype(M))
					var/prev = M.name
					M.icon_state = findtext(M.icon_state, "_o") ? "inspectorc_o" : "inspectorc"
					M.coat_style = "inspectorc"
					M.name = "inspector's short coat"
					M.real_name = "inspector's short coat"
					M.desc = "A coat for the modern detective. (Base Item: [prev])"
					H.set_clothing_icon_dirty()
					succ = TRUE

			if (H.w_uniform)
				var/obj/item/clothing/M = H.w_uniform
				if (istype(M, /obj/item/clothing/under/rank/det))
					var/prev = M.name
					M.icon = 'icons/obj/clothing/uniforms/item_js_misc.dmi'
					M.inhand_image_icon = 'icons/mob/inhand/jumpsuit/hand_js_misc.dmi'
					M.wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_misc.dmi'
					M.icon_state = "inspectorj"
					M.item_state = "viceG"
					M.name = "inspector's uniform"
					M.real_name = "inspector's uniform"
					M.desc = "A uniform for the modern detective. (Base Item: [prev])"
					H.set_clothing_icon_dirty()
					succ = TRUE

			if (H.head)
				var/obj/item/clothing/M = H.head
				var/obj/item/clothing/head/det_hat/gadget/G = H.head
				if (istype(G))
					var/prev = M.name
					G.icon_state = "inspector"
					G.item_state = "inspector"
					G.desc = "Detective's special hat you can outfit with various items for easy retrieval! (Base Item: [prev])"
					G.inspector = TRUE
					H.set_clothing_icon_dirty()
					succ = TRUE
				else if (istype(M, /obj/item/clothing/head/det_hat))
					var/prev = M.name
					M.icon_state = "inspector"
					M.item_state = "inspector"
					M.name = "inspector's hat"
					M.real_name = "inspector's hat"
					M.desc = "A hat for the modern detective. (Base Item: [prev])"
					H.set_clothing_icon_dirty()
					succ = TRUE

			if (H.belt)
				var/obj/item/storage/belt/M = H.belt
				if (istype(M, /obj/item/storage/belt/security/shoulder_holster))
					var/prev = M.name
					M.icon_state = "inspector_holster"
					M.item_state = "inspector_holster"
					M.name = "inspector's holster"
					M.real_name = "inspector holster"
					M.desc = "A shoulder holster for the modern detective. (Base Item: [prev])"
					H.set_clothing_icon_dirty()
					succ = TRUE

			if (H.shoes)
				var/obj/item/clothing/M = H.shoes
				if (istype(M, /obj/item/clothing/shoes/detective))
					var/prev = M.name
					M.icon_state = "inspector"
					M.item_state = "inspector"
					M.name = "inspector's boots"
					M.real_name = "inspector's boots"
					M.desc = "This pair of boots has inspected it's fair share of mysteries. (Base Item: [prev])"
					H.set_clothing_icon_dirty()
					succ = TRUE

			if (H.gloves)
				var/obj/item/clothing/M = H.gloves
				if (istype(M, /obj/item/clothing/gloves/black))
					var/prev = M.name
					M.icon_state = "inspector"
					M.item_state = "inspector"
					M.name = "inspector's gloves"
					M.real_name = "inspector's gloves"
					M.desc = "A pair of gloves for the modern detective. (Base Item: [prev])"
					H.set_clothing_icon_dirty()
					succ = TRUE

			if (!succ)
				boutput(activator, "<span class='alert'>Unable to redeem... now that's a case for a real detective, not you.</span>")
			return succ

		boutput(activator, "<span class='alert'>Unable to redeem... Only humans can redeem this.</span>")
		return

/datum/achievementReward/ntso_commander
	title = "(Skin set) NT-SO Commander Uniform"
	desc = "Will change the skin of captain hats, captain armor/spacesuits, cap backpacks, sabres and captain uniforms."
	required_medal = "Icarus"
	once_per_round = FALSE

	rewardActivate(var/mob/activator)
		if (ishuman(activator))
			var/mob/living/carbon/human/H = activator
			var/succ = FALSE
			if (H.w_uniform)
				var/obj/item/clothing/M = H.w_uniform
				if (istype(M, /obj/item/clothing/under/rank/captain))
					var/prev = M.name
					M.name = "commander's uniform"
					M.desc = "A uniform specifically for NanoTrasen commanders. (Base Item: [prev])"
					if (istype(M, /obj/item/clothing/under/rank/captain/fancy))
						M.icon_state = "captain-fancy-blue"
						M.item_state = "captain-fancy-blue"
					else if (istype(M, /obj/item/clothing/under/rank/captain/dress))
						M.icon_state = "captain-dress-blue"
						M.item_state = "captain-dress-blue"
					else
						M.icon_state = "captain-blue"
						M.item_state = "captain-blue"
					H.set_clothing_icon_dirty()
					succ = TRUE

				else if (istype(M, /obj/item/clothing/under/suit/captain))
					var/prev = M.name
					M.name = "\improper Commander's suit"
					M.desc = "A uniform specifically for NanoTrasen commanders. (Base Item: [prev])"
					if (istype(M, /obj/item/clothing/under/suit/captain/dress))
						M.icon_state = "suit-capB-dress"
						M.item_state = "suit-capB-dress"
					else
						M.icon_state = "suit-capB"
						M.item_state = "suit-capB"
					H.set_clothing_icon_dirty()
					succ = TRUE

			if (H.wear_suit)
				var/obj/item/clothing/M = H.wear_suit
				if (istype(M, /obj/item/clothing/suit/armor/captain))
					var/prev = M.name
					M.icon_state = "centcom"
					M.item_state = "centcom"
					M.name = "commander's armor"
					M.real_name = "commander's armor"
					M.desc = "A suit of protective formal armor. It is made specifically for NanoTrasen commanders. (Base Item: [prev])"
					H.set_clothing_icon_dirty()
					succ = TRUE

				if (istype(M, /obj/item/clothing/suit/armor/capcoat))
					var/prev = M.name
					M.icon_state = "centcoat"
					M.item_state = "centcoat"
					M.name = "commander's coat"
					M.real_name = "commander's coat"
					M.desc = "A luxorious formal coat. It is specifically made for Nanotrasen commanders.(Base Item: [prev])"
					H.set_clothing_icon_dirty()
					succ = TRUE

				else if (istype(M, /obj/item/clothing/suit/space/captain))
					var/prev = M.name
					M.icon_state = "spacecap-blue"
					M.item_state = "spacecap-blue"
					M.name = "commander's space suit"
					M.real_name = "commander's space suit"
					M.desc = "A suit that protects against low pressure environments. It is made specifically for NanoTrasen commanders. (Base Item: [prev])"
					H.set_clothing_icon_dirty()
					succ = TRUE

			if (H.head)
				var/obj/item/clothing/M = H.head
				if (istype(M, /obj/item/clothing/head/caphat))
					var/prev = M.name
					M.icon_state = "centcom"
					M.item_state = "centcom"
					M.name = "commander's hat"
					M.real_name = "commander's hat"
					M.desc = "A fancy hat specifically for NanoTrasen commanders. (Base Item: [prev])"
					H.set_clothing_icon_dirty()
					succ = TRUE

				else if (istype(M, /obj/item/clothing/head/helmet/space/captain))
					var/prev = M.name
					M.name = "commander's space helmet"
					M.desc = "Helps protect against vacuum. Comes in a fasionable blue befitting a commander. (Base Item: [prev])"
					M.icon_state = "space-captain-blue"
					M.item_state = "space-captain-blue"
					H.set_clothing_icon_dirty()
					succ = TRUE

				else if (istype(M, /obj/item/clothing/head/helmet/captain))
					var/prev = M.name
					M.name = "commander's helmet"
					M.desc = "Somewhat protects an important person's head from being bashed in. Comes in a stylish shade of blue befitting of a commander. (Base Item: [prev])"
					M.icon_state = "helmet-captain-blue"
					M.item_state = "helmet-captain-blue"
					H.set_clothing_icon_dirty()
					succ = TRUE

			if (H.belt)
				var/obj/item/M = H.belt
				if (istype(M, /obj/item/swords_sheaths/captain))
					if (M.item_state == "scabbard-cap1" || M.item_state == "red_scabbard-cap1")
						qdel(M)
						H.equip_if_possible(new /obj/item/swords_sheaths/captain/blue(H), H.slot_belt)
						succ = TRUE

			if (H.back)
				if (istype(H.back, /obj/item/storage/backpack/satchel/captain) || (H.back.icon_state == "capsatchel" || H.back.icon_state == "capsatchel_red"))
					var/obj/item/storage/backpack/satchel/captain/M = activator.back
					var/prev = M.name
					M.icon_state = "capsatchel_blue"
					M.item_state = "capsatchel_blue"
					M.desc = "A fancy designer bag made out of rare blue space snake leather and encrusted with plastic expertly made to look like gold. (Base Item: [prev])"
					H.set_clothing_icon_dirty()
					succ = TRUE

				if (istype(H.back, /obj/item/storage/backpack/captain))
					if (H.back.icon_state == "capbackpack" || H.back.icon_state == "capbackpack_red")
						var/obj/item/storage/backpack/captain/M = activator.back
						var/prev = M.name
						M.icon_state = "capbackpack_blue"
						M.item_state = "capbackpack_blue"
						M.desc = "A fancy designer bag made out of rare blue space snake leather and encrusted with plastic expertly made to look like gold. (Base Item: [prev])"
						H.set_clothing_icon_dirty()
						succ = TRUE

				if(H.find_type_in_hand(/obj/item/megaphone))
					var/obj/item/megaphone/M = H.find_type_in_hand(/obj/item/megaphone)
					M.icon_state = "megaphone_blue"
					M.item_state = "megaphone_blue"
					M.desc = "The captain's megaphone, fancily decorated blue to induce a 'cool' and 'calming' sensation in those around. Useful for barking demands at staff assistants or getting your point across."
					M.maptext_color = "#c1ddf8"
					M.maptext_outline_color = "#02294d"
					succ = TRUE

			if (!succ)
				boutput(activator, "<span class='alert'>Unable to redeem... What kind of fake captain are you!?</span>")
			return succ
		else
			boutput(activator, "<span class='alert'>Unable to redeem... Only humans can redeem this.</span>")
			return FALSE

//red captain medal, after all this time!
/datum/achievementReward/centcom_executive
	title = "(Skin Set) CENTCOM Executive Uniform"
	desc = "Will change the skin of captain hats, captain armor/spacesuits, cap backpacks, sabres and captain uniforms."
	required_medal = "Brown Pants" //Red shirt, brown pants.
	once_per_round = FALSE

	rewardActivate(var/mob/activator)
		if (ishuman(activator))
			var/mob/living/carbon/human/H = activator
			var/succ = FALSE
			if (H.w_uniform)
				var/obj/item/clothing/M = H.w_uniform
				if (istype(M, /obj/item/clothing/under/rank/captain))
					var/prev = M.name
					M.name = "\improper CentCom uniform"
					M.desc = "A uniform specifically for CENTCOM executives. (Base Item: [prev])"
					if (istype(M, /obj/item/clothing/under/rank/captain/fancy))
						M.icon_state = "captain-fancy-red"
						M.item_state = "captain-fancy-red"
					else if (istype(M, /obj/item/clothing/under/rank/captain/dress))
						M.icon_state = "captain-dress-red"
						M.item_state = "captain-dress-red"
					else
						M.icon_state = "captain-red"
						M.item_state = "captain-red"
					H.set_clothing_icon_dirty()
					succ = TRUE

				else if (istype(M, /obj/item/clothing/under/suit/captain))
					var/prev = M.name
					M.name = "\improper CentCom suit"
					M.desc = "A uniform specifically for CENTCOM executives. (Base Item: [prev])"
					if (istype(M, /obj/item/clothing/under/suit/captain/dress))
						M.icon_state = "suit-capR-dress"
						M.item_state = "suit-capR-dress"
					else
						M.icon_state = "suit-capR"
						M.item_state = "suit-capR"
					H.set_clothing_icon_dirty()
					succ = TRUE

			if (H.wear_suit)
				var/obj/item/clothing/M = H.wear_suit
				if (istype(M, /obj/item/clothing/suit/armor/captain))
					var/prev = M.name
					M.icon_state = "centcom-red"
					M.item_state = "centcom-red"
					M.name = "\improper CentCom armor"
					M.desc = "A suit of protective formal armor. It is made specifically for CENTCOM executives. (Base Item: [prev])"
					H.set_clothing_icon_dirty()
					succ = TRUE

				if (istype(M, /obj/item/clothing/suit/armor/capcoat))
					var/prev = M.name
					M.icon_state = "centcoat-red"
					M.item_state = "centcoat-red"
					M.name = "\improper CentCom coat"
					M.real_name = "\improper CentCom coat"
					M.desc = "A luxorious formal coat. It is specifically made for CENTCOM executives.(Base Item: [prev])"
					H.set_clothing_icon_dirty()
					succ = TRUE

				else if (istype(M, /obj/item/clothing/suit/space/captain))
					var/prev = M.name
					M.icon_state = "spacecap-red"
					M.item_state = "spacecap-red"
					M.name = "\improper CentCom space suit"
					M.desc = "A suit that protects against low pressure environments. It is made specifically for CENTCOM executives. (Base Item: [prev])"
					H.set_clothing_icon_dirty()
					succ = TRUE

			if (H.head)
				var/obj/item/clothing/M = H.head
				if (istype(M, /obj/item/clothing/head/caphat))
					var/prev = M.name
					M.icon_state = "centcom-red"
					M.item_state = "centcom-red"
					M.name = "\improper CentCom hat"
					M.desc = "A fancy hat specifically for CENTCOM executives. (Base Item: [prev])"
					H.set_clothing_icon_dirty()
					succ = TRUE

				else if (istype(M, /obj/item/clothing/head/helmet/space/captain))
					var/prev = M.name
					M.name = "\improper CentCom space helmet"
					M.desc = "Helps protect against vacuum. Comes in a fasionable red befitting an executive. (Base Item: [prev])"
					M.icon_state = "space-captain-red"
					M.item_state = "space-captain-red"
					H.set_clothing_icon_dirty()
					succ = TRUE

				else if (istype(M, /obj/item/clothing/head/helmet/captain))
					var/prev = M.name
					M.name = "\improper CentCom helmet"
					M.desc = "Somewhat protects an important person's head from being bashed in. Comes in a stylish shade of red befitting an executive. (Base Item: [prev])"
					M.icon_state = "helmet-captain-red"
					M.item_state = "helmet-captain-red"
					H.set_clothing_icon_dirty()
					succ = TRUE

			if (H.belt)
				var/obj/item/M = H.belt
				if (istype(M, /obj/item/swords_sheaths/captain))
					if (M.item_state == "scabbard-cap1" || M.item_state == "blue_scabbard-cap1")
						qdel(M)
						H.equip_if_possible(new /obj/item/swords_sheaths/captain/red(H), H.slot_belt)
						succ = TRUE

			if (H.back)
				if (istype(H.back, /obj/item/storage/backpack/satchel/captain) || (H.back.icon_state == "capsatchel" || H.back.icon_state == "capsatchel_blue"))
					var/obj/item/storage/backpack/satchel/captain/M = activator.back
					var/prev = M.name
					M.icon_state = "capsatchel_red"
					M.item_state = "capsatchel_red"
					M.desc = "A fancy designer bag made out of rare red space snake leather and encrusted with plastic expertly made to look like gold. (Base Item: [prev])"
					H.set_clothing_icon_dirty()
					succ = TRUE

				if (istype(H.back, /obj/item/storage/backpack/captain))
					if (H.back.icon_state == "capbackpack" || H.back.icon_state == "capbackpack_blue")
						var/obj/item/storage/backpack/captain/M = activator.back
						var/prev = M.name
						M.icon_state = "capbackpack_red"
						M.item_state = "capbackpack_red"
						M.desc = "A fancy designer bag made out of rare red space snake leather and encrusted with plastic expertly made to look like gold. (Base Item: [prev])"
						H.set_clothing_icon_dirty()
						succ = TRUE

				if(H.find_type_in_hand(/obj/item/megaphone))
					var/obj/item/megaphone/M = H.find_type_in_hand(/obj/item/megaphone)
					M.icon_state = "megaphone_red"
					M.item_state = "megaphone_red"
					M.desc = "The captain's megaphone, fancily decorated red, which helps it stand out. Useful for barking demands at staff assistants or getting your point across."
					M.maptext_color = "#fcd4d4"
					M.maptext_outline_color = "#520000"
					succ = TRUE


			if (!succ)
				boutput(activator, "<span class='alert'>Unable to redeem... What kind of fake captain are you!?</span>")
			return succ
		else
			boutput(activator, "<span class='alert'>Unable to redeem... Only humans can redeem this.</span>")
			return FALSE

/datum/achievementReward/ai_malf
	title = "(AI Face) Malfunction"
	desc = "Turns you into a scary malfunctioning AI! Only in appearance, of course."
	required_medal = "HUMANOID MUST NOT ESCAPE"

	rewardActivate(var/mob/activator)
		if (isAI(activator))
			var/mob/living/silicon/ai/A = activator
			if (isAIeye(activator))
				var/mob/living/intangible/aieye/AE = activator
				A = AE.mainframe
			A.custom_emotions = ai_emotions | list("ROGUE(reward)" = "ai-red")
			A.faceEmotion = "ai-red"
			A.set_color("#EE0000")
			//A.icon_state = "ai-malf"
			return 1
		else
			boutput(activator, "<span class='alert'>You need to be an AI to use this, you goof!</span>")

/datum/achievementReward/ai_tetris
	title = "(AI Face) Tetris"
	desc = "Turns you into a tetris-playing machine!"
	required_medal = "Block Stacker"

	rewardActivate(var/mob/activator)
		if (isAI(activator))
			var/mob/living/silicon/ai/A = activator
			if (isAIeye(activator))
				var/mob/living/intangible/aieye/AE = activator
				A = AE.mainframe
			A.custom_emotions = ai_emotions | list("Tetris (reward)" = "ai-tetris")
			A.faceEmotion = "ai-tetris"
			A.set_color("#111111")
			A.update_appearance()
			return 1
		else
			boutput(activator, "<span class='alert'>You need to be an AI to use this, you goof!</span>")

datum/achievementReward/ai_dwaine
	title = "(AI Core Skin) DWAINE"
	desc = "Replaces the casing of your core with an older model!"
	required_medal = "421"

	rewardActivate(mob/activator)
		if (isAI(activator))
			var/mob/living/silicon/ai/A = activator
			if (isAIeye(activator))
				var/mob/living/intangible/aieye/AE = activator
				A = AE.mainframe
			A.coreSkin = "dwaine"
			A.update_appearance()
			return 1
		else
			boutput(activator, "<span class='alert'>You need to be an AI to use this, you goof!</span>")

/datum/achievementReward/borg_automoton
	title = "(Cyborg Skin) Automaton"
	desc = "Turns you into the mysterious Automaton! Only in appearance, of course. Keys not included."
	required_medal = "Icarus"

	rewardActivate(var/mob/activator)
		if (isrobot(activator))
			var/mob/living/silicon/robot/C = activator
			C.automaton_skin = 1
			C.update_appearance()
			return 1
		else
			boutput(activator, "<span class='alert'>You need to be a cyborg to use this, you goof!</span>")

/*
/datum/achievementReward/secbelt
	title = "(Skin) Security Toolbelt"
	desc = "Turns your worn Utility Belt into a Security Toolbelt."
	required_medal = "Suitable? How about the Oubliette?!"

	rewardActivate(var/mob/living/carbon/human/activator)

	rewardActivate(var/mob/activator)
		if (!ishuman(activator))
			return

		var/mob/living/carbon/human/H = activator

		if (H.belt && istype(H.belt, /obj/item/storage/belt/utility))
			var/obj/item/storage/belt/utility/M = H.belt
			var/prev = M.name
			M.icon_state = "secbelt"
			M.item_state = "secbelt"
			M.name = "security toolbelt"
			M.real_name = "security toolbelt"
			M.desc = "For the trend-setting Security Officer on the go. (Base Item: [prev])"
			H.set_clothing_icon_dirty()
		return
*/

/datum/achievementReward/goldenGun
	title = "Golden Gun"
	desc = "Gold plates a shotgun, hunting rifle, detective revolver, or AK-47 you're holding."
	required_medal = "Helios"

	rewardActivate(var/mob/activator)
		if (ishuman(activator))
			var/mob/living/carbon/human/H = activator
			var/obj/item/gun/kinetic/gunmod
			if (istype(H.l_hand, /obj/item/gun/kinetic))
				gunmod = H.l_hand
			else if (istype(H.r_hand, /obj/item/gun/kinetic))
				gunmod = H.r_hand
			if (!gunmod)
				boutput(activator, "<span class='alert'>You can't be the man with the golden gun if you ain't got a got dang gun!</span>")
				return
			if(!gunmod.gildable)
				boutput(activator, "<span class='alert'>This gun doesn't seem to be gildable!</span>")
				return

			gunmod.name = "Golden [gunmod.name]"
			gunmod.icon_state = "[initial(gunmod.icon_state)]-golden"
			gunmod.item_state = "[initial(gunmod.item_state)]-golden"
			gunmod.gilded = TRUE
			gunmod.UpdateIcon()
			H.update_inhands()
			return 1


/datum/achievementReward/smug
	title = "(Emote) Smug"
	desc = "Gives you the ability to be all smug about something. I bet nobody likes you."
	required_medal = ":10bux:"

	rewardActivate(var/mob/activator)
		if (!istype(activator))
			return
		activator.verbs += /proc/smugproc
		return 1

/datum/achievementReward/shelterbee
	title = "(Emote) Shelterbee"
	desc = "Shelterbee expresses what you cannot. And it's also pretty dang cute."
	required_medal = "Too Cool"

	rewardActivate(var/mob/activator)
		if (!istype(activator))
			return
		boutput(usr, "<span class='notice'>:shelterbee:</span>")
		animate_emote(usr, /obj/effect/shelterbee)
		return 1

/obj/effect/shelterbee
	name = "shelterbee"
	icon = 'icons/mob/64.dmi'
	icon_state = "shelterbee"
	anchored = ANCHORED
	pixel_x = -16
	pixel_y = -16

/datum/achievementReward/participantribbon
	title = "(Transformation) Participation Ribbon"
	desc = "Turn into a living participation ribbon. No refunds!"
	required_medal = "Fun Times"
	mobonly = 0

	rewardActivate(var/mob/activator)
		if (!isobserver(activator))
			boutput(activator, "<span class='alert'>You gotta be dead to use this, you goof!</span>")
			return
		var/mob/living/object/O = new /mob/living/object(get_turf(usr), new /obj/item/sticker/ribbon/participant, usr)
		O.say_language = "animal"
		O.literate = 0
		return 1

/datum/achievementReward/goldbud
	title = "(Skin) Golden PR-4 Guardbuddy Frame"
	desc = "Gold plates a held PR-4 Guardbuddy frame."
	required_medal = "Ol' buddy ol' pal"
	once_per_round = 1

	rewardActivate(var/mob/activator)
		if (!istype(activator))
			return

		var/obj/item/guardbot_frame/old/skin_target = activator.find_type_in_hand(/obj/item/guardbot_frame/old)
		if (skin_target)
			new /obj/item/guardbot_frame/old/golden(get_turf(activator))
			qdel(skin_target)
			return 1

		boutput(activator, "<span class='alert'>You need to be holding a PR-4 Guardbuddy frame in order to claim this reward!</span>")
		return


/proc/smugproc()
	set name = ":smug:"
	set desc = "Allows you to show others how great you feel about yourself for having paid 10 bucks."
	set category = "Commands"

	animate_emote(usr, /obj/effect/smug)
	usr.verbs -= /proc/smugproc
	usr.verbs += /proc/smugprocCD
	SPAWN(30 SECONDS)
		boutput(usr, "<span class='notice'>You can now be smug again! Go hog wild.</span>")
		usr.verbs += /proc/smugproc
		usr.verbs -= /proc/smugprocCD
	return

/proc/smugprocCD()
	set name = ":smug:"
	set desc = "Currently on cooldown."
	set category = "Commands"

	boutput(usr, "<span class='alert'>You can't use that again just yet.</span>")
	return

/obj/effect/smug
	name = "smug"
	icon = 'icons/mob/64.dmi'
	icon_state = "smug"
	anchored = ANCHORED
	pixel_x = -16
	pixel_y = -16

/datum/achievementReward/beefriend
	title = "(Reagent) Bee"
	desc = "You're gonna burp one up, probably."
	required_medal = "Bombini is missing!"

	rewardActivate(var/mob/activator)
		if (!activator.reagents) return
		activator.reagents.add_reagent("bee", 5)
		boutput (activator, "<span class='alert'>Pleeze hold, bee will bee with thee shortlee!</span>" )
		return 1

/datum/achievementReward/bloodflood
	title = "(Fancy Gib) Plague of Blood"
	desc = "This will cleanse you of Original Sin (permanently)."
	required_medal = "Original Sin"
	// once_per_round = 0

	rewardActivate(var/mob/activator)
		if (isdead(activator))
			boutput(activator, "<span class='alert'>You uh, yeah no- you already popped, buddy.</span>")
			return
		if (activator.restrained() || is_incapacitated(activator))
			boutput(activator, "<span style=\"color:red\">Absolutely Not. You can't be incapacitated.</span>")
			return
		var/blood_id = "blood"
		var/blood_amount = 500
		var/blood_mult = 6.9
		var/mob/living/L = activator
		if(istype(L))
			var/mob/living/carbon/human/H = activator
			if(L.blood_id)
				blood_id = L.blood_id
			if(istype(H) && H.blood_volume)
				blood_amount = H.blood_volume
		activator.suiciding = 1
		var/turf/T = get_turf(activator)
		if (L?.traitHolder?.hasTrait("hemophilia"))
			blood_mult = blood_mult + 3
		T.fluid_react_single(blood_id,blood_mult * blood_amount)
		var/result = world.ClearMedal("Original Sin", activator, config.medal_hub, config.medal_password)
		logTheThing(LOG_COMBAT, activator, "Activated the blood flood gib reward thing (Original Sin)")
		if (result)
			boutput(activator, "<span class='alert'>You feel your soul cleansed of sin.</span>")
			playsound(T, 'sound/voice/farts/diarrhea.ogg', 50, 1)
		activator.gib()
		return 1
/datum/achievementReward/HotrodHelmet
	title = "(Skin) Hotrod Welding Helmet"
	desc = "Requires you to hold a welding helmet."
	required_medal = "Slow Burn"
	once_per_round = 0

	rewardActivate(var/mob/activator)
		if (!istype(activator))
			return

		var/obj/item/clothing/head/helmet/welding/skin_target = activator.find_type_in_hand(/obj/item/clothing/head/helmet/welding)
		if (skin_target)
			var/obj/item/clothing/head/helmet/welding/fire/new_helmet = new /obj/item/clothing/head/helmet/welding/fire(get_turf(activator))
			new_helmet.fingerprints = skin_target.fingerprints
			new_helmet.fingerprints_full = skin_target.fingerprints_full
			new_helmet.fingerprintslast = skin_target.fingerprintslast
			skin_target.fingerprints = null
			skin_target.fingerprints_full = null
			skin_target.fingerprintslast = null
			qdel(skin_target)
			activator.put_in_hand_or_drop(new_helmet)
			return 1
		else
			boutput(activator, "<span class='alert'>Unable to redeem... you need to have a welding helmet in your hands.</span>")
			return


// Reward management stuff

/datum/achievementReward/contributor
	title = "Contributor Rewards"
	desc = "A whole host of things and buttons to reward you for contributing!"
	required_medal = "Contributor"
	once_per_round = 0
	mobonly = 0

	rewardActivate(mob/user)
		ui_interact(user)
		return 1

	/// [name, desc, callback]
	var/contrib_rewards = list(
		list("Silly Screams", "Crazy silly screams for your character!", PROC_REF(sillyscream)),
	)

	ui_state(mob/user)
		. = tgui_always_state

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ContributorRewards")
			ui.open()

	ui_static_data(mob/user)
		var/titles = list()
		var/descs = list()
		for (var/reward in contrib_rewards)
			titles += reward[1]
			descs += reward[2]
		. = list(
			"rewardTitles" = titles,
			"rewardDescs" = descs,
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return

		switch(action)
			if("redeem")
				var/reward_idx = text2num(params["reward_idx"])
				INVOKE_ASYNC(src, contrib_rewards[reward_idx][3], ui.user)

	proc/sillyscream(mob/M)
		var/mob/living/living = M
		if(istype( living ))
			living.sound_scream = pick('sound/voice/screams/sillyscream1.ogg','sound/voice/screams/sillyscream2.ogg')
			M.client << sound( living.sound_scream )
			return 1
		else
			boutput( usr, "<span class='alert'>Hmm.. I can't set the scream sound of that!</span>" )
			return 0

/// Keeps track of once-per-round rewards
/datum/player/var/list/claimed_rewards = list()

/client/verb/claimreward()
	set background = 1
	set name = "Claim Reward"
	set desc = "Allows you to claim rewards you might have earned."
	set category = "Commands"
	set popup_menu = 0

	SPAWN(0)
		src.verbs -= /client/verb/claimreward
		boutput(usr, "<span class='alert'>Checking your eligibility. There might be a short delay, please wait.</span>")
		var/list/eligible = list()
		for(var/A in rewardDB)
			var/datum/achievementReward/D = rewardDB[A]
			var/result = usr.has_medal(D.required_medal)
			if(result == 1)
				if((D.once_per_round && !src.player.claimed_rewards.Find(D.type)) || !D.once_per_round)
					if( D.mobonly && !istype( src.mob, /mob/living ) ) continue
					eligible.Add(D.title)
					eligible[D.title] = D

		if(!length(eligible))
			boutput(usr, "<span class='alert'>Sorry, you don't have any rewards available.</span>")
			src.verbs += /client/verb/claimreward
			return

		var/selection = tgui_input_list(usr,"Please select your reward", "VIP Rewards", (eligible + "CANCEL"))

		if(!selection || selection == "CANCEL")
			src.verbs += /client/verb/claimreward
			return

		var/datum/achievementReward/S = null

		for(var/X in rewardDB)
			var/datum/achievementReward/C = rewardDB[X]
			if(C.title == selection)
				S = C
				break

		if(S == null)
			boutput(usr, "<span class='alert'>Invalid Rewardtype after selection. Please inform a coder.</span>")
			return

		if(S.once_per_round && src.player.claimed_rewards.Find(S.type))
			boutput(usr, "<span class='alert'>You already claimed this!</span>")
			return

		var/confirm = tgui_alert(usr, S.desc + "\n(Earned through the \"[S.required_medal]\" Medal)", "Claim this Reward?", list("Yes", "No"))
		src.verbs += /client/verb/claimreward
		if(confirm == "Yes")
			var/worked = S.rewardActivate(src.mob)
			if (worked)
				boutput(usr, "<span class='alert'>Successfully claimed \"[S.title]\".</span>")
				if(S.once_per_round)
					src.player.claimed_rewards.Add(S.type)
			else
				boutput(usr, "<span class='alert'>Redemption of \"[S.title]\" failed.</span>")
