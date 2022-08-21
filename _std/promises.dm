#define INF_SLEEP_TIME 1e7

#define SPINLOCK_COUNT 10
#define SPINLOCK_SLEEP_DURATION 1

/**
 * Represents something akin to a sleep() call that can be interrupted.
 *
 * You create this datum, give a copy to some other place and call `wait()` to sleep until interrupted.
 * The other place can then call `INTERRUPT_SLEEP(the_isleep)` to wake up the sleep.
 */
/datum/interruptible_sleep
	var/spinlock_iters_left = SPINLOCK_COUNT
	var/interrupted = FALSE

	/**
	 * Sleep until interrupted.
	 *
	 * @param isleep How long to wait. If not provided sleep indefinitely.
	 * @return TRUE if interrupted, FALSE if not.
	 */
	proc/wait(time=INF_SLEEP_TIME)
		. = TRUE
		while(!src.interrupted && src.spinlock_iters_left > 0) // if interrupted quickly we avoid full `del`
			sleep(SPINLOCK_SLEEP_DURATION)
			src.spinlock_iters_left-- // decrementing here because we want it to be non-zero in the sleep
		if(src.interrupted)
			return
		sleep(time - SPINLOCK_COUNT * SPINLOCK_SLEEP_DURATION)
		. = FALSE

/**
 * Interrupts an /datum/interruptible_sleep.
 * For best performance make sure there are as few references to this datum as possible.
 *
 * @param ISLEEP The sleep to interrupt.
 */
#define INTERRUPT_SLEEP(ISLEEP) \
	if(ISLEEP?.spinlock_iters_left && !ISLEEP.interrupted) \
		{ ISLEEP.interrupted = TRUE; } \
	else if (!isnull(ISLEEP)) \
		{ del ISLEEP; }

/**
 * Represents a promised value that can then be fulfilled (likely by some other execution context).
 * Supports waiting for fulfillment.
 *
 * You create this datum, give a copy to some other place and call `wait()` or `wait_for_value()` to wait for fulfillment.
 * The other place can then call `the_promise.fulfill(value)` to fulfill the promise with value `value`, this interrupts all the waits.
 */
/datum/promise
	VAR_PRIVATE/datum/interruptible_sleep/isleep = null
	var/value = null
	var/fulfilled = FALSE

	/**
	 * Wait for the promise to be fulfilled.
	 *
	 * @param timeout How long to wait for fulfillment. If not provided wait indefinitely.
	 * @return TRUE if fulfilled, FALSE if not (due to timeout expiring).
	 */
	proc/wait(timeout=INF_SLEEP_TIME)
		if(fulfilled)
			return fulfilled
		if(!isleep)
			isleep = new
		isleep.wait(timeout)
		return fulfilled

	/**
	 * Wait for the promise to be fulfilled and return the value.
	 *
	 * @param timeout How long to wait for fulfillment. If not provided wait indefinitely.
	 * @return The value of the promise or null if unfulfilled.
	 */
	proc/wait_for_value(timeout=INF_SLEEP_TIME)
		if(fulfilled)
			return value
		if(!isleep)
			isleep = new
		isleep.wait(timeout)
		return value

	/**
	 * Fulfills the promise with value `value`.
	 *
	 * @param value The value to fulfill the promise with.
	 * @return TRUE if the promise was not already fulfilled, FALSE if it was.
	 */
	proc/fulfill(val)
		if(fulfilled)
			return FALSE
		value = val
		fulfilled = TRUE
		INTERRUPT_SLEEP(isleep)
		return TRUE

#undef INF_SLEEP_TIME

#undef SPINLOCK_COUNT
#undef SPINLOCK_SLEEP_DURATION
