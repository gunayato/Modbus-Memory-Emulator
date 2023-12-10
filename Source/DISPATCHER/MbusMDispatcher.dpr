program MbusMDispatcher;

uses
  gnugettext,
  Windows,
  Forms,
  Controls,
  SysUtils,
  Config in 'Config.pas' {ConfigFrm},
  Common in '..\COMMON\Common.pas',
  Main in 'Main.pas' {MainFrm},
  Dispatch in 'Dispatch.pas' {DispatchFrm},
  Gateway in '..\COMMON\Gateway\Gateway.pas' {GatewayFrm};

{$R *.res}

begin
  // Gnugettext
  TextDomain('modbusmdispatcher');
  AddDomainForResourceString('modbusmdispatcher');
  AddDomainForResourceString('delphi');
  AddDomainForResourceString('cport');
  TP_GlobalIgnoreClassProperty(TControl,'HelpKeyword');
  LanguageExt := _('ENG');

  Application.Initialize;
  Application.Title := 'Modbus Memory Dispatcher';
  Application.CreateForm(TMainFrm, MainFrm);
  Application.CreateForm(TConfigFrm, ConfigFrm);
  Application.CreateForm(TDispatchFrm, DispatchFrm);
  Application.CreateForm(TGatewayFrm, GatewayFrm);
    
  Application.Run;
end.
