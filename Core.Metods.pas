unit Core.Metods;

interface

uses
  system.Classes, system.SysUtils, system.Rtti, system.Generics.Collections,
  Vcl.Forms, Vcl.Controls, Core.consts, Vcl.StdCtrls, Core.types, superobject,
  db, Vcl.dialogs, uniGUITypes, IGNY.Metods, uniGUIApplication, uniSweetAlert;

type
  TCompControl = class
  private
    FButtonClickEvent: TNotifyEvent;
    FCallBack: TProc<TListeCevap>;
    FEdit: TxEdit;
    procedure ButtonClick(Sender: TObject);
    constructor Create(AEdit: TxEdit);
    procedure CallBackProc(Sonuc: TListeCevap);
  published
    property onButtonClick: TNotifyEvent read FButtonClickEvent write FButtonClickEvent;
  end;

  TSweetDialog = class
  private
    FConfirmEvent: TNotifyEvent;
    FProc: TProc;
    procedure Confirm(Sender: TObject);
    constructor Create(Proc: TProc);
  published
    property onAlertConfirm: TNotifyEvent read FConfirmEvent write FConfirmEvent;
  end;

  TServis = class
    class function GetView(AView: string): TDataSource;
    class function GetKart(ATablo: string; Kod: Integer; Cntrl: TWinControl): TFormJson;
    class function SaveKart(ATablo: string; Cntrl: TWinControl): Integer;
    class function DeleteKart(ATablo: string; Kod: Integer): Boolean;
    class function GetInfo(ATablo: string; Kod: Integer): TKayitInfo;

    class function Get<T>(Servis: string; Params: string): TCevap<T>;
    class function Post<T>(Servis, Data: string): TCevap<T>; static;

    class function GetSQLData(SQL: string): TDataSet; static;
    class function GetDef(Tablo:string):TListeCevap;
  end;

  TDlg = class
    class procedure MesajSor(Mesaj: string; ConfirmProc: TProc; Form: TWinControl);
  end;

function ControlToJson(Form: TWinControl; FrmJson: TFormJson = nil): string;

function DataToControl(Dset: TDataSet; Form: TWinControl): string;

function JsonToControl(jsonstr: string; Form: TWinControl): string;

procedure ClearControl(Form: TWinControl);

procedure FreeControl(Form: TWinControl);

//procedure MesajVer(msg: string);
function DataToJson(Dset: TDataSet): string;

function FormDataToJson(Dset: TDataSet): string;

function JsonToCreateControl(jsonstr: string; Form: TWinControl): string;

function JsonToCreateParamControl(SQL: string; Form: TWinControl): string;

function ControlToSQL(FSQL: string; Form: TWinControl): string;

function TabloKodJson(Kod: Integer; Tablo: string): string;

function KontrolBul(Cntrl: TWinControl; Adi: string): TWinControl;
procedure SetDefDataToEdit(Edit:TxEdit);
procedure MesajBox(Mesaj: string; Baslik: string = 'Bilgi'; Sn: Integer = 0);
function FormJsonToControl(FrmJson: TFormJson; Form: TWinControl): string;
var
  FormJson: string;

implementation

uses
  WebBase.List, Core.View, Main;

function ControlToJson(Form: TWinControl; FrmJson: TFormJson = nil): string;
var
  I: Integer;
  Cntrl: TWinControl;
  Field, Value, Tip: string;
  ctx: TSuperRttiContext;
begin
  if not Assigned(FrmJson) then
  begin
    FrmJson := TFormJson.Create;
    FrmJson.Name := Form.Hint;
    FrmJson.No := TWinControl(Form).Tag;
  end;
  for I := 0 to Form.ControlCount - 1 do
  begin
    Cntrl := TWinControl(Form.Controls[I]);
    if Cntrl = nil then
      Continue;

    if X.strArray.Find(Cntrl.ClassName, HaricContol) then
    begin
      if TWinControl(Cntrl).ControlCount > 0 then
        ControlToJson(Cntrl, FrmJson);
      Continue;
    end;
    Field := Cntrl.Name;
    if X.strArray.Find(Cntrl.ClassName, DahilContol) then
    begin

      if Cntrl.ClassNameIs('TUniEdit') then
      begin
        Tip := 'STR';
        Value := TxEdit(Cntrl).Text;
        if TxEdit(Cntrl).InputType = 'text' then
          Tip := 'STR';

        if TxEdit(Cntrl).InputType = 'number' then
        begin
          Tip := 'CUR';
          Value := ParaToStr(StrToPara(TxEdit(Cntrl).Text));
        end;
        if TxEdit(Cntrl).InputType = 'date' then
          Tip := 'DTE';
        if TxEdit(Cntrl).InputType = 'datetime-local' then
          Tip := 'DTT';

      end;

      FrmJson.AddValue(Field, Value, Tip);
    end;
  end;
  ctx := TSuperRttiContext.Create;
  try
    Result := ctx.AsJson<TFormJson>(FrmJson).AsString;
  finally
    ctx.Free;
  end;
end;

function EditToParam(SQL: string; Edt: TxEdit): string;
begin
  if Edt.InputType = 'number' then
    Result := Edt.Text
  else
    Result := QuotedStr(Edt.Text);
  Result := SQL.Replace(':' + Edt.Name, Result);
end;

function ControlToSQL(FSQL: string; Form: TWinControl): string;
var
  Cntrl, SubCntrl: TControl;
  I: Integer;
  Z: Integer;
begin
  Result := FSQL;
  Result := Result.Replace('INTX', '').Replace('STRX', '').Replace('DTEX', '').Replace('CURX', '').Replace('DTTX', '');

  for I := 0 to Form.ControlCount - 1 do
  begin
    Cntrl := Form.Controls[I];
    if Cntrl.ClassNameIs(TxPanel.ClassName) then
    begin
      for Z := 0 to TxPanel(Cntrl).ControlCount - 1 do
      begin
        SubCntrl := TxPanel(Cntrl).Controls[Z];
        if SubCntrl.ClassNameIs(TxEdit.ClassName) then
        begin
          Result := EditToParam(Result, TxEdit(SubCntrl));
        end;
      end;
    end
    else if Cntrl.ClassNameIs(TxEdit.ClassName) then
      Result := EditToParam(Result, TxEdit(Cntrl));
  end;
end;

function DataToControl(Dset: TDataSet; Form: TWinControl): string;
var
  Cntrl: TComponent;
  Field: TField;
begin
  for Field in Dset.Fields do
  begin
    Cntrl := Form.FindComponent(Field.Name);
    if Assigned(Cntrl) then
    begin
      if Cntrl.ClassNameIs('TEdit') then
        TEdit(Cntrl).Text := Field.AsString;
    end;
  end;
end;

function DataToJson(Dset: TDataSet): string;
var
  Field: TField;
  Row: string;
begin
  Result := '{"Dset":[';

  if Dset.RecNo <= 0 then
  begin
    Result := Result + ']}';
    Exit;
  end;
  while not Dset.Eof do
  begin
    if Dset.RecNo > 1 then
      Row := ',{'
    else
      Row := '{';
    for Field in Dset.Fields do
    begin
      if Row <> '{' then
        Row := Row + ',';

      Row := Row + '"' + Field.FieldName + '":';
      case Field.DataType of
        ftString, ftMemo:
          Row := Row + '"' + Field.AsString + '"';
        ftInteger, ftSmallint, ftWord, ftLargeint, ftFloat, ftCurrency:
          Row := Row + Field.AsString;
      end;
      Row := Row + '}';
    end;
    Dset.Next;
  end;
  Result := Result + ']}';
end;

function FormDataToJson(Dset: TDataSet): string;
var
  Field: TField;
  Row: string;
  FormJson: TFormJson;
begin
  FormJson := TFormJson.Create;
  try
    FormJson.Name := Dset.Name;
    FormJson.No := Dset.Tag;

    for Field in Dset.Fields do
    begin
      case Field.DataType of

        ftWideMemo, ftWideString, ftMemo, ftString:
          Row := 'STR';
        ftLongWord, ftShortint, ftWord, ftAutoInc, ftSmallint, ftInteger, ftLargeint:
          Row := 'INT';

        ftExtended, ftFloat, ftCurrency, ftBCD, ftSingle:
          Row := 'CUR';
        ftDate, ftTime, ftDateTime, ftTimeStamp:
          Row := 'DTE';

      end;
      FormJson.AddValue(Field.FieldName, Field.AsString, Row);
    end;
    Result := XJson.toJson<TFormJson>(FormJson);
  finally
    FormJson.Free;
  end;
end;

function JsonToControl(jsonstr: string; Form: TWinControl): string;
var
  Cntrl: TComponent;
  FrmJson: TFormJson;
  Field: TJsonField;
begin
  FrmJson := X.Json.parse<TFormJson>(jsonstr);
  for Field in FrmJson.Values do
  begin
    Cntrl := Form.FindComponent(Field.Field);
    if Assigned(Cntrl) then
    begin
      if Cntrl.ClassName=Txedit.ClassName then
        TxEdit(Cntrl).Text := Field.Value;
    end;
  end;
end;
function FormJsonToControl(FrmJson: TFormJson; Form: TWinControl): string;
var
  Cntrl: TComponent;
  Field: TJsonField;
begin
  for Field in FrmJson.Values do
  begin
    Cntrl := Form.FindComponent(Field.Field);
    if Assigned(Cntrl) then
    begin
      if Cntrl.ClassName=Txedit.ClassName then
        TxEdit(Cntrl).Text := Field.Value;
    end;
  end;
end;

function SQLParamToJson(SQL: string): string;
var
  Mem: TxMem;
  I: Integer;
  FJ: TFormJson;
  F: TFieldType;
begin
  FJ := TFormJson.Create;
  try
    X.data.FQQ.Close;
    X.data.FQQ.SQL.Text := SQL;
    for I := 0 to x.data.FQQ.Params.Count - 1 do
    begin
      F := X.data.FQQ.Params[I].DataType;
      FJ.AddValue(X.data.FQQ.Params[I].Name, '', X.data.FQQ.Params[I].DataTypeName);
    end;
    Result := X.json.toJson(FJ);
  finally
    FJ.Free;
  end;
end;

function JsonToCreateParamControl(SQL: string; Form: TWinControl): string;
begin
  Result := SQLParamToJson(SQL);
  JsonToCreateControl(Result, Form);
end;

function KontrolBul(Cntrl: TWinControl; Adi: string): TWinControl;
var
  Z, I: Integer;
  W: TWinControl;
begin
  Result := nil;
  for I := 0 to Cntrl.ControlCount - 1 do
  begin
    W := TWinControl(Cntrl.Controls[I]);
    for Z := 0 to W.ControlCount - 1 do
      if Adi = W.Controls[Z].Name then
      begin
        Result := TWinControl(W.Controls[Z]);
        Break;
      end;
  end;
end;

function JsonToCreateControl(jsonstr: string; Form: TWinControl): string;
var
  Cntrl: TComponent;
  FrmJson: TFormJson;
  Field: TJsonField;
  Edit: TxEdit;
  Lbl: TxLabel;
  Panel: TxPanel;
  Sb: TxSpeedButton;
  I, Z: Integer;
  Tmp, Adi, Tip, Baslik: string;
  A: TArray<string>;
  CC: TCompControl;
  RM: Integer;
  Duzenleme: Boolean;
begin
  I := 0;
  Z := 0;
  RM := 25;
  Duzenleme := Form.Align = TAlign.alLeft;
  if Duzenleme then    //kenardan boþluk kalasýný istemiyorsak
    RM := 3;
  FrmJson := X.Json.parse<TFormJson>(jsonstr);
  for Field in FrmJson.Values do
  begin
//    Cntrl := Form.FindComponent(Field.Field);
//    if Assigned(Cntrl) then
//    begin
    A := Field.Field.Split(['X']);
    Tip := A[0];
    Adi := A[1];
    if Length(A) > 2 then
      Baslik := A[2]
    else
      Baslik := Adi;

    Panel := TxPanel.Create(Form);
    Panel.Parent := Form;
    Panel.Caption := '';
    Panel.Align := alTop;
    Panel.Height := 25;
    Panel.BorderStyle := ubsNone;
    Panel.AlignWithMargins := True;
    Panel.Margins.Left := 5;
    Panel.Margins.Right := RM;
    Panel.Margins.Top := 0;
    Panel.Margins.Bottom := 0;
    Panel.TabOrder := Z;
//    Panel.AlwaysOnTop:=True;
//    Panel.AlwaysOnTopPriority := I;
    I := I + 25;
    Panel.Top := I;
    Lbl := TxLabel.Create(Panel);
    Lbl.Caption := Baslik;
    Lbl.Parent := Panel;
    Lbl.Alignment := TAlignment.taLeftJustify;
    Lbl.AutoSize := False;
    Lbl.Width := 75;
    Lbl.AlignWithMargins := True;
    Lbl.Align := TAlign.alLeft;

    Edit := TxEdit.Create(Panel);
    Edit.Text := Field.Value;
    Edit.Parent := Panel;
    Edit.Name := Adi;
    Edit.Alignment := TAlignment.taLeftJustify;
    Edit.AlignWithMargins := True;
    Edit.Align := TAlign.alClient;
    Edit.Margins.Right := RM;
    if Tip = 'LKP' then
    begin
      Randomize;
      Tmp := Adi + 'X' + IntToStr(Random(100));

      Sb := TxSpeedButton.Create(Panel);
      Sb.Caption := '...';
      Sb.Parent := Panel;
      Sb.Name := Tmp;
      Sb.AlignWithMargins := True;
      Sb.Margins.Right := RM;
      Sb.Margins.Left := 0;
      Sb.Margins.Bottom := 0;
      Sb.Align := TAlign.alRight;
      CC := TCompControl.Create(Edit);
      Sb.OnClick := CC.ButtonClick;
      Edit.ReadOnly := True;
      Edit.Name := 'LKPX' + Adi;
      Edit.Margins.Right := 3;
    end;
    if (Tip = 'INT') or (Tip = 'CUR') then
    begin
      Edit.InputType := 'number';
    end;
    if Tip = 'STR' then
    begin
      Edit.InputType := 'text';
    end;
    if Tip = 'DTE' then
    begin
      Edit.InputType := 'date';
    end;
    if Tip = 'DTT' then
    begin
      Edit.InputType := 'datetime-local';
    end;
    if Adi = 'Kod' then
      Edit.Enabled := False;
    Z := Z + 1;
  end;

  if Duzenleme = False then
  begin
    I := I + 135;
    if Screen.WorkAreaHeight - 650 < I then
      I := Screen.WorkAreaHeight - 650;

    TForm(Form.Parent).Height := I;
  end;
//  end;
end;

procedure ClearControl(Form: TWinControl);
var
  I: Integer;
  Cntrl: TComponent;
  Field: string;
begin
  for I := 0 to Form.ComponentCount - 1 do
  begin
    Cntrl := TComponent(Form.Components[I]);
    if Cntrl = nil then
      Continue;
    Field := Cntrl.Name;
    if Cntrl.ClassName = TxPanel.ClassName then
    begin
      ClearControl(TWinControl(Cntrl));
    end
    else if X.strArray.Find(Cntrl.ClassName, DahilContol) then
    begin
      if Cntrl.ClassNameIs(TxEdit.ClassName) then
        TxEdit(Cntrl).Text := '';
      if Cntrl.ClassNameIs('TMemo') then
        TMemo(Cntrl).Lines.Clear;
    end;
  end;
  Form.Tag := 0;
end;
procedure SetDefDataToEdit(Edit:TxEdit);
var Cevap:TListeCevap;Tablo:String;
begin
  Tablo:=Edit.Name;
  Tablo:=Tablo.Replace('kod','Kart');
  Cevap:=TServis.GetDef(Tablo);
  Edit.Tag:=Cevap.Kod;
  Edit.Text:=Cevap.Adi;
end;
procedure FreeControl(Form: TWinControl);
var
  I: Integer;
  Cntrl: TComponent;
  Field: string;
begin
  for I := Form.ComponentCount - 1 downto 0 do
  begin
    Cntrl := TComponent(Form.Components[I]);
    if Cntrl = nil then
      Continue;
    FreeAndNil(Cntrl);
  end;
end;

{ TCompControl }
procedure TCompControl.CallBackProc(Sonuc: TListeCevap);
begin
  FEdit.Tag := Sonuc.Kod;
  FEdit.Text := Sonuc.Adi;
end;

procedure TCompControl.ButtonClick(Sender: TObject);
var
  FName, View: string;
  A: TArray<string>;
begin
  FName := TWinControl(Sender).Name;
  A := FName.Split(['X']);
  View := A[0];
  TView.ShowListe(View, FCallBack);
end;

constructor TCompControl.Create(AEdit: TxEdit);
begin
  inherited Create;
  FEdit := AEdit;
  FCallBack := CallBackProc
end;

function TabloKodJson(Kod: Integer; Tablo: string): string;
var
  TT: TTKod;
begin
  TT := TTKod.Create;
  try
    TT.Kod := Kod;
    TT.Tablo := Tablo;
    Result := x.json.toJson(TT);
  finally
    TT.Free;
  end;
end;

{ TServis }
class function TServis.Get<T>(Servis: string; Params: string): TCevap<T>;
var
  Json: string;
begin
  try
    Json := X.rest.get(x.conf.RestBaseURL + Servis + '?' + Params);
    Result := x.json.parse<TCevap<T>>(Json);
  except
    on E: Exception do
    begin
      Result.hata := True;
      Result.mesaj := E.Message;
      E.Message := '';
    end;
  end;
end;

class function TServis.GetDef(Tablo: string): TListeCevap;
var SQL:String;Dset:TDataSet;
begin
  Result:=TListeCevap.Create;
  try
    SQL:='select Kod,Adi from '+Tablo+' where Kod = cast((select Deger from genel_Parametre where Adi='+QuotedStr('Def_'+Tablo)+') as Int)';
    Dset:=TServis.GetSQLData(SQL);
    if Assigned(Dset) then
    begin
      Result.Kod:=Dset.FieldByName('Kod').AsInteger;
      Result.Adi:=Dset.FieldByName('Adi').AsString;
    end;
  finally

  end;
end;

class function TServis.Post<T>(Servis: string; Data: string): TCevap<T>;
var
  Json: string;
begin
  try
    Json := X.rest.post(x.conf.RestBaseURL + Servis, Data);
    Result := x.json.parse<TCevap<T>>(Json);
  except
    on E: Exception do
    begin
      Result.hata := True;
      Result.mesaj := E.Message;
      E.Message := '';
    end;
  end;
end;

class function TServis.DeleteKart(ATablo: string; Kod: Integer): Boolean;
var
  Json: string;
  Cevap: TCevap<string>;
begin
  Result := True;
  Cevap := Get<string>('deletekart', 'tablo=' + ATablo + '&kod=' + IntToStr(Kod));
  if Cevap.hata then
  begin
    Result := False;
    raise Exception.Create(Cevap.mesaj);
  end;
end;

class function TServis.GetInfo(ATablo: string; Kod: Integer): TKayitInfo;
var
  Json: string;
begin
  Json := X.http.GetString(X.conf.RestBaseURL + 'getinfo?tablo=' + ATablo + '&kod=' + IntToStr(Kod));
  Result := X.json.parse<TKayitInfo>(Json);
end;

class function TServis.GetKart(ATablo: string; Kod: Integer; Cntrl: TWinControl): TFormJson;
var
  Json: string;
begin
  Json := X.http.GetString(X.conf.RestBaseURL + 'getkart?tablo=' + ATablo + '&kod=' + IntToStr(Kod));
  Result := X.Json.parse<TFormJson>(Json);
  if Assigned(Cntrl) then
  begin
    JsonToCreateControl(Json, Cntrl);
    Cntrl.Hint := ATablo;
    Cntrl.Tag := Kod;
  end;
end;

class function TServis.GetView(AView: string): TDataSource;
var
  MS: TMemoryStream;
begin
  MS := X.http.GetStream(x.conf.RestBaseURL + 'getlist?view=' + AView);
  Result := x.data.StreamDS(MS);
end;
class function TServis.GetSQLData(SQL: string): TDataSet;
var
  MS: TMemoryStream;
begin
  MS := X.http.GetStream(x.conf.RestBaseURL + 'getsqldata?' + SQL);
  Result := x.data.StreamDset(MS);
end;

class function TServis.SaveKart(ATablo: string; Cntrl: TWinControl): Integer;
var
  Json: string;
  Cevap: TCevap<string>;
begin
  Json := ControlToJson(Cntrl);
  Cevap := Post<string>('savekart', Json);
  Result := 0;
  if Cevap.hata then
    raise Exception.Create(Cevap.mesaj)
  else
    Result := StrToIntDef(Cevap.sonuc, 0);
  Cntrl.Tag := Result;
end;

procedure MesajBox(Mesaj: string; Baslik: string = 'Bilgi'; Sn: Integer = 0);
var
  Alert: TUniSweetAlert;
  Tip: TAlertType;
begin
  Alert := TUniSweetAlert.Create(nil);
  Alert.ConfirmButtonText := 'Tamam';

  Tip := atInfo;
  if Baslik = 'Bilgi' then
    Tip := atInfo;
  if Baslik = 'Hata' then
    Tip := atError;
  if Baslik = 'Uyarý' then
    Tip := atWarning;
  if Baslik = 'Baþarýlý' then
    Tip := atSuccess;

  Alert.AlertType := Tip;
  Alert.Title := Baslik;
  Alert.TitleText := Baslik;
  Alert.Text := Mesaj;
  Alert.CancelButtonText := 'Ýptal';
  Alert.TimerMS := Sn * 1000;
  Alert.Show(Mesaj);
  Alert.FreeOnRelease;
end;

class procedure TDlg.MesajSor(Mesaj: string; ConfirmProc: TProc; Form: TWinControl);
var
  Alert: TUniSweetAlert;
  Dlg: TSweetDialog;
begin
  Alert := TUniSweetAlert.Create(Form);
  Alert.ConfirmButtonText := 'Evet';

  Alert.AlertType := atQuestion;
  Alert.Title := 'Onay';
  Alert.TitleText := 'Onay';
  Alert.Text := Mesaj;
  Alert.CancelButtonText := 'Hayýr';
  Alert.ShowConfirmButton := True;
  Alert.ShowCancelButton := True;
  Dlg := TSweetDialog.Create(ConfirmProc);
  Alert.OnConfirm := Dlg.Confirm;
  Alert.Show(Mesaj);

end;
{ TSweetDialog }

procedure TSweetDialog.Confirm(Sender: TObject);
begin
  FProc;
end;

constructor TSweetDialog.Create(Proc: TProc);
begin
  inherited Create;
  FProc := Proc;
end;

end.

