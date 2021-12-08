object MainForm: TMainForm
  Left = 0
  Top = 0
  ClientHeight = 467
  ClientWidth = 899
  Caption = 'MainForm'
  BorderStyle = bsNone
  WindowState = wsMaximized
  FormStyle = fsMDIForm
  OldCreateOrder = False
  KeyPreview = True
  MonitoredKeys.Keys = <>
  ClientEvents.ExtEvents.Strings = (
    
      'window.afterrender=function window.afterrender (sender, eOpts)'#13#10 +
      '{'#13#10'  Ext.get (sender.id) .el.setStyle ("padding", 0);'#13#10'  Ext.get' +
      ' (sender.id) .el.setStyle ("border-width", 0);'#13#10'  Ext.get (sende' +
      'r.id) .el.setStyle ("- webkit-border-radius", 0);'#13#10'  Ext.get (se' +
      'nder.id) .el.setStyle ("- moz-border-radius", 0);'#13#10'  Ext.get (se' +
      'nder.id) .el.setStyle ("border-radius", 0);'#13#10'}')
  PixelsPerInch = 96
  TextHeight = 13
  object UniTreeMenu1: TUniTreeMenu
    Left = 0
    Top = 0
    Width = 257
    Height = 467
    Hint = ''
    Items.FontData = {0100000000}
    ScreenMask.Enabled = True
    ScreenMask.WaitData = True
    ScreenMask.Message = 'L'#252'tfen Bekleyiniz.'
    SourceMenu = UniMenuItems1
    SingleExpand = True
  end
  object UniMenuItems1: TUniMenuItems
    Images = UniNativeImageList1
    Left = 408
    Top = 104
    object anmlamalar1: TUniMenuItem
      Caption = 'Tan'#305'mlamalar'
      ImageIndex = 3
      object StokKart1: TUniMenuItem
        Caption = 'Stok Kart'#305
        ImageIndex = 7
        OnClick = DepoKart1Click
      end
      object CariKart1: TUniMenuItem
        Caption = 'Cari Kart'#305
        ImageIndex = 5
        OnClick = DepoKart1Click
      end
      object KasaKart1: TUniMenuItem
        Caption = 'Kasa Kart'#305
        ImageIndex = 6
        OnClick = DepoKart1Click
      end
      object DepoKart1: TUniMenuItem
        Caption = 'Depo Kart'#305
        ImageIndex = 4
        OnClick = DepoKart1Click
      end
    end
    object Filer1: TUniMenuItem
      Caption = 'Fi'#351'/Fatura'
      ImageIndex = 0
      object AlFaturas1: TUniMenuItem
        Tag = 10
        Caption = 'Al'#305#351' Faturas'#305
        ImageIndex = 8
        OnClick = AlFaturas1Click
      end
      object SatFaturas1: TUniMenuItem
        Tag = 35
        Caption = 'Sat'#305#351' Faturas'#305
        ImageIndex = 9
        OnClick = AlFaturas1Click
      end
    end
    object Ayarlar1: TUniMenuItem
      Caption = 'Ayarlar'
      ImageIndex = 11
      OnClick = Ayarlar1Click
    end
  end
  object UniNativeImageList1: TUniNativeImageList
    Left = 360
    Top = 192
    Images = {
      0C00000000000000060E0000006E65777370617065723B66615F3B0000000006
      0D0000006172726F775F75703B66615F3B00000000060D000000626F782D6F70
      656E3B66615F3B00000000060C00000069642D636172643B66615F3B00000000
      060A00000073746F72653B66615F3B000000000611000000757365722D667269
      656E64733B66615F3B0000000006130000006D6F6E65792D62696C6C2D616C74
      3B66615F3B00000000060C000000617263686976653B66615F3B000000000609
      000000746167733B66615F3B00000000061200000073686F7070696E672D6361
      72743B66615F3B00000000061400000073686F7070696E672D6261736B65743B
      66615F3B00000000060E0000006D6963726F636869703B66615F3B}
  end
  object UniImageListAdapter1: TUniImageListAdapter
    UniImageList = UniNativeImageList1
    Left = 360
    Top = 248
  end
end
