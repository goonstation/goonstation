//####################################//
//###~GANNETS' RADIO STATION STUFF~###//
//####################################//

/* --Contents:--
	changed and new files
	areas
	objects
		audio logs
		fake objects
		books
		computers
		records */

/* --Changed/used files + new files list--
	code/WorkInProgress/radioship.dm
	maps/radiostation2.dmm
	icon/obj/radiostation.dmi
	icon/obj/large/64x64.dmi
	icon/obj/large/32x64.dmi
	icon/obj/decoration.dmi
	strings/radioship/radioship_records.txt */

// areas

/area/radiostation
	name = "Radio Station"
	icon_state = "purple"

/area/radiostation/studio
	name = "Radio Studio"
	icon_state = "green"

/area/radiostation/bridge
	name = "Radio Bridge"
	icon_state = "yellow"

/area/radiostation/podbay
	name = "Radio Podbay"
	icon_state = "green"

/area/radiostation/bedroom
	name = "Radio Bedroom"
	icon_state = "red"

/area/radiostation/engineering
	name = "Radio Engine"
	icon_state = "blue"

/area/radiostation/hallway
	name = "Radio Hallway"
	icon_state = "purple"

/area/radiostation/serverroom
	name = "Radio Server"
	icon_state = "yellow"
	sound_environment = 3
	workplace = 1

//objects

// Audio log players
/obj/item/device/audio_log/radioship/large
	name = "audio log"
	desc = "A bulky recording device."
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "audiolog_newLarge"

/obj/item/device/audio_log/radioship/small
	name = "audio log"
	desc = "A handheld recording device."
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "audiolog_newSmall"

/obj/item/device/audio_log/radioship/small/radioshow
		continuous = 0
		audiolog_messages = list("*buzzing static*",
								"*screeching and flapping*",
								"Alright! You're listening to GNTS - The Bird!",
								"This is your host Walt Woodward.",
								"Bringing you those deep cuts you love, all night until four.",
								"*whooping siren*",
								"But uh-oh! Looks like we've got a word from our sponsor coming in.",
								"We'll be right back after this!",
								"*rising static*")
		audiolog_speakers = list("???",
								"???",
								"Male Voice",
								"Male Voice",
								"Geoff",
								"???",
								"Geoff",
								"Geoff",
								"???*")

/obj/item/device/audio_log/radioship/large/distress
		continuous = 0
		audiolog_messages = list("GENERAL DISTRESS BEACON",
								"COORDINATES:",
								"*garbled noises*",
								"BROADCAST RANGE: 253au",
								"MESSAGE:",
								"Hello? Does anyone read me?",
								"*coughing*",
								"This is an urgent distress call fr- *buzzing static*",
								"cargo vessel, I think something's overloading our comm-",
								"*high-pitch squealing*",
								"can't move. Please, if there's anyone in range, we could really use th-",
								"*louder squealing*",
								"TIME SENT: MINUS TWO YEARS, SIX MONTHS, ONE WEEK, FOUR DAYS, TWELVE HOURS")
		audiolog_speakers = list("Electronic Voice",
								"Electronic Voice",
								"???",
								"Electronic Voice",
								"Electronic Voice",
								"Female Voice",
								"???",
								"Female Voice",
								"Female Voice",
								"???",
								"Female Voice",
								"???",
								"Electronic Voice")

// Mixing desk/voice changer
/obj/submachine/mixing_desk
	name = "mixing desk"
	desc = "A large and complicated audio mixing desk. Complete with fancy displays, dials, knobs and automated faders."
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "mixtable-2"
	anchored = ANCHORED
	density = 1
	flags = TGUI_INTERACTIVE
	/// A static list of mixingdesk permitted accent IDs, indexed by their name.
	var/static/list/accents
	/// The maximum number of voices that this mixing desk may store.
	var/const/max_voices = 9
	/// A list of name/accent pairs to be displayed on the UI.
	var/list/voices
	/// A list of abstract say sources to be used for each voice.
	var/list/atom/movable/abstract_say_source/mixing_desk/voice_say_sources
	/// The index of the current voice selected.
	var/selected_voice = 0
	/// Whether the UI should display a say popup window.
	var/say_popup = FALSE

/obj/submachine/mixing_desk/New()
	. = ..()
	src.voices = list()
	src.voice_say_sources = list()

	if (src.accents)
		return

	src.accents = list()
	for (var/datum/bioEffect/speech/effect_type as anything in concrete_typesof(/datum/bioEffect/speech))
		if (!effect_type::acceptable_in_mutini || !effect_type::occur_in_genepools || !effect_type::mixingdesk_allowed)
			continue

		var/name = effect_type::id
		if ((length(name) >= 7) && findtext(name, "accent_", 1, 8))
			name = copytext(name, 8)

		name = replacetext(name, "_", " ")
		src.accents[name] = effect_type::id

/obj/submachine/mixing_desk/ui_status(mob/user, datum/ui_state/state)
	return min(
		state.can_use_topic(src, user),
		tgui_not_incapacitated_state.can_use_topic(src, user)
	)

/obj/submachine/mixing_desk/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MixingDesk", "[src]")
		ui.open()

/obj/submachine/mixing_desk/ui_data(mob/user)
	. = list(
		"voices" = src.voices,
		"selected_voice" = src.selected_voice,
		"say_popup" = src.say_popup
	)

/obj/submachine/mixing_desk/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	if (..())
		return

	switch (action)
		if ("add_voice")
			if (length(src.voices) >= src.max_voices)
				return FALSE

			var/name = tgui_input_text(usr, "Enter voice name:", "Voice Name", max_length = FULLNAME_MAX)
			if (!name)
				return FALSE

			phrase_log.log_phrase("voice-radiostation", name, no_duplicates = TRUE)

			var/accent = tgui_input_list(usr, "Pick an accent:", "Accent", list("None") + src.accents)
			if (accent == "None")
				accent = null
				src.voice_say_sources += new /atom/movable/abstract_say_source/mixing_desk(src, name)
			else
				src.voice_say_sources += new /atom/movable/abstract_say_source/mixing_desk(src, name, src.accents[accent])

			src.voices += list(list(
				"name" = name,
				"accent" = accent,
			))

			. = TRUE

		if("remove_voice")
			var/id = params["id"]
			if ((id <= 0) || (id > length(src.voices)))
				return FALSE

			if (id == src.selected_voice)
				src.selected_voice = 0
			else if (id < src.selected_voice)
				src.selected_voice -= 1

			src.voices.Cut(id, id + 1)
			qdel(src.voice_say_sources[id])

			. = TRUE

		if("switch_voice")
			var/id = params["id"]
			if ((id <= 0) || (id > length(src.voices)))
				src.selected_voice = 0
			else
				src.selected_voice = id

			. = TRUE

		if("say_popup")
			if("id" in params)
				src.selected_voice = params["id"]

			src.say_popup = TRUE
			. = TRUE

		if("cancel_say")
			src.say_popup = FALSE
			. = TRUE

		if("say")
			src.say_popup = FALSE
			var/message = strip_html(params["message"])
			if ((src.selected_voice <= 0) || (src.selected_voice > length(src.voices)))
				usr.say(message, flags = SAYFLAG_SPOKEN_BY_PLAYER)
				return TRUE

			src.voice_say_sources[src.selected_voice].say(message, flags = SAYFLAG_SPOKEN_BY_PLAYER | SAYFLAG_IGNORE_POSITION)

			var/name = src.voices[src.selected_voice]["name"]
			var/accent_id = src.accents[src.voices[src.selected_voice]["accent"]]
			logTheThing(LOG_SAY, usr, "SAY: [message] (Synthesizing the voice of <b>([constructTarget(name, "say")])</b> with accent [accent_id])")

			. = TRUE

// Record player
/obj/submachine/record_player
	name = "record player"
	desc = "An old school vinyl record player sat on a set of drawers. Shame you don't have any records."
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "mixtable-3"
	anchored = ANCHORED
	density = 1
	var/can_play_music = TRUE
	var/has_record = FALSE
	var/obj/item/record/record_inside = null

	New()
		. = ..()
		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, "pda", FREQ_PDA)
		START_TRACKING

	get_desc()
		if(!src.can_play_music)
			. += " There's an \"out of order\" label on it."

	disposing()
		STOP_TRACKING
		. = ..()

/obj/submachine/record_player/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/record))
		if (!src.can_play_music)
			boutput(user, SPAN_ALERT("You insert the record into the record player, but it won't turn on."))
			return
		else if(has_record)
			boutput(user, "The record player already has a record inside!")
		else if(is_music_playing())
			boutput(user, SPAN_ALERT("Music is already playing, it'd be rude to interrupt!"))
		else
			var/obj/item/record/inserted_record = W
			var/record_name = copytext(tgui_input_text(user, "What is the name of this record?", "Record Name", inserted_record.record_name), 1, MAX_MESSAGE_LEN)
			if(!record_name)
				boutput(user, SPAN_NOTICE("You decide not to play this record."))
				return
			if(!(inserted_record in user.equipped_list()))
				boutput(user, SPAN_ALERT("You have to be holding a record to place it in the player!"))
				return
			if(!in_interact_range(src, user))
				boutput(user, SPAN_ALERT("You're out of range of the [src.name]!"))
				return
			if(is_music_playing()) // someone queuing up several input windows
				return
			phrase_log.log_phrase("record", html_encode(record_name))
			boutput(user, "You insert the record into the record player.")
			src.visible_message(SPAN_NOTICE("<b>[user] inserts the record into the record player.</b>"))
			user.drop_item(W)
			W.set_loc(src)
			src.record_inside = W
			src.has_record = TRUE

			if (istype(W, /obj/item/record/remote))
				// play remote
				var/obj/item/record/remote/YT = W
				if (YT.youtube)
					play_youtube_remote_url(user, YT.youtube)
				else
					boutput(user, SPAN_ALERT("You have no idea what happened but this record does not seem to work. Maybe call an admin."))
					return	// guh????
			else
				user.client.play_music_radio(record_inside.song, html_encode(record_name))
			/// PDA message ///
			var/datum/signal/pdaSignal = get_free_signal()
			pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="RADIO-STATION", "sender"="00000000", "message"="Now playing: [record_name].", "group" = MGA_RADIO)
			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal, null, "pda")
#ifdef UNDERWATER_MAP
			EXTEND_COOLDOWN(global, "music", 500 SECONDS)
#else
			EXTEND_COOLDOWN(global, "music", 300 SECONDS)
#endif
	else
		..()

/obj/submachine/record_player/attack_hand(mob/user)
	if(has_record)
		if(!is_music_playing())
			boutput(user, "You remove the record from the record player. It looks worse for the wear.")
			src.visible_message(SPAN_NOTICE("<b>[user] removes the record from the record player.</b>"))
			user.put_in_hand_or_drop(src.record_inside)
			src.record_inside = null
			src.has_record = 0
		else
			boutput(user, "You can feel heat emanating from the record player. You should probably wait a while before touching it. It's kinda old and you don't want to break it.")

/obj/submachine/record_player/portable
	name = "portable record player"
	desc = "An old school record player, painted in a cool syndicate-red."
	icon_state = "portable_record"
	density = 0

	New()
		..()
		src.AddComponent(/datum/component/foldable,/obj/item/objBriefcase/syndicate)
		var/datum/component/foldable/fold_component = src.GetComponent(/datum/component/foldable) //Fold up into a briefcase the first spawn
		if(!fold_component?.the_briefcase)
			return
		var/obj/item/objBriefcase/briefcase = fold_component.the_briefcase
		if (briefcase)
			briefcase.set_loc(get_turf(src))
			src.set_loc(briefcase)
// Records
/obj/item/record
	name = "record"
	desc = "A fairly large record. You imagine there are probably some rad songs on this."
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "record"
	var/song = ""
	var/record_name = ""
	var/add_overlay = 1
	w_class = W_CLASS_NORMAL
	throwforce = 3
	throw_speed = 3
	throw_range = 8
	force = 2

/obj/item/record/New()
	..()
	if (add_overlay)
		src.UpdateOverlays(new /image(src.icon, "record_[rand(1,10)]"), "recordlabel")
	if (record_name)
		src.desc = "A fairly large record. There's a sticker on it that says \"[record_name]\"."

/obj/item/record/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	if (user.a_intent == INTENT_HARM)
		if (target == user)
			boutput(user, SPAN_ALERT("<B>You smash the record over your own head!</b>"))
		else
			target.visible_message(SPAN_ALERT("<B>[user] smashes [src] over [target]'s head!</B>"))
			logTheThing(LOG_COMBAT, user, "smashes [src] over [constructTarget(target,"combat")]'s head! ")
		target.TakeDamageAccountArmor("head", force, 0, 0, DAMAGE_BLUNT)
		target.changeStatus("knockdown", 2 SECONDS)
		playsound(src, "shatter", 70, 1)
		var/obj/O = new /obj/item/raw_material/shard/glass
		O.set_loc(get_turf(target))
		if (src.material)
			O.setMaterial(src.material)
		qdel(src)
	else
		target.visible_message(SPAN_ALERT("[user] taps [target] over the head with [src]."))
		logTheThing(LOG_COMBAT, user, "taps [constructTarget(target,"combat")] over the head with [src].")

ABSTRACT_TYPE(/obj/item/record/random)

/obj/item/record/random/dance_on_a_space_volcano
	name = "record - \"Dance On A Space Volcano\""
	record_name = "Dance On A Space Volcano"
	song = 'sound/radio_station/music/dance_on_a_space_volcano.ogg'

/obj/item/record/random/adventure_1
	name = "record - \"adventure track #1\""
	record_name = "adventure track #1"
	song = "sound/radio_station/music/adventure_1.mod"

/obj/item/record/random/adventure_2
	name = "record - \"adventure track #2\""
	record_name = "adventure track #2"
	song = "sound/radio_station/music/adventure_2.s3m"

/obj/item/record/random/adventure_3
	name = "record - \"adventure track #3\""
	record_name = "adventure track #3"
	song = 'sound/radio_station/music/adventure_3.ogg'

/obj/item/record/random/adventure_4
	name = "record - \"adventure track #4\""
	record_name = "adventure track #4"
	song = 'sound/radio_station/music/adventure_4.ogg'

/obj/item/record/random/adventure_5
	name = "record - \"adventure track #5\""
	record_name = "adventure track #5"
	song = 'sound/radio_station/music/adventure_5.ogg'

/obj/item/record/random/adventure_6
	name = "record - \"adventure track #6\""
	record_name = "adventure track #6"
	song = "sound/radio_station/music/adventure_6.mod"

/obj/item/record/random/upbeat_1
	name = "record - \"upbeat track #1\""
	record_name = "upbeat track #1"
	song = 'sound/radio_station/music/upbeat_1.ogg'

/obj/item/record/random/upbeat_2
	name = "record - \"upbeat track #2\""
	record_name = "upbeat track #2"
	song = 'sound/radio_station/music/upbeat_2.ogg'

/obj/item/record/random/chill_1
	name = "record - \"chill track #1\""
	record_name = "chill track #1"
	song = 'sound/radio_station/music/chill_1.ogg'

/obj/item/record/random/chill_2
	name = "record - \"chill track #2\""
	record_name = "chill track #2"
	song = 'sound/radio_station/music/chill_2.ogg'

/obj/item/record/random/chill_3
	name = "record - \"chill track #3\""
	record_name = "chill track #3"
	song = 'sound/radio_station/music/chill_3.ogg'

/obj/item/record/random/chill_4
	name = "record - \"chill track #4\""
	record_name = "chill track #4"
	song = 'sound/radio_station/music/chill_4.ogg'

/obj/item/record/random/january
	record_name = "january"
	song = "sound/radio_station/music/january.xm"

/obj/item/record/random/february
	record_name = "february"
	song = "sound/radio_station/music/february.xm"

/obj/item/record/random/march
	record_name = "march"
	song = "sound/radio_station/music/march.xm"

/obj/item/record/random/april
	record_name = "april"
	song = "sound/radio_station/music/april.xm"

/obj/item/record/random/may
	record_name = "may"
	song = "sound/radio_station/music/may.xm"

/obj/item/record/random/june
	record_name = "june"
	song = "sound/radio_station/music/june.xm"

/obj/item/record/random/july
	record_name = "july"
	song = "sound/radio_station/music/july.xm"

/obj/item/record/random/august
	record_name = "august"
	song = "sound/radio_station/music/august.xm"

/obj/item/record/random/september
	record_name = "september"
	song = "sound/radio_station/music/september.xm"

/obj/item/record/random/october
	record_name = "october"
	song = "sound/radio_station/music/october.xm"

/obj/item/record/random/november
	record_name = "november"
	song = "sound/radio_station/music/november.xm"

/obj/item/record/random/december
	record_name = "december"
	song = "sound/radio_station/music/december.xm"

/obj/item/record/spacebux // Many thanks to Camryn Buttes!!
	add_overlay = 0
	icon_state = "record_red"

ABSTRACT_TYPE(/obj/item/record/random/nostalgic)
/obj/item/record/random/nostalgic
	New()
		. = ..()
		src.desc += {" Nostalgic sounds from SS13 yesteryears."}

/obj/item/record/random/nostalgic/distant
	name = "record - \"Distant Star\""
	record_name = "Distant Star"
	song = 'sound/radio_station/music/distant_star.ogg'

/obj/item/record/random/nostalgic/technologic
	name = "record - \"High Technologic Beat\""
	record_name = "High Technologic Beat"
	song = 'sound/radio_station/music/high_technologic_beat.ogg'

/obj/item/record/random/nostalgic/afterparty
	name = "record - \"After Party\""
	record_name = "After Party"
	song = 'sound/radio_station/music/after_party.ogg'

/obj/item/record/random/nostalgic/soalive
	name = "record - \"Everyone Is So Alive\""
	record_name = "Everyone Is So Alive"
	song = 'sound/radio_station/music/everyone_is_so_alive.ogg'

/obj/item/record/random/nostalgic/alivetoo
	name = "record - \"It Feels Good To Be Alive Too\""
	record_name = "It Feels Good To Be Alive Too"
	song = 'sound/radio_station/music/it_feels_good_to_be_alive_too.ogg'

ABSTRACT_TYPE(/obj/item/record/random/chronoquest)
/obj/item/record/random/chronoquest
	New()
		. = ..()
		src.desc += {" Created by <a href="https://soundcloud.com/wizardofthewestside">Chronoquest</a>."}

/obj/item/record/random/chronoquest/waystations
	record_name = "Waystations"
	name = "record - \"Waystations\""
	song = 'sound/radio_station/music/waystations.ogg'

/obj/item/record/random/chronoquest/planets
	record_name = "Planets"
	name = "record - \"Planets\""
	song = 'sound/radio_station/music/planets.ogg'

/obj/item/record/random/chronoquest/oh_no_evil_star
	record_name = "Oh No Evil Star"
	name = "record - \"Oh No Evil Star\""
	song = 'sound/radio_station/music/oh_no_evil_star.ogg'

/obj/item/record/random/chronoquest/cloudskymanguy
	record_name = "Cloudskymanguy"
	name = "record - \"Cloudskymanguy\""
	song = 'sound/radio_station/music/cloudskymanguy.ogg'

/obj/item/record/random/chronoquest/black_wing_interface
	record_name = "Black Wing Interface"
	name = "record - \"Black Wing Interface\""
	song = 'sound/radio_station/music/black_wing_interface.ogg'

/obj/item/record/random/chronoquest/riverdancer
	name = "record - \"Riverdancer\""
	record_name = "Riverdancer"
	song = 'sound/radio_station/music/riverdancer.ogg'

/obj/item/record/random/key_lime
	name = "record - \"key_lime #1\""
	record_name = "key lime #1"
	song = 'sound/radio_station/music/key_lime.ogg'
	add_overlay = FALSE

	New()
		..()
		src.UpdateOverlays(new /image(src.icon, "record_6"), "recordlabel") //it should always be green because I'm so funny.

// nukie record
/obj/item/record/second_reality
	name = "record - \"Second Reality\""
	record_name = "Second Reality"
	song = "sound/radio_station/music/second_reality.s3m"
	add_overlay = FALSE

	New()
		..()
		var/image/overlay = new /image(src.icon, "record_3")
		overlay.color = list(1.5, 0, 0, 0, 0, 0, 0, 0, 0) // very red
		src.UpdateOverlays(overlay, "recordlabel")
		src.desc = "A fairly large record. You imagine there are probably some rad songs on this. Rad, get it? Because the station is gonna be irradiated once the nuke detonates. Song by Purple Motion."

ABSTRACT_TYPE(/obj/item/record/random/metal)
/obj/item/record/random/metal
	New()
		. = ..()
		src.desc += {" A space metal record, rock on!"}

/obj/item/record/random/metal/xtra
	name = "record - \"Radstorm Rock\""
	record_name = "Radstorm Rock"
	song = 'sound/radio_station/music/xtra.ogg'

/obj/item/record/random/metal/giga
	name = "record - \"Punctured Spacesuit\""
	record_name = "Punctured Spacesuit"
	song = 'sound/radio_station/music/giga.ogg'

/obj/item/record/random/metal/maxi
	name = "record - \"Plasmageddon\""
	record_name = "Plasmageddon"
	song = 'sound/radio_station/music/maxi.ogg'

ABSTRACT_TYPE(/obj/item/record/random/funk)
/obj/item/record/random/funk
	New()
		. = ..()
		src.desc += {" A space funk record to groove to!"}

/obj/item/record/random/funk/funkadelic
	name = "record - \"Fission Funk\""
	record_name = "Fission Funk"
	song = 'sound/radio_station/music/funkadelic.ogg'

/obj/item/record/random/funk/groovy
	name = "record - \"Gaussian Groove\""
	record_name = "Gaussian Groove"
	song = 'sound/radio_station/music/groovy.ogg'

/obj/item/record/random/funk/time4lunch
	name = "record - \"Lunch4Laika\""
	record_name = "Lunch4Laika"
	song = 'sound/radio_station/music/lunch.ogg'

/obj/item/record/random/funk/monkey_riot
	name = "record - \"Monkey Riot\""
	record_name = "Monkey Riot"
	song = 'sound/radio_station/music/monkey_riot.ogg'

/obj/item/record/random/funk/space_gardener
	name = "record - \"Space Gardener\""
	record_name = "Space Gardener"
	song = 'sound/radio_station/music/space_gardener.ogg'

ABSTRACT_TYPE(/obj/item/record/random/notaquario)
/obj/item/record/random/notaquario
	New()
		. = ..()
		src.desc += {" A record from the Aquario and Not Tom Mixtape, looks pretty old!"}

/obj/item/record/random/notaquario/beaches
	record_name = "Beaches"
	song = 'sound/radio_station/music/beaches.ogg'

/obj/item/record/random/notaquario/graveyard
	record_name = "Graveyard"
	song = 'sound/radio_station/music/graveyard.ogg'

/obj/item/record/random/notaquario/floaty
	record_name = "I'm Floaty In Space But Thats Ok"
	song = 'sound/radio_station/music/floaty.ogg'

/obj/item/record/random/notaquario/repose
	record_name = "Repose"
	song = 'sound/radio_station/music/repose.ogg'

/obj/item/record/random/notaquario/biodome
	record_name = "Biodome"
	song = 'sound/radio_station/music/biodome.ogg'

/obj/item/record/spacebux/New()
	..()
	var/obj/item/record/record_type = pick(concrete_typesof(/obj/item/record/random))
	src.name = initial(record_type.name)
	src.record_name = initial(record_type.record_name)
	src.name = initial(record_type.name)
	src.song = initial(record_type.song)
	if(src.record_name)
		src.desc = "A fairly large record. There's a sticker on it that says \"[record_name]\"."

/obj/item/record/poo
	desc = "A fairly large record. It has a scratch on one side."
	add_overlay = 0
	icon_state = "record_blue"
	song = 'sound/radio_station/music/poo.ogg'

/obj/item/record/poo/attackby(obj/item/P, mob/user)
	if (istype(P, /obj/item/magnifying_glass))
		boutput(user, SPAN_NOTICE("You examine the record with the magnifying glass."))
		sleep(2 SECONDS)
		boutput(user, "The scratch on the record, upon close examination, is actually tiny lettering. It says, <i>Fuck Discount Dan's. I hope more of your factories go under and you all drown in your toxic sewage.</i>")

/obj/item/record/atlas
	desc = "Ode to a space ship."
	song = 'sound/radio_station/music/atlas.ogg'

/obj/item/record/honey
	desc = "A fairly large record. It's all sticky and coated in honey!"
	add_overlay = 0
	icon_state = "record_honey"
	song = 'sound/radio_station/music/bumblebee.ogg'

/obj/item/record/christmas
	desc = "A truly nefarious and unholy record that has been banned in most of space."
	add_overlay = 0
	icon_state = "record_red"
	song = 'sound/radio_station/music/christmassong.ogg'

/obj/item/record/honkmas
	desc = "Wow, this fruitcake record is almost as good as the real thing!"
	add_overlay = 0
	icon_state = "record_fruit"
	song = 'sound/radio_station/music/honkmas.ogg'

/obj/item/record/clown_collection // By Arborinus. Honk!
	add_overlay = 0
	icon_state = "record_yellow"

/obj/item/record/clown_collection/honk
	song = 'sound/radio_station/music/warriors_honk.ogg'
	color = "#DED347"

/obj/item/record/clown_collection/uguu
	song = 'sound/radio_station/music/uguu.ogg'
	color = "#DEC647"

/obj/item/record/clown_collection/eggshell
	song = 'sound/radio_station/music/eggshell.ogg'
	color = "#DEB947"

/obj/item/record/clown_collection/disco
	song = 'sound/radio_station/music/disco_poo.ogg'
	color = "#DEAC47"

/obj/item/record/clown_collection/poo
	song = 'sound/radio_station/music/core_of_poo.ogg'
	color = "#DE9F47"

/obj/item/record/remote
	name = "remote record"
	desc = "You know those casettes that you put in tape decks that are actually aux cables? This is like that, but for records! You have no idea how it works."
	icon_state = "record_red"
	var/youtube = null

	get_desc()
		if (src.youtube)
			. += " It looks like it will play <a href=\"[copytext(src.youtube,1,5) == "http" ? "[src.youtube]" : "https://youtu.be/[src.youtube]"]\">this</a>, whatever that is."
		else
			. += " It looks like this isn't connected to anything. You should probably call an admin."

	attack_self(mob/user as mob)
		if (!src.youtube && isadmin(user))
			var/yt = input(user, "Input the Youtube video information\nEither the full URL e.g. https://www.youtube.com/watch?v=145RCdUwAxM\nOr just the video ID e.g. 145RCdUwAxM", "Set Record Audio") as null|text
			if (yt)
				boutput(user, SPAN_NOTICE("You configure the record's radio. This makes sense, I promise."))
				src.name = "remote record - \"???\""
				src.youtube = yt
				src.record_name = yt
				var/de = input(user, "What should the name of this record be?", "Set Record Name") as null|text
				if (de)
					src.name = "remote record - \"[de]\""
					src.record_name = de
		else if (!src.youtube && !isadmin(user))
			boutput(user, SPAN_NOTICE("You have no idea how to configure this thing! It's written in some sort of weird language that makes your head hurt and your ears throb with knocking sounds."))
		return


// Record sets
/obj/item/storage/box/record
	name = "record sleeve"
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "sleeve_1"
	desc = "A sturdy record sleeve, designed to hold multiple records."
	max_wclass = W_CLASS_NORMAL
	can_hold = list(/obj/item/record)

/obj/item/storage/box/record/clown_collection
	icon_state = "sleeve_2"
	desc = "Did someone say <i>honk</i>?"
	spawn_contents = list(/obj/item/record/clown_collection/honk,
	/obj/item/record/clown_collection/uguu,
	/obj/item/record/clown_collection/eggshell,
	/obj/item/record/clown_collection/disco,
	/obj/item/record/clown_collection/poo)

/obj/item/storage/box/record/radio
	desc = "A sturdy record sleeve, designed to hold multiple records. The art on the cover is very lovely."

/obj/item/storage/box/record/radio/New()
	..()
	icon_state = "sleeve_[rand(4,36)]"

/obj/item/storage/box/record/radio/one
	spawn_contents = list(/obj/item/record/random/january,
	/obj/item/record/random/february,
	/obj/item/record/random/march,
	/obj/item/record/random/april,
	/obj/item/record/random/may,
	/obj/item/record/random/june)

/obj/item/storage/box/record/radio/two
	spawn_contents = list(/obj/item/record/random/july,
	/obj/item/record/random/august,
	/obj/item/record/random/september,
	/obj/item/record/random/october,
	/obj/item/record/random/november,
	/obj/item/record/random/december)

/obj/item/storage/box/record/radio/nostalgic
	name = "\improper Nostalgic Dance record sleeve"
	desc = {"A sturdy record sleeve, designed to hold multiple records. These song titles seem familiar..."}
	spawn_contents = list(
		/obj/item/record/random/nostalgic/distant,
		/obj/item/record/random/nostalgic/technologic,
		/obj/item/record/random/nostalgic/afterparty,
		/obj/item/record/random/nostalgic/soalive,
		/obj/item/record/random/nostalgic/alivetoo)

/obj/item/storage/box/record/radio/guitar
	name = "\improper Space Metal N' Funk record sleeve"
	desc = {"A sturdy record sleeve, designed to hold multiple records. It seems to have an assortment of rockin' tunes."}
	spawn_contents = list(
		/obj/item/record/random/metal/xtra,
		/obj/item/record/random/metal/giga,
		/obj/item/record/random/metal/maxi,
		/obj/item/record/random/funk/funkadelic,
		/obj/item/record/random/funk/groovy,
		/obj/item/record/random/funk/time4lunch)

/obj/item/storage/box/record/radio/chronoquest
	name = "\improper Chronoquest record sleeve"
	desc = {"A sturdy record sleeve, designed to hold multiple records made by <a href="https://soundcloud.com/wizardofthewestside">Chronoquest</a>."}
	spawn_contents = list(
		/obj/item/record/random/chronoquest/waystations,
		/obj/item/record/random/chronoquest/planets,
		/obj/item/record/random/chronoquest/oh_no_evil_star,
		/obj/item/record/random/chronoquest/cloudskymanguy,
		/obj/item/record/random/chronoquest/black_wing_interface,
		/obj/item/record/random/chronoquest/riverdancer)

/obj/item/storage/box/record/notaquario
	name = "\improper Aquario and Not Tom's Mixtape Vol 1"
	desc = "Woa, these are some old tunes! Made by Aquario and Not Tom way back in the early 2020s!"
	spawn_contents = list(/obj/item/record/random/notaquario/graveyard,
	/obj/item/record/random/notaquario/repose,
	/obj/item/record/random/notaquario/beaches,
	/obj/item/record/random/notaquario/floaty,
	/obj/item/record/random/notaquario/biodome)

/obj/item/storage/box/record/radio/host
	desc = "A sleeve of exclusive radio station songs."

/obj/item/storage/box/record/radio/host/make_my_stuff()
	..()
	var/list/possibilities = concrete_typesof(/obj/item/record/random, cache=FALSE)
	possibilities = possibilities.Copy() // so we don't modify the cached version if someone else cached it I guess
	while (!src.storage.is_full() && length(possibilities))
		var/obj/item/record/R = pick(possibilities)
		src.storage.add_contents(new R(src))
		possibilities -= R

// Tape deck
/obj/submachine/tape_deck
	name = "tape deck"
	desc = "A large standalone reel-to-reel tape deck."
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "tapedeck"
	anchored = ANCHORED
	density = 1
	var/has_tape = FALSE
	var/can_play_tapes = TRUE
	var/obj/item/radio_tape/tape_inside = null

	New()
		. = ..()
		START_TRACKING
		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, "pda", FREQ_PDA)

	get_desc()
		if(!src.can_play_tapes)
			. += " There's an \"out of order\" label on it."

	disposing()
		STOP_TRACKING
		. = ..()

/obj/submachine/tape_deck/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/radio_tape))
		if(!src.can_play_tapes)
			boutput(user, SPAN_ALERT("You insert the tape into the tape deck, but it won't turn on."))
			return
		if(has_tape)
			boutput(user, "The tape deck already has a tape inserted!")
		else if(is_music_playing())
			boutput(user, SPAN_ALERT("Music is already playing, it'd be rude to interrupt!"))
		else if(GET_COOLDOWN(src, "play"))
			boutput(user, SPAN_ALERT("The tape deck is still rewinding!"))
		else
			src.visible_message(SPAN_NOTICE("<b>[user] inserts the compact tape into the tape deck.</b>"),
			"You insert the compact tape into the tape deck.")
			user.drop_item()
			W.set_loc(src)
			src.tape_inside = W
			src.has_tape = TRUE
			user.client.play_music_radio(tape_inside.audio)
			/// PDA message ///
			var/datum/signal/pdaSignal = get_free_signal()
			pdaSignal.data = list("command"="text_message", "sender_name"="RADIO-STATION", "sender"="00000000", "message"="Now playing: [src.tape_inside.audio_type] for [src.tape_inside.name_of_thing].", "group" = MGA_RADIO)
			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal, null, "pda")
			EXTEND_COOLDOWN(src, "play", 600 SECONDS)

/obj/submachine/tape_deck/attack_hand(mob/user)
	if(has_tape)
		if(!GET_COOLDOWN(src, "play"))
			if(istype(src.tape_inside,/obj/item/radio_tape/advertisement))
				src.visible_message(SPAN_ALERT("<b>[src.tape_inside]'s copyright preserving self destruct feature activates!</b>"))
				qdel(src.tape_inside)
				src.tape_inside = null
				src.has_tape = 0
			else
				boutput(user, "You remove the tape from the tape deck.")
				src.visible_message(SPAN_NOTICE("<b>[user] removes the tape from the tape deck.</b>"))
				user.put_in_hand_or_drop(src.tape_inside)
				src.tape_inside = null
				src.has_tape = 0
		else
			boutput(user, "It looks like the tape is still being rewound. You should wait a bit more before taking it out.")

// Tapes
/obj/item/radio_tape
	name = "compact tape"
	desc = "A small audio tape. Though, it looks too big to fit in an audio log."
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "tape"
	w_class = W_CLASS_SMALL
	var/audio = null
	var/audio_type = "Test"
	var/name_of_thing = "Beep boop"


/obj/item/radio_tape/advertisement
	audio_type = "Advertisement"

/obj/item/radio_tape/advertisement/grones
	name = "compact tape - 'Grones Soda'"
	audio = 'sound/radio_station/adverts/grones.ogg'
	name_of_thing = "Grones Soda"

/obj/item/radio_tape/advertisement/dans_tickets
	name = "compact tape - 'Discount Dan's GTMs'"
	audio = 'sound/radio_station/adverts/dans_tickets.ogg'
	name_of_thing = "Discount Dan's GTMs"

/obj/item/radio_tape/advertisement/quik_noodles
	name = "compact tape - 'Discount Dan's Quik Noodles'"
	audio = 'sound/radio_station/adverts/quik_noodles.ogg'
	name_of_thing = "Discount Dan's Quik Noodles"
	desc = {"A small audio tape. It looks too big to fit in an audio log.<br>
	The music is "Palast Rock by Stefan Kartenberg (CC BY-NC 3.0)"}

/obj/item/radio_tape/advertisement/danitos_burritos
	name = "compact tape - 'Descuento Danito's Burritos'"
	audio = 'sound/radio_station/adverts/danitos_burritos.ogg'
	name_of_thing = "Descuento Danito's Burritos"
	desc = {"A small audio tape. It looks too big to fit in an audio log.<br>
	The music is "Requiem for a Fish" by The Freak Fandango Orchestra (CC BY-NC 4.0)"}

/obj/item/radio_tape/advertisement/movie
	name = "compact tape - 'Movie Ad'"
	audio = 'sound/radio_station/adverts/bill_movie.ogg'
	name_of_thing = "some shitty movie"

/obj/item/radio_tape/advertisement/pope_crunch
	name = "compact tape - 'Pope Crunch'"
	audio = 'sound/radio_station/adverts/pope_crunch_cereal.ogg'
	name_of_thing = "Pope Crunch Cereal"
	desc = {"A small audio tape. It looks too big to fit in an audio log.<br>
	Voiceover by Puppet Master and HeadsmanStukka of the Black Pants Legion. <br>
	The music is Smooth Talker by Apoxode (CC BY 3.0)"}

/obj/item/radio_tape/advertisement/cloning_psa
	name = "compact tape - 'Cloning PSA'"
	audio = 'sound/radio_station/adverts/cloning_psa.ogg'
	name_of_thing = "Cloning Public Service Announcement"
	desc = {"A small audio tape. It looks too big to fit in an audio log.<br>
	Voiceover by Cenith of the Black Pants Legion<br>
	Musical backing is "Inspretional Wave" by khalafnasirs 2020 (CC-BY-NC 3.0)"}

/obj/item/radio_tape/advertisement/captain_psa
	name = "compact tape - 'Captain's Training Program'"
	audio = 'sound/radio_station/adverts/captain_training.ogg'
	name_of_thing = "Nanotrasen Captain's Training Promotional Tape"
	desc = {"A small audio tape. It looks too big to fit in an audio log.<br>
	Voiceover by Tex of the Black Pants Legion<br>
	Musical backing is "Out of Space" by Javolenus 2019 CC-BY NC 3.0"}

/obj/item/radio_tape/advertisement/security_psa
	name = "compact tape - 'Nanotrasen Security PSA'"
	audio = 'sound/radio_station/adverts/security_psa.ogg'
	name_of_thing = "Security Department Public Service Announcement"
	desc = {"A small audio tape. It looks too big to fit in an audio log.<br>
	Voiceover by Squidchild of the Black Pants Legion"}

/obj/item/radio_tape/advertisement/cargonia
	name = "compact tape - 'Scuffed Compact Tape'"
	audio = 'sound/radio_station/adverts/Cargonia.ogg'
	name_of_thing = "Cargo Union Advertisement <VERY ILLEGAL>"
	desc = {"A small audio tape. It looks too big to fit in an audio log.<br>
	You found this in a locked up chest in the depths. Someone went to a lot of trouble to get rid of it.<br>
	Voiceover by Tex of the Black Pants Legion<br>
	Musical Backing is "Valor" by David Fesliyan"}

/obj/item/radio_tape/advertisement/chemistry
	name = "charred compact tape - 'Unofficial Chemsitry Advertisement tape'"
	audio = 'sound/radio_station/adverts/Chemistry.ogg'
	name_of_thing = "Unofficial Chemsitry Advertisement"
	desc = {"A small audio tape. It looks too big to fit in an audio log.<br>
	Voiceover by Brixx79 of Goonstation"}

/obj/item/radio_tape/advertisement/robotics
	name = "bloodied compact tape stained with oil - 'Unofficial Robotics Advertisement tape'"
	audio = 'sound/radio_station/adverts/Robotics.ogg'
	name_of_thing = "Unofficial Robotics Advertisement"
	desc = {"A small audio tape. It looks too big to fit in an audio log.<br>
	Voiceover by Brixx79 of Goonstation"}

/obj/item/radio_tape/audio_book
	audio_type = "Audio book"

/obj/item/radio_tape/audio_book/heisenbee
	name = "compact tape - 'The Trial of Heisenbee'"
	audio = 'sound/radio_station/trial_of_heisenbee.ogg'
	name_of_thing = "The Trial of Heisenbee"

///obj/item/radio_tape/audio_book/commander_announcement
//	name = "Commander's Log - 'You Got A Small Arsenal'"
//	name_of_thing = "You Got A Small Arsenal"
//	audio = 'sound/radio_station/commander_announcement.ogg'

/obj/item/radio_tape/audio_book/commander_support
	name = "Commander's Log - 'Customer Support Ticket #121'"
	name_of_thing = "Customer Support Ticket #121"
	audio = 'sound/radio_station/commander_support.ogg'

/obj/item/radio_tape/audio_book/commander_resignation
	name = "Commander's Log - 'I Quit'"
	name_of_thing = "I Quit"
	audio = 'sound/radio_station/commander_resignation.ogg'

/obj/item/radio_tape/audio_book/commander_figurines
	name = "Commander's Log - 'They're Called Collectibles'"
	name_of_thing = "They're Called Collectibles"
	audio = 'sound/radio_station/commander_figurines.ogg'

/obj/item/radio_tape/owl
	audio_type = "???"
	name = "compact tape - 'Owls'"
	audio = 'sound/radio_station/adverts/owl.ogg'
	name_of_thing = "Owls"

/obj/item/radio_tape/adventure
	audio_type = "???"
	name = "compact tape - 'Unlabeled'"
	audio = 'sound/ambience/spooky/Somewhere_Tone.ogg'
	name_of_thing = "found tape"
	interesting = "The tape seems pretty corrupted."


// Drawer
/*/obj/table/wood/auto/desk/radio
	var/list/stuff = list()

	New()
		..()
		for (var/thing in src.stuff)
			new thing(src.desk_drawer)

	records
		stuff = list(/obj/item/record,
		/obj/item/record/distant,
		/obj/item/record/too,
		/obj/item/record/atmosphere,
		/obj/item/record/party,
		/obj/item/record/high,
		/obj/item/record/anonymous)

	tapes
		stuff = list(/obj/item/radio_tape/advertisement/grones,
		/obj/item/radio_tape/advertisement/dans_tickets,
		/obj/item/radio_tape/audio_book/heisenbee)*/

//Fake objects
/obj/fakeobject/cpucontroller
	name = "central processing unit"
	desc = "The computing core of the mainframe."
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "gannets_machine1"
	bound_width = 64
	bound_height = 32
	anchored = ANCHORED
	density = 1

/obj/fakeobject/vacuumtape
	name = "vacuum column tape drive"
	desc = "A large 9 track magnetic tape storage unit."
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "gannets_machine2"
	bound_width = 32
	bound_height = 64
	anchored = ANCHORED
	density = 1

/obj/fakeobject/operatorconsole
	name = "operator's console"
	desc = "The computer operating console, covered in fancy toggle switches and register value lamps."
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "gannets_machine1"
	bound_width = 32
	bound_height = 64
	anchored = ANCHORED
	density = 1

/obj/fakeobject/broadcastcomputer
	name = "broadcast server"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "gannets_machine11"
	anchored = ANCHORED
	density = 1

/obj/fakeobject/tapedeck
	name = "reel to reel tape deck"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "gannets_machine20"
	anchored = ANCHORED
	density = 1

//Computer, disk and files.

/obj/item/disk/data/fixed_disk/radioship

/obj/item/disk/data/fixed_disk/radioship/New()
	..()

	var/datum/computer/folder/newfolder = new /datum/computer/folder(  )
	newfolder.name = "logs"
	src.root.add_file( newfolder )
	newfolder.add_file( new /datum/computer/file/record/c3help(src))

	newfolder = new /datum/computer/folder
	newfolder.name = "bin"
	src.root.add_file( newfolder )
	newfolder.add_file( new /datum/computer/file/terminal_program/writewizard(src))

	newfolder = new /datum/computer/folder
	newfolder.name = "doc"
	src.root.add_file( newfolder )
	newfolder.add_file( new /datum/computer/file/record/radioship/testlog (src))
	newfolder.add_file( new /datum/computer/file/record/radioship/testlog2 (src))

/obj/machinery/computer3/generic/personal/radioship
	setup_drive_type = /obj/item/disk/data/fixed_disk/radioship

/datum/computer/file/record/radioship

/datum/computer/file/record/radioship/testlog
	name = "nav_logs"

/datum/computer/file/record/radioship/testlog/New()
	..()
	fields = strings("radioship/radioship_records.txt","log_1")

/datum/computer/file/record/radioship/testlog2
	name = "inter-ship_communications"

/datum/computer/file/record/radioship/testlog2/New()
	..()
	fields = strings("radioship/radioship_records.txt","log_2")


TYPEINFO(/obj/item/device/radio/intercom/radiostation)
	mats = 0
/obj/item/device/radio/intercom/radiostation
	name = "broadcast radio"
	desc = "A powerful radio transmitter. Enable the microphone to begin broadcasting your radio show."
	device_color = "#E52780"
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "mixtable-1"
