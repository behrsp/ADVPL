/**-----------------------------------------------------------------------------------------------------------------**/
/**                                          DECLARAÇÃO DAS BIBLIOTECAS                                             **/
/**-----------------------------------------------------------------------------------------------------------------**/
#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "TOTVS.CH"

/**-----------------------------------------------------------------------------------------------------------------**/
/**                                           DEFINICAO DE PALAVRAS                                                 **/
/**-----------------------------------------------------------------------------------------------------------------**/
#Define ENTER CHR(13)+CHR(10)

/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: MA410MNU                      	    	                                                 	  
/** SOLICITANTE: Maicon                                                                                           
/** CONSULTOR  : 
/** DESCRICAO  : 
/** EXECUCAO   : carlos                       
/**---------------------------------------------------------------------------------------------------------------**/

User Function MA410MNU() 

	Local aArea			:= GetArea()  

	aAdd(aRotina,{"Lista de Separação "         , 'U_AFATR02(SC5->C5_NUM,)' 	            , 0 , 5 , 0 , NIL })
	aAdd(aRotina,{"Complemento Veiculo "        , 'U_CompVeic()'                            , 0 , 4 , 0 , NIL })
    aAdd(aRotina,{"Definir Endereço Coleta "    , 'U_AFATA01(SC5->C5_NUM,)'                 , 0 , 5 , 0 , NIL }) 
    aAdd(aRotina,{"Ajustes Pedido Venda"        , 'U_AltPedV()'                             , 0 , 5 , 0 , NIL }) 
    aAdd(aRotina,{'Detalhes Pedido'             ,  'U_detPed(SC5->C5_NUM,)'                 , 0 , 5 , 0 , NIL })
     

	restArea(aArea)       

Return Nil

User Function CompVeic()  
	Local _iCount  := 0
    Local _iCount2 := 0
    Local nAtual   := 0

    Private aCols 		:= {}
	Private aHeader 	:= {}
    Private _aRecno     := {}

    Private aHeaderX := {}
    Private aStruct  := {}

	SX3->(DbSetOrder(1))
    SX3->(DbSeek("CD9"+"08"))

    /*
	SX3->(DbSetOrder(1))
    SX3->(DbSeek("CD9"+"08"))
	While SX3->X3_ARQUIVO == "CD9"
    	If	x3uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
	     	AADD(aHeader,{	TRIM(SX3->X3_TITULO),SX3->X3_CAMPO,;
                        	SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,;
                        	"",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT} )
        EndIf

        SX3->(DbSkip())
	Enddo
    */

    aStruct := CD9->(DbStruct()) 

    For nAtual := 8 To Len(aStruct)         
        MntHeader(@aHeader, aStruct[nAtual][1], 4 , .F. )
    Next

    CD9->(DbSetOrder(1)) //CD9_FILIAL+CD9_TPMOV+CD9_SERIE+CD9_DOC+CD9_CLIFOR+CD9_LOJA+CD9_ITEM+CD9_COD 
    SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO                                                                                                                             
    
    SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM,.T.))
    While !SC6->(Eof()) .And. xFilial("SC6")+SC5->C5_NUM == SC6->C6_FILIAL+SC6->C6_NUM
        
        _aAux       := {}
        _lAchouCD9  := CD9->(DbSeek(xFilial("CD9")+"P"+Space(Len(CD9->CD9_SERIE))+;
                                    Padr(SC5->C5_NUM, Len(CD9->CD9_DOC))+SC5->C5_CLIENTE+SC5->C5_LOJACLI+;
                                    Padr(SC6->C6_ITEM, Len(CD9->CD9_ITEM)),.F.))

        For _iCount := 1 TO Len(aHeader)
            iF _lAchouCD9
                Aadd(_aAux, CD9->(FieldGet(FieldPos(aHeader[_iCount, 2]))))
            ElseIf AllTrim(aHeader[_iCount, 2]) == "CD9_ITEM"
                Aadd(_aAux, SC6->C6_ITEM)
            ElseIf AllTrim(aHeader[_iCount, 2]) == "CD9_COD"
                Aadd(_aAux, SC6->C6_PRODUTO)
            Else
                If aHeader[_iCount, 8] == "C"
                    Aadd(_aAux, Space(aHeader[_iCount, 4]))
                ElseIf aHeader[_iCount, 8] == "N"
                    Aadd(_aAux, 0)
                ElseIf aHeader[_iCount, 8] == "D"
                    Aadd(_aAux, Ctod(""))
                EndIf
            EndIf
        Next _iCount
        Aadd(_aAux, .F.)
        Aadd(aCols, _aAux)

        SC6->(DbSkip())
    Enddo 

	aCGD			:=	{80,5,350,350}
	//aCGD			:=  {80,5,118,315}
 
	aR 		:= {}
	aC 		:= {}
	N		:= 1

	nOpcx 	:= 6

	aR 		:= {}

	aObjects    := {}
	aPosObj     := {}
	aSize       := MsAdvSize()

	AADD(aObjects,{100,100,.T.,.T.})
	AADD(aObjects,{200,200,.T.,.T.})     

	aInfo       := {aSize[1],aSize[2],aSize[3],aSize[4],3,3,3,3}

	aPosObj     := MsObjSize(aInfo,aObjects,.T.)

	aCordW 		:= {aSize[7],0,aSize[6],aSize[5]}

    dbSelectArea("SE2")

	cTitulo		:= "Complemento do Veiculo"
	
    _lRet := U_ModIIERP(cTitulo,aC,aR,aCGD,nOpcx,,,,,,,aCordW,,,)
    
    If 	_lRet
		For _iCount := 1 To Len(aCols) 
            If CD9->(DbSeek(xFilial("CD9")+"P"+Space(Len(CD9->CD9_SERIE))+;
                     Padr(SC5->C5_NUM, Len(CD9->CD9_DOC))+SC5->C5_CLIENTE+SC5->C5_LOJACLI+;
                     Padr(GDFieldGet("CD9_ITEM",_iCount), Len(CD9->CD9_ITEM)),.F.))
                RecLock("CD9",.F.)
            Else
                RecLock("CD9",.T.)
            EndIf
            CD9->CD9_FILIAL := xFilial("CD9")
            CD9->CD9_TPMOV  := "P"
            CD9->CD9_DOC    := SC5->C5_NUM
            CD9->CD9_CLIFOR := SC5->C5_CLIENTE
            CD9->CD9_LOJA   := SC5->C5_LOJACLI
    
            For _iCount2 := 1 TO Len(aHeader)
        		FieldPut( FieldPos(aHeader[_iCount2,2] ), aCols[_iCount, _iCount2] )
            Next _iCount2

		Next  _iCount
	EndIf

Return

 
static Function MntHeader(aArray , cCampo , nTipo , cTituloDef , cCampoDef , cBlocoDef , cAliasDef , lUsado )

    Local aArea        := GetArea() 
    Local cFieldX3     := ""
    Local cTipoX3      := ""
    Local cTitX3       := ""
    Local cPictX3      := ""
    Local cCBoxX3      := ""
    Local cF3X3        := ""
    Local cValidX3     := ""
    Local cUsadoX3     := ""
    Local cRelacaoX3   := ""
    Local aTamX3       := {}
    Local nTamArr      := 0
    Local cAliasTab    := ""
    Local cNivelX3     := ""  // Nivel do campo em relação aos direitos do operador
    Default aArray     := {}
    Default cCampo     := ""
    Default nTipo      := 0
    Default cTituloDef := ""
    Default cCampoDef  := ""
    Default cBlocoDef  := ""
    Default cAliasDef  := ""
 
    //Se tiver campo preenchido
    If ! Empty(cCampo) 
        cFieldX3 := alltrim(GetSX3Cache(cCampo, "X3_CAMPO")) 
  
        //Se o campo for encontrado na SX3
        If ! Empty(cFieldX3) 
            nTamArr    := Len(aArray) + 1 
            cAliasTab  := AliasCPO(cFieldX3)
            cTipoX3    := GetSX3Cache(cFieldX3, "X3_TIPO")
            aTamX3     := TamSX3(cFieldX3)
            cTitX3     := Iif(Empty(cTituloDef), GetSX3Cache(cFieldX3, "X3_TITULO"), cTituloDef)
            cPictX3    := PesqPict(cAliasTab, cFieldX3)
            cCBoxX3    := GetSX3Cache(cFieldX3, "X3_CBOX")
            cF3X3      := GetSX3Cache(cFieldX3, "X3_F3")
            cValidX3   := GetSX3Cache(cFieldX3, "X3_VALID")
            cUsadoX3   := x3USO(GetSX3Cache(cFieldX3, "X3_USADO"))  
            cRelacaoX3 := GetSX3Cache(cFieldX3, "X3_RELACAO")
            cNivelX3   := GetSX3Cache(cFieldX3, "X3_NIVEL")
 
            //Para montar a Struct de uma FWTemporaryTable
            If nTipo == 1
                aAdd(aArray, {;
                    Iif(Empty(cCampoDef), cCampo, cCampoDef),;
                    cTipoX3,;
                    aTamX3[1],;
                    aTamX3[2];
                })
 
            //Para montar o aHeader de telas com Browse (FWMarkBrowse)
            ElseIf nTipo == 2
                aAdd(aArray, {;
                    Iif(Empty(cCampoDef), cCampo, cCampoDef),; 
                    cTitX3,;
                    nTamArr,;
                    cPictX3,;
                    1,;
                    aTamX3[1],;
                    aTamX3[2],;
                    cCBoxX3;
                })
 
            //Para montar o aSeek em telas com Pesquisa no Browse
            ElseIf nTipo == 3
                aAdd(aArray, { cTitX3, ;
                    { { "",;
                        cTipoX3,;
                        aTamX3[1],;
                        aTamX3[2],;
                        cTitX3,;
                        cPictX3;
                    } };
                })
 
            //Para montar o aHeader de telas com Browse (MsNewGetDados)
            ElseIf nTipo == 4
                if cUsadoX3 .and. cNivel >= cNivelX3 
                   aAdd(aArray, {;
                       cTitX3,;
                       Iif(Empty(cCampoDef), cCampo, cCampoDef),;
                       cPictX3,;
                       aTamX3[1],;
                       aTamX3[2],;
                       cValidX3,; 
                       cUsadoX3,;
                       cTipoX3,;
                       cF3X3,;
                       cRelacaoX3,;
                       cCBoxX3;
                   })
                endif 
 
            //Para montar o aHeader de telas com FWBrwColumn (FWFormBrowse)
            ElseIf nTipo == 5
                aAdd(aArray, FWBrwColumn():New())
                nTamArr := Len(aArray)
 
                aArray[nTamArr]:SetType(cTipoX3)
                aArray[nTamArr]:SetTitle(cTitX3)
                aArray[nTamArr]:SetSize(aTamX3[1])
                aArray[nTamArr]:SetPicture(cPictX3)
                aArray[nTamArr]:SetDecimal(aTamX3[2])
                aArray[nTamArr]:SetData(&(cBlocoDef))
 
            //Para utilizar o método SetFieldFilter (FWFormBrowse)
            ElseIf nTipo == 6
                aAdd(aArray, {;
                    cCampo,;
                    cTitX3,;
                    cTipoX3,;
                    aTamX3[1],;
                    aTamX3[2],;
                    cPictX3;
                })
 
            //Para utilizar o método SetFields (FWMarkBrowse)
            ElseIf nTipo == 7
                aAdd(aArray, {;
                    cTitX3,;
                    &("{|| " + Iif(! Empty(cAliasDef), "(" + cAliasDef + ")->", "") + cCampo + "}"),;
                    cTipoX3,;
                    cPictX3,;
                    1,;
                    aTamX3[1],;
                    aTamX3[2],;
                    .F.,;
                    ,;
                    ,;
                    ,;
                    ,;
                    ,;
                    ,;
                    ,;
                    1;
                })
            EndIf
 
        EndIf
    EndIf
 
    RestArea(aArea)
Return



user function detPed()

    Local aArea     := GetArea()
   Local cMensagem := ""


    //monta a mensagem
    cMensagem := "Você está posicionado no Pedido[" + SC5->C5_NUM + "]" + CRLF
    cMensagem += "" + CRLF
    cMensagem += "Hoje é: [" + dtoC(Date()) + "]" + CRLF
    cMensagem += "Emissão do Pedido: ["+ dToC(C5_EMISSAO)+"]" + CRLF
    cMensagem += "A condição de pagamento é do tipo [" + C5_CONDPAG + "]" + CRLF
    cMensagem += "A 1º parcela : [" + dToC(C5_DATA1) + "]" + CRLF
    cMensagem += "A 2º parcela: [" + dToC(C5_DATA2) + "]" + CRLF
    cMensagem += "A 3º parcela: [" + dToC(C5_DATA3) + "]" + CRLF
    cMensagem += "A 4º parcela: [" + dToC(C5_DATA4) + "]" + CRLF

    ShowLog(cMensagem)


    restArea(aArea)

Return
