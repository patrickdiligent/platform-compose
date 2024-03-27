import http.client
import json
import ssl
import urllib.parse

platformDomain = "platform.example.com"
platformUrl  =f"https://{platformDomain}"

conn = None
accessToken = None

def getAccessToken():
    return accessToken

def getConn():
    return conn

def authenticate():
    global conn
    global accessToken

    conn = http.client.HTTPSConnection(platformDomain, context = ssl._create_unverified_context())

    payload = json.dumps({})

    headers = {
        'Content-Type':'application/json',
        'X-OpenAM-Username':'amadmin',
        'X-OpenAM-Password':'password',
        'Accept-API-Version':'resource=2.0, protocol=1.0',
    }

    getConn().request("POST","/am/json/realms/root/authenticate", payload, headers)
    res = getConn().getresponse()
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

    getConn().request("POST", "/am/oauth2/realms/root/authorize", body, headers)
    res1 = getConn().getresponse()

    if res1.status != 302:
        print(f"Error issuing authorize call, not getting redirection, status = {res.status}")
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

    getConn().request("POST", "/am/oauth2/realms/root/access_token", body, headers)
    res2 = getConn().getresponse()
    data = json.loads(res2.read())

    accessToken = data['access_token']
    print(f"access_token : {accessToken}")

    return accessToken    

def queryManaged(type, filter = "true", fields = None):
    url = f"/openidm/managed/{type}"
    payload = ''
    headers = {
        'Authorization': f'Bearer {getAccessToken()}'
    }
    queryString = f"_queryFilter={filter}"
    if fields is not None:
        queryString = f"{queryString}&_fields={fields}"
    
    getConn().request("GET", f"{url}?{queryString}", payload, headers)
    res = getConn().getresponse()
    if res.status > 200:
        print(f"Error: {res.status}, {res.reason}")
        return None
    data = json.loads(res.read())
    if data['resultCount'] == 0:
        return None
    else:
        return data["result"]

def readManaged(type, id, fields = None):
    headers = {
        'Authorization': f'Bearer {getAccessToken()}'
    }
    url = f"/openidm/managed/{type}/{id}"
    if fields is not None:
        url = f"{url}?_fields={fields}"
        getConn().request("GET", url, '', headers)
        res = getConn().getresponse()
        return json.loads(res.read())

def patchManaged(type, id, payload):
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {getAccessToken()}'
    }
    getConn().request("PATCH", f"/openidm/managed/{type}/{id}", payload, headers)
    res = getConn().getresponse()
    return json.loads(res.read())

def createManaged(type, payload):
    url = f"/openidm/managed/{type}?_action=create"
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {getAccessToken()}'
    }
    getConn().request("POST", url, json.dumps(payload), headers)
    res = getConn().getresponse()
    return json.loads(res.read())