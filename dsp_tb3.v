module tb3 ();
  reg [17:0] A, B, D, BCIN;
  reg [47:0] C, PCIN;
  reg [7:0] OPMODE;
  reg CARRYIN, RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE;
  reg CLK, CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE;
  wire [17:0] BCOUT;
  wire [47:0] PCOUT, P;
  wire [35:0] M;
  wire CARRYOUT, CARRYOUTF;

  dsp #(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, "OPMODE5", "DIRECT", "ASYNC") DUT (
      A,
      B,
      D,
      C,
      CLK,
      CARRYIN,
      OPMODE,
      BCIN,
      RSTA,
      RSTB,
      RSTM,
      RSTP,
      RSTC,
      RSTD,
      RSTCARRYIN,
      RSTOPMODE,
      CEA,
      CEB,
      CEM,
      CEP,
      CEC,
      CED,
      CECARRYIN,
      CEOPMODE,
      PCIN,
      BCOUT,
      PCOUT,
      P,
      M,
      CARRYOUT,
      CARRYOUTF
  );

  initial begin
    CLK = 0;
    forever begin
      #20 CLK = ~CLK;
    end
  end

  initial begin
    RSTA = 1;
    RSTB = 1;
    RSTM = 1;
    RSTP = 1;
    RSTC = 1;
    RSTD = 1;
    RSTCARRYIN = 1;
    RSTOPMODE = 1;
    repeat (3) @(negedge CLK);

    // P = 79

    RSTA = 0;
    RSTB = 0;
    RSTM = 0;
    RSTP = 0;
    RSTC = 0;
    RSTD = 0;
    RSTCARRYIN = 0;
    RSTOPMODE = 0;

    CEA = 1;
    CEB = 1;
    CEM = 1;
    CEP = 1;
    CEC = 1;
    CED = 1;
    CECARRYIN = 1;
    CEOPMODE = 1;

    A = 5;
    B = 6;
    C = 9;
    D = 8;
    CARRYIN = 0;
    OPMODE = 8'b00011101;
    BCIN = $random;
    PCIN = $random;
    repeat (3) @(negedge CLK);

    // P = 160
    A = 10;
    B = 7;
    C = 10;
    D = 8;
    repeat (3) @(negedge CLK);

    // P = 73420
    A = 110;
    B = 78;
    C = 160;
    D = 588;
    repeat (5) @(negedge CLK);
    $stop;
  end

endmodule
