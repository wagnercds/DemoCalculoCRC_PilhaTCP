unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, LibString, Math, UDisp, OleCtrls, MSCommLib_TLB,
  ExtCtrls;

type
  TFCRC = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    Hexa: TEdit;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    edNum: TEdit;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    TimeOut: TTimer;
    Button10: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure TimeOutTimer(Sender: TObject);
    procedure Button10Click(Sender: TObject);
  private
    fcstab : array[0..256] of word;
    Porta : TPort;
    Cancela : boolean;
    function RecebeDados : string;
    function ConverteHexaShow(Aux : string) : string;
    function Remove7D(Aux : string) : string;
    function ConverteHexa(Aux : string) : string;
    function CalculaCRC(Aux : string) : string;
    function Insere7D(Aux : string) : string;
    function CalculaCRCUDP(Aux : string) : string;
    function CalculaCRC2(Aux : string) : string;
    function LoopCRC2(Dig : word) : word;

    procedure SomaUDP(dados : string; var soma : word);
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

  RespMagico =  #126 + #255 + #003 + #192 + #033 + #002 + #000 + #000 + #010 + #005 +
                #006 + #000 + #000 + #001 + #000 + #197 + #071 + #126;

  RespSenha1 =  #126 + #255 + #003 + #192 + #033 + #001 + #001 + #000 + #018 + #001 +
                #004 + #005 + #182 + #003 + #004 + #192 + #035 + #005 + #006;

  RespSenhaC =  #126 + #255 + #003 + #192 + #035 + #002 + #000 + #000 + #005 + #000 +
                #048 + #039 + #126;

  RespLinIG =   #126 + #255 + #001 + #001 + #001 + #000 + #010 + #003 + #006 + #010 +
                #000 + #000 + #254 + #076 + #234 + #126;

  RespIP    =   #126 + #255 + #003 + #128 + #033 + #003;

  RespNumIP =   #126 + #255 + #003 + #128 + #033 + #003 + #000 + #000 + #016 + #003;

  RespNeg =     #126 + #255 + #003 + #192 + #033 + #002 + #000 + #000 + #010 + #005 +
                #006 + #000 + #000 + #001 + #000 + #197 + #071 + #126;

  ConfConexao = #255 + #003 + #192 + #033 + #002 + #001 + #000 + #020 + #002 + #006 +
                #000 + #000 + #000 + #000 + #003 + #004 + #192 + #035 + #005 + #006;

  ConfSenha =   #255 + #003 + #192 + #035 + #001 + #000 + #000 + #042 + #027;

  ConfSenha1 =  #255 + #003 + #192 + #033 + #002 + #001 + #000 + #018 + #001 + #004 +
                #005 + #182 + #003 + #004 + #192 + #035 + #005 + #006;

  ConfIP     =  #255 + #003 + #128 + #033 + #001 + #001 + #000 + #022 + #003 + #006;

  ConfIP2    =  #129 + #006 + #010 + #000 + #000 + #254 + #131 + #006 + #000 + #000 +
                #000 + #000;

  ConfCIP    =  #255 + #003 + #128 + #033 + #002;

  ConfCIP2   =  #000 + #010 + #003 + #006 + #010 + #000 + #000 + #254 + #000;

  NumTel = '1397350312';

  {'1397416413'; '1397350312';}

   //'1397350482'; //'1397132875'; //'1397165469'; // '1397350312

  Dominio = '@vpncarsystem.com';

  Senha = #009 + 'esperanca';

implementation

{$R *.dfm}

procedure TFCRC.Button1Click(Sender: TObject);
var
 iLoop : integer;
 Aux : string;
begin
   // Convertendo hexadecimais para numeros
   for iLoop := 0 to Hexa.GetTextLen div 3 do
       Aux := Aux + Chr(HexToInt(Copy(Hexa.Text, (iLoop * 3) + 1, 2)));

   edNum.Text := '';
   for iLoop := 1 to Length(Aux) do
       edNum.Text := edNum.Text + IntToStr(Integer(Aux[iLoop])) + ' ';

   Aux := CalculaCRC(Aux);

   ShowMessage(IntToHex(Integer(Aux[1]),2) + '/' + IntToHex(Integer(Aux[2]),2));
end;

procedure TFCRC.Button2Click(Sender: TObject);
var
 Aux, NumMagico, Aux2 : string;
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
         if Porta.EnvMensEspResp(10000,'CONNECT') then
         begin
            Memo1.Lines.Add('Conectado');

            Memo1.Lines.Add(' ');
            Aux := '';
            while Aux = '' do
            begin
               Aux := '';
               // Enviando o primeiro pacote PPP
{               Memo1.Lines.Add('Enviando primeiro pacote :');
               Memo1.Lines.Add('');
               Aux := #126 + #255 + #003 + #192 + #033 + #001 + #000 + #000 +
                      #010 + #005 + #006 + #000 + #000 + #001 + #000 + #172 +
                      #051 + #126;
               Aux := Insere7D(Aux);
               Memo1.Lines.Add(ConverteHexa(Remove7D(Aux)));
               Memo1.Lines.Add(ConverteHexaShow(Aux));
               Porta.EnvMens(Aux);
               Memo1.Lines.Add(' ');
               sleep(100);}
               // Enviando o primeiro pacote PPP
               Memo1.Lines.Add('Enviando primeiro pacote :');
               Memo1.Lines.Add('');
               Aux := #126 + #255 + #003 + #192 + #033 + #001 + #000 + #000 +
                      #010 + #005 + #006 + #000 + #000 + #001 + #000 + #172 +
                      #051 + #126;
               Aux := Insere7D(Aux);
               Memo1.Lines.Add(ConverteHexa(Remove7D(Aux)));
               Memo1.Lines.Add(ConverteHexaShow(Aux));
               Porta.EnvMens(Aux);
               Memo1.Lines.Add(' ');


               Memo1.Lines.Add('Resposta do primeiro pacote :');
               Memo1.Lines.Add(' ');
               Aux := RecebeDados;
               // Exibe o pacote recebido
               Memo1.Lines.Add(ConverteHexaShow(Aux));
               // Remove o 7D
               Aux := Remove7D(Aux);
               Memo1.Lines.Add(ConverteHexa(Aux));
               Memo1.Lines.Add(' ');
            end;
            // Verifica se a resposta é correta e pega o código de conexão
            if Copy(Aux,1,21) = RespConexao then
            //if Aux <> RespNeg then
            begin
               // Pega o número mágico
               Memo1.Lines.Add('Primeiro pacote OK');
               NumMagico := Copy(Aux,Length(Aux) - 6,4);
               Memo1.Lines.Add(' ');
               Memo1.Lines.Add('Número mágico obtido: ' + ConverteHexa(NumMagico));
               Memo1.Lines.Add(' ');

               // Envia pacote de confirmação do número mágico
               Memo1.Lines.Add('Enviando o segundo pacote :');
               Memo1.Lines.Add(' ');
               Aux := ConfConexao + NumMagico;
               Aux := #126 + Aux + CalculaCRC(Aux) + #126;
               Memo1.Lines.Add(ConverteHexa(Aux));
               Aux := Insere7D(Aux);
               Memo1.Lines.Add(ConverteHexaShow(Aux));
               Porta.EnvMens(Aux);
               Memo1.Lines.Add(' ');

               // Recebendo pacote
               Memo1.Lines.Add('Resposta do segundo pacote :');
               Memo1.Lines.Add(' ');
               // Pacote lido
               Aux := RecebeDados;
               // Exibe pacote recebido
               Memo1.Lines.Add(ConverteHexaShow(Aux));
               Aux := Remove7D(Aux);
               Memo1.Lines.Add(ConverteHexa(Aux));
               Memo1.Lines.Add(' ');
               // Essa analise foi removido porque em alguns momentos os caracteres estão se perdendo
               if true then//Aux = RespMagico then
               begin
                  Memo1.Lines.Add('Segundo pacote OK');

                  Aux := ConfSenha + NumTel + Dominio + Senha;
                  Aux := #126 + Aux + CalculaCRC(Aux) + #126;
                  Memo1.Lines.Add(' ');
                  Memo1.Lines.Add('Enviando terceiro pacote :');
                  Memo1.Lines.Add(' ');
                  Memo1.Lines.Add(ConverteHexa(Aux));
                  Aux := Insere7D(Aux);
                  Aux2 := Aux;
                  Memo1.Lines.Add(ConverteHexaShow(Aux));
                  Porta.EnvMens(Aux);
                  Memo1.Lines.Add(' ');

                  Memo1.Lines.Add('Resposta do terceiro pacote :');
                  Memo1.Lines.Add(' ');
                  Aux := RecebeDados;
                  Memo1.Lines.Add(ConverteHexaShow(Aux));
                  Aux := Remove7D(Aux);
                  Memo1.Lines.Add(ConverteHexa(Aux));
                  Memo1.Lines.Add(' ');

                  //if Copy(Aux, 1, 19) = RespSenha1 then
                  if true then
                  begin
                     Memo1.Lines.Add('Teceiro pacote OK');
                     Memo1.Lines.Add(' ');

                     Memo1.Lines.Add('Enviando quarto pacote :');
                     Memo1.Lines.Add(' ');
                     Aux := ConfSenha1 + NumMagico;
                     Aux := #126 + Aux + CalculaCRC(Aux) + #126;
                     Memo1.Lines.Add(ConverteHexa(Aux));
                     Aux := Insere7D(Aux);
                     Memo1.Lines.Add(ConverteHexaShow(Aux));
                     Porta.EnvMens(Aux);
                     Memo1.Lines.Add(' ');

                     Memo1.Lines.Add('Enviando quinto pacote :');
                     Memo1.Lines.Add(' ');
                     Memo1.Lines.Add(ConverteHexa(Remove7D(Aux2)));
                     Memo1.Lines.Add(ConverteHexaShow(Aux2));
                     Porta.EnvMens(Aux2);
                     Memo1.Lines.Add(' ');


                     Memo1.Lines.Add('Resposta do quarto e do quinto pacote :');
                     Memo1.Lines.Add(' ');
                     Aux := RecebeDados;
                     Memo1.Lines.Add(ConverteHexaShow(Aux));
                     Aux := Remove7D(Aux);
                     Memo1.Lines.Add(ConverteHexa(Aux));
                     Memo1.Lines.Add(' ');

                     if Aux = RespSenhaC then
                     //if true then
                     begin
                        Memo1.Lines.Add('Quarto e quinto pacote OK');
                        Memo1.Lines.Add(' ');

                        Memo1.Lines.Add('Resposta :');
                        Memo1.Lines.Add(' ');
                        Aux := RecebeDados;
                        Memo1.Lines.Add(ConverteHexaShow(Aux));
                        Aux := Remove7D(Aux);
                        Memo1.Lines.Add(ConverteHexa(Aux));
                        Memo1.Lines.Add(' ');

                        Memo1.Lines.Add('Resposta :');
                        Memo1.Lines.Add(' ');
                        Aux := RecebeDados;
                        Memo1.Lines.Add(ConverteHexaShow(Aux));
                        Aux := Remove7D(Aux);
                        Memo1.Lines.Add(ConverteHexa(Aux));
                        Memo1.Lines.Add(' ');

                        NumMagico := Copy(Aux, 7, 1);
                        Memo1.Lines.Add('Numero do protocolo : ' +
                                        ConverteHexa(NumMagico));
                        Memo1.Lines.Add(' ');
                        Aux2 := Copy(Aux, 2, 4) + #2 + Copy(Aux, 7, 10);
                        Aux2 := #126 + Aux2 + CalculaCRC(Aux2) + #126;

                        Memo1.Lines.Add('Enviando sexto pacote :');
                        Memo1.Lines.Add(' ');
                        Aux := #126 + #255 + #125 + #35 + #128 + #33 + #125 + #33 +
                               #125 + #32 + #125 + #32 + #125 + #54 + #125 + #35 +
                               #125 + #38 + #125 + #32 + #125 + #32 + #125 + #32 +
                               #125 + #32 + #129 + #125 + #38 + #125 + #32 + #125 +
                               #32 + #125 + #32 + #125 + #32 + #131 + #125 + #38 +
                               #125 + #32 + #125 + #32 + #125 + #32 + #125 + #32 +
                               #125 + #34 + #236 + #126;
                        Memo1.Lines.Add(ConverteHexa(Remove7D(Aux)));
                        Memo1.Lines.Add(ConverteHexaShow(Aux));
                        Memo1.Lines.Add(' ');
                        Porta.EnvMens(Aux);

                        Memo1.Lines.Add('Enviando sétimo pacote :');
                        Memo1.Lines.Add(' ');
                        Memo1.Lines.Add(ConverteHexa(Aux2));
                        Aux2 := Insere7D(Aux2);
                        Memo1.Lines.Add(ConverteHexaShow(Aux2));
                        Porta.EnvMens(Aux2);
                        Memo1.Lines.Add(' ');

                        Memo1.Lines.Add('Resposta do sexto e do sétimo pacote :');
                        Memo1.Lines.Add(' ');
                        Aux := RecebeDados;
                        Memo1.Lines.Add(ConverteHexaShow(Aux));
                        Aux := Remove7D(Aux);
                        Memo1.Lines.Add(ConverteHexa(Aux));
                        Memo1.Lines.Add(' ');

                        Memo1.Lines.Add('Enviando o oitavo comando :');
                        Aux := #126 + #255 + #125 + #35 + #128 + #33 + #125 + #33 +
                               #125 + #33 + #125 + #32 + #125 + #54 + #125 + #35 +
                               #125 + #38 + #125 + #42 + #41 + #125 + #54 + #125 +
                               #39 + #129 + #125 + #38 + #125 + #42 + #125 + #32 +
                               #125 + #32 + #254 + #131 + #125 + #38 + #125 + #32 +
                              #125 + #32 + #125 + #32 + #125 + #32 + #244 + #43 +
                               #126;
                        Memo1.Lines.Add(' ');
                        Memo1.Lines.Add(ConverteHexa(Remove7D(Aux)));
                        Memo1.Lines.Add(ConverteHexaShow(Aux));
                        Porta.EnvMens(Aux);
                        Memo1.Lines.Add(' ');

                        Memo1.Lines.Add('Resposta do oitavo pacote :');
                        Memo1.Lines.Add(' ');
                        Aux := RecebeDados;
                        Memo1.Lines.Add(ConverteHexaShow(Aux));
                        Aux := Remove7D(Aux);
                        Memo1.Lines.Add(ConverteHexa(Aux));
                        Memo1.Lines.Add(' ');
                     end
                     else
                        Memo1.Lines.Add('NÃO FOI ACEITO A SENHA !');
                  end
                  else
                     Memo1.Lines.Add('NÃO FOI ACEITO O ENVIO DE SENHA !');
               end;
            end
            else
               Memo1.Lines.Add('NÃO FOI ACEITO O PEDIDO DE CONEXÃO !');
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
   Porta.EnvMens('+++');
   Sleep(100);
   Porta.EnvMens('ATH' + #13 + #10);
   if not Porta.EnvMensEspResp(500,'OK') then
       Application.MessageBox('Não foi possível desconectar !','Atenção',
                             MB_OK + MB_IconError)
   else
      Memo1.Lines.Add('Desconectado');
   Button3.Enabled := true;
end;

procedure TFCRC.FormCreate(Sender: TObject);
begin
   Porta := TPort.Create;
   if Porta.AbrPort(1, 8, NOPARITY, ONESTOPBIT, CBR_19200) = 0 then
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
   Result := Result + Porta.LerPort;
   Cancela := false;
   TimeOut.Enabled := true;
   while true do
   begin
      if Cancela then
         break;
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
         // Essa rotina foi colocado apenas por que falta caracter (erro no MSCOMM), no PIC não vai precisar
         if Result[Length(Result)] = #126 then
         begin
            if Result[1] = #192 then
               Result := #126 + #255 + #125 + #35 + Result
            else
               Result := #126 + #255 + #125 + Result;
            break;
         end;
      end;
      Application.ProcessMessages;
   end;
   TimeOut.Enabled := false;
end;

function TFCRC.ConverteHexaShow(Aux: string): string;
var
 iLoop : word;
begin
   Result := '';
   for iLoop := 1 to Length(Aux) do
       Result := Result + '0x' + IntToHex(Integer(Aux[iLoop]),2) + '-' + Aux[iLoop] + ' ';
end;

function TFCRC.Remove7D(Aux: string): string;
var
 iLoop, Reduz : word;
begin
   Reduz := 0;
   Result := '';
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
   Result := '';
   for iLoop := 1 to Length(Aux) do
       Result := Result + IntToHex(Integer(Aux[iLoop]),2) + ' ';
end;

function TFCRC.CalculaCRC(Aux: string): string;
var
 b, v, fcs, iLoop : Word;
begin
   // Calculo do CRC
   b := 0;
   while b <> 256 do
   begin
      v := b;
      for iLoop := 0 to 7 do
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

   for iLoop := 1 to Length(Aux) do
      fcs := (fcs shr 8) xor fcstab[(fcs xor integer(Aux[iLoop])) and 255];

   fcs := fcs xor 65535;

   Result := char(fcs and 255) + char((fcs shr 8) and 255);
end;

function TFCRC.Insere7D(Aux: string): string;
var
 iLoop : word;
begin
   Result := '';
   for iLoop := 2 to Length(Aux) - 1 do
   begin
      if (Integer(Aux[iLoop]) < 32) or (Integer(Aux[iLoop]) = 125) or
         (Integer(Aux[iLoop]) = 126)then
         Result := Result + #125 + chr(Integer(Aux[iLoop]) xor 32)
      else
         Result := Result + Aux[iLoop];
   end;
   Result := Aux[1] + Result + Aux[Length(Aux)];
end;

procedure TFCRC.Button4Click(Sender: TObject);
var
 iLoop : integer;
 Aux : string;
begin
   // Convertendo hexadecimais para numeros
   for iLoop := 0 to Hexa.GetTextLen div 3 do
       Aux := Aux + Chr(HexToInt(Copy(Hexa.Text, (iLoop * 3) + 1, 2)));

   edNum.Text := '';
   for iLoop := 1 to Length(Aux) do
       edNum.Text := edNum.Text + IntToStr(Integer(Aux[iLoop])) + ' ';

   Aux := Insere7D(Aux);

   Hexa.Text := '';
   for iLoop := 1 to Length(Aux) do
       Hexa.Text := Hexa.Text + '0x' + IntToHex(Integer(Aux[iLoop]),2) + '-' +
                    Aux[iLoop] + ' ';
end;

procedure TFCRC.Button5Click(Sender: TObject);
var
 Aux : string;
begin
   Aux := #126 + #255 + #125 + #035 + #125 + #032 + #033 + #069 + #125 + #032 +
          #125 + #032 + #052 + #125 + #032 + #125 + #032 + #125 + #032 + #125 +
          #032 + #100 + #125 + #049 + #044 + #115 + #125 + #042 + #041 + #125 +
          #054 + #125 + #039 + #125 + #042 + #125 + #032 + #125 + #032 + #125 +
          #055 + #125 + #059 + #138 + #125 + #059 + #138 + #125 + #032 + #032 +
          #125 + #058 + #159 + #048 + #048 + #048 + #048 + #048 + #045 + #045 +
          #045 + #045 + #045 + #045 + #045 + #045 + #098 + #083 + #073 + #103 +
          #065 + #070 + #114 + #048 + #054 + #125 + #045 + #125 + #042 + #113 +
          #081 + #126;

   Memo1.Lines.Add('Dados enviado : ');
   Memo1.Lines.Add(ConverteHexaShow(Aux));
   Memo1.Lines.Add(ConverteHexa(Remove7D(Aux)));
   Porta.EnvMens(Aux);
end;

procedure TFCRC.Button6Click(Sender: TObject);
var
 Aux : string;
begin
   Button6.Enabled := false;
   Aux := RecebeDados;
   Memo1.Lines.Add('Dados recebidos :');
   Memo1.Lines.Add(ConverteHexaShow(Aux));
   Button6.Enabled := true;
   Memo1.Lines.Add('');
end;

(* Uso futuro

                        NumMagico := Copy(Aux, 7, 1);
                           Memo1.Lines.Add(ConverteHexa(NumMagico));
                           Memo1.Lines.Add('*******************************************************');
                           Memo1.Lines.Add('Enviando pedido de conexão IP...');
                           Aux := #126 + #255 + #125 + #035 + #128 + #033 + #125 +
                                  #033 + #125 + #032 + #125 + #032 + #125 + #054 +
                                  #125 + #035 + #125 + #038 + #125 + #032 + #125 +
                                  #032 + #125 + #032 + #125 + #032 + #129 + #125 +
                                  #038 + #125 + #032 + #125 + #032 + #125 + #032 +
                                  #125 + #032 + #131 + #125 + #038 + #125 + #032 +
                                  #125 + #032 + #125 + #032 + #125 + #032 + #125 +
                                  #034 + #236 + #126;
                          Memo1.Lines.Add(ConverteHexaShow(Aux));
                          Porta.EnvMens(Aux);
                          Memo1.Lines.Add('Enviando pacote de ligação');
                          Aux := ConfCIP + NumMagico + ConfCIP2;
                          Aux := #126 + Aux + CalculaCRC(Aux) + #126;
                          Memo1.Lines.Add('Pacote sem 7D');
                          Memo1.Lines.Add(ConverteHexa(Aux));
                          Aux := Insere7D(Aux);
                          Memo1.Lines.Add(ConverteHexaShow(Aux));
                          Porta.EnvMens(Aux);

///////////////////
                        Memo1.Lines.Add('Pacote de confirmação recebido :');
                        Aux := RecebeDados;
                        Memo1.Lines.Add(ConverteHexaShow(Aux));
                        Aux := Remove7D(Aux);
                        Memo1.Lines.Add('Pacote sem 7D :');
                        Memo1.Lines.Add(ConverteHexa(Aux));
                        Memo1.Lines.Add('Pacote de entrada na rede IP :');
                        Aux := RecebeDados;
                        Memo1.Lines.Add(ConverteHexaShow(Aux));
                        Memo1.Lines.Add('Pacote sem 7D :');
                        Aux := Remove7D(Aux);
                        Memo1.Lines.Add(ConverteHexa(Aux));
                        Memo1.Lines.Add(ConverteHexa(Copy(Aux, 1, 6)));
                        Memo1.Lines.Add(ConverteHexa(RespIP));
                        if Copy(Aux, 1, 6) = RespIP then
                        begin
                           Memo1.Lines.Add('Dentro da REDE IP');
                           Memo1.Lines.Add('Número da rede IP');
//*************************
                                                        Memo1.Lines.Add(ConverteHexaShow(Aux));
                             Aux := #126 + #255 + #125 + #035 + #128 + #033 + #125 +
                                 #033 + #125 + #045 + #125 + #032 + #125 + #042 +
                                 #125 + #035 + #125 + #038 + #125 + #042 + #125 +
                                 #032 + #125 + #032 + #254 + #099 + #170 + #126;
                             Memo1.Lines.Add('Confirmando IP Recebido');
                             Memo1.Lines.Add(ConverteHexaShow(Aux));
                             Porta.EnvMens(Aux);
//***************************
////////////////////////
                          Memo1.Lines.Add('Pacote recebido :');
                          Aux := RecebeDados;
                          Memo1.Lines.Add(ConverteHexaShow(Aux));
                          Memo1.Lines.Add('Pacote sem o 7D :');
                          Aux := Remove7D(Aux);
                          Memo1.Lines.Add(ConverteHexa(Aux));
                          Memo1.Lines.Add(ConverteHexa(Copy(Aux, 1, 10)));
                          Memo1.Lines.Add(ConverteHexa(RespNumIP));
                          if true then
                          //if Copy(Aux, 1, 10) = RespNumIP then
                          begin
                             Memo1.Lines.Add('IP obtido : ');
                             Aux2 := Copy(Aux, 12, 4);
                             Memo1.Lines.Add(ConverteHexa(Aux2) + '(' +
                                             IntToStr(Integer(Aux2[1])) + '.' +
                                             IntToStr(Integer(Aux2[2])) + '.' +
                                             IntToStr(Integer(Aux2[3])) + '.' +
                                             IntToStr(Integer(Aux2[4])) + ')');
                             Memo1.Lines.Add('****************************************************');
                             //***********
                             Aux := RecebeDados;
                             Memo1.Lines.Add(ConverteHexaShow(Aux));





                             (*Memo1.Lines.Add('Enviando confirmação do IP obtido :');
                             Aux := ConfIP + Aux2 + ConfIP2;
                             Aux := Insere7D(#126 + Aux + CalculaCRC(Aux) + #126);
                             Memo1.Lines.Add(ConverteHexaShow(Aux));
                             Porta.EnvMens(Aux);
                             Memo1.Lines.Add('Pacote recebido :');
                             Aux := RecebeDados;
                             Memo1.Lines.Add(ConverteHexaShow(Aux));
                             Aux := Remove7D(Aux);
                             Memo1.Lines.Add('Pacote sem o 7D :');
                             Memo1.Lines.Add(ConverteHexa(Aux));
                             Aux := RecebeDados;
                             Memo1.Lines.Add(ConverteHexaShow(Aux));
                             Aux := RecebeDados;
                             Memo1.Lines.Add(ConverteHexaShow(Aux));
                             {if Copy (Aux, 1 ,10) = RespNumIP then
                             begin
                                Memo1.Lines.Add('CONEXÃO CONCLUÍDA !');
                             end;}
                          end
                          else
                             Memo1.Lines.Add('NÃO FOI RECEBIDO O NÚMERO IP');
                        end
                        else
                           Memo1.Lines.Add('NÃO FOI RECEBIDO O PACOTE IP');*)

procedure TFCRC.Button7Click(Sender: TObject);
var
 Aux : string;
 iLoop : integer;
begin
   // Vai calcular o CRC
    for iLoop := 0 to Hexa.GetTextLen div 3 do
       Aux := Aux + Chr(HexToInt(Copy(Hexa.Text, (iLoop * 3) + 1, 2)));

   edNum.Text := '';
   for iLoop := 1 to Length(Aux) do
       edNum.Text := edNum.Text + IntToStr(Integer(Aux[iLoop])) + ' ';

   Aux := CalculaCRCUDP(Aux);

   ShowMessage(IntToHex(Integer(Aux[1]),2) + '/' + IntToHex(Integer(Aux[2]),2));
end;

function TFCRC.CalculaCRCUDP(Aux: string): string;
var
 Soma : word;
begin
   Soma := 0;
   // Calcula a primeira parte com os dados
   SomaUDP(Copy(Aux,9,6) + Copy(Aux,17,Length(Aux) - 16),Soma);

   // Calcula a terceira parte com o IP dono
   SomaUDP(Copy(Aux,5,4),Soma);

   // Calcula a segunda parte com o IP de destino
   SomaUDP(Copy(Aux,1,4),Soma);

   // Soma o protocolo UDP (17) mais o tamanho dos dados
   Soma := (Soma + 17 + (integer(Aux[14]) + 16)) - 14;
   // desloca 16 bits da soma até ela ser zero
   while (soma shr 16) > 0 do
         soma := (soma and 65535) + (soma shr 16);
   // Inverte a soma
   Soma := not Soma;
   Result := char((Soma shr 8) and 255) + char(Soma and 255);
end;

procedure TFCRC.SomaUDP(dados: string; var soma: word);
var
 iLoop, Calc : word;
begin
   iLoop := 1;
   while iLoop < Length(dados) do
   begin
      Calc := ((word(dados[iLoop]) shl 8) and 65280) + (word(dados[iLoop + 1]) and 255);
      Soma := Soma + Calc;
      Inc(iLoop,2);
   end;
end;

procedure TFCRC.Button8Click(Sender: TObject);
var
 Aux, Aux2 : string;
 Pos1, Pos2 : byte;
begin
   Memo1.Lines.Add(' ');
   Hexa.Text := Hexa.Text + #13 + #10;
   // Insere o cabeçalho principal
   Aux := #010 + #041 + #022 + #230 + #010 + #000 + #000 + #023 + #027 + #138 +
          #027 + #138;
   // Insere o tamanho do pacote
   Aux := Aux + char(((Hexa.GetTextLen + 8) shr 8) and 255) + char((Hexa.GetTextLen + 8) and 255);
   // Insere os dois digitos do futuro CRC (0 0) e depois o texto
   Aux := Aux + #0 + #0 + Hexa.Text;
   // Calcula o CRC
   Aux2 := CalculaCRCUDP(Aux);
   // Coloca o CRC correto
   Aux[15] := Aux2[1];
   Aux[16] := Aux2[2];
   aux[15] := #0;
   aux[16] := #0;
   aux[15] := #23;
   aux[16] := #193;
   Memo1.Lines.Add('Linha do UDP :');
   Memo1.Lines.Add(ConverteHexa(Aux));

   // Calcula o CRC do protocolo IP
   // 69 + 100 + Primeiro IP recebido + Terceiro IP Recebido + primeiro IP do servidor + terceiro IP do servidor
   Pos1 := 69 + 2 + 100 +Integer(Aux[1]) + Integer(Aux[3]) + Integer(Aux[5]) + Integer(Aux[7]);

   // Total do pacote + 17 + segundo IP Recebido + quarto ip recebido + segundo ip do servidor + quarto ip do servidor
   Pos2 := (Hexa.GetTextLen + 28) +  17 + Integer(Aux[2]) + Integer(Aux[4]) + Integer(Aux[6]) + Integer(Aux[8]);

   Pos2 := Pos2 + (Pos1 div 256);

   Pos1 := (Pos1 and 255) + (Pos2 div 256);

   Pos2 := (Pos2 and 255) + (Pos1 div 256);

   
   Pos1 := Pos1 + (Pos2 div 256);

   Pos1 := not Pos1;

   Pos2 := not Pos2;

   // Insere o cabeçalho do PPP
   Aux := #255 + #003 + #000 + #033 + #069 + #000 + #000 + char(Hexa.GetTextLen + 28) +
        //#000      
          #001 + #000 + #000 + #000 + #100 + #017 + char(Pos1) + char(Pos2) + Aux;

   // Calcula o CRC PPP
   Aux := #126 + Aux + CalculaCRC(Aux) + #126;
   Memo1.Lines.Add('Pacote completo :');
   Memo1.Lines.Add(ConverteHexa(Aux));

   Aux := Insere7D(Aux);
   Memo1.Lines.Add(ConverteHexa(Aux));
   Porta.EnvMens(Aux);
end;

function TFCRC.CalculaCRC2(Aux: string): string;
var
 iLoop, CheckSum : word;
begin
   CheckSum := 65535;
   for iLoop := 1 to Length(Aux) do
       CheckSum := LoopCRC2(word(Aux[iLoop]) xor CheckSum) xor (CheckSum div 256);
  CheckSum := not CheckSum;

  Result := char(CheckSum and 255) + char(CheckSum div 256);
end;

function TFCRC.LoopCRC2(Dig: word): word;
var
 iLoop : byte;
begin
   Result := dig and 255;
   for iLoop := 0 to 7 do
   begin
      if (Result and 1) = 1 then
      begin
         Result := Result div 2;
         Result := Result xor 33800;
      end
      else
         Result := Result div 2;
   end;
end;

procedure TFCRC.Button9Click(Sender: TObject);
var
 iLoop : integer;
 Aux : string;
begin
   // Convertendo hexadecimais para numeros
   for iLoop := 0 to Hexa.GetTextLen div 3 do
       Aux := Aux + Chr(HexToInt(Copy(Hexa.Text, (iLoop * 3) + 1, 2)));

   edNum.Text := '';
   for iLoop := 1 to Length(Aux) do
       edNum.Text := edNum.Text + IntToStr(Integer(Aux[iLoop])) + ' ';

   Aux := CalculaCRC2(Aux);

   ShowMessage(IntToHex(Integer(Aux[1]),2) + '/' + IntToHex(Integer(Aux[2]),2));
end;

procedure TFCRC.TimeOutTimer(Sender: TObject);
begin
   Cancela := true;
end;

procedure TFCRC.Button10Click(Sender: TObject);
var
 Aux, NumMagico, Aux2 : string;
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
         Porta.EnvMens('ATDT #778' + #13 + #10);
         if Porta.EnvMensEspResp(10000,'CONNECT') then
         begin
            Memo1.Lines.Add('Conectado');
            Memo1.Lines.Add(' ');

            Memo1.Lines.Add('Esperando o número mágico :');
            Memo1.Lines.Add(' ');
            Aux := RecebeDados;
            // Exibe o pacote recebido
            Memo1.Lines.Add(ConverteHexaShow(Aux));
            // Remove o 7D
            Aux := Remove7D(Aux);
            Memo1.Lines.Add(ConverteHexa(Aux));
            Memo1.Lines.Add(' ');
            NumMagico := Copy(Aux,26,4);
            Memo1.Lines.Add('Número mágico : ' + ConverteHexa(NumMagico));
            Memo1.Lines.Add(' ');
            Aux2 := Copy(Aux,6,2);

            // Enviando o primeiro pacote
            Memo1.Lines.Add('Enviando primeiro pacote :');
            Memo1.Lines.Add(' ');
            Aux := #255 + #003 + #192 + #033 + #002 + #002 + #000 + #028 +
                   #001 + #004 + #005 + #234 + #002 + #006 + #000 + #000 + #000 +
                   #000 + #003 + #004 + #192 + #035 + #005 + #006 + NumMagico +
                   #007 + #002 + #008 + #002;
            Aux := #126 + Aux + CalculaCRC(Aux) + #126;
            Aux := Insere7D(Aux);
            Memo1.Lines.Add(ConverteHexa(Remove7D(Aux)));
            Memo1.Lines.Add(ConverteHexaShow(Aux));
            Porta.EnvMens(Aux);
            Memo1.Lines.Add(' ');

{            Memo1.Lines.Add('Resposta do primeiro pacote');
            Memo1.Lines.Add(' ');
            Aux := RecebeDados;
            // Exibe o pacote recebido
            Memo1.Lines.Add(ConverteHexaShow(Aux));
            // Remove o 7D
            Aux := Remove7D(Aux);
            Memo1.Lines.Add(ConverteHexa(Aux));
            Memo1.Lines.Add(' ');}

            // Enviando o segundo pacote
            Memo1.Lines.Add('Enviando segundo pacote :');
            Memo1.Lines.Add(' ');
            Aux := #126 + #255 + #003 + #192 + #033 + #001 + #000 + #000 + #010 +
                   #005 + #006 + #000 + #000 + #001 + #000 + #172 + #051 + #126;
            Aux := Insere7D(Aux);
            Memo1.Lines.Add(ConverteHexa(Remove7D(Aux)));
            Memo1.Lines.Add(ConverteHexaShow(Aux));
            Porta.EnvMens(Aux);
            Memo1.Lines.Add(' ');

            Memo1.Lines.Add('Resposta do segundo pacote');
            Memo1.Lines.Add(' ');
            Aux := RecebeDados;
            // Exibe o pacote recebido
            Memo1.Lines.Add(ConverteHexaShow(Aux));
            // Remove o 7D
            Aux := Remove7D(Aux);
            Memo1.Lines.Add(ConverteHexa(Aux));
            Memo1.Lines.Add(' ');

            Memo1.Lines.Add('Conexão identica');

            Aux := ConfSenha + NumTel + Dominio + Senha;
            Aux := #126 + Aux + CalculaCRC(Aux) + #126;
            Memo1.Lines.Add(' ');
            Memo1.Lines.Add('Enviando terceiro pacote :');
            Memo1.Lines.Add(' ');
            Memo1.Lines.Add(ConverteHexa(Aux));
            Aux := Insere7D(Aux);
            Aux2 := Aux;
            Memo1.Lines.Add(ConverteHexaShow(Aux));
            Porta.EnvMens(Aux);
            Memo1.Lines.Add(' ');

            Memo1.Lines.Add('Resposta do terceiro pacote :');
            Memo1.Lines.Add(' ');
            Aux := RecebeDados;
            Memo1.Lines.Add(ConverteHexaShow(Aux));
            Aux := Remove7D(Aux);
            Memo1.Lines.Add(ConverteHexa(Aux));
            Memo1.Lines.Add(' ');

            if Copy(Aux, 1, 19) = RespSenha1 then
            begin
               Memo1.Lines.Add('Teceiro pacote OK');
               Memo1.Lines.Add(' ');

               Memo1.Lines.Add('Enviando quarto pacote :');
               Memo1.Lines.Add(' ');
               Aux := ConfSenha1 + NumMagico;
               Aux := #126 + Aux + CalculaCRC(Aux) + #126;
               Memo1.Lines.Add(ConverteHexa(Aux));
               Aux := Insere7D(Aux);
               Memo1.Lines.Add(ConverteHexaShow(Aux));
               Porta.EnvMens(Aux);
               Memo1.Lines.Add(' ');

               Memo1.Lines.Add('Enviando quinto pacote :');
               Memo1.Lines.Add(' ');
               Memo1.Lines.Add(ConverteHexa(Remove7D(Aux2)));
               Memo1.Lines.Add(ConverteHexaShow(Aux2));
               Porta.EnvMens(Aux2);
               Memo1.Lines.Add(' ');

               Memo1.Lines.Add('Resposta do quarto e do quinto pacote :');
               Memo1.Lines.Add(' ');
               Aux := RecebeDados;
               Memo1.Lines.Add(ConverteHexaShow(Aux));
               Aux := Remove7D(Aux);
               Memo1.Lines.Add(ConverteHexa(Aux));
               Memo1.Lines.Add(' ');

               if true then //Aux = RespSenhaC then
               begin
                  Memo1.Lines.Add('Quarto e quinto pacote OK');
                  Memo1.Lines.Add(' ');

                  Memo1.Lines.Add('Resposta :');
                  Memo1.Lines.Add(' ');
                  Aux := RecebeDados;
                  Memo1.Lines.Add(ConverteHexaShow(Aux));
                  Aux := Remove7D(Aux);
                  Memo1.Lines.Add(ConverteHexa(Aux));
                  Memo1.Lines.Add(' ');

                  Memo1.Lines.Add('Resposta :');
                  Memo1.Lines.Add(' ');
                  Aux := RecebeDados;
                  Memo1.Lines.Add(ConverteHexaShow(Aux));
                  Aux := Remove7D(Aux);
                  Memo1.Lines.Add(ConverteHexa(Aux));
                  Memo1.Lines.Add(' ');

                  NumMagico := Copy(Aux, 5, 1);
                  Memo1.Lines.Add('Numero do protocolo : ' + ConverteHexa(NumMagico));
                  Memo1.Lines.Add(' ');
                  Aux2 := #255 + #03 + #128 + #33 + #2 + Copy(Aux, 5, 9);

                  Aux2 := #126 + Aux2 + CalculaCRC(Aux2) + #126;

                  Memo1.Lines.Add('Enviando sexto pacote :');
                  Memo1.Lines.Add(' ');
                  Aux := #126 + #255 + #125 + #35 + #128 + #33 + #125 + #33 +
                         #125 + #32 + #125 + #32 + #125 + #54 + #125 + #35 +
                         #125 + #38 + #125 + #32 + #125 + #32 + #125 + #32 +
                         #125 + #32 + #129 + #125 + #38 + #125 + #32 + #125 +
                         #32 + #125 + #32 + #125 + #32 + #131 + #125 + #38 +
                         #125 + #32 + #125 + #32 + #125 + #32 + #125 + #32 +
                         #125 + #34 + #236 + #126;
                   Memo1.Lines.Add(ConverteHexa(Remove7D(Aux)));
                   Memo1.Lines.Add(ConverteHexaShow(Aux));
                   Memo1.Lines.Add(' ');
                   Porta.EnvMens(Aux);

                   Memo1.Lines.Add('Enviando sétimo pacote :');
                   Memo1.Lines.Add(' ');
                   Memo1.Lines.Add(ConverteHexa(Aux2));
                   Aux2 := Insere7D(Aux2);
                   Memo1.Lines.Add(ConverteHexaShow(Aux2));
                   Porta.EnvMens(Aux2);
                   Memo1.Lines.Add(' ');

                   Memo1.Lines.Add('Resposta do sexto e do sétimo pacote :');
                   Memo1.Lines.Add(' ');
                   Aux := RecebeDados;
                   Memo1.Lines.Add(ConverteHexaShow(Aux));
                   Aux := Remove7D(Aux);
                   Memo1.Lines.Add(ConverteHexa(Aux));
                   Memo1.Lines.Add(' ');

                   Memo1.Lines.Add('Enviando o oitavo comando :');
                   Aux := #126 + #255 + #125 + #35 + #128 + #33 + #125 + #33 +
                          #125 + #33 + #125 + #32 + #125 + #54 + #125 + #35 +
                          #125 + #38 + #125 + #42 + #41 + #125 + #54 + #125 +
                          #39 + #129 + #125 + #38 + #125 + #42 + #125 + #32 +
                          #125 + #32 + #254 + #131 + #125 + #38 + #125 + #32 +
                          #125 + #32 + #125 + #32 + #125 + #32 + #244 + #43 +
                          #126;
                   Memo1.Lines.Add(' ');
                   Memo1.Lines.Add(ConverteHexa(Remove7D(Aux)));
                   Memo1.Lines.Add(ConverteHexaShow(Aux));
                   Porta.EnvMens(Aux);
                   Memo1.Lines.Add(' ');

                   Memo1.Lines.Add('Resposta do oitavo pacote :');
                   Memo1.Lines.Add(' ');
                   Aux := RecebeDados;
                   Memo1.Lines.Add(ConverteHexaShow(Aux));
                   Aux := Remove7D(Aux);
                   Memo1.Lines.Add(ConverteHexa(Aux));
                   Memo1.Lines.Add(' ');
               end;
            end;
         end;
      end;
   end;
end;

end.



