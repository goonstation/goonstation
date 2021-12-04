/// Min range before rng kicks in
#define AST_MINSIZE 7
/// prob reduction per 1 tile over min size
#define AST_REDUCTION 9
/// +- mod on asteroid size, i.e. 4 = 4 tiles smaller to 4 tiles larger.
#define AST_SIZERANGE 4
/// +- range of flat rng applied to tile placement
#define AST_TILERNG 20
/// Base amount of asteroid seeds. Actual amount of asteroids works out to be significantly less.
#define AST_SEEDS 40
/// Amount of asteroid tiles to dig out during random walk.
#define AST_RNGWALKCNT 7
/// How many random walks should we do per asteroid.
#define AST_RNGWALKINST 5

/// Lower bound of amount of drones that can spawn
#define DEBRIS_DRONE_LOWER 60
/// Upper bound of amount of drones that can spawn
#define DEBRIS_DRONE_UPPER 85
/// Lower bound of amount of garbage that can spawn
#define DEBRIS_GARBAGE_LOWER 125
/// Upper bound of amount of garbage that can spawn
#define DEBRIS_GARBAGE_UPPER 225
/// Lower bound of amount of small asteroids that can spawn
#define DEBRIS_ASTEROID_LOWER 100
/// Upper bound of amount of small asteroids that can spawn
#define DEBRIS_ASTEROID_UPPER 115
/// Lower bound of amount of length of asteroids that can spawn
#define DEBRIS_ASTEROID_LENGTH_LOWER 5
/// Upper bound of amount of length of asteroids that can spawn
#define DEBRIS_ASTEROID_LENGTH_UPPER 9
/// Lower bound of amount of generated loot derelicts that can spawn
#define DEBRIS_LOOT_LOWER 30
/// Upper bound of amount of generated loot derelicts that can spawn
#define DEBRIS_LOOT_UPPER 50
/// How many drone beacons do we REALLY NEED TO SPAWN?
#define DEBRIS_DRONE_BEACONS 5

#ifdef UNDERWATER_MAP
/// How many prefabs to place. It'll try it's hardest to place this many at the very least. You're basically guaranteed this amount of prefabs.
#define AST_NUMPREFABS 18
/// Up to how many extra prefabs to place randomly. You might or might not get these extra ones.
#define AST_NUMPREFABSEXTRA 6
#else
/// How many prefabs to place. It'll try it's hardest to place this many at the very least. You're basically guaranteed this amount of prefabs.
#define AST_NUMPREFABS 11
/// Up to how many extra prefabs to place randomly. You might or might not get these extra ones.
#define AST_NUMPREFABSEXTRA 5
#endif

/// How many big prefabs to place. It'll try it's hardest to place this many at the very least. You're basically guaranteed this amount of prefabs.
#define DEBRIS_NUMBIGPREFABS 7
/// Up to how many extra big prefabs to place randomly. You might or might not get these extra ones.
#define DEBRIS_NUMBIGPREFABSEXTRA 4
/// Same as above but this only counts the small ones that are basically moot
#define DEBRIS_NUMSMALLPREFABS 8
/// Up to how many extra big prefabs to place randomly. You might or might not get these extra ones.
#define DEBRIS_NUMSMALLPREFABSEXTRA 7

/// Min distance from map edge for seeds.
#define AST_MAPSEEDBORDER 10
/// Absolute map border around generated content
#define AST_MAPBORDER 3
/// Zlevel for asteroid field generation.
#define AST_ZLEVEL 5

/// Zlevel for debris field generation.
#define DEBRIS_ZLEVEL 3
