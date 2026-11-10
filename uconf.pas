unit uConf;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Spin, uFuncoes;

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
    procedure FormShow(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Panel3Click(Sender: TObject);
  private

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

procedure TfrmConf.FormShow(Sender: TObject);
begin
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

