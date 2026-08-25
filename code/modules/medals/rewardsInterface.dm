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

// Static reward data for all users
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

// Per user data
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
		if(src.user_ineligible_for(user, reward))
			continue
		eligible += reward_type
	src.cached_eligibility_by_ckey[user.ckey] = eligible
	return src.cached_eligibility_by_ckey[user.ckey]

/datum/medal_rewards/proc/user_ineligible_for(var/mob/user, var/datum/achievementReward/reward)
	if(!user?.ckey || !istype(reward)) return "You don't have a ckey or that's not a reward!"
	if(!user.has_medal(reward.required_medal)) return "You do not have the medal required for that reward!" //Handles our lagcheck. //TODO: Check if not SPAWNing this breaks everything
	if(reward.once_per_round && user.mind.get_player().claimed_rewards.Find(reward.type)) return "You can only claim that reward once per round!"
	if(reward.mobonly && !isliving(user)) return "You must be alive to claim that reward!"
	return FALSE

// Redeeming
/datum/medal_rewards/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("redeem")
			src.try_redeem_reward(ui.user, params["reward_type"])

/datum/medal_rewards/proc/try_redeem_reward(var/mob/user, var/reward_type)
	var/datum/achievementReward/reward = global.rewardDB[reward_type] //TODO: reward_type being a string here breaks this
	if(!istype(user) || !istype(reward))
		return
	var/error_text = src.user_ineligible_for(user, reward)
	if(error_text)
		boutput(user, SPAN_ALERT(error_text))
		return
	if(!tgui_confirm(user, "Redeem [reward.title]? \n(Earned through the \"[reward.required_medal]\" Medal)"))
		return
	if (reward.rewardActivate(user))
		boutput(user, SPAN_ALERT("Successfully claimed \"[reward.title]\"."))
		if(reward.once_per_round)
			user.mind.get_player().claimed_rewards.Add(reward_type)
	else
		boutput(user, SPAN_ALERT("Redemption of \"[reward.title]\" failed."))

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
