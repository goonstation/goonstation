/**
Lunar Moon Museum Zone
Contents:
	Moon Areas
	Moon turfs
	Moon emails
	A tourguid bud
	Museum objects
	Control Panel Puzzle
	A li'l fake bomb for an exhibit.
**/

/area/moon
	name = "moon"
	icon_state = "blue"
	filler_turf = "/turf/unsimulated/floor/lunar"
	requires_power = 0
	force_fullbright = 0
	ambient_light = rgb(0.9 * 255, 0.9 * 255, 0.9 * 255)
	sound_group = "moon"

/area/moon/underground
	name = "Lunar Underground"
	icon_state = "orange"
	ambient_light = rgb(0.5 * 255, 0.5 * 255, 0.5 * 255)

/area/moon/underground/hemera
	name = "Hemera Lunar Office"
	icon_state = "yellow"

/area/moon/museum
	name = "Museum of Lunar History"
	icon_state = "purple"
	ambient_light = rgb(0.5 * 255, 0.5 * 255, 0.5 * 255)
	sound_loop = 'sound/ambience/industrial/LavaPowerPlant_Rumbling1.ogg'
	sound_loop_vol = 60

/area/moon/museum/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_AREA_PROCESS)

/area/moon/museum/disposing()
	STOP_TRACKING_CAT(TR_CAT_AREA_PROCESS)
	. = ..()

/area/moon/museum/area_process()
	if(prob(20))
		src.sound_fx_2 = pick('sound/ambience/loop/Wind_Low.ogg',\
		'sound/ambience/station/Machinery_Computers2.ogg',\
		'sound/ambience/station/Machinery_Computers3.ogg')

		for(var/mob/living/carbon/human/H in src)
			H.client?.playAmbience(src, AMBIENCE_FX_2, 60)

/area/shuttle/lunar_elevator/museum/upper
	icon_state = "shuttle"
	force_fullbright = 0
	name = "Elevator"

/area/shuttle/lunar_elevator/museum/lower
	icon_state = "shuttle2"
	force_fullbright = 0
	name = "Elevator"

/area/shuttle/lunar_elevator/hemera/upper
	icon_state = "shuttle"
	force_fullbright = 0
	name = "Elevator"

/area/shuttle/lunar_elevator/hemera/lower
	icon_state = "shuttle2"
	force_fullbright = 0
	name = "Elevator"

/area/moon/museum/west
	name = "Museum of Lunar History West Wing"
	icon_state = "red"

/area/moon/museum/giftshop
	name = "Museum of Lunar History Gift Shop"
	icon_state = "green"

/area/moon/monorail_station/museum
	icon_state = "shuttle"

/area/moon/monorail_station/district
	icon_state = "shuttle2"

/turf/unsimulated/floor/lunar_shaft
	name = "open elevator shaft"
	icon_state = "moon_shaft"
	desc = "An elevator shaft.  It's probably a bad idea to try to walk over this, unless you're Wile E. Coyote and don't look down."
	pathable = 0
	var/isHemera = 0

	New()
		..()
		SPAWN(0.5 SECONDS)
			if (istype( get_step(src, WEST), src.type))
				if (istype( get_step(src, NORTH), src.type))
					//Lower right
					set_dir(4)

				else
					//Upper right
					set_dir(1)

			else
				if (istype( get_step(src, NORTH), src.type))
					//Lower left
					set_dir(8)

				else
					//Upper left
					set_dir(2)


	Entered(atom/A as mob|obj)
		if (istype(A, /obj/overlay/tile_effect) || istype(A, /mob/dead) || istype(A, /mob/wraith) || istype(A, /mob/living/intangible))
			return ..()

		var/turf/T = pick_landmark(isHemera ? LANDMARK_FALL_MOON_HEMERA : LANDMARK_FALL_MOON_MUSEUM)
		if (T)
			fall_to(T, A)
			return

		else
			..()

/turf/unsimulated/floor/lunar
	name = "lunar surface"
	desc = "Regolith.  Wait, isn't moon dust actually really sticky, just from how incredibly dry it is?"
	icon_state = "lunar"
	carbon_dioxide = 0
	nitrogen = 0
	oxygen = 0
	fullbright = 1

	New()
		..()
		//icon_state = "moon[rand(1,3)]"

	cavern
		name = "lunar cavern"
		oxygen = MOLES_O2STANDARD
		nitrogen = MOLES_N2STANDARD
		fullbright = 0

/turf/unsimulated/wall/setpieces/lunar
	name = "moon rock"
	desc = "More regolith, now in big solid chunk form!"
	icon = 'icons/turf/walls.dmi'
	icon_state = "lunar"
	plane = PLANE_NOSHADOW_ABOVE // shadow makes it look grody with current sprites that include the floor
	carbon_dioxide = 0
	nitrogen = 0
	oxygen = 0
	fullbright = 1


/turf/unsimulated/wall/setpieces/leadwall/white/lunar
	name = "Shielded Wall"
	desc = "Painted white, of course."


/turf/unsimulated/wall/setpieces/leadwindow/white
	name = "Shielded Wall"
	desc = "Painted white, of course."
	icon_state = "leadwindow_white_1"


/obj/item/clothing/suit/esdjacket
	name = "\improper ESD jacket"
	desc = "A cleanroom jacket designed to prevent the build-up of electrostatic charge."
	icon_state = "esdcoat"
	item_state = "esdcoat"
	body_parts_covered = TORSO|ARMS

	setupProperties()
		..()
		setProperty("conductivity", 0.2)

/obj/storage/closet/esdjacket
	name = "\improper ESD Protective Equipment"
	desc = "A locker intended to carry protective clothing."
	icon_state = "syndicate"
	icon_opened = "syndicate-open"
	icon_closed = "syndicate"
	spawn_contents = list(/obj/item/clothing/suit/esdjacket,\
	/obj/item/clothing/suit/esdjacket)

/datum/computer/file/record/moon_mail
	New()
		..()
		src.name = "[copytext("\ref[src]", 4, 12)]GENERIC"

	renovation_it
		New()
			..()
			fields = list("MLH_INTERNAL",
"*ALL",
"HJANSSENAA@WMLH",
"JWILLETMM@WMLH",
"MEDIUM",
"Network Outages",
"Due to the ongoing renovations, connections between museum sections may be temporarily disrupted.",
"This includes connections to the central mainframe.  Local control systems will remain operative.",
"We apologize for the inconvenience.",
"Regards",
"Harold Janssen",
"World Museum of Lunar History Information Technology Services")

	no_journalists
		New()
			..()
			fields = list("MLH_INTERNAL",
"*SEC",
"LOCALHOST",
"JWILLETMM@WMLH",
"HIGH",
"SECURITY LEVEL ELEVATED",
"The security level has been automatically elevated to GUARDED",
"due to arrival of potential threat agent.",
"Threat agent designation:  Hartman, Wallace A. ",
" DOB: 03/12/04",
" OCCUPATION: Journalist",
" Reason for inclusion in threat agent database:",
" Production of articles unfavorable to NT corporate interests",
" May attempt to produce material detrimental to museum profitability",
"",
"Recommended action: Detention of agent and confiscation of recording materials.")

	no_radicals
		New()
			..()
			fields = list("MLH_INTERNAL",
"*SEC",
"LOCALHOST",
"JWILLETMM@WMLH",
"HIGH",
"SECURITY LEVEL ELEVATED",
"The security level has been automatically elevated to GUARDED",
"due to arrival of potential threat agent.",
"Threat agent designation:  Leary, Samantha H. ",
" DOB: 11/21/22",
" OCCUPATION: Office Worker",
" Reason for inclusion in threat agent database:",
" Participation in leftist / anticorporate group WEATHER OUTERSPACE",
" Production of material expressing these views as recently as:07 MAY 2045",
"",
"Recommended action: Detention of agent.")

	ex_employee
		New()
			..()
			fields = list("MLH_INTERNAL",
"*SEC",
"LOCALHOST",
"JWILLETMM@WMLH",
"HIGH",
"SECURITY LEVEL ELEVATED",
"The security level has been automatically elevated to GUARDED",
"due to arrival of potential threat agent.",
"Threat agent designation:  Sullivan, Gerald D. ",
" DOB: 08/01/17",
" OCCUPATION: UNEMPLOYED",
" Reason for inclusion in threat agent database:",
" Former museum employee.  Employment terminated 07/31/52 due",
" to budget cuts.",
" May make revenge attempt.",
"",
"Recommended action: Monitor agent, full measures authorized if",
"agent turns violent or attempts to enter secure area.")

	saw_a_thing
		New()
			..()
			fields = list("MLH_GENERAL",
"*SEC",
"SHUGHESAF@WMLH",
"JWILLETMM@WMLH",
"LOW",
"something fucked up",
"johnny, i just saw something fucked up and I don't know who to talk to",
"okay, so I'm in the booth, right, and the only person outside is this suit",
"inspecting the renovations, this tiny indian chick",
"i'm only half paying attention and then CRASH and I look out and a bunch of",
"gantry shit has fallen on her and like there's this rebar going through her",
"shoulder. I'm all \"oh shit\" and reach for the call button but then she",
"just kinda pulls it out?? like, calmly pulls out this fuckin jagged rebar",
"that's taller than she is?  And its not the craziest part, like, she has this",
"hole in her shoulder and then all the fuckin blood just sucks back into it",
"and the hole is fuckin gone like nothing even happened",
"",
"jesus christ im glad the booth window is dark tinted because i don't",
"think she knew I was there",
"what kind of fuckin monster am I stuck in here with")

	saw_a_thing2
		New()
			..()
			fields = list("MLH_GENERAL",
"*SEC",
"SHUGHESAF@WMLH",
"JWILLETMM@WMLH",
"LOW",
"re: re: something fucked up",
"what do you mean 'yeah but is she cute' you dumb fucker")


	weird_guest
		New()
			..()
			fields = list("MLH_GENERAL",
"*ALL",
"ZGARRETTFN@WMLH",
"JWILLETMM@WMLH",
"LOW",
"Pretty Weird Guest",
"Hey Johnny, it's a shame you're on first shift because we just had the weirdest",
"fucker come by.  Dude came in dressed like some kind of hobo biker or whatever,",
"absolutely reeking of cheap booze.  We fixed him up for a \"random\" search and",
"jesus christ the dude was like a noah's ark of narcotics.  But here's the weird",
"part:  He had an NT employee ID on him, though it looked like he left it in a",
"bathtub for a week, and hey the thing still scanned...and the computer refused",
"to show any information, it's all confidential (???), and we were told to let him",
"go.  He staggered around for an hour mumbling to himself and I swear that every",
"security camera was locked on him the whole time.",
"Maybe this was a test and he's from some kinda secret shopper kinda thing? For",
"security?  I have no fuckin idea.",
"",
"Anyway, see you at the tournament.  Laters, Zack.")

	weirder_guest
		New()
			..()
			fields = list("MLH_GENERAL",
"*ALL",
"ZGARRETTFN@WMLH",
"JWILLETMM@WMLH",
"LOW",
"Another Weirdo",
"Hey Johnny, I must be cursed or something because another weirdo showed up.",
"Some dude in a torn white straightjacket thing, ranting about angels and ",
"screaming.  Maybe an escaped mental patient, but the weird thing is that he",
"showed up inside a sealed exhibit.  We got him out and took him to the",
"holding room.  Here's the even weirder thing: we left him in there alone for",
"like 30 seconds, and he just disappeared.  Not escaped, disappeared.  From a",
"locked room.  We're going to go over the security tapes, but he's not in the",
"museum.  What's up with all this spooky shit lately?")


	earthrise00
		New()
			..()
			fields = list("LNN_GENERAL",
"*ALL",
"NEWSWIRE@LNN",
"LNNSUBS@LNN",
"HIGH",
"Earthrise Killer Slays Again",
"A set of human remains discovered late last week beneath the Serenity Tram",
"Station has been identified as atmospheric technician Marie Hanford.",
"Hanford, 38, was a mother of three and a Lunaport native. She had been",
"reported missing three weeks earlier. Hanford represents a shift in victims",
"for the Earthrise Killer, who until now has exclusively targeted the homeless",
"and destitute. Like those victims, the remains are desiccated, mummified.",
"From beneath a cloud of fear, Lunaport citizens demand answers from the LPPD",
"and Administrator Hollenthal. The MNX system has near-omnipresent surveillance,",
"but as soon as society's most vulnerable are threatened it becomes plagued",
"with sensor faults, network outages, and data loss. Is the city leadership",
"uninterested in investigating someone cleansing the city of \"undesirables\"?")

/obj/item/audio_tape/earthrise
	New()
		..()

		messages = list("-fucking idiot?  I can't keep cleaning up after you every time you decide to go loud.  Do you have any idea how difficult you are making my job?!",
		"*some kind of terrible laughter*",
		"Are you fucking serious.",
		"you HAVe wWORN THEe mask they gAVE YOu for so LONG, youu thinK YOU'RE ONE of THEM",
		"Do you even remember why WE ARE EVEN FUCKING HERE?  WHAT WE ARE SUPPOSED TO DO?",
		"*more terrible laughter.  Seriously, it's like a crowd is trying to laugh together and all of them have had their tongues removed.*",
		"WE Do noTT CAre whAT THOSE..INsecTS..exPeCT fFrom uS",
		"MaaaYBE if yOU WaNT TO be..ONE..of them, theN MAaaYBE  YOUuu  wilL  TAssttee   liikE   THEM!!",
		"*crashing noises, a..roar?  Like a whole bunch of weird space lions roaring simultaneously??*",
		"Oh jesus God",
		"Oh fuck no no no NO ARE YOU SHITTING ME",
		"*that awful laughter.  It's very unpleasant.*",
		"run!  RUN!  aS IF we WOULD conSUmE YOUr poISon flESH!",
		"...  speaKING OF fLESH, We smELL YOU TOo, frESH MeaT",
		"oh shit oh shit OH SHIT OH-",
		"*crunch; thrump; crackle*",
		"*static*")
		speakers = list("Female voice",
		"???!!",
		"Female voice",
		"???!!",
		"Female voice",
		"???!!",
		"???!!",
		"???!!",
		"!!!!!",
		"Male voice, near microphone",
		"Female voice",
		"???!!",
		"???!!",
		"???!!",
		"Male voice, near microphone",
		"???",
		"???")

/obj/item/disk/data/fixed_disk/lunar
	New()
		..()

		var/datum/computer/folder/currentFolder = new /datum/computer/folder {name="mails";} (src)
		src.root.add_file(currentFolder)

		currentFolder.add_file( new /datum/computer/file/record/moon_mail/renovation_it (src) )
		currentFolder.add_file( new /datum/computer/file/record/moon_mail/no_journalists (src) )
		currentFolder.add_file( new /datum/computer/file/record/moon_mail/no_radicals (src) )
		currentFolder.add_file( new /datum/computer/file/record/moon_mail/ex_employee (src) )
		currentFolder.add_file( new /datum/computer/file/record/moon_mail/saw_a_thing (src) )
		currentFolder.add_file( new /datum/computer/file/record/moon_mail/saw_a_thing2 (src) )
		currentFolder.add_file( new /datum/computer/file/record/moon_mail/weird_guest (src) )
		currentFolder.add_file( new /datum/computer/file/record/moon_mail/weirder_guest (src) )

		currentFolder = new /datum/computer/folder {name="bin";} (src)
		src.root.add_file(currentFolder)

		currentFolder.add_file( new /datum/computer/file/terminal_program/email (src) )

		src.root.add_file( new /datum/computer/file/terminal_program/secure_records {req_access = list(list(999));} (src) )

/obj/machinery/computer3/generic/lunarsec
	name = "Security computer"
	icon_state = "datasec"
	base_icon_state = "datasec"
	setup_drive_type = /obj/item/disk/data/fixed_disk/lunar
	setup_starting_peripheral1 = /obj/item/peripheral/network/powernet_card


/obj/item/audio_tape/lunar_01
	New()
		..()

		messages = list("This the stuff from that journo?",

"Yeah, you want anything?  You, uh, have any interest in photography?",
"How about a nice microphone?  Your kid still have that band?",

"Ugh, yeah.  \"Thanks for the microphone, dad, now let me sing about how totally unfair and lame you are all the time.\"",
"No thanks.",

"So, did you hear that they're going to try and, uh, move the Channel closer to Earth?",

"Can they even do that?  How the hell do you move a wormhole?",
"I sucked at high school physics but that just sounds like it breaks some rule.",

"Well, it's got those solid bits generating it or whatever, don't it?  Maybe they pull that?",
"I hope they don't, personally.  Who the hell is going to come to the moon if they can go right through to a goddamn plasma goldmine without travelling for months?",

"Maybe they want to see the, um.  Fuck if I know, man.")

		speakers = list("Male voice", "Other male voice", "Other male voice", "Male voice", "Male voice", "Other male voice", "Male voice", "Male voice", "Other male voice", "Other male voice", "Male voice")

/obj/item/device/audio_log/lunar_01

	New()
		..()
		src.tape = new /obj/item/audio_tape/lunar_01(src)

/obj/item/device/audio_log/lunar_02

	New()
		..()
		src.tape = new /obj/item/audio_tape/earthrise(src)

/obj/machinery/bot/guardbot/old/tourguide/lunar
	name = "Molly"
	desc = "A PR-4 Robuddy. These are pretty old, guess the museum doesn't change often.  This one has a little name tag on the front labeled 'Molly'"
	setup_default_startup_task = /datum/computer/file/guardbot_task/tourguide/lunar
	no_camera = 1
	setup_charge_maximum = 3000
	setup_charge_percentage = 100
	flashlight_lum = 4

	New()
		..()

		SPAWN(1 SECOND)
			if (src.botcard)
				src.botcard.access += 999


//"Oh, hello!  I apologize, I wasn't expecting guests before the renovations were done!  Welcome to the Museum of Lunar History!"
//"Before we begin, there is a request that all guests from Soviet bloc countries move down the hall to my right for special screening."
//"This, um, includes those from Zvezda.  Even if you have a day pass.  I'm sorry, I hope this isn't too much of a bother!"

//"Nanotrasen employees may be eligible for an employee discount.  Now checking Museum Central, please hold..."
//"Oh, I'm sorry.  Your position is not eligible.  Actually, um, well this is weird."
//"There is a log indicating that all employees of Research Station #13 are to be charged 10% extra.  I've never seen that before.  Huh."

//"FAAE or, as it is commonly called, Plasma, was first discovered here on the moon in 1969."
//"It's not actually native to the moon, though!  It was discovered embedded in the site of a meteorite impact."

//"This is the actual, genuine recreation of the site where Neil Armstrong first walked on the moon!  Of course, it now sits much lower due to extensive strip mining."
//"As you have selected the surface tour option, we will get to walk in Neil's reconstructed footprints!  Wow!  Please, ensure your helmets are latched and follow me through the airlock in an orderly manner!"

//"This is a model of the NASA LESA base, the first permanent lunar base.  Construction finished in fall 1971 and it wasn't decommissioned until 1996!"
//"It was the main site for plasma mining before Nanotrasen received mineral rights."

//"I hope I'm around for the centennial!"

//"This is Yuri Gagarin, the first man to go to outer space. He orbited the Earth on April 12, 1961. He um, died. MOVING ON"

//"This exhibit remembers the 2004 Lunar Port Hostage Crisis, where the primary spaceport was seized for a terrifying four days by the Space Irish Republican Army.|pIn the aftermath, laws were passed boosting the size and capability of corporate security forces--boosting our safety without violating the 1967 Outer Space Treaty!"


//Lunar underground stuff:
//Um, this isn't part of the tour.  The transit station is technically owned by the city, not the museum.
//I guess I could narrate?  I um, haven't ever been in the tunnels before.

//This is a tramway tunnel.  The tram system is the oldest part of the city and runs beneath all of Lunaport.
//Walking in these tunnels is a bad idea because, you know, there are trams that go by.  Really wide trains.

//Another reason that walking in these tunnels is a bad idea is that they're haunted.


//


//There is a house on Luna that they call the Rising Sun. It's been the ruin of many a poor bud and God, I know I'm one.

//Oh, this is an office building, um...Hemera!  Oh man, these guys used to do all kind of secret science stuff. Before Nanotrasen drove them out of business, I mean.


//Whoa, hey!  Hey!  What are you doing?  You should be ashamed of yourselves!  I'm guessing that you've been alone here for a while, and that's really lousy, but there's no need to take it out on innocent tourists!

//Oh jeez, it's my boss.  HELLO SIR! Yes I know I'm not supposed to be here and I'm really sorry, but-
//Oh, it's okay?  Uh....okay, thank you sir.

//That was MNX-17.  I guess they don't mind us being here?  Too badly??

/obj/machinery/navbeacon/lunar
	name = "tour beacon"
	freq = 1441

	tour0
		name = "tour beacon - start"
		location = "tour0"
		codes_txt = "tour;next_tour=tour1;desc=Oh, hello!  I apologize, I wasn't expecting guests before the renovations were done!  Welcome to the Museum of Lunar History!  Before we begin, there is a request that all guests from Soviet bloc countries move down the hall to my right for special screening.  This, um, includes those from Zvezda.  Even if you have a day pass.  I'm sorry, I hope this isn't too much of a bother!"

	tour1
		location = "tour1"
		codes_txt = "tour;next_tour=tour2;desc=FAAE or, as it is commonly called, Plasma, was first discovered here on the moon in 1969.  It's not actually native to the moon, though!  It was discovered embedded in the site of a meteorite impact, extending down really far, almost like it grew outward!|pBut it didn't, because plasma crystals can't grow, ha ha..|pIt makes sense that more plasma was found in the asteroid belt.  Oh, and through the Channel, um, as much as weird holes in space time make sense."

	tour2
		location = "tour2"
		codes_txt = "tour;next_tour=tour3;desc=Lunar plasma deposits were almost entirely in crystalline form.  Mining efforts went pretty slowly before Nanotrasen arrived!"

	tour3
		location = "tour3"
		codes_txt = "tour;next_tour=tour4;desc=Nanotrasen, then the newly-diversifying National Notary Supply Company, first acquired plasma samples from the Apollo missions through connections to this man, the visionary Victor Jam, head of the Senate Committee on Aeronau--|pOh, um, I guess this is down for renovations.  Nevermind."

	tour4
		location = "tour4"
		codes_txt = "tour;next_tour=tour5;desc=This is the site of our star exhibit, the Apollo 11 Experience!  Well, it will be the star when renovations are done and it has more displays and material.  Eventually.|pI'm really sorry that it isn't done yet.  Did I mention that?"

	tour5
		location = "tour5"
		codes_txt = "tour;next_tour=tour6;desc=Outside that window is the actual, genuine recreation of the site where Neil Armstrong first walked on the moon!  Of course, it now sits much lower due to extensive strip mining.|pAs you have selected the surface tour option, we will get to walk in Neil's reconstructed footprints!  Wow!  Please, ensure your helmets are latched and follow me through the airlock in an orderly manner!"

	tour6
		location = "tour6"
		codes_txt = "tour;next_tour=tour7;desc=Again, please make sure your suit is secured!  As I understand, air is kinda important."

	tour7
		location = "tour7"
		New()
			var/goofy_story = pick_string("lunar.txt", "mary_stories")
			codes_txt = "tour;next_tour=tour8;desc=This is the lunar surf..oh! You probably can't hear me, being that we are outside and my audio systems aren't hooked to the radio.  Ha ha.  I guess I can just say anything I want now.  [goofy_story]"
			..()

	tour8
		location = "tour8"
		codes_txt = "tour;next_tour=tour9;desc=Wow, That sure was fun!  And nobody was hurt, which is important.  Please disregard this message if anyone was hurt or did not have fun."

	tour9
		location = "tour9"
		codes_txt = "tour;next_tour=tour10;desc=This is a model of the NASA LESA base, the first permanent lunar base.  Construction finished in fall 1971 and it wasn't decommissioned until 1996!|pIt was the main site for plasma mining before Nanotrasen received mineral rights.|pThe base accomplished a great deal of scientific discovery and answered age-old questions, such as \"is the moon made of cheese?\" and \"is the moon full of tiny little men named Gary?\""

	tour10
		location = "tour10"
		codes_txt = "tour;next_tour=tour11;desc=Oh, um, I guess this compartment is sealed.  And decompressed.  Okay then.  That just covers the spaceport that became the city.  Nothing important..."

	tour11
		location = "tour11"
		codes_txt = "tour;next_tour=tour12;desc=This is also normally open.  And working.  I'll try to get your ticket fees refunded because this is just completely unacceptable."

	tour12
		location = "tour12"
		codes_txt = "tour;next_tour=tour13;desc=Oh, the Lunaport exhibits are still in this hall!  Good!"

	tour13
		location = "tour13"
		codes_txt = "tour;next_tour=tour14;desc=This exhibit remembers the 2004 Lunar Port Hostage Crisis, where the primary spaceport was seized for a terrifying four days by the Space Irish Republican Army.|pIn the aftermath, laws were passed boosting the size and capability of corporate security forces--boosting our safety without violating the 1967 Outer Space Treaty!"

	tour14
		location = "tour14"
		codes_txt = "tour;next_tour=tour15;desc=This exhibit is on Wallace Jam, the longest-serving administrator of the Lunaport, during the economic boom times of 2001 to 2024.  Please note the whimsical bag of jellybeans on his desk.  He was known for throwing them at people."

	tour15
		location = "tour15"
		codes_txt = "tour;next_tour=tour16;desc=This is the MNX-12, the first master computer of Lunaport, operational from the 2021 administration sector expansion until 2041.  It managed a ton of tasks across the growing city.|pThis was Thinktronic Data System's first big contract with Nanotrasen!  Fun fact: the first robuddy United States senator, Lloyd-019, started out working under MNX in 2031!"

	tour16
		location = "tour16"
		codes_txt = "tour;next_tour=tour17;desc=This is Greg, also affectionately called \"Lousy Greg,\" beloved town character known for...laying down apparently?  Um, maybe this would be a good time to hit the gift shop?  Yes."

	tour17
		location = "tour17"
		codes_txt = "tour;"

#define NT_DISCOUNT   (1<<0)
#define NT_CLOAKER    (1<<1)
#define NT_OTHERGUIDE	(1<<2)
#define NT_PONZI      (1<<3)
#define NT_SPY        (1<<4)
#define NT_BILL       (1<<5)
#define NT_BEE        (1<<6)
#define NT_SOLARIUM   (1<<7)
#define NT_CHEGET     (1<<8)
#define NT_SOVBUDDY   (1<<9)

#define NT_HEMERA     (1<<0)
#define NT_MNX        (1<<1)
#define NT_RISING_SUN (1<<2)

#define MAPTEXT_PAUSE (5 SECONDS)
#define FOUND_NEAT(FLAG) src.distracted = TRUE; src.neat_things |= FLAG; SPAWN(0)
#define END_NEAT sleep(MAPTEXT_PAUSE*2); src.distracted = FALSE

/datum/computer/file/guardbot_task/tourguide/lunar

	wait_for_guests = 1

	var/neat_things_underground = 0
	var/has_been_underground = 0

	look_for_neat_thing()
		var/area/ourArea = get_area(src.master)
		if (istype(ourArea, /area/moon/underground))
			if (!has_been_underground)
				has_been_underground = TRUE
				src.distracted = TRUE
				master.speak("Um, this isn't part of the tour.  The transit station is technically owned by the city, not the museum.")
				SPAWN(5 SECOND)
					if (master)
						master.speak("I guess I could narrate?  I um, haven't ever been in the tunnels before.")
					src.distracted = FALSE

			if (!(neat_things_underground & NT_HEMERA) && istype(ourArea, /area/moon/underground/hemera))
				src.distracted = TRUE
				neat_things_underground |= NT_HEMERA

				speak_with_maptext("Oh, this is an office building, um...Hemera!  Oh man, these guys used to do all kind of secret science stuff. Before Nanotrasen drove them out of business, I mean.")
				src.distracted = FALSE
				return

			if (!(neat_things_underground & NT_MNX))
				var/obj/machinery/embedded_controller/radio/maintpanel/MNXpanel = locate("MNXpanel") in view(7, master)
				if (istype(MNXpanel))
					src.distracted = TRUE
					neat_things_underground |= NT_MNX
					//todo
					src.distracted = FALSE
					return

			if (prob(1) && prob(5) && !(neat_things_underground & NT_RISING_SUN))
				src.distracted = TRUE
				neat_things_underground |= NT_RISING_SUN

				master.speak("There is a house on Luna that they call the Rising Sun.")
				SPAWN(5 SECOND)
					if (master)
						master.speak("It's been the ruin of many a poor bud and God, I know I'm one.")
					src.distracted = FALSE
			//todo

			return

		if (istype(ourArea, /area/solarium) && !(src.neat_things & NT_SOLARIUM))
			FOUND_NEAT(NT_SOLARIUM)
				master.speak("Huh, this place is weird!  This is some ship and that's our sun, right?")
				if (prob(25))
					if (master)
						speak_with_maptext("I, um, am going to need to go back to work.  My shift isn't over yet.")
				END_NEAT
			return

		for (var/atom/movable/AM in view(7, master))
			if (ishuman(AM))
				var/mob/living/carbon/human/H = AM
				if (!(src.neat_things & NT_BILL) && cmptext(H.real_name, "shitty bill"))
					FOUND_NEAT(NT_BILL)
						master.visible_message("<b>[master]</b> points at [H].")
						speak_with_maptext("Oh no, not you again.  Uh, I mean...hey...guyyy.")
						END_NEAT
					return


				if (!(src.neat_things & NT_DISCOUNT) && !isdead(H) && (istype(H.wear_id, /obj/item/card/id) || (istype(H.wear_id, /obj/item/device/pda2) && H.wear_id:ID_card)))
					FOUND_NEAT(NT_DISCOUNT)
						speak_with_maptext("Nanotrasen employees may be eligible for an employee discount.  Now checking Museum Central, please hold...")
						sleep(5.5 SECONDS)
						if (master)
							speak_with_maptext("Oh, I'm sorry.  Your position is not eligible.  Actually, um, well this is weird.")
						sleep(5.8 SECONDS)
						if (master)
							speak_with_maptext("There is a log indicating that all employees of Research Station #13 are to be charged 10% extra.  I've never seen that before.  Huh.")
						END_NEAT
					return

				if (!(src.neat_things & NT_CLOAKER) && H.invisibility > INVIS_NONE)
					FOUND_NEAT(NT_CLOAKER)
						speak_with_maptext("This is a reminder that cloaking technology is illegal within the inner solar system.  Please remain opaque to the visible spectrum as a courtesy to your fellow guests.  Thanks!")
						END_NEAT
					return

				if (!(src.neat_things & NT_PONZI) && (locate(/obj/item/spacecash/buttcoin) in AM.contents))
					FOUND_NEAT(NT_PONZI)
						speak_with_maptext("Um, I'm sorry [AM], we do not accept blockchain-based cryptocurrency as payment.  You aren't one of those guys who yell about gold on the apollo flag or something, right?")
						H.unlock_medal("To the Moon!",1)
						END_NEAT
					return

			if (istype(AM, /obj/machinery/bot/guardbot) && AM != src.master)
				if (istype(AM, /obj/machinery/bot/guardbot/old/tourguide) && !(src.neat_things & NT_OTHERGUIDE))
					FOUND_NEAT(NT_OTHERGUIDE)
						src.master.visible_message("<b>[master]</b> nods professionally at [AM].<br>Well, really it's more of a shake from suddenly halting the drive motors, but you get the intent.")

						animate(master, pixel_x = -4, time = 10, loop = 1, easing = SINE_EASING)

						animate(pixel_x = 0, transform = matrix(10, MATRIX_ROTATE), time = 10, loop = 1, easing = SINE_EASING)
						animate(transform = matrix(-10, MATRIX_ROTATE), time = 10, loop = 1, easing = SINE_EASING)
						END_NEAT
					return

				if (istype(AM, /obj/machinery/bot/guardbot/soviet) && !(src.neat_things & NT_SOVBUDDY))
					FOUND_NEAT(NT_SOVBUDDY)
						speak_with_maptext("Oh, um, hi.  So are you one of those Russian robuddies?  Nice to meet you..?")
						sleep(5 SECOND)
						if (src.master)
							var/area/masterArea = get_area(src.master)
							if (istype(masterArea, /area/russian) || istype(masterArea, /area/salyut) || istype(masterArea, /area/hospital/samostrel))
								src.master.speak("I hope they don't ask for a travel visa...")
							else if (istype(masterArea, /area/moon))
								src.master.speak("You um, don't have to visit the security annex.  That's for humans.  Oh, also fruit.  If you have any fruit or seeds you need to check that in.")
							else
								src.master.speak("Is this one of those \"Khrushchev in a supermarket\" things?")
						END_NEAT
					return

			if (istype(AM, /obj/critter/moonspy) && !(src.neat_things & NT_SPY))
				FOUND_NEAT(NT_SPY)
					master.visible_message("<b>[master]</b> points at [AM].")
					speak_with_maptext("Attention guests, there appears to be a coat rack or something available if needed.")
					sleep(5 SECOND)
					if (src.master)
						speak_with_maptext("You know, because of all the coats that you are clearly wearing.")
					END_NEAT
				return

			if (istype(AM, /obj/critter/domestic_bee) && !(src.neat_things & NT_BEE))
				FOUND_NEAT(NT_BEE)
					master.visible_message("<b>[master]</b> points at [AM].")
					speak_with_maptext("Ah, a space bee!  Space bees count as minors under 12 for the purposes of ticket pricing.")
					END_NEAT
				return

			if ((istype(AM, /obj/item/luggable_computer/cheget) || istype(AM, /obj/machinery/computer3/luggable/cheget)) && !(src.neat_things & NT_CHEGET))
				FOUND_NEAT(NT_CHEGET)
					speak_with_maptext("Huh, what's with the briefcase?  Did that come out of the security annex?  Somebody should probably call security or the embassy or something.")
					sleep(5.5 SECONDS)
					if (src.master)
						speak_with_maptext("I think they dealt with some kind of briefcase key the week before renovations started?  There's some sad office worker out there right now.")
					END_NEAT
				return

		//wip

		return

	task_input(var/input)
		if (..())
			return

		if (input == "broken_door")
			if (src.master.mover)
				src.master.mover.master = null //master mover master mover master mover help HELP
				src.master.mover = null
			master.moving = 0
			src.awaiting_beacon = 10

			SPAWN(1 SECOND)
				src.master.speak("Uh.  That isn't supposed to happen.")
				src.state = 0	//Yeah, let's find that route.

				sleep(5.5 SECOND)
				if (src.master)
					src.master.speak("I guess we need to take another route.  Please follow me.")
					src.state = 0
					src.awaiting_beacon = 3
					next_beacon_id = current_beacon_id
					src.task_act()

#undef NT_DISCOUNT
#undef NT_CLOAKER
#undef NT_OTHERGUIDE
#undef NT_PONZI
#undef NT_SPY
#undef NT_BILL
#undef NT_BEE
#undef NT_SOLARIUM
#undef NT_CHEGET
#undef NT_SOVBUDDY


#undef NT_MNX
#undef NT_RISING_SUN
#undef MAPTEXT_PAUSE
#undef FOUND_NEAT
#undef END_NEAT

/obj/machinery/door/poddoor/blast/lunar
	name = "security door"
	desc = "A security door used to separate museum compartments."
	autoclose = FALSE
	req_access_txt = ""

/obj/machinery/door/poddoor/blast/lunar/tour

	isblocked()
		return (src.density && src.operating == -1)

	open(var/obj/callerDoor)
		if (src.operating == 1) //doors can still open when emag-disabled
			return
		if (!density)
			return 0

		for (var/obj/machinery/door/poddoor/blast/lunar/tourDoor in orange(1, src))
			if (tourDoor == callerDoor)
				continue

			SPAWN(0)
				tourDoor.open(src)

		if(!src.operating) //in case of emag
			src.operating = 1
		flick("bdoor[doordir]c0", src)
		src.icon_state = "bdoor[doordir]0"
		SPAWN(1 SECOND)
			src.set_density(0)
			src.RL_SetOpacity(0)
			update_nearby_tiles()

			if(operating == 1) //emag again
				src.operating = 0
			if(autoclose)
				sleep(15 SECONDS)
				autoclose()
		return 1


	close(var/obj/callerDoor)
		if (src.operating)
			return
		if (src.density)
			return
		src.operating = 1

		for (var/obj/machinery/door/poddoor/blast/lunar/tour/tourDoor in orange(1, src))
			if (tourDoor == callerDoor)
				continue

			SPAWN(0)
				tourDoor.close(src)

		flick("bdoor[doordir]c1", src)
		src.icon_state = "bdoor[doordir]1"
		src.set_density(1)
		if (src.visible)
			src.RL_SetOpacity(1)
		update_nearby_tiles()

		sleep(1 SECOND)
		src.operating = 0
		return

	attackby(obj/item/C, mob/user)
		src.add_fingerprint(user)
		return


/obj/machinery/door/lunar_breakdoor
	name = "External Airlock"
	icon = 'icons/obj/doors/SL_doors.dmi'
	icon_state = "airlock_closed"
	icon_base = "airlock"
	anchored = 1
	density = 1
	opacity = 1
	autoclose = FALSE
	cant_emag = TRUE
	req_access_txt = "999"

	var/broken = 0

	New()
		..()
		UnsubscribeProcess()

	close()
		return

	isblocked()
		return broken

	open()
		if (src.broken)
			return

		src.broken = 1
		src.operating = -1 // set operating to -1 so A* fails on door check

		playsound(src.loc, 'sound/machines/airlock_break_very_temp.ogg', 50, 1)
		SPAWN(0)
			flick("breakairlock1", src)
			src.icon_state = "breakairlock2"
			sleep (2)
			src.set_opacity(0)
			sleep(0.6 SECONDS)
			elecflash(src,power=2,exclude_center = 0)

		for (var/obj/machinery/door/airlock/otherDoor in view(7, src))
			if (777 in otherDoor.req_access)
				otherDoor.req_access -= 777

		var/obj/machinery/bot/guardbot/old/theTourguide = locate() in view(src)
		if (istype(theTourguide) && theTourguide.task)
			theTourguide.task.task_input("broken_door")



/obj/decal/lunar_bootprint
	name = "Neil Armstrong's genuine lunar bootprint"
	desc = "The famous photographed bootprint is actually from Buzz Aldrin, but this is the genuine actual real replica of the FIRST step on the moon.  A corner of another world that is forever mankind."
	anchored = 1
	density = 0
	layer = TURF_LAYER
	icon = 'icons/misc/lunar.dmi'
	icon_state = "footprint"
	pixel_x = -8
	var/somebody_fucked_up = 0

	attack_hand(mob/user)
		if (!user)
			return

		if (user.loc != src.loc)
			boutput(user, "If you got really close, you could probably compare foot sizes.")
			return

		user.visible_message("<b>[user]</b> steps right into [src.name].", "<span class='notice'>You step into the footprint. Ha ha, oh man, your foot fits right into that!</span>")
		if (!somebody_fucked_up)
			desc += " There's some total idiot fucker's footprint smooshed into the center."
			boutput(user, "<span class='alert'>OH FUCK you left your footprint over it!  You fucked up a 90 year old famous footprint. You assumed it was covered in some kind of protective resin or something, shit!!</span>")

		somebody_fucked_up = 1


/obj/decal/fakeobjects/moon_on_a_stick
	name = "Moon model"
	desc = "A really large mockup of the Earth's moon."
	icon = 'icons/misc/lunar64.dmi'
	icon_state = "moon"
	anchored = 1
	density = 1
	layer = MOB_LAYER + 1

	New()
		..()

		var/image/stand = image('icons/misc/lunar.dmi', "moonstand")
		stand.pixel_x = 16
		src.pixel_y = 24
		stand.pixel_y = -24
		stand.layer = OBJ_LAYER
		src.underlays += stand

/obj/decal/fakeobjects/lunar_lander
	name = "Lunar module descent stage"
	desc = "The descent stage of the Apollo 11 lunar module, which landed the first astronauts on the moon."
	anchored = 1
	density = 1
	icon = 'icons/misc/lunar64.dmi'
	icon_state = "LEM"
	bound_height = 64
	bound_width = 64


/obj/decal/fakeobjects/moonrock
	name = "moon rock"
	desc = "A piece of regolith. Or something. It is a heavy rock from the moon.  These used to be worth more."
	icon = 'icons/misc/lunar.dmi'
	icon_state = "moonrock"
	anchored = 1
	density = 1

/obj/critter/mannequin
	name = "mannequin"
	desc = "It's a dummy, dummy."
	icon = 'icons/misc/lunar.dmi'
	icon_state = "mannequin"
	atkcarbon = 0
	atksilicon = 0
	health = 10
	firevuln = 1	//Typical store display mannequin has a styrofoam body and metal skeleton.  Styrofoam /burns/
	brutevuln = 0.5
	aggressive = 0
	defensive = 0
	wanderer = 0
	generic = 0
	flying = 0
	death_text = "%src% tips over, its joints seizing and locking up.  It does not move again."
	angertext = "seems to stare at"
	is_pet = 0

	var/does_creepy_stuff = 0
	var/typeName = "Generic"

	CritterAttack(mob/M)
		src.attacking = 1
		src.visible_message("<span class='alert'><B>[src]</B> awkwardly bashes [src.target]!</span>")
		random_brute_damage(src.target, rand(5,15),1)
		playsound(src.loc, 'sound/misc/automaton_scratch.ogg', 50, 1)
		SPAWN(1 SECOND)
			src.attacking = 0

	process()
		if(!..())
			return 0
		if (!alive || !does_creepy_stuff)
			return

		if (prob(6))
			playsound(src.loc, 'sound/misc/automaton_tickhum.ogg', 60, 1)
			src.visible_message("<span class='alert'><b>[src] emits [pick("a soft", "a quiet", "a curious", "an odd", "an ominous", "a strange", "a forboding", "a peculiar", "a faint")] [pick("ticking", "tocking", "humming", "droning", "clicking")] sound.</span>")

		if (prob(6))
			playsound(src.loc, 'sound/misc/automaton_ratchet.ogg', 60, 1)
			src.visible_message("<span class='alert'><b>[src] emits [pick("a peculiar", "a worried", "a suspicious", "a reassuring", "a gentle", "a perturbed", "a calm", "an annoyed", "an unusual")] [pick("ratcheting", "rattling", "clacking", "whirring")] noise.</span>")

		if (prob(5))
			playsound(src.loc, 'sound/misc/automaton_scratch.ogg', 50, 1)
			src.visible_message("<span class='alert'><b>[src]</b> [pick("turns", "pivots", "twitches", "spins")].</span>")
			src.set_dir(pick(alldirs))

/obj/critter/moonspy
	name = "\proper not a syndicate spy probe"
	desc = "It's probably a coat rack or something."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "drone_service_bot"
	density = 1
	health = 35
	aggressive = 0
	defensive = 1
	wanderer = 0
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	atkcarbon = 1
	atksilicon = 1
	atcritter = 0
	firevuln = 0.5
	brutevuln = 0.5
	sleeping_icon_state = "drone_service_bot_off"
	flying = 0
	generic = 0
	death_text = "%src% blows apart! But not in a way at all like surveillance equipment. More like a washing machine or something."

	var/static/list/non_spy_weapons = list("something that isn't a high gain microphone", "an object distinct from a tape recorder", "object that is, in all likelihood, not a spy camera")

	ChaseAttack(mob/M)
		src.visible_message("<span class='alert'><B>[src]</B> launches itself towards [M]!</span>")
		if (prob(20)) M.changeStatus("stunned", 2 SECONDS)
		random_brute_damage(M, rand(2,5))

	CritterAttack(mob/M)
		src.attacking = 1
		src.visible_message("<span class='alert'>The <B>[src.name]</B> [pick("conks", "whacks", "bops")] [src.target] with [pick(non_spy_weapons)]!</span>")
		random_brute_damage(src.target, rand(2,4),1)
		SPAWN(1 SECOND)
			src.attacking = 0

	CritterDeath()
		if (!src.alive) return
		..()

		SPAWN(0)
			elecflash(src,power=2,exclude_center = 0)
			qdel(src)


/obj/item/clothing/suit/lunar_tshirt
	name = "museum of lunar history t-shirt"
	desc = "Size small.  However, just fifty years ago this would have been considered an XXL."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "moon_tshirt"
	item_state = "moon_tshirt"
	body_parts_covered = TORSO|ARMS


#define REASON_NONE			0
#define REASON_ADDTEXT		1
#define REASON_CLEARSCREEN	2
#define REASON_UPDATETEXT	4
obj/machinery/embedded_controller/radio/maintpanel
	name = "maintenance access panel"
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "museum_control"
	anchored = 1
	density = 0

	var/id_tag = null
	var/net_id = null
	var/locked = 0
	var/blinking = 0
	var/obj/machinery/power/data_terminal/wired_connection = null
	var/setup_string
	var/datum/light/light

	var/updateFlags = 0
	var/the_goddamn_regex = "/\\s/gm"
	//req_access

	New()
		..()
		light = new /datum/light/point
		light.attach(src)
		light.set_color(0.6, 1, 0.66)
		light.set_brightness(0.4)
		light.enable()

		SPAWN(0.5 SECONDS)
			if (src.tag)
				src.id_tag = src.tag
				src.tag = null

			src.net_id = generate_net_id(src)

			if(!src.wired_connection)	//Find the data terminal if there is one around.
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.wired_connection = test_link
					src.wired_connection.master = src

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/card/id))
			if (user && src.allowed(user))
				boutput(user, "<span class='success'>Access approved..</span>")
				src.locked = !src.locked
				updateUsrDialog()
			else
				boutput(user, "<font class='alert'>Access denied.</font>")

		else
			return ..()

	post_signal(datum/signal/signal, comm_line)
		if (!signal || (status & NOPOWER))
			return

		signal.source = src
		signal.data["sender"] = src.net_id
		if (comm_line)
			signal.transmission_method = TRANSMISSION_WIRE
			if (wired_connection)
				wired_connection.post_signal(src, signal)

		else
			return SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, 100)

	initialize()
		..()

		var/datum/computer/file/embedded_program/maintpanel/new_prog = new
		new_prog.master = src
		program = new_prog

		if (setup_string)
			new_prog.do_setup(setup_string)


	receive_signal(datum/signal/signal, receive_method, receive_param, connection_id)
		if(!signal || signal.encryption)
			return

		if (!cmptext(signal.data["address_1"], src.net_id))
			if (cmptext(signal.data["address_1"], "ping"))
				var/datum/signal/pingsignal = get_free_signal()
				pingsignal.data["device"] = "MCU_CONTROL"
				pingsignal.data["netid"] = src.net_id
				pingsignal.data["address_1"] = signal.data["sender"]
				pingsignal.data["command"] = "ping_reply"

				post_signal(pingsignal)

			return

		if(program)
			return program.receive_signal(signal, receive_method, receive_param)


	process()
		if (status & NOPOWER)
			UpdateIcon()
			return

		return ..()

	update_icon()
		if (status & NOPOWER)
			icon_state = "museum_control_off"
		else
			icon_state = blinking ? "museum_control_blink" : "museum_control"

	attack_hand(mob/user)
		src.add_dialog(user)
		var/dat = {"<!DOCTYPE html>
<html>
<head>
<TITLE>Intelligent Maintenance Panel</TITLE>
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<style>

	@font-face
	{
		font-family: 'Glass_TTY_VT220';
		src: url('glass_tty_vt220.eot');
		src: url('glass_tty_vt220.eot') format('embedded-opentype'),
			 url('glass_tty_vt220.ttf') format('truetype'),
			 url('glass_tty_vt220.woff') format('woff'),
	}

	body {background-color:#999876;}

	img {border-style: none;}

	hr {
		color:#31A131;
		border-style:solid;
		background-color:#31A131;
		height:14px;
		}

	a:link {text-decoration:none}


	#outputscreen
	{
		border: 1px solid gray;
		height: 13em;
		width: 36ex;
		position: absolute;
		left: 60px;
		overflow-y: hidden;
		overflow-x: hidden;
		word-wrap: break-word;
		word-break: break-all;
		background-color:#111F10;
		color:#31C131;
		font-size:14pt;
	}

	.outputline
	{
		border: 0;
		height: 1.4em;
		width: 32ex;
		overflow-y: hidden;
		overflow-x: hidden;
		word-wrap: break-word;
		word-break: break-all;
		background-color:#111F10;
		color:#31C131;
		font-family: Glass_TTY_VT220 !important;
		font-size: 14pt;
	}

	#alertpanel
	{
		border: 8px solid #31A131;
		text-align: center;
		margin: auto auto auto auto;
		width: 10ex;
		top: 40%;
	}

	.controlbutton
	{
		border: 1px solid black;
		background-color: #CF6300;
		width: 40px;
		height: 20px;
		position: absolute;
		left: 20px;
		display:block;
		text-align: center;
		color: #D0D0D0;
		font-size: small;
	}

</style>
</head>

<body scroll=no><br>

<div id="outputscreen">
"}
		for (var/screenlineIndex = 0, screenlineIndex < 13, screenlineIndex++)
			dat += "<div id=\"screenline[screenlineIndex]\" class=\"outputline\"></div>"

		dat +={"</div>
<a id="button1" class='controlbutton' style="top:290px; left:76px"  href='byond://?src=\ref[src];command=button1'>&#8678;</a>
<a id="button2" class='controlbutton' style="top:290px; left:151px" href='byond://?src=\ref[src];command=button2'>&#8680;</a>
<a id="button3" class='controlbutton' style="top:290px; left:226px" href='byond://?src=\ref[src];command=button3'>SEL</a>
<a id="button4" class='controlbutton' style="top:290px; left:301px" href='byond://?src=\ref[src];command=button4'>BACK</a>

<a id="button5" class='controlbutton' style="top:330px; left:76px"  href='byond://?src=\ref[src];command=button5'>&#8681;</a>
<a id="button6" class='controlbutton' style="top:330px; left:151px" href='byond://?src=\ref[src];command=button6'>&#8679;</a>
<a id="button7" class='controlbutton' style="top:330px; left:226px" href='byond://?src=\ref[src];command=button7'>ACT</a>
<a id="button8" class='controlbutton' style="top:330px; left:301px" href='byond://?src=\ref[src];command=button8'>DEAC</a>


<script type="text/javascript">
	var printing = \["","","","","","","","","","","","",""];
	var t_count = 0;
	var last_output;


	function setLocked ()
	{
		if (last_output)
		{
			window.clearTimeout(last_output);
			last_output = null;
		}

		var line = 0;
		for (; line < 13; line++)
		{
			document.getElementById("screenline" + line).innerHTML = "&#8199;";
		}
		document.getElementById("screenline4").innerHTML = "<div id='alertpanel'>&#8199;LOCKED&#8199;</div>";
	}

	function clearScreen ()
	{
		if (last_output)
		{
			window.clearTimeout(last_output);
			last_output = null;
		}

		var line = 0;
		for (; line < 13; line++)
		{
			document.getElementById("screenline" + line).innerHTML = "&#8199;";
		}
	}

	function setDisplay (output, line)
	{
		if (last_output)
		{
			window.clearTimeout(last_output);
			last_output = null;
		}
		if (isNaN(line))
		{
			line = 1;
		}
		else
		{
			line = Math.round(line);
			if (line < 1 || line > 13)
			{
				return;
			}
		}

		output = output.substr(0,32);
		output = output.replace([the_goddamn_regex], "&#8288; ");
		document.getElementById("screenline" + (line-1)).innerHTML = output;
	}


	function consoleTextOut(t, line)
	{
		var callPrint = 0;
		if (isNaN(line))
		{
			line = 1;
		}
		else
		{
			line = Math.round(line);
			if (line < 1 || line > 13)
			{
				return;
			}
		}

		var splitT = t.split("<br>");
		var splitTIndex = 0;
		for (; splitTIndex < splitT.length && line <= 13; splitTIndex++, line++)
		{
			t = splitT\[splitTIndex];
			if (t.length > 32)
			{
				t = t.toUpperCase();
				while (t.length > 32)
				{
					printing\[line-1] = t.substr(0,32);
					document.getElementById("screenline" + (line-1)).innerHTML = "";
					t = t.substr(32);

					if (line >= 13)
					{
						break;
					}
					line++;
				}

				callPrint = 1;

			}
			else
			{
				callPrint += printing\[line-1].length < 1;
			}
			printing\[line-1] = t.toUpperCase();
			document.getElementById("screenline" + (line-1)).innerHTML = "";
		}

		if (callPrint)
		{
			last_output = window.setInterval((function () {consoleTextOutInterval();}), 10);
		}


	}

	function consoleTextOutInterval()
	{
		var i = 0;
		for (; i < 13; i++)
		{
			if (!printing\[i].length)
			{
				continue;
			}
			var t_bit = printing\[i].substr(0,1);
			printing\[i] = printing\[i].substr(1);
			if (t_bit == " ")
			{
				t_bit = "&#8288; ";
			}

			document.getElementById("screenline" + i).innerHTML += t_bit;

			document.getElementById("outputscreen").scrollTop = document.getElementById("outputscreen").scrollHeight;
			return;
		}

		window.clearTimeout(last_output);
		last_output = null;
		return;
	}"}
		if (locked)
			dat += "setLocked();"
		else if (program)
			for (var/indexNum = 1, indexNum < 13, indexNum++)
				dat += "setDisplay(\"[program.memory["display[indexNum]"]]\", [indexNum]); "

		dat += "</script></body></html>"

		user.Browse(dat, "window=maintpanel;size=435x380;can_resize=0")
		onclose(user, "maintpanel")

	Topic(href, href_list)
		if (status & NOPOWER)
			return

		if (BOUNDS_DIST(src, usr) > 0 && !issilicon(usr))
			return

		program?.receive_user_command(href_list["command"])

		src.add_dialog(usr)

	process()
		if(!(status & NOPOWER) && program)
			program.process()

		UpdateIcon()

	updateUsrDialog(var/reason)
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if (M.using_dialog_of(src))
				if (reason || updateFlags)
					src.dynamicUpdate(M, reason|updateFlags)
					updateFlags = REASON_NONE
				else
					src.Attackhand(M)

		if (issilicon(usr))
			if (!(usr in nearby))
				if (usr.using_dialog_of(src))
					if (reason || updateFlags)
						src.dynamicUpdate(usr, reason|updateFlags)
						updateFlags = REASON_NONE
					else
						src.attack_ai(usr)

		if (program)
			for (var/line = 1, line <= 13, line++)
				if (program.memory["display_add[line]"])
					program.memory["display[line]"] = program.memory["display_add[line]"]
					program.memory["display_add[line]"] = null

	proc/dynamicUpdate(mob/user, reasonFlags)
		if (reasonFlags & REASON_CLEARSCREEN)
			user << output(null, "maintpanel.browser:clearScreen")
		if (program)
			if (reasonFlags & REASON_ADDTEXT)
				for (var/line = 1, line < 14, line++)
					if (program.memory["display_add[line]"])
						user << output(url_encode(program.memory["display_add[line]"])+"&[line]", "maintpanel.browser:consoleTextOut")


			else
				for (var/line = 1, line < 14, line++)
					if (program.memory["display[line]"])
						user << output(url_encode(program.memory["display[line]"])+"&[line]", "maintpanel.browser:setDisplay")

/*
	return_text()
		if (status & NOPOWER)
			return ""

		if (locked)
			return "<div id='alertpanel'>&#8199;LOCKED&#8199;</div>"

		if (program)
			return program.memory["display"]
*/

#define ENTRY_MAX	24
#define PANELSTATE_MAIN_MENU	0
#define PANELSTATE_ENTRY_MENU	1

datum/computer/file/embedded_program/maintpanel
	name = "maintpnl"
	extension = "EPG"
	state = PANELSTATE_MAIN_MENU

	var/tmp/list/device_entries = list()
	var/tmp/selected_entry = 0
	var/tmp/list/sessions = list()

	New()
		..()
		for (var/line = 1, line <= 13, line++)
			memory += "display[line]"
			memory["display[line]"] = ""

			memory += "display_add[line]"
			memory["display_add[line]"] = ""

		SPAWN(1 SECOND)
			updateDisplay()

	disposing()
		if (device_entries)
			for (var/datum/entry in device_entries)
				entry.dispose()

			device_entries = null

		sessions = null

		..()

	proc/do_setup(var/setupString)
		var/list/setupList = splittext(setupString, ";")
		if (!setupList || !length(setupList))
			return

		for (var/setupEntry in setupList)
			var/entryName = ""
			. = findtext(setupEntry, ",")
			if (.)
				entryName = copytext(setupEntry, .+1)
				setupEntry = copytext(setupEntry, 1, .)

			if (cmptext(copytext(setupEntry, 1, 5), "fake"))
				. = text2path("/datum/maintpanel_device_entry/dummy[copytext(setupEntry, 5)]")
				if (.)
					src.device_entries += new . (src, entryName)
				else
					src.device_entries += new /datum/maintpanel_device_entry/dummy (src, entryName)
				continue

			var/obj/controlTarget = locate(setupEntry)
			if (!controlTarget)
				logTheThing(LOG_DEBUG, null, "Maint control panel at \[[master.x], [master.y], [master.z]] had invalid setup tag \"[setupEntry]\"")
				continue

			if (istype(controlTarget, /obj/machinery/door/airlock))
				src.device_entries += new /datum/maintpanel_device_entry/airlock (src, controlTarget, entryName)

			else if (istype(controlTarget, /obj/machinery/door/poddoor))
				src.device_entries += new /datum/maintpanel_device_entry/podlock (src, controlTarget, entryName)

			else if (istype(controlTarget, /obj/critter/mannequin))
				src.device_entries += new /datum/maintpanel_device_entry/mannequin (src, controlTarget, entryName)

		while (src.device_entries.len < 16)
			src.device_entries += new /datum/maintpanel_device_entry/dummy (src, pick("GEN$$E$C", "MANNEA83IN 13", "M@____$CC DOOR $$S9", "########?3"))

	receive_user_command(command)
		switch (command)
			if ("button1")	//Left arrow
				if (state == PANELSTATE_MAIN_MENU)
					selected_entry &= ~1		//Left side is all evens

			if ("button2")	//Right arrow
				if (state == PANELSTATE_MAIN_MENU)
					selected_entry |= 1			//Right side is all odds.

			if ("button5")	//Down arrow
				if (state == PANELSTATE_MAIN_MENU)
					selected_entry = min(selected_entry + 2, ENTRY_MAX)

			if ("button6")	//Up arrow
				if (state == PANELSTATE_MAIN_MENU)
					selected_entry = max(selected_entry - 2, 0)

			if ("button3")	//Select
				if (state == PANELSTATE_MAIN_MENU)
					state = PANELSTATE_ENTRY_MENU

			if ("button4")	//Back
				if (state != PANELSTATE_MAIN_MENU)
					state = PANELSTATE_MAIN_MENU

			if ("button7")	//Activate
				if (state == PANELSTATE_ENTRY_MENU && selected_entry < device_entries.len)
					var/datum/maintpanel_device_entry/currentEntry = src.device_entries[selected_entry + 1]
					if (!istype(currentEntry))
						return

					currentEntry.activate()


			if ("button8")	//Deactivate
				if (state == PANELSTATE_ENTRY_MENU && selected_entry < device_entries.len)
					var/datum/maintpanel_device_entry/currentEntry = src.device_entries[selected_entry + 1]
					if (!istype(currentEntry))
						return

					currentEntry.deactivate()

		updateDisplay()

		return

	receive_signal(datum/signal/signal, receive_method, receive_param, connection_id)
		if (signal.data["sender"] in src.sessions)
			var/datum/maintpanel_device_entry/entry = src.sessions[signal.data["sender"]]
			src.sessions -= signal.data["sender"]
			if (istype(entry) && (entry in src.device_entries) && signal.data["lock_status"])

				entry.receive_signal(signal)

				updateDisplay()

		return

	process()
		return

	proc/updateDisplay()
		if (state == PANELSTATE_MAIN_MENU)
			var/list/printList = list(" *       KNOWN  DEVICES       * ","","","","","","","","","","","","")
			var/printedCounter
			for (printedCounter = 0, printedCounter < ENTRY_MAX, printedCounter++)
				var/datum/maintpanel_device_entry/entry
				if (printedCounter < device_entries.len)
					entry = device_entries[printedCounter+1]

				var/nextEntry
				printList[round(printedCounter/2) + 2] += (selected_entry == printedCounter) ? ">" : (istype(entry) && entry.active ? "*" : " ")
				if (!istype(entry))
					printList[round(printedCounter/2) + 2] += "               " //This makes half a display row of spaces.  16 spaces.  2^4 spaces.

					continue

				nextEntry = "[copytext(entry.name, 1, 16)]"

				while (length(nextEntry) < 15)
					nextEntry += " "

				printList[round(printedCounter/2) + 2] += nextEntry


			printToDisplay(printList, 0)

		else if (state == PANELSTATE_ENTRY_MENU)
			if ((selected_entry+1) > device_entries.len)
				state = PANELSTATE_MAIN_MENU
				return

			var/datum/maintpanel_device_entry/entry = device_entries[selected_entry + 1]
			if (!istype(entry))
				state = PANELSTATE_MAIN_MENU
				return

			. = copytext(entry.name, 1, 17)
			while (length(.) < 28)
				. = " [.] "

			var/list/outList = list(" *[.]* ")
			. = entry.getControlMenu()
			if (.)
				outList += .
			else
				outList += "   N / A"

			printToDisplay(outList, 0)

		return

	proc/printToDisplay(var/list/newText, var/add)
		if (!istype(newText))
			return

		if (add)
			for (var/line = 1, line <= 13 && line <= newText.len, line++)
				memory["display_add[line]"] += newText[line]
		else
			for (var/line = 1, line <= 13, line++)
				if (line <= newText.len)
					memory["display[line]"] = newText[line]
				else
					memory["display[line]"] = " "

		if (master)
			master.updateUsrDialog(add ? REASON_ADDTEXT : REASON_UPDATETEXT)

datum/maintpanel_device_entry
	var/name = "GENERIC"
	var/datum/computer/file/embedded_program/maintpanel/master
	var/active = 0
	var/needs_hack = 0

	disposing()
		master = null

		..()

	proc/activate()
		return 0

	proc/deactivate()
		return 0

	proc/toggle()
		if (active)
			return deactivate()
		else
			return activate()

	proc/getControlMenu()
		return "  ACTIVE: [src.active ? "YES" : "NO"]"

	proc/receive_signal(datum/signal/signal)

	airlock
		name = "AIRLOCK"
		var/ourDoorID
		var/open = 0
		var/locked = 0

		New(datum/computer/file/embedded_program/maintpanel/newMaster, obj/machinery/door/airlock/targetDoor, entryName)
			..()

			if (!istype(newMaster) || !istype(targetDoor))
				return

			ourDoorID = targetDoor.net_id
			master = newMaster
			if (entryName)
				src.name = uppertext(entryName)

			locked = targetDoor.locked
			open = !targetDoor.density

			active = open || !locked

		getControlMenu()
			return list("  SEALED: [src.active ? "NO" : "YES"]",\
			"  LOCKED: [src.locked ? "YES" : "NO"]",\
			"  CLASS: AIRLOCK - GENERIC")

		receive_signal(datum/signal/signal)

			open = signal.data["door_status"] == "open"
			locked = signal.data["lock_status"] == "locked"

			active = open || !locked

		activate()
			if (!ourDoorID || !master)
				return 1

			if (active)
				return 0

			var/datum/signal/signal = get_free_signal()
			signal.data["address_1"] = ourDoorID
			signal.data["command"] = "secure_open"

			master.sessions["[ourDoorID]"] = src

			master.post_signal(signal)
			return 0


		deactivate()
			if (!ourDoorID || !master)
				return 1

			if (!active)
				return 0

			var/datum/signal/signal = get_free_signal()
			signal.data["address_1"] = ourDoorID
			signal.data["command"] = "secure_close"

			master.sessions["[ourDoorID]"] = src

			master.post_signal(signal)
			return 0


	podlock
		name = "BLASTDOOR"
		var/obj/machinery/door/poddoor/ourDoor

		New(datum/computer/file/embedded_program/maintpanel/newMaster, obj/machinery/door/poddoor/targetDoor, entryName)
			..()

			if (!istype(newMaster) || !istype(targetDoor))
				return

			//ourDoorID = targetDoor.net_id
			master = newMaster
			if (entryName)
				src.name = uppertext(entryName)

			ourDoor = targetDoor

		getControlMenu()
			if (ourDoor)
				src.active = !ourDoor.density

			return list("  DOOR TYPE: BLAST DOOR","  SEALED: [src.active ? "NO" : "YES"]","  ACTUATOR PRESSURE:","    ACT 1:  OK","    ACT 2:  OK","    ACT 3:  OK")

		activate()
			if (!ourDoor)
				return 1

			if (ourDoor.disposed)
				ourDoor = null
				return 1

			if (ourDoor.open())
				src.active = 1

			return 0

		deactivate()
			if (!ourDoor)
				return 1

			if (ourDoor.disposed)
				ourDoor = null
				return 1

			if (ourDoor.close())
				src.active = 0

			return 0

	mannequin
		name = "ANIMATRONIC"
		var/obj/critter/mannequin/ourMannequin
		var/mannequinName = "GENERIC"

		getControlMenu()
			return list("  ACTOR ID: [mannequinName]",\
			"  ACTIVE: [(ourMannequin?.alive) ? (src.active ? "YES" : "NO") : "NO"]",\
			"  CONDITION: [ourMannequin?.alive ? "OK" : "REPAIRS NEEDED"]")

		New(datum/computer/file/embedded_program/maintpanel/newMaster, obj/critter/mannequin/mannequin, entryName)
			..()

			if (!istype(newMaster) || !istype(mannequin))
				return

			master = newMaster
			src.active = mannequin.does_creepy_stuff
			if (mannequin.typeName)
				src.mannequinName = uppertext(mannequin.typeName)

			ourMannequin = mannequin
			if (entryName)
				src.name = uppertext(entryName)

		activate()
			if (ourMannequin)
				if (ourMannequin.disposed)
					ourMannequin = null
					return 1

				active = 1
				ourMannequin.does_creepy_stuff = 1
				return 0

			return 1

		deactivate()
			if (ourMannequin)
				if (ourMannequin.disposed)
					ourMannequin = null
					return 1

				active = 0
				ourMannequin.does_creepy_stuff = 0

			return 1

	dummy	//This is a fake entry that exists to fill space, not to be confused with the mannequin type.

		New(datum/computer/file/embedded_program/maintpanel/newMaster, entryName)
			..()

			if (istype(newMaster))
				master = newMaster
				if (entryName)
					src.name = uppertext(entryName)

		getControlMenu()
			. = list()
			for (var/n = 0, n < 10, n++)
				var/toAdd = ""
				while (length(toAdd) < 25)
					toAdd += ascii2text( prob(50) ? rand(48, 59) : rand(63, 90) )

				. += toAdd

	dummyreactor

		New(datum/computer/file/embedded_program/maintpanel/newMaster, entryName)
			..()

			if (istype(newMaster))
				master = newMaster
				if (entryName)
					src.name = uppertext(entryName)


		getControlMenu()
			return list("  CLASS MSTAR-80A", "  STATUS:  INACTIVE", "  OUTPUT: 0 W", "", " !! CHECK COOLANT PUMPS !!", " !! TURBINE TRIP !!")

	dummyatmos
		New(datum/computer/file/embedded_program/maintpanel/newMaster, entryName)
			..()

			if (istype(newMaster))
				master = newMaster
				if (entryName)
					src.name = uppertext(entryName)


		getControlMenu()
			return list("  ATMOS PROCESSOR","  STATUS: LOW FUNCTION", "  REFRIGERANT LEVELS LOW","  FILTER 0 STATUS: OK", "  FILTER 1 STATUS: REPLACE", "  FILTER 2 STATUS: REPLACE")

	dummywhat
		New(datum/computer/file/embedded_program/maintpanel/newMaster, entryName)
			..()

			if (istype(newMaster))
				master = newMaster
				if (entryName)
					src.name = uppertext(entryName)

		getControlMenu()
			return list("  HOW ARE YOU SEEING THIS", "  ARE YOU A WIZARD")

#undef PANELSTATE_MAIN_MENU
#undef PANELSTATE_ENTRY_MENU
#undef REASON_NONE
#undef REASON_ADDTEXT
#undef REASON_CLEARSCREEN
#undef REASON_UPDATETEXT

obj/machinery/embedded_controller/radio/maintpanel/mnx
	locked = 1
	setup_string = "fakewhat,HOW"

	New()
		..()

		SPAWN(1 SECOND)
			if (!locate("MNXpanel"))
				src.tag = "MNXpanel"
				src.id_tag = src.tag

/obj/item/kitchen/everyflavor_box/wax
	attack_hand(mob/user, unused, flag)
		if (flag)
			return ..()
		if(user.r_hand == src || user.l_hand == src)
			if(src.amount == 0)
				boutput(user, "<span class='alert'>You're out of beans. You feel strangely sad.</span>")
				return
			else
				var/obj/item/reagent_containers/food/snacks/candy/B = new /obj/item/reagent_containers/food/snacks/candy {name = "A Farty Snott's Every Flavour Bean"; desc = "A favorite halloween sweet worldwide!"; icon_state = "bean"; amount = 1; initial_volume = 100;} (user)

				user.put_in_hand_or_drop(B)
				src.amount--

				if (B.reagents)
					B.reagents.clear_reagents()
					B.reagents.add_reagent("wax", 20)

				if(src.amount == 0)
					src.icon_state = "beans-empty"
					src.name = "An empty Farty Snott's bag."
		else
			return ..()
		return

/obj/fake_dwarf_bomb
	name = "historic \"dwarf\" plasma bomb"
	desc = "This is a model of the \"dwarf\" plasma bomb held by the Space IRA in the 2004 Lunar Port Hostage Crisis.  At least, you hope it's a model."
	icon = 'icons/misc/lunar.dmi'
	icon_state = "dwarf_bomb"
	anchored = 0
	density = 1

	var/well_fuck_its_armed = 0

	attackby(obj/item/I, mob/user)
		return attack_hand(user)

	attack_hand(mob/living/user)
		if (!istype(user) || user.stat || (BOUNDS_DIST(src, user) > 0) || well_fuck_its_armed)
			return

		well_fuck_its_armed = 1
		user.visible_message("<b>[user]</b> prods [src].", "You prod at [src].  It's a pretty accurate replica, it seems.  Neat.")
		SPAWN(1 SECOND)
			src.visible_message("<span class='alert'>[src] gives a grumpy beep! <b><font style='font-size:200%;'>OH FUCK</font></b></span>")

			playsound(src.loc, 'sound/weapons/armbomb.ogg', 50)

			sleep(3 SECONDS)
			//do tiny baby explosion noise
			//Todo: a squeakier blast sound.
			playsound(src.loc, 'sound/effects/Explosion2.ogg', 40, 0, 0, 4)

			new /obj/effects/explosion/tiny_baby (src.loc)
			for (var/mob/living/carbon/unfortunate_jerk in range(1, src))
				if (!isdead(unfortunate_jerk) && unfortunate_jerk.client)
					shake_camera(unfortunate_jerk, 12, 32)
				unfortunate_jerk.changeStatus("stunned", 4 SECONDS)
				unfortunate_jerk.stuttering += 4
				unfortunate_jerk.lying = 1
				unfortunate_jerk.set_clothing_icon_dirty()

			qdel(src)

//Shelving for the gift shop
/obj/rack/lunar
	name = "shop shelf"
	desc = "A shelf as is used in many stores."
	icon = 'icons/misc/lunar.dmi'
	icon_state = "aisleshelf"

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W))
			return

		return ..()

/obj/item/basketball/lunar
	name = "moon basketball"
	desc = "A basketball that is printed to resemble the moon."
	icon = 'icons/misc/lunar.dmi'
	icon_state = "bball"
	item_state = "bbmoon"

/obj/decal/fakeobjects/junction_box
	name = "junction box"
	desc = "A large, wall-mounted metal box with several burly cables moving from it to the floor.  The front panel is locked.  A label on the panel reads 'FED FROM XFMR 210.  DANGER:  15 kV.  ARC FLASH HAZARD, DO NOT OPEN OR OPERATE CONTROLS WITHOUT APPROPRIATE PPE.'"
	icon = 'icons/misc/lunar.dmi'
	icon_state = "junction_box"
	pixel_y = 24
	anchored = 1
	density = 0

	attackby(obj/item/C, mob/user)
		if (istype(C, /obj/item/device/key))
			user.visible_message("<b>[user]</b> dully bumps a key against [src].  It's not even going in the lock.  Uhhh.","Really?  We're really doing this?  No, the key doesn't fit.  Do we need to stage an intervention?")
			return

		return ..()


/datum/computer/file/guardbot_task/security/crazy/moon
	var/tmp/chastised = 0

	task_input(input)
		if(..())
			return 1

		if (input == "chastise")
			if (!chastised)
				chastised = 1
				panic = 0

				master.speak( pick("Um...oh.  Sorry about that.","I was just afraid it was more of those armed NT men...sorry...","You're....you're right.  I'm sorry.") )
				master.visible_message("<b>[src.master]</b> looks ashamed!")
				drop_arrest_target()

				master.set_emotion("sad")
				master.moving = 0

				return 1

		return 0
