* regkey
#INCLUDE CLASS\REGISTRY.H
set procedure to utils
set classlib to class\registry
lthiskey = alltrim(str(getvol("c:\")))
oreg = createobject("registry")

oreg.setregkey("LicenceKey",lThisKey,"Software\ChhPos\",HKEY_LOCAL_MACHINE,.T.)