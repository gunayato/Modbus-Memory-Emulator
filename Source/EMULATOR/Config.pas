unit Config;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, JvExExtCtrls, JvComponent, JvPanel,
  Spin, JvExtComponent, JvExControls, JvSpeedButton;

type
  TConfigFrm = class(TForm)
    JvPanel2: TJvPanel;
    SaveBtn: TBitBtn;
    GroupBox1: TGroupBox;
    IPPortEdit: TSpinEdit;
    Label7: TLabel;
    SlaveAdrEdit: TSpinEdit;
    Label1: TLabel;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    Label3: TLabel;
    NumRegEdit: TSpinEdit;
    NumBitEdit: TSpinEdit;
    GroupBox2: TGroupBox;
    ComPortLabel: TLabel;
    COMSetupBtn: TJvSpeedButton;
    GatewayCB: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure COMSetupBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConfigFrm: TConfigFrm;

implementation

uses gnugettext, Main, Gateway, CPortSetup;


{$R *.dfm}


//
// Form
//
procedure TConfigFrm.FormCreate(Sender: TObject);
begin
  DefaultInstance.TranslateComponent(self);
end;


procedure TConfigFrm.FormShow(Sender: TObject);
begin
  IPPortEdit.Value := TcpIpPort;
  SlaveAdrEdit.Value := ModbusSlave;
  NumRegEdit.Value := NumRegisters;
  NumBitEdit.Value := NumBits;
  GatewayCB.Checked := GatewayEnabled;
  ComPortLabel.Caption := GatewayGetCOMStr;
end;


//
// Save
//
procedure TConfigFrm.SaveBtnClick(Sender: TObject);
begin
  TcpIpPort := IPPortEdit.Value;
  ModbusSlave := SlaveAdrEdit.Value;
  NumRegisters := NumRegEdit.Value;
  NumBits := NumBitEdit.Value;
  GatewayEnabled := GatewayCB.Checked;
end;



//
// Com port setup dialog
//
procedure TConfigFrm.COMSetupBtnClick(Sender: TObject);
begin
  GatewayCOMSetup;
end;



end.
