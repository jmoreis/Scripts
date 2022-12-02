#!/bin/bash
# Criado sinalização de Gateway padrao.

#Variaveis globais
wan1="8.8.4.4" #Default(DNS2 Google)
wan2="8.8.8.8" #Contingencia(DNS Google)
pass_link=0
opc=""
bkgdef=6
linha=`ls -l $0|head -n1`
versao=`echo "${linha: -10}"|cut -d"." -f1|cut -d"v" -f2`

#Inicio
clear 
echo 
echo "`tput rev;tput bold;tput setaf 6` Monitoramento de links (v.$versao)`tput sgr0`"
while [ -z $opc ]
do
    if [ `ip route|grep default|awk '{print $3}'` = "10.0.0.1" ]
    then
        DF_RTN="Default    "
    else
        DF_RTN="Contigencia"
    fi

    for link_wan in $wan1 $wan2
    do
        ctd_ver=0
        #Testa link
        for tstping in {1..4}
        do
            if ping -c1 -w1 $link_wan 1> /dev/null
            then
                ctd_ver=$((ctd_ver + 1))
            fi
        done

        #Define se o link esta ativo ou nao
        if [ $ctd_ver -gt 2 ]
        then
            statcolr=3
            statbkg=6
            statmsg="Link ativo   "
        else
            statcolr=6
            statbkg=1
            statmsg="Link inativo "
        fi
        
        #Define o nome do link testado
        if [ $pass_link -eq 0 ]
        then
            nom_link="Default    "
        else
            nom_link="Contigencia"
        fi
        
        #Marca link GW
        if [ $nom_link = $DF_RTN ]
        then
            DF="(*)"
        else
            DF="   "
        fi

        #Cria bordas e cabecalho com horario
        if [ $pass_link -eq 0 ]
        then
            bordas=$(echo "| Status atual $nom_link   =  $statmsg     |" | sed 's/./-/g')
            tput cup 3 0
            tput bold
            tput setaf 6
            echo " Hora atual `date +'%H:%M:%S %p'`"
            tput sgr0
            tput setab $bkgdef
            tput setaf 0
            echo $bordas
        fi

        #Exibe informacoes
        echo "| `tput setaf 0`Status atual $nom_link =  `tput bold;tput setaf $statcolr;tput setab $statbkg` $statmsg $DF`tput sgr0;tput setab $bkgdef;tput setaf 0`  |"

        #Fecha a borda do quadro
        if [ $pass_link -eq 1 ]
        then
            tput setaf 0
            echo $bordas
            tput sgr0
        fi
        pass_link=1
    done
    pass_link=0

    #Exibe rodape
    echo
    echo "`tput bold;tput setaf 6`>>>Pressione qualquer tecla para sair<<<`tput sgr0`"
    read -rsn1 -t 5 opc
done
