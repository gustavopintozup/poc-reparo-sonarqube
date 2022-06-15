#!/bin/bash

if [ -n `which java` ]; then
    echo "Java está instalado!"
else
    echo "Java não está instalado!"
    exit 0
fi

root_dir=$(pwd)
projeto_dir="/home/gustavopinto/workspace/plataforma-treino-lms" # pedir para usuario informar

echo "Avaliando uso do sonarqube (pode demorar alguns segundos)"
java -jar sorald.jar mine \
    --source $projeto_dir \
    --handled-rules       \
    --stats-output-file output.json >/dev/null

violacoes=$(grep ruleKey output.json | wc -l)

echo "Métricas coletadas. $violacoes violações encontradas."

echo "Quer listar violações?"

options=("Sim" "Não")
select opt in "${options[@]}"
do
    case $opt in
        "Sim"|1)
            cat output.json | grep ruleName -A1 | less
            break
            ;;
        "Não"|2)
            break
            ;;
        *) echo "Opção Inválida $REPLY";;
    esac
done


function verifica_se_git_esta_limpo() {
    cd $projeto_dir
    if [ -n "$(git status --porcelain)" ]; then
        echo "Não foi possível reparar as violações pois o git tem mudanças não commitadas.";
        echo "Faça commit e depois tente novamente.";
        exit 0
    fi
    cd $root_dir
}

function repara_regra_violada() {
    cd $projeto_dir
    git checkout -b reparo-sonarqube-$rule >/dev/null  2>&1
    cd $root_dir

    echo "Reparando $1"

    java -jar sorald.jar repair \
        --source $projeto_dir \
        --rule-key $1 >/dev/null 2>&1
}

echo "Você deseja reparar alguma violação?"
options=("Sim (todas)" "Sim (especificar)" "Não")
select opt in "${options[@]}"
do
    case $opt in
        "Sim (todas)"|1)
            verifica_se_git_esta_limpo
            regras=$(cat output.json | grep ruleKey | awk -F : '{ print $2 }' | tr -d '"')
            
            for regra in ${regras[@]}; do
                repara_regra_violada $regra
            done
            
            echo "Todas as violações foram reparadas!"
            break;
            ;;
        "Sim (especificar)"|2)
            verifica_se_git_esta_limpo
            echo "Digite o número da violação que você deseja reparar"
            read rule

            repara_regra_violada $rule
            break;
            ;;
        "Não"|3)
            echo "Nenhuma reparação escolhida. Finalizando programa."
            break;
            ;;
        *) echo "Opção inválida $REPLY";;
    esac
done