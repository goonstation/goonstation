/obj/voting_box
	name = "voting machine"
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "voting_box"
	density = 1
	anchored = ANCHORED
	desc = "Some sort of thing to put ballots into. Maybe you can even vote with it!"
	var/bribeAmount = 0
	var/bribeJerk = null

	get_desc()
		. = ..()
		if (bribeAmount > 0)
			. += "<br>Looks like some jerk spent [bribeAmount] credits to buy a vote."

	attack_hand(mob/user)
		src.add_fingerprint(user)

		var/client/C = user.client
		if (!C) return

		if (mapSwitcher.playersVoting)
			var/hadVoted = 0
			var/list/client_vote_map = map_vote_holder.vote_map[C.ckey]
			if (client_vote_map)
				hadVoted = 1

			var/map = input("Your Civic Duty", "Which Map?") as null|anything in (client_vote_map ? client_vote_map : mapSwitcher.playerPickable)
			if (map)
				map_vote_holder.special_vote(C,map)
				var/adv = pick("", "proudly", "confidently", "cautiously", "dismissively", "carelessly", "idly")
				var/adj = pick("", "questionable", "decisive", "worthless", "important", "curious", "bizarre", "regrettable")
				visible_message(SPAN_NOTICE("<strong>[user]</strong> [adv] [hadVoted ? "changes [his_or_her(user)]" : "casts a"] [adj] vote [hadVoted ? "to" : "for"] <strong>[map]</strong>."))
				playsound(src.loc, 'sound/machines/ping.ogg', 35)

				if (user.real_name == bribeJerk)
					map_vote_holder.voting_box(src,map)

				if (!hadVoted)
					var/obj/item/sticker = new /obj/item/sticker/ribbon/voter(get_turf(user))
					sticker.layer = src.layer += 0.1
					user.put_in_hand_or_eject(sticker)
					boutput(user, SPAN_NOTICE("\The [src] dispenses \an [sticker] as a reward for doing your civic duty."))
		else
			boutput(user, SPAN_NOTICE("There's no vote going on right now."))


	attackby(obj/item/S, mob/user)
		src.add_fingerprint(user)

		if (istype(S, /obj/item/currency/spacecash))
			if (!mapSwitcher.playersVoting)
				boutput(user, SPAN_ALERT("There's no point in buying a vote when there's no vote going on."))
				return

			var/client/C = user.client
			if (!C)
				return	// how the hell did you even get here.

			if (S.amount <= bribeAmount && user.real_name != bribeJerk)
				// Someone already gave us a better bribe
				boutput(user, SPAN_ALERT("If you want this machine to vote for your map, you need to pay more than [bribeJerk]'s [bribeAmount] credits."))
				return

			if ((S.amount > bribeAmount) || (user.real_name == bribeJerk))
				var/list/voted_maps = map_vote_holder.get_client_votes(C)
				if(length(voted_maps))
					var/chosen = input("Money Talks", "Which Map?") as null|anything in voted_maps
					if (chosen)
						if (user.real_name == bribeJerk)
							// increase paid amount here
							bribeAmount += S.amount
							visible_message("<strong>[user] increases [his_or_her(user)] bribe to [bribeAmount] credits!</strong>")
						else
							// time to switch our vote.
							visible_message("<strong>[user] has paid [S.amount] credits to swing the map vote in [his_or_her(user)] favor!</strong>")
							boutput(user, SPAN_NOTICE("You've puchased a vote for [chosen]."))
							bribeAmount = S.amount
							bribeJerk = user.real_name
							map_vote_holder.voting_box(src,chosen)
						S.amount = 0
						user.u_equip(S)
						S.dropped(user)
						qdel( S )
						animate_storage_rustle(src)
						playsound(src.loc, 'sound/machines/ping.ogg', 75)
						SPAWN(1 SECOND)
							playsound(src.loc, 'sound/machines/paper_shredder.ogg', 90, 1)
				else
					boutput(user, SPAN_ALERT("You can't buy a vote when you haven't voted, doofus."))
					return
			return


		var/obj/item/paper/P = S
		if (istype(P) && !istype(P, /obj/item/paper/book))
			src.visible_message("<span>[user] casts a worthless ballot into [src.name] and it emits a buzzing sound.</span>")
			playsound(src.loc, 'sound/machines/paper_shredder.ogg', 50, 1)
			animate_storage_rustle(src)
			user.u_equip(P)
			qdel(P)
			return
		..()
