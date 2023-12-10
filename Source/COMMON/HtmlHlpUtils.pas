{******************************************************************}
{                                                       	   }
{       HTML Help Utilities unit                                   }
{ 								   }
{ Portions created by Microsoft are 				   }
{ Copyright (C) 1995-1999 Microsoft Corporation. 		   }
{ All Rights Reserved. 						   }
{ 								   }
{ The original code is: HtmlHlpUtils.pas, released 9 Jun 1999.     }
{ The initial developer of the Pascal code is Marcel van Brakel    }
{ (brakelm@bart.nl).                      			   }
{ 								   }
{ Portions created by Marcel van Brakel are			   }
{ Copyright (C) 1999 Marcel van Brakel.				   }
{ 								   }
{ Contributor(s): Robert Chandler  (robert@helpware.net)           }
{ Some functions where inspired by functions originally written by }
{ Robert and included in his Delphi HH Kit (http://helpware.net    }
{ 								   }
{ Obtained through:                               	           }
{ Joint Endeavour of Delphi Innovators (Project JEDI)              }
{								   }
{ You may retrieve the latest version of this file at the Project  }
{ JEDI home page, located at http://delphi-jedi.org                }
{								   }
{ The contents of this file are used with permission, subject to   }
{ the Mozilla Public License Version 1.1 (the "License"); you may  }
{ not use this file except in compliance with the License. You may }
{ obtain a copy of the License at                                  }
{ http://www.mozilla.org/MPL/MPL-1.1.html	                   }
{                                                                  }
{ Software distributed under the License is distributed on an 	   }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or   }
{ implied. See the License for the specific language governing     }
{ rights and limitations under the License. 			   }
{ 								   }
{******************************************************************}

unit HtmlHlpUtils;

interface

uses
  Windows, VersionInfo;

type

{ TControlIdMap }

  TControlIdMap = class
  private
    FMap: array of DWORD;
    function GetMap: DWORD;
  public
    constructor Create;
    procedure Add(ControlId, TopicId: DWORD);
    property Map: DWORD read GetMap;
  end;

{ Functions }

function HHGetOCXPath(var Path: string): Boolean;

function HHGetVersion(var Version: TFileVersionInfo): Boolean;
function HHGetFriendlyVersion: string;

function GetSystemFolder: string;
function IEGetVersion(var Version: TFileVersionInfo): Boolean;
function IEGetFriendlyVersion: string;

function HHDisplayIndex(const URL, Keyword: string; Parent: HWND = 0): HWND;
function HHMakeUrl(const HelpFile, Topic: string; Window: string = ''): string;
function HHDisplayToc(const URL: string; Parent: HWND = 0): HWND;

function HHDisplayPopup(const Text: string; Pos: TPoint): HWND; overload;
function HHDisplayPopup(const URL: string; Id: Longword; Pos: TPoint): HWND; overload;
function HHDisplayPopup(Inst, Id: Longword; Pos: TPoint): HWND; overload;
procedure HHSetPopupAttr(const Font: string; const Margins: TRect; FGC, BGC: TColorRef);
procedure HHGetPopupAttr(var Font: string; var Margins: TRect;  var FGC, BGC: TColorRef);
function HHDisplayTopic(const URL: string; Parent: HWND = 0): HWND;
function HHHelpContext(const URL: string; ContextId: Longword; Parent: HWND): HWND;

function HHDisplayWMHelp(Map: TControlIdMap; const URL: string; Id: DWORD): HWND;
function HHDisplayContextMenu(Map: TControlIdMap; const URL: string; Id: DWORD): HWND;

function HHGetLastErrorString: string;
function HHGetLastErrorCode: HResult;
procedure HHGetLastError(var Description: string; var Code: HResult);

implementation

uses
  ActiveX, Classes, HtmlHlp, Registry, SysUtils;

{ TControlIdMap }

constructor TControlIdMap.Create;
begin
  SetLength(FMap, 2);
  FMap[0] := 0;
  FMap[1] := 0;
end;

procedure TControlIdMap.Add(ControlId, TopicId: DWORD);
var
  L: Integer;
begin
  L := Length(FMap) + 2;
  SetLength(FMap, L);
  FMap[L - 4] := ControlId;
  FMap[L - 3] := TopicId;
  FMap[L - 2] := 0;
  FMap[L - 1] := 0;
end;

function TControlIdMap.GetMap: DWORD;
begin
  Result := DWORD(@FMap[0]);
end;

{ Functions }

function HHGetOCXPath(var Path: string): Boolean;
const
  HHPathRegKey = 'CLSID\{adb880a6-d8ff-11cf-9377-00aa003b7a11}\InprocServer32';
begin
  with TRegistry.Create do
  try
    RootKey := HKEY_CLASSES_ROOT;
    {$IFDEF VER100}
    if OpenKey(HHPathRegKey, False) then Path := ReadString('');
    {$ELSE}
    if OpenKeyReadOnly(HHPathRegKey) then Path := ReadString('');
    {$ENDIF}
    Result := (Path <> '') and FileExists(Path);
  finally
    Free;
  end;
end;

function HHGetVersion(var Version: TFileVersionInfo): Boolean;
var
  Path: string;
begin
  Result := False;
  if HHGetOCXPath(Path) and VersionResourceAvailable(Path) then
  begin
    Version := TFileVersionInfo.Create(Path);
    Result := True;
  end;
end;

type
  TVersionMapEntry = record
    Version: string;
    Friendly: string;
  end;

const
  HHVersionMap: array[0..7] of TVersionMapEntry =
   ((Version: '4.72.7290'; Friendly:'1.0'),
    (Version: '4.72.7323'; Friendly:'1.1'),
    (Version: '4.72.7325'; Friendly:'1.1a'),
    (Version: '4.72.8164'; Friendly:'1.1b'),
    (Version: '4.73.8252'; Friendly:'1.2'),
    (Version: '4.73.8412'; Friendly:'1.21'),
    (Version: '4.73.8474'; Friendly:'1.21a'),
    (Version: '4.73.8561'; Friendly:'1.22'));

function HHGetFriendlyVersion: string;
var
  V: string;
  I: Integer;
  Version: TFileVersionInfo;
begin
  Result := '';
  if HHGetVersion(Version) then
  begin
    V := Version.FileVersion;
    for I := 0 to High(HHVersionMap) do
    begin
      if HHVersionMap[I].Version = V then
      begin
        Result := 'HTML Help ' + HHVersionMap[I].Friendly;
        Break;
      end;
    end;
  end;
end;

function GetSystemFolder: string;
var
  Size: Integer;
begin
  SetLength(Result, MAX_PATH + 1);
  Size := GetSystemDirectory(PChar(Result), MAX_PATH);
  SetLength(Result, Size);
  if Size > MAX_PATH then
  begin
    SetLength(Result, Size + 1);
    Size := GetSystemDirectory(PChar(Result), Size);
    SetLength(Result, Size);
  end;
  if Result[Length(Result)] = '\' then Delete(Result, Length(Result), 1);
end;

function IEGetVersion(var Version: TFileVersionInfo): Boolean;
var
  SysFolder: string;
begin
  Result := False;
  SysFolder := GetSystemFolder;
  if (SysFolder <> '') and (VersionResourceAvailable(SysFolder + '\shdocvw.dll')) then
  begin
    Version := TFileVersionInfo.Create(SysFolder + '\shdocvw.dll');
    Result := True;
  end;
end;

const
  IEVersionMap: array[0..17] of TVersionMapEntry =
   ((Version: '5.00.2615'; Friendly: '5.0'),
    (Version: '5.00.2614'; Friendly: '5.0b'),
    (Version: '5.00.2314'; Friendly: '5.0a'),
    (Version: '5.00.2014'; Friendly: '5.0'),
    (Version: '5.00.0910'; Friendly: '5 Beta (Beta 2)'),
    (Version: '5.00.0518'; Friendly: '5 Developer Preview (Beta 1)'),
    (Version: '4.72.3612'; Friendly: '4.01 Service Pack 2 (SP2)'),
    (Version: '4.72.3110'; Friendly: '4.01 Service Pack 1 (SP1)'),
    (Version: '4.72.2106'; Friendly: '4.01'),
    (Version: '4.71.1712'; Friendly: '4.0'),
    (Version: '4.71.1008'; Friendly: '4.0 Platform Preview 2.0 (PP2)'),
    (Version: '4.71.544';  Friendly: '4.0 Platform Preview 1.0 (PP1)'),
    (Version: '4.70.1300'; Friendly: '3.02'),
    (Version: '4.70.1215'; Friendly: '3.01'),
    (Version: '4.70.1158'; Friendly: '3.0 (OSR2)'),
    (Version: '4.70.1155'; Friendly: '3.0'),
    (Version: '4.40.520';  Friendly: '2.0'),
    (Version: '4.40.308';  Friendly: '1.0 (Plus!)'));

function IEGetFriendlyVersion: string;
var
  V: string;
  I: Integer;
  Version: TFileVersionInfo;
begin
  Result := '';
  if IEGetVersion(Version) then
  begin
    V := Copy(Version.FileVersion, 1, 9);
    if V[9] = ',' then Delete(V, 9, 1);
    for I := 0 to High(IEVersionMap) do
    begin
      if IEVersionMap[I].Version = V then
      begin
        Result := 'Internet Explorer ' + IEVersionMap[I].Friendly;
        Break;
      end;
    end;
  end;
end;

function HHDisplayIndex(const URL, Keyword: string; Parent: HWND = 0): HWND;
begin
  Result := HtmlHelp(Parent, PChar(URL), HH_DISPLAY_INDEX, DWORD(PChar(Keyword)));
end;

function HHMakeUrl(const HelpFile, Topic: string; Window: string = ''): string;
begin
  Result := HelpFile;
  if Topic <> '' then Result := Result + '::/' + Topic;
  if Window <> '' then Result := Result + '>' + Window;
end;

function HHDisplayToc(const URL: string; Parent: HWND = 0): HWND;
begin
  Result := HtmlHelp(Parent, PChar(URL), HH_DISPLAY_TOC, 0);
end;

var
  PopupAttr: THHPopup;
  PopupFont: string;

procedure HHSetPopupAttr(const Font: string; const Margins: TRect; FGC, BGC: TColorRef);
begin
  PopupFont := Font;
  PopupAttr.pszFont := PChar(PopupFont);
  PopupAttr.rcMargins := Margins;
  PopupAttr.clrForeGround := FGC;
  PopupAttr.clrBackground := BGC;
end;

procedure HHGetPopupAttr(var Font: string; var Margins: TRect;  var FGC, BGC: TColorRef);
begin
  Font := PopupFont;
  Margins := PopupAttr.rcMargins;
  FGC := PopupAttr.clrForeGround;
  BGC := PopupAttr.clrBackground;
end;

function HHDisplayPopup(const Text: string; Pos: TPoint): HWND;
var
  Popup: THHPopup;
begin
  FillChar(Popup, SizeOf(Popup), 0);
  Popup.cbStruct := SizeOf(Popup);
  Popup.hinst := 0;
  Popup.idString := 0;
  Popup.pszText := PChar(Text);
  Popup.pt := Pos;
  Popup.clrForeGround := PopupAttr.clrForeGround;
  Popup.clrBackground := PopupAttr.clrBackground;
  Popup.rcMargins := PopupAttr.rcMargins;
  Popup.pszFont := PopupAttr.pszFont;
  Result := HtmlHelp(0, nil, HH_DISPLAY_TEXT_POPUP, DWORD(@Popup));
end;

function HHDisplayPopup(const URL: string; Id: Longword; Pos: TPoint): HWND;
var
  Popup: THHPopup;
begin
  FillChar(Popup, SizeOf(Popup), 0);
  Popup.cbStruct := SizeOf(Popup);
  Popup.hinst := 0;
  Popup.idString := Id;
  Popup.pszText := nil;
  Popup.pt := Pos;
  Popup.clrForeGround := PopupAttr.clrForeGround;
  Popup.clrBackground := PopupAttr.clrBackground;
  Popup.rcMargins := PopupAttr.rcMargins;
  Popup.pszFont := PopupAttr.pszFont;
  Result := HtmlHelp(0, PChar(URL), HH_DISPLAY_TEXT_POPUP, DWORD(@Popup));
end;

function HHDisplayPopup(Inst, Id: Longword; Pos: TPoint): HWND;
var
  Popup: THHPopup;
begin
  FillChar(Popup, SizeOf(Popup), 0);
  Popup.cbStruct := SizeOf(Popup);
  Popup.hinst := Inst;
  Popup.idString := Id;
  Popup.pszText := nil;
  Popup.pt := Pos;
  Popup.clrForeGround := PopupAttr.clrForeGround;
  Popup.clrBackground := PopupAttr.clrBackground;
  Popup.rcMargins := PopupAttr.rcMargins;
  Popup.pszFont := PopupAttr.pszFont;
  Result := HtmlHelp(0, nil, HH_DISPLAY_TEXT_POPUP, DWORD(@Popup));
end;

function HHDisplayTopic(const URL: string; Parent: HWND = 0): HWND;
begin
  Result := HtmlHelp(Parent, PChar(URL), HH_DISPLAY_TOPIC, 0);
end;

function HHHelpContext(const URL: string; ContextId: Longword; Parent: HWND): HWND;
begin
  Result := HtmlHelp(Parent, PChar(URL), HH_HELP_CONTEXT, ContextId);
end;

function HHDisplayWMHelp(Map: TControlIdMap; const URL: string; Id: DWORD): HWND;
begin
  Result := HtmlHelp(Id, PChar(URL), HH_TP_HELP_WM_HELP, Map.Map);
end;

function HHDisplayContextMenu(Map: TControlIdMap; const URL: string; Id: DWORD): HWND;
begin
  Result := HtmlHelp(Id, PChar(URL), HH_TP_HELP_CONTEXTMENU, Map.Map);
end;

function HHGetLastErrorString: string;
var
  Code: HResult;
begin
  HHGetLastError(Result, Code);
end;

function HHGetLastErrorCode: HResult;
var
  Description: string;
begin
  HHGetLastError(Description, Result);
end;

procedure HHGetLastError(var Description: string; var Code: HResult);
var
  LastError: THHLastError;
begin
  Description := '';
  Code := 0;
  if HtmlHelp(0, nil, HH_GET_LAST_ERROR, DWORD(@LastError)) <> 0 then
  begin
    if Failed(LastError.hr) then
    begin
      Code := LastError.hr;
      if LastError.Description <> nil then
      begin
        Description := LastError.Description;
        SysFreeString(LastError.Description);
      end;
    end;
  end;
end;

initialization
  PopupAttr.clrForeGround := TColorRef(-1);
  PopupAttr.clrBackground := TColorRef(-1);
  PopupAttr.rcMargins := Rect(-1, -1, -1, -1);
  PopupFont := '';
  PopupAttr.pszFont := PChar(PopupFont);
end.
