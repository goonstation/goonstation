
// CONSTRUCTION ABILITIES

/datum/blob_ability/build
	var/gen_rate_invest = 0
	var/build_path = /obj/blob
	cooldown_time = 100
	var/buildname = "build"

	onUse(var/turf/T)
		if (..())
			return 1
		if (!T)
			T = get_turf(owner)

		var/obj/blob/B = T.get_blob_on_this_turf()

		if (!B)
			boutput(owner, SPAN_ALERT("There is no blob there to convert."))
			return 1

		if (gen_rate_invest > 0)
			if (owner.get_gen_rate() < gen_rate_invest + 1)
				boutput(owner, SPAN_ALERT("You do not have a high enough generation rate to use that ability."))
				boutput(owner, SPAN_ALERT("Keep in mind that you cannot reduce your generation rate to zero or below."))
				return 1

		if (B.type != /obj/blob)
			boutput(owner, SPAN_ALERT("You cannot convert special blob cells."))
			return 1

		if (!tutorial_check(buildname, T))
			return 1

		var/obj/blob/L = new build_path(T)
		logTheThing(LOG_STATION, owner, "builds [L] at [T] ([log_loc(T)])")
		L.setOvermind(owner)
		L.setMaterial(B.material)
		B.material = null
		qdel(B)
		if (gen_rate_invest)
			owner.gen_rate_used++
		src.deduct_bio_points()
		src.do_cooldown()
		owner.playsound_local(owner.loc, "sound/voice/blob/blobplace[rand(1, 6)].ogg", 75, 1)

/datum/blob_ability/build/lipid
	name = "Build Lipid Cell"
	icon_state = "blob-lipid"
	desc = "This will convert a blob tile into a Lipid. Lipids act as a storage for 4 biopoints. When you try to spend more than your available biopoints, you will use up lipids to substitute for the missing points. If a lipid is destroyed, the stored points are lost."
	bio_point_cost = 5
	build_path = /obj/blob/lipid
	buildname = "lipid"

/datum/blob_ability/build/ribosome
	name = "Build Ribosome Cell"
	icon_state = "blob-ribosome"
	desc = "This will convert a blob tile into a Ribosome. Ribosomes increase your generation of biopoints, allowing you to do more things."
	bio_point_cost = 15
	build_path = /obj/blob/ribosome
	buildname = "ribosome"

/datum/blob_ability/build/mitochondria
	name = "Build Mitochondria Cell"
	icon_state = "blob-mitochondria"
	desc = "This will convert a blob tile into a Mitochondrion. Mitochondria heal nearby blob cells."
	bio_point_cost = 5
	build_path = /obj/blob/mitochondria
	buildname = "mitochondria"

/datum/blob_ability/build/plasmaphyll
	name = "Build Plasmaphyll Cell"
	icon_state = "blob-plasmaphyll"
	desc = "This will convert a blob tile into a Plasmaphyll. Plasmaphylls protect nearby blob pieces from sustained fires by absorbing plasma out of the air and converting it into biopoints."
	bio_point_cost = 15
	gen_rate_invest = 1
	build_path = /obj/blob/plasmaphyll
	buildname = "plasmaphyll"

/datum/blob_ability/build/ectothermid
	name = "Build Ectothermid Cell"
	icon_state = "blob-ectothermid"
	desc = "This will convert a blob tile into an Ectothermid. Ectothermids provice heat protection in an area at the cost of for biopoints."
	bio_point_cost = 15
	gen_rate_invest = 1
	build_path = /obj/blob/ectothermid
	buildname = "ectothermid"

/datum/blob_ability/build/reflective
	name = "Build Reflective Membrane Cell"
	icon_state = "blob-reflective"
	desc = "This will convert a blob tile into a reflective membrane. Reflective membranes are reflect energy projectiles back in the direction they were shot from."
	bio_point_cost = 8
	build_path = /obj/blob/reflective
	buildname = "reflective"

/datum/blob_ability/build/launcher
	name = "Build Slime Launcher"
	icon_state = "blob-cannon"
	desc = "This will convert a blob tile into a slime launcher. Slime launchers will fire weak projectiles at nearby humans and cyborgs at the cost of 2 biopoints. Click-drag any reagent deposit onto a slime launcher to load the reagents into the launcher. When loaded with reagents, the slime bullets are also infused with the reagents and while the reservoir lasts, firing the launcher does not cost biopoints."
	bio_point_cost = 10
	build_path = /obj/blob/launcher
	buildname = "launcher"

/datum/blob_ability/build/wall
	name = "Build Thick Membrane Cell"
	icon_state = "blob-wall"
	desc = "This will convert a blob tile into a wall. Wall cells are harder to destroy."
	bio_point_cost = 5
	build_path = /obj/blob/wall
	buildname = "wall"

/datum/blob_ability/build/firewall
	name = "Build Fire-resistant Membrane Cell"
	icon_state = "blob-firewall"
	desc = "This will convert a blob tile into a fire-resistant wall. Fire resistant walls are very resistant to fire damage."
	bio_point_cost = 5
	build_path = /obj/blob/firewall
	buildname = "firewall"
