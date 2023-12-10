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

$Id: ModbusSlave.dpr,v 1.1 2004/01/05 08:45:47 plpolak Exp $

===============================================================================}

program MbusMEmulator;

uses
  gnugettext,
  Windows,
  Forms,
  Controls,
  SysUtils,
  Messages,
  Main in 'Main.pas' {MainFrm},
  Config in 'Config.pas' {ConfigFrm},
  Interpreter in 'Interpreter.pas' {ScriptFrm},
  Common in '..\COMMON\Common.pas',
  Bit in 'Bit.pas' {BitFrm},
  Gateway in '..\COMMON\Gateway\Gateway.pas' {GatewayFrm};

{$R *.res}

const
  PrefsFileName = 'ModbusMEmulator';

var
  I: integer;
  S, IniFName: string;

begin
  // Gnugettext
  TextDomain('modbusmemulator');
  AddDomainForResourceString('modbusmemulator');
  AddDomainForResourceString('delphi');
  AddDomainForResourceString('cport');
  TP_GlobalIgnoreClassProperty(TControl,'HelpKeyword');
  LanguageExt := _('ENG');

  Application.Initialize;
  Application.Title := 'Modbus Memory Emulator';
  Application.CreateForm(TMainFrm, MainFrm);
  Application.CreateForm(TConfigFrm, ConfigFrm);
  Application.CreateForm(TScriptFrm, ScriptFrm);
  Application.CreateForm(TBitFrm, BitFrm);
  Application.CreateForm(TGatewayFrm, GatewayFrm);

  // Cmd line arguments
  with MainFrm do begin
    IniFName := PrefsFileName;
    if Length(ParamStr(1)) > 0 then begin
        MainFrm.FormStorage.Active := False;

        if FileExists(ParamStr(1)) then begin
          OpenDlg.FileName := ParamStr(1);
          OpenMenuClick(nil);
          GatewayEnabled := False;

          if TryStrToInt(ParamStr(2), I) then begin
            ModbusSlave := I;
            RefreshTitle;
            IniFName := Format('%s\%s-%d' ,[ExtractFileDir(ParamStr(1)), PrefsFileName, ModbusSlave]);

            if TryStrToInt(ParamStr(3), I) then begin
              TcpIpPort := I;
              CmdLineTimer.Enabled := True;
            end;

          end;

      end;

    end;
    // Load ini prefs file
    AppIniFile.FileName := IniFName;
    AppIniFile.Reload;
    FormStorage.Active := True;
  end;

  Application.Run;
end.
