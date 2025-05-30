module PE0 (
    CLK, RST,

    outport_0_dataDeq,
    outport_0_dataOut,
    outport_0_dataValid,
    inport_0_dataDeq,
    inport_0_dataIn,
    inport_0_dataValid,
    control_in,
    control_out);

    input wire CLK, RST;

    input  wire [32-1:0] inport_0_dataIn;
    output reg  inport_0_dataDeq;   // wire
    input  wire inport_0_dataValid;
    output wire [32-1:0] outport_0_dataOut;
    input  wire outport_0_dataDeq;
    output wire outport_0_dataValid;

    input  wire [32-1:0] control_in;
    output wire [32-1:0] control_out;
           reg  [32-1:0] control_out_reg;
           reg  [32-1:0] control_out_reg_wire;

    wire outfifo_0_dataDeq; 
    reg outfifo_0_dataEnq; // wire
    wire outfifo_0_notEmpty, outfifo_0_notFull;
    reg  [32-1:0] outfifo_0_dataIn; // wire
    wire [32-1:0] outfifo_0_dataOut;
    FIFO2#(.width (32)) outfifo_0 (.CLK (CLK), .RST (~RST),
        .D_IN    (outfifo_0_dataIn),
        .D_OUT   (outfifo_0_dataOut),
        .ENQ     (outfifo_0_dataEnq),
        .DEQ     (outfifo_0_dataDeq),
        .EMPTY_N (outfifo_0_notEmpty),
        .FULL_N  (outfifo_0_notFull),
        .CLR     (1'b0));
    assign outport_0_dataOut   = outfifo_0_dataOut;
    assign outport_0_dataValid = outfifo_0_notEmpty;
    assign outfifo_0_dataDeq = outport_0_dataDeq;

    reg flitSent; // YOSYS = 1'b0;
    reg flitSent_next; // wire
    always @(posedge CLK) begin
        if (1'b1 == RST) begin
            flitSent <= 1'b0;
            control_out_reg <= 32'b0;
        end
        else begin
            flitSent <= flitSent_next;
            control_out_reg <= control_out_reg_wire;
        end
    end

    // assign control_out = flitSent_next;

    always @(*) begin
        flitSent_next = flitSent;
        outfifo_0_dataEnq = 1'b0;
        outfifo_0_dataIn = 32'b0;
        if (1'b1 == RST) begin
        end
        else begin
            if (1'b0 == flitSent) begin
                if (1'b1 == outfifo_0_notFull) begin
                    if (0 != control_in[0]) begin
                        flitSent_next = 1'b1;
                        outfifo_0_dataEnq = 1'b1;
                        //outfifo_0_dataIn = 32'b1;
                        outfifo_0_dataIn = {1'b0, control_in[31:1]}; //32'b100001;
                    end
                end
            end
        end
    end

    always @(*) begin
        control_out_reg_wire = 32'b0;
        inport_0_dataDeq = 1'b0;
        if (1'b1 == RST) begin
        end
        else begin
            if (1'b1 == inport_0_dataValid) begin
                inport_0_dataDeq = 1'b1;
                control_out_reg_wire = {1'b1, inport_0_dataIn[30:0]};
            end
        end
    end

    assign control_out = control_out_reg;

    always @(posedge CLK) begin
        if (1'b1 == RST) begin
        end
        else begin
            if (1'b1 ==  inport_0_dataValid) begin
                $display ("PE0: received flit [0x%08x]", inport_0_dataIn);
            end
        end
    end

endmodule

