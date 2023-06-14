/// Don't change the index -- it's set by the PDA!
#define RINGLIST_STATIC 0
/// Cycle through the ringtone list one after the other
#define RINGLIST_CYCLE 1
/// Pick a random index
#define RINGLIST_RANDOM 2

/// type filter for ringtones that're suposed to be selectable at roundstart
proc/filter_is_character_setup_ringtone(type)
	var/datum/ringtone/r_tone = type
	return initial(r_tone.canSpawnWith)

/// Ringtones that'll get mashed into a PDA
/datum/ringtone
	var/name = "Two-Beep"
	var/desc = "The default alert tone used in nearly every Thinktronic Systems device ever built. A keen ear may recognize this classic tune as an excerpt from Frédéric Chopin's ‘Grande Valse’, but in fact it's based on a remix of Dimmy Spuud's minimalist reimagining ‘BEEP’, used with permission and possibly on a dare."
	/// List of sounds
	var/list/ringList = list('sound/machines/twobeep.ogg')
	/// List of alternate sounds
	var/list/ringShortList = list('sound/machines/twobeep.ogg')
	/// What volume to play the sound at this index -- keep all these lists at the same length as ringlist!
	var/list/volList = list(35)
	/// Whether or not to vary the sound at this index
	var/list/varyList = list(1)
	/// The alert text to play for the sound at this index -- if enabled and not blank
	var/list/alertList = list("beep")
	/// Pitch to play the sound at this index
	var/list/pitchList = list(1)
	/// How much further should this sound carry?
	var/list/rangeList = list(0)
	/// Current index to read all the lists from, so if the ringtone wants to cycle through different sounds, it can
	var/ringListIndex = 1
	/// Whether this ringtone set should use its alert text instead of the PDA's
	var/overrideAlert = 0
	/// Sets how to change the index whenever the sound gets played
	var/listCycleType = RINGLIST_STATIC
	/// Does this ringtone have short versions of their tones?
	var/has_short = 0
	/// The PDA this happens to be attached to
	var/obj/item/device/pda2/holder
	/// The success message when this ringtone gets applied
	var/succText = "<span class='notice'>*Successfully set your device's sound system to Two-Beep.*</span>"
	/// The message sent when previewing the ringtone
	var/previewMessage = "This is a message sent from this PDA to demonstrate the currently selected sound system. Note that this is only a preview, your PDA's sound system settings have not been updated!"
	/// The sender of the preview message
	var/previewSender = "Thinktronic Systems, LTD"
	/// The following are used by the PDA programs to display the menu option things
	/// The text that you click to make this your ringtone
	var/applyText = "Apply"
	/// The test that you click to get a message and hear the ringtone without applying it
	var/previewText = "Preview"
	/// The text that works as a flowery replacement for Name:
	var/nameText = "Sound system:"
	/// The text that works as a flowery form of Description:
	var/descText = "Description:"
	/// Does this ringtone have special message-specific functionality?
	var/readMessages = 0
	/// Can this ringtone be selected through character creation?
	var/canSpawnWith = 1
	/// Extrarange added to all ringtones here
	var/extrarange_adjustment = -27

	New(var/obj/item/device/pda2/thisPDA)
		..()
		if (istype(thisPDA))
			src.holder = thisPDA

	disposing()
		holder = null
		. = ..()

	/// Plays the sound at the current index, then change the index
	proc/PlayRingtone(var/use_short = 0)
		if(!istype(holder))
			return // we havent been put in a PDA yet!
		playsound(src.holder, ((use_short && src.has_short) ? src.ringShortList[src.ringListIndex] : src.ringList[src.ringListIndex]), src.volList[src.ringListIndex], src.varyList[src.ringListIndex], src.rangeList[src.ringListIndex] + extrarange_adjustment, src.pitchList[src.ringListIndex])
		src.DoSpecialThing(src.ringListIndex)
		if(src.alertList[ringListIndex])
			. = src.alertList[ringListIndex]
		switch(src.listCycleType)
			if(RINGLIST_CYCLE)
				src.ringListIndex += 1
			if(RINGLIST_RANDOM)
				src.ringListIndex = rand(1, length(src.ringList))
			else
				src.ringListIndex = 1
		if(src.ringListIndex > length(src.ringList))
			src.ringListIndex = 1

	/// Do something special at certain indexes, after playing the sound?
	proc/DoSpecialThing(var/index)
		return

	/// So things with access to the ringtone can do things to it
	proc/MessageAction(var/data)
		return

/// Test ringtone for random sounds w/ varied and altered pitch
/datum/ringtone/dogs
	name = "WOLF PACK"
	desc = "LIVE BY THE TOOTH AND HOWL BY THE FANG RIDE AND DIE BY THE LIGHT OF THE MOON CRANKING THE MAN THROUGH THE FOREST FOREVER NIGHT CLAW SHEEP GET PAID LEAP WIGGLE HAIRBALL WOOF WOOF AWOO"
	ringList = list('sound/voice/animal/werewolf_howl.ogg',\
									'sound/voice/animal/howl1.ogg',\
									'sound/voice/animal/howl2.ogg',\
									'sound/voice/animal/howl3.ogg',\
									'sound/voice/animal/howl4.ogg',\
									'sound/voice/animal/howl5.ogg',\
									'sound/voice/animal/howl6.ogg',\
									'sound/voice/animal/dogbark.ogg')
	volList = list(100, 35, 35, 35, 35, 35, 35, 100)
	varyList = list(1, 1, 1, 1, 1, 1, 1, 1)
	alertList = list("AAAWOOOOOOO",\
									"HAWWWAWOOOO",\
									"HOOOAAAUUUUWWW",\
									"HORROWWWWWLL",\
									"HRROOWWRRRRWWRR",\
									"RRWRWRRRROOOO",\
									"RAWRRWRROOORRRHHH",\
									"ARF")
	pitchList = list(0.8, 1, 0.7, 1, 1.1, 1, 1, 0.6)
	rangeList = list(5, 0, 0, 0, 0, 0, 0, 0)
	extrarange_adjustment = -24
	listCycleType = RINGLIST_RANDOM
	succText = "<span class='alert'>*WELCOME THE HECK TO THE PACK*</span>"
	previewMessage = "GRR RAGH ARGFH AWROO RAFF RARFH THIS IS A PREVIEW OF THE M'F'IN WOLF PACK THRASHTONE TRY BEFORE YOU BUY ARGH WOOF AGRR"
	previewSender = "LORD MCGRUFF THE CRIME ALPHA"
	applyText = "<b><u><i>AWOOOO</i></u></b>"
	previewText = "<b><u><i>WOOF</i></u></b>"
	nameText = "<b><u><i>ALPHAAA</i></u></b>:"
	descText = "<b><u><i>WOOF</i></u></b>:"
	canSpawnWith = 0

/datum/ringtone/dogs/lessdogs
	name = "dog pack"
	desc = "live by the teeth and fang chase cats into the alley pounce and bark woof woof at the mailman"
	ringList = list('sound/voice/animal/howl1.ogg',\
									'sound/voice/animal/howl2.ogg',\
									'sound/voice/animal/howl3.ogg',\
									'sound/voice/animal/howl4.ogg',\
									'sound/voice/animal/howl5.ogg',\
									'sound/voice/animal/howl6.ogg',\
									'sound/voice/animal/dogbark.ogg')
	volList = list(100, 35, 35, 35, 35, 35, 35, 100)
	varyList = list(1, 1, 1, 1, 1, 1, 1, 1)
	alertList = list("howloo",\
									"hrorwroor",\
									"rowroroow",\
									"hrwrr",\
									"rahrnmn",\
									"arwrrwroo",\
									"arf")
	pitchList = list(1.1, 1.3, 0.8, 1, 1.1, 1, 1, 1.2)
	rangeList = list(1, 0, 0, 0, 0, 0, 0, 0)
	listCycleType = RINGLIST_RANDOM
	succText = "<span class='notice'>*welcome to the dog pack*</span>"
	previewMessage = "woof woof this is what you could bark when you install awoo this"
	previewSender = "duke doggus"
	applyText = "awoo"
	previewText = "woof"
	nameText = "doggo:"
	descText = "woof:"

/// Test ringtone for cycled numbers with special index
/datum/ringtone/numbers
	name = "Norman Number's Counting Safari"
	desc = "Welcome to Number Land! All of Norman Number's Numbermals have run away into the Math Forest! Learn the numbers 1 thru 10 as you find them all. INSTRUCTIONS: When you find a Numbermal, type its name in a message to your teacher. If you're correct, you'll get a gold star and this PDA will tell you how many Numbermals you've found! First Numberventurer to reach 10 wins! Supervision advised."
	ringList = list('sound/vox/one.ogg',\
									'sound/vox/two.ogg',\
									'sound/vox/three.ogg',\
									'sound/vox/four.ogg',\
									'sound/vox/five.ogg',\
									'sound/vox/six.ogg',\
									'sound/vox/seven.ogg',\
									'sound/vox/eight.ogg',\
									'sound/vox/nine.ogg',\
									'sound/vox/ten.ogg')
	volList = list(35, 35, 35, 35, 35, 35, 35, 35, 35, 35)
	varyList = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	pitchList = list(1.1, 1.15, 1.2, 1.25, 1.3, 1.35, 1.4, 1.45, 1.5, 0.5)
	rangeList = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	listCycleType = RINGLIST_CYCLE
	succText = "<span class='notice'>*You're ready for your Virtual Numberventure!*</span>"
	previewMessage = "You're just in time, Numberventurer! I've lost all 10 (ten) of my Numbermals in the Virtual Numberforest! Will you help me find them?"
	previewSender = "Norman Number"
	applyText = "Embark"
	previewText = "Preview"
	nameText = "Learnventure:"
	descText = ""
	canSpawnWith = 0
	var/agentname
	var/explode = 1
	var/detonating

	New()
		. = ..()
		src.agentname = "[capitalize(pick_string("agent_callsigns.txt", "colors"))] [capitalize(pick_string("agent_callsigns.txt", "birds"))]"
		src.alertList = list("You've found (one) Numbermal!",\
												"Good job, Kyle! You've found (two) Numbermals!",\
												"Yay! You've found (three) Numbermals!",\
												"(Four) is how many Numbermals you've found!",\
												"\[src.spaceson_kg.m_poppyson.k_brofft.mother] would be proud that you've found (five) Numbermals!",\
												"You've found (six) Numbermals! That's as many as your age in years!",\
												"Well done, Agent [src.agentname]. The following is for your ears only. When you are in position, send this device a secure message.",\
												"Surveyor Eagle Gorilla has identified a major structural weakness in the NT [station_or_ship()] codenamed '[station_name]'. We agree with his assessment that a low yield M68 'Popey Crunchet' tactical nuclear device detonated within the location known as the 'Clown Hole' will destroy the [station_or_ship()].",\
												"Assemble your strike force, [src.agentname], you've been granted access to the Syndicate Battlecruiser Cairngorm. You begin your assault at shift change on [BUILD_TIME_MONTH]-[BUILD_TIME_DAY]. Do not disappoint us. Dispose of this device by sending it a message.",\
												"Congratulations, Kyle! You've found all (ten) Numbermals! You're a certified Numbermalogist! ")

	DoSpecialThing(var/index)
		if(!explode)
			return
		if(index >= 10)
			if(!detonating)
				src.detonating = 1
				SPAWN(1 SECOND)
					src.holder.explode()


/// Stock Thinktronic ringtones
/datum/ringtone/thinktronic
	name = "Three-Beep"
	desc = "An advanced ringtone modeled after the highly successful \"Two-Beep\"!"
	ringList = list('sound/machines/phones/ringtones/bebebeep.ogg')
	succText = "<span class='notice'>*Successfully set your device's sound system to Three-Beep.*</span>"

/datum/ringtone/thinktronic/quad1
	name = "Four-Beep 1"
	desc = "An avant garde ringtone inspired by the classic two-beep."
	ringList = list('sound/machines/phones/ringtones/bobobebeep.ogg')
	succText = "<span class='notice'>*Successfully set your device's sound system to Four-Beep 1.*</span>"

/datum/ringtone/thinktronic/quad2
	name = "Four-Beep 2"
	desc = "An even more avant garde ringtone inspired by the classic two-beep."
	ringList = list('sound/machines/phones/ringtones/bebobeboop.ogg')
	succText = "<span class='notice'>*Successfully set your device's sound system to Four-Beep 2.*</span>"


/// Clown ringtones
/datum/ringtone/clown
	name = "Nooty's Tooter"
	desc = "Imagine, you're in the middle of terrorizing your audience into raucous fits of laughter when disaster strikes! Someone sends you a message, and you forgot to silence your PDA! Oh no, you'll be the laughing stock of the crew! Just kidding, you cleverly disguised your ringtone to sound like a bike horn, turning your carelessness into careletunity!"
	ringList = list('sound/musical_instruments/Bikehorn_1.ogg')
	volList = list(35)
	varyList = list(1)
	pitchList = list(1)
	alertList = list("honk")
	rangeList = list(0)
	listCycleType = RINGLIST_STATIC
	succText = "<span class='notice'>*Ringtone set to \"HONKHORN~1.AU\"*</span>"
	previewMessage = "Remember, laughter is laughter whether it's with you or at you!"
	previewSender = "Nooty Tooter"
	applyText = "Scene!"
	previewText = "Rehearsal!"
	nameText = "Role:"
	descText = "Motivation:"
	canSpawnWith = 0

/datum/ringtone/clown/horn
	name = "Buzzo's Bleater"
	desc = "piss"
	ringList = list('sound/musical_instruments/Vuvuzela_1.ogg')
	volList = list(100)
	varyList = list(0)
	pitchList = list(1)
	alertList = list("<span class='alert'>AAAAAAAA</span>")
	rangeList = list(0)
	listCycleType = RINGLIST_STATIC
	succText = "<span class='notice'>*Ringtone set to \"LOUD.AIFF\"*</span>"
	previewMessage = "Remember, if the crowds don't find you funny, they should at least find you deafening!"
	previewSender = "Nooty Tooter"
	applyText = "Scene!"
	previewText = "Rehearsal!"
	nameText = "Role:"
	descText = "Motivation:"

	New(obj/item/device/pda2/thisPDA)
		. = ..()
		src.desc = {"INT. MALL OF SPACEMERICA - DAY<br>
A SAD, CRYING CLOWN is frantically gesticulating in a large crowd of people who seem to be ignoring her.
The crowd has their attention on ANOTHER SADDER, CRYING CLOWN across the aisle in front of an Orange Janklius.<br>
THE FIRST SAD, CRYING CLOWN'S SPACELORD sends her a PDA message telling her she's several months late with rent,
and that she'll be out on her baggy ass if she doesn't pay up.<br>
Since A SAD CRYING CLOWN had this ringtone installed on her PDA, and its loud ringtone attracts the attention of the crowd,
bathing in her ennui and showering her with money.
"}

/datum/ringtone/clown/harmonica
	name = "Hobo's Harp"
	desc = "Whether you're riding the rails in the boxcar in the sky or just slummin' it with your other unemployable friends, any good hobo clown isn't complete without a high-tech digital replica of a harmonica. Can of beans and floppy top-hat not included."
	ringList = list('sound/musical_instruments/Harmonica_1.ogg',\
									'sound/musical_instruments/Harmonica_2.ogg',\
									'sound/musical_instruments/Harmonica_3.ogg')
	volList = list(35,\
								 35,\
								 35)
	varyList = list(1,\
									1,\
									1)
	pitchList = list(1,\
									 1,\
									 1)
	alertList = list("harmonica",\
									 "harmonica",\
									 "harmonica")
	rangeList = list(0, 0, 0)
	listCycleType = RINGLIST_RANDOM
	succText = "<span class='notice'>*Ringtone set to \"HARM~4.AIFF\"*</span>"
	previewMessage = "Remember, you're in it for the laughs, not the money!"
	previewSender = "Nooty Tooter"
	applyText = "Scene!"
	previewText = "Rehearsal!"
	nameText = "Role:"
	descText = "Motivation:"

/// basic-ass ringtones for basic-ass spacepeople
/datum/ringtone/basic
	name = "Retrospection"
	desc = "Seek inwards within."
	ringList = list('sound/machines/phones/ringtones/ringtone1_short.ogg')
	volList = list(35)
	varyList = list(1)
	pitchList = list(1)
	alertList = list("*starkle*")
	rangeList = list(0)
	listCycleType = RINGLIST_STATIC
	succText = "<span class='notice'>*Ringtone set to \"ringtone1_short.AU\"*</span>"
	previewMessage = "Set your sights skyward!"
	previewSender = "Stars Above"
	applyText = "Apply"
	previewText = "Preview"
	nameText = "Idea:"
	descText = "Inspiration:"

/datum/ringtone/basic/ring1
	name = "Introspection"
	desc = "Seek within inwards."
	ringList = list('sound/machines/phones/ringtones/ringtone1_short_01.ogg')
	volList = list(35)
	varyList = list(1)
	pitchList = list(1)
	alertList = list("*starkle*")
	rangeList = list(0)
	listCycleType = RINGLIST_STATIC
	succText = "<span class='notice'>*Ringtone set to \"ringtone1_short_01.AU\"*</span>"
	previewMessage = "Set your sights skyward!"
	previewSender = "Stars Above"
	applyText = "Apply"
	previewText = "Preview"
	nameText = "Idea:"
	descText = "Inspiration:"

/datum/ringtone/basic/ring2
	name = "Perspection"
	desc = "Seek outwards within."
	ringList = list('sound/machines/phones/ringtones/ringtone1_short_02.ogg')
	volList = list(35)
	varyList = list(1)
	pitchList = list(1)
	alertList = list("*starkle*")
	rangeList = list(0)
	listCycleType = RINGLIST_STATIC
	succText = "<span class='notice'>*Ringtone set to \"ringtone1_short_02.AU\"*</span>"
	previewMessage = "Set your sights skyward!"
	previewSender = "Stars Above"
	applyText = "Apply"
	previewText = "Preview"
	nameText = "Idea:"
	descText = "Inspiration:"

/datum/ringtone/basic/ring3
	name = "Inspection"
	desc = "Seek outwards without."
	ringList = list('sound/machines/phones/ringtones/ringtone1_short_03.ogg')
	volList = list(35)
	varyList = list(1)
	pitchList = list(1)
	alertList = list("*starkle*")
	rangeList = list(0)
	listCycleType = RINGLIST_STATIC
	succText = "<span class='notice'>*Ringtone set to \"ringtone1_short_03.AU\"*</span>"
	previewMessage = "Set your sights skyward!"
	previewSender = "Stars Above"
	applyText = "Apply"
	previewText = "Preview"
	nameText = "Idea:"
	descText = "Inspiration:"

/datum/ringtone/basic/ring4
	name = "Spectrum"
	desc = "Love boundless forwards beyond."
	ringList = list('sound/machines/phones/ringtones/ringtone2_short.ogg')
	volList = list(35)
	varyList = list(1)
	pitchList = list(1)
	alertList = list("*starkle*")
	rangeList = list(0)
	listCycleType = RINGLIST_STATIC
	succText = "<span class='notice'>*Ringtone set to \"ringtone2_short.AU\"*</span>"
	previewMessage = "Set your sky sightward!"
	previewSender = "Stars Above"
	applyText = "Apply"
	previewText = "Preview"
	nameText = "Idea:"
	descText = "Inspiration:"

/datum/ringtone/basic/ring5
	name = "Spectral"
	desc = "Love around sentwards forever."
	ringList = list('sound/machines/phones/ringtones/ringtone2_short_01.ogg')
	volList = list(35)
	varyList = list(1)
	pitchList = list(1)
	alertList = list("*starkle*")
	rangeList = list(0)
	listCycleType = RINGLIST_STATIC
	succText = "<span class='notice'>*Ringtone set to \"ringtone2_short_01.AU\"*</span>"
	previewMessage = "Set your sky sightward!"
	previewSender = "Stars Above"
	applyText = "Apply"
	previewText = "Preview"
	nameText = "Idea:"
	descText = "Inspiration:"

/datum/ringtone/basic/ring6
	name = "Refraction"
	desc = "Starward abound."
	ringList = list('sound/machines/phones/ringtones/ringtone2_short_02.ogg')
	volList = list(35)
	varyList = list(1)
	pitchList = list(1)
	alertList = list("*starkle*")
	rangeList = list(0)
	listCycleType = RINGLIST_STATIC
	succText = "<span class='notice'>*Ringtone set to \"ringtone2_short_02.AU\"*</span>"
	previewMessage = "Set your sky sightward!"
	previewSender = "Stars Above"
	applyText = "Apply"
	previewText = "Preview"
	nameText = "Idea:"
	descText = "Inspiration:"

/datum/ringtone/basic/ring7
	name = "Reboundance"
	desc = "Skybound around."
	ringList = list('sound/machines/phones/ringtones/ringtone2_short_03.ogg')
	volList = list(35)
	varyList = list(1)
	pitchList = list(1)
	alertList = list("*starkle*")
	rangeList = list(0)
	listCycleType = RINGLIST_STATIC
	succText = "<span class='notice'>*Ringtone set to \"ringtone2_short_03.AU\"*</span>"
	previewMessage = "Set your sky sightward!"
	previewSender = "Stars Above"
	applyText = "Apply"
	previewText = "Preview"
	nameText = "Idea:"
	descText = "Inspiration:"

/datum/ringtone/basic/ring8
	name = "Reflection"
	desc = "Stalwart abound."
	ringList = list('sound/machines/phones/ringtones/ringtone3_short.ogg')
	volList = list(35)
	varyList = list(1)
	pitchList = list(1)
	alertList = list("*starkle*")
	rangeList = list(0)
	listCycleType = RINGLIST_STATIC
	succText = "<span class='notice'>*Ringtone set to \"ringtone3_short.AU\"*</span>"
	previewMessage = "Set your sky sightward!"
	previewSender = "Stars Above"
	applyText = "Apply"
	previewText = "Preview"
	nameText = "Idea:"
	descText = "Inspiration:"

/datum/ringtone/basic/ring9
	name = "Relaxation"
	desc = "Float along."
	ringList = list('sound/machines/phones/ringtones/ringtone4_short.ogg')
	volList = list(35)
	varyList = list(1)
	pitchList = list(1)
	alertList = list("*starkle*")
	rangeList = list(0)
	listCycleType = RINGLIST_STATIC
	succText = "<span class='notice'>*Ringtone set to \"ringtone4_short.AU\"*</span>"
	previewMessage = "Set your sky sightward!"
	previewSender = "Stars Above"
	applyText = "Apply"
	previewText = "Preview"
	nameText = "Idea:"
	descText = "Inspiration:"

/datum/ringtone/basic/ring10
	name = "Stance"
	desc = "Ever again."
	ringList = list('sound/machines/phones/ringtones/ringtone5_short.ogg')
	volList = list(35)
	varyList = list(1)
	pitchList = list(1)
	alertList = list("*starkle*")
	rangeList = list(0)
	listCycleType = RINGLIST_STATIC
	succText = "<span class='notice'>*Ringtone set to \"ringtone5_short.AU\"*</span>"
	previewMessage = "Set your sky sightward!"
	previewSender = "Stars Above"
	applyText = "Apply"
	previewText = "Preview"
	nameText = "Idea:"
	descText = "Inspiration:"

/// Ringtones with Shorts
/datum/ringtone/retkid
	name = "BEEP 2: The Fourth"
	desc = "An intricate remix of Dimmy Spuud's ‘BEEP’."
	ringList = list('sound/machines/phones/ringtones/ringers1.ogg')
	ringShortList = list('sound/machines/phones/ringtones/ringershort1.ogg')
	volList = list(35)
	varyList = list(1)
	pitchList = list(1)
	alertList = list("*beedleebeep*")
	rangeList = list(0)
	listCycleType = RINGLIST_STATIC
	has_short = TRUE
	succText = "<span class='notice'>*Ringtone set to \"ringlord1.SND\"*</span>"
	previewMessage = "A modernized classic, remodernized!"
	previewSender = "Rhettifort 'Ret' Kid"
	applyText = "Apply"
	previewText = "Preview"
	nameText = "Ringer:"
	descText = "Descriptor:"

/datum/ringtone/retkid/ring1
	name = "Spacechimes"
	desc = "Just some holochimes jangling in the spacewind."
	ringList = list('sound/machines/phones/ringtones/ringers2.ogg')
	ringShortList = list('sound/machines/phones/ringtones/ringershort2.ogg')
	succText = "<span class='notice'>*Ringtone set to \"ringlord2.SND\"*</span>"
	previewMessage = "Always listen to your space meteorologist!"
	previewSender = "Rhettifort 'Ret' Kid"

/datum/ringtone/retkid/ring2
	name = "Shy Spacechimes"
	desc = "Just some anxious holochimes uncomfortable about jangling in the spacewind."
	ringList = list('sound/machines/phones/ringtones/ringers3.ogg')
	ringShortList = list('sound/machines/phones/ringtones/ringershort3.ogg')
	succText = "<span class='notice'>*Ringtone set to \"ringlord3.SND\"*</span>"
	previewMessage = "All spacechimes are worthy of love, no matter how they express themselves."
	previewSender = "Rhettifort 'Ret' Kid"

/datum/ringtone/retkid/ring3
	name = "Perky Spacechimes"
	desc = "Just some enthusiastic holochimes overjoyed to jangle in the spacewind."
	ringList = list('sound/machines/phones/ringtones/ringers4.ogg')
	ringShortList = list('sound/machines/phones/ringtones/ringershort4.ogg')
	succText = "<span class='notice'>*Ringtone set to \"ringlord4.SND\"*</span>"
	previewMessage = "Every new day is a cause for celebration."
	previewSender = "Rhettifort 'Ret' Kid"

/datum/ringtone/retkid/ring4
	name = "Moonlit Peahen"
	desc = "The classic tag-jingle of the Space Broadcasting Company."
	ringList = list('sound/machines/phones/ringtones/ringers5.ogg')
	ringShortList = list('sound/machines/phones/ringtones/ringershort5.ogg')
	succText = "<span class='notice'>*Ringtone set to \"ringlord5.SND\"*</span>"
	previewMessage = "Used with permission (please don't sue)"
	previewSender = "Rhettifort 'Ret' Kid"

/datum/ringtone/retkid/ring5
	name = "Plinkoe's Journey"
	desc = "A winding adventure through a space kalimba."
	ringList = list('sound/machines/phones/ringtones/ringers6.ogg')
	ringShortList = list('sound/machines/phones/ringtones/ringershort6.ogg')
	succText = "<span class='notice'>*Ringtone set to \"ringlord6.SND\"*</span>"
	previewMessage = "Honestly, it's a beautiful instrument."
	previewSender = "Rhettifort 'Ret' Kid"

/datum/ringtone/retkid/ring6
	name = "Sedate Spacechimes"
	desc = "Just some laid-back holochimes jangling at their own pace in the spacewind."
	ringList = list('sound/machines/phones/ringtones/ringers7.ogg')
	ringShortList = list('sound/machines/phones/ringtones/ringershort6.ogg')
	succText = "<span class='notice'>*Ringtone set to \"ringlord7.SND\"*</span>"
	previewMessage = "It's good to slow down every now and then."
	previewSender = "Rhettifort 'Ret' Kid"

/datum/ringtone/retkid/ring7
	name = "Focused Spacechimes"
	desc = "Just some forthright holochimes straightforward about jangling in the spacewind."
	ringList = list('sound/machines/phones/ringtones/ringers8.ogg')
	ringShortList = list('sound/machines/phones/ringtones/ringershort8.ogg')
	succText = "<span class='notice'>*Ringtone set to \"ringlord8.SND\"*</span>"
	previewMessage = "Many people appreciate getting right to the point."
	previewSender = "Rhettifort 'Ret' Kid"

/datum/ringtone/retkid/ring8
	name = "ringtone.dm,58: Cannot read null.name"
	desc = "piss"
	ringList = list('sound/machines/phones/ringtones/ringers9.ogg')
	ringShortList = list('sound/machines/phones/ringtones/ringershort9.ogg')
	succText = "<span class='notice'>*Ringtone set to \"null.SND\"*</span>"
	previewMessage = "pda_ringtones.dm,575: Cannot read null.previewMessage"
	previewSender = "pda_ringtones.dm,576: Cannot read null.previewSender"
	canSpawnWith = 0

	New(obj/item/device/pda2/thisPDA)
		. = ..()
		src.desc = {"proc name: return text (/datum/computer/file/pda_program/ringtone/return_text)<br>
  source file: ringtone.dm,58<br>
  usr: null<br>
  src: ringtone.dm,58: Cannot read null.name (/datum/ringtone/retkid/ring8)<br>
  src.loc: null<br>
  call stack:<br>
ringtone.dm,58: Cannot read null.name (/datum/ringtone/retkid/ring8): return_text()<br>
"}

/datum/ringtone/retkid/ring9
	name = "Fweeuweeu"
	desc = "Flweeuweeuweeuweeuweeuweeuweeuweeu"
	ringList = list('sound/machines/phones/ringtones/ringers10.ogg')
	ringShortList = list('sound/machines/phones/ringtones/ringershort10.ogg')
	succText = "<span class='notice'>*Ringtone set to \"ringlord10.SND\"*</span>"
	previewMessage = "Flweeuweeuweeuweeuweeuweeuweeuweeu."
	previewSender = "Rhettifort 'Ret' Kid"

/// Syndicate Distracto-tones
/datum/ringtone/syndie
	name = "KABLAMMO - Realistic Explosion FX"
	desc = "HIT THE DECKS, DUCK AND COVER! Is what they'll say when they hear these 100% AUTHENTIC REALISTIC explosion effects! For licensing information, contact Ted."
	ringList = list('sound/effects/Explosion1.ogg',\
									'sound/effects/Explosion2.ogg',\
									'sound/effects/explosion_new1.ogg',\
									'sound/effects/explosion_new2.ogg',\
									'sound/effects/explosion_new3.ogg',\
									'sound/effects/explosion_new4.ogg',\
									'sound/effects/explosionfar.ogg')
	volList = list(100, 100, 100, 100, 100, 100, 100)
	varyList = list(1, 1, 1, 1, 1, 1, 1, 1)
	alertList = list("This one was fun to make. Got me some fireworks, set em on fire. Yeaaah.",\
									"Fun fact, this is actually the sound my gate makes when I hit it with a stick of dynamite!",\
									"My neighbor was blowin' up space voles one morning and it sounded <i>dope</i> so I got out my yakback and recorded that sucker! Yeah he's cool with it being here yeah.",\
									"One of my oldest boomfex, which is what I call my explosion sounds for short. Yeah I forget how I made this. Yeah.",\
									"Darn thing blew up the other thing too, so I had to leave it in, darn it.",\
									"Found a bus in the space desert, filled that sucker with gasoline and ran it off a spacecliff. Heck. Yeah. Kinda sucked. Whatever.",\
									"Oh yeah that bus actually exploded down there, raaaad.")
	pitchList = list(1, 1, 1, 1, 1, 1, 1)
	rangeList = list(15, 15, 15, 15, 15, 15, 0)
	extrarange_adjustment = -22
	listCycleType = RINGLIST_RANDOM
	succText = "*KABLAMMO installed!*"
	previewMessage = "SounDreamS Professional Ultrasystems LTD cannot be held liable for any damage done to your device's speakers."
	previewSender = "Sammy SounDreamS"
	applyText = "Apply"
	previewText = "Sample"
	nameText = "SounPacK:"
	descText = "DescrIptioN:"
	canSpawnWith = 0

	DoSpecialThing(var/index)
		animate_shockwave(src.holder)
		if(index == 6) return
		var/turf/T = get_turf(src.holder)
		for(var/client/C in clients)
			if(C.mob && (C.mob.z == T?.z))
				C << sound('sound/effects/explosionfar.ogg')
		if(prob(10))
			src.holder.bust_speaker()

/datum/ringtone/syndie/guns
	name = "Modern Commando - Realistic Gunfire FX"
	desc = "BANG BANG! These 100% AUTHENTIC REALISTIC gunfire effects are so realistic you can even hear the bullets careening toward some poor sod's lunch! For licensing information, contact THA VENGE."
	ringList = list('sound/weapons/ak47shot.ogg',\
									'sound/weapons/derringer.ogg',\
									'sound/weapons/Gunshot.ogg',\
									'sound/weapons/minigunshot.ogg',\
									'sound/weapons/railgun.ogg',\
									'sound/weapons/shotgunshot.ogg')
	volList = list(100, 100, 100, 100, 100, 100, 100)
	varyList = list(1, 1, 1, 1, 1, 1, 1, 1)
	alertList = list("SEVEN. SIX. TWO. <span style='color:#888888;font-size:40%'>RAPIDFIRE.</span>",\
									"A SMALL GUN. WITH LARGE ASPIRATIONS.",\
									"I HATE MY FUCKING NEIGHBOR.",\
									"<span style='color:#888888;font-size:80%'>MAN PORTABLE.</span> <span style='color:#888888;font-size:40%'>MAN PORTABLE.</span>",\
									"BLAST A HOLE IN MY DREAMS. <span style='color:#888888;font-size:80%'>MY DREAMS.</span> <span style='color:#888888;font-size:40%'>MY.</span> <span style='color:#888888;font-size:20%'>DREAMS.</span>",\
									"ALCOHOL IS A SIN.")
	pitchList = list(1, 1, 1, 1, 1, 1, 1)
	rangeList = list(5, 5, 5, 5, 5, 5, 5)
	extrarange_adjustment = -22
	listCycleType = RINGLIST_RANDOM
	succText = "*Modern Commando installed!*"
	previewMessage = "Ready to serve up your project a nice hot cup of lead? Or, rather, a set of sound effects that give that impression?"
	previewSender = "Sammy SounDreamS"
	applyText = "Apply"
	previewText = "Sample"
	nameText = "SounPacK:"
	descText = "DescrIptioN:"

	DoSpecialThing(var/index)
		var/timesToDoIt = 1
		var/howQuicklyToDoIt = 4
		switch(index)
			if(1)
				timesToDoIt = 2
				howQuicklyToDoIt = 1
			if(2)
				timesToDoIt = 1
				howQuicklyToDoIt = 4
			if(3)
				timesToDoIt = 2
				howQuicklyToDoIt = 4
			if(4)
				timesToDoIt = 7
				howQuicklyToDoIt = 0.7
			if(5)
				timesToDoIt = 1
				howQuicklyToDoIt = 4
			if(6)
				timesToDoIt = 2
				howQuicklyToDoIt = 4
		SPAWN(0)
			for(var/i in 1 to timesToDoIt)
				sleep(howQuicklyToDoIt)
				MakeSoundPlay(index)
				animate_shockwave(src.holder)
				if(prob(1))
					src.holder?.bust_speaker()

	proc/MakeSoundPlay(var/index)
		if(!src.holder || index > length(src.ringList))
			return 1
		playsound(src.holder, src.ringList[index], src.volList[index], src.varyList[index], pitch = src.pitchList[index])

/datum/ringtone/syndie/lasersword
	name = "SPACEBATTLE - Realistic Sci-Fi FX"
	desc = "VOOSH! VHWAAAM! Louden up those climactic space battles -- GOOD versus SPACE -- with these 100% AUTHENTIC REALISTIC sci-fi sword-fight effects! For licensing information, contact Stern. <br> Text MALE or FEMALE followed by OPEN, CLOSE, HIT to this PDA to change the type of sword-sound. For example, 'MALE HIT' to set the sound set to the male-sword-hit-thing sounds!"
	ringList = list('sound/weapons/female_cswordturnon.ogg')
	volList = list(100, 100)
	varyList = list(1, 1)
	alertList = list("hi.",\
									"heyo")
	pitchList = list(1, 1)
	rangeList = list(5, 5)
	extrarange_adjustment = -22
	listCycleType = RINGLIST_RANDOM
	succText = "*SPACEBATTLE installed!*"
	previewMessage = "Do note that some viewers will complain about being able to hear space battles in space."
	previewSender = "Sammy SounDreamS"
	applyText = "Apply"
	previewText = "Sample"
	nameText = "SounPacK:"
	descText = "DescrIptioN:"
	readMessages = 1
	var/list/openSwordMale = list('sound/weapons/male_cswordturnon.ogg')
	var/list/openSwordFemale = list('sound/weapons/female_cswordturnon.ogg')
	var/list/closeSwordMale = list('sound/weapons/male_cswordturnoff.ogg')
	var/list/closeSwordFemale = list('sound/weapons/female_cswordturnoff.ogg')
	var/list/ringListMale = list('sound/weapons/male_cswordattack1.ogg', 'sound/weapons/male_cswordattack2.ogg')
	var/list/ringListFemale = list('sound/weapons/female_cswordattack1.ogg', 'sound/weapons/female_cswordattack2.ogg')

	DoSpecialThing(index)
		animate_shockwave(src.holder)
		if(prob(5))
			src.holder.bust_speaker()

	MessageAction(var/data)
		switch(data)
			if("MALE OPEN")
				src.ringList = src.openSwordMale
			if("FEMALE OPEN")
				src.ringList = src.openSwordFemale
			if("MALE CLOSE")
				src.ringList = src.closeSwordMale
			if("FEMALE CLOSE")
				src.ringList = src.closeSwordFemale
			if("MALE HIT")
				src.ringList = src.ringListMale
			if("FEMALE HIT")
				src.ringList = src.ringListFemale
			else
				return
		src.ringListIndex = 1
		. = ..()

#undef RINGLIST_STATIC
#undef RINGLIST_CYCLE
#undef RINGLIST_RANDOM
