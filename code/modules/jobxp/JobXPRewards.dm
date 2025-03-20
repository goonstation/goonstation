//code\lists\jobs.dm

var/list/xpRewards = list() //Assoc. List of NAME OF XP REWARD : INSTANCE OF XP REWARD DATUM . Contains all rewards.
var/list/xpRewardButtons = list() //Assoc, datum:button obj

mob/verb/checkrewards()
	set name = "Check Job Rewards"
	set category = "Commands"

	if(isdead(usr))
		boutput(usr, SPAN_NOTICE("You can't claim rewards while dead!"))
		return

	SPAWN(0)
		var/mob/M = usr
		if(!winexists(M, "winjobrewards_[M.ckey]"))
			winclone(M, "winJobRewards", "winjobrewards_[M.ckey]")

		var/list/valid = list()
		for(var/datum/jobXpReward/J in xpRewardButtons) //This could be cached later.
			if(job in J.required_levels)
				valid.Add(J)
				valid[J] = xpRewardButtons[J]

		if(valid.len)
			winset(M, "winjobrewards_[M.ckey].grdJobRewards", "cells=\"1x[valid.len]\"")
			var/count = 0
			for(var/S in valid)
				winset(M, "winjobrewards_[M.ckey].grdJobRewards", "current-cell=1,[++count]")
				M << output(valid[S], "winjobrewards_[M.ckey].grdJobRewards")
			winset(M, "winjobrewards_[M.ckey].lblJobName", "text=\"Job rewards for '[job]', Lvl [get_level(M.key, job)]\"")
		else
			winset(M, "winjobrewards_[M.ckey].grdJobRewards", "cells=\"1x0\"")
			winset(M, "winjobrewards_[M.ckey].lblrewarddesc", "text=\"Sorry nothing.\"")
			winset(M, "winjobrewards_[M.ckey].lblJobName", "text=\"Sorry there's no rewards for the [job] yet :(\"")
		winshow(M, "winjobrewards_[M.ckey]")

//Once again im forced to make fucking objects to properly use byond skin stuff.
/obj/jobxprewardbutton
	icon = 'icons/ui/jobxp.dmi'
	icon_state = "?"
	flags = NOSPLASH
	var/datum/jobXpReward/rewardDatum = null

	Click(location,control,params)
		if(control && rewardDatum)
			if(control == "winjobrewards_[usr.ckey].grdJobRewards")
				if(rewardDatum.claimable && (usr.job in rewardDatum.required_levels) && rewardDatum.qualifies(usr.key)) //Check for number of claims.
					var/claimsLeft = 1
					if(rewardDatum.claimPerRound > 0)
						if(rewardDatum.claimedNumbers.Find(usr.key) && rewardDatum.claimedNumbers[usr.key] >= rewardDatum.claimPerRound)
							claimsLeft = 0
					if(claimsLeft)
						if(tgui_alert(usr, "Would you like to claim this reward?", "Claim reward", list("Yes", "No")) == "Yes")
							if(rewardDatum.claimPerRound > 0)
								if(rewardDatum.claimedNumbers.Find(usr.key) && rewardDatum.claimedNumbers[usr.key] >= rewardDatum.claimPerRound)
									return
							if(rewardDatum.qualifies(usr.key))
								rewardDatum.activate(usr.client)
								if(usr.key in rewardDatum.claimedNumbers)
									rewardDatum.claimedNumbers[usr.key] = (rewardDatum.claimedNumbers[usr.key] + 1)
								else
									rewardDatum.claimedNumbers[usr.key] = 1
							else
								boutput(usr, SPAN_ALERT("Looks like you haven't earned this yet, sorry!"))
					else
						boutput(usr, SPAN_ALERT("Sorry, you can not claim any more of this reward, this round."))
		return

	MouseEntered(location,control,params)
		if(winexists(usr, "winjobrewards_[usr.ckey]"))
			var/str = ""
			for(var/X in rewardDatum.required_levels)
				str += "[X] [rewardDatum.required_levels[X]],"
			str = copytext(str,1,length(str))
			winset(usr, "winjobrewards_[usr.ckey].lblrewarddesc", "text=\"[rewardDatum.desc] | Required levels: [str]\"")
		return

/proc/qualifiesXpByName(var/key, var/name)
	if(name in xpRewards)
		var/datum/jobXpReward/R = xpRewards[name]
		if(R.qualifies(key))
			return 1
	return 0

/datum/jobXpReward
	//TBI: Icons, XP reward tree overview.
	var/name = "" //Also used in the trait unlock checks. Make sure theres no duplicate names.
	var/desc = ""
	var/list/required_levels = list("Clown"=999) //Associated List of JOB:REQUIRED LEVEL. Affects visibility in jobxp rewards screen
	var/icon_state = "?"
	var/claimPerRound = -1 //How often can this be used per round. <0 = infinite
	var/claimable = 0 //Can this actively be claimed? (1) or is it a passive thing that is checked elsewhere (0)
	var/list/claimedNumbers = list() //Assoc list, key:numclaimed

	proc/qualifies(var/key)
		var/pass = 1
		for(var/X in required_levels)
			var/level = get_level(key, X)
			if(level < required_levels[X])
				pass = 0
		return pass

	proc/activate(var/client/C)
		return

//JANITOR

/datum/jobXpReward/janitor5
	name = "Red Bucket"
	desc = "A bucket! And it's red! Wow."
	required_levels = list("Janitor"=5)
	claimable = 1
	var/path_to_spawn = /obj/item/reagent_containers/glass/bucket/red

	activate(var/client/C)
		var/obj/item/reagent_containers/glass/bucket/bucket = locate(/obj/item/reagent_containers/glass/bucket) in C.mob.contents

		if (istype(bucket))
			C.mob.remove_item(bucket)
			qdel(bucket)
		else
			boutput(C.mob, "You need to be holding a bucket in order to claim this reward")
			return
		var/obj/item/I = new path_to_spawn()
		I.set_loc(get_turf(C.mob))
		C.mob.put_in_hand_or_drop(I)
		boutput(C.mob, "You turn around for just a second and your bucket is suddenly all red!")

/datum/jobXpReward/janitor10
	name = "Holographic Signs "
	desc = "Gives access to a hologram emitter loaded with various signs."
	required_levels = list("Janitor"=10)
	icon_state = "holo"
	claimable = 1
	claimPerRound = 5

	activate(var/client/C)
		var/obj/item/holoemitter/T = new/obj/item/holoemitter(get_turf(C.mob))
		T.ownerKey = C.key
		T.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(T)
		return

/datum/jobXpReward/janitor15
	name = "Orange Mop"
	desc = "A mop! And it's orange! Amazing."
	required_levels = list("Janitor"=15)
	claimable = 1
	var/path_to_spawn = /obj/item/mop/orange

	activate(var/client/C)
		var/obj/item/mop/mop = locate(/obj/item/mop/) in C.mob.contents

		if (istype(mop))
			C.mob.remove_item(mop)
			qdel(mop)
		else
			boutput(C.mob, "You need to be holding a mop in order to claim this reward")
			return
		var/obj/item/I = new path_to_spawn()
		I.set_loc(get_turf(C.mob))
		C.mob.put_in_hand_or_drop(I)
		boutput(C.mob, "An orange shade starts to crawl all over the mop's head.")

/datum/jobXpReward/janitor20
	name = "Head of Sanitation beret"
	desc = "You've seen it all.  You've seen entirely too much. Was it worth it? Maybe this hat will help you forget..."
	required_levels = list("Janitor"=20)
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		var/obj/item/clothing/head/janiberet/T = new/obj/item/clothing/head/janiberet(get_turf(C.mob))
		T.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(T)
		return

//JANITOR END

//BOTANIST

/datum/jobXpReward/botanist/seed
	name = "Strange Seed"
	desc = "You notice a strange looking seed and grab it instinctually before you realize what happened."
	required_levels = list("Botanist"=0)
	icon_state
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		var/obj/item/seed/alien/S = new/obj/item/seed/alien(get_turf(C.mob))
		S.set_loc(get_turf(C.mob))
		C.mob.put_in_hand_or_drop(S)
		return

/datum/jobXpReward/botanist/wateringcan
	name = "Golden Watering Can"
	desc = "A Golden Watering can. Seems the same as normal otherwise..."
	required_levels = list("Botanist"=3)
	icon_state = "?"
	claimable = 1
	claimPerRound = 1
	var/path_to_spawn = /obj/item/reagent_containers/glass/wateringcan/gold

	activate(var/client/C)
		var/obj/item/reagent_containers/glass/wateringcan/can = locate(/obj/item/reagent_containers/glass/wateringcan) in C.mob.contents

		if (istype(can))
			C.mob.remove_item(can)
			qdel(can)
		var/obj/item/I = new path_to_spawn()
		I.set_loc(get_turf(C.mob))
		C.mob.put_in_hand_or_drop(I)
		boutput(C.mob, "You blink and your watering can seems different...")

/datum/jobXpReward/botanist/apron
	name = "Blue apron"
	desc = "An apron to protect yourself from any workplace spills and messes."
	required_levels = list("Botanist"=5)
	icon_state
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		boutput(C, "The apron pops into existance!")
		var/obj/item/I = new/obj/item/clothing/suit/apron/botanist()
		I.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(I)
		return

/datum/jobXpReward/botanist/wateringcan/weed
	name = "Weed Watering Can"
	desc = "A Watering can with the likeness of a certain plant on it. Seems the same as normal otherwise..."
	required_levels = list("Botanist"=8)
	path_to_spawn = /obj/item/reagent_containers/glass/wateringcan/weed

/datum/jobXpReward/botanist/wateringcan/rainbow
	name = "Rainbow Watering Can"
	desc = "A Watering can that looks like it's made of rainbows... sorta. Seems the same as normal otherwise..."
	required_levels = list("Botanist"=10)
	path_to_spawn = /obj/item/reagent_containers/glass/wateringcan/rainbow

/datum/jobXpReward/botanist/jumpsuit
	name = "Senior Botanist Jumpsuit"
	desc = "An old jumpsuit with an earthy smell to it."
	required_levels = list("Botanist"=15)
	icon_state = "?"
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		boutput(C, SPAN_HINT("The jumpsuit pops into existance!"))
		var/obj/item/I = new /obj/item/clothing/under/misc/hydroponics(get_turf(C.mob))
		C.mob.put_in_hand(I)

/datum/jobXpReward/botanist/wateringcan/old
	name = "Antique Watering Can"
	desc = "A Watering can that looks like it's made of rainbows... sorta. Seems the same as normal otherwise..."
	required_levels = list("Botanist"=20)
	path_to_spawn = /obj/item/reagent_containers/glass/wateringcan/old



//Botanist End

/datum/jobXpReward/HeadofSecurity/mug
	name = "Alternate Blue Mug"
	desc = "It's your favourite coffee mug, but now its text is blue. Wow."
	required_levels = list("Head of Security"=0)
	claimable = 1
	var/path_to_spawn = /obj/item/reagent_containers/food/drinks/mug/HoS/blue

	activate(var/client/C)
		var/mug = C.mob.find_type_in_hand(/obj/item/reagent_containers/food/drinks/mug/HoS)

		if (mug)
			C.mob.remove_item(mug)
			qdel(mug)
		else
			boutput(C.mob, "You need to be holding your mug in order to claim this reward")
			return
		var/obj/item/I = new path_to_spawn()
		I.set_loc(get_turf(C.mob))
		C.mob.put_in_hand_or_drop(I)
		boutput(C.mob, "The mug's colouring flips to blue")

/datum/jobXpReward/head_of_security_LG
	name = "The Lawbringer"
	desc = "Gain access to a voice activated weapon of the future-past by sacrificing your egun."
	required_levels = list("Head of Security"=0)
	claimable = 1
	claimPerRound = 1
	icon_state = "?"
	var/sacrifice_path = /obj/item/gun/energy/egun 		//Don't go lower than obj/item/gun/energy/egun
	var/reward_path = /obj/item/gun/energy/lawbringer
	var/sacrifice_name = "E-Gun"

	activate(var/client/C)
		var/charge = 0
		var/max_charge = 0
		var/found = 0
		var/O = locate(sacrifice_path) in C.mob.contents
		if (istype(O, sacrifice_path))
			var/obj/item/gun/energy/E = O
			var/list/ret = list()
			if(SEND_SIGNAL(E, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
				charge = ret["charge"]
				max_charge = ret["max_charge"]
			C.mob.remove_item(E)
			found = 1
			qdel(E)

		if (!found)
			boutput(C.mob, "You need to be holding a [sacrifice_name] in order to claim this reward.")
			//Remove used from list of claimed. I'll make this more elegant once I understand it all. No time for it now. -Kyle
			src.claimedNumbers[usr.key] --
			return

		var/obj/item/gun/energy/lawbringer/LG = new reward_path()
		var/obj/item/paper/lawbringer_pamphlet/LGP = new/obj/item/paper/lawbringer_pamphlet()
		if (!istype(LG))
			boutput(C.mob, "Something terribly went wrong. The reward path got screwed up somehow. call 1-800-CODER. But you're an HoS! You don't need no stinkin' guns anyway!")
			src.claimedNumbers[usr.key] --
			return
		//Don't let em get get a charged power cell for a spent one. Spend the difference
		SEND_SIGNAL(LG, COMSIG_CELL_USE, max_charge - charge)

		LG.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(LG)
		boutput(C.mob, "Your E-Gun vanishes and is replaced with [LG]!")
		LG.assign_name(C.mob)
		C.mob.put_in_hand_or_drop(LGP)
		boutput(C.mob, SPAN_EMOTE("A pamphlet flutters out."))
		return

//Captain

/datum/jobXpReward/captainsword
	name = "Commander's Sabre"
	desc = "Trade out your energy gun for a cool sword! Swords beat guns, right?"
	required_levels = list("Captain"=0)
	claimable = 1
	claimPerRound = 1
	icon_state = "?"
	var/sacrifice_path = /obj/item/gun/energy/egun
	var/reward_path = /obj/item/swords_sheaths/captain
	var/sacrifice_name = "E-Gun"

	activate(var/client/C)
		var/found = 0
		var/O = locate(sacrifice_path) in C.mob.contents
		if (istype(O, sacrifice_path))
			var/obj/item/gun/energy/egun/K = O
			if (K.nojobreward) // Checks to see if it was scanned by a device analyzer
				boutput(C.mob, "This [sacrifice_name] has forever been ruined by a device analyzer's magnets. It can't turn into a sword ever again!!")
				src.claimedNumbers[usr.key] --
				return
			if (K.deconstruct_flags & DECON_BUILT) //Checks to see if it was built from a frame
				boutput(C.mob, "This [sacrifice_name] is a replica and cannot be turned into a sword legally! Only an original, unscanned energy gun will work for this!")
				src.claimedNumbers[usr.key] --
				return
			var/list/ret = list()
			if(SEND_SIGNAL(K, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
				var/ratio = min(1, ret["charge"] / ret["max_charge"])
				if (ratio < 0.9)
					boutput(C.mob, "The [sacrifice_name] is depleted, you'll need to charge it up first!")
					src.claimedNumbers[usr.key]--
					return
			else
				boutput(C.mob, "The [sacrifice_name] has no cell, you'll need to provide one first!")
				src.claimedNumbers[usr.key]--
				return

			C.mob.remove_item(K)
			found = 1
			qdel(K)
			boutput(C.mob, "Your energy gun morphs into a sword! What the fuck!")
			var/obj/item/swords_sheaths/captain/T = new/obj/item/swords_sheaths/captain()
			T.set_loc(get_turf(C.mob))
			C.mob.put_in_hand(T)
			return

		if (!found)
			boutput(C.mob, "You need to be holding an [sacrifice_name] in order to claim this reward.")
			src.claimedNumbers[usr.key] --
			return

//Detective

/datum/jobXpReward/detective
	name = "The Colt"
	desc = "Gain access to an old-ish replica of an old gun by sacrificing your revolver."
	required_levels = list("Detective"=0)
	claimable = 1
	claimPerRound = 1
	icon_state = "?"
	var/sacrifice_path = /obj/item/gun/kinetic/detectiverevolver
	var/reward_path = /obj/item/gun/kinetic/single_action/colt_saa/detective
	var/sacrifice_name = ".38 revolver"

	activate(var/client/C)
		var/found = 0
		var/tmp_ammo = null
		var/tmp_current_projectile = null

		var/O = locate(sacrifice_path) in C.mob.contents
		if (istype(O, sacrifice_path))
			var/obj/item/gun/kinetic/K = O
			tmp_ammo = K.ammo
			tmp_current_projectile = K.current_projectile
			C.mob.remove_item(K)
			found = 1
			qdel(K)

		if (!found)
			boutput(C.mob, "You need to be holding a [sacrifice_name] in order to claim this reward.")
			//Remove used from list of claimed. I'll make this more elegant once I understand it all. No time for it now. -Kyle
			src.claimedNumbers[usr.key] --
			return

		var/obj/item/gun/kinetic/single_action/colt_saa/colt = new reward_path()
		if (!istype(colt))
			boutput(C.mob, "Something terribly went wrong. The reward path got screwed up somehow. call 1-800-CODER. But you're a detective! You don't need no stinkin' guns anyway!")
			src.claimedNumbers[usr.key] --
			return

		if (tmp_ammo && tmp_current_projectile)
			colt.ammo = tmp_ammo
			colt.set_current_projectile(tmp_current_projectile)
		if (!colt.ammo)
			colt.ammo = new/obj/item/ammo/bullets/a38/stun
		if (!colt.current_projectile)
			colt.set_current_projectile(new/datum/projectile/bullet/revolver_38/stunners)

		colt.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(colt)
		boutput(C.mob, "Your revolver vanishes and is replaced with [colt]!")
		return

/datum/jobXpReward/detectivenoirglasses
	name = "Noir-Tech Glasses"
	desc = "Gain access to a pair of glasses that replicates monochromia."
	required_levels = list("Detective"=0)
	claimable = 1
	claimPerRound = 1
	icon_state = "?"

	activate(var/client/C)
		var/obj/item/clothing/glasses/noir/T = new/obj/item/clothing/glasses/noir()
		T.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(T)
		return

/datum/jobXpReward/security2
	name = " (TBI)"
	desc = ""
	required_levels = list("Security Officer"=999)
	icon_state = "?"

/datum/jobXpReward/security5
	name = " (TBI)"
	desc = ""
	required_levels = list("Security Officer"=999)
	icon_state = "?"

/datum/jobXpReward/security10
	name = " (TBI)"
	desc = ""
	required_levels = list("Security Officer"=999)
	icon_state = "?"

/datum/jobXpReward/security15
	name = " (TBI)"
	desc = ""
	required_levels = list("Security Officer"=999)
	icon_state = "?"

/datum/jobXpReward/security20
	name = " (TBI)"
	desc = ""
	required_levels = list("Security Officer"=999)
	icon_state = "?"

/////////////CLOWN////////////////
/datum/jobXpReward/clown1
	name = "Special Crayon"
	desc = "Spin it and watch it work its \"Magic\"!"
	required_levels = list("Clown"=1)
	icon_state = "?"
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		boutput(C, "You pull your special crayon out from your special place!")
		var/obj/item/I = new/obj/item/pen/crayon/random/choose()
		I.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(I)
		return

/datum/jobXpReward/clown5
	name = "Clown Box"
	desc = "It's a really cool box."
	required_levels = list("Clown"=5)
	icon_state = "?"
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		boutput(C, "You pull your clown box out from your - wait, what?")
		new /obj/item/clothing/suit/cardboard_box/colorful/clown(get_turf(C.mob))
		return

/datum/jobXpReward/clown10
	name = "Rubber Hammer"
	desc = "Haha, hammer go 'boing'"
	required_levels = list("Clown"=10)
	icon_state = "?"
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		boutput(C, "You pull your rubber hammer out from your nose!")
		new /obj/item/rubber_hammer(get_turf(C.mob))
		return

/datum/jobXpReward/clown15
	name = "Nothing!!!"
	desc = "Nothing Again Again Again!!!"
	required_levels = list("Clown"=15)
	icon_state = "?"
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		boutput(C, "Nothing seems to happen!")
		return

/datum/jobXpReward/clown20
	name = "Bananna"
	desc = "Bananna, but misspelled!"
	required_levels = list("Clown"=20)
	icon_state = "?"
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		boutput(C, "You get a \"banana\"!")
		var/obj/item/banana = null
		if (prob(1))
			banana = new/obj/item/old_grenade/spawner/banana()
		else
			banana = new/obj/item/reagent_containers/food/snacks/plant/banana()
		banana.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(banana)

/////////////Bartender////////////////

/datum/jobXpReward/bartender/spectromonocle
	name = "Spectroscopic Monocle"
	desc = "Now you can look dapper and know which drinks you poisoned at the same time"
	required_levels = list("Bartender"=5)
	icon_state = "?"
	claimable = 1
	var/path_to_spawn = /obj/item/clothing/glasses/spectro/monocle

	activate(var/client/C)
		var/glasses = C.mob.find_type_in_hand(/obj/item/clothing/glasses/spectro)

		if(!(glasses))
			boutput(C.mob, "You need to be holding a pair of spectroscopic scanner goggles to claim this item")
			return
		C.mob.remove_item(glasses)
		qdel(glasses)
		var/obj/item/I = new path_to_spawn()
		I.set_loc(get_turf(C.mob))
		C.mob.put_in_hand_or_drop(I)
		boutput(C.mob, "You break the goggles in half and fashion the lens into a monocle...somehow.")

/datum/jobXpReward/bartender/goldenshaker
	name = "Golden Cocktail Shaker"
	desc = "After all your years of service, you've finally managed to gather enough money in tips to buy yourself a present! You regret every cent."
	required_levels = list("Bartender"=20)
	icon_state = "?"
	claimable = 1
	claimPerRound = 1
	var/path_to_spawn = /obj/item/reagent_containers/food/drinks/cocktailshaker/golden

	activate(var/client/C)
		var/obj/item/reagent_containers/food/drinks/cocktailshaker/shaker = locate(/obj/item/reagent_containers/food/drinks/cocktailshaker) in C.mob.contents

		if(!istype(shaker))
			return
		C.mob.remove_item(shaker)
		qdel(shaker)
		var/obj/item/I = new path_to_spawn()
		I.set_loc(get_turf(C.mob))
		C.mob.put_in_hand_or_drop(I)
		boutput(C.mob, "You look away for a second and the shaker turns into golden from top to bottom!")

/////////////Chef////////////////

/datum/jobXpReward/chefitamae
	name = "Sushi Chef Outfit"
	desc = "Om nom nom mmmm I love sushi"
	required_levels = list("Chef"=0)
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		var/obj/item/clothing/head/itamaehat/H = new/obj/item/clothing/head/itamaehat(get_turf(C.mob))
		var/obj/item/clothing/under/misc/itamae/U = new/obj/item/clothing/under/misc/itamae(get_turf(C.mob))
		H.set_loc(get_turf(C.mob))
		U.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(H)
		C.mob.put_in_hand(U)
		boutput(C.mob, "You look down and notice that a whole sushi chef outfit has materialized in your hands! What on earth?")
		return

/datum/jobXpReward/chefhattall
    name = "Tall Chef Hat"
    desc = "Your iconic toque blanche but tall!"
    required_levels = list("Chef"=2)
    claimable = 1
    var/path_to_spawn = /obj/item/clothing/head/chefhattall

    activate(var/client/C)
        var/obj/item/clothing/head/chefhat/chefhat = locate(/obj/item/clothing/head/chefhat) in C.mob.contents

        if (istype(chefhat))
            C.mob.remove_item(chefhat)
            qdel(chefhat)
        else
            boutput(C.mob, "You need to be holding a chef's hat in order to claim this reward")
            return
        var/obj/item/I = new path_to_spawn()
        I.set_loc(get_turf(C.mob))
        C.mob.put_in_hand_or_drop(I)
        boutput(C.mob, "Your chef's hat suddenly elongates before your very eyes!")

/////////////Mime////////////////

/datum/jobXpReward/mime/mimefancy
	name = "Fancy Mime Suit"
	desc = "A suit perfect for more sophisticated mimes. Wait... This isn't just a bleached clown suit, is it?"
	required_levels = list("Mime"=0)
	icon_state = "?"
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		boutput(C, "You pretend to unfold a piece of clothing, and suddenly the Fancy Mime Suit is in your hands!")
		var/obj/item/I = new/obj/item/clothing/under/misc/mimefancy()
		I.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(I)
		return

/datum/jobXpReward/mime/mimedress
	name = "Mime Dress"
	desc = "You may be trapped in an invisible box forever and ever, but at least you look stylish!"
	required_levels = list("Mime"=0)
	icon_state = "?"
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		boutput(C, "You pretend to unfold a piece of clothing, and suddenly the Mime Dress is in your hands!")
		var/obj/item/I = new/obj/item/clothing/under/misc/mimedress()
		I.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(I)
		return

//////////////AI/////////////////

ABSTRACT_TYPE(/datum/jobXpReward/ai)
/datum/jobXpReward/ai
	var/aiskin = "default"
	required_levels = list("AI")
	icon_state = "?"
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		if (isAI(C.mob))
			var/mob/living/silicon/ai/A = C.mob
			if (isAIeye(C.mob))
				var/mob/living/intangible/aieye/AE = C.mob
				A = AE.mainframe
			A.coreSkin = aiskin
			A.update_appearance()
			return 1
		else
			boutput(C, SPAN_ALERT("You need to be an AI to use this, you goof!"))

/datum/jobXpReward/ai/aiframedefault
	name = "AI Core Frame - Standard"
	desc = "Resets your AI core to standard."
	aiskin = "default"

/datum/jobXpReward/ai/aiframent
	name = "AI Core Frame - NanoTrasen"
	desc = "Fancies up your core to show some company spirit!"
	aiskin = "nt"

/datum/jobXpReward/ai/aiframentold
	name = "AI Core Frame - NanoTrasen (Dated)"
	desc = "Fancies up your core to show some company spirit! Now with added dust and eggshell white."
	aiskin = "ntold"

/datum/jobXpReward/ai/aiframegardengear
	name = "AI Core Frame - Hydroponics"
	desc = "Paints your core with the colours of the hydroponics department!"
	aiskin = "gardengear"

/datum/jobXpReward/ai/aiframescience
	name = "AI Core Frame - Research"
	desc = "Paints your core with the colours of the research department!"
	aiskin = "science"

/datum/jobXpReward/ai/aiframemedical
	name = "AI Core Frame - Medical"
	desc = "Paints your core with the colours of the medical department!"
	aiskin = "medical"

/datum/jobXpReward/ai/aiframeengineering
	name = "AI Core Frame - Engineering"
	desc = "Paints your core with the colours of the engineering department!"
	aiskin = "engineering"

/datum/jobXpReward/ai/aiframesecurity
	name = "AI Core Frame - Security"
	desc = "Fancies up your AI core to look all tactical."
	aiskin = "tactical"

/datum/jobXpReward/ai/aiframelgun
	name = "AI Core Frame - Plastic (Pink)"
	desc = "Replaces your AI core with a fancy, child-friendly version."
	aiskin = "lgun"

/datum/jobXpReward/ai/aiframetelegun
	name = "AI Core Frame - Plastic (Blue)"
	desc = "Replaces your AI core with a fancy, child-friendly version."
	aiskin = "telegun"

/datum/jobXpReward/ai/aiframerustic
	name = "AI Core Frame - Rustic"
	desc = "Replaces your AI core with a much, much older model."
	aiskin = "rustic"
