import requests
from bs4 import BeautifulSoup
import pytesseract
from PIL import Image

url_base = "http://e-consultaruc.sunat.gob.pe/cl-ti-itmrconsruc/"
url = url_base + "frameCriterioBusqueda.jsp"

response = requests.get(url)

if response.status_code == 200:
    soup = BeautifulSoup(response.content, 'html.parser')
    response.close()
else:
    raise Exception(response.reason)

imagen = soup.find("img").attrs
url_imagen = url_base + imagen["src"]
respuesta_img = requests.get(url_imagen)
archivo = open("captcha_2.jpg", "wb")
archivo.write(respuesta_img.content)
archivo.close()

texto_captcha = pytesseract.image_to_string(
	Image.open("captcha_2.jpg")
)
print("texto_captcha:: ", texto_captcha)
dni = 45139145
dicc = {
    'accion': 'consPorTipdoc',
    'razSoc': '',
    'nroRuc': '',
    'nrodoc': dni,
    'contexto': 'ti-it',
    'search1': '',
    'codigo': texto_captcha,
    'tQuery': 'on',
    'tipdoc': '1',
    'search2': dni,
    'coddpto': '',
    'codprov': '',
    'coddist': '',
    'search3': '',
}
headers = {
	'Accept':'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
	'Accept-Encoding':'gzip, deflate',
	'Accept-Language':'en-US,en;q=0.9',
	'Cache-Control':'max-age=0',
	'Connection':'keep-alive',
	'Content-Length':'160',
	'Content-Type':'application/x-www-form-urlencoded',
	'Cookie':'ITMRCONSRUCSESSION=YZ4Xh1wCrflzzrpthYpXm2sng53x0Mh1hhGjqSPPLgDdWmJSTnG3K32zwdqPf26hlCLQKCxRph9Tx0GK5yJBL4lhQ66zfnCl6p7kysMW4XB12Gxck4HCv3RNxgfWnRWkmxs9k21ttxXVJ9hJnytpJyZ2xpTQQpt9njk1tz9nkQVVnPN8p12DGGLLjnRzQqLHb1Wyv0wfL58l1dX9k6YMnCHRL0v71p51vxp2zMv3WpL6k09QSg3DBnCDwHN3lMfV!-828738521!1240425142',
	'Host':'e-consultaruc.sunat.gob.pe',
	'Origin':'http://e-consultaruc.sunat.gob.pe',
	'Referer':'http://e-consultaruc.sunat.gob.pe/cl-ti-itmrconsruc/frameCriterioBusqueda.jsp',
	'Upgrade-Insecure-Requests':'1',
	'User-Agent':'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36'
}

url_consulta = url_base + "jcrS00Alias"

response_consulta_2 = requests.get(url_consulta, data=dicc, headers=headers)
print(response_consulta_2.content)

print("@@@@@@@@@@@@@@@@@")

ss = requests.Session()
response_consulta = ss.get(url_consulta, data=dicc, headers=headers)
print(response_consulta.content)

print("////////////////")
response_other = requests.request("GET", url, headers=headers, params=dicc)
print(response_other.content)











