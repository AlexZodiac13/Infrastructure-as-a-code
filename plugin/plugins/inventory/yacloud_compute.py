#!/usr/bin/env python3
"""Заглушка-плагин для yacloud_compute.

Замените этим файлом реальную реализацию плагина (скачайте из репозитория автора)
"""
import sys
import json

if __name__ == '__main__':
    # Заглушка — возвращаем пустой inventory и подсказку
    print(json.dumps({}))
    sys.exit(0)
