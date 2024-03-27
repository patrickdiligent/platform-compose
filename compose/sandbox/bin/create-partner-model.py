#!/usr/local/bin/python3

import http.client
import json
import ssl
import urllib.parse
from random import seed
from random import randint
from random import choice
from copy import copy
from faker import Faker

platformDomain = "platform.example.com"
platformUrl  =f"https://{platformDomain}"

conn = http.client.HTTPSConnection(platformDomain, context = ssl._create_unverified_context())

APPLICATIONS = [ 'Application-1', 'Application-2', 'Application-3' ]

USERGOUPS = [
     ['UserGroup-1','userrole1'],
     ['UserGroup-1-1','userrole1'],
     ['UserGroup-2','userrole2'],
     ['UserGroup-3','userrole3'],
     ['UserGroup-4','userrole4'],
     ['UserGroup-5','userrole5'],
     ['UserGroup-6','userrole6'],
     ['UserGroup-7','userrole7'],
     ['UserGroup-8','userrole8'],
     ['UserGroup-9','userrole9'],
     ['UserGroup-11','userrole11'],
     ['UserGroup-14','userrole14'],
]
nb_usergroups = len(USERGOUPS)

TESTUSERS = [
    'test1',
    'test2',
    'test3',
    'test4',
    'test5'
]

accessToken = None

def authenticate():
    
    payload = json.dumps({})

    headers = {
        'Content-Type':'application/json',
        'X-OpenAM-Username':'amadmin',
        'X-OpenAM-Password':'password',
        'Accept-API-Version':'resource=2.0, protocol=1.0',
    }

    conn.request("POST","/am/json/realms/root/authenticate", payload, headers)
    res = conn.getresponse()
    data = res.read()
    content = json.loads(data)
    tokenId = content["tokenId"]

    print(f"tokenId: {tokenId}")

    payload = {
        "grant_type": "authorization_code",
        "redirect_uri": f"{platformUrl}/admin/sessionCheck.html",
        "client_id": "idm-admin-ui",
        "scope": "openid fr:idm:*",
        "response_type": "code",
        "decision": "allow",
        "csrf": tokenId,
        "state": "123abc"
    }

    body = urllib.parse.urlencode(payload)

    headers = {
        'Cookie': f'iPlanetDirectoryPro={tokenId}',
        "Content-Type": "application/x-www-form-urlencoded"
    }

    conn.request("POST", "/am/oauth2/realms/root/authorize", body, headers)
    res1 = conn.getresponse()

    if res1.status != 302:
        print(f"Error issuing authorize call, not getting redirection, satus = {res.status}")
        data = res1.read()
        print(data)
        exit()

    res1.read()
    locationUrl = res1.headers['Location']
    resQuery = urllib.parse.urlparse(locationUrl).query
    resQueryDict = urllib.parse.parse_qs(resQuery)
    code = resQueryDict['code'][0]

    if code == None:
        print("Error!! Code i null")
        exit()

    print(f"code: {code}")

    payload = {
        "grant_type":"authorization_code",
        "client_id":"idm-admin-ui",
        "redirect_uri" : f"{platformUrl}/admin/sessionCheck.html"
    }

    body = f'{urllib.parse.urlencode(payload)}&code={code}'
    headers = {
        "Content-Type": "application/x-www-form-urlencoded"
    }

    conn.request("POST", "/am/oauth2/realms/root/access_token", body, headers)
    res2 = conn.getresponse()
    data = json.loads(res2.read())

    accessToken = data['access_token']
    print(f"access_token : {accessToken}")

    return accessToken    

def searchManaged(type, filter, fields = None):
    url = f"/openidm/managed/{type}"
    payload = ''
    headers = {
        'Authorization': f'Bearer {accessToken}'
    }
    queryString = f"_queryFilter={filter}"
    if fields is not None:
        queryString = f"{queryString}&_fields={fields}"
    conn.request("GET", f"{url}?{queryString}", payload, headers)
    res = conn.getresponse()
    data = json.loads(res.read())
    if data['resultCount'] == 0:
        return None
    else:
        return data

def readManaged(type, id, fields = None):
    headers = {
        'Authorization': f'Bearer {accessToken}'
    }
    url = f"/openidm/managed/{type}/{id}"
    if fields is not None:
        url = f"{url}?_fields={fields}"
        conn.request("GET", url, '', headers)
        res = conn.getresponse()
        return json.loads(res.read())

def patchManaged(type, id, payload):
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {accessToken}'
    }
    conn.request("PATCH", f"/openidm/managed/{type}/{id}", payload, headers)
    res = conn.getresponse()
    return json.loads(res.read())

def createManaged(type, payload):
    url = f"/openidm/managed/{type}?_action=create"
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {accessToken}'
    }
    conn.request("POST", url, payload, headers)
    res = conn.getresponse()
    return json.loads(res.read())

def createApplications():
    appsToCreate = []
    for app in APPLICATIONS:
        data = searchManaged("partnerapplication", f"name+eq+%22{app}%22")
        if data is None:
            appsToCreate.append(app)

    print(f"apps to create: {appsToCreate}")

    for app in appsToCreate:
        payload = json.dumps({
            "name": app
        })
        data = createManaged("partnerapplication", payload)
        print(data)


def createUsergroups():
    groupsToCreate = []
    for group in USERGOUPS:
        data = searchManaged("usergroup", f"name+eq+%22{group[0]}%22")
        if data is None:
            groupsToCreate.append(group)
    
    print(f"groupsToCreate: {groupsToCreate}")

    for group in groupsToCreate:
        payload = json.dumps({
            "name": group[0],
            "userrole": group[1]
        })
        data = createManaged("usergroup", payload)
        print(data)

def getUsergroupId(name):
    data = searchManaged("usergroup", f"name+eq+%22{name}%22")
    return data['result'][0]['_id']

def addGroupsToApp(app_id, _usergroups):
    x = randint(0, nb_usergroups)
    for i in range(x):
        usergroup = choice(_usergroups)
        print(usergroup)
        _usergroups.remove(usergroup)
        id = getUsergroupId(usergroup[0])
        payload = json.dumps([
            {
                "operation": "add",
                "value":  { "_ref" : f"managed/usergroup/{id}"},
                "field": "/usergroups/-"
            }
        ])
        data = patchManaged("partnerapplication", app_id, payload)
        print(data)
    print("---")

def assignGroupsToApplications():
    _usergroups = copy(USERGOUPS)
    data = searchManaged("partnerapplication", "true", "effectiveUsergroups")
    for value in data["result"]:
        groups = value['effectiveUsergroups']
        if not groups:
            addGroupsToApp(value['_id'], _usergroups)

def assignGroupsToTestUsers():
    for username in TESTUSERS:
        _usergroups = copy(USERGOUPS)
        data = searchManaged("user", f"userName+eq+%22{username}%22", "usergroups")
        user_id  = data['result'][0]['_id']
        if not data['result'][0]['usergroups']:
            x = randint(0, nb_usergroups)
            for i in range(x):
                usergroup = choice(_usergroups)
                print(usergroup)
                _usergroups.remove(usergroup)
                id = getUsergroupId(usergroup[0])
                payload = json.dumps([
                    {
                        "operation": "add",
                        "value":  { "_ref" : f"managed/usergroup/{id}"},
                        "field": "/usergroups/-"
                    }
                ])
                data = patchManaged("user", user_id, payload)


def createTestUsers():
    usersToCreate = []
    fake = Faker()
    for username in TESTUSERS:
        data = searchManaged("user", f"userName+eq+%22{username}%22")
        if data is None:
            usersToCreate.append(username)
    
    print(f"usersToCreate: {usersToCreate}")

    for username in usersToCreate:
        payload = json.dumps({
            "userName": username,
            "givenName" : fake.first_name(),
            "mail": fake.email(),
            "sn": fake.last_name(),
            "password" : "P@ssw0rd"
        })
        data = createManaged("user", payload)
        print(data)

accessToken = authenticate()
exit()
createApplications()
createUsergroups()
assignGroupsToApplications()
createTestUsers()
assignGroupsToTestUsers()