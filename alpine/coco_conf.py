#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#

import os

BASE_DIR = os.path.dirname(__file__)


class Config:
    # 项目名称, 会用来向Jumpserver注册, 识别而已, 不能重复
    CORE_HOST = os.environ.get("CORE_HOST") or 'http://127.0.0.1:8080'

    # 启动时绑定的ip, 默认 0.0.0.0
    # BIND_HOST = '0.0.0.0'

    # 监听的SSH端口号, 默认2222
    # SSHD_PORT = 2222

    # 监听的HTTP/WS端口号，默认5000
    # HTTPD_PORT = 5000

    # 项目使用的ACCESS KEY, 默认会注册,并保存到 ACCESS_KEY_STORE中,
    # 如果有需求, 可以写到配置文件中, 格式 access_key_id:access_key_secret
    # ACCESS_KEY = None

    # ACCESS KEY 保存的地址, 默认注册后会保存到该文件中
    # ACCESS_KEY_STORE = os.path.join(BASE_DIR, 'keys', '.access_key')

    # 加密密钥
    # SECRET_KEY = None

    # 设置日志级别 ['DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL', 'CRITICAL']
    LOG_LEVEL = os.environ.get("LOG_LEVEL") or 'DEBUG'

    # 日志存放的目录
    # LOG_DIR = os.path.join(BASE_DIR, 'logs')

    # Session录像存放目录
    # SESSION_DIR = os.path.join(BASE_DIR, 'sessions')

    # 资产显示排序方式, ['ip', 'hostname']
    # ASSET_LIST_SORT_BY = 'ip'

    # 登录是否支持密码认证
    # SSH_PASSWORD_AUTH = True

    # 登录是否支持秘钥认证
    # SSH_PUBLIC_KEY_AUTH = True

    # 和Jumpserver 保持心跳时间间隔
    # HEARTBEAT_INTERVAL = 5

    # Admin的名字，出问题会提示给用户
    # ADMINS = 'm

    # 命令存储
    # COMMAND_STORAGE = {
    #     "TYPE": "server"
    # }


config = Config()
