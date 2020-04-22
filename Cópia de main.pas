unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, LibString, Math, UDisp;

type
  TFCRC = class(TForm)
    Hexa: TEdit;
    Button1: TButton;
    Label1: TLabel;
    Button2: TButton;
    Memo1: TMemo;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    Aux : array[0..80] of integer;
    fcstab : array[0..256] of word;
    Porta : TPort;
    function RecebeDados : string;
    function ConverteHexaShow(Aux : string) : string;
    function Remove7D(Aux : string) : string;
    function ConverteHexa(Aux : string) : string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FCRC: TFCRC;

const
  RespConexao = #126 + #255 + #003 + #192 + #033 + #001 + #001 + #000 + #020 + #002 +
                #006 + #000 + #000 + #000 + #000 + #003 + #004 + #192 + #035 + #005 +
                #006;

implementation

{$R *.dfm}

procedure TFCRC.Button1Click(Sender: TObject);
var
 iLoop : integer;
 b, v, fcs, msb_fcs, lsb_fcs : Word;
begin
   Label1.Caption := '';
   // Convertendo os numeros para hexadecimais
   for iLoop := 0 to Hexa.GetTextLen div 3 do
       Aux[iLoop] := HexToInt(Copy(Hexa.Text, (iLoop * 3) + 1, 2));

   for iLoop := 0 to Hexa.GetTextLen div 3 do
       Label1.Caption := Label1.Caption + IntToStr(Aux[iLoop]) + ' ';

   // Calculo do CRC
   b := 0;
   while b <> 256 do
   begin
      v := b;
      for iLoop := 7 downto 0 do
      begin
         if (v and 1) > 0 then
            v := (v shr 1) xor 33800
         else
            v := v shr 1;
      end;
      fcstab[b] := v and 65535;
      Inc(b);
   end;

   fcs := 65535;

   for iLoop := 0 to Hexa.GetTextLen div 3 do
      fcs := (fcs shr 8) xor fcstab[(fcs xor Aux[iLoop]) and 255];

   fcs := fcs xor 65535;

   lsb_fcs := ((fcs shr 8) and 255);

   msb_fcs := fcs and 255;

   ShowMessage(IntToHex(msb_fcs,2) + '/' + IntToHex(lsb_fcs,2));
end;

procedure TFCRC.Button2Click(Sender: TObject);
var
 Aux : string;
begin
   Memo1.Lines.Clear;
   // Testando o modem
   Memo1.Lines.Add('Testando o modem ...');
   Porta.EnvMens('AT' + #13 + #10);
   if Porta.EnvMensEspResp(1000,'OK') then
   begin
      Memo1.Lines.Add('OK');
      // Desligando o eco
      Memo1.Lines.Add('Desligando ECO ...');
      Porta.EnvMens('ATE0' + #13 + #10);
      if Porta.EnvMensEspResp(1000,'OK') then
      begin
         Memo1.Lines.Add('OK');
         // Fazendo a conexão
         Memo1.Lines.Add('Conectando ...');
         Porta.EnvMens('ATDT #777' + #13 + #10);
         if Porta.EnvMensEspResp(5000,'CONNECT') then
         begin
            Memo1.Lines.Add('Conectado');
            // Enviando o primeiro pacote PPP
            Memo1.Lines.Add('Enviando pedido de conexão ...');
            Porta.EnvMens(#126 + #255 + #003 + #192 + #033 + #001 + #000 + #000 +
                          #010 + #005 + #006 + #000 + #000 + #001 + #000 + #172 +
                          #051 + #126);
            Memo1.Lines.Add('Pacote recebido :');
            Aux := RecebeDados;
            // Exibe o pacote recebido
            Memo1.Lines.Add(ConverteHexaShow(Aux));
            // Remove o 7D
            Memo1.Lines.Add('Pacote sem o 7D :');
            Aux := Remove7D(Aux);
            Memo1.Lines.Add(ConverteHexa(Aux));
            // Verifica se a resposta é correta e pega o código de conexão
            if Copy(Aux,1,21) = RespConexao then
            begin
               // Pega o número mágico
               Memo1.Lines.Add('Pedido de conexão aceito');
               Aux := Copy(Aux,22,4);
               Memo1.Lines.Add('Número mágico :');
               Memo1.Lines.Add(ConverteHexa(Aux));
            end;
         end
         else
            Application.MessageBox('Não foi possível conectar !','Atenção',
                                   MB_OK + MB_IconError);
      end
      else
         Application.MessageBox('Não foi possível desligar o ECO !', 'Atenção',
                                MB_OK + MB_IconError);
   end
   else
      Application.MessageBox('O modem não está instalado !','Atenção',
                             MB_OK + MB_IconError);
end;

procedure TFCRC.Button3Click(Sender: TObject);
begin
   Button3.Enabled := false;
   Porta.EnvMens('ATH' + #13 + #10);
   if not Porta.EnvMensEspResp(1000,'OK') then
      Application.MessageBox('Não foi possível desconectar !','Atenção',
                             MB_OK + MB_IconError)
   else
      Memo1.Lines.Add('Desconectado');
   Button3.Enabled := true;
end;

procedure TFCRC.FormCreate(Sender: TObject);
begin
   Porta := TPort.Create;
   if Porta.AbrPort(2, 8, NOPARITY, ONESTOPBIT, CBR_19200) = 0 then
   begin
      Button2.Enabled := true;
      Button3.Enabled := true;
   end;
end;

procedure TFCRC.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Porta.FecPort;
   Porta.Free;
end;

function TFCRC.RecebeDados: string;
var
 iLoop : word;
begin
   Result := '';
   while true do
   begin
      // Le os dados da porta serial
      Result := Result + Porta.LerPort;
      // Verifica se recebeu alguma coisa
      if Result <> '' then
      begin
         // Verifica se o primeiro caracter é 126
         if Result[1] = #126 then
         begin
            // Procura o ultimo caracter de 126
            for iLoop := 2 to Length(Result) do
            begin
               if Result[iLoop] = #126 then
                  break;
            end;
            // Remove o restante dos caracteres
            if Result[iLoop] = #126 then
            begin
               Result := Copy(Result,1,iLoop);
               break;
            end;
         end;
      end;
      Application.ProcessMessages;
   end;
end;

function TFCRC.ConverteHexaShow(Aux: string): string;
var
 iLoop : word;
begin
   for iLoop := 1 to Length(Aux) do
       Result := Result + '0x' + IntToHex(Integer(Aux[iLoop]),2) + '-' + Aux[iLoop] + ' ';
end;

function TFCRC.Remove7D(Aux: string): string;
var
 iLoop, Reduz : word;
begin
   Reduz := 0;
   for iLoop := 1 to Length(Aux) do
   begin
      if Integer(Aux[iLoop]) = 125 then
         Reduz := 32
      else
      begin
         Result := Result + Char(Integer(Aux[iLoop]) - Reduz);
         Reduz := 0;
      end;
   end;
end;

function TFCRC.ConverteHexa(Aux: string): string;
var
 iLoop : word;
begin
   for iLoop := 1 to Length(Aux) do
       Result := Result + IntToHex(Integer(Aux[iLoop]),2) + ' ';
end;

end.
