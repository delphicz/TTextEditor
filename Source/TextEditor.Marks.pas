unit TextEditor.Marks;

interface

uses
  System.Classes, System.Contnrs, Vcl.Controls, Vcl.Graphics;

type
  TTextEditorMark = class
  protected
    FBackground: TColor;
    FChar: Integer;
    FData: Pointer;
    FEditor: TCustomControl;
    FImageIndex: Integer;
    FIndex: Integer;
    FLine: Integer;
    FVisible: Boolean;
  public
    constructor Create(AOwner: TCustomControl);
    property Background: TColor read FBackground write FBackground default clNone;
    property Char: Integer read FChar write FChar;
    property Data: Pointer read FData write FData;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
    property Index: Integer read FIndex write FIndex;
    property Line: Integer read FLine write FLine;
    property Visible: Boolean read FVisible write FVisible;
  end;

  TTextEditorMarkEvent = procedure(ASender: TObject; var AMark: TTextEditorMark) of object;
  TTextEditorMarks = array of TTextEditorMark;

  TTextEditorMarkList = class(TObjectList)
  protected
    FEditor: TCustomControl;
    FOnChange: TNotifyEvent;
    function GetItem(AIndex: Integer): TTextEditorMark;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    procedure SetItem(AIndex: Integer; AItem: TTextEditorMark);
    property OwnsObjects;
  public
    constructor Create(AOwner: TCustomControl);
    function Extract(AItem: TTextEditorMark): TTextEditorMark;
    function Find(const AIndex: Integer): TTextEditorMark;
    function First: TTextEditorMark;
    function Last: TTextEditorMark;
    procedure ClearLine(ALine: Integer);
    procedure GetMarksForLine(ALine: Integer; var AMarks: TTextEditorMarks);
    procedure Place(AMark: TTextEditorMark);
    property Items[AIndex: Integer]: TTextEditorMark read GetItem write SetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

uses
  System.Types, TextEditor;

constructor TTextEditorMark.Create(AOwner: TCustomControl);
begin
  inherited Create;

  FBackground := clNone;
  FIndex := -1;
  FEditor := AOwner;
end;

{ TTextEditorBookmarkList }

procedure TTextEditorMarkList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TTextEditorMarkList.GetItem(AIndex: Integer): TTextEditorMark;
begin
  Result := TTextEditorMark(inherited GetItem(AIndex));
end;

procedure TTextEditorMarkList.SetItem(AIndex: Integer; AItem: TTextEditorMark);
begin
  inherited SetItem(AIndex, AItem);
end;

constructor TTextEditorMarkList.Create(AOwner: TCustomControl);
begin
  inherited Create;
  FEditor := AOwner;
end;

function TTextEditorMarkList.Find(const AIndex: Integer): TTextEditorMark;
var
  LIndex: Integer;
  LMark: TTextEditorMark;
begin
  Result := nil;
  for LIndex := Count - 1 downto 0 do
  begin
    LMark := Items[LIndex];
    if LMark.Index = AIndex then
      Exit(LMark);
  end;
end;

function TTextEditorMarkList.First: TTextEditorMark;
begin
  Result := TTextEditorMark(inherited First);
end;

function TTextEditorMarkList.Last: TTextEditorMark;
begin
  Result := TTextEditorMark(inherited Last);
end;

function TTextEditorMarkList.Extract(AItem: TTextEditorMark): TTextEditorMark;
begin
  Result := TTextEditorMark(inherited Extract(AItem));
end;

procedure TTextEditorMarkList.ClearLine(ALine: Integer);
var
  LIndex: Integer;
begin
  for LIndex := Count - 1 downto 0 do
  if Items[LIndex].Line = ALine then
    Delete(LIndex);
end;

procedure TTextEditorMarkList.GetMarksForLine(ALine: Integer; var AMarks: TTextEditorMarks);
var
  LIndex, LIndex2: Integer;
  LMark: TTextEditorMark;
begin
  SetLength(AMarks, Count);
  LIndex2 := 0;
  for LIndex := 0 to Count - 1 do
  begin
    LMark := Items[LIndex];
    if LMark.Line = ALine then
    begin
      AMarks[LIndex2] := LMark;
      Inc(LIndex2);
    end;
  end;
  SetLength(AMarks, LIndex2);
end;

procedure TTextEditorMarkList.Place(AMark: TTextEditorMark);
var
  LEditor: TCustomTextEditor;
begin
  LEditor := nil;
  if Assigned(FEditor) and (FEditor is TCustomTextEditor) then
    LEditor := FEditor as TCustomTextEditor;
  if Assigned(LEditor) then
    if Assigned(LEditor.OnBeforeMarkPlaced) then
      LEditor.OnBeforeMarkPlaced(FEditor, AMark);
  if Assigned(AMark) then
    Add(AMark);
  if Assigned(LEditor) then
    if Assigned(LEditor.OnAfterMarkPlaced) then
      LEditor.OnAfterMarkPlaced(FEditor);
end;

end.
