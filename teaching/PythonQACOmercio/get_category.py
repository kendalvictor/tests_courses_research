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
#chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-web-security")
chrome_options.add_argument('--ignore-certificate-errors')
chrome_options.add_argument('--disable-dev-shm-usage')
chrome_options.add_argument("--no-default-browser-check")
chrome_options.add_argument('--disable-extensions')
chrome_options.add_argument('--profile-directory=Default')
chrome_options.add_argument("--incognito")
chrome_options.add_argument("--disable-plugins-discovery");
chrome_options.add_argument("--start-maximized")
#chrome_options.add_argument("--single-process")

driver = webdriver.Chrome(
    executable_path='/home/rmg/STORAGE/tests_courses/teaching/PythonQACOmercio/chromedriver',
    chrome_options=chrome_options
)

driver.delete_all_cookies()
driver.set_window_size(800,800)
driver.set_window_position(0,0)

url = 'https://tools.zvelo.com/'
driver.get(url)
driver.execute_script('window.znetvars = 1')

time.sleep(3)

web = 'facebook.com'
driver.execute_script("""
    document.getElementById("zvelo-search-input").value = "{}";
    document.getElementById("g-recaptcha-response").click();
""".format(web))


frame = driver.find_element_by_xpath('//iframe[contains(@src, "recaptcha")]')
driver.switch_to.frame(frame)
#driver.find_element_by_xpath("//*[@id='recaptcha-anchor']")
slider = driver.find_element_by_id('recaptcha-anchor')
slider.click()



print("@@@@"*30)




