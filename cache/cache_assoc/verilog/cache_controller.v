`default_nettype none
module cache_controller(
    // Outputs
    Done, Stall, CacheHit, error, cache_enable, 
    cache_offset, cache_comp, cache_write, cache_valid_in, 
    mem_addr, mem_write, mem_read,
    // Inputs
    clk, rst, system_read, system_write, system_tag, 
    system_index, system_offset, real_hit, victimize, 
    cache_tag_out, mem_stall
);

    /* Inputs */
    input wire clk;
    input wire rst;
    input wire system_read;
    input wire system_write;
    input wire [4:0] system_tag;
    input wire [7:0] system_index;
    input wire [2:0] system_offset;
    input wire real_hit;
    input wire victimize;
    input wire [4:0] cache_tag_out;
    input wire mem_stall;

    /* Outputs */
    output reg Done;
    output reg Stall;
    output reg CacheHit;
    output reg error;
    output reg cache_enable;
    output reg [2:0] cache_offset;
    output reg cache_comp;
    output reg cache_write;
    output reg cache_valid_in;
    output reg [15:0] mem_addr;
    output reg mem_write;
    output reg mem_read;

    /* State definitions */
    localparam IDLE = 4'b0000; // idle when done
    localparam VICTIMIZE_0 = 4'b0001; // write back to bank 0
    localparam VICTIMIZE_1 = 4'b0010; // wire back to bank 1
    localparam VICTIMIZE_2 = 4'b0011; // write back to bank 2
    localparam VICTIMIZE_3 = 4'b0100; // write back to bank 3
    localparam CACHE_LOAD_0 = 4'b0101; // grab data from bank 0
    localparam CACHE_LOAD_1 = 4'b0110; // grab data from bank 1
    localparam CACHE_LOAD_2 = 4'b0111; // grab data from bank 2 and write to cache word 0
    localparam CACHE_LOAD_3 = 4'b1000; // grab data from bank 3 and write to cache word 1
    localparam CACHE_LOAD_4 = 4'b1001; // write to cache word 2
    localparam CACHE_LOAD_5 = 4'b1010; // write to cache word 3
    localparam GRAB_DATA = 4'b1011; // grab the newly updated data from the cache
    localparam DONE = 4'b1100; // set done high for one cycle

    /* State transition logic */
    wire [3:0] state;
    reg [3:0] next_state;
    dff state_reg [3:0] (
        .q(state),
        .d(next_state),
        .clk(clk),
        .rst(rst)
    );

    /* FSM */
    always @(*) begin
        Done = 1'b0;
        Stall = 1'b1;
        CacheHit = 1'b0;
        error = 1'b0;
        cache_enable = 1'b1;
        cache_offset = 3'b000;
        cache_comp = 1'b0;
        cache_write = 1'b0;
        cache_valid_in = 1'b0;
        mem_addr = 16'h0000;
        mem_write = 1'b0;
        mem_read = 1'b0;
        next_state = state;

        case(state)
            IDLE: begin
                cache_comp = system_read | system_write;
                cache_offset = system_offset;
                cache_write = system_write;
                Done = (system_read | system_write) & real_hit;
                CacheHit = real_hit;
                Stall = 1'b0;
                next_state = (system_read | system_write) ? (real_hit ? IDLE : (victimize) ? VICTIMIZE_0 : CACHE_LOAD_0) : IDLE;
            end
            VICTIMIZE_0: begin
                mem_write = 1'b1;
                cache_offset = 3'b000; // cache must grab word 0
                mem_addr = {cache_tag_out, system_index, 3'b000}; // write cache output to first bank
                next_state = mem_stall ? VICTIMIZE_0 : VICTIMIZE_1;
            end
            VICTIMIZE_1: begin
                mem_write = 1'b1;
                cache_offset = 3'b010; // cache must grab word 1
                mem_addr = {cache_tag_out, system_index, 3'b010}; // write cache output to second bank
                next_state = mem_stall ? VICTIMIZE_1 : VICTIMIZE_2;
            end
            VICTIMIZE_2: begin
                mem_write = 1'b1;
                cache_offset = 3'b100; // cache must grab word 2
                mem_addr = {cache_tag_out, system_index, 3'b100}; // write cache output to third bank
                next_state = mem_stall ? VICTIMIZE_2 : VICTIMIZE_3;
            end
            VICTIMIZE_3: begin
                mem_write = 1'b1;
                cache_offset = 3'b110; // cache must grab word 3
                mem_addr = {cache_tag_out, system_index, 3'b110}; // write cache output to fourth bank
                next_state = mem_stall ? VICTIMIZE_3 : CACHE_LOAD_0;
            end
            CACHE_LOAD_0: begin
                // bank 0 is free now so grab word
                mem_read = 1'b1;
                mem_addr = {(system_read | system_write) ? system_tag : cache_tag_out, system_index, 3'b000}; // may need to fix
                next_state = mem_stall ? CACHE_LOAD_0 : CACHE_LOAD_1;
            end
            CACHE_LOAD_1: begin
                // bank 1 is free now so grab word
                mem_read = 1'b1;
                mem_addr = {(system_read | system_write) ? system_tag : cache_tag_out, system_index, 3'b010}; // may need to fix
                next_state = mem_stall ? CACHE_LOAD_1 : CACHE_LOAD_2;
            end
            CACHE_LOAD_2: begin
                // bank 2 is free
                mem_read = 1'b1;
                mem_addr = {(system_read | system_write) ? system_tag : cache_tag_out, system_index, 3'b100}; // may need to fix
                // write to cache word 0 on data line
                cache_offset = 3'b000;
                cache_write = 1'b1;
                next_state = mem_stall ? CACHE_LOAD_2 : CACHE_LOAD_3;
            end
            CACHE_LOAD_3: begin
                // bank 3 is free
                mem_read = 1'b1;
                mem_addr = {(system_read | system_write) ? system_tag : cache_tag_out, system_index, 3'b110}; // may need to fix
                // write to cache word 1 on data line
                cache_offset = 3'b010;
                cache_write = 1'b1;
                next_state = mem_stall ? CACHE_LOAD_3 : CACHE_LOAD_4;
            end
            CACHE_LOAD_4: begin
                // write to cache word 2 on data line
                cache_offset = 3'b100;
                cache_write = 1'b1;
                next_state = CACHE_LOAD_5; // stall will not be high now
            end
            CACHE_LOAD_5: begin
                // write to cache word 3 on data line
                cache_valid_in = 1'b1;
                cache_offset = 3'b110;
                cache_write = 1'b1;
                next_state = GRAB_DATA;
            end
            GRAB_DATA: begin
                // need to grab the data from the cache and display it on the data line by using comp
                cache_comp = 1'b1;
                cache_write = system_write;
                cache_offset = system_offset;
                next_state = DONE;
            end
            DONE: begin
                // assert done for one cycle and go back to idle, offset still needs to remain offset so that data out is correct
                Done = 1'b1;
                cache_offset = system_offset;
                next_state = IDLE;
            end
            default: begin
                error = 1'b1;
            end
        endcase
    end
endmodule