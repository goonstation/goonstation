// I have no idea what I'm doing here.
// I don't know what any of this is.
//
// So... yep.

/area/nomad

/area/nomad/outside
	name = "Distant Place"
	icon_state = "purple"
	ambient_light = rgb(42, 40, 45)
	requires_power = 0

	filler_turf = "/turf/unsimulated/dirt"
	sound_environment = 3
	skip_sims = 1
	sims_score = 0
	sound_group = "nomad"
	sound_loop = 'sound/ambience/nature/Rain_Heavy.ogg'

	New()
		..()

		overlays += image(icon = 'icons/turf/areas.dmi', icon_state = "rain_overlay", layer = EFFECTS_LAYER_BASE)


/area/nomad/inside
	name = "Nomad's Abode"
	icon_state = "green"
	ambient_light = rgb(0, 0, 0)
	requires_power = 0
	sound_group = "nomad"
	sound_loop = 'sound/ambience/nature/Rain_Heavy.ogg'
	sound_loop_vol = 70
	sound_environment = 15

/area/nomad/inside/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_AREA_PROCESS)

/area/nomad/inside/disposing()
	STOP_TRACKING_CAT(TR_CAT_AREA_PROCESS)
	. = ..()

/area/nomad/inside/area_process()
	if(prob(20))
		src.sound_fx_2 = pick('sound/ambience/nature/Rain_ThunderDistant.ogg',\
			'sound/ambience/nature/Wind_Cold1.ogg',\
			'sound/ambience/nature/Wind_Cold2.ogg',\
			'sound/ambience/nature/Wind_Cold3.ogg')

		for(var/mob/living/carbon/human/H in src)
			H.client?.playAmbience(src, AMBIENCE_FX_2, 50)


/datum/computer/file/record/nomad/story_01
	name = "20530000"
	fields = list(
	"Subject: Observations",
	"Date: 2053-00-00 00:00",
	"---------------------------------------",
	"I have a feeling that this universe is",
	"experiencing a 'chronophenomenon'.",
	"I don't know what, exactly, is going",
	"on, but I've made some quite peculiar",
	"observations. I will try to describe",
	"these in a way someone else can",
	"understand, even though I myself",
	"do not."
	)
/datum/computer/file/record/nomad/story_02
	name = "20530000a"
	fields = list(
	"Subject: Cause and effect",
	"Date: 2053-00-00 00:00",
	"---------------------------------------",
	"Cause and effect isn't working. Its",
	"direct effects are observable - punch",
	"something and it will hurt - but the",
	"long-term ramifications of this appear",
	"to be missing.",
	"",
	"Consider the case of employees aboard",
	"Nanotrasen's outposts. During a covert",
	"interview, one subject was asked if",
	"they had undergone any training for",
	"the job they were doing. They claimed",
	"to have no memory of any such training,",
	"yet they were extemely skilled at the",
	"tasks required, and had knowledge that",
	"could have only come from doing that",
	"job for a long time."
	)

/datum/computer/file/record/nomad/story_03
	name = "20530000b"
	fields = list(
	"Subject: Time loops?",
	"Date: 2053-00-00 00:00",
	"---------------------------------------",
	"One potential theory we have come up",
	"with is that the universe is undergoing",
	"some kind of 'time loop', where time",
	"progresses, but resets after a point.",
	"",
	"There is some evidence to support this.",
	"We have data recovered from expeditions",
	"that does not reflect reality. Places",
	"that have had their valuables pilfered",
	"appearing as if nothing was ever",
	"touched. Places that were destroyed",
	"and their destruction recorded in video",
	"still existing, good-as-new."
	)

/datum/computer/file/record/nomad/story_04
	name = "20530000c"
	fields = list(
	"Subject: None of this makes sense.",
	"Date: 2053-00-00 00:00",
	"---------------------------------------",
	"We've found that some of our own",
	"records are no longer consistent with",
	"our knowledge of them. Things are",
	"changing out from under us. We cannot",
	"be sure that what we know is even the",
	"truth. While we suspected something",
	"like this before, having it affect",
	"our own archives has thrown us into",
	"darkness.",
	"",
	"If we can't trust ourselves,",
	"what CAN we trust?",
	""
	)

/datum/computer/file/record/nomad/story_05
	name = "20530000d"
	fields = list(
	"Subject: Recording is all we can do.",
	"Date: 2053-00-00 00:00",
	"---------------------------------------",
	"We're continuing to monitor what we",
	"can. The dates on our archives are,",
	"slowly but surely, being lost. Numbers",
	"vanish, as if they had never been",
	"written; despite this, the rest of the",
	"text appears to be largely the same.",
	"",
	"Some of the locations we have been",
	"watching undergo sudden changes in",
	"their state. Nothing is directly",
	"observed to cause it, but it is",
	"undoubtable that change has happened.",
	"",
	"Perhaps...",
	""
	)

/datum/computer/file/record/nomad/story_06
	name = "20530000e"
	fields = list(
	"Subject: Changes",
	"Date: 2053-00-00 00:00",
	"---------------------------------------",
	"We managed to observe one of these",
	"changes occur right in front of us.",
	"We were watching a group of explorers",
	"investigating a certain location. They",
	"had been here before - in that they,",
	"too, knew the location of the secret",
	"tunnels and passages - yet checking",
	"the records aboard their outpost showed",
	"that day was their first deployment.",
	"There was no way they could have been",
	"here before!",
	"",
	"And yet, that is clearly the case.",
	"Something is wrong.",
	"",
	"The next observation, everything had",
	"once again gone back to how it was.",
	"It was as if none of those explorers",
	"had been there.",
	"",
	"But something was different."
	)

/datum/computer/file/record/nomad/story_07
	name = "20530000f"
	fields = list(
	"Subject: Suspicions",
	"Date: 2053-00-00 00:00",
	"---------------------------------------",
	"There is no time loop. Not in the usual",
	"sense, where everything is undone and",
	"the day begins as if the previous never",
	"happened.",
	"",
	"People are remembering the skills they",
	"have, but not how they got them. They",
	"remember the people they work with,",
	"even when neither employee has worked",
	"with one another before.",
	"",
	"The places we watch remain static for",
	"long periods of time. Sometimes, minor",
	"things change. An object is somewhere",
	"else. Lights become broken. New things",
	"that were never there before can be",
	"found.",
	"",
	"Perhaps... Some things are recorded.",
	"The universe itself adjusts and changes,",
	"and the next day, it is as if it had",
	"always been that way.",
	"",
	"But if that is the case...",
	""
	)

/datum/computer/file/record/nomad/story_08
	name = "20539999"
	fields = list(
	"Subject:",
	"Date: 2053-99-99 99:99",
	"---------------------------------------",
	"",
	"Are we the ones who are",
	"discovering the truth?",
	"",
	"... Or could it be that, in trying to",
	"understand the truth, we create it?",
	""
	)

/datum/computer/file/record/nomad/story_09
	name = "99999999"
	fields = list(
	"Subject: 7",
	"Date: 9999-99-99 99:99",
	"---------------------------------------",
	"Why do you keep turning the keys?",
	"Even though the outcome never changes,",
	"and our world is destroyed, every time.",
	"",
	"Are you simply hoping that something,",
	"anything will change? That you'll",
	"find some way to change the ending?",
	"",
	"We don't know how you got here, or why.",
	"We don't have any answers for you.",
	"We are simply characters in this story.",
	"",
	"Just like you."
	)


/obj/item/disk/data/fixed_disk/nomad_computer

	New()
		..()

		var/datum/computer/folder/newfolder = new /datum/computer/folder(  )
		newfolder.name = "diary"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/record/nomad/story_01 (src))
		newfolder.add_file( new /datum/computer/file/record/nomad/story_02 (src))
		newfolder.add_file( new /datum/computer/file/record/nomad/story_03 (src))
		newfolder.add_file( new /datum/computer/file/record/nomad/story_04 (src))
		newfolder.add_file( new /datum/computer/file/record/nomad/story_05 (src))
		newfolder.add_file( new /datum/computer/file/record/nomad/story_06 (src))
		newfolder.add_file( new /datum/computer/file/record/nomad/story_07 (src))
		newfolder.add_file( new /datum/computer/file/record/nomad/story_08 (src))
		newfolder.add_file( new /datum/computer/file/record/nomad/story_09 (src))

		newfolder = new /datum/computer/folder
		newfolder.name = "bin"
		src.root.add_file( newfolder )
		newfolder.add_file( new /datum/computer/file/terminal_program/writewizard(src))


/obj/machinery/computer3/generic/nomad_computer
	name = "broken computer"
	desc = "This computer has definitely seen better days."
/*	icon = 'icons/obj/computer.dmi'
	icon_state = "computer_generic"
	base_icon_state = "computer_generic"
	setup_frame_type = /obj/computer3frame //What kind of frame does it spawn while disassembled.  This better be a type of /obj/compute3frame !!
*/
	setup_drive_type = /obj/item/disk/data/fixed_disk/nomad_computer

	New()
		..()
		SPAWN(3 SECONDS)
			set_broken()


/*/datum/telescope_event/nomad
	name = "Nomad"
	name_undiscovered = "Teleport beacon"
	id = "nomad"
	size = 15
	tags = TAG_PLANET | TAG_TELEPORT_LOC

	New()
		..()
		telescopeDialogue = new/datum/dialogueMaster/telescopeNomad(src)*/


/datum/dialogueMaster/telescopeNomad
	dialogueName = "Nomad"
	start = /datum/dialogueNode/telNomadStart
	visibleDialogue = 0

/datum/dialogueNode
	telNomadStart
		nodeImage = "static.png"
		nodeText = "Long-range teleport beacon located within a structure. Further scans inconclusive."
		linkText = "..."
		links = list(/datum/dialogueNode/telNomadEnable)

	telNomadEnable
		linkText = "Save the location."
		nodeText = "The location is now available at the long-range teleporter."

		onActivate(var/client/C)
			if(!special_places.Find("Nomad"))
				special_places.Add("Nomad")
				var/datum/computer/file/coords/CO = new()
				CO.destx = 258
				CO.desty = 19
				CO.destz = 2
				special_places["Nomad"] = CO
			return

		canShow(var/client/C)
			if(!special_places.Find("Nomad"))
				return 1
			else
				return 0


/*
/datum/telescope_event/nomad
	name = "???"
	name_undiscovered = "Unknown signal"
	desc = "???<br>Co-ordinates have been uploaded to the long-range teleporter."
	id = "nomad"
	icon = "found.png"
	size = 30
	tags = TAG_TELEPORT_LOC
	contact_verb = "SCAN"
	contact_image = "termplate2.png" //Alternative image of the object for the contact screen. otherwise icon is used.

	onActivate(var/obj/machinery/computer/telescope/T)
		..()
		if(!special_places.Find(name))
			special_places.Add(name)
			var/datum/computer/file/coords/C = new()
			C.destx = 255
			C.desty = 3
			C.destz = 2
			special_places[name] = C
		return
*/
