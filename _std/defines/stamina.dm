#define STAMINA_MAX 200        			//Default max stamina value
#define STAMINA_REGEN 10   	   		 	//Default stamina regeneration rate.
#define STAMINA_ITEM_DMG 20     		//Default stamina damage objects do.
#define STAMINA_ITEM_COST 15    		//Default attack cost on user for attacking with items.
#define STAMINA_HTH_DMG 30      		//Default hand-to-hand (punch, kick) stamina damage.
#define STAMINA_HTH_COST 15     		//Default hand-to-hand (punch, kick) stamina cost
#define STAMINA_MIN_ATTACK 50   		//The minimum amount of stamina required to attack.
#define STAMINA_NEG_CAP -75     		//How far into the negative we can take stamina. (People will be stunned while stamina regens up to > 0 - so this can lead to long stuns if set too high)
#define STAMINA_NEG_CAP_STUN_TIME 60   	//When we reach the neg cap, how long to paralyze?
#define STAMINA_STUN_TIME 5     		//How long we will be stunned for, for being <= 0 stamina
#define STAMINA_STUN_CRIT_TIME 8  		//How long we will be stunned for, for being <= NEGCAP stamina
#define STAMINA_GRAB_COST 25    		//How much grabbing someone costs.
#define STAMINA_DISARM_COST 5   		//How much disarming someone costs.
#define STAMINA_DISARM_DMG 19			//Stamina damage of disarming someone with bare hands.
#define STAMINA_FLIP_COST 25    		//How much flipping / suplexing costs.
#define STAMINA_CRIT_CHANCE 25  		//Base chance of landing a critical hit to stamina.
#define STAMINA_CRIT_DIVISOR 2  		//Divide stamina by how much on a crit
#define STAMINA_BLOCK_CHANCE 40 		//Chance to block an attack in disarm mode. Settings this to 0 effectively disables the blocking system.
#define STAMINA_GRAB_BLOCK_CHANCE 85    //Chance to block grabs.
#define STAMINA_DEFAULT_BLOCK_COST 5    //Cost of blocking an attack.
#define STAMINA_LOW_COST_KICK 1 	    //Does kicking people on the ground cost less stamina ? (Right now it doesnt cost less but rather refunds some because kicking people on the ground is very relaxing OKAY)
#define STAMINA_NO_ATTACK_CAP 1 		//Attacks only cost stamina up to the min atttack cap. after that they are free
#define STAMINA_NEG_CRIT_KNOCKOUT 0     //Getting crit below or at 0 stamina will always knock out
#define STAMINA_WINDED_SPEAK_MIN 0      //Can't speak below this point.
#define STAMINA_SPRINT 64				//can only sprint above this number
#define STAMINA_COST_SPRINT 7			//cost of moving in sprint
#define SUSTAINED_RUN_GRACE 0.5 SECONDS	//grace period where sustained run can be sustained
#define SUSTAINED_RUN_REQ 8				//how many tiles to start sustained run

//This is a bad solution. Optimally this should scale.
#define STAMINA_MIN_WEIGHT_CLASS 0 	    //Minimum weightclass (w_class) of an item that allows for knock-outs and critical hits.

//This is the last resort option for the RNG lovers.
#define STAMINA_STUN_ON_CRIT 0          //Getting crit stuns the affected person for a short moment?
#define STAMINA_STUN_ON_CRIT_SEV 2      //How long people get stunned on crits

#define STAMINA_CRIT_DROP 0	    	    //If 1, stamina crits will instantly set a targets stamina to the number set below instead of doing a multiplier.
#define STAMINA_CRIT_DROP_NUM 1			//Amount of stamina to drop to on a crit.

#define STAMINA_SCALING_KNOCKOUT_BASE 20   //Base chance at 0 stamina to be knocked out by an attack - scales up the lower stamina goes.
#define STAMINA_SCALING_KNOCKOUT_SCALER 60 //Up to which *additional* value the chance will scale with lower stamina nearly the negative cap

#define STAMINA_EXHAUSTED_STR "<p style=\"color:red;font-weight:bold;\">You are too exhausted to attack.</p>" //The message tired people get when they try to attack.

#define STAMINA_DEFAULT_FART_COST 0  //How much farting costs. I am not even kidding.

#define USE_STAMINA_DISORIENT //use the new stamina based stun disorient system thingy
