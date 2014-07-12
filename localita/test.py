# coding=utf-8
import re
#regex = re.compile(r"^.*interfaceOpDataFile.*$", re.IGNORECASE)
ins = open( "lista_località", "r" )
array = []

file = open("newfile.txt", "w")

for line in ins:
    line = line.replace("<a id=\"link-localita-", "")
    line = line.replace("\" class=\"link-localita\" href='", ",")
    line = line.replace("    <div id=\"localita-", "")
    line = line.replace("\" class=\"localita\">", ";")
    line = line.replace("\" class=\"localita\">", "")
    print line
    file.write(line)
ins.close()
file.close()
