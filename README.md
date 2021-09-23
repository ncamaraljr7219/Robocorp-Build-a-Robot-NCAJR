# robocorp-certification-level-ii
RoboCorp Certification Level II

Algumas notas e problemas que surgiram durante o curso:

- `` devdata / env`` e a referência ao arquivo `` vault.json``: Parece que apenas caminhos absolutos parecem funcionar aqui. Nem o Robot Framework `` $ {CURDIR} `` nem abordagens Unix como `` $ HOME``, `` ~ ``, `` ../ vault.json`` e outros funcionam. Isso significa que a versão atual deste arquivo __will__ __not__ __work__ fora da caixa em um ambiente diferente sem algumas pequenas alterações. Além disso, se você abrir o arquivo em VSCode, minhas configurações de venv serão ativadas (veja o arquivo `` .vscode / settings.json`` e a linha de configuração `` "python.pythonPath": "/Users/jsl/.robocorp/live / 7b3eba72202108b9 / bin / python3 "` `)
- Tenho que usar o VSCode porque meu empregador não permite a instalação do IDE Robocorp. Então, gerei o código do esqueleto RPA no VSCode. O gerador cria todos os arquivos, mas atribui uma versão antiga / obsoleta do `` rpaframework`` ao arquivo `` conda.yaml`` (9.xxx). Com esta configuração padrão, a opção PDF `` append`` não funciona, pois a palavra-chave não reconhecerá este parâmetro. Veja os comentários no código-fonte. -> `` - rpaframework == 10.6.0 # https: // rpaframework.org / releasenotes.html`` no arquivo `` conda.yaml`` fará o truque. Você adicionou isso às instruções (`` Palavras-chave do RPA Framework não são reconhecidas pelo IDE! ``), Mas você também deve mencionar que os parâmetros podem não ser reconhecidos se você não aumentar a versão.
- Com a biblioteca RPA.PDF atual, não vejo como EMBED a imagem no conteúdo da página __primeira__ (onde estão os dados do pedido). Dê uma olhada no código python no qual a palavra-chave se baseia - tudo o que você fornecer como arquivos externos (imagens ou pdfs) __sempre__ será adicionado como uma página SEPARADA no arquivo pdf. Veja também meus comentários no arquivo `` tasks.robot`` (com referência a `` https://github.com/robocorp/rpaframework/blob/master/packages/pdf/src/RPA/PDF/keywords/document. py``)

Com os caminhos codificados para o cofre (e as configurações do venv), a restrição do exame `` Verifique se é possível executar o robô sem configuração manual`` pode não ser atendida. No entanto, como não posso ignorar os requisitos de ambiente absolutos, mesmo para o arquivo do vault, o teste não funcionará imediatamente - a menos que você altere essas configurações.

Todos os outros nomes de arquivo, caminhos, etc. foram armazenados como parâmetros no arquivo. Desculpe, companheiros - eu uso principalmente o Robot Framework para teste de API de back-end, então algumas abordagens no teste podem ser um pouco desajeitadas. Mas o teste em si funciona bem.

Sugestões de melhoria:

Eu gostaria de ver informações sobre como o programa pode forçar o usuário a inserir alguns dados ao usar rpa.dialogs e caixas de entrada. Os loops WUKS não podem ser a solução aqui? Não detectei esse problema potencial no programa, então é definitivamente um "fora do escopo".

Obrigado pelo desafio!