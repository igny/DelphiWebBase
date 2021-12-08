object UniServerModule: TUniServerModule
  OldCreateOrder = False
  OnCreate = UniGUIServerModuleCreate
  TempFolder = 'temp\'
  Title = 'New Application'
  SuppressErrors = []
  Bindings = <>
  SSL.SSLOptions.RootCertFile = 'root.pem'
  SSL.SSLOptions.CertFile = 'cert.pem'
  SSL.SSLOptions.KeyFile = 'key.pem'
  SSL.SSLOptions.Method = sslvTLSv1_1
  SSL.SSLOptions.SSLVersions = [sslvTLSv1_1]
  SSL.SSLOptions.Mode = sslmUnassigned
  SSL.SSLOptions.VerifyMode = []
  SSL.SSLOptions.VerifyDepth = 0
  ConnectionFailureRecovery.ErrorMessage = 'Connection Error'
  ConnectionFailureRecovery.RetryMessage = 'Retrying...'
  OnHTTPCommand = UniGUIServerModuleHTTPCommand
  Height = 150
  Width = 215
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 88
    Top = 24
  end
  object FDStanStorageBinLink1: TFDStanStorageBinLink
    Left = 88
    Top = 80
  end
  object FDStanStorageXMLLink1: TFDStanStorageXMLLink
    Left = 32
    Top = 24
  end
end
