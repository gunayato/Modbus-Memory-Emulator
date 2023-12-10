unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, ToolWin, JvExComCtrls, JvToolBar, JvGIF,
  ExtCtrls, StdCtrls, JvExStdCtrls, JvMemo, Spin, XPMan, DB, JvDataSource,
  JvCsvData, Grids, DBGrids, DBCtrls, JvDBControls, JvExDBGrids, JvDBGrid, Mask,
  JvExMask, JvSpin, JvDBSpinEdit, JvToolEdit, JvDialogs, JvFormPlacement,
  JvComponentBase, JvAppStorage, JvAppIniStorage, Menus, JvMRUList, ShellAPI,
  tlHelp32, AppEvnts, JvBalloonHint,
  JclFileUtils;

type
  TStringArray = array of string;

  TMainFrm = class(TForm)
    ImageList: TImageList;
    TopPanel: TPanel;
    MainPanel: TPanel;
    BottomPanel: TPanel;
    XPManifest: TXPManifest;
    ToolBar: TJvToolBar;
    OpenMenu: TToolButton;
    SaveMenu: TToolButton;
    NewMenu: TToolButton;
    ToolButton: TToolButton;
    RunMenu: TToolButton;
    CsvDBGrid: TJvDBGrid;
    CsvDB: TJvCsvDataSet;
    CsvDS: TJvDataSource;
    NavPanel: TPanel;
    CsvDBNavAdd: TJvDBNavigator;
    CsvDBNavDel: TJvDBNavigator;
    LogMemo: TJvMemo;
    ConfigMenu: TToolButton;
    ToolButton2: TToolButton;
    UnitEdit: TJvDBSpinEdit;
    ConfigEdit: TJvDBComboEdit;
    ConfigOpenDlg: TJvOpenDialog;
    CsvDBNavValid: TJvDBNavigator;
    SaveDlg: TJvSaveDialog;
    OpenDlg: TJvOpenDialog;
    PrjIniFile: TJvAppIniFileStorage;
    FormStorage: TJvFormStorage;
    AppIniFile: TJvAppIniFileStorage;
    MruList: TJvMruList;
    MRUMenu: TPopupMenu;
    StopMenu: TToolButton;
    LogPopupMenu: TPopupMenu;
    ViewRequestMenu: TMenuItem;
    ApplicationEvents: TApplicationEvents;
    BalloonHint: TJvBalloonHint;
    CloseMenu: TToolButton;
    RightPanel: TPanel;
    Logo: TImage;
    procedure LogoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NewMenuClick(Sender: TObject);
    procedure ConfigMenuClick(Sender: TObject);
    procedure ConfigEditButtonClick(Sender: TObject);
    procedure SaveMenuClick(Sender: TObject);
    procedure CsvDBNavAddClick(Sender: TObject; Button: TNavigateBtn);
    procedure CsvDBNavDelClick(Sender: TObject; Button: TNavigateBtn);
    procedure OpenMenuClick(Sender: TObject);
    procedure MruListEnumText(Sender: TObject; Value: string; Index: Integer);
    procedure RunMenuClick(Sender: TObject);
    procedure StopMenuClick(Sender: TObject);
    procedure CsvDBAfterPost(DataSet: TDataSet);
    procedure ApplicationEventsMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure CloseMenuClick(Sender: TObject);
  private
    FormName: string;  
    procedure MRUItemClick(Sender: TObject);
    procedure SetDBTitle;
    procedure RefreshTitle;
    { Private declarations }
  public
    { Public declarations }
    procedure Log(S: string; Clear: boolean = False);
    procedure ShowLog;
  end;

  
const
  MaxRunEmulator = 255;


var
  MainFrm: TMainFrm;
  LanguageExt: string;
  DBTitle: TStringArray;
  IPPort: integer = 502;
  RedirectIPPort: integer = 12345;
  GatewayEnabled: boolean;
  LogText: string;
  RunEmulatorHwnd: array[1..MaxRunEmulator+1] of THandle;


implementation

uses gnugettext, MyFunctions, Config, Common,
     Dispatch, Gateway;

{$R *.dfm}


//
// Logo
//
procedure TMainFrm.LogoClick(Sender: TObject);
begin
  ShellExecute(Handle,'OPEN','http://gunayato.free.fr',Nil,Nil,SW_SHOW);
end;



//
// Log
//
procedure TMainFrm.Log(S: string; Clear: boolean = False);
begin
  try
    LogMemo.Lines.BeginUpdate;
    if Clear then LogMemo.Clear;
    LogMemo.Lines.Add(S);
    if LogMemo.Lines.Count >= LogMemo.MaxLines then begin
      LogMemo.Lines.Delete(0);
      LogMemo.Lines.Delete(0);
      LogMemo.Lines.Delete(0);
      LogMemo.Lines.Delete(0);
      LogMemo.Lines.Delete(0);
    end;
  finally
    SendMessage(LogMemo.Handle, WM_VSCROLL, SB_BOTTOM, 0); // Jump to the end of memo  
    LogMemo.Lines.EndUpdate;
  end;

end;


procedure TMainFrm.ShowLog;
begin
  if ViewRequestMenu.Checked then Log(LogText);
end;




//
// MRU
//
procedure TMainFrm.MruListEnumText(Sender: TObject; Value: String;
  Index: Integer);
var
  Menu: TMenuItem;
begin
  if Value <> '' then begin
    Menu := TMenuItem.Create(nil);
    Menu.Caption := Value;
    Menu.OnClick := MRUItemClick;
    Menu.Tag := Index;
    MRUMenu.Items.Add(Menu);
  end;
end;

procedure TMainFrm.MRUItemClick(Sender: TObject);
begin
  OpenDlg.FileName := TMenuItem(Sender).Caption;
  OpenMenuClick(nil);
end;




//
// Form
//
procedure TMainFrm.FormCreate(Sender: TObject);
begin
  DefaultInstance.TranslateComponent(self);

  Constraints.MinWidth := Width;
  Constraints.MinHeight := Height;
  OpenMenu.Enabled := True;
  NewMenu.Enabled := True;
  SaveMenu.Enabled := False;
  ConfigMenu.Enabled := False;
  RunMenu.Enabled := False;
  MainPanel.Enabled := False;

  MRUList.Open;
  MRUList.EnumItems;

  SetLength(DBTitle, 2);
  DBTitle[0] := _('Unit');
  DBTitle[1] := _('Configuration file');

  CsvDBGrid.DataSource := nil;

  FormName := Caption;
  Caption := Caption + Format(' [v%s]', [VersionFixedFileInfoString(Application.ExeName, vfMajorMinor)]);

  HelpFile := ExtractFilePath(Application.ExeName)+Format('%s_%s.chm', [HelpFile, LanguageExt]);
end;



//
// App title
//
procedure TMainFrm.RefreshTitle;
begin
  Caption := Format('%s - %s', [ChangeFileExt(ExtractFileName(OpenDlg.FileName), ''), FormName]);
  Application.Title := Caption;
end;




//
// Config
//
procedure TMainFrm.ConfigMenuClick(Sender: TObject);
begin
  ConfigFrm.ShowModal;
end;




//
// New
//
procedure TMainFrm.NewMenuClick(Sender: TObject);
begin
  OpenMenu.Enabled := False;
  SaveMenu.Enabled := True;
  CloseMenu.Enabled := True;
  ConfigMenu.Enabled := True;
  MainPanel.Enabled := True;

  // Chargement du fichier csv source
  with CsvDB do begin
    Close;
    Filename := ChangeFileExt(ExtractFileName(Application.ExeName), '');
    Open;
    EmptyTable;
  end;
  GatewayEnabled := False;

  CsvDBNavAdd.BtnClick(nbInsert);
end;



//
// Open
//
procedure TMainFrm.OpenMenuClick(Sender: TObject);
var
  Ok: boolean;
  FName: string;
begin
  Ok := False;
  if (Sender <> nil) then Ok := OpenDlg.Execute;
  try
    if Ok or (Sender = nil) then begin
      with PrjIniFile do begin
        FileName := ChangeFileExt(OpenDlg.FileName, dfProjectFileExt);
        if not FileExists(FileName) then Abort;
        IpPort := ReadInteger('TcpIpPort', 502);
        RedirectIPPort := ReadInteger('RedirectIPPort', 12345);
        GatewayEnabled := ReadBoolean('GatewayEnabled', False);
      end;
      with CsvDB do begin
        Close;
        FName := ChangeFileExt(OpenDlg.FileName, dfDatabaseFileExt);
        if not FileExists(FName) then Abort;
        LoadFromFile(FName);
        Open;
      end;
      if CsvDB.RecordCount > 0 then begin
        CsvDBGrid.DataSource := CsvDS;
        CsvDB.Sort('UNIT', True);
        SetDBTitle;
      end;
      
      GatewayLoadSettings(PrjIniFile.FileName);

      OpenMenu.Enabled := False;
      CloseMenu.Enabled := True;
      SaveMenu.Enabled := True;
      NewMenu.Enabled := False;
      ConfigMenu.Enabled := True;
      RunMenu.Enabled := True;
      MainPanel.Enabled := True;

      MruList.AddString(ChangeFileExt(OpenDlg.FileName, ''));
      SaveDlg.FileName := OpenDlg.FileName;

      RefreshTitle;
    end;
  except
    Log(_('Loading error !'));
  end;
end;



//
// Close
//
procedure TMainFrm.CloseMenuClick(Sender: TObject);
begin
  OpenMenu.Enabled := True;
  CloseMenu.Enabled := False;
  NewMenu.Enabled := True;
  SaveMenu.Enabled := False;
  ConfigMenu.Enabled := False;
  RunMenu.Enabled := False;
  MainPanel.Enabled := False;

  CsvDB.Close;

  GatewayEnabled := False;

  Caption := FormName;
  Application.Title := Caption;
end;



//
// Save
//
procedure TMainFrm.SaveMenuClick(Sender: TObject);
begin
  if SaveDlg.Execute then begin
    with PrjIniFile do begin
      FileName := ChangeFileExt(SaveDlg.FileName, dfProjectFileExt);
      WriteInteger('TcpIpPort', IpPort);
      WriteInteger('RedirectIPPort', RedirectIPPort);
      WriteBoolean('GatewayEnabled', GatewayEnabled);
      Flush;
    end;
    CsvDB.SaveToFile(ChangeFileExt(SaveDlg.FileName, dfDatabaseFileExt));
    MruList.AddString(ChangeFileExt(SaveDlg.FileName, ''));
    GatewaySaveSettings(PrjIniFile.FileName);
    RefreshTitle;
  end;
end;





//
// DB nav
//
procedure TMainFrm.CsvDBAfterPost(DataSet: TDataSet);
begin
  RunMenu.Enabled := not StopMenu.Enabled;
  CsvDB.Sort('UNIT', True);
end;


procedure TMainFrm.CsvDBNavAddClick(Sender: TObject; Button: TNavigateBtn);
begin
  if CsvDBGrid.DataSource = nil then begin
    CsvDBGrid.DataSource := CsvDS;
    SetDBTitle;    
  end;
end;



procedure TMainFrm.CsvDBNavDelClick(Sender: TObject; Button: TNavigateBtn);
begin
  if CsvDB.RecordCount <= 0 then CsvDBGrid.DataSource := nil;
end;



procedure TMainFrm.SetDBTitle;
var
  I: integer;
begin
  // Column title
  for I := 0 to High(DBTitle) do begin
    CsvDBGrid.Columns[I].Title.Caption := DBTitle[I];
  end;
end;



//
// Edit
//
procedure TMainFrm.ConfigEditButtonClick(Sender: TObject);
begin
  if ConfigOpenDlg.Execute() then begin
    if CsvDB.State <> dsEdit then CsvDB.Edit;
    CsvDB.FieldByName('CONFIG_FILE').AsString := ConfigOpenDlg.FileName;
    ConfigEdit.EditText := ConfigOpenDlg.FileName;
  end;
end;




//
// Help
//
procedure TMainFrm.ApplicationEventsMessage(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if Msg.message = WM_KEYDOWN then
  begin
    if Msg.wParam = VK_F1 then
      HtmlHelpW(0, PChar(HelpFile), HH_DISPLAY_TOPIC, 0);
  end;

end;



//
// Run/Stop emulator
//
procedure TMainFrm.RunMenuClick(Sender: TObject);
var
  I, Port, MaxEmul: integer;
  Cmd, Arg: string;
  tsi: TStartupInfo;
  tpi: TProcessInformation;
  ErrorMsg: string;
begin
  Cmd := 'MbusMEmulator.exe';
  Port := RedirectIPPort;
  
  MaxEmul := MaxRunEmulator;

  CsvDB.First;
  for I := 1 to MaxEmul do begin
    RunEmulatorHwnd[I] := 0;
    if not CsvDB.Eof then begin
      Arg := '"' + CsvDB.FieldByName('CONFIG_FILE').AsString + '" ';
      Arg := Arg + CsvDB.FieldByName('UNIT').AsString + ' ';
      Arg := Arg + IntToStr(Port);

      // Run emulator in the list
      FillChar(tsi, SizeOf(TStartupInfo), 0);
      tsi.cb := SizeOf(TStartupInfo);
      tsi.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      tsi.wShowWindow := SW_MINIMIZE;
      if CreateProcess(
        nil, { Pointer to Application }
        PChar(Cmd+' '+Arg), { Pointer to Application with Parameter }
        nil, { pointer to process security attributes }
        nil, { pointer to thread security attributes }
        False, { handle inheritance flag }
        CREATE_NEW_CONSOLE, { creation flags }
        nil, { pointer to new environment block }
        nil, { pointer to current directory name }
        tsi, { pointer to STARTUPINFO }
        tpi) { pointer to PROCESS_INF } then
        RunEmulatorHwnd[I] := tpi.dwProcessId
      else begin
        Log(Format(_('Error running emulator for unit %s'), [CsvDB.FieldByName('UNIT').AsString]));
      end;

      Inc(Port);
      CsvDB.Next;
      Application.ProcessMessages;
      Sleep(1000);
    end;
  end;

  ConstructDispatchList;

  // Run com port gateway
  if GatewayEnabled then begin
      if GatewayStart(IpPort, ErrorMsg) then
        Log(_('COM port running'))
      else
        Log(ErrorMsg, True);
  end;

  MainPanel.Enabled := False;
  OpenMenu.Enabled := False;
  CloseMenu.Enabled := False;
  NewMenu.Enabled := False;
  SaveMenu.Enabled := False;    
  ConfigMenu.Enabled := False;
  RunMenu.Enabled := False;
  StopMenu.Enabled := True;
end;



function EnumThreadWindowProc(H:THandle;Param:Pointer):Bool;Stdcall;
begin
  // Close message
  PostMessage(H,WM_CLOSE,0,0);
  Result:=True;
end;



procedure TMainFrm.StopMenuClick(Sender: TObject);
var
  I: integer;
  h: Integer;
  Te32: TThreadEntry32;
  hProcess: THandle;
begin
  // Stop com port gateway
  if GatewayEnabled then begin
    GatewayStop;
    Log(_('COM port stopped'));
  end;

  DestructDispatchList;
  
  for I := 1 to MaxRunEmulator do begin
    if RunEmulatorHwnd[I] > 0 then begin

    h := CreateToolHelp32Snapshot(TH32CS_SNAPTHREAD,0);

    // Le process à fermer
    hProcess := RunEmulatorHwnd[I];

    // Recherche des Thread appartenant aux process
    Te32.dwSize := SizeOf(Te32);
    if Thread32First(h, Te32) then
    Repeat
      // Si le thread est créé par le process à fermer
      if Te32.th32OwnerProcessID = hProcess then
      begin
        // Alors on recherche les fenêtres appartenant aux Thread
        // L'énumération va ensuite envoyé WM_CLOSE à chaque fenêtre
        EnumThreadWindows(Te32.th32ThreadID, @EnumThreadWindowProc,0);
      end;
    until Not Thread32Next(h,Te32)
    else RaiseLastOSError;

    // Libération de la liste
    CloseHandle(h);

    end;
  end;
  MainPanel.Enabled := True;
  OpenMenu.Enabled := False;
  CloseMenu.Enabled := True;
  NewMenu.Enabled := False;
  SaveMenu.Enabled := True;
  ConfigMenu.Enabled := True;
  RunMenu.Enabled := True;
  StopMenu.Enabled := False;  
end;









end.
