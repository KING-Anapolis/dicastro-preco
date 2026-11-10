unit uConf;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin, ColorSpeedButton, LCLIntf, uFuncoes, uTema;

type

  { TfrmConf }

  TfrmConf = class(TForm)
    ckInativos: TCheckBox;
    Label1: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Panel3Click(Sender: TObject);
  private
    FBtnSalvar: TColorSpeedButton;
    procedure Modernizar;

  public

  end;

var
  frmConf: TfrmConf;

implementation

{$R *.lfm}

{ TfrmConf }

procedure TfrmConf.Panel3Click(Sender: TObject);
begin
    PGravaINI(
          'DICASTRO',
          'TAM_FONTE',
          IntToStr(SpinEdit1.Value)
        );

    PGravaINI(
          'DICASTRO',
          'HIS_LINHAS',
           IntToStr(SpinEdit2.Value)
     );


    PGravaINI(
        'DICASTRO',
        'MOSTRAR_INATIVOS',
        BoolToStr(ckInativos.Checked)
    );

    Self.Close;
end;

procedure TfrmConf.FormCreate(Sender: TObject);
begin
  Modernizar;
end;

{ Visual moderno: cantos arredondados e botao Salvar arredondado no tema. }
procedure TfrmConf.Modernizar;
begin
  if FBtnSalvar = nil then
  begin
    FBtnSalvar := TColorSpeedButton.Create(Self);
    FBtnSalvar.Parent := Panel1;
    FBtnSalvar.SetBounds(Panel3.Left - 8, Panel3.Top, Panel3.Width + 8, Panel3.Height);
    FBtnSalvar.Caption := 'SALVAR (F12)';
    FBtnSalvar.Font.Style := [fsBold];
    FBtnSalvar.Cursor := crHandPoint;
    FBtnSalvar.OnClick := @Panel3Click;
    Panel3.Visible := False;
  end;
  AplicarTema(Self);
end;

procedure TfrmConf.FormShow(Sender: TObject);
begin
  SetWindowRgn(Handle, CreateRoundRectRgn(0, 0, Width + 1, Height + 1, 20, 20), True);
  AplicarTema(Self);
      SpinEdit1.Value :=
      StrToIntDef(
        PLerINI(
          'DICASTRO',
          'TAM_FONTE',
          '9'
        ),
        9
      );

    SpinEdit2.Value :=
      StrToIntDef(
        PLerINI(
          'DICASTRO',
          'HIS_LINHAS',
          '9'
        ),
        9
      );


    ckInativos.Checked :=
      PLerINI(
        'DICASTRO',
        'MOSTRAR_INATIVOS',
        '0'
      ) = '1';
end;

procedure TfrmConf.Label2Click(Sender: TObject);
begin
    PGravaINI(
          'DICASTRO',
          'TAM_FONTE',
          IntToStr(SpinEdit1.Value)
        );

    PGravaINI(
          'DICASTRO',
          'HIS_LINHAS',
           IntToStr(SpinEdit2.Value)
     );


    PGravaINI(
        'DICASTRO',
        'MOSTRAR_INATIVOS',
        BoolToStr(ckInativos.Checked)
    );

    Self.Close;
end;

end.

