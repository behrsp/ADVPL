/**---------------------------------------------------------------------------------------------**/
/** PROPRIETARIO: GRUPO AIZ																																			**/
/** MODULO			: Compras																																				**/				
/** FINALIDADE	: Tela para informar os complementos de importação                              **/
/** DATA 				: 14/04/2022																																		**/
/** DATA 				: 05/02/2026                                                                    **/
/** Ajustado fonte, para atender as Importações.  																							**/
/**---------------------------------------------------------------------------------------------**/
/**                                 DECLARAÃ‡ÃƒO DAS BIBLIOTECAS                         				**/
/**---------------------------------------------------------------------------------------------**/
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include "totvs.ch"   
#Include "protheus.ch"
/**---------------------------------------------------------------------------------------------**/
/**                                   DEFINIÇÃO DE PALAVRAS					                  					**/
/**---------------------------------------------------------------------------------------------**/
#Define ENTER CHR(13)+CHR(10) 
/**---------------------------------------------------------------------------------------------**/
/** NOME DA FUNÇAO  : AFISA03()				                                                   			  **/
/** DESCRIÇÃOO	  	: Tela																								                      **/
/**---------------------------------------------------------------------------------------------**/
/**															CRIAÇÃO /ALTERAÇÃO / MANUTENÇÕES                            		**/	
/**---------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitação         | Descrição                      **/
/**---------------------------------------------------------------------------------------------**/


User Function AFISA03(cCompDoc, cCompSer, cCompForn, cCompLoja)

  Private aGets     := {}
  Private oFon1	    := TFont():New("Consolas", 06, 16, Nil, .F., Nil, Nil, Nil, .T., .F.)
  Private oT01      := Nil

  //Define valores padroes
  Default cCompDoc  := SF1->F1_DOC
  Default cCompSer  := SF1->F1_SERIE
  Default cCompForn := SF1->F1_FORNECE
  Default cCompLoja := SF1->F1_LOJA

  //Valida o posicionamento
  If (SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA) != cCompDoc + cCompSer + cCompForn + cCompLoja)

    //Ordena a tabela
    SF1->(DbSetOrder(1))

    //Posiciona 
    If !SF1->(DbSeek(xFilial("SF1") + cCompDoc + cCompSer + cCompForn + cCompLoja))

      //Mensagem
      MsgInfo("A nota fiscal informada não foi encontrada na base de dados.", "Atenção")

      //Sai da rotina
      Return Nil

    EndIf

  EndIf
  
  //Ordena a tabela
  SA2->(DbSetOrder(1))

  //Posiciona no fornecedor
  If SA2->(DbSeek(xFilial("SA2") + cCompForn + cCompLoja))

    //Verifica o estado
    If (SA2->A2_EST != "EX")

      //Sai da rotina
      Return Nil

    EndIf

  EndIf

  //Ordena a tabela
  CD5->(DbSetOrder(1))

  //Posiciona no registro da CD5
  If CD5->(DbSeek(xFilial("CD5") + cCompDoc + cCompSer + cCompForn + cCompLoja))

    //Mensagem
     MsgInfo("Já existe complemento de importação para essa nota fiscal, faça manutenção pela rotina de complemento", "Atenção")

    //Sai da rotina
    Return Nil

  EndIf

  //Inicializa
  Aadd(aGets, {Nil, Space(TamSx3("CD5_TPIMP")[01])  , "Tp. Doc. Imp." , .T., {"0 - Declaração de Importação", "1 - Declaração Simplificada de Importação"}})
  Aadd(aGets, {Nil, Space(TamSx3("CD5_DOCIMP")[01]) , "Doc. Imp."     , .T., {}})
  Aadd(aGets, {Nil, Space(TamSx3("CD5_LOCAL")[01])  , "Local Serv."   , .T., {"0 - Executado no país", "1 - Executado no exterior, cujo resultado se verifique no país"}})
  Aadd(aGets, {Nil, Space(TamSx3("CD5_NDI")[01])    , "No. DI/DA"     , .T., {}})
  Aadd(aGets, {Nil, Stod("")    	                  , "Registro DI"   , .T., {}})
  Aadd(aGets, {Nil, Space(TamSx3("CD5_LOCDES")[01]) , "Local Desemb." , .T., {}})
  Aadd(aGets, {Nil, Space(TamSx3("CD5_UFDES")[01])  , "UF"            , .T., {}})
  Aadd(aGets, {Nil, Stod("")                        , "Dt Desembar."  , .T., {}})
  Aadd(aGets, {Nil, Space(TamSx3("CD5_VTRANS")[01]) , "Via Transp"    , .T., StrToKarr(cBoxVTrans(),";")})
  Aadd(aGets, {Nil, Space(TamSx3("CD5_INTERM")[01]) , "Forma Import"  , .T., StrToKarr("1=Importação por conta própria;2=Importação por conta e ordem;3=Importação por encomenda",";")})
  Aadd(aGets, {Nil, Space(TamSx3("CD5_CNPJAE")[01]) , "Cnpj Adqui."   , .T., {}})
  Aadd(aGets, {Nil, Space(TamSx3("CD5_UFTERC")[01])  , "UF Terc."     , .T., {}})

  //Define a tela 
  Define MsDialog oT01 Title "Complemento de Importação" From 000, 000 To 485, 470 Pixel

  //Grupo
  @ 003, 003 To 217, 235 Title " Dados Complementares de Importação "

  //Label
  TSay():Create(oT01, &("{|| '" + aGets[01][03] + "'}"), 016, 007, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
  @ 024, 007 MsComboBox aGets[01][01] Var aGets[01][02] Items aGets[01][05]  Size 220, 013 Of oT01 Pixel 

  TSay():Create(oT01, &("{|| '" + aGets[02][03] + "'}"), 040, 007, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
  @ 048, 007 MsGet aGets[02][01] Var aGets[02][02] Picture "@!" Size 150, 010 Of oT01 Pixel 

  TSay():Create(oT01, &("{|| '" + aGets[03][03] + "'}"), 064, 007, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
  @ 072, 007 MsComboBox aGets[03][01] Var aGets[03][02] Items aGets[03][05] Size 220, 013 Of oT01 Pixel 

  TSay():Create(oT01, &("{|| '" + aGets[04][03] + "'}"), 088, 007, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
  @ 096, 007 MsGet aGets[04][01] Var aGets[04][02] Picture "@!" Size 060, 010 Of oT01 Pixel 

   TSay():Create(oT01, &("{|| '" + aGets[05][03] + "'}"), 088, 085, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
  @ 096, 085 MsGet aGets[05][01] Var aGets[05][02] Picture "@!" Size 045, 010 Of oT01 Pixel 

  TSay():Create(oT01, &("{|| '" + aGets[06][03] + "'}"), 112, 007, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
  @ 120, 007 MsGet aGets[06][01] Var aGets[06][02] Picture "@!" Size 120, 010 Of oT01 Pixel 

  TSay():Create(oT01, &("{|| '" + aGets[07][03] + "'}"), 112, 135, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
  @ 120, 135 MsGet aGets[07][01] Var aGets[07][02] Picture "@!" Size 015, 010 Of oT01 Pixel 

  TSay():Create(oT01, &("{|| '" + aGets[08][03] + "'}"), 112, 165, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
  @ 120, 165 MsGet aGets[08][01] Var aGets[08][02] Picture "@!" Size 045, 010 Of oT01 Pixel 

  TSay():Create(oT01, &("{|| '" + aGets[09][03] + "'}"), 136, 007, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
  @ 144, 007 MsComboBox aGets[09][01] Var aGets[09][02] Items aGets[09][05]  Size 220, 013 Of oT01 Pixel 

  TSay():Create(oT01, &("{|| '" + aGets[10][03] + "'}"), 160, 007, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
  @ 168, 007 MsComboBox aGets[10][01] Var aGets[10][02] Items aGets[10][05]  Size 220, 013 Of oT01 Pixel 

  TSay():Create(oT01, &("{|| '" + aGets[11][03] + "'}"), 186, 007, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
  @ 195, 007 MsGet aGets[11][01] Var aGets[11][02] Picture "@R! NN.NNN.NNN/NNNN-99" Size 070, 010 Of oT01 Pixel 

  TSay():Create(oT01, &("{|| '" + aGets[12][03] + "'}"), 186, 112, Nil, oFon1, Nil, Nil, Nil, .T., Rgb(0, 0, 139), Nil, 290, 30)
  @ 195, 112 MsGet aGets[12][01] Var aGets[12][02] Picture "@!" Size 015, 010 Of oT01 Pixel 


  //Botões
  @ 219, 198 Button "Confirmar" Size 037, 014 Pixel Of oT01 Action Processa({|| AFISA03A()}, "Processando...")
	@ 219, 157 Button "Cancelar" Size 037, 014 Pixel Of oT01 Action Close(oT01)

  //Ativa a tela
  Activate MsDialog oT01 Centered

Return Nil

/**---------------------------------------------------------------------------------------------**/
/** NOME DA FUNÇAO  : AFISA03A()				                                                   			**/
/** DESCRIÇÃOO	  	: Gravação dos dados da CD5														                      **/
/**---------------------------------------------------------------------------------------------**/
/**															CRIAÇÃO /ALTERAÇÃO / MANUTENÇÕES                            		**/	
/**---------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitação         | Descrição                      **/
/**---------------------------------------------------------------------------------------------**/


Static Function AFISA03A()

  Local aASD1 := SD1->(GetArea())
  Local aACD5  := CD5->(GetArea())

  //Ordena a tabela
  SD1->(DbSetOrder(1))

  //Posiciona 
  If SD1->(DbSeek(xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))

    //Loop nos itens
    While (!SD1->(Eof()) .AND. SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA))

      //Trava a tabela
      RecLock("CD5", .T.)

      //Grava os dados
      CD5->CD5_FILIAL   := xFilial("CD5")
      CD5->CD5_DOC      := SF1->F1_DOC
      CD5->CD5_SERIE    := SF1->F1_SERIE
      CD5->CD5_ESPEC    := SF1->F1_ESPECIE
      CD5->CD5_FORNEC   := SF1->F1_FORNECE
      CD5->CD5_LOJA     := SF1->F1_LOJA
      CD5->CD5_TPIMP    := Substr(aGets[01][02], 1, 1)
      CD5->CD5_DOCIMP   := aGets[02][02]
      CD5->CD5_LOCAL    := Substr(aGets[03][02], 1, 1)
      CD5->CD5_NDI      := aGets[04][02]
      CD5->CD5_DTDI     := aGets[05][02]
      CD5->CD5_LOCDES   := aGets[06][02]
      CD5->CD5_UFDES    := aGets[07][02]
      CD5->CD5_DTDES    := aGets[08][02]
      CD5->CD5_CODEXP   := SF1->F1_FORNECE
      CD5->CD5_NADIC    := "01"
      CD5->CD5_SQADIC   := "01"
      CD5->CD5_CODFAB   := SF1->F1_FORNECE
      CD5->CD5_LOJFAB   := SF1->F1_LOJA
      CD5->CD5_LOJEXP   := SF1->F1_LOJA         
      CD5->CD5_VTRANS   := Substr(aGets[09][02], 1, 2)
      CD5->CD5_INTERM   := Substr(aGets[10][02], 1, 1) 
      CD5->CD5_ITEM     := SD1->D1_ITEM
      CD5->CD5_SDOC     := "1"
      CD5->CD5_CNPJAE   := aGets[11][02]
      CD5->CD5_UFTERC   := aGets[12][02]

      //Libera a tabela
      CD5->(MsUnLock())

      //Próximo registro
      SD1->(DbSkip())

    EndDo

  EndIf

  //Fecha a tela 
  Close(oT01)

  //Restaura a area
  RestArea(aASD1)
  RestArea(aACD5)

Return Nil
