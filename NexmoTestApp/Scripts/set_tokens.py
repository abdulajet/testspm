import urllib2
import json
import os
import sys

targetDir = sys.argv[1]
print "TARGET_DIR: " + targetDir
user_types = ["testUser", "baby", "demo"]
user_pattern = "%s%d"
base_request = "http://capi-token.dev.il.vocal-dev.com:8889/token/f1a5f6fa-7d74-4b97-bdf4-4ecaae8e851e/%s%d"
base_line = "static NSString * const %s%dToken = @\"%s\";"
def main():
	print("Updating Tokens")
	new_lines = {}
	input_file = open(targetDir+"/Scripts/Tokens.h.template",'r')
	output_file = open(targetDir+"/AppCode/users/NXMTokens.h","w")
	for user_type in user_types:
		for i in range(1,10):
			content = urllib2.urlopen(base_request % (user_type , i)).read()
			json_content = json.loads(content)
			new_line = base_line % (user_type , i , json_content["token"])
			new_lines[user_pattern % (user_type , i)] = new_line
	
	print new_lines
	
	for input_line in input_file.readlines():
		token_index = input_line.find("Token =")
		if token_index != -1:
			user_id = input_line[:token_index]
			output_file.write(new_lines[user_id] + "\n\n")
		else:
			output_file.write(input_line)

	output_file.close()
	input_file.close()
	print("Tokens Updated")

if __name__ == '__main__':
	main()
