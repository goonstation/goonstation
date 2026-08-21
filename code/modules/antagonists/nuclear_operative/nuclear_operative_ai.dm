/datum/antagonist/mob/nuclear_operative_ai
	id = ROLE_NUKEOP_AI
	display_name = "Syndicate Mission Control"
	antagonist_icon = "syndcorp"
	remove_on_clone = TRUE
	antagonist_panel_tab_type = /datum/antagonist_panel_tab/bundled/nuclear_operative
	faction = list(FACTION_SYNDICATE)
	mob_path = /mob/living/silicon/ai
	wiki_link = "https://wiki.ss13.co/Nuclear_Operative"
	var/mainframe_antag_image

	New(datum/mind/new_owner)
		src.owner = new_owner
		if (istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/gamemode = ticker.mode
			src.owner.store_memory("The bomb must be armed in <B>[gamemode.concatenated_location_names]</B>.")
			if (!(src.owner in gamemode.syndicates))
				gamemode.syndicates += src.owner

		. = ..()

	give_equipment()
		. = ..()
		SPAWN(0)
			src.setup_mainframe()

	proc/setup_mainframe()
		var/mob/living/silicon/ai/mainframe = src.owner.current
		// Style
		mainframe.faceEmotion = global.ai_emotions["Sunglasses"]
		mainframe.set_color("#ff0000")
		mainframe.setSkin("syndicate")

		// Laws and functional stuff
		mainframe.syndicate = TRUE
		mainframe.set_law_rack(ticker.ai_law_rack_manager?.default_ai_rack_syndie)
		SPAWN(0.7 SECONDS) //Internal camera doesnt exist for .6 seconds guh
			mainframe.choose_name(3, "Mission Control")
		mainframe.internal_pda.scannable = FALSE
		mainframe.internal_pda.mailgroups |= MGA_SYNDICATE

		//Radios
		mainframe.radio1.icon_tooltip = "Syndicate Mission Control"
		mainframe.radio2.icon_tooltip = "Syndicate Mission Control"
		mainframe.radio3.icon_tooltip = "Syndicate Mission Control"
		mainframe.radio1.chat_class = RADIO::CSS::SYNDICATE
		mainframe.radio1.set_frequency(RADIO::FREQ::SYNDICATE)
		mainframe.radio2.set_frequency(RADIO::FREQ::SALVAGER)
		mainframe.radio2.toggle_speaker(TRUE)
		var/obj/item/device/radio/headset/ai_headset = mainframe.radio3
		ai_headset.chat_class = RADIO::CSS::SYNDICATE
		ai_headset.install_radio_upgrade(new/obj/item/device/radio_upgrade/syndicatechannel)

	add_to_image_groups()
		. = ..()
		var/mob/living/silicon/ai/mainframe = src.owner.current
		var/datum/client_image_group/image_group = get_image_group(ROLE_NUKEOP)
		//Give the mainframe a static icon
		var/image/image = src.get_antag_icon_image()
		image.loc = mainframe
		src.mainframe_antag_image = image
		image_group.add_image(image)
		//Add whatever the owner's currently in aswell as the mainframe
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())
		image_group.add_mind(src.owner)
		get_image_group(ROLE_TRAITOR).add_mind(src.owner)
		get_image_group(ROLE_REVOLUTIONARY).add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(ROLE_NUKEOP)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_image(src.mainframe_antag_image)
		qdel(src.mainframe_antag_image)
		image_group.remove_mind(src.owner)
		get_image_group(ROLE_TRAITOR).remove_mind(src.owner)
		get_image_group(ROLE_REVOLUTIONARY).remove_mind(src.owner)

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/nuclear, src)

	relocate()
		src.owner.current.set_loc(pick_landmark(LANDMARK_SYNDICATE_AI))
