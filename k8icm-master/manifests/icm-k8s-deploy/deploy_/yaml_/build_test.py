#! /usr/bin/python
# -*- coding: utf-8 -*-
from jinja2 import Environment, FileSystemLoader
import ConfigParser
import os
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

tamplate_dir = './templates'
output_dir = './output/'
config_file = "config"


class Config(object):
    # def __init__(self, values):
    #     self.values = 0

    def load_config(self, app_name='ibase'):
        cf = ConfigParser.ConfigParser()
        cf.read(config_file)
        return cf.items(app_name)


if __name__ == '__main__':
    config = Config()
    config.load_config('ibase')
