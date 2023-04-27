var/list/admin_verbs = list(


	1 = list(
		// LEVEL_BABBY, goat fart, ayn rand's armpit
		TYPE_PROC_REF(/client, cmd_admin_say),
		TYPE_PROC_REF(/client, cmd_admin_gib_self),
		),


	2 = list(
		// LEVEL_MOD, moderator
		TYPE_PROC_REF(/client, admin_changes),
		TYPE_PROC_REF(/client, admin_play),
		TYPE_PROC_REF(/client, admin_observe),
		TYPE_PROC_REF(/client, admin_invisible),
		TYPE_PROC_REF(/client, game_panel),
		TYPE_PROC_REF(/client, game_panel_but_called_secrets),
		TYPE_PROC_REF(/client, player_panel),
		TYPE_PROC_REF(/client, cmd_admin_view_playernotes),
		TYPE_PROC_REF(/client, toggle_pray),
		TYPE_PROC_REF(/client, cmd_whois),
		TYPE_PROC_REF(/client, cmd_whodead),

		TYPE_PROC_REF(/client, cmd_admin_pm),
		TYPE_PROC_REF(/client, dsay),
		TYPE_PROC_REF(/client, blobsay),
		TYPE_PROC_REF(/client, dronesay),
		TYPE_PROC_REF(/client, hivesay),
		TYPE_PROC_REF(/client, marsay),
		TYPE_PROC_REF(/client, flocksay),
		TYPE_PROC_REF(/client, silisay),
		TYPE_PROC_REF(/client, toggle_hearing_all_looc),
		TYPE_PROC_REF(/client, toggle_hearing_all),
		TYPE_PROC_REF(/client, cmd_admin_prison_unprison),
		TYPE_PROC_REF(/client, cmd_admin_playermode),

		TYPE_PROC_REF(/datum/admins, announce),
		TYPE_PROC_REF(/datum/admins, toggleooc),
		TYPE_PROC_REF(/datum/admins, togglelooc),
		TYPE_PROC_REF(/datum/admins, toggleoocdead),
		TYPE_PROC_REF(/datum/admins, startnow),
		TYPE_PROC_REF(/datum/admins, toggleAI),
		TYPE_PROC_REF(/datum/admins, delay_start),
		TYPE_PROC_REF(/datum/admins, delay_end),
		TYPE_PROC_REF(/datum/admins, togglepowerdebug),

		TYPE_PROC_REF(/client, cmd_admin_subtle_message),
		TYPE_PROC_REF(/client, cmd_admin_alert),
		TYPE_PROC_REF(/client, toggle_banlogin_announcements),
		TYPE_PROC_REF(/client, toggle_jobban_announcements),
		TYPE_PROC_REF(/client, toggle_popup_verbs),
		TYPE_PROC_REF(/client, toggle_server_toggles_tab),
		TYPE_PROC_REF(/client, toggle_attack_messages),
		TYPE_PROC_REF(/client, toggle_adminwho_alerts),
		TYPE_PROC_REF(/client, toggle_rp_word_filtering),
		TYPE_PROC_REF(/client, toggle_uncool_word_filtering),
		TYPE_PROC_REF(/client, toggle_hear_prayers),
		TYPE_PROC_REF(/client, cmd_admin_plain_message),
		TYPE_PROC_REF(/client, cmd_admin_check_vehicle),
		TYPE_PROC_REF(/client, change_admin_prefs),
		//TYPE_PROC_REF(/client, cmd_boot),

		TYPE_PROC_REF(/client, enableDrunkMode),
		TYPE_PROC_REF(/client, forceDrunkMode),

		TYPE_PROC_REF(/client, cmd_unshame_cube),
		TYPE_PROC_REF(/client, cmd_shame_cube),
		TYPE_PROC_REF(/client, removeSelf),
		TYPE_PROC_REF(/client, toggle_station_name_changing),
		TYPE_PROC_REF(/client, cmd_admin_remove_all_labels),
		TYPE_PROC_REF(/client, cmd_admin_antag_popups),
		TYPE_PROC_REF(/client, retreat_to_office),
		TYPE_PROC_REF(/client, summon_office),

		),


	3 = list(
		// LEVEL_SA, secondary administrator
		TYPE_PROC_REF(/client, stealth),
		TYPE_PROC_REF(/datum/admins, pixelexplosion),
		TYPE_PROC_REF(/datum/admins, turn_off_pixelexplosion),
		TYPE_PROC_REF(/datum/admins, camtest),
		TYPE_PROC_REF(/client, alt_key),
		TYPE_PROC_REF(/client, create_portal),
		TYPE_PROC_REF(/datum/admins, togglefarting),
		TYPE_PROC_REF(/client, cmd_admin_show_ai_laws),
		TYPE_PROC_REF(/client, cmd_admin_reset_ai),
		/verb/restart_the_fucking_server_i_mean_it,
		TYPE_PROC_REF(/client, cmd_admin_forceallsay),
		TYPE_PROC_REF(/client, cmd_admin_murraysay),
		TYPE_PROC_REF(/client, cmd_admin_hssay),
		TYPE_PROC_REF(/client, cmd_admin_bradsay),
		TYPE_PROC_REF(/client, cmd_admin_beepsay),
		TYPE_PROC_REF(/datum/admins, restart),
		TYPE_PROC_REF(/datum/admins, toggleenter),
		TYPE_PROC_REF(/client, respawn_self),
		TYPE_PROC_REF(/client, cmd_admin_check_reagents),
		TYPE_PROC_REF(/client, cmd_admin_check_health),
		TYPE_PROC_REF(/client, cmd_admin_polymorph),
		TYPE_PROC_REF(/client, revive_all_bees),
		TYPE_PROC_REF(/client, revive_all_cats),
		TYPE_PROC_REF(/client, revive_all_parrots),
		TYPE_PROC_REF(/datum/admins, toggle_blood_system),
		TYPE_PROC_REF(/client, narrator_mode),
		TYPE_PROC_REF(/client, force_desussification),
		TYPE_PROC_REF(/client, admin_observe_random_player),
		TYPE_PROC_REF(/client, orp),
		TYPE_PROC_REF(/client, admin_pick_random_player),
		TYPE_PROC_REF(/client, fix_powernets),
		TYPE_PROC_REF(/datum/admins, delay_start),
		TYPE_PROC_REF(/datum/admins, delay_end),
		TYPE_PROC_REF(/client, cmd_admin_create_centcom_report),
		TYPE_PROC_REF(/client, cmd_admin_create_advanced_centcom_report),
		TYPE_PROC_REF(/client, cmd_admin_advanced_centcom_report_help),
		TYPE_PROC_REF(/client, warn),
		TYPE_PROC_REF(/client, cmd_admin_playeropt),
		TYPE_PROC_REF(/client, popt_key),
		TYPE_PROC_REF(/client, POK),
		TYPE_PROC_REF(/client, POM),
		TYPE_PROC_REF(/client, show_rules_to_player),
		TYPE_PROC_REF(/client, view_fingerprints),
		TYPE_PROC_REF(/client, cmd_admin_intercom_announce),
		TYPE_PROC_REF(/client, cmd_admin_intercom_announce_freq),
		TYPE_PROC_REF(/client, cmd_admin_intercom_help),
		TYPE_PROC_REF(/client, cmd_dectalk),
		TYPE_PROC_REF(/client, cmd_admin_remove_plasma),
		TYPE_PROC_REF(/client, toggle_death_confetti),
		TYPE_PROC_REF(/client, cmd_admin_unhandcuff),
		TYPE_PROC_REF(/client, admin_toggle_lighting),
		TYPE_PROC_REF(/client, cmd_admin_managebioeffect),
		TYPE_PROC_REF(/client, toggle_cloning_with_records),
		TYPE_PROC_REF(/client, toggle_random_job_selection),

		TYPE_PROC_REF(/client, debug_deletions),

		TYPE_PROC_REF(/client, Jump),
		TYPE_PROC_REF(/client, jumptomob),
		TYPE_PROC_REF(/client, jtm),
		TYPE_PROC_REF(/client, jumptokey),
		TYPE_PROC_REF(/client, jtk),
		TYPE_PROC_REF(/client, jumptoturf),
		TYPE_PROC_REF(/client, jtt),
		TYPE_PROC_REF(/client, jumptocoord),
		TYPE_PROC_REF(/client, jtc),
		TYPE_PROC_REF(/client, admin_follow_mobject),
		TYPE_PROC_REF(/client, main_loop_context),
		TYPE_PROC_REF(/client, main_loop_tick_detail),
		TYPE_PROC_REF(/client, display_bomb_monitor),
		//Ban verbs
		TYPE_PROC_REF(/client, openBanPanel),
		TYPE_PROC_REF(/client, banooc),
		TYPE_PROC_REF(/client, view_cid_list),
		TYPE_PROC_REF(/client, modify_parts),
		TYPE_PROC_REF(/client, jobbans),

		// moved down from admin
		TYPE_PROC_REF(/client, cmd_admin_add_freeform_ai_law),
		TYPE_PROC_REF(/client, cmd_admin_bulk_law_change),
		TYPE_PROC_REF(/client, cmd_admin_mute),
		TYPE_PROC_REF(/client, cmd_admin_mute_temp),
		TYPE_PROC_REF(/client, respawn_as_self),
		TYPE_PROC_REF(/client, respawn_as_new_self),
		TYPE_PROC_REF(/client, respawn_as_job),
		TYPE_PROC_REF(/datum/admins, toggletraitorscaling),
		TYPE_PROC_REF(/client, toggle_flourish),

		TYPE_PROC_REF(/client, cmd_view_runtimes),
		TYPE_PROC_REF(/client, cmd_antag_history),
		TYPE_PROC_REF(/client, cmd_admin_show_player_stats),
		TYPE_PROC_REF(/client, cmd_admin_show_player_ips),
		TYPE_PROC_REF(/client, cmd_admin_show_player_compids),
		TYPE_PROC_REF(/client, give_mass_medals),
		TYPE_PROC_REF(/client, copy_medals),
		TYPE_PROC_REF(/client, copy_cloud_saves),

		TYPE_PROC_REF(/client, cmd_dispatch_observe_to_ghosts),
		TYPE_PROC_REF(/client, waddle_walking),
		TYPE_PROC_REF(/client, clear_area_overlays),
		TYPE_PROC_REF(/client, cmd_admin_adminundamn),
		TYPE_PROC_REF(/client, cmd_admin_admindamn),
		TYPE_PROC_REF(/client, toggle_respawn_arena),

		TYPE_PROC_REF(/client, cmd_emag_all),
		TYPE_PROC_REF(/client, cmd_scale_all),
		TYPE_PROC_REF(/client, cmd_rotate_all),
		TYPE_PROC_REF(/client, cmd_spin_all),
		TYPE_PROC_REF(/client, cmd_atom_emergency_stop),
		TYPE_PROC_REF(/client, cmd_emag_type),
		TYPE_PROC_REF(/client, cmd_transmute_type),
		TYPE_PROC_REF(/client, cmd_scale_type),
		TYPE_PROC_REF(/client, cmd_rotate_type),
		TYPE_PROC_REF(/client, cmd_spin_type),
		TYPE_PROC_REF(/client, cmd_get_type),
		TYPE_PROC_REF(/client, cmd_lightsout),

		TYPE_PROC_REF(/client, vpn_whitelist_add),
		TYPE_PROC_REF(/client, vpn_whitelist_remove),
		TYPE_PROC_REF(/client, set_conspiracy_objective)
		),

	4 = list(
		// LEVEL_IA, admin
		/*
		TYPE_PROC_REF(/client, noclip),
		TYPE_PROC_REF(/client, cmd_admin_mute),
		TYPE_PROC_REF(/client, cmd_admin_mute_temp),
		TYPE_PROC_REF(/client, cmd_admin_delete),
		TYPE_PROC_REF(/client, cmd_admin_add_freeform_ai_law),
		TYPE_PROC_REF(/client, cmd_admin_show_ai_laws),
		TYPE_PROC_REF(/client, cmd_admin_reset_ai),
		TYPE_PROC_REF(/client, addpathogens),
		TYPE_PROC_REF(/client, addreagents),
		TYPE_PROC_REF(/client, respawn_as_self),
		TYPE_PROC_REF(/datum/admins, toggletraitorscaling),
		TYPE_PROC_REF(/datum/admins, togglerandomaiblobs),
		*/
		),

	5 = list(
		// LEVEL_PA, primary administrator
		TYPE_PROC_REF(/datum/admins, togglesuicide),
		TYPE_PROC_REF(/datum/admins, pixelexplosion),
		TYPE_PROC_REF(/client, open_dj_panel),
		TYPE_PROC_REF(/client, cmd_admin_clownify),
		TYPE_PROC_REF(/client, toggle_toggles),
		TYPE_PROC_REF(/client, cmd_admin_plain_message_all),
		TYPE_PROC_REF(/client, cmd_admin_fake_medal),
		TYPE_PROC_REF(/datum/admins, togglespeechpopups),
		TYPE_PROC_REF(/datum/admins, togglemonkeyspeakhuman),
		TYPE_PROC_REF(/datum/admins, toggletraitorsseeeachother),
		TYPE_PROC_REF(/datum/admins, toggleautoending),
		TYPE_PROC_REF(/datum/admins, togglelatetraitors),
		TYPE_PROC_REF(/datum/admins, toggle_pull_slowing),
		TYPE_PROC_REF(/client, resetbuildmode),
		TYPE_PROC_REF(/client, togglebuildmode),
		TYPE_PROC_REF(/client, toggle_buildmode_view),
		TYPE_PROC_REF(/client, cmd_admin_rejuvenate_all),
		TYPE_PROC_REF(/client, toggle_force_mixed_blob),
		TYPE_PROC_REF(/client, toggle_force_mixed_wraith),
		TYPE_PROC_REF(/client, toggle_spooky_light_plane),
		TYPE_PROC_REF(/datum/admins, toggle_radio_audio),
		///proc/possess,
		/proc/possessmob,
		/proc/releasemob,
		TYPE_PROC_REF(/client, critter_creator_debug),
		TYPE_PROC_REF(/client, cmd_cat_county),
		TYPE_PROC_REF(/client, fake_pda_message_to_all),
		TYPE_PROC_REF(/client, force_say_in_range),
		TYPE_PROC_REF(/client, find_thing),
		TYPE_PROC_REF(/client, find_one_of),
		TYPE_PROC_REF(/client, cmd_admin_advview),
		TYPE_PROC_REF(/client, iddt),
		TYPE_PROC_REF(/client, cmd_swap_minds),
		TYPE_PROC_REF(/client, cmd_transfer_client),
		TYPE_PROC_REF(/client, edit_module),
		// TYPE_PROC_REF(/client, modify_organs),
		TYPE_PROC_REF(/client, toggle_atom_verbs),
		TYPE_PROC_REF(/client, toggle_camera_network_reciprocity),
		//TYPE_PROC_REF(/client, generate_poster),
		TYPE_PROC_REF(/client, count_all_of),
		TYPE_PROC_REF(/client, admin_set_ai_vox),
		TYPE_PROC_REF(/client, cmd_makeshittyweapon),
		TYPE_PROC_REF(/client, rspawn_panel),
		TYPE_PROC_REF(/client, cmd_admin_manageabils),
		TYPE_PROC_REF(/client, create_all_wizard_rings),
		TYPE_PROC_REF(/client, toggle_vpn_blacklist),

		// moved up from admin
		//TYPE_PROC_REF(/client, cmd_admin_delete),
		TYPE_PROC_REF(/client, noclip),
		TYPE_PROC_REF(/client, idclip),
		//TYPE_PROC_REF(/client, addpathogens),
		TYPE_PROC_REF(/client, respawn_as_self),
		TYPE_PROC_REF(/client, respawn_list_players),
		TYPE_PROC_REF(/client, cmd_give_pet),
		TYPE_PROC_REF(/client, cmd_give_pets),
		TYPE_PROC_REF(/client, cmd_give_player_pets),
		TYPE_PROC_REF(/client, cmd_customgrenade),
		TYPE_PROC_REF(/client, cmd_admin_gib),
		TYPE_PROC_REF(/client, cmd_admin_partygib),
		TYPE_PROC_REF(/client, cmd_admin_owlgib),
		TYPE_PROC_REF(/client, cmd_admin_firegib),
		TYPE_PROC_REF(/client, cmd_admin_elecgib),
		TYPE_PROC_REF(/client, sharkgib),
		TYPE_PROC_REF(/client, cmd_admin_icegib),
		TYPE_PROC_REF(/client, cmd_admin_goldgib),
		TYPE_PROC_REF(/client, cmd_admin_spidergib),
		TYPE_PROC_REF(/client, cmd_admin_implodegib),
		TYPE_PROC_REF(/client, cmd_admin_cluwnegib),
		TYPE_PROC_REF(/client, cmd_admin_buttgib),
		TYPE_PROC_REF(/client, cmd_admin_tysongib),
		TYPE_PROC_REF(/client, removeOther),
		TYPE_PROC_REF(/client, toggle_map_voting),
		TYPE_PROC_REF(/client, show_admin_lag_hacks),
		TYPE_PROC_REF(/client, spawn_survival_shit),
		TYPE_PROC_REF(/client, respawn_cinematic),
		TYPE_PROC_REF(/client, idkfa),
		TYPE_PROC_REF(/datum/admins, spawn_atom),
		TYPE_PROC_REF(/datum/admins, heavenly_spawn_obj),
		TYPE_PROC_REF(/datum/admins, supplydrop_spawn_obj),
		TYPE_PROC_REF(/datum/admins, demonically_spawn_obj),
		TYPE_PROC_REF(/datum/admins, spawn_figurine),

		// moved down from coder. shows artists, atmos etc
		TYPE_PROC_REF(/client, SetInfoOverlay),
		TYPE_PROC_REF(/client, SetInfoOverlayAlias),

		),


	6 = list(
		// LEVEL_ADMIN, Administrator
		TYPE_PROC_REF(/datum/admins, togglesoundwaiting),
		TYPE_PROC_REF(/client, debug_variables),
		/verb/adminCreateBlueprint,
		/verb/adminDeleteBlueprint,
		TYPE_PROC_REF(/client, toggle_text_mode),
		TYPE_PROC_REF(/client, cmd_debug_mutantrace),
		TYPE_PROC_REF(/client, cmd_admin_rejuvenate),
		TYPE_PROC_REF(/client, cmd_admin_drop_everything),
		TYPE_PROC_REF(/client, cmd_admin_humanize),
		TYPE_PROC_REF(/client, cmd_admin_mobileAIize),
		TYPE_PROC_REF(/client, cmd_admin_makeai),
		TYPE_PROC_REF(/client, cmd_admin_makecyborg),
		TYPE_PROC_REF(/client, cmd_admin_makeghostdrone),
		TYPE_PROC_REF(/client, cmd_debug_del_all),
		TYPE_PROC_REF(/client, cmd_debug_del_half),
		TYPE_PROC_REF(/client, cmd_admin_godmode),
		TYPE_PROC_REF(/client, cmd_admin_godmode_self),
		TYPE_PROC_REF(/client, cmd_admin_toggle_ghost_interaction),
		TYPE_PROC_REF(/client, iddqd),
		TYPE_PROC_REF(/client, cmd_admin_omnipresence),
		TYPE_PROC_REF(/client, cmd_admin_get_mobject),
		TYPE_PROC_REF(/client, cmd_admin_get_mobject_loc),
		TYPE_PROC_REF(/client, Getmob),
		TYPE_PROC_REF(/client, sendmob),
		TYPE_PROC_REF(/client, gethmobs),
		TYPE_PROC_REF(/client, sendhmobs),
		TYPE_PROC_REF(/client, getmobs),
		TYPE_PROC_REF(/client, getclients),
		TYPE_PROC_REF(/client, sendmobs),
		TYPE_PROC_REF(/client, gettraitors),
		TYPE_PROC_REF(/client, getnontraitors),
		TYPE_PROC_REF(/datum/admins, adrev),
		TYPE_PROC_REF(/datum/admins, adspawn),
		TYPE_PROC_REF(/datum/admins, adjump),
		TYPE_PROC_REF(/client, find_all_of),
		TYPE_PROC_REF(/client, respawn_as),
		TYPE_PROC_REF(/client, whitelist_add_temp),
		TYPE_PROC_REF(/client, whitelist_toggle),
		TYPE_PROC_REF(/client, list_adminteract_buttons),

		TYPE_PROC_REF(/client, general_report),
		TYPE_PROC_REF(/client, map_debug_panel),
		TYPE_PROC_REF(/client, air_report),
		TYPE_PROC_REF(/client, fix_next_move),
		TYPE_PROC_REF(/client, debugreward),

		TYPE_PROC_REF(/client, flip_view),
		TYPE_PROC_REF(/client, show_image_to_all),
		TYPE_PROC_REF(/client, sharkban),
		TYPE_PROC_REF(/client, toggle_literal_disarm),
		TYPE_PROC_REF(/datum/admins, toggle_emote_cooldowns),
		TYPE_PROC_REF(/client, implant_all),
		TYPE_PROC_REF(/client, cmd_crusher_walls),
		TYPE_PROC_REF(/client, cmd_disco_lights),
		TYPE_PROC_REF(/client, cmd_blindfold_monkeys),
		TYPE_PROC_REF(/client, cmd_terrainify_station),
		TYPE_PROC_REF(/client, cmd_custom_spawn_event),
		TYPE_PROC_REF(/client, cmd_special_shuttle),
		TYPE_PROC_REF(/client, toggle_radio_maptext),

		TYPE_PROC_REF(/datum/admins, toggleaprilfools),
		TYPE_PROC_REF(/client, cmd_admin_pop_off_all_the_limbs_oh_god),
		TYPE_PROC_REF(/datum/admins, togglethetoggles),
		TYPE_PROC_REF(/datum/admins, togglesimsmode),
		TYPE_PROC_REF(/client, admin_toggle_nightmode),
		TYPE_PROC_REF(/client, toggle_ip_alerts),
		TYPE_PROC_REF(/client, upload_custom_hud),
		TYPE_PROC_REF(/client, enable_waterflow),
		TYPE_PROC_REF(/client, delete_fluids),
		TYPE_PROC_REF(/client, special_fullbright),
		TYPE_PROC_REF(/client, replace_space_exclusive),
		TYPE_PROC_REF(/client, dereplace_space),
		TYPE_PROC_REF(/client, ghostdroneAll),
		TYPE_PROC_REF(/client, showLoadingHint),
		TYPE_PROC_REF(/client, showPregameHTML),
		TYPE_PROC_REF(/client, dbg_radio_controller),
		TYPE_PROC_REF(/client, test_mass_flock_convert),
		TYPE_PROC_REF(/client, BK_finance_debug),
		TYPE_PROC_REF(/client, BK_alter_funds),
		TYPE_PROC_REF(/client, debug_variables),
		TYPE_PROC_REF(/client, cmd_randomize_look),
		TYPE_PROC_REF(/client, flock_cheat),

		TYPE_PROC_REF(/client, call_proc),
		TYPE_PROC_REF(/client, call_proc_all),
		TYPE_PROC_REF(/client, debug_global_variable),
		TYPE_PROC_REF(/client, debug_ref_variables),

		// TYPE_PROC_REF(/client, admin_airborne_fluid),
		// TYPE_PROC_REF(/client, replace_space),
#ifdef IMAGE_DEL_DEBUG
		TYPE_PROC_REF(/client, debug_image_deletions),
		TYPE_PROC_REF(/client, debug_image_deletions_clear),
#endif

		),

	7 = list(
		// LEVEL_CODER, coder
		TYPE_PROC_REF(/client, cmd_job_controls),
		TYPE_PROC_REF(/client, cmd_modify_market_variables),
		TYPE_PROC_REF(/client, debug_pools),
		TYPE_PROC_REF(/client, debug_global_variable),
		TYPE_PROC_REF(/client, get_admin_state),
		TYPE_PROC_REF(/client, call_proc),
		TYPE_PROC_REF(/client, call_proc_all),
		TYPE_PROC_REF(/datum/admins, adsound),
		TYPE_PROC_REF(/datum/admins, pcap),
		TYPE_PROC_REF(/client, toggle_extra_verbs),
		TYPE_PROC_REF(/client, toggle_numbers_station_messages),

		TYPE_PROC_REF(/client, ticklag),
		TYPE_PROC_REF(/client, cmd_debug_vox),
		TYPE_PROC_REF(/client, check_gang_scores),
		TYPE_PROC_REF(/client, mapWorld),
		TYPE_PROC_REF(/client, haine_blood_debug),
		TYPE_PROC_REF(/client, debug_messages),
		TYPE_PROC_REF(/client, toggle_next_click),
		TYPE_PROC_REF(/client, debug_reaction_list),
		TYPE_PROC_REF(/client, debug_reagents_cache),
		//TYPE_PROC_REF(/client, debug_check_possible_reactions),
		TYPE_PROC_REF(/client, set_admin_level),
		TYPE_PROC_REF(/client, show_camera_paths),
		//TYPE_PROC_REF(/client, dbg_itemspecial),
		//TYPE_PROC_REF(/client, dbg_objectprop),
		// TYPE_PROC_REF(/client, remove_camera_paths_verb),
		// TYPE_PROC_REF(/client, show_runtime_window),
		TYPE_PROC_REF(/client, cmd_chat_debug),
		TYPE_PROC_REF(/client, toggleIrcbotDebug),
		TYPE_PROC_REF(/datum/admins, toggle_bone_system),
		TYPE_PROC_REF(/client, cmd_randomize_handwriting),
		TYPE_PROC_REF(/client, wireTest),
		TYPE_PROC_REF(/client, toggleResourceCache),
		TYPE_PROC_REF(/client, debugResourceCache),
		TYPE_PROC_REF(/client, debug_profiler),
		TYPE_PROC_REF(/client, cmd_tooltip_debug),
		TYPE_PROC_REF(/client, deleteJsLogFile),
		TYPE_PROC_REF(/client, deleteAllJsLogFiles),
		TYPE_PROC_REF(/client, random_color_matrix),
		TYPE_PROC_REF(/client, clear_string_cache),
		TYPE_PROC_REF(/client, test_flock_panel),
		TYPE_PROC_REF(/client, temporary_deadmin_self),
		/verb/rebuild_flow_networks,
		/verb/print_flow_networks,
		TYPE_PROC_REF(/client, toggle_hard_reboot),
		TYPE_PROC_REF(/client, cmd_modify_respawn_variables),
		TYPE_PROC_REF(/client, set_nukie_score),
		TYPE_PROC_REF(/client, set_pod_wars_score),
		TYPE_PROC_REF(/client, set_pod_wars_deaths),
		TYPE_PROC_REF(/client, clear_nukeop_uplink_purchases),
		TYPE_PROC_REF(/client, upload_uncool_words),
		TYPE_PROC_REF(/client, TestMarketReq),

		TYPE_PROC_REF(/client, delete_profiling_logs),
		TYPE_PROC_REF(/client, cause_lag),
		TYPE_PROC_REF(/client, persistent_lag),

#ifdef MACHINE_PROCESSING_DEBUG
		TYPE_PROC_REF(/client, cmd_display_detailed_machine_stats),
		TYPE_PROC_REF(/client, cmd_display_detailed_power_stats),
#endif
#ifdef QUEUE_STAT_DEBUG
		TYPE_PROC_REF(/client, cmd_display_queue_stats),
#endif
#ifdef ENABLE_SPAWN_DEBUG
		TYPE_PROC_REF(/client, cmd_modify_spawn_dbg_list),
		TYPE_PROC_REF(/client, spawn_dbg),
#elif defined(ENABLE_SPAWN_DEBUG_2)
		TYPE_PROC_REF(/client, spawn_dbg),
#endif
		),

	8 = list(
		// LEVEL_HOST, host
		TYPE_PROC_REF(/datum/admins, toggle_soundpref_override)
		),
	)

// verbs that SAs and As get while observing. PA+ get these all the time
var/list/special_admin_observing_verbs = list(
	TYPE_PROC_REF(/datum/admins, toggle_respawns),
	TYPE_PROC_REF(/datum/admins, toggledeadchat),
	TYPE_PROC_REF(/client, togglepersonaldeadchat),
	TYPE_PROC_REF(/client, Getmob),
	)

// verbs that PAs get while observing. Coder+ get these all the time
var/list/special_pa_observing_verbs = list(
	TYPE_PROC_REF(/client, cmd_admin_drop_everything),
	TYPE_PROC_REF(/client, debug_variables),
	TYPE_PROC_REF(/client, cmd_modify_ticker_variables),
	TYPE_PROC_REF(/client, cmd_modify_controller_variables),
	TYPE_PROC_REF(/client, Getmob),
	TYPE_PROC_REF(/client, sendmob),
	TYPE_PROC_REF(/client, cmd_admin_rejuvenate),
	TYPE_PROC_REF(/client, toggle_view_range),
	TYPE_PROC_REF(/client, cmd_admin_aview),
	)

/*
/client/proc/cmd_add_to_screen(var/atom/A as obj|mob|turf in world)
	set name = "Add to Screen"
	set desc = "Add a thing to some poor sod's screen."
	set popup_menu = 1
	set category = null

	var/list/who = list("everyone" = 1)
	for (var/client/C in clients)
		var/keyname = "[C] ([C.mob])"
		who += keyname
		who[keyname] = who

	var/chosen = input("Whose screen do you want to add this to?", "Add to screen", "everyone") as null|anything in who
	if (!chosen)
		return
	if (chosen == "everyone")
		for (var/client/C in clients)
			C.screen += A
		message_admins("[key_name(usr)] added [A] to everyone's screen!")
		logTheThing(LOG_ADMIN, usr, "added [A] to everyone's screen.")
	else
		var/client/C = who[chosen]
		C.screen += A
		boutput(usr, "<span class='notice'>Successful.</span>")
		logTheThing(LOG_ADMIN, usr, "added [A] to [constructTarget(C.mob,"admin")]'s screen.")
*/
/client/proc/update_admins(var/rank)
	if(src.player.tempmin && src.player.perm_admin)
		logTheThing(LOG_DEBUG, src, "is somehow both tempminned and permadminned. This is a bug.")
		stack_trace("[src] is somehow both tempminned and permadminned. This is a bug.")

	// The idea is that player.tempmin and player.perm_admin are set when the given player
	// is adminned for the first time during a round and are persistent. Essentially, if
	// the player is adminned by code during round initialization then their src.holder
	// has already been set and they are marked as perm_admin for the rest of the round.
	// Other ways of getting adminned (such as using the player options) will not set
	// src.holder and the first call to this proc will mark the player as tempminned for
	// the rest of the round.
	if((!src.holder || src.player.tempmin) && !src.player.perm_admin)
		src.holder = new /datum/admins(src)
		src.holder.tempmin = TRUE
		src.holder.audit |= AUDIT_VIEW_VARIABLES
		src.player.tempmin = TRUE
	else
		src.player.perm_admin = TRUE

	src.holder.rank = rank

	if(!src.holder.state)
		var/state = tgui_alert(src.mob, "Which state do you want the admin to begin in?", "Admin-state", list("Play", "Observe", "Neither"))
		if(state == "Play")
			src.holder.state = 1
			src.admin_play()
			return
		else if(state == "Observe")
			src.holder.state = 2
			src.admin_observe()
			return
		else
			src.holder.dispose()
			src.holder = null
			return

	switch (rank)
		if ("Host")
			src.holder.level = LEVEL_HOST
		if ("Coder")
			src.holder.level = LEVEL_CODER
		if ("Administrator")
			src.holder.level = LEVEL_ADMIN
		if ("Primary Administrator")
			src.holder.level = LEVEL_PA
		if ("Intermediate Administrator")
			src.holder.level = LEVEL_IA
		if ("Secondary Administrator")
			src.holder.level = LEVEL_SA
		if ("Moderator")
			src.holder.level = LEVEL_MOD
		if ("Goat Fart", "Ayn Rand's Armpit")
			src.holder.level = LEVEL_BABBY

		if ("Inactive")
			src.holder.dispose()
			src.holder = null
			boutput(src, "<span style='color:red;font-size:150%'><b>You are set to Inactive admin status! Please join the Goonstation Discord if you would like to become active again!</b></span>")
			return

		if ("Banned")
			del(src)
			return

		else
			src.holder.dispose()
			src.holder = null
			return

	if (src.holder)
		src.holder.owner = src
		for(var/i = 1; i < 9; i++)
			if (src.holder.level + 2 >= i && admin_verbs.len >= i && !isnull(admin_verbs[i]))
				src.verbs += admin_verbs[i]

		// certain ranks get special treatment while observing
		if( src.holder.state ) // literally the laziest way to do this
			if ( src.holder.level > LEVEL_MOD)
				src.deadchat = 1
				src.verbs += special_admin_observing_verbs
			if ( src.holder.level > LEVEL_IA )
				src.verbs += special_pa_observing_verbs
		else
			if ( src.holder.level > LEVEL_IA)
				src.deadchat = 1
				src.verbs += special_admin_observing_verbs
			if( src.holder.level > LEVEL_PA ) //SHIT GUY PLUS
				src.verbs += special_pa_observing_verbs

	if (src.chatOutput && src.chatOutput.loaded)
		src.chatOutput.loadAdmin()

/client/proc/clear_admin_verbs()
	src.deadchat = 0

	for(var/i = 1;i < 9; i++)
		src.verbs -= admin_verbs[i]

	src.verbs -= special_admin_observing_verbs
	src.verbs -= special_pa_observing_verbs

	src.buildmode = null
	src.show_popup_menus = 1

	if (widescreen)
		src.view = "21x15"
	else
		src.view = "15x15"


	usr.see_in_dark = initial(usr.see_in_dark)

	if(src.holder)
		src.holder.level = 0

/client/proc/admin_invisible()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Set Invisible"
	if(!src.holder)
		alert("You are not an admin")
		return
	if(src.mob.mouse_opacity)
		src.mob.mouse_opacity = 0
		src.mob.alpha = 0
		boutput(src, "<span class='notice'>You are now invisible.</span>")
	else
		src.mob.mouse_opacity = 1
		src.mob.alpha = 255
		boutput(src, "<span class='notice'>You are no longer invisible!</span>")

/client/proc/admin_observe()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Set Observe"
	if(!src.holder)
		alert("You are not an admin")
		return

	if(!src.holder.popuptoggle) //Hrngh
		var/rank = src.holder.rank
		clear_admin_verbs()
		src.holder.state = 2
	//	src.mob.mind.observing = 1
		update_admins(rank)

	if(!istype(src.mob, /mob/dead/observer) && !istype(src.mob, /mob/dead/target_observer))
		src.mob.mind?.damned = FALSE
		src.mob.mind?.get_player()?.dnr++
		src.mob.ghostize()
		boutput(src, "<span class='notice'>You are now observing</span>")
	else
		boutput(src, "<span class='notice'>You are already observing!</span>")

/client/proc/admin_play()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Set Play"
	if(!src.holder)
		alert("You are not an admin")
		return

	if(!src.holder.popuptoggle) //Hrngh x2
		var/rank = src.holder.rank
		clear_admin_verbs()
		src.holder.state = 1
	//	src.mob.mind.observing = 0
		update_admins(rank)

	if(istype(src.mob, /mob/dead/observer))
		src.mob:reenter_corpse()
		src.mob.mind?.get_player()?.dnr = max(src.mob.mind?.get_player()?.dnr - 1, 0)
		boutput(src, "<span class='notice'>You are now playing</span>")
	else
		boutput(src, "<span class='notice'>You are already playing!</span>")

/client/proc/get_admin_state()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	for(var/client/C)
		if(C.holder)
			if(C.holder.state == 1)
				boutput(src, "[C.key] is playing - [C.holder.state]")
			else if(C.holder.state == 2)
				boutput(src, "[C.key] is observing - [C.holder.state]")
			else
				boutput(src, "[C.key] is undefined - [C.holder.state]")

//admin client procs ported over from mob.dm

/client/proc/player_panel()
	set name = "Player Panel"
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	ADMIN_ONLY
	if (src.holder.tempmin)
		logTheThing(LOG_ADMIN, usr, "tried to access the player panel")
		logTheThing(LOG_DIARY, usr, "tried to access the player panel", "admin")
		message_admins("[key_name(usr)] tried to access the player panel but was denied.")
		alert("You need to be an actual admin to access the player panel.")
		return
	if (src.holder.level >= LEVEL_SA)
		global.player_panel.ui_interact(src.mob)

/client/proc/rspawn_panel()
	set name = "Respawn Panel"
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	if (src.holder)
		src.holder.s_respawn()
	return

/client/proc/jobbans(key as text)
	set name = "Jobban Panel"
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	src.holder?.Topic(null, list("action"="jobbanpanel","target"=key))
	return

/client/proc/game_panel()
	set name = "Game Panel"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	if (src.holder)
		src.holder.Game()
	return

/client/proc/game_panel_but_called_secrets()
	set name = "Secrets"
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	if (src.holder)
		src.holder.Game()
	return

/client/proc/stealth()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Stealth Mode"
	ADMIN_ONLY

	//fuck u
	src.holder.set_stealth_mode(null, 0)

/datum/admins/proc/set_stealth_mode(var/new_key = null, var/force_on = 0)
	if (!src.owner || !isclient(src.owner))
		return // farte
	if (force_on)
		src.owner:stealth = 1
	else
		src.owner:stealth = !(src.owner:stealth)

	if (src.owner:stealth)
		if (!new_key)
			new_key = input(usr, "Enter your desired display name.", "Fake Key", src.owner:key) as null|text
			if (!new_key)
				src.owner:stealth = 0
		if (src.owner:stealth && src.owner:alt_key)
			src.set_alt_key()
		if (new_key)
			new_key = trim(new_key)
			//stealth_hide_fakekey = (alert("Hide your fake key when using DSAY?", "Extra stealthy","Yes", "No") == "Yes")
			// I think if people really wanna be Denmark they can just set themselves to be Denmark
			new_key = strip_html(new_key)
			if (length(new_key) >= 50)
				new_key = copytext(new_key, 1, 50)
			src.owner:fakekey = new_key
		if(src.owner.fakekey)
			src.owner.mob.mind.displayed_key = src.owner.fakekey

	else
		src.owner:fakekey = null
		src.owner:stealth_hide_fakekey = 0
		src.owner.mob.mind.displayed_key = src.owner.key
		if (src.auto_alt_key)
			src.set_alt_key(src.auto_alt_key_name)

	logTheThing(LOG_ADMIN, src.owner, "has turned stealth mode [src.owner:stealth ? "ON using key \"[src.owner:fakekey]\"" : "OFF"]")
	logTheThing(LOG_DIARY, src.owner, "has turned stealth mode [src.owner:stealth ? "ON using key \"[src.owner:fakekey]\"" : "OFF"]", "admin")
	message_admins("[key_name(src.owner)] has turned stealth mode [src.owner:stealth ? "ON using key \"[src.owner:fakekey]\"" : "OFF"]")

	if (src.owner:stealth)
		var/ircmsg[] = new()
		ircmsg["key"] = src.owner:key
		ircmsg["name"] = (usr?.real_name) ? stripTextMacros(usr.real_name) : "NULL"
		ircmsg["msg"] = "Has enabled stealth mode as ([src.owner:fakekey])"
		ircbot.export_async("admin", ircmsg)

/client/proc/alt_key()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Alternate Key"
	set desc = "Shows your key as something else!"
	ADMIN_ONLY

	src.holder.set_alt_key(null, 0)

/datum/admins/proc/set_alt_key(var/new_key = null, var/force_on = 0)
	if (!src.owner || !isclient(src.owner))
		return // farte
	if (force_on)
		src.owner:alt_key = 1
	else
		src.owner:alt_key = !(src.owner:alt_key)

	if (src.owner:alt_key)
		if (!new_key)
			new_key = input(usr, "Enter your desired display name.", "Fake Key", src.owner:key) as null|text
			if (!new_key)
				src.owner:alt_key = 0
		if (src.owner:alt_key && src.owner:stealth)
			src.set_stealth_mode()
		if (new_key)
			new_key = trim(new_key)
			new_key = strip_html(new_key)
			if (length(new_key) >= 50)
				new_key = copytext(new_key, 1, 50)
			src.owner:fakekey = new_key
	else
		src.owner:fakekey = null

	logTheThing(LOG_ADMIN, src.owner, "has changed their displayed key to [src.owner:alt_key ? "\"[src.owner:fakekey]\"" : "\"[src.owner:key]\""]")
	logTheThing(LOG_DIARY, src.owner, "has changed their displayed key to [src.owner:alt_key ? "\"[src.owner:fakekey]\"" : "\"[src.owner:key]\""]", "admin")
	message_admins("[key_name(src.owner)] has changed their displayed key to [src.owner:alt_key ? "\"[src.owner:fakekey]\"" : "\"[src.owner:key]\""]")
/*
	if (src.alt_key)
		var/ircmsg[] = new()
		ircmsg["key"] = src.owner:key
		ircmsg["name"] = (usr?.real_name) ? stripTextMacros(usr.real_name) : "NULL"
		ircmsg["msg"] = "Has set their displayed key to ([src.owner:fakekey])"
		ircbot.export_async("admin", ircmsg)
*/
/client/proc/banooc()
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "OOC (Un)Ban"
	set desc = "Ban or unban a player from using OOC"
	ADMIN_ONLY
	var/mob/target
	var/client/selection = tgui_input_list(src.mob, "Please, select a player!", "OOC Ban", clients)
	if (!selection)
		return
	target = selection.mob
	if (!oocban_isbanned(target))
		oocban_fullban(target)
		message_admins("[key_name(src)] has banned [key_name(target)] from OOC")
		logTheThing(LOG_ADMIN, usr, "Banned [constructTarget(target,"admin")] from OOC")
		logTheThing(LOG_DIARY, usr, "Banned [constructTarget(target,"diary")] from OOC", "admin")
	else
		oocban_unban(selection)
		message_admins("[key_name(src)] has unbanned [key_name(target)] from OOC")
		logTheThing(LOG_ADMIN, usr, "Unbanned [constructTarget(target,"admin")] from OOC")
		logTheThing(LOG_DIARY, usr, "Unbanned [constructTarget(target,"diary")] from OOC", "admin")

/client/proc/warn(var/mob/M in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	set name = "Warn"
	set desc = "Warn a player"
	ADMIN_ONLY
	if(M.client && M.client.holder && (M.client.holder.level >= src.holder.level))
		alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
		return
	if(!M.client.warned)
		M.Browse(rules, "window=rules;size=480x320")
		boutput(M, "<span class='alert'><B>You have been warned by an administrator. This is the only warning you will receive.</B></span>")
		M.client.warned = 1
		message_admins("<span class='internal'>[src.ckey] warned [M.ckey].</span>")
	else
		var/addData[] = new()
		addData["ckey"] = M.ckey
		addData["compID"] = M.computer_id
		addData["ip"] = M.client.address
		addData["reason"] = "Autobanning due to previous warn. This is what we in the biz like to call a \"second warning\"."
		addData["akey"] = src.ckey
		addData["mins"] = 10
		addBan(addData)

/client/proc/clear_area_overlays()
	set name = "Clear Area Overlays"
	SET_ADMIN_CAT(ADMIN_CAT_NONE)

	for(var/area/A in world)
		A.icon_state = ""

var/list/fun_images = list()
/client/proc/show_image_to_all()
	set name = "Show Image to All"
	SET_ADMIN_CAT(ADMIN_CAT_FUN)

	if(fun_images.len)
		switch(alert("There is already an existing image.", "Warning", "Ignore", "Clear", "Cancel"))
			if("Clear")
				for (var/datum/hud/funimage/fun_image)
					for (var/client/C in fun_image.clients)
						fun_image.remove_client(C)
				fun_images.len = 0
				return
			if("Cancel")
				return

	var/icon/I = input("Pick an icon:","Icon") as null|icon
	if (I)
		var/datum/hud/funimage/fun_image = new(I)
		fun_images += fun_image
		for (var/client/C in clients)
			fun_image.add_client(C)
		logTheThing(LOG_ADMIN, src, "has uploaded icon [I] to all players")
		logTheThing(LOG_DIARY, src, "has uploaded icon [I] to all players", "admin")
		message_admins("[key_name(src)] has uploaded icon [I] to all players")

/client/proc/show_rules_to_player(mob/M as mob in world)
	set name = "Show Rules to Player"
	set popup_menu = 0
	SET_ADMIN_CAT(ADMIN_CAT_NONE)

	var/crossness = tgui_alert(src.mob, "How cross are we with this guy?", "Enter Crossness", list("A bit", "A lot", "Cancel"))
	if (!crossness || crossness == "Cancel")
		return

	if(!M.client)
		alert("[M] is logged out, so you should probably ban them!")
		return
	logTheThing(LOG_ADMIN, src, "forced [constructTarget(M,"admin")] to view the rules")
	logTheThing(LOG_DIARY, src, "forced [constructTarget(M,"diary")] to view the rules", "admin")
	message_admins("[key_name(src)] forced [key_name(M)] to view the rules.")
	switch(crossness)
		if ("A bit")
			M << 'sound/misc/newsting.ogg'
			boutput(M, "<span class='alert'><B>Here are the rules, you can read this, you have a good chance of being able to read them too.</B></span>")
		if ("A lot")
			M << 'sound/misc/klaxon.ogg'
			boutput(M, "<span class='alert'><B>WARNING: An admin is likely very cross with you and wants you to read the rules right fucking now!</B></span>")

	// M << browse(rules, "window=rules;size=800x1000")
	M << link("http://wiki.ss13.co/Rules")

/client/proc/view_fingerprints(obj/O as obj in world)
	set name = "View Object Fingerprints"
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0

	ADMIN_ONLY
	if(!O.fingerprints_full || !length(O.fingerprints_full))
		alert("There are no fingerprints on this object.", null, null, null, null, null)
		return

	boutput(src, "<b>Hidden Fingerprints on [O]:</b>")
	for(var/i in O.fingerprints_full)
		var/list/L = O.fingerprints_full[i]
		boutput(src, "Key: [L["key"]], real name: [L["real_name"]], time: [L["time"]]")

	boutput(src, "<b>Last touched by:</b> [key_name(O.fingerprintslast)].")
	return

/client/proc/respawn_cinematic()
	set name = "Respawn Cinematic"
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set desc = "Respawn yourself with a special effect"
	set popup_menu = 0
	ADMIN_ONLY

	var/list/respawn_types = list("Heavenly", "Demonically", "Beam")
	var/selection = tgui_input_list(src.mob, "Select Respawn type.", "Cinematic Respawn", respawn_types)
	switch(selection)
		if("Heavenly")
			src.respawn_as_self()
			var/mob/M = src.mob
			M.UpdateOverlays(image('icons/misc/32x64.dmi',"halo"), "halo")
			heavenly_spawn(M)
		if("Demonically")
			src.respawn_as_self()
			var/mob/living/carbon/human/M = src.mob
			M.bioHolder.AddEffect("hell_fire", magical = 1)
			demonic_spawn(M)
		if("Beam")
			src.respawn_as_self()
			spawn_beam(src.mob)

/client/proc/respawn_as(var/client/cli in clients)
	set name = "Respawn As"
	set desc = "Respawn yourself as the currenly loaded character of a player. Instantly. Right where you stand."
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set popup_menu = 0
	ADMIN_ONLY

	if (!cli)
		cli = tgui_input_list(src.mob, "Please, select a player!", "Respawn As", null, null, clients)
		if(!cli)
			return

	if (!cli.preferences)
		boutput(src, "<span class='alert'>No preferences found on target client.</span>")

	var/mob/mymob = src.mob
	var/mob/living/carbon/human/H = new(mymob.loc, cli.preferences.AH, cli.preferences, TRUE)
	if (!mymob.mind)
		mymob.mind = new /datum/mind()
		mymob.mind.ckey = ckey
		mymob.mind.key = key
		mymob.mind.current = mymob
		ticker.minds += mymob.mind
	mymob.mind.transfer_to(H)
	qdel(mymob)
	H.JobEquipSpawned("Staff Assistant", 1)
	H.update_colorful_parts()

/client/proc/respawn_as_job(var/datum/job/J in (job_controls.staple_jobs|job_controls.special_jobs|job_controls.hidden_jobs))
	set name = "Respawn As Job"
	set desc = "Respawn yourself as a given job. Instantly. Right where you stand."
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set popup_menu = 0
	ADMIN_ONLY

	respawn_as_self_internal(new_self=TRUE, jobstring = J.name)

/client/proc/respawn_as_new_self()
	set name = "Respawn As New Self"
	set desc = "Respawn yourself as your currenly loaded character. Instantly. Right where you stand."
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set popup_menu = 0
	ADMIN_ONLY

	respawn_as_self_internal(new_self=TRUE)


/client/proc/respawn_as_self()
	set name = "Respawn As Self"
	set desc = "Respawn yourself as your currenly loaded character or the character you removed with remove-self. Instantly. Right where you stand."
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set popup_menu = 0
	ADMIN_ONLY

	respawn_as_self_internal(new_self=FALSE)


/client/proc/respawn_as_self_internal(new_self=FALSE, jobstring = "Staff Assistant")
	ADMIN_ONLY

	if (!src.preferences)
		boutput(src, "<span class='alert'>No preferences found on your client.</span>")

	if (!istype(src.mob, /mob/dead/observer) && !istype(src.mob, /mob/dead/target_observer))
		if (alert(usr, "Are you sure you wanna respawn yourself where you are? If you're already in a living mob, it'll be deleted!", "Confirmation", "Yes", "No") == "No")
			return

	var/mob/mymob = src.mob
	var/mob/living/carbon/human/H
	var/new_mob = FALSE
	if(src.holder.respawn_as_self_mob && !src.holder.respawn_as_self_mob.disposed && !new_self)
		H = src.holder.respawn_as_self_mob
		if(locate(/obj/storage) in mymob.loc)
			var/obj/storage/S = locate(/obj/storage) in mymob.loc
			H.set_loc(S)
		else
			H.set_loc(mymob.loc)
		src.holder.respawn_as_self_mob = null
	else
		if(locate(/obj/storage) in mymob.loc)
			var/obj/storage/S = locate(/obj/storage) in mymob.loc
			H = new(S, src.preferences.AH, src.preferences, TRUE)
		else
			H = new(mymob.loc, src.preferences.AH, src.preferences, TRUE)
		new_mob = TRUE
	if (!mymob.mind)
		mymob.mind = new /datum/mind()
		mymob.mind.ckey = ckey
		mymob.mind.key = key
		mymob.mind.current = mymob
		ticker.minds += mymob.mind
	mymob.mind.transfer_to(H)
	if(new_mob)
		H.Equip_Rank(jobstring, 2) //ZeWaka: joined_late is 2 so you don't get announced.
		H.update_colorful_parts()
	qdel(mymob)
	if (flourish)
		for (var/mob/living/M in oviewers(5, get_turf(H)))
			M.apply_flash(animation_duration = 30, weak = 5, uncloak_prob = 0, stamina_damage = 250)

/client/proc/respawn_list_players()
	set name = "Respawn List of Players"
	set desc = "Respawn the provided list of players."
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set popup_menu = FALSE
	ADMIN_ONLY

	var/list/ckeys = splittext(input(src, "Input list of players", "Ckeys with spaces as delimiters", null) as null|text, " ")
	if (!length(ckeys))
		return
	var/list/jobs = job_controls.staple_jobs + job_controls.special_jobs + job_controls.hidden_jobs
	sortList(jobs, /proc/cmp_text_asc)
	var/datum/job/job = tgui_input_list(usr, "Select job to respawn", "Respawn As", jobs)
	if (!job)
		return
	for (var/CK in ckeys)
		var/mob/M = ckey_to_mob(CK)
		if (!M)
			continue
		var/mob/new_player/NP = src.respawn_target(M)
		NP?.AttemptLateSpawn(job, force=TRUE)

/client/proc/cmd_admin_humanize(var/mob/M in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Humanize"
	set popup_menu = 0

	if (!ticker)
		SPAWN(0)
			alert("Wait until the game starts.")
		return

	if (istype(M, /mob/new_player) || istype(M, /mob/dead/target_observer)/* || istype(M, /mob/living/intangible/aicamera)*/)
		SPAWN(0)
			alert("You can't humanize new_player mobs or target observers.")
		return

	// You now get to chose (mostly) if you want to send the target to the arrival shuttle (Convair880).
	var/send_to_arrival_shuttle = 0
	if (iswraith(M))
		if (M.mind && M.mind.special_role == ROLE_WRAITH)
			remove_antag(M, src, 0, 1) // Can't complete specialist objectives as a human. Also, the proc takes care of the rest.
			return
		send_to_arrival_shuttle = 1
	else if (isintangible(M))
		if (M.mind && M.mind.special_role == ROLE_BLOB || M.mind.special_role == ROLE_FLOCKMIND || M.mind.special_role == ROLE_FLOCKTRACE)
			remove_antag(M, src, FALSE, TRUE) // Ditto.
			return
		send_to_arrival_shuttle = 1
	else if (isAI(M))
		send_to_arrival_shuttle = 1
	else
		switch (input(src, "Send mob to arrival shuttle?", "Auto-teleport", "No") in list("Yes", "No", "Cancel"))
			if ("Cancel")
				return
			if ("Yes")
				send_to_arrival_shuttle = 1
			if ("No")
				send_to_arrival_shuttle = 0
			else
				send_to_arrival_shuttle = 0

	if (issilicon(M))
		var/mob/living/silicon/S = M
		if (S.dependent && S.mainframe && isAI(S.mainframe))
			qdel(S.mainframe) // Delete mainframe if it's an AI-controlled robot.

	logTheThing(LOG_ADMIN, src, "has made [constructTarget(M,"admin")] a human.")
	logTheThing(LOG_DIARY, src, "has made [constructTarget(M,"diary")] a human.", "admin")
	message_admins("[key_name(src)] has made [key_name(M)] a human.")

	if (send_to_arrival_shuttle == 1)
		M.show_text("<h2><font color=red><B>You have been respawned as a human and send to the arrival shuttle. If this is an unexpected development, please inquire about it in adminhelp.</B></font></h2>", "red")
		return M.humanize(TRUE, FALSE, FALSE)
	else
		M.show_text("<h2><font color=red><B>You have been respawned as a human. If this is an unexpected development, please inquire about it in adminhelp.</B></font></h2>", "red")
		return M.humanize(FALSE, FALSE, FALSE)

/client/proc/cmd_admin_pop_off_all_the_limbs_oh_god()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Pop off everyone's limbs"
	set desc = "Oh christ no don't do this"

	if(alert("Really pop off everyone's limbs?", "JESUS CHRIST", "Yes, I'm a crazy bastard", "No") == "Yes, I'm a crazy bastard")
		logTheThing(LOG_ADMIN, src, "popped off all limbs.")
		logTheThing(LOG_DIARY, src, "has popped off all limbs", "admin")
		message_admins("[key_name(src)] has popped off everyone's limbs.")

		for (var/mob/living/M in mobs)
			for (var/obj/item/parts/P in M)
				P.sever()
				LAGCHECK(LAG_LOW)

			M.update_body()
	else
		alert("Thank fuck.")

//Special proc to set up the server for mapping via screenshots
/client/proc/mapWorld()
	set name = "Map World"
	set desc = "Takes a series of screenshots for mapping"
	SET_ADMIN_CAT(ADMIN_CAT_NONE)

	//Gotta prevent dummies
	var/confirm = tgui_alert(src.mob, "WARNING: This proc should absolutely not be run on a live server! Make sure you know what you are doing!", "WARNING", list("Cancel", "Proceed"))
	if(confirm == "Cancel")
		return

	//Viewport size
	var/viewport_width
	var/viewport_height
	var/inputView = input(src, "Set your desired viewport size. (30 for 300x300 maps, 50 for 200x200)", "Viewport Size", 30) as num //used to be 60 then lummox broke it
	if (inputView < 1)
		return
	else
		viewport_width = inputView
		viewport_height = inputView

	src.view = "[viewport_width]x[viewport_height]"

	//Z levels to map
	var/z
	var/allZ = 0
	var/safeAllZ = 0
	var/inputZ = input(src, "What Z level do you want to map? (10 for all levels, 11 for all except centcom level)", "Z Level", 11) as num
	if (inputZ < 1)
		return
	else if (inputZ == 10)
		allZ = 1
	else if (inputZ == 11)
		safeAllZ = 1
	else
		z = inputZ

	var/delay
	var/inputDelay = input(src, "Delay between changing location/taking screenshots. (If unsure, leave as as default)", "Delay", 7) as num
	if (inputDelay < 1)
		return
	else
		delay = inputDelay

	var/confirm2 = tgui_alert(src.mob, "Make everyone invisible? (Literally every mob)", "Invisible Mobs?", list("Yes", "No"))
	if (confirm2 == "Yes")
		//Make everyone invisible so they don't get in the way of screenshots
		for (var/mob/M in mobs)
			if (M.ckey)
				M.alpha = 0

	var/confirm3 = tgui_alert(src.mob, "Max out all power devices? (Prevents lights from going out mid-mapping)", "Max Power?", list("Yes", "No"))
	if (confirm3 == "Yes")
		//Max out all power (to avoid lights dying mid mapping)
		for(var/obj/machinery/power/apc/C in machine_registry[MACHINES_POWER])
			if(C.cell && C.z == 1)
				C.cell.charge = C.cell.maxcharge
		for(var/obj/machinery/power/smes/S in machine_registry[MACHINES_POWER])
			if(S.z != 1)
				continue
			S.charge = S.capacity
			S.output = 200000
			S.online = 1
			S.UpdateIcon()
			S.power_change()

	var/confirm4 = tgui_alert(src.mob, "Turn space bright pink? (For post processing/optimizations)", "Pink Background?", list("Yes", "No"))
	if (confirm4 == "Yes")
		//Make every space tile bright pink (for further processing via local image manipulation)
		for (var/turf/space/S in world)
			LAGCHECK(LAG_LOW)
			if (S.contents.len == 0 && S.overlays.len <= 1)//== 0) //Doesnt pinkify tiles with crap on top of them (transparant overlays fuck with the image processing later)
				S.icon = 'icons/effects/ULIcons.dmi'
				S.icon_state = "etc"
				S.color = transparentColor
				S.UpdateOverlays(null, "starlight", 1)

	var/confirm5 = tgui_alert(src.mob, "Make everything full bright?", "Fullbright?", list("Yes", "No"))
	if (confirm5 == "Yes")
		var/atom/plane = src.get_plane(PLANE_LIGHTING)
		if (plane)
			plane.alpha = 0

	var/confirm6 = tgui_alert(src.mob, "Disable drop shadowing?", "Dropshadows?", list("Yes", "No"))
	if (confirm6 == "Yes")
		winset(src, "menu.set_shadow", "is-checked=false")
		src.apply_depth_filter()

	var/confirm7 = tgui_alert(src.mob, "Reset client color matrix to identity matrix?", "Reset Color Matrix?", list("Yes", "No"))
	if (confirm7 == "Yes")
		src.set_saturation(1)
		src.set_color(COLOR_MATRIX_IDENTITY, FALSE)

	// Get fucked ghost HUD
	for (var/atom/movable/screen/ability/hudItem in src.screen)
		del(hudItem)

	// Also get fucked giant...planet...things
	for (var/obj/effects/background_objects/bgObj in world)
		del(bgObj)

	var/start_x = (viewport_width / 2) + 1
	var/start_y = (viewport_height / 2) + 1

	boutput(src, "<span class='notice'><B>Begining mapping.</B></span>")

	//Map eeeeverything
	if (allZ || safeAllZ)
		for (var/curZ = 1; curZ <= world.maxz; curZ++)
			if (safeAllZ && (curZ == 2 || curZ == 4))
				continue //Skips centcom
			for (var/y = start_y; y <= world.maxy; y += viewport_height)
				for (var/x = start_x; x <= world.maxx; x += viewport_width)
					src.mob.x = x
					src.mob.y = y
					src.mob.z = curZ
					sleep(delay)
					winset(src, null, "command=\".screenshot auto\"")
					out(src, "Screenshot taken at ([x], [y], [z])")
					sleep(delay)
			if (curZ != world.maxz)
				var/pause = tgui_alert(src.mob, "Z Level ([curZ]) finished. Organise your screenshot files and press Ok to continue or Cancel to cease mapping.", "Tea break", list("Ok", "Cancel"))
				if (pause == "Cancel")
					return
	//Or just one level I GUESS
	else
		for (var/y = start_y; y <= world.maxy; y += viewport_height)
			for (var/x = start_x; x <= world.maxx; x += viewport_width)
				src.mob.x = x
				src.mob.y = y
				src.mob.z = z
				sleep(delay)
				winset(src, null, "command=\".screenshot auto\"")
				out(src, "Screenshot taken at ([x], [y], [z])")
				sleep(delay)

	alert("Mapping complete!", "Yay!", "Ok")

/client/proc/view_cid_list(var/C as text)
	set name = "View CompID List"
	set desc = "View the list of observed computer IDs belonging to a key"
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)

	ADMIN_ONLY

	view_client_compid_list(usr, C)

/client/proc/cmd_chat_debug(var/client/C in clients)
	set name = "Debug Chat"
	set desc = "Opens a firebug console in the target's chat area"
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)

	ADMIN_ONLY

	if (src != C)
		var/trigger = (C.holder ? src.key : (src.stealth || src.fakekey ? src.fakekey : src.key))
		ehjax.send(C, "browseroutput", list("firebug" = 1, "trigger" = trigger))
		message_admins("[key_name(src)] has enabled Debug Chat mode on [key_name(C)]")
	else
		ehjax.send(C, "browseroutput", list("firebug" = 1))

/client/proc/blobsay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "blobsay"
	set hidden = 1
	ADMIN_ONLY
	if (!src.mob || src.player_mode)
		return

	if (src.holder.level < LEVEL_ADMIN)
		msg = copytext(sanitize(html_encode(msg)), 1, MAX_MESSAGE_LEN)
	logTheThing(LOG_ADMIN, src, "BLOBSAY: [msg]")
	logTheThing(LOG_DIARY, src, "BLOBSAY: [msg]", "admin")

	if (!msg)
		return
	var/show_other_key = 0
	if (src.stealth || src.alt_key)
		show_other_key = 1
	var/rendered = "<span class='game blobsay'><span class='prefix'>BLOB:</span> <span class='name'>ADMIN([show_other_key ? src.fakekey : src.key])</span> says, <span class='message'>\"[msg]\"</span></span>"
	var/adminrendered = "<span class='game blobsay'><span class='prefix'>BLOB:</span> <span class='name' data-ctx='\ref[src.mob.mind]'>[show_other_key ? "ADMIN([src.key] (as [src.fakekey])" : "ADMIN([src.key]"])</span> says, <span class='message'>\"[msg]\"</span></span>"

	for (var/mob/M in mobs)
		if(istype(M, /mob/new_player))
			continue

		if (M.client && (isblob(M) || M.client.holder && !M.client.player_mode))
			var/thisR = rendered
			if ((istype(M, /mob/dead/observer)||M.client.holder) && src.mob.mind)
				thisR = "<span class='adminHearing' data-ctx='[M.client.chatOutput.getContextFlags()]'>[adminrendered]</span>"
			M.show_message(thisR, 2)

//say to all changelings hiveminds
/client/proc/hivesay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "hivesay"
	set hidden = 1
	ADMIN_ONLY
	if (!src.mob || src.player_mode)
		return

	if (src.holder.level < LEVEL_ADMIN)
		msg = copytext(sanitize(html_encode(msg)), 1, MAX_MESSAGE_LEN)
	logTheThing(LOG_ADMIN, src, "HIVESAY: [msg]")
	logTheThing(LOG_DIARY, src, "HIVESAY: [msg]", "admin")

	if (!msg)
		return
	var/show_other_key = 0
	if (src.stealth || src.alt_key)
		show_other_key = 1
	var/rendered = "<span class='game hivesay'><span class='prefix'>HIVEMIND:</span> <span class='name'>ADMIN([show_other_key ? src.fakekey : src.key])</span> says, <span class='message'>\"[msg]\"</span></span>"
	var/adminrendered = "<span class='game hivesay'><span class='prefix'>HIVEMIND:</span> <span class='name' data-ctx='\ref[src.mob.mind]'>[show_other_key ? "ADMIN([src.key] (as [src.fakekey])" : "ADMIN([src.key]"])</span> says, <span class='message'>\"[msg]\"</span></span>"

	for (var/client/C in clients)
		var/mob/M = C.mob
		if(istype(M, /mob/new_player))
			continue

		var/is_in_hivemind = 0
		if (istype(M,/mob/living/critter/changeling) || istype(M,/mob/dead/target_observer/hivemind_observer))
			is_in_hivemind = 1

		else if (ischangeling(M))
			is_in_hivemind = 1

		if (is_in_hivemind || C.holder && !C.player_mode)
			var/thisR = rendered
			if (C.holder && src.mob.mind)
				thisR = "<span class='adminHearing' data-ctx='[M.client.chatOutput.getContextFlags()]'>[adminrendered]</span>"
			M.show_message(thisR, 2)

/client/proc/silisay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "silisay"
	ADMIN_ONLY
	if (!src.mob || src.player_mode)
		return

	if (src.holder.level < LEVEL_ADMIN)
		msg = copytext(sanitize(html_encode(msg)), 1, MAX_MESSAGE_LEN)
	logTheThing(LOG_ADMIN, src, "SILISAY: [msg]")
	logTheThing(LOG_DIARY, src, "SILISAY: [msg]", "admin")

	if (!msg)
		return
	var/show_other_key = 0
	if (src.stealth || src.alt_key)
		show_other_key = 1

	var/rendered = "<span class='game roboticsay'>Robotic Talk, <span class='name'>ADMIN([show_other_key ? src.fakekey : src.key])</span> says, <span class='message'>\"[msg]\"</span></span>"
	var/adminrendered = "<span class='game roboticsay'>Robotic Talk, <span class='name' data-ctx='\ref[src.mob.mind]'>[show_other_key ? "ADMIN([src.key] (as [src.fakekey])" : "ADMIN([src.key]"])</span> says, <span class='message'>\"[msg]\"</span></span>"

	for (var/mob/M in mobs)
		if (istype(M, /mob/new_player))
			continue
		if (M.client && (M.robot_talk_understand || M.client.holder && !M.client.player_mode))
			var/thisR = rendered
			if (M.client.holder && src.mob.mind)
				thisR = "<span class='adminHearing' data-ctx='[M.client.chatOutput.getContextFlags()]'>[adminrendered]</span>"
			M.show_message(thisR, 2)

/client/proc/dronesay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "dronesay"
	set hidden = 1
	ADMIN_ONLY
	if (!src.mob || src.player_mode)
		return

	if (src.holder.level < LEVEL_ADMIN)
		msg = copytext(sanitize(html_encode(msg)), 1, MAX_MESSAGE_LEN)
	logTheThing(LOG_ADMIN, src, "DRONESAY: [msg]")
	logTheThing(LOG_DIARY, src, "DRONESAY: [msg]", "admin")

	if (!msg)
		return
	var/show_other_key = 0
	if (src.stealth || src.alt_key)
		show_other_key = 1
	var/rendered = "<span class='game ghostdronesay'><span class='prefix'>DRONE:</span> <span class='name'>ADMIN([show_other_key ? src.fakekey : src.key])</span> says, <span class='message'>\"[msg]\"</span></span>"
	var/adminrendered = "<span class='game ghostdronesay'><span class='prefix'>DRONE:</span> <span class='name' data-ctx='\ref[src.mob.mind]'>[show_other_key ? "ADMIN([src.key] (as [src.fakekey])" : "ADMIN([src.key]"])</span> says, <span class='message'>\"[msg]\"</span></span>"

	for (var/mob/M in mobs)
		if (istype(M, /mob/new_player))
			continue

		if (M.client && (isghostdrone(M) || M.client.holder && !M.client.player_mode))
			var/thisR = rendered
			if (M.client.holder && src.mob.mind)
				thisR = "<span class='adminHearing' data-ctx='[M.client.chatOutput.getContextFlags()]'>[adminrendered]</span>"
			M.show_message(thisR, 2)


// let's keep xeroxing until all that remains is a faded butt - cirr
/client/proc/marsay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "marsay"
	set hidden = 1
	ADMIN_ONLY
	if (!src.mob || src.player_mode)
		return

	if (src.holder.level < LEVEL_ADMIN)
		msg = copytext(sanitize(html_encode(msg)), 1, MAX_MESSAGE_LEN)
	logTheThing(LOG_ADMIN, src, "MARSAY: [msg]")
	logTheThing(LOG_DIARY, src, "MARSAY: [msg]", "admin")

	if (!msg)
		return
	martian_speak(src.mob, msg, 1)

/client/proc/flocksay(msg as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "flocksay"
	set hidden = 1
	ADMIN_ONLY
	if (!src.mob || src.player_mode)
		return

	if (src.holder.level < LEVEL_ADMIN)
		msg = copytext(sanitize(html_encode(msg)), 1, MAX_MESSAGE_LEN)
	logTheThing(LOG_ADMIN, src, "FLOCKSAY: [msg]")
	logTheThing(LOG_DIARY, src, "FLOCKSAY: [msg]", "admin")

	if (!msg)
		return
	flock_speak(src.mob, msg, null, speak_as_admin = TRUE)


/client/proc/cmd_dectalk()
	set name = "Dectalk"
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set desc = "Sends a message as voice to all players"
	set popup_menu = 0

	var/msg
	if (length(args))
		msg = args[1]

	msg = input(src, "Sends a message as voice to all players", "Dectalk", msg) as null|message
	if (!msg) return 0

	var/audio = dectalk(msg)
	if (audio && audio["audio"])
		message_admins("[key_name(src)] has used the dectalk verb with message: [audio["message"]]")
		logTheThing(LOG_ADMIN, src, "has used the dectalk verb with message: [audio["message"]]")
		logTheThing(LOG_DIARY, src, "has used the dectalk verb with message: [audio["message"]]", "admin")

		for (var/client/C in clients)
			if (C.ignore_sound_flags & (SOUND_VOX | SOUND_ALL))
				continue
			var/trigger = src.key
			if (src.holder && (src.stealth || src.alt_key))
				trigger = (C.holder ? "[src.key] (as [src.fakekey])" : src.fakekey)
			var/vol = C.getVolume(VOLUME_CHANNEL_ADMIN)
			if (vol)
				C.chatOutput.playDectalk(audio["audio"], trigger, vol)
		return 1
	else if (audio && audio["cooldown"])
		alert(src, "There is a [nextDectalkDelay] second global cooldown between uses of this verb. Please wait [((world.timeofday + nextDectalkDelay * 10) - world.timeofday)/10] seconds.")
		src.cmd_dectalk(msg)
		return 0
	else
		alert(src, "An external server error has occurred. Please report this.")
		return 0

/client/proc/cmd_give_pet(var/mob/M as mob in world)
	set popup_menu = 0
	set name = "Give Pet"
	set desc = "Assigns someone a pet!  Woo!"
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	ADMIN_ONLY

	if (!M)
		M = tgui_input_list(src.mob, "Choose a target.", "Selection", mobs)
		if (!M)
			return
	var/pet_input = input("Enter path of the thing you want to give as a pet or enter a part of the path to search", "Enter Path", pick("/obj/critter/domestic_bee", "/obj/critter/parrot/random")) as null|text
	if (!pet_input)
		return
	var/pet_path = get_one_match(pet_input, /obj)
	if (!pet_path)
		return

	var/obj/Pet = new pet_path(get_turf(M))
	Pet.name = "[M]'s pet [Pet.name]"

	//Pets should probably not attack their owner
	if (istype(Pet, /obj/critter))
		var/obj/critter/CritterPet = Pet
		CritterPet.atkcarbon = 0
		CritterPet.atksilicon = 0

	logTheThing(LOG_ADMIN, usr ? usr : src, M, "gave [constructTarget(M,"admin")] a pet [pet_path]!")
	logTheThing(LOG_DIARY, usr ? usr : src, M, "gave [constructTarget(M,"diary")] a pet [pet_path]!", "admin")
	message_admins("[key_name(usr ? usr : src)] gave [M] a pet [pet_path]!")

/client/proc/cmd_give_pets(pet_input=null as text)
	set popup_menu = 0
	set name = "Give Pets"
	set desc = "Assigns everyone a pet! Enter part of the path of the thing you want to give."
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	ADMIN_ONLY

	if(isnull(pet_input))
		pet_input = input("Enter path of the thing you want to give people as pets or enter a part of the path to search", "Enter Path", pick("/obj/critter/domestic_bee", "/obj/critter/parrot/random")) as null|text
	if (!pet_input)
		return
	var/pet_path = get_one_match(pet_input, /obj)
	if (!pet_path)
		return

	for (var/mob/living/L in mobs)
		var/obj/Pet = new pet_path(get_turf(L))
		Pet.name = "[L]'s pet [Pet.name]"

		//Pets should probably not attack their owner
		if (istype(Pet, /obj/critter))

			var/obj/critter/CritterPet = Pet
			CritterPet.atkcarbon = 0
			CritterPet.atksilicon = 0

		LAGCHECK(LAG_LOW)

	logTheThing(LOG_ADMIN, usr ? usr : src, null, "gave everyone a pet [pet_path]!")
	logTheThing(LOG_DIARY, usr ? usr : src, null, "gave everyone a pet [pet_path]!", "admin")
	message_admins("[key_name(usr ? usr : src)] gave everyone a pet [pet_path]!")

/client/proc/cmd_give_player_pets(pet_input=null as text)
	set popup_menu = 0
	set name = "Give Player Pets"
	set desc = "Assigns every living player a pet! Enter part of the path of the thing you want to give."
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	ADMIN_ONLY

	if(isnull(pet_input))
		pet_input = input("Enter path of the thing you want to give people as pets or enter a part of the path to search", "Enter Path", pick("/obj/critter/domestic_bee", "/obj/critter/parrot/random")) as null|text
	if (!pet_input)
		return
	var/pet_path = get_one_match(pet_input, /obj)
	if (!pet_path)
		return

	for (var/client/cl as anything in clients)
		var/mob/living/L = cl.mob
		if(!istype(L) || isdead(L))
			continue
		var/obj/Pet = new pet_path(get_turf(L))
		Pet.name = "[L]'s pet [Pet.name]"

		//Pets should probably not attack their owner
		if (istype(Pet, /obj/critter))
			var/obj/critter/CritterPet = Pet
			CritterPet.atkcarbon = 0
			CritterPet.atksilicon = 0

		LAGCHECK(LAG_LOW)

	logTheThing(LOG_ADMIN, usr ? usr : src, null, "gave every player a pet [pet_path]!")
	logTheThing(LOG_DIARY, usr ? usr : src, null, "gave every player a pet [pet_path]!", "admin")
	message_admins("[key_name(usr ? usr : src)] gave every player a pet [pet_path]!")

/client/proc/cmd_customgrenade()
	set popup_menu = 0
	set name = "Custom Grenade"
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set desc = "Create a custom object spewing grenade"
	ADMIN_ONLY

	var/new_grenade = tgui_alert(src.mob, "Use the new thing throwing grenade?", "Cool new grenade?", list("Yes", "No")) == "Yes"
	var/obj_input = input("Enter path of the object you want the grenade to have or enter a part of the path to search", "Enter Path") as null|text
	if (!obj_input)
		return
	var/obj_path = get_one_match(obj_input, /atom/movable)
	if (!obj_path)
		return

	if(new_grenade)
		var/obj/item/old_grenade/thing_thrower/nade = new(usr.loc)
		nade.count = input("How many things?", "How many things?", 8) as null|num
		nade.payload = obj_path
		nade.name = "mysterious grenade"
		nade.desc = "There could be anything inside this."
	else
		var/obj/item/old_grenade/spawner/banana/nade = new /obj/item/old_grenade/spawner/banana(usr.loc)
		nade.payload = obj_path
		nade.name = "mysterious grenade"
		nade.desc = "There could be anything inside this."
	logTheThing(LOG_ADMIN, src, "spawned a custom grenade at [usr.loc]")
	logTheThing(LOG_DIARY, src, "spawned a custom grenade at [usr.loc]", "admin")
	message_admins("[key_name(src)] spawned a custom grenade at [usr.loc].")

/client/proc/admin_changes()
	set category = "Commands"
	set name = "Admin Changelog"
	set desc = "Show or hide the admin changelog"
	ADMIN_ONLY

	if (winget(src, "adminchanges", "is-visible") == "true")
		src.Browse(null, "window=adminchanges")
	else
		var/changelogHtml = grabResource("html/changelog.html")
		var/data = admin_changelog:html
		var/fontcssdata = {"
				<style type="text/css">
				@font-face {
					font-family: 'Twemoji';
					src: url('[resource("css/fonts/Twemoji.eot")]');
					src: url('[resource("css/fonts/Twemoji.eot")]') format('embedded-opentype'),
						 url('[resource("css/fonts/Twemoji.ttf")]') format('truetype');
					text-rendering: optimizeLegibility;
				}
				</style>
		"}
		changelogHtml = replacetext(changelogHtml, "<!-- CSS INJECT GOES HERE -->", fontcssdata)
		changelogHtml = replacetext(changelogHtml, "<!-- HTML GOES HERE -->", "[data]")
		src.Browse(changelogHtml, "window=adminchanges;size=500x650;title=Admin+Changelog;", 1)

/client/proc/removeSelf()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Remove Self"
	set desc = "Simply removes you from existence"
	set popup_menu = 0
	ADMIN_ONLY

	if (!src.mob)
		out(src, "<span class='alert'>You don't even exist!</span>")
		return

	if (istype(src.mob, /mob/dead/observer) || istype(src.mob, /mob/dead/target_observer))
		out(src, "<span class='alert'>You're already dead, you can't be removed any more than that!</span>")
		return
	if (flourish)
		for (var/mob/living/M in oviewers(5, get_turf(src.mob)))
			M.apply_flash(animation_duration = 30, weak = 5, uncloak_prob = 0, stamina_damage = 250)
		animate(src.mob, transform = matrix(50, 50, MATRIX_SCALE), time = 15, alpha = 0, easing = CIRCULAR_EASING, flags = EASE_OUT)
		sleep(1.5 SECONDS)

	var/mob/O = src.mob
	src.mob.ghostize()
	O.set_loc(null)
	if(src.holder.respawn_as_self_mob)
		qdel(src.holder.respawn_as_self_mob)
	src.holder.respawn_as_self_mob = O

/client/proc/removeOther(var/mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set name = "Remove Other"
	set desc = "Remove some other dude from the mortal plain"
	set popup_menu = 0
	ADMIN_ONLY

	if (!M)
		out(src, "<span class='alert'>You need to select someone to remove!</span>")
		return

	if (istype(M, /mob/dead/observer) || istype(M, /mob/dead/target_observer))
		out(src, "<span class='notice'>That person is already dead, sorry.</span>")
		return

	var/client/C
	if (M.client)
		C = M.client

	M.remove()

	var/Target = C ? C : M
	logTheThing(LOG_ADMIN, src, "removed [constructTarget(Target,"admin")] from existence!")
	logTheThing(LOG_DIARY, src, "removed [constructTarget(Target,"diary")] from existence!", "admin")
	message_admins("[key_name(src)] removed [key_name(C ? C : M)] from existence!")

/client/proc/cmd_change_map()
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "Switch Map"
	set desc = "Switch the map for the next round"
	set popup_menu = 0

	ADMIN_ONLY

	var/bustedMapSwitcher = isMapSwitcherBusted()
	if (bustedMapSwitcher)
		return alert(bustedMapSwitcher)

	if (mapSwitcher.nextMapIsVotedFor)
		var/ignorePlayerVote = tgui_alert(src.mob, "The next map was voted for by the players, are you sure you want to override it? This could be very rude!", "Ignore Players?", list("Yes", "No"))
		if (ignorePlayerVote == "No")
			return

	var/info = "Select a map"
	info += "\nCurrently on: [mapSwitcher.current]"
	if (mapSwitcher.next)
		info += "\nNext round's map will be: [mapSwitcher.next]"

	var/map = input(info, "Switch Map", mapSwitcher.next ? mapSwitcher.next : mapSwitcher.current) as null|anything in mapNames
	if (!map) return

	if (map == mapSwitcher.current && !mapSwitcher.next)
		return alert("The map is already on [map] you dunce!")

	try
		mapSwitcher.setNextMap(src.key, mapName = map)
	catch (var/exception/e)
		logTheThing(LOG_DEBUG, null, "<b>Map Switcher:</b> [e.name]")
		return alert("Oh no! Something went wrong with the map switcher. Details have been logged to the debug category.")

	logTheThing(LOG_ADMIN, usr ? usr : src, null, "set the next round's map to [map]")
	logTheThing(LOG_DIARY, usr ? usr : src, null, "set the next round's map to [map]", "admin")
	message_admins("[key_name(usr ? usr : src)] set the next round's map to [map]")

	var/announce = tgui_alert(src.mob, "Map set to [map]. It will apply next round.\n\nAnnounce this to the unwashed masses?", "All done", list("Ok", "Nah"))
	if (announce == "Ok")
		boutput(world, "<span class='notice'><b>The next round's map will be: [map]</b></span>")

/client/proc/cmd_start_map_vote()
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "Start Map Vote"
	set desc = "Start a player vote for the next map"
	set popup_menu = 0

	ADMIN_ONLY

	var/bustedMapSwitcher = isMapSwitcherBusted()
	if (bustedMapSwitcher)
		return alert(bustedMapSwitcher)

	if (!mapSwitcher.votingAllowed)
		return alert("Map votes are currently toggled off.")

	if (mapSwitcher.playersVoting)
		return alert("There is already a map vote underway.")

	var/duration = input("How long (in seconds) should this vote last? Enter 0 to last indefinitely (you'll need to manually end it).", "Duration?", 0) as num
	duration = duration * 10 //convert to deciseconds

	try
		mapSwitcher.startMapVote(duration = duration)
	catch (var/exception/e)
		logTheThing(LOG_DEBUG, null, "<b>Map Switcher:</b> [e.name]")
		return alert("Oh no! Something went wrong with the map switcher. Details have been logged to the debug category.")

	logTheThing(LOG_ADMIN, usr ? usr : src, null, "triggered a player map vote (duration: [duration])")
	logTheThing(LOG_DIARY, usr ? usr : src, null, "triggered a player map vote (duration: [duration])", "admin")
	message_admins("[key_name(usr ? usr : src)] triggered a player map vote (duration: [duration])")

/client/proc/cmd_end_map_vote()
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "End Map Vote"
	set desc = "End a player vote for the next map"
	set popup_menu = 0

	ADMIN_ONLY

	var/bustedMapSwitcher = isMapSwitcherBusted()
	if (bustedMapSwitcher)
		return alert(bustedMapSwitcher)

	if (!mapSwitcher.playersVoting)
		return alert("There isn't a vote currently underway.")

	try
		mapSwitcher.endMapVote()
	catch (var/exception/e)
		logTheThing(LOG_DEBUG, null, "<b>Map Switcher:</b> [e.name]")
		return alert("Oh no! Something went wrong with the map switcher. Details have been logged to the debug category.")

	logTheThing(LOG_ADMIN, usr ? usr : src, null, "ended the player map vote")
	logTheThing(LOG_DIARY, usr ? usr : src, null, "ended the player map vote", "admin")
	message_admins("[key_name(usr ? usr : src)] ended the player map vote")

/client/proc/cmd_cancel_map_vote()
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "Cancel Map Vote"
	set desc = "Cancel a player map vote without doing anything"
	set popup_menu = 0

	ADMIN_ONLY

	var/bustedMapSwitcher = isMapSwitcherBusted()
	if (bustedMapSwitcher)
		return alert(bustedMapSwitcher)

	if (!mapSwitcher.playersVoting)
		return alert("There isn't a vote currently underway.")

	var/really = tgui_alert(src.mob, "Are you sure you want to cancel the map vote before it's finished? This will discard all votes and do nothing.", "Dash player dreams?", list("Yes", "No"))
	if (really == "No")
		return

	try
		mapSwitcher.cancelMapVote()
	catch (var/exception/e)
		logTheThing(LOG_DEBUG, null, "<b>Map Switcher:</b> [e.name]")
		return alert("Oh no! Something went wrong with the map switcher. Details have been logged to the debug category.")

	logTheThing(LOG_ADMIN, usr ? usr : src, null, "cancelled the player map vote prematurely")
	logTheThing(LOG_DIARY, usr ? usr : src, null, "cancelled the player map vote prematurely", "admin")
	message_admins("[key_name(usr ? usr : src)] cancelled the player map vote prematurely. Rude.")

/client/proc/cmd_antag_history(var/ckey as text)
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set name = "View Antag History"
	set desc = "View the antag history for a given player"
	set popup_menu = 0
	ADMIN_ONLY

	if (!ckey)
		return

	var/list/history
	try
		history = antagWeighter.completeHistory(ckey)
	catch(var/exception/e)
		return alert(e.name)

	var/html = "<table>"
	html += "<thead><tr>"
	html += "<th>Mode</th>"
	html += "<th>Played</th>"
	html += "<th>Antag</th>"
	html += "<th>Chosen</th>"
	html += "<th>Target</th>"
	html += "</tr></thead>"

	for (var/role in config.play_antag_rates)
		var/list/data

		if (role in history)
			data = history[role]
		else
			//some round types are so rare, we might have no data for this player playing them, so we make shit up
			data = list(
				"seen" = 0,
				"selected" = 0,
				"percent" = 0
			)

		var/seen = round(text2num(data["seen"]))
		var/selected = round(text2num(data["selected"]))
		var/chosen = round(text2num(data["percent"]))
		var/target = config.play_antag_rates[role]

		var/chosenClass = "fine"
		//if the player has been chosen more than 50% over the target, show red
		if (chosen > target * 1.5)
			chosenClass = "danger"
		//or, if it's just over the target, show orange
		else if (chosen > target)
			chosenClass = "warning"

		html += "<tr>"
		html += "<td>[capitalize(role)]</td>"
		html += "<td>[seen]</td>"
		html += "<td>[selected]</td>"
		html += "<td class='[chosenClass]'>[chosen]%</td>"
		html += "<td>[target]%</td>"
		html += "</tr>"

	html += "</table>"

	var/antagHistoryHtml = grabResource("html/antagHistory.html")
	antagHistoryHtml = replacetext(antagHistoryHtml, "<!-- HTML GOES HERE -->", html)
	src.Browse(antagHistoryHtml, "window=antaghistory[ckey];title=[capitalize(ckey)]+Antag+History;")


/client/proc/cmd_dispatch_observe_to_ghosts(var/atom/movable/target)
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Alert All Ghosts"
	set desc = "Send a notice to ghosts that something weird is happening at a person"
	set popup_menu = 0
	ADMIN_ONLY

	if(ghost_notifier)
		ghost_notifier.send_notification(src, target, /datum/ghost_notification/observe/admin)

/client/proc/showLoadingHint()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set name = "Show Loading Hint"
	set desc = "Show everyone a fun loading screen hint."
	set waitfor = FALSE

	if (global.current_state != GAME_STATE_PREGAME)
		return
	var/hint = pick(dd_file2list("strings/roundstart_hints.txt"))
	for (var/client/C)
		if (!istype(C.mob,/mob/new_player))
			continue
		var/html = "\
<html>\
	<style>\
		body {background-color:black;}\
		div {text-align: center; font-family: Arial, sans-serif; font-size: 30px; top: 50%; width:100%; position:absolute; color:white;}\
    </style>\
    <body>\
		<div>Tip: [hint]</div>\
	</body>\
</html>"
		pregameHTML = html
		C << browse(html, "window=pregameBrowser")
		winshow(C, "pregameBrowser", 1)

/client/proc/showPregameHTML()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set name = "Display Pregame HTML"
	set desc = "Tired of boring map gimmicks on the pregame screen? Try HTML!"

	ADMIN_ONLY
	// Previous HTML (so you can replace without always resetting to the default)
	if(pregameHTML)
		if(alert("There's already some HTML shown. Do you want to remove or replace it?", "HTML clear?", "Remove", "Replace") == "Remove")
			pregameHTML = null
			message_admins("[key_name(src)] cleared the pre-game HTML.")
			logTheThing(LOG_ADMIN, src, "cleared the pre-game HTML.")
			for(var/client/C)
				try
					C<< browse("", "window=pregameBrowser")
					if(C)
						winshow(C, "pregameBrowser", 0)
				catch()
			var/turf/T = landmarks[LANDMARK_LOBBY_LEFTSIDE][1]
			T = locate(T.x + 3, T.y, T.z)
			if (locate(/obj/titlecard) in T) return
			if (alert("Replace with a title card turf?",, "Yes", "No") == "Yes")
				new /obj/titlecard(T)
			return
	var/newHTML = null
	if(alert("Do you want to upload an HTML file, or type it in?", "HTML Source", "Here", "Upload") == "Here")
		newHTML = input("Gib HTML, then.", "FEED ME HTML", pregameHTML) as message
	else
		newHTML = input("Upload that file!", "Upload that file!") as file|null
		if(newHTML)
			newHTML = file2text(newHTML)
	if(newHTML)
		pregameHTML = newHTML
		message_admins("[key_name(src)] changed the pre-game HTML.")
		logTheThing(LOG_ADMIN, src, "changed the pre-game HTML.")
		for(var/client/C)
			if(istype(C.mob, /mob/new_player))
				C << browse(pregameHTML, "window=pregameBrowser")
				if(C)
					winshow(C, "pregameBrowser", 1)
					var/mob/new_player/new_player = C.mob
					new_player.pregameBrowserLoaded = TRUE

/client/proc/implant_all()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Implant All"
	set desc = "Gives everyone a microbomb. You cannot undo this!!"

	ADMIN_ONLY
	microbombs_4_everyone()


/var/microbombs_4_everyone = 0

/proc/microbombs_4_everyone(var/bomb_power = null)
	if (isnull(bomb_power) && usr)
		bomb_power = input("Please enter bomb power. Set to 0 to turn off. Turning off will not get rid of or disable existing microbombs.") as null|num
		if (isnull(bomb_power))
			return
	microbombs_4_everyone = max(bomb_power, 0)
	message_admins("[key_name(usr)] [bomb_power > 0 ? "implanted everyone with a microbomb. Power: [bomb_power]" : "turned off microbombs for everyone."]")
	logTheThing(LOG_ADMIN, usr, "[bomb_power > 0 ? "implanted everyone with a microbomb. Power: [bomb_power]" : "turned off microbombs for everyone."]")
	if (microbombs_4_everyone > 0)
		var/implanted = 0
		for (var/mob/living/carbon/human/H in mobs)
			var/obj/item/implant/revenge/microbomb/MB = new (H)
			MB.power = microbombs_4_everyone
			implanted ++
		SPAWN(3 SECONDS)
			boutput(usr, "<span class='alert'>Implanted [implanted] people with microbombs. Any further humans that spawn will also have bombs.</span>")
	else
		boutput(usr, "<span class='alert'>Turned off spawning with microbombs. No existing microbombs have been deleted or disabled.</span>")

/client/proc/set_nukie_score()
	set popup_menu = 0
	set name = "Set Nuke-Ops Scoreboard Values"
	set desc = "Manually assign values to the nuke ops win/loss scoreboard."
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	ADMIN_ONLY
	DENY_TEMPMIN

	var/win_value = input("Enter new win value.") as num
	world.save_intra_round_value("nukie_win", win_value)

	var/lose_value = input("Enter new lose value.") as num
	world.save_intra_round_value("nukie_loss", lose_value)

	world.save_intra_round_value("nukie_last_reset", world.realtime)

	logTheThing(LOG_ADMIN, usr ? usr : src, null, "set nuke ops values to [win_value] wins and [lose_value] loses.")
	logTheThing(LOG_DIARY, usr ? usr : src, null, "set nuke ops values to [win_value] wins and [lose_value] loses.", "admin")
	message_admins("[key_name(usr ? usr : src)] set nuke ops values to [win_value] wins and [lose_value] loses.")

/client/proc/set_pod_wars_score()
	set popup_menu = 0
	set name = "Set Pod Wars Scoreboard Values"
	set desc = "Manually assign values to the Pod Wars Nanotrasen/Syndicate wins scoreboard."
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	ADMIN_ONLY
	DENY_TEMPMIN

	var/nt_win_value = input("Enter new Nanotrasen win value.") as num
	world.save_intra_round_value("nt_win", nt_win_value)

	var/sy_win_value = input("Enter new Syndicate loss value.") as num
	world.save_intra_round_value("sy_win", sy_win_value)

	world.save_intra_round_value("pod_wars_last_reset", world.realtime)

	logTheThing(LOG_ADMIN, usr ? usr : src, null, "set pod war win values to [nt_win_value] Nanotrasen wins and [sy_win_value] Syndicate wins.")
	logTheThing(LOG_DIARY, usr ? usr : src, null, "set pod war win values to [nt_win_value] Nanotrasen wins and [sy_win_value] Syndicate wins.", "admin")
	message_admins("[key_name(usr ? usr : src)] set pod war win values to [nt_win_value] Nanotrasen wins and [sy_win_value] Syndicate wins.")

/client/proc/set_pod_wars_deaths()
	set popup_menu = 0
	set name = "Set Pod Wars Death Scoreboard Values"
	set desc = "Manually assign values to the Pod Wars Nanotrasen/Syndicate deaths scoreboard."
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	ADMIN_ONLY
	DENY_TEMPMIN

	var/nt_death_value = input("Enter new Nanotrasen death value.") as num
	world.save_intra_round_value("nt_death", nt_death_value)

	var/sy_death_value = input("Enter new Syndicate death value.") as num
	world.save_intra_round_value("sy_death", sy_death_value)

	world.save_intra_round_value("pod_wars_last_reset", world.realtime)

	logTheThing(LOG_ADMIN, usr ? usr : src, null, "set pod war death values to [nt_death_value] Nanotrasen deaths and [sy_death_value] Syndicate deaths.")
	logTheThing(LOG_DIARY, usr ? usr : src, null, "set pod war death values to [nt_death_value] Nanotrasen deaths and [sy_death_value] Syndicate deaths.", "admin")
	message_admins("[key_name(usr ? usr : src)] set pod war death values to [nt_death_value] Nanotrasen deaths and [sy_death_value] Syndicate deaths.")

/client/proc/clear_nukeop_uplink_purchases()
	set popup_menu = 0
	set name = "Wipe Nukie Boss Stats"
	set desc = "Wipe the intra-round stats of the nukeop commander's uplink purchases"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	ADMIN_ONLY
	DENY_TEMPMIN

	var/confirm = input(usr, "Are you SURE you want to clear the stats?") in list("Yes", "No")
	if(!(confirm == "Yes"))
		return
	for(var/datum/syndicate_buylist/commander/commander_datum in syndi_buylist_cache)
		world.save_intra_round_value("NuclearCommander-[commander_datum]-Purchased", 0)

	logTheThing(LOG_ADMIN, usr ? usr : src, null, "wiped the Nuclear Operative Commander uplink purchase stats.")
	logTheThing(LOG_DIARY, usr ? usr : src, null, "wiped the Nuclear Operative Commander uplink purchase stats.", "admin")
	message_admins("[key_name(usr ? usr : src)] wiped the Nuclear Operative Commander uplink purchase stats.")

/mob/verb/admin_interact_verb()
	set name = "admin_interact"
	set hidden = 1
	USR_ADMIN_ONLY
	src.client.admin_intent = 1
	src.client.show_popup_menus = 0
	src.update_cursor()

/mob/proc/admin_interact(var/atom/A,var/list/parameters)
	src.client.admin_intent = 0
	src.client.show_popup_menus = 1
	src.update_cursor()
	USR_ADMIN_ONLY


	if (parameters["right"])
		var/turf/clicked_turf = get_turf(A)
		var/x_shift = round(text2num(parameters["icon-x"]) / 32)
		var/y_shift = round(text2num(parameters["icon-y"]) / 32)
		clicked_turf = locate(clicked_turf.x + x_shift, clicked_turf.y + y_shift, clicked_turf.z)
		var/list/atom/atoms = list()
		for(var/atom/thing as anything in list(clicked_turf) + clicked_turf.contents)
			if(thing.name)
				atoms += thing
			else if(!istype(thing, /obj/effect) && !istype(thing, /obj/overlay/tile_effect))
				if(initial(thing.name))
					atoms["nameless [initial(thing.name)]"] = thing
				else
					atoms["nameless [thing.type]"] = thing
		if (atoms.len)
			A = tgui_input_list(src, "Which item to admin-interact with?", "Admin interact", atoms)
			if (isnull(A)) return
		if(istext(A))
			A = atoms[A]

	var/title = "What do?"
	var/list/verbs = list()
	if (!client.holder.disable_atom_verbs)
		title += " (atom verbs ON)"
		verbs += client.holder.admin_interact_atom_verbs
	if (ismob(A))
		verbs += client.holder.admin_interact_verbs["mob"]
	else if (isturf(A))
		verbs += client.holder.admin_interact_verbs["turf"]
	else
		verbs += client.holder.admin_interact_verbs["obj"]
		if (isobj(A))
			var/obj/object = A
			if (istype(object.artifact, /datum/artifact))
				verbs += "Activate Artifact"

	var/typeinfo/atom/typeinfo = A.get_typeinfo()
	var/list/type_procs = list()
	if (typeinfo.admin_procs)
		for (var/procpath/proc_path as anything in typeinfo.admin_procs)
			var/proc_name = proc_path.name
			if (!proc_name)
				var/split_list = splittext("[proc_path]", "/")
				proc_name = split_list[length(split_list)]
			type_procs["[proc_name] *"] = proc_path
	verbs += type_procs

	if (length(type_procs))
		title += " ([length(type_procs)] custom)"

	var/choice = tgui_input_list(src, title, "[A]", verbs, start_with_search=FALSE)

	var/client/C = src.client
	if (choice in type_procs)
		call(A, type_procs[choice])()
		src.update_cursor()
		return

	switch(choice)
		if("Get Thing")
			C.cmd_admin_get_mobject(A)
		if("Follow Thing")
			C.admin_follow_mobject(A)
		if("Manage Bioeffects")
			C.cmd_admin_managebioeffect(A)
		if("Manage Abilities")
			C.cmd_admin_manageabils(A)
		if("Manage Traits")
			C.cmd_admin_managetraits(A)
		if("Add Reagents")
			C.addreagents(A)
		if("Check Reagents")
			C.cmd_admin_check_reagents(A)
		if("View Variables")
			C.debug_variables(A)
		if("View Fingerprints")
			C.view_fingerprints(A)
		if("Delete")
			C.cmd_admin_delete(A)
		if("Copy Here")
			semi_deep_copy(A, src.loc)
		if("Ship to Cargo")
			C.cmd_admin_ship_movable_to_cargo(A)

		if("Player Options")
			C.cmd_admin_playeropt(A)
		if("Private Message")
			C.cmd_admin_pm(A)
		if("Subtle Message")
			C.cmd_admin_subtle_message(A)
		if("Check Health")
			C.cmd_admin_check_health(A)
		if("Heal")
			C.cmd_admin_rejuvenate(A)
		if("Gib")
			C.cmd_admin_gib(A)
		if("Polymorph")
			C.cmd_admin_polymorph(A)
		if("Modify Organs")
			C.modify_organs(A)
		if("Modify Parts")
			C.modify_parts(A)
		if("Modify Module")
			C.edit_module(A)
		if("Swap Minds")
			C.cmd_swap_minds(A)
		if("Transfer Client To")
			C.cmd_transfer_client(A)
		if("Shamecube")
			C.cmd_shame_cube(A)

		if("Jump To Turf")
			C.jumptoturf(A)
		if("Air Status")
			C.air_status(A)
		if("Create Explosion")
			C.cmd_explosion(A)
		if("Create Fluid")
			C.admin_fluid(A)
		if("Create Smoke")
			C.admin_smoke(A)
		if("Create Portal")
			C.create_portal(A)
		if("Get Telesci Coords")
			C.getturftelesci(A)

		if ("Possess")
			if(istype(A, /mob))
				possessmob(A)
			else
				possess(A)
		if ("Create Poster")
			C.generate_poster(A)

		if ("Spin")
			C.cmd_spin_target(A)
		if ("Rotate")
			C.cmd_rotate_target(A)
		if ("Scale")
			C.cmd_scale_target(A)
		if ("Emag")
			C.cmd_emag_target(A)
		if ("Set Material")
			C.cmd_set_material(A)
		if ("Activate Artifact")
			var/obj/object = A
			object.ArtifactActivated()

	src.update_cursor()


/client/proc/vpn_whitelist_add(vpnckey as text)
	set name = "VPN whitelist add"
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	ADMIN_ONLY
	DENY_TEMPMIN
	vpnckey = ckey(vpnckey)
	try
		apiHandler.queryAPI("vpncheck-whitelist/add", list("ckey" = vpnckey, "akey" = src.ckey))
	catch(var/exception/e)
		message_admins("Error while adding ckey [vpnckey] to the VPN whitelist: [e.name]")
		return 0
	global.vpn_ip_checks?.Cut() // to allow them to reconnect this round
	message_admins("Ckey [vpnckey] added to the VPN whitelist by [src.key].")
	logTheThing(LOG_ADMIN, src, "Ckey [vpnckey] added to the VPN whitelist.")
	addPlayerNote(vpnckey, src.ckey, "Ckey [vpnckey] added to the VPN whitelist.")
	return 1

/client/proc/vpn_whitelist_remove(vpnckey as text)
	set name = "VPN whitelist remove"
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	ADMIN_ONLY
	DENY_TEMPMIN
	vpnckey = ckey(vpnckey)
	try
		apiHandler.queryAPI("vpncheck-whitelist/remove", list("ckey" = vpnckey, "akey" = src.ckey))
	catch(var/exception/e)
		message_admins("Error while removing ckey [vpnckey] from the VPN whitelist: [e.name]")
		return 0
	message_admins("Ckey [vpnckey] removed from the VPN whitelist by [src.key].")
	logTheThing(LOG_ADMIN, src, "Ckey [vpnckey] removed from the VPN whitelist.")
	return 1

/client/proc/cmd_lightsout()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Lights Out"
	set desc = "Force off all station lighting for a duration"
	ADMIN_ONLY
	if(!isadmin(src))
		boutput(src, "Only administrators may use this command.")
		return

	var/dur = input(usr, "Input duration (in seconds)", "lightsout duration", 0) as null|num

	if(dur)
		var i = 0
		for_by_tcl(apc, /obj/machinery/power/apc)
			if(apc.z == 1)
				if((i++ % 5) == 0)
					sleep(1 SECOND)
				apc.setStatus("lightsout", dur SECONDS)

/client/proc/flock_cheat()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Flock cheats"
	set desc = "Toggle cheats on or off on a particular flock"

	var/cheats = list(FLOCK_ACHIEVEMENT_CHEAT_STRUCTURES, FLOCK_ACHIEVEMENT_CHEAT_COMPUTE)
	var/cheat = tgui_input_list(src, "Pick a cheat to enable", "Flock cheats", cheats)
	if (!(cheat in cheats))
		return
	var/flockname = tgui_input_list(src, "Pick a flock", "Choose flock", flocks)
	var/datum/flock/flock = flocks[flockname]
	if (!flock)
		return
	var/toggle
	if (!flock.hasAchieved(cheat))
		toggle = TRUE
		flock.achieve(cheat)
	else
		toggle = FALSE
		flock.unAchieve(cheat)
	boutput(src, "[cheat] turned [toggle ? "on" : "off"] for flock [flockname]")
	logTheThing(LOG_ADMIN, src, "has toggled [cheat] [toggle ? "on" : "off"] for flock [flockname]")

/client/proc/upload_uncool_words()
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Upload Uncool Words"
	set desc = "Upload a JSON file for the uncool words list"
	ADMIN_ONLY
	DENY_TEMPMIN

	global.phrase_log?.upload_uncool_words()
	global.phrase_log?.load()


/client/proc/whitelist_add_temp(ckey as text)
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set name = "Whitelist Add Temp"
	set desc = "Temporarily whitelist a ckey (for this round only)"
	ADMIN_ONLY
	DENY_TEMPMIN

	ckey = ckey(ckey)
	if(!ckey)
		return

	if(isnull(global.whitelistCkeys))
		global.whitelistCkeys = list()
	global.whitelistCkeys += ckey


/client/proc/whitelist_toggle()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle Whitelist"
	set desc = "Toggle the server whitelist on or off"
	ADMIN_ONLY
	DENY_TEMPMIN

	var/current_status = config.whitelistEnabled ? "ON" : "OFF"
	if(!config.whitelistEnabled && config.baseWhitelistEnabled)
		if(config.roundsLeftWithoutWhitelist == 0)
			current_status += " (will be enabled next round)"
		else
			current_status += " (will be enabled in [config.roundsLeftWithoutWhitelist] rounds)"

	if(tgui_alert(src, "The whitelist is currently [current_status]. Are you sure you want to change that?", "Toggle whitelist?", list("Yes", "No")) != "Yes")
		return

	if(config.whitelistEnabled)
		var/rounds_duration = 0
		if(config.baseWhitelistEnabled)
			rounds_duration = tgui_input_number(src, "How many rounds should the whitelist be disabled for? (0 = just current round)", "Whitelist duration", 0, 10, 0)
		if(isnull(rounds_duration))
			return
		if(rounds_duration)
			message_admins("[src] has disabled the whitelist for [rounds_duration] round\s.")
			logTheThing(LOG_ADMIN, src, null, "Disabled the whitelist for [rounds_duration] round\s.")
			world.save_intra_round_value("whitelist_disabled", rounds_duration)
		else
			message_admins("[src] has disabled the whitelist for the rest of the round.")
			logTheThing(LOG_ADMIN, src, null, "Disabled the whitelist for the rest of the round.")
		config.whitelistEnabled = FALSE
		config.roundsLeftWithoutWhitelist = rounds_duration
	else
		var/kick_existing = tgui_alert(src, "Do you want to kick all players who are not whitelisted?", "Kick non-whitelisted players?", list("Yes", "No")) == "Yes"
		config.whitelistEnabled = TRUE
		config.roundsLeftWithoutWhitelist = 0
		if(kick_existing)
			for(var/client/C in clients)
				if(C.holder || (C in global.whitelistCkeys))
					continue
				boutput(C, "<span class='alert' style='font-size: 2.5em;'>You have been kicked from the server because the whitelist got enabled and you are not whitelisted.</span>")
				del(C)
		message_admins("[src] has enabled the whitelist [kick_existing ? "and kicked all non-whitelisted players" : ""]")
		logTheThing(LOG_ADMIN, src, null, "Enabled the whitelist [kick_existing ? "and kicked all non-whitelisted players" : ""]")
		world.save_intra_round_value("whitelist_disabled", 0)

	set_station_name(src.mob, manual=FALSE, name=station_name)

/client/proc/set_conspiracy_objective()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set name = "Set Conspiracy Objective"
	set desc = "Set a custom objective for all conspirators. Works fine in non-conspiracy modes."
	ADMIN_ONLY
	//comedic type abuse time
	var/datum/antagonist/conspirator/type = /datum/antagonist/conspirator
	var/objective_text = input(usr, "Input a custom objective for the conspiracy to follow (leave blank for random)", "Custom objective")
	if (length(objective_text))
		type.conspirator_objective = new /datum/objective/conspiracy(objective_text)
		boutput(usr, "Conspiracy objective set to: [type.conspirator_objective.explanation_text]")
	else
		boutput(usr, "Custom objective cleared, conspiracy will select a random objective.")
		type.conspirator_objective = null
