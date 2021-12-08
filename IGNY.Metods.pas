unit IGNY.Metods;

interface

uses
  System.Classes, superobject, DB, SysUtils, System.IniFiles, variants, FireDAC.Stan.StorageBin,
  FireDAC.Comp.Client, FireDAC.Stan.Intf,FireDAC.Stan.Option, Forms, DateUtils, dialogs,Winapi.ShellAPI,
  System.TypInfo, rtti,System.StrUtils,System.Types,Winapi.Windows,System.NetEncoding,IdSSLOpenSSL,IdHTTP,
  FireDAC.Phys.MSSQL,ortak.rest.client;

type
  TxCon={$IF CompilerVersion < 26}TADConnection{$ENDIF}{$IF CompilerVersion >= 26}TFDConnection{$ENDIF};
  TxQQ ={$IF CompilerVersion < 26}TADQuery{$ENDIF}{$IF CompilerVersion >= 26}TFDQuery{$ENDIF};
  TxTR ={$IF CompilerVersion < 26}TADTransaction{$ENDIF}{$IF CompilerVersion >= 26}TFDTransaction{$ENDIF};
  TxCTr={$IF CompilerVersion < 26}TADCustomTransaction{$ELSE}TFDCustomTransaction{$ENDIF} ;
  TxMem={$IF CompilerVersion < 26}TADMemTable{$ENDIF}{$IF CompilerVersion >= 26}TFDMemTable{$ENDIF};
  TxDataType ={$IF CompilerVersion < 26}TADDataType{$ENDIF}{$IF CompilerVersion >= 26}TFDDataType{$ENDIF};
  TxDset = TDataSet;
  TxDS=TDataSource;
  TStrArray = class
    function Find(Aranan: string; Arr: TArray<string>): Boolean;
  end;

type
  PCInfo = class
    class function BilgisayarAdi: string;
    class function MacAdresi: string;
    class function WindowsKullaniciAdi: string;
  end;

  TCevap<T> = class
    kod: Integer;
    hata: Boolean;
    mesaj:string;
    sonuc: T;
    constructor Create;
  end;

  TLog = class
    Zaman: TDateTime;
    Aciklama: string;
    Bilgisayar: string;
    Kullanici: string;
    Tip, Ekran: string;
    procedure Ekle(LogStr: string);
  end;

  TSession = class
    SL: TStringList;
    procedure Clear;
    procedure SetValue(Alan, Deger: string);
    function GetValue(Alan: string): string;
    procedure ValueClear(Alan: string);
    constructor Create;
    destructor Destroy;
  end;

  XJson = class
    class function parse<T>(json: string): T;
    class function toJson<T>(const Obj: T): string;
    class function BasariliCevap(Mesaj: string = ''): string;
    class function HataliCevap(HataMesaj: string): string; static;
    class function toCevap(json: string): string;
  end;

  XRest = class
    class function get(url: string): string;
    class function post(url, data: string): string;
  end;
  XHTTP=class
    IdHTTP:TIdHTTP;
    LHandler:TIdSSLIOHandlerSocketOpenSSL;

    function GetString(Url:String):string;
    function GetFile(Url:string;Dosya:string):Boolean;
    function PostStream(Url:string;Data:TMemoryStream):string;
    constructor Create;
    destructor Destroy;

    function GetStream(Url:String): TMemoryStream;

    function PostString(Url, Data: String): string;
  end;
  TConfig = class
    ServerName, ServerIP, DataName, PrgDir, RunDir, RaporDir,UName,UPass: string;
    PerformansLogAktif: string;
    RestBaseURL,iniFile: string;
  end;

  TxField = class
    Size: Integer;
    Name, DataType: string;
  end;

  TxRow = class
    Name, Value: string;
  end;

  TxRows = TArray<TxRow>;

  TJsonData = class
    TabloAd:string;
    Kod:Integer;
    Rows: TArray<TxRows>;
    Fields: TArray<TxField>;
  end;

  TxDb = class
    FQQ: TFDQuery;
    FTT:TFDTable;
    FCON: TFDConnection;
    function Post(Dset: TDataSet): Boolean;
    function SetFieldAndPost(Dset: TDataSet; FName: string; FValue: Variant): Boolean;
    function toJson(Dset: TFDMemTable): string;
    function parse(json: string): TFDMemTable;
    function Open(SQL: string): TDataSet;
    function Run(SQL: string): Boolean;
    constructor Create(con: TFDConnection = nil);
    function saveTable(Dset: TDataSet): Boolean;
    function GetGenID(GenId: string): Integer;
    function OpenToMem(SQL: string): TFDmemtable;
    function DataToUpdateSQL(Dset:TDataSet;TabloAd,Where:string):string;
    function Ata(SQL:String):TDataSource;
    function DataToInsetSQL(Dset: TDataSet;TabloAd:string): string;
    procedure BezerAlanlariEsle(Kaynak,Hedef:TDataSet;Haricler:string='');
    function MemToStream(Dset:TFDMemTable):TMemoryStream;
    function OpenToStream(SQL: string): TMemoryStream;

    function StreamDS(MS: TMemoryStream): TDataSource;

    procedure OpenToType(SQL: string; Obje: TObject);

    function OpenToValue(SQL: string): Variant;

    function StreamDset(MS: TMemoryStream): TDataset;

    function StreamMem(MS: TMemoryStream): TFDMemTable;

    function DataToSQL(Dset: TDataSet;TabloAd:string;Tur:string='INSERT';Where:string=''): string;
  end;

  TX = class
    json: XJson;
    rest: XRest;
    http: XHTTP;
    data: TxDb;
    session: TSession;
    strArray: TStrArray;
    conf: TConfig;
    log: TLog;
    PCName, Kullanici: string;
    constructor Create(Con: TFDConnection = nil; Config: string = 'Config.ini');
    procedure MesajVer(msg: string);
    function MesajSor(msg: string): Integer;
    procedure SetData(Con: TFDConnection);
    procedure SetConfig(ConfFile: string);
    procedure startMetod(MName: string);
    procedure finishMetod;
    procedure HataMesaj(Msg:string);
  private
    LastProcessTime: Int64;
    StartTime, FinishTime: TDateTime;
    MetodName: string;
  end;
  TDosya = class
    class function ToByteArr(Dosya: string): TByteDynArray;
    class function Sil(FName: string): Boolean;
    class function Kullanimdami(Dosya: TFileName): Boolean;
    class Function GetFileDateTime: String;
    class function SLYaz(Filename, Metin: String; UYaz: Boolean = True)
      : Boolean;
    class function OkuIsle(Filename: String;
      Proc: TFunc<string, Boolean>): Boolean;
    class function VarsayilanIleAc(FName: string): Integer;
    class function FromByteArray(AByteArray: TByteDynArray;
      var Dosya: String): Boolean;
    class function FromBase64(Base64: String; var Dosya: String): Boolean;

    class function FromBase64ToStream(Base64: String;var BS:TBytesStream): TMemoryStream; static;
  end;
  TtarTip = (tarYok, tarymd, tardmy, tarmdy);
    TTarih = class
    class function StrtoTarih(sTar: string; tarTip: TtarTip = tarYok)
      : TDateTime;
    end;

    procedure TypeToData(dataset:TDataSet;instance: TObject);
    procedure DataToType(dataset:TDataSet;instance: TObject);
    function  CreateDatasetFromType(instance: TObject) : TxMem;
    function TypeToSQL(SQL:String;instance: TObject):String;
    function TypeToFieldNames(instance: TObject):String;
    procedure TypeToType(Src,Dest: TObject);
    function TypeTipKarsilastir(Src,Dest:string):Boolean;


  {$REGION 'Prasal Foknksiyonlar'}
function Yuvarla(Sayi: Double): Double;
Function Yuv(Tip: Smallint; Sayi, Katsayi: Extended): Extended;
function DoubleToText(SS: Double): string;

function TextToDouble(SS: string): Double;
Function TextToDoubleWithSep(SS: String): Double;
function ParaFormat(X: Extended; n: Smallint): Extended;

function YuvarlaPara(Para: Extended): Extended;

function ParaToStr(Para: Double; Yuvarla: Boolean = True): string;

function StrToPara(S: string): Double;

function Yaziyacevir(Rakam: Double): string;
{$ENDREGION}
function EgerBuysa(aValue: Boolean; const ATrue: Variant;
  const AFalse: Variant): Variant;
  function DateTimeToSqlQuotedStr(Dt: TDateTime): string;
  function DateToSqlQuotedStr(Dt: TDateTime): string;
   function UnicodeKarakterDuzelt(S: string): string;
   function TitleCase(const s : string) : string;
var
  X: TX;

implementation

uses
  PJSysInfo;

{$REGION 'Para Çevirme Ýþlemleri'}

function KdvHaricTutar(Tutar, Kdv: Double): Double;
begin
  Result := Tutar / (100 + Kdv) * 100;
end;

function TextToDouble(SS: string): Double;
var
  I: Integer;
  S2, S3: string;
  C: Char;
begin
  S2 := '';
  SS := Trim(SS);
  SetLength(S3, 0);
  for I := 1 to Length(SS) do
    if CharInSet(SS[I], ['0' .. '9', '.', ',', '-']) then
    begin
      C := SS[I];
      if CharInSet(C, ['.', ',']) then
        C := FormatSettings.DecimalSeparator;
      S2 := S2 + C;

    end;

  try
    if S2 = '' then
      Result := 0
    else
      Result := StrToFloat(S2);
  except
    Result := 0;
  end;
end;

Function TextToDoubleWithSep(SS: String): Double;
var
  DecSep, ThSep: String;
begin
  SS := Trim(SS);

  if (Pos('.', SS) > 0) OR (Pos(',', SS) > 0) then
  begin
    SS := StringReplace(SS, '.', ',', []);
    SS := StringReplace(SS, ',', '.', []);

    DecSep := Copy(SS, Length(SS) - 2, 1);

    if (DecSep <> '.') and (DecSep <> ',') then
      DecSep := FormatSettings.DecimalSeparator;

    ThSep := FormatSettings.ThousandSeparator;

    if DecSep = '.' then
      ThSep := ',';
    if DecSep = ',' then
      ThSep := '.';
    SS := StringReplace(SS, ThSep, '', [rfReplaceAll]);
    SS := StringReplace(SS, DecSep, FormatSettings.DecimalSeparator,
      [rfReplaceAll]);
  end;

  Result := StrToFloatDef(SS, 0);
end;

function DoubleToText(SS: Double): string;
var
  I: Integer;
  S, S2, S3: string;
  C: Char;
begin
  S2 := '';
  S := FloatToStr(SS);
  SetLength(S3, 0);

  for I := 1 to Length(S) do
    if CharInSet(S[I], ['0' .. '9', '.', ',', '-']) then
    begin
      C := S[I];
      if CharInSet(C, ['.', ',']) then
        C := '.';
      S2 := S2 + C;
    end;

  try
    if S2 = '' then
      Result := '0'
    else
      Result := S2;
  except
    Result := '0';
  end;
end;

function Yuvarla(Sayi: Double): Double;
var
  Carp: Smallint;
  Kus: Double;
begin
  if (Sayi < 0) then
  begin
    Carp := -1;
    Sayi := Abs(Sayi);
  end
  else
    Carp := 1;
  Result := Sayi;

  if (Sayi <> 0) then
  begin
    Kus := Frac(Result);
    if (Kus >= 0.5) then
      Result := Result + 1;
    Result := Result - Kus;
  end;

  Result := Result * Carp;
end;

Function Yuv(Tip: Smallint; Sayi, Katsayi: Extended): Extended;
Begin
  Result := Sayi;
  Case Tip Of
    0:
      Result := Yuvarla(Sayi); // Sadece Tam Sayýya Yuvarla
    1:
      Begin // Normal Yuvarlama
        if (Katsayi > 0) and (Sayi > 0) Then
          Result := Yuvarla(Sayi / Katsayi) * Katsayi;
      End;
    2:
      Begin // Aþaðý Yuvarlama
        if (Katsayi > 0) and (Sayi > 0) Then
          Result := Sayi - (Frac(Sayi / Katsayi) * Katsayi);
      End;
    3:
      Begin // Yukarý Yuvarlama
        if (Katsayi > 0) and (Sayi > 0) Then
        Begin
          Result := Sayi / Katsayi;
          if (Frac(Result) > 0) Then
            Result := Result + 1;
          Result := Result - Frac(Result);
          Result := Result * Katsayi;
        End;
      End;
  End;
End;

function YuvarlaPara(Para: Extended): Extended;
begin
  Result := ParaFormat(Para, 2);
end;

function ParaFormat(X: Extended; n: Smallint): Extended;
var
  Carp: Smallint;
  a, Sayi, Tamsayi, Kusurat: Extended;
begin
  Sayi := X;
  if (Sayi < 0) then
  begin
    Carp := -1;
    Sayi := Abs(Sayi);
  end
  else
    Carp := 1;

  Tamsayi := Int(Sayi);
  Kusurat := Sayi - Tamsayi;

  if (Kusurat <> 0) then
  begin
    a := Exp(n * Ln(10));
    Kusurat := Yuvarla(Kusurat * a) / a;
  end;

  Result := Tamsayi + Kusurat;
  Result := Result * Carp;
end;

function ParaToStr(Para: Double; Yuvarla: Boolean = True): string;
begin
  if Yuvarla then
    Para := ParaFormat(Para, 2);
  Result := FloatToStr(Para);
  Result := StringReplace(Result, ',', '.', [rfReplaceAll]);
end;

function StrToPara(S: string): Double;
var
  I: Integer;
  K: string;
begin
  K := '';
  for I := 1 to S.Length do
  begin
    if CharInSet(S[I], ['0' .. '9', '.', ',']) then
      K := K + S[I];
  end;

  S := StringReplace(K, '.', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  S := StringReplace(S, ',', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  Result := StrToFloatDef(S, 0);
end;
{$ENDREGION}
procedure TypeToData(dataset:TDataSet;instance: TObject);
var
  cntx: TRttiContext;
  objField: TRttiField;
  dbFieldName,Ft: string;
  Field:TField;

  value: TValue;
begin
  cntx := TRttiContext.Create;

  for objField in cntx.GetType(instance.ClassType).GetFields do
  begin
    dbFieldName := objField.Name;
    Field:=dataset.FindField(dbFieldName);
    if Field<>nil then
    begin
      value := objField.GetValue(instance);
      Ft:=objField.FieldType.ToString;
      if (Ft='string') or (Ft='WideString') then
      Field.AsString:=value.AsString;
      if (Ft='TDate') or (Ft='TDateTime') or (Ft='Date') or (Ft='DateTime') then
      Field.Value:=value.AsVariant;
      if (Ft='Integer') OR (Ft='SmallInt') then
      Field.AsInteger:=value.AsInteger;
      if Ft='Double' then
      Field.AsFloat:=value.AsExtended;
    end;
  end;

  cntx.Free;
end;
function TypeTipKarsilastir(Src,Dest:string):Boolean;
begin

end;
procedure DataToType(dataset:TDataSet;instance: TObject);
var
  cntx: TRttiContext;
  objField: TRttiField;
  dbFieldName: string;
  Ft:string;
  I: Integer;
  value: TValue;
  Ok:Boolean;
begin
  cntx := TRttiContext.Create;
  for I := 0 to dataset.FieldCount - 1 do
  begin
    dbFieldName := dataset.Fields[I].DisplayName;
    for objField in cntx.GetType(instance.ClassType).GetFields do
    begin
      if (UpperCase(dbFieldName) = UpperCase(objField.Name)) OR (dbFieldName=objField.Name) then
      begin
        Ft:=objField.FieldType.ToString;
        Ok:=False;
        case dataset.Fields[I].DataType of
          ftString:Ok:=((Ft='string') or (Ft='WideString'));
          ftInteger,ftSmallint:Ok:=((Ft='Integer') or (Ft='SmallInt'));
          ftFloat:Ok:=((Ft='Double') or (Ft='Extended'));
          ftDate,ftDateTime:Ok:=((Ft='TDate') or (Ft='TDateTime'));
        end;

        if Ok then
        begin
          value := TValue.From(dataset.Fields[I].value);
          objField.SetValue(instance, value);
        end;
        Break;
      end;
    end;
  end;
  cntx.Free;
end;
function CreateDatasetFromType(instance: TObject) : TxMem;
var
  cntx: TRttiContext;
  objField: TRttiField;
  dbFieldName,Ft: string;
begin
  cntx := TRttiContext.Create;
  try
    Result := TxMem.Create( nil );

    for objField in cntx.GetType(instance.ClassType).GetFields do
    begin
      dbFieldName := objField.Name;
      Ft:=objField.FieldType.ToString;
      if Ft='string' then
      Result.FieldDefs.Add( dbFieldName, ftString, 200);
      if Ft='Integer' then
      Result.FieldDefs.Add( dbFieldName, ftInteger );
      if Ft='SmallInt' then
      Result.FieldDefs.Add( dbFieldName, ftSmallint );
      if Ft='Double' then
      Result.FieldDefs.Add( dbFieldName, ftFloat );
      if (Ft='Date') OR (Ft='TDate') then
      Result.FieldDefs.Add( dbFieldName, ftDate);
      if (Ft='DateTime') OR (Ft='TDateTime') then
      Result.FieldDefs.Add( dbFieldName, ftDateTime);
      if Ft='WideString' then
      Result.FieldDefs.Add( dbFieldName, ftMemo);
    end;
    Result.CreateDataSet;
  finally
    cntx.Free;
  end;
end;

function DateToSqlQuotedStr(Dt: TDateTime): string;
begin
  Result := QuotedStr(FormatDateTime('YYYY-MM-DD', Dt));
end;

function DateTimeToSqlQuotedStr(Dt: TDateTime): string;
begin
  Result := QuotedStr(FormatDateTime('YYYY-MM-DD HH:MM:SS:NN', Dt));
end;

function DoubleToSqlQuotedStr(Para: Double): string;
begin
  Result := QuotedStr(ParaToStr(Para));
end;

function EgerBuysa(aValue: Boolean; const ATrue: Variant;
  const AFalse: Variant): Variant;
begin
  if aValue then
    Result := ATrue
  else
    Result := AFalse;
end;
function TypeToSQL(SQL:String;instance: TObject):String;
var
  cntx: TRttiContext;
  objField: TRttiField;
  dbFieldName,Ft: string;
  value: TValue;
begin
  cntx := TRttiContext.Create;
  Result:=SQL;
  for objField in cntx.GetType(instance.ClassType).GetFields do
  begin
    dbFieldName := objField.Name;
    if dbFieldName <> '' then
    dbFieldName:=':'+dbFieldName;

    if Pos(dbFieldName,Result)>0 then
    begin
      value := objField.GetValue(instance);
      Ft:=objField.FieldType.ToString;
      if (Ft='string') or (Ft='WideString') then
      Result:=Result.Replace(dbFieldName,EgerBuysa(value.AsString='','NULL',QuotedStr(value.AsString)));
      if (Ft='Integer') OR (Ft='SmallInt') then
      Result:=Result.Replace(dbFieldName,IntToStr(value.AsInteger));
      if (Ft='Int64') then
      Result:=Result.Replace(dbFieldName,IntToStr(value.AsInt64));
      if Ft='Double' then
      Result:=Result.Replace(dbFieldName,ParaToStr(value.AsExtended,False));
      if Ft='TDate' then
      Result:=Result.Replace(dbFieldName,DateToSqlQuotedStr(value.AsExtended));
      if Ft='TDateTime' then
      Result:=Result.Replace(dbFieldName,DateTimeToSqlQuotedStr(value.AsExtended));
    end;
  end;

  cntx.Free;
end;

function TypeToFieldNames(instance: TObject):String;
var
  cntx: TRttiContext;
  objField: TRttiField;
  dbFieldName: string;
begin
  cntx := TRttiContext.Create;
  Result:='';
  for objField in cntx.GetType(instance.ClassType).GetFields do
  begin
    dbFieldName := objField.Name;

    if Result<>'' then Result:=Result+',';

    Result:=Result + dbFieldName;
  end;

  cntx.Free;
end;
procedure TypeToType(Src,Dest: TObject);
var
  cntx: TRttiContext;
  DestField,SrcField: TRttiField;
  FieldName,ss: string;
  I: Integer;
  value: TValue;
begin
  cntx := TRttiContext.Create;
  for SrcField in cntx.GetType(Src.ClassType).GetFields do
  begin
    FieldName := SrcField.Name;
    value := SrcField.GetValue(Src);
    for DestField in cntx.GetType(Dest.ClassType).GetFields do
    begin
      if (UpperCase(FieldName) = UpperCase(DestField.Name)) OR (FieldName=DestField.Name) then
      begin
        DestField.SetValue(Dest, value);
        Break;
      end;
    end;
  end;
  cntx.Free;
end;
{ XJson }

class function XJson.parse<T>(json: string): T;
var
  ctx: TSuperRttiContext;
  response, TmpObj: ISuperObject;
begin
  ctx := TSuperRttiContext.Create;
  try
    TmpObj := SO(json);
    Result := ctx.AsType<T>(TmpObj)
  finally
    ctx.Free;
  end;
end;

class function XJson.toJson<T>(const Obj: T): string;
var
  ctx: TSuperRttiContext;
  cls: TClass;
begin
  ctx := TSuperRttiContext.Create;
  try
    Result := ctx.AsJson<T>(Obj).AsString;
  finally
    ctx.Free;
  end;
end;

function JsonDuzenle(jsonstr: string): string;
begin
  if Pos('/', jsonstr) > 0 then
    jsonstr := jsonstr.replace('/', '');
  if Pos('\', jsonstr) > 0 then
    jsonstr := jsonstr.replace('\', '');

  jsonstr := jsonstr.Replace('}"', '}').Replace('"{', '{');
  jsonstr := jsonstr.replace(#13#10, '').Trim;
  Result := jsonstr;
end;

{ XRest }

class function XRest.get(url: string): string;
var
  TmpObj: ISuperObject;
begin
  Result := GetMetods(url);

  Result := JsonDuzenle(Result);
  TmpObj := SO(Result);
  if not Assigned(TmpObj) then
    Exit;
  if not Assigned(TmpObj.A['result']) then
    Exit;
  TmpObj := TmpObj.A['result'][0];
  Result := TmpObj.AsJSon();
end;

class function XRest.post(url, data: string): string;
var
  TmpObj: ISuperObject;
begin
  Result := PostMetods(url, data);
  Result := JsonDuzenle(Result);
  TmpObj := SO(Result);
  if not Assigned(TmpObj) then
    Exit;
  if not Assigned(TmpObj.A['result']) then
    Exit;
  TmpObj := TmpObj.A['result'][0];
  Result := TmpObj.AsJSon();
end;

function TxDb.SetFieldAndPost(Dset: TDataSet; FName: string; FValue: Variant): Boolean;
begin
  if not (Dset.State in [dsEdit, dsInsert]) then
    Dset.Edit;
  Dset.FieldByName(FName).Value := FValue;
  try
    Dset.Post;
    Result := True;
  except
    on e: Exception do
    begin
      Result := False;
      raise Exception.Create(e.Message);
    end;
  end;
end;

function TxDb.toJson(Dset: TFDMemTable): string;
var
  lStream: TStringStream;
  json,DT: string;
  Data: TJsonData;
  I, Y: Integer;
  Field: TField;
  Row:TxRow;
begin
  Dset.DisableControls;

  Data := TJsonData.Create;
  Data.TabloAd:=Dset.Name;
  Data.Kod:=Dset.Tag;
  SetLength(Data.Rows, Dset.RecordCount);
  SetLength(Data.Fields, Dset.FieldCount);
  Y := 0;
  for Field in Dset.Fields do
  begin
    Data.Fields[Y] := TxField.Create;
    Data.Fields[Y].Name := Field.FieldName;
    Data.Fields[Y].Size := Field.Size;
    Data.Fields[Y].DataType := GetEnumName(TypeInfo(TFieldType), Ord(Field.DataType));
    Inc(Y);
  end;
  Dset.First;
  I := 0;
  while not Dset.Eof do
  begin
    SetLength(Data.Rows[I], Dset.FieldCount);
    Y := 0;

    for Field in Dset.Fields do
    begin
      Row := TxRow.Create;
      Row.Name := Field.FieldName;
      if Field.IsNull=False then
      begin
        DT:=GetEnumName(TypeInfo(TFieldType), Ord(Field.DataType));
        if (Pos('string', LowerCase(DT)) > 0) then
          Row.Value:=Field.AsString;
        if (Pos('Int', DT) > 0) or (Pos('int', DT) > 0) then
          Row.Value:=IntToStr(Field.AsInteger);
        if (Pos('Date',DT) > 0) or (Pos('TimeStamp',DT)>0) then
          Row.Value:=DateToStr(Field.AsDateTime);
      end;
      Data.Rows[I][Y]:=Row;
      Inc(Y);
    end;
    Inc(I);
    Dset.Next;
  end;
  Result := X.json.toJson<TJsonData>(Data);
  Dset.EnableControls;
end;

function TxDb.Ata(SQL: String): TDataSource;
begin
  Result:=TDataSource.Create(nil);
  Result.DataSet:=OpenToMem(SQL);
end;
function TxDb.StreamDS(MS:TMemoryStream): TDataSource;
var Mem:TxMem;
begin
  Result:=TDataSource.Create(nil);
  Result.DataSet:=StreamDset(MS);
end;
function TxDb.StreamDset(MS:TMemoryStream): TDataset;
begin
  Result:=StreamMem(Ms);
end;
function TxDb.StreamMem(MS:TMemoryStream): TFDMemTable;
var Mem:TxMem;
begin
  Mem:=TFDMemTable.Create(nil);
  MS.Position:=0;
  Mem.LoadFromStream(MS);
  Result:=Mem;
end;
procedure TxDb.OpenToType(SQL: string; Obje: TObject);
var
  Dset: TDataSet;
begin
  Dset := Open(SQL);
  if Dset = nil then
    Exit;

  DataToType(Dset, Obje);
end;
procedure TxDb.BezerAlanlariEsle(Kaynak, Hedef: TDataSet;Haricler:string='');
var Field,HedefField:TField;
begin
  for Field in Kaynak.Fields do
  begin
    HedefField:=Hedef.FindField(Field.FieldName);
    if (Assigned(HedefField)) and (Pos(Field.FieldName,Haricler)<=0) then
    HedefField.Value:=Field.Value;
  end;
end;

constructor TxDb.Create(Con: TFDConnection = nil);
begin
  inherited Create;
  FCON := Con;

  FQQ := TFDQuery.Create(nil);
  FQQ.Connection := Con;
  FTT:=TFDTable.Create(nil);
  FTT.Connection:=con;
  FTT.FetchOptions.Mode:=fmManual;
end;

function TxDb.parse(json: string): TFDMemTable;
var
  lStream: TStringStream;
  I: Integer;
  JO: ISuperObject;
  Meta: TJsonData;
  Field: TxField;
  Row: TxRows;
  K: Integer;
begin
  Result := nil;
//  JO := SO(json);
//  if JO = nil then
//    Exit;
//  JO := JO.O['FDBS'];
//  if JO = nil then
//    Exit;
//  JO := JO.O['Manager'];
//  if JO = nil then
//    Exit;
//  JO := JO.A['TableList'][0];
//  if JO = nil then
//    Exit;
//
//  JO := JO.O['ColumnList'];
//  if JO = nil then
//    Exit;

  Meta := XJson.parse<TJsonData>(json);

  Result := TFDMemTable.Create(nil);
  Result.Name:=Meta.TabloAd;
  Result.Tag:=Meta.Kod;
  I := 0;
  for Field in Meta.Fields do
  begin
    if (Pos('string', LowerCase(Field.DataType)) > 0) then
      Result.FieldDefs.Add(Field.Name, ftString, Field.Size);

    if (Pos('Int', Field.DataType) > 0) or (Pos('int', Field.DataType) > 0) then
      Result.FieldDefs.Add(Field.Name, ftInteger);
    if (Pos('Date',Field.DataType) > 0) or (Pos('TimeStamp',Field.DataType)>0) then
      Result.FieldDefs.Add(Field.Name, ftDateTime);
    Inc(I);
  end;
  Result.CreateDataSet;

  for Row in Meta.Rows do
  begin
    Result.Append;
    for I := Low(Row) to High(Row) do
    begin
      case Result.Fields[I].DataType of
        ftString:
        begin
          Result.FieldByName(Row[I].Name).AsString:=Row[I].Value;
        end;
        ftDate,ftDateTime:
        begin
          Result.FieldByName(Row[I].Name).AsDateTime:=TTarih.StrtoTarih(Row[I].Value);
        end;
        ftInteger:
        begin
          Result.FieldByName(Row[I].Name).AsInteger:=StrToIntDef(Row[I].Value,0);
        end;
        ftFloat,ftCurrency:
        begin
          Result.FieldByName(Row[I].Name).AsFloat:=StrToPara(Row[I].Value);
        end
      end;

    end;
    Result.Post;
  end;

//  lStream := TStringStream.Create;
//  lStream.Position := 0;
//  lStream.WriteString(json);
//  lStream.Position := 0;
//  Result.DisableControls;
//  Result.LoadFromStream(lStream, sfJSON);

  result.EnableControls;
end;

function TxDb.Post(Dset: TDataSet): Boolean;
begin
  if (Dset.State in [dsEdit, dsInsert]) then
  try
    Dset.Post;
    Result := True;
  except
    on e: exception do
    begin
      Result := False;
      raise Exception.Create(e.Message);
    end;
  end;
end;

function TxDb.DataToInsetSQL(Dset: TDataSet;TabloAd:string): string;
var Field:TField; Alanlar,Degerler:string;
begin
  Alanlar:='';
  Degerler:='';
  for Field in Dset.Fields do
  begin
    Alanlar:=Alanlar+','+Field.FieldName;
    case Field.DataType of
      ftWideMemo,ftFixedWideChar,ftWideString,ftMemo,ftString: Degerler:=Degerler+','+QuotedStr(Field.AsString);
      ftShortint,ftLongWord,ftLargeint,ftSmallint,ftInteger,ftWord: Degerler:=Degerler+','+IntToStr(Field.AsInteger);
      ftFloat,ftCurrency: Degerler:=Degerler+','+ParaToStr(Field.AsFloat);
      ftDate: Degerler:=Degerler+','+QuotedStr(FormatDateTime('yyyy-mm-dd',Field.AsDateTime));
      ftTime: Degerler:=Degerler+','+QuotedStr(FormatDateTime('hh:nn:ss',Field.AsDateTime));
      ftDateTime: Degerler:=Degerler+','+QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss',Field.AsDateTime));
      ftTimeStamp: Degerler:=Degerler+','+QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss',Field.AsDateTime));
    end;
  end;
  Result:='INSERT INTO '+TabloAd+' ('+Trim(Copy(Alanlar,2,lENGTH(Alanlar)))+') VALUES ('+Trim(Copy(Degerler,2,lENGTH(Degerler)))+')';
end;

function TxDb.DataToUpdateSQL(Dset: TDataSet;TabloAd,Where:string): string;
var Field:TField; Alan,Degerler:string;
begin
  Alan:='';
  Degerler:='';
  for Field in Dset.Fields do
  begin
    Alan:=Field.FieldName;
    case Field.DataType of
      ftWideMemo,ftFixedWideChar,ftWideString,ftMemo,ftString: Degerler:=Degerler+','+Alan+'='+QuotedStr(Field.AsString);
      ftShortint,ftLongWord,ftLargeint,ftSmallint,ftInteger,ftWord: Degerler:=Degerler+','+Alan+'='+IntToStr(Field.AsInteger);
      ftFloat,ftCurrency: Degerler:=Degerler+','+Alan+'='+ParaToStr(Field.AsFloat);
      ftDate: Degerler:=Degerler+','+Alan+'='+QuotedStr(FormatDateTime('yyyy-mm-dd',Field.AsDateTime));
      ftTime: Degerler:=Degerler+','+Alan+'='+QuotedStr(FormatDateTime('hh:nn:ss',Field.AsDateTime));
      ftDateTime: Degerler:=Degerler+','+Alan+'='+QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss',Field.AsDateTime));
      ftTimeStamp: Degerler:=Degerler+','+Alan+'='+QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss',Field.AsDateTime));
    end;
  end;
  Result:='UPDATE '+TabloAd+' SET '+Degerler+' '+Where;
end;
function TxDb.DataToSQL(Dset: TDataSet;TabloAd:string;Tur:string='INSERT';Where:string=''): string;
var Field:TField; Alanlar,Alan,Deger,Degerler:string;  Mem:TxDset;
begin
  Alanlar:='';
  Alan:='';
  Degerler:='';
  Mem:=Open('SELECT COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='+QuotedStr(TabloAd));
  Mem.First;
  while Mem.Eof=False do
  begin
    Field:=Dset.FindField(Mem.Fields[0].AsString);
    if Assigned(Field)then
    begin
      Alan:=Field.FieldName;
      if Alanlar <> '' then
      Alan:=','+Alan;
      Alanlar:=Alanlar+Alan;
      case Field.DataType of
        ftWideMemo,ftFixedWideChar,ftWideString,ftMemo,ftString:Deger:=QuotedStr(Field.AsString);
        ftShortint,ftLongWord,ftLargeint,ftSmallint,ftInteger,ftWord: Deger:=IntToStr(Field.AsInteger);
        ftFloat,ftCurrency: Deger:=ParaToStr(Field.AsFloat);
        ftDate: Deger:=QuotedStr(FormatDateTime('yyyy-mm-dd',Field.AsDateTime));
        ftTime: Deger:=QuotedStr(FormatDateTime('hh:nn:ss',Field.AsDateTime));
        ftDateTime: Deger:=QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss',Field.AsDateTime));
        ftTimeStamp: Deger:=QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss',Field.AsDateTime));
      end;
      if Tur = 'EDIT' then
      Degerler := Degerler+ Alan + '='+Deger
      else
      begin
        if Degerler <> '' then
        Degerler:=Degerler+',';
        Degerler:=Degerler+Deger;
      end;
    end;
    Mem.Next;
  end;
  if Degerler ='' then
  begin
    Result:='';
    Exit;
  end;
  if Tur = 'EDIT' then
  Result:='UPDATE '+TabloAd+' SET '+Degerler+',:DEGERLER'+' '+Where
  else
  Result:='INSERT INTO '+TabloAd+' ('+Trim(Alanlar+',:ALANLAR')+') VALUES ('+Trim(Degerler+',:DEGERLER')+')';
end;

function TxDb.GetGenID(GenId: string): Integer;
begin
  try
    Result := Open('SELECT NEXT VALUE FOR ' + GenId).Fields[0].AsInteger;
  except
    on e:Exception do
    X.log.Ekle(e.Message);
  end;
end;
function TxDb.OpenToStream(SQL:string): TMemoryStream;
var Dset:TxMem;
begin
  Dset:=OpenToMem(SQL);
  Result:=MemToStream(Dset);
end;
function TxDb.MemToStream(Dset: TFDMemTable): TMemoryStream;
begin
  Result := TMemoryStream.Create;
  Result.Position := 0;
  Dset.SaveToStream(Result);
  Result.Position := 0;
end;

function TxDb.Open(SQL: string): TDataSet;
begin
  X.startMetod('TxDb.Open');
  try
    FQQ.Close;
    FQQ.SQL.Text := SQL;
    FQQ.Open;
    Result:=FQQ;
  except
    on e: Exception do
      X.log.Ekle(e.Message);
  end;
  x.finishMetod;
end;

function TxDb.OpenToValue(SQL: string): Variant;
var Dset:TDataSet;
begin
  Dset:=Open(SQL);
  case Dset.Fields[0].DataType of
     ftString:
        begin
          Result:=Dset.Fields[0].AsString;
        end;
        ftDate,ftDateTime:
        begin
          Result:=Dset.Fields[0].AsDateTime;
        end;
        ftInteger,ftLargeint:
        begin
          Result:=Dset.Fields[0].AsInteger;
        end;
        ftFloat,ftCurrency:
        begin
          Result:=Dset.Fields[0].AsFloat;
        end
      end;
  ;

end;

function TxDb.OpenToMem(SQL: string): TFDmemtable;
var
  I: Integer;
begin
  X.startMetod('TxDb.Open');
  try
    FQQ.Close;
    FQQ.SQL.Text := SQL;
    FQQ.Open;
  except
    on e: Exception do
    begin
      x.finishMetod;
      X.log.Ekle(e.Message);
      Exit;
    end;
  end;
  x.finishMetod;
  Result := TFDMemTable.Create(nil);
  try
    for I := 0 to FQQ.Fields.Count - 1 do
    begin
      if FQQ.Fields[I].DataType in [ftString, ftWideString, ftMemo, ftWideMemo] then
        Result.FieldDefs.Add(FQQ.Fields[I].FieldName, FQQ.Fields[I].DataType, FQQ.Fields[I].DataSize)
      else
        Result.FieldDefs.Add(FQQ.Fields[I].FieldName, FQQ.Fields[I].DataType);
    end;
    Result.CreateDataSet;

    Result.CopyDataSet(FQQ);

    if Result.RecNo > 0 then
      Result.First;
  except
    on e: Exception do
    begin
      x.HataMesaj(e.message);
    end;
  end;
end;

function TxDb.Run(SQL: string): Boolean;
begin
  Result:=False;
  X.startMetod('TxDb.Run');
  try
    FQQ.Close;
    FQQ.SQL.Text := SQL;
    FQQ.ExecSQL;
    Result:=True;
  except
    on e: Exception do
      x.HataMesaj(e.Message);
  end;
  X.finishMetod;
end;

function TxDb.saveTable(Dset: TDataSet): Boolean;
var
  SQL: string;
  lStream: TStringStream;
  json: string;
begin
  Result:=False;
  X.startMetod('TxDb.saveTable');
  X.data.FTT.Open(Dset.Name);
  if Dset.Tag > 0 then
  x.data.FTT.Edit
  else
  x.data.FTT.Append;
  x.data.FTT.CopyFields(Dset);
  try
    Result:=x.data.Post(x.data.FTT);
  except
    on e:exception do
    X.HataMesaj(e.Message);
  end;
  x.data.FTT.Close;
  x.finishMetod;
end;
{ TX }
procedure Tx.HataMesaj(Msg:string);
begin
  x.log.Ekle(Msg);
  raise Exception.Create(Msg);
end;
constructor TX.Create(Con: TFDConnection = nil; Config: string = 'Config.ini');
begin
  inherited Create;
  json := XJson.Create;
  Rest := XRest.Create;
  http:=XHTTP.Create;
  session := TSession.Create;
  strArray := TStrArray.Create;
  conf := TConfig.Create;
  SetConfig(Config);
  SetData(Con);
  log := TLog.Create;
  PCName := PCInfo.BilgisayarAdi;
end;

class function XJson.HataliCevap(HataMesaj: string): string;
var
  Cevap: TCevap<string>;
begin
  Cevap := TCevap<string>.Create;
  try
    Cevap.hata := True;
    Cevap.sonuc := HataMesaj;
    Cevap.mesaj:=HataMesaj;
    Cevap.kod := -1;

    Result := XJson.toJson<TCevap<string>>(Cevap);
  finally
    Cevap.Free;
  end;
end;

class function XJson.BasariliCevap(Mesaj: string = ''): string;
var
  Cevap: TCevap<string>;
begin
  Cevap := TCevap<string>.Create;
  try
    Cevap.hata := False;
    if Mesaj = '' then
      Mesaj := 'Ýþlem Baþarýlý';
    Cevap.mesaj :=  '';

    Cevap.sonuc:=mesaj;
    Cevap.kod := 0;

    Result := XJson.toJson<TCevap<string>>(Cevap);
  finally
    Cevap.Free;
  end;
end;

class function XJson.toCevap(json: string): string;
var Cevap:TCevap<ISuperObject>;
begin
  json := json.Replace('}"', '}').Replace('"{', '{');
  Cevap := XJson.parse<TCevap<ISuperObject>>(json);

  if cevap.hata then
  raise Exception.Create(Cevap.mesaj)
  else
  Result:=Cevap.sonuc.AsJSon;
end;

procedure TSession.Clear;
begin
  if Assigned(SL) then
    SL.Clear;
end;

procedure TSession.SetValue(Alan, Deger: string);
begin
  if not Assigned(SL) then
    Exit;
  SL.Values[Alan] := Deger;
end;

function TSession.GetValue(Alan: string): string;
begin
  if not Assigned(SL) then
    Exit;
  Result := SL.Values[Alan];
end;

procedure TSession.ValueClear(Alan: string);
begin
  if not Assigned(SL) then
    Exit;
  SL.Values[Alan] := '';
end;

constructor TSession.Create;
begin
  inherited;
  SL := TStringList.Create;
end;

destructor TSession.Destroy;
begin
  inherited;
  SL.Free;
end;

function TStrArray.Find(Aranan: string; Arr: TArray<string>): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(Arr) to High(Arr) do
  begin
    if Arr[I] = Aranan then
    begin
      Result := True;
      Break;
    end;
  end;
end;

constructor TCevap<T>.Create;
begin
  hata := False;
//  sonuc := nil;
  kod := 0;
end;

procedure TX.MesajVer(msg: string);
begin
  showmessage(msg);
end;

procedure TX.SetConfig(ConfFile: string);
var
  ini: TIniFile;
const
  section = 'CONFIG';
begin
  conf.RunDir := ExtractFilePath(ParamStr(0));

  ini := TIniFile.Create(conf.RunDir + ConfFile);
  try
    conf.ServerIP := ini.ReadString(section, 'ServerIP', '127.0.0.1');
    conf.ServerName := ini.ReadString(section, 'ServerName', '127.0.0.1');
    conf.DataName := ini.ReadString(section, 'DBName', 'DEF_DATA');
    conf.UName := ini.ReadString(section, 'DBUser', 'sa');
    conf.UPass := ini.ReadString(section, 'DBPass', '8090');

    conf.PrgDir := ini.ReadString(section, 'PrgDir', ExtractFilePath(ParamStr(0)));
    conf.RaporDir := ini.ReadString(section, 'RaporDir', '127.0.0.1');
    conf.PerformansLogAktif := ini.ReadString(section, 'PerformansLogAktif', 'HAYIR');
    conf.RestBaseURL := 'http://' + conf.ServerIP + ':8077/';//':8090/datasnap/rest/TServerMethods1/';
    conf.iniFile:=ConfFile;
  finally
    ini.Free;
  end;

end;

procedure TX.SetData(Con: TFDConnection);
var ConString:string;FCon:TFDConnection;
begin
  inherited Create;
  if Con=nil then
  begin
    FCon:=TFDConnection.Create(nil);
    if conf.UName <> '' then
    ConString:='Server='+conf.ServerName+';OSAuthent=No;Database='+conf.DataName+';User_Name='+conf.UName+';Password='+conf.UPass+';DriverID=MSSQL'
    else
    ConString:='Server='+conf.ServerName+';OSAuthent=Yes;Database='+conf.DataName+';DriverID=MSSQL';
    FCon.Open(ConString);
  end
  else
  FCon:=Con;
  data := TxDb.Create(FCon);
end;

procedure TX.finishMetod;
begin
  Application.ProcessMessages;
  FinishTime := Now;
  LastProcessTime := MilliSecondsBetween(FinishTime, StartTime);
  if x.conf.PerformansLogAktif = 'EVET' then
    log.Ekle('Performans LOG =>' + MetodName + '->Çalýþma Süresi=' + IntToStr(LastProcessTime) + ' ms.');
end;

procedure TX.startMetod(MName: string);
begin
  MetodName := MName;
  Application.ProcessMessages;
  StartTime := Now;
  if x.conf.PerformansLogAktif = 'EVET' then
    log.Ekle('Performans LOG =>' + MetodName + '->Çalýþmaya Baþladý');
end;

function TX.MesajSor(msg: string): Integer;
begin
  Result := MessageDlg(msg, mtConfirmation, mbYesNo, 0);
end;

{ TLog }

procedure TLog.Ekle(LogStr: string);
var
  LogFile: string;
  F: TextFile;
begin
  LogFile := x.conf.PrgDir + 'Log.txt';

  AssignFile(F, LogFile);

  if FileExists(LogFile) = True then
    Append(F)
  else
    Rewrite(F);
  Writeln(F, '-----------------------------------------------------');
  Writeln(F, 'Zaman = ' + DateTimeToStr(Now) + ', PC =' + X.PCName);
  Writeln(F, LogStr);
  CloseFile(F);
end;

class function PCInfo.BilgisayarAdi: string;
var
  LMDSysInfo1: TPJComputerInfo;
begin
  Result := 'Bilinmiyor';
  LMDSysInfo1 := TPJComputerInfo.Create;
  try
    Result := LMDSysInfo1.ComputerName;
  finally
    LMDSysInfo1.Free;
  end;
end;

class function PCInfo.MacAdresi: string;
var
  LMDSysInfo1: TPJComputerInfo;
begin
  Result := 'Bilinmiyor';
  LMDSysInfo1 := TPJComputerInfo.Create;
  try
    Result := LMDSysInfo1.MACAddress;
  finally
    LMDSysInfo1.Free;
  end;
end;

class function PCInfo.WindowsKullaniciAdi: string;
var
  LMDSysInfo1: TPJComputerInfo;
begin
  Result := 'Bilinmiyor';
  LMDSysInfo1 := TPJComputerInfo.Create;
  try
    Result := LMDSysInfo1.UserName;
  finally
    LMDSysInfo1.Free;
  end;
end;

function TRKarakterCevir(S: string; Tersle: Boolean = False): string;
begin
  if Tersle then
  begin
    S := ReplaceStr(S, '<C>', 'Ç');
    S := ReplaceStr(S, '<c>', 'ç');
    S := ReplaceStr(S, '<S>', 'Þ');
    S := ReplaceStr(S, '<s>', 'þ');
    S := ReplaceStr(S, '<I>', 'Ý');
    S := ReplaceStr(S, '<i>', 'ý');
    S := ReplaceStr(S, '<O>', 'Ö');
    S := ReplaceStr(S, '<o>', 'ö');
    S := ReplaceStr(S, '<G>', 'Ð');
    S := ReplaceStr(S, '<g>', 'ð');
    S := ReplaceStr(S, '<U>', 'Ü');
    S := ReplaceStr(S, '<u>', 'ü');
    S := ReplaceStr(S, '<INC>', '"');
  end
  else
  begin
    S := ReplaceStr(S, 'Ç', '<C>');
    S := ReplaceStr(S, 'ç', '<c>');
    S := ReplaceStr(S, 'Þ', '<S>');
    S := ReplaceStr(S, 'þ', '<s>');
    S := ReplaceStr(S, 'Ý', '<I>');
    S := ReplaceStr(S, 'ý', '<i>');
    S := ReplaceStr(S, 'Ö', '<O>');
    S := ReplaceStr(S, 'ö', '<o>');
    S := ReplaceStr(S, 'Ð', '<G>');
    S := ReplaceStr(S, 'ð', '<g>');
    S := ReplaceStr(S, 'Ü', '<U>');
    S := ReplaceStr(S, 'ü', '<u>');
    S := ReplaceStr(S, '"', '<INC>');
    S := ReplaceStr(S, '#$D#$A', '');
  end;
  Result := S;
end;

function YaziyacevirSayi(Rakam: Double): string;
const
  Birler: array [0 .. 9] of string = ('', 'Bir', 'Ýki', 'Üç', 'Dört', 'Beþ',
    'Altý', 'Yedi', 'Sekiz', 'Dokuz');
  Onlar: array [0 .. 9] of string = ('', 'On', 'Yirmi', 'Otuz', 'Kýrk', 'Elli',
    'Altmýþ', 'Yetmiþ', 'Seksen', 'Doksan');
var
  B: Double;
  S, s1, S2, S3: string;

  function IlkUc(Sayi: Double): string;
  var
    S: string;
  begin
    S := FormatFloat('000', Sayi);
    s1 := Birler[StrToInt(S[1])];
    if (S[1] = '1') then
      s1 := 'Yüz';
    if (S[1] > '1') then
      s1 := s1 + 'Yüz';
    S2 := Onlar[StrToInt(S[2])];
    S3 := Birler[StrToInt(S[3])];
    Result := s1 + S2 + S3;
  end;

begin
  S := FormatFloat('000000000000000', Rakam);

  B := StrToCurr(Copy(S, 1, 3));
  if (B > 0) then
    Result := IlkUc(B) + 'Trilyon';

  B := StrToCurr(Copy(S, 4, 3));
  if (B > 0) then
    Result := Result + IlkUc(B) + 'Milyar';

  B := StrToCurr(Copy(S, 7, 3));
  if (B > 0) then
    Result := Result + IlkUc(B) + 'Milyon';

  B := StrToCurr(Copy(S, 10, 3));
  if (B > 0) then
    Result := Result + IlkUc(B) + 'Bin';

  if (Length(CurrToStr(StrToCurr(S))) = 4) and (StrToCurr(S) < 2000) then
    Result := 'Bin';

  B := StrToCurr(Copy(S, 13, 3));
  Result := Result + IlkUc(B);
  // if (Result='') Then Result:='Sýfýr';
end;

function Yaziyacevir(Rakam: Double): string;
var
  Spc: string;
  KurusStr: string;
  a, Kusurat: Double;
const
  ParaDigit = 2;
  ParaAdi = 'TL';
  KurusAdi = 'KRS';
begin
  Result := '';
  KurusStr := '';

  Rakam := ParaFormat(Rakam, ParaDigit);
  Kusurat := Frac(Rakam);
  Rakam := Rakam - Kusurat;
  if (Rakam <> 0) then
    Result := YaziyacevirSayi(Rakam);

  if (Kusurat <> 0) then
  begin
    a := Exp(ParaDigit * Ln(10));
    Kusurat := Kusurat * a;
    Kusurat := Yuvarla(Kusurat);
    KurusStr := YaziyacevirSayi(Kusurat);
  end;

  if (Rakam <> 0) then
    Result := Result + ' ' + ParaAdi;

  if (Kusurat <> 0) then
  begin
    if (Result <> '') then
      Spc := ' '
    else
      Spc := '';
    Result := Result + Spc + KurusStr + ' ' + KurusAdi;
  end;

  if (Result = '') then
    Result := 'SIFIR ' + ParaAdi;
end;


{ Tdosya }
class function TDosya.Sil(FName: string): Boolean;
begin
  if FileExists(FName) then
  begin
    SetFileAttributes(Pchar(FName), faArchive);
    Result := DeleteFile(Pchar(FName));
  end
  else
    Result := True;
  if not Result then
    raise Exception.Create(FName + ' Dosyasý Silinemedi');
end;

class function TDosya.ToByteArr(Dosya: string): TByteDynArray;
var
  Content: TBytes;
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(Dosya, fmOpenRead or fmShareDenyWrite);
  try
    if FileStream.Size > 0 then
    begin
      SetLength(Content, FileStream.Size);
      FileStream.Read(Pointer(Content)^, FileStream.Size);
    end;
  finally
    if FileStream <> nil then
      FreeAndNil(FileStream);
  end;
  Result := TByteDynArray(Content);
end;

class function TDosya.FromByteArray(AByteArray: TByteDynArray;
  var Dosya: String): Boolean;
var
  Stream: TStream;
begin
  Result := False;
  Sil(Dosya);

  Stream := TFileStream.Create(Dosya, fmCreate);
  try
    Stream.WriteBuffer(Pointer(AByteArray)^, Length(AByteArray));
    Result := True;
  finally
    Stream.Free;
  end;
end;

class function TDosya.FromBase64(Base64: String; var Dosya: String): Boolean;
begin
  TBytesStream.Create(TNetEncoding.Base64.DecodeStringToBytes(Base64)).SaveToFile(Dosya);
end;
class function TDosya.FromBase64ToStream(Base64: String;var BS:TBytesStream): TMemoryStream;

begin
  Bs:=TBytesStream.Create(TNetEncoding.Base64.DecodeStringToBytes(Base64));
  Result:=TMemoryStream.Create;
  Result.Position:=0;
  BS.SaveToStream(Result);
end;

class function TDosya.Kullanimdami(Dosya: TFileName): Boolean;
var
  HFileRes: HFILE;
begin
  Result := False;
  if not FileExists(Dosya) then
    Exit;
  HFileRes := CreateFile(Pchar(Dosya), GENERIC_READ or GENERIC_WRITE, 0, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  Result := (HFileRes = INVALID_HANDLE_VALUE);
  if not Result then
    CloseHandle(HFileRes);
end;

class Function TDosya.GetFileDateTime: String;
Var
  I: Integer;
  S: String;
Begin
  Result := '';
  S := DateToStr(Date);
  For I := 1 To Length(S) Do
    if CharInSet(S[I], ['0' .. '9']) Then
      Result := Result + S[I];
  S := TimeToStr(Time);
  Result := Result + '_';
  For I := 1 To Length(S) Do
    if CharInSet(S[I], ['0' .. '9']) Then
      Result := Result + S[I];
End;

class function TDosya.SLYaz(Filename, Metin: String;
  UYaz: Boolean = True): Boolean;
var
  FF: TextFile;
begin
  try
    try
      Result := True;
      with TStringList.Create do
      begin
        if UYaz = False then
          LoadFromFile(Filename);

        Append(Metin);

        SaveToFile(Filename);
        Free;
      end;
    except
      on E: Exception do
      Begin
        Result := False;
        raise Exception.Create('Dosya Kaydetme Ýþlemi Sýrasýnda Hata Oluþtu' +
          #13 + E.Message);
      End;
    end;
  finally

  end;
end;

class function TDosya.OkuIsle(Filename: String;
  Proc: TFunc<string, Boolean>): Boolean;
var
  FF: TextFile;
  Satir: String;
begin
  Result := True;
  Try
    AssignFile(FF, Filename);
    Reset(FF);
  Except
    Result := False;
    raise Exception.Create(Filename + ' Dosyasý Açýlamadý');
  End;
  try
    While Not Eof(FF) Do
    Begin
      Readln(FF, Satir);
      if Proc(Satir) = True then
        Break;
    End;
  finally
    CloseFile(FF);
  end;
end;
class function TDosya.VarsayilanIleAc(FName: string): Integer;
begin
  Result := -1;
  if FName = '' then
    Exit;
  if FileExists(FName) = False then
    raise Exception.Create(FName + ' Dosyasý Bulunamadý.');

  Result := ShellExecute(0, 'open', Pchar(FName), nil, nil, SW_SHOWNORMAL);
end;


class function TTarih.StrtoTarih(sTar: string; tarTip: TtarTip = tarYok)
  : TDateTime;
var
  s1, S2: string;
  D, M, Y, h, n, S, ms: Word;
  a: TArray<string>;
  Tip: TtarTip;
  saatvar: Boolean;
begin
  sTar := sTar.Trim;
  if sTar = '' then
  begin
    Result := 0;
    Exit;
  end;

  Tip := tarYok;
  D := 0;
  M := 0;
  Y := 0;
  h := 0;
  n := 0;
  S := 0;
  ms := 0;
  s1 := '';
  S2 := '';
  SetLength(a, 0);
  sTar := sTar.Replace('.', '-');
  sTar := sTar.Replace('/', '-');
  sTar := sTar.Replace('T', ' ');

  saatvar := Pos(':', sTar) > 0;
  if saatvar then
  begin
    a := sTar.Split([' ']);
    s1 := a[0].Trim;
    S2 := a[1].Trim;
  end
  else
    s1 := sTar;

  if tarTip = tarYok then
  begin
    if Pos('-', sTar) > 0 then
    begin
      a := s1.Split(['-']);

      Y := StrToIntDef(a[0], 0);
      if Y > 1000 then
      begin
        Tip := tarymd;
      end
      else
      begin
        Y := StrToIntDef(a[2], 0);
        if Y > 1000 then
        begin
          Tip := tardmy;
          M := StrToIntDef(a[1], 0);
          if M > 12 then
            Tip := tarmdy;

        end;
      end;
    end;
  end
  else
    Tip := tarTip;

  case Tip of
    tarymd:
      begin
        a := s1.Split(['-']);
        Y := StrToInt(a[0]);
        M := StrToInt(a[1]);
        D := StrToInt(a[2]);
      end;
    tardmy:
      begin
        a := s1.Split(['-']);
        Y := StrToInt(a[2]);
        M := StrToInt(a[1]);
        D := StrToInt(a[0]);
      end;
    tarmdy:
      begin
        a := s1.Split(['-']);
        Y := StrToInt(a[2]);
        M := StrToInt(a[0]);
        D := StrToInt(a[1]);
      end;

  end;
  if saatvar then
  begin
    DecodeTime(StrtoTime(S2), h, n, S, ms);
  end;
  try
    if Tip = tarYok then
      Result := 0
    else
      Result := EncodeDateTime(Y, M, D, h, n, S, ms);
  except
    Result := 0;
  end;
end;
function UnicodeKarakterDuzelt(S: string): string;
begin
  Result := '';
  S := StringReplace(S, 'u011f', 'ð', [rfReplaceAll]);
  S := StringReplace(S, 'u011e', 'Ð', [rfReplaceAll]);
  S := StringReplace(S, 'u0131', 'ý', [rfReplaceAll]);
  S := StringReplace(S, 'u0130', 'Ý', [rfReplaceAll]);
  S := StringReplace(S, 'u00f6', 'ö', [rfReplaceAll]);
  S := StringReplace(S, 'u00d6', 'Ö', [rfReplaceAll]);
  S := StringReplace(S, 'u00fc', 'ü', [rfReplaceAll]);
  S := StringReplace(S, 'u00dc', 'Ü', [rfReplaceAll]);
  S := StringReplace(S, 'u015f', 'þ', [rfReplaceAll]);
  S := StringReplace(S, 'u015E', 'Þ', [rfReplaceAll]);
  S := StringReplace(S, 'u00e7', 'ç', [rfReplaceAll]);
  S := StringReplace(S, 'u00C7', 'Ç', [rfReplaceAll]);
  S := StringReplace(S, '\', '', [rfReplaceAll]);

  Result := S;
end;
constructor XHTTP.Create;
begin
  inherited Create;
  try
    IdHTTP := TIdHTTP.Create(nil);
    LHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

    IdHTTP.IOHandler := LHandler;
    IdHTTP.ConnectTimeout := 10000;

    IdHTTP.Request.Accept := 'application/json';
    IdHTTP.Request.AcceptCharSet := 'UTF-8';
    IdHTTP.Response.ContentType := 'application/json; CharSet=UTF-8';
  except

  end;
end;

function XHTTP.GetFile(Url:string;Dosya: string): Boolean;
var
  Stream: TMemoryStream;
begin
  Result := False;
  Stream := TMemoryStream.Create;
  try
    IdHTTP.Get(Url,Stream);
    Stream.SaveToFile(Dosya);
    Result := FileExists(Dosya)
  finally
    Stream.Free;
  end;
end;
function XHTTP.GetString(Url:String): string;
begin
  Result:='';
  try
    Result := UnicodeKarakterDuzelt(IdHTTP.Get(Url));
  except
  end;
end;
function XHTTP.PostStream(Url:string;Data:TMemoryStream):string;
begin
  try
    Result := IdHTTP.Post(Url, Data);
  except
    on e:Exception do
    begin
      raise Exception.Create('HATA!!'+e.Message);
    end;
  end;
end;
function XHTTP.PostString(Url:string;Data:String):string;
begin
  try
    Result := IdHTTP.Post(Url, Data);
  except
    on e:Exception do
    begin
      raise Exception.Create('HATA!!'+e.Message);
    end;
  end;
end;
function XHTTP.GetStream(Url:String):TMemoryStream;
begin
  try
    Result := TMemoryStream.Create;
    Result.Position:=0;
    IdHTTP.Get(Url, Result);
  except
    on e:Exception do
    begin
      raise Exception.Create('HATA!!'+e.Message);
    end;
  end;
end;
destructor XHTTP.Destroy;
begin
  IdHTTP.Free;
  LHandler.Free;
end;
function TitleCase(const s : string) : string;
var
   i : integer;
begin
   if s = '' then
     Result := ''
   else begin
     Result := Uppercase(s[1]);
     for i := 2 to Length(s) do
       if s[i - 1] = ' ' then
         Result := Result + Uppercase(s[i])
       else
         Result := Result + Lowercase(s[i]);
   end;
end;
initialization
  x:=tx.Create;
end.

