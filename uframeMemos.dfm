object frameMemos: TframeMemos
  Left = 0
  Top = 0
  Width = 581
  Height = 441
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -9
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object Splitter1: TSplitter
    Left = 0
    Top = 284
    Width = 581
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    Color = clMoneyGreen
    ParentColor = False
  end
  object gboxScripts: TGroupBox
    Left = 0
    Top = 32
    Width = 581
    Height = 252
    Align = alClient
    Caption = ' Log  '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGreen
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    ExplicitTop = 46
    ExplicitHeight = 238
    object mmoScript: TMemo
      Left = 2
      Top = 15
      Width = 577
      Height = 235
      Align = alClient
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -8
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
      WordWrap = False
      ExplicitHeight = 221
    end
    object mmoFk: TMemo
      Left = 253
      Top = 31
      Width = 301
      Height = 146
      Color = clMoneyGreen
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clOlive
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      Lines.Strings = (
        'select A.RDB$RELATION_NAME,'
        'A.RDB$CONSTRAINT_NAME,'
        'A.RDB$CONSTRAINT_TYPE,'
        'B.RDB$CONST_NAME_UQ,'
        'B.RDB$UPDATE_RULE,'
        'B.RDB$DELETE_RULE,'
        'C.RDB$RELATION_NAME as FK_Table,'
        'A.RDB$INDEX_NAME,'
        'D.RDB$FIELD_NAME as FK_Field,'
        'E.RDB$FIELD_NAME as OnField,'
        'I.RDB$INDEX_TYPE'
        
          'from RDB$REF_CONSTRAINTS B, RDB$RELATION_CONSTRAINTS A, RDB$RELA' +
          'TION_CONSTRAINTS C,'
        'RDB$INDEX_SEGMENTS D, RDB$INDEX_SEGMENTS E, RDB$INDICES I'
        'where (A.RDB$CONSTRAINT_TYPE = '#39'FOREIGN KEY'#39')'
        'and (A.RDB$CONSTRAINT_NAME = B.RDB$CONSTRAINT_NAME)'
        'and (B.RDB$CONST_NAME_UQ=C.RDB$CONSTRAINT_NAME)'
        'and (C.RDB$INDEX_NAME=D.RDB$INDEX_NAME)'
        'and (A.RDB$INDEX_NAME=E.RDB$INDEX_NAME)'
        'and (A.RDB$INDEX_NAME=I.RDB$INDEX_NAME)'
        'and (A.RDB$RELATION_NAME = '#39'%s'#39')'
        'and (A.RDB$CONSTRAINT_NAME = '#39'%s'#39')'
        'AND (D.RDB$FIELD_POSITION = E.RDB$FIELD_POSITION)'
        
          'order by A.RDB$RELATION_NAME, A.RDB$CONSTRAINT_NAME, D.RDB$FIELD' +
          '_POSITION, E.RDB$FIELD_POSITION')
      ParentFont = False
      TabOrder = 1
      Visible = False
      WordWrap = False
    end
    object mmoValidFields: TMemo
      Left = 30
      Top = 84
      Width = 301
      Height = 146
      Color = clMoneyGreen
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clOlive
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      Lines.Strings = (
        '          SELECT RF.RDB$RELATION_NAME TABLENAME,'
        '                 RF.RDB$FIELD_NAME FIELDNAME,'
        '                 RF.RDB$FIELD_POSITION'
        '          FROM RDB$RELATION_FIELDS RF'
        
          '             LEFT JOIN RDB$FIELDS F ON RF.RDB$FIELD_SOURCE = F.R' +
          'DB$FIELD_NAME'
        
          '             JOIN RDB$RELATIONS R   ON RF.RDB$RELATION_NAME = R.' +
          'RDB$RELATION_NAME'
        '          WHERE F.RDB$COMPUTED_BLR IS NULL'
        '            AND F.RDB$DIMENSIONS IS NULL'
        '            AND R.RDB$VIEW_BLR IS NULL'
        '            AND RF.RDB$RELATION_NAME NOT STARTING '#39'RDB$'#39
        '            AND RF.RDB$RELATION_NAME = '#39'%s'#39
        'ORDER BY RF.RDB$FIELD_POSITION')
      ParentFont = False
      TabOrder = 2
      Visible = False
      WordWrap = False
    end
  end
  object gboxStatus: TGroupBox
    Left = 0
    Top = 287
    Width = 581
    Height = 154
    Align = alBottom
    Caption = ' Status  '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGreen
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    object mmoMessages: TRichEdit
      Left = 2
      Top = 15
      Width = 577
      Height = 137
      Align = alClient
      BorderStyle = bsNone
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      HideScrollBars = False
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
      WordWrap = False
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 581
    Height = 32
    Align = alTop
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 2
    DesignSize = (
      581
      32)
    object lblProgress: TLabel
      Left = 5
      Top = 4
      Width = 26
      Height = 11
      Caption = '0 de 0'
    end
    object btnAuto: TSpeedButton
      Tag = 1
      Left = 404
      Top = 3
      Width = 84
      Height = 25
      AllowAllUp = True
      Anchors = [akTop, akRight]
      GroupIndex = 1
      Down = True
      Caption = 'Automatico'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000FF00FFFF00FF
        FF00FFFF00FFFF00FF767474787777807E7E7E7D7D797777767474FF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF767474838282ACACADADACAFA3
        A3A0A49F9AA79E9EA59C9C848080767474FF00FFFF00FFFF00FFFF00FFFF00FF
        818181A1A0A0CBCBCC9D9A969290819696938A8B959A907E8F817ABBA4A3A495
        95747373FF00FFFF00FFFF00FF767474A3A0A1D8D5D7969289C5C2AAFEF0CED3
        C0C4ABA4CBFFFFE5D4D3C9847B6FBB9A9AA69595767474FF00FFFF00FF968F96
        7DAC7F1F6E25CFD3B2FFF4CCF3C990EFB677EFAA67EFBF86FFFBDEEEF3EB8377
        6ACAA3A4888080FF00FF767474799178269E3C2AC0524C9A49F7F3C0FFF8C9FA
        EDB8F4CF97EEB87EF2C587FFE7C6CCCBC0937870B79C9C8C8182707E6F107A1A
        29C44E40DD7028BC5069AF5EFEFFD3FEFFD3FCF8C9FFE7ACFBBD7BF0AD6FFFF7
        D98C806FC49E9E8C81821068140A8F161DB0362ABF4B26AD450E7B1B7DB067B0
        AA956A6A629D9E82967F62D1955ACFBFC5807F89C69E999788882D6E2F337B35
        0D961B15A62B438F47C0D9B8C6E0A3AFAF953A3A3C292A286E6C5BC5935FB7A9
        C0747589C9A09C9687879387928EAA8E06810C079313589F5CFFFFFFFFFFF4FF
        FFD5D0D0AF4C4D44A49879FFCF91FFEEC096897AC59FA18B8081767474AAA9A9
        1D8022018C07167F1CDDE6DAFFFFFFFFFFFAFFFFEBE7E7CA424139978873D5D5
        B7A18883BD9F9F8B8081FF00FF8C878A7FA780047A0A00860529892D9CC49EE9
        F2EAF6FAF6FFFFFEEEEECFBDC2A19C9284CEA7A98A8181FF00FFFF00FF767474
        9F989E77A5790F7B14007703006E0407680D1B7227C2DEC0E7E7D7AAA393C7A6
        A79E9090767474FF00FFFF00FFFF00FF7B7B7A9A979AABBAAB89AA8A70966D7D
        996F93A584B1B0A3B1A4A0C4AAAB9C8F8F7B7B7BFF00FFFF00FFFF00FFFF00FF
        FF00FF767474898688ABA4AABBB2BAB5AFB5B0A9ACABA1A39E97998482827674
        74FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF7674747674747A
        79797B7979767575767474FF00FFFF00FFFF00FFFF00FFFF00FF}
      ParentFont = False
    end
    object btnStopNow: TSpeedButton
      Tag = 1
      Left = 317
      Top = 3
      Width = 84
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Parar agora'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000FF00FFFF00FF
        A46769A46769A46769A46769A46769A46769A46769A46769A46769A46769A467
        69A46769A46769FF00FFFF00FFFF00FFA46769FEE9C7F4DAB5F3D5AAF2D0A0EF
        CB96EFC68BEDC182EBC17FEBC180EBC180F2C782A46769FF00FFFF00FFFF00FF
        A46769FCEACEF3DABCF2D5B1F0D0A7EECB9EEDC793EDC28BE9BD81E9BD7FE9BD
        7FEFC481A46769FF00FFFF00FFFF00FFA0675BFEEFDAF6E0C6F2DABCF2D5B2EF
        D0A9EECB9EEDC796EBC28CE9BD82E9BD7FEFC481A46769FF00FFFF00FFFF00FF
        A0675BFFF4E5F7E5CFF4E0C5A7A5CAF2D5B1F0D0A6A49AB4EDC795EBC28AEABF
        81EFC480A46769FF00FFFF00FFFF00FFA7756BFFFBF0F8EADCF6E3CF0525F795
        97CF9595C70425F6EDCB9EEDC695EBC28AEFC583A46769FF00FFFF00FFFF00FF
        A7756BFFFFFCFAF0E6F8EADA5D72E50526F70526F75B6CD7F0D0A7EECB9DEBC7
        93F2C98CA46769FF00FFFF00FFFF00FFBC8268FFFFFFFEF7F2FAEFE6969FE301
        1FFA011FFA9196CFF2D4B1F0D0A7EECC9EF3CE97A46769FF00FFFF00FFFF00FF
        BC8268FFFFFFFFFEFCFCF6F00525F85E75EB5D73E50525F7F3D9BBF3D4B0F0D0
        A6F6D3A0A46769FF00FFFF00FFFF00FFD1926DFFFFFFFFFFFFFFFEFC637BF6FA
        EFE5F8EAD96075E3F6DEC4F3D9B8F4D8B1EBCFA4A46769FF00FFFF00FFFF00FF
        D1926DFFFFFFFFFFFFFFFFFFFFFEFCFCF7F0FAEFE5F8E9D9F8E7D1FBEACEDECE
        B4B6AA93A46769FF00FFFF00FFFF00FFDA9D75FFFFFFFFFFFFFFFFFFFFFFFFFF
        FEFCFCF6EFFCF3E6EDD8C9A56B5FA56B5FA56B5FA46769FF00FFFF00FFFF00FF
        DA9D75FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFBFFFEF7DAC1BAA56B5FE19E
        55E68F31B56D4DFF00FFFF00FFFF00FFE7AB79FFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFDCC7C5A56B5FF8B55CBF7A5CFF00FFFF00FFFF00FFFF00FF
        E7AB79FBF4F0FBF4EFFAF3EFFAF3EFF8F2EFF7F2EFF7F2EFD8C2C0A56B5FC183
        6CFF00FFFF00FFFF00FFFF00FFFF00FFE7AB79D1926DD1926DD1926DD1926DD1
        926DD1926DD1926DD1926DA56B5FFF00FFFF00FFFF00FFFF00FF}
      ParentFont = False
      OnClick = btnStopNowClick
    end
    object lblDesc: TLabel
      Left = 5
      Top = 15
      Width = 29
      Height = 11
      Caption = 'lblDesc'
    end
    object btnErros: TJvSpeedButton
      Tag = 1
      Left = 491
      Top = 3
      Width = 84
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Ignorar'#13#10'erros'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000FF00FFFF00FF
        FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
        FFFF00FF0005B70005B7FF00FF0005B70005B7FF00FFFF00FFFF00FFFF00FFFF
        00FFFF00FFFF00FFFF00FFFF00FFFF00FF0005B70005B7FF00FFFF00FF0005B7
        0005B70005B7FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0005
        B70005B7FF00FFFF00FFFF00FF0005B70005B60005B70005B7FF00FFFF00FFFF
        00FFFF00FFFF00FFFF00FF0005B70005B7FF00FFFF00FFFF00FFFF00FFFF00FF
        0006D70005BA0005B70005B7FF00FFFF00FFFF00FFFF00FF0005B70005B7FF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0005B70005B70005B6FF
        00FF0005B60005B70005B7FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
        FF00FFFF00FFFF00FF0005B60006C70006C70006CE0005B4FF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0006C100
        05C10006DAFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
        FF00FFFF00FFFF00FF0005B60006D70006CE0006DA0006E9FF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0006E50006DA0006D3FF
        00FFFF00FF0006E50006EFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
        FF00FF0006F80006DA0006EFFF00FFFF00FFFF00FFFF00FF0006F80006F6FF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FF0006F60006F60006F8FF00FFFF00FFFF
        00FFFF00FFFF00FFFF00FF0006F60006F6FF00FFFF00FFFF00FFFF00FF0006F6
        0006F60006F6FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
        FF0006F6FF00FFFF00FF0006F60006F60006F6FF00FFFF00FFFF00FFFF00FFFF
        00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0006F60006F6
        FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
        00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF}
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -9
      HotTrackFont.Name = 'Tahoma'
      HotTrackFont.Style = []
      Layout = blGlyphLeft
      ParentFont = False
      ParentShowHint = True
      Spacing = 4
      Transparent = True
      OnClick = btnErrosClick
    end
    object lblTempoRestante: TLabel
      Left = 130
      Top = 9
      Width = 74
      Height = 11
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'lblTempoRestante'
    end
    object edtTempoTimer: TJvSpinEdit
      Left = 206
      Top = 6
      Width = 52
      Height = 18
      ButtonKind = bkStandard
      OnBottomClick = edtTempoTimerChange
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Anchors = [akTop, akRight]
      ParentFont = False
      TabOrder = 0
      OnChange = edtTempoTimerChange
      BevelKind = bkSoft
    end
    object edtQtde: TJvSpinEdit
      Left = 260
      Top = 6
      Width = 52
      Height = 18
      ButtonKind = bkStandard
      Value = 100.000000000000000000
      OnBottomClick = edtTempoTimerChange
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Anchors = [akTop, akRight]
      ParentFont = False
      TabOrder = 1
      OnChange = edtTempoTimerChange
      BevelKind = bkSoft
    end
  end
  object timerrestante: TTimer
    OnTimer = timerrestanteTimer
    Left = 48
    Top = 40
  end
  object dbxml: TJvSimpleXML
    IndentString = '  '
    Options = [sxoAutoCreate, sxoAutoIndent, sxoAutoEncodeValue, sxoAutoEncodeEntity]
    Left = 15
    Top = 90
  end
  object cfgxml: TJvSimpleXML
    IndentString = '  '
    Options = [sxoAutoCreate, sxoAutoIndent, sxoAutoEncodeValue, sxoAutoEncodeEntity]
    Left = 15
    Top = 120
  end
  object timeralive: TTimer
    OnTimer = timeraliveTimer
    Left = 104
    Top = 40
  end
end
