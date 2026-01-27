#include 'PROTHEUS.CH'
#include 'TOTVS.CH'
//#Include "topconn.ch"

/*/{Protheus.doc} BLOQPRD
        FUNCAO para validar quando:
        É alterado a flag para bloqueio do código. Não permitir o bloqueio, caso existir saldo.
        Colocar no CFG No campo B1_MSBLQ em validação de usuário a função=>  U_BLOQPRD()   
    @type       function
    @version    2
    @author     Robson Behr 
    @since      27/01/2025
/*/


User Function BLOQPRD()

    Local aArea     := GetArea()
    Local lRet  := .T.
    //Local cQuant    := SB2->B2_QATU
    Local cCod      := SB1->B1_COD

    cQry := " SELECT  SUM(SB2.B2_QATU) B2_QATU

    cQry += "   FROM		" + RetSqlName("SB2") + " SB2

    cQry += "   LEFT JOIN SB1010 SB1
    cQry += "   ON 1 = 1
    cQry += "   AND SB1.B1_FILIAL = SUBSTRING(SB2.B2_FILIAL,1,6)
    cQry += "   AND SB1.B1_COD  = SB2.B2_COD
    cQry += "   AND SB1.D_E_L_E_T_=''	

    cQry += "      WHERE SB2.D_E_L_E_T_=''

    cQry += "   AND SB2.B2_FILIAL =	'" + XFilial("SE2") + "'
    cQry += "   AND SB1.B1_COD =  '" + cCod + "'
    cQry += "   AND SB2.B2_QATU != 0

    // abre a query 
    PLSQuery(cQry,"SB2")

    //Só deixa bloquear produto se não tiver saldo.

    IF SB2->B2_QATU == 0 //.AND. M->B1_MSBLQL = '1'

        lRet := .T.

    ELSE 

        Help(NIL, NIL, "HELP", NIL, "Produto possui saldo, portanto não pode ser bloqueado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Procure o Almoxarifado."})
        
        
        lRet := .F. 
        SB1->B1_MSBLQL := '2' 

    ENDIF


    RestArea(aArea)

Return(lret)
