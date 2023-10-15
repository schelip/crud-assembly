#Douglas Kenji Sakakibara RA117741
#Felipe Gabriel Comin Scheffel RA117306


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

    nextNode:           .int        0   # 145:  32-bit int

    # Strings de output
    opening:            .asciz      "\nPrograma para cadastro e consulta de imóveis\n"
    menuOp:             .asciz      "\nMenu de Opções\n<1> Cadastrar imóvel\n<2> Remover imóvel\n<3> Consultar imóveis\n<4> Exibir relatório\n<5> Finalizar\nDigite opcao => "
    errorOpeningFile:   .asciz      "\nHouve um erro ao abrir o arquivo, nenhuma propriedaade será lida."
    propertyNRead:      .asciz      "\nPropriedades lidas do disco: %d\n"
    propertyNWritten:   .asciz      "\nPropriedades salvas no disco: %d\n"
    emptyProperties:    .asciz      "\nNenhuma propriedade cadastrada.\n"

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
    longFormat:         .asciz      "%ld"
    strFormat:          .asciz      "%s"
    wSpaceStrFormat:    .asciz      "%35[^\n]%*c"
    byteFormat:         .asciz      "%1d"

    # Variáveis gerais
    option:             .int        0
    firstNode:          .int        0
    lastNode:           .int        0
    pProperty:          .int        0
    nextId:             .int        1
    propertyN:          .int        0

    # Constantes
    fileName:           .asciz      "properties.txt"
    structSize:         .int        145
    nodeSize:           .int        149

.section .bss
    .lcomm  structBuffer, 145
    .lcomm  fileHandle, 4

.section .text
.globl _start
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

    movl    $0, nextNode

_saveNewPropertyStruct:
    call    createNewNode               # Cria novo nó na posição adequada da lista com a memória alocada para a struct
    call    writeVariablesToStruct      # Escreve as variáveis na memória da struct
    call    saveStructsToFile           # Salva lista atualizada no disco
    RET

deleteProperty:
    # Remove uma propriedade escolhida a partir de seu ID
    RET

queryProperties:
    # Pesquisa um imovél cadastrado e gravado no arquivo usando como parâmetro o número de quartos do imóvel
    RET


showProperties:
    # Mostra os imoveis que foram registrados
    movl    firstNode, %edx             # Move o ponteiro que aponta para o primeiro nó da lista para edx 
    test    %edx, %edx                  # Se o primeiro nó da lista não for zero, as informações dos imóveis registrados serão mostrados
    jz      _emptyProperties            # Se não, não existe nenhum registro de imóvel cadastrado

_printNextProperty:
    call    readStructToVariables       # Carrega os dados da estrutura para as variáveis

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

    movl    nextNode, %edx              # Move o ponteiro que aponta para próximo nó da lista para o edx
    test    %edx, %edx                  # Se o valor movido para edx não for zero, ainda existe registros a serem mostrados
    jnz     _printNextProperty

    RET

_emptyProperties:
    pushl   $emptyProperties
    call    printf
    addl    $4, %esp

    RET

#### UTIL

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

createNewNode:
    # Aloca espaço de memória para a struct e adiciona na lista encadeada

    pushl   $nodeSize                   # Push do tamanho da struct para a alocar espaço de memória 
    call    malloc                      # Aloca mémoria para a struct 
    addl    $4, %esp                    # Desfaz o último push
    movl    %eax, pProperty             # Move o ponteiro da memória alocada para o eax 
    
_addToLinkedList:
    movl    firstNode, %eax             # Move o ponteiro que aponta para o primeiro nó para o eax 
    test    %eax, %eax                  # Se não existir nenhum no registro, o primeiro e o último nó serão o que está sendo registrado no momento
    jz      _addFirstNode

_updateLastNode:
    movl    pProperty, %ebx             # Move o ponteiro da struct para o ebx 
    movl    lastNode, %edx              # Move o ponteiro do último nó da lista para edx 
    movl    %ebx, 145(%edx)             # Move o ponteiro da struct para a posição do último nó da lista 
    movl    %ebx, lastNode              # Atualiza o ponteiro do último nó com o ponteiro da struct 
    movl    %ebx, %edx

    RET

_addFirstNode:
    movl    pProperty, %edx             # Move o ponteiro da struct para edx
    movl    %edx, firstNode             # Atualiza o ponteiro do primeiro nó com o ponteiro da struct 
    movl    %edx, lastNode              # Atualiza o ponteiro do último com o ponteiro da struct, pois esse é ainda o primeiro adicionado 

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
    
    movl    nextNode, %ecx
    movl    %ecx, 145(%edx)

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
    
    movl    145(%edx), %ecx
    movl    %ecx, nextNode

    RET

openFile:
    # Abertura do arquivo
    movl    $5, %eax                    # Carrega o valor da chamada de sistema para `fopen` para eax 
    movl    $fileName, %ebx             # Carega o nome do arquivo para ebx 
    movl    $0102, %ecx                 # Carrega a flag de permissão de leitura e escrita para ecx 
    movl    $0644, %edx                 # Carrega a flag de permissões para edx 
    int     $0x80                       # Executa a chamada de sistema

    RET

closeFile:
    # Fechamento do arquivo
    movl    $6, %eax                    # Carrega o valor da chamada de sistema para `fclose` para eax 
    movl    fileHandle, %ebx            # Carega o handle do arquivo para ebx
    int     $0x80                       # Executa chamada de sistema

    RET

saveStructsToFile:
    # Salva as structs alocadas que possuem as informações dos imóveis no arquivo

    call    openFile
    
    test    %eax, %eax                  # Se eax é positivo, o arquivo foi aberto com sucesso 
    js      _errorReadingFile           # Senão, ocorreu um erro na abertura do arquivo 

    movl    %eax, fileHandle            # Armazena file handle
    movl    firstNode, %edx

    movl    $0, propertyN

_saveNextStruct:
    test    %edx, %edx                  # Se edx edx != 0, existe pelo menos um nó(registro) para salvar no arquivo 
    jz      _endOfList                  # Senão, não exite nenhum nó(registro) para salvar

    pushl   145(%edx)                   # Backup do próximo nó 
    
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

    popl    %edx                        # Pop backup do próximo nó
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

    call    createNewNode               # Chama a função createNewNode para alocar espaço na memória para a struct

    leal    structBuffer, %esi          # Do buffer
    leal    0(%edx), %edi               # Para a struct
    movl    structSize, %ecx            # Move o tamanho da struct(quantidade de bytes da struct) para o ecx 
    cld
    rep     movsb

    movl    propertyN, %eax
    incl    %eax                        # Incrementa por um o número de structs que foram lidas 
    movl    %eax, propertyN             # Move o valor para propertyN(número de registros)

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

_errorReadingFile:
    pushl   $errorOpeningFile           # Push da mensagem de erro da leitura do arquivo 
    call    printf                      # Print da mensagem de erro 
    addl    $4, %esp                    # Desfaz o último push

    RET
 