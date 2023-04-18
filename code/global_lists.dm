proc/initialize_global_lists()

	// for a more complete list see https://gn32.uk/f/byond-typeids.txt
	global.type_ids = list(
		/turf = "01",
		/obj = "02",
		/mob = "03",
		/area = "04",
		/client = "05",
		// strings are "06"
		/image = "0d",
		/datum = "21"
	)



	global.addr_padding = list("00000", "0000", "000", "00", "0", "")



	global.singletons = list()


	/// contains lists of objects indexed by their type based on [START_TRACKING] / [STOP_TRACKING]
	global.by_type = list()


	/// contains lists of objects indexed by a category string based on START_TRACKING_CAT / STOP_TRACKING_CAT
	global.by_cat = list()




	global.toggleable_admin_verb_categories = list(
		ADMIN_CAT_PLAYERS,
		ADMIN_CAT_SERVER,
		// not ADMIN_CAT_SELF because it contains Change Admin Preferences
		ADMIN_CAT_ATOM,
		ADMIN_CAT_SERVER_TOGGLES,
		ADMIN_CAT_FUN,
		ADMIN_CAT_DEBUG
	)



	/// Global static list of rarity color associations
	global.RARITY_COLOR = list("#9d9d9d", "#ffffff", "#1eff00", "#0070dd", "#a335ee", "#ff8000", "#ff0000")


	/// see match_material_pattern() for exact definitions
	global.material_category_names = list(
		"ALL"   = "Any Material",
		"CON-1" = "Conductive Material",
		"CON-2" = "High Energy Conductor",
		"CRY-1" = "Crystal",
		"DEN-1" = "High Density Matter",
		"DEN-2" = "Very High Density Matter",
		"CRY-2" = "Extraordinarily Dense Crystalline Matter",
		"FAB-1" = "Fabric",
		"INS-1" = "Insulative Material",
		"INS-2" = "Highly Insulative Material",
		"MET-1" = "Metal",
		"MET-2" = "Sturdy Metal",
		"MET-3" = "Extremely Tough Metal",
		"POW-1" = "Power Source",
		"POW-2" = "Significant Power Source",
		"POW-3" = "Extreme Power Source",
		"REF-1" = "Reflective Material",
		"ORG|RUB" = "Organic or Rubber Material",
		"RUB" = "Rubber Material",
		"WOOD" = "Wood"
	)



	global.audio_channel_name_to_id = list(
		"master" = VOLUME_CHANNEL_MASTER,
		"game" = VOLUME_CHANNEL_GAME,
		"ambient" = VOLUME_CHANNEL_AMBIENT,
		"radio" = VOLUME_CHANNEL_RADIO,
		"admin" = VOLUME_CHANNEL_ADMIN,
		"emote" = VOLUME_CHANNEL_EMOTE,
		"mentorpm" = VOLUME_CHANNEL_MENTORPM
	)



	#ifdef ENABLE_SPAWN_DEBUG
	global.global_spawn_dbg = list()
	#elif defined(ENABLE_SPAWN_DEBUG_2)
	global.detailed_spawn_dbg = list()
	#endif


	#ifdef DELETE_QUEUE_DEBUG
	global.detailed_delete_count = list()
	global.detailed_delete_gc_count = list()
	#endif

	#ifdef MACHINE_PROCESSING_DEBUG
	global.detailed_machine_timings = list()
	global.detailed_machine_power_log_zlevels = (1 << Z_LEVEL_STATION)
	#endif

	#ifdef QUEUE_STAT_DEBUG
	global.queue_stat_list = list()
	#endif

	// dumb, bad
	global.extra_resources = list('interface/fonts/pressstart2p.ttf', 'interface/fonts/ibmvga9.ttf', 'interface/fonts/xfont.ttf', 'interface/fonts/statusdisp.ttf')
	// Press Start 2P - 6px


	//playerPickable defines whether the map can be chosen by players when voting on a new map.
	global.mapNames = list(
		"Clarion" =				list("id" = "CLARION",		"settings" = "destiny/clarion", "playerPickable" = TRUE,	"MaxPlayersAllowed" = 60),
	#ifdef RP_MODE
		"Cogmap 1" =			list("id" = "COGMAP",		"settings" = "cogmap",			"playerPickable" = TRUE,	"MinPlayersAllowed" = 14),
	#else
		"Cogmap 1" =			list("id" = "COGMAP",		"settings" = "cogmap",			"playerPickable" = TRUE,	"MaxPlayersAllowed" = 80),
	#endif
		//"Construction" =		list("id" = "CONSTRUCTION", "settings" = "construction"),
		"Cogmap 1 (Old)" =		list("id" = "COGMAP_OLD",	"settings" = "cogmap_old"),
		"Cogmap 2" =			list("id" = "COGMAP2",		"settings" = "cogmap2",			"playerPickable" = TRUE, 	"MinPlayersAllowed" = 40),
		"Destiny" =				list("id" = "DESTINY",		"settings" = "destiny",			"playerPickable" = FALSE,	"MaxPlayersAllowed" = 80),
		"Donut 2" =				list("id" = "DONUT2",		"settings" = "donut2",			"playerPickable" = TRUE,	"MaxPlayersAllowed" = 80),
		"Donut 3" =				list("id" = "DONUT3",		"settings" = "donut3",			"playerPickable" = TRUE, 	"MinPlayersAllowed" = 40),
		"Horizon" =				list("id" = "HORIZON",		"settings" = "horizon",			"playerPickable" = FALSE),
		"Crash" = 				list("id" = "CRASH",		"settings" = "horizon/crash",	"playerPickable" = FALSE),
		"Mushroom" =			list("id" = "MUSHROOM",		"settings" = "mushroom",		"playerPickable" = FALSE),
		"Trunkmap" =			list("id" = "TRUNKMAP",		"settings" = "trunkmap",		"playerPickable" = FALSE),
		"Oshan Laboratory"= 	list("id" = "OSHAN",		"settings" = "oshan",			"playerPickable" = TRUE),
		"1 pamgoC" =			list("id" = "PAMGOC",		"settings" = "pamgoc",			"playerPickable" = FALSE),
		"Kondaru" =				list("id" = "KONDARU",		"settings" = "kondaru",			"playerPickable" = TRUE,	"MaxPlayersAllowed" = 80),
		"Ozymandias" =			list("id" = "OZYMANDIAS",	"settings" = "ozymandias",		"playerPickable" = FALSE,	"MinPlayersAllowed" = 40),
		"Nadir" =				list("id" = "NADIR",		"settings" = "nadir",			"playerPickable" = TRUE,	"MaxPlayersAllowed" = 70),
		"Bellerophon Fleet" =	list("id" = "FLEET",		"settings" = "fleet",			"playerPickable" = FALSE),
		//"Density" = 			list("id" = "DENSITY",		"settings" = "density",			"playerPickable" = FALSE,	"MaxPlayersAllowed" = 30),
		"Atlas" =				list("id" = "ATLAS",		"settings" = "atlas",			"playerPickable" = TRUE,	"MaxPlayersAllowed" = 30),
		"Manta" =				list("id" = "MANTA",		"settings" = "manta",			"playerPickable" = FALSE,	"MaxPlayersAllowed" = 80),
		"Wrestlemap" =			list("id" = "WRESTLEMAP",	"settings" = "wrestlemap",		"playerPickable" = FALSE),
		"pod_wars" =			list("id" = "POD_WARS",		"settings" = "pod_wars",		"playerPickable" = FALSE),
		"Event" =				list("id" = "EVENT",		"settings" = "destiny/clarion",	"playerPickable" = FALSE),
		"blank" =				list("id" = "BLANK",		"settings" = "", 				"playerPickable" = FALSE),
		"blank_underwater" =	list("id" = "BLANK_UNDERWATER", "settings" = "", 			"playerPickable" = FALSE)
	)


	#ifdef DETAILED_POOL_STATS
	global.pool_stats = list()
	#endif


	#ifdef DEBUG_MOVING_LIGHTS_STATS
	global.moving_lights_stats = list()
	global.moving_lights_stats_by_first_attached = list()
	global.color_changing_lights_stats = list()
	global.color_changing_lights_stats_by_first_attached = list()
	#endif


	/// global list of all named colors
	global.named_colors = list()
	/// global cache of all named colors once fetched with a color rgba
	global.named_color_cache = list()



	global.pipe_networks = list()
	//


	global.bad_name_characters = list("_", "'", "\"", "<", ">", ";", "\[", "\]", "{", "}", "|", "\\", "/")
	var/list/removed_jobs = list(
		// jobs that have been removed or replaced (replaced -> new name, removed -> null)
		"Barman" = "Bartender",
		"Mechanic" = "Engineer",
	)

	// if it's a list then we'll pick from the options in the list
	global.hair_details = list("einstein" = /datum/customization_style/hair/short/einalt,\
		"80s" = /datum/customization_style/hair/long/eightiesfade,\
		"glammetal" = /datum/customization_style/hair/long/glammetalO,\
		"lionsmane" = /datum/customization_style/hair/long/lionsmane_fade,\
		"longwaves" = /datum/customization_style/hair/long/longwaves_fade,\
		"ripley" = /datum/customization_style/hair/long/ripley_fade,\
		"violet" = /datum/customization_style/hair/long/violet_fade,\
		"willow" = /datum/customization_style/hair/long/willow_fade,\
		"rockponytail" = /datum/customization_style/hair/hairup/rockponytail_fade,\
		"pompompigtail" = /datum/customization_style/hair/long/flatbangs, /datum/customization_style/hair/long/twobangs_long,\
		"breezy" = /datum/customization_style/hair/long/breezy_fade,\
		"flick" = /datum/customization_style/hair/short/flick_fade,\
		"mermaid" = /datum/customization_style/hair/long/mermaidfade,\
		"smoothwave" = /datum/customization_style/hair/long/smoothwave_fade,\
		"longbeard" = /datum/customization_style/beard/longbeardfade,\
		"pomp" = /datum/customization_style/hair/short/pompS,\
		"mohawk" = list(/datum/customization_style/hair/short/mohawkFT, /datum/customization_style/hair/short/mohawkFB, /datum/customization_style/hair/short/mohawkS),\
		"emo" = /datum/customization_style/hair/short/emoH,\
		"clown" = list(/datum/customization_style/hair/short/clownT, /datum/customization_style/hair/short/clownM, /datum/customization_style/hair/short/clownB),\
		"dreads" = /datum/customization_style/hair/long/dreadsA,\
		"afro" = list(/datum/customization_style/hair/short/afroHR, /datum/customization_style/hair/short/afroHL, /datum/customization_style/hair/short/afroST, /datum/customization_style/hair/short/afroSM, /datum/customization_style/hair/short/afroSB, /datum/customization_style/hair/short/afroSL, /datum/customization_style/hair/short/afroSR, /datum/customization_style/hair/short/afroSC, /datum/customization_style/hair/short/afroCNE, /datum/customization_style/hair/short/afroCNW, /datum/customization_style/hair/short/afroCSE, /datum/customization_style/hair/short/afroCSW, /datum/customization_style/hair/short/afroSV, /datum/customization_style/hair/short/afroSH))


	// all these icon state names are ridiculous
	global.feminine_ustyles = list("No Underwear" = "none",\
		"Bra and Panties" = "brapan",\
		"Tanktop and Panties" = "tankpan",\
		"Bra and Boyshorts" = "braboy",\
		"Tanktop and Boyshorts" = "tankboy",\
		"Panties" = "panties",\
		"Boyshorts" = "boyshort")
	global.masculine_ustyles = list("No Underwear" = "none",\
		"Briefs" = "briefs",\
		"Boxers" = "boxers",\
		"Boyshorts" = "boyshort")

	global.male_screams = list("male", "malescream4", "malescream5", "malescream6", "malescream7")
	global.female_screams = list("female", "femalescream1", "femalescream2", "femalescream3", "femalescream4")



	//some things (mostly items places on the map) call procs on this datum before it exists, queue them instead
	var/global/list/hydro_controller_queue = list(
		"species" = list(),
		"mutation" = list(),
		"strain" = list()
	)



	global.asteroid_blocked_turfs = list()



	/// Global list to handle multiple flocks existing
	global.flockstats_global = list()




	global.football_spawns = list("join" = list(), "blue" = list(), "red" = list(), "bluefield" = list(), "redfield" = list(), "football" = list())
	global.football_players = list("blue" = list(), "red" = list())



	/// Populated by proc call in world.New()
	global.admins = list()
	global.onlineAdmins = list()


	/// Players whomst'd've get allowed if whitelist-only is enabled
	global.whitelistCkeys = list()

	// Players who are allowed to bypass the server's player cap
	global.bypassCapCkeys = list()



	global.occupations = list(

		"Chief Engineer",
		"Engineer","Engineer","Engineer",
		"Miner","Miner","Miner",
		"Security Officer", "Security Officer", "Security Officer",
	//	"Vice Officer",
		"Detective",
		"Geneticist",
		"Pathologist",
		"Scientist","Scientist", "Scientist",
		"Medical Doctor", "Medical Doctor",
		"Head of Personnel",
	//	"Head of Security",
		"Research Director",
		"Medical Director",
		"Chaplain",
		"Roboticist",
	//	"Hangar Mechanic", "Hangar Mechanic",
		"AI",
		"Cyborg", "Cyborg",
		"Bartender",
		"Chef",
		"Janitor",
		"Clown",
	//	"Chemist","Chemist",
		"Quartermaster","Quartermaster",
		"Botanist","Botanist")
	//	"Attorney at Space-Law")

	global.assistant_occupations = list(
		"Staff Assistant")



	global.job_mailgroup_list = list(
		"Captain" = MGD_COMMAND,
		"Head of Personnel" = MGD_COMMAND,
		"Head of Security" = MGD_COMMAND,
		"Medical Director" = MGD_COMMAND,
		"Research Director" = MGD_COMMAND,
		"Chief Engineer" = MGD_COMMAND,
		"Quartermaster" = MGD_CARGO,
		"Engineer" = MGD_STATIONREPAIR,
		"Janitor" = MGD_STATIONREPAIR,
		"Miner" = MGD_MINING,
		"Botanist" = MGD_BOTANY,
		"Medical Director" = MGD_MEDRESEACH,
		"Roboticist" = MGD_MEDRESEACH,
		"Geneticist" = MGD_MEDRESEACH,
		"Pathologist" = MGD_MEDRESEACH,
		"Medical Doctor" = MGD_MEDBAY,
		"Chaplain" = MGD_SPIRITUALAFFAIRS)

	//Used for PDA department paging.
	global.page_departments = list(
		"Command" = MGD_COMMAND,
		"Security" = MGD_SECURITY,
		"Medbay" = MGD_MEDBAY,
		"Med Research" = MGD_MEDRESEACH,
		"Research" = MGD_SCIENCE,
		"Station Repair" = MGD_STATIONREPAIR,
		"Cargo" = MGD_CARGO,
		"Botany" = MGD_BOTANY,
		"Bar / Kitchen" = MGD_KITCHEN,
		"Spiritual Affairs" = MGD_SPIRITUALAFFAIRS,
		"Mining" = MGD_MINING)



	global.command_jobs = list("Captain", "Medical Director", "Research Director", "Head of Personnel", "Head of Security", "Chief Engineer", "Communications Officer"/*"Clown"*/)
	global.security_jobs = list("Head of Security", "Nanotrasen Security Consultant", "Nanotrasen Special Operative", "Security Officer", "Security Assistant", "Detective")
	global.engineering_jobs = list("Chief Engineer", "Engineer", "Miner", "Quartermaster")
	global.medical_jobs = list("Medical Director", "Medical Doctor", "Roboticist", "Geneticist")
	global.science_jobs = list("Research Director", "Scientist")
	global.medsci_jobs = medical_jobs + science_jobs
	global.service_jobs = list("Head of Personnel", "Bartender", "Chef", "Botanist", "Rancher", "Clown", "Chaplain", "Janitor")

	global.command_gimmicks = list("Head of Mining", "Nanotrasen Security Consultant" /* NTSC isn't a gimmick role, but for the sake of sorting, it practically is*/)
	global.security_gimmicks = list("Vice Officer", "Part-time Vice Officer", "Forensic Technician")
	global.engineering_gimmicks = list("Head of Mining", "Station Builder", "Atmospherish Technician", "Technical Assistant")
	global.medical_gimmicks = list("Medical Specialist", "Medical Assistant", "Pharmacist", "Psychiatrist", "Psychologist", "Psychotherapist", "Therapist", "Counselor")
	global.science_gimmicks = list("Toxins Researcher", "Chemist", "Research Assistant", "Test Subject")
	global.medsci_gimmicks = medical_gimmicks + science_gimmicks
	global.service_gimmicks = list("Lawyer", "Barber", "Mailman", "Mime", "Musician", "Apiculturist", "Apiarist", "Sous-Chef", "Waiter", "Life Coach")



	// HI IT'S ME CIRR I DON'T KNOW WHERE ELSE TO PUT THIS
	global.respawn_critter_types = list(/mob/living/critter/small_animal/mouse/weak, /mob/living/critter/small_animal/cockroach/weak, /mob/living/critter/small_animal/butterfly/weak,)
	global.antag_respawn_critter_types =  list(/mob/living/critter/small_animal/fly/weak, /mob/living/critter/small_animal/mosquito/weak,)



	global.module_editors = list()




	global.update_body_limbs = list("r_leg" = "stump_leg_right", "l_leg" = "stump_leg_left", "r_arm" = "stump_arm_right", "l_arm" = "stump_arm_left")



	global.ai_move_scheduled = list()




	global.mob_bird_species = list("smallowl" = /mob/living/critter/small_animal/bird/owl,
		"owl" = /mob/living/critter/small_animal/bird/owl/large,
		"hooty" = /mob/living/critter/small_animal/bird/owl/large/hooty,
		"then" = /mob/living/critter/small_animal/bird/turkey/hen,
		"ttom" = /mob/living/critter/small_animal/bird/turkey/gobbler,
		"gull" = /mob/living/critter/small_animal/bird/seagull,
		"gannet" = /mob/living/critter/small_animal/bird/seagull/gannet,
		"crow" = /mob/living/critter/small_animal/bird/crow,
		"goose" = /mob/living/critter/small_animal/bird/goose,
		"swan" = /mob/living/critter/small_animal/bird/goose/swan,
		"cassowary" = /mob/living/critter/small_animal/bird/cassowary,
		"penguin" = /mob/living/critter/small_animal/bird/penguin)



	global.available_ai_shells = list()
	global.ai_minimap_ui
	global.ai_emotions = list("Happy" = "ai_happy", \
		"Very Happy" = "ai_veryhappy",\
		"Neutral" = "ai_neutral",\
		"Unsure" = "ai_unsure",\
		"Confused" = "ai_confused",\
		"Surprised" = "ai_surprised",\
		"Sad" = "ai_sad",\
		"Mad" = "ai_mad",\
		"BSOD" = "ai_bsod",\
		"Text" = "ai_text",\
		"Text (Inverted)" = "ai_text-inverted",\
		"Blank" = "ai_blank",\
		"Unimpressed" = "ai_unimpressed",\
		"Baffled" = "ai_baffled",\
		"Cheeky" = "ai_cheeky",\
		"Silly" = "ai_silly",\
		"Annoyed" = "ai_annoyed",\
		"Pensive" = "ai_pensive",\
		"Content" = "ai_content",\
		"Tired" = "ai_tired",\
		"Smug" = "ai_smug",\
		"Wink" = "ai_wink",\
		"Heart" = "ai_heart",\
		"Triangle" = "ai_triangle",\
		"Spooky" = "ai_spooky",\
		"Suspicious" = "ai_eyesemoji",\
		"Glitch" = "ai_glitch",\
		"Eye" = "ai_eye",\
		"Snoozing" = "ai_zzz",\
		"Loading Bar" = "ai_loading",\
		"Exclamation" = "ai_exclamation",\
		"Question" = "ai_question") // this should be in typeinfo


	global.admin_verbs = list(


		1 = list(
			// LEVEL_BABBY, goat fart, ayn rand's armpit
			/client/proc/cmd_admin_say,
			/client/proc/cmd_admin_gib_self,
			),


		2 = list(
			// LEVEL_MOD, moderator
			/client/proc/admin_changes,
			/client/proc/admin_play,
			/client/proc/admin_observe,
			/client/proc/admin_invisible,
			/client/proc/game_panel,
			/client/proc/game_panel_but_called_secrets,
			/client/proc/player_panel,
			/client/proc/cmd_admin_view_playernotes,
			/client/proc/toggle_pray,
			/client/proc/cmd_whois,
			/client/proc/cmd_whodead,

			/client/proc/cmd_admin_pm,
			/client/proc/dsay,
			/client/proc/blobsay,
			/client/proc/dronesay,
			/client/proc/hivesay,
			/client/proc/marsay,
			/client/proc/flocksay,
			/client/proc/silisay,
			/client/proc/toggle_hearing_all_looc,
			/client/proc/toggle_hearing_all,
			/client/proc/cmd_admin_prison_unprison,
			/client/proc/cmd_admin_playermode,

			/datum/admins/proc/announce,
			/datum/admins/proc/toggleooc,
			/datum/admins/proc/togglelooc,
			/datum/admins/proc/toggleoocdead,
			/datum/admins/proc/startnow,
			/datum/admins/proc/toggleAI,
			/datum/admins/proc/delay_start,
			/datum/admins/proc/delay_end,
			/datum/admins/proc/togglepowerdebug,

			/client/proc/cmd_admin_subtle_message,
			/client/proc/cmd_admin_alert,
			/client/proc/toggle_banlogin_announcements,
			/client/proc/toggle_jobban_announcements,
			/client/proc/toggle_popup_verbs,
			/client/proc/toggle_server_toggles_tab,
			/client/proc/toggle_attack_messages,
			/client/proc/toggle_adminwho_alerts,
			/client/proc/toggle_rp_word_filtering,
			/client/proc/toggle_uncool_word_filtering,
			/client/proc/toggle_hear_prayers,
			/client/proc/cmd_admin_plain_message,
			/client/proc/cmd_admin_check_vehicle,
			/client/proc/change_admin_prefs,
			//client/proc/cmd_boot,

			/client/proc/enableDrunkMode,
			/client/proc/forceDrunkMode,

			/client/proc/cmd_unshame_cube,
			/client/proc/cmd_shame_cube,
			/client/proc/removeSelf,
			/client/proc/toggle_station_name_changing,
			/client/proc/cmd_admin_remove_all_labels,
			/client/proc/cmd_admin_antag_popups,
			/client/proc/retreat_to_office,
			/client/proc/summon_office,

			),


		3 = list(
			// LEVEL_SA, secondary administrator
			/client/proc/stealth,
			/datum/admins/proc/pixelexplosion,
			/datum/admins/proc/turn_off_pixelexplosion,
			/datum/admins/proc/camtest,
			/client/proc/alt_key,
			/client/proc/create_portal,
			/datum/admins/proc/togglefarting,
			/client/proc/cmd_admin_show_ai_laws,
			/client/proc/cmd_admin_reset_ai,
			/verb/restart_the_fucking_server_i_mean_it,
			/client/proc/cmd_admin_forceallsay,
			/client/proc/cmd_admin_murraysay,
			/client/proc/cmd_admin_hssay,
			/client/proc/cmd_admin_bradsay,
			/client/proc/cmd_admin_beepsay,
			/datum/admins/proc/restart,
			/datum/admins/proc/toggleenter,
			/client/proc/respawn_self,
			/client/proc/cmd_admin_check_reagents,
			/client/proc/cmd_admin_check_health,
			/client/proc/cmd_admin_polymorph,
			/client/proc/revive_all_bees,
			/client/proc/revive_all_cats,
			/client/proc/revive_all_parrots,
			/datum/admins/proc/toggle_blood_system,
			/client/proc/narrator_mode,
			/client/proc/force_desussification,
			/client/proc/admin_observe_random_player,
			/client/proc/orp,
			/client/proc/admin_pick_random_player,
			/client/proc/fix_powernets,
			/datum/admins/proc/delay_start,
			/datum/admins/proc/delay_end,
			/client/proc/cmd_admin_create_centcom_report,
			/client/proc/cmd_admin_create_advanced_centcom_report,
			/client/proc/cmd_admin_advanced_centcom_report_help,
			/client/proc/warn,
			/client/proc/cmd_admin_playeropt,
			/client/proc/popt_key,
			/client/proc/POK,
			/client/proc/POM,
			/client/proc/show_rules_to_player,
			/client/proc/view_fingerprints,
			/client/proc/cmd_admin_intercom_announce,
			/client/proc/cmd_admin_intercom_announce_freq,
			/client/proc/cmd_admin_intercom_help,
			/client/proc/cmd_dectalk,
			/client/proc/cmd_admin_remove_plasma,
			/client/proc/toggle_death_confetti,
			/client/proc/cmd_admin_unhandcuff,
			/client/proc/admin_toggle_lighting,
			/client/proc/cmd_admin_managebioeffect,
			/client/proc/toggle_cloning_with_records,
			/client/proc/toggle_random_job_selection,

			/client/proc/debug_deletions,

			/client/proc/Jump,
			/client/proc/jumptomob,
			/client/proc/jtm,
			/client/proc/jumptokey,
			/client/proc/jtk,
			/client/proc/jumptoturf,
			/client/proc/jtt,
			/client/proc/jumptocoord,
			/client/proc/jtc,
			/client/proc/admin_follow_mobject,
			/client/proc/main_loop_context,
			/client/proc/main_loop_tick_detail,
			/client/proc/display_bomb_monitor,
			//Ban verbs
			/client/proc/openBanPanel,
			/client/proc/banooc,
			/client/proc/view_cid_list,
			/client/proc/modify_parts,
			/client/proc/jobbans,

			// moved down from admin
			/client/proc/cmd_admin_add_freeform_ai_law,
			/client/proc/cmd_admin_bulk_law_change,
			/client/proc/cmd_admin_mute,
			/client/proc/cmd_admin_mute_temp,
			/client/proc/respawn_as_self,
			/client/proc/respawn_as_new_self,
			/client/proc/respawn_as_job,
			/datum/admins/proc/toggletraitorscaling,
			/client/proc/toggle_flourish,

			/client/proc/cmd_view_runtimes,
			/client/proc/cmd_antag_history,
			/client/proc/cmd_admin_show_player_stats,
			/client/proc/cmd_admin_show_player_ips,
			/client/proc/cmd_admin_show_player_compids,
			/client/proc/give_mass_medals,
			/client/proc/copy_medals,
			/client/proc/copy_cloud_saves,

			/client/proc/cmd_dispatch_observe_to_ghosts,
			/client/proc/waddle_walking,
			/client/proc/clear_area_overlays,
			/client/proc/cmd_admin_adminundamn,
			/client/proc/cmd_admin_admindamn,
			/client/proc/toggle_respawn_arena,

			/client/proc/cmd_emag_all,
			/client/proc/cmd_scale_all,
			/client/proc/cmd_rotate_all,
			/client/proc/cmd_spin_all,
			/client/proc/cmd_atom_emergency_stop,
			/client/proc/cmd_emag_type,
			/client/proc/cmd_transmute_type,
			/client/proc/cmd_scale_type,
			/client/proc/cmd_rotate_type,
			/client/proc/cmd_spin_type,
			/client/proc/cmd_get_type,
			/client/proc/cmd_lightsout,

			/client/proc/vpn_whitelist_add,
			/client/proc/vpn_whitelist_remove,
			/client/proc/set_conspiracy_objective
			),

		4 = list(
			// LEVEL_IA, admin
			/*
			/client/proc/noclip,
			/client/proc/cmd_admin_mute,
			/client/proc/cmd_admin_mute_temp,
			/client/proc/cmd_admin_delete,
			/client/proc/cmd_admin_add_freeform_ai_law,
			/client/proc/cmd_admin_show_ai_laws,
			/client/proc/cmd_admin_reset_ai,
			/client/proc/addpathogens,
			/client/proc/addreagents,
			/client/proc/respawn_as_self,
			/datum/admins/proc/toggletraitorscaling,
			/datum/admins/proc/togglerandomaiblobs,
			*/
			),

		5 = list(
			// LEVEL_PA, primary administrator
			/datum/admins/proc/togglesuicide,
			/datum/admins/proc/pixelexplosion,
			/client/proc/open_dj_panel,
			/client/proc/cmd_admin_clownify,
			/client/proc/toggle_toggles,
			/client/proc/cmd_admin_plain_message_all,
			/client/proc/cmd_admin_fake_medal,
			/datum/admins/proc/togglespeechpopups,
			/datum/admins/proc/togglemonkeyspeakhuman,
			/datum/admins/proc/toggletraitorsseeeachother,
			/datum/admins/proc/toggleautoending,
			/datum/admins/proc/togglelatetraitors,
			/datum/admins/proc/toggle_pull_slowing,
			/client/proc/resetbuildmode,
			/client/proc/togglebuildmode,
			/client/proc/toggle_buildmode_view,
			/client/proc/cmd_admin_rejuvenate_all,
			/client/proc/toggle_force_mixed_blob,
			/client/proc/toggle_force_mixed_wraith,
			/client/proc/toggle_spooky_light_plane,
			/datum/admins/proc/toggle_radio_audio,
			///proc/possess,
			/proc/possessmob,
			/proc/releasemob,
			/client/proc/critter_creator_debug,
			/client/proc/cmd_cat_county,
			/client/proc/fake_pda_message_to_all,
			/client/proc/force_say_in_range,
			/client/proc/find_thing,
			/client/proc/find_one_of,
			/client/proc/cmd_admin_advview,
			/client/proc/iddt,
			/client/proc/cmd_swap_minds,
			/client/proc/cmd_transfer_client,
			/client/proc/edit_module,
			// /client/proc/modify_organs,
			/client/proc/toggle_atom_verbs,
			/client/proc/toggle_camera_network_reciprocity,
			///client/proc/generate_poster,
			/client/proc/count_all_of,
			/client/proc/admin_set_ai_vox,
			/client/proc/cmd_makeshittyweapon,
			/client/proc/rspawn_panel,
			/client/proc/cmd_admin_manageabils,
			/client/proc/create_all_wizard_rings,
			/client/proc/toggle_vpn_blacklist,

			// moved up from admin
			//client/proc/cmd_admin_delete,
			/client/proc/noclip,
			/client/proc/idclip,
			///client/proc/addpathogens,
			/client/proc/respawn_as_self,
			/client/proc/respawn_list_players,
			/client/proc/cmd_give_pet,
			/client/proc/cmd_give_pets,
			/client/proc/cmd_give_player_pets,
			/client/proc/cmd_customgrenade,
			/client/proc/cmd_admin_gib,
			/client/proc/cmd_admin_partygib,
			/client/proc/cmd_admin_owlgib,
			/client/proc/cmd_admin_firegib,
			/client/proc/cmd_admin_elecgib,
			/client/proc/sharkgib,
			/client/proc/cmd_admin_icegib,
			/client/proc/cmd_admin_goldgib,
			/client/proc/cmd_admin_spidergib,
			/client/proc/cmd_admin_implodegib,
			/client/proc/cmd_admin_cluwnegib,
			/client/proc/cmd_admin_buttgib,
			/client/proc/cmd_admin_tysongib,
			/client/proc/removeOther,
			/client/proc/toggle_map_voting,
			/client/proc/show_admin_lag_hacks,
			/client/proc/spawn_survival_shit,
			/client/proc/respawn_cinematic,
			/client/proc/idkfa,
			/datum/admins/proc/spawn_atom,
			/datum/admins/proc/heavenly_spawn_obj,
			/datum/admins/proc/supplydrop_spawn_obj,
			/datum/admins/proc/demonically_spawn_obj,
			/datum/admins/proc/spawn_figurine,

			// moved down from coder. shows artists, atmos etc
			/client/proc/SetInfoOverlay,
			/client/proc/SetInfoOverlayAlias,

			),


		6 = list(
			// LEVEL_ADMIN, Administrator
			/datum/admins/proc/togglesoundwaiting,
			/client/proc/debug_variables,
			/verb/adminCreateBlueprint,
			/verb/adminDeleteBlueprint,
			/client/proc/toggle_text_mode,
			/client/proc/cmd_debug_mutantrace,
			/client/proc/cmd_admin_rejuvenate,
			/client/proc/cmd_admin_drop_everything,
			/client/proc/cmd_admin_humanize,
			/client/proc/cmd_admin_mobileAIize,
			/client/proc/cmd_admin_makeai,
			/client/proc/cmd_admin_makecyborg,
			/client/proc/cmd_admin_makeghostdrone,
			/client/proc/cmd_debug_del_all,
			/client/proc/cmd_debug_del_half,
			/client/proc/cmd_admin_godmode,
			/client/proc/cmd_admin_godmode_self,
			/client/proc/cmd_admin_toggle_ghost_interaction,
			/client/proc/iddqd,
			/client/proc/cmd_admin_omnipresence,
			/client/proc/cmd_admin_get_mobject,
			/client/proc/cmd_admin_get_mobject_loc,
			/client/proc/Getmob,
			/client/proc/sendmob,
			/client/proc/gethmobs,
			/client/proc/sendhmobs,
			/client/proc/getmobs,
			/client/proc/getclients,
			/client/proc/sendmobs,
			/client/proc/gettraitors,
			/client/proc/getnontraitors,
			/datum/admins/proc/adrev,
			/datum/admins/proc/adspawn,
			/datum/admins/proc/adjump,
			/client/proc/find_all_of,
			/client/proc/respawn_as,
			/client/proc/whitelist_add_temp,
			/client/proc/whitelist_toggle,
			/client/proc/list_adminteract_buttons,

			/client/proc/general_report,
			/client/proc/map_debug_panel,
			/client/proc/air_report,
			/client/proc/fix_next_move,
			/client/proc/debugreward,

			/client/proc/flip_view,
			/client/proc/show_image_to_all,
			/client/proc/sharkban,
			/client/proc/toggle_literal_disarm,
			/datum/admins/proc/toggle_emote_cooldowns,
			/client/proc/implant_all,
			/client/proc/cmd_crusher_walls,
			/client/proc/cmd_disco_lights,
			/client/proc/cmd_blindfold_monkeys,
			/client/proc/cmd_terrainify_station,
			/client/proc/cmd_custom_spawn_event,
			/client/proc/cmd_special_shuttle,
			/client/proc/toggle_radio_maptext,

			/datum/admins/proc/toggleaprilfools,
			/client/proc/cmd_admin_pop_off_all_the_limbs_oh_god,
			/datum/admins/proc/togglethetoggles,
			/datum/admins/proc/togglesimsmode,
			/client/proc/admin_toggle_nightmode,
			/client/proc/toggle_ip_alerts,
			/client/proc/upload_custom_hud,
			/client/proc/enable_waterflow,
			/client/proc/delete_fluids,
			/client/proc/special_fullbright,
			/client/proc/replace_space_exclusive,
			/client/proc/dereplace_space,
			/client/proc/ghostdroneAll,
			/client/proc/showLoadingHint,
			/client/proc/showPregameHTML,
			/client/proc/dbg_radio_controller,
			/client/proc/test_mass_flock_convert,
			/client/proc/BK_finance_debug,
			/client/proc/BK_alter_funds,
			/client/proc/debug_variables,
			/client/proc/cmd_randomize_look,
			/client/proc/flock_cheat,

			/client/proc/call_proc,
			/client/proc/call_proc_all,
			/client/proc/debug_global_variable,
			/client/proc/debug_ref_variables,

			// /client/proc/admin_airborne_fluid,
			// /client/proc/replace_space,
	#ifdef IMAGE_DEL_DEBUG
			/client/proc/debug_image_deletions,
			/client/proc/debug_image_deletions_clear,
	#endif

			),

		7 = list(
			// LEVEL_CODER, coder
			/client/proc/cmd_job_controls,
			/client/proc/cmd_modify_market_variables,
			/client/proc/debug_pools,
			/client/proc/debug_global_variable,
			/client/proc/get_admin_state,
			/client/proc/call_proc,
			/client/proc/call_proc_all,
			/datum/admins/proc/adsound,
			/datum/admins/proc/pcap,
			/client/proc/toggle_extra_verbs,
			/client/proc/toggle_numbers_station_messages,

			/client/proc/ticklag,
			/client/proc/cmd_debug_vox,
			/client/proc/check_gang_scores,
			/client/proc/mapWorld,
			/client/proc/haine_blood_debug,
			/client/proc/debug_messages,
			/client/proc/toggle_next_click,
			/client/proc/debug_reaction_list,
			/client/proc/debug_reagents_cache,
			///client/proc/debug_check_possible_reactions,
			/client/proc/set_admin_level,
			/client/proc/show_camera_paths,
			///client/proc/dbg_itemspecial,
			///client/proc/dbg_objectprop,
			// /client/proc/remove_camera_paths_verb,
			// /client/proc/show_runtime_window,
			/client/proc/cmd_chat_debug,
			/client/proc/toggleIrcbotDebug,
			/datum/admins/proc/toggle_bone_system,
			/client/proc/cmd_randomize_handwriting,
			/client/proc/wireTest,
			/client/proc/toggleResourceCache,
			/client/proc/debugResourceCache,
			/client/proc/debug_profiler,
			/client/proc/cmd_tooltip_debug,
			/client/proc/deleteJsLogFile,
			/client/proc/deleteAllJsLogFiles,
			/client/proc/random_color_matrix,
			/client/proc/clear_string_cache,
			/client/proc/test_flock_panel,
			/client/proc/temporary_deadmin_self,
			/verb/rebuild_flow_networks,
			/verb/print_flow_networks,
			/client/proc/toggle_hard_reboot,
			/client/proc/cmd_modify_respawn_variables,
			/client/proc/set_nukie_score,
			/client/proc/set_pod_wars_score,
			/client/proc/set_pod_wars_deaths,
			/client/proc/clear_nukeop_uplink_purchases,
			/client/proc/upload_uncool_words,
			/client/proc/TestMarketReq,

			/client/proc/delete_profiling_logs,
			/client/proc/cause_lag,
			/client/proc/persistent_lag,

	#ifdef MACHINE_PROCESSING_DEBUG
			/client/proc/cmd_display_detailed_machine_stats,
			/client/proc/cmd_display_detailed_power_stats,
	#endif
	#ifdef QUEUE_STAT_DEBUG
			/client/proc/cmd_display_queue_stats,
	#endif
	#ifdef ENABLE_SPAWN_DEBUG
			/client/proc/cmd_modify_spawn_dbg_list,
			/client/proc/spawn_dbg,
	#elif defined(ENABLE_SPAWN_DEBUG_2)
			/client/proc/spawn_dbg,
	#endif
			),

		8 = list(
			// LEVEL_HOST, host
			/datum/admins/proc/toggle_soundpref_override
			),
		)

	// verbs that SAs and As get while observing. PA+ get these all the time
	var/list/special_admin_observing_verbs = list(
		/datum/admins/proc/toggle_respawns,
		/datum/admins/proc/toggledeadchat,
		/client/proc/togglepersonaldeadchat,
		/client/proc/Getmob,
		)

	// verbs that PAs get while observing. Coder+ get these all the time
	var/list/special_pa_observing_verbs = list(
		/client/proc/cmd_admin_drop_everything,
		/client/proc/debug_variables,
		/client/proc/cmd_modify_ticker_variables,
		/client/proc/cmd_modify_controller_variables,
		/client/proc/Getmob,
		/client/proc/sendmob,
		/client/proc/cmd_admin_rejuvenate,
		/client/proc/toggle_view_range,
		/client/proc/cmd_admin_aview,
		)


	// verbs that SAs and As get while observing. PA+ get these all the time
	global.special_admin_observing_verbs = list(
		/datum/admins/proc/toggle_respawns,
		/datum/admins/proc/toggledeadchat,
		/client/proc/togglepersonaldeadchat,
		/client/proc/Getmob,
		)

	// verbs that PAs get while observing. Coder+ get these all the time
	global.special_pa_observing_verbs = list(
		/client/proc/cmd_admin_drop_everything,
		/client/proc/debug_variables,
		/client/proc/cmd_modify_ticker_variables,
		/client/proc/cmd_modify_controller_variables,
		/client/proc/Getmob,
		/client/proc/sendmob,
		/client/proc/cmd_admin_rejuvenate,
		/client/proc/toggle_view_range,
		/client/proc/cmd_admin_aview,
		)



	global.fun_images = list()


	//A dumb thing to cache the players seen per round, so I don't end up recording dudes when they reconnect a billion times
	global.playersSeen = list()


	global.color_caching = list()



	//Verbs we have deemed "server-breaking" or just anything a drunkmin probably shouldnt have
	global.dangerousVerbs = list(\

	//No accidentally restarting the server
	/verb/restart_the_fucking_server_i_mean_it,\
	/datum/admins/proc/restart,\

	//Music/sounds
	/client/proc/open_dj_panel,\

	//No banning for you
	/client/proc/warn,\
	/client/proc/openBanPanel,\
	/client/proc/cmd_admin_addban,\
	/client/proc/banooc,\
	/client/proc/sharkban,\

	//This is a little involved for a drunk person huh
	/client/proc/main_loop_context,\
	/client/proc/main_loop_tick_detail,\
	/client/proc/cmd_explosion,\

	//Shitguy stuff
	/client/proc/debug_variables,\
	/client/proc/cmd_debug_mutantrace,\
	/client/proc/cmd_debug_del_all,\
	/client/proc/general_report,\
	/client/proc/map_debug_panel,\
	/client/proc/air_report,\
	/client/proc/air_status,\
	/client/proc/fix_next_move,\
	/client/proc/debugreward,\

	//Coder stuff this is mostly all dangerous shit
	/client/proc/cmd_modify_market_variables,\
	/client/proc/BK_finance_debug,\
	/client/proc/BK_alter_funds,\
	/client/proc/debug_pools,\
	/client/proc/debug_variables,\
	/client/proc/debug_global_variable,\
	/client/proc/call_proc,\
	/client/proc/call_proc_all,\
	/client/proc/ticklag,\
	/client/proc/cmd_debug_vox,\
	/client/proc/mapWorld,\
	/client/proc/haine_blood_debug,\
	/client/proc/debug_messages,\
	/client/proc/debug_reaction_list,\
	/client/proc/debug_reagents_cache,\
	/client/proc/set_admin_level,\
	/client/proc/show_camera_paths, \
	/*/client/proc/remove_camera_paths_verb, \*/
	/client/proc/check_gang_scores,\
	/client/proc/critter_creator_debug,\
	/client/proc/debug_deletions,\
	/client/proc/cmd_modify_controller_variables,\
	/client/proc/cmd_modify_ticker_variables,\
	/client/proc/find_thing,\
	/client/proc/find_one_of,\
	/client/proc/find_all_of,\
	/client/proc/fix_powernets,\
	/client/proc/cmd_job_controls,\

	//Toggles (these are ones that could be very confusing to accidentally toggle for a drunk person)
	/client/proc/toggle_toggles,\
	/client/proc/toggle_popup_verbs,\
	/client/proc/toggle_server_toggles_tab,\
	/datum/admins/proc/toggleenter,\
	/datum/admins/proc/toggle_blood_system,\
	/datum/admins/proc/toggle_bone_system,\
	/client/proc/togglebuildmode,\
	/client/proc/toggle_atom_verbs,\
	/client/proc/toggle_camera_network_reciprocity, \
	/client/proc/toggle_atom_verbs,\
	/client/proc/toggle_extra_verbs,\
	/datum/admins/proc/togglethetoggles,\

	/client/proc/forceDrunkMode\
	)




	global.default_organ_paths = list("head" = /obj/item/organ/head, "skull" = /obj/item/skull, "brain" = /obj/item/organ/brain, "left_eye" = /obj/item/organ/eye, "right_eye" = /obj/item/organ/eye, "chest" = /obj/item/organ/chest, "heart" = /obj/item/organ/heart, "left_lung" = /obj/item/organ/lung, "right_lung" = /obj/item/organ/lung, "butt" = /obj/item/clothing/head/butt, "liver" = /obj/item/organ/liver, "stomach" = /obj/item/organ/stomach, "intestines" = /obj/item/organ/intestines, "pancreas" = /obj/item/organ/pancreas, "spleen" = /obj/item/organ/spleen, "appendix" = /obj/item/organ/appendix, "left_kidney" = /obj/item/organ/kidney, "right_kidney" = /obj/item/organ/kidney, "tail" = /obj/item/organ/tail)
	global.default_limb_paths = list("l_arm" = /obj/item/parts/human_parts/arm/left, "r_arm" = /obj/item/parts/human_parts/arm/right, "l_leg" = /obj/item/parts/human_parts/leg/left, "r_leg" = /obj/item/parts/human_parts/leg/right)



	//fixed that for you -marq
	global.popup_verbs_to_toggle = list(\
	/client/proc/sendmobs,
	/client/proc/sendhmobs,
	/client/proc/Jump,\
	)


	// if it's in Toggles (Server) it should be in here, ya dig?
	global.server_toggles_tab_verbs = list(
	/client/proc/toggle_attack_messages,
	/client/proc/toggle_ghost_respawns,
	/client/proc/toggle_adminwho_alerts,
	/client/proc/toggle_toggles,
	/client/proc/toggle_jobban_announcements,
	/client/proc/toggle_banlogin_announcements,
	/client/proc/toggle_literal_disarm,
	/client/proc/toggle_spooky_light_plane,\
	/client/proc/toggle_cloning_with_records,
	/client/proc/toggle_random_job_selection,
	/datum/admins/proc/toggleooc,
	/datum/admins/proc/togglelooc,
	/datum/admins/proc/toggleoocdead,
	/datum/admins/proc/toggletraitorscaling,
	/datum/admins/proc/pcap,
	/datum/admins/proc/toggleenter,
	/datum/admins/proc/toggleAI,
	/datum/admins/proc/toggle_soundpref_override,
	/datum/admins/proc/toggle_respawns,
	/datum/admins/proc/adsound,
	/datum/admins/proc/adspawn,
	/datum/admins/proc/adrev,
	/datum/admins/proc/toggledeadchat,
	/datum/admins/proc/togglefarting,
	/datum/admins/proc/toggle_blood_system,
	/datum/admins/proc/toggle_bone_system,
	/datum/admins/proc/togglesuicide,
	/datum/admins/proc/togglethetoggles,
	/datum/admins/proc/toggleautoending,
	/datum/admins/proc/toggleaprilfools,
	/datum/admins/proc/togglespeechpopups,
	/datum/admins/proc/togglemonkeyspeakhuman,
	/datum/admins/proc/toggletraitorsseeeachother,
	/datum/admins/proc/togglelatetraitors,
	/datum/admins/proc/togglesoundwaiting,
	/datum/admins/proc/adjump,
	/datum/admins/proc/togglesimsmode,
	/datum/admins/proc/toggle_pull_slowing,
	/datum/admins/proc/togglepowerdebug,
	/client/proc/admin_toggle_nightmode,
	/client/proc/toggle_camera_network_reciprocity,
	/datum/admins/proc/toggle_radio_audio,
	)




	global.adventure_elements_by_id = list()



	global.iomoon_puzzle_options = list("Ancient Robot Door" = /obj/iomoon_puzzle/ancient_robot_door, "Energy Field Door" = /obj/iomoon_puzzle/ancient_robot_door/energy,
			"Meat Jaw Door" = /obj/iomoon_puzzle/ancient_robot_door/meat, "Ganglion Button" = /obj/iomoon_puzzle/meat_ganglion,
			"Floor Pad Button" = /obj/iomoon_puzzle/floor_pad, "Ancient Robot Button" = /obj/iomoon_puzzle/button, "(Cancel)")



	/*
	//This is stored as a nested list instead of datums or whatever because it json encodes nicely for usage in tgui
	global.master_filter_info = list(
		"alpha" = list(
			"defaults" = list(
				"x" = 0,
				"y" = 0,
				"icon" = ICON_NOT_SET,
				"render_source" = "",
				"flags" = 0
			),
			"flags" = list(
				"MASK_INVERSE" = MASK_INVERSE,
				"MASK_SWAP" = MASK_SWAP
			)
		),
		"angular_blur" = list(
			"defaults" = list(
				"x" = 0,
				"y" = 0,
				"size" = 1
			)
		),
		"color" = list(
			"defaults" = list(
				"color" = COLOR_WHITE,
				"space" = COLORSPACE_RGB
				),
			"space" = list(
				"RGB" = COLORSPACE_RGB,
				"HSV" = COLORSPACE_HSV,
				"HSL" = COLORSPACE_HSL,
				"HCY" = COLORSPACE_HCY
			)
		),
		"displace" = list(
			"defaults" = list(
				"x" = 0,
				"y" = 0,
				"size" = null,
				"icon" = ICON_NOT_SET,
				"render_source" = ""
			)
		),
		"drop_shadow" = list(
			"defaults" = list(
				"x" = 1,
				"y" = -1,
				"size" = 1,
				"offset" = 0,
				"color" = COLOR_HALF_TRANSPARENT_BLACK
			)
		),
		"blur" = list(
			"defaults" = list(
				"size" = 1
			)
		),
		"layer" = list(
			"defaults" = list(
				"x" = 0,
				"y" = 0,
				"icon" = ICON_NOT_SET,
				"render_source" = "",
				"flags" = FILTER_OVERLAY,
				"color" = "",
				"transform" = null,
				"blend_mode" = BLEND_DEFAULT,
			),
			"blend_mode" = list(
					"BLEND_DEFAULT" = BLEND_DEFAULT,
					"BLEND_OVERLAY" = BLEND_OVERLAY,
					"BLEND_ADD" = BLEND_ADD,
					"BLEND_SUBTRACT" = BLEND_SUBTRACT,
					"BLEND_MULTIPLY" = BLEND_MULTIPLY,
					"BLEND_INSET_OVERLAY" = BLEND_INSET_OVERLAY,
				)
		),

		"motion_blur" = list(
			"defaults" = list(
				"x" = 0,
				"y" = 0
			)
		),
		"outline" = list(
			"defaults" = list(
				"size" = 0,
				"color" = COLOR_BLACK,
				"flags" = 0
			),
			"flags" = list(
				"OUTLINE_SHARP" = OUTLINE_SHARP,
				"OUTLINE_SQUARE" = OUTLINE_SQUARE
			)
		),
		"radial_blur" = list(
			"defaults" = list(
				"x" = 0,
				"y" = 0,
				"size" = 0.01
			)
		),
		"rays" = list(
			"defaults" = list(
				"x" = 0,
				"y" = 0,
				"size" = 16,
				"color" = COLOR_WHITE,
				"offset" = 0,
				"density" = 10,
				"threshold" = 0.5,
				"factor" = 0,
				"flags" = FILTER_OVERLAY | FILTER_UNDERLAY
			),
			"flags" = list(
				"FILTER_OVERLAY" = FILTER_OVERLAY,
				"FILTER_UNDERLAY" = FILTER_UNDERLAY
			)
		),
		"ripple" = list(
			"defaults" = list(
				"x" = 0,
				"y" = 0,
				"size" = 1,
				"repeat" = 2,
				"radius" = 0,
				"falloff" = 1,
				"flags" = 0
			),
			"flags" = list(
				"WAVE_BOUNDED" = WAVE_BOUNDED
			)
		),
		"wave" = list(
			"defaults" = list(
				"x" = 0,
				"y" = 0,
				"size" = 1,
				"offset" = 0,
				"flags" = 0
			),
			"flags" = list(
				"WAVE_SIDEWAYS" = WAVE_SIDEWAYS,
				"WAVE_BOUNDED" = WAVE_BOUNDED
			)
		)
	)
	*/



	global.master_particle_info = list()




	global.default_muzzle_flash_colors = list(
		"muzzle_flash" = "#FFEE9980",
		"muzzle_flash_laser" = "#FF333380",
		"muzzle_flash_elec" = "#FFC80080",
		"muzzle_flash_bluezap" = "#00FFFF80",
		"muzzle_flash_plaser" = "#00A9FB80",
		"muzzle_flash_phaser" = "#F41C2080",
		"muzzle_flash_launch" = "#FFFFFF50",
		"muzzle_flash_wavep" = "#B3234E80",
		"muzzle_flash_waveg" = "#33CC0080",
		"muzzle_flash_waveb" = "#87BBE380"
	)



	global.snd_macho_rage = list('sound/voice/macho/macho_alert13.ogg', 'sound/voice/macho/macho_alert16.ogg', 'sound/voice/macho/macho_alert24.ogg',\
	'sound/voice/macho/macho_become_alert54.ogg', 'sound/voice/macho/macho_become_alert56.ogg', 'sound/voice/macho/macho_rage_55.ogg', 'sound/voice/macho/macho_shout07.ogg',\
	'sound/voice/macho/macho_rage_58.ogg', 'sound/voice/macho/macho_rage_61.ogg', 'sound/voice/macho/macho_rage_64.ogg', 'sound/voice/macho/macho_rage_68.ogg',\
	'sound/voice/macho/macho_rage_71.ogg', 'sound/voice/macho/macho_rage_72.ogg', 'sound/voice/macho/macho_rage_73.ogg', 'sound/voice/macho/macho_rage_78.ogg',\
	'sound/voice/macho/macho_rage_79.ogg', 'sound/voice/macho/macho_rage_80.ogg', 'sound/voice/macho/macho_rage_81.ogg', 'sound/voice/macho/macho_rage_54.ogg',\
	'sound/voice/macho/macho_rage_55.ogg')

	global.snd_macho_idle = list('sound/voice/macho/macho_alert16.ogg', 'sound/voice/macho/macho_alert22.ogg',\
	'sound/voice/macho/macho_breathing01.ogg', 'sound/voice/macho/macho_breathing13.ogg', 'sound/voice/macho/macho_breathing18.ogg',\
	'sound/voice/macho/macho_idle_breath_01.ogg', 'sound/voice/macho/macho_mumbling04.ogg', 'sound/voice/macho/macho_moan03.ogg',\
	'sound/voice/macho/macho_mumbling05.ogg', 'sound/voice/macho/macho_mumbling07.ogg', 'sound/voice/macho/macho_shout08.ogg')



	global.animal_spell_critter_paths = list(/mob/living/critter/small_animal/cat,
	/mob/living/critter/small_animal/dog,
	/mob/living/critter/small_animal/dog/corgi,
	/mob/living/critter/small_animal/dog/shiba,
	/mob/living/critter/small_animal/bird/random,
	/mob/living/critter/small_animal/bird/owl,
	/mob/living/critter/small_animal/bird/turkey,
	/mob/living/critter/small_animal/bird/timberdoodle,
	/mob/living/critter/small_animal/bird/seagull,
	/mob/living/critter/small_animal/sparrow,
	/mob/living/critter/small_animal/bird/crow,
	/mob/living/critter/small_animal/bird/goose,
	/mob/living/critter/small_animal/bird/goose/swan,
	/mob/living/critter/small_animal/floateye,
	/mob/living/critter/small_animal/pig,
	/mob/living/critter/small_animal/bat,
	/mob/living/critter/small_animal/bat/angry,
	/mob/living/critter/spider/nice,
	/mob/living/critter/spider/clown,
	/mob/living/critter/small_animal/fly,
	/mob/living/critter/small_animal/mosquito,
	/mob/living/critter/spider/baby,
	/mob/living/critter/spider/ice/baby,
	/mob/living/critter/small_animal/wasp,
	/mob/living/critter/small_animal/raccoon,
	/mob/living/critter/small_animal/seal,
	/mob/living/critter/small_animal/walrus,
	/mob/living/critter/small_animal/slug,
	/mob/living/critter/small_animal/slug/snail,
	/mob/living/critter/small_animal/bee,
	/mob/living/critter/maneater_polymorph,
	/mob/living/critter/fermid/polymorph,
	/mob/living/critter/small_animal/crab_polymorph)



	#ifdef KEEP_A_LIST_OF_HOTLY_PROCESSED_TURFS
	global.hotly_processed_turfs = list()
	#endif


	global.chem_requests = list()



	global.basic_elements = list(
			"aluminium","barium","bromine","calcium","carbon","chlorine", \
			"chromium","copper","ethanol","fluorine","hydrogen", \
			"iodine","iron","lithium","magnesium","mercury","nickel", \
			"nitrogen","oxygen","phosphorus","plasma","platinum","potassium", \
			"radium","silicon","silver","sodium","sugar","sulfur","water"
		)




	global.active_reagent_holders = list()



	///List of 2 letter shorthands for the reagent, currently only used by the cybernetic hypospray
	global.reagent_shorthands = list(
		"salbutamol" = "Sb",
		"anti_rad" = "KI"
	)



	global.chem_whitelist = list("antihol", "charcoal", "epinephrine", "insulin", "mutadone", "teporone",\
	"silver_sulfadiazine", "salbutamol", "perfluorodecalin", "omnizine", "synaptizine", "anti_rad",\
	"oculine", "mannitol", "penteticacid", "styptic_powder", "methamphetamine", "spaceacillin", "saline",\
	"salicylic_acid", "cryoxadone", "blood", "bloodc", "synthflesh",\
	"menthol", "cold_medicine", "antihistamine", "ipecac",\
	"booster_enzyme", "anti_fart", "goodnanites", "smelling_salt", "CBD")




	global.FrozenAccounts = list()




	global.ban_from_airborne_fluid = list()



	global.ban_from_fluid = list(
		"paper",\
		"fungus",\
		"martian_flesh",\
		"blackpowder",\
		"thermite",\
		"luminol",\
	)
	//todo : make thermite work
	global.ban_stacking_into_fluid = list( //ban these from producing fluid from a 'cleanable'
		"water",\
		"sodium",\
		"magnesium",\
		"carbon",\
		"ash",\
		"blackpowder",\
		"leaves",\
		"poo",\
	)



	global.depth_levels = list(2,50,100,200)




	global.santa_snacks = list(/obj/item/reagent_containers/food/drinks/eggnog,/obj/item/reagent_containers/food/snacks/cookie,
	/obj/item/reagent_containers/food/snacks/ice_cream/random,/obj/item/reagent_containers/food/snacks/pie/apple,/obj/item/reagent_containers/food/snacks/snack_cake,
	/obj/item/reagent_containers/food/snacks/yoghurt/frozen,/obj/item/reagent_containers/food/snacks/granola_bar,/obj/item/reagent_containers/food/snacks/candy/chocolate)



	///Used to translate internal action names to human-readable names.
	global.action_names = list(

		"attackself" = "Use in-hand",
		"togglethrow" = "Throw (Toggle)",
		"swaphand" = "Swap Hand",
		"equip" = "Equip",
		"resist" = "Resist",

		"fart" = "Fart",
		"flip" = "Flip",
		"twirl" = "Twirl",
		"eyebrow" = "Raise Eyebrow",
		"gasp" = "Gasp",
		"raisehand" = "Raise Hand",
		"dance" = "Dance",
		"laugh" = "Laugh",
		"nod" = "Nod",
		"wave" = "Wave",
		"wink" = "Wink",
		"flex" = "Flex",
		"yawn" = "Yawn",
		"snap" = "Snap",
		"scream" = "Scream",
		"salute" = "Salute",
		"burp" = "Burp",

		"help" = "Help Intent",
		"disarm" = "Disarm Intent",
		"grab" = "Grab Intent",
		"harm" = "Harm Intent",

		"look_n" = "Look North",
		"look_s" = "Look South",
		"look_w" = "Look West",
		"look_e" = "Look East",

		"say" = "Say",
		"say_radio" = "Say Radio",
		"say_main_radio" = "Say Main Radio",
		"dsay" = "Dead Say",
		"asay" = "Admin Say",
		"whisper" = "Whisper",
		"ooc" = "OOC",
		"looc" = "LOOC",
		"emote" = "Custom Emote",

		"screenshot" = "Screenshot",
		"autoscreenshot" = "Auto Screenshot",

		"head" = "Target Head",
		"chest" = "Target Chest",
		"l_arm" = "Target Left Arm",
		"r_arm" = "Target Right Arm",
		"l_leg" = "Target Left Leg",
		"r_leg" = "Target Right Leg",

		"walk" = "Walk (Toggle)",
		"rest" = "Rest (Toggle)",

		"module1" = "Module 1",
		"module2" = "Module 2",
		"module3" = "Module 3",
		"module4" = "Module 4",

		"unequip" = "Unequip (Silicon)",
		"pickup" = "Pick Up",
		"drop" = "Drop",
		"stop_pull" = "Stop Pulling",

		"fire" = "Fire",
		"fire_secondary" = "Fire Secondary",
		"stop" = "Stop",
		"alt_fire" = "Alternate Fire",
		"cycle" = "Cycle Shell",
		"exit" = "Exit",

		"mentorhelp" = "Mentor Help",
		"adminhelp" = "Admin Help",

		"togglepoint" = "Toggle Pointing",
		"refocus"   = "Refocus Window",
		"mainfocus" = "Focus Main Window",

		"admin_interact" = "Admin Interact",

		"module1" = "Module 1",
		"module2" = "Module 2",
		"module3" = "Module 3",
		"module4" = "Module 4"
	)

	///Used for literal input of actions
	global.action_verbs = list(
		"say_radio" = "say_radio",
		"salute" = "me_hotkey salute",
		"burp" = "me_hotkey burp",
		"dab" = "me_hotkey dab",
		"dance" = "me_hotkey dance",
		"eyebrow" = "me_hotkey eyebrow",
		"fart" = "me_hotkey fart",
		"flip" = "me_hotkey flip",
		"twirl" = "me_hotkey twirl",
		"gasp" = "me_hotkey gasp",
		"raisehand" = "me_hotkey raisehand",
		"laugh" = "me_hotkey laugh",
		"nod" = "me_hotkey nod",
		"wave" = "me_hotkey wave",
		"flip" = "me_hotkey flip",
		"scream" = "me_hotkey scream",
		"wink" = "me_hotkey wink",
		"flex" = "me_hotkey flex",
		"yawn" = "me_hotkey yawn",
		"snap" = "me_hotkey snap",
		"pickup" = "pick-up",
		"adminhelp" = "adminhelp",
		"mentorhelp" = "mentorhelp",
		"autoscreenshot" = ".xscreenshot auto",
		"screenshot" = ".xscreenshot",
		"togglepoint" = "togglepoint",
		"refocus"   = ".winset \\\"mainwindow.input.focus=true;mainwindow.input.text=\\\"\\\"\\\"",
		"mainfocus" = ".winset \"mainwindow.input.focus=false;mapwindow.map.focus=true;mainwindow.input.text=\"\"\"",
		//"lazyfocus" = ".winset \\\"mainwindow.input.focus=true\\\"",
		"Admin Interact" = "admin_interact"
	)

	global.action_macros = list(
		"asay" = "asaymacro",
		"dsay" = "dsaymacro",
		"say" = "startsay",
		"emote-h" = "startemote-h",
		"emote-v" = "startemote-v",
		"say_main_radio" = "radiosay",
		"ooc" = "ooc",
		"looc" = "looc",
		"whisper" = "whisper",
	)

	///Used to translate bitflags of hotkeys into human-readable names
	global.key_names = list(
		"[KEY_FORWARD]" = "Up",
		"[KEY_BACKWARD]" = "Down",
		"[KEY_LEFT]" = "Left",
		"[KEY_RIGHT]" = "Right",
		"[KEY_RUN]" = "Run",
		"[KEY_THROW]" = "Throw",
		"[KEY_POINT]" = "Point",
		"[KEY_EXAMINE]" = "Examine",
		"[KEY_PULL]" = "Pull",
		"[KEY_OPEN]" = "Open",
		"[KEY_BOLT]" = "Bolt",
		"[KEY_SHOCK]" = "Electrify"
	)


	global.dirty_keystates = list()




	global.figure_low_rarity = list(\
	/datum/figure_info/assistant,
	/datum/figure_info/chef,
	/datum/figure_info/chaplain,
	/datum/figure_info/bartender,
	/datum/figure_info/botanist,
	/datum/figure_info/janitor,
	/datum/figure_info/doctor,
	/datum/figure_info/geneticist,
	/datum/figure_info/roboticist,
	/datum/figure_info/scientist,
	/datum/figure_info/security,
	/datum/figure_info/detective,
	/datum/figure_info/engineer,
	/datum/figure_info/mechanic,
	/datum/figure_info/miner,
	/datum/figure_info/qm,
	/datum/figure_info/monkey)

	global.figure_high_rarity = list(\
	/datum/figure_info/captain,
	/datum/figure_info/hos,
	/datum/figure_info/hop,
	/datum/figure_info/md,
	/datum/figure_info/rd,
	/datum/figure_info/ce,
	/datum/figure_info/boxer,
	/datum/figure_info/lawyer,
	/datum/figure_info/barber,
	/datum/figure_info/mailman,
	/datum/figure_info/tourist,
	/datum/figure_info/vice,
	/datum/figure_info/clown,
	/datum/figure_info/traitor,
	/datum/figure_info/changeling,
	/datum/figure_info/nukeop,
	/datum/figure_info/wizard,
	/datum/figure_info/wraith,
	/datum/figure_info/cluwne,
	/datum/figure_info/macho,
	/datum/figure_info/cyborg,
	/datum/figure_info/ai,
	/datum/figure_info/blob,
	/datum/figure_info/werewolf,
	/datum/figure_info/omnitraitor,
	/datum/figure_info/shitty_bill,
	/datum/figure_info/don_glabs,
	/datum/figure_info/father_jack,
	/datum/figure_info/inspector,
	/datum/figure_info/coach,
	/datum/figure_info/sous_chef,
	/datum/figure_info/waiter,
	/datum/figure_info/apiarist,
	/datum/figure_info/journalist,
	/datum/figure_info/diplomat,
	/datum/figure_info/musician,
	/datum/figure_info/salesman,
	/datum/figure_info/union_rep,
	/datum/figure_info/vip,
	/datum/figure_info/actor,
	/datum/figure_info/regional_director,
	#ifdef XMAS
	/datum/figure_info/santa,
	#endif
	/datum/figure_info/pharmacist,
	/datum/figure_info/test_subject)



	//List of KEY : TOTAL XP EARNED THIS ROUND. Used for post game stats, XP caps etc.
	global.xp_earned = list()

	//List of KEY : List(Timestamp : XP amount) used for throttling
	global.xp_throttle_list = list()

	//List of KEY : List(JOB : XP amount) used for end-of-round XP recaps and stat tracking
	global.xp_archive = list()

	global.xp_cache = list()




	global.xpRewards = list() //Assoc. List of NAME OF XP REWARD : INSTANCE OF XP REWARD DATUM . Contains all rewards.
	global.xpRewardButtons = list() //Assoc, datum:button obj



	// Basic caching of asset datums, let's not create a bunch of these.
	global.global_asset_datum_list = list()



	/// This contains the names of the trigger lists on materials. Required for copying materials. Remember to keep this updated if you add new triggers.
	global.triggerVars = list("triggersOnBullet", "triggersOnEat", "triggersTemp", "triggersChem", "triggersPickup", "triggersDrop", "triggersExp", "triggersOnAdd", "triggersOnLife", "triggersOnAttack", "triggersOnAttacked", "triggersOnEntered")




	global.hex_digit_mask = list("0"=1,"1"=2,"2"=4,"3"=8,"4"=16,"5"=32,"6"=64,"7"=128,"8"=256,"9"=512,"A"=1024,"B"=2048,"C"=4096,"D"=8192,"E"=16384,"F"=32768)
	global.hex_digit_values = list("0" = 0, "1" = 1, "2" = 2, "3" = 3, "4" = 4, "5" = 5, "6" = 6, "7" = 7, "8" = 8, "9" = 9, "A" = 10, "B" = 11, "C" = 12, "D" = 13, "E" = 14, "F" = 15)



	// chest item whitelist, because some things are more important than being reasonable
	global.chestitem_whitelist = list(/obj/item/gnomechompski, /obj/item/gnomechompski/elf, /obj/item/gnomechompski/mummified)




	var/numbersAndLetters = list("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q",
	"r", "s", "t", "u", "v", "w", "x", "y", "z" , "0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
	global.bioEffectList = list()
	global.mutini_effects = list()



	global.genescanner_addresses = list()
	global.genetek_hair_styles = list()




	global.radio_brains = list()



	/*
	global.generic_exit_list = list("command"=DWAINE_COMMAND_EXIT)
	*/


	global.SPACED_ENV = list(100,0.52,0,-1600,-1500,0,2,2,-10000,0,200,0.01,0.165,0,0.25,0.01,-5,1000,20,10,53,100,0x3f)
	global.SPACED_ECHO = list(-10000,0,-1450,0,0,1,0,1,10,10,0,1,0,10,10,10,10,7)
	global.ECHO_AFAR = list(0,0,0,0,0,0,-10000,1.0,1.5,1.0,0,1.0,0,0,0,0,1.0,7)
	global.ECHO_CLOSE = list(0,0,0,0,0,0,0,0.25,1.5,1.0,0,1.0,0,0,0,0,1.0,7)
	global.falloff_cache = list()

	//default volumes
	global.default_channel_volumes = list(1, 1, 0.2, 0.5, 0.5, 1, 1)




	global.soundCache = list(
		"sound/ambience/dojo/dojoambi.ogg" = 'sound/ambience/dojo/dojoambi.ogg',\
		"sound/ambience/industrial/AncientPowerPlant_Creaking1.ogg" = 'sound/ambience/industrial/AncientPowerPlant_Creaking1.ogg',\
		"sound/ambience/industrial/AncientPowerPlant_Creaking2.ogg" = 'sound/ambience/industrial/AncientPowerPlant_Creaking2.ogg',\
		"sound/ambience/industrial/AncientPowerPlant_Drone1.ogg" = 'sound/ambience/industrial/AncientPowerPlant_Drone1.ogg',\
		"sound/ambience/industrial/AncientPowerPlant_Drone2.ogg" = 'sound/ambience/industrial/AncientPowerPlant_Drone2.ogg',\
		"sound/ambience/industrial/AncientPowerPlant_Drone3.ogg" = 'sound/ambience/industrial/AncientPowerPlant_Drone3.ogg',\
		"sound/ambience/industrial/LavaPowerPlant_FallingMetal1.ogg" = 'sound/ambience/industrial/LavaPowerPlant_FallingMetal1.ogg',\
		"sound/ambience/industrial/LavaPowerPlant_FallingMetal2.ogg" = 'sound/ambience/industrial/LavaPowerPlant_FallingMetal2.ogg',\
		"sound/ambience/industrial/LavaPowerPlant_Rumbling1.ogg" = 'sound/ambience/industrial/LavaPowerPlant_Rumbling1.ogg',\
		"sound/ambience/industrial/LavaPowerPlant_Rumbling2.ogg" = 'sound/ambience/industrial/LavaPowerPlant_Rumbling2.ogg',\
		"sound/ambience/industrial/LavaPowerPlant_Rumbling3.ogg" = 'sound/ambience/industrial/LavaPowerPlant_Rumbling3.ogg',\
		"sound/ambience/industrial/LavaPowerPlant_SteamHiss1.ogg" = 'sound/ambience/industrial/LavaPowerPlant_SteamHiss1.ogg',\
		"sound/ambience/industrial/LavaPowerPlant_SteamHiss2.ogg" = 'sound/ambience/industrial/LavaPowerPlant_SteamHiss2.ogg',\
		"sound/ambience/industrial/MarsFacility_Glitchy.ogg" = 'sound/ambience/industrial/MarsFacility_Glitchy.ogg',\
		"sound/ambience/industrial/MarsFacility_MovingEquipment.ogg" = 'sound/ambience/industrial/MarsFacility_MovingEquipment.ogg',\
		"sound/ambience/industrial/Precursor_Bells.ogg" = 'sound/ambience/industrial/Precursor_Bells.ogg',\
		"sound/ambience/industrial/Precursor_Choir.ogg" = 'sound/ambience/industrial/Precursor_Choir.ogg',\
		"sound/ambience/industrial/Precursor_Drone1.ogg" = 'sound/ambience/industrial/Precursor_Drone1.ogg',\
		"sound/ambience/industrial/Precursor_Drone2.ogg" = 'sound/ambience/industrial/Precursor_Drone2.ogg',\
		"sound/ambience/industrial/Precursor_Drone3.ogg" = 'sound/ambience/industrial/Precursor_Drone3.ogg',\
		"sound/ambience/industrial/Timeship_Atmospheric.ogg" = 'sound/ambience/industrial/Timeship_Atmospheric.ogg',\
		"sound/ambience/industrial/Timeship_Glitchy1.ogg" = 'sound/ambience/industrial/Timeship_Glitchy1.ogg',\
		"sound/ambience/industrial/Timeship_Glitchy2.ogg" = 'sound/ambience/industrial/Timeship_Glitchy2.ogg',\
		"sound/ambience/industrial/Timeship_Glitchy3.ogg" = 'sound/ambience/industrial/Timeship_Glitchy3.ogg',\
		"sound/ambience/industrial/Timeship_Gong.ogg" = 'sound/ambience/industrial/Timeship_Gong.ogg',\
		"sound/ambience/industrial/Timeship_Malfunction.ogg" = 'sound/ambience/industrial/Timeship_Malfunction.ogg',\
		"sound/ambience/industrial/Timeship_Tones.ogg" = 'sound/ambience/industrial/Timeship_Tones.ogg',\
		"sound/ambience/loop/Fire_Medium.ogg" = 'sound/ambience/loop/Fire_Medium.ogg',\
		"sound/ambience/loop/manta_vault.ogg" = 'sound/ambience/loop/manta_vault.ogg',\
		"sound/ambience/loop/Mars_Interior.ogg" = 'sound/ambience/loop/Mars_Interior.ogg',\
		"sound/ambience/loop/Polarisloop.ogg" = 'sound/ambience/loop/Polarisloop.ogg',\
		"sound/ambience/loop/Shore.ogg" = 'sound/ambience/loop/Shore.ogg',\
		"sound/ambience/loop/Static_Horror_Loop.ogg" = 'sound/ambience/loop/Static_Horror_Loop.ogg',\
		"sound/ambience/loop/Static_Horror_Loop_End.ogg" = 'sound/ambience/loop/Static_Horror_Loop_End.ogg',\
		"sound/ambience/loop/Station_Background_Drone.ogg" = 'sound/ambience/loop/Station_Background_Drone.ogg',\
		"sound/ambience/loop/Wind_Low.ogg" = 'sound/ambience/loop/Wind_Low.ogg',\
		"sound/ambience/music/shoptheme.ogg" = 'sound/ambience/music/shoptheme.ogg',\
		"sound/ambience/music/v_office_beats.ogg" = 'sound/ambience/music/v_office_beats.ogg',\
		"sound/ambience/music/VRtunes_edited.ogg" = 'sound/ambience/music/VRtunes_edited.ogg',\
		"sound/ambience/music/VRtunes2.ogg" = 'sound/ambience/music/VRtunes2.ogg',\
		"sound/ambience/nature/Biodome_Birds1.ogg" = 'sound/ambience/nature/Biodome_Birds1.ogg',\
		"sound/ambience/nature/Biodome_Birds2.ogg" = 'sound/ambience/nature/Biodome_Birds2.ogg',\
		"sound/ambience/nature/Biodome_Bugs.ogg" = 'sound/ambience/nature/Biodome_Bugs.ogg',\
		"sound/ambience/nature/Biodome_Monkeys.ogg" = 'sound/ambience/nature/Biodome_Monkeys.ogg',\
		"sound/ambience/nature/Cave_Bugs.ogg" = 'sound/ambience/nature/Cave_Bugs.ogg',\
		"sound/ambience/nature/Cave_Drips.ogg" = 'sound/ambience/nature/Cave_Drips.ogg',\
		"sound/ambience/nature/Cave_Rumbling.ogg" = 'sound/ambience/nature/Cave_Rumbling.ogg',\
		"sound/ambience/nature/Cave_Wind1.ogg" = 'sound/ambience/nature/Cave_Wind1.ogg',\
		"sound/ambience/nature/Cave_Wind2.ogg" = 'sound/ambience/nature/Cave_Wind2.ogg',\
		"sound/ambience/nature/Glacier_DeepRumbling1.ogg" = 'sound/ambience/nature/Glacier_DeepRumbling1.ogg',\
		"sound/ambience/nature/Glacier_DeepRumbling2.ogg" = 'sound/ambience/nature/Glacier_DeepRumbling2.ogg',\
		"sound/ambience/nature/Glacier_IceCracking.ogg" = 'sound/ambience/nature/Glacier_IceCracking.ogg',\
		"sound/ambience/nature/Glacier_Scuttling.ogg" = 'sound/ambience/nature/Glacier_Scuttling.ogg',\
		"sound/ambience/nature/Lavamoon_DeepBubble1.ogg" = 'sound/ambience/nature/Lavamoon_DeepBubble1.ogg',\
		"sound/ambience/nature/Lavamoon_DeepBubble2.ogg" = 'sound/ambience/nature/Lavamoon_DeepBubble2.ogg',\
		"sound/ambience/nature/Lavamoon_FireCrackling.ogg" = 'sound/ambience/nature/Lavamoon_FireCrackling.ogg',\
		"sound/ambience/nature/Lavamoon_RocksBreaking1.ogg" = 'sound/ambience/nature/Lavamoon_RocksBreaking1.ogg',\
		"sound/ambience/nature/Lavamoon_RocksBreaking2.ogg" = 'sound/ambience/nature/Lavamoon_RocksBreaking2.ogg',\
		"sound/ambience/nature/Mars_Rockslide1.ogg" = 'sound/ambience/nature/Mars_Rockslide1.ogg',\
		"sound/ambience/nature/Mars_Rockslide2.ogg" = 'sound/ambience/nature/Mars_Rockslide2.ogg',\
		"sound/ambience/nature/Rain_Heavy.ogg" = 'sound/ambience/nature/Rain_Heavy.ogg',\
		"sound/ambience/nature/Rain_Thunderdistant.ogg" = 'sound/ambience/nature/Rain_Thunderdistant.ogg',\
		"sound/ambience/nature/Seagulls1.ogg" = 'sound/ambience/nature/Seagulls1.ogg',\
		"sound/ambience/nature/Seagulls2.ogg" = 'sound/ambience/nature/Seagulls2.ogg',\
		"sound/ambience/nature/Seagulls3.ogg" = 'sound/ambience/nature/Seagulls3.ogg',\
		"sound/ambience/nature/Wind_Cold1.ogg" = 'sound/ambience/nature/Wind_Cold1.ogg',\
		"sound/ambience/nature/Wind_Cold2.ogg" = 'sound/ambience/nature/Wind_Cold2.ogg',\
		"sound/ambience/nature/Wind_Cold3.ogg" = 'sound/ambience/nature/Wind_Cold3.ogg',\
		"sound/ambience/owlzone/owlambi1.ogg" = 'sound/ambience/owlzone/owlambi1.ogg',\
		"sound/ambience/owlzone/owlambi2.ogg" = 'sound/ambience/owlzone/owlambi2.ogg',\
		"sound/ambience/owlzone/owlambi3.ogg" = 'sound/ambience/owlzone/owlambi3.ogg',\
		"sound/ambience/owlzone/owlambi4.ogg" = 'sound/ambience/owlzone/owlambi4.ogg',\
		"sound/ambience/owlzone/owlambi5.ogg" = 'sound/ambience/owlzone/owlambi5.ogg',\
		"sound/ambience/owlzone/owlbanjo.ogg" = 'sound/ambience/owlzone/owlbanjo.ogg',\
		"sound/ambience/owlzone/owlsfx1.ogg" = 'sound/ambience/owlzone/owlsfx1.ogg',\
		"sound/ambience/owlzone/owlsfx2.ogg" = 'sound/ambience/owlzone/owlsfx2.ogg',\
		"sound/ambience/owlzone/owlsfx3.ogg" = 'sound/ambience/owlzone/owlsfx3.ogg',\
		"sound/ambience/owlzone/owlsfx4.ogg" = 'sound/ambience/owlzone/owlsfx4.ogg',\
		"sound/ambience/owlzone/owlsfx5.ogg" = 'sound/ambience/owlzone/owlsfx5.ogg',\
		"sound/ambience/spooky/basket_noises1.ogg" = 'sound/ambience/spooky/basket_noises1.ogg',\
		"sound/ambience/spooky/basket_noises2.ogg" = 'sound/ambience/spooky/basket_noises2.ogg',\
		"sound/ambience/spooky/basket_noises3.ogg" = 'sound/ambience/spooky/basket_noises3.ogg',\
		"sound/ambience/spooky/basket_noises4.ogg" = 'sound/ambience/spooky/basket_noises4.ogg',\
		"sound/ambience/spooky/basket_noises5.ogg" = 'sound/ambience/spooky/basket_noises5.ogg',\
		"sound/ambience/spooky/basket_noises6.ogg" = 'sound/ambience/spooky/basket_noises6.ogg',\
		"sound/ambience/spooky/basket_noises7.ogg" = 'sound/ambience/spooky/basket_noises7.ogg',\
		"sound/ambience/spooky/Evilreaver_Ambience.ogg" = 'sound/ambience/spooky/Evilreaver_Ambience.ogg',\
		"sound/ambience/spooky/Flock_Static.ogg" = 'sound/ambience/spooky/Flock_Static.ogg',\
		"sound/ambience/spooky/Hospital_Chords.ogg" = 'sound/ambience/spooky/Hospital_Chords.ogg',\
		"sound/ambience/spooky/Hospital_Drone1.ogg" = 'sound/ambience/spooky/Hospital_Drone1.ogg',\
		"sound/ambience/spooky/Hospital_Drone2.ogg" = 'sound/ambience/spooky/Hospital_Drone2.ogg',\
		"sound/ambience/spooky/Hospital_Drone3.ogg" = 'sound/ambience/spooky/Hospital_Drone3.ogg',\
		"sound/ambience/spooky/Hospital_Feedback.ogg" = 'sound/ambience/spooky/Hospital_Feedback.ogg',\
		"sound/ambience/spooky/Hospital_Haunted1.ogg" = 'sound/ambience/spooky/Hospital_Haunted1.ogg',\
		"sound/ambience/spooky/Hospital_Haunted2.ogg" = 'sound/ambience/spooky/Hospital_Haunted2.ogg',\
		"sound/ambience/spooky/Hospital_Haunted3.ogg" = 'sound/ambience/spooky/Hospital_Haunted3.ogg',\
		"sound/ambience/spooky/Hospital_ScaryChimes.ogg" = 'sound/ambience/spooky/Hospital_ScaryChimes.ogg',\
		"sound/ambience/spooky/Meatzone_BreathingAndAnthem.ogg" = 'sound/ambience/spooky/Meatzone_BreathingAndAnthem.ogg',\
		"sound/ambience/spooky/Meatzone_BreathingFast.ogg" = 'sound/ambience/spooky/Meatzone_BreathingFast.ogg',\
		"sound/ambience/spooky/Meatzone_BreathingSlow.ogg" = 'sound/ambience/spooky/Meatzone_BreathingSlow.ogg',\
		"sound/ambience/spooky/Meatzone_Gurgle.ogg" = 'sound/ambience/spooky/Meatzone_Gurgle.ogg',\
		"sound/ambience/spooky/Meatzone_Howl.ogg" = 'sound/ambience/spooky/Meatzone_Howl.ogg',\
		"sound/ambience/spooky/Meatzone_Rumble.ogg" = 'sound/ambience/spooky/Meatzone_Rumble.ogg',\
		"sound/ambience/spooky/Meatzone_Squishy.ogg" = 'sound/ambience/spooky/Meatzone_Squishy.ogg',\
		"sound/ambience/spooky/MFortuna.ogg" = 'sound/ambience/spooky/MFortuna.ogg',\
		"sound/ambience/spooky/Somewhere_Tone.ogg" = 'sound/ambience/spooky/Somewhere_Tone.ogg',\
		"sound/ambience/spooky/TheBlindPig.ogg" = 'sound/ambience/spooky/TheBlindPig.ogg',\
		"sound/ambience/spooky/TheBlindPig2.ogg" = 'sound/ambience/spooky/TheBlindPig2.ogg',\
		"sound/ambience/spooky/Void_Calls.ogg" = 'sound/ambience/spooky/Void_Calls.ogg',\
		"sound/ambience/spooky/Void_Hisses.ogg" = 'sound/ambience/spooky/Void_Hisses.ogg',\
		"sound/ambience/spooky/Void_Screaming.ogg" = 'sound/ambience/spooky/Void_Screaming.ogg',\
		"sound/ambience/spooky/Void_Song.ogg" = 'sound/ambience/spooky/Void_Song.ogg',\
		"sound/ambience/spooky/Void_Wail.ogg" = 'sound/ambience/spooky/Void_Wail.ogg',\
		"sound/ambience/station/Chapel_ChoirTwoNote1.ogg" = 'sound/ambience/station/Chapel_ChoirTwoNote1.ogg',\
		"sound/ambience/station/Chapel_ChoirTwoNote2.ogg" = 'sound/ambience/station/Chapel_ChoirTwoNote2.ogg',\
		"sound/ambience/station/Chapel_FemaleChoir.ogg" = 'sound/ambience/station/Chapel_FemaleChoir.ogg',\
		"sound/ambience/station/Chapel_HighFemaleSolo.ogg" = 'sound/ambience/station/Chapel_HighFemaleSolo.ogg',\
		"sound/ambience/station/Detectivesoffice.ogg" = 'sound/ambience/station/Detectivesoffice.ogg',\
		"sound/ambience/station/JazzLounge1.ogg" = 'sound/ambience/station/JazzLounge1.ogg',\
		"sound/ambience/station/Machinery_Computers1.ogg" = 'sound/ambience/station/Machinery_Computers1.ogg',\
		"sound/ambience/station/Machinery_Computers2.ogg" = 'sound/ambience/station/Machinery_Computers2.ogg',\
		"sound/ambience/station/Machinery_Computers3.ogg" = 'sound/ambience/station/Machinery_Computers3.ogg',\
		"sound/ambience/station/Machinery_PowerStation1.ogg" = 'sound/ambience/station/Machinery_PowerStation1.ogg',\
		"sound/ambience/station/Machinery_PowerStation2.ogg" = 'sound/ambience/station/Machinery_PowerStation2.ogg',\
		"sound/ambience/station/Station_MechanicalHissing.ogg" = 'sound/ambience/station/Station_MechanicalHissing.ogg',\
		"sound/ambience/station/Station_MechanicalThrum1.ogg" = 'sound/ambience/station/Station_MechanicalThrum1.ogg',\
		"sound/ambience/station/Station_MechanicalThrum2.ogg" = 'sound/ambience/station/Station_MechanicalThrum2.ogg',\
		"sound/ambience/station/Station_MechanicalThrum3.ogg" = 'sound/ambience/station/Station_MechanicalThrum3.ogg',\
		"sound/ambience/station/Station_MechanicalThrum4.ogg" = 'sound/ambience/station/Station_MechanicalThrum4.ogg',\
		"sound/ambience/station/Station_MechanicalThrum5.ogg" = 'sound/ambience/station/Station_MechanicalThrum5.ogg',\
		"sound/ambience/station/Station_MechanicalThrum6.ogg" = 'sound/ambience/station/Station_MechanicalThrum6.ogg',\
		"sound/ambience/station/Station_SpookyAtmosphere1.ogg" = 'sound/ambience/station/Station_SpookyAtmosphere1.ogg',\
		"sound/ambience/station/Station_SpookyAtmosphere2.ogg" = 'sound/ambience/station/Station_SpookyAtmosphere2.ogg',\
		"sound/ambience/station/Station_StructuralCreaking.ogg" = 'sound/ambience/station/Station_StructuralCreaking.ogg',\
		"sound/ambience/station/Station_VocalNoise1.ogg" = 'sound/ambience/station/Station_VocalNoise1.ogg',\
		"sound/ambience/station/Station_VocalNoise2.ogg" = 'sound/ambience/station/Station_VocalNoise2.ogg',\
		"sound/ambience/station/Station_VocalNoise3.ogg" = 'sound/ambience/station/Station_VocalNoise3.ogg',\
		"sound/ambience/station/Station_VocalNoise4.ogg" = 'sound/ambience/station/Station_VocalNoise4.ogg',\
		"sound/ambience/station/Underwater/ocean_ambi1.ogg" = 'sound/ambience/station/Underwater/ocean_ambi1.ogg',\
		"sound/ambience/station/Underwater/ocean_ambi2.ogg" = 'sound/ambience/station/Underwater/ocean_ambi2.ogg',\
		"sound/ambience/station/Underwater/ocean_ambi3.ogg" = 'sound/ambience/station/Underwater/ocean_ambi3.ogg',\
		"sound/ambience/station/Underwater/sub_ambi.ogg" = 'sound/ambience/station/Underwater/sub_ambi.ogg',\
		"sound/ambience/station/Underwater/sub_ambi1.ogg" = 'sound/ambience/station/Underwater/sub_ambi1.ogg',\
		"sound/ambience/station/Underwater/sub_ambi2.ogg" = 'sound/ambience/station/Underwater/sub_ambi2.ogg',\
		"sound/ambience/station/Underwater/sub_ambi3.ogg" = 'sound/ambience/station/Underwater/sub_ambi3.ogg',\
		"sound/ambience/station/Underwater/sub_ambi4.ogg" = 'sound/ambience/station/Underwater/sub_ambi4.ogg',\
		"sound/ambience/station/Underwater/sub_ambi5.ogg" = 'sound/ambience/station/Underwater/sub_ambi5.ogg',\
		"sound/ambience/station/Underwater/sub_ambi6.ogg" = 'sound/ambience/station/Underwater/sub_ambi6.ogg',\
		"sound/ambience/station/Underwater/sub_ambi7.ogg" = 'sound/ambience/station/Underwater/sub_ambi7.ogg',\
		"sound/ambience/station/Underwater/sub_ambi8.ogg" = 'sound/ambience/station/Underwater/sub_ambi8.ogg',\
		"sound/ambience/station/Underwater/sub_bridge_ambi1.ogg" = 'sound/ambience/station/Underwater/sub_bridge_ambi1.ogg',\
		"sound/ambience/station/ZenGarden1.ogg" = 'sound/ambience/station/ZenGarden1.ogg',\
		"sound/ambience/station/ZenGarden2.ogg" = 'sound/ambience/station/ZenGarden2.ogg',\
		"sound/effects/airbridge_dpl.ogg" = 'sound/effects/airbridge_dpl.ogg',\
		"sound/effects/attach.ogg" = 'sound/effects/attach.ogg',\
		"sound/effects/bamf.ogg" = 'sound/effects/bamf.ogg',\
		"sound/effects/bell_high_pitch.ogg" = 'sound/effects/bell_high_pitch.ogg',\
		"sound/effects/bell_ring.ogg" = 'sound/effects/bell_ring.ogg',\
		"sound/effects/bigwave.ogg" = 'sound/effects/bigwave.ogg',\
		"sound/effects/bionic_sound.ogg" = 'sound/effects/bionic_sound.ogg',\
		"sound/effects/blood.ogg" = 'sound/effects/blood.ogg',\
		"sound/effects/bones_break.ogg" = 'sound/effects/bones_break.ogg',\
		"sound/effects/bow_nock.ogg" = 'sound/effects/bow_nock.ogg',\
		"sound/effects/bow_pull.ogg" = 'sound/effects/bow_pull.ogg',\
		"sound/effects/bow_release.ogg" = 'sound/effects/bow_release.ogg',\
		"sound/effects/brrp.ogg" = 'sound/effects/brrp.ogg',\
		"sound/effects/bubbles.ogg" = 'sound/effects/bubbles.ogg',\
		"sound/effects/bubbles_short.ogg" = 'sound/effects/bubbles_short.ogg',\
		"sound/effects/bubbles2.ogg" = 'sound/effects/bubbles2.ogg',\
		"sound/effects/bubbles3.ogg" = 'sound/effects/bubbles3.ogg',\
		"sound/effects/cani_suicide.ogg" = 'sound/effects/cani_suicide.ogg',\
		"sound/effects/capture.ogg" = 'sound/effects/capture.ogg',\
		"sound/effects/cargodoor.ogg" = 'sound/effects/cargodoor.ogg',\
		"sound/effects/chair_step.ogg" = 'sound/effects/chair_step.ogg',\
		"sound/effects/chalk1.ogg" = 'sound/effects/chalk1.ogg',\
		"sound/effects/chalk2.ogg" = 'sound/effects/chalk2.ogg',\
		"sound/effects/chalk3.ogg" = 'sound/effects/chalk3.ogg',\
		"sound/effects/cheridan_pop.ogg" = 'sound/effects/cheridan_pop.ogg',\
		"sound/effects/commsdown.ogg" = 'sound/effects/commsdown.ogg',\
		"sound/effects/crackle1.ogg" = 'sound/effects/crackle1.ogg',\
		"sound/effects/crackle2.ogg" = 'sound/effects/crackle2.ogg',\
		"sound/effects/crackle3.ogg" = 'sound/effects/crackle3.ogg',\
		"sound/effects/cracklesstethoscope.ogg" = 'sound/effects/cracklesstethoscope.ogg',\
		"sound/effects/creaking_metal1.ogg" = 'sound/effects/creaking_metal1.ogg',\
		"sound/effects/creaking_metal2.ogg" = 'sound/effects/creaking_metal2.ogg',\
		"sound/effects/damnation.ogg" = 'sound/effects/damnation.ogg',\
		"sound/effects/darkspawn.ogg" = 'sound/effects/darkspawn.ogg',\
		"sound/effects/distortedfasthyperstethoscope.ogg" = 'sound/effects/distortedfasthyperstethoscope.ogg',\
		"sound/effects/dramatic.ogg" = 'sound/effects/dramatic.ogg',\
		"sound/effects/elec_bigzap.ogg" = 'sound/effects/elec_bigzap.ogg',\
		"sound/effects/elec_bzzz.ogg" = 'sound/effects/elec_bzzz.ogg',\
		"sound/effects/electric_shock.ogg" = 'sound/effects/electric_shock.ogg',\
		"sound/effects/electric_shock_short.ogg" = 'sound/effects/electric_shock_short.ogg',\
		"sound/effects/env_damage.ogg" = 'sound/effects/env_damage.ogg',\
		"sound/effects/espoon_suicide.ogg" = 'sound/effects/espoon_suicide.ogg',\
		"sound/effects/exlow.ogg" = 'sound/effects/exlow.ogg',\
		"sound/effects/explosion_new1.ogg" = 'sound/effects/explosion_new1.ogg',\
		"sound/effects/explosion_new2.ogg" = 'sound/effects/explosion_new2.ogg',\
		"sound/effects/explosion_new3.ogg" = 'sound/effects/explosion_new3.ogg',\
		"sound/effects/explosion_new4.ogg" = 'sound/effects/explosion_new4.ogg',\
		"sound/effects/Explosion1.ogg" = 'sound/effects/Explosion1.ogg',\
		"sound/effects/Explosion2.ogg" = 'sound/effects/Explosion2.ogg',\
		"sound/effects/explosionfar.ogg" = 'sound/effects/explosionfar.ogg',\
		"sound/effects/ExplosionFirey.ogg" = 'sound/effects/ExplosionFirey.ogg',\
		"sound/effects/ExtremelyScaryGhostNoise.ogg" = 'sound/effects/ExtremelyScaryGhostNoise.ogg',\
		"sound/effects/fingersnap.ogg" = 'sound/effects/fingersnap.ogg',\
		"sound/effects/fingersnap_echo.ogg" = 'sound/effects/fingersnap_echo.ogg',\
		"sound/effects/firework.ogg" = 'sound/effects/firework.ogg',\
		"sound/effects/flame.ogg" = 'sound/effects/flame.ogg',\
		"sound/effects/flameswoosh.ogg" = 'sound/effects/flameswoosh.ogg',\
		"sound/effects/flip.ogg" = 'sound/effects/flip.ogg',\
		"sound/effects/ghost.ogg" = 'sound/effects/ghost.ogg',\
		"sound/effects/ghost2.ogg" = 'sound/effects/ghost2.ogg',\
		"sound/effects/ghostambi1.ogg" = 'sound/effects/ghostambi1.ogg',\
		"sound/effects/ghostambi2.ogg" = 'sound/effects/ghostambi2.ogg',\
		"sound/effects/ghostbreath.ogg" = 'sound/effects/ghostbreath.ogg',\
		"sound/effects/ghostlaugh.ogg" = 'sound/effects/ghostlaugh.ogg',\
		"sound/effects/ghostvoice.ogg" = 'sound/effects/ghostvoice.ogg',\
		"sound/effects/glare.ogg" = 'sound/effects/glare.ogg',\
		"sound/effects/glitchshot.ogg" = 'sound/effects/glitchshot.ogg',\
		"sound/effects/glitchy1.ogg" = 'sound/effects/glitchy1.ogg',\
		"sound/effects/glitchy2.ogg" = 'sound/effects/glitchy2.ogg',\
		"sound/effects/glitchy3.ogg" = 'sound/effects/glitchy3.ogg',\
		"sound/effects/gust.ogg" = 'sound/effects/gust.ogg',\
		"sound/effects/handscan.ogg" = 'sound/effects/handscan.ogg',\
		"sound/effects/Heart Beat.ogg" = 'sound/effects/Heart Beat.ogg',\
		"sound/effects/heartbeat.ogg" = 'sound/effects/heartbeat.ogg',\
		"sound/effects/hyperventstethoscope.ogg" = 'sound/effects/hyperventstethoscope.ogg',\
		"sound/effects/hyperventstethoscope2.ogg" = 'sound/effects/hyperventstethoscope2.ogg',\
		"sound/effects/kaboom.ogg" = 'sound/effects/kaboom.ogg',\
		"sound/effects/leakagentb.ogg" = 'sound/effects/leakagentb.ogg',\
		"sound/effects/leakoxygen.ogg" = 'sound/effects/leakoxygen.ogg',\
		"sound/effects/light_breaker.ogg" = 'sound/effects/light_breaker.ogg',\
		"sound/effects/lightning_strike.ogg" = 'sound/effects/lightning_strike.ogg',\
		"sound/effects/lit.ogg" = 'sound/effects/lit.ogg',\
		"sound/effects/mag_fireballlaunch.ogg" = 'sound/effects/mag_fireballlaunch.ogg',\
		"sound/effects/mag_forcewall.ogg" = 'sound/effects/mag_forcewall.ogg',\
		"sound/effects/mag_golem.ogg" = 'sound/effects/mag_golem.ogg',\
		"sound/effects/mag_iceburstimpact.ogg" = 'sound/effects/mag_iceburstimpact.ogg',\
		"sound/effects/mag_iceburstimpact_high.ogg" = 'sound/effects/mag_iceburstimpact_high.ogg',\
		"sound/effects/mag_iceburstlaunch.ogg" = 'sound/effects/mag_iceburstlaunch.ogg',\
		"sound/effects/mag_magmisimpact.ogg" = 'sound/effects/mag_magmisimpact.ogg',\
		"sound/effects/mag_magmisimpact_bounce.ogg" = 'sound/effects/mag_magmisimpact_bounce.ogg',\
		"sound/effects/mag_magmislaunch.ogg" = 'sound/effects/mag_magmislaunch.ogg',\
		"sound/effects/mag_pandroar.ogg" = 'sound/effects/mag_pandroar.ogg',\
		"sound/effects/mag_phase.ogg" = 'sound/effects/mag_phase.ogg',\
		"sound/effects/mag_teleport.ogg" = 'sound/effects/mag_teleport.ogg',\
		"sound/effects/mag_warp.ogg" = 'sound/effects/mag_warp.ogg',\
		"sound/effects/magic1.ogg" = 'sound/effects/magic1.ogg',\
		"sound/effects/magic2.ogg" = 'sound/effects/magic2.ogg',\
		"sound/effects/magic3.ogg" = 'sound/effects/magic3.ogg',\
		"sound/effects/magic4.ogg" = 'sound/effects/magic4.ogg',\
		"sound/effects/MagShieldDown.ogg" = 'sound/effects/MagShieldDown.ogg',\
		"sound/effects/MagShieldUp.ogg" = 'sound/effects/MagShieldUp.ogg',\
		"sound/effects/manta_alarm.ogg" = 'sound/effects/manta_alarm.ogg',\
		"sound/effects/manta_interface.ogg" = 'sound/effects/manta_interface.ogg',\
		"sound/effects/mantamoving.ogg" = 'sound/effects/mantamoving.ogg',\
		"sound/effects/mindkill.ogg" = 'sound/effects/mindkill.ogg',\
		"sound/effects/molitzcrumble.ogg" = 'sound/effects/molitzcrumble.ogg',\
		"sound/effects/normstethoscope.ogg" = 'sound/effects/normstethoscope.ogg',\
		"sound/effects/pixelexplosion.ogg" = 'sound/effects/pixelexplosion.ogg',\
		"sound/effects/plant_mutation.ogg" = 'sound/effects/plant_mutation.ogg',\
		"sound/effects/plop_dissolve.ogg" = 'sound/effects/plop_dissolve.ogg',\
		"sound/effects/poff.ogg" = 'sound/effects/poff.ogg',\
		"sound/effects/polaris_crateopening.ogg" = 'sound/effects/polaris_crateopening.ogg',\
		"sound/effects/poof.ogg" = 'sound/effects/poof.ogg',\
		"sound/effects/pop.ogg" = 'sound/effects/pop.ogg',\
		"sound/effects/power_charge.ogg" = 'sound/effects/power_charge.ogg',\
		"sound/effects/pump.ogg" = 'sound/effects/pump.ogg',\
		"sound/effects/radio_sweep1.ogg" = 'sound/effects/radio_sweep1.ogg',\
		"sound/effects/radio_sweep2.ogg" = 'sound/effects/radio_sweep2.ogg',\
		"sound/effects/radio_sweep3.ogg" = 'sound/effects/radio_sweep3.ogg',\
		"sound/effects/radio_sweep4.ogg" = 'sound/effects/radio_sweep4.ogg',\
		"sound/effects/radio_sweep5.ogg" = 'sound/effects/radio_sweep5.ogg',\
		"sound/effects/redweedpop.ogg" = 'sound/effects/redweedpop.ogg',\
		"sound/effects/ritual.ogg" = 'sound/effects/ritual.ogg',\
		"sound/effects/sawhit.ogg" = 'sound/effects/sawhit.ogg',\
		"sound/effects/sbfail1.ogg" = 'sound/effects/sbfail1.ogg',\
		"sound/effects/sbfail2.ogg" = 'sound/effects/sbfail2.ogg',\
		"sound/effects/sbfail3.ogg" = 'sound/effects/sbfail3.ogg',\
		"sound/effects/sbtrick1.ogg" = 'sound/effects/sbtrick1.ogg',\
		"sound/effects/sbtrick10.ogg" = 'sound/effects/sbtrick10.ogg',\
		"sound/effects/sbtrick2.ogg" = 'sound/effects/sbtrick2.ogg',\
		"sound/effects/sbtrick3.ogg" = 'sound/effects/sbtrick3.ogg',\
		"sound/effects/sbtrick4.ogg" = 'sound/effects/sbtrick4.ogg',\
		"sound/effects/sbtrick5.ogg" = 'sound/effects/sbtrick5.ogg',\
		"sound/effects/sbtrick6.ogg" = 'sound/effects/sbtrick6.ogg',\
		"sound/effects/sbtrick7.ogg" = 'sound/effects/sbtrick7.ogg',\
		"sound/effects/sbtrick8.ogg" = 'sound/effects/sbtrick8.ogg',\
		"sound/effects/sbtrick9.ogg" = 'sound/effects/sbtrick9.ogg',\
		"sound/effects/screech.ogg" = 'sound/effects/screech.ogg',\
		"sound/effects/screech_tone.ogg" = 'sound/effects/screech_tone.ogg',\
		"sound/effects/screech2.ogg" = 'sound/effects/screech2.ogg',\
		"sound/effects/sdriver_suicide.ogg" = 'sound/effects/sdriver_suicide.ogg',\
		"sound/effects/shielddown.ogg" = 'sound/effects/shielddown.ogg',\
		"sound/effects/shielddown2.ogg" = 'sound/effects/shielddown2.ogg',\
		"sound/effects/ship_alert_major.ogg" = 'sound/effects/ship_alert_major.ogg',\
		"sound/effects/ship_alert_minor.ogg" = 'sound/effects/ship_alert_minor.ogg',\
		"sound/effects/ship_charge.ogg" = 'sound/effects/ship_charge.ogg',\
		"sound/effects/ship_engage.ogg" = 'sound/effects/ship_engage.ogg',\
		"sound/effects/shovel1.ogg" = 'sound/effects/shovel1.ogg',\
		"sound/effects/shovel2.ogg" = 'sound/effects/shovel2.ogg',\
		"sound/effects/shovel3.ogg" = 'sound/effects/shovel3.ogg',\
		"sound/effects/sine_boop.ogg" = 'sound/effects/sine_boop.ogg',\
		"sound/effects/singsuck.ogg" = 'sound/effects/singsuck.ogg',\
		"sound/effects/sleepstethoscope.ogg" = 'sound/effects/sleepstethoscope.ogg',\
		"sound/effects/smear.ogg" = 'sound/effects/smear.ogg',\
		"sound/effects/smoke.ogg" = 'sound/effects/smoke.ogg',\
		"sound/effects/smoke_tile_spread.ogg" = 'sound/effects/smoke_tile_spread.ogg',\
		"sound/effects/snaptape.ogg" = 'sound/effects/snaptape.ogg',\
		"sound/effects/spark_lighter.ogg" = 'sound/effects/spark_lighter.ogg',\
		"sound/effects/sparks1.ogg" = 'sound/effects/sparks1.ogg',\
		"sound/effects/sparks2.ogg" = 'sound/effects/sparks2.ogg',\
		"sound/effects/sparks3.ogg" = 'sound/effects/sparks3.ogg',\
		"sound/effects/sparks4.ogg" = 'sound/effects/sparks4.ogg',\
		"sound/effects/sparks5.ogg" = 'sound/effects/sparks5.ogg',\
		"sound/effects/sparks6.ogg" = 'sound/effects/sparks6.ogg',\
		"sound/effects/splort.ogg" = 'sound/effects/splort.ogg',\
		"sound/effects/spray.ogg" = 'sound/effects/spray.ogg',\
		"sound/effects/spray2.ogg" = 'sound/effects/spray2.ogg',\
		"sound/effects/spring.ogg" = 'sound/effects/spring.ogg',\
		"sound/effects/sprint_puff.ogg" = 'sound/effects/sprint_puff.ogg',\
		"sound/effects/static_horror.ogg" = 'sound/effects/static_horror.ogg',\
		"sound/effects/stoneshift.ogg" = 'sound/effects/stoneshift.ogg',\
		"sound/effects/stridorstethoscope.ogg" = 'sound/effects/stridorstethoscope.ogg',\
		"sound/effects/suck.ogg" = 'sound/effects/suck.ogg',\
		"sound/effects/swoosh.ogg" = 'sound/effects/swoosh.ogg',\
		"sound/effects/swoosh_double.ogg" = 'sound/effects/swoosh_double.ogg',\
		"sound/effects/sword_clash1.ogg" = 'sound/effects/sword_clash1.ogg',\
		"sound/effects/sword_clash2.ogg" = 'sound/effects/sword_clash2.ogg',\
		"sound/effects/sword_clash3.ogg" = 'sound/effects/sword_clash3.ogg',\
		"sound/effects/sword_sheath.ogg" = 'sound/effects/sword_sheath.ogg',\
		"sound/effects/sword_unsheath1.ogg" = 'sound/effects/sword_unsheath1.ogg',\
		"sound/effects/sword_unsheath2.ogg" = 'sound/effects/sword_unsheath2.ogg',\
		"sound/effects/syringeproj.ogg" = 'sound/effects/syringeproj.ogg',\
		"sound/effects/teleport.ogg" = 'sound/effects/teleport.ogg',\
		"sound/effects/throw.ogg" = 'sound/effects/throw.ogg',\
		"sound/effects/thump.ogg" = 'sound/effects/thump.ogg',\
		"sound/effects/thunder.ogg" = 'sound/effects/thunder.ogg',\
		"sound/effects/toilet_flush.ogg" = 'sound/effects/toilet_flush.ogg',\
		"sound/effects/torpedolaunch.ogg" = 'sound/effects/torpedolaunch.ogg',\
		"sound/effects/treefall.ogg" = 'sound/effects/treefall.ogg',\
		"sound/effects/valve_creak.ogg" = 'sound/effects/valve_creak.ogg',\
		"sound/effects/warp1.ogg" = 'sound/effects/warp1.ogg',\
		"sound/effects/warp2.ogg" = 'sound/effects/warp2.ogg',\
		"sound/effects/welder_ignite.ogg" = 'sound/effects/welder_ignite.ogg',\
		"sound/effects/welderarc_ignite.ogg" = 'sound/effects/welderarc_ignite.ogg',\
		"sound/effects/welding_arc.ogg" = 'sound/effects/welding_arc.ogg',\
		"sound/effects/zzzt.ogg" = 'sound/effects/zzzt.ogg',\
		"sound/impact_sounds/Blade_Small.ogg" = 'sound/impact_sounds/Blade_Small.ogg',\
		"sound/impact_sounds/Blade_Small_Bloody.ogg" = 'sound/impact_sounds/Blade_Small_Bloody.ogg',\
		"sound/impact_sounds/block_blunt.ogg" = 'sound/impact_sounds/block_blunt.ogg',\
		"sound/impact_sounds/block_burn.ogg" = 'sound/impact_sounds/block_burn.ogg',\
		"sound/impact_sounds/block_cut.ogg" = 'sound/impact_sounds/block_cut.ogg',\
		"sound/impact_sounds/block_stab.ogg" = 'sound/impact_sounds/block_stab.ogg',\
		"sound/impact_sounds/burn_sizzle.ogg" = 'sound/impact_sounds/burn_sizzle.ogg',\
		"sound/impact_sounds/Bush_Hit.ogg" = 'sound/impact_sounds/Bush_Hit.ogg',\
		"sound/impact_sounds/circsaw.ogg" = 'sound/impact_sounds/circsaw.ogg',\
		"sound/impact_sounds/Clock_slap.ogg" = 'sound/impact_sounds/Clock_slap.ogg',\
		"sound/impact_sounds/coconut_break.ogg" = 'sound/impact_sounds/coconut_break.ogg',\
		"sound/impact_sounds/Crystal_Hit_1.ogg" = 'sound/impact_sounds/Crystal_Hit_1.ogg',\
		"sound/impact_sounds/Crystal_Shatter_1.ogg" = 'sound/impact_sounds/Crystal_Shatter_1.ogg',\
		"sound/impact_sounds/Door_Metal_Knock_1.ogg" = 'sound/impact_sounds/Door_Metal_Knock_1.ogg',\
		"sound/impact_sounds/Energy_Hit_1.ogg" = 'sound/impact_sounds/Energy_Hit_1.ogg',\
		"sound/impact_sounds/Energy_Hit_2.ogg" = 'sound/impact_sounds/Energy_Hit_2.ogg',\
		"sound/impact_sounds/Energy_Hit_3.ogg" = 'sound/impact_sounds/Energy_Hit_3.ogg',\
		"sound/impact_sounds/Fireaxe.ogg" = 'sound/impact_sounds/Fireaxe.ogg',\
		"sound/impact_sounds/Flesh_Break_1.ogg" = 'sound/impact_sounds/Flesh_Break_1.ogg',\
		"sound/impact_sounds/Flesh_Break_2.ogg" = 'sound/impact_sounds/Flesh_Break_2.ogg',\
		"sound/impact_sounds/Flesh_Crush_1.ogg" = 'sound/impact_sounds/Flesh_Crush_1.ogg',\
		"sound/impact_sounds/Flesh_Cut_1.ogg" = 'sound/impact_sounds/Flesh_Cut_1.ogg',\
		"sound/impact_sounds/Flesh_Stab_1.ogg" = 'sound/impact_sounds/Flesh_Stab_1.ogg',\
		"sound/impact_sounds/Flesh_Stab_2.ogg" = 'sound/impact_sounds/Flesh_Stab_2.ogg',\
		"sound/impact_sounds/Flesh_Stab_3.ogg" = 'sound/impact_sounds/Flesh_Stab_3.ogg',\
		"sound/impact_sounds/Flesh_Tear_1.ogg" = 'sound/impact_sounds/Flesh_Tear_1.ogg',\
		"sound/impact_sounds/Flesh_Tear_2.ogg" = 'sound/impact_sounds/Flesh_Tear_2.ogg',\
		"sound/impact_sounds/Flesh_Tear_3.ogg" = 'sound/impact_sounds/Flesh_Tear_3.ogg',\
		"sound/impact_sounds/folding_chair.ogg" = 'sound/impact_sounds/folding_chair.ogg',\
		"sound/impact_sounds/Generic_Click_1.ogg" = 'sound/impact_sounds/Generic_Click_1.ogg',\
		"sound/impact_sounds/Generic_Hit_1.ogg" = 'sound/impact_sounds/Generic_Hit_1.ogg',\
		"sound/impact_sounds/Generic_Hit_2.ogg" = 'sound/impact_sounds/Generic_Hit_2.ogg',\
		"sound/impact_sounds/Generic_Hit_3.ogg" = 'sound/impact_sounds/Generic_Hit_3.ogg',\
		"sound/impact_sounds/Generic_Hit_Heavy_1.ogg" = 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg',\
		"sound/impact_sounds/Generic_Punch_1.ogg" = 'sound/impact_sounds/Generic_Punch_1.ogg',\
		"sound/impact_sounds/Generic_Punch_2.ogg" = 'sound/impact_sounds/Generic_Punch_2.ogg',\
		"sound/impact_sounds/Generic_Punch_3.ogg" = 'sound/impact_sounds/Generic_Punch_3.ogg',\
		"sound/impact_sounds/Generic_Punch_4.ogg" = 'sound/impact_sounds/Generic_Punch_4.ogg',\
		"sound/impact_sounds/Generic_Punch_5.ogg" = 'sound/impact_sounds/Generic_Punch_5.ogg',\
		"sound/impact_sounds/Generic_Shove_1.ogg" = 'sound/impact_sounds/Generic_Shove_1.ogg',\
		"sound/impact_sounds/Generic_Slap_1.ogg" = 'sound/impact_sounds/Generic_Slap_1.ogg',\
		"sound/impact_sounds/Generic_Snap_1.ogg" = 'sound/impact_sounds/Generic_Snap_1.ogg',\
		"sound/impact_sounds/Generic_Stab_1.ogg" = 'sound/impact_sounds/Generic_Stab_1.ogg',\
		"sound/impact_sounds/Generic_Swing_1.ogg" = 'sound/impact_sounds/Generic_Swing_1.ogg',\
		"sound/impact_sounds/Glass_Hit_1.ogg" = 'sound/impact_sounds/Glass_Hit_1.ogg',\
		"sound/impact_sounds/Glass_Shards_Hit_1.ogg" = 'sound/impact_sounds/Glass_Shards_Hit_1.ogg',\
		"sound/impact_sounds/Glass_Shatter_1.ogg" = 'sound/impact_sounds/Glass_Shatter_1.ogg',\
		"sound/impact_sounds/Glass_Shatter_2.ogg" = 'sound/impact_sounds/Glass_Shatter_2.ogg',\
		"sound/impact_sounds/Glass_Shatter_3.ogg" = 'sound/impact_sounds/Glass_Shatter_3.ogg',\
		"sound/impact_sounds/Glub_1.ogg" = 'sound/impact_sounds/Glub_1.ogg',\
		"sound/impact_sounds/Glub_2.ogg" = 'sound/impact_sounds/Glub_2.ogg',\
		"sound/impact_sounds/katana_slash.ogg" = 'sound/impact_sounds/katana_slash.ogg',\
		"sound/impact_sounds/kendo_block_1.ogg" = 'sound/impact_sounds/kendo_block_1.ogg',\
		"sound/impact_sounds/kendo_block_2.ogg" = 'sound/impact_sounds/kendo_block_2.ogg',\
		"sound/impact_sounds/kendo_parry_1.ogg" = 'sound/impact_sounds/kendo_parry_1.ogg',\
		"sound/impact_sounds/kendo_parry_2.ogg" = 'sound/impact_sounds/kendo_parry_2.ogg',\
		"sound/impact_sounds/kendo_parry_3.ogg" = 'sound/impact_sounds/kendo_parry_3.ogg',\
		"sound/impact_sounds/Liquid_Hit_Big_1.ogg" = 'sound/impact_sounds/Liquid_Hit_Big_1.ogg',\
		"sound/impact_sounds/Liquid_Slosh_1.ogg" = 'sound/impact_sounds/Liquid_Slosh_1.ogg',\
		"sound/impact_sounds/Liquid_Slosh_2.ogg" = 'sound/impact_sounds/Liquid_Slosh_2.ogg',\
		"sound/impact_sounds/locker_break.ogg" = 'sound/impact_sounds/locker_break.ogg',\
		"sound/impact_sounds/locker_hit.ogg" = 'sound/impact_sounds/locker_hit.ogg',\
		"sound/impact_sounds/Machinery_Break_1.ogg" = 'sound/impact_sounds/Machinery_Break_1.ogg',\
		"sound/impact_sounds/meat_smack.ogg" = 'sound/impact_sounds/meat_smack.ogg',\
		"sound/impact_sounds/Metal_Clang_1.ogg" = 'sound/impact_sounds/Metal_Clang_1.ogg',\
		"sound/impact_sounds/Metal_Clang_2.ogg" = 'sound/impact_sounds/Metal_Clang_2.ogg',\
		"sound/impact_sounds/Metal_Clang_3.ogg" = 'sound/impact_sounds/Metal_Clang_3.ogg',\
		"sound/impact_sounds/Metal_Hit_1.ogg" = 'sound/impact_sounds/Metal_Hit_1.ogg',\
		"sound/impact_sounds/Metal_Hit_Heavy_1.ogg" = 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg',\
		"sound/impact_sounds/Metal_Hit_Light_1.ogg" = 'sound/impact_sounds/Metal_Hit_Light_1.ogg',\
		"sound/impact_sounds/Metal_Hit_Lowfi_1.ogg" = 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg',\
		"sound/impact_sounds/plate_break.ogg" = 'sound/impact_sounds/plate_break.ogg',\
		"sound/impact_sounds/Rush_Slash.ogg" = 'sound/impact_sounds/Rush_Slash.ogg',\
		"sound/impact_sounds/Slap.ogg" = 'sound/impact_sounds/Slap.ogg',\
		"sound/impact_sounds/Slimy_Cut_1.ogg" = 'sound/impact_sounds/Slimy_Cut_1.ogg',\
		"sound/impact_sounds/Slimy_Hit_1.ogg" = 'sound/impact_sounds/Slimy_Hit_1.ogg',\
		"sound/impact_sounds/Slimy_Hit_2.ogg" = 'sound/impact_sounds/Slimy_Hit_2.ogg',\
		"sound/impact_sounds/Slimy_Hit_3.ogg" = 'sound/impact_sounds/Slimy_Hit_3.ogg',\
		"sound/impact_sounds/Slimy_Hit_4.ogg" = 'sound/impact_sounds/Slimy_Hit_4.ogg',\
		"sound/impact_sounds/Slimy_Splat_1.ogg" = 'sound/impact_sounds/Slimy_Splat_1.ogg',\
		"sound/impact_sounds/Slimy_Splat_2.ogg" = 'sound/impact_sounds/Slimy_Splat_2.ogg',\
		"sound/impact_sounds/Slimy_Splat_2_Short.ogg" = 'sound/impact_sounds/Slimy_Splat_2_Short.ogg',\
		"sound/impact_sounds/Stone_Cut_1.ogg" = 'sound/impact_sounds/Stone_Cut_1.ogg',\
		"sound/impact_sounds/Stone_Scrape_1.ogg" = 'sound/impact_sounds/Stone_Scrape_1.ogg',\
		"sound/impact_sounds/tube_bonk.ogg" = 'sound/impact_sounds/tube_bonk.ogg',\
		"sound/impact_sounds/Wood_Hit_1.ogg" = 'sound/impact_sounds/Wood_Hit_1.ogg',\
		"sound/impact_sounds/Wood_Hit_Small_1.ogg" = 'sound/impact_sounds/Wood_Hit_Small_1.ogg',\
		"sound/impact_sounds/Wood_Snap.ogg" = 'sound/impact_sounds/Wood_Snap.ogg',\
		"sound/impact_sounds/Wood_Tap.ogg" = 'sound/impact_sounds/Wood_Tap.ogg',\
		"sound/items/batcheer.ogg" = 'sound/items/batcheer.ogg',\
		"sound/items/bball_bounce.ogg" = 'sound/items/bball_bounce.ogg',\
		"sound/items/bball_hoop.ogg" = 'sound/items/bball_hoop.ogg',\
		"sound/items/blade_pull.ogg" = 'sound/items/blade_pull.ogg',\
		"sound/items/can_crush-1.ogg" = 'sound/items/can_crush-1.ogg',\
		"sound/items/can_crush-2.ogg" = 'sound/items/can_crush-2.ogg',\
		"sound/items/can_crush-3.ogg" = 'sound/items/can_crush-3.ogg',\
		"sound/items/can_open.ogg" = 'sound/items/can_open.ogg',\
		"sound/items/capsule_pop.ogg" = 'sound/items/capsule_pop.ogg',\
		"sound/items/CocktailShake.ogg" = 'sound/items/CocktailShake.ogg',\
		"sound/items/coindrop.ogg" = 'sound/items/coindrop.ogg',\
		"sound/items/Crowbar.ogg" = 'sound/items/Crowbar.ogg',\
		"sound/items/Deconstruct.ogg" = 'sound/items/Deconstruct.ogg',\
		"sound/items/defib_charge.ogg" = 'sound/items/defib_charge.ogg',\
		"sound/items/dicedrop.ogg" = 'sound/items/dicedrop.ogg',\
		"sound/items/drink.ogg" = 'sound/items/drink.ogg',\
		"sound/items/eatfood.ogg" = 'sound/items/eatfood.ogg',\
		"sound/items/eatfoodshort.ogg" = 'sound/items/eatfoodshort.ogg',\
		"sound/items/fishing_rod_cast.ogg" = 'sound/items/fishing_rod_cast.ogg',\
		"sound/items/fishing_rod_reel.ogg" = 'sound/items/fishing_rod_reel.ogg',\
		"sound/items/garrote_twang.ogg" = 'sound/items/garrote_twang.ogg',\
		"sound/items/gavel.ogg" = 'sound/items/gavel.ogg',\
		"sound/items/geiger/geiger-1-1.ogg" = 'sound/items/geiger/geiger-1-1.ogg',\
		"sound/items/geiger/geiger-1-2.ogg" = 'sound/items/geiger/geiger-1-2.ogg',\
		"sound/items/geiger/geiger-2-1.ogg" = 'sound/items/geiger/geiger-2-1.ogg',\
		"sound/items/geiger/geiger-2-2.ogg" = 'sound/items/geiger/geiger-2-2.ogg',\
		"sound/items/geiger/geiger-3-1.ogg" = 'sound/items/geiger/geiger-3-1.ogg',\
		"sound/items/geiger/geiger-3-2.ogg" = 'sound/items/geiger/geiger-3-2.ogg',\
		"sound/items/geiger/geiger-4-1.ogg" = 'sound/items/geiger/geiger-4-1.ogg',\
		"sound/items/geiger/geiger-4-2.ogg" = 'sound/items/geiger/geiger-4-2.ogg',\
		"sound/items/geiger/geiger-4-3.ogg" = 'sound/items/geiger/geiger-4-3.ogg',\
		"sound/items/geiger/geiger-5-1.ogg" = 'sound/items/geiger/geiger-5-1.ogg',\
		"sound/items/geiger/geiger-5-2.ogg" = 'sound/items/geiger/geiger-5-2.ogg',\
		"sound/items/geiger/geiger-5-3.ogg" = 'sound/items/geiger/geiger-5-3.ogg',\
		"sound/items/glass_slide.ogg" = 'sound/items/glass_slide.ogg',\
		"sound/items/glass_wipe.ogg" = 'sound/items/glass_wipe.ogg',\
		"sound/items/hand_label.ogg" = 'sound/items/hand_label.ogg',\
		"sound/items/hypo.ogg" = 'sound/items/hypo.ogg',\
		"sound/items/injectorbelt_active.ogg" = 'sound/items/injectorbelt_active.ogg',\
		"sound/items/matchstick_hit.ogg" = 'sound/items/matchstick_hit.ogg',\
		"sound/items/matchstick_light.ogg" = 'sound/items/matchstick_light.ogg',\
		"sound/items/mender.ogg" = 'sound/items/mender.ogg',\
		"sound/items/mender_refill.ogg" = 'sound/items/mender_refill.ogg',\
		"sound/items/mender_refill_juice.ogg" = 'sound/items/mender_refill_juice.ogg',\
		"sound/items/mender2.ogg" = 'sound/items/mender2.ogg',\
		"sound/items/mesonactivate.ogg" = 'sound/items/mesonactivate.ogg',\
		"sound/items/mic_feedback.ogg" = 'sound/items/mic_feedback.ogg',\
		"sound/items/mining_blaster.ogg" = 'sound/items/mining_blaster.ogg',\
		"sound/items/mining_conc.ogg" = 'sound/items/mining_conc.ogg',\
		"sound/items/mining_drill.ogg" = 'sound/items/mining_drill.ogg',\
		"sound/items/mining_hammer.ogg" = 'sound/items/mining_hammer.ogg',\
		"sound/items/mining_pick.ogg" = 'sound/items/mining_pick.ogg',\
		"sound/items/miningtool_off.ogg" = 'sound/items/miningtool_off.ogg',\
		"sound/items/miningtool_on.ogg" = 'sound/items/miningtool_on.ogg',\
		"sound/items/ocular_implanter_end.ogg" = 'sound/items/ocular_implanter_end.ogg',\
		"sound/items/ocular_implanter_start.ogg" = 'sound/items/ocular_implanter_start.ogg',\
		"sound/items/penclick.ogg" = 'sound/items/penclick.ogg',\
		"sound/items/pickup_1.ogg" = 'sound/items/pickup_1.ogg',\
		"sound/items/pickup_2.ogg" = 'sound/items/pickup_2.ogg',\
		"sound/items/pickup_3.ogg" = 'sound/items/pickup_3.ogg',\
		"sound/items/pickup_defib.ogg" = 'sound/items/pickup_defib.ogg',\
		"sound/items/pickup_gun.ogg" = 'sound/items/pickup_gun.ogg',\
		"sound/items/pickup_plate.ogg" = 'sound/items/pickup_plate.ogg',\
		"sound/items/plate_tap.ogg" = 'sound/items/plate_tap.ogg',\
		"sound/items/plunger_pop.ogg" = 'sound/items/plunger_pop.ogg',\
		"sound/items/polaroid1.ogg" = 'sound/items/polaroid1.ogg',\
		"sound/items/polaroid2.ogg" = 'sound/items/polaroid2.ogg',\
		"sound/items/police_whistle1.ogg" = 'sound/items/police_whistle1.ogg',\
		"sound/items/police_whistle2.ogg" = 'sound/items/police_whistle2.ogg',\
		"sound/items/putback_defib.ogg" = 'sound/items/putback_defib.ogg',\
		"sound/items/Ratchet.ogg" = 'sound/items/Ratchet.ogg',\
		"sound/items/rubberduck.ogg" = 'sound/items/rubberduck.ogg',\
		"sound/items/Scissor.ogg" = 'sound/items/Scissor.ogg',\
		"sound/items/Screwdriver.ogg" = 'sound/items/Screwdriver.ogg',\
		"sound/items/Screwdriver2.ogg" = 'sound/items/Screwdriver2.ogg',\
		"sound/items/security_alert.ogg" = 'sound/items/security_alert.ogg',\
		"sound/items/small_fire_hiss.ogg" = 'sound/items/small_fire_hiss.ogg',\
		"sound/items/sponge.ogg" = 'sound/items/sponge.ogg',\
		"sound/items/sticker.ogg" = 'sound/items/sticker.ogg',\
		"sound/items/towel.ogg" = 'sound/items/towel.ogg',\
		"sound/items/toys/figure-headlock.ogg" = 'sound/items/toys/figure-headlock.ogg',\
		"sound/items/toys/figure-kiss.ogg" = 'sound/items/toys/figure-kiss.ogg',\
		"sound/items/toys/figure-knock.ogg" = 'sound/items/toys/figure-knock.ogg',\
		"sound/items/Welder.ogg" = 'sound/items/Welder.ogg',\
		"sound/items/Welder2.ogg" = 'sound/items/Welder2.ogg',\
		"sound/items/Wirecutter.ogg" = 'sound/items/Wirecutter.ogg',\
		"sound/items/woodbat.ogg" = 'sound/items/woodbat.ogg',\
		"sound/items/zipper.ogg" = 'sound/items/zipper.ogg',\
		"sound/items/zippo_close.ogg" = 'sound/items/zippo_close.ogg',\
		"sound/items/zippo_open.ogg" = 'sound/items/zippo_open.ogg',\
		"sound/machines/airlock.ogg" = 'sound/machines/airlock.ogg',\
		"sound/machines/airlock_bolt.ogg" = 'sound/machines/airlock_bolt.ogg',\
		"sound/machines/airlock_break_very_temp.ogg" = 'sound/machines/airlock_break_very_temp.ogg',\
		"sound/machines/airlock_deny.ogg" = 'sound/machines/airlock_deny.ogg',\
		"sound/machines/airlock_deny_temp.ogg" = 'sound/machines/airlock_deny_temp.ogg',\
		"sound/machines/airlock_pry.ogg" = 'sound/machines/airlock_pry.ogg',\
		"sound/machines/airlock_swoosh_temp.ogg" = 'sound/machines/airlock_swoosh_temp.ogg',\
		"sound/machines/airlock_swoosh_tempier.ogg" = 'sound/machines/airlock_swoosh_tempier.ogg',\
		"sound/machines/airlock_unbolt.ogg" = 'sound/machines/airlock_unbolt.ogg',\
		"sound/machines/alarm_a.ogg" = 'sound/machines/alarm_a.ogg',\
		"sound/machines/ArtifactAnc1.ogg" = 'sound/machines/ArtifactAnc1.ogg',\
		"sound/machines/ArtifactBee1.ogg" = 'sound/machines/ArtifactBee1.ogg',\
		"sound/machines/ArtifactBee2.ogg" = 'sound/machines/ArtifactBee2.ogg',\
		"sound/machines/ArtifactBee3.ogg" = 'sound/machines/ArtifactBee3.ogg',\
		"sound/machines/ArtifactEld1.ogg" = 'sound/machines/ArtifactEld1.ogg',\
		"sound/machines/ArtifactEld2.ogg" = 'sound/machines/ArtifactEld2.ogg',\
		"sound/machines/ArtifactFea1.ogg" = 'sound/machines/ArtifactFea1.ogg',\
		"sound/machines/ArtifactFea2.ogg" = 'sound/machines/ArtifactFea2.ogg',\
		"sound/machines/ArtifactFea3.ogg" = 'sound/machines/ArtifactFea3.ogg',\
		"sound/machines/ArtifactLat1.ogg" = 'sound/machines/ArtifactLat1.ogg',\
		"sound/machines/ArtifactLat2.ogg" = 'sound/machines/ArtifactLat2.ogg',\
		"sound/machines/ArtifactLat3.ogg" = 'sound/machines/ArtifactLat3.ogg',\
		"sound/machines/ArtifactMar1.ogg" = 'sound/machines/ArtifactMar1.ogg',\
		"sound/machines/ArtifactMar2.ogg" = 'sound/machines/ArtifactMar2.ogg',\
		"sound/machines/ArtifactPre1.ogg" = 'sound/machines/ArtifactPre1.ogg',\
		"sound/machines/ArtifactVoi1.ogg" = 'sound/machines/ArtifactVoi1.ogg',\
		"sound/machines/ArtifactVoi2.ogg" = 'sound/machines/ArtifactVoi2.ogg',\
		"sound/machines/ArtifactWiz1.ogg" = 'sound/machines/ArtifactWiz1.ogg',\
		"sound/machines/bellalert.ogg" = 'sound/machines/bellalert.ogg',\
		"sound/machines/bloop_alert.ogg" = 'sound/machines/bloop_alert.ogg',\
		"sound/machines/bloop_mad.ogg" = 'sound/machines/bloop_mad.ogg',\
		"sound/machines/bloop_ok.ogg" = 'sound/machines/bloop_ok.ogg',\
		"sound/machines/bloop_sad.ogg" = 'sound/machines/bloop_sad.ogg',\
		"sound/machines/bloop_standard.ogg" = 'sound/machines/bloop_standard.ogg',\
		"sound/machines/bomb_planted.ogg" = 'sound/machines/bomb_planted.ogg',\
		"sound/machines/boost.ogg" = 'sound/machines/boost.ogg',\
		"sound/machines/button.ogg" = 'sound/machines/button.ogg',\
		"sound/machines/buzz-sigh.ogg" = 'sound/machines/buzz-sigh.ogg',\
		"sound/machines/buzz-two.ogg" = 'sound/machines/buzz-two.ogg',\
		"sound/machines/bweep.ogg" = 'sound/machines/bweep.ogg',\
		"sound/machines/capsulebuy.ogg" = 'sound/machines/capsulebuy.ogg',\
		"sound/machines/car_screech.ogg" = 'sound/machines/car_screech.ogg',\
		"sound/machines/chainsaw.ogg" = 'sound/machines/chainsaw.ogg',\
		"sound/machines/chainsaw_green.ogg" = 'sound/machines/chainsaw_green.ogg',\
		"sound/machines/chainsaw_red.ogg" = 'sound/machines/chainsaw_red.ogg',\
		"sound/machines/chainsaw_red_start.ogg" = 'sound/machines/chainsaw_red_start.ogg',\
		"sound/machines/chainsaw_red_stop.ogg" = 'sound/machines/chainsaw_red_stop.ogg',\
		"sound/machines/cheget_goodbloop.ogg" = 'sound/machines/cheget_goodbloop.ogg',\
		"sound/machines/cheget_grumpbloop.ogg" = 'sound/machines/cheget_grumpbloop.ogg',\
		"sound/machines/cheget_sadbloop.ogg" = 'sound/machines/cheget_sadbloop.ogg',\
		"sound/machines/cheget_somberbloop.ogg" = 'sound/machines/cheget_somberbloop.ogg',\
		"sound/machines/cheget_startledbloop.ogg" = 'sound/machines/cheget_startledbloop.ogg',\
		"sound/machines/chime.ogg" = 'sound/machines/chime.ogg',\
		"sound/machines/claw_machine_fail.ogg" = 'sound/machines/claw_machine_fail.ogg',\
		"sound/machines/claw_machine_success.ogg" = 'sound/machines/claw_machine_success.ogg',\
		"sound/machines/click.ogg" = 'sound/machines/click.ogg',\
		"sound/machines/computerboot_pc.ogg" = 'sound/machines/computerboot_pc.ogg',\
		"sound/machines/computerboot_pc_end.ogg" = 'sound/machines/computerboot_pc_end.ogg',\
		"sound/machines/computerboot_pc_loop.ogg" = 'sound/machines/computerboot_pc_loop.ogg',\
		"sound/machines/computerboot_pc_start.ogg" = 'sound/machines/computerboot_pc_start.ogg',\
		"sound/machines/cruiser_warp.ogg" = 'sound/machines/cruiser_warp.ogg',\
		"sound/machines/decompress.ogg" = 'sound/machines/decompress.ogg',\
		"sound/machines/ding.ogg" = 'sound/machines/ding.ogg',\
		"sound/machines/disaster_alert.ogg" = 'sound/machines/disaster_alert.ogg',\
		"sound/machines/disposalflush.ogg" = 'sound/machines/disposalflush.ogg',\
		"sound/machines/door_close.ogg" = 'sound/machines/door_close.ogg',\
		"sound/machines/door_locked.ogg" = 'sound/machines/door_locked.ogg',\
		"sound/machines/door_open.ogg" = 'sound/machines/door_open.ogg',\
		"sound/machines/driveclick.ogg" = 'sound/machines/driveclick.ogg',\
		"sound/machines/elevator_move.ogg" = 'sound/machines/elevator_move.ogg',\
		"sound/machines/engine_alert1.ogg" = 'sound/machines/engine_alert1.ogg',\
		"sound/machines/engine_alert2.ogg" = 'sound/machines/engine_alert2.ogg',\
		"sound/machines/engine_alert3.ogg" = 'sound/machines/engine_alert3.ogg',\
		"sound/machines/engine_grump1.ogg" = 'sound/machines/engine_grump1.ogg',\
		"sound/machines/engine_grump2.ogg" = 'sound/machines/engine_grump2.ogg',\
		"sound/machines/engine_grump3.ogg" = 'sound/machines/engine_grump3.ogg',\
		"sound/machines/engine_grump4.ogg" = 'sound/machines/engine_grump4.ogg',\
		"sound/machines/engine_highpower.ogg" = 'sound/machines/engine_highpower.ogg',\
		"sound/machines/firealarm.ogg" = 'sound/machines/firealarm.ogg',\
		"sound/machines/fortune_greeting.ogg" = 'sound/machines/fortune_greeting.ogg',\
		"sound/machines/fortune_greeting_broken.ogg" = 'sound/machines/fortune_greeting_broken.ogg',\
		"sound/machines/fortune_laugh.ogg" = 'sound/machines/fortune_laugh.ogg',\
		"sound/machines/fortune_laugh_broken.ogg" = 'sound/machines/fortune_laugh_broken.ogg',\
		"sound/machines/fortune_riff.ogg" = 'sound/machines/fortune_riff.ogg',\
		"sound/machines/fortune_riff_broken.ogg" = 'sound/machines/fortune_riff_broken.ogg',\
		"sound/machines/found.ogg" = 'sound/machines/found.ogg',\
		"sound/machines/futurebuddy_beep.ogg" = 'sound/machines/futurebuddy_beep.ogg',\
		"sound/machines/genetics.ogg" = 'sound/machines/genetics.ogg',\
		"sound/machines/giantdrone_boop1.ogg" = 'sound/machines/giantdrone_boop1.ogg',\
		"sound/machines/giantdrone_boop2.ogg" = 'sound/machines/giantdrone_boop2.ogg',\
		"sound/machines/giantdrone_boop3.ogg" = 'sound/machines/giantdrone_boop3.ogg',\
		"sound/machines/giantdrone_boop4.ogg" = 'sound/machines/giantdrone_boop4.ogg',\
		"sound/machines/giantdrone_loop.ogg" = 'sound/machines/giantdrone_loop.ogg',\
		"sound/machines/giantdrone_startup.ogg" = 'sound/machines/giantdrone_startup.ogg',\
		"sound/machines/glitch1.ogg" = 'sound/machines/glitch1.ogg',\
		"sound/machines/glitch2.ogg" = 'sound/machines/glitch2.ogg',\
		"sound/machines/glitch3.ogg" = 'sound/machines/glitch3.ogg',\
		"sound/machines/glitch4.ogg" = 'sound/machines/glitch4.ogg',\
		"sound/machines/glitch5.ogg" = 'sound/machines/glitch5.ogg',\
		"sound/machines/heater_off.ogg" = 'sound/machines/heater_off.ogg',\
		"sound/machines/heater_on.ogg" = 'sound/machines/heater_on.ogg',\
		"sound/machines/hiss.ogg" = 'sound/machines/hiss.ogg',\
		"sound/machines/hydraulic.ogg" = 'sound/machines/hydraulic.ogg',\
		"sound/machines/interdictor_activate.ogg" = 'sound/machines/interdictor_activate.ogg',\
		"sound/machines/interdictor_deactivate.ogg" = 'sound/machines/interdictor_deactivate.ogg',\
		"sound/machines/interdictor_operate.ogg" = 'sound/machines/interdictor_operate.ogg',\
		"sound/machines/keyboard1.ogg" = 'sound/machines/keyboard1.ogg',\
		"sound/machines/keyboard2.ogg" = 'sound/machines/keyboard2.ogg',\
		"sound/machines/keyboard3.ogg" = 'sound/machines/keyboard3.ogg',\
		"sound/machines/keypress.ogg" = 'sound/machines/keypress.ogg',\
		"sound/machines/lavamoon_alarm1.ogg" = 'sound/machines/lavamoon_alarm1.ogg',\
		"sound/machines/lavamoon_computer_fx1.ogg" = 'sound/machines/lavamoon_computer_fx1.ogg',\
		"sound/machines/lavamoon_plantalarm.ogg" = 'sound/machines/lavamoon_plantalarm.ogg',\
		"sound/machines/lavamoon_rotors_fast.ogg" = 'sound/machines/lavamoon_rotors_fast.ogg',\
		"sound/machines/lavamoon_rotors_fast_short.ogg" = 'sound/machines/lavamoon_rotors_fast_short.ogg',\
		"sound/machines/lavamoon_rotors_slow.ogg" = 'sound/machines/lavamoon_rotors_slow.ogg',\
		"sound/machines/lavamoon_rotors_starting.ogg" = 'sound/machines/lavamoon_rotors_starting.ogg',\
		"sound/machines/lavamoon_rotors_stopping.ogg" = 'sound/machines/lavamoon_rotors_stopping.ogg',\
		"sound/machines/law_insert.ogg" = 'sound/machines/law_insert.ogg',\
		"sound/machines/law_remove.ogg" = 'sound/machines/law_remove.ogg',\
		"sound/machines/loom.ogg" = 'sound/machines/loom.ogg',\
		"sound/machines/lrteleport.ogg" = 'sound/machines/lrteleport.ogg',\
		"sound/machines/microwave_start.ogg" = 'sound/machines/microwave_start.ogg',\
		"sound/machines/milk_horn.ogg" = 'sound/machines/milk_horn.ogg',\
		"sound/machines/milk_horn_far.ogg" = 'sound/machines/milk_horn_far.ogg',\
		"sound/machines/mixer.ogg" = 'sound/machines/mixer.ogg',\
		"sound/machines/modem.ogg" = 'sound/machines/modem.ogg',\
		"sound/machines/paper_shredder.ogg" = 'sound/machines/paper_shredder.ogg',\
		"sound/machines/pc_process.ogg" = 'sound/machines/pc_process.ogg',\
		"sound/machines/phones/dial.ogg" = 'sound/machines/phones/dial.ogg',\
		"sound/machines/phones/dial2.ogg" = 'sound/machines/phones/dial2.ogg',\
		"sound/machines/phones/hang_up.ogg" = 'sound/machines/phones/hang_up.ogg',\
		"sound/machines/phones/phone_busy.ogg" = 'sound/machines/phones/phone_busy.ogg',\
		"sound/machines/phones/pick_up.ogg" = 'sound/machines/phones/pick_up.ogg',\
		"sound/machines/phones/remote_answer.ogg" = 'sound/machines/phones/remote_answer.ogg',\
		"sound/machines/phones/remote_hangup.ogg" = 'sound/machines/phones/remote_hangup.ogg',\
		"sound/machines/phones/ring_incoming.ogg" = 'sound/machines/phones/ring_incoming.ogg',\
		"sound/machines/phones/ring_outgoing.ogg" = 'sound/machines/phones/ring_outgoing.ogg',\
		"sound/machines/phones/ringtones/bebebeep.ogg" = 'sound/machines/phones/ringtones/bebebeep.ogg',\
		"sound/machines/phones/ringtones/bebobeboop.ogg" = 'sound/machines/phones/ringtones/bebobeboop.ogg',\
		"sound/machines/phones/ringtones/bobobebeep.ogg" = 'sound/machines/phones/ringtones/bobobebeep.ogg',\
		"sound/machines/phones/ringtones/ringers1.ogg" = 'sound/machines/phones/ringtones/ringers1.ogg',\
		"sound/machines/phones/ringtones/ringers10.ogg" = 'sound/machines/phones/ringtones/ringers10.ogg',\
		"sound/machines/phones/ringtones/ringers2.ogg" = 'sound/machines/phones/ringtones/ringers2.ogg',\
		"sound/machines/phones/ringtones/ringers3.ogg" = 'sound/machines/phones/ringtones/ringers3.ogg',\
		"sound/machines/phones/ringtones/ringers4.ogg" = 'sound/machines/phones/ringtones/ringers4.ogg',\
		"sound/machines/phones/ringtones/ringers5.ogg" = 'sound/machines/phones/ringtones/ringers5.ogg',\
		"sound/machines/phones/ringtones/ringers6.ogg" = 'sound/machines/phones/ringtones/ringers6.ogg',\
		"sound/machines/phones/ringtones/ringers7.ogg" = 'sound/machines/phones/ringtones/ringers7.ogg',\
		"sound/machines/phones/ringtones/ringers8.ogg" = 'sound/machines/phones/ringtones/ringers8.ogg',\
		"sound/machines/phones/ringtones/ringers9.ogg" = 'sound/machines/phones/ringtones/ringers9.ogg',\
		"sound/machines/phones/ringtones/ringershort1.ogg" = 'sound/machines/phones/ringtones/ringershort1.ogg',\
		"sound/machines/phones/ringtones/ringershort10.ogg" = 'sound/machines/phones/ringtones/ringershort10.ogg',\
		"sound/machines/phones/ringtones/ringershort2.ogg" = 'sound/machines/phones/ringtones/ringershort2.ogg',\
		"sound/machines/phones/ringtones/ringershort3.ogg" = 'sound/machines/phones/ringtones/ringershort3.ogg',\
		"sound/machines/phones/ringtones/ringershort4.ogg" = 'sound/machines/phones/ringtones/ringershort4.ogg',\
		"sound/machines/phones/ringtones/ringershort5.ogg" = 'sound/machines/phones/ringtones/ringershort5.ogg',\
		"sound/machines/phones/ringtones/ringershort6.ogg" = 'sound/machines/phones/ringtones/ringershort6.ogg',\
		"sound/machines/phones/ringtones/ringershort8.ogg" = 'sound/machines/phones/ringtones/ringershort8.ogg',\
		"sound/machines/phones/ringtones/ringershort9.ogg" = 'sound/machines/phones/ringtones/ringershort9.ogg',\
		"sound/machines/phones/ringtones/ringtone1.ogg" = 'sound/machines/phones/ringtones/ringtone1.ogg',\
		"sound/machines/phones/ringtones/ringtone1_short.ogg" = 'sound/machines/phones/ringtones/ringtone1_short.ogg',\
		"sound/machines/phones/ringtones/ringtone1_short_01.ogg" = 'sound/machines/phones/ringtones/ringtone1_short_01.ogg',\
		"sound/machines/phones/ringtones/ringtone1_short_02.ogg" = 'sound/machines/phones/ringtones/ringtone1_short_02.ogg',\
		"sound/machines/phones/ringtones/ringtone1_short_03.ogg" = 'sound/machines/phones/ringtones/ringtone1_short_03.ogg',\
		"sound/machines/phones/ringtones/ringtone2.ogg" = 'sound/machines/phones/ringtones/ringtone2.ogg',\
		"sound/machines/phones/ringtones/ringtone2_short.ogg" = 'sound/machines/phones/ringtones/ringtone2_short.ogg',\
		"sound/machines/phones/ringtones/ringtone2_short_01.ogg" = 'sound/machines/phones/ringtones/ringtone2_short_01.ogg',\
		"sound/machines/phones/ringtones/ringtone2_short_02.ogg" = 'sound/machines/phones/ringtones/ringtone2_short_02.ogg',\
		"sound/machines/phones/ringtones/ringtone2_short_03.ogg" = 'sound/machines/phones/ringtones/ringtone2_short_03.ogg',\
		"sound/machines/phones/ringtones/ringtone3.ogg" = 'sound/machines/phones/ringtones/ringtone3.ogg',\
		"sound/machines/phones/ringtones/ringtone3_short.ogg" = 'sound/machines/phones/ringtones/ringtone3_short.ogg',\
		"sound/machines/phones/ringtones/ringtone4.ogg" = 'sound/machines/phones/ringtones/ringtone4.ogg',\
		"sound/machines/phones/ringtones/ringtone4_short.ogg" = 'sound/machines/phones/ringtones/ringtone4_short.ogg',\
		"sound/machines/phones/ringtones/ringtone5.ogg" = 'sound/machines/phones/ringtones/ringtone5.ogg',\
		"sound/machines/phones/ringtones/ringtone5_short.ogg" = 'sound/machines/phones/ringtones/ringtone5_short.ogg',\
		"sound/machines/ping.ogg" = 'sound/machines/ping.ogg',\
		"sound/machines/pod_alarm.ogg" = 'sound/machines/pod_alarm.ogg',\
		"sound/machines/printer_cargo.ogg" = 'sound/machines/printer_cargo.ogg',\
		"sound/machines/printer_dotmatrix.ogg" = 'sound/machines/printer_dotmatrix.ogg',\
		"sound/machines/printer_press.ogg" = 'sound/machines/printer_press.ogg',\
		"sound/machines/printer_thermal.ogg" = 'sound/machines/printer_thermal.ogg',\
		"sound/machines/repairing.ogg" = 'sound/machines/repairing.ogg',\
		"sound/machines/reprog.ogg" = 'sound/machines/reprog.ogg',\
		"sound/machines/rev_engine.ogg" = 'sound/machines/rev_engine.ogg',\
		"sound/machines/rock_drill.ogg" = 'sound/machines/rock_drill.ogg',\
		"sound/machines/romhack1.ogg" = 'sound/machines/romhack1.ogg',\
		"sound/machines/romhack2.ogg" = 'sound/machines/romhack2.ogg',\
		"sound/machines/romhack3.ogg" = 'sound/machines/romhack3.ogg',\
		"sound/machines/satcrash.ogg" = 'sound/machines/satcrash.ogg',\
		"sound/machines/sawfly1.ogg" = 'sound/machines/sawfly1.ogg',\
		"sound/machines/sawfly2.ogg" = 'sound/machines/sawfly2.ogg',\
		"sound/machines/sawfly3.ogg" = 'sound/machines/sawfly3.ogg',\
		"sound/machines/sawflyrev.ogg" = 'sound/machines/sawflyrev.ogg',\
		"sound/machines/scan.ogg" = 'sound/machines/scan.ogg',\
		"sound/machines/scan2.ogg" = 'sound/machines/scan2.ogg',\
		"sound/machines/seed_destroyed.ogg" = 'sound/machines/seed_destroyed.ogg',\
		"sound/machines/shielddown.ogg" = 'sound/machines/shielddown.ogg',\
		"sound/machines/shieldgen_mainloop.ogg" = 'sound/machines/shieldgen_mainloop.ogg',\
		"sound/machines/shieldgen_shutoff.ogg" = 'sound/machines/shieldgen_shutoff.ogg',\
		"sound/machines/shieldgen_startup.ogg" = 'sound/machines/shieldgen_startup.ogg',\
		"sound/machines/shieldoverload.ogg" = 'sound/machines/shieldoverload.ogg',\
		"sound/machines/shieldup.ogg" = 'sound/machines/shieldup.ogg',\
		"sound/machines/signal.ogg" = 'sound/machines/signal.ogg',\
		"sound/machines/singulo_start.ogg" = 'sound/machines/singulo_start.ogg',\
		"sound/machines/siphon_activate.ogg" = 'sound/machines/siphon_activate.ogg',\
		"sound/machines/siphon_run.ogg" = 'sound/machines/siphon_run.ogg',\
		"sound/machines/siren_generalquarters.ogg" = 'sound/machines/siren_generalquarters.ogg',\
		"sound/machines/siren_generalquarters_quiet.ogg" = 'sound/machines/siren_generalquarters_quiet.ogg',\
		"sound/machines/siren_police.ogg" = 'sound/machines/siren_police.ogg',\
		"sound/machines/sleeper_close.ogg" = 'sound/machines/sleeper_close.ogg',\
		"sound/machines/sleeper_open.ogg" = 'sound/machines/sleeper_open.ogg',\
		"sound/machines/spend.ogg" = 'sound/machines/spend.ogg',\
		"sound/machines/squeaky_rolling.ogg" = 'sound/machines/squeaky_rolling.ogg',\
		"sound/machines/sweep.ogg" = 'sound/machines/sweep.ogg',\
		"sound/machines/tone_beep.ogg" = 'sound/machines/tone_beep.ogg',\
		"sound/machines/tractor_running.ogg" = 'sound/machines/tractor_running.ogg',\
		"sound/machines/tractor_running2.ogg" = 'sound/machines/tractor_running2.ogg',\
		"sound/machines/tractor_running3.ogg" = 'sound/machines/tractor_running3.ogg',\
		"sound/machines/tractorrev.ogg" = 'sound/machines/tractorrev.ogg',\
		"sound/machines/tram_bell.ogg" = 'sound/machines/tram_bell.ogg',\
		"sound/machines/transport_move.ogg" = 'sound/machines/transport_move.ogg',\
		"sound/machines/twobeep.ogg" = 'sound/machines/twobeep.ogg',\
		"sound/machines/twobeep2.ogg" = 'sound/machines/twobeep2.ogg',\
		"sound/machines/typewriter.ogg" = 'sound/machines/typewriter.ogg',\
		"sound/machines/ufo_move.ogg" = 'sound/machines/ufo_move.ogg',\
		"sound/machines/vending_crash.ogg" = 'sound/machines/vending_crash.ogg',\
		"sound/machines/vending_dispense.ogg" = 'sound/machines/vending_dispense.ogg',\
		"sound/machines/vending_dispense_small.ogg" = 'sound/machines/vending_dispense_small.ogg',\
		"sound/machines/warning-buzzer.ogg" = 'sound/machines/warning-buzzer.ogg',\
		"sound/machines/weaponoverload.ogg" = 'sound/machines/weaponoverload.ogg',\
		"sound/machines/weapons-deploy.ogg" = 'sound/machines/weapons-deploy.ogg',\
		"sound/machines/weapons-reloading.ogg" = 'sound/machines/weapons-reloading.ogg',\
		"sound/machines/whistlealert.ogg" = 'sound/machines/whistlealert.ogg',\
		"sound/machines/whistlebeep.ogg" = 'sound/machines/whistlebeep.ogg',\
		"sound/machines/wifi.ogg" = 'sound/machines/wifi.ogg',\
		"sound/machines/windowdoor.ogg" = 'sound/machines/windowdoor.ogg',\
		"sound/misc/adminhelp.ogg" = 'sound/misc/adminhelp.ogg',\
		"sound/misc/airraid_loop.ogg" = 'sound/misc/airraid_loop.ogg',\
		"sound/misc/airraid_loop_short.ogg" = 'sound/misc/airraid_loop_short.ogg',\
		"sound/misc/american_patriot.ogg" = 'sound/misc/american_patriot.ogg',\
		"sound/misc/amusingduck.ogg" = 'sound/misc/amusingduck.ogg',\
		"sound/misc/ancientbot_beep1.ogg" = 'sound/misc/ancientbot_beep1.ogg',\
		"sound/misc/ancientbot_beep2.ogg" = 'sound/misc/ancientbot_beep2.ogg',\
		"sound/misc/ancientbot_beep3.ogg" = 'sound/misc/ancientbot_beep3.ogg',\
		"sound/misc/ancientbot_buzz1.ogg" = 'sound/misc/ancientbot_buzz1.ogg',\
		"sound/misc/ancientbot_buzz2.ogg" = 'sound/misc/ancientbot_buzz2.ogg',\
		"sound/misc/ancientbot_grump.ogg" = 'sound/misc/ancientbot_grump.ogg',\
		"sound/misc/ancientbot_grump2.ogg" = 'sound/misc/ancientbot_grump2.ogg',\
		"sound/misc/android_cry.ogg" = 'sound/misc/android_cry.ogg',\
		"sound/misc/android_scream.ogg" = 'sound/misc/android_scream.ogg',\
		"sound/misc/android_throw.ogg" = 'sound/misc/android_throw.ogg',\
		"sound/misc/announcement_1.ogg" = 'sound/misc/announcement_1.ogg',\
		"sound/misc/announcement_chime.ogg" = 'sound/misc/announcement_chime.ogg',\
		"sound/misc/automaton_ratchet.ogg" = 'sound/misc/automaton_ratchet.ogg',\
		"sound/misc/automaton_scratch.ogg" = 'sound/misc/automaton_scratch.ogg',\
		"sound/misc/automaton_tickhum.ogg" = 'sound/misc/automaton_tickhum.ogg',\
		"sound/misc/beepbeep.ogg" = 'sound/misc/beepbeep.ogg',\
		"sound/misc/belt_click.ogg" = 'sound/misc/belt_click.ogg',\
		"sound/misc/blowout.ogg" = 'sound/misc/blowout.ogg',\
		"sound/misc/blowout_short.ogg" = 'sound/misc/blowout_short.ogg',\
		"sound/misc/body_thud.ogg" = 'sound/misc/body_thud.ogg',\
		"sound/misc/boing/1.ogg" = 'sound/misc/boing/1.ogg',\
		"sound/misc/boing/2.ogg" = 'sound/misc/boing/2.ogg',\
		"sound/misc/boing/3.ogg" = 'sound/misc/boing/3.ogg',\
		"sound/misc/boing/4.ogg" = 'sound/misc/boing/4.ogg',\
		"sound/misc/boing/5.ogg" = 'sound/misc/boing/5.ogg',\
		"sound/misc/boing/6.ogg" = 'sound/misc/boing/6.ogg',\
		"sound/misc/Boxingbell.ogg" = 'sound/misc/Boxingbell.ogg',\
		"sound/misc/bubble_pop.ogg" = 'sound/misc/bubble_pop.ogg',\
		"sound/misc/bugchitter.ogg" = 'sound/misc/bugchitter.ogg',\
		"sound/misc/cashregister.ogg" = 'sound/misc/cashregister.ogg',\
		"sound/misc/chair/glass/scoot1.ogg" = 'sound/misc/chair/glass/scoot1.ogg',\
		"sound/misc/chair/glass/scoot2.ogg" = 'sound/misc/chair/glass/scoot2.ogg',\
		"sound/misc/chair/glass/scoot3.ogg" = 'sound/misc/chair/glass/scoot3.ogg',\
		"sound/misc/chair/glass/scoot4.ogg" = 'sound/misc/chair/glass/scoot4.ogg',\
		"sound/misc/chair/glass/scoot5.ogg" = 'sound/misc/chair/glass/scoot5.ogg',\
		"sound/misc/chair/normal/scoot1.ogg" = 'sound/misc/chair/normal/scoot1.ogg',\
		"sound/misc/chair/normal/scoot2.ogg" = 'sound/misc/chair/normal/scoot2.ogg',\
		"sound/misc/chair/normal/scoot3.ogg" = 'sound/misc/chair/normal/scoot3.ogg',\
		"sound/misc/chair/normal/scoot4.ogg" = 'sound/misc/chair/normal/scoot4.ogg',\
		"sound/misc/chair/normal/scoot5.ogg" = 'sound/misc/chair/normal/scoot5.ogg',\
		"sound/misc/chair/office/scoot1.ogg" = 'sound/misc/chair/office/scoot1.ogg',\
		"sound/misc/chair/office/scoot2.ogg" = 'sound/misc/chair/office/scoot2.ogg',\
		"sound/misc/chair/office/scoot3.ogg" = 'sound/misc/chair/office/scoot3.ogg',\
		"sound/misc/chair/office/scoot4.ogg" = 'sound/misc/chair/office/scoot4.ogg',\
		"sound/misc/chair/office/scoot5.ogg" = 'sound/misc/chair/office/scoot5.ogg',\
		"sound/misc/chalkwrite_1.ogg" = 'sound/misc/chalkwrite_1.ogg',\
		"sound/misc/chalkwrite_2.ogg" = 'sound/misc/chalkwrite_2.ogg',\
		"sound/misc/chalkwrite_3.ogg" = 'sound/misc/chalkwrite_3.ogg',\
		"sound/misc/chalkwrite_4.ogg" = 'sound/misc/chalkwrite_4.ogg',\
		"sound/misc/chefsong.ogg" = 'sound/misc/chefsong.ogg',\
		"sound/misc/chefsong_end.ogg" = 'sound/misc/chefsong_end.ogg',\
		"sound/misc/chefsong_start.ogg" = 'sound/misc/chefsong_start.ogg',\
		"sound/misc/clownstep1.ogg" = 'sound/misc/clownstep1.ogg',\
		"sound/misc/clownstep2.ogg" = 'sound/misc/clownstep2.ogg',\
		"sound/misc/cluwnestep1.ogg" = 'sound/misc/cluwnestep1.ogg',\
		"sound/misc/cluwnestep2.ogg" = 'sound/misc/cluwnestep2.ogg',\
		"sound/misc/cluwnestep3.ogg" = 'sound/misc/cluwnestep3.ogg',\
		"sound/misc/cluwnestep4.ogg" = 'sound/misc/cluwnestep4.ogg',\
		"sound/misc/coffin_close.ogg" = 'sound/misc/coffin_close.ogg',\
		"sound/misc/coffin_open.ogg" = 'sound/misc/coffin_open.ogg',\
		"sound/misc/croak.ogg" = 'sound/misc/croak.ogg',\
		"sound/misc/curiosity_beep.ogg" = 'sound/misc/curiosity_beep.ogg',\
		"sound/misc/deepfrieddabs.ogg" = 'sound/misc/deepfrieddabs.ogg',\
		"sound/misc/drain_glug.ogg" = 'sound/misc/drain_glug.ogg',\
		"sound/misc/dreamy.ogg" = 'sound/misc/dreamy.ogg',\
		"sound/misc/drinkfizz.ogg" = 'sound/misc/drinkfizz.ogg',\
		"sound/misc/drinkfizz_honk.ogg" = 'sound/misc/drinkfizz_honk.ogg',\
		"sound/misc/eggdrop.ogg" = 'sound/misc/eggdrop.ogg',\
		"sound/misc/extreme_ass.ogg" = 'sound/misc/extreme_ass.ogg',\
		"sound/misc/flockmind/click.ogg" = 'sound/misc/flockmind/click.ogg',\
		"sound/misc/flockmind/deny.ogg" = 'sound/misc/flockmind/deny.ogg',\
		"sound/misc/flockmind/flock_broadcast_charge.ogg" = 'sound/misc/flockmind/flock_broadcast_charge.ogg',\
		"sound/misc/flockmind/flock_broadcast_kaboom.ogg" = 'sound/misc/flockmind/flock_broadcast_kaboom.ogg',\
		"sound/misc/flockmind/Flock_Reactor.ogg" = 'sound/misc/flockmind/Flock_Reactor.ogg',\
		"sound/misc/flockmind/flock_sound.ogg" = 'sound/misc/flockmind/flock_sound.ogg',\
		"sound/misc/flockmind/flockbit_wisp1.ogg" = 'sound/misc/flockmind/flockbit_wisp1.ogg',\
		"sound/misc/flockmind/flockbit_wisp2.ogg" = 'sound/misc/flockmind/flockbit_wisp2.ogg',\
		"sound/misc/flockmind/flockbit_wisp3.ogg" = 'sound/misc/flockmind/flockbit_wisp3.ogg',\
		"sound/misc/flockmind/flockbit_wisp4.ogg" = 'sound/misc/flockmind/flockbit_wisp4.ogg',\
		"sound/misc/flockmind/flockbit_wisp5.ogg" = 'sound/misc/flockmind/flockbit_wisp5.ogg',\
		"sound/misc/flockmind/flockbit_wisp6.ogg" = 'sound/misc/flockmind/flockbit_wisp6.ogg',\
		"sound/misc/flockmind/flockdrone_beep1.ogg" = 'sound/misc/flockmind/flockdrone_beep1.ogg',\
		"sound/misc/flockmind/flockdrone_beep2.ogg" = 'sound/misc/flockmind/flockdrone_beep2.ogg',\
		"sound/misc/flockmind/flockdrone_beep3.ogg" = 'sound/misc/flockmind/flockdrone_beep3.ogg',\
		"sound/misc/flockmind/flockdrone_beep4.ogg" = 'sound/misc/flockmind/flockdrone_beep4.ogg',\
		"sound/misc/flockmind/flockdrone_build.ogg" = 'sound/misc/flockmind/flockdrone_build.ogg',\
		"sound/misc/flockmind/flockdrone_build_complete.ogg" = 'sound/misc/flockmind/flockdrone_build_complete.ogg',\
		"sound/misc/flockmind/flockdrone_convert.ogg" = 'sound/misc/flockmind/flockdrone_convert.ogg',\
		"sound/misc/flockmind/flockdrone_door.ogg" = 'sound/misc/flockmind/flockdrone_door.ogg',\
		"sound/misc/flockmind/flockdrone_door_deny.ogg" = 'sound/misc/flockmind/flockdrone_door_deny.ogg',\
		"sound/misc/flockmind/flockdrone_fart.ogg" = 'sound/misc/flockmind/flockdrone_fart.ogg',\
		"sound/misc/flockmind/flockdrone_floorrun.ogg" = 'sound/misc/flockmind/flockdrone_floorrun.ogg',\
		"sound/misc/flockmind/flockdrone_grump1.ogg" = 'sound/misc/flockmind/flockdrone_grump1.ogg',\
		"sound/misc/flockmind/flockdrone_grump2.ogg" = 'sound/misc/flockmind/flockdrone_grump2.ogg',\
		"sound/misc/flockmind/flockdrone_grump3.ogg" = 'sound/misc/flockmind/flockdrone_grump3.ogg',\
		"sound/misc/flockmind/flockdrone_locker_close.ogg" = 'sound/misc/flockmind/flockdrone_locker_close.ogg',\
		"sound/misc/flockmind/flockdrone_locker_open.ogg" = 'sound/misc/flockmind/flockdrone_locker_open.ogg',\
		"sound/misc/flockmind/flockdrone_quickbuild.ogg" = 'sound/misc/flockmind/flockdrone_quickbuild.ogg',\
		"sound/misc/flockmind/flockmind_cast.ogg" = 'sound/misc/flockmind/flockmind_cast.ogg',\
		"sound/misc/flockmind/flockmind_caw.ogg" = 'sound/misc/flockmind/flockmind_caw.ogg',\
		"sound/misc/flockmind/flockmind_deathcry.ogg" = 'sound/misc/flockmind/flockmind_deathcry.ogg',\
		"sound/misc/flockmind/hover.ogg" = 'sound/misc/flockmind/hover.ogg',\
		"sound/misc/flockmind/ping.ogg" = 'sound/misc/flockmind/ping.ogg',\
		"sound/misc/footstep1.ogg" = 'sound/misc/footstep1.ogg',\
		"sound/misc/footstep2.ogg" = 'sound/misc/footstep2.ogg',\
		"sound/misc/fridge_close.ogg" = 'sound/misc/fridge_close.ogg',\
		"sound/misc/fridge_open.ogg" = 'sound/misc/fridge_open.ogg',\
		"sound/misc/fuse.ogg" = 'sound/misc/fuse.ogg',\
		"sound/misc/gnomegiggle.ogg" = 'sound/misc/gnomegiggle.ogg',\
		"sound/misc/ground_rumble.ogg" = 'sound/misc/ground_rumble.ogg',\
		"sound/misc/ground_rumble_big.ogg" = 'sound/misc/ground_rumble_big.ogg',\
		"sound/misc/gulp.ogg" = 'sound/misc/gulp.ogg',\
		"sound/misc/handle_click.ogg" = 'sound/misc/handle_click.ogg',\
		"sound/misc/hastur/devour1.ogg" = 'sound/misc/hastur/devour1.ogg',\
		"sound/misc/hastur/devour2.ogg" = 'sound/misc/hastur/devour2.ogg',\
		"sound/misc/hastur/devour3.ogg" = 'sound/misc/hastur/devour3.ogg',\
		"sound/misc/hastur/devour4.ogg" = 'sound/misc/hastur/devour4.ogg',\
		"sound/misc/hastur/growl.ogg" = 'sound/misc/hastur/growl.ogg',\
		"sound/misc/hastur/tentacle_hit.ogg" = 'sound/misc/hastur/tentacle_hit.ogg',\
		"sound/misc/hastur/tentacle_walk.ogg" = 'sound/misc/hastur/tentacle_walk.ogg',\
		"sound/misc/headspiderability.ogg" = 'sound/misc/headspiderability.ogg',\
		"sound/misc/jaws.ogg" = 'sound/misc/jaws.ogg',\
		"sound/misc/jester_laugh.ogg" = 'sound/misc/jester_laugh.ogg',\
		"sound/misc/JetpackMK2on.ogg" = 'sound/misc/JetpackMK2on.ogg',\
		"sound/misc/klaxon.ogg" = 'sound/misc/klaxon.ogg',\
		"sound/misc/knockout.ogg" = 'sound/misc/knockout.ogg',\
		"sound/misc/laughter/boo.ogg" = 'sound/misc/laughter/boo.ogg',\
		"sound/misc/laughter/laughtrack1.ogg" = 'sound/misc/laughter/laughtrack1.ogg',\
		"sound/misc/laughter/laughtrack2.ogg" = 'sound/misc/laughter/laughtrack2.ogg',\
		"sound/misc/laughter/laughtrack3.ogg" = 'sound/misc/laughter/laughtrack3.ogg',\
		"sound/misc/laughter/laughtrack4.ogg" = 'sound/misc/laughter/laughtrack4.ogg',\
		"sound/misc/lawnotify.ogg" = 'sound/misc/lawnotify.ogg',\
		"sound/misc/lightswitch.ogg" = 'sound/misc/lightswitch.ogg',\
		"sound/misc/lincolnshire.ogg" = 'sound/misc/lincolnshire.ogg',\
		"sound/misc/locker_close.ogg" = 'sound/misc/locker_close.ogg',\
		"sound/misc/locker_open.ogg" = 'sound/misc/locker_open.ogg',\
		"sound/misc/lose.ogg" = 'sound/misc/lose.ogg',\
		"sound/misc/meat_gargle.ogg" = 'sound/misc/meat_gargle.ogg',\
		"sound/misc/meat_hork.ogg" = 'sound/misc/meat_hork.ogg',\
		"sound/misc/meat_plop.ogg" = 'sound/misc/meat_plop.ogg',\
		"sound/misc/meat_splat.ogg" = 'sound/misc/meat_splat.ogg',\
		"sound/misc/meatmonaut1.ogg" = 'sound/misc/meatmonaut1.ogg',\
		"sound/misc/mechanical_footstep1.ogg" = 'sound/misc/mechanical_footstep1.ogg',\
		"sound/misc/mechanical_footstep2.ogg" = 'sound/misc/mechanical_footstep2.ogg',\
		"sound/misc/mechanical_footstep3.ogg" = 'sound/misc/mechanical_footstep3.ogg',\
		"sound/misc/mentorhelp.ogg" = 'sound/misc/mentorhelp.ogg',\
		"sound/misc/miccheck.ogg" = 'sound/misc/miccheck.ogg',\
		"sound/misc/molly_revived.ogg" = 'sound/misc/molly_revived.ogg',\
		"sound/misc/NewRound.ogg" = 'sound/misc/NewRound.ogg',\
		"sound/misc/NewRound2.ogg" = 'sound/misc/NewRound2.ogg',\
		"sound/misc/NewRound3.ogg" = 'sound/misc/NewRound3.ogg',\
		"sound/misc/NewRound4.ogg" = 'sound/misc/NewRound4.ogg',\
		"sound/misc/newsting.ogg" = 'sound/misc/newsting.ogg',\
		"sound/misc/nightclub.ogg" = 'sound/misc/nightclub.ogg',\
		"sound/misc/openlootcrate.ogg" = 'sound/misc/openlootcrate.ogg',\
		"sound/misc/openlootcrate2.ogg" = 'sound/misc/openlootcrate2.ogg',\
		"sound/misc/PhilCollinsTom.ogg" = 'sound/misc/PhilCollinsTom.ogg',\
		"sound/misc/pourdrink.ogg" = 'sound/misc/pourdrink.ogg',\
		"sound/misc/pourdrink2.ogg" = 'sound/misc/pourdrink2.ogg',\
		"sound/misc/prayerchime.ogg" = 'sound/misc/prayerchime.ogg',\
		"sound/misc/respawn.ogg" = 'sound/misc/respawn.ogg',\
		"sound/misc/rimshot.ogg" = 'sound/misc/rimshot.ogg',\
		"sound/misc/rustle1.ogg" = 'sound/misc/rustle1.ogg',\
		"sound/misc/rustle2.ogg" = 'sound/misc/rustle2.ogg',\
		"sound/misc/rustle3.ogg" = 'sound/misc/rustle3.ogg',\
		"sound/misc/rustle4.ogg" = 'sound/misc/rustle4.ogg',\
		"sound/misc/rustle5.ogg" = 'sound/misc/rustle5.ogg',\
		"sound/misc/sad_server_death.ogg" = 'sound/misc/sad_server_death.ogg',\
		"sound/misc/safe_close.ogg" = 'sound/misc/safe_close.ogg',\
		"sound/misc/safe_open.ogg" = 'sound/misc/safe_open.ogg',\
		"sound/misc/satanellite_bootsignal.ogg" = 'sound/misc/satanellite_bootsignal.ogg',\
		"sound/misc/satanellite_failedboot.ogg" = 'sound/misc/satanellite_failedboot.ogg',\
		"sound/misc/satanellite_signal01.ogg" = 'sound/misc/satanellite_signal01.ogg',\
		"sound/misc/satanellite_signal02.ogg" = 'sound/misc/satanellite_signal02.ogg',\
		"sound/misc/satanellite_signal03.ogg" = 'sound/misc/satanellite_signal03.ogg',\
		"sound/misc/satanellite_signal04.ogg" = 'sound/misc/satanellite_signal04.ogg',\
		"sound/misc/satanellite_signal420.ogg" = 'sound/misc/satanellite_signal420.ogg',\
		"sound/misc/shuttle_arrive1.ogg" = 'sound/misc/shuttle_arrive1.ogg',\
		"sound/misc/shuttle_centcom.ogg" = 'sound/misc/shuttle_centcom.ogg',\
		"sound/misc/shuttle_enroute.ogg" = 'sound/misc/shuttle_enroute.ogg',\
		"sound/misc/shuttle_recalled.ogg" = 'sound/misc/shuttle_recalled.ogg',\
		"sound/misc/sleeper_agent_hello.ogg" = 'sound/misc/sleeper_agent_hello.ogg',\
		"sound/misc/slip.ogg" = 'sound/misc/slip.ogg',\
		"sound/misc/slip_big.ogg" = 'sound/misc/slip_big.ogg',\
		"sound/misc/splash_1.ogg" = 'sound/misc/splash_1.ogg',\
		"sound/misc/splash_2.ogg" = 'sound/misc/splash_2.ogg',\
		"sound/misc/splash_3.ogg" = 'sound/misc/splash_3.ogg',\
		"sound/misc/stamp_paper.ogg" = 'sound/misc/stamp_paper.ogg',\
		"sound/misc/step/step_barefoot_1.ogg" = 'sound/misc/step/step_barefoot_1.ogg',\
		"sound/misc/step/step_barefoot_2.ogg" = 'sound/misc/step/step_barefoot_2.ogg',\
		"sound/misc/step/step_barefoot_3.ogg" = 'sound/misc/step/step_barefoot_3.ogg',\
		"sound/misc/step/step_barefoot_4.ogg" = 'sound/misc/step/step_barefoot_4.ogg',\
		"sound/misc/step/step_carpet_1.ogg" = 'sound/misc/step/step_carpet_1.ogg',\
		"sound/misc/step/step_carpet_2.ogg" = 'sound/misc/step/step_carpet_2.ogg',\
		"sound/misc/step/step_carpet_3.ogg" = 'sound/misc/step/step_carpet_3.ogg',\
		"sound/misc/step/step_carpet_4.ogg" = 'sound/misc/step/step_carpet_4.ogg',\
		"sound/misc/step/step_carpet_5.ogg" = 'sound/misc/step/step_carpet_5.ogg',\
		"sound/misc/step/step_default_1.ogg" = 'sound/misc/step/step_default_1.ogg',\
		"sound/misc/step/step_default_2.ogg" = 'sound/misc/step/step_default_2.ogg',\
		"sound/misc/step/step_default_3.ogg" = 'sound/misc/step/step_default_3.ogg',\
		"sound/misc/step/step_default_4.ogg" = 'sound/misc/step/step_default_4.ogg',\
		"sound/misc/step/step_default_5.ogg" = 'sound/misc/step/step_default_5.ogg',\
		"sound/misc/step/step_flipflop_1.ogg" = 'sound/misc/step/step_flipflop_1.ogg',\
		"sound/misc/step/step_flipflop_2.ogg" = 'sound/misc/step/step_flipflop_2.ogg',\
		"sound/misc/step/step_flipflop_3.ogg" = 'sound/misc/step/step_flipflop_3.ogg',\
		"sound/misc/step/step_heavyboots_1.ogg" = 'sound/misc/step/step_heavyboots_1.ogg',\
		"sound/misc/step/step_heavyboots_2.ogg" = 'sound/misc/step/step_heavyboots_2.ogg',\
		"sound/misc/step/step_heavyboots_3.ogg" = 'sound/misc/step/step_heavyboots_3.ogg',\
		"sound/misc/step/step_lattice_1.ogg" = 'sound/misc/step/step_lattice_1.ogg',\
		"sound/misc/step/step_lattice_2.ogg" = 'sound/misc/step/step_lattice_2.ogg',\
		"sound/misc/step/step_lattice_3.ogg" = 'sound/misc/step/step_lattice_3.ogg',\
		"sound/misc/step/step_lattice_4.ogg" = 'sound/misc/step/step_lattice_4.ogg',\
		"sound/misc/step/step_military_1.ogg" = 'sound/misc/step/step_military_1.ogg',\
		"sound/misc/step/step_military_2.ogg" = 'sound/misc/step/step_military_2.ogg',\
		"sound/misc/step/step_military_3.ogg" = 'sound/misc/step/step_military_3.ogg',\
		"sound/misc/step/step_military_4.ogg" = 'sound/misc/step/step_military_4.ogg',\
		"sound/misc/step/step_outdoors_1.ogg" = 'sound/misc/step/step_outdoors_1.ogg',\
		"sound/misc/step/step_outdoors_2.ogg" = 'sound/misc/step/step_outdoors_2.ogg',\
		"sound/misc/step/step_outdoors_3.ogg" = 'sound/misc/step/step_outdoors_3.ogg',\
		"sound/misc/step/step_plating_1.ogg" = 'sound/misc/step/step_plating_1.ogg',\
		"sound/misc/step/step_plating_2.ogg" = 'sound/misc/step/step_plating_2.ogg',\
		"sound/misc/step/step_plating_3.ogg" = 'sound/misc/step/step_plating_3.ogg',\
		"sound/misc/step/step_plating_4.ogg" = 'sound/misc/step/step_plating_4.ogg',\
		"sound/misc/step/step_plating_5.ogg" = 'sound/misc/step/step_plating_5.ogg',\
		"sound/misc/step/step_robo_1.ogg" = 'sound/misc/step/step_robo_1.ogg',\
		"sound/misc/step/step_robo_2.ogg" = 'sound/misc/step/step_robo_2.ogg',\
		"sound/misc/step/step_robo_3.ogg" = 'sound/misc/step/step_robo_3.ogg',\
		"sound/misc/step/step_rubberboot_1.ogg" = 'sound/misc/step/step_rubberboot_1.ogg',\
		"sound/misc/step/step_rubberboot_2.ogg" = 'sound/misc/step/step_rubberboot_2.ogg',\
		"sound/misc/step/step_rubberboot_3.ogg" = 'sound/misc/step/step_rubberboot_3.ogg',\
		"sound/misc/step/step_rubberboot_4.ogg" = 'sound/misc/step/step_rubberboot_4.ogg',\
		"sound/misc/step/step_wood_1.ogg" = 'sound/misc/step/step_wood_1.ogg',\
		"sound/misc/step/step_wood_2.ogg" = 'sound/misc/step/step_wood_2.ogg',\
		"sound/misc/step/step_wood_3.ogg" = 'sound/misc/step/step_wood_3.ogg',\
		"sound/misc/step/step_wood_4.ogg" = 'sound/misc/step/step_wood_4.ogg',\
		"sound/misc/step/step_wood_5.ogg" = 'sound/misc/step/step_wood_5.ogg',\
		"sound/misc/talk/blub.ogg" = 'sound/misc/talk/blub.ogg',\
		"sound/misc/talk/blub_ask.ogg" = 'sound/misc/talk/blub_ask.ogg',\
		"sound/misc/talk/blub_exclaim.ogg" = 'sound/misc/talk/blub_exclaim.ogg',\
		"sound/misc/talk/bottalk_1.ogg" = 'sound/misc/talk/bottalk_1.ogg',\
		"sound/misc/talk/bottalk_2.ogg" = 'sound/misc/talk/bottalk_2.ogg',\
		"sound/misc/talk/bottalk_3.ogg" = 'sound/misc/talk/bottalk_3.ogg',\
		"sound/misc/talk/buwoo.ogg" = 'sound/misc/talk/buwoo.ogg',\
		"sound/misc/talk/buwoo_ask.ogg" = 'sound/misc/talk/buwoo_ask.ogg',\
		"sound/misc/talk/buwoo_exclaim.ogg" = 'sound/misc/talk/buwoo_exclaim.ogg',\
		"sound/misc/talk/cow.ogg" = 'sound/misc/talk/cow.ogg',\
		"sound/misc/talk/cow_ask.ogg" = 'sound/misc/talk/cow_ask.ogg',\
		"sound/misc/talk/cow_exclaim.ogg" = 'sound/misc/talk/cow_exclaim.ogg',\
		"sound/misc/talk/cyborg.ogg" = 'sound/misc/talk/cyborg.ogg',\
		"sound/misc/talk/cyborg_ask.ogg" = 'sound/misc/talk/cyborg_ask.ogg',\
		"sound/misc/talk/cyborg_exclaim.ogg" = 'sound/misc/talk/cyborg_exclaim.ogg',\
		"sound/misc/talk/lizard.ogg" = 'sound/misc/talk/lizard.ogg',\
		"sound/misc/talk/lizard_ask.ogg" = 'sound/misc/talk/lizard_ask.ogg',\
		"sound/misc/talk/lizard_exclaim.ogg" = 'sound/misc/talk/lizard_exclaim.ogg',\
		"sound/misc/talk/pug.ogg" = 'sound/misc/talk/pug.ogg',\
		"sound/misc/talk/pug_ask.ogg" = 'sound/misc/talk/pug_ask.ogg',\
		"sound/misc/talk/pug_exclaim.ogg" = 'sound/misc/talk/pug_exclaim.ogg',\
		"sound/misc/talk/pugg.ogg" = 'sound/misc/talk/pugg.ogg',\
		"sound/misc/talk/pugg_ask.ogg" = 'sound/misc/talk/pugg_ask.ogg',\
		"sound/misc/talk/pugg_exclaim.ogg" = 'sound/misc/talk/pugg_exclaim.ogg',\
		"sound/misc/talk/radio.ogg" = 'sound/misc/talk/radio.ogg',\
		"sound/misc/talk/radio_ai.ogg" = 'sound/misc/talk/radio_ai.ogg',\
		"sound/misc/talk/radio2.ogg" = 'sound/misc/talk/radio2.ogg',\
		"sound/misc/talk/roach.ogg" = 'sound/misc/talk/roach.ogg',\
		"sound/misc/talk/roach_ask.ogg" = 'sound/misc/talk/roach_ask.ogg',\
		"sound/misc/talk/roach_exclaim.ogg" = 'sound/misc/talk/roach_exclaim.ogg',\
		"sound/misc/talk/skelly.ogg" = 'sound/misc/talk/skelly.ogg',\
		"sound/misc/talk/skelly_ask.ogg" = 'sound/misc/talk/skelly_ask.ogg',\
		"sound/misc/talk/skelly_exclaim.ogg" = 'sound/misc/talk/skelly_exclaim.ogg',\
		"sound/misc/talk/speak_1.ogg" = 'sound/misc/talk/speak_1.ogg',\
		"sound/misc/talk/speak_1_ask.ogg" = 'sound/misc/talk/speak_1_ask.ogg',\
		"sound/misc/talk/speak_1_exclaim.ogg" = 'sound/misc/talk/speak_1_exclaim.ogg',\
		"sound/misc/talk/speak_2.ogg" = 'sound/misc/talk/speak_2.ogg',\
		"sound/misc/talk/speak_2_ask.ogg" = 'sound/misc/talk/speak_2_ask.ogg',\
		"sound/misc/talk/speak_2_exclaim.ogg" = 'sound/misc/talk/speak_2_exclaim.ogg',\
		"sound/misc/talk/speak_3.ogg" = 'sound/misc/talk/speak_3.ogg',\
		"sound/misc/talk/speak_3_ask.ogg" = 'sound/misc/talk/speak_3_ask.ogg',\
		"sound/misc/talk/speak_3_exclaim.ogg" = 'sound/misc/talk/speak_3_exclaim.ogg',\
		"sound/misc/talk/speak_4.ogg" = 'sound/misc/talk/speak_4.ogg',\
		"sound/misc/talk/speak_4_ask.ogg" = 'sound/misc/talk/speak_4_ask.ogg',\
		"sound/misc/talk/speak_4_exclaim.ogg" = 'sound/misc/talk/speak_4_exclaim.ogg',\
		"sound/misc/thegoose_honk.ogg" = 'sound/misc/thegoose_honk.ogg',\
		"sound/misc/thegoose_song.ogg" = 'sound/misc/thegoose_song.ogg',\
		"sound/misc/TimeForANewRound.ogg" = 'sound/misc/TimeForANewRound.ogg',\
		"sound/misc/Warning_AssDay.ogg" = 'sound/misc/Warning_AssDay.ogg',\
		"sound/misc/waterflow.ogg" = 'sound/misc/waterflow.ogg',\
		"sound/misc/winding.ogg" = 'sound/misc/winding.ogg',\
		"sound/misc/yee.ogg" = 'sound/misc/yee.ogg',\
		"sound/misc/yee_music.ogg" = 'sound/misc/yee_music.ogg',\
		"sound/misc/zipper.ogg" = 'sound/misc/zipper.ogg',\
		"sound/mksounds/boost.ogg" = 'sound/mksounds/boost.ogg',\
		"sound/mksounds/cpuspin.ogg" = 'sound/mksounds/cpuspin.ogg',\
		"sound/mksounds/cputhrow.ogg" = 'sound/mksounds/cputhrow.ogg',\
		"sound/mksounds/gothit.ogg" = 'sound/mksounds/gothit.ogg',\
		"sound/mksounds/gotitem.ogg" = 'sound/mksounds/gotitem.ogg',\
		"sound/mksounds/invin10sec.ogg" = 'sound/mksounds/invin10sec.ogg',\
		"sound/mksounds/itemdestroy.ogg" = 'sound/mksounds/itemdestroy.ogg',\
		"sound/mksounds/itemdrop.ogg" = 'sound/mksounds/itemdrop.ogg',\
		"sound/mksounds/shellbounce.ogg" = 'sound/mksounds/shellbounce.ogg',\
		"sound/mksounds/skidd.ogg" = 'sound/mksounds/skidd.ogg',\
		"sound/mksounds/spinout.ogg" = 'sound/mksounds/spinout.ogg',\
		"sound/mksounds/throw.ogg" = 'sound/mksounds/throw.ogg',\
		"sound/musical_instruments/Airhorn_1.ogg" = 'sound/musical_instruments/Airhorn_1.ogg',\
		"sound/musical_instruments/artifact/Artifact_Ancient_1.ogg" = 'sound/musical_instruments/artifact/Artifact_Ancient_1.ogg',\
		"sound/musical_instruments/artifact/Artifact_Ancient_2.ogg" = 'sound/musical_instruments/artifact/Artifact_Ancient_2.ogg',\
		"sound/musical_instruments/artifact/Artifact_Ancient_3.ogg" = 'sound/musical_instruments/artifact/Artifact_Ancient_3.ogg',\
		"sound/musical_instruments/artifact/Artifact_Ancient_4.ogg" = 'sound/musical_instruments/artifact/Artifact_Ancient_4.ogg',\
		"sound/musical_instruments/artifact/Artifact_Bee_1.ogg" = 'sound/musical_instruments/artifact/Artifact_Bee_1.ogg',\
		"sound/musical_instruments/artifact/Artifact_Bee_2.ogg" = 'sound/musical_instruments/artifact/Artifact_Bee_2.ogg',\
		"sound/musical_instruments/artifact/Artifact_Bee_3.ogg" = 'sound/musical_instruments/artifact/Artifact_Bee_3.ogg',\
		"sound/musical_instruments/artifact/Artifact_Bee_4.ogg" = 'sound/musical_instruments/artifact/Artifact_Bee_4.ogg',\
		"sound/musical_instruments/artifact/Artifact_Eldritch_1.ogg" = 'sound/musical_instruments/artifact/Artifact_Eldritch_1.ogg',\
		"sound/musical_instruments/artifact/Artifact_Eldritch_2.ogg" = 'sound/musical_instruments/artifact/Artifact_Eldritch_2.ogg',\
		"sound/musical_instruments/artifact/Artifact_Eldritch_3.ogg" = 'sound/musical_instruments/artifact/Artifact_Eldritch_3.ogg',\
		"sound/musical_instruments/artifact/Artifact_Eldritch_4.ogg" = 'sound/musical_instruments/artifact/Artifact_Eldritch_4.ogg',\
		"sound/musical_instruments/artifact/Artifact_Feather_1.ogg" = 'sound/musical_instruments/artifact/Artifact_Feather_1.ogg',\
		"sound/musical_instruments/artifact/Artifact_Feather_2.ogg" = 'sound/musical_instruments/artifact/Artifact_Feather_2.ogg',\
		"sound/musical_instruments/artifact/Artifact_Feather_3.ogg" = 'sound/musical_instruments/artifact/Artifact_Feather_3.ogg',\
		"sound/musical_instruments/artifact/Artifact_Lattice_1.ogg" = 'sound/musical_instruments/artifact/Artifact_Lattice_1.ogg',\
		"sound/musical_instruments/artifact/Artifact_Lattice_2.ogg" = 'sound/musical_instruments/artifact/Artifact_Lattice_2.ogg',\
		"sound/musical_instruments/artifact/Artifact_Lattice_3.ogg" = 'sound/musical_instruments/artifact/Artifact_Lattice_3.ogg',\
		"sound/musical_instruments/artifact/Artifact_Martian_1.ogg" = 'sound/musical_instruments/artifact/Artifact_Martian_1.ogg',\
		"sound/musical_instruments/artifact/Artifact_Martian_2.ogg" = 'sound/musical_instruments/artifact/Artifact_Martian_2.ogg',\
		"sound/musical_instruments/artifact/Artifact_Martian_3.ogg" = 'sound/musical_instruments/artifact/Artifact_Martian_3.ogg',\
		"sound/musical_instruments/artifact/Artifact_Martian_4.ogg" = 'sound/musical_instruments/artifact/Artifact_Martian_4.ogg',\
		"sound/musical_instruments/artifact/Artifact_Precursor_1.ogg" = 'sound/musical_instruments/artifact/Artifact_Precursor_1.ogg',\
		"sound/musical_instruments/artifact/Artifact_Precursor_2.ogg" = 'sound/musical_instruments/artifact/Artifact_Precursor_2.ogg',\
		"sound/musical_instruments/artifact/Artifact_Precursor_3.ogg" = 'sound/musical_instruments/artifact/Artifact_Precursor_3.ogg',\
		"sound/musical_instruments/artifact/Artifact_Precursor_4.ogg" = 'sound/musical_instruments/artifact/Artifact_Precursor_4.ogg',\
		"sound/musical_instruments/artifact/Artifact_Precursor_5.ogg" = 'sound/musical_instruments/artifact/Artifact_Precursor_5.ogg',\
		"sound/musical_instruments/artifact/Artifact_Void_1.ogg" = 'sound/musical_instruments/artifact/Artifact_Void_1.ogg',\
		"sound/musical_instruments/artifact/Artifact_Void_2.ogg" = 'sound/musical_instruments/artifact/Artifact_Void_2.ogg',\
		"sound/musical_instruments/artifact/Artifact_Void_3.ogg" = 'sound/musical_instruments/artifact/Artifact_Void_3.ogg',\
		"sound/musical_instruments/artifact/Artifact_Void_4.ogg" = 'sound/musical_instruments/artifact/Artifact_Void_4.ogg',\
		"sound/musical_instruments/artifact/Artifact_Wizard_1.ogg" = 'sound/musical_instruments/artifact/Artifact_Wizard_1.ogg',\
		"sound/musical_instruments/artifact/Artifact_Wizard_2.ogg" = 'sound/musical_instruments/artifact/Artifact_Wizard_2.ogg',\
		"sound/musical_instruments/artifact/Artifact_Wizard_3.ogg" = 'sound/musical_instruments/artifact/Artifact_Wizard_3.ogg',\
		"sound/musical_instruments/artifact/Artifact_Wizard_4.ogg" = 'sound/musical_instruments/artifact/Artifact_Wizard_4.ogg',\
		"sound/musical_instruments/Bagpipes_1.ogg" = 'sound/musical_instruments/Bagpipes_1.ogg',\
		"sound/musical_instruments/Bagpipes_2.ogg" = 'sound/musical_instruments/Bagpipes_2.ogg',\
		"sound/musical_instruments/Bagpipes_3.ogg" = 'sound/musical_instruments/Bagpipes_3.ogg',\
		"sound/musical_instruments/banjo/notes/a3.ogg" = 'sound/musical_instruments/banjo/notes/a3.ogg',\
		"sound/musical_instruments/banjo/notes/a-3.ogg" = 'sound/musical_instruments/banjo/notes/a-3.ogg',\
		"sound/musical_instruments/banjo/notes/a4.ogg" = 'sound/musical_instruments/banjo/notes/a4.ogg',\
		"sound/musical_instruments/banjo/notes/a-4.ogg" = 'sound/musical_instruments/banjo/notes/a-4.ogg',\
		"sound/musical_instruments/banjo/notes/a5.ogg" = 'sound/musical_instruments/banjo/notes/a5.ogg',\
		"sound/musical_instruments/banjo/notes/a-5.ogg" = 'sound/musical_instruments/banjo/notes/a-5.ogg',\
		"sound/musical_instruments/banjo/notes/b3.ogg" = 'sound/musical_instruments/banjo/notes/b3.ogg',\
		"sound/musical_instruments/banjo/notes/b4.ogg" = 'sound/musical_instruments/banjo/notes/b4.ogg',\
		"sound/musical_instruments/banjo/notes/b5.ogg" = 'sound/musical_instruments/banjo/notes/b5.ogg',\
		"sound/musical_instruments/banjo/notes/c4.ogg" = 'sound/musical_instruments/banjo/notes/c4.ogg',\
		"sound/musical_instruments/banjo/notes/c-4.ogg" = 'sound/musical_instruments/banjo/notes/c-4.ogg',\
		"sound/musical_instruments/banjo/notes/c5.ogg" = 'sound/musical_instruments/banjo/notes/c5.ogg',\
		"sound/musical_instruments/banjo/notes/c-5.ogg" = 'sound/musical_instruments/banjo/notes/c-5.ogg',\
		"sound/musical_instruments/banjo/notes/c6.ogg" = 'sound/musical_instruments/banjo/notes/c6.ogg',\
		"sound/musical_instruments/banjo/notes/d4.ogg" = 'sound/musical_instruments/banjo/notes/d4.ogg',\
		"sound/musical_instruments/banjo/notes/d-4.ogg" = 'sound/musical_instruments/banjo/notes/d-4.ogg',\
		"sound/musical_instruments/banjo/notes/d5.ogg" = 'sound/musical_instruments/banjo/notes/d5.ogg',\
		"sound/musical_instruments/banjo/notes/d-5.ogg" = 'sound/musical_instruments/banjo/notes/d-5.ogg',\
		"sound/musical_instruments/banjo/notes/e3.ogg" = 'sound/musical_instruments/banjo/notes/e3.ogg',\
		"sound/musical_instruments/banjo/notes/e4.ogg" = 'sound/musical_instruments/banjo/notes/e4.ogg',\
		"sound/musical_instruments/banjo/notes/e5.ogg" = 'sound/musical_instruments/banjo/notes/e5.ogg',\
		"sound/musical_instruments/banjo/notes/f3.ogg" = 'sound/musical_instruments/banjo/notes/f3.ogg',\
		"sound/musical_instruments/banjo/notes/f-3.ogg" = 'sound/musical_instruments/banjo/notes/f-3.ogg',\
		"sound/musical_instruments/banjo/notes/f4.ogg" = 'sound/musical_instruments/banjo/notes/f4.ogg',\
		"sound/musical_instruments/banjo/notes/f-4.ogg" = 'sound/musical_instruments/banjo/notes/f-4.ogg',\
		"sound/musical_instruments/banjo/notes/f5.ogg" = 'sound/musical_instruments/banjo/notes/f5.ogg',\
		"sound/musical_instruments/banjo/notes/f-5.ogg" = 'sound/musical_instruments/banjo/notes/f-5.ogg',\
		"sound/musical_instruments/banjo/notes/g3.ogg" = 'sound/musical_instruments/banjo/notes/g3.ogg',\
		"sound/musical_instruments/banjo/notes/g-3.ogg" = 'sound/musical_instruments/banjo/notes/g-3.ogg',\
		"sound/musical_instruments/banjo/notes/g4.ogg" = 'sound/musical_instruments/banjo/notes/g4.ogg',\
		"sound/musical_instruments/banjo/notes/g-4.ogg" = 'sound/musical_instruments/banjo/notes/g-4.ogg',\
		"sound/musical_instruments/banjo/notes/g5.ogg" = 'sound/musical_instruments/banjo/notes/g5.ogg',\
		"sound/musical_instruments/banjo/notes/g-5.ogg" = 'sound/musical_instruments/banjo/notes/g-5.ogg',\
		"sound/musical_instruments/bard/lead1.ogg" = 'sound/musical_instruments/bard/lead1.ogg',\
		"sound/musical_instruments/bard/lead2.ogg" = 'sound/musical_instruments/bard/lead2.ogg',\
		"sound/musical_instruments/bard/riff.ogg" = 'sound/musical_instruments/bard/riff.ogg',\
		"sound/musical_instruments/bard/tapping1.ogg" = 'sound/musical_instruments/bard/tapping1.ogg',\
		"sound/musical_instruments/bard/tapping2.ogg" = 'sound/musical_instruments/bard/tapping2.ogg',\
		"sound/musical_instruments/Bell_Huge_1.ogg" = 'sound/musical_instruments/Bell_Huge_1.ogg',\
		"sound/musical_instruments/Bikehorn_1.ogg" = 'sound/musical_instruments/Bikehorn_1.ogg',\
		"sound/musical_instruments/Bikehorn_2.ogg" = 'sound/musical_instruments/Bikehorn_2.ogg',\
		"sound/musical_instruments/Bikehorn_bonk1.ogg" = 'sound/musical_instruments/Bikehorn_bonk1.ogg',\
		"sound/musical_instruments/Bikehorn_bonk2.ogg" = 'sound/musical_instruments/Bikehorn_bonk2.ogg',\
		"sound/musical_instruments/Bikehorn_bonk3.ogg" = 'sound/musical_instruments/Bikehorn_bonk3.ogg',\
		"sound/musical_instruments/Boathorn_1.ogg" = 'sound/musical_instruments/Boathorn_1.ogg',\
		"sound/musical_instruments/Carhorn_1.ogg" = 'sound/musical_instruments/Carhorn_1.ogg',\
		"sound/musical_instruments/cowbell/cowbell_1.ogg" = 'sound/musical_instruments/cowbell/cowbell_1.ogg',\
		"sound/musical_instruments/cowbell/cowbell_2.ogg" = 'sound/musical_instruments/cowbell/cowbell_2.ogg',\
		"sound/musical_instruments/cowbell/cowbell_3.ogg" = 'sound/musical_instruments/cowbell/cowbell_3.ogg',\
		"sound/musical_instruments/fiddle/notes/a3.ogg" = 'sound/musical_instruments/fiddle/notes/a3.ogg',\
		"sound/musical_instruments/fiddle/notes/a-3.ogg" = 'sound/musical_instruments/fiddle/notes/a-3.ogg',\
		"sound/musical_instruments/fiddle/notes/a4.ogg" = 'sound/musical_instruments/fiddle/notes/a4.ogg',\
		"sound/musical_instruments/fiddle/notes/a-4.ogg" = 'sound/musical_instruments/fiddle/notes/a-4.ogg',\
		"sound/musical_instruments/fiddle/notes/a5.ogg" = 'sound/musical_instruments/fiddle/notes/a5.ogg',\
		"sound/musical_instruments/fiddle/notes/a-5.ogg" = 'sound/musical_instruments/fiddle/notes/a-5.ogg',\
		"sound/musical_instruments/fiddle/notes/b3.ogg" = 'sound/musical_instruments/fiddle/notes/b3.ogg',\
		"sound/musical_instruments/fiddle/notes/b4.ogg" = 'sound/musical_instruments/fiddle/notes/b4.ogg',\
		"sound/musical_instruments/fiddle/notes/b5.ogg" = 'sound/musical_instruments/fiddle/notes/b5.ogg',\
		"sound/musical_instruments/fiddle/notes/c4.ogg" = 'sound/musical_instruments/fiddle/notes/c4.ogg',\
		"sound/musical_instruments/fiddle/notes/c-4.ogg" = 'sound/musical_instruments/fiddle/notes/c-4.ogg',\
		"sound/musical_instruments/fiddle/notes/c5.ogg" = 'sound/musical_instruments/fiddle/notes/c5.ogg',\
		"sound/musical_instruments/fiddle/notes/c-5.ogg" = 'sound/musical_instruments/fiddle/notes/c-5.ogg',\
		"sound/musical_instruments/fiddle/notes/c6.ogg" = 'sound/musical_instruments/fiddle/notes/c6.ogg',\
		"sound/musical_instruments/fiddle/notes/c-6.ogg" = 'sound/musical_instruments/fiddle/notes/c-6.ogg',\
		"sound/musical_instruments/fiddle/notes/d4.ogg" = 'sound/musical_instruments/fiddle/notes/d4.ogg',\
		"sound/musical_instruments/fiddle/notes/d-4.ogg" = 'sound/musical_instruments/fiddle/notes/d-4.ogg',\
		"sound/musical_instruments/fiddle/notes/d5.ogg" = 'sound/musical_instruments/fiddle/notes/d5.ogg',\
		"sound/musical_instruments/fiddle/notes/d-5.ogg" = 'sound/musical_instruments/fiddle/notes/d-5.ogg',\
		"sound/musical_instruments/fiddle/notes/d6.ogg" = 'sound/musical_instruments/fiddle/notes/d6.ogg',\
		"sound/musical_instruments/fiddle/notes/d-6.ogg" = 'sound/musical_instruments/fiddle/notes/d-6.ogg',\
		"sound/musical_instruments/fiddle/notes/e4.ogg" = 'sound/musical_instruments/fiddle/notes/e4.ogg',\
		"sound/musical_instruments/fiddle/notes/e5.ogg" = 'sound/musical_instruments/fiddle/notes/e5.ogg',\
		"sound/musical_instruments/fiddle/notes/e6.ogg" = 'sound/musical_instruments/fiddle/notes/e6.ogg',\
		"sound/musical_instruments/fiddle/notes/f4.ogg" = 'sound/musical_instruments/fiddle/notes/f4.ogg',\
		"sound/musical_instruments/fiddle/notes/f-4.ogg" = 'sound/musical_instruments/fiddle/notes/f-4.ogg',\
		"sound/musical_instruments/fiddle/notes/f5.ogg" = 'sound/musical_instruments/fiddle/notes/f5.ogg',\
		"sound/musical_instruments/fiddle/notes/f-5.ogg" = 'sound/musical_instruments/fiddle/notes/f-5.ogg',\
		"sound/musical_instruments/fiddle/notes/f6.ogg" = 'sound/musical_instruments/fiddle/notes/f6.ogg',\
		"sound/musical_instruments/fiddle/notes/f-6.ogg" = 'sound/musical_instruments/fiddle/notes/f-6.ogg',\
		"sound/musical_instruments/fiddle/notes/g3.ogg" = 'sound/musical_instruments/fiddle/notes/g3.ogg',\
		"sound/musical_instruments/fiddle/notes/g-3.ogg" = 'sound/musical_instruments/fiddle/notes/g-3.ogg',\
		"sound/musical_instruments/fiddle/notes/g4.ogg" = 'sound/musical_instruments/fiddle/notes/g4.ogg',\
		"sound/musical_instruments/fiddle/notes/g-4.ogg" = 'sound/musical_instruments/fiddle/notes/g-4.ogg',\
		"sound/musical_instruments/fiddle/notes/g5.ogg" = 'sound/musical_instruments/fiddle/notes/g5.ogg',\
		"sound/musical_instruments/fiddle/notes/g-5.ogg" = 'sound/musical_instruments/fiddle/notes/g-5.ogg',\
		"sound/musical_instruments/fiddle/notes/g6.ogg" = 'sound/musical_instruments/fiddle/notes/g6.ogg',\
		"sound/musical_instruments/fiddle/notes/g-6.ogg" = 'sound/musical_instruments/fiddle/notes/g-6.ogg',\
		"sound/musical_instruments/Fiddle_1.ogg" = 'sound/musical_instruments/Fiddle_1.ogg',\
		"sound/musical_instruments/Fiddle_2.ogg" = 'sound/musical_instruments/Fiddle_2.ogg',\
		"sound/musical_instruments/Fiddle_3.ogg" = 'sound/musical_instruments/Fiddle_3.ogg',\
		"sound/musical_instruments/Fiddle_4.ogg" = 'sound/musical_instruments/Fiddle_4.ogg',\
		"sound/musical_instruments/Fiddle_5.ogg" = 'sound/musical_instruments/Fiddle_5.ogg',\
		"sound/musical_instruments/Gong_Rumbling.ogg" = 'sound/musical_instruments/Gong_Rumbling.ogg',\
		"sound/musical_instruments/guitar/guitar_1.ogg" = 'sound/musical_instruments/guitar/guitar_1.ogg',\
		"sound/musical_instruments/guitar/guitar_10.ogg" = 'sound/musical_instruments/guitar/guitar_10.ogg',\
		"sound/musical_instruments/guitar/guitar_11.ogg" = 'sound/musical_instruments/guitar/guitar_11.ogg',\
		"sound/musical_instruments/guitar/guitar_12.ogg" = 'sound/musical_instruments/guitar/guitar_12.ogg',\
		"sound/musical_instruments/guitar/guitar_2.ogg" = 'sound/musical_instruments/guitar/guitar_2.ogg',\
		"sound/musical_instruments/guitar/guitar_3.ogg" = 'sound/musical_instruments/guitar/guitar_3.ogg',\
		"sound/musical_instruments/guitar/guitar_4.ogg" = 'sound/musical_instruments/guitar/guitar_4.ogg',\
		"sound/musical_instruments/guitar/guitar_5.ogg" = 'sound/musical_instruments/guitar/guitar_5.ogg',\
		"sound/musical_instruments/guitar/guitar_6.ogg" = 'sound/musical_instruments/guitar/guitar_6.ogg',\
		"sound/musical_instruments/guitar/guitar_7.ogg" = 'sound/musical_instruments/guitar/guitar_7.ogg',\
		"sound/musical_instruments/guitar/guitar_8.ogg" = 'sound/musical_instruments/guitar/guitar_8.ogg',\
		"sound/musical_instruments/guitar/guitar_9.ogg" = 'sound/musical_instruments/guitar/guitar_9.ogg',\
		"sound/musical_instruments/Guitar_bonk1.ogg" = 'sound/musical_instruments/Guitar_bonk1.ogg',\
		"sound/musical_instruments/Guitar_bonk2.ogg" = 'sound/musical_instruments/Guitar_bonk2.ogg',\
		"sound/musical_instruments/Guitar_bonk3.ogg" = 'sound/musical_instruments/Guitar_bonk3.ogg',\
		"sound/musical_instruments/Harmonica_1.ogg" = 'sound/musical_instruments/Harmonica_1.ogg',\
		"sound/musical_instruments/Harmonica_2.ogg" = 'sound/musical_instruments/Harmonica_2.ogg',\
		"sound/musical_instruments/Harmonica_3.ogg" = 'sound/musical_instruments/Harmonica_3.ogg',\
		"sound/musical_instruments/jukebox/jazzpiano.ogg" = 'sound/musical_instruments/jukebox/jazzpiano.ogg',\
		"sound/musical_instruments/jukebox/neosoul.ogg" = 'sound/musical_instruments/jukebox/neosoul.ogg',\
		"sound/musical_instruments/jukebox/ultralounge.ogg" = 'sound/musical_instruments/jukebox/ultralounge.ogg',\
		"sound/musical_instruments/jukebox/vintage.ogg" = 'sound/musical_instruments/jukebox/vintage.ogg',\
		"sound/musical_instruments/organ/bach1.ogg" = 'sound/musical_instruments/organ/bach1.ogg',\
		"sound/musical_instruments/organ/bach2.ogg" = 'sound/musical_instruments/organ/bach2.ogg',\
		"sound/musical_instruments/organ/bridal1.ogg" = 'sound/musical_instruments/organ/bridal1.ogg',\
		"sound/musical_instruments/organ/funeral.ogg" = 'sound/musical_instruments/organ/funeral.ogg',\
		"sound/musical_instruments/partybutton.ogg" = 'sound/musical_instruments/partybutton.ogg',\
		"sound/musical_instruments/piano/furelise.ogg" = 'sound/musical_instruments/piano/furelise.ogg',\
		"sound/musical_instruments/piano/gymno.ogg" = 'sound/musical_instruments/piano/gymno.ogg',\
		"sound/musical_instruments/piano/lune.ogg" = 'sound/musical_instruments/piano/lune.ogg',\
		"sound/musical_instruments/piano/nachtmusik1.ogg" = 'sound/musical_instruments/piano/nachtmusik1.ogg',\
		"sound/musical_instruments/piano/nachtmusik2.ogg" = 'sound/musical_instruments/piano/nachtmusik2.ogg',\
		"sound/musical_instruments/piano/notes/a0.ogg" = 'sound/musical_instruments/piano/notes/a0.ogg',\
		"sound/musical_instruments/piano/notes/a-0.ogg" = 'sound/musical_instruments/piano/notes/a-0.ogg',\
		"sound/musical_instruments/piano/notes/a1.ogg" = 'sound/musical_instruments/piano/notes/a1.ogg',\
		"sound/musical_instruments/piano/notes/a-1.ogg" = 'sound/musical_instruments/piano/notes/a-1.ogg',\
		"sound/musical_instruments/piano/notes/a2.ogg" = 'sound/musical_instruments/piano/notes/a2.ogg',\
		"sound/musical_instruments/piano/notes/a-2.ogg" = 'sound/musical_instruments/piano/notes/a-2.ogg',\
		"sound/musical_instruments/piano/notes/a3.ogg" = 'sound/musical_instruments/piano/notes/a3.ogg',\
		"sound/musical_instruments/piano/notes/a-3.ogg" = 'sound/musical_instruments/piano/notes/a-3.ogg',\
		"sound/musical_instruments/piano/notes/a4.ogg" = 'sound/musical_instruments/piano/notes/a4.ogg',\
		"sound/musical_instruments/piano/notes/a-4.ogg" = 'sound/musical_instruments/piano/notes/a-4.ogg',\
		"sound/musical_instruments/piano/notes/a5.ogg" = 'sound/musical_instruments/piano/notes/a5.ogg',\
		"sound/musical_instruments/piano/notes/a-5.ogg" = 'sound/musical_instruments/piano/notes/a-5.ogg',\
		"sound/musical_instruments/piano/notes/a6.ogg" = 'sound/musical_instruments/piano/notes/a6.ogg',\
		"sound/musical_instruments/piano/notes/a-6.ogg" = 'sound/musical_instruments/piano/notes/a-6.ogg',\
		"sound/musical_instruments/piano/notes/a7.ogg" = 'sound/musical_instruments/piano/notes/a7.ogg',\
		"sound/musical_instruments/piano/notes/a-7.ogg" = 'sound/musical_instruments/piano/notes/a-7.ogg',\
		"sound/musical_instruments/piano/notes/b0.ogg" = 'sound/musical_instruments/piano/notes/b0.ogg',\
		"sound/musical_instruments/piano/notes/b-0.ogg" = 'sound/musical_instruments/piano/notes/b-0.ogg',\
		"sound/musical_instruments/piano/notes/b1.ogg" = 'sound/musical_instruments/piano/notes/b1.ogg',\
		"sound/musical_instruments/piano/notes/b-1.ogg" = 'sound/musical_instruments/piano/notes/b-1.ogg',\
		"sound/musical_instruments/piano/notes/b2.ogg" = 'sound/musical_instruments/piano/notes/b2.ogg',\
		"sound/musical_instruments/piano/notes/b-2.ogg" = 'sound/musical_instruments/piano/notes/b-2.ogg',\
		"sound/musical_instruments/piano/notes/b3.ogg" = 'sound/musical_instruments/piano/notes/b3.ogg',\
		"sound/musical_instruments/piano/notes/b-3.ogg" = 'sound/musical_instruments/piano/notes/b-3.ogg',\
		"sound/musical_instruments/piano/notes/b4.ogg" = 'sound/musical_instruments/piano/notes/b4.ogg',\
		"sound/musical_instruments/piano/notes/b-4.ogg" = 'sound/musical_instruments/piano/notes/b-4.ogg',\
		"sound/musical_instruments/piano/notes/b5.ogg" = 'sound/musical_instruments/piano/notes/b5.ogg',\
		"sound/musical_instruments/piano/notes/b-5.ogg" = 'sound/musical_instruments/piano/notes/b-5.ogg',\
		"sound/musical_instruments/piano/notes/b6.ogg" = 'sound/musical_instruments/piano/notes/b6.ogg',\
		"sound/musical_instruments/piano/notes/b-6.ogg" = 'sound/musical_instruments/piano/notes/b-6.ogg',\
		"sound/musical_instruments/piano/notes/b7.ogg" = 'sound/musical_instruments/piano/notes/b7.ogg',\
		"sound/musical_instruments/piano/notes/b-7.ogg" = 'sound/musical_instruments/piano/notes/b-7.ogg',\
		"sound/musical_instruments/piano/notes/c1.ogg" = 'sound/musical_instruments/piano/notes/c1.ogg',\
		"sound/musical_instruments/piano/notes/c-1.ogg" = 'sound/musical_instruments/piano/notes/c-1.ogg',\
		"sound/musical_instruments/piano/notes/c2.ogg" = 'sound/musical_instruments/piano/notes/c2.ogg',\
		"sound/musical_instruments/piano/notes/c-2.ogg" = 'sound/musical_instruments/piano/notes/c-2.ogg',\
		"sound/musical_instruments/piano/notes/c3.ogg" = 'sound/musical_instruments/piano/notes/c3.ogg',\
		"sound/musical_instruments/piano/notes/c-3.ogg" = 'sound/musical_instruments/piano/notes/c-3.ogg',\
		"sound/musical_instruments/piano/notes/c4.ogg" = 'sound/musical_instruments/piano/notes/c4.ogg',\
		"sound/musical_instruments/piano/notes/c-4.ogg" = 'sound/musical_instruments/piano/notes/c-4.ogg',\
		"sound/musical_instruments/piano/notes/c5.ogg" = 'sound/musical_instruments/piano/notes/c5.ogg',\
		"sound/musical_instruments/piano/notes/c-5.ogg" = 'sound/musical_instruments/piano/notes/c-5.ogg',\
		"sound/musical_instruments/piano/notes/c6.ogg" = 'sound/musical_instruments/piano/notes/c6.ogg',\
		"sound/musical_instruments/piano/notes/c-6.ogg" = 'sound/musical_instruments/piano/notes/c-6.ogg',\
		"sound/musical_instruments/piano/notes/c7.ogg" = 'sound/musical_instruments/piano/notes/c7.ogg',\
		"sound/musical_instruments/piano/notes/c-7.ogg" = 'sound/musical_instruments/piano/notes/c-7.ogg',\
		"sound/musical_instruments/piano/notes/c8.ogg" = 'sound/musical_instruments/piano/notes/c8.ogg',\
		"sound/musical_instruments/piano/notes/d1.ogg" = 'sound/musical_instruments/piano/notes/d1.ogg',\
		"sound/musical_instruments/piano/notes/d-1.ogg" = 'sound/musical_instruments/piano/notes/d-1.ogg',\
		"sound/musical_instruments/piano/notes/d2.ogg" = 'sound/musical_instruments/piano/notes/d2.ogg',\
		"sound/musical_instruments/piano/notes/d-2.ogg" = 'sound/musical_instruments/piano/notes/d-2.ogg',\
		"sound/musical_instruments/piano/notes/d3.ogg" = 'sound/musical_instruments/piano/notes/d3.ogg',\
		"sound/musical_instruments/piano/notes/d-3.ogg" = 'sound/musical_instruments/piano/notes/d-3.ogg',\
		"sound/musical_instruments/piano/notes/d4.ogg" = 'sound/musical_instruments/piano/notes/d4.ogg',\
		"sound/musical_instruments/piano/notes/d-4.ogg" = 'sound/musical_instruments/piano/notes/d-4.ogg',\
		"sound/musical_instruments/piano/notes/d5.ogg" = 'sound/musical_instruments/piano/notes/d5.ogg',\
		"sound/musical_instruments/piano/notes/d-5.ogg" = 'sound/musical_instruments/piano/notes/d-5.ogg',\
		"sound/musical_instruments/piano/notes/d6.ogg" = 'sound/musical_instruments/piano/notes/d6.ogg',\
		"sound/musical_instruments/piano/notes/d-6.ogg" = 'sound/musical_instruments/piano/notes/d-6.ogg',\
		"sound/musical_instruments/piano/notes/d7.ogg" = 'sound/musical_instruments/piano/notes/d7.ogg',\
		"sound/musical_instruments/piano/notes/d-7.ogg" = 'sound/musical_instruments/piano/notes/d-7.ogg',\
		"sound/musical_instruments/piano/notes/e1.ogg" = 'sound/musical_instruments/piano/notes/e1.ogg',\
		"sound/musical_instruments/piano/notes/e-1.ogg" = 'sound/musical_instruments/piano/notes/e-1.ogg',\
		"sound/musical_instruments/piano/notes/e2.ogg" = 'sound/musical_instruments/piano/notes/e2.ogg',\
		"sound/musical_instruments/piano/notes/e-2.ogg" = 'sound/musical_instruments/piano/notes/e-2.ogg',\
		"sound/musical_instruments/piano/notes/e3.ogg" = 'sound/musical_instruments/piano/notes/e3.ogg',\
		"sound/musical_instruments/piano/notes/e-3.ogg" = 'sound/musical_instruments/piano/notes/e-3.ogg',\
		"sound/musical_instruments/piano/notes/e4.ogg" = 'sound/musical_instruments/piano/notes/e4.ogg',\
		"sound/musical_instruments/piano/notes/e-4.ogg" = 'sound/musical_instruments/piano/notes/e-4.ogg',\
		"sound/musical_instruments/piano/notes/e5.ogg" = 'sound/musical_instruments/piano/notes/e5.ogg',\
		"sound/musical_instruments/piano/notes/e-5.ogg" = 'sound/musical_instruments/piano/notes/e-5.ogg',\
		"sound/musical_instruments/piano/notes/e6.ogg" = 'sound/musical_instruments/piano/notes/e6.ogg',\
		"sound/musical_instruments/piano/notes/e-6.ogg" = 'sound/musical_instruments/piano/notes/e-6.ogg',\
		"sound/musical_instruments/piano/notes/e7.ogg" = 'sound/musical_instruments/piano/notes/e7.ogg',\
		"sound/musical_instruments/piano/notes/e-7.ogg" = 'sound/musical_instruments/piano/notes/e-7.ogg',\
		"sound/musical_instruments/piano/notes/f1.ogg" = 'sound/musical_instruments/piano/notes/f1.ogg',\
		"sound/musical_instruments/piano/notes/f-1.ogg" = 'sound/musical_instruments/piano/notes/f-1.ogg',\
		"sound/musical_instruments/piano/notes/f2.ogg" = 'sound/musical_instruments/piano/notes/f2.ogg',\
		"sound/musical_instruments/piano/notes/f-2.ogg" = 'sound/musical_instruments/piano/notes/f-2.ogg',\
		"sound/musical_instruments/piano/notes/f3.ogg" = 'sound/musical_instruments/piano/notes/f3.ogg',\
		"sound/musical_instruments/piano/notes/f-3.ogg" = 'sound/musical_instruments/piano/notes/f-3.ogg',\
		"sound/musical_instruments/piano/notes/f4.ogg" = 'sound/musical_instruments/piano/notes/f4.ogg',\
		"sound/musical_instruments/piano/notes/f-4.ogg" = 'sound/musical_instruments/piano/notes/f-4.ogg',\
		"sound/musical_instruments/piano/notes/f5.ogg" = 'sound/musical_instruments/piano/notes/f5.ogg',\
		"sound/musical_instruments/piano/notes/f-5.ogg" = 'sound/musical_instruments/piano/notes/f-5.ogg',\
		"sound/musical_instruments/piano/notes/f6.ogg" = 'sound/musical_instruments/piano/notes/f6.ogg',\
		"sound/musical_instruments/piano/notes/f-6.ogg" = 'sound/musical_instruments/piano/notes/f-6.ogg',\
		"sound/musical_instruments/piano/notes/f7.ogg" = 'sound/musical_instruments/piano/notes/f7.ogg',\
		"sound/musical_instruments/piano/notes/f-7.ogg" = 'sound/musical_instruments/piano/notes/f-7.ogg',\
		"sound/musical_instruments/piano/notes/g1.ogg" = 'sound/musical_instruments/piano/notes/g1.ogg',\
		"sound/musical_instruments/piano/notes/g-1.ogg" = 'sound/musical_instruments/piano/notes/g-1.ogg',\
		"sound/musical_instruments/piano/notes/g2.ogg" = 'sound/musical_instruments/piano/notes/g2.ogg',\
		"sound/musical_instruments/piano/notes/g-2.ogg" = 'sound/musical_instruments/piano/notes/g-2.ogg',\
		"sound/musical_instruments/piano/notes/g3.ogg" = 'sound/musical_instruments/piano/notes/g3.ogg',\
		"sound/musical_instruments/piano/notes/g-3.ogg" = 'sound/musical_instruments/piano/notes/g-3.ogg',\
		"sound/musical_instruments/piano/notes/g4.ogg" = 'sound/musical_instruments/piano/notes/g4.ogg',\
		"sound/musical_instruments/piano/notes/g-4.ogg" = 'sound/musical_instruments/piano/notes/g-4.ogg',\
		"sound/musical_instruments/piano/notes/g5.ogg" = 'sound/musical_instruments/piano/notes/g5.ogg',\
		"sound/musical_instruments/piano/notes/g-5.ogg" = 'sound/musical_instruments/piano/notes/g-5.ogg',\
		"sound/musical_instruments/piano/notes/g6.ogg" = 'sound/musical_instruments/piano/notes/g6.ogg',\
		"sound/musical_instruments/piano/notes/g-6.ogg" = 'sound/musical_instruments/piano/notes/g-6.ogg',\
		"sound/musical_instruments/piano/notes/g7.ogg" = 'sound/musical_instruments/piano/notes/g7.ogg',\
		"sound/musical_instruments/piano/notes/g-7.ogg" = 'sound/musical_instruments/piano/notes/g-7.ogg',\
		"sound/musical_instruments/piano/notes/rrr.ogg" = 'sound/musical_instruments/piano/notes/rrr.ogg',\
		"sound/musical_instruments/saxbonk.ogg" = 'sound/musical_instruments/saxbonk.ogg',\
		"sound/musical_instruments/saxbonk2.ogg" = 'sound/musical_instruments/saxbonk2.ogg',\
		"sound/musical_instruments/saxbonk3.ogg" = 'sound/musical_instruments/saxbonk3.ogg',\
		"sound/musical_instruments/saxophone/notes/a3.ogg" = 'sound/musical_instruments/saxophone/notes/a3.ogg',\
		"sound/musical_instruments/saxophone/notes/a-3.ogg" = 'sound/musical_instruments/saxophone/notes/a-3.ogg',\
		"sound/musical_instruments/saxophone/notes/a4.ogg" = 'sound/musical_instruments/saxophone/notes/a4.ogg',\
		"sound/musical_instruments/saxophone/notes/a-4.ogg" = 'sound/musical_instruments/saxophone/notes/a-4.ogg',\
		"sound/musical_instruments/saxophone/notes/a5.ogg" = 'sound/musical_instruments/saxophone/notes/a5.ogg',\
		"sound/musical_instruments/saxophone/notes/a-5.ogg" = 'sound/musical_instruments/saxophone/notes/a-5.ogg',\
		"sound/musical_instruments/saxophone/notes/b3.ogg" = 'sound/musical_instruments/saxophone/notes/b3.ogg',\
		"sound/musical_instruments/saxophone/notes/b4.ogg" = 'sound/musical_instruments/saxophone/notes/b4.ogg',\
		"sound/musical_instruments/saxophone/notes/b5.ogg" = 'sound/musical_instruments/saxophone/notes/b5.ogg',\
		"sound/musical_instruments/saxophone/notes/c4.ogg" = 'sound/musical_instruments/saxophone/notes/c4.ogg',\
		"sound/musical_instruments/saxophone/notes/c-4.ogg" = 'sound/musical_instruments/saxophone/notes/c-4.ogg',\
		"sound/musical_instruments/saxophone/notes/c5.ogg" = 'sound/musical_instruments/saxophone/notes/c5.ogg',\
		"sound/musical_instruments/saxophone/notes/c-5.ogg" = 'sound/musical_instruments/saxophone/notes/c-5.ogg',\
		"sound/musical_instruments/saxophone/notes/c6.ogg" = 'sound/musical_instruments/saxophone/notes/c6.ogg',\
		"sound/musical_instruments/saxophone/notes/d4.ogg" = 'sound/musical_instruments/saxophone/notes/d4.ogg',\
		"sound/musical_instruments/saxophone/notes/d-4.ogg" = 'sound/musical_instruments/saxophone/notes/d-4.ogg',\
		"sound/musical_instruments/saxophone/notes/d5.ogg" = 'sound/musical_instruments/saxophone/notes/d5.ogg',\
		"sound/musical_instruments/saxophone/notes/d-5.ogg" = 'sound/musical_instruments/saxophone/notes/d-5.ogg',\
		"sound/musical_instruments/saxophone/notes/e4.ogg" = 'sound/musical_instruments/saxophone/notes/e4.ogg',\
		"sound/musical_instruments/saxophone/notes/e5.ogg" = 'sound/musical_instruments/saxophone/notes/e5.ogg',\
		"sound/musical_instruments/saxophone/notes/f4.ogg" = 'sound/musical_instruments/saxophone/notes/f4.ogg',\
		"sound/musical_instruments/saxophone/notes/f-4.ogg" = 'sound/musical_instruments/saxophone/notes/f-4.ogg',\
		"sound/musical_instruments/saxophone/notes/f5.ogg" = 'sound/musical_instruments/saxophone/notes/f5.ogg',\
		"sound/musical_instruments/saxophone/notes/f-5.ogg" = 'sound/musical_instruments/saxophone/notes/f-5.ogg',\
		"sound/musical_instruments/saxophone/notes/g3.ogg" = 'sound/musical_instruments/saxophone/notes/g3.ogg',\
		"sound/musical_instruments/saxophone/notes/g-3.ogg" = 'sound/musical_instruments/saxophone/notes/g-3.ogg',\
		"sound/musical_instruments/saxophone/notes/g4.ogg" = 'sound/musical_instruments/saxophone/notes/g4.ogg',\
		"sound/musical_instruments/saxophone/notes/g-4.ogg" = 'sound/musical_instruments/saxophone/notes/g-4.ogg',\
		"sound/musical_instruments/saxophone/notes/g5.ogg" = 'sound/musical_instruments/saxophone/notes/g5.ogg',\
		"sound/musical_instruments/saxophone/notes/g-5.ogg" = 'sound/musical_instruments/saxophone/notes/g-5.ogg',\
		"sound/musical_instruments/tambourine/tambourine_1.ogg" = 'sound/musical_instruments/tambourine/tambourine_1.ogg',\
		"sound/musical_instruments/tambourine/tambourine_2.ogg" = 'sound/musical_instruments/tambourine/tambourine_2.ogg',\
		"sound/musical_instruments/tambourine/tambourine_3.ogg" = 'sound/musical_instruments/tambourine/tambourine_3.ogg',\
		"sound/musical_instruments/tambourine/tambourine_4.ogg" = 'sound/musical_instruments/tambourine/tambourine_4.ogg',\
		"sound/musical_instruments/triangle/triangle_1.ogg" = 'sound/musical_instruments/triangle/triangle_1.ogg',\
		"sound/musical_instruments/triangle/triangle_2.ogg" = 'sound/musical_instruments/triangle/triangle_2.ogg',\
		"sound/musical_instruments/Trombone_Failiure.ogg" = 'sound/musical_instruments/Trombone_Failiure.ogg',\
		"sound/musical_instruments/trumpet/notes/a3.ogg" = 'sound/musical_instruments/trumpet/notes/a3.ogg',\
		"sound/musical_instruments/trumpet/notes/a-3.ogg" = 'sound/musical_instruments/trumpet/notes/a-3.ogg',\
		"sound/musical_instruments/trumpet/notes/a4.ogg" = 'sound/musical_instruments/trumpet/notes/a4.ogg',\
		"sound/musical_instruments/trumpet/notes/a-4.ogg" = 'sound/musical_instruments/trumpet/notes/a-4.ogg',\
		"sound/musical_instruments/trumpet/notes/a5.ogg" = 'sound/musical_instruments/trumpet/notes/a5.ogg',\
		"sound/musical_instruments/trumpet/notes/a-5.ogg" = 'sound/musical_instruments/trumpet/notes/a-5.ogg',\
		"sound/musical_instruments/trumpet/notes/b3.ogg" = 'sound/musical_instruments/trumpet/notes/b3.ogg',\
		"sound/musical_instruments/trumpet/notes/b4.ogg" = 'sound/musical_instruments/trumpet/notes/b4.ogg',\
		"sound/musical_instruments/trumpet/notes/b5.ogg" = 'sound/musical_instruments/trumpet/notes/b5.ogg',\
		"sound/musical_instruments/trumpet/notes/c4.ogg" = 'sound/musical_instruments/trumpet/notes/c4.ogg',\
		"sound/musical_instruments/trumpet/notes/c-4.ogg" = 'sound/musical_instruments/trumpet/notes/c-4.ogg',\
		"sound/musical_instruments/trumpet/notes/c5.ogg" = 'sound/musical_instruments/trumpet/notes/c5.ogg',\
		"sound/musical_instruments/trumpet/notes/c-5.ogg" = 'sound/musical_instruments/trumpet/notes/c-5.ogg',\
		"sound/musical_instruments/trumpet/notes/c6.ogg" = 'sound/musical_instruments/trumpet/notes/c6.ogg',\
		"sound/musical_instruments/trumpet/notes/d4.ogg" = 'sound/musical_instruments/trumpet/notes/d4.ogg',\
		"sound/musical_instruments/trumpet/notes/d-4.ogg" = 'sound/musical_instruments/trumpet/notes/d-4.ogg',\
		"sound/musical_instruments/trumpet/notes/d5.ogg" = 'sound/musical_instruments/trumpet/notes/d5.ogg',\
		"sound/musical_instruments/trumpet/notes/d-5.ogg" = 'sound/musical_instruments/trumpet/notes/d-5.ogg',\
		"sound/musical_instruments/trumpet/notes/e3.ogg" = 'sound/musical_instruments/trumpet/notes/e3.ogg',\
		"sound/musical_instruments/trumpet/notes/e4.ogg" = 'sound/musical_instruments/trumpet/notes/e4.ogg',\
		"sound/musical_instruments/trumpet/notes/e5.ogg" = 'sound/musical_instruments/trumpet/notes/e5.ogg',\
		"sound/musical_instruments/trumpet/notes/f3.ogg" = 'sound/musical_instruments/trumpet/notes/f3.ogg',\
		"sound/musical_instruments/trumpet/notes/f-3.ogg" = 'sound/musical_instruments/trumpet/notes/f-3.ogg',\
		"sound/musical_instruments/trumpet/notes/f4.ogg" = 'sound/musical_instruments/trumpet/notes/f4.ogg',\
		"sound/musical_instruments/trumpet/notes/f-4.ogg" = 'sound/musical_instruments/trumpet/notes/f-4.ogg',\
		"sound/musical_instruments/trumpet/notes/f5.ogg" = 'sound/musical_instruments/trumpet/notes/f5.ogg',\
		"sound/musical_instruments/trumpet/notes/f-5.ogg" = 'sound/musical_instruments/trumpet/notes/f-5.ogg',\
		"sound/musical_instruments/trumpet/notes/g3.ogg" = 'sound/musical_instruments/trumpet/notes/g3.ogg',\
		"sound/musical_instruments/trumpet/notes/g-3.ogg" = 'sound/musical_instruments/trumpet/notes/g-3.ogg',\
		"sound/musical_instruments/trumpet/notes/g4.ogg" = 'sound/musical_instruments/trumpet/notes/g4.ogg',\
		"sound/musical_instruments/trumpet/notes/g-4.ogg" = 'sound/musical_instruments/trumpet/notes/g-4.ogg',\
		"sound/musical_instruments/trumpet/notes/g5.ogg" = 'sound/musical_instruments/trumpet/notes/g5.ogg',\
		"sound/musical_instruments/trumpet/notes/g-5.ogg" = 'sound/musical_instruments/trumpet/notes/g-5.ogg',\
		"sound/musical_instruments/Vuvuzela_1.ogg" = 'sound/musical_instruments/Vuvuzela_1.ogg',\
		"sound/musical_instruments/WeirdChime_0.ogg" = 'sound/musical_instruments/WeirdChime_0.ogg',\
		"sound/musical_instruments/WeirdChime_1.ogg" = 'sound/musical_instruments/WeirdChime_1.ogg',\
		"sound/musical_instruments/WeirdChime_10.ogg" = 'sound/musical_instruments/WeirdChime_10.ogg',\
		"sound/musical_instruments/WeirdChime_11.ogg" = 'sound/musical_instruments/WeirdChime_11.ogg',\
		"sound/musical_instruments/WeirdChime_12.ogg" = 'sound/musical_instruments/WeirdChime_12.ogg',\
		"sound/musical_instruments/WeirdChime_2.ogg" = 'sound/musical_instruments/WeirdChime_2.ogg',\
		"sound/musical_instruments/WeirdChime_3.ogg" = 'sound/musical_instruments/WeirdChime_3.ogg',\
		"sound/musical_instruments/WeirdChime_4.ogg" = 'sound/musical_instruments/WeirdChime_4.ogg',\
		"sound/musical_instruments/WeirdChime_5.ogg" = 'sound/musical_instruments/WeirdChime_5.ogg',\
		"sound/musical_instruments/WeirdChime_6.ogg" = 'sound/musical_instruments/WeirdChime_6.ogg',\
		"sound/musical_instruments/WeirdChime_7.ogg" = 'sound/musical_instruments/WeirdChime_7.ogg',\
		"sound/musical_instruments/WeirdChime_8.ogg" = 'sound/musical_instruments/WeirdChime_8.ogg',\
		"sound/musical_instruments/WeirdChime_9.ogg" = 'sound/musical_instruments/WeirdChime_9.ogg',\
		"sound/musical_instruments/WeirdHorn_0.ogg" = 'sound/musical_instruments/WeirdHorn_0.ogg',\
		"sound/musical_instruments/WeirdHorn_1.ogg" = 'sound/musical_instruments/WeirdHorn_1.ogg',\
		"sound/musical_instruments/WeirdHorn_10.ogg" = 'sound/musical_instruments/WeirdHorn_10.ogg',\
		"sound/musical_instruments/WeirdHorn_11.ogg" = 'sound/musical_instruments/WeirdHorn_11.ogg',\
		"sound/musical_instruments/WeirdHorn_12.ogg" = 'sound/musical_instruments/WeirdHorn_12.ogg',\
		"sound/musical_instruments/WeirdHorn_2.ogg" = 'sound/musical_instruments/WeirdHorn_2.ogg',\
		"sound/musical_instruments/WeirdHorn_3.ogg" = 'sound/musical_instruments/WeirdHorn_3.ogg',\
		"sound/musical_instruments/WeirdHorn_4.ogg" = 'sound/musical_instruments/WeirdHorn_4.ogg',\
		"sound/musical_instruments/WeirdHorn_5.ogg" = 'sound/musical_instruments/WeirdHorn_5.ogg',\
		"sound/musical_instruments/WeirdHorn_6.ogg" = 'sound/musical_instruments/WeirdHorn_6.ogg',\
		"sound/musical_instruments/WeirdHorn_7.ogg" = 'sound/musical_instruments/WeirdHorn_7.ogg',\
		"sound/musical_instruments/WeirdHorn_8.ogg" = 'sound/musical_instruments/WeirdHorn_8.ogg',\
		"sound/musical_instruments/WeirdHorn_9.ogg" = 'sound/musical_instruments/WeirdHorn_9.ogg',\
		"sound/voice/animal/brullbar_cry.ogg" = 'sound/voice/animal/brullbar_cry.ogg',\
		"sound/voice/animal/brullbar_laugh.ogg" = 'sound/voice/animal/brullbar_laugh.ogg',\
		"sound/voice/animal/brullbar_maul.ogg" = 'sound/voice/animal/brullbar_maul.ogg',\
		"sound/voice/animal/brullbar_roar.ogg" = 'sound/voice/animal/brullbar_roar.ogg',\
		"sound/voice/animal/brullbar_scream.ogg" = 'sound/voice/animal/brullbar_scream.ogg',\
		"sound/voice/animal/bugchitter.ogg" = 'sound/voice/animal/bugchitter.ogg',\
		"sound/voice/animal/bull.ogg" = 'sound/voice/animal/bull.ogg',\
		"sound/voice/animal/butterflyscream.ogg" = 'sound/voice/animal/butterflyscream.ogg',\
		"sound/voice/animal/buzz.ogg" = 'sound/voice/animal/buzz.ogg',\
		"sound/voice/animal/cat.ogg" = 'sound/voice/animal/cat.ogg',\
		"sound/voice/animal/cat_hiss.ogg" = 'sound/voice/animal/cat_hiss.ogg',\
		"sound/voice/animal/crab_chirp.ogg" = 'sound/voice/animal/crab_chirp.ogg',\
		"sound/voice/animal/dogbark.ogg" = 'sound/voice/animal/dogbark.ogg',\
		"sound/voice/animal/fly_buzz.ogg" = 'sound/voice/animal/fly_buzz.ogg',\
		"sound/voice/animal/gabe1.ogg" = 'sound/voice/animal/gabe1.ogg',\
		"sound/voice/animal/gabe10.ogg" = 'sound/voice/animal/gabe10.ogg',\
		"sound/voice/animal/gabe11.ogg" = 'sound/voice/animal/gabe11.ogg',\
		"sound/voice/animal/gabe2.ogg" = 'sound/voice/animal/gabe2.ogg',\
		"sound/voice/animal/gabe3.ogg" = 'sound/voice/animal/gabe3.ogg',\
		"sound/voice/animal/gabe4.ogg" = 'sound/voice/animal/gabe4.ogg',\
		"sound/voice/animal/gabe5.ogg" = 'sound/voice/animal/gabe5.ogg',\
		"sound/voice/animal/gabe6.ogg" = 'sound/voice/animal/gabe6.ogg',\
		"sound/voice/animal/gabe7.ogg" = 'sound/voice/animal/gabe7.ogg',\
		"sound/voice/animal/gabe8.ogg" = 'sound/voice/animal/gabe8.ogg',\
		"sound/voice/animal/gabe9.ogg" = 'sound/voice/animal/gabe9.ogg',\
		"sound/voice/animal/goose.ogg" = 'sound/voice/animal/goose.ogg',\
		"sound/voice/animal/hoot.ogg" = 'sound/voice/animal/hoot.ogg',\
		"sound/voice/animal/howl1.ogg" = 'sound/voice/animal/howl1.ogg',\
		"sound/voice/animal/howl2.ogg" = 'sound/voice/animal/howl2.ogg',\
		"sound/voice/animal/howl3.ogg" = 'sound/voice/animal/howl3.ogg',\
		"sound/voice/animal/howl4.ogg" = 'sound/voice/animal/howl4.ogg',\
		"sound/voice/animal/howl5.ogg" = 'sound/voice/animal/howl5.ogg',\
		"sound/voice/animal/howl6.ogg" = 'sound/voice/animal/howl6.ogg',\
		"sound/voice/animal/mouse_squeak.ogg" = 'sound/voice/animal/mouse_squeak.ogg',\
		"sound/voice/animal/squawk1.ogg" = 'sound/voice/animal/squawk1.ogg',\
		"sound/voice/animal/squawk2.ogg" = 'sound/voice/animal/squawk2.ogg',\
		"sound/voice/animal/squawk3.ogg" = 'sound/voice/animal/squawk3.ogg',\
		"sound/voice/animal/turkey.ogg" = 'sound/voice/animal/turkey.ogg',\
		"sound/voice/animal/werewolf_attack1.ogg" = 'sound/voice/animal/werewolf_attack1.ogg',\
		"sound/voice/animal/werewolf_attack2.ogg" = 'sound/voice/animal/werewolf_attack2.ogg',\
		"sound/voice/animal/werewolf_attack3.ogg" = 'sound/voice/animal/werewolf_attack3.ogg',\
		"sound/voice/animal/werewolf_howl.ogg" = 'sound/voice/animal/werewolf_howl.ogg',\
		"sound/voice/animal/woodcock.ogg" = 'sound/voice/animal/woodcock.ogg',\
		"sound/voice/animal/YetiGrowl.ogg" = 'sound/voice/animal/YetiGrowl.ogg',\
		"sound/voice/babynoise.ogg" = 'sound/voice/babynoise.ogg',\
		"sound/voice/bcreep.ogg" = 'sound/voice/bcreep.ogg',\
		"sound/voice/bcriminal.ogg" = 'sound/voice/bcriminal.ogg',\
		"sound/voice/bfreeze.ogg" = 'sound/voice/bfreeze.ogg',\
		"sound/voice/bgod.ogg" = 'sound/voice/bgod.ogg',\
		"sound/voice/biamthelaw.ogg" = 'sound/voice/biamthelaw.ogg',\
		"sound/voice/binsultbeep.ogg" = 'sound/voice/binsultbeep.ogg',\
		"sound/voice/bjustice.ogg" = 'sound/voice/bjustice.ogg',\
		"sound/voice/blob/blobattack.ogg" = 'sound/voice/blob/blobattack.ogg',\
		"sound/voice/blob/blobconsume1.ogg" = 'sound/voice/blob/blobconsume1.ogg',\
		"sound/voice/blob/blobconsume2.ogg" = 'sound/voice/blob/blobconsume2.ogg',\
		"sound/voice/blob/blobdamaged1.ogg" = 'sound/voice/blob/blobdamaged1.ogg',\
		"sound/voice/blob/blobdamaged2.ogg" = 'sound/voice/blob/blobdamaged2.ogg',\
		"sound/voice/blob/blobdamaged3.ogg" = 'sound/voice/blob/blobdamaged3.ogg',\
		"sound/voice/blob/blobdamaged4.ogg" = 'sound/voice/blob/blobdamaged4.ogg',\
		"sound/voice/blob/blobdeath.ogg" = 'sound/voice/blob/blobdeath.ogg',\
		"sound/voice/blob/blobdeploy.ogg" = 'sound/voice/blob/blobdeploy.ogg',\
		"sound/voice/blob/blobheal1.ogg" = 'sound/voice/blob/blobheal1.ogg',\
		"sound/voice/blob/blobheal2.ogg" = 'sound/voice/blob/blobheal2.ogg',\
		"sound/voice/blob/blobheal3.ogg" = 'sound/voice/blob/blobheal3.ogg',\
		"sound/voice/blob/blobhit.ogg" = 'sound/voice/blob/blobhit.ogg',\
		"sound/voice/blob/blobplace1.ogg" = 'sound/voice/blob/blobplace1.ogg',\
		"sound/voice/blob/blobplace2.ogg" = 'sound/voice/blob/blobplace2.ogg',\
		"sound/voice/blob/blobplace3.ogg" = 'sound/voice/blob/blobplace3.ogg',\
		"sound/voice/blob/blobplace4.ogg" = 'sound/voice/blob/blobplace4.ogg',\
		"sound/voice/blob/blobplace5.ogg" = 'sound/voice/blob/blobplace5.ogg',\
		"sound/voice/blob/blobplace6.ogg" = 'sound/voice/blob/blobplace6.ogg',\
		"sound/voice/blob/blobreflect1.ogg" = 'sound/voice/blob/blobreflect1.ogg',\
		"sound/voice/blob/blobreflect2.ogg" = 'sound/voice/blob/blobreflect2.ogg',\
		"sound/voice/blob/blobreflect3.ogg" = 'sound/voice/blob/blobreflect3.ogg',\
		"sound/voice/blob/blobreflect4.ogg" = 'sound/voice/blob/blobreflect4.ogg',\
		"sound/voice/blob/blobreflect5.ogg" = 'sound/voice/blob/blobreflect5.ogg',\
		"sound/voice/blob/blobreinforce1.ogg" = 'sound/voice/blob/blobreinforce1.ogg',\
		"sound/voice/blob/blobreinforce2.ogg" = 'sound/voice/blob/blobreinforce2.ogg',\
		"sound/voice/blob/blobshoot.ogg" = 'sound/voice/blob/blobshoot.ogg',\
		"sound/voice/blob/blobspread1.ogg" = 'sound/voice/blob/blobspread1.ogg',\
		"sound/voice/blob/blobspread2.ogg" = 'sound/voice/blob/blobspread2.ogg',\
		"sound/voice/blob/blobspread3.ogg" = 'sound/voice/blob/blobspread3.ogg',\
		"sound/voice/blob/blobspread4.ogg" = 'sound/voice/blob/blobspread4.ogg',\
		"sound/voice/blob/blobspread5.ogg" = 'sound/voice/blob/blobspread5.ogg',\
		"sound/voice/blob/blobspread6.ogg" = 'sound/voice/blob/blobspread6.ogg',\
		"sound/voice/blob/blobsucc1.ogg" = 'sound/voice/blob/blobsucc1.ogg',\
		"sound/voice/blob/blobsucc2.ogg" = 'sound/voice/blob/blobsucc2.ogg',\
		"sound/voice/blob/blobsucc3.ogg" = 'sound/voice/blob/blobsucc3.ogg',\
		"sound/voice/blob/blobsucced.ogg" = 'sound/voice/blob/blobsucced.ogg',\
		"sound/voice/blob/blobup1.ogg" = 'sound/voice/blob/blobup1.ogg',\
		"sound/voice/blob/blobup2.ogg" = 'sound/voice/blob/blobup2.ogg',\
		"sound/voice/blob/blobup3.ogg" = 'sound/voice/blob/blobup3.ogg',\
		"sound/voice/bradio.ogg" = 'sound/voice/bradio.ogg',\
		"sound/voice/bsecureday.ogg" = 'sound/voice/bsecureday.ogg',\
		"sound/voice/burp.ogg" = 'sound/voice/burp.ogg',\
		"sound/voice/burp_2.ogg" = 'sound/voice/burp_2.ogg',\
		"sound/voice/burp_alien.ogg" = 'sound/voice/burp_alien.ogg',\
		"sound/voice/chanting.ogg" = 'sound/voice/chanting.ogg',\
		"sound/voice/cluwnelaugh1.ogg" = 'sound/voice/cluwnelaugh1.ogg',\
		"sound/voice/cluwnelaugh2.ogg" = 'sound/voice/cluwnelaugh2.ogg',\
		"sound/voice/cluwnelaugh3.ogg" = 'sound/voice/cluwnelaugh3.ogg',\
		"sound/voice/creepyshriek.ogg" = 'sound/voice/creepyshriek.ogg',\
		"sound/voice/creepywhisper_1.ogg" = 'sound/voice/creepywhisper_1.ogg',\
		"sound/voice/creepywhisper_2.ogg" = 'sound/voice/creepywhisper_2.ogg',\
		"sound/voice/creepywhisper_3.ogg" = 'sound/voice/creepywhisper_3.ogg',\
		"sound/voice/death_1.ogg" = 'sound/voice/death_1.ogg',\
		"sound/voice/death_2.ogg" = 'sound/voice/death_2.ogg',\
		"sound/voice/farts/diarrhea.ogg" = 'sound/voice/farts/diarrhea.ogg',\
		"sound/voice/farts/fart1.ogg" = 'sound/voice/farts/fart1.ogg',\
		"sound/voice/farts/fart2.ogg" = 'sound/voice/farts/fart2.ogg',\
		"sound/voice/farts/fart3.ogg" = 'sound/voice/farts/fart3.ogg',\
		"sound/voice/farts/fart4.ogg" = 'sound/voice/farts/fart4.ogg',\
		"sound/voice/farts/fart5.ogg" = 'sound/voice/farts/fart5.ogg',\
		"sound/voice/farts/fart6.ogg" = 'sound/voice/farts/fart6.ogg',\
		"sound/voice/farts/fart7.ogg" = 'sound/voice/farts/fart7.ogg',\
		"sound/voice/farts/frogfart.ogg" = 'sound/voice/farts/frogfart.ogg',\
		"sound/voice/farts/poo.ogg" = 'sound/voice/farts/poo.ogg',\
		"sound/voice/farts/poo2.ogg" = 'sound/voice/farts/poo2.ogg',\
		"sound/voice/farts/poo2_robot.ogg" = 'sound/voice/farts/poo2_robot.ogg',\
		"sound/voice/farts/superfart.ogg" = 'sound/voice/farts/superfart.ogg',\
		"sound/voice/femvox.ogg" = 'sound/voice/femvox.ogg',\
		"sound/voice/gasps/female_gasp_1.ogg" = 'sound/voice/gasps/female_gasp_1.ogg',\
		"sound/voice/gasps/female_gasp_2.ogg" = 'sound/voice/gasps/female_gasp_2.ogg',\
		"sound/voice/gasps/female_gasp_3.ogg" = 'sound/voice/gasps/female_gasp_3.ogg',\
		"sound/voice/gasps/female_gasp_4.ogg" = 'sound/voice/gasps/female_gasp_4.ogg',\
		"sound/voice/gasps/female_gasp_5.ogg" = 'sound/voice/gasps/female_gasp_5.ogg',\
		"sound/voice/gasps/gasp.ogg" = 'sound/voice/gasps/gasp.ogg',\
		"sound/voice/gasps/male_gasp_1.ogg" = 'sound/voice/gasps/male_gasp_1.ogg',\
		"sound/voice/gasps/male_gasp_2.ogg" = 'sound/voice/gasps/male_gasp_2.ogg',\
		"sound/voice/gasps/male_gasp_3.ogg" = 'sound/voice/gasps/male_gasp_3.ogg',\
		"sound/voice/gasps/male_gasp_4.ogg" = 'sound/voice/gasps/male_gasp_4.ogg',\
		"sound/voice/gasps/male_gasp_5.ogg" = 'sound/voice/gasps/male_gasp_5.ogg',\
		"sound/voice/guard_halt.ogg" = 'sound/voice/guard_halt.ogg',\
		"sound/voice/hagg_vorbis.ogg" = 'sound/voice/hagg_vorbis.ogg',\
		"sound/voice/heavenly.ogg" = 'sound/voice/heavenly.ogg',\
		"sound/voice/heavenly3.ogg" = 'sound/voice/heavenly3.ogg',\
		"sound/voice/hogg_vorbis.ogg" = 'sound/voice/hogg_vorbis.ogg',\
		"sound/voice/hogg_vorbis_screams.ogg" = 'sound/voice/hogg_vorbis_screams.ogg',\
		"sound/voice/hogg_vorbis_the.ogg" = 'sound/voice/hogg_vorbis_the.ogg',\
		"sound/voice/hogg_with_scream.ogg" = 'sound/voice/hogg_with_scream.ogg',\
		"sound/voice/hoooagh.ogg" = 'sound/voice/hoooagh.ogg',\
		"sound/voice/hoooagh2.ogg" = 'sound/voice/hoooagh2.ogg',\
		"sound/voice/horse.ogg" = 'sound/voice/horse.ogg',\
		"sound/voice/jeans/1.ogg" = 'sound/voice/jeans/1.ogg',\
		"sound/voice/jeans/2.ogg" = 'sound/voice/jeans/2.ogg',\
		"sound/voice/jeans/3.ogg" = 'sound/voice/jeans/3.ogg',\
		"sound/voice/jeans/4.ogg" = 'sound/voice/jeans/4.ogg',\
		"sound/voice/jeans/5.ogg" = 'sound/voice/jeans/5.ogg',\
		"sound/voice/killme.ogg" = 'sound/voice/killme.ogg',\
		"sound/voice/macho/macho_alert13.ogg" = 'sound/voice/macho/macho_alert13.ogg',\
		"sound/voice/macho/macho_alert16.ogg" = 'sound/voice/macho/macho_alert16.ogg',\
		"sound/voice/macho/macho_alert22.ogg" = 'sound/voice/macho/macho_alert22.ogg',\
		"sound/voice/macho/macho_alert24.ogg" = 'sound/voice/macho/macho_alert24.ogg',\
		"sound/voice/macho/macho_alert26.ogg" = 'sound/voice/macho/macho_alert26.ogg',\
		"sound/voice/macho/macho_alert41.ogg" = 'sound/voice/macho/macho_alert41.ogg',\
		"sound/voice/macho/macho_become_alert54.ogg" = 'sound/voice/macho/macho_become_alert54.ogg',\
		"sound/voice/macho/macho_become_alert55.ogg" = 'sound/voice/macho/macho_become_alert55.ogg',\
		"sound/voice/macho/macho_become_alert56.ogg" = 'sound/voice/macho/macho_become_alert56.ogg',\
		"sound/voice/macho/macho_become_enraged01.ogg" = 'sound/voice/macho/macho_become_enraged01.ogg',\
		"sound/voice/macho/macho_breathing01.ogg" = 'sound/voice/macho/macho_breathing01.ogg',\
		"sound/voice/macho/macho_breathing02.ogg" = 'sound/voice/macho/macho_breathing02.ogg',\
		"sound/voice/macho/macho_breathing13.ogg" = 'sound/voice/macho/macho_breathing13.ogg',\
		"sound/voice/macho/macho_breathing18.ogg" = 'sound/voice/macho/macho_breathing18.ogg',\
		"sound/voice/macho/macho_breathing26.ogg" = 'sound/voice/macho/macho_breathing26.ogg',\
		"sound/voice/macho/macho_cuppacoffee1.ogg" = 'sound/voice/macho/macho_cuppacoffee1.ogg',\
		"sound/voice/macho/macho_cuppacoffee2.ogg" = 'sound/voice/macho/macho_cuppacoffee2.ogg',\
		"sound/voice/macho/macho_cuppacoffee3.ogg" = 'sound/voice/macho/macho_cuppacoffee3.ogg',\
		"sound/voice/macho/macho_freakout.ogg" = 'sound/voice/macho/macho_freakout.ogg',\
		"sound/voice/macho/macho_idle_breath_01.ogg" = 'sound/voice/macho/macho_idle_breath_01.ogg',\
		"sound/voice/macho/macho_idle_breath_02.ogg" = 'sound/voice/macho/macho_idle_breath_02.ogg',\
		"sound/voice/macho/macho_idle_breath_04.ogg" = 'sound/voice/macho/macho_idle_breath_04.ogg',\
		"sound/voice/macho/macho_idle_breath_06.ogg" = 'sound/voice/macho/macho_idle_breath_06.ogg',\
		"sound/voice/macho/macho_moan03.ogg" = 'sound/voice/macho/macho_moan03.ogg',\
		"sound/voice/macho/macho_moan07.ogg" = 'sound/voice/macho/macho_moan07.ogg',\
		"sound/voice/macho/macho_mumbling04.ogg" = 'sound/voice/macho/macho_mumbling04.ogg',\
		"sound/voice/macho/macho_mumbling05.ogg" = 'sound/voice/macho/macho_mumbling05.ogg',\
		"sound/voice/macho/macho_mumbling07.ogg" = 'sound/voice/macho/macho_mumbling07.ogg',\
		"sound/voice/macho/macho_mumbling08.ogg" = 'sound/voice/macho/macho_mumbling08.ogg',\
		"sound/voice/macho/macho_rage_54.ogg" = 'sound/voice/macho/macho_rage_54.ogg',\
		"sound/voice/macho/macho_rage_55.ogg" = 'sound/voice/macho/macho_rage_55.ogg',\
		"sound/voice/macho/macho_rage_58.ogg" = 'sound/voice/macho/macho_rage_58.ogg',\
		"sound/voice/macho/macho_rage_61.ogg" = 'sound/voice/macho/macho_rage_61.ogg',\
		"sound/voice/macho/macho_rage_64.ogg" = 'sound/voice/macho/macho_rage_64.ogg',\
		"sound/voice/macho/macho_rage_68.ogg" = 'sound/voice/macho/macho_rage_68.ogg',\
		"sound/voice/macho/macho_rage_71.ogg" = 'sound/voice/macho/macho_rage_71.ogg',\
		"sound/voice/macho/macho_rage_72.ogg" = 'sound/voice/macho/macho_rage_72.ogg',\
		"sound/voice/macho/macho_rage_73.ogg" = 'sound/voice/macho/macho_rage_73.ogg',\
		"sound/voice/macho/macho_rage_78.ogg" = 'sound/voice/macho/macho_rage_78.ogg',\
		"sound/voice/macho/macho_rage_79.ogg" = 'sound/voice/macho/macho_rage_79.ogg',\
		"sound/voice/macho/macho_rage_80.ogg" = 'sound/voice/macho/macho_rage_80.ogg',\
		"sound/voice/macho/macho_rage_81.ogg" = 'sound/voice/macho/macho_rage_81.ogg',\
		"sound/voice/macho/macho_rage30.ogg" = 'sound/voice/macho/macho_rage30.ogg',\
		"sound/voice/macho/macho_sarcasm.ogg" = 'sound/voice/macho/macho_sarcasm.ogg',\
		"sound/voice/macho/macho_shout04.ogg" = 'sound/voice/macho/macho_shout04.ogg',\
		"sound/voice/macho/macho_shout06.ogg" = 'sound/voice/macho/macho_shout06.ogg',\
		"sound/voice/macho/macho_shout07.ogg" = 'sound/voice/macho/macho_shout07.ogg',\
		"sound/voice/macho/macho_shout08.ogg" = 'sound/voice/macho/macho_shout08.ogg',\
		"sound/voice/macho/macho_slimjim.ogg" = 'sound/voice/macho/macho_slimjim.ogg',\
		"sound/voice/MEbewarecoward.ogg" = 'sound/voice/MEbewarecoward.ogg',\
		"sound/voice/mechmonstrositylaugh.ogg" = 'sound/voice/mechmonstrositylaugh.ogg',\
		"sound/voice/MEhunger.ogg" = 'sound/voice/MEhunger.ogg',\
		"sound/voice/MEilive.ogg" = 'sound/voice/MEilive.ogg',\
		"sound/voice/MEraaargh.ogg" = 'sound/voice/MEraaargh.ogg',\
		"sound/voice/MEruncoward.ogg" = 'sound/voice/MEruncoward.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-clearsthroat.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-clearsthroat.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Commander_Dies-1.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Commander_Dies-1.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Commander_Dies-2.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Commander_Dies-2.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Crit_System_Destroyed-1.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Crit_System_Destroyed-1.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Crit_System_Destroyed-2.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Crit_System_Destroyed-2.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Lose-1.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Lose-1.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Lose-2.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Lose-2.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Lose-3.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Lose-3.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Lose-4.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Lose-4.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-losing1.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-losing1.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-losing2.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-losing2.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-losing3.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-losing3.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_CHUCKS-1.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_CHUCKS-1.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_CHUCKS-2.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_CHUCKS-2.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_CHUCKS-3.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_CHUCKS-3.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_FORTUNA-1.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_FORTUNA-1.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_FORTUNA-2.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_FORTUNA-2.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_FORTUNA-3.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_FORTUNA-3.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_RELIANT-1.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_RELIANT-1.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_RELIANT-2.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_RELIANT-2.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_RELIANT-3.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_RELIANT-3.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_UVB67-1.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Objective_Lost_UVB67-1.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Objective_Secured-1.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Objective_Secured-1.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Objective_Secured-2.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Objective_Secured-2.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Objective_Secured-3.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Objective_Secured-3.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Roundstart-1.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Roundstart-1.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Roundstart-2.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Roundstart-2.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Win-1.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Win-1.ogg',\
		"sound/voice/pod_wars_voices/NanoTrasen-Win-2.ogg" = 'sound/voice/pod_wars_voices/NanoTrasen-Win-2.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Commander_Dies-1.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Commander_Dies-1.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Crit_System_Destroyed-1.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Crit_System_Destroyed-1.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Lose-1.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Lose-1.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Lose-2.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Lose-2.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Objective_Lost_CHUCKS-1.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Objective_Lost_CHUCKS-1.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Objective_Lost_CHUCKS-2.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Objective_Lost_CHUCKS-2.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Objective_Lost_FORTUNA-1.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Objective_Lost_FORTUNA-1.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Objective_Lost_FORTUNA-2.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Objective_Lost_FORTUNA-2.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Objective_Lost_RELIANT-1.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Objective_Lost_RELIANT-1.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Objective_Lost_RELIANT-2.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Objective_Lost_RELIANT-2.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Objective_Lost_UVB67-1.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Objective_Lost_UVB67-1.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Objective_Lost_UVB67-2.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Objective_Lost_UVB67-2.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Objective_Secured-1.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Objective_Secured-1.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Objective_Secured-2.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Objective_Secured-2.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Roundstart-1.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Roundstart-1.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Win-1.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Win-1.ogg',\
		"sound/voice/pod_wars_voices/Syndicate-Win-2.ogg" = 'sound/voice/pod_wars_voices/Syndicate-Win-2.ogg',\
		"sound/voice/pug_sneeze.ogg" = 'sound/voice/pug_sneeze.ogg',\
		"sound/voice/pug_sniff.ogg" = 'sound/voice/pug_sniff.ogg',\
		"sound/voice/pug_wheeze.ogg" = 'sound/voice/pug_wheeze.ogg',\
		"sound/voice/Sad_Robot.ogg" = 'sound/voice/Sad_Robot.ogg',\
		"sound/voice/screams/chicken_bawk.ogg" = 'sound/voice/screams/chicken_bawk.ogg',\
		"sound/voice/screams/female_scream.ogg" = 'sound/voice/screams/female_scream.ogg',\
		"sound/voice/screams/fescream1.ogg" = 'sound/voice/screams/fescream1.ogg',\
		"sound/voice/screams/fescream2.ogg" = 'sound/voice/screams/fescream2.ogg',\
		"sound/voice/screams/fescream3.ogg" = 'sound/voice/screams/fescream3.ogg',\
		"sound/voice/screams/fescream4.ogg" = 'sound/voice/screams/fescream4.ogg',\
		"sound/voice/screams/fescream5.ogg" = 'sound/voice/screams/fescream5.ogg',\
		"sound/voice/screams/frogscream1.ogg" = 'sound/voice/screams/frogscream1.ogg',\
		"sound/voice/screams/frogscream3.ogg" = 'sound/voice/screams/frogscream3.ogg',\
		"sound/voice/screams/frogscream4.ogg" = 'sound/voice/screams/frogscream4.ogg',\
		"sound/voice/screams/male_scream.ogg" = 'sound/voice/screams/male_scream.ogg',\
		"sound/voice/screams/martian_growl.ogg" = 'sound/voice/screams/martian_growl.ogg',\
		"sound/voice/screams/martian_screech.ogg" = 'sound/voice/screams/martian_screech.ogg',\
		"sound/voice/screams/mascream1.ogg" = 'sound/voice/screams/mascream1.ogg',\
		"sound/voice/screams/mascream2.ogg" = 'sound/voice/screams/mascream2.ogg',\
		"sound/voice/screams/mascream3.ogg" = 'sound/voice/screams/mascream3.ogg',\
		"sound/voice/screams/mascream4.ogg" = 'sound/voice/screams/mascream4.ogg',\
		"sound/voice/screams/mascream5.ogg" = 'sound/voice/screams/mascream5.ogg',\
		"sound/voice/screams/mascream6.ogg" = 'sound/voice/screams/mascream6.ogg',\
		"sound/voice/screams/mascream7.ogg" = 'sound/voice/screams/mascream7.ogg',\
		"sound/voice/screams/monkey_scream.ogg" = 'sound/voice/screams/monkey_scream.ogg',\
		"sound/voice/screams/moo.ogg" = 'sound/voice/screams/moo.ogg',\
		"sound/voice/screams/Psychic_Scream_1.ogg" = 'sound/voice/screams/Psychic_Scream_1.ogg',\
		"sound/voice/screams/pug.ogg" = 'sound/voice/screams/pug.ogg',\
		"sound/voice/screams/pugg.ogg" = 'sound/voice/screams/pugg.ogg',\
		"sound/voice/screams/robot_scream.ogg" = 'sound/voice/screams/robot_scream.ogg',\
		"sound/voice/screams/Robot_Scream_2.ogg" = 'sound/voice/screams/Robot_Scream_2.ogg',\
		"sound/voice/screams/sillyscream1.ogg" = 'sound/voice/screams/sillyscream1.ogg',\
		"sound/voice/screams/sillyscream2.ogg" = 'sound/voice/screams/sillyscream2.ogg',\
		"sound/voice/screams/sillyscream3.ogg" = 'sound/voice/screams/sillyscream3.ogg',\
		"sound/voice/snore.ogg" = 'sound/voice/snore.ogg',\
		"sound/voice/tommy_did-not-hit-hehr.ogg" = 'sound/voice/tommy_did-not-hit-hehr.ogg',\
		"sound/voice/tommy_hahahah.ogg" = 'sound/voice/tommy_hahahah.ogg',\
		"sound/voice/tommy_hahahaha.ogg" = 'sound/voice/tommy_hahahaha.ogg',\
		"sound/voice/tommy_hauh.ogg" = 'sound/voice/tommy_hauh.ogg',\
		"sound/voice/tommy_hey-everybody.ogg" = 'sound/voice/tommy_hey-everybody.ogg',\
		"sound/voice/tommy_weird-chicken-noise.ogg" = 'sound/voice/tommy_weird-chicken-noise.ogg',\
		"sound/voice/tommy_you-are-tearing-me-apart-lisauh.ogg" = 'sound/voice/tommy_you-are-tearing-me-apart-lisauh.ogg',\
		"sound/voice/uguu.ogg" = 'sound/voice/uguu.ogg',\
		"sound/voice/urf.ogg" = 'sound/voice/urf.ogg',\
		"sound/voice/virtual_gassy.ogg" = 'sound/voice/virtual_gassy.ogg',\
		"sound/voice/virtual_scream.ogg" = 'sound/voice/virtual_scream.ogg',\
		"sound/voice/virtual_snap.ogg" = 'sound/voice/virtual_snap.ogg',\
		"sound/voice/wizard/AnimateDeadFem.ogg" = 'sound/voice/wizard/AnimateDeadFem.ogg',\
		"sound/voice/wizard/AnimateDeadGrim.ogg" = 'sound/voice/wizard/AnimateDeadGrim.ogg',\
		"sound/voice/wizard/AnimateDeadLoud.ogg" = 'sound/voice/wizard/AnimateDeadLoud.ogg',\
		"sound/voice/wizard/BlindFem.ogg" = 'sound/voice/wizard/BlindFem.ogg',\
		"sound/voice/wizard/BlindGrim.ogg" = 'sound/voice/wizard/BlindGrim.ogg',\
		"sound/voice/wizard/BlindLoud.ogg" = 'sound/voice/wizard/BlindLoud.ogg',\
		"sound/voice/wizard/BlinkFem.ogg" = 'sound/voice/wizard/BlinkFem.ogg',\
		"sound/voice/wizard/BlinkGrim.ogg" = 'sound/voice/wizard/BlinkGrim.ogg',\
		"sound/voice/wizard/BlinkLoud.ogg" = 'sound/voice/wizard/BlinkLoud.ogg',\
		"sound/voice/wizard/BullChargeFem.ogg" = 'sound/voice/wizard/BullChargeFem.ogg',\
		"sound/voice/wizard/BullChargeGrim.ogg" = 'sound/voice/wizard/BullChargeGrim.ogg',\
		"sound/voice/wizard/BullChargeLoud.ogg" = 'sound/voice/wizard/BullChargeLoud.ogg',\
		"sound/voice/wizard/ClairvoyanceFem.ogg" = 'sound/voice/wizard/ClairvoyanceFem.ogg',\
		"sound/voice/wizard/ClairvoyanceGrim.ogg" = 'sound/voice/wizard/ClairvoyanceGrim.ogg',\
		"sound/voice/wizard/ClairvoyanceLoud.ogg" = 'sound/voice/wizard/ClairvoyanceLoud.ogg',\
		"sound/voice/wizard/ClownsRevengeFem.ogg" = 'sound/voice/wizard/ClownsRevengeFem.ogg',\
		"sound/voice/wizard/CluwneFem.ogg" = 'sound/voice/wizard/CluwneFem.ogg',\
		"sound/voice/wizard/CluwneGrim.ogg" = 'sound/voice/wizard/CluwneGrim.ogg',\
		"sound/voice/wizard/CluwneLoud.ogg" = 'sound/voice/wizard/CluwneLoud.ogg',\
		"sound/voice/wizard/DopplegangerFem.ogg" = 'sound/voice/wizard/DopplegangerFem.ogg',\
		"sound/voice/wizard/DopplegangerGrim.ogg" = 'sound/voice/wizard/DopplegangerGrim.ogg',\
		"sound/voice/wizard/DopplegangerLoud.ogg" = 'sound/voice/wizard/DopplegangerLoud.ogg',\
		"sound/voice/wizard/EarthquakeFem.ogg" = 'sound/voice/wizard/EarthquakeFem.ogg',\
		"sound/voice/wizard/EarthquakeGrim.ogg" = 'sound/voice/wizard/EarthquakeGrim.ogg',\
		"sound/voice/wizard/EarthquakeLoud.ogg" = 'sound/voice/wizard/EarthquakeLoud.ogg',\
		"sound/voice/wizard/FireballFem.ogg" = 'sound/voice/wizard/FireballFem.ogg',\
		"sound/voice/wizard/FireballGrim.ogg" = 'sound/voice/wizard/FireballGrim.ogg',\
		"sound/voice/wizard/FireballLoud.ogg" = 'sound/voice/wizard/FireballLoud.ogg',\
		"sound/voice/wizard/ForcewallFem.ogg" = 'sound/voice/wizard/ForcewallFem.ogg',\
		"sound/voice/wizard/ForcewallGrim.ogg" = 'sound/voice/wizard/ForcewallGrim.ogg',\
		"sound/voice/wizard/ForcewallLoud.ogg" = 'sound/voice/wizard/ForcewallLoud.ogg',\
		"sound/voice/wizard/FurryFem.ogg" = 'sound/voice/wizard/FurryFem.ogg',\
		"sound/voice/wizard/FurryGrim.ogg" = 'sound/voice/wizard/FurryGrim.ogg',\
		"sound/voice/wizard/FurryLoud.ogg" = 'sound/voice/wizard/FurryLoud.ogg',\
		"sound/voice/wizard/GolemFem.ogg" = 'sound/voice/wizard/GolemFem.ogg',\
		"sound/voice/wizard/GolemGrim.ogg" = 'sound/voice/wizard/GolemGrim.ogg',\
		"sound/voice/wizard/GolemLoud.ogg" = 'sound/voice/wizard/GolemLoud.ogg',\
		"sound/voice/wizard/IceBurstFem.ogg" = 'sound/voice/wizard/IceBurstFem.ogg',\
		"sound/voice/wizard/IceBurstGrim.ogg" = 'sound/voice/wizard/IceBurstGrim.ogg',\
		"sound/voice/wizard/IceBurstLoud.ogg" = 'sound/voice/wizard/IceBurstLoud.ogg',\
		"sound/voice/wizard/KnockFem.ogg" = 'sound/voice/wizard/KnockFem.ogg',\
		"sound/voice/wizard/KnockGrim.ogg" = 'sound/voice/wizard/KnockGrim.ogg',\
		"sound/voice/wizard/KnockLoud.ogg" = 'sound/voice/wizard/KnockLoud.ogg',\
		"sound/voice/wizard/MagicMissileFem.ogg" = 'sound/voice/wizard/MagicMissileFem.ogg',\
		"sound/voice/wizard/MagicMissileGrim.ogg" = 'sound/voice/wizard/MagicMissileGrim.ogg',\
		"sound/voice/wizard/MagicMissileLoud.ogg" = 'sound/voice/wizard/MagicMissileLoud.ogg',\
		"sound/voice/wizard/MagicShieldFem.ogg" = 'sound/voice/wizard/MagicShieldFem.ogg',\
		"sound/voice/wizard/MagicShieldGrim.ogg" = 'sound/voice/wizard/MagicShieldGrim.ogg',\
		"sound/voice/wizard/MagicShieldLoud.ogg" = 'sound/voice/wizard/MagicShieldLoud.ogg',\
		"sound/voice/wizard/MistFormFem.ogg" = 'sound/voice/wizard/MistFormFem.ogg',\
		"sound/voice/wizard/MistFormGrim.ogg" = 'sound/voice/wizard/MistFormGrim.ogg',\
		"sound/voice/wizard/MistFormLoud.ogg" = 'sound/voice/wizard/MistFormLoud.ogg',\
		"sound/voice/wizard/MutateFem.ogg" = 'sound/voice/wizard/MutateFem.ogg',\
		"sound/voice/wizard/MutateGrim.ogg" = 'sound/voice/wizard/MutateGrim.ogg',\
		"sound/voice/wizard/MutateLoud.ogg" = 'sound/voice/wizard/MutateLoud.ogg',\
		"sound/voice/wizard/PandemoniumFem.ogg" = 'sound/voice/wizard/PandemoniumFem.ogg',\
		"sound/voice/wizard/PandemoniumGrim.ogg" = 'sound/voice/wizard/PandemoniumGrim.ogg',\
		"sound/voice/wizard/PandemoniumLoud.ogg" = 'sound/voice/wizard/PandemoniumLoud.ogg',\
		"sound/voice/wizard/RathensSecretFem.ogg" = 'sound/voice/wizard/RathensSecretFem.ogg',\
		"sound/voice/wizard/RathensSecretGrim.ogg" = 'sound/voice/wizard/RathensSecretGrim.ogg',\
		"sound/voice/wizard/RathensSecretLoud.ogg" = 'sound/voice/wizard/RathensSecretLoud.ogg',\
		"sound/voice/wizard/ShockingGraspFem.ogg" = 'sound/voice/wizard/ShockingGraspFem.ogg',\
		"sound/voice/wizard/ShockingGraspGrim.ogg" = 'sound/voice/wizard/ShockingGraspGrim.ogg',\
		"sound/voice/wizard/ShockingGraspLoud.ogg" = 'sound/voice/wizard/ShockingGraspLoud.ogg',\
		"sound/voice/wizard/StaffFem.ogg" = 'sound/voice/wizard/StaffFem.ogg',\
		"sound/voice/wizard/StaffGrim.ogg" = 'sound/voice/wizard/StaffGrim.ogg',\
		"sound/voice/wizard/TeleportFem.ogg" = 'sound/voice/wizard/TeleportFem.ogg',\
		"sound/voice/wizard/TeleportGrim.ogg" = 'sound/voice/wizard/TeleportGrim.ogg',\
		"sound/voice/wizard/TeleportLoud.ogg" = 'sound/voice/wizard/TeleportLoud.ogg',\
		"sound/voice/wizard/WarpFem.ogg" = 'sound/voice/wizard/WarpFem.ogg',\
		"sound/voice/wizard/WarpGrim.ogg" = 'sound/voice/wizard/WarpGrim.ogg',\
		"sound/voice/wizard/WarpLoud.ogg" = 'sound/voice/wizard/WarpLoud.ogg',\
		"sound/voice/wraith/ghostrespawn.ogg" = 'sound/voice/wraith/ghostrespawn.ogg',\
		"sound/voice/wraith/reventer.ogg" = 'sound/voice/wraith/reventer.ogg',\
		"sound/voice/wraith/revfocus.ogg" = 'sound/voice/wraith/revfocus.ogg',\
		"sound/voice/wraith/revleave.ogg" = 'sound/voice/wraith/revleave.ogg',\
		"sound/voice/wraith/revpush1.ogg" = 'sound/voice/wraith/revpush1.ogg',\
		"sound/voice/wraith/revpush2.ogg" = 'sound/voice/wraith/revpush2.ogg',\
		"sound/voice/wraith/revshock.ogg" = 'sound/voice/wraith/revshock.ogg',\
		"sound/voice/wraith/revtouch.ogg" = 'sound/voice/wraith/revtouch.ogg',\
		"sound/voice/wraith/wraithhaunt.ogg" = 'sound/voice/wraith/wraithhaunt.ogg',\
		"sound/voice/wraith/wraithleaveobject.ogg" = 'sound/voice/wraith/wraithleaveobject.ogg',\
		"sound/voice/wraith/wraithlivingobject.ogg" = 'sound/voice/wraith/wraithlivingobject.ogg',\
		"sound/voice/wraith/wraithportal.ogg" = 'sound/voice/wraith/wraithportal.ogg',\
		"sound/voice/wraith/wraithpossesobject.ogg" = 'sound/voice/wraith/wraithpossesobject.ogg',\
		"sound/voice/wraith/wraithraise1.ogg" = 'sound/voice/wraith/wraithraise1.ogg',\
		"sound/voice/wraith/wraithraise2.ogg" = 'sound/voice/wraith/wraithraise2.ogg',\
		"sound/voice/wraith/wraithraise3.ogg" = 'sound/voice/wraith/wraithraise3.ogg',\
		"sound/voice/wraith/wraithsoulsucc1.ogg" = 'sound/voice/wraith/wraithsoulsucc1.ogg',\
		"sound/voice/wraith/wraithsoulsucc2.ogg" = 'sound/voice/wraith/wraithsoulsucc2.ogg',\
		"sound/voice/wraith/wraithspook1.ogg" = 'sound/voice/wraith/wraithspook1.ogg',\
		"sound/voice/wraith/wraithspook2.ogg" = 'sound/voice/wraith/wraithspook2.ogg',\
		"sound/voice/wraith/wraithstaminadrain.ogg" = 'sound/voice/wraith/wraithstaminadrain.ogg',\
		"sound/voice/wraith/wraithwhisper1.ogg" = 'sound/voice/wraith/wraithwhisper1.ogg',\
		"sound/voice/wraith/wraithwhisper2.ogg" = 'sound/voice/wraith/wraithwhisper2.ogg',\
		"sound/voice/wraith/wraithwhisper3.ogg" = 'sound/voice/wraith/wraithwhisper3.ogg',\
		"sound/voice/wraith/wraithwhisper4.ogg" = 'sound/voice/wraith/wraithwhisper4.ogg',\
		"sound/voice/yayyy.ogg" = 'sound/voice/yayyy.ogg',\
		"sound/voice/yeaaahhh.ogg" = 'sound/voice/yeaaahhh.ogg',\
		"sound/voice/Zgroan1.ogg" = 'sound/voice/Zgroan1.ogg',\
		"sound/voice/Zgroan2.ogg" = 'sound/voice/Zgroan2.ogg',\
		"sound/voice/Zgroan3.ogg" = 'sound/voice/Zgroan3.ogg',\
		"sound/voice/Zgroan4.ogg" = 'sound/voice/Zgroan4.ogg',\
		"sound/weapons/20mm.ogg" = 'sound/weapons/20mm.ogg',\
		"sound/weapons/9x19NATO.ogg" = 'sound/weapons/9x19NATO.ogg',\
		"sound/weapons/ACgun1.ogg" = 'sound/weapons/ACgun1.ogg',\
		"sound/weapons/ACgun2.ogg" = 'sound/weapons/ACgun2.ogg',\
		"sound/weapons/airzooka.ogg" = 'sound/weapons/airzooka.ogg',\
		"sound/weapons/ak47shot.ogg" = 'sound/weapons/ak47shot.ogg',\
		"sound/weapons/akm.ogg" = 'sound/weapons/akm.ogg',\
		"sound/weapons/armbomb.ogg" = 'sound/weapons/armbomb.ogg',\
		"sound/weapons/assrifle.ogg" = 'sound/weapons/assrifle.ogg',\
		"sound/weapons/blaster_a.ogg" = 'sound/weapons/blaster_a.ogg',\
		"sound/weapons/casing.ogg" = 'sound/weapons/casing.ogg',\
		"sound/weapons/casings/casing-01.ogg" = 'sound/weapons/casings/casing-01.ogg',\
		"sound/weapons/casings/casing-02.ogg" = 'sound/weapons/casings/casing-02.ogg',\
		"sound/weapons/casings/casing-03.ogg" = 'sound/weapons/casings/casing-03.ogg',\
		"sound/weapons/casings/casing-04.ogg" = 'sound/weapons/casings/casing-04.ogg',\
		"sound/weapons/casings/casing-05.ogg" = 'sound/weapons/casings/casing-05.ogg',\
		"sound/weapons/casings/casing-06.ogg" = 'sound/weapons/casings/casing-06.ogg',\
		"sound/weapons/casings/casing-07.ogg" = 'sound/weapons/casings/casing-07.ogg',\
		"sound/weapons/casings/casing-08.ogg" = 'sound/weapons/casings/casing-08.ogg',\
		"sound/weapons/casings/casing-09.ogg" = 'sound/weapons/casings/casing-09.ogg',\
		"sound/weapons/casings/casing-large-01.ogg" = 'sound/weapons/casings/casing-large-01.ogg',\
		"sound/weapons/casings/casing-large-02.ogg" = 'sound/weapons/casings/casing-large-02.ogg',\
		"sound/weapons/casings/casing-large-03.ogg" = 'sound/weapons/casings/casing-large-03.ogg',\
		"sound/weapons/casings/casing-large-04.ogg" = 'sound/weapons/casings/casing-large-04.ogg',\
		"sound/weapons/casings/casing-shell-01.ogg" = 'sound/weapons/casings/casing-shell-01.ogg',\
		"sound/weapons/casings/casing-shell-02.ogg" = 'sound/weapons/casings/casing-shell-02.ogg',\
		"sound/weapons/casings/casing-shell-03.ogg" = 'sound/weapons/casings/casing-shell-03.ogg',\
		"sound/weapons/casings/casing-shell-04.ogg" = 'sound/weapons/casings/casing-shell-04.ogg',\
		"sound/weapons/casings/casing-shell-05.ogg" = 'sound/weapons/casings/casing-shell-05.ogg',\
		"sound/weapons/casings/casing-shell-06.ogg" = 'sound/weapons/casings/casing-shell-06.ogg',\
		"sound/weapons/casings/casing-shell-07.ogg" = 'sound/weapons/casings/casing-shell-07.ogg',\
		"sound/weapons/casings/casing-small-01.ogg" = 'sound/weapons/casings/casing-small-01.ogg',\
		"sound/weapons/casings/casing-small-02.ogg" = 'sound/weapons/casings/casing-small-02.ogg',\
		"sound/weapons/casings/casing-small-03.ogg" = 'sound/weapons/casings/casing-small-03.ogg',\
		"sound/weapons/casings/casing-small-04.ogg" = 'sound/weapons/casings/casing-small-04.ogg',\
		"sound/weapons/casings/casing-small-05.ogg" = 'sound/weapons/casings/casing-small-05.ogg',\
		"sound/weapons/casings/casing-small-06.ogg" = 'sound/weapons/casings/casing-small-06.ogg',\
		"sound/weapons/casings/casing-xl-01.ogg" = 'sound/weapons/casings/casing-xl-01.ogg',\
		"sound/weapons/casings/casing-xl-02.ogg" = 'sound/weapons/casings/casing-xl-02.ogg',\
		"sound/weapons/casings/casing-xl-03.ogg" = 'sound/weapons/casings/casing-xl-03.ogg',\
		"sound/weapons/casings/casing-xl-04.ogg" = 'sound/weapons/casings/casing-xl-04.ogg',\
		"sound/weapons/casings/casing-xl-05.ogg" = 'sound/weapons/casings/casing-xl-05.ogg',\
		"sound/weapons/casings/casing-xl-06.ogg" = 'sound/weapons/casings/casing-xl-06.ogg',\
		"sound/weapons/conc_grenade.ogg" = 'sound/weapons/conc_grenade.ogg',\
		"sound/weapons/cutter.ogg" = 'sound/weapons/cutter.ogg',\
		"sound/weapons/deagle.ogg" = 'sound/weapons/deagle.ogg',\
		"sound/weapons/derringer.ogg" = 'sound/weapons/derringer.ogg',\
		"sound/weapons/DSBFG.ogg" = 'sound/weapons/DSBFG.ogg',\
		"sound/weapons/DSRXPLOD.ogg" = 'sound/weapons/DSRXPLOD.ogg',\
		"sound/weapons/energy/howitzer_firing.ogg" = 'sound/weapons/energy/howitzer_firing.ogg',\
		"sound/weapons/energy/howitzer_impact.ogg" = 'sound/weapons/energy/howitzer_impact.ogg',\
		"sound/weapons/energy/howitzer_shot.ogg" = 'sound/weapons/energy/howitzer_shot.ogg',\
		"sound/weapons/energy/InfernoCannon.ogg" = 'sound/weapons/energy/InfernoCannon.ogg',\
		"sound/weapons/energy/laser_alastor.ogg" = 'sound/weapons/energy/laser_alastor.ogg',\
		"sound/weapons/energy/LightningCannon.ogg" = 'sound/weapons/energy/LightningCannon.ogg',\
		"sound/weapons/energy/LightningCannonImpact.ogg" = 'sound/weapons/energy/LightningCannonImpact.ogg',\
		"sound/weapons/energy/phaser_enormous.ogg" = 'sound/weapons/energy/phaser_enormous.ogg',\
		"sound/weapons/energy/phaser_huge.ogg" = 'sound/weapons/energy/phaser_huge.ogg',\
		"sound/weapons/energy/phaser_tiny.ogg" = 'sound/weapons/energy/phaser_tiny.ogg',\
		"sound/weapons/female_cswordattack1.ogg" = 'sound/weapons/female_cswordattack1.ogg',\
		"sound/weapons/female_cswordattack2.ogg" = 'sound/weapons/female_cswordattack2.ogg',\
		"sound/weapons/female_cswordturnoff.ogg" = 'sound/weapons/female_cswordturnoff.ogg',\
		"sound/weapons/female_cswordturnon.ogg" = 'sound/weapons/female_cswordturnon.ogg',\
		"sound/weapons/female_toyattack.ogg" = 'sound/weapons/female_toyattack.ogg',\
		"sound/weapons/female_toyattack2.ogg" = 'sound/weapons/female_toyattack2.ogg',\
		"sound/weapons/flamethrower.ogg" = 'sound/weapons/flamethrower.ogg',\
		"sound/weapons/flaregun.ogg" = 'sound/weapons/flaregun.ogg',\
		"sound/weapons/flash.ogg" = 'sound/weapons/flash.ogg',\
		"sound/weapons/flashbang.ogg" = 'sound/weapons/flashbang.ogg',\
		"sound/weapons/fleshot.ogg" = 'sound/weapons/fleshot.ogg',\
		"sound/weapons/flintlock.ogg" = 'sound/weapons/flintlock.ogg',\
		"sound/weapons/gauss40mm.ogg" = 'sound/weapons/gauss40mm.ogg',\
		"sound/weapons/grenade.ogg" = 'sound/weapons/grenade.ogg',\
		"sound/weapons/gun_cocked_colt45.ogg" = 'sound/weapons/gun_cocked_colt45.ogg',\
		"sound/weapons/Gunclick.ogg" = 'sound/weapons/Gunclick.ogg',\
		"sound/weapons/gunload_40mm.ogg" = 'sound/weapons/gunload_40mm.ogg',\
		"sound/weapons/gunload_click.ogg" = 'sound/weapons/gunload_click.ogg',\
		"sound/weapons/gunload_heavy.ogg" = 'sound/weapons/gunload_heavy.ogg',\
		"sound/weapons/gunload_hitek.ogg" = 'sound/weapons/gunload_hitek.ogg',\
		"sound/weapons/gunload_light.ogg" = 'sound/weapons/gunload_light.ogg',\
		"sound/weapons/gunload_mprt.ogg" = 'sound/weapons/gunload_mprt.ogg',\
		"sound/weapons/gunload_rigil.ogg" = 'sound/weapons/gunload_rigil.ogg',\
		"sound/weapons/gunload_sawnoff.ogg" = 'sound/weapons/gunload_sawnoff.ogg',\
		"sound/weapons/Gunshot.ogg" = 'sound/weapons/Gunshot.ogg',\
		"sound/weapons/Gunshotold.ogg" = 'sound/weapons/Gunshotold.ogg',\
		"sound/weapons/gyrojet.ogg" = 'sound/weapons/gyrojet.ogg',\
		"sound/weapons/hadar_impact.ogg" = 'sound/weapons/hadar_impact.ogg',\
		"sound/weapons/hadar_pickup.ogg" = 'sound/weapons/hadar_pickup.ogg',\
		"sound/weapons/handcuffs.ogg" = 'sound/weapons/handcuffs.ogg',\
		"sound/weapons/heavyion.ogg" = 'sound/weapons/heavyion.ogg',\
		"sound/weapons/heavyioncharge.ogg" = 'sound/weapons/heavyioncharge.ogg',\
		"sound/weapons/kuvalda.ogg" = 'sound/weapons/kuvalda.ogg',\
		"sound/weapons/kuvaldapump.ogg" = 'sound/weapons/kuvaldapump.ogg',\
		"sound/weapons/Laser.ogg" = 'sound/weapons/Laser.ogg',\
		"sound/weapons/laser_a.ogg" = 'sound/weapons/laser_a.ogg',\
		"sound/weapons/laser_b.ogg" = 'sound/weapons/laser_b.ogg',\
		"sound/weapons/laser_c.ogg" = 'sound/weapons/laser_c.ogg',\
		"sound/weapons/laser_charge.ogg" = 'sound/weapons/laser_charge.ogg',\
		"sound/weapons/laser_d.ogg" = 'sound/weapons/laser_d.ogg',\
		"sound/weapons/laser_e.ogg" = 'sound/weapons/laser_e.ogg',\
		"sound/weapons/laser_f.ogg" = 'sound/weapons/laser_f.ogg',\
		"sound/weapons/laser-burst.ogg" = 'sound/weapons/laser-burst.ogg',\
		"sound/weapons/laserheavy.ogg" = 'sound/weapons/laserheavy.ogg',\
		"sound/weapons/laserlight.ogg" = 'sound/weapons/laserlight.ogg',\
		"sound/weapons/lasermed.ogg" = 'sound/weapons/lasermed.ogg',\
		"sound/weapons/LaserOLD.ogg" = 'sound/weapons/LaserOLD.ogg',\
		"sound/weapons/Laser-orig.ogg" = 'sound/weapons/Laser-orig.ogg',\
		"sound/weapons/lasersound.ogg" = 'sound/weapons/lasersound.ogg',\
		"sound/weapons/laserultra.ogg" = 'sound/weapons/laserultra.ogg',\
		"sound/weapons/launcher.ogg" = 'sound/weapons/launcher.ogg',\
		"sound/weapons/lb_execute.ogg" = 'sound/weapons/lb_execute.ogg',\
		"sound/weapons/male_cswordattack1.ogg" = 'sound/weapons/male_cswordattack1.ogg',\
		"sound/weapons/male_cswordattack2.ogg" = 'sound/weapons/male_cswordattack2.ogg',\
		"sound/weapons/male_cswordturnoff.ogg" = 'sound/weapons/male_cswordturnoff.ogg',\
		"sound/weapons/male_cswordturnon.ogg" = 'sound/weapons/male_cswordturnon.ogg',\
		"sound/weapons/male_toyattack.ogg" = 'sound/weapons/male_toyattack.ogg',\
		"sound/weapons/male_toyattack2.ogg" = 'sound/weapons/male_toyattack2.ogg',\
		"sound/weapons/minigunshot.ogg" = 'sound/weapons/minigunshot.ogg',\
		"sound/weapons/nano-blade-1.ogg" = 'sound/weapons/nano-blade-1.ogg',\
		"sound/weapons/nano-blade-2.ogg" = 'sound/weapons/nano-blade-2.ogg',\
		"sound/weapons/nano-blade-3.ogg" = 'sound/weapons/nano-blade-3.ogg',\
		"sound/weapons/nano-blade-4.ogg" = 'sound/weapons/nano-blade-4.ogg',\
		"sound/weapons/nano-blade-5.ogg" = 'sound/weapons/nano-blade-5.ogg',\
		"sound/weapons/optio.ogg" = 'sound/weapons/optio.ogg',\
		"sound/weapons/pindrop.ogg" = 'sound/weapons/pindrop.ogg',\
		"sound/weapons/plasma_gun.ogg" = 'sound/weapons/plasma_gun.ogg',\
		"sound/weapons/pulse.ogg" = 'sound/weapons/pulse.ogg',\
		"sound/weapons/radxbow.ogg" = 'sound/weapons/radxbow.ogg',\
		"sound/weapons/railgun.ogg" = 'sound/weapons/railgun.ogg',\
		"sound/weapons/railgun_a.ogg" = 'sound/weapons/railgun_a.ogg',\
		"sound/weapons/rev_flash_startup.ogg" = 'sound/weapons/rev_flash_startup.ogg',\
		"sound/weapons/ribbit.ogg" = 'sound/weapons/ribbit.ogg',\
		"sound/weapons/rocket.ogg" = 'sound/weapons/rocket.ogg',\
		"sound/weapons/sawnoff.ogg" = 'sound/weapons/sawnoff.ogg',\
		"sound/weapons/scope.ogg" = 'sound/weapons/scope.ogg',\
		"sound/weapons/shotgunpump.ogg" = 'sound/weapons/shotgunpump.ogg',\
		"sound/weapons/shotgunshot.ogg" = 'sound/weapons/shotgunshot.ogg',\
		"sound/weapons/SigLethal.ogg" = 'sound/weapons/SigLethal.ogg',\
		"sound/weapons/SigTase.ogg" = 'sound/weapons/SigTase.ogg',\
		"sound/weapons/smallcaliber.ogg" = 'sound/weapons/smallcaliber.ogg',\
		"sound/weapons/smartgun.ogg" = 'sound/weapons/smartgun.ogg',\
		"sound/weapons/smg_shot.ogg" = 'sound/weapons/smg_shot.ogg',\
		"sound/weapons/snipershot.ogg" = 'sound/weapons/snipershot.ogg',\
		"sound/weapons/suppressed_22.ogg" = 'sound/weapons/suppressed_22.ogg',\
		"sound/weapons/Taser.ogg" = 'sound/weapons/Taser.ogg',\
		"sound/weapons/TaserOLD.ogg" = 'sound/weapons/TaserOLD.ogg',\
		"sound/weapons/tranq_pistol.ogg" = 'sound/weapons/tranq_pistol.ogg',\
		"sound/weapons/trayhit.ogg" = 'sound/weapons/trayhit.ogg',\
		"sound/weapons/wavegun.ogg" = 'sound/weapons/wavegun.ogg',\

	"NONE" = null)



	global.globalStatusPrototypes = list()
	global.globalStatusInstances = list()


	/// See exclusiveGroup. Buffs above the max will not be applied.
	global.statusGroupLimits = list("Food"=4)



	global.special_places = list() //list of location names, which are coincidentally also landmark ids



	//list creation
	global.clothingbooth_stock = list()
	global.clothingbooth_paths = list()



	global.vpn_ip_checks = list() //assoc list of ip = true or ip = false. if ip = true, thats a vpn ip. if its false, its a normal ip.




	global.miningModifiers = list()



	///All possible biomes in assoc list as type || instance
	global.biomes = list()




	global.blacklist_flora_gen = list(/area/shuttle, /area/mining)




	global.landmarks = list()



	global.job_start_locations = list()



	//The Holy Variable That Is Zoldorf
	global.the_zoldorf = list() //for some reason a global mob was acting strangely, so this list should hypothetically only ever have one zoldorf mob reference in it (the current one)


	global.zoldorf_items_raw
	global.zoldorf_items = list()



	// I don't think every blood decal needed these lists on them, I can't imagine that was nice for performance
	global.blood_decal_low_icon_states = list("drip1a", "drip1b", "drip1c", "drip1d", "drip1e", "drip1f")
	global.blood_decal_med_icon_states = list("drip2a", "drip2b", "drip2c", "drip2d", "drip2e", "drip2f")
	global.blood_decal_high_icon_states = list("drip3a", "drip3b", "drip3c", "drip3d", "drip3e", "drip3f")
	global.blood_decal_max_icon_states = list("drip4a", "drip4b", "drip4c", "drip4d", "drip5a", "drip5b", "drip5c", "drip5d")
	global.blood_decal_violent_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7", "gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")



	global.rollList = list()




	global.generic_gift_paths = list(/obj/item/basketball,
		/obj/item/football,
		/obj/item/clothing/head/cakehat,
		/obj/item/clothing/mask/melons,
		/obj/item/old_grenade/spawner/banana,
		/obj/item/old_grenade/spawner/cheese_sandwich,
		/obj/item/old_grenade/spawner/banana_corndog,
		/obj/item/gimmickbomb/butt,
		/obj/item/instrument/bikehorn,
		/obj/item/instrument/bikehorn/dramatic,
		/obj/item/instrument/bikehorn/airhorn,
		/obj/item/instrument/vuvuzela,
		/obj/item/instrument/bagpipe,
		/obj/item/instrument/harmonica,
		/obj/item/instrument/fiddle,
		/obj/item/instrument/trumpet,
		/obj/item/instrument/whistle,
		/obj/item/instrument/guitar,
		/obj/item/instrument/triangle,
		/obj/item/instrument/tambourine,
		/obj/item/instrument/cowbell,
		/obj/item/horseshoe,
		/obj/item/clothing/glasses/monocle,
		/obj/item/dice/coin,
		/obj/item/dice/magic8ball,
		/obj/item/storage/dicepouch,
		/obj/item/clothing/gloves/fingerless,
		/obj/item/clothing/mask/spiderman,
		/obj/item/clothing/shoes/flippers,
		/obj/item/clothing/gloves/water_wings,
		/obj/item/inner_tube/random,
		/obj/item/clothing/head/waldohat,
		/obj/item/emeter,
		/obj/item/skull,
		/obj/item/pen/crayon/lipstick,
		/obj/item/pen/crayon/rainbow,
		/obj/item/storage/box/crayon,
		/obj/item/device/light/zippo/gold,
		/obj/item/spacecash/random/really_small,
		/obj/item/rubberduck,
		/obj/item/rubber_hammer,
		/obj/item/bang_gun,
		/obj/item/bee_egg_carton,
		/obj/item/brick,
		/obj/item/rubber_chicken,
		/obj/item/clothing/ears/earmuffs,
		/obj/item/clothing/glasses/macho,
		/obj/item/clothing/glasses/noir,
		/obj/item/clothing/glasses/sunglasses/tanning,
		/obj/item/clothing/head/cowboy,
		/obj/item/clothing/head/apprentice,
		/obj/item/clothing/head/crown,
		/obj/item/clothing/head/dramachefhat,
		/obj/item/clothing/head/XComHair,
		/obj/item/clothing/head/snake,
		/obj/item/clothing/head/bigtex,
		/obj/item/clothing/head/aviator,
		/obj/item/clothing/head/pinwheel_hat,
		/obj/item/clothing/head/frog_hat,
		/obj/item/clothing/head/hairbow/flashy,
		/obj/item/clothing/head/helmet/jetson,
		/obj/item/clothing/head/longtophat,
		/obj/item/clothing/suit/bedsheet/cape/royal,
		/obj/item/clothing/mask/moustache,
		/obj/item/clothing/mask/moustache/safe,
		/obj/item/clothing/mask/chicken,
		/obj/item/clothing/gloves/fingerless,
		/obj/item/clothing/gloves/yellow/unsulated,
		/obj/item/clothing/suit/bee,
		/obj/item/clothing/shoes/cowboy,
		/obj/item/clothing/shoes/dress_shoes,
		/obj/item/clothing/shoes/heels/red,
		/obj/item/clothing/shoes/moon,
		/obj/item/clothing/suit/armor/sneaking_suit/costume,
		/obj/item/clothing/suit/hoodie,
		/obj/item/clothing/suit/robuddy,
		/obj/item/clothing/suit/scarf,
		/obj/item/clothing/under/gimmick/rainbow,
		/obj/item/item_box/figure_capsule,
		/obj/item/item_box/assorted/stickers,
		/obj/item/paint_can/rainbow,
		/obj/item/paint_can/rainbow/plaid,
		/obj/item/storage/box/beer,
		/obj/item/storage/box/bacon_kit,
		/obj/item/storage/box/balloonbox,
		/obj/item/storage/box/nerd_kit,
		/obj/item/storage/box/nerd_kit/stationfinder,
		/obj/item/storage/fanny/funny,
		/obj/item/storage/firstaid/regular,
		/obj/item/storage/pill_bottle/cyberpunk,
		/obj/item/toy/sword,
		/obj/item/stg_box,
		/obj/item/clothing/suit/jacket/plastic/random_color)

	global.questionable_generic_gift_paths = list(/obj/item/relic,
		/obj/item/stimpack,
		/obj/item/clothing/mask/cursedclown_hat,
		/obj/item/fireaxe,
		/obj/racing_clowncar/kart,
		/obj/item/old_grenade/moustache,
		/obj/item/clothing/head/oddjob,
		/obj/item/clothing/mask/anime,
		/obj/item/clothing/under/gimmick,
		/obj/item/clothing/suit/armor/sneaking_suit,
		/obj/item/kitchen/everyflavor_box,
		/obj/item/medical/bruise_pack/cyborg,
		/obj/item/medical/ointment/cyborg,
		/obj/item/storage/box/prosthesis_kit/eye_random,
		/obj/item/storage/box/spy_sticker_kit,
		/obj/item/reagent_containers/food/snacks/pizza/xmas,
	#ifndef RP_MODE
		/obj/item/implanter/microbomb,
		/obj/item/old_grenade/light_gimmick,
		/obj/item/gun/energy/bfg,
		/obj/item/engibox/station_locked,
		/obj/item/gun/energy/tommy_gun,
		/obj/item/gun/energy/glitch_gun,
		/obj/item/instrument/trumpet/dootdoot,
		/obj/item/instrument/fiddle/satanic,
		/obj/item/gun/kinetic/beepsky,
		/obj/item/gun/kinetic/gungun,
	#endif
		/obj/item/spacecash/random/small)

	global.xmas_gift_paths = list(/obj/item/clothing/suit/sweater,
		/obj/item/clothing/suit/sweater/red,
		/obj/item/clothing/suit/sweater/green,
		/obj/item/reagent_containers/food/snacks/candy/candy_cane,
		/obj/item/storage/box/cookie_tin,
		/obj/item/storage/box/cookie_tin/sugar)

	global.questionable_xmas_gift_paths = list(/obj/item/reagent_containers/food/snacks/pizza/xmas)


	// rest in peace the_very_holy_global_bible_list_amen (??? - 2020)
	global.bible_contents = list()



	global.last_ghostdrone_build_time = 0
	global.available_ghostdrones = list()
	global.ghostdrone_candidates = list()




	global.portable_machinery = list() // stop looping through world for things you SHITMONGERS




	global.availdisposalpipes = list(
		"Pipe" = 0,
		"Bent Pipe" = 1,
		"Junction" = 2,
		"Flipped Junction" = 3,
		"Y-Junction" = 4,
		"Trunk" = 5,
	)




	global.oven_recipes = list()



	global.mixer_recipes = list()



	//those go UP
	global.zalgo_up = list(
		"&#x030d;", 		"&#x030e;", 		"&#x0304;", 		"&#x0305;",
		"&#x033f;", 		"&#x0311;", 		"&#x0306;", 		"&#x0310;",
		"&#x0352;", 		"&#x0357;", 		"&#x0351;", 		"&#x0307;",
		"&#x0308;", 		"&#x030a;", 		"&#x0342;", 		"&#x0343;",
		"&#x0344;", 		"&#x034a;", 		"&#x034b;", 		"&#x034c;",
		"&#x0303;", 		"&#x0302;", 		"&#x030c;", 		"&#x0350;",
		"&#x0300;", 		"&#x0301;", 		"&#x030b;", 		"&#x030f;",
		"&#x0312;", 		"&#x0313;", 		"&#x0314;", 		"&#x033d;",
		"&#x0309;", 		"&#x0363;", 		"&#x0364;", 		"&#x0365;",
		"&#x0366;", 		"&#x0367;", 		"&#x0368;", 		"&#x0369;",
		"&#x036a;", 		"&#x036b;", 		"&#x036c;", 		"&#x036d;",
		"&#x036e;", 		"&#x036f;", 		"&#x033e;", 		"&#x035b;",
		"&#x0346;", 		"&#x031a;"
	)

	//those go DOWN
	global.zalgo_down = list(
		"&#x0316;", 		"&#x0317;", 		"&#x0318;", 		"&#x0319;",
		"&#x031c;", 		"&#x031d;", 		"&#x031e;", 		"&#x031f;",
		"&#x0320;", 		"&#x0324;", 		"&#x0325;", 		"&#x0326;",
		"&#x0329;", 		"&#x032a;", 		"&#x032b;", 		"&#x032c;",
		"&#x032d;", 		"&#x032e;", 		"&#x032f;", 		"&#x0330;",
		"&#x0331;", 		"&#x0332;", 		"&#x0333;", 		"&#x0339;",
		"&#x033a;", 		"&#x033b;", 		"&#x033c;", 		"&#x0345;",
		"&#x0347;", 		"&#x0348;", 		"&#x0349;", 		"&#x034d;",
		"&#x034e;", 		"&#x0353;", 		"&#x0354;", 		"&#x0355;",
		"&#x0356;", 		"&#x0359;", 		"&#x035a;", 		"&#x0323;"
	)

	//those always stay in the middle
	global.zalgo_mid = list(
		"&#x0315;", 		"&#x031b;", 		"&#x0340;", 		"&#x0341;",
		"&#x0358;", 		"&#x0321;", 		"&#x0322;", 		"&#x0327;",
		"&#x0328;", 		"&#x0334;", 		"&#x0335;", 		"&#x0336;",
		"&#x034f;", 		"&#x035c;", 		"&#x035d;", 		"&#x035e;",
		"&#x035f;", 		"&#x0360;", 		"&#x0362;", 		"&#x0338;",
		"&#x0337;", 		"&#x0361;", 		"&#x0489;"
	)



	/// Associative list of role defines and their respective client preferences.
	global.roles_to_prefs = list(
		ROLE_TRAITOR = "be_traitor",
		ROLE_SPY_THIEF = "be_spy",
		ROLE_NUKEOP = "be_syndicate",
		ROLE_VAMPIRE = "be_vampire",
		ROLE_GANG_LEADER = "be_gangleader",
		ROLE_WIZARD = "be_wizard",
		ROLE_CHANGELING = "be_changeling",
		ROLE_WEREWOLF = "be_werewolf",
		ROLE_BLOB = "be_blob",
		ROLE_WRAITH = "be_wraith",
		ROLE_HEAD_REVOLUTIONARY = "be_revhead",
		ROLE_CONSPIRATOR = "be_conspirator",
		ROLE_ARCFIEND = "be_arcfiend",
		ROLE_FLOCKMIND = "be_flock",
		ROLE_SALVAGER = "be_salvager",
		ROLE_MISC = "be_misc"
		)




	global.cid_test = list()
	global.cid_tested = list()



	global.vowels_lower = list("a","e","i","o","u")
	global.vowels_upper = list("A","E","I","O","U")
	global.consonants_lower = list("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z")
	global.consonants_upper = list("B","C","D","F","G","H","J","K","L","M","N","P","Q","R","S","T","V","W","X","Y","Z")
	global.symbols = list("!","?",".",",","'","\"","@","#","$","%","^","&","*","+","-","=","_","(",")","<",">","\[","\]",":",";")
	global.numbers = list("0","1","2","3","4","5","6","7","8","9")

	global.stinkDescs = list("nasty","unpleasant","foul","horrible","rotten","unholy",
		"repulsive","noxious","putrid","gross","unsavory","fetid","pungent","vulgar")
	global.stinkTypes = list("smell","stink","odor","reek","stench","miasma")
	global.stinkExclamations = list("Ugh","Good lord","Good grief","Christ","Fuck","Eww")
	global.stinkThings = list("garbage can","trash heap","cesspool","toilet","pile of poo",
		"butt","skunk","outhouse","corpse","fart","devil")
	global.stinkVerbs = list("took a shit","died","farted","threw up","wiped its ass")
	global.stinkThingies = list("ass","armpit","excretions","leftovers","administrator")




	global.easing_types = list(
	"Linear/0" = LINEAR_EASING,
	"Sine/1" = SINE_EASING,
	"Circular/2" = CIRCULAR_EASING,
	"Cubic/3" = CUBIC_EASING,
	"Bounce/4" = BOUNCE_EASING,
	"Elastic/5" = ELASTIC_EASING,
	"Back/6" = BACK_EASING)

	global.blend_types = list(
	"Default/0" = BLEND_DEFAULT,
	"Overlay/1" = BLEND_OVERLAY,
	"Add/2" = BLEND_ADD,
	"Subtract/3" = BLEND_SUBTRACT,
	"Multipy/4" = BLEND_MULTIPLY)



	global.hex_chars = list("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F")

	global.all_functional_reagent_ids = list()



	global.english_num = list("0" = "zero", "1" = "one", "2" = "two", "3" = "three", "4" = "four", "5" = "five", "6" = "six", "7" = "seven", "8" = "eight", "9" = "nine",\
	"10" = "ten", "11" = "eleven", "12" = "twelve", "13" = "thirteen", "14" = "fourteen", "15" = "fifteen", "16" = "sixteen", "17" = "seventeen", "18" = "eighteen", "19" = "nineteen",\
	"20" = "twenty", "30" = "thirty", "40" = "forty", "50" = "fifty", "60" = "sixty", "70" = "seventy", "80" = "eighty", "90" = "ninety")



	global.uppercase_letters = list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
	global.lowercase_letters = list("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z")




	global.trinket_safelist = list(/obj/item/basketball,/obj/item/instrument/bikehorn, /obj/item/brick, /obj/item/clothing/glasses/eyepatch,
	/obj/item/clothing/glasses/regular, /obj/item/clothing/glasses/sunglasses/tanning, /obj/item/clothing/gloves/boxing,
	/obj/item/clothing/mask/horse_mask, /obj/item/clothing/mask/clown_hat, /obj/item/clothing/head/cowboy, /obj/item/clothing/shoes/cowboy, /obj/item/clothing/shoes/moon,
	/obj/item/clothing/suit/sweater, /obj/item/clothing/suit/sweater/red, /obj/item/clothing/suit/sweater/green, /obj/item/clothing/suit/sweater/grandma, /obj/item/clothing/under/shorts,
	/obj/item/clothing/under/suit/pinstripe, /obj/item/cigpacket, /obj/item/coin, /obj/item/crowbar, /obj/item/pen/crayon/lipstick,
	/obj/item/dice, /obj/item/dice/d20, /obj/item/device/light/flashlight, /obj/item/device/key/random, /obj/item/extinguisher, /obj/item/firework,
	/obj/item/football, /obj/item/stamped_bullion, /obj/item/instrument/harmonica, /obj/item/horseshoe,
	/obj/item/kitchen/utensil/knife, /obj/item/raw_material/rock, /obj/item/pen/fancy, /obj/item/pen/odd, /obj/item/plant/herb/cannabis/spawnable,
	/obj/item/razor_blade,/obj/item/rubberduck, /obj/item/instrument/saxophone, /obj/item/scissors, /obj/item/screwdriver, /obj/item/skull, /obj/item/stamp,
	/obj/item/instrument/vuvuzela, /obj/item/wrench, /obj/item/device/light/zippo, /obj/item/reagent_containers/food/drinks/bottle/beer, /obj/item/reagent_containers/food/drinks/bottle/vintage,
	/obj/item/reagent_containers/food/drinks/bottle/vodka, /obj/item/reagent_containers/food/drinks/bottle/rum, /obj/item/reagent_containers/food/drinks/bottle/hobo_wine/safe,
	/obj/item/reagent_containers/food/snacks/burger, /obj/item/reagent_containers/food/snacks/burger/cheeseburger,
	/obj/item/reagent_containers/food/snacks/burger/moldy,/obj/item/reagent_containers/food/snacks/candy/chocolate, /obj/item/reagent_containers/food/snacks/chips,
	/obj/item/reagent_containers/food/snacks/cookie,/obj/item/reagent_containers/food/snacks/ingredient/egg,
	/obj/item/reagent_containers/food/snacks/ingredient/egg/bee,/obj/item/reagent_containers/food/snacks/plant/apple,
	/obj/item/reagent_containers/food/snacks/plant/banana, /obj/item/reagent_containers/food/snacks/plant/potato, /obj/item/reagent_containers/food/snacks/sandwich/pb,
	/obj/item/reagent_containers/food/snacks/sandwich/cheese, /obj/item/reagent_containers/syringe/krokodil, /obj/item/reagent_containers/syringe/morphine,
	/obj/item/reagent_containers/patch/LSD, /obj/item/reagent_containers/patch/lsd_bee, /obj/item/reagent_containers/patch/nicotine, /obj/item/reagent_containers/glass/bucket, /obj/item/reagent_containers/glass/beaker,
	/obj/item/reagent_containers/food/drinks/drinkingglass, /obj/item/reagent_containers/food/drinks/drinkingglass/shot,/obj/item/storage/pill_bottle/bathsalts,
	/obj/item/storage/pill_bottle/catdrugs, /obj/item/storage/pill_bottle/crank, /obj/item/storage/pill_bottle/cyberpunk, /obj/item/storage/pill_bottle/methamphetamine,
	/obj/item/spraybottle,/obj/item/staple_gun,/obj/item/clothing/head/NTberet,/obj/item/clothing/head/biker_cap, /obj/item/clothing/head/black, /obj/item/clothing/head/blue,
	/obj/item/clothing/head/chav, /obj/item/clothing/head/det_hat, /obj/item/clothing/head/green, /obj/item/clothing/head/helmet/hardhat, /obj/item/clothing/head/merchant_hat,
	/obj/item/clothing/head/mj_hat, /obj/item/clothing/head/red, /obj/item/clothing/head/that, /obj/item/clothing/head/wig, /obj/item/clothing/head/turban, /obj/item/dice/magic8ball,
	/obj/item/reagent_containers/food/drinks/mug/random_color, /obj/item/reagent_containers/food/drinks/skull_chalice, /obj/item/pen/marker/random, /obj/item/pen/crayon/random,
	/obj/item/clothing/gloves/yellow/unsulated, /obj/item/reagent_containers/food/snacks/fortune_cookie, /obj/item/instrument/triangle, /obj/item/instrument/tambourine, /obj/item/instrument/cowbell,
	/obj/item/toy/plush/small/bee, /obj/item/paper/book/from_file/the_trial, /obj/item/paper/book/from_file/deep_blue_sea, /obj/item/clothing/suit/bedsheet/cape/red, /obj/item/disk/data/cartridge/clown,
	/obj/item/clothing/mask/cigarette/cigar, /obj/item/device/light/sparkler, /obj/item/toy/sponge_capsule, /obj/item/reagent_containers/food/snacks/plant/pear, /obj/item/reagent_containers/food/snacks/donkpocket/honk/warm,
	/obj/item/seed/alien)



	global.smart_string_pickers = list()




	global.chessboard = list()



	global.parrot_species = list("eclectus" = /datum/species_info/parrot/eclectus,
		"eclectusf" = /datum/species_info/parrot/eclectus/female,
		"agrey" = /datum/species_info/parrot/grey,
		"bcaique" = /datum/species_info/parrot/caique,
		"wcaique" = /datum/species_info/parrot/caique/white,
		"gbudge" = /datum/species_info/parrot/budgie,
		"bbudge" = /datum/species_info/parrot/budgie/blue,
		"bgbudge" = /datum/species_info/parrot/budgie/bluegreen,
		"tiel" = /datum/species_info/parrot/cockatiel,
		"wtiel" = /datum/species_info/parrot/cockatiel/white,
		"luttiel" = /datum/species_info/parrot/cockatiel/lutino,
		"blutiel" = /datum/species_info/parrot/cockatiel/face,
		"too" = /datum/species_info/parrot/cockatoo,
		"utoo" = /datum/species_info/parrot/cockatoo/umbrella,
		"mtoo" = /datum/species_info/parrot/cockatoo/mitchells,
		"toucan" = /datum/species_info/parrot/toucan,
		"kbtoucan" = /datum/species_info/parrot/toucan/keel,
		"smacaw" = /datum/species_info/parrot/macaw,
		"bmacaw" = /datum/species_info/parrot/macaw/bluegold,
		"mmacaw" = /datum/species_info/parrot/macaw/military,
		"hmacaw" = /datum/species_info/parrot/macaw/hyacinth,
		"love" = /datum/species_info/parrot/lovebird,
		"lovey" = /datum/species_info/parrot/lovebird/pfyellow,
		"lovem" = /datum/species_info/parrot/lovebird/masked,
		"loveb" = /datum/species_info/parrot/lovebird/masked/blue,
		"lovef" = /datum/species_info/parrot/lovebird/fischer,
		"kea" = /datum/species_info/parrot/kea)

	global.special_parrot_species = list("ikea" = /datum/species_info/parrot/kea/ikea,
		"space" = /datum/species_info/parrot/space)



	//FUCKABLE AREAS!!
	global.owlery_sounds = list('sound/voice/animal/hoot.ogg','sound/ambience/owlzone/owlsfx1.ogg','sound/ambience/owlzone/owlsfx2.ogg','sound/ambience/owlzone/owlsfx3.ogg','sound/ambience/owlzone/owlsfx4.ogg','sound/ambience/owlzone/owlsfx5.ogg','sound/machines/hiss.ogg')




	global.mantaPushList = list()



	global.globalDialogueFlags = list()



	global.iomoon_exterior_sounds = list('sound/ambience/nature/Lavamoon_DeepBubble1.ogg','sound/ambience/nature/Lavamoon_RocksBreaking1.ogg','sound/ambience/nature/Lavamoon_RocksBreaking2.ogg','sound/ambience/nature/Lavamoon_DeepBubble2.ogg')
	global.iomoon_powerplant_sounds = list('sound/ambience/nature/Lavamoon_RocksBreaking1.ogg','sound/ambience/industrial/LavaPowerPlant_FallingMetal1.ogg','sound/ambience/industrial/LavaPowerPlant_Rumbling3.ogg','sound/ambience/station/Machinery_PowerStation1.ogg','sound/ambience/station/Machinery_PowerStation2.ogg',"rustle",)
	global.iomoon_basement_sounds = list('sound/ambience/industrial/LavaPowerPlant_SteamHiss1.ogg','sound/ambience/industrial/LavaPowerPlant_FallingMetal1.ogg','sound/ambience/industrial/LavaPowerPlant_FallingMetal2.ogg','sound/machines/engine_grump4.ogg','sound/machines/hiss.ogg','sound/vox/smoke.ogg','sound/effects/pump.ogg')
	global.iomoon_ancient_sounds = list('sound/ambience/industrial/AncientPowerPlant_Creaking1.ogg','sound/ambience/industrial/AncientPowerPlant_Creaking2.ogg','sound/ambience/industrial/AncientPowerPlant_Drone2.ogg')
	global.iomoon_alarm_sound = null



	global.scarysounds = list('sound/machines/engine_alert3.ogg',
	'sound/effects/creaking_metal1.ogg',
	'sound/machines/glitch1.ogg',
	'sound/machines/glitch2.ogg',
	'sound/machines/glitch3.ogg',
	'sound/misc/automaton_tickhum.ogg',
	'sound/misc/automaton_ratchet.ogg',
	'sound/misc/automaton_scratch.ogg',
	'sound/musical_instruments/Gong_Rumbling.ogg',
	'sound/ambience/industrial/Precursor_Drone2.ogg',
	'sound/ambience/industrial/Precursor_Choir.ogg',
	'sound/ambience/industrial/Precursor_Drone3.ogg',
	'sound/ambience/industrial/Precursor_Bells.ogg',
	'sound/ambience/industrial/Precursor_Drone1.ogg',
	'sound/ambience/industrial/AncientPowerPlant_Creaking1.ogg',
	'sound/ambience/industrial/AncientPowerPlant_Creaking2.ogg',
	'sound/ambience/industrial/AncientPowerPlant_Drone2.ogg',
	'sound/ambience/industrial/AncientPowerPlant_Drone1.ogg',
	'sound/machines/romhack1.ogg',
	'sound/machines/romhack2.ogg',
	'sound/machines/romhack3.ogg',
	'sound/ambience/industrial/LavaPowerPlant_FallingMetal1.ogg',
	'sound/ambience/industrial/LavaPowerPlant_FallingMetal2.ogg',
	'sound/ambience/industrial/LavaPowerPlant_Rumbling3.ogg',
	'sound/ambience/spooky/Evilreaver_Ambience.ogg',
	'sound/ambience/spooky/Void_Song.ogg',
	'sound/ambience/spooky/Void_Hisses.ogg',
	'sound/ambience/spooky/Void_Screaming.ogg',
	'sound/ambience/spooky/Void_Wail.ogg',
	'sound/ambience/spooky/Void_Calls.ogg')

