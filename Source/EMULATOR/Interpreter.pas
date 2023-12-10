{$I jvcl.inc}

unit Interpreter;

interface


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, 
  JvInterpreter, JvInterpreterFm, JvEditor, JvHLParser, JvHLEditor,
  Db, DBTables, Grids, DBGrids, Variants, JvThreadTimer,
  JvComponentBase, Buttons, JvExExtCtrls, JvComponent, JvPanel,
  JvExControls, JvEditorCommon, JvExtComponent, JvFormPlacement;


type
  TScriptFrm = class(TForm)
    InterpreterProgram: TJvInterpreterFm;
    SourceEditor: TJvHLEditor;
    StatusPanel: TPanel;
    BottomPanel: TJvPanel;
    SaveBtn: TBitBtn;
    CaretLabel: TLabel;
    ScriptEnableCB: TCheckBox;
    FormStorage: TJvFormStorage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CompileClick(Sender: TObject);
    procedure InterpreterProgramStatement(Sender: TObject);
    procedure InterpreterProgramGetValue(Sender: TObject;
      Identifier: String; var Value: Variant; Args: TJvInterpreterArgs; var Done: Boolean);
    procedure FormShow(Sender: TObject);
    procedure SourceEditorChangeStatus(Sender: TObject);
    procedure InterpreterProgramSetValue(Sender: TObject;
      Identifier: String; const Value: Variant; Args: TJvInterpreterArgs;
      var Done: Boolean);
  private
    { Private declarations }
    Parser : TJvIParser;
    CurFileName: TFileName;
  public
    { Public declarations }
    V: Variant;
    procedure RunScript;
  end;

  TVarType = Word;

var
  ScriptFrm: TScriptFrm;
  ScriptSpeed: integer;
  ScriptSave: string;

implementation

uses gnugettext, JclFileUtils, JclStrings, JvJCLUtils, JvJVCLUtils,
     JvInterpreter_all, JvInterpreter_SysUtils, Main;

{$R *.DFM}


procedure EZeroDivide_Create(var Value: Variant; Args: TJvInterpreterArgs);
begin
  Value := O2V(EZeroDivide.Create(Args.Values[0]));
end;

//
// Form create/destroys
//
procedure TScriptFrm.FormCreate(Sender: TObject);
begin
  DefaultInstance.TranslateComponent(self);

  InterpreterProgram.Adapter.AddGet(EZeroDivide, 'Create', EZeroDivide_Create, 1, [varEmpty], varEmpty);
  InterpreterProgram.Pas := SourceEditor.Lines;
  DecimalSeparator := '.';
  Parser := TJvIParser.Create;

  ScriptSave := SourceEditor.Lines.Text;
end;

procedure TScriptFrm.FormDestroy(Sender: TObject);
begin
  Parser.Free;
end;

procedure TScriptFrm.FormShow(Sender: TObject);
begin
  SourceEditor.Lines.Text := InterpreterProgram.Source;
  ScriptEnableCB.Checked := ScriptEnabled;
end;


//
// Compile script
//
procedure TScriptFrm.CompileClick(Sender: TObject);
const
  Bool : array [boolean] of string = ('False', 'True');
var
  T1: longword;
  obj:TObject;
  vtype:TVarType;
  res: smallint;
begin
  InterpreterProgram.Pas := SourceEditor.Lines;
  if InterpreterProgram.Pas.Count <= 1 then Exit;
  
  CurFileName := '';
  T1 := GetTickCount;

  try
    try

      res := HiWord(GetKeyState(VK_LSHIFT));
      if res <> 0 then begin
        InterpreterProgram.Run;
        modalResult := mrNone;
      end
      else
        InterpreterProgram.Compile;
      StatusPanel.Caption := 'ms: ' + IntToStr(GetTickCount - T1);

      vtype := VarType(InterpreterProgram.VResult);
      if vtype = varBoolean then
        StatusPanel.Caption := Bool[boolean(InterpreterProgram.VResult)]
      else if (vtype = varString) or (vtype = varInteger) or (vtype = varDouble) then
        StatusPanel.Caption := InterpreterProgram.VResult
      else if vtype = varEmpty then
        StatusPanel.Caption := _('Empty')
      else if vtype = varNull then
        StatusPanel.Caption := _('Null')
      else if vtype = varObject then begin
          obj := V2O(InterpreterProgram.VResult);
          if Assigned(obj) then
           StatusPanel.Caption := _('Object: nil')
          else
           StatusPanel.Caption := _('Object: ') + obj.ClassName;
        end
      else if vtype = varSet then
        StatusPanel.Caption := _('Set: ') + IntToStr(V2S(InterpreterProgram.VResult))
      else
        StatusPanel.Caption := _('!Unknown!');

      ScriptEnabled := ScriptEnableCB.Checked;

    except
      on E : EJvInterpreterError do
      begin
        modalResult := mrNone;
        StatusPanel.Caption := IntToStr(E.ErrCode) + ': ' + ReplaceString(E.Message, #10, ' ');
        if E.ErrPos > -1 then
        begin
          SourceEditor.SelStart := E.ErrPos;
          SourceEditor.SelLength := 0;
        end;
        SourceEditor.SetFocus;
      end;

      on E : Exception do
      begin
        modalResult := mrNone;
        StatusPanel.Caption := IntToStr(InterpreterProgram.LastError.ErrCode) + ': ' +
        ReplaceString(InterpreterProgram.LastError.Message, #10, ' ');
        if InterpreterProgram.LastError.ErrPos > -1 then
        begin
          SourceEditor.SelStart := InterpreterProgram.LastError.ErrPos;
          SourceEditor.SelLength := 0;
        end;
        SourceEditor.SetFocus;
        raise;
      end
      else
      begin
        StatusPanel.Caption := _('error');
        raise;
      end;
      
    end; // Except

  finally
    StatusPanel.Color := clBtnFace;
  end;
end;




//
// Interpreter functions
//
procedure TScriptFrm.InterpreterProgramStatement(Sender: TObject);
begin
  Application.ProcessMessages;
  Sleep(ScriptSpeed);
end;



procedure TScriptFrm.InterpreterProgramGetValue(Sender: TObject;
  Identifier: String; var Value: Variant; Args: TJvInterpreterArgs; var Done: Boolean);
begin
//  if not ServerActive then Exit;

  try
    if Cmp(Identifier, 'GetBitValue') then
    begin
      Done := True;
      Value := MainFrm.GetBitValue(Args.Values[0]+1);
    end
    else if Cmp(Identifier, 'SetBitValue') then
    begin
      Done := True;
      MainFrm.SetBitValue(Args.Values[0]+1, Args.Values[1]);
    end

    else if Cmp(Identifier, 'GetRegisterValue') then
    begin
      Done := True;
      Value := MainFrm.GetRegisterValue(Args.Values[0]+1);
    end
    else if Cmp(Identifier, 'SetRegisterValue') then
    begin
      Done := True;
      MainFrm.SetRegisterValue(Args.Values[0]+1, Args.Values[1]);
    end

    else if Cmp(Identifier, 'GetRegisterDValue') then
    begin
      Done := True;
      Value := MainFrm.GetRegisterDValue(Args.Values[0]+1);
    end
    else if Cmp(Identifier, 'SetRegisterDValue') then
    begin
      Done := True;
      MainFrm.SetRegisterDValue(Args.Values[0]+1, Args.Values[1]);
    end

    else if Cmp(Identifier, 'GetRegisterFValue') then
    begin
      Done := True;
      Value := MainFrm.GetRegisterFValue(Args.Values[0]+1);
    end
    else if Cmp(Identifier, 'SetRegisterFValue') then
    begin
      Done := True;
      MainFrm.SetRegisterFValue(Args.Values[0]+1, Args.Values[1]);
    end

    else if Cmp(Identifier, 'Log') then
    begin
      Done := True;
      MainFrm.Log('[ ' + Args.Values[0] + ' ]');
      Application.ProcessMessages;
    end

    else if Cmp(Identifier, 'ScriptSpeed') then
    begin
      Done := True;
      ScriptSpeed := Value;
    end

    else if Cmp(Identifier, 'Terminated') then
    begin
      Done := True;
      Value := not ServerActive;
    end;

  except
    MainFrm.Log(Format(_('Error in script for function: %s'),[Identifier]));
  end;
end;



procedure TScriptFrm.InterpreterProgramSetValue(Sender: TObject;
  Identifier: String; const Value: Variant; Args: TJvInterpreterArgs;
  var Done: Boolean);
begin
  try

    if Cmp(Identifier, 'ScriptSpeed') then
    begin
      Done := True;
      ScriptSpeed := Value;
    end

  except
    MainFrm.Log(Format(_('Error in script for function: %s'),[Identifier]));
  end;
end;



//
// Run with timer
//
procedure TScriptFrm.RunScript;
begin
  if InterpreterProgram.Pas.Count <= 1 then Exit;
  try
    ScriptSpeed := 1;
    InterpreterProgram.Run;
  except
    on E : EJvInterpreterError do
    begin
      modalResult := mrNone;
      MainFrm.Log(IntToStr(E.ErrCode) + ': ' + ReplaceString(E.Message, #10, ' '));
    end;
  end;
end;



//
// Editor x,y
//
procedure TScriptFrm.SourceEditorChangeStatus(Sender: TObject);
begin
  CaretLabel.Caption := Format(_('X:%d Y:%d'), [SourceEditor.CaretX, SourceEditor.CaretY]);
end;



end.
