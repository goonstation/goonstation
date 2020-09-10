//code\lists\jobs.dm

var/list/xpRewards = list() //Assoc. List of NAME OF XP REWARD : INSTANCE OF XP REWARD DATUM . Contains all rewards.
var/list/xpRewardButtons = list() //Assoc, datum:button obj

mob/verb/checkrewards()
	set name = "Check Job Rewards"
	set category = "Commands"
	var/txt = input(usr, "Which job? (Case sensitive)","Check Job Rewards", src.job)
	if(txt == null || length(txt) == 0) txt = src.job
	showJobRewards(txt)
	return

/proc/showJobRewards(var/job) //Pass in job instead
	SPAWN_DBG(0)
		var/mob/M = usr
		if(job)
			if(!winexists(M, "winjobrewards_[M.ckey]"))
				winclone(M, "winJobRewards", "winjobrewards_[M.ckey]")

			var/list/valid = list()
			for(var/datum/jobXpReward/J in xpRewardButtons) //This could be cached later.
				if(J.required_levels.Find(job))
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
		else
			boutput(M, "<span class='alert'>Woops! That's not a valid job, sorry!</span>")

//Once again im forced to make fucking objects to properly use byond skin stuff.
/obj/jobxprewardbutton
	icon = 'icons/ui/jobxp.dmi'
	icon_state = "?"
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
						if(alert("Would you like to claim this reward?",,"Yes","No") == "Yes")
							if(rewardDatum.claimPerRound > 0)
								if(rewardDatum.claimedNumbers.Find(usr.key) && rewardDatum.claimedNumbers[usr.key] >= rewardDatum.claimPerRound)
									return
							if(rewardDatum.qualifies(usr.key))
								rewardDatum.activate(usr.client)
								if(rewardDatum.claimedNumbers.Find(usr.key))
									rewardDatum.claimedNumbers[usr.key] = (rewardDatum.claimedNumbers[usr.key] + 1)
								else
									rewardDatum.claimedNumbers[usr.key] = 1
							else
								boutput(usr, "<span class='alert'>Looks like you haven't earned this yet, sorry!</span>")
					else
						boutput(usr, "<span class='alert'>Sorry, you can not claim any more of this reward, this round.</span>")
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
	if(xpRewards.Find(name))
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

/datum/jobXpReward/janitor10
	name = "Holographic signs (WIP)"
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

// /datum/jobXpReward/janitor15
// 	name = "Tsunami-P3"
// 	desc = "Gain access to the Tsunami-P3 spray bottle."
// 	required_levels = list("Janitor"=15)
// 	icon_state = "tsunami"
// 	claimable = 1
// 	claimPerRound = 1

// 	activate(var/client/C)
// 		var/obj/item/spraybottle/cleaner/tsunami/T = new/obj/item/spraybottle/cleaner/tsunami()
// 		T.set_loc(get_turf(C.mob))
// 		C.mob.put_in_hand(T)
// 		return

// /datum/jobXpReward/janitor20
// 	name = "Antique Mop"
// 	desc = "Gain access to an ancient mop."
// 	required_levels = list("Janitor"=20)
// 	icon_state = "tsunami"
// 	claimable = 1
// 	claimPerRound = 1

// 	activate(var/client/C)
// 		var/obj/item/mop/old/T = new/obj/item/mop/old()
// 		T.set_loc(get_turf(C.mob))
// 		C.mob.put_in_hand(T)
// 		return

/datum/jobXpReward/janitor20
	name = "(TBI)"
	desc = "(TBI)"
	required_levels = list("Janitor"=20)
	icon_state = "?"

//JANITOR END

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
		var/found = 0
		var/O = locate(sacrifice_path) in C.mob.contents
		if (istype(O, sacrifice_path))
			var/obj/item/gun/energy/E = O
			if (E.cell)
				charge = E.cell.charge
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
		//Don't let em get get a charged power cell for a spent one
		if (charge < 200)
			LG.cell.charge = charge

		LG.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(LG)
		boutput(C.mob, "Your E-Gun vanishes and is replaced with [LG]!")
		C.mob.put_in_hand_or_drop(LGP)
		boutput(C.mob, "<span class='emote'>A pamphlet flutters out.</span>")
		return

/datum/jobXpReward/head_of_security_LG/old
	name = "The Antique Lawbringer"
	desc = "Gain access to a voice activated weapon of the past-future-past by sacrificing your gun of the future-past. I.E. The Lawbringer."
	sacrifice_path = /obj/item/gun/energy/lawbringer
	reward_path = /obj/item/gun/energy/lawbringer/old
	sacrifice_name = "Lawbringer"
	required_levels = list("Head of Security"=5)

//Captain

/datum/jobXpReward/captainsword
	name = "Commander's Sabre"
	desc = "Trade out your energy gun for a cool sword! Swords beat guns, right?"
	required_levels = list("Captain"=0)
	claimable = 1
	claimPerRound = 1
	icon_state = "?"
	var/sacrifice_path = /obj/item/gun/energy/egun
	var/reward_path = /obj/item/katana_sheath/captain
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
			C.mob.remove_item(K)
			found = 1
			qdel(K)
			boutput(C.mob, "Your energy gun morphs into a sword! What the fuck!")
			var/obj/item/katana_sheath/captain/T = new/obj/item/katana_sheath/captain()
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
	var/reward_path = /obj/item/gun/kinetic/colt_saa/detective
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

		var/obj/item/gun/kinetic/colt_saa/colt = new reward_path()
		if (!istype(colt))
			boutput(C.mob, "Something terribly went wrong. The reward path got screwed up somehow. call 1-800-CODER. But you're a detective! You don't need no stinkin' guns anyway!")
			src.claimedNumbers[usr.key] --
			return

		if (tmp_ammo && tmp_current_projectile)
			colt.ammo = tmp_ammo
			colt.current_projectile = tmp_current_projectile
		if (!colt.ammo)
			colt.ammo = new/obj/item/ammo/bullets/a38/stun
		if (!colt.current_projectile)
			colt.current_projectile = new/datum/projectile/bullet/revolver_38/stunners

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
	name = "Nothing!!"
	desc = "Nothing Again Again!!"
	required_levels = list("Clown"=10)
	icon_state = "?"
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		boutput(C, "Nothing seems to happen!")
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
	desc = "Banana, but misspelled!"
	required_levels = list("Clown"=20)
	icon_state = "?"
	claimable = 1
	claimPerRound = 1

	activate(var/client/C)
		boutput(C, "You get a \"banana\"!")
		var/obj/item/banana = null
		if (prob(1))
			banana = new/obj/item/old_grenade/banana()
		else
			banana = new/obj/item/reagent_containers/food/snacks/plant/banana()
		banana.set_loc(get_turf(C.mob))
		C.mob.put_in_hand(banana)
		return
