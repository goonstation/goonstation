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
	icon/obj/64x64.dmi
	icon/obj/32x64.dmi
	icon/obj/decoration.dmi
	strings/radioship/radioship_records.txt */

// areas

/area/radiostation/
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
	name = "Audio log"
	desc = "A bulky recording device."
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "audiolog_newLarge"

/obj/item/device/audio_log/radioship/small
	name = "Audio log"
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
	anchored = 1.0
	density = 1
	var/state = 0
	var/state_name = "OFF"
	var/voice = 0
	var/last_voice = ""

/obj/submachine/mixing_desk/attack_hand(mob/user as mob)
	if(..())
		return
	src.add_dialog(user)
	var/dat = "<a href='byond://?src=\ref[src];state=1'>[src.state_name]</a>"
	if(state)
		dat += "<center><h4>Mixing Desk</h4></center>"
		if(voice)
			dat += "<br><center><h3>Voice synthesized: [src.voice]</h3></center>"
		else
			dat += "<br><center><h3>Error: no voice</h3></center>"
		dat += "<center><b><a href='byond://?src=\ref[src];voice=1'>Voice</a> | "
		dat += "<a href='byond://?src=\ref[src];say=1'>Say</a>"

	user.Browse(dat, "window=mixing_desk")
	onclose(user, "mixing_desk")
	return

/obj/submachine/mixing_desk/Topic(href, href_list)
	if(..()) return
	if(usr.stat || usr.restrained()) return
	if(!in_range(src, usr)) return

	if (href_list["state"])
		if(state)
			state = 0
			state_name = "OFF"
		else
			state = 1
			state_name = "ON"

	else if (href_list["voice"])
		voice = html_encode(input("Choose a voice to synthesize:","Voice",last_voice) as null|text)
		last_voice = voice

	else if (href_list["say"])
		if (!voice)
			return
		var/message = html_encode(input("Choose something to say:","Message","") as null|text)
		logTheThing("say", usr, voice, "SAY: [message] (Synthesizing the voice of <b>([constructTarget(voice,"say")])</b>)")
		var/original_name = usr.real_name
		usr.real_name = copytext(voice, 1, MOB_NAME_MAX_LENGTH)
		usr.say(message)
		usr.real_name = original_name

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

// Record player
/obj/submachine/record_player
	name = "record player"
	desc = "An old school vinyl record player sat on a set of drawers. Shame you don't have any records."
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "mixtable-3"
	anchored = 1.0
	density = 1
	var/has_record = 0
	var/is_playing = 0
	var/obj/item/record/record_inside = null

/obj/submachine/record_player/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/record))
		if(has_record)
			boutput(user, "The record player already has a record inside!")
		else if(!is_playing)
			boutput(user, "You insert the record into the record player.")
			src.visible_message("<span class='notice'><b>[user] inserts the record into the record player.</b></span>")
			user.drop_item()
			W.set_loc(src)
			src.record_inside = W
			src.has_record = 1
			src.is_playing = 1
			var/R = html_encode(input("What is the name of this record?","Record Name") as null|text)
			if (!R)
				R = record_inside.record_name ? record_inside.record_name : pick("rad tunes","hip jams","cool music","neat sounds","magnificent melodies","fantastic farts")
			user.client.play_music_radio(record_inside.song, R)
			/// PDA message ///
			var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
			var/datum/signal/pdaSignal = get_free_signal()
			pdaSignal.data = list("command"="text_message", "sender_name"="RADIO-STATION", "sender"="00000000", "message"="Now playing: [R].")
			pdaSignal.transmission_method = TRANSMISSION_RADIO
			if(transmit_connection != null)
				transmit_connection.post_signal(src, pdaSignal)
			//////
#ifdef UNDERWATER_MAP
				sleep(5000) // mbc : underwater map has the radio on-station instead of in space. so it gets played a lot more often + is breaking my immersion
#else
				sleep(3000)
#endif
			is_playing = 0
	else
		..()

/obj/submachine/record_player/attack_hand(mob/user as mob)
	if(has_record)
		if(!is_playing)
			boutput(user, "You remove the record from the record player. It looks worse for the wear.")
			src.visible_message("<span class='notice'><b>[user] removes the record from the record player.</b></span>")
			user.put_in_hand_or_drop(src.record_inside)
			src.record_inside = null
			src.has_record = 0
		else
			boutput(user, "You can feel heat emanating from the record player. You should probably wait a while before touching it. It's kinda old and you don't want to break it.")

// Records
/obj/item/record
	name = "record"
	desc = "A fairly large record. You imagine there are probably some rad songs on this."
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "record"
	var/song = ""
	var/record_name = ""
	var/add_overlay = 1
	w_class = 3.0
	throwforce = 3.0
	throw_speed = 3
	throw_range = 8
	force = 2

/obj/item/record/New()
	..()
	if (add_overlay)
		src.UpdateOverlays(new /image(src.icon, "record_[rand(1,10)]"), "recordlabel")
	if (record_name)
		src.desc = "A fairly large record. There's a sticker on it that says \"[record_name]\"."

/obj/item/record/attack(mob/M as mob, mob/user as mob) // copied plate code
	if (user.a_intent == INTENT_HARM)
		if (M == user)
			boutput(user, "<span class='alert'><B>You smash the record over your own head!</b></span>")
		else
			M.visible_message("<span class='alert'><B>[user] smashes [src] over [M]'s head!</B></span>")
			logTheThing("combat", user, M, "smashes [src] over [constructTarget(M,"combat")]'s head! ")
		M.TakeDamageAccountArmor("head", force, 0, 0, DAMAGE_BLUNT)
		M.changeStatus("weakened", 2 SECONDS)
		playsound(src, "shatter", 70, 1)
		var/obj/O = unpool (/obj/item/raw_material/shard/glass)
		O.set_loc(get_turf(M))
		if (src.material)
			O.setMaterial(copyMaterial(src.material))
		qdel(src)
	else
		M.visible_message("<span class='alert'>[user] taps [M] over the head with [src].</span>")
		logTheThing("combat", user, M, "taps [constructTarget(M,"combat")] over the head with [src].")

ABSTRACT_TYPE(/obj/item/record/random)

/obj/item/record/random/dance_on_a_space_volcano
	name = "record - \"Dance On A Space Volcano\""
	record_name = "Dance On A Space Volcano"
	song = "sound/radio_station/dance_on_a_space_volcano.ogg"

/obj/item/record/random/adventure_1
	name = "record - \"adventure track #1\""
	record_name = "adventure track #1"
	song = "sound/radio_station/adventure_1.mod"

/obj/item/record/random/adventure_2
	name = "record - \"adventure track #2\""
	record_name = "adventure track #2"
	song = "sound/radio_station/adventure_2.s3m"

/obj/item/record/random/adventure_3
	name = "record - \"adventure track #3\""
	record_name = "adventure track #3"
	song = "sound/radio_station/adventure_3.ogg"

/obj/item/record/random/adventure_4
	name = "record - \"adventure track #4\""
	record_name = "adventure track #4"
	song = "sound/radio_station/adventure_4.ogg"

/obj/item/record/random/adventure_5
	name = "record - \"adventure track #5\""
	record_name = "adventure track #5"
	song = "sound/radio_station/adventure_5.ogg"

/obj/item/record/random/adventure_6
	name = "record - \"adventure track #6\""
	record_name = "adventure track #6"
	song = "sound/radio_station/adventure_6.mod"

/obj/item/record/random/upbeat_1
	name = "record - \"upbeat track #1\""
	record_name = "upbeat track #1"
	song = "sound/radio_station/upbeat_1.ogg"

/obj/item/record/random/upbeat_2
	name = "record - \"upbeat track #2\""
	record_name = "upbeat track #2"
	song = "sound/radio_station/upbeat_2.ogg"

/obj/item/record/random/chill_1
	name = "record - \"chill track #1\""
	record_name = "chill track #1"
	song = "sound/radio_station/chill_1.ogg"

/obj/item/record/random/chill_2
	name = "record - \"chill track #2\""
	record_name = "chill track #2"
	song = "sound/radio_station/chill_2.ogg"

/obj/item/record/random/chill_3
	name = "record - \"chill track #3\""
	record_name = "chill track #3"
	song = "sound/radio_station/chill_3.ogg"

/obj/item/record/random/chill_4
	name = "record - \"chill track #4\""
	record_name = "chill track #4"
	song = "sound/radio_station/chill_4.ogg"

/obj/item/record/january
	record_name = "january"
	song = "sound/radio_station/january.xm"

/obj/item/record/february
	record_name = "february"
	song = "sound/radio_station/february.xm"

/obj/item/record/march
	record_name = "march"
	song = "sound/radio_station/march.xm"

/obj/item/record/april
	record_name = "april"
	song = "sound/radio_station/april.xm"

/obj/item/record/may
	record_name = "may"
	song = "sound/radio_station/may.xm"

/obj/item/record/june
	record_name = "june"
	song = "sound/radio_station/june.xm"

/obj/item/record/july
	record_name = "july"
	song = "sound/radio_station/july.xm"

/obj/item/record/august
	record_name = "august"
	song = "sound/radio_station/august.xm"

/obj/item/record/september
	record_name = "september"
	song = "sound/radio_station/september.xm"

/obj/item/record/october
	record_name = "october"
	song = "sound/radio_station/october.xm"

/obj/item/record/november
	record_name = "november"
	song = "sound/radio_station/november.xm"

/obj/item/record/december
	record_name = "december"
	song = "sound/radio_station/december.xm"

/obj/item/record/spacebux // Many thanks to Camryn Buttes!!
	add_overlay = 0
	icon_state = "record_red"

ABSTRACT_TYPE(/obj/item/record/random/chronoquest)
/obj/item/record/random/chronoquest
	New()
		. = ..()
		src.desc += {" Created by <a href="https://soundcloud.com/wizardofthewestside">Chronoquest</a>."}

/obj/item/record/random/chronoquest/waystations
	record_name = "Waystations"
	name = "record - \"Waystations\""
	song = "sound/radio_station/waystations.ogg"

/obj/item/record/random/chronoquest/planets
	record_name = "Planets"
	name = "record - \"Planets\""
	song = "sound/radio_station/planets.ogg"

/obj/item/record/random/chronoquest/oh_no_evil_star
	record_name = "Oh No Evil Star"
	name = "record - \"Oh No Evil Star\""
	song = "sound/radio_station/oh_no_evil_star.ogg"

/obj/item/record/random/chronoquest/cloudskymanguy
	record_name = "Cloudskymanguy"
	name = "record - \"Cloudskymanguy\""
	song = "sound/radio_station/cloudskymanguy.ogg"

/obj/item/record/random/chronoquest/black_wing_interface
	record_name = "Black Wing Interface"
	name = "record - \"Black Wing Interface\""
	song = "sound/radio_station/black_wing_interface.ogg"

/obj/item/record/random/chronoquest/riverdancer
	name = "record - \"Riverdancer\""
	record_name = "Riverdancer"
	song = "sound/radio_station/riverdancer.ogg"

/obj/item/record/random/key_lime
	name = "record - \"key_lime #1\""
	record_name = "key lime #1"
	song = "sound/radio_station/key_lime.ogg"
	add_overlay = FALSE

	New()
		..()
		src.UpdateOverlays(new /image(src.icon, "record_6"), "recordlabel") //it should always be green because I'm so funny.

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
	song = "sound/radio_station/poo.ogg"

/obj/item/record/poo/attackby(obj/item/P as obj, mob/user as mob)
	if (istype(P, /obj/item/magnifying_glass))
		boutput(user, "<span class='notice'>You examine the record with the magnifying glass.</span>")
		sleep(2 SECONDS)
		boutput(user, "The scratch on the record, upon close examination, is actually tiny lettering. It says, <i>Fuck Discount Dan's. I hope more of your factories go under and you all drown in your toxic sewage.</i>")

/obj/item/record/atlas
	desc = "Ode to a space ship."
	song = "sound/radio_station/atlas.ogg"

/obj/item/record/honey
	desc = "A fairly large record. It's all sticky and coated in honey!"
	add_overlay = 0
	icon_state = "record_honey"
	song = "sound/radio_station/bumblebee.ogg"

/obj/item/record/christmas
	desc = "A truly nefarious and unholy record that has been banned in most of space."
	add_overlay = 0
	icon_state = "record_red"
	song = "sound/radio_station/christmassong.ogg"

/obj/item/record/honkmas
	desc = "Wow, this fruitcake record is almost as good as the real thing!"
	add_overlay = 0
	icon_state = "record_fruit"
	song = "sound/radio_station/honkmas.ogg"

/obj/item/record/clown_collection // By Arborinus. Honk!
	add_overlay = 0
	icon_state = "record_yellow"

/obj/item/record/clown_collection/honk
	song = "sound/radio_station/warriors_honk.ogg"
	color = "#DED347"

/obj/item/record/clown_collection/uguu
	song = "sound/radio_station/uguu.ogg"
	color = "#DEC647"

/obj/item/record/clown_collection/eggshell
	song = "sound/radio_station/eggshell.ogg"
	color = "#DEB947"

/obj/item/record/clown_collection/disco
	song = "sound/radio_station/disco_poo.ogg"
	color = "#DEAC47"

/obj/item/record/clown_collection/poo
	song = "sound/radio_station/core_of_poo.ogg"
	color = "#DE9F47"

// Record sets
/obj/item/storage/box/record
	name = "record sleeve"
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "sleeve_1"
	desc = "A sturdy record sleeve, designed to hold multiple records."
	max_wclass = 3
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
	spawn_contents = list(/obj/item/record/january,
	/obj/item/record/february,
	/obj/item/record/march,
	/obj/item/record/april,
	/obj/item/record/may,
	/obj/item/record/june)

/obj/item/storage/box/record/radio/two
	spawn_contents = list(/obj/item/record/july,
	/obj/item/record/august,
	/obj/item/record/september,
	/obj/item/record/october,
	/obj/item/record/november,
	/obj/item/record/december)

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

/obj/item/storage/box/record/radio/host
	desc = "A sleeve of exclusive radio station songs."

/obj/item/storage/box/record/radio/host/New()
	..()
	var/list/possibilities = concrete_typesof(/obj/item/record/random, cache=FALSE)
	possibilities = possibilities.Copy() // so we don't modify the cached version if someone else cached it I guess
	for (var/i = 1, i < 8, i++)
		var/obj/item/record/R = pick(possibilities)
		new R(src)
		possibilities -= R

// Tape deck
/obj/submachine/tape_deck
	name = "tape deck"
	desc = "A large standalone reel-to-reel tape deck."
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "tapedeck"
	anchored = 1.0
	density = 1
	var/has_tape = 0
	var/is_playing = 0
	var/obj/item/radio_tape/tape_inside = null

/obj/submachine/tape_deck/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/radio_tape))
		if(has_tape)
			boutput(user, "The tape deck already has a tape inserted!")
		else if(!is_playing)
			src.visible_message("<span class='notice'><b>[user] inserts the compact tape into the tape deck.</b></span>",
			"You insert the compact tape into the tape deck.")
			user.drop_item()
			W.set_loc(src)
			src.tape_inside = W
			src.has_tape = 1
			src.is_playing = 1
			user.client.play_music_radio(tape_inside.audio)
			/// PDA message ///
			var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
			var/datum/signal/pdaSignal = get_free_signal()
			pdaSignal.data = list("command"="text_message", "sender_name"="RADIO-STATION", "sender"="00000000", "message"="Now playing: [src.tape_inside.audio_type] for [src.tape_inside.name_of_thing].")
			pdaSignal.transmission_method = TRANSMISSION_RADIO
			if(transmit_connection != null)
				transmit_connection.post_signal(src, pdaSignal)
			//////
			sleep(6000)
			is_playing = 0

/obj/submachine/tape_deck/attack_hand(mob/user as mob)
	if(has_tape)
		if(!is_playing)
			boutput(user, "You remove the tape from the tape deck.")
			src.visible_message("<span class='notice'><b>[user] removes the tape from the tape deck.</b></span>")
			user.put_in_hand_or_drop(src.tape_inside)
			src.tape_inside = null
			src.has_tape = 0
		else
			boutput(user, "It looks like the tape is still being rewinded. You should wait a bit more before taking it out.")

// Tapes
/obj/item/radio_tape
	name = "compact tape"
	desc = "A small audio tape. Though, it looks too big to fit in an audio log."
	icon = 'icons/obj/radiostation.dmi'
	icon_state = "tape"
	w_class = 2.0
	var/audio = null
	var/audio_type = "Test"
	var/name_of_thing = "Beep boop"


/obj/item/radio_tape/advertisement
	audio_type = "Advertisement"

/obj/item/radio_tape/advertisement/grones
	name = "compact tape - 'Grones Soda'"
	audio = "sound/radio_station/grones.ogg"
	name_of_thing = "Grones Soda"

/obj/item/radio_tape/advertisement/dans_tickets
	name = "compact tape - 'Discount Dan's GTMs'"
	audio = "sound/radio_station/dans_tickets.ogg"
	name_of_thing = "Discount Dan's GTMs"

/obj/item/radio_tape/advertisement/quik_noodles
	name = "compact tape - 'Discount Dan's Quik Noodles'"
	audio = "sound/radio_station/quik_noodles.ogg"
	name_of_thing = "Discount Dan's Quik Noodles"
	desc = {"A small audio tape. It looks too big to fit in an audio log.<br>
	The music is "Palast Rock by Stefan Kartenberg (CC BY-NC 3.0)"}

/obj/item/radio_tape/advertisement/danitos_burritos
	name = "compact tape - 'Descuento Danito's Burritos'"
	audio = "sound/radio_station/danitos_burritos.ogg"
	name_of_thing = "Descuento Danito's Burritos"
	desc = {"A small audio tape. It looks too big to fit in an audio log.<br>
	The music is "Requiem for a Fish" by The Freak Fandango Orchestra (CC BY-NC 4.0)"}

/obj/item/radio_tape/advertisement/movie
	name = "compact tape - 'Movie Ad'"
	audio = "sound/radio_station/bill_movie.ogg"
	name_of_thing = "some shitty movie"

/obj/item/radio_tape/advertisement/pope_crunch
	name = "compact tape - 'Pope Crunch'"
	audio = "sound/radio_station/pope_crunch_cereal.ogg"
	name_of_thing = "Pope Crunch Cereal"
	desc = {"A small audio tape. It looks too big to fit in an audio log.<br>
	Voiceover by Puppet Master and HeadsmanStukka of the Black Pants Legion. <br>
	The music is Smooth Talker by Apoxode (CC BY 3.0)"}

/obj/item/radio_tape/advertisement/cloning_psa
	name = "compact tape - 'Cloning PSA'"
	audio = "sound/radio_station/cloning_psa.ogg"
	name_of_thing = "Cloning Public Service Announcement"
	desc = {"A small audio tape. It looks too big to fit in an audio log.<br>
	Voiceover by Cenith of the Black Pants Legion<br>
	Musical backing is "Inspretional Wave" by khalafnasirs 2020 (CC-BY-NC 3.0)"}

/obj/item/radio_tape/advertisement/captain_psa
	name = "compact tape - 'Captain's Training Program'"
	audio = "sound/radio_station/captain_training.ogg"
	name_of_thing = "Nanotrasen Captain's Training Promotional Tape"
	desc = {"A small audio tape. It looks too big to fit in an audio log.<br>
	Voiceover by Tex of the Black Pants Legion<br>
	Musical backing is "Out of Space" by Javolenus 2019 CC-BY NC 3.0"}

/obj/item/radio_tape/advertisement/security_psa
	name = "compact tape - 'Nanotrasen Security PSA'"
	audio = "sound/radio_station/security_psa.ogg"
	name_of_thing = "Security Department Public Service Announcement"
	desc = {"A small audio tape. It looks too big to fit in an audio log.<br>
	Voiceover by Squidchild of the Black Pants Legion"}

/obj/item/radio_tape/advertisement/cargonia
	name = "compact tape - 'Scuffed Compact Tape'"
	audio = "sound/radio_station/Cargonia.ogg"
	name_of_thing = "Cargo Union Advertisement <VERY ILLEGAL>"
	desc = {"A small audio tape. It looks too big to fit in an audio log.<br>
	You found this in a locked up chest in the depths. Someone went to a lot of trouble to get rid of it.<br>
	Voiceover by Tex of the Black Pants Legion<br>
	Musical Backing is "Valor" by David Fesliyan"}

/obj/item/radio_tape/audio_book
	audio_type = "Audio book"

/obj/item/radio_tape/audio_book/heisenbee
	name = "compact tape - 'The Trial of Heisenbee'"
	audio = "sound/radio_station/trial_of_heisenbee.ogg"
	name_of_thing = "The Trial of Heisenbee"

/obj/item/radio_tape/audio_book/commander_announcement
	name = "Commander's Log - 'You Got A Small Arsenal'"
	name_of_thing = "You Got A Small Arsenal"
	audio = "sound/radio_station/commander_announcement.ogg"

/obj/item/radio_tape/audio_book/commander_support
	name = "Commander's Log - 'Customer Support Ticket #121'"
	name_of_thing = "Customer Support Ticket #121"
	audio = "sound/radio_station/commander_support.ogg"

/obj/item/radio_tape/audio_book/commander_resignation
	name = "Commander's Log - 'I Quit'"
	name_of_thing = "I Quit"
	audio = "sound/radio_station/commander_resignation.ogg"

/obj/item/radio_tape/audio_book/commander_figurines
	name = "Commander's Log - 'They're Called Collectibles'"
	name_of_thing = "They're Called Collectibles"
	audio = "sound/radio_station/commander_figurines.ogg"

/obj/item/radio_tape/owl
	audio_type = "???"
	name = "compact tape - 'Owls'"
	audio = "sound/radio_station/owl.ogg"
	name_of_thing = "Owls"

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
/obj/decal/fakeobjects/cpucontroller
	name = "central processing unit"
	desc = "The computing core of the mainframe."
	icon = 'icons/obj/64x64.dmi'
	icon_state = "gannets_machine1"
	bound_width = 64
	bound_height = 64
	anchored = 1
	density = 1

/obj/decal/fakeobjects/vacuumtape
	name = "vacuum column tape drive"
	desc = "A large 9 track magnetic tape storage unit."
	icon = 'icons/obj/32x64.dmi'
	icon_state = "gannets_machine2"
	bound_width = 32
	bound_height = 64
	anchored = 1
	density = 1

/obj/decal/fakeobjects/operatorconsole
	name = "operator's console"
	desc = "The computer operating console, covered in fancy toggle swtiches and register value lamps."
	icon = 'icons/obj/32x64.dmi'
	icon_state = "gannets_machine1"
	bound_width = 32
	bound_height = 64
	anchored = 1
	density = 1

/obj/decal/fakeobjects/broadcastcomputer
	name = "broadcast server"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "gannets_machine11"
	anchored = 1
	density = 1

/obj/decal/fakeobjects/tapedeck
	name = "reel to reel tape deck"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "gannets_machine20"
	anchored = 1
	density = 1

//Books + documents
//this one isn't on the map, but it might be good to have.
/obj/item/paper/book/icarus_ovid
	name = "Mythological Stories of the Ancient Greeks"
	desc = "An old dusty book of mythology, well worn and dog-eared."
	info = {"<p>In tedious Exile now too long detain'd,<br>
Daedalus languish'd for his native Land:<br>
The Sea foreclos'd his Flight; yet thus he said;<br>
Tho' Earth and Water in Subjection laid,<br>
O cruel Minos, thy Dominion be,<br>
We'll go thro' Air; for sure the Air is free.<br>
Then to new Arts his cunning Thought applies,<br>
And to improve the Work of Nature tries.<br>
A Row of Quills in gradual Order plac'd,<br>
Rise by Degrees in Length from first to last;<br>
As on a Cliff th' ascending Thicket grows,<br>
Or, different Reeds the rural Pipe compose.<br>
Along the Middle runs a Twine of Flax,<br>
The Bottom Stems are joyn'd by pliant Wax.<br>
Thus, well compact, a hollow Bending brings<br>
The fine Composure into real Wings.</p>

<p>His Boy, young Icarus, that near him stood,<br>
Unthinking of his Fate, with Smiles pursu'd<br>
The floating Feathers, which the moving Air<br>
Bore loosely from the Ground, and wafted here and there.<br>
Or with the Wax impertinently play'd,<br>
And with his childish Tricks the great Design delay'd.<br>
The final Master-stroke at last impos'd,<br>
And now, the neat Machine compleatly clos'd;<br>
Fitting his Pinions, on a Flight he tries,<br>
And hung self-ballanc'd in the beaten Skies.<br>
Then thus instructs his Child; My Boy, take Care<br>
To wing your Course along the middle Air;<br>
If low, the Surges wet your flagging Plumes,<br>
If high, the Sun the melting Wax consumes:<br>
Steer between both: Nor to the Northern Skies,<br>
Nor South Orion turn your giddy Eyes;<br>
But follow me: Let me before you lay<br>
Rules for the Flight, and mark the pathless Way.<br>
Then teaching, with a fond Concern, his Son,<br>
He took the untry'd Wings, and fix'd 'em on;<br>
But fix'd with trembling Hands; and, as he speaks,<br>
The Tears roul gently down his aged Cheeks.<br>
Then kiss'd, and in his Arms embrac'd him fast,<br>
But knew not this Embrace must be the last.<br>
And mounting upward, as he wings his Flight,<br>
Back on his Charge he turns his aking Sight;<br>
As Parent Birds, when first their callow Care<br>
Leave the high Nest to tempt the liquid Air.<br>
Then chears him on, and oft, with fatal Art,<br>
Reminds the Stripling to perform his Part.</p>

<p>These, as the Angler at the silent Brook,<br>
Or Mountain-Shepherd leaning on his Crook,<br>
Or gaping Plowman from the Vale descries,<br>
They stare, and view 'em with religious Eyes,<br>
And strait conclude 'em Gods; since none, but they,<br>
Thro' their own azure Skies cou'd find a Way.<br>
Now Delos, Paros on the Left are seen,<br>
And Samos, favour'd by Jove's haughty Queen;<br>
Upon the Right, the Isle Lebynthos nam'd,<br>
And fair Calymne for its Honey fam'd.<br>
When now the Boy, whose childish Thoughts aspire<br>
To loftier Aims, and make him ramble higher,<br>
Grown wild and wanton, more embolden'd flies<br>
Far from his Guide, and soars among the Skies.<br>
The soft'ning Wax, that felt a nearer Sun,<br>
Dissolv'd apace, and soon began to run.<br>
The Youth in vain his melting Pinions shakes,<br>
His Feathers gone, no longer Air he takes:<br>
Oh! Father, Father, as he strove to cry,<br>
Down to the Sea he tumbled from on high,<br>
And found his Fate; yet still subsists by Fame,<br>
Among those Waters that retain his Name.<br>
The Father, now no more a Father, cries,<br>
Ho Icarus! where are you? as he flies;<br>
Where shall I seek my Boy? he cries again,<br>
And saw his Feathers scatter'd on the Main.<br>
Then curs'd his Art; and fun'ral Rites confer'd,<br>
Naming the Country from the Youth interr'd.<br>
A Partridge, from a neighb'ring Stump, beheld<br>
The Sire his monumental Marble build;<br>
Who, with peculiar Call, and flutt'ring Wing,<br>
Chirpt joyful, and malicious seem'd to sing:</p>

<p>The only Bird of all its Kind, and late<br>
Transform'd in Pity to a feather'd State:<br>
From whence, O Daedalus, thy Guilt we date.<br>
His Sister's Son, when now twelve Years were past,<br>
Was, with his Uncle, as a Scholar plac'd;<br>
The unsuspecting Mother saw his Parts,<br>
And Genius fitted for the finest Arts.<br>
This soon appear'd; for when the spiny Bone<br>
In Fishes Backs was by the Stripling known,<br>
A rare Invention thence he learnt to draw,<br>
Fil'd Teeth in Iron, and made the grating Saw.<br>
He was the first, that from a Knob of Brass<br>
Made two strait Arms with widening Stretch to pass;<br>
That, while one stood upon the Center's Place,<br>
The other round it drew a circling Space.<br>
Daedalus envy'd this, and from the Top<br>
Of fair Minerva's Temple let him drop;<br>
Feigning that, as he lean'd upon the Tow'r,<br>
Careless he stoop'd too much, and tumbled o'er.<br>
The Goddess, who th' Ingenious still befriends,<br>
On this Occasion her Assistance lends;<br>
His Arms with Feathers, as he fell, she veils,<br>
And in the Air a new-made Bird he sails.<br>
The Quickness of his Genius, once so fleet,<br>
Still in his Wings remains, and in his Feet:<br>
Still, tho' transform'd, his ancient Name he keeps,<br>
And with low Flight the new-shorn Stubble sweeps.<br>
Declines the lofty Trees, and thinks it best<br>
To brood in Hedge-rows o'er it's humble Nest;<br>
And, in Remembrance of the former Ill,<br>
Avoids the Heights and Precipices still.</p>

<p>At length, fatigu'd with long laborious Flights,<br>
On fair Sicilia's Plains the Artist lights;<br>
Where Cocalus the King, that gave him Aid,<br>
Was, for his Kindness, with Esteem repaid.<br>
Athens no more her doleful Tribute sent,<br>
That Hardship gallant Theseus did prevent;<br>
Their Temples hung with Garlands, they adore<br>
Each friendly God, but most Minerva's Pow'r:<br>
To her, to Jove, to All, their Altars smoak,<br>
They each with Victims and Perfumes invoke.<br>
Now talking Fame, thro' every Graecian Town,<br>
Had spread, immortal Theseus, thy Renown.<br>
From him, the neighb'ring Nations in Distress,<br>
In suppliant Terms implore a kind Redress.</p>
"}

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
