module window_buffer (
    input  wire clk,
    input  wire rst_n,
    input  wire [7:0] pixel_in,
    output reg [199:0] window_out,
    output reg window_valid
);

    reg [7:0] row_buffer0 [0:31];  
    reg [7:0] row_buffer1 [0:31];  
    reg [7:0] row_buffer2 [0:31];  
    reg [7:0] row_buffer3 [0:31];  

    reg [5:0] col_count;  
    reg [5:0] row_count;  

    integer c;  
    integer r;  

    reg [7:0] old_buf0, old_buf1, old_buf2, old_buf3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col_count <= 0;
            row_count <= 0;
            window_out <= 200'd0;
            window_valid <= 1'b0;
            for (c = 0; c < 31; c = c + 1) begin
                row_buffer0[c] <= 8'd0;
                row_buffer1[c] <= 8'd0;
                row_buffer2[c] <= 8'd0;
                row_buffer3[c] <= 8'd0;
            end
        end else begin

            old_buf0 = row_buffer0[col_count];  
            old_buf1 = row_buffer1[col_count];  
            old_buf2 = row_buffer2[col_count]; 
            old_buf3 = row_buffer3[col_count];

            row_buffer0[col_count] <= pixel_in;  
            row_buffer1[col_count] <= old_buf0;
            row_buffer2[col_count] <= old_buf1;
            row_buffer3[col_count] <= old_buf2;
         
            for (r = 0; r < 5; r = r + 1) begin
                window_out[(8*(r*5+0)) +: 8] <= window_out[(8*(r*5+1)) +: 8];
                window_out[(8*(r*5+1)) +: 8] <= window_out[(8*(r*5+2)) +: 8];
                window_out[(8*(r*5+2)) +: 8] <= window_out[(8*(r*5+3)) +: 8];
                window_out[(8*(r*5+3)) +: 8] <= window_out[(8*(r*5+4)) +: 8];

            end

            window_out[(8*(0*5+4)) +: 8] <= old_buf3;   
            window_out[(8*(1*5+4)) +: 8] <= old_buf2;   
            window_out[(8*(2*5+4)) +: 8] <= old_buf1;  
            window_out[(8*(3*5+4)) +: 8] <= old_buf0;   
            window_out[(8*(4*5+4)) +: 8] <= pixel_in;   

            if (col_count == 30) begin
                col_count <= 0;   
                row_count <= row_count + 1;
            end else begin
                col_count <= col_count + 1;
            end
            window_valid <= (row_count >= 4) && (col_count >= 4);
        end
    end
endmodule