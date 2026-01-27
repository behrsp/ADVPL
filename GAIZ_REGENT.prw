#include 'Protheus.ch'
#include 'TOTVS.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} @type function
    Gerencia Regras para manipulação dos campos     C1_XTPCOMP | C1_XDESTCP | C1_USOMT
        C1_XDESTCP  10=Administrativo;20=AIZM;30=Garantia;40=Imobilizado;50=Imposto/Taxa;60=Industrialização;70=Revenda;80=Seg.Trabalho;90=Serviços 
        C1_XTPCOMP  MP=MatériaPrima;MC=Material Uso Consumo;SV=CompraServiço;MR=MercadoriaRevenda;AI=AtivoImobilizado;TX=ImpostosTaxas;MA=Manutenção
        C1_USOMT    1=Industrializacao;2=Uso e Consumo;3=Imobilizado;4=Revenda;5=Serviços  
@author  Robson
@since   15/09/2023
@version 2.0
/*/
//-------------------------------------------------------------------


#Define ENTER Chr(10) + Chr (13) 

User function REGENT(cTpC,cDstP)

    Local aArea     := GetArea()
    Local cRet      := ""

    //funcao para validar tipo de compra
    cRet := U_REGENTA(cTpC,cDstP)


    RestArea(aArea)  

RETURN(cRet)



user function REGENTA(cTpC, cDstP)


    Local aArea     := GetArea()
    Local cRet      := "  "
    //Local cConta    := M->C1_CONTA


    if !EMPTY( cTpC ) .AND. !EMPTY( cDstP )

        if(cTpC = 'MP') .AND. (cDstP $ '10|40|50|10|20|70|80')

            //MsgInfo("Destino não permitido para tipo compra selecionado",'Suporte')
            MsgAlert("<u>O tipo 'MP' permitido apenas para destinos:</u></ br>"+;
                ENTER+"30 - Garantia"+;
                ENTER+"60 - Industrialização","<center>MP - Matéria Prima</center>"; 
            )
   
            cRet := "  "
            cTpC := "  "



        elseif (cTpC = 'MP') .AND. (cDstP $ '30|60')
        
            cRet := "1 "
 
        

        elseif (cTpC = 'MC') .AND. (cDstP $ '10|80')
        
            cRet := "2 "

        elseif (cTpC = 'MC') .AND. (cDstP $ '20|30|40|50|60|70')
        
            //MsgInfo("Destino não permitido para tipo compra selecionado",'Suporte')
            MsgAlert("<u>O tipo 'MC' permitido apenas para destinos:</u></ br>"+;
                ENTER+"10 - Administrativo"+;
                ENTER+"80 - Seg.Trabalho","<center>MC - Material Uso e Consumo</center>"; 
            )

            cRet := "  "
            //cDstP := " "   
            cTpC := "  "     

        elseif (cTpC = 'SV') .AND. (cDstP $ '10|80')
        
            cRet := "2 " 

        elseif (cTpC = 'SV') .AND. (cDstP $ '20|40')
        
            cRet := "3 "

        elseif (cTpC = 'SV') .AND. (cDstP $ '30|60')
        
            cRet := "1 "

        elseif (cTpC = 'SV') .AND. (cDstP $ '50|70')
        
            //MsgInfo("Destino não permitido para tipo compra selecionado",'Suporte')
            MsgAlert("<u>O tipo 'SV' permitido apenas para destinos:</u></ br>"+;
                ENTER+"10 - Administrativo  -  20 - Aizm"+;
                ENTER+"30 - Garantia  -|  40 - Imobilizado"+;
                ENTER+"60 - Industrialização"+;
                ENTER+"80 - Seg.Trabalho","<center>SV - Serviço</center>"; 
            )

            cRet := "  "
            //cDstP := " "   
            cTpC := "  " 

        elseif (cTpC = 'SV') .AND. (cDstP = '70')

            cRet := "1 "      


        elseif (cTpC = 'MR') .AND. (cDstP $ '10|20|30|40|50|60|80')
        
            //MsgInfo("Destino não permitido para tipo compra selecionado",'Suporte')
            MsgAlert("<u>O tipo 'MR' permitido apenas para destinos:</u></ br>"+;
                ENTER+"70 - Revenda","<center>MR - Mercadoria Revenda</center>"; 
            )
            
            cRet := "  "
            //cDstP := " "   
            cTpC := "  " 

        elseif (cTpC = 'MR') .AND. (cDstP = '70')
        
            cRet := "4 "// nova regra 4 - Revenda


        elseif (cTpC = 'AI') .AND. (cDstP $ '30|50|60|70|80')
        
            //MsgInfo("Destino não permitido para tipo compra selecionado",'Suporte')
            MsgAlert("<u>O tipo 'AI' permitido apenas para destinos:</u></ br>"+;
                ENTER+"10 - Administrativo"+;
                ENTER+"20 - Aizm"+;
                ENTER+"40 - Imobilizado","<center>AI - Ativo Imobilizado</center>"; 
            )
            
            cRet := "  "
            //cDstP := " "   
            cTpC := "  " 

        elseif (cTpC = 'AI') .AND. (cDstP $ '10|20|40')
        
            cRet := "3 "


        elseif (cTpC = 'TX') .AND. (cDstP $ '10|20|40|50')
        
            cRet := "2 "
         
        elseif (cTpC = 'TX') .AND. (cDstP $ '30|60|50|70|80')
        
            //MsgInfo("Destino não permitido para tipo compra selecionado",'Suporte')
            MsgAlert("<u>O tipo 'TX' permitido apenas para destinos:</u></ br>"+;
                ENTER+"10 - Administrativo"+;
                ENTER+"20 - Aizm"+;
                ENTER+"40 - Imobilizado","<center>TX - Impostos/Taxas</center>"; 
            )
            
            cRet := "  "
            //cDstP := " "   
            cTpC := "  " 

        //VERIFICAÇÃO DA REGRA MA - MANUTENÇÃO 
        elseif (cTpC = 'MA') .AND. (cDstP $ '30')
        
            cRet := "1 "

        elseif (cTpC = 'MA') .AND. (cDstP $ '70|10|20|40|50|60|80')

            //MsgInfo("Destino não permitido para tipo compra selecionado",'Suporte')
            MsgAlert("<u>O tipo 'MA' permitido apenas para destinos:</u></ br>"+;
                ENTER+"30 - Garantia","<center>MA - Manutenção</center>"; 
            )
            
            cRet := "  "
            //cDstP := " "   
            cTpC := "  " 

        ENDIF

    else

        //Alert("Os campos Destino e Tipo de compra são obrigatórios.","Suporte")
        U_REGENTB()

    endif

    RestArea(aArea)

return(cRet)


user function REGENTB()

    Local aArea := GetArea()
    Local lRet := .F.

    RestArea(aArea)
        
return(lRet)
