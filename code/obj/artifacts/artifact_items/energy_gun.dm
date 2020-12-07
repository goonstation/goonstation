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
		src.firemodes = AS.artifact_firemodes
		if (forceartiorigin)
			AS.validtypes = list("[forceartiorigin]")
		src.artifact = AS
		// The other three are normal for energy gun setup, so proceed as usual i guess
		qdel(src.loaded_magazine)
		src.loaded_magazine = null

		SPAWN_DBG(0)
			src.ArtifactSetup()
			var/datum/artifact/A = src.artifact
			src.loaded_magazine = new/obj/item/ammo/power_cell/self_charging/artifact(src,A.artitype)
			src.ArtifactDevelopFault(15)
			src.set_firemode(initialize = TRUE)
			var/batt_mult = 1
			var/proj_cost = 1
			/// Ensures it'll be able to fire at least one full burst of its most expensive projectile
			for(var/datum/firemode/AFM in src.firemodes)
				if(batt_mult < AFM.burst_count)
					batt_mult = AFM.burst_count
				if(proj_cost < AFM.projectile.cost)
					proj_cost = AFM.projectile.cost
			src.loaded_magazine.max_charge = max(src.loaded_magazine.max_charge, proj_cost * batt_mult)


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

	set_firemode(mob/user, var/initialize)
		if(!src.firemodes.len) return
		if(initialize)
			for(var/datum/firemode/F in src.firemodes)
				if(F.gunmaster != src)
					F.gunmaster = src
		var/curr_fm = src.firemode_index
		src.firemode_index = rand(1, src.firemodes.len)
		if(src.firemode_index > round(src.firemodes.len) || src.firemode_index < 1)
			src.firemode_index = 1
		var/datum/firemode/FM = src.firemodes[src.firemode_index]
		if(curr_fm == src.firemode_index)
			FM.switch_to_firemode(user, mode_changed = 0)
		else
			FM.switch_to_firemode(user)
		src.shoot_delay = FM.shoot_delay
		src.burst_count = FM.burst_count
		src.refire_delay = FM.refire_delay
		src.spread_angle = FM.spread_angle
		if(istype(FM.projectile, /datum/projectile))
			src.current_projectile = FM.projectile

	process_ammo(var/mob/user)
		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			if(R.cell)
				if(R.cell.charge >= src.robocharge)
					R.cell.charge -= src.robocharge
					return 1
			return 0
		else
			if(src.current_projectile && src.loaded_magazine && src.loaded_magazine.use(src.current_projectile.cost))
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

		A.ReduceHealth(src)

		src.ArtifactFaultUsed(user)
		return

/datum/artifact/energygun
	associated_object = /obj/item/gun/energy/artifact
	rarity_class = 2
	validtypes = list("ancient","eldritch","precursor")
	react_elec = list(0.02,0,5)
	react_xray = list(10,75,100,11,"CAVITY")
	var/integrity = 100
	var/integrity_loss = 5
	var/list/artifact_firemodes = list()
	examine_hint = "It seems to have a handle you're supposed to hold it by."
	module_research = list("weapons" = 8, "energy" = 8)
	module_research_insight = 3
	New()
		..()
		var/bullet_num = rand(1,3)
		for(var/i in 1 to bullet_num)
			src.artifact_firemodes += new/datum/firemode/artgun
		integrity = rand(50, 100)
		integrity_loss = rand(1, 3) // was rand(1,7)
		react_xray[3] = integrity

	proc/ReduceHealth(var/obj/item/gun/energy/artifact/O)
		var/prev_health = integrity
		integrity -= integrity_loss
		if (integrity <= 20 && prev_health > 20)
			O.visible_message("<span class='alert'>[O] emits a terrible cracking noise.</span>")
		if (integrity <= 0)
			O.visible_message("<span class='alert'>[O] crumbles into nothingness.</span>")
			qdel(O)
		react_xray[3] = integrity
