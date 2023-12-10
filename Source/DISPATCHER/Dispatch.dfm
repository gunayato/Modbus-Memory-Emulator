object DispatchFrm: TDispatchFrm
  Left = 0
  Top = 0
  Caption = 'Dispatcher'
  ClientHeight = 81
  ClientWidth = 209
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 12
  object TCPServer: TIdTCPServer
    Bindings = <>
    DefaultPort = 502
    OnExecute = TCPServerExecute
    Left = 116
    Top = 24
  end
end
