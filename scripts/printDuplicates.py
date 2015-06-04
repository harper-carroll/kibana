import sys

#Run this script to find duplicates.
# First argument is the file name.
file=sys.argv[1]
fileContent = open(file);
seen = set();
line_num = 0;
for line in fileContent:
   line_num = line_num + 1;
   line_lower = line.lower();
   if line_lower in seen:
      print line_num, line
   else:
      seen.add(line_lower)
