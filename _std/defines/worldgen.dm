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

/// Min distance from map edge for seeds.
#define AST_MAPSEEDBORDER 10
/// Absolute map border around generated content
#define AST_MAPBORDER 3
/// Zlevel for generation.
#define AST_ZLEVEL 5

/// Prefabs that spawn anywhere
#define PREFAB_ANYWHERE					(1<<0)
/// Prefabs that spawn in space
#define PREFAB_SPACE					(1<<1)
/// Prefabs that spawn on planets
#define PREFAB_PLANET					(1<<2)

// Water maps

/// Prefabs that spawn on nadir and other water maps
#define PREFAB_NADIR_SAFE				(1<<3)
/// Prefabs that spawn on water maps barring nadir
#define PREFAB_NADIR_UNSAFE				(1<<4)
/// Prefabs that only spawn on Nadir
#define PREFAB_NADIR 					(1<<5)
/// Prefabs that only spawn on Oshan
#define PREFAB_OSHAN					(1<<6)
/// Prefabs that only spawn on Manta
#define PREFAB_MANTA					(1<<7)
