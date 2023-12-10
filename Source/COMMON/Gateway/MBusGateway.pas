unit MBusGateway;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls;

const
	Buf_Size    = 260;

type
	TModBusDataBuffer     = array[0..Buf_Size-1] of Byte;

  TModBusFunction = Byte;

  TModBusIPHeader = packed record
    TransactionID: Word;
    ProtocolID: Word;
    RecLength: Word;
  end;

  TModBusIPBuffer = packed record
    Header: TModBusIPHeader;
    MBPData: TModBusDataBuffer;
  end;


  function ModBusCRC16(Buf: TModBusDataBuffer; Len: Word): Word;

implementation



// Compute checksum
function ModBusCRC16(Buf: TModBusDataBuffer; Len: Word): Word;
var
	CS: Word;
  Index, Shift: integer;
begin
	CS := $FFFF;
	for Index := 0 to Len-1 do
	begin
    	CS := CS xor Byte(Buf[Index]);
	  	for Shift := 0 to 7 do
    	begin
  			if (CS and $0001) = $0001 then
  			begin
     			CS := CS shr 1;
        	CS := CS xor $A001;
        end
     		else
     			CS := CS shr 1;
  		end;
	end;
	result := CS;
end;



end.
