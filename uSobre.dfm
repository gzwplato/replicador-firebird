object dlgSobre: TdlgSobre
  Left = 575
  Top = 289
  BorderStyle = bsDialog
  Caption = 'Sobre'
  ClientHeight = 325
  ClientWidth = 439
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    439
    325)
  PixelsPerInch = 96
  TextHeight = 13
  object lblTit: TLabel
    Left = 18
    Top = 7
    Width = 30
    Height = 16
    Caption = 'lblTit'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 18
    Top = 27
    Width = 228
    Height = 39
    Caption = 
      'Este programa '#233' freeware.'#13#10'Desenvolvido por Ivan Hennig - ich@vi' +
      'a.com.br'#13#10'http://ich.pro.br'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Panel1: TPanel
    Left = 15
    Top = 81
    Width = 412
    Height = 240
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelInner = bvLowered
    TabOrder = 0
    object Label1: TLabel
      Left = 10
      Top = 10
      Width = 364
      Height = 210
      Caption = 
        'Componentes Usados:'#13#10'  Portable Network Graphics Delphi - Gustav' +
        'o Daud'#13#10'    http://pngdelphi.sourceforge.net/'#13#10#13#10'  JEDI Visual C' +
        'omponent Library'#13#10'    http://homepages.borland.com/jedi/jvcl/'#13#10#13 +
        #10'  Unified Interbase'#13#10'    http://www.progdigy.com/modules.php?na' +
        'me=UIB'#13#10#13#10'  Virtual Treeview - Mike Lischke'#13#10'    http://www.soft' +
        '-gems.net/'#13#10#13#10'  Este programa foi baseado na id'#233'ia do REPLICADOR' +
        'BR'#13#10'    http://sourceforge.net/projects/replicadorbr/'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
    end
  end
end
