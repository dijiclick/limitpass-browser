; LimitPass Browser Installer
; Inno Setup Script - Compatible with Inno Setup 6.2+
; This creates a proper Windows installer for your custom Chromium browser

#define MyAppName "LimitPass Browser"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "DijiClick"
#define MyAppExeName "LimitPassBrowser.cmd"
#define MyAppIcon "mybrowser.ico"

[Setup]
; Basic installer settings
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\LimitPassBrowser
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
; Output settings - the installer will be created in dist folder
OutputDir=..\dist
OutputBaseFilename=LimitPassBrowser_Setup
; Compression
Compression=lzma2/ultra64
SolidCompression=yes
LZMAUseSeparateProcess=yes
; UI settings
WizardStyle=modern
; Icon file (optional - comment out if not available)
; SetupIconFile=mybrowser.ico
UninstallDisplayIcon={app}\mybrowser.ico
; Require admin for Program Files installation
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog
; Architecture
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Misc
DisableProgramGroupPage=yes
DisableWelcomePage=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Copy the entire browser folder
; Path is relative to project root (one level up from installer folder)
Source: "..\dist\LimitPassBrowser\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; Desktop shortcut
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

; Start Menu shortcut  
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"

; Start Menu uninstall shortcut
Name: "{autoprograms}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"

[Run]
; Option to launch browser after installation
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent shellexec

[Code]
// Post-install: Lock down the policy folder with ACLs
procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
  PolicyPath: String;
begin
  if CurStep = ssPostInstall then
  begin
    PolicyPath := ExpandConstant('{app}\policy');
    
    // Set restrictive ACLs on policy folder (only Administrators and SYSTEM can write)
    if DirExists(PolicyPath) then
    begin
      // Remove inherited permissions and set explicit ones
      Exec('icacls.exe', '"' + PolicyPath + '" /inheritance:r /grant:r Administrators:(OI)(CI)F /grant:r SYSTEM:(OI)(CI)F /grant:r Users:(OI)(CI)RX', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    end;
  end;
end;

// Cleanup function for uninstall
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  UserDataPath: String;
  ResultCode: Integer;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    // Optionally remove user data (ask user)
    UserDataPath := ExpandConstant('{app}\user-data');
    if DirExists(UserDataPath) then
    begin
      if MsgBox('Do you want to remove all browser data (bookmarks, history, etc.)?', mbConfirmation, MB_YESNO) = IDYES then
      begin
        DelTree(UserDataPath, True, True, True);
      end;
    end;
  end;
end;

