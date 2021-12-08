{$define UNIGUI_VCL} // Comment out this line to turn this project into an ISAPI module

{$ifndef UNIGUI_VCL}
library
{$else}
program
{$endif}
  WebBase;

uses
  uniGUIISAPI,
  Forms,
  ServerModule in 'ServerModule.pas' {UniServerModule: TUniGUIServerModule},
  MainModule in 'MainModule.pas' {UniMainModule: TUniGUIMainModule},
  Main in 'Main.pas' {MainForm: TUniForm},
  WebBase.Form in 'WebBase.Form.pas' {FrmWebBase: TUniForm},
  WebBase.Kart in 'WebBase.Kart.pas' {FrmWebBaseKart: TUniForm},
  IGNY.Metods in '..\ORTAK\IGNY.Metods.pas',
  WebBase.List in 'WebBase.List.pas' {FrmWebBaseList: TUniForm},
  Core.Consts in 'Core.Consts.pas',
  Core.Metods in 'Core.Metods.pas',
  Core.Types in 'Core.Types.pas',
  Core.View in 'Core.View.pas',
  WebBase.Rapor in 'WebBase.Rapor.pas' {FrmWebBaseRapor: TUniForm},
  WebBase.KayitInfo in 'WebBase.KayitInfo.pas' {FrmWebBaseInfo: TUniForm},
  WebBase.Fis in 'WebBase.Fis.pas' {FrmWebBaseFis: TUniForm},
  WebBase.Ayar in 'WebBase.Ayar.pas' {FrmWebBaseAyar: TUniForm},
  UnitAyar in 'UnitAyar.pas' {FrmAyar: TUniForm};

{$R *.res}

{$ifndef UNIGUI_VCL}
exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;
{$endif}

begin
{$ifdef UNIGUI_VCL}
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
{$endif}
end.
