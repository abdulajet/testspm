import sys
import requests
import time
import utils
import getopt

usage = '''
user.py -e npeName -t adminToken -n numOfUsers -b [basicName]
'''


def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "he:t:n:b:")
    except getopt.GetoptError:
        print usage
        sys.exit()
    for opt, arg in opts:
        if opt == '-h':
            print usage
            sys.exit()
        elif opt in "-e":
            npe_name = arg
        elif opt in "-t":
            admin_token = arg
        elif opt in "-n":
            num_of_users = int(arg)
        elif opt in "-b":
            base_name = arg
        else:
            print usage
            sys.exit()
    b_url = utils.get_url_for_npe(npe_name) + 'users'
    for i in range(num_of_users):
        if base_name is None:
            create_user(url=b_url, token=admin_token, name=None)
        else:
            create_user(url=b_url, token=admin_token, name=base_name+'_' + str(i))
    time.sleep(1)
    get_users(b_url + 'users', admin_token)


def create_user(url, token, name):
    print '++++++++++++++++++++++++++++++++++'
    print 'start create_user ',url ,token, name
    print '++++++++++++++++++++++++++++++++++'
    json_to_use = {}
    if name is not None:
        json_to_use = {"name": name}
    req = requests.post(url, json=json_to_use, headers=utils.create_headers(token=token))
    # print json_to_use['name'] + ' status code is ' + str(req.status_code)
    print '++++++++++++++++++++++++++++++++++'
    print 'end create_user '
    print '++++++++++++++++++++++++++++++++++'
    return req


def get_users(url, token):
    print '++++++++++++++++++++++++++++++++++'
    print 'start get_users ',url ,token
    print '++++++++++++++++++++++++++++++++++'
    req = requests.get(url, headers=utils.create_headers(token=token))
    utils.print_color_json(req.text)
    print '++++++++++++++++++++++++++++++++++'
    print 'end get_users '
    print '++++++++++++++++++++++++++++++++++'
    return req.json()


if __name__ == '__main__':
    main()
