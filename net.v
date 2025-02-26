module bitonicSort8(
    input clk,
    input reset,
    input en,
    input [7:0] in0, in1, in2, in3, in4, in5, in6, in7,
    output reg done,
    output reg [7:0] out0, out1, out2, out3, out4, out5, out6, out7,
    output reg [7:0] value
);
    localparam IDLE = 2'b00,
               SORT = 2'b01,
               DONE = 2'b10;

    reg [1:0] state;
    reg [7:0] d[0:7];
    reg [3:0] step;
    reg [7:0] count;
    reg start;

    // Counter logic
    always @(posedge clk or negedge reset) begin
        if (!reset)
            count <= 0;
        else if (start && state == SORT)
            count <= count + 1;
        else if (state == IDLE)
            count <= 0;
    end

    // Main sorting logic
    always @(posedge clk or negedge reset)
    if (!reset) begin
        out0 <= 8'd0;
        out1 <= 8'd0;
        out2 <= 8'd0;
        out3 <= 8'd0;
        out4 <= 8'd0;
        out5 <= 8'd0;
        out6 <= 8'd0;
        out7 <= 8'd0;
        step <= 4'd0;
        done <= 1'd0;
        state <= IDLE;
        start <= 0;
    end else begin
        case(state)
            IDLE: begin
                d[0] <= in0;
                d[1] <= in1;
                d[2] <= in2;
                d[3] <= in3;
                d[4] <= in4;
                d[5] <= in5;
                d[6] <= in6;
                d[7] <= in7;
                step <= 0;
                done <= 1'd0;
                if(en) begin
                    state <= SORT;
                    start <= 1;
                end
            end 
            SORT: begin
                case(step)
                    0: begin
                        if(d[0] > d[1]) begin d[0] <= d[1]; d[1] <= d[0]; end
                        if(d[2] < d[3]) begin d[2] <= d[3]; d[3] <= d[2]; end
                        if(d[4] > d[5]) begin d[4] <= d[5]; d[5] <= d[4]; end
                        if(d[6] < d[7]) begin d[6] <= d[7]; d[7] <= d[6]; end
                        step <= step + 1;
                    end
                    1: begin
                        if(d[0] > d[2]) begin d[0] <= d[2]; d[2] <= d[0]; end
                        if(d[1] > d[3]) begin d[1] <= d[3]; d[3] <= d[1]; end
                        if(d[4] < d[6]) begin d[4] <= d[6]; d[6] <= d[4]; end
                        if(d[5] < d[7]) begin d[5] <= d[7]; d[7] <= d[5]; end
                        step <= step + 1;
                    end
                    2: begin
                        if(d[0] > d[1]) begin d[0] <= d[1]; d[1] <= d[0]; end
                        if(d[2] > d[3]) begin d[2] <= d[3]; d[3] <= d[2]; end
                        if(d[4] < d[5]) begin d[4] <= d[5]; d[5] <= d[4]; end
                        if(d[6] < d[7]) begin d[6] <= d[7]; d[7] <= d[6]; end
                        step <= step + 1;
                    end
                    3: begin
                        if(d[0] > d[4]) begin d[0] <= d[4]; d[4] <= d[0]; end
                        if(d[1] > d[5]) begin d[1] <= d[5]; d[5] <= d[1]; end
                        if(d[2] > d[6]) begin d[2] <= d[6]; d[6] <= d[2]; end
                        if(d[3] > d[7]) begin d[3] <= d[7]; d[7] <= d[3]; end
                        step <= step + 1;
                    end
                    4: begin
                        if(d[0] > d[2]) begin d[0] <= d[2]; d[2] <= d[0]; end
                        if(d[1] > d[3]) begin d[1] <= d[3]; d[3] <= d[1]; end
                        if(d[4] > d[6]) begin d[4] <= d[6]; d[6] <= d[4]; end
                        if(d[5] > d[7]) begin d[5] <= d[7]; d[7] <= d[5]; end
                        step <= step + 1;
                    end
                    5: begin
                        if(d[0] > d[1]) begin d[0] <= d[1]; d[1] <= d[0]; end
                        if(d[2] > d[3]) begin d[2] <= d[3]; d[3] <= d[2]; end
                        if(d[4] > d[5]) begin d[4] <= d[5]; d[5] <= d[4]; end
                        if(d[6] > d[7]) begin d[6] <= d[7]; d[7] <= d[6]; end
                        step <= 4'd0;
                        state <= DONE;
                        start <= 0;
                    end
                endcase
            end
            DONE: begin
                out0 <= d[0];
                out1 <= d[1];
                out2 <= d[2];
                out3 <= d[3];
                out4 <= d[4];
                out5 <= d[5];
                out6 <= d[6];
                out7 <= d[7];
                done <= 1'b1;
                value <= count;
                if (!en) state <= IDLE;
            end
            default: state <= IDLE;
        endcase
    end
endmodule

module bitonicSort8_tb();

    parameter CLK_PERIOD = 10;

    reg clk, reset, en;
    reg [7:0] in0, in1, in2, in3, in4, in5, in6, in7;
    wire done;
    wire [7:0] out0, out1, out2, out3, out4, out5, out6, out7;
    wire [7:0] value;

    bitonicSort8 bitonic_SORT8(
        .clk(clk),
        .reset(reset),
        .en(en),
        .in0(in0), .in1(in1), .in2(in2), .in3(in3),
        .in4(in4), .in5(in5), .in6(in6), .in7(in7),
        .done(done),
        .out0(out0), .out1(out1), .out2(out2), .out3(out3),
        .out4(out4), .out5(out5), .out6(out6), .out7(out7),
        .value(value)
    );

    // Clock generation
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test procedure
    initial begin
        // Initialize
        reset = 0;
        en = 0;
        in0 = 8'd0; in1 = 8'd0; in2 = 8'd0; in3 = 8'd0;
        in4 = 8'd0; in5 = 8'd0; in6 = 8'd0; in7 = 8'd0;

        // Reset
        #(CLK_PERIOD*2);
        reset = 1;
        #(CLK_PERIOD);

        // Test 1: Random input
        $display("\nTest 1: Random Input");
        in0 = 8'd6; in1 = 8'd3; in2 = 8'd1; in3 = 8'd8;
        in4 = 8'd9; in5 = 8'd10; in6 = 8'd2; in7 = 8'd4;
        display_input();
        en = 1;
        #(CLK_PERIOD);
        en = 0;
        wait(done);
        #(CLK_PERIOD);
        display_output();
        verify_sorted();

        // Reset between tests
        #(CLK_PERIOD*2);
        reset = 0;
        #(CLK_PERIOD);
        reset = 1;

        // Test 2: Reverse sorted
        $display("\nTest 2: Reverse Sorted Input");
        in0 = 8'd8; in1 = 8'd7; in2 = 8'd6; in3 = 8'd5;
        in4 = 8'd4; in5 = 8'd3; in6 = 8'd2; in7 = 8'd1;
        display_input();
        en = 1;
        #(CLK_PERIOD);
        en = 0;
        wait(done);
        #(CLK_PERIOD);
        display_output();
        verify_sorted();

        #(CLK_PERIOD*5);
        $finish;
    end

    // Display tasks
    task display_input;
        begin
            $display("Input array: [%d, %d, %d, %d, %d, %d, %d, %d]",
                in0, in1, in2, in3, in4, in5, in6, in7);
        end
    endtask

    task display_output;
        begin
            $display("Output array: [%d, %d, %d, %d, %d, %d, %d, %d]",
                out0, out1, out2, out3, out4, out5, out6, out7);
            $display("Cycle count: %d", value);
        end
    endtask

    task verify_sorted;
        begin
            if (out0 <= out1 && out1 <= out2 && out2 <= out3 &&
                out3 <= out4 && out4 <= out5 && out5 <= out6 && out6 <= out7)
                $display("PASSED: Array is sorted correctly");
            else
                $display("FAILED: Array is not sorted");
        end
    endtask

    // Monitor
    initial begin
        $monitor("Time=%0t State=%0d Step=%0d Done=%b Count=%d",
            $time, bitonic_SORT8.state, bitonic_SORT8.step, done, value);
    end
endmodule