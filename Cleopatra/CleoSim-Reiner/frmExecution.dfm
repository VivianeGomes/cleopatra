object execution: Texecution
  Left = 297
  Top = 195
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Cleopatra Execu'#231#227'o'
  ClientHeight = 564
  ClientWidth = 663
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 2
    Top = 0
    Width = 255
    Height = 249
    Caption = 'Program Data'
    TabOrder = 0
    object ProgramData: TStringGrid
      Left = 8
      Top = 16
      Width = 145
      Height = 225
      ColCount = 3
      DefaultColWidth = 40
      DefaultRowHeight = 18
      FixedCols = 0
      Options = [goFixedHorzLine, goHorzLine, goRowSelect]
      TabOrder = 0
      ColWidths = (
        32
        32
        54)
    end
    object MachineCode: TStringGrid
      Left = 160
      Top = 16
      Width = 86
      Height = 225
      ColCount = 2
      DefaultColWidth = 40
      DefaultRowHeight = 18
      FixedCols = 0
      Options = [goFixedHorzLine, goHorzLine, goRowSelect]
      ScrollBars = ssNone
      TabOrder = 1
    end
  end
  object GroupBox2: TGroupBox
    Left = 424
    Top = 0
    Width = 233
    Height = 249
    Caption = 'Data Memory'
    TabOrder = 1
    object DataMemory: TXStringGrid
      Left = 8
      Top = 16
      Width = 217
      Height = 225
      ColCount = 3
      DefaultRowHeight = 18
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
      TabOrder = 0
      FixedLineColor = clBlack
      Columns = <
        item
          HeaderFont.Charset = DEFAULT_CHARSET
          HeaderFont.Color = clWindowText
          HeaderFont.Height = -11
          HeaderFont.Name = 'MS Sans Serif'
          HeaderFont.Style = []
          Width = 98
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          EditorInheritsCellProps = False
        end
        item
          HeaderFont.Charset = DEFAULT_CHARSET
          HeaderFont.Color = clWindowText
          HeaderFont.Height = -11
          HeaderFont.Name = 'MS Sans Serif'
          HeaderFont.Style = []
          Width = 47
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          EditorInheritsCellProps = False
        end
        item
          HeaderFont.Charset = DEFAULT_CHARSET
          HeaderFont.Color = clWindowText
          HeaderFont.Height = -11
          HeaderFont.Name = 'MS Sans Serif'
          HeaderFont.Style = []
          Width = 43
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          EditorInheritsCellProps = False
        end>
      OnCellProps = DataMemoryCellProps
      MultiLine = False
      ImmediateEditMode = False
      ColWidths = (
        98
        47
        43)
    end
  end
  object GroupBox3: TGroupBox
    Left = 264
    Top = 0
    Width = 153
    Height = 185
    Caption = 'Registradores'
    TabOrder = 2
    object Regs: TValueListEditor
      Left = 8
      Top = 16
      Width = 137
      Height = 137
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goAlwaysShowEditor, goThumbTracking]
      Strings.Strings = (
        'AC='
        'PC='
        'RS='
        'MAR='
        'MDR='
        'IR=')
      TabOrder = 0
      TitleCaptions.Strings = (
        'Registrador'
        'Valor')
      ColWidths = (
        63
        68)
    end
    object Negative: TCheckBox
      Left = 8
      Top = 160
      Width = 33
      Height = 17
      Caption = 'N'
      TabOrder = 1
    end
    object Overflow: TCheckBox
      Left = 112
      Top = 160
      Width = 33
      Height = 17
      Caption = 'V'
      TabOrder = 2
    end
    object zero: TCheckBox
      Left = 40
      Top = 160
      Width = 33
      Height = 17
      Caption = 'Z'
      TabOrder = 3
    end
    object Carry: TCheckBox
      Left = 80
      Top = 160
      Width = 33
      Height = 17
      Caption = 'C'
      TabOrder = 4
    end
  end
  object btnReset: TButton
    Left = 264
    Top = 192
    Width = 49
    Height = 25
    Caption = 'Reset'
    TabOrder = 3
    OnClick = btnResetClick
  end
  object btnPasso: TButton
    Left = 360
    Top = 192
    Width = 57
    Height = 25
    Caption = 'Passo'
    TabOrder = 4
    OnClick = btnPassoClick
  end
  object MicroInstructionSimulation: TStringGrid
    Left = 0
    Top = 256
    Width = 657
    Height = 305
    ColCount = 17
    DefaultColWidth = 30
    DefaultRowHeight = 18
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    TabOrder = 5
    ColWidths = (
      30
      40
      41
      42
      39
      30
      30
      30
      30
      40
      29
      26
      24
      23
      30
      50
      81)
  end
  object TrackBar1: TTrackBar
    Left = 263
    Top = 225
    Width = 90
    Height = 24
    TabOrder = 6
    ThumbLength = 10
  end
  object btnRodar: TButton
    Left = 360
    Top = 223
    Width = 57
    Height = 25
    Caption = 'Rodar'
    TabOrder = 7
    OnClick = btnRodarClick
  end
  object btnParar: TButton
    Left = 360
    Top = 223
    Width = 57
    Height = 25
    Caption = 'Parar'
    TabOrder = 8
    Visible = False
    OnClick = btnPararClick
  end
  object chkMicro: TCheckBox
    Left = 608
    Top = 240
    Width = 49
    Height = 17
    Caption = 'Micro'
    TabOrder = 9
    OnClick = chkMicroClick
  end
end
