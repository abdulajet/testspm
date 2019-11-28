import sys
import os
import jwt_tokens
import user
import conversation
import xml.etree.ElementTree as ET
import plistlib
import getopt
import utils
from xml.dom import minidom
from xml.dom.minidom import parseString

usage = '''
npe_evn_dev.py -a 'applicationId' -p $'privateKey' -e npeName -f userNamePrefix -m pathToAndroid -c NumOfUsers -o [Android/iOS]
'''
pretty_print = lambda data: '\n'.join([line for line in parseString(ET.tostring(data)).toprettyxml(indent=' '*2).split('\n') if line.strip()])

def main():
    private_key = ''
    try:
        opts, args = getopt.getopt(sys.argv[1:], "ha:p:e:c:f:m:o:")
    except getopt.GetoptError:
        print usage
        sys.exit()
    for opt, arg in opts:
        if opt == '-h':
            print usage
            sys.exit()
        elif opt in "-e":
            npe_name = arg
        elif opt in "-a":
            application_id = arg
        elif opt in "-c":
            count = int(arg)
        elif opt in "-p":
            private_key = arg
        elif opt in "-f":
            user_name_prefix = arg
        elif opt in "-m":
            path_to_android = arg
        elif opt in "-o":
            os = arg
        else:
            print usage
            sys.exit()

    # create token for admin user

    admin_token = jwt_tokens.create_token_for_user(application_id=application_id, private_key=private_key,
                                                   username=None, npename=npe_name)
    print 'admin Token for:' + admin_token
    b_url = utils.get_url_for_npe(npe_name)
    for i in range(0, count):
        user_name = user_name_prefix + '_' + str(i)
        res = user.create_user(b_url + 'users', token=admin_token, name=user_name)
    usersJson = user.get_users(url=b_url + 'users', token=admin_token)
    for userj in usersJson:
        userj["token"] = jwt_tokens.create_token_for_user(application_id=application_id, private_key=private_key,
                                                            username=userj["name"], npename=npe_name)
    # for username in user_names:
    #     user_tokens.append(jwt_tokens.create_token_for_user(application_id=application_id, private_key=private_key,
                                                            # username=username))
    # TODO: update iOS and Android framework sample App with the new MemberIds, tokens, conversationId and npe address
    #print usersJson
    if 'Android' in os:
        save_to_android(usersJson, npe_name, path_to_android)
    elif 'iOS' in os:
        save_to_ios(usersJson, npe_name, path_to_android)


def save_to_android(users, npe_name, path):
    root_xml_node = ET.parse(path +
                             '/app/src/main/res/values/nexmo_strings.xml').getroot()
    root_xml_node.find('.//string[@name="npe_name"]').text = npe_name
    tokens_xml_items = root_xml_node.find('.//array[@name="usertokens"]')
    users_xml_items = root_xml_node.find('.//array[@name="usernames"]')
    ids_xml_items = root_xml_node.find('.//array[@name="userids"]')
    #   print help(tokens_xml_items),users_xml_items,ids_xml_items
    tokens_xml_items.clear()
    tokens_xml_items.set("name","usertokens")
    users_xml_items.clear()
    users_xml_items.set("name" ,"usernames")
    ids_xml_items.clear()
    ids_xml_items.set("name","userids")
    for userj in users:
        etItem = ET.Element("item")
        etItem.text = userj["name"]
        users_xml_items.append(etItem)
        etItem = ET.Element("item")
        etItem.text = userj["token"]
        tokens_xml_items.append(etItem)
        etItem = ET.Element("item")
        etItem.text = userj["id"]
        ids_xml_items.append(etItem)
    output_file = open(path +
                             '/app/src/main/res/values/nexmo_strings.xml',
                       'w')
    print pretty_print(root_xml_node)
    output_file.write(pretty_print(root_xml_node))
    output_file.close()


def get_members_for_names(user_names, conJson):
    members_in_conversation = conJson['members']
    members = []
    for user_name in user_names:
        for memberJson in members_in_conversation:
            if memberJson['name'] == user_name:
                members.append(memberJson['member_id'])
    return members


def save_to_ios(users, npe_name, path):
    print(os.getcwd())
    root_plist_node = plistlib.readPlist(path + '/users.plist')
    root_plist_node['users_names'] = []
    root_plist_node['users_tokens'] = []
    root_plist_node['users_ids'] = []

        
    for user in users:
        index_in_list = users.index(user)
        root_plist_node['users_names'].append(user["name"])
        root_plist_node['users_tokens'].append(user["token"])
        root_plist_node['users_ids'].append(user["id"])

    plistlib.writePlist(root_plist_node, path + '/users.plist')


if __name__ == '__main__':
    main()
