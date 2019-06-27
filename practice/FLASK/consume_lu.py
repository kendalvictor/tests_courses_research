# Load libraries
import requests
import json
import base64

from PIL import Image
from os.path import join
from io import BytesIO

url = "http://deployments.lumenaisuite.com/p112-onboardingperu/carwith8888/v17/predict"

# Image path
image_path = '/home/kendal/Pictures/AAAGHJX.jpeg'

# Prepare image
im = Image.open(image_path)
buffered = BytesIO()
im.save(buffered, format="JPEG")
data = base64.b64encode(buffered.getvalue())

# Send post request
headers = {
    'content-type': "application/image",
    'authorization': "df2f9e0c49884d1ea38ecb39e826cfa5",
    'cache-control': "no-cache",
}

print(type(data))
response = requests.request("POST", url, headers=headers, data=data)
print(response.text)

