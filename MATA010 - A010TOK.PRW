#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include "totvs.ch"
#include "tbiconn.ch"
#Include "fwmbrowse.ch"
#include "fwmvcdef.ch"   

/*################################################################################
###  A010TOK - Valida na gravação do produto, inclusão e alteração              ###
###  Ponto de entrada, para validar o tipo de material se a filial for MEGA     ###
###  Regra MP|PA|PP NÃO PODEM SER CADASTRADOS NA MEGA E NA AIZT                 ###
###  20/01/2025                                                                 ###
###                                                                             ###
###  Robson                                                                     ###
###                                                                             ###
##################################################################################*/

User Function A010TOK()

    local aArea := GetArea()
    Local lExecuta := .T.

    IF SUBSTR(cFilAnt,1,6) $'01MEGA|02AIZT' .AND. SUBSTR(M->B1_TIPO,1,2) $ 'MP|PA|PP'

        Help(NIL, NIL, "Campo TIPO ", NIL, "Tipos MP - PA - PP não permitidos nas filiais MEGA E AIZT ", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Escolha um tipo válido."})
        lExecuta      := .F.
    
    endif

    restArea(aArea)

Return lExecuta
