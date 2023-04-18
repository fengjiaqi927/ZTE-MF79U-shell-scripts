# ZTE-MF79U-shell-scripts
Some shell scripts to get parameters and control buttons from MF79U web


## Function
1. Get data usage and upload to wechat
2. Control the data connect switch according to the total data volume

## How it work
base step：Get Cookie

```
auth_response=$(curl -s -X POST \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -H "Origin: http://192.168.0.1" \
     -H "Referer: http://192.168.0.1/index.html" \
     -d "isTest=false&goformId=LOGIN&password=$(echo -n $password | base64)" \
     http://192.168.0.1/goform/goform_set_cmd_process \
     -c cookies.txt)
stok=$(grep -E '192\.168\.0\.1\s+FALSE\s+/\s+FALSE\s+\d+\s+stok\s+\w+' cookies.txt | awk '{print $NF}')
```

usage 1：Get Parameters
```
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
```
usage 2: Control switch
```
curl -s --header "Referer: http://192.168.0.1/index.html" -d 'isTest=false&notCallback=true&goformId=DISCONNECT_NETWORK' http://192.168.0.1/goform/goform_set_cmd_process
echo 'DISCONNECT_NETWORK'
curl -s --header "Referer: http://192.168.0.1/index.html" -d 'isTest=false&notCallback=true&goformId=CONNECT_NETWORK' http://192.168.0.1/goform/goform_set_cmd_process
echo 'CONNECT_NETWORK'
```
## Special thanks to:

[rkarimabadi/ZTE-MF79-usb-modem-Send-SMS](https://github.com/rkarimabadi/ZTE-MF79-usb-modem-Send-SMS) - for the idea of using curl to log in to the web

[pmcrwf-mid/ZTE-MF79U-api](https://github.com/pmcrwf-mid/ZTE-MF79U-api) - for the parameters 

