import os
import re
import string
import time
import glob
from datetime import datetime, timedelta

 

import pandas as pd
import unicodedata
from pyspark.sql.types import *
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import Select
from selenium.webdriver.common.by import By
from sqlalchemy import create_engine
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

 


class ReactivaCrawler(object):
    def __init__(self):
        self.hoy = datetime.today()
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

 

 

        options.add_experimental_option("prefs", {
            "download.default_directory": r"{0}".format(self.current_path),
            "download.prompt_for_download": False,
            "download.directory_upgrade": True,
            "safebrowsing.enabled": True
        })
        #           "safebrowsing.disable_download_protection": True
        
        self.driver_path = os.path.join(self.current_path, 'utils', 'chromedriver.exe')
        path = 'http://10.11.9.180:9080/group/control_panel/manage'
        quey_params = {
            'p_p_id': 'reportedinamico_WAR_halconreportedinamicoportlet',
            'p_p_lifecycle': '0',
            'p_p_state': 'maximized',
            'p_p_mode': 'view',
            'doAsGroupId': '20182',
            'refererPlid': '40063',
            'controlPanelCategory': 'current_site.content'
        }
        
        self.url = path + '?' + '&'.join([k + '=' + v for k, v in quey_params.items()])               
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
        
        WebDriverWait(self.driver, 15).until(
            EC.presence_of_element_located((By.ID, "_58_login"))
        )
        self.driver.execute_script("""
            document.getElementById("{}").value = "{}";
            document.getElementById("{}").value = "{}";
            document.querySelector("{}").click();
        """.format(
            '_58_login', 'pvalerot', '_58_password', 'JY7_auvGGbjLG7',
            '#_58_fm > fieldset > div > button'
        ))
        
    def page_scrap_reactiva_peru(self):
        
        print("****PAGE CRAWLER REACTIVA PERU*****")
        
        select_1 = WebDriverWait(self.driver, 15).until(
            EC.presence_of_element_located((By.ID, "_reportedinamico_WAR_halconreportedinamicoportlet_cboTipoFormulario"))
        )
        select_1.click()
        select_ = Select(select_1)
        select_.select_by_value('57')
        
        self.driver.execute_script("""
            document.getElementById("{}").value = "{}";
            document.getElementById("{}").value = "{}";
        """.format(
            '_reportedinamico_WAR_halconreportedinamicoportlet_txtFechaInicio',
            self.ayer_format,
            '_reportedinamico_WAR_halconreportedinamicoportlet_txtFechaFin',
            self.hoy_format
        ))
        time.sleep(2)
        
        self.driver.execute_script("""
            document.getElementById("{}").click();
        """.format( 'btnExportar'))
        time.sleep(15)
 