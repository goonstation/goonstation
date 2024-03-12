import fnmatch
import functools
import glob
import sys

# Originally from https://github.com/tgstation/tgstation/pull/66831 + changes - courtesy of mothblocks

reading = False

# Things we want to block from being included
FORBID_INCLUDE = [
    # Sekrits
    r'+secret**/*.dm',
    r'code/_placeholder.dm',
    r'code/_publicVersion.dm',

    # Included by __std.dme
    r'_std**/*.dm',

    # Included by _unit_test.dm
    r'code/modules/unit_tests/[!_]*.dm',

    # Included by tgs/includes.dm
    r'code/modules/tgs/**/*.dm',

    # Included by map.dm (which we have to whitelist)
    r'maps**/*.dm',

    # OpenDream pragma lint file
    r'tools/ci/od_lints.dm'
]

# Things we want to explicitly allow, even if they're in blocked dirs
ALLOW_INCLUDE = [
     # The one file in maps we always include
     r'maps/config/map.dm',
     # OD lint stuff that we want to live in `goonstation.dme`
     r'_std\__odlint.dme'
]

lines = []
total = 0
for line in sys.stdin:
    total+=1
    line = line.strip()

    if line == "// BEGIN_INCLUDE":
        reading = True
        continue
    elif line == "// END_INCLUDE":
        break
    elif not reading:
        continue

    lines.append(line)

offset = total - len(lines)
print(f"{offset} lines were ignored in output")
fail_no_include = False

for code_file in glob.glob("**/*.dm", recursive=True):
    dm_path = code_file.replace('/', '\\')

    included = f"#include \"{dm_path}\"" in lines
    forbid_include = False

    for forbid in FORBID_INCLUDE:
        if not fnmatch.fnmatch(code_file, forbid):
            continue

        explicit_allowed = False
        for allow in ALLOW_INCLUDE:
             if fnmatch.fnmatch(code_file, allow):
                  explicit_allowed = True
                  break

        if not explicit_allowed:
            forbid_include = True

            if included:
                print(f"{dm_path} should not be included")
                print(f"::error file={code_file},line=1,title=DME Validator::File should not be included")
                fail_no_include = True
                break

    if forbid_include:
        continue

    if not included:
        print(f"{dm_path} is not included")
        print(f"::error file={code_file},line=1,title=DME Validator::File is not included")
        fail_no_include = True

if fail_no_include:
    sys.exit(1)

def compare_lines(a, b):
    # Remove initial include as well as the final quotation mark
    a = a[len("#include \""):-1].lower()
    b = b[len("#include \""):-1].lower()

    a_segments = a.split('\\')
    b_segments = b.split('\\')

    for (a_segment, b_segment) in zip(a_segments, b_segments):
        a_is_file = a_segment.endswith((".dm", ".dms"))
        b_is_file = b_segment.endswith((".dm", ".dms"))

        # code\something.dm will ALWAYS come before code\directory\something.dm
        if a_is_file and not b_is_file:
            return -1

        if b_is_file and not a_is_file:
            return 1

        # interface\something.dm will ALWAYS come after code\something.dm
        if a_segment != b_segment:
            return (a_segment > b_segment) - (a_segment < b_segment)

    print(f"Two lines were exactly the same ({a} vs. {b})")

sorted_lines = sorted(lines, key = functools.cmp_to_key(compare_lines))
for (index, line) in enumerate(lines):
    if sorted_lines[index] != line:
        print(f"The include at line {index + offset} is out of order ({line}, expected {sorted_lines[index]})")
        print(f"::error file=goonstation.dme,line={index+offset},title=DME Validator::The include at line {index + offset} is out of order ({line}, expected {sorted_lines[index]})")
        sys.exit(1)
