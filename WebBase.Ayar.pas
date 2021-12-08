unit WebBase.Ayar;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, WebBase.Form, uniGUIBaseClasses,
  uniGUIClasses, uniBasicGrid, uniDBGrid, uniDBVerticalGrid, uniButton,
  uniBitBtn, uniSpeedButton, uniPanel, uniImageList, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.Stan.StorageBin, uniScrollBox;

type
  TFrmWebBaseAyar = class(TFrmWebBase)
    UniNativeImageList1: TUniNativeImageList;
    PnlBtn: TUniPanel;
    BtnKaydet: TUniSpeedButton;
    BtnSil: TUniSpeedButton;
    BtnKapat: TUniSpeedButton;
    BtnInfo: TUniSpeedButton;
    Ayar: TFDMemTable;
    DsAyar: TDataSource;
    AyarAdi: TStringField;
    AyarAciklama: TStringField;
    AyarKod: TIntegerField;
    AyarDeger: TStringField;
    UniScrollBox1: TUniScrollBox;
    procedure BtnKapatClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmWebBaseAyar: TFrmWebBaseAyar;

implementation

{$R *.dfm}

procedure TFrmWebBaseAyar.BtnKapatClick(Sender: TObject);
begin
  inherited;
  close;
end;

end.
