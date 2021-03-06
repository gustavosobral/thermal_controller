;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              									               *
;*                		GUSTAVO SOBRAL			                   *
;*                    FEVEREIRO DE 2016                            *
;*																   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <P16F877A.INC>

	__CONFIG _BODEN_OFF & _LVP_OFF & _PWRTE_ON & _WDT_OFF & _HS_OSC

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES

		; SLEEP VARIAVEIS
		TEMPO1
		TEMPO0
		; I2C VARIAVEIS
		BUFFER
		ENDERECO
		FLAG
		; A/D VARIAVEIS
		THERESHOLD_HIGH
		THERESHOLD_LOW
		CONVERTED
		READED_AD
		HIGH_LCD_VALUE
		LOW_LCD_VALUE

		; DELAY VARIAVEIS
		DELAY

		; MENU VARIAVEIS
		FILTRO_BOTOES

		DIVIDER
		INPUT
		REST
		TO_CONVERT
		COUNTER_HIGH
		COUNTER_LOW

	ENDC			;FIM DO BLOCO DE MEM�RIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

#DEFINE		F_ERRO	FLAG,0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

FILTRO_TECLA		EQU	.1
CONST_COUNT_LOW		EQU	.50
CONST_COUNT_HIGH	EQU	.5

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE		BOTAO_0	PORTD,3		; CHAVE DE MENU
#DEFINE		BOTAO_1	PORTD,4		; INCREMENTA THERESHOLD_HIGH
#DEFINE		BOTAO_2	PORTD,5		; DECREMENTA THERESHOLD_HIGH

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE		FET			PORTE,0
#DEFINE		SCL			PORTC,3

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      ENTRADAS / SA�DAS                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#DEFINE		SDA		PORTC,4

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG		0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	CONFIGS
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE�O DE DESVIO DAS INTERRUP��ES. A PRIMEIRA TAREFA � SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA��O FUTURA

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER� ESCRITA AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP��O

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI��O DE FUNCIONAMENTO
; E UM NOME COERENTE �S SUAS FUN��ES.

; DURACAO DE 1MS X O VALOR PASSADO EM WORK (W)
DELAY_MS
	MOVWF	TEMPO1
	MOVLW	.250
	MOVWF	TEMPO0
	
	CLRWDT
	DECFSZ	TEMPO0,F
		GOTO	$-2

	DECFSZ	TEMPO1,F
		GOTO	$-6
	RETURN

; DURACAO DE 1S X O VALOR PASSADO EM WORK (W)
DELAY_S
	MOVWF	DELAY
	BCF		STATUS, C
	RLF		DELAY
	RLF		DELAY
	MOVLW	.250
LOOP_DELAY
	DECFSZ	DELAY
		GOTO	CALL_DELAY_MS
	RETURN

CALL_DELAY_MS
	CALL	DELAY_MS
	GOTO	LOOP_DELAY

CONVERT_AD_VALUE
	MOVFW	READED_AD
	MOVWF	CONVERTED
	BCF		STATUS, C
	RRF		CONVERTED,1
	RETURN

NUM_LCD_CONVERTER
	MOVLW	B'00110000'
	MOVWF	HIGH_LCD_VALUE
	MOVFW	TO_CONVERT
	MOVWF	INPUT

TEST
	MOVFW	INPUT
	MOVWF	REST

	MOVFW	DIVIDER
	SUBWF	INPUT
	BTFSC	STATUS,0
		GOTO INCREASE_HIGH
	MOVFW	REST
	IORLW	B'00110000'
	MOVWF	LOW_LCD_VALUE
	RETURN

INCREASE_HIGH
	INCF	HIGH_LCD_VALUE
	GOTO	TEST

CALC_THERESHOLD_LOW
	MOVLW	.10
	SUBWF	THERESHOLD_HIGH,0
	MOVWF	THERESHOLD_LOW
	RETURN

; VERIFICA SE TEM ALGUM EVENTO OCORRENDO NO I2C
AGUARDA_I2C_LIVRE
	BANK1
	BTFSC	SSPSTAT,R_W
		GOTO	$-1
	MOVF	SSPCON2,W
	ANDLW	B'00011111'
	BTFSS	STATUS,Z
		GOTO	$-3
	BANK0	
	RETURN

; TESTA SE O ACK FOI RECEBIDO
TESTA_ACK
	BANK1
	BTFSC	SSPCON2,ACKSTAT
		GOTO	RECEBEU_NACK

	BANK0
	BCF		F_ERRO
	RETURN

RECEBEU_NACK
	BANK0
	BSF		F_ERRO
	RETURN

I2C_CONNECT
	; CONDI��O DE START
	BANK1
	BSF		SSPCON2,SEN
	BANK0
	CALL	AGUARDA_I2C_LIVRE

	; ENVIA ENDERECO
	MOVF	ENDERECO,W
	MOVWF	SSPBUF
	CALL	AGUARDA_I2C_LIVRE
	CALL	TESTA_ACK
	BTFSC	F_ERRO
		GOTO	I2C_ERRO
	RETURN

I2C_SEND
	; ENVIA DADO
	MOVF	BUFFER,W
	MOVWF	SSPBUF
	CALL	AGUARDA_I2C_LIVRE
	CALL	TESTA_ACK
	BTFSC	F_ERRO
		GOTO	I2C_ERRO
	RETURN

I2C_CLOSE
	; INICIA STOP BIT
	BANK1
	BSF		SSPCON2,PEN
	BANK0
	CALL	AGUARDA_I2C_LIVRE
	RETURN

; ROTINA PARA TRATAMENTO DE ERRO DO I2C
I2C_ERRO
	; INICIA STOP BIT
	BANK1
	BSF		SSPCON2,PEN
	BANK0

	; TODO: TURN ON RED LED
	RETURN

ESCREVE_TEMP_LCD
	; LIMPA LCD E ESCREVE PRIMEIRA LINHA
	CALL	I2C_CONNECT
	MOVLW	B'00000001'
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	'T'
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	'e'
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	'm'
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	'p'
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	':'
	MOVWF	BUFFER
	CALL	I2C_SEND

	; ATUALIZA COLUNA
	MOVLW	B'10010000'
	MOVWF	BUFFER
	CALL	I2C_SEND

	; ESCREVE TEMPERATURA LIDA
	MOVFW	HIGH_LCD_VALUE
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVFW	LOW_LCD_VALUE
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	' '
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	'o'
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	'C'
	MOVWF	BUFFER
	CALL	I2C_SEND

	; FECHA CONEXAO
	CALL	I2C_CLOSE
	RETURN

ESCREVE_THERESHOLD_LCD
	; LIMPA LCD E ESCREVE PRIMEIRA LINHA
	CALL	I2C_CONNECT
	MOVLW	B'00000001'
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	'L'
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	'i'
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	'm'
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	'i'
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	'a'
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	'r'
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	':'
	MOVWF	BUFFER
	CALL	I2C_SEND

	; ATUALIZA COLUNA
	MOVLW	B'10010000'
	MOVWF	BUFFER
	CALL	I2C_SEND

	; ESCREVE TEMPERATURA LIDA
	MOVFW	HIGH_LCD_VALUE
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVFW	LOW_LCD_VALUE
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	' '
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	'o'
	MOVWF	BUFFER
	CALL	I2C_SEND
	MOVLW	'C'
	MOVWF	BUFFER
	CALL	I2C_SEND

	; FECHA CONEXAO
	CALL	I2C_CLOSE
	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
CONFIGS
	BANK0
	CLRF	PORTA
	CLRF	PORTB
	CLRF	PORTC
	CLRF	PORTD
	CLRF	PORTE

	BANK1
	MOVLW	B'11111111'
	MOVWF	TRISA
	MOVLW	B'11111111'
	MOVWF	TRISB
	MOVLW	B'11110101'
	MOVWF	TRISC
	MOVLW	B'00111000'
	MOVWF	TRISD
	MOVLW	B'00000100'
	MOVWF	TRISE

	MOVLW	B'11011111'
	MOVWF	OPTION_REG
	MOVLW	B'00000000'
	MOVWF	INTCON
	MOVLW	B'10000100'	; CONFIGURA CONVERSOR A/D
	MOVWF	ADCON1
	MOVLW	B'01111111'
	MOVWF	SSPADD
	MOVLW	B'10000000'
	MOVWF	SSPSTAT

	BANK0
	MOVLW	B'00101000'	; HABILITA I2C MODO MASTER
	MOVWF	SSPCON
	BSF		SCL

	MOVLW	B'01000001'	; CONFIGURA CONVERSOR A/D
	MOVWF	ADCON0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	MOVLW	B'01000001'
	MOVWF	BUFFER
	MOVLW	B'00010000'
	MOVWF	ENDERECO

	MOVLW	.45
	MOVWF	THERESHOLD_HIGH

	MOVLW	.10
	MOVWF	DIVIDER
	MOVLW	CONST_COUNT_LOW
	MOVWF	COUNTER_LOW
	MOVLW	CONST_COUNT_HIGH
	MOVWF	COUNTER_HIGH

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
CALL	CALC_THERESHOLD_LOW
MOVLW	FILTRO_TECLA
MOVWF	FILTRO_BOTOES

VARRE
	MOVLW	.2
	CALL	DELAY_S

	; INICIA CONVERSAO A/D
	BSF	ADCON0,GO
	BTFSC	ADCON0,GO
		GOTO	$-1

	BANK1
	MOVFW	ADRESL
	BANK0
	MOVWF	READED_AD

	; VERIFICA SE O FET ESTA LIGADO OU NAO
	BTFSC	FET
		GOTO	FET_ON
	GOTO	FET_OFF

FET_ON
	MOVFW	CONVERTED ; VERIFICA SE A TEMP E MAIOR/MENOR DO QUE O LIMIAR
	SUBWF	THERESHOLD_HIGH,0
	BTFSC	STATUS,C
		GOTO	FIM
	DECFSZ	COUNTER_HIGH ; TRATA TEMP ALTA COM FET ON
		GOTO	FIM
	BCF	FET
	MOVLW	CONST_COUNT_HIGH
	MOVWF	COUNTER_HIGH
	GOTO	FIM

FET_OFF
	MOVFW	CONVERTED ; VERIFICA SE A TEMP E MAIOR/MENOR DO QUE O LIMIAR BAIXO
	SUBWF	THERESHOLD_LOW,0
	BTFSS	STATUS,C
		GOTO	FIM
	DECFSZ	COUNTER_LOW ; TRATA TEMP BAIXA COM FET OFF
		GOTO	FIM
	BSF	FET
	MOVLW	CONST_COUNT_LOW
	MOVWF	COUNTER_LOW
	GOTO	FIM

FIM
	
	BTFSC	BOTAO_0
		GOTO	SHOW_THERESHOLD
	CALL	CONVERT_AD_VALUE
	MOVFW	CONVERTED
	MOVWF	TO_CONVERT
	CALL	NUM_LCD_CONVERTER
	CALL	ESCREVE_TEMP_LCD
	GOTO	VARRE

; TRADUZ VALOR LIDO PARA O FORMATO DO LCD
SHOW_THERESHOLD
	MOVFW	THERESHOLD_HIGH
	MOVWF	TO_CONVERT
	CALL	NUM_LCD_CONVERTER
	CALL	ESCREVE_THERESHOLD_LCD

	BTFSC	BOTAO_1
		GOTO	TRATA_BOTAO_1
	BTFSC	BOTAO_2
		GOTO	TRATA_BOTAO_2

	MOVLW	FILTRO_TECLA
	MOVWF	FILTRO_BOTOES
	GOTO	VARRE

TRATA_BOTAO_1
	DECFSZ	FILTRO_BOTOES,1
		GOTO	VARRE

	INCF	THERESHOLD_HIGH,1
	CALL	CALC_THERESHOLD_LOW
	BTFSC	BOTAO_1
		GOTO	$-1
	GOTO	VARRE

TRATA_BOTAO_2
	DECFSZ	FILTRO_BOTOES,1
		GOTO	VARRE

	DECF	THERESHOLD_HIGH,1
	CALL	CALC_THERESHOLD_LOW
	BTFSC	BOTAO_2
		GOTO	$-1
	GOTO	VARRE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
