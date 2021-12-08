unit UnitAyar;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, WebBase.List, uniGUIBaseClasses,
  uniGUIClasses, uniImageList, uniImage, uniEdit, uniBasicGrid, uniDBGrid,
  uniButton, uniBitBtn, uniSpeedButton, uniPanel,data.db;

type
  TFrmAyar = class(TFrmWebBaseList)
    procedure UniFormCreate(Sender: TObject);
    procedure UniFormShow(Sender: TObject);
  private
    procedure AyarfterPost(DataSet: TDataSet);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmAyar: TFrmAyar;

implementation

{$R *.dfm}
procedure TFrmAyar.AyarfterPost(DataSet: TDataSet);
begin

end;
procedure TFrmAyar.UniFormCreate(Sender: TObject);
begin
  inherited;
  FView:='AYAR_LISTE_VIEW';
end;

procedure TFrmAyar.UniFormShow(Sender: TObject);
begin
  inherited;
  GridList.DataSource.DataSet.AfterPost:=AyarfterPost;
  GridList.Columns.ColumnFromFieldName('Kod').Visible:=False;
  GridList.Columns.ColumnFromFieldName('Adi').Visible:=False;
  GridList.Columns.ColumnFromFieldName('Aciklama').ReadOnly:=True;
end;

end.
