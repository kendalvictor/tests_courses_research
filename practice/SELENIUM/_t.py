import os
import re
import string
import time
import glob
from datetime import datetime, timedelta

 
from PIL import Image
from slugify import slugify
import cv2
import pytesseract
import pandas as pd
import unicodedata
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import Select
from selenium.webdriver.common.by import By
from sqlalchemy import create_engine
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


 


class SunatCrawler(object):
    def __init__(self):
        self.hoy = datetime.today()
        self.ruc = 0
        #self.hoy = datetime(2020, 5, 22, 13, 0, 0)
        self.hoy_format = self.hoy.strftime('%d/%m/%Y')
        self.ayer = self.hoy - timedelta(days=1)  #ayer
        self.ayer_format = self.ayer.strftime('%d/%m/%Y')
        headless = False
        user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36'
        
        #self.engine = create_engine("mysql://jquiza:7841wQnGTO1CovvE@108.59.81.200:3306/ibk_business_account")
        #self.connection = self.engine.connect()
        self.current_path = os.getcwd()
        
        options = Options()
        options.add_argument("--incognito")
        options.add_argument('--no-proxy-server')
        options.add_argument('user-agent={}'.format(user_agent))
        #ptions.add_argument("--disable-web-security")
        #options.add_argument("--no-sandbox")
        
        if headless:
            options.add_argument("--disable-notifications")
            options.add_argument('--no-sandbox')
            options.add_argument('--verbose')
            options.add_argument('--disable-gpu')
            options.add_argument('--disable-software-rasterizer')
            options.add_argument('--headless')
            options.add_argument("--disable-web-security")
            options.add_argument("--allow-running-insecure-content")
            options.add_argument("--allow-cross-origin-auth-prompt")
            options.add_argument("--disable-cookie-encryption")
            options.add_argument('--user-data-dir={}'.format(os.path.join(self.current_path, 'data')))
            options.add_argument('--data-path={}'.format(os.path.join(self.current_path, 'data')))
            options.add_argument('--homedir={}'.format(os.path.join(self.current_path, 'data')))
            options.add_argument('--disk-cache-dir={}'.format(os.path.join(self.current_path, 'data')))
        
        options.add_experimental_option("prefs", {
            "download.default_directory": r"{0}".format(self.current_path),
            "download.prompt_for_download": False,
            "download.directory_upgrade": True,
            "safebrowsing.enabled": True
        })
        #"safebrowsing.disable_download_protection": True
        
        self.driver_path = os.path.join(self.current_path, 'utils', 'chromedriver')
        self.url = "https://e-consultaruc.sunat.gob.pe/cl-ti-itmrconsruc/jcrS00Alias"
        self.driver = webdriver.Chrome(self.driver_path, options=options)
        self.driver.implicitly_wait(20)
        print("--DRIVER INICIALIZADO")

        if headless:
            self.enable_download_in_headless_chrome()

 

    
    def enable_download_in_headless_chrome(self):
        # add missing support for chrome "send_command"  to selenium webdriver
        self.driver.command_executor._commands["send_command"] = ("POST", '/session/$sessionId/chromium/send_command')

 

        params = {'cmd': 'Page.setDownloadBehavior', 'params': {'behavior': 'allow', 'downloadPath': self.current_path}}
        self.driver.execute("send_command", params)
        
        
    def close(self):
        self.driver.close()
    
    @staticmethod
    def clean_csv_old_related(sufijo='REACTIVA_PERU_'):
        for csvname in glob.iglob('**/*{}*.csv'.format(sufijo), recursive=True):
            print(csvname)
            os.system("del /f {0}".format(csvname))

 

    @staticmethod
    def get_csv_name_reactiva(sufijo='REACTIVA_PERU_'):
        return [_ for _ in glob.iglob('**/*{}*.csv'.format(sufijo), recursive=True)]
        
    def page_load(self):
        print("****LOAD PAGE*****")
        self.driver.get(self.url)
        time.sleep(2)
    
    def page_session(self):
        print("****PAGE SESSION*****")
        
        dd = self.driver.find_element_by_name("search1")
        dd.send_keys(str(self.ruc))
        try:
            WebDriverWait(self.driver, 15).until(EC.text_to_be_present_in_element_value((By.NAME, "search1"), self.ruc))
            time.sleep(5)
        except:
            print("/"*100)
            #             document.getElementsByName("search1")[0].value = {}
            self.driver.execute_script("""
                document.querySelector("#s1 > input").value = {}
            """.format(
                self.ruc
            ))
            print("="*100)
        WebDriverWait(self.driver, 5).until(EC.presence_of_element_located((By.NAME, "imagen")))

        self.driver.save_screenshot("screenshot.png")
        img = Image.open('screenshot.png')

        ancho = img.size[0]
        alto = img.size[1]
        img_recortada = img.crop((ancho/1.8, alto/5, ancho/1.3, alto/3.2))
        img_recortada.save("recorte1.png")
        
        originalImage = cv2.imread("recorte1.png")
        grayImage = cv2.cvtColor(originalImage, cv2.COLOR_BGR2GRAY)
        
        captcha = pytesseract.image_to_string(grayImage)
        
        print("RECORTE GUARDADO: ", captcha)
        if len(captcha) < 4:
            raise Exception("Deteccion corta")
        
        self.driver.execute_script("""
            document.getElementsByName("codigo")[0].value = '{}'
            document.getElementsByClassName("form-button")[0].click()
        """.format(
            captcha
        ))
        time.sleep(2)
        
        
    def page_scrap(self):
        print("****PAGE CRAWLER SUNAR PERU*****")
        _dicc = {}
        #Esperamos que se cargue la tabla de resultados
        WebDriverWait(self.driver, 15).until(EC.presence_of_element_located((By.CLASS_NAME, "form-table")))
        #Obtenemos el enlace que contiene al RUC
        list_data = [_ for _ in self.driver.find_elements(By.TAG_NAME, "tr")]
        
        
        for ii, row in enumerate(list_data[5: 18]):
            print(ii)
            try:
                llave = slugify(row.find_element(By.CLASS_NAME, "bgn").text.strip().replace(':', ''))
                valor = row.find_element(By.CLASS_NAME, "bg").text.strip().replace(':', '')
                _dicc[llave] = valor
            except Exception as e:
                print("EXCEPTION: ", str(e))
            print(ii)
    
        return _dicc 
    
    def run(self, ruc):
        self.ruc = ruc
        self.page_load()
        self.page_session()
        #data = self.page_scrap()
        #self.driver.close()
        return ruc


if __name__ == '__main__':
    rc = SunatCrawler()
    rc.run()
