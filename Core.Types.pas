unit Core.Types;
{$define WEB}
interface

uses
  system.Classes, system.SysUtils,superobject,FireDAC.Stan.StorageJSON,FireDAC.Comp.Client,
  Vcl.Forms,firedac.stan.Intf,DateUtils,Vcl.StdCtrls,Vcl.ExtCtrls
  {$IFDEF  WEB}
  ,uniPanel,uniEdit,uniLabel,uniSpeedButton,uniButton,uniMemo,uniGUIApplication,uniGUIForm
//  ,Redis.Values,Redis.Client,redis.commons,Redis.NetLib.INDY
  {$ENDIF}
  ;

type
  TxPanel={$IFDEF WEB}TUniPanel{$ELSE}TPanel{$ENDIF};
  TxEdit={$IFDEF WEB}TUniEdit{$ELSE}TEdit{$ENDIF};
  TxLabel={$IFDEF WEB}TUniLabel{$ELSE}TLabel{$ENDIF};
  TxSpeedButton={$IFDEF WEB}TUniSpeedButton{$ELSE}TSpeedButton{$ENDIF};
  TxButton={$IFDEF WEB}TUniButton{$ELSE}TButton{$ENDIF};
  TxApplication={$IFDEF WEB}TUniGUIApplication{$ELSE}TApplication{$ENDIF};
  TIslemTur = (itUnKnown, itSel, itIns, itUpd, itDel);

  TJsonField=class
    Field,Value :string;
  end;

  TBase = Class
    InsTar, UpdTar: TDateTime;
    InsUser, InsPc, UpdUser, UpdPc : String;
    Kod, IslemSay, Silindi: Integer;
    ITur: TIslemTur;
  End;

  TFormJson=class
    Name:String;
    No:Integer;
    Values:TArray<TJsonField>;
    procedure AddValue(Field,Value:String;Tip:string='STR';Name:string='');

  end;
  TListeCevap=class
    Kod:Integer;
    Adi:string;
  end;
  TTKod=class
    Kod:Integer;
    Tablo:string;
  end;
  TKayitInfo=class
    InsPc,InsUser,UpdPc,UpdUser:string;
    UpdTar,InsTar:TDateTime;
  end;
//  function JsonDuzenle(jsonstr: string): string;
implementation


procedure TFormJson.AddValue(Field,Value:String;Tip:string='STR';Name:string='');
var JsonField:TJsonField;
begin
  JsonField:=TJsonField.Create;
  try
    if Pos('X',Field)>0 then
    JsonField.Field:=Field
    else
    JsonField.Field:=Tip+'X'+Field;
    if Name <> '' then
    JsonField.Field:=Field+'X'+Name;

    JsonField.Value:=Value;
    Insert(JsonField,Values,MaxInt);
  finally

  end;
end;


{ TCevap }

//
//constructor TxData.Create(Con:TFDConnection);
//begin
//  inherited;
//  {$IFDEF useredis}
//  FRedis:=NewRedisClient;
//  {$ENDIF}
//end;
//
//

end.
