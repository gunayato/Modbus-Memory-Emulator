;--------------------------------
; Version
!define VersionNumber "1.6.1"

;--------------------------------

OutFile "MbusMEmulator_Setup.exe"

XPStyle on
BrandingText " "

RequestExecutionLevel admin

;--------------------------------

Page license
Page components
Page directory
Page instfiles

;--------------------------------
;Definitions

!define SHCNE_ASSOCCHANGED 0x8000000
!define SHCNF_IDLIST 0

;--------------------------------

; First is default
InstallDir "$PROGRAMFILES\Modbus Memory Emulator"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\French.nlf"

; License data
LicenseLangString myLicenseData ${LANG_ENGLISH} "Licence_eng.txt"
LicenseLangString myLicenseData ${LANG_FRENCH} "Licence_fra.txt"
LicenseData $(myLicenseData)

; App name
Name "Modbus Memory Emulator ${VersionNumber}"

; Component text
LangString ^ComponentsText ${LANG_ENGLISH} "Components to install"
LangString ^ComponentsText ${LANG_FRENCH} "Composants à installer"

; Sections
LangString Sec1Name ${LANG_ENGLISH} "Main components"
LangString Sec1Name ${LANG_FRENCH} "Composants principaux"

LangString Sec2Name ${LANG_ENGLISH} "Shortcuts"
LangString Sec2Name ${LANG_FRENCH} "Raccourcis"

; Strings
LangString InstallMsg ${LANG_ENGLISH} "Installation finished"
LangString InstallMsg ${LANG_FRENCH} "Installation terminée"

LangString UninstallMsg ${LANG_ENGLISH} "Uninstallation"
LangString UninstallMsg ${LANG_FRENCH} "Désinstallation"

LangString HelpMsg ${LANG_ENGLISH} "Help"
LangString HelpMsg ${LANG_FRENCH} "Aide"

LangString HelpExtMsg ${LANG_ENGLISH} "ENG"
LangString HelpExtMsg ${LANG_FRENCH} "FRA"


;--------------------------------

; Files
Section !$(Sec1Name) sec1

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Files to copy
  File "..\EXE\*.EXE"
  File "..\EXE\*.CHM"
  File /r "..\EXE\APPLICATIONS*" 
  File /r "..\EXE\LOCALE"
   
  ; Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Modbus Memory Emulator" "DisplayName" "Modbus Memory Emulator"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Modbus Memory Emulator" "UninstallString" '"$INSTDIR\Uninstall.exe"'
      
SectionEnd


;--------------------------------


; Shortcuts
Section !$(Sec2Name) sec2
    SetShellVarContext all

  CreateDirectory "$SMPROGRAMS\Modbus Memory Emulator" 

  CreateDirectory "$SMPROGRAMS\Modbus Memory Emulator\$(HelpMsg)"
  CreateShortCut "$SMPROGRAMS\Modbus Memory Emulator\$(HelpMsg)\Modbus Memory Emulator.lnk" "$INSTDIR\MbusMEmulator_$(HelpExtMsg).CHM"

  CreateShortCut "$SMPROGRAMS\Modbus Memory Emulator\Modbus Memory Emulator.lnk" "$INSTDIR\MbusMEmulator.EXE"
  CreateShortCut "$SMPROGRAMS\Modbus Memory Emulator\Modbus Memory Dispatcher.lnk" "$INSTDIR\MbusMDispatcher.EXE"
     
  CreateShortCut "$SMPROGRAMS\Modbus Memory Emulator\$(UninstallMsg).lnk" "$INSTDIR\uninstall.exe"
SectionEnd

;--------------------------------

; Uninstaller

UninstallText $(UninstallMsg)

Section "Uninstall"
    SetShellVarContext all

  ; Remove files and uninstaller
  Delete $INSTDIR\*.EXE
  Delete $INSTDIR\*.CHM
  Delete $INSTDIR\uninstall.exe
  RMDir /r "$INSTDIR\LOCALE"
  Delete $INSTDIR\*.INI  

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\Modbus Memory Emulator\*.*"
  RMDir /r "$SMPROGRAMS\Modbus Memory Emulator"

  ; Remove directories used
  RMDir "$INSTDIR"
  
      
  ; Registry
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Modbus Memory Emulator"
  DeleteRegKey HKLM "SOFTWARE\Modbus Memory Emulator\Modbus Memory Emulator"

SectionEnd


;--------------------------------



Function .onInit

	;Language selection dialog

	Push ""
	Push ${LANG_ENGLISH}
	Push English
	Push ${LANG_FRENCH}
	Push Français
	Push A ; A means auto count languages
	       ; for the auto count to work the first empty push (Push "") must remain
	LangDLL::LangDialog "Installer Language" "Please select the language of the installer"

	Pop $LANGUAGE
	StrCmp $LANGUAGE "cancel" 0 +2
		Abort
FunctionEnd
