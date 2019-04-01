<?php

## GATEWAY (requires +developer_ip.yml apache only at present)

if (strpos( $_SERVER['ALLOWED'], '.Info.') === false) {
    header('HTTP/1.0 403 Forbidden'); 
    die('You are loved, but not enough to see my info'); 
}

phpinfo();

