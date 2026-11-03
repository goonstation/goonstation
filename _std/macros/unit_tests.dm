/**
 * Lets unit tests answer tgui prompts without a client.
 * Responses are queued with [/datum/unit_test/proc/queue_tgui_responses] and consumed in order.
 * Put at the very top of a prompt proc.
 */
#ifdef UNIT_TESTS
/// Returns the next queued response, if there is one
#define UNIT_TEST_TGUI_RESPONSE if (length(global.unit_tests.tgui_responses)) { return global.unit_tests.pop_tgui_response() }
/// Invokes CALLBACK with the next queued response, if there is one
#define UNIT_TEST_TGUI_RESPONSE_ASYNC(CALLBACK) if (length(global.unit_tests.tgui_responses)) { global.unit_tests.pop_tgui_response_async(CALLBACK); return }
#else
#define UNIT_TEST_TGUI_RESPONSE
#define UNIT_TEST_TGUI_RESPONSE_ASYNC(CALLBACK)
#endif
