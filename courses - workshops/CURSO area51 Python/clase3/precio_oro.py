import requests
from bs4 import BeautifulSoup
import pytesseract
from PIL import Image

url_base = "http://www.kitco.com/"
headers = {
	'User-Agent':'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36'
}

response = requests.get(url_base, headers=headers)

if response.status_code == 200:
    soup = BeautifulSoup(response.content, 'html.parser')
    response.close()
else:
    raise Exception(response.reason)

oro_min = soup.find("span", {'id': 'AU-low'}).text
oro_max = soup.find("span", {'id': 'AU-high'}).text

print("Valor del Oro actualizada: ")
print("Min: ", oro_min)
print("Max: ", oro_max)

