#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include "totvs.ch"   
#Include "protheus.ch"
#Include "fwmvcdef.ch"  

//-------------------------------------------------------------------
/*/{Protheus.doc} 
@type Function
Tela para que seja reaberta a comissão selecionada
Premissas: 
    1 - Usuario deve estar dentro do parametro     GA_USRCOM
    2 - Usuario precisa estar logado na filial onde a comissão foi gerada 
    3 - Usuario precisa passar o numero do titulo e a data de vencimento da comissão que deseja reabrir
@author  Robson
@since   02/02/2026
@version 1
/*/
//-------------------------------------------------------------------


User Function Reabre()
    Local oDlg
    Local cNum := Space(10)
    Local dVencto := CToD("") // converte string para data
    Local oGetNum, oGetData
    Local oMemoDet
    Local cDetalhes := ""

    Define MsDialog oDlg Title "Reabertura de Títulos - SE3" From 0, 0 To 400, 600 Pixel

        @ 010, 010 Say "Número do Título:" Pixel Of oDlg
        @ 010, 070 Get oGetNum Var cNum Size 60, 10 Pixel Of oDlg Picture "@!"

        @ 025, 010 Say "Data Vencimento:" Pixel Of oDlg
        @ 025, 070 Get oGetData Var dVencto Size 60, 10 Pixel Of oDlg Valid !Empty(dVencto)

        // Botão para buscar e mostrar detalhes
        @ 010, 150 Button "Visualizar Detalhes" Size 60, 20 Pixel Of oDlg ;
            Action (cDetalhes := BuscarSE3(cNum, dVencto), oMemoDet:Refresh())

        @ 050, 010 Say "Dados do Título Localizado:" Pixel Of oDlg
        @ 060, 010 Get oMemoDet Var cDetalhes Memo Size 280, 80 Pixel Of oDlg ReadOnly

       
// Botão de Ação
        @ 160, 070 Button "Reabrir Título" Size 60, 20 Pixel Of oDlg ;
            Action ( ProcessarReab(cNum, dVencto, oDlg) )

        @ 160, 150 Button "Fechar" Size 60, 20 Pixel Of oDlg Action oDlg:End()

    Activate MsDialog oDlg Centered

Return


Static Function BuscarSE3(cNum, dVencto)
 Local cRet      := "Título não encontrado."
    Local cAliasTmp := GetNextAlias()
    Local cSql      := ""
    Local cDataSql  := DToS(dVencto)

    cSql := " SELECT E3_FILIAL, E3_NUM, E3_PARCELA, E3_BASE, E3_COMIS, E3_VENCTO, E3_XVALIDA "
    cSql += " FROM " + RetSqlName("SE3") + " "
    cSql += " WHERE D_E_L_E_T_ = '' "
    cSql += " AND E3_FILIAL = '" + xFilial("SE3") + "' "
    cSql += " AND E3_NUM = '" + cNum + "' "
    cSql += " AND E3_VENCTO = '" + cDataSql + "' "

    // Usando MPSysOpenQuery que é mais estável para evitar erros de argumentos
    DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), cAliasTmp, .T., .T.)

    If (cAliasTmp)->(!Eof())
        cRet := "FILIAL: " + (cAliasTmp)->E3_FILIAL + " | "
        cRet += "TITULO: " + (cAliasTmp)->E3_NUM + " | "
        cRet += "PARC: " + (cAliasTmp)->E3_PARCELA + CRLF + CRLF
        
        cRet += "BASE: " + Transform((cAliasTmp)->E3_BASE, "@E 999,999,999.99") + CRLF
        cRet += "COMISSAO: " + Transform((cAliasTmp)->E3_COMIS, "@E 999,999,999.99") + CRLF + CRLF
        
        // Verifica se a data está vazia no banco antes de converter
        If !Empty((cAliasTmp)->E3_VENCTO)
            cRet += "DT. PAGTO ATUAL: " + DTOC(STOD((cAliasTmp)->E3_VENCTO)) + CRLF
        Else
            cRet += "DT. PAGTO ATUAL: [EM ABERTO]" + CRLF
        EndIf
        
        cRet += "XVALIDA ATUAL: " + AllTrim((cAliasTmp)->E3_XVALIDA)
    EndIf

    (cAliasTmp)->(DbCloseArea())
Return cRet


Static Function ProcessarReab(cNum, dVencto, oDlg)
   Local nAtu     := 0
    Local cAliasUpd := GetNextAlias()
    Local cSql     := ""
    Local 	cUsrPerm	:= AllTrim(SUPERGETMV("GA_USRCOM", .T., "000781"))// criado parametro, para controlar quem pode reabrir as comissões.
    

    IF !(__cUserId $ cUsrPerm)


        MsgInfo("Voce nao tem permissao para acessar esta rotina!!!")
        return .f.

    else
    
        If MsgYesNo("Deseja realmente reabrir este título? Isso limpará a data de pagamento e validação.", "Atenção")
            
            // Em vez de DbSeek, vamos buscar os Recnos (ID físico) dos registros que batem com o filtro
            cSql := " SELECT R_E_C_N_O_ AS ID FROM " + RetSqlName("SE3")
            cSql += " WHERE D_E_L_E_T_ = '' "
            cSql += " AND E3_FILIAL = '" + xFilial("SE3") + "' "
            cSql += " AND E3_NUM = '" + cNum + "' "
            cSql += " AND E3_VENCTO = '" + DtoS(dVencto) + "' "

            DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), cAliasUpd, .T., .T.)

            DbSelectArea("SE3")
            While (cAliasUpd)->(!Eof())
                // Vai direto no registro pelo Recno (impossível errar)
                SE3->(DbGoTo((cAliasUpd)->ID))
                
                If RecLock("SE3", .F.)
                    SE3->E3_DATA    := CToD("") 
                    SE3->E3_XVALIDA := ""       
                    SE3->(MsUnlock())
                    nAtu++
                EndIf
                
                (cAliasUpd)->(DbSkip())
            End While
            (cAliasUpd)->(DbCloseArea())

            If nAtu > 0
                MsgInfo("Sucesso! " + AllTrim(Str(nAtu)) + " registro(s) reaberto(s).", "Finalizado")
                oDlg:End()
            Else
                MsgStop("Não foi possível encontrar o registro para gravar. Verifique se o título já está aberto.", "Erro de Gravação")
            EndIf
        EndIf

    ENDIF

Return
