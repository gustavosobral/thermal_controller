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

	__CONFIG _CP_OFF & _CPD_OFF & _DEBUG_OFF & _LVP_OFF & _WRT_OFF & _BODEN_OFF & _PWRTE_ON & _WDT_ON & _XT_OSC

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

		TEMPO1
		TEMPO0
		FLAG
		AUX
		BUFFER

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

ENDERECO	EQU		B'00010000'

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE		SCL		PORTC,3

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

; VERIFICA SE TEM ALGUM EVENTO OCORRENDO NO I2C
AGUARDA_I2C_LIVRE
	BANK1
	BTFSC	SSPSTAT,R_W
	GOTO	$-1
	MOVF 	SSPCON2,W
	ANDLW	B'00011111'
	BTFSS	STATUS,Z
	GOTO	$-3
	BANK0	
	RETURN

ACK_OUT
	BANK1
	BCF		SSPCON2,ACKDT
	BSF		SSPCON2,ACKEN
	BANK0
	RETURN

NACK_OUT
	BANK1
	BSF		SSPCON2,ACKDT
	BSF		SSPCON2,ACKEN
	BANK0
	RETURN

; TESTA SE O ACK FOI RECEBIDO
TESTA_ACK
	BANK1
	BTFSC	SSPCON2,ACKSTAT
	GOTO 	RECEBEU_NACK

	BANK0
	BCF		F_ERRO
	RETURN

RECEBEU_NACK
	BANK0
	BSF		F_ERRO
	RETURN

I2C_EEPROM_WRITE
	; CONDI��O DE START
	BANK1
	BSF		SSPCON2,SEN
	BANK0
	CALL	AGUARDA_I2C_LIVRE

	; ENVIA ENDERE�O
	MOVF	ENDERECO,W
	MOVWF	SSPBUF
	CALL	AGUARDA_I2C_LIVRE
	CALL	TESTA_ACK
	BTFSC	F_ERRO
	GOTO	I2C_ERRO

	; ENVIA DADO
	MOVF	BUFFER,W
	MOVWF	SSPBUF
	CALL	AGUARDA_I2C_LIVRE
	CALL	TESTA_ACK
	BTFSC	F_ERRO
	GOTO	I2C_ERRO

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
	MOVLW	B'00000111'
	MOVWF	ADCON1
	MOVLW	B'01111111'
	MOVWF	SSPADD
	MOVLW	B'10000000'
	MOVWF	SSPSTAT

	BANK0
	MOVLW	B'00101000'	; HABILITA I2C MODO MASTER
	MOVWF	SSPCON
	BSF		SCL

	; LOCK INICIAL
	BTFSC	STATUS,NOT_TO
	GOTO	$

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	MOVLW	B'01000001'
	MOVWF	BUFFER
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN

	;CORPO DA ROTINA PRINCIPAL

	MOVLW	.200
	CALL	DELAY_MS

	CALL	I2C_EEPROM_WRITE

	GOTO	MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END