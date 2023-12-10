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
    IPGroupBox: TGroupBox;
    Label7: TLabel;
    Label1: TLabel;
    IPPortEdit: TSpinEdit;
    RedirectIPPortEdit: TSpinEdit;
    ComGroupBox: TGroupBox;
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
  IPPortEdit.Value := IPPort;
  RedirectIPPortEdit.Value := RedirectIPPort;
  GatewayCB.Checked := GatewayEnabled;
end;


//
// Save
//
procedure TConfigFrm.SaveBtnClick(Sender: TObject);
begin
  IPPort := IPPortEdit.Value;
  RedirectIPPort := RedirectIPPortEdit.Value;
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
