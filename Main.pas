unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm, uniGUIBaseClasses, uniButton,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, Vcl.StdCtrls, Vcl.Buttons, uniImageList,
  Vcl.Menus, uniMainMenu, uniSweetAlert, uniTrackBar, uniGenericControl,
  uniFieldSet, uniPanel, uniProgressBar, uniMultiItem, uniListBox,
  uniSpeedButton,  uniImage, uniEdit, uniWidgets,
  uniCalendarPanel, uniBitBtn, uniTreeView, uniTreeMenu, uniMenuButton,
  System.ImageList, Vcl.ImgList;

type
  TMainForm = class(TUniForm)
    UniTreeMenu1: TUniTreeMenu;
    UniMenuItems1: TUniMenuItems;
    anmlamalar1: TUniMenuItem;
    Filer1: TUniMenuItem;
    StokKart1: TUniMenuItem;
    CariKart1: TUniMenuItem;
    KasaKart1: TUniMenuItem;
    DepoKart1: TUniMenuItem;
    AlFaturas1: TUniMenuItem;
    SatFaturas1: TUniMenuItem;
    UniNativeImageList1: TUniNativeImageList;
    Ayarlar1: TUniMenuItem;
    UniImageListAdapter1: TUniImageListAdapter;
    procedure DepoKart1Click(Sender: TObject);
    procedure AlFaturas1Click(Sender: TObject);
    procedure Ayarlar1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, WebBase.Form, WebBase.Kart, IGNY.Metods, WebBase.List, WebBase.Rapor, Core.Metods, Core.View;

function MainForm: TMainForm;
begin
  Result := TMainForm(UniMainModule.GetFormInstance(TMainForm));
end;

procedure TMainForm.AlFaturas1Click(Sender: TObject);
var Tip:Integer;
begin
  Tip:=TWebTreeMenuNode(Sender).Tag;
  TView.OpenFis(Tip);
end;

procedure TMainForm.Ayarlar1Click(Sender: TObject);
begin
  TView.OpenAyar;
end;

procedure TMainForm.DepoKart1Click(Sender: TObject);
var Adi:string;
begin
  Adi:=TWebTreeMenuNode(Sender).Text;
  Adi:=Adi.Replace(' ','_').Replace('ý','');
  TView.OpenKart(Adi);
end;

initialization
  RegisterAppFormClass(TMainForm);

end.
