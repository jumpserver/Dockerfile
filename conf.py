#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#

import os

BASE_DIR = os.path.dirname(__file__)


class Config:
    """
    Coco config file, coco also load config from server update setting below
    """
    # 项目名称, 会用来向Jumpserver注册, 识别而已, 不能重复
    # NAME = "localhost"

    # Jumpserver项目的url, api请求注册会使用
    CORE_HOST = os.environ.get("CORE_HOST") or 'http://127.0.0.1:8080'

    # Bootstrap Token, 预共享秘钥, 用来注册coco使用的service account和terminal
    # 请和jumpserver 配置文件中保持一致，注册完成后可以删除
    BOOTSTRAP_TOKEN = os.environ.get("BOOTSTRAP_TOKEN") or "nwv4RdXpM82LtSvmV"

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
    LOG_LEVEL = 'ERROR'

    # 日志存放的目录
    # LOG_DIR = os.path.join(BASE_DIR, 'logs')

    # Session录像存放目录
    # SESSION_DIR = os.path.join(BASE_DIR, 'sessions')

    # 资产显示排序方式, ['ip', 'hostname']
    # ASSET_LIST_SORT_BY = 'ip'

    # 登录是否支持密码认证
    # PASSWORD_AUTH = True

    # 登录是否支持秘钥认证
    # PUBLIC_KEY_AUTH = True

    # SSH白名单
    # ALLOW_SSH_USER = 'all'  # ['test', 'test2']

    # SSH黑名单, 如果用户同时在白名单和黑名单，黑名单优先生效
    # BLOCK_SSH_USER = []

    # 和Jumpserver 保持心跳时间间隔
    # HEARTBEAT_INTERVAL = 5

    # Admin的名字，出问题会提示给用户
    # ADMINS = ''
    COMMAND_STORAGE = {
        "TYPE": "server"
    }
    REPLAY_STORAGE = {
        "TYPE": "server"
    }

    # SSH连接超时时间 (default 15 seconds)
    # SSH_TIMEOUT = 15

    # 语言 = en
    LANGUAGE_CODE = 'zh'


config = Config()
