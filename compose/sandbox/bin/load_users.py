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

import common

# userName, sn, firstName, mail required
#  then read list of usergroups, assign randomly

numberOfUsers = 500

accessToken = common.authenticate()
usergroups = common.queryManaged("usergroup")

if usergroups is None:
    print("There are no usergroups yet, please reconcile")
    exit()

print(f"retrieved {len(usergroups)} user groups")

fake = Faker()

for k in range(numberOfUsers):
    print(k)
    firstName = fake.first_name()
    lastName = fake.last_name()
    userName = f"{firstName}.{lastName}"
    mail = f"{userName}@example.com"
    payload = {
        "userName": userName,
        "sn": lastName,
        "givenName": firstName,
        "mail": mail
    }

    x = randint(1, 5)
    _usergroups = copy(usergroups)
    assigningGroups = []
    for j in range(x):
        usergroup = choice(_usergroups)
        _usergroups.remove(usergroup)
        assigningGroups.append({ "_ref": f'managed/usergroup/{usergroup["_id"]}' })
    
    payload["userGroups"] = assigningGroups
    print(payload)
    common.createManaged("user", payload)

print(f"Created {numberOfUsers} users")