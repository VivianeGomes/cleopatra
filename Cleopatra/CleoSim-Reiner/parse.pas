procedure TForm1.Parse(line: String);
var
  tmp: String;
  resultado: TStrings;
  teste: TStrings;
  cleaning_line: integer;
  errado: boolean;

  iTemporario: integer;
  sTemporario: string;
  sTemporario2: string;

  function TipoAcesso : integer;
  begin
    iTemporario := pos('#',sTemporario);
    if iTemporario > 0 then
    begin
      //Acesso Imediato a memória
      execution.MachineCode.Cells[0,row_program]:= execution.MachineCode.Cells[0,row_program]+'0';
      if copy(sTemporario,Length(sTemporario),1) = 'h' then
        sTemporario:=UpperCase(sTemporario);
      execution.ProgramData.Cells[2,row_program]:= sTemporario;
      execution.MachineCode.Cells[1,row_program]:= sTemporario;
//      row_program:=row_program+1;
      TipoAcesso := 0;
      //exit;
    end
    else
    begin
      //Teste se o Modo de acesso é Indireto
      iTemporario := pos(',',sTemporario);
      if iTemporario > 0 then
      begin
        sTemporario2 := trim(copy(sTemporario,iTemporario+1,Length(sTemporario)));
        if sTemporario2 = 'i' then
        begin
          sTemporario := copy(sTemporario,1,iTemporario-1);
          execution.MachineCode.Cells[1,row_program]:=sTemporario;
          execution.MachineCode.Cells[0,row_program]:=execution.MachineCode.Cells[0,row_program]+'8';
          execution.ProgramData.Cells[2,row_program]:= sTemporario+',i';
//          row_program:=row_program+1;
          TipoAcesso := 2;
          //exit;
        end
        else
        begin
          if sTemporario2 = 'r' then
          begin
            sTemporario := copy(sTemporario,1,iTemporario-1);
            execution.MachineCode.Cells[1,row_program]:=sTemporario;
            execution.MachineCode.Cells[0,row_program]:=execution.MachineCode.Cells[0,row_program]+'8';
            execution.ProgramData.Cells[2,row_program]:= sTemporario+',i';
//            row_program:=row_program+1;
            TipoAcesso := 3;
          end
          else
          begin
            //AQUI POR O ERRO TIPO DE ACCESSO DESCONHECIDO
          end;
        end;
      end
      else
      begin
        if Length(sTemporario) > 0 then
        begin
          //Modo de acesso direto
          execution.MachineCode.Cells[0,row_program]:= execution.MachineCode.Cells[0,row_program]+'4';
          execution.MachineCode.Cells[1,row_program]:= sTemporario;
          execution.ProgramData.Cells[2,row_program]:= sTemporario;
//          row_program:=row_program+1;
          TipoAcesso := 1;
          //  exit;
        end
        else
        begin
          //AQUI POR O ERRO CASO NÃO TEM POSIÇÂO DE MEMÓRIA
        end;
      end;
    end;
  end;
begin



  errado := false;
  resultado := TStringList.Create();

  // Retira comentários da linha para fazer o parse apenas nos comandos
  cleaning_line:=pos(';',line);
  if cleaning_line > 0 then
  begin
    line := Copy(line,1,cleaning_line-1);
  end;
  line := trim(line);  // Retira espaços

  if Length(line)=0 then
    exit;

  line:=LowerCase(line);

  if Copy(line,1,1) = '.' then
  begin
   if line = '.code' then
    begin
      parse_programa:=true;
      exit;
    end
    else
      if line = '.endcode' then
      begin
        parse_programa:=false;
        exit;
      end
      else
        if line = '.data' then
        begin
          parse_dados:=true;
          exit;
        end
        else
          if line = '.enddata' then
          begin
            parse_dados:=false;
            exit;
          end;
  end;

  sTemporario := trim(copy(line,1,3));

  if sTemporario = 'org' then
  begin
    iTemporario := pos('#',line);
    if iTemporario > 0 then
    begin
       sTemporario := trim(copy(line,iTemporario+1,(pos('h',line)-(iTemporario+1))));
       posicao_memoria:=StrToInt('$'+UpperCase(sTemporario));
       exit;
    end;
  end;

  if parse_programa then
  begin
    // processa Labels
    iTemporario := pos(':',line);
    if iTemporario > 0 then
    begin
      sTemporario := copy(line,1,iTemporario-1);
      sTemporario := trim(sTemporario);
      line := copy(line,iTemporario+1,Length(line));
      line := trim(line);

      //Registra na tabela de memória os Labels
      execution.DataMemory.RowCount:=execution.DataMemory.RowCount+1;
      execution.DataMemory.Cells[0,execution.DataMemory.RowCount-1]:=sTemporario;
      execution.DataMemory.Cells[2,execution.DataMemory.RowCount-1]:='#'+UpperCase(IntToHex(posicao_memoria,2))+'H';
    end;

    sTemporario := copy(line,1,3);
    sTemporario := trim(sTemporario);

    if sTemporario = 'not' then
    begin
      execution.MachineCode.RowCount:=row_program+1;
      execution.ProgramData.RowCount:=row_program+1;
      execution.MachineCode.Cells[0,row_program]:= '00';
      execution.ProgramData.Cells[1,row_program]:= 'not';
      execution.ProgramData.Cells[0,row_program]:= IntToHex(posicao_memoria,2);
      row_program:=row_program+1;
      //exit;
    end
    else
    begin
      if sTemporario = 'lda' then
      begin
        execution.MachineCode.RowCount:=row_program+1;
        execution.ProgramData.RowCount:=row_program+1;

        execution.ProgramData.Cells[0,row_program]:= IntToHex(posicao_memoria,2);
        execution.ProgramData.Cells[1,row_program]:= 'lda';


        execution.MachineCode.Cells[0,row_program]:= '4';
        sTemporario := trim(copy(line,4,Length(line)));

        iTemporario := pos('#',sTemporario);
        TipoAcesso;
        row_program:=row_program+1;
      end
      else
      begin
        if sTemporario = 'hlt' then
        begin
          execution.MachineCode.RowCount:=row_program+1;
          execution.ProgramData.RowCount:=row_program+1;
          execution.MachineCode.Cells[0,row_program]:= 'F0';
          execution.ProgramData.Cells[0,row_program]:= IntToHex(posicao_memoria,2);
          execution.ProgramData.Cells[1,row_program]:= 'hlt';
          row_program:=row_program+1;
          //exit;
        end
        else
        begin
          if sTemporario = 'rts' then
          begin
            execution.MachineCode.RowCount:=row_program+1;
            execution.ProgramData.RowCount:=row_program+1;
            execution.MachineCode.Cells[0,row_program]:= 'D0';
            execution.ProgramData.Cells[0,row_program]:= IntToHex(posicao_memoria,2);
            execution.ProgramData.Cells[1,row_program]:= 'rts';
            row_program:=row_program+1;
            //exit;
          end
          else
          begin
            if sTemporario = 'sta' then
            begin
              execution.MachineCode.RowCount:=row_program+1;
              execution.ProgramData.RowCount:=row_program+1;
              execution.MachineCode.Cells[0,row_program]:= '2';
              execution.ProgramData.Cells[0,row_program]:= IntToHex(posicao_memoria,2);
              execution.ProgramData.Cells[1,row_program]:= 'sta';

              sTemporario := trim(copy(line,4,Length(line)));
              TipoAcesso;
              row_program:=row_program+1;
            end
            else
            begin
              if sTemporario = 'add' then
              begin
                execution.MachineCode.RowCount:=row_program+1;
                execution.ProgramData.RowCount:=row_program+1;
                execution.MachineCode.Cells[0,row_program]:= '5';
                execution.ProgramData.Cells[0,row_program]:= IntToHex(posicao_memoria,2);
                execution.ProgramData.Cells[1,row_program]:= 'add';

                sTemporario := trim(copy(line,4,Length(line)));
                TipoAcesso;
                row_program:=row_program+1;
              end
              else
              begin
                if sTemporario = 'or' then
                begin
                  execution.MachineCode.RowCount:=row_program+1;
                  execution.ProgramData.RowCount:=row_program+1;
                  execution.MachineCode.Cells[0,row_program]:= '6';
                  execution.ProgramData.Cells[0,row_program]:= IntToHex(posicao_memoria,2);
                  execution.ProgramData.Cells[1,row_program]:= 'or';

                  sTemporario := trim(copy(line,4,Length(line)));
                  TipoAcesso;
                  row_program:=row_program+1;
                end
                else
                begin
                  if sTemporario = 'and' then
                  begin
                    execution.MachineCode.RowCount:=row_program+1;
                    execution.ProgramData.RowCount:=row_program+1;
                    execution.MachineCode.Cells[0,row_program]:= '7';
                    execution.ProgramData.Cells[0,row_program]:= IntToHex(posicao_memoria,2);
                    execution.ProgramData.Cells[1,row_program]:= 'and';

                    sTemporario := trim(copy(line,4,Length(line)));
                    TipoAcesso;
                    row_program:=row_program+1;
                  end
                  else
                  begin
                    if sTemporario = 'jmp' then
                    begin
                      execution.MachineCode.RowCount:=row_program+1;
                      execution.ProgramData.RowCount:=row_program+1;
                      execution.MachineCode.Cells[0,row_program]:= '8';
                      execution.ProgramData.Cells[0,row_program]:= IntToHex(posicao_memoria,2);
                      execution.ProgramData.Cells[1,row_program]:= 'jmp';

                      sTemporario := trim(copy(line,4,Length(line)));
                      TipoAcesso;
                      row_program:=row_program+1;
                    end
                    else
                    begin
                      if sTemporario = 'jc' then
                      begin
                        execution.MachineCode.RowCount:=row_program+1;
                        execution.ProgramData.RowCount:=row_program+1;
                        execution.MachineCode.Cells[0,row_program]:= '9';
                        execution.ProgramData.Cells[0,row_program]:= IntToHex(posicao_memoria,2);
                        execution.ProgramData.Cells[1,row_program]:= 'jc';

                        sTemporario := trim(copy(line,4,Length(line)));
                        TipoAcesso;
                        row_program:=row_program+1;
                      end
                      else
                      begin
                        if sTemporario = 'jv' then
                        begin
                          execution.MachineCode.RowCount:=row_program+1;
                          execution.ProgramData.RowCount:=row_program+1;
                          execution.MachineCode.Cells[0,row_program]:= 'E';
                          execution.ProgramData.Cells[0,row_program]:= IntToHex(posicao_memoria,2);
                          execution.ProgramData.Cells[1,row_program]:= 'jv';

                          sTemporario := trim(copy(line,4,Length(line)));
                          TipoAcesso;
                          row_program:=row_program+1;
                        end
                        else
                        begin
                          if sTemporario = 'jn' then
                          begin
                            execution.MachineCode.RowCount:=row_program+1;
                            execution.ProgramData.RowCount:=row_program+1;
                            execution.MachineCode.Cells[0,row_program]:= 'A';
                            execution.ProgramData.Cells[0,row_program]:= IntToHex(posicao_memoria,2);
                            execution.ProgramData.Cells[1,row_program]:= 'jn';

                            sTemporario := trim(copy(line,4,Length(line)));
                            TipoAcesso;
                            row_program:=row_program+1;
                          end
                          else
                          begin
                            if sTemporario = 'jz' then
                            begin
                              execution.MachineCode.RowCount:=row_program+1;
                              execution.ProgramData.RowCount:=row_program+1;
                              execution.MachineCode.Cells[0,row_program]:= 'B';
                              execution.ProgramData.Cells[0,row_program]:= IntToHex(posicao_memoria,2);
                              execution.ProgramData.Cells[1,row_program]:= 'jz';

                              sTemporario := trim(copy(line,4,Length(line)));
                              TipoAcesso;
                              row_program:=row_program+1;
                            end
                            else
                            begin
                              if sTemporario = 'jsr' then
                              begin
                                execution.MachineCode.RowCount:=row_program+1;
                                execution.ProgramData.RowCount:=row_program+1;
                                execution.MachineCode.Cells[0,row_program]:= 'C';
                                execution.ProgramData.Cells[0,row_program]:= IntToHex(posicao_memoria,2);
                                execution.ProgramData.Cells[1,row_program]:= 'jsr';

                                sTemporario := trim(copy(line,4,Length(line)));
                                TipoAcesso;
                                row_program:=row_program+1;
                              end
                              else
                              begin
                                //FUNCAO DESCONHECIDA DAR ERRO
                              end;
                            end;
                          end;
                        end;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;

    posicao_memoria:=posicao_memoria+1;
  end;

  //Processa a parte da memória
  if parse_dados and (pos('db',line) > 0) then
  begin
    execution.DataMemory.RowCount:=execution.DataMemory.RowCount+1;
    iTemporario:=pos(':',line);
    if iTemporario > 0 then
    begin
      sTemporario := copy(line,1,iTemporario-1);
      sTemporario := trim(sTemporario);
      execution.DataMemory.Cells[0,execution.DataMemory.RowCount-1]:=sTemporario;
    end;
    iTemporario:=pos('db',line);

    if iTemporario > 0 then
    begin
      sTemporario := trim(copy(line,iTemporario+2,Length(line)));
      execution.DataMemory.Cells[1,execution.DataMemory.RowCount-1]:=sTemporario;
    end;
    execution.DataMemory.Cells[2,execution.DataMemory.RowCount-1]:='#'+UpperCase(IntToHex(posicao_memoria,2))+'H';
    posicao_memoria:=posicao_memoria+$1;
  end
  else
  begin
    if parse_dados then
      MessageDlg('Erro a linha está fodida',mtError,mbOKCancel,0);
  end;

end;