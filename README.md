## Plugin de reparo automático de violações do sonarqube

Esse plugin é um wrapper da ferramenta [sorald](https://github.com/SpoonLabs/sorald/). Essa ferramenta detecta e repara automaticamente 20+ tipos de violações de código definidos pelo sonarqube. 

Nessa POC, fizemos um [script](sorald.sh) para interagir com a ferramenta de forma mais amigável ao usuário.

Em testes realizados na Handora, foram detectados 4 grupos de violações (mais de 15 violações individuais), que a ferramenta conseguiu reparar localmente.