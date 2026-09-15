#!/usr/bin/env bash
# Uso: bash testes/testar.sh parte1
#      bash testes/testar.sh missao1
#      bash testes/testar.sh missao2
#      bash testes/testar.sh missao3
#
# Compila o programa e roda cada arquivo .in da pasta escolhida, comparando a
# saida com o .out de mesmo nome. Rode a partir da raiz do repositorio.

set -u

if [ $# -ne 1 ]; then
  echo "Uso: bash testes/testar.sh parte1|missao1|missao2|missao3"
  exit 1
fi

pasta="testes/$1"
if [ ! -d "$pasta" ]; then
  echo "Pasta $pasta nao existe."
  exit 1
fi

# Compila tudo que estiver em src/. Se existir a pasta include/, ela entra
# no caminho de busca dos .hpp.
inclui=""
if [ -d include ]; then
  inclui="-Iinclude"
fi
g++ -std=c++11 -Wall -Wno-sign-compare src/*.cpp $inclui -o agencia || exit 1

# As missoes 2 e 3 tem testes que salvam em dados_teste.txt e outros que
# carregam. Os arquivos .in rodam em ordem alfabetica e o arquivo de dados
# fica na pasta atual.
rm -f dados_teste.txt

total=0
falhas=0
for entrada in "$pasta"/*.in; do
  esperado="${entrada%.in}.out"
  nome="$(basename "$entrada" .in)"
  total=$((total + 1))

  saida="$(./agencia < "$entrada")"
  if [ "$saida" == "$(cat "$esperado")" ]; then
    echo "OK    $nome"
  else
    echo "FALHA $nome"
    echo "----- diferenca (esperado com -, seu programa com +) -----"
    diff -u "$esperado" <(echo "$saida") | tail -n +3 | head -30
    echo "-----------------------------------------------------------"
    falhas=$((falhas + 1))
  fi
done

rm -f dados_teste.txt

echo
echo "$((total - falhas)) de $total testes passaram."
if [ "$falhas" -ne 0 ]; then
  exit 1
fi
