#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# a: liupeng04@inspur.com
# d: 20181111

from jinja2 import Environment, FileSystemLoader
import ConfigParser
import os
import sys
import re
reload(sys)
sys.setdefaultencoding('utf-8')


tamplate_dir = './templates'
output_dir = './output/'
config_file = "config.ini"


# 读取配置
class ConfigPass(object):
    def __init__(self, cf_file=config_file):
        self.cf = ConfigParser.ConfigParser()
        self.cf.read(cf_file)

    def list_sections(self):
        sections = self.cf.sections()
        return sections

    def load_config(self, app_name):
        values = self.cf.items(app_name)
        return values


# 判断文件夹
def chk_mkdir(dirname):
    if not os.path.isdir(dirname):
        os.makedirs(dirname)


# 用jinja渲染模板生成配置文件
def render_to_file(app_name):
    env = Environment(loader=FileSystemLoader(tamplate_dir))
    tpl_list = os.listdir(tamplate_dir)
    # 渲染tpl目录下的所有模板
    for t in tpl_list:
        tpl = env.get_template(t)
        cf = ConfigPass()
        info = cf.load_config(app_name)
        output = tpl.render(info)
        t_index = t.split(".")[0]
        with open(output_dir + app_name + '-' + t_index + '.yaml', 'w') as out:
            out.write(output)


# 创建模板
def create_templates():
    chk_mkdir(output_dir)
    app_name = sys.argv[1]

    if app_name == 'all':

        for section in ConfigPass().list_sections():
            render_to_file(section)
    else:
        render_to_file(app_name)


if __name__ == "__main__":

    create_templates()
