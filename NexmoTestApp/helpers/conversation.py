import sys
import requests
import utils
import getopt

base_url = 'http://lb1.%s.npe:5200/v1/conversations'

usage = '''
conversation.py -e npeName -t token -c conversationName -u basename -n num_of_users
'''


def get_conversation(url, token, conversation_id):
    print '++++++++++++++++++++++++++++++++++'
    print 'start get_conversation ',url,token,conversation_id
    print '++++++++++++++++++++++++++++++++++'
    url = url + '/' + conversation_id
    req = requests.get(url, headers=utils.create_headers(token=token))
    utils.print_color_json(req.text)
    print '++++++++++++++++++++++++++++++++++'
    print 'end get_conversation'
    print '++++++++++++++++++++++++++++++++++'
    return req.json()


def create_conversation(url, token, name, user_names):
    print 'start create_conversation ',url ,token,name,user_names
    json_to_use = {
        "body":
            {
                "name": name
            }
    }
    req = requests.post(url, json=json_to_use, headers=utils.create_headers(token=token))
    if req.status_code == 200:
        conversation_id = req.json()['id']
        for name in user_names:
            json_to_use = {
                "action": "join",
                "user_name": name,
                "channel": {
                    "type": "app"
                    }
            }
            # req =
            requests.post(url+'/'+conversation_id+'/members', json=json_to_use,
                          headers=utils.create_headers(token=token))
            # print req.status_code

    print '++++++++++++++++++++++++++++++++++'
    print 'end create_conversation '
    print '++++++++++++++++++++++++++++++++++'
    return get_conversation(url, token, conversation_id)


def main():

    try:
        opts, args = getopt.getopt(sys.argv[1:], "he:t:c:u:n:")
    except getopt.GetoptError:
        print usage
        sys.exit()
    print opts
    for opt, arg in opts:
        if opt == '-h':
            print usage
            sys.exit()
        elif opt in "-e":
            npe_name = arg
        elif opt in "-t":
            token = arg
        elif opt in "-c":
            conversation_name = arg
        elif opt in "-u":
            user_name_base = arg
        elif opt in "-n":
            num_of_users = int(arg)
        else:
            print usage
            sys.exit()
    b_url = utils.get_url_for_npe(npe_name) + 'conversations'
    user_names = []
    for i in range(num_of_users):
        user_names.append(user_name_base+'_'+str(i))
    create_conversation(b_url, token, conversation_name, user_names)
    pass


if __name__ == '__main__':
    main()
