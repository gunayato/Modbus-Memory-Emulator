{===============================================================================

The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above. If you wish to
allow use of your version of this file only under the terms of the GPL and not
to allow others to use your version of this file under the MPL, indicate your
decision by deleting the provisions above and replace them with the notice and
other provisions required by the GPL. If you do not delete the provisions
above, a recipient may use your version of this file under either the MPL or
the GPL.

$Id: IdModbusServer.pas,v 1.30 2010/05/19 08:26:57 plpolak Exp $

===============================================================================}

{$I ModBusCompiler.inc}

unit IdModBusServer;

interface

uses
  Classes
 ,SysUtils
{$IFDEF DMB_INDY10}
 ,IdContext
 ,IdCustomTCPServer
 ,IdGlobal
{$ELSE}
 ,IdTCPClient
 ,IdTCPServer
{$ENDIF}
 ,ModBusConsts
 ,ModbusTypes
 ,ModbusUtils
 ,SyncObjs;

type
  TModRegisterData = array[0..MaxCoils] of Word;

type
  TModCoilData = array[0..MaxCoils] of ByteBool;

{$IFDEF DMB_INDY10}
type
  TModBusCoilReadEvent = procedure(const Sender: TIdContext;
    const RegNr, Count: Integer; var Data: TModCoilData;
    const RequestBuffer: TModBusRequestBuffer) of object;
  TModBusRegisterReadEvent = procedure(const Sender: TIdContext;
    const RegNr, Count: Integer; var Data: TModRegisterData;
    const RequestBuffer: TModBusRequestBuffer) of object;
  TModBusCoilWriteEvent = procedure(const Sender: TIdContext;
    const RegNr, Count: Integer; const Data: TModCoilData;
    const RequestBuffer: TModBusRequestBuffer) of object;
  TModBusRegisterWriteEvent = procedure(const Sender: TIdContext;
    const RegNr, Count: Integer; const Data: TModRegisterData;
    const RequestBuffer: TModBusRequestBuffer) of object;
  TModBusErrorEvent = procedure(const Sender: TIdContext;
    const FunctionCode: Byte; const ErrorCode: Byte;
    const RequestBuffer: TModBusRequestBuffer) of object;
  TModBusInvalidFunctionEvent = procedure(const Sender: TIdContext;
    const FunctionCode: TModBusFunction;
    const RequestBuffer: TModBusRequestBuffer) of object;
{$ELSE}
type
  TModBusCoilReadEvent = procedure(const Sender: TIdPeerThread;
    const RegNr, Count: Integer; var Data: TModCoilData;
    const RequestBuffer: TModBusRequestBuffer) of object;
  TModBusRegisterReadEvent = procedure(const Sender: TIdPeerThread;
    const RegNr, Count: Integer; var Data: TModRegisterData;
    const RequestBuffer: TModBusRequestBuffer) of object;
  TModBusCoilWriteEvent = procedure(const Sender: TIdPeerThread;
    const RegNr, Count: Integer; const Data: TModCoilData;
    const RequestBuffer: TModBusRequestBuffer) of object;
  TModBusRegisterWriteEvent = procedure(const Sender: TIdPeerThread;
    const RegNr, Count: Integer; const Data: TModRegisterData;
    const RequestBuffer: TModBusRequestBuffer) of object;
  TModBusErrorEvent = procedure(const Sender: TIdPeerThread;
    const FunctionCode: Byte; const ErrorCode: Byte;
    const RequestBuffer: TModBusRequestBuffer) of object;
  TModBusInvalidFunctionEvent = procedure(const Sender: TIdPeerThread;
    const FunctionCode: TModBusFunction;
    const RequestBuffer: TModBusRequestBuffer) of object;
{$ENDIF}

type
{$IFDEF DMB_INDY10}
  TIdModBusServer = class(TIdCustomTCPServer)
{$ELSE}
  TIdModBusServer = class(TIdTCPServer)
{$ENDIF}
  private
    FOneShotConnection: Boolean;
    FLogCriticalSection: TCriticalSection;
    FLogEnabled: Boolean;
    FLogFile: String;
    FLogTimeFormat: String;
    FMaxRegister: Word;
    FMinRegister: Word;
    FMaxCoil: Word;
    FMinCoil: Word;
    FOnError: TModBusErrorEvent;
    FOnInvalidFunction: TModBusInvalidFunctionEvent;
    FOnReadCoils: TModBusCoilReadEvent;
    FOnReadHoldingRegisters: TModBusRegisterReadEvent;
    FOnReadInputBits: TModBusCoilReadEvent;
    FOnReadInputRegisters: TModBusRegisterReadEvent;
    FOnWriteCoils: TModBusCoilWriteEvent;
    FOnWriteRegisters: TModBusRegisterWriteEvent;
    FPause: Boolean;
    FUnitID: Byte;
    function GetVersion: String;
    procedure SetVersion(const Value: String);
    function IsLogTimeFormatStored: Boolean;
    procedure LogByteBuffer(const LogType: String; const PeerIP: String; const ByteBuffer: array of Byte; const Size: Integer);
  {$IFDEF DMB_INDY10}
    procedure InternalReadCoils(const AContext: TIdContext; const RegNr, Count: Integer;
      var Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer);
    procedure InternalReadInputBits(const AContext: TIdContext; const RegNr, Count: Integer;
      var Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer);
    procedure InternalWriteCoils(const AContext: TIdContext; const RegNr, Count: Integer;
      const Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer);
  {$ELSE}
    procedure InternalReadCoils(const Sender: TIdPeerThread; const RegNr, Count: Integer;
      var Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer);
    procedure InternalReadInputBits(const Sender: TIdPeerThread; const RegNr, Count: Integer;
      var Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer);
    procedure InternalWriteCoils(const Sender: TIdPeerThread; const RegNr, Count: Integer;
      const Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer);
  {$ENDIF}
  protected
  {$IFDEF DMB_INDY10}
    procedure InitComponent; override;
  {$ENDIF}
  {$IFDEF DMB_INDY10}
    procedure DoError(const AContext: TIdContext; const FunctionCode: Byte;
      const ErrorCode: Byte; const RequestBuffer: TModBusRequestBuffer); virtual;
    function DoExecute(AContext: TIdContext): Boolean; override;
    procedure DoInvalidFunction(const AContext: TIdContext;
      const FunctionCode: TModBusFunction; const RequestBuffer: TModBusRequestBuffer); virtual;
    procedure DoReadHoldingRegisters(const AContext: TIdContext; const RegNr, Count: Integer;
      var Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer); virtual;
    procedure DoReadInputRegisters(const AContext: TIdContext; const RegNr, Count: Integer;
      var Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer); virtual;
    procedure DoReadCoils(const AContext: TIdContext; const RegNr, Count: Integer;
      var Data: TModCoilData; const RequestBuffer: TModBusRequestBuffer); virtual;
    procedure DoReadInputBits(const AContext: TIdContext; const RegNr, Count: Integer;
      var Data: TModCoilData; const RequestBuffer: TModBusRequestBuffer); virtual;
    procedure DoWriteCoils(const AContext: TIdContext; const RegNr, Count: Integer;
      const Data: TModCoilData; const RequestBuffer: TModBusRequestBuffer); virtual;
    procedure DoWriteRegisters(const AContext: TIdContext; const RegNr, Count: Integer;
      const Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer); virtual;
    procedure LogExceptionBuffer(const AContext: TIdContext; const Buffer: TModBusExceptionBuffer);
    procedure LogRequestBuffer(const AContext: TIdContext; const Buffer: TModBusRequestBuffer; const Size: Integer);
    procedure LogResponseBuffer(const AContext: TIdContext; const Buffer: TModBusResponseBuffer; const Size: Integer);
    procedure ReadCommand(const AContext: TIdContext);
    procedure SendError(const AContext: TIdContext; const ErrorCode: Byte;
      const ReceiveBuffer: TModBusRequestBuffer);
    procedure SendResponse(const AContext: TIdContext; const ReceiveBuffer: TModBusRequestBuffer;
      const Data: TModRegisterData);
  {$ELSE}
    procedure DoError(const Sender: TIdPeerThread; const FunctionCode: Byte;
      const ErrorCode: Byte; const RequestBuffer: TModBusRequestBuffer); virtual;
    function DoExecute(AThread: TIdPeerThread): Boolean; override;
    procedure DoInvalidFunction(const Sender: TIdPeerThread; const FunctionCode: TModBusFunction;
      const RequestBuffer: TModBusRequestBuffer); virtual;
    procedure DoReadHoldingRegisters(const Sender: TIdPeerThread; const RegNr, Count: Integer;
      var Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer); virtual;
    procedure DoReadInputRegisters(const Sender: TIdPeerThread; const RegNr, Count: Integer;
      var Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer); virtual;
    procedure DoReadCoils(const Sender: TIdPeerThread; const RegNr, Count: Integer;
      var Data: TModCoilData; const RequestBuffer: TModBusRequestBuffer); virtual;
    procedure DoReadInputBits(const Sender: TIdPeerThread; const RegNr, Count: Integer;
      var Data: TModCoilData; const RequestBuffer: TModBusRequestBuffer); virtual;
    procedure DoWriteCoils(const Sender: TIdPeerThread; const RegNr, Count: Integer;
      const Data: TModCoilData; const RequestBuffer: TModBusRequestBuffer); virtual;
    procedure DoWriteRegisters(const Sender: TIdPeerThread; const RegNr, Count: Integer;
      const Data: TModRegisterData; const RequestBuffer: TModBusRequestBuffer); virtual;
    procedure LogExceptionBuffer(const AThread: TIdPeerThread; const Buffer: TModBusExceptionBuffer);
    procedure LogRequestBuffer(const AThread: TIdPeerThread; const Buffer: TModBusRequestBuffer; const Size: Integer);
    procedure LogResponseBuffer(const AThread: TIdPeerThread; const Buffer: TModBusResponseBuffer; const Size: Integer);
    procedure ReadCommand(const AThread: TIdPeerThread);
    procedure SendError(const AThread: TIdPeerThread; const ErrorCode: Byte;
      const ReceiveBuffer: TModBusRequestBuffer);
    procedure SendResponse(const AThread: TIdPeerThread; const ReceiveBuffer: TModBusRequestBuffer;
      const Data: TModRegisterData);
  {$ENDIF}
  public
  {$IFNDEF DMB_INDY10}
    constructor Create(AOwner: TComponent); override;
  {$ENDIF}
  { public properties }
    property Pause: Boolean read FPause write FPause;
  published
    property DefaultPort default MB_PORT;
    property LogEnabled: Boolean read FLogEnabled write FLogEnabled default False;
    property LogFile: String read FLogFile write FLogFile;
    property LogTimeFormat: String read FLogTimeFormat write FLogTimeFormat stored IsLogTimeFormatStored;
    property OneShotConnection: Boolean read FOneShotConnection write FOneShotConnection default False;
    property MaxRegister: Word read FMaxRegister write FMaxRegister default $FFFF;
    property MinRegister: Word read FMinRegister write FMinRegister default 1;
    property MaxCoil: Word read FMaxCoil write FMaxCoil default 2000;
    property MinCoil: Word read FMinCoil write FMinCoil default 1;
    property UnitID: Byte read FUnitID write FUnitID default MB_IGNORE_UNITID;
    property Version: String read GetVersion write SetVersion stored False;
  { events }
    property OnError: TModBusErrorEvent read FOnError write FOnError;
    property OnInvalidFunction: TModBusInvalidFunctionEvent read FOnInvalidFunction write FOnInvalidFunction;
    property OnReadCoils: TModBusCoilReadEvent read FOnReadCoils write FOnReadCoils;
    property OnReadHoldingRegisters: TModBusRegisterReadEvent read FOnReadHoldingRegisters write FOnReadHoldingRegisters;
    property OnReadInputBits: TModBusCoilReadEvent read FOnReadInputBits write FOnReadInputBits;
    property OnReadInputRegisters: TModBusRegisterReadEvent read FOnReadInputRegisters write FOnReadInputRegisters;
    property OnWriteCoils: TModBusCoilWriteEvent read FOnWriteCoils write FOnWriteCoils;
    property OnWriteRegisters: TModBusRegisterWriteEvent read FOnWriteRegisters write FOnWriteRegisters;
  end; { TIdModBusServer }


implementation

uses
  Math, Windows;

{ TIdModBusServer }

{$IFDEF DMB_INDY10}
procedure TIdModBusServer.InitComponent;
{$ELSE}
constructor TIdModBusServer.Create(AOwner: TComponent);
{$ENDIF}
begin
{$IFDEF DMB_INDY10}
  inherited;
{$ELSE}
  inherited Create(AOwner);
{$ENDIF}
  DefaultPort := MB_PORT;
  FLogCriticalSection := SyncObjs.TCriticalSection.Create;
  FLogEnabled := False;
  FLogFile := '';
  FLogTimeFormat := DefaultLogTimeFormat;
  FMaxRegister := $FFFF;
  FMinRegister := 1;
  FMaxCoil := 2000;
  FMinCoil := 1;
  FOneShotConnection := False;
  FOnError := nil;
  FOnInvalidFunction := nil;
  FOnReadCoils := nil;
  FOnReadHoldingRegisters := nil;
  FOnReadInputBits := nil;
  FOnReadInputRegisters := nil;
  FOnWriteCoils := nil;
  FOnWriteRegisters := nil;
  FPause := False;
  FUnitID := MB_IGNORE_UNITID;
end;


procedure TIdModBusServer.LogByteBuffer(const LogType: String;
  const PeerIP: String; const ByteBuffer: array of Byte; const Size: Integer);
var
  F: TextFile;
begin
  if FLogEnabled and (FLogFile <> '') then
  begin
    FLogCriticalSection.Enter;
    try
      AssignFile(F, FLogFile);
      if FileExists(FLogFile) then
        Append(F)
      else
        Rewrite(F);
      try
        WriteLn(F, FormatDateTime(FLogTimeFormat, Now)
                  ,'; ', LogType
                  ,'; ', PeerIP
                  ,'; ', IntToStr(Size)
                  ,'; ', BufferToHex(ByteBuffer));
      finally
        CloseFile(F);
      end;
    finally
      FLogCriticalSection.Leave;
    end;
  end;
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.InternalReadCoils(const AContext: TIdContext;
  const RegNr, Count: Integer; var Data: TModRegisterData;
    const RequestBuffer: TModBusRequestBuffer);
{$ELSE}
procedure TIdModBusServer.InternalReadCoils(const Sender: TIdPeerThread;
  const RegNr, Count: Integer; var Data: TModRegisterData;
    const RequestBuffer: TModBusRequestBuffer);
{$ENDIF}
var
  CoilData: TModCoilData;
  i: Integer;
begin
  FillChar(CoilData, SizeOf(CoilData), 0);
{$IFDEF DMB_INDY10}
  DoReadCoils(AContext, RegNr, Count, CoilData, RequestBuffer);
{$ELSE}
  DoReadCoils(Sender, RegNr, Count, CoilData, RequestBuffer);
{$ENDIF}
  for i := 0 to (Count - 1) do
  begin
    if CoilData[i] then
      Data[i] := 1;
  end;
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.InternalReadInputBits(const AContext: TIdContext;
  const RegNr, Count: Integer; var Data: TModRegisterData;
  const RequestBuffer: TModBusRequestBuffer);
{$ELSE}
procedure TIdModBusServer.InternalReadInputBits(const Sender: TIdPeerThread;
  const RegNr, Count: Integer; var Data: TModRegisterData;
  const RequestBuffer: TModBusRequestBuffer);
{$ENDIF}
var
  CoilData: TModCoilData;
  i: Integer;
begin
  FillChar(CoilData, SizeOf(CoilData), 0);
{$IFDEF DMB_INDY10}
  DoReadInputBits(AContext, RegNr, Count, CoilData, RequestBuffer);
{$ELSE}
  DoReadInputBits(Sender, RegNr, Count, CoilData, RequestBuffer);
{$ENDIF}
  for i := 0 to (Count - 1) do
  begin
    if CoilData[i] then
      Data[i] := 1;
  end;

end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.InternalWriteCoils(const AContext: TIdContext;
  const RegNr, Count: Integer; const Data: TModRegisterData;
  const RequestBuffer: TModBusRequestBuffer);
{$ELSE}
procedure TIdModBusServer.InternalWriteCoils(const Sender: TIdPeerThread;
  const RegNr, Count: Integer; const Data: TModRegisterData;
  const RequestBuffer: TModBusRequestBuffer);
{$ENDIF}
var
  CoilData: TModCoilData;
  i: Integer;
begin
  FillChar(CoilData, SizeOf(CoilData), 0);
  for i := 0 to (Count - 1) do
    CoilData[i] := (Data[i] = 1);
{$IFDEF DMB_INDY10}
  DoWriteCoils(AContext, RegNr, Count, CoilData, RequestBuffer);
{$ELSE}
  DoWriteCoils(Sender, RegNr, Count, CoilData, RequestBuffer);
{$ENDIF}
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.LogExceptionBuffer(const AContext: TIdContext;
  const Buffer: TModBusExceptionBuffer);
{$ELSE}
procedure TIdModBusServer.LogExceptionBuffer(const AThread: TIdPeerThread;
  const Buffer: TModBusExceptionBuffer);
{$ENDIF}
var
  PeerIP: String;
  ByteBuffer: array of Byte;
begin
{$IFDEF DMB_INDY10}
  PeerIP := AContext.Connection.Socket.Binding.PeerIP;
{$ELSE}
  PeerIP := AThread.Connection.Socket.Binding.PeerIP;
{$ENDIF}
  SetLength(ByteBuffer, SizeOf(Buffer));
  Move(Buffer, ByteBuffer[0], SizeOf(Buffer));
  LogByteBuffer('excp', PeerIP, ByteBuffer, SizeOf(Buffer));
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.LogRequestBuffer(const AContext: TIdContext;
  const Buffer: TModBusRequestBuffer; const Size: Integer);
{$ELSE}
procedure TIdModBusServer.LogRequestBuffer(const AThread: TIdPeerThread;
  const Buffer: TModBusRequestBuffer; const Size: Integer);
{$ENDIF}
var
  PeerIP: String;
  ByteBuffer: array of Byte;
begin
{$IFDEF DMB_INDY10}
  PeerIP := AContext.Connection.Socket.Binding.PeerIP;
{$ELSE}
  PeerIP := AThread.Connection.Socket.Binding.PeerIP;
{$ENDIF}
  SetLength(ByteBuffer, SizeOf(Buffer));
  Move(Buffer, ByteBuffer[0], SizeOf(Buffer));
  LogByteBuffer('recv', PeerIP, ByteBuffer, Size);
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.LogResponseBuffer(const AContext: TIdContext;
  const Buffer: TModBusResponseBuffer; const Size: Integer);
{$ELSE}
procedure TIdModBusServer.LogResponseBuffer(const AThread: TIdPeerThread;
  const Buffer: TModBusResponseBuffer; const Size: Integer);
{$ENDIF}
var
  PeerIP: String;
  ByteBuffer: array of Byte;
begin
{$IFDEF DMB_INDY10}
  PeerIP := AContext.Connection.Socket.Binding.PeerIP;
{$ELSE}
  PeerIP := AThread.Connection.Socket.Binding.PeerIP;
{$ENDIF}
  SetLength(ByteBuffer, SizeOf(Buffer));
  Move(Buffer, ByteBuffer[0], SizeOf(Buffer));
  LogByteBuffer('sent', PeerIP, ByteBuffer, Size);
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.ReadCommand(const AContext: TIdContext);
{$ELSE}
procedure TIdModBusServer.ReadCommand(const AThread: TIdPeerThread);
{$ENDIF}

  function GetRegNr(const RegNr: Integer): Integer;
  begin
    Result := RegNr;
    if (RegNr < 0) then
      Result := Result + MAXWORD
    else if (RegNr > MAXWORD) then
      Result := RegNr - (MAXWORD + 1);
  end; { GetRegNr }
  
var
  iCount: Integer;
  iRegNr: Integer;
  ErrorCode: Byte;
  ReceiveBuffer: TModBusRequestBuffer;
  Data: TModRegisterData;
{$IFDEF DMB_INDY10}
  Buffer: TIdBytes;
{$ENDIF}
begin
{ Initialize all register data to 0 }
  FillChar(Data[0], SizeOf(Data), 0);
  FillChar(ReceiveBuffer, SizeOf(ReceiveBuffer), 0);
{ Read the data from the peer connection }
{$IFDEF DMB_INDY10}
{ Ensure receiving databuffer is completely empty, and filled with zeros }
  SetLength(Buffer, SizeOf(ReceiveBuffer));
  FillChar(Buffer[0], SizeOf(ReceiveBuffer), 0);
{ Wait max. 250 msecs. for available data }
  AContext.Connection.IOHandler.CheckForDataOnSource(250);
  if not AContext.Connection.IOHandler.InputBufferIsEmpty then
  begin
    AContext.Connection.IOHandler.InputBuffer.ExtractToBytes(Buffer, -1, False, -1);
    iCount := Length(Buffer);
    if (iCount > 0) then
    begin
      Move(Buffer[0], ReceiveBuffer, Min(iCount, SizeOf(ReceiveBuffer)));
      if FLogEnabled then
        LogRequestBuffer(AContext, ReceiveBuffer, iCount);
    end
    else
      Exit;
  end
  else
    Exit;
{$ELSE}
  iCount := AThread.Connection.Socket.Recv(ReceiveBuffer, SizeOf(ReceiveBuffer));
  if (iCount > 0) then
  begin
    if FLogEnabled then
      LogRequestBuffer(AThread, ReceiveBuffer, iCount);
  end
  else
    Exit;
{$ENDIF}
{ Process the data }
  if ((FUnitID <> MB_IGNORE_UNITID) and (ReceiveBuffer.Header.UnitID <> FUnitID)) or
     (ReceiveBuffer.Header.ProtocolID <> MB_PROTOCOL)
  then
  begin
  // When listening for a specific UnitID, only except data for that ID
  {$IFDEF DMB_INDY10}
    SendError(AContext, mbeServerFailure, ReceiveBuffer);
  {$ELSE}
    SendError(AThread, mbeServerFailure, ReceiveBuffer);
  {$ENDIF}
  end
  else if ((Byte(ReceiveBuffer.FunctionCode) and $80) <> 0) then
  begin
    ErrorCode := Integer(ReceiveBuffer.MBPData[0]);
  {$IFDEF DMB_INDY10}
    DoError(AContext, ReceiveBuffer.FunctionCode and not $80, ErrorCode, ReceiveBuffer);
  {$ELSE}
    DoError(AThread, ReceiveBuffer.FunctionCode and not $80, ErrorCode, ReceiveBuffer);
  {$ENDIF}
  end
  else
  begin
    ErrorCode := 0;
    case ReceiveBuffer.FunctionCode of
      mbfReadCoils,
      mbfReadInputBits:
        begin
          iRegNr := GetRegNr(Swap(Word((@ReceiveBuffer.MBPData[0])^)) + 1);
          iCount := Swap(Word((@ReceiveBuffer.MBPData[2])^));
          if (iRegNr < FMinCoil) or ((iRegNr + iCount) > FMaxCoil) then ErrorCode := mbeIllegalRegister;
          if (iCount > MaxCoils) then ErrorCode := mbeIllegalDataValue;
          if ErrorCode > 0 then
          {$IFDEF DMB_INDY10}
            SendError(AContext, ErrorCode, ReceiveBuffer)
          {$ELSE}
            SendError(AThread, ErrorCode, ReceiveBuffer)
          {$ENDIF}
          else
          begin
          { Signal the user that data is needed }
          {$IFDEF DMB_INDY10}
            if (ReceiveBuffer.FunctionCode = mbfReadCoils) then
              InternalReadCoils(AContext, iRegNr, iCount, Data, ReceiveBuffer)
            else
              InternalReadInputBits(AContext, iRegNr, iCount, Data, ReceiveBuffer);
            SendResponse(AContext, ReceiveBuffer, Data);
          {$ELSE}
            if (ReceiveBuffer.FunctionCode = mbfReadCoils) then
              InternalReadCoils(AThread, iRegNr, iCount, Data, ReceiveBuffer)
            else
              InternalReadInputBits(AThread, iRegNr, iCount, Data, ReceiveBuffer);
            SendResponse(AThread, ReceiveBuffer, Data);
          {$ENDIF}
          end;
        end;
      mbfReadInputRegs,
      mbfReadHoldingRegs:
        begin
          iRegNr := GetRegNr(Swap(Word((@ReceiveBuffer.MBPData[0])^)) + 1);
          iCount := Swap(Word((@ReceiveBuffer.MBPData[2])^));
          if (iRegNr < FMinRegister) or ((iRegNr + iCount) > FMaxRegister) then ErrorCode := mbeIllegalRegister;
          if (iCount > MaxBlockLength) then ErrorCode := mbeIllegalDataValue;
          if ErrorCode > 0 then
          {$IFDEF DMB_INDY10}
            SendError(AContext, ErrorCode, ReceiveBuffer)
          {$ELSE}
            SendError(AThread, ErrorCode, ReceiveBuffer)
          {$ENDIF}
          else
          begin
          { Signal the user that data is needed }
          {$IFDEF DMB_INDY10}
            if (ReceiveBuffer.FunctionCode = mbfReadInputRegs) then
              DoReadInputRegisters(AContext, iRegNr, iCount, Data, ReceiveBuffer)
            else
              DoReadHoldingRegisters(AContext, iRegNr, iCount, Data, ReceiveBuffer);
            SendResponse(AContext, ReceiveBuffer, Data);
          {$ELSE}
            if (ReceiveBuffer.FunctionCode = mbfReadInputRegs) then
              DoReadInputRegisters(AThread, iRegNr, iCount, Data, ReceiveBuffer)
            else
              DoReadHoldingRegisters(AThread, iRegNr, iCount, Data, ReceiveBuffer);
            SendResponse(AThread, ReceiveBuffer, Data);
          {$ENDIF}
          end;
        end;
      mbfWriteOneReg:
        begin
        { Get the register number }
          iRegNr := GetRegNr(Swap(Word((@ReceiveBuffer.MBPData[0])^)) + 1);
        { Get the register value }
          Data[0] := Swap(Word((@ReceiveBuffer.MBPData[2])^));
        { This function always writes one register }
          iCount := 1;

          if ((iRegNr < FMinRegister) or ((iRegNr + iCount) > FMaxRegister)) then
          {$IFDEF DMB_INDY10}
            SendError(AContext, mbeIllegalRegister, ReceiveBuffer)
          {$ELSE}
            SendError(AThread, mbeIllegalRegister, ReceiveBuffer)
          {$ENDIF}
          else
          begin
          { Send back the response to the master }
          {$IFDEF DMB_INDY10}
            SendResponse(AContext, ReceiveBuffer, Data);
            DoWriteRegisters(AContext, iRegNr, iCount, Data, ReceiveBuffer);
          {$ELSE}
            SendResponse(AThread, ReceiveBuffer, Data);
            DoWriteRegisters(AThread, iRegNr, iCount, Data, ReceiveBuffer);
          {$ENDIF}
          end;
        end;
      mbfWriteRegs:
        begin
          iRegNr := GetRegNr(Swap(Word((@ReceiveBuffer.MBPData[0])^)) + 1);
          iCount := Swap(Word((@ReceiveBuffer.MBPData[2])^));
          if (iRegNr < FMinRegister) or ((iRegNr + iCount) > FMaxRegister) then ErrorCode := mbeIllegalRegister;
          if (iCount > MaxBlockLength) then ErrorCode := mbeIllegalDataValue;
          if ErrorCode > 0 then
          {$IFDEF DMB_INDY10}
            SendError(AContext, ErrorCode, ReceiveBuffer)
          {$ELSE}
            SendError(AThread, ErrorCode, ReceiveBuffer)
          {$ENDIF}
          else
          begin
          { Decode the contents of the Registers }
            GetRegistersFromBuffer(@ReceiveBuffer.MbpData[5], iCount, Data);
          { Send back the response to the master }
          {$IFDEF DMB_INDY10}
            SendResponse(AContext, ReceiveBuffer, Data);
            DoWriteRegisters(AContext, iRegNr, iCount, Data, ReceiveBuffer);
          {$ELSE}
            SendResponse(AThread, ReceiveBuffer, Data);
            DoWriteRegisters(AThread, iRegNr, iCount, Data, ReceiveBuffer);
          {$ENDIF}
          end;
        end;
      mbfWriteOneCoil:
        begin
          iRegNr := GetRegNr(Swap(Word((@ReceiveBuffer.MBPData[0])^)) + 1);
          iCount := 1;
          if ((iRegNr < FMinCoil) or ((iRegNr + iCount) > FMaxCoil)) then
          {$IFDEF DMB_INDY10}
            SendError(AContext, mbeIllegalRegister, ReceiveBuffer)
          {$ELSE}
            SendError(AThread, mbeIllegalRegister, ReceiveBuffer)
          {$ENDIF}
          else
          begin
          { Decode the contents of the Registers }
            GetCoilsFromBuffer(@ReceiveBuffer.MbpData[2], iCount, Data);
          { Send back the response to the master }
          {$IFDEF DMB_INDY10}
            SendResponse(AContext, ReceiveBuffer, Data);
            InternalWriteCoils(AContext, iRegNr, iCount, Data, ReceiveBuffer);
          {$ELSE}
            SendResponse(AThread, ReceiveBuffer, Data);
            InternalWriteCoils(AThread, iRegNr, iCount, Data, ReceiveBuffer);
          {$ENDIF}
          end;
        end;
      mbfWriteCoils:
        begin
          iRegNr := GetRegNr(Swap(Word((@ReceiveBuffer.MBPData[0])^)) + 1);
          iCount := Swap(Word((@ReceiveBuffer.MBPData[2])^));
          if (iRegNr < FMinCoil) or ((iRegNr + iCount) > FMaxCoil) then ErrorCode := mbeIllegalRegister;
          if (iCount > MaxCoils) then ErrorCode := mbeIllegalDataValue;
          if ErrorCode > 0 then
          {$IFDEF DMB_INDY10}
            SendError(AContext, ErrorCode, ReceiveBuffer)
          {$ELSE}
            SendError(AThread, ErrorCode, ReceiveBuffer)
          {$ENDIF}
          else
          begin
          { Decode the contents of the Registers }
            GetCoilsFromBuffer(@ReceiveBuffer.MbpData[5], iCount, Data);
          { Send back the response to the master }
          {$IFDEF DMB_INDY10}
            SendResponse(AContext, ReceiveBuffer, Data);
            InternalWriteCoils(AContext, iRegNr, iCount, Data, ReceiveBuffer);
          {$ELSE}
            SendResponse(AThread, ReceiveBuffer, Data);
            InternalWriteCoils(AThread, iRegNr, iCount, Data, ReceiveBuffer);
          {$ENDIF}
          end;
        end;
    else
      if (ReceiveBuffer.FunctionCode <> 0) then
      begin
      { Illegal or unsupported function code }
      {$IFDEF DMB_INDY10}
        SendError(AContext, mbeIllegalFunction, ReceiveBuffer);
        DoInvalidFunction(AContext, ReceiveBuffer.FunctionCode, ReceiveBuffer);
      {$ELSE}
        SendError(AThread, mbeIllegalFunction, ReceiveBuffer);
        DoInvalidFunction(AThread, ReceiveBuffer.FunctionCode, ReceiveBuffer);
      {$ENDIF}
      end;
    end;
  end;
{ If needed: the server terminates the connection, after the request has been handled }
  if FOneShotConnection then
  {$IFDEF DMB_INDY10}
    AContext.Connection.Disconnect;
  {$ELSE}
    AThread.Connection.Disconnect;
  {$ENDIF}
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.DoError(const AContext: TIdContext;
  const FunctionCode: Byte; const ErrorCode: Byte; const RequestBuffer: TModBusRequestBuffer);
{$ELSE}
procedure TIdModBusServer.DoError(const Sender: TIdPeerThread;
  const FunctionCode: Byte; const ErrorCode: Byte; const RequestBuffer: TModBusRequestBuffer);
{$ENDIF}
begin
  if Assigned(FOnError) then
  {$IFDEF DMB_INDY10}
    FOnError(AContext, FunctionCode, ErrorCode, RequestBuffer);
  {$ELSE}
    FOnError(Sender, FunctionCode, ErrorCode, RequestBuffer);
  {$ENDIF}
end;


{$IFDEF DMB_INDY10}
function TIdModBusServer.DoExecute(AContext: TIdContext): Boolean;
{$ELSE}
function TIdModBusServer.DoExecute(AThread: TIdPeerThread): Boolean;
{$ENDIF}
begin
  Result := False;
  if not FPause then
  begin
  {$IFDEF DMB_INDY10}
    ReadCommand(AContext);
    Result := inherited DoExecute(AContext);
  {$ELSE}
    ReadCommand(AThread);
    Result := inherited DoExecute(AThread);
  {$ENDIF}
  end;
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.DoInvalidFunction(const AContext: TIdContext;
  const FunctionCode: TModBusFunction; const RequestBuffer: TModBusRequestBuffer);
{$ELSE}
procedure TIdModBusServer.DoInvalidFunction(const Sender: TIdPeerThread;
  const FunctionCode: TModBusFunction; const RequestBuffer: TModBusRequestBuffer);
{$ENDIF}
begin
  if Assigned(FOnInvalidFunction) then
  {$IFDEF DMB_INDY10}
    FOnInvalidFunction(AContext, FunctionCode, RequestBuffer);
  {$ELSE}
    FOnInvalidFunction(Sender, FunctionCode, RequestBuffer);
  {$ENDIF}
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.DoReadCoils(const AContext: TIdContext;
  const RegNr, Count: Integer; var Data: TModCoilData;
  const RequestBuffer: TModBusRequestBuffer);
{$ELSE}
procedure TIdModBusServer.DoReadCoils(const Sender: TIdPeerThread;
  const RegNr, Count: Integer; var Data: TModCoilData;
  const RequestBuffer: TModBusRequestBuffer);
{$ENDIF}
begin
  if Assigned(FOnReadCoils) then
  {$IFDEF DMB_INDY10}
    FOnReadCoils(AContext, RegNr, Count, Data, RequestBuffer);
  {$ELSE}
    FOnReadCoils(Sender, RegNr, Count, Data, RequestBuffer);
  {$ENDIF}
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.DoReadInputBits(const AContext: TIdContext;
  const RegNr, Count: Integer; var Data: TModCoilData;
  const RequestBuffer: TModBusRequestBuffer);
{$ELSE}
procedure TIdModBusServer.DoReadInputBits(const Sender: TIdPeerThread;
  const RegNr, Count: Integer; var Data: TModCoilData;
  const RequestBuffer: TModBusRequestBuffer);
{$ENDIF}
begin
  if Assigned(FOnReadInputBits) then
  {$IFDEF DMB_INDY10}
    FOnReadInputBits(AContext, RegNr, Count, Data, RequestBuffer);
  {$ELSE}
    FOnReadInputBits(Sender, RegNr, Count, Data, RequestBuffer);
  {$ENDIF}
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.DoReadHoldingRegisters(const AContext: TIdContext;
  const RegNr, Count: Integer; var Data: TModRegisterData;
  const RequestBuffer: TModBusRequestBuffer);
{$ELSE}
procedure TIdModBusServer.DoReadHoldingRegisters(const Sender: TIdPeerThread;
  const RegNr, Count: Integer; var Data: TModRegisterData;
  const RequestBuffer: TModBusRequestBuffer);
{$ENDIF}
begin
  if Assigned(FOnReadHoldingRegisters) then
  {$IFDEF DMB_INDY10}
    FOnReadHoldingRegisters(AContext, RegNr, Count, Data, RequestBuffer);
  {$ELSE}
    FOnReadHoldingRegisters(Sender, RegNr, Count, Data, RequestBuffer);
  {$ENDIF}
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.DoReadInputRegisters(const AContext: TIdContext;
  const RegNr, Count: Integer; var Data: TModRegisterData;
  const RequestBuffer: TModBusRequestBuffer);
{$ELSE}
procedure TIdModBusServer.DoReadInputRegisters(const Sender: TIdPeerThread;
  const RegNr, Count: Integer; var Data: TModRegisterData;
  const RequestBuffer: TModBusRequestBuffer);
{$ENDIF}
begin
  if Assigned(FOnReadInputRegisters) then
  {$IFDEF DMB_INDY10}
    FOnReadInputRegisters(AContext, RegNr, Count, Data, RequestBuffer);
  {$ELSE}
    FOnReadInputRegisters(Sender, RegNr, Count, Data, RequestBuffer);
  {$ENDIF}
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.DoWriteCoils(const AContext: TIdContext;
  const RegNr, Count: Integer; const Data: TModCoilData;
  const RequestBuffer: TModBusRequestBuffer);
{$ELSE}
procedure TIdModBusServer.DoWriteCoils(const Sender: TIdPeerThread;
  const RegNr, Count: Integer; const Data: TModCoilData;
  const RequestBuffer: TModBusRequestBuffer);
{$ENDIF}
begin
  if Assigned(FOnWriteCoils) then
  {$IFDEF DMB_INDY10}
    FOnWriteCoils(AContext, RegNr, Count, Data, RequestBuffer);
  {$ELSE}
    FOnWriteCoils(Sender, RegNr, Count, Data, RequestBuffer);
  {$ENDIF}
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.DoWriteRegisters(const AContext: TIdContext;
  const RegNr, Count: Integer; const Data: TModRegisterData;
  const RequestBuffer: TModBusRequestBuffer);
{$ELSE}
procedure TIdModBusServer.DoWriteRegisters(const Sender: TIdPeerThread;
const RegNr, Count: Integer; const Data: TModRegisterData;
const RequestBuffer: TModBusRequestBuffer);
{$ENDIF}
begin
  if Assigned(FOnWriteRegisters) then
  {$IFDEF DMB_INDY10}
    FOnWriteRegisters(AContext, RegNr, Count, Data, RequestBuffer);
  {$ELSE}
    FOnWriteRegisters(Sender, RegNr, Count, Data, RequestBuffer);
  {$ENDIF}
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.SendError(const AContext: TIdContext;
  const ErrorCode: Byte; const ReceiveBuffer: TModBusRequestBuffer);
{$ELSE}
procedure TIdModBusServer.SendError(const AThread: TIdPeerThread;
  const ErrorCode: Byte; const ReceiveBuffer: TModBusRequestBuffer);
{$ENDIF}
var
  SendBuffer: TModBusExceptionBuffer;
{$IFDEF DMB_INDY10}
  Buffer: TIdBytes;
{$ENDIF}
begin
  if Active then
  begin
    SendBuffer.Header := ReceiveBuffer.Header;
    SendBuffer.ExceptionFunction := ReceiveBuffer.FunctionCode or $80;
    SendBuffer.ExceptionCode := ErrorCode;
    SendBuffer.Header.RecLength := Swap(3);

  {$IFDEF DMB_INDY10}
    Buffer := RawToBytes(SendBuffer, SizeOf(SendBuffer));
    AContext.Connection.Socket.WriteDirect(Buffer);
    if FLogEnabled then
      LogExceptionBuffer(AContext, SendBuffer);
  {$ELSE}
    AThread.Connection.Socket.Send(SendBuffer, SizeOf(SendBuffer));
    if FLogEnabled then
      LogExceptionBuffer(AThread, SendBuffer);
  {$ENDIF}
  end;
end;


{$IFDEF DMB_INDY10}
procedure TIdModBusServer.SendResponse(const AContext: TIdContext;
  const ReceiveBuffer: TModBusRequestBuffer; const Data: TModRegisterData);
{$ELSE}
procedure TIdModBusServer.SendResponse(const AThread: TIdPeerThread;
  const ReceiveBuffer: TModBusRequestBuffer; const Data: TModRegisterData);
{$ENDIF}
var
  SendBuffer: TModBusResponseBuffer;
  L: Integer;
  iBytesToWrite: Byte;
{$IFDEF DMB_INDY10}
  Buffer: TIdBytes;
{$ENDIF}
begin
  if Active then
  begin
    FillChar(SendBuffer, SizeOf(SendBuffer), 0);
    SendBuffer.Header.TransactionID := ReceiveBuffer.Header.TransactionID;
    SendBuffer.Header.ProtocolID := ReceiveBuffer.Header.ProtocolID;
    SendBuffer.Header.UnitID := ReceiveBuffer.Header.UnitID;
    SendBuffer.FunctionCode := ReceiveBuffer.FunctionCode;
    SendBuffer.Header.RecLength := Swap(0);

    case ReceiveBuffer.FunctionCode of
      mbfReadCoils,
      mbfReadInputBits:
        begin
          L := Swap(Word((@ReceiveBuffer.MBPData[2])^));
          if (L <= MaxCoils) then
          begin
            iBytesToWrite := Byte(L div 8) ;
            if (L mod 8) > 0 then Inc(iBytesToWrite);
            SendBuffer.MBPData[0] := iBytesToWrite;
            PutCoilsIntoBuffer(@SendBuffer.MBPData[1], L, Data);
            SendBuffer.Header.RecLength := Swap(3 + SendBuffer.MBPData[0]);
          end;
        end;
      mbfReadInputRegs,
      mbfReadHoldingRegs:
        begin
          L := Swap(Word((@ReceiveBuffer.MBPData[2])^));
          if (L <= MaxBlockLength) then
          begin
            SendBuffer.MBPData[0] := Byte(L shl 1);
            PutRegistersIntoBuffer(@SendBuffer.MBPData[1], L, Data);
            SendBuffer.Header.RecLength := Swap(3 + SendBuffer.MBPData[0]);
          end;
        end;
    else
      begin
        SendBuffer.MBPData[0] := ReceiveBuffer.MBPData[0];
        SendBuffer.MBPData[1] := ReceiveBuffer.MBPData[1];
        SendBuffer.MBPData[2] := ReceiveBuffer.MBPData[2];
        SendBuffer.MBPData[3] := ReceiveBuffer.MBPData[3];
        SendBuffer.Header.RecLength := Swap(6);
      end;
    end;
  {$IFDEF DMB_INDY10}
    Buffer := RawToBytes(SendBuffer, Swap(SendBuffer.Header.RecLength) + 6);
    AContext.Connection.Socket.WriteDirect(Buffer);
    if FLogEnabled then
      LogResponseBuffer(AContext, SendBuffer, Swap(SendBuffer.Header.RecLength) + 6);
  {$ELSE}
    AThread.Connection.Socket.Send(SendBuffer, Swap(SendBuffer.Header.RecLength) + 6);
    if FLogEnabled then
      LogResponseBuffer(AThread, SendBuffer, Swap(SendBuffer.Header.RecLength) + 6);
  {$ENDIF}
  end;
end;


function TIdModBusServer.GetVersion: String;
begin
  Result := DMB_VERSION;
end;


function TIdModBusServer.IsLogTimeFormatStored: Boolean;
begin
  Result := (FLogTimeFormat <> DefaultLogTimeFormat);
end;


procedure TIdModBusServer.SetVersion(const Value: String);
begin
{ This intentionally is a readonly property }
end;


end.

