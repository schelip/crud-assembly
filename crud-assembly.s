# CRUD de imóveis
#
# Permite cadastro, deleção, consulta e relatório de imóveis em memória e gravação dos dados no disco.
#
# Autores:
# RA117741 | Douglas Kenji Sakakibara
# RA117306 | Felipe Gabriel Comin Scheffel
#
# Trabalho desenvolvido durante a disciplina de Programação de interfaceamente Hardware e Software
# Professora: Sandra Cossul
# Ciência da Computação - UEM - 2023

.section .data
    # Struct do imóvel
    id:                 .int        0   # 0:    32-bit int
    ownerName:          .space      36  # 4:    char[36]
    ownerPhone:         .space      15  # 40:   char[15]
    propType:           .byte       0   # 55:   bool
    addrCity:           .space      36  # 56:   char[36]
    addrDist:           .space      36  # 92:   char[36]
    bedroomN:           .int        0   # 128:  32-bit int
    suiteN:             .int        0   # 132:  32-bit int
    hasGarage:          .byte       0   # 136:  bool
    sqrMeters:          .int        0   # 137:  32-bit int
    rentPrice:          .int        0   # 141:  32-bit int

    # Strings de output
    opening:            .asciz      "\nPrograma para cadastro e consulta de imóveis\n"
    errorOpeningFile:   .asciz      "\nHouve um erro ao abrir o arquivo, nenhuma propriedaade será lida."
    propertyNRead:      .asciz      "\nPropriedades lidas do disco: %d\n"
    propertyNWritten:   .asciz      "\nPropriedades salvas no disco: %d\n"
    emptyProperties:    .asciz      "\nNenhuma propriedade cadastrada.\n"
    propNotFound:       .asciz      "\nPropriedade com ID %d não encontrada.\n"
    propDeleted:        .asciz      "\nPropriedade com ID %d deletada.\n"
    noPropsFiltered:    .asciz      "\nA consulta não retornou nenhum registro para o filtro de %d quartos.\n"
    totalPropsShown:    .asciz      "\nTotal de imóveis: %d\n"
    
    menuOp:             .asciz      "\nMenu de Opções\n<1> Cadastrar imóvel\n<2> Remover imóvel\n<3> Consultar imóveis\n<4> Exibir relatório\n<5> Finalizar\n=> "
    deletePropPrompt:   .asciz      "\nInforme o ID da propriedade a ser excluída => "
    queryPropPrompt:    .asciz      "\nInforme a quantidade total de quartos para a consulta => "
    ownerNamePrompt:    .asciz      "\nInforme o nome do proprietário => "
    ownerPhonePrompt:   .asciz      "Informe o telefone do proprietário (somente números) => "
    propTypePrompt:     .asciz      "Informe o tipo de propriedade (<0> Casa ou <1> Apartamento) => "
    addrCityPrompt:     .asciz      "Informe a cidade => "
    addrDistPrompt:     .asciz      "Informe o bairro => "
    bedroomNPrompt:     .asciz      "Informe o número de quartos => "
    suiteNPrompt:       .asciz      "Informe o número de suítes => "
    hasGaragePrompt:    .asciz      "A propriedade tem garagem? (<0> Não ou <1> Sim) => "
    sqrMetersPrompt:    .asciz      "Informe a área em metros quadrados => "
    rentPricePrompt:    .asciz      "Informe o preço do aluguel => "

    idInfo:             .asciz      "\nID: %d"
    ownerNameInfo:      .asciz      "\nNome do proprietário: %s"
    ownerPhoneInfo:     .asciz      "\nTelefone do proprietário: %s"
    propTypeInfo:       .asciz      "\nTipo de propriedade (<0> Casa ou <1> Apartamento): %d"
    addrCityInfo:       .asciz      "\nCidade: %s"
    addrDistInfo:       .asciz      "\nBairro: %s"
    bedroomNInfo:       .asciz      "\nNúmero de quartos: %d"
    suiteNInfo:         .asciz      "\nNúmero de suítes: %d"
    hasGarageInfo:      .asciz      "\nA propriedade tem garagem? (<0> Não ou <1> Sim): %d"
    sqrMetersInfo:      .asciz      "\nÁrea em metros quadrados: %d"
    rentPriceInfo:      .asciz      "\nPreço do aluguel: %d\n"

    # Strings de formatos para input
    intFormat:          .asciz      "%d"
    strFormat:          .asciz      "%s"
    byteFormat:         .asciz      "%1d"

    # Variáveis gerais
    option:             .int        0
    firstNode:          .int        0
    lastNode:           .int        0
    pProperty:          .int        0
    nextId:             .int        1
    propertyN:          .int        0
    totalRoomQuery:     .int        0

    # Constantes
    fileName:           .asciz      "properties.data"
    structSize:         .int        145
    nodeSize:           .int        149

.section .bss
    .lcomm  structBuffer, 145
    .lcomm  fileHandle, 4

.section .text
.globl _start

# MAIN ############################################################################################################################################################################

_start:
    nop
    pushl   $opening                    # Push da mensagem de abertura para a pilha
    call    printf                      # Print da mensagem de abertura
    addl    $4, %esp                    # Desfaz o ultimo push

    call    readPropertiesFromFile      # Leitura das propriedas salvas no arquivo em memoria

    _mainMenu:
    call    showMainMenu                # Chama a funcao showMainMenu 

    cmpl    $5, option                  # Se a opção selecionada for 5, o programa é encerrado 
    je      _end

    call    handleOptions               # Senão, a função handleOptions é chamada 
    
    jmp     _mainMenu                   # Após terminado, começa novamente e mostra o menu inicial

    _end:
    pushl   $0                          # O programa foi executado com sucesso
    call    exit                        # Programa é encerrado 

showMainMenu:                           
    # Apresenta as opções disponiveis para o usuário e recebe a opção selecionada pelo usuário

    pushl   $intFormat                  # Push da string de formatação para int
    pushl   $option                     # Push da variável que armazena a opção selecionada do menu 
    pushl   $menuOp                     # Push do menu de opções a ser selecionado pelo usuário 
    call    getInput                    # Chama a função getInput 
    addl    $12, %esp                   # Desfaz os últimos 3 push 
    
    RET

handleOptions:
    # Direciona o usuário para opção selecionada

    cmpl    $1, option                  # Se a opção selecionada for 1, a função createProperty é chamada 
    je      createProperty

    cmpl    $2, option                  # Se a opção selecionada for 2, a função deleteProperty é chamada 
    je      deleteProperty                

    cmpl    $3, option                  # Se a opção selecionada for 3, a função queryProperties é chamada 
    je      queryProperties
    
    cmpl    $4, option                  # Se a opção selecionada for 4, a função showProperties é chamada
    je      showProperties

    RET

# CRUD ############################################################################################################################################################################

createProperty:
    # Cria um novo registro de um imóvel para locação
    
    movl    nextId, %eax
    movl    %eax, id
    incl    %eax                        # Incrementa o id para o próximo registro a ser cadastrado 
    movl    %eax, nextId                # Armazena o valor do id para o próximo registro a ser cadastrado na váriavel nextId

    pushl   $strFormat                  # Push do formato da variável
    pushl   $ownerName                  # Push da endereço da variável da struct  
    pushl   $ownerNamePrompt            # Push do prompt
    call    getInput                    # Chama a função getInput para receber a entrada do usuário
    addl    $12, %esp                   # Desfaz os últimos 3 push

    # Repetir processo para todos os campos

    pushl   $strFormat
    pushl   $ownerPhone
    pushl   $ownerPhonePrompt
    call    getInput
    addl    $12, %esp

    pushl   $byteFormat
    pushl   $propType
    pushl   $propTypePrompt
    call    getInput
    addl    $12, %esp

    pushl   $strFormat
    pushl   $addrCity
    pushl   $addrCityPrompt
    call    getInput
    addl    $12, %esp

    pushl   $strFormat
    pushl   $addrDist
    pushl   $addrDistPrompt
    call    getInput
    addl    $12, %esp

    pushl   $intFormat
    pushl   $bedroomN
    pushl   $bedroomNPrompt
    call    getInput
    addl    $12, %esp

    pushl   $intFormat
    pushl   $suiteN
    pushl   $suiteNPrompt
    call    getInput
    addl    $12, %esp

    pushl   $byteFormat
    pushl   $hasGarage
    pushl   $hasGaragePrompt
    call    getInput
    addl    $12, %esp

    pushl   $intFormat
    pushl   $sqrMeters
    pushl   $sqrMetersPrompt
    call    getInput
    addl    $12, %esp

    pushl   $intFormat
    pushl   $rentPrice
    pushl   $rentPricePrompt
    call    getInput
    addl    $12, %esp

    _saveNewPropertyStruct:
    movl    bedroomN, %ebx              # Adiciona número de quartos simples ao total de quartos do imóvel
    addl    suiteN, %ebx                # Adiciona número de suites ao total de quartos do imóvel

    call    createNewNode               # Cria novo nó na posição adequada da lista com a memória alocada para a struct
    call    writeVariablesToStruct      # Escreve as variáveis na memória da struct
    call    saveStructsToFile           # Salva lista atualizada no disco
    RET

deleteProperty:
    # Remove uma propriedade escolhida a partir de seu ID

    pushl   $intFormat                  # Push do formato de int
    pushl   $id                         # Push da variável de id
    pushl   $deletePropPrompt           # Push do prompt para obter id da propriedade a deletar
    call    getInput                    # Obtém input
    addl    $12, %esp                   # Desfaz últimos 3 push

    movl    id, %eax                    # Move id obtido para eax

    movl    firstNode, %edx             # Move o ponteiro que aponta para o primeiro nó da lista para edx, para a iteração
    mov     firstNode, %ecx             # Será mantida uma referência ao nó anterior em ecx
    test    %edx, %edx                  # Se o primeiro nó da lista não for zero, buscar propriedade
    jz      _printEmptyPropertiesMsg    # Se não, não existe nenhum registro de imóvel cadastrado

    _checkIdNextProperty:
    movl    0(%edx), %ebx               # Move id da próxima propriedade para ebx
    
    cmpl    %ebx, %eax                  # Se forem diferente, continuar iterando
    je      _deleteProp                 # Se não, foi encontrado, realizar deleção

    movl    %edx, %ecx                  # Atualiza ecx com o nó da iteração
    movl    145(%edx), %edx             # Move o ponteiro que aponta para próximo nó da lista para edx
    test    %edx, %edx                  # Se o valor movido para edx não for zero, ainda existe registros a serem mostrados
    jz      _printPropertyNotFoundMsg   # Se não, acabou a lista e ID não foi encontrado

    jmp     _checkIdNextProperty

    _deleteProp:
    cmpl    firstNode, %edx
    je      _deleteFirstNode

    cmpl    lastNode, %edx
    je      _deleteLastNode

    _deleteMiddleNode:
    movl    145(%edx), %ebx             # Move o ponteiro do próximo nó da lista para ebx
    movl    %ebx, 145(%ecx)             # Altera nó anterior para apontar para próximo nó, removendo o nó atual da lista

    jmp     _finishedDelete

    _deleteFirstNode:
    cmpl    lastNode, %edx
    je      _deleteOnlyNode

    movl    145(%edx), %ebx             # Move o ponteiro do próximo nó da lista para ebx
    movl    %ebx, firstNode             # Seta próximo nó como primeiro, removendo atual primeiro nó

    jmp     _finishedDelete

    _deleteLastNode:
    movl    145(%ecx), %ebx             # Move o ponteiro do nó anterior da lista para ebx
    movl    $0, 145(%ecx)               # Altera ponteiro para próximo do nó anterior para nulo
    movl    %ebx, lastNode              # Seta nó anterior como último, removendo atual último nó

    jmp     _finishedDelete
    
    _deleteOnlyNode:
    movl    $0, firstNode               # Seta nenhum nó como primeiro
    movl    $0, lastNode                # Seta nenhum nó como último

    _finishedDelete:
    pushl   %edx                        # Push do ponteiro do nó a ser deletado
    call    free                        # Limpa memória
    addl    $4, %esp                    # Desfaz último push

    pushl   id                          # Push do ID da busca
    pushl   $propDeleted                # Push da mensagem de imóvel não encontrado
    call    printf                      # Imprime mensagem na tela
    addl    $8, %esp                    # Desfaz 2 últimos push

    call    saveStructsToFile           # Salva lista atualizada

    RET

queryProperties:
    # Pesquisa os imovéis cadastrados que tenham um certo total de quartos

    movl    firstNode, %edx             # Move o ponteiro que aponta para o primeiro nó da lista para edx 
    test    %edx, %edx                  # Se o primeiro nó da lista não for zero, as informações dos imóveis registrados serão mostrados
    jz      _printEmptyPropertiesMsg    # Se não, não existe nenhum registro de imóvel cadastrado

    pushl   %edx                        # Backup edx

    pushl   $intFormat                  # Push do formato de int
    pushl   $totalRoomQuery             # Push da variável da consulta
    pushl   $queryPropPrompt            # Push do prompt para obter filtro da consulta
    call    getInput                    # Obtém input
    addl    $12, %esp                   # Desfaz últimos 3 push

    popl    %edx                        # Backup edx

    movl    $1, propertyN               # Reinicia variável para realizar contagem

    _findFirstFiltered:
    call    getTotalNumberOfRooms       # Obtendo número total de quartos do imóvel do nó

    cmpl    %eax, totalRoomQuery        # Se forem diferentes, continuar iterando
    je      _printNextFiltered          # Se não, começar impressão

    movl    145(%edx), %edx             # Move o ponteiro que aponta para próximo nó da lista para o edx
    test    %edx, %edx                  # Se o valor movido para edx for zero, nenhum registro se adequou a busca
    jnz     _findFirstFiltered          # Se não, continuar iterando

    _printNoPropsFiltered:
    pushl   totalRoomQuery              # Push da variável da consulta
    pushl   $noPropsFiltered            # Push da mensagem de nenhum imóvel filtrado na consulta
    call    printf                      # Imprime mensagem
    addl    $8, %esp                    # Desfaz 2 últimos push

    RET

    _printNextFiltered:
    call    readStructToVariables       # Carrega os dados da estrutura para as variáveis

    pushl   %edx                        # Backup edx

    call    printPropertyFields         # Imprime campos

    popl    %edx                        # Backup edx

    movl    145(%edx), %edx             # Move o ponteiro que aponta para próximo nó da lista para o edx
    test    %edx, %edx                  # Se o valor movido para edx não for zero, ainda existem registros a serem mostrados
    jz      _queryFinished              # Se não, fim da consulta

    call    getTotalNumberOfRooms

    cmpl    %eax, totalRoomQuery        # Se forem iguais, continuar iterando
    jne     _queryFinished              # Se não, fim da consulta

    movl    propertyN, %eax
    incl    %eax                        # Incrementa por um o número de registros consultados 
    movl    %eax, propertyN

    jmp     _printNextFiltered

    _queryFinished:
    pushl   propertyN
    pushl   $totalPropsShown
    call    printf
    addl    $8, %esp

    RET

showProperties:
    # Mostra os imoveis que foram registrados
    movl    firstNode, %edx             # Move o ponteiro que aponta para o primeiro nó da lista para edx 
    test    %edx, %edx                  # Se o primeiro nó da lista não for zero, as informações dos imóveis registrados serão mostrados
    jz      _printEmptyPropertiesMsg    # Se não, não existe nenhum registro de imóvel cadastrado

    movl    $1, propertyN               # Reinicia variável para realizar contagem

    _printNextProperty:
    call    readStructToVariables       # Carrega os dados da estrutura para as variáveis

    pushl   %edx                        # Backup edx

    call    printPropertyFields         # Imprime campos

    popl    %edx                        # Backup edx

    movl    145(%edx), %edx             # Move o ponteiro que aponta para próximo nó da lista para o edx
    test    %edx, %edx                  # Se o valor movido para edx não for zero, ainda existe registros a serem mostrados
    jz      _showFinished

    movl    propertyN, %eax
    incl    %eax                        # Incrementa por um o número de registros consultados 
    movl    %eax, propertyN

    jmp     _printNextProperty

    _showFinished:
    pushl   propertyN
    pushl   $totalPropsShown
    call    printf
    addl    $8, %esp

    RET

# PERSISTENCE #####################################################################################################################################################################

saveStructsToFile:
    # Salva as structs alocadas que possuem as informações dos imóveis no arquivo

    movl    $01102, %ecx                 # Flags de truncamento, criação e acesso de leitura/escrita
    call    openFile
    
    test    %eax, %eax                  # Se eax é positivo, o arquivo foi aberto com sucesso 
    js      _errorReadingFile           # Senão, ocorreu um erro na abertura do arquivo 

    movl    %eax, fileHandle            # Armazena file handle
    movl    firstNode, %edx

    movl    $0, propertyN

    _saveNextStruct:
    test    %edx, %edx                  # Se edx edx != 0, existe pelo menos um nó(registro) para salvar no arquivo 
    jz      _endOfList                  # Senão, não exite nenhum nó(registro) para salvar

    pushl   %edx                        # Backup edx
    
    leal    0(%edx), %esi               # Da struct 
    leal    structBuffer, %edi          # Para o buffer
    movl    structSize, %ecx            # Move o tamanho da struct para o ecx
    cld
    rep     movsb
    
    movl    $4, %eax                    # Carrega o valor da chamada de sistema `write` para eax
    movl    fileHandle, %ebx            # Carrega o file handle para ebx 
    movl    $structBuffer, %ecx         # Carrega o endereço do buffer para o ecx 
    movl    structSize, %edx            # Carrega o tamanho da struct para o edx 
    int     $0x80                       # Executa a chamada de sistema 

    test    %eax, %eax                  # Se eax >=0, a escrita foi realizada com sucesso 
    js      _errorWritingToFile         # Senão, ocorreu um erro na escrita 

    movl    propertyN, %eax
    incl    %eax                        # Incrementa por um o número de registros escritos 
    movl    %eax, propertyN

    popl    %edx                        # Backup edx
    movl    145(%edx), %edx             # Iterando para o próximo nó
    jmp     _saveNextStruct

    _endOfList:
    call    closeFile                   # Chama a função closeFile para fechar o arquivo

    pushl   propertyN                   # Push da variável propertyN
    pushl   $propertyNWritten           # Push da mensagem de saída propertyNWritten
    call    printf
    addl    $8, %esp                    # Desfaz os últimos dois push

    RET

    _errorWritingToFile:
    pushl   $errorOpeningFile           # Push da mensagem de erro error message
    call    printf                      # Print da mensagem de erro error message
    addl    $4, %esp                    # Desfaz o último push

    RET

readPropertiesFromFile:
    # Leitura dos registros dos imóveis do arquivo 

    movl    $0102, %ecx                 # Flags de criação e acesso de leitura/escrita
    call    openFile
    
    test    %eax, %eax                  # Se eax é positivo, a leitura do registro armazenado no arquivo foi realizada com sucesso
    js      _errorReadingFile           # Senão ocorreu um erro na leitura do arquivo 

    movl    %eax, fileHandle            # Armazena o file handle 

    _readNextStruct:
    movl    $3, %eax                    # Carrega o valor da chamada de sistema `read` para o eax 
    movl    fileHandle, %ebx            # Carrega o file handle para o ebx 
    movl    $structBuffer, %ecx         # Carrega o buffer para o ecx 
    movl    structSize, %edx            # Carrega o número de bytes a ser lido para o edx 
    int     $0x80                       # Executa a chamada de sistema 
    
    test    %eax, %eax                  # Se eax <= 0, EOF
    js      _endOfFile
    jz      _endOfFile

    movl    $0, %ebx
    call    createNewNode               # Chama a função createNewNode para alocar espaço na memória para a struct

    leal    structBuffer, %esi          # Do buffer
    leal    0(%edx), %edi               # Para a struct
    movl    structSize, %ecx            # Move o tamanho da struct(quantidade de bytes da struct) para o ecx 
    cld
    rep     movsb

    movl    propertyN, %eax
    incl    %eax                        # Incrementa por um o número de structs que foram lidas 
    movl    %eax, propertyN             # Move o valor para propertyN(número de registros)

    movl    0(%edx), %eax               # Move id da estrutura para eax
    cmpl    %eax, nextId                # Se o id da estrutura lida for maior ou igual ao nextId atual, deve ser atualizado
    jg      _readNextStruct             # Se não, não é necessário atualizar

    incl    %eax                        # Soma 1 ao id da estrutura
    movl    %eax, nextId                # Salva o próximo id na variável

    jmp     _readNextStruct

    _endOfFile:
    call    closeFile                   # Chama a função closeFile para fechar o arquivo 
    pushl   propertyN                   # Push da variável propertyN
    pushl   $propertyNRead              # Push da mensagem de saída propertyNRead
    call    printf
    addl    $8, %esp                    # Desfaz os último dois push

    movl    propertyN, %eax             
    incl    %eax                        # Incrementa por um o número de structs que foram lidas
    movl    %eax, nextId                # Move o valor para nextId

    RET

# UTILS ###########################################################################################################################################################################

getInput:                               
    # Exibe uma mensagem de prompt e recebe um input do usuário
    # Args: (PROMPT, ADDR, FORMAT)

    pushl   %ebp                        # Salva o valor original de ebp 
    movl    %esp, %ebp                  # Copia o ponteiro atual da pilha esp para ebp Copy current esp stack pointer to ebp

    pushl   8(%ebp)                     # Push prompt string
    call    printf                      # Print prompt
    addl    $4, %esp                    # Desfaz o último push

    pushl   12(%ebp)                    # Push o endereço da varáivel 
    pushl   16(%ebp)                    # Push input format string
    call    scanf                       # Leitura da entrada digitada pelo usuário 
    addl    $8, %esp                    # Desfaz os últimos dois push
    
    movl    %ebp, %esp                  # Recupera o ponteiro da pilha 
    popl    %ebp                        # Recupera o registrador ebp original  

    RET

writeVariablesToStruct:
    # Escreve as variáveis que possuem as informações do imovél na struct alocada
    # Args: (edx: STRUCT_PNTR)

    movl    id, %ecx
    movl    %ecx, 0(%edx)

    leal    ownerName, %esi
    leal    4(%edx), %edi
    movl    $36, %ecx
    cld
    rep     movsb

    leal    ownerPhone, %esi
    leal    40(%edx), %edi
    movl    $15, %ecx
    cld
    rep     movsb

    movb    propType, %cl
    movb    %cl, 55(%edx)

    leal    addrCity, %esi
    leal    56(%edx), %edi
    movl    $36, %ecx
    cld
    rep     movsb

    leal    addrDist, %esi
    leal    92(%edx), %edi
    movl    $36, %ecx
    cld
    rep     movsb

    movl    bedroomN, %ecx
    movl    %ecx, 128(%edx)

    movl    suiteN, %ecx
    movl    %ecx, 132(%edx)

    movb    hasGarage, %cl
    movb    %cl, 136(%edx)

    movl    sqrMeters, %ecx
    movl    %ecx, 137(%edx)

    movl    rentPrice, %ecx
    movl    %ecx, 141(%edx)
    
    RET

readStructToVariables:
    # Realiza a leitura dos bytes da struct que contem os dados do imóvel e armazena os valores nas variaveis
    # Args: (edx: STRUCT_PNTR)

    movl    0(%edx), %ecx
    movl    %ecx, id

    leal    4(%edx), %esi
    leal    ownerName, %edi
    movl    $36, %ecx
    cld
    rep     movsb

    leal    40(%edx), %esi
    leal    ownerPhone, %edi
    movl    $15, %ecx
    cld
    rep     movsb

    movb    55(%edx), %cl
    movb    %cl, propType

    leal    56(%edx), %esi
    leal    addrCity, %edi
    movl    $36, %ecx
    cld
    rep     movsb

    leal    92(%edx), %esi
    leal    addrDist, %edi
    movl    $36, %ecx
    cld
    rep     movsb

    movl    128(%edx), %ecx
    movl    %ecx, bedroomN

    movl    132(%edx), %ecx
    movl    %ecx, suiteN

    movb    136(%edx), %cl
    movb    %cl, hasGarage

    movl    137(%edx), %ecx
    movl    %ecx, sqrMeters
    
    movl    141(%edx), %ecx
    movl    %ecx, rentPrice
    
    RET

printPropertyFields:
    # Imprime todas as variáveis de campos da struct no console

    pushl   id                          # Push da variável da struct
    pushl   $idInfo                     # Push do prompt
    call    printf
    addl    $8, %esp                    # Desfaz os últimos 2 push

    # Repetir processo para todos os campos

    pushl   $ownerName
    pushl   $ownerNameInfo
    call    printf
    addl    $8, %esp

    pushl   $ownerPhone
    pushl   $ownerPhoneInfo
    call    printf
    addl    $8, %esp

    movl    $0, %eax
    movb    propType, %al
    pushl   %eax
    pushl   $propTypeInfo
    call    printf
    addl    $8, %esp

    pushl   $addrCity
    pushl   $addrCityInfo
    call    printf
    addl    $8, %esp

    pushl   $addrDist
    pushl   $addrDistInfo
    call    printf
    addl    $8, %esp

    pushl   bedroomN
    pushl   $bedroomNInfo
    call    printf
    addl    $8, %esp

    pushl   suiteN
    pushl   $suiteNInfo
    call    printf
    addl    $8, %esp

    movl    $0, %eax
    movb    hasGarage, %al
    pushl   %eax
    pushl   $hasGarageInfo
    call    printf
    addl    $8, %esp

    pushl   sqrMeters
    pushl   $sqrMetersInfo
    call    printf
    addl    $8, %esp

    pushl   rentPrice
    pushl   $rentPriceInfo
    call    printf
    addl    $8, %esp

    RET

openFile:
    # Abertura do arquivo
    # Args: (ecx: FLAG)

    movl    $5, %eax                    # Carrega o valor da chamada de sistema para `fopen` para eax 
    movl    $fileName, %ebx             # Carega o nome do arquivo para ebx 
    movl    $0644, %edx                 # Carrega a flag de permissões para edx 
    int     $0x80                       # Executa a chamada de sistema

    RET

closeFile:
    # Fechamento do arquivo

    movl    $6, %eax                    # Carrega o valor da chamada de sistema para `fclose` para eax 
    movl    fileHandle, %ebx            # Carega o handle do arquivo para ebx
    int     $0x80                       # Executa chamada de sistema

    RET

    _errorReadingFile:
    pushl   $errorOpeningFile           # Push da mensagem de erro da leitura do arquivo 
    call    printf                      # Print da mensagem de erro 
    addl    $4, %esp                    # Desfaz o último push

    RET
 
getTotalNumberOfRooms:
    # Calcula total de quartos de um imóvel
    # Args: (edx: STRUCT_PNTR)
    # Out: (eax: TOTAL_ROOM_N)
    
    movl    128(%edx), %eax             # Adiciona número de quartos simples ao total
    addl    132(%edx), %eax             # Adiciona número de suites ao total

    RET

createNewNode:
    # Aloca espaço de memória para a struct e adiciona na lista encadeada
    # Args: (ebx: ROOM_N)
    # Out:  (edx: STRUCT_PNTR)

    pushl   $nodeSize                   # Push do tamanho da struct para a alocar espaço de memória 
    call    malloc                      # Aloca mémoria para a struct 
    addl    $4, %esp                    # Desfaz o último push
    movl    %eax, pProperty             # Salva o ponteiro da memória alocada na variável
    
    movl    firstNode, %edx             # Move o ponteiro que aponta para o primeiro nó para o edx 
    test    %edx, %edx                  # Se não existir nenhum no registro, o primeiro e o último nó serão o que está sendo registrado no momento
    jz      _addAsOnlyNode

    test    %ebx, %ebx                  # Se foi passado um valor de total de quartos diferente 0, o nó será inserido ordenamente com base nesse valor
    jz      _addAsLastNode              # Se não, o nó vai ser criado no fim da lista

    call    getTotalNumberOfRooms       # Calculando total de quartos no primeiro nó

    cmpl    %ebx, %eax                  # Se o novo nó tem mais ou igual quartos que o primeiro, deve ser procurada a posição correta
    jg      _addAsFirstNode             # Se não, é inserido no começo da lista

    _checkNextNode:
    movl    %edx, %ecx                  # O nó "atual", que será o nó precedendo o novo, é mantido em ecx
    movl    145(%edx), %edx             # O "próximo" nó, que deve ter mais quartos que o novo, é mantido em edx

    test    %edx, %edx                  # Se não existe próximo nó, adicionar no fim da lista
    jz      _addAsLastNode

    call    getTotalNumberOfRooms       # Obtém total de quartos do nó sendo analisado

    cmpl    %eax, %ebx                  # Se o nó analisado tem mais quartos que o novo, posição foi encontrada
    jge     _checkNextNode              # Se não, checar próximo nó

    _addNode:
    movl    pProperty, %ebx             # Carrega novo nó em ebx
    movl    %edx, 145(%ebx)             # Seta próximo como o nó na posição encontrada
    movl    %ebx, 145(%ecx)             # Seta novo nó como próximo nó do anterior a posição encontrada
    
    movl    %ebx, %edx                  # Ponteiro para novo nó como valor de saída

    RET

    _addAsFirstNode:
    movl    pProperty, %ebx             # Carrega ponteiro para novo nó em ebx
    movl    %edx, 145(%ebx)             # Salva antigo primeiro como novo segundo nó
    movl    %ebx, firstNode             # Salva novo nó como primeiro
    
    movl    %ebx, %edx                  # Ponteiro para novo nó como saída

    RET

    _addAsLastNode:
    movl    pProperty, %edx             # Move o ponteiro da struct para o ebx 
    movl    lastNode, %ebx              # Move o ponteiro do último nó da lista para edx 
    movl    %edx, 145(%ebx)             # Move o ponteiro da struct para a posição do último nó da lista 
    movl    %edx, lastNode              # Atualiza o ponteiro do último nó com o ponteiro da struct 
    
    RET

    _addAsOnlyNode:
    movl    pProperty, %edx             # Move o ponteiro da struct para edx
    movl    %edx, firstNode             # Atualiza o ponteiro do primeiro nó com o ponteiro da struct 
    movl    %edx, lastNode              # Atualiza o ponteiro do último com o ponteiro da struct, pois esse é ainda o primeiro adicionado 

    RET

_printEmptyPropertiesMsg:
    # Imprime mensagem de nenhum imóvel cadastrado

    pushl   $emptyProperties            # Push da mensagem de nenhum imóvel
    call    printf                      # Imprime mensagem na tela
    addl    $4, %esp                    # Desfaz último push

    RET

_printPropertyNotFoundMsg:
    # Imprime mensagem de imóvel não encontrado

    pushl   id                          # Push do ID da busca
    pushl   $propNotFound               # Push da mensagem de imóvel não encontrado
    call    printf                      # Imprime mensagem na tela
    addl    $8, %esp                    # Desfaz 2 últimos push

    RET
