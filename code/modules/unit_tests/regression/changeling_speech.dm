// Antagonist setup expects a game mode, but regression tests run before ticker initialization.
/datum/changeling_speech_test_context
	var/datum/controller/gameticker/previous_ticker

/datum/changeling_speech_test_context/New()
	. = ..()
	src.previous_ticker = global.ticker
	global.ticker = new /datum/controller/gameticker
	global.ticker.mode = new /datum/game_mode/extended

/datum/changeling_speech_test_context/disposing()
	qdel(global.ticker.mode)
	qdel(global.ticker)
	global.ticker = src.previous_ticker
	src.previous_ticker = null
	. = ..()

/datum/listen_module/effect/changeling_speech_test
	id = "changeling_speech_test"
	var/list/heard = list()

/datum/listen_module/effect/changeling_speech_test/process(datum/say_message/message)
	src.heard += message.get_content()

/datum/unit_test/regression/changeling_headspider_speech
	var/datum/changeling_speech_test_context/context

/datum/unit_test/regression/changeling_headspider_speech/New()
	. = ..()
	src.context = new

/datum/unit_test/regression/changeling_headspider_speech/disposing()
	. = ..()
	qdel(src.context)
	src.context = null

/datum/unit_test/regression/changeling_headspider_speech/Run()
	var/starting_runtimes = runtime_count
	var/mob/living/carbon/human/body = src.allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = src.allocate(/mob/living/carbon/human)
	var/mob/living/critter/changeling/headspider/spider = src.allocate(/mob/living/critter/changeling/headspider)
	body.mind = new /datum/mind(body)
	victim.mind = new /datum/mind(victim)
	var/datum/mind/victim_mind = victim.mind
	var/datum/abilityHolder/changeling/holder = body.add_ability_holder(/datum/abilityHolder/changeling)

	// activate_headspider deliberately keeps the holder off the spider's ability list.
	body.mind.transfer_to(spider)
	holder.owner = spider
	TEST_ASSERT(!spider.get_ability_holder(/datum/abilityHolder/changeling), "Headspider fixture must have a detached holder")

	// Match the order in headspider.stage_act: absorb before moving the holder to the host.
	holder.addDna(victim, TRUE)
	var/mob/dead/target_observer/hivemind_observer/member = victim_mind.current
	TEST_ASSERT(istype(member), "Victim should become a hivemind observer")
	member.ghost = src.allocate(/mob/dead/observer, member)
	src.allocated += member
	spider.mind.transfer_to(victim)
	victim.add_existing_ability_holder(holder)
	holder.insert_into_hivemind(member)
	holder.reassign_hivemind_target_mob()

	TEST_ASSERT(member.hivemind_owner == holder, "Headspider victim must have the new holder")
	TEST_ASSERT(member in holder.hivemind, "Headspider victim must be registered in the hivemind")
	TEST_ASSERT(member.target == victim, "Headspider victim must follow the host")
	TEST_ASSERT(member.ensure_speech_tree().GetOutputByID(SPEECH_OUTPUT_HIVECHAT_MEMBER, ref(holder)), "Headspider victim must speak to the holder's subchannel")
	TEST_ASSERT(!member.speech_tree.GetOutputByID(SPEECH_OUTPUT_HIVECHAT_MEMBER, "\ref[null]"), "No speech output should address a null holder")
	TEST_ASSERT(victim.ensure_speech_tree().GetOutputByID(SPEECH_OUTPUT_SPOKEN), "New host must retain ordinary speech")
	var/datum/listen_module/effect/changeling_speech_test/receiver = victim.ensure_listen_tree().AddListenEffect("changeling_speech_test")
	member.say("headspider regression message")
	TEST_ASSERT("headspider regression message" in receiver.heard, "Headspider victim's actual message must reach the new host")
	TEST_ASSERT_EQUAL(runtime_count, starting_runtimes, "Headspider speech test must not runtime")

/datum/unit_test/regression/changeling_hivemind_transfer_speech
	var/datum/changeling_speech_test_context/context

/datum/unit_test/regression/changeling_hivemind_transfer_speech/New()
	. = ..()
	src.context = new

/datum/unit_test/regression/changeling_hivemind_transfer_speech/disposing()
	. = ..()
	qdel(src.context)
	src.context = null

/datum/unit_test/regression/changeling_hivemind_transfer_speech/Run()
	var/starting_runtimes = runtime_count
	var/mob/living/carbon/human/loser = src.allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/winner = src.allocate(/mob/living/carbon/human)
	loser.mind = new /datum/mind(loser)
	winner.mind = new /datum/mind(winner)
	var/datum/abilityHolder/changeling/old_holder = loser.add_ability_holder(/datum/abilityHolder/changeling)
	var/datum/abilityHolder/changeling/new_holder = winner.add_ability_holder(/datum/abilityHolder/changeling)
	var/list/members = list()
	for (var/i in 1 to 2)
		var/mob/living/carbon/human/victim = src.allocate(/mob/living/carbon/human)
		victim.mind = new /datum/mind(victim)
		members += old_holder.insert_into_hivemind(victim)

	// A dead legworm returns through the same insertion path before its master is absorbed.
	var/mob/living/critter/changeling/legworm/legworm = src.allocate(/mob/living/critter/changeling/legworm)
	legworm.mind = new /datum/mind(legworm)
	var/datum/mind/leg_mind = legworm.mind
	legworm.hivemind_owner = old_holder
	legworm.death()
	members += leg_mind.current
	src.allocated += members

	var/datum/listen_module/effect/changeling_speech_test/receiver = winner.ensure_listen_tree().AddListenEffect("changeling_speech_test")
	TEST_ASSERT_EQUAL(length(members), 3, "Fixture must include two observers and a returned legworm")
	for (var/mob/member in members)
		TEST_ASSERT(istype(member, /mob/dead/target_observer/hivemind_observer), "Fixture must contain actual hivemind observers")
		member.ghost = src.allocate(/mob/dead/observer, member)
	var/datum/mind/loser_mind = loser.mind
	new_holder.addDna(loser)
	var/mob/dead/target_observer/hivemind_observer/absorbed_master = loser_mind.current
	absorbed_master.ghost = src.allocate(/mob/dead/observer, absorbed_master)
	src.allocated += absorbed_master
	for (var/mob/dead/target_observer/hivemind_observer/member in members)
		TEST_ASSERT(member.hivemind_owner == new_holder && member.target == winner, "Every transferred member must follow the winning changeling")
		TEST_ASSERT(member in new_holder.hivemind, "Every transferred member must be registered in the new hivemind")
		TEST_ASSERT(!(member in old_holder.hivemind), "Transferred members must leave the old hivemind")
		TEST_ASSERT(member.ensure_speech_tree().GetOutputByID(SPEECH_OUTPUT_HIVECHAT_MEMBER, ref(new_holder)), "Transferred member must speak in the new hivemind")
		TEST_ASSERT(!member.speech_tree.GetOutputByID(SPEECH_OUTPUT_HIVECHAT_MEMBER, ref(old_holder)), "Transferred member must stop speaking in the old hivemind")
		receiver.heard.Cut()
		member.say("transferred member regression message")
		TEST_ASSERT("transferred member regression message" in receiver.heard, "Transferred member's actual message must reach the winning changeling")
		new_holder.insert_into_hivemind(member)
		TEST_ASSERT_EQUAL(member.speech_tree.GetOutputSubcount(SPEECH_OUTPUT_HIVECHAT_MEMBER, ref(new_holder)), 1, "Repeated insertion must not duplicate speech subscriptions")
	TEST_ASSERT_EQUAL(runtime_count, starting_runtimes, "Hivemind transfer speech test must not runtime")
