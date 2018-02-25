`timescale 1ns / 1ps

module i2s_sim ();
    reg tb_clk;
    reg tb_rst;
    reg tb_en;
    
    reg tb_lrclk; 
    reg tb_bclk;
    reg tb_sdi;
        
    wire tb_adc_valid_l;
    wire tb_adc_valid_r;
    wire [23:0] tb_adc_data;

    i2s uut
    (
        .clk(tb_clk),
        .rst(tb_rst),
        .lrclk(tb_lrclk),
        .bclk(tb_bclk),
        .sdi(tb_sdi),
        .en(tb_en),
        .adc_valid_l(tb_adc_valid_l),
        .adc_valid_r(tb_adc_valid_r),
        .adc_data(tb_adc_data)
    );
    
    initial begin
        tb_clk <= 0;
        tb_rst <= 1;
        tb_en <= 1;
        tb_lrclk <= 0;
        tb_bclk <= 0;
        tb_sdi <= 0;
        cntr <= 0;
         
        #20
        tb_rst <= 0;
    end
    
    //GENERATE CLOCK (100MHz)
    always #5 tb_clk = ~tb_clk;
    
    //GENERATE BCLK (~6.144MHz)
    always #163 tb_bclk = ~tb_bclk;
    
    //GENERATE LRCLK (25MHz / 32), LOAD SDI
    localparam data = 32'h12345678;
    reg [5:0] cntr;
    
    always @ (negedge tb_bclk)
    begin
        if(tb_rst)
            cntr <= 0;
        else begin
            
            cntr <= cntr + 1;
        
            tb_lrclk <= cntr[5];
        
            tb_sdi <= data[31 - cntr[4:0]];
            
        end
    end
endmodule