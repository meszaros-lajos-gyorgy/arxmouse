Program Arxmouse2;

{Rune detector program, similarly to what you have in Arx Fatalis}

uses crt;

type tkoord = record
  x, y: integer;
end;

const directions: string[9] = '012345678';

var
  vonal: array[1..3] of tkoord;
  mouse: byte;
  rune: string[7];
  bekapcs: boolean;
  magic: array[1..6] of string;
  i: byte;
  prevMagicnum: byte;
  magicnum: byte;

procedure showMouseCursor; assembler;
asm
  mov ax, 1
  int 33h
end;

procedure hideMouseCursor; assembler;
asm
  mov ax, 2
  int 33h
end;

procedure set80x25TextMode; assembler;
asm
  mov ax, 3
  int 10h
end;

procedure hideTextCursor; assembler;
asm
  mov ah, 1
  mov ch, 127
  int 10h
end;

procedure getMouseCoordinates; assembler;
asm
  mov si, offset vonal
  mov al, mouse
  shl al, 1
  and al, 00000011b
  mov mouse, al
  mov ax, 5
  int 33h
  and al, 00000001b
  add mouse, al
  cmp mouse, 2
  jz  @2
  cmp mouse, 3
  jz  @3
  cmp mouse, 1
  jnz @vege
  mov ax, 3
  int 33h
  shr cx, 1
  mov [si], cx
  mov [si + 2], dx
  jmp @vege
@2:
  mov ax, 3
  int 33h
  shr cx, 1
  mov [si + 4], cx
  mov [si + 6], dx
  jmp @vege
@3:
  mov ax, [si + 8]
  mov [si + 4], ax
  mov ax, [si + 10]
  mov [si + 6], ax
  mov ax, 3
  int 33h
  shr cx, 1
  mov [si + 8], cx
  mov [si + 10], dx
@vege:
end;

function getDirectionIndex: byte;
var dx, dy: single;
begin
  dx := vonal[2].x - vonal[1].x;
  dy := vonal[2].y - vonal[1].y;
  if      (dx = 0)     and (dy = 0)                      then getDirectionIndex := 0
  else if (dx < -dy/2) and (dx > dy/2)  and (dy < 0)     then getDirectionIndex := 1
  else if (dx > -dy/2) and (dy < -dx/2)                  then getDirectionIndex := 2
  else if (dx > 0)     and (dy > -dx/2) and (dy < dx/2)  then getDirectionIndex := 3
  else if (dx > dy/2)  and (dy > dx/2)                   then getDirectionIndex := 4
  else if (dx < dy/2)  and (dx > -dy/2) and (dy > 0)     then getDirectionIndex := 5
  else if (dx < -dy/2) and (dy > -dx/2)                  then getDirectionIndex := 6
  else if (dx < 0)     and (dy > dx/2)  and (dy < -dx/2) then getDirectionIndex := 7
  else if (dx < dy/2)  and (dy < dx/2)                   then getDirectionIndex := 8;
  {getDirectionIndex:
   8   1   2
     \ | /
   7 --0-- 3
     / | \
   6   5   4}
end;

begin
  set80x25TextMode;
  hideTextCursor;
  showMouseCursor;

  mouse := 0;
  rune := '0';
  bekapcs := true;

  for i := 1 to 6 do
    magic[i] := '';

  magicnum := 0;
  prevMagicnum := -1;

  repeat
    getMouseCoordinates;
    if mouse = 2 then begin
      if (vonal[2].x <> vonal[3].x) and (vonal[2].y <> vonal[3].y) then
        rune := rune + directions[dxdy+1];
      
      if (magicnum < 6) then
        inc(magicnum);

      if      rune = '3'      then magic[magicnum] := 'AAM'
      else if rune = '7'      then magic[magicnum] := 'NHI'
      else if rune = '1'      then magic[magicnum] := 'MEGA'
      else if rune = '531'    then magic[magicnum] := 'YOK'
      else if rune = '353'    then magic[magicnum] := 'TAAR'
      else if rune = '76543'  then magic[magicnum] := 'KAOM'
      else if rune = '31'     then magic[magicnum] := 'VITAE'
      else if rune = '46'     then magic[magicnum] := 'VISTA'
      else if rune = '141'    then magic[magicnum] := 'STREGNUM'
      else if rune = '35'     then magic[magicnum] := 'MORTE'
      else if rune = '3571'   then magic[magicnum] := 'COSUM'
      else if rune = '35753'  then magic[magicnum] := 'COMMUNICATUM'
      else if rune = '363'    then magic[magicnum] := 'MOVIS'
      else if rune = '135313' then magic[magicnum] := 'TEMPUS'
      else if rune = '24'     then magic[magicnum] := 'FOLGORA'
      else if rune = '7531'   then magic[magicnum] := 'SPACIUM'
      else if rune = '253'    then magic[magicnum] := 'TERA'
      else if rune = '413'    then magic[magicnum] := 'CETRIUS'
      else if rune = '5'      then magic[magicnum] := 'RHAA'
      else if rune = '135'    then magic[magicnum] := 'FRIDD'
      else dec(magicnum);
    end
    else if mouse = 3 then begin
      if (vonal[2].x = vonal[3].x) and (vonal[2].y = vonal[3].y)
      and (vonal[1].x <> vonal[3].x) and (vonal[1].y <> vonal[3].y) then begin
        if bekapcs then begin
          if (rune[length(rune)] <> directions[dxdy + 1]) then
            rune := rune + directions[dxdy + 1];
          bekapcs := false;
          vonal[1].x := vonal[2].x;
          vonal[1].y := vonal[2].y;
        end;
      end
      else bekapcs := true;
    end
    else if mouse = 0 then rune := '';

    if (prevMagicnum <> magicnum) then begin
      gotoxy(1, 1);
      clreol;
      for i := 1 to magicnum do
        write(magic[i], ' ');
    end;

    prevMagicnum = magicnum;

  until keypressed;
  hideMouseCursor; 
end.