var/datum/artifact_controller/artifact_controls

/datum/artifact_controller
	var/list/artifacts = list()
	var/list/artifact_types = list()
	var/list/artifact_origins = list()
	var/spawner_type = null
	var/spawner_cine = 0

	New()
		..()
		for (var/X in childrentypesof(/datum/artifact) - /datum/artifact/art)
			var/datum/artifact/A = new X
			artifact_types += A

		for (var/X in childrentypesof(/datum/artifact_origin))
			var/datum/artifact_origin/AO = new X
			artifact_origins += AO

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
			spawner_type = input("What type of artifact?","Artifact Controls") as null|anything in list("ancient","martian","wizard","eldritch","precursor","reliquary")//,"bee","void","lattice","feather")

		else if (href_list["Spawncine"])
			spawner_cine = !spawner_cine

		src.config()

// Origins

/datum/artifact_origin
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
			fault_types += childrentypesof(/datum/artifact_fault)

	proc/generate_name()
		return "unknown object"

/datum/artifact_origin/ancient
	name = "ancient"
	fault_types = list(/datum/artifact_fault/burn,/datum/artifact_fault/irradiate,/datum/artifact_fault/shutdown,
	/datum/artifact_fault/murder,/datum/artifact_fault/zap)
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

	generate_name()
		return "unit [pick("alpha","sigma","tau","phi","gamma","epsilon")]-[pick("x","z","d","e","k")] [rand(100,999)]"

/datum/artifact_origin/martian
	name = "martian"
	fault_types = list(/datum/artifact_fault/shutdown,/datum/artifact_fault/zap,/datum/artifact_fault/poison)
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

	generate_name()
		var/namestring = ""
		namestring += "[pick(prefix)]"
		namestring += "[pick(thingy)] "
		namestring += "[pick(action)]"
		return namestring

/datum/artifact_origin/wizard
	name = "wizard"
	fault_types = list(/datum/artifact_fault/irradiate,/datum/artifact_fault/shutdown,/datum/artifact_fault/murder,
	/datum/artifact_fault/warp,/datum/artifact_fault/zap,/datum/artifact_fault/messager/creepy_whispers)
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

	generate_name()
		var/namestring = ""
		namestring += "[pick(material)] "
		namestring += "[pick(object)] of "
		namestring += "[pick(aspect)]"
		return namestring

/datum/artifact_origin/eldritch
	name = "eldritch"
	activation_sounds = list('sound/machines/ArtifactEld1.ogg','sound/machines/ArtifactEld2.ogg')
	instrument_sounds = list("sound/musical_instruments/artifact/Artifact_Eldritch_1.ogg",
		"sound/musical_instruments/artifact/Artifact_Eldritch_2.ogg",
		"sound/musical_instruments/artifact/Artifact_Eldritch_3.ogg",
		"sound/musical_instruments/artifact/Artifact_Eldritch_4.ogg")
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
	name = "precursor"
	activation_sounds = list('sound/machines/ArtifactPre1.ogg')
	instrument_sounds = list("sound/musical_instruments/artifact/Artifact_Precursor_1.ogg",
		"sound/musical_instruments/artifact/Artifact_Precursor_2.ogg",
		"sound/musical_instruments/artifact/Artifact_Precursor_3.ogg",
		"sound/musical_instruments/artifact/Artifact_Precursor_4.ogg",
		"sound/musical_instruments/artifact/Artifact_Precursor_5.ogg",
		"sound/musical_instruments/artifact/Artifact_Precursor_6.ogg")
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


/datum/artifact_origin/reliquary
	name = "reliquary"
	fault_types = list(/datum/artifact_fault/burn,/datum/artifact_fault/irradiate,/datum/artifact_fault/shutdown,
	/datum/artifact_fault/murder,/datum/artifact_fault/zap)
	activation_sounds = list('sound/misc/reliquary/artifact/Rel-artifact-activation.ogg')
	instrument_sounds = list("sound/misc/reliquary/artifact/Rel-artifact-instrument1.ogg",
		"sound/misc/reliquary/artifact/Rel-artifact-instrument2.ogg",
		"sound/misc/reliquary/artifact/Rel-artifact-instrument3.ogg",
		"sound/misc/reliquary/artifact/Rel-artifact-instrument4.ogg",
		"sound/misc/reliquary/artifact/Rel-artifact-instrument5.ogg")
	impact_reaction_one = 1
	impact_reaction_two = 0.5
	heat_reaction_one = 1.5
	max_sprites = 4
	fx_red_min = null
	fx_red_max = null
	fx_green_min = null
	fx_green_max = null
	fx_blue_min = null
	fx_blue_max = null
	nofx = 1
	scramblechance = 0
	adjectives = list("dark","cold","smooth","angular","humming","sharp-edged","droning")
	nouns_large = list("monolith","slab","obelisk","pylon","menhir","machine","structure")
	nouns_small = list("implement","device","instrument","apparatus","appliance","mechanism","tool")
	touch_descriptors = list("It feels cold.","It feels smooth.","Touching it makes you feel uneasy.")
*/
