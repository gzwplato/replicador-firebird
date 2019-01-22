unit uXml;

interface

uses
  JclSimpleXml,
  SysUtils,
  StrUtils,
  Classes;


function leStrXML(const AXML : String; const AElems : String) : String;
function leStrXMLCount(const AXML : String; const AElems : String) : Integer;
function leStrXMLFloat(const AXML : String; const AElems : String) : Double;

function leXML(AXML : TJclSimpleXml; AElems : String) : Variant;
function leXMLCount(AXML : TJclSimpleXml; AElems : String) : Integer;
function leXMLFloat(AXML : TJclSimpleXml; AElems : String) : Double;

function leXMLIntDef(AXML : TJclSimpleXml; AElems : String; ADef : integer = 0) : Integer;
function leStrXMLIntDef(const AXML : String; const AElems : String; ADef : integer = 0) : Integer;

function leXMLName(AXML : TJclSimpleXml; AElems : String) : String;
function leStrXMLName(const AXML : String; const AElems : String) : String;

function leStrXMLProp(const AXML : String; const AElems : String; AProp : String) : String;
function leXMLProp(AXML : TJclSimpleXml; AElems : String; AProp : String) : String;

implementation

function Split(input: string; schar: Char; s: Integer): string;
var
  c: array of Integer;
  b, t: Integer;
begin
  if input[Length(input)] <> schar then
    input := input + schar;
  t := 0;
  setlength(c, Length(input));
  for b := 0 to pred(High(c)) do
  begin
    c[b + 1] := PosEx(schar, input, succ(c[b]));
     if (c[b + 1] < c[b]) or (s < t) then break
    else
      Inc(t);
  end;
  Result := Copy(input, succ(c[s]), pred(c[s + 1] - c[s]));
end;
function SplitCount(input: string; C: Char): Integer;
var
  I: Integer;
begin
  Result := 0;
  if input = '' then Exit;
  if input = ';' then Exit;

  if input[Length(input)] <> C then
    input := input + C;

  Result := 0;
  for I := 1 to Length(input) do
    if input[I] = C then
      Inc(Result);
end;
function leXML(AXML : TJclSimpleXml; AElems : String) : Variant;
var
  lElem : TJclSimpleXMLElem;
  i,
  lOut  : integer;
  lStr  : String;
begin
  Result        := '';
  lElem         := AXML.Root;
  for i:=0 to SplitCount(AElems,';')-1 do
  begin
    if not Assigned(lElem) then Exit;
    lStr := Split(AElems,';',i);
    if TryStrToInt(lStr,lOut) then//Indice para um elemento
      lElem := lElem.Items.Item[lOut]
    else
      lElem := lElem.Items.ItemNamed[lStr];
  end;
  if not Assigned(lElem) then Exit;


  if Copy(lStr,1,1)='@' then
  begin
    lStr   := Copy(lStr,2,Length(lStr)-2);
    Result := lElem.Properties.Value( lStr );
  end else if Copy(lStr,1,1)='#' then
  begin
    lStr   := Copy(lStr,2,Length(lStr)-2);
    if CompareText(lStr,'count')=0 then
      Result := lElem.Items.Count
    else if CompareText(lStr,'float')=0 then
      Result := lElem.FloatValue
    else if CompareText(lStr,'int')=0 then
      Result := lElem.IntValue
    else if CompareText(lStr,'name')=0 then
      Result := lElem.Name
  end else
  begin
    Result := lElem.Value;
  end;


end;
function leXMLProp(AXML : TJclSimpleXml; AElems : String; AProp : String) : String;
var
  lElem : TJclSimpleXMLElem;
  i,lOut : integer;
begin
  Result        := '';
  lElem         := AXML.Root;
  for i:=0 to SplitCount(AElems,';')-1 do
  begin
    if not Assigned(lElem) then Exit;
    if TryStrToInt(Split(AElems,';',i),lOut) then
      lElem := lElem.Items.Item[lOut]
    else
      lElem := lElem.Items.ItemNamed[Split(AElems,';',i)];
  end;
  if not Assigned(lElem) then Exit;
  Result := lElem.Properties.Value(AProp);
end;

function leXMLName(AXML : TJclSimpleXml; AElems : String) : String;
var
  lElem : TJclSimpleXMLElem;
  i,lOut : integer;
begin
  Result        := '';
  lElem         := AXML.Root;
  for i:=0 to SplitCount(AElems,';')-1 do
  begin
    if not Assigned(lElem) then Exit;
    if TryStrToInt(Split(AElems,';',i),lOut) then
      lElem := lElem.Items.Item[lOut]
    else
      lElem := lElem.Items.ItemNamed[Split(AElems,';',i)];
  end;
  if not Assigned(lElem) then Exit;
  Result := lElem.Name;
end;

function leStrXML(const AXML : String; const AElems : String) : String;
var
  lXml : TJclSimpleXML;
begin
  lXml := TJclSimpleXML.Create;
  lXml.Options := lXml.Options + [sxoAutoCreate];
  lXml.LoadFromString(AXML);
  try
    Result := leXML(lXml,AElems);
  finally
    lXml.Free;
  end;
end;
function leStrXMLProp(const AXML : String; const AElems : String; AProp : String) : String;
var
  lXml : TJclSimpleXML;
begin
  lXml := TJclSimpleXML.Create;
  lXml.Options := lXml.Options + [sxoAutoCreate];
  lXml.LoadFromString(AXML);
  try
    Result := leXMLProp(lXml,AElems,AProp);
  finally
    lXml.Free;
  end;
end;
function leStrXMLName(const AXML : String; const AElems : String) : String;
var
  lXml : TJclSimpleXML;
begin
  lXml := TJclSimpleXML.Create;
  lXml.Options := lXml.Options + [sxoAutoCreate];
  lXml.LoadFromString(AXML);
  try
    Result := leXMLName(lXml,AElems);
  finally
    lXml.Free;
  end;
end;
function leXMLFloat(AXML : TJclSimpleXml; AElems : String) : Double;
var
  lElem : TJclSimpleXMLElem;
  i,lOut : integer;
begin
  Result := 0.0;

  lElem := AXML.Root;
  for i:=0 to SplitCount(AElems,';')-1 do
  begin
    if not Assigned(lElem) then Exit;

    if TryStrToInt(Split(AElems,';',i),lOut) then
      lElem := lElem.Items.Item[lOut]
    else
      lElem := lElem.Items.ItemNamed[Split(AElems,';',i)];
  end;
  if not Assigned(lElem) then Exit;
  Result := lElem.FloatValue;
end;
function leStrXMLFloat(const AXML : String; const AElems : String) : Double;
var
  lXml : TJclSimpleXML;
begin
  lXml := TJclSimpleXML.Create;
  lXml.Options := lXml.Options + [sxoAutoCreate];
  lXml.LoadFromString(AXML);
  try
    Result := leXMLFloat(lXml,AElems);
  finally
    lXml.Free;
  end;
end;

function leXMLIntDef(AXML : TJclSimpleXml; AElems : String; ADef : integer = 0) : Integer;
var
  lElem : TJclSimpleXMLElem;
  i,lOut : integer;
begin
  Result := ADef;

  lElem := AXML.Root;
  for i:=0 to SplitCount(AElems,';')-1 do
  begin
    if not Assigned(lElem) then Exit;

    if TryStrToInt(Split(AElems,';',i),lOut) then
      lElem := lElem.Items.Item[lOut]
    else
      lElem := lElem.Items.ItemNamed[Split(AElems,';',i)];
  end;
  if not Assigned(lElem) then Exit;
  Result := lElem.IntValue;
end;
function leStrXMLIntDef(const AXML : String; const AElems : String; ADef : integer = 0) : Integer;
var
  lXml : TJclSimpleXML;
begin
  lXml := TJclSimpleXML.Create;
  lXml.Options := lXml.Options + [sxoAutoCreate];
  lXml.LoadFromString(AXML);
  try
    Result := leXMLIntDef(lXml,AElems,ADef);
  finally
    lXml.Free;
  end;
end;

function leXMLCount(AXML : TJclSimpleXml; AElems : String) : Integer;
var
  lElem : TJclSimpleXMLElem;
  i,lOut : integer;
begin
  Result := 0;

  lElem := AXML.Root;
  for i:=0 to SplitCount(AElems,';')-1 do
  begin
    if not Assigned(lElem) then Exit;
    if TryStrToInt(Split(AElems,';',i),lOut) then
      lElem := lElem.Items.Item[lOut]
    else
      lElem := lElem.Items.ItemNamed[Split(AElems,';',i)];
  end;
  if not Assigned(lElem) then Exit;
  Result := lElem.Items.Count;
end;
function leStrXMLCount(const AXML : String; const AElems : String) : Integer;
var
  lXml : TJclSimpleXML;
begin
  lXml := TJclSimpleXML.Create;
  lXml.Options := lXml.Options + [sxoAutoCreate];
  lXml.LoadFromString(AXML);
  try
    Result := leXMLCount(lXml,AElems);
  finally
    lXml.Free;
  end;
end;

end.
