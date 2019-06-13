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
from selenium.webdriver.common.keys import Keys
from requests.auth import HTTPBasicAuth
from selenium.webdriver.support.ui import Select
from slugify import slugify


BASE_DIR = path.dirname(path.abspath(__file__))
sys.path.append(BASE_DIR)


users_agents = [
    "Mozilla/5.0 (Linux; Android 4.2.1; en-us; Nexus 5 Build/JOP40D) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19"
]

mobile_emulation = {
    "deviceMetrics": {"width": 700, "height": 700, "pixelRatio": 3.0},
    "userAgent": random.choice(users_agents)
}

chrome_options = Options()
chrome_options.add_experimental_option("mobileEmulation", mobile_emulation)
driver = webdriver.Chrome(
    executable_path='/home/villacorta/STORAGE/tests_courses_research/practice/SELENIUM/chromedriver',
    chrome_options=chrome_options
)



def init_sbs():
    wait = WebDriverWait(driver, 10)
    time.sleep(1)

    domain = 'http://www.sbs.gob.pe'
    path_main = '/estadisticas-y-publicaciones/estadisticas-/sistema-financiero_'
    url_main = urljoin(domain, path_main)

    # Ingreso al link inicial
    driver.get(url_main)
    driver.implicitly_wait(10)
    driver.set_window_size(700, 700)

    # Ingreso al iframe con contenido real
    link_iframe_app = driver.find_element(
        By.XPATH,
         '//*[@id="dnn_ctr12814_HtmlModule_lblContent"]/div/p/iframe'
    ).get_attribute('src')
    driver.get(link_iframe_app)

    # Deteccion de enlaces segun tipo

    links = driver.find_elements(By.CLASS_NAME, 'sistema-privado-pensiones__item__content__link')
    for link in links:
        if 'ver-' in slugify(link.text):
            link.click()
         

    dicc_links = {}
    bodies = driver.find_elements(By.CLASS_NAME, 'sistema-privado-pensiones__item__body')

    for body_data in bodies:
        title = slugify(
            body_data.find_element(By.CLASS_NAME, 'sistema-privado-pensiones__item__title').text or ''
        )
        link = body_data.find_element(
            By.CLASS_NAME, 'sistema-privado-pensiones__item__content__link'
        )
        if 'ver-' not in slugify(link.text) and 'presentacion'not in title:
            print(title, link.get_attribute('href'))
            dicc_links[title] = link.get_attribute('href')


    #########################
    SCROLL_BY_ADVANCED = 250
    last_height = driver.execute_script("return document.body.offsetHeight;")
    window_height = driver.execute_script("return window.innerHeight + scrollY;")

    while True:
        time.sleep(1)
        driver.execute_script("window.scrollBy(0, {0})".format(
            SCROLL_BY_ADVANCED))

        last_height = driver.execute_script("return document.body.offsetHeight;")
        if window_height >= last_height:
            break

        window_height += SCROLL_BY_ADVANCED
    #########################
    
    # Recorrido de los links
    for title, link in dicc_links.items():
        driver.get(link)
        driver.implicitly_wait(10)
        time.sleep(1)

        # OPEN TABS
        vinetas_0 = driver.find_elements(By.CLASS_NAME, 'MEN01_vineta_0_OUT')
        for vineta in vinetas_0:
            try:
                vineta.click()
            except:
                pass


        vinetas_1 = driver.find_elements(By.CLASS_NAME, 'MEN01_vineta_1_OUT')
        for subvineta in vinetas_1:
            try:
                subvineta.click()
                driver.execute_script(
                    "window.scrollBy(0, {0})".format(SCROLL_BY_ADVANCED)
                )
                print(subvineta.text)
                time.sleep(2)
            except:
                continue

        # CLOSE TABS
        for vineta in vinetas_0:
            try:
                vineta.click()
            except:
                continue

    print("FINISH")

init_sbs()