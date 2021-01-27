/// Weapon Sounds
/datum/gun_sounds
	var/name = "gunsound parent"
	/// Sound to play when loading one bullet thing into the gun
	var/soundLoadSingle
	var/soundLoadSingleVolume = 100
	/// Sound to play when loading multiple bullet things into the gun at once
	var/soundLoadMultiple
	var/soundLoadMultipleVolume = 100
	/// Sound to play when loading a magazine / battery into the gun
	var/soundLoadMagazine
	var/soundLoadMagazineVolume = 100

	/// Sound to play when unloading one bullet thing from the gun
	var/soundUnloadSingle
	var/soundUnloadSingleVolume = 100
	/// Sound to play when unloading multiple bullet things from the gun at once
	var/soundUnloadMultiple
	var/soundUnloadMultipleVolume = 100
	/// Sound to play when unloading a magazine / battery from the gun
	var/soundUnloadMagazine
	var/soundUnloadMagazineVolume = 100

/datum/shoot_sounds
	/// Can be left null if the intended projectile has its own sound. Which is to say, most projectiles.
	var/soundShoot
	var/soundShootVolume = 100
	var/soundShootSilent
	var/soundShootSilentVolume = 100
	var/soundShootEmpty
	var/soundShootEmptyVolume = 100

/datum/gun_sounds/test
	name = "gunsound parent"
	soundLoadSingle = "sound/weapons/gun_cocked_colt45.ogg"
	soundLoadSingleVolume = 100
	soundLoadMultiple = "sound/musical_instruments/Airhorn_1.ogg"
	soundLoadMultipleVolume = 100
	soundLoadMagazine = "sound/impact_sounds/Energy_Hit_1.ogg"
	soundLoadMagazineVolume = 100

	soundUnloadSingle = "sound/musical_instruments/Bikehorn_1.ogg"
	soundUnloadSingleVolume = 100
	soundUnloadMultiple = "sound/ambience/industrial/AncientPowerPlant_Drone3.ogg"
	soundUnloadMultipleVolume = 100
	soundUnloadMagazine = "sound/impact_sounds/Slimy_Splat_1.ogg"
	soundUnloadMagazineVolume = 100

/datum/shoot_sounds/test
	soundShoot = "sound/voice/animal/werewolf_howl.ogg"
	soundShootVolume = 100
	soundShootSilent = "sound/voice/farts/superfart.ogg"
	soundShootSilentVolume = 100
	soundShootEmpty = "sound/weapons/lasermed.ogg"
	soundShootEmptyVolume = 100

/datum/shoot_sounds/test2
	soundShoot = "sound/voice/farts/superfart.ogg"
	soundShootVolume = 100
	soundShootSilent = "sound/voice/animal/werewolf_howl.ogg"
	soundShootSilentVolume = 100
	soundShootEmpty = "sound/weapons/lasermed.ogg"
	soundShootEmptyVolume = 100
