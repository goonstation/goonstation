#define AI_SKIN(state) icon='icons/mob/ai.dmi'; icon_state=state; aiskin=state;
ABSTRACT_TYPE(/datum/achievementReward/aicase)
/datum/achievementReward/aicase
	var/aiskin = "default"

	rewardActivate(mob/activator)
		if (isAI(activator))
			var/mob/living/silicon/ai/A = activator
			if (isAIeye(activator))
				var/mob/living/intangible/aieye/AE = activator
				A = AE.mainframe
			A.coreSkin = aiskin
			A.update_appearance()
			return 1
		else
			boutput(activator, SPAN_ALERT("You need to be an AI to use this, you goof!"))

/datum/achievementReward/aicase/bee
	title = "(AI Core Skin) Bee"
	desc = "Buzz Buzz!"
	required_medal = "Bombini is Missing!"
	AI_SKIN("bee")

/datum/achievementReward/aicase/ai_ailes
	title = "(AI Core Skin) Bulky"
	desc = "Replaces your core with a bulky older model."
	required_medal = "I'm in"
	AI_SKIN("ailes")

datum/achievementReward/aicase/ai_crt
	title = "(AI Core Skin) CRT Television"
	desc = "Replaces the casing of your core with a CRT television."
	required_medal = "I Spy"
	AI_SKIN("crt")

datum/achievementReward/aicase/ai_dwaine
	title = "(AI Core Skin) DWAINE"
	desc = "Replaces the casing of your core with an older model!"
	required_medal = "421"
	AI_SKIN("dwaine")

/datum/achievementReward/aicase/ai_gold
	title = "(AI Core Skin) Golden"
	desc = "Gold plates your AI core!"
	required_medal = "Helios"
	AI_SKIN("gold")

datum/achievementReward/aicase/ai_industrial
	title = "(AI Core Skin) Industrial"
	desc = "Reinforces your AI core with a shiny reinforced alloy straight from mining-- purely superficially, of course."
	required_medal = "This object menaces with spikes of..."
	AI_SKIN("industrial")

/*/datum/achievementReward/aicase/ai_kingsway
	title = "(AI Core Skin) Kingsway"
	desc = "Replaces your AI core with a fancy new model."
	required_medal = PLEEEASE someone make a kingsway associated medal something for playing all three obtainable brad tapes in the same round or something
	AI_SKIN("kingsway")*/

datum/achievementReward/aicase/ai_salvage
	title = "(AI Core Skin) Salvaged"
	desc = "Superficially smashes up your AI core a bit - for that really RUGGED aesthetic."
	required_medal = "40K" //placeholder until salvagers get a greentext medal - ideally also have the core frame in the magpie use this skin
	AI_SKIN("salvage")

/datum/achievementReward/aicase/ai_shock
	title = "(AI Core Skin) Shock"
	desc = "Fancies your AI core up to look very neon."
	required_medal = "Virtual Ascension"
	AI_SKIN("shock")

/datum/achievementReward/aicase/ai_soviet
	title = "(AI Core Skin) Soviet"
	desc = "Replaces your AI core with a model originating from the Eastern Bloc."
	required_medal = "My Bologna Has A First Name" //placeholder bc there's no directly soviet related medals and meat has some soviet stuff in it ig
	AI_SKIN("soviet")
#undef AI_SKIN
