program icon_preview;
{$mode objfpc}{$H+}
uses Interfaces, Graphics, Classes, Types, uIcones;
var Sheet, B: TBitmap; I: TIcone; X: Integer; PNG: TPortableNetworkGraphic;
begin
  Sheet := TBitmap.Create; Sheet.SetSize(7*80+10, 2*80+10);
  Sheet.Canvas.Brush.Color := $00C68A00; Sheet.Canvas.FillRect(0,0,Sheet.Width,Sheet.Height div 2);
  Sheet.Canvas.Brush.Color := $00FFFFFF; Sheet.Canvas.FillRect(0,80+5,Sheet.Width,Sheet.Height);
  X := 5;
  for I := Low(TIcone) to High(TIcone) do begin
    B := CriarIcone(I, 30, 30, clWhite, $00C68A00, $00C68A00);
    Sheet.Canvas.StretchDraw(Rect(X,5,X+72,77), B); B.Free;
    B := CriarIcone(I, 30, 30, clWhite, $00A06A00, $00FFFFFF);
    Sheet.Canvas.StretchDraw(Rect(X,90,X+72,162), B); B.Free;
    X += 80;
  end;
  PNG := TPortableNetworkGraphic.Create; PNG.Assign(Sheet); PNG.SaveToFile('icons.png');
end.
