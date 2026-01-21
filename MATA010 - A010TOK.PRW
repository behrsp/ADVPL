#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include "totvs.ch"
#include "tbiconn.ch"
#Include "fwmbrowse.ch"
#include "fwmvcdef.ch"   

/*

    Ponto de entrada, para validar o tipo de material se a filial for MEGA
    Regra aguardando Regiane.
    20/01/2025

    Robson

*/

User Function A010TOK()

    local aArea := GetArea()
    Local lExecuta := .T.// Validações do usuário para inclusão ou alteração do produto



    IF SUBSTR(cFilAnt,1,6) $'01MEGA' .AND. (M->B1_TIPO =='MP')


        //FWAlertWarning("Tipo MP não permitido para esta filial,procure Regiane", "TOTVS")
            //Help('',1,'Tipo MP',,'Não permitido para esta filial, contate Regiane',1,0)
        Help(NIL, NIL, "Tipo - MP - ", NIL, "Não permitido na filial  - MEGA - ", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Procure a Regiane"})
        lExecuta      := .F.
    
    endif


    restArea(aArea)

Return lExecuta
