!include "MUI2.nsh"

Name "${NAME}"
OutFile "${OUTPUTFILE}"
Caption "${CAPTION}"
Unicode true
RequestExecutionLevel admin
SetCompress force
ManifestDPIAware true
ShowInstDetails show

!define MUI_ABORTWARNING

!insertmacro MUI_PAGE_LICENSE ".\licenses\LICENSE.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!ifdef MOD_README_PATH
  !define MUI_FINISHPAGE_SHOWREADME
  !define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
  !define MUI_FINISHPAGE_SHOWREADME_TEXT "Show release notes"
  !define MUI_FINISHPAGE_SHOWREADME_FUNCTION ShowReleaseNotes
!endif

!define MUI_PAGE_CUSTOMFUNCTION_LEAVE AfterFinishPage
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

VIProductVersion "${VERSION}.0"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${NAME}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${VERSION}.0"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "${NAME}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" ""
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${VERSION}"

!ifdef MOD_README_PATH
Function ShowReleaseNotes
  #MessageBox MB_OK "Show release notes!"
  ExecShell "open" "$INSTDIR\${MOD_README_PATH}"
FunctionEnd
!endif

Function AfterFinishPage
  MessageBox MB_OK|MB_ICONINFORMATION "Steam must be restarted for ${NAME} to appear in your game list."
FunctionEnd

Section
  SetDetailsPrint both
  SetOutPath "$INSTDIR"
  File /a /r "${MOD_FILES_PATH}\*"
  WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Uninstall"
  #MessageBox MB_OK "$INSTDIR"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir /r "$INSTDIR"
SectionEnd

Function .onInit
  ReadRegStr $R0 HKCU Software\Valve\Steam SourceModInstallPath
  IfErrors 0 sourcemods_dir_found
    MessageBox MB_OK "sourcemods directory not found!"
    Abort
sourcemods_dir_found:
  StrCpy $INSTDIR "$R0\${MOD_FOLDER}"
  #MessageBox MB_OK "$INSTDIR"
FunctionEnd
