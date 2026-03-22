import os
import re

directories = [
    r"d:\prm_project\school_app_backend\src\main\java\com\he186581\school_app\controller"
]

# Match @RequestParam / @PathVariable
# then possibly whitespace
# then Type (can include spaces, commas, angle brackets), we will just lazily match until we find the name which is just before a comma, closing parenthesis, or just an identifier.
# Actually, the simplest check: regex for @RequestParam followed by any characters until the last word before a comma or closing paren.
# But it's risky.

# Better regex:
# @(?:RequestParam|PathVariable)(?:\(.*?\))?\s+(?:[\w<>,\.\?\[\]\s]+)\s+(\w+)\s*[,)]

# Let's just use simple regex and manually fix the Map one if it misses it.

pattern1 = re.compile(r'@(RequestParam|PathVariable)\s+([A-Za-z0-9_<>\[\]]+)\s+([A-Za-z0-9_]+)')
pattern2 = re.compile(r'@(RequestParam|PathVariable)\s*\(\s*(required\s*=\s*(?:true|false))\s*\)\s+([A-Za-z0-9_<>\[\]]+)\s+([A-Za-z0-9_]+)')
pattern_map = re.compile(r'@(RequestParam|PathVariable)\s+([A-Za-z0-9_<>, \?\[\]]+)\s+([A-Za-z0-9_]+)')

count = 0
for directory in directories:
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".java"):
                path = os.path.join(root, file)
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()

                new_content = pattern1.sub(r'@\1("\3") \2 \3', content)
                new_content = pattern2.sub(r'@\1(value = "\4", \2) \3 \4', new_content)
                
                # handle Map<String, String> kind of things
                def repl_map(m):
                    anno = m.group(1)
                    type_str = m.group(2).strip()
                    name = m.group(3)
                    # if type_str has a space in it or comma
                    if "," in type_str:
                        return f'@{anno}("{name}") {type_str} {name}'
                    else:
                        return m.group(0)
                        
                new_content = re.sub(r'@(RequestParam|PathVariable)\s+([A-Za-z0-9_<>, \?\[\]]+)\s+([A-Za-z0-9_]+)', repl_map, new_content)

                if new_content != content:
                    count += 1
                    with open(path, "w", encoding="utf-8") as f:
                        f.write(new_content)
                    print(f"Fixed {file}")

print(f"Total files fixed: {count}")
