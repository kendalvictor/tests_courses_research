import requests

def get_metrics(apikey, host, limit):
	url = "http://api.chartbeat.com/live/toppages/v3/"

	querystring = {
		"host": host,
		"apikey": apikey,
		"limit": limit
	}

	headers = {
	    'cache-control': "no-cache",
	}

	response = requests.request(
		"GET", url, headers=headers, params=querystring
	)

	print("response.status_code: ", response.status_code)
	return response.json() if response.ok else {'status': response.status_code}



limit = 2
host = "gestion.pe"
apikey = "094d70f05bf0f49f7ba8126e7ee62c76"

response_chartbeat = get_metrics(apikey, host, limit)
pages = response_chartbeat.get('pages', [])

if pages:
	for page in pages:
		host = page.get('host', '')
		name = page.get('title', '')
		sections = page.get('sections', '')
		authors = page.get('authors', '')
		path = page.get('path', '')

		print("\n Análisis: {} / {}".format(host, name))
		print(path)
		print(sections, authors, '\n')

		for k, v in page.get('stats', {}).items():
			print(k, v)
			print("-"*50)

else:
	print(
		"Error en petición, status: ", 
		response_chartbeat.get('status', 500)
	)






