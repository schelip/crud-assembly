.section .data
	# Property struct
	id:					.int	0		# 0:	32-bit int
	ownerName:			.space	144		# 4:	char[36]
	ownerPhone:			.space	60		# 148:	char[15]
	propType:			.byte	0		# 208:	bool
	addrCity:			.space	144		# 209:	char[36]
	addrDist:			.space	144		# 353:	char[36]
	bedroomN:			.int	0		# 497:	32-bit int
	suiteN:				.int	0		# 501:	32-bit int
	hasGarage:			.byte	0		# 505:	bool
	sqrMeters:			.int	0		# 506:	32-bit int
	rentPrice:			.int	0		# 510:	32-bit int
	nextNode:			.int	0		# 514:	32-bit int

	# Output strings
	opening:			.asciz	"\nPrograma para cadastro e consulta de imóveis\n"
	menuOp:				.asciz	"\nMenu de Opcoes\n<1> Cadastrar imóvel\n<2> Remover imóvel\n<3> Consultar imóveis\n<4> Exibir relatório\n<5> Finalizar\nDigite opcao => "

	ownerNamePrompt:	.asciz	"\nInforme o nome do proprietário => "
	ownerPhonePrompt:	.asciz	"Informe o telefone do proprietário (somente números) => "
	propTypePrompt:		.asciz	"Informe o tipo de propriedade (<0> Casa ou <1> Apartamento) => "
	addrCityPrompt:		.asciz	"Informe a cidade => "
	addrDistPrompt:		.asciz	"Informe o bairro => "
	bedroomNPrompt:		.asciz	"Informe o número de quartos => "
	suiteNPrompt:		.asciz	"Informe o número de suítes => "
	hasGaragePrompt:	.asciz	"A propriedade tem garagem? (<0> Não ou <1> Sim) => "
	sqrMetersPrompt:	.asciz	"Informe a área em metros quadrados => "
	rentPricePrompt:	.asciz	"Informe o preço do aluguel => "

	idInfo:				.asciz	"\nID: %d"
	ownerNameInfo:		.asciz	"\nNome do proprietário: %s"
	ownerPhoneInfo:		.asciz	"\nTelefone do proprietário: %s"
	propTypeInfo:		.asciz	"\nTipo de propriedade (<0> Casa ou <1> Apartamento): %d"
	addrCityInfo:		.asciz	"\nCidade: %s"
	addrDistInfo:		.asciz	"\nBairro: %s"
	bedroomNInfo:		.asciz	"\nNúmero de quartos: %d"
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
	nextId:				.int	1

	# Constants
	fileName:			.asciz	"properties.txt"
	structSize:			.int	518

.section .text
.globl _start
_start:
	nop
	pushl	$opening				# Push opening message to stack
	call	printf					# Print opening message
	addl	$4, %esp				# Undo last push

	call	readProperties			# Read properties saved on file to memory
	
	call	optionsMenu				# Show options menu to user and get option

	cmpl	$5, option				# If option was 5, finalize program
	je	_end

	call	handleOptions			# Else, redirect to chosen functionality
	
	jmp	_start						# After done, start again

_end:
	pushl	$0						# Successful execution code
	call	exit					# Finish program

optionsMenu:
	pushl	$intFormat				# Push int format string
	pushl	$option					# Push option variable to store result
	pushl	$menuOp					# Push option menu query string
	call	getInput				# Get user input
	addl	$12, %esp				# Undo last 3 pushes
	
	RET

handleOptions:
	cmpl	$1, option				# If option chosen was 1, create new property from input
	je	createProperty

	cmpl	$2, option				# Else if option chosen was 2, delete a property
	je	deleteProperty				

	cmpl	$3, option				# Else if option chosen was 3, query properties by room number
	je	queryProperties
	
	cmpl	$4, option				# Else if option chosen was 4, show all properties
	je	showProperties

	RET

readProperties:
	RET

createProperty:
	pushl	$strFormat
	pushl	$ownerName
	pushl	$ownerNamePrompt
	call	getInput
	addl	$12, %esp

	pushl	$strFormat
	pushl	$ownerPhone
	pushl	$ownerPhonePrompt
	call	getInput
	addl	$12, %esp

	pushl	$byteFormat
	pushl	$propType
	pushl	$propTypePrompt
	call	getInput
	addl	$12, %esp

	pushl	$strFormat
	pushl	$addrCity
	pushl	$addrCityPrompt
	call	getInput
	addl	$12, %esp

	pushl	$strFormat
	pushl	$addrDist
	pushl	$addrDistPrompt
	call	getInput
	addl	$12, %esp

	pushl	$intFormat
	pushl	$bedroomN
	pushl	$bedroomNPrompt
	call	getInput
	addl	$12, %esp

	pushl	$intFormat
	pushl	$suiteN
	pushl	$suiteNPrompt
	call	getInput
	addl	$12, %esp

	pushl	$byteFormat
	pushl	$hasGarage
	pushl	$hasGaragePrompt
	call	getInput
	addl	$12, %esp

	pushl	$intFormat
	pushl	$sqrMeters
	pushl	$sqrMetersPrompt
	call	getInput
	addl	$12, %esp

	pushl	$intFormat
	pushl	$rentPrice
	pushl	$rentPricePrompt
	call	getInput
	addl	$12, %esp

	movl	$0, nextNode

_initializeStruct:
	pushl	$structSize				# Push struct size for allocation
	call	malloc					# Allocate memory for the struct
	addl	$4, %esp				# Undo last push
	movl	%eax, pProperty			# Move pointer for allocated memory to eax

	movl	pProperty, %edx			# Move struct pointer to edx
	call	writeVariablesToStruct	# Write all variables to the struct allocated memory

_addToLinkedList:
	movl	firstNode, %eax			# Move pointer to the first node to eax
	cmpl	$0, %eax				# If there are no nodes yet, first and last node will be this one
	je	_addFirstNode

_updateLastNode:
	movl	%edx, %ebx				# Move struct pointer to ebx, freeing edx
	movl	lastNode, %edx			# Move pointer to last node of list to edx
	movl	%ebx, 514(%edx)			# Move struct pointer to "next node" position of last node
	movl	%ebx, lastNode			# Update last node pointer with struct pointer

	RET

_addFirstNode:
	movl	%edx, firstNode			# Update first node with struct pointer
	movl	%edx, lastNode			# Update last node also, since it is the only node

	RET

deleteProperty:
	RET

queryProperties:
	RET

showProperties:
	movl	firstNode, %edx			# Move pointer to first node to edx

_printProperty:
	call	readStructToVariables	# Read struct bytes to variables

	pushl	$id
	pushl	$idInfo
	call	printf
	addl	$8, %esp

	pushl	$ownerName
	pushl	$ownerNameInfo
	call	print
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

	pushl	bedroomN
	pushl	$bedroomNInfo
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
	movl	nextNode, %edx			# Move pointer of next node on the list to edx
	cmpl	$0, %edx				# If the pointer is not zero, there are still more nodes to be printed
	jne		_printProperty

	RET


#### UTIL
getInput:							# (PROMPT, ADDR, FORMAT)
	pushl	%ebp					# Save original value of ebp
	movl	%esp, %ebp				# Copy current esp stack pointer to ebp

	pushl	8(%ebp)					# Push prompt string
	call	printf					# Print prompt
	addl	$4, %esp				# Undo last push

	pushl	12(%ebp)				# Push input variable address
	pushl	16(%ebp)				# Push input format string
	call	scanf					# Scan for user input
	addl	$8, %esp				# Undo last 2 pushes
	
	movl	%ebp, %esp				# Restore original stack pointer
	popl	%ebp					# Restore original ebp

	RET

writeVariablesToStruct:				# EDX: pointer to the struct
	movl	id, %ecx
	movl	%ecx, 0(%edx)

	leal	ownerName, %esi
	leal	4(%edx), %edi
	movl	$144, %ecx
	cld
	rep movsb

	leal	ownerPhone, %esi
	leal	148(%edx), %edi
	movl	$60, %ecx
	cld
	rep movsb

	movb	propType, %cl
	movb	%cl, 208(%edx)

	leal	addrCity, %esi
	leal	209(%edx), %edi
	movl	$144, %ecx
	cld
	rep movsb

	leal	addrDist, %esi
	leal	353(%edx), %edi
	movl	$144, %ecx
	cld
	rep movsb

	movl	bedroomN, %ecx
	movl	%ecx, 497(%edx)

	movl	suiteN, %ecx
	movl	%ecx, 501(%edx)

	movb	hasGarage, %cl
	movb	%cl, 505(%edx)

	movl	sqrMeters, %ecx
	movl	%ecx, 506(%edx)

	movl	rentPrice, %ecx
	movl	%ecx, 510(%edx)
	
	movl	nextNode, %ecx
	movl	%ecx, 514(%edx)

	RET

readStructToVariables:
	movl	0(%edx), %ecx
	movl	%ecx, id

	leal	4(%edx), %esi
	leal	ownerName, %edi
	movl	$144, %ecx
	cld
	rep movsb

	leal	148(%edx), %esi
	leal	ownerPhone, %edi
	movl	$60, %ecx
	cld
	rep movsb

	movb	208(%edx), %cl
	movb	%cl, propType

	leal	209(%edx), %esi
	leal	addrCity, %edi
	movl	$144, %ecx
	cld
	rep movsb

	leal	353(%edx), %esi
	leal	addrDist, %edi
	movl	$144, %ecx
	cld
	rep movsb

	movl	497(%edx), %ecx
	movl	%ecx, bedroomN

	movl	501(%edx), %ecx
	movl	%ecx, suiteN

	movb	505(%edx), %cl
	movb	%cl, hasGarage

	movl	506(%edx), %ecx
	movl	%ecx, sqrMeters
	
	movl	510(%edx), %ecx
	movl	%ecx, rentPrice
	
	movl	514(%edx), %ecx
	movl	%ecx, nextNode

	RET
