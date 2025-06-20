#define JavaURL "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=249559_4d5417147a92418ea8b615e228bb6935"
#define JavaInstallerName "JavaInstaller.exe"

[Setup]
AppName=Warehouse Control
AppVersion=1.3.4
DefaultDirName={userappdata}\Warehouse Control_v1.3.4
DefaultGroupName=Warehouse Control
UninstallDisplayIcon={app}\app-sklad-1.2-SNAPSHOT-jar-with-dependencies.jar
OutputDir=.
OutputBaseFilename=WCInstaller_v1.3.4
Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest


[Files]
Source: "E:\JavaProjects\appSklad\target\app-sklad-1.0-SNAPSHOT-jar-with-dependencies.jar"; DestDir: "{app}"; Flags: ignoreversion
Source: "E:\ЗАГРУЗКИ\iconMyApp.ico"; DestDir: "{app}"; Flags: ignoreversion

[Run]
Filename: "{code:GetJavaPath}"; Parameters: "-jar ""{app}\app-sklad-1.0-SNAPSHOT-jar-with-dependencies.jar"""; WorkingDir: "{app}"; Flags: shellexec postinstall skipifsilent
Filename: "https://asi0700.github.io/Warehouse_Control/guide.html"; Flags: shellexec postinstall skipifsilent

[Tasks]
Name: "desktopicon"; Description: "Создать ярлык на рабочем столе"; GroupDescription: "Дополнительные значки:"


[Icons]
Name: "{group}\Warehouse Control"; Filename: "{code:GetJavaPath}"; Parameters: "-jar ""{app}\app-sklad-1.0-SNAPSHOT-jar-with-dependencies.jar"""; WorkingDir: "{app}"; IconFilename: "{app}\iconMyApp.ico"
Name: "{userdesktop}\Warehouse Control"; Filename: "{code:GetJavaPath}"; Parameters: "-jar ""{app}\app-sklad-1.0-SNAPSHOT-jar-with-dependencies.jar"""; WorkingDir: "{app}"; IconFilename: "{app}\iconMyApp.ico"; Tasks: desktopicon

[Code]
const
  URLMON_DLL = 'urlmon.dll';

function URLDownloadToFile(Caller: Integer; URL, FileName: String; Reserved: Integer; StatusCB: Integer): Integer;
  external 'URLDownloadToFileA@urlmon.dll stdcall';

function IsJavaInstalled(): Boolean;
var
  ErrorCode: Integer;
begin
  Result := ShellExec('', 'java', '-version', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
end;

function GetJavaExe(Param: string): string;
begin
  
  if RegQueryStringValue(HKLM, 'SOFTWARE\JavaSoft\Java Runtime Environment', 'CurrentVersion', Result) then
  begin
    RegQueryStringValue(HKLM, 'SOFTWARE\JavaSoft\Java Runtime Environment\' + Result, 'JavaHome', Result);
    Result := AddBackslash(Result) + 'bin\javaw.exe';
  end
  else
  begin
    Result := 'javaw.exe';
  end;
end;

var
  JavaPath: string;

function GetJavaPath(Param: string): string;
begin
  Result := JavaPath;
end;

procedure InstallJava();
var
  TempPath, JavaInstaller: string;
  Code: Integer;
begin
  TempPath := ExpandConstant('{tmp}');
  JavaInstaller := TempPath + '\{#JavaInstallerName}';

  MsgBox('Скачивается Java. Пожалуйста, подождите...', mbInformation, MB_OK);

  if URLDownloadToFile(0, '{#JavaURL}', JavaInstaller, 0, 0) <> 0 then
  begin
    MsgBox('Ошибка при загрузке Java. Проверьте интернет-соединение.', mbCriticalError, MB_OK);
    Exit;
  end;

  if not ShellExec('', JavaInstaller, '', '', SW_SHOW, ewWaitUntilTerminated, Code) then
  begin
    MsgBox('Не удалось запустить установку Java.', mbError, MB_OK);
  end;
end;

function InitializeSetup(): Boolean;
begin
  if not IsJavaInstalled() then
  begin
    if MsgBox('Java не найдена. Установить автоматически?', mbConfirmation, MB_YESNO) = IDYES then
    begin
      InstallJava();
    end
    else
    begin
      MsgBox('Для работы программы требуется Java. Установка отменена.', mbCriticalError, MB_OK);
      Result := False;
      Exit;
    end;
  end;

  JavaPath := GetJavaExe('');
  Result := True;
end;
