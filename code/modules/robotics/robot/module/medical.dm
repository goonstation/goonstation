/obj/item/robot_module/medical
	name = "medical cyborg module"
	desc = "Incorporates medical tools intended for use to save and preserve human life."
	icon_state = "medical"
	mod_hudicon = "medical"
	included_cosmetic = /datum/robot_cosmetic/medical
	included_tools = /datum/robot/module_tool_creator/recursive/module/medical
	radio_type = /obj/item/device/radio/headset/medical
	mail_groups = list(MGD_MEDICAL, MGJ_ROBOTICS, MGT_SILICON, MGJ_GENETICS, MSG_PARTY_LINE)
	mail_topics = list(MSG_TOPIC_DELIVERY, MSG_TOPIC_RADIO, MSG_TOPIC_DEATH, MSG_TOPIC_CRITICAL, MSG_TOPIC_CLONER, MSG_TOPIC_CRISIS, MSG_TOPIC_SALES)

/datum/robot_cosmetic/medical
	head_mod = "Medical Mirror"
	ches_mod = "Medical Insignia"
	fx = list(0, 255, 0)
	painted = 1
	paint = "#969696"
