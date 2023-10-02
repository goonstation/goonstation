/obj/item/robot_module/brobocop
	name = "brobocop cyborg module"
	desc = "Become the life of the party, and also the scourge of fun."
	icon_state = "brobocop"
	mod_hudicon = "brobocop"
	included_cosmetic = /datum/robot_cosmetic/brobocop
	included_tools = /datum/robot/module_tool_creator/recursive/module/brobocop
	radio_type = /obj/item/device/radio/headset/security
	mail_groups = list(MGD_SECURITY, MGT_CATERING, MGT_SILICON, MSG_PARTY_LINE)
	mail_topics = list(MSG_TOPIC_DELIVERY, MSG_TOPIC_RADIO, MSG_TOPIC_DEATH, MSG_TOPIC_CHECKPOINT, MSG_TOPIC_ARREST, MSG_TOPIC_CRISIS, MSG_TOPIC_TRACKING)

/datum/robot_cosmetic/brobocop
	head_mod = "Afro and Shades"
	fx = list(90, 0, 90)
	painted = 0
