#include <WinAPIRes.au3>
#include <TrayConstants.au3> ; Required for the $TRAY_ICONSTATE_SHOW constant.

#Region
#AutoIt3Wrapper_Icon=ChangeCursor.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Fileversion=1.0
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Run_Obfuscator=y
#EndRegion


Opt("TrayMenuMode", 3)

Global $hPrev = Null
Global $hCursorName = 32512
Global $newCursorPath = @ScriptDir & '\cursors'



Func RestoreCursor()
  ; Restore our cursor from backup if we have one
  If $hPrev Then
	  ConsoleWrite("Restoring Cursor" & @LF)
	  if Not _WinAPI_SetSystemCursor($hPrev, $hCursorName) Then
		 ConsoleWriteError(_WinAPI_GetLastErrorMessage ( ) & @LF)
	  EndIf
	  $hPrev = Null
   EndIf
EndFunc
Func BackupCursor()
  ; Ensure we don't clobber a backed up cursor
  If $hPrev == Null Then
	  ConsoleWrite("Backing Up Cursor." & @LF)
	  $hPrev = _WinAPI_CopyCursor(_WinAPI_LoadCursor(0, $hCursorName))
   EndIf
EndFunc
Func SetNewCursor()
   BackupCursor()
   if Not _WinAPI_SetSystemCursor(_WinAPI_LoadCursorFromFile($newCursorPath & "\" & $selectedColor & "x48.cur"), 32512) Then
	  ConsoleWriteError(_WinAPI_GetLastErrorMessage ( ) & @LF)
   EndIf
   ConsoleWrite("Setting New Cursor" & @LF)
EndFunc

Func Main()
	Local $iCursor = TrayCreateMenu("Cursor") ; Create a tray menu sub menu with two sub items.
	Local $colors[12]
	$colors[0] = "Red"
	$colors[1] = "Blue"
	$colors[2] = "Green"
	$colors[3] = "Pink"
	$colors[4] = "Orange"
	$colors[5] = "Yellow"
	$colors[6] = "Black"
	$colors[7] = "White"
	$colors[8] = "Purple"
	$colors[9] = "Brown"
	$colors[10] = "Cyan"
	$colors[11] = "Lime"

	Local $options[12]

	For $i = 0 To 11
	  $options[$i] = TrayCreateItem($colors[$i], $iCursor, $i, 1)
	Next

   ; Set default color
   Global $selectedColor = "Orange"
   TrayItemSetState($options[4], $TRAY_CHECKED )


   ;; Enable/Disable Check
   Local $iEnabled = TrayCreateItem("Enabled")

   ; Set default to enabled
   Global $enabled = True
   TrayItemSetState($iEnabled, $enabled ? $TRAY_CHECKED : $TRAY_UNCHECKED)
   TrayCreateItem("") ; Create a separator line.

   TrayCreateItem("") ; Create a separator line.
   Local $idExit = TrayCreateItem("Exit")

   TraySetState($TRAY_ICONSTATE_SHOW) ; Show the tray menu.

   While 1
	  Local $evt = TrayGetMsg()

	  Switch $evt
	  Case $iEnabled ; should we be enabled?
		 $enabled = Not $enabled
	  Case $idExit ; Exit the loop.
		 RestoreCursor()
		 ExitLoop
	  EndSwitch

	  For $i = 0 To 11
		 If $evt == ($options[$i]) Then
			$selectedColor = $colors[$i]
			TrayItemSetState($options[$i], $TRAY_CHECKED )
		 EndIf
	  Next
	  TrayItemSetState($iEnabled, $enabled ? $TRAY_CHECKED : $TRAY_UNCHECKED)
	  If $enabled And  WinActive("Among Us") And Not $hPrev Then
		 SetNewCursor()
	  EndIf
	  If Not WinActive("Among Us") and $hPrev Then
		 RestoreCursor()
	  EndIf
   WEnd
EndFunc

Main()