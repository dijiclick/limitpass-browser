#define BrowserName GetEnv('BrowserName')
#if BrowserName == ""
  #define BrowserName "MyBrowser"
#endif

#ifndef RepoRoot
  #define RepoRoot "."
#endif

#ifndef PublisherName
  #define PublisherName "My Company, Inc."
#endif
#ifndef CompanyName
  #define CompanyName "My Company, Inc."
#endif
#ifndef Version
  #define Version "1.0.0"
#endif
#ifndef IconPath
  #define IconPath "assets\icons\mybrowser.ico"
#endif
#ifndef PayloadRoot
  #define PayloadRoot "dist\MyBrowser"
#endif
#ifndef OutputInstaller
  #define OutputInstaller "dist\MyBrowser_Setup.exe"
#endif
#ifndef InstallDirName
  #define InstallDirName "MyBrowser"
#endif

#define OutputDirResolved ExtractFilePath(OutputInstaller)
#if OutputDirResolved == ""
  #undef OutputDirResolved
  #define OutputDirResolved "{#RepoRoot}\dist\"
#endif
#define OutputBaseName ChangeFileExt(GetFileName(OutputInstaller), "")

[Setup]
AppId={{A7E8D9B4-19C8-4D8A-9D3C-8A0FABF81C4F}
AppName={#BrowserName}
AppVersion={#Version}
AppPublisher={#PublisherName}
AppPublisherURL=https://example.com
AppSupportURL=https://example.com/support
AppUpdatesURL=https://example.com/updates
DefaultDirName={pf64}\{#InstallDirName}
DisableProgramGroupPage=yes
DefaultGroupName={#BrowserName}
OutputDir={#OutputDirResolved}
OutputBaseFilename={#OutputBaseName}
SetupIconFile={#IconPath}
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"
Name: "startmenuicon"; Description: "Create a Start Menu shortcut"; GroupDescription: "Additional icons:"

[Files]
Source: "{#PayloadRoot}\*"; DestDir: "{app}\"; Flags: recursesubdirs createallsubdirs replacesameversion ignoreversion

[Icons]
Name: "{autoprograms}\{#BrowserName}"; Filename: "{app}\{#BrowserName}.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\{#GetFileName(IconPath)}"; Tasks: startmenuicon
Name: "{commondesktop}\{#BrowserName}"; Filename: "{app}\{#BrowserName}.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\{#GetFileName(IconPath)}"; Tasks: desktopicon

[Run]
Filename: "{cmd}"; Parameters: "/c icacls ""{app}\policy"" /inheritance:r /grant:r ""Administrators:(OI)(CI)F"" ""SYSTEM:(OI)(CI)F"" /t"; Flags: runhidden

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

