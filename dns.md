## Install BIND9
```bash
sudo apt update
sudo apt install bind9 dnsutils -y
```
## Buat File Zona db.corpX.local
```
sudo nano /etc/bind/db.corpX.local
```
isi file :
```
$TTL    604800
@       IN      SOA     ns1.corpX.local. admin.corpX.local. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

; Nameserver
        IN      NS      ns1.corpX.local.

; A Records
ns1     IN      A       127.0.0.1
dev     IN      A       127.0.0.2
git     IN      A       127.0.0.3
mail    IN      A       127.0.0.4
```
## Tambah Zona di named.conf.local
edit file :
```
sudo nano /etc/bind/named.conf.local
```
isi file :
```
zone "corpX.local" {
    type master;
    file "/etc/bind/db.corpX.local";
};
```

## Konfigurasi Global named.conf.options
edit file :
```
sudo nano /etc/bind/named.conf.options
```
isi file :
```
options {
    directory "/var/cache/bind";

    recursion yes;
    allow-query { any; };

    listen-on { 127.0.0.1; };
    listen-on-v6 { none; };
};
```
## Periksa & Reload Konfigurasi
```
sudo named-checkconf
sudo named-checkzone corpX.local /etc/bind/db.corpX.local
```
## Restart BIND9
```
sudo systemctl restart bind9
```
periksa status :
```
sudo systemctl status bind9
```

## Atur resolv.conf agar pakai DNS lokal
```
sudo nano /etc/resolv.conf
```
isi file :
```
nameserver 127.0.0.1
```
## Pengujian DNS
```
nslookup dev.corpX.local
nslookup git.corpX.local
nslookup mail.corpX.local

dig dev.corpX.local
dig git.corpX.local

host mail.corpX.local
```
output :
```
┌──(kali㉿DESKTOP-28BRRSL)-[/etc/bind]
└─$ nslookup dev.corpX.local
Server:         127.0.0.1
Address:        127.0.0.1#53

Name:   dev.corpX.local
Address: 127.0.0.2

┌──(kali㉿DESKTOP-28BRRSL)-[/etc/bind]
└─$ dig git.corpX.local

; <<>> DiG 9.20.9-1-Debian <<>> git.corpX.local
;; global options: +cmd
;; Got answer:
;; WARNING: .local is reserved for Multicast DNS
;; You are currently testing what happens when an mDNS query is leaked to DNS
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 42740
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: c51af3832fe28dc5010000006846d6a8c0de5da8c8b2dd0b (good)
;; QUESTION SECTION:
;git.corpX.local.               IN      A

;; ANSWER SECTION:
git.corpX.local.        604800  IN      A       127.0.0.3

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Mon Jun 09 19:42:16 WIB 2025
;; MSG SIZE  rcvd: 88

┌──(kali㉿DESKTOP-28BRRSL)-[/etc/bind]
└─$ host mail.corpX.local
mail.corpX.local has address 127.0.0.4
```