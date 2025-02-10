`default_nettype none
module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err,
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input wire [15:0] Addr;
   input wire [15:0] DataIn;
   input wire        Rd;
   input wire        Wr;
   input wire        createdump;
   input wire        clk;
   input wire        rst;
   
   output wire [15:0] DataOut;
   output wire        Done;
   output wire        Stall;
   output wire        CacheHit;
   output wire        err;

   /* Cache signals */
   wire [4:0] cache_tag_out;
   wire [15:0] cache_data_out;
   wire cache_hit, cache_dirty, cache_valid, cache_error;
   wire cache_enable, cache_comp, cache_write, cache_valid_in;
   wire [4:0] cache_tag_in; // tag from system address
   wire [7:0] cache_index;  // index from system address
   wire [2:0] cache_offset; // offset is calculated from FSM, handles W/R to different words in the line
   wire [15:0] cache_data_in;

   /* Memory signals */
   wire [15:0] mem_data_out;
   wire [15:0] mem_address;
   wire mem_stall, mem_error, mem_write, mem_read;

   /* FSM signals */
   wire fsm_error;
   wire victimize;
   wire real_hit;

   /* Assigns */
   assign cache_tag_in = Addr[15:11];
   assign cache_index = Addr[10:3];
   assign cache_data_in = cache_comp ? DataIn : mem_data_out; // take cache data from system on a compare, otherwise from memory to write
   assign DataOut = cache_data_out; // data presented to system will only ever be data from cache
   assign err = cache_error | mem_error | fsm_error; // error is the OR of cache and memory errors
   assign victimize = cache_dirty & cache_valid; // if we need to write back to memory
   assign real_hit = cache_hit & cache_valid; // if we have a hit and the data is valid

   parameter memtype = 0;
   cache #(0 + memtype) c0(
                        // Outputs
                        .tag_out              (cache_tag_out),
                        .data_out             (cache_data_out),
                        .hit                  (cache_hit),
                        .dirty                (cache_dirty),
                        .valid                (cache_valid),
                        .err                  (cache_error),
                        // Inputs
                        .enable               (cache_enable), // from FSM
                        .clk                  (clk), // from system
                        .rst                  (rst), // from system
                        .createdump           (createdump), // from system
                        .tag_in               (cache_tag_in), // from system, just the address tag
                        .index                (cache_index), // from system, just the address index
                        .offset               (cache_offset), // from FSM, calculated based on which bank we're writing to
                        .data_in              (cache_data_in), // from system, needs to be system data out when comp is high and mem data out when comp is low for access writes
                        .comp                 (cache_comp), // from FSM, if we're doing checks or not or just access reading or writing
                        .write                (cache_write), // from FSM, if we're writing to the cache or not
                        .valid_in             (cache_valid_in)); // from FSM, this is the valid bit and should be set to 1 once we finish writing a full line

four_bank_mem mem(
                  // Outputs
                  .data_out          (mem_data_out),
                  .stall             (mem_stall),
                  .busy              (),				// not needed
                  .err               (mem_error),
                  // Inputs
                  .clk               (clk), // from system
                  .rst               (rst), // from system
                  .createdump        (createdump), // from system
                  .addr              (mem_address), // from FSM, not system because we need to change the tag based on what operation we're doing
                  .data_in           (cache_data_out), // from cache, we only ever write to the memory using cache data
                  .wr                (mem_write), // from FSM, if we're writing to memory or not
                  .rd                (mem_read)); // from FSM, if we're reading from memory or not

cache_controller cache_fsm(
   // Outputs
   .Done(Done),
   .Stall(Stall),
   .CacheHit(CacheHit),
   .error(fsm_error),
   .cache_enable(cache_enable),
   .cache_offset(cache_offset),
   .cache_comp(cache_comp),
   .cache_write(cache_write),
   .cache_valid_in(cache_valid_in),
   .mem_addr(mem_address),
   .mem_write(mem_write),
   .mem_read(mem_read),
   // Inputs
   .clk(clk),
   .rst(rst),
   .system_read(Rd),
   .system_write(Wr),
   .system_tag(Addr[15:11]),
   .system_index(Addr[10:3]),
   .system_offset(Addr[2:0]),
   .real_hit(real_hit),
   .victimize(victimize),
   .cache_tag_out(cache_tag_out),
   .mem_stall(mem_stall)
);

endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9: