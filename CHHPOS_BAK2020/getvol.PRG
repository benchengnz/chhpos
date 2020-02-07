**---------------------------------------------------------------**
** Program: Get_vol.prg                                           **
** Purpose: Demonstrates how to declare and use the Win32        **
**          GetVolumeInformation API.                           **
**---------------------------------------------------------------**
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
