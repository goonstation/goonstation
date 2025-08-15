/// The shell script encountered a if statement evaluated as TRUE.
#define SCRIPT_IF_TRUE		(1 << 0)
/// The shell script is currently in a while loop.
#define SCRIPT_IN_LOOP		(1 << 1)

/// The maximum number of pipes that may be used in a single line.
#define MAX_PIPED_COMMANDS 16
/// The maximum number of while loop iterations when processing a script.
#define MAX_SCRIPT_COMPLEXITY 2048
/// When executing a shell script, the shell forks itself; this is the maximum fork depth.
#define MAX_SCRIPT_ITERATIONS 128
/// The maximum number of items allowed in the data stack.
#define MAX_STACK_DEPTH 128

/// The maximum value of a 32-bit signed integer.
#define INT_MAX 2147483647
/// The minimum value of a 32-bit signed integer.
#define INT_MIN -2147483647

/// Clamp the passed value between `INT_MAX` and `INT_MIN`, which represent the maximum and minimum internal values of a 32-bit signed fixed-point number.
#define SCRIPT_CLAMPVALUE(VALUE) round(clamp(VALUE, INT_MIN, INT_MAX), 0.01)
