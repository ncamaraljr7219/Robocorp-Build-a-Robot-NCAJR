# -*- coding: utf-8 -*-
# +
*** Settings ***
Documentation   Encomendar Robos do robotsparebin industrias
...             Salvar o recibo HTML em um arquivo pdf
...             Pegar PrintScreen dos Robos e anexar em um arquivo pdf
...             Zipar todos os recibos
...             Author: https://github.com/ncamaraljr7219

Library         RPA.Browser
Library         RPA.Tables
Library         RPA.PDF
Library         RPA.FileSystem
Library         RPA.HTTP
Library         RPA.Archive
Library         Dialogs
Library         RPA.Robocloud.Secrets
Library         RPA.core.notebook
# -


# #Passo a Passo a ser Seguido.
# Todos os passos que temos que seguir são :
# 1. Abrir o site da web
# 2. Abrir uma caixa de dialogo perguntando pela url de origem para realizar o download do arquivo csv
# 3. Usar o arquivo csv levando em conta cada linha para criar os detalhes dos robos via site da web.
# 4. Depois da entrada e operação dos dados, salvar os recibos em um arquivo de formato PDF
# 5. Tirar uma printscreen do Robo e adcionar o robo em um arquivo de formato PDF
# 6. Finalmente pegar todos seus recibos e zippar eles e armazenar no diretório output.
# 7. Fechar o site da web
#

# +
*** Variables ***
${url}            https://robotsparebinindustries.com/#/robot-order

#${img_folder}     ${CURDIR}${/}image_files
#${pdf_folder}     ${CURDIR}${/}pdf_files
#${output_folder}  ${CURDIR}${/}output

#${orders_file}    ${CURDIR}${/}orders.csv
#${zip_file}       ${output_folder}${/}pdf_archive.zip
${csv_url}        https://robotsparebinindustries.com/orders.csv
# -

***Keywords***
Abrir a janela do browser padrao da maquina
    ${website}=  Get Secret  websitedata
    ${nome}=  Get Secret  autor
    Open Available Browser  ${website}[url]
    Maximize Browser Window

# #Pontos
#     O comando archive não criará isso automaticamente, então precisamos garantir que o diretório esteja lá
#     Criar diretório não nos dará um erro se o diretório já existir.
#

***Keywords***
Remover e adcionar diretorios vazios
    [Arguments]  ${folder}
    Remove Directory  ${folder}  True
    Create Directory  ${folder}


***Keywords***
Passo de Inicializacao da criacao dos robos   
    Remove File  ${CURDIR}${/}orders.csv
    ${reciept_folder}=  Does Directory Exist  ${CURDIR}${/}reciepts
    ${robots_folder}=  Does Directory Exist  ${CURDIR}${/}robots
    Run Keyword If  '${reciept_folder}'=='True'  Remover e adcionar diretorios vazios  ${CURDIR}${/}reciepts  ELSE  Create Directory  ${CURDIR}${/}reciepts
    Run Keyword If  '${robots_folder}'=='True'  Remover e adcionar diretorios vazios  ${CURDIR}${/}robots  ELSE  Create Directory  ${CURDIR}${/}robots

***Keywords***
Ler o arquivo CVS na ordem correta
    ${data}=  Read Table From Csv  ${CURDIR}${/}orders.csv  header=True
    Return From Keyword  ${data}

***Keywords***
Processando as entradas de dados relativo a cada pedido de criacao de robo
    [Arguments]  ${row}
    Wait Until Page Contains Element  //button[@class="btn btn-dark"]
    Click Button  //button[@class="btn btn-dark"]
    Select From List By Value  //select[@name="head"]  ${row}[Head]
    Click Element  //input[@value="${row}[Body]"]
    Input Text  //input[@placeholder="Enter the part number for the legs"]  ${row}[Legs]
    Input Text  //input[@placeholder="Shipping address"]  ${row}[Address] 
    Click Button  //button[@id="preview"]
    Wait Until Page Contains Element  //div[@id="robot-preview-image"]
    Wait Until Element Is Visible   //*[@id="head"]
    Wait Until Element Is Enabled   //*[@id="head"]
    Click Button  //button[@id="order"]
    
    # O comando sleep é uma solução suja para o caso em que uma parte da imagem com três dobras ainda não foi carregada
    # Isso pode acontecer em velocidades de download muito reduzidas e resulta em uma imagem de destino incompleta.
    # Uma preferência seria ter uma palavra-chave como "Aguarde até que a imagem seja baixada" em vez deste hack rápido
    # mas mesmo o Selenium não suporta isso nativamente.
    #
    # Desculpe, companheiros - eu uso principalmente o Robot Framework para APIs REST. O teste da Web não é meu domínio principal :-)
    ## Defina as variáveis ​​locais para os elementos da IU
    # Isso supostamente ajuda com o congestionamento da rede (espero)
    # quando o carregamento de uma imagem demora muito e só terminaremos com um download parcial.

***Keywords***
Fechar a janela atual e abrir nova jkanela do browser antes de processar outro pedido
    Close Browser
    Abrir a janela do browser padrao da maquina
    Continue For Loop

*** Keywords ***
Realizando a conferencia dos recibos que foram processados ou nao 
    FOR  ${i}  IN RANGE  ${100}
        ${alert}=  Is Element Visible  //div[@class="alert alert-danger"]  
        Run Keyword If  '${alert}'=='True'  Click Button  //button[@id="order"] 
        Exit For Loop If  '${alert}'=='False'       
    END
    
    Run Keyword If  '${alert}'=='True'  Fechar a janela atual e abrir nova jkanela do browser antes de processar outro pedido 

***Keywords***
Processando a criacao de robos e geracao do recibo no final
    [Arguments]  ${row} 
    Page Should Contain Element  //*[@id="receipt"]
    ${reciept_data}=  Get Element Attribute  //div[@id="receipt"]  outerHTML
    Html To Pdf  ${reciept_data}  ${CURDIR}${/}reciepts${/}${row}[Order number].pdf
    Screenshot  //div[@id="robot-preview-image"]  ${CURDIR}${/}robots${/}${row}[Order number].png 
    Add Watermark Image To Pdf  ${CURDIR}${/}robots${/}${row}[Order number].png  ${CURDIR}${/}reciepts${/}${row}[Order number].pdf  ${CURDIR}${/}reciepts${/}${row}[Order number].pdf 
    Click Button  //button[@id="order-another"]
     
    #get o ID do pedido
    # Adicione os arquivos ao PDF
    #
    # Observação:
    #
    # 'anexar' requer o RPAframework mais recente. Atualize a versão no arquivo conda.yaml - caso contrário,
    # isso não funcionará. O arquivo gerado automaticamente pelo VSCode contém um número de versão muito antigo.
    #
    # por https://github.com/robocorp/rpaframework/blob/master/packages/pdf/src/RPA/PDF/keywords/document.py,
    # um "append" sempre adiciona uma NOVA página ao arquivo. Não vejo uma maneira de EMBARCAR a imagem da primeira página
    # que contém os dados do pedido

***Keywords***
Processando pedidos de criacao de robos
    [Arguments]  ${data}
    FOR  ${row}  IN  @{data}    
        Processando as entradas de dados relativo a cada pedido de criacao de robo  ${row}
        Realizando a conferencia dos recibos que foram processados ou nao 
        Processando a criacao de robos e geracao do recibo no final  ${row}      
    END  

***Keywords***
Baixar arquivo csv order
    Download  ${csv_url}  orders.csv
    Sleep  2 seconds

***Keywords***
Zippar a pasta de recibos
    Archive Folder With Zip  ${CURDIR}${/}reciepts  ${OUTPUT_DIR}${/}reciepts.zip

    # Crie o nome do arquivo

+***Keywords***
Buscando o nome do Author no Vault
    ${website}=  Get Secret  websitedata
    Log                     ${website}[username] escreveu esse programa de robo para vc!!      console=yes


*** Tasks ***
Lista da sequencia no qual o robo ira atuar para criacao e tratamento dos pedidos
    Passo de Inicializacao da criacao dos robos
    Baixar arquivo csv order
    ${data}=  Ler o arquivo CVS na ordem correta
    Abrir a janela do browser padrao da maquina
    Processando pedidos de criacao de robos  ${data}
    Zippar a pasta de recibos
    [Teardown]  Close Browser
    
    # Sequência que o Robo irá seguir
