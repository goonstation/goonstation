#define PAPER_MODE_READING 0
#define PAPER_MODE_WRITING 1
#define PAPER_MODE_STAMPING 2
#define PAPER_MAX_LENGTH 5000
#define PAPER_MAX_STAMPS 30
#define PAPER_MAX_STAMPS_OVERLAYS 4

#define STAMP_IDS list(\
	"Clown" = "stamp-sprite-clown",\
	"Denied" = "stamp-sprite-deny" ,\
	"Granted" = "stamp-sprite-ok",\
	"Head of Personnel" = "stamp-sprite-hop",\
	"Medical Director" = "stamp-sprite-md",\
	"Chief Engineer" = "stamp-sprite-ce",\
	"Head of Security" = "stamp-sprite-hos",\
	"Research Director" = "stamp-sprite-rd",\
	"Captain" = "stamp-sprite-cap",\
	"Quartermaster" = "stamp-sprite-qm",\
	"Security" = "stamp-sprite-law",\
	"Chaplain" = "stamp-sprite-chap",\
	"Mime" = "stamp-sprite-mime",\
	"Centcom" = "stamp-sprite-centcom",\
	"Syndicate" = "stamp-sprite-syndicate",\
	"Void" = "stamp-sprite-void",\
	"Your Name" = "stamp-text-name",\
	"Current Time" = "stamp-text-time",)

/obj/item/paper
	name = "paper"
	icon = 'icons/obj/writing.dmi'
	icon_state = "paper_blank"
	uses_multiple_icon_states = 1
	wear_image_icon = 'icons/mob/clothing/head.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	var/info = ""
	var/stampable = 1
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 3
	throw_range = 15
	layer = OBJ_LAYER
	//cogwerks - burning vars
	burn_point = 220
	burn_output = 900
	burn_possible = 2
	var/list/form_startpoints
	var/list/form_endpoints
	var/font_css_crap = null
	var/list/fonts = list()

	var/stampNum = 0
	var/sizex = 0
	var/sizey = 0
	var/offset = 0

	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0

	var/sealed = 0 //Can you write on this with a pen?
	var/list/stamps = null
	var/list/form_fields = list()
	var/field_counter = 1

/obj/item/paper/New()
	..()
	src.create_reagents(10)
	reagents.add_reagent("paper", 10)
	SPAWN(0)
		if (src.info && src.icon_state == "paper_blank")
			icon_state = "paper"
	if (!src.rand_pos)
		return
	else
		src.pixel_y = rand(-8, 8)
		src.pixel_x = rand(-9, 9)

/obj/item/paper/examine(mob/user)
	. = ..()
	ui_interact(user)

/obj/item/paper/custom_suicide = 1
/obj/item/paper/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	user.visible_message("<span class='alert'><b>[user] cuts [him_or_her(user)]self over and over with the paper.</b></span>")
	user.TakeDamage("chest", 150, 0)
	return 1

/obj/item/paper/attack_self(mob/user as mob)
	var/menuchoice = tgui_alert(user, "What would you like to do with [src]?", "Use paper", list("Fold", "Read", "Nothing"))
	if (!menuchoice || menuchoice == "Nothing")
		return
	else if (menuchoice == "Read")
		src.examine(user)
	else
		var/fold = tgui_alert(user, "What would you like to fold [src] into?", "Fold paper", list("Paper hat", "Paper plane", "Paper ball"))
		if(src.disposed || !fold) //It's possible to queue multiple of these menus before resolving any.
			return
		user.u_equip(src)
		if (fold == "Paper hat")
			user.show_text("You fold the paper into a hat! Neat.", "blue")
			var/obj/item/clothing/head/paper_hat/H = new()
			user.put_in_hand_or_drop(H)
		else
			var/obj/item/paper/folded/F = null
			if (fold == "Paper plane")
				user.show_text("You fold the paper into a plane! Neat.", "blue")
				F = new /obj/item/paper/folded/plane(user)
			else
				user.show_text("You crumple the paper into a ball! Neat.", "blue")
				F = new /obj/item/paper/folded/ball(user)
			F.info = src.info
			F.old_desc = src.desc
			F.old_icon_state = src.icon_state
			user.put_in_hand_or_drop(F)

		qdel(src)

/obj/item/paper/attack_ai(var/mob/AI as mob)
	var/mob/living/silicon/ai/user
	if (isAIeye(AI))
		var/mob/living/intangible/aieye/E = AI
		user = E.mainframe
	else
		user = AI
	if (!isAI(user) || (user.current && GET_DIST(src, user.current) < 2)) //Wire: fix for undefined variable /mob/living/silicon/robot/var/current
		var/font_junk = ""
		for (var/i in src.fonts)
			font_junk += "<link href='http://fonts.googleapis.com/css?family=[i]' rel='stylesheet' type='text/css'>"
		usr.Browse("<HTML><HEAD><TITLE>[src.name]</TITLE>[font_junk]</HEAD><BODY><TT>[src.info]</TT></BODY></HTML>", "window=[src.name]")
		onclose(usr, "[src.name]")
	return

/obj/item/paper/proc/stamp(x, y, r, stamp_png, icon_state)
	if(length(stamps) < PAPER_MAX_STAMPS)
		var/list/stamp_info = list(list(stamp_png, x, y, r))
		LAZYLISTADD(stamps, stamp_info)
	if(icon_state)
		var/image/stamp_overlay = image('icons/obj/writing.dmi', "paper_[icon_state]");
		var/matrix/stamp_matrix = matrix()
		stamp_matrix.Scale(1, 1)
		stamp_matrix.Translate(rand(-2, 2), rand(-3, 2))
		stamp_overlay.transform = stamp_matrix
		src.UpdateOverlays(stamp_overlay, "stamps_[length(stamps) % PAPER_MAX_STAMPS_OVERLAYS]")

/obj/item/paper/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaperSheet")
		ui.open()

/obj/item/paper/ui_status(mob/user,/datum/ui_state/state)
	if(!user.literate)
		boutput(user, "<span class='alert'>You don't know how to read.</span>")
		return UI_CLOSE
	if(istype(src.loc, /obj/item/clipboard))
		if (isliving(user))
			var/mob/living/L = user
			return L.shared_living_ui_distance(src, viewcheck = FALSE)
		else
			return UI_UPDATE // ghosts always get updates
	. = max(..(), UI_DISABLED)
	if(IN_RANGE(user, src, 8))
		. = max(., UI_UPDATE)

/obj/item/paper/ui_act(action, params,datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(src.sealed)
		boutput(usr, "<span class='alert'>You can't do that while [src] is folded up.</span>")
		return
	switch(action)
		if("stamp")
			if(!src.stampable)
				boutput(usr, "<span class='alert'>You can't stamp [src].</span>")
				return
			var/stamp_x = text2num_safe(params["x"])
			var/stamp_y = text2num_safe(params["y"])
			var/stamp_r = text2num_safe(params["r"])	// rotation in degrees
			var/obj/item/stamp/stamp = ui.user.equipped()

			if(length(stamps) < PAPER_MAX_STAMPS)
				stamp(stamp_x, stamp_y, stamp_r, stamp.current_state, stamp.icon_state)
				update_static_data(usr, ui)
				boutput(usr, "<span class='notice'>[ui.user] stamps [src] with \the [stamp.name]!</span>")
				playsound(usr.loc, 'sound/misc/stamp_paper.ogg', 50, 0.5)
			else
				boutput(usr, "There is no where else you can stamp!")
			. = TRUE

		if("save")
			if (src.icon_state == "paper_blank" && params["text"])
				src.icon_state = "paper"
			var/in_paper = params["text"]
			var/paper_len = length(in_paper)

			field_counter = params["fieldCounter"] ? text2num_safe(params["fieldCounter"]) : field_counter

			if(paper_len > PAPER_MAX_LENGTH)
				// Side note, the only way we should get here is if
				// the javascript was modified, somehow, outside of
				// byond.  but right now we are logging it as
				// the generated html might get beyond this limit
				logTheThing(LOG_DEBUG, src, "PAPER: [key_name(ui.user)] writing to paper [name], and overwrote it by [paper_len-PAPER_MAX_LENGTH]")
			if(paper_len == 0)
				boutput(ui.user, pick("Writing block strikes again!", "You forgot to write anthing!"))
			else
				if(info != in_paper)
					boutput(ui.user, "You write on \the [src]!");
					info = in_paper
					phrase_log.log_phrase("paper", info, no_duplicates=FALSE)
					update_static_data(usr,ui)
			. = TRUE

/obj/item/paper/ui_static_data(mob/user)
	. = list(
		"name" = src.name,
		"sizeX" = src.sizex,
		"sizeY" = src.sizey,
		"text" = src.info,
		"max_length" = PAPER_MAX_LENGTH,
		"paperColor" = src.color || "white",	// color might not be set
		"stamps" = src.stamps,
		"stampable" = src.stampable,
		"sealed" = src.sealed,
	)

/obj/item/paper/ui_data(mob/user)
	. = list(
		"editUsr" = "[user]",
		"fieldCounter" = field_counter,
		"formFields" = form_fields,
	)

	var/obj/O = user.equipped()
	var/time_type = istype(O, /obj/item/stamp/clown) ? "HONK O'CLOCK" : "SHIFT TIME"
	var/T = ""
	T = time_type + ": [time2text(world.timeofday, "DD MMM 2053, hh:mm:ss")]"

	// TODO: change this awful array name & stampAssetType
	var/stamp_assets = list(
		"stamp-sprite-clown" = "[resource("images/tgui/stamp_icons/stamp-clown.png")]",
		"stamp-sprite-deny" = "[resource("images/tgui/stamp_icons/stamp-deny.png")]",
		"stamp-sprite-ok" = "[resource("images/tgui/stamp_icons/stamp-ok.png")]",
		"stamp-sprite-hop" = "[resource("images/tgui/stamp_icons/stamp-hop.png")]",
		"stamp-sprite-md" = "[resource("images/tgui/stamp_icons/stamp-md.png")]",
		"stamp-sprite-ce" = "[resource("images/tgui/stamp_icons/stamp-ce.png")]",
		"stamp-sprite-hos" = "[resource("images/tgui/stamp_icons/stamp-hos.png")]",
		"stamp-sprite-rd" = "[resource("images/tgui/stamp_icons/stamp-rd.png")]",
		"stamp-sprite-cap" = "[resource("images/tgui/stamp_icons/stamp-cap.png")]",
		"stamp-sprite-qm" = "[resource("images/tgui/stamp_icons/stamp-qm.png")]",
		"stamp-sprite-law" = "[resource("images/tgui/stamp_icons/stamp-law.png")]",
		"stamp-sprite-chap" = "[resource("images/tgui/stamp_icons/stamp-chap.png")]",
		"stamp-sprite-mime" = "[resource("images/tgui/stamp_icons/stamp-mime.png")]",
		"stamp-sprite-centcom" = "[resource("images/tgui/stamp_icons/stamp-centcom.png")]",
		"stamp-sprite-syndicate" = "[resource("images/tgui/stamp_icons/stamp-syndicate.png")]",
		"stamp-sprite-void" = "[resource("images/tgui/stamp_icons/stamp-void.png")]",
		"stamp-text-time" =  T,
		"stamp-text-name" = user.name
	)

	if(!istype(O, /obj/item/pen))
		if(istype(src.loc, /obj/item/clipboard))
			var/obj/item/clipboard/C = src.loc
			if(istype(C.pen, /obj/item/pen))
				O = C.pen
		if(istype(src.loc, /obj/item/portable_typewriter))
			var/obj/item/portable_typewriter/typewriter = src.loc
			if(istype(typewriter.pen, /obj/item/pen))
				O = typewriter.pen
	if(istype(O, /obj/item/pen))
		var/obj/item/pen/PEN = O
		. += list(
			"penFont" = PEN.font,
			"penColor" = PEN.color,
			"editMode" = PAPER_MODE_WRITING,
			"isCrayon" = FALSE,
			"stampClass" = "FAKE",
		)
	else if(istype(O, /obj/item/stamp))
		var/obj/item/stamp/stamp = O
		stamp.current_state = stamp_assets[stamp.current_mode]
		. += list(
			"stampClass" = stamp_assets[stamp.current_mode],
			"editMode" = PAPER_MODE_STAMPING,
			"penFont" = "FAKE",
			"penColor" = "FAKE",
			"isCrayon" = FALSE,
		)
	else
		. += list(
			"editMode" = PAPER_MODE_READING,
			"penFont" = "FAKE",
			"penColor" = "FAKE",
			"isCrayon" = FALSE,
			"stampClass" = "FAKE",
		)

/obj/item/paper/attackby(obj/item/P, mob/living/user, params)
	if(istype(P, /obj/item/portable_typewriter))
		return // suppress attack sound, the typewriter will load the paper in afterattack
	if(istype(P, /obj/item/pen) || istype(P, /obj/item/pen/crayon))
		if(src.sealed)
			boutput(user, "<span class='alert'>You can't write on [src].</span>")
			return
		if(length(info) >= PAPER_MAX_LENGTH) // Sheet must have less than 1000 charaters
			boutput(user, "<span class='warning'>This sheet of paper is full!</span>")
			return
		ui_interact(user)
		return
	else if(istype(P, /obj/item/stamp))
		if(src.sealed)
			boutput(user, "<span class='alert'>You can't stamp [src].</span>")
			return
		boutput(user, "<span class='notice'>You ready your stamp over the paper! </span>")
		ui_interact(user)
		return // Normaly you just stamp, you don't need to read the thing
	else if (issnippingtool(P))
		boutput(user, "<span class='notice'>You cut the paper into a mask.</span>")
		playsound(src.loc, 'sound/items/Scissor.ogg', 30, 1)
		var/obj/item/paper_mask/M = new /obj/item/paper_mask(get_turf(src.loc))
		user.put_in_hand_or_drop(M)
		user.u_equip(src)
		qdel(src)
	else if (istype(P, /obj/item/paper))
		var/obj/item/staple_gun/S = user.find_type_in_hand(/obj/item/staple_gun)
		if (S?.ammo)
			var/obj/item/paper_booklet/booklet = new(src.loc)
			user.drop_item()
			booklet.pages += src
			src.set_loc(booklet)
			booklet.Attackby(P, user, params)
			return
		else
			boutput(user, "<span class='alert'>You need a loaded stapler in hand to staple the sheets into a booklet.</span>")
	else
		// cut paper?  the sky is the limit!
		ui_interact(user)	// The other ui will be created with just read mode outside of this

	return ..()

/obj/item/paper/proc/build_fields(var/length)
	var/pixel_width = (14 + (12 * (length-1)))
	src.field_counter++
	return {"\[<input type="text" style="font:'12x Georgia';color:'null';min-width:[pixel_width]px;max-width:[pixel_width]px;" id="paperfield_[field_counter]" maxlength=[length] size=[length] />\]"}


/obj/item/paper/thermal
	name = "thermal paper"
	stampable = 0
	icon_state = "thermal_paper"
	sealed = 1
	item_function_flags = SMOKELESS

/obj/item/paper/thermal/portable_printer
	sealed = 0

/obj/item/paper/fortune
	name = "fortune"
	info = {"<center>YOUR FORTUNE</center>"}
	desc = "A slip of paper with a life-changing prophecy printed on it."
	icon_state = "fortune"

	var/static/list/action = list("Beware of", "Keep an eye on", "Seek out", "Be wary of", "Make friends with", "Aid", "Talk to", "Avoid")
	var/static/list/who = list("Officer Beepsky", "Shambling Abomination", "Remy", "Dr. Acula", "Morty", "Sylvester", "Jones", "the staff assistant next to you", "the clown")
	var/static/list/thing = list("are in possession of highly dangerous contraband.", "murdered a bee.", "kicked George.", "are a Syndicate operative.", "are a murderer.", "have disguised themselves from their true form.",
	"are not who they claim to be.", "know Shitty Bill's secret.", "are lonely.", "hugged a space bear and survived to tell the tale.", "know the legendary double-fry technique.", "have the power to reanimate the dead.",
	"consort with wizards.", "sell really awesome drugs.", "have all-access.", "know the king.", "make amazing pizza.", "have a toolbox and are not afraid to use it.")
	var/static/list/general = list("NanoTrasen locked me to this desk and is forcing me to make fortunes for these cookies please help!", "Help I'm trapped in this cookie!", "Buy Discount Dan's today!")
	var/static/list/sol = list("He plunged into the sea.", "Follow the NSS Polaris.", "Across the Channel.", "It's in the Void.")
	var/static/initialized = FALSE

	New()
		var/randme = rand(1,10)
		var/fortune = "Blah."

		if(!initialized)
			initialized = TRUE
			for(var/datum/db_record/t as anything in data_core.general.records)
				who += "[t["name"]]"

		switch(randme)
			if(1)
				fortune = "[pick(sol)]"
			if(2)
				fortune = "[pick(general)]"
			else
				fortune = "[pick(action)] [pick(who)] for they [pick(thing)]"

		info = {"<font face='System' size='3'><center>YOUR FORTUNE</center><br><br>
		Discount Dan's is the proud sponsor of your magical fortune. Whether good or bad, delightful or alarming, know it to be true.<br><br>
		[fortune]</font>"}
		..()


/obj/item/paper/thermal/fortune
	name = "fortune"
	info = {"<center>YOUR FORTUNE</center>"}
	desc = "A thermal print."

	var/list/fortune_mystical = list("fortunes","fate","doom","life","death","rewards","secrets","omens",
	"portents","aura","heart","soul","mind","mysteries","destiny","signs","essence","runes")

	var/list/fortune_nouns = list("curse","crime", "wizard", "station","traitor", "treasure","gold","monster",
	"beast","machine","ghost","spirit","station","friend","enemy","captain","doctor","assistant","chef","priest",
	"cat","skull","skeleton","phantasm","aeon","cenotaph","monument","planet","ritual","ceremony","sound","color",
	"reward","owl","key","buddy","bee","god","gods","sun","stars","crypt","cave","grave","potion","elixir","spectre",
	"clown","moon","crystals","keys","robot","cyborg","book","orb","cube","apparition","oracle","king","crown","rumpus",
	"throne","light","darkness","abyss","void","fire","entity","horde","swarm","horrors","legions","nightmare","vampire",
	"ossuary","portal","shade","stone","talisman","statue","artifact","tomb","urn","pit","depths","blood","ruckus","abomination",
	"tome","relic","serum","instrument","fungus","garden","cult","implement","device","engine","manuscript","tablet","ambrosia",
	"watcher","asteroid","drone","servant","blade","coins","amulet","sigil","symbol","coven","pact","sanctuary","grove",
	"ruin","guide","mirror","pool","chalice","bones","ashes")

	var/list/fortune_verbs = list("murder","kill","hug","meet","greet","punish","devour","exsanguinate","find","destroy","sacrifice",
	"dehumanize","reveal","cuddle","haunt","frighten","harm","sass","respect","obey","worship","revere",
	"fear","smash","banish","corrupt","profane","exhume","purge","torment","betray","eradicate","obliterate",
	"immolate","slay","confront","exalt","sing praises to","abhor","denounce","condemn","venerate","glorify",
	"deface","debase","consecrate","desecrate","summon","expunge","invoke","rebuke","awaken","consume","vilify",
	"forsake","consecrate","mourn","butcher","illuminate")

	var/list/fortune_adjectives = list("grumpy","zesty","omniscient","golden","mystical","forgotten","lost","ancient","metal","brass",
	"eldritch","warped","frozen","martian","robotic","burning","copper","dead","undying","unholy","fabulous","mighty",
	"elder","hellish","heavenly","antiquated","automated","mechanical","dread","grotesque","mysterious","auspicious",
	"screaming","rusted","iron","scary","terrifying","horrid","antique","austere","burly","dapper","dutiful",
	"enlightened","fearless","gleaming","glowing","grim","gray","gruesome","handsome","hideous","horrible",
	"ill-fated","star-crossed","impure","jaunty","nocturnal","metallic","monstrous","marvelous","prestigious",
	"quaint","radiant","robust","regal","shameful","shimmering","silent","silver","sinful","smug","tragic",
	"terrible","terrific","vast","weird","electrical","technicolor","quantum","heroic","villainous","dastardly","evil",
	"enchanted","accursed","haunted","malicious","macabre","sinister","mortal","immortal","sacred","eerie",
	"ethereal","inscrutable","lewd","stygian","tarnished","odd","subterranean","cthonic","alien","aberrant","ashen",
	"baleful","beastly","anomalous","angular","colorless","cosmic","cyclopean","dank","diabolical","elusive","solemn",
	"endless","enigmatical","festering","faceless","strange","foetid","ghoulish","infernal","kaleidoscopic",
	"nameless","obscene","pagan","holy","pallid","pale","putrid","quivering","reptilian","sepulchral","sightless",
	"unseen","doomed","loathsome","demonic","luminous","spooky","eternal","saintly","benighted","beautiful","skeletal",
	"magical","arcane","rotted","rude","crusty","divine","mercurial","blasted","damned","blessed","blazing","bumbling",
	"wailing","unspeakable","melancholy","insectoid","infested","lurid","incomprehensible","vile","amorphous","antediluvian",
	"weeping","moist","grody","unutterable","lurking","immemorial","blasphemous","nebulous","shadowy","obscure","outer","tenebrous",
	"gloomy","murky","lightless","dismal","unlit","attuned","ghastly","lugubrious","desolate","doleful","baleful","menacing",
	"dark","cold","lumpy","rotund","burly","buff","fleshy","ornate","imposing","false","fancy","elegant","creepy",
	"quirky","unnerving","abnormal","peculiar","astral","chaotic","spherical","swirling","deathless","archaic",
	"atomic","elemental","invisible","awesome","awful","apocalyptic","righteous")

	var/list/fortune_read = list("read","seen","foreseen","inscribed","beheld","witnessed")

	New()
		var/sentence_1 = "You shall soon [pick(fortune_verbs)] the [pick(fortune_adjectives)] [pick(fortune_nouns)]"
		var/sentence_2 = "remember to drink more grones"
		var/sentence_3 = "for reals"

		var/rand2 = rand(1,3)
		var/rand3 = rand(1,3)

		switch(rand2)
			if(1)
				sentence_2 = "but beware, lest the [pick(fortune_adjectives)] [pick(fortune_nouns)] [pick(fortune_verbs)] you"
			if(2)
				sentence_2 = "but take heed, for the [pick(fortune_adjectives)] [pick(fortune_nouns)] might [pick(fortune_verbs)] you"
			else
				sentence_2 = "but rejoice, for the [pick(fortune_adjectives)] [pick(fortune_nouns)] shall [pick(fortune_verbs)] you"

		switch(rand3)
			if(1)
				sentence_3 = "Seek the [pick(fortune_mystical)] of the [pick(fortune_adjectives)] [pick(fortune_nouns)] and [pick(fortune_verbs)] yourself"
			if(2)
				sentence_3 = "Remember to [pick(fortune_verbs)] the [pick(fortune_adjectives)] [pick(fortune_nouns)] and you will surely [pick(fortune_verbs)] your [pick(fortune_adjectives)] [pick(fortune_mystical)]"
			else
				sentence_3 = "You must [pick(fortune_verbs)] the [pick(fortune_adjectives)] [pick(fortune_nouns)] or the [pick(fortune_nouns)] will surely [pick(fortune_verbs)] your [pick(fortune_adjectives)] [pick(fortune_mystical)]"

		info = {"<font face='System' size='3'><center>YOUR FORTUNE</center><br><br>
		The great and [pick(fortune_adjectives)] Zoldorf has [pick(fortune_read)] your [pick(fortune_mystical)]!<br><br>
		[sentence_1]... [sentence_2]! [sentence_3].</font>"}
		return ..() // moving the

// PHOTOGRAPH

/obj/item/paper/photograph
	name = "photo"
	icon_state = "photo"
	var/photo_id = 0
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"

/obj/item/paper/photograph/New()

	..()
	src.pixel_y = 0
	src.pixel_x = 0
	return

/obj/item/paper/photograph/attack_self(mob/user as mob)

	var/n_name = input(user, "What would you like to label the photo?", "Paper Labelling", null) as null|text
	if (!n_name)
		return
	n_name = copytext(html_encode(n_name), 1, 32)
	if ((src.loc == user && isalive(user)))
		src.name = "photo[n_name ? text("- '[]'", n_name) : null]"
	src.add_fingerprint(user)
	return


// cogwerks - creepy picture things

/obj/item/paper/printout
	name = "Printed Image"
	desc = "Fancy."
	var/print_icon = 'icons/effects/sstv.dmi'
	var/print_icon_state = "sstv_1"

	New()
		..()
		src.info = {"<IMG SRC="sstv_cachedimage.png">"}
		return

	examine()
		usr << browse_rsc(icon(print_icon,print_icon_state), "sstv_cachedimage.png")
		. = ..()

	satellite
		print_icon_state = "sstv_2"
		desc = "Looks like a satellite view of a research base."

	group1
		print_icon_state = "sstv_3"
		desc = "A group photo of a research team."

	group2
		print_icon_state = "sstv_4"
		desc = "A group photo of a research team."

	group3
		print_icon_state = "sstv_6"
		desc = "A group of scientists working in a lab."

	researcher1
		print_icon_state = "sstv_5"
		desc = "A scientist handling what looks like an ice core."

	researcher2
		print_icon_state = "sstv_9"
		desc = "The image is badly distorted, but it seems to be a researcher carrying a lab monkey."

	slide1
		print_icon_state = "sstv_7"
		desc = "A microscopic slide. Seems to be some sort of biological cell structure."

	slide2
		print_icon_state = "sstv_8"
		desc = "A dissection report of some kind of arachnid."

	slide3
		print_icon_state = "sstv_10"
		desc = "A dissection report of... something. What the hell is that?"

	emerg1
		print_icon_state = "sstv_11"
		desc = "A coded emergency broadcast."

	crewlog1
		print_icon_state = "sstv_12"
		desc = "A blurry image of something approaching the photographer."

	crewlog2
		print_icon_state = "sstv_13"
		desc = "Oh god."

/obj/item/paper_bin
	name = "paper bin"
	icon = 'icons/obj/writing.dmi'
	icon_state = "paper_bin1"
	uses_multiple_icon_states = 1
	amount = 10
	item_state = "sheet-metal"
	throwforce = 1
	w_class = W_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7

	//cogwerks - burn vars
	burn_point = 600
	burn_output = 800
	burn_possible = 1

	/// the item type this bin contains, should always be a subtype for /obj/item for reasons...
	var/bin_type = /obj/item/paper

/obj/item/paper_bin/artifact_paper
	name = "artifact analysis form tray"
	desc = "A tray full of forms for classifying alien artifacts."
	icon = 'icons/obj/writing.dmi'
	icon_state = "artifact_form_tray"
	amount = INFINITY
	bin_type = /obj/item/sticker/postit/artifact_paper

	update()
		tooltip_rebuild = 1

/obj/item/paper_bin/proc/update()
	tooltip_rebuild = 1
	src.icon_state = "paper_bin[(src.amount || locate(bin_type, src)) ? "1" : null]"
	return

/obj/item/paper_bin/mouse_drop(mob/user as mob)
	if (user == usr && !user.restrained() && !user.stat && (user.contents.Find(src) || in_interact_range(src, user)))
		if (!user.put_in_hand(src))
			return ..()

/obj/item/paper_bin/attack_hand(mob/user)
	src.add_fingerprint(user)
	var/obj/item/paper = locate(bin_type) in src
	if (paper)
		user.put_in_hand_or_drop(paper)
	else
		if (src.amount >= 1 && user) //Wire: Fix for Cannot read null.loc (&& user)
			src.amount--
			var/obj/item/P = new bin_type(src)
			user.put_in_hand_or_drop(P)
			if (rand(1,100) == 13 && istype(P, /obj/item/paper))
				var/obj/item/paper/PA = P
				PA.info = "Help me! I am being forced to code SS13 and It won't let me leave."
	src.update()

/obj/item/paper_bin/attack_self(mob/user as mob)
	. = ..()
	src.Attackhand(user)

/obj/item/paper_bin/attackby(obj/item/P, mob/user) // finally you can write on all the paper AND put it back in the bin to mess with whoever shows up after you ha ha
	if (istype(P, bin_type))
		user.drop_item()
		P.set_loc(src)
		boutput(user, "You place [P] into [src].")
		src.update()
	else
		return ..()

/obj/item/paper_bin/get_desc()
	var/n = src.amount
	for(var/obj/item/paper/P in src)
		n++
	return "There's [(n > 0) ? n : "no" ] paper[s_es(n)] in \the [src]."

/obj/item/paper_bin/robot
	name = "semi-automatic paper bin"
	var/next_generate = 0

	attack_self(mob/user as mob)
		if (src.amount < 1 && isnull(locate(bin_type) in src))
			if (src.next_generate < TIME)
				boutput(user, "The [src] generates another sheet of paper using the power of [pick("technology","science","computers","nanomachines",5;"magic",5;"extremely tiny clowns")].")
				src.amount++
				src.update()
				src.next_generate = TIME + 5 SECONDS
				return

			boutput(user, "Nothing left in the [src]. Maybe you should check again later.")
			return

		boutput(user, "You remove a piece of paper from the [src].")
		return attack_hand(user)

/obj/item/stamp
	name = "rubber stamp"
	desc = "A no-nonsense National Notary rubber stamp for stamping important documents. It has a simple acrylic handle."
	icon = 'icons/obj/writing.dmi'
	icon_state = "stamp"
	item_state = "stamp"
	flags = FPRINT | TABLEPASS
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 7
	throw_range = 15
	m_amt = 60
	stamina_damage = 0
	stamina_cost = 0
	rand_pos = 1
	var/special_mode = null
	var/is_reassignable = 1
	var/assignment = null
	var/available_modes = list("Granted", "Denied", "Void", "Current Time", "Your Name");
	var/current_mode = "stamp-sprite-ok"
	var/current_state = null

/obj/item/stamp/New()
	..()
	if(special_mode)
		available_modes += special_mode
		current_mode = (STAMP_IDS[special_mode])

/obj/item/stamp/proc/set_assignment(A)
	if (istext(A))
		src.assignment = A
		src.desc = "A rubber stamp for stamping important documents. It is assigned to: \"[A]\"."
		return
	else
		src.assignment = null
		src.desc = "A rubber stamp for stamping important documents."
		return
/obj/item/stamp/attackby(obj/item/C, mob/user)// assignment with ID
	if (istype(C, /obj/item/card/id))
		var/obj/item/card/id/ID = C
		if (!src.is_reassignable)
			boutput(user, "<span class='alert'>This rubber stamp cannot be reassigned!</span>")
			return
		if (!isnull(src.assignment))
			boutput(user, "<span class='alert'>This rubber stamp has already been assigned!</span>")
			return
		else if (!ID.assignment)
			boutput(user, "<span class='alert'>This ID isn't assigned to a job!</span>")
			return
		src.set_assignment(ID.assignment)
		boutput(user, "<span class='notice'>You update the assignment of the rubber stamp.</span>")
		return

/obj/item/stamp/attack_self() // change current mode
	var/NM = input(usr, "Configure \the [src]?", "[src.name]", src.current_mode) in src.available_modes
	if (!NM || !length(NM) || !(NM in src.available_modes))
		return
	src.current_mode = (STAMP_IDS[NM])
	boutput(usr, "<span class='notice'>You set \the [src] to '[NM]'.</span>")
	return

/obj/item/stamp/examine()
	. = ..()
	. += "It is set to '[current_mode]' mode."

/obj/item/stamp/reagent_act(reagent_id, volume)
	if (..())
		return
	switch(reagent_id)
		if ("acetone") // allow reassigning with acetone
			if (isnull(src.assignment) || !src.is_reassignable)
				return
			var/turf/T = get_turf(src)
			T.visible_message("<span>The acetone eats away at the rubber stamp's structure; it is now unassigned.</span>")
			src.set_assignment(null)
	return

/obj/item/stamp/custom_suicide = 1
/obj/item/stamp/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	user.visible_message("<span class='alert'><b>[user] stamps 'VOID' on [his_or_her(user)] forehead!</b></span>")
	user.TakeDamage("head", 250, 0)
	return 1


/obj/item/stamp // static staff stamps
	cap
		name = "\improper captain's rubber stamp"
		desc = "The Captain's rubber stamp for stamping important documents. Ooh, it's the really fancy National Notary 'Congressional' model with the fine ebony handle."
		icon_state = "stamp-cap"
		special_mode = "Captain"
		is_reassignable = 0
		assignment = "stamp-cap"
	hop
		name = "\improper head of personnel's rubber stamp"
		desc = "The Head of Personnel's rubber stamp for stamping important documents. Looks like one of those fancy National Notary 'Continental' models with the kingwood handle."
		icon_state = "stamp-hop"
		special_mode = "Head of Personnel"
		is_reassignable = 0
		assignment = "stamp-hop"
	hos
		name = "\improper head of security's rubber stamp"
		desc = "The Head of Security's rubber stamp for stamping important documents. Looks like one of those fancy National Notary 'Bancroft' models with the bloodwood handle."
		icon_state = "stamp-hos"
		special_mode = "Head of Security"
		is_reassignable = 0
		assignment = "stamp-hos"
	ce
		name = "\improper chief engineer's rubber stamp"
		desc = "The Chief Engineer's rubber stamp for stamping important documents. Looks like one of those fancy National Notary 'St. Mary' models with the ironwood handle."
		icon_state = "stamp-ce"
		special_mode = "Chief Engineer"
		is_reassignable = 0
		assignment = "stamp-ce"
	md
		name = "\improper medical director's rubber stamp"
		desc = "The Medical Director's rubber stamp for stamping important documents. Looks like one of those fancy National Notary 'St. Anne' models with the rosewood handle."
		icon_state = "stamp-md"
		special_mode = "Medical Director"
		is_reassignable = 0
		assignment = "stamp-md"
	rd
		name = "\improper research director's rubber stamp"
		desc = "The Research Director's rubber stamp for stamping important documents. Looks like one of those fancy National Notary 'St. John' models with the purpleheart handle."
		icon_state = "stamp-rd"
		special_mode = "Research Director"
		is_reassignable = 0
		assignment = "stamp-rd"
	clown
		name = "\improper clown's rubber stamp"
		desc = "The Clown's rubber stamp for stamping whatever important documents they've gotten their hands on. It doesn't seem very legit."
		icon_state = "stamp-honk"
		special_mode = "Clown"
		is_reassignable = 0
		assignment = "stamp-honk"
	centcom
		name = "\improper centcom executive rubber stamp"
		desc = "Some bureaucrat from Centcom probably lost this. Dang, is that National Notary's 'Admiral Sampson' model with the exclusive blackwood handle?"
		icon_state = "stamp-centcom"
		special_mode = "Centcom"
		is_reassignable = 0
		assignment = "stamp-centcom"
	mime
		name = "\improper mime's rubber stamp"
		desc = "The Mime's rubber stamp for stamping whatever important documents they've gotten their hands on. It doesn't seem very legit."
		icon_state = "stamp-mime"
		special_mode = "Mime"
		is_reassignable = 0
		assignment = "stamp-mime"
	chap
		name = "\improper chaplain's rubber stamp"
		desc = "The Chaplain's rubber stamp for stamping whatever important documents they've gotten their hands on. It's the National Notary 'Chesapeake' model in varnished oak."
		icon_state = "stamp-chap"
		special_mode = "Chaplain"
		is_reassignable = 0
		assignment = "stamp-chap"
	qm
		name = "\improper quartermaster's rubber stamp"
		desc = "The Quartermaster's rubber stamp for stamping whatever important documents they've gotten their hands on. A classic National Notary 'Eastport' model in oiled black walnut."
		icon_state = "stamp-qm"
		special_mode = "Quartermaster"
		is_reassignable = 0
		assignment = "stamp-qm"
	syndicate
		name = "\improper syndicate rubber stamp"
		desc = "Syndicate rubber stamp for stamping whatever important documents they've gotten their hands on. Surprisingly, it's also a National Notary 'Continental'. Not many choices out here."
		icon_state = "stamp-syndicate"
		special_mode = "Syndicate"
		is_reassignable = 0
		assignment = "stamp-syndicate"
	law
		name = "\improper security's rubber stamp"
		desc = "Security's rubber stamp for stamping whatever important documents they've gotten their hands on. It's the rugged National Notary 'Severn' model with the rock maple handle."
		icon_state = "stamp-syndicate"
		special_mode = "Security"
		is_reassignable = 0
		assignment = "stamp-law"

/obj/item/paper/folded
	name = "folded paper"
	icon_state = "paper"
	burn_possible = 1
	sealed = 1
	var/old_desc = null
	var/old_icon_state = null

/obj/item/paper/folded/attack_self(mob/user as mob)
	if (src.sealed)
		user.show_text("You unfold the [src] back into a sheet of paper! It looks pretty crinkled.", "blue")
		src.name = "crinkled paper"
		src.desc = src.old_desc
		if(src.old_icon_state)
			src.icon_state = src.old_icon_state
		else
			if(src.info)
				src.icon_state = "paper"
			else
				src.icon_state = "paper_blank"
		src.sealed = 0
	else
		..()

/obj/item/paper/folded/examine()
	if (src.sealed)
		return list(desc)
	else
		return ..()

/obj/item/paper/folded/plane
	name = "paper plane"
	desc = "If you throw it in space is it a paper spaceship?"
	icon_state = "paperplane"
	throw_speed = 1
	throw_spin = 0

/obj/item/paper/folded/plane/hit_check(datum/thrown_thing/thr)
	if(src.throwing && src.sealed)
		src.throw_unlimited = 1

/obj/item/paper/folded/plane/attack_self(mob/user as mob)
	if (src.sealed) //Set throwing vars when unfolding (mostly in the parent call) so that an unfolded paper "plane" behaves like regular paper
		throw_speed = 3 //default for paper
		throw_spin = 1
	..()

/obj/item/paper/folded/ball
	name = "paper ball"
	desc = "It's really fun pelting your coworkers with these."
	icon_state = "paperball"

/obj/item/paper/folded/ball/attack(mob/M, mob/user)
	if (iscarbon(M) && M == user && src.sealed)
		M.visible_message("<span class='notice'>[M] stuffs [src] into [his_or_her(M)] mouth and eats it.</span>")
		playsound(M, 'sound/misc/gulp.ogg', 30, 1)
		eat_twitch(M)
		var/obj/item/paper/P = src
		user.u_equip(P)
		qdel(P)
	else
		..()

/obj/item/paper/nukeop_uplink_purchases
	name = "Shipping Manifest"
	icon_state = "paper"

	New()
		. = ..()
		if(!length(syndi_buylist_cache))
			SPAWN(30 SECONDS) //This spawns empty on-map otherwise, 30s is a safe bet
				build_paper()
		else
			build_paper()

	proc/build_paper()
		var/placeholder_info
		placeholder_info += "<b>Syndicate Shipping Manifest</b><br>"
		for(var/datum/syndicate_buylist/commander/commander_item in syndi_buylist_cache)
			var/item_info = world.load_intra_round_value("NuclearCommander-[commander_item]-Purchased")
			if(isnull(item_info))
				item_info = 0
			placeholder_info += "<br><br><b>[commander_item.name]</b>: [item_info]"
		info = placeholder_info
