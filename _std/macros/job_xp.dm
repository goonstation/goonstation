
/// Hard CAP on XP earned per round, used to prevent exploiting.
#define XP_ROUND_CAP 6000
/// Global multiplier for xp earned. normalXP * XP_GLOBAL_MOD. For events or adjustments.
#define XP_GLOBAL_MOD 1
/// Constant for scaling the XP curve.
#define XP_CONSTANT 0.2
/// Returns XP required for the given level.
#define XP_FOR_LEVEL(LV) (((LV/XP_CONSTANT)**2))
/// Returns the level for the given amount of XP. Recommend rounding it down.
#define LEVEL_FOR_XP(XP) (XP_CONSTANT * sqrt(XP))

/// Defines the range of time that is throttled, see below. Currently very roughly one minute "game time".
#define XP_THROTTLE_TICKS 600

/**
	* This much XP is allowed per XP_THROTTLE_TICKS. Should prevent people from exploiting certain things.
	* This cap is ignored if a person if awarded XP in excess of this cap in one burst.
	*
	* Roughly 2 times the expected XP per minute, currently.
	*/
#define XP_THROTTLE_AMT 10

/**
	* Gives USR in the current context XP amount if they have the appropriate job.
	*
	* `USR_JOB_XP("Clown", 5)` would give usr 5xp if they are a clown.
	*/
#define USR_JOB_XP(JOB, XP) if(usr.job == JOB && usr.key) award_xp(usr.key, JOB, XP)

/**
	* Gives TRG, XP amount if they have the appropriate job.
	*
	* `JOB_XP(someMobHere, "Clown", 5)` would give someMobHere 5xp if they are a clown.
	*/
#define JOB_XP(TRG, JOB, XP) if(ismob(TRG) && TRG:job == JOB && TRG:key) award_xp_and_archive(TRG:key, JOB, XP)

//0.2, 25, 100, 225, 400, 625 ... 7=1225,10=2500,20=10000,30=22500,50=62500,100=250000
//Say a round lasts 60 minutes. Level 5 should take 2 hours. ??
//TOTAL TIME SPENT FOR LEVELS WITH CONSTANT 0.2, LV5@2hours, 5.2XP per min:
//625XP/120m,5.2XP-min.lv5=2 hours, lv7=3.9 hours, lv10=8 hours, lv20=32.05 hours, lv30=72,1 hours, lv50=200 hours, lv100=801 hours/33 days
