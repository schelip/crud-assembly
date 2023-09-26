.section .data
	# Property struct
	ownerName:			.space	144		# 0: char[36]
	ownerPhone:			.space	60		# 144: char[15]
	propType:			.byte	0		# 204: bool
	addrCity:			.space	144		# 205: char[36]
	addrDist:			.space	144		# 349: char[36]
	roomN:				.int	0		# 493: 32-bit int
	suiteN:				.int	0		# 497: 32-bit int
	hasGarage:			.byte	0		# 501: bool
	sqrMeters:			.int	0		# 502: 32-bit int
	rentPrice:			.int	0		# 506: 32-bit int
	
	nextNode:			.int	0		# 510: 32-bit int

	structSize:			.int	514

	# Output strings
	opening:			.asciz	"\nPrograma para cadastro e consulta de imóveis\n"
	menuOp:				.asciz	"\nMenu de Opcoes\n<1> Cadastrar imóvel\n<2> Remover imóvel\n<3> Consultar imóveis\n<4> Exibir relatório\n<5> Finalizar\nDigite opcao => "

	ownerNamePrompt:	.asciz	"\nInforme o nome do proprietário => "
	ownerPhonePrompt:	.asciz	"Informe o telefone do proprietário (somente números) => "
	propTypePrompt:		.asciz	"Informe o tipo de propriedade (<0> Casa ou <1> Apartamento) => "
	addrCityPrompt:		.asciz	"Informe a cidade => "
	addrDistPrompt:		.asciz	"Informe o bairro => "
	roomNPrompt:		.asciz	"Informe o número de quartos => "
	suiteNPrompt:		.asciz	"Informe o número de suítes => "
	hasGaragePrompt:	.asciz	"A propriedade tem garagem? (<0> Não ou <1> Sim) => "
	sqrMetersPrompt:	.asciz	"Informe a área em metros quadrados => "
	rentPricePrompt:	.asciz	"Informe o preço do aluguel => "

	ownerNameInfo:		.asciz	"\nNome do proprietário: %s"
	ownerPhoneInfo:		.asciz	"\nTelefone do proprietário: %s"
	propTypeInfo:		.asciz	"\nTipo de propriedade (<0> Casa ou <1> Apartamento): %d"
	addrCityInfo:		.asciz	"\nCidade: %s"
	addrDistInfo:		.asciz	"\nBairro: %s"
	roomNInfo:			.asciz	"\nNúmero de quartos: %d"
	suiteNInfo:			.asciz	"\nNúmero de suítes: %d"
	hasGarageInfo:		.asciz	"\nA propriedade tem garagem? (<0> Não ou <1> Sim): %d"
	sqrMetersInfo:		.asciz	"\nÁrea em metros quadrados: %d"
	rentPriceInfo:		.asciz	"\nPreço do aluguel: %d\n"
	
	# Input format strings
	intFormat:			.asciz	"%d"
	longFormat:			.asciz	"%ld"
	strFormat:			.asciz	"%s"
	wSpaceStrFormat:	.asciz	"%35[^\n]%*c"
	byteFormat:			.asciz	"%1d"

	# Variables
	option:				.int	0
	firstNode:			.int	0
	lastNode:			.int	0
	pProperty:			.int	0


.section .text
.globl _start
_start:
	nop
	pushl	$opening
	call	printf
	addl	$4, %esp
	
	call	showMenuOptions

	cmpl	$5, option
	je	_end

	call	handleOptions
	
	jmp	_start

_end:
	pushl	$0
	call	exit

showMenuOptions:
	pushl	$intFormat
	pushl	$option
	pushl	$menuOp
	call	getInput
	addl	$12, %esp
	
	RET

handleOptions:
	cmpl	$1, option
	je	createProperty

	cmpl	$2, option
	je	deleteProperty

	cmpl	$3, option
	je	queryProperties
	
	cmpl	$4, option
	je	showProperties

	RET

createProperty:
    pushl	$strFormat
    pushl   $ownerName
    pushl   $ownerNamePrompt
	call	getInput
	addl	$12, %esp

    pushl	$strFormat
    pushl   $ownerPhone
    pushl   $ownerPhonePrompt
	call	getInput
	addl	$12, %esp

	pushl	$byteFormat
    pushl   $propType
    pushl   $propTypePrompt
    call    getInput
	addl	$12, %esp

    pushl	$strFormat
    pushl   $addrCity
    pushl   $addrCityPrompt
	call	getInput
	addl	$12, %esp

    pushl	$strFormat
    pushl   $addrDist
    pushl   $addrDistPrompt
	call	getInput
	addl	$12, %esp

	pushl	$intFormat
    pushl   $roomN
    pushl   $roomNPrompt
    call    getInput
	addl	$12, %esp

	pushl	$intFormat
    pushl   $suiteN
    pushl   $suiteNPrompt
    call    getInput
	addl	$12, %esp

	pushl	$byteFormat
    pushl   $hasGarage
    pushl   $hasGaragePrompt
    call    getInput
	addl	$12, %esp

	pushl	$intFormat
    pushl   $sqrMeters
    pushl   $sqrMetersPrompt
    call    getInput
	addl	$12, %esp

	pushl	$intFormat
    pushl   $rentPrice
    pushl   $rentPricePrompt
    call    getInput
	addl	$12, %esp

	movl	$0, nextNode

_initializeStruct:
    pushl   $structSize
    call    malloc
    addl    $4, %esp
    movl    %eax, pProperty

	movl    pProperty, %edx
	call	writeVariablesToStruct

_addToLinkedList:
	movl	firstNode, %eax
	cmpl	$0, %eax
	je	_addFirstNode

_updateLastNode:
	movl	%edx, %ebx
	movl	lastNode, %edx
	movl	%ebx, 510(%edx)
	movl	%ebx, lastNode

	RET

_addFirstNode:
	movl	%edx, firstNode
	movl	%edx, lastNode

	RET

deleteProperty:
	RET

queryProperties:
	RET

showProperties:
	movl	firstNode, %edx

_printProperty:
	call	readStructToVariables

	pushl	$ownerName
	pushl	$ownerNameInfo
	call	printf
	addl	$8, %esp

	pushl	$ownerPhone
	pushl	$ownerPhoneInfo
	call	printf
	addl	$8, %esp

	movl	$0, %eax
	movb	propType, %al
	pushl	%eax
	pushl	$propTypeInfo
	call	printf
	addl	$8, %esp

	pushl	$addrCity
	pushl	$addrCityInfo
	call	printf
	addl	$8, %esp

	pushl	$addrDist
	pushl	$addrDistInfo
	call	printf
	addl	$8, %esp

	pushl	roomN
	pushl	$roomNInfo
	call	printf
	addl	$8, %esp

	pushl	suiteN
	pushl	$suiteNInfo
	call	printf
	addl	$8, %esp

	movl	$0, %eax
	movb	hasGarage, %al
	pushl	%eax
	pushl	$hasGarageInfo
	call	printf
	addl	$8, %esp

	pushl	sqrMeters
	pushl	$sqrMetersInfo
	call	printf
	addl	$8, %esp

	pushl	rentPrice
	pushl	$rentPriceInfo
	call	printf
	addl	$8, %esp

_readNextStruct:
	movl	nextNode, %edx
	cmpl	$0, %edx
	jne		_printProperty

	RET

#### UTIL

getInput: # (PROMPT, ADDR, FORMAT)
	pushl	%ebp
	movl	%esp, %ebp

	pushl	8(%ebp)
	call	printf
	addl	$4, %esp

	pushl	12(%ebp)
	pushl	16(%ebp)
    call    scanf
    addl    $8, %esp
	
	movl	%ebp, %esp
	popl	%ebp

    RET

writeVariablesToStruct:
	leal	ownerName, %esi
	leal	0(%edx), %edi
	movl	$144, %ecx
	cld
	rep movsb

	leal	ownerPhone, %esi
	leal	144(%edx), %edi
	movl	$60, %ecx
	cld
	rep movsb

	movb	propType, %cl
	movb	%cl, 204(%edx)

	leal	addrCity, %esi
	leal	205(%edx), %edi
	movl	$144, %ecx
	cld
	rep movsb

	leal	addrDist, %esi
	leal	349(%edx), %edi
	movl	$144, %ecx
	cld
	rep movsb

	movl	roomN, %ecx
	movl	%ecx, 493(%edx)

	movl	suiteN, %ecx
	movl	%ecx, 497(%edx)

	movb	hasGarage, %cl
	movb	%cl, 501(%edx)

	movl	sqrMeters, %ecx
	movl	%ecx, 502(%edx)

	movl	rentPrice, %ecx
	movl	%ecx, 506(%edx)
	
	movl	nextNode, %ecx
	movl	%ecx, 510(%edx)

	RET

readStructToVariables:
	leal	0(%edx), %esi
	leal	ownerName, %edi
	movl	$144, %ecx
	cld
	rep movsb

	leal	144(%edx), %esi
	leal	ownerPhone, %edi
	movl	$60, %ecx
	cld
	rep movsb

	movl	204(%edx), %ecx
	movl	%ecx, propType

	leal	205(%edx), %esi
	leal	addrCity, %edi
	movl	$144, %ecx
	cld
	rep movsb

	leal	349(%edx), %esi
	leal	addrDist, %edi
	movl	$144, %ecx
	cld
	rep movsb

	movl	493(%edx), %ecx
	movl	%ecx, roomN

	movl	497(%edx), %ecx
	movl	%ecx, suiteN

	movl	501(%edx), %ecx
	movl	%ecx, hasGarage

	movl	502(%edx), %ecx
	movl	%ecx, sqrMeters
	
	movl	506(%edx), %ecx
	movl	%ecx, rentPrice
	
	movl	510(%edx), %ecx
	movl	%ecx, nextNode

	RET
