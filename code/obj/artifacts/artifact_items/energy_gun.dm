/obj/item/gun/energy/artifact
	// an energy gun, it shoots things as you might expect
	name = "artifact energy gun"
	icon = 'icons/obj/artifacts/artifactsitem.dmi'
	icon_state = "laser"
	force = 5.0
	artifact = 1
	is_syndicate = 1
	module_research_no_diminish = 1
	mat_changename = 0
	mat_changedesc = 0

	New(var/loc, var/forceartiorigin)
		..()
		var/datum/artifact/energygun/AS = new /datum/artifact/energygun(src)
		if (forceartiorigin)
			AS.validtypes = list("[forceartiorigin]")
		src.artifact = AS
		// The other three are normal for energy gun setup, so proceed as usual i guess
		qdel(cell)
		cell = null

		SPAWN_DBG(0)
			src.ArtifactSetup()
			var/datum/artifact/A = src.artifact
			cell = new/obj/item/ammo/power_cell/self_charging/artifact(src,A.artitype)
			src.ArtifactDevelopFault(15)

			set_current_projectile(AS.bullet)
			projectiles = list(src.current_projectile)
			cell.max_charge = max(cell.max_charge, current_projectile.cost)

		src.setItemSpecial(null)

	examine()
		. = list("You have no idea what this thing is!")
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/A = src.artifact
		if (istext(A.examine_hint))
			. += A.examine_hint

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	attackby(obj/item/W as obj, mob/user as mob)
		if (src.Artifact_attackby(W,user))
			..()

	process_ammo(var/mob/user)
		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			if(R.cell)
				if(R.cell.charge >= src.robocharge)
					R.cell.charge -= src.robocharge
					return 1
			return 0
		else
			if(src.current_projectile)
				if(src.cell)
					if(src.cell.use(src.current_projectile.cost))
						return 1
			return 0

	shoot(var/target,var/start,var/mob/user)
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/energygun/A = src.artifact

		if (!istype(A))
			return

		if (!A.activated)
			return

		..()

		if(prob(5))
			src.ArtifactTakeDamage(rand(5,30))

		O.visible_message("<span class='alert'>[O] emits a terrible cracking noise.</span>")

		src.ArtifactFaultUsed(user)
		return

	ArtifactDestroyed()
		var/turf/T = get_turf(src)
		if(T)
			cell.set_loc(T)
		. = ..()


/datum/artifact/energygun
	associated_object = /obj/item/gun/energy/artifact
	rarity_weight = 350
	validtypes = list("ancient","eldritch","precursor")
	react_elec = list(0.02,0,5)
	react_xray = list(10,75,100,11,"CAVITY")
	var/datum/projectile/artifact/bullet = null
	examine_hint = "It seems to have a handle you're supposed to hold it by."
	module_research = list("weapons" = 8, "energy" = 8)
	module_research_insight = 3

	New()
		..()
		bullet = new/datum/projectile/artifact
		bullet.randomise()
		// artifact tweak buff, people said guns were useless compared to their cells
		// the next 3 lines override the randomize(). Doing this instead of editing randomize to avoid changing prismatic spray.
		bullet.power = rand(15,35) // randomise puts it between 2 and 50, let's make it less variable
		bullet.dissipation_rate = rand(1,bullet.power)
		bullet.cost = rand(35,100) // randomise puts it at 50-150

