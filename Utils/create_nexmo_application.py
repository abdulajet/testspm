### You might need to install some python packages to make it work
### pip install python-jose requests


import time
from random import random, randint

import requests
from datetime import datetime, timedelta
from base64 import urlsafe_b64encode
import os
import sys
from jose import jwt
import json


# ===============================================================================================
class Config:
    # IMAGE_URL_1 = "http://google.com/image1"

    DEFAULT_LASTNAME = 'Created from script'
    DEFAULT_XML_ACCOUNT = '<?xml version="1.0" encoding="UTF-8"?> ' \
                          '<account sysid="%(api_key)s" password="%(api_secret)s" max-binds="2" ' \
                          '  max-mt-per-second="5000" max-mo-per-second="5000" smpp-enabled="false" use-http="true" ' \
                          '  http-mo-base-url="" http-dn-base-url="" http-post-username="" http-post-password="" ' \
                          '  http-post-method="get" encoding="latin9"> <mo-queue enabled="true" mo-required="true" ' \
                          '  delivery-receipts-required="true" queue-size="50" discard-when-queue-full="false" /> ' \
                          '<quota enabled="%(quota)s" pricing-group-id="" mo-quota-enabled="%(mo_quota)s" /> ' \
                          '<banned banned="false" reason="" /> ' \
                          '<routing group-id="" /> ' \
                          '<dlr-format message-id-is-in-hex="false" /> ' \
                          '<special-capabilities> ' \
                          ' <internal can-specify-explicit-message-id="false" /> ' \
                          ' <automatically-ack-mo-and-dlr enabled="false" /> ' \
                          ' <custom-so-timeout value="0" /> ' \
                          ' <custom-mo-window-size value="0" /> ' \
                          ' <tlv can-specify-explicit-network-code="false" /> ' \
                          ' <smpp-nack include-message-id="true" /> ' \
                          ' <capabilities>%(capabilities)s</capabilities> ' \
                          '</special-capabilities> ' \
                          '<restrictions>%(restrictions)s</restrictions> ' \
                          '<security sign-mo-and-dlr-http-requests="false" signature-secret-method ' \
                          '="%(method)s" ' \
                          '  require-signed-http-submissions="false" secret-key="" /> ' \
                          '<capacity-thresholds>%(thresholds)s</capacity-thresholds>' \
                          '<time-created>%(creation_date)s</time-created> ' \
                          '<time-of-last-activity>%(creation_date)s</time-of-last-activity> ' \
                          '<time-last-modified>%(creation_date)s</time-last-modified> ' \
                          '</account>'
    DEFAULT_QUOTA_URL = '%(api_host)s:8009/quota/json' \
                        '?cmd=purchase&account=%(api_key)s&amount=%(credit)s&price=%(credit)s'
    DEFAULT_PROV_URL = '%(api_host)s:8019/provisioning/api' \
                       '?xml=%(xml)s&cmd=create-account&auto-top-up=true'
    DEFAULT_CALLBACK_URL = "https://callbacks.nexmo.io:8443/svc/callbacks_noauth/callback_json"
    # DEFAULT_IMAGE_URL = "http://image.com"

    DEVAPI_HOST = 'http://core1.santana.npe'  # sys.argv[1]
    # gConfig.DEVAPI_PATH = sys.argv[2]
    DEVAPI_URL = 'http://core1.santana.npe:8280/beta'  # sys.argv[2]

    application_name = "Vonage Test App"
    TESTING_ENV = 'dev'
    CS_URL = 'http://lb1.santana.npe:5200/v1'


gConfig = Config()


# ===============================================================================================
# ===============================================================================================

def create_account_and_application(app_type='rtc'):
    print("creating the account to be used for application creation...")

    new_account = create_account(api_host=gConfig.DEVAPI_HOST, acc_prefix="cscs")

    api_key = new_account[0]
    api_secret = new_account[1]

    print("==========================================================================")
    print("Account created API_KEY: {0} API_SECRET: {1}".format(api_key, api_secret))
    print("==========================================================================")

    # create an application
    print("creating the application...")
    application = create_application(
        application_name=gConfig.application_name,
        auth=(api_key, api_secret),
        answer_url=gConfig.DEFAULT_CALLBACK_URL,
        event_url=gConfig.DEFAULT_CALLBACK_URL,
        api_host=gConfig.DEVAPI_URL,
        application_type=app_type
    )

    print("Application created: [{}]".format("QA Application"))

    return application


# ===============================================================================================
def create_application(auth, answer_url, event_url,
                       application_name="", application_type="rtc",
                       backup_url="", answer_method="",
                       backup_method="", event_method="",
                       expected_response_code=201,
                       api_host=gConfig.DEVAPI_URL):
    """ creates an application
    developer: john.rickwood
    @param auth: api_key and api_secret
    @param answer_url: the answer URL (NCCO URL)
    @param event_url: the event URL
    @param application_name: optional field, if left blank it will be generated automatically
    @param application_type: the type of application (e.g. Voice)
    @param backup_url: a backup URL if the event URL is unavailable
    @param answer_method: answer method, defaults to POST
    @param backup_method: backup method, defaults to POST
    @param event_method: event method, defaults to POST
    @param expected_response_code: the expected response code
    @param api_host: the location of the dev api to be used
    :return JSON of the application details
    """

    # create an application name if one wasn't provided
    if not application_name:
        my_application_name = "auto_tests_application_name_{0}_{1}".format(
            time.strftime("%d%m%Y%H%M%S"), random.radom(1000, 9999))
    else:
        my_application_name = application_name

    params = dict()
    params['api_key'] = auth[0]
    params['api_secret'] = auth[1]
    params['name'] = my_application_name
    params['type'] = application_type
    params['answer_url'] = answer_url
    params['event_url'] = event_url
    if answer_method:
        params['answer_method'] = answer_method
    if event_method:
        params['event_method'] = event_method
    if backup_url:
        params['backup_url'] = backup_url
    if backup_method:
        params['backup_method'] = backup_method

    params['security'] = {"token-expiration-time-millisecs": "99999999", "request-signing":
        {"secret": '123456', "signature-method": "hmac-md5",
         "mandatory-signature": "true"},
                          "auth": {"public-key": '123456',
                                   "signature-method": "hmac-sha256"}}

    account = "account/" if gConfig.TESTING_ENV != 'live' else ""
    new_application = requests.post(
        url="{0}/{1}applications".format(api_host, account), params=params, timeout=30)

    print("==========================================================================")
    print("Request: POST {} ").format("{0}/{1}applications".format(api_host, account))
    print("Payload: {} ").format(params)
    print("Response Status Code: {}").format(new_application.status_code)
    print("==========================================================================")

    assert new_application.status_code == expected_response_code

    return new_application.json()


# ===============================================================================================
def create_account(acc_prefix="sip", api_host=gConfig.DEVAPI_HOST, dry_run=False, verbose=False,
                   number=1, start_index=1, first_name=None, last_name=None,
                   mail_domain="@test.com", credit=1000000, quota="true",
                   mo_quota="true", capabilities='', restrictions='<message-watermark />',
                   method='hash-md5',
                   thresholds='<threshold id="max-concurrent-calls" max="10000" />',
                   requests_client=requests):
    """ Helper method to create a new account (dashboard user is not created)
    developer: john.rickwood
    @param acc_prefix
    @param api_host
    @param dry_run
    @param verbose
    @param number
    @param start_index
    @param first_name: the first name of the new account
    @param last_name: the last name of the new account
    @param mail_domain
    @param credit: the initial credit to allocate to the account
    @param quota: should quota be enabled?
    @param mo_quota: should mo quota be enabled?
    @param capabilities: any capabilities to assign to the account
    @param restrictions: any restrictions to assign to the account
    @param method: signature method to be used
    @param thresholds: any thresholds to assign to the account
    note: modified from an original method created by Fabien
    """
    for x in range(1, 10):
        print("creating new account attempt {0}".format(x))

        api_key = "{0}-{1}".format(acc_prefix, randint(1000, 9999))
        api_secret = "AUTO-{0}".format(api_key)

        creation_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        print('Creating user %s' % api_key)
        if not api_secret:
            api_secret = api_key
        mail = '%s@%s' % (api_key, mail_domain)
        fn = first_name if first_name is not None else api_key
        ln = last_name if last_name is not None else gConfig.DEFAULT_LASTNAME

        # Make provisioning call
        xml = gConfig.DEFAULT_XML_ACCOUNT % locals()
        if verbose:
            print('HTTP request: %s' % (gConfig.DEFAULT_PROV_URL % locals()))
        if not dry_run:
            try:

                prov = requests.get(gConfig.DEFAULT_PROV_URL % locals())
            except:
                print("Failed to create account")
                continue

            if 'OK' not in prov.text:
                print("account creation failed!")
            else:
                # Make quota call
                if verbose:
                    print('HTTP request: %s' % (gConfig.DEFAULT_QUOTA_URL % locals()))
                if not dry_run:
                    quota = requests_client.get(gConfig.DEFAULT_QUOTA_URL % locals())
                    quota_json = quota.json()
                    if quota_json.get('result-code', -1) != 0:
                        print('Error calling quota API\nReq: %s\nResp: %s' %
                              (gConfig.DEFAULT_QUOTA_URL % locals(), str(quota_json)))
                        raise Exception("failed to create the account")
                    else:
                        if verbose:
                            print('User created: \napi_key: {}\napi_secret: {}\nemail: {}'.format(
                                api_key,
                                api_secret,
                                mail
                            ))
                        return api_key, api_secret

    raise Exception("failed to create the account")


# ===============================================================================================
def createAdminToken(application, acl=None):
    payload = {
        "iat": int(time.time()) - 3,
        "iss": "QA",
        'exp': datetime.utcnow() + timedelta(hours=1000),
        "application_id": application["id"],
        "jti": urlsafe_b64encode(os.urandom(64)).decode('utf-8')
    }

    if acl is None:
        payload['acl'] = {'paths': {'/**': {}}}
    else:
        payload['acl'] = acl

    # generate our token signed with this private key...
    admin_token = jwt.encode(
        claims=payload,
        key=application["keys"]["private_key"],
        algorithm='RS256')

    print("Admin token is: {0}".format(admin_token))

    return admin_token


# ===============================================================================================
def create_user(admin_token, user_name):
    header = {
        "Content-type": "application/json",
        "Authorization": "Bearer {0}".format(admin_token)
    }
    params = {
        "name": user_name
    }
    return requests.post(url=gConfig.CS_URL + '/users', data=json.dumps(params), headers=header)


# ===============================================================================================
def create_default_conversation(token):
    header = {
        "Content-type": "application/json",
        "Authorization": "Bearer {0}".format(token)
    }
    return requests.post(url=gConfig.CS_URL + '/conversations', data=None, headers=header)


# ===============================================================================================
def create_user_token(application_id, private_key, user_name, algorithm='RS256', ttl_in_hours=1000, acl=None):
    """ mints a JWT token
    developer: john.rickwood and nikola.shekerev
    @param application_id: the id of the application the token will be used for
    @param private_key: the private key of the applicaiton
    @param algorithm: algorithm to be used, must be the same as what the application says it uses
    @param ttl_in_hours: time to live in hours
    @param sub: user name
    :return the JWT
    """
    if acl is None:
        acl = {'paths': {'/**': {}}}

    payload = {
        # issued at 3 seconds earlier fo avoid server delay
        "iat": int(time.time()) - 3,
        "nbf": int(time.time()) - 3,
        "iss": "QA",
        "sub": user_name,
        'exp': datetime.utcnow() + timedelta(hours=ttl_in_hours),
        "application_id": application_id,
        "jti": urlsafe_b64encode(os.urandom(64)).decode('utf-8'),
        "acl": acl
    }

    # generate our token signed with this private key...
    token = jwt.encode(
        claims=payload,
        key=private_key,
        algorithm=algorithm)
    print("our token is: {0}".format(token))

    return token


# ===============================================================================================
if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("Expected arguments, base NPE URLs")
        exit(-1)

    baseUrl = str(sys.argv[1])

    gConfig.DEVAPI_HOST = 'http://core1.'+ baseUrl +'.npe'
    gConfig.DEVAPI_URL = 'http://core1.'+ baseUrl +'.npe:8280/beta'
    gConfig.CS_URL = 'http://lb1.'+baseUrl+'.npe:5200/v1'

    application = create_account_and_application()
    print("==========================================================================")
    print(application)
    print("==========================================================================")

    token = createAdminToken(application)
    print("==========================================================================")
    print(token)
    print("==========================================================================")

    users_name = ["user1", "user2", "user3"]

    for user_n in users_name:
        user = create_user(token, user_n)
        print("==========================================================================")
        print(user)
        print("==========================================================================")

        user_token = create_user_token(application["id"], application["keys"]["private_key"], user_name=user_n)
        print("==========================================================================")
        print(user_token)
        print("==========================================================================")

    conversation = create_default_conversation(token)
    print("==========================================================================")
    print(conversation)
    print("==========================================================================")
