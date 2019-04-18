import urllib3
import json
import os
import sys
import time
import getopt

usage = '''
usage:
delete_conversation.py
'''

# defaults
page_size = 50  # less than 100
conversations_not_to_delete = []  # less than page_size to avoid infinite loops cause this is a shitty script :)
num_of_conversations_not_to_delete = conversations_not_to_delete.__len__()


def main():
    token = get_token()
    delete_conversations(token)


def get_token():
    print("acquiring token")
    token_request_url = "http://capi-token.dev.il.vocal-dev.com:8889/token/f1a5f6fa-7d74-4b97-bdf4-4ecaae8e851e"
    token_content = urllib2.urlopen(token_request_url).read()
    token_json_content = json.loads(token_content)
    token = token_json_content["token"]
    print("token received " + token[0:6] + "...")
    return token


def delete_conversation(cid):
    if cid in conversations_not_to_delete:
        print("skipping conversation " + cid)
        return

    conversation_url = conversations_url + "/%s" % cid
    print("deleting conversation " + cid)


def delete_conversations(token):
    print("starting to delete conversations")
    deleting_conversations = 1

    for_testings = 5

    while deleting_conversations:
        print("acquiring conversations")
        cs_base_url = "https://api.nexmo.com/beta"
        conversations_url = cs_base_url + "/conversations"
        conversations_request = urllib3.Request(conversations_url, headers={'Authorization': 'bearer %s' % token})
        conversations_payload = json.loads(urllib3.urlopen(conversations_request).read())
        num_of_total_conversations = conversations_payload["count"]
        print("total of %i conversations" % (num_of_total_conversations))
        for_testings = for_testings - 1
        if num_of_total_conversations <= num_of_conversations_not_to_delete or for_testings == 0:
            deleting_conversations = 0

        conversations = conversations_payload["_embedded"]["conversations"]
        num_of_conversations_queried = conversations.__len__()
        print("queried %i conversations" % num_of_conversations_queried)

        for i in xrange(1,num_of_conversations_queried):
            delete_conversation(conversations[i]["uuid"])
            time.sleep(1)


if __name__ == '__main__':
    main()
