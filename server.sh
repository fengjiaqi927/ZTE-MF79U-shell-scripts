#!/bin/sh
export PATH='/usr/sbin:/usr/bin:/sbin:/bin'

# Paraments

serverchan_sckey_1=$1
serverchan_sckey_2=$2

password="12345679"

auth_response=$(curl -s -X POST \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -H "Origin: http://192.168.0.1" \
     -H "Referer: http://192.168.0.1/index.html" \
     -d "isTest=false&goformId=LOGIN&password=$(echo -n $password | base64)" \
     http://192.168.0.1/goform/goform_set_cmd_process \
     -c cookies.txt)

#stok=$(grep -Po '(?<=stok\t)[^\t]+' cookies.txt)
stok=$(grep -E '192\.168\.0\.1\s+FALSE\s+/\s+FALSE\s+\d+\s+stok\s+\w+' cookies.txt | awk '{print $NF}')


# echo $stok


web_response=$(curl 'http://192.168.0.1/goform/goform_get_cmd_process?isTest=false&cmd=monthly_tx_bytes%2Cmonthly_rx_bytes&multi_data=1&_=1681181570518' \
  -H 'Accept: application/json, text/javascript, */*; q=0.01' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Connection: keep-alive' \
  -H "Cookie: stok=${stok}" \
  -H 'Referer: http://192.168.0.1/index.html' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36' \
  -H 'X-Requested-With: XMLHttpRequest' \
  --insecure)

monthly_tx_bytes=$(echo $web_response | jq -r '.monthly_tx_bytes')
monthly_rx_bytes=$(echo $web_response | jq -r '.monthly_rx_bytes')


echo $monthly_tx_bytes
echo $monthly_rx_bytes 


total_bytes=$(expr $monthly_tx_bytes + $monthly_rx_bytes)
total_gb=$(echo "scale=2; $total_bytes / 1073741824" |bc )




content="Hello, YY~~~, I love U!!!!"


# weather=$(curl 'wttr.in/?format=3')

device_city=$(curl ipinfo.io | jq -r '.city')
weather=$(curl wttr.in/${device_city}?format=3)

content_all="${content}${weather}"

title=$(echo -n "you have used $total_gb GB data" | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g')


curl -s "http://sctapi.ftqq.com/$serverchan_sckey_1.send?text=${title}" -d "&desp=${content_all}" &
logger -t "wechat push" "data_used: ${content_all} pushed"

curl -s "http://sctapi.ftqq.com/$serverchan_sckey_2.send?text=${title}" -d "&desp=${content_all}" &
logger -t "wechat push" "data_used: ${content_all} pushed"



