module tb1 ();
  reg [17:0] A, B, D, BCIN;
  reg [47:0] C, PCIN;
  reg [7:0] OPMODE;
  reg CARRYIN, RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE;
  reg CLK, CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE;
  wire [17:0] BCOUT;
  wire [47:0] PCOUT, P;
  wire [35:0] M;
  wire CARRYOUT, CARRYOUTF;

  dsp #(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "OPMODE5", "DIRECT", "SYNC") DUT (
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
    // P = 79
    A = 5;
    B = 6;
    C = 9;
    D = 8;
    CARRYIN = 0;
    OPMODE = 8'b00011101;
    BCIN = $random;
    RSTA = 1;
    RSTB = 1;
    RSTM = 1;
    RSTP = 1;
    RSTC = 1;
    RSTD = 1;
    RSTCARRYIN = 1;
    RSTOPMODE = 1;
    CEA = 1;
    CEB = 1;
    CEM = 1;
    CEP = 1;
    CEC = 1;
    CED = 1;
    CECARRYIN = 1;
    CEOPMODE = 1;
    PCIN = 1;
    #10;

    // P = 160
    A = 10;
    B = 7;
    C = 10;
    D = 8;
    #10;

    // P = 73420
    A = 110;
    B = 78;
    C = 160;
    D = 588;
    #10;
    $stop;
  end

endmodule
