unit MyFunctions;

interface

uses SysUtils, Windows, Classes, Types, Forms, DB, DBGrids;

const
  CryptKey = 1791;

function Crypt(St:string; Key:integer = CryptKey):string;

function IntToBinary(const Value: Int64; const ALength: Integer): String;
function BinaryToInt(Value: String): Int64;

procedure AutoSizeCol(aGrid: TDBGrid);

procedure SetFormPosition(Form: TForm);

implementation


//
// Crypt string
//
function Crypt(St:string; Key:integer = CryptKey):string;
var
  i:byte;
  StCrypt:string;
begin
  StCrypt := ''; // Init var
  for i:=1 to Length(St) do
  StCrypt := StCrypt + Char(Byte(St[i]) xor Key shr 8); // Crypt
  result := StCrypt;
end;


//
// Integer/Binary
//
function IntToBinary(const Value: Int64; const ALength: Integer): String;
var
  iWork: Int64;
begin
  Result := '';
  iWork := Value;
  while (iWork > 0) do
  begin
    Result := IntToStr(iWork mod 2) + Result;
    iWork := iWork div 2;
  end;
  while (Length(Result) < ALength) do
    Result := '0' + Result;
end; { IntToBinary }




function BinaryToInt(Value: String): Int64;
var
  i, Size: Integer;
begin
  Result := 0;
  Size := Length(Value);
  for i := Size downto 1 do
    if Value[i] = '1' then Result := Result+(1 shl (Size-i));
end;




//
// Autosize column
//
procedure AutoSizeCol(aGrid: TDBGrid);
var
  MaxWidth, //Largeur maximale de la colonne
  MinWidth, //Largeur minimale de la colonne
  CurrentWidth: integer; //Largeur actuelle
  FieldSize: integer; //Taille du champ d'après son contenu
  DS: TDataSet;
  BookMark: TBookmark;
  Col: integer;
begin

  //Pour alléger l'écriture !...
  DS := aGrid.DataSource.DataSet;
  with aGrid do
  begin
    //Mémoriser la ligne actuellement sélectionnée
    BookMark := DS.GetBookmark;
    //Pour ne pas voir toutes les lignes défiler
    Ds.DisableControls;
    for Col := 0 to aGrid.Columns.Count - 1 do
      //ne traiter que les colonnes visibles
      if aGrid.Columns[Col].Visible then
      begin
        //prendre en compte la largeur des titres
        MaxWidth := Canvas.TextWidth(aGrid.Columns[Col].Title.Caption) + 5;
        MinWidth := MaxWidth;
        //Parcours de toutes les lignes de l'ensemble de données
        DS.First;
        while not DS.Eof do
        begin
          //Déterminer la largeur en pixels du contenu de l'enregistrement lu
          FieldSize := Canvas.TextWidth(aGrid.Columns[Col].Field.AsString) + 5;
          //Réajuster la largeur maximale ?
          if MaxWidth < FieldSize then
            MaxWidth := FieldSize;
          //Réajuster la largeur minimale ?
          if MinWidth > FieldSize then
            MinWidth := FieldSize;
          DS.Next;
        end;
        //Largeur de la colonne cliquée
        CurrentWidth := aGrid.Columns[Col].Width;

        if CurrentWidth <> MaxWidth then
          CurrentWidth := MaxWidth;

        if CurrentWidth < MinWidth then
          CurrentWidth := MinWidth;
        //Affectation de la nouvelle largeur à la colonne
        Columns[Col].Width := CurrentWidth;
      end; {if Grid.Columns[Col].Visible}
    //repositionner le curseur de l'ensemble de données
    DS.GotoBookmark(BookMark);
    DS.FreeBookmark(BookMark);
    //Rétablir l'affichage du TDbGrid
    DS.EnableControls;
  end;
end;




//
// Set correctly a popup form
//
procedure SetFormPosition(Form: TForm);
var
  Pos : TPoint;
  InvPartY, InvPartX: integer;
begin
  with Form do begin
    Windows.GetCursorPos(Pos);
    Left := Pos.X - Width div 2;
    Top := Pos.Y - Height div 2;
    InvPartX := Left + Width - Screen.DesktopWidth;
    if InvPartX > 0 then Left := Left - InvPartX;
    InvPartY := Top + Height - Screen.DesktopHeight;
    if InvPartY > 0 then Top := Top - InvPartY;
    if Left < 0 then Left := 0;
    if Top < 0 then Top := 0;
  end;
end;


end.
