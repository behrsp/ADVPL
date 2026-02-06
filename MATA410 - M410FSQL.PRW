#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "TOTVS.CH"


/*

    Ponto de entrada, para filtrar logo na entrada
    os Clientes em uma determinada data.

*/

user function M410FSQL()

    Local aArea :=GetArea()
    Local cFiltro := ""
    Local aPergs := {}
    Local cClieDe  := Space(TamSX3('A1_COD')[1])
    Local cClieAt := StrTran(cClieDe, ' ','Z')
    Local dDataDe := FirstDate(Date())
    Local dDateAt := LastDate(Date())


    //Adiciona os Parametros que serão exibidos
    aAdd(aPergs, {1,'Cliente De',  cClieDe, "", "Vazio() .OR. ExistCPO('SA1')",   "SA1", ".T." ,70,  .F.}) //mv_par01
    aAdd(aPergs, {1,'Cliente Até', cClieAt, "", "ExistCPO('SA1')",                "SA1", ".T." ,70,  .T.}) //mv_par02
    aAdd(aPergs, {1,'Data De',     dDataDe, "", ".T.",                             "",   ".T." ,80,  .F.}) //mv_par03
    aAdd(aPergs, {1,'Data Ate',    dDateAt, "", ".T.",                             "",   ".T." ,80,  .T.}) //mv_par04

    //se a pergunta for confirmada
    If Parambox(aPergs, "Informe os parâmetros", , , , , , , , ,.F., .F.)

        //monta  o filtro que será aplicado no browse
        cFiltro += " SC5->C5_CLIENTE >='"+ MV_PAR01 + "' .AND."
        cFiltro += " SC5->C5_CLIENTE <='"+ MV_PAR02 + "' .AND."
        cFiltro += " SC5->C5_EMISSAO >= sToD('" + dToS(MV_PAR03) + "') .AND."
        cFiltro += " SC5->C5_EMISSAO <= sToD('" + dToS(MV_PAR04) + "') "

    endif

    restArea(aArea)

Return cFiltro
