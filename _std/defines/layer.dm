#define PLATING_LAYER     (TURF_LAYER-0.2)
#define BETWEEN_FLOORS_LAYER     (TURF_LAYER-0.1)
#define LATTICE_LAYER 		(TURF_LAYER+0.1)
#define DISPOSAL_PIPE_LAYER (TURF_LAYER+0.11)
#define PIPE_LAYER 			(TURF_LAYER+0.12) // MR MARIO HE WAS A PIPE LAYER
#define FLUID_PIPE_LAYER	(TURF_LAYER+0.125)
#define CATWALK_LAYER 		(TURF_LAYER+0.13)
#define CABLE_LAYER 		(TURF_LAYER+0.14)
#define PIPE_MACHINE_LAYER (TURF_LAYER+0.15)
#define DECAL_LAYER 		(TURF_LAYER+0.2)
#define FLUID_LAYER 		(TURF_LAYER+0.25)
#define FLUID_AIR_LAYER 	(TURF_LAYER+0.26)
#define FLOOR_EQUIP_LAYER1 	(TURF_LAYER+0.3)
#define FLOOR_EQUIP_LAYER2 	(TURF_LAYER+0.31)
#define AI_RAIL_LAYER 		(TURF_LAYER+0.4)
#define TURF_EFFECTS_LAYER 	(TURF_LAYER+0.8)
#define GRILLE_LAYER 		(TURF_LAYER+0.9)
#define COG2_WINDOW_LAYER 	(TURF_LAYER+0.95)

// More specific obj layers
#define SUB_TAG_LAYER		(OBJ_LAYER - 0.03) //! Graffiti that's been sprayed over sits here
#define TAG_LAYER			(OBJ_LAYER - 0.02) //! Graffiti layer for gangs, this is the topmost (ie. most recent) tag on a turf
#define STORAGE_LAYER		(OBJ_LAYER - 0.01) // Keep lockers etc below items
#define ABOVE_OBJ_LAYER 	(OBJ_LAYER + 0.01) // For objects that should generally layer above other objects

// Mob clothing and effect layers
#define MOB_LAYER_BASE 		4
#define MOB_OVERLAY_BASE	FLOAT_LAYER
#define MOB_LAYER_OVER_FUCKING_EVERYTHING_LAYER (MOB_OVERLAY_BASE - 0.1) ///! Boxes
#define MOB_OVER_TOP_LAYER 	(MOB_OVERLAY_BASE - 0.2)	///! For things which are draped over the top of all other clothing
#define MOB_BACK_SUIT_LAYER (MOB_OVERLAY_BASE - 0.3)	///! For capes and scarves and stuff. Technically on back, but we want to layer over almost everything else
#define MOB_FULL_SUIT_LAYER	 (MOB_OVERLAY_BASE - 0.4) 	///! For things which fully cover the body, but are still normal-ish clothes (cult robes, mechanicus robe)
#define MOB_EFFECT_LAYER 	(MOB_OVERLAY_BASE-1)	// FLOAT_LAYER
#define MOB_HANDCUFF_LAYER 	(MOB_OVERLAY_BASE-2)
#define MOB_INHAND_LAYER 	(MOB_OVERLAY_BASE-3)
#define MOB_HEAD_LAYER2		(MOB_OVERLAY_BASE-4) // helmets
#define MOB_OVERMASK_LAYER (MOB_OVERLAY_BASE-4.8) // for mutant details that go over masks
#define MOB_HEAD_LAYER1		(MOB_OVERLAY_BASE-5) // masks
#define MOB_EARS_LAYER		(MOB_OVERLAY_BASE-5.5)
#define MOB_GLASSES_LAYER2 (MOB_OVERLAY_BASE-5.9) // For eyewear that should layer OVER hair
#define MOB_HAIR_LAYER2 	(MOB_OVERLAY_BASE-6)
#define MOB_GLASSES_LAYER	(MOB_OVERLAY_BASE-7)  // For eyewear that should layer UNDER hair
#define MOB_BACK_LAYER 		(MOB_OVERLAY_BASE-8)
#define MOB_OVERSUIT_LAYER1 (MOB_OVERLAY_BASE-8.6)	// For mutant oversuit (de)tails when facing north
#define MOB_OVERSUIT_LAYER2 (MOB_OVERLAY_BASE-8.7)	// If we have another one
#define MOB_SHEATH_LAYER 	(MOB_OVERLAY_BASE-8.8)
#define MOB_BACK_LAYER_SATCHEL  (MOB_OVERLAY_BASE-8.9)  // For satchels so they don't show over a tail or something
#define MOB_ARMOR_LAYER 	(MOB_OVERLAY_BASE-9)
#define MOB_HAND_LAYER2 	(MOB_OVERLAY_BASE-10) 	// gloves
#define MOB_HAND_LAYER1 	(MOB_OVERLAY_BASE-11)
#define MOB_BELT_LAYER 		(MOB_OVERLAY_BASE-12) 	// bit missleading name, used for more than just belts
#define MOB_HAIR_LAYER1		(MOB_OVERLAY_BASE-13)
#define MOB_FACE_LAYER 		(MOB_OVERLAY_BASE-14)
#define MOB_CLOTHING_LAYER 	(MOB_OVERLAY_BASE-15)
#define MOB_UNDERWEAR_LAYER (MOB_OVERLAY_BASE-16)
#define MOB_DAMAGE_LAYER 	(MOB_OVERLAY_BASE-17)
#define MOB_BODYDETAIL_LAYER3 	(MOB_OVERLAY_BASE-18)
#define MOB_BODYDETAIL_LAYER2 	(MOB_OVERLAY_BASE-19)	// Used for limb overlays. you can use it for other things too, I won't stop you
#define MOB_BODYDETAIL_LAYER1 	(MOB_OVERLAY_BASE-20) // Mostly just for torso stuff
#define MOB_LIMB_LAYER 		(MOB_OVERLAY_BASE-21)
#define MOB_TAIL_LAYER2 		(MOB_OVERLAY_BASE-23) // Tail detail
#define MOB_TAIL_LAYER1 		(MOB_OVERLAY_BASE-24) // Tail base

// Some effects were defined on layer 10, some on layer 20... Lets unify this...
// These are for effects that should display below lighting
#define EFFECTS_LAYER_BASE 30
#define EFFECTS_LAYER_1 (EFFECTS_LAYER_BASE+1)
#define EFFECTS_LAYER_2 (EFFECTS_LAYER_BASE+2)
#define EFFECTS_LAYER_3 (EFFECTS_LAYER_BASE+3)
#define EFFECTS_LAYER_4 (EFFECTS_LAYER_BASE+4)

// Use this for shit that should appear above everything else but under actual effects
#define EFFECTS_LAYER_UNDER_1 (EFFECTS_LAYER_BASE-1)
#define EFFECTS_LAYER_UNDER_2 (EFFECTS_LAYER_BASE-2)
#define EFFECTS_LAYER_UNDER_3 (EFFECTS_LAYER_BASE-3)
#define EFFECTS_LAYER_UNDER_4 (EFFECTS_LAYER_BASE-4)

// Overlay effects layers - Formerly layer 11 -- primarily for lighting.
#define OVERLAY_EFFECT_LAYER_BASE 40
#define TILE_EFFECT_OVERLAY_LAYER (OVERLAY_EFFECT_LAYER_BASE+1)
#define TILE_EFFECT_OVERLAY_LAYER_LIGHTING OVERLAY_EFFECT_LAYER_BASE

// Effects that should display above the lighting overlays
#define NOLIGHT_EFFECTS_LAYER_BASE 50
#define NOLIGHT_EFFECTS_LAYER_1 (NOLIGHT_EFFECTS_LAYER_BASE+1)
#define NOLIGHT_EFFECTS_LAYER_2 (NOLIGHT_EFFECTS_LAYER_BASE+2)
#define NOLIGHT_EFFECTS_LAYER_3 (NOLIGHT_EFFECTS_LAYER_BASE+3)
#define NOLIGHT_EFFECTS_LAYER_4 (NOLIGHT_EFFECTS_LAYER_BASE+4)

// HUD Layers - Formerly layer 20
#define HUD_LAYER_BASE 60
#define HUD_LAYER HUD_LAYER_BASE
#define HUD_LAYER_1 (HUD_LAYER+1)
#define HUD_LAYER_2 (HUD_LAYER+2)
#define HUD_LAYER_3 (HUD_LAYER+3)
#define HUD_LAYER_UNDER_1 (HUD_LAYER-1)
#define HUD_LAYER_UNDER_2 (HUD_LAYER-2)
#define HUD_LAYER_UNDER_3 (HUD_LAYER-3)
#define HUD_LAYER_UNDER_4 (HUD_LAYER-4)

#define LIGHTING_LAYER_ROBUST 0
#define LIGHTING_LAYER_BASE 1
#define LIGHTING_LAYER_FULLBRIGHT 2
#define LIGHTING_LAYER_DARKNESS_EFFECTS 3

// Mining asteroid Layers
#define ASTEROID_LAYER TURF_LAYER
#define ASTEROID_TOP_OVERLAY_LAYER (TURF_LAYER+0.01)
#define ASTEROID_ORE_OVERLAY_LAYER (TURF_LAYER+0.02)
#define ASTEROID_MINING_SCAN_DECAL_LAYER (TURF_LAYER+0.03)
