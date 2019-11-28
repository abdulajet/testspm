import datetime
import sys
import jwt
import getopt
import urllib2
import json
import os


usage = '''
            jwt_tokens.py -a 'applicationId' -k $'secretKey' -t admin/user -n [userName]
'''

adminAcl = {
    "paths": {
        "/**": {},
    }
}

def getproductiontoken(username, applicationid):
  base_request = "http://capi-token.dev.il.vocal-dev.com:8889/token/%s"

  urlt = base_request % (applicationid)
  if not username == None:
    urlt = urlt + '/' + username 
  content = urllib2.urlopen(urlt).read()
  json_content = json.loads(content)  
  return json_content["token"]


def create_token_for_user(application_id, private_key, username, npename):
    print '++++++++++++++++++++++++++++++++++'
    print 'start create_token_for_user ' ,application_id , private_key ,username, npename
    print '++++++++++++++++++++++++++++++++++'
    if 'prod' in npename:
      return getproductiontoken(username, application_id)
    else:
      jti = ''
      now = int((datetime.datetime.utcnow() - datetime.datetime(1970, 1, 1)).total_seconds() * 1000)
      jti = str(now)
      acl = {"paths": {
        "/*/users/**": {},
        "/*/conversations/**": {},
        "/*/sessions/**": {},
        "/*/devices/**": {},
        "/*/image/**": {},
        "/*/media/**": {},
        "/*/applications/**": {},
        "/*/push/**": {},
        "/*/knocking/**": {},
        "/*/calls/**": {}
      }
      }
      exp = (now / 1000) + (10 * 365 * 24 * 60 * 60)
      payload = {'iat': round(now / 1000),
                 'nbf': round(now / 1000),
                 'jti': jti,
                 'application_id': application_id,
                 'acl': adminAcl if username == 'admin' else acl,
                 'exp': exp,
                 'iss': "Kostas"
                 }
      if username is not None:
          payload['sub'] = username

      key = "\n".join([l.lstrip() for l in private_key.split("\n")])
      # print key

      encoded = jwt.encode(payload, key, algorithm='RS256')

      print '++++++++++++++++++++++++++++++++++'
      print 'end create_token_for_user '
      print '++++++++++++++++++++++++++++++++++'
      return encoded


def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "ha:k:t:n:")
    except getopt.GetoptError:
        print usage
        sys.exit()
    for opt, arg in opts:
        if opt == '-h':
            print usage
            sys.exit()
        elif opt in "-a":
            application_id = arg
        elif opt in "-k":
            private_key = arg
        elif opt in "-t":
            type_of_user = arg
        elif opt in "-n":
            base_name = arg
        else:
            print usage
            sys.exit()
    if type_of_user == 'admin':
        encoded = create_token_for_user(application_id, private_key=private_key, username=None)
    else:
        encoded = create_token_for_user(application_id, private_key=private_key, username=base_name)

    print encoded


if __name__ == "__main__":
    main()
