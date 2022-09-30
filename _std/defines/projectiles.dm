
//pass flags
#define PROJ_PASSWALL			(1<<1)
#define PROJ_PASSOBJ			(1<<2)

//pass flags on hit thing take priotity if they exist
#define PROJ_ATOM_PASSTHROUGH	(1<<4)
#define PROJ_ATOM_CANNOT_PASS	(1<<5)
#define PROJ_OBJ_HIT_OTHER_OBJS	(1<<6)




//Projectile damage type defines
#define D_KINETIC				(1<<0)
#define D_PIERCING				(1<<1)
#define D_SLASHING				(1<<2)
#define D_ENERGY				(1<<3)
#define D_BURNING				(1<<4)
#define D_RADIOACTIVE			(1<<5)
#define D_TOXIC					(1<<6)
#define D_SPECIAL				(1<<7)

//Projectile reflection defines
#define PROJ_NO_HEADON_BOUNCE 1
#define PROJ_HEADON_BOUNCE 2
#define PROJ_RAPID_HEADON_BOUNCE 3

//default max range for 'unlimited' range projectiles
#define PROJ_INFINITE_RANGE 500



//ammo categories

#define AMMO_SHOTGUN_LOW "shotgun_low"
#define AMMO_SHOTGUN_HIGH "shotgun_high"
#define AMMO_SHOTGUN_ALL AMMO_SHOTGUN_LOW, AMMO_SHOTGUN_HIGH


#define AMMO_REVOLVER_SYNDICATE "revolver_syndicate"
#define AMMO_REVOLVER_DETECTIVE "revolver_detective"
#define AMMO_REVOLVER_45 "revolver_45"
#define AMMO_REVOLVER_ALL AMMO_REVOLVER_SYNDICATE, AMMO_REVOLVER_DETECTIVE, AMMO_REVOLVER_45

#define AMMO_PISTOL_22 "pistol_22"
#define AMMO_PISTOL_9MM "pistol_9mm"
#define AMMO_PISTOL_9MM_SOVIET "pistol_9mm_soviet"
#define AMMO_PISTOL_9MM_ALL AMMO_PISTOL_9MM, AMMO_PISTOL_9MM_SOVIET
#define AMMO_PISTOL_41 "pistol_41"
#define AMMO_PISTOL_ALL AMMO_PISTOL_22, AMMO_PISTOL_9MM_ALL, AMMO_PISTOL_41

#define AMMO_TRANQ_9MM "tranq_9mm"
#define AMMO_TRANQ_308 "tranq_308"
#define AMMO_TRANQ_ALL AMMO_TRANQ_9MM, AMMO_TRANQ_308


#define AMMO_RIFLE_308 "rifle_308"
#define AMMO_AUTO_308 "auto_308"

#define AMMO_AUTO_556 "auto_5.56mm"
#define AMMO_AUTO_762 "auto_7.62mm" //7.62x39, not fullsize like 308
#define AMMO_SMG_9MM "auto_9mm"

#define AMMO_9MM_ALL AMMO_SMG_9MM, AMMO_PISTOL_9MM_ALL, AMMO_TRANQ_9MM

#define AMMO_CANNON_40MM "grenade_40mm"
#define AMMO_GRENADE_40MM "grenade_custom"
#define AMMO_GRENADE_ALL AMMO_CANNON_40MM, AMMO_GRENADE_40MM

#define AMMO_ROCKET_SING "rocket_sing"
#define AMMO_ROCKET_RPG "rocket_rpg"
#define AMMO_ROCKET_MRL "rocket_mrl"
#define AMMO_ROCKET_ALL AMMO_ROCKET_SING, AMMO_ROCKET_RPG, AMMO_ROCKET_MRL

#define AMMO_FOAMDART "foamdart"
#define AMMO_AIRZOOKA "airzooka"

#define AMMO_CANNON_20MM "cannon_20mm"
#define AMMO_CASELESS_G11 "caseless_g11"
#define AMMO_DEAGLE "deagle"
#define AMMO_GYROJET "gyrojet"
#define AMMO_FLECHETTE "flechette"
#define AMMO_BLOWDART "blowdart"

#define AMMO_DART_ALL AMMO_FOAMDART,AMMO_BLOWDART

#define AMMO_BEEPSKY "spawner_beepsky"
#define AMMO_DERRINGER_LITERAL "spawner_derringer"
#define AMMO_HOWITZER "howitzer"
#define AMMO_FLINTLOCK "flintlock"
#define AMMO_COILGUN "coilgun"
