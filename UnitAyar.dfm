inherited FrmAyar: TFrmAyar
  Caption = 'FrmAyar'
  OnCreate = UniFormCreate
  PixelsPerInch = 96
  TextHeight = 14
  inherited GridList: TUniDBGrid
    RowEditor = True
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgTitleClick, dgAutoRefreshRow, dgDontReloadAfterEdit]
    WebOptions.PageSize = 1000
    WebOptions.AppendPosition = tpCurrentRow
    BufferedStore.Enabled = True
    ForceFit = True
    OnDblClick = nil
  end
end
