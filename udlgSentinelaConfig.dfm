object dlgSentinelaConfig: TdlgSentinelaConfig
  Left = 538
  Top = 202
  BorderStyle = bsDialog
  ClientHeight = 414
  ClientWidth = 349
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 95
    Width = 349
    Height = 141
    Align = alTop
    Caption = 'Base Origem  '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object lblInfo: TLabel
      Left = 183
      Top = 77
      Width = 134
      Height = 11
      Caption = 'Deve ser diferente de SYSDBA '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = [fsItalic]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 183
      Top = 58
      Width = 109
      Height = 11
      Caption = 'Ex. fbClient.dll | gds32.dll '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = [fsItalic]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 108
      Top = 39
      Width = 85
      Height = 11
      Caption = 'Ex. filial001 | matriz '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = [fsItalic]
      ParentFont = False
    end
    object Label7: TLabel
      Left = 24
      Top = 116
      Width = 34
      Height = 11
      Alignment = taRightJustify
      Caption = 'CharSet'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object edtPathOrigem: TLabeledEdit
      Left = 61
      Top = 16
      Width = 276
      Height = 19
      BevelKind = bkSoft
      BorderStyle = bsNone
      EditLabel.Width = 19
      EditLabel.Height = 11
      EditLabel.Caption = 'Path'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -9
      EditLabel.Font.Name = 'Tahoma'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      LabelPosition = lpLeft
      ParentFont = False
      TabOrder = 0
    end
    object edtFilialOrigem: TLabeledEdit
      Left = 61
      Top = 35
      Width = 44
      Height = 19
      BevelKind = bkSoft
      BorderStyle = bsNone
      EditLabel.Width = 51
      EditLabel.Height = 11
      EditLabel.Caption = 'Identificador'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -9
      EditLabel.Font.Name = 'Tahoma'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      LabelPosition = lpLeft
      MaxLength = 10
      ParentFont = False
      TabOrder = 1
    end
    object edtLibOrigem: TLabeledEdit
      Left = 61
      Top = 54
      Width = 120
      Height = 19
      BevelKind = bkSoft
      BorderStyle = bsNone
      EditLabel.Width = 53
      EditLabel.Height = 11
      EditLabel.Caption = 'LibraryName'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -9
      EditLabel.Font.Name = 'Tahoma'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      LabelPosition = lpLeft
      ParentFont = False
      TabOrder = 2
    end
    object edtUserOrigem: TLabeledEdit
      Left = 61
      Top = 73
      Width = 120
      Height = 19
      Hint = 
        'Usu'#225'rio de replica'#231#227'o. Deve ser o mesmo usado no Replicado Confi' +
        'g.'
      BevelKind = bkSoft
      BorderStyle = bsNone
      CharCase = ecUpperCase
      EditLabel.Width = 31
      EditLabel.Height = 11
      EditLabel.Caption = 'Usu'#225'rio'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -9
      EditLabel.Font.Name = 'Tahoma'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      LabelPosition = lpLeft
      ParentFont = False
      TabOrder = 3
    end
    object edtPassOrigem: TLabeledEdit
      Left = 61
      Top = 92
      Width = 99
      Height = 19
      Hint = 'Senha do usu'#225'rio de replica'#231#227'o.'
      BevelKind = bkSoft
      BorderStyle = bsNone
      EditLabel.Width = 26
      EditLabel.Height = 11
      EditLabel.Caption = 'Senha'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -9
      EditLabel.Font.Name = 'Tahoma'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      LabelPosition = lpLeft
      ParentFont = False
      TabOrder = 4
    end
    object edtPassSYSDBAOrigem: TLabeledEdit
      Left = 237
      Top = 92
      Width = 99
      Height = 19
      Hint = 'Senha do usu'#225'rio de admin.'
      BevelKind = bkSoft
      BorderStyle = bsNone
      EditLabel.Width = 67
      EditLabel.Height = 11
      EditLabel.Caption = 'Senha SYSDBA'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -9
      EditLabel.Font.Name = 'Tahoma'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      LabelPosition = lpLeft
      ParentFont = False
      TabOrder = 5
    end
    object cbxCharSetOrigem: TComboBox
      Left = 61
      Top = 112
      Width = 145
      Height = 19
      BevelKind = bkSoft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 11
      ParentFont = False
      TabOrder = 6
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 236
    Width = 349
    Height = 141
    Align = alTop
    Caption = 'Base Destino  '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    object Label2: TLabel
      Left = 183
      Top = 77
      Width = 134
      Height = 11
      Caption = 'Deve ser diferente de SYSDBA '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = [fsItalic]
      ParentFont = False
    end
    object Label4: TLabel
      Left = 183
      Top = 58
      Width = 109
      Height = 11
      Caption = 'Ex. fbClient.dll | gds32.dll '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = [fsItalic]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 108
      Top = 39
      Width = 85
      Height = 11
      Caption = 'Ex. filial001 | matriz '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = [fsItalic]
      ParentFont = False
    end
    object Label8: TLabel
      Left = 24
      Top = 116
      Width = 34
      Height = 11
      Alignment = taRightJustify
      Caption = 'CharSet'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object edtPathDestino: TLabeledEdit
      Left = 61
      Top = 16
      Width = 276
      Height = 19
      BevelKind = bkSoft
      BorderStyle = bsNone
      EditLabel.Width = 19
      EditLabel.Height = 11
      EditLabel.Caption = 'Path'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -9
      EditLabel.Font.Name = 'Tahoma'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      LabelPosition = lpLeft
      ParentFont = False
      TabOrder = 0
    end
    object edtFilialDestino: TLabeledEdit
      Left = 61
      Top = 35
      Width = 44
      Height = 19
      BevelKind = bkSoft
      BorderStyle = bsNone
      EditLabel.Width = 51
      EditLabel.Height = 11
      EditLabel.Caption = 'Identificador'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -9
      EditLabel.Font.Name = 'Tahoma'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      LabelPosition = lpLeft
      MaxLength = 10
      ParentFont = False
      TabOrder = 1
    end
    object edtLibDestino: TLabeledEdit
      Left = 61
      Top = 54
      Width = 120
      Height = 19
      BevelKind = bkSoft
      BorderStyle = bsNone
      EditLabel.Width = 53
      EditLabel.Height = 11
      EditLabel.Caption = 'LibraryName'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -9
      EditLabel.Font.Name = 'Tahoma'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      LabelPosition = lpLeft
      ParentFont = False
      TabOrder = 2
    end
    object edtPassDestino: TLabeledEdit
      Left = 61
      Top = 92
      Width = 99
      Height = 19
      Hint = 'Senha do usu'#225'rio de replica'#231#227'o.'
      BevelKind = bkSoft
      BorderStyle = bsNone
      EditLabel.Width = 26
      EditLabel.Height = 11
      EditLabel.Caption = 'Senha'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -9
      EditLabel.Font.Name = 'Tahoma'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      LabelPosition = lpLeft
      ParentFont = False
      TabOrder = 3
    end
    object edtUserDestino: TLabeledEdit
      Left = 61
      Top = 73
      Width = 120
      Height = 19
      Hint = 
        'Usu'#225'rio de replica'#231#227'o. Deve ser o mesmo usado no Replicado Confi' +
        'g.'
      BevelKind = bkSoft
      BorderStyle = bsNone
      CharCase = ecUpperCase
      EditLabel.Width = 31
      EditLabel.Height = 11
      EditLabel.Caption = 'Usu'#225'rio'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -9
      EditLabel.Font.Name = 'Tahoma'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      LabelPosition = lpLeft
      ParentFont = False
      TabOrder = 4
    end
    object edtPassSYSDBADestino: TLabeledEdit
      Left = 237
      Top = 92
      Width = 99
      Height = 19
      Hint = 'Senha do usu'#225'rio de admin.'
      BevelKind = bkSoft
      BorderStyle = bsNone
      EditLabel.Width = 67
      EditLabel.Height = 11
      EditLabel.Caption = 'Senha SYSDBA'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -9
      EditLabel.Font.Name = 'Tahoma'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      LabelPosition = lpLeft
      ParentFont = False
      TabOrder = 5
    end
    object cbxCharSetDestino: TComboBox
      Left = 61
      Top = 112
      Width = 145
      Height = 19
      BevelKind = bkSoft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 11
      ParentFont = False
      TabOrder = 6
    end
  end
  object GroupBox3: TGroupBox
    Left = 0
    Top = 0
    Width = 349
    Height = 95
    Align = alTop
    Caption = 'Principal'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    object Label1: TLabel
      Left = 7
      Top = 57
      Width = 51
      Height = 11
      Alignment = taRightJustify
      Caption = 'Intervalo (s)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblInfoInterval: TJvHTLabel
      Left = 138
      Top = 57
      Width = 74
      Height = 12
      Caption = 'lblInfoInterval'
    end
    object edtNome: TLabeledEdit
      Left = 61
      Top = 16
      Width = 121
      Height = 19
      BevelKind = bkSoft
      BorderStyle = bsNone
      EditLabel.Width = 25
      EditLabel.Height = 11
      EditLabel.Caption = 'Nome'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -9
      EditLabel.Font.Name = 'Tahoma'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      LabelPosition = lpLeft
      ParentFont = False
      TabOrder = 0
    end
    object edtDesc: TLabeledEdit
      Left = 61
      Top = 35
      Width = 276
      Height = 19
      BevelKind = bkSoft
      BorderStyle = bsNone
      EditLabel.Width = 39
      EditLabel.Height = 11
      EditLabel.Caption = 'Descri'#231#227'o'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -9
      EditLabel.Font.Name = 'Tahoma'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      LabelPosition = lpLeft
      ParentFont = False
      TabOrder = 1
    end
    object chkAuto: TCheckBox
      Left = 9
      Top = 72
      Width = 65
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Inicio Auto.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
    object edtIntervalo: TJvSpinEdit
      Left = 61
      Top = 54
      Width = 76
      Height = 19
      Hint = 'Tempo em segundos entre as replica'#231#245'es.'
      ButtonKind = bkStandard
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      BevelKind = bkSoft
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 377
    Width = 349
    Height = 37
    Align = alClient
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    object imgCancel: TImage
      Left = 278
      Top = 2
      Width = 69
      Height = 33
      Cursor = crHandPoint
      Align = alRight
      Center = True
      Picture.Data = {
        0A54504E474F626A65637489504E470D0A1A0A0000000D494844520000001600
        0000160806000000C4B46C3B000000097048597300000B1300000B1301009A9C
        180000000467414D410000B18E7CFB5193000004E84944415478DA8D950D4C53
        571886DF5B0B94D696A2C89FE00F0E01AD9364C18584214C33F919031DC2B0C8
        36890819E1672A4AB6646190B98A73824E9DC950888385210525641B301CA0C0
        92814316A90537260391A054816285B2EFDC52C4E18C5F727A6E4FCE7DCE77DE
        EF3DE7729813876D6DF7462D5FFEE6C66BD7A27B81BB7881D802F89DDBB02137
        A5AD2DFBFBC9C96AF33867FEF9CAC9E9B3A4ACAC4C2814D0E6E4B4BD5D5DBDFD
        3A70EB79D0508120A0343D5D2D8E89911BD4EAF1D4DCDCF8D306C3773C93A0DC
        4917974389D9D907B06A15303909585AE21F954A1B74E95250E7FFC08300FF0B
        C9C995E2E868390C06C0C202686AC25E95EAFDA33ADD394E00585F7670E87C6D
        DF3E37AC5D0BDCBB072C58002C5E8C6E95EA7A685D5DE84DE0F65C6830C76D2C
        562A4BE54AA53D3F9F85AD2D0F2ECACFFFE5DDD1D100A6823411F82D4D2A75F7
        D8B30758B70ED0EB4D704747DCCECBD384D5D686FD0E68D9FB216CFBB1B16A49
        44841C434326A8B535D0D888AB0505C89B9AAA2F055E6760CB58A07535E01D62
        6585571212004FCF277092A5BFACEC4FFFFAFA4027C0EE87A8A85A4978B81C77
        EE98A06231BDDD8A9F8B8AD06034A20528FE1150F2C57300764401A79750F6E1
        0B17E2E5585A6AE54AE0D1234020E05B5F45458FC4C64662BB79B323AFE9F434
        201201EDEDB85256869F1E3F0639E9AF0B40DC28E5CF99752368DC3BC0172E94
        550865A98888003C3C9EC059F62C587159D01C7474A0E1E24534D1225D808624
        D84DB31B67ED660E923F9A8438ED08C8038542AC0F0B03962D03A6A64CFE3107
        5B44AB454B7535AE1294C4EF3D0BEC3443E78167328FA1629EB00716854BA570
        DDB60D20ED9F828E8CA047AD46D5C4047A809E0220710CA89DCB9907E6EB01BC
        552212156EF1F3935BB9BACECCE49EEA277A7B51DEDC7C473936469AA1F5BF8C
        6782B364B2FD99BEBED916CECE56BC0C668D1994158DF5F47F42A3193FD8DA9A
        9CA7D79F7D2E58482D5F2C3E9CE4EABA9FD796F993D98949313C6C5A805C8331
        DAF8FDFB804EC7DBF2D8F0F0A7E9C3C39F3C13BC90E32CCF4AA5A7226D6C76F1
        15674774E952DE154682B791AD169023BC7D7CC091B5C01ADBCDCC73C9DDBB5F
        C70D0C249167A667C1728E1317CB6485C13259E46C9674EA98B58C3219FE205B
        0D7677F30938AC5E0D859F1F3896EDF8B8C98E5444D6AB0707CFC7F7F727DC37
        1AF59CB340B0A44C2A3DEF2B93BDC143D9569D9C304DFD2441BB1A1AF050A341
        39F02B09C185033E32BA53BC366D82F0E1C359397879A86F191AAA89ECEB5372
        3B84C2DDDFDADB9FE1B364BADAD9C1485023F59ACA4A3C26681150FF25401687
        E043F2B9120814BABB630D5951F8E08149FFD1515323F8CE1B3792B9CD40EA71
        91E898E7D6AD8044C217686AD122F4545561BCB313DF00D527807482DE9C2987
        7B2A70FC3DBAE3ADBCBCE0CEE02C73260B2DA2ADA9C1072323195C0099FB0870
        4A44E7DE332D8D07DF2A2DC504697A083857021CC0FCAF89D376203B1388B776
        73835B54142CE802EAA2DB6D8CB23F303D9DC291AAEE39407930A0107A7BC392
        0A3646997E445BAE000E12448767872C84E0B4788A78C50AB08F84BEAE0E7574
        677C0C6CE55D4177940FC1CF24F8FB7BFFADD54E250F0C7C7E19C87D0ED41C52
        7F20E388549AF192426159D8DCDC490925922857667D4CE76A7DAC8D4D6A875E
        DFD16E309CA421035E2C2CD60885BB5E95487C8B74BA3C72763B1BFC1789B0D1
        DC8D8A06C60000000049454E44AE426082}
      OnClick = imgCancelClick
    end
    object imgOk: TImage
      Left = 140
      Top = 2
      Width = 69
      Height = 33
      Cursor = crHandPoint
      Hint = 'Salvar'
      Align = alRight
      Center = True
      Picture.Data = {
        0A54504E474F626A65637489504E470D0A1A0A0000000D494844520000001600
        0000160806000000C4B46C3B000000097048597300000B1300000B1301009A9C
        180000000467414D410000B18E7CFB5193000004634944415478DA955559286E
        6B187E97CF3CCFF33CE74251BB1419CBA6248A24A2742817129123B4D64FA6EC
        38CA491145A1CC172E48A628DA174A5C986B1722F3BCD1C779DF6FFB5D38679F
        F8EAEFFFD6FFAFF5ACE77D9EF7793F494343E38FFEFEFEF68B8B8B83F6F676C9
        DDDD1D8E8E8E202020002A2A2A607777177EFEFC094F4F4FF0F8F8085A5A5A70
        777727F6FAFAFAB0B9B909E7E7E7606666A6BFB7B7775F57576707B8246F6FEF
        DA9E9E9E3FE9CFBEBE3E70737303BC0132323220383818D4EBE5E5052E2F2F61
        7575557CDBD8D880BFBF3FECECECC0D2D29278899393135C5F5F436C6CAC2421
        90DCD1D1A19C9C9C406F6FAF1A98A7A6A6B2C4C4447E7676C608D8C4C404B6B7
        B7213D3D1DECECECB8A5A525EBECEC84EFDFBFC3ECEC2CB7B0B0600F0F0F1014
        14045959597F4BCECECE4A6B6BAB8C520860474747019C9696C610FC0DD8D8D8
        18565656A0B4B4141094BBBABAB29A9A1AF1DBC8C808B7B2B262CFCFCFE0E1E1
        01B9B9B95512D2579A9B9BE5ABAB2B4EC0F6F6F6B0BFBFCF1098676666320406
        3530CAC5E3E3E3C1D6D696F9F8F870D413363636A0ABAB8B5115B8C0C5C585E5
        E7E7AB0463BC41BEBDBD8581810130353525F378727232CBCECEE63737376F8C
        353535C1CFCF0F1C1C1C3896CCAAAAAA04E3EEEE6E8EC08231E2414949894AC2
        9B142C494600014C5A1E1F1FF3B8B838C1DAD0D0F04D63C618585B5B83A7A727
        0F0B0B63B5B5B5C238349D5315D439E411CAA592F04D4A6565A500A6AE401304
        704C4C8C00462035304760264912B1E70909090C25105DD2D2D2C2B14B046302
        C6365549F88352565626DFDFDFF3D1D1512013512BA6ADADCDD11486AD45C650
        3B3132EDB5FBE865625F5E5E0E2823C3CA380113F3EAEA6A95840F29A8897C70
        7020D8928EF41006806D6D6DD1C3A244FC90390C0988FF91B960883900030303
        F11F5DA302505F5FAF9230314A5151918CE5C3E1E1A1F8601A05203EACFE8657
        86EC95F1DB9E8243A8641E8586AAFBF6ED9B4A42BD94E2E2627979799974859C
        9C1C8AEB1BA8BAE4DFED091865636D6D6D7C7C7C1C020303594343834AC23294
        C2C24279727212161717E11DA3FF64F96EFF764DA98B8E8E86C6C64695844345
        292828903196303C3C4C1D01A8D5A780118363E52C252505B00DA1A9A94925E9
        E8E82858BEBCB0B0C08786864492DE81FEAF14EA6B349127252541484808C9A2
        225714CCB63C333303A41146527480DA3CD45030FBDD5ECDF8C78F1F8C3C8A88
        88009C3D2A097B5EC199204F4F4FF38989098A2B9C9E9E325D5D5D8E73986145
        82194EAE7FEDC9385AD4E3D84DFCEBD7AF10191949C1F9C51847A1D0786A6A0A
        CCCDCD69900B461F654C7D4C531041213C3C1C70BEFF02C678CAF3F3F33457E9
        24A0612D02F011F388B5919191008E8A8A12E60D0E0E0A29642F2F2F657D7D1D
        D6D6D6A82705E3CF74054AC1910C237D434343616C6C4C21C67FE5E5E5E5CFCD
        CD8921849987D7D87E78E9E9E98933F0CB972F420A9C39CD049C8807E8301E9A
        CF78A80AF3E8DCFACC4229C439497DECEBEBAB81D527FF03A97D7E91B5601C3F
        0000000049454E44AE426082}
      OnClick = imgOkClick
    end
    object imgOkAs: TImage
      Left = 209
      Top = 2
      Width = 69
      Height = 33
      Cursor = crHandPoint
      Hint = 'Salvar como'
      Align = alRight
      Center = True
      Picture.Data = {
        0A54504E474F626A65637489504E470D0A1A0A0000000D494844520000001600
        0000160806000000C4B46C3B000000097048597300000B1300000B1301009A9C
        180000000467414D410000B18E7CFB51930000054B4944415478DA95957D4895
        6718C6AFE7F1FBA375FC40A3A559A9D8920E5A1615194DD3B2AF4D86D48488E1
        0E0D3950A16D645FB4D5621A2C10E53D3A886DE270CC4D6A228BA153CCADB9DC
        8EAE15736A4DCBD43C273D7EA6EFBBFB7EF01CDC7FDB0387F3FA7ACEEFBDEEFB
        BEAEFB88D8D8D80F8E1F3F9E3F3F3F3FD7D8D888A0A020BC78F102C9C9C93874
        E810A6A7A7313333A35E7CCDFFE377C330E0E7E7878181013C7BF60C5E5E5EE2
        E1C3877D45E6359D8E7B7D2D62DBB66D36ABD5FA36818DD6D6560F38333313BB
        77EF86FB389D4E8C8E8EE2C1830798989840585818E2E2E214F8FEFDFB905222
        E3F1EF22F2C02BC09D0E88AD5BB76AC78E1DB3306C115827A83C78F0A04E472E
        40F5919111595151C1EAF498981879F2E449D8ED76DCBD7B573756EF90EF443E
        05CE5880C8E5109B376FD6F2F2F22C7373730AECEFEFAFC05959593227274727
        A0E4521D0E87EE72B9E4F5EBD7E1EDEDADAF5DBB561616163214BEE3DF217CC7
        7BE8F8AD0BBDB59FC171E79776919292A21D3D7AD442ADD019ECEBEBCB60B167
        CF1E233B3B5B3C79F2C4E016505F055563141717335898CD66E3D4A95370DA37
        0953CCCFE28BFA1FD03D3405FB5F0DE86B6BB5898D1B376AB9B9B9162A196D6D
        6D104280D4EBE9E9E972EFDEBDFAE0E0A09C9C9C44484888BE64C91279E2C409
        A578CB962DD29AF323FCC36B31FB31E01B085C1D7D135E6129A8AAAAB289A4A4
        24EDF0E1C3AC5881F93038353555666464E8D45F693299101A1AAA9362C94EA1
        AAF4F233FD7265622726AE0183CF81AE8437D03968564EA9AEAEB689F5EBD76B
        D44B05BE7DFBB6074CBD578A1946502C5DBA540F0E0E96BB76EDC2B5D33D48DC
        D407572930324E26083F607439CD82BFCBE09A9A1A9B58B76E9D46BDB4902FF5
        8E8E0E8C8D8DB14745444484414315344C83A0EC1641CA0DD39855FA857D0957
        2530FA5CE28FD5B946E39FCBD9290683E95DD6D6D6DA4442428246B6528AD98B
        0B4727B89C9D9DD5E95A7218F8C1D6EC5F655C420B26AB80218744935F1AEC8E
        44653FFEDC02187575753641C9D3F6EFDFAFC0EC65B61D83173EE8F942C1911E
        C4C77E8FC96AE0A953E2DBB974D887577A84D040A58F8F8F02DFB871C32656AD
        5AA5EDDBB7CF4293D729852A6D04E77E7169EA3D64E68A0C0E2AC3740D30F0D4
        1B2FE5561AD32FBD6AB8A96CBF86860695DCC0C04079F3E64D9B888A8AD2280C
        16323FCE9F3FAF62BA58F174FFBBD21F1FC1F51529EDF7C69AD375404896A712
        B7E2EEEE6E79E1C205D080515F5F6F13CB962DD3280C16CE3F27292020C0037E
        39E07398BC4AE0FC660EC1860F1EBF7E0DE3AED4C50FF680C7C7C76549498902
        93FA4A111919A9A5A5A5A956141414A880700B12C26F89509F62E8B72620A3FD
        702FF88AE1949BDCE50BDA7606CF8367C37FD3E08DD2D252D58AA6A6A60A411E
        5560567CEEDC39904BE03BD9680488B7049A1D802910F6804F109598A9D3CE50
        29E4CDC4B6720F8B5DD1D3D3A314F31253608AAA4629E31EEBDCA3F8F87844CC
        7F2DD15140BB72169F8EBD6F64BC76C4E8EAEA1204323800AC907DCB5086D33D
        D1DFDF6F5CBA74091CFBE6E6669BA09E68DBB76F578A2F5EBC08D3EC4F30FFAD
        E1C3C61824645BF5E4E424D9D9D9A9F6835B258546E792591DDD67FF2BC55C31
        DF6B6969B1F1C6D2366CD8C03DC6E5CB97515454C42DD1C91D72686848A79702
        900015E9C5C3754F8E5BD1DBDBEB01D3CEB1097AB2464B5B292E2F2F074599CB
        D3A7A6A6E4F0F0B04E2049ED528A17C1FE0566C58F1E3D9267CF9E55E0F6F676
        9BA0FE54ECDCB9338FC1BC5F57AC58C1C3C1FF39BC0AF8278AAB65302DFF4AF6
        561E85A490F7427E7E3EA2A3A3DD16FACF8787488A515656C62B55D2F5D57F00
        653DB658F83DE1920000000049454E44AE426082}
      OnClick = imgOkAsClick
    end
  end
  object xml: TJvSimpleXML
    IndentString = '  '
    Options = [sxoAutoCreate, sxoAutoIndent, sxoAutoEncodeValue, sxoAutoEncodeEntity]
    Left = 312
    Top = 16
  end
  object savedlg: TSaveDialog
    DefaultExt = '.xml'
    Filter = 'Arquivo Configura'#231#227'o|*.xml|Todos|*.*'
    Left = 280
    Top = 16
  end
  object appevnt: TApplicationEvents
    OnMessage = appevntMessage
    Left = 245
    Top = 15
  end
end
