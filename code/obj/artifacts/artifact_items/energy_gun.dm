/obj/item/gun/energy/artifact
	// an energy gun, it shoots things as you might expect
	name = "artifact energy gun"
	icon = 'icons/obj/artifacts/artifactsitem.dmi'
	icon_state = "laser"
	force = 5
	artifact = 1
	is_syndicate = 1
	mat_changename = 0
	mat_changedesc = 0

	New(var/loc, var/forceartiorigin, var/list/datum/projectile/artifact/forceBullets)
		..()
		var/datum/artifact/energygun/AS = new /datum/artifact/energygun(src)
		if (forceartiorigin)
			AS.validtypes = list("[forceartiorigin]")
		src.artifact = AS
		// The other three are normal for energy gun setup, so proceed as usual i guess

		SPAWN(0)
			src.ArtifactSetup()
			var/datum/artifact/A = src.artifact


			if(forceBullets)
				for(var/datum/projectile/artifact/forceBullet as anything in forceBullets)
					forceBullet.turretArt = null // not making this trigger faults on people who are shot, to prevent guns from feeling too unfair
				AS.bullets = forceBullets
			set_current_projectile(pick(AS.bullets))
			projectiles = AS.bullets
			AddComponent(/datum/component/cell_holder, new/obj/item/ammo/power_cell/self_charging/artifact(src,A.artitype,current_projectile.cost), swappable = FALSE)

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

	attackby(obj/item/W, mob/user)
		if (src.Artifact_attackby(W,user))
			..()

	reagent_act(reagent_id,volume)
		if (..())
			return
		src.Artifact_reagent_act(reagent_id, volume)
		return

	emp_act()
		src.Artifact_emp_act()
		..()

	shoot(var/target,var/start,var/mob/user)
		if (!src.ArtifactSanityCheck())
			return
		var/datum/artifact/energygun/A = src.artifact

		if (!istype(A))
			return

		if (!A.activated)
			return

		. = ..()

		if(!.) // do not trigger fault or damage if we don't shoot
			return

		src.ArtifactFaultUsed(user)

		if(prob(20))
			src.ArtifactDevelopFault(100)
			user.visible_message("<span class='alert'>[src] emits \a [pick("ominous", "portentous", "sinister")] sound.</span>")
		else if(prob(20))
			src.ArtifactTakeDamage(20)
			user.visible_message("<span class='alert'>[src] emits a terrible cracking noise.</span>")

		return

	ArtifactDestroyed()
		SEND_SIGNAL(src, COMSIG_CELL_SWAP, null, null) //swap cell with nothing (drop cell on flooor)
		. = ..()

	ArtifactActivated()
		. = ..()
		AddComponent(/datum/component/cell_holder, swappable = TRUE)

	ArtifactDeactivated()
		. = ..()
		AddComponent(/datum/component/cell_holder, swappable = FALSE)

/datum/artifact/energygun
	associated_object = /obj/item/gun/energy/artifact
	type_name = "Energy Gun"
	type_size = ARTIFACT_SIZE_MEDIUM
	rarity_weight = 350
	validtypes = list("ancient","eldritch","precursor")
	react_elec = list(0.02,0,5)
	react_xray = list(10,75,100,11,"CAVITY")
	var/list/datum/projectile/artifact/bullets = list()
	examine_hint = "It seems to have a handle you're supposed to hold it by."

	New()
		..()
		var/datum/projectile/artifact/bullet = null
		var/mode_amount = pick(7;1, 2;2, 1;3) // 70% 1 mode, 20% 2 modes, 10% 3 modes

		for(var/i = 1 to mode_amount)
			bullet = new/datum/projectile/artifact
			bullet.randomise()
			// artifact tweak buff, people said guns were useless compared to their cells
			// the next 3 lines override the randomize(). Doing this instead of editing randomize to avoid changing prismatic spray.
			bullet.power = rand(15,35) // randomise puts it between 2 and 50, let's make it less variable
			bullet.generate_inverse_stats()
			bullet.dissipation_rate = rand(1,bullet.power)
			bullet.cost = rand(35,100) // randomise puts it at 50-150
			bullets += bullet
