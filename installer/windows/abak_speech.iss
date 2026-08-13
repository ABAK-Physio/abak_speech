#ifndef MyAppVersion
  #define MyAppVersion "0.0.0"
#endif

#define MyAppName "ABAK Speech"
#define MyAppPublisher "ABAK-Physio"

[Setup]
AppId={{A0F6D501-8C1F-4C78-9E14-ABAKSPEECH001}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}

DefaultDirName={commonappdata}\ABAK\speech
DisableProgramGroupPage=yes

OutputDir=..\..\dist
OutputBaseFilename=ABAK_Speech_Windows

Compression=lzma2
SolidCompression=yes

PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

Uninstallable=yes

[Files]
Source: "..\..\abak-speech.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\whisper-cli.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\ggml-large-v3-turbo.bin"; DestDir: "{app}"; Flags: ignoreversion

[Run]
Filename: "{app}\abak-speech.exe"; Parameters: "--status"; Flags: runhidden waituntilterminated