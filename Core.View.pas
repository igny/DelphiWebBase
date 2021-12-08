unit Core.View;

interface
  uses classes,System.SysUtils,WebBase.List,uniGUIApplication,uniGUIDialogs,Core.Types,Vcl.Controls;
  type
  TView=Class
    class procedure ShowListe(View:string;CallBack: TProc<TListeCevap>);
    class procedure ShowKayitInfo(Tablo:string;Kod:Integer);
    class procedure OpenKart(Kart:string;Kod:Integer=0);
    class procedure OpenFis(Tip:Integer;Kod:Integer=0);
    class procedure OpenAyar;
  End;
implementation

uses
  Core.Metods, WebBase.KayitInfo, WebBase.Kart, WebBase.Fis, WebBase.Ayar, Main,
  UnitAyar;

{ TView }

class procedure TView.OpenAyar;
begin
  with TFrmAyar.Create(UniApplication) do
  begin
    show;
  end;
end;

class procedure TView.OpenFis(Tip, Kod: Integer);
begin
  with TFrmWebBaseFis.Create(UniApplication) do
  begin
    FTablo:='Fis';
    FTip:=Tip;
    FKod:=Kod;
    Show();
  end;
end;

class procedure TView.OpenKart(Kart: string; Kod: Integer);
begin
  with TFrmWebBaseKart.Create(UniApplication) do
  begin
    FTablo:=kart;
    FKod:=Kod;
    Show();
  end;
end;

class procedure TView.ShowKayitInfo(Tablo: string; Kod: Integer);
var KI:TKayitInfo;
begin
  KI:=TServis.GetInfo(Tablo,Kod);
  with TFrmWebBaseInfo.Create(UniApplication) do
  begin
    FKayitInfo:=KI;
    Show();
  end;
end;

class procedure TView.ShowListe(View: string; CallBack: TProc<TListeCevap>);
var Cevap:TListeCevap;
begin
  with TFrmWebBaseList.Create(UniApplication) do
  begin
    FView:=View;
    FreeOnClose:=True;
    ShowModal( procedure(Sender: TComponent; Res: Integer)
    begin
      if Res=mrOk then
      begin
        Cevap:=TListeCevap.Create;
        Cevap.Kod:=GridList.DataSource.DataSet.FieldByName('Kod').AsInteger;
        Cevap.Adi:=GridList.DataSource.DataSet.FieldByName('Adi').AsString;
        CallBack(Cevap);
      end;

    end
    );
  end;
end;


end.
