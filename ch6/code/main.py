# main.py
import os
import functions_framework
from markupsafe import escape

@functions_framework.http
def hello_http(request):
    # 獲取環境變數
    mysql_ip = os.environ.get('MYSQL_IP', 'not set')  # 如果沒有設置，返回 'not set'
    mysql_password = os.environ.get('MYSQL_PASSWORD', 'not set')
    
    request_json = request.get_json(silent=True)
    request_args = request.args

    if request_json and "name" in request_json:
        name = request_json["name"]
    elif request_args and "name" in request_args:
        name = request_args["name"]
    else:
        name = "World"
        
    return f"Hello {escape(name)}! (MySQL IP: {mysql_ip})(MySQL Password: {mysql_password})"