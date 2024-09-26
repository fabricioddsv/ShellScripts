#!/bin/bash

orig=$1
dest=$2
lista_arquivos="lista_arquivos.txt"

# Verifica se os parâmetros foram passados corretamente
if [ $# != "2" ]; then
    echo "Uso: $0 <diretorio_origem> <diretorio_destino>"
    exit 1
elif [ -e "$orig" ]; then
    echo "Sincronizacao iniciada"
    
    # Verifica se o diretório de destino existe
    if [ ! -e "$dest" ]; then
        while true; do
            if [ -e "$dest" ]; then
                break
            fi
            echo "Aguardando conexão com o destino: $dest"
            for i in {1..10}; do
                echo -n "*"
                sleep 1
            done
            echo ""
        done
    fi

    # Gera uma lista recursiva de todos os arquivos e diretórios da origem
    find "$orig" -type f -o -type d > "$lista_arquivos"

    # Percorre a lista de arquivos e diretórios
    while read caminho_origem; do
        # Cria o caminho correspondente no destino
        caminho_destino="${caminho_origem/$orig/$dest}"

        # Se o caminho é um diretório
        if [ -d "$caminho_origem" ]; then
            if [ ! -d "$caminho_destino" ]; then
                echo "Criando diretorio $caminho_destino"
                mkdir -p "$caminho_destino"
            fi

        # Se o caminho é um arquivo
        elif [ -f "$caminho_origem" ]; then
            if [ -e "$caminho_destino" ]; then
                # Verifica se o arquivo na origem é mais recente
                if [ "$caminho_origem" -nt "$caminho_destino" ]; then
                    echo "Atualizando arquivo $caminho_destino"
                    cp "$caminho_origem" "$caminho_destino"
                else
                    echo "Ignorando arquivo $caminho_destino"
                fi
            else
                # Se o arquivo não existe no destino
                echo "Criando arquivo $caminho_destino"
                cp "$caminho_origem" "$caminho_destino"
            fi
        fi
    done < "$lista_arquivos"

    # Remove o arquivo de listagem
    rm "$lista_arquivos"

    echo "Sincronização encerrada"
    exit 0
else
    echo "Diretorio de origem nao encontrado: $orig"
    echo "Encerrando execucao"
    exit 1
fi

