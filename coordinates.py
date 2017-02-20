import csv
import pandas as pd
import sys
import requests
import time

reload(sys)
sys.setdefaultencoding('utf8')

f = csv.writer(open('coordinates.csv', 'wb'))

f.writerow(['address', 'address_1', 'lat_1', 'lng_2', 'address_2', 'lat_2', 'lng_2'])

ufo = pd.read_csv('data/testing.csv')

BING_STR = 'http://dev.virtualearth.net/REST/v1/Locations?query={},%20Los%20Angeles,%20CA&output=json&key={}'
key = 'ApmsCgK3jSH-D8Ttdbjj4yqUvHAqkNYxBG94Fc0GJis_09Cab9Co5ZyuxoqYgVIa'

#unique = pd.read_csv('unique_hundredblock_addresses.csv', header = None, names = ['original_address'])
# locations = pd.read_excel('ph-to-regeocode.xlsx')
# location file
locations = open('data/testing.csv').read().splitlines()

# open geocoded file
f = open('ph-geocoded-stores.txt','a')
g = open('ph-geocoded-stores-not-found.txt','a')

# header row
# f.write('address\tcity\tstate\tparty\tconfidence\tbingaddress\tbingcity\tlatitude\tlongitude\n')
# g.write('address\tcity\tstate\tparty\tconfidence\tbingaddress\tbingcity\tlatitude\tlongitude\n')


for location in locations[1:2]:
  print location
  items = location.split(',')
  print items
  city = items[1]
  state = items[2]
  print city
  print state
  BING_STR = 'http://dev.virtualearth.net/REST/v1/Locations/US/'+ state +'/'+ city +'/' +'?include=includeValue&maxResults=1&key=' + key

  # update without spaces
  BING_STR = BING_STR.replace(' ','%20')

  # check for any spaces and update string
  query_string = BING_STR.format(BING_STR.replace(' ','%20'), key)

  # print items
  # try string
  response = requests.get(query_string)
  # print response

  try:
    response.raise_for_status()
    response_json = response.json()print response_json

  #   if len(response_json['resourceSets'][0]['resources']) > 0:
  #     top_hit = response_json['resourceSets'][0]['resources'][0]
  #     bingAddy = top_hit['address']['addressLine']
  #     bingCity = top_hit['address']['locality']
  #     bingCoords = top_hit['point']['coordinates']
  #     bingConf = top_hit['confidence']
  #     print 'Success location for ' + location + '! ' + str(len(locations) - locations.index(location)) + ' left.'
  #   f.write(address+'\t'+city+'\t'+state+'\t'+party+'\t'+bingConf+'\t'+bingAddy+'\t'+bingCity+'\t'+str(bingCoords[0])+'\t'+str(bingCoords[1])+'\n')

  # except requests.exceptions.HTTPError:
  #   print 'HTTPError' + str(requests.exceptions.HTTPError)
  #   g.write(address+'\t'+city+'\t'+state+'\t'+party+'\n')

  # except KeyError:
  #   print 'KeyError' + str(KeyError)
  #   g.write(address+'\t'+city+'\t'+state+'\t'+party+'\n')

  # time.sleep(1)

# f.close()

# GOOGLE_KEY = "AIzaSyBOsz2G8oWsgv98fhOfxtpY0YGDT7Oudl0"
# GOOGLE_STR = "https://maps.googleapis.com/maps/api/geocode/json?address={},&key={}"

# def google_geocode(address):
#    link = GOOGLE_STR.format(address, GOOGLE_KEY)
#    try:
#        response = requests.get(link)
#        response.raise_for_status()
#        response_json = response.json()
#        if len(response_json['results']) > 0:
#            lat = response_json['results'][0]['geometry']['location']['lat']
#            lng = response_json['results'][0]['geometry']['location']['lng']
#            return {'lat':lat, 'lng':lng}
#        else:
#            return (False, False, False)
#    except:
#        return (False, False, False)


# ufo['address'] = str(ufo['city'] + ", " + ufo['state'])
# # print ufo['address']

# addresses = pd.DataFrame({'addresses': (ufo['city'] + ", " + ufo['state'])})

# print google_geocode(addresses['addresses'][0])
# print addresses['addresses'][0]

# for address in addresses['addresses']:

#   google_geocode(address)
#   # lat = google_geocode(address)['lat']
#   # lng = google_geocode(address)['lng']
#   # print lat
#   # print lng


#   print address
#   search = geocoder.get(address, region = 'US')
#   print search 
  # address = address
  # first_result = search[0]
  # print first_result
  
  # address_1 = first_result.formatted_address
  # lat_1 = first_result.geometry.location.lat
  # lng_1 = first_result.geometry.location.lng

  # try:

  #   second_result = search[1]
    
  #   address_2 = second_result.formatted_address
  #   lat_2 = second_result.geometry.location.lat
  #   lng_2 = second_result.geometry.location.lng

  # except:
  # #   continue

  #   f.writerow([address, address_1, lat_1, lng_1, address_2, lat_2, lng_2])   

   

# print search[0]
# search[0].geometry.location
# print (search[0].geometry.location.lat, search[0].geometry.location.lng)

# def google_geocode(address):
#    link = GOOGLE_STR.format(address, GOOGLE_KEY)
#    try:
#        response = requests.get(link)
#        response.raise_for_status()
#        response_json = response.json()
#        if len(response_json['results']) > 0:
#            lat = response_json['results'][0]['geometry']['location']['lat']
#            lng = response_json['results'][0]['geometry']['location']['lng']
#            return {'lat':lat, 'lng':lng}
#        else:
#            return (False, False, False)
#    except:
#        return (False, False, False)