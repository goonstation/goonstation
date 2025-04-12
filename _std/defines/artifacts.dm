#define ARTIFACT_SIZE_LARGE 3
#define ARTIFACT_SIZE_MEDIUM 2
#define ARTIFACT_SIZE_TINY 1

#define ARTIFACT_SHARD_ESSENCE "art_shard_essence"
#define ARTIFACT_SHARD_POWER "art_shard_power"
#define ARTIFACT_SHARD_SPACETIME "art_shard_spacetime"
#define ARTIFACT_SHARD_FUSION "art_shard_fusion"
#define ARTIFACT_SHARD_OMNI "art_shard_omni"

// flags for allowed combinations
#define ARTIFACT_COMBINES_INTO_ANY (1<<0)
#define ARTIFACT_ACCEPTS_ANY_COMBINE (1<<1)
#define ARTIFACT_DOES_NOT_COMBINE (1<<2)
#define ARTIFACT_COMBINES_INTO_HANDHELD (1<<3)
#define ARTIFACT_COMBINES_INTO_LARGE (1<<4)

/// effect priorities when combined
#define ARTIFACT_COMBINATION_PASSIVE "art_combination_passive"
#define ARTIFACT_COMBINATION_TOUCHED "art_combination_touched"
