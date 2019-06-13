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
    executable_path='/home/rmg/STORAGE/tests_courses/teaching/PythonQACOmercio/chromedriver',
    chrome_options=chrome_options
)


def login_init():
    time.sleep(5)
    url = 'https://qa.elbocon.pe/cms-epensa/adm/'
    driver.get(url)
    time.sleep(1)

    driver.execute_script("""
        document.getElementById("id_username").value = "admin";
        document.getElementById("id_password").value = "admin";
        document.getElementsByClassName("btn-info")[0].click(); 
    """)


def acces_qa_cms():
    #driver.refresh()
    #driver.delete_all_cookies()
    #driver.set_page_load_timeout(60)
    trunc = random.choice(range(100, 1000))
    url = 'https://qa.elbocon.pe/cms-epensa/adm/dragonfly/article/{}/'.format(trunc)
    driver.get(url)
    time.sleep(1)
    driver.execute_script("""
        document.querySelectorAll(".datetime > .datetimeshortcuts > a")[0].click();
        document.querySelectorAll(".datetime > .datetimeshortcuts > a")[2].click();
        document.querySelectorAll(".datetime > .datetimeshortcuts > a")[0].click();
        document.querySelectorAll(".datetime > .datetimeshortcuts > a")[2].click();
        document.getElementsByClassName("btn-high")[0].click();
    """)
    try:
        driver.execute_script("""
            document.getElementsByClassName("btn-success")[0].click(); 
        """)
        driver.get(url)
    except Exception as e:
        print("Error de confirmacion :: ", str(e))


    driver.execute_script("""
        document.getElementsByClassName("viewsitelink")[0].click();
    """)

    for _ in range(15):
        driver.refresh()
    
    time.sleep(5)
    print("BUSQUEDA REALIZADA")







login_init()

while True:
    acces_qa_cms()
