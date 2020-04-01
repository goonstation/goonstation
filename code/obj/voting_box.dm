/obj/voting_box
	name = "voting machine"
	icon = 'icons/obj/32x64.dmi'
	icon_state = "voting_box"
	density = 1
	flags = FPRINT
	anchored = 1.0
	desc = "Some sort of thing to put ballots into. Maybe you can even vote with it!"
	var/bribeAmount = 0
	var/bribeJerk = null

	get_desc()
		. = ..()
		if (bribeAmount > 0)
			. += "<br>Looks like some jerk spent [bribeAmount] credits to buy a vote."

	attack_hand(mob/user as mob)
		src.add_fingerprint(user)

		var/client/C = user.client
		if (!C) return

		if (mapSwitcher.playersVoting)
			var/hadVoted = mapSwitcher.playerVotes[C.ckey] ? 1 : 0
			var/map = mapSwitcher.showMapVote(C)
			if (map)
				var/adv = pick("", "proudly", "confidently", "cautiously", "dismissively", "carelessly", "idly")
				var/adj = pick("", "questionable", "decisive", "worthless", "important", "curious", "bizarre", "regrettable")
				visible_message(__blue("<strong>[user]</strong> [adv] [hadVoted ? "changes their" : "casts a"] [adj] vote [hadVoted ? "to" : "for"] <strong>[map]</strong>."))
				playsound(src.loc, "sound/machines/ping.ogg", 35)

				if (!hadVoted)
					var/obj/item/sticker = new /obj/item/sticker/ribbon/voter(get_turf(user))
					sticker.layer = src.layer += 0.1
					user.put_in_hand_or_eject(sticker)
					boutput(user, __blue("\The [src] dispenses \an [sticker] as a reward for doing your civic duty."))
		else
			boutput(user, __blue("There's no vote going on right now."))


	attackby(obj/item/S as obj, mob/user as mob)
		src.add_fingerprint(user)

		if (istype(S, /obj/item/spacecash))
			if (!mapSwitcher.playersVoting)
				boutput(user, __red("There's no point in buying a vote when there's no vote going on."))
				return

			var/client/C = user.client
			if (!C)
				return	// how the hell did you even get here.

			if (user.real_name == bribeJerk)
				// increase paid amount here
				bribeAmount += S.amount
				visible_message("<strong>[user] increases their bribe to [bribeAmount] credits!</strong>")

			if (S.amount <= bribeAmount && user.real_name != bribeJerk)
				// Someone already gave us a better bribe
				boutput(user, __red("If you want this machine to vote for your map, you need to pay more than [bribeJerk]'s [bribeAmount] credits."))
				return

			if (S.amount > bribeAmount)
				if (mapSwitcher.playerVotes[C.ckey])
					// time to switch our vote.
					bribeAmount = S.amount
					bribeJerk = user.real_name
					mapSwitcher.playerVotes["\ref[src]"] = mapSwitcher.playerVotes[C.ckey]
					visible_message("<strong>[user] has paid [S.amount] credits to swing the map vote in their favor!</strong>")
					boutput(user, __blue("You've puchased a vote for [mapSwitcher.playerVotes[C.ckey]]."))

				else
					boutput(user, __red("You can't buy a vote when you haven't voted, doofus."))
					return

			S.amount = 0
			user.u_equip(S)
			S.dropped()
			pool( S )
			animate_storage_rustle(src)
			playsound(src.loc, "sound/machines/ping.ogg", 75)
			SPAWN_DBG(1 SECOND)
				playsound(src.loc, "sound/machines/paper_shredder.ogg", 90, 1)
			return


		var/obj/item/paper/P = S
		if (istype(P) && !istype(P, /obj/item/paper/book))
			src.visible_message("<span>[user] casts a worthless ballot into [src.name] and it emits a buzzing sound.</span>")
			playsound(src.loc, "sound/machines/paper_shredder.ogg", 50, 1)
			animate_storage_rustle(src)
			user.u_equip(P)
			pool(P)
			return
		..()
