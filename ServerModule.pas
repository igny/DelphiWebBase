unit ServerModule;

interface

uses
  Classes, SysUtils, uniGUIServer, uniGUIMainModule, uniGUIApplication,
  uIdCustomHTTPServer, uniGUITypes, uniGUIBaseClasses, uniGUIClasses,
  uniImageList, FireDAC.Stan.StorageXML, FireDAC.Stan.StorageBin,
  FireDAC.Stan.StorageJSON, IdGlobal,variants;

type
  TUniServerModule = class(TUniGUIServerModule)
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    FDStanStorageBinLink1: TFDStanStorageBinLink;
    FDStanStorageXMLLink1: TFDStanStorageXMLLink;
    procedure UniGUIServerModuleHTTPCommand(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; var Handled: Boolean);
    procedure UniGUIServerModuleCreate(Sender: TObject);
  private

    { Private declarations }
  protected
    procedure FirstInit; override;
  public
    function GetMesaj: string;
  end;

function UniServerModule: TUniServerModule;

implementation

{$R *.dfm}

uses
  UniGUIVars, IGNY.Metods, Core.Metods, Core.Types;

function UniServerModule: TUniServerModule;
begin
  Result := TUniServerModule(UniGUIServerInstance);
end;

procedure TUniServerModule.FirstInit;
begin
  InitServerModule(Self);
end;

function TUniServerModule.GetMesaj: string;
begin
  RESULT := '{"mesaj":"kanka"}';
end;

procedure TUniServerModule.UniGUIServerModuleCreate(Sender: TObject);
begin
//  X := tx.Create;
end;

function SQLtoResponse(SQL: string; ResponseInfo: TIdHTTPResponseInfo): Boolean;
begin
  Result := False;
  try
    ResponseInfo.ResponseNo := 200;
    ResponseInfo.FreeContentStream := True;
    ResponseInfo.ContentStream := X.data.OpenToStream(SQL);
    Result := True;
  except
    on E: Exception do
    begin
      ResponseInfo.ResponseNo := 500;
      ResponseInfo.ContentText := e.Message;
    end;
  end;
end;

procedure TUniServerModule.UniGUIServerModuleHTTPCommand(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; var Handled: Boolean);
var
  Dset: TxMem;
  MS: TMemoryStream;
  SL: TStringList;
  S, F, V: string;
  Stream: TStream;
  FormJson: TFormJson;
  Fld: TJsonField;
  Kod: Integer;
  A:TArray<string>;
  Tmp:string;
  KayInfo:TKayitInfo;
begin
  if ARequestInfo.URI = '/getkart' then
  begin
    SL := TStringList.Create;
    try
      SL.Text := ARequestInfo.UnparsedParams.Replace('&', sLineBreak);
      Dset := X.data.OpenToMem('select * from get_' + SL.Values['tablo'] + '(' + SL.Values['kod'] + ')');
      Dset.Name := SL.Values['tablo'];
      Dset.Tag := StrToIntDef(SL.Values['kod'], 0);
      if Assigned(Dset) then
      begin
        AResponseInfo.ResponseNo := 200;
        AResponseInfo.ContentText := FormDataToJson(Dset);

      end
      else
      begin
        AResponseInfo.ResponseNo := 500;
        AResponseInfo.ContentText := 'Getirilecek Veri Bulunamadý';
      end;

      AResponseInfo.WriteContent;
      Handled := True;
    finally
      SL.Free;
    end;
  end;
  if ARequestInfo.URI = '/getinfo' then
  begin
    SL := TStringList.Create;
    try
      SL.Text := ARequestInfo.UnparsedParams.Replace('&', sLineBreak);
      KayInfo:=TKayitInfo.Create;
      X.data.OpenToType('select InsPc,InsTar,InsUser,UpdPc,UpdUser,UpdTar from ' + SL.Values['tablo'] + ' where Kod=' + SL.Values['kod'],KayInfo);

      if Assigned(KayInfo) then
      begin
        AResponseInfo.ResponseNo := 200;
        AResponseInfo.ContentText := x.json.toJson(kayInfo);

      end
      else
      begin
        AResponseInfo.ResponseNo := 500;
        AResponseInfo.ContentText := 'Getirilecek Veri Bulunamadý';
      end;

      AResponseInfo.WriteContent;
      Handled := True;
    finally
      SL.Free;
    end;
  end;
  if ARequestInfo.URI = '/savekart' then
  begin
    Stream := ARequestInfo.PostStream;
    if Assigned(Stream) then
    begin
      S := ReadStringFromStream(Stream, -1, IndyTextEncoding_UTF8);
    end;
    if S <> '' then
    begin
      FormJson := X.json.parse<TFormJson>(S);
      if FormJson.No > 0 then
      begin
        Kod := FormJson.No;
        S := 'UPDATE ' + FormJson.Name + ' SET @VAL Where Kod=' + IntToStr(Kod);
      end
      else
      begin
        Kod := X.data.GetGenID('seq_' + FormJson.Name);
        S := 'INSERT INTO ' + FormJson.Name + '(Kod,@FIELDS) VALUES ('+Inttostr(Kod)+',@VAL) ';
      end;
      V:='';F:='';
      for Fld in FormJson.Values do
      begin
        A:=Fld.Field.Split(['X']);
        if a[1]='Kod' then
        Continue;


        if (a[0]='STR') or (a[0]='DTE') or (a[0]='DTT') then
        Tmp:=QuotedStr(Fld.Value)
        else
        Tmp:=Fld.Value;

        if (A[1]='Adi') and (FormJson.No <= 0) then
        begin
          if X.data.OpenToValue('Select Kod from '+FormJson.Name+' where Adi='+Tmp)>0 then
          begin
            AResponseInfo.ResponseNo := 202;
            AResponseInfo.ContentText := x.json.HataliCevap(Fld.Value+' Adli Kayýt Daha Önceden Tanýmlanmýþ');
            AResponseInfo.WriteContent;
            Handled := True;
            Exit;
          end;
        end;

        if F<>'' then F:=F+',';
        if V<>'' then V:=V+',';
        if FormJson.No > 0 then
        V:=V+A[1]+'='+Tmp
        else
        begin
          V:=V+tmp;
          F:=F+A[1];
        end;
      end;
      S:=S.Replace('@VAL',V).Replace('@FIELDS',F);
      if X.data.Run(S) then
      begin
        AResponseInfo.ResponseNo := 200;
        AResponseInfo.ContentText := X.json.BasariliCevap(IntToStr(Kod));
      end
      else
      begin
        AResponseInfo.ResponseNo := 500;
        AResponseInfo.ContentText := x.json.HataliCevap('Kayýt Ýþlemi Baþarýsýz');
      end;
    end;

    AResponseInfo.WriteContent;
    Handled := True;
  end;
  if ARequestInfo.URI = '/deletekart' then
  begin
    SL := TStringList.Create;
    try
      SL.Text := ARequestInfo.UnparsedParams.Replace('&', sLineBreak);
      if X.data.Run('delete from ' + SL.Values['tablo'] + ' where Kod=' + SL.Values['kod']) then
      begin
        AResponseInfo.ResponseNo := 200;
        AResponseInfo.ContentText := x.json.BasariliCevap;
      end
      else
      begin
        AResponseInfo.ResponseNo := 201;
        AResponseInfo.ContentText := x.json.HataliCevap('Kayýt Silinemedi');
      end;

      AResponseInfo.WriteContent;
      Handled := True;
    finally
      SL.Free;
    end;
  end;
  if ARequestInfo.URI = '/getlist' then
  begin
    A:=ARequestInfo.UnparsedParams.split(['=']);
    SQLtoResponse('Select * from '+a[1], AResponseInfo);
    AResponseInfo.WriteContent;
    Handled := True;
  end;
  if ARequestInfo.URI = '/getsqldata' then
  begin
    Tmp:=ARequestInfo.QueryParams;
    SQLtoResponse(tmp, AResponseInfo);
    AResponseInfo.WriteContent;
    Handled := True;
  end;
  if ARequestInfo.URI = '/getayar' then
  begin
    Tmp:='';
    try
      Tmp:=VarToStrDef(x.data.OpenToValue('select Deger from genel_Parametre where Adi='+ARequestInfo.QueryParams),'');
      AResponseInfo.ResponseNo := 200;
    except
      AResponseInfo.ResponseNo := 500;
    end;

    AResponseInfo.ContentText := X.json.BasariliCevap(Tmp);
    AResponseInfo.WriteContent;
    Handled := True;
  end;

end;

initialization
  RegisterServerModuleClass(TUniServerModule);

end.

