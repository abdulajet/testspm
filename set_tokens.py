import urllib2
import json
import os
import sys

targetDir = sys.argv[1]
print "TARGET_DIR: " + targetDir
base_request = "http://capi-token.dev.il.vocal-dev.com:8889/token/f1a5f6fa-7d74-4b97-bdf4-4ecaae8e851e/testuser%d"
base_line = "static const NSString* testUser%dToken = @\"%s\";"
def main():
	new_lines = []
	input_file = open("Tokens.h.template",'r')
	output_file = open(targetDir+"/Tokens.h","w")

	for i in range(1,9):
		content = urllib2.urlopen(base_request % i).read()
		json_content = json.loads(content)
		new_line = base_line % (i , json_content["token"])
		new_lines.append(new_line)
	
	#print new_lines
	
	for input_line in input_file.readlines():
		if input_line.find("Token =") != -1:
			output_file.write(new_lines	.pop() + "\n")
		else:
			output_file.write(input_line)

	output_file.close()
	input_file.close()

if __name__ == '__main__':
	main()
