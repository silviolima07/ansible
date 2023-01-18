#!/bin/bash
# Proposito: Automatiza a criação de usuários na AWS
# Utilizacao: ./aws-iam-cria-usuario.sh <formato arquivo entrada .csv>
# Formato do arquivo de entrada: usuarios,grupo,senha
# Autor: Jean Rodrigues
# ------------------------------------------

INPUT=$1 # Captura o nome do arquivo fornecido na linha de comando
OLDIFS=$IFS #  Internal Field Separator (IFS) por default é: space><tab><newline>
IFS=',;' # Informa os separadores que podem ser usados no arquivo cvs informado

# Se nenhum argumento é fornecido, a mensagem é apresentada
if [ "${#INPUT}" -eq 0 ]; then
    echo "Informe nome do arquivo com extensao csv"
    echo "Sintaxe: ./aws-iam-cria-usuario.sh filename.csv"
    exit 99
fi

# Caso o arquivo informado não existir no diretório corrente, a mensagem será apresentada
[ ! -f $INPUT ] && { echo "$INPUT arquivo nao encontrado"; exit 99; }

# Ao executar o comando dos2unix a conversão inicia e uma mensagem default aparece.
# Caso o comando dos2unix nao esteja instalado aparecerá uma mensagem orientando para que seja instalado.
command -v dos2unix >/dev/null || { echo "utilitario dos2unix nao encontrado. Por favor, instale dos2unix antes de rodar o script."; exit 1; }

dos2unix $INPUT

# Enquanto houver entrada valida no arquivo convertido o loop while e do/done continua
while read -r usuario grupo senha || [ -n "$usuario" ]
do
    if [ "$usuario" != "usuarios" ]; then
       echo "Criando usuario: $usuario do Grupo: $grupo com Senha temporaria: $senha"
       aws iam create-user --user-name $usuario
       aws iam create-login-profile --password-reset-required --user-name $usuario --password $senha
       aws iam add-user-to-group --group-name $grupo --user-name $usuario
    fi

done < $INPUT # Realimenta o loop de entrada

IFS=$OLDIFS
