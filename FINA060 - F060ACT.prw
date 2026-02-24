#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} F060ACT()
Este fonte, foi criado pelo Willian RSAC, para realizar as recompras, e transferencias intercompany.
Porém, ao realizar a transferencia, o titulo original permanecia em aberto, no contas a Receber.
Foi alterado o fonte, para que ao final da transferencia, faz a baixa do titulo original, deixando apenas
o titulo transferido em aberto, na filial destino.
@type user function
@author Robson
@since 24/02/2026
@version 2
@param Sem parametros
@return sem retornos
/*/


User Function F060ACT()

    Local aArea        := GetArea()
    Local aAreaSE1     := SE1->(GetArea())
    Local aAreaFRV     := FRV->(GetArea())

    Local cFilOld      := cFilAnt
    Local cFilDestino  := ""
    Local cHistCp      := ""
    Local aE1Auto      := {}
    Local aBaixaAuto   := {}
    Local lInclui      := .F.
    Local lExclui      := .F.
    Local lMsErroAuto  := .F.

    // ============================================================
    // CAPTURA DADOS DO TÍTULO ORIGINAL
    // ============================================================

    Local cPrefixo  := SE1->E1_PREFIXO
    Local cNum      := SE1->E1_NUM
    Local cParcela  := SE1->E1_PARCELA
    Local cTipo     := AllTrim(SE1->E1_TIPO)
    Local cCliente  := SE1->E1_CLIENTE
    Local cLoja     := SE1->E1_LOJA
    Local cNomCli   := SE1->E1_NOMCLI
    Local dEmissao  := SE1->E1_EMISSAO
    Local dVencto   := SE1->E1_VENCTO
    Local dVencrea  := SE1->E1_VENCREA
    Local nValor    := SE1->E1_VALOR
    Local nMoeda    := SE1->E1_MOEDA

    // ============================================================
    // VERIFICA SE É INCLUSÃO OU EXCLUSÃO
    // ============================================================

    If AllTrim(cSituant) == "0" .AND. cSituacao $ GetMV("AIZ_CRTMUT")
        lInclui := .T.
    ElseIf cSituant $ GetMV("AIZ_CRTMUT") .AND. AllTrim(cSituacao) == "0"
        lExclui := .T.
    Else
        RestArea(aArea)
        Return Nil
    EndIf

    // ============================================================
    // POSICIONA FRV PARA PEGAR FILIAL DESTINO
    // ============================================================

    dbSelectArea("FRV")
    FRV->(dbSetOrder(1))

    If lInclui
        FRV->(dbSeek(xFilial("FRV") + cSituacao))
    Else
        FRV->(dbSeek(xFilial("FRV") + cSituant))
    EndIf

    cFilDestino := FRV->FRV_FILCES
    cHistCp     := "CESSAO DE TITULO DA EMPRESA " + cFilAnt

    // ============================================================
    // TROCA FILIAL PARA INCLUIR NOVO TITULO
    // ============================================================

    cFilAnt := cFilDestino

    // ============================================================
    // MONTA ARRAY DO NOVO TITULO
    // ============================================================

    aE1Auto := { ;
        { "E1_FILIAL"  , xFilial("SE1") , NIL }, ;
        { "E1_PREFIXO" , cPrefixo       , NIL }, ;
        { "E1_NUM"     , cNum           , NIL }, ;
        { "E1_PARCELA" , cParcela       , NIL }, ;
        { "E1_TIPO"    , cTipo          , NIL }, ;
        { "E1_NATUREZ" , "10408"        , NIL }, ;
        { "E1_CLIENTE" , cCliente       , NIL }, ;
        { "E1_LOJA"    , cLoja          , NIL }, ;
        { "E1_NOMCLI"  , cNomCli        , NIL }, ;
        { "E1_EMISSAO" , dEmissao       , NIL }, ;
        { "E1_VENCTO"  , dVencto        , NIL }, ;
        { "E1_VENCREA" , dVencrea       , NIL }, ;
        { "E1_VALOR"   , nValor         , NIL }, ;
        { "E1_HIST"    , cHistCp        , NIL }, ;
        { "E1_MOEDA"   , nMoeda         , NIL }, ;
        { "E1_EMPCES"  , cFilOld        , NIL } }

    // ============================================================
    // INICIA TRANSAÇÃO
    // ============================================================

    Begin Transaction

        lMsErroAuto := .F.

        // 1 - Cria novo título na filial destino
        If lInclui
            MsExecAuto({|x,y| FINA040(x,y)}, aE1Auto, 3)
        ElseIf lExclui
            MsExecAuto({|x,y| FINA040(x,y)}, aE1Auto, 5)
        EndIf

        // 2 - Se criou com sucesso, baixa o título original
        If !lMsErroAuto .AND. lInclui

            // Volta para filial ORIGINAL
            cFilAnt := cFilOld

            aBaixaAuto := { ;
                { "E1_FILIAL"  , xFilial("SE1") , NIL }, ;
                { "E1_PREFIXO" , cPrefixo       , NIL }, ;
                { "E1_NUM"     , cNum           , NIL }, ;
                { "E1_PARCELA" , cParcela       , NIL }, ;
                { "E1_TIPO"    , cTipo          , NIL }, ;
                { "E1_BAIXA"   , dDataBase      , NIL }, ;
                { "E1_VALLIQ"  , nValor         , NIL } }

            MsExecAuto({|x,y| FINA050(x,y)}, aBaixaAuto, 3)


            DbSelectArea("SE1")
            SE1->(DbSetOrder(1))

            If SE1->(DbSeek(cFilOld + cPrefixo + cNum + cParcela + cTipo))

                RecLock("SE1", .F.)
                SE1->E1_SALDO := 0
                SE1->E1_STATUS := "B"
                MsUnlock()

            EndIf

        EndIf

        If lMsErroAuto
            MostraErro()
            DisarmTransaction()
        EndIf

    End Transaction

    // ============================================================
    // VOLTA FILIAL ORIGINAL DEFINITIVA
    // ============================================================

    cFilAnt := cFilOld

    RestArea(aArea)
    RestArea(aAreaSE1)
    RestArea(aAreaFRV)

Return Nil
