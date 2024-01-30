/* ACM Class System (I) Fall Assignment 1
 *
 * Bonus: Floating Point Adder (32-bit)
 *
 * Reference: 
 * 1. https://en.wikipedia.org/wiki/IEEE_754
 * 2. https://blog.csdn.net/Phoenix_ZengHao/article/details/118760774
 *
 */

module adder(
        input clk, rst,
        input [31:0] x, y,
        output reg [31:0] z,
        output reg [1:0]  overflow //00: regular, 01: overflow, 10: underflow, 11: invalid input
    );
    reg [24:0] m_x, m_y, m_z; //mantissa (including hidden 1 and a reserved bit)
    reg [7:0] e_x, e_y, e_z; //exponent
    reg s_x, s_y, s_z; //sign

    reg [2:0] state_now, state_next; //state machine
    parameter start = 3'b000, zerocheck = 3'b001, matchexp = 3'b010,
              addm = 3'b011, normal = 3'b100, over = 3'b110;

    always @(posedge clk) begin
        if(~rst) begin
            state_now <= start;
        end
        else begin
            state_now <= state_next;
        end
    end

    //temporary reg for exponent matching
    reg [7:0] diff;
    reg [24:0] low;

    always @(*) begin
        case(state_now)
            start: begin //separate x, y into mantissa and exponent
                m_x <= {2'b01, x[22:0]};
                m_y <= {2'b01, y[22:0]};
                e_x <= x[30:23];
                e_y <= y[30:23];
                s_x <= x[31];
                s_y <= y[31];

                //check
                if((e_x == 8'd255 && m_x[22:0] != 0) || (e_y == 8'd255 && m_y[22:0] != 0)) begin //NaN
                    overflow <= 2'b11;
                    state_next <= over;
                    m_z <= 23'b1; //z = NaN
                    e_z <= 8'd255;
                    s_z <= 1'b1;
                end
                else if(e_x == 8'd255 && m_x[22:0] == 0) begin //x is Inf
                    overflow <= 2'b11;
                    state_next <= over;
                    m_z <= 23'b0;
                    e_z <= 8'd255;
                    s_z <= s_x;
                end
                else if(e_y == 8'd255 && m_y[22:0] == 0) begin //y is Inf
                    overflow <= 2'b11;
                    state_next <= over;
                    m_z <= 23'b0;
                    e_z <= 8'd255;
                    s_z <= s_y;
                end
                else begin
                    //correct the mantissa of unnormalized x, y
                    if(e_x == 0 && m_x[22:0] != 0) begin
                        m_x[23] <= 0;
                    end
                    if(e_y == 0 && m_y[22:0] != 0) begin
                        m_y[23] <= 0;
                    end
                    overflow <= 2'b00;
                    state_next <= zerocheck;
                end
            end

            zerocheck: begin //if x or y zero, jump to over
                if(e_x == 0 && m_x[22:0] == 0) begin
                    s_z <= s_y;
                    e_z <= e_y;
                    m_z <= m_y;
                    state_next <= over;
                end
                else if(e_y == 0 && m_y[22:0] == 0) begin
                    s_z <= s_x;
                    e_z <= e_x;
                    m_z <= m_x;
                    state_next <= over;
                end
                else begin
                    state_next <= matchexp;
                end
            end

            matchexp: begin //match exponent
                if(e_x == e_y) begin
                    state_next <= addm;
                end
                else if(e_x > e_y) begin //shift y right
                    diff = e_x - e_y;
                    low = m_y & ((1 << diff) - 1); //bits that be shifted out
                    m_y <= m_y >> diff;

                    if(low > (1 << (diff - 1))) begin
                        m_y = m_y + 1;
                    end
                    else if(low == (1 << (diff - 1)) && m_y[0] == 1) begin
                        m_y = m_y + 1;
                    end

                    if(m_y == 0) begin
                        s_z <= s_x;
                        e_z <= e_x;
                        m_z <= m_x;
                        state_next <= over;
                    end
                    else begin
                        e_y <= e_x;
                        state_next <= addm;
                    end
                end
                else begin //e_x < e_y, shift x right
                    diff = e_y - e_x;
                    low = m_x & ((1 << diff) - 1); //bits that be shifted out
                    m_x <= m_x >> diff;

                    if(low > (1 << (diff - 1))) begin
                        m_x = m_x + 1;
                    end
                    else if(low == (1 << (diff - 1)) && m_x[0] == 1) begin
                        m_x = m_x + 1;
                    end

                    if(m_x == 0) begin
                        s_z <= s_y;
                        e_z <= e_y;
                        m_z <= m_y;
                        state_next <= over;
                    end
                    else begin
                        e_x <= e_y;
                        state_next <= addm;
                    end
                end
            end

            addm: begin //add mantissa
                if(s_x ^ s_y == 1'b0) begin //same sign
                    e_z <= e_x;
                    s_z <= s_x;
                    m_z <= m_x + m_y;
                    state_next <= normal;
                end
                else begin //different sign
                    if(m_x > m_y) begin
                        e_z <= e_x;
                        s_z <= s_x;
                        m_z <= m_x - m_y;
                        state_next <= normal;
                    end
                    else if(m_x < m_y) begin
                        e_z <= e_y;
                        s_z <= s_y;
                        m_z <= m_y - m_x;
                        state_next <= normal;
                    end
                    else begin //zero
                        e_z <= e_x;
                        m_z <= 23'b0;
                        state_next <= over; //no need to normal
                    end
                end
            end

            normal: begin
                if(m_z[24] == 1'b1) begin //carry
                    if(m_z[0] == 1) begin
                        m_z <= m_z + 1; //round
                        state_next <= normal;
                    end
                    else begin
                        m_z <= {1'b0, m_z[24:1]};
                        e_z <= e_z + 1;
                        state_next <= over;
                    end
                end
                else begin
                    if(m_z[23] == 1'b0 && e_z >= 1) begin //first bit 0
                        m_z <= {m_z[23:0], 1'b0};
                        e_z <= e_z - 1;
                        state_next <= normal;
                    end
                    else begin
                        state_next <= over;
                    end
                end
            end

            over: begin
                z <= {s_z, e_z[7:0], m_z[22:0]};
                if(overflow == 2'b11) begin //unnormalized input, jumped from start directly
                    state_next <= start;
                end
                else if(e_z == 8'd255) begin
                    overflow <= 2'b01;
                    state_next <= start;
                end
                else if(e_z == 8'd0 && m_z[22:0] != 0) begin
                    overflow <= 2'b10; //underflow
                    state_next <= start;
                end
                else begin
                    overflow <= 2'b00;
                    state_next <= start;
                end
            end

            default: begin
                state_next <= start;
            end

        endcase
    end

endmodule //adder
