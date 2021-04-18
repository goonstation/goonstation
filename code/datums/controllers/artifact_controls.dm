var/datum/artifact_controller/artifact_controls

/datum/artifact_controller
	var/list/artifacts = list()
	var/list/datum/artifact/artifact_types = list()
	var/list/artifact_rarities = list()
	var/list/artifact_origins = list()

	var/list/artifact_origin_names = list()
	var/list/artifact_type_names = list()
	var/list/artifact_fault_names = list()
	var/list/artifact_trigger_names = list()
	var/spawner_type = null
	var/spawner_cine = 0

	New()
		..()
		artifact_rarities["all"] = list()

		// origin list
		for (var/X in childrentypesof(/datum/artifact_origin))
			var/datum/artifact_origin/AO = new X
			artifact_origins += AO
			artifact_origin_names += AO.type_name
			artifact_rarities[AO.name] = list()

		// type list
		// also make one list for each origin of all artifact types
		// and also one that just holds all types
		// the type is the index, the value the rarity
		// for use with weighted_pick
		for (var/A in concrete_typesof(/datum/artifact))
			var/datum/artifact/AI = new A
			artifact_types += AI
			artifact_type_names += AI.type_name

			artifact_rarities["all"][A] = AI.rarity_weight
			for (var/origin in artifact_rarities)
				if(origin in AI.validtypes)
					artifact_rarities[origin][A] = AI.rarity_weight

		// fault list
		for (var/X in concrete_typesof(/datum/artifact_fault))
			var/datum/artifact_fault/AF = new X
			artifact_fault_names += AF.type_name

		// trigger list
		for (var/X in concrete_typesof(/datum/artifact_trigger))
			var/datum/artifact_trigger/AT = new X
			if(AT.used)
				artifact_trigger_names += AT.type_name

	proc/get_origin_from_string(var/string)
		if (!istext(string))
			return
		for (var/datum/artifact_origin/AO in src.artifact_origins)
			if (AO.name == string)
				return AO
		return null

	// Added. Admin actions related to artfacts were not logged at all (Convair880).
	proc/log_me(var/mob/user, var/obj/O, var/type_of_action, var/trigger_alert = 0)
		if (type_of_action == "spawns")
			logTheThing("admin", user, null, "spawns a random artifact at [user && ismob(user) ? "[log_loc(user)]" : "*unknown*"].")
			logTheThing("diary", user, null, "spawns a random artifact at [user && ismob(user) ? "[log_loc(user)]" : "*unknown*"].", "admin")
			return

		if (!O || !istype(O.artifact, /datum/artifact) || !type_of_action)
			return

		var/datum/artifact/A = O.artifact

		logTheThing("admin", user, null, "[type_of_action] an artifact ([A.type]) at [log_loc(O)].")
		logTheThing("diary", user, null, "[type_of_action] an artifact ([A.type]) at [log_loc(O)].", "admin")
		if (trigger_alert)
			message_admins("[key_name(user)] [type_of_action] an artifact ([A.type]) at [log_loc(O)].")
		return

	proc/config()
		var/dat = "<html><body><title>Artifact Controller</title>"
		dat += "<b><u>Artifact Controls</u></b><HR><small>"
		dat += "<a href='byond://?src=\ref[src];Spawnnew=1'>Spawn a new Artifact on your current tile</b></a><br>"

		dat += "<a href='byond://?src=\ref[src];Spawntype=1'>Spawn Type:</a> "
		if (!spawner_type)
			dat += "Random"
		else
			dat += "[spawner_type]"

		dat += "<br><a href='byond://?src=\ref[src];Spawncine=1'>Cinematic Spawning:</a> "
		if (spawner_cine)
			dat += "Yes"
		else
			dat += "No"
		dat += "<br><br>"

		var/datum/artifact/A = null
		var/turf/T = null
		for (var/obj/O in src.artifacts)
			if (!istype(O.artifact,/datum/artifact/))
				continue
			A = O.artifact
			T = get_turf(O)

			dat += "<b>"
			if (A.internal_name)
				dat += "[A.internal_name] "
			else
				dat += "Unnamed Artifact "
			dat += "</b>"
			if (istype(T,/turf/))
				dat += "in [T.loc]<br>"

			dat += "[O.name], [A.artitype.name], [A.type]<br>"
			for(var/trigger in A.triggers)
				dat += "[trigger] "
			if(A.triggers.len)
				dat += "<br>"

			dat += "<a href='byond://?src=\ref[src];Activate=\ref[O]'>"
			if (!A.activated)
				dat += "Activate"
			else
				dat += "Deactivate"
			dat += "</a> * "
			dat += "<a href='byond://?src=\ref[src];Jumpto=\ref[O]'>Jump To</a> * "
			dat += "<a href='byond://?src=\ref[src];Get=\ref[O]'>Get</a> * "
			dat += "<a href='byond://?src=\ref[src];Destroy=\ref[O]'>Destroy</a><br><br>"

		dat += "</small></body></html>"

		usr.Browse(dat,"window=artifacts;size=400x600")

	Topic(href, href_list[])
		usr_admin_only
		if (href_list["Activate"])
			var/obj/O = locate(href_list["Activate"]) in src.artifacts
			if (!istype(O,/obj/))
				return
			if (!istype(O.artifact,/datum/artifact/))
				return
			var/datum/artifact/A = O.artifact
			if (A.activated)
				O.ArtifactDeactivated()
			else
				O.ArtifactActivated()

			src.log_me(usr, O, A.activated ? "activates" : "deactivates", 1)

		else if (href_list["Jumpto"])
			var/obj/O = locate(href_list["Jumpto"]) in src.artifacts
			if (!istype(O,/obj/))
				return
			var/turf/T = O.loc
			usr.set_loc(T)

			src.log_me(usr, O, "jumps to", 0)

		else if (href_list["Get"])
			var/obj/O = locate(href_list["Get"]) in src.artifacts
			if (!istype(O,/obj/))
				return
			var/turf/T = usr.loc
			O.set_loc(T)

			src.log_me(usr, O, "teleports", 0)

		else if (href_list["Destroy"])
			var/obj/O = locate(href_list["Destroy"]) in src.artifacts
			if (!istype(O,/obj/))
				return
			if (!istype(O.artifact,/datum/artifact/))
				return

			src.log_me(usr, O, "destroys", 1)
			O.ArtifactDestroyed()

		else if (href_list["Spawnnew"])
			var/turf/T = get_turf(usr)
			new /obj/artifact_spawner(T,spawner_type,spawner_cine)

			src.log_me(usr, null, "spawns", 0)

		else if (href_list["Spawntype"])
			spawner_type = input("What type of artifact?","Artifact Controls") as null|anything in list("ancient","martian","wizard","eldritch","precursor")//,"bee","void","lattice","feather")

		else if (href_list["Spawncine"])
			spawner_cine = !spawner_cine

		src.config()

// Origins

/datum/artifact_origin
	var/type_name = "bad artifact code"
	var/name = "unknown"
	var/max_sprites = 7
	var/impact_reaction_one = 0
	var/impact_reaction_two = 0
	var/heat_reaction_one = 0
	var/fx_red_min = 0
	var/fx_red_max = 255
	var/fx_green_min = 0
	var/fx_green_max = 255
	var/fx_blue_min = 0
	var/fx_blue_max = 255
	var/nofx = 0 // If set to 1, does not apply an overlay but a flat icon_state change.
	var/scramblechance = 10 //probability to have "fake" artifact with altered appearance
	var/list/activation_sounds = list()
	var/list/instrument_sounds = list()
	var/list/fault_types = list("all")
	var/list/adjectives = list("strange","unusual","odd","curious","bizarre","weird","abnormal","peculiar")
	var/list/nouns_large = list("object","machine","artifact","contraption","structure","edifice")
	var/list/nouns_small = list("item","device","relic","widget","utensil","gadget","accessory","gizmo")
	var/list/touch_descriptors = list("You can't really tell how it feels.")

	New()
		..()
		if ("all" in fault_types)
			fault_types += concrete_typesof(/datum/artifact_fault)

	proc/post_setup(obj/artifact)
		var/datum/artifact/AD = artifact.artifact
		var/rarityMod = AD.get_rarity_modifier()
		if(prob(100*rarityMod))
			artifact.transform = matrix(artifact.transform, -1, 1, MATRIX_SCALE)
		if(prob(20 * rarityMod))
			artifact.transform = matrix(artifact.transform, 1, -1, MATRIX_SCALE)

	proc/generate_name()
		return "unknown object"


/datum/artifact_origin/ancient
	type_name = "Silicon"
	name = "ancient"
	fault_types = list(
		/datum/artifact_fault/burn = 10,
		/datum/artifact_fault/irradiate = 10,
		/datum/artifact_fault/shutdown = 10,
		/datum/artifact_fault/zap = 10,
		/datum/artifact_fault/explode = 10,
		/datum/artifact_fault/messager/ai_laws = 10)
	activation_sounds = list('sound/machines/ArtifactAnc1.ogg')
	instrument_sounds = list("sound/musical_instruments/artifact/Artifact_Ancient_1.ogg",
		"sound/musical_instruments/artifact/Artifact_Ancient_2.ogg",
		"sound/musical_instruments/artifact/Artifact_Ancient_3.ogg",
		"sound/musical_instruments/artifact/Artifact_Ancient_4.ogg")
	impact_reaction_one = 1
	impact_reaction_two = 0.5
	heat_reaction_one = 1.5
	fx_red_min = 50
	fx_red_max = 255
	fx_green_min = 50
	fx_green_max = 255
	fx_blue_min = 50
	fx_blue_max = 255
	adjectives = list("dark","cold","smooth","angular","humming","sharp-edged","droning")
	nouns_large = list("monolith","slab","obelisk","pylon","menhir","machine","structure")
	nouns_small = list("implement","device","instrument","apparatus","appliance","mechanism","tool")
	touch_descriptors = list("It feels cold.","It feels smooth.","Touching it makes you feel uneasy.")

	post_setup(obj/artifact)
		. = ..()
		var/datum/artifact/AD = artifact.artifact
		var/rarityMod = AD.get_rarity_modifier()
		if(prob(50 * rarityMod))
			var/scaling = 1.1 + rand() * 0.2
			artifact.transform = matrix(artifact.transform, scaling, scaling, MATRIX_SCALE)
		if(prob(100 * rarityMod))
			var/col = rand(100, 230)
			artifact.color = rgb(col, col, col)

	generate_name()
		return "unit [pick("alpha","sigma","tau","phi","gamma","epsilon")]-[pick("x","z","d","e","k")] [rand(100,999)]"

/datum/artifact_origin/martian
	type_name = "Martian"
	name = "martian"
	fault_types = list(
		/datum/artifact_fault/shutdown = 10,
		/datum/artifact_fault/zap = 5,
		/datum/artifact_fault/poison = 15,
		/datum/artifact_fault/messager/what_people_said = 5,
		/datum/artifact_fault/messager/comforting_whispers = 5,
		/datum/artifact_fault/grow = 8,
		/datum/artifact_fault/shrink = 8,
		/datum/artifact_fault/messager/emoji = 10)
	activation_sounds = list('sound/machines/ArtifactMar1.ogg','sound/machines/ArtifactMar2.ogg')
	instrument_sounds = list("sound/musical_instruments/artifact/Artifact_Martian_1.ogg",
		"sound/musical_instruments/artifact/Artifact_Martian_2.ogg",
		"sound/musical_instruments/artifact/Artifact_Martian_3.ogg",
		"sound/musical_instruments/artifact/Artifact_Martian_4.ogg")
	impact_reaction_one = 1
	impact_reaction_two = 0
	heat_reaction_one = 0.99
	fx_red_min = 50
	fx_red_max = 90
	fx_green_min = 70
	fx_green_max = 120
	fx_blue_min = 50
	fx_blue_max = 90
	adjectives = list("squishy","gooey","clammy","quivering","twitching","pulpy","fleshy")
	nouns_large = list("mass","pile","heap","glob","mound","clump","bulk")
	nouns_small = list("lump","chunk","cluster","clod","nugget","giblet","organ")
	touch_descriptors = list("It feels warm.","It feels gross.","You can feel a faint pulsing.")
	var/list/prefix = list("cardio","neuro","physio","morpho","brachio","bronchi","dermo","ossu")
	var/list/thingy = list("cystic","genetic","metabolic","static","vascular","muscular")
	var/list/action = list("stimulator","suppressor","regenerator","depressor","mutator")

	post_setup(obj/artifact)
		. = ..()
		var/datum/artifact/AD = artifact.artifact
		var/rarityMod = AD.get_rarity_modifier()
		if(prob(50 * rarityMod))
			artifact.transform = matrix(artifact.transform, rand(-15, 15), MATRIX_ROTATE)
		if(prob(200 * rarityMod))
			artifact.color = rgb(rand(210, 255), rand(210, 255), rand(210, 255))
		if(prob(80 * rarityMod))
			var/icon/distortion_icon = icon('icons/effects/distort.dmi', "martian[rand(1,7)]")
			if(prob(20))
				distortion_icon = turn(distortion_icon, rand(360))
			var/size = rand(4, 6 + 8 * rarityMod) * pick(-1, 1)
			artifact.filters += filter(
				type="displace",
				icon=distortion_icon,
				size=size)
			if(prob(80 * rarityMod))
				var/filter = artifact.filters[length(artifact.filters)]
				var/anim_time = pick(rand() * 1 SECOND + 1 SECOND, rand() * 5 SECONDS, rand() * 1 MINUTE)
				var/new_size = size + rand(-8, 8)
				if(prob(15) || anim_time > 5 SECONDS && prob(70))
					if(prob(50))
						new_size = -size
					else
						new_size *= 1.5
				animate(filter,
					size = new_size,
					time = anim_time,
					easing = SINE_EASING,
					flags = ANIMATION_PARALLEL,
					loop = -1)
				if(anim_time < 2 SECONDS && prob(35))
					animate(time = rand() * 1.5 MINUTES)
				animate(
					size = size,
					time = anim_time,
					easing = SINE_EASING,
					loop = -1)
				if(anim_time < 2 SECONDS && prob(35))
					animate(time = rand() * 1.5 MINUTES)

	generate_name()
		var/namestring = ""
		namestring += "[pick(prefix)]"
		namestring += "[pick(thingy)] "
		namestring += "[pick(action)]"
		return namestring

/datum/artifact_origin/wizard
	type_name = "Wizard"
	name = "wizard"
	fault_types = list(
		/datum/artifact_fault/irradiate = 10,
		/datum/artifact_fault/shutdown = 10,
		/datum/artifact_fault/warp = 15,
		/datum/artifact_fault/zap = 10,
		/datum/artifact_fault/burn = 10,
		/datum/artifact_fault/explode = 5,
		/datum/artifact_fault/messager/creepy_whispers = 5,
		/datum/artifact_fault/messager/comforting_whispers = 5,
		/datum/artifact_fault/messager/what_dead_people_said = 5,
		/datum/artifact_fault/messager/what_people_said = 5,
		/datum/artifact_fault/messager/emoji = 5)
	activation_sounds = list('sound/machines/ArtifactWiz1.ogg')
	instrument_sounds = list("sound/musical_instruments/artifact/Artifact_Wizard_1.ogg",
		"sound/musical_instruments/artifact/Artifact_Wizard_2.ogg",
		"sound/musical_instruments/artifact/Artifact_Wizard_3.ogg",
		"sound/musical_instruments/artifact/Artifact_Wizard_4.ogg")
	impact_reaction_one = 8
	impact_reaction_two = 6
	heat_reaction_one = 0.75
	fx_red_min = 40
	fx_red_max = 125
	fx_green_min = 125
	fx_green_max = 255
	fx_blue_min = 125
	fx_blue_max = 255
	adjectives = list("ornate","regal","imposing","fancy","elaborate","elegant","ostentatious")
	nouns_large = list("jewel","crystal","sculpture","statue","brazier","ornament","edifice")
	nouns_small = list("wand","scepter","staff","rod","cane","crozier","trophy")
	touch_descriptors = list("It feels warm.","It feels smooth.","It is suprisingly pleasant to touch.")
	var/list/material = list("ebon","ivory","pearl","golden","malachite","diamond","ruby","emerald","sapphire","opal")
	var/list/object = list("jewel","trophy","favor","boon","token","crown","treasure","sacrament","oath")
	var/list/aspect = list("wonder","splendor","power","plenty","mystery","glory","majesty","eminence","grace")

	post_setup(obj/artifact)
		. = ..()
		var/datum/artifact/AD = artifact.artifact
		var/rarityMod = AD.get_rarity_modifier()
		if(prob(300*rarityMod))
			var/hue1 = prob(100*rarityMod) ? rand(360) : (55 + rand(-10, 10))
			var/list/col1
			if(prob(150*rarityMod))
				col1 = hsv2rgblist(hue1, rand() * 0.2 + 0.5, rand() * 0.2 + 0.6)
			else
				col1 = list(255, 168, 0)
			var/hue2 = 180 + hue1 + rand(-135, 135)
			if(prob(100*rarityMod))
				hue2 = rand(360)
			var/list/col2 = hsv2rgblist(hue2, rand() * 0.3 + 0.7, rand() * 0.1 + 0.9)
			artifact.color = affine_color_mapping_matrix(
				list("#000000", "#ffa800", "#ae2300", "#0000ff"),
				list(random_color(), col1, col2, "#0000ff")
			)
		if(prob(50*rarityMod))
			artifact.alpha = rand(200, 255)

	generate_name()
		var/namestring = ""
		namestring += "[pick(material)] "
		namestring += "[pick(object)] of "
		namestring += "[pick(aspect)]"
		return namestring

/datum/artifact_origin/eldritch
	type_name = "Eldritch"
	name = "eldritch"
	activation_sounds = list('sound/machines/ArtifactEld1.ogg','sound/machines/ArtifactEld2.ogg')
	instrument_sounds = list("sound/musical_instruments/artifact/Artifact_Eldritch_1.ogg",
		"sound/musical_instruments/artifact/Artifact_Eldritch_2.ogg",
		"sound/musical_instruments/artifact/Artifact_Eldritch_3.ogg",
		"sound/musical_instruments/artifact/Artifact_Eldritch_4.ogg")
	fault_types = list(
		/datum/artifact_fault/murder = 2,
		/datum/artifact_fault/messager/creepy_whispers = 5,
		/datum/artifact_fault/messager/what_dead_people_said = 5,
		/datum/artifact_fault/poison = 10,
		/datum/artifact_fault/irradiate = 10,
		/datum/artifact_fault/shutdown = 5,
		/datum/artifact_fault/zap = 8,
		/datum/artifact_fault/explode = 5,
		/datum/artifact_fault/warp = 15,
		/datum/artifact_fault/grow = 5,
		/datum/artifact_fault/shrink = 5,
		/datum/artifact_fault/messager/emoji = 3)
	impact_reaction_one = 0.5
	impact_reaction_two = 0
	heat_reaction_one = 0.25
	fx_red_min = 40
	fx_red_max = 255
	fx_green_min = 40
	fx_green_max = 255
	fx_blue_min = 40
	fx_blue_max = 255
	adjectives = list("creepy","unnerving","ominous","threatening","horrid","evil-looking","lurid")
	nouns_large = list("edifice","effigy","statue","idol","sculpture","stele","artifact")
	nouns_small = list("spike","needle","thorns","relic","carving","figurine","item")
	touch_descriptors = list("It feels cold.","It feels gross.","Touching it makes you feel uneasy.")
	var/list/general_adjectives = list("dark","cold","horrid","foul","sinister","cruel","rancid","demonic")
	var/list/object_nouns = list("hand","eye","finger","blood","breath","thorns","mantle","skin","bane","scourge","wrath",
	"favor","will","tentacles","mandible","fangs","maw","flesh","ichor","teeth","heart")
	var/list/people = list("master","lord","king","queen","lady","mother","father","master","beast","brute","tyrant")
	var/list/person_adjectives = list("dread","great","old","ancient","vile","wicked","majestic","vast","mighty",
	"evil","heartless","fierce","ferocious")
	var/list/horror_name_start = list("trog","yogg","ta","y","has","shub","az","cth","cha","ul","xel","og","flu","wrk")
	var/list/horror_name_mid = list("sog","ran","gon","ni","a","hul","ttur","ay","o","lo","ncac","sin","fel","di")
	var/list/horror_name_end = list("dyte","oth","tula","olac","tur","bburath","thoth","hu","dha","aoth","tath","goth","ter")

	generate_name()
		var/the_horror = src.horror_name()
		var/namestring = ""
		if (prob(50))
			if (prob(20))
				namestring += "[pick(general_adjectives)] "
			namestring += "[pick(object_nouns)] of "
			if (prob(20))
				namestring += "[pick(person_adjectives)] "
			namestring += "[the_horror]"
		else
			if (prob(20))
				namestring += "[pick(person_adjectives)] "
			namestring += "[the_horror]'s "
			if (prob(20))
				namestring += "[pick(general_adjectives)] "
			namestring += "[pick(object_nouns)]"
		return namestring

	proc/horror_name()
		var/fthagn = ""
		if (prob(20))
			fthagn += "[pick(people)] "
		fthagn += "[pick(horror_name_start)]"
		if (prob(20))
			fthagn += "[pick("'","-")]"
		fthagn += "[pick(horror_name_mid)]"
		if (prob(20))
			fthagn += "[pick("'","-")]"
		fthagn += "[pick(horror_name_end)]"
		return fthagn // ia ia

/datum/artifact_origin/precursor
	type_name = "Precursor"
	name = "precursor"
	activation_sounds = list('sound/machines/ArtifactPre1.ogg')
	instrument_sounds = list("sound/musical_instruments/artifact/Artifact_Precursor_1.ogg",
		"sound/musical_instruments/artifact/Artifact_Precursor_2.ogg",
		"sound/musical_instruments/artifact/Artifact_Precursor_3.ogg",
		"sound/musical_instruments/artifact/Artifact_Precursor_4.ogg",
		"sound/musical_instruments/artifact/Artifact_Precursor_5.ogg",
		"sound/musical_instruments/artifact/Artifact_Precursor_6.ogg")
	fault_types = list(
		/datum/artifact_fault/irradiate = 10,
		/datum/artifact_fault/shutdown = 5,
		/datum/artifact_fault/zap = 10,
		/datum/artifact_fault/explode = 5,
		/datum/artifact_fault/burn = 5,
		/datum/artifact_fault/warp = 10,
		/datum/artifact_fault/messager/what_people_said = 10,
		/datum/artifact_fault/poison = 2)
	impact_reaction_one = 2
	impact_reaction_two = 10
	heat_reaction_one = 2
	fx_red_min = 155
	fx_red_max = 255
	fx_green_min = 155
	fx_green_max = 255
	fx_blue_min = 155
	fx_blue_max = 255
	adjectives = list("quirky","metallic","janky","bulky","chunky","cumbersome","unwieldy")
	nouns_large = list("contraption","machine","object","mechanism","artifact","machinery","structure")
	nouns_small = list("widget","thingy","device","appliance","mechanism","accessory","gizmo")
	touch_descriptors = list("It feels warm.","It feels cold.","It is suprisingly pleasant to touch.",
	"You can feel a faint pulsing.")
	var/list/prefixes = list("meta","poly","anti","hyper","hypo","nano","mega","infra","ultra","trans","micro","macro")
	var/list/particles = list("quark","tachyon","neutron","positron","photon","neutrino","lepton","baryon","atom","molecule")
	var/list/verber = list("stabilizer","synchroniser","generator","coupler","fuser","linker","materializer")

	post_setup(obj/artifact)
		. = ..()
		var/datum/artifact/AD = artifact.artifact
		var/rarityMod = AD.get_rarity_modifier()
		if(!isitem(artifact) && prob(100 * rarityMod))
			var/do_opposite_y = prob(50)
			var/base_pixel_y = rand(-10, 10)
			var/eps = 0.1 * pick(-1, 1)
			var/r = rand(10, 26)
			var/start_dir = pick(-1, 1)
			var/icon_state = "precursorball[rand(1, 6)]"
			var/time = rand(4 SECONDS, 18 SECONDS)
			if(prob(20))
				time = rand(50 SECONDS, 70 SECONDS)
			var/n_balls = rand(1, 4) + round(rarityMod * 3)
			for(var/i = 1 to n_balls)
				var/delay = (i - 1) * time / n_balls
				SPAWN_DBG(delay)
					var/obj/effect/ball = new
					ball.icon = 'icons/obj/artifacts/artifactEffects.dmi'
					ball.icon_state = icon_state
					if(prob(15))
						ball.icon_state = "precursorball[rand(1, 6)]"
					if(prob(10))
						ball.color = list(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1)
					ball.mouse_opacity = 0
					artifact.vis_contents += ball
					if(!do_opposite_y)
						base_pixel_y = rand(-10, 10)
					ball.pixel_y = do_opposite_y ? 0 : base_pixel_y
					ball.layer = artifact.layer + eps
					animate(ball,
						time = time/4,
						easing = SINE_EASING | EASE_OUT,
						pixel_x = r * start_dir,
						pixel_y = base_pixel_y,
						layer = artifact.layer,
						loop = -1)
					animate(
						time = time/4,
						easing = SINE_EASING | EASE_IN,
						pixel_x = 0,
						pixel_y = do_opposite_y ? 0 : base_pixel_y,
						layer = artifact.layer - eps,
						loop = -1)
					animate(
						time = time/4,
						easing = SINE_EASING | EASE_OUT,
						pixel_x = -r * start_dir,
						pixel_y = do_opposite_y ? -base_pixel_y : base_pixel_y,
						layer = artifact.layer,
						loop = -1)
					animate(
						time = time/4,
						easing = SINE_EASING | EASE_IN,
						pixel_x = 0,
						pixel_y = do_opposite_y ? 0 : base_pixel_y,
						layer = artifact.layer + eps,
						loop = -1)


	generate_name()
		var/namestring = ""
		if (prob(40))
			namestring += "[pick(prefixes)]"
		namestring += "[pick(particles)] "
		if (prob(33))
			namestring += "de"
		namestring += "[pick(verber)]"
		return namestring


// TODO: These origins are not ready for general use yet

/*
/datum/artifact_origin/bee
	name = "bee"
	activation_sounds = list('sound/machines/ArtifactBee1.ogg', 'sound/machines/ArtifactBee2.ogg', 'sound/machines/ArtifactBee3.ogg')
	instrument_sounds = list("sound/musical_instruments/artifact/Artifact_Bee_1.ogg",
		"sound/musical_instruments/artifact/Artifact_Bee_2.ogg",
		"sound/musical_instruments/artifact/Artifact_Bee_3.ogg",
		"sound/musical_instruments/artifact/Artifact_Bee_4.ogg")
	max_sprites = 6

/datum/artifact_origin/void
	name = "void"
	activation_sounds = list('sound/machines/ArtifactVoi1.ogg', 'sound/machines/ArtifactVoi2.ogg')
	instrument_sounds = list("sound/musical_instruments/artifact/Artifact_Void_1.ogg",
		"sound/musical_instruments/artifact/Artifact_Void_2.ogg",
		"sound/musical_instruments/artifact/Artifact_Void_3.ogg",
		"sound/musical_instruments/artifact/Artifact_Void_4.ogg")
	max_sprites = 6

/datum/artifact_origin/lattice
	name = "lattice"
	activation_sounds = list('sound/machines/ArtifactLat1.ogg', 'sound/machines/ArtifactLat2.ogg', 'sound/machines/ArtifactLat3.ogg')
	instrument_sounds = list("sound/musical_instruments/artifact/Artifact_Lattice_1.ogg",
		"sound/musical_instruments/artifact/Artifact_Lattice_2.ogg",
		"sound/musical_instruments/artifact/Artifact_Lattice_3.ogg")
	max_sprites = 6

/datum/artifact_origin/feather
	name = "feather"
	activation_sounds = list('sound/machines/ArtifactFea1.ogg', 'sound/machines/ArtifactFea2.ogg', 'sound/machines/ArtifactFea3.ogg')
	instrument_sounds = list("sound/musical_instruments/artifact/Artifact_Feather_1.ogg",
		"sound/musical_instruments/artifact/Artifact_Feather_2.ogg",
		"sound/musical_instruments/artifact/Artifact_Feather_3.ogg")
	max_sprites = 6


*/
