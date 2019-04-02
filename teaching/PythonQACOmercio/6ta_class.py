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


BASE_DIR = path.dirname(path.abspath(__file__))
sys.path.append(BASE_DIR)


users_agents = [
    "Mozilla/5.0 (Linux; Android 4.2.1; en-us; Nexus 5 Build/JOP40D) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19"
]

mobile_emulation = {
    "deviceMetrics": {"width": 1080, "height": 500, "pixelRatio": 3.0},
    "userAgent": random.choice(users_agents)
}

chrome_options = Options()
# chrome_options.add_experimental_option("mobileEmulation", mobile_emulation)
driver = webdriver.Chrome(
    executable_path='/home/rmg/STORAGE/tests_courses/teaching/PythonQACOmercio/chromedriver',
    chrome_options=chrome_options
)


def create_article():
    wait = WebDriverWait(driver, 10)
    #element = wait.until(EC.element_to_be_clickable((By.XPATH, '//form[@id="login-form"]/div[4]/input')))
    #print(wait, type(wait))
    #print(element, type(element))

    url = 'https://qa.elshow.pe/cms-epensa/adm/dragonfly/article/add/'
    driver.get(url)
    driver.implicitly_wait(10)
    time.sleep(1)

    driver.find_element(By.ID, 'id_username').send_keys('admin')
    driver.find_element(By.ID, 'id_password').send_keys('admin')
    driver.find_element(By.CLASS_NAME, 'btn-info').click()

    time.sleep(1)
    driver.find_element(By.ID, 'id_title').send_keys('admin crawlerhhknknknhk')
    driver.find_element(By.ID, 'id_short_title').send_keys('admin crawler')
    driver.find_element(By.ID, 'id_slug').send_keys('admin-crawler')
    driver.find_element(By.ID, 'id_summary').send_keys('admin crawler')

    ## pp.send_keys()
    contenido_nota = 'Este es el cuerpo de mi nota'
    pp = driver.find_element(
        By.XPATH, '//form[@id="_form"]/div[2]/div/fieldset[1]/div[5]/div/div[2]/div/div/p'
    )

    actions = ActionChains(driver)
    actions.move_to_element(pp)
    actions.click()
    actions.send_keys(contenido_nota)
    actions.perform()

    driver.find_element(By.XPATH, '//*[@id="articlenode_set-group"]/div/fieldset/table/tbody/tr[2]/td/a').click()


    # Select Node
    selec_1 = driver.find_element(By.XPATH, '//*[@id="id_articlenode_set-0-node"]')
    selec_1.click()

    selec_1 = Select(selec_1)

    all_options = [o.get_attribute('value') for o in selec_1.options if o.get_attribute('value')]
    print(all_options)

    elems = get_qualification(selec_1, all_options, wait)
    print("elems : ", elems)
    elems.click()
    #selec_2 = Select(selec_2)
    #all_options = [o.get_attribute('value') for o in selec_2.options if o.get_attribute('value')]
    #print(all_options)
    #selec_2.select_by_value(random.choice(all_options))

    driver.find_element(By.XPATH, '//*[@id="id_articlenode_set-0-is_principal"]').click()

    # GRABAR
    driver.find_element(By.XPATH, '//form[@id="_form"]/div[1]/div/div/button[1]').click()


def get_qualification(selec_1, all_options, wait):
    val = random.choice(all_options)
    selec_1.select_by_value(val)

    time.sleep(1)
    try:
        selec_2 = driver.find_element(By.XPATH, '//*[@id="id_articlenode_set-0-qualification"]')
        selec_2.click()

        elems = wait.until(
            EC.element_to_be_clickable(
                (By.XPATH, '//*[@id="id_articlenode_set-0-qualification"]/option[@value="standard"]'))
        )
        return elems
    except:
        all_options.remove(val)
        return get_qualification(selec_1, all_options, wait)





create_article()