library Project2;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils, Windows, Forms, Controls,
  Classes;

{$H+}

function StartPythonScript(const CommandLine: string): Boolean;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  StartupInfo.cb := SizeOf(StartupInfo);

  Result := CreateProcess(nil, PChar(CommandLine), nil, nil, False, 
                          CREATE_NEW_CONSOLE, nil, nil, StartupInfo, ProcessInfo);
  if Result then
    CloseHandle(ProcessInfo.hProcess)
  else
    MessageBox(0, 'Error starting Python script!', 'Error', MB_OK or MB_ICONERROR);
end;

function SendMessageToPython(const InputStr: string): string;
var
  hPipe: THandle;
  dwWritten, dwRead: DWORD;
  buffer: array[0..65535] of Char;
  resultBuffer: array[0..65535] of Char;
begin
  Screen.Cursor := crHourGlass;
  hPipe := CreateFile('\\.\pipe\alj', GENERIC_READ or GENERIC_WRITE,
                      0, nil, OPEN_EXISTING, 0, 0);

  if hPipe = INVALID_HANDLE_VALUE then
  begin
    Result := '.retry    ';
    Screen.Cursor := crDefault;
    Exit;
  end;

  StrPCopy(buffer, InputStr);
  WriteFile(hPipe, buffer, Length(InputStr) * SizeOf(Char), dwWritten, nil);

  ZeroMemory(@resultBuffer, SizeOf(resultBuffer));
  ReadFile(hPipe, resultBuffer, SizeOf(resultBuffer), dwRead, nil);
  Result := resultBuffer;

  CloseHandle(hPipe);
  Screen.Cursor := crDefault;
end;


function Send(const InputStr: string): string;
begin
  StartPythonScript('D:\PYTHON\new\wython\.venv\Scripts\pythonw.exe D:\PYTHON\new\wython\pyserver.py');
  result := SendMessageToPython(InputStr);

  if result = '.retry    ' then
  begin
    Sleep(100);
    StartPythonScript('D:\PYTHON\new\wython\.venv\Scripts\pythonw.exe D:\PYTHON\new\wython\pyserver.py');
    result := SendMessageToPython(InputStr);
  end;

end;

exports
  Send;

begin
end.
