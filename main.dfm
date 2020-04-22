object FCRC: TFCRC
  Left = 57
  Top = 165
  Width = 936
  Height = 404
  Caption = 'CRC PPP'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 69
    Width = 928
    Height = 308
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 928
    Height = 69
    Align = alTop
    TabOrder = 1
    object Hexa: TEdit
      Left = 8
      Top = 8
      Width = 913
      Height = 21
      TabOrder = 0
    end
    object Button1: TButton
      Left = 8
      Top = 40
      Width = 49
      Height = 25
      Caption = '&Calcular'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 61
      Top = 40
      Width = 49
      Height = 25
      Caption = 'C&onectar'
      Enabled = False
      TabOrder = 2
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 114
      Top = 40
      Width = 65
      Height = 25
      Caption = '&Desconectar'
      Enabled = False
      TabOrder = 3
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 184
      Top = 40
      Width = 57
      Height = 25
      Caption = 'Colocar 7D'
      TabOrder = 4
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 245
      Top = 40
      Width = 41
      Height = 25
      Caption = 'Enviar'
      TabOrder = 5
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 288
      Top = 40
      Width = 33
      Height = 25
      Caption = 'LER'
      TabOrder = 6
      OnClick = Button6Click
    end
    object edNum: TEdit
      Left = 680
      Top = 32
      Width = 233
      Height = 21
      TabOrder = 7
    end
    object Button7: TButton
      Left = 324
      Top = 40
      Width = 57
      Height = 25
      Caption = 'Calc. UDP'
      TabOrder = 8
      OnClick = Button7Click
    end
    object Button8: TButton
      Left = 384
      Top = 40
      Width = 75
      Height = 25
      Caption = 'Envia texto'
      TabOrder = 9
      OnClick = Button8Click
    end
    object Button9: TButton
      Left = 464
      Top = 40
      Width = 65
      Height = 25
      Caption = 'Calc CRC2'
      TabOrder = 10
      OnClick = Button9Click
    end
    object Button10: TButton
      Left = 535
      Top = 40
      Width = 75
      Height = 25
      Caption = '778'
      TabOrder = 11
      OnClick = Button10Click
    end
  end
  object TimeOut: TTimer
    Enabled = False
    Interval = 30000
    OnTimer = TimeOutTimer
    Left = 704
    Top = 80
  end
end
