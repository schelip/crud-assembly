.section .data
    # Property struct
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

    # Output strings
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

    # Input format strings
    intFormat:          .asciz      "%d"
    longFormat:         .asciz      "%ld"
    strFormat:          .asciz      "%s"
    wSpaceStrFormat:    .asciz      "%35[^\n]%*c"
    byteFormat:         .asciz      "%1d"

    # Variables
    option:             .int        0
    firstNode:          .int        0
    lastNode:           .int        0
    pProperty:          .int        0
    nextId:             .int        1
    propertyN:          .int        0

    # Constants
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
    pushl   $opening                    # Push opening message to stack
    call    printf                      # Print opening message
    addl    $4, %esp                    # Undo last push

    call    readPropertiesFromFile      # Read properties saved on file to memory

_mainMenu:
    call    showMainMenu                # Show options menu to user and get option

    cmpl    $5, option                  # If option was 5, finalize program
    je      _end

    call    handleOptions               # Else, redirect to chosen functionality
    
    jmp     _mainMenu                   # After done, start again

_end:
    pushl   $0                          # Successful execution code
    call    exit                        # Finish program

showMainMenu:
    pushl   $intFormat                  # Push int format string
    pushl   $option                     # Push option variable to store result
    pushl   $menuOp                     # Push option menu query string
    call    getInput                    # Get user input
    addl    $12, %esp                   # Undo last 3 pushes
    
    RET

handleOptions:
    cmpl    $1, option                  # If option chosen was 1, create new property from input
    je      createProperty

    cmpl    $2, option                  # Else if option chosen was 2, delete a property
    je      deleteProperty                

    cmpl    $3, option                  # Else if option chosen was 3, query properties by room number
    je      queryProperties
    
    cmpl    $4, option                  # Else if option chosen was 4, show all properties
    je      showProperties

    RET

createProperty:
    movl    nextId, %eax
    movl    %eax, id
    incl    %eax
    movl    %eax, nextId

    pushl   $strFormat
    pushl   $ownerName
    pushl   $ownerNamePrompt
    call    getInput
    addl    $12, %esp

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
    call    createNewNode               # Allocate memory for the struct and add to list
    call    writeVariablesToStruct      # Write all variables to the struct allocated memory
    call    saveStructsToFile           # Save updated list with new struct

    RET

deleteProperty:
    RET

queryProperties:
    RET

showProperties:
    movl    firstNode, %edx             # Move pointer to first node to edx
    test    %edx, %edx                  # If the first node is not zero, start printing
    jz      _emptyProperties            # Else, there are no properties

_printNextProperty:
    call    readStructToVariables       # Read struct bytes to variables

    pushl   id
    pushl   $idInfo
    call    printf
    addl    $8, %esp

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

    movl    nextNode, %edx              # Move pointer of next node on the list to edx
    test    %edx, %edx                  # If the pointer is not zero, there are still more nodes to be printed
    jnz     _printNextProperty

    RET

_emptyProperties:
    pushl   $emptyProperties
    call    printf
    addl    $4, %esp

    RET

#### UTIL
getInput:                               # (PROMPT, ADDR, FORMAT)
    pushl   %ebp                        # Save original value of ebp
    movl    %esp, %ebp                  # Copy current esp stack pointer to ebp

    pushl   8(%ebp)                     # Push prompt string
    call    printf                      # Print prompt
    addl    $4, %esp                    # Undo last push

    pushl   12(%ebp)                    # Push input variable address
    pushl   16(%ebp)                    # Push input format string
    call    scanf                       # Scan for user input
    addl    $8, %esp                    # Undo last 2 pushes
    
    movl    %ebp, %esp                  # Restore original stack pointer
    popl    %ebp                        # Restore original ebp

    RET

createNewNode:
    pushl   $nodeSize                   # Push struct size for allocation
    call    malloc                      # Allocate memory for the struct
    addl    $4, %esp                    # Undo last push
    movl    %eax, pProperty             # Move pointer for allocated memory to eax
    
_addToLinkedList:
    movl    firstNode, %eax             # Move pointer to the first node to eax
    test    %eax, %eax                  # If there are no nodes yet, first and last node will be this one
    jz      _addFirstNode

_updateLastNode:
    movl    pProperty, %ebx             # Move struct pointer to ebx
    movl    lastNode, %edx              # Move pointer to last node of list to edx
    movl    %ebx, 145(%edx)             # Move struct pointer to "next node" position of last node
    movl    %ebx, lastNode              # Update last node pointer with struct pointer
    movl    %ebx, %edx

    RET

_addFirstNode:
    movl    pProperty, %edx             # Move struct pointer to edx
    movl    %edx, firstNode             # Update first node with struct pointer
    movl    %edx, lastNode              # Update last node also, since it is the only node

    RET

writeVariablesToStruct:                 # EDX: pointer to the struct
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
    movl    $5, %eax                    # Load system call value for `fopen` to eax
    movl    $fileName, %ebx             # Load file name to ebx
    movl    $0102, %ecx                 # Load read write permission flag to ecx
    movl    $0644, %edx                 # Load permissions flag to edx
    int     $0x80                       # Execute system call

    RET

closeFile:
    movl    fileHandle, %ebx
    movl    $6, %eax
    int     $0x80

    RET

saveStructsToFile:
    call    openFile
    
    test    %eax, %eax                  # If eax is positive, sucess
    js      _errorReadingFile           # Else, error opening file

    movl    %eax, fileHandle            # Store file handle
    movl    firstNode, %edx

    movl    $0, propertyN

_saveNextStruct:
    test    %edx, %edx                  # If edx != 0, there is at least one node to save
    jz      _endOfList                  # Else, no more nodes

    pushl   145(%edx)                   # Backup next node
    
    leal    0(%edx), %esi               # From struct
    leal    structBuffer, %edi          # To buffer
    movl    structSize, %ecx            # Move structSize bytes
    cld
    rep     movsb
    
    movl    $4, %eax                    # Load system call value `write` to eax
    movl    fileHandle, %ebx            # Load file handle to ebx
    movl    $structBuffer, %ecx         # Load buffer address to ecx
    movl    structSize, %edx            # Load struct size to edx
    int     $0x80                       # Execute system call

    test    %eax, %eax                  # If eax >= 0, write was succesful
    js      _errorWritingToFile         # Else, error writing

    movl    propertyN, %eax
    incl    %eax                        # Increment number of properties written by 1
    movl    %eax, propertyN

    popl    %edx                        # Pop backup of next node
    jmp     _saveNextStruct

_endOfList:
    call    closeFile

    pushl   propertyN
    pushl   $propertyNWritten
    call    printf
    addl    $8, %esp

    RET

_errorWritingToFile:
    pushl   $errorOpeningFile           # Push error message
    call    printf                      # Print error message
    addl    $4, %esp                    # Undo last push

    RET

readPropertiesFromFile:
    call    openFile
    
    test    %eax, %eax                  # If eax is positive, sucess
    js      _errorReadingFile           # Else, error opening file

    movl    %eax, fileHandle            # Store file handle

_readNextStruct:
    movl    $3, %eax                    # Load system call value `read` to eax
    movl    fileHandle, %ebx            # Load file handle to ebx
    movl    $structBuffer, %ecx         # Load buffer to ecx
    movl    structSize, %edx            # Load number of bytes to be read to edx
    int     $0x80                       # Execute system call
    
    test    %eax, %eax                  # If eax <= 0, EOF
    js      _endOfFile
    jz      _endOfFile

    call    createNewNode               # Allocate memory for the struct

    leal    structBuffer, %esi          # From buffer
    leal    0(%edx), %edi               # To struct
    movl    structSize, %ecx            # move structSize bytes
    cld
    rep     movsb

    movl    propertyN, %eax
    incl    %eax                        # Increment number of structs read by 1
    movl    %eax, propertyN

    jmp     _readNextStruct

_endOfFile:
    call    closeFile

    pushl   propertyN
    pushl   $propertyNRead
    call    printf
    addl    $8, %esp

    movl    propertyN, %eax
    incl    %eax
    movl    %eax, nextId

    RET

_errorReadingFile:
    pushl   $errorOpeningFile           # Push error message
    call    printf                      # Print error message
    addl    $4, %esp                    # Undo last push

    RET
 