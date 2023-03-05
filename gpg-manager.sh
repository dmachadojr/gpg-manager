#!/bin/bash
#------------------------------------
# gerenciador de uso chave gpg
# versao 1.0
# autor: Prof. Dr. Dorival M. Machado Junior
# curso de Sistemas de Informacao
# Libertas Faculdades Integradas
#------------------------------------
stty sane #repara problema referente ao <ENTER> no terminal quando usa o Kali

listaChaves() {
        echo "---|CHAVES ENCONTRADAS|------"
        gpg --list-keys
        echo "-----------------------------"
}

geraChave() {
        gpg --gen-key
}

exportaChave() {
        ARQ=$CHAVE-`date | tr -s [:blank:] _ | tr -s : .`.asc
        gpg -a --export $CHAVE > $ARQ
        echo "Chave exportada para $ARQ"
}

importaChave() {
        gpg --import $ARQUIVO
}

confiarNaChave() {
        gpg --sign-key $CHAVE
}

encriptaMensagem() {
        gpg --encrypt --sign --armor -r $DESTINATARIO $ARQUIVOMENSAGEMTEXTO
        cat $ARQUIVOMENSAGEMTEXTO.asc
        echo "*****************************************************"
        echo "Mensagem criptografada salva em $ARQUIVOMENSAGEMTEXTO.asc"
        echo "*****************************************************"
        read -p "Pressione <ENTER> para continuar..."
}

desencriptarMensagem() {
        gpg --decrypt $ARQUIVOMENSAGEMASC
}

assinarArquivo() {
        echo -n "Informe o arquivo a ser assinado: "
        read ARQUIVOTEXTOPLANO
        gpg -s $ARQUIVOTEXTOPLANO
}

apagarAssinaturaArquivo() {
        gpg -s --clear-sign $ARQUIVOASSINADOGPG
}


recepcionaArquivo() {
        echo -n $1
        read ARQUIVO
        if [ ! -e $ARQUIVO ]; then
                echo "Arquivo não encontrado..."
        else
                echo "Arquivo encontrado."
        fi
}

apagarChave() {
        listaChaves
        echo -n "Escreva o e-mail referente as chave (publica e privada) a serem removidas: "
        read E
        gpg --delete-secret-and-public-keys $E
}

MENU() {
        clear
        echo
        echo "GPG Manager Tabajara 2021, by Tomatex7"
        echo "======================================"
        echo 
        listaChaves
        echo 
        echo "[1] Gerar chave PGP (antes de executar abra outro terminal e deixe executando \"cat /dev/urandom\""
        echo "[2] Exportar chave publica"
        echo "[3] Importar chave de um novo contato"
        echo "[4] Confiar em uma chave importada"
        echo "[5] Assinar um arquivo (esta opcao nao vai encriptar a mensagem, apenas assinar)"
        echo "[6] Apagar assinatura de um arquivo - AINDA NAO IMPLEMENTADO"
        echo "[7] Encriptar uma mensagem para envio"
        echo "[8] Desencriptar uma mensagem recebida"
        echo "[9] Remove chave publica e privada existente"
        echo "[0] Sair"
        echo
        echo -n "Escolha: "
        read OP

        case "$OP" in
                1)
                        geraChave
                        MENU
                ;;

                2)
                        listaChaves
                        echo -n "Digite a chave que deseja exportar: (atencao: nao eh o e-mail): "
                        read CHAVE
                        exportaChave CHAVE
                        read -p "Pressione <ENTER> para continuar..."
                ;;

                3)
                        echo "--[buscando arquivos .asc]--------"
                        ls *.asc -l
                        echo "--[final da busca]----------------"

                        echo -n "Importacao de arquivo .asc: "
                        recepcionaArquivo "Informe o arquivo .asc a ser importado:"
                        importaChave
                        read -p "Pressione <ENTER> para continuar..."
                ;;

                4)
                        listaChaves
                        echo -n "Digite o e-mail da chave que pretende confiar: "
                        read CHAVE
                        confiarNaChave
                        read -p "Pressione <ENTER> para continuar..."
                ;;
                5)
                        assinarArquivo
                ;;
                6)
                        echo "Ainda nao implementado, desculpe!"
                ;;

                7)
                        echo -n "Destinatario (escolha da lista de chaves): "
                        read DESTINATARIO

                        echo "Escolha a origem da mensagem a ser criptografada:"
                        echo "[1] - Quero digitar a mensagem agora."
                        echo "[2] - Quero informar o arquivo que contém a mensagem."
                        echo -n "? "
                        read OP_ORIG
                        case "$OP_ORIG" in
                                1)
                                        echo -n "Mensagem: "
                                        read MSGTEXTO
                                        echo $MSGTEXTO > MSGTXT
                                        ARQUIVOMENSAGEMTEXTO="MSGTXT"
                                ;;
                                2)
                                        while [ ! -e "$ARQUIVOMENSAGEMTEXTO" ]; do
                                                echo -n "Arquivo com a mensagem: "
                                                read ARQUIVOMENSAGEMTEXTO
                                                if [ ! -e "$ARQUIVOMENSAGEMTEXTO" ]; then echo "Arquivo não encontrado"; fi
                                        done
                                        echo "MENSAGEM A SER ENCRIPTADA:"
                                        cat $ARQUIVOMENSAGEMTEXTO
                                        read -p "Pressione <ENTER> para executar processo de encriptação..."
                                ;;
                                *)
                                        MENU
                                ;;
                        esac
                        encriptaMensagem
                        rm -f $ARQUIVOMENSAGEMTEXTO 
                        #rm -f $ARQUIVOMENSAGEMTEXTO.asc
                MENU
                ;;
                8)
                        echo "Escolha a origem da mensagem a ser descriptografada:"
                        echo "[1] - Quero colar o texto criptografado."
                        echo "[2] - Quero informar o arquivo que contém a mensagem"
                        echo -n "? "
                        read OP_ORIG
                        case "$OP_ORIG" in
                                1)
                                        echo -n "Mensagem: "
                                        read MSGASC
                                        echo $MSGASC > MSGASC
                                        ARQUIVOMENSAGEMASC="MSGASC"
                                ;;
                                2)
                                        while [ ! -e "$ARQUIVOMENSAGEMASC" ]; do
                                                echo "---[arquivos no diretorio]-----"
                                                ls -l
                                                echo "-------------------------------"
                                                echo -n "Arquivo com a mensagem: "
                                                read ARQUIVOMENSAGEMASC
                                                if [ ! -e "$ARQUIVOMENSAGEMASC" ]; then echo "Arquivo não encontrado"; fi
                                        done
                                        echo "MENSAGEM A SER DESENCRIPTADA:"
                                        cat $ARQUIVOMENSAGEMASC
                                        read -p "Pressione <ENTER> para executar processo de desencriptação..."
                                ;;
                                *)
                                        MENU
                                ;;
                        esac
                        desencriptarMensagem

                ;;
                9)
                        apagarChave
                ;;

        esac
}
MENU
