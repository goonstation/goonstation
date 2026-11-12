//it's time to share your perspective.
/datum/random_event/menhir/resight
	name = "Through Another's Eyes"
	description = "Swaps the eye position of a few people around the station in close proximity to each other (no UI reveal). Less effective in lowpop."
	weight = 70

	event_effect()
		//First verify we have some people to mess with.
		var/list/eligible_examinees = EVENT.MENHIR.FILTER.get_event_candidates(EVENT::MENHIR::FILTER::ON_TURF)
		var/candidate_num = length(eligible_examinees)

		if (candidate_num < 3)
			logTheThing(LOG_STATION, null, "Menhir event [src.name] has inadequate candidates ([candidate_num]/3); skipping event.")
			message_admins("Menhir event [src.name] has inadequate candidates ([candidate_num]/3); skipping event.")
			return

		//And consider how many we'll swap. This is, at most, how many PAIRS of people will have their perspective exchanged.
		var/swapcount = floor(candidate_num/3)
		if (swapcount < 1) //always at least 1 pair
			swapcount = 1

		///String for recording who got swapped
		var/return_string = ""
		for(var/i in 1 to swapcount)
			if(!length(eligible_examinees)) break
			var/mob/candidate_A = pick(eligible_examinees)
			var/mob/candidate_B = null
			eligible_examinees -= candidate_A
			for(var/mob/M in eligible_examinees)
				if(GET_DIST(candidate_A,M) < 9) //we only want to swap people who are in visual range of each other
					candidate_B = M
					eligible_examinees -= M
					break

			if(candidate_A && candidate_B)
				SPAWN(1 SECOND)
					src.perception_swap(candidate_A,candidate_B)
				return_string += "[key_name(candidate_A)] and [key_name(candidate_B)]"
				if(i < swapcount) return_string += " | "

		message_delay = rand(18 SECONDS, 24 SECONDS)
		..()

		logTheThing(LOG_STATION, null, "Menhir event [src.name] - perceptions swapped: [return_string]")
		message_admins("Menhir event [src.name] - perceptions swapped: [return_string]")

	proc/perception_swap(var/mob/swapped_A,var/mob/swapped_B)
		var/swap_duration = rand(40 SECONDS,50 SECONDS)
		swapped_A.set_eye(swapped_B)
		swapped_B.set_eye(swapped_A)
		SPAWN(1)
			swapped_A.playsound_local_not_inworld('sound/musical_instruments/artifact/Artifact_Precursor_5.ogg', 55, 0, pitch = 0.45)
			swapped_B.playsound_local_not_inworld('sound/musical_instruments/artifact/Artifact_Precursor_5.ogg', 55, 0, pitch = 0.45)
		sleep(swap_duration)
		if(swapped_A) swapped_A.set_eye(null)
		if(swapped_B) swapped_B.set_eye(null)
