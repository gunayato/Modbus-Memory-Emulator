unit Bit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvExControls, JvLabel, StdCtrls, JvExStdCtrls, JvCheckBox, Buttons;

type
  TBitFrm = class(TForm)
    Bit0CB: TJvCheckBox;
    JvLabel2: TJvLabel;
    JvLabel3: TJvLabel;
    Bit1CB: TJvCheckBox;
    Bit2CB: TJvCheckBox;
    Bit3CB: TJvCheckBox;
    Bit4CB: TJvCheckBox;
    Bit5CB: TJvCheckBox;
    Bit6CB: TJvCheckBox;
    Bit7CB: TJvCheckBox;
    Bit8CB: TJvCheckBox;
    Bit9CB: TJvCheckBox;
    Bit10CB: TJvCheckBox;
    Bit11CB: TJvCheckBox;
    Bit12CB: TJvCheckBox;
    Bit13CB: TJvCheckBox;
    Bit14CB: TJvCheckBox;
    Bit15CB: TJvCheckBox;
    SaveBtn: TBitBtn;
    JvLabel1: TJvLabel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function EditWordBinary(Value: word): word;

var
  BitFrm: TBitFrm;

implementation

{$R *.dfm}


uses MyFunctions;


function EditWordBinary(Value: word): word;
begin
  with BitFrm do begin
    // Load check box with 'value' bit weight
    Bit0CB.Checked  := ((Value and 1)    > 0);
    Bit1CB.Checked  := ((Value and 2)    > 0);
    Bit2CB.Checked  := ((Value and 4)    > 0);
    Bit3CB.Checked  := ((Value and 8)    > 0);
    Bit4CB.Checked  := ((Value and 16)   > 0);
    Bit5CB.Checked  := ((Value and 32)   > 0);
    Bit6CB.Checked  := ((Value and 64)   > 0);
    Bit7CB.Checked  := ((Value and 128)  > 0);
    Bit8CB.Checked  := ((Value and 256)  > 0);
    Bit9CB.Checked  := ((Value and 512)  > 0);
    Bit10CB.Checked := ((Value and 1024) > 0);
    Bit11CB.Checked := ((Value and 2048) > 0);
    Bit12CB.Checked := ((Value and 4096) > 0);
    Bit13CB.Checked := ((Value and 8192) > 0);
    Bit14CB.Checked := ((Value and 16384) > 0);
    Bit15CB.Checked := ((Value and 32768) > 0);

    // Show the window
    ShowModal;

    // Get result value
    if modalresult = mrOk then begin
      Value := 0;
      Value := Value or (Word(Bit0CB.Checked)  * 1);
      Value := Value or (Word(Bit1CB.Checked)  * 2);
      Value := Value or (Word(Bit2CB.Checked)  * 4);
      Value := Value or (Word(Bit3CB.Checked)  * 8);
      Value := Value or (Word(Bit4CB.Checked)  * 16);
      Value := Value or (Word(Bit5CB.Checked)  * 32);
      Value := Value or (Word(Bit6CB.Checked)  * 64);
      Value := Value or (Word(Bit7CB.Checked)  * 128);
      Value := Value or (Word(Bit8CB.Checked)  * 256);
      Value := Value or (Word(Bit9CB.Checked)  * 512);
      Value := Value or (Word(Bit10CB.Checked) * 1024);
      Value := Value or (Word(Bit11CB.Checked) * 2048);
      Value := Value or (Word(Bit12CB.Checked) * 4096);
      Value := Value or (Word(Bit13CB.Checked) * 8192);
      Value := Value or (Word(Bit14CB.Checked) * 16384);
      Value := Value or (Word(Bit15CB.Checked) * 32768);
    end;

    result := Value;
  end;
end;

procedure TBitFrm.FormShow(Sender: TObject);
begin
  SetFormPosition(Self);
end;

end.
