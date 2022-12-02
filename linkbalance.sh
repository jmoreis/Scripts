#!/bin/bash
# Ver. 1.0: Script para detetecao de queda do link padrao.
# Por Julio Reis Em 01/12/2022

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin

wan1="8.8.4.4" #DNS2 Google
versao=`echo "${linha: -10}"|cut -d"." -f1|cut -d"v" -f2`
ctd_ver=0
CTRL=0
CAMLCK="/scripts/net/fonte_linkbalance"
CAMLOG="/var/log/LR"

testLink()
{
    for tstping in {1..10}
    do
        if ping -c1 -w1 $wan1 1> /dev/null
        then
            ctd_ver=$((ctd_ver + 1))
        fi
    done
}


#Inicio
if [ -f $CAMLCK/lblc.lck ]
then
    exit 0
fi

testLink

if [ $ctd_ver -le 7 ]
then
    touch $CAMLCK/lblc.lck
    echo -e "Link com alta perda de pacotes ($ctd_ver).\nIniciado protocolo de contingencia.\n\nSuporte LR"| mail -s "LR09 - Starlink" julio@lr.com.br
    echo "`date "+%F %T"` : Alteração para Contingencia. Perda de pacotes=$((10-ctd)).(Ver.$versao)" >> $CAMLOG/linkbalance.log
    #REMOVE ROTAS STARLINK
    route del default gw 10.0.0.1
    sleep 2
    route add default gw 10.0.0.9
    sleep 300
    while [ $CTRL -le 5 ]
    do
        ctd_ver=0
        testLink
        if [ $ctd_ver -gt 7 ]
        then 
            CTRL=$((CTRL + 1))
        fi
        sleep 5
    done
    route del default gw 10.0.0.9
    sleep 2
    route add default gw 10.0.0.1
    echo "`date "+%F %T"` : Retorno link Starlink. Perda de pacotes=$((10-ctd_ver)).(Ver.$versao)" >> $CAMLOG/linkbalance.log
    rm -f $CAMLCK/lblc.lck
fi
