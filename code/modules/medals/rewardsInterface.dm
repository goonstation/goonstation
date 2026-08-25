/datum/medal_rewards
	/// Generate the medal data itself once then never again. Availability per medal determined independently.
	var/list/reward_data = list()
	/// Only refresh availability when the user earns a medal or manually refreshes the menu.
	var/list/cached_eligibility_by_ckey = list()

/datum/medal_rewards/ui_state(mob/user)
	return tgui_always_state.can_use_topic(src, user)

/datum/medal_rewards/ui_status(mob/user, datum/ui_state/state)
	return tgui_always_state.can_use_topic(src, user)

/datum/medal_rewards/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "MedalRewards")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/medal_rewards/ui_static_data(mob/user)
	if(!length(src.reward_data))
		src.generate_reward_data()
	return list("rewards" = src.reward_data)

/datum/medal_rewards/proc/generate_reward_data()
	src.reward_data = list()
	for(var/reward_type in global.rewardDB)
		var/datum/achievementReward/reward = rewardDB[reward_type]
		src.reward_data += list(list(
			"type" = reward_type,
			"title" = reward.title,
			"desc" = reward.desc,
		))

/datum/medal_rewards/ui_data(mob/user)
	. = list()
	.["eligible_rewards"] = src.get_user_eligible_medals(user)

/datum/medal_rewards/proc/get_user_eligible_medals(var/mob/user)
	if(user.ckey in src.cached_eligibility_by_ckey)
		return src.cached_eligibility_by_ckey[user.ckey]
	boutput(user, SPAN_ALERT("Checking your eligibility. There might be a short delay, please wait."))
	var/list/eligible = list()
	for(var/reward_type in global.rewardDB)
		var/datum/achievementReward/reward = global.rewardDB[reward_type]
		if(!src.user_eligibile_for(user, reward))
			continue
		eligible += reward_type
	src.cached_eligibility_by_ckey[user.ckey] = eligible
	return src.cached_eligibility_by_ckey[user.ckey]

/datum/medal_rewards/proc/user_eligibile_for(var/mob/user, var/datum/achievementReward/reward)
	if(!user?.ckey || !istype(reward)) return FALSE
	if(!user.has_medal(reward.required_medal)) return FALSE //Handles our lagcheck. //TODO: Check if not SPAWNing this breaks everything
	if(reward.once_per_round && user.mind.get_player().claimed_rewards.Find(reward.type)) return FALSE
	if(reward.mobonly && !isliving(user)) return FALSE
	return TRUE

/// Keeps track of once-per-round rewards
/datum/player/var/list/claimed_rewards = list()

/client/verb/claimreward()
	set background = 1
	set name = "Claim Reward"
	set desc = "Allows you to claim rewards you might have earned."
	set category = "Commands"
	set popup_menu = 0

	SPAWN(0)
		if (!src.authenticated)
			boutput(usr, SPAN_ALERT("You need to be authenticated to claim rewards."))
			return

		get_singleton(/datum/medal_rewards).ui_interact(src.mob)

/*
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
			boutput(usr, SPAN_ALERT("Invalid Rewardtype after selection. Please inform a coder."))
			return

		if(S.once_per_round && src.player.claimed_rewards.Find(S.type))
			boutput(usr, SPAN_ALERT("You already claimed this!"))
			return

		var/confirm = tgui_alert(usr, S.desc + "\n(Earned through the \"[S.required_medal]\" Medal)", "Claim this Reward?", list("Yes", "No"))
		src.verbs += /client/verb/claimreward
		if(confirm == "Yes")
			var/worked = S.rewardActivate(src.mob)
			if (worked)
				boutput(usr, SPAN_ALERT("Successfully claimed \"[S.title]\"."))
				if(S.once_per_round)
					src.player.claimed_rewards.Add(S.type)
			else
				boutput(usr, SPAN_ALERT("Redemption of \"[S.title]\" failed."))
*/
