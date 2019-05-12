# coding=utf-8
import requests
from datetime import datetime
import csv
from os import path
from urllib.parse import urljoin
import re
import time
import sys
import random
from threading import Thread
import logging

from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import WebDriverException
from selenium.webdriver import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from requests.auth import HTTPBasicAuth

BASE_DIR = path.dirname(path.abspath(__file__))
sys.path.append(BASE_DIR)


users_agents = [
    "Mozilla/5.0 (Linux; Android 4.2.1; en-us; Nexus 5 Build/JOP40D) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19"
]

mobile_emulation = {
    "deviceMetrics": {"width": 1080, "height": 980, "pixelRatio": 3.0},
    "userAgent": random.choice(users_agents)
}

chrome_options = Options()
chrome_options.add_experimental_option("mobileEmulation", mobile_emulation)

driver = webdriver.Chrome(
    chrome_options=chrome_options
)


def login_init():
    url = 'http://bit.ly/2XZk2NH'
    driver.get(url)
    time.sleep(1)

    driver.execute_script("""
        document.getElementById("nombres").value = "LEONELA TACURE PURIZACA";
        document.getElementById("num_documento").value = "45169538";
        document.getElementById("correo").value = "leonela.tp@gmail.com";
        document.getElementById("celular").value = "944348973";
        document.getElementById("centro_trabajo").value = "MUNICIPALIDAD DE LURIN";
        document.getElementById("cargo").value = "ANALISTA DE CUENTAS";
        document.getElementById("datos").click();
        document.getElementById("button").click();
    """)

while True:
    login_init()