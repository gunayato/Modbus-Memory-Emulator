unit Gateway;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, JvExComCtrls, JvToolBar, ImgList, StdCtrls, Spin,
  JvExControls, JvSpeedButton, CPort, CPortSetup, TypInfo, IdBaseComponent,
  IdComponent, IdCustomTCPServer, IdTCPServer, IdGlobal, MBusGateway,
  IdTCPConnection, IdTCPClient, JvExStdCtrls, JvMemo, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, SyncObjs;

type
  TGatewayFrm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    TransactionID: word;
    GatewayTCPClient: TIdTCPClient;
    GatewayIpPort: integer;
    RxCount: integer;
    CriticalSection: TCriticalSection;
    Stop: boolean;
    Stopped: boolean;
    procedure RxComChar(Sender: TObject; Count: Integer);
    procedure DoGateway(Count: Integer);
  public
    { Public declarations }
    ComPort: TComPort;
  end;

  procedure GatewayCOMSetup;
  function GatewayGetCOMStr:string;
  procedure GatewayLoadSettings(IniName: string);
  procedure GatewaySaveSettings(IniName: string);
  function GatewayStart(TcpIpPort: integer; var ErrorMsg: string): boolean;
  procedure GatewayStop;


var
  GatewayFrm: TGatewayFrm;


implementation

{$R *.dfm}


uses gnugettext, Main;





//
// Form create/destroy
//
procedure TGatewayFrm.FormCreate(Sender: TObject);
begin
  ComPort := TComPort.Create(Self);
  ComPort.Name := 'ComPort';
  ComPort.OnRxChar := RxComChar;
  ComPort.EventChar := #0;
  Comport.Timeouts.ReadTotalConstant := 250;
  ComPort.SyncMethod := smNone;

  CriticalSection := TCriticalSection.Create;
end;

procedure TGatewayFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(ComPort) then ComPort.Free;
  if Assigned(CriticalSection) then CriticalSection.Free;
end;



//
// Com port load/save settings
//
 procedure GatewayLoadSettings(IniName: string);
begin
  GatewayFrm.Comport.LoadSettings(stIniFile, IniName);
end;


 procedure GatewaySaveSettings(IniName: string);
begin
  GatewayFrm.Comport.StoreSettings(stIniFile, IniName);
end;


//
// Com setup string
//
function GatewayGetCOMStr:string;
begin
  with GatewayFrm do begin
    result := Format(_('%s - %s,%s,%s,%s,%s'), [ComPort.Port, BaudRateToStr(ComPort.BaudRate),
                                                                   DataBitsToStr(ComPort.DataBits),
                                                                   ParityToStr(ComPort.Parity.Bits),
                                                                   StopBitsToStr(ComPort.StopBits),
                                                                   FlowControlToStr(ComPort.FlowControl.FlowControl)]);
  end;
end;


//
// Run/Stop Gateway
//
function GatewayStart(TcpIpPort: integer; var ErrorMsg: string): boolean;
begin
  with GatewayFrm do begin

    Stop := False;
    Stopped := False;
    result := True;

    try
      ComPort.Open;
    except
      ErrorMsg := _('COM port: Error opening com port');
      result := False;
    end;

    TransactionID := 0;

    GatewayIpPort := TcpIpPort;
    RxCount := 0;

    GatewayTCPClient := TIdTCPClient.Create;
    GatewayTCPClient.Host := '127.0.0.1';
    GatewayTCPClient.Port := GatewayIpPort;
    GatewayTCPClient.ConnectTimeout := 5000;
    GatewayTCPClient.ReadTimeout := 2000;
    GatewayTCPClient.Connect;
  end;
end;


procedure GatewayStop;
var
  I: integer;
begin
  with GatewayFrm do begin
    Stop := True;

    for I := 0 to 20 do
    begin
      Sleep(100);
      Application.ProcessMessages;
      if Stopped then
        Break;
    end;

    if ComPort.Connected then ComPort.Close;
    if Assigned(GatewayTCPClient) then GatewayTCPClient.Free;
  end;
end;



//
// Receive from com port -> send by tcp
//
procedure TGatewayFrm.RxComChar(Sender: TObject; Count: Integer);
begin
  if RxCount <> 0 then Exit;
  RxCount := Count;

  if not Stop then
    DoGateway(RxCount)
  else
    Stopped := True;
end;



procedure TGatewayFrm.DoGateway(Count: Integer);
var
  I, CountChar, RecLength: integer;
  SendIPBuffer, RecvIPBuffer: TIdBytes;
  ModbusComBuffer: TModBusDataBuffer;
  ModbusIPBuffer: TModBusIPBuffer;
  CRC16: word;
  S:integer;
begin
  RecvIPBuffer := nil;

  try
    CriticalSection.Enter;

    CountChar := ComPort.Read(ModbusComBuffer, SizeOf(ModbusComBuffer));
    if CountChar > 0 then begin

//      GatewayTCPClient := TIdTCPClient.Create;
//      GatewayTCPClient.Host := '127.0.0.1';
//      GatewayTCPClient.Port := GatewayIpPort;
//      GatewayTCPClient.Connect;
//      Application.ProcessMessages;

      if not GatewayTCPClient.Connected then GatewayTCPClient.Connect;

      if GatewayTCPClient.Connected then begin
        GatewayTCPClient.Socket.InputBuffer.Clear;

        TransactionID := TransactionID + 1;
        ModbusIPBuffer.Header.ProtocolID := 0;
        ModbusIPBuffer.Header.TransactionID := Swap(TransactionID);
        RecLength := CountChar - 2;
        ModbusIPBuffer.Header.RecLength := Swap(RecLength);
        for I := 0 to CountChar - 3 do begin
          ModbusIPBuffer.MBPData[I] := ModbusComBuffer[I];
        end;
        S := Sizeof(ModbusIPBuffer.Header);
        SendIPBuffer := RawToBytes(ModbusIPBuffer, Sizeof(ModbusIPBuffer.Header) + CountChar - 2);

        GatewayTCPClient.Socket.Write(SendIPBuffer, Length(SendIPBuffer));

        GatewayTCPClient.Socket.ReadBytes(RecvIPBuffer, -1);

        CountChar := Length(RecvIPBuffer);
        if CountChar > 0 then begin
          Move(RecvIPBuffer[0], ModbusIPBuffer, CountChar);
          RecLength := Swap(ModbusIPBuffer.Header.RecLength);
          if RecLength > 0 then begin
            for I := 0 to RecLength - 1 do begin
              ModbusComBuffer[I] := ModbusIPBuffer.MBPData[I];
            end;
            CRC16 := ModBusCRC16(ModbusComBuffer, RecLength);
            ModbusComBuffer[RecLength+0] := Lo(CRC16);
            ModbusComBuffer[RecLength+1] := Hi(CRC16);
            ComPort.Write(ModbusComBuffer, RecLength + 2);
          end;
        end;

      end;

    end;

//    if Assigned(GatewayTCPClient) then GatewayTCPClient.Free;

  except
    ;
  end;
  RxCount := 0;
  CriticalSection.Leave;

end;



//
// Com port setup dialog
//
procedure GatewayCOMSetup;
var
  ComPortSetupFrm: TComSetupFrm;
begin
  ComPortSetupFrm := TComSetupFrm.Create(nil);
  with ComPortSetupFrm do
  begin
    TP_Ignore(ComPortSetupFrm, 'Combo1');
    TP_Ignore(ComPortSetupFrm, 'Combo2');
    TP_Ignore(ComPortSetupFrm, 'Combo3');
    TP_Ignore(ComPortSetupFrm, 'Combo4');
    TP_Ignore(ComPortSetupFrm, 'Combo5');
    TP_Ignore(ComPortSetupFrm, 'Combo6');
    TranslateComponent(ComPortSetupFrm, 'cport');

    Combo1.ComPort := GatewayFrm.ComPort;
    Combo2.ComPort := GatewayFrm.ComPort;
    Combo3.ComPort := GatewayFrm.ComPort;
    Combo4.ComPort := GatewayFrm.ComPort;
    Combo5.ComPort := GatewayFrm.ComPort;
    Combo6.ComPort := GatewayFrm.ComPort;
    Combo1.UpdateSettings;
    Combo2.UpdateSettings;
    Combo3.UpdateSettings;
    Combo4.UpdateSettings;
    Combo5.UpdateSettings;
    Combo6.UpdateSettings;

    if ShowModal = mrOK then
    begin
      GatewayFrm.ComPort.BeginUpdate;
      Combo1.ApplySettings;
      Combo2.ApplySettings;
      Combo3.ApplySettings;
      Combo4.ApplySettings;
      Combo5.ApplySettings;
      Combo6.ApplySettings;
      GatewayFrm.ComPort.EndUpdate;
    end;
    Free;
  end;
end;


end.
