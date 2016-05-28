;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              									               *
;*                		GUSTAVO SOBRAL			                   *
;*                    FEVEREIRO DE 2016                            *
;*																   *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <P16F877A.INC>

	__CONFIG _BODEN_OFF & _LVP_OFF & _PWRTE_ON & _WDT_OFF & _HS_OSC

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES

		; SLEEP VARIAVEIS
		TEMPO1
		TEMPO0
		; I2C VARIAVEIS
		BUFFER
		ENDERECO
		FLAG
		; A/D VARIAVEIS
		AD_VALUE
		CONVERTED
		HIGH_LCD_VALUE
		LOW_LCD_VALUE

		; DELAY VARIAVEIS
		DELAY

		DIVIDER
		INPUT
		REST

	ENDC			;FIM DO BLOCO DE MEMÓRIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

#DEFINE		F_ERRO	FLAG,0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE		SCL		PORTC,3

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      ENTRADAS / SAÍDAS                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#DEFINE		SDA		PORTC,4

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG		0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	CONFIGS
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÁ ESCRITA AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.

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
	MOVWF	CONVERTED
	BCF		STATUS, C
	RRF		CONVERTED,1
	RETURN

TEMP_LCD_CONVERTER
	MOVLW	B'00110000'
	MOVWF	HIGH_LCD_VALUE
	MOVFW	CONVERTED
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
	; CONDIÇÃO DE START
	BANK1
	BSF		SSPCON2,SEN
	BANK0
	CALL	AGUARDA_I2C_LIVRE

	; ENVIA ENDEREÇO
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

	; FECHA CONEXÃO
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
	MOVLW	B'00000000'
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
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	MOVLW	B'01000001'
	MOVWF	BUFFER
	MOVLW	B'00010000'
	MOVWF	ENDERECO

	MOVLW	.150
	MOVWF	AD_VALUE

	MOVLW	.10
	MOVWF	DIVIDER
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

MAIN
	; INICIA CONVERSÃO A/D
	BSF		ADCON0,GO
	BTFSC	ADCON0,GO
		GOTO	$-1

	BANK1
	MOVFW	ADRESL ; TODO
	BANK0
	;MOVLW	.80
	; TRADUZ VALOR LIDO PARA O FORMATO DO LCD
	CALL	CONVERT_AD_VALUE
	CALL	TEMP_LCD_CONVERTER
	CALL	ESCREVE_TEMP_LCD

	MOVLW	.5
	CALL	DELAY_S

	GOTO 	MAIN

	; TODO
	; VERIFICA SE É MAIOR/MENOR DO QUE O LIMIAR
	MOVFW	ADRESL
	SUBWF	AD_VALUE,0
	BTFSC	STATUS,C
		GOTO	LOWER
	GOTO	HIGHER

LOWER
	GOTO	I2C

HIGHER
	GOTO	I2C

I2C
	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
