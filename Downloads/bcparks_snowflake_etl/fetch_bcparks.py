import requests
import json

url = "https://bcparks.api.gov.bc.ca/api/park-facilities?pagination[limit]=-1"
response = requests.get(url)

if response.status_code == 200:
    with open("facilities.json", "w") as f:
        json.dump(response.json(), f, indent=2)
    print("Saved to facilities.json")
else:
    print("Request failed:", response.status_code)
