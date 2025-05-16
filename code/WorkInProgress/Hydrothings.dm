//Content related to Operation Fuckable Owls
/obj/decal/floor/displays/owlsign
	icon = 'icons/misc/Owlzone.dmi'
	icon_state = "owlsign-left"

/obj/item/paper/postcard/owlery
	name = "Owlery post card"
	desc = "It's pretty scuffed up. Someone has scrawled the words 'ROAD TRIP? Call Me! -J' on the back."
	icon_state = "postcard-owlery"
	interesting = "There are traces of hydrocarbons, collagens, proteins, and sugars deposited in the cellulose of the card"

	sizex = 1040
	sizey = 705

	New()
		..()
		pixel_x = rand(-8, 8)
		pixel_y = rand(-8, 8)
		info = "<html><body style='margin:2px'><img src='[resource("images/arts/postcard_Owlery.png")]'></body></html>"

	examine()
		return ..()

	attackby()
		return

/obj/item/paper/bombininote
	name = "smelly note"
	interesting = "There are traces of Escherichia Coli, Salmonella, and synthetic grasslike fibers dusted across the note. The handwriting seems mechanical."
	desc = "A note which smells faintly of... Owls?"
	icon_state = "paper"
	info = {"We have your Bee, Bombini. We want 5 mill-ion dosh credits or your Bee friend will be spaced. Do not try to HOOTIN find us. We are very powerful and our location is impossible to find. -THE OWLS
		<br>
		<br><b>(This message brought to you by Gaggle Translation services, this message was translated to ENGLISH from OWL.)"}

/obj/item/paper/paperwelcome
	name = "paper- 'crumpled paper'"
	desc = "This paper seems like a script for a speech, it's all crumpled up."
	interesting = "A faint scent of butterscotch lingers on this paper"
	icon_state = "paper"
	info =  {"<i>*cheerful*</i>Hallo and Welcome to the newly reopened Frontier Space Owlery!
			<br>I'm Professor Reuben van der Hootens and I'm glad you're here! You're just in time for Hootenany Week 2053.
			<br><i> *pause, cough out loud*</i>
			<br><i> *speak quietly, rushed* </i>Due to ongoing and completely unfounded litigation, all persons entering this facility
			<br>hereby fully waive all liability for any and all incidental damages or injuries.
			<br>The Frontier Space Owlery is not responsible for any injury, loss, or damage sustained by any
			<br>persons within the Owlery facilities under any circumstances.
			<br><i> *cough loudly*</i>
			<br><i> *sip water*</i>
			<br><i> *cheerful* </i> Sorry about that folks! Have a safe and happy visit, bedankt, we have just a few rules to go over.
			<ul>
			<li>Keep your hands to yourselves at all times</li>
			<li>Do not feed the owls</li>
			<li>Do not make extended eye contact with the owls</li>
			<li>Do not hoot at the owls, they find this very rude</li>
			<li>Do not leave any objects or possessions in the Owldome</li>
			<li>Do be sure to visit the Gift Shop next to the Cafeteria</li>
			</ul>
			<br>We appreciate your cooperation, and so will the owls!
			<h5>The rest of the note is torn off.</h5>"}

/obj/item/paper/rippednote
	name = "paper- 'torn Up paper'"
	desc = "This paper is barely able to be read, it looks like a bird ripped it up or something."
	icon_state = "paper"
	info = {"Kyle, I'm leaving this note here for when you find this. <i>What. The. Fuck.</i>
			<br>Why did you decide this was a good spot for an APC? Come on man.
			<br>The birds are going to destroy this thing here. Get this fixed you idiot and report to my office once you're done. -Alex"}

/obj/item/paper/hootening
	name = "paper- 'Experiment #620'"
	desc = "An experiment log, part of it is obscured by a coffee stain."
	icon_state = "paper"
	info = {"<b>Experiment Log #620.</b>
			<br>
			<br>Hypothesis: Slow infusion of mutagens, stimulants, and Space Owl blood administered to captive SUBJECT #620-JA may induce
			<br>glandular synthesis of the Hootagen compound. Cardiac stimulants included in mixture to avoid a repeat of Experiment #613.
			<br>
			<br>Hour 1: Beginning IV-transfusion of owl blood, mutagen and stimulant mixture to sedated SUBJECT #620-JA.
			<br>Subject awakened immediately in significant distress. H.R. 125 bpm, B.P. 145/85
			<br>Hour 2: Subject exhibiting 23% increased activity of the amygdala region and 28% increased blood serum levels of adrenaline.
			<br>H.R. 158 bpm. B.P. 185/98
			<br>Hour 3: Subject displaying onset of desired genetic drift. Additional 35% amygdala activation and addtional 42% rise of adrenaline count.
			<br>Subject experiencing brief seizures. H.R. 229 bpm, B.P. 248/125, severe arryhthmia.
			<br>Hour 4: Morphology changes consistent with Space Owl morphology continue steadily. Subject deliriously agitated. Snapped off three needles while I was
			<br>extracting blood samples. Attempting to administer haloperidol.
			<br>Hour 5: Halo FAILED suject brokem restraint  , arm is broken. have
			<br>been forced to seal and abandon  chamber  samples INTACT "}

/obj/item/paper/cleanerorder
	name = "paper- 'Mission Statement'"
	icon_state = "paper"
	info = {"<b>Mission Statement for NT/SEC/FORN #36322</b>
			<br>Arrange civilian transport to Designated Facility (DF) 'Frontier Space Owlery' under assigned cover, rank: Substitute Custodian
			<br>Note: This job position has been opened by on-site agent NT/SCI #41903 for you.
			<br>
			<br>
			<br>RESTRICTIONS: UNDER NO CIRCUMSTANCES ARE YOU TO DAMAGE THE FACILITY AT LARGE OR HARM THE OWLS
			<br>Maintain discretion and cover to prevent any unnecessary conflict with non-cleared facility employees
			<br>
			<br>Objectives:
			<br>NT/SCI #41903 requests total data recovery and forensics redaction within the verbally described Clandestine Compartment (CC).
			<br>Recover all primary documents within CC and destroy all further copies
			<br>Recover all chemical and biological samples within CC with strict adherence to HAZ/BIO/L3 exfiltration procedures
			<br>Terminate and redact hostile SUBJECT 620-JA within the CC Operating Chamber
			<br>Perform a complete Chemical Redaction deployment against all forensic vectors and surfaces within the CC
			<br>Secure CC entrance from unauthorized access or discovery
			<br>Depart from DF with all recovered materials and assets and discreetly return to Minerva-5 for debriefing by NT/ADMIN/SCI #51352
			<br>
			<br>Mission Equipment:
			<ul>
			<li>1 Light Machine Gun with 3 Clips (CONDITION: USE ONLY IN CASE OF EXISTENTIAL THREAT TO FACILITY)
			<li>1 .22 Caliber Suppressed Sidearm with 3 Clips (CONDITION: SELF-DEFENSE)
			<li>10 Stealth Storages
			<li>6 BLAM!-brand Cleaning Grenades
			<li>1 'Sleepypen' Ketamine Injector (CONDITION: OPERATIONAL SECURITY)"}

/obj/item/paper/cargoinvoice
	name = "paper- 'Daily Order'"
	desc = "This paper is barely able to be read, it looks like someone spilled coffee on it."
	icon_state = "paper"
	info = {"<b>Frontier Space Owlery: Daily Order</b>
			<br>
			<br>Shipment Contents:
			<br><li>4 5-liter jugs of Hootin' Dan's Owl Nutrients
			<br><li>5 Crates 144/ct Donk Pockets, Frozen
			<br><li>1 copy of "A Qualitative Metholodogy of Applied Mutagenics, Vol. 3" by Dr. Amy Habicht."}

/obj/item/paper/shuttle_heist
	name = "DEAR FIRST SHIFT TEAM"
	desc = "This note looks ANGRY."
	icon_state = "paper"
	info = {"<b>WHY: I ASK YOU</b>
			<br>
			<br>WHY
			<br>WHY did you idiots let some drunk-ass drifter into our cargo dock
			<br>WHY did you believe him when he said he works here
			<br>WHY did you let him haul away a bunch of our kitchen crates
			<br>AND WHY did you let him STEAL ONE OF OUR GODDAMN SHUTTLES"}

/obj/item/paper/randomencounter
	name = "paper- 'Weird-ass guy'"
	icon_state = "paper"
	info = {"Hey its me Jacob, shifts have just about changed but we ran into a crazy dude just now.
		<br>Guy came running in from the tour route holding a fucking flamethrower!
		<br>We were able to take him down before he could use the fucking thing. But im not really sure what to do with his stuff. For now we left it inside the confiscated items locker."}

/obj/item/paper/getaway
	name = "paper- 'Experiment #621: Success'"
	icon_state = "paper"
	info = {"As of writing this experiment #621 has been a success. With the blood samples from Experiment #620, I have finally created a reliable synthesis method for this 'Hootagen' shit.
			<br>I will be presenting my findings in person to AH and the Professor at Aurora's. I'll have to leave James in charge here.
			<br>He's an idiot but I doubt he could fuck up too badly in just a couple days.
			<br>Had to tell the crew here I busted my arm when I slipped on spilled coffee. Blamed Addle for it and wrote him up, he's a klutz anyways.
			<br>I'll call in a cleaner to wipe this lab down, can't be too careful nowadays with NT snooping around everywhere."}

/obj/item/paper/fuckingidiot
	name = "paper- 'Memo'"
	icon_state = "paper"
	info = {"Hey Alex, James here. Just leaving this note here for when you come back. Kyle and I were fixing a disposals jam and found one of the missing jugs of Owl Nutrients stuck in one of the tubes.
			<br>Dang janitor must have tossed some full jugs out by accident before he took off. So I tossed it in with the rest of the supplies. Kinda gross, why's this Formula 620 stuff smell like rotting plants?
			<br>Are you buying from a new producer? I heard it's unhealthy to switch owl feed brands like that."}

/obj/item/paper/failedexperiment
	name = "paper- 'Experiment #616 results'"
	icon_state = "paper"
	info = {"Experiment #616 has been a failure, the chemical synthesis method again did not yield the "Hootagen" I seek.
			<br>Strangly though instead of the usual flash, explosion or dangerous gas reaction it seems it preciptated into a drab green substance smelling of decayed vegetation.
			<br>I am experiencing severely intrusive violent thoughts and a really fucking bad headache I suspect stemmed from this brief exposure. Should be more careful around this fucking owl gunk."}

/obj/item/paper/employment
	name = "paper- 'New Horizons'"
	icon_state = "paper"
	info = {"So since this started happening I have decided to begin keeping a journal incase this all blows up in my face.
			<br>Recently I was contacted by my old college friend Amy on behalf of her employer. Seems this Professor Hootens guy heard about my incident getting fired from NT14.
			<br>He needs someone with my kinda background and rap sheet in advanced chemistry and genetics to do some classified research with Owls.
			<br>Yep. Friggin' owl guy from the broadcasts needs me for some cloak and dagger shit.
			<br>The deal is I'm supposed to run this tourist trap for the public, but secretly, continue the last RD's research on this synthetic compound named "Hootagen."
			<br>Really weird vibe from this Professor fella but the pay and stock options are wild.
			<br>Apparently the last guy on this assignment died from self inflicted stress wounds. He managed to ruin most of his research notes in the incident too, what an asshole.
			<br>
			<br>They have assigned me command of this small station on the frontier as Research Director and have a provided a significant operations budget
			<br>with the expectation that I'll keep up appearances for the normal tourist nonsense while I'm here.
			<br>So I have decided, probably against my better judgment to accept their offer. I can only hope these guys don't plan to off me once its all said and done. -Dr. Alex Cornwall, PhD."}

/obj/item/paper/hootagenhint
	name = "paper- 'Hootagen Research Notes'"
	icon_state = "paper"
	info = {"Do research on things that turn into other things because you need to turn the person into another thing? Like a chameleon but different maybe?
			<br>
			<br>How the fuck am I supposed to turn somebody into an owl without them fucking dying?
			<br>
			<br>What do owls do? Fly? How the fuck can a human fly thats impossible."}

/obj/item/paper/janitorlist
	name = "steve's daily notes"
	icon_state = "paper"
	info = {"<h3>steve's daily notes</h3>
			<hr>
			<p>
			<br>grand re-opening week is almost here
			<br>this place needs to sparkle!
			</p>
			<p>
			<br><i>6:30 - 7:00</i>
			<br>sorted and ejected overnight disposals
			<br>minimal trash
			<br>
			<br><i>7:00 - 9:00</i>
			<br>cleaned owl pens after morning feeding
			<br>sanitized owl feeding troughs
			<br>friggin' Bitey ruined another one of my mops
			<br>need to order some spares tonight
			<br>
			<br><i>9:00 - 9:30</i>
			<br>skimmed filtration pond
			<br>filters 4 and 7 will need to be replaced soon
			<br>waste water storage at 65% capacity
			<br>fresh water reservoirs at 77% capacity
			<br>
			<br><i>9:45 - 11:30</i>
			<br>inspected and cleaned owl dome
			<br>pathways and water features cleaned
			<br>raked up dead foliage
			<br>disposed of 6 owl pellets, birds have been busy
			<br>
			<br>
			<br><i>11:30 - 13:00</i>
			<br>shower break, lunch with Greg
			<br>
			<br><i>13:00 - 14:00</i>
			<br>scrubbed and waxed cafeteria floors. lookin good!
			<br>repaired loose sink knob in cafe
			<br>we're not even open to the public yet, who
			<br>keeps sticking gum under the tables?
			<br>
			<br><i>14:00 - 15:00</i>
			<br>cleaned kitchen floors and fixtures, chatted with chef about opening week preparations.
			<br>sloppy joes tomorrow!
			<br>
			<br><i>15:00 - 16:30</i>
			<br>cleaned lobby, main hall junction, annex, public restrooms
			<br>tidied up the prof hootens bot, got it all nice and polished up
			<br>real hootens is gonna be here in a couple days, don't wanna disappoint!
			<br>always a big day when he's around
			<br>
			<br><i>16:30 - 17:45</i>
			<br>cleaned staff wing and head offices. restocked restrooms.
			<br>
			<br><i>17:45 - 18:30</i>
			<br>swept maintenance tunnels. found a leak in the plumbing near the office wing.
			<br>NOT water. corrosive puddle burned up another of my damn mops!
			<br>schematics don't indicate any hazardous materials plumbing around this area
			<br>who the hell installed this?
			<br>needs further inspection, this shit ain't safe
			<br>
			<br><i>19:45</i>
			<br>found even more non-standard plumbing containing volatile liquids. lacks proper labelling. serious fire and safety risks!
			<br>cornwall has no idea what i'm talking about and said that area is off limits and that i should mind my own business
			<br>does james know about this?
			<br>safety is never off limits!! this IS my business!
			<br>now i gotta write up another friggin incident report and a formal complaint
			</p>"}

/obj/item/audio_tape/beecrash
	New()
		..()
		messages = list("Jeez B, I think we emptied out your keg, you sure it's safe to be flying around this late?",
	"*rowdy buzzing*",
	"*rowdy hooting*",
	"*BANG*",
	"*KEEERRUUUUUUNCHHHH*",
	"*alarms*",
	"*hissing air*",
	"...",
	"Bombini, are you alright? Damn you really messed up your ship.",
	"*solemn buzzing*",
	"*reassuring hoots*",
	"I think we should get out of here guys!")
		speakers = list("Robotic voice", "Bombini", "Unknown Owl", "???", "***", "!!!", "???", "...", "Robotic voice", "Bombini", "Unknown Owl", "Robotic voice")

/obj/item/audio_tape/beepoker
	New()
		..()
		messages = list("Come on B, cheer up! You're on quite the winning streak tonight!",
	"*buzzing*",
	"*pondering hoots*",
	"Alright everyone place your bets.",
	"...",
	"Bombini raises. Bitey raises. Fluffums folds.",
	"*pensive hoots*",
	"Bombini raises. Bitey raises.",
	"Erm, Bombini are you sure? Do you even have that kind of cash?",
	"*confident buzzing*")
		speakers = list("Robotic voice", "Bombini", "Unknown Owl", "Robotic voice", "???", "Robotic voice", "Unknown Owl", "Robotic voice", "Bombini")

// setpiece decals

/obj/fakeobject/pipe/radioactive
	desc = "This pipe is kinda warm. Huh."
	interesting = "Radiological decay detected."

/obj/fakeobject/pipe/sarin // will change to saxitoxin after updating owlery map file
	desc = "This pipe seems totally normal."
	interesting = "Trace amounts of hazardous nerve agent detected."

/obj/fakeobject/pipe/acid
	desc = "This pipe is pretty corroded around the fittings. Huh."
	interesting = "Pipe fittings and adjacent metals exhibit damage consistent with exposure to strong acids."


//FUCKABLE ITEMS

/obj/item/card/id/owlmaint
	icon_state = "id_com"
	access = list(access_owlerymaint)
	registered = null
	assignment = null
	title = null

/obj/item/card/id/owlsecurity
	icon_state = "id_sec"
	access = list(access_owlerysec)
	registered = null
	assignment = null
	title = null

/obj/item/card/id/owlgold
	name = "identification card"
	icon_state = "id_gold"
	item_state = "gold_id"
	desc = "This card is important!"
	access = list(access_owlerycommand, access_owlerysec, access_owlerymaint)
	registered = null
	assignment = null
	title = null

/obj/fakeobject/bustedpod
	name = "Busted Escape Pod"
	desc = "A escape pod for escaping. It seems to be busted."
	icon = 'icons/obj/ship.dmi'
	icon_state = "escape"
	density = 1
	anchored = ANCHORED

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/owl/madness
	critter_type = /obj/critter/madnessowl

/obj/item/gnomechompski/elf
	name = "Gnelf Cnompski"
	desc = "Wait this isn't a gnome..."
	icon = 'icons/obj/junk.dmi'
	icon_state = "gnelf"
	item_state = "gnome"

/obj/item/gun/russianhootolver
	desc = "Rootin hootin tootin fun for the whole family!"
	name = "Russian Hootolver"
	icon = 'icons/obj/items/guns/kinetic.dmi'
	icon_state = "hootolver"
	w_class = W_CLASS_NORMAL
	throw_speed = 2
	throw_range = 10
	m_amt = 2000
	contraband = 0
	var/shotsLeft = 0
	var/shotsMax = 6

	New()
		src.shotsLeft = rand(1,shotsMax)
		..()
		return

	attack_self(mob/user as mob)
		reload_gun(user)

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		fire_gun(user)

	proc/fire_gun(mob/user as mob)
		if(src.shotsLeft > 1)
			src.shotsLeft--
			for(var/mob/O in AIviewers(user, null))
				if (O.client)
					O.show_message(SPAN_ALERT("[user] points the gun at [his_or_her(user)] head. Wonk!"), 1, SPAN_ALERT("Wonk!"), 2)
					playsound(user, 'sound/vox/wonk.ogg', 70, TRUE)

			return 0
		else if(src.shotsLeft == 1)
			src.shotsLeft = 0
			playsound(user, 'sound/voice/animal/hoot.ogg', 70, TRUE)
			for(var/mob/O in AIviewers(user, null))
				if (O.client)	O.show_message(SPAN_ALERT("<B>HOOT!</B> [user] explodes revealing an owl within."), 1, SPAN_ALERT("You hear an owl."), 2)
				SPAWN(1 DECI SECOND)
				user.owlgib()
			return 1
		else
			boutput(user, SPAN_NOTICE("You need to reload the gun."))
			return 0

	proc/reload_gun(mob/user as mob)
		if(src.shotsLeft <= 0)
			user.visible_message(SPAN_NOTICE("[user] finds a bullet on the ground and loads it into the gun, spinning the cylinder."), SPAN_NOTICE("You find a bullet on the ground and load it into the gun, spinning the cylinder."))
			src.shotsLeft = rand(1, shotsMax)
		else if(src.shotsLeft >= 1)
			user.visible_message(SPAN_NOTICE("[user] spins the cylinder."), SPAN_NOTICE("You spin the cylinder."))
			src.shotsLeft = rand(1, shotsMax)

/obj/item/plutonium_core/hootonium_core
	name = "Hootonium Core"
	desc = "A core of pure Hootonium, you can feel immense power radiating from within it."
	icon = 'icons/misc/owlzone.dmi'
	icon_state = "hootonium"
	ability_path = /obj/ability_button/owl_slam
	var/chosen = 0

	attack_self(mob/user as mob)
		var/input = tgui_alert(user, "Would you like to attempt to absorb the core into your body?", "Hoot or not to hoot.", list("Yes", "No"))
		if (input == "Yes" && chosen == 0)
			chosen = 1
			user.visible_message(SPAN_ALERT("<b>[user] absorbs the [src] into their body!"))
			sleep(1.5 SECONDS)
			playsound(user.loc, 'sound/items/eatfood.ogg', rand(10,50), 1)
			user.reagents.add_reagent("hootonium", 10)
			qdel(src)

/datum/ailment/disease/hootonium
	name = "Hyperhootemia"
	scantype = "Virus"
	cure_flags = CURE_CUSTOM
	cure_desc = "Space Owl Diffusion"
	max_stages = 3
	associated_reagent = "hootonium" // associated reagent, duh

/datum/ailment/disease/hootonium/on_infection(mob/living/affected_mob, datum/ailment_data/D)
	. = ..()
	affected_mob.add_vomit_behavior(/datum/vomit_behavior/owl)

/datum/ailment/disease/hootonium/on_remove(mob/living/affected_mob, datum/ailment_data/D)
	. = ..()
	affected_mob.remove_vomit_behavior(/datum/vomit_behavior/owl)

/datum/ailment/disease/hootonium/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	if (probmult(30))
		affected_mob.nauseate(2)
	switch(D.stage)
		if(1)
			if (probmult(25))
				boutput(affected_mob, "<B>[pick("It feels wrong, I feel wrong.", "Am I okay?", "I can feel it, its under my skin.", "I need help, I WANT HELP!")]<B/>")
			if (probmult(50))
				affected_mob.make_jittery(25)

		if(2)
			playsound(affected_mob, 'sound/effects/HeartBeatLong.ogg', 70, TRUE)
			if (probmult(50))
				for(var/mob/O in viewers(affected_mob, null))
					playsound(O, 'sound/voice/animal/hoot.ogg', 70, TRUE)
					O.show_message(SPAN_ALERT("<B>[affected_mob]</B> hoots uncontrollably!"), 1)
				affected_mob.changeStatus("stunned", 10 SECONDS)
				affected_mob.changeStatus("knockdown", 10 SECONDS)
				affected_mob.make_jittery(250)
				affected_mob.drop_item()
				affected_mob.hand = !affected_mob.hand
				affected_mob.drop_item()
				affected_mob.hand = !affected_mob.hand
			if  (probmult(35))
				boutput(affected_mob, "<B>[pick("Oh g-HOOT", "Whats happe-ho-ing to me?", "It hurts!")]</B>")

		if(3)
			if(probmult(25))
				boutput(affected_mob, SPAN_ALERT("You feel your skin getting rougher!"))
				boutput(affected_mob, SPAN_ALERT("Your body convulses painfully!"))
			if(probmult(25))
				affected_mob.drop_item()
				affected_mob.hand = !affected_mob.hand
				affected_mob.drop_item()
				affected_mob.hand = !affected_mob.hand
				random_brute_damage(affected_mob, 5)
				affected_mob.take_oxygen_deprivation(5)
				affected_mob.changeStatus("stunned", 10 SECONDS)
				affected_mob.changeStatus("knockdown", 10 SECONDS)
				affected_mob.make_jittery(250)
				for(var/mob/O in viewers(affected_mob, null))
					playsound(O, 'sound/voice/animal/hoot.ogg', 70, TRUE)
					O.show_message(SPAN_ALERT("<B>[affected_mob]</B> hoots uncontrollably!"), 1)
			if(probmult(25))
				boutput(affected_mob, "<B>[pick("Who-WHO", "HOoooT", "neST!")]</B>")
			if(probmult(10))
				var/obj/critter/hootening/P = new/obj/critter/hootening(affected_mob.loc)
				P.name = affected_mob.real_name
				logTheThing(LOG_COMBAT, affected_mob, "was gibbed by the disease [name] at [log_loc(affected_mob)].")
				affected_mob.gib()

/obj/machinery/floorflusher/bathtub
	name = "bathtub"
	desc = "Now, that looks cosy!"
	icon = 'icons/misc/owlzone.dmi'
	icon_state = "floorflush_c"

/obj/item/poster/titled_photo/bee
	name = "Er- Found? Poster"
	desc = "A poster of a m------ Bee loved by all."
	poster_image = 'icons/misc/missingbee.png'
	line_b1 = "<center><b> THANK YOU </b></center>"
	line_b2 = "<b>LAST SEEN:</b> New Store!"
	line_b3 = "<b>NOTES:</b> Responds to being called Bombini"
	line_below_photo = "HAVE YOU SEEN THIS BEE? YES YOU HAVE"
	line_photo_subtitle = "2nd MOST RECENT PHOTO"
	line_title = "YOU HAVE SEEN THIS BEE?"

/obj/reagent_dispensers/beerkeg/owldrugs
	name = "Hootin' Dan's Owl Nutrients"
	desc = "A mix of drugs to stimulate owl growth. A label on the side says 'DON'T' The rest has been pecked off."
	icon = 'icons/misc/owlzone.dmi'
	icon_state = "owlfeed"

	New()
		..()
		reagents.remove_reagent("beer",1000)
		reagents.add_reagent("omnizine",150)
		reagents.add_reagent("teporone", 150)
		reagents.add_reagent("synaptizine", 150)
		reagents.add_reagent("saline", 150)
		reagents.add_reagent("salbutamol", 150)
		reagents.add_reagent("methamphetamine", 150)

/obj/reagent_dispensers/beerkeg/owlfeed
	name = "Hootin' Dan's Owl Feed"
	desc = "A mixture of bread, nutrients and preservatives for owls. Smells like gross plants."
	icon = 'icons/misc/owlzone.dmi'
	icon_state = "owlfeed"

	New()
		..()
		reagents.remove_reagent("beer",1000)
		reagents.add_reagent("bread",800)
		reagents.add_reagent("silicate", 50)
		reagents.add_reagent("madness_toxin", 50)
		reagents.add_reagent("lexorin", 50)
		reagents.add_reagent("formaldehyde", 50)

/obj/machinery/power/apc/owlery
	noalerts = 1
	start_charge = 0
	req_access = list(access_owlerymaint)


/obj/owlerysign/owlplaque
	desc = "Beyond here lies the Owl Habitation Wing."
	name = "Informational Plaque"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "rip"
	anchored = ANCHORED
	opacity = 0
	density = 0

/obj/owlerysign/officeplaque
	desc = "Beyond here lies the office wing."
	name = "Informational Plaque"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "rip"
	anchored = ANCHORED
	opacity = 0
	density = 0

/obj/owlerysign/staffplaque
	desc = "Beyond here lies the staff wing."
	name = "Informational Plaque"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "rip"
	anchored = ANCHORED
	opacity = 0
	density = 0

/obj/item/device/key/owl
	name = "Owlish Key"
	desc = "This key was found in an owl pellet. Yuck."
	interesting = "Filthy. GROSS"
	icon_state = "key_owl"

/obj/owldoor
	name = "Strange Looking Wall"
	desc = "This wall has a small slit in middle, huh."
	icon = 'icons/turf/walls/auto.dmi'
	icon_state = "mapwall_r"
	density = 1
	opacity = 1
	anchored = ANCHORED

	attackby(var/obj/item/W, var/mob/user)
		if (istype(W, /obj/item/device/key/owl))
			boutput(user, "You insert the key into the wall causing it to slide into a crevice below!")
			playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 50, 1, -1)
			qdel(src)

/datum/projectile/wonk
	power = 10
	stun = 20
	dissipation_rate = 1
	shot_sound = 'sound/vox/wonk.ogg'
	sname = "Wonkonize"
	shot_number = 1
	window_pass = 1
	icon = 'icons/effects/hallucinations.dmi'
	icon_state = "yee"
	damage_type = D_SPECIAL

	on_hit(atom/hit)
		if(istype(hit,/mob/living/carbon/human))
			var/mob/living/carbon/human/M = hit
			if (!(M.wear_mask && istype(M.wear_mask, /obj/item/clothing/mask/owl_mask)))
				for(var/obj/item/clothing/O in M)
					M.u_equip(O)
					if (O)
						O.set_loc(M.loc)
						O.dropped(M)
						O.layer = initial(O.layer)

				var/obj/item/clothing/under/gimmick/owl/owlsuit = new /obj/item/clothing/under/gimmick/owl(M)
				owlsuit.cant_self_remove = 1
				var/obj/item/clothing/mask/owl_mask/owlmask = new /obj/item/clothing/mask/owl_mask(M)
				owlmask.cant_self_remove = 1

				M.equip_if_possible(owlsuit, SLOT_W_UNIFORM)
				M.equip_if_possible(owlmask, SLOT_WEAR_MASK)
				M.set_clothing_icon_dirty()

/obj/item/gun/energy/wonkgun
	name = "Prototype W.0-NK Laser Rifle"
	desc = "Wonk!"
	item_state = "gun"
	force = 5
	icon_state = "bullpup"
	rechargeable = 0
	custom_cell_max_capacity = 100
	cell_type = /obj/item/ammo/power_cell/self_charging
	muzzle_flash = "muzzle_flash_plaser"
	uses_charge_overlay = TRUE
	charge_icon_state = "bullpup"

	New()
		set_current_projectile(new/datum/projectile/wonk)
		projectiles = list(current_projectile)
		..()

//FUCKABLE MOBS
/obj/critter/owl_mannequin
	name = "Animatronic Owl"
	desc = "An owl made of cogs and gears. It smells faintly of oil and ozone."
	icon = 'icons/misc/bird.dmi'
	icon_state = "smallowl"
	dead_state = "smallowl-dead"
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

	var/does_creepy_stuff = 1
	var/typeName = "Generic"

	process()
		if(!..())
			return 0
		if (!alive || !does_creepy_stuff)
			return

		if (prob(6))
			playsound(src.loc, 'sound/voice/animal/hoot.ogg', 60, 1)
			src.visible_message(SPAN_ALERT("<b>[src] emits [pick("a soft", "a quiet", "a curious", "an odd", "an ominous", "a strange", "a forboding", "a peculiar", "a faint")] [pick("ticking", "tocking", "humming", "droning", "clicking")] hoot."))

		if (prob(6))
			playsound(src.loc, 'sound/voice/animal/hoot.ogg', 60, 1)
			src.visible_message(SPAN_ALERT("<b>[src] emits [pick("a peculiar", "a worried", "a suspicious", "a reassuring", "a gentle", "a perturbed", "a calm", "an annoyed", "an unusual")] [pick("ratcheting", "rattling", "clacking", "whirring")] hoot."))

/obj/machinery/portableowl/owlzone
	name = "Disabled Animatronic Owl"
	desc = "A disabled robot owl."
	icon = 'icons/misc/bird.dmi'
	icon_state = "smallowl"
	anchored = ANCHORED
	density = 1
	flash_prob = 80
	base_state = "smallowl"

	attack_hand(user)
		if (src.anchored)
			if(!ON_COOLDOWN(src, "flash", 5 SECONDS))
				return

			name = "Not so Disabled Animatronic Owl"
			src.flash()

TYPEINFO(/obj/critter/owl_presentor)
	start_speech_modifiers = null
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN_LOCAL)

/obj/critter/owl_presentor
	name = "Professor Hootens"
	desc = "It's Professor Hootens! The leading expert on Space Owls, if it was the real Hootens of course. This is just an animatronic stand-in."
	icon = 'icons/misc/lunar.dmi'
	icon_state = "jammannequin"
	dead_state = "jammannequin-dead"
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
	default_speech_output_channel = SAY_CHANNEL_OUTLOUD
	var/does_creepy_stuff = 1
	var/typeName = "Generic"

	process()
		if(!..())
			return 0
		if (!alive || !does_creepy_stuff)
			return

		if (prob(5))
			playsound(src.loc, 'sound/misc/automaton_ratchet.ogg', 50, 1)
			src.say("[pick("The Owls are fine!", "Welcome to the Frontier Space Owlery, please follow the glowing signs. A tour guide will be waiting for you.", "Did you know? By 2063, it is expected that there will be more owls on Earth than human beings.", "Remember, do not touch the owls. Ddon't do it.", "By entering the 50 square kilometers surrounding the Frontier Space Owlery you agree to remove your right to file a civil lawsuit against the owlery for any reason including death.", "Please keep all pets away from Owl feed or the Owls.", "Remember to say 'HI!' to Greg, our friendly cyborg.", "The Frontier Space Owlery thanks our generous benefactors at Donk Co., LLC. The sole creators and copyright holders of Donk Pockets TM!")]")
		if (prob(5))
			playsound(src.loc, 'sound/misc/automaton_scratch.ogg', 50, 1)
			src.visible_message(SPAN_ALERT("<b>[src]</b> [pick("turns", "pivots", "twitches", "spins")]."))
			src.set_dir(pick(alldirs))

/obj/critter/madnessowl
	name = "space owl"
	desc = "This owl has bloodshot eyes and seems to be snarling at you. What the fuck."
	icon = 'icons/misc/Owlzone.dmi'
	icon_state = "madsmallowl-flap"
	dead_state = "madsmallowl-dead"
	density = 1
	health = 25
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 1
	atksilicon = 1
	firevuln = 1
	brutevuln = 1
	angertext = "hoots angrily at"
	death_text = "%src% falls into a heap on the floor and releases a gargled hoot."
	butcherable = BUTCHER_ALLOWED
	flying = 1
	chases_food = 1
	scavenger = 1
	var/turftarget = null

	bump(atom/movable/AM)
		..()
		if(isobj(AM))

			if(istype(AM, /obj/window))
				AM:health = 0
				AM:smash()
				src.visible_message(SPAN_ALERT("<B>[src]</B> smashes into \the [AM]!"))
			else
				return

	ai_think()
		..()
		if (task == "thinking" || task == "wandering" || task == "chasing")
			if (prob(10))
				if (!src.muted)
					src.visible_message("<b>[src]</b> hoots!")
					playsound(src.loc, 'sound/voice/animal/hoot.ogg', 50, 1)
			else
				if (prob(10))
					FLICK("[src.icon_state]-flap", src)
					src.visible_message("<b>[src]</b> flaps.")
					playsound(src.loc, pick(sounds_rustle), 50, 1)


	on_grump()
		playsound(src.loc, 'sound/voice/animal/hoot.ogg', 60, 1)
		src.visible_message(SPAN_ALERT("<b>[src] hoots angrily!</b>"))

	CritterAttack(mob/M)
		playsound(src.loc, pick(sounds_rustle), 60, 1, -1)
		if(ismob(M))
			src.visible_message(SPAN_COMBAT("<B>[src]</B> swoops at [src.target] and bites a chunk off off them!"))
			random_brute_damage(src.target, 10,1)
			playsound(src.loc, 'sound/impact_sounds/Flesh_Tear_1.ogg', 35, 1, -1)
			src.pixel_x = -5
			src.pixel_y = -5
			sleep(rand(4,6))
			turftarget = get_turf(target)
			src.set_loc(turftarget)
			playsound(src.loc, 'sound/impact_sounds/Flesh_Tear_3.ogg', 35, 1, -1)
			random_brute_damage(src.target, 2,1)
			SPAWN(rand(1,10))
				src.attacking = 0
		return

	ChaseAttack(mob/M)
		if(prob(25))
			playsound(src.loc, pick(sounds_rustle), 60, 1, -1)
		if(ismob(M))
			src.visible_message(SPAN_COMBAT("<B>[src]</B> swoops around and circles [src.target] before biting a chunk off off them!"))
			random_brute_damage(src.target, 10,1)
			playsound(src.loc, 'sound/impact_sounds/Flesh_Tear_1.ogg', 35, 1, -1)
			src.pixel_x = -5
			src.pixel_y = -5
			sleep(rand(4,6))
			turftarget = get_turf(target)
			src.set_loc(turftarget)
			playsound(src.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 35, 1, -1)
			sleep(1 SECOND)

/obj/critter/madnessowl/gun
	name = "space owl with a gun"
	icon_state = "madsmallowlgun"
	dead_state = "madsmallowlgun-dead"
	desc = "WATCH OUT IT HAS A GUN!"

	seek_target()
		src.anchored = UNANCHORED
		for (var/mob/living/C in hearers(src.seekrange,src))
			if (!src.alive) break
			if (C.health < 0) continue
			if (C.name == src.attacker) src.attack = 1
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (istype(C, /mob/living/silicon/) && src.atksilicon) src.attack = 1

			if (src.attack)

				src.target = C
				src.oldtarget_name = C.name

				src.visible_message(SPAN_ALERT("<b>[src]</b> fires at [src.target]!"))

				var/tturf = get_turf(target)
				SPAWN(rand(2,7))
					Shoot(tturf, src.loc, src)
			//	SPAWN(rand(8,12))

				src.attack = 0
				return

/obj/critter/madnessowl/switchblade
	name = "space owl with a switchblade"
	desc = "Oh god it found a knife, how more dangerous can they get?"
	icon_state = "madsmallowlknife"
	dead_state = "madsmallowlknife-dead"
	health = 85

	CritterAttack(mob/M)
		if(ismob(M))
			src.attacking = 1
			src.visible_message(SPAN_COMBAT("<B>[src]</B> shanks [src.target]!"))
			playsound(src.loc, 'sound/impact_sounds/Blade_Small.ogg', 40, 1, -1)
			random_brute_damage(src.target, 5)//shivved
			sleep(rand(4,7))
			playsound(src.loc, 'sound/impact_sounds/Blade_Small.ogg', 40, 1, -1)
			random_brute_damage(src.target, 5)//shivved
			take_bleeding_damage(target, null, 5, DAMAGE_STAB, 1, get_turf(target))
			SPAWN(rand(1,10))
				src.attacking = 0
		return

	ChaseAttack(mob/M)
		FLICK("[src.icon_state]-flaploop", src)
		if(prob(50))
			playsound(src.loc, pick(sounds_rustle), 50, 1, -1)
		if(ismob(M))
			src.attacking =1
			if(prob(20))
				src.visible_message(SPAN_COMBAT("<B>[src]</B> swoops down upon [M] and plunges a blade deep into their back!"))
				playsound(src.loc, 'sound/impact_sounds/Blade_Small.ogg', 40, 1, -1)
				random_brute_damage(src.target, 10)//shivved
				take_bleeding_damage(target, null, 5, DAMAGE_STAB, 1, get_turf(target))
				M.changeStatus("stunned", 2 SECONDS)
				M.changeStatus("knockdown", 2 SECONDS)
				if(!M.stat)
					M.emote("scream")
			else
				src.visible_message(SPAN_COMBAT("<B>[src]</B> swoops down and slashes [M]!"))
				playsound(src.loc, 'sound/impact_sounds/Blade_Small.ogg', 40, 1, -1)
				random_brute_damage(src.target, 3,1)
				take_bleeding_damage(target, null, 2, DAMAGE_STAB, 1, get_turf(target))
			SPAWN(rand(1,10))
				src.attacking = 0
		return

/obj/critter/gunbot/drone/hootening //If anyone wants to take a crack at it, this guy was originally supposed to start doing melee after half HP but fuck critter code.
	name = "The Hootening"
	desc = "Wait you recognize them from somewhere, oh shit wait they have a gun!"
	icon = 'icons/misc/owlzone.dmi'
	icon_state = "hootening"
	dead_state = "deadhoot"
	death_text = "%src% collapses and explodes into pieces?"
	density = 1
	health = 500
	maxhealth = 500
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	firevuln = 1.5
	brutevuln = 1
	flying = 1
	score = 100
	droploot = null
	alertsound1 = 'sound/voice/animal/hoot.ogg'
	alertsound2 = 'sound/voice/animal/yetigrowl.ogg'
	projectile_type = /datum/projectile/bullet/lmg
	current_projectile = new/datum/projectile/bullet/lmg
	projectile_spread = 20
	attack_cooldown = 35
	smashes_shit = 1

	select_target(var/atom/newtarget)
		src.target = newtarget
		src.oldtarget_name = newtarget.name
		playsound(src.loc, ismob(newtarget) ? alertsound2 : alertsound1, 55, 1)
		src.visible_message(SPAN_ALERT("<b>[src]</b> rotates its head a full 360 degrees and begins chasing [src.target]!"))
		task = "chasing"

	New()
		..()
		name = "The Hootening"
		return

/// ALTERNATE HOOTENING ATTEMPT

/obj/critter/hootening
	name = "THE HOOTENING"
	desc = "What has science done???"
	icon = 'icons/misc/owlzone.dmi'
	icon_state = "owlmutant"
	dead_state = "owlmutant-dead"
	death_text = "%src% <b>collapses, releasing a final hoot and regurgitating a Hootonium Core. What? </b>"
	health = 666
	flying = 1
	firevuln = 1
	brutevuln = 0.5
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	seekrange = 6
	density = 1
	butcherable = BUTCHER_ALLOWED
	can_revive = 0
	var/boredom_countdown = 0
	var/flailing = 0
	var/frenzied = 0

	CritterDeath()
		if (src.alive)
			..()
			playsound(src.loc, 'sound/voice/animal/hoot.ogg', 65, 1)
			layer = initial(layer)
			new /obj/item/plutonium_core/hootonium_core (src.loc)

	seek_target()
		src.anchored = UNANCHORED
		if (src.target)
			src.task = "chasing"
			return
		for (var/mob/living/C in hearers(src.seekrange,src))
			if (!isrobot(C) && !ishuman(C)) continue
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			//if (C.stat || C.health < 0) continue

			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				if(iswerewolf(H))
					src.visible_message(SPAN_ALERT("<b>[src] backs away in fear!</b>"))
					step_away(src, H, 15)
					src.set_dir(get_dir(src, H))
					continue

			src.boredom_countdown = rand(1,4)
			src.target = C
			src.oldtarget_name = C.name
			src.task = "chasing"
			playsound(src.loc, 'sound/voice/animal/hoot.ogg', 75, 1)
			src.visible_message(SPAN_ALERT("<b>[src] hoots!</b>"))
			break

	attackby(obj/item/W, mob/living/user) //ARRRRGH WHY
		user.lastattacked = get_weakref(src)

		var/attack_force = 0
		var/damage_type = "brute"
		if (istype(W, /obj/item/artifact/melee_weapon))
			var/datum/artifact/melee/ME = W.artifact
			attack_force = ME.dmg_amount
			damage_type = ME.damtype
		else
			attack_force = W.force
			switch(W.hit_type)
				if (DAMAGE_BURN)
					damage_type = "fire"
				else
					damage_type = "brute"
		switch(damage_type)
			if("fire")
				src.health -= attack_force * src.firevuln
			if("brute")
				src.health -= attack_force * src.brutevuln
			else
				src.health -= attack_force * src.miscvuln
		for(var/mob/O in viewers(src, null))
			O.show_message(SPAN_ALERT("<b>[user]</b> hits [src] with [W]!"), 1)
		if(prob(30))
			playsound(src.loc, 'sound/voice/animal/hoot.ogg', 60, 1)
			src.visible_message(SPAN_ALERT("<b>[src] hoots!</b>"))
		if(prob(25) && alive)
			src.target = user
			src.oldtarget_name = user.name
			src.task = "chasing"
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 60, 1)
			src.visible_message(SPAN_ALERT("<b>[src]</b> freaks out at [src.target]!"))
			frenzy(src.target)
		if(prob(10) && alive)
			src.target = user
			src.oldtarget_name = user.name
			user.TakeDamageAccountArmor("chest", 15, 0, 0, DAMAGE_BLUNT)
			playsound(user.loc, "swing_hit", 60, 1)
			src.visible_message(SPAN_ALERT("<b>[src]</b> preforms a counterattack and dragonkicks [user.name] square in the chest!"))
			animate_spin(src, prob(50) ? "L" : "R", 1, 0)
			var/turf/T = get_edge_target_turf(user, get_dir(user, get_step_away(user, src)))
			if (T && isturf(T))
				user.throw_at(T, 3, 2)
				user.changeStatus("knockdown", 0.5 SECONDS)
				user.changeStatus("stunned", 0.5 SECONDS)

		if (src.alive && src.health <= 0) src.CritterDeath()

		//src.boredom_countdown = rand(5,10)
		src.target = user
		src.oldtarget_name = user.name
		src.task = "chasing"

	attack_hand(var/mob/user)
		user.lastattacked = get_weakref(src)
		if (!src.alive)
			..()
			return
		if (user.a_intent == INTENT_HARM)
			src.health -= rand(1,2) * src.brutevuln
			on_damaged(src)
			for(var/mob/O in viewers(src, null))
				O.show_message(SPAN_ALERT("<b>[user]</b> punches [src]!"), 1)
			playsound(src.loc, pick(sounds_punch), 50, 1)
			if(prob(30))
				playsound(src.loc, 'sound/voice/animal/hoot.ogg', 60, 1)
				src.visible_message(SPAN_ALERT("<b>[src] hoots!</b>"))
			if(prob(20) && alive) // crowd beatdown fix
				src.target = user
				src.oldtarget_name = user.name
				src.task = "chasing"
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1)
				src.visible_message(SPAN_ALERT("<b>[src]</b> flips out at [src.target]!"))
				frenzy(src.target)
			if (src.alive && src.health <= 0) src.CritterDeath()

			//src.boredom_countdown = rand(5,10)
			src.target = user
			src.oldtarget_name = user.name
			src.task = "chasing"
		else
			src.visible_message(SPAN_ALERT("<b>[user]</b> pets [src]!"))
			playsound(src.loc, 'sound/voice/animal/hoot.ogg', 60, 1)
			src.visible_message(SPAN_ALERT("<b>[src] hoots!</b>"))

	ChaseAttack(mob/M)
		if(!flailing) src.flail()
		if(prob(10))
			playsound(src.loc, 'sound/voice/animal/hoot.ogg', 75, 1)
			src.visible_message(SPAN_ALERT("<b>[src] hoots!</b>"))
			src.visible_message(SPAN_ALERT("<B>[src]</B> tackles [M]!"))
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1, -1)
			if(ismob(M))
				M.changeStatus("stunned", 2 SECONDS)
				M.changeStatus("knockdown", 2 SECONDS)

	CritterAttack(mob/M)
		src.attacking = 1
		var/attack_delay = rand(3,15)
		if (isrobot(M))
			var/mob/living/silicon/robot/BORG = M
			if (!BORG.part_head)
				src.visible_message(SPAN_ALERT("<B>[src]</B> pecks at [BORG.name]."))
				sleep(1.5 SECONDS)
				src.visible_message(SPAN_ALERT("<B>[src]</B> throws a tantrum and smashes [BORG.name] to pieces!"))
				playsound(src.loc, 'sound/voice/animal/hoot.ogg', 75, 1)
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 70, 1)
				logTheThing(LOG_COMBAT, src, "gibs [constructTarget(BORG,"combat")] at [log_loc(src)].")
				BORG.gib()
				src.target = null
				src.boredom_countdown = 0
			else
				if (BORG.part_head.ropart_get_damage_percentage() >= 85)
					src.visible_message(SPAN_ALERT("<B>[src]</B> grabs [BORG.name]'s head and wrenches it right off!"))
					playsound(src.loc, 'sound/voice/animal/hoot.ogg', 70, 1)
					playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 70, 1)
					BORG.compborg_lose_limb(BORG.part_head)
					sleep(1.5 SECONDS)
					src.visible_message(SPAN_ALERT("<B>[src]</B> ravenously eats the mangled brain remnants out of the decapitated head!"))
					playsound(src.loc, 'sound/voice/animal/hoot.ogg', 80, 1)
					make_cleanable( /obj/decal/cleanable/blood,src.loc)
					src.target = null
				else
					src.visible_message(SPAN_ALERT("<B>[src]</B> pounds on [BORG.name]'s head furiously!"))
					playsound(src.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', 50, 1)
					if (BORG.part_head.ropart_take_damage(rand(20,40),0) == 1)
						BORG.compborg_lose_limb(BORG.part_head)
					if (prob(33)) playsound(src.loc, 'sound/voice/animal/hoot.ogg', 75, 1)
					attack_delay = 5
		else
			if (boredom_countdown-- > 0)
				if(prob(70))
					src.visible_message(SPAN_ALERT("<B>[src]</B> [pick("bites", "nibbles", "chews on", "gnaws on")] [src.target]!"))
					playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
					playsound(src.loc, 'sound/items/eatfood.ogg', 50, 1)
					random_brute_damage(target, 10,1)
					take_bleeding_damage(target, null, 5, DAMAGE_STAB, 1, get_turf(target))
					if(prob(40))
						playsound(src.loc, 'sound/voice/animal/hoot.ogg', 70, 1)
						src.visible_message(SPAN_ALERT("<b>[src] hoots!</b>"))
				else
					src.visible_message(SPAN_ALERT("<B>[src]</B> [pick("slashes", "swipes", "rips", "tears")] a chunk out of [src.target] with its talons!"))
					playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
					random_brute_damage(target, 20,1)
					take_bleeding_damage(target, null, 10, DAMAGE_CUT, 0, get_turf(target))
					playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
					playsound(src.loc, 'sound/voice/animal/hoot.ogg', 75, 1)
					src.visible_message(SPAN_ALERT("<b>[src] hoots!</b>"))
					if(!M.stat) M.emote("scream") // don't scream while dead/asleep

			else // flip the fuck out
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1)
				src.visible_message(SPAN_ALERT("<b>[src]</b> slams into [src.target]!"))
				if(iscarbon(M))
					M.changeStatus("knockdown", 0.4 SECONDS)
				frenzy(src.target)

			if (isdead(M)) // devour corpses
				src.visible_message(SPAN_ALERT("<b>[src] devours [src.target]! Holy shit!</b>"))
				playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
				M.ghostize()
				new /obj/fakeobject/skeleton(M.loc)
				M.gib()
				src.target = null

		SPAWN(attack_delay)
			src.attacking = 0

	proc/flail()
		if (flailing)
			return

		flailing = 25
		SPAWN(0)
			while(flailing-- > 0)
				src.pixel_x = rand(-2,2) * 2
				src.pixel_y = rand(-2,2) * 2
				src.set_dir(pick(alldirs))
				sleep(0.4 SECONDS)
			src.pixel_x = 0
			src.pixel_y = 0
			if(flailing < 0)
				flailing = 0

	// go crazy and make a huge goddamn mess
	proc/frenzy(mob/M)
		if (src.frenzied)
			return

		SPAWN(0)
			src.visible_message(SPAN_ALERT("<b>[src] goes [pick("on a rampage", "into a bloodlust", "berserk", "hog wild", "feral")]!</b>"))
			playsound(src.loc, 'sound/voice/animal/hoot.ogg', 70, 1)
			src.set_loc(M.loc)
			src.frenzied = 20
			sleep(1 DECI SECOND)
			if(!flailing) src.flail()
			while(src.target && src.frenzied && src.alive && src.loc == M.loc )
				src.visible_message(SPAN_ALERT("<b>[src] [pick("pecks", "claws", "slashes", "tears at", "lacerates", "mangles")] [src.target]!</b>"))
				random_brute_damage(target, 10,1)
				take_bleeding_damage(target, null, 5, DAMAGE_CUT, 0, get_turf(target))
				if(prob(33)) // don't make quite so much mess
					bleed(target, 5, 5, get_step(src.loc, pick(alldirs)), 1)
				sleep(0.4 SECONDS)
				src.frenzied--
			src.frenzied = 0

//FUCKABLE AREAS!!
var/list/owlery_sounds = list('sound/voice/animal/hoot.ogg','sound/ambience/owlzone/owlsfx1.ogg','sound/ambience/owlzone/owlsfx2.ogg','sound/ambience/owlzone/owlsfx3.ogg','sound/ambience/owlzone/owlsfx4.ogg','sound/ambience/owlzone/owlsfx5.ogg','sound/machines/hiss.ogg')

/area/owlery
	name = "owl fuckery"
	sound_group = "owl"
	teleport_blocked = 1
	sound_environment = 12
	area_parallax_render_source_group = /datum/parallax_render_source_group/area/owlery

	New()
		..()
		SPAWN(1 SECOND)
			process()

	proc/process()
		while(current_state < GAME_STATE_FINISHED)
			sleep(10 SECONDS)
			if (current_state == GAME_STATE_PLAYING && length(population))
				if(!played_fx_2 && prob(15))
					sound_fx_2 = pick(owlery_sounds)
					for(var/mob/M in src)
						if (M.client)
							M.client.playAmbience(src, AMBIENCE_FX_2, 50)

/area/owlery/Owlopen
	name = "Owlery Arrivals"
	icon_state = "green"
	sound_loop = 'sound/ambience/owlzone/owlbanjo.ogg'
	sound_group = "owl_banjo"

/area/owlery/owllock
	name = "Owl Observatory Room"
	icon_state = "yellow"
	sound_loop = 'sound/ambience/owlzone/owlambi3.ogg'
	sound_group = "owl_amb3"

/area/owlery/owleryhall
	name = "Owlery Hall Junction"
	icon_state = "orange"
	sound_loop = 'sound/ambience/owlzone/owlbanjo.ogg'
	sound_group = "owl_banjo"

/area/owlery/gangzone
	name = "Mad Owl Den"
	icon_state = "purple"
	sound_loop = 'sound/ambience/owlzone/owlambi2.ogg'
	sound_group = "owl_amb2"

/area/owlery/staffhall
	name = "Staff Hall"
	icon_state = "crewquarters"
	sound_loop = 'sound/ambience/owlzone/owlbanjo.ogg'
	sound_group = "owl_banjo"

/area/owlery/office
	name = "Office Wing"
	icon_state = "red"
	sound_loop = 'sound/ambience/owlzone/owlbanjo.ogg'
	sound_group = "owl_banjo"

/area/owlery/lab
	name = "Perfectly Legal Laboratory"
	icon_state = "blue"
	sound_loop = 'sound/ambience/owlzone/owlambi5.ogg'

/area/owlery/Owlmait
	name = "Owl Maintenance"
	icon_state = "dk_yellow"
	sound_loop = 'sound/ambience/owlzone/owlbanjo.ogg'
	sound_group = "owl_banjo"

/area/owlery/solars
	name = "Owlery Solar Array"
	icon_state = "yellow"
	requires_power = 0
	luminosity = 1
	teleport_blocked = 0

/area/owlery/Owlmait2
	name = "River Loop Maintenance"
	icon_state = "dk_yellow"
	sound_loop = 'sound/ambience/owlzone/owlambi3.ogg'
	sound_group = "owl_amb3"

/area/syndicate/minerva5/command
	name = "Administrator's Office"
	icon_state = "red"
	sound_loop = 'sound/ambience/station/JazzLounge1.ogg'

//Other fuckable things
/obj/ability_button/owl_slam
	name = "Owl Slam"
	desc = "Hoot the entire station with the power of an owl."
	targeted = FALSE
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "owlslam"

/obj/ability_button/owl_slam/execute_ability()
	. = ..()
	var/mob/M = the_mob

	var/equipped_thing = M.equipped()
	if(istype(equipped_thing, /obj/item/basketball))
		var/obj/item/basketball/BB = equipped_thing
		if(!BB.payload)
			boutput(M, SPAN_ALERT("This b-ball doesn't have the right heft to it!"))
			return
		else //Safety thing to ensure the hootonium core is only good for one dunk
			var/pl = BB.payload
			BB.payload = null
			qdel(pl)
	else
		boutput(M, SPAN_ALERT("You can't slam without a b-ball, yo!"))
		return

	the_item.remove_item_ability(the_mob, src.type)
	APPLY_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "owlslam") //you cannot move while doing this
	logTheThing(LOG_COMBAT, M, "<b>triggers a owl slam in [M.loc.loc] ([log_loc(M)])!</b>")

	M.visible_message(SPAN_ALERT("[M] flies through the ceiling!"))
	playsound(M.loc, 'sound/effects/bionic_sound.ogg', 50)

	for(var/i = 0, i < 50, i++)
		M.pixel_y += 6
		M.set_dir(turn(M.dir, 90))
		sleep(0.1 SECONDS)
	M.layer = 0
	var/sound/siren = sound('sound/misc/airraid_loop_short.ogg')
	siren.repeat = 1
	siren.channel = 5
	world << siren
	command_alert("A massive influx of Owl Quarks has been detected in [get_area(M)]. A Owl Slam is imminent. All personnel currently on [station_name()] have 10 seconds to reach minimum safe distance. This is not a test.")
	for(var/mob/N in mobs)
		SPAWN(0)
			shake_camera(N, 120, 24)
	SPAWN(0)
		var/thunder = 70
		while(thunder > 0)
			thunder--
			if(prob(15))
				playsound_global(world, 'sound/voice/animal/hoot.ogg', 80)
				for(var/mob/N in mobs)
					N.flash(3 SECONDS)
			sleep(0.5 SECONDS)
	sleep(20 SECONDS)
	playsound(M.loc, 'sound/effects/bionic_sound.ogg', 50)
	M.layer = EFFECTS_LAYER_BASE
	for(var/i = 0, i < 20, i++)
		M.pixel_y -= 12
		M.set_dir(turn(M.dir, 90))
		sleep(0.1 SECONDS)
	sleep(0.1 SECONDS)
	siren.repeat = 0
	siren.status = SOUND_UPDATE
	siren.channel = 5
	world << siren
	M.visible_message(SPAN_ALERT("[M] successfully executes a Owl Slam!"))
	REMOVE_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "owlslam")
	explosion_new(M, get_turf(M), 1, 75)
	for(var/mob/living/carbon/human/M1 in range(5, M))
		SPAWN(0)
		M1.owlgib()
	for(var/mob/living/carbon/human/M2 in range(50, M))
		SPAWN(0)
			if (!QDELETED(M2) && !(M2.wear_mask && istype(M2.wear_mask, /obj/item/clothing/mask/owl_mask)))
				for(var/obj/item/clothing/O in M2)
					M2.u_equip(O)
					if (O)
						O.set_loc(M2.loc)
						O.dropped(M2)
						O.layer = initial(O.layer)

				var/obj/item/clothing/under/gimmick/owl/owlsuit = new /obj/item/clothing/under/gimmick/owl(M2)
				owlsuit.cant_self_remove = 1
				var/obj/item/clothing/mask/owl_mask/owlmask = new /obj/item/clothing/mask/owl_mask(M2)
				owlmask.cant_self_remove = 1

				M2.equip_if_possible(owlsuit, SLOT_W_UNIFORM)
				M2.equip_if_possible(owlmask, SLOT_WEAR_MASK)
				M2.set_clothing_icon_dirty()

///////GREG THE COOL AWESOME ROBOT TRADER/////////////////
/obj/npc/trader/greg
	icon = 'icons/obj/trader.dmi'
	icon_state = "greg"
	picture = "robot.png"
	name = "Greg"
	desc = "Oh hey its Greg! Everyone loves him, but you don't seem to remember why."

	New()
		..()
		/////////////////////////////////////////////////////////
		//// sell list //////////////////////////////////////////
		/////////////////////////////////////////////////////////
		src.goods_sell += new /datum/commodity/airzooka(src)
		src.goods_sell += new /datum/commodity/airbag(src)
		src.goods_sell += new /datum/commodity/dangerbag(src)
		src.goods_sell += new /datum/commodity/hat/dailyspecial/greg
		src.goods_sell += new /datum/commodity/crayons/greg
		src.goods_sell += new /datum/commodity/drugs/poppies/greg
		src.goods_sell += new /datum/commodity/owlpaint
		/////////////////////////////////////////////////////////
		//// buy list ///////////////////////////////////////////
		/////////////////////////////////////////////////////////
		src.goods_buy += new /datum/commodity/owleggs(src)
		/////////////////////////////////////////////////////////

		greeting= {"Hey there kid! Welcome to the gift shop. Im Greg, Professor Hootens loveable assistant! And this little fella on my hand is Howard the Hooter, say "Hi" Howard!."}

		portrait_setup = "<img src='[resource("images/traders/[src.picture]")]'><HR><B>[src.name]</B><HR>"

		sell_dialogue = "Howards lost some of his eggs, can you find them all?."

		buy_dialogue = "Are you interested in some Owl accessories?"

		successful_purchase_dialogue = list("Thank you for your purchase!", "Please enjoy your purchase.",
		"Thank you for your continued support of the Owlery!")

		failed_sale_dialogue = list("Sorry, we're not currently accepting donations of that variety.")

		successful_sale_dialogue = list("Thank you for your contribution to the Owlery, your personalized thank you card will arrive in 3 to 300 business days.")

		failed_purchase_dialogue = list("Im sorry but it appears the transaction as reached a fatal error, please contact your cards provider for more info.")

		pickupdialogue = "Your purchase has been delivered."

		pickupdialoguefailure = "I don't believe you have added anything to your virtu-cart."

TYPEINFO(/obj/item/lilgreg)
	start_listen_effects = list(LISTEN_EFFECT_LIL_GREG)
	start_listen_inputs = list(LISTEN_INPUT_OUTLOUD)
	start_speech_modifiers = null
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN_LOCAL)

/obj/item/lilgreg
	name = "Greg Jr"
	desc = "Gregs adopted son! He seems to have gotten caught up with a bad crowd."
	icon = 'icons/misc/owlzone.dmi'
	icon_state = "gregjr"
	default_speech_output_channel = SAY_CHANNEL_OUTLOUD
	var/seensol = 0
	var/cantalk = 1

	attack_self(mob/user as mob)
		if(cantalk == 1)
			cantalk = 0
			if(prob(5))
				playsound(src.loc, "sound/ambience/owlzone/owlsfx[rand(1,5)].ogg", 50, 1)
				user.visible_message(SPAN_NOTICE("Greg Jr emits a haunting hoot as you pull the string on their back."))
				cantalk = 1
			else
				playsound(src.loc, 'sound/misc/automaton_ratchet.ogg', 50, 1)
				user.visible_message(SPAN_ALERT("[user] pull the string located at the back of Greg Jr."))
				sleep(3 SECONDS)
				if (istype(get_area(src), /area/solarium) && seensol == 0)
					src.say("Woah, so thats what the sun looks like. It's kind of smaller then I expected though?")
					sleep(1 SECOND)
					src.say("Hm, looks like my internal camera is out of storage. Mind holding this tape real quick while I add some film?")
					new /obj/item/audio_tape/beepoker(get_turf(user))
					seensol = 1
					cantalk = 1
					return
				else
					src.say("[pick("Hey there pal! How's your day been?", "You ever been to that weird satilite with the giant guardbuddy?", "Hey have you ever heard about Greg? He's a real swell guy.", "Ever eaten a Lemon Square? I haven't, I wonder what they taste like.","Did you catch last nights Professor Hootens story hour? I must have missed it.", "Those darn Owls scratched my paintjob.", "Ever meet that guy with the big beard and giant heart?", "I wonder where Greg is today, have you seen him?", "I wish I could see that sun thing people keep talking about.")]")
					sleep(3 SECONDS)
					cantalk = 1
					sleep(2 SECONDS)
					return
