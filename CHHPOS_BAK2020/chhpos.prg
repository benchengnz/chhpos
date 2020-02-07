* Set up Environment
parameter lcUserPath
#include class\registry.h
Set EXCLUSIVE OFF
Set MULTILOCK ON
Set SAFETY OFF
Set DELETE ON
Set SYSFORMAT ON
Set CENTURY ON
Set TALK OFF
Close ALL
Clear
On KEY LABEL SHIFT+F11 SUSPEND
SET LIBRARY TO C40Fox60.Fll
=CRYPTOR("CUSTOMER.DBF",'mega')
=CRYPTOR("USER.DBF",'mega')

Set PROCEDURE TO UTILS
Set CLASSLIB TO
Set CLASSLIB TO CLASS\BASECTRL.VCX
Set CLASSLIB TO CLASS\FRMCLASS.VCX ADDITIVE
Set CLASSLIB TO CLASS\REGISTRY.VCX ADDITIVE
lthiskey = alltrim(str(getvol("c:\")))
oreg = createobject("registry")
regValue=space(50)
oReg.GetRegKey("LicenceKey",@regValue,"Software\ChhPos\",HKEY_LOCAL_MACHINE)

IF lThisKey <> regValue
	MESSAGEBOX("This application has not been registred! Please contact your administrator.")
	QUIT
ENDIF

Do upgrade

Public m.cUserPath, m.UserID, glUser
m.UserID = "Admin"
if type('lcUserPath')='L'
m.cUserPath=SYS(2023)+'\'
else
cUserPath=lcUserPath
endif
If DBUSED('TempData')
	Close DataBase
Endif
If FILE(m.cUserPath+"TempData.dbc")
	*  Delete database (This.cUserPath+'Tempdata')
	*-- This doesn't check whether the database is valid first.

	* OPEN DATABASE (m.cUserPath+"TempData.dbc")

	Delete FILE (m.cUserPath+'Tempdata.dbc')
Else
	*	CREATE DATABASE (m.cUserPath+'Tempdata')
Endif

Create DATABASE (m.cUserPath+'Tempdata')
If NOT USED('SYSTEM')
	Use DATA\SYSTEM in 0
Endif

cversion = ""
DIMENSION averarray(1)
ntheval = aGetFileVersion(averarray,"chhpos.exe")
if ntheval > 0
	cversion = averarray(4)
endif

application.caption = "CHH - " + trim(System.Branch) + " (ver. " + cversion + ")"

Do form forms\login to m.lLogin


If lLogin


	On SHUTDOWN DOEXIT()

	*  REPLACE THE SYSTEM MENU
	Do .\FORMS\POSMENU.MPR
	oToolbar=CreateObject('CHHTOOLBAR')
	oToolbar.Show()
	oToolbar.dock(1)
	_Screen.windowstate=2

	Read EVENT
Endif

Set SYSMENU TO DEFAULT
On SHUTDOWN

Close DATABASE
Release oToolbar
