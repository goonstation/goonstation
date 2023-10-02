/obj/item/robot_module/mining
	name = "mining cyborg module"
	desc = "Tools for use in the excavation and transportation of valuable minerals."
	icon_state = "mining"
	mod_hudicon = "mining"
	included_cosmetic = /datum/robot_cosmetic/mining
	included_tools = /datum/robot/module_tool_creator/recursive/module/mining
	radio_type = /obj/item/device/radio/headset/miner
	mail_groups = list(MGJ_MINING, MGJ_CARGO, MGT_SILICON, MSG_PARTY_LINE)
	mail_topics = list(MSG_TOPIC_DELIVERY, MSG_TOPIC_RADIO, MSG_TOPIC_SALES, MSG_TOPIC_SHIPPING, MSG_TOPIC_REQUEST, MSG_TOPIC_DEATH)

/datum/robot_cosmetic/mining
	head_mod = "Hard Hat"
	fx = list(0, 255, 255)
	painted = 1
	paint = "#825A00"
