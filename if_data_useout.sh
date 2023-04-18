#!/bin/sh

export PATH='/usr/sbin:/usr/bin:/sbin:/bin'

total_data=$1
serverchan_sckey_1=$2
serverchan_sckey_2=$3

stok_time_out=0

if [ $stok_time_out = "0" ];then
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
  web_response=$(curl 'http://192.168.0.1/goform/goform_get_cmd_process?isTest=false&cmd=monthly_tx_bytes%2Cmonthly_rx_bytes%2Cwan_connect_status&multi_data=1&_=1681181570518' \
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
  wan_connect_status=$(echo $web_response | jq -r '.wan_connect_status')
fi


echo $monthly_tx_bytes
echo $monthly_rx_bytes
echo $wan_connect_status 


total_bytes=$(expr $monthly_tx_bytes + $monthly_rx_bytes)
total_gb=$(echo "scale=2; $total_bytes / 1073741824" |bc )

echo $total_gb
echo $total_data



greater_than_set=$(echo "$total_gb > $total_data" |bc -l)

echo $greater_than_set

if [ $greater_than_set = "1" ];then
	if [ $wan_connect_status = "pdp_connected" ];then

		curl -s --header "Referer: http://192.168.0.1/index.html" -d 'isTest=false&notCallback=true&goformId=DISCONNECT_NETWORK' http://192.168.0.1/goform/goform_set_cmd_process
		echo 'DISCONNECT_NETWORK'
		
	fi
	echo 'used_data_more_than_set'
else
	if [ $wan_connect_status = "no_connected" ];then
		curl -s --header "Referer: http://192.168.0.1/index.html" -d 'isTest=false&notCallback=true&goformId=CONNECT_NETWORK' http://192.168.0.1/goform/goform_set_cmd_process
		echo 'CONNECT_NETWORK'
	fi
	echo 'used_data_less_than_set'
fi

