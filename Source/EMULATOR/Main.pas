unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ExtCtrls, StdCtrls, Buttons, ComCtrls, ToolWin, JvExComCtrls, JvToolBar, ImgList,
  JvComponentBase, JvBalloonHint, JvDialogs, IdIOHandlerSocket,
  IdBaseComponent, IdComponent, IdTCPServer, IdModBusServer, ModBusConsts, ModbusTypes,
  IdThread, IdGlobal, IdSchedulerOfThread,
  JvExGrids, JvStringGrid, JvAppStorage, JvAppIniStorage, JvMRUList, Menus,
  JvInterpreterFm, JvInterpreter, IdAntiFreezeBase, IdAntiFreeze, IdContext,
  JvExStdCtrls, JvMemo, JvFormPlacement, ShellApi, JvGIF, JvThreadTimer,
  AppEvnts, XPMan, JvExControls, JvLED, JvExExtCtrls, JvShape,
  JclFileUtils;

type
  TMainFrm = class(TForm)
    MainPanel: TPanel;
    MainSplitter: TSplitter;
    ImageList: TImageList;
    ToolBar: TJvToolBar;
    OpenMenu: TToolButton;
    SaveMenu: TToolButton;
    NewMenu: TToolButton;
    ToolButton4: TToolButton;
    ConfigMenu: TToolButton;
    ConnectMenu: TToolButton;
    ScriptMenu: TToolButton;
    BalloonHint: TJvBalloonHint;
    PageControlRegisters: TPageControl;
    RegistersWordSheet: TTabSheet;
    RegistersWordSGrid: TjvStringGrid;
    PageControlBits: TPageControl;
    BitsSheet: TTabSheet;
    BitsSGrid: TJvStringGrid;
    SaveDlg: TSaveDialog;
    OpenDlg: TOpenDialog;
    AppIniFile: TJvAppIniFileStorage;
    MruList: TJvMruList;
    MRUMenu: TPopupMenu;
    IdAntiFreeze: TIdAntiFreeze;
    FormStorage: TJvFormStorage;
    BottomPanel: TPanel;
    LogMemo: TJvMemo;
    PrjIniFile: TJvAppIniFileStorage;
    LogPopupMenu: TPopupMenu;
    ViewRequestMenu: TMenuItem;
    ApplicationEvents: TApplicationEvents;
    XPManifest: TXPManifest;
    CmdLineTimer: TTimer;
    CloseMenu: TToolButton;
    RegisterMenu: TPopupMenu;
    GotoRegisterMenu: TMenuItem;
    BitMenu: TPopupMenu;
    GotoBitMenu: TMenuItem;
    RxComLEDTimer: TTimer;
    LEDPanel: TPanel;
    RxComLED: TImage;
    TxComLED: TImage;
    RxComLED_Off: TImage;
    TxComLED_Off: TImage;
    TxComLEDTimer: TTimer;
    FilterRegistersMenu: TMenuItem;
    FilterBitsMenu: TMenuItem;
    BottomBevel: TBevel;
    RightPanel: TPanel;
    Logo: TImage;
    procedure FormCreate(Sender: TObject);
    procedure NewMenuClick(Sender: TObject);
    procedure ConfigMenuClick(Sender: TObject);
    procedure ConnectMenuClick(Sender: TObject);
    procedure SaveMenuClick(Sender: TObject);
    procedure OpenMenuClick(Sender: TObject);
    procedure MruListEnumText(Sender: TObject; Value: String;
      Index: Integer);
    procedure MRUItemClick(Sender: TObject);
    procedure RegistersWordSGridKeyPress(Sender: TObject; var Key: Char);
    procedure RegistersWordSGridGetEditText(Sender: TObject; ACol,
      ARow: Integer; var Value: String);
    procedure RegistersWordSGridExitCell(Sender: TJvStringGrid; AColumn,
      ARow: Integer; const EditText: String);
    procedure BitsSGridKeyPress(Sender: TObject; var Key: Char);
    procedure BitsSGridGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure BitsSGridExitCell(Sender: TJvStringGrid; AColumn,
      ARow: Integer; const EditText: String);
    procedure BitsSGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LogoClick(Sender: TObject);
    procedure ScriptMenuClick(Sender: TObject);
    procedure ApplicationEventsMessage(var Msg: tagMSG;
      var Handled: Boolean);
    procedure CmdLineTimerTimer(Sender: TObject);
    procedure CloseMenuClick(Sender: TObject);
    procedure GotoRegisterMenuClick(Sender: TObject);
    procedure GotoBitMenuClick(Sender: TObject);
    procedure RxComLEDTimerTimer(Sender: TObject);
    procedure TxComLEDTimerTimer(Sender: TObject);
    procedure FilterRegistersMenuClick(Sender: TObject);
    procedure FilterBitsMenuClick(Sender: TObject);
    procedure RegistersWordSGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FormName: string;
    FormExit: boolean;
    RxComLED_Flag: boolean;
    TxComLED_Flag: boolean;
    RxComLED_Cnt: integer;
    TxComLED_Cnt: integer;
    procedure ServerCreate;
    procedure ServerDestroy;
    procedure ClearGrid(Grid: TStringGrid);
    procedure FillRegisters(Clear: boolean; Start: integer = 0);
    procedure PLCReadRegisters(const Sender: TIdContext;
      const RegNr, Count: Integer; var Data: TModRegisterData;
      const RequestBuffer: TModBusRequestBuffer);
    procedure PLCWriteRegisters(const Sender: TIdContext;
      const RegNr, Count: Integer; const Data: TModRegisterData;
      const RequestBuffer: TModBusRequestBuffer);
    procedure PLCReadBits(const Sender: TIdContext;
      const RegNr, Count: Integer; var Data: TModCoilData;
      const RequestBuffer: TModBusRequestBuffer);
    procedure PLCWriteBits(const Sender: TIdContext;
      const RegNr, Count: Integer; const Data: TModCoilData;
      const RequestBuffer: TModBusRequestBuffer);
    procedure PLCConnect(Sender: TIdContext);
    procedure PLCDisconnect(Sender: TIdContext);
    procedure PLCErrorCode(const Sender: TIdContext; const FunctionCode,
      ErrorCode: Byte; const RequestBuffer: TModBusRequestBuffer);
    procedure SetColumnTitle;
    procedure ActivateRxComLED;
    procedure ActivateTxComLED;
    procedure ShowLogForce;
    procedure ServerStop;
    procedure PLCInvalidFunction(const Sender: TIdContext;
      const FunctionCode: TModBusFunction;
      const RequestBuffer: TModBusRequestBuffer);
  public
    procedure SetRegisterValue(const RegNo: Integer; const Value: Word);
    function GetRegisterValue(const RegNo: Integer): Word;
    procedure RefreshDWord(RegNo: integer = -1);
    procedure SetRegisterDValue(const RegNo: Integer; const Value: Longword);
    function GetRegisterDValue(const RegNo: Integer): Longword;
    function GetRegisterFValue(const RegNo: Integer): single;
    procedure SetRegisterFValue(const RegNo: Integer; const Value: single);
    procedure FillBits(Clear: boolean; Start: integer = 0);
    procedure SetBitValue(const BitNo: Integer; const Value: Boolean);
    function GetBitValue(const BitNo: Integer): Boolean;
    procedure Log(S: string; Clear: boolean = False);
    procedure ShowLog;
    procedure RefreshTitle;    
  end;

  TByteBuffer = array[0..65535] of Byte;
  PByteBuffer = ^TByteBuffer;
  TWordBuffer = array[0..65535] of Smallint;
  PWordBuffer = ^TWordBuffer;
  TDoubleBuffer = array[0..65535] of Longint;
  PDoubleBuffer = ^TDoubleBuffer;
  TFloatBuffer = array[0..65535] of Single;
  PFloatBuffer = ^TFloatBuffer;

const
  RegCol          = 8;  // Number of column
  RegCol_No       = 0;  // Column index
  RegCol_Val      = 1;
  RegCol_Word     = 2;
  RegCol_DWord    = 3;
  RegCol_Float    = 4;
  RegCol_Hex      = 5;
  RegCol_Bin      = 6;
  RegCol_Info     = 7;

  BitCol          = 3;
  BitCol_No       = 0;
  BitCol_Bin      = 1;
  BitCol_Info     = 2;


var
  MainFrm: TMainFrm;

  LanguageExt: string;

  ModbusServer: TIdModBusServer;

  NumRegisters: Integer = 1000;
  NumBits: Integer = 500;
  TcpIpPort: integer = 502;
  ModbusSlave: integer = 1;
  ScriptEnabled: boolean;
  GatewayEnabled: boolean;

  RegistersWordCol: integer;
  RegistersWordRow: integer;
  BitsCol: integer;
  BitsRow: integer;

  LogText: string;
  LogSave: string;

  ServerActive: boolean = False;
  ConnectFlag: boolean = False;


implementation

{$R *.dfm}

uses gnugettext, MyFunctions, Config, Interpreter, Bit,
     HtmlHlp, Common, Gateway;




//
// Modbus Server
//
procedure TMainFrm.ServerCreate;
begin
  ModbusServer := TIdModbusServer.Create(self);
  if Assigned(ModbusServer) then begin
    ModbusServer.DefaultPort := TcpIpPort;
    ModbusServer.TerminateWaitTime := 5000;
    ModbusServer.OnReadHoldingRegisters := PLCReadRegisters;
    ModbusServer.OnWriteRegisters := PLCWriteRegisters;
    ModbusServer.OnReadCoils := PLCReadBits;
    ModbusServer.OnReadInputBits := PLCReadBits;;
    ModbusServer.OnWriteCoils := PLCWriteBits;
    ModbusServer.OnConnect := PLCConnect;
    ModbusServer.OnDisconnect := PLCDisconnect;
    ModbusServer.OnError := PLCErrorCode;
    ModbusServer.OnInvalidFunction := PLCInvalidFunction;
    ModbusServer.MaxRegister := NumRegisters+1;
    ModbusServer.MaxCoil := NumBits+1;
    ModbusServer.UnitID := ModbusSlave;
    ModbusServer.Active := True;
  end;
end;


procedure TMainFrm.ServerStop;
var
  I: integer;
begin
  if Assigned(ModbusServer) then begin
    ModbusServer.OnReadHoldingRegisters := nil;
    ModbusServer.OnWriteRegisters := nil;
    ModbusServer.OnReadCoils := nil;
    ModbusServer.OnWriteCoils := nil;
    ModbusServer.OnConnect := nil;
    ModbusServer.OnDisconnect := nil;
    for I := 1 to 10 do begin // Wait a little the end of activities
      Sleep(100);
      Application.ProcessMessages;
    end;
  end;
end;


procedure TMainFrm.ServerDestroy;
begin
  if not Assigned(ModbusServer) then Exit;
  try
    FreeAndNil(ModbusServer);
  except
    on E : Exception do begin ; end;
  end;
end;


//
// Form
//
procedure TMainFrm.FormCreate(Sender: TObject);
var
  ModuleName: string;
begin
  DefaultInstance.TranslateComponent(self);

  // Set grid headers titles
  with RegistersWordSGrid do begin
    FixedFont := Font;
    ColCount := RegCol;
    HideCol(RegCol_Val); // Used for value deposit cache
    ColWidths[RegCol_Word]  := 6 * (Font.Size) + 4;
    ColWidths[RegCol_DWord] := 11 * (Font.Size) + 4;
    ColWidths[RegCol_Float] := 11 * (Font.Size) + 4;
    ColWidths[RegCol_Hex]   := 5 * (Font.Size) + 4;
    ColWidths[RegCol_Bin]   := 17 * (Font.Size) + 4;
    ColWidths[RegCol_Info]  := 400;
  end;
  with BitsSGrid do begin
    FixedFont := Font;
    ColCount := BitCol;
    ColWidths[BitCol_Info] := 400;
  end;
  SetColumnTitle;

  LogSave := LogMemo.Text;

  PageControlRegisters.ActivePageIndex := 0;
  PageControlBits.ActivePageIndex := 0;

  OpenMenu.Enabled := True;
  NewMenu.Enabled := True;

  MRUList.Open;
  MRUList.EnumItems;

  ModuleName := ChangeFileExt(ExtractFileName(Application.ExeName), '');
  HelpFile := ExtractFilePath(Application.ExeName)+Format('%s_%s.chm', [ModuleName, LanguageExt]);

  FormName := Caption;
  Caption := Caption + Format(' [v%s]', [VersionFixedFileInfoString(Application.ExeName, vfMajorMinor)]);

  LEDPanel.AutoSize := False;

  MainSplitter.Top := PageControlBits.Top-MainSplitter.Height;
end;




procedure TMainFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FormExit then Exit;
  FormExit := True;
  Log(_('Exiting...'));
  if ServerActive then
    ConnectMenuClick(nil);
end;



//
// Column title
//
procedure TMainFrm.SetColumnTitle;
begin
  // Set grid headers titles
  with RegistersWordSGrid do begin
    Cells[RegCol_No, 0]     := _('No');
    Cells[RegCol_Val, 0]    := _('Value');
    Cells[RegCol_Word, 0]   := _('Word');
    Cells[RegCol_DWord, 0]  := _('DWord');
    Cells[RegCol_Float, 0]  := _('Float');
    Cells[RegCol_Hex, 0]    := _('Hex');
    Cells[RegCol_Bin, 0]    := _('Binary');
    Cells[RegCol_Info, 0]   := _('Info');
  end;
  with BitsSGrid do begin
    Cells[BitCol_No, 0]    := _('No');
    Cells[BitCol_Bin, 0]   := _('Binary');
    Cells[BitCol_Info, 0]  := _('Info');
  end;
end;





//
// Modbus server events
//
procedure TMainFrm.PLCInvalidFunction(const Sender: TIdContext;
    const FunctionCode: TModBusFunction;
    const RequestBuffer: TModBusRequestBuffer);
var
  Host: string;
  Thread: TIdThreadWithTask;
begin
    if Sender.Yarn is TIdYarnOfThread then
    begin
      Host := TIdIOHandlerSocket(Sender.Connection.IOHandler).Binding.PeerIP;
      LogText := Format(_('Invalid function code %d'), [Integer(FunctionCode)]);
      Thread := TIdYarnOfThread(Sender.Yarn).Thread;
      Thread.Synchronize(ShowLog);
    end;
end;


procedure TMainFrm.PLCErrorCode(const Sender: TIdContext;
    const FunctionCode: Byte; const ErrorCode: Byte;
    const RequestBuffer: TModBusRequestBuffer);
var
  Host: string;
  Thread: TIdThreadWithTask;
begin
    if Sender.Yarn is TIdYarnOfThread then
    begin
      Host := TIdIOHandlerSocket(Sender.Connection.IOHandler).Binding.PeerIP;
      LogText := Format(_('Error code %d'), [ErrorCode]);
      Thread := TIdYarnOfThread(Sender.Yarn).Thread;
      Thread.Synchronize(ShowLog);
    end;
end;



procedure TMainFrm.PLCReadRegisters(const Sender: TIdContext;
    const RegNr, Count: Integer; var Data: TModRegisterData;
    const RequestBuffer: TModBusRequestBuffer);
var
  i: Integer;
  Host: string;
  Thread: TIdThreadWithTask;
begin

  try

    for i := 0 to (Count - 1) do
      Data[i] := GetRegisterValue(RegNr + i);

    if not ServerActive then Sender.Connection.Disconnect;
    if not ServerActive then Exit;

    if Sender.Yarn is TIdYarnOfThread then
    begin
      Host := TIdIOHandlerSocket(Sender.Connection.IOHandler).Binding.PeerIP;
      LogText := Format(_('Read registers from %s / Start %d Count %d'), [Host, RegNr-1, Count]);
      Thread := TIdYarnOfThread(Sender.Yarn).Thread;
      Thread.Synchronize(ActivateRxComLED);
      Thread.Synchronize(ShowLog);
    end;

  except
    Exit;
  end;
end;


procedure TMainFrm.PLCWriteRegisters(const Sender: TIdContext;
    const RegNr, Count: Integer; const Data: TModRegisterData;
    const RequestBuffer: TModBusRequestBuffer) ;
var
  i: Integer;
  Host: string;
  Thread: TIdThreadWithTask;
begin

  try

    for i := 0 to (Count - 1) do
      SetRegisterValue(RegNr + i, Data[i]);

    if not ServerActive then Sender.Connection.Disconnect;
    if not ServerActive then Exit;

    if Sender.Yarn is TIdYarnOfThread then
    begin
      Host := TIdIOHandlerSocket(Sender.Connection.IOHandler).Binding.PeerIP;
      LogText := Format(_('Write registers from %s / Start %d Count %d'), [Host, RegNr-1, Count]);
      Thread := TIdYarnOfThread(Sender.Yarn).Thread;
      Thread.Synchronize(ActivateTxComLED);
      Thread.Synchronize(ShowLog);
    end;

  except
    Exit;
  end;
end;




procedure TMainFrm.PLCReadBits(const Sender: TIdContext;
    const RegNr, Count: Integer; var Data: TModCoilData;
    const RequestBuffer: TModBusRequestBuffer);
var
  i: Integer;
  Host: string;
  Thread: TIdThreadWithTask;
begin

  try

    for i := 0 to (Count - 1) do
      Data[i] := ByteBool(GetBitValue(RegNr + i));

    if not ServerActive then Sender.Connection.Disconnect;
    if not ServerActive then Exit;

    if Sender.Yarn is TIdYarnOfThread then
    begin
      Host := TIdIOHandlerSocket(Sender.Connection.IOHandler).Binding.PeerIP;
      LogText := Format(_('Read coils from %s / Start %d Count %d'), [Host, RegNr-1, Count]);
      Thread := TIdYarnOfThread(Sender.Yarn).Thread;
      Thread.Synchronize(ActivateRxComLED);
      Thread.Synchronize(ShowLog);
    end;

  except
    Exit;
  end;
end;


procedure TMainFrm.PLCWriteBits(const Sender: TIdContext;
    const RegNr, Count: Integer; const Data: TModCoilData;
    const RequestBuffer: TModBusRequestBuffer);
var
  i: Integer;
  Host: string;
  Thread: TIdThreadWithTask;
begin

  try

    for i := 0 to (Count - 1) do
      SetBitValue(RegNr + i, Boolean(Data[i]));

    if not ServerActive then Sender.Connection.Disconnect;
    if not ServerActive then Exit;

    if Sender.Yarn is TIdYarnOfThread then
    begin
      Host := TIdIOHandlerSocket(Sender.Connection.IOHandler).Binding.PeerIP;
      LogText := Format(_('Write coils from %s / Start %d Count %d'), [Host, RegNr-1, Count]);
      Thread := TIdYarnOfThread(Sender.Yarn).Thread;
      Thread.Synchronize(ActivateTxComLED);
      Thread.Synchronize(ShowLog);
    end;
    
  except
    Exit;
  end;
end;



procedure TMainFrm.PLCConnect(Sender: TIdContext);
var
  Host: string;
  Thread: TIdThreadWithTask;
begin

  try

    if not ServerActive then Sender.Connection.Disconnect;
    if not ServerActive then Exit;

//    if Sender.Yarn is TIdYarnOfThread then
//    begin
//      Host := TIdIOHandlerSocket(Sender.Connection.IOHandler).Binding.PeerIP;
//      LogText := Format(_('Connection from %s'), [Host]);
//      Thread := TIdYarnOfThread(Sender.Yarn).Thread;
//      Thread.Synchronize(ShowLogForce);
//    end;

  except
    Exit;
  end;
end;


procedure TMainFrm.PLCDisconnect(Sender: TIdContext);
var
  Thread: TIdThreadWithTask;
begin

  try

//  if Sender.Yarn is TIdYarnOfThread then
//  begin
//    LogText := _('Disconnection');
//    Thread := TIdYarnOfThread(Sender.Yarn).Thread;
//    Thread.Synchronize(ShowLogForce);
//  end;

  except
    Exit;
  end;
end;



//
// Log
//
procedure TMainFrm.ShowLog;
begin
  if ViewRequestMenu.Checked then Log(LogText);
end;


procedure TMainFrm.ShowLogForce;
begin
  Log(LogText);
end;



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



//
// Grid
//
procedure TMainFrm.ClearGrid(Grid: TStringGrid);
var
  i: Integer;
begin
  with Grid do begin

    RowCount := 2;
    for i := 0 to (ColCount - 1) do
      Cells[i, 1] := '';

  end;
end;





//
// Registers
//
procedure TMainFrm.FillRegisters(Clear: boolean; Start: integer = 0);
var
  I: Integer;
begin
  if Clear then ClearGrid(RegistersWordSGrid);
  if Start > NumRegisters then Start := NumRegisters;

  with RegistersWordSGrid do begin
    RowCount := NumRegisters + 2;
    for I := Start to NumRegisters do
    begin
      Cells[RegCol_No, I + 1] := IntToStr(i); // Register number
      SetRegisterValue(I + 1, 0);  // Set default value
    end;
    HideRow(NumRegisters + 1); // This row is not showed but still exists for dword alignment
  end;
end;




procedure TMainFrm.SetRegisterValue(const RegNo: Integer; const Value: Word);
var
  I: integer;
begin
  if (RegNo <= NumRegisters) then
  begin
    if Value > 32767 then
      I := -(65536 - Value)
    else
      I := Value;
    RegistersWordSGrid.Cells[RegCol_Val, RegNo] := IntToStr(Value);

    if not RegistersWordSGrid.EditorMode or
        (RegistersWordSGrid.EditorMode and (RegNo<>RegistersWordRow)) then begin
      RegistersWordSGrid.Cells[RegCol_Word, RegNo] := IntToStr(I);
      RegistersWordSGrid.Cells[RegCol_Hex, RegNo] := IntToHex(Value, 4);
      RegistersWordSGrid.Cells[RegCol_Bin, RegNo] := IntToBinary(Value, 16);
    end;
    RefreshDWord(RegNo);
  end;
end;


function TMainFrm.GetRegisterValue(const RegNo: Integer): Word;
begin
  if (RegNo <= NumRegisters) then
    Result := StrToInt(RegistersWordSGrid.Cells[RegCol_Val, RegNo])
  else
    Result := 0;
end;



// Refresh DWord and Float values for all the grid
procedure TMainFrm.RefreshDWord(RegNo: integer = -1);
var
  I, I2, First, Last : integer;
  W1, W2: Word;
  DWord: Longword;
  PWord: PWordBuffer;
  Float: single;
  PFloat: PFloatBuffer;
  S1, S2: string;
begin
  DWord := 0;
  PWord := @DWord;
  PFloat := @DWord;

  with RegistersWordSGrid do begin

    if RegNo = -1 then begin
      First := 1; Last := RowCount-1;
    end
    else begin
      First := RegNo-1; Last := RegNo+1;
    end;
    if First < 1 then First := 1;
    if Last > RowCount-1 then Last := RowCount-1;


    for I := First to Last do begin
      if not RegistersWordSGrid.EditorMode or
        (RegistersWordSGrid.EditorMode and (I<>RegistersWordRow)) then begin
        S1 := Cells[RegCol_Val, I];
        S2 := Cells[RegCol_Val, I+1];
        if S1 = '' then
          W1 := 0
        else
          W1 := StrToInt(S1);
        if S2 = '' then
          W2 := 0
        else
          W2 := StrToInt(S2);
        PWord[0] := W1;
        PWord[1] := W2;
        if DWord > 2147483647 then // Signed DWord (DInt)
          I2 := -(4294967296 - DWord)
        else
          I2 := DWord;
        Float := PFloat[0];
        Cells[RegCol_DWord, I] := IntToStr(I2);
        Cells[RegCol_Float, I] := FloatToStrF(Float, ffGeneral, 8, 2);
      end;
    end;

  end;
end;


procedure TMainFrm.SetRegisterDValue(const RegNo: Integer; const Value: Longword);
var
  PWord: PWordBuffer;
begin
  PWord := @Value;

  if (RegNo <= NumRegisters) then
  begin
    SetRegisterValue(RegNo,   PWord[0]);
    SetRegisterValue(RegNo+1, PWord[1]);
  end;
end;


function TMainFrm.GetRegisterDValue(const RegNo: Integer): Longword;
var
  PWord: PWordBuffer;
  DWord: Longword;
begin
  DWord := 0;
  PWord := @DWord;
  if (RegNo <= NumRegisters) then begin
    PWord[0] := GetRegisterValue(RegNo);
    PWord[1] := GetRegisterValue(RegNo+1);
    Result := DWord;
  end
  else
    Result := 0;
end;





procedure TMainFrm.SetRegisterFValue(const RegNo: Integer; const Value: single);
var
  PWord: PWordBuffer;
begin
  PWord := @Value;

  if (RegNo <= NumRegisters) then
  begin
    SetRegisterValue(RegNo,   PWord[0]);
    SetRegisterValue(RegNo+1, PWord[1]);
  end;
end;


function TMainFrm.GetRegisterFValue(const RegNo: Integer): single;
var
  PWord: PWordBuffer;
  Float: single;
begin
  Float := 0;
  PWord := @Float;
  if (RegNo <= NumRegisters) then begin
    PWord[0] := GetRegisterValue(RegNo);
    PWord[1] := GetRegisterValue(RegNo+1);
    Result := Float;
  end
  else
    Result := 0;
end;


//
// Bits
//
procedure TMainFrm.FillBits(Clear: boolean; Start: integer = 0);
var
  i: Integer;
begin
  if Clear then ClearGrid(BitsSGrid);
  if Start > NumBits then Start := NumBits;

  with BitsSGrid do begin

    RowCount := NumBits + 1;
    for i := Start to NumBits do
    begin
      Cells[0, i + 1] := IntToStr(i);
      SetBitValue(i + 1, False);
    end;

  end;
end;


procedure TMainFrm.SetBitValue(const BitNo: Integer; const Value: Boolean);
var
  S: string;
begin
  if (BitNo <= NumBits) then begin
    if Value then S := '1' else S := '0';
    BitsSGrid.Cells[BitCol_Bin, BitNo] := S;
  end;
end;



function TMainFrm.GetBitValue(const BitNo: Integer): Boolean;
begin
  if (BitNo <= NumBits) then
    Result := StrToBool(BitsSGrid.Cells[BitCol_Bin, BitNo])
  else
    Result := False;
end;


//
// New project
//
procedure TMainFrm.NewMenuClick(Sender: TObject);
begin
  OpenMenu.Enabled := False;
  CloseMenu.Enabled := True;
  SaveMenu.Enabled := True;
  NewMenu.Enabled := False;
  ConfigMenu.Enabled := True;
  ConnectMenu.Enabled := True;
  ScriptMenu.Enabled := True;
  MainPanel.Enabled := True;

  FillRegisters(True);
  FillBits(True);
  ScriptEnabled := False;
  GatewayEnabled := False;

  LogMemo.Text := LogSave;
  ScriptFrm.InterpreterProgram.Source := ScriptSave;
end;


//
// Configuration
//
procedure TMainFrm.ConfigMenuClick(Sender: TObject);
var
  OldNumRegisters: Integer;
  OldNumBits: Integer;
begin
  OldNumRegisters := NumRegisters;
  OldNumBits := NumBits;
  if ConfigFrm.ShowModal = mrOk then begin
    RegistersWordSGrid.ShowRow(OldNumRegisters + 1, -1);
    FillRegisters(False, NumRegisters+(OldNumRegisters-NumRegisters));
    FillBits(False, NumBits+(OldNumBits-NumBits));
  end;
end;



//
// Script editor
//
procedure TMainFrm.ScriptMenuClick(Sender: TObject);
begin
  ScriptFrm.ShowModal;
end;



//
// Run the emulator
//
procedure TMainFrm.ConnectMenuClick(Sender: TObject);
var
  ErrorMsg: string;
begin
  if ConnectFlag then Exit;

  try
    ConnectFlag := True;

    ServerActive := ConnectMenu.Down and not FormExit;

    if ServerActive then begin
      // Run emulator
      try
        ServerCreate;
        Log(_('Emulator running'), True);
      except
        ServerActive := False;
        Log(_('Error in running server... (port already in use ?)'), True);
      end;
      // Run com port gateway
      if GatewayEnabled then begin
        if GatewayStart(TcpIpPort, ErrorMsg) then
          Log(_('COM port running'))
        else
          Log(ErrorMsg, True);
      end;
    end
    else begin
      // Stop com port gateway
      if GatewayEnabled then begin
        GatewayStop;
        Log(_('COM port stopped'));
      end;

      // Stop emulator
      ServerStop;

      if ScriptEnabled then
        Log(_('Stopping script')); // Script is auto-stopped by ServerActive variable
      try
        ServerDestroy;
        Log(_('Emulator stopped'));
      except
        Log(_('Error in stopping server...'));
      end;
    end;

  finally
    ConnectFlag := False;
    ConnectMenu.Down := ServerActive;
    CloseMenu.Enabled := not ServerActive;
    SaveMenu.Enabled := not ServerActive;
    ConfigMenu.Enabled := not ServerActive;
    ScriptMenu.Enabled := not ServerActive;
    // Run script interpreter
    if ServerActive and ScriptEnabled then begin
      Log(_('Running script'));
      ScriptFrm.RunScript;
    end
  end;

end;


//
// App title
//
procedure TMainFrm.RefreshTitle;
begin
  Caption := Format('%s - %d - %s', [ChangeFileExt(ExtractFileName(OpenDlg.FileName), ''), ModbusSlave, FormName]);
  Application.Title := Caption;
end;



//
// Save/open/close project
//
procedure TMainFrm.SaveMenuClick(Sender: TObject);
begin
  if SaveDlg.Execute then begin
    with PrjIniFile do begin        
      FileName := ChangeFileExt(SaveDlg.FileName, efProjectFileExt);
      WriteInteger('TcpIpPort', TcpIpPort);
      WriteInteger('ModbusSlave', ModbusSlave);
      WriteInteger('NumRegisters', NumRegisters);
      WriteInteger('NumBits', NumBits);
      WriteBoolean('ScriptEnabled', ScriptEnabled);
      WriteBoolean('GatewayEnabled', GatewayEnabled);
      Flush;
    end;

    // COM port for gateway
    GatewaySaveSettings(PrjIniFile.FileName);

    RegistersWordSGrid.SaveToCSV(ChangeFileExt(SaveDlg.FileName, efRegistersFileExt));
    BitsSGrid.SaveToCSV(ChangeFileExt(SaveDlg.FileName, efBitsFileExt));

    with ScriptFrm do begin
      InterpreterProgram.Pas.SaveToFile(ChangeFileExt(SaveDlg.FileName, efScriptFileExt));
    end;
  end;
  OpenDlg.FileName := SaveDlg.FileName;
  MruList.AddString(ChangeFileExt(OpenDlg.FileName, ''));
  MRUList.EnumItems;
  RefreshTitle;
end;



procedure TMainFrm.OpenMenuClick(Sender: TObject);
var
  Ok: boolean;
  I: integer;
  ColWidthsRSave: array[0..99] of integer;
  ColWidthsBSave: array[0..99] of integer;
  F: string;
begin
  Ok := False;
  if (Sender <> nil) then Ok := OpenDlg.Execute;
  if Ok or (Sender = nil) then begin
    with PrjIniFile do begin
      FileName := ChangeFileExt(OpenDlg.FileName, efProjectFileExt);
      TcpIpPort := ReadInteger('TcpIpPort', 502);
      ModbusSlave := ReadInteger('ModbusSlave', 1);
      NumRegisters := ReadInteger('NumRegisters', 1000);
      NumBits := ReadInteger('NumBits', 1000);
      ScriptEnabled := ReadBoolean('ScriptEnabled', False);
      GatewayEnabled := ReadBoolean('GatewayEnabled', False);
    end;

    // COM port for gateway
    GatewayLoadSettings(PrjIniFile.FileName);


    // Save cols widths
    with RegistersWordSGrid do begin
      for I := 0 to ColCount-1 do ColWidthsRSave[I] := ColWidths[I]; end;
    with BitsSGrid do
      for I := 0 to ColCount-1 do ColWidthsBSave[I] := ColWidths[I];

    // Load data
    RegistersWordSGrid.LoadFromCSV(ChangeFileExt(OpenDlg.FileName, efRegistersFileExt));
    RegistersWordSGrid.RowCount := NumRegisters + 2;
    RegistersWordSGrid.HideRow(NumRegisters + 1);
    BitsSGrid.LoadFromCSV(ChangeFileExt(OpenDlg.FileName, efBitsFileExt));

    // Restore cols widths
    with RegistersWordSGrid do
      for I := 0 to ColCount-1 do ColWidths[I] := ColWidthsRSave[I];
    with BitsSGrid do
      for I := 0 to ColCount-1 do ColWidths[I] := ColWidthsBSave[I];

    with ScriptFrm do begin
      F := ChangeFileExt(OpenDlg.FileName, efScriptFileExt);
      if FileExists(F) then
        InterpreterProgram.Pas.LoadFromFile(F);
    end;

    SetColumnTitle;

    OpenMenu.Enabled := False;
    CloseMenu.Enabled := True;
    SaveMenu.Enabled := True;
    NewMenu.Enabled := False;
    ConfigMenu.Enabled := True;
    ConnectMenu.Enabled := True;
    ScriptMenu.Enabled := True;
    MainPanel.Enabled := True;

    MruList.AddString(ChangeFileExt(OpenDlg.FileName, ''));
    SaveDlg.FileName := OpenDlg.FileName;

    FilterRegistersMenu.Checked := False;
    FilterBitsMenu.Checked := False;

    RefreshTitle;

  end;
end;



procedure TMainFrm.CloseMenuClick(Sender: TObject);
begin
    OpenMenu.Enabled := True;
    CloseMenu.Enabled := False;
    SaveMenu.Enabled := False;
    NewMenu.Enabled := True;
    ConfigMenu.Enabled := False;
    ConnectMenu.Enabled := False;
    ScriptMenu.Enabled := False;
    MainPanel.Enabled := False;

    ClearGrid(RegistersWordSGrid);
    ClearGrid(BitsSGrid);

    Caption := FormName;
    Application.Title := Caption;

    LogMemo.Text := LogSave;
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
// Registers grid edit
//
procedure TMainFrm.RegistersWordSGridKeyPress(Sender: TObject;
  var Key: Char);
begin
  // Backspace
  if Key = #8 then Exit;
  
  // Word
  if RegistersWordCol = RegCol_Word then begin
    if Key = #13 then
      SetRegisterValue(RegistersWordRow, StrToInt(RegistersWordSGrid.Cells[RegistersWordCol, RegistersWordRow]))
    else
      if not (Key in ['0','1','2','3','4','5','6','7','8','9', '-']) then Key := #0;
  end;
  // Double Word
  if RegistersWordCol = RegCol_DWord then begin
    if Key = #13 then
      SetRegisterDValue(RegistersWordRow, StrToInt(RegistersWordSGrid.Cells[RegistersWordCol, RegistersWordRow]))
    else
      if not (Key in ['0','1','2','3','4','5','6','7','8','9', '-']) then Key := #0;
  end;
  // Float
  if RegistersWordCol = RegCol_Float then begin
    if Key = #13 then
      SetRegisterFValue(RegistersWordRow, StrToFloat(RegistersWordSGrid.Cells[RegistersWordCol, RegistersWordRow]))
    else
      if not (Key in ['0','1','2','3','4','5','6','7','8','9', '-', DecimalSeparator]) then Key := #0;
  end;
  // Hexadecimal
  if RegistersWordCol = RegCol_Hex then begin
    if Key = #13 then
      SetRegisterValue(RegistersWordRow, StrToInt('$'+RegistersWordSGrid.Cells[RegistersWordCol, RegistersWordRow]))
    else
      if not (Key in ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','a','b','c','d','e','f']) then Key := #0;
  end;
  // Binary
  if RegistersWordCol = RegCol_Bin then begin
    if Key = #13 then
      SetRegisterValue(RegistersWordRow, BinaryToInt(RegistersWordSGrid.Cells[RegistersWordCol, RegistersWordRow]))
    else
      if not (Key in ['0','1']) then Key := #0;
  end;
end;



procedure TMainFrm.RegistersWordSGridGetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: String);
begin
  RegistersWordCol := ACol;
  RegistersWordRow := ARow;
end;


procedure TMainFrm.RegistersWordSGridExitCell(Sender: TJvStringGrid;
  AColumn, ARow: Integer; const EditText: String);
var
  Key: char;
begin
  Key := #13;
  RegistersWordSGridKeyPress(Sender, Key); // 'Enter' key simul
end;




procedure TMainFrm.RegistersWordSGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Column, Row: integer;
  Value: word;
begin
  if Button in [mbMiddle] then begin
    RegistersWordSGrid.MouseToCell(X, Y, Column, Row);
    if Column <> RegCol_Bin then Exit;
    Value := GetRegisterValue(Row);
    Value := EditWordBinary(Value);
    SetRegisterValue(Row, Value);
  end;
end;




//
// Bits grid edit
//
procedure TMainFrm.BitsSGridKeyPress(Sender: TObject; var Key: Char);
var
  B: boolean;
begin
  // Backspace
  if Key = #8 then Exit;

  // Binary
  if BitsCol = BitCol_Bin then begin
    BitsSGrid.Cells[BitsCol, BitsRow] := Copy(BitsSGrid.Cells[BitsCol, BitsRow], 0, 1);  
    if Key = #13 then begin
      if BitsSGrid.Cells[BitsCol, BitsRow] = '1' then B := True else B := False;
      SetBitValue(BitsRow, B);
    end;
    if not (Key in ['0','1']) then Key := #0;
  end;
end;


procedure TMainFrm.BitsSGridGetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: String);
begin
  BitsCol := ACol;
  BitsRow := ARow;
end;

procedure TMainFrm.BitsSGridExitCell(Sender: TJvStringGrid; AColumn,
  ARow: Integer; const EditText: String);
var
  Key: char;
begin
  Key := #13;
  BitsSGridKeyPress(Sender, Key); // 'Enter' key simul
end;


procedure TMainFrm.BitsSGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  B: boolean;
  Column, Row: integer;
begin
  if Button in [mbMiddle] then begin
    BitsSGrid.MouseToCell(X, Y, Column, Row);
    if Column <> BitCol_Bin then Exit;
    if BitsSGrid.Cells[Column, Row] = '1' then B := False else B := True;
    SetBitValue(Row, B);
  end;
end;



//
// Logo
//
procedure TMainFrm.LogoClick(Sender: TObject);
begin
  ShellExecute(Handle,'OPEN','http://gunayato.free.fr',Nil,Nil,SW_SHOW);
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
// Cmd line
//
procedure TMainFrm.CmdLineTimerTimer(Sender: TObject);
begin
  CmdLineTimer.Enabled := False;
  ConnectMenu.Down := True;
  ConnectMenu.Click; // Active emulator from command line
end;





//
// Register menu
//
procedure TMainFrm.GotoRegisterMenuClick(Sender: TObject);
var
  S: string;
  I: integer;
begin
  S := InputBox(_('Go to register'), _('Enter register number to reach'), '');
  if TryStrToInt(S, I) then begin
    Inc(I);
    if I <= RegistersWordSGrid.RowCount then
      RegistersWordSGrid.Row := I;
  end;
end;




procedure TMainFrm.FilterRegistersMenuClick(Sender: TObject);
var
  I: integer;
  Prev, V: boolean;
begin                  
  Prev := True;
  FilterRegistersMenu.Checked := not FilterRegistersMenu.Checked;
  // Set grid headers titles
  with RegistersWordSGrid do begin
    for I := 1 to RowCount-1 do begin
      V := ( (Cells[RegCol_Info, I] <> '') and FilterRegistersMenu.Checked ) or not FilterRegistersMenu.Checked;
      if V then
        ShowRow(I, -1)
      else begin
        if Prev then
          ShowRow(I, 1)
        else
          HideRow(I);
      end;
      Prev := V;
    end;
  end;
end;




//
// Bit menu
//
procedure TMainFrm.GotoBitMenuClick(Sender: TObject);
var
  S: string;
  I: integer;
begin
  S := InputBox(_('Go to bit'), _('Enter bit number to reach'), '');
  if TryStrToInt(S, I) then begin
    Inc(I);
    if I <= BitsSGrid.RowCount then
      BitsSGrid.Row := I;
  end;
end;



procedure TMainFrm.FilterBitsMenuClick(Sender: TObject);
var
  I: integer;
  Prev, V: boolean;
begin
  Prev := True;
  FilterBitsMenu.Checked := not FilterBitsMenu.Checked;
  // Set grid headers titles
  with BitsSGrid do begin
    for I := 1 to RowCount-1 do begin
      V := ( (Cells[BitCol_Info, I] <> '') and FilterBitsMenu.Checked ) or not FilterBitsMenu.Checked;
      if V then
        ShowRow(I, -1)
      else begin
        if Prev then
          ShowRow(I, 1)
        else
          HideRow(I);
      end;
      Prev := V;
    end;
  end;
end;




//
// Communication LED
//
procedure TMainFrm.ActivateRxComLED;
begin
  RxComLEDTimer.Enabled := True;
  RxComLED_Cnt := 2;
end;


procedure TMainFrm.RxComLEDTimerTimer(Sender: TObject);
begin
  RxComLED_Cnt := RxComLED_Cnt -1;
  if RxComLED_Cnt <= 0 then
  begin
    RxComLEDTimer.Enabled := False;
    RxComLED_Flag := True;
  end;

  RxComLED_Flag := not RxComLED_Flag;
  RxComLED.Visible := RxComLED_Flag;
  RxComLED_Off.Visible := not RxComLED.Visible;
end;




procedure TMainFrm.ActivateTxComLED;
begin
  TxComLEDTimer.Enabled := True;
  TxComLED_Cnt := 2;
end;


procedure TMainFrm.TxComLEDTimerTimer(Sender: TObject);
begin
  TxComLED_Cnt := TxComLED_Cnt -1;
  if TxComLED_Cnt <= 0 then
  begin
    TxComLEDTimer.Enabled := False;
    TxComLED_Flag := True;
  end;

  TxComLED_Flag := not TxComLED_Flag;
  TxComLED.Visible := TxComLED_Flag;
  TxComLED_Off.Visible := not TxComLED.Visible;
end;



end.
