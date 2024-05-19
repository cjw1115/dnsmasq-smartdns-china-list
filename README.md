## 目标
在OpenWRT中使用SmartDNS作为dnsmasq的上游DNS服务器，针对不同域名使用不同的DNS服务器进行域名解析。比如针对所有china域名走国内的DNS服务器解析，而其他地区域名走Cloudfare或者Google等国际DNS解析服务器。
* 实现域名分流
* 防止DNS泄露

## dnsmasq-china-list
本项目基于项目 https://github.com/felixonmars/dnsmasq-china-list.git
原项目支持使用如下命令：
```
make SERVER=CN smartdns
```
生成适用于smartdns的自定义配置文件, 默认输出名称是 `accelerated-domains.china.smartdns.conf`, 该文件内容是包含所有china域名的smartdns nameserver配置文件，每一行都是一个nameserver配置项，例如：
```
nameserver /baidu.com/CN
```
其中CN表示该域名使用服务器组CN进行DNS解析。

## 配置SmartDNS
1. 清除所有上游服务器，然后添加国内DNS服务器，全部勾选从`从默认组中排除`，服务器组填写为`CN`, 主要是要与上面一步的SERVER=CN匹配，可以添加多个，比如运营商DNS, 百度，114，腾讯，阿里
![image](https://github.com/cjw1115/dnsmasq-smartdns-china-list/assets/13924086/a1a1be71-957e-4d81-a4c3-0b6d4989bc45)
2. 在自定义设置中（/etc/smardns/custom.conf）中添加如下行，实际就是需要把上面dnsmasq-china-list生成的配置文件引入到smartdns中，注意需要把生成的`accelerated-domains.china.smartdns.conf`复制到`/etc/smartdns/domain-set/accelerated-domains.china.smartdns.conf`，然后保存重启smartdns。

  ```
  conf-file /etc/smartdns/domain-set/accelerated-domains.china.smartdns.conf
  ```
  ![image](https://github.com/cjw1115/dnsmasq-smartdns-china-list/assets/13924086/5ce8b32e-fd9e-427d-8426-daba27ff9458)
  
经过上面设置后，应该已经可以针对国内的大多数网站进行正常的域名解析了。其他所有不在这个列表中的域名，DNS解析将会失败，因为我们目前添加的所有DNS上游服务器都是从默认组中排除的，其他域名目前是没有上游DNS服务器可用。
这个时候你就可以添加cloudflare或者google的dns服务器了，服务器组名称不要填写`CN`, 也不要勾选从默认组排除。设置过后，所有不在accelerated-domains.china.smartdns.conf中的域名，都将通过clouldflare或者google的DNS服务器去解析。

> SmartDNS默认会引入配置项 `resolv-file /tmp/resolv.conf.d/resolv.conf.auto `，这个文件中包含了从WAN口获取的运营商DNS，这个DNS会被隐式作为缺省值使用，最好把里面的DNS地址用#注释掉

## update_smartdns_conf.sh
确保smartdns已经按照上面的步骤配置完成，将此脚本放置于任意用户目录，然后执行此脚本，将自动clone项目dnsmasq-china-list, 利用该项目生成 accelerated-domains.china.smartdns.conf，并把它复制到smartdns的domain-set目录，最后重启smartdns。
> 你也可以把此脚本利用crontab加入自动计划任务中，定期执行，确保你的域名列表是最新的！
