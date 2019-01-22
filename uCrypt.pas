unit uCrypt;

interface

function Encrypt(tr: string): string;
function Decrypt(pr: string): string;
function ExtractHost(ADBPath: string): string;


implementation



function ExtractHost(ADBPath: string): string;
var
  lPos : integer;
begin
  Result := '';
  lPos := Pos(':',ADBPath);
  if lPos > 0 then
  begin
    Result := Copy(ADBPath,0,lPos-1);
    lPos := Pos('/',Result);
    if lPos > 0 then
    begin
      Result := Copy(Result,0,lPos-1);
    end;
  end;


end;

function Encrypt(tr: string): string;
var
  i: Integer;
  Temp: string;
begin
  for i := 1 to Length(tr) do
  begin
    Temp := Temp + Chr(Ord(tr[i]) + length(tr) - i);
  end;
  Encrypt := Temp;
end;

function Decrypt(pr: string): string;
var
  i: Integer;
  Temp: string;
begin
  for i := 1 to Length(pr) do
  begin
    Temp := Temp + Chr(Ord(pr[i]) - length(pr) + i);
  end;
  Decrypt := Temp;
end;

end.
 