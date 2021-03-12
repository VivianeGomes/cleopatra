object Form1: TForm1
  Left = 231
  Top = 214
  Width = 870
  Height = 639
  Caption = 'Simulador do Cleopatra - EC'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Memo: TAdvMemo
    Left = 0
    Top = 0
    Width = 862
    Height = 566
    Cursor = crIBeam
    Align = alClient
    BorderStyle = bsSingle
    Ctl3D = False
    TabOrder = 0
    TabStop = True
    AutoIndent = True
    GutterColor = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'COURIER NEW'
    Font.Style = []
    SelColor = clWhite
    SelBkColor = clNavy
    Lines.Strings = (
      '.code'
      'LOOP: LDA end1,I  ; Carrega elemento do vetor'
      '      ADD #0Fh    ; Adiciona a constante'
      '      STA end1,I  ; Salva no vetor'
      
        '      LDA end1    ; Carrega o Endere'#231'o de mem'#243'ria onde se encont' +
        'ra o registro'
      '      ADD #01h    ; Soma 1'
      '      STA end1    ; Salva nova posi'#231#227'o'
      '      LDA end2    ; Carrega Contador'
      '      ADD #0FFh   ; Adiciona -1'
      '      STA end2    ; Salva contador'
      '      JZ  FIM'
      '      JMP LOOP'
      'FIM:  HLT'
      '.endcode'
      ''
      ''
      '.data'
      '      vet1: DB #01h'
      '            DB #02h'
      '            DB #03h'
      '            DB #04h'
      '            DB #05h'
      '      end1: DB vet1'
      '      end2: DB #05h'
      '.enddata'
      '')
    HiddenCaret = False
    URLAware = False
    URLStyle.TextColor = clBlue
    URLStyle.BkColor = clWhite
    URLStyle.Style = [fsUnderline]
    TabSize = 4
    UndoLimit = 100
    DelErase = True
    SyntaxStyles = AdvPascalMemoStyler1
    OnChange = MemoChange
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 566
    Width = 862
    Height = 19
    Panels = <
      item
        Width = 500
      end>
  end
  object AdvPascalMemoStyler1: TAdvPascalMemoStyler
    LineComment = ';'
    MultiCommentLeft = '{'
    MultiCommentRight = '}'
    CommentStyle.TextColor = clGreen
    CommentStyle.BkColor = clWhite
    CommentStyle.Style = [fsItalic]
    NumberStyle.TextColor = clRed
    NumberStyle.BkColor = clWhite
    NumberStyle.Style = []
    AllStyles = <
      item
        KeyWords.Strings = (
          '#00h'
          '#01h'
          '#02h'
          '#03h'
          '#04h'
          '#05h'
          '#06h'
          '#07h'
          '#08h'
          '#09h'
          '#0Ah'
          '#0Bh'
          '#0Ch'
          '#0Dh'
          '#0Eh'
          '#0Fh'
          '#010h'
          '#011h'
          '#012h'
          '#013h'
          '#014h'
          '#015h'
          '#016h'
          '#017h'
          '#018h'
          '#019h'
          '#01Ah'
          '#01Bh'
          '#01Ch'
          '#01Dh'
          '#01Eh'
          '#01Fh'
          '#020h'
          '#021h'
          '#022h'
          '#023h'
          '#024h'
          '#025h'
          '#026h'
          '#027h'
          '#028h'
          '#029h'
          '#02Ah'
          '#02Bh'
          '#02Ch'
          '#02Dh'
          '#02Eh'
          '#02Fh'
          '#030h'
          '#031h'
          '#032h'
          '#033h'
          '#034h'
          '#035h'
          '#036h'
          '#037h'
          '#038h'
          '#039h'
          '#03Ah'
          '#03Bh'
          '#03Ch'
          '#03Dh'
          '#03Eh'
          '#03Fh'
          '#040h'
          '#041h'
          '#042h'
          '#043h'
          '#044h'
          '#045h'
          '#046h'
          '#047h'
          '#048h'
          '#049h'
          '#04Ah'
          '#04Bh'
          '#04Ch'
          '#04Dh'
          '#04Eh'
          '#04Fh'
          '#050h'
          '#051h'
          '#052h'
          '#053h'
          '#054h'
          '#055h'
          '#056h'
          '#057h'
          '#058h'
          '#059h'
          '#05Ah'
          '#05Bh'
          '#05Ch'
          '#05Dh'
          '#05Eh'
          '#05Fh'
          '#060h'
          '#061h'
          '#062h'
          '#063h'
          '#064h'
          '#065h'
          '#066h'
          '#067h'
          '#068h'
          '#069h'
          '#06Ah'
          '#06Bh'
          '#06Ch'
          '#06Dh'
          '#06Eh'
          '#06Fh'
          '#070h'
          '#071h'
          '#072h'
          '#073h'
          '#074h'
          '#075h'
          '#076h'
          '#077h'
          '#078h'
          '#079h'
          '#07Ah'
          '#07Bh'
          '#07Ch'
          '#07Dh'
          '#07Eh'
          '#07Fh'
          '#080h'
          '#081h'
          '#082h'
          '#083h'
          '#084h'
          '#085h'
          '#086h'
          '#087h'
          '#088h'
          '#089h'
          '#08Ah'
          '#08Bh'
          '#08Ch'
          '#08Dh'
          '#08Eh'
          '#08Fh'
          '#090h'
          '#091h'
          '#092h'
          '#093h'
          '#094h'
          '#095h'
          '#096h'
          '#097h'
          '#098h'
          '#099h'
          '#09Ah'
          '#09Bh'
          '#09Ch'
          '#09Dh'
          '#09Eh'
          '#09Fh'
          '#0A0h'
          '#0A1h'
          '#0A2h'
          '#0A3h'
          '#0A4h'
          '#0A5h'
          '#0A6h'
          '#0A7h'
          '#0A8h'
          '#0A9h'
          '#0AAh'
          '#0ABh'
          '#0ACh'
          '#0ADh'
          '#0AEh'
          '#0AFh'
          '#0B0h'
          '#0B1h'
          '#0B2h'
          '#0B3h'
          '#0B4h'
          '#0B5h'
          '#0B6h'
          '#0B7h'
          '#0B8h'
          '#0B9h'
          '#0BAh'
          '#0BBh'
          '#0BCh'
          '#0BDh'
          '#0BEh'
          '#0BFh'
          '#0C0h'
          '#0C1h'
          '#0C2h'
          '#0C3h'
          '#0C4h'
          '#0C5h'
          '#0C6h'
          '#0C7h'
          '#0C8h'
          '#0C9h'
          '#0CAh'
          '#0CBh'
          '#0CCh'
          '#0CDh'
          '#0CEh'
          '#0CFh'
          '#0D0h'
          '#0D1h'
          '#0D2h'
          '#0D3h'
          '#0D4h'
          '#0D5h'
          '#0D6h'
          '#0D7h'
          '#0D8h'
          '#0D9h'
          '#0DAh'
          '#0DBh'
          '#0DCh'
          '#0DDh'
          '#0DEh'
          '#0DFh'
          '#0E0h'
          '#0E1h'
          '#0E2h'
          '#0E3h'
          '#0E4h'
          '#0E5h'
          '#0E6h'
          '#0E7h'
          '#0E8h'
          '#0E9h'
          '#0EAh'
          '#0EBh'
          '#0ECh'
          '#0EDh'
          '#0EEh'
          '#0EFh'
          '#0F0h'
          '#0F1h'
          '#0F2h'
          '#0F3h'
          '#0F4h'
          '#0F5h'
          '#0F6h'
          '#0F7h'
          '#0F8h'
          '#0F9h'
          '#0FAh'
          '#0FBh'
          '#0FCh'
          '#0FDh'
          '#0FEh'
          '#0FFh')
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clActiveCaption
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        BGColor = clWhite
        StyleType = stKeyword
        Bracket = #0
        Symbols = '#'
        Info = 'Numbers'
      end
      item
        KeyWords.Strings = (
          '.code'
          '.endcode'
          '.data'
          '.enddata')
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clTeal
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = [fsItalic]
        BGColor = clWhite
        StyleType = stKeyword
        Bracket = #0
        Info = 'Reserved Words'
      end
      item
        KeyWords.Strings = (
          'NOT'
          'STA'
          'LDA'
          'ADD'
          'OR'
          'AND'
          'JMP'
          'JC'
          'JV'
          'JN'
          'JZ'
          'JSR'
          'RTS'
          'HLT'
          'DB'
          'ORG')
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clNavy
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = [fsBold]
        BGColor = clWhite
        StyleType = stKeyword
        Bracket = #0
        Info = 'Cleopatra Definition'
      end
      item
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        BGColor = clWhite
        StyleType = stSymbol
        Bracket = #0
        Symbols = ' ,;:(){}[]=-*/^%<>'
        Info = 'Symbols Delimiters'
      end>
    Left = 704
    Top = 456
  end
  object MainMenu1: TMainMenu
    Left = 744
    Top = 456
    object Arquivo1: TMenuItem
      Caption = 'Arquivo'
      object Abrir1: TMenuItem
        Caption = 'Abrir'
        OnClick = Abrir1Click
      end
      object Salvar1: TMenuItem
        Caption = 'Salvar'
        OnClick = Salvar1Click
      end
      object SalvarComo1: TMenuItem
        Caption = 'Salvar Como'
        OnClick = SalvarComo1Click
      end
      object Fechar1: TMenuItem
        Caption = 'Fechar'
        OnClick = Fechar1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Sair1: TMenuItem
        Caption = 'Sair'
        OnClick = Sair1Click
      end
    end
    object Cleopatra1: TMenuItem
      Caption = 'Cleopatra'
      object Make1: TMenuItem
        Caption = 'Make'
        ShortCut = 16504
        OnClick = Make1Click
      end
      object Run1: TMenuItem
        Caption = 'Run'
        ShortCut = 120
        OnClick = Run1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Save1: TMenuItem
        Caption = 'Save Object'
        Enabled = False
        OnClick = Save1Click
      end
    end
    object Sobre1: TMenuItem
      Caption = 'Sobre'
      OnClick = Sobre1Click
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'CleoASM|*.asm'
    Options = [ofHideReadOnly, ofCreatePrompt, ofEnableSizing]
    Left = 832
    Top = 536
  end
  object SaveDialog1: TSaveDialog
    Filter = 'CleoASM|*.asm'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 800
    Top = 536
  end
  object SaveDialog2: TSaveDialog
    Filter = 'CleoOBJ|*.txt'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 768
    Top = 536
  end
end
