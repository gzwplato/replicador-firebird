object dlgIgnorarErros: TdlgIgnorarErros
  Left = 915
  Top = 332
  Width = 224
  Height = 159
  BorderStyle = bsSizeToolWin
  Caption = 'Erros...'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object chkList: TJvCheckListBox
    Left = 0
    Top = 0
    Width = 208
    Height = 123
    OnClickCheck = chkListClickCheck
    Align = alClient
    BevelKind = bkSoft
    BorderStyle = bsNone
    ItemHeight = 13
    Items.Strings = (
      'Ignorar Erros de Qualquer Outro Tipo')
    TabOrder = 0
  end
end
