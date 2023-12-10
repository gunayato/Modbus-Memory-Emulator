unit Dispatch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdCustomTCPServer, IdTCPServer, IdContext, IdGlobal, IdThread,
  IdIOHandlerSocket, IdSchedulerOfThread;

type
  TDispatchFrm = class(TForm)
    TCPServer: TIdTCPServer;
    procedure TCPServerExecute(AContext: TIdContext);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


  // Emulator record
  TEmulTable = record
      ModbusUnit      : integer;
      Client          : TIdTcpClient;
  end;
  PEmulTable = ^TEmulTable;


  procedure ConstructDispatchList;
  procedure DestructDispatchList;
  function FindUnitInList(ModbusUnit: byte):PEmulTable;

  
var
  DispatchFrm: TDispatchFrm;
  EmulList: TList;


implementation

{$R *.dfm}

uses gnugettext, Main, ModbusTypes;


//
// Dispatch list
//
procedure ConstructDispatchList;
var
  P: PEmulTable;
  Port: integer;
begin
  Port := RedirectIPPort;
  with MainFrm.CsvDB do begin
    if not Active then Exit;
    First; Prior;
    EmulList := TList.Create;
    while not Eof do begin
      New(P);
      EmulList.Add(P);
      // Fill with table info
      P^.ModbusUnit := FieldByName('UNIT').AsInteger;
      P^.Client := TIdTcpClient.Create(nil);
      P^.Client.Port := Port;
      P^.Client.Host := '127.0.0.1';
      Next;
      Inc(Port);
    end;
  end;
  DispatchFrm.TCPServer.Active := True;
end;



procedure DestructDispatchList;
var
  I: integer;
  P: PEmulTable;
begin
  DispatchFrm.TCPServer.Active := False;

  for I := 1 to 10 do begin // Wait a little the end of activities
    Sleep(200);
    Application.ProcessMessages;
  end;
  
  if not Assigned(EmulList) then Exit;

  with EmulList do
    try
      for I := 0 to (Count - 1) do
      begin
        P := Items[I];
        if Assigned(P^.Client) then P^.Client.Free;
        Dispose(P);
      end;
    finally
      ;
    end;

  EmulList.Clear;
  FreeAndNil(EmulList);
end;



function FindUnitInList(ModbusUnit: byte):PEmulTable;
var
  I: integer;
  P: PEmulTable;
begin
  result := nil;

  if not Assigned(EmulList) then Exit;

  with EmulList do
    try
      for I := 0 to (Count - 1) do
      begin
        P := Items[I];
        if P^.ModbusUnit = ModbusUnit then
          result := P;
      end;
    finally
      ;
    end;
end;


//
// Server TCP
//
procedure TDispatchFrm.TCPServerExecute(AContext: TIdContext);
var
  iLen: integer;
  ReceiveBuffer: TModBusRequestBuffer;
  Buffer : TIdBytes;
  P: PEmulTable;
  Thread: TIdThreadWithTask;
  ModbusUnit: byte;
  HostIP: ShortString;
begin
  try
    Thread := TIdYarnOfThread(AContext.Yarn).Thread;
    HostIP := TIdIOHandlerSocket(AContext.Connection.IOHandler).Binding.PeerIP;

    // Init to zero
    FillChar(ReceiveBuffer, SizeOf(ReceiveBuffer), 0);
    SetLength(Buffer, 0);

    // Read the data from the peer connection
    iLen := 6;
    AContext.Connection.Socket.ReadBytes(Buffer, iLen); // Read first bytes with function code
    if iLen > 0 then begin
      Move(Buffer[0], ReceiveBuffer, SizeOf(ReceiveBuffer));
      iLen := Swap(ReceiveBuffer.Header.RecLength);
      SetLength(Buffer, 0);
      AContext.Connection.Socket.ReadBytes(Buffer, iLen); // Read more
      Move(Buffer[0], ReceiveBuffer.Header.UnitID, iLen);
      ModbusUnit := ReceiveBuffer.Header.UnitID;

      LogText := Format(_('[Unit %d] Request detected from %s'), [ModbusUnit, HostIP]);
      Thread.Synchronize(MainFrm.ShowLog);

      P := FindUnitInList(ReceiveBuffer.Header.UnitID);
      if P <> nil then begin

        LogText := Format(_('[Unit %d] Emulator found'), [ModbusUnit]);
        Thread.Synchronize(MainFrm.ShowLog);

        if not P^.Client.Connected then P^.Client.Connect;
        if P^.Client.Connected then begin

          LogText := Format(_('[Unit %d] Emulator connected'), [ModbusUnit]);
          Thread.Synchronize(MainFrm.ShowLog);

          // Send request to routed port
          Buffer := RawToBytes(ReceiveBuffer, Swap(ReceiveBuffer.Header.RecLength) + 6);
          P^.Client.Socket.WriteDirect(Buffer);

          LogText := Format(_('[Unit %d] Request sent to Emulator listening port %d'), [ModbusUnit, P^.Client.Port]);
          Thread.Synchronize(MainFrm.ShowLog);

          // Get answer
          SetLength(Buffer, 0);
          iLen := -1;
          P^.Client.Socket.ReadBytes(Buffer, iLen);
          iLen := Length(Buffer);
          if iLen > 0 then begin

            LogText := Format(_('[Unit %d] Answer received from Emulator listening port %d'), [ModbusUnit, P^.Client.Port]);
            Thread.Synchronize(MainFrm.ShowLog);

            // Send answer to request originate
            AContext.Connection.Socket.WriteDirect(Buffer);

            LogText := Format(_('[Unit %d] Answer sent to %s'), [ModbusUnit, HostIP]);
            Thread.Synchronize(MainFrm.ShowLog);

          end;

        end
        else begin
          LogText := Format(_('[Unit %d] Emulator not connected'), [ModbusUnit]);
          Thread.Synchronize(MainFrm.ShowLog);
        end;

      end;

    end;

  except
    ;
  end;
end;

end.
