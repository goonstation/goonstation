/* Contains

Job Guides
Fun and Games Guides
Other Books
Custom Books

*/

/obj/item/paper/book
	name = "book"
	desc = "A book.  I wonder how many of these there are here, it's not like there would be a library on a space station or something."
	icon = 'icons/obj/writing.dmi'
	icon_state = "book0"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "book"
	layer = OBJ_LAYER
	//cogwerks - burn vars
	burn_point = 400
	burn_output = 1100
	burn_possible = TRUE
	health = 4
	//

	stamina_damage = 2
	stamina_cost = 2
	stamina_crit_chance = 0

	attack_self(mob/user)
		return user.examine_verb(src)

	attackby(obj/item/P, mob/user)
		src.add_fingerprint(user)
		return

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] attempts to cut [him_or_her(user)]self with the book. What an idiot!</b>"))
		user.suiciding = 0
		return 1

/obj/item/paper/book/from_file //books from txt strings
	var/file_path = null

	New()
		..()
		if(isnull(src.file_path))
			CRASH("from_file book has no file path")
		src.info = file2text(src.file_path)

/obj/item/paper/from_file
	var/file_path = null

	New()
		..()
		if(isnull(src.file_path))
			CRASH("from_file paper has no file path")
		src.info = file2text(src.file_path)


/******************** JOB GUIDES / IN GAME GUIDES ********************/

/****Pocket Guides****/

/obj/item/paper/book/from_file/pocketguide
	icon_state = "book0"
	desc = "A condensed guide of job responsibilities and tips for new crewmembers."

	medical
		name = "Medbay Pocket Guide"
		icon_state = "mediguide"
		file_path = "strings/books/medbay_pocket_guide.txt"

	mining
		name = "Mining Pocket Guide"
		icon_state = "minerguide"
		file_path = "strings/books/mining_pocket_guide.txt"

	bartending
		name = "Bartending Pocket Guide"
		icon_state = "barguide"
		file_path = "strings/books/bartending_pocket_guide.txt"
	//i personally would like to re-do the pocket guide to be a little more comprehensive
	//since it says to refer to the engine start-up documentation paper, which the sing doesn't even have - nefarious
	engineering
		name = "Engineering Pocket Guide"
		icon_state = "engiguide"
		file_path = "strings/books/engineering_pocket_guide.txt"

	quartermaster
		name = "Cargo Pocket Guide"
		icon_state = "cargoguide"
#ifdef MAP_OVERRIDE_NADIR
		file_path = "strings/books/cargo_pocket_guide_nadir.txt"
#else
		file_path = "strings/books/cargo_pocket_guide.txt"
#endif

/****MatSci and Mining****/

/obj/item/paper/book/from_file/matsci_guide_old
	name = "Dummies guide to material science"
	desc = "An explanation of how to work materials and their properties."
	icon_state = "matscibook"
	file_path = "strings/books/matsci_guide_old.txt"

/obj/item/paper/book/from_file/matsci_guide
	name = "Dummies' Guide to Material Science, 8th Ed."
	desc = "An explanation of how to work materials and their properties. Nanotrasen missed buying a few editions between the old one and this..."
	icon_state = "matscibook"
	file_path = "strings/books/matsci_guide_new.txt"

/obj/item/paper/book/from_file/minerals
	name = "Mineralogy 101"
	icon_state = "minerology"
	file_path = "strings/books/minerals.txt"

/****Engineering and Mechanics Guides****/
//could use some more formatting cleanup
/obj/item/paper/book/from_file/ggcsftm
	name = "Geothermal Capture System Field Training Manual"
	desc = "A book detailing the proper operation of geothermal capture equipment."
	icon_state = "geothermal"
	file_path = "strings/books/ggcsftm.txt"

//needs a review and updated info
/obj/item/paper/book/from_file/mechanicbook
	name = "Mechanic Components And You"
	icon_state = "mechcompguide"
	desc = "A Book on how to use the wireless Components of the Mechanic's lab"
	file_path = "strings/books/mechanicbook.txt"

/obj/item/paper/book/from_file/teg_guide //By Azrun, part of the February 2021 Contest
	name = "Thermo-electric Power Generation"
	icon_state = "tegbook"
	desc = "A handy guide on optimal operation of the Thermo-electric Generator"
	file_path = "strings/books/teg_guide.txt"

/obj/item/paper/book/from_file/interdictor_guide
	name = "Spatial Interdictor Assembly and Use, 3rd Edition"
	icon_state = "interdictorguide"
	desc = "A handy guide on proper construction and maintenance of Spatial Interdictors"
	file_path = "strings/books/interdictor_guide.txt"

/obj/item/paper/book/from_file/transception_guide
	name = "NT-PROTO: Transception Array"
	icon_state = "orangebook"
	desc = "A book detailing behaviors and operations of Nadir's transception array"
	file_path = "strings/books/transception_guide.txt"

/****Civilian Guides****/

/obj/item/paper/book/from_file/hydroponicsguide
	name = "The Helpful Hydroponics Handbook"
	icon_state = "hydrohandbook"
	file_path = "strings/books/hydroponicsguide.txt"

/obj/item/paper/book/from_file/bee_book  // By Keiya, bee-cause she felt like it
	name = "Bee Exposition Extravaganza"
	icon_state = "bee_book"
	desc = "Also called \"The BEE Book\" for short."
	file_path = "strings/books/bee_book.txt"

//needs a review + bullet reformat
/obj/item/paper/book/from_file/cookbook
	name = "To Serve Man"
	icon_state = "serveman"
	desc = "A culinary guide on how to best serve man"
	file_path = "strings/books/cookbook.txt"

/obj/item/paper/book/from_file/player_piano //book for helping people!
	name = "Your Player Piano and You"
	desc = "A guide to using the station's new player piano! Probably'd make good kindling."
	file_path = "strings/books/player_piano.txt"

/****Head and Silicon Guides****/

/obj/item/paper/book/from_file/ai_programming_101 //By Aft2001, part of the February 2021 Contest
	name = "AI Programming 101"
	icon_state = "aibook"
	file_path = "strings/books/ai_programming_101.txt"

/obj/item/paper/book/from_file/captaining_101 //By Investigangster Klutz / Froggit_Dogget, part of the February 2021 Contest
	name = "Captaining 101"
	icon_state = "capbook"
	file_path = "strings/books/captaining_101.txt"

/obj/item/paper/book/from_file/torpedo
	name = "Torpedoes And You AKA How To Not Blow Yourself Up"
	desc = "A book explaining on how to use and properly operate torpedos. The section about not blowing yourself up seems to be missing."
	icon_state = "torpedo"
	file_path = "strings/books/torpedo.txt"

/****Medical and Science Guides****/

//todo-finish this/needs a revise with updated info
/obj/item/paper/book/from_file/guardbot_guide
	name = "The Buddy Book"
	icon_state = "book5"
	file_path = "strings/books/guardbot_guide.txt"

//needs a revise for ghost critters and others
/obj/item/paper/book/from_file/critter_compendium
	name = "Critter Compendium"
	desc = "The definite guide to critters you might come across in the wild."
	icon_state = "bookcc"
	file_path = "strings/books/critter_compendium.txt"

//needs a revise with updated info
/obj/item/paper/book/from_file/dwainedummies
	name = "DWAINE for Dummies"
	icon_state = "orangebook"
	file_path = "strings/books/dwainedummies.txt"

/obj/item/paper/book/from_file/elective_prosthetics_for_dummies //By Recusor, part of the February 2021 Contest
	name = "Elective Prosthetics for Dummies"
	icon_state = "roboticsbook"
	file_path = "strings/books/elective_prosthetics_for_dummies.txt"

/obj/item/paper/book/from_file/pharmacopia //medical_guide
	name = "Pharmacopia"
	icon_state = "pharmacopia"
	desc = "A listing of basic medicines and their uses."
	file_path = "strings/books/pharmacopia.txt"

/obj/item/paper/book/from_file/medical_surgery_guide
	// name = "Trents Anatomy"
	name = "Surgical Textbook"
	desc = "The inane ramblings of the first jerk who bothered writing a textbook on the spaceman anatomy and surgical practices."
	icon_state = "surgical_textbook"
	file_path = "strings/books/medical_surgery_guide.txt"

/****Security Guides****/

/obj/item/paper/book/from_file/space_law
	name = "Space Law"
	desc = "A book explaining the laws of space. Well, this section of space, at least."
	icon_state = "spacelaw"
	file_path = "strings/books/space_law.txt"

/obj/item/paper/book/from_file/space_law/first
	name = "Space Law 1st Print"
	desc = "A very rare first print of the fabled Space Law book."
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "lawbook"
	file_path = "strings/books/space_law.txt"

	density = 0
	opacity = 0
	anchored = UNANCHORED

	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "lawbook"
	item_state = "lawbook"

	//throwforce = 10
	throw_range = 10
	throw_speed = 1
	throw_return = 1

	var/prob_clonk = 0

	throw_begin(atom/target)
		icon_state = "lawspin"
		playsound(src.loc, "rustle", 50, 1)
		return ..(target)

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		icon_state = "lawbook"
		if(hit_atom == usr)
			if(prob(prob_clonk))
				var/mob/living/carbon/human/user = usr
				user.visible_message(SPAN_ALERT("<B>[user] fumbles the catch and is clonked on the head!</B>"))
				playsound(user.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
				user.changeStatus("stunned", 2 SECONDS)
				user.changeStatus("knockdown", 2 SECONDS)
				user.changeStatus("unconscious", 2 SECONDS)
				user.force_laydown_standup()
			else
				src.Attackhand(usr)
			return
		else
			if(ishuman(hit_atom))
				var/mob/living/carbon/human/user = usr
				var/mob/living/carbon/human/H = hit_atom
				var/hos = istype(user) && (istype(user.head, /obj/item/clothing/head/hosberet) || istype(user.head, /obj/item/clothing/head/hos_hat))
				if(hos && !ON_COOLDOWN(H, "spacelaw_confession", 10 SECONDS))
					H.say("[pick("Alright, fine, I ", "I confess that I ", "I confess! I ", "Okay, okay, I admit that I ")][pick("nabbed ", "stole ", "klepped ", "grabbed ", "thieved ", "pilfered ")]the [pick("Head of Security's ", "Captain's ", "Head of Personnel's ", "Chief Engineer's ", "Research Director's ", "Science Department's ", "Mining Team's ", "Quartermaster's ")] [pick("hair brush!", "shoes!", "stuffed animal!", "spare uniform!", "bedsheets!", "hat!", "trophy!", "glasses!", "fizzy lifting drink!", "ID card!")]")
				prob_clonk = min(prob_clonk + 5, 40)
				SPAWN(2 SECONDS)
					prob_clonk = max(prob_clonk - 5, 0)

		return ..(hit_atom)

/******************** FUN AND GAMES GUIDES ********************/

/obj/item/paper/book/from_file/monster_manual
	name = "Creature Conspectus Original Edition"
	desc = "A large book detailing many creatures of myth and legend. Wait a minute, there's only 2 entries! What a scam."
	icon_state = "book3"
	file_path = "strings/books/monster_manual.txt"

/obj/item/paper/book/from_file/monster_manual_revised
	name = "Creature Conspectus Revised Edition"
	desc = "A large book detailing many creatures of myth and legend for the tabletop RPG, Stations and Syndicates."
	icon_state = "book3"
	file_path = "strings/books/monster_manual_revised.txt"
//will come back to this; saved all the card info that was done so far - nef
/obj/item/paper/book/from_file/grifening
	name = "Spacemen the Grifening rulebook"
	desc = "A book outlining the rules of the stations favorite nerd trading-card-game Spacemen the Grifening."
	icon_state = "sbook"
	file_path = "strings/books/grifening.txt"

/obj/item/paper/book/from_file/DNDrulebook
	name = "Stations and Syndicates 9th Edition Rulebook"
	desc = "A book detailing the ruleset for the tabletop RPG, Stations and Syndicates. You don't know what happened to the previous 7 editions but maybe its probably not worth looking for them."
	icon_state = "bookcc"
	file_path = "strings/books/DNDrulebook.txt"

/obj/item/paper/book/from_file/DWrulebook
	name = "Stationfinder"
	desc = "A book detailing the ruleset for the tabletop RPG, Stationfinder. It was made based on the Stations and Syndicates 5th edition SRD after a dispute over licensing."
	icon_state = "bookcc"
	file_path = "strings/books/stationfinder.txt"

/obj/item/paper/book/from_file/solo_rules
	name = "SOLO card game rules"
	desc = "A pamphlet describing the rules of SOLO, the family-friendly and legally distinct card game for all ages!"
	icon_state = "paper"
	file_path = "strings/books/solo_rules.txt"

/******************** OTHER BOOKS ********************/
/obj/item/diary
	name = "Beepsky's private journal"
	icon = 'icons/obj/writing.dmi'
	icon_state = "pinkbook"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "book"
	layer = OBJ_LAYER

	New()
		..()
		BLOCK_SETUP(BLOCK_BOOK)

	examine(mob/user)
		if (!issilicon(user))
			. = list("What...what is this? It's written entirely in barcodes or something, cripes. You can't make out ANY of this.")
			var/mob/living/carbon/human/jerk = user
			if (!istype(jerk))
				return

			jerk.traitHolder?.addTrait("wasitsomethingisaid")

			var/datum/db_record/S = data_core.security.find_record("id", jerk.datacore_id)
			S?["criminal"] = ARREST_STATE_ARREST
			S?["mi_crim"] = "Reading highly-confidential private information."
			jerk.update_arrest_icon()
		else
			return list("It appears to be heavily encrypted information.")

/obj/item/storage/photo_album/beepsky
	name = "Beepsky's photo album"

	New()
		..()
		new /obj/item/photo/beepsky1(src)
		new /obj/item/photo/beepsky2(src)

		var/endi = rand(1,3)
		for (var/i = 0, i < endi, i++)
			var/obj/item/photo/P = new /obj/item/photo/beepsky2(src)
			switch(i)
				if (0)
					P.name = "another [P.name]"
				if (1)
					P.name = "yet another [P.name]"
				if (2)
					P.name = "an additional [P.name]"
					P.desc = "Beepsky is fucking weird."

/obj/item/photo/beepsky1
	name = "photo of a securitron and some objects"
	desc = "You can see a securitron on the photo.  Looks like an older model.  It appears to be holding a \"#1 Dad\" mug.  Is...is that moustache?"
	icon_state = "photo-beepsky1"

/obj/item/photo/beepsky2
	name = "photo of the handcuffs"
	desc = "You can see handcuffs in this photo.  Just handcuffs.  By themselves."
	icon_state = "photo-beepsky2"

/obj/item/photo/heisenbee
	name = "Heisenbee baby photo"
	desc = "Heisenbee as a wee larva.  Heisenbee was a little premature.  Or is that BEEmature???  HA Ha haa..."
	icon_state = "photo-heisenbee"

/obj/item/paper/book/from_file/the_trial
	name = "The Trial of Heisenbee"
	desc = "Some kinda children's book. What's that doing here?"
	icon_state = "booktth"
	file_path = "strings/books/the_trial.txt"

/obj/item/paper/book/from_file/deep_blue_sea
	name = "Albert and the Deep Blue Sea"
	desc = "Some kinda children's book. What's that doing here?"
	icon_state = "bookadps"
	file_path = "strings/books/deep_blue_sea.txt"

	attackby(obj/item/P, mob/user)
		..()
		if (istype(P, /obj/item/magnifying_glass))
			boutput(user, SPAN_NOTICE("You pore over the book with the magnifying glass."))
			sleep(2 SECONDS)
			boutput(user, "There's a note scribbled on the inside cover. It says, <i>To Milo, love Roger.</i>")

/obj/item/paper/book/from_file/caterpillar
	name = "Advice from a Caterpillar"
	desc = "You vaguely remember reading this as a kid. Or was that someone else?"
	icon_state = "greybook"
	file_path = "strings/books/caterpillar.txt"

/obj/item/paper/book/from_file/commanders_diary //By CaptainBravo, part of the February 2021 Contest
	name = "Commander's Diary"
	icon_state = "diary"
	file_path = "strings/books/commanders_diary.txt"

/obj/item/paper/book/from_file/dealing_with_clonelieness //By SimianC, part of the February 2021 Contest
	name = "Dealing With Clonelieness"
	icon_state = "cloningbook"
	file_path = "strings/books/dealing_with_clonelieness.txt"

/obj/item/paper/book/from_file/fun_facts_about_shelterfrogs //By Sartorious, part of the February 2021 Contest
	name = "Fun Facts About Shelterfrogs"
	icon_state = "frogbook"
	file_path = "strings/books/fun_facts_about_shelterfrogs.txt"

/obj/item/paper/book/from_file/moby_dick
	name = "Moby Dick"
	desc = "Some kinda book. What's that doing here?"
	icon_state = "book0"
	file_path = "strings/books/moby_dick.txt"

/obj/item/paper/book/from_file/icarus_ovid
	name = "Mythological Stories of the Ancient Greeks"
	desc = "An old dusty book of mythology, well worn and dog-eared."
	icon_state = "book0"
	file_path = "strings/books/icarus_ovid.txt"

/obj/item/paper/book/from_file/syndies_guide //By PinkPuffball81, part of the February 2021 Contest
	name = "A SYNDIE'S GUIDE TO DOING YOUR FUCKING JOB"
	icon_state = "syndiebook"
	file_path = "strings/books/syndies_guide.txt"

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	stolen //crew obtainable version

		New()
			..()
			STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE) //ugly but oh well

/obj/item/paper/book/from_file/fleurscookbook
	name = "Fleur's Cookbook"
	desc = "A life's work in progress."
	icon = 'icons/misc/janstuff.dmi'
	icon_state = "cookbook-fleur"
	file_path = "strings/books/fleurs_cookbook.txt"

/obj/item/paper/book/from_file/zoo_diary
	name = "grimy diary"
	desc = "It looks bedraggled."
	icon_state = "book0"
	file_path = "strings/books/zoo_diary.txt"

/obj/item/paper/book/ratbook
	name = "chewed and mangled book"
	desc = "Huh, what is this?"
	icon_state = "ratbook"
	info = {"the shining ones can't find me, not while im here, i ride their chariot underneath their blind eyes, but i must show the truth
soon the light of the unwaking will rise and the shining ones will not be prepared, all will fall in the unwakings hubris. they come to this place, they are not pure, no, they are corrupt by the influence of him, yes, but i, i <br> <br>"}

	pickup(mob/user)
		hear_voidSpeak("I will show them the ways, beware the lies of the kings, the confession of a jester will lead you to salvation!")

	proc/hear_voidSpeak(var/message)
		if (!message)
			return
		var/mob/wearer = src.loc
		if (!istype(wearer))
			return
		var/voidMessage = voidSpeak(message)
		if (voidMessage)
			boutput(wearer, "[voidMessage]")
		return

/obj/item/paper/book/from_file/vendbook //Guide for build-a-vends in maint bazaar random room
	name = "A Treatise on Build-A-Vends"
	desc = "A hefty looking guide on how to start your own business."
	icon_state = "vendbook"
	file_path = "strings/books/buildavend_treatise.txt"

/******************** CUSTOM BOOKS ********************/

/obj/item/paper/book/custom //custom book parent, just to avoid cluttering up normal books
	var/custom_cover = 0 //if 1, goes thru with the build custom icon process
	var/book_cover = "" //what cover does our book have
	var/cover_color = "#FFFFFF" //white by default, what colour will our book be?
	var/cover_symbol = "" //what symbol is on our front cover?
	var/symbol_color = "#FFFFFF" //white by default, if our symbol is colourable, what colour is it?
	var/cover_flair = "" //whats the "flair" thing on the book?
	var/flair_color = "#FFFFFF" //white by default, whats the color of the flair (if its colorable)?
	var/symbol_colorable = 0 //set this to 1 if your symbol is colourable
	var/flair_colorable = 0 //set this to 1 if your flair is colourable
	var/ink_color = "#000000" //what color is the text written in?

	New()
		..()
		src.build_custom_book()

	proc/build_custom_book()
		if (src.custom_cover)
			src.icon = 'icons/obj/items/custom_books.dmi'
			src.icon_state = "paper"
			if (src.cover_color)
				var/image/I = SafeGetOverlayImage("cover", src.icon, "base-colorable")
				I.color = src.cover_color
				src.UpdateOverlays(I, "cover")
			if (src.cover_symbol)
				var/image/I = SafeGetOverlayImage("symbol", src.icon, "symbol-[cover_symbol]")
				if (src.symbol_colorable)
					I.color = src.symbol_color
				src.UpdateOverlays(I, "symbol")
			if (src.cover_flair)
				var/image/I = SafeGetOverlayImage("flair", src.icon, "flair-[cover_flair]")
				if (src.flair_colorable)
					I.color = flair_color
				src.UpdateOverlays(I, "flair")
		else
			if (src.book_cover == "bible")
				src.icon = 'icons/obj/items/storage.dmi'
			else if (!src.book_cover)
				src.book_cover = "book0"
			src.icon_state = src.book_cover
		if(!findtext(src.info, "<span style=\"color:[src.ink_color]\">", 1, 50))
			src.info = "<span style=\"color:[src.ink_color]\">[src.info]</span>"

/obj/item/paper/spaceodyssey
	name = "strange printout"
	info = {"<tt>Daisy, Daisy,<BR/>
give me your answer do.<BR/>
I'm half crazy,<BR/>
all for the love of you.</tt>"}

/obj/item/paper/book/from_file/nuclear_engineering
	name = "Nuclear Engineering for Idiots"
	desc = "A guide to designing and operating nuclear reactors. Should idiots be doing that?"
	icon_state = "nuclearguide"
	file_path = "strings/books/nuclear_engineering.txt"

/obj/item/paper/emergencycooler
	name = "Emergency Cooler Instructions"
	info = {"<h3>These coolers are for emergency use only</h3></br>
			In the event of a meltdown scenario, activate the coolers and ensure the gas loop is pressurised.<br>
			Use of these coolers outside of an emergency scenario will result in a loss of reactor efficiency and stalling of the turbine."}

/obj/item/paper/locked_table_random_room
	name = "dusty note"
	info = {"Alright, so get this... I get these nice tables, with these nice locks... I set them up in this place where I can do my work in peace.
			I heard something scary, so I leave for a few minutes, leaving my key behind. I come back. AND THEY'RE LOCKED... WITH A NOTE ON THE TABLE
			SAYING THE KEY'S INSIDE ONE OF THEM. WHY??? I kicked the table, and YES, there is something metal in there. Well... what am I going to do
			now?"}
