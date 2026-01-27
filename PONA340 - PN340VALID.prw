#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

#Define ENTER CHR(13)+CHR(10) 


USER FUNCTION PN340VALID()

    Local aArea	    := GetArea() 
    Local lRet      := .F.

    dbSelectArea("SPW")

    IF dbSeek(xFilial('SPW') + SPW->PW_VISITA )

        If!(SPW->PW_SITVIST) == '2'

            lRet      := .T. 

        else

            MsgAlert("<center><font color='#FF0000' size='04'>Visitante com Restrição de Acesso!</font></center>"+;
                        ENTER+"<center><font color='#00008B' size='04'>Verifique seu histórico.</font></center>"+;
                        "<p>Contate o RH</p>",'Atenção')
            lRet      := .F.
           
        ENDIF

    endif

	restArea(aArea)  

RETURN lRet
