***************************
* GetPoint
***************************
procedure GetPoint
parameter p_comcode

IF EMPTY(P_COMCODE) 
	RETURN 0
ENDIF
select sum(point) from data\invline, data\invhead ;
	where invhead.c_comcode=p_comcode ;
	and invline.invheadid = invhead.invheadid ;
	and invhead.invdate > system.ptexpiry ;
	into array apoint 
if _tally > 0
return apoint[1]
endif
return 0




***************************
* GetInvNo
***************************
procedure GetInvNo
local lcInvNo, lnSelect
lnSelect = select()
if not used('system')
  use data\system in 0
endif
select system
if rlock()
	lcInvNo = transform(nextinvno)
	replace nextinvno with nextinvno + 1
endif
unlock	

if not empty(InvPrefix)
	lcInvNo = alltrim(InvPreFix) + lcInvno	
endif
select (lnSelect)
return alltrim(lcInvNo)

***************************
* GetAddress
***************************
procedure GetAddress
parameter tcTable
if pcount() < 1
  tcTable = "customer"
endif

local lcAddress, lnSelect
lnSelect = select()
select (tcTable)
lcAddress=''
if not empty(c_street)
  lcAddress = trim(c_Street)
endif
if not empty(c_streetno)
  lcAddress = lcAddress + ' ' + trim(c_streetno) + '號'
endif

if not empty(c_floor)
  lcAddress = lcAddress + ' ' + trim(c_floor) + '樓'
endif

if not empty(c_floorno)
  lcAddress = lcAddress + ' ' + trim(c_floorno) + '字'
endif

if not empty(C_ROOMNO)
  lcAddress = lcAddress + ' ' + trim(C_ROOMNO) + '室'
endif

if not empty(C_BUILDNO)
  lcAddress = lcAddress + ' ' + trim(C_BUILDNO) + '座'
endif

if not empty(C_ROOM)
  lcAddress = lcAddress + ' ' + trim(C_ROOM) + '房'
endif


if not empty(C_FRNTBACK)
  lcAddress = lcAddress + ' ' + trim(C_FRNTBACK) 
endif


select (lnSelect)
return alltrim(lcAddress)

***************************
*Upgrade Check
***************************
PROCEDURE Upgrade

wait window "checking upgrade.." nowait
IF NOT USED('DATADICT')
	USE DATA\DATADICT IN 0
ENDIF

SELECT DATADICT
LOCATE FOR TABLE = 'BRAND' AND FIELD_NAME ='BRANDNAME'
IF !FOUND()
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('BRAND','BRANDNAME ','C',8,0,'牌子名稱')
ENDIF

IF USED('SYSTEM')
 USE IN SYSTEM
ENDIF

PUBLIC LSYSTEMINUSED
LSYSTEMINUSED = .F.
ON ERROR LSYSTEMINUSED = .T.
USE DATA\SYSTEM EXCL IN 0

ON ERROR
IF LSYSTEMINUSED = .T.
	USE DATA\SYSTEM IN 0
	RETURN
ENDIF

IF NOT TYPE('SYSTEM.PTEXPIRY ') = 'D'
	ALTER TABLE DATA\SYSTEM ADD COLUMN PTEXPIRY D
	REPLACE SYSTEM.PTEXPIRY WITH DATE()
ENDIF


IF NOT TYPE('SYSTEM.LENCRYPT ') = 'L'
	ALTER TABLE DATA\SYSTEM ADD COLUMN LENCRYPT L
ENDIF

IF SYSTEM.LENCRYPT = .F.
	=ENCODE("DATA\CUSTOMER.DBF",'mega',.F.)
	=ENCODE("DATA\USER.DBF",'mega',.F.)
	REPLACE SYSTEM.LENCRYPT WITH .T.
ENDIF


IF NOT USED("CUSTOMER")
USE DATA\CUSTOMER IN 0
ENDIF


SELECT SYSTEM

IF NOT TYPE('CUSTOMER.STOVETYPE')='C' AND NOT TYPE('SYSTEM.STOVETYPE')='C'
	ALTER TABLE DATA\SYSTEM ADD COLUMN STOVETYPE C(48)
	ALTER TABLE DATA\SYSTEM ADD COLUMN HWTYPE C(48)
	REPLACE STOVETYPE WITH "有安全裝置,無安全裝置", ;
		HWTYPE WITH "對衡式,煙道式,無煙道式"
ENDIF


IF TYPE('NEXTINVNO')='U'
   ALTER TABLE DATA\SYSTEM ADD COLUMN NEXTINVNO N(7,0)
   ALTER TABLE DATA\SYSTEM ADD COLUMN INVPREFIX C(3)
   REPLACE NEXTINVNO WITH 10000
ENDIF
IF TYPE('ServType')='U'
   ALTER TABLE DATA\SYSTEM ADD COLUMN ServType c(200)
ENDIF   

IF TYPE('INVRPT')='U'
   ALTER TABLE DATA\SYSTEM ADD COLUMN INVRPT c(15)
ENDIF   

IF TYPE('BRCHNAME')='U'
   ALTER TABLE DATA\SYSTEM ADD COLUMN BRCHNAME c(20)
ENDIF   

IF TYPE('CBRCHNAME')='U'
   ALTER TABLE DATA\SYSTEM ADD COLUMN CBRCHNAME c(16)
ENDIF   

IF TYPE("COPSAFECHK")="U"
	ALTER TABLE DATA\SYSTEM ADD COLUMN COPSAFECHK N(4,0)
	ALTER TABLE DATA\SYSTEM ADD COLUMN COPHIPRESS N(4,0)
	ALTER TABLE DATA\SYSTEM ADD COLUMN COPLOPRESS N(4,0)
	ALTER TABLE DATA\SYSTEM ADD COLUMN COPPIPE N(4,0)
	
	ALTER TABLE DATA\SYSTEM ADD COLUMN DUESAFECHK N(4,0)
	ALTER TABLE DATA\SYSTEM ADD COLUMN DUEHIPRESS N(4,0)
	ALTER TABLE DATA\SYSTEM ADD COLUMN DUELOPRESS N(4,0)
	ALTER TABLE DATA\SYSTEM ADD COLUMN DUEPIPE N(4,0)
	
	ALTER TABLE DATA\SYSTEM ADD COLUMN DEATHMTH  N(4,0)
	
	ALTER TABLE DATA\SYSTEM ADD COLUMN SHOPNAME  C(30)
	ALTER TABLE DATA\SYSTEM ADD COLUMN SHOPNAMEC  C(30)
	ALTER TABLE DATA\SYSTEM ADD COLUMN SHOPADDR  C(60)
	ALTER TABLE DATA\SYSTEM ADD COLUMN SHOPADDRC  C(60)
	ALTER TABLE DATA\SYSTEM ADD COLUMN SHOPTEL  C(20)
	ALTER TABLE DATA\SYSTEM ADD COLUMN SHOPFAX  C(20)
	ALTER TABLE DATA\SYSTEM ADD COLUMN BRAND  C(10)
	REPLACE COPSAFECHK WITH 3, COPHIPRESS WITH 3, COPLOPRESS WITH 3, COPPIPE WITH 3, ;
	  DUESAFECHK WITH 18, DUEHIPRESS WITH 36, DUELOPRESS WITH 36, DUEPIPE WITH 36, ;
	  DEATHMTH WITH 12

ENDIF

USE IN SYSTEM

IF USED('INVHEAD')
  USE IN INVHEAD
ENDIF
USE DATA\INVHEAD EXCL IN 0
SELECT INVHEAD

IF TYPE("INVHEAD.PTEARNED")="U"
	ALTER TABLE DATA\INVHEAD ADD COLUMN PTEARNED N(10)
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('INVHEAD','PTEARNED','N',10,0,'本單積分')
ENDIF

IF TYPE("INVHEAD.PTREDEEMED")="U"
	ALTER TABLE DATA\INVHEAD ADD COLUMN PTREDEEMED N(10)
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('INVHEAD','PTREDEEMED','N',10,0,'本單所用積分')
ENDIF


IF TYPE('DELDATE')='U'
 	ALTER TABLE DATA\INVHEAD ADD COLUMN DELDATE T

	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('INVHEAD','DELDATE ','T',0,0,'DELIVERY DATE')


 	ALTER TABLE DATA\INVHEAD ADD COLUMN DELDATE2 T
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('INVHEAD','DELDATE2','T',0,0,'DELIVERY DATE2')

 	ALTER TABLE DATA\INVHEAD ADD COLUMN INSDATE T
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('INVHEAD','INSDATE ','T',0,0,'INSTALL DATE')

 	ALTER TABLE DATA\INVHEAD ADD COLUMN INSDATE2 T
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('INVHEAD','INSDATE2 ','T',0,0,'INSTALL DATE2')

 	ALTER TABLE DATA\INVHEAD ADD COLUMN DELDOPER C(5)
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('INVHEAD','DELDOPER ','C',5,0,'DELIVERY SPEC')
 	
 	ALTER TABLE DATA\INVHEAD ADD COLUMN INSDOPER C(5)
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('INVHEAD','INSDOPER ','C',5,0,'INSTALL SPEC')

ENDIF
IF TYPE('PAID') = 'U'
	ALTER TABLE DATA\INVHEAD ADD COLUMN PAID N(10,2)
	ALTER TABLE DATA\INVHEAD ADD COLUMN DESPOSIT N(10,2)
*	ALTER TABLE DATA\INVHEAD ADD COLUMN DELIVERY C(50)
*	ALTER TABLE DATA\INVHEAD ADD COLUMN INSTALL C(50)
	ALTER TABLE DATA\INVHEAD ADD COLUMN REMARK M
	ALTER TABLE DATA\INVHEAD ADD COLUMN D_BYDATE D
	ALTER TABLE DATA\INVHEAD ADD COLUMN CONTACT C(15)
ENDIF

SELECT DATADICT
LOCATE FOR TABLE = 'INVHEAD' AND FIELD_NAME = 'DESPOSIT'
IF !FOUND()
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('INVHEAD','DESPOSIT','N',10,2,'訂金')
ENDIF

LOCATE FOR TABLE = 'INVHEAD' AND FIELD_NAME = 'PAID'
IF !FOUND()
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('INVHEAD','PAID','N',10,2,'己付')
ENDIF

SELECT INVHEAD


IF TYPE('INVHEAD.REMARK')<>'M'
	ALTER TABLE DATA\INVHEAD ALTER COLUMN REMARK M
ENDIF

IF TYPE("DELIVERER")="U"
 	ALTER TABLE DATA\INVHEAD ADD COLUMN DELIVERER C(10)
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('INVHEAD','DELIVERER','C',10,0,'送貨人')
ENDIF

IF TYPE("CLEARED")="U"
 	ALTER TABLE DATA\INVHEAD ADD COLUMN CLEARED L
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('INVHEAD','CLEARED','L',1,0,'已收款')
ENDIF


IF USED("INVLINE")
	USE IN INVLINE 
ENDIF
SELECT 0 
USE DATA\INVLINE EXCL

IF FSIZE("QUANTITY","INVLINE") < 4
	ALTER TABLE DATA\INVLINE ALTER COLUMN QUANTITY N(4)
ENDIF

IF TYPE("INVLINE.PRINTNAME")="U"
	ALTER TABLE DATA\INVLINE ADD COLUMN PRINTNAME C(40)
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('INVLINE','PRINTNAME ','C',40,0,'INVOICE PRODUCT NAME')
ENDIF

IF TYPE("INVLINE.POINT")="U"
	ALTER TABLE DATA\INVLINE ADD COLUMN POINT N(10)
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('INVLINE','POINT','N',10,0,'積分')
ENDIF

IF TYPE("INVLINE.C_COMCODE")="U"
	ALTER TABLE DATA\INVLINE ADD COLUMN C_COMCODE C(10)

	SELECT INVHEAD
	SCAN
		SELECT INVLINE
		REPLACE INVLINE.C_COMCODE WITH INVHEAD.C_COMCODE ;
			FOR INVLINE.INVHEADID = INVHEAD.INVHEADID 	
		SELECT INVHEAD
	ENDSCAN	
INDEX ON C_COMCODE TAG C_COMCODE
ENDIF

IF TYPE("INVLINE.C_BRDNAME")="U"
	ALTER TABLE DATA\INVLINE ADD COLUMN C_BRDNAME C(8)
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('INVLINE','C_BRDNAME','C',8,0,'牌子')

	IF NOT USED('PRODUCT')
		USE DATA\PRODUCT IN 0
	ENDIF
	SELECT INVLINE
	SCAN FOR NOT EMPTY(productid)
		SELECT PRODUCT
		LOCATE FOR PRODUCTID = INVLINE.PRODUCTID
		IF FOUND()
			REPLACE INVLINE.C_BRDNAME WITH PRODUCT.C_BRDNAME 
		ENDIF
		SELECT INVLINE
	ENDSCAN
ENDIF

USE IN INVLINE
USE IN INVHEAD

IF USED('PRODUCT')
	USE IN PRODUCT
ENDIF
SELECT 0
USE DATA\PRODUCT EXCL
IF TYPE("PRODUCT.PRINTNAME")="U"
	ALTER TABLE DATA\PRODUCT ADD COLUMN PRINTNAME C(40)
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('PRODUCT','PRINTNAME ','C',40,0,'INVOICE PRODUCT NAME')
ENDIF

IF TYPE("PRODUCT.POINT")="U"
	ALTER TABLE DATA\PRODUCT ADD COLUMN POINT N(10)
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('PRODUCT','POINT','N',10,0,'積分')
ENDIF


USE IN PRODUCT

* upgrade on 14 Jun 2000


IF USED("CUSTOMER")
	USE IN CUSTOMER
ENDIF

USE DATA\CUSTOMER EXCL
SELECT CUSTOMER

IF NOT TYPE('CUSTOMER.STOVETYPE')='C'
	ALTER TABLE DATA\CUSTOMER ADD COLUMN STOVETYPE C(12)
	ALTER TABLE DATA\CUSTOMER ADD COLUMN HWTYPE C(12)
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('CUSTOMER','STOVETYPE','C',12,0,'煮食爐款式')

	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('CUSTOMER','HWTYPE','C',12,0,'熱水爐款式')

ENDIF
IF NOT TYPE('CUSTOMER.STOVE')='C'
	ALTER TABLE DATA\CUSTOMER ADD COLUMN STOVE C(12)
	ALTER TABLE DATA\CUSTOMER ADD COLUMN HOTWATER C(12)
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('CUSTOMER','STOVE','C',12,0,'煮食爐')

	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('CUSTOMER','HOTWATER','C',12,0,'熱水爐')

ENDIF

IF NOT TYPE("CUSTOMER.C_PHONE2")="C"
	ALTER TABLE DATA\CUSTOMER ADD COLUMN C_PHONE2 C(12)
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('CUSTOMER','C_PHONE2','C',12,0,'電話2')

ENDIF


IF NOT TYPE("CUSTOMER.WARNPRESS")="L"
	ALTER TABLE DATA\CUSTOMER ADD COLUMN WARNPRESS L
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('CUSTOMER','WARNPRESS','L',1,0,'調壓器警告信')

	ALTER TABLE DATA\CUSTOMER ADD COLUMN WARNPipe L
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('CUSTOMER','WARNPIPE ','L',1,0,'接駁喉警告信')

ENDIF

IF LEN(CUSTOMER.C_STREETNO) < 15
	ALTER TABLE DATA\CUSTOMER ALTER COLUMN C_STREETNO C(15)
ENDIF


IF NOT FILE('DATA\SERVICES.DBF')
	CREATE TABLE DATA\SERVICES ;
		(C_COMCODE C(10), ;
		SERVICESID C(10), ;
		SERVTYPE C(16), ;
		MANDATE D )
INDEX ON C_COMCODE TAG C_COMCODE

	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('SERVICES','C_COMCODE','C',10,0,'客戶編號 ')
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('SERVICES','MANDATE ','D',8,0,'維修日期')
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('SERVICES','SERVICESID','C',10,0,'維修編號 ')
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('SERVICES','SERVTYPE ','C',16,0,'維修項目')

ENDIF

IF NOT FILE('DATA\EQUIPMNT.DBF')
	CREATE TABLE DATA\equipmnt ;
		(C_COMCODE C(10), ;
		EQUIPMNTID C(10), ;
		TYPE C(10), ;
		MANDATE D )

	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('EQUIPMNT','C_COMCODE','C',10,0,'客戶編號 ')

	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('EQUIPMNT','EQUIPMNTID ','C',10,0,'編號 ')

	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('EQUIPMNT','MANDATE ','D',8,0,'出廠日期')

	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('EQUIPMNT','TYPE ','C',10,0,'設備類別 ')


	IF NOT USED('CUSTOMER')
		USE DATA\CUSTOMER IN 0
	ENDIF
	SELECT CUSTOMER
	SCAN
		IF CUSTOMER.n_gregu_h > 0
			FOR I = 1 TO CUSTOMER.n_gregu_h
				lcNewID = GETID('EQU')
				INSERT INTO equipmnt (C_COMCODE, ;
					EQUIPMNTID, TYPE) VALUE ;
					(CUSTOMER.C_COMCODE,lcNewID,'低壓調節器')
			ENDFOR
		ENDIF

		IF CUSTOMER.n_gregu_R > 0
			FOR I = 1 TO CUSTOMER.n_gregu_R
				lcNewID = GETID('EQU')
				INSERT INTO equipmnt (C_COMCODE, ;
					EQUIPMNTID, TYPE) VALUE ;
					(CUSTOMER.C_COMCODE,lcNewID,'高壓調節器')
			ENDFOR
		ENDIF

		IF CUSTOMER.npipes > 0
			FOR I = 1 TO CUSTOMER.npipes 
				lcNewID = GETID('EQU')
				INSERT INTO equipmnt (C_COMCODE, ;
					EQUIPMNTID, TYPE) VALUE ;
					(CUSTOMER.C_COMCODE,lcNewID,'膠喉')
			ENDFOR
		ENDIF
		
		
		SELECT CUSTOMER
	ENDSCAN
	USE IN equipmnt
ENDIF
USE IN CUSTOMER



SELECT 0
USE DATA\EQUIPMNT EXCL
IF TYPE("EQUIPMNT.REGCODE")="U"
	ALTER TABLE DATA\EQUIPMNT ADD COLUMN REGCODE C(4)
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('EQUIPMNT','REGCODE','C',4,0,'調節器編號')
ENDIF

IF TYPE("EQUIPMNT.INSTDATE")="U"
	ALTER TABLE DATA\EQUIPMNT ADD COLUMN INSTDATE D
	INSERT INTO DATA\DATADICT (TABLE, Field_name, Field_Type, ;
		Field_Len, Field_dec, DESC ) VALUES ;
		('EQUIPMNT','INSTDATE','D',8,0,'安裝日期')
ENDIF


USE IN EQUIPMNT 


wait clear

RETURN


***************************
*CreateChildView
***************************
PROCEDURE CreateChildView
LPARAMETER tcTable, tcViewName, tcWhere, tcKeyField
LOCAL lcTable, lcFields, I
lcTable = 'DATA\'+tcTable

IF USED(tcViewName)
	USE IN (tcViewName)
ENDIF

IF NOT USED(tcTable)
	USE ('DATA\'+tcTable) IN 0
ENDIF

lcFields = FIELD(1,tcTable)
FOR I = 2 TO FCOUNT(tcTable)
	lcFields = lcFields + ',' + FIELD(I)
ENDFOR

CREATE SQL VIEW (tcViewName) AS ;
	SELECT * FROM &lcTable WHERE &tcWhere


=DBSETPROP(tcViewName+'.' + tcKeyField ,'Field','KeyField',.T.)
FOR I = 1 TO FCOUNT(tcTable)
	*!*		IF UPPER(tcKeyField) == field(i,tcTable)
	*!*		=DBSETPROP(tcViewName+'.'+field(i,tcTable), 'Field','UpDatable',.F.)
	*!*		ELSE
	=DBSETPROP(tcViewName+'.'+FIELD(I,tcTable), 'Field','UpDatable',.T.)
	*!*		ENDIF
	=DBSETPROP(tcViewName+'.'+FIELD(I,tcTable),'Field','UpdateName',tcTable+'.'+FIELD(I,tcTable))
ENDFOR

=DBSETPROP(tcViewName,'View','Tables',tcTable)
=DBSETPROP(tcViewName,'View','WhereType',1)
=DBSETPROP(tcViewName,'View','SendUpdates',.T.)



SELECT 0
USE (tcViewName)


RETURN

***************************
*GETID
***************************
PROCEDURE GETID
LPARAMETER lcPrefix
IF PARAMETER() = 0 OR EMPTY(lcPrefix)
	lcPrefix = 'SYS'
ENDIF

LOCAL lnSelect, lcReturn
lnSelect = SELECT()

IF NOT USED('CKEY')
	USE DATA\CKEY IN 0
ENDIF
SELECT CKEY
IF RLOCK()
	lcReturn = lcPrefix + TRANS(CKEY.nextid,'@L 9999999')
	REPLACE CKEY.nextid WITH CKEY.nextid + 1
ENDIF
UNLOCK

SELECT (lnSelect)
RETURN lcReturn

***************************
*
***************************

PROCEDURE DOEXIT
CLEAR WINDOWS ALL

CLEAR EVENTS
RETURN


***************************
* ISENTRYFORM
***************************

PROCEDURE ISENTRYFORM
lReturn = .F.
IF TYPE('_SCREEN.ACTIVEFORM') = 'O' ;
		AND UPPER(_SCREEN.ACTIVEFORM.CLASS) = 'ENTRYFORM'
	lReturn = .T.

ENDIF

RETURN lReturn


***************************
* ISADDABLEFORM
***************************

PROCEDURE ISADDABLEFORM
lReturn = .F.
IF TYPE('_SCREEN.ACTIVEFORM') = 'O' ;
		AND ( UPPER(_SCREEN.ACTIVEFORM.CLASS) = 'LISTEDIT' ;
		OR UPPER(_SCREEN.ACTIVEFORM.CLASS) = 'ENTRYFORM' ;
		OR UPPER(_SCREEN.ACTIVEFORM.CLASS) = 'FRMCHILDLIST' )
	lReturn = .T.

ENDIF

RETURN lReturn


***************************
*
***************************
PROCEDURE SHOWSCREEN
LPARAMETER lcScreen, lcParam
if pcount() < 2
	lcParam ="" 
endif
loScreen = 'o' + lcScreen
ldoform = .t.
IF TYPE(loScreen) = 'O' AND (!ISNULL(&loScreen))  AND  (EMPTY(lcParam))
	&loScreen..SHOW()
	ldoForm = .f.
ENDIF

IF ldoform
	RELEASE &loScreen
	PUBLIC &loScreen
if not empty(lcParam)
	DO FORM ('FORMS\'+lcScreen) with lcParam NAME (loScreen) LINK
else
	DO FORM ('FORMS\'+lcScreen) NAME (loScreen) LINK
endif	
ENDIF
RETURN


***************************
* GET CUSTOMERID
***************************
PROCEDURE GETCUSTID

IF NOT USED('SYSTEM')
	USE DATA\SYSTEM IN 0
ENDIF
LOCAL lcBranch, lcPhone
lcBranch= UPPER(TRIM(SYSTEM.BRANCH))
IF NOT EMPTY(CUSTOMER.C_TELNO1)
	lcPhone = '0'+ RIGHT(ALLTRIM(CUSTOMER.C_TELNO1),4)
	SELECT MAX(C_COMCODE) FROM CUSTOMER ;
		WHERE C_COMCODE = lcBranch+lcPhone ;
		INTO ARRAY aPhone
	IF _TALLY >0
		lcPhone=lcPhone + CHR(ASC(RIGHT(TRIM(aPhone[1]),1))+1)
	ELSE
		lcPhone = lcPhone + '0'
	ENDIF

ELSE
	* no phone no.
	lcPhone = 'Z' + RIGHT(GETID('SYS'),4) + '0'
ENDIF


RETURN lcBranch + lcPhone


***************************
* GET SHOWDATE
***************************

FUNCTION SHOWDELDATE
PARAMETER PDATETIME, PDATETIME2, POPER

IF EMPTY(PDATETIME)
	return ""
ENDIF
lcReturn = DTOC(PDATETIME)
DO CASE
CASE  HOUR(PDATETIME)=12 
	lcReturn = lcReturn + ' 中午' + TRANS(HOUR(PDATETIME),'@L 99')+ ":" + TRANS(MINUTE(PDATETIME),'@L 99') 
CASE  HOUR(PDATETIME)>11
	lcReturn = lcReturn + ' 下午' + TRANS(MOD(HOUR(PDATETIME),12),'@L 99')+ ":" + TRANS(MINUTE(PDATETIME),'@L 99') 
OTHERWISE
	lcReturn = lcReturn + ' 上午' + TRANS(HOUR(PDATETIME),'@L 99')+ ":" + TRANS(MINUTE(PDATETIME),'@L 99') 
	
ENDCASE



IF NOT EMPTY(PDATETIME2)
	lcReturn = lcReturn + ' - ' + TRANS(MOD(HOUR(PDATETIME2),12),'@L 99')+ ":" + TRANS(MINUTE(PDATETIME2),'@L 99') + pOper

ELSE
	lcReturn = lcReturn + ' ' + pOper 	
ENDIF
RETURN lcReturn

***************************
* ADD MONTHS
***************************
PROCEDURE ADDMONTHS
lparameter d,m
IF EMPTY(D)
	RETURN {//}
ENDIF
local mm,nm,ay,ny,dy
mm = month(d)
nm = ((mm + M)%12)
ay = int((mm+m)/12)
IF NM = 0
	NM = 12
	ay = ay -1
ENDIF

ny = year(d) + ay
nd = day(d)

return date(ny,nm,nd)

PROCEDURE REBUILD

select distinct * from data\datadict into cursor tempdict
tempfile = fullpath(dbf())
select datadict
delete all
append from (tempfile)
use in tempdict

DO PACKDBF WITH "BRAND"
DO PACKDBF WITH "DATADICT"
DO PACKDBF WITH "CUSTOMER"
DO PACKDBF WITH "EQUIPMNT"
DO PACKDBF WITH "INVHEAD"
DO PACKDBF WITH "INVLINE"
DO PACKDBF WITH "PRODTYPE"
DO PACKDBF WITH "PRODUCT"
DO PACKDBF WITH "REPORTS"
DO PACKDBF WITH "SAFECHK"
DO PACKDBF WITH "SERVICES"
DO PACKDBF WITH "STREETS"
DO PACKDBF WITH "SUPPLIER"
DO PACKDBF WITH "USER"
RETURN

PROCEDURE PACKDBF
PARAMETER pTable
IF USED(pTable) 
	USE IN (pTable)
ENDIF
SELECT 0
USE ("DATA\"+pTable) EXCL
PACK
DO CASE
	CASE PTABLE = "CUSTOMER"
		INDEX ON C_COMCODE TAG C_COMCODE
		INDEX ON C_CUSTOMER TAG C_CUSTOMER
		INDEX ON C_PHONE2 TAG C_PHONE2
		INDEX ON C_TELNO1 TAG C_TELNO1

	CASE PTABLE = "INVHEAD"
		INDEX ON C_COMCODE TAG C_COMCODE
		INDEX ON INVHEADID TAG INVHEADID
		INDEX ON INVOICENO TAG INVOICENO
		
	CASE PTABLE = "INVLINE"
		INDEX ON INVLINEID TAG INVLINEID
		INDEX ON INVHEADID TAG INVHEADID

	CASE PTABLE = "EQUIPMNT"
		INDEX ON EQUIPMNTID TAG EQUIPMNTID 
		INDEX ON C_COMCODE TAG C_COMCODE
		
	CASE PTABLE = "SAFECHK"
		INDEX ON SAFECHKID TAG SAFECHKID 
		INDEX ON C_COMCODE TAG C_COMCODE
		
ENDCASE

USE


**---------------------------------------------------------------**
** Program: Get_vol.prg                                           **
** Purpose: Demonstrates how to declare and use the Win32        **
**          GetVolumeInformation API.                           **
**---------------------------------------------------------------**
procedure Get_Vol
PARAMETERS lpRootPathName
LOCAL   lpVolumeNameBuffer, ;
        nVolumeNameSize, ;
        lpVolumeSerialNumber, ;
        lpMaximumComponentLength, ;
        lpFileSystemFlags, ;
        lpFileSystemNameBuffer, ;
        nFileSystemNameSize

*lpRootPathName          = "E:\"      && Drive and directory path (dontforget the "\"
lpVolumeNameBuffer       = SPACE(256) && lpVolumeName return buffer
nVolumeNameSize          = 256        && Size of/lpVolumeNameBuffer
lpVolumeSerialNumber     = 0          && lpVolumeSerialNumber buffer
lpMaximumComponentLength = 256
lpFileSystemFlags        = 0
lpFileSystemNameBuffer   = SPACE(256)
nFileSystemNameSize      = 256

DECLARE INTEGER GetVolumeInformation IN Win32API AS GetVolInfo ;
        STRING  @lpRootPathName, ;
        STRING  @lpVolumeNameBuffer, ;
        INTEGER nVolumeNameSize, ;
        INTEGER @lpVolumeSerialNumber, ;
        INTEGER @lpMaximumComponentLength, ;
        INTEGER @lpFileSystemFlags, ;
        STRING  @lpFileSystemNameBuffer, ;
        INTEGER nFileSystemNameSize

=GetVolInfo(@lpRootPathName, @lpVolumeNameBuffer, ;
                  nVolumeNameSize, @lpVolumeSerialNumber, ;
                  @lpMaximumComponentLength, @lpFileSystemFlags, ;
                  @lpFileSystemNameBuffer, nFileSystemNameSize)
return lpVolumeSerialNumber
